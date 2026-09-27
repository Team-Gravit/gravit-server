-- Unit: DML (Unit ID: 48)
-- Chapter: 데이터베이스 (Chapter ID: 4)
-- Topic: DATABASE
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-database-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(236, 'DATABASE', 48, 'HARD', true,
 'students 테이블에서 특정 학생 한 명의 행만 지우려 했는데 WHERE 절을 빠뜨린 채 DELETE 문을 실행하면 어떤 결과가 되나요? UPDATE 문에서 같은 실수를 했을 때는 어떻게 되는지, 그리고 대상 행을 정확히 한정하려면 SQL을 어떻게 작성해야 하는지 함께 설명해 주세요.',
 'WHERE 절은 조건을 지정해 특정 행만 조회·수정·삭제하는 데 쓰입니다. 따라서 WHERE 절 없이 `DELETE FROM students;`를 실행하면 특정 행이 아니라 students 테이블의 전체 행이 삭제됩니다. 한 명만 지우려면 `DELETE FROM students WHERE student_id = 1;`처럼 조건을 붙여 삭제 대상을 그 행으로 한정해야 합니다. UPDATE도 마찬가지로 `UPDATE students SET email = ''newhong@example.com'' WHERE student_id = 1;`처럼 WHERE 절로 대상을 지정하는데, WHERE 절을 생략하면 수정 대상 행이 한정되지 않습니다. 대상 범위를 넓게 잡아야 할 때는 `WHERE student_id BETWEEN 1 AND 10`처럼 범위 지정을 써서 의도한 행들만 대상에 들어오게 하면 됩니다.'),
(237, 'DATABASE', 48, 'NORMAL', true,
 'students 테이블에 새로운 학생 정보를 추가할 때와 이미 저장된 학생의 이메일을 다른 값으로 바꿀 때는 각각 어떤 DML 명령어를 사용하나요? 두 경우의 SQL 작성 방식이 어떻게 다른지 예시와 함께 설명해 주세요.',
 '새로운 학생 정보를 추가할 때는 테이블에 새로운 행을 삽입하는 INSERT를 쓰고, 이미 저장된 학생의 이메일 값을 바꿀 때는 테이블의 기존 데이터를 수정하는 UPDATE를 씁니다. INSERT는 `INSERT INTO students (student_id, name, email) VALUES (1, ''홍길동'', ''hong@example.com'');`처럼 INSERT INTO 뒤에 테이블명과 컬럼 목록을 적고, VALUES 뒤에 그 컬럼 순서대로 넣을 값을 적습니다. `VALUES (2, ''김철수'', ''kim@example.com''), (3, ''이영희'', ''lee@example.com'');`처럼 값 묶음을 여러 개 나열하면 다중행 삽입이 됩니다. 반면 UPDATE는 `UPDATE students SET email = ''newhong@example.com'' WHERE student_id = 1;`처럼 UPDATE 뒤에 테이블명을 쓰고 SET 절에 바꿀 컬럼과 새 값을 지정합니다. `SET name = ''홍길동수정'', email = ''updated@example.com''`처럼 SET 절에 컬럼을 여러 개 나열하면 다중 컬럼을 한 번에 수정할 수 있습니다. 정리하면 INSERT는 컬럼 목록과 VALUES 값 묶음으로 행 하나를 통째로 만들어 넣고, UPDATE는 SET 절로 이미 있는 행의 특정 컬럼 값만 바꾼다는 점이 다릅니다.'),
(238, 'DATABASE', 48, 'NORMAL', true,
 '조회할 때 특정 행만 가져오는 것과 특정 컬럼만 가져오는 것은 SELECT 문의 어느 부분으로 제어하나요? 두 방식의 차이를 예시와 함께 설명해 주세요.',
 '가져올 컬럼은 SELECT 뒤의 목록으로, 가져올 행은 WHERE 절로 제어합니다. `SELECT * FROM students;`는 전체 컬럼을 조회하고, `SELECT student_id FROM students;`처럼 컬럼명을 적으면 그 컬럼만 조회합니다. 반면 행을 한정하려면 `SELECT * FROM students WHERE student_id = 1;`처럼 WHERE 절에 조건을 지정합니다. WHERE 절은 조건을 지정해 특정 행만 조회·수정·삭제하는 데 사용하는 부분이므로, 컬럼 선택과는 역할이 다릅니다. SELECT 자체는 테이블의 데이터를 조회하는 DML 명령어입니다.'),
(239, 'DATABASE', 48, 'EASY', true,
 'DML이 무엇인지 설명하고, DML에 해당하는 대표 명령어와 각각의 기능을 말씀해 주세요.',
 'DML(Data Manipulation Language)은 데이터베이스에 저장된 데이터를 조작하는 언어로, 테이블의 행을 조회·삽입·수정·삭제하는 역할을 합니다. 대표 명령어는 SELECT, INSERT, UPDATE, DELETE 네 가지입니다. SELECT는 데이터 조회, INSERT는 데이터 삽입, UPDATE는 데이터 수정, DELETE는 데이터 삭제 기능을 담당합니다. 예를 들어 `SELECT * FROM students;`로 조회하고, `INSERT INTO students (student_id, name, email) VALUES (1, ''홍길동'', ''hong@example.com'');`으로 삽입하며, `UPDATE students SET email = ''newhong@example.com'' WHERE student_id = 1;`로 수정하고, `DELETE FROM students WHERE student_id = 1;`로 삭제합니다.'),
(240, 'DATABASE', 48, 'EASY', true,
 'WHERE 절은 어떤 역할을 하나요? WHERE 절에 쓸 수 있는 조건에는 어떤 종류가 있는지 예시와 함께 설명해 주세요.',
 'WHERE 절은 조건을 지정하여 특정 행만 조회, 수정, 삭제하는 데 사용합니다. 조건에는 먼저 `student_id = 1`, `student_id > 5`, `student_id != 3`처럼 =, >, != 연산자로 값의 일치나 대소를 따지는 비교 연산이 있습니다. 또 `student_id BETWEEN 1 AND 10`으로 범위를 지정하고, `name LIKE ''홍%''`, `name LIKE ''%동''`, `name LIKE ''%길%''`처럼 패턴 매칭으로 시작·끝·포함 문자열을 찾으며, `department_id IN (1, 2, 3)`으로 목록 조건을 걸고, `email IS NULL` / `email IS NOT NULL`로 NULL 여부를 조건에 쓸 수 있습니다. 여기에 `department_id = 1 AND name = ''홍길동''`, `department_id = 1 OR department_id = 2`, `NOT department_id = 1`처럼 AND·OR·NOT 논리 연산으로 여러 조건을 결합할 수도 있습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 236
(1209, 236, 'WHERE 절 없는 DELETE FROM students가 테이블 전체 행 삭제임을 명시', 'ESSENTIAL', 1),
(1210, 236, 'DELETE FROM students WHERE student_id = 1처럼 조건을 붙여 대상을 한 행으로 한정함을 제시', 'ESSENTIAL', 2),
(1211, 236, 'UPDATE에서도 WHERE 절을 생략하면 수정 대상 행이 한정되지 않음을 언급', 'ESSENTIAL', 3),
(1212, 236, 'student_id BETWEEN 1 AND 10 같은 범위 지정으로 대상 행을 좁힐 수 있음을 제시', 'SUPPLEMENTARY', 4),
(1213, 236, 'DELETE가 테이블의 행을 삭제하는 명령어임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 237
(1214, 237, '새 행 추가에는 INSERT, 기존 데이터 수정에는 UPDATE를 쓴다는 대응을 명시', 'ESSENTIAL', 1),
(1215, 237, 'INSERT INTO 뒤에 테이블명과 컬럼 목록을, VALUES 뒤에 값을 적음을 설명', 'ESSENTIAL', 2),
(1216, 237, 'UPDATE는 SET 절에 바꿀 컬럼과 새 값을 적음을 설명', 'ESSENTIAL', 3),
(1217, 237, 'SET 절에 여러 컬럼을 나열해 다중 컬럼을 한 번에 수정할 수 있음을 제시', 'SUPPLEMENTARY', 4),
(1218, 237, '다중행 삽입은 VALUES 뒤에 여러 개의 값 묶음을 나열함을 언급', 'SUPPLEMENTARY', 5),
(1219, 237, 'students 테이블에 student_id, name, email 값을 넣는 예시를 제시', 'SUPPLEMENTARY', 6),

-- 질문 238
(1220, 238, '특정 컬럼만 조회할 때는 SELECT 뒤에 student_id처럼 컬럼명을 적음을 설명', 'ESSENTIAL', 1),
(1221, 238, '특정 행만 조회할 때는 WHERE 절에 조건을 지정함을 명시', 'ESSENTIAL', 2),
(1222, 238, 'SELECT * FROM students가 전체 컬럼 조회임을 언급', 'SUPPLEMENTARY', 3),
(1223, 238, 'SELECT가 테이블의 데이터를 조회하는 명령어임을 언급', 'SUPPLEMENTARY', 4),

-- 질문 239
(1224, 239, 'DML이 데이터베이스에 저장된 데이터를 조작하는 언어임을 설명', 'ESSENTIAL', 1),
(1225, 239, 'SELECT·INSERT·UPDATE·DELETE 네 가지를 DML 명령어로 제시', 'ESSENTIAL', 2),
(1226, 239, 'SELECT 조회·INSERT 삽입·UPDATE 수정·DELETE 삭제 기능 대응 중 최소 3개를 명시', 'ESSENTIAL', 3),
(1227, 239, 'DML이 테이블의 행을 대상으로 동작함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 240
(1228, 240, 'WHERE 절이 조건을 지정해 특정 행만 조회·수정·삭제하도록 하는 역할임을 설명', 'ESSENTIAL', 1),
(1229, 240, 'student_id = 1이나 student_id > 5처럼 =, >, != 연산으로 값을 비교', 'ESSENTIAL', 2),
(1230, 240, 'BETWEEN·LIKE·IN·IS NULL 중 최소 2개를 WHERE 조건 종류로 제시', 'ESSENTIAL', 3),
(1231, 240, 'AND·OR·NOT 논리 연산으로 여러 조건을 결합할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(1232, 240, 'name LIKE ''홍%''처럼 패턴 매칭으로 특정 문자열로 시작하는 행을 찾음을 제시', 'SUPPLEMENTARY', 5);
