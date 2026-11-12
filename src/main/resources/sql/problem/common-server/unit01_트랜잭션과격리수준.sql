-- Unit: 트랜잭션과 격리 수준 (Unit ID: 70)
-- Chapter: Server (Chapter ID: 6)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (496, 70, 'ACID와 격리 수준별 이상 현상'),
       (654, 70, '격리 동작 차이와 커넥션 점유 장애'),
       (812, 70, '롤백 규칙과 격리 수준 선택 비용');

-- =====================================================
-- Lesson 496: ACID와 격리 수준별 이상 현상
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3155, 496, '아래 로그에서 TX#41의 값 되돌림과 TX#42의 값 보존을 각각 보장하는 메커니즘으로 옳은 것은?', '[장애 로그 요약]

10:02:01  TX#41 시작 → account(id=1) 잔액 10,000원 차감 성공
10:02:02  TX#41 → account(id=2) 입금 시도, CHECK 제약 위반으로 실패
10:02:02  TX#41 ROLLBACK. 이후 조회하니 id=1 잔액은 차감 전 값으로 돌아와 있음
10:02:05  TX#42 COMMIT 완료
10:02:06  서버 전원 차단(정전)
10:02:40  재기동 후 조회. TX#42가 바꾼 값은 그대로 남아 있음', 'OBJECTIVE'),
       (3156, 496, '아래 SQL 표준 매트릭스를 바탕으로 옳지 않은 것은?', '| 격리 수준 | Dirty Read | Non-Repeatable Read | Phantom Read | 구현 방식(일반적) |
|---|---|---|---|---|
| READ UNCOMMITTED | 발생 | 발생 | 발생 | 읽기에 사실상 제어 없음 |
| READ COMMITTED | 차단 | 발생 | 발생 | 문장 단위 스냅샷 |
| REPEATABLE READ | 차단 | 차단 | 발생 가능 | 트랜잭션 단위 스냅샷 |
| SERIALIZABLE | 차단 | 차단 | 차단 | 범위 락 또는 직렬화 충돌 감지 |', 'OBJECTIVE'),
       (3157, 496, '아래 타임라인에서 TX A가 겪은 현상을 막는 방법으로 옳은 것은?', '[같은 트랜잭션 TX A 안에서 실행된 두 조회 · SQL 표준의 격리 수준 정의를 기준으로 판단한다]

```sql
TX A: SELECT COUNT(*) FROM orders WHERE status = ''READY'';   -- 12
TX B:                 INSERT INTO orders(status) VALUES (''READY'');
TX B:                 COMMIT;
TX A: SELECT COUNT(*) FROM orders WHERE status = ''READY'';   -- 13
```', 'OBJECTIVE'),
       (3158, 496, '아래 이관 상황에서 두 조회 값이 달라진 원인으로 옳은 것은?', '한 트랜잭션 안에서 상품 재고를 두 번 조회해 그 차이를 정산 리포트에 적는 배치가 있다. MySQL(InnoDB)에서 1년 넘게 두 조회 값이 어긋난 적이 없었는데, 코드를 그대로 두고 PostgreSQL로 옮기자 두 값이 달라지는 날이 생겼다. 두 환경 모두 격리 수준을 따로 지정하지 않았고, 두 조회 사이에 다른 트랜잭션이 같은 행을 UPDATE하고 커밋한 기록이 남아 있었다.', 'OBJECTIVE'),
       (3159, 496, '아래 재고 로그에서 나타난 문제를 가리키는 용어는?', '[재고 로그 · 같은 초에 들어온 결제 2건]

12:00:00.011  TX#7  SELECT stock FROM product WHERE id = 1   → 10
12:00:00.013  TX#8  SELECT stock FROM product WHERE id = 1   → 10
12:00:00.020  TX#7  UPDATE product SET stock = 9 WHERE id = 1   COMMIT
12:00:00.024  TX#8  UPDATE product SET stock = 9 WHERE id = 1   COMMIT

주문 테이블에는 결제 완료 주문이 2건 쌓였는데, 재고는 10에서 9로 1만 줄어 있었다.', 'SUBJECTIVE'),
       (3160, 496, '아래 코드에서 saveOne의 롤백이 일어나지 않은 원인을 가리키는 용어는?', '아래 코드에서 stockRepository.decrease가 RuntimeException을 던지면, 방금 insert한 주문 행이 지워지지 않고 그대로 남았다. 반면 다른 클래스의 서비스가 saveOne을 직접 호출하는 경로에서는 같은 예외에 주문 행이 정상적으로 사라진다.

```java
@Service
public class OrderService {

    public void placeAll(List<Order> orders) {
        for (Order o : orders) {
            this.saveOne(o);
        }
    }

    @Transactional
    public void saveOne(Order o) {
        orderRepository.insert(o);
        stockRepository.decrease(o.getProductId());
    }
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3155
(8587, 3155, 'TX#41은 CHECK 제약 조건이, TX#42는 PK·FK 제약 조건이 검사해 두 결과를 모두 보장한다.', '제약 조건은 규칙 위반을 잡아 문장을 실패시킬 뿐, 이미 바뀐 값을 되돌리거나 커밋된 값을 디스크에 남기지는 않는다. 되돌림은 Undo 로그, 보존은 Redo 로그의 몫이다.', false),
(8588, 3155, 'TX#41은 Redo 로그로 되돌리고, TX#42는 Undo 로그를 디스크에 동기화해 지킨다.', '두 로그의 역할을 맞바꾼 오개념. Undo는 변경 전 이미지를 남겨 되돌리는 데 쓰고, Redo(WAL)는 커밋된 변경을 재적용해 지속성을 지키는 데 쓴다.', false),
(8589, 3155, 'TX#41은 Undo 로그로 되돌리고, TX#42는 Redo 로그(WAL)를 디스크에 동기화해 지킨다.', '원자성은 변경 전 이미지를 담은 Undo 로그로 롤백해 보장하고, 지속성은 커밋 시점에 Redo 로그를 디스크에 내려써 정전 뒤 재기동 때 재적용할 수 있게 해 보장한다.', true),
(8590, 3155, 'TX#41과 TX#42 모두 격리 수준을 높게 잡아야 보장되고, 낮추면 두 결과가 다 깨진다.', '격리 수준이 조절하는 것은 동시에 도는 트랜잭션끼리 서로의 중간 상태를 얼마나 보느냐다. 원자성·지속성은 격리 수준과 무관하게 로그로 보장된다.', false),

-- 문제 3156
(8591, 3156, 'READ COMMITTED까지 올리면 같은 행을 두 번 읽어도 값이 달라지지 않는다.', '표의 READ COMMITTED 행은 Non-Repeatable Read가 발생으로 남아 있어 거짓이다. 이 수준은 문장 단위 스냅샷이라 두 SELECT 사이에 커밋된 UPDATE가 두 번째 읽기에 그대로 드러난다. 값이 고정되려면 트랜잭션 단위 스냅샷이 필요하다.', true),
(8592, 3156, 'Dirty Read만 막으면 되는 조회라면 가장 느슨한 수준에서 한 단계만 올려도 목적을 이룬다.', '참. 표에서 Dirty Read가 차단으로 바뀌는 첫 지점이 READ COMMITTED다. 그 위 두 수준은 더 막아 주지만 이 목적에는 불필요한 대기·충돌 비용을 더한다.', false),
(8593, 3156, '같은 조건의 조회에서 행 수가 늘어나는 것까지 막으려면 네 단계 중 가장 엄격한 수준을 골라야 한다.', '참. 표에서 Phantom Read가 차단인 행은 SERIALIZABLE뿐이며, 그 구현도 값 비교가 아니라 범위 락이나 직렬화 충돌 감지다.', false),
(8594, 3156, '문장 단위 스냅샷을 쓰는 수준과 트랜잭션 단위 스냅샷을 쓰는 수준은 Dirty Read 차단 여부가 서로 같다.', '참. 두 행 모두 Dirty Read가 차단이다. 스냅샷을 언제 찍느냐는 같은 행을 다시 읽을 때 갈리고, 커밋 전 값을 읽느냐에서는 갈리지 않는다.', false),

-- 문제 3157
(8595, 3157, 'READ COMMITTED로 올리면 막힌다. 커밋되지 않은 값을 읽은 것이 원인이기 때문이다.', 'Dirty Read와 혼동. TX B는 두 번째 조회 전에 COMMIT을 마쳤으므로 TX A가 읽은 것은 커밋된 값이다. 커밋 전 읽기를 막는 처방으로는 해결되지 않는다.', false),
(8596, 3157, 'REPEATABLE READ로 올리면 막힌다. 이미 읽은 행의 값이 바뀐 것이 원인이기 때문이다.', 'Non-Repeatable Read와 혼동. 기존 행의 값은 그대로고 조건에 맞는 행이 하나 늘었다. 표준 정의상 REPEATABLE READ는 이 경우를 차단하지 못한다.', false),
(8597, 3157, '격리 수준으로는 못 막고, 두 조회를 하나의 원자적 UPDATE 문장으로 합쳐야 막힌다.', '원자적 UPDATE는 읽고 계산해 덮어써 갱신이 사라지는 Lost Update의 처방이다. 조회만 하는 이 상황에는 맞지 않고, 여기서는 격리 수준으로 막을 수 있다.', false),
(8598, 3157, 'SERIALIZABLE로 올리면 막힌다. 범위 락이나 직렬화 충돌 감지로 새 행의 끼어듦까지 차단하기 때문이다.', '같은 조건의 두 조회 사이에 커밋된 INSERT가 끼어들어 행 수가 달라진 Phantom Read다. 표준 정의상 SERIALIZABLE에서만 차단되고, 값이 아닌 조건 범위를 지켜야 하므로 범위 락·충돌 감지가 필요하다.', true),

-- 문제 3158
(8599, 3158, 'PostgreSQL은 기본 격리 수준이 READ UNCOMMITTED라 상대가 커밋하기 전 값까지 읽었기 때문이다.', 'PostgreSQL은 READ UNCOMMITTED를 지정해도 READ COMMITTED로 동작해 커밋 전 값을 읽지 않는다. 본문에서도 상대 트랜잭션은 커밋을 마친 뒤였다.', false),
(8600, 3158, 'PostgreSQL은 기본 격리 수준이 READ COMMITTED라 SELECT 문장마다 새 스냅샷을 잡기 때문이다.', 'MySQL(InnoDB) 기본값인 REPEATABLE READ는 트랜잭션 단위 스냅샷이라 두 조회가 같은 값을 본다. PostgreSQL 기본값인 READ COMMITTED는 문장 단위 스냅샷이라 사이에 커밋된 UPDATE가 두 번째 조회에 드러난다.', true),
(8601, 3158, 'PostgreSQL에는 REPEATABLE READ가 없어 트랜잭션이 자동으로 SERIALIZABLE로 승격되기 때문이다.', 'REPEATABLE READ를 제공하지 않는 것은 Oracle 쪽 특징이고 PostgreSQL은 이 수준을 지원한다. 게다가 SERIALIZABLE로 승격됐다면 두 조회 값은 오히려 고정된다.', false),
(8602, 3158, 'MySQL이 같은 조회 결과를 캐시에서 돌려줬을 뿐이고, 두 DBMS의 기본 격리 수준은 서로 같기 때문이다.', '두 조회가 같은 값을 본 것은 캐시가 아니라 트랜잭션 단위 스냅샷 때문이다. 기본 격리 수준도 MySQL은 REPEATABLE READ, PostgreSQL은 READ COMMITTED로 다르다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1008, 3159, '갱신 손실,갱신 유실,갱신 분실,갱신 손실 문제,로스트 업데이트,로스트업데이트,lost update,lostupdate', '두 트랜잭션이 같은 값(10)을 읽고 각자 9를 계산해 덮어썼기 때문에 먼저 커밋한 TX#7의 갱신이 흔적 없이 사라졌다. 결제는 2건인데 재고가 1만 줄어든 것이 그 증거다. 읽은 값이 달라지는 Non-Repeatable Read와 달리 여기서는 읽기가 아니라 쓰기가 덮어써진 것이고, 격리 수준 표의 세 이상 현상 목록에는 아예 없다. REPEATABLE READ의 스냅샷만으로는 막지 못하는 경우가 많아 UPDATE product SET stock = stock - 1 WHERE id = 1 AND stock >= 1 처럼 DB가 현재 값을 기준으로 원자적으로 갱신하게 하거나, 락·버전 컬럼으로 충돌을 잡아야 한다.'),
       (1009, 3160, '자기 호출,자가 호출,자기호출,내부 호출,셀프 인보케이션,self-invocation,self invocation,selfinvocation', '선언적 트랜잭션은 프록시 객체가 대상 빈을 감싸 커밋·롤백을 처리한다. 같은 클래스 안에서 this로 부르면 호출이 프록시를 거치지 않고 원본 객체의 메서드로 바로 들어가므로 saveOne에 붙인 트랜잭션 설정이 아예 적용되지 않는다. 다른 클래스에서 호출한 경로에서는 프록시를 통과해 롤백이 정상 동작한다는 점이 결정적 단서다. 흔히 헷갈리는 롤백 규칙 오해(체크 예외는 커밋된다)와는 구분해야 한다. 여기서 던진 것은 런타임 예외인데도 롤백이 없었으므로 원인은 예외의 종류가 아니라 호출 경로다.');

-- =====================================================
-- Lesson 654: 격리 동작 차이와 커넥션 점유 장애
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4103, 654, '아래 실험 결과를 해석한 것으로 옳은 것은?', '두 DB에 같은 account 테이블을 만들고 아래 순서로 실험했다. 두 DB 모두 격리 수준은 READ COMMITTED이다.

1. TX A: `UPDATE account SET balance = 70 WHERE id = 1;` 실행 (변경 전 balance = 100)
2. TX A가 COMMIT하지 않고 멈춰 있는 동안 TX B: `SELECT balance FROM account WHERE id = 1;` 실행
3. TX A는 1번 실행 30초 뒤 COMMIT

| DB | TX B의 SELECT가 결과를 돌려준 시점 | TX B가 받은 값 |
|---|---|---|
| DB 1 (SQL Server, 온프레미스 설치 기본 설정) | 약 30초 뒤, TX A의 COMMIT 직후 | 70 |
| DB 2 (PostgreSQL, 설치 기본 설정) | 실행 후 3ms | 100 |', 'OBJECTIVE'),
       (4104, 654, '아래 타임라인이 끝난 뒤 stock 값과 두 UPDATE가 갱신한 행 수를 옳게 짝지은 것은?', E'재고가 1개 남은 상품에 주문 두 건이 동시에 들어왔다. 두 트랜잭션의 격리 수준은 READ COMMITTED이다.\n\n```sql\n-- 초기 상태: product(id=1)의 stock = 1\nTX A: UPDATE product SET stock = stock - 1 WHERE id = 1 AND stock >= 1;\nTX B: UPDATE product SET stock = stock - 1 WHERE id = 1 AND stock >= 1;  -- TX A의 행 잠금 때문에 대기\nTX A: COMMIT;\nTX B: -- 대기가 풀려 UPDATE 문장이 끝남\nTX B: COMMIT;\n```', 'OBJECTIVE'),
       (4105, 654, '아래 로그의 오류를 받은 애플리케이션이 이어서 취할 조치로 옳은 것은?', '[포인트 정산 배치 로그 · PostgreSQL]

```
02:00:00.100  TX#301  BEGIN ISOLATION LEVEL REPEATABLE READ
02:00:00.105  TX#301  SELECT point FROM wallet WHERE user_id = 7                → 800
02:00:00.120  TX#301  INSERT INTO settle_log(user_id, amount) VALUES (7, -200)  → 1행
02:00:00.230  TX#302  UPDATE wallet SET point = point + 300 WHERE user_id = 7; COMMIT
02:00:00.310  TX#301  UPDATE wallet SET point = point - 200 WHERE user_id = 7
02:00:00.311  TX#301  ERROR:  could not serialize access due to concurrent update
```', 'OBJECTIVE'),
       (4106, 654, '아래 장애를 줄이기 위한 수정으로 옳은 것은?', '커넥션 풀 최대 크기가 10인 주문 서버에서, 결제 대행사 API 응답이 평소 0.2초에서 8초로 느려진 날 이 메서드와 상관없는 상품 조회 API까지 커넥션을 얻지 못해 타임아웃이 쏟아졌다. 같은 시간대 DB 쿼리의 실행 시간은 모두 10ms 안쪽이었다.

```java
@Transactional
public void pay(Long orderId) {
    Order order = orderRepository.findById(orderId);    // SELECT
    PayResult result = payClient.approve(order);        // 결제 대행사 HTTP 호출
    orderRepository.markPaid(orderId, result.txId());   // UPDATE
}
```', 'OBJECTIVE'),
       (4107, 654, '아래 로그에서 TX#52가 겪은 문제를 가리키는 용어는?', '[쿠폰 잔여 수량 조회 로그]

```
14:10:00.100  TX#51  UPDATE coupon SET remain = 0 WHERE id = 3   (변경 전 remain = 5)
14:10:00.140  TX#52  SELECT remain FROM coupon WHERE id = 3       → 0
14:10:00.142  TX#52  COMMIT, 사용자 화면에 쿠폰 소진 안내 표시
14:10:00.300  TX#51  결제 검증 실패 → ROLLBACK
14:10:00.500  TX#53  SELECT remain FROM coupon WHERE id = 3       → 5
```

※ TX#51은 UPDATE와 ROLLBACK 사이에 다른 명령을 보내지 않았다.', 'SUBJECTIVE'),
       (4108, 654, '아래 조사 기록에서 지켜지지 못한 트랜잭션의 성질을 가리키는 용어는?', '[출금 한도 사고 조사 · 회원 17]

- 출금 정책: 한 회원의 하루 출금 합계는 1,000,000원 이하
- 테이블 정의: withdrawal(id PK, member_id FK, amount NOT NULL)

```
09:00:02  TX#901  출금 400,000원 INSERT → COMMIT
13:10:45  TX#944  출금 400,000원 INSERT → COMMIT
18:31:09  TX#990  출금 400,000원 INSERT → COMMIT
23:59:00  일일 점검 → 회원 17의 당일 출금 합계 1,200,000원
```

- 세 트랜잭션은 몇 시간 간격으로 하나씩 처리됐고, 전후로 회원 17의 데이터를 건드린 다른 트랜잭션은 없었다.
- 세 건 모두 오류 없이 끝났고, 당일 서버 장애나 재시작이 없어 기록이 그대로 남아 있다.
- 출금 API 코드에는 당일 출금 합계를 조회해 한도를 검사하는 부분이 없었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4103
(11115, 4103, 'DB 2는 READ UNCOMMITTED처럼 동작해, 행 잠금을 무시하고 수정 중인 값을 곧바로 읽었다.', '수정 중인 값을 읽었다면 TX B는 70을 받았어야 한다. DB 2가 돌려준 100은 TX A가 바꾸기 전의 커밋된 값이라 커밋 전 값을 읽은 것이 아니다. PostgreSQL은 READ UNCOMMITTED를 지정해도 READ COMMITTED로 동작한다.', false),
(11116, 4103, 'DB 2는 변경 전 행 버전을 따로 남겨 두어, 조회가 행 잠금을 기다리지 않고 커밋된 값을 읽었다.', 'DB 2는 MVCC(다중 버전 동시성 제어)로 UPDATE 중에도 변경 전 버전(100)을 보관한다. 그래서 TX B는 TX A의 잠금이 풀리길 기다리지 않고 자기 스냅샷에 보이는 커밋된 버전을 3ms 만에 읽었다. 읽기가 쓰기를 기다리지 않는 것이 핵심이다.', true),
(11117, 4103, 'DB 1도 격리 수준을 REPEATABLE READ로 올리면, TX B가 기다리지 않고 곧바로 100을 받는다.', '격리 수준을 올리면 스냅샷을 쓰게 된다고 본 오개념. DB 1의 기본 설정은 잠금으로 읽기를 제어해 조회도 공유 잠금을 얻어야 하므로 TX A의 배타 잠금이 풀릴 때까지 기다린다. 잠금 기반에서 수준을 올리면 잠금을 더 오래 쥘 뿐 대기는 사라지지 않는다.', false),
(11118, 4103, 'DB 2에서 TX B가 TX A의 COMMIT 뒤 같은 트랜잭션 안에서 다시 조회해도 100을 받는다.', '트랜잭션 단위 스냅샷과 혼동. READ COMMITTED는 SELECT 문장마다 스냅샷을 새로 찍으므로, TX A가 커밋한 뒤의 두 번째 조회는 70을 읽는다. 첫 조회 값 100이 끝까지 유지되는 것은 REPEATABLE READ일 때다.', false),

-- 문제 4104
(11119, 4104, 'stock = -1 / TX A 1행, TX B 1행', 'TX B의 WHERE 조건이 대기 전에 본 stock = 1로 이미 통과했다고 본 오개념. 대기가 풀린 TX B는 커밋된 최신 행(stock = 0)으로 조건을 다시 확인하므로 stock >= 1에 걸려 차감하지 않고, 재고는 음수로 내려가지 않는다.', false),
(11120, 4104, 'stock = 0 / TX A 1행, TX B 1행', 'SELECT로 읽어 애플리케이션에서 계산한 값을 덮어쓰는 Lost Update 패턴과 혼동. stock = stock - 1은 잠금을 잡은 시점의 현재 값으로 계산되므로, 두 UPDATE가 모두 1행을 갱신했다면 결과는 0이 아니라 -1이어야 한다.', false),
(11121, 4104, 'stock = 1 / TX A 0행, TX B 0행', '같은 행을 동시에 갱신하면 둘 다 취소된다고 본 오개념. 행 잠금은 뒤에 온 TX B를 기다리게 할 뿐이고, 먼저 잠금을 잡은 TX A의 차감은 정상 반영되어 커밋된다.', false),
(11122, 4104, 'stock = 0 / TX A 1행, TX B 0행', '먼저 잠금을 잡은 TX A가 1을 0으로 바꿔 커밋하고, 기다리던 TX B는 최신 값 0으로 stock >= 1을 다시 평가해 한 행도 갱신하지 않는다. 애플리케이션은 갱신 행 수 0을 재고 부족으로 처리하면 초과 판매를 막을 수 있다.', true),

-- 문제 4105
(11123, 4105, '트랜잭션을 롤백하고 BEGIN부터 전체를 다시 실행해, 새 스냅샷에서 point를 읽고 계산한다.', 'REPEATABLE READ는 첫 조회 때 찍은 스냅샷을 끝까지 쓰므로, 그 뒤 TX#302가 커밋한 행을 옛 스냅샷 기준으로 덮어쓸 수 없어 오류를 낸다. 처음부터 다시 실행해야 1,100을 새로 읽고 올바르게 차감하므로 재시도 로직이 필요하다.', true),
(11124, 4105, '같은 트랜잭션 안에서 실패한 UPDATE 문장만 한 번 더 실행해 차감을 마친다.', '오류가 난 문장만 다시 보내면 된다고 본 오개념. PostgreSQL은 오류가 난 트랜잭션을 중단 상태로 두어 ROLLBACK 전까지 이후 명령을 모두 거부한다. 허용되더라도 같은 옛 스냅샷이라 다시 충돌한다.', false),
(11125, 4105, '오류가 난 UPDATE는 건너뛰고 COMMIT을 보내, 먼저 성공한 INSERT만 확정한다.', '문장 단위로 골라 확정할 수 있다고 본 오개념. 중단된 트랜잭션에 COMMIT을 보내면 ROLLBACK으로 처리돼 INSERT도 함께 취소된다. 일부 문장만 남기는 것은 원자성에도 어긋난다.', false),
(11126, 4105, '격리 수준만 SERIALIZABLE로 올려 같은 순서로 실행하면, 오류 없이 차감된다.', '격리 수준을 올리면 충돌이 사라진다고 본 오개념. SERIALIZABLE은 더 엄격해서 같은 순서의 동시 갱신에도 직렬화 오류를 내며, 오히려 재시도가 필요한 경우가 늘어난다.', false),

-- 문제 4106
(11127, 4106, '격리 수준을 SERIALIZABLE로 올려, 다른 요청이 같은 주문 행에 끼어들지 못하게 한다.', '행 충돌을 원인으로 본 오개념. DB 쿼리는 10ms 안쪽으로 끝났고, 문제는 HTTP 응답을 기다리는 8초 동안 커넥션을 쥐고 있는 것이다. SERIALIZABLE은 대기와 롤백을 늘려 점유 시간을 더 길게 만든다.', false),
(11128, 4106, '메서드에 readOnly = true를 붙여, 변경 감지와 플러시를 생략하게 한다.', 'readOnly를 성능 만능 옵션으로 본 오개념. 이 메서드는 UPDATE를 하므로 읽기 전용 대상이 아니고, 붙이더라도 결제 응답을 기다리는 동안 커넥션을 쥐고 있는 구조는 그대로다.', false),
(11129, 4106, '결제 API 호출을 트랜잭션 밖으로 빼고, 조회와 갱신만 각각 짧은 트랜잭션으로 감싼다.', '선언적 트랜잭션은 메서드 시작에 커넥션을 빌려 끝날 때 반납한다. 8초짜리 HTTP 대기가 안에 있으면 동시 요청 10건만으로 풀이 바닥난다. 외부 호출을 밖으로 빼면 커넥션은 10ms짜리 쿼리 동안만 쓰인다.', true),
(11130, 4106, '트랜잭션 타임아웃을 60초로 늘려, 느린 결제 응답에도 롤백되지 않게 한다.', '롤백을 원인으로 본 오개념. 타임아웃을 늘리면 커넥션을 쥔 채 기다릴 수 있는 시간이 길어져 풀 고갈이 더 심해진다. 줄여야 할 것은 트랜잭션 안의 외부 대기 시간이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1324, 4107, '더티 리드,더티리드,더티 읽기,dirty read,dirtyread,dirty-read,오손 읽기,오손 데이터 읽기,오염된 읽기', 'TX#52가 읽은 0은 TX#51이 아직 COMMIT하지 않은 변경이었고, TX#51이 ROLLBACK하면서 한 번도 확정된 적 없는 값이 됐다. 그 결과 사용자는 쿠폰이 남아 있는데도 소진 안내를 받았고, 롤백 뒤 TX#53은 원래 값 5를 읽었다. 이것이 Dirty Read이며 READ COMMITTED 이상에서 차단된다. 같은 행을 두 번 읽는 사이 다른 트랜잭션이 UPDATE 후 커밋해 값이 달라지는 Non-Repeatable Read와 달리, 여기서 TX#52는 한 번만 읽었고 읽은 값 자체가 커밋되지 않은 것이었다는 점이 경계다. READ UNCOMMITTED는 이 현상을 허용하는 격리 수준의 이름이지 현상의 이름이 아니다.'),
       (1325, 4108, '일관성,consistency,정합성,데이터 일관성,일관성(consistency),컨시스턴시', '세 트랜잭션은 각각 전부 반영됐고(원자성), 겹쳐 실행된 트랜잭션이 없었으며(격리성), 장애 없이 기록이 남았다(지속성). 깨진 것은 트랜잭션 전후로 데이터가 규칙을 만족해야 한다는 일관성이다. PK·FK·NOT NULL은 모두 통과했지만 하루 출금 한도 같은 업무 규칙은 테이블 제약 조건만으로 표현되지 않아 애플리케이션 로직이 검사해야 하는데, 그 검사가 빠져 있었다. 만약 여러 요청이 동시에 한도를 검사하다 함께 통과한 경우였다면 격리성 쪽 문제로 봐야 하므로, 요청이 몇 시간 간격으로 하나씩 처리됐다는 기록이 두 성질을 가르는 단서다.');

-- =====================================================
-- Lesson 812: 롤백 규칙과 격리 수준 선택 비용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5051, 812, '아래 실행이 모두 끝난 뒤 두 계좌의 balance를 옳게 짝지은 것은?', '자동 이체 배치가 아래 순서로 실행됐다. 실행 전 account(id = 1)의 balance는 10,000원, account(id = 2)의 balance는 3,000원이었다. balance 컬럼에는 CHECK (balance >= 0) 제약이 걸려 있고, 세이브포인트는 쓰지 않았다.

```sql
START TRANSACTION;
UPDATE account SET balance = balance - 4000 WHERE id = 1;  -- 정상 실행
UPDATE account SET balance = balance + 4000 WHERE id = 2;  -- 정상 실행
UPDATE account SET balance = balance - 9000 WHERE id = 1;  -- CHECK 제약 위반으로 실패
ROLLBACK;
```', 'OBJECTIVE'),
       (5052, 812, '아래 로그에서 주문 행이 지워지지 않고 남은 원인으로 옳은 것은?', '주문 생성 메서드는 다른 클래스의 컨트롤러가 주입받은 빈을 통해 호출한다.

```java
@Transactional
public void placeOrder(Order order) throws IOException {
    orderRepository.insert(order);   // INSERT
    receiptStorage.upload(order);    // 실패하면 IOException을 던진다
}
```

```
11:20:03  INSERT INTO orders ... 1행
11:20:04  receiptStorage.upload 실패 → IOException 전파
11:20:04  placeOrder 종료, 커넥션 반납
11:20:10  SELECT * FROM orders WHERE id = 8821 → 11:20:03에 넣은 행이 그대로 있음
```

같은 메서드에서 IOException 대신 IllegalStateException을 던지도록만 바꿔 같은 실패를 재현하자, 이번에는 주문 행이 남지 않았다.', 'OBJECTIVE'),
       (5053, 812, '아래 측정 결과를 보고 취할 조치로 옳은 것은?', '주문 서비스에서 재고가 가끔 초과 차감된다는 보고가 올라오자, 팀은 애플리케이션 전체의 기본 격리 수준을 SERIALIZABLE로 올렸다. 초과 차감이 나는 지점은 재고를 읽어 계산한 값을 덮어쓰는 UPDATE 한 곳이고, 나머지 요청은 대부분 단순 조회다.

| 지표 | 변경 전 | 변경 후 |
|---|---|---|
| 주문 API 평균 응답 | 180ms | 1.4초 |
| 직렬화 충돌로 인한 롤백 | 하루 3건 | 하루 2,800건 |
| 재고 초과 차감 | 주 2건 | 0건 |
| 커넥션 풀 대기 타임아웃 | 하루 0건 | 하루 940건 |', 'OBJECTIVE'),
       (5054, 812, '아래 실험 결과에 대한 설명으로 옳은 것은?', 'MySQL(InnoDB) 8.0에서 격리 수준을 따로 지정하지 않고 아래 순서를 실행했다. orders 테이블의 status 컬럼에는 인덱스가 있다.

```
11:00:00  세션 A  BEGIN
11:00:01  세션 A  SELECT COUNT(*) FROM orders WHERE status = ''READY''  → 12
11:00:03  세션 B  INSERT INTO orders(status) VALUES (''READY'');  COMMIT
11:00:05  세션 A  SELECT COUNT(*) FROM orders WHERE status = ''READY''  → 12
11:00:07  세션 A  COMMIT
11:00:08  세션 A  SELECT COUNT(*) FROM orders WHERE status = ''READY''  → 13
```

팀원이 “SQL 표준 매트릭스에는 이 기본 격리 수준에서 같은 조건의 행 수가 늘어나는 현상이 발생 가능으로 적혀 있는데, 왜 11:00:05에서 12가 나오느냐”고 물었다.', 'OBJECTIVE'),
       (5055, 812, '아래 로그에서 TX#88이 겪은 이상 현상을 가리키는 용어는?', '[정산 화면 문의 조사 · 요청 하나가 트랜잭션 하나로 처리된다]

```
10:15:02.010  TX#88  BEGIN (READ COMMITTED)
10:15:02.012  TX#88  SELECT point FROM wallet WHERE user_id = 42   → 5,000  (출금 한도 검사에 사용)
10:15:02.130  TX#95  UPDATE wallet SET point = 2000 WHERE user_id = 42;  COMMIT
10:15:02.210  TX#88  SELECT point FROM wallet WHERE user_id = 42   → 2,000  (화면에 표시)
10:15:02.215  TX#88  COMMIT
```

- 두 조회는 모두 user_id = 42인 한 행만 대상으로 했고, 조회 조건도 서로 같았다.
- 사용자는 한도 검사에 쓰인 값과 화면에 찍힌 값이 어긋난다며 정산이 잘못됐다고 문의했다.', 'SUBJECTIVE'),
       (5056, 812, '아래 측정에서 조회 메서드의 트랜잭션 설정에 추가한 옵션의 이름은?', '주문 목록 API는 실행하는 쿼리가 전부 SELECT인데, 요청마다 응답 직전에 변경 감지가 돌고 플러시가 한 번씩 나갔다. 트랜잭션 설정에 값 하나를 더 준 것 말고는 쿼리도 인덱스도 바꾸지 않았다.

| 측정 항목 | 설정 추가 전 | 설정 추가 후 |
|---|---|---|
| 응답 p99 | 320ms | 180ms |
| 요청당 플러시 횟수 | 1회 | 0회 |
| 이 API의 조회가 향한 노드 | 소스 DB | 레플리카 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5051
(13643, 5051, 'id = 1 → 10,000원 / id = 2 → 7,000원', 'ROLLBACK이 오류가 난 행만 되돌린다고 본 오개념. 되돌림의 단위는 행이 아니라 트랜잭션이다. 오류와 상관없는 id = 2의 입금도 같은 트랜잭션 안에서 실행됐으므로 함께 취소돼 3,000원으로 돌아간다.', false),
(13644, 5051, 'id = 1 → 6,000원 / id = 2 → 7,000원', '실패한 문장만 빠지고 앞선 두 UPDATE는 살아남는다고 본 오개념. 원자성은 문장 단위가 아니라 트랜잭션 단위로 적용돼, 일부만 반영된 중간 상태로 끝나지 않는다.', false),
(13645, 5051, 'id = 1 → 10,000원 / id = 2 → 3,000원', '원자성에 따라 트랜잭션은 전부 반영되거나 전부 취소된다. ROLLBACK이 Undo 로그에 남은 변경 전 이미지로 앞선 두 UPDATE까지 되돌리므로, 두 계좌 모두 START TRANSACTION 직전 값으로 남는다.', true),
(13646, 5051, 'id = 1 → 6,000원 / id = 2 → 3,000원', 'ROLLBACK이 오류 직전 문장까지만 부분적으로 되감는다고 본 오개념. 세이브포인트를 두지 않았으므로 중간 지점으로 되돌아갈 수 없고, 첫 UPDATE의 차감도 함께 사라진다.', false),

-- 문제 5052
(13647, 5052, '커넥션 반납이 끝나기 전이라 롤백이 아직 실행되지 않았을 뿐이고, 잠시 뒤 다시 조회하면 행은 사라진다.', '롤백 시점을 뒤로 미뤄 본 오개념. 커밋·롤백은 메서드가 끝나는 시점에 결정되고 커넥션은 그 뒤에 반납된다. 반납 6초 뒤 조회에도 행이 남아 있었으므로 이 트랜잭션은 이미 커밋으로 끝난 것이다.', false),
(13648, 5052, '같은 클래스 안에서 this로 호출해 프록시를 거치지 못했고, 그래서 트랜잭션 설정이 아예 적용되지 않았다.', '자기 호출(self-invocation) 함정과 혼동. 호출은 다른 클래스의 빈을 통해 이뤄졌다. 프록시를 타지 못한 것이 원인이라면 예외 종류만 바꾼 두 번째 실행에서도 행이 남았어야 하는데 그때는 사라졌다.', false),
(13649, 5052, '조회 시점의 격리 수준이 낮아 커밋되지 않은 INSERT가 보인 것이고, 실제 테이블에는 행이 없다.', 'Dirty Read와 혼동. 커밋 전 값을 본 것이라면 트랜잭션이 끝난 뒤의 조회에서는 행이 보이지 않아야 한다. 같은 조회로 두 번째 실행에서는 행이 사라졌다는 점도 조회 방식이 아니라 종료 방식이 갈랐음을 보여 준다.', false),
(13650, 5052, '기본 롤백 규칙이 런타임 예외에만 걸려, 체크 예외로 끝난 트랜잭션이 롤백 없이 커밋됐다.', '많은 프레임워크가 기본적으로 런타임 예외에만 롤백을 걸고 체크 예외는 정상 종료로 보아 커밋한다. IOException은 체크 예외, IllegalStateException은 런타임 예외라 두 실행의 결과가 갈렸다. 체크 예외도 되돌리려면 롤백 대상 예외를 명시해야 한다.', true),

-- 문제 5053
(13651, 5053, '기본 격리 수준을 READ UNCOMMITTED로 한 단계 더 낮춰, 대기와 충돌 롤백을 아예 없앤다.', '지연만 보고 정합성을 버린 처방. 커밋 전 값까지 읽게 돼 조회 결과를 믿을 수 없고, 재고 차감 충돌은 그대로거나 더 나빠진다. PostgreSQL처럼 이 수준을 지정해도 READ COMMITTED로 동작하는 DBMS도 있어 기대한 효과조차 없다.', false),
(13652, 5053, '기본 격리 수준은 원래대로 되돌리고, 재고 차감만 조건을 담은 원자적 UPDATE나 명시적 락으로 보호한다.', '충돌은 UPDATE 한 지점에서만 나는데 격리 수준을 전역으로 올려 모든 요청이 비용을 나눠 냈다. UPDATE product SET stock = stock - 1 WHERE id = ? AND stock >= 1처럼 DB가 현재 값 기준으로 갱신하게 하면, 기본 수준을 낮게 두고도 초과 차감을 막는다.', true),
(13653, 5053, '기본 격리 수준을 REPEATABLE READ로 두면 스냅샷만으로 갱신 충돌까지 막히므로, 코드는 그대로 둔다.', '스냅샷이 쓰기 충돌까지 막아 준다고 본 오개념. 읽은 값을 애플리케이션에서 계산해 덮어쓰는 Lost Update는 트랜잭션 단위 스냅샷만으로 막지 못하는 경우가 많아, 원자적 UPDATE나 락이 따로 필요하다.', false),
(13654, 5053, 'SERIALIZABLE을 유지한 채 커넥션 풀 크기와 트랜잭션 타임아웃을 늘려 늘어난 대기를 흡수한다.', '대기를 없애지 않고 담을 그릇만 키운 처방. 하루 2,800건의 직렬화 충돌 롤백은 그대로 남고, 커넥션을 더 오래 쥐게 돼 평균 응답은 1.4초에서 더 늘어난다.', false),

-- 문제 5054
(13655, 5054, '기본 격리 수준이 REPEATABLE READ라 11:00:05가 트랜잭션 스냅샷을 읽었고, InnoDB는 넥스트 키 락까지 더해 표준이 허용한 현상을 대부분 막는다.', 'SQL 표준 매트릭스는 이 수준에서 Phantom Read를 발생 가능으로 두지만, InnoDB는 트랜잭션 단위 스냅샷과 넥스트 키 락으로 대부분 차단한다. 트랜잭션을 끝낸 뒤 11:00:08에 13이 나온 것이 그 증거다. 표준 기준과 구현 동작은 나눠서 답해야 한다.', true),
(13656, 5054, '11:00:03의 INSERT가 커밋되지 않아 세션 A에 보이지 않은 것이고, 커밋됐다면 11:00:05에서도 13이 나왔을 것이다.', 'Dirty Read의 반대 상황으로 읽은 오개념. 로그에는 11:00:03에 COMMIT이 함께 찍혀 있고, 같은 행이 11:00:08의 조회에서는 세어졌다. 커밋 여부가 아니라 세션 A가 어느 시점의 스냅샷을 보느냐가 12와 13을 갈랐다.', false),
(13657, 5054, '11:00:05의 조회가 질의 결과 캐시에서 이전 값을 그대로 돌려준 것이라 격리 수준과는 상관이 없다.', '같은 값이 두 번 나온 것을 캐시로 설명한 오개념. 캐시가 원인이라면 세션 A가 COMMIT을 한 것만으로 11:00:08의 값이 13으로 바뀐 이유를 설명할 수 없다. 트랜잭션이 자기 스냅샷을 계속 보다가 새 트랜잭션에서 최신 상태를 본 것이다.', false),
(13658, 5054, '11:00:05를 SELECT COUNT(*) ... FOR UPDATE로 바꿔도 같은 스냅샷을 읽으므로 결과는 똑같이 12다.', '잠금 읽기와 일반 조회를 같게 본 오개념. FOR UPDATE 같은 잠금 읽기는 스냅샷이 아니라 최신 커밋 행을 읽으므로 13이 나온다. 넥스트 키 락은 이렇게 잠금 읽기가 훑은 범위에 다른 트랜잭션이 행을 끼워 넣지 못하게 막는 쪽으로 작동한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1640, 5055, '비반복 읽기,반복 불가능한 읽기,반복할 수 없는 읽기,넌리피터블 리드,넌리피터블리드,논리피터블 리드,non-repeatable read,nonrepeatable read,non repeatable read,unrepeatable read', 'TX#88이 같은 행을 두 번 읽는 사이 TX#95가 값을 바꾸고 커밋해, 한도 검사에 쓴 5,000과 화면에 찍힌 2,000이 어긋났다. 이것이 Non-Repeatable Read이며, READ COMMITTED는 SELECT 문장마다 스냅샷을 새로 찍기 때문에 막지 못한다. 트랜잭션 단위 스냅샷을 쓰는 REPEATABLE READ부터 차단되고, 한 트랜잭션에서 같은 값을 여러 번 써야 하면 격리 수준을 올리거나 명시적 락으로 고정해야 한다. 이웃 개념과의 경계도 함께 보자. Dirty Read는 아직 커밋되지 않은 값을 읽는 것이라 TX#95가 COMMIT을 마친 이 로그와 다르고, Phantom Read는 같은 조건의 행 수가 늘어나는 것이라 한 행의 값만 바뀐 여기와 다르다. Lost Update는 읽은 값을 각자 계산해 덮어써 한쪽 쓰기가 사라지는 문제인데, TX#88은 쓰기를 하지 않았으므로 해당하지 않는다.'),
       (1641, 5056, 'readOnly,readonly,read only,read-only,readOnly=true,readonly=true,읽기 전용,읽기전용,읽기 전용 옵션,읽기 전용 힌트,읽기 전용 트랜잭션', '조회만 하는 트랜잭션에 읽기 전용 힌트를 주면 영속성 컨텍스트의 변경 감지와 플러시를 건너뛴다. 요청당 플러시가 1회에서 0회로, 응답 p99가 320ms에서 180ms로 줄어든 것이 그 효과다. 복제 환경에서는 이 표시가 라우팅 기준이 되어 조회를 레플리카로 보낼 수 있는데, 같은 API의 조회가 소스 DB에서 레플리카로 옮겨 간 것이 그 단서다. 헷갈리기 쉬운 이웃 설정과 구분하자면, 격리 수준은 동시에 도는 트랜잭션이 서로의 중간 상태를 얼마나 보는지를 정하고 타임아웃은 실행 시간을 제한할 뿐이어서 플러시 횟수나 라우팅을 바꾸지 않는다. 쓰기가 섞인 메서드에 붙이면 변경이 반영되지 않거나 예외가 날 수 있으니 조회 전용 경로에만 쓴다.');
