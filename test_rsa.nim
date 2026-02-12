## RSA 라이브러리 단위 테스트

import rsa
import std/[unittest, random]

suite "RSA 암호화 테스트":
  
  test "키 생성 테스트":
    let keys = generateKeyPair(16)
    check keys.publicKey.n > 0
    check keys.publicKey.e > 0
    check keys.privateKey.n > 0
    check keys.privateKey.d > 0
    check keys.publicKey.n == keys.privateKey.n
  
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
  
  test "특수문자 메시지":
    let keys = generateKeyPair(16)
    let message = "!@#$%^&*()"
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
    let message = "This is a longer message to test RSA encryption!"
    let encrypted = encrypt(message, keys.publicKey)
    let decrypted = decrypt(encrypted, keys.privateKey)
    check message == decrypted
  
  test "16진수 변환":
    let keys = generateKeyPair(16)
    let message = "Hex Test"
    let encrypted = encrypt(message, keys.publicKey)
    let hexStr = encrypted.toHexString()
    let restored = fromHexString(hexStr)
    let decrypted = decrypt(restored, keys.privateKey)
    check message == decrypted
  
  test "여러 키 쌍 생성":
    for i in 1..5:
      let keys = generateKeyPair(16)
      let message = "Test " & $i
      let encrypted = encrypt(message, keys.publicKey)
      let decrypted = decrypt(encrypted, keys.privateKey)
      check message == decrypted

echo ""
echo "╔════════════════════════════════════════╗"
echo "║      RSA 테스트 완료!                  ║"
echo "╚════════════════════════════════════════╝"
