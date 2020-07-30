import std.algorithm;
import std.bigint;
import std.bitmanip;
import std.conv;
import std.datetime.stopwatch : StopWatch;
import std.functional;
import std.digest;
import std.stdio;
import std.string;
import std.socket;

import core.thread;
import core.sys.linux.ifaddrs;
import core.sys.linux.sys.socket;
import core.sys.linux.netinet.in_: IP_ADD_MEMBERSHIP, IP_MULTICAST_LOOP;
import core.sys.posix.netdb;
import core.sys.posix.netinet.in_;

import secured;
import secured.kdf;
import secured.symmetric;

import accessories;
import http_util;
import custom_http;
import mdns_sd;
import srp_params;
import srp;
import tlv;
import ed25519;

import tweetNaCl;

CustomHTTP httpServer;
SrpServer srpServer;
TLVStates State;

enum ACC_NAME = "_hello_";
enum ACC_MAC = "01:01:01:01:01:ff";
enum ACC_PIN = "111-11-111";
ubyte[] ACC_SK, ACC_PK; // accessory secret/public key

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


ubyte[] layerEncrypt(ubyte[] data, ulong count, ubyte[] key) {
  ubyte[] result;
  size_t total = data.length;
  for (size_t offset = 0; offset < total; ) {
    ushort length = to!ushort(total - offset);
    if (length > 1024) length = 1024;

    ubyte[2] leLength = nativeToLittleEndian(length);
    ubyte[8] nonce = nativeToLittleEndian(count);

    ubyte[] message = data[offset..offset+length].dup;

    ubyte[] auth;
    ubyte[] encrypted = encrypt_ex(SymmetricAlgorithm.ChaCha20_Poly1305, 
          key, nonce, message, leLength, auth);
    offset += length;

    result ~= leLength;
    result ~= encrypted;
    result ~= auth;

  }

  return result.dup;
}

ubyte[] layerDecrypt(ubyte[] packet, ulong count, ubyte[] key) {
  if (fragment.length > 0) {
    packet = fragment ~ packet;
  }
  writeln("packet len: ", packet.length);

  ubyte[] result;
  size_t total = packet.length;

  for (size_t offset = 0; offset < total;) {
    ushort x = packet.peek!(ushort, Endian.littleEndian)(0);
    size_t realDataLength = to!size_t(x);
    writeln("realDataLen: ", realDataLength);

    auto availableDataLength = total - offset - 2 - 16;
    if (realDataLength > availableDataLength) {
      // Fragmented packet
      fragment = packet[offset..$];
      break;
    } else {
      fragment = [];
    }

    ubyte[8] nonce = nativeToLittleEndian(count);
    writeln("nonce: ", nonce);

    ubyte[] plaintext;
    ubyte[] messageData = packet[offset+2..offset+2+realDataLength].dup;
    ubyte[] authTagData = packet[offset+2+realDataLength..offset+2+realDataLength+16].dup;
    ubyte[] additional = packet[offset..offset+2].dup;
    writeln("messageData len: ", messageData.length);
    writeln("authTag len: ", authTagData.length);
    writeln("additional len: ", additional.length);
    try {
      plaintext = decrypt_ex(key , nonce, messageData, authTagData,
                    additional, SymmetricAlgorithm.ChaCha20_Poly1305); 
    } catch(Exception e) {
      writeln("Error decrypting data: ");
      writeln(e);
      //throw e;
      return result;
    }

    result ~= plaintext.dup;
    offset += (18 + realDataLength);
  }

  return result;
}


void handleByteRequest(string client_addr, ubyte[] enc_message) {
  writeln("here comes decryption...hooooray!");

  ubyte[] dec = layerDecrypt(enc_message, in_count, enc_controllerToAccessoryKey);
  in_count += 1;
  
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
    writeln("iOS requesting accessory list");
    

    string resStatus = "HTTP/1.1 200 OK";
    string[string] resHeaders; 
    resHeaders["Content-Type"] = "application/hap+json";
    
    string resBody = ACCESSORIES.dup;

    resHeaders["Content-Length"] = to!string(resBody.length);


    string response = encodeHTTP(resStatus, resHeaders, resBody);
    writeln("response: ", response);

    // attempt to send empty list
    ubyte[] enc = layerEncrypt(cast(ubyte[])response,
                    out_count, enc_accessoryToControllerKey);
    out_count += 1;
    httpServer.sendByteResponse(client_addr, enc);
  }
}

void handleHttpRequest(string client_addr, 
    string status, string[string] headers, string content) {
  writeln("hello, my friend.. http request");

  string method = status.split(" ")[0];
  string path = status.split(" ")[1];

  if (path == "/pair-verify") {
    writeln("TODO: /pair-verify");
    ubyte[] buffer = cast(ubyte[]) content;

    auto tlvReq = decodeTlv(buffer);
    writeln(tlvReq);
    auto tlvReqState = tlvReq[TLVTypes.state].value[0];
    if (tlvReqState == TLVStates.M1) {
      writeln("pair-verify step 1/2");
      ubyte[] clientPublicKey = tlvReq[TLVTypes.public_key].value;
      // generate new encryption keys for this session
      KeyPair keyPair = gen_key_pair25519();
      ubyte[] secretKey = keyPair.SK;
      ubyte[] publicKey = keyPair.PK;
      ubyte[] sharedSec = scalar_mult(secretKey, clientPublicKey);
      ubyte[] usernameData = cast(ubyte[]) ACC_MAC;
      ubyte[] material = publicKey ~ usernameData ~ clientPublicKey;
      ubyte[] privateKey = ACC_SK;
      ubyte[] serverProof = sign_detached(material, privateKey);

      string encSalt = "Pair-Verify-Encrypt-Salt";
      string encInfo = "Pair-Verify-Encrypt-Info";
      ubyte[] outputKey = hkdf_ex(sharedSec.dup, 
          cast(ubyte[])encSalt, encInfo, 32, HashAlgorithm.SHA2_512)[0..32]; 

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

      ubyte[] auth;
      ubyte[] encrypted = encrypt_ex(SymmetricAlgorithm.ChaCha20_Poly1305, 
          outputKey, cast(ubyte[])"PV-Msg02", message, [], auth);

      ubyte[] enc_a = encrypted ~ auth;

      TLVMessage[3] tEnc;
      tEnc[0].type = TLVTypes.state;
      tEnc[0].value ~= TLVStates.M2;
      tEnc[1].type = TLVTypes.encrypted_data;
      tEnc[1].value = enc_a;
      tEnc[2].type = TLVTypes.public_key;
      tEnc[2].value = publicKey;

      httpServer.sendHttpResponse(client_addr, encodeTlv(tEnc), "application/pairing+tlv8");
    } else if (tlvReqState == TLVStates.M3) {
      writeln("pair-verify step 2/2");
      ubyte[] encryptedData = tlvReq[TLVTypes.encrypted_data].value;
      ubyte[] messageData = encryptedData[0..$-16]; 
      ubyte[] authTagData = encryptedData[$-16..$];
      writeln("trying to decrypt data");
      ubyte[] plaintext;
      try {
        plaintext = decrypt_ex(enc_hkdfPairEncKey , cast(ubyte[])"PV-Msg03",
            messageData, authTagData, null, SymmetricAlgorithm.ChaCha20_Poly1305); 
      } catch(Exception e) {
        writeln("Error decrypting data: ", e.message);
        throw e;
      }
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
      bool result = verify_detached(material, proof, clientPublicKey);
      writeln("verifying result: ", result);
      if (!result) {
        throw new Exception("Wrong signature");
      }
      TLVMessage[1] tRes;
      tRes[0].type = TLVTypes.state;
      tRes[0].value ~= TLVStates.M4;
      writeln("finally paired: ", encodeTlv(tRes).toHexString);
      // send response
      httpServer.sendHttpResponse(client_addr, encodeTlv(tRes), "application/pairing+tlv8");
      // "upgrade" HTTP connection 
      httpServer.switchToEncryptedMode(client_addr);
      // save encryption keys
      string encSalt = "Control-Salt";
      string infoRead = "Control-Read-Encryption-Key";
      string infoWrite = "Control-Write-Encryption-Key";
      enc_accessoryToControllerKey = hkdf_ex(enc_sharedSec.dup, 
          cast(ubyte[])encSalt, infoRead, 32, HashAlgorithm.SHA2_512)[0..32].dup; 
      enc_controllerToAccessoryKey = hkdf_ex(enc_sharedSec.dup, 
          cast(ubyte[])encSalt, infoWrite, 32, HashAlgorithm.SHA2_512)[0..32].dup; 
      in_count = 0; out_count = 0;
    }
  } else if (path == "/pair-setup") {
    ubyte[] buffer = cast(ubyte[]) content;

    auto tlvReq = decodeTlv(buffer);
    writeln(tlvReq);

    auto tlvReqState = tlvReq[TLVTypes.state].value[0];

    if (tlvReqState == TLVStates.M1) {
      writeln("here comes _pairStepOne");
      // step one
      SrpParam srpParams = getSrpParamHap();
      ubyte[] salt = gen_key(16).dup;

      // for test purposes
      //ubyte[] salt = bi2buf(BigInt(
      //      "0xBEB25379D1A8581EB5A727673A2441EE"));

      ubyte[] key = gen_key(32).dup;

      // for test purposes
      //ubyte[] key = bi2buf(BigInt(
      //      "0xE487CB59D31AC550471E81F00F6928E01DDA08E974A004F49E61F5D105284D20"));

      ubyte[] id = cast(ubyte[])"Pair-Setup";

      // for test purposes
      //ubyte[] id = cast(ubyte[])"alice";

      ubyte[] pin = cast(ubyte[])ACC_PIN;

      // for test purposes
      //ubyte[] pin = cast(ubyte[])"password123";

      srpServer = new SrpServer(srpParams, salt, id, pin, key);
      auto srpB = srpServer.get_B();

      TLVMessage[3] tRes;
      tRes[0].type = TLVTypes.state;
      tRes[0].value ~= TLVStates.M2;
      tRes[1].type = TLVTypes.salt;
      tRes[1].value = salt;
      tRes[2].type = TLVTypes.public_key;
      tRes[2].value = srpB;

      //res.writeBody(encodeTlv(tRes), "application/pairing+tlv8");
      writeln("trying to send data");
      httpServer.sendHttpResponse(client_addr, encodeTlv(tRes), "application/pairing+tlv8");
      State = TLVStates.M2;
    } else if (tlvReqState == TLVStates.M3 && State == TLVStates.M2) {
      writeln("here should be _pairStepTwo");
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
        //res.writeBody(encodeTlv(tRes), "application/pairing+tlv8");
        httpServer.sendHttpResponse(client_addr, encodeTlv(tRes), "application/pairing+tlv8");
        State = TLVStates.unknown;
        return;
      }
      writeln("Good, client provided correct PIN.");
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
      writeln("here should be _pairStepThree");
      ubyte[] encrypted_data = tlvReq[TLVTypes.encrypted_data].value;
      ubyte[] message_data = encrypted_data[0..$-16];
      ubyte[] authtag_data = encrypted_data[$-16..$];
      ubyte[] session_key = bi2buf(srpServer.return_session_key()).dup;
      string PAIRING_3_SALT = "Pair-Setup-Encrypt-Salt";
      string PAIRING_3_INFO = "Pair-Setup-Encrypt-Info";
      string PAIRING_3_NONCE = "PS-Msg05";
      size_t OUTPUT_LEN = 32; 
      writeln("trying to decrypt data");
      ubyte[] hap3_hkdf = hkdf_ex(session_key.dup, cast(ubyte[])PAIRING_3_SALT,
          PAIRING_3_INFO, OUTPUT_LEN, HashAlgorithm.SHA2_512); 
      ubyte[] decrypted_data = decrypt_ex(hap3_hkdf, cast(ubyte[]) PAIRING_3_NONCE,
          message_data, authtag_data, null, SymmetricAlgorithm.ChaCha20_Poly1305); 
      //writeln(decodeTlv(decrypted_data));
      auto tlvData = decodeTlv(decrypted_data);
      writeln("=============");
      writeln(tlvData.keys);
      writeln("=============");
      ubyte[] client_public = tlvData[TLVTypes.public_key].value;
      ubyte[] client_sign = tlvData[TLVTypes.signature].value;
      ubyte[] client_id = tlvData[TLVTypes.identifier].value;

      // step 4/5
      // ed25519 verify
      string PAIRING_4_SALT = "Pair-Setup-Controller-Sign-Salt";
      string PAIRING_4_INFO = "Pair-Setup-Controller-Sign-Info";

      ubyte[] hap4_hkdf = hkdf_ex(session_key.dup, cast(ubyte[])PAIRING_4_SALT,
          PAIRING_4_INFO, OUTPUT_LEN, HashAlgorithm.SHA2_512); 
      ubyte[] vdata;
      vdata = hap4_hkdf ~ client_id ~ client_public;
      writeln("hkdf: ", hap4_hkdf.toHexString);
      writeln("client_id: ", client_id.toHexString);
      writeln("client_sig: ", client_sign.toHexString);
      writeln("client_pub: ", client_public.toHexString);
      writeln("vdata: ", vdata.toHexString);
      writeln("verifying: ", verify_detached(vdata, client_sign, client_public));
      // TODO: send response if error and return


      // step 5/5
      string PAIRING_5_SALT = "Pair-Setup-Accessory-Sign-Salt";
      string PAIRING_5_INFO = "Pair-Setup-Accessory-Sign-Info";
      string PAIRING_5_NONCE = "PS-Msg06";
      ubyte[] hap5_hkdf = hkdf_ex(session_key.dup, cast(ubyte[])PAIRING_5_SALT,
          PAIRING_5_INFO, OUTPUT_LEN, HashAlgorithm.SHA2_512); 

      /*
         var serverLTPK = this.accessoryInfo.signPk;
         var usernameData = Buffer.from(this.accessoryInfo.username);
         var material = Buffer.concat([outputKey, usernameData, serverLTPK]);
         var privateKey = Buffer.from(this.accessoryInfo.signSk);
         var serverProof = tweetnacl.sign.detached(material, privateKey);
         var message = tlv.encode(TLVValues.USERNAME, usernameData, TLVValues.PUBLIC_KEY, serverLTPK, TLVValues.PROOF, serverProof);

       */

      KeyPair keyPair = gen_key_pair();
      ACC_SK = keyPair.SK;
      ACC_PK = keyPair.PK;

      ubyte[] material = hap5_hkdf.dup;
      material ~= cast(ubyte[]) ACC_MAC.dup;
      material ~= ACC_PK.dup;
      ubyte[] serverProof = sign_detached(material, ACC_SK);

      TLVMessage[3] tRes;
      tRes[0].type = TLVTypes.identifier;
      tRes[0].value ~= cast(ubyte[]) ACC_MAC;
      tRes[1].type = TLVTypes.public_key;
      tRes[1].value = ACC_PK;
      tRes[2].type = TLVTypes.signature;
      tRes[2].value = serverProof;

      ubyte[] message = encodeTlv(tRes);

      // encrypt_ex(SymmetricAlgorithm algorithm, const ubyte[] key, const ubyte[] iv, const ubyte[] data, const ubyte[] additional, out ubyte[] auth) {
      ubyte[] auth;
      ubyte[] encrypted = encrypt_ex(SymmetricAlgorithm.ChaCha20_Poly1305, 
          hap3_hkdf, cast(ubyte[])PAIRING_5_NONCE, message, [], auth);

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

    txt ~= "c#=1\n";
    txt ~= "md=bugaga\n";
    txt ~= "id="~ ACC_MAC ~"\n"; 
    txt ~= "pv=1.0\n";
    txt ~= "s#=1\n";
    txt ~= "sf=1\n";
    txt ~= "ci=2\n";

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
