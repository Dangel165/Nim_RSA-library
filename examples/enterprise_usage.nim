import nimrsa
import std/[times, logging]

var logger = newConsoleLogger()
addHandler(logger)

echo "Enterprise RSA Example (2048-bit + OAEP)"
echo "========================================"
echo ""

echo "[1] Generate 2048-bit keys"
let startTime = cpuTime()
let keys = generateKeyPair(2048, verbose = true)
let keyGenTime = cpuTime() - startTime
echo ""
echo "Key generation time: ", keyGenTime.formatFloat(ffDecimal, 3), "s"
echo "Key size: ", keys.keySize, " bits"
echo ""

echo "[2] Save keys"
saveKeys(keys, "enterprise_keys.json")
savePublicKey(keys.publicKey, "public_key.json")
echo "Full keys saved: enterprise_keys.json"
echo "Public key saved: public_key.json"
echo ""

echo "[3] Encrypt with OAEP"
let confidentialData = "This is highly confidential enterprise data!"
echo "Original: ", confidentialData
echo "Length: ", confidentialData.len, " bytes"

let encStartTime = cpuTime()
let encrypted = encrypt(confidentialData, keys.publicKey, OAEP_SHA256)
let encTime = cpuTime() - encStartTime

echo "Encryption time: ", encTime.formatFloat(ffDecimal, 3), "s"
echo "Ciphertext size: ", encrypted.len, " bytes"
echo "Ciphertext (Base64): ", toBase64(encrypted)[0..min(64, toBase64(encrypted).len-1)], "..."
echo ""

echo "[4] Decrypt with CRT"
let decStartTime = cpuTime()
let decrypted = decrypt(encrypted, keys.privateKey, OAEP_SHA256, useCRT = true)
let decTime = cpuTime() - decStartTime

echo "Decryption time: ", decTime.formatFloat(ffDecimal, 3), "s"
echo "Decrypted: ", decrypted
echo ""

echo "[5] Verify"
if confidentialData == decrypted:
  echo "Success!"
else:
  echo "Failed!"
echo ""

echo "[6] Performance comparison (CRT vs Normal)"
let crtStart = cpuTime()
for i in 1..10:
  discard decrypt(encrypted, keys.privateKey, OAEP_SHA256, useCRT = true)
let crtTime = (cpuTime() - crtStart) / 10.0

let normalStart = cpuTime()
for i in 1..10:
  discard decrypt(encrypted, keys.privateKey, OAEP_SHA256, useCRT = false)
let normalTime = (cpuTime() - normalStart) / 10.0

echo "CRT optimization: ", crtTime.formatFloat(ffDecimal, 4), "s"
echo "Normal decryption: ", normalTime.formatFloat(ffDecimal, 4), "s"
echo "Speed improvement: ", (normalTime / crtTime).formatFloat(ffDecimal, 2), "x"
echo ""

echo "[7] Padding comparison"
let pkcs1Enc = encrypt("Test PKCS1", keys.publicKey, PKCS1v15)
let pkcs1Dec = decrypt(pkcs1Enc, keys.privateKey, PKCS1v15)
echo "PKCS#1 v1.5: ", if pkcs1Dec == "Test PKCS1": "Success" else: "Failed"

let oaepEnc = encrypt("Test OAEP", keys.publicKey, OAEP_SHA256)
let oaepDec = decrypt(oaepEnc, keys.privateKey, OAEP_SHA256)
echo "OAEP SHA-256: ", if oaepDec == "Test OAEP": "Success" else: "Failed"
echo ""

echo "All tests completed!"
