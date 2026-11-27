# query-stats-summary-0 — feed

상태: 0 = 원본
측정: VU 50 / 유지 1m (총 2m) / Redis 해당 없음, DB 캐시 제어하지 않음 (warmup 후) / 요청 6090건

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 6090 | 711.6196148844017 | 4333763.454646006 | 99.94357517838404% | 5.0000000000000000 | `UserFeedRepository.findVisibleFeedsByUserId` | `user_feed`(user_id, is_hidden 조건) + `social_feed` 조인 + `users`(작성자) 조인, `social_feed.created_at`, `id` 역순 상위 5행 |
| 2 | 1.00000000000000000000 | 6090 | 0.1383818898193761 | 842.7457090000003 | 0.019435075311599343% | 0.00000000000000000000 | `CongratulationRepository.findActorIdsWithLimitReached` | `congratulation`에서 사용자, 작성자 IN(4건), 오늘 0시 이후 조건으로 작성자별 3건 이상만 집계 |
| 3 | 1.00000000000000000000 | 6090 | 0.08075717422003274 | 491.8111910000004 | 0.011341959305274107% | 2.0000000000000000 | `CongratulationRepository.findCongratulatedFeedIds` | `congratulation`에서 사용자, 피드 IN(4건) 조건으로 축하한 피드 id 조회 |
| 4 | 2.0001642036124795 | 12181 | 0.03545563590838183 | 431.8851010000001 | 0.009959967015260933% | 0.000000000000000000000000 | - | 트랜잭션 제어 (읽기 전용 트랜잭션 시작. `parseUser`의 `findById`와 `SocialFacade.getFeed`) |
| 5 | 1.00000000000000000000 | 6090 | 0.05934473908045969 | 361.4094610000001 | 0.0083346850869098% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` → `UserRepository.findById` (`JwtAuthFilter`) | 토큰의 사용자 id로 `users` 1행 조회 |
| 6 | 1.00000000000000000000 | 6090 | 0.04669466059113299 | 284.37048299999947 | 0.006558041998290222% | 0.00000000000000000000 | `UserAccessService.updateLastAccessed` → `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor`) | `users.last_accessed_at` 조건부 갱신 (0행 갱신) |
| 7 | 1.00000000000000000000 | 6090 | 0.003959940065681451 | 24.116034999999997 | 0.0005561546637814628% | 0.00000000000000000000 | - | 트랜잭션 제어 (`UserAccessService.updateLastAccessed`) |
| 8 | 0.00065681444991789819 | 4 | 2.218591 | 8.874364 | 0.00020465714727542562% | 1.00000000000000000000 | `SeasonRepository.findByStatus` (호출 경로 미상, 요청 경로 밖) | `season`을 상태로 1행 조회 |
| 9 | 0.00016420361247947455 | 1 | 1.113402 | 1.113402 | 2.5676845922789895e-05% | 3.0000000000000000 | `UserLeagueRepository.findRankEntriesBySeasonId` (호출 경로 미상, 요청 경로 밖) | `user_league` + `users` 조인으로 시즌 참여자의 LP와 리그 조회 |
| 10 | 0.00082101806239737274 | 5 | 0.060501200000000005 | 0.302506 | 6.9762762710319175e-06% | 0.00000000000000000000 | - | 커넥션 초기화 (JDBC 드라이버) |
| 11 | 0.00623973727422003284 | 38 | 0.0018576842105263159 | 0.070592 | 1.6279653776278329e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select sf1_0.id,sf1_0.actor_id,u1_0.nickname,u1_0.profile_img_number,u1_0.handle,sf1_0.event_type,sf1_0.event_value,sf1_0.created_at from user_feed uf1_0 join social_feed sf1_0 on sf1_0.id=uf1_0.feed_id join users u1_0 on (u1_0.deleted_at IS NULL) and u1_0.id=sf1_0.actor_id where uf1_0.user_id=$1 and uf1_0.is_hidden=$3 order by sf1_0.created_at desc,sf1_0.id desc fetch first $2 rows only

[2] select c1_0.actor_id from congratulation c1_0 where c1_0.user_id=$1 and c1_0.actor_id in ($2,$3,$4,$5) and c1_0.created_at>=$6 group by c1_0.actor_id having count(c1_0.id)>=$7

[3] select c1_0.feed_id from congratulation c1_0 where c1_0.user_id=$1 and c1_0.feed_id in ($2,$3,$4,$5)

[4] BEGIN READ ONLY

[5] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[6] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[7] BEGIN

[8] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$1

[9] select $2,u1_0.id,ul1_0.league_point,ul1_0.league_id from user_league ul1_0 join users u1_0 on u1_0.id=ul1_0.user_id and (u1_0.deleted_at IS NULL) where ul1_0.season_id=$1 and u1_0.deleted_at is null

[10] SET application_name = 'PostgreSQL JDBC Driver'

[11] COMMIT
