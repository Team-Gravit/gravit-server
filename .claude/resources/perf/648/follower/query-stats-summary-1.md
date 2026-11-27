# query-stats-summary-1 — follower

상태: 1 = 사이클 1 적용 후: 인덱스 추가 (`ix_friends_followee_created`)
측정: VU 50 / 유지 1m (총 2m) / Redis 해당 없음, DB 캐시 제어하지 않음 (warmup 후) / 요청 45587건
직전 상태 대비: 요청 1829 → 45587건. 요청당 쿼리 수 SELECT 2 + UPDATE 1, 트랜잭션 3 → 같음. 대상 쿼리 mean_ms 2427.539571606886 → 0.4651968748108025, total_ms 4439969.8764689965 → 21206.92993200002, 비중 99.97469471204874% → 62.9697085800219%, 행/호출 11 → 11. `parseUser`의 `findById` mean_ms 0.16546498578458171 → 0.1027636033737688. `updateLastAccessedAt` mean_ms 0.06564906670311652 → 0.07110576655625446. 사라진 쿼리: `SET application_name = 'PostgreSQL JDBC Driver'`(-0의 21회, 커넥션 초기화). 새로 생긴 쿼리: 없음. 대상 쿼리 원문의 CASE 결과가 -0의 `true`/`false`에서 `$4`/`$5`로 정규화되어 기록됨 (애플리케이션 코드 변경 없음)

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 45587 | 0.4651968748108025 | 21206.92993200002 | 62.9697085800219% | 11.0000000000000000 | `FriendRepository.findFollowersByFolloweeId` | `friends`(followee_id 조건) + `users` 조인 + `friends` 맞팔 왼쪽 조인, `created_at` 역순 상위 11행 |
| 2 | 1.00000000000000000000 | 45587 | 0.1027636033737688 | 4684.684386999992 | 13.910227061845498% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` → `UserRepository.findById` (`JwtAuthFilter`) | 토큰의 사용자 id로 `users` 1행 조회 |
| 3 | 2.0000000000000000 | 91174 | 0.048001818906706614 | 4376.517837 | 12.995188538597068% | 0.000000000000000000000000 | - | 트랜잭션 제어 (읽기 전용 트랜잭션 시작. `parseUser`의 `findById`와 `FriendService.getFollowers`) |
| 4 | 1.00000000000000000000 | 45587 | 0.07110576655625446 | 3241.4985799999845 | 9.62497738237699% | 0.000000000000000000000000 | `UserAccessService.updateLastAccessed` → `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor`) | `users.last_accessed_at` 조건부 갱신 (0행 갱신) |
| 5 | 1.00000000000000000000 | 45587 | 0.003679769429881383 | 167.74964900000043 | 0.4980988075974079% | 0.000000000000000000000000 | - | 트랜잭션 제어 (`UserAccessService.updateLastAccessed`) |
| 6 | 0.00013161646960756356 | 6 | 0.08925966666666667 | 0.535558 | 0.0015902316504951487% | 1.00000000000000000000 | `SeasonRepository.findByStatus` (호출 경로 미상, 요청 경로 밖) | `season`을 상태로 1행 조회 |
| 7 | 0.00098712352205672670 | 45 | 0.0015671333333333337 | 0.07052099999999999 | 0.00020939791063632392% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select u1_0.id,u1_0.nickname,u1_0.profile_img_number,u1_0.handle,case when f2_0.id is not null then $4 else $5 end from friends f1_0 join users u1_0 on (u1_0.deleted_at IS NULL) and u1_0.id=f1_0.follower_id left join friends f2_0 on f2_0.follower_id=$1 and f2_0.followee_id=u1_0.id where f1_0.followee_id=$2 order by f1_0.created_at desc fetch first $3 rows only

[2] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[3] BEGIN READ ONLY

[4] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[5] BEGIN

[6] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$1

[7] COMMIT
