# query-stats-summary-0 — lessons

상태: 0 = 원본 (기준선 이전에 선행한 정합성 수정만 적용된 상태. 성능 기법은 아직 적용하지 않았다)
측정: VU 50 / 유지 1m (총 2m) / Redis 캐시 cold, DB 캐시 제어하지 않음 / 요청 65236건
비고: 로컬 DB에 V3 인덱스 3개가 없는 상태에서 잰 1차 측정은 폐기하고, 인덱스를 복구한 뒤 다시 잰 값이다. 두 측정 사이에 바뀐 것은 로컬 DB의 인덱스뿐이고 애플리케이션 코드는 그대로이므로 상태 번호는 0을 유지한다. 정합성 수정은 1차 측정 이전에 이미 적용돼 있어 두 측정 모두에 포함된다

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 65236 | 0.3302276035164658 | 21542.72794299995 | 29.085465926961536% | 1.00000000000000000000 | `WrongAnsweredNoteRepository.countByUnitIdAndUserId` | `wrong_answered_note ⋈ problem ⋈ lesson` 조인으로 유저의 해당 유닛 미극복 오답노트 수를 COUNT |
| 2 | 1.00000000000000000000 | 65236 | 0.310082543687537 | 20228.54481999992 | 27.311148925561273% | 1.00000000000000000000 | `BookmarkRepository.countByUnitIdAndUserId` | `bookmark ⋈ problem ⋈ lesson` 조인으로 유저의 해당 유닛 북마크 수를 COUNT |
| 3 | 1.00000000000000000000 | 65236 | 0.30593950446073004 | 19958.269513000098 | 26.946242343003945% | 2.0000000000000000 | `LessonRepository.findAllLessonSummaryByUnitId` | 유닛의 레슨 목록을 읽고, 레슨 행마다 문제 수 COUNT 서브쿼리와 제출 존재 여부 EXISTS 서브쿼리를 계산 |
| 4 | 1.00000000000000000000 | 65236 | 0.043101160233613274 | 2811.7472890000004 | 3.7962221026891685% | 1.00000000000000000000 | `ChapterRepository.findChapterBriefByUnitId` | `chapter ⋈ unit` 조인으로 유닛이 속한 챕터의 id, title 조회 |
| 5 | 1.00000000000000000000 | 65236 | 0.04245486784904072 | 2769.5857590000487 | 3.739298590147637% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` | 인증 필터에서 `users` PK 단건 조회 (전체 컬럼) |
| 6 | 1.00000000000000000000 | 65236 | 0.038416776074560184 | 2506.156803999997 | 3.3836354673016396% | 1.00000000000000000000 | `UnitRepository.findUnitSummaryById` | `unit` PK 단건 조회 |
| 7 | 2.0000000000000000 | 130472 | 0.017156888826721214 | 2238.4935990000463 | 3.0222555599135847% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 8 | 1.00000000000000000000 | 65236 | 0.029910295036482754 | 1951.2280069999752 | 2.634409897553009% | 0.000000000000000000000000 | `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed`) | 오늘 첫 접근이면 `users.last_accessed_at`을 갱신하는 UPDATE. 조건 불일치로 0행 갱신 |
| 9 | 1.00007664479735115580 | 65241 | 0.0009213586088502636 | 60.110356999996476 | 0.08115674788294361% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 10 | 0.000076644797351155803544 | 5 | 0.018075 | 0.09037500000000001 | 0.00012201792596110283% | 0.00000000000000000000 | `SeasonRepository.findCloseableActiveByNowForUpdate` | 시즌 스케줄러의 종료 대상 시즌 잠금 조회. 대상 API와 무관 |
| 11 | 0.00068980317616040223 | 45 | 0.0006250888888888889 | 0.028129000000000015 | 3.797778411463196e-05% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 12 | 0.000045986878410693482126 | 3 | 0.001097 | 0.003291 | 4.443275179396839e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select count(wan1_0.id) from wrong_answered_note wan1_0 join problem p1_0 on p1_0.id=wan1_0.problem_id join lesson l1_0 on l1_0.id=p1_0.lesson_id where l1_0.unit_id=$1 and wan1_0.user_id=$2 and wan1_0.resolved_at is null

[2] select count(b1_0.id) from bookmark b1_0 join problem p1_0 on p1_0.id=b1_0.problem_id join lesson l1_0 on l1_0.id=p1_0.lesson_id where l1_0.unit_id=$1 and b1_0.user_id=$2

[3] select l1_0.id,l1_0.title,(select count(p1_0.id) from problem p1_0 where p1_0.lesson_id=l1_0.id),case when exists(select 1 from lesson_submission ls1_0 where ls1_0.lesson_id=l1_0.id and ls1_0.user_id=$1) then true else false end from lesson l1_0 where l1_0.unit_id=$2

[4] select c1_0.id,c1_0.title from chapter c1_0 join unit u1_0 on u1_0.chapter_id=c1_0.id where u1_0.id=$1

[5] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[6] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 where u1_0.id=$1

[7] BEGIN READ ONLY

[8] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[9] BEGIN

[10] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[11] COMMIT

[12] ROLLBACK
