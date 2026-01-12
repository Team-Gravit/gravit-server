-- Chapter: 데이터베이스 (id: 4), Unit: 트랜잭션 (id: 54)

-- Lesson 1: 트랜잭션 기초 (ID: 158)
INSERT INTO lesson (id, title, unit_id)
VALUES (158, '트랜잭션 기초', 54);

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (1097, 158, '다음 중 트랜잭션(Transaction)에 대한 설명으로 올바른 것은?', '트랜잭션은 데이터베이스의 상태를 변화시키는 작업의 단위이다.', 'OBJECTIVE'),
       (1098, 158, '빈칸에 들어갈 약어를 작성하시오.', '트랜잭션의 네 가지 특성을 ___라고 한다. (각 속성의 앞글자를 딴 단어)', 'SUBJECTIVE'),
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
(3136, 1102, '여러 트랜잭션이 독립적으로 실행되어야 한다', '격리성의 의미이다.', false),
(3137, 1102, '트랜잭션 결과가 영구적으로 저장되어야 한다', '지속성의 의미이다.', false),
(3138, 1102, '트랜잭션 실행 전후로 데이터베이스가 유효한 상태를 유지해야 한다', '일관성은 트랜잭션이 실행되기 전과 후에 데이터베이스의 모든 무결성 제약조건을 만족해야 한다는 특성이다.', true),

-- 문제 1103
(3139, 1103, '계좌 1번에서 100을 차감하고 계좌 2번에 100을 추가하는 이체 작업을 하나의 트랜잭션으로 처리한다', 'BEGIN으로 트랜잭션을 시작하고, 두 개의 UPDATE를 수행한 후 COMMIT으로 확정한다. 하나의 논리적 작업을 원자적으로 처리한다.', true),
(3140, 1103, '계좌 1번의 잔액만 감소시킨다', '두 개의 UPDATE가 모두 실행된다.', false),
(3141, 1103, '두 계좌의 잔액을 모두 삭제한다', 'UPDATE로 잔액을 수정한다.', false),
(3142, 1103, '트랜잭션을 취소한다', 'COMMIT으로 트랜잭션을 확정한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (315, 1098, 'acid', '트랜잭션의 네 가지 특성인 Atomicity(원자성), Consistency(일관성), Isolation(격리성), Durability(지속성)의 앞글자를 따서 ACID라고 한다.'),
       (316, 1101, 'commit,커밋', 'COMMIT은 트랜잭션의 모든 작업을 확정하여 데이터베이스에 영구적으로 반영하는 명령어이다.');


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
(3144, 1104, '트랜잭션을 시작한다', 'BEGIN이 트랜잭션을 시작한다.', false),
(3145, 1104, '특정 지점을 저장한다', 'SAVEPOINT가 특정 지점을 저장한다.', false),
(3146, 1104, '트랜잭션의 모든 변경 사항을 취소하고 이전 상태로 되돌린다', 'ROLLBACK은 트랜잭션의 모든 작업을 취소하고 트랜잭션 시작 이전 상태로 되돌린다.', true),

-- 문제 1106
(3147, 1106, '트랜잭션 내에서 중간 지점을 표시하여 부분 롤백을 가능하게 한다', 'SAVEPOINT는 트랜잭션 내에서 특정 지점을 표시한다. ROLLBACK TO SAVEPOINT로 해당 지점까지만 되돌릴 수 있다.', true),
(3148, 1106, '트랜잭션을 완전히 취소한다', 'ROLLBACK이 트랜잭션을 취소한다.', false),
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
VALUES (317, 1105, 'rollback,롤백', 'ROLLBACK은 트랜잭션의 모든 변경 사항을 취소하고 트랜잭션 시작 이전 상태로 되돌린다.'),
       (318, 1108, 'savepoint,세이브포인트,save point', 'SAVEPOINT는 트랜잭션 내에서 특정 지점을 표시한다. SAVEPOINT 이름 형식으로 사용한다.');


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
(3168, 1113, 'Dirty Read를 완전히 방지한다', 'READ UNCOMMITTED는 Dirty Read를 방지하지 못한다.', false),
(3169, 1113, '가장 안전하지만 성능이 가장 느리다', 'READ UNCOMMITTED는 가장 빠르지만 안전하지 않다.', false),
(3170, 1113, '커밋되지 않은 데이터를 읽을 수 있어 Dirty Read가 발생한다', 'READ UNCOMMITTED는 커밋되지 않은 변경 사항도 읽을 수 있다. Dirty Read, Non-Repeatable Read, Phantom Read 모두 발생 가능하다.', true),

-- 문제 1114
(3171, 1114, '커밋되지 않은 데이터를 읽는 현상', 'Dirty Read는 다른 트랜잭션이 수정했지만 아직 커밋하지 않은 데이터를 읽는 현상이다. 해당 트랜잭션이 롤백되면 잘못된 데이터를 읽게 된다.', true),
(3172, 1114, '같은 데이터를 두 번 읽었을 때 결과가 다른 현상', 'Non-Repeatable Read의 설명이다.', false),
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
VALUES (319, 1112, 'dirty read,더티 리드', '커밋되지 않은 데이터를 다른 트랜잭션이 읽는 현상을 Dirty Read라고 한다. 해당 트랜잭션이 롤백되면 잘못된 데이터를 읽게 된다.'),
       (320, 1115, 'non-repeatable read,반복 불가능한 읽기,nonrepatable read', '같은 쿼리를 두 번 실행했을 때 다른 트랜잭션의 수정으로 인해 결과가 달라지는 현상을 Non-Repeatable Read라고 한다.');
