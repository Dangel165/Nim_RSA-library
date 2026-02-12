import std/[random, hashes, sha1]
import types

proc pkcs1v15Pad*(message: seq[byte], keySize: int): seq[byte] =
  ## PKCS#1 v1.5 패딩
  ## keySize: 키 크기 (바이트)
  let mLen = message.len
  let padLen = keySize - mLen - 3
  
  if padLen < 8:
    raise newException(RSAEncryptionError, "메시지가 너무 큽니다")
  
  result = newSeq[byte](keySize)
  result[0] = 0x00
  result[1] = 0x02
  
  # 랜덤 패딩 (0이 아닌 값)
  randomize()
  for i in 2..<(2 + padLen):
    var r = byte(rand(1..255))
    result[i] = r
  
  result[2 + padLen] = 0x00
  
  # 메시지 복사
  for i in 0..<mLen:
    result[3 + padLen + i] = message[i]

proc pkcs1v15Unpad*(padded: seq[byte]): seq[byte] =
  ## PKCS#1 v1.5 언패딩
  if padded.len < 11:
    raise newException(RSADecryptionError, "잘못된 패딩")
  
  if padded[0] != 0x00 or padded[1] != 0x02:
    raise newException(RSADecryptionError, "잘못된 패딩 형식")
  
  # 0x00 구분자 찾기
  var separatorIndex = -1
  for i in 2..<padded.len:
    if padded[i] == 0x00:
      separatorIndex = i
      break
  
  if separatorIndex == -1 or separatorIndex < 10:
    raise newException(RSADecryptionError, "잘못된 패딩 구조")
  
  # 메시지 추출
  result = newSeq[byte](padded.len - separatorIndex - 1)
  for i in 0..<result.len:
    result[i] = padded[separatorIndex + 1 + i]

proc mgf1SHA256*(seed: seq[byte], maskLen: int): seq[byte] =
  ## MGF1 마스크 생성 함수 (SHA-256 기반)
  ## OAEP에서 사용
  result = newSeq[byte](maskLen)
  var counter = 0'u32
  var offset = 0
  
  while offset < maskLen:
    # counter를 바이트로 변환
    var counterBytes = newSeq[byte](4)
    counterBytes[0] = byte((counter shr 24) and 0xFF)
    counterBytes[1] = byte((counter shr 16) and 0xFF)
    counterBytes[2] = byte((counter shr 8) and 0xFF)
    counterBytes[3] = byte(counter and 0xFF)
    
    # SHA-256(seed || counter)
    var input = seed & counterBytes
    let hashVal = $secureHash(cast[string](input))
    
    # 해시 결과를 바이트로 변환
    for i in countup(0, hashVal.len - 1, 2):
      if offset >= maskLen:
        break
      let byteVal = parseHexInt(hashVal[i..i+1])
      result[offset] = byte(byteVal)
      offset += 1
    
    counter += 1

proc oaepSHA256Pad*(message: seq[byte], keySize: int, label: seq[byte] = @[]): seq[byte] =
  ## OAEP 패딩 (SHA-256)
  ## keySize: 키 크기 (바이트)
  ## label: 선택적 라벨 (기본값: 빈 배열)
  
  const hLen = 32  # SHA-256 출력 크기
  let mLen = message.len
  let maxMLen = keySize - 2 * hLen - 2
  
  if mLen > maxMLen:
    raise newException(RSAEncryptionError, "메시지가 너무 큽니다")
  
  # lHash = SHA-256(label)
  let lHash = $secureHash(cast[string](label))
  var lHashBytes = newSeq[byte](hLen)
  for i in countup(0, lHash.len - 1, 2):
    let byteVal = parseHexInt(lHash[i..i+1])
    lHashBytes[i div 2] = byte(byteVal)
  
  # DB = lHash || PS || 0x01 || M
  let psLen = keySize - mLen - 2 * hLen - 2
  var db = newSeq[byte](keySize - hLen - 1)
  
  # lHash 복사
  for i in 0..<hLen:
    db[i] = lHashBytes[i]
  
  # PS (0으로 채움)
  for i in hLen..<(hLen + psLen):
    db[i] = 0x00
  
  # 0x01 구분자
  db[hLen + psLen] = 0x01
  
  # 메시지 복사
  for i in 0..<mLen:
    db[hLen + psLen + 1 + i] = message[i]
  
  # seed 생성
  randomize()
  var seed = newSeq[byte](hLen)
  for i in 0..<hLen:
    seed[i] = byte(rand(255))
  
  # dbMask = MGF1(seed, k - hLen - 1)
  let dbMask = mgf1SHA256(seed, db.len)
  
  # maskedDB = DB xor dbMask
  var maskedDB = newSeq[byte](db.len)
  for i in 0..<db.len:
    maskedDB[i] = db[i] xor dbMask[i]
  
  # seedMask = MGF1(maskedDB, hLen)
  let seedMask = mgf1SHA256(maskedDB, hLen)
  
  # maskedSeed = seed xor seedMask
  var maskedSeed = newSeq[byte](hLen)
  for i in 0..<hLen:
    maskedSeed[i] = seed[i] xor seedMask[i]
  
  # EM = 0x00 || maskedSeed || maskedDB
  result = newSeq[byte](keySize)
  result[0] = 0x00
  for i in 0..<hLen:
    result[1 + i] = maskedSeed[i]
  for i in 0..<maskedDB.len:
    result[1 + hLen + i] = maskedDB[i]

proc oaepSHA256Unpad*(padded: seq[byte], label: seq[byte] = @[]): seq[byte] =
  ## OAEP 언패딩 (SHA-256)
  const hLen = 32
  
  if padded.len < 2 * hLen + 2:
    raise newException(RSADecryptionError, "잘못된 패딩 크기")
  
  if padded[0] != 0x00:
    raise newException(RSADecryptionError, "잘못된 패딩 형식")
  
  # maskedSeed와 maskedDB 추출
  var maskedSeed = newSeq[byte](hLen)
  for i in 0..<hLen:
    maskedSeed[i] = padded[1 + i]
  
  var maskedDB = newSeq[byte](padded.len - hLen - 1)
  for i in 0..<maskedDB.len:
    maskedDB[i] = padded[1 + hLen + i]
  
  # seedMask = MGF1(maskedDB, hLen)
  let seedMask = mgf1SHA256(maskedDB, hLen)
  
  # seed = maskedSeed xor seedMask
  var seed = newSeq[byte](hLen)
  for i in 0..<hLen:
    seed[i] = maskedSeed[i] xor seedMask[i]
  
  # dbMask = MGF1(seed, len(maskedDB))
  let dbMask = mgf1SHA256(seed, maskedDB.len)
  
  # DB = maskedDB xor dbMask
  var db = newSeq[byte](maskedDB.len)
  for i in 0..<maskedDB.len:
    db[i] = maskedDB[i] xor dbMask[i]
  
  # lHash 검증
  let lHash = $secureHash(cast[string](label))
  for i in countup(0, min(hLen * 2 - 1, lHash.len - 1), 2):
    let byteVal = parseHexInt(lHash[i..i+1])
    if db[i div 2] != byte(byteVal):
      raise newException(RSADecryptionError, "라벨 검증 실패")
  
  # 0x01 구분자 찾기
  var separatorIndex = -1
  for i in hLen..<db.len:
    if db[i] == 0x01:
      separatorIndex = i
      break
    elif db[i] != 0x00:
      raise newException(RSADecryptionError, "잘못된 패딩 구조")
  
  if separatorIndex == -1:
    raise newException(RSADecryptionError, "구분자를 찾을 수 없습니다")
  
  # 메시지 추출
  result = newSeq[byte](db.len - separatorIndex - 1)
  for i in 0..<result.len:
    result[i] = db[separatorIndex + 1 + i]
