import types, math
import std/[bigints, times, logging]

var logger = newConsoleLogger()

proc generateKeyPair*(bits: int = 2048, verbose: bool = false, useLogger: bool = true): RSAKeyPair =
  
  if bits < 1024:
    raise newException(RSAKeyError, "키 크기는 최소 1024비트 이상이어야 합니다")
  
  if useLogger:
    logger.log(lvlInfo, "RSA 키 생성 시작 (" & $bits & "비트)")
  
  let startTime = cpuTime()
  
  if verbose:
    echo "RSA 키 생성 중 (", bits, "비트)..."
  
  # 두 개의 서로 다른 소수 생성
  if verbose:
    echo "소수 p 생성 중..."
  let p = generateProbablePrime(bits div 2)
  
  if verbose:
    echo "소수 q 생성 중..."
  var q = generateProbablePrime(bits div 2)
  while q == p:
    q = generateProbablePrime(bits div 2)
  
  if verbose:
    echo "소수 생성 완료"
    echo "  p: ", p.toString()[0..min(50, p.toString().len-1)], "..."
    echo "  q: ", q.toString()[0..min(50, q.toString().len-1)], "..."
  
  # n = p * q
  let n = p * q
  if verbose:
    echo "모듈러스 n 계산 완료"
  
  # φ(n) = (p-1)(q-1)
  let phi = (p - initBigInt(1)) * (q - initBigInt(1))
  
  # 공개 지수 e 선택 (65537 사용)
  var e = initBigInt(65537)
  if e >= phi:
    e = initBigInt(3)
  
  # e와 φ(n)이 서로소인지 확인
  while gcd(e, phi) != initBigInt(1):
    e = e + initBigInt(2)
  
  if verbose:
    echo "공개 지수 e: ", e
  
  # 개인 지수 d 계산 (d = e^-1 mod φ(n))
  if verbose:
    echo "개인 지수 계산 중..."
  let d = modInverse(e, phi)
  
  # CRT 파라미터 계산 (복호화 최적화)
  let dP = d mod (p - initBigInt(1))
  let dQ = d mod (q - initBigInt(1))
  let qInv = modInverse(q, p)
  
  let elapsedTime = cpuTime() - startTime
  
  if verbose:
    echo "키 생성 완료! (", elapsedTime.formatFloat(ffDecimal, 2), "초)"
  
  if useLogger:
    logger.log(lvlInfo, "RSA 키 생성 완료 (" & $elapsedTime.formatFloat(ffDecimal, 2) & "초)")
  
  result.publicKey = RSAPublicKey(n: n, e: e)
  result.privateKey = RSAPrivateKey(
    n: n, d: d,
    p: p, q: q,
    dP: dP, dQ: dQ,
    qInv: qInv
  )
  result.keySize = bits
