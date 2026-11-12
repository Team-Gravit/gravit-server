-- Unit: 인덱스와 실행 계획 (Unit ID: 71)
-- Chapter: Server (Chapter ID: 6)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (497, 71, '세컨더리·커버링 인덱스와 카디널리티'),
       (655, 71, 'B+Tree 깊이와 클러스터드 인덱스'),
       (813, 71, '옵티마이저 통계와 선택도, 정렬 회피');

-- =====================================================
-- Lesson 497: 세컨더리·커버링 인덱스와 카디널리티
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3161, 497, '아래 인덱스 종류에 대한 설명으로 옳은 것은?', 'PK가 아닌 일반 컬럼에 개발자가 직접 만드는 인덱스로, 한 테이블에 여러 개를 둘 수 있다. 이 인덱스에서 조건에 맞는 항목을 찾아낸 뒤에는, 거기에 함께 저장된 PK 값으로 실제 행을 한 번 더 찾아간다.', 'OBJECTIVE'),
       (3162, 497, '아래 인덱스 정의를 바탕으로 세 쿼리의 인덱스 사용을 옳게 설명한 것은?', E'```sql\nCREATE INDEX idx_orders ON orders (created_at, status);\n\n-- Q1\nSELECT * FROM orders WHERE status = ''PAID'' AND created_at >= ''2026-01-01'';\n\n-- Q2\nSELECT * FROM orders WHERE created_at >= ''2026-01-01'';\n\n-- Q3\nSELECT * FROM orders WHERE status = ''PAID'';\n```', 'OBJECTIVE'),
       (3163, 497, '아래 실행 계획에 대한 설명으로 옳지 않은 것은?', E'orders 테이블은 1,000만 행이고, 인덱스는 idx_user (user_id) 하나뿐이다.\n\n```sql\nEXPLAIN SELECT user_id, amount FROM orders WHERE user_id = 7 ORDER BY created_at DESC;\n```\n\n```\nid | select_type | table  | type | key      | rows | Extra\n---+-------------+--------+------+----------+------+-----------------------------\n1  | SIMPLE      | orders | ref  | idx_user | 120  | Using where; Using filesort\n```', 'OBJECTIVE'),
       (3164, 497, '아래 실행 계획 비교에서 B와 D가 인덱스를 타지 못한 원인을 옳게 짚은 것은?', 'users 테이블 500만 행. phone은 VARCHAR, created_at은 DATETIME이고 두 컬럼 각각에 인덱스가 하나씩 있다.

| 쿼리 | WHERE 절 | type | key |
|---|---|---|---|
| A | phone = ''01012345678'' | ref | idx_phone |
| B | phone = 1012345678 | ALL | NULL |
| C | created_at >= ''2026-09-01'' AND created_at < ''2026-09-02'' | range | idx_created |
| D | DATE(created_at) = ''2026-09-01'' | ALL | NULL |', 'OBJECTIVE'),
       (3165, 497, '아래 두 쿼리의 응답 시간 차이를 만든 인덱스 활용 방식을 가리키는 용어는?', E'orders 테이블은 1,000만 행이고, 인덱스는 idx_orders_user (user_id, created_at)가 있다.\n\n```sql\n-- Q1: 평균 8ms, 실행 계획의 Extra = Using index\nSELECT user_id, created_at FROM orders WHERE user_id = 7;\n\n-- Q2: 평균 240ms, 실행 계획의 Extra = Using where\nSELECT user_id, created_at, amount FROM orders WHERE user_id = 7;\n```', 'SUBJECTIVE'),
       (3166, 497, '아래에서 두 인덱스의 효과를 갈라놓은 컬럼의 성질을 부르는 용어는?', 'orders 테이블 1,000만 행에 인덱스를 하나 더 만들려고 두 컬럼을 먼저 조사했다.

```sql
SELECT COUNT(DISTINCT status), COUNT(*) FROM orders;   -- 5 / 10,000,000
SELECT COUNT(DISTINCT user_id), COUNT(*) FROM orders;  -- 2,000,000 / 10,000,000
```

status에 인덱스를 만들고 WHERE status = ''PAID''로 조회했더니 실행 계획은 여전히 type = ALL이었다.
같은 형태인 WHERE user_id = 7 조회는 user_id 인덱스를 타고 곧바로 type = ref로 처리됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3161
(8603, 3161, 'PK 순서대로 행이 물리적으로 저장되므로 PK는 짧고 단조 증가하는 값이 좋다.', '클러스터드 인덱스의 성질을 갖다 붙인 오개념. 행을 PK 순서로 늘어놓는 것은 테이블당 하나뿐인 클러스터드 인덱스이고, 본문의 인덱스는 그 위에 얹혀 PK 값만 들고 있다.', false),
(8604, 3161, '조건에 맞는 행이 많아질수록 옵티마이저가 이 인덱스 대신 풀 스캔을 고르기도 한다.', '찾은 항목마다 PK로 실제 행을 되짚는 랜덤 I/O가 붙는다. 결과 행이 많아지면 이 비용이 테이블을 처음부터 훑는 비용을 넘어서므로, 옵티마이저는 풀 스캔이 더 싸다고 판단한다.', true),
(8605, 3161, '값 종류가 적은 컬럼에 만들수록 한 번에 많은 행을 걸러내 효과가 커진다.', '카디널리티를 거꾸로 본 오개념. 값 종류가 적으면 조건 하나에 걸리는 행이 오히려 많아져 걸러지는 비율이 낮고, 되짚어야 할 행만 늘어 인덱스를 타는 이득이 사라진다.', false),
(8606, 3161, '조회 속도만 빨라질 뿐 INSERT·UPDATE 비용에는 영향을 주지 않는다.', '인덱스를 읽기 전용 자료로 오해한 것. 행이 바뀌면 그 행이 걸린 인덱스 트리도 함께 갱신해야 하므로, 인덱스를 늘릴수록 쓰기가 느려지고 저장 공간도 더 든다.', false),

-- 문제 3162
(8607, 3162, 'Q1은 등치 조건인 status로 먼저 범위를 좁힌 뒤 그 안에서 created_at을 훑는다.', '옵티마이저가 인덱스 컬럼 순서를 알아서 바꿔 준다고 오해한 것. 리프는 created_at으로 먼저 정렬돼 있어 날짜 범위를 훑으며 status를 걸러낸다. 등치를 앞세우려면 인덱스를 (status, created_at) 순으로 다시 만들어야 한다.', false),
(8608, 3162, 'Q2는 범위 조건뿐이라 정렬 순서를 쓸 수 없어 풀 스캔으로 처리된다.', '범위 조건이면 인덱스를 못 쓴다는 오개념. created_at은 이 인덱스의 첫 컬럼이고 리프가 그 순서로 정렬돼 있어, 시작 지점을 찾은 뒤 순서대로 읽어 나가는 범위 스캔이 가능하다.', false),
(8609, 3162, 'Q3은 인덱스의 첫 컬럼 조건이 빠져 이 인덱스를 쓰지 못한다.', '리프는 created_at으로 먼저 정렬되고 같은 날짜 안에서만 status가 정렬된다. created_at 조건이 없으면 같은 status 값이 인덱스 전체에 흩어져 있어 시작 지점을 잡을 수 없다. 왼쪽 접두어 규칙이다.', true),
(8610, 3162, 'Q2가 인덱스를 타게 하려면 created_at 단독 인덱스를 따로 만들어야 한다.', '복합 인덱스는 모든 컬럼 조건이 갖춰져야 쓴다는 오개념. Q2는 첫 컬럼만으로도 이미 인덱스를 탄다. 왼쪽 접두어인 단독 인덱스는 대부분 중복이라 쓰기 비용만 늘린다.', false),

-- 문제 3163
(8611, 3163, 'Extra의 Using filesort는 인덱스 순서 덕분에 별도 정렬 없이 결과가 나왔다는 표시다.', '뜻이 정반대라 이 선지가 거짓이다. Using filesort는 인덱스 순서를 그대로 쓰지 못해 가져온 행을 따로 정렬했다는 표시다. idx_user에 created_at이 없어 ORDER BY를 인덱스로 해결하지 못했다.', true),
(8612, 3163, 'type이 ref이므로 유니크하지 않은 인덱스로 등치 조건을 찾아 들어갔다.', '참인 진술이다. ref는 유니크가 아닌 인덱스를 등치 조건으로 조회했다는 뜻이다. user_id = 7에 여러 행이 걸릴 수 있어, 단 한 행이 보장될 때 나오는 const가 아니라 ref로 잡혔다.', false),
(8613, 3163, 'key에 idx_user가 찍혔으므로 옵티마이저가 풀 스캔 대신 그 인덱스를 실제로 골랐다.', '참인 진술이다. key는 후보 목록이 아니라 최종 선택된 인덱스를 보여 준다. 풀 스캔이었다면 type은 ALL, key는 NULL로 찍히고 rows도 1,000만에 가깝게 잡혔을 것이다.', false),
(8614, 3163, 'amount가 인덱스에 없어 행마다 테이블을 되짚어야 하므로 Using index가 나오지 않았다.', '참인 진술이다. Using index는 쿼리가 요구한 컬럼이 전부 인덱스 안에 있을 때만 찍힌다. amount와 created_at은 idx_user에 없어 PK로 실제 행을 찾아가야 하므로 표시되지 않았다.', false),

-- 문제 3164
(8615, 3164, 'B는 숫자 리터럴이 문자열보다 비교 비용이 커서고, D는 날짜 컬럼의 값 종류가 적어서다.', '비교 비용과 카디널리티로 원인을 돌린 오개념. B는 A와 같은 컬럼에 같은 값을 넣었고 D도 C와 같은 컬럼을 쓰는데 결과가 갈렸으니, 컬럼의 성질이 아니라 조건을 쓴 방식이 원인이다.', false),
(8616, 3164, 'B와 D 모두 조건에 맞는 행이 전체의 대부분이라 옵티마이저가 풀 스캔을 골랐다.', '선택도가 낮아 풀 스캔을 고른 정상 동작으로 오해한 것. 같은 값을 찾는 A는 ref로 소수 행만 짚었고 C도 range로 하루치만 읽었으니, 실제로 걸리는 행 수는 B·D에서도 다르지 않다.', false),
(8617, 3164, 'B는 인덱스 통계가 오래돼서고, D는 결과를 정렬해야 해서 인덱스를 포기한 것이다.', '통계 노후와 정렬을 원인으로 든 오개념. 통계가 낡으면 rows 추정만 어긋날 뿐 key가 통째로 NULL이 되지는 않고, 네 쿼리 모두 ORDER BY가 없어 정렬은 개입할 여지가 없다.', false),
(8618, 3164, 'B는 리터럴 타입이 달라 컬럼 값 쪽이 변환됐고, D는 컬럼을 함수로 가공해 저장된 값과 대조할 수 없어서다.', 'VARCHAR 컬럼을 숫자와 비교하면 컬럼 쪽이 숫자로 변환돼, 인덱스에 정렬돼 있는 원래 문자열 값과 맞춰 볼 수 없다. DATE(created_at)도 가공된 값이라 마찬가지다. C처럼 컬럼을 그대로 둔 범위 조건으로 바꾸면 인덱스를 탄다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1010, 3165, '커버링 인덱스,커버링인덱스,covering index,coveringindex,커버링,cover index', 'Q1이 요구한 user_id·created_at은 idx_orders_user 안에 모두 들어 있어 인덱스만 읽고 조회가 끝난다. 실행 계획의 Using index가 그 표시다. Q2는 amount가 인덱스에 없어 찾은 행마다 PK로 테이블을 되짚는 랜덤 I/O가 붙어 30배 느려졌다. 커버링 인덱스는 별도의 인덱스 종류가 아니라, 쿼리가 요구한 컬럼을 인덱스가 전부 덮은 상태를 부르는 말이다. 인덱스 자체의 종류인 클러스터드·세컨더리 인덱스와는 층위가 다르니 구분해야 한다. 다만 커버링을 노려 컬럼을 계속 덧붙이면 인덱스가 비대해져 쓰기·메모리 비용이 커지므로, 자주 쓰는 쿼리에만 맞춰 설계한다.'),
       (1011, 3166, '카디널리티,cardinality,카디날리티,카디넬리티', 'COUNT(DISTINCT)로 센 값 종류의 수가 카디널리티다. status는 1,000만 행에 값이 5종뿐이라 조건 하나에 평균 200만 행이 걸리고, 인덱스로 찾은 뒤 PK로 테이블을 되짚는 비용이 풀 스캔보다 커져 옵티마이저가 인덱스를 버린다. user_id는 200만 종이라 한 값에 평균 5행만 걸려 인덱스가 제 몫을 한다. 여기서 잰 것은 값 종류의 수이지 조건에 걸러지는 행의 비율이 아니다. 비율을 가리키는 선택도(selectivity)는 재는 대상이 다른 별개 지표이며, 카디널리티가 높을수록 선택도도 좋아지는 짝을 이룬다. 인덱스를 만들 수 있느냐가 아니라 옵티마이저가 쓸 만하다고 볼 것이냐의 문제라는 점이 핵심이다.');

-- =====================================================
-- Lesson 655: B+Tree 깊이와 클러스터드 인덱스
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4109, 655, '아래 조건에서 키 하나를 찾을 때 루트부터 리프까지 읽는 노드 수는?', 'orders 테이블 1억 행의 order_no 컬럼에 B+Tree 인덱스가 있다. order_no 값은 행마다 모두 다르다.

- 루트·브랜치 노드는 자식 노드를 최대 500개까지 가리킨다.
- 리프 노드는 키를 최대 500개까지 담는다.
- 모든 노드를 최대한 꽉 채워 트리 높이가 가장 낮아지도록 구성했다고 가정한다.', 'OBJECTIVE'),
       (4110, 655, '아래 인덱스 중 Q1~Q4의 인덱스 활용을 해치지 않고 삭제할 수 있는 것은?', E'MySQL InnoDB의 orders 테이블(1,000만 행)은 인덱스가 많아 주문 INSERT가 느려져, 인덱스를 하나 줄이려 한다. 이 테이블에서 실행되는 조회는 아래 Q1~Q4뿐이다.\n\n```sql\nCREATE INDEX idx_a ON orders (user_id);\nCREATE INDEX idx_b ON orders (user_id, created_at);\nCREATE INDEX idx_c ON orders (created_at);\nCREATE INDEX idx_d ON orders (status, created_at);\n\n-- Q1\nSELECT * FROM orders WHERE user_id = ?;\n-- Q2\nSELECT * FROM orders WHERE user_id = ? AND created_at >= ?;\n-- Q3\nSELECT * FROM orders WHERE created_at >= ? AND created_at < ?;\n-- Q4\nSELECT * FROM orders WHERE status = ? AND created_at >= ?;\n```', 'OBJECTIVE'),
       (4111, 655, '아래 두 실행 계획을 옳게 해석한 것은?', E'MySQL InnoDB의 users 테이블은 500만 행이고, 인덱스는 PK(id)와 idx_name (name) 두 개다.\n\n```sql\n-- Q1\nEXPLAIN SELECT id, name FROM users WHERE name LIKE ''%철수'';\n-- Q2\nEXPLAIN SELECT * FROM users WHERE name LIKE ''%철수'';\n```\n\n```\n쿼리 | type  | key      | rows      | Extra\n-----+-------+----------+-----------+-------------------------\nQ1   | index | idx_name | 4,980,000 | Using where; Using index\nQ2   | ALL   | NULL     | 4,980,000 | Using where\n```', 'OBJECTIVE'),
       (4112, 655, '아래 두 쿼리의 응답 시간 차이를 옳게 설명한 것은?', E'MySQL InnoDB의 posts 테이블은 3,000만 행이고 PK는 id다. (board_id, created_at) 순서의 인덱스 idx_board가 있고, board_id = 3인 글은 150만 건이다. 두 쿼리는 같은 게시글 20건을 돌려주며, Q1의 실행 계획은 type = ref, key = idx_board였다.\n\n```sql\n-- Q1: 평균 2,900ms\nSELECT *\nFROM posts\nWHERE board_id = 3\nORDER BY created_at DESC\nLIMIT 20 OFFSET 500000;\n\n-- Q2: 평균 180ms\nSELECT p.*\nFROM posts p\nJOIN (\n  SELECT id\n  FROM posts\n  WHERE board_id = 3\n  ORDER BY created_at DESC\n  LIMIT 20 OFFSET 500000\n) t ON p.id = t.id\nORDER BY p.created_at DESC;\n```', 'OBJECTIVE'),
       (4113, 655, '아래 쿼리에서 인덱스에 들어 있지만, 인덱스에서 읽을 구간을 좁히는 데는 쓰이지 못하는 컬럼은?', 'MySQL InnoDB의 products 테이블(800만 행)에는 아래 복합 인덱스 하나만 있고, 쿼리는 이 인덱스를 타고 실행된다.

```sql
CREATE INDEX idx_products ON products (shop_id, category, price, stock);

SELECT *
FROM products
WHERE stock > 0
  AND price BETWEEN 30000 AND 50000
  AND shop_id = 12
  AND category = ''SHOES'';
```', 'SUBJECTIVE'),
       (4114, 655, '아래 표의 변화가 한꺼번에 나타난 까닭을 설명해 주는 인덱스 종류를 가리키는 용어는?', 'MySQL InnoDB의 events 테이블(3,000만 행)은 PK가 AUTO_INCREMENT BIGINT였고, PK 외에 user_id 인덱스와 created_at 인덱스가 있었다. 인덱스 컬럼은 그대로 두고 PK만 무작위로 생성되는 UUID 문자열(CHAR(36))로 바꾸자 아래와 같이 달라졌다.

| 항목 | 변경 전 | 변경 후 |
|---|---|---|
| INSERT 처리량 | 초당 6,000건 | 초당 2,100건 |
| 꽉 찬 페이지를 둘로 쪼갠 횟수 | 시간당 약 40회 | 시간당 약 9,000회 |
| user_id 인덱스 크기 | 1.1GB | 2.3GB |
| created_at 인덱스 크기 | 1.2GB | 2.4GB |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4109
(11131, 4109, '2개', '루트가 리프 500개를 곧바로 가리키고 리프마다 키를 500개씩 담아도 25만 개뿐이다. 키 1억 개에는 리프 20만 개가 필요하고 루트 하나로는 이를 다 가리킬 수 없어, 사이에 브랜치 단계가 하나 더 들어가야 한다.', false),
(11132, 4109, '3개', '리프는 1억 ÷ 500 = 20만 개, 이를 가리킬 브랜치는 20만 ÷ 500 = 400개이고, 400개는 루트 하나가 모두 가리킨다. 그래서 루트→브랜치→리프 3개만 읽으면 된다. 노드마다 자식이 수백 개라 1억 행에도 트리가 얕다.', true),
(11133, 4109, '4개', '1억 → 20만 → 400 → 1로 줄여 가는 네 수를 모두 노드 단계로 센 것. 맨 앞의 1억은 리프 안에 담긴 키 개수일 뿐 노드 단계가 아니므로, 실제로 읽는 노드는 리프·브랜치·루트 세 단계다.', false),
(11134, 4109, '27개', '노드마다 자식이 2개인 이진 탐색 트리로 계산한 것(log₂ 1억 ≈ 26.6). B+Tree는 노드 하나에 수백 개의 키를 담아 한 번에 갈래를 크게 나누므로, 같은 행 수에서도 높이가 훨씬 낮다.', false),

-- 문제 4110
(11135, 4110, 'idx_c — Q3의 created_at 조건은 idx_b나 idx_d에 들어 있는 created_at으로 대신 처리된다.', '복합 인덱스의 뒤 컬럼도 단독 조건에 쓸 수 있다는 오개념. idx_b·idx_d는 user_id·status로 먼저 정렬돼 created_at 값이 곳곳에 흩어져 있다. 앞 컬럼 조건이 없는 Q3은 시작 지점을 잡지 못해 풀 스캔이 된다.', false),
(11136, 4110, 'idx_d — Q4는 idx_c로 기간을 찾은 뒤 status만 걸러도 읽는 양이 같다.', '등치 조건으로 먼저 좁히는 효과를 놓친 오개념. idx_c로는 기간에 걸린 모든 주문을 테이블에서 읽은 뒤 status를 걸러야 한다. idx_d는 status로 먼저 좁히고 그 안에서 기간만 읽어 읽는 행이 줄어든다.', false),
(11137, 4110, 'idx_b — Q1과 Q2 모두 idx_a로 처리되므로 idx_b는 쓰일 일이 없다.', '단일 컬럼 인덱스로 충분하다고 본 오개념. Q2는 idx_b로 user_id와 기간을 인덱스 안에서 함께 좁힌다. idx_b를 지우면 idx_a로 그 사용자의 주문을 모두 테이블에서 읽은 뒤 기간을 걸러야 해 읽는 행이 늘어난다.', false),
(11138, 4110, 'idx_a — Q1은 idx_b의 앞 컬럼 user_id만으로 같은 방식으로 찾을 수 있다.', 'idx_b는 user_id로 먼저 정렬돼 있어 user_id 조건만 줘도 시작 지점을 곧바로 찾는다(왼쪽 접두어 규칙). idx_a가 하는 일을 idx_b가 그대로 하므로, idx_a는 INSERT마다 트리 갱신 비용만 더하는 중복 인덱스다.', true),

-- 문제 4111
(11139, 4111, 'Q1도 읽을 범위를 좁히지 못해 idx_name 전체를 훑었고, 테이블 행 대신 인덱스를 읽었다는 점만 다르다.', 'type = index는 인덱스를 처음부터 끝까지 읽었다는 뜻이다. ''%철수''는 앞부분이 비어 정렬 순서로 시작 지점을 잡을 수 없다. 다만 PK인 id는 idx_name 리프에 함께 들어 있어, Q1은 테이블 대신 인덱스만 훑었다(Using index).', true),
(11140, 4111, 'Q1은 key에 idx_name이 찍혔으므로 ''%철수''에 맞는 구간만 골라 읽는 범위 스캔을 했다.', 'key에 인덱스가 찍히면 범위를 좁혔다고 본 오개념. 구간만 읽는 범위 스캔이었다면 type이 range로 나온다. Q1의 type은 index이고 rows도 전체 행 수에 가까워, 인덱스 전체를 훑었음을 보여 준다.', false),
(11141, 4111, 'Q2가 풀 스캔이 된 것은 걸리는 행이 많아서이며, ''철수''로 끝나는 이름이 드물면 범위 스캔으로 바뀐다.', '선택도 때문이라고 본 오개념. 결과가 몇 건뿐이어도 ''%철수''는 앞부분이 비어 있어 B+Tree 정렬 순서로 시작 지점을 찾을 수 없다. 원인은 걸리는 행 수가 아니라 앞부분 와일드카드라서 범위 스캔은 불가능하다.', false),
(11142, 4111, '두 계획의 rows가 같으므로 Q1과 Q2가 디스크에서 읽어 들이는 데이터 양도 같다.', 'rows를 읽는 데이터 양으로 오해한 것. rows는 확인할 항목 수 추정일 뿐이다. Q1은 name과 id만 담긴 작은 인덱스를 읽고 Q2는 모든 컬럼이 든 행을 읽으므로, 같은 건수라도 Q1이 읽는 양이 훨씬 적다.', false),

-- 문제 4112
(11143, 4112, 'Q2는 인덱스가 OFFSET 위치를 곧바로 계산해, 앞의 500,000건을 읽지 않고 시작 지점으로 간다.', '인덱스가 OFFSET을 건너뛰어 준다는 오개념. B+Tree는 항목이 몇 번째인지 세어 두지 않으므로 Q2의 서브쿼리도 인덱스 항목 500,020건을 차례로 읽는다. 두 쿼리의 차이는 그동안 테이블 행을 찾아가느냐에 있다.', false),
(11144, 4112, 'Q1은 created_at 정렬을 인덱스로 처리하지 못해, 500,020건을 따로 정렬하느라 느려졌다.', '따로 정렬(filesort)해서 느리다고 본 오개념. idx_board는 같은 board_id 안에서 created_at 순으로 정렬돼 있어, board_id = 3으로 좁힌 Q1은 인덱스 순서 그대로 읽으며 정렬하지 않는다. 느린 원인은 읽은 항목마다 테이블을 되짚는 데 있다.', false),
(11145, 4112, 'Q1은 건너뛸 행까지 테이블에서 읽지만, Q2는 그 구간을 인덱스만으로 넘기고 20건만 테이블에서 읽는다.', 'SELECT *인 Q1은 인덱스로 찾은 500,020건마다 PK로 테이블 행을 되짚는 랜덤 I/O가 붙는다. Q2의 서브쿼리는 필요한 id가 세컨더리 인덱스 리프에 이미 들어 있어 인덱스만 읽고(커버링 인덱스), 마지막 20건만 조인해 테이블에서 읽는다.', true),
(11146, 4112, 'Q2의 서브쿼리는 idx_board를 거치지 않고 PK 인덱스만 id 순으로 읽어 세컨더리 인덱스 비용이 없다.', '서브쿼리가 PK 인덱스를 쓴다고 본 오개념. board_id 조건과 created_at 정렬을 함께 처리할 수 있는 것은 idx_board뿐이다. id는 PK라 세컨더리 인덱스 리프에 함께 저장되므로 idx_board만 읽어도 id를 얻는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1326, 4113, 'stock,stock 컬럼,stock컬럼,products.stock,stock > 0,stock>0', 'WHERE 절에 적은 순서와 상관없이 옵티마이저는 인덱스 컬럼 순서(shop_id → category → price → stock)대로 조건을 맞춰 본다. shop_id·category는 등치 조건이라 인덱스 안의 한 구간으로 좁혀지고, 그 구간 안에서 price는 정렬돼 있어 30,000~50,000 구간까지 잡을 수 있다. 그런데 price가 범위라 여러 값에 걸치면, stock은 price 값마다 따로 정렬돼 있을 뿐 잡힌 구간 전체로는 순서가 뒤섞인다. 그래서 stock > 0은 읽기 시작·멈춤 지점을 더 줄이지 못하고, 이미 잡힌 구간의 항목을 하나씩 걸러내는 데만 쓰인다. 첫 컬럼 조건이 빠져 인덱스로 시작 지점을 아예 못 잡는 왼쪽 접두어 규칙 위반과 달리, 이 쿼리는 인덱스를 타되 범위 조건 뒤 컬럼만 구간을 좁히는 효과를 잃은 경우다. 복합 인덱스에서 등치 조건 컬럼을 앞에, 범위 조건 컬럼을 뒤에 두라는 원칙이 여기서 나온다.'),
       (1327, 4114, '클러스터드 인덱스,클러스터드인덱스,클러스터 인덱스,클러스터인덱스,클러스터링 인덱스,클러스터링인덱스,클러스터형 인덱스,클러스터형인덱스,clustered index,clusteredindex,clustering index,cluster index,클러스터드,clustered', 'InnoDB는 PK로 클러스터드 인덱스를 만들어 리프에 행 데이터 전체를 PK 순서대로 저장한다. 계속 커지는 BIGINT PK일 때는 새 행이 늘 맨 끝 페이지에 붙었지만, 무작위 UUID는 새 행이 이미 꽉 찬 중간 페이지 사이사이에 끼어들어야 해서 페이지 분할이 폭증하고 INSERT 처리량이 떨어졌다. 인덱스 컬럼을 건드리지 않았는데 user_id·created_at 인덱스가 두 배로 커진 것도 같은 뿌리다. 세컨더리 인덱스는 리프에 인덱스 컬럼 값과 함께 PK 값을 담아 두고 그 PK로 클러스터드 인덱스를 다시 찾아가므로, 8바이트 정수였던 PK가 36자 문자열이 되자 모든 세컨더리 인덱스 항목이 함께 커졌다. 표에서 크기가 커진 쪽은 세컨더리 인덱스지만, 두 변화를 한꺼번에 설명하는 것은 PK가 곧 행의 저장 순서이자 행을 찾아가는 열쇠라는 클러스터드 인덱스의 성질이다. 테이블당 여러 개 둘 수 있는 세컨더리(논클러스터드) 인덱스와 달리 클러스터드 인덱스는 테이블당 하나뿐이며, 그래서 PK는 짧고 단조 증가하는 값이 권장된다.');

-- =====================================================
-- Lesson 813: 옵티마이저 통계와 선택도, 정렬 회피
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5057, 813, '아래 인덱스 자료구조에 대한 설명으로 옳은 것은?', '키를 정렬된 상태로 보관하며, 노드 하나가 자식 노드를 수백 개까지 거느린다. 실제 키 값과 행을 찾아갈 정보는 가장 아래의 리프 노드에만 들어 있고, 리프 노드들은 서로 앞뒤로 이어져 있다.', 'OBJECTIVE'),
       (5058, 813, '아래 두 실행 계획이 갈린 까닭을 옳게 설명한 것은?', E'MySQL InnoDB의 members 테이블은 800만 행이고, idx_email (email)과 idx_phone (phone) 인덱스가 각각 하나씩 있다.\n\n```sql\n-- Q1\nEXPLAIN SELECT * FROM members WHERE email = ''a@example.com'';\n\n-- Q2\nEXPLAIN SELECT * FROM members WHERE email = ''a@example.com'' OR phone = ''01012345678'';\n```\n\n```\n쿼리 | type | key       | rows      | Extra\n-----+------+-----------+-----------+-------------\nQ1   | ref  | idx_email | 1         | Using where\nQ2   | ALL  | NULL      | 7,940,000 | Using where\n```', 'OBJECTIVE'),
       (5059, 813, '아래 조회가 따로 정렬하는 단계 없이 인덱스에서 20건만 읽고 끝나게 하려면 어떤 인덱스를 만들어야 하는가?', 'MySQL InnoDB의 posts 테이블은 3,000만 행이고 PK는 id다. 지금 있는 인덱스는 PK뿐이며, 목록 화면에서 아래 조회가 초당 수백 번 실행된다.

```sql
SELECT id, created_at
FROM posts
WHERE board_id = 3 AND status = ''OPEN''
ORDER BY created_at DESC
LIMIT 20;
```

board_id가 3이면서 status가 ''OPEN''인 글은 150만 건이다.', 'OBJECTIVE'),
       (5060, 813, '아래 실행 계획에 대한 설명으로 옳지 않은 것은?', E'MySQL InnoDB의 logs 테이블은 2,000만 행이고, 인덱스는 PK(id) 하나뿐이다.\n\n```sql\nEXPLAIN SELECT user_id, COUNT(*) AS cnt\nFROM logs\nWHERE created_at >= ''2026-09-01''\nGROUP BY user_id\nORDER BY cnt DESC;\n```\n\n```\nid | select_type | table | type | key  | rows       | Extra\n---+-------------+-------+------+------+------------+----------------------------------------------\n1  | SIMPLE      | logs  | ALL  | NULL | 19,840,000 | Using where; Using temporary; Using filesort\n```', 'OBJECTIVE'),
       (5061, 813, '아래 상황에서 실행 계획의 rows 추정을 실제와 다시 맞추려고 orders 테이블에 실행해야 하는 SQL 명령은?', 'MySQL InnoDB의 orders 테이블(300만 행)에 야간 배치로 1,200만 행을 한 번에 넣었다. 테이블 정의·인덱스·쿼리 문장은 그대로인데, 적재가 끝난 뒤 같은 조회가 아래처럼 달라졌다.

| 항목 | 적재 전 | 적재 직후 |
|---|---|---|
| 실행 계획의 rows | 4,100 | 4,300 |
| 실제로 읽은 행 | 4,050 | 1,120,000 |
| key에 찍힌 인덱스 | idx_user | idx_status |
| 응답 시간 | 40ms | 11.8초 |', 'SUBJECTIVE'),
       (5062, 813, '아래에서 같은 인덱스를 두고도 옵티마이저의 선택이 갈린 까닭을 설명하는 지표의 이름은?', 'MySQL InnoDB의 orders 테이블은 1,000만 행이고, created_at 컬럼에 idx_created (created_at) 인덱스가 하나 있다. 컬럼도 인덱스도 그대로 둔 채 조회 기간만 바꿔 두 번 실행했더니 아래처럼 갈렸다.

| 조건 | 조건에 걸린 행 | type | key | 응답 시간 |
|---|---|---|---|---|
| created_at >= ''2026-09-19'' | 12,000 | range | idx_created | 18ms |
| created_at >= ''2026-01-01'' | 7,300,000 | ALL | NULL | 9.4초 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5057
(13659, 5057, '한 값을 찾을 때 읽는 노드 단계 수가 행 수에 거의 비례해, 행이 100배가 되면 탐색 비용도 100배가 된다.', '목록을 앞에서부터 훑는 구조로 본 오개념. 노드 하나가 자식을 수백 개 거느리므로 한 단계 내려갈 때마다 후보가 수백분의 1로 줄어, 수천만 행이어도 읽는 단계는 서너 단계에 그친다.', false),
(13660, 5057, '값을 정확히 맞추는 등치 조건에만 쓸 수 있고, 크거나 작음을 따지는 범위 조건에는 쓸 수 없다.', '값을 흩어 담는 해시 인덱스의 성질을 갖다 붙인 오개념. 키가 정렬돼 있고 리프가 앞뒤로 이어져 있어, 시작 지점만 찾으면 부등호나 BETWEEN 조건도 그 뒤를 이어 읽으며 처리한다.', false),
(13661, 5057, '정렬 조건이 이 순서와 맞으면 가져온 결과를 따로 정렬하는 단계를 건너뛸 수 있다.', '이미 정렬된 리프를 순서대로 이어 읽으면 ORDER BY가 요구하는 순서가 그대로 나온다. 그래서 MySQL 실행 계획에서 Using filesort가 사라지고, LIMIT이 붙으면 필요한 만큼만 읽고 멈출 수 있다.', true),
(13662, 5057, '리프까지 내려가기 전에 중간 노드에서 원하는 행을 찾고 끝나는 경우가 많아 평균 탐색 비용이 더 낮다.', '중간 노드에도 행 데이터를 함께 두는 구조와 헷갈린 것. 본문의 인덱스는 행을 찾아갈 정보가 리프에만 있어, 어느 키를 찾든 루트에서 리프까지 같은 단계 수를 내려가야 한다.', false),

-- 문제 5058
(13663, 5058, 'Q2는 두 조건이 서로 다른 인덱스에 걸려 한쪽만 읽어서는 결과를 다 모을 수 없다. 조건별로 쿼리를 나눠 UNION으로 합치면 각각 인덱스를 탄다.', 'OR는 둘 중 하나만 맞아도 결과에 든다. idx_email로 찾은 집합에는 phone만 맞는 행이 빠져 있어 인덱스 하나로는 결과를 완성할 수 없다. 두 조회로 나누면 각각 ref로 처리한 뒤 합칠 수 있다.', true),
(13664, 5058, 'Q2는 두 컬럼을 함께 묶은 (email, phone) 복합 인덱스가 없어서이며, 그 인덱스를 만들면 Q2도 ref로 바뀐다.', '복합 인덱스가 OR까지 해결해 준다고 본 오개념. 복합 인덱스는 앞 컬럼으로 먼저 정렬되므로 email 조건이 없는 행은 여전히 곳곳에 흩어진다. AND로 범위를 좁힐 때 쓰는 도구라 OR에는 도움이 되지 않는다.', false),
(13665, 5058, 'Q2의 rows가 794만이므로 조건에 실제로 걸리는 행이 그만큼 많아 옵티마이저가 풀 스캔을 골랐다.', 'rows를 결과 행 수로 오해한 것. rows는 확인해 볼 행 수의 추정치이고, 풀 스캔을 고르면 테이블 행 수가 거의 그대로 찍힌다. 등치 조건 두 개를 OR로 묶었을 뿐이라 실제 결과는 많아야 몇 행이다.', false),
(13666, 5058, 'Q2도 값 종류가 더 많은 email 쪽 인덱스를 힌트로 강제하면 그 인덱스만으로 두 조건을 모두 처리할 수 있다.', '힌트가 인덱스 사용 여부만 정해 주면 된다고 본 오개념. email 인덱스를 강제해도 phone만 맞는 행은 그 인덱스 안에 단서가 없어, 결국 나머지 행을 테이블에서 다시 확인해야 한다.', false),

-- 문제 5059
(13667, 5059, 'CREATE INDEX idx_posts ON posts (created_at, board_id, status);', '정렬 컬럼을 맨 앞에 두면 된다고 본 오개념. created_at 순서로 읽을 수는 있지만 board_id로 시작 구간을 좁히지 못해, 20건을 채울 때까지 다른 게시판 글까지 인덱스에서 계속 걸러내며 읽어야 한다.', false),
(13668, 5059, 'CREATE INDEX idx_posts ON posts (board_id, status, created_at);', '등치 조건 두 개로 인덱스의 한 구간을 잡고, 그 구간 안은 created_at 순으로 정렬돼 있어 끝에서부터 20건만 읽으면 된다. id는 PK라 리프에 함께 들어 있어 테이블도 건드리지 않는다.', true),
(13669, 5059, 'CREATE INDEX idx_posts ON posts (board_id, created_at, status);', '정렬 컬럼을 등치 컬럼보다 앞에 둔 배치. board_id로 좁히고 정렬도 인덱스로 해결하지만, status는 구간을 좁히지 못한 채 읽은 항목을 하나씩 걸러내는 데만 쓰여 20건을 채우기까지 더 읽는다.', false),
(13670, 5059, 'CREATE INDEX idx_posts ON posts (status, board_id);', 'WHERE에 쓰인 컬럼만 넣으면 된다고 본 오개념. 두 등치 조건으로 구간은 잡히지만 그 안에 정렬 순서가 없어, 걸린 150만 건을 모두 읽어 created_at으로 따로 정렬한 뒤에야 20건을 낼 수 있다.', false),

-- 문제 5060
(13671, 5060, 'type이 ALL이고 key가 NULL이므로 created_at 조건으로 읽을 구간을 좁히지 못했다.', '참인 진술이다. 쓸 수 있는 인덱스가 PK뿐이라 기간 조건은 인덱스로 처리되지 못했다. rows가 테이블 행 수에 가까운 것도 전부 읽어 가며 조건을 확인했음을 보여 준다.', false),
(13672, 5060, 'ORDER BY cnt는 집계로 만들어진 값을 기준으로 삼아, 어떤 인덱스를 추가해도 정렬 단계를 없앨 수 없다.', '참인 진술이다. 인덱스는 테이블에 저장된 컬럼 값만 미리 정렬해 둔다. COUNT(*) 결과는 집계가 끝나야 나오는 값이라 정렬해 둘 수 없고, 정렬은 집계가 끝난 뒤에 따로 해야 한다.', false),
(13673, 5060, 'created_at에 인덱스를 만들어도 기간에 걸리는 행이 대부분이면 옵티마이저는 풀 스캔을 그대로 고를 수 있다.', '참인 진술이다. 인덱스로 찾은 행마다 PK로 테이블을 되짚는 비용이 붙어, 걸리는 행이 많으면 처음부터 순서대로 훑는 편이 싸다. 인덱스를 안 타는 것이 늘 잘못은 아니다.', false),
(13674, 5060, 'Using temporary는 GROUP BY를 빠르게 하려고 옵티마이저가 임시 인덱스를 만들어 붙였다는 표시다.', '임시로 만드는 것은 인덱스가 아니라 테이블이라 이 선지가 거짓이다. 중간 집계 결과를 담을 임시 테이블을 만들었다는 표시이며, 대상이 커져 메모리에 담기지 않으면 디스크에 만들어져 더 느려진다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1642, 5061, 'ANALYZE TABLE orders,ANALYZE TABLE orders;,ANALYZE TABLE,ANALYZE,애널라이즈 테이블,애널라이즈', '옵티마이저는 테이블·인덱스마다 모아 둔 통계로 조건에 걸릴 행 수를 어림잡아 실행 계획을 고른다. 1,200만 행을 한 번에 넣었는데도 rows 추정이 4,100에서 4,300으로 거의 그대로인 것은, 통계가 적재 전 300만 행 시절에 멈춰 있다는 신호다. 어림값과 실제가 300배 가까이 벌어지자 옵티마이저는 idx_status가 더 싸다고 잘못 판단했고, 실제로는 112만 행을 읽어 11.8초가 걸렸다. ANALYZE TABLE orders를 실행해 인덱스 통계를 다시 모으면 rows 추정이 실제에 가까워지고 원래대로 idx_user를 고르게 된다. 이름이 비슷한 것들과 구분해 두자. PostgreSQL이나 MySQL 8.0의 EXPLAIN ANALYZE는 쿼리를 실제로 실행해 걸린 시간과 실제 행 수를 보여 주는 진단 도구이지 통계를 갱신하는 명령이 아니다. OPTIMIZE TABLE은 조각난 저장 공간을 정리하는 명령이라 목적이 다르다. 실행 계획이 갑자기 이상해졌을 때는 인덱스를 새로 만들기 전에 rows 추정과 실제 행 수가 얼마나 벌어졌는지부터 확인하는 것이 순서다.'),
       (1643, 5062, '선택도,selectivity,셀렉티비티,선택률,선택 비율', '조건 하나가 전체 행 가운데 얼마나 좁은 몫만 남기는지를 나타내는 값이 선택도다. 앞 조건은 1,000만 행에서 12,000행만 남겨 0.12%이므로, 인덱스로 그 구간만 찾아 행마다 테이블을 되짚어도 이득이 크다. 뒤 조건은 730만 행이 걸려 전체의 73%다. 인덱스를 타면 730만 번의 랜덤 I/O가 뒤따르므로, 옵티마이저는 차라리 테이블을 처음부터 순서대로 훑는 편이 싸다고 보고 인덱스를 버린다. type이 ALL로 바뀐 것은 버그가 아니라 이 비교의 결과다. 카디널리티와 헷갈리기 쉬운데, 카디널리티는 컬럼에 값 종류가 몇 가지나 있는지를 세는 컬럼의 성질이라 조건을 바꿔도 달라지지 않는다. 여기서는 컬럼도 인덱스도 하나뿐이고 기간만 달라졌으니 카디널리티로는 이 차이를 설명할 수 없다. 조건마다 달라지는 것은 걸러지는 몫, 곧 선택도다. 그래서 값 종류가 아무리 많은 컬럼이라도 넓은 범위를 조회하면 인덱스가 쓰이지 않을 수 있다.');
