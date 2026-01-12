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
VALUES (291, 1014, '조인 키,조인키,join key,공통 열,공통열', '두 테이블을 연결할 때 사용하는 공통 컬럼을 조인 키라고 한다. 일반적으로 한 테이블의 외래키와 다른 테이블의 기본키를 조인 키로 사용한다.'),
       (292, 1017, 'join,inner join', '명시적 조인은 JOIN 키워드를 사용하여 테이블을 연결한다. INNER JOIN이 기본이며, INNER는 생략 가능하다.');


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
(2908, 1022, '오른쪽 테이블의 모든 행만 포함된다', 'RIGHT JOIN의 결과이다.', false),
(2909, 1022, '두 테이블의 카테시안 곱이 생성된다', 'CROSS JOIN의 결과이다.', false),
(2910, 1022, '왼쪽 테이블의 모든 행이 포함되고, 매칭되지 않으면 NULL이 표시된다', 'LEFT JOIN은 왼쪽 테이블의 모든 행을 포함하고, 오른쪽 테이블에 매칭되는 데이터가 없으면 NULL로 표시한다.', true),

-- 문제 1023
(2911, 1023, '학생이 없는 학과도 포함하여 모든 학과를 조회한다', 'RIGHT JOIN은 오른쪽 테이블(departments)의 모든 행을 포함한다. 학생이 없는 학과도 조회되며, 학생 정보는 NULL로 표시된다.', true),
(2912, 1023, '모든 학생과 학과 정보를 조회한다', 'RIGHT JOIN이므로 모든 학과가 포함된다.', false),
(2913, 1023, '학과가 없는 학생만 조회한다', 'WHERE d.id IS NULL 조건이 있어야 한다.', false),
(2914, 1023, '학생과 학과가 모두 있는 경우만 조회한다', 'INNER JOIN의 결과이다.', false),

-- 문제 1025
(2915, 1025, '조인 조건이 필수적이다', 'CROSS JOIN은 조인 조건 없이 모든 조합을 생성한다.', false),
(2916, 1025, '두 테이블의 모든 행을 카테시안 곱으로 결합한다', 'CROSS JOIN은 조인 조건 없이 왼쪽 테이블의 각 행을 오른쪽 테이블의 모든 행과 결합한다. m개와 n개 행이면 m×n개 행이 생성된다.', true),
(2917, 1025, '왼쪽 테이블의 행만 포함한다', 'LEFT JOIN의 특징이다.', false),
(2918, 1025, '매칭되는 행만 반환한다', 'INNER JOIN의 특징이다.', false),

-- 문제 1026
(2919, 1026, '동일한 테이블을 두 번 참조하여 조인한다', 'SELF JOIN은 같은 테이블을 마치 두 개의 테이블처럼 사용하여 조인한다. 별칭을 반드시 사용해야 한다.', true),
(2920, 1026, '서로 다른 두 테이블을 조인하는 방법이다', 'SELF JOIN은 같은 테이블을 조인한다.', false),
(2921, 1026, '반드시 CROSS JOIN으로만 구현할 수 있다', 'INNER JOIN, LEFT JOIN 등 다양한 조인 방식으로 구현 가능하다.', false),
(2922, 1026, '별칭을 사용할 수 없다', 'SELF JOIN은 별칭이 필수적이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (293, 1021, 'left,left outer', 'LEFT JOIN은 왼쪽 테이블의 모든 행을 포함하고, 오른쪽 테이블에 매칭되는 데이터가 없으면 NULL로 표시한다. OUTER는 생략 가능하다.'),
       (294, 1024, 'full,full outer', 'FULL OUTER JOIN은 양쪽 테이블의 모든 행을 포함한다. 매칭되지 않는 부분은 NULL로 표시된다. OUTER는 생략 가능하다.');


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
VALUES (295, 1028, 'on', 'SELF JOIN에서도 ON 키워드로 조인 조건을 지정한다. 같은 테이블을 두 번 참조하므로 반드시 서로 다른 별칭을 사용해야 한다.'),
       (296, 1031, 'd.id is null,d.department_id is null', 'LEFT JOIN에서 오른쪽 테이블의 컬럼이 NULL이면 매칭되지 않은 것이다. 학과 테이블의 기본키가 NULL이면 학과가 없는 학생을 의미한다.');
