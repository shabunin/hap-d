// from lighttp project
module http_util;

import std.array : Appender;
import std.string : split, join, strip, indexOf;


private enum crlf = "\r\n";

public string encodeHTTP(string status, string[string] headers, string content) {
  Appender!string ret;
  ret.put(status);
  ret.put(crlf);
  foreach(k, v ; headers) {
    ret.put(k);
    ret.put(": ");
    ret.put(v);
    ret.put(crlf);
  }
  ret.put(crlf); // empty line
  ret.put(content);
  return ret.data;
}

public bool decodeHTTP(string str, ref string status, ref string[string] headers, ref string content) {
  string[] spl = str.split(crlf);
  if(spl.length > 1) {
    status = spl[0];
    size_t index;
    while(++index < spl.length && spl[index].length) { // read until empty line
      auto s = spl[index].split(":");
      if(s.length >= 2) {
        headers[s[0].strip] = s[1..$].join(":").strip;
      } else {
        return false; // invalid header
      }
    }
    content = (index + 1 < spl.length) ? join(spl[index + 1..$], crlf) : string.init;
    return true;
  } else {
    return false;
  }
}
