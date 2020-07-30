import tweetNaCl;

/***
  -- from tweetnacl.js --
  nacl.sign.detached.verify = function(msg, sig, publicKey) {
  if (sig.length !== crypto_sign_BYTES)
  throw new Error('bad signature size');
  if (publicKey.length !== crypto_sign_PUBLICKEYBYTES)
  throw new Error('bad public key size');
  var sm = new Uint8Array(crypto_sign_BYTES + msg.length);
  var m = new Uint8Array(crypto_sign_BYTES + msg.length);
  var i;
  for (i = 0; i < crypto_sign_BYTES; i++) sm[i] = sig[i];
  for (i = 0; i < msg.length; i++) sm[i+crypto_sign_BYTES] = msg[i];
  return (crypto_sign_open(m, sm, sm.length, publicKey) >= 0);
  };


 ***/

bool verify_detached(ubyte[] msg, ubyte[] sig, ubyte[] pk) {
  ubyte[] sm; //sm.length = sig.length + msg.length;
  sm ~= sig;
  sm ~= msg;
  ubyte[] m; m.length  = sm.length;

  return crypto_sign_open(m, sm, pk);
}

struct KeyPair{
  ubyte[] PK;
  ubyte[] SK;
}

KeyPair gen_key_pair() {
  ubyte[] pk; pk.length = crypto_sign_PUBLICKEYBYTES;
  ubyte[] sk; sk.length = crypto_sign_SECRETKEYBYTES;
  crypto_sign_keypair(pk, sk);
  KeyPair kp;
  kp.PK = pk.dup;
  kp.SK = sk.dup;

  return kp;
}

KeyPair gen_key_pair25519() {
  ubyte[] pk; pk.length = crypto_box_PUBLICKEYBYTES;
  ubyte[] sk; sk.length = crypto_box_SECRETKEYBYTES;
  crypto_box_keypair(pk, sk);
  KeyPair kp;
  kp.PK = pk.dup;
  kp.SK = sk.dup;

  return kp;
}
ubyte[] scalar_mult(ubyte[] n, ubyte[] p) {
  ubyte[crypto_scalarmult_BYTES] q;
  crypto_scalarmult (q, n, p);
  return q.dup;
}

ubyte[] sign_detached(ubyte[] msg, ubyte[] sk) {
  if (sk.length != crypto_sign_SECRETKEYBYTES) {
    throw new Exception("bad secret key size");
  }
  ubyte[] sm; sm.length = crypto_sign_BYTES + msg.length;
  crypto_sign(sm, msg, sk);
  
  return sm[0..crypto_sign_BYTES].dup;
}
