import std.algorithm;
import std.bigint;
import std.bitmanip;
import std.conv;
import std.datetime.stopwatch : StopWatch;
import std.functional;
import std.digest;
import std.json;
import std.stdio;
import std.string;
import std.socket;

import core.thread;

import libsodium;

import accessories;
import custom_http;
import http_util;
import hkdf;
import mdns_sd;
import srp_params;
import srp;
import tlv;

CustomHTTP httpServer;
SrpServer srpServer;
TLVStates State;

HAPAccessory[] accs;

enum ACC_NAME = "_hellp_";
enum ACC_MAC = "01:01:01:01:01:01";
enum ACC_PIN = "111-11-111";
ubyte[crypto_sign_PUBLICKEYBYTES] ACC_PK;
ubyte[crypto_sign_SECRETKEYBYTES] ACC_SK;

ubyte[] enc_clientPublicKey,
  enc_secretKey,
  enc_publicKey,
  enc_sharedSec,
  enc_hkdfPairEncKey,
  enc_accessoryToControllerKey,
  enc_controllerToAccessoryKey;

ubyte[] fragment;

ulong in_count, out_count;

ubyte[][string] CLI_PUB;

ubyte[] layerEncrypt(ubyte[] data, ref ulong count, ubyte[] key) {
  ubyte[] result;
  size_t total = data.length;
  for (size_t offset = 0; offset < total; ) {
    ushort length = to!ushort(total - offset);
    if (length > 1024) length = 1024;

    ubyte[2] leLength = nativeToLittleEndian(length);
    ubyte[] nonce = cast(ubyte[]) [0, 0, 0, 0] ~ nativeToLittleEndian(count);
    count += 1;

    ubyte[] message = data[offset..offset+length].dup;

    ubyte[] encrypted;
    encrypted.length = message.length;
    ubyte[crypto_aead_chacha20poly1305_ABYTES] auth;
    ulong authlen;

    crypto_aead_chacha20poly1305_ietf_encrypt_detached(encrypted.ptr, auth.ptr, &authlen, 
        message.ptr, message.length, leLength.ptr, leLength.length, null, nonce.ptr, key.ptr);

    offset += length;

    result ~= leLength;
    result ~= encrypted;
    result ~= auth[0..authlen];
  }

  return result.dup;
}

ubyte[] layerDecrypt(ubyte[] packet, ref ulong count, ubyte[] key) {
  if (fragment.length > 0) {
    packet = fragment ~ packet;
  }

  ubyte[] result;
  size_t total = packet.length;

  for (size_t offset = 0; offset < total;) {
    ushort x = packet.peek!(ushort, Endian.littleEndian)(offset);
    size_t realDataLength = to!size_t(x);

    auto availableDataLength = total - offset - 2 - 16;
    if (realDataLength > availableDataLength) {
      // Fragmented packet
      fragment = packet[offset..$];
      break;
    } else {
      fragment = [];
    }

    ubyte[] nonce =  cast(ubyte[])[0, 0, 0, 0] ~ nativeToLittleEndian(count);
    count += 1;

    ubyte[] messageData = packet[offset+2..offset+2+realDataLength].dup;
    ubyte[] authTagData = packet[offset+2+realDataLength..offset+2+realDataLength+16].dup;
    ubyte[] additional = packet[offset..offset+2].dup;
    ubyte[] plaintext; plaintext.length = messageData.length;

    int dec_res = crypto_aead_chacha20poly1305_ietf_decrypt_detached(
        plaintext.ptr,
        null, // nsec
        messageData.ptr, messageData.length,
        authTagData.ptr, // mac
        additional.ptr, additional.length, // additional
        nonce.ptr, key.ptr);

    result ~= plaintext.dup;
    offset += (18 + realDataLength);
  }

  return result;
}


void handleByteRequest(string client_addr, ubyte[] enc_message) {
  ubyte[] dec = layerDecrypt(enc_message, in_count, enc_controllerToAccessoryKey);

  string status;
  string[string] headers;
  string content;

  bool decoded = decodeHTTP(cast(string)dec, status, headers, content);

  writeln(status);
  writeln(headers);
  writeln(content);

  string method = status.split(" ")[0];
  string path = status.split(" ")[1];

  if (method == "GET" && path == "/accessories") {
    writeln("iOS device requesting accessory list");


    string resStatus = "HTTP/1.1 200 OK";
    string[string] resHeaders; 
    resHeaders["Content-Type"] = "application/hap+json";

    JSONValue jaccs = parseJSON("{}");
    jaccs["accessories"] = parseJSON("[]");
    foreach(a; accs) {
      jaccs["accessories"].array ~= parseJSON(a.toJSON);
    }

    string resBody = jaccs.toJSON;

    resHeaders["Content-Length"] = to!string(resBody.length);

    string response = encodeHTTP(resStatus, resHeaders, resBody);
    writeln("Sending response: ", response);

    // attempt to send accessory list list
    ubyte[] enc = layerEncrypt(cast(ubyte[])response,
        out_count, enc_accessoryToControllerKey);
    httpServer.sendByteResponse(client_addr, enc);
  } else if (method == "GET" && path.indexOf("/characteristics") > -1) {
    // GET /characteristics?id=2.10 HTTP/1.1
    uint aid, iid;
    auto query = path.split("?")[1];
    aid = parse!uint(query.split("=")[1].split(".")[0]);
    iid = parse!uint(query.split("=")[1].split(".")[1]);
    writeln("wanna know status of ", aid, "-", iid);
    JSONValue j = parseJSON("{}");
    foreach(a; accs) {
      if (a.aid != aid) continue;
      foreach(s;a.services) {
        foreach(c; s.chars) {
          if (c.iid != iid) continue;
          writeln("characteristic value: ", c.value);
          j["characteristics"] = parseJSON("[]");
          j["characteristics"].array ~= parseJSON("{}");
          j["characteristics"].array[0]["aid"] = JSONValue(aid);
          j["characteristics"].array[0]["iid"] = JSONValue(iid);
          j["characteristics"].array[0]["value"] = c.value;
        }
      }
    }

    string resStatus = "HTTP/1.1 200 OK";
    string[string] resHeaders; 
    resHeaders["Content-Type"] = "application/hap+json";
    string resBody = j.toJSON;

    resHeaders["Content-Length"] = to!string(resBody.length);

    string response = encodeHTTP(resStatus, resHeaders, resBody);
    writeln("Sending response: ", response);

    ubyte[] enc = layerEncrypt(cast(ubyte[])response,
        out_count, enc_accessoryToControllerKey);
    httpServer.sendByteResponse(client_addr, enc);
  } else if (method == "PUT" && path == "/characteristics") {
    JSONValue j = parseJSON(content);
    foreach(jc; j["characteristics"].array) {
      uint aid = to!uint(jc["aid"].integer);
      uint iid = to!uint(jc["iid"].integer);
      if (("value" in jc) is null) continue;
      JSONValue jv = jc["value"];
      for(auto a = 0; a < accs.length; a += 1) {
        if (accs[a].aid != aid) continue;
        for (auto s = 0; s < accs[a].services.length; s += 1) {
          for(auto c = 0; c < accs[a].services[s].chars.length; c += 1) {
            if (accs[a].services[s].chars[c].iid != iid) continue;
            accs[a].services[s].chars[c].value = jv;
          }
        }
      }
    }
    string resStatus = "HTTP/1.1 204 No Content";
    string[string] resHeaders; 
    string resBody = "";

    string response = encodeHTTP(resStatus, resHeaders, resBody);
    writeln("Sending response: ", response);
    ubyte[] enc = layerEncrypt(cast(ubyte[])response,
        out_count, enc_accessoryToControllerKey);
    httpServer.sendByteResponse(client_addr, enc);
  }
}

void handleHttpRequest(string client_addr, 
    string status, string[string] headers, string content) {
  writeln("http request from remote device");

  string method = status.split(" ")[0];
  string path = status.split(" ")[1];

  if (path == "/pair-verify") {
    ubyte[] buffer = cast(ubyte[]) content;

    auto tlvReq = decodeTlv(buffer);
    writeln("tlvReq: ", tlvReq);
    auto tlvReqState = tlvReq[TLVTypes.state].value[0];
    if (tlvReqState == TLVStates.M1) {
      writeln("pair-verify step 1/2");
      ubyte[] clientPublicKey = tlvReq[TLVTypes.public_key].value;
      // generate new encryption keys for this session
      ubyte[crypto_sign_PUBLICKEYBYTES] publicKey;
      ubyte[crypto_sign_SECRETKEYBYTES] secretKey;
      crypto_box_keypair(publicKey.ptr, secretKey.ptr);
      ubyte[crypto_scalarmult_BYTES] sharedSec;
      crypto_scalarmult(sharedSec.ptr, secretKey.ptr, clientPublicKey.ptr);
      ubyte[] usernameData = cast(ubyte[]) ACC_MAC;
      ubyte[] material = publicKey ~ usernameData ~ clientPublicKey;
      ubyte[] privateKey = ACC_SK;
      ubyte[crypto_sign_BYTES] serverProof;
      ulong siglen;
      crypto_sign_detached(serverProof.ptr, &siglen,
          material.ptr, material.length, privateKey.ptr);

      string encSalt = "Pair-Verify-Encrypt-Salt";
      string encInfo = "Pair-Verify-Encrypt-Info";
      ubyte[] outputKey = hkdf_ex(sharedSec.dup, 
          cast(ubyte[])encSalt, encInfo, 32)[0..32]; 

      enc_clientPublicKey = clientPublicKey.dup;
      enc_secretKey = secretKey.dup;
      enc_publicKey = publicKey.dup;
      enc_sharedSec = sharedSec.dup;
      enc_hkdfPairEncKey = outputKey.dup;

      TLVMessage[2] tRes;
      tRes[0].type = TLVTypes.identifier;
      tRes[0].value = usernameData;
      tRes[1].type = TLVTypes.signature;
      tRes[1].value = serverProof;

      ubyte[] message = encodeTlv(tRes);

      //const encrypted = hapCrypto.chacha20_poly1305_encryptAndSeal(outputKey, Buffer.from("PV-Msg02"), null, message);

      ubyte[] encrypted;
      encrypted.length = message.length;
      ubyte[crypto_aead_chacha20poly1305_ABYTES] auth;
      ulong authlen;
      ubyte[] nonce = cast(ubyte[])[0, 0, 0, 0] ~ cast(ubyte[])"PV-Msg02";

      crypto_aead_chacha20poly1305_ietf_encrypt_detached(encrypted.ptr, auth.ptr, &authlen, 
          message.ptr, message.length, null, 0,
          null, nonce.ptr, outputKey.ptr);

      ubyte[] enc_a = encrypted ~ auth;

      TLVMessage[3] tEnc;
      tEnc[0].type = TLVTypes.state;
      tEnc[0].value ~= TLVStates.M2;
      tEnc[1].type = TLVTypes.encrypted_data;
      tEnc[1].value = enc_a;
      tEnc[2].type = TLVTypes.public_key;
      tEnc[2].value = publicKey;

      httpServer.sendHttpResponse(client_addr, encodeTlv(tEnc), "application/pairing+tlv8");
      writeln("pair-verify step 1/2: sending response");
    } else if (tlvReqState == TLVStates.M3) {
      writeln("pair-verify step 2/2");
      ubyte[] encryptedData = tlvReq[TLVTypes.encrypted_data].value;
      ubyte[] messageData = encryptedData[0..$-16]; 
      ubyte[] authTagData = encryptedData[$-16..$];
      ubyte[] plaintext; plaintext.length = messageData.length;
      ubyte[] nonce = cast(ubyte[])[0, 0, 0, 0] ~ cast(ubyte[]) "PV-Msg03";
      int dec_res = crypto_aead_chacha20poly1305_ietf_decrypt_detached(
          plaintext.ptr,
          null, // nsec
          messageData.ptr, messageData.length,
          authTagData.ptr, // mac
          null, 0, // additional
          nonce.ptr, enc_hkdfPairEncKey.ptr);
      auto decoded = decodeTlv(plaintext);
      ubyte[] clientUsername = decoded[TLVTypes.identifier].value;
      ubyte[] proof = decoded[TLVTypes.signature].value;
      ubyte[] material = 
        enc_clientPublicKey ~ clientUsername ~ enc_publicKey;

      if ((clientUsername.toHexString in CLI_PUB) is null) {
        throw new Exception("Client want to verify, but not paired; rejecting: ");
      }
      ubyte[] clientPublicKey = CLI_PUB[clientUsername.toHexString];
      // TODO: verify material proof clientPublicKey
      int verify_res = crypto_sign_verify_detached(proof.ptr, 
          material.ptr, material.length, clientPublicKey.ptr);
      bool result = verify_res > -1; //verify_detached(material, proof, clientPublicKey);
      writeln("signature verified: ", result);
      if (!result) {
        throw new Exception("Wrong signature");
      }
      TLVMessage[1] tRes;
      tRes[0].type = TLVTypes.state;
      tRes[0].value ~= TLVStates.M4;
      // send response
      writeln("pair-verify step 2/2: sending response");
      httpServer.sendHttpResponse(client_addr, encodeTlv(tRes), "application/pairing+tlv8");
      // "upgrade" HTTP connection 
      httpServer.switchToEncryptedMode(client_addr);
      // save encryption keys
      string encSalt = "Control-Salt";
      string infoRead = "Control-Read-Encryption-Key";
      string infoWrite = "Control-Write-Encryption-Key";
      enc_accessoryToControllerKey = hkdf_ex(enc_sharedSec.dup, 
          cast(ubyte[])encSalt, infoRead, 32)[0..32].dup; 
      enc_controllerToAccessoryKey = hkdf_ex(enc_sharedSec.dup, 
          cast(ubyte[])encSalt, infoWrite, 32)[0..32].dup; 
      in_count = 0; out_count = 0;
    }
  } else if (path == "/pair-setup") {
    ubyte[] buffer = cast(ubyte[]) content;

    auto tlvReq = decodeTlv(buffer);

    auto tlvReqState = tlvReq[TLVTypes.state].value[0];

    if (tlvReqState == TLVStates.M1) {
      writeln("pair setup step 1/5");
      // step one
      SrpParam srpParams = getSrpParamHap();
      ubyte[16] salt;
      randombytes_buf(salt.ptr, salt.length);

      ubyte[32] key; 
      randombytes_buf(key.ptr, key.length);

      ubyte[] id = cast(ubyte[])"Pair-Setup";

      ubyte[] pin = cast(ubyte[])ACC_PIN;

      srpServer = new SrpServer(srpParams, salt, id, pin, key);
      auto srpB = srpServer.get_B();

      TLVMessage[3] tRes;
      tRes[0].type = TLVTypes.state;
      tRes[0].value ~= TLVStates.M2;
      tRes[1].type = TLVTypes.salt;
      tRes[1].value = salt;
      tRes[2].type = TLVTypes.public_key;
      tRes[2].value = srpB;

      httpServer.sendHttpResponse(client_addr, encodeTlv(tRes), "application/pairing+tlv8");
      State = TLVStates.M2;
    } else if (tlvReqState == TLVStates.M3 && State == TLVStates.M2) {
      writeln("pair setup step 2/5");
      auto A = tlvReq[TLVTypes.public_key].value;
      auto M1 = tlvReq[TLVTypes.password_proof].value;
      srpServer.set_A(A);
      ubyte[] M2;
      try {
        M2 = srpServer.verify(M1);
      } catch (Exception err) {
        // most likely the client supplied an incorrect pincode.
        writeln("Error while checking pincode: ", err.message);
        TLVMessage[2] tRes;
        tRes[0].type = TLVTypes.state;
        tRes[0].value ~= TLVStates.M4;
        tRes[1].type = TLVTypes.error;
        tRes[1].value ~= TLVErrors.authentication;

        httpServer.sendHttpResponse(client_addr, encodeTlv(tRes), "application/pairing+tlv8");
        State = TLVStates.unknown;
        return;
      }
      writeln("client provided correct PIN.");
      // "M2 is the proof that the server actually knows your password."
      State = TLVStates.M2;

      TLVMessage[2] tRes;
      tRes[0].type = TLVTypes.state;
      tRes[0].value ~= TLVStates.M4;
      tRes[1].type = TLVTypes.password_proof;
      tRes[1].value = M2;

      //res.writeBody(encodeTlv(tRes), "application/pairing+tlv8");
      httpServer.sendHttpResponse(client_addr, encodeTlv(tRes), "application/pairing+tlv8");
    } else if (tlvReqState == TLVStates.M5 && State == TLVStates.M2) {
      writeln("pair setup step 3/5");
      ubyte[] encrypted_data = tlvReq[TLVTypes.encrypted_data].value;
      ubyte[] message_data = encrypted_data[0..$-16].dup;
      ubyte[] authtag_data = encrypted_data[$-16..$].dup;
      ubyte[] session_key = bi2buf(srpServer.return_session_key()).dup;
      string PAIRING_3_SALT = "Pair-Setup-Encrypt-Salt";
      string PAIRING_3_INFO = "Pair-Setup-Encrypt-Info";
      string PAIRING_3_NONCE = "PS-Msg05";
      size_t OUTPUT_LEN = 32; 
      ubyte[] hap3_hkdf = hkdf_ex(session_key.dup, cast(ubyte[])PAIRING_3_SALT,
          PAIRING_3_INFO, OUTPUT_LEN); 

      ubyte[] p3nonce = cast(ubyte[])[0, 0, 0, 0] ~ cast(ubyte[]) PAIRING_3_NONCE;

      ubyte[] decrypted_data; decrypted_data.length = encrypted_data.length;
      ulong decrypted_length;

      int dec_res = crypto_aead_chacha20poly1305_ietf_decrypt_detached(
          decrypted_data.ptr,
          null, // nsec
          message_data.ptr, message_data.length,
          authtag_data.ptr, // mac
          null, 0, // additional
          p3nonce.ptr, hap3_hkdf.ptr);

      auto tlvData = decodeTlv(decrypted_data);
      ubyte[] client_public = tlvData[TLVTypes.public_key].value;
      ubyte[] client_sign = tlvData[TLVTypes.signature].value;
      ubyte[] client_id = tlvData[TLVTypes.identifier].value;

      // step 4/5
      // ed25519 verify
      writeln("pair setup step 4/5");
      string PAIRING_4_SALT = "Pair-Setup-Controller-Sign-Salt";
      string PAIRING_4_INFO = "Pair-Setup-Controller-Sign-Info";

      ubyte[] hap4_hkdf = hkdf_ex(session_key.dup, cast(ubyte[])PAIRING_4_SALT,
          PAIRING_4_INFO, OUTPUT_LEN); 
      ubyte[] vdata;
      vdata = hap4_hkdf ~ client_id ~ client_public;
      int verify_res = crypto_sign_verify_detached(client_sign.ptr, 
          vdata.ptr, vdata.length, client_public.ptr);
      bool result = verify_res == 0;
      writeln("signature verified: ", result);
      // TODO: send response if error and return

      // step 5/5
      writeln("pair setup step 5/5");
      string PAIRING_5_SALT = "Pair-Setup-Accessory-Sign-Salt";
      string PAIRING_5_INFO = "Pair-Setup-Accessory-Sign-Info";
      string PAIRING_5_NONCE = "PS-Msg06";
      ubyte[] hap5_hkdf = hkdf_ex(session_key.dup, cast(ubyte[])PAIRING_5_SALT,
          PAIRING_5_INFO, OUTPUT_LEN); 

      //crypto_sign_keypair(ACC_PK.ptr, ACC_SK.ptr);
      crypto_sign_keypair(ACC_PK.ptr, ACC_SK.ptr);

      ubyte[] material = hap5_hkdf.dup;
      material ~= cast(ubyte[]) ACC_MAC.dup;
      material ~= ACC_PK.dup;
      ubyte[crypto_sign_BYTES] serverProof;
      ulong siglen;
      crypto_sign_detached(serverProof.ptr, &siglen,
          material.ptr, material.length, ACC_SK.ptr);

      TLVMessage[3] tRes;
      tRes[0].type = TLVTypes.identifier;
      tRes[0].value ~= cast(ubyte[]) ACC_MAC;
      tRes[1].type = TLVTypes.public_key;
      tRes[1].value = ACC_PK;
      tRes[2].type = TLVTypes.signature;
      tRes[2].value = serverProof;

      ubyte[] message = encodeTlv(tRes);

      ubyte[] encrypted;
      encrypted.length = message.length;
      ubyte[crypto_aead_chacha20poly1305_ABYTES] auth;
      ulong authlen;
      ubyte[] p5nonce = cast(ubyte[])[0, 0, 0, 0] ~ cast(ubyte[]) PAIRING_5_NONCE;

      crypto_aead_chacha20poly1305_ietf_encrypt_detached(encrypted.ptr, auth.ptr, &authlen, 
          message.ptr, message.length, null, 0,
          null, p5nonce.ptr, hap3_hkdf.ptr);

      ubyte[] enc_a = encrypted ~ auth;

      TLVMessage[2] tEnc;
      tEnc[0].type = TLVTypes.state;
      tEnc[0].value ~= TLVStates.M6;
      tEnc[1].type = TLVTypes.encrypted_data;
      tEnc[1].value = enc_a;
      //res.writeBody(encodeTlv(tEnc), "application/pairing+tlv8");
      httpServer.sendHttpResponse(client_addr, encodeTlv(tEnc), "application/pairing+tlv8");
      CLI_PUB[client_id.toHexString] = client_public.dup;
    }
  }
}

void main(string[] args) {
  writeln("hello, friend\n", args);
  string iface = "";
  if (args.length > 1) {
    iface = args[1];
  }

  auto advertiser = new DnsSD(iface);

  string txt = "";

  txt ~= "c#=2\n";
  txt ~= "md=dbridge\n";
  txt ~= "id="~ ACC_MAC ~"\n"; 
  txt ~= "pv=1.1\n";
  txt ~= "s#=1\n";
  txt ~= "sf=1\n";
  txt ~= "ci=2\n";
  txt ~= "ff=0\n";

  ushort port = 45001;

  int sidx = 
    advertiser.registerService(ACC_NAME, "_hap._tcp", "local", "friend.local", port, txt);

  StopWatch sw = StopWatch();
  sw.start();
  Duration interval = 5000.msecs;
  // http server
  httpServer = new CustomHTTP(port);
  httpServer.onHttpRequest = toDelegate(&handleHttpRequest);
  httpServer.onByteRequest = toDelegate(&handleByteRequest);

  // bridge accessory
  HAPAccessory my;
  my.aid = 1;
  my.createInfoService("bobalus", "dbridge", ACC_NAME, ACC_MAC, "1.1.5");

  HAPService hapInfo;
  hapInfo.type = "A2";
  HAPCharacteristic ver;
  ver.type = "37";
  ver.format = "string";
  ver.value = JSONValue("1.1.0");
  ver.perms = [HAPPermission.PAIRED_READ, HAPPermission.EVENTS];
  ver.description = "Version";
  hapInfo.chars ~= ver;
  my.addService(hapInfo);

  accs ~= my;

  // lightbulb
  HAPAccessory lightAcc;
  lightAcc.aid = 2;
  lightAcc.createInfoService("Default-Manufacturer", "Default-Model", "Test lamp", "Default-SerialNumber", "0.0.3");

  HAPService lservice;
  lservice.type = "43";

  HAPCharacteristic lname;
  lname.type = "23";
  lname.format = "string";
  lname.value = JSONValue("Test lamp");
  lname.perms = [HAPPermission.PAIRED_READ];
  lname.description = "Name";

  HAPCharacteristic lon;
  lon.type = "25";
  lon.format = "bool";
  lon.value = JSONValue(false);
  lon.perms = [HAPPermission.PAIRED_READ, HAPPermission.PAIRED_WRITE, HAPPermission.EVENTS];
  lon.description = "On";

  lservice.chars ~= lname;
  lservice.chars ~= lon;

  lightAcc.addService(lservice);
  accs ~= lightAcc;

  // --------------- //

  while(true) {
    advertiser.processMessages();
    Thread.sleep(1.msecs);
    Duration dur = sw.peek();
    if (dur > interval) {
      advertiser.publish(sidx);
      sw.reset();
    }
    httpServer.processSocket();
  }
}
