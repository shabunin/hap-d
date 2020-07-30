/**
  hello, friend
  
  This us port of following python file to D:
  https://github.com/ikalchev/HAP-python/blob/dev/pyhap/hsrp.py
  
  More complex implementation:
  https://github.com/homebridge/fast-srp/blob/master/src/srp.ts
  
**/ 

module srp;

import std.algorithm;
import std.array: array;
import std.bigint;
import std.conv;
import std.digest;
import std.digest.sha;
import std.random: MinstdRand, uniform;
import std.range;
import std.stdio;
import std.string;

import srp_params;

ubyte[] gen_key(int size) {
  auto rnd = MinstdRand(142);

  ubyte[] arr;
  arr.length = size;
  for (int i = 0; i < size; i += 1) {
    arr[i] = rnd.uniform!ubyte();
  }
  return arr;
}
  
BigInt buf2bi(ubyte[] buf) {
    return BigInt("0x" ~ buf.toHexString);
}
ubyte[] bi2buf(BigInt num) {
        string hexStr = num.toHex.replace("_", "");
        if (hexStr.length % 2 != 0) {
            hexStr = "0" ~ hexStr;
        }
        return hexStr
                 .chunks(2)
                 .map!(d => d.to!ubyte(16))
                 .array;
}
ubyte[] padTo(ubyte[] n, int len) {
  auto padding = len - n.length;
  if (padding < 0) return n;
  ubyte[] result; result.length = padding;
  result ~= n;
  
  return result;
}
ubyte[] padTo(BigInt n, int len) {
    return padTo(bi2buf(n), len);
}
ubyte[] padToN(BigInt number, SrpParam params) {
  return padTo(number, params.N_length_bits/8);
}
ubyte[] padToN(ubyte[] number, SrpParam params) {
  return padTo(number, params.N_length_bits/8);
}

BigInt get_x(SrpParam params, ubyte[] salt, ubyte[] I, ubyte[] P) {
  SHA512 sha;
  sha.start();
  sha.put(I ~ cast(ubyte)':' ~ P);
  ubyte[] hashIP = sha.finish.dup;
  
  sha.start();
  sha.put(salt);
  sha.put(hashIP);
  ubyte[] hashX = sha.finish.dup;
  
  return buf2bi(hashX);
}

BigInt get_verifier(SrpParam params, ubyte[] salt, ubyte[] I, ubyte[] P) {
    BigInt x = get_x(params, salt, I, P);
    return powmod(params.g, x, params.N);
}

BigInt get_k(SrpParam params) {
    SHA512 sha;
    sha.start();
    sha.put(padToN(params.N, params));
    sha.put(padToN(params.g, params));
    ubyte[] hashK = sha.finish.dup;
    
    return buf2bi(hashK);
}

BigInt get_session_key(SrpParam params, BigInt S) {
    SHA512 sha;
    sha.start();
    sha.put(bi2buf(S));
    ubyte[] hashS = sha.finish.dup;
    
    return buf2bi(hashS);
}

class SrpServer {
  private SrpParam _params;
  private ubyte[] _I; // identity buffer
  private ubyte[] _P; // password buffer
  private ubyte[] _s; // salt buffer
  private BigInt _k;  // multiplier param
  private BigInt _b;  // server priv key
  private BigInt _B; // server public key
  private BigInt _v;  // verifier
  private BigInt _K; // session key

  private BigInt _A; // client pubkey
  private ubyte[] _M;
  private ubyte[] _HAMK;

  private BigInt _u; // random scrambling param
  private BigInt _S; // premaster secret

  this(SrpParam params, ubyte[] salt, ubyte[] identity, ubyte[] password, ubyte[] secret) {
    _params = params;
    _s = salt.dup;
    _I = identity.dup;
    _P = password.dup;
    _b = buf2bi(secret);
    
    _v = get_verifier(_params, _s, _I, _P);
    _k = get_k(_params);
    _B = derive_B();
  
  }
  private BigInt derive_B() {
    return (_k*_v + powmod(_params.g, _b, _params.N)) % _params.N;
  }
  
  public void set_A(ubyte[] A) {
    _A = buf2bi(A);
    _S = derive_premaster_secret();
    _K = get_session_key(_params, _S);
    _M = get_M();
  }
  
  // get_challenge??
  
  private BigInt derive_premaster_secret() {
    SHA512 sha;
    sha.start();
    sha.put(padToN(_A, _params));
    sha.put(padToN(_B, _params));
    ubyte[] hashU = sha.finish.dup;
    
    BigInt U = buf2bi(hashU);
    BigInt Avu = _A*powmod(_v, U, _params.N);
    return powmod(Avu, _b, _params.N);
  }
  
  private ubyte[] get_M() {
    SHA512 sha;
    sha.start();
    sha.put(bi2buf(_params.N));
    ubyte[] hN = sha.finish.dup;
    sha.start();
    sha.put(bi2buf(_params.g));
    ubyte[] hG = sha.finish.dup;
    ubyte[] hGroup; hGroup.length = hN.length;
    for (int i = 0; i < hGroup.length; i += 1) {
        hGroup[i] = hN[i] ^ hG[i];
    }
    
    sha.start();
    sha.put(_I);
    ubyte[] hI = sha.finish.dup;
    
    sha.start();
    sha.put(hGroup);
    sha.put(hI);
    sha.put(_s);
    sha.put(bi2buf(_A));
    sha.put(bi2buf(_B));
    sha.put(bi2buf(_K));
    
    return sha.finish.dup;
  }
  
  public ubyte[] verify(ubyte[] M) {
    if (!equal(_M, M)) {
        throw new Exception("Client M and server M not equal.");
    }
    _HAMK = get_HAMK();
    return _HAMK;
  }
  
  private ubyte[] get_HAMK() {
    SHA512 sha;
    sha.put(bi2buf(_A));
    sha.put(_M);
    sha.put(bi2buf(_K));
    
    return sha.finish.dup;
  }
  public ubyte[] get_B() {
    return bi2buf(_B);
  }
  public BigInt return_session_key() {
    return _K;
  }
}
