module tlv;

import std.bitmanip;
import std.conv;
import std.digest;
import std.stdio;

enum TLVTypes {
  // TODO: page 51 of HAP specs
  method = 0x00,
  identifier = 0x01,
  salt = 0x02,
  public_key = 0x03,
  password_proof = 0x04,
  encrypted_data = 0x05,
  state = 0x06,
  error = 0x07,
  retry_delay = 0x08,
  certificate = 0x09,
  signature = 0x0a,
  permissions = 0x0b,
  fragment_data = 0x0c,
  fragment_last = 0x0d,
  flags = 0x13,
  separator = 0xff
}

enum TLVErrors {
  reserved = 0x00,
  unknown = 0x01,
  authentication = 0x02,
  backoff = 0x03,
  max_peers = 0x04,
  max_tries = 0x05,
  unavailable = 0x06,
  busy = 0x07
}

enum TLVMethods {
  pair_setup = 0x00,
  pair_setup_auth = 0x01,
  pair_verify = 0x02,
  add_pairing = 0x03,
  remove_pairing = 0x04,
  list_pairings = 0x05
}

enum TLVStates {
  unknown = 0x00,
  M1 = 0x01,
  M2 = 0x02,
  M3 = 0x03,
  M4 = 0x04,
  M5 = 0x05,
  M6 = 0x06
}

struct TLVMessage {
  TLVTypes type;
  int len;
  ubyte[] value;
}

TLVMessage[TLVTypes] decodeTlv(ubyte[] buffer) {
  TLVMessage[TLVTypes] result;

  while(buffer.length > 0) {
    TLVTypes type = cast(TLVTypes) buffer.read!ubyte();
    ubyte len = buffer.read!ubyte();
    if (len == 0) break;
    ubyte[] value = buffer[0..len];

    if ((type in result) is null) {
      TLVMessage msg;
      msg.type = type;
      msg.len = len;
      msg.value = value.dup;

      result[type] = msg;
    } else {
      result[type].len = result[type].len + len;
      result[type].value ~= value.dup;
    }

    if (buffer.length == len) {
      buffer = [];
    } else {
      buffer = buffer[len..$];
    }
  }

  return result;
}

ubyte[] encodeTlv(TLVMessage[] tlvs) {
  ubyte[] res;

  foreach(t; tlvs) {
    if (t.value.length <= 255) {
      res ~= cast(ubyte) t.type;
      res ~= to!ubyte(t.value.length);
      res ~= t.value;
    } else {
      auto left = t.value.length;
      auto start = 0;

      while(left > 0) {
        if (left > 255) {
          res ~= cast(ubyte) t.type;
          res ~= 0xff;
          res ~= t.value[start..start+0xff];
          start += 255; left -=255;
        } else {
          res ~= cast(ubyte) t.type;
          res ~= to!ubyte(left);
          res ~= t.value[start..$];
          left = 0;
        }
      }
    }
  }

  return res;
}
