-- Unit: SQL 개요와 명령어 분류 (Unit ID: 244)
-- Chapter: 데이터베이스 (Chapter ID: 4)
-- Topic: DATABASE
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-database-unit15 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1399, 'DATABASE', 244, 'HARD', true,
 '운영 테이블의 데이터를 모두 비워야 하는데, 실수하면 되돌려야 할 수도 있습니다. DELETE와 TRUNCATE 중 무엇을 쓰고 왜 그런가요?',
 '되돌릴 가능성이 있다면 DELETE를 써야 합니다. DELETE는 DML로 자동 커밋되지 않으며, 커밋 전이라면 ROLLBACK으로 되돌릴 수 있습니다. 반면 TRUNCATE는 DDL로 분류되어 실행 즉시 자동 커밋되므로 ROLLBACK이 불가능합니다. TRUNCATE는 테이블을 초기 상태로 재생성하는 방식이라 빠르고, DELETE는 행마다 로그를 남기며 삭제하므로 느리지만, 복구 가능성이 필요하다면 DELETE가 맞습니다.',
 'interview-question/1399.mp3'),
(1400, 'DATABASE', 244, 'NORMAL', true,
 'SELECT 절에서 붙인 별칭을 WHERE 절에서는 못 쓰고 ORDER BY 절에서는 쓸 수 있는 이유는 무엇인가요?',
 'SQL은 작성 순서와 실행 순서가 다르기 때문입니다. 논리적 실행 순서는 FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY, LIMIT 순입니다. WHERE가 SELECT보다 먼저 실행되므로 WHERE 시점에는 SELECT에서 부여하는 별칭이 아직 존재하지 않습니다. 반면 ORDER BY는 SELECT 이후에 실행되므로 별칭을 사용할 수 있습니다.',
 'interview-question/1400.mp3'),
(1401, 'DATABASE', 244, 'NORMAL', true,
 'DDL과 DML은 트랜잭션 처리 방식에서 어떻게 다른가요?',
 'DDL은 테이블, 인덱스, 뷰 같은 데이터베이스 객체의 구조를 생성·변경·삭제하는 명령으로, 실행 즉시 자동 커밋되어 ROLLBACK으로 되돌릴 수 없습니다. 반면 DML은 테이블에 저장된 행을 조회·삽입·수정·삭제하는 명령으로, 자동 커밋되지 않으며 COMMIT 전까지 ROLLBACK으로 되돌릴 수 있습니다. DML 작업의 결과는 COMMIT, ROLLBACK 같은 TCL로 트랜잭션 단위로 확정하거나 취소합니다.',
 'interview-question/1401.mp3'),
(1402, 'DATABASE', 244, 'EASY', true,
 'SQL을 선언형 언어라고 부르는 이유는 무엇인가요?',
 'SQL은 데이터를 어떻게 처리할지가 아니라 무엇을 원하는지를 기술하는 언어이기 때문입니다. 데이터를 가져오는 구체적인 절차는 DBMS의 옵티마이저가 결정합니다. C나 Java 같은 절차형 언어와 달리 반복문이나 분기 없이 원하는 결과 집합만 선언합니다. 또한 SQL은 행 하나가 아닌 집합 단위로 데이터를 처리해, WHERE 조건을 만족하는 모든 행이 한 번의 명령으로 처리됩니다.',
 'interview-question/1402.mp3'),
(1403, 'DATABASE', 244, 'EASY', true,
 '트랜잭션에서 SAVEPOINT는 어떤 역할을 하나요?',
 'SAVEPOINT는 트랜잭션 제어어인 TCL 명령어로, 트랜잭션 안에 부분 롤백 지점을 지정합니다. ROLLBACK TO SAVEPOINT로 그 지점까지 롤백하면 지정한 지점 이후의 작업만 취소되고, 그 이전까지의 작업은 남아 있어 COMMIT으로 확정할 수 있습니다.',
 'interview-question/1403.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1399
(6488, 1399, 'DELETE를 선택해야 한다고 제시', 'ESSENTIAL', 1),
(6489, 1399, 'DELETE는 커밋 전이라면 ROLLBACK으로 되돌릴 수 있다고 설명', 'ESSENTIAL', 2),
(6490, 1399, 'TRUNCATE는 ROLLBACK으로 되돌릴 수 없다고 설명', 'ESSENTIAL', 3),
(6491, 1399, 'TRUNCATE는 실행 즉시 자동 커밋된다고 언급', 'SUPPLEMENTARY', 4),
(6492, 1399, 'TRUNCATE가 DELETE보다 속도가 빠르다고 언급', 'SUPPLEMENTARY', 5),
(6493, 1399, 'TRUNCATE가 DDL로 분류된다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1400
(6494, 1400, 'WHERE가 SELECT보다 먼저 실행된다고 설명', 'ESSENTIAL', 1),
(6495, 1400, 'ORDER BY가 SELECT 이후에 실행된다고 설명', 'ESSENTIAL', 2),
(6496, 1400, 'WHERE 실행 시점에는 별칭이 존재하지 않는다고 설명', 'SUPPLEMENTARY', 3),
(6497, 1400, 'SQL은 작성 순서와 실행 순서가 다르다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1401
(6498, 1401, 'DDL은 실행 즉시 자동 커밋된다는 점과 ROLLBACK으로 되돌릴 수 없다는 점 중 최소 1개를 설명', 'ESSENTIAL', 1),
(6499, 1401, 'DML은 자동 커밋되지 않는다는 점과 COMMIT 전까지 ROLLBACK으로 되돌릴 수 있다는 점 중 최소 1개를 설명', 'ESSENTIAL', 2),
(6500, 1401, 'DML 결과는 TCL로 확정하거나 취소한다고 언급', 'SUPPLEMENTARY', 3),
(6501, 1401, 'DDL은 객체 구조를, DML은 행 데이터를 다룬다고 구분', 'SUPPLEMENTARY', 4),

-- 질문 1402
(6502, 1402, '어떻게가 아니라 무엇을 원하는지를 기술한다고 설명', 'ESSENTIAL', 1),
(6503, 1402, '데이터를 가져오는 구체적인 절차는 옵티마이저가 결정한다고 설명', 'ESSENTIAL', 2),
(6504, 1402, '반복문·분기 없이 원하는 결과 집합만 선언한다고 언급', 'SUPPLEMENTARY', 3),
(6505, 1402, 'SQL은 집합 단위로 데이터를 처리한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1403
(6506, 1403, 'SAVEPOINT는 부분 롤백 지점을 지정한다고 설명', 'ESSENTIAL', 1),
(6507, 1403, 'SAVEPOINT로 롤백하면 지정한 지점 이후 작업만 취소된다고 설명', 'ESSENTIAL', 2),
(6508, 1403, 'SAVEPOINT 이전까지의 작업은 COMMIT으로 확정할 수 있다고 언급', 'SUPPLEMENTARY', 3),
(6509, 1403, 'SAVEPOINT가 TCL 명령어에 속한다고 언급', 'SUPPLEMENTARY', 4);
