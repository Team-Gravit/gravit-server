calls | per_req | mean_ms | total_ms | pct | rows_per_call | query
296280 | 30.0000000000000000 | 0.4347570695423183 | 128809.82456399893 | 73.1629614619832 | 1.00000000000000000000 | insert into problem_submission (created_at,is_correct,problem_id,selected_option_id,submitted_content,updated_at,user_id) values ($1,$2,$3,$4,$5,$6,$7)
RETURNING *
7005 | 0.70929526123936816525 | 1.6373010558172738 | 11469.293896000048 | 6.514468210398746 | 9.0000000000000000 | INSERT INTO wrong_answered_note (user_id, problem_id, wrong_count, created_at, updated_at)
    SELECT $1, p.problem_id, $5, $2, $3
    FROM unnest(CAST($4 AS BIGINT[])) AS p(problem_id)
    ON CONFLICT (user_id, problem_id)
    DO UPDATE SET wrong_count = wrong_answered_note.wrong_count + $6,
                  resolved_at = $7,
                  updated_at  = EXCLUDED.updated_at
9876 | 1.00000000000000000000 | 0.833472785338191 | 8231.377227999988 | 4.675357155012593 | 0.00000000000000000000 | select ls1_0.id from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2 fetch first $3 rows only
2871 | 0.29070473876063183475 | 1.630727874259838 | 4681.819727000002 | 2.6592365715727335 | 9.0000000000000000 | INSERT INTO wrong_answered_note (user_id, problem_id, wrong_count, created_at, updated_at)
    SELECT $1, p.problem_id, $5, $2, $3
    FROM unnest(CAST($4 AS BIGINT[])) AS p(problem_id)
    ON CONFLICT (user_id, problem_id)
    DO UPDATE SET wrong_count = wrong_answered_note.wrong_count + $6,
                  resolved_at = $7,
                  updated_at  = EXCLUDED.updated_at
4625 | 0.46830700688537869583 | 0.7938449130810814 | 3671.5327230000003 | 2.0854015447074516 | 1.00000000000000000000 | select count(ls1_0.id) from lesson_submission ls1_0 where ls1_0.lesson_id=$1 and ls1_0.user_id=$2
9876 | 1.00000000000000000000 | 0.2873000690562981 | 2837.3754820000013 | 1.61160683003338 | 1.00000000000000000000 | select ul1_0.id,ul1_0.created_at,ul1_0.league_id,ul1_0.league_point,ul1_0.season_id,ul1_0.updated_at,ul1_0.user_id from user_league ul1_0 left join users u1_0 on u1_0.id=ul1_0.user_id and (u1_0.deleted_at IS NULL) where u1_0.id=$1
9876 | 1.00000000000000000000 | 0.2644012362292418 | 2611.226609000003 | 1.4831560590151405 | 1.00000000000000000000 | select l1_0.name from user_league ul1_0 join league l1_0 on ul1_0.league_id=l1_0.id where ul1_0.user_id=$1
10543 | 1.0675374645605508 | 0.15158681921654135 | 1598.1798349999979 | 0.907753504619737 | 1.00000000000000000000 | update users set created_at=$1,deleted_at=$2,email=$3,handle=$4,is_onboarded=$5,last_accessed_at=$6,level=$7,xp=$8,nickname=$9,profile_img_number=$10,provider_id=$11,role=$12,status=$13,updated_at=$14 where id=$15
9876 | 1.00000000000000000000 | 0.15345943975293638 | 1515.5654270000084 | 0.8608291743586963 | 1.00000000000000000000 | select count(distinct ls1_0.lesson_id) from lesson_submission ls1_0 where ls1_0.user_id=$1
9876 | 1.00000000000000000000 | 0.11259511857027078 | 1111.9893910000003 | 0.631601178211724 | 1.00000000000000000000 | insert into lesson_submission (accuracy,created_at,learning_time,lesson_id,updated_at,user_id) values ($1,$2,$3,$4,$5,$6)
RETURNING *
9876 | 1.00000000000000000000 | 0.09757503422438257 | 963.6510379999991 | 0.5473461670694573 | 30.0000000000000000 | select p1_0.id,p1_0.problem_type from problem p1_0 where p1_0.id in ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30)
8665 | 0.87737950587282300527 | 0.10962872117714924 | 949.9328689999994 | 0.5395543555886702 | 1.00000000000000000000 | update user_league set created_at=$1,league_id=$2,league_point=$3,season_id=$4,updated_at=$5,user_id=$6 where id=$7
9876 | 1.00000000000000000000 | 0.09412634426893511 | 929.5917759999983 | 0.5280007756634503 | 1.00000000000000000000 | select c1_0.id,u1_0.id,l1_0.id from lesson l1_0 join unit u1_0 on u1_0.id=l1_0.unit_id join chapter c1_0 on c1_0.id=u1_0.chapter_id where l1_0.id=$1
30295 | 3.0675374645605508 | 0.02640730179897659 | 800.0092079999965 | 0.45439890204224603 | 1.00000000000000000000 | select u1_0.id,u1_0.created_at,u1_0.deleted_at,u1_0.email,u1_0.handle,u1_0.is_onboarded,u1_0.last_accessed_at,u1_0.level,u1_0.xp,u1_0.nickname,u1_0.profile_img_number,u1_0.provider_id,u1_0.role,u1_0.status,u1_0.updated_at from users u1_0 where u1_0.id=$1 and (u1_0.deleted_at IS NULL)
9876 | 1.00000000000000000000 | 0.0783381183677603 | 773.6672570000028 | 0.4394368822400341 | 1.00000000000000000000 | select u1_0.id,u1_0.title,u1_0.description from unit u1_0 join lesson l1_0 on l1_0.unit_id=u1_0.id where l1_0.id=$1
798 | 0.08080194410692588092 | 0.9432390751879707 | 752.7047819999979 | 0.42753036225396623 | 1.00000000000000000000 | insert into social_feed (actor_id,created_at,event_type,event_value,updated_at) values ($1,$2,$3,$4,$5)
RETURNING *
9876 | 1.00000000000000000000 | 0.06937176670716831 | 685.1155679999988 | 0.38914022333509257 | 0.89874443094370190360 | select dlr1_0.id,dlr1_0.solved_date,dlr1_0.solved_lesson_count,dlr1_0.user_id from daily_learning_record dlr1_0 where dlr1_0.user_id=$1 and dlr1_0.solved_date=$2
8876 | 0.89874443094370190360 | 0.05661683066696699 | 502.5309889999986 | 0.285433626713712 | 1.00000000000000000000 | update daily_learning_record set solved_date=$1,solved_lesson_count=$2,user_id=$3 where id=$4
1000 | 0.10125556905629809640 | 0.4737477050000001 | 473.74770499999926 | 0.2690849490785292 | 1.00000000000000000000 | insert into daily_learning_record (solved_date,solved_lesson_count,user_id) values ($1,$2,$3)
RETURNING *
4876 | 0.49372215471850951802 | 0.0968161743232157 | 472.07566599999984 | 0.26813524415241846 | 1.00000000000000000000 | update learning set consecutive_solved_days=$1,planet_conquest_rate=$2,recent_solved_chapter_id=$3,today_solved=$4,user_id=$5,version=$6 where id=$7 and version=$8
(20 rows)
