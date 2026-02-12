## RSA 라이브러리 사용 예제

import rsa
import std/strutils

echo "╔════════════════════════════════════════╗"
echo "║   Nim RSA 암호화 라이브러리 예제      ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 1. 키 생성
echo "[1단계] RSA 키 쌍 생성"
echo "─────────────────────────────────────────"
let keys = generateKeyPair(16)  # 16비트 키 (데모용)
echo ""

# 2. 메시지 암호화
echo "[2단계] 메시지 암호화"
echo "─────────────────────────────────────────"
let originalMessage = "Nim is awesome!"
echo "원본 메시지: ", originalMessage

let encryptedData = encrypt(originalMessage, keys.publicKey)
let hexCipher = encryptedData.toHexString()
echo "암호화 완료: ", hexCipher
echo ""

# 3. 메시지 복호화
echo "[3단계] 메시지 복호화"
echo "─────────────────────────────────────────"
let decryptedMessage = decrypt(encryptedData, keys.privateKey)
echo "복호화 완료: ", decryptedMessage
echo ""

# 4. 검증
echo "[4단계] 검증"
echo "─────────────────────────────────────────"
if originalMessage == decryptedMessage:
  echo "✓ 성공: 원본과 복호화된 메시지가 일치합니다!"
else:
  echo "✗ 실패: 메시지가 일치하지 않습니다."
echo ""

# 5. 다양한 메시지 테스트
echo "[5단계] 추가 테스트"
echo "─────────────────────────────────────────"
let testMessages = @[
  "Hello World",
  "RSA 2024",
  "Nim Lang!",
  "12345"
]

for msg in testMessages:
  let enc = encrypt(msg, keys.publicKey)
  let dec = decrypt(enc, keys.privateKey)
  let status = if msg == dec: "✓" else: "✗"
  echo status, " '", msg, "' -> '", dec, "'"

echo ""
echo "테스트 완료!"
