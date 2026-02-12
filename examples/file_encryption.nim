import nimrsa
import std/os

echo "File Encryption Example"
echo "======================"
echo ""

echo "[1] Generate keys"
let keys = generateKeyPair(2048)
echo "Keys generated"
echo ""

echo "[2] Save keys"
saveKeys(keys, "my_keys.json")
echo "Keys saved: my_keys.json"
echo ""

echo "[3] Create test file"
writeFile("test_message.txt", "This is a secret message!")
echo "Test file created: test_message.txt"
echo ""

echo "[4] Encrypt file"
encryptFile("test_message.txt", "encrypted.dat", keys.publicKey)
echo "File encrypted: encrypted.dat"
echo ""

echo "[5] Load keys"
let loadedKeys = loadKeys("my_keys.json")
echo "Keys loaded"
echo ""

echo "[6] Decrypt file"
decryptFile("encrypted.dat", "decrypted.txt", loadedKeys.privateKey)
echo "File decrypted: decrypted.txt"
echo ""

echo "[7] Verify"
let original = readFile("test_message.txt")
let decrypted = readFile("decrypted.txt")

if original == decrypted:
  echo "Success!"
else:
  echo "Failed!"

echo ""
echo "Files created:"
echo "  - my_keys.json"
echo "  - test_message.txt"
echo "  - encrypted.dat"
echo "  - decrypted.txt"
