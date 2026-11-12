# query-stats-summary-0 — units

상태: 0 = 원본 (아무것도 적용하지 않음)
측정: VU 50 / ramp-up 30s + 유지 1m + ramp-down 30s (총 2m) / Redis cold, DB 캐시 제어하지 않음 / 요청 33647건
직전 상태 대비: -

| # | 요청당 | calls | mean_ms | total_ms | 비중 | 행/호출 | 출처 | 하는 일 |
|---|---|---|---|---|---|---|---|---|
| 1 | 13.2000178321990073 | 444141 | 0.15408816826638075 | 68436.87314199883 | 72.96558285477879% | 1.00000000000000000000 | `LessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId` | 유닛 하나에서 해당 유저가 제출한 서로 다른 레슨 수를 센다 |
| 2 | 10.3032365441198324 | 346673 | 0.06126250718977414 | 21238.057155000402 | 22.6434544401578% | 1.00000000000000000000 | `LessonRepository.countTotalLessonByUnitId` | 유닛 하나에 속한 전체 레슨 수를 센다 |
| 3 | 1.00000000000000000000 | 33647 | 0.03226445582072698 | 1085.602144999997 | 1.1574402748349957% | 1.00000000000000000000 | `AuthTokenProvider.parseUser` (`JwtAuthFilter` 경유) | 토큰의 subject로 유저 엔티티 전체 컬럼을 읽는다 |
| 4 | 1.00000000000000000000 | 33647 | 0.03094173117959992 | 1041.0964290000004 | 1.1099894583493994% | 13.2000178321990073 | `UnitRepository.findAllUnitSummaryByChapterId` | 챕터에 속한 유닛의 id, title, description을 읽는다 |
| 5 | 2.0000000000000000 | 67294 | 0.011670944467560293 | 785.384536999999 | 0.8373562069154138% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 6 | 1.00000000000000000000 | 33647 | 0.01871428739560719 | 629.6796280000033 | 0.6713477539143252% | 0.000000000000000000000000 | `UserRepository.updateLastAccessedAt` (`LastAccessInterceptor` 경유) | 유저의 last_accessed_at을 갱신한다 |
| 7 | 1.00000000000000000000 | 33647 | 0.016008778613249366 | 538.6473740000002 | 0.5742915740109473% | 1.00000000000000000000 | `ChapterRepository.findChapterSummaryByChapterId` | 챕터 단건의 id, title, description을 읽는다 |
| 8 | 1.00011888132671560615 | 33651 | 0.0011243999286796838 | 37.83718199999443 | 0.04034100202800854% | 0.000000000000000000000000 | - | 트랜잭션 제어 |
| 9 | 0.00020804232175231076 | 7 | 0.011482285714285714 | 0.080376 | 8.56947639230557e-05% | 0.00000000000000000000 | - | JDBC 드라이버의 application_name 설정 |
| 10 | 0.00011888132671560615 | 4 | 0.014270999999999999 | 0.057083999999999996 | 6.086144998237919e-05% | 0.00000000000000000000 | `SeasonRepository.findCloseableActiveByNowForUpdate` | 마감 시각이 지난 ACTIVE 시즌을 잠금 조회한다 |
| 11 | 0.00166433857401848605 | 56 | 0.0007959999999999999 | 0.04457600000000002 | 4.75257514262234e-05% | 0.00000000000000000000 | - | 트랜잭션 제어 |
| 12 | 0.000089160995036704609623 | 3 | 0.0007356666666666666 | 0.0022069999999999998 | 2.3530449882823715e-06% | 0.00000000000000000000 | - | 트랜잭션 제어 |

## 쿼리 원문

[1] select count(distinct l1_0.id) from lesson_submission ls1_0 join lesson l1_0 on l1_0.id=ls1_0.lesson_id where l1_0.unit_id=$1 and ls1_0.user_id=$2

[2] select count(l1_0.id) from unit u1_0 join lesson l1_0 on l1_0.unit_id=u1_0.id where u1_0.id=$1

[3] select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)

[4] select u1_0.id,u1_0.title,u1_0.description from unit u1_0 where u1_0.chapter_id=$1

[5] BEGIN READ ONLY

[6] update users u1_0 set last_accessed_at=$1 where u1_0.id=$2 and (u1_0.last_accessed_at is null or u1_0.last_accessed_at<$3) and (u1_0.deleted_at IS NULL)

[7] select c1_0.id,c1_0.title,c1_0.description from chapter c1_0 where c1_0.id=$1

[8] BEGIN

[9] SET application_name = 'PostgreSQL JDBC Driver'

[10] select s1_0.id,s1_0.ends_at,s1_0.season_key,s1_0.starts_at,s1_0.status,s1_0.tz from season s1_0 where s1_0.status=$2 and s1_0.ends_at<=$1 for no key update

[11] COMMIT

[12] ROLLBACK
