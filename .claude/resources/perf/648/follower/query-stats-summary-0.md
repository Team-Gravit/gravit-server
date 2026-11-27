# query-stats-summary-0 — follower

상태: 0 = 원본
측정: VU 50 / 유지 1m (총 2m) / Redis 해당 없음, DB 캐시 제어하지 않음 (warmup 후) / 요청 1829건

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 1829 | 2427.539571606886 | 4439969.8764689965 | 99.97469471204874% | 11.0000000000000000 | `FriendRepository.findFollowersByFolloweeId` | `friends`(followee_id 조건) + `users` 조인 + `friends` 맞팔 왼쪽 조인, `created_at` 역순 상위 11행 |
| 2 | 2.0000000000000000 | 3658 | 0.18117935046473505 | 662.7540640000016 | 0.014923217287740632% | 0.00000000000000000000 | - | 트랜잭션 제어 (읽기 전용 트랜잭션 시작. `parseUser`의 `findById`와 `FriendService.getFollowers`) |
| 3 | 1.00000000000000000000 | 1829 | 0.16546498578458171 | 302.6354589999999 | 0.006814435337256732% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` → `UserRepository.findById` (`JwtAuthFilter`) | 토큰의 사용자 id로 `users` 1행 조회 |
| 4 | 1.00000000000000000000 | 1829 | 0.06564906670311652 | 120.0721429999999 | 0.00270366155037815% | 0.00000000000000000000 | `UserAccessService.updateLastAccessed` → `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor`) | `users.last_accessed_at` 조건부 갱신 (0행 갱신) |
| 5 | 1.00000000000000000000 | 1829 | 0.015524508474576235 | 28.394326000000046 | 0.0006393543542826816% | 0.00000000000000000000 | - | 트랜잭션 제어 (`UserAccessService.updateLastAccessed`) |
| 6 | 0.00328048113723346091 | 6 | 1.3653021666666665 | 8.191813 | 0.00018445485591098263% | 1.00000000000000000000 | `SeasonRepository.findByStatus` (호출 경로 미상, 요청당 0.003회라 요청 경로 밖) | `season`을 상태로 1행 조회 |
| 7 | 0.01148168398031711318 | 21 | 0.0781607619047619 | 1.641376 | 3.695882383737825e-05% | 0.00000000000000000000 | - | 커넥션 초기화 (JDBC 드라이버) |
| 8 | 0.03116457080371787862 | 57 | 0.0024977192982456138 | 0.14237 | 3.205741859103302e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select u1_0.id,u1_0.nickname,u1_0.profile_img_number,u1_0.handle,case when f2_0.id is not null then true else false end from friends f1_0 join users u1_0 on (u1_0.deleted_at IS NULL) and u1_0.id=f1_0.follower_id left join friends f2_0 on f2_0.follower_id=$1 and f2_0.followee_id=u1_0.id where f1_0.followee_id=$2 order by f1_0.created_at desc fetch first $3 rows only

[2] BEGIN READ ONLY

[3] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[4] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[5] BEGIN

[6] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$1

[7] SET application_name = 'PostgreSQL JDBC Driver'

[8] COMMIT
