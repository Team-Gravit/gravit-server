-- Chapter: 데이터베이스 (id: 4), Unit: 뷰 (id: 52)
-- Lesson 1: 뷰 기초 (ID: 152)
INSERT INTO lesson (id, title, unit_id)
VALUES (152, '뷰 기초', 52);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1055, 152, '다음 중 뷰(View)에 대한 설명으로 올바른 것은?', '뷰는 하나 이상의 테이블로부터 유도된 가상 테이블이다.', 'OBJECTIVE'),
       (1056, 152, '빈칸에 들어갈 키워드를 작성하시오.', '___ VIEW student_view AS SELECT id, name FROM students; -- 뷰 생성', 'SUBJECTIVE'),
       (1057, 152, '다음 중 뷰의 특징으로 올바르지 않은 것은?', '뷰는 실제 데이터를 저장하지 않는 가상 테이블이다.', 'OBJECTIVE'),
       (1058, 152, '다음 SQL 명령어의 역할은?', 'CREATE VIEW dept_student AS SELECT s.name, d.name AS dept_name FROM students s JOIN departments d ON s.department_id = d.id;', 'OBJECTIVE'),
       (1059, 152, '빈칸에 들어갈 용어를 작성하시오.', '뷰는 실제 데이터를 저장하지 않고 SELECT 문의 결과를 보여주는 ___이다.', 'SUBJECTIVE'),
       (1060, 152, '다음 중 뷰를 사용하는 이유로 올바른 것은?', '뷰는 데이터베이스 설계와 보안에 유용하게 활용된다.', 'OBJECTIVE'),
       (1061, 152, '다음 SQL 명령어의 역할은?', 'SELECT * FROM student_view;', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1055
(3003, 1055, '뷰는 실제 데이터를 물리적으로 저장한다', '뷰는 데이터를 저장하지 않고 쿼리 결과만 보여준다.', false),
(3004, 1055, '뷰는 SELECT 문의 결과를 가상 테이블로 제공한다', '뷰는 저장된 SELECT 문을 실행하여 결과를 가상 테이블 형태로 제공한다. 실제 데이터는 기본 테이블에 저장되어 있다.', true),
(3005, 1055, '뷰는 테이블과 동일하게 데이터를 저장한다', '뷰는 가상 테이블로 데이터를 저장하지 않는다.', false),
(3006, 1055, '뷰는 인덱스를 가질 수 있다', '일반 뷰는 인덱스를 가질 수 없다. 실체화된 뷰는 가능하다.', false),

-- 문제 1057
(3007, 1057, '뷰는 보안을 강화할 수 있다', '뷰를 통해 특정 컬럼만 노출하여 보안을 강화할 수 있다.', false),
(3008, 1057, '뷰는 복잡한 쿼리를 단순화한다', '복잡한 조인이나 집계를 뷰로 만들어 간단하게 사용할 수 있다.', false),
(3009, 1057, '뷰는 데이터를 물리적으로 저장한다', '뷰는 가상 테이블로 데이터를 저장하지 않는다. 뷰를 조회할 때마다 기본 테이블에서 데이터를 가져온다.', true),
(3010, 1057, '뷰는 재사용이 가능하다', '한 번 생성한 뷰는 여러 곳에서 재사용할 수 있다.', false),

-- 문제 1058
(3011, 1058, '학생과 학과 정보를 조인한 뷰를 생성한다', 'CREATE VIEW로 학생 이름과 학과 이름을 조인한 결과를 dept_student라는 뷰로 생성한다.', true),
(3012, 1058, '학생 테이블을 삭제한다', 'CREATE VIEW는 뷰를 생성한다.', false),
(3013, 1058, '학과 테이블을 생성한다', 'CREATE TABLE이 테이블을 생성한다.', false),
(3014, 1058, '데이터를 조회한다', 'CREATE VIEW는 뷰를 생성하는 것이지 조회하는 것이 아니다.', false),

-- 문제 1060
(3015, 1060, '데이터를 물리적으로 저장하기 위해', '뷰는 데이터를 저장하지 않는다.', false),
(3016, 1060, '복잡한 쿼리를 단순화하고 재사용하기 위해', '복잡한 조인, 집계, 서브쿼리 등을 뷰로 만들어 간단한 SELECT 문으로 사용할 수 있다. 코드 재사용성이 향상된다.', true),
(3017, 1060, '테이블을 삭제하기 위해', 'DROP TABLE이 테이블을 삭제한다.', false),
(3018, 1060, '인덱스를 생성하기 위해', 'CREATE INDEX가 인덱스를 생성한다.', false),

-- 문제 1061
(3019, 1061, 'student_view 뷰의 데이터를 조회한다', 'SELECT 문으로 뷰를 조회한다. 뷰는 테이블처럼 사용할 수 있다.', true),
(3020, 1061, 'student_view 뷰를 생성한다', 'CREATE VIEW가 뷰를 생성한다.', false),
(3021, 1061, 'student_view 뷰를 삭제한다', 'DROP VIEW가 뷰를 삭제한다.', false),
(3022, 1061, 'student_view 테이블을 수정한다', 'ALTER TABLE이 테이블을 수정한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (303, 1056, 'create', 'CREATE VIEW 문으로 뷰를 생성한다. CREATE VIEW 뷰이름 AS SELECT 문 형식으로 작성한다.'),
       (304, 1059, '가상 테이블,virtual table,논리 테이블', '뷰는 실제 데이터를 저장하지 않고 SELECT 문의 실행 결과를 보여주는 가상 테이블이다. 뷰를 조회하면 정의된 SELECT 문이 실행된다.');


-- Lesson 2: 뷰 활용 (ID: 153)
INSERT INTO lesson (id, title, unit_id)
VALUES (153, '뷰 활용', 52);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1062, 153, '다음 SQL 명령어의 역할은?', 'CREATE VIEW high_grade_students AS SELECT * FROM students WHERE grade >= 3;', 'OBJECTIVE'),
       (1063, 153, '빈칸에 들어갈 키워드를 작성하시오.', '___ VIEW student_view; -- 뷰 삭제', 'SUBJECTIVE'),
       (1064, 153, '다음 중 뷰를 통한 보안 강화 방법으로 올바른 것은?', '뷰는 데이터 접근을 제어하여 보안을 강화할 수 있다.', 'OBJECTIVE'),
       (1065, 153, '다음 SQL 명령어의 역할은?', 'CREATE VIEW student_summary AS SELECT department_id, COUNT(*) AS student_count FROM students GROUP BY department_id;', 'OBJECTIVE'),
       (1066, 153, '빈칸에 들어갈 구문을 작성하시오.', 'CREATE ___ VIEW student_view AS SELECT id, name FROM students; -- 기존 뷰 대체', 'SUBJECTIVE'),
       (1067, 153, '다음 중 뷰의 장점으로 올바르지 않은 것은?', '뷰는 다양한 장점을 제공하지만 한계도 있다.', 'OBJECTIVE'),
       (1068, 153, '다음 SQL 명령어의 역할은?', 'CREATE VIEW public_student AS SELECT id, name, email FROM students;', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1062
(3023, 1062, '모든 학생을 조회하는 뷰를 생성한다', 'WHERE 조건으로 필터링한다.', false),
(3024, 1062, '학생 테이블을 삭제한다', 'CREATE VIEW는 뷰를 생성한다.', false),
(3025, 1062, '학생 데이터를 수정한다', 'UPDATE가 데이터를 수정한다.', false),
(3026, 1062, '3학년 이상 학생만 조회하는 뷰를 생성한다', 'WHERE grade >= 3 조건으로 3학년 이상 학생만 포함하는 뷰를 생성한다. 뷰를 조회하면 항상 이 조건을 만족하는 데이터만 반환된다.', true),

-- 문제 1064
(3027, 1064, '모든 컬럼을 노출하여 투명성을 높인다', '보안을 위해서는 필요한 컬럼만 노출해야 한다.', false),
(3028, 1064, '민감한 컬럼을 제외하고 필요한 컬럼만 뷰로 제공한다', '뷰를 통해 급여, 주민번호 등 민감한 정보를 숨기고 필요한 정보만 노출할 수 있다. 사용자는 뷰만 접근하도록 권한을 부여한다.', true),
(3029, 1064, '모든 사용자에게 테이블 직접 접근 권한을 부여한다', '뷰를 사용하는 이유는 직접 접근을 제한하기 위함이다.', false),
(3030, 1064, '뷰를 사용하면 보안이 저하된다', '뷰는 보안을 강화하는 도구이다.', false),

-- 문제 1065
(3031, 1065, '학과별 학생 수를 집계하는 뷰를 생성한다', 'GROUP BY로 학과별로 그룹화하고 COUNT로 학생 수를 계산하는 뷰를 생성한다. 복잡한 집계 쿼리를 단순화한다.', true),
(3032, 1065, '학생 수를 삭제한다', 'CREATE VIEW는 뷰를 생성한다.', false),
(3033, 1065, '모든 학생을 조회한다', 'GROUP BY로 집계한 결과를 조회한다.', false),
(3034, 1065, 'department_id를 수정한다', 'SELECT 문으로 데이터를 조회한다.', false),

-- 문제 1067
(3035, 1067, '복잡한 쿼리를 단순화할 수 있다', '뷰는 복잡한 조인이나 집계를 숨기고 간단하게 사용할 수 있다.', false),
(3036, 1067, '데이터 보안을 강화할 수 있다', '뷰를 통해 특정 컬럼만 노출하여 보안을 강화할 수 있다.', false),
(3037, 1067, '쿼리 성능이 항상 향상된다', '뷰는 쿼리를 단순화할 뿐 성능을 자동으로 향상시키지 않는다. 오히려 복잡한 뷰는 성능을 저하시킬 수 있다.', true),
(3038, 1067, '논리적 데이터 독립성을 제공한다', '뷰를 사용하면 테이블 구조가 변경되어도 뷰만 수정하면 된다.', false),

-- 문제 1068
(3039, 1068, '학생의 모든 정보를 조회하는 뷰를 생성한다', 'SELECT *가 아닌 특정 컬럼만 선택한다.', false),
(3040, 1068, '학생 테이블을 삭제한다', 'CREATE VIEW는 뷰를 생성한다.', false),
(3041, 1068, '이메일 정보를 수정한다', 'SELECT 문으로 데이터를 조회한다.', false),
(3042, 1068, '민감한 정보를 제외한 공개 정보만 포함하는 뷰를 생성한다', 'id, name, email만 선택하여 주민번호, 급여 등 민감한 정보는 제외한다. 보안을 위한 뷰 활용 사례이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (305, 1063, 'drop', 'DROP VIEW 문으로 뷰를 삭제한다. DROP VIEW 뷰이름 형식으로 작성한다.'),
       (306, 1066, 'or replace', 'CREATE OR REPLACE VIEW는 뷰가 이미 존재하면 대체하고, 없으면 새로 생성한다. 뷰를 수정할 때 사용한다.');


-- Lesson 3: 뷰 제약사항 (ID: 154)
INSERT INTO lesson (id, title, unit_id)
VALUES (154, '뷰 제약사항', 52);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1069, 154, '다음 중 뷰를 통한 데이터 수정이 불가능한 경우는?', '모든 뷰에서 데이터를 수정할 수 있는 것은 아니다.', 'OBJECTIVE'),
       (1070, 154, '빈칸에 들어갈 용어를 작성하시오.', '데이터 수정이 가능한 뷰를 ___라고 한다.', 'SUBJECTIVE'),
       (1071, 154, '다음 중 갱신 가능한 뷰의 조건으로 올바른 것은?', '특정 조건을 만족하는 뷰만 데이터를 수정할 수 있다.', 'OBJECTIVE'),
       (1072, 154, '다음 SQL 명령어가 실패하는 이유는?', 'CREATE VIEW avg_grade AS SELECT department_id, AVG(grade) AS avg FROM students GROUP BY department_id;\nUPDATE avg_grade SET avg = 4.0 WHERE department_id = 1;', 'OBJECTIVE'),
       (1073, 154, '빈칸에 들어갈 키워드를 작성하시오.', 'CREATE VIEW student_view AS SELECT * FROM students ___ CHECK OPTION; -- 뷰 조건 강제', 'SUBJECTIVE'),
       (1074, 154, '다음 중 WITH CHECK OPTION의 역할로 올바른 것은?', 'WITH CHECK OPTION은 뷰를 통한 데이터 수정을 제한한다.', 'OBJECTIVE'),
       (1075, 154, '다음 중 뷰의 성능 문제로 올바른 것은?', '뷰 사용 시 성능을 고려해야 한다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1069
(3043, 1069, '단일 테이블을 기반으로 한 뷰', '조건을 만족하면 단일 테이블 뷰도 수정 가능하다.', false),
(3044, 1069, 'GROUP BY를 사용한 집계 뷰', 'GROUP BY, DISTINCT, 집계 함수를 사용한 뷰는 데이터를 수정할 수 없다. 집계된 결과는 원본 데이터와 일대일 대응이 아니기 때문이다.', true),
(3045, 1069, 'WHERE 조건이 있는 뷰', 'WHERE 조건만 있으면 수정 가능할 수 있다.', false),
(3046, 1069, '모든 컬럼을 포함한 뷰', '다른 조건을 만족하면 수정 가능하다.', false),

-- 문제 1071
(3047, 1071, 'GROUP BY를 사용해야 한다', 'GROUP BY를 사용하면 갱신이 불가능하다.', false),
(3048, 1071, '여러 테이블을 조인해야 한다', '조인을 사용하면 일반적으로 갱신이 어렵다.', false),
(3049, 1071, '단일 테이블 기반이고 집계 함수가 없어야 한다', '갱신 가능한 뷰는 단일 테이블 기반이고, GROUP BY, DISTINCT, 집계 함수, UNION 등을 사용하지 않아야 한다.', true),
(3050, 1071, 'DISTINCT를 사용해야 한다', 'DISTINCT를 사용하면 갱신이 불가능하다.', false),

-- 문제 1072
(3051, 1072, '권한이 없어서 실패한다', '권한과는 무관하다.', false),
(3052, 1072, '집계 함수를 사용한 뷰는 수정할 수 없어서 실패한다', 'AVG 같은 집계 함수로 생성된 뷰는 원본 데이터와 일대일 대응이 아니므로 UPDATE, INSERT, DELETE가 불가능하다.', true),
(3053, 1072, '뷰 이름이 잘못되어서 실패한다', '뷰 이름은 올바르다.', false),
(3054, 1072, 'WHERE 절이 없어서 실패한다', 'WHERE 절 유무와는 무관하다.', false),

-- 문제 1074
(3055, 1074, '뷰의 조회 성능을 향상시킨다', 'WITH CHECK OPTION은 성능과 무관하다.', false),
(3056, 1074, '뷰를 통한 수정 시 뷰의 조건을 만족하는지 검사한다', 'WITH CHECK OPTION은 뷰를 통해 INSERT나 UPDATE 시 뷰의 WHERE 조건을 만족하는지 검사한다. 조건을 위반하면 오류가 발생한다.', true),
(3057, 1074, '뷰를 자동으로 삭제한다', 'WITH CHECK OPTION은 검사 기능만 제공한다.', false),
(3058, 1074, '인덱스를 생성한다', 'WITH CHECK OPTION은 인덱스와 무관하다.', false),

-- 문제 1075
(3059, 1075, '뷰는 항상 테이블보다 빠르다', '뷰가 항상 빠른 것은 아니다.', false),
(3060, 1075, '복잡한 뷰는 매번 쿼리를 실행하므로 성능이 저하될 수 있다', '뷰는 데이터를 저장하지 않으므로 조회할 때마다 정의된 SELECT 문을 실행한다. 복잡한 조인이나 집계가 포함된 뷰는 성능이 저하될 수 있다.', true),
(3061, 1075, '뷰는 인덱스를 사용할 수 없다', '기본 테이블의 인덱스는 활용된다.', false),
(3062, 1075, '뷰는 캐싱되어 성능이 향상된다', '일반 뷰는 캐싱되지 않는다. 실체화된 뷰는 가능하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (307, 1070, '갱신 가능한 뷰,updatable view', '데이터 수정(INSERT, UPDATE, DELETE)이 가능한 뷰를 갱신 가능한 뷰라고 한다. 단일 테이블 기반이고 집계 함수가 없어야 한다.'),
       (308, 1073, 'with', 'WITH CHECK OPTION은 뷰를 통한 데이터 수정 시 뷰의 WHERE 조건을 만족하는지 검사한다. 조건을 위반하는 수정을 방지한다.');
