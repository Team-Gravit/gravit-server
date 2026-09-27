-- Unit: DML (Unit ID: 48)
-- Chapter: 데이터베이스 (Chapter ID: 4)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (140, 48, 'DML 정의와 INSERT·다중행 삽입'),
       (141, 48, 'UPDATE·DELETE와 WHERE 누락'),
       (142, 48, 'WHERE 조건 연산자와 IS NULL'),
       (267, 48, '연속 UPDATE 결과와 NULL 비교'),
       (336, 48, '행 개수 추적과 BETWEEN 경계'),
       (405, 48, 'INSERT 생략 컬럼과 NOT 조건'),
       (474, 48, 'UPDATE 산술 갱신과 중복 키 삽입');

-- =====================================================
-- Lesson 140: DML 정의와 INSERT·다중행 삽입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (971, 140, '다음 중 DML(Data Manipulation Language)에 대한 설명으로 올바른 것은?', 'DML은 SQL의 한 종류이다.', 'OBJECTIVE'),
       (972, 140, '빈칸에 들어갈 DML 명령어를 작성하시오.', '테이블에 새로운 행을 삽입하는 명령어는 ___이다.', 'SUBJECTIVE'),
       (973, 140, '다음 중 DML 명령어가 아닌 것은?', 'DML은 데이터를 조작하는 언어이다.', 'OBJECTIVE'),
       (974, 140, '다음 SQL 명령어의 역할은?', 'INSERT INTO students (student_id, name) VALUES (1, ''홍길동'');', 'OBJECTIVE'),
       (975, 140, '빈칸에 들어갈 DML 명령어를 작성하시오.', '테이블의 기존 데이터를 수정하는 명령어는 ___이다.', 'SUBJECTIVE'),
       (976, 140, '다음 중 다중행 삽입 SQL로 올바른 것은?', 'INSERT 명령어로 여러 행을 한 번에 삽입할 수 있다.', 'OBJECTIVE'),
       (977, 140, '다음 SQL 명령어의 역할은?', 'DELETE FROM students;', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 971
(2763, 971, '데이터베이스의 구조를 정의하는 언어이다', '이것은 DDL(Data Definition Language)의 설명이다.', false),
(2764, 971, '데이터베이스에 저장된 데이터를 조작하는 언어이다', 'DML(Data Manipulation Language)은 테이블의 행을 조회, 삽입, 수정, 삭제하는 역할을 한다.', true),
(2765, 971, '트랜잭션을 제어하는 언어이다', '이것은 TCL(Transaction Control Language)의 설명이다.', false),
(2766, 971, '사용자 권한을 관리하는 언어이다', '이것은 DCL(Data Control Language)의 설명이다.', false),

-- 문제 973
(2767, 973, 'SELECT', 'SELECT는 데이터를 조회하는 DML 명령어이다.', false),
(2768, 973, 'INSERT', 'INSERT는 데이터를 삽입하는 DML 명령어이다.', false),
(2769, 973, 'CREATE', 'CREATE는 객체를 생성하는 DDL 명령어이다. DML이 아니다.', true),
(2770, 973, 'UPDATE', 'UPDATE는 데이터를 수정하는 DML 명령어이다.', false),

-- 문제 974
(2771, 974, 'students 테이블의 데이터를 조회한다', 'SELECT가 데이터를 조회한다.', false),
(2772, 974, 'students 테이블에 새로운 행을 삽입한다', 'INSERT INTO ... VALUES는 테이블에 새로운 행을 삽입하는 명령이다. student_id가 1이고 name이 홍길동인 행이 추가된다.', true),
(2773, 974, 'students 테이블의 데이터를 수정한다', 'UPDATE가 데이터를 수정한다.', false),
(2774, 974, 'students 테이블을 생성한다', 'CREATE TABLE이 테이블을 생성한다.', false),

-- 문제 976
(2775, 976, 'INSERT INTO students VALUES (1, ''홍길동''), (2, ''김철수'')', 'VALUES 절에 여러 행을 쉼표로 구분하여 한 번에 삽입할 수 있다.', true),
(2776, 976, 'INSERT INTO students VALUES (1, ''홍길동'') AND (2, ''김철수'')', 'AND는 다중행 삽입에 사용하지 않는다.', false),
(2777, 976, 'INSERT INTO students VALUES (1, ''홍길동''); (2, ''김철수'')', '세미콜론은 문장 종료를 의미하므로 다중행 삽입이 아니다.', false),
(2778, 976, 'INSERT MULTIPLE INTO students VALUES (1, ''홍길동''), (2, ''김철수'')', 'INSERT MULTIPLE은 올바른 문법이 아니다.', false),

-- 문제 977
(2779, 977, 'students 테이블의 특정 행을 삭제한다', 'WHERE 절이 없으므로 특정 행이 아닌 모든 행을 삭제한다.', false),
(2780, 977, 'students 테이블의 모든 행을 삭제한다', 'DELETE FROM 테이블명; 형태로 WHERE 절이 없으면 테이블의 모든 행을 삭제한다.', true),
(2781, 977, 'students 테이블을 삭제한다', 'DROP TABLE이 테이블을 삭제한다.', false),
(2782, 977, 'students 테이블의 구조를 초기화한다', 'TRUNCATE가 테이블을 초기화한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (279, 972, 'insert', 'INSERT는 테이블에 새로운 행을 삽입하는 DML 명령어이다. INSERT INTO 테이블명 (컬럼1, 컬럼2) VALUES (값1, 값2); 형태로 사용한다.'),
       (280, 975, 'update', 'UPDATE는 테이블의 기존 데이터를 수정하는 DML 명령어이다. UPDATE 테이블명 SET 컬럼=값 WHERE 조건; 형태로 사용한다.');

-- =====================================================
-- Lesson 141: UPDATE·DELETE와 WHERE 누락
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (978, 141, '다음 SQL 명령어의 역할은?', 'UPDATE students SET email = ''new@example.com'' WHERE student_id = 1;', 'OBJECTIVE'),
       (979, 141, '빈칸에 들어갈 키워드를 작성하시오.', 'UPDATE students ___ name = ''홍길동'' WHERE student_id = 1; -- name 컬럼 수정', 'SUBJECTIVE'),
       (980, 141, '다음 중 UPDATE 명령어에 대한 설명으로 틀린 것은?', 'UPDATE는 DML 명령어 중 하나이다.', 'OBJECTIVE'),
       (981, 141, '다음 SQL 명령어 실행 결과는?', 'UPDATE students SET name = ''테스트'';', 'OBJECTIVE'),
       (982, 141, '빈칸에 들어갈 DML 명령어를 작성하시오.', '테이블의 행을 삭제하는 명령어는 ___이다.', 'SUBJECTIVE'),
       (983, 141, '다음 SQL 명령어의 역할은?', 'DELETE FROM students WHERE student_id = 1;', 'OBJECTIVE'),
       (984, 141, '다음 중 DELETE와 TRUNCATE의 공통점은?', 'DELETE와 TRUNCATE는 모두 데이터를 삭제한다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 978
(2783, 978, 'student_id가 1인 학생의 이메일을 수정한다', 'UPDATE ... SET ... WHERE는 조건에 맞는 행의 특정 컬럼 값을 수정한다.', true),
(2784, 978, '모든 학생의 이메일을 수정한다', 'WHERE 절이 있으므로 조건에 맞는 행만 수정된다.', false),
(2785, 978, 'student_id가 1인 학생을 삭제한다', 'DELETE가 행을 삭제한다.', false),
(2786, 978, '새로운 학생을 추가한다', 'INSERT가 새로운 행을 추가한다.', false),

-- 문제 980
(2787, 980, 'WHERE 절 없이 사용하면 모든 행이 수정된다', 'WHERE 절이 없으면 테이블의 모든 행이 수정된다.', false),
(2788, 980, '여러 컬럼을 동시에 수정할 수 있다', 'SET 절에 쉼표로 구분하여 여러 컬럼을 수정할 수 있다.', false),
(2789, 980, '조건에 맞는 행만 수정할 수 있다', 'WHERE 절로 조건을 지정하여 특정 행만 수정할 수 있다.', false),
(2790, 980, '테이블 구조를 변경할 수 있다', 'UPDATE는 데이터만 수정한다. 테이블 구조 변경은 ALTER를 사용한다.', true),

-- 문제 981
(2791, 981, '오류가 발생한다', 'WHERE 절 없이도 실행 가능하다.', false),
(2792, 981, 'student_id가 1인 학생만 수정된다', 'WHERE 절이 없으므로 모든 행이 수정된다.', false),
(2793, 981, '모든 학생의 name이 테스트로 변경된다', 'WHERE 절이 없으면 테이블의 모든 행이 수정된다.', true),
(2794, 981, '아무 변화가 없다', 'UPDATE 문이 실행되어 데이터가 변경된다.', false),

-- 문제 983
(2795, 983, '모든 학생을 삭제한다', 'WHERE 절이 있으므로 조건에 맞는 행만 삭제된다.', false),
(2796, 983, 'student_id가 1인 학생을 삭제한다', 'DELETE FROM ... WHERE는 조건에 맞는 행을 삭제한다.', true),
(2797, 983, 'student_id 컬럼을 삭제한다', 'ALTER TABLE ... DROP COLUMN이 컬럼을 삭제한다.', false),
(2798, 983, 'students 테이블을 삭제한다', 'DROP TABLE이 테이블을 삭제한다.', false),

-- 문제 984
(2799, 984, 'ROLLBACK으로 복구할 수 있다', 'DELETE는 ROLLBACK 가능하지만 TRUNCATE는 일반적으로 불가능하다.', false),
(2800, 984, 'WHERE 절을 사용할 수 있다', 'DELETE만 WHERE 절을 사용할 수 있다.', false),
(2801, 984, '테이블의 데이터를 삭제한다', 'DELETE와 TRUNCATE 모두 테이블의 데이터를 삭제한다. 단, 동작 방식과 특성이 다르다.', true),
(2802, 984, '테이블 구조도 함께 삭제한다', '두 명령어 모두 테이블 구조는 유지한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (281, 979, 'set', 'UPDATE 문에서 SET 키워드는 수정할 컬럼과 값을 지정한다. UPDATE 테이블명 SET 컬럼=값 형태로 사용한다.'),
       (282, 982, 'delete', 'DELETE는 테이블의 행을 삭제하는 DML 명령어이다. DELETE FROM 테이블명 WHERE 조건; 형태로 사용하며, WHERE 절이 없으면 모든 행이 삭제된다.');

-- =====================================================
-- Lesson 142: WHERE 조건 연산자와 IS NULL
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (985, 142, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students;', 'OBJECTIVE'),
       (986, 142, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT * FROM students ___ student_id = 1; -- 조건 지정', 'SUBJECTIVE'),
       (987, 142, '다음 중 WHERE 절의 비교 연산자로 올바르지 않은 것은?', 'WHERE 절은 조건을 지정하는 데 사용한다.', 'OBJECTIVE'),
       (988, 142, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students WHERE name LIKE ''홍%'';', 'OBJECTIVE'),
       (989, 142, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT * FROM students WHERE email ___ NULL; -- NULL 값 확인', 'SUBJECTIVE'),
       (990, 142, '다음 중 IN 연산자의 사용법으로 올바른 것은?', 'IN 연산자는 여러 값 중 하나와 일치하는지 확인한다.', 'OBJECTIVE'),
       (991, 142, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students WHERE student_id BETWEEN 1 AND 10;', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 985
(2803, 985, 'students 테이블의 특정 컬럼만 조회한다', '*는 모든 컬럼을 의미한다.', false),
(2804, 985, 'students 테이블의 모든 컬럼과 모든 행을 조회한다', 'SELECT *는 모든 컬럼을 조회하고, WHERE 절이 없으면 모든 행을 조회한다.', true),
(2805, 985, 'students 테이블을 생성한다', 'CREATE TABLE이 테이블을 생성한다.', false),
(2806, 985, 'students 테이블의 데이터를 삭제한다', 'DELETE가 데이터를 삭제한다.', false),

-- 문제 987
(2807, 987, '=', '= 연산자는 값이 같은지 비교한다.', false),
(2808, 987, '<>', '<> 연산자는 값이 다른지 비교한다. !=와 동일하다.', false),
(2809, 987, '==', 'SQL에서 동등 비교는 =를 사용한다. ==는 사용하지 않는다.', true),
(2810, 987, '>=', '>= 연산자는 크거나 같은지 비교한다.', false),

-- 문제 988
(2811, 988, '이름이 정확히 홍인 학생을 조회한다', '%는 0개 이상의 문자를 의미하는 와일드카드이다.', false),
(2812, 988, '이름이 홍으로 시작하는 학생을 조회한다', 'LIKE ''홍%''는 홍으로 시작하는 모든 값과 일치한다. %는 0개 이상의 임의 문자를 의미한다.', true),
(2813, 988, '이름이 홍으로 끝나는 학생을 조회한다', '''%홍''이 홍으로 끝나는 값과 일치한다.', false),
(2814, 988, '이름에 홍이 포함된 학생을 조회한다', '''%홍%''가 홍이 포함된 값과 일치한다.', false),

-- 문제 990
(2815, 990, 'WHERE department_id IN (1, 2, 3)', 'IN 연산자는 괄호 안에 값 목록을 지정하여 해당 값 중 하나와 일치하는지 확인한다.', true),
(2816, 990, 'WHERE department_id IN 1, 2, 3', '괄호가 필요하다.', false),
(2817, 990, 'WHERE department_id = IN (1, 2, 3)', '= 연산자와 IN을 함께 사용하지 않는다.', false),
(2818, 990, 'WHERE IN department_id (1, 2, 3)', 'IN은 컬럼명 뒤에 위치한다.', false),

-- 문제 991
(2819, 991, 'student_id가 1 또는 10인 학생을 조회한다', 'IN (1, 10)이 1 또는 10인 값을 조회한다.', false),
(2820, 991, 'student_id가 1보다 크고 10보다 작은 학생을 조회한다', 'BETWEEN은 경계값을 포함한다.', false),
(2821, 991, 'student_id가 1이 아니고 10이 아닌 학생을 조회한다', 'NOT IN (1, 10)이 해당 조건이다.', false),
(2822, 991, 'student_id가 1부터 10 사이인 학생을 조회한다', 'BETWEEN A AND B는 A 이상 B 이하의 범위를 지정한다. 1부터 10까지 포함된다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (283, 986, 'where', 'WHERE 절은 조건을 지정하여 특정 행만 조회, 수정, 삭제하는 데 사용한다. SELECT, UPDATE, DELETE 문에서 사용할 수 있다.'),
       (284, 989, 'is', 'NULL 값을 비교할 때는 = 연산자가 아닌 IS NULL 또는 IS NOT NULL을 사용한다. NULL은 값이 없음을 의미하므로 일반 비교 연산자로 비교할 수 없다.');

-- =====================================================
-- Lesson 267: 연속 UPDATE 결과와 NULL 비교
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1781, 267, '아래 SQL을 실행한 뒤 students 테이블의 상태로 옳은 것은?', '초기 상태로 students 테이블에는 5개의 행이 있고, 그중 student_id가 1인 행만 grade 값이 ''A''이다. 아래 문장을 차례로 실행한다.

```sql
UPDATE students SET grade = ''B'';
UPDATE students SET grade = ''A'' WHERE student_id = 1;
```', 'OBJECTIVE'),
       (1782, 267, '아래 조회 조건에 대한 설명으로 옳은 것은?', 'students 테이블의 name 컬럼에는 ''홍길동'', ''김길수'', ''이영희'', ''박길동님'' 네 값이 들어 있다. 아래 문장으로 조회한다.

```sql
SELECT * FROM students WHERE name LIKE ''%길%'';
```', 'OBJECTIVE'),
       (1783, 267, '아래 DML 명령어 비교표를 바탕으로 옳지 않은 것은?', '| 명령어 | 분류 | 행 단위 효과 |
| --- | --- | --- |
| SELECT | 조회 | 행을 가져오기만 함 |
| INSERT | 삽입 | 새 행을 추가 |
| UPDATE | 수정 | 기존 행의 컬럼 값을 변경 |
| DELETE | 삭제 | 조건에 맞는 행을 제거 |', 'OBJECTIVE'),
       (1784, 267, '아래 두 조회 결과의 차이를 가장 잘 설명한 것은?', E'email 컬럼에 값이 비어 있는(NULL인) 행을 찾으려고 아래 두 문장을 각각 실행했다. 두 문장의 조회 결과 행 수가 서로 달랐다.\n\n```sql\n-- (가)\nSELECT * FROM students WHERE email = NULL;\n-- (나)\nSELECT * FROM students WHERE email IS NULL;\n```', 'OBJECTIVE'),
       (1785, 267, '아래 상황에서 사용해야 할 DML 명령어의 이름은?', '운영 중인 students 테이블에서, 졸업 처리가 끝나 더 이상 보관할 필요가 없는 특정 학생들의 행 자체를 테이블에서 골라 없애려고 한다. 컬럼 값을 바꾸는 것이 아니라 행 전체를 테이블에서 제거하는 것이 목적이다.', 'SUBJECTIVE'),
       (1786, 267, '아래 WHERE 조건을 한 단어로 대체할 수 있는 SQL 연산자의 이름은?', E'department_id가 1, 2, 3 중 하나인 행을 조회하려고 한다. 아래처럼 OR로 길게 나열한 조건을, 값들을 괄호 안에 묶어 하나의 연산자로 짧게 표현할 수 있다.\n\n```sql\n-- 길게 쓴 조건\nWHERE department_id = 1 OR department_id = 2 OR department_id = 3\n```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1781
(4923, 1781, 'student_id가 1인 행만 ''B''가 되고 나머지 4개 행은 처음 값을 유지한다.', 'WHERE가 없는 첫 UPDATE의 효과를 거꾸로 이해한 오개념이다. WHERE 없는 UPDATE는 특정 행이 아니라 모든 행에 적용된다.', false),
(4924, 1781, '모든 행의 grade가 ''B''가 되고, student_id가 1인 행만 다시 ''A''가 된다.', '첫 UPDATE는 WHERE가 없어 5개 행 전체를 ''B''로 바꾼다. 이어진 두 번째 UPDATE는 WHERE로 student_id=1 행만 ''A''로 되돌린다.', true),
(4925, 1781, 'WHERE가 없는 첫 문장은 오류로 거부되고, student_id가 1인 행만 ''A''로 남는다.', 'WHERE 없는 UPDATE가 문법 오류라는 오개념이다. WHERE는 선택 사항이며, 생략하면 전체 행이 대상이 될 뿐 오류가 아니다.', false),
(4926, 1781, '두 UPDATE가 충돌하여 grade가 모두 NULL로 초기화된다.', 'UPDATE를 덮어쓰기 충돌로 오해한 오개념이다. 두 문장은 순서대로 실행될 뿐 충돌하지 않으며, NULL로 만들지도 않는다.', false),

-- 문제 1782
(4927, 1782, '''홍길동'', ''김길수'', ''박길동님'' 세 행이 조회된다.', '%는 0글자 이상 임의 문자열과 일치하므로 ''길''이 이름 어디에든 들어간 행이 모두 잡힌다. 앞뒤에 다른 글자가 붙은 ''박길동님''도 포함된다.', true),
(4928, 1782, '''김길수'' 한 행만 조회된다. 가운데에 ''길''이 있는 이름만 일치한다.', '%가 양옆에 있어도 가운데 글자만 매칭한다고 본 오개념이다. %길%는 위치와 무관하게 ''길''을 포함하기만 하면 모두 일치한다.', false),
(4929, 1782, '''길''이라는 이름을 가진 행이 없으므로 한 행도 조회되지 않는다.', 'LIKE ''%길%''를 정확히 ''길''과 같은지 비교하는 = 조건으로 오해한 것이다. %가 붙으면 부분 일치를 검사한다.', false),
(4930, 1782, '네 행이 모두 조회된다. %가 붙으면 테이블의 모든 행을 반환한다.', '''%''만 단독으로 쓰면 전체와 일치하지만, ''%길%''는 ''길'' 포함이라는 조건이 남는다. ''이영희''는 ''길''이 없어 제외된다.', false),

-- 문제 1783
(4931, 1783, 'SELECT는 행을 가져오기만 할 뿐 테이블의 행 개수나 값을 바꾸지 않는다.', '표의 SELECT=조회, ''행을 가져오기만 함''에서 바로 따라 나오는 참인 진술이다. SELECT는 데이터를 읽는 명령어다.', false),
(4932, 1783, 'INSERT는 테이블에 새로운 행을 추가하여 행 개수를 늘린다.', '표의 INSERT=삽입, ''새 행을 추가''와 일치하는 참인 진술이다. INSERT는 행을 더해 데이터를 채운다.', false),
(4933, 1783, 'UPDATE는 기존 행을 그대로 두고 조건에 맞는 새 행을 복제해 추가한다.', '표에서 UPDATE는 ''기존 행의 컬럼 값을 변경''인데 이를 행 복제·추가로 바꾼 거짓 진술이다. 행을 늘리는 것은 INSERT의 역할이다.', true),
(4934, 1783, 'DELETE는 조건에 맞는 행을 테이블에서 제거하여 행 개수를 줄인다.', '표의 DELETE=삭제, ''조건에 맞는 행을 제거''와 일치하는 참인 진술이다. DELETE는 행 단위로 데이터를 없앤다.', false),

-- 문제 1784
(4935, 1784, '(가)는 NULL을 =로 비교해 어떤 행과도 일치하지 않고, (나)가 IS NULL로 빈 값 행을 제대로 찾는다.', 'NULL은 ''값이 없음''이라 =로는 비교 자체가 참이 되지 않는다. 그래서 빈 값을 찾으려면 = NULL이 아니라 IS NULL을 써야 한다.', true),
(4936, 1784, '(가)와 (나)는 의미가 같고, 결과 차이는 우연히 생긴 데이터 정렬 때문이다.', '= NULL과 IS NULL이 동치라는 오개념이다. 둘은 동작이 다르며, = NULL은 빈 값 행을 잡지 못한다.', false),
(4937, 1784, '(가)가 email이 빈 값인 행을 찾고, (나)는 빈 값이 아닌 행을 찾는다.', '두 문장의 역할을 뒤바꾼 오개념이다. 빈 값이 아닌 행은 IS NOT NULL로 찾으며, = NULL은 빈 값 행조차 찾지 못한다.', false),
(4938, 1784, '(나)는 문법 오류로 거부되고, (가)만 정상 실행되어 빈 값 행을 반환한다.', 'IS NULL을 잘못된 문법으로, = NULL을 올바른 문법으로 거꾸로 본 오개념이다. NULL 비교의 표준 문법이 IS NULL이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (550, 1785, 'DELETE,delete,딜리트', '컬럼 값을 바꾸지 않고 조건에 맞는 행 자체를 테이블에서 제거하는 명령어는 DELETE다. 행은 그대로 두고 컬럼 값만 바꾸는 UPDATE와 헷갈리지 않도록 주의한다.'),
       (551, 1786, 'IN,in', '여러 값 중 하나와 일치하는지를 괄호 안 목록으로 묶어 검사하는 연산자는 IN이다. 두 값 사이의 범위를 검사하는 BETWEEN과 달리, IN은 나열된 개별 값들과의 일치를 본다는 점에서 헷갈리지 않도록 주의한다.');

-- =====================================================
-- Lesson 336: 행 개수 추적과 BETWEEN 경계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (2195, 336, '아래 INSERT 문을 차례로 실행한 뒤 students 테이블의 행 개수는?', '초기 상태로 students 테이블은 비어 있다(행 0개). 아래 두 문장을 순서대로 실행한다.

```sql
INSERT INTO students (student_id, name)
VALUES (1, ''홍길동'');

INSERT INTO students (student_id, name)
VALUES
    (2, ''김철수''),
    (3, ''이영희''),
    (4, ''박민수'');
```', 'OBJECTIVE'),
       (2196, 336, '아래 SQL을 차례로 실행한 뒤 students 테이블에 남는 행으로 옳은 것은?', '초기 상태로 students 테이블에는 student_id가 1, 2, 3, 4, 5인 행 5개가 있다. 아래 두 문장을 순서대로 실행한다.

```sql
DELETE FROM students WHERE student_id > 3;
DELETE FROM students;
```', 'OBJECTIVE'),
       (2197, 336, '아래 조회 문장이 반환하는 행으로 옳은 것은?', 'students 테이블의 student_id 컬럼에는 1, 3, 5, 7, 10 다섯 값이 들어 있다. 아래 문장으로 조회한다.

```sql
SELECT * FROM students WHERE student_id BETWEEN 3 AND 7;
```', 'OBJECTIVE'),
       (2198, 336, '아래 조회 문장이 반환하는 행으로 옳은 것은?', 'students 테이블에는 아래 세 행이 있다.

| student_id | dept_id | grade |
| --- | --- | --- |
| 1 | 1 | A |
| 2 | 2 | A |
| 3 | 1 | B |

```sql
SELECT * FROM students WHERE dept_id = 1 AND grade = ''A'' OR grade = ''B'';
```', 'OBJECTIVE'),
       (2199, 336, '아래 상황에서 사용해야 할 DML 명령어의 이름은?', '운영 중인 students 테이블에서 학번이 1인 학생의 이메일 주소가 바뀌었다. 행을 새로 추가하거나 지우지 않고, 그 행의 email 컬럼 값만 새 주소로 바꾸려고 한다.', 'SUBJECTIVE'),
       (2200, 336, '아래 빈칸에 들어갈 LIKE 패턴의 와일드카드 문자는?', '이름이 정확히 세 글자인 학생만 조회하려고 한다. 자리 수에 상관없이 임의의 문자열과 일치하는 % 대신, 한 자리당 임의의 한 글자와 일치하는 와일드카드를 세 번 이어 붙여 아래처럼 작성했다.

```sql
SELECT * FROM students WHERE name LIKE ''___'';
```

위 패턴에서 한 글자를 대신하는 와일드카드 문자는 무엇인가?', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 2195
(6027, 2195, '1개. 두 번째 INSERT는 여러 행을 한 번에 넣으므로 묶음 전체가 한 행으로 저장된다.', '다중행 INSERT를 한 행으로 합쳐 넣는다고 본 오개념이다. VALUES 뒤 괄호 하나가 행 하나이므로, 괄호 세 개는 세 행이 된다.', false),
(6028, 2195, '2개. INSERT 문 한 번이 행 하나를 만드므로 문장 두 개면 두 행이 생긴다.', 'INSERT 문장 수를 곧 행 수로 본 오개념이다. 행 수는 문장 수가 아니라 VALUES 뒤 괄호(튜플)의 개수로 정해진다.', false),
(6029, 2195, '4개. 첫 문장이 1행, 둘째 문장이 3행을 추가해 모두 4행이 된다.', '단일행 INSERT가 1행, 다중행 INSERT의 괄호 3개가 3행을 추가하므로 빈 테이블에 총 4행이 쌓인다.', true),
(6030, 2195, '0개. 같은 테이블에 INSERT를 두 번 실행하면 뒤 문장이 앞 문장의 행을 덮어쓴다.', 'INSERT를 UPDATE처럼 덮어쓰기로 오해한 오개념이다. INSERT는 기존 행을 지우지 않고 새 행을 더하기만 한다.', false),

-- 문제 2196
(6031, 2196, '한 행도 남지 않는다. 두 번째 DELETE에 WHERE가 없어 테이블의 모든 행이 제거된다.', '첫 DELETE가 student_id 4·5를 지워 3행이 남고, 이어 WHERE 없는 DELETE가 남은 3행마저 전부 지운다. WHERE 없는 DELETE는 전체 행이 대상이다.', true),
(6032, 2196, 'student_id가 1, 2, 3인 행이 남는다. 두 번째 DELETE는 첫 문장이 지운 행만 되돌린다.', 'WHERE 없는 DELETE가 직전 삭제를 취소한다고 본 오개념이다. DELETE는 되돌리는 명령이 아니라, WHERE가 없으면 남은 행을 모두 지운다.', false),
(6033, 2196, 'student_id가 4, 5인 행이 남는다. BETWEEN처럼 3보다 큰 값만 보존된다.', '첫 DELETE의 조건 student_id > 3을 보존 조건으로 거꾸로 읽은 오개념이다. 조건에 맞는 행은 보존이 아니라 삭제 대상이다.', false),
(6034, 2196, 'WHERE 없는 두 번째 DELETE는 오류로 거부되고, student_id가 1, 2, 3인 행이 남는다.', 'WHERE 없는 DELETE가 문법 오류라는 오개념이다. WHERE는 선택 사항이며, 생략하면 전체 행이 삭제될 뿐 오류가 아니다.', false),

-- 문제 2197
(6035, 2197, 'student_id가 5, 7인 두 행만 조회된다. BETWEEN은 양 끝 경계값을 제외한다.', 'BETWEEN을 경계값을 빼는 초과·미만 조건으로 본 오개념이다. BETWEEN a AND b는 a와 b를 포함하는 이상·이하 범위다.', false),
(6036, 2197, 'student_id가 3, 5, 7인 세 행이 조회된다. BETWEEN은 양 끝 경계값을 포함한다.', 'BETWEEN 3 AND 7은 3 이상 7 이하를 뜻해 경계값 3과 7을 포함한다. 값 1과 10은 범위 밖이라 빠진다.', true),
(6037, 2197, 'student_id가 1, 3, 5, 7인 네 행이 조회된다. BETWEEN은 작은 쪽 경계만 무시한다.', '범위의 아래 경계를 열어 둔 채로 본 오개념이다. BETWEEN은 두 경계를 모두 닫은 구간이라 1은 3 미만이므로 제외된다.', false),
(6038, 2197, '다섯 행이 모두 조회된다. BETWEEN이 붙은 조회는 전체 행을 반환한다.', 'BETWEEN을 조건 없는 전체 조회로 본 오개념이다. BETWEEN은 지정한 범위에 드는 행만 거른다.', false),

-- 문제 2198
(6039, 2198, 'student_id가 1, 3인 두 행이 조회된다. AND가 OR보다 먼저 묶이기 때문이다.', 'AND를 OR보다 먼저 계산해 (dept_id=1 AND grade=A) OR (grade=B)로 묶는 것이 표준이다. 1행은 앞 조건, 3행은 grade=B로 각각 참이 된다.', true),
(6040, 2198, 'student_id가 1, 2인 두 행이 조회된다. 조건은 왼쪽에서 오른쪽 순서대로 묶인다.', 'OR를 AND보다 먼저 또는 같은 우선순위로 본 오개념이다. AND가 먼저 묶이므로 grade=A인 2행은 dept_id=1이 아니라 빠진다.', false),
(6041, 2198, 'student_id가 1인 한 행만 조회된다. AND와 OR가 모두 동시에 만족돼야 한다.', 'OR를 또 하나의 AND처럼 본 오개념이다. OR는 어느 한쪽만 참이어도 행을 통과시키므로 grade=B인 3행도 결과에 든다.', false),
(6042, 2198, '세 행이 모두 조회된다. AND와 OR가 섞이면 조건이 무시되고 전체가 반환된다.', '연산자가 섞이면 조건이 풀린다고 본 오개념이다. 우선순위 규칙으로 AND가 먼저 묶일 뿐 조건은 그대로 적용돼 2행은 걸러진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (688, 2199, 'UPDATE,update,업데이트', '행을 더하거나 지우지 않고 기존 행의 특정 컬럼 값만 새 값으로 바꾸는 명령어는 UPDATE다. 새 행을 더하는 INSERT, 행 자체를 없애는 DELETE와 달리 UPDATE는 행 개수를 그대로 두고 값만 고친다는 점에서 헷갈리지 않도록 주의한다.'),
       (689, 2200, '_,언더스코어,언더바,밑줄', 'LIKE 패턴에서 임의의 한 글자와 일치하는 와일드카드는 밑줄(_)이다. ___처럼 세 번 쓰면 정확히 세 글자인 값에 일치한다. 자리 수에 상관없이 0글자 이상 임의 문자열과 일치하는 %와 헷갈리지 않도록 주의한다.');

-- =====================================================
-- Lesson 405: INSERT 생략 컬럼과 NOT 조건
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (2609, 405, '아래 INSERT를 실행한 직후 새로 추가된 행의 상태로 옳은 것은?', 'students 테이블은 (student_id, name, email, grade) 네 컬럼으로 이루어져 있고, 어떤 컬럼에도 기본값(DEFAULT)이 지정되어 있지 않다. 아래 문장을 실행한다.

```sql
INSERT INTO students (student_id, name)
VALUES (7, ''장보고'');
```', 'OBJECTIVE'),
       (2610, 405, '아래 조회 문장이 반환하는 행으로 옳은 것은?', 'students 테이블에는 아래 네 행이 있다. grade 컬럼이 비어 있는(NULL인) 행이 섞여 있다.

| student_id | grade |
| --- | --- |
| 1 | A |
| 2 | B |
| 3 | (NULL) |
| 4 | B |

```sql
SELECT * FROM students WHERE grade != ''A'';
```', 'OBJECTIVE'),
       (2611, 405, '아래 조회 문장이 반환하는 행으로 옳은 것은?', 'students 테이블에는 아래 세 행이 있다.

| student_id | dept_id |
| --- | --- |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |

```sql
SELECT * FROM students WHERE NOT dept_id = 1;
```', 'OBJECTIVE'),
       (2612, 405, '아래 두 조회 문장의 결과 차이를 옳게 설명한 것은?', E'students 테이블의 name 컬럼에는 ''홍길동'', ''김영동'', ''동길수'' 세 값이 들어 있다. 아래 두 문장을 각각 실행한다.\n\n```sql\n-- (가)\nSELECT * FROM students WHERE name LIKE ''홍%'';\n-- (나)\nSELECT * FROM students WHERE name LIKE ''%동'';\n```', 'OBJECTIVE'),
       (2613, 405, '아래 상황에서 실행해야 할 DML 명령어의 이름은?', '고객센터 상담원이 전화 문의를 받고 어드민 화면에서 students 테이블을 열었다. 화면에는 student_id가 5인 학생의 name과 grade 컬럼 값이 표 형태로 그대로 떠 있었고, 상담원은 화면에 표시된 grade ''A''를 그대로 읽어 고객에게 알려 준 뒤 전화를 끊었다.', 'SUBJECTIVE'),
       (2614, 405, '아래 WHERE 조건을 한 단어로 대체할 수 있는 SQL 연산자의 이름은?', E'student_id가 5 이상 10 이하인 행을 조회하려고 한다. 아래처럼 두 개의 비교 연산을 AND로 이어 붙인 조건을, 두 경계값을 한 번에 묶어 더 짧은 하나의 연산자로 바꿔 쓰려고 한다.\n\n```sql\n-- 길게 쓴 조건\nWHERE student_id >= 5 AND student_id <= 10\n```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 2609
(7131, 2609, '문장이 거부된다. INSERT는 테이블의 모든 컬럼에 값을 빠짐없이 지정해야 실행된다.', '모든 컬럼을 채워야 INSERT가 된다고 본 오개념이다. 컬럼 목록에 적은 컬럼에만 값을 넣으면 되고, 나머지는 자동으로 채워진다.', false),
(7132, 2609, '값을 적지 않은 email과 grade에는 빈 문자열('''')이 들어간 행이 추가된다.', '값이 없는 컬럼이 빈 문자열로 채워진다고 본 오개념이다. 빈 문자열은 길이 0인 값이고, 값 자체가 없는 NULL과는 다르다.', false),
(7133, 2609, '값을 적지 않은 email과 grade에는 NULL이 들어간 행이 추가된다.', '컬럼 목록에 적힌 컬럼에만 값이 들어가고, 빠진 컬럼은 기본값이 없으면 값 없음(NULL)으로 채워진다. student_id=7, name=''장보고''인 한 행이 추가된다.', true),
(7134, 2609, '직전에 삽입된 행의 email과 grade 값이 새 행에 그대로 복사되어 들어간다.', '빠진 컬럼이 이전 행에서 값을 물려받는다고 본 오개념이다. INSERT는 다른 행을 참조하지 않으며, 명시하지 않은 컬럼은 기본값이나 NULL로만 채워진다.', false),

-- 문제 2610
(7135, 2610, 'student_id가 2, 4인 두 행만 조회된다. grade가 NULL인 행은 != 비교에서 참이 되지 못해 빠진다.', 'NULL은 ''값이 없음''이라 ''A''와 같은지 다른지 자체를 판정할 수 없어 != ''A''도 참이 되지 않는다. 그래서 grade=B인 2·4번만 잡히고, NULL인 3번은 제외된다.', true),
(7136, 2610, 'student_id가 2, 3, 4인 세 행이 조회된다. grade가 ''A''만 아니면 NULL을 포함해 모두 잡힌다.', 'NULL을 ''A가 아닌 어떤 값''으로 묶어 != 조건에 포함시킨 오개념이다. NULL은 비교 결과가 참도 거짓도 아닌 미지라 != 조건을 통과하지 못한다.', false),
(7137, 2610, '아무 행도 조회되지 않는다. != 연산자는 문자열 컬럼에는 쓸 수 없다.', '!=가 숫자 전용이라는 오개념이다. !=는 문자열에도 쓸 수 있으며, grade가 ''A''와 다른 행을 정상적으로 가려낸다.', false),
(7138, 2610, 'student_id가 1인 행만 조회된다. !=는 뒤에 적은 값과 같은 행을 찾는다.', '!=를 ''같다''(=)로 거꾸로 읽은 오개념이다. !=는 양쪽이 서로 다를 때 참이므로 ''A''와 같은 1번은 오히려 제외된다.', false),

-- 문제 2611
(7139, 2611, 'student_id가 1인 행만 조회된다. NOT은 뒤따르는 조건을 강조해 그대로 참으로 만든다.', 'NOT을 조건을 강조하는 수식어로 본 오개념이다. NOT은 조건의 참·거짓을 뒤집으므로 dept_id=1인 행은 오히려 결과에서 빠진다.', false),
(7140, 2611, '세 행이 모두 조회된다. NOT이 붙으면 조건이 풀려 전체 행이 반환된다.', 'NOT이 조건을 무력화한다고 본 오개념이다. NOT은 조건을 없애는 것이 아니라 결과를 반대로 뒤집어, dept_id=1이 아닌 행만 남긴다.', false),
(7141, 2611, '아무 행도 조회되지 않는다. NOT과 = 를 함께 쓰면 문법 오류가 난다.', 'NOT과 =를 같이 못 쓴다는 오개념이다. NOT dept_id = 1은 dept_id <> 1과 같은 정상 조건으로, 조건에 맞는 행을 반환한다.', false),
(7142, 2611, 'student_id가 2, 3인 두 행이 조회된다. dept_id가 1이라는 조건을 뒤집어 1이 아닌 행만 남는다.', 'NOT은 뒤따르는 조건(dept_id=1)의 참·거짓을 반전시킨다. dept_id가 1인 1번은 제외되고, 1이 아닌 2번·3번이 결과에 든다.', true),

-- 문제 2612
(7143, 2612, '(가)는 ''홍길동''만, (나)는 ''김영동''과 ''동길수''를 반환한다.', '%는 0글자 이상 임의 문자열과 일치한다. ''홍%''는 ''홍''으로 시작하는 값이라 ''홍길동''만, ''%동''은 ''동''으로 끝나는 값이라 ''김영동''만 잡는다. ''동길수''는 ''동''으로 끝나지 않아 (나)에서도 빠진다.', false),
(7144, 2612, '(가)는 ''홍길동''을, (나)는 ''김영동''을 반환한다. (가)는 앞글자, (나)는 끝글자로 거른다.', '''홍%''는 ''홍''으로 시작하는 ''홍길동''을 잡고, ''%동''은 ''동''으로 끝나는 값을 잡는다. 끝이 ''동''인 것은 ''김영동''뿐이고, ''동길수''는 ''동''으로 시작할 뿐 끝나지 않아 제외된다.', true),
(7145, 2612, '(가)와 (나) 모두 ''동''이 들어간 세 값을 똑같이 반환한다.', '''홍%''와 ''%동''을 ''%동%''처럼 부분 포함으로 본 오개념이다. % 위치가 한쪽에만 있으면 시작 또는 끝을 고정해 거르므로 결과가 서로 다르다.', false),
(7146, 2612, '(가)는 ''동길수''를, (나)는 ''홍길동''을 반환한다.', '''홍%''와 ''%동''에서 %의 위치를 거꾸로 읽은 오개념이다. ''홍%''는 끝이 아니라 ''홍''으로 시작을, ''%동''은 시작이 아니라 ''동''으로 끝을 고정한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (826, 2613, 'SELECT,select,셀렉트', '화면에 이미 저장된 컬럼 값을 그대로 표시해 읽어 오기만 하는 작업은 SELECT다. 새 행을 더하는 INSERT, 기존 값을 다른 값으로 바꾸는 UPDATE, 행을 없애는 DELETE는 모두 테이블의 내용을 바꾸지만, SELECT만 테이블을 건드리지 않고 데이터를 가져와 보여 준다는 점에서 헷갈리지 않도록 주의한다.'),
       (827, 2614, 'BETWEEN,between,비트윈', '두 경계값을 한 번에 묶어 그 사이의 범위에 드는지 검사하는 연산자는 BETWEEN이다. 나열한 개별 값들과의 일치를 보는 IN과 달리, BETWEEN은 하한과 상한으로 정한 이상·이하 구간에 드는 행을 거른다는 점에서 헷갈리지 않도록 주의한다.');

-- =====================================================
-- Lesson 474: UPDATE 산술 갱신과 중복 키 삽입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3023, 474, '아래 SQL을 실행한 뒤 accounts 테이블의 상태로 옳은 것은?', '초기 상태로 accounts 테이블에는 아래 세 행이 있다.

| id | balance |
| --- | --- |
| 1 | 100 |
| 2 | 200 |
| 3 | 300 |

```sql
UPDATE accounts SET balance = balance + 50;
```', 'OBJECTIVE'),
       (3024, 474, '아래 두 문장을 차례로 실행한 뒤 members 테이블의 상태로 옳은 것은?', '초기 상태로 members 테이블에는 student_id가 1, 2, 3인 행 3개가 있고, 모든 행의 phone 컬럼에 값이 채워져 있다. 아래 두 문장을 순서대로 실행한다.

```sql
UPDATE members SET phone = NULL WHERE student_id = 1;
DELETE FROM members WHERE student_id = 2;
```', 'OBJECTIVE'),
       (3025, 474, '아래 조회 문장이 반환하는 행으로 옳은 것은?', 'orders 테이블에는 아래 다섯 행이 있다.

| order_id | dept_id |
| --- | --- |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 4 |
| 5 | 2 |

```sql
SELECT * FROM orders WHERE dept_id IN (2, 4);
```', 'OBJECTIVE'),
       (3026, 474, '아래 조회 문장이 반환하는 행으로 옳은 것은?', 'members 테이블의 name 컬럼에는 ''김민'', ''김민수'', ''박민'', ''김수'' 네 값이 들어 있다. 아래 문장으로 조회한다.

```sql
SELECT * FROM members WHERE name LIKE ''김_'';
```', 'OBJECTIVE'),
       (3027, 474, '아래 상황에서 운영자가 실행한 DML 명령어의 이름은?', 'student_id가 기본 키인 members 테이블에 같은 한 문장을 운영자가 두 번 실행했다. 첫 실행 직후 테이블 행 수는 5개에서 6개로 늘었다. 곧바로 똑같은 문장을 다시 실행하자 이번에는 "duplicate key value violates unique constraint" 오류가 뜨면서 거부되었고, 행 수는 6개 그대로였다.', 'SUBJECTIVE'),
       (3028, 474, '아래 빈칸에서 쓰이는 SQL 키워드의 이름은?', 'members 테이블의 email 컬럼에서 도메인이 ''@gmail.com''으로 끝나는 회원만 찾으려고 한다. 정확히 같은 값을 비교하는 =로는 풀 수 없어, 와일드카드 %를 붙인 패턴과 함께 쓰는 키워드를 아래 빈칸에 넣었다.

```sql
SELECT * FROM members WHERE email ____ ''%@gmail.com'';
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3023
(8235, 3023, 'id가 1인 행만 balance가 150이 되고, 2·3번 행은 처음 값을 유지한다.', 'WHERE 없는 UPDATE가 첫 행에만 적용된다고 본 오개념이다. WHERE가 없으면 세 행 모두가 대상이 되어 각자 50씩 늘어난다.', false),
(8236, 3023, '세 행의 balance가 모두 같은 값으로 맞춰져 셋 다 50이 된다.', 'SET balance = balance + 50을 모든 행을 한 값으로 덮어쓰는 것으로 본 오개념이다. balance + 50은 각 행이 가진 자기 값에 50을 더하므로 행마다 결과가 다르다.', false),
(8237, 3023, '세 행의 balance가 각각 150, 250, 350이 된다.', 'WHERE 없는 UPDATE는 모든 행을 대상으로 한다. balance + 50은 각 행의 기존 balance에 50을 더하므로 100·200·300이 각각 150·250·350으로 바뀐다.', true),
(8238, 3023, '세 행의 balance에 모두 50이 더해진 새 행 3개가 추가되어 행이 6개가 된다.', 'UPDATE가 새 행을 만든다고 본 오개념이다. UPDATE는 기존 행의 값을 제자리에서 고칠 뿐 행 개수를 늘리지 않는다. 행을 더하는 것은 INSERT다.', false),

-- 문제 3024
(8239, 3024, 'student_id가 1·3인 두 행이 남고, 그중 1번 행의 phone은 비어 있다(NULL).', '첫 UPDATE는 1번 행의 phone만 NULL로 바꿀 뿐 행을 지우지 않는다. 이어진 DELETE가 2번 행 자체를 제거해, 1번(phone NULL)과 3번 두 행이 남는다.', true),
(8240, 3024, 'student_id가 3인 한 행만 남는다. phone을 NULL로 바꾼 1번 행도 함께 사라진다.', 'phone을 NULL로 만든 것을 행 삭제로 본 오개념이다. UPDATE ... SET phone = NULL은 컬럼 값만 비울 뿐 행은 그대로 남는다. 행을 없애는 것은 DELETE다.', false),
(8241, 3024, '세 행이 모두 남는다. UPDATE와 DELETE는 같은 테이블에 함께 쓰면 서로 효과가 상쇄된다.', '두 명령이 서로를 취소한다고 본 오개념이다. 두 문장은 순서대로 각각 실행되며, DELETE는 조건에 맞는 2번 행을 실제로 제거한다.', false),
(8242, 3024, 'student_id가 1·2·3인 세 행이 모두 남고, 1번과 2번의 phone이 비워진다(NULL).', 'DELETE를 행 삭제가 아니라 컬럼을 비우는 동작으로 본 오개념이다. DELETE는 컬럼만 비우는 것이 아니라 조건에 맞는 행 자체를 테이블에서 없앤다.', false),

-- 문제 3025
(8243, 3025, 'order_id가 2, 4, 5인 세 행이 조회된다.', 'IN (2, 4)는 dept_id가 목록의 2 또는 4와 같은 행을 모두 고른다. dept_id가 2인 2번·5번과 4인 4번이 잡히고, 1·3번은 목록에 없어 빠진다.', true),
(8244, 3025, 'order_id가 2, 4인 두 행만 조회된다. IN은 각 값과 한 행씩만 짝지어 고른다.', 'IN이 목록의 값마다 행 하나씩만 집는다고 본 오개념이다. IN은 dept_id가 목록 값과 같으면 모두 고르므로, dept_id=2가 두 행이면 둘 다 잡힌다.', false),
(8245, 3025, 'order_id가 3, 4, 5인 세 행이 조회된다. IN (2, 4)는 2와 4 사이의 범위를 뜻한다.', 'IN을 BETWEEN처럼 범위로 본 오개념이다. IN (2, 4)는 2 이상 4 이하가 아니라 값이 정확히 2이거나 4인 행만 고른다. dept_id=3은 목록에 없어 제외된다.', false),
(8246, 3025, '다섯 행이 모두 조회된다. IN이 붙은 조회는 테이블의 전체 행을 반환한다.', 'IN을 조건 없는 전체 조회로 본 오개념이다. IN은 dept_id가 괄호 안 목록에 든 행만 거르므로, 목록에 없는 1·3번은 결과에서 빠진다.', false),

-- 문제 3026
(8247, 3026, '한 행도 조회되지 않는다. ''김_''와 정확히 같은 이름이 테이블에 없기 때문이다.', 'LIKE ''김_''를 글자 그대로의 값과 같은지 보는 = 비교로 본 오개념이다. _는 와일드카드라 임의의 한 글자를 대신하므로, ''김'' 뒤에 한 글자가 붙은 이름이 매칭된다.', false),
(8248, 3026, '''김민''과 ''김수'' 두 행이 조회된다.', '_는 임의의 한 글자 정확히 하나와 일치하므로 ''김_''는 ''김'' 뒤에 글자 하나가 붙은 두 글자 이름에 맞는다. ''김민''과 ''김수''가 잡히고, 세 글자인 ''김민수''와 ''김''으로 시작하지 않는 ''박민''은 빠진다.', true),
(8249, 3026, '''김민'', ''김민수'', ''김수'' 세 행이 조회된다. ''김''으로 시작하면 글자 수와 무관하게 모두 일치한다.', '_를 ''김''으로 시작하기만 하면 되는 %처럼 본 오개념이다. _는 한 글자만 대신하므로 ''김'' 뒤에 두 글자가 더 붙은 세 글자 ''김민수''는 ''김_''에 맞지 않는다.', false),
(8250, 3026, '''김민'', ''박민'', ''김수'' 세 행이 조회된다. _는 마지막 한 글자가 무엇이든 상관없게 한다.', '_가 끝 글자만 자유롭게 두고 앞부분은 안 따진다고 본 오개념이다. ''김_''는 첫 글자가 반드시 ''김''이어야 하므로 ''박''으로 시작하는 ''박민''은 첫 글자부터 어긋나 제외된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (964, 3027, 'INSERT,insert,인서트', '행 수를 5개에서 6개로 늘린 것은 새 행을 더한 INSERT다. 같은 문장을 다시 실행했을 때 student_id 기본 키 값이 이미 있는 값과 겹쳐 중복 키 제약 위반으로 거부된 것이 결정적 단서다. 같은 키로 다시 넣으면 막히는 INSERT와 달리, UPDATE·DELETE는 기존 행을 다룰 뿐 행 수를 늘리지 않고 중복 키 오류도 내지 않는다는 점에서 구분한다.'),
       (965, 3028, 'LIKE,like,라이크', '%·_ 같은 와일드카드 패턴으로 부분 일치를 검사할 때 쓰는 키워드는 LIKE다. 값이 정확히 같은지만 보는 =와 달리, LIKE는 ''%@gmail.com''처럼 끝부분이나 일부만 맞아도 행을 고를 수 있다는 점에서 헷갈리지 않도록 주의한다.');
