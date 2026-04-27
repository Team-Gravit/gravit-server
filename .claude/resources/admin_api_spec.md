# Gravit 백오피스 API 명세서

> 본 문서는 Gravit 백오피스(Admin) 클라이언트가 사용하는 모든 백엔드 API의 통합 명세입니다.
> 와이어프레임 명세서(`01_gravit_admin_wireframe_spec.md`)의 7장과 정합성을 유지하며, 백엔드 팀이 단독으로 구현 가능한 수준으로 작성되었습니다.

---

## 목차

1. [개요](#1-개요)
2. [공통 사양](#2-공통-사양)
3. [인증 (Auth)](#3-인증-auth)
4. [대시보드 (Dashboard)](#4-대시보드-dashboard)
5. [유저 (Users)](#5-유저-users)
6. [신고 (Reports)](#6-신고-reports)
7. [학습 컨텐츠 — Prod (Chapters / Units / Lessons / Problems)](#7-학습-컨텐츠--prod-chapters--units--lessons--problems)
8. [스테이징 (Staging)](#8-스테이징-staging)
9. [공지 (Notices)](#9-공지-notices)
10. [백엔드 추가/확장 요청 사항 요약](#10-백엔드-추가확장-요청-사항-요약)
11. [백엔드 결정 사항 (디자인 단계 미확정)](#11-백엔드-결정-사항-디자인-단계-미확정)

---

## 1. 개요

### 1-1. 사용 클라이언트

- **Gravit 백오피스 (Admin)**: 내부 운영자(수십 명)용 관리 도구
- 데스크탑 전용 웹 애플리케이션
- 운영 업무: 유저 관리, 신고 처리, 학습 컨텐츠 관리, 스테이징 검수/promote, 공지 관리

### 1-2. 본 문서의 범위

| 포함 | 제외 |
|---|---|
| 백오피스가 호출하는 모든 엔드포인트 | 사용자 앱(end user app)이 호출하는 엔드포인트 |
| 요청/응답 핵심 필드 및 타입 | 데이터베이스 스키마 |
| HTTP 상태 코드 | 인프라 구성 (배포, CDN 등) |
| 권한·인증 정책 | 외부 OAuth provider 연동 상세 |
| 백엔드 추가/확장 요청 사항 | 토큰 만료 시간, refresh/logout 엔드포인트 (백엔드 결정) |

---

## 2. 공통 사양

### 2-1. Base URL

```
{API_HOST}/api/v1/admin
```

### 2-2. 인증

- **방식**: Bearer Token (JWT)
- **헤더**: `Authorization: Bearer {accessToken}`
- **권한**: 모든 엔드포인트는 `role=ADMIN` 토큰 요구. `role=USER` 토큰으로 호출 시 `403 Forbidden` 응답

#### 인증 미통과 응답

| 상황 | HTTP 상태 |
|---|---|
| Authorization 헤더 누락 또는 잘못된 형식 | `401 Unauthorized` |
| 토큰 만료 | `401 Unauthorized` |
| 토큰은 유효하나 `role=USER` | `403 Forbidden` |

### 2-3. Content Type

- 요청 body가 있는 경우: `Content-Type: application/json`
- 응답 body: `Content-Type: application/json`

### 2-4. 페이지네이션 응답 공통 구조

```json
{
  "page": 1,
  "totalPages": 10,
  "hasNextPage": true,
  "content": [ /* 리소스 배열 */ ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `page` | number | 현재 페이지 번호 (1부터 시작) |
| `totalPages` | number | 전체 페이지 수 |
| `hasNextPage` | boolean | 다음 페이지 존재 여부 |
| `content` | array | 리소스 배열 |

#### 공통 쿼리 파라미터

| 파라미터 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `page` | number | 1 | 요청 페이지 번호 (1부터 시작) |

> **페이지 크기**: 모든 목록 API의 페이지 크기는 **20행 고정** (서버 측 고정). 클라이언트에서 변경 불가.

### 2-5. 에러 응답

> ⚠️ **백엔드 결정 사항**: 통일된 에러 응답 본문 포맷은 백엔드 팀이 결정합니다. 본 문서에서는 HTTP 상태 코드만 명시합니다.

#### 권장 응답 본문 포맷 (참고)

클라이언트의 토스트 메시지 표시를 위해 최소한 다음 필드가 표준화되면 좋습니다.

```json
{
  "code": "STRING_CODE",
  "message": "사용자에게 표시 가능한 메시지"
}
```

#### 공통 HTTP 상태 코드

| 상태 | 의미 |
|---|---|
| `200 OK` | 조회/수정 성공 |
| `201 Created` | 생성 성공 |
| `204 No Content` | 삭제 성공 (응답 body 없음) |
| `400 Bad Request` | 요청 파라미터/body 검증 실패 |
| `401 Unauthorized` | 인증 실패 |
| `403 Forbidden` | 권한 부족 |
| `404 Not Found` | 리소스 없음 |
| `409 Conflict` | 상태 전이 위반 등 |
| `500 Internal Server Error` | 서버 내부 오류 |

### 2-6. 권한 정책

| 엔드포인트 군 | 요구 권한 |
|---|---|
| `POST /auth/login` | 인증 불필요 (로그인 시 발급) |
| 그 외 모든 엔드포인트 | `role=ADMIN` |

---

## 3. 인증 (Auth)

### 3-1. POST `/auth/login`

OAuth provider(Google/Kakao/Naver)에서 받은 idToken으로 백오피스 로그인.

#### 요청

```http
POST /api/v1/admin/auth/login
Content-Type: application/json
```

```json
{
  "providerId": "GOOGLE",
  "idToken": "..."
}
```

| 필드 | 타입 | 필수 | 값 |
|---|---|---|---|
| `providerId` | string | Y | `GOOGLE` \| `KAKAO` \| `NAVER` |
| `idToken` | string | Y | OAuth provider에서 발급한 idToken |

#### 응답

##### 200 OK

```json
{
  "accessToken": "...",
  "refreshToken": "..."
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `accessToken` | string | 백오피스 API 호출용 JWT |
| `refreshToken` | string | accessToken 재발급용 토큰 |

##### 401 / 403

| 상황 | HTTP 상태 |
|---|---|
| idToken 검증 실패 | `401 Unauthorized` |
| 인증된 유저의 `role`이 `USER` (백오피스 접근 권한 없음) | `401` 또는 `403` (백엔드 결정) |

> **클라이언트 동작**: 401/403 응답 시 로그인 카드 하단에 "백오피스 접근 권한이 없습니다." 에러 메시지 표시.

### 3-2. 추가 엔드포인트 (백엔드 결정)

> ⚠️ 다음 엔드포인트는 명세에 정의되지 않았으며 백엔드 결정 사항입니다.

- `POST /auth/refresh` — accessToken 만료 시 refreshToken으로 재발급
- `POST /auth/logout` — refreshToken 무효화

운영 시점에 클라이언트가 이 엔드포인트를 필요로 하므로 백엔드 팀의 결정 후 추가 명세가 필요합니다.

---

## 4. 대시보드 (Dashboard)

### 4-1. GET `/dashboard/summary`

대시보드 화면의 위젯 3개에 표시할 카운트.

> **신규 추가 요청 (디자인 단계)**: 본 엔드포인트는 와이어프레임 설계 과정에서 신규 요청된 항목입니다.

#### 요청

```http
GET /api/v1/admin/dashboard/summary
Authorization: Bearer {accessToken}
```

#### 응답 — 200 OK

```json
{
  "totalUsers": 12345,
  "pendingLabelsCount": 8,
  "unresolvedReportsCount": 24
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `totalUsers` | number | `status IN (ACTIVE, SUSPENDED)`인 유저 수 (`DELETED` 제외) |
| `pendingLabelsCount` | number | `status = PENDING`인 스테이징 라벨 수 |
| `unresolvedReportsCount` | number | `isResolved = false`인 신고 수 |

> **호출 시점**: 대시보드 페이지 진입 시 1회만 호출. 자동 갱신 없음.

---

## 5. 유저 (Users)

### 5-1. GET `/users` — 유저 목록

#### 요청

```http
GET /api/v1/admin/users?page={n}&search={q}&status={s}&role={r}
Authorization: Bearer {accessToken}
```

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `page` | number | N | 1 | 페이지 번호 |
| `search` | string | N | - | email/nickname/handle 검색 키워드 |
| `status` | string | N | - | `ACTIVE` \| `SUSPENDED` \| `DELETED` (미지정 시 전체) |
| `role` | string | N | - | `ADMIN` \| `USER` (미지정 시 전체) |

> **확장 요청 (디자인 단계)**: `search`, `status`, `role` 쿼리는 디자인 단계에서 추가 요청된 항목입니다.

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 25,
  "hasNextPage": true,
  "content": [
    {
      "userId": 1001,
      "email": "user@example.com",
      "nickname": "홍길동",
      "handle": "gildong",
      "role": "USER",
      "status": "ACTIVE",
      "createdAt": "2026-01-15"
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `userId` | number | 유저 고유 ID |
| `email` | string | 이메일 |
| `nickname` | string | 닉네임 |
| `handle` | string | 핸들 (`@` prefix 없이 순수 값) |
| `role` | string | `ADMIN` \| `USER` |
| `status` | string | `ACTIVE` \| `SUSPENDED` \| `DELETED` |
| `createdAt` | string (date) | 가입일 (`YYYY-MM-DD`) |

### 5-2. GET `/users/{userId}` — 유저 상세

#### 요청

```http
GET /api/v1/admin/users/{userId}
Authorization: Bearer {accessToken}
```

#### 응답 — 200 OK

```json
{
  "userId": 1001,
  "email": "user@example.com",
  "nickname": "홍길동",
  "handle": "gildong",
  "profileImgNumber": 3,
  "role": "USER",
  "status": "ACTIVE",
  "level": 12,
  "createdAt": "2026-01-15"
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `profileImgNumber` | number | 프리셋 이미지 매핑용 정수 (사용자 앱과 동일 매핑 사용) |
| `level` | number | 학습 레벨 |
| (나머지 필드는 5-1과 동일) | | |

#### 404 Not Found

해당 `userId`의 유저가 존재하지 않을 때.

### 5-3. PATCH `/users/{userId}/status` — 유저 상태 변경

#### 요청

```http
PATCH /api/v1/admin/users/{userId}/status
Authorization: Bearer {accessToken}
Content-Type: application/json
```

```json
{ "status": "SUSPENDED" }
```

| 필드 | 타입 | 필수 | 값 |
|---|---|---|---|
| `status` | string | Y | `ACTIVE` \| `SUSPENDED` \| `DELETED` |

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 (변경된 유저 객체 반환 권장) |
| `400 Bad Request` | 잘못된 status 값 |
| `404 Not Found` | 유저 없음 |

> **자기 자신 보호**: 본인 계정 상태 변경 가능. 백엔드는 별도 차단 로직 없음. 운영 리스크는 클라이언트 confirm 모달로 안내.

### 5-4. PATCH `/users/{userId}/role` — 유저 역할 변경

#### 요청

```http
PATCH /api/v1/admin/users/{userId}/role
Content-Type: application/json
```

```json
{ "role": "ADMIN" }
```

| 필드 | 타입 | 필수 | 값 |
|---|---|---|---|
| `role` | string | Y | `ADMIN` \| `USER` |

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 잘못된 role 값 |
| `404 Not Found` | 유저 없음 |

> **자기 자신 보호**: 본인 계정의 role 변경 가능 (USER로 변경 시 즉시 백오피스 접근 권한 상실). 백엔드 차단 로직 없음.

---

## 6. 신고 (Reports)

### 6-1. GET `/reports` — 신고 목록

#### 요청

```http
GET /api/v1/admin/reports?page={n}&reportType={t}&isResolved={b}
Authorization: Bearer {accessToken}
```

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `page` | number | N | 1 | 페이지 번호 |
| `reportType` | string | N | - | `TYPO_ERROR` \| `CONTENT_ERROR` \| `ANSWER_ERROR` \| `OTHER_ERROR` |
| `isResolved` | boolean | N | - | `true` \| `false` (미지정 시 전체) |

> **확장 요청 (디자인 단계)**: `reportType`, `isResolved` 쿼리는 디자인 단계에서 추가 요청된 항목입니다.
> **클라이언트 기본 필터**: 클라이언트는 진입 시 `isResolved=false`(미해결)를 기본값으로 호출합니다.

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 5,
  "hasNextPage": true,
  "content": [
    {
      "reportId": 1024,
      "reportType": "TYPO_ERROR",
      "problemId": 512,
      "isResolved": false,
      "submittedAt": "2026-04-23T14:32:00Z"
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `reportId` | number | 신고 고유 ID |
| `reportType` | string | 신고 유형 |
| `problemId` | number | 신고 대상 문제 ID |
| `isResolved` | boolean | 처리 여부 |
| `submittedAt` | string (datetime) | 제출 일시 (ISO 8601) |

### 6-2. GET `/reports/{reportId}` — 신고 상세

#### 요청

```http
GET /api/v1/admin/reports/{reportId}
Authorization: Bearer {accessToken}
```

#### 응답 — 200 OK

```json
{
  "reportId": 1024,
  "reportType": "TYPO_ERROR",
  "problemId": 512,
  "content": "두 번째 줄에서 '알고리듬'이 '알고리즘'으로 되어있습니다. 오타로 보입니다.",
  "isResolved": false,
  "submittedAt": "2026-04-23T14:32:00Z"
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `content` | string | 신고 내용 (유저가 작성한 텍스트) |
| (나머지는 6-1과 동일) | | |

> **신고자 정보**: 클라이언트는 신고자 정보를 표시하지 않습니다. 응답에 reporter 필드가 있는지 여부는 백엔드 결정 사항이며, 있어도 클라이언트는 미사용.

### 6-3. PATCH `/reports/{reportId}/status` — 처리 상태 변경

#### 요청

```http
PATCH /api/v1/admin/reports/{reportId}/status
Content-Type: application/json
```

```json
{ "isResolved": true }
```

| 필드 | 타입 | 필수 | 값 |
|---|---|---|---|
| `isResolved` | boolean | Y | `true` \| `false` |

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `404 Not Found` | 신고 없음 |

---

## 7. 학습 컨텐츠 — Prod (Chapters / Units / Lessons / Problems)

### 7-1. GET `/chapters` — 챕터 목록

#### 요청

```http
GET /api/v1/admin/chapters?page={n}
```

| 파라미터 | 타입 | 필수 | 기본값 |
|---|---|---|---|
| `page` | number | N | 1 |

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 2,
  "hasNextPage": true,
  "content": [
    {
      "chapterId": 1,
      "title": "자료구조 기초",
      "description": "배열, 리스트, 스택, 큐, 트리, 그래프 등 기본 자료구조"
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `chapterId` | number | 챕터 ID |
| `title` | string | 제목 |
| `description` | string | 설명 |

### 7-2. GET `/chapters/{chapterId}` — 챕터 상세

#### 응답 — 200 OK

```json
{
  "chapterId": 1,
  "title": "자료구조 기초",
  "description": "배열, 리스트, 스택, 큐, 트리, 그래프 등 기본 자료구조",
  "unitCount": 12
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `unitCount` | number | 이 챕터에 속한 유닛 수 |

> **추가 요청 (디자인 단계)**: `unitCount` 필드는 와이어프레임 6-5-2 "유닛 (총 N개)" 표시를 위해 추가 요청된 항목입니다.

### 7-3. GET `/chapters/{chapterId}/stats` — 챕터 풀이 현황

#### 응답 — 200 OK

```json
{
  "units": [
    {
      "unitId": 12,
      "unitTitle": "배열",
      "averageProgress": 78,
      "participantCount": 342
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `unitId` | number | 유닛 ID |
| `unitTitle` | string | 유닛 제목 |
| `averageProgress` | number | 평균 진행률. **단위는 0~100 퍼센트로 가정** (백엔드 확인 필요) |
| `participantCount` | number | 참여 인원 |

> ⚠️ **백엔드 확인 필요**: `averageProgress`의 단위가 `0~1`인지 `0~100`인지 명세에 정의되지 않았습니다. 클라이언트는 `0~100`으로 가정합니다.

### 7-4. PATCH `/chapters/{chapterId}` — 챕터 수정

```json
{
  "title": "자료구조 기초",
  "description": "..."
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `title` | string | N | 제목 |
| `description` | string | N | 설명 |

> **부분 업데이트**: 제공된 필드만 수정. 미제공 필드는 변경되지 않음.

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 (예: title 빈 값) |
| `404 Not Found` | 챕터 없음 |

### 7-5. GET `/chapters/{chapterId}/units` — 유닛 목록

#### 요청

```http
GET /api/v1/admin/chapters/{chapterId}/units?page={n}
```

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 1,
  "hasNextPage": false,
  "content": [
    {
      "unitId": 12,
      "title": "배열",
      "description": "배열의 개념과 활용"
    }
  ]
}
```

### 7-6. GET `/units/{unitId}` — 유닛 상세

#### 응답 — 200 OK

```json
{
  "unitId": 12,
  "chapterId": 1,
  "title": "배열",
  "description": "배열의 개념과 활용",
  "lessonCount": 5
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `lessonCount` | number | 이 유닛에 속한 레슨 수 |

> **추가 요청 (디자인 단계)**: `lessonCount` 필드는 와이어프레임 6-5-3 "레슨 (총 N개)" 표시를 위해 추가 요청된 항목입니다.

### 7-7. PATCH `/units/{unitId}` — 유닛 수정

```json
{
  "title": "배열",
  "description": "..."
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `title` | string | N | 제목 |
| `description` | string | N | 설명 |

### 7-8. GET `/units/{unitId}/lessons` — 레슨 목록

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 1,
  "hasNextPage": false,
  "content": [
    {
      "lessonId": 901,
      "title": "배열의 정의"
    }
  ]
}
```

> **note**: 레슨에는 `description` 필드 없음.

### 7-9. GET `/lessons/{lessonId}` — 레슨 상세

#### 응답 — 200 OK

```json
{
  "lessonId": 901,
  "unitId": 12,
  "title": "배열의 정의",
  "problemCount": 6
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `problemCount` | number | 이 레슨에 속한 문제 수 |

> **추가 요청 (디자인 단계)**: `problemCount` 필드는 와이어프레임 6-5-4 "문제 (총 N개)" 표시를 위해 추가 요청된 항목입니다.

### 7-10. PATCH `/lessons/{lessonId}` — 레슨 수정

```json
{ "title": "배열의 정의" }
```

| 필드 | 타입 | 필수 |
|---|---|---|
| `title` | string | N |

> **note**: 레슨은 `title`만 수정 가능 (description 필드 자체가 없음).

### 7-11. GET `/lessons/{lessonId}/problems` — 문제 목록

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 1,
  "hasNextPage": false,
  "content": [
    {
      "problemId": 512,
      "problemType": "OBJECTIVE",
      "instruction": "다음 중 배열의 특징이 아닌 것을 고르시오."
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `problemType` | string | `OBJECTIVE` \| `SUBJECTIVE` |
| `instruction` | string | 지시문 |

### 7-12. GET `/problems/{problemId}` — 문제 상세

#### 응답 — 200 OK (객관식 예시)

```json
{
  "problemId": 512,
  "lessonId": 901,
  "problemType": "OBJECTIVE",
  "instruction": "다음 중 배열의 특징이 아닌 것을 고르시오.",
  "content": "배열은 동일한 데이터 타입의 원소들을...",
  "options": [
    {
      "optionId": 1,
      "content": "인덱스로 접근 가능",
      "explanation": "배열은 O(1) 시간에 접근 가능합니다.",
      "isAnswer": false
    }
  ]
}
```

#### 응답 — 200 OK (주관식 예시)

```json
{
  "problemId": 513,
  "lessonId": 901,
  "problemType": "SUBJECTIVE",
  "instruction": "배열의 인덱스가 시작하는 숫자를 입력하시오.",
  "content": "...",
  "answers": [
    {
      "answerId": 1,
      "content": "0",
      "explanation": "배열의 인덱스는 0부터 시작합니다."
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `options` | array | 객관식만. 정확히 4개 |
| `options[].isAnswer` | boolean | 정답 여부. 4개 중 정확히 1개만 `true` |
| `answers` | array | 주관식만. 1개 이상 |

### 7-13. PATCH `/problems/{problemId}/objective` — 객관식 문제 수정

```json
{
  "instruction": "...",
  "content": "...",
  "options": [
    { "optionId": 1, "content": "...", "explanation": "...", "isAnswer": false },
    { "optionId": 2, "content": "...", "explanation": "...", "isAnswer": true },
    { "optionId": 3, "content": "...", "explanation": "...", "isAnswer": false },
    { "optionId": 4, "content": "...", "explanation": "...", "isAnswer": false }
  ]
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `instruction` | string | N | 지시문 |
| `content` | string | N | 본문 |
| `options` | array | N | 정확히 4개. 제공 시 전체 교체 |

> **PATCH 동작**: prod 객관식은 `options` 배열을 **전체 교체**. 4개 고정 도메인 제약 유지.

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 (옵션 4개 아님, 정답 0개 또는 2개 이상 등) |
| `404 Not Found` | 문제 없음 |

### 7-14. PATCH `/problems/{problemId}/subjective` — 주관식 문제 수정

```json
{
  "instruction": "...",
  "content": "...",
  "answers": [
    { "answerId": 1, "content": "0", "explanation": "..." },
    { "answerId": 2, "content": "zero", "explanation": "..." }
  ]
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `instruction` | string | N | 지시문 |
| `content` | string | N | 본문 |
| `answers` | array | N | 1개 이상. 제공 시 전체 교체 (가정) |

> ⚠️ **백엔드 확인 필요**: `answers` 배열의 PATCH 동작이 **전체 교체**인지 확인 필요. 클라이언트는 전체 교체로 가정하여 추가/삭제 UI를 구현합니다.

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 (정답 0개) |
| `404 Not Found` | 문제 없음 |

---

## 8. 스테이징 (Staging)

> **도메인 컨텍스트**: 한 라벨 = 한 사이클 (레슨 1개 + 문제 6개). LLM 파이프라인이 자동 생성하여 staging 테이블에 적재 → 운영자 검수 → `PENDING → COMPLETED` 전환 시 prod 테이블로 INSERT 실행 (가장 위험한 액션, 되돌리기 어려움).

### 8-1. GET `/staging/labels` — 스테이징 라벨 목록

#### 요청

```http
GET /api/v1/admin/staging/labels?page={n}&status={s}
Authorization: Bearer {accessToken}
```

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| `page` | number | N | 1 | 페이지 번호 |
| `status` | string | N | - | `PENDING` \| `COMPLETED` (미지정 시 전체) |

> **확장 요청 (디자인 단계)**: `status` 쿼리는 디자인 단계에서 추가 요청된 항목입니다.
> **클라이언트 기본 필터**: 클라이언트는 진입 시 `status=PENDING`을 기본값으로 호출합니다.

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 2,
  "hasNextPage": true,
  "content": [
    {
      "label": "2026-04-25-update",
      "unitId": 12,
      "description": "배열 챕터 5번째 사이클",
      "status": "PENDING",
      "createdAt": "2026-04-25"
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `label` | string | `YYYY-MM-DD-update` 포맷. 라벨 식별자 |
| `unitId` | number | 대상 유닛 ID |
| `description` | string | 사이클 설명 |
| `status` | string | `PENDING` \| `COMPLETED` |
| `createdAt` | string (date) | 생성일 (`YYYY-MM-DD`) |

### 8-2. GET `/staging/labels/{label}` — 라벨 상세 (그루핑 응답)

라벨에 속한 레슨 1개 + 문제 6개 + 각 문제의 옵션/정답을 한 번에 그루핑하여 반환.

#### 요청

```http
GET /api/v1/admin/staging/labels/{label}
Authorization: Bearer {accessToken}
```

| Path 파라미터 | 타입 | 설명 |
|---|---|---|
| `label` | string | 라벨 식별자 (예: `2026-04-25-update`) |

#### 응답 — 200 OK

```json
{
  "label": "2026-04-25-update",
  "unitId": 12,
  "description": "배열 챕터 5번째 사이클",
  "status": "PENDING",
  "createdAt": "2026-04-25",
  "lesson": {
    "lessonId": 901,
    "title": "배열의 정의"
  },
  "problems": [
    {
      "problemId": 1001,
      "problemType": "OBJECTIVE",
      "instruction": "...",
      "content": "...",
      "options": [
        { "optionId": 1, "content": "...", "explanation": "...", "isAnswer": false },
        { "optionId": 2, "content": "...", "explanation": "...", "isAnswer": true },
        { "optionId": 3, "content": "...", "explanation": "...", "isAnswer": false },
        { "optionId": 4, "content": "...", "explanation": "...", "isAnswer": false }
      ]
    },
    {
      "problemId": 1002,
      "problemType": "SUBJECTIVE",
      "instruction": "...",
      "content": "...",
      "answers": [
        { "answerId": 1, "content": "...", "explanation": "..." },
        { "answerId": 2, "content": "...", "explanation": "..." }
      ]
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `lesson` | object | 단일 레슨 객체 |
| `problems` | array | **정확히 6개의 문제** |
| `problems[].options` | array | 객관식만 존재. 정확히 4개 |
| `problems[].answers` | array | 주관식만 존재. 1개 이상 |

#### 정렬 순서

> ⚠️ **백엔드 결정 사항**: `options` 4개와 `answers` N개의 정렬 순서는 백엔드가 결정합니다. 클라이언트는 응답 배열 순서를 그대로 사용하여 화면에 표시합니다 (예: 객관식 ①②③④는 응답 배열 인덱스 순서). 일관된 순서 보장만 필요합니다.

#### 404 Not Found

해당 `label`이 존재하지 않을 때.

### 8-3. PATCH `/staging/lessons/{lessonId}` — 스테이징 레슨 수정

```json
{ "title": "..." }
```

| 필드 | 타입 | 필수 |
|---|---|---|
| `title` | string | N |

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 (예: title 빈 값) |
| `404 Not Found` | 레슨 없음 |
| `409 Conflict` | 라벨이 이미 `COMPLETED`인 경우 (편집 불가) |

### 8-4. PATCH `/staging/problems/{problemId}` — 스테이징 문제 수정

```json
{
  "instruction": "...",
  "content": "..."
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `instruction` | string | N | 지시문 |
| `content` | string | N | 본문 |

> **부분 업데이트**: 제공된 필드만 수정. `options`/`answers`는 별도 엔드포인트로 처리.

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 |
| `404 Not Found` | 문제 없음 |
| `409 Conflict` | 라벨이 이미 `COMPLETED`인 경우 |

### 8-5. PATCH `/staging/options/{optionId}` — 스테이징 객관식 옵션 수정 (개별)

prod와 달리 **개별 옵션 단위로 수정**.

```json
{
  "content": "...",
  "explanation": "...",
  "isAnswer": true
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `content` | string | N | 보기 본문 |
| `explanation` | string | N | 해설 |
| `isAnswer` | boolean | N | 정답 여부 |

#### 정답 변경 시 클라이언트 동작

객관식 정답은 4개 중 정확히 1개만 `true`여야 합니다. 클라이언트는 radio 그룹으로 정답을 변경할 때 다음과 같이 호출합니다.

| 시나리오 | 호출 |
|---|---|
| 옵션 ②(현재 정답) → 옵션 ③(새 정답) 변경 | `PATCH /staging/options/2 { isAnswer: false }` + `PATCH /staging/options/3 { isAnswer: true }` (총 2회) |

> **백엔드 검증**: 백엔드는 라벨 단위에서 "정확히 1개의 isAnswer=true" 제약을 강제할 필요는 없습니다 (다중 PATCH 중간 상태에서 일시적으로 위반될 수 있음). 검증은 클라이언트가 [저장] 클릭 직전에 수행하며, 백엔드는 단순히 요청 값을 반영합니다.

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 |
| `404 Not Found` | 옵션 없음 |
| `409 Conflict` | 라벨이 이미 `COMPLETED`인 경우 |

### 8-6. PATCH `/staging/answers/{answerId}` — 스테이징 주관식 정답 수정 (개별)

```json
{
  "content": "...",
  "explanation": "..."
}
```

| 필드 | 타입 | 필수 |
|---|---|---|
| `content` | string | N |
| `explanation` | string | N |

> **도메인 제약 (디자인 결정)**: 주관식 정답의 **추가·삭제 API는 제공하지 않음** (Q19 결정). 운영자는 자동 생성된 N개의 정답을 수정만 가능. 정답 개수는 LLM 파이프라인 단계에서 확정되며 백오피스에서 변경 불가.

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 |
| `404 Not Found` | 정답 없음 |
| `409 Conflict` | 라벨이 이미 `COMPLETED`인 경우 |

### 8-7. PATCH `/staging/labels/{label}/status` — 라벨 상태 전환 (가장 위험한 액션)

```json
{ "status": "COMPLETED" }
```

| 필드 | 타입 | 필수 | 값 |
|---|---|---|---|
| `status` | string | Y | `COMPLETED` (현재 명세상 유일한 전환 방향) |

#### 동작

- `PENDING → COMPLETED` 전환 시 백엔드는 라벨에 속한 lesson + problems + options/answers를 **prod 테이블에 INSERT** 실행
- 이 작업은 **되돌리기 어려움** (rollback API 없음)
- 전환 후 라벨의 모든 staging 리소스는 read-only

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 전환 성공 |
| `409 Conflict` | 라벨이 이미 `COMPLETED`인 경우 또는 prod INSERT 충돌 |
| `500 Internal Server Error` | prod INSERT 실패 |

> **클라이언트 안전장치**: 클라이언트는 라벨명을 정확히 타이핑해야 [반영] 버튼이 활성화되는 strict match confirm 모달을 사용합니다 (와이어프레임 6-7-8 참조). 백엔드는 추가 검증 없이 요청을 처리하면 됩니다.

---

## 9. 공지 (Notices)

### 9-1. GET `/notices` — 공지 목록

#### 요청

```http
GET /api/v1/admin/notices?page={n}
```

| 파라미터 | 타입 | 필수 | 기본값 |
|---|---|---|---|
| `page` | number | N | 1 |

#### 응답 — 200 OK

```json
{
  "page": 1,
  "totalPages": 3,
  "hasNextPage": true,
  "content": [
    {
      "noticeId": 42,
      "title": "v2.0 업데이트",
      "status": "PUBLISHED",
      "pinned": true,
      "publishedAt": "2026-04-20",
      "createdAt": "2026-04-19"
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `noticeId` | number | 공지 ID |
| `title` | string | 제목 |
| `status` | string | `DRAFT` \| `PUBLISHED` \| `ARCHIVED` |
| `pinned` | boolean | 상단 고정 여부 |
| `publishedAt` | string (date) \| null | 게시일. `DRAFT`인 경우 `null` |
| `createdAt` | string (date) | 작성일 |

### 9-2. GET `/notices/{noticeId}` — 공지 상세

#### 응답 — 200 OK

```json
{
  "noticeId": 42,
  "title": "v2.0 업데이트",
  "summary": "새로운 챕터와 학습 기능이 추가되었습니다.",
  "content": "안녕하세요. Gravit 운영팀입니다...",
  "status": "PUBLISHED",
  "pinned": true,
  "publishedAt": "2026-04-20",
  "createdAt": "2026-04-19"
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `summary` | string | 요약 |
| `content` | string | 본문 (마크다운 텍스트) |
| (나머지 필드는 9-1과 동일) | | |

### 9-3. POST `/notices` — 공지 작성

```json
{
  "title": "...",
  "summary": "...",
  "content": "...",
  "status": "DRAFT",
  "pinned": false
}
```

| 필드 | 타입 | 필수 | 값 / 설명 |
|---|---|---|---|
| `title` | string | Y | 제목 |
| `summary` | string | Y | 요약 |
| `content` | string | Y | 본문 (마크다운) |
| `status` | string | Y | `DRAFT` \| `PUBLISHED` (작성 시 `ARCHIVED`는 불가) |
| `pinned` | boolean | N | 기본 `false` |

#### 응답

| 상태 | 의미 |
|---|---|
| `201 Created` | 성공 (생성된 공지 객체 반환 권장) |
| `400 Bad Request` | 검증 실패 (필수 필드 누락 등) |

### 9-4. PATCH `/notices/{noticeId}` — 공지 수정

```json
{
  "title": "...",
  "summary": "...",
  "content": "...",
  "status": "PUBLISHED",
  "pinned": true
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `title` | string | N | 제목 |
| `summary` | string | N | 요약 |
| `content` | string | N | 본문 |
| `status` | string | N | `DRAFT` \| `PUBLISHED` \| `ARCHIVED` (전이 제약 적용) |
| `pinned` | boolean | N | 상단 고정 |

#### 상태 전이 제약 (백엔드 검증 필수)

| 현재 상태 | 허용 전이 | 차단 |
|---|---|---|
| `DRAFT` | `DRAFT`, `PUBLISHED` | → `ARCHIVED` 불가 |
| `PUBLISHED` | `PUBLISHED`, `ARCHIVED` | → `DRAFT` 불가 |
| `ARCHIVED` | `ARCHIVED` (변경 없음) | → `DRAFT`, → `PUBLISHED` 모두 불가 |

> **추가 제약 (디자인 결정)**: `ARCHIVED → PUBLISHED` 차단은 디자인 단계에서 결정된 정책입니다. ARCHIVED는 종착 상태로 처리합니다. 백엔드 검증 일치 필요.

#### 응답

| 상태 | 의미 |
|---|---|
| `200 OK` | 성공 |
| `400 Bad Request` | 검증 실패 |
| `404 Not Found` | 공지 없음 |
| `409 Conflict` | 상태 전이 위반 (예: PUBLISHED → DRAFT 시도) |

### 9-5. DELETE `/notices/{noticeId}` — 공지 삭제

#### 요청

```http
DELETE /api/v1/admin/notices/{noticeId}
Authorization: Bearer {accessToken}
```

#### 응답

| 상태 | 의미 |
|---|---|
| `204 No Content` | 성공 |
| `404 Not Found` | 공지 없음 |

> **물리 삭제 vs 논리 삭제**: 백엔드 결정 사항. 클라이언트는 삭제 후 목록에서 사라지는 동작만 가정합니다.

---

## 10. 백엔드 추가/확장 요청 사항 요약

디자인 단계에서 도출된 백엔드 추가/확장 요청 사항을 우선순위별로 정리합니다.

### 10-1. 신규 엔드포인트

| # | 엔드포인트 | 사유 |
|---|---|---|
| 1 | `GET /dashboard/summary` | 대시보드 위젯 3개 카운트 |

### 10-2. 기존 엔드포인트 확장 (쿼리 파라미터 추가)

| # | 엔드포인트 | 추가 파라미터 | 사유 |
|---|---|---|---|
| 1 | `GET /users` | `search`, `status`, `role` | 유저 목록 검색·필터 |
| 2 | `GET /reports` | `reportType`, `isResolved` | 신고 목록 필터 |
| 3 | `GET /staging/labels` | `status` | 스테이징 라벨 필터 |

### 10-3. 기존 엔드포인트 확장 (응답 필드 추가)

| # | 엔드포인트 | 추가 필드 | 사유 |
|---|---|---|---|
| 1 | `GET /chapters/{id}` | `unitCount` | 챕터 상세 "유닛 (총 N개)" 표시 |
| 2 | `GET /units/{id}` | `lessonCount` | 유닛 상세 "레슨 (총 N개)" 표시 |
| 3 | `GET /lessons/{id}` | `problemCount` | 레슨 상세 "문제 (총 N개)" 표시 |

### 10-4. 백엔드 검증/정책 확인

| # | 항목 | 확인 사항 |
|---|---|---|
| 1 | 백오피스 로그인 시 `role=USER` 차단 | `POST /auth/login`에서 401 또는 403 응답 |
| 2 | 공지 `ARCHIVED → PUBLISHED` 전이 차단 | 디자인 결정 — 백엔드 검증 일치 필요 |
| 3 | `PATCH /problems/{id}/subjective`의 `answers` 동작 | 전체 교체로 가정 — 확인 필요 |
| 4 | `GET /chapters/{id}/stats`의 `averageProgress` 단위 | `0~100` 퍼센트로 가정 — 확인 필요 |
| 5 | `GET /staging/labels/{label}` 응답 구조 | 본 문서 8-2 구조와 실제 백엔드 응답 일치 확인 |

### 10-5. 운영 시점 추가 필요

| # | 엔드포인트 | 사유 |
|---|---|---|
| 1 | `POST /auth/refresh` | accessToken 만료 시 재발급 |
| 2 | `POST /auth/logout` | refreshToken 무효화 |

> 위 두 엔드포인트는 운영 시점에 클라이언트가 반드시 필요로 하므로 백엔드 팀 결정 후 추가 명세가 필요합니다.

---

## 11. 백엔드 결정 사항 (디자인 단계 미확정)

본 문서에 단정 표기되지 않은 항목은 백엔드 팀이 결정합니다.

| # | 항목 | 영향 |
|---|---|---|
| 1 | accessToken / refreshToken 만료 시간 | 보안 정책 |
| 2 | refresh / logout 엔드포인트 사양 | 클라이언트 토큰 갱신 흐름 |
| 3 | 통일된 에러 응답 본문 포맷 | 클라이언트 토스트 메시지 (권장: `{ code, message }`) |
| 4 | 공지 DELETE의 물리/논리 삭제 여부 | 데이터 보존 정책 |
| 5 | 신고 응답에 reporter 필드 포함 여부 | 클라이언트 미사용 (포함되어도 무방) |
| 6 | `GET /staging/labels/{label}`의 `options` / `answers` 정렬 순서 | 일관된 순서만 보장되면 됨 |
| 7 | `profileImgNumber` 매핑 규칙 | 사용자 앱과 동일 사용 |

---

**문서 작성일**: 2026-04-26  
**문서 버전**: 1.0  
**관련 문서**: `01_gravit_admin_wireframe_spec.md` v1.1 (와이어프레임 명세)
