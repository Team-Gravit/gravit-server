# query-stats-summary-1 — chapters

상태: 1 = 사이클 1 적용 후 (단일 집계 쿼리로 N+1 제거)
측정: VU 50 / ramp-up 30s + 유지 1m + ramp-down 30s (총 2m) / Redis 캐시 cold, DB 캐시 제어하지 않음 / 요청 70715건
직전 상태 대비: 요청당 SQL 12.8459941275167785 → 4.0 (왕복 15.85 → 7.00), 요청당 DB 실행시간 2.2125210943372ms → 1.3445919ms, `countSolvedLessonByChapterIdAndUserId`(238400회)와 `countTotalLessonByChapterId`(231057회)가 사라지고 `findChapterProgressByUserId`(70715회, 요청당 1회)가 새로 생김

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 70715 | 1.1704637619882787 | 82769.34492900038 | 87.04973879038928% | 5.0000000000000000 | `ChapterRepository.findChapterProgressByUserId` | 전체 챕터의 총 레슨 수와 해당 유저가 푼 레슨 수를 챕터별로 한 번에 집계한다. `chapter` → `unit` → `lesson` → `lesson_submission` 3중 LEFT JOIN + `GROUP BY c.id` |
| 2 | 1.00000000000000000000 | 70715 | 0.05074677653963104 | 3588.5583030000084 | 3.774139606616385% | 1.00000000000000000000 | `UserRepository.findById` (`JwtAuthFilter:81` → `AuthTokenProvider.parseUser:70`) | 토큰의 userId로 유저 엔티티 전체 컬럼을 읽는다 |
| 3 | 2.0000000000000000 | 141430 | 0.024559445025807813 | 3473.4423099999685 | 3.653070421764848% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 4 | 1.00000000000000000000 | 70715 | 0.03902106241957194 | 2759.3744290000354 | 2.902074717099415% | 0.000000000000000000000000 | `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor:30` → `UserAccessService:25`) | 오늘 첫 접근이면 `last_accessed_at`을 갱신한다 |
| 5 | 1.00000000000000000000 | 70715 | 0.03405632865728632 | 2408.293280999967 | 2.5328375042901112% | 5.0000000000000000 | `ChapterRepository.findAllChapterSummary` | 전체 챕터의 id, title, description을 읽는다. 조건 없음 |
| 6 | 1.00008484762780173938 | 70721 | 0.001181764864750203 | 83.57559300000038 | 0.08789768175817536% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 7 | 0.000084847627801739376370 | 6 | 0.03252083333333333 | 0.195125 | 0.00020521583559764736% | 0.00000000000000000000 | `SeasonRepository.findCloseableActiveByNowForUpdate` (`SeasonBatchScheduler.tryQuarterlyRollover` → `SeasonBatchService:48`) | 만료된 ACTIVE 시즌을 잠금 조회한다. 로컬 `application.yml:104`가 cron을 `*/30 * * * * *`로 덮어써 30초마다 돈다. 대상 API와 무관 |
| 8 | 0.00063635720851304532 | 45 | 0.0007258666666666668 | 0.03266400000000001 | 3.4353209757650513e-05% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 9 | 0.000028282542600579792123 | 2 | 0.0008125 | 0.001625 | 1.709036427142483e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

7번 행의 `행/호출`은 1차 출력에서 `0.00000000000000000000`이다.

**사라진 쿼리**

| 출처 | 상태 0에서의 값 |
|---|---|
| `LessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId` | 요청당 5.0000000000000000회, calls 238400, mean 0.3010765931082263ms, total 71776.65979699792ms (비중 68.03926064083532%) |
| `LessonRepository.countTotalLessonByChapterId` | 요청당 4.8459941275167785회, calls 231057, mean 0.12106246924351827ms, total 27972.33095600065ms (비중 26.515816172413153%) |

두 메서드 자체는 코드에 남아 있다(`LearningFacade:48`, `UserFacade:118`이 단건으로 호출).
이 부하 시나리오가 그 경로를 타지 않아 통계에 나타나지 않는다.

**새로 생긴 쿼리**

| 출처 | 값 |
|---|---|
| `ChapterRepository.findChapterProgressByUserId` | 요청당 1.00000000000000000000회, calls 70715, mean 1.1704637619882787ms, total 82769.34492900038ms (비중 87.04973879038928%) |

**요청당 집계**

| 구분 | 상태 0 | 상태 1 |
|---|---|---|
| SQL 문 | 12.8459941275167785 | 4.0 |
| SQL 문 + 배경 노이즈 | 12.846140939597315 | 4.000084847627802 |
| 트랜잭션 제어 (`BEGIN READ ONLY` 2 + `BEGIN` 1) | 3.00014681208053691275 | 3.00008484762780173938 |
| 왕복 합계 | 15.85 | 7.00 |
| 전체 SQL 실행시간 합 / 요청 수 | 105493.00377599859 / 47680 = 2.2125210943372ms | 95082.81825900036 / 70715 = 1.3445919ms |

트랜잭션 구성은 변하지 않았다. `BEGIN READ ONLY` 2건은 필터의 `UserRepository.findById`와 파사드의
`@Transactional(readOnly = true)`, `BEGIN` 1건은 인터셉터의 UPDATE 트랜잭션이다.

## 쿼리 원문

[1] select c1_0.id,count(distinct l1_0.id),count(distinct ls1_0.lesson_id) from chapter c1_0 left join unit u1_0 on u1_0.chapter_id=c1_0.id left join lesson l1_0 on l1_0.unit_id=u1_0.id left join lesson_submission ls1_0 on ls1_0.lesson_id=l1_0.id and ls1_0.user_id=$1 group by c1_0.id

[2] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[3] BEGIN READ ONLY

[4] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[5] select c1_0.id,c1_0.title,c1_0.description from chapter c1_0

[6] BEGIN

[7] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[8] COMMIT

[9] ROLLBACK
