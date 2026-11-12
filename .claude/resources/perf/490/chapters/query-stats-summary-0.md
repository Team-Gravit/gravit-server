# query-stats-summary-0 — chapters

상태: 0 = 아무것도 적용하지 않은 원본
측정: VU 50 / ramp-up 30s + 유지 1m + ramp-down 30s (총 2m) / Redis 캐시 cold, DB 캐시 제어하지 않음 / 요청 47680건
직전 상태 대비: - (기준선)

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 5.0000000000000000 | 238400 | 0.3010765931082263 | 71776.65979699792 | 68.03926064083532% | 1.00000000000000000000 | `LessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId` | 유저가 해당 챕터에서 푼 서로 다른 레슨 수를 센다. `lesson_submission` → `lesson` → `unit` 조인 |
| 2 | 4.8459941275167785 | 231057 | 0.12106246924351827 | 27972.33095600065 | 26.515816172413153% | 1.00000000000000000000 | `LessonRepository.countTotalLessonByChapterId` | 해당 챕터의 전체 레슨 수를 센다. `chapter` → `unit` → `lesson` 조인 |
| 3 | 1.00000000000000000000 | 47680 | 0.0346105702390938 | 1650.231988999988 | 1.5643046741792022% | 1.00000000000000000000 | `UserRepository.findById` (`JwtAuthFilter:81` → `AuthTokenProvider.parseUser:70`) | 토큰의 userId로 유저 엔티티 전체 컬럼을 읽는다 |
| 4 | 2.0000000000000000 | 95360 | 0.014380062709731602 | 1371.2827800000582 | 1.2998803057232198% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 5 | 1.00000000000000000000 | 47680 | 0.02805992363674482 | 1337.8971589999896 | 1.2682330686505523% | 5.0000000000000000 | `ChapterRepository.findAllChapterSummary` | 전체 챕터의 id, title, description을 읽는다. 조건 없음 |
| 6 | 1.00000000000000000000 | 47680 | 0.02800730006291952 | 1335.388066999983 | 1.2658546246683007% | 0.000000000000000000000000 | `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor:30` → `UserAccessService:25`) | 오늘 첫 접근이면 `last_accessed_at`을 갱신한다 |
| 7 | 1.00014681208053691275 | 47687 | 0.0010244429089689107 | 48.852608999995724 | 0.04630886148974224% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 8 | 0.00014681208053691275 | 7 | 0.043167000000000004 | 0.302169 | 0.00028643510866523315% | `SeasonRepository.findCloseableActiveByNowForUpdate` (`SeasonBatchScheduler.tryQuarterlyRollover` → `SeasonBatchService:48`) | 만료된 ACTIVE 시즌을 잠금 조회한다. 로컬 `application.yml:104`가 cron을 `*/30 * * * * *`로 덮어써 30초마다 돈다. 대상 API와 무관 |
| 9 | 0.00096476510067114094 | 46 | 0.0007137608695652174 | 0.032833000000000015 | 3.112339095938235e-05% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 10 | 0.000041946308724832214765 | 2 | 0.012708500000000001 | 0.025417000000000002 | 2.4093540889185293e-05% | 0.00000000000000000000 | - | 트랜잭션 제어 |

8번 행의 `행/호출`은 1차 출력에서 `0.00000000000000000000`이다.

**요청당 집계**

| 구분 | 값 |
|---|---|
| SQL 문 (1, 2, 3, 5, 6번) | 12.8459941275167785 |
| SQL 문 + 배경 노이즈(8번) | 12.846140939597315 |
| 트랜잭션 제어 (`BEGIN READ ONLY` 2 + `BEGIN` 1) | 3.00014681208053691275 |
| 전체 SQL 실행시간 합 / 요청 수 | 105493.00377599859ms / 47680 = 2.2125210943372...ms |

`BEGIN READ ONLY` 2건은 필터의 `UserRepository.findById`(Spring Data JPA 기본 `readOnly = true`)와
파사드의 `@Transactional(readOnly = true)`, `BEGIN` 1건은 인터셉터의 UPDATE 트랜잭션이다.

## 쿼리 원문

[1] select count(distinct l1_0.id) from lesson_submission ls1_0 join lesson l1_0 on l1_0.id=ls1_0.lesson_id join unit u1_0 on u1_0.id=l1_0.unit_id where u1_0.chapter_id=$1 and ls1_0.user_id=$2

[2] select count(l1_0.id) from chapter c1_0 join unit u1_0 on u1_0.chapter_id=c1_0.id join lesson l1_0 on l1_0.unit_id=u1_0.id where c1_0.id=$1

[3] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[4] BEGIN READ ONLY

[5] select c1_0.id,c1_0.title,c1_0.description from chapter c1_0

[6] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[7] BEGIN

[8] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[9] COMMIT

[10] ROLLBACK
