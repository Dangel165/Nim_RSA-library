## NimRSA 통합 테스트

import unittest
import nimrsa

suite "RSA 수학 연산 테스트":
  test "모듈러 거듭제곱":
    check modPow(2, 10, 1000) == 24
    check modPow(3, 5, 7) == 5
    check modPow(5, 3, 13) == 8
  
  test "소수 판별":
    check isPrime(2) == true
    check isPrime(3) == true
    check isPrime(5) == true
    check isPrime(7) == true
    check isPrime(11) == true
    check isPrime(4) == false
    check isPrime(6) == false
    check isPrime(9) == false
  
  test "소수 생성":
    for i in 1..10:
      let p = generatePrime(12)
      check isPrime(p) == true

suite "RSA 키 생성 테스트":
  test "키 생성":
    let keys = generateKeyPair(16)
    check keys.publicKey.n > 0
    check keys.publicKey.e > 0
    check keys.privateKey.n > 0
    check keys.privateKey.d > 0
    check keys.publicKey.n == keys.privateKey.n
  
  test "여러 키 생성":
    for i in 1..5:
      let keys = generateKeyPair(16)
      check keys.publicKey.n > 0

suite "RSA 암호화/복호화 테스트":
  test "기본 암호화/복호화":
    let keys = generateKeyPair(16)
    let message = "Test"
    let encrypted = encrypt(message, keys.publicKey)
    let decrypted = decrypt(encrypted, keys.privateKey)
    check message == decrypted
  
  test "영문 메시지":
    let keys = generateKeyPair(16)
    let message = "Hello World"
    let encrypted = encrypt(message, keys.publicKey)
    let decrypted = decrypt(encrypted, keys.privateKey)
    check message == decrypted
  
  test "숫자 메시지":
    let keys = generateKeyPair(16)
    let message = "1234567890"
    let encrypted = encrypt(message, keys.publicKey)
    let decrypted = decrypt(encrypted, keys.privateKey)
    check message == decrypted
  
  test "특수문자":
    let keys = generateKeyPair(16)
    let message = "!@#$%"
    let encrypted = encrypt(message, keys.publicKey)
    let decrypted = decrypt(encrypted, keys.privateKey)
    check message == decrypted
  
  test "빈 문자열":
    let keys = generateKeyPair(16)
    let message = ""
    let encrypted = encrypt(message, keys.publicKey)
    let decrypted = decrypt(encrypted, keys.privateKey)
    check message == decrypted
  
  test "긴 메시지":
    let keys = generateKeyPair(16)
    let message = "This is a longer message to test RSA!"
    let encrypted = encrypt(message, keys.publicKey)
    let decrypted = decrypt(encrypted, keys.privateKey)
    check message == decrypted

suite "RSA 유틸리티 테스트":
  test "16진수 변환":
    let keys = generateKeyPair(16)
    let message = "Hex Test"
    let encrypted = encrypt(message, keys.publicKey)
    let hexStr = encrypted.toHexString()
    let restored = fromHexString(hexStr)
    let decrypted = decrypt(restored, keys.privateKey)
    check message == decrypted
  
  test "키 문자열 변환":
    let keys = generateKeyPair(16)
    let pubStr = keys.publicKey.toString()
    let privStr = keys.privateKey.toString()
    check pubStr.len > 0
    check privStr.len > 0

suite "RSA 파일 입출력 테스트":
  test "키 저장/로드":
    import std/os
    let keys = generateKeyPair(16)
    let filename = "test_keys.json"
    
    saveKeys(keys, filename)
    check fileExists(filename)
    
    let loadedKeys = loadKeys(filename)
    check keys.publicKey.n == loadedKeys.publicKey.n
    check keys.publicKey.e == loadedKeys.publicKey.e
    check keys.privateKey.d == loadedKeys.privateKey.d
    
    removeFile(filename)

echo ""
echo "╔════════════════════════════════════════╗"
echo "║      모든 테스트 완료!                 ║"
echo "╚════════════════════════════════════════╝"
