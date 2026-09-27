-- Unit: DDL (Unit ID: 47)
-- Chapter: 데이터베이스 (Chapter ID: 4)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (137, 47, 'DDL 정의와 명령어 종류'),
       (138, 47, 'ALTER TABLE 컬럼·제약 변경'),
       (139, 47, 'TRUNCATE 동작과 DELETE 구분'),
       (266, 47, '객체 생성·제거와 실행 상태 추적'),
       (335, 47, 'IF EXISTS와 자동 증가 초기화'),
       (404, 47, 'DEFAULT 컬럼 추가와 컬럼 삭제'),
       (473, 47, 'CHECK 제약 추가와 DROP 비교');

-- =====================================================
-- Lesson 137: DDL 정의와 명령어 종류
-- =====================================================

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

-- =====================================================
-- Lesson 138: ALTER TABLE 컬럼·제약 변경
-- =====================================================

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

-- =====================================================
-- Lesson 139: TRUNCATE 동작과 DELETE 구분
-- =====================================================

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

-- =====================================================
-- Lesson 266: 객체 생성·제거와 실행 상태 추적
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1775, 266, '아래 DDL 명령어에 대한 설명으로 옳은 것은?', '이미 존재하는 테이블의 구조 자체를 바꾸는 명령어로, 컬럼을 새로 더하거나 컬럼의 자료형을 고치고, UNIQUE 같은 제약 조건을 붙이거나 떼는 데 쓴다. 테이블 안에 들어 있는 행(데이터)을 직접 손대는 명령어가 아니다.', 'OBJECTIVE'),
       (1776, 266, '아래 DDL 문들을 위에서부터 차례로 실행한 직후 students 테이블의 상태로 옳은 것은?', E'```sql\n-- students 테이블이 이미 존재하고, 행이 3건 들어 있는 상태에서 시작\nALTER TABLE students ADD phone VARCHAR(20);\nTRUNCATE TABLE students;\nALTER TABLE students DROP COLUMN phone;\n```', 'OBJECTIVE'),
       (1777, 266, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 명령어 | 분류 | 대상 | WHERE 조건 |
| --- | --- | --- | --- |
| DROP TABLE | DDL | 테이블 객체 자체를 제거 | 사용 불가 |
| TRUNCATE TABLE | DDL | 테이블의 모든 행을 한 번에 제거 | 사용 불가 |
| DELETE FROM | DML | 테이블의 행을 제거 | 사용 가능 |', 'OBJECTIVE'),
       (1778, 266, '아래 상황에서 사용한 DDL 명령어의 동작으로 옳은 것은?', '운영 중인 로그 테이블이 수백만 행으로 불어나 디스크를 압박하자, 담당자는 테이블의 컬럼 구조와 제약 조건은 그대로 남긴 채 안에 쌓인 데이터만 한 번에 비워 초기 상태로 되돌리는 명령어 한 줄을 실행했다. 실행 후에도 테이블 자체는 그대로 조회할 수 있었다.', 'OBJECTIVE'),
       (1779, 266, '아래 빈칸에 공통으로 들어갈 DDL 명령어 키워드는?', '```sql
______ TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

______ DATABASE school;
```', 'SUBJECTIVE'),
       (1780, 266, '아래 상황에 해당하는 DDL 명령어 키워드는?', '개발용으로 만들어 둔 테이블이 더는 필요 없어졌다. 담당자는 그 테이블에 정의된 컬럼·제약 조건은 물론 테이블이라는 객체 자체를 데이터베이스에서 통째로 없애려 한다. 이후에는 같은 이름으로 조회조차 되지 않아야 한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1775
(4907, 1775, '새 테이블을 처음 만들면서 컬럼과 자료형을 정의할 때 쓰는 명령어다.', '테이블을 새로 정의해 만드는 일은 CREATE의 몫이다. 이미 있는 테이블의 구조를 바꾸는 명령어와 혼동한 오개념이다.', false),
(4908, 1775, '테이블의 구조는 그대로 두고 안에 있는 모든 행을 한 번에 비우는 명령어다.', '구조는 두고 데이터만 한 번에 비우는 것은 TRUNCATE의 동작이다. 본문은 구조 자체를 바꾸는 명령어를 가리키므로 대상이 다르다.', false),
(4909, 1775, '이미 만들어진 테이블에 컬럼이나 제약 조건을 더하거나 없애 구조를 변경한다.', '본문의 설명대로 기존 테이블의 컬럼·제약 조건을 더하고 빼는 구조 변경은 ALTER의 핵심 역할이다.', true),
(4910, 1775, '특정 조건에 맞는 행만 골라 삭제하므로 WHERE 절을 함께 쓴다.', '조건에 맞는 행만 골라 지우는 것은 DML인 DELETE의 동작이다. 구조가 아니라 데이터를 다루므로 본문이 가리키는 명령어가 아니다.', false),

-- 문제 1776
(4911, 1776, 'phone 컬럼이 그대로 있고, 기존 행 3건도 그대로 남아 있다.', 'TRUNCATE가 행을 비우지 않는다고 본 오개념이다. TRUNCATE는 구조는 두되 모든 행을 제거하므로 3건은 남지 않는다.', false),
(4912, 1776, 'phone 컬럼이 없고, 행도 한 건도 없는 빈 테이블이 된다.', 'ADD로 phone이 생겼다가 마지막 DROP COLUMN으로 제거되어 컬럼이 사라지고, 중간의 TRUNCATE가 모든 행을 비우므로 행이 0건인 빈 테이블이 된다.', true),
(4913, 1776, 'phone 컬럼이 없는 대신, 처음의 행 3건은 그대로 남아 있다.', 'DROP COLUMN으로 컬럼은 옳게 제거했지만, 중간의 TRUNCATE가 행을 모두 비운다는 점을 빠뜨린 오개념이다.', false),
(4914, 1776, 'TRUNCATE가 테이블 객체를 지워 students 테이블 자체가 사라진다.', 'TRUNCATE를 DROP과 혼동한 오개념이다. TRUNCATE는 행만 비울 뿐 테이블 객체는 남으므로, 뒤이은 DROP COLUMN도 정상 실행된다.', false),

-- 문제 1777
(4915, 1777, 'DROP TABLE은 행만 지우는 것이 아니라 테이블 객체 자체를 제거하므로, 실행 후 같은 이름으로 조회할 수 없다.', '표에서 DROP TABLE의 대상이 테이블 객체 자체이므로 객체가 사라진다는 참인 진술이다. 행만 지우는 명령어와 구별된다.', false),
(4916, 1777, 'TRUNCATE TABLE은 WHERE 조건을 붙일 수 없어, 일부 행만 골라 남기는 식으로는 쓸 수 없다.', '표에서 TRUNCATE의 WHERE가 사용 불가이므로, 조건으로 일부만 지우는 용도로는 못 쓴다는 참인 진술이다.', false),
(4917, 1777, 'DELETE FROM은 DML이며 WHERE 조건으로 특정 행만 골라 지울 수 있다.', '표에서 DELETE는 DML이고 WHERE 사용이 가능하므로, 조건에 맞는 행만 지울 수 있다는 참인 진술이다.', false),
(4918, 1777, 'TRUNCATE TABLE은 DML이라 WHERE 조건을 붙여 원하는 행만 선택적으로 비울 수 있다.', '표에서 TRUNCATE는 DDL이고 WHERE가 사용 불가인데 이를 DML에 WHERE 가능으로 뒤집은 거짓 진술이다. 조건 없이 전체 행을 한 번에 비우는 것이 TRUNCATE다.', true),

-- 문제 1778
(4919, 1778, '테이블의 구조는 유지한 채 모든 행을 한 번에 제거해 비운 테이블만 남긴다.', '본문대로 컬럼·제약 조건은 두고 데이터만 통째로 비워 초기화하는 것은 TRUNCATE의 동작이다. 실행 후 테이블 객체는 그대로 남아 조회된다.', true),
(4920, 1778, '테이블 객체 자체를 제거해 이후 같은 이름으로는 조회할 수 없게 만든다.', '객체 자체를 없애는 것은 DROP이다. 본문은 실행 후에도 테이블을 조회할 수 있었다고 했으므로 객체가 남는 명령어를 가리킨다.', false),
(4921, 1778, 'WHERE 조건에 맞는 일부 행만 골라 지우고 나머지 행은 그대로 둔다.', '조건에 맞는 일부만 지우는 것은 DELETE의 동작이다. 본문은 안의 데이터를 한 번에 모두 비웠다고 했으므로 부분 삭제가 아니다.', false),
(4922, 1778, '테이블에 컬럼을 새로 더해 구조를 바꾸면서 동시에 데이터를 정리한다.', '컬럼을 더해 구조를 바꾸는 것은 ALTER다. 본문은 구조는 그대로 두고 데이터만 비웠다고 했으므로 구조를 바꾸는 명령어가 아니다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (548, 1779, 'CREATE,create,크리에이트,생성', '테이블과 데이터베이스를 새로 정의해 만드는 객체 생성 명령어는 CREATE다. 이미 있는 테이블의 구조를 바꾸는 ALTER나, 테이블의 데이터를 비우는 TRUNCATE와 헷갈리지 않도록 주의한다. CREATE는 없던 객체를 만드는 쪽이다.'),
       (549, 1780, 'DROP,drop,드롭', '컬럼·제약 조건을 포함해 테이블이라는 객체 자체를 통째로 없애 이후 조회조차 되지 않게 하는 명령어는 DROP이다. 구조는 남기고 행만 비우는 TRUNCATE나, 행을 조건부로 지우는 DELETE와 헷갈리지 않도록 주의한다. 객체 자체가 사라지는 쪽이 DROP이다.');

-- =====================================================
-- Lesson 335: IF EXISTS와 자동 증가 초기화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (2189, 335, '아래 CREATE TABLE 문을 실행해 만든 테이블에 대한 설명으로 옳은 것은?', '```sql
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    grade VARCHAR(10) NOT NULL,
    joined_at DATE DEFAULT CURRENT_DATE
);
```', 'OBJECTIVE'),
       (2190, 335, '아래 ALTER 문들을 students 테이블에 차례로 실행했을 때의 결과로 옳은 것은?', E'```sql\n-- 시작 시점: students 테이블에 name VARCHAR(50) 컬럼이 있음\nALTER TABLE students RENAME COLUMN name TO full_name;\nALTER TABLE students MODIFY full_name VARCHAR(100);\nALTER TABLE students ADD CONSTRAINT uk_email UNIQUE (email);\n```', 'OBJECTIVE'),
       (2191, 335, '아래 DDL 명령어에 대한 설명으로 옳은 것은?', '테이블 안의 모든 행을 한 번에 비워 초기 상태로 되돌리는 명령어다. 행을 한 건씩 지우며 조건을 평가하는 대신 데이터 저장 영역을 통째로 회수하는 방식으로 동작해, 같은 양의 데이터를 비울 때 보통 더 빠르다. 다만 어떤 행을 남기고 어떤 행을 지울지 고를 수는 없다.', 'OBJECTIVE'),
       (2192, 335, '아래 두 문장을 차례로 실행할 때의 동작으로 옳지 않은 것은?', E'```sql\n-- 데이터베이스에 logs 테이블은 존재하지 않는 상태\nDROP TABLE IF EXISTS logs;\nDROP TABLE logs;\n```', 'OBJECTIVE'),
       (2193, 335, '아래 상황에 해당하는 DDL 명령어 키워드는?', '서비스를 운영하던 중 회원 테이블에 휴대폰 번호를 담을 칸이 새로 필요해졌다. 담당자는 테이블을 다시 만들거나 데이터를 옮기지 않고, 이미 운영 중인 테이블에 phone 컬럼 하나를 덧붙여 구조만 바꾸려 한다. 기존 행의 값은 그대로 두고 새 컬럼만 추가되면 된다.', 'SUBJECTIVE'),
       (2194, 335, '아래 빈칸에 들어갈 DDL 명령어 키워드는?', E'```sql\n-- 테이블 구조와 제약 조건은 그대로 두고, 쌓인 수백만 행을 한 번에 비워\n-- 자동 증가 일련번호까지 처음 상태로 되돌리려 한다\n______ TABLE access_log;\n```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 2189
(6011, 2189, 'email에는 같은 값을 가진 행이 둘 이상 들어갈 수 없지만, 값을 비워 두는 것은 허용된다.', 'UNIQUE는 중복 값을 막을 뿐 NULL을 강제하지 않으므로, email은 값을 비워 둔 행은 여러 건 있을 수 있어도 같은 이메일을 가진 행은 둘 이상 들어가지 못한다.', true),
(6012, 2189, 'joined_at에 값을 넣지 않으면 그 행의 삽입이 거부되어 오류가 난다.', 'DEFAULT가 걸린 컬럼은 값을 생략하면 기본값(CURRENT_DATE)이 대신 채워진다. DEFAULT를 NOT NULL처럼 값 누락을 막는 제약으로 오해한 것이다.', false),
(6013, 2189, 'member_id는 같은 값이 중복될 수는 있으나 비워 둘 수는 없다.', 'PRIMARY KEY는 중복도 NULL도 모두 막는다. 중복은 막고 NULL은 허용하는 UNIQUE의 성질과 뒤섞어 PRIMARY KEY에 거꾸로 갖다 붙인 오개념이다.', false),
(6014, 2189, 'grade는 기본값이 지정되어 있어 값을 생략해도 빈 문자열이 자동으로 들어간다.', 'grade에는 NOT NULL만 있고 DEFAULT가 없어 값을 생략하면 채워질 기본값이 없으므로 삽입이 거부된다. DEFAULT가 없는 컬럼에 기본값이 있다고 오해한 것이다.', false),

-- 문제 2190
(6015, 2190, '컬럼 이름이 full_name으로 바뀌고 자료형이 VARCHAR(100)으로 늘며, email에 중복을 막는 제약이 더해진다.', 'RENAME COLUMN은 컬럼명을, MODIFY는 자료형을 바꾸고, ADD CONSTRAINT ... UNIQUE는 중복을 막는 제약을 더한다. 세 ALTER가 각자 구조의 다른 부분을 바꾼다.', true),
(6016, 2190, '세 문장 모두 테이블에 쌓여 있던 행의 데이터를 변경하거나 삭제한다.', 'ALTER는 테이블의 구조(컬럼명·자료형·제약)를 바꿀 뿐 행의 데이터 자체를 지우거나 고치지 않는다. ALTER를 DML처럼 데이터를 손대는 명령어로 오해한 것이다.', false),
(6017, 2190, 'RENAME COLUMN이 name 컬럼을 삭제한 뒤 full_name 컬럼을 새로 만들어, 기존 값이 모두 사라진다.', 'RENAME COLUMN은 컬럼을 지우고 새로 만드는 것이 아니라 같은 컬럼의 이름표만 바꾸므로 들어 있던 값은 그대로 유지된다. DROP 후 ADD로 동작한다고 오해한 것이다.', false),
(6018, 2190, 'MODIFY가 자료형을 VARCHAR(100)으로 바꾸면서 컬럼 이름도 함께 원래의 name으로 되돌린다.', 'MODIFY는 자료형만 바꿀 뿐 컬럼 이름은 건드리지 않는다. 앞선 RENAME으로 바뀐 full_name이 그대로 유지되며, MODIFY가 이름까지 되돌린다고 본 것은 잘못이다.', false),

-- 문제 2191
(6019, 2191, '구조와 제약 조건은 그대로 둔 채 모든 행을 한 번에 비워 빈 테이블만 남긴다.', '본문이 가리키는 것은 TRUNCATE다. 컬럼·제약 같은 구조는 유지하고 안의 행만 통째로 비우므로 실행 뒤에도 빈 테이블은 그대로 조회된다.', true),
(6020, 2191, 'WHERE 조건을 붙여 특정 행만 골라 지우고 나머지는 남길 수 있다.', '본문은 어떤 행을 남기고 지울지 고를 수 없다고 했다. 조건으로 일부 행만 지우는 것은 DML인 DELETE의 동작이며, 본문 명령어와 혼동한 것이다.', false),
(6021, 2191, '테이블이라는 객체 자체를 제거해 이후 같은 이름으로는 조회할 수 없게 만든다.', '객체 자체를 없애는 것은 DROP이다. 본문은 행만 비워 초기 상태로 되돌린다고 했으므로 테이블 객체는 그대로 남는다. DROP과 혼동한 오개념이다.', false),
(6022, 2191, '행을 한 건씩 검사하며 지우므로 같은 데이터를 비울 때 행 단위 삭제보다 느리다.', '본문은 행을 한 건씩 평가하는 대신 저장 영역을 통째로 회수해 보통 더 빠르다고 했다. 행 단위로 도는 DELETE의 동작 방식을 본문 명령어에 거꾸로 갖다 붙인 것이다.', false),

-- 문제 2192
(6023, 2192, '첫 줄의 DROP TABLE IF EXISTS는 logs가 없으므로 아무 일도 하지 않고 오류 없이 넘어간다.', 'IF EXISTS는 대상 테이블이 없을 때 오류를 내지 않고 조용히 통과시키는 안전장치다. 본문처럼 logs가 없으면 첫 줄은 아무것도 지우지 않고 그냥 넘어가므로 참인 진술이다.', false),
(6024, 2192, '두 번째 줄의 DROP TABLE logs는 IF EXISTS가 없어, 없는 테이블을 지우려다 오류가 난다.', 'IF EXISTS를 붙이지 않은 DROP은 대상이 실제로 있어야 한다. logs가 없는 상태에서 그냥 DROP하면 존재하지 않는 객체를 지우려는 것이라 오류가 나므로 참인 진술이다.', false),
(6025, 2192, 'IF EXISTS는 테이블이 있든 없든 결과를 똑같게 만들 뿐, 두 줄 모두 같은 방식으로 오류 없이 끝난다.', 'IF EXISTS가 있는 첫 줄은 없어도 통과하지만, 그것이 빠진 둘째 줄은 없는 테이블에서 오류를 낸다. 두 줄이 같은 방식으로 끝난다는 것은 IF EXISTS의 효과를 무시한 거짓 진술이다.', true),
(6026, 2192, 'IF EXISTS는 테이블이 존재할 때만 DROP을 실행하게 하는 조건이다.', 'IF EXISTS는 대상이 있으면 지우고, 없으면 오류 없이 건너뛰게 한다. 본문 첫 줄이 오류 없이 넘어가는 이유가 이것이므로 참인 진술이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (686, 2193, 'ALTER,alter,알터', '이미 존재하는 테이블에 컬럼을 덧붙여 구조만 바꾸는 명령어는 ALTER다. 테이블을 새로 정의하는 CREATE나 객체 자체를 없애는 DROP과 헷갈리지 않도록 주의한다. 기존 테이블을 그대로 두고 구조를 고치는 쪽이 ALTER다.'),
       (687, 2194, 'TRUNCATE,truncate,트렁케이트,트런케이트', '구조와 제약은 두고 모든 행을 한 번에 비워 자동 증가 일련번호까지 초기 상태로 되돌리는 명령어는 TRUNCATE다. 객체 자체를 없애는 DROP이나, 조건부로 행만 지우며 일련번호는 유지하는 DELETE와 헷갈리지 않도록 주의한다. 행을 통째로 비우고 초기화하는 쪽이 TRUNCATE다.');

-- =====================================================
-- Lesson 404: DEFAULT 컬럼 추가와 컬럼 삭제
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (2603, 404, '아래 CREATE TABLE 문으로 만든 테이블에 대한 설명으로 옳은 것은?', '```sql
CREATE TABLE enrollment (
    enroll_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
```', 'OBJECTIVE'),
       (2604, 404, '위 ALTER 문들을 차례로 실행한 직후, 기존 5건의 행에서 두 새 컬럼의 값으로 옳은 것은?', E'```sql\n-- products 테이블에 행이 5건 들어 있는 상태에서 시작\nALTER TABLE products ADD discount INT;\nALTER TABLE products ADD note VARCHAR(50) DEFAULT ''none'';\n```', 'OBJECTIVE'),
       (2605, 404, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | DELETE | TRUNCATE |
| --- | --- | --- |
| 분류 | DML | DDL |
| WHERE 조건 | 사용 가능 | 사용 불가 |
| 자동 증가 값 | 유지됨 | 초기화됨 |
| 처리 방식 | 행을 한 건씩 삭제 | 저장 영역을 통째로 회수 |', 'OBJECTIVE'),
       (2606, 404, '아래 상황에 맞는 DDL 동작으로 옳은 것은?', '한 담당자가 회원 테이블에서 더 이상 쓰지 않는 fax 컬럼 하나만 없애려고 한다. 테이블 자체와 다른 컬럼들, 그리고 그 안에 쌓인 행은 모두 그대로 유지되어야 하고, fax 칸과 거기 들어 있던 값만 사라지면 된다.', 'OBJECTIVE'),
       (2607, 404, '아래 설명에 해당하는, CREATE TABLE에서 지정하는 제약 조건의 이름은?', '회원 테이블을 만들면서 member_id 칸에 특정 제약 조건을 걸어 두었다. 이후 운영 중에 같은 member_id 값을 가진 행을 또 넣으려 하면 거부되었고, member_id를 비운 채 행을 넣으려 해도 거부되었다. 반면 같은 제약이 없는 다른 칸에서는 빈 값이나 중복 값이 별문제 없이 들어갔다.', 'SUBJECTIVE'),
       (2608, 404, '아래 설명에 해당하는, CREATE TABLE에서 컬럼에 지정하는 키워드는?', '주문 테이블을 만들 때 status 칸에 특정 설정을 해 두었다. 그 뒤로 주문을 넣을 때 status 값을 적지 않고 생략해도 오류가 나지 않았고, 그 행의 status에는 자동으로 ''pending''이라는 값이 대신 채워졌다. 값을 직접 적어 넣은 행에는 적은 값이 그대로 들어갔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 2603
(7115, 2603, 'enroll_id는 같은 값이 중복될 수는 있어도 비워 두는 것은 허용되지 않는다.', 'PRIMARY KEY는 중복과 NULL을 모두 막는다. 중복은 허용하고 빈 값만 막는다고 본 것은 UNIQUE의 성질 일부를 PRIMARY KEY에 잘못 갖다 붙인 오개념이다.', false),
(7116, 2603, 'student_id에는 students 테이블의 student_id에 실제로 존재하는 값만 넣을 수 있다.', 'FOREIGN KEY는 참조하는 부모 테이블에 있는 값만 자식 컬럼에 허용한다. 없는 student_id를 넣으려 하면 참조 무결성 위반으로 거부된다.', true),
(7117, 2603, 'course_id는 NOT NULL이 없어도 기본적으로 빈 값을 막으므로 모든 행이 과목을 가져야 한다.', '제약을 적지 않은 컬럼은 NULL이 기본으로 허용된다. 모든 컬럼이 기본으로 NOT NULL이라고 본 오개념으로, course_id는 값을 비워 둘 수 있다.', false),
(7118, 2603, 'FOREIGN KEY가 걸려 있어도 부모인 students 테이블을 DROP하면 enrollment만 남고 참조는 무시된다.', '참조받는 부모 테이블에 자식이 걸려 있으면 부모를 그냥 DROP할 수 없다. 참조 의존성이 있는데도 부모를 자유롭게 지울 수 있다고 본 오개념이다.', false),

-- 문제 2604
(7119, 2604, 'discount는 NULL이고, note는 ''none''으로 채워진다.', 'DEFAULT가 없는 ADD COLUMN은 기존 행을 NULL로 채우고, DEFAULT가 지정된 ADD COLUMN은 기존 행까지 그 기본값으로 채운다. 그래서 discount는 NULL, note는 ''none''이 된다.', true),
(7120, 2604, '두 컬럼 모두 NULL로 채워진다.', 'note에 DEFAULT ''none''이 지정되어 기존 행에도 기본값이 적용된다는 점을 놓친 것이다. DEFAULT는 새로 추가하는 컬럼의 기존 행까지 그 값으로 채운다.', false),
(7121, 2604, '두 컬럼 모두 자료형에 따라 0과 빈 문자열로 자동 초기화된다.', '컬럼을 추가한다고 자료형별 0이나 빈 문자열이 자동으로 들어가지는 않는다. 기본값을 지정하지 않으면 NULL이 들어간다는 점을 자료형 기본값과 혼동한 오개념이다.', false),
(7122, 2604, 'ADD는 새로 들어올 행에만 적용되므로 기존 5건에는 두 컬럼이 아예 존재하지 않는다.', 'ALTER ADD는 컬럼을 테이블 구조에 추가하므로 기존 행에도 그 컬럼이 생긴다. 새 컬럼이 이후 행에만 붙는다고 본 오개념이다.', false),

-- 문제 2605
(7123, 2605, 'DELETE는 행을 한 건씩 지우므로 WHERE로 조건에 맞는 일부 행만 골라 삭제할 수 있다.', '표에서 DELETE는 WHERE 사용이 가능하고 행을 한 건씩 처리하므로, 조건에 맞는 일부만 지울 수 있다는 참인 진술이다.', false),
(7124, 2605, 'TRUNCATE로 테이블을 비우면 자동 증가 컬럼의 다음 값이 처음 상태로 되돌아간다.', '표에서 TRUNCATE의 자동 증가 값이 초기화됨으로 되어 있으므로, 비운 뒤 일련번호가 처음부터 다시 시작한다는 참인 진술이다.', false),
(7125, 2605, 'TRUNCATE는 WHERE 조건으로 특정 행만 남길 수 있어 일부만 골라 삭제할 때 유리하다.', '표에서 TRUNCATE는 WHERE 사용이 불가다. 조건으로 일부만 남긴다는 것은 표와 어긋난 거짓 진술이며, 조건 없이 전체 행을 한 번에 비우는 것이 TRUNCATE다.', true),
(7126, 2605, '같은 양의 데이터를 모두 지울 때, 저장 영역을 통째로 회수하는 TRUNCATE가 한 건씩 도는 DELETE보다 보통 빠르다.', '표의 처리 방식대로 TRUNCATE는 저장 영역을 통째로 회수하고 DELETE는 행을 한 건씩 지우므로, 전체를 비울 때 TRUNCATE가 보통 더 빠르다는 참인 진술이다.', false),

-- 문제 2606
(7127, 2606, 'DROP TABLE로 회원 테이블 객체를 통째로 지운 뒤 같은 구조로 테이블을 다시 만들어야 한다.', '한 컬럼만 없애는 데 객체 전체를 지우고 다시 만드는 것은 과한 처리다. 컬럼 제거를 객체 삭제로 확대 해석한 오개념으로, 다른 컬럼과 행까지 사라진다.', false),
(7128, 2606, 'DELETE FROM에 WHERE를 걸어 fax 값이 들어 있는 행만 골라 지우면 된다.', 'DELETE는 컬럼이 아니라 행을 지운다. 칸(컬럼) 제거와 행 삭제를 혼동한 오개념으로, 컬럼 구조는 그대로 남고 행만 사라진다.', false),
(7129, 2606, 'TRUNCATE TABLE로 테이블을 비우면 fax 컬럼만 사라지고 다른 데이터는 그대로 남는다.', 'TRUNCATE는 컬럼을 떼는 것이 아니라 모든 행을 비운다. 컬럼 제거와 데이터 비우기를 뒤섞은 오개념으로, 구조는 그대로고 다른 컬럼의 값까지 모두 사라진다.', false),
(7130, 2606, 'ALTER TABLE로 해당 컬럼만 떼어 내면 되며, 테이블을 새로 만들거나 객체를 통째로 지울 필요가 없다.', '특정 컬럼 하나와 그 값만 없애는 구조 변경은 ALTER TABLE의 DROP COLUMN이 맡는다. 객체와 다른 컬럼·행은 그대로 두고 지정한 컬럼만 제거하므로 상황에 맞는다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (824, 2607, 'PRIMARY KEY,primary key,프라이머리 키,기본 키,기본키,PK,pk', '같은 값의 중복도 막고 빈 값(NULL)도 막아 각 행을 하나로 식별하게 하는 제약은 PRIMARY KEY다. 중복은 막되 빈 값은 허용하는 UNIQUE와 헷갈리지 않도록 주의한다. 본문에서 빈 값까지 거부되었다는 점이 UNIQUE가 아니라 PRIMARY KEY임을 가른다.'),
       (825, 2608, 'DEFAULT,default,디폴트,기본값', '값을 생략하면 미리 정해 둔 값을 대신 채워 넣게 하는 키워드는 DEFAULT다. 값 생략 자체를 막아 오류를 내는 NOT NULL과 헷갈리지 않도록 주의한다. 본문처럼 값을 적지 않아도 오류 없이 정해진 값이 채워졌다는 점이 DEFAULT임을 가른다.');

-- =====================================================
-- Lesson 473: CHECK 제약 추가와 DROP 비교
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3017, 473, '아래 CREATE TABLE 문으로 만든 테이블에 대한 설명으로 옳은 것은?', '```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    amount INT NOT NULL CHECK (amount > 0),
    status VARCHAR(10) DEFAULT ''new''
);
```', 'OBJECTIVE'),
       (3018, 473, '아래 ALTER 문을 실행했을 때의 결과로 옳은 것은?', E'```sql\n-- products 테이블에 price 값이 각각 100, -50, 0인 행 3건이 이미 들어 있다\nALTER TABLE products ADD CONSTRAINT chk_price CHECK (price > 0);\n```', 'OBJECTIVE'),
       (3019, 473, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | DELETE | TRUNCATE | DROP TABLE |
| --- | --- | --- | --- |
| 분류 | DML | DDL | DDL |
| 실행 후 남는 것 | 빈 테이블 | 빈 테이블 | 아무것도 남지 않음 |
| WHERE 조건 | 사용 가능 | 사용 불가 | 사용 불가 |
| 행을 한 건씩 평가 | 그렇다 | 아니다 | 아니다 |', 'OBJECTIVE'),
       (3020, 473, '아래에서 설명하는 제약 조건과 관련된 동작으로 옳은 것은?', '자식 테이블의 한 컬럼이 부모 테이블의 기본 키 값을 참조하도록 걸어 둔 제약 조건이다. 지금 자식 테이블의 어떤 행이 부모 테이블의 특정 행을 실제로 참조하고 있는 상태라고 하자.', 'OBJECTIVE'),
       (3021, 473, '아래 상황에 해당하는, CREATE TABLE에서 컬럼에 거는 제약 조건의 이름은?', '회원 가입에서 나이 칸에 -5나 200처럼 말이 안 되는 값을 보내자, 애플리케이션 코드의 별도 검사를 거치지 않았는데도 데이터베이스가 그 행의 삽입을 직접 거부했다. 1부터 150 사이의 값을 보낸 행만 정상적으로 저장되었고, 같은 설정이 없는 다른 칸에는 어떤 정수든 그대로 들어갔다.', 'SUBJECTIVE'),
       (3022, 473, '아래 상황에 해당하는, 컬럼에 거는 제약 조건의 이름은?', '회원 테이블의 이메일 칸에 어떤 설정을 걸어 두었더니, 이미 등록된 것과 똑같은 이메일로 가입하려는 행은 거부되었다. 다만 이메일을 비운 채로 가입하는 행은 여러 건이 별문제 없이 등록되었다. 즉 같은 값이 또 들어오는 것은 막혔지만, 값을 비워 두는 것은 막히지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3017
(8219, 3017, 'status 값을 적지 않고 행을 넣으면 기본값이 없어 삽입이 거부된다.', 'status에는 DEFAULT ''new''가 걸려 있어 값을 생략하면 ''new''가 대신 채워지므로 삽입이 거부되지 않는다. DEFAULT를 NOT NULL처럼 값 누락을 막는 제약으로 오해한 것이다.', false),
(8220, 3017, 'amount 값을 적지 않고 행을 넣으면, 채워질 기본값이 없어 삽입이 거부된다.', 'amount에는 NOT NULL만 있고 DEFAULT가 없으므로 값을 생략하면 대신 채울 값이 없어 삽입이 거부된다. NOT NULL과 DEFAULT가 별개라는 점이 핵심이다.', true),
(8221, 3017, 'order_id에 같은 값을 두 번 넣어도 되지만, 비워 두는 것은 허용되지 않는다.', 'PRIMARY KEY는 중복과 NULL을 모두 막는다. 중복은 허용하고 빈 값만 막는다고 본 것은 UNIQUE의 성질 일부를 PRIMARY KEY에 잘못 갖다 붙인 오개념이다.', false),
(8222, 3017, 'amount에 0을 넣은 행은 CHECK를 통과하므로 정상적으로 저장된다.', 'CHECK (amount > 0)은 0보다 큰 값만 허용하므로 0은 조건을 만족하지 못해 거부된다. 0이 양수 조건을 통과한다고 본 오개념이다.', false),

-- 문제 3018
(8223, 3018, '기존 3건은 그대로 두고, 이후 새로 들어오는 행에만 price > 0 조건이 적용된다.', 'ALTER ADD CONSTRAINT는 기존 행까지 검사 대상으로 삼는다. 새 행에만 적용된다고 본 것은 잘못으로, 본문은 기존 행에 위반 값이 있어 제약 추가 자체가 막힌다.', false),
(8224, 3018, '조건을 어기는 -50, 0 행이 자동으로 삭제되고 100인 행만 남은 뒤 제약이 걸린다.', 'ADD CONSTRAINT는 위반 행을 알아서 지우지 않는다. 위반 데이터를 자동 정리한다고 본 오개념으로, 실제로는 위반 행 때문에 제약 추가가 거부된다.', false),
(8225, 3018, '기존 행 중 조건을 어기는 값이 있어 제약 추가가 거부되고, 제약은 적용되지 않는다.', 'ALTER ADD CONSTRAINT는 추가 시점에 기존 데이터를 모두 검사한다. -50, 0이 price > 0을 어기므로 제약을 걸 수 없어 명령이 거부되고 데이터는 그대로 남는다.', true),
(8226, 3018, '제약은 정상적으로 추가되며, 위반하던 -50, 0 값이 1로 자동 보정된다.', 'ADD CONSTRAINT는 위반 값을 임의로 고치지 않는다. 위반 데이터가 조건에 맞게 자동 수정된다고 본 오개념으로, 실제로는 제약 추가가 거부된다.', false),

-- 문제 3019
(8227, 3019, 'DROP TABLE을 실행한 뒤에도 빈 테이블 껍데기는 남아 같은 이름으로 조회할 수 있다.', '표에서 DROP TABLE은 실행 후 아무것도 남지 않는다고 했다. 빈 테이블이 남는 것은 DELETE·TRUNCATE이며, DROP을 이들과 혼동해 객체가 남는다고 본 거짓 진술이다.', true),
(8228, 3019, 'DELETE는 WHERE 조건으로 일부 행만 골라 지울 수 있지만 TRUNCATE는 그럴 수 없다.', '표에서 DELETE는 WHERE 사용 가능, TRUNCATE는 사용 불가이므로, 조건으로 일부만 지우는 것은 DELETE만 된다는 참인 진술이다.', false),
(8229, 3019, 'DELETE는 행을 한 건씩 평가하며 지우지만 TRUNCATE는 그런 평가 없이 한 번에 비운다.', '표에서 행을 한 건씩 평가하는 것은 DELETE만 그렇다고 되어 있으므로, TRUNCATE는 건별 평가 없이 전체를 비운다는 참인 진술이다.', false),
(8230, 3019, 'DELETE와 TRUNCATE는 실행 후 빈 테이블이 남지만 DROP TABLE은 테이블 객체까지 사라진다.', '표의 실행 후 남는 것 행대로 DELETE·TRUNCATE는 빈 테이블을 남기고 DROP은 아무것도 남기지 않으므로, 객체 자체가 사라진다는 참인 진술이다.', false),

-- 문제 3020
(8231, 3020, '참조받는 부모 테이블의 행은 자식이 그 값을 참조하든 말든 언제나 자유롭게 DELETE할 수 있다.', '자식이 참조 중인 부모 행은 그냥 지울 수 없다. 참조 의존성을 무시하고 부모를 자유롭게 지울 수 있다고 본 오개념으로, 참조 무결성 위반이 된다.', false),
(8232, 3020, '자식 컬럼에는 부모 테이블에 실제로 존재하지 않는 값도 제약과 무관하게 넣을 수 있다.', '이 제약은 부모에 있는 값만 자식에 허용한다. 없는 값을 넣으려 하면 참조 무결성 위반으로 거부되므로, 아무 값이나 넣을 수 있다는 것은 잘못이다.', false),
(8233, 3020, '자식이 참조 중인 부모 행을 그냥 DELETE하면, 그 값을 참조하는 자식 때문에 삭제가 거부된다.', '참조받는 부모 행이 자식에 의해 쓰이고 있으면 부모를 함부로 지울 수 없다. 부모를 지우려면 먼저 자식 쪽 참조를 정리해야 하며, 그러지 않으면 참조 무결성 위반으로 막힌다.', true),
(8234, 3020, '이 제약은 자식 컬럼의 값이 비어 있는 것을 무조건 막아 모든 자식 행이 부모를 가리키게 한다.', '참조 제약 자체가 NULL을 강제하지는 않는다. 빈 값 금지는 NOT NULL의 몫이며, 둘을 뒤섞어 참조 제약이 값 비움을 막는다고 본 오개념이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (962, 3021, 'CHECK,check,체크,체크 제약,체크 제약 조건', '컬럼 값이 정해진 조건(예: 1과 150 사이)을 만족하는지 데이터베이스가 직접 검사해 어기는 행의 삽입을 거부하는 제약은 CHECK다. 빈 값만 막는 NOT NULL이나 중복만 막는 UNIQUE와 달리, 값의 범위·조건 자체를 따진다는 점이 CHECK를 가른다.'),
       (963, 3022, 'UNIQUE,unique,유니크,유니크 제약,고유 제약,고유 키', '같은 값이 두 번 들어오는 것은 막되 빈 값(NULL)은 여러 건 허용하는 제약은 UNIQUE다. 중복도 빈 값도 모두 막는 PRIMARY KEY와 헷갈리지 않도록 주의한다. 본문에서 빈 값은 여러 건 허용되었다는 점이 PRIMARY KEY가 아니라 UNIQUE임을 가른다.');
