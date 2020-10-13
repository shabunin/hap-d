import std.conv;
import std.digest;
import std.digest.hmac;
import std.digest.sha;
import std.math;

// hkdf_ex(key, salt, info, outputlen, SHA512)

// SHA512 hash algorithm is hard-coded at this moment

ubyte[] hkdf_ex(ubyte[] key, ubyte[] salt, string info, ulong size) {

  // get hash len
  ubyte[] hashBuf = sha512Of("").dup;
  auto hashLen = hashBuf.length;

  if (salt.length == 0) {
    salt.length = hashLen;
  }

  auto phmac = HMAC!SHA512(salt);
  phmac.put(key);
  // pseudo random key
  auto prk = phmac.finish.dup;

  string prev = "";
  ubyte[] res;
  //res.length = size;

  auto num_blocks = ceil(to!float(size) / to!float(hashLen));
  for (auto i = 0; i < num_blocks; i++) {
    ubyte[] input = cast(ubyte[])(prev ~ info);
    ubyte cnt = (i + 1)&0xff;
    input ~= cnt;
    auto hmac = HMAC!SHA512(prk);
    hmac.put(input);
    prev = cast(string) hmac.finish.dup;
    res ~= cast(ubyte[]) prev;
  }

  return res[0..size].dup;
}

