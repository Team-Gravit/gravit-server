---
description: 프로젝트 디렉토리 구조. 새 파일을 생성하거나 패키지 위치를 결정할 때 참조
paths:
  - "src/main/java/**/*.java"
---

# 프로젝트 구조

```
src/main/java/gravit/code/
├── global/              # 공통 설정, 예외, 어노테이션, 필터/인터셉터, 재시도 큐(event/retry), 유틸
├── security/            # Spring Security 설정, JWT 필터
├── auth/                # OAuth 인증, 토큰 발급
│
├── chapter/             # 챕터 (최상위 학습 단위)
├── unit/                # 유닛 (챕터 하위)
├── lesson/              # 레슨 (유닛 하위), 제출 기록
├── problem/             # 문제
├── option/              # 문제 선택지(객관식)
├── answer/              # 정답(주관식)
│
├── learning/            # 학습 진행도, 연속 학습
├── dailyLearningRecord/ # 일일 학습 기록, 주간 리포트
├── bookmark/            # 문제 북마크
├── wrongAnsweredNote/   # 오답 노트
├── csnote/              # CS 노트
├── interview/           # AI 면접 세션, 세션 주제, 답안, 스택 선택지
├── interviewQuestion/   # 면접 문제와 핵심 개념, 주제 태그, 난이도
├── interviewFeedback/   # 면접 채점 결과, LLM 채점 판정 연동
│
├── league/              # 리그
├── userLeague/          # 사용자별 리그 정보, 리그 랭킹
├── userLeagueHistory/   # 리그 이력
├── season/              # 시즌 관리, 배치
├── mission/             # 미션
│
├── friend/              # 팔로우/팔로잉
├── social/              # 소셜 피드, 유저 추천, 축하
│
├── user/                # 사용자 관리
├── notification/        # 인앱 알림
├── fcm/                 # FCM 토큰, 푸시 메시지
├── notice/              # 공지사항
├── inquiry/             # 문의/답변
├── report/              # 신고
│
├── admin/               # 관리자 기능
├── version/             # 앱 버전 관리
└── test/                # QA 전용 API (시나리오 세팅, 데이터 정리, 알림 생성, 면접 채점 수동 호출)
```

## 도메인 패키지 내부 구조

```
{domain}/
├── controller/
│   ├── {Domain}Controller.java
│   └── docs/
│       └── {Domain}ControllerDocs.java   # Swagger 문서 인터페이스
├── service/
│   ├── {Domain}Service.java              # 조회/변경 분리 시 {Domain}QueryService, {Domain}CommandService (선택)
│   └── port/                             # 인프라 구현을 가리는 인터페이스, 구현은 infrastructure/ (선택)
├── repository/
│   ├── {Domain}Repository.java           # JPA Repository 인터페이스
│   ├── custom/                           # 커스텀 조회 인터페이스 + JdbcTemplate Impl (선택)
│   ├── sql/                              # custom/ Impl이 쓰는 SQL 상수 (선택)
│   └── strategy/                         # 조회 조건별 쿼리 전략 (선택)
├── domain/
│   └── {Domain}.java                     # Entity
└── dto/
    ├── request/
    ├── response/
    ├── internal/                         # 레이어 간 내부 전달용, 쿼리 프로젝션 (선택)
    └── event/                            # 도메인 이벤트 record (선택)
```

필요할 때만 추가하는 선택적 하위 패키지:

- `facade/` - 여러 도메인 Service를 조합할 때 (`@Facade`)
- `listener/` - 이벤트 리스너
- `support/`, `factory/`, `strategy/`, `policy/` - 도메인 보조 로직
- `batch/`, `scheduler/` - 배치, 스케줄
- `infrastructure/` - 외부 연동, `service/port/` 구현, 재시도 큐 처리 대상(`*RetryTarget`)
- `config/` - 도메인 전용 설정과 props

`test/`는 도메인 구조를 따르지 않는다. `test/{기능}/` 아래에 QA 컨트롤러와 `docs/`를 둔다.
