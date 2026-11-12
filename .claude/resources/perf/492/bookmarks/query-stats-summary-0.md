# query-stats-summary-0 — bookmarks

상태: 0 = 아무것도 적용하지 않은 원본
측정: VU 50 / ramp-up 30s + 유지 1m + ramp-down 30s / Redis cold, DB 캐시 제어하지 않음 / 요청 19941건

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 19941 | 101.58188398951914 | 2025644.3486349937 | 91.2000115838526% | 30.0000000000000000 | `BookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId` | `bookmark`를 `problem`, `lesson`, `unit`과 조인해 특정 유저, 특정 유닛의 북마크 문제 상세를 `created_at` 순으로 읽는다 |
| 2 | 1.00000000000000000000 | 19941 | 7.867449813650273 | 156884.8167340002 | 7.063380653722835% | 60.0000000000000000 | `OptionRepository.findAllByProblemIdIn` | OBJECTIVE 문제 15건의 선택지를 `problem_id IN`으로 읽는다 |
| 3 | 1.00000000000000000000 | 19941 | 1.5959442353944158 | 31824.723998000096 | 1.432835531679759% | 15.0000000000000000 | `AnswerRepository.findByProblemIdIn` | SUBJECTIVE 문제 15건의 정답을 `problem_id IN`으로 읽는다 |
| 4 | 1.00000000000000000000 | 19941 | 0.09943197743342828 | 1982.7730620000016 | 0.08926982979238429% | 1.00000000000000000000 | `UnitRepository.findUnitSummaryById` | `unit`을 PK로 단건 읽는다 |
| 5 | 1.00000000000000000000 | 19941 | 0.09042022275713398 | 1803.0696620000022 | 0.08117909452945349% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` (`UserRepository.findById`, JwtAuthFilter 경유) | `users`를 PK로 단건 읽는다 |
| 6 | 2.0000000000000000 | 39882 | 0.040689615415475784 | 1622.7832420000389 | 0.07306211012225104% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 7 | 1.00000000000000000000 | 19941 | 0.06380370457850669 | 1272.3096730000098 | 0.057282837924653475% | 0.000000000000000000000000 | `LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed` (`UserRepository`) | `users.last_accessed_at`을 오늘 첫 접근일 때만 갱신한다 |
| 8 | 1.0046136101499423 | 20033 | 0.0030089006639045625 | 60.277306999999645 | 0.0027138481147235085% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 9 | 0.00461361014994232987 | 92 | 0.03950953260869564 | 3.6348769999999986 | 0.00016365203730322417% | 0.00000000000000000000 | 미상 | `season`에서 종료 시각이 지난 시즌을 잠금 조회한다 |
| 10 | 0.00601775236948999549 | 120 | 0.01809335833333333 | 2.171203 | 9.775345750320365e-05% | 0.00000000000000000000 | 미상 (JDBC 드라이버) | 커넥션 초기화 |
| 11 | 0.00090266285542349932 | 18 | 0.002094944444444445 | 0.037709 | 1.6977616229289967e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 12 | 0.00245724888420841482 | 49 | 0.0006377755102040816 | 0.031251000000000015 | 1.407004918670718e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select p1_0.id,p1_0.problem_type,p1_0.instruction,p1_0.content,true from bookmark b1_0 join problem p1_0 on p1_0.id=b1_0.problem_id join lesson l1_0 on l1_0.id=p1_0.lesson_id join unit u1_0 on u1_0.id=l1_0.unit_id where u1_0.id=$1 and b1_0.user_id=$2 order by b1_0.created_at

[2] select o1_0.id,o1_0.content,o1_0.explanation,o1_0.is_answer,o1_0.problem_id from option o1_0 where o1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by o1_0.problem_id

[3] select a1_0.id,a1_0.content,a1_0.explanation,a1_0.problem_id from answer a1_0 where a1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by a1_0.problem_id

[4] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 where u1_0.id=$1

[5] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[6] BEGIN READ ONLY

[7] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[8] BEGIN

[9] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[10] SET application_name = 'PostgreSQL JDBC Driver'

[11] ROLLBACK

[12] COMMIT
