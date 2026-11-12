-- Unit: SQL 튜닝과 실행 계획 (Unit ID: 247)
-- Chapter: 데이터베이스 (Chapter ID: 4)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (1027, 247, '옵티마이저와 실행 계획 읽기'),
       (1028, 247, '인덱스를 타지 못하는 쿼리 패턴'),
       (1029, 247, '커버링 인덱스와 튜닝 수칙 적용');

-- =====================================================
-- Lesson 1027: 옵티마이저와 실행 계획 읽기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6341, 1027, '아래 옵티마이저 방식에 대한 설명으로 옳은 것은?', 'SQL을 처리할 실행 방법을 고를 때, 미리 정해 둔 접근 경로의 우선순위 규칙을 따르는 방식이다. 예를 들어 "조건 컬럼에 인덱스가 있으면 풀 테이블 스캔보다 인덱스 경로를 먼저 쓴다" 같은 규칙이 정해져 있고, 판단할 때 참고하는 정보는 인덱스가 있는지와 SQL이 어떤 형태로 쓰였는지뿐이다.', 'OBJECTIVE'),
       (6342, 1027, '아래 실행 계획에 대한 해석으로 옳은 것은?', 'orders 테이블은 약 500만 행이다. 아래 쿼리 앞에 EXPLAIN을 붙여 실행 계획을 확인했다.

```sql
SELECT order_id, amount, memo
FROM orders
WHERE memo = ''환불 요청''
ORDER BY amount DESC;
```

| id | table | type | key | rows | Extra |
| --- | --- | --- | --- | --- | --- |
| 1 | orders | ALL | NULL | 4,980,000 | Using where; Using filesort |', 'OBJECTIVE'),
       (6343, 1027, '아래 네 쿼리를 실행 계획의 type이 빠른 것부터 느린 것 순서로 나열한 것은?', 'orders 테이블의 인덱스 구성은 다음과 같다.

- PRIMARY KEY: id
- 일반 인덱스 idx_user: user_id
- 일반 인덱스 idx_created: created_at
- memo 컬럼에는 인덱스가 없다.

```sql
A: SELECT * FROM orders WHERE created_at BETWEEN ''2024-03-01'' AND ''2024-03-07'';
B: SELECT * FROM orders WHERE id = 1001;
C: SELECT * FROM orders WHERE memo = ''선물 포장'';
D: SELECT * FROM orders WHERE user_id = 7;
```

(각 쿼리는 위 인덱스를 쓸 수 있으면 쓰는 것으로 가정한다.)', 'OBJECTIVE'),
       (6344, 1027, '아래 상황에서 인덱스를 삭제한 뒤 다시 확인한 실행 계획으로 옳은 것은?', 'orders 테이블은 약 500만 행이다. 인덱스 idx_status_created(status, created_at)가 있을 때 아래 쿼리의 실행 계획은 type=range, key=idx_status_created, rows=1,200이었고, 실제 결과도 1,200건 안팎이었다. 이후 운영자가 이 인덱스를 삭제해, orders 테이블에는 PK(order_id) 말고는 인덱스가 남지 않았다.

```sql
EXPLAIN
SELECT order_id, status, created_at
FROM orders
WHERE status = ''pending'' AND created_at > ''2024-01-01'';
```', 'OBJECTIVE'),
       (6345, 1027, '아래 상황에서 두 환경의 실행 방법을 고른 옵티마이저의 방식을 가리키는 용어는?', '같은 쿼리와 같은 인덱스 idx_status(status)를 두 데이터베이스에 그대로 배포했다. 두 환경의 MySQL 버전과 설정도 같다.

```sql
SELECT * FROM orders WHERE status = ''pending'';
```

| 환경 | 전체 행 수 | pending 비율 | type | key |
| --- | --- | --- | --- | --- |
| 개발 DB | 10,000 | 90% | ALL | NULL |
| 운영 DB | 10,000,000 | 0.1% | ref | idx_status |

쿼리 문장도 인덱스도 같은데, 개발 DB에서는 인덱스를 두고도 테이블 전체를 읽는 쪽을 골랐다.', 'SUBJECTIVE'),
       (6346, 1027, '아래 상황에서 동료가 SELECT 앞에 붙여 실행한 키워드는?', 'MySQL 8.0의 orders 테이블에서 아래 쿼리가 매번 8초씩 걸렸다. 쿼리 앞에 EXPLAIN을 붙여 보니 rows가 1,200으로 나와 문제가 없어 보였다.

```sql
SELECT * FROM orders
WHERE status = ''pending'' AND created_at > ''2024-01-01'';
```

동료가 SELECT 앞에 붙이는 키워드를 바꿔 다시 실행하자, 이번에는 쿼리가 실제로 8초 동안 돈 뒤 아래 결과가 나왔다.

```
-> Filter: ((orders.status = ''pending'') and (orders.created_at > ''2024-01-01''))
   (cost=1520 rows=1200) (actual time=0.08..7950 rows=2310000 loops=1)
```

추정 rows는 1,200인데 실제로 처리한 행은 231만 건이었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6341
(17083, 6341, '대량의 데이터를 바꾼 뒤 통계를 갱신하지 않으면, 실제 데이터와 어긋난 실행 계획을 고를 수 있다.', '비용 기반 옵티마이저(CBO)의 약점을 갖다 붙인 오개념이다. 본문의 방식은 통계를 아예 참고하지 않으므로 통계가 낡아 계획이 틀어지는 일이 없다. 대신 처음부터 데이터 상황을 모른다.', false),
(17084, 6341, '테이블의 거의 모든 행이 조건에 걸려도, 행을 하나씩 찾아가는 쪽이 더 느린지 따지지 않고 같은 경로를 고른다.', '규칙 기반 옵티마이저(RBO)는 행 수·데이터 분포를 보지 않고 규칙의 순위만 따른다. 그래서 인덱스로 읽는 편이 오히려 느린 상황에서도 규칙대로 인덱스를 고른다. 데이터 분포를 반영하지 못하는 약점이 드러나는 장면이다.', true),
(17085, 6341, '후보 실행 방법마다 예상 비용을 계산해 비교하므로, 데이터가 바뀌면 같은 SQL이라도 선택이 달라진다.', 'CBO의 동작을 갖다 붙인 오개념이다. 본문의 방식은 비용을 계산하지 않고 규칙 순위로 고르므로, 인덱스와 SQL 형태가 같으면 데이터가 바뀌어도 같은 계획을 고른다.', false),
(17086, 6341, 'MySQL·Oracle 등 현재 대부분의 RDBMS가 기본 옵티마이저로 채택하고 있는 방식이다.', '현재 대부분의 RDBMS가 기본으로 쓰는 것은 통계를 바탕으로 비용을 계산하는 CBO다. 규칙 기반 방식은 데이터 분포를 반영하지 못해 지금은 거의 쓰이지 않는다.', false),

-- 문제 6342
(17087, 6342, 'type이 ALL이므로 인덱스의 리프를 처음부터 끝까지 순서대로 훑었다.', 'type index(인덱스 전체 스캔)와 혼동한 해석이다. ALL은 인덱스를 쓰지 않고 테이블 자체를 전부 읽는 풀 테이블 스캔이며, 그래서 key도 NULL로 나온다.', false),
(17088, 6342, 'rows 4,980,000은 이 쿼리가 실제로 읽은 행 수를 정확히 센 값이다.', 'rows는 통계를 바탕으로 한 추정치다. EXPLAIN은 쿼리를 실제로 실행하지 않으므로 실제로 읽은 행 수를 알려 주지 않으며, 실측값은 MySQL 8.0의 EXPLAIN ANALYZE로 확인한다.', false),
(17089, 6342, 'Extra의 Using filesort는 인덱스 순서 덕분에 정렬 작업을 건너뛰었다는 표시다.', '반대로 읽은 오개념이다. Using filesort는 결과를 정렬하려고 별도 작업이 발생한다는 신호로, Using temporary와 함께 튜닝할 때 점검하는 항목이다.', false),
(17090, 6342, '어떤 인덱스도 쓰지 못한 채 테이블 전체를 읽고, 결과를 따로 정렬할 것으로 예상된다.', 'key가 NULL이라 사용한 인덱스가 없고, type ALL은 풀 테이블 스캔이다. Extra의 Using filesort는 ORDER BY amount를 위해 별도 정렬이 일어난다는 뜻이라 두 가지 모두 개선 대상이다.', true),

-- 문제 6343
(17091, 6343, 'B → D → A → C', 'B는 PK로 단 1건을 찾는 const, D는 일반 인덱스 동등 비교인 ref, A는 BETWEEN 범위 스캔인 range, C는 인덱스가 없어 풀 테이블 스캔인 ALL이다. 읽는 범위가 좁은 것부터 넓은 순서다.', true),
(17092, 6343, 'D → B → A → C', 'ref를 const보다 앞에 둔 오류다. user_id는 일반 인덱스라 같은 값이 여러 행일 수 있지만, PK 동등 조건은 결과가 최대 1건으로 정해져 const가 가장 빠르다.', false),
(17093, 6343, 'B → A → D → C', 'range를 ref보다 앞에 둔 오류다. 동등 비교(ref)는 한 값에 해당하는 행만 찾지만, BETWEEN은 일정 구간을 이어 읽어야 해 range가 ref보다 느린 쪽에 놓인다.', false),
(17094, 6343, 'B → D → C → A', 'WHERE 조건이 있으면 풀 스캔도 적게 읽는다고 본 오개념이다. C는 memo에 인덱스가 없어 조건과 상관없이 테이블 전체를 읽는 ALL이라, 인덱스 범위 스캔인 A보다 느리다.', false),

-- 문제 6344
(17095, 6344, 'type=index, key=NULL, rows≈5,000,000', 'index는 인덱스 전체를 처음부터 끝까지 읽는 방식이라 key에 그 인덱스 이름이 나온다. 조건을 받칠 인덱스가 없어 key가 NULL이면 테이블을 직접 다 읽는 ALL이 된다.', false),
(17096, 6344, 'type=ALL, key=NULL, rows≈1,200', 'rows를 결과 건수로 착각한 오개념이다. rows는 읽을 것으로 추정되는 행 수라, 풀 테이블 스캔이면 결과가 1,200건이어도 rows는 전체 행 수에 가까워진다.', false),
(17097, 6344, 'type=ALL, key=NULL, rows≈5,000,000', '조건 컬럼을 받쳐 줄 인덱스가 사라져 옵티마이저는 테이블 전체를 읽는 풀 테이블 스캔밖에 고를 수 없다. 그래서 type은 ALL, key는 NULL, rows는 전체 행 수에 가까운 추정치가 된다.', true),
(17098, 6344, 'type=range, key=PRIMARY, rows≈1,200', 'PK가 남아 있으면 범위 스캔이 유지된다고 본 오개념이다. PK 인덱스는 order_id 기준으로 정렬돼 있어 status·created_at 조건의 탐색 시작점을 정해 주지 못한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2070, 6345, '비용 기반 옵티마이저,비용기반 옵티마이저,비용 기반 옵티마이저(CBO),CBO,Cost Based Optimizer,Cost-Based Optimizer,비용 기반,비용기반,비용 기반 최적화', 'SQL 문장과 인덱스가 같은데 환경마다 계획이 갈렸다는 것은, 옵티마이저가 레코드 수·데이터 분포 같은 통계를 보고 후보 계획마다 예상 비용을 계산해 골랐다는 뜻이다. 이것이 비용 기반 옵티마이저(CBO)다. 개발 DB는 pending이 90%라 인덱스로 거의 모든 행을 하나씩 찾느니 테이블을 통째로 읽는 편이 싸다고 판단했고, 운영 DB는 0.1%만 걸려 인덱스 쪽이 훨씬 싸다고 판단했다.

규칙 기반 옵티마이저(RBO)와 헷갈리지 않게 한다. RBO는 "인덱스가 있으면 인덱스 우선" 같은 규칙과 SQL 형태만 보므로, 인덱스와 쿼리가 같은 두 환경에서 서로 다른 계획을 고를 수 없다. CBO는 이렇게 데이터에 맞춰 더 나은 선택을 하는 대신, 통계가 낡으면 잘못된 계획을 고를 수 있어 대량 변경 뒤에는 ANALYZE TABLE 등으로 통계를 갱신해야 한다.'),
       (2071, 6346, 'EXPLAIN ANALYZE,explain analyze,EXPLAINANALYZE,EXPLAIN ANALYSE', 'EXPLAIN ANALYZE는 쿼리를 실제로 실행하면서 단계마다 실측값(actual time, actual rows)을 함께 보여 준다. 그래서 이번에는 8초가 걸린 뒤에 결과가 나왔고, 추정 rows=1200 옆에 실제 처리 행 rows=2310000이 찍혔다. 그냥 EXPLAIN은 쿼리를 실행하지 않고 통계 기반의 추정치만 보여 주므로, 추정이 실제와 크게 어긋난 상황을 잡아내지 못한다.

ANALYZE TABLE과 구분한다. ANALYZE TABLE은 테이블의 통계 정보를 갱신하는 명령이지 실행 계획이나 실측값을 출력하지 않는다. 이 사례처럼 추정 1,200건과 실제 231만 건이 크게 다르다면 통계가 실제와 어긋났을 가능성이 커서, EXPLAIN ANALYZE로 확인한 다음 ANALYZE TABLE로 통계를 갱신하는 순서로 이어진다.');

-- =====================================================
-- Lesson 1028: 인덱스를 타지 못하는 쿼리 패턴
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6347, 1028, '아래 쿼리를 같은 결과를 내면서 created_at 인덱스를 쓸 수 있도록 고친 것은?', 'orders 테이블의 created_at(DATETIME) 컬럼에 인덱스 idx_created가 있다. 최근 7일 안에 생성된 주문을 찾는 아래 쿼리는 실행 계획에서 key가 NULL로 나왔다.

```sql
SELECT order_id FROM orders
WHERE created_at + INTERVAL 7 DAY > NOW();
```', 'OBJECTIVE'),
       (6348, 1028, '아래 요구를 처리하는 방법 중 인덱스를 활용할 수 있는 것은?', 'users 테이블(300만 행)의 email 컬럼에는 인덱스가 이미 있다. 운영팀이 "gmail.com 도메인 회원 목록"을 하루에도 수십 번 조회하는데, 지금 쓰는 아래 쿼리는 실행 계획이 type=ALL로 나온다.

```sql
SELECT user_id FROM users WHERE email LIKE ''%@gmail.com'';
```', 'OBJECTIVE'),
       (6349, 1028, '아래 쿼리의 실행 계획에 대한 판단으로 옳은 것은?', 'users 테이블(200만 행)의 인덱스 구성은 다음과 같다.

- 인덱스 idx_name: name
- nickname 컬럼에는 인덱스가 없다.

```sql
SELECT * FROM users WHERE name = ''kim'' OR nickname = ''kim'';
```

EXPLAIN 결과는 type=ALL, key=NULL이었다.', 'OBJECTIVE'),
       (6350, 1028, '아래 요구를 처리하는 조건 중 order_no 인덱스로 탐색 범위를 좁힐 수 있는 것은?', 'orders 테이블의 order_no 컬럼은 VARCHAR(12)이고, ''202403150001''처럼 날짜 8자리 뒤에 일련번호 4자리를 붙인 값이 들어 있다. 이 컬럼에는 인덱스 idx_order_no가 있다. 2024년 3월 15일에 만들어진 주문을 order_no만으로 모두 찾으려 한다.', 'OBJECTIVE'),
       (6351, 1028, '아래 상황에서 인덱스를 쓰지 못하게 만든 원인을 가리키는 용어는?', 'members 테이블의 member_no 컬럼은 VARCHAR(20)이고 인덱스 idx_member_no가 있다. 애플리케이션에서 회원 번호를 Long 변수에 담아 그대로 바인딩했더니, 실제로 DB에 전달된 쿼리와 실행 계획은 아래와 같았다.

```sql
SELECT * FROM members WHERE member_no = 1029384;
```

| type | key | rows |
| --- | --- | --- |
| ALL | NULL | 3,400,000 |

쿼리 문장은 그대로 두고 바인딩하는 값만 String으로 바꿔 ''1029384''가 전달되게 하자, type=ref, key=idx_member_no, rows=1로 바뀌었다.', 'SUBJECTIVE'),
       (6352, 1028, '아래 상황에서 두 SELECT 문 사이에 넣은 키워드는?', 'users 테이블(200만 행)에서 아래 쿼리가 type=ALL로 처리돼 느렸다. name에는 인덱스가 있었지만 nickname에는 없었다.

```sql
SELECT user_id, name, nickname FROM users
WHERE name = ''kim'' OR nickname = ''kim'';
```

nickname에도 인덱스를 만든 뒤, 쿼리를 조건 하나씩만 가진 SELECT 두 개로 나누고 키워드 하나로 이어 붙였다. 두 SELECT는 각각 자기 인덱스로 ref 접근을 했다. name과 nickname이 모두 kim인 회원 1명은 두 SELECT에 다 걸렸지만, 최종 결과에는 한 번만 나왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6347
(17099, 6347, 'WHERE DATE(created_at) > DATE(NOW() - INTERVAL 7 DAY)', '여전히 인덱스 컬럼을 DATE()로 가공한다. 가공된 값은 인덱스에 저장된 원본 값과 비교할 수 없어 인덱스를 타지 못하고, 날짜 단위로 잘려 결과 범위도 달라진다.', false),
(17100, 6347, 'WHERE created_at < NOW() - INTERVAL 7 DAY', '컬럼을 가공하지 않아 인덱스는 쓸 수 있지만 부등호 방향이 반대라 7일보다 오래된 주문을 찾는다. 연산을 조건 값 쪽으로 옮길 때 비교 방향도 함께 확인해야 한다.', false),
(17101, 6347, 'WHERE created_at > NOW() - INTERVAL 7 DAY', '양변에서 7일을 빼 연산을 조건 값 쪽으로 옮긴 형태라 결과가 같다. 컬럼이 원본 그대로 남아 인덱스에 저장된 값과 바로 비교할 수 있으므로 범위 스캔이 가능하다.', true),
(17102, 6347, 'WHERE UNIX_TIMESTAMP(created_at) > UNIX_TIMESTAMP(NOW()) - 604800', '결과는 같지만 컬럼을 함수로 감싸 형태만 바꾼 것이다. 함수를 적용한 결과는 인덱스에 없는 값이라 인덱스 컬럼 가공 문제가 그대로 남는다.', false),

-- 문제 6348
(17103, 6348, 'email 컬럼에 같은 구성의 인덱스를 하나 더 만들고 쿼리는 그대로 둔다.', '인덱스가 없어서가 아니라 패턴이 %로 시작해 탐색 시작점을 못 찾는 것이 원인이다. 인덱스를 늘려도 앞쪽 와일드카드는 그대로라 풀 스캔이 이어지고 쓰기 비용만 는다.', false),
(17104, 6348, '도메인만 담는 email_domain 컬럼에 인덱스를 만들고, email_domain = ''gmail.com''으로 조회한다.', '도메인을 별도 컬럼으로 떼면 조건이 동등 비교가 되어 정렬된 인덱스에서 바로 시작점을 찾는다. 뒷부분 검색이 잦을 때 앞쪽 와일드카드를 피하는 방법이다.', true),
(17105, 6348, '조건을 email LIKE ''gmail.com%''로 바꿔 전방 일치 검색으로 만든다.', '전방 일치라 인덱스는 탈 수 있지만, gmail.com으로 시작하는 이메일을 찾게 되어 결과가 달라진다. 도메인은 이메일의 뒷부분에 있다.', false),
(17106, 6348, '조건을 REVERSE(email) LIKE ''moc.liamg@%''로 바꿔 와일드카드를 뒤로 보낸다.', '와일드카드는 뒤로 갔지만 인덱스 컬럼 email을 REVERSE()로 가공했다. 가공된 값은 인덱스에 없어 탐색 시작점을 못 찾는 문제가 그대로다.', false),

-- 문제 6349
(17107, 6349, '두 조건의 순서를 바꿔 쓰면 name 조건이 먼저 인덱스로 걸러져 풀 스캔을 피한다.', 'OR 조건의 처리 방식은 작성 순서와 무관하다. 순서를 바꿔도 nickname 조건을 받칠 인덱스가 없다는 사실은 같아 풀 스캔이 그대로다.', false),
(17108, 6349, 'name 조건이 인덱스를 타므로, 테이블에서는 name 인덱스로 찾은 범위만 읽으면 된다.', 'AND처럼 생각한 오개념이다. OR는 name이 kim이 아니어도 nickname이 kim이면 결과에 넣어야 하므로, name 인덱스 범위만 읽으면 그런 행을 놓친다.', false),
(17109, 6349, '조건을 ''kim'' IN (name, nickname)으로 바꿔 쓰면 name 인덱스 하나로 두 조건을 처리한다.', 'IN으로 바꾸는 방법은 같은 컬럼의 OR에만 통한다. 이 식은 두 컬럼 비교를 묶어 쓴 것일 뿐 원래 OR와 뜻이 같아, nickname 쪽 인덱스가 없다는 문제가 남는다.', false),
(17110, 6349, 'nickname이 kim인 행은 어디에나 있을 수 있어, 그 조건을 확인하려면 결국 테이블 전체를 읽어야 한다.', 'OR는 둘 중 하나만 맞아도 결과에 넣는다. nickname 조건은 인덱스가 없어 어느 행이 해당하는지 미리 알 수 없으므로 전체를 읽어야 하고, 그 김에 name 조건도 함께 검사하는 풀 스캔이 된다.', true),

-- 문제 6350
(17111, 6350, 'order_no LIKE ''20240315%''', '컬럼을 가공하지 않은 전방 일치 패턴이다. 인덱스는 문자열 앞부분부터 정렬돼 있으므로 20240315로 시작하는 위치를 찾아 그 구간만 읽으면 된다.', true),
(17112, 6350, 'LEFT(order_no, 8) = ''20240315''', '결과는 같지만 인덱스 컬럼을 LEFT()로 가공했다. 잘라 낸 값은 인덱스에 저장된 원본과 비교할 수 없어 인덱스를 타지 못한다.', false),
(17113, 6350, 'order_no BETWEEN 202403150000 AND 202403159999', 'VARCHAR 컬럼을 숫자와 비교해 암시적 형변환이 일어난다. 컬럼 쪽 값이 숫자로 바뀌어 비교되므로 인덱스 컬럼 가공과 같은 효과가 나 인덱스를 쓰지 못한다.', false),
(17114, 6350, 'order_no LIKE ''%20240315%''', '앞쪽에 와일드카드가 붙어 인덱스에서 탐색 시작점을 정할 수 없다. 값 중간 어디에서든 일치하면 되는 조건이라 정렬된 인덱스 순서를 활용할 길이 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2072, 6351, '암시적 형변환,암시적 형 변환,묵시적 형변환,묵시적 형 변환,자동 형변환,자동 형 변환,암시적 타입 변환,묵시적 타입 변환,implicit conversion,implicit type conversion,implicit casting,암묵적 형변환,암묵적 형 변환,암묵적 타입 변환,묵시적 캐스팅,암시적 캐스팅,형변환,형 변환,타입 변환', 'VARCHAR 컬럼 member_no를 숫자 1029384와 비교하자, DBMS가 두 값의 타입을 맞추려고 내부적으로 형변환을 수행했다. 이것이 암시적 형변환이다. 이때 컬럼 쪽 값이 숫자로 바뀌어 비교되므로, 인덱스에 저장된 문자열 원본과 바로 비교할 수 없어 인덱스 컬럼에 함수를 씌운 것과 같은 효과가 난다. 그래서 type=ALL, key=NULL이 됐고, 컬럼 타입에 맞게 문자열 ''1029384''를 넘기자 ref 접근으로 바로 1건을 찾았다.

인덱스 컬럼 가공(DATE(created_at)처럼 개발자가 직접 함수를 씌우는 경우)과 결과는 같지만, 쿼리 문장에는 가공이 전혀 보이지 않고 DBMS가 몰래 변환한다는 점이 다르다. 그래서 쿼리만 보고는 원인을 찾기 어렵고, 실행 계획과 바인딩된 값의 타입을 함께 확인해야 한다.'),
       (2073, 6352, 'UNION,union,UNION DISTINCT,union distinct', 'OR로 묶인 조건 중 nickname 쪽이 인덱스를 타지 못하면 전체가 풀 스캔으로 처리될 수 있다. 그래서 조건별로 SELECT를 나눠 각각 자기 인덱스를 타게 하고, 두 결과를 UNION으로 합쳤다. UNION은 두 결과를 합치면서 중복 행을 제거하므로, 두 조건에 모두 걸린 회원이 한 번만 나와 원래 OR 쿼리와 결과가 같다.

UNION ALL과 구분한다. UNION ALL은 중복을 제거하지 않고 그대로 이어 붙여, name과 nickname이 모두 kim인 회원이 두 번 나온다. 또 IN으로 바꾸는 방법은 status = ''active'' OR status = ''dormant''처럼 같은 컬럼의 OR에만 쓸 수 있어, 서로 다른 두 컬럼에 걸친 이 쿼리에는 맞지 않는다.');

-- =====================================================
-- Lesson 1029: 커버링 인덱스와 튜닝 수칙 적용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6353, 1029, '아래 인덱스 구성에서 테이블의 데이터 행을 읽지 않고 인덱스만으로 처리되는 쿼리는?', 'orders 테이블의 컬럼은 order_id, user_id, status, amount, created_at이고, PK 외에는 아래 인덱스 하나만 있다.

```sql
CREATE INDEX idx_status_created ON orders(status, created_at);
```', 'OBJECTIVE'),
       (6354, 1029, '아래 실행 계획을 바탕으로, 튜닝 우선순위에 따라 가장 먼저 시도할 조치로 옳은 것은?', 'orders 테이블(약 200만 행)의 created_at(DATETIME) 컬럼에는 인덱스 idx_created가 이미 있다. 하루치 주문을 뽑는 아래 쿼리가 느려 EXPLAIN을 실행했다. 테이블 통계는 어제 갱신했다.

```sql
SELECT order_id, created_at FROM orders
WHERE DATE(created_at) = ''2024-03-15'';
```

| type | key | rows | Extra |
| --- | --- | --- | --- |
| ALL | NULL | 1,980,000 | Using where |', 'OBJECTIVE'),
       (6355, 1029, '아래 세 실행 계획을 바탕으로 한 판단으로 옳지 않은 것은?', 'orders 테이블(약 200만 행)에는 PK 외에 일반 인덱스 idx_user(user_id)만 있다.

```sql
A: SELECT * FROM orders WHERE user_id = 7;
B: SELECT * FROM orders WHERE memo LIKE ''%환불%'';
C: SELECT * FROM orders WHERE user_id = 7 ORDER BY amount;
```

| 쿼리 | type | key | rows | Extra |
| --- | --- | --- | --- | --- |
| A | ref | idx_user | 35 | (없음) |
| B | ALL | NULL | 1,990,000 | Using where |
| C | ref | idx_user | 35 | Using filesort |', 'OBJECTIVE'),
       (6356, 1029, '아래 상황에서 SELECT 목록만 바꿨을 때 기대할 수 있는 변화로 옳은 것은?', 'orders 테이블(약 500만 행)에는 PK 외에 인덱스 idx_status_created(status, created_at)가 있다. 주문 목록 화면은 상태와 생성 시각 두 값만 보여 주는데, 조회 코드는 긴 TEXT 컬럼 memo를 포함한 30개 컬럼을 모두 가져오고 있다.

```sql
SELECT * FROM orders
WHERE status = ''pending'' AND created_at > ''2024-03-01'';
```

이 SELECT *를 SELECT status, created_at으로 바꾸려 한다. WHERE 절은 그대로 둔다.', 'OBJECTIVE'),
       (6357, 1029, '아래 상황에서 변경 후 실행 계획의 Extra 칸에 나타났을 표시는?', 'MySQL의 orders 테이블(약 500만 행)에 인덱스 idx_status_created(status, created_at)가 있다. 두 쿼리의 WHERE 절은 모두 status = ''pending''으로 같고, SELECT 목록만 다르다.

| 항목 | 변경 전 | 변경 후 |
| --- | --- | --- |
| SELECT 목록 | status, amount | status, created_at |
| type / key | ref / idx_status_created | ref / idx_status_created |
| 테이블 데이터 페이지 읽기 | 18,400 | 0 |
| 응답 시간 | 1.2초 | 40ms |
| Extra | (없음) | ? |', 'SUBJECTIVE'),
       (6358, 1029, '아래 상황에서 빈칸 ___에 들어간 키워드는?', 'MySQL을 쓰는 게시판 API의 변경 전후를 비교했다. 변경 전에는 쿼리 결과를 모두 받아 온 뒤 애플리케이션 코드에서 잘라 썼다.

```java
List<Post> rows = postRepository.findByBoard(3); // 52,000건
return rows.subList(0, 10);
```

변경 후에는 자바 코드의 subList를 지우고 SQL만 아래처럼 고쳤다.

```sql
SELECT post_id, title, created_at FROM posts
WHERE board_id = 3
ORDER BY created_at DESC
___ 10;
```

| 항목 | 변경 전 | 변경 후 |
| --- | --- | --- |
| 드라이버가 받은 행 | 52,000 | 10 |
| 애플리케이션 힙 사용 | 약 48MB | 약 0.1MB |
| 응답 시간 | 1.4초 | 35ms |

같은 API의 2페이지는 마지막 줄을 `___ 10, 10`으로 바꿔 11번째부터 20번째 글을 받아 온다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6353
(17115, 6353, 'SELECT status, amount FROM orders WHERE status = ''pending'';', 'amount가 인덱스에 없다. 인덱스로 조건에 맞는 행을 찾은 뒤, amount 값을 읽으려고 행마다 테이블에 접근해야 한다.', false),
(17116, 6353, 'SELECT created_at FROM orders WHERE status = ''pending'' AND created_at > ''2024-03-01'';', 'SELECT와 WHERE에 쓰인 status, created_at이 모두 idx_status_created 안에 있다. 쿼리에 필요한 값을 인덱스에서 다 얻으니 테이블 접근 없이 결과를 돌려주는 커버링 인덱스가 동작한다.', true),
(17117, 6353, 'SELECT created_at FROM orders WHERE status = ''pending'' AND amount > 10000;', 'SELECT 목록만 보고 판단한 오개념이다. WHERE의 amount도 쿼리에 필요한 컬럼인데 인덱스에 없어, 조건을 확인하려고 테이블 행을 읽어야 한다.', false),
(17118, 6353, 'SELECT * FROM orders WHERE status = ''pending'' AND created_at > ''2024-03-01'';', 'WHERE 조건이 인덱스 컬럼뿐이라도 SELECT *는 user_id, amount 같은 인덱스 밖 컬럼까지 요구한다. 그 값을 가져오려고 테이블에 접근해야 한다.', false),

-- 문제 6354
(17119, 6354, '(created_at, order_id) 순서의 복합 인덱스를 새로 추가한다.', 'WHERE가 created_at을 DATE()로 가공하는 한 새 인덱스도 쓰이지 않는다. 인덱스 추가는 쓰기 비용까지 붙으므로, 쿼리 수정으로 해결되는지 먼저 확인한다.', false),
(17120, 6354, 'ANALYZE TABLE을 실행해 통계를 다시 갱신한다.', '통계 문제가 아니다. 통계는 어제 갱신했고, key가 NULL인 것은 컬럼 가공 때문에 인덱스 자체를 쓸 수 없어서라 통계를 고쳐도 계획은 그대로다.', false),
(17121, 6354, 'orders를 월별 테이블로 나눠 한 번에 읽는 행 수를 줄인다.', '테이블 구조 변경은 튜닝 우선순위의 마지막 단계다. 원인이 쿼리 작성 방식에 있는데 구조부터 바꾸면 비용이 크고, 컬럼 가공 문제도 그대로 남는다.', false),
(17122, 6354, 'WHERE를 created_at >= ''2024-03-15'' AND created_at < ''2024-03-16''으로 고친다.', '원인은 인덱스 컬럼을 DATE()로 가공한 것이다. 컬럼은 그대로 두고 값 쪽을 하루 범위로 바꾸면 기존 idx_created로 범위 스캔이 가능하다. 쿼리를 고쳐 기존 인덱스를 타게 하는 것이 첫 순서다.', true),

-- 문제 6355
(17123, 6355, 'B는 memo 컬럼에 인덱스를 새로 만들면, 조건을 그대로 둬도 type이 range로 바뀐다.', '거짓이다. B의 조건은 %로 시작해 정렬된 인덱스에서 탐색 시작점을 정할 수 없다. memo에 인덱스를 만들어도 앞쪽 와일드카드가 남아 있는 한 풀 테이블 스캔이 이어진다.', true),
(17124, 6355, 'B는 type이 ALL이고 key가 NULL이라, 세 쿼리 중 가장 먼저 점검할 대상이다.', '참이다. 느린 쿼리는 type ALL과 key NULL부터 확인하는데, B만 인덱스를 전혀 쓰지 못하고 약 199만 행을 읽을 것으로 추정된다. ALL은 개선 대상 1순위다.', false),
(17125, 6355, 'C는 A와 같은 인덱스로 행을 찾지만, amount 순서를 맞추려고 별도 정렬을 더 한다.', '참이다. type·key·rows가 A와 같아 행을 찾는 방식은 같고, Extra의 Using filesort는 ORDER BY amount를 위한 정렬 작업이 더해졌다는 신호다.', false),
(17126, 6355, 'A와 C의 rows 35는 추정치라, 실제로 읽은 행 수와 다를 수 있다.', '참이다. rows는 통계 기반 예상값이고 EXPLAIN은 쿼리를 실행하지 않는다. 실제로 읽은 행 수는 EXPLAIN ANALYZE로 확인해야 한다.', false),

-- 문제 6356
(17127, 6356, 'WHERE 절이 같으므로 실행 계획과 읽는 데이터 양은 그대로이고, 응답 크기만 줄어든다.', 'WHERE만 보고 계획이 같다고 본 오개념이다. 필요한 컬럼이 모두 인덱스에 들어가면 테이블 접근을 생략하는 계획이 가능해져, 읽는 데이터 양 자체가 준다.', false),
(17128, 6356, '조회하는 컬럼 수를 줄였으므로 조건에 맞아 결과로 나오는 행의 수가 줄어든다.', 'SELECT 목록은 어떤 컬럼을 보여 줄지 정할 뿐, 어떤 행을 고를지는 WHERE가 정한다. 행 수는 그대로이고 행마다 실어 나르는 값이 줄 뿐이다.', false),
(17129, 6356, '필요한 값을 인덱스에서 모두 얻어 테이블 접근이 사라지고, 전송할 데이터도 줄어든다.', '바꾼 쿼리는 SELECT·WHERE의 컬럼이 모두 idx_status_created 안에 있어 커버링 인덱스가 동작한다. 행마다 테이블을 읽지 않고 memo 같은 큰 컬럼도 보내지 않아 I/O·네트워크 비용이 함께 준다.', true),
(17130, 6356, '실행 계획의 type이 const로 바뀌어 단 1건만 읽고 끝나게 된다.', 'const는 PK·UNIQUE 인덱스로 단 1건을 찾는 접근이다. 이 쿼리는 status 동등 비교와 created_at 범위 조건이라 여러 행을 읽으며, SELECT 목록을 바꿔도 이 점은 달라지지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2074, 6357, 'Using index,using index,Usingindex,Using where; Using index', '변경 후 쿼리는 SELECT의 status, created_at과 WHERE의 status가 모두 idx_status_created 안에 있어, 인덱스만 읽고 테이블의 데이터 행에는 접근하지 않는다. 이렇게 커버링 인덱스가 동작하면 실행 계획의 Extra에 Using index가 표시된다. 표에서 테이블 데이터 페이지 읽기가 18,400에서 0으로 떨어진 것이 그 결과다. 변경 전에는 amount가 인덱스에 없어 행마다 테이블에 접근해야 했으므로 Using index가 없었다.

비슷한 이름의 표시와 구분한다. Using index condition은 인덱스 단계에서 조건을 먼저 걸러 내는 처리라 테이블 접근이 남아 있을 수 있고, Using where는 읽은 행에 조건을 적용했다는 뜻, Using filesort는 별도 정렬이 일어났다는 신호다. 테이블 접근이 사라졌음을 알려 주는 표시는 Using index다.'),
       (2075, 6358, 'LIMIT,limit,LIMIT 10,limit 10,LIMIT절,LIMIT 절', 'LIMIT은 결과로 돌려줄 행 수의 상한을 정하는 절이다. ORDER BY created_at DESC 뒤에 LIMIT 10을 붙이면 최신 10건만 결과로 받으므로, DB에서 가져오는 행이 52,000에서 10으로 줄고 애플리케이션 메모리와 응답 시간도 함께 줄었다. 화면에 10건만 보여 주면서 전체를 읽어 올 이유가 없다는 튜닝 수칙을 적용한 사례다.

헷갈리는 키워드와 구분한다. OFFSET은 앞의 몇 행을 건너뛸지 정할 뿐 가져올 행 수를 제한하지 않고, WHERE는 조건으로 행을 거를 뿐 개수를 정하지 않는다. TOP(SQL Server)은 SELECT 바로 뒤에 쓰고, FETCH FIRST(표준 SQL)는 숫자 뒤에 ROWS ONLY가 붙는다. 쿼리 맨 끝에 숫자 하나를 붙이고, 2페이지처럼 `LIMIT 10, 10`으로 건너뛸 행 수와 가져올 행 수를 함께 쓰는 형태는 MySQL의 LIMIT이다.');
