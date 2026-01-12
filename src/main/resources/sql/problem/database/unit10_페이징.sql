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
VALUES (297, 1035, '페이지 크기,page size,페이지네이션 크기,pagination size', '한 페이지에 표시할 데이터의 개수를 페이지 크기라고 한다. 일반적으로 10, 20, 50, 100 등의 값을 사용한다.'),
       (298, 1038, 'order by,orderby', '페이징을 사용할 때는 일관된 결과를 위해 ORDER BY로 정렬 기준을 명시해야 한다. 정렬하지 않으면 같은 쿼리라도 결과 순서가 달라질 수 있다.');


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
(2968, 1043, 'OFFSET = 페이지 번호 + 페이지 크기', '곱셈으로 계산해야 한다.', false),
(2969, 1043, 'OFFSET = 페이지 크기 / 페이지 번호', '나눗셈이 아닌 곱셈을 사용한다.', false),
(2970, 1043, 'OFFSET = (페이지 번호 - 1) × 페이지 크기', 'OFFSET은 건너뛸 행의 개수이다. 페이지 번호가 1부터 시작한다면 (페이지 번호 - 1) × 페이지 크기로 계산한다.', true),

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
       (1052, 151, '빈칸에 들어갈 조건을 작성하시오.', 'SELECT * FROM students WHERE created_at ___ :last_created_at ORDER BY created_at DESC LIMIT 20; -- 마지막 조회 시각 이후 데이터', 'SUBJECTIVE'),
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
(2997, 1053, '필요한 컬럼만 SELECT 한다', '불필요한 컬럼을 제외하면 데이터 전송량이 줄어든다.', false),
(2998, 1053, '모든 페이지에서 COUNT 쿼리를 매번 실행한다', 'COUNT 쿼리는 비용이 크므로 매번 실행하지 않고 캐싱하거나 필요할 때만 실행하는 것이 좋다.', true),

-- 문제 1054
(2999, 1054, '전체 개수가 자주 변하지 않으면 캐싱을 고려한다', 'COUNT 쿼리는 전체 테이블을 스캔할 수 있어 비용이 크다. 데이터 변경이 적으면 결과를 캐싱하여 재사용하는 것이 효율적이다.', true),
(3000, 1054, 'COUNT 쿼리는 항상 빠르다', '테이블 크기가 크면 COUNT 쿼리도 느려진다.', false),
(3001, 1054, 'COUNT 쿼리는 인덱스를 활용할 수 없다', 'COUNT 쿼리도 인덱스를 활용할 수 있다.', false),
(3002, 1054, 'COUNT 쿼리는 페이징과 무관하다', 'COUNT 쿼리는 전체 페이지 수를 계산하기 위해 사용된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (301, 1049, '커서 기반 페이징,커서,키셋,키셋 페이징,커서 페이징', '마지막으로 조회한 데이터의 키 값을 기준으로 다음 페이지를 조회하는 방식을 커서 기반 페이징 또는 키셋 페이징이라고 한다. OFFSET 방식보다 성능이 우수하다.'),
       (302, 1052, '<', '커서 기반 페이징에서는 마지막으로 조회한 시각(커서)보다 이전 데이터를 조회한다. DESC 정렬이므로 < 연산자를 사용한다.');
