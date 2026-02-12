@echo off
chcp 65001 >nul
echo ═══════════════════════════════════════════════════════════════
echo   NimRSA 라이브러리 배포 스크립트
echo   GitHub: https://github.com/Dangel165/Nim_RSA-library
echo ═══════════════════════════════════════════════════════════════
echo.

echo [1단계] Git 초기화 및 커밋
echo.

if exist .git (
    echo ⚠️ Git 저장소가 이미 존재합니다.
    echo    기존 커밋을 유지하고 새 커밋을 추가합니다.
    echo.
) else (
    echo Git 저장소 초기화 중...
    git init
    if errorlevel 1 (
        echo ❌ Git 초기화 실패!
        pause
        exit /b 1
    )
    echo ✅ Git 초기화 완료
    echo.
)

echo 모든 파일 추가 중...
git add .
if errorlevel 1 (
    echo ❌ 파일 추가 실패!
    pause
    exit /b 1
)
echo ✅ 파일 추가 완료
echo.

echo 커밋 생성 중...
git commit -m "Initial commit: NimRSA v2.0.0 - Enterprise RSA encryption library"
if errorlevel 1 (
    echo ⚠️ 커밋 실패 (이미 커밋된 상태일 수 있음)
    echo    계속 진행합니다...
)
echo.

echo ═══════════════════════════════════════════════════════════════
echo [2단계] GitHub 저장소 연결
echo ═══════════════════════════════════════════════════════════════
echo.

echo GitHub 저장소 연결 중...
git remote add origin https://github.com/Dangel165/Nim_RSA-library.git 2>nul
if errorlevel 1 (
    echo ⚠️ Remote가 이미 존재합니다. 업데이트 중...
    git remote set-url origin https://github.com/Dangel165/Nim_RSA-library.git
)
echo ✅ GitHub 저장소 연결 완료
echo.

echo 메인 브랜치 설정 중...
git branch -M main
echo ✅ 메인 브랜치 설정 완료
echo.

echo ═══════════════════════════════════════════════════════════════
echo [3단계] GitHub에 푸시
echo ═══════════════════════════════════════════════════════════════
echo.

echo GitHub에 푸시 중...
echo (GitHub 로그인이 필요할 수 있습니다)
echo.
git push -u origin main
if errorlevel 1 (
    echo.
    echo ❌ 푸시 실패!
    echo.
    echo 가능한 원인:
    echo 1. GitHub 인증 필요 (Personal Access Token 또는 SSH 키)
    echo 2. 저장소가 아직 생성되지 않음
    echo 3. 네트워크 문제
    echo.
    echo 해결 방법:
    echo 1. GitHub에서 저장소가 생성되었는지 확인
    echo    https://github.com/Dangel165/Nim_RSA-library
    echo.
    echo 2. Personal Access Token 생성:
    echo    https://github.com/settings/tokens
    echo    - repo 권한 체크
    echo    - 토큰 복사 후 비밀번호 대신 사용
    echo.
    echo 3. 다시 시도:
    echo    git push -u origin main
    echo.
    pause
    exit /b 1
)
echo ✅ GitHub 푸시 완료
echo.

echo ═══════════════════════════════════════════════════════════════
echo [4단계] 버전 태그 생성 및 푸시
echo ═══════════════════════════════════════════════════════════════
echo.

echo v2.0.0 태그 생성 중...
git tag v2.0.0 2>nul
if errorlevel 1 (
    echo ⚠️ 태그가 이미 존재합니다. 삭제 후 재생성...
    git tag -d v2.0.0
    git tag v2.0.0
)
echo ✅ 태그 생성 완료
echo.

echo 태그 푸시 중...
git push origin v2.0.0
if errorlevel 1 (
    echo ❌ 태그 푸시 실패!
    pause
    exit /b 1
)
echo ✅ 태그 푸시 완료
echo.

echo ═══════════════════════════════════════════════════════════════
echo   배포 완료! 🎉
echo ═══════════════════════════════════════════════════════════════
echo.
echo ✅ 코드가 GitHub에 업로드되었습니다!
echo ✅ v2.0.0 태그가 생성되었습니다!
echo.
echo 다음 단계:
echo.
echo 1. GitHub Release 생성 (필수!)
echo    https://github.com/Dangel165/Nim_RSA-library/releases/new
echo.
echo    - Choose a tag: v2.0.0
echo    - Release title: NimRSA v2.0.0 - Enterprise RSA Library
echo    - Description: (아래 내용 복사)
echo.
echo    ───────────────────────────────────────────────────
echo    # NimRSA v2.0.0
echo.
echo    Enterprise-grade RSA encryption library for Nim.
echo.
echo    ## Features
echo    - 🔐 2048/4096-bit RSA encryption
echo    - 🛡️ OAEP ^& PKCS#1 v1.5 padding
echo    - ⚡ CRT optimization (4x faster decryption)
echo    - 📦 Pure Nim implementation
echo.
echo    ## Installation
echo    ```bash
echo    nimble install https://github.com/Dangel165/Nim_RSA-library
echo    ```
echo.
echo    ## Quick Start
echo    ```nim
echo    import nimrsa
echo    let keys = generateKeyPair(2048)
echo    let encrypted = encrypt("Secret", keys.publicKey, OAEP_SHA256)
echo    let decrypted = decrypt(encrypted, keys.privateKey, OAEP_SHA256)
echo    ```
echo    ───────────────────────────────────────────────────
echo.
echo 2. 사용자 설치 방법:
echo    nimble install https://github.com/Dangel165/Nim_RSA-library
echo.
echo 3. 홍보 (선택사항):
echo    - Nim Forum: https://forum.nim-lang.org/
echo    - Nim Discord: https://discord.gg/nim
echo    - Reddit: https://reddit.com/r/nim
echo.
echo ═══════════════════════════════════════════════════════════════

pause
