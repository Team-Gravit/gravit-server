# query-stats-summary-0 — wrong-answered-notes

상태: 0 = 원본 (단, `bookmark (user_id, problem_id)` UNIQUE 인덱스 V38이 앞 대상에서 이미 적용된 상태다)
측정: VU 50 / 유지 1m (총 2m) / 캐시 cold / 요청 45872건
직전 상태 대비: - (이 대상의 첫 측정)

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 45872 | 7.283352535708062 | 334101.947518001 | 54.79509378993013% | 60.0000000000000000 | `OptionRepository.findAllByProblemIdIn` | OBJECTIVE 문제 15건의 선택지를 `problem_id IN (...)`로 읽고 `problem_id` 순으로 정렬 |
| 2 | 1.00000000000000000000 | 45872 | 4.0971767350671575 | 187945.69119100034 | 30.82442904846952% | 30.0000000000000000 | `WrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId` | `wrong_answered_note ⋈ problem ⋈ lesson ⋈ unit` 내부 조인 + `bookmark` LEFT JOIN, `user_id`/`unit.id`/`resolved_at IS NULL`로 걸러 문제 상세를 읽음 |
| 3 | 1.00000000000000000000 | 45872 | 1.6740161849494228 | 76790.47043599872 | 12.594182886308074% | 15.0000000000000000 | `AnswerRepository.findByProblemIdIn` | SUBJECTIVE 문제 15건의 정답을 `problem_id IN (...)`로 읽고 `problem_id` 순으로 정렬 |
| 4 | 1.00000000000000000000 | 45872 | 0.07258027341297645 | 3329.402302000005 | 0.5460456389368105% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` | `users` PK 단건 조회 (인증 필터) |
| 5 | 2.0000000000000000 | 91744 | 0.029648312816097106 | 2720.054811000024 | 0.4461083198997713% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 6 | 1.00000000000000000000 | 45872 | 0.05624162264562195 | 2579.9157139999975 | 0.423124512050705% | 1.00000000000000000000 | `UnitRepository.findUnitSummaryById` | `unit` PK 단건 조회, DTO 프로젝션 |
| 7 | 1.00000000000000000000 | 45872 | 0.04753245295605129 | 2180.408681999994 | 0.35760251958462586% | 0.000000000000000000000000 | `UserAccessService.updateLastAccessed` (`LastAccessInterceptor.preHandle`) | `users.last_accessed_at` 갱신 |
| 8 | 1.00008719916288803627 | 45876 | 0.0017806529775917619 | 81.68923600000696 | 0.013397615253370972% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 9 | 0.000087199162888036274852 | 4 | 0.01655175 | 0.066207 | 1.085841852015676e-05% | 0.00000000000000000000 | 미상 (측정 대상 API 밖. 시즌 스케줄러로 추정되나 Grep으로 특정하지 못함) | 종료 시점이 지난 `season`을 `FOR NO KEY UPDATE`로 조회 |
| 10 | 0.00098099058249040809 | 45 | 0.0006213333333333333 | 0.02796000000000001 | 4.585638706233225e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 11 | 0.000043599581444018137426 | 2 | 0.0006875 | 0.001375 | 2.2550977185517458e-07% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select o1_0.id,o1_0.content,o1_0.explanation,o1_0.is_answer,o1_0.problem_id from option o1_0 where o1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by o1_0.problem_id

[2] select p1_0.id,p1_0.problem_type,p1_0.instruction,p1_0.content,case when b1_0.id is not null then $4 else $5 end from wrong_answered_note wan1_0 join problem p1_0 on p1_0.id=wan1_0.problem_id join lesson l1_0 on l1_0.id=p1_0.lesson_id join unit u1_0 on u1_0.id=l1_0.unit_id left join bookmark b1_0 on b1_0.problem_id=p1_0.id and b1_0.user_id=$1 where wan1_0.user_id=$2 and u1_0.id=$3 and wan1_0.resolved_at is null

[3] select a1_0.id,a1_0.content,a1_0.explanation,a1_0.problem_id from answer a1_0 where a1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by a1_0.problem_id

[4] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[5] BEGIN READ ONLY

[6] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 where u1_0.id=$1

[7] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[8] BEGIN

[9] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[10] COMMIT

[11] ROLLBACK
