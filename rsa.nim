## Nim RSA Cryptography Library
## 순수 Nim으로 구현된 RSA 암호화/복호화 라이브러리

import std/[random, math, strutils, sequtils, times]

type
  RSAKeyPair* = object
    publicKey*: RSAPublicKey
    privateKey*: RSAPrivateKey
  
  RSAPublicKey* = object
    n*: int64  # modulus
    e*: int64  # public exponent
  
  RSAPrivateKey* = object
    n*: int64  # modulus
    d*: int64  # private exponent

# 소수 판별 (Miller-Rabin 알고리즘)
proc isPrime(n: int64, k: int = 5): bool =
  if n <= 1: return false
  if n <= 3: return true
  if n mod 2 == 0: return false
  
  # n-1 = 2^r * d 형태로 분해
  var d = n - 1
  var r = 0
  while d mod 2 == 0:
    d = d div 2
    r += 1
  
  # Miller-Rabin 테스트 k번 반복
  randomize()
  for _ in 0..<k:
    let a = rand(2.int64 .. n-2)
    var x = modPow(a, d, n)
    
    if x == 1 or x == n - 1:
      continue
    
    var continueOuter = false
    for _ in 0..<r-1:
      x = (x * x) mod n
      if x == n - 1:
        continueOuter = true
        break
    
    if not continueOuter:
      return false
  
  return true

# 모듈러 거듭제곱 (a^b mod m)
proc modPow(base, exp, modulus: int64): int64 =
  var result = 1.int64
  var b = base mod modulus
  var e = exp
  
  while e > 0:
    if (e and 1) == 1:
      result = (result * b) mod modulus
    e = e shr 1
    b = (b * b) mod modulus
  
  return result

# 확장 유클리드 알고리즘
proc extendedGCD(a, b: int64): tuple[gcd, x, y: int64] =
  if b == 0:
    return (a, 1.int64, 0.int64)
  
  let (gcd, x1, y1) = extendedGCD(b, a mod b)
  let x = y1
  let y = x1 - (a div b) * y1
  
  return (gcd, x, y)

# 모듈러 역원 계산
proc modInverse(a, m: int64): int64 =
  let (gcd, x, _) = extendedGCD(a, m)
  if gcd != 1:
    raise newException(ValueError, "모듈러 역원이 존재하지 않습니다")
  return (x mod m + m) mod m

# 랜덤 소수 생성
proc generatePrime(bits: int = 16): int64 =
  randomize()
  let minVal = 1.int64 shl (bits - 1)
  let maxVal = (1.int64 shl bits) - 1
  
  while true:
    var candidate = rand(minVal .. maxVal)
    if candidate mod 2 == 0:
      candidate += 1
    
    if isPrime(candidate):
      return candidate

# RSA 키 쌍 생성
proc generateKeyPair*(bits: int = 16): RSAKeyPair =
  ## RSA 키 쌍을 생성합니다
  ## bits: 소수의 비트 크기 (기본값: 16)
  
  echo "RSA 키 생성 중..."
  
  # 두 개의 서로 다른 소수 생성
  let p = generatePrime(bits)
  var q = generatePrime(bits)
  while q == p:
    q = generatePrime(bits)
  
  echo "소수 p: ", p
  echo "소수 q: ", q
  
  # n = p * q
  let n = p * q
  echo "모듈러스 n: ", n
  
  # φ(n) = (p-1)(q-1)
  let phi = (p - 1) * (q - 1)
  echo "오일러 파이 φ(n): ", phi
  
  # 공개 지수 e 선택 (일반적으로 65537 사용)
  var e = 65537.int64
  if e >= phi:
    e = 3.int64
  
  # e와 φ(n)이 서로소인지 확인
  while extendedGCD(e, phi)[0] != 1:
    e += 2
  
  echo "공개 지수 e: ", e
  
  # 개인 지수 d 계산 (d = e^-1 mod φ(n))
  let d = modInverse(e, phi)
  echo "개인 지수 d: ", d
  
  result.publicKey = RSAPublicKey(n: n, e: e)
  result.privateKey = RSAPrivateKey(n: n, d: d)
  
  echo "키 생성 완료!"

# 암호화
proc encrypt*(message: string, publicKey: RSAPublicKey): seq[int64] =
  ## 메시지를 RSA 공개키로 암호화합니다
  result = @[]
  
  for ch in message:
    let m = ch.int64
    if m >= publicKey.n:
      raise newException(ValueError, "메시지가 너무 큽니다")
    
    let c = modPow(m, publicKey.e, publicKey.n)
    result.add(c)

# 복호화
proc decrypt*(ciphertext: seq[int64], privateKey: RSAPrivateKey): string =
  ## 암호문을 RSA 개인키로 복호화합니다
  result = ""
  
  for c in ciphertext:
    let m = modPow(c, privateKey.d, privateKey.n)
    result.add(chr(m.int))

# 키를 문자열로 변환
proc toString*(key: RSAPublicKey): string =
  return "PublicKey(n=" & $key.n & ", e=" & $key.e & ")"

proc toString*(key: RSAPrivateKey): string =
  return "PrivateKey(n=" & $key.n & ", d=" & $key.d & ")"

# 암호문을 16진수 문자열로 변환
proc toHexString*(ciphertext: seq[int64]): string =
  result = ""
  for i, val in ciphertext:
    if i > 0:
      result.add(" ")
    result.add(val.toHex())

# 16진수 문자열을 암호문으로 변환
proc fromHexString*(hexStr: string): seq[int64] =
  result = @[]
  for part in hexStr.split(" "):
    if part.len > 0:
      result.add(parseHexInt(part).int64)

# 내보내기
when isMainModule:
  echo "=== Nim RSA 라이브러리 테스트 ==="
  echo ""
  
  # 키 생성
  let keyPair = generateKeyPair(16)
  echo ""
  echo "생성된 키:"
  echo "공개키: ", keyPair.publicKey.toString()
  echo "개인키: ", keyPair.privateKey.toString()
  echo ""
  
  # 암호화
  let message = "Hello RSA!"
  echo "원본 메시지: ", message
  
  let encrypted = encrypt(message, keyPair.publicKey)
  echo "암호화된 메시지: ", encrypted.toHexString()
  echo ""
  
  # 복호화
  let decrypted = decrypt(encrypted, keyPair.privateKey)
  echo "복호화된 메시지: ", decrypted
  echo ""
  
  if message == decrypted:
    echo "✓ 암호화/복호화 성공!"
  else:
    echo "✗ 암호화/복호화 실패!"
