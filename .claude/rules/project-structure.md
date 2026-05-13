---
description: 프로젝트 디렉토리 구조. 새 파일을 생성하거나 패키지 위치를 결정할 때 참조
paths:
  - "src/main/java/**/*.java"
---

# 프로젝트 구조

```
src/main/java/gravit/code/
├── global/            # 공통 설정, 예외, 어노테이션, 필터, 이벤트
├── security/          # Spring Security 설정, JWT 필터
├── auth/              # OAuth 인증, 토큰 발급
├── user/              # 사용자 관리
├── chapter/           # 챕터 (최상위 학습 단위)
├── unit/              # 유닛 (챕터 하위)
├── lesson/            # 레슨 (유닛 하위)
├── problem/           # 문제
├── answer/            # 정답
├── learning/          # 학습 진행도, 연속 학습
├── bookmark/          # 문제 북마크
├── wrongAnsweredNote/ # 오답 노트
├── csnote/            # CS 노트
├── league/            # 리그
├── userLeague/        # 사용자별 리그 정보
├── userLeagueHistory/ # 리그 이력
├── season/            # 시즌 관리, 배치
├── mission/           # 미션
├── badge/             # 뱃지
├── friend/            # 팔로우/팔로잉
├── notice/            # 공지사항
├── report/            # 신고
├── admin/             # 관리자 기능
└── test/              # 테스트 데이터 초기화 (QA용)
```

## 도메인 패키지 내부 구조

```
{domain}/
├── controller/
│   ├── {Domain}Controller.java
│   └── docs/
│       └── {Domain}Docs.java
├── facade/
│   └── {Domain}Facade.java
├── service/
│   ├── {Domain}QueryService.java
│   └── {Domain}CommandService.java
├── repository/
│   └── {Domain}Repository.java
├── domain/
│   └── {Domain}.java
└── dto/
    ├── request/
    ├── response/
    └── internal/
```