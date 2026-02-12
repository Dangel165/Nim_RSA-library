## RSA 라이브러리 대화형 데모

import rsa
import std/[strutils, terminal]

proc printHeader() =
  echo ""
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║         Nim RSA 암호화 라이브러리 데모                ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""

proc printMenu() =
  echo "─────────────────────────────────────────────────────────"
  echo "1. 새 RSA 키 생성"
  echo "2. 메시지 암호화"
  echo "3. 메시지 복호화"
  echo "4. 키 정보 보기"
  echo "5. 암호화 강도 테스트"
  echo "6. 종료"
  echo "─────────────────────────────────────────────────────────"
  stdout.write "선택 (1-6): "
  stdout.flushFile()

var
  currentKeys: RSAKeyPair
  hasKeys = false
  lastEncrypted: seq[int64]

proc generateNewKeys() =
  echo ""
  echo "키 비트 크기를 선택하세요:"
  echo "  1. 12비트 (빠름, 약함)"
  echo "  2. 16비트 (보통, 데모용)"
  echo "  3. 20비트 (느림, 강함)"
  stdout.write "선택 (1-3): "
  stdout.flushFile()
  
  let choice = stdin.readLine()
  let bits = case choice
    of "1": 12
    of "2": 16
    of "3": 20
    else: 16
  
  echo ""
  echo "RSA 키 생성 중 (", bits, "비트)..."
  currentKeys = generateKeyPair(bits)
  hasKeys = true
  echo ""
  echo "✓ 키 생성 완료!"

proc encryptMessage() =
  if not hasKeys:
    echo ""
    echo "✗ 먼저 키를 생성해주세요!"
    return
  
  echo ""
  stdout.write "암호화할 메시지를 입력하세요: "
  stdout.flushFile()
  let message = stdin.readLine()
  
  if message.len == 0:
    echo "✗ 메시지가 비어있습니다!"
    return
  
  echo ""
  echo "암호화 중..."
  lastEncrypted = encrypt(message, currentKeys.publicKey)
  let hexStr = lastEncrypted.toHexString()
  
  echo ""
  echo "✓ 암호화 완료!"
  echo "원본 메시지: ", message
  echo "암호화된 데이터 (16진수):"
  echo hexStr

proc decryptMessage() =
  if not hasKeys:
    echo ""
    echo "✗ 먼저 키를 생성해주세요!"
    return
  
  if lastEncrypted.len == 0:
    echo ""
    echo "✗ 암호화된 메시지가 없습니다!"
    return
  
  echo ""
  echo "복호화 중..."
  let decrypted = decrypt(lastEncrypted, currentKeys.privateKey)
  
  echo ""
  echo "✓ 복호화 완료!"
  echo "복호화된 메시지: ", decrypted

proc showKeyInfo() =
  if not hasKeys:
    echo ""
    echo "✗ 생성된 키가 없습니다!"
    return
  
  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "RSA 키 정보"
  echo "═══════════════════════════════════════════════════════"
  echo ""
  echo "[공개키]"
  echo "  모듈러스 (n): ", currentKeys.publicKey.n
  echo "  공개 지수 (e): ", currentKeys.publicKey.e
  echo ""
  echo "[개인키]"
  echo "  모듈러스 (n): ", currentKeys.privateKey.n
  echo "  개인 지수 (d): ", currentKeys.privateKey.d
  echo ""
  echo "═══════════════════════════════════════════════════════"

proc testEncryptionStrength() =
  echo ""
  echo "암호화 강도 테스트 중..."
  echo ""
  
  let testMessages = @[
    "A",
    "Hello",
    "Test123",
    "Special!@#",
    "Long message test for RSA encryption"
  ]
  
  var successCount = 0
  
  for msg in testMessages:
    let keys = generateKeyPair(16)
    let enc = encrypt(msg, keys.publicKey)
    let dec = decrypt(enc, keys.privateKey)
    
    let status = if msg == dec: "✓" else "✗"
    echo status, " '", msg, "' (길이: ", msg.len, ")"
    
    if msg == dec:
      successCount += 1
  
  echo ""
  echo "결과: ", successCount, "/", testMessages.len, " 성공"
  
  if successCount == testMessages.len:
    echo "✓ 모든 테스트 통과!"
  else:
    echo "✗ 일부 테스트 실패"

# 메인 루프
printHeader()

while true:
  printMenu()
  let choice = stdin.readLine()
  
  case choice
  of "1":
    generateNewKeys()
  of "2":
    encryptMessage()
  of "3":
    decryptMessage()
  of "4":
    showKeyInfo()
  of "5":
    testEncryptionStrength()
  of "6":
    echo ""
    echo "프로그램을 종료합니다."
    break
  else:
    echo ""
    echo "✗ 잘못된 선택입니다. 1-6 사이의 숫자를 입력하세요."
  
  echo ""
  stdout.write "계속하려면 Enter를 누르세요..."
  discard stdin.readLine()
  
  # 화면 정리 (Windows)
  when defined(windows):
    discard execShellCmd("cls")
  else:
    discard execShellCmd("clear")
  
  printHeader()

echo ""
echo "감사합니다!"
