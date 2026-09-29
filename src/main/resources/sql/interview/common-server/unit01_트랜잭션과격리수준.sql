-- Unit: 트랜잭션과 격리 수준 (Unit ID: 70)
-- Chapter: Server (Chapter ID: 6)
-- Topic: SERVER_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-server-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(346, 'SERVER_COMMON', 70, 'HARD', true,
 '재고를 SELECT로 읽은 뒤 애플리케이션에서 계산한 값으로 UPDATE하는 코드에 동시 요청이 몰리면 어떤 문제가 생기나요? 격리 수준을 SERIALIZABLE로 올리는 대신 어떻게 막는 것이 좋은지 그 이유와 함께 설명해 주세요.',
 '두 트랜잭션이 같은 재고 값 10을 각각 읽고, 애플리케이션에서 10-1을 계산해 둘 다 9로 덮어쓰면 두 번 팔았는데 재고는 1만 줄어듭니다. 이렇게 한쪽의 갱신이 사라지는 현상을 Lost Update라고 하며, 격리 수준 표에는 없지만 실무에서 가장 자주 만나는 문제이고 REPEATABLE READ 같은 스냅샷 격리만으로는 막지 못하는 경우가 많습니다. 그렇다고 SERIALIZABLE로 올리면 대기와 롤백이 급증하므로, 대부분의 서비스는 격리 수준은 기본값으로 두고 정합성이 중요한 지점만 원자적 UPDATE나 락으로 보호합니다. 가장 간단한 방법은 UPDATE product SET stock = stock - 1 WHERE id = 1 AND stock >= 1처럼 DB가 현재 값을 기준으로 원자적으로 갱신하게 하는 것이고, 갱신 행 수가 0이면 재고 부족으로 처리합니다. 재고·잔액처럼 갱신 충돌이 치명적인 경우에는 격리 수준을 올리기보다 원자적 UPDATE나 비관적 락·낙관적 락으로 막습니다.',
 'interview-question/346.mp3'),
(347, 'SERVER_COMMON', 70, 'NORMAL', true,
 'READ COMMITTED와 REPEATABLE READ 격리 수준의 차이는 무엇인가요?',
 '두 격리 수준의 차이는 결국 스냅샷을 언제 찍는가입니다. READ COMMITTED는 SELECT 문장마다 스냅샷을 찍기 때문에, 같은 행을 두 번 읽는 사이에 다른 트랜잭션이 UPDATE하고 커밋하면 값이 달라지는 Non-Repeatable Read가 발생합니다. 반면 REPEATABLE READ는 트랜잭션 시작, 즉 첫 읽기 시점에 스냅샷을 찍어 트랜잭션 내내 같은 스냅샷을 보므로 Non-Repeatable Read가 차단됩니다. 대부분의 현대 DBMS는 이 스냅샷을 MVCC로 구현해 읽기가 쓰기를 기다리지 않게 합니다. 다만 SQL 표준 기준으로 REPEATABLE READ에서도 Phantom Read는 발생할 수 있습니다.',
 'interview-question/347.mp3'),
(348, 'SERVER_COMMON', 70, 'NORMAL', true,
 'MySQL(InnoDB)과 PostgreSQL의 기본 격리 수준은 각각 무엇이고, 이 차이 때문에 DBMS를 바꿀 때 어떤 문제가 생길 수 있나요?',
 'MySQL(InnoDB)의 기본 격리 수준은 REPEATABLE READ이고, PostgreSQL의 기본 격리 수준은 READ COMMITTED입니다. 그래서 같은 코드가 DBMS를 바꾸면 다르게 동작할 수 있습니다. 예를 들어 MySQL에서 잘 되던 한 트랜잭션 안에서 두 번 읽기 로직이 PostgreSQL 기본값에서는 SELECT 문장마다 스냅샷을 찍으므로 두 읽기 사이에 값이 바뀔 수 있습니다. 또 MySQL은 넥스트 키 락과 MVCC로 일반적인 Phantom Read를 대부분 차단하고, PostgreSQL의 REPEATABLE READ는 갱신 충돌 시 could not serialize access 오류를 던지므로 재시도 로직이 필요합니다. MySQL의 기본값이 REPEATABLE READ인 것은 과거 문장 기반 복제에서 소스와 레플리카의 결과를 일치시키기 위한 역사적 이유가 큽니다. 세부 기본값은 버전에 따라 다를 수 있으므로 운영 DB 설정을 직접 확인해야 합니다.',
 'interview-question/348.mp3'),
(349, 'SERVER_COMMON', 70, 'EASY', true,
 '트랜잭션의 ACID 네 가지 성질을 각각 무엇으로 보장하는지 함께 설명해 주세요.',
 '원자성은 트랜잭션이 전부 반영되거나 전부 취소되는 성질로, Undo 로그 기반 롤백으로 보장됩니다. 일관성은 트랜잭션 전후로 PK·FK·CHECK 같은 제약 조건이 항상 만족되는 성질인데, 잔액은 음수가 될 수 없다 같은 업무 규칙은 DB 제약 조건만으로 충분하지 않아 애플리케이션 로직이 함께 지켜야 합니다. 격리성은 동시에 실행돼도 순차 실행한 것과 같은 결과가 나오는 성질로, 격리 수준과 락, MVCC로 보장합니다. 격리성은 성능과 맞바꾸는 조절 가능한 성질입니다. 지속성은 커밋된 결과가 장애가 나도 사라지지 않는 성질로, Redo 로그(WAL)의 디스크 동기화로 보장됩니다.',
 'interview-question/349.mp3'),
(350, 'SERVER_COMMON', 70, 'EASY', true,
 '@Transactional 같은 선언적 트랜잭션에서 트랜잭션 범위를 너무 길게 잡는 것, 같은 클래스 안의 자기 호출, 롤백 규칙 오해는 각각 어떤 문제를 일으키나요?',
 '선언적 트랜잭션은 내부적으로 커넥션을 빌려 autocommit을 끄고, 메서드가 끝나면 커밋이나 롤백을 한 뒤 커넥션을 반납하는 프록시 구조입니다. 먼저 트랜잭션 범위가 너무 길면, 예를 들어 외부 API 호출이나 파일 업로드를 트랜잭션 안에서 하면 커넥션과 락을 오래 점유해 전체 처리량이 떨어집니다. 둘째, 같은 클래스 안에서 this.method()로 자기 호출을 하면 프록시를 거치지 않아 트랜잭션이 적용되지 않습니다. 셋째, 롤백 규칙 오해로, 많은 프레임워크가 기본적으로 런타임 예외만 롤백하고 체크 예외는 커밋하므로 체크 예외가 나도 롤백될 거라 기대하면 안 됩니다. 이 규칙은 프레임워크·버전에 따라 다를 수 있으니 확인이 필요합니다.',
 'interview-question/350.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 346
(1822, 346, '두 트랜잭션이 같은 값을 읽고 덮어써 한쪽 갱신이 사라지는 Lost Update가 발생한다고 설명', 'ESSENTIAL', 1),
(1823, 346, '원자적 UPDATE·비관적 락·낙관적 락 중 최소 1개를 Lost Update 해결책으로 제시', 'ESSENTIAL', 2),
(1824, 346, 'SERIALIZABLE로 올리면 대기·롤백이 급증하는 비용이 따른다고 언급', 'ESSENTIAL', 3),
(1825, 346, 'REPEATABLE READ 같은 스냅샷 격리만으로는 Lost Update를 막지 못하는 경우가 많다고 언급', 'SUPPLEMENTARY', 4),
(1826, 346, 'WHERE stock >= 1 조건으로 갱신 행 수가 0이면 재고 부족으로 처리한다고 언급', 'SUPPLEMENTARY', 5),
(1827, 346, '격리 수준은 기본값으로 두고 정합성이 중요한 지점만 보호하는 방식이 일반적이라고 언급', 'SUPPLEMENTARY', 6),

-- 질문 347
(1828, 347, 'READ COMMITTED는 SELECT 문장마다 스냅샷을 찍는다고 설명', 'ESSENTIAL', 1),
(1829, 347, 'REPEATABLE READ는 트랜잭션 시작(첫 읽기) 시점에 스냅샷을 찍는다고 설명', 'ESSENTIAL', 2),
(1830, 347, 'Non-Repeatable Read가 READ COMMITTED에서는 발생하고 REPEATABLE READ에서는 차단된다고 언급', 'ESSENTIAL', 3),
(1831, 347, '스냅샷을 MVCC로 구현해 읽기가 쓰기를 기다리지 않게 한다고 언급', 'SUPPLEMENTARY', 4),
(1832, 347, 'SQL 표준에서 REPEATABLE READ도 Phantom Read가 발생 가능하다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 348
(1833, 348, 'MySQL(InnoDB)의 기본 격리 수준이 REPEATABLE READ임을 명시', 'ESSENTIAL', 1),
(1834, 348, 'PostgreSQL의 기본 격리 수준이 READ COMMITTED임을 명시', 'ESSENTIAL', 2),
(1835, 348, '한 트랜잭션 안에서 두 번 읽는 로직이 PostgreSQL 기본값에서는 값이 바뀔 수 있다고 설명', 'ESSENTIAL', 3),
(1836, 348, 'MySQL이 넥스트 키 락과 MVCC로 일반적인 Phantom Read를 대부분 차단한다고 언급', 'SUPPLEMENTARY', 4),
(1837, 348, 'PostgreSQL REPEATABLE READ의 could not serialize access 오류에 재시도 로직이 필요하다고 언급', 'SUPPLEMENTARY', 5),
(1838, 348, 'MySQL 기본값이 문장 기반 복제에서 소스와 레플리카 결과를 맞추기 위한 역사적 이유라고 설명', 'SUPPLEMENTARY', 6),

-- 질문 349
(1839, 349, '원자성이 Undo 로그 기반 롤백으로 보장된다고 설명', 'ESSENTIAL', 1),
(1840, 349, '지속성이 Redo 로그(WAL)의 디스크 동기화로 보장된다고 설명', 'ESSENTIAL', 2),
(1841, 349, '격리성을 보장하는 수단으로 격리 수준·락·MVCC 중 최소 1개를 제시', 'ESSENTIAL', 3),
(1842, 349, '일관성은 DB 제약 조건만으로 부족해 애플리케이션 로직이 함께 지켜야 한다고 설명', 'ESSENTIAL', 4),
(1843, 349, '격리성은 성능과 맞바꾸는 조절 가능한 성질이라고 언급', 'SUPPLEMENTARY', 5),

-- 질문 350
(1844, 350, '트랜잭션 범위가 길면 커넥션과 락을 오래 점유한다고 설명', 'ESSENTIAL', 1),
(1845, 350, '같은 클래스 안 자기 호출(self-invocation)은 프록시를 거치지 않아 트랜잭션이 적용되지 않는다고 설명', 'ESSENTIAL', 2),
(1846, 350, '많은 프레임워크가 기본적으로 런타임 예외만 롤백하고 체크 예외는 커밋한다고 설명', 'ESSENTIAL', 3),
(1847, 350, '선언적 트랜잭션이 autocommit을 끄고 끝나면 커밋/롤백 후 커넥션을 반납하는 프록시 구조라고 언급', 'SUPPLEMENTARY', 4),
(1848, 350, '커넥션과 락을 오래 점유하면 전체 처리량이 떨어진다고 언급', 'SUPPLEMENTARY', 5),
(1849, 350, '롤백 규칙은 프레임워크·버전에 따라 다를 수 있어 확인이 필요하다고 언급', 'SUPPLEMENTARY', 6);
