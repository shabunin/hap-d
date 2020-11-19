module dns;

import std.base64;
import std.bitmanip;
import std.conv;
import std.stdio;
import std.string;
import std.exception : assumeUnique;

struct RData {
  string data;
  // for srv
  ushort priority;
  ushort weight;
  ushort port;
}

enum RecordClasses {
  unknown = 0,
  int_ = 1,
  cs = 2,
  ch = 3,
  hs = 4
};

enum RecordTypes {
  unknown = 0,
  a = 1,
  ns = 2,
  md = 3,
  mf = 4,
  cname = 5,
  soa = 6,
  mb = 7,
  mg = 8,
  mr = 9,
  null_ = 10,
  wks = 11,
  ptr = 12,
  hinfo = 13,
  minfo = 14,
  mx = 15,
  txt = 16,
  aaaa = 28,
  afsdb = 18,
  apl = 42,
  caa = 257,
  cdnskey = 60,
  cds = 59,
  cert = 37,
  dhcid = 49,
  dlv = 32769,
  dname = 39,
  dnskey = 48,
  ds = 43,
  hip = 55,
  ipseckey = 45,
  key = 25,
  kx = 36,
  loc = 29,
  naptr = 35,
  nsec = 47,
  nsec3 = 50,
  nsec3param = 51,
  openpgpkey = 61,
  rrsig = 46,
  rp = 17,
  sig = 24,
  srv = 33,
  sshfp = 44,
  ta = 32768,
  tkey = 249,
  tlsa = 52,
  tsig = 250,
  uri = 256,
  opt = 41,
  any = 255
};

struct RecordLabel {
  bool valid;
  ushort length;
  string domain_name;
}

struct RecordQuestion {
  string label;
  RecordTypes record_type;
  RecordClasses record_class;
}

// answers, authorities, additionals
struct RecordResponse {
  string label;
  RecordTypes record_type;
  RecordClasses record_class;
  ushort flash;
  uint ttl;
  ushort rdlen; 
  RData rdata;
}

struct RecordHeader {
  ushort id;

  //  == flags ==
  bool response;
  ubyte opcode;
  bool authoritative;
  bool truncated;
  bool recdesired;
  bool recavail;
  bool z;
  bool authenticated;
  bool checkdisable;
  ubyte rcode;

  ushort questions;
  ushort answers;
  ushort authorities;
  ushort additionals;
}

struct Record {
  bool valid;
  RecordHeader header;
  RecordQuestion[] questions;
  RecordResponse[] answers;
  RecordResponse[] authorities;
  RecordResponse[] additionals;
}

// parse labels
RecordLabel parseLabel(ubyte[] buf, int offset) {
  string[] labels;
  // length of bytes
  ushort length = 0;
  bool valid = true;
  while(true) {
    auto label_len = buf.peek!ubyte(offset + length);
    if ((label_len & 0b11000000) == 0b11000000) {
      // compression rfc1035 4.1.4
      auto i = buf.peek!ushort(offset + length) & 0b0011111111111111;
      // recursion
      auto parsed = parseLabel(buf, i);
      if (parsed.valid) {
        labels ~= parsed.domain_name;
        length += 2;
        break;
      } else {
        valid = false;
        break;
      }
    } else if ((label_len & 0b11000000) == 0b00000000) {
      length += 1;
      if (label_len == 0x00) {
        break;
      } else if (offset + length + label_len <= buf.length) {
        auto label = cast(string) buf[offset + length..offset+length+label_len];
        labels ~= label;
        length += label_len;
      } else {
        valid = false;
        break;
      }
    } else {
      valid = false;
      break;
    }
  }

  string domain_name;
  domain_name = "".dup;
  for (auto j = 0, m = labels.length; j < m; j += 1) {
    if (j > 0) {
      domain_name ~= ".";
    }
    domain_name ~= labels[j];
  }

  RecordLabel result;
  result.valid = valid;
  result.length = length;
  result.domain_name = domain_name;

  return result;
}

ubyte[] serializeLabel(string label) {
  ubyte[] result;
  // without compression
  // for all domain_name.split("."):
  //   write label len to buf
  //   write label to buf
  // end for
  // write null as a len to indicate ending
  // return result
  auto labels = label.split(".");
  for(auto i = 0; i < labels.length; i += 1) {
    auto lbl = labels[i];
    auto len = lbl.length;
    if (len > 0b00111111) {
      // excessive length of domain name
      result.length = 0;
      return result;
    }

    result ~= to!ubyte(len);
    result ~= cast(ubyte[]) lbl;
  }
  result ~= 0x00;

  return result;
}
ubyte[] serializeLabel(RecordLabel label) {
  return serializeLabel(label.domain_name);
}

RData parseRdataA(ubyte[] buf, int offset, int len) {
  RData result;
  result.data = "".dup;
  for (int i = 0; i < len; i += 1) {
    ubyte octet = buf.peek!ubyte(offset + i);
    result.data ~= to!string(octet, 10);
    if(i != len - 1) {
      result.data ~= ".";
    }
  }
  return result;
}

ubyte[] serializeRdataA(RData rdata) {
  ubyte[] result;
  auto arr = rdata.data.split(".");
  result.length = arr.length;
  for(int i =0; i < arr.length; i += 1) {
    result[i] = to!ubyte(arr[i], 10);
  }
  return result;
}

RData parseRdataAAAA(ubyte[] buf, int offset, int len) {
  RData result;
  result.data = "".dup;
  for (int i = 0; i < len; i += 2) {
    ushort octet = buf.peek!ushort(offset + i);
    result.data ~= to!string(octet, 16);
    if(i != len - 2) {
      result.data ~= ":";
    }
  }
  return result;
}

ubyte[] serializeRdataAAAA(RData rdata) {
  ubyte[] result;
  auto arr = rdata.data.split(":");
  result.length = arr.length*2;
  for(int i =0; i < arr.length; i += 2) {
    result.write!ushort(to!ushort(arr[i], 16), i);
  }
  return result;
}

RData parseRdataPtr(ubyte[] buf, int offset, int len) {
  RData result;
  RecordLabel parsed = parseLabel(buf, offset);
  if (parsed.valid) {
    result.data = parsed.domain_name;
  }

  return result;
}
ubyte[] serializeRdataPtr(RData rdata) {
  ubyte[] result;
  result = serializeLabel(rdata.data);

  return result;
}

RData parseRdataTxt(ubyte[] buf, int offset, int len) {
  RData result;
  result.data = "".dup;

  int i = 0;
  while (i < len) {
    ubyte blen = buf.peek!ubyte(offset + i);
    i += 1;
    if (i + blen <= len) {
      string pair = cast(string) buf[offset + i..offset + i + blen];
      result.data ~= pair;
      result.data ~= "\n";
      i += blen;
    } else {
      break;
    }
  }
  return result;
}
ubyte[] serializeRdataTxt(RData rdata) {
  ubyte[] result;

  auto arr = rdata.data.split("\n");

  for (int i = 0; i < arr.length; i += 1) {
    result ~= to!ubyte(arr[i].length);
    result ~= cast(ubyte[])arr[i];
  }

  return result;
}

RData parseRdataSrv(ubyte[] buf, int offset, int len) {
  RData result;
  if (len <= 6) {
    return result;
  }
  string target = "".dup;
  RecordLabel parsed = parseLabel(buf, offset + 6);
  if (parsed.valid) {
    target = cast(string) parsed.domain_name;
  }
  ushort priority = buf.peek!ushort(offset);
  ushort weight = buf.peek!ushort(offset + 2);
  ushort port = buf.peek!ushort(offset + 4);
  result.data = target;
  result.priority = priority;
  result.weight = weight;
  result.port = port;

  return result;
}
ubyte[] serializeRdataSrv(RData rdata) {
  ubyte[] result;
  result.length = 6;

  int offset = 0;
  result.write!ushort(rdata.priority, offset); offset += 2;
  result.write!ushort(rdata.weight, offset); offset += 2;
  result.write!ushort(rdata.port, offset); offset += 2;

  result ~= serializeLabel(rdata.data);

  return result;
}

RData parseRdataOther(ubyte[] buf, int offset, int len) {
  RData result;
  result.data = Base64.encode(buf[offset..offset + len]);

  return result;
}
ubyte[] serializeRdataOther(RData rdata) {
  ubyte[] result;
  result = Base64.decode(rdata.data);

  return result;
}

Record parseRR(ubyte[] buf) {
  Record result;
  if (buf.length <= 12) {
    return result;
  }
  RecordHeader header;
  header.id = buf.peek!ushort(0);

  /// ==== flags ====
  ubyte ub = buf.peek!ubyte(2);
  // query-response. 
  header.response = to!bool((ub & 0b10000000) >> 7);
  // opcode, standard query, etc
  header.opcode = (ub & 0b01111000) >> 3;
  // authoritative
  header.authoritative = to!bool((ub & 0b00000100) >> 2);
  // truncated
  header.truncated = to!bool((ub & 0b00000010) >> 1);
  // recursion desired
  header.recdesired = to!bool((ub & 0b00000001) >> 0);

  ub = buf.peek!ubyte(3);
  // recursion available
  header.recavail = to!bool((ub & 0b10000000) >> 7);
  // rezerved
  header.z  = to!bool((ub & 0b01000000) >> 6);
  // answer authenticated
  header.authenticated = to!bool((ub & 0b00100000) >> 5);
  // check disable
  header.checkdisable = to!bool((ub & 0b00010000) >> 4);
  // reply code, 0b0000 - no error
  header.rcode = (ub & 0b00001111) >> 0;
  // ==== flags ==== 

  header.questions = buf.peek!ushort(4);
  header.answers = buf.peek!ushort(6);
  header.authorities = buf.peek!ushort(8);
  header.additionals = buf.peek!ushort(10);

  if (header.truncated ||
      header.recdesired ||
      header.recavail ||
      header.z ||
      header.authenticated ||
      header.checkdisable ||
      header.rcode != 0) {
    // null value
    return result;
  }

  result.header = header;
  /***
    result.questions.length = header.questions;
    result.answers.length = header.answers;
    result.authorities.length = header.authorities;
    result.additionals.length = header.additionals;
   **/

  auto sum = header.questions;
  sum += header.answers;
  sum += header.authorities;
  sum += header.additionals;
  if (sum == 0) {
    // no payload?
    return result;
  }

  // ref0rma:
  // hell0, fr1nd
  auto offset = 12;
  auto current_record_item = 0;
  auto total_record_items = 
    header.questions + header.answers + header.authorities + header.additionals;
  // indexes for pushing to result array
  auto questions_left = header.questions;
  auto answers_left = header.answers;
  auto authorities_left = header.authorities;
  auto additionals_left = header.additionals;

  while(current_record_item < total_record_items) {
    auto parsed = parseLabel(buf, offset);
    if (parsed.valid) {
      offset += parsed.length;
    } else {
      //invalid = true;
      break;
    }

    if (questions_left > 0) {
      if (offset + 4 > buf.length) {
        break;
      }
      ushort record_type = buf.peek!ushort(offset);
      offset += 2;
      ushort record_class = buf.peek!ushort(offset);
      offset += 2;
      RecordQuestion question;
      question.label = parsed.domain_name;
      question.record_type = cast(RecordTypes) record_type;
      question.record_class = cast(RecordClasses) record_class;
      result.questions ~= question;
      questions_left -= 1;
    } else {
      if (offset + 10 > buf.length) {
        break;
      }
      ushort record_type = buf.peek!ushort(offset);
      offset += 2;
      ushort cls_value = buf.peek!ushort(offset);
      ushort cls_key = cls_value & 0b0111111111111111;

      ushort flash = cls_value & 0b1000000000000000 >> 15;
      offset += 2;
      auto ttl = buf.peek!uint(offset);
      offset += 4;
      auto rdlen = buf.peek!ushort(offset);
      offset += 2;
      if (offset + rdlen > buf.length) {
        break;
      }
      RecordResponse response;
      response.label = parsed.domain_name;
      response.record_type = cast(RecordTypes) record_type;
      response.record_class = cast(RecordClasses) cls_key;
      response.flash = flash;
      response.ttl = ttl;
      response.rdlen = rdlen;
      switch(record_type) {
        case RecordTypes.a:
          response.rdata = parseRdataA(buf, offset, rdlen);
          break;
        case RecordTypes.ptr:
          response.rdata = parseRdataPtr(buf, offset, rdlen);
          break;
        case RecordTypes.txt:
          response.rdata = parseRdataTxt(buf, offset, rdlen);
          break;
        case RecordTypes.srv:
          response.rdata = parseRdataSrv(buf, offset, rdlen);
          break;
        default:
          response.rdata = parseRdataOther(buf, offset, rdlen);
          break;
      }
      offset += rdlen;

      if (answers_left > 0) {
        result.answers ~= response;
        answers_left -= 1;
      } else if (authorities_left > 0) {
        result.authorities ~= response;
        authorities_left -= 1;
      } else if (additionals_left > 0) {
        result.additionals ~= response;
        additionals_left -= 1;
      }
    }

    current_record_item += 1;
  }

  result.valid = true;
  return result;
}

ubyte[] serializeRR(Record rec) {
  auto header = rec.header;
  ubyte[] buf;
  buf.length = 12;
  int offset = 0;

  buf.write!ushort(header.id, offset); offset += 2;

  /// ==== flags ====
  ubyte ub1, ub2;
  ub1 = to!ubyte((to!ubyte(header.response) << 7) | ub1);
  // opcode, standard query, etc
  ub1 = to!ubyte(((header.opcode & 0b1111) << 3) | ub1);
  // authoritative
  ub1 = to!ubyte((to!ubyte(header.authoritative) << 2) | ub1);
  // truncated
  ub1 = to!ubyte((to!ubyte(header.truncated) << 1) | ub1);
  // recursion desired
  ub1 = to!ubyte((to!ubyte(header.recdesired) << 0) | ub1);

  // recursion available
  ub2 = to!ubyte((to!ubyte(header.recavail) << 7) | ub2);
  // rezerved
  ub2 = to!ubyte((to!ubyte(header.z) << 6) | ub2);
  // answer authenticated
  ub2 = to!ubyte((to!ubyte(header.authenticated) << 5) | ub2);
  // check disable
  ub2 = to!ubyte((to!ubyte(header.checkdisable) << 4) | ub2);
  // reply code, 0b0000 - no error
  ub2 = to!ubyte(((header.rcode & 0b1111) << 0) | ub2);
  // ==== flags ==== 
  buf.write!ubyte(ub1, offset); offset += 1;
  buf.write!ubyte(ub2, offset); offset += 1;

  buf.write!ushort(header.questions, offset); offset += 2;
  buf.write!ushort(header.answers, offset); offset += 2;
  buf.write!ushort(header.authorities, offset); offset += 2;
  buf.write!ushort(header.additionals, offset); offset += 2;

  auto current_record_item = 0;
  auto total_record_items = 
    header.questions + header.answers + header.authorities + header.additionals;
  // indexes for pushing to result array
  auto questions_left = header.questions;
  auto answers_left = header.answers;
  auto authorities_left = header.authorities;
  auto additionals_left = header.additionals;

  while(current_record_item < total_record_items) {
    if (questions_left > 0) {
      auto question = rec.questions[header.questions - questions_left];
      buf ~= serializeLabel(question.label);
      offset = to!int(buf.length);
      buf.length += 4;
      buf.write!ushort(cast(ushort) question.record_type, offset); offset += 2;
      buf.write!ushort(cast(ushort) question.record_class, offset); offset += 2;

      questions_left -= 1;
    } else{
      RecordResponse rr;
      if (answers_left > 0) {
        rr = rec.answers[header.answers - answers_left];
        answers_left -= 1;
      } else if (authorities_left > 0) {
        rr = rec.authorities[header.authorities - authorities_left];
        authorities_left -= 1;
      } else if (additionals_left > 0) {
        rr = rec.additionals[header.additionals - additionals_left];
        additionals_left -= 1;
      }

      buf ~= serializeLabel(rr.label);
      offset = to!int(buf.length);
      buf.length += 10;
      buf.write!ushort(cast(ushort) rr.record_type, offset); offset += 2;
      ushort cls_value = to!ushort((cast(ushort) rr.record_class) | (rr.flash << 15));
      buf.write!ushort(cls_value, offset); offset += 2;
      buf.write!uint(rr.ttl, offset); offset += 4;

      ubyte[] urdata;
      switch(rr.record_type) {
        case RecordTypes.a:
          urdata = serializeRdataA(rr.rdata);
          break;
        case RecordTypes.ptr:
          urdata = serializeRdataPtr(rr.rdata);
          break;
        case RecordTypes.txt:
          urdata = serializeRdataTxt(rr.rdata);
          break;
        case RecordTypes.srv:
          urdata = serializeRdataSrv(rr.rdata);
          break;
        default:
          urdata = serializeRdataOther(rr.rdata);
          break;
      }
      rr.rdlen = to!ushort(urdata.length);
      buf.write!ushort(rr.rdlen, offset); offset += 2;

      buf ~= urdata;
    }
    current_record_item += 1;
  }

  return buf;
}
