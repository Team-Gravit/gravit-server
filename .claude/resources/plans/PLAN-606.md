# [PLAN-606] 마이페이지 최다 학습 챕터를 상위 5개로 수정

> 이슈: #606
> 브랜치: fix/606-top-chapters-limit

## 목표
마이페이지 이번 주 최다 학습 챕터 조회(`GET /api/v1/my-pages/learning/top-chapters`)가 상위 3개만 반환한다.
기획은 상위 5개이므로 조회 개수를 5개로 맞추고, API 문서와 테스트, 서비스 정책을 같은 기준으로 갱신한다.

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/lesson/service/LessonSubmissionQueryService.java` - `TOP_CHAPTERS_LIMIT` 값을 `3`에서 `5`로 변경
- `src/main/java/gravit/code/user/controller/docs/MyPageControllerDocs.java` - `getMyPageTopChapters`의 `@Operation` description `상위 3개` → `상위 5개`
- `src/test/java/gravit/code/lesson/service/LessonSubmissionQueryServiceIntegrationTest.java` - 개수 제한 검증 테스트를 5개 기준으로 갱신
- `.claude/spec/service-policy/learning.md` - 정책 추가: 마이페이지 이번 주 최다 학습 챕터의 집계 기준과 노출 개수(5개)

## 구현 계획
1. **Entity / Flyway**: 변경 없음
2. **Repository**: 변경 없음. `LessonSubmissionRepository.findTopChaptersByUserIdInWeek(long userId, LocalDateTime weekStart, LocalDateTime nextWeekStart, Pageable pageable)`가 이미 `Pageable`로 개수를 받으므로 쿼리는 그대로 둔다
3. **Service**: `LessonSubmissionQueryService`
   - `private static final int TOP_CHAPTERS_LIMIT = 3;` → `5`
   - `getTopChapters(long userId)` 로직은 변경 없음 (`PageRequest.of(0, TOP_CHAPTERS_LIMIT)`로 상수를 그대로 사용)
4. **Facade**: 불필요 - 단일 Service, 기존 흐름(Controller → `LessonSubmissionQueryService`) 유지
5. **DTO**: 변경 없음 (`TopChapterResponse`의 rank, chapterTitle, solvedLessonCount, ratio 그대로)
6. **Controller**: 변경 없음 (`GET /api/v1/my-pages/learning/top-chapters → MyPageController.getMyPageTopChapters`)
   - Docs만 수정: `MyPageControllerDocs.getMyPageTopChapters`의 description을 `"이번 주에 가장 많이 푼 챕터 상위 5개를 조회합니다<br>"`로 변경. summary, 응답 정의는 그대로
7. **Test**: `LessonSubmissionQueryServiceIntegrationTest.GetTopChapters`
   - `풀이_수가_많은_순으로_최대_3개의_챕터를_반환한다` → `풀이_수가_많은_순으로_최대_5개의_챕터를_반환한다`로 이름 변경
   - given: 기존 4개 챕터(자료구조 3, 운영체제 2, 네트워크 1, 데이터베이스 1)에 2개 챕터(컴퓨터구조 1, 알고리즘 1)를 추가해 총 6개 챕터를 만든다. 챕터마다 유닛 1개, 레슨과 제출을 풀이 수만큼 둔다
   - then: `hasSize(5)`, rank가 `1, 2, 3, 4, 5` 순서, solvedLessonCount가 `3, 2, 1, 1, 1` 순서, 1위 `자료구조`, 2위 `운영체제`
   - 나머지 3개 테스트(중복 제출, 기록 없음, 다른 사용자)는 개수 제한과 무관하므로 그대로 둔다
8. **Policy**: `learning.md` 주간 리포트 항목 근처에 아래 규칙을 추가한다
   - 마이페이지 이번 주 최다 학습 챕터는 월요일 시작 기준 이번 주에 푼 레슨 수가 많은 챕터 순으로 최대 5개를 보여준다. 같은 레슨을 여러 번 제출해도 1개로 센다
   - 푼 레슨 수가 같으면 먼저 등록된 챕터가 앞선다. 비율은 이번 주에 푼 전체 레슨 수 대비 그 챕터의 푼 레슨 수이고, 소수점은 버린다

## 결정 필요 (Decisions needed)
- 없음

## 검증
- 대상 테스트: `LessonSubmissionQueryServiceIntegrationTest` 전체 (특히 `GetTopChapters`의 4개 시나리오)

## Deviation Log
