# query-stats-summary-1 — units

상태: 1 = 사이클 1 적용 후 (단일 집계 쿼리로 N+1 제거)
측정: VU 50 / ramp-up 30s + 유지 1m + ramp-down 30s (총 2m) / Redis cold, DB 캐시 제어하지 않음 / 요청 82328건
직전 상태 대비: 요청당 쿼리 수 27.5033 → 5.0000, 요청당 DB 시간 2.7876 ms → 0.5757 ms, 총 DB 시간 93793.362 ms → 47396.173 ms. `countSolvedLessonByUnitIdAndUserId`(요청당 13.2000178321990073회)와 `countTotalLessonByUnitId`(요청당 10.3032365441198324회)가 사라지고 `findUnitProgressByChapterIdAndUserId`(요청당 1회)가 새로 생겼다. 나머지 5개 쿼리는 요청당 호출 수가 그대로다.

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 82328 | 0.425866908852397 | 35060.77087199996 | 73.97384293539044% | 13.2000048586143232 | `UnitRepository.findUnitProgressByChapterIdAndUserId` | 챕터의 유닛별로 전체 레슨 수와 해당 유저가 제출한 레슨 수를 한 번에 집계한다 |
| 2 | 1.00000000000000000000 | 82328 | 0.038811200454280305 | 3195.2485110000384 | 6.741574860267018% | 13.2000048586143232 | `UnitRepository.findAllUnitSummaryByChapterId` | 챕터에 속한 유닛의 id, title, description을 읽는다 |
| 3 | 1.00000000000000000000 | 82328 | 0.032994515717617544 | 2716.372489999964 | 5.731206329229537% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` (`JwtAuthFilter` 경유) | 토큰의 subject로 유저 엔티티 전체 컬럼을 읽는다 |
| 4 | 2.0000000000000000 | 164656 | 0.014914430776892775 | 2455.750513999979 | 5.181326545110739% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 5 | 1.00000000000000000000 | 82328 | 0.026223036427460857 | 2158.8901429999996 | 4.554988278383361% | 0.000000000000000000000000 | `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor` 경유) | 유저의 last_accessed_at을 갱신한다 |
| 6 | 1.00000000000000000000 | 82328 | 0.020225839325623964 | 1665.152899999996 | 3.513264427006115% | 1.00000000000000000000 | `ChapterRepository.findChapterSummaryByChapterId` | 챕터 단건의 id, title, description을 읽는다 |
| 7 | 1.00006073267903993781 | 82333 | 0.0017461307738087905 | 143.7641850000186 | 0.3033244556929833% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 8 | 0.000060732679039937809737 | 5 | 0.0373414 | 0.186707 | 0.0003939284262562508% | 0.00000000000000000000 | `SeasonRepository.findCloseableActiveByNowForUpdate` | 마감 시각이 지난 ACTIVE 시즌을 잠금 조회한다 |
| 9 | 0.00054659411135944029 | 45 | 0.0007898000000000001 | 0.03554100000000002 | 7.49870663530206e-05% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 10 | 0.000036439607423962685842 | 3 | 0.000514 | 0.001542 | 3.2534272056598776e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

사라진 쿼리 (상태 0에 있었으나 상태 1에 없음)

| 쿼리 | 상태 0의 요청당 | 상태 0의 비중 |
|---|---|---|
| `LessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId` | 13.2000178321990073 | 72.96558285477879% |
| `LessonRepository.countTotalLessonByUnitId` | 10.3032365441198324 | 22.6434544401578% |

새로 생긴 쿼리 (상태 1에만 있음)

| 쿼리 | 상태 1의 요청당 | 상태 1의 비중 |
|---|---|---|
| `UnitRepository.findUnitProgressByChapterIdAndUserId` | 1.00000000000000000000 | 73.97384293539044% |

상태 0에 있던 `SET application_name = 'PostgreSQL JDBC Driver'`(7회)는 상태 1의 상위 20행에 나타나지 않았다.

## 쿼리 원문

[1] select u1_0.id,u1_0.title,count(distinct l1_0.id),count(distinct ls1_0.lesson_id) from unit u1_0 left join lesson l1_0 on l1_0.unit_id=u1_0.id left join lesson_submission ls1_0 on ls1_0.lesson_id=l1_0.id and ls1_0.user_id=$1 where u1_0.chapter_id=$2 group by u1_0.id,u1_0.title order by u1_0.id

[2] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 where u1_0.chapter_id=$1

[3] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[4] BEGIN READ ONLY

[5] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[6] select c1_0.id,c1_0.title,c1_0.description from chapter c1_0 where c1_0.id=$1

[7] BEGIN

[8] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[9] COMMIT

[10] ROLLBACK
