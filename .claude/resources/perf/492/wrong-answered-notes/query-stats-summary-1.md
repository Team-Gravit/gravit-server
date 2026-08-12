# query-stats-summary-1 — wrong-answered-notes

상태: 1 = 사이클 1 적용 후: 불필요한 `Unit` 조인 제거 (`WHERE l.unitId = :unitId`)
측정: VU 50 / 유지 1m (총 2m) / 캐시 cold / 요청 45275건
직전 상태 대비: 요청당 쿼리 수 6 → 6 (변화 없음). 대상 쿼리 total_ms 187945.69119100034 → 192853.78409099995 (+2.6%), mean_ms 4.0971767350671575 → 4.2596087043843 (+4.0%), 비중 30.82442904846952% → 30.991447705657233%. 쿼리 목록의 구성과 순위는 동일하고, 사라지거나 새로 생긴 쿼리는 없다. 대상 쿼리 원문에서 `join unit u1_0 on u1_0.id=l1_0.unit_id`가 빠지고 `where` 절이 `u1_0.id=$3` → `l1_0.unit_id=$3`으로 바뀌었다

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.00000000000000000000 | 45275 | 7.479063274632813 | 338614.58975900203 | 54.41509172532968% | 60.0000000000000000 | `OptionRepository.findAllByProblemIdIn` | OBJECTIVE 문제 15건의 선택지를 `problem_id IN (...)`로 읽고 `problem_id` 순으로 정렬 |
| 2 | 1.00000000000000000000 | 45275 | 4.2596087043843 | 192853.78409099995 | 30.991447705657233% | 30.0000000000000000 | `WrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId` | `wrong_answered_note ⋈ problem ⋈ lesson` 내부 조인 + `bookmark` LEFT JOIN, `user_id`/`lesson.unit_id`/`resolved_at IS NULL`로 걸러 문제 상세를 읽음 |
| 3 | 1.00000000000000000000 | 45275 | 1.704469572236333 | 77169.85988299926 | 12.40113430125055% | 15.0000000000000000 | `AnswerRepository.findByProblemIdIn` | SUBJECTIVE 문제 15건의 정답을 `problem_id IN (...)`로 읽고 `problem_id` 순으로 정렬 |
| 4 | 1.00000000000000000000 | 45275 | 0.09084572125897257 | 4113.040030000008 | 0.6609622186146609% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` | `users` PK 단건 조회 (인증 필터) |
| 5 | 2.0000000000000000 | 90550 | 0.04071503327443372 | 3686.7462630000305 | 0.5924571537568539% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 6 | 1.00000000000000000000 | 45275 | 0.07190682279403679 | 3255.5814020000066 | 0.5231693080182709% | 1.00000000000000000000 | `UnitRepository.findUnitSummaryById` | `unit` PK 단건 조회, DTO 프로젝션 |
| 7 | 1.00000000000000000000 | 45275 | 0.052404212103809966 | 2372.6007029999732 | 0.381275021177356% | 0.000000000000000000000000 | `UserAccessService.updateLastAccessed` (`LastAccessInterceptor.preHandle`) | `users.last_accessed_at` 갱신 |
| 8 | 1.00015461071231363887 | 45282 | 0.004727197650280482 | 214.05696400002105 | 0.034398781631933745% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 9 | 0.00015461071231363887 | 7 | 0.052404714285714284 | 0.3668330000000001 | 5.894976751322098e-05% | 0.00000000000000000000 | 미상 (측정 대상 API 밖. 시즌 스케줄러로 추정되나 Grep으로 특정하지 못함) | 종료 시점이 지난 `season`을 `FOR NO KEY UPDATE`로 조회 |
| 10 | 0.00097183876311430149 | 44 | 0.0006496818181818183 | 0.02858600000000001 | 4.593747165966352e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 11 | 0.000044174489232468249586 | 2 | 0.00075 | 0.0015 | 2.410487913296553e-07% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select o1_0.id,o1_0.content,o1_0.explanation,o1_0.is_answer,o1_0.problem_id from option o1_0 where o1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by o1_0.problem_id

[2] select p1_0.id,p1_0.problem_type,p1_0.instruction,p1_0.content,case when b1_0.id is not null then true else false end from wrong_answered_note wan1_0 join problem p1_0 on p1_0.id=wan1_0.problem_id join lesson l1_0 on l1_0.id=p1_0.lesson_id left join bookmark b1_0 on b1_0.problem_id=p1_0.id and b1_0.user_id=$1 where wan1_0.user_id=$2 and l1_0.unit_id=$3 and wan1_0.resolved_at is null

[3] select a1_0.id,a1_0.content,a1_0.explanation,a1_0.problem_id from answer a1_0 where a1_0.problem_id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) order by a1_0.problem_id

[4] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[5] BEGIN READ ONLY

[6] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 where u1_0.id=$1

[7] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[8] BEGIN

[9] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[10] COMMIT

[11] ROLLBACK
