-- Chapter: 데이터베이스 (id: 4), Unit: 서브쿼리 (id: 49)

-- Lesson 1: 서브쿼리 기초 (ID: 143)
INSERT INTO lesson (id, title, unit_id)
VALUES (143, '서브쿼리 기초', 49);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (992, 143, '다음 중 서브쿼리에 대한 설명으로 올바른 것은?', '서브쿼리는 SQL 문 내부에 포함된 SELECT 문이다.', 'OBJECTIVE'),
       (993, 143, '빈칸에 들어갈 용어를 작성하시오.', 'SELECT 절에 사용되는 서브쿼리를 ___라고 한다.', 'SUBJECTIVE'),
       (994, 143, '다음 중 서브쿼리의 위치로 올바르지 않은 것은?', '서브쿼리는 SQL 문의 다양한 위치에 사용될 수 있다.', 'OBJECTIVE'),
       (995, 143, '다음 중 스칼라 서브쿼리의 특징으로 올바른 것은?', '스칼라 서브쿼리는 단일 값을 반환하는 서브쿼리이다.', 'OBJECTIVE'),
       (996, 143, '빈칸에 들어갈 용어를 작성하시오.', 'FROM 절에 사용되는 서브쿼리를 ___라고 한다.', 'SUBJECTIVE'),
       (997, 143, '다음 중 서브쿼리 실행 순서로 올바른 것은?', '서브쿼리와 메인 쿼리의 실행 순서를 고려해야 한다.', 'OBJECTIVE'),
       (998, 143, '다음 SQL 명령어의 역할은?', 'SELECT name FROM students WHERE department_id = (SELECT id FROM departments WHERE name = ''컴퓨터공학'');', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 992
(2823, 992, '서브쿼리는 항상 WHERE 절에만 사용할 수 있다', '서브쿼리는 SELECT, FROM, WHERE, HAVING 등 다양한 절에 사용할 수 있다.', false),
(2824, 992, '서브쿼리는 다른 쿼리 내부에 중첩된 SELECT 문이다', '서브쿼리는 메인 쿼리 내부에 포함되어 먼저 실행되는 SELECT 문이다.', true),
(2825, 992, '서브쿼리는 INSERT 문에만 사용할 수 있다', '서브쿼리는 SELECT, INSERT, UPDATE, DELETE 등 다양한 DML 문에서 사용할 수 있다.', false),
(2826, 992, '서브쿼리는 항상 여러 행을 반환해야 한다', '서브쿼리는 단일 값, 단일 행, 여러 행 등 다양한 형태로 결과를 반환할 수 있다.', false),

-- 문제 994
(2827, 994, 'SELECT 절', 'SELECT 절에 서브쿼리를 사용하여 스칼라 서브쿼리를 작성할 수 있다.', false),
(2828, 994, 'GROUP BY 절', 'GROUP BY 절에는 서브쿼리를 직접 사용할 수 없다. 컬럼명이나 표현식만 사용 가능하다.', true),
(2829, 994, 'FROM 절', 'FROM 절에 서브쿼리를 사용하여 인라인 뷰를 작성할 수 있다.', false),
(2830, 994, 'WHERE 절', 'WHERE 절에 서브쿼리를 사용하여 조건을 지정할 수 있다.', false),

-- 문제 995
(2831, 995, '여러 컬럼과 여러 행을 반환한다', '스칼라 서브쿼리는 정확히 하나의 값만 반환해야 한다.', false),
(2832, 995, '여러 행을 반환하지만 하나의 컬럼만 반환한다', '스칼라 서브쿼리는 단일 값(1행 1컬럼)만 반환한다.', false),
(2833, 995, '정확히 하나의 행과 하나의 컬럼을 반환한다', '스칼라 서브쿼리는 단일 값을 반환하므로 1행 1컬럼의 결과를 가진다. SELECT 절에서 주로 사용된다.', true),
(2834, 995, 'NULL 값을 반환할 수 없다', '스칼라 서브쿼리는 조건에 맞는 데이터가 없으면 NULL을 반환할 수 있다.', false),

-- 문제 997
(2835, 997, '메인 쿼리가 먼저 실행되고 서브쿼리가 나중에 실행된다', '일반적으로 서브쿼리가 먼저 실행되어 결과를 메인 쿼리에 전달한다.', false),
(2836, 997, '서브쿼리와 메인 쿼리가 동시에 실행된다', '서브쿼리는 메인 쿼리보다 먼저 실행되어 결과를 반환한다.', false),
(2837, 997, '서브쿼리가 먼저 실행되고 그 결과를 메인 쿼리가 사용한다', '서브쿼리는 메인 쿼리보다 먼저 실행되어 결과값을 반환하고, 메인 쿼리는 이 결과를 사용하여 실행된다.', true),
(2838, 997, '실행 순서는 데이터베이스마다 다르다', '서브쿼리의 실행 순서는 표준 SQL에서 정의되어 있다.', false),

-- 문제 998
(2839, 998, '컴퓨터공학과의 모든 학생 이름을 조회한다', '서브쿼리가 컴퓨터공학과의 department_id를 반환하고, 메인 쿼리가 해당 학과의 학생 이름을 조회한다.', true),
(2840, 998, '컴퓨터공학과라는 이름을 가진 학생을 조회한다', '서브쿼리는 departments 테이블에서 학과 ID를 조회한다.', false),
(2841, 998, '모든 학과의 학생 이름을 조회한다', '서브쿼리로 특정 학과의 ID만 조회한다.', false),
(2842, 998, 'departments 테이블의 모든 데이터를 조회한다', '메인 쿼리는 students 테이블의 name을 조회한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (285, 993, '스칼라 서브쿼리, scalar subquery', 'SELECT 절에 사용되는 서브쿼리를 스칼라 서브쿼리라고 한다. 스칼라 서브쿼리는 정확히 하나의 값(1행 1컬럼)을 반환해야 한다.'),
       (286, 996, '인라인 뷰, inline view', 'FROM 절에 사용되는 서브쿼리를 인라인 뷰라고 한다. 인라인 뷰는 임시 테이블처럼 동작하며, 메인 쿼리에서 일반 테이블처럼 사용할 수 있다.');


-- Lesson 2: 서브쿼리 심화 (ID: 144)
INSERT INTO lesson (id, title, unit_id)
VALUES (144, '서브쿼리 심화', 49);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (999, 144, '다음 중 단일 행 서브쿼리에서 사용할 수 있는 비교 연산자는?', '단일 행 서브쿼리는 하나의 행만 반환하는 서브쿼리이다.', 'OBJECTIVE'),
       (1000, 144, '빈칸에 들어갈 연산자를 작성하시오.', 'SELECT * FROM students WHERE department_id ___ (SELECT id FROM departments WHERE name = ''경영학''); -- 단일 값 비교', 'SUBJECTIVE'),
       (1001, 144, '다음 중 다중 행 서브쿼리에서 사용하는 연산자로 올바른 것은?', '다중 행 서브쿼리는 여러 행을 반환하는 서브쿼리이다.', 'OBJECTIVE'),
       (1002, 144, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students WHERE department_id IN (SELECT id FROM departments WHERE college = ''공과대학'');', 'OBJECTIVE'),
       (1003, 144, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT * FROM students WHERE salary > ___ (SELECT salary FROM students); -- 서브쿼리의 모든 값보다 큼', 'SUBJECTIVE'),
       (1004, 144, '다음 중 상관 서브쿼리의 특징으로 올바른 것은?', '상관 서브쿼리는 메인 쿼리와 연관된 서브쿼리이다.', 'OBJECTIVE'),
       (1005, 144, '다음 중 EXISTS 연산자의 특징으로 올바른 것은?', 'EXISTS는 서브쿼리의 결과 존재 여부를 확인하는 연산자이다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 999
(2843, 999, 'IN', 'IN은 다중 행 서브쿼리에서 사용하는 연산자이다.', false),
(2844, 999, '=', '단일 행 서브쿼리는 하나의 값만 반환하므로 =, >, <, >=, <=, <> 등의 비교 연산자를 사용할 수 있다.', true),
(2845, 999, 'ANY', 'ANY는 다중 행 서브쿼리에서 사용하는 연산자이다.', false),
(2846, 999, 'ALL', 'ALL은 다중 행 서브쿼리에서 사용하는 연산자이다.', false),

-- 문제 1001
(2847, 1001, '=', '= 연산자는 단일 값과 비교할 때 사용한다.', false),
(2848, 1001, 'IN', 'IN 연산자는 다중 행 서브쿼리의 결과 중 하나와 일치하는지 확인한다. 여러 값 중 하나라도 일치하면 true를 반환한다.', true),
(2849, 1001, 'BETWEEN', 'BETWEEN은 범위를 지정하는 연산자이다.', false),
(2850, 1001, 'LIKE', 'LIKE는 패턴 매칭에 사용하는 연산자이다.', false),

-- 문제 1002
(2851, 1002, '공과대학에 속한 모든 학과의 학생을 조회한다', '서브쿼리가 공과대학 소속 학과의 ID 목록을 반환하고, IN 연산자로 해당 학과의 학생들을 조회한다.', true),
(2852, 1002, '공과대학이라는 이름을 가진 학생을 조회한다', '서브쿼리는 departments 테이블에서 학과 ID를 조회한다.', false),
(2853, 1002, 'departments 테이블의 모든 데이터를 조회한다', '메인 쿼리는 students 테이블의 데이터를 조회한다.', false),
(2854, 1002, '하나의 학과에 속한 학생만 조회한다', 'IN 연산자로 여러 학과의 학생을 조회할 수 있다.', false),

-- 문제 1004
(2855, 1004, '메인 쿼리와 독립적으로 실행된다', '상관 서브쿼리는 메인 쿼리의 값을 참조하여 실행된다.', false),
(2856, 1004, '메인 쿼리의 각 행마다 서브쿼리가 실행된다', '상관 서브쿼리는 메인 쿼리의 각 행에 대해 반복 실행되며, 메인 쿼리의 컬럼 값을 참조한다.', true),
(2857, 1004, '서브쿼리가 먼저 한 번만 실행된다', '일반 서브쿼리의 특징이다. 상관 서브쿼리는 메인 쿼리의 행마다 반복 실행된다.', false),
(2858, 1004, '항상 단일 값을 반환한다', '상관 서브쿼리도 다중 행을 반환할 수 있다.', false),

-- 문제 1005
(2859, 1005, 'EXISTS는 서브쿼리의 결과값을 반환한다', 'EXISTS는 결과 존재 여부만 확인하여 true/false를 반환한다.', false),
(2860, 1005, 'EXISTS는 서브쿼리가 반환하는 행의 개수를 센다', 'COUNT 함수가 행의 개수를 센다.', false),
(2861, 1005, 'EXISTS는 서브쿼리 결과가 존재하면 true를 반환한다', 'EXISTS는 서브쿼리가 하나 이상의 행을 반환하면 true, 반환하지 않으면 false를 반환한다. 실제 결과값은 확인하지 않는다.', true),
(2862, 1005, 'EXISTS는 NULL 값을 확인하는 연산자이다', 'IS NULL이 NULL 값을 확인하는 연산자이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (287, 1000, '=', '단일 행 서브쿼리는 하나의 값만 반환하므로 =, >, <, >=, <=, <> 등의 비교 연산자를 사용하여 값을 비교할 수 있다.'),
       (288, 1003, 'ALL', 'ALL 연산자는 서브쿼리가 반환하는 모든 값과 비교하여 모두 만족하면 true를 반환한다. > ALL은 서브쿼리의 모든 값보다 큰 경우를 의미한다.');


-- Lesson 3: 서브쿼리 활용 (ID: 145)
INSERT INTO lesson (id, title, unit_id)
VALUES (145, '서브쿼리 활용', 49);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1006, 145, '다음 SQL 명령어의 역할은?', 'SELECT name, (SELECT AVG(salary) FROM students) AS avg_salary FROM students;', 'OBJECTIVE'),
       (1007, 145, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT * FROM (SELECT * FROM students WHERE grade >= 3) ___ high_grade; -- 별칭 지정', 'SUBJECTIVE'),
       (1008, 145, '다음 중 NOT IN 연산자의 사용법으로 올바른 것은?', 'NOT IN은 서브쿼리 결과에 포함되지 않는 값을 조회한다.', 'OBJECTIVE'),
       (1009, 145, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students WHERE salary > ANY (SELECT salary FROM students WHERE department_id = 1);', 'OBJECTIVE'),
       (1010, 145, '빈칸에 들어갈 연산자를 작성하시오.', 'SELECT * FROM departments d WHERE ___ (SELECT 1 FROM students s WHERE s.department_id = d.id); -- 학생이 있는 학과만 조회', 'SUBJECTIVE'),
       (1011, 145, '다음 중 서브쿼리 최적화 방법으로 올바르지 않은 것은?', '서브쿼리는 성능에 영향을 줄 수 있으므로 최적화가 필요하다.', 'OBJECTIVE'),
       (1012, 145, '다음 중 서브쿼리와 JOIN의 차이로 올바른 것은?', '서브쿼리와 JOIN은 상황에 따라 선택하여 사용할 수 있다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1006
(2863, 1006, '각 학생의 이름과 평균 급여를 조회한다', 'SELECT 절의 스칼라 서브쿼리로 전체 학생의 평균 급여를 계산하여 모든 행에 동일한 평균값을 표시한다.', true),
(2864, 1006, '급여가 평균 이상인 학생을 조회한다', 'WHERE 절이 없으므로 모든 학생을 조회한다.', false),
(2865, 1006, '학생을 급여 순으로 정렬한다', 'ORDER BY 절이 없으므로 정렬하지 않는다.', false),
(2866, 1006, '학생 수와 평균 급여를 조회한다', 'name 컬럼을 조회하므로 각 학생의 정보가 표시된다.', false),

-- 문제 1008
(2867, 1008, 'WHERE department_id NOT IN (1, 2, 3)', '괄호 안의 값 목록에 포함되지 않는 데이터를 조회한다.', false),
(2868, 1008, 'WHERE department_id NOT IN (SELECT id FROM departments WHERE college = ''인문대'')', '서브쿼리 결과에 포함되지 않는 값을 조회한다. 인문대가 아닌 학과의 학생을 조회한다.', true),
(2869, 1008, 'WHERE NOT department_id IN (SELECT id FROM departments)', 'NOT의 위치가 잘못되었다. NOT IN으로 함께 사용한다.', false),
(2870, 1008, 'WHERE department_id IN NOT (SELECT id FROM departments)', 'IN NOT은 올바른 문법이 아니다.', false),

-- 문제 1009
(2871, 1009, '1번 학과 학생들의 급여보다 모두 높은 학생을 조회한다', '> ALL이 모든 값보다 큰 경우이다.', false),
(2872, 1009, '1번 학과 학생들의 급여 중 하나보다 높은 학생을 조회한다', '> ANY는 서브쿼리가 반환하는 값 중 하나라도 크면 true를 반환한다. 1번 학과 학생 중 최소 급여보다 높으면 조회된다.', true),
(2873, 1009, '1번 학과 학생만 조회한다', 'WHERE 절에 department_id 조건이 없으므로 모든 학과를 대상으로 조회한다.', false),
(2874, 1009, '급여가 가장 높은 학생을 조회한다', 'MAX 함수나 ORDER BY LIMIT를 사용해야 한다.', false),

-- 문제 1011
(2875, 1011, '서브쿼리를 JOIN으로 변환한다', 'JOIN으로 변환하면 성능이 향상될 수 있다.', false),
(2876, 1011, '인덱스를 활용한다', '서브쿼리에서 사용하는 컬럼에 인덱스를 생성하면 성능이 향상된다.', false),
(2877, 1011, '서브쿼리를 중첩하여 여러 단계로 사용한다', '서브쿼리를 과도하게 중첩하면 성능이 저하된다. 가능한 한 단순하게 작성하는 것이 좋다.', true),
(2878, 1011, '불필요한 서브쿼리를 제거한다', '동일한 결과를 얻을 수 있다면 서브쿼리 대신 간단한 조건을 사용하는 것이 효율적이다.', false),

-- 문제 1012
(2879, 1012, '서브쿼리는 읽기가 더 쉽고 JOIN은 성능이 더 좋다', '일반적으로 JOIN이 성능이 더 좋지만, 상황에 따라 다를 수 있다.', false),
(2880, 1012, '서브쿼리는 단일 테이블 조회에만 사용할 수 있다', '서브쿼리도 여러 테이블을 조회할 수 있다.', false),
(2881, 1012, 'JOIN은 여러 테이블의 컬럼을 함께 조회할 때 유리하다', 'JOIN은 여러 테이블의 데이터를 하나의 결과로 결합하여 조회할 때 유리하다. 서브쿼리는 조건 필터링에 주로 사용된다.', true),
(2882, 1012, 'JOIN은 절대 서브쿼리로 변환할 수 없다', '대부분의 JOIN은 서브쿼리로 변환 가능하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (289, 1007, 'AS', 'FROM 절의 서브쿼리(인라인 뷰)에는 반드시 별칭(alias)을 지정해야 한다. AS 키워드를 사용하여 별칭을 지정한다. AS는 생략 가능하다.'),
       (290, 1010, 'EXISTS', 'EXISTS는 서브쿼리 결과가 존재하는지 확인한다. 상관 서브쿼리와 함께 사용하여 관련 데이터가 있는 행만 조회할 수 있다. 학생이 존재하는 학과만 조회된다.');

-- Chapter: 데이터베이스 (id: 4), Unit: 조인 (id: 50)

-- Lesson 1: 조인 기초 (ID: 146)
INSERT INTO lesson (id, title, unit_id)
VALUES (146, '조인 기초', 50);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1013, 146, '다음 중 조인(JOIN)에 대한 설명으로 올바른 것은?', '조인은 두 개 이상의 테이블을 연결하여 데이터를 조회하는 방법이다.', 'OBJECTIVE'),
       (1014, 146, '빈칸에 들어갈 용어를 작성하시오.', '두 테이블을 연결할 때 사용하는 공통 컬럼을 ___라고 한다.', 'SUBJECTIVE'),
       (1015, 146, '다음 중 조인의 필요성으로 올바르지 않은 것은?', '조인은 관계형 데이터베이스에서 정규화된 테이블의 데이터를 결합하기 위해 사용한다.', 'OBJECTIVE'),
       (1016, 146, '다음 SQL 명령어의 역할은?', 'SELECT s.name, d.name FROM students s, departments d WHERE s.department_id = d.id;', 'OBJECTIVE'),
       (1017, 146, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT * FROM students s ___ departments d ON s.department_id = d.id; -- 명시적 조인', 'SUBJECTIVE'),
       (1018, 146, '다음 중 조인 조건으로 올바른 것은?', '조인 조건은 두 테이블을 연결하는 기준을 정의한다.', 'OBJECTIVE'),
       (1019, 146, '다음 중 테이블 별칭(alias) 사용의 장점으로 올바른 것은?', '테이블 별칭은 SQL 문을 간결하게 작성하는 데 도움을 준다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1013
(2883, 1013, '조인은 하나의 테이블 내에서만 데이터를 조회한다', '조인은 두 개 이상의 테이블을 연결한다.', false),
(2884, 1013, '조인은 외래키가 없으면 절대 사용할 수 없다', '외래키 제약 조건이 없어도 공통 컬럼으로 조인할 수 있다.', false),
(2885, 1013, '조인은 여러 테이블에 분산된 데이터를 하나의 결과로 결합한다', '조인은 두 개 이상의 테이블을 공통 컬럼을 기준으로 연결하여 관련 데이터를 함께 조회한다.', true),
(2886, 1013, '조인은 테이블의 행을 삭제하는 명령이다', 'DELETE가 행을 삭제하는 명령이다.', false),

-- 문제 1015
(2887, 1015, '정규화로 분리된 테이블의 데이터를 결합하기 위해', '조인은 정규화된 테이블의 데이터를 결합하여 의미있는 정보를 조회하기 위해 필요하다.', false),
(2888, 1015, '여러 테이블의 관련 데이터를 함께 조회하기 위해', '조인을 통해 관련된 데이터를 한 번에 조회할 수 있다.', false),
(2889, 1015, '데이터 중복을 제거하기 위해', '데이터 중복 제거는 정규화의 목적이다. 조인은 분리된 데이터를 결합하는 것이 목적이다.', true),
(2890, 1015, '외래키로 연결된 테이블의 정보를 함께 보기 위해', '조인은 외래키 관계의 테이블을 연결하여 조회하는 데 사용된다.', false),

-- 문제 1016
(2891, 1016, '학생 이름과 학과 이름을 함께 조회한다', 'students와 departments 테이블을 조인하여 학생 이름과 소속 학과 이름을 함께 조회한다. 암시적 조인 방식이다.', true),
(2892, 1016, '학생 테이블만 조회한다', 'departments 테이블도 함께 조회한다.', false),
(2893, 1016, '학과 테이블의 데이터를 삭제한다', 'SELECT 문으로 데이터를 조회한다.', false),
(2894, 1016, '두 테이블의 모든 조합을 조회한다', 'WHERE 절로 조인 조건을 지정했으므로 카테시안 곱이 아니다.', false),

-- 문제 1018
(2895, 1018, 'ON s.name = d.name', '이름으로 조인하는 것은 일반적이지 않다. 주로 ID로 조인한다.', false),
(2896, 1018, 'ON s.department_id = d.id', '외래키와 기본키를 연결하는 것이 일반적인 조인 조건이다. students의 department_id와 departments의 id를 연결한다.', true),
(2897, 1018, 'ON s.id = d.id', '서로 다른 의미의 ID를 연결하면 잘못된 결과가 나온다.', false),
(2898, 1018, 'ON s.grade = d.id', '학년과 학과 ID는 연관성이 없다.', false),

-- 문제 1019
(2899, 1019, '테이블 이름을 짧게 표현하여 쿼리 작성이 편리하다', '별칭을 사용하면 긴 테이블 이름을 짧게 표현할 수 있어 SQL 문이 간결해진다. 특히 조인 시 유용하다.', true),
(2900, 1019, '별칭을 사용하면 쿼리 성능이 향상된다', '별칭은 가독성을 위한 것으로 성능과는 무관하다.', false),
(2901, 1019, '별칭 없이는 조인을 사용할 수 없다', '별칭 없이도 조인을 사용할 수 있다.', false),
(2902, 1019, '별칭을 사용하면 테이블 구조가 변경된다', '별칭은 쿼리 내에서만 사용되는 임시 이름이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (291, 1014, '조인 키, 조인키, join key', '두 테이블을 연결할 때 사용하는 공통 컬럼을 조인 키라고 한다. 일반적으로 한 테이블의 외래키와 다른 테이블의 기본키를 조인 키로 사용한다.'),
       (292, 1017, 'JOIN, INNER JOIN', '명시적 조인은 JOIN 키워드를 사용하여 테이블을 연결한다. INNER JOIN이 기본이며, INNER는 생략 가능하다.');


-- Lesson 2: 조인 유형 (ID: 147)
INSERT INTO lesson (id, title, unit_id)
VALUES (147, '조인 유형', 50);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1020, 147, '다음 중 INNER JOIN의 특징으로 올바른 것은?', 'INNER JOIN은 두 테이블에서 조인 조건을 만족하는 데이터만 조회한다.', 'OBJECTIVE'),
       (1021, 147, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT * FROM students s ___ JOIN departments d ON s.department_id = d.id; -- 왼쪽 테이블의 모든 데이터 포함', 'SUBJECTIVE'),
       (1022, 147, '다음 중 LEFT JOIN의 결과로 올바른 것은?', 'LEFT JOIN은 왼쪽 테이블의 모든 행을 포함한다.', 'OBJECTIVE'),
       (1023, 147, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students s RIGHT JOIN departments d ON s.department_id = d.id;', 'OBJECTIVE'),
       (1024, 147, '빈칸에 들어갈 조인 유형을 작성하시오.', 'SELECT * FROM students s ___ JOIN departments d ON s.department_id = d.id; -- 양쪽 테이블의 모든 데이터 포함', 'SUBJECTIVE'),
       (1025, 147, '다음 중 CROSS JOIN의 특징으로 올바른 것은?', 'CROSS JOIN은 두 테이블의 모든 조합을 생성한다.', 'OBJECTIVE'),
       (1026, 147, '다음 중 SELF JOIN에 대한 설명으로 올바른 것은?', 'SELF JOIN은 자기 자신과 조인하는 방법이다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1020
(2903, 1020, '왼쪽 테이블의 모든 행을 포함한다', 'LEFT JOIN의 특징이다.', false),
(2904, 1020, '두 테이블 모두에 존재하는 데이터만 조회한다', 'INNER JOIN은 조인 조건을 만족하는 행만 반환한다. 양쪽 테이블에 모두 일치하는 데이터가 있어야 결과에 포함된다.', true),
(2905, 1020, '오른쪽 테이블의 모든 행을 포함한다', 'RIGHT JOIN의 특징이다.', false),
(2906, 1020, '모든 가능한 조합을 생성한다', 'CROSS JOIN의 특징이다.', false),

-- 문제 1022
(2907, 1022, '조인 조건을 만족하는 행만 포함된다', 'INNER JOIN의 결과이다.', false),
(2908, 1022, '왼쪽 테이블의 모든 행이 포함되고, 매칭되지 않으면 NULL이 표시된다', 'LEFT JOIN은 왼쪽 테이블의 모든 행을 포함하고, 오른쪽 테이블에 매칭되는 데이터가 없으면 NULL로 표시한다.', true),
(2909, 1022, '오른쪽 테이블의 모든 행만 포함된다', 'RIGHT JOIN의 결과이다.', false),
(2910, 1022, '두 테이블의 카테시안 곱이 생성된다', 'CROSS JOIN의 결과이다.', false),

-- 문제 1023
(2911, 1023, '모든 학생과 학과 정보를 조회한다', 'RIGHT JOIN이므로 모든 학과가 포함된다.', false),
(2912, 1023, '학생이 없는 학과도 포함하여 모든 학과를 조회한다', 'RIGHT JOIN은 오른쪽 테이블(departments)의 모든 행을 포함한다. 학생이 없는 학과도 조회되며, 학생 정보는 NULL로 표시된다.', true),
(2913, 1023, '학과가 없는 학생만 조회한다', 'WHERE d.id IS NULL 조건이 있어야 한다.', false),
(2914, 1023, '학생과 학과가 모두 있는 경우만 조회한다', 'INNER JOIN의 결과이다.', false),

-- 문제 1025
(2915, 1025, '조인 조건이 필수적이다', 'CROSS JOIN은 조인 조건 없이 모든 조합을 생성한다.', false),
(2916, 1025, '두 테이블의 모든 행을 카테시안 곱으로 결합한다', 'CROSS JOIN은 조인 조건 없이 왼쪽 테이블의 각 행을 오른쪽 테이블의 모든 행과 결합한다. m개와 n개 행이면 m×n개 행이 생성된다.', true),
(2917, 1025, '왼쪽 테이블의 행만 포함한다', 'LEFT JOIN의 특징이다.', false),
(2918, 1025, '매칭되는 행만 반환한다', 'INNER JOIN의 특징이다.', false),

-- 문제 1026
(2919, 1026, '서로 다른 두 테이블을 조인하는 방법이다', 'SELF JOIN은 같은 테이블을 조인한다.', false),
(2920, 1026, '동일한 테이블을 두 번 참조하여 조인한다', 'SELF JOIN은 같은 테이블을 마치 두 개의 테이블처럼 사용하여 조인한다. 별칭을 반드시 사용해야 한다.', true),
(2921, 1026, '반드시 CROSS JOIN으로만 구현할 수 있다', 'INNER JOIN, LEFT JOIN 등 다양한 조인 방식으로 구현 가능하다.', false),
(2922, 1026, '별칭을 사용할 수 없다', 'SELF JOIN은 별칭이 필수적이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (293, 1021, 'LEFT, LEFT OUTER', 'LEFT JOIN은 왼쪽 테이블의 모든 행을 포함하고, 오른쪽 테이블에 매칭되는 데이터가 없으면 NULL로 표시한다. OUTER는 생략 가능하다.'),
       (294, 1024, 'FULL, FULL OUTER', 'FULL OUTER JOIN은 양쪽 테이블의 모든 행을 포함한다. 매칭되지 않는 부분은 NULL로 표시된다. OUTER는 생략 가능하다.');


-- Lesson 3: 조인 활용 (ID: 148)
INSERT INTO lesson (id, title, unit_id)
VALUES (148, '조인 활용', 50);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1027, 148, '다음 SQL 명령어의 역할은?', 'SELECT s.name, d.name FROM students s LEFT JOIN departments d ON s.department_id = d.id WHERE d.id IS NULL;', 'OBJECTIVE'),
       (1028, 148, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT a.name, b.name FROM employees a JOIN employees b ___ a.manager_id = b.id; -- 조인 조건 지정', 'SUBJECTIVE'),
       (1029, 148, '다음 중 다중 조인에 대한 설명으로 올바른 것은?', '다중 조인은 세 개 이상의 테이블을 연결하는 방법이다.', 'OBJECTIVE'),
       (1030, 148, '다음 SQL 명령어의 역할은?', 'SELECT s.name, d.name, c.name FROM students s JOIN departments d ON s.department_id = d.id JOIN colleges c ON d.college_id = c.id;', 'OBJECTIVE'),
       (1031, 148, '빈칸에 들어갈 조건을 작성하시오.', 'SELECT * FROM students s LEFT JOIN departments d ON s.department_id = d.id WHERE ___; -- 학과가 없는 학생만 조회', 'SUBJECTIVE'),
       (1032, 148, '다음 중 조인 성능 최적화 방법으로 올바른 것은?', '조인은 대량의 데이터를 처리할 때 성능에 영향을 줄 수 있다.', 'OBJECTIVE'),
       (1033, 148, '다음 중 암시적 조인과 명시적 조인의 차이로 올바른 것은?', '암시적 조인과 명시적 조인은 문법만 다를 뿐 결과는 동일하다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1027
(2923, 1027, '모든 학생과 학과를 조회한다', 'WHERE 조건으로 필터링한다.', false),
(2924, 1027, '학과가 없는 학생만 조회한다', 'LEFT JOIN으로 모든 학생을 포함하고, WHERE d.id IS NULL로 학과가 매칭되지 않는(학과가 없는) 학생만 필터링한다.', true),
(2925, 1027, '학과가 있는 학생만 조회한다', 'WHERE d.id IS NOT NULL이 해당 조건이다.', false),
(2926, 1027, '학생이 없는 학과를 조회한다', 'RIGHT JOIN을 사용해야 한다.', false),

-- 문제 1029
(2927, 1029, '두 개의 테이블만 조인할 수 있다', '세 개 이상의 테이블도 조인 가능하다.', false),
(2928, 1029, '세 개 이상의 테이블을 순차적으로 조인할 수 있다', '다중 조인은 여러 JOIN 절을 연결하여 세 개 이상의 테이블을 조인한다. 첫 번째 조인 결과에 다음 테이블을 조인하는 방식이다.', true),
(2929, 1029, '반드시 같은 종류의 조인만 사용해야 한다', 'INNER JOIN과 LEFT JOIN을 섞어서 사용할 수 있다.', false),
(2930, 1029, '다중 조인은 성능에 영향을 주지 않는다', '조인이 많을수록 성능에 영향을 줄 수 있다.', false),

-- 문제 1030
(2931, 1030, '학생, 학과, 단과대학 정보를 함께 조회한다', '세 개의 테이블을 조인하여 학생 이름, 소속 학과 이름, 소속 단과대학 이름을 함께 조회한다.', true),
(2932, 1030, '학생 정보만 조회한다', '세 테이블의 name을 모두 조회한다.', false),
(2933, 1030, '단과대학 정보만 조회한다', '학생, 학과, 단과대학 정보를 모두 조회한다.', false),
(2934, 1030, '테이블을 생성한다', 'SELECT 문으로 데이터를 조회한다.', false),

-- 문제 1032
(2935, 1032, '가능한 많은 테이블을 조인한다', '필요한 테이블만 조인하는 것이 효율적이다.', false),
(2936, 1032, '조인 키에 인덱스를 생성한다', '조인 조건에 사용되는 컬럼에 인덱스를 생성하면 조인 성능이 향상된다. 특히 외래키 컬럼에 인덱스를 생성하는 것이 좋다.', true),
(2937, 1032, '별칭을 사용하지 않는다', '별칭은 성능과 무관하며 가독성을 위한 것이다.', false),
(2938, 1032, 'WHERE 절을 사용하지 않는다', 'WHERE 절로 필요한 데이터만 필터링하면 성능이 향상된다.', false),

-- 문제 1033
(2939, 1033, '암시적 조인은 WHERE 절에 조인 조건을 작성한다', '암시적 조인은 FROM 절에 테이블을 나열하고 WHERE 절에 조인 조건을 작성한다. 명시적 조인은 JOIN 키워드를 사용한다.', true),
(2940, 1033, '명시적 조인은 성능이 더 좋다', '두 방식의 성능은 동일하다.', false),
(2941, 1033, '암시적 조인은 LEFT JOIN을 사용할 수 있다', '암시적 조인은 INNER JOIN만 가능하다. OUTER JOIN은 명시적 조인으로만 사용 가능하다.', false),
(2942, 1033, '명시적 조인은 최신 문법이 아니다', '명시적 조인이 표준 SQL 문법이며 권장된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (295, 1028, 'ON', 'SELF JOIN에서도 ON 키워드로 조인 조건을 지정한다. 같은 테이블을 두 번 참조하므로 반드시 서로 다른 별칭을 사용해야 한다.'),
       (296, 1031, 'd.id IS NULL, d.department_id IS NULL', 'LEFT JOIN에서 오른쪽 테이블의 컬럼이 NULL이면 매칭되지 않은 것이다. 학과 테이블의 기본키가 NULL이면 학과가 없는 학생을 의미한다.');
       
-- Chapter: 데이터베이스 (id: 4), Unit: 페이징 (id: 51)
-- Lesson 1: 페이징 기초 (ID: 149)
INSERT INTO lesson (id, title, unit_id)
VALUES (149, '페이징 기초', 51);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1034, 149, '다음 중 페이징(Paging)에 대한 설명으로 올바른 것은?', '페이징은 대량의 데이터를 분할하여 조회하는 기법이다.', 'OBJECTIVE'),
       (1035, 149, '빈칸에 들어갈 용어를 작성하시오.', '한 페이지에 표시할 데이터의 개수를 ___라고 한다.', 'SUBJECTIVE'),
       (1036, 149, '다음 중 페이징이 필요한 이유로 올바르지 않은 것은?', '페이징은 사용자 경험과 시스템 성능을 개선하기 위해 사용한다.', 'OBJECTIVE'),
       (1037, 149, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students ORDER BY id LIMIT 10 OFFSET 0;', 'OBJECTIVE'),
       (1038, 149, '빈칸에 들어갈 키워드를 작성하시오.', 'SELECT * FROM students ___ id LIMIT 10; -- 정렬 후 조회', 'SUBJECTIVE'),
       (1039, 149, '다음 중 LIMIT 절의 특징으로 올바른 것은?', 'LIMIT은 조회할 행의 개수를 제한하는 키워드이다.', 'OBJECTIVE'),
       (1040, 149, '다음 중 OFFSET의 의미로 올바른 것은?', 'OFFSET은 건너뛸 행의 개수를 지정한다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1034
(2943, 1034, '페이징은 모든 데이터를 한 번에 조회하는 방법이다', '페이징은 데이터를 나누어 조회한다.', false),
(2944, 1034, '페이징은 데이터를 일정 단위로 나누어 조회하는 기법이다', '페이징은 대량의 데이터를 페이지 단위로 분할하여 필요한 부분만 조회함으로써 성능을 향상시킨다.', true),
(2945, 1034, '페이징은 데이터를 삭제하는 방법이다', 'DELETE가 데이터를 삭제한다.', false),
(2946, 1034, '페이징은 테이블을 생성하는 방법이다', 'CREATE TABLE이 테이블을 생성한다.', false),

-- 문제 1036
(2947, 1036, '서버 부하를 줄이기 위해', '한 번에 모든 데이터를 조회하면 서버에 부담이 크다.', false),
(2948, 1036, '네트워크 트래픽을 감소시키기 위해', '필요한 데이터만 전송하면 네트워크 부하가 줄어든다.', false),
(2949, 1036, '사용자 경험을 향상시키기 위해', '필요한 데이터만 빠르게 표시하여 사용자 경험이 개선된다.', false),
(2950, 1036, '데이터베이스 용량을 늘리기 위해', '페이징은 데이터베이스 용량과는 무관하다. 조회 성능과 사용자 경험 개선이 목적이다.', true),

-- 문제 1037
(2951, 1037, '첫 번째 페이지의 10개 데이터를 조회한다', 'ORDER BY로 정렬하고, LIMIT 10으로 10개만 조회하며, OFFSET 0으로 첫 번째부터 시작한다.', true),
(2952, 1037, '10번째 학생만 조회한다', 'LIMIT 10은 10개를 조회한다는 의미이다.', false),
(2953, 1037, '모든 학생을 조회한다', 'LIMIT 10으로 10개만 조회한다.', false),
(2954, 1037, '학생 데이터를 삭제한다', 'SELECT 문으로 데이터를 조회한다.', false),

-- 문제 1039
(2955, 1039, 'LIMIT은 조회를 시작할 위치를 지정한다', 'OFFSET이 시작 위치를 지정한다.', false),
(2956, 1039, 'LIMIT은 반환할 최대 행 수를 제한한다', 'LIMIT은 조회할 행의 최대 개수를 지정한다. LIMIT 10이면 최대 10개의 행을 반환한다.', true),
(2957, 1039, 'LIMIT은 데이터를 정렬한다', 'ORDER BY가 데이터를 정렬한다.', false),
(2958, 1039, 'LIMIT은 WHERE 절과 같은 역할을 한다', 'WHERE는 조건을 지정하고, LIMIT은 개수를 제한한다.', false),

-- 문제 1040
(2959, 1040, '조회할 행의 개수를 지정한다', 'LIMIT이 개수를 지정한다.', false),
(2960, 1040, '건너뛸 행의 개수를 지정한다', 'OFFSET은 결과에서 건너뛸 행의 개수를 지정한다. OFFSET 10이면 처음 10개를 건너뛰고 11번째부터 조회한다.', true),
(2961, 1040, '데이터를 정렬한다', 'ORDER BY가 데이터를 정렬한다.', false),
(2962, 1040, '테이블을 생성한다', 'CREATE TABLE이 테이블을 생성한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (297, 1035, '페이지 크기, page size, 페이지당 행 수', '한 페이지에 표시할 데이터의 개수를 페이지 크기라고 한다. 일반적으로 10, 20, 50, 100 등의 값을 사용한다.'),
       (298, 1038, 'ORDER BY', '페이징을 사용할 때는 일관된 결과를 위해 ORDER BY로 정렬 기준을 명시해야 한다. 정렬하지 않으면 같은 쿼리라도 결과 순서가 달라질 수 있다.');


-- Lesson 2: 페이징 구현 (ID: 150)
INSERT INTO lesson (id, title, unit_id)
VALUES (150, '페이징 구현', 51);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1041, 150, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students ORDER BY id LIMIT 10 OFFSET 20;', 'OBJECTIVE'),
       (1042, 150, '빈칸에 들어갈 값을 작성하시오.', 'SELECT * FROM students ORDER BY id LIMIT 10 OFFSET ___; -- 3페이지 조회 (페이지당 10개)', 'SUBJECTIVE'),
       (1043, 150, '다음 중 페이지 번호로 OFFSET을 계산하는 공식으로 올바른 것은?', '페이지 번호와 페이지 크기를 이용하여 OFFSET을 계산한다.', 'OBJECTIVE'),
       (1044, 150, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students ORDER BY name LIMIT 20 OFFSET 40;', 'OBJECTIVE'),
       (1045, 150, '빈칸에 들어갈 값을 작성하시오.', 'SELECT * FROM students ORDER BY id LIMIT ___ OFFSET 0; -- 첫 페이지에 20개씩 표시', 'SUBJECTIVE'),
       (1046, 150, '다음 중 페이징 구현 시 주의사항으로 올바른 것은?', '페이징을 올바르게 구현하려면 몇 가지 규칙을 지켜야 한다.', 'OBJECTIVE'),
       (1047, 150, '다음 중 LIMIT과 OFFSET의 사용법으로 올바르지 않은 것은?', 'LIMIT과 OFFSET은 함께 사용하여 페이징을 구현한다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1041
(2963, 1041, '첫 번째 페이지를 조회한다', 'OFFSET 20이므로 첫 20개를 건너뛴다.', false),
(2964, 1041, '20개를 건너뛰고 그 다음 10개를 조회한다', 'OFFSET 20으로 처음 20개를 건너뛰고, LIMIT 10으로 21번째부터 30번째까지 10개를 조회한다. 3페이지에 해당한다.', true),
(2965, 1041, '20번째 학생만 조회한다', 'LIMIT 10으로 10개를 조회한다.', false),
(2966, 1041, '모든 학생을 조회한다', 'LIMIT 10으로 10개만 조회한다.', false),

-- 문제 1043
(2967, 1043, 'OFFSET = 페이지 번호', '페이지 크기를 고려해야 한다.', false),
(2968, 1043, 'OFFSET = (페이지 번호 - 1) × 페이지 크기', 'OFFSET은 건너뛸 행의 개수이다. 페이지 번호가 1부터 시작한다면 (페이지 번호 - 1) × 페이지 크기로 계산한다.', true),
(2969, 1043, 'OFFSET = 페이지 번호 + 페이지 크기', '곱셈으로 계산해야 한다.', false),
(2970, 1043, 'OFFSET = 페이지 크기 / 페이지 번호', '나눗셈이 아닌 곱셈을 사용한다.', false),

-- 문제 1044
(2971, 1044, '이름 순으로 정렬하여 3페이지를 조회한다', '페이지당 20개씩이면 OFFSET 40은 3페이지이다. name으로 정렬하여 41번째부터 60번째까지 조회한다.', true),
(2972, 1044, 'ID 순으로 정렬하여 조회한다', 'ORDER BY name으로 이름 순으로 정렬한다.', false),
(2973, 1044, '40개의 데이터를 조회한다', 'LIMIT 20으로 20개를 조회한다.', false),
(2974, 1044, '첫 번째 페이지를 조회한다', 'OFFSET 40으로 40개를 건너뛴다.', false),

-- 문제 1046
(2975, 1046, 'ORDER BY 없이 사용해도 된다', 'ORDER BY가 없으면 결과 순서가 일관되지 않을 수 있다.', false),
(2976, 1046, 'ORDER BY를 반드시 사용하여 정렬 순서를 명시해야 한다', 'ORDER BY 없이 페이징을 사용하면 같은 쿼리라도 데이터베이스 내부 상태에 따라 결과 순서가 달라질 수 있다. 일관된 페이징을 위해 ORDER BY는 필수이다.', true),
(2977, 1046, 'LIMIT 값은 항상 100 이상이어야 한다', 'LIMIT 값은 필요에 따라 자유롭게 설정할 수 있다.', false),
(2978, 1046, 'OFFSET은 음수 값을 사용할 수 있다', 'OFFSET은 0 이상의 값만 사용할 수 있다.', false),

-- 문제 1047
(2979, 1047, 'SELECT * FROM students LIMIT 10 OFFSET 0', 'LIMIT 10 OFFSET 0은 올바른 문법이다.', false),
(2980, 1047, 'SELECT * FROM students OFFSET 10 LIMIT 20', 'OFFSET은 LIMIT 뒤에 위치해야 한다. 올바른 순서는 LIMIT 다음 OFFSET이다.', true),
(2981, 1047, 'SELECT * FROM students LIMIT 10', 'OFFSET 없이 LIMIT만 사용할 수 있다. 기본값은 OFFSET 0이다.', false),
(2982, 1047, 'SELECT * FROM students ORDER BY id LIMIT 5 OFFSET 10', 'ORDER BY, LIMIT, OFFSET 순서가 올바르다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (299, 1042, '20', '3페이지를 조회하려면 처음 2페이지(20개)를 건너뛰어야 한다. OFFSET = (3 - 1) × 10 = 20이다.'),
       (300, 1045, '20', '페이지당 20개씩 표시하려면 LIMIT 20을 사용한다. 첫 페이지는 OFFSET 0이므로 처음부터 20개를 조회한다.');


-- Lesson 3: 페이징 최적화 (ID: 151)
INSERT INTO lesson (id, title, unit_id)
VALUES (151, '페이징 최적화', 51);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1048, 151, '다음 중 OFFSET 방식의 단점으로 올바른 것은?', 'LIMIT-OFFSET 방식은 간단하지만 성능상 단점이 있다.', 'OBJECTIVE'),
       (1049, 151, '빈칸에 들어갈 용어를 작성하시오.', '마지막으로 조회한 데이터의 키 값을 기준으로 다음 페이지를 조회하는 방식을 ___라고 한다.', 'SUBJECTIVE'),
       (1050, 151, '다음 중 커서 기반 페이징의 장점으로 올바른 것은?', '커서 기반 페이징은 OFFSET 방식의 성능 문제를 개선한다.', 'OBJECTIVE'),
       (1051, 151, '다음 SQL 명령어의 역할은?', 'SELECT * FROM students WHERE id > 100 ORDER BY id LIMIT 10;', 'OBJECTIVE'),
       (1052, 151, '빈칸에 들어갈 조건을 작성하시오.', 'SELECT * FROM students WHERE ___ ORDER BY created_at DESC LIMIT 20; -- 마지막 조회 시각 이후 데이터', 'SUBJECTIVE'),
       (1053, 151, '다음 중 페이징 성능 최적화 방법으로 올바르지 않은 것은?', '페이징 성능을 향상시키기 위한 다양한 방법이 있다.', 'OBJECTIVE'),
       (1054, 151, '다음 중 COUNT 쿼리 최적화에 대한 설명으로 올바른 것은?', '전체 데이터 개수를 조회하는 COUNT 쿼리는 성능에 영향을 줄 수 있다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1048
(2983, 1048, 'OFFSET이 클수록 성능이 저하된다', 'OFFSET이 커질수록 데이터베이스는 건너뛸 행까지 모두 읽어야 하므로 성능이 저하된다. 마지막 페이지로 갈수록 느려진다.', true),
(2984, 1048, 'OFFSET 방식은 구현이 복잡하다', 'OFFSET 방식은 구현이 간단하다.', false),
(2985, 1048, 'OFFSET은 정렬이 불가능하다', 'ORDER BY로 정렬할 수 있다.', false),
(2986, 1048, 'OFFSET은 첫 페이지 조회가 느리다', '첫 페이지는 빠르고, 뒤로 갈수록 느려진다.', false),

-- 문제 1050
(2987, 1050, '커서 기반 페이징은 OFFSET보다 구현이 간단하다', '커서 기반 페이징은 구현이 더 복잡하다.', false),
(2988, 1050, '커서 기반 페이징은 페이지 번호를 사용할 수 있다', '커서 기반 페이징은 이전/다음 페이지 이동만 가능하다.', false),
(2989, 1050, '커서 기반 페이징은 페이지가 깊어져도 성능이 일정하다', '커서 기반 페이징은 마지막 조회 위치부터 시작하므로 페이지 깊이와 관계없이 일정한 성능을 유지한다. 인덱스를 활용하여 효율적이다.', true),
(2990, 1050, '커서 기반 페이징은 정렬이 불가능하다', 'ORDER BY로 정렬할 수 있다.', false),

-- 문제 1051
(2991, 1051, 'ID가 100인 학생만 조회한다', '> 연산자로 100보다 큰 값을 조회한다.', false),
(2992, 1051, 'ID가 100보다 큰 학생 중 10명을 조회한다', 'WHERE id > 100으로 ID가 100보다 큰 데이터를 필터링하고, LIMIT 10으로 그 중 10개를 조회한다. 커서 기반 페이징 방식이다.', true),
(2993, 1051, '모든 학생을 조회한다', 'WHERE 조건으로 필터링한다.', false),
(2994, 1051, '100명의 학생을 조회한다', 'LIMIT 10으로 10명을 조회한다.', false),

-- 문제 1053
(2995, 1053, '정렬 기준 컬럼에 인덱스를 생성한다', 'ORDER BY 컬럼에 인덱스가 있으면 정렬 성능이 향상된다.', false),
(2996, 1053, '커서 기반 페이징을 사용한다', '깊은 페이지 조회 시 커서 기반 페이징이 효율적이다.', false),
(2997, 1053, '모든 페이지에서 COUNT 쿼리를 매번 실행한다', 'COUNT 쿼리는 비용이 크므로 매번 실행하지 않고 캐싱하거나 필요할 때만 실행하는 것이 좋다.', true),
(2998, 1053, '필요한 컬럼만 SELECT 한다', '불필요한 컬럼을 제외하면 데이터 전송량이 줄어든다.', false),

-- 문제 1054
(2999, 1054, 'COUNT 쿼리는 항상 빠르다', '테이블 크기가 크면 COUNT 쿼리도 느려진다.', false),
(3000, 1054, 'COUNT 쿼리는 인덱스를 활용할 수 없다', 'COUNT 쿼리도 인덱스를 활용할 수 있다.', false),
(3001, 1054, '전체 개수가 자주 변하지 않으면 캐싱을 고려한다', 'COUNT 쿼리는 전체 테이블을 스캔할 수 있어 비용이 크다. 데이터 변경이 적으면 결과를 캐싱하여 재사용하는 것이 효율적이다.', true),
(3002, 1054, 'COUNT 쿼리는 페이징과 무관하다', 'COUNT 쿼리는 전체 페이지 수를 계산하기 위해 사용된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (301, 1049, '커서 기반 페이징, cursor-based paging, 키셋 페이징, keyset pagination', '마지막으로 조회한 데이터의 키 값을 기준으로 다음 페이지를 조회하는 방식을 커서 기반 페이징 또는 키셋 페이징이라고 한다. OFFSET 방식보다 성능이 우수하다.'),
       (302, 1052, 'created_at < ''2024-01-01 00:00:00'', created_at < :last_created_at', '커서 기반 페이징에서는 마지막으로 조회한 시각(커서)보다 이전 데이터를 조회한다. DESC 정렬이므로 < 연산자를 사용한다.');
       
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
VALUES (303, 1056, 'CREATE', 'CREATE VIEW 문으로 뷰를 생성한다. CREATE VIEW 뷰이름 AS SELECT 문 형식으로 작성한다.'),
       (304, 1059, '가상 테이블, virtual table', '뷰는 실제 데이터를 저장하지 않고 SELECT 문의 실행 결과를 보여주는 가상 테이블이다. 뷰를 조회하면 정의된 SELECT 문이 실행된다.');


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
(3023, 1062, '3학년 이상 학생만 조회하는 뷰를 생성한다', 'WHERE grade >= 3 조건으로 3학년 이상 학생만 포함하는 뷰를 생성한다. 뷰를 조회하면 항상 이 조건을 만족하는 데이터만 반환된다.', true),
(3024, 1062, '모든 학생을 조회하는 뷰를 생성한다', 'WHERE 조건으로 필터링한다.', false),
(3025, 1062, '학생 테이블을 삭제한다', 'CREATE VIEW는 뷰를 생성한다.', false),
(3026, 1062, '학생 데이터를 수정한다', 'UPDATE가 데이터를 수정한다.', false),

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
(3040, 1068, '민감한 정보를 제외한 공개 정보만 포함하는 뷰를 생성한다', 'id, name, email만 선택하여 주민번호, 급여 등 민감한 정보는 제외한다. 보안을 위한 뷰 활용 사례이다.', true),
(3041, 1068, '학생 테이블을 삭제한다', 'CREATE VIEW는 뷰를 생성한다.', false),
(3042, 1068, '이메일 정보를 수정한다', 'SELECT 문으로 데이터를 조회한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (305, 1063, 'DROP', 'DROP VIEW 문으로 뷰를 삭제한다. DROP VIEW 뷰이름 형식으로 작성한다.'),
       (306, 1066, 'OR REPLACE', 'CREATE OR REPLACE VIEW는 뷰가 이미 존재하면 대체하고, 없으면 새로 생성한다. 뷰를 수정할 때 사용한다.');


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
VALUES (307, 1070, '갱신 가능한 뷰, updatable view', '데이터 수정(INSERT, UPDATE, DELETE)이 가능한 뷰를 갱신 가능한 뷰라고 한다. 단일 테이블 기반이고 집계 함수가 없어야 한다.'),
       (308, 1073, 'WITH', 'WITH CHECK OPTION은 뷰를 통한 데이터 수정 시 뷰의 WHERE 조건을 만족하는지 검사한다. 조건을 위반하는 수정을 방지한다.');
       
-- Chapter: 데이터베이스 (id: 4), Unit: 정규화 (id: 53)

-- Lesson 1: 정규화 기초 (ID: 155)
INSERT INTO lesson (id, title, unit_id)
VALUES (155, '정규화 기초', 53);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1076, 155, '다음 중 정규화(Normalization)에 대한 설명으로 올바른 것은?', '정규화는 데이터베이스 설계 과정에서 중요한 개념이다.', 'OBJECTIVE'),
       (1077, 155, '빈칸에 들어갈 용어를 작성하시오.', '정규화는 데이터의 ___를 제거하여 이상 현상을 방지한다.', 'SUBJECTIVE'),
       (1078, 155, '다음 중 정규화의 목적으로 올바르지 않은 것은?', '정규화는 데이터베이스의 품질을 향상시키기 위해 수행한다.', 'OBJECTIVE'),
       (1079, 155, '다음 중 이상 현상(Anomaly)의 종류로 올바른 것은?', '정규화되지 않은 테이블에서는 다양한 이상 현상이 발생할 수 있다.', 'OBJECTIVE'),
       (1080, 155, '빈칸에 들어갈 용어를 작성하시오.', '데이터 삽입 시 원치 않는 데이터도 함께 삽입해야 하는 문제를 ___ 이상이라고 한다.', 'SUBJECTIVE'),
       (1081, 155, '다음 중 삭제 이상(Deletion Anomaly)의 설명으로 올바른 것은?', '삭제 이상은 정규화되지 않은 테이블에서 발생하는 문제이다.', 'OBJECTIVE'),
       (1082, 155, '다음 중 갱신 이상(Update Anomaly)의 예시로 올바른 것은?', '갱신 이상은 데이터 불일치를 초래할 수 있다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1076
(3063, 1076, '정규화는 데이터 중복을 증가시킨다', '정규화는 데이터 중복을 제거한다.', false),
(3064, 1076, '정규화는 테이블을 분리하여 데이터 중복과 이상 현상을 제거한다', '정규화는 함수적 종속성을 기반으로 테이블을 분해하여 데이터 중복을 최소화하고 이상 현상을 방지한다.', true),
(3065, 1076, '정규화는 테이블을 합치는 과정이다', '반정규화가 테이블을 합치는 과정이다.', false),
(3066, 1076, '정규화는 인덱스를 생성하는 과정이다', '정규화는 테이블 구조를 개선하는 과정이다.', false),

-- 문제 1078
(3067, 1078, '데이터 중복을 최소화하기 위해', '정규화는 데이터 중복을 제거한다.', false),
(3068, 1078, '이상 현상을 방지하기 위해', '정규화는 삽입, 삭제, 갱신 이상을 방지한다.', false),
(3069, 1078, '조회 성능을 향상시키기 위해', '정규화는 데이터 무결성이 목적이며, 조회 성능 향상이 주목적이 아니다. 오히려 조인이 많아져 성능이 저하될 수 있다.', true),
(3070, 1078, '데이터 무결성을 보장하기 위해', '정규화는 데이터의 일관성과 정확성을 유지한다.', false),

-- 문제 1079
(3071, 1079, '삽입 이상, 삭제 이상, 조회 이상', '조회 이상은 없다.', false),
(3072, 1079, '삽입 이상, 삭제 이상, 갱신 이상', '정규화되지 않은 테이블에서는 삽입 이상, 삭제 이상, 갱신 이상이 발생할 수 있다.', true),
(3073, 1079, '생성 이상, 수정 이상, 제거 이상', '정확한 용어는 삽입, 삭제, 갱신 이상이다.', false),
(3074, 1079, '중복 이상, 불일치 이상, 손실 이상', '정확한 이상 현상의 분류가 아니다.', false),

-- 문제 1081
(3075, 1081, '데이터를 삽입할 때 발생하는 문제이다', '삽입 이상의 설명이다.', false),
(3076, 1081, '데이터를 삭제할 때 필요한 데이터까지 함께 삭제되는 문제이다', '삭제 이상은 특정 데이터를 삭제할 때 의도하지 않은 다른 정보까지 함께 삭제되는 현상이다.', true),
(3077, 1081, '데이터를 수정할 때 발생하는 문제이다', '갱신 이상의 설명이다.', false),
(3078, 1081, '데이터를 조회할 때 발생하는 문제이다', '조회 이상은 없다.', false),

-- 문제 1082
(3079, 1082, '새로운 데이터를 삽입할 수 없는 경우', '삽입 이상의 예시이다.', false),
(3080, 1082, '동일한 정보가 여러 행에 중복 저장되어 일부만 수정하면 불일치가 발생하는 경우', '갱신 이상은 중복된 데이터 중 일부만 수정하여 데이터 불일치가 발생하는 현상이다. 모든 중복 데이터를 찾아 수정해야 한다.', true),
(3081, 1082, '필요한 데이터까지 삭제되는 경우', '삭제 이상의 예시이다.', false),
(3082, 1082, '인덱스가 없어서 조회가 느린 경우', '이상 현상과 무관하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (309, 1077, '중복, 중복성, redundancy', '정규화는 데이터의 중복을 제거하여 삽입, 삭제, 갱신 이상을 방지하고 데이터 무결성을 보장한다.'),
       (310, 1080, '삽입, insertion', '삽입 이상은 데이터를 삽입할 때 원하지 않는 데이터도 함께 삽입해야 하거나, 특정 데이터만 삽입할 수 없는 현상이다.');


-- Lesson 2: 정규형 (ID: 156)
INSERT INTO lesson (id, title, unit_id)
VALUES (156, '정규형', 53);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1083, 156, '다음 중 제1정규형(1NF)의 조건으로 올바른 것은?', '제1정규형은 가장 기본적인 정규형이다.', 'OBJECTIVE'),
       (1084, 156, '빈칸에 들어갈 용어를 작성하시오.', '각 속성이 더 이상 분리할 수 없는 하나의 값만 가져야 하는 특성을 ___라고 한다.', 'SUBJECTIVE'),
       (1085, 156, '다음 중 제1정규형을 만족하지 않는 테이블은?', '제1정규형은 원자값을 가져야 한다.', 'OBJECTIVE'),
       (1086, 156, '다음 중 제2정규형(2NF)의 조건으로 올바른 것은?', '제2정규형은 부분 함수 종속을 제거한다.', 'OBJECTIVE'),
       (1087, 156, '빈칸에 들어갈 용어를 작성하시오.', '복합키의 일부 속성에만 종속되는 것을 ___ 함수 종속이라고 한다.', 'SUBJECTIVE'),
       (1088, 156, '다음 중 제3정규형(3NF)의 조건으로 올바른 것은?', '제3정규형은 이행적 종속을 제거한다.', 'OBJECTIVE'),
       (1089, 156, '다음 중 BCNF(Boyce-Codd Normal Form)의 특징으로 올바른 것은?', 'BCNF는 3NF보다 엄격한 정규형이다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1083
(3083, 1083, '모든 속성이 기본키에 완전 함수 종속되어야 한다', '제2정규형의 조건이다.', false),
(3084, 1083, '각 속성이 원자값을 가져야 한다', '제1정규형은 모든 속성이 더 이상 분리할 수 없는 원자값을 가져야 한다. 다중값이나 반복 그룹이 없어야 한다.', true),
(3085, 1083, '이행적 종속이 없어야 한다', '제3정규형의 조건이다.', false),
(3086, 1083, '모든 결정자가 후보키여야 한다', 'BCNF의 조건이다.', false),

-- 문제 1085
(3087, 1085, '학생(학번, 이름, 학과)', '각 속성이 원자값을 가진다.', false),
(3088, 1085, '학생(학번, 이름, 전화번호1, 전화번호2)', '전화번호가 분리되어 있지만 각각 원자값이다.', false),
(3089, 1085, '학생(학번, 이름, 수강과목)', '수강과목이 여러 개면 원자값이 아니다. 하나의 셀에 여러 과목이 들어가면 1NF를 위반한다.', true),
(3090, 1085, '학생(학번, 이름, 생년월일)', '각 속성이 원자값을 가진다.', false),

-- 문제 1086
(3091, 1086, '원자값을 가져야 한다', '제1정규형의 조건이다.', false),
(3092, 1086, '제1정규형을 만족하고 부분 함수 종속을 제거해야 한다', '제2정규형은 1NF를 만족하면서 모든 비주요 속성이 기본키에 완전 함수 종속되어야 한다. 부분 함수 종속을 제거해야 한다.', true),
(3093, 1086, '이행적 종속을 제거해야 한다', '제3정규형의 조건이다.', false),
(3094, 1086, '모든 결정자가 후보키여야 한다', 'BCNF의 조건이다.', false),

-- 문제 1088
(3095, 1088, '원자값을 가져야 한다', '제1정규형의 조건이다.', false),
(3096, 1088, '부분 함수 종속을 제거해야 한다', '제2정규형의 조건이다.', false),
(3097, 1088, '제2정규형을 만족하고 이행적 종속을 제거해야 한다', '제3정규형은 2NF를 만족하면서 비주요 속성 간의 이행적 종속을 제거해야 한다. A→B, B→C인 경우 A→C를 제거한다.', true),
(3098, 1088, '모든 결정자가 후보키여야 한다', 'BCNF의 조건이다.', false),

-- 문제 1089
(3099, 1089, 'BCNF는 제1정규형과 동일하다', 'BCNF는 3NF보다 강한 조건이다.', false),
(3100, 1089, 'BCNF는 모든 결정자가 후보키여야 한다', 'BCNF는 3NF를 만족하면서 모든 함수 종속에서 결정자가 후보키여야 한다. 3NF보다 엄격한 조건이다.', true),
(3101, 1089, 'BCNF는 제2정규형보다 약한 조건이다', 'BCNF는 3NF보다 강한 조건이다.', false),
(3102, 1089, 'BCNF는 부분 함수 종속만 제거한다', 'BCNF는 모든 결정자가 후보키여야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (311, 1084, '원자값, 원자성, atomic value, atomicity', '각 속성이 더 이상 분리할 수 없는 하나의 값만 가져야 하는 특성을 원자값 또는 원자성이라고 한다. 제1정규형의 핵심 조건이다.'),
       (312, 1087, '부분, 부분적, partial', '복합키의 일부 속성에만 종속되는 것을 부분 함수 종속이라고 한다. 제2정규형은 부분 함수 종속을 제거한다.');


-- Lesson 3: 정규화 과정 (ID: 157)
INSERT INTO lesson (id, title, unit_id)
VALUES (157, '정규화 과정', 53);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1090, 157, '다음 중 정규화 과정의 순서로 올바른 것은?', '정규화는 단계적으로 진행된다.', 'OBJECTIVE'),
       (1091, 157, '빈칸에 들어갈 용어를 작성하시오.', 'A → B 관계에서 A를 ___, B를 종속자라고 한다.', 'SUBJECTIVE'),
       (1092, 157, '다음 중 함수적 종속(Functional Dependency)의 표기로 올바른 것은?', '함수적 종속은 속성 간의 관계를 나타낸다.', 'OBJECTIVE'),
       (1093, 157, '다음 테이블을 제1정규형으로 변환할 때 올바른 방법은?', '학생(학번, 이름, 수강과목) 테이블에서 수강과목이 ''수학, 영어''처럼 저장되어 있다.', 'OBJECTIVE'),
       (1094, 157, '빈칸에 들어갈 정규형을 작성하시오.', '부분 함수 종속을 제거하면 ___에 도달한다.', 'SUBJECTIVE'),
       (1095, 157, '다음 중 이행적 함수 종속의 예시로 올바른 것은?', '이행적 종속은 A→B, B→C 관계를 의미한다.', 'OBJECTIVE'),
       (1096, 157, '다음 중 반정규화(Denormalization)가 필요한 경우는?', '정규화가 항상 최선은 아니다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1090
(3103, 1090, '1NF → 3NF → 2NF → BCNF', '순서가 잘못되었다.', false),
(3104, 1090, '1NF → 2NF → 3NF → BCNF', '정규화는 제1정규형부터 시작하여 제2정규형, 제3정규형, BCNF 순으로 진행된다. 각 단계는 이전 단계를 만족해야 한다.', true),
(3105, 1090, '2NF → 1NF → BCNF → 3NF', '순서가 잘못되었다.', false),
(3106, 1090, 'BCNF → 3NF → 2NF → 1NF', '역순이다.', false),

-- 문제 1092
(3107, 1092, 'A ← B', '화살표 방향이 반대이다.', false),
(3108, 1092, 'A → B', 'A → B는 A가 B를 함수적으로 결정한다는 의미이다. A 값이 정해지면 B 값이 유일하게 결정된다.', true),
(3109, 1092, 'A = B', '등호는 함수적 종속을 나타내지 않는다.', false),
(3110, 1092, 'A + B', '덧셈 기호는 함수적 종속과 무관하다.', false),

-- 문제 1093
(3111, 1093, '학생(학번, 이름, 수강과목1, 수강과목2, 수강과목3)', '컬럼을 추가하는 것은 1NF 해결 방법이 아니다.', false),
(3112, 1093, '학생(학번, 이름), 수강(학번, 과목)', '다중값 속성을 별도 테이블로 분리하여 각 수강 과목을 별도 행으로 저장한다. 이것이 1NF를 만족하는 방법이다.', true),
(3113, 1093, '학생(학번, 이름, 수강과목) - 그대로 유지', '다중값이 있으면 1NF를 위반한다.', false),
(3114, 1093, '학생(학번), 학생정보(이름, 수강과목)', '수강과목의 다중값 문제를 해결하지 못한다.', false),

-- 문제 1095
(3115, 1095, '학번 → 이름', '직접 종속이다.', false),
(3116, 1095, '학번 → 학과코드, 학과코드 → 학과명', '학번이 학과코드를 결정하고, 학과코드가 학과명을 결정한다. 학번 → 학과명의 이행적 종속이 발생한다.', true),
(3117, 1095, '학번, 과목코드 → 성적', '복합키 종속이다.', false),
(3118, 1095, '주민번호 → 이름', '직접 종속이다.', false),

-- 문제 1096
(3119, 1096, '데이터 무결성을 강화하기 위해', '정규화가 무결성을 강화한다.', false),
(3120, 1096, '조회 성능이 크게 저하되어 개선이 필요한 경우', '과도한 정규화로 조인이 많아지면 조회 성능이 저하될 수 있다. 이 경우 의도적으로 반정규화하여 성능을 개선할 수 있다.', true),
(3121, 1096, '이상 현상을 발생시키기 위해', '반정규화는 성능 개선이 목적이다.', false),
(3122, 1096, '테이블을 더 분리하기 위해', '반정규화는 테이블을 합치거나 중복을 허용한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (313, 1091, '결정자, determinant', 'A → B 관계에서 A를 결정자, B를 종속자라고 한다. 결정자는 다른 속성의 값을 유일하게 결정하는 속성이다.'),
       (314, 1094, '제2정규형, 2NF', '부분 함수 종속을 제거하면 제2정규형에 도달한다. 모든 비주요 속성이 기본키에 완전 함수 종속되어야 한다.');
	
-- Chapter: 데이터베이스 (id: 4), Unit: 트랜잭션 (id: 54)

-- Lesson 1: 트랜잭션 기초 (ID: 158)
INSERT INTO lesson (id, title, unit_id)
VALUES (158, '트랜잭션 기초', 54);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1097, 158, '다음 중 트랜잭션(Transaction)에 대한 설명으로 올바른 것은?', '트랜잭션은 데이터베이스의 상태를 변화시키는 작업의 단위이다.', 'OBJECTIVE'),
       (1098, 158, '빈칸에 들어갈 약어를 작성하시오.', '트랜잭션의 네 가지 특성을 ___라고 한다.', 'SUBJECTIVE'),
       (1099, 158, '다음 중 트랜잭션의 ACID 특성이 아닌 것은?', 'ACID는 트랜잭션이 보장해야 하는 네 가지 특성이다.', 'OBJECTIVE'),
       (1100, 158, '다음 중 원자성(Atomicity)의 의미로 올바른 것은?', '원자성은 트랜잭션의 기본 특성 중 하나이다.', 'OBJECTIVE'),
       (1101, 158, '빈칸에 들어갈 용어를 작성하시오.', '트랜잭션이 성공적으로 완료되었음을 확정하는 명령어는 ___이다.', 'SUBJECTIVE'),
       (1102, 158, '다음 중 일관성(Consistency)의 의미로 올바른 것은?', '일관성은 데이터베이스의 무결성을 보장한다.', 'OBJECTIVE'),
       (1103, 158, '다음 SQL 명령어의 역할은?', 'BEGIN;\nUPDATE accounts SET balance = balance - 100 WHERE id = 1;\nUPDATE accounts SET balance = balance + 100 WHERE id = 2;\nCOMMIT;', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1097
(3123, 1097, '트랜잭션은 데이터를 조회만 하는 단위이다', '트랜잭션은 조회뿐만 아니라 삽입, 수정, 삭제를 포함한다.', false),
(3124, 1097, '트랜잭션은 하나 이상의 SQL 문을 논리적 작업 단위로 묶은 것이다', '트랜잭션은 데이터베이스의 상태를 변화시키는 하나 이상의 작업을 논리적으로 하나의 단위로 처리한다. 모두 성공하거나 모두 실패한다.', true),
(3125, 1097, '트랜잭션은 항상 자동으로 커밋된다', '명시적으로 COMMIT 또는 ROLLBACK 해야 한다.', false),
(3126, 1097, '트랜잭션은 테이블을 생성하는 단위이다', 'CREATE TABLE이 테이블을 생성한다.', false),

-- 문제 1099
(3127, 1099, 'Atomicity(원자성)', '원자성은 ACID 특성 중 하나이다.', false),
(3128, 1099, 'Consistency(일관성)', '일관성은 ACID 특성 중 하나이다.', false),
(3129, 1099, 'Isolation(격리성)', '격리성은 ACID 특성 중 하나이다.', false),
(3130, 1099, 'Availability(가용성)', '가용성은 ACID 특성이 아니다. ACID는 Atomicity, Consistency, Isolation, Durability이다.', true),

-- 문제 1100
(3131, 1100, '여러 트랜잭션이 동시에 실행되어도 독립적으로 동작한다', '격리성의 의미이다.', false),
(3132, 1100, '트랜잭션의 모든 연산이 완전히 수행되거나 전혀 수행되지 않아야 한다', '원자성은 All or Nothing 원칙이다. 트랜잭션의 모든 작업이 성공하면 COMMIT, 하나라도 실패하면 ROLLBACK하여 전체를 취소한다.', true),
(3133, 1100, '트랜잭션 완료 후 결과가 영구적으로 저장된다', '지속성의 의미이다.', false),
(3134, 1100, '트랜잭션 실행 전후 데이터베이스가 일관된 상태를 유지한다', '일관성의 의미이다.', false),

-- 문제 1102
(3135, 1102, '트랜잭션이 모두 성공하거나 모두 실패해야 한다', '원자성의 의미이다.', false),
(3136, 1102, '트랜잭션 실행 전후로 데이터베이스가 유효한 상태를 유지해야 한다', '일관성은 트랜잭션이 실행되기 전과 후에 데이터베이스의 모든 무결성 제약조건을 만족해야 한다는 특성이다.', true),
(3137, 1102, '여러 트랜잭션이 독립적으로 실행되어야 한다', '격리성의 의미이다.', false),
(3138, 1102, '트랜잭션 결과가 영구적으로 저장되어야 한다', '지속성의 의미이다.', false),

-- 문제 1103
(3139, 1103, '계좌 1번의 잔액만 감소시킨다', '두 개의 UPDATE가 모두 실행된다.', false),
(3140, 1103, '계좌 1번에서 100을 차감하고 계좌 2번에 100을 추가하는 이체 작업을 하나의 트랜잭션으로 처리한다', 'BEGIN으로 트랜잭션을 시작하고, 두 개의 UPDATE를 수행한 후 COMMIT으로 확정한다. 하나의 논리적 작업을 원자적으로 처리한다.', true),
(3141, 1103, '두 계좌의 잔액을 모두 삭제한다', 'UPDATE로 잔액을 수정한다.', false),
(3142, 1103, '트랜잭션을 취소한다', 'COMMIT으로 트랜잭션을 확정한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (315, 1098, 'ACID', '트랜잭션의 네 가지 특성인 Atomicity(원자성), Consistency(일관성), Isolation(격리성), Durability(지속성)의 앞글자를 따서 ACID라고 한다.'),
       (316, 1101, 'COMMIT', 'COMMIT은 트랜잭션의 모든 작업을 확정하여 데이터베이스에 영구적으로 반영하는 명령어이다.');


-- Lesson 2: 트랜잭션 제어 (ID: 159)
INSERT INTO lesson (id, title, unit_id)
VALUES (159, '트랜잭션 제어', 54);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1104, 159, '다음 중 ROLLBACK의 역할로 올바른 것은?', 'ROLLBACK은 트랜잭션 제어 명령어이다.', 'OBJECTIVE'),
       (1105, 159, '빈칸에 들어갈 키워드를 작성하시오.', 'BEGIN;\nUPDATE students SET grade = 4;\n___; -- 트랜잭션 취소', 'SUBJECTIVE'),
       (1106, 159, '다음 중 SAVEPOINT의 역할로 올바른 것은?', 'SAVEPOINT는 트랜잭션 내에서 특정 지점을 표시한다.', 'OBJECTIVE'),
       (1107, 159, '다음 SQL 명령어의 실행 결과는?', 'BEGIN;\nINSERT INTO students VALUES (1, ''홍길동'');\nSAVEPOINT sp1;\nINSERT INTO students VALUES (2, ''김철수'');\nROLLBACK TO sp1;\nCOMMIT;', 'OBJECTIVE'),
       (1108, 159, '빈칸에 들어갈 명령어를 작성하시오.', 'BEGIN;\nDELETE FROM students WHERE id = 1;\n___ sp1; -- 특정 지점 저장', 'SUBJECTIVE'),
       (1109, 159, '다음 중 자동 커밋(Autocommit)에 대한 설명으로 올바른 것은?', '자동 커밋은 데이터베이스의 기본 동작 방식이다.', 'OBJECTIVE'),
       (1110, 159, '다음 중 트랜잭션 격리 수준과 관계없는 것은?', '격리 수준은 동시성 제어와 관련이 있다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1104
(3143, 1104, '트랜잭션을 확정한다', 'COMMIT이 트랜잭션을 확정한다.', false),
(3144, 1104, '트랜잭ション의 모든 변경 사항을 취소하고 이전 상태로 되돌린다', 'ROLLBACK은 트랜잭션의 모든 작업을 취소하고 트랜잭션 시작 이전 상태로 되돌린다.', true),
(3145, 1104, '트랜잭션을 시작한다', 'BEGIN이 트랜잭션을 시작한다.', false),
(3146, 1104, '특정 지점을 저장한다', 'SAVEPOINT가 특정 지점을 저장한다.', false),

-- 문제 1106
(3147, 1106, '트랜잭션을 완전히 취소한다', 'ROLLBACK이 트랜잭션을 취소한다.', false),
(3148, 1106, '트랜잭션 내에서 중간 지점을 표시하여 부분 롤백을 가능하게 한다', 'SAVEPOINT는 트랜잭션 내에서 특정 지점을 표시한다. ROLLBACK TO SAVEPOINT로 해당 지점까지만 되돌릴 수 있다.', true),
(3149, 1106, '트랜잭션을 확정한다', 'COMMIT이 트랜잭션을 확정한다.', false),
(3150, 1106, '데이터를 백업한다', 'SAVEPOINT는 백업 기능이 아니다.', false),

-- 문제 1107
(3151, 1107, '두 학생 모두 삽입된다', 'sp1까지 롤백하므로 두 번째 삽입은 취소된다.', false),
(3152, 1107, '홍길동만 삽입된다', 'SAVEPOINT sp1 이후의 작업만 취소되므로 첫 번째 INSERT는 유지되고 두 번째 INSERT는 취소된다. COMMIT으로 확정한다.', true),
(3153, 1107, '김철수만 삽입된다', '첫 번째 삽입이 유지된다.', false),
(3154, 1107, '아무것도 삽입되지 않는다', 'sp1 이전의 작업은 유지된다.', false),

-- 문제 1109
(3155, 1109, '자동 커밋은 항상 비활성화되어 있다', '데이터베이스마다 기본 설정이 다르다.', false),
(3156, 1109, '자동 커밋이 활성화되면 각 SQL 문이 자동으로 커밋된다', '자동 커밋 모드에서는 각 SQL 문이 실행 후 자동으로 COMMIT된다. 명시적 트랜잭션 제어가 필요하면 자동 커밋을 비활성화해야 한다.', true),
(3157, 1109, '자동 커밋은 ROLLBACK을 불가능하게 만든다', '명시적 트랜잭션에서는 ROLLBACK 가능하다.', false),
(3158, 1109, '자동 커밋은 성능을 저하시킨다', '자동 커밋 자체는 성능과 직접적 관련이 없다.', false),

-- 문제 1110
(3159, 1110, 'READ UNCOMMITTED', 'READ UNCOMMITTED는 격리 수준 중 하나이다.', false),
(3160, 1110, 'READ COMMITTED', 'READ COMMITTED는 격리 수준 중 하나이다.', false),
(3161, 1110, 'REPEATABLE READ', 'REPEATABLE READ는 격리 수준 중 하나이다.', false),
(3162, 1110, 'COMMIT DELAY', 'COMMIT DELAY는 격리 수준이 아니다. 격리 수준은 READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (317, 1105, 'ROLLBACK', 'ROLLBACK은 트랜잭션의 모든 변경 사항을 취소하고 트랜잭션 시작 이전 상태로 되돌린다.'),
       (318, 1108, 'SAVEPOINT', 'SAVEPOINT는 트랜잭션 내에서 특정 지점을 표시한다. SAVEPOINT 이름 형식으로 사용한다.');


-- Lesson 3: 격리 수준과 동시성 (ID: 160)
INSERT INTO lesson (id, title, unit_id)
VALUES (160, '격리 수준과 동시성', 54);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1111, 160, '다음 중 격리성(Isolation)의 의미로 올바른 것은?', '격리성은 동시성 제어와 관련이 있다.', 'OBJECTIVE'),
       (1112, 160, '빈칸에 들어갈 용어를 작성하시오.', '커밋되지 않은 데이터를 다른 트랜잭션이 읽는 현상을 ___라고 한다.', 'SUBJECTIVE'),
       (1113, 160, '다음 중 READ UNCOMMITTED 격리 수준의 특징으로 올바른 것은?', 'READ UNCOMMITTED는 가장 낮은 격리 수준이다.', 'OBJECTIVE'),
       (1114, 160, '다음 중 Dirty Read의 설명으로 올바른 것은?', 'Dirty Read는 격리 수준이 낮을 때 발생하는 문제이다.', 'OBJECTIVE'),
       (1115, 160, '빈칸에 들어갈 용어를 작성하시오.', '같은 쿼리를 두 번 실행했을 때 결과가 달라지는 현상을 ___라고 한다.', 'SUBJECTIVE'),
       (1116, 160, '다음 중 SERIALIZABLE 격리 수준의 특징으로 올바른 것은?', 'SERIALIZABLE은 가장 높은 격리 수준이다.', 'OBJECTIVE'),
       (1117, 160, '다음 중 Phantom Read의 설명으로 올바른 것은?', 'Phantom Read는 격리 수준과 관련된 현상이다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1111
(3163, 1111, '트랜잭션이 모두 성공하거나 모두 실패해야 한다', '원자성의 의미이다.', false),
(3164, 1111, '동시에 실행되는 트랜잭션들이 서로 영향을 주지 않아야 한다', '격리성은 여러 트랜잭션이 동시에 실행되어도 각 트랜잭션이 독립적으로 실행되는 것처럼 보장한다. 한 트랜잭션의 중간 결과가 다른 트랜잭션에 영향을 주지 않는다.', true),
(3165, 1111, '트랜잭션 결과가 영구적으로 저장되어야 한다', '지속성의 의미이다.', false),
(3166, 1111, '데이터베이스가 일관된 상태를 유지해야 한다', '일관성의 의미이다.', false),

-- 문제 1113
(3167, 1113, '가장 높은 격리 수준으로 모든 문제를 방지한다', 'SERIALIZABLE이 가장 높은 격리 수준이다.', false),
(3168, 1113, '커밋되지 않은 데이터를 읽을 수 있어 Dirty Read가 발생한다', 'READ UNCOMMITTED는 커밋되지 않은 변경 사항도 읽을 수 있다. Dirty Read, Non-Repeatable Read, Phantom Read 모두 발생 가능하다.', true),
(3169, 1113, 'Dirty Read를 완전히 방지한다', 'READ UNCOMMITTED는 Dirty Read를 방지하지 못한다.', false),
(3170, 1113, '가장 안전하지만 성능이 가장 느리다', 'READ UNCOMMITTED는 가장 빠르지만 안전하지 않다.', false),

-- 문제 1114
(3171, 1114, '같은 데이터를 두 번 읽었을 때 결과가 다른 현상', 'Non-Repeatable Read의 설명이다.', false),
(3172, 1114, '커밋되지 않은 데이터를 읽는 현상', 'Dirty Read는 다른 트랜잭션이 수정했지만 아직 커밋하지 않은 데이터를 읽는 현상이다. 해당 트랜잭션이 롤백되면 잘못된 데이터를 읽게 된다.', true),
(3173, 1114, '없던 데이터가 나타나는 현상', 'Phantom Read의 설명이다.', false),
(3174, 1114, '데드락이 발생하는 현상', 'Dirty Read와 데드락은 다른 개념이다.', false),

-- 문제 1116
(3175, 1116, '커밋되지 않은 데이터를 읽을 수 있다', 'READ UNCOMMITTED의 특징이다.', false),
(3176, 1116, '가장 높은 격리 수준으로 모든 동시성 문제를 방지한다', 'SERIALIZABLE은 트랜잭션을 순차적으로 실행하는 것처럼 동작하여 Dirty Read, Non-Repeatable Read, Phantom Read를 모두 방지한다. 가장 안전하지만 성능이 가장 낮다.', true),
(3177, 1116, 'Phantom Read를 방지하지 못한다', 'SERIALIZABLE은 Phantom Read를 방지한다.', false),
(3178, 1116, '가장 빠른 성능을 제공한다', 'READ UNCOMMITTED가 가장 빠르다.', false),

-- 문제 1117
(3179, 1117, '커밋되지 않은 데이터를 읽는 현상', 'Dirty Read의 설명이다.', false),
(3180, 1117, '같은 데이터를 두 번 읽었을 때 값이 변경된 현상', 'Non-Repeatable Read의 설명이다.', false),
(3181, 1117, '같은 쿼리를 두 번 실행했을 때 없던 행이 나타나거나 있던 행이 사라지는 현상', 'Phantom Read는 한 트랜잭션 내에서 같은 쿼리를 실행했을 때 다른 트랜잭션의 INSERT나 DELETE로 인해 결과 집합이 달라지는 현상이다.', true),
(3182, 1117, '데드락이 발생하는 현상', 'Phantom Read와 데드락은 다른 개념이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (319, 1112, 'Dirty Read, 더티 리드', '커밋되지 않은 데이터를 다른 트랜잭션이 읽는 현상을 Dirty Read라고 한다. 해당 트랜잭션이 롤백되면 잘못된 데이터를 읽게 된다.'),
       (320, 1115, 'Non-Repeatable Read, 반복 불가능한 읽기', '같은 쿼리를 두 번 실행했을 때 다른 트랜잭션의 수정으로 인해 결과가 달라지는 현상을 Non-Repeatable Read라고 한다.');
       
-- Chapter: 데이터베이스 (id: 4), Unit: 인덱스 (id: 55)

-- Lesson 1: 인덱스 기초 (ID: 161)
INSERT INTO lesson (id, title, unit_id)
VALUES (161, '인덱스 기초', 55);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1118, 161, '다음 중 인덱스(Index)에 대한 설명으로 올바른 것은?', '인덱스는 데이터 검색 속도를 향상시키는 데이터베이스 객체이다.', 'OBJECTIVE'),
       (1119, 161, '빈칸에 들어갈 키워드를 작성하시오.', '___ INDEX idx_name ON students(name); -- 인덱스 생성', 'SUBJECTIVE'),
       (1120, 161, '다음 중 인덱스의 장점으로 올바르지 않은 것은?', '인덱스는 조회 성능을 향상시키지만 단점도 있다.', 'OBJECTIVE'),
       (1121, 161, '다음 SQL 명령어의 역할은?', 'CREATE INDEX idx_student_name ON students(name);', 'OBJECTIVE'),
       (1122, 161, '빈칸에 들어갈 용어를 작성하시오.', '인덱스는 책의 ___와 같은 역할을 한다.', 'SUBJECTIVE'),
       (1123, 161, '다음 중 인덱스가 필요한 경우로 올바른 것은?', '인덱스는 적절한 상황에서 사용해야 효과적이다.', 'OBJECTIVE'),
       (1124, 161, '다음 중 인덱스의 단점으로 올바른 것은?', '인덱스는 장점과 함께 단점도 고려해야 한다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1118
(3183, 1118, '인덱스는 데이터를 물리적으로 저장한다', '인덱스는 데이터의 위치 정보를 저장한다.', false),
(3184, 1118, '인덱스는 검색 속도를 향상시키기 위한 별도의 자료구조이다', '인덱스는 테이블의 검색 속도를 높이기 위해 컬럼 값과 해당 레코드의 주소를 키-값 쌍으로 저장하는 자료구조이다.', true),
(3185, 1118, '인덱스는 모든 쿼리의 성능을 향상시킨다', '인덱스는 조회 성능은 향상시키지만 삽입, 수정, 삭제 성능은 저하시킬 수 있다.', false),
(3186, 1118, '인덱스는 테이블과 동일한 개념이다', '인덱스와 테이블은 서로 다른 객체이다.', false),

-- 문제 1120
(3187, 1120, '검색 속도가 향상된다', '인덱스의 주요 장점이다.', false),
(3188, 1120, 'WHERE 절의 조회 성능이 개선된다', '인덱스는 조건 검색 성능을 향상시킨다.', false),
(3189, 1120, 'ORDER BY 성능이 향상된다', '인덱스는 정렬된 상태로 저장되어 ORDER BY 성능이 향상된다.', false),
(3190, 1120, '데이터 삽입 속도가 향상된다', '인덱스는 삽입 시 인덱스도 업데이트해야 하므로 삽입 속도가 저하된다. 이것은 단점이다.', true),

-- 문제 1121
(3191, 1121, 'students 테이블의 name 컬럼에 인덱스를 생성한다', 'CREATE INDEX로 name 컬럼에 idx_student_name이라는 인덱스를 생성한다. 이름으로 검색하는 쿼리의 성능이 향상된다.', true),
(3192, 1121, 'students 테이블을 삭제한다', 'DROP TABLE이 테이블을 삭제한다.', false),
(3193, 1121, 'name 컬럼을 삭제한다', 'ALTER TABLE ... DROP COLUMN이 컬럼을 삭제한다.', false),
(3194, 1121, 'students 테이블의 데이터를 조회한다', 'SELECT가 데이터를 조회한다.', false),

-- 문제 1123
(3195, 1123, '테이블의 데이터가 매우 적을 때', '데이터가 적으면 인덱스 효과가 미미하다.', false),
(3196, 1123, 'WHERE 절에서 자주 사용되는 컬럼일 때', 'WHERE 절에서 자주 조회되는 컬럼에 인덱스를 생성하면 검색 성능이 크게 향상된다.', true),
(3197, 1123, '데이터 수정이 매우 빈번한 컬럼일 때', '수정이 빈번하면 인덱스 유지 비용이 크다.', false),
(3198, 1123, '모든 컬럼에 인덱스를 생성할 때', '불필요한 인덱스는 성능을 저하시킨다.', false),

-- 문제 1124
(3199, 1124, '조회 성능이 향상된다', '이것은 장점이다.', false),
(3200, 1124, '추가 저장 공간이 필요하다', '인덱스는 별도의 저장 공간을 차지한다. 테이블 크기의 약 10% 정도의 추가 공간이 필요하다.', true),
(3201, 1124, '정렬 성능이 향상된다', '이것은 장점이다.', false),
(3202, 1124, '검색 속도가 빨라진다', '이것은 장점이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (321, 1119, 'CREATE', 'CREATE INDEX 문으로 인덱스를 생성한다. CREATE INDEX 인덱스명 ON 테이블명(컬럼명) 형식으로 작성한다.'),
       (322, 1122, '목차, 색인', '인덱스는 책의 목차나 색인과 같은 역할을 한다. 원하는 내용을 빠르게 찾을 수 있도록 돕는다.');


-- Lesson 2: 인덱스 종류 (ID: 162)
INSERT INTO lesson (id, title, unit_id)
VALUES (162, '인덱스 종류', 55);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1125, 162, '다음 중 클러스터형 인덱스(Clustered Index)의 특징으로 올바른 것은?', '클러스터형 인덱스는 데이터의 물리적 정렬과 관련이 있다.', 'OBJECTIVE'),
       (1126, 162, '빈칸에 들어갈 용어를 작성하시오.', '테이블당 ___개의 클러스터형 인덱스만 생성할 수 있다.', 'SUBJECTIVE'),
       (1127, 162, '다음 중 비클러스터형 인덱스(Non-Clustered Index)의 특징으로 올바른 것은?', '비클러스터형 인덱스는 별도의 인덱스 공간을 사용한다.', 'OBJECTIVE'),
       (1128, 162, '다음 SQL 명령어의 역할은?', 'CREATE UNIQUE INDEX idx_email ON users(email);', 'OBJECTIVE'),
       (1129, 162, '빈칸에 들어갈 키워드를 작성하시오.', 'CREATE ___ INDEX idx_unique_id ON students(student_id); -- 중복 불가 인덱스', 'SUBJECTIVE'),
       (1130, 162, '다음 중 복합 인덱스(Composite Index)에 대한 설명으로 올바른 것은?', '복합 인덱스는 여러 컬럼을 조합한 인덱스이다.', 'OBJECTIVE'),
       (1131, 162, '다음 SQL 명령어의 역할은?', 'CREATE INDEX idx_name_grade ON students(name, grade);', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1125
(3203, 1125, '테이블당 여러 개 생성할 수 있다', '클러스터형 인덱스는 테이블당 하나만 생성 가능하다.', false),
(3204, 1125, '데이터가 인덱스 키 순서대로 물리적으로 정렬된다', '클러스터형 인덱스는 테이블 데이터를 인덱스 키 순서대로 물리적으로 정렬하여 저장한다. 일반적으로 기본키에 자동 생성된다.', true),
(3205, 1125, '별도의 인덱스 공간이 필요하다', '비클러스터형 인덱스의 특징이다.', false),
(3206, 1125, '검색 속도가 비클러스터형보다 느리다', '클러스터형 인덱스가 일반적으로 더 빠르다.', false),

-- 문제 1127
(3207, 1127, '데이터를 물리적으로 정렬한다', '클러스터형 인덱스의 특징이다.', false),
(3208, 1127, '별도의 인덱스 페이지에 인덱스 정보를 저장한다', '비클러스터형 인덱스는 데이터와 별도로 인덱스 정보를 저장한다. 테이블당 여러 개 생성 가능하다.', true),
(3209, 1127, '테이블당 하나만 생성할 수 있다', '비클러스터형 인덱스는 여러 개 생성 가능하다.', false),
(3210, 1127, '자동으로 생성된다', '명시적으로 생성해야 한다.', false),

-- 문제 1128
(3211, 1128, 'users 테이블의 email 컬럼에 중복을 허용하지 않는 인덱스를 생성한다', 'UNIQUE INDEX는 중복 값을 허용하지 않는 인덱스이다. email 컬럼에 동일한 값이 들어갈 수 없다.', true),
(3212, 1128, 'email 컬럼을 삭제한다', 'ALTER TABLE ... DROP COLUMN이 컬럼을 삭제한다.', false),
(3213, 1128, 'users 테이블을 생성한다', 'CREATE TABLE이 테이블을 생성한다.', false),
(3214, 1128, '중복된 email을 조회한다', 'SELECT가 데이터를 조회한다.', false),

-- 문제 1130
(3215, 1130, '하나의 컬럼만 사용하는 인덱스이다', '복합 인덱스는 여러 컬럼을 사용한다.', false),
(3216, 1130, '두 개 이상의 컬럼을 조합하여 생성하는 인덱스이다', '복합 인덱스는 여러 컬럼을 조합하여 만든다. 컬럼 순서가 중요하며, 첫 번째 컬럼부터 순서대로 사용해야 인덱스가 효과적이다.', true),
(3217, 1130, '자동으로 생성된다', '명시적으로 생성해야 한다.', false),
(3218, 1130, '성능에 도움이 되지 않는다', '적절히 사용하면 성능이 향상된다.', false),

-- 문제 1131
(3219, 1131, 'name 컬럼에만 인덱스를 생성한다', 'name과 grade 두 컬럼에 복합 인덱스를 생성한다.', false),
(3220, 1131, 'name과 grade 컬럼을 조합한 복합 인덱스를 생성한다', 'name과 grade를 조합한 복합 인덱스를 생성한다. name으로 검색하거나 name과 grade로 함께 검색할 때 효과적이다.', true),
(3221, 1131, '두 개의 별도 인덱스를 생성한다', '하나의 복합 인덱스를 생성한다.', false),
(3222, 1131, '테이블을 생성한다', 'CREATE INDEX는 인덱스를 생성한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (323, 1126, '1, 하나, 한', '클러스터형 인덱스는 데이터를 물리적으로 정렬하므로 테이블당 하나만 생성할 수 있다. 일반적으로 기본키에 자동 생성된다.'),
       (324, 1129, 'UNIQUE', 'UNIQUE INDEX는 중복 값을 허용하지 않는 인덱스이다. 해당 컬럼에 동일한 값이 들어갈 수 없다.');


-- Lesson 3: 인덱스 최적화 (ID: 163)
INSERT INTO lesson (id, title, unit_id)
VALUES (163, '인덱스 최적화', 55);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1132, 163, '다음 중 인덱스가 사용되지 않는 경우는?', '특정 상황에서는 인덱스가 무시될 수 있다.', 'OBJECTIVE'),
       (1133, 163, '빈칸에 들어갈 키워드를 작성하시오.', '___ INDEX idx_name; -- 인덱스 삭제', 'SUBJECTIVE'),
       (1134, 163, '다음 중 복합 인덱스 사용 시 주의사항으로 올바른 것은?', '복합 인덱스는 컬럼 순서가 중요하다.', 'OBJECTIVE'),
       (1135, 163, '다음 SQL 쿼리에서 인덱스가 사용되지 않는 이유는?', 'CREATE INDEX idx_name ON students(name);\nSELECT * FROM students WHERE UPPER(name) = ''홍길동'';', 'OBJECTIVE'),
       (1136, 163, '빈칸에 들어갈 용어를 작성하시오.', '인덱스를 사용하지 않고 테이블 전체를 읽는 것을 ___라고 한다.', 'SUBJECTIVE'),
       (1137, 163, '다음 중 인덱스 성능을 저하시키는 요인으로 올바른 것은?', '인덱스도 관리가 필요하다.', 'OBJECTIVE'),
       (1138, 163, '다음 중 인덱스 설계 시 고려사항으로 올바르지 않은 것은?', '인덱스는 신중하게 설계해야 한다.', 'OBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 1132
(3223, 1132, 'WHERE name = ''홍길동''', '인덱스가 있으면 사용된다.', false),
(3224, 1132, 'WHERE id = 100', '기본키 인덱스가 사용된다.', false),
(3225, 1132, 'WHERE YEAR(birth_date) = 2000', '컬럼에 함수를 적용하면 인덱스를 사용할 수 없다. birth_date 컬럼에 인덱스가 있어도 YEAR 함수로 인해 무시된다.', true),
(3226, 1132, 'WHERE age > 20', '인덱스가 있으면 사용될 수 있다.', false),

-- 문제 1134
(3227, 1134, '컬럼 순서는 중요하지 않다', '복합 인덱스는 컬럼 순서가 매우 중요하다.', false),
(3228, 1134, '첫 번째 컬럼부터 순서대로 사용해야 인덱스가 효과적이다', '복합 인덱스 (A, B, C)는 A, A+B, A+B+C 조건에서 사용되지만 B, C만 사용하면 인덱스가 효과적이지 않다. 첫 번째 컬럼이 포함되어야 한다.', true),
(3229, 1134, '마지막 컬럼만 사용해도 된다', '첫 번째 컬럼부터 순서대로 사용해야 한다.', false),
(3230, 1134, '복합 인덱스는 성능에 도움이 되지 않는다', '적절히 사용하면 성능이 크게 향상된다.', false),

-- 문제 1135
(3231, 1135, 'name 컬럼에 인덱스가 없어서', '인덱스는 생성되어 있다.', false),
(3232, 1135, '컬럼에 함수를 적용하여 인덱스를 사용할 수 없어서', 'UPPER 함수를 name 컬럼에 적용하면 인덱스를 사용할 수 없다. WHERE name = ''홍길동'' 형태로 작성해야 인덱스가 사용된다.', true),
(3233, 1135, 'SELECT *를 사용해서', 'SELECT *는 인덱스 사용 여부와 무관하다.', false),
(3234, 1135, '데이터가 너무 많아서', '데이터 양은 이 경우와 무관하다.', false),

-- 문제 1137
(3235, 1137, '인덱스를 자주 생성한다', '적절한 인덱스 생성은 성능을 향상시킨다.', false),
(3236, 1137, '데이터 수정이 빈번하여 인덱스 재구성이 자주 발생한다', '데이터 삽입, 수정, 삭제가 빈번하면 인덱스도 함께 업데이트되어야 하므로 성능이 저하된다. 단편화도 발생할 수 있다.', true),
(3237, 1137, 'WHERE 절을 사용한다', 'WHERE 절은 인덱스 사용을 유도한다.', false),
(3238, 1137, '적은 양의 데이터를 저장한다', '데이터가 적으면 인덱스 효과가 미미할 뿐이다.', false),

-- 문제 1138
(3239, 1138, 'WHERE 절에 자주 사용되는 컬럼에 인덱스를 생성한다', '올바른 설계 원칙이다.', false),
(3240, 1138, '카디널리티가 높은 컬럼에 인덱스를 생성한다', '중복도가 낮은 컬럼이 인덱스 효과가 좋다.', false),
(3241, 1138, '모든 컬럼에 인덱스를 생성한다', '불필요한 인덱스는 저장 공간을 낭비하고 DML 성능을 저하시킨다. 필요한 컬럼에만 선택적으로 생성해야 한다.', true),
(3242, 1138, '데이터 수정이 적은 컬럼에 인덱스를 생성한다', '올바른 설계 원칙이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (325, 1133, 'DROP', 'DROP INDEX 문으로 인덱스를 삭제한다. DROP INDEX 인덱스명 형식으로 작성한다.'),
       (326, 1136, '풀 테이블 스캔, full table scan, 전체 테이블 스캔', '인덱스를 사용하지 않고 테이블의 모든 행을 처음부터 끝까지 읽는 것을 풀 테이블 스캔이라고 한다. 데이터가 많으면 성능이 크게 저하된다.');
