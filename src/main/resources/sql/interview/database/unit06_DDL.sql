-- Unit: DDL (Unit ID: 47)
-- Chapter: 데이터베이스 (Chapter ID: 4)
-- Topic: DATABASE
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-database-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(231, 'DATABASE', 47, 'HARD', true,
 '이미 학생 데이터가 쌓여 있는 students 테이블에 email 컬럼 UNIQUE 제약 조건을 추가해야 합니다. 테이블을 DROP한 뒤 CREATE로 다시 만드는 방식과 ALTER로 수정하는 방식 중 어느 쪽을 선택하시겠습니까? 각 방식에서 기존 데이터와 테이블 구조가 어떻게 되는지 그 대가와 함께 설명하고, 대신 TRUNCATE를 실행하면 결과가 어떻게 달라지는지도 함께 설명해 주세요.',
 '기존 학생 데이터를 그대로 두어야 하므로 ALTER를 선택합니다. ALTER는 이미 존재하는 테이블의 구조를 수정하는 명령어라서, ALTER TABLE students ADD CONSTRAINT uk_email UNIQUE (email); 처럼 실행하면 테이블과 그 안의 데이터는 유지된 채 제약 조건만 추가됩니다. 반대로 DROP TABLE students; 로 테이블을 지우고 CREATE TABLE students (...) 로 다시 만드는 방식도 결과적으로 UNIQUE 제약이 걸린 테이블을 얻을 수는 있지만, DROP은 데이터베이스나 테이블 같은 객체 자체를 삭제하는 명령어이기 때문에 테이블 객체와 그 안에 쌓여 있던 기존 데이터가 전부 사라진다는 대가를 치릅니다. 게다가 CREATE TABLE 구문에 student_id INT PRIMARY KEY, name VARCHAR(50) NOT NULL, email VARCHAR(100) UNIQUE 같은 컬럼 정의와 제약 조건을 처음부터 다시 작성해야 합니다. TRUNCATE TABLE students; 를 실행하는 경우는 또 다릅니다. TRUNCATE는 테이블의 모든 데이터를 삭제해 초기 상태로 되돌리는 명령어이므로 데이터만 전부 사라질 뿐, 애초에 구조를 수정하는 명령어가 아니어서 email에 UNIQUE 제약을 추가하는 목적은 전혀 달성하지 못합니다. 즉 데이터를 잃지 않으면서 구조만 바꾸는 유일한 선택지는 ALTER입니다. 참고로 테이블이 있는지 확실하지 않은 상태에서 지워야 한다면 DROP TABLE IF EXISTS students; 처럼 존재 여부를 확인한 뒤 삭제하는 구문을 쓸 수 있습니다.',
 'interview-question/231.mp3'),
(232, 'DATABASE', 47, 'NORMAL', true,
 '이미 운영 중인 students 테이블에 phone 컬럼을 추가하고 email 컬럼에 UNIQUE 제약 조건을 걸어야 한다면 어떤 DDL 명령어를 사용하시겠습니까? 실제 구문과 함께, 그 명령어가 CREATE와 역할 면에서 어떻게 다른지 설명해 주세요.',
 '이미 만들어져 있는 테이블의 구조를 바꾸는 작업이므로 ALTER를 사용합니다. 컬럼 추가는 ALTER TABLE students ADD phone VARCHAR(20); 처럼 작성하고, 제약 조건 추가는 ALTER TABLE students ADD CONSTRAINT uk_email UNIQUE (email); 처럼 작성합니다. CREATE는 데이터베이스나 테이블 같은 객체를 새로 생성하는 명령어인 반면, ALTER는 이미 존재하는 테이블의 구조를 수정하는 명령어라는 점에서 역할이 다릅니다. 즉 테이블이 없을 때는 CREATE TABLE로 만들고, 테이블이 이미 있는 상태에서 컬럼이나 제약 조건을 바꿔야 할 때 ALTER를 씁니다. ALTER는 이 밖에도 ALTER TABLE students MODIFY name VARCHAR(100); 으로 기존 컬럼 정의를 수정하거나, ALTER TABLE students DROP CONSTRAINT uk_email; 로 제약 조건을 삭제하는 데에도 사용할 수 있습니다.',
 'interview-question/232.mp3'),
(233, 'DATABASE', 47, 'NORMAL', true,
 'ALTER TABLE students DROP COLUMN phone; 과 DROP TABLE students; 는 둘 다 DROP이라는 키워드를 쓰지만 실행 결과는 다릅니다. 두 구문이 각각 무엇을 삭제하는지 차이를 설명해 주세요.',
 'ALTER TABLE students DROP COLUMN phone; 은 ALTER, 즉 테이블 구조를 수정하는 명령어의 한 형태로 students 테이블에서 phone 컬럼 하나만 삭제합니다. 따라서 실행 후에도 students 테이블 자체와 나머지 컬럼, 데이터는 그대로 남아 있습니다. 반면 DROP TABLE students; 는 DROP, 즉 데이터베이스 객체를 삭제하는 명령어이므로 students 테이블이라는 객체 전체가 사라집니다. 정리하면 앞의 구문은 테이블 안의 컬럼 단위 삭제이고 뒤의 구문은 테이블 객체 단위 삭제라는 점이 차이입니다. 참고로 ALTER에는 ALTER TABLE students RENAME COLUMN name TO n_name; 처럼 컬럼명만 바꾸는 구조 수정도 있습니다.',
 'interview-question/233.mp3'),
(234, 'DATABASE', 47, 'EASY', true,
 'DDL이 무엇인지와 DDL에 속하는 대표적인 명령어들이 각각 어떤 기능을 하는지 설명해 주세요.',
 'DDL은 Data Definition Language의 약자로, 데이터베이스의 구조를 정의하는 언어입니다. 테이블, 인덱스, 스키마 같은 데이터베이스 객체를 생성하고 수정하고 삭제하는 역할을 합니다. 대표적인 명령어로는 CREATE, ALTER, DROP, TRUNCATE가 있습니다. CREATE는 데이터베이스나 테이블 등 객체를 생성하는 명령어이고, ALTER는 테이블 구조를 수정하는 명령어입니다. DROP은 데이터베이스나 테이블 등 객체를 삭제하고, TRUNCATE는 테이블 데이터를 전체 초기화해 초기 상태로 되돌립니다. 예를 들어 CREATE TABLE students (...) 로 테이블을 만들고, ALTER TABLE students ADD phone VARCHAR(20); 으로 컬럼을 추가하며, DROP TABLE students 로 테이블을 지우고, TRUNCATE TABLE students; 로 데이터만 비웁니다.',
 'interview-question/234.mp3'),
(235, 'DATABASE', 47, 'EASY', true,
 'CREATE 명령어는 어떤 역할을 하며, CREATE TABLE로 테이블을 만들 때 컬럼에 지정할 수 있는 제약 조건에는 어떤 것들이 있는지 설명해 주세요.',
 'CREATE는 데이터베이스나 테이블 같은 데이터베이스 객체를 생성하는 명령어입니다. CREATE DATABASE school; 처럼 데이터베이스를 만들 수도 있고, CREATE TABLE students (...); 처럼 테이블을 만들 수도 있습니다. 테이블을 생성할 때 컬럼에는 여러 제약 조건을 지정할 수 있는데, student_id INT PRIMARY KEY처럼 기본 키를 지정하거나, name VARCHAR(50) NOT NULL처럼 값이 비어 있으면 안 되게 하거나, email VARCHAR(100) UNIQUE처럼 중복을 허용하지 않도록 할 수 있습니다. 또 department_id에 대해 FOREIGN KEY (department_id) REFERENCES departments(department_id)처럼 다른 테이블을 참조하는 외래 키를 지정할 수 있고, created_at DATE DEFAULT CURRENT_DATE처럼 기본값을 지정할 수도 있습니다.',
 'interview-question/235.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 231
(1184, 231, '기존 데이터를 보존하려면 ALTER TABLE ADD CONSTRAINT로 UNIQUE 제약을 추가하는 선택을 명시', 'ESSENTIAL', 1),
(1185, 231, 'DROP TABLE 후 CREATE TABLE로 다시 만들면 테이블 객체와 기존 데이터가 사라진다는 대가를 설명', 'ESSENTIAL', 2),
(1186, 231, 'TRUNCATE TABLE은 데이터를 전체 초기화할 뿐 제약 조건을 추가하지 못함을 명시', 'ESSENTIAL', 3),
(1187, 231, 'CREATE TABLE 구문에서 email VARCHAR(100) UNIQUE처럼 컬럼 정의에 제약을 직접 쓰는 방식을 제시', 'SUPPLEMENTARY', 4),
(1188, 231, 'DROP TABLE IF EXISTS처럼 존재 여부를 확인한 뒤 삭제하는 구문을 언급', 'SUPPLEMENTARY', 5),

-- 질문 232
(1189, 232, '기존 테이블의 구조를 수정할 때는 ALTER TABLE을 사용함을 명시', 'ESSENTIAL', 1),
(1190, 232, 'ALTER TABLE students ADD phone 형태로 컬럼을 추가하는 구문을 제시', 'ESSENTIAL', 2),
(1191, 232, 'ALTER TABLE ADD CONSTRAINT로 UNIQUE 제약 조건을 추가하는 구문을 제시', 'ESSENTIAL', 3),
(1192, 232, 'CREATE는 객체 생성이고 ALTER는 테이블 구조 수정이라는 역할 차이를 설명', 'ESSENTIAL', 4),
(1193, 232, 'ALTER TABLE MODIFY로 기존 컬럼 정의를 수정할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(1194, 232, 'ALTER TABLE DROP CONSTRAINT로 제약 조건을 삭제할 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 233
(1195, 233, 'ALTER TABLE DROP COLUMN은 테이블의 특정 컬럼만 삭제함을 설명', 'ESSENTIAL', 1),
(1196, 233, 'DROP TABLE은 테이블이라는 데이터베이스 객체 전체를 삭제함을 설명', 'ESSENTIAL', 2),
(1197, 233, 'DROP COLUMN 실행 후에도 테이블 자체는 남는다는 차이를 명시', 'ESSENTIAL', 3),
(1198, 233, 'ALTER TABLE RENAME COLUMN처럼 컬럼명만 바꾸는 구조 수정도 있음을 언급', 'SUPPLEMENTARY', 4),

-- 질문 234
(1199, 234, 'DDL이 데이터베이스의 구조를 정의하는 언어임을 설명', 'ESSENTIAL', 1),
(1200, 234, '테이블·인덱스·스키마 중 최소 2개를 DDL이 다루는 데이터베이스 객체로 제시', 'ESSENTIAL', 2),
(1201, 234, 'CREATE·ALTER·DROP·TRUNCATE 중 최소 3개를 DDL 명령어로 제시', 'ESSENTIAL', 3),
(1202, 234, 'CREATE는 객체 생성, ALTER는 테이블 구조 수정처럼 명령어별 기능을 최소 2개 서술', 'ESSENTIAL', 4),
(1203, 234, 'DDL의 약자가 Data Definition Language임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 235
(1204, 235, 'CREATE가 데이터베이스나 테이블 등 객체를 생성하는 명령어임을 설명', 'ESSENTIAL', 1),
(1205, 235, 'PRIMARY KEY·NOT NULL·UNIQUE·FOREIGN KEY 중 최소 3개를 컬럼 제약 조건으로 제시', 'ESSENTIAL', 2),
(1206, 235, 'FOREIGN KEY가 REFERENCES로 다른 테이블을 참조하도록 지정함을 명시', 'SUPPLEMENTARY', 3),
(1207, 235, 'DEFAULT CURRENT_DATE처럼 컬럼 기본값을 지정할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(1208, 235, 'CREATE DATABASE school처럼 데이터베이스도 생성할 수 있음을 언급', 'SUPPLEMENTARY', 5);
