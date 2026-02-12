# NimRSA 

Nim 언어로 작성된 프로덕션 레벨의 RSA 암호화 라이브러리입니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nim Version](https://img.shields.io/badge/nim-%3E%3D1.6.0-blue.svg)](https://nim-lang.org)

## 주요 기능

- 🔐 2048/4096비트 RSA 암호화 지원
- 🛡️ OAEP & PKCS#1 v1.5 패딩 방식
- ⚡ CRT 최적화 
- 🔧 간단한 API

## 설치 방법

### Nimble로 설치 (권장)

```bash
nimble install nimrsa
```

### 소스에서 설치

```bash
git clone https://github.com/yourusername/nimrsa.git
cd nimrsa
nimble install
```

## 빠른 시작

```nim
import nimrsa

# 2048비트 키 생성
let keys = generateKeyPair(2048)

# OAEP 패딩으로 암호화
let encrypted = encrypt("비밀 데이터", keys.publicKey, OAEP_SHA256)

# CRT 최적화로 복호화
let decrypted = decrypt(encrypted, keys.privateKey, OAEP_SHA256, useCRT = true)
```

## 사용 예제

### 1. 기본 암호화/복호화

```nim
import nimrsa

# 키 생성
let keys = generateKeyPair(2048)

# 메시지 암호화
let message = "안녕하세요!"
let encrypted = encrypt(message, keys.publicKey, OAEP_SHA256)

# 메시지 복호화
let decrypted = decrypt(encrypted, keys.privateKey, OAEP_SHA256)

echo decrypted  # "안녕하세요!"
```

### 2. 키 저장 및 불러오기

```nim
import nimrsa

# 키 생성 및 저장
let keys = generateKeyPair(2048)
saveKeys(keys, "my_keys.json")

# 나중에 키 불러오기
let loadedKeys = loadKeys("my_keys.json")
```

### 3. 파일 암호화

```nim
import nimrsa

let keys = generateKeyPair(2048)

# 파일 암호화
encryptFile("secret.txt", "secret.enc", keys.publicKey, OAEP_SHA256)

# 파일 복호화
decryptFile("secret.enc", "decrypted.txt", keys.privateKey, OAEP_SHA256)
```

### 4. 공개키만 저장/불러오기

```nim
import nimrsa

let keys = generateKeyPair(2048)

# 공개키만 저장 (배포용)
savePublicKey(keys.publicKey, "public_key.json")

# 공개키 불러오기
let pubKey = loadPublicKey("public_key.json")

# 공개키로 암호화만 가능
let encrypted = encrypt("데이터", pubKey, OAEP_SHA256)
```

## API 문서

### 키 생성

```nim
proc generateKeyPair(bits: int = 2048, verbose: bool = false, 
                     useLogger: bool = true): RSAKeyPair
```

**매개변수:**
- `bits`: 키 크기 (1024, 2048, 4096 권장)
- `verbose`: 상세 출력 여부
- `useLogger`: 로깅 사용 여부

**반환값:** RSA 키 쌍 (공개키 + 개인키)

### 암호화

```nim
proc encrypt(message: string, publicKey: RSAPublicKey, 
             padding: PaddingScheme = OAEP_SHA256): seq[byte]
```

**매개변수:**
- `message`: 암호화할 문자열
- `publicKey`: RSA 공개키
- `padding`: 패딩 방식 (OAEP_SHA256, PKCS1v15, NoPadding)

**반환값:** 암호화된 바이트 배열

### 복호화

```nim
proc decrypt(ciphertext: seq[byte], privateKey: RSAPrivateKey,
             padding: PaddingScheme = OAEP_SHA256, 
             useCRT: bool = true): string
```

**매개변수:**
- `ciphertext`: 암호화된 바이트 배열
- `privateKey`: RSA 개인키
- `padding`: 패딩 방식
- `useCRT`: CRT 최적화 사용 (4배 빠름)

**반환값:** 복호화된 문자열

### 파일 작업

```nim
# 키 저장/불러오기
proc saveKeys(keyPair: RSAKeyPair, filename: string)
proc loadKeys(filename: string): RSAKeyPair

# 공개키만 저장/불러오기
proc savePublicKey(publicKey: RSAPublicKey, filename: string)
proc loadPublicKey(filename: string): RSAPublicKey

# 파일 암호화/복호화
proc encryptFile(inputFile, outputFile: string, publicKey: RSAPublicKey,
                 padding: PaddingScheme = OAEP_SHA256)
proc decryptFile(inputFile, outputFile: string, privateKey: RSAPrivateKey,
                 padding: PaddingScheme = OAEP_SHA256, useCRT: bool = true)
```

### 유틸리티

```nim
# 16진수 변환
proc toHexString(data: seq[byte]): string
proc fromHexString(hexStr: string): seq[byte]

# Base64 변환
proc toBase64(data: seq[byte]): string
proc fromBase64(b64Str: string): seq[byte]

# 키 크기 확인
proc getKeySize(key: RSAPublicKey): int
proc getKeySize(key: RSAPrivateKey): int
```

## 패딩 방식

```nim
type PaddingScheme = enum
  NoPadding      # 패딩 없음 (비권장)
  PKCS1v15       # PKCS#1 v1.5 (호환성용)
  OAEP_SHA256    # OAEP with SHA-256 (권장)
```

**권장사항:** 프로덕션 환경에서는 `OAEP_SHA256` 사용

## 예제 실행

```bash
# 기본 예제
nim c -r examples/basic_usage.nim

# 기업용 예제 (2048비트 + OAEP + CRT)
nim c -r examples/enterprise_usage.nim

# 파일 암호화 예제
nim c -r examples/file_encryption.nim
```

또는 Nimble 태스크 사용:

```bash
nimble example      # 기본 예제
nimble enterprise   # 기업용 예제
nimble test         # 테스트 실행
```

## 에러 처리

```nim
import nimrsa

try:
  let keys = loadKeys("my_keys.json")
  let encrypted = encrypt("데이터", keys.publicKey)
  let decrypted = decrypt(encrypted, keys.privateKey)
except RSAKeyError as e:
  echo "키 오류: ", e.msg
except RSAEncryptionError as e:
  echo "암호화 오류: ", e.msg
except RSADecryptionError as e:
  echo "복호화 오류: ", e.msg
except RSAError as e:
  echo "RSA 오류: ", e.msg
```

## 로깅

```nim
import nimrsa
import std/logging

# 파일 로거 설정
var logger = newFileLogger("rsa_operations.log")
addHandler(logger)

# 모든 RSA 작업이 자동으로 로깅됨
let keys = generateKeyPair(2048)
```

## 프로젝트 구조

```
nim_rsa_library/
├── src/
│   ├── nimrsa.nim          # 메인 모듈
│   └── nimrsa/
│       ├── types.nim       # 타입 정의
│       ├── math.nim        # 수학 연산 (BigInt)
│       ├── keygen.nim      # 키 생성
│       ├── crypto.nim      # 암호화/복호화
│       ├── padding.nim     # 패딩 (OAEP, PKCS1)
│       ├── utils.nim       # 유틸리티
│       └── io.nim          # 파일 입출력
├── examples/               # 예제 코드
├── tests/                  # 테스트
└── nimrsa.nimble          # 패키지 설정
```

## 문제 해결

### Q: "bigints를 찾을 수 없습니다" 오류

```bash
nimble install bigints
```

### Q: 키 생성이 너무 느려요

- 2048비트 키는 2-5초 정도 소요됩니다
- 한 번만 생성하고 저장해서 재사용하세요
- 4096비트는 더 오래 걸립니다 (10-30초)

### Q: 암호화된 데이터가 너무 커요

- RSA는 작은 데이터 암호화용입니다
- 큰 파일은 AES + RSA 하이브리드 방식 사용 권장
- RSA로 AES 키를 암호화하고, AES로 데이터 암호화

### Q: 다른 언어와 호환되나요?

- 표준 RSA 알고리즘 사용
- OAEP, PKCS#1 v1.5 표준 패딩
- 다른 언어의 RSA 라이브러리와 호환 가능

## 라이선스

MIT License - 자유롭게 사용 가능

## 주의사항

⚠️ **보안 감사 필요**
- 이 라이브러리는 교육 및 일반 용도로 제작되었습니다
- 프로덕션 환경에서는 추가 보안 감사를 권장합니다
- 금융, 의료 등 고보안 환경에서는 전문가 검토 필요

