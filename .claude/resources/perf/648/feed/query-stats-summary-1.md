# query-stats-summary-1 — feed

상태: 1 = 사이클 1 적용 후: 쿼리 재작성 (`ORDER BY uf.feedId DESC`)
측정: VU 50 / 유지 1m (총 2m) / Redis 해당 없음, DB 캐시 제어하지 않음 (warmup 후) / 요청 6890건
직전 상태 대비: 요청 6090 → 6890건. 요청당 쿼리 수 SELECT 4 + UPDATE 1, 트랜잭션 3 → 같음. 대상 쿼리 mean_ms 711.6196148844017 → 628.0638215290288, total_ms 4333763.454646006 → 4327359.730335016, 비중 99.94357517838404% → 99.94434611075538%, 행/호출 5 → 5. `findActorIdsWithLimitReached` mean_ms 0.1383818898193761 → 0.11247805384615411, `findCongratulatedFeedIds` 0.08075717422003274 → 0.06531017242380256, `findById` 0.05934473908045969 → 0.057189282873730055, `updateLastAccessedAt` 0.04669466059113299 → 0.042655569956458646. 사라진 쿼리: `SET application_name = 'PostgreSQL JDBC Driver'`(-0의 5회, 커넥션 초기화). 새로 생긴 쿼리: 없음. `findActorIdsWithLimitReached` 원문의 HAVING 값이 -0의 `$7`에서 `3`으로 기록됨 (해당 코드 변경 없음)

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 6890 | 628.0638215290288 | 4327359.730335016 | 99.94434611075538% | 5.0000000000000000 | `UserFeedRepository.findVisibleFeedsByUserId` | `user_feed`(user_id, is_hidden 조건) + `social_feed` 조인 + `users`(작성자) 조인, `user_feed.feed_id` 역순 상위 5행 |
| 2 | 1.00000000000000000000 | 6890 | 0.11247805384615411 | 774.973790999998 | 0.01789873124055523% | 0.00000000000000000000 | `CongratulationRepository.findActorIdsWithLimitReached` | `congratulation`에서 사용자, 작성자 IN(4건), 오늘 0시 이후 조건으로 작성자별 3건 이상만 집계 |
| 3 | 2.0001451378809869 | 13781 | 0.03365063906828238 | 463.73945700000047 | 0.010710488538939569% | 0.000000000000000000000000 | - | 트랜잭션 제어 (읽기 전용 트랜잭션 시작. `parseUser`의 `findById`와 `SocialFacade.getFeed`) |
| 4 | 1.00000000000000000000 | 6890 | 0.06531017242380256 | 449.9870879999987 | 0.010392864950231681% | 2.0000000000000000 | `CongratulationRepository.findCongratulatedFeedIds` | `congratulation`에서 사용자, 피드 IN(4건) 조건으로 축하한 피드 id 조회 |
| 5 | 1.00000000000000000000 | 6890 | 0.057189282873730055 | 394.0341589999998 | 0.009100580682139767% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` → `UserRepository.findById` (`JwtAuthFilter`) | 토큰의 사용자 id로 `users` 1행 조회 |
| 6 | 1.00000000000000000000 | 6890 | 0.042655569956458646 | 293.89687700000144 | 0.006787818213921453% | 0.00000000000000000000 | `UserAccessService.updateLastAccessed` → `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor`) | `users.last_accessed_at` 조건부 갱신 (0행 갱신) |
| 7 | 1.00000000000000000000 | 6890 | 0.00327243323657475 | 22.547064999999975 | 0.0005207451676237783% | 0.00000000000000000000 | - | 트랜잭션 제어 (`UserAccessService.updateLastAccessed`) |
| 8 | 0.00072568940493468795 | 5 | 1.7351112 | 8.675556 | 0.00020036993122827656% | 1.00000000000000000000 | `SeasonRepository.findByStatus` (호출 경로 미상, 요청 경로 밖) | `season`을 상태로 1행 조회 |
| 9 | 0.00014513788098693759 | 1 | 1.700929 | 1.700929 | 3.928451695247903e-05% | 3.0000000000000000 | `UserLeagueRepository.findRankEntriesBySeasonId` (호출 경로 미상, 요청 경로 밖) | `user_league` + `users` 조인으로 시즌 참여자의 LP와 리그 조회 |
| 10 | 0.00653120464441219158 | 45 | 0.0028922888888888885 | 0.130153 | 3.006003034174856e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select sf1_0.id,sf1_0.actor_id,u1_0.nickname,u1_0.profile_img_number,u1_0.handle,sf1_0.event_type,sf1_0.event_value,sf1_0.created_at from user_feed uf1_0 join social_feed sf1_0 on sf1_0.id=uf1_0.feed_id join users u1_0 on (u1_0.deleted_at IS NULL) and u1_0.id=sf1_0.actor_id where uf1_0.user_id=$1 and uf1_0.is_hidden=$3 order by uf1_0.feed_id desc fetch first $2 rows only

[2] select c1_0.actor_id from congratulation c1_0 where c1_0.user_id=$1 and c1_0.actor_id in ($2,$3,$4,$5) and c1_0.created_at>=$6 group by c1_0.actor_id having count(c1_0.id)>=3

[3] BEGIN READ ONLY

[4] select c1_0.feed_id from congratulation c1_0 where c1_0.user_id=$1 and c1_0.feed_id in ($2,$3,$4,$5)

[5] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[6] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[7] BEGIN

[8] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$1

[9] select $2,u1_0.id,ul1_0.league_point,ul1_0.league_id from user_league ul1_0 join users u1_0 on u1_0.id=ul1_0.user_id and (u1_0.deleted_at IS NULL) where ul1_0.season_id=$1 and u1_0.deleted_at is null

[10] COMMIT
