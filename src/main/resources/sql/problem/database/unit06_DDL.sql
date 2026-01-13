-- =====================================================
-- Chapter 4: 데이터베이스 (ID: 4)
-- Unit 47: DDL(Data Definition Language)
-- =====================================================

-- Lesson 1: DDL 1 (ID: 137)
INSERT INTO lesson (id, title, unit_id)
VALUES (137, 'DDL 1', 47);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (950, 137, '다음 중 DDL(Data Definition Language)에 대한 설명으로 올바른 것은?', 'DDL은 SQL의 한 종류이다.', 'OBJECTIVE'),
       (951, 137, '빈칸에 들어갈 DDL 명령어를 작성하시오.', '데이터베이스, 테이블 등 객체를 생성하는 명령어는 ___이다.', 'SUBJECTIVE'),
       (952, 137, '다음 중 DDL 명령어가 아닌 것은?', 'DDL은 데이터베이스 구조를 정의하는 언어이다.', 'OBJECTIVE'),
       (953, 137, '다음 SQL 명령어의 역할은?', 'CREATE DATABASE school;', 'OBJECTIVE'),
       (954, 137, '빈칸에 들어갈 DDL 명령어를 작성하시오.', '테이블의 구조를 수정하는 명령어는 ___이다.', 'SUBJECTIVE'),
       (955, 137, '다음 중 DROP 명령어에 대한 설명으로 올바른 것은?', 'DROP은 DDL 명령어 중 하나이다.', 'OBJECTIVE'),
       (956, 137, '다음 중 TRUNCATE와 DROP의 차이점으로 올바른 것은?', 'TRUNCATE와 DROP은 모두 DDL 명령어이다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 950
(2703, 950, '데이터를 조회하고 조작하는 언어이다', '이것은 DML(Data Manipulation Language)의 설명이다.', false),
(2704, 950, '데이터베이스의 구조를 정의하는 언어이다', 'DDL(Data Definition Language)은 데이터베이스의 구조를 정의하는 언어이다. 테이블, 인덱스, 스키마 등 데이터베이스 객체를 생성, 수정, 삭제하는 역할을 한다.', true),
(2705, 950, '트랜잭션을 제어하는 언어이다', '이것은 TCL(Transaction Control Language)의 설명이다.', false),
(2706, 950, '사용자 권한을 관리하는 언어이다', '이것은 DCL(Data Control Language)의 설명이다.', false),

-- 문제 952
(2707, 952, 'CREATE', 'CREATE는 객체를 생성하는 DDL 명령어이다.', false),
(2708, 952, 'ALTER', 'ALTER는 테이블 구조를 수정하는 DDL 명령어이다.', false),
(2709, 952, 'SELECT', 'SELECT는 데이터를 조회하는 DML 명령어이다. DDL이 아니다.', true),
(2710, 952, 'DROP', 'DROP은 객체를 삭제하는 DDL 명령어이다.', false),

-- 문제 953
(2711, 953, '테이블을 생성한다', 'CREATE TABLE이 테이블을 생성한다.', false),
(2712, 953, 'school이라는 이름의 데이터베이스를 생성한다', 'CREATE DATABASE는 새로운 데이터베이스를 생성하는 명령어이다. school이라는 이름의 데이터베이스가 생성된다.', true),
(2713, 953, '데이터베이스를 삭제한다', 'DROP DATABASE가 데이터베이스를 삭제한다.', false),
(2714, 953, '데이터베이스 구조를 수정한다', 'ALTER DATABASE가 데이터베이스 구조를 수정한다.', false),

-- 문제 955
(2715, 955, '테이블의 데이터만 삭제한다', '이것은 TRUNCATE의 설명이다. DROP은 테이블 자체를 삭제한다.', false),
(2716, 955, '테이블의 구조를 수정한다', '이것은 ALTER의 설명이다.', false),
(2717, 955, '데이터베이스 객체를 삭제한다', 'DROP은 데이터베이스, 테이블 등 객체 자체를 삭제하는 명령어이다. 구조와 데이터가 모두 삭제된다.', true),
(2718, 955, '데이터베이스 객체를 생성한다', '이것은 CREATE의 설명이다.', false),

-- 문제 956
(2719, 956, 'TRUNCATE는 테이블 구조를 유지하고 데이터만 삭제한다', 'TRUNCATE는 테이블의 모든 데이터를 삭제하지만 테이블 구조는 유지한다. DROP은 테이블 자체를 삭제하여 구조도 사라진다.', true),
(2720, 956, 'DROP은 테이블 데이터만 삭제한다', 'DROP은 테이블 자체를 삭제하여 구조와 데이터가 모두 사라진다.', false),
(2721, 956, 'TRUNCATE는 테이블 구조도 함께 삭제한다', 'TRUNCATE는 테이블 구조를 유지한다.', false),
(2722, 956, '두 명령어는 동일하게 동작한다', 'TRUNCATE는 데이터만, DROP은 구조와 데이터 모두를 삭제한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (273, 951, 'create', 'CREATE는 데이터베이스, 테이블, 인덱스 등 데이터베이스 객체를 생성하는 DDL 명령어이다. CREATE DATABASE, CREATE TABLE 등의 형태로 사용한다.'),
       (274, 954, 'alter', 'ALTER는 테이블의 구조를 수정하는 DDL 명령어이다. 컬럼 추가, 수정, 삭제 및 제약 조건 관리 등에 사용한다.');

-- Lesson 2: DDL 2 (ID: 138)
INSERT INTO lesson (id, title, unit_id)
VALUES (138, 'DDL 2', 47);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (957, 138, '다음 SQL 명령어의 역할은?', 'ALTER TABLE students ADD phone VARCHAR(20);', 'OBJECTIVE'),
       (958, 138, '빈칸에 들어갈 키워드를 작성하시오.', 'ALTER TABLE students ___ COLUMN phone; -- phone 컬럼 삭제', 'SUBJECTIVE'),
       (959, 138, '다음 중 ALTER TABLE 명령어로 수행할 수 없는 것은?', 'ALTER TABLE은 테이블 구조를 수정하는 명령어이다.', 'OBJECTIVE'),
       (960, 138, '다음 SQL 명령어의 역할은?', 'ALTER TABLE students MODIFY name VARCHAR(100);', 'OBJECTIVE'),
       (961, 138, '빈칸에 들어갈 키워드를 작성하시오.', 'ALTER TABLE students ___ COLUMN name TO full_name; -- 컬럼명 변경', 'SUBJECTIVE'),
       (962, 138, '다음 중 제약 조건을 추가하는 올바른 SQL은?', 'ALTER TABLE을 사용하여 제약 조건을 관리할 수 있다.', 'OBJECTIVE'),
       (963, 138, '다음 SQL 명령어의 역할은?', 'ALTER TABLE students DROP CONSTRAINT uk_email;', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 957
(2723, 957, 'students 테이블에 phone 컬럼을 추가한다', 'ALTER TABLE ... ADD는 테이블에 새로운 컬럼을 추가하는 명령이다. VARCHAR(20) 타입의 phone 컬럼이 추가된다.', true),
(2724, 957, 'students 테이블을 삭제한다', 'DROP TABLE이 테이블을 삭제한다.', false),
(2725, 957, 'students 테이블의 phone 컬럼을 삭제한다', 'ALTER TABLE ... DROP COLUMN이 컬럼을 삭제한다.', false),
(2726, 957, 'students 테이블의 phone 컬럼을 수정한다', 'ALTER TABLE ... MODIFY가 컬럼을 수정한다.', false),

-- 문제 959
(2727, 959, '컬럼 추가', 'ALTER TABLE ... ADD로 컬럼을 추가할 수 있다.', false),
(2728, 959, '컬럼 삭제', 'ALTER TABLE ... DROP COLUMN으로 컬럼을 삭제할 수 있다.', false),
(2729, 959, '제약 조건 추가', 'ALTER TABLE ... ADD CONSTRAINT로 제약 조건을 추가할 수 있다.', false),
(2730, 959, '데이터 삽입', '데이터 삽입은 DML의 INSERT 명령어를 사용한다. ALTER TABLE은 구조 수정용이다.', true),

-- 문제 960
(2731, 960, 'name 컬럼을 삭제한다', 'DROP COLUMN이 컬럼을 삭제한다.', false),
(2732, 960, 'name 컬럼의 데이터 타입을 VARCHAR(100)으로 변경한다', 'ALTER TABLE ... MODIFY는 기존 컬럼의 속성(데이터 타입, 크기 등)을 수정하는 명령이다.', true),
(2733, 960, 'name이라는 새 컬럼을 추가한다', 'ADD가 새 컬럼을 추가한다.', false),
(2734, 960, 'name 컬럼의 이름을 변경한다', 'RENAME COLUMN이 컬럼명을 변경한다.', false),

-- 문제 962
(2735, 962, 'ALTER TABLE students ADD uk_email UNIQUE (email)', '제약 조건 추가 시 ADD CONSTRAINT 키워드를 사용한다.', false),
(2736, 962, 'ALTER TABLE students ADD CONSTRAINT uk_email UNIQUE (email)', 'ADD CONSTRAINT를 사용하여 제약 조건 이름과 함께 제약 조건을 추가한다.', true),
(2737, 962, 'ALTER TABLE students CREATE CONSTRAINT uk_email UNIQUE (email)', 'CREATE CONSTRAINT는 올바른 문법이 아니다.', false),
(2738, 962, 'ALTER TABLE students INSERT CONSTRAINT uk_email UNIQUE (email)', 'INSERT CONSTRAINT는 올바른 문법이 아니다.', false),

-- 문제 963
(2739, 963, 'uk_email 제약 조건을 삭제한다', 'DROP CONSTRAINT는 지정된 이름의 제약 조건을 삭제하는 명령이다.', true),
(2740, 963, 'uk_email 제약 조건을 추가한다', 'ADD CONSTRAINT가 제약 조건을 추가한다.', false),
(2741, 963, 'email 컬럼을 삭제한다', 'DROP COLUMN이 컬럼을 삭제한다.', false),
(2742, 963, 'students 테이블을 삭제한다', 'DROP TABLE이 테이블을 삭제한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (275, 958, 'drop', 'ALTER TABLE ... DROP COLUMN은 테이블에서 기존 컬럼을 삭제하는 명령이다. 삭제된 컬럼의 데이터도 함께 사라진다.'),
       (276, 961, 'rename', 'ALTER TABLE ... RENAME COLUMN ... TO ...는 기존 컬럼의 이름을 변경하는 명령이다. 컬럼의 데이터와 속성은 유지된다.');

-- Lesson 3: DDL 3 (ID: 139)
INSERT INTO lesson (id, title, unit_id)
VALUES (139, 'DDL 3', 47);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (964, 139, '다음 SQL 명령어의 역할은?', 'DROP TABLE IF EXISTS students;', 'OBJECTIVE'),
       (965, 139, '빈칸에 들어갈 키워드를 작성하시오.', 'DROP TABLE ___ EXISTS students; -- 테이블이 존재할 때만 삭제', 'SUBJECTIVE'),
       (966, 139, '다음 중 TRUNCATE 명령어에 대한 설명으로 올바른 것은?', 'TRUNCATE는 DDL 명령어 중 하나이다.', 'OBJECTIVE'),
       (967, 139, '다음 SQL 명령어 실행 후 테이블 구조는 어떻게 되는가?', 'TRUNCATE TABLE students;', 'OBJECTIVE'),
       (968, 139, '빈칸에 들어갈 명령어를 작성하시오.', '테이블의 모든 데이터를 삭제하고 초기 상태로 되돌리는 DDL 명령어는 ___이다.', 'SUBJECTIVE'),
       (969, 139, '다음 중 DELETE와 TRUNCATE의 차이점으로 올바른 것은?', 'DELETE는 DML, TRUNCATE는 DDL이다.', 'OBJECTIVE'),
       (970, 139, '다음 상황에서 적절한 명령어는?', '테이블의 모든 데이터를 빠르게 삭제하되, 테이블 구조는 유지해야 한다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 964
(2743, 964, 'students 테이블을 무조건 삭제한다', 'IF EXISTS가 없으면 테이블이 없을 때 오류가 발생한다.', false),
(2744, 964, 'students 테이블이 존재하면 삭제한다', 'IF EXISTS는 테이블이 존재할 때만 삭제를 수행한다. 테이블이 없어도 오류가 발생하지 않는다.', true),
(2745, 964, 'students 테이블의 데이터만 삭제한다', 'DROP TABLE은 테이블 자체를 삭제한다.', false),
(2746, 964, 'students 테이블을 생성한다', 'CREATE TABLE이 테이블을 생성한다.', false),

-- 문제 966
(2747, 966, '특정 행만 삭제할 수 있다', 'TRUNCATE는 WHERE 절을 사용할 수 없어 특정 행만 삭제할 수 없다.', false),
(2748, 966, '테이블의 모든 데이터를 삭제하고 테이블 구조는 유지한다', 'TRUNCATE는 테이블의 모든 데이터를 삭제하고 초기 상태로 되돌리지만, 테이블 구조(스키마)는 그대로 유지된다.', true),
(2749, 966, '테이블 구조도 함께 삭제한다', 'DROP이 테이블 구조를 삭제한다.', false),
(2750, 966, 'ROLLBACK으로 복구할 수 있다', 'TRUNCATE는 DDL이므로 일반적으로 자동 커밋되어 ROLLBACK이 불가능하다.', false),

-- 문제 967
(2751, 967, '테이블 구조가 삭제된다', 'TRUNCATE는 데이터만 삭제하고 구조는 유지한다.', false),
(2752, 967, '테이블 구조는 그대로 유지된다', 'TRUNCATE는 테이블의 모든 데이터를 삭제하지만 테이블 구조(컬럼, 제약 조건 등)는 그대로 유지된다.', true),
(2753, 967, '테이블이 완전히 사라진다', 'DROP TABLE이 테이블을 완전히 삭제한다.', false),
(2754, 967, '아무 변화가 없다', 'TRUNCATE는 모든 데이터를 삭제한다.', false),

-- 문제 969
(2755, 969, 'DELETE는 ROLLBACK이 가능하고, TRUNCATE는 일반적으로 불가능하다', 'DELETE는 DML로 트랜잭션 내에서 ROLLBACK이 가능하다. TRUNCATE는 DDL로 자동 커밋되어 일반적으로 ROLLBACK이 불가능하다.', true),
(2756, 969, 'TRUNCATE는 WHERE 절을 사용할 수 있다', 'TRUNCATE는 WHERE 절을 사용할 수 없다. DELETE만 WHERE 절로 특정 행을 삭제할 수 있다.', false),
(2757, 969, 'DELETE가 TRUNCATE보다 빠르다', 'TRUNCATE가 DELETE보다 빠르다. TRUNCATE는 로그를 최소화하기 때문이다.', false),
(2758, 969, '두 명령어는 동일하게 동작한다', 'DELETE는 DML이고 TRUNCATE는 DDL로 동작 방식이 다르다.', false),

-- 문제 970
(2759, 970, 'DROP TABLE', 'DROP TABLE은 테이블 구조도 함께 삭제한다.', false),
(2760, 970, 'DELETE FROM', 'DELETE도 가능하지만 TRUNCATE가 더 빠르다.', false),
(2761, 970, 'TRUNCATE TABLE', 'TRUNCATE는 테이블의 모든 데이터를 빠르게 삭제하면서 구조는 유지한다. 대량 데이터 삭제 시 DELETE보다 효율적이다.', true),
(2762, 970, 'ALTER TABLE', 'ALTER TABLE은 테이블 구조를 수정하는 명령이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (277, 965, 'if', 'IF EXISTS는 테이블이 존재할 때만 삭제를 수행한다. 테이블이 없어도 오류가 발생하지 않아 스크립트 실행 시 안전하다.'),
       (278, 968, 'truncate', 'TRUNCATE는 테이블의 모든 데이터를 삭제하고 초기 상태로 되돌리는 DDL 명령어이다. DELETE보다 빠르지만 WHERE 절을 사용할 수 없고 ROLLBACK이 불가능하다.');
