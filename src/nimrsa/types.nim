import std/bigints

type
  RSAKeyPair* = object
    publicKey*: RSAPublicKey
    privateKey*: RSAPrivateKey
    keySize*: int
  
  RSAPublicKey* = object
    n*: BigInt
    e*: BigInt
  
  RSAPrivateKey* = object
    n*: BigInt
    d*: BigInt
    p*: BigInt
    q*: BigInt
    dP*: BigInt
    dQ*: BigInt
    qInv*: BigInt
  
  RSAError* = object of CatchableError
  RSAKeyError* = object of RSAError
  RSAEncryptionError* = object of RSAError
  RSADecryptionError* = object of RSAError
  
  PaddingScheme* = enum
    NoPadding
    PKCS1v15
    OAEP_SHA256
