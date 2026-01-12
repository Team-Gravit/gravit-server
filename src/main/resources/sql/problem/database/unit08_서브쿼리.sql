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
VALUES (285, 993, '스칼라 서브쿼리,scalar subquery,스칼라,scalar', 'SELECT 절에 사용되는 서브쿼리를 스칼라 서브쿼리라고 한다. 스칼라 서브쿼리는 정확히 하나의 값(1행 1컬럼)을 반환해야 한다.'),
       (286, 996, '인라인 뷰,inline view,인라인,inline', 'FROM 절에 사용되는 서브쿼리를 인라인 뷰라고 한다. 인라인 뷰는 임시 테이블처럼 동작하며, 메인 쿼리에서 일반 테이블처럼 사용할 수 있다.');


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
       (288, 1003, 'all', 'ALL 연산자는 서브쿼리가 반환하는 모든 값과 비교하여 모두 만족하면 true를 반환한다. > ALL은 서브쿼리의 모든 값보다 큰 경우를 의미한다.');


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
VALUES (289, 1007, 'as', 'FROM 절의 서브쿼리(인라인 뷰)에는 반드시 별칭(alias)을 지정해야 한다. AS 키워드를 사용하여 별칭을 지정한다. AS는 생략 가능하다.'),
       (290, 1010, 'exists', 'EXISTS는 서브쿼리 결과가 존재하는지 확인한다. 상관 서브쿼리와 함께 사용하여 관련 데이터가 있는 행만 조회할 수 있다. 학생이 존재하는 학과만 조회된다.');
