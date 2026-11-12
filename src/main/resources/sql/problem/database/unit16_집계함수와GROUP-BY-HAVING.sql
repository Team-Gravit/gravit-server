-- Unit: 집계 함수와 GROUP BY, HAVING (Unit ID: 245)
-- Chapter: 데이터베이스 (Chapter ID: 4)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (1021, 245, '집계 함수의 NULL 처리와 COUNT 변형'),
       (1022, 245, 'GROUP BY 그룹 분할과 SELECT 절 제약'),
       (1023, 245, 'HAVING과 WHERE 구분, ROLLUP·CUBE 소계');

-- =====================================================
-- Lesson 1021: 집계 함수의 NULL 처리와 COUNT 변형
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6305, 1021, '아래 쿼리가 돌려주는 세 값을 순서대로 옳게 나열한 것은?', 'bonus 컬럼이 아래와 같은 employees 테이블(전체 6행)에 쿼리를 실행했다.

| emp_id | bonus |
| --- | --- |
| 1 | 200 |
| 2 | NULL |
| 3 | 200 |
| 4 | 500 |
| 5 | NULL |
| 6 | 300 |

```sql
SELECT COUNT(*), COUNT(bonus), COUNT(DISTINCT bonus)
FROM   employees;
```', 'OBJECTIVE'),
       (6306, 1021, '아래 상황에서 담당자 쿼리의 실제 결과와 요구사항이 원한 평균을 순서대로 옳게 짝지은 것은?', '평가 테이블 evaluations에는 직원 6명의 점수가 아래처럼 저장돼 있다. 평가서를 내지 않은 직원은 score가 NULL이고, 4번 직원은 실제로 0점을 받았다.

| emp_id | score |
| --- | --- |
| 1 | 90 |
| 2 | NULL |
| 3 | 60 |
| 4 | 0 |
| 5 | NULL |
| 6 | 90 |

요구사항은 "미제출자도 0점으로 쳐서 6명 전체의 평균을 낸다"였는데, 담당자는 아래 쿼리를 그대로 배포했다.

```sql
SELECT AVG(score) FROM evaluations;
```', 'OBJECTIVE'),
       (6307, 1021, '아래 products 테이블에 대한 집계 결과로 옳지 않은 것은?', '| name | price | released |
| --- | --- | --- |
| Keyboard | 30,000 | 2024-03-01 |
| Mouse | NULL | 2023-11-15 |
| Monitor | 250,000 | NULL |
| Cable | 5,000 | 2024-07-20 |

name은 문자열, price는 정수, released는 날짜 타입이며, 문자열은 알파벳 순서로 비교한다.', 'OBJECTIVE'),
       (6308, 1021, '표준 SQL의 집계 함수별 적용 가능 타입을 기준으로 볼 때, 아래 테이블에 쓴 쿼리 중 인자 타입이 맞지 않는 것은?', '```sql
CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_name VARCHAR(50),
    ordered_at    DATE,
    amount        INT
);
```', 'OBJECTIVE'),
       (6309, 1021, '아래 상황에서 대시보드 숫자를 바로잡으려고 COUNT(phone) 대신 쓸 집계 식은?', '회원 테이블 members에는 1,200명이 가입돼 있고, 그중 250명은 전화번호를 입력하지 않아 phone이 NULL이다. 관리자 대시보드의 "전체 회원 수" 카드는 아래 쿼리로 숫자를 채우는데, 화면에는 950이 표시되고 있다.

```sql
SELECT COUNT(phone) FROM members;
```

특정 컬럼 이름에 기대지 않고 1,200이 나오도록 위 집계 식만 바꾸려 한다.', 'SUBJECTIVE'),
       (6310, 1021, '아래 상황에서 괄호 안 컬럼 앞에 덧붙인 키워드는?', '주문 테이블 orders는 10,000행이고, 한 고객이 여러 번 주문하면 같은 customer_id가 여러 행에 반복된다. "한 번이라도 주문한 고객 수"를 구하려고 아래처럼 썼더니 10,000이 나왔다.

```sql
SELECT COUNT(customer_id) FROM orders;
```

괄호 안 customer_id 앞에 키워드 하나를 덧붙이자 결과가 1,342로 바뀌었고, 이는 회원 테이블에서 따로 확인한 실제 구매 고객 수와 일치했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6305
(16987, 6305, '6, 6, 4', 'COUNT(컬럼)도 행 수를 센다고 보고, DISTINCT에서 NULL까지 한 값으로 친 계산이다. COUNT(bonus)는 NULL이 아닌 4행만 세고, DISTINCT 역시 NULL을 뺀 뒤 중복을 지운다.', false),
(16988, 6305, '4, 4, 3', 'COUNT(*)도 NULL을 건너뛴다고 본 오해다. COUNT(*)는 컬럼 값과 무관하게 행 자체를 세므로 bonus가 NULL인 2행까지 포함해 6이 된다.', false),
(16989, 6305, '6, 4, 3', 'COUNT(*)는 행 자체 6개를, COUNT(bonus)는 NULL이 아닌 200·200·500·300의 4개를 센다. COUNT(DISTINCT bonus)는 여기서 중복된 200을 하나로 합쳐 200·500·300의 3개가 된다.', true),
(16990, 6305, '6, 4, 4', 'DISTINCT가 NULL도 하나의 값으로 남긴다고 본 계산이다. COUNT(DISTINCT 컬럼)는 NULL을 먼저 제외한 뒤 중복을 제거하므로 NULL은 개수에 들어가지 않는다.', false),

-- 문제 6306
(16991, 6306, '60, 40', 'AVG는 NULL을 뺀 4행(90·60·0·90)으로 240 ÷ 4 = 60을 낸다. 요구사항은 미제출자까지 분모에 넣는 240 ÷ 6 = 40이라 AVG(COALESCE(score, 0))이나 SUM(score) / COUNT(*)로 써야 한다.', true),
(16992, 6306, '40, 40', 'AVG가 NULL을 0으로 바꿔 계산한다고 본 오해다. AVG는 NULL 행을 분자와 분모 모두에서 빼므로 6이 아닌 4로 나눈다.', false),
(16993, 6306, '80, 40', '실제 0점과 NULL을 같은 것으로 본 계산이다. 0은 엄연한 값이라 AVG의 분모에 들어가고, 제외되는 건 NULL인 2행뿐이어서 240 ÷ 4가 된다.', false),
(16994, 6306, 'NULL, 40', 'NULL이 하나라도 섞이면 집계 결과 전체가 NULL이 된다고 본 오해다. 90 + NULL 같은 산술식은 NULL이지만, 집계 함수는 NULL 행을 건너뛰고 나머지 값으로 계산한다.', false),

-- 문제 6307
(16995, 6307, 'MIN(released)의 결과는 2023-11-15이다.', 'MIN은 날짜에도 쓸 수 있고 released가 NULL인 Monitor 행을 건너뛴다. 남은 세 날짜 가운데 가장 이른 값이 Mouse의 2023-11-15라 참이다.', false),
(16996, 6307, 'MAX(name)의 결과는 Mouse이다.', 'MAX는 문자열도 비교한다. Monitor와 Mouse는 세 번째 글자에서 n보다 u가 뒤라 Mouse가 크고, Cable·Keyboard보다도 뒤라 최댓값이 되므로 참이다.', false),
(16997, 6307, 'SUM(price)의 결과는 285,000이다.', 'SUM은 price가 NULL인 Mouse 행을 빼고 30,000 + 250,000 + 5,000을 더한다. NULL을 만났다고 합계 전체가 NULL이 되지 않으므로 참이다.', false),
(16998, 6307, 'AVG(price)의 결과는 71,250이다.', '71,250은 합계 285,000을 전체 4행으로 나눈 값이다. AVG는 NULL인 Mouse 행을 분모에서도 빼므로 285,000 ÷ 3 = 95,000이 실제 결과다.', true),

-- 문제 6308
(16999, 6308, 'SELECT MAX(customer_name) FROM orders;', 'MAX·MIN은 숫자뿐 아니라 문자 타입에도 쓸 수 있어, 정렬 순서상 가장 뒤에 오는 고객 이름을 돌려준다. 숫자 전용이라는 오해를 노린 선지다.', false),
(17000, 6308, 'SELECT AVG(ordered_at) FROM orders;', 'AVG는 SUM과 함께 숫자 타입에만 쓰는 함수다. 날짜는 더해서 나눈다는 의미가 없어 DATE 컬럼은 인자로 맞지 않는다. 날짜에는 MAX·MIN·COUNT를 쓴다.', true),
(17001, 6308, 'SELECT MIN(ordered_at) FROM orders;', 'MIN은 날짜도 비교할 수 있어 가장 이른 주문일을 돌려준다. 날짜에는 앞뒤 순서가 있으므로 최솟값과 최댓값을 정할 수 있다.', false),
(17002, 6308, 'SELECT COUNT(ordered_at) FROM orders;', 'COUNT는 값을 계산하지 않고 NULL이 아닌 행만 세므로 모든 타입에 쓸 수 있다. 날짜 컬럼이라도 주문일이 기록된 행의 수가 나온다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2058, 6309, 'COUNT(*),count(*),COUNT (*),COUNT(1),count(1)', 'COUNT(컬럼)은 그 컬럼이 NULL인 행을 세지 않아 phone이 빈 250명이 빠진 950이 나왔다. COUNT(*)는 컬럼 값을 보지 않고 행 자체를 세므로 1,200이 된다. COUNT(1)도 매 행에 NULL이 아닌 상수 1을 두고 세는 것이라 같은 결과를 낸다. COUNT(DISTINCT phone)은 NULL에 더해 중복까지 빼므로 950보다 더 작아질 수 있어 답이 될 수 없다.'),
       (2059, 6310, 'DISTINCT,distinct,디스팅트,COUNT(DISTINCT customer_id),count(distinct customer_id)', 'COUNT(컬럼)은 NULL만 뺄 뿐 같은 값이 몇 번 나오든 모두 세므로, 반복 주문이 그대로 더해져 10,000이 나왔다. DISTINCT를 붙인 COUNT(DISTINCT customer_id)는 NULL을 제외한 뒤 중복을 제거한 값의 개수를 세서 고객 1명을 한 번만 센다. GROUP BY customer_id도 고객별로 묶긴 하지만 고객마다 한 행씩 결과가 나뉘어 1,342라는 한 값이 나오지 않고, UNIQUE는 테이블에 거는 제약조건이지 집계 함수 인자에 붙이는 키워드가 아니다.');

-- =====================================================
-- Lesson 1022: GROUP BY 그룹 분할과 SELECT 절 제약
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6311, 1022, '아래 쿼리의 결과에 대한 설명으로 옳은 것은?', 'sales 테이블에는 아래 6행이 있다.

| region | product | qty |
| --- | --- | --- |
| 서울 | A | 3 |
| 부산 | B | 5 |
| 서울 | B | 2 |
| 대구 | A | NULL |
| 부산 | A | 1 |
| 서울 | C | 4 |

```sql
SELECT region, COUNT(*) AS cnt, SUM(qty) AS total
FROM   sales
GROUP  BY region;
```', 'OBJECTIVE'),
       (6312, 1022, '표준 SQL 기준으로 아래 쿼리를 실행했을 때 일어나는 일로 옳은 것은?', 'employees 테이블에서 dept_id가 10인 직원은 김철수·이영희 2명, dept_id가 20인 직원은 박민수·최지은 2명이다.

```sql
SELECT dept_id, name, AVG(salary)
FROM   employees
GROUP  BY dept_id;
```', 'OBJECTIVE'),
       (6313, 1022, '아래 요구사항을 만족하도록 쿼리를 고친 것으로 옳은 것은?', '요구사항은 "고객별로 가장 최근 주문일과 주문 총액을 한 행씩 보여 준다"이다. ONLY_FULL_GROUP_BY가 꺼진 MySQL에서 아래 쿼리가 오류 없이 돌았지만, 고객 C-102의 order_date가 실제 최근 주문일인 2024-09-30이 아니라 2024-02-11로 나왔다.

```sql
SELECT customer_id, order_date, SUM(amount)
FROM   orders
GROUP  BY customer_id;
```', 'OBJECTIVE'),
       (6314, 1022, '아래 쿼리의 결과 행 수는?', 'employees 테이블에는 아래 7행이 있다.

| emp_id | dept_id | job |
| --- | --- | --- |
| 1 | 10 | 개발 |
| 2 | 10 | 개발 |
| 3 | 10 | 기획 |
| 4 | 20 | 개발 |
| 5 | 20 | 영업 |
| 6 | 20 | 영업 |
| 7 | 30 | 기획 |

```sql
SELECT dept_id, job, COUNT(*)
FROM   employees
GROUP  BY dept_id, job;
```', 'OBJECTIVE'),
       (6315, 1022, '아래 두 번째 쿼리의 빈칸에 들어갈 절은?', '같은 orders 테이블(12,000행)에 두 쿼리를 실행했다.

```sql
SELECT COUNT(*) FROM orders;
```

| count |
| --- |
| 12,000 |

```sql
SELECT status, COUNT(*) FROM orders ________ status;
```

| status | count |
| --- | --- |
| PAID | 7,200 |
| SHIPPED | 3,100 |
| CANCELED | 1,200 |
| PENDING | 500 |

두 번째 결과의 count를 모두 더하면 첫 번째 결과와 같은 12,000이다.', 'SUBJECTIVE'),
       (6316, 1022, '아래 상황에서 두 서버의 동작 차이를 만든 MySQL sql_mode 값은?', '운영 서버와 새 스테이징 서버는 같은 MySQL 8.0 버전이고, sql_mode에 들어 있는 값 하나만 다르다. posts 테이블에는 글을 쓸 당시의 nickname이 함께 저장된다. 아래 쿼리를 두 서버에서 실행했다.

```sql
SELECT user_id, nickname, COUNT(*) AS post_cnt
FROM   posts
GROUP  BY user_id;
```

- 운영 서버: 오류 없이 실행됐고, 닉네임을 바꾼 적 있는 사용자는 옛 닉네임이 나오기도 했다.
- 스테이징 서버: ERROR 1055 "Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column ''posts.nickname''"(메시지 뒷부분 생략)으로 거부됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6311
(17003, 6311, '결과는 6행이며, 각 행에 원래 qty 값이 그대로 나온다.', 'GROUP BY가 행을 정렬만 한다고 본 오해다. 같은 region 값끼리 그룹으로 나눈 뒤 그룹마다 한 행만 내므로 6행이 서울·부산·대구 3행으로 줄어든다.', false),
(17004, 6311, '결과는 3행이며, 서울 행의 total은 9이다.', 'region 값이 서울·부산·대구 셋이라 그룹당 한 행씩 3행이 나온다. 서울 그룹은 qty가 3·2·4인 세 행이라 SUM(qty)가 9가 된다.', true),
(17005, 6311, '결과는 3행이며, 대구 행의 cnt는 0이다.', 'qty가 NULL이라 COUNT(*)가 그 행을 건너뛴다고 본 오해다. COUNT(*)는 컬럼 값과 무관하게 행을 세므로 대구 그룹의 cnt는 1이고, NULL이 되는 쪽은 total이다.', false),
(17006, 6311, '결과는 2행이며, qty가 NULL인 대구 그룹은 빠진다.', '집계 값이 NULL이면 그룹이 사라진다고 본 오해다. 그룹은 region 값으로 나뉘므로 대구 그룹은 남고, SUM이 더할 값이 없어 total만 NULL로 나온다.', false),

-- 문제 6312
(17007, 6312, '부서마다 한 행이 나오고, name에는 각 부서에서 먼저 저장된 직원 이름이 들어간다.', 'ONLY_FULL_GROUP_BY를 끈 MySQL에서 임의 값이 나오는 동작을 표준으로 착각한 것이다. 그 환경에서도 먼저 저장된 값이 나온다는 보장이 없어 버그의 원인이 된다.', false),
(17008, 6312, '직원마다 한 행씩 4행이 나오고, 평균 칸에는 소속 부서 평균이 반복된다.', 'GROUP BY가 행 수를 유지한 채 평균만 붙여 준다고 본 오해다. GROUP BY는 그룹당 한 행으로 줄이므로 직원별 행이 남는 결과는 나올 수 없다.', false),
(17009, 6312, '부서마다 한 행이 나오고, 집계되지 않은 name 칸은 NULL로 채워진다.', 'ROLLUP 소계 행에서 그룹화되지 않은 컬럼이 NULL로 표시되는 것과 혼동한 것이다. 일반 GROUP BY는 비집계 컬럼을 NULL로 바꿔 출력해 주지 않는다.', false),
(17010, 6312, '부서 하나에 이름이 둘씩 있어 어느 값을 보여줄지 정할 수 없으므로 오류가 난다.', '그룹당 한 행만 남는데 name은 그룹으로 묶이지도 집계되지도 않아, 10번 부서에서 김철수와 이영희 중 하나를 고를 근거가 없다. 그래서 SELECT 절에는 그룹화 컬럼과 집계 함수만 올 수 있다.', true),

-- 문제 6313
(17011, 6313, 'SELECT customer_id, MAX(order_date), SUM(amount) FROM orders GROUP BY customer_id;', 'order_date를 MAX로 집계하면 그룹마다 가장 늦은 날짜 하나로 정해진다. SELECT 절이 그룹화 컬럼과 집계 함수만으로 이뤄져 고객별 한 행에 최근 주문일과 총액이 함께 나온다.', true),
(17012, 6313, 'SELECT customer_id, order_date, SUM(amount) FROM orders GROUP BY customer_id, order_date;', 'order_date를 그룹 키에 넣으면 오류는 사라지지만 고객·날짜 조합마다 그룹이 나뉜다. 한 고객이 주문한 날짜 수만큼 행이 생기고 SUM도 날짜별 금액이 되어 요구사항과 어긋난다.', false),
(17013, 6313, 'SELECT DISTINCT customer_id, order_date, SUM(amount) FROM orders GROUP BY customer_id;', 'DISTINCT는 완성된 결과 행의 중복을 지울 뿐, 그룹 안에서 order_date 하나를 고르는 기준이 되지 못한다. 비집계 컬럼 문제가 그대로 남는다.', false),
(17014, 6313, 'SELECT customer_id, order_date, SUM(amount) FROM orders GROUP BY customer_id ORDER BY order_date DESC;', 'ORDER BY는 그룹화가 끝난 결과 행을 정렬할 뿐이라, 그룹 안의 여러 order_date 중 무엇을 보여줄지는 여전히 정해지지 않는다. 그룹 안의 값을 고르려면 집계 함수가 필요하다.', false),

-- 문제 6314
(17015, 6314, '3', 'GROUP BY에 적은 첫 컬럼 dept_id로만 그룹이 나뉜다고 본 계산이다. 여러 컬럼을 적으면 두 값이 모두 같은 행끼리만 한 그룹이 된다.', false),
(17016, 6314, '7', '행 하나하나가 그대로 결과로 나온다고 본 계산이다. 1·2번 행은 (10, 개발), 5·6번 행은 (20, 영업)으로 값이 같아 각각 한 그룹으로 합쳐진다.', false),
(17017, 6314, '5', '(dept_id, job) 두 값이 모두 같은 행끼리 묶이므로, 실제로 존재하는 조합 (10, 개발), (10, 기획), (20, 개발), (20, 영업), (30, 기획)의 5그룹이 각각 한 행이 된다.', true),
(17018, 6314, '9', 'dept_id 3종과 job 3종의 모든 조합 3 × 3을 만든다고 본 계산이다. GROUP BY는 테이블에 실제로 있는 값 조합만 그룹으로 만들고, 행이 없는 조합은 결과에 나타나지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2060, 6315, 'GROUP BY,group by,GROUPBY,그룹 바이,GROUP BY status,group by status', 'GROUP BY status는 status 값이 같은 행끼리 그룹으로 나눈 뒤 그룹마다 COUNT(*)를 한 번씩 적용해 그룹당 한 행을 낸다. 그래서 12,000행 전체를 센 한 값이 상태별 네 값으로 쪼개지고, 그 합은 원래 총계와 같다. ORDER BY status는 행 순서만 바꿀 뿐 그룹을 만들지 않으므로 status와 COUNT(*)를 함께 쓰면 표준 SQL에서 오류가 나고, PARTITION BY는 윈도 함수 안에서 쓰는 구문이라 행 수를 줄이지 않는다.'),
       (2061, 6316, 'ONLY_FULL_GROUP_BY,only_full_group_by,ONLY FULL GROUP BY,ONLYFULLGROUPBY', 'ONLY_FULL_GROUP_BY가 켜진 스테이징 서버는 표준 SQL처럼 GROUP BY에 없는 비집계 컬럼(nickname)을 SELECT 절에 두는 쿼리를 거부한다. 운영 서버는 이 값이 빠져 있어 그룹 안의 여러 nickname 중 임의의 하나를 돌려줬고, 그래서 옛 닉네임이 섞여 나오는 버그가 생겼다. 해결하려면 nickname을 GROUP BY에 넣거나 집계 함수로 감싸야 한다. STRICT_TRANS_TABLES 같은 다른 sql_mode 값은 잘못된 값의 저장을 막는 설정이라 GROUP BY 검사와는 관계가 없다.');

-- =====================================================
-- Lesson 1023: HAVING과 WHERE 구분, ROLLUP·CUBE 소계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6317, 1023, '아래 쿼리의 결과에 포함되는 dept_id를 모두 나열한 것은?', 'employees 테이블에는 아래 9행이 있다.

| emp_id | dept_id | salary | hire_date |
| --- | --- | --- | --- |
| 1 | 10 | 3,000 | 2023-05-01 |
| 2 | 10 | 5,000 | 2024-02-10 |
| 3 | 10 | 4,000 | 2024-06-01 |
| 4 | 20 | 6,000 | 2023-03-15 |
| 5 | 20 | 4,500 | 2024-04-01 |
| 6 | 20 | 2,000 | 2024-09-01 |
| 7 | 30 | 4,200 | 2024-01-15 |
| 8 | 30 | 2,000 | 2022-11-30 |
| 9 | 40 | 2,500 | 2024-08-20 |

```sql
SELECT dept_id, AVG(salary) AS avg_sal
FROM   employees
WHERE  hire_date >= ''2024-01-01''
GROUP  BY dept_id
HAVING AVG(salary) >= 4000;
```', 'OBJECTIVE'),
       (6318, 1023, '아래 쿼리가 실패하는 이유와 바른 수정으로 옳은 것은?', '"직원이 3명 이상인 부서만 부서별 인원 수를 보여 준다"는 요구사항으로 아래 쿼리를 작성했더니, 집계 함수를 이 위치에 쓸 수 없다는 오류가 났다.

```sql
SELECT dept_id, COUNT(*) AS cnt
FROM   employees
WHERE  COUNT(*) >= 3
GROUP  BY dept_id;
```', 'OBJECTIVE'),
       (6319, 1023, '아래 두 쿼리 A, B에 대한 설명으로 옳은 것은?', 'employees 테이블은 100만 행이고, 그중 dept_id가 10인 행은 2,000행이다. 두 쿼리는 같은 결과(1행)를 돌려준다.

쿼리 A

```sql
SELECT dept_id, AVG(salary)
FROM   employees
GROUP  BY dept_id
HAVING dept_id = 10;
```

쿼리 B

```sql
SELECT dept_id, AVG(salary)
FROM   employees
WHERE  dept_id = 10
GROUP  BY dept_id;
```', 'OBJECTIVE'),
       (6320, 1023, '아래 쿼리의 결과 행 수는?', 'employees 테이블에 존재하는 (dept_id, job) 조합은 아래 세 가지뿐이다.

| dept_id | job | salary 합계 |
| --- | --- | --- |
| 10 | 개발 | 9,000 |
| 10 | 기획 | 4,000 |
| 20 | 개발 | 7,000 |

```sql
SELECT dept_id, job, SUM(salary)
FROM   employees
GROUP  BY ROLLUP(dept_id, job);
```', 'OBJECTIVE'),
       (6321, 1023, '아래 상황에서 ROLLUP 자리에 바꿔 넣은 키워드의 이름은?', '지역·제품별 매출 보고서를 아래 쿼리로 뽑았다.

```sql
SELECT region, product, SUM(amount)
FROM   sales
GROUP  BY ROLLUP(region, product);
```

결과에는 (서울, A)처럼 지역·제품 조합별 행, (서울, NULL)처럼 지역별 소계 행, (NULL, NULL) 총계 행이 나왔다. 그런데 영업팀은 지역을 가리지 않은 제품 A 전체 매출을 보여 주는 (NULL, A) 형태의 행도 요구했다. ROLLUP 한 단어만 다른 키워드로 바꾸고 괄호 안은 그대로 두자, 기존 행은 모두 남은 채 제품별 소계 행이 추가됐다.', 'SUBJECTIVE'),
       (6322, 1023, '아래 상황에서 CUBE 대신 쓴 GROUP BY 확장 문법은?', '부서 10곳, 직급 5종인 employees 테이블에서 보고서에 필요한 행은 "부서별 급여 합계"와 "직급별 급여 합계"뿐이다. 처음에는 GROUP BY CUBE(dept_id, job)로 뽑았는데, 결과 가운데 부서·직급 조합별 행과 전체 총계 행은 쓰지 않아 매번 걸러 내야 했다.

쿼리를 아래처럼 바꾸자 부서별 합계 10행과 직급별 합계 5행, 정확히 15행만 나왔다.

```sql
SELECT dept_id, job, SUM(salary)
FROM   employees
GROUP  BY ________((dept_id), (job));
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6317
(17019, 6317, '10, 20', 'HAVING의 평균을 WHERE가 걸러 내기 전 전체 행으로 계산한 결과다. 실제로는 WHERE가 먼저 2024년 이전 입사자를 빼므로 20번 부서는 4,500·2,000만 남아 평균 3,250으로 탈락한다.', false),
(17020, 6317, '10, 20, 30', 'HAVING을 행 필터로 보고 급여 4,000 이상인 행이 하나라도 남은 그룹을 고른 결과다. HAVING은 그룹의 집계 값으로 판정하므로, 4,500인 행이 있어도 평균이 3,250인 20번 부서는 빠진다.', false),
(17021, 6317, '10, 20, 30, 40', 'HAVING 조건이 적용되지 않는다고 보고 WHERE를 통과한 그룹을 모두 고른 결과다. GROUP BY 뒤에 HAVING이 그룹별 AVG(salary)를 따져 평균 미달 그룹을 다시 걸러 낸다.', false),
(17022, 6317, '10, 30', 'WHERE가 먼저 2024년 이후 입사자만 남기면 10번은 5,000·4,000(평균 4,500), 20번은 4,500·2,000(3,250), 30번은 4,200, 40번은 2,500이 된다. 이어서 HAVING이 평균 4,000 이상인 10번과 30번만 남긴다.', true),

-- 문제 6318
(17023, 6318, 'WHERE는 그룹화 전에 행마다 평가돼 집계 값이 아직 없으므로, 조건을 GROUP BY 뒤 HAVING으로 옮긴다.', 'FROM → WHERE → GROUP BY → HAVING 순서라 WHERE 시점에는 그룹도 COUNT(*) 값도 없다. HAVING COUNT(*) >= 3으로 옮기면 그룹별 인원 수가 계산된 뒤 그룹을 걸러 낸다.', true),
(17024, 6318, 'COUNT(*)가 NULL 행까지 세는 것이 문제이므로, WHERE COUNT(dept_id) >= 3으로 바꾼다.', 'NULL 포함 여부는 이 오류와 무관하다. COUNT(dept_id)도 집계 함수라 WHERE에 두면 똑같이 거부되며, 문제는 함수 종류가 아니라 집계를 평가하는 시점이다.', false),
(17025, 6318, 'WHERE 절을 GROUP BY 뒤로 옮겨 적으면, 그룹화된 결과에 같은 조건이 걸린다.', '절의 실행 순서는 적는 위치로 바뀌지 않는다. WHERE는 문법상 GROUP BY 앞에만 올 수 있어 뒤로 옮기면 구문 오류가 나고, 그룹에 조건을 거는 절은 따로 있다.', false),
(17026, 6318, 'SELECT 절의 별칭을 써서 WHERE cnt >= 3으로 고치면, 집계 결과를 조건에 쓸 수 있다.', 'SELECT는 WHERE·GROUP BY·HAVING보다 나중에 처리되므로 WHERE 시점에는 별칭 cnt가 존재하지 않는다. 별칭으로 바꿔도 컬럼을 찾을 수 없다는 오류가 날 뿐이다.', false),

-- 문제 6319
(17027, 6319, 'A는 HAVING에 집계 함수가 없는 조건을 두었으므로 실행되지 않고 오류가 난다.', 'HAVING에는 집계 함수뿐 아니라 GROUP BY에 적힌 컬럼의 조건도 쓸 수 있다. dept_id는 그룹화 컬럼이라 A도 정상 실행되며 B와 같은 결과를 낸다.', false),
(17028, 6319, 'A는 HAVING이 WHERE보다 먼저 평가되므로, B보다 적은 행을 읽고 끝난다.', '실행 순서를 거꾸로 본 오해다. HAVING은 GROUP BY 이후에 적용되므로 A는 100만 행을 모두 그룹으로 나누고 집계한 뒤에야 10번 부서를 고른다.', false),
(17029, 6319, 'B는 그룹화 전에 행을 2,000개로 줄이므로, 그룹으로 나누고 집계할 대상이 A보다 적다.', 'WHERE는 GROUP BY 이전에 행을 걸러 B는 2,000행만 그룹화·집계한다. 결과가 같아도 집계가 필요 없는 일반 조건은 WHERE에 두는 편이 처리할 행 수를 줄여 성능상 유리하다.', true),
(17030, 6319, 'B는 WHERE로 행을 먼저 지우므로, AVG(salary)가 10번 부서 전체가 아닌 일부 행의 평균이 된다.', 'WHERE가 지우는 것은 dept_id가 10이 아닌 행뿐이라 10번 부서의 행은 하나도 빠지지 않는다. 그래서 B의 평균도 10번 부서 2,000행 전체의 평균이다.', false),

-- 문제 6320
(17031, 6320, '3', 'ROLLUP을 일반 GROUP BY dept_id, job과 같다고 본 계산이다. ROLLUP은 조합별 3행에 더해 소계와 총계 행을 추가로 만든다.', false),
(17032, 6320, '6', '조합별 3행에 dept_id별 소계 (10, NULL)·(20, NULL) 2행과 전체 총계 (NULL, NULL) 1행이 더해져 6행이다. 소계·총계 행에서 그룹화되지 않은 컬럼은 NULL로 표시된다.', true),
(17033, 6320, '5', '부서별 소계만 붙고 전체 총계는 없다고 본 계산이다. ROLLUP(A, B)는 A별 소계 위에 전체 총계 행 (NULL, NULL)까지 계층적으로 만든다.', false),
(17034, 6320, '8', 'job별 소계 (NULL, 개발)·(NULL, 기획)까지 더한 CUBE의 결과다. ROLLUP은 인자 순서대로 앞 컬럼 기준 소계만 만들어, 뒤 컬럼 job만으로 묶은 소계는 생기지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2062, 6321, 'CUBE,cube,큐브,GROUP BY CUBE,group by cube,WITH CUBE,with cube', 'CUBE(region, product)는 ROLLUP의 결과(조합별 행, region별 소계, 총계)에 product별 소계까지 더해, 두 컬럼으로 만들 수 있는 모든 그룹 조합을 집계한다. ROLLUP은 인자 순서를 따라 앞 컬럼(region) 기준 소계만 계층적으로 만들기 때문에 (NULL, A) 같은 product별 소계가 나오지 않았다. GROUPING SETS도 (product)를 적어 비슷한 행을 만들 수 있지만, 원하는 조합을 직접 하나하나 적는 문법이라 괄호 안을 그대로 둔 채 키워드만 바꾸는 이 상황과는 맞지 않는다.'),
       (2063, 6322, 'GROUPING SETS,grouping sets,GROUPINGSETS,그루핑 세트,그룹핑 세트,그루핑 셋,그룹핑 셋', 'GROUPING SETS는 집계할 그룹 조합을 괄호 안에 직접 지정하는 문법이다. (dept_id)와 (job) 두 조합만 적었으므로 부서별 합계 10행과 직급별 합계 5행만 나오고, CUBE가 함께 만들던 부서·직급 조합별 행과 총계 행은 생기지 않는다. 각 행에서 그룹 기준이 아닌 컬럼은 소계 행과 마찬가지로 NULL로 표시된다. CUBE는 가능한 모든 조합을, ROLLUP은 앞 컬럼 기준 소계와 총계를 정해진 규칙대로 만들기 때문에 이처럼 특정 조합만 골라 낼 수 없다.');
