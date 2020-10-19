module hap_server;

import std.algorithm;
import std.bigint;
import std.bitmanip;
import std.conv;
import std.datetime.stopwatch;
import std.functional;
import std.digest;
import std.json;
import std.stdio;
import std.string;
import std.socket;

//import core.thread;

import libsodium;

import accessories;
import custom_http;
import hkdf;
import mdns_sd;
import srp_params;
import srp;
import tlv;

class HAPServer {
  private DnsSD advertiser;
  private string[string] txt;
  private int serviceIndex;	
  private StopWatch sw;
  private Duration interval = 5000.msecs;

  private CustomHTTP httpServer;
  private SrpServer srpServer;
  private TLVStates State;

  private HAPAccessory[] accs;

  private string acc_pin;
  private string acc_id;

  private ubyte[crypto_sign_PUBLICKEYBYTES] ACC_PK;
  private ubyte[crypto_sign_SECRETKEYBYTES] ACC_SK;

  private ubyte[] iOS_PK;
  private ubyte[] iOS_ID;

  private ubyte[] enc_clientPublicKey,
          enc_secretKey,
          enc_publicKey,
          enc_sharedSec,
          enc_hkdfPairEncKey,
          enc_accessoryToControllerKey,
          enc_controllerToAccessoryKey;

  private ubyte[] fragment;
  private ulong in_count, out_count;
  private ubyte[][string] CLI_PUB;

  public void delegate(ubyte[], ubyte[], ubyte[], ubyte[]) onPair;

  public void setPairInfo(ubyte[] acc_pk, ubyte[] acc_sk, ubyte[] ios_pk, ubyte[] ios_id) {
    ACC_PK = acc_pk.dup;
    ACC_SK = acc_sk.dup;
    iOS_PK = ios_pk.dup;
    iOS_ID = ios_id.dup;
    CLI_PUB[iOS_ID.toHexString] = iOS_PK.dup;
    txt["sf"] = "0";
    advertiser.setTxtRecord(serviceIndex, txt);
  };

  private ubyte[] layerEncrypt(ubyte[] data, ref ulong count, ubyte[] key) {
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

  private ubyte[] layerDecrypt(ubyte[] packet, ref ubyte[] fragment, ref ulong count, ubyte[] key) {
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


  private void handleByteRequest(string client_addr, ubyte[] enc_message) {
    ubyte[] dec = layerDecrypt(enc_message, fragment, in_count, enc_controllerToAccessoryKey);

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
            if (c.onGet !is null) {
              j["characteristics"].array[0]["value"] = c.onGet();
            } else {
              j["characteristics"].array[0]["value"] = c.value;
            }
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
      JSONValue jres = parseJSON("{}");
      jres["characteristics"] = parseJSON("[]");
      foreach(jc; j["characteristics"].array) {
        uint aid = to!uint(jc["aid"].integer);
        uint iid = to!uint(jc["iid"].integer);
        if (("ev" in jc)) {
          // don't support notifications for a moment
          // TODO implement support
          JSONValue jr = parseJSON("{}");
          jr["aid"] = JSONValue(aid);
          jr["iid"] = JSONValue(iid);
          jr["status"] = JSONValue(-70406);
          jres["characteristics"].array ~= jr;
          continue;
        }
        if (("value" in jc) is null) continue;
        JSONValue jv = jc["value"];
        for(auto a = 0; a < accs.length; a += 1) {
          if (accs[a].aid != aid) continue;
          for (auto s = 0; s < accs[a].services.length; s += 1) {
            for(auto c = 0; c < accs[a].services[s].chars.length; c += 1) {
              if (accs[a].services[s].chars[c].iid != iid) continue;
              if (accs[a].services[s].chars[c].onSet !is null) {
                accs[a].services[s].chars[c].onSet(jv);
                JSONValue jr = parseJSON("{}");
                jr["aid"] = JSONValue(aid);
                jr["iid"] = JSONValue(iid);
                jr["status"] = JSONValue(0);
                jr["value"] = jv;
                jres["characteristics"].array ~= jr;
              } else {
                JSONValue jr = parseJSON("{}");
                jr["aid"] = JSONValue(aid);
                jr["iid"] = JSONValue(iid);
                jr["status"] = JSONValue(-70402);
                jres["characteristics"].array ~= jr;	
              }
            }
          }
        }
      }
      string resStatus = "HTTP/1.1 207 Multi-Status";
      string resBody = jres.toJSON;
      string[string] resHeaders; 
      resHeaders["Content-Type"] = "application/hap+json";
      resHeaders["Content-Length"] = to!string(resBody.length);

      string response = encodeHTTP(resStatus, resHeaders, resBody);
      writeln("Sending response: ", response);
      ubyte[] enc = layerEncrypt(cast(ubyte[])response,
          out_count, enc_accessoryToControllerKey);
      httpServer.sendByteResponse(client_addr, enc);
    }
  }

  private void handleHttpRequest(string client_addr, 
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
        ubyte[] usernameData = cast(ubyte[]) acc_id;
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
        writeln("client_username: ", clientUsername.toHexString);
        writeln("saved ios_id:    ", iOS_ID.toHexString);
        ubyte[] proof = decoded[TLVTypes.signature].value;
        ubyte[] material = 
          enc_clientPublicKey ~ clientUsername ~ enc_publicKey;

        if ((clientUsername.toHexString in CLI_PUB) is null) {
          throw new Exception("Client want to verify, but not paired; rejecting: ");
        }
        ubyte[] clientPublicKey = CLI_PUB[clientUsername.toHexString];
        // verify material proof clientPublicKey
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
        // change txt record
        txt["sf"] = "0";
        advertiser.setTxtRecord(serviceIndex, txt);

        // call onPair callback
        // to save keys
        if (onPair !is null) {
          onPair(ACC_PK, ACC_SK, iOS_PK, iOS_ID);
        }
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

        ubyte[] pin = cast(ubyte[])acc_pin;

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
        if (!result) return;

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
        material ~= cast(ubyte[]) acc_id.dup;
        material ~= ACC_PK.dup;
        ubyte[crypto_sign_BYTES] serverProof;
        ulong siglen;
        crypto_sign_detached(serverProof.ptr, &siglen,
            material.ptr, material.length, ACC_SK.ptr);

        TLVMessage[3] tRes;
        tRes[0].type = TLVTypes.identifier;
        tRes[0].value ~= cast(ubyte[]) acc_id;
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

        // save iOS_LTPK and ID 
        iOS_PK = client_public.dup;
        iOS_ID = client_id.dup;
      }
    }
  }
  this(string iface, string acc_name, string service,
      string domain, ushort port, string acc_model, string acc_id, string acc_pin) {

    this.acc_id = acc_id;
    this.acc_pin = acc_pin;
    advertiser = new DnsSD(iface);
    txt["c#"] = "1"; // configuration number. 
    txt["md"] = acc_model;
    txt["id"] = acc_id; 
    txt["pv"] = "1.1";
    txt["s#"] = "1";
    txt["sf"] = "1"; // 1 - not paired yet
    txt["ci"] = "2"; // 2 - bridges
    string hostname = acc_name ~ "." ~ domain;
    serviceIndex = 
      advertiser.registerService(acc_name, service, domain, hostname, port, txt);
    // http server
    httpServer = new CustomHTTP(port);
    httpServer.onHttpRequest = toDelegate(&handleHttpRequest);
    httpServer.onByteRequest = toDelegate(&handleByteRequest);

    // bridge accessory
    HAPAccessory bridge;
    HAPService bridgeInfo = 
      bridge.createInfoService("hap-d", acc_model, acc_name, acc_id, "0.0.1");
    bridge.addService(bridgeInfo);

    HAPService hapInfo = HAPS_HapProtocolInfo;
    HAPCharacteristic ver = HAPC_Version("1.1.0");
    hapInfo.addCharacteristic(ver);
    bridge.addService(hapInfo);

    addAccessory(bridge);

    // stopwatch for mdns advertiser
    sw = StopWatch();
    sw.start();
  }
  public void addAccessory(HAPAccessory acc) {
    acc.aid = to!uint(accs.length + 1);
    accs ~= acc;
  }
  public void loop() {
    advertiser.processMessages();
    Duration dur = sw.peek();
    if (dur > interval) {
      advertiser.publish(serviceIndex);
      sw.reset();
    }
    httpServer.processSocket();
  }
}

