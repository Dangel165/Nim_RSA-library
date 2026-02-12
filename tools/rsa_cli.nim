## RSA 명령줄 도구

import nimrsa
import std/[parseopt, os]

proc printUsage() =
  echo """
╔════════════════════════════════════════╗
║   NimRSA 명령줄 도구                  ║
╚════════════════════════════════════════╝

사용법:
  rsa_cli keygen [-k:키파일] [-b:비트수]
  rsa_cli encrypt -i:입력파일 -o:출력파일 [-k:키파일]
  rsa_cli decrypt -i:입력파일 -o:출력파일 [-k:키파일]

명령어:
  keygen      새 RSA 키 쌍 생성
  encrypt     파일 암호화
  decrypt     파일 복호화

옵션:
  -k, --key       키 파일 경로 (기본값: rsa_keys.json)
  -i, --input     입력 파일
  -o, --output    출력 파일
  -b, --bits      키 비트 크기 (기본값: 16)
  -h, --help      도움말 표시

예제:
  rsa_cli keygen -k:my_keys.json -b:20
  rsa_cli encrypt -i:secret.txt -o:secret.enc -k:my_keys.json
  rsa_cli decrypt -i:secret.enc -o:decrypted.txt -k:my_keys.json
"""

proc main() =
  var
    command = ""
    keyFile = "rsa_keys.json"
    inputFile = ""
    outputFile = ""
    bits = 16
  
  # 명령어 파싱
  var p = initOptParser()
  if p.kind == cmdArgument:
    command = p.key
    p.next()
  
  # 옵션 파싱
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case p.key
      of "k", "key": keyFile = p.val
      of "i", "input": inputFile = p.val
      of "o", "output": outputFile = p.val
      of "b", "bits": bits = parseInt(p.val)
      of "h", "help":
        printUsage()
        quit(0)
    of cmdArgument:
      if command == "":
        command = p.key
  
  # 명령어 실행
  case command
  of "keygen":
    echo "RSA 키 생성 중 (", bits, "비트)..."
    let keys = generateKeyPair(bits, verbose = true)
    saveKeys(keys, keyFile)
    echo ""
    echo "✓ 키 저장 완료: ", keyFile
  
  of "encrypt":
    if inputFile == "" or outputFile == "":
      echo "✗ 오류: 입력 파일과 출력 파일을 지정해주세요"
      printUsage()
      quit(1)
    
    if not fileExists(keyFile):
      echo "✗ 오류: 키 파일을 찾을 수 없습니다: ", keyFile
      quit(1)
    
    if not fileExists(inputFile):
      echo "✗ 오류: 입력 파일을 찾을 수 없습니다: ", inputFile
      quit(1)
    
    echo "키 로드 중: ", keyFile
    let keys = loadKeys(keyFile)
    
    echo "파일 암호화 중: ", inputFile
    encryptFile(inputFile, outputFile, keys.publicKey)
    
    echo "✓ 암호화 완료: ", outputFile
  
  of "decrypt":
    if inputFile == "" or outputFile == "":
      echo "✗ 오류: 입력 파일과 출력 파일을 지정해주세요"
      printUsage()
      quit(1)
    
    if not fileExists(keyFile):
      echo "✗ 오류: 키 파일을 찾을 수 없습니다: ", keyFile
      quit(1)
    
    if not fileExists(inputFile):
      echo "✗ 오류: 입력 파일을 찾을 수 없습니다: ", inputFile
      quit(1)
    
    echo "키 로드 중: ", keyFile
    let keys = loadKeys(keyFile)
    
    echo "파일 복호화 중: ", inputFile
    decryptFile(inputFile, outputFile, keys.privateKey)
    
    echo "✓ 복호화 완료: ", outputFile
  
  else:
    if command == "":
      echo "✗ 오류: 명령어를 지정해주세요"
    else:
      echo "✗ 오류: 알 수 없는 명령어: ", command
    printUsage()
    quit(1)

when isMainModule:
  main()
