# 보안 설정 가이드

## 환경 변수 설정

### 1. .env 파일 생성
```bash
cp .env.example .env
```

### 2. API 키 설정
`.env` 파일에 실제 API 키를 입력하세요:
```
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

### 3. Android 키스토어 설정
```bash
cp android/key.properties.example android/key.properties
```

`android/key.properties` 파일에 실제 키스토어 정보를 입력하세요:
```
storePassword=your_actual_store_password
keyPassword=your_actual_key_password
keyAlias=your_actual_key_alias
storeFile=../../../flower.keystore
```

## 중요 사항

⚠️ **절대 커밋하지 말 것:**
- `.env` 파일
- `android/key.properties` 파일
- 키스토어 파일 (flower.keystore)

✅ **커밋해도 되는 것:**
- `.env.example` 파일
- `android/key.properties.example` 파일
- 이 가이드 문서

## Git 설정

### .gitignore에 포함된 민감 파일들:
- `/android/key.properties`
- `.env`, `.env.local`, `.env.production`, `.env.staging`
- `**/api_keys.dart`, `**/secrets.dart`

### 실수로 민감정보를 커밋한 경우:
```bash
# 최신 커밋에서 파일 제거 (커밋 전)
git rm --cached android/key.properties
git rm --cached .env

# 이미 커밋한 경우 히스토리에서 완전 제거
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch android/key.properties' --prune-empty --tag-name-filter cat -- --all
```

## 팀 협업시 주의사항

1. 새 팀원은 반드시 이 가이드를 따라 환경설정
2. API 키는 개별적으로 발급받아 사용
3. 키스토어는 팀 리더가 안전하게 공유
4. 민감정보는 Slack/Discord 등에 절대 공유 금지