import types, math, padding
import std/[bigints, logging]

var logger = newConsoleLogger()

proc bytesToBigInt(bytes: seq[byte]): BigInt =
  result = initBigInt(0)
  for b in bytes:
    result = (result shl 8) or initBigInt(int(b))

proc bigIntToBytes(num: BigInt, size: int): seq[byte] =
  result = newSeq[byte](size)
  var n = num
  for i in countdown(size - 1, 0):
    result[i] = byte(n and initBigInt(0xFF))
    n = n shr 8

proc encrypt*(message: string, publicKey: RSAPublicKey, 
              padding: PaddingScheme = OAEP_SHA256): seq[byte] =
  
  try:
    let messageBytes = cast[seq[byte]](message)
    let keySize = (publicKey.n.toString().len * 4 + 7) div 8  # 대략적인 바이트 크기
    
    # 패딩 적용
    var paddedMessage: seq[byte]
    case padding
    of NoPadding:
      paddedMessage = messageBytes
    of PKCS1v15:
      paddedMessage = pkcs1v15Pad(messageBytes, keySize)
    of OAEP_SHA256:
      paddedMessage = oaepSHA256Pad(messageBytes, keySize)
    
    # 바이트를 BigInt로 변환
    let m = bytesToBigInt(paddedMessage)
    
    if m >= publicKey.n:
      raise newException(RSAEncryptionError, "메시지가 모듈러스보다 큽니다")
    
    # RSA 암호화: c = m^e mod n
    let c = modPow(m, publicKey.e, publicKey.n)
    
    # BigInt를 바이트로 변환
    result = bigIntToBytes(c, keySize)
    
    logger.log(lvlDebug, "암호화 완료: " & $result.len & " 바이트")
    
  except Exception as e:
    logger.log(lvlError, "암호화 실패: " & e.msg)
    raise newException(RSAEncryptionError, "암호화 중 오류 발생: " & e.msg)

proc decrypt*(ciphertext: seq[byte], privateKey: RSAPrivateKey,
              padding: PaddingScheme = OAEP_SHA256, useCRT: bool = true): string =
  
  try:
    # 바이트를 BigInt로 변환
    let c = bytesToBigInt(ciphertext)
    
    # RSA 복호화
    var m: BigInt
    if useCRT and privateKey.p != initBigInt(0):
      # CRT 최적화 사용 (약 4배 빠름)
      let m1 = modPow(c, privateKey.dP, privateKey.p)
      let m2 = modPow(c, privateKey.dQ, privateKey.q)
      let h = (privateKey.qInv * (m1 - m2 + privateKey.p)) mod privateKey.p
      m = m2 + h * privateKey.q
    else:
      # 일반 복호화: m = c^d mod n
      m = modPow(c, privateKey.d, privateKey.n)
    
    # BigInt를 바이트로 변환
    let keySize = ciphertext.len
    let paddedMessage = bigIntToBytes(m, keySize)
    
    # 패딩 제거
    var messageBytes: seq[byte]
    case padding
    of NoPadding:
      messageBytes = paddedMessage
    of PKCS1v15:
      messageBytes = pkcs1v15Unpad(paddedMessage)
    of OAEP_SHA256:
      messageBytes = oaepSHA256Unpad(paddedMessage)
    
    result = cast[string](messageBytes)
    
    logger.log(lvlDebug, "복호화 완료: " & $result.len & " 바이트")
    
  except Exception as e:
    logger.log(lvlError, "복호화 실패: " & e.msg)
    raise newException(RSADecryptionError, "복호화 중 오류 발생: " & e.msg)

proc encryptBytes*(data: seq[byte], publicKey: RSAPublicKey,
                   padding: PaddingScheme = OAEP_SHA256): seq[byte] =
  ## 바이트 배열을 암호화
  let message = cast[string](data)
  return encrypt(message, publicKey, padding)

proc decryptBytes*(ciphertext: seq[byte], privateKey: RSAPrivateKey,
                   padding: PaddingScheme = OAEP_SHA256, useCRT: bool = true): seq[byte] =
  ## 바이트 배열을 복호화
  let message = decrypt(ciphertext, privateKey, padding, useCRT)
  return cast[seq[byte]](message)
