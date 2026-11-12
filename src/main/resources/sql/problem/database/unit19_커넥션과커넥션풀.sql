-- Unit: 커넥션과 커넥션 풀 (Unit ID: 248)
-- Chapter: 데이터베이스 (Chapter ID: 4)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (1030, 248, '커넥션 생성 비용과 매 요청 연결'),
       (1031, 248, '풀의 대여·반납과 풀 크기 트레이드오프'),
       (1032, 248, 'HikariCP 설정과 커넥션 누수');

-- =====================================================
-- Lesson 1030: 커넥션 생성 비용과 매 요청 연결
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6359, 1030, '아래 측정값을 바탕으로, 커넥션 풀을 도입한 뒤 같은 요청 한 건의 처리 시간은?', '요청마다 커넥션을 새로 맺고 끊던 API 서버에서 요청 한 건의 구간별 시간을 측정했다. 이후 커넥션 풀을 도입했다. 풀은 애플리케이션 시작 시 커넥션을 미리 채워 두며, 요청을 처리하는 동안 유휴 커넥션이 늘 남아 있었다. 풀에서 빌리고 돌려놓는 데 드는 시간은 무시한다.

| 구간 | 시간 |
| --- | --- |
| TCP 3-way 핸드셰이크 | 1.5ms |
| 계정·비밀번호 인증 | 4ms |
| DB 세션 생성 | 8.5ms |
| SELECT 실행 | 3ms |
| 연결 종료 | 3ms |', 'OBJECTIVE'),
       (6360, 1030, '아래 실험 결과에 대한 해석으로 옳은 것은?', '같은 SELECT 한 건을 두 환경에서 1,000번씩 실행해 평균 소요 시간을 쟀다. **새 커넥션**은 실행마다 커넥션을 맺고 끊었고, **커넥션 재사용**은 미리 맺어 둔 커넥션 하나로 계속 실행했다. 두 DB 서버의 사양과 데이터는 같고, SELECT의 DB 내부 실행 시간은 두 환경 모두 약 0.5ms다.

| 환경 | 네트워크 왕복 시간(RTT) | 새 커넥션 | 커넥션 재사용 |
| --- | --- | --- | --- |
| 같은 서버 안의 DB | 0.1ms | 9ms | 0.6ms |
| 다른 리전의 DB | 20ms | 110ms | 21ms |', 'OBJECTIVE'),
       (6361, 1030, '아래 장애 기록에 대한 해석으로 옳은 것은?', 'API 서버는 요청마다 `DriverManager.getConnection()`으로 커넥션을 새로 맺고, 응답한 뒤 끊는다. 선착순 이벤트가 열리자 아래 기록이 남았다.

```
[평상시]
  초당 요청 40건 | DB 동시 커넥션 약 3개 | 응답 p99 25ms

[이벤트 시작 후 10초]
  초당 요청 1,500건
  DB에 들어온 새 커넥션 요청: 초당 약 1,500건
  DB 동시 커넥션 151개 도달 뒤 신규 연결 거절: "Too many connections"
  DB CPU 사용률 98%
  같은 SELECT의 DB 내부 실행 시간: 3ms (평상시와 같음)
```', 'OBJECTIVE'),
       (6362, 1030, '아래 두 메서드를 각각 한 번씩 실행했을 때의 비교로 옳은 것은?', '커넥션 풀 없이 JDBC로 DB에 직접 연결한다. 두 메서드 모두 예외 없이 끝나며, `ids`에는 주문 번호 1,000개가 들어 있다.

```java
// A
void markA(List<Long> ids) throws SQLException {
    for (Long id : ids) {
        Connection conn = DriverManager.getConnection(URL, USER, PW);
        PreparedStatement ps = conn.prepareStatement(SQL);
        ps.setLong(1, id);
        ps.executeUpdate();
        conn.close();
    }
}

// B
void markB(List<Long> ids) throws SQLException {
    Connection conn = DriverManager.getConnection(URL, USER, PW);
    PreparedStatement ps = conn.prepareStatement(SQL);
    for (Long id : ids) {
        ps.setLong(1, id);
        ps.executeUpdate();
    }
    conn.close();
}
```', 'OBJECTIVE'),
       (6363, 1030, '아래 변경에서 서버에 도입한 기법의 이름은?', '주문 API 서버의 배포 전후 지표다. 코드의 쿼리는 하나도 바꾸지 않았다.

| 지표 | 변경 전 | 변경 후 |
| --- | --- | --- |
| 분당 새로 맺은 커넥션 수 | 약 18,000 | 서버 기동 때 10, 이후 0 |
| 응답 시간 p50 | 48ms | 7ms |
| DB 동시 커넥션 수 | 트래픽에 따라 3~280 | 항상 10 |
| 트래픽 급증 시 | DB가 신규 연결 거절 | 일부 요청이 앱 안에서 잠시 대기 |

변경 후에는 코드에서 `conn.close()`를 불러도 DB 쪽에 연결 종료 기록이 남지 않았다.', 'SUBJECTIVE'),
       (6364, 1030, '아래 패킷 기록에서 ①~③의 교환 과정을 부르는 이름은?', '요청마다 커넥션을 새로 맺는 API 서버(10.0.1.5)와 MySQL 서버(10.0.2.9:3306) 사이의 패킷을 캡처했다. 요청 한 건분만 옮겼다.

```
0.000ms  ①  10.0.1.5 → 10.0.2.9  [SYN]
0.210ms  ②  10.0.2.9 → 10.0.1.5  [SYN, ACK]
0.230ms  ③  10.0.1.5 → 10.0.2.9  [ACK]
0.900ms  ④  10.0.2.9 → 10.0.1.5  서버 인사(Greeting)
1.100ms  ⑤  10.0.1.5 → 10.0.2.9  로그인 요청(계정·인증 정보)
4.800ms  ⑥  10.0.2.9 → 10.0.1.5  OK
5.000ms  ⑦  10.0.1.5 → 10.0.2.9  쿼리: SELECT ...
8.100ms  ⑧  10.0.2.9 → 10.0.1.5  결과 행
8.300ms  ⑨  10.0.1.5 → 10.0.2.9  종료 요청(Quit)
8.400ms  ⑩  10.0.1.5 → 10.0.2.9  [FIN, ACK]
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6359
(17131, 6359, '3ms', '풀의 커넥션은 시작 시점에 핸드셰이크·인증·세션 생성을 마친 채 재사용되고, 다 쓰면 끊지 않고 반납된다. 요청 처리 중 남는 구간은 SELECT 3ms뿐이다.', true),
(17132, 6359, '6ms', '사용 후 close()가 연결을 끊는다고 보고 종료 3ms를 남긴 계산이다. 풀 환경의 close()는 연결을 끊지 않고 풀에 반납하므로 종료 비용이 요청마다 생기지 않는다.', false),
(17133, 6359, '7ms', '빌릴 때마다 인증을 다시 거친다고 본 계산이다(4 + 3). 인증은 커넥션을 맺을 때 한 번 끝나며, 풀은 인증과 세션까지 마친 커넥션을 통째로 보관했다가 빌려준다.', false),
(17134, 6359, '15.5ms', '풀이 TCP 연결만 유지하고 인증·세션은 매번 새로 만든다고 본 계산이다(4 + 8.5 + 3). 풀에 보관되는 것은 세션까지 할당된 완성된 커넥션이라 세 단계 모두 다시 하지 않는다.', false),

-- 문제 6360
(17135, 6360, '다른 리전에서 새 커넥션이 재사용보다 89ms 더 걸린 것은 원격 DB에서 SELECT가 더 느리게 실행되기 때문이다.', '본문에서 DB 내부 실행 시간은 두 환경 모두 0.5ms로 같다. 늘어난 시간은 쿼리가 아니라 커넥션을 맺는 단계에서 생겼다.', false),
(17136, 6360, '같은 서버 안에서 새 커넥션이 약 8ms 더 걸린 것은 대부분 네트워크 왕복 때문이다.', 'RTT가 0.1ms라 왕복 몇 번으로는 8ms가 나오지 않는다. 이 차이는 DB가 계정을 검증하고 세션용 메모리·프로세스를 할당하는 서버 쪽 처리 비용이다.', false),
(17137, 6360, '새 커넥션의 추가 비용이 원격에서 크게 불어난 것은, 연결 수립이 쿼리 전에 여러 번의 왕복을 거치기 때문이다.', 'TCP 3-way 핸드셰이크와 인증이 각각 왕복을 요구해 쿼리를 보내기 전에 여러 번 오가야 한다. RTT가 20ms면 그 왕복 수만큼 지연이 쌓여 재사용보다 약 89ms가 더 든다.', true),
(17138, 6360, '원격에서 커넥션을 재사용해도 21ms가 걸린 것은 재사용할 때마다 핸드셰이크를 다시 하기 때문이다.', '재사용은 이미 맺은 커넥션으로 쿼리만 보내므로 요청·응답 왕복 한 번(20ms)에 실행 시간이 더해진 값이다. 핸드셰이크를 매번 한다면 새 커넥션처럼 100ms 안팎이 나와야 한다.', false),

-- 문제 6361
(17139, 6361, 'SELECT 실행이 느려진 것이 CPU 98%의 원인이므로, 인덱스를 추가하면 연결 거절이 사라진다.', '본문에서 같은 SELECT는 평상시와 같은 3ms에 끝났다. 쿼리는 그대로인데 CPU가 치솟았으니, CPU를 잡아먹은 것은 초당 1,500건씩 들어온 연결 수립 작업이다.', false),
(17140, 6361, 'DB의 동시 커넥션 상한을 2,000으로 올리면 DB 부하 없이 몰린 요청을 모두 받아낼 수 있다.', '커넥션마다 DB가 세션 메모리와 프로세스(스레드)를 할당하므로 상한을 올리면 그 부담이 그대로 늘어난다. 이미 CPU가 98%라 상한만 올리면 처리량이 더 떨어질 수 있다.', false),
(17141, 6361, '커넥션을 맺는 비용은 앱 서버가 부담하므로 DB CPU 98%는 연결 수립과 관계가 없다.', '인증 검증과 세션 할당은 DB 서버가 수행한다. 요청마다 커넥션을 맺고 끊으면 DB가 세션 생성과 해제를 끊임없이 반복하게 되는 것이 매 요청 연결 방식의 큰 문제다.', false),
(17142, 6361, '앱이 동시 커넥션 수를 제한하지 않아, 트래픽이 늘수록 DB가 인증·세션 할당에 쓰는 자원도 함께 불어났다.', '매 요청 연결 방식에서는 동시 커넥션 수가 트래픽을 따라 무제한으로 는다. 쿼리 시간이 그대로인데 CPU가 98%가 된 것은 연결 수립 비용 때문이며, 풀이 있었다면 초과 요청은 앱에서 대기해 DB가 보호됐다.', true),

-- 문제 6362
(17143, 6362, '두 메서드 모두 UPDATE를 1,000번 보내므로 DB 서버가 처리하는 일의 양은 같다.', '쿼리 수는 같아도 A는 반복마다 연결 수립(핸드셰이크·인증·세션 생성)과 종료를 함께 요구한다. DB 입장에서는 UPDATE 1,000번에 세션 생성·해제 1,000번이 더해진다.', false),
(17144, 6362, 'A는 DB 서버에 계정 검증과 세션 할당을 1,000번 요구하지만, B는 한 번만 요구한다.', '계정 검증과 세션 할당은 커넥션을 맺을 때 일어난다. A는 루프 안에서 getConnection()을 불러 1,000번 연결하고, B는 루프 밖에서 한 번 맺은 커넥션으로 UPDATE만 반복한다.', true),
(17145, 6362, 'A는 매번 연결을 끊어 세션을 오래 쥐지 않으므로 B보다 DB 자원을 아껴 쓴다.', '세션을 짧게 쥐는 대신 세션 생성과 해제를 1,000번 반복시키는 쪽이 DB에 훨씬 큰 부담이다. 같은 일을 하는 동안 세션 하나를 유지하는 B가 DB 자원을 덜 쓴다.', false),
(17146, 6362, 'B도 executeUpdate()마다 TCP 3-way 핸드셰이크를 거치므로 A와 연결 비용이 같다.', '핸드셰이크는 커넥션을 맺을 때 한 번 일어난다. B는 이미 맺은 커넥션으로 쿼리만 보내므로 executeUpdate()마다 연결 단계를 다시 거치지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2076, 6363, '커넥션 풀,커넥션풀,커넥션 풀링,커넥션풀링,connection pool,connection pooling,connectionpool,DB 커넥션 풀,데이터베이스 커넥션 풀,DBCP,Database Connection Pool,연결 풀,풀링,pooling', '커넥션을 미리 여러 개 만들어 보관해 두고, 요청이 오면 빌려 주고 다 쓰면 돌려받아 재사용하는 기법이 커넥션 풀이다. 새로 맺는 커넥션이 기동 때 10개뿐이고 이후 0이 된 것은 커넥션을 재사용했다는 뜻이고, 그 덕분에 요청마다 들던 핸드셰이크·인증·세션 생성 비용이 사라져 응답이 48ms에서 7ms로 줄었다. DB 동시 커넥션이 항상 10으로 고정되고 급증 시 요청이 앱 안에서 기다린 것은 풀 크기가 상한 역할을 해 DB를 보호했기 때문이다. close()를 불러도 DB에 종료 기록이 없는 것은 풀 환경의 close()가 연결을 끊지 않고 풀에 반납하기 때문이다. HikariCP·Apache Commons DBCP는 이 기법을 구현한 라이브러리 이름이고, 커넥션 자체를 줄이는 캐시나 서버 여러 대로 요청을 나누는 로드밸런싱과는 다른 개념이다.'),
       (2077, 6364, '3-way 핸드셰이크,3-way handshake,3웨이 핸드셰이크,쓰리웨이 핸드셰이크,three-way handshake,3 way handshake,3방향 핸드셰이크,TCP 3-way 핸드셰이크,TCP 3-way handshake,TCP 핸드셰이크,TCP handshake,핸드셰이크,handshake,3-way 핸드쉐이크,3웨이 핸드쉐이크,쓰리웨이 핸드쉐이크,TCP 핸드쉐이크,핸드쉐이크,3단계 핸드셰이크,TCP 연결 수립,TCP 연결 설정', '①~③은 SYN → SYN+ACK → ACK 세 번의 교환으로 TCP 연결을 수립하는 3-way 핸드셰이크다. DB 프로토콜 메시지(④ 이후)가 오가기 전에 반드시 이 왕복이 먼저 끝나야 한다. 커넥션을 새로 맺는 비용은 이것만이 아니다. ④~⑥은 DB 계정을 검증하는 인증 단계로, 3.7ms가 걸린 ⑤→⑥ 구간에는 인증과 DB 세션 할당이 들어 있다. 실제 작업인 ⑦~⑧ 쿼리는 약 3ms인데 그 앞의 연결 수립에만 약 5ms가 들었다. ⑩의 FIN은 연결을 끊는 종료 과정의 시작으로, 연결 수립 단계인 3-way 핸드셰이크와 구분해야 한다. 커넥션 풀은 이 수립 과정을 기동 때 한 번만 치르고 이후 커넥션을 재사용해 요청마다 반복되는 ①~⑥을 없앤다.');

-- =====================================================
-- Lesson 1031: 풀의 대여·반납과 풀 크기 트레이드오프
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6365, 1031, '아래 배치 작업이 끝날 때까지 API 서버와 DB 서버 사이에서 일어나는 TCP 3-way 핸드셰이크 횟수는?', '애플리케이션을 기동한 직후 `run()`을 한 번 호출하며, 기동부터 작업 종료까지 2초가 걸린다. 그동안 DB가 끊은 커넥션은 없고, 다른 코드는 DB를 쓰지 않는다.

```properties
spring.datasource.hikari.maximum-pool-size=5
spring.datasource.hikari.minimum-idle=5
```

```java
@Component
public class SettleBatch {
    private final DataSource dataSource;   // 위 설정의 HikariCP 풀

    public SettleBatch(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public void run(List<Long> ids) throws SQLException {
        for (Long id : ids) {              // 500건, 한 번에 하나씩 순서대로
            try (Connection conn = dataSource.getConnection();
                 PreparedStatement ps = conn.prepareStatement(SQL)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }
        }
    }
}
```', 'OBJECTIVE'),
       (6366, 1031, '아래 부하 실험 결과에 대한 해석으로 옳은 것은?', '같은 API 서버·DB 서버에 동시 사용자 300명의 부하를 5분간 걸었다. A는 요청마다 커넥션을 새로 맺고 끊고, B는 최대 크기 10인 커넥션 풀을 쓴다. B의 풀은 측정 전에 커넥션 10개를 모두 채워 두었다.

| 지표 | A | B |
| --- | --- | --- |
| 응답 시간 p50 | 52ms | 31ms |
| 응답 시간 중 풀 대기 p50 | 해당 없음 | 24ms |
| DB 동시 커넥션 최댓값 | 300 | 10 |
| 5분간 새로 맺은 커넥션 수 | 약 170,000 | 0 |
| 쿼리 실행 시간 p50 (DB 측 측정) | 9ms | 4ms |', 'OBJECTIVE'),
       (6367, 1031, '아래 제안에 대한 검토 의견으로 옳지 않은 것은?', '- **DB 서버**: CPU 4코어, 디스크 1개, 최대 커넥션 수(`max_connections`) 100
- **API 서버**: 2대, 각 서버의 HikariCP `maximum-pool-size`는 10
- **관측**: 피크 시간에 풀 대기가 생기며, 그때 DB CPU 사용률은 95%다.
- **제안**: "풀이 작아서 기다리는 것이니, 서버당 풀을 60으로 키우자."', 'OBJECTIVE'),
       (6368, 1031, '아래 조건에서 커넥션을 얻지 못해 예외로 끝나는 요청은 몇 개인가?', '- HikariCP `maximum-pool-size`는 2이며, 시작 시 2개를 모두 채워 둔 상태다.
- `connection-timeout`은 1,000ms다.
- 요청 7개(r1~r7)가 0ms에 동시에 도착해 r1부터 차례로 커넥션을 요청한다.
- 커넥션을 얻은 요청은 정확히 400ms 동안 쓰고 반납하며, 반납된 커넥션은 가장 먼저 기다리기 시작한 요청이 즉시 받는다.
- 예외로 끝난 요청은 다시 시도하지 않으며, 그 밖의 요청은 없다.', 'OBJECTIVE'),
       (6369, 1031, '아래 업그레이드 뒤 이 서버가 쓰게 된 커넥션 풀 구현체의 이름은?', '스프링 부트 1.5로 운영하던 서버를 2.7로 올렸다. `spring-boot-starter-jdbc` 외에 커넥션 풀 의존성은 따로 추가하지 않았고, 풀 관련 설정도 하나도 없다. 아래는 두 버전의 기동 로그이며, 업그레이드 후 로그의 풀 이름 부분은 가렸다.

```
[1.5] o.a.tomcat.jdbc.pool.ConnectionPool : pool initialized (initialSize=10)

[2.7] [가림]Pool-1 - Starting...
[2.7] [가림]Pool-1 - Added connection com.mysql.cj.jdbc.ConnectionImpl@5e1fc2
[2.7] [가림]Pool-1 - Start completed.
```

업그레이드 후에는 풀 설정 키도 `spring.datasource.tomcat.*` 대신 이 구현체 이름을 소문자로 쓴 접두사(`spring.datasource.[가림].*`)를 써야 적용됐다.', 'SUBJECTIVE'),
       (6370, 1031, '아래 관측에서 DB CPU가 쿼리 처리 대신 점점 더 많이 쓰게 된 작업을 가리키는 용어는?', 'CPU 8코어 DB 서버에 붙는 커넥션 풀의 크기만 바꿔 가며 같은 부하를 걸고, DB 서버에서 `vmstat`으로 관측했다. 쿼리와 데이터는 모두 같다.

| 풀 크기 | 동시에 실행 중인 쿼리 | vmstat 지표 ㉠ (초당) | CPU 중 커널 영역(sy) | 쿼리 평균 시간 | 처리량(TPS) |
| --- | --- | --- | --- | --- | --- |
| 16 | 약 16 | 4,000 | 5% | 3ms | 5,200 |
| 400 | 약 400 | 180,000 | 38% | 120ms | 3,100 |

두 경우 모두 CPU 사용률은 거의 100%였다. 풀 400에서는 코어 하나가 수십 개의 쿼리를 아주 짧게 돌아가며 맡았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6365
(17147, 6365, '0', '풀의 커넥션은 핸드셰이크 없이 생긴다고 본 오해다. 풀도 커넥션을 미리 만들 때 TCP 연결 수립·인증·세션 생성을 똑같이 거치며, 그 비용을 기동 시점에 한 번 치러 둘 뿐이다.', false),
(17148, 6365, '1', '한 번에 하나씩만 쓰니 커넥션도 필요할 때 하나만 만든다고 본 계산이다. 풀은 기동 시 minimum-idle만큼 미리 채워 두므로, 실제로 하나만 돌려 쓰더라도 5개분의 연결 수립이 이미 일어났다.', false),
(17149, 6365, '5', '기동 시 minimum-idle=5에 맞춰 커넥션 5개를 미리 맺어 둔다. 이후 500번의 getConnection()은 유휴 커넥션을 빌리고 try 블록을 벗어날 때 반납할 뿐 새 연결을 맺지 않는다.', true),
(17150, 6365, '500', 'try 블록이 끝나며 호출되는 close()가 연결을 끊는다고 본 오해다. 풀 환경의 close()는 커넥션을 풀에 반납하므로, 다음 반복은 그 커넥션을 다시 빌려 쓴다.', false),

-- 문제 6366
(17151, 6366, 'B의 응답이 A보다 빠른 것은, 풀 대기가 붙었어도 연결 수립이 사라지고 DB 부하가 줄어든 몫이 더 컸기 때문이다.', 'B는 새 커넥션이 0개라 핸드셰이크·인증·세션 비용이 없고, DB 동시 커넥션이 10으로 묶여 같은 쿼리도 9ms가 아닌 4ms에 끝났다. 풀 대기 24ms를 더해도 31ms로 A의 52ms보다 짧다.', true),
(17152, 6366, 'B의 풀 대기 24ms는 대기하던 요청이 커넥션을 새로 맺는 데 걸린 시간이다.', 'B가 5분간 새로 맺은 커넥션은 0개다. 풀이 꽉 차면 요청은 새 커넥션을 만들지 않고 다른 요청이 커넥션을 반납할 때까지 기다리며, 24ms는 그 대기 시간이다.', false),
(17153, 6366, 'A의 쿼리 실행 시간이 더 긴 것은 핸드셰이크에 걸린 시간이 실행 시간에 함께 잡혔기 때문이다.', '쿼리 실행 시간은 DB 측에서 쿼리만 잰 값이라 연결 수립 시간이 들어가지 않는다. A는 동시 세션 300개와 끊임없는 세션 생성·해제로 DB가 과부하돼 같은 쿼리도 느려졌다.', false),
(17154, 6366, 'B의 풀 최대 크기를 300으로 올리면 풀 대기가 사라지고 DB 측 쿼리 시간도 4ms로 유지된다.', '풀을 300으로 키우면 DB 동시 커넥션이 A와 같은 300까지 늘어 세션 자원 부담과 경합이 다시 커진다. 풀 대기는 줄어도 DB 측 쿼리 시간이 4ms로 유지된다고 볼 근거가 없다.', false),

-- 문제 6367
(17155, 6367, '제안대로면 두 서버의 풀 합계가 120이 되어, 커넥션을 다 채우기 전에 DB의 최대 커넥션 수에 걸린다.', '풀 크기는 서버마다 따로 잡히므로 DB가 받는 커넥션은 60 × 2 = 120이다. max_connections가 100이라 20개는 맺지 못하고, 그 서버의 풀은 연결 실패를 겪는다. 참인 의견이다.', false),
(17156, 6367, 'DB CPU가 이미 95%라, 동시에 보내는 쿼리를 늘리면 컨텍스트 스위칭이 늘어 처리량이 오히려 떨어질 수 있다.', '코어 4개로 이미 바쁜 DB에 동시 쿼리를 더 밀어 넣으면 코어가 여러 쿼리를 번갈아 처리하느라 전환 비용이 커진다. 기다림이 풀 앞에서 DB 안으로 옮겨 갈 뿐이라 참인 의견이다.', false),
(17157, 6367, '풀을 키우면 앱 서버는 여유로워 보여도, 늘어난 세션의 메모리 부담은 DB 서버가 떠안는다.', 'DB는 커넥션마다 세션용 메모리와 프로세스(스레드)를 할당한다. 풀 대기가 줄어 앱은 편해 보여도 그 부담이 고스란히 DB로 넘어가므로 참인 의견이다.', false),
(17158, 6367, '풀을 키우면 요청마다 드는 연결 수립 비용이 줄어들기 때문에, DB CPU 사용률도 함께 내려간다.', '풀을 쓰는 지금도 요청 처리 중에는 연결 수립 비용이 없다. 풀을 키우면 DB가 유지할 세션과 동시 쿼리만 늘어 CPU 부담이 커지므로, 사용률이 내려간다는 판단은 거짓이다.', true),

-- 문제 6368
(17159, 6368, '0개', '풀이 모자라면 커넥션을 더 만들어 준다고 본 오해다. maximum-pool-size=2가 상한이라 동시에 쓸 수 있는 커넥션은 2개뿐이고, r7은 1,200ms가 돼야 차례가 오는데 대기 한계는 1,000ms다.', false),
(17160, 6368, '1개', '커넥션은 400ms마다 2개씩 돌아온다. r3·r4는 400ms, r5·r6은 800ms에 받아 한계 안에 성공하지만, r7의 차례는 1,200ms라 1,000ms 시점에 대기 한계를 넘겨 예외로 끝난다.', true),
(17161, 6368, '3개', 'connection-timeout을 요청이 끝날 때까지의 시간으로 본 계산이다(r5·r6은 1,200ms에 끝남). 이 값은 커넥션 대여를 기다리는 한계라, 800ms에 커넥션을 받은 r5·r6은 성공한다.', false),
(17162, 6368, '5개', '곧바로 커넥션을 받지 못한 요청은 모두 실패한다고 본 오해다. 풀이 꽉 차면 요청은 connection-timeout까지 반납을 기다리며, 그 안에 커넥션을 받으면 정상 처리된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2078, 6369, 'HikariCP,Hikari CP,Hikari,히카리CP,히카리 CP,히카리,HikariPool,Hikari Pool,히카리 풀,Hikari Connection Pool,히카리 커넥션 풀,com.zaxxer.hikari', '스프링 부트는 2.0부터 HikariCP를 기본 커넥션 풀로 쓴다. 풀 의존성과 설정을 따로 두지 않았으니 2.7에서는 기본 구현체가 선택되고, 기동 로그의 HikariPool-1과 설정 접두사 spring.datasource.hikari.*가 그 흔적이다. 1.5의 로그에 찍힌 org.apache.tomcat.jdbc.pool은 톰캣에 내장된 Tomcat JDBC Pool로, 1.x 시절 기본값이었다. 아파치 재단의 전통적인 구현체인 Apache Commons DBCP도 별도 라이브러리이며 기본값이 아니다. DBCP(Database Connection Pool)는 커넥션 풀 기법이나 그 구현체를 통칭하는 말이라, 특정 구현체의 이름을 묻는 이 문제의 답으로는 맞지 않는다.'),
       (2079, 6370, '컨텍스트 스위칭,컨텍스트 스위치,컨텍스트스위칭,콘텍스트 스위칭,콘텍스트 스위치,컨텍스트 전환,콘텍스트 전환,문맥 교환,문맥 전환,문맥교환,context switching,context switch,컨텍스트 스위칭 비용,문맥 교환 비용,context switching overhead', 'CPU가 실행 중이던 작업의 상태를 저장하고 다른 작업의 상태를 불러와 넘어가는 일이 컨텍스트 스위칭이다. vmstat의 ㉠ 지표(cs)는 초당 이 전환 횟수를 뜻하며, 풀 크기를 16에서 400으로 키우자 4,000에서 180,000으로 45배 늘었다. 코어는 8개 그대로인데 동시 쿼리가 400개가 되어 코어마다 수십 개를 번갈아 처리했고, 그 전환에 커널 영역 CPU가 38%까지 쓰였다. CPU 사용률은 똑같이 100%였지만 실제 쿼리 처리에 쓰인 몫이 줄어 처리량이 5,200에서 3,100으로 떨어졌다. 풀이 너무 크면 부담이 DB로 넘어간다는 것이 바로 이 장면이다. 커넥션을 얻으려고 앱에서 기다리는 풀 대기와는 다르다. 풀 대기는 풀이 작을 때 앱 쪽에서 생기고, 컨텍스트 스위칭은 풀이 클 때 DB 서버 안에서 생긴다.');

-- =====================================================
-- Lesson 1032: HikariCP 설정과 커넥션 누수
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6371, 1032, '아래 환경에서 만들어진 커넥션 풀에 대한 설명으로 옳은 것은?', 'Spring Boot 3.2 서버의 `application.properties`에는 DB 접속 정보만 있고, 다른 데이터소스 설정은 없다.

```properties
spring.datasource.url=jdbc:mysql://db:3306/shop
spring.datasource.username=shop
spring.datasource.password=secret
```

기동 로그는 아래와 같다.

```
HikariPool-1 - Starting...
HikariPool-1 - Added connection com.mysql.cj.jdbc.ConnectionImpl@1a2b3c
HikariPool-1 - Start completed.
```', 'OBJECTIVE'),
       (6372, 1032, '아래 오류를 예방하는 설정 변경으로 옳은 것은?', 'MySQL 서버는 600초 동안 요청이 없는 커넥션을 먼저 끊는다(`wait_timeout=600`). API 서버의 HikariCP 설정은 아래와 같다.

```properties
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.max-lifetime=1800000
```

새벽 동안 요청이 거의 없다가, 아침 첫 요청 몇 건이 아래 오류로 실패했다.

```
Communications link failure
The last packet successfully received from the server was 1,140,000 milliseconds ago.
```', 'OBJECTIVE'),
       (6373, 1032, '아래 호출이 모두 끝난 직후, 풀에서 바로 빌릴 수 있는 유휴 커넥션은 몇 개인가?', '- HikariCP `maximum-pool-size`와 `minimum-idle`은 둘 다 5이며, 기동 시 5개를 모두 채워 두었다.
- 누수 감지 등 다른 설정은 없고, 이 메서드 말고는 DB를 쓰는 코드가 없다.
- 호출은 한 번에 하나씩 순서대로 하며, 호출한 쪽은 예외를 잡아 로그만 남기고 넘어간다.

```java
public int countItems(long orderId) throws SQLException {
    Connection conn = dataSource.getConnection();
    PreparedStatement ps = conn.prepareStatement(
        "SELECT COUNT(*) FROM order_item WHERE order_id = ?");
    ps.setLong(1, orderId);
    ResultSet rs = ps.executeQuery();
    rs.next();
    int n = rs.getInt(1);
    if (n == 0) {
        throw new IllegalStateException("빈 주문: " + orderId);
    }
    conn.close();
    return n;
}
```

| 순서 | 호출 | 해당 주문의 품목 수 |
| --- | --- | --- |
| 1 | countItems(101) | 3 |
| 2 | countItems(102) | 0 |
| 3 | countItems(103) | 2 |
| 4 | countItems(104) | 0 |
| 5 | countItems(105) | 1 |', 'OBJECTIVE'),
       (6374, 1032, '아래 풀 로그에 대한 설명으로 옳은 것은?', 'MySQL(`wait_timeout=28800`, 8시간)에 붙는 API 서버의 HikariCP 설정과, 하루 종일 요청이 꾸준히 들어온 날의 풀 로그 일부다. 같은 시간대에 오류 응답은 한 건도 없었다.

```properties
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.max-lifetime=1800000
```

```
09:00:02  HikariPool-1 - Start completed. (conn0 ~ conn9 생성)
09:29:31  HikariPool-1 - Closing connection conn4: (connection has passed maxLifetime)
09:29:31  HikariPool-1 - Added connection conn10
09:29:48  HikariPool-1 - Closing connection conn7: (connection has passed maxLifetime)
09:29:48  HikariPool-1 - Added connection conn11
...
09:59:05  HikariPool-1 - Closing connection conn10: (connection has passed maxLifetime)
09:59:05  HikariPool-1 - Added connection conn12
```', 'OBJECTIVE'),
       (6375, 1032, '아래 수정 코드에서 쓴 자바 문법의 이름은?', '주문 서버에서 일주일에 두세 번, 풀의 활성 커넥션이 하나씩 쌓이다가 결국 모든 요청이 `Connection is not available, request timed out after 30000ms`로 실패했다. 원인은 `executeUpdate()`에서 예외가 나면 그 아래의 `conn.close()`에 닿지 못하는 코드였다. 아래처럼 고친 뒤로는 같은 장애가 한 번도 나지 않았고, 코드 어디에도 `close()` 호출이 남지 않았다.

```java
try (Connection conn = dataSource.getConnection();
     PreparedStatement ps = conn.prepareStatement(SQL)) {
    ps.setLong(1, orderId);
    ps.executeUpdate();
}
```', 'SUBJECTIVE'),
       (6376, 1032, '아래 두 주 사이에 값을 바꾼 설정 항목의 이름은?', 'HikariCP를 쓰는 API 서버다. 이 풀은 10분 넘게 쓰이지 않은 유휴 커넥션을 닫는다. 두 주 사이에 HikariCP 설정 하나의 값만 2에서 10으로 바꿨고, `maximum-pool-size`는 두 주 모두 10이다.

| 지표 | 1주차 | 2주차 |
| --- | --- | --- |
| 새벽 4시 풀 상태 | 전체 2개, 모두 유휴 | 전체 10개, 모두 유휴 |
| 07:00 출근 트래픽 첫 1분간 새로 맺은 커넥션 | 8개 | 0개 |
| 07:00 첫 1분 응답 시간 p99 | 180ms | 35ms |
| 그 밖의 시간대 응답 시간 p99 | 35ms | 35ms |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6371
(17163, 6371, '커넥션 10개가 모두 대여 중이면, 다음 요청은 최대 30초까지 반납을 기다린 뒤 예외로 끝난다.', '설정이 없으면 maximum-pool-size 기본값 10이 상한이고, connection-timeout 기본값 30,000ms가 대여 대기 한계다. 반납이 없으면 30초 뒤 예외가 난다.', true),
(17164, 6371, 'minimum-idle을 적지 않았으므로, 요청이 없는 동안 풀은 유휴 커넥션을 하나도 남기지 않는다.', 'minimum-idle의 기본값은 0이 아니라 maximum-pool-size와 같은 값이다. 그래서 기본 설정의 풀은 요청이 없어도 커넥션 10개를 유휴 상태로 유지한다.', false),
(17165, 6371, 'max-lifetime을 적지 않았으므로, 한 번 맺은 커넥션은 애플리케이션이 끝날 때까지 폐기되지 않는다.', 'max-lifetime의 기본값은 1,800,000ms(30분)다. 수명을 넘긴 커넥션은 폐기되고 새로 만들어지므로, 설정을 적지 않아도 커넥션은 30분 안쪽에서 교체된다.', false),
(17166, 6371, '설정이 없으니 커넥션 수에 상한이 없어, 동시 요청이 늘면 그 수만큼 커넥션이 계속 늘어난다.', '설정을 적지 않아도 기본값이 적용된다. maximum-pool-size 기본값 10이 상한이라, 동시 요청이 그보다 많으면 커넥션을 더 만들지 않고 반납을 기다리게 한다.', false),

-- 문제 6372
(17167, 6372, 'connection-timeout을 60000으로 늘려, 커넥션을 빌리기까지 더 오래 기다릴 수 있게 한다.', 'connection-timeout은 풀에서 커넥션을 빌리려고 기다리는 한계다. 오류는 대기 중이 아니라 이미 DB가 끊은 커넥션을 받아 쓰다가 났으므로 대기 한계를 늘려도 막지 못한다.', false),
(17168, 6372, 'maximum-pool-size를 20으로 늘려, 끊긴 커넥션 대신 쓸 여분의 커넥션을 확보한다.', '커넥션이 늘어도 새벽 동안 쓰이지 않은 커넥션은 모두 600초가 지나 DB에 끊긴다. 풀이 끊긴 줄 모르고 내주는 문제는 그대로라, 개수를 늘리면 죽은 커넥션만 늘어난다.', false),
(17169, 6372, 'max-lifetime을 540000으로 줄여, DB가 끊기 전에 풀이 먼저 커넥션을 교체하게 한다.', '마지막 수신이 1,140초 전이라 wait_timeout 600초를 넘겨 DB가 먼저 끊은 커넥션을 풀이 내준 것이다. 수명을 540초로 줄이면 600초에 닿기 전에 폐기·재생성돼 죽은 커넥션이 대여되지 않는다.', true),
(17170, 6372, 'max-lifetime을 3600000으로 늘려, 커넥션이 중간에 폐기되지 않고 오래 유지되게 한다.', '현재 30분도 이미 wait_timeout 10분보다 길어서 문제가 생겼다. 수명을 60분으로 늘리면 DB가 끊은 뒤에도 풀에 남아 있는 시간이 더 길어져 같은 오류가 더 자주 난다.', false),

-- 문제 6373
(17171, 6373, '0', '직접 부른 close()는 반납이 안 되고 try-with-resources만 반납한다고 본 오해다. 풀 환경에서는 직접 부른 close()도 커넥션을 풀에 돌려놓으므로 정상 종료된 호출은 반납된다.', false),
(17172, 6373, '3', '102·104는 품목 수가 0이라 conn.close()에 닿기 전에 예외로 빠져나가 커넥션 2개가 반납되지 않았다. 나머지 3건은 close()로 반납돼 5 − 2 = 3개가 남고, 대여 중인 2개가 상한을 채워 새로 만들지도 않는다.', true),
(17173, 6373, '4', '두 번째 예외 호출이 앞서 누수된 커넥션을 다시 받아 썼다고 본 오해다. 반납되지 않은 커넥션은 풀이 대여 중으로 보므로 다시 내주지 않고, 104는 다른 유휴 커넥션을 빌려 또 누수시킨다.', false),
(17174, 6373, '5', '예외가 나면 커넥션이 자동으로 풀에 돌아간다고 본 오해다. 이 코드에는 finally나 try-with-resources가 없어 예외 경로에서 close()가 불리지 않고, 그 커넥션은 풀로 돌아오지 않는다.', false),

-- 문제 6374
(17175, 6374, '대여 대기가 30초를 넘긴 요청이 쓰던 커넥션을 풀이 실패로 보고 닫은 기록이다.', 'connection-timeout 30,000ms는 커넥션을 빌리려고 기다리는 한계라, 넘기면 그 요청이 예외로 끝날 뿐 커넥션을 닫지 않는다. 이날은 오류 응답이 없었고 닫힌 이유도 maxLifetime이다.', false),
(17176, 6374, 'DB가 wait_timeout에 걸린 커넥션을 먼저 끊어서, 풀이 뒤늦게 그 커넥션을 정리한 기록이다.', 'wait_timeout은 8시간인데 커넥션은 만든 지 30분이 안 돼 닫혔다. DB가 끊기 훨씬 전에 풀이 먼저 교체한 것이며, max-lifetime을 wait_timeout보다 짧게 둔 의도대로 동작했다.', false),
(17177, 6374, '빌려 간 뒤 돌려받지 못한 커넥션을 풀이 누수로 판단해 강제로 회수한 기록이다.', '로그에 적힌 사유는 누수가 아니라 maxLifetime 초과다. 풀은 반납되지 않은 커넥션을 대여 중으로 볼 뿐 스스로 회수하지 않으며, 그래서 누수는 반납을 코드로 보장해 막아야 한다.', false),
(17178, 6374, '만든 지 30분 가까이 된 커넥션을 풀이 스스로 폐기하고 새 커넥션으로 채운 정상 동작이다.', 'max-lifetime 1,800,000ms는 30분이다. 09:00에 만든 conn4·conn7과 09:29에 만든 conn10이 약 30분 뒤 닫히고 곧바로 새 커넥션이 채워졌다. 한꺼번에 교체되지 않도록 수명보다 조금 일찍, 제각각 닫힌다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2080, 6375, 'try-with-resources,try with resources,trywithresources,try-with-resource,try with resource,try-with-resources 문,try-with-resources문,트라이 위드 리소스,트라이-위드-리소스,트라이위드리소스,ARM,automatic resource management', 'try 뒤 괄호 안에 AutoCloseable 자원을 선언하면, 블록이 정상으로 끝나든 예외로 빠져나가든 블록을 벗어날 때 선언 역순으로 close()를 자동 호출하는 문법이 try-with-resources다. 고치기 전에는 executeUpdate()의 예외로 conn.close() 줄을 건너뛰어 커넥션이 하나씩 반납되지 않았고(커넥션 누수), 쌓이다가 풀이 비자 모든 요청이 connection-timeout 30초를 넘겨 실패했다. 고친 코드에 close() 호출이 하나도 없어도 반납이 보장되는 것은 이 문법이 대신 불러 주기 때문이다. 풀 환경에서 close()는 연결을 끊는 것이 아니라 풀에 반납하는 동작이다. try-finally에서 close()를 부르는 방식도 반납은 보장하지만 close()를 직접 써야 하므로 이 코드와는 다르고, 예외를 잡아 처리하는 try-catch는 자원을 닫아 주지 않는다.'),
       (2081, 6376, 'minimum-idle,minimumIdle,minimum idle,minimumidle,spring.datasource.hikari.minimum-idle,spring.datasource.hikari.minimumIdle,min-idle,minIdle,최소 유휴 커넥션,최소 유휴 커넥션 수,최소 유휴 수', '풀이 유지할 최소 유휴 커넥션 수가 minimum-idle이다. 1주차에는 값이 2라 새벽에 쓰이지 않은 커넥션이 정리되고 2개만 남았고, 출근 트래픽이 몰리자 모자란 8개를 그 자리에서 새로 맺느라 첫 1분 p99가 180ms로 뛰었다. 2주차에 10으로 바꾸자 새벽에도 10개가 유휴로 유지돼 새로 맺을 커넥션이 없었고 p99가 평소와 같은 35ms였다. 기본값은 maximum-pool-size와 같아서, 따로 줄이지 않으면 풀은 고정 크기로 동작한다. maximum-pool-size는 풀이 가질 수 있는 커넥션의 상한으로 두 주 모두 10이었고, connection-timeout은 대여를 기다리는 한계, max-lifetime은 커넥션 하나의 최대 수명이라 유휴 커넥션을 몇 개 남길지와는 관계가 없다.');
