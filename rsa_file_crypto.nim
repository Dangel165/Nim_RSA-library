## RSA 파일 암호화/복호화 도구

import rsa
import std/[os, strutils, json]

proc saveKeys*(keyPair: RSAKeyPair, filename: string) =
  ## RSA 키를 JSON 파일로 저장
  let jsonData = %* {
    "public": {
      "n": keyPair.publicKey.n,
      "e": keyPair.publicKey.e
    },
    "private": {
      "n": keyPair.privateKey.n,
      "d": keyPair.privateKey.d
    }
  }
  
  writeFile(filename, jsonData.pretty())
  echo "키가 저장되었습니다: ", filename

proc loadKeys*(filename: string): RSAKeyPair =
  ## JSON 파일에서 RSA 키 로드
  let jsonStr = readFile(filename)
  let jsonData = parseJson(jsonStr)
  
  result.publicKey = RSAPublicKey(
    n: jsonData["public"]["n"].getInt(),
    e: jsonData["public"]["e"].getInt()
  )
  
  result.privateKey = RSAPrivateKey(
    n: jsonData["private"]["n"].getInt(),
    d: jsonData["private"]["d"].getInt()
  )
  
  echo "키가 로드되었습니다: ", filename

proc encryptFile*(inputFile, outputFile: string, publicKey: RSAPublicKey) =
  ## 파일을 암호화
  echo "파일 암호화 중: ", inputFile
  
  let content = readFile(inputFile)
  let encrypted = encrypt(content, publicKey)
  let hexData = encrypted.toHexString()
  
  writeFile(outputFile, hexData)
  echo "암호화 완료: ", outputFile

proc decryptFile*(inputFile, outputFile: string, privateKey: RSAPrivateKey) =
  ## 파일을 복호화
  echo "파일 복호화 중: ", inputFile
  
  let hexData = readFile(inputFile)
  let encrypted = fromHexString(hexData)
  let decrypted = decrypt(encrypted, privateKey)
  
  writeFile(outputFile, decrypted)
  echo "복호화 완료: ", outputFile

when isMainModule:
  import std/parseopt
  
  var
    mode = ""
    inputFile = ""
    outputFile = ""
    keyFile = "rsa_keys.json"
  
  # 명령줄 인자 파싱
  var p = initOptParser()
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case p.key
      of "m", "mode": mode = p.val
      of "i", "input": inputFile = p.val
      of "o", "output": outputFile = p.val
      of "k", "key": keyFile = p.val
    of cmdArgument:
      discard
  
  echo "╔════════════════════════════════════════╗"
  echo "║   RSA 파일 암호화/복호화 도구         ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  
  case mode
  of "keygen":
    echo "새 RSA 키 생성 중..."
    let keys = generateKeyPair(16)
    saveKeys(keys, keyFile)
    echo ""
    echo "공개키: ", keys.publicKey.toString()
    echo "개인키: ", keys.privateKey.toString()
  
  of "encrypt":
    if inputFile == "" or outputFile == "":
      echo "사용법: rsa_file_crypto -m:encrypt -i:input.txt -o:output.enc [-k:keys.json]"
      quit(1)
    
    let keys = loadKeys(keyFile)
    encryptFile(inputFile, outputFile, keys.publicKey)
  
  of "decrypt":
    if inputFile == "" or outputFile == "":
      echo "사용법: rsa_file_crypto -m:decrypt -i:input.enc -o:output.txt [-k:keys.json]"
      quit(1)
    
    let keys = loadKeys(keyFile)
    decryptFile(inputFile, outputFile, keys.privateKey)
  
  else:
    echo "사용법:"
    echo "  키 생성:    rsa_file_crypto -m:keygen [-k:keys.json]"
    echo "  암호화:     rsa_file_crypto -m:encrypt -i:input.txt -o:output.enc [-k:keys.json]"
    echo "  복호화:     rsa_file_crypto -m:decrypt -i:input.enc -o:output.txt [-k:keys.json]"
    echo ""
    echo "옵션:"
    echo "  -m, --mode      작업 모드 (keygen/encrypt/decrypt)"
    echo "  -i, --input     입력 파일"
    echo "  -o, --output    출력 파일"
    echo "  -k, --key       키 파일 (기본값: rsa_keys.json)"
