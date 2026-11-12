# query-stats-summary-1 — bookmarks

상태: 1 = 사이클 1 적용 후: `bookmark (user_id, problem_id)` UNIQUE 인덱스 추가
측정: VU 50 / ramp-up 30s + 유지 1m + ramp-down 30s / Redis cold, DB 캐시 제어하지 않음 / 요청 26551건
직전 상태 대비: 요청당 쿼리 수 6 → 6 (변화 없음), 대상 쿼리 mean_ms 101.58188398951914 → 7.549862536326318, total_ms 2025644.3486349937 → 200456.40020199993, 비중 91.2000115838526% → 32.318545126437755%. 대상 쿼리가 1위에서 2위로 내려가고 `option` 조회가 1위가 됐다. 요청 수가 19941 → 26551로 늘어 total_ms는 직접 비교 대상이 아니다

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 26551 | 12.100271866295044 | 321274.3183219986 | 51.79739107452778% | 60.0000000000000000 | `OptionRepository.findAllByProblemIdIn` | OBJECTIVE 문제 15건의 선택지를 `problem_id IN`으로 읽는다 |
| 2 | 1.00000000000000000000 | 26551 | 7.549862536326318 | 200456.40020199993 | 32.318545126437755% | 30.0000000000000000 | `BookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId` | `bookmark`를 `problem`, `lesson`, `unit`과 조인해 특정 유저, 특정 유닛의 북마크 문제 상세를 `created_at` 순으로 읽는다 |
| 3 | 1.00000000000000000000 | 26551 | 2.9878205807690725 | 79329.62423999973 | 12.789903631314452% | 15.0000000000000000 | `AnswerRepository.findByProblemIdIn` | SUBJECTIVE 문제 15건의 정답을 `problem_id IN`으로 읽는다 |
| 4 | 1.00000000000000000000 | 26551 | 0.23537510093781805 | 6249.444304999989 | 1.0075654735033326% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` (`UserRepository.findById`, JwtAuthFilter 경유) | `users`를 PK로 단건 읽는다 |
| 5 | 2.0000000000000000 | 53102 | 0.09832997227976366 | 5221.51818800001 | 0.8418382801314529% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 6 | 1.00000000000000000000 | 26551 | 0.15716525855899788 | 4172.894779999985 | 0.6727741699412229% | 0.000000000000000000000000 | `LastAccessInterceptor.preHandle` → `UserAccessService.updateLastAccessed` (`UserRepository`) | `users.last_accessed_at`을 오늘 첫 접근일 때만 갱신한다 |
| 7 | 1.00000000000000000000 | 26551 | 0.12921818353357706 | 3430.8719909999913 | 0.5531416864337083% | 1.00000000000000000000 | `UnitRepository.findUnitSummaryById` | `unit`을 PK로 단건 읽는다 |
| 8 | 1.00018831682422507627 | 26556 | 0.004346933499020953 | 115.43716600000596 | 0.018611335207455542% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 9 | 0.00018831682422507627 | 5 | 0.27710039999999997 | 1.385502 | 0.0002233772973307291% | 0.00000000000000000000 | 미상 | `season`에서 종료 시각이 지난 시즌을 잠금 조회한다 |
| 10 | 0.00169485141802568641 | 45 | 0.0007732444444444444 | 0.034796000000000014 | 5.609978504484334e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 11 | 0.000075326729690030507326 | 2 | 0.0007295 | 0.001459 | 2.352269984493229e-07% | 0.00000000000000000000 | - | 트랜잭션 제어 |

`query-stats-summary-0.md`에 있던 `SET application_name = 'PostgreSQL JDBC Driver'`는 이번 수집의 상위 20건에 나타나지 않았다.

## 쿼리 원문

[1] select o1_0.id,o1_0.content,o1_0.explanation,o1_0.is_answer,o1_0.problem_id from option o1_0 where o1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by o1_0.problem_id

[2] select p1_0.id,p1_0.problem_type,p1_0.instruction,p1_0.content,true from bookmark b1_0 join problem p1_0 on p1_0.id=b1_0.problem_id join lesson l1_0 on l1_0.id=p1_0.lesson_id join unit u1_0 on u1_0.id=l1_0.unit_id where u1_0.id=$1 and b1_0.user_id=$2 order by b1_0.created_at

[3] select a1_0.id,a1_0.content,a1_0.explanation,a1_0.problem_id from answer a1_0 where a1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by a1_0.problem_id

[4] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[5] BEGIN READ ONLY

[6] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[7] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 where u1_0.id=$1

[8] BEGIN

[9] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[10] COMMIT

[11] ROLLBACK
