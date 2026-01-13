-- =====================================================
-- Chapter 4: 데이터베이스 (ID: 4)
-- Unit 48: DML(Data Manipulation Language)
-- =====================================================

-- Lesson 1: DML 1 (ID: 140)
INSERT INTO lesson (id, title, unit_id)
VALUES (140, 'DML 1', 48);

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

-- Lesson 2: DML 2 (ID: 141)
INSERT INTO lesson (id, title, unit_id)
VALUES (141, 'DML 2', 48);

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

-- Lesson 3: DML 3 (ID: 142)
INSERT INTO lesson (id, title, unit_id)
VALUES (142, 'DML 3', 48);

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
