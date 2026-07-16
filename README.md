## Gravit Server

CS(Computer Science) 학습 보조 서비스의 백엔드 서버입니다.

IT 취준생이 CS 핵심 개념을 반복 학습할 수 있도록 돕는 플랫폼을 지향합니다.

<br>

## 기술 스택

| 분류 | 기술 |
|------|------|
| Language | Java 21 |
| Framework | Spring Boot 3.5.11 |
| Build | Gradle 8.14.2 |
| Database | PostgreSQL, JPA, Flyway |
| Cache | Redis |
| Security | Spring Security, OAuth2 (Google / Kakao / Naver), JWT |
| Notification | Firebase Cloud Messaging (FCM), Spring Mail |
| API Docs | springdoc-openapi (Swagger UI) |
| Test | JUnit 5, AssertJ, Testcontainers, H2 |
| Monitoring | Actuator, Micrometer, Prometheus |
| Etc | Spring Retry, Lombok |

<br>

## 빌드 & 실행

```bash
./gradlew build      # 빌드 (Flyway validate 포함)
./gradlew test       # 테스트
./gradlew bootRun    # 로컬 실행 (Docker Compose 로 PostgreSQL, Redis 필요)
```

<br>

## 디렉토리 구조

각 도메인은 `Controller → (Facade) → Service → Repository` 레이어 구조를 따릅니다.

```
gravit/code
│
├── global              # 공통 설정, 예외, 필터, 이벤트
├── security            # Spring Security 설정, JWT 필터
├── auth                # OAuth 인증, 토큰 발급
│
├── user                # 사용자 관리
├── friend              # 팔로우 / 팔로잉
├── social              # 소셜 피드, 유저 추천
│
├── chapter             # 챕터 (최상위 학습 단위)
├── unit                # 유닛 (챕터 하위 학습 단위)
├── lesson              # 레슨 (유닛 하위 학습 단위)
├── problem             # 문제
├── option              # 객관식 선택지
├── answer              # 주관식 정답
├── csnote              # CS 개념 노트
│
├── learning            # 학습 진행도, 연속 학습
├── dailyLearningRecord # 일별 / 주간 학습 기록
├── bookmark            # 문제 북마크
├── wrongAnsweredNote   # 오답 노트
├── mission             # 미션
├── badge               # 뱃지
│
├── league              # 리그
├── userLeague          # 사용자별 리그 정보
├── userLeagueHistory   # 리그 이력
├── season              # 시즌 관리, 배치
│
├── notification        # 알림 발송, 알림 인박스
├── fcm                 # FCM 푸시 토큰 관리
├── notice              # 공지사항
├── report              # 신고
│
├── admin               # 관리자 기능
├── version             # 클라이언트 앱 버전 관리
└── test                # QA 용 테스트 데이터 초기화
```

<br/>

## Team

| <img src="https://avatars.githubusercontent.com/u/146558936?v=4" width="130" height="130"> | <img src="https://avatars.githubusercontent.com/u/115551339?v=4" width="130" height="130"> | <img src="https://avatars.githubusercontent.com/u/155729481?v=4" width="130" height="130"> |
| :---: | :---: | :---: |
| [xunxxoie](https://github.com/xunxxoie) | [sukangpunch](https://github.com/sukangpunch) | [Jungseokhwan](https://github.com/Jungseokhwan) |
