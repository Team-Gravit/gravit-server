-- Unit: SQL 개요와 명령어 분류 (Unit ID: 244)
-- Chapter: 데이터베이스 (Chapter ID: 4)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (1018, 244, '선언형·집합 처리 특징과 명령어 4분류'),
       (1019, 244, '자동 커밋과 DELETE·TRUNCATE·DROP 비교'),
       (1020, 244, 'SELECT 논리적 실행 순서와 별칭 참조');

-- =====================================================
-- Lesson 1018: 선언형·집합 처리 특징과 명령어 4분류
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6287, 1018, '아래 상황에서 드러난 SQL이라는 언어의 성격에 대한 설명으로 옳은 것은?', '개발자는 아래 한 문장만 작성했다. 인덱스를 쓸지, 테이블 전체를 훑을지, 어떤 순서로 행을 읽을지는 문장 어디에도 적지 않았다.

```sql
SELECT name, email FROM members WHERE grade = ''VIP'';
```

같은 DBMS에서 members가 100행일 때와 500만 행일 때 실행 계획을 확인하니, 문장을 한 글자도 바꾸지 않았는데 행을 읽는 방식이 서로 달랐다. 두 경우 모두 돌려받은 결과 집합은 같은 조건을 만족하는 행들이었다.', 'OBJECTIVE'),
       (6288, 1018, '아래 SQL 문장들을 SQL 명령어 4분류(DDL·DML·DCL·TCL)에 따라 짝지은 것으로 옳은 것은?', '```sql
(가) TRUNCATE TABLE access_log;
(나) REVOKE SELECT ON students FROM user1;
(다) SELECT * FROM students WHERE grade = 3;
(라) SAVEPOINT sp1;
```', 'OBJECTIVE'),
       (6289, 1018, '아래 두 쿼리를 비교한 설명으로 옳은 것은?', '학생 3명만 조회하려고 두 DBMS에서 각각 아래 쿼리를 작성했다.

```sql
(MySQL)  SELECT name FROM students LIMIT 3;
(Oracle) SELECT name FROM students WHERE ROWNUM <= 3;
```

SELECT name FROM students 부분은 MySQL과 Oracle 어느 쪽에서 실행해도 같은 의미로 동작했다. 그러나 MySQL용 쿼리를 Oracle에서, Oracle용 쿼리를 MySQL에서 그대로 실행하면 행 수를 제한하는 부분에서 의도대로 동작하지 않았다.', 'OBJECTIVE'),
       (6290, 1018, '아래 문장을 한 번 실행했을 때의 처리 결과로 옳은 것은?', 'orders 테이블에는 status가 ''PENDING''인 행이 1,200건 있고, 그중 created_at이 2026-01-01 이전인 행은 830건이다.

```sql
UPDATE orders
SET    status = ''CANCELED''
WHERE  status = ''PENDING''
  AND  created_at < ''2026-01-01'';
```', 'OBJECTIVE'),
       (6291, 1018, '아래 상황에서 행을 읽는 방식을 바꿔 고른 DBMS 내부 구성 요소의 이름은?', '아래 쿼리는 배포 이후 한 번도 수정되지 않았다.

```sql
SELECT * FROM orders WHERE customer_id = 42;
```

서비스 초기 orders가 300행이던 시절 실행 계획에는 Seq Scan(테이블 전체 순차 읽기)이 찍혔다. 1년 뒤 orders가 800만 행으로 늘어나자 같은 쿼리의 실행 계획에 Index Scan이 찍혔고 응답 시간은 2ms 안팎을 유지했다. 개발자가 바꾼 것은 아무것도 없었고, 쿼리 문장에도 읽는 방식을 정하는 힌트는 없었다.', 'SUBJECTIVE'),
       (6292, 1018, '아래 관리자가 실행한 두 문장이 공통으로 속하는 SQL 명령어 분류의 약어는?', '학기 초 실습 계정 user1로 아래 조회를 실행하자 오류가 났다.

```
mysql> SELECT * FROM students;
ERROR 1142 (42000): SELECT command denied to user ''user1''@''localhost'' for table ''students''
```

관리자가 문장 하나를 실행한 직후 user1의 같은 조회가 정상적으로 결과를 돌려주었다. 학기가 끝나자 관리자는 다른 문장 하나를 실행했고, user1은 다시 위와 같은 오류를 보게 되었다. 두 문장 모두 students 테이블의 구조나 행에는 아무 변화도 주지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6287
(16939, 6287, '행을 하나씩 꺼내 조건을 검사하는 반복 절차가 문장에 담겨 있어, 그 절차를 바꾸면 결과도 달라진다.', 'SQL 문장에는 반복·분기 같은 처리 절차가 없다. 본문에서도 개발자는 읽는 방식을 적지 않았고, 절차는 DBMS가 정한다. 절차형 언어의 동작 방식을 SQL에 덧씌운 오해다.', false),
(16940, 6287, '데이터 양에 따라 DBMS가 WHERE 조건을 고쳐 쓰므로, 같은 문장이라도 결과 집합이 달라질 수 있다.', 'DBMS가 바꾸는 것은 결과를 얻는 방법이지 조건이 아니다. 본문처럼 읽는 방식이 달라져도 결과는 grade = ''VIP''를 만족하는 행으로 같다. 처리 방법과 결과를 혼동한 오해다.', false),
(16941, 6287, '반복문·분기 없이 얻고 싶은 결과의 조건만 적는 선언형 언어라, C·Java 같은 절차형 언어와 구분된다.', 'SQL은 "어떻게"가 아니라 "무엇을" 원하는지만 기술한다. 본문에서 개발자가 조건만 적었는데 DBMS가 데이터 양에 맞춰 처리 방법을 따로 고른 것이 그 결과다.', true),
(16942, 6287, '처리 방식이 달라진 것은 DBMS마다 SQL 문법이 달라서이며, 표준 문법만 쓰면 처리 방식이 하나로 고정된다.', '본문은 같은 DBMS에서 같은 문장을 실행한 경우라 문법 차이와 무관하다. 표준 문법을 써도 처리 방법은 데이터 상황에 따라 DBMS가 정한다. 표준화와 처리 방식 결정을 섞은 오해다.', false),

-- 문제 6288
(16943, 6288, '(가) DML, (나) DCL, (다) DML, (라) TCL', 'TRUNCATE를 "데이터를 지우니 DML"로 본 오해다. TRUNCATE는 테이블을 초기 상태로 되돌리는 DDL이며, 그래서 자동 커밋되어 롤백할 수 없다.', false),
(16944, 6288, '(가) DDL, (나) DCL, (다) DML, (라) TCL', 'TRUNCATE는 객체를 초기화하는 DDL, REVOKE는 권한을 회수하는 DCL, SELECT는 4분류에서 DML, SAVEPOINT는 부분 롤백 지점을 정하는 TCL이다.', true),
(16945, 6288, '(가) DDL, (나) TCL, (다) DML, (라) TCL', 'REVOKE를 ROLLBACK처럼 "되돌리는" 명령으로 보고 TCL에 넣은 오해다. REVOKE가 되돌리는 것은 트랜잭션이 아니라 부여했던 권한이므로 DCL이다.', false),
(16946, 6288, '(가) DDL, (나) DCL, (다) DML, (라) DDL', 'SAVEPOINT가 이름 붙은 지점을 "만든다"는 점을 CREATE와 같은 객체 생성으로 본 오해다. SAVEPOINT는 트랜잭션 안의 롤백 지점을 지정하는 TCL이다.', false),

-- 문제 6289
(16947, 6289, 'LIMIT과 ROWNUM은 둘 다 ANSI/ISO 표준 구문이며, 각 DBMS가 둘 중 하나만 골라 구현한 것이다.', '두 구문은 표준이 아니라 각 DBMS의 자체 확장이다. 표준 구문이라면 표준을 따르는 DBMS 어디서나 같은 의미로 동작해야 하는데, 본문에서는 서로의 DBMS에서 동작하지 않았다.', false),
(16948, 6289, 'SQL에는 DBMS 사이의 공통 표준이 없어서, SELECT·FROM이 같게 동작한 것은 두 DBMS의 문법이 우연히 겹친 결과다.', 'SQL은 ANSI/ISO 표준으로 제정되어 대부분의 RDBMS가 공통 문법을 쓴다. SELECT·FROM이 같게 동작한 것은 우연이 아니라 표준을 따랐기 때문이다.', false),
(16949, 6289, '행 수 제한은 SQL이 아닌 애플리케이션 코드가 맡는 기능이라, DBMS 드라이버에 따라 지원 여부가 갈린다.', 'LIMIT과 ROWNUM은 드라이버가 아니라 DBMS가 해석하는 SQL 구문이다. 지원 여부가 갈린 이유는 각 DBMS가 표준 위에 서로 다른 확장 기능을 더했기 때문이다.', false),
(16950, 6289, '공통 부분은 ANSI/ISO 표준 문법이고, 행 수를 자르는 구문은 각 DBMS가 표준 위에 더한 자체 확장 기능이다.', 'SQL은 표준으로 제정되어 SELECT·FROM 같은 공통 문법이 DBMS 간에 통한다. 반면 MySQL의 LIMIT, Oracle의 ROWNUM은 각 DBMS의 확장이라 다른 DBMS에서는 그대로 쓸 수 없다.', true),

-- 문제 6290
(16951, 6290, '조건을 만족하는 830건이 한 번의 명령으로 함께 갱신된다.', 'SQL은 행 하나가 아니라 집합 단위로 처리한다. WHERE의 두 조건을 모두 만족하는 830건 전체가 이 UPDATE 한 번으로 바뀐다.', true),
(16952, 6290, '조건을 처음 만족한 1건만 갱신되고, 나머지 829건은 같은 문장을 반복 실행해야 갱신된다.', '한 문장이 한 행만 처리한다고 본 오해다. WHERE를 만족하는 모든 행이 한 번의 명령으로 처리되므로 반복 실행할 필요가 없다.', false),
(16953, 6290, 'status가 PENDING인 1,200건이 모두 갱신되고, created_at 조건은 갱신 순서를 정하는 데만 쓰인다.', 'AND로 이어진 조건은 모두 행을 거르는 데 쓰인다. created_at 조건 때문에 1,200건 중 830건만 대상이 되며, 갱신 순서를 정하는 기능은 없다.', false),
(16954, 6290, '830건을 모두 바꾸려면 반복문 안에서 행마다 이 UPDATE를 한 번씩 호출해야 한다.', '절차형 언어처럼 행마다 명령을 돌려야 한다고 본 오해다. SQL은 조건에 맞는 집합 전체를 한 문장으로 처리하므로 반복문이 필요 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2052, 6291, '옵티마이저,optimizer,쿼리 옵티마이저,쿼리옵티마이저,query optimizer,옵티마이져,질의 최적화기,플래너,planner,쿼리 플래너,쿼리플래너,query planner', 'SQL은 원하는 결과만 선언하는 선언형 언어이고, 그 결과를 얻는 구체적인 절차는 DBMS의 옵티마이저가 정한다. 본문에서 쿼리 문장과 힌트가 그대로인데도 데이터가 300행에서 800만 행으로 늘자 Seq Scan이 Index Scan으로 바뀐 것은 옵티마이저가 데이터 상황에 맞춰 처리 방법을 다시 골랐기 때문이다. 인덱스는 옵티마이저가 고를 수 있는 읽기 수단일 뿐 방식을 고르는 주체가 아니므로 답이 될 수 없고, 실행 계획 역시 옵티마이저가 내놓은 결과물이지 고르는 구성 요소가 아니다.'),
       (2053, 6292, 'DCL,dcl,데이터 제어어,데이터제어어,데이터 제어 언어,Data Control Language', '본문의 두 문장은 user1에게 students 조회 권한을 부여(GRANT)했다가 학기 말에 회수(REVOKE)한 것이다. 사용자 권한을 부여·회수하는 명령은 데이터 제어어(DCL)에 속한다. 테이블 구조를 바꾸는 DDL이나 행을 바꾸는 DML과 달리 구조·행에 변화가 없다는 점, 그리고 ROLLBACK처럼 트랜잭션을 다루는 TCL과도 대상(권한 vs 트랜잭션)이 다르다는 점이 경계다.');

-- =====================================================
-- Lesson 1019: 자동 커밋과 DELETE·TRUNCATE·DROP 비교
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6293, 1019, '아래 두 작업을 각각 실행한 직후, 각 작업에서 logs 테이블에 남은 행 수로 옳은 것은?', '자동 커밋을 끈 세션이라, INSERT·UPDATE·DELETE의 변경은 COMMIT을 실행해야 확정된다. 두 작업은 서로 다른 세션에서 실행하며, 각 작업 시작 시점에 logs 테이블에는 행이 100건 들어 있다.

```sql
(작업 A)
DELETE FROM logs;
ROLLBACK;

(작업 B)
TRUNCATE TABLE logs;
ROLLBACK;
```', 'OBJECTIVE'),
       (6294, 1019, '아래 세 작업에 쓸 명령어를 짝지은 것으로 옳은 것은?', '| 작업 | 요구 사항 |
| --- | --- |
| A | 데이터 이관에 쓴 임시 테이블 tmp_import를 다 썼다. 이후 같은 이름으로 조회조차 되지 않게, 테이블이라는 객체 자체를 없앤다. |
| B | access_log에 쌓인 수천만 행을 전부 비운다. 테이블은 계속 써야 하고, 차지하던 저장 공간도 초기화되어야 하며, 빠를수록 좋다. |
| C | members에서 탈퇴 후 1년이 지난 회원만 지운다. 지워진 건수를 확인한 뒤 예상과 다르면 커밋 전에 되돌릴 수 있어야 한다. |', 'OBJECTIVE'),
       (6295, 1019, '아래 트랜잭션을 실행한 뒤 id 1과 id 2의 최종 잔액으로 옳은 것은?', '시작 시점에 accounts 테이블의 잔액은 id 1이 50,000원, id 2가 0원이다.

```sql
UPDATE accounts SET balance = balance - 10000 WHERE id = 1;
SAVEPOINT sp1;
UPDATE accounts SET balance = balance + 10000 WHERE id = 2;
SAVEPOINT sp2;
UPDATE accounts SET balance = balance - 5000 WHERE id = 1;
ROLLBACK TO SAVEPOINT sp1;
UPDATE accounts SET balance = balance + 3000 WHERE id = 2;
COMMIT;
```', 'OBJECTIVE'),
       (6296, 1019, '아래 문장들을 실행한 뒤 t1·t2·t3 각각에 SELECT COUNT(*)를 실행한 결과로 옳은 것은?', '시작 시점에 t1·t2·t3 테이블에는 id가 1부터 1,000까지인 행이 1,000건씩 들어 있다. 각 문장은 앞 문장에서 오류가 나더라도 이어서 실행된다.

```sql
DELETE FROM t1 WHERE id <= 400;
TRUNCATE TABLE t2 WHERE id <= 400;
DROP TABLE t3;
COMMIT;
```', 'OBJECTIVE'),
       (6297, 1019, '아래 상황에서 ALTER 문의 변경만 되돌려지지 않은 원인을 가리키는 용어는?', '이 세션에서는 INSERT·UPDATE·DELETE가 COMMIT을 실행해야 확정되도록 설정되어 있다. 개발자는 두 번에 나눠 아래처럼 실험했다.

```sql
(실험 1)
INSERT INTO members (id, name) VALUES (99, ''테스트'');
ROLLBACK;

(실험 2)
ALTER TABLE members ADD nickname VARCHAR(30);
ROLLBACK;
```

실험 1 뒤에는 id 99인 행이 조회되지 않았다. 반면 실험 2 뒤에는 ROLLBACK을 실행했는데도 members 테이블에 nickname 컬럼이 그대로 남아 있었고, 다른 세션에서도 이 컬럼이 곧바로 보였다.', 'SUBJECTIVE'),
       (6298, 1019, '아래 비교에서 명령어 B에 해당하는 SQL 명령어의 이름은?', '같은 구조의 두 테이블에 똑같이 1,000만 행을 넣어 두고, 서로 다른 명령어 A와 B로 각각 모든 행을 비운 뒤 결과를 비교했다.

| 관찰 항목 | 명령어 A | 명령어 B |
| --- | --- | --- |
| 걸린 시간 | 0.4초 | 9분 12초 |
| 실행 중 남긴 기록 | 행별 기록 없음 | 지운 행마다 기록을 남김 |
| 실행 후 테이블이 차지하는 저장 공간 | 초기화됨 | 그대로 유지됨 |
| 실행 후 테이블 조회 | 0행으로 정상 조회 | 0행으로 정상 조회 |

B는 같은 명령어에 조건을 붙이면 일부 행만 골라 지우는 데에도 쓸 수 있다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6293
(16955, 6293, '작업 A 100건, 작업 B 100건', 'ROLLBACK이 어떤 삭제든 되돌린다고 본 오해다. TRUNCATE는 DDL이라 실행 즉시 자동 커밋되므로 뒤이은 ROLLBACK으로 행을 되살릴 수 없다.', false),
(16956, 6293, '작업 A 0건, 작업 B 0건', 'DELETE도 실행 즉시 확정된다고 본 오해다. DELETE는 DML이라 자동 커밋되지 않으므로, COMMIT 전에 실행한 ROLLBACK으로 100건이 돌아온다.', false),
(16957, 6293, '작업 A 100건, 작업 B 0건', 'DML인 DELETE는 COMMIT 전이라 ROLLBACK으로 100건이 복구된다. DDL인 TRUNCATE는 실행 즉시 자동 커밋되어 ROLLBACK이 효과가 없고 0건이 남는다.', true),
(16958, 6293, '작업 A 0건, 작업 B 100건', 'DELETE와 TRUNCATE의 분류를 뒤바꾼 오해다. 롤백이 가능한 쪽은 DML인 DELETE이고, DDL인 TRUNCATE는 자동 커밋되어 되돌릴 수 없다.', false),

-- 문제 6294
(16959, 6294, 'A TRUNCATE, B DROP, C DELETE', 'TRUNCATE와 DROP의 대상을 뒤바꾼 오해다. TRUNCATE는 행만 비우고 테이블은 남기므로 A의 객체 제거를 못 하고, DROP은 테이블을 없애 B의 "계속 써야 한다"를 어긴다.', false),
(16960, 6294, 'A DROP, B DELETE, C TRUNCATE', 'TRUNCATE는 WHERE 절을 쓸 수 없고 자동 커밋되어 C의 조건부 삭제·되돌리기를 둘 다 못 한다. B에 DELETE를 쓰면 행 단위 기록으로 느리고 저장 공간도 유지된다.', false),
(16961, 6294, 'A DROP, B DELETE, C DELETE', 'B를 DELETE로도 비울 수는 있지만, 행마다 기록을 남겨 느리고 저장 공간이 그대로 유지된다. "빠르게"와 "저장 공간 초기화"라는 B의 요구를 채우지 못한다.', false),
(16962, 6294, 'A DROP, B TRUNCATE, C DELETE', 'A는 구조까지 없애는 DROP, B는 테이블을 남긴 채 모든 행을 빠르게 비우고 공간을 초기화하는 TRUNCATE, C는 WHERE로 대상을 고르고 커밋 전 롤백이 되는 DELETE가 맞다.', true),

-- 문제 6295
(16963, 6295, 'id 1: 35,000원, id 2: 13,000원', 'ROLLBACK TO를 무시하고 모든 UPDATE가 반영된다고 본 계산이다. sp1으로 되돌리면 sp1 이후의 +10,000과 -5,000이 모두 취소된다.', false),
(16964, 6295, 'id 1: 40,000원, id 2: 3,000원', 'ROLLBACK TO SAVEPOINT sp1은 sp1 이후 변경(id 2 +10,000, id 1 -5,000)만 취소한다. sp1 이전 -10,000과 이후 새로 실행한 +3,000이 남아 COMMIT으로 확정된다.', true),
(16965, 6295, 'id 1: 40,000원, id 2: 13,000원', 'ROLLBACK TO가 가장 가까운 sp2까지만 되돌린다고 본 계산이다. 이 문장이 지정한 지점은 sp1이므로 sp2 이전의 +10,000까지 함께 취소된다.', false),
(16966, 6295, 'id 1: 50,000원, id 2: 3,000원', 'ROLLBACK TO를 트랜잭션 전체 롤백으로 본 계산이다. sp1 이전에 실행한 id 1의 -10,000은 취소되지 않고 남는다.', false),

-- 문제 6296
(16967, 6296, 't1 600건, t2 1,000건, t3 조회 오류(테이블 없음)', 'DELETE는 WHERE로 400건만 지워 600건이 남는다. TRUNCATE는 WHERE 절을 쓸 수 없어 구문 오류가 나 t2는 그대로 1,000건이다. DROP은 테이블 구조 자체를 없애 t3는 조회조차 안 된다.', true),
(16968, 6296, 't1 600건, t2 600건, t3 조회 오류(테이블 없음)', 'TRUNCATE도 DELETE처럼 WHERE로 지울 행을 고를 수 있다고 본 오해다. TRUNCATE는 모든 행을 비우는 명령이라 WHERE 절을 붙이면 구문 오류가 난다.', false),
(16969, 6296, 't1 600건, t2 0건, t3 조회 오류(테이블 없음)', 'TRUNCATE가 WHERE를 무시하고 모든 행을 비운다고 본 오해다. TRUNCATE는 WHERE 절을 허용하지 않아 문장 자체가 구문 오류로 실행되지 않는다.', false),
(16970, 6296, 't1 600건, t2 1,000건, t3 0건', 'DROP을 TRUNCATE처럼 행만 비우는 명령으로 본 오해다. DROP은 테이블 구조 자체를 삭제하고 저장 공간을 반환하므로 t3는 0건이 아니라 존재하지 않는 테이블이 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2054, 6297, '자동 커밋,자동커밋,오토 커밋,오토커밋,auto commit,autocommit,auto-commit,암시적 커밋,묵시적 커밋,implicit commit,DDL,DDL 자동 커밋,DDL자동커밋,DDL 자동커밋', 'ALTER는 테이블 구조를 바꾸는 DDL이고, DDL은 실행 즉시 자동 커밋되어 뒤이은 ROLLBACK으로 되돌릴 수 없다. 그래서 실험 2의 nickname 컬럼은 남아 있고 다른 세션에서도 바로 보였다. 반면 실험 1의 INSERT는 DML이라 자동 커밋되지 않고 COMMIT 전까지 ROLLBACK으로 취소된다. 롤백 지점을 정하는 SAVEPOINT나 확정 명령 COMMIT은 개발자가 직접 실행하는 TCL 명령어일 뿐, 실험 2에서 ROLLBACK을 무력하게 만든 원인이 아니다.'),
       (2055, 6298, 'DELETE,delete,DELETE FROM,딜리트', 'B는 지운 행마다 기록을 남기며 처리하기 때문에 9분이 넘게 걸렸고, 행을 비운 뒤에도 테이블이 차지하던 저장 공간이 그대로 유지되었다. 조건을 붙여 일부 행만 고를 수 있다는 점까지 합치면 WHERE 절을 쓸 수 있는 DML인 DELETE다. A는 행별 기록 없이 테이블을 초기 상태로 재생성하는 방식이라 빠르고 저장 공간도 초기화되는 TRUNCATE이며, WHERE 절을 쓸 수 없다. 실행 후 두 테이블 모두 0행으로 조회되었으므로 구조 자체를 없애고 공간을 반환하는 DROP은 어느 쪽에도 해당하지 않는다.');

-- =====================================================
-- Lesson 1020: SELECT 논리적 실행 순서와 별칭 참조
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6299, 1020, '아래 쿼리에서 DBMS가 논리적 실행 순서상 세 번째로 처리하는 절은?', '```sql
SELECT   dept_id, COUNT(*) AS cnt
FROM     employees
GROUP BY dept_id
HAVING   COUNT(*) >= 3
ORDER BY cnt DESC;
```', 'OBJECTIVE'),
       (6300, 1020, '아래 쿼리를 실행하자 오류가 났다. 오류의 원인과 해결 방법으로 옳은 것은?', '```sql
SELECT   name, salary * 12 AS annual
FROM     employees
WHERE    annual >= 60000000
ORDER BY annual DESC;
```

```
ERROR:  column "annual" does not exist
LINE 3: WHERE    annual >= 60000000
```', 'OBJECTIVE'),
       (6301, 1020, '아래 데이터에 쿼리를 실행했을 때의 결과로 옳은 것은?', 'employees 테이블 (salary 단위: 만 원)

| emp_id | dept_id | salary | hire_date |
| --- | --- | --- | --- |
| 1 | 10 | 5000 | 2023-06-01 |
| 2 | 10 | 3000 | 2024-03-01 |
| 3 | 10 | 4600 | 2024-05-10 |
| 4 | 20 | 3500 | 2024-02-01 |
| 5 | 20 | 4300 | 2023-11-20 |
| 6 | 30 | 6000 | 2024-07-01 |
| 7 | 30 | 2600 | 2024-08-15 |

```sql
SELECT   dept_id, AVG(salary) AS avg_sal
FROM     employees
WHERE    hire_date >= ''2024-01-01''
GROUP BY dept_id
HAVING   AVG(salary) >= 4000
ORDER BY avg_sal DESC;
```', 'OBJECTIVE'),
       (6302, 1020, '아래 데이터에 쿼리를 실행했을 때 돌려받는 행으로 옳은 것은?', 'students 테이블 (행이 저장된 순서대로 표시)

| name | score | bonus |
| --- | --- | --- |
| 김 | 70 | 20 |
| 이 | 95 | 0 |
| 박 | 88 | 10 |
| 최 | 60 | 40 |
| 정 | 80 | 5 |

```sql
SELECT   name, score + bonus AS total
FROM     students
WHERE    score >= 65
ORDER BY total DESC
LIMIT    2;
```', 'OBJECTIVE'),
       (6303, 1020, '아래 오류를 없애려고 조건을 옮겨 간 절의 키워드는?', '부서별 직원 수가 3명 이상인 부서만 보려고 아래 쿼리를 실행했다.

```sql
SELECT   dept_id, COUNT(*) AS cnt
FROM     employees
WHERE    COUNT(*) >= 3
GROUP BY dept_id;
```

```
ERROR:  aggregate functions are not allowed in WHERE
```

COUNT(*) >= 3 조건을 WHERE에서 빼내 GROUP BY dept_id 바로 아래에 다른 키워드로 시작하는 절로 옮겨 적자, 오류 없이 직원이 3명 이상인 부서만 조회되었다.', 'SUBJECTIVE'),
       (6304, 1020, '아래 관찰 결과로 볼 때, 별칭 avg_sal이 처음 만들어지는 절의 키워드는?', 'PostgreSQL에서 아래 쿼리를 기준으로 별칭 avg_sal을 여러 절에 하나씩 넣어 보며 실행했다.

```sql
SELECT   dept_id, AVG(salary) AS avg_sal
FROM     employees
WHERE    hire_date >= ''2024-01-01''
GROUP BY dept_id
HAVING   AVG(salary) >= 4000
ORDER BY dept_id;
```

| 바꾼 위치 | 바꾼 내용 | 결과 |
| --- | --- | --- |
| WHERE | hire_date 조건 뒤에 AND avg_sal > 0 추가 | column "avg_sal" does not exist |
| HAVING | AVG(salary) >= 4000 → avg_sal >= 4000 | column "avg_sal" does not exist |
| ORDER BY | dept_id → avg_sal DESC | 정상 실행 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6299
(16971, 6299, 'GROUP BY', '작성 순서(SELECT → FROM → GROUP BY)로 세어 본 오해다. 논리적 실행은 FROM이 첫 번째이고 이 쿼리에는 WHERE가 없으므로 GROUP BY는 두 번째다.', false),
(16972, 6299, 'HAVING', '논리적 실행 순서는 FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY다. 이 쿼리에는 WHERE가 없어 FROM, GROUP BY 다음인 HAVING이 세 번째다.', true),
(16973, 6299, 'SELECT', 'SELECT가 그룹화 직후 처리된다고 본 오해다. 그룹을 거르는 HAVING이 먼저 끝나야 SELECT가 컬럼을 고르고 별칭 cnt를 붙인다.', false),
(16974, 6299, 'ORDER BY', 'HAVING과 SELECT를 건너뛴 셈이다. 정렬은 SELECT에서 cnt가 만들어진 뒤에야 할 수 있어 이 쿼리에서 가장 마지막으로 처리된다.', false),

-- 문제 6300
(16975, 6300, 'ORDER BY도 같은 이유로 별칭을 쓸 수 없으므로, WHERE와 ORDER BY의 annual을 모두 salary * 12로 바꿔야 한다.', 'ORDER BY는 SELECT 뒤에 실행되어 별칭 annual이 이미 있으므로 그대로 써도 된다. 실제로 오류 위치도 3번째 줄의 WHERE만 가리킨다.', false),
(16976, 6300, '산술식에는 AS로 별칭을 붙일 수 없으므로, SELECT 절의 AS annual을 지우면 오류가 사라진다.', '산술식에도 별칭을 붙일 수 있다. 별칭을 지우면 ORDER BY의 annual까지 참조 대상이 사라질 뿐, 문제의 원인인 WHERE의 참조 시점은 그대로다.', false),
(16977, 6300, 'WHERE 절을 ORDER BY 절 뒤로 옮겨 적으면, 별칭이 먼저 만들어진 뒤 조건이 검사되어 오류가 사라진다.', '작성 순서를 바꾸면 논리적 실행 순서가 바뀐다고 본 오해다. 절의 작성 순서는 문법으로 정해져 있어 옮기면 구문 오류가 나고, 실행 순서도 바뀌지 않는다.', false),
(16978, 6300, 'WHERE가 SELECT보다 먼저 처리되어 그 시점엔 별칭이 없으므로, WHERE에는 salary * 12 식을 직접 써야 한다.', '논리적으로 WHERE(②)가 SELECT(⑤)보다 앞서므로 WHERE를 처리할 때 annual은 아직 없다. 식을 직접 쓰면 해결되고, SELECT 뒤에 실행되는 ORDER BY의 annual은 그대로 둬도 된다.', true),

-- 문제 6301
(16979, 6301, 'dept_id 30 (avg_sal 4300) 한 행', 'WHERE가 먼저 2024년 이후 입사자만 남겨 10은 3000·4600(평균 3800), 20은 3500, 30은 6000·2600(평균 4300)이 된다. HAVING으로 4000 이상인 그룹만 남아 30 한 행이다.', true),
(16980, 6301, 'dept_id 30 (avg_sal 4300), dept_id 10 (avg_sal 4200) 두 행', '그룹 평균을 WHERE 전에 구했다고 본 계산이다. 10의 4200은 2023년 입사자 5000까지 넣은 평균인데, WHERE가 GROUP BY보다 먼저 실행되어 그 행은 집계 전에 빠진다.', false),
(16981, 6301, 'dept_id 30 (avg_sal 6000), dept_id 10 (avg_sal 4600) 두 행', 'HAVING을 WHERE처럼 개별 행의 salary를 거르는 절로 본 계산이다. HAVING은 GROUP BY 뒤에 그룹 단위로 실행되어 AVG(salary)라는 그룹 평균을 비교한다.', false),
(16982, 6301, 'dept_id 30 (avg_sal 4300), dept_id 10 (avg_sal 3800), dept_id 20 (avg_sal 3500) 세 행', 'HAVING이 그룹화 전에 실행되어 거를 대상이 없다고 본 오해다. HAVING은 GROUP BY 다음에 실행되어 평균이 4000 미만인 10과 20을 걸러 낸다.', false),

-- 문제 6302
(16983, 6302, '이(95), 김(90)', 'LIMIT이 ORDER BY보다 먼저 실행된다고 보고, 저장 순서상 앞의 두 행(김, 이)을 자른 뒤 정렬한 결과다. LIMIT은 마지막에 실행되어 정렬된 결과에서 2행을 고른다.', false),
(16984, 6302, '최(100), 박(98)', 'WHERE가 SELECT 뒤에 실행되어 total을 기준으로 거른다고 본 결과다. WHERE는 SELECT보다 먼저 원래 컬럼 score로 거르므로, score가 60인 최는 이미 빠진다.', false),
(16985, 6302, '박(98), 이(95)', 'WHERE가 score 60인 최를 먼저 거르고, SELECT가 total(김 90·이 95·박 98·정 85)을 만든다. ORDER BY가 total 내림차순으로 정렬한 뒤 LIMIT이 앞의 두 행을 고른다.', true),
(16986, 6302, '이(95), 박(98)', 'ORDER BY가 별칭 total을 볼 수 없어 원래 score로 정렬한다고 본 결과다. ORDER BY는 SELECT 뒤에 실행되어 total로 정렬하므로 박(98)이 먼저다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2056, 6303, 'HAVING,having,HAVING 절,HAVING절,해빙', 'WHERE는 GROUP BY보다 먼저 실행되어 개별 행을 거르는 단계라, 그 시점에는 그룹이 없어 COUNT(*) 같은 집계값을 쓸 수 없다. GROUP BY 다음에 실행되어 그룹 단위로 조건을 거는 절이 HAVING이므로, 집계 조건을 HAVING으로 옮기면 부서별 직원 수가 계산된 뒤에 3명 이상인 그룹만 남는다. 같은 필터링이라도 행 단위는 WHERE, 그룹 단위는 HAVING이라는 점이 경계다.'),
       (2057, 6304, 'SELECT,select,SELECT 절,SELECT절,셀렉트', '논리적 실행 순서는 FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY다. 별칭을 WHERE와 HAVING에서 쓰면 오류가 나고 ORDER BY에서는 정상 동작했으므로, 별칭은 HAVING 뒤·ORDER BY 앞의 단계에서 생긴다. 그 단계가 컬럼을 선택하고 별칭을 붙이는 SELECT다. 별칭이 작성 순서상 맨 앞에 적혀 있다고 해서 먼저 만들어지는 것이 아니며, HAVING은 SELECT보다 먼저 실행되어 별칭을 볼 수 없다는 점에 주의한다.');
