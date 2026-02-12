import types, crypto, utils
import std/[json, os, bigints, logging]

var logger = newConsoleLogger()

proc saveKeys*(keyPair: RSAKeyPair, filename: string) =
  
  try:
    let jsonData = %* {
      "version": "1.0",
      "keySize": keyPair.keySize,
      "public": {
        "n": keyPair.publicKey.n.toString(),
        "e": keyPair.publicKey.e.toString()
      },
      "private": {
        "n": keyPair.privateKey.n.toString(),
        "d": keyPair.privateKey.d.toString(),
        "p": keyPair.privateKey.p.toString(),
        "q": keyPair.privateKey.q.toString(),
        "dP": keyPair.privateKey.dP.toString(),
        "dQ": keyPair.privateKey.dQ.toString(),
        "qInv": keyPair.privateKey.qInv.toString()
      }
    }
    
    writeFile(filename, jsonData.pretty())
    logger.log(lvlInfo, "키 저장 완료: " & filename)
    
  except Exception as e:
    logger.log(lvlError, "키 저장 실패: " & e.msg)
    raise newException(RSAKeyError, "키 저장 중 오류 발생: " & e.msg)

proc loadKeys*(filename: string): RSAKeyPair =
  
  try:
    if not fileExists(filename):
      raise newException(RSAKeyError, "키 파일을 찾을 수 없습니다: " & filename)
    
    let jsonStr = readFile(filename)
    let jsonData = parseJson(jsonStr)
    
    result.keySize = jsonData["keySize"].getInt()
    
    result.publicKey = RSAPublicKey(
      n: initBigInt(jsonData["public"]["n"].getStr()),
      e: initBigInt(jsonData["public"]["e"].getStr())
    )
    
    result.privateKey = RSAPrivateKey(
      n: initBigInt(jsonData["private"]["n"].getStr()),
      d: initBigInt(jsonData["private"]["d"].getStr()),
      p: initBigInt(jsonData["private"]["p"].getStr()),
      q: initBigInt(jsonData["private"]["q"].getStr()),
      dP: initBigInt(jsonData["private"]["dP"].getStr()),
      dQ: initBigInt(jsonData["private"]["dQ"].getStr()),
      qInv: initBigInt(jsonData["private"]["qInv"].getStr())
    )
    
    logger.log(lvlInfo, "키 로드 완료: " & filename)
    
  except Exception as e:
    logger.log(lvlError, "키 로드 실패: " & e.msg)
    raise newException(RSAKeyError, "키 로드 중 오류 발생: " & e.msg)

proc savePublicKey*(publicKey: RSAPublicKey, filename: string) =
  try:
    let jsonData = %* {
      "version": "1.0",
      "type": "public",
      "n": publicKey.n.toString(),
      "e": publicKey.e.toString()
    }
    
    writeFile(filename, jsonData.pretty())
    logger.log(lvlInfo, "공개키 저장 완료: " & filename)
    
  except Exception as e:
    logger.log(lvlError, "공개키 저장 실패: " & e.msg)
    raise newException(RSAKeyError, "공개키 저장 중 오류 발생: " & e.msg)

proc loadPublicKey*(filename: string): RSAPublicKey =
  try:
    if not fileExists(filename):
      raise newException(RSAKeyError, "키 파일을 찾을 수 없습니다: " & filename)
    
    let jsonStr = readFile(filename)
    let jsonData = parseJson(jsonStr)
    
    result = RSAPublicKey(
      n: initBigInt(jsonData["n"].getStr()),
      e: initBigInt(jsonData["e"].getStr())
    )
    
    logger.log(lvlInfo, "공개키 로드 완료: " & filename)
    
  except Exception as e:
    logger.log(lvlError, "공개키 로드 실패: " & e.msg)
    raise newException(RSAKeyError, "공개키 로드 중 오류 발생: " & e.msg)

proc encryptFile*(inputFile, outputFile: string, publicKey: RSAPublicKey,
                  padding: PaddingScheme = OAEP_SHA256) =
  
  try:
    if not fileExists(inputFile):
      raise newException(RSAEncryptionError, "입력 파일을 찾을 수 없습니다: " & inputFile)
    
    let content = readFile(inputFile)
    let encrypted = encrypt(content, publicKey, padding)
    let base64Data = toBase64(encrypted)
    
    writeFile(outputFile, base64Data)
    logger.log(lvlInfo, "파일 암호화 완료: " & outputFile)
    
  except Exception as e:
    logger.log(lvlError, "파일 암호화 실패: " & e.msg)
    raise newException(RSAEncryptionError, "파일 암호화 중 오류 발생: " & e.msg)

proc decryptFile*(inputFile, outputFile: string, privateKey: RSAPrivateKey,
                  padding: PaddingScheme = OAEP_SHA256, useCRT: bool = true) =
  
  try:
    if not fileExists(inputFile):
      raise newException(RSADecryptionError, "입력 파일을 찾을 수 없습니다: " & inputFile)
    
    let base64Data = readFile(inputFile)
    let encrypted = fromBase64(base64Data)
    let decrypted = decrypt(encrypted, privateKey, padding, useCRT)
    
    writeFile(outputFile, decrypted)
    logger.log(lvlInfo, "파일 복호화 완료: " & outputFile)
    
  except Exception as e:
    logger.log(lvlError, "파일 복호화 실패: " & e.msg)
    raise newException(RSADecryptionError, "파일 복호화 중 오류 발생: " & e.msg)
