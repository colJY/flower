# 🌸 꽃받침 (FlowerCup)

AI 기반 꽃 사진 감성 글귀 생성 앱

## 📱 프로젝트 소개

꽃 사진을 촬영하면 AI가 사용자의 감정과 상황에 맞는 아름다운 시나 글귀를 생성해주는 Flutter 앱입니다.

### ✨ 주요 기능

- 🌺 **꽃 사진 촬영/선택**: 카메라 또는 갤러리에서 꽃 사진 선택
- 🎭 **감정 입력**: 현재 기분이나 상황을 텍스트/음성으로 입력
- 🤖 **AI 글귀 생성**: Gemini AI가 꽃과 감정에 맞는 감성적인 글 생성
- 🎨 **스타일 선택**: 시, 산문, 위로 메시지, 일기 등 다양한 스타일
- 📱 **카드 생성**: 아름다운 디자인의 카드로 생성 및 저장
- 📤 **SNS 공유**: 생성된 카드를 소셜미디어에 공유
- 🌍 **다국어 지원**: 한국어/영어 지원

### 🛠 기술 스택

- **Frontend**: Flutter
- **AI API**: Google Gemini 2.5 Flash-Lite
- **로컬 저장**: SQLite (sqflite)
- **상태 관리**: Provider
- **국제화**: flutter_localizations
- **이미지 처리**: image_picker, camera
- **음성 인식**: speech_to_text (기획됨)

### 📁 프로젝트 구조

```
lib/
├── main.dart
├── models/          # 데이터 모델
├── screens/         # 화면들
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── camera_screen.dart
│   ├── emotion_input_screen.dart
│   ├── ai_generation_screen.dart
│   ├── result_card_screen.dart
│   └── collection_screen.dart
├── services/        # API 및 로컬 저장 서비스
│   ├── gemini_service.dart
│   └── storage_service.dart
├── widgets/         # 재사용 위젯들
└── l10n/           # 다국어 지원
```

### 🎯 주요 화면 플로우

1. **스플래시** → **온보딩** → **홈**
2. **홈** → **카메라/갤러리** → **감정입력**
3. **감정입력** → **AI 생성** → **결과카드**
4. **결과카드** → **저장/공유** → **마이컬렉션**

## 🚀 실행 방법

### 환경 설정

1. **API 키 설정**
   ```bash
   cp .env.example .env
   # .env 파일에 Gemini API 키 입력
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   flutter run
   ```

### 빌드 (Android)

1. **키스토어 설정** (선택사항)
   ```bash
   cp android/key.properties.example android/key.properties
   # key.properties에 키스토어 정보 입력
   ```

2. **릴리즈 빌드**
   ```bash
   flutter build apk --release
   # 또는
   flutter build appbundle --release
   ```

## 📸 스크린샷

(스크린샷 추가 예정)

## 🎨 디자인 컨셉

- **색상**: 핑크 계열의 따뜻하고 부드러운 톤
- **컨셉**: 꽃의 자연스러운 아름다움과 감성적 경험
- **UX**: 직관적이고 간편한 사용성

## 📝 개발 노트

이 프로젝트는 AI와 사용자의 감정을 연결하는 새로운 방식의 앱을 구현하기 위해 시작되었습니다. 특히 음성 인식과 이미지 분석을 결합한 멀티모달 AI 경험을 제공합니다.

---

💡 **포트폴리오 프로젝트** - 개인 개발자의 Flutter 및 AI 통합 역량을 보여주는 프로젝트입니다.
