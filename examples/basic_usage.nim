import nimrsa

echo "Basic RSA Usage Example"
echo "======================="
echo ""

echo "[1] Generate 2048-bit key pair"
let keys = generateKeyPair(2048, verbose = true)
echo ""

echo "[2] Encrypt message"
let message = "Hello NimRSA!"
echo "Original: ", message
let encrypted = encrypt(message, keys.publicKey, OAEP_SHA256)
echo "Encrypted: ", encrypted.toHexString()[0..min(64, encrypted.toHexString().len-1)], "..."
echo ""

echo "[3] Decrypt message"
let decrypted = decrypt(encrypted, keys.privateKey, OAEP_SHA256)
echo "Decrypted: ", decrypted
echo ""

echo "[4] Verify"
if message == decrypted:
  echo "Success!"
else:
  echo "Failed!"
