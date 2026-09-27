-- Unit: 에러 핸들링과 프로세스 안정성 (Unit ID: 130)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (556, 130, '에러 우선 콜백과 우아한 종료'),
       (714, 130, '운영 오류 분류와 크래시 직전 로깅'),
       (872, 130, 'Node.js 크래시 대응과 안전한 종료 설계');

-- =====================================================
-- Lesson 556: 에러 우선 콜백과 우아한 종료
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3515, 556, '아래 코드를 실행했을 때의 동작으로 옳은 것은?', '```javascript
const fs = require(''fs'');

try {
  fs.readFile(''/no/such/file.txt'', (err, data) => {
    if (err) throw err;
    console.log(data.length);
  });
} catch (e) {
  console.log(''caught:'', e.code);
}

console.log(''end of script'');
```', 'OBJECTIVE'),
       (3516, 556, '아래 두 장애에 대한 대응으로 옳은 것은?', '[사건 1] 결제 게이트웨이 호출이 5초 타임아웃으로 실패했다. 지수 백오프로 2회 재시도했으나 모두 실패해 해당 요청에만 502를 반환했다. 같은 시간대의 다른 요청 4,300건은 정상 처리됐다.

[사건 2] 주문 저장 도중 order.items가 undefined인 상태에서 order.items.length를 읽어 TypeError가 발생했다. 이 시점에 DB 트랜잭션은 열린 채였고, 재고 카운터는 이미 1 감소한 뒤였다.', 'OBJECTIVE'),
       (3517, 556, '아래 표를 바탕으로 옳지 않은 것은?', '| 잡히지 않은 실패 | 리스너 없음 | 리스너 있음 |
| --- | --- | --- |
| 동기 throw → uncaughtException | 스택을 출력하고 종료 코드 1로 종료 | 리스너 실행 후 프로세스 계속 실행 |
| Promise 거부 → unhandledRejection (Node 15+ 기본 throw 모드) | uncaughtException으로 승격되어 종료 | 리스너 실행 후 프로세스 계속 실행 |', 'OBJECTIVE'),
       (3518, 556, '아래 종료 로그에서 파드가 강제 종료된 원인으로 옳은 것은?', '```
12:00:00  SIGTERM received -> health check now returns 503
12:00:00  server.close() called
12:00:02  in-flight requests: 0 / open sockets: 128 (idle, keep-alive)
12:00:10  in-flight requests: 0 / open sockets: 128 (idle, keep-alive)
12:00:10  server.close() callback: not called yet
12:00:30  SIGKILL: terminationGracePeriodSeconds 30s exceeded
```', 'OBJECTIVE'),
       (3519, 556, '아래에서 라이브러리가 지키지 않아 문제가 된 Node.js 규약의 이름은?', '팀이 만든 캐시 라이브러리는 콜백에 값 하나만 넘겨 호출한다. 실패를 알릴 자리가 없어 라이브러리 내부에서는 그냥 throw를 던지는데, 아래처럼 감싸도 catch 블록은 한 번도 실행되지 않았고 그때마다 프로세스가 종료 코드 1로 죽었다.

```javascript
try {
  cache.get(''user:1'', (value) => res.json(value));
} catch (e) {
  res.status(500).end();
}
```

시그니처를 fs.readFile과 같은 형태로 바꾸자 호출부가 실패를 응답으로 돌릴 수 있게 됐고, 프로세스는 더 이상 죽지 않았다.', 'SUBJECTIVE'),
       (3520, 556, '아래에서 종료 절차를 다시 짠 뒤 갖추게 된 방식의 이름은?', '쿠버네티스 롤링 배포를 돌릴 때마다 API 게이트웨이 대시보드에 5xx가 배포당 평균 312건씩 찍혔다. 확인해 보니 SIGTERM을 받은 파드가 곧바로 process.exit(0)을 호출해, 응답을 기다리던 요청과 아직 플러시되지 않은 로그가 연결째 사라지고 있었다.

종료 절차를 다시 짠 뒤 같은 규모의 배포에서 5xx는 0건이 됐다. 대신 파드 하나가 사라지기까지 걸리는 시간이 평균 0.2초에서 4.1초로 늘었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3515
(9547, 3515, '콘솔에 caught: ENOENT가 출력되고 스크립트가 정상 종료된다.', 'readFile의 콜백은 파일 I/O가 끝난 뒤 다른 스택에서 실행되므로, 이미 빠져나온 try 블록의 catch는 그 예외를 받을 수 없다.', false),
(9548, 3515, 'end of script가 먼저 출력된 뒤, 콜백의 throw가 어디에서도 잡히지 않아 uncaughtException으로 프로세스가 종료된다.', 'readFile은 비동기라 콜백만 등록하고 즉시 반환해 마지막 줄이 먼저 실행된다. 이후 콜백에서 던진 예외는 try 밖의 스택에서 발생해 uncaughtException 경로로 간다.', true),
(9549, 3515, '파일을 찾지 못하면 readFile이 콜백을 호출하지 않으므로 아무 예외도 발생하지 않는다.', '실패해도 콜백은 반드시 호출되며 첫 인자 err에 Error가 담긴다. 호출 자체가 생략된다고 보면 에러 우선 콜백의 실패 경로를 놓치게 된다.', false),
(9550, 3515, '잡히지 않은 예외가 unhandledRejection 이벤트로 전달되어 경고만 남고 실행이 계속된다.', 'unhandledRejection은 Promise 거부가 처리되지 않았을 때의 이벤트다. 여기서는 Promise가 없는 동기 throw이므로 uncaughtException 경로를 탄다.', false),

-- 문제 3516
(9551, 3516, '두 사건 모두 전역 예외 핸들러에서 로그만 남기고 프로세스를 계속 실행하는 편이 가용성에 유리하다.', '사건 2처럼 버그로 상태가 깨진 뒤 계속 실행하면 열린 트랜잭션과 어긋난 재고 카운터를 안고 서비스하게 된다. 가용성을 얻는 대신 데이터 정합성을 잃는다.', false),
(9552, 3516, '사건 1이 반복된다면 프로세스를 재시작해야 근본 원인이 해소된다.', '타임아웃은 외부 의존성의 문제이지 프로세스 상태의 문제가 아니다. 재시작해도 게이트웨이는 그대로이며, 타임아웃·재시도·서킷 브레이커로 요청 경계에서 다뤄야 한다.', false),
(9553, 3516, '사건 1은 요청 단위로 처리하고 프로세스를 유지하되, 사건 2는 정리 작업 뒤 프로세스를 종료하고 재시작해야 한다.', '사건 1은 정상 코드가 만나는 예상 가능한 실패라 응답으로 바꾸면 되지만, 사건 2는 버그가 트랜잭션·카운터 상태를 깨뜨린 뒤라 프로세스를 새로 띄우는 것이 정석이다.', true),
(9554, 3516, '사건 2는 해당 요청에만 500을 반환하고 프로세스는 그대로 두면 충분하다.', '응답만 돌려주면 열린 트랜잭션과 1 감소한 재고 카운터가 그대로 남는다. 버그가 남긴 오염된 상태는 요청 경계에서 되돌릴 수 없다.', false),

-- 문제 3517
(9555, 3517, 'Node 15 이상에서는 리스너를 등록하지 않아도 미처리 Promise 거부가 경고만 남기고 프로세스는 계속 실행된다.', '표의 둘째 행처럼 Node 15부터 기본 모드가 throw라 리스너가 없으면 uncaughtException으로 승격되어 종료된다. 경고만 남기고 넘어가는 것은 Node 15 이전 동작이다.', true),
(9556, 3517, 'uncaughtException 리스너를 등록하면 종료 코드 1로 죽던 프로세스가 살아남지만, 예외 지점의 상태를 믿을 수 없어 정리 후 종료가 권장된다.', '표의 첫 행 오른쪽 칸대로 리스너가 있으면 계속 실행된다. 다만 예외가 어디서 났는지 모르므로 공식 문서는 동기적 정리만 하고 종료하라고 명시한다.', false),
(9557, 3517, 'unhandledRejection 리스너에서 받은 이유를 그대로 다시 throw하면 두 종류의 실패를 uncaughtException 한 경로로 모을 수 있다.', '리스너 안의 throw는 잡는 곳이 없는 동기 예외라 표의 첫 행 경로를 탄다. 종료·정리 처리를 한 군데로 모으려고 쓰는 방법이다.', false),
(9558, 3517, '기본 종료 동작은 그대로 두고 예외를 관찰만 하려면 uncaughtExceptionMonitor를 쓰면 된다.', 'uncaughtException 리스너를 달면 표의 오른쪽 칸처럼 기본 종료가 사라진다. Monitor 이벤트는 기본 동작을 바꾸지 않고 기록만 하므로 관찰 용도에 맞다.', false),

-- 문제 3518
(9559, 3518, '유휴 keep-alive 연결이 열린 채로 남아 server.close()가 끝내 완료되지 못했다.', 'server.close()는 새 연결만 막고 이미 열린 연결이 모두 닫혀야 콜백을 부른다. closeIdleConnections()로 유휴 소켓을 끊어야 종료가 진행된다.', true),
(9560, 3518, '진행 중인 요청이 남아 있어 server.close()의 콜백이 호출되지 못했다.', '로그의 in-flight requests가 10초 뒤에도 0이다. 처리 중인 요청이 없었으므로 대기 원인이 될 수 없다.', false),
(9561, 3518, '헬스체크가 503을 반환해 로드밸런서가 종료 절차를 되돌렸다.', '503은 트래픽을 먼저 빼내려고 일부러 만든 상태이며, 로드밸런서는 프로세스의 종료 절차에 개입하지 않는다. 순서상 옳게 동작한 부분이다.', false),
(9562, 3518, 'SIGTERM 리스너가 없어 기본 동작대로 유예 시간이 끝날 때까지 대기했다.', '로그 첫 두 줄에서 신호를 받아 헬스체크를 바꾸고 server.close()까지 호출했으므로 리스너는 등록돼 있었다. 기본 동작이었다면 즉시 종료됐을 것이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1128, 3519, '에러 우선 콜백,에러퍼스트 콜백,에러 퍼스트 콜백,error-first callback,error first callback,errorfirst callback,errback', 'Node.js 코어의 비동기 API는 콜백의 첫 인자를 실패 자리로 비워 두는 에러 우선 콜백(error-first callback) 규약을 따른다. 성공하면 첫 인자가 null이고 결과는 두 번째 인자로 온다. 이 자리가 없으면 라이브러리가 실패를 알릴 방법은 throw뿐인데, 콜백은 호출부의 try 블록이 이미 끝난 뒤 다른 스택에서 실행되므로 그 예외는 catch에 닿지 못하고 uncaughtException이 되어 프로세스를 죽인다. Promise 기반 API는 실패를 거부(rejection)로 전달해 .catch()나 await + try/catch로 잡고, 아무도 잡지 않으면 unhandledRejection이 된다는 점에서 전파 경로가 다르니 구분한다.'),
       (1129, 3520, '우아한 종료,우아한종료,그레이스풀 셧다운,그레이스풀 종료,graceful shutdown,graceful-shutdown,gracefulshutdown', 'SIGTERM을 받으면 새 연결 수락을 멈추고, 헬스체크를 실패로 바꿔 로드밸런서가 트래픽을 먼저 빼게 한 뒤, 유휴 keep-alive 연결을 정리하고 진행 중인 요청이 끝나기를 기다렸다가 DB 풀과 로그를 정리하고 종료하는 절차가 우아한 종료다. 배포당 5xx가 312건에서 0건이 된 대신 파드 종료 시간이 0.2초에서 4.1초로 늘어난 것이 그 대가이며, 유예 시간을 넘기면 강제 종료되므로 타임아웃 안에 끝나도록 설계해야 한다. 신호를 받자마자 이벤트 루프를 멈추는 process.exit()이나 오케스트레이터가 유예 시간 뒤 보내는 SIGKILL은 진행 중인 작업을 기다리지 않는 강제 종료라는 점에서 구분한다.');

-- =====================================================
-- Lesson 714: 운영 오류 분류와 크래시 직전 로깅
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4463, 714, '아래 코드를 실행했을 때의 동작으로 옳은 것은?', '```javascript
const { EventEmitter } = require(''events'');

const job = new EventEmitter();
job.on(''done'', () => console.log(''done''));

try {
  job.emit(''error'', new Error(''disk full''));
  console.log(''after emit'');
} catch (e) {
  console.log(''caught:'', e.message);
}

console.log(''end'');
```', 'OBJECTIVE'),
       (4464, 714, '아래 상황에서 이어서 벌어지는 일로 옳은 것은?', '주문 API는 Node.js 20과 Express 4로 운영되며, unhandledRejection·uncaughtException 리스너는 어느 것도 등록돼 있지 않다.

```javascript
app.get(''/orders/:id'', async (req, res) => {
  const order = await db.findOrder(req.params.id);
  res.json(order);
});

app.use((err, req, res, next) => {
  res.status(500).json({ message: ''internal error'' });
});
```

새벽에 DB 장애 조치(failover)가 진행되는 동안 db.findOrder() 호출 하나가 거부(reject)됐다. 그 순간 같은 프로세스는 다른 요청 800건을 처리하고 있었다.', 'OBJECTIVE'),
       (4465, 714, '아래 배치 스크립트에서 실패 로그가 파일에 남지 않은 원인으로 옳은 것은?', '매일 새벽에 도는 정산 배치다. logger는 기록을 메모리 버퍼에 모아 두었다가 비동기로 파일에 쓴다.

```javascript
async function main() {
  const rows = await fetchSettlements();
  await uploadReport(rows);
}

main().catch((err) => {
  logger.error({ err }, ''settlement failed'');
  process.exit(1);
});
```

어젯밤 uploadReport()가 실패했다. 스케줄러에는 종료 코드 1이 기록됐지만, 로그 파일에는 settlement failed 줄이 남아 있지 않았다.', 'OBJECTIVE'),
       (4466, 714, '아래 종료 기록에서 연결 거부를 없애는 조치로 옳은 것은?', '쿠버네티스에서 롤링 배포를 할 때마다, 종료되는 파드로 간 요청 일부가 연결 거부(ECONNREFUSED)로 실패한다. 파드 하나의 종료 과정을 기록한 결과는 다음과 같다.

| 경과 시간 | 기록 |
| --- | --- |
| 0.0초 | SIGTERM 수신, 곧바로 server.close() 호출 |
| 0.0~2.8초 | 이 파드로 들어온 새 요청 173건이 연결 거부로 실패 |
| 2.8초 | 서비스 엔드포인트 목록에서 이 파드가 빠짐 |
| 3.1초 | 진행 중인 요청 0건 확인, db.end() 후 process.exit(0) |

terminationGracePeriodSeconds는 30초이며, 종료는 매번 SIGKILL 없이 3초 남짓에 끝났다.', 'OBJECTIVE'),
       (4467, 714, '아래에서 첫 번째 인자를 바꿔 새로 등록한 process 이벤트의 이름은?', '결제 서버는 크래시 직전의 스택을 crash.log에 남기려고 아래 한 줄을 넣었다. writeCrash()는 fs.appendFileSync()로 스택을 파일에 동기적으로 쓴다.

```javascript
process.on(''uncaughtException'', writeCrash);
```

그 뒤로는 버그가 터져도 프로세스가 죽지 않았다. 이틀 동안 DB 커넥션 풀 사용률이 100%에 머문 채 요청이 줄줄이 타임아웃됐고, PM2 대시보드의 재시작 횟수는 0이었다.

writeCrash는 그대로 두고 process.on의 첫 번째 인자만 바꾸자, 같은 버그가 터졌을 때 crash.log에는 스택이 남으면서도 프로세스는 종료 코드 1로 끝났고 PM2가 곧바로 새 프로세스를 띄웠다.', 'SUBJECTIVE'),
       (4468, 714, '아래 회고에서 묶음 A에 모인 오류들을 가리키는 분류 이름은?', '주문 서비스의 한 달 치 오류 로그를 회고하면서 오류를 두 묶음으로 나눴다.

| 묶음 A | 묶음 B |
| --- | --- |
| 배송 조회 API가 3초 안에 응답하지 않아 타임아웃 | cart.coupon이 null인데 .rate를 읽어 TypeError 발생 |
| 사용자가 올린 파일이 20MB 업로드 제한을 넘음 | formatPrice()를 필수 인자 없이 호출 |
| 탈퇴한 회원 ID로 주문 내역을 조회해 404 | 배열을 받아야 하는 함수에 문자열을 넘겨 호출 |

묶음 B의 오류는 코드를 고쳐 배포한 뒤에야 사라졌다. 묶음 A의 오류는 코드를 전혀 바꾸지 않은 주에도 매주 비슷한 건수로 되풀이됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4463
(12075, 4463, 'after emit과 end가 차례로 출력되고 프로세스는 정상 종료된다.', '리스너 없는 이벤트는 조용히 무시된다는 규칙을 ''error''에도 적용한 오개념이다. ''error'' 이벤트만은 리스너가 없으면 emit()을 호출한 자리에서 넘겨받은 Error를 그대로 throw한다.', false),
(12076, 4463, 'caught: disk full과 end가 차례로 출력되고 프로세스는 정상 종료된다.', '''error'' 리스너가 없으면 emit()이 그 자리에서 Error를 동기적으로 throw해, 감싸고 있던 try/catch가 잡는다. 실제 소켓·스트림은 I/O 콜백 안에서 emit하므로 잡을 곳이 없어 프로세스가 죽는다.', true),
(12077, 4463, 'after emit과 end가 출력된 뒤 uncaughtException으로 프로세스가 종료된다.', '''error''가 나중에 다른 스택에서 던져진다고 본 오개념이다. emit()은 리스너 호출과 throw를 모두 동기적으로 처리하므로, after emit 줄에 닿기 전에 실행이 catch 블록으로 넘어간다.', false),
(12078, 4463, 'console.log가 하나도 실행되지 않고 uncaughtException으로 프로세스가 곧바로 종료된다.', '''error'' 이벤트는 try/catch를 건너뛰고 무조건 프로세스를 죽인다고 본 오개념이다. 던지는 위치가 emit() 호출 지점이라, 같은 스택의 try/catch가 평범한 throw처럼 잡는다.', false),

-- 문제 4464
(12079, 4464, '오류 처리 미들웨어가 호출돼 해당 요청만 500 응답을 받고, 나머지 800건은 정상 처리된다.', 'Express 4는 핸들러가 반환한 Promise를 확인하지 않아 거부가 next(err)로 전달되지 않는다. 비동기 핸들러의 거부를 오류 처리 미들웨어로 넘겨주는 것은 Express 5·NestJS·Fastify의 동작이다.', false),
(12080, 4464, '미처리 거부 경고만 출력되고, 해당 요청은 응답 없이 멈춘 채 나머지 요청은 계속 처리된다.', 'Node.js 15 이전의 기본 동작이다. 15부터 기본 모드가 throw로 바뀌어, 리스너가 없는 미처리 거부는 잡히지 않은 예외로 승격되고 프로세스가 끝난다.', false),
(12081, 4464, '거부가 난 요청의 연결만 끊기고, 나머지 800건은 영향 없이 같은 프로세스에서 계속 처리된다.', '요청마다 격리된 실행 단위가 있다고 본 오개념이다. Node.js는 프로세스 하나가 모든 요청을 함께 처리하므로, 잡히지 않은 예외로 프로세스가 끝나면 진행 중이던 연결도 모두 끊긴다.', false),
(12082, 4464, '프로세스가 종료 코드 1로 끝나면서, 처리 중이던 다른 요청 800건의 연결도 함께 끊긴다.', 'Express 4가 거부를 잡지 않고 리스너도 없어, 미처리 거부가 Node.js 20의 기본 throw 모드에서 잡히지 않은 예외로 승격돼 종료된다. 요청들이 프로세스 하나를 공유하므로 800건도 함께 끊긴다.', true),

-- 문제 4465
(12083, 4465, 'process.exit()가 남은 비동기 쓰기 작업을 기다리지 않고 프로세스를 곧바로 끝냈다.', 'process.exit()는 이벤트 루프를 즉시 멈추므로 버퍼에 쌓인 로그가 파일에 쓰이기 전에 프로세스가 끝난다. process.exitCode = 1만 두고 자연 종료되게 하거나, 로거 플러시를 기다린 뒤 종료해야 한다.', true),
(12084, 4465, 'main() 안에 try/catch가 없어 uploadReport()의 거부가 catch 콜백까지 전파되지 않았다.', 'await한 Promise가 거부되면 async 함수가 반환한 Promise도 거부되어 바깥 .catch()로 전파된다. 종료 코드 1이 남은 것도 catch 콜백의 process.exit(1)이 실행됐음을 보여 준다.', false),
(12085, 4465, '종료 코드 1은 강제 종료를 뜻하므로, 스케줄러가 SIGKILL로 프로세스를 먼저 죽였다.', '종료 코드 1은 코드가 process.exit(1)로 직접 넘긴 값과 일치한다. SIGKILL로 죽은 프로세스는 셸·컨테이너에서 보통 128에 신호 번호 9를 더한 137로 기록된다.', false),
(12086, 4465, 'process.exit(1)이 버퍼 쓰기를 일정 시간 기다렸지만, 파일 쓰기가 그 시간을 넘겨 취소됐다.', 'process.exit()에 대기 시간이 있다고 본 오개념이다. 남은 비동기 작업을 전혀 기다리지 않으므로, 정리 시간이 필요하면 플러시 완료를 직접 기다리고 강제 종료 타임아웃은 따로 둬야 한다.', false),

-- 문제 4466
(12087, 4466, 'terminationGracePeriodSeconds를 30초에서 60초로 늘려 종료 절차에 쓸 시간을 더 준다.', '시간이 모자라 생긴 문제로 본 오개념이다. 종료는 3.1초에 SIGKILL 없이 끝났고 실패는 엔드포인트에서 빠지기 전인 0~2.8초에 몰려 있어, 유예 시간을 늘려도 달라지지 않는다.', false),
(12088, 4466, 'server.close()보다 closeIdleConnections()를 먼저 호출해 유휴 keep-alive 연결부터 정리한다.', '유휴 연결 정리는 close 콜백이 끝나지 않아 종료가 SIGKILL까지 늘어지는 문제를 막는 조치다. 이 기록의 실패는 이미 닫힌 서버로 새 요청이 들어와 생긴 것이라 원인과 맞지 않는다.', false),
(12089, 4466, '헬스체크를 먼저 실패로 바꾸고 몇 초 기다려 엔드포인트에서 빠진 뒤 server.close()를 호출한다.', '엔드포인트 갱신은 SIGTERM과 따로 진행돼 2.8초가 걸렸고, 그 사이 이미 닫힌 서버로 요청이 들어왔다. 트래픽이 빠질 때까지 요청을 계속 받다가 수락을 멈춰야 하며, preStop 훅의 대기도 같은 목적이다.', true),
(12090, 4466, 'SIGTERM을 받자마자 process.exit(0)을 호출해 거부가 생길 틈 없이 곧바로 종료한다.', '빨리 끝내면 된다고 본 오개념이다. 엔드포인트에서 빠지기 전에 들어온 요청은 여전히 실패하고, 처리 중이던 요청과 플러시 전 로그까지 함께 사라져 피해가 커진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1444, 4467, 'uncaughtExceptionMonitor,uncaughtExceptionMonitor 이벤트,uncaught exception monitor,uncaughtException monitor', 'uncaughtExceptionMonitor(Node.js 13.7+) 리스너는 잡히지 않은 예외가 기본 처리로 넘어가기 직전에 호출되지만, 스택을 출력하고 종료 코드 1로 끝내는 기본 종료 동작은 바꾸지 않는다. 그래서 writeCrash가 스택을 남긴 뒤에도 프로세스는 죽고 PM2가 새 프로세스를 띄운다. 리스너가 끝나면 곧바로 종료가 이어지므로 본문처럼 동기 쓰기로 기록해야 안전하다. 처음 등록한 uncaughtException 리스너는 기본 종료를 없애 버려, 예외가 어디서 났는지 모르는 오염된 상태(반환되지 않은 커넥션, 어긋난 카운터)로 계속 서비스하게 만든다. ''exit'' 이벤트는 종료 코드만 받고 Error 객체를 받지 못하며, unhandledRejection은 Promise 거부에만 반응한다는 점에서 구분한다.'),
       (1445, 4468, '운영 오류,운영 에러,운영상 오류,운영상의 오류,운영오류,operational error,operational errors', '배송 조회 API 타임아웃, 업로드 용량 초과, 없는 회원 조회(404)는 코드가 올바르게 짜여 있어도 외부 환경이나 사용자 입력 때문에 런타임에 생길 수 있는 예상 가능한 실패로, 운영 오류(operational error)라 부른다. 코드를 바꾸지 않은 주에도 비슷한 건수로 되풀이된 것이 그 신호다. 운영 오류는 재시도·대체 응답·4xx/5xx 응답처럼 요청 단위로 처리하고 프로세스는 유지한다. 묶음 B의 null 속성 읽기·필수 인자 누락·잘못된 타입 전달은 코드 자체의 버그인 프로그래머 오류(programmer error)로, 상태를 믿을 수 없어 정리 후 프로세스를 재시작하고 코드를 고쳐야 한다는 점에서 구분한다. 실무에서는 AppError의 isOperational 같은 플래그로 두 경우를 나눠 처리한다.');

-- =====================================================
-- Lesson 872: Node.js 크래시 대응과 안전한 종료 설계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5411, 872, '아래 코드의 출력과 그 뒤의 프로세스 동작으로 옳은 것은?', 'Node.js 20에서 실행하며, unhandledRejection·uncaughtException 리스너는 등록돼 있지 않다.

```javascript
async function notify(id) {
  if (id === 2) throw new Error(''push failed'');
  console.log(''sent'', id);
}

function sendAll(ids) {
  try {
    ids.forEach(async (id) => {
      await notify(id);
    });
    console.log(''all sent'');
  } catch (e) {
    console.log(''caught:'', e.message);
  }
}

sendAll([1, 2, 3]);
```', 'OBJECTIVE'),
       (5412, 872, '아래 운영 방식에서 크래시 때마다 생기는 주문 실패를 없애는 방법으로 옳은 것은?', '주문 서버는 VM 한 대에서 PM2로 Node.js 프로세스 하나만 띄워 운영한다. 얼마 전 uncaughtException 핸들러를 로그 기록 → 정리 → 종료 순서로 바꿨고, 버그로 프로세스가 죽으면 PM2가 크래시 직후 곧바로 새 프로세스를 띄운다.

그런데 새 프로세스가 설정을 읽고 DB 커넥션 풀을 연결해 요청을 받기까지 약 8초가 걸린다. 그 8초 동안 들어온 주문 요청은 모두 연결 거부(ECONNREFUSED)로 실패하며, 이런 크래시가 하루 평균 3번 일어난다.', 'OBJECTIVE'),
       (5413, 872, '아래 상황에서 프로세스가 끝나는 시점과 종료 코드로 옳은 것은?', '쿠버네티스 롤링 배포 중 파드가 SIGTERM을 받은 순간, 서버에는 처리에 25초가 더 걸리는 보고서 내보내기 요청 1건이 진행 중이었고 나머지 연결은 모두 유휴 keep-alive 상태였다. terminationGracePeriodSeconds는 30초이며, 종료 처리 코드는 다음과 같다.

```javascript
const server = app.listen(3000);
let shuttingDown = false;

function shutdown(code = 0) {
  if (shuttingDown) return;
  shuttingDown = true;

  const force = setTimeout(() => process.exit(code || 1), 10_000).unref();

  server.close(async () => {
    await db.end();
    clearTimeout(force);
    process.exit(code);
  });
  server.closeIdleConnections();
}

process.on(''SIGTERM'', () => shutdown(0));
```', 'OBJECTIVE'),
       (5414, 872, '아래 종료 기록에서 메일 중복 발송을 막기 위해 고쳐야 할 점으로 옳은 것은?', '이메일 발송 워커는 큐에서 작업을 하나씩 가져와 처리하며, 작업 하나에 보통 6초 남짓 걸린다. 큐에는 보낼 메일이 항상 수백 건 쌓여 있다. 쿠버네티스 롤링 배포 때 워커 파드 하나의 종료 기록은 다음과 같다.

| 경과 시간 | 기록 |
| --- | --- |
| 0.0초 | SIGTERM 수신, 처리 중인 작업 #41이 끝나기를 기다림 |
| 6.1초 | 작업 #41 완료, 큐에서 작업 #42를 가져와 처리 시작 |
| 12.4초 | 작업 #42 완료, 큐에서 작업 #43을 가져와 처리 시작 |
| 18.9초 | 작업 #43 완료, 큐에서 작업 #44를 가져와 처리 시작 |
| 24.8초 | 작업 #44 완료, 큐에서 작업 #45를 가져와 처리 시작 |
| 30.0초 | 유예 시간(terminationGracePeriodSeconds 30초) 초과로 SIGKILL |

작업 #45는 완료 확인을 보내지 못한 채 끊겨 다른 워커가 처음부터 다시 처리했고, 고객은 같은 메일을 두 번 받았다.', 'OBJECTIVE'),
       (5415, 872, '아래에서 서버 시작 코드를 고칠 때 따른 설계 원칙의 이름은?', '새 버전에서 DB 접속 주소를 담는 환경 변수 이름을 DATABASE_URL에서 DB_URL로 바꿨지만, 운영 환경 설정에는 반영하지 못했다. 서버는 문제없이 떠서 헬스체크(/health)에 200을 돌려줬고 롤링 배포도 끝까지 진행됐다. 그러나 DB 조회가 필요한 요청은 모두 500으로 실패했고, 원인을 찾기까지 47분이 걸렸다.

서버 시작 코드를 고친 뒤 같은 실수를 재현하자, 새 파드는 요청을 하나도 받기 전에 아래 한 줄을 남기고 1초 만에 종료 코드 1로 끝났다. 롤링 배포는 첫 파드에서 멈췄고, 기존 버전 파드들이 계속 트래픽을 받아 500 응답은 0건이었다.

```
Error: DB_URL is required
```', 'SUBJECTIVE'),
       (5416, 872, '아래에서 결제 호출 앞에 적용한 장애 대응 패턴의 이름은?', '주문 서버는 결제사 API를 호출할 때 5초 타임아웃을 건다. 지난달 결제사가 40분 동안 응답하지 않았을 때 결제 호출은 매번 5초를 다 채운 뒤에야 실패했고, 기다리는 요청이 쌓이면서 결제와 무관한 상품 조회 API까지 응답이 10초를 넘겼다.

이후 결제 호출 앞에 한 가지 패턴을 적용했다. 같은 장애가 다시 났을 때의 기록은 다음과 같다.

| 구간 | 결제사로 보낸 요청 | 결제 호출 결과 |
| --- | --- | --- |
| 14:00:00~14:00:05 | 37건 | 37건 모두 타임아웃 |
| 14:00:05~14:00:35 | 0건 | 1,920건 실패, 평균 2ms |
| 14:00:35 | 1건 | 타임아웃 |
| 14:00:40~14:01:10 | 0건 | 2,050건 실패, 평균 2ms |
| 14:01:10~14:40:35 | 약 35초마다 1건 | 보낸 1건은 타임아웃, 나머지는 평균 2ms에 실패 |
| 14:40:40 | 1건 | 성공 |
| 14:40:40 이후 | 모든 요청 | 정상 응답 |

장애 내내 상품 조회 API의 응답 시간은 평소와 같은 40ms였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5411
(14603, 5411, 'sent 1, caught: push failed가 출력되고, sent 3과 all sent는 출력되지 않는다.', 'async 콜백 안의 throw가 동기 throw처럼 forEach를 멈추고 catch로 간다고 본 오개념이다. async 함수에서 던진 예외는 거부된 Promise로 바뀌어 반환될 뿐이라, forEach는 멈추지 않고 id 3까지 호출한다.', false),
(14604, 5411, 'sent 1, sent 3, all sent가 출력된 뒤, 처리되지 않은 거부로 프로세스가 종료 코드 1로 끝난다.', 'forEach는 async 콜백이 돌려준 Promise를 버려 id 2의 거부를 아무도 기다리지 않는다. try 블록은 동기 부분만 감싼 채 끝나 all sent가 먼저 찍히고, 남은 거부는 Node.js 20의 기본 throw 모드에서 잡히지 않은 예외로 승격돼 종료된다.', true),
(14605, 5411, 'sent 1, sent 3, all sent가 출력된 뒤, caught: push failed가 출력되고 정상 종료된다.', '거부가 나중에 나도 바깥 try/catch가 받아 준다고 본 오개념이다. 거부는 try 블록이 끝난 뒤에 처리되므로 catch에 닿지 않는다. sendAll을 async로 바꾸고 for...of 안에서 await하거나 Promise.all을 await해야 잡힌다.', false),
(14606, 5411, 'sent 1, sent 3, all sent가 출력된 뒤, 경고 한 줄만 남기고 정상 종료된다.', 'Node.js 15 이전의 기본 동작이다. 15부터는 리스너가 없는 미처리 거부를 경고로 넘기지 않고 잡히지 않은 예외로 승격시켜, 프로세스를 종료 코드 1로 끝낸다.', false),

-- 문제 5412
(14607, 5412, '크래시 때 진행 중인 요청을 모두 마치고 끝나도록 종료 전 대기 시간을 늘린다.', '실패는 이전 프로세스가 끝난 뒤 새 프로세스가 요청을 받기까지의 8초 공백에서 생긴다. 종료를 늦춰도 이 공백은 그대로이고, 버그로 상태가 오염된 프로세스를 더 오래 살려 두는 부작용만 생긴다.', false),
(14608, 5412, 'PM2의 재시작 지연을 0초로 설정해 크래시가 나자마자 새 프로세스를 띄운다.', 'PM2는 이미 크래시 직후 곧바로 새 프로세스를 띄우고 있다. 8초는 재시작을 기다리는 시간이 아니라 새 프로세스가 설정을 읽고 DB 커넥션 풀을 연결하는 기동 시간이라 줄어들지 않는다.', false),
(14609, 5412, '종료 전 정리 작업을 건너뛰고 곧바로 process.exit(1)을 호출해 재시작을 앞당긴다.', '공백은 종료가 아니라 새 프로세스의 기동 8초에서 생기므로 종료를 서둘러도 그대로다. 오히려 process.exit()가 이벤트 루프를 즉시 멈춰 플러시 전 로그와 처리 중이던 응답까지 잃는다.', false),
(14610, 5412, '프로세스를 여러 개로 늘려 하나가 다시 뜨는 동안 나머지가 요청을 받게 한다.', '프로세스가 하나뿐이면 그 프로세스의 재시작이 곧 서비스 중단이다. PM2 클러스터 모드나 여러 파드로 프로세스를 늘리면 한 프로세스가 다시 뜨는 8초 동안 나머지가 트래픽을 받아, 크래시가 서비스 장애로 번지지 않는다.', true),

-- 문제 5413
(14611, 5413, 'SIGTERM 후 10초에 강제 종료 타이머로 끝나며, 종료 코드는 1이다.', '보고서 요청의 소켓이 열려 있어 server.close()의 콜백은 25초 뒤에야 불릴 수 있다. 그 전에 10초 타이머가 실행되고, shutdown(0)이라 code || 1이 1로 계산돼 process.exit(1)로 끝나며 진행 중이던 요청은 끊긴다.', true),
(14612, 5413, 'SIGTERM 후 25초에 요청을 마치고 정리한 뒤 끝나며, 종료 코드는 0이다.', 'unref()가 타이머를 취소한다고 본 오개념이다. unref()는 타이머 때문에 프로세스가 살아 있지 않게 할 뿐 취소하지 않는다. 열린 소켓이 프로세스를 살려 두는 동안 10초가 되면 타이머가 그대로 실행된다.', false),
(14613, 5413, 'SIGTERM 후 10초에 강제 종료 타이머로 끝나며, 종료 코드는 0이다.', 'SIGTERM으로 시작한 종료라 0으로 끝난다고 본 오개념이다. 타이머는 process.exit(code || 1)을 호출하는데 code가 0이면 거짓으로 취급돼 1이 된다. 정리를 마치지 못한 종료를 실패로 남기려는 설계다.', false),
(14614, 5413, 'SIGTERM 직후 새 연결을 막자마자 끝나며, 종료 코드는 0이다.', 'server.close()가 기존 연결까지 끊는다고 보거나, unref() 뒤로는 프로세스를 붙잡는 것이 없다고 본 오개념이다. close()는 새 연결만 막으며, 진행 중인 요청의 소켓이 남아 이벤트 루프를 살려 둔다.', false),

-- 문제 5414
(14615, 5414, 'terminationGracePeriodSeconds를 60초로 늘려 마지막 작업까지 끝낼 시간을 준다.', '시간이 모자라 생긴 문제로 본 오개념이다. 워커는 작업을 끝낼 때마다 새 작업을 가져오고 큐는 늘 차 있으므로, 유예 시간을 얼마로 늘려도 SIGKILL 순간에는 또 다른 작업을 처리하고 있다.', false),
(14616, 5414, 'SIGTERM을 받으면 작업 #41을 기다리지 말고 곧바로 process.exit(0)을 호출한다.', '빨리 끝내면 된다고 본 오개념이다. 처리 중이던 #41이 완료 확인 없이 끊겨 다른 워커가 처음부터 다시 처리하므로, 중복 발송이 #45에서 #41로 옮겨 갈 뿐이다.', false),
(14617, 5414, 'SIGTERM을 받는 즉시 큐에서 새 작업 가져오기를 멈추고, #41만 마친 뒤 종료한다.', '큐 워커의 종료 순서는 새 작업 가져오기 중단 → 처리 중인 작업 완료 → 종료다. 이렇게 하면 #41이 끝나는 6.1초에 종료돼 완료 확인을 못 받은 작업이 남지 않는다. HTTP 서버에서 server.close()로 새 연결을 막는 것과 같은 역할이다.', true),
(14618, 5414, 'server.close()로 새 연결을 막고 closeIdleConnections()로 유휴 연결을 정리한다.', 'HTTP 서버의 종료 절차를 그대로 옮긴 오개념이다. 이 워커의 일감은 들어오는 연결이 아니라 스스로 큐에서 가져오는 작업이라, 연결을 정리해도 가져오기 반복은 멈추지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1760, 5415, '페일 패스트,페일패스트,fail fast,fail-fast,failfast,빠른 실패,빠른실패,즉시 실패,페일 패스트 원칙,fail fast 원칙,fail-fast 원칙', '필수 설정과 연결을 프로세스 시작 시점에 검증하고, 하나라도 빠지면 요청을 받기 전에 곧바로 종료 코드 1로 끝내는 것이 페일 패스트(fail fast)다. 처음 배포처럼 잘못된 설정을 안고 ''떠 있지만 동작하지 않는'' 상태가 되면 헬스체크를 통과해 배포가 끝까지 진행되고, 증상은 한참 뒤 요청의 500으로 멀리서 드러나 진단이 가장 어렵다. 시작하자마자 죽으면 새 파드가 준비 상태가 되지 못해 롤링 배포가 멈추고 기존 버전이 계속 트래픽을 받는다. 설정이 없을 때 기본값으로 넘어가 문제를 뒤로 미루는 방식과 반대이며, 이미 떠 있는 서버가 요청 처리 중 만나는 운영 오류(타임아웃·잘못된 입력)는 프로세스를 죽이지 않고 요청 단위로 처리한다는 점과 구분한다.'),
       (1761, 5416, '서킷 브레이커,서킷브레이커,서킷 브레이커 패턴,회로 차단기,회로차단기,circuit breaker,circuitbreaker,circuit-breaker,circuit breaker 패턴,circuit breaker pattern', '연속 실패가 기준을 넘으면 회로를 열어(open) 한동안 외부 호출을 아예 보내지 않고 즉시 실패를 돌려주고, 일정 시간이 지나면 한 건만 시험 삼아 보내(half-open) 성공하면 회로를 닫아(closed) 정상 호출로 돌아가는 방식이 서킷 브레이커다. 본문에서 결제사로 보낸 요청이 0건인데 결과가 평균 2ms에 나온 구간이 열린 상태, 약 35초마다 1건씩 보낸 것이 시험 호출이며, 14:40:40 시험 호출이 성공하자 모든 요청이 다시 전달됐다. 느린 의존성을 기다리는 요청이 쌓이지 않으므로 상품 조회 API처럼 무관한 기능까지 장애가 번지지 않는다. 한 호출을 얼마나 기다릴지 정하는 타임아웃(이미 5초로 걸려 있었다), 실패한 호출을 간격을 늘려 가며 다시 보내는 재시도·지수 백오프와 구분한다.');
