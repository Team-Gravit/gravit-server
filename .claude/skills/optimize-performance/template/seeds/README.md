# 시드 모듈

성능 측정용 더미 데이터를 도메인 단위로 모듈화해 둔 것이다.
**규모만 정하면 바로 쓸 수 있어야 한다.** 매번 INSERT 문을 새로 쓰지 마라.

## 쓰는 법

`.claude/resources/perf/{이슈번호}/seeds.sql`을 아래 형태로 만든다.
변수 블록과 `\i` 줄만 있으면 된다. **모듈 본문을 복사하지 마라.**

```sql
-- PERF-{이슈번호} 시드
-- 대상: {측정할 엔드포인트들}

\set user_start 1001
\set user_count 1000

\set content_id_base 900000
\set chapter_count 10
\set units_per_chapter 5
\set lessons_per_unit 4
\set problems_per_lesson 10

\set lesson_sub_per_user 300
\set distinct_lessons 100
\set recent_days 7
\set recent_count 100
\set window_days 180

\set problem_sub_per_user 2000
\set distinct_problems 700
\set wrong_pct 30

\set daily_record_days 180

\i .claude/skills/optimize-performance/template/seeds/content.sql
\i .claude/skills/optimize-performance/template/seeds/user.sql
\i .claude/skills/optimize-performance/template/seeds/learning.sql
```

실행은 호출자가 프로젝트 루트에서 한다.

```bash
psql -h localhost -p 5433 -U postgres -d mydb -f $PERF_DIR/seeds.sql
```

## 모듈

| 모듈 | 채우는 테이블 | 선행 모듈 |
|---|---|---|
| `content.sql` | `chapter`, `unit`, `lesson`, `problem` | 없음 |
| `user.sql` | `users` | 없음 |
| `learning.sql` | `lesson_submission`, `problem_submission`, `daily_learning_record` | `content`, `user` |
| `league.sql` | `league`, `season`, `user_league`, `user_league_history` | `user` |

`\i` 순서가 곧 FK 의존 순서다. 표의 위에서 아래로 부른다.

## 변수

모듈은 psql 변수만 읽는다. 필요한 변수가 없으면 psql이 `:변수명`을 그대로 넘겨 구문 오류로 죽는다.
오류 메시지에 변수명이 찍히므로 그때 채우면 된다.

| 변수 | 쓰는 모듈 | 뜻 |
|---|---|---|
| `user_start` | user, learning, league | 시드 유저 id 시작값. k6 스크립트의 `USER_ID_START`와 일치시킨다 |
| `user_count` | user, learning, league | 시드 유저 수. k6 스크립트의 `USER_COUNT`와 일치시킨다 |
| `content_id_base` | content | 콘텐츠 id 오프셋. 앱 시드와 겹치지 않게 충분히 큰 값을 쓴다 |
| `chapter_count` | content | 챕터 수 |
| `units_per_chapter` | content | 챕터당 유닛 수 |
| `lessons_per_unit` | content | 유닛당 레슨 수 |
| `problems_per_lesson` | content | 레슨당 문제 수 |
| `lesson_sub_per_user` | learning | 유저당 레슨 제출 수 |
| `distinct_lessons` | learning | 유저당 서로 다른 레슨 수 (카디널리티) |
| `recent_days` | learning | 최근 구간의 길이(일). 주간 집계 쿼리를 재는 경우 7 |
| `recent_count` | learning | 최근 구간에 몰아넣을 제출 수. 나머지는 `window_days`에 퍼진다 |
| `window_days` | learning | 전체 제출이 퍼지는 기간(일) |
| `problem_sub_per_user` | learning | 유저당 문제 제출 수 |
| `distinct_problems` | learning | 유저당 서로 다른 문제 수 (카디널리티) |
| `wrong_pct` | learning | 오답 비율(%) |
| `daily_record_days` | learning | 유저당 일별 학습 기록 일수 |
| `league_tier_count` | league | 리그 티어 수 |
| `past_season_count` | league | 종료된 과거 시즌 수 |

## 모듈을 고칠 때

- **규모는 변수로만 조절한다.** 특정 이슈의 숫자를 모듈 본문에 박지 마라.
- 고정 콘텐츠(`content.sql`)의 값은 실제 학습 데이터처럼 보일 필요가 없다.
  FK 관계와 개수, 카디널리티만 맞으면 된다. `'perf-lesson-' || i` 수준으로 채운다.
- 모든 모듈은 **재실행해도 중복이 쌓이지 않아야 한다.** 가드를 지우지 마라.
- 카디널리티가 걸린 컬럼은 `(i % :변수)` 형태로 서로 다른 값의 개수를 명시적으로 통제한다.
  한 값에 전 행이 몰리거나 전 행이 서로 다른 값을 갖게 두지 마라.
- 새 도메인이 필요하면 새 모듈 파일을 만들고 이 표에 추가한다. 기존 모듈에 덧붙이지 마라.
- 검증 쿼리는 모듈 말미에 둔다. 행 수와 함께 카디널리티를 반드시 뽑는다.
