-- Unit: 이벤트 루프와 논블로킹 I/O (Unit ID: 123)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (549, 123, '페이즈 순서와 동기 I/O 블로킹'),
       (707, 123, '타이머 지연과 DNS 스레드 풀 경합'),
       (865, 123, 'poll 대기와 ReDoS·스레드 풀 크기');

-- =====================================================
-- Lesson 549: 페이즈 순서와 동기 I/O 블로킹
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3473, 549, '아래 코드를 실행했을 때 콘솔에 찍히는 순서로 옳은 것은?', '```javascript
const fs = require(''node:fs'');

console.log(''1'');
fs.readFile(__filename, () => {
  setTimeout(() => console.log(''2''), 0);
  setImmediate(() => console.log(''3''));
});
console.log(''4'');
```

읽는 파일은 항상 존재하며, 예외는 발생하지 않는다.', 'OBJECTIVE'),
       (3474, 549, '아래 이벤트 루프 페이즈 표를 바탕으로 옳지 않은 것은?', '| 순서 | 페이즈 | 실행되는 콜백 |
| --- | --- | --- |
| 1 | timers | 만료 시각이 지난 setTimeout·setInterval |
| 2 | pending callbacks | 지연된 시스템 콜백 |
| 3 | idle, prepare | 내부 처리용 |
| 4 | poll | 파일·소켓 등 I/O 완료 콜백 |
| 5 | check | setImmediate |
| 6 | close callbacks | 소켓·핸들 종료 핸들러 |

이벤트 루프는 위 순서대로 페이즈를 한 바퀴씩 순회하며, 각 페이즈에서 자기 큐의 콜백을 비운 뒤 다음 페이즈로 넘어간다.', 'OBJECTIVE'),
       (3475, 549, '아래 실행 로그에서 다섯째·여섯째 작업만 완료가 두 배로 늦어진 이유로 옳은 것은?', '```
$ node bench.js   # crypto.pbkdf2를 반복문에서 6번 연달아 예약, 호출 하나당 약 0.5초 소요
작업 1 완료: 512ms
작업 2 완료: 515ms
작업 3 완료: 517ms
작업 4 완료: 520ms
작업 5 완료: 1,032ms
작업 6 완료: 1,035ms
```

측정 장비의 코어는 8개이고, Node.js는 기본 설정 그대로 실행했다.', 'OBJECTIVE'),
       (3476, 549, '아래 서버에 요청 10개가 동시에 도착했을 때 나타나는 현상으로 옳은 것은?', '```javascript
const app = express();

// report.html을 읽는 데 평균 300ms가 걸린다.
app.get(''/report'', (req, res) => {
  res.send(fs.readFileSync(''report.html'', ''utf8''));
});
```

서버는 기본 설정의 Node.js 프로세스 하나로 실행 중이며, 클러스터나 워커 스레드는 쓰지 않는다.', 'OBJECTIVE'),
       (3477, 549, '아래 관찰에서 이벤트 루프가 멈춰 대기하던 페이즈의 이름은?', '요청이 없는 동안 서버 프로세스의 CPU 사용률은 0%에 가까웠고, 이벤트 루프는 순회 도중 한 지점에 멈춰 있었다. 이때 setTimeout(fn, 500)만 예약해 두면 500ms 뒤에 그 지점에서 깨어났고, setImmediate(fn)를 예약해 두면 아예 기다리지 않고 곧장 다음 단계로 넘어갔다. 소켓에 새 데이터가 도착했을 때도 프로세스는 이 지점에서 깨어나 등록해 둔 처리 함수를 실행했다.', 'SUBJECTIVE'),
       (3478, 549, '아래 관찰에 나타난 Node.js 내부 라이브러리의 이름은?', '리눅스 서버에서 Node.js 프로세스의 스레드를 나열했더니 JavaScript를 실행하는 스레드 말고도 워커 스레드가 4개 더 떠 있었고, 그중 하나는 epoll_wait 시스템 콜에 걸린 채 대기 중이었다. 같은 코드를 macOS에서 실행하자 이번에는 kqueue가, 윈도우에서는 IOCP가 쓰였지만 애플리케이션 코드는 한 줄도 고치지 않았다. JavaScript를 컴파일·실행하는 V8이 아니라 C로 작성된 다른 구성 요소가 이 차이를 감춰 준다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3473
(9435, 3473, '1 → 4 → 2 → 3', 'timers가 check보다 앞 페이즈라는 이유로 setTimeout이 먼저라고 본 오답. 두 콜백은 poll 페이즈인 readFile 콜백 안에서 예약되므로, 바로 뒤에 오는 check가 다음 순회의 timers보다 먼저 도달한다.', false),
(9436, 3473, '1 → 4 → 3 → 2', '동기 코드 1·4가 먼저 끝나고, readFile 콜백은 poll 페이즈에서 실행된다. 그 안에서 예약한 setImmediate는 바로 다음 check 페이즈에서, setTimeout(0)은 다음 순회의 timers에서 실행되므로 3이 2보다 앞선다.', true),
(9437, 3473, '1 → 2 → 3 → 4', 'readFile 콜백이 호출 즉시 실행된다고 본 오답. 논블로킹 I/O는 요청만 등록하고 곧바로 다음 줄로 넘어가므로, 콜백은 동기 코드가 모두 끝나 콜 스택이 빈 뒤에야 실행된다.', false),
(9438, 3473, '1 → 3 → 4 → 2', 'setImmediate를 이름 그대로 ''지금 즉시''로 읽은 오답. 이 콜백도 콜 스택이 비고 이벤트 루프가 check 페이즈에 닿아야 실행되므로 동기 코드 4보다 앞설 수 없다.', false),

-- 문제 3474
(9439, 3474, '만료 시각이 지난 setTimeout 콜백은 같은 순회에서 파일 읽기 완료 콜백보다 먼저 실행된다.', '참인 진술이다. 타이머는 1번, I/O 완료 콜백은 4번 페이즈에서 처리되므로 한 순회 안에서는 타이머 쪽이 앞선다.', false),
(9440, 3474, '소켓 종료 핸들러는 같은 순회에서 setImmediate로 예약한 콜백보다 뒤에 실행된다.', '참인 진술이다. 루프는 check(5번)를 지난 뒤 close callbacks(6번)에 닿으므로 종료 핸들러가 나중에 실행된다.', false),
(9441, 3474, '한 페이즈의 콜백 하나가 오래 걸리면 뒤 페이즈의 콜백은 물론 다음 순회의 타이머까지 밀린다.', '참인 진술이다. 한 스레드가 페이즈를 순서대로 도는 구조라, 콜백이 루프를 붙잡고 있으면 그 뒤 순서는 모두 그만큼 늦게 실행된다.', false),
(9442, 3474, '파일 읽기 완료 콜백은 같은 순회에서 setImmediate로 예약한 콜백보다 뒤에 실행된다.', '거짓이라 이 선지가 정답이다. I/O 완료 콜백은 4번 poll, setImmediate는 5번 check에서 실행되므로 실제 순서는 반대다.', true),

-- 문제 3475
(9443, 3475, '커널이 비동기 처리를 지원하지 않는 작업이라 워커 스레드가 대신 계산하는데, 기본 워커 수가 4개여서 앞선 넷이 끝나야 나머지가 시작된다.', 'pbkdf2는 커널 비동기 I/O로 넘길 수 없어 워커 스레드 풀에 위임된다. 기본 크기가 4라 다섯째부터는 빈 워커를 기다리고, 그래서 완료 시각이 0.5초 단위 계단을 이룬다.', true),
(9444, 3475, 'JavaScript 실행 스레드가 하나뿐이라 여섯 번의 계산이 메인 스레드에서 하나씩 차례로 처리된다.', '메인 스레드가 직렬로 계산했다면 완료 시각이 0.5초 간격으로 여섯 계단이 나와야 한다. 앞선 넷이 거의 동시에 끝난 것은 계산이 메인 스레드 밖에서 병렬로 돌았다는 증거다.', false),
(9445, 3475, 'poll 페이즈가 한 순회에 처리할 수 있는 콜백 수가 시스템 한도인 4개로 묶여 있어 나머지가 다음 순회로 밀린다.', 'poll의 한도는 이미 끝난 작업의 콜백을 몇 개 실행할지에 대한 것이라, 계산 시작 자체를 미루지 않는다. 콜백 실행만 밀렸다면 지연은 밀리초 수준이지 0.5초씩 늘지 않는다.', false),
(9446, 3475, '해시 계산이 커널의 epoll로 감시되는 비동기 I/O인데, 한 번에 감시할 수 있는 이벤트 수가 4개로 제한돼 있다.', 'epoll은 소켓처럼 파일 디스크립터가 있는 대상을 감시하는 장치이고 감시 개수도 4개로 묶여 있지 않다. 암호 연산은 디스크립터가 없는 CPU 작업이라 감시 대상이 아니다.', false),

-- 문제 3476
(9447, 3476, '요청마다 별도의 처리 스레드가 배정되므로 열 개의 응답이 모두 300ms 안팎에 함께 도착한다.', '요청당 스레드를 띄우는 서버 모델을 Node.js에 갖다 붙인 오개념. JavaScript 실행 스레드는 하나뿐이라 핸들러 열 개가 동시에 돌 수 없다.', false),
(9448, 3476, '워커 스레드 4개가 읽기를 나눠 맡아 열 개의 요청이 네 개씩 묶여 완료된다.', '스레드 풀로 넘어가는 것은 fs의 비동기 API다. readFileSync는 워커에 위임하지 않고 메인 스레드가 직접 읽으므로 네 개씩 묶여 끝나는 현상이 나타나지 않는다.', false),
(9449, 3476, '마지막 요청은 앞선 아홉 번의 읽기가 모두 끝난 뒤에야 처리돼 응답이 3초 가까이 늦어진다.', 'readFileSync는 읽기가 끝날 때까지 이벤트 루프를 붙잡아 다른 콜백을 한 개도 실행하지 못하게 한다. 핸들러 열 개가 300ms씩 줄을 서므로 마지막 응답은 약 3초 뒤가 된다.', true),
(9450, 3476, '읽기 완료 콜백이 poll 페이즈 큐에 쌓여 timers 페이즈의 콜백보다 먼저 처리된다.', '동기 호출에 콜백·페이즈 개념을 잘못 갖다 붙인 오답. readFileSync는 콜백을 등록하지 않고 읽은 값을 그 자리에서 반환하므로 poll 큐에 쌓일 것이 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1114, 3477, 'poll,poll 페이즈,폴,폴 페이즈,poll phase', 'poll은 I/O 완료 콜백을 실행하고, 큐가 비면 예약된 setImmediate가 없는 한 가장 가까운 타이머 만료 시각까지 블로킹 대기하는 페이즈다. 유휴 상태에서 CPU를 거의 쓰지 않는 것도, 소켓 데이터 도착과 타이머 만료 양쪽에서 깨어나는 것도 이 대기 규칙에서 나온다. setImmediate만 실행하는 check, 만료된 타이머만 실행하는 timers와 구분한다.'),
       (1115, 3478, 'libuv,리브유브,libuv 라이브러리', '운영체제마다 다른 비동기 I/O 장치(리눅스 epoll, macOS kqueue, 윈도우 IOCP)를 한 인터페이스로 감싸고, 커널이 비동기로 처리하지 못하는 작업을 위해 워커 스레드 풀(기본 4개)을 함께 운영하는 C 라이브러리가 libuv다. V8은 JavaScript를 컴파일·실행하고 콜 스택·힙·GC를 맡을 뿐 이벤트 루프를 돌리지 않는다는 점에서 구분된다.');

-- =====================================================
-- Lesson 707: 타이머 지연과 DNS 스레드 풀 경합
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4421, 707, '아래 코드를 실행했을 때 B 줄에 찍히는 경과 시간에 가장 가까운 값은?', '```javascript
const start = Date.now();

setTimeout(() => {
  console.log(`A: ${Date.now() - start}ms`);
  setTimeout(() => {
    console.log(`B: ${Date.now() - start}ms`);
  }, 100);
}, 100);

// 약 300ms 동안 CPU를 붙잡는 동기 반복문
while (Date.now() - start < 300) {}
```

프로그램에 다른 비동기 작업은 없고, 반복문 외의 코드 실행 시간은 무시한다.', 'OBJECTIVE'),
       (4422, 707, '아래 운영 지표에서 피크 시간대에 템플릿 파일 읽기가 느려진 원인으로 옳은 것은?', 'Node.js 서버(프로세스 1개, 기본 설정)가 요청마다 `http.get`으로 외부 API를 호출하고 `fs.readFile`로 템플릿 파일을 읽는다. 외부 API는 고객사마다 호스트명이 달라, 호출할 때마다 호스트명을 IP 주소로 바꾸는 조회가 새로 일어난다. 서버의 CPU 코어는 8개다.

| 지표 | 평시 | 피크 |
| --- | --- | --- |
| 외부 API 호출 수 | 초당 5회 | 초당 600회 |
| 템플릿 파일 읽기 평균 시간 | 2ms | 900ms |
| 이벤트 루프 지연 p99 (예약한 타이머가 늦게 실행된 정도) | 3ms | 4ms |
| CPU 사용률 | 5% | 18% |', 'OBJECTIVE'),
       (4423, 707, '아래 서버의 I/O 처리 방식에 대한 설명으로 옳은 것은?', '이 서버는 요청이 들어올 때마다 새 스레드를 하나 만들어 맡긴다. 스레드는 DB에 쿼리를 보낸 뒤 결과가 돌아올 때까지 그 자리에서 멈춰 기다리고, 결과를 받으면 응답을 보낸 뒤 종료된다. DB는 동시에 들어온 쿼리끼리 서로 기다리게 하지 않는다.', 'OBJECTIVE'),
       (4424, 707, '아래 장애에서 다른 요청까지 느려지는 문제를 없애는 조치로 옳은 것은?', '```javascript
app.post(''/import'', express.text({ limit: ''100mb'' }), async (req, res) => {
  const rows = JSON.parse(req.body); // 약 80MB 문자열
  await db.insertMany(rows);
  res.sendStatus(201);
});
```

```
14:02:10  GET  /health  200  3ms
14:02:11  POST /import  수신 (본문 80MB)
14:02:12  GET  /health  200  1,480ms
14:02:12  GET  /health  200  1,215ms
14:02:14  POST /import  201
```

CPU 프로파일을 보니 /import 처리 중 약 1.4초가 `JSON.parse` 한 줄에서 쓰였다. 서버는 기본 설정의 Node.js 프로세스 하나로 실행 중이다.', 'OBJECTIVE'),
       (4425, 707, '아래 실행 결과로 볼 때 ⓐ 자리에 들어갈 Node.js 전역 함수의 이름은?', '```javascript
// main.js
setTimeout(() => console.log(''A''), 0);
ⓐ(() => console.log(''B''));
```

```javascript
// io.js
const fs = require(''node:fs'');

fs.readFile(__filename, () => {
  setTimeout(() => console.log(''A''), 0);
  ⓐ(() => console.log(''B''));
});
```

두 파일을 같은 서버에서 각각 1,000번씩 실행했다.

- main.js: 실행할 때마다 순서가 달라져 A → B와 B → A가 섞여 나왔다.
- io.js: 1,000번 모두 B → A 순서로 찍혔다.

두 파일의 ⓐ는 콜백 하나를 인자로 받는 같은 전역 함수다.', 'SUBJECTIVE'),
       (4426, 707, '아래 두 장애 기록이 공통으로 가리키는 Node.js 런타임 구성 요소의 이름은?', '같은 Node.js 서버에서 서로 다른 날 두 번의 장애가 났다.

```
RangeError: Maximum call stack size exceeded
    at walk (/app/tree.js:12:10)
    at walk (/app/tree.js:14:12)
    at walk (/app/tree.js:14:12)
```

```
<--- Last few GCs --->
[4121:0x5f3a000] 81234 ms: Mark-Compact 4043.1 (4138.5) -> 4040.2 (4139.2) MB
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
```

첫째 장애는 트리를 도는 재귀 함수를 반복문으로 바꾸자 사라졌다. 둘째 장애는 코드를 그대로 두고 node 실행 명령에 `--max-old-space-size=8192` 옵션만 추가하자 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4421
(11963, 4421, '약 200ms', '타이머가 동기 반복문을 끊고 예약한 시각에 정확히 실행된다고 본 오답. JavaScript는 메인 스레드 하나에서 실행되므로 반복문이 끝나 콜 스택이 비기 전에는 어떤 타이머 콜백도 끼어들 수 없다.', false),
(11964, 4421, '약 300ms', 'B의 100ms가 A가 원래 실행됐어야 할 100ms 시점부터 흐른다고 보고, 밀린 두 타이머가 반복문 직후 한꺼번에 실행된다고 본 오답. B의 대기는 A 콜백 안에서 setTimeout을 호출한 약 300ms 시점부터 센다.', false),
(11965, 4421, '약 400ms', '반복문이 300ms 동안 루프를 붙잡아, 이미 만료된 A는 반복문이 끝난 직후 timers 페이즈에서 약 300ms에 실행된다. 지연 값은 최소 대기 시간일 뿐이다. A 안에서 예약한 B는 그 시점부터 100ms 뒤에 만료되므로 약 400ms에 찍힌다.', true),
(11966, 4421, '약 500ms', '타이머 대기 시간이 반복문이 끝난 뒤에야 흐르기 시작한다고 본 오답. A의 100ms는 setTimeout을 호출한 순간부터 흘러 반복문 도중 이미 만료되므로, 루프가 풀리자마자 A가 실행된다.', false),

-- 문제 4422
(11967, 4422, '호스트명 조회가 파일 읽기와 같은 워커 스레드 4개를 나눠 써서, 파일 읽기가 빈 워커를 기다렸다.', 'http.get은 기본으로 dns.lookup을 쓰고, 이는 OS의 getaddrinfo를 libuv 스레드 풀에서 호출한다. fs 작업도 같은 4개 워커를 쓰므로 조회가 몰리면 파일 읽기가 줄을 선다. 루프 지연이 그대로인 것도 대기가 메인 스레드 밖에서 생겼음을 보여 준다.', true),
(11968, 4422, '호스트명 조회 응답을 기다리는 동안 메인 스레드가 멈춰, 이미 끝난 파일 읽기 콜백이 실행되지 못했다.', '네트워크 대기가 메인 스레드를 멈춘다고 본 오답. 메인 스레드가 멈췄다면 이벤트 루프 지연이 수백 ms로 치솟아야 하는데 피크에도 4ms다. 호스트명 조회는 메인 스레드가 아니라 워커 스레드에서 진행된다.', false),
(11969, 4422, '외부 API 소켓의 송수신도 워커 스레드를 하나씩 차지해, 호출이 늘자 파일 읽기에 줄 워커가 모자랐다.', '소켓 I/O도 스레드 풀을 쓴다고 본 오답. TCP 소켓 송수신은 epoll 같은 커널 비동기 API로 감시돼 워커 스레드가 필요 없다. 워커를 차지한 것은 소켓 송수신이 아니라 연결 전에 일어나는 호스트명 조회다.', false),
(11970, 4422, 'poll 페이즈가 소켓 콜백을 모두 비운 뒤에야 파일 읽기 콜백을 실행해, 파일 콜백이 다음 순회로 밀렸다.', 'poll 큐에 I/O 종류별 우선순위가 있다고 본 오답. 콜백 실행 차례가 밀린 것이라면 이벤트 루프 지연도 함께 커져야 하지만 4ms 그대로다. 지연은 콜백 실행 전, 읽기 작업이 워커를 얻지 못한 단계에서 생겼다.', false),

-- 문제 4423
(11971, 4423, '쿼리 하나가 10초 걸리면 그동안 들어온 다른 요청의 응답도 모두 10초 넘게 늦어진다.', '스레드 하나로 모든 콜백을 도는 이벤트 루프가 막힐 때의 증상을 갖다 붙인 오답. 이 서버는 요청마다 스레드가 따로 있어, 한 스레드가 멈춰 있어도 다른 요청은 자기 스레드에서 처리된다.', false),
(11972, 4423, '결과를 기다리며 멈춰 있는 동안에도 그 스레드가 CPU 코어 하나를 계속 점유한다.', '블로킹 대기를 바쁜 대기(busy waiting)로 오해한 오답. I/O를 기다리는 스레드는 운영체제가 대기 상태로 내려 두므로 CPU를 쓰지 않는다. 비용은 CPU가 아니라 스레드마다 잡히는 메모리와 컨텍스트 스위칭에서 생긴다.', false),
(11973, 4423, '쿼리 완료를 알아차리려면 epoll·kqueue 같은 운영체제의 이벤트 감시 기능이 반드시 필요하다.', '완료 통지를 이벤트로 받는 논블로킹 방식의 특징을 갖다 붙인 오답. 이 서버의 스레드는 읽기 호출 안에서 결과가 올 때까지 멈춰 있다가 그대로 값을 받으므로, 여러 소켓을 감시하는 장치가 없어도 된다.', false),
(11974, 4423, '동시 접속이 수만 개로 늘면 스레드 생성·컨텍스트 스위칭 비용과 스레드마다 잡히는 스택 메모리가 함께 커진다.', '대기 중에도 스레드는 사라지지 않으므로 동시 요청 수가 곧 살아 있는 스레드 수다. 스레드마다 스택 메모리가 잡히고 운영체제가 전환할 대상도 늘어난다. 적은 스레드로 많은 연결을 처리하려고 논블로킹 I/O와 이벤트 루프를 쓰는 이유다.', true),

-- 문제 4424
(11975, 4424, 'JSON.parse 호출을 setImmediate 콜백 안으로 옮겨 check 페이즈에서 실행되게 한다.', '실행 시점을 뒤로 미루면 루프가 풀린다고 본 오답. 파싱은 여전히 메인 스레드의 콜백 하나 안에서 1.4초 동안 돌기 때문에, 그 콜백이 끝날 때까지 /health 요청은 똑같이 기다린다.', false),
(11976, 4424, '요청 본문을 스트림 파서로 청크마다 나눠 파싱해, 콜백 하나가 루프를 붙잡는 시간을 줄인다.', 'JSON.parse는 80MB 문자열 전체를 한 번에 처리하는 동기 CPU 작업이라 끝날 때까지 루프가 멈춘다. 스트림 파서는 도착한 청크마다 조금씩 처리하므로, 청크 사이사이 /health 같은 다른 요청의 콜백이 실행될 틈이 생긴다.', true),
(11977, 4424, 'UV_THREADPOOL_SIZE를 8로 늘려 파싱을 나눠 맡을 워커 스레드를 늘린다.', 'JSON.parse가 스레드 풀로 넘어간다고 본 오답. 스레드 풀이 맡는 것은 fs·dns.lookup·crypto·zlib 같은 작업이고, JSON.parse는 JavaScript 코드와 같은 메인 스레드에서 실행되므로 워커 수와 무관하다.', false),
(11978, 4424, 'JSON.parse 앞에 await를 붙여 파싱이 끝나기를 기다리는 동안 다른 요청을 처리하게 한다.', 'await가 동기 함수를 비동기로 바꿔 준다고 본 오답. JSON.parse는 Promise를 반환하지 않으므로 파싱이 그 자리에서 끝까지 실행되고, await는 이미 계산된 결과를 받아 넘길 뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1430, 4425, 'setImmediate,setImmediate(),set immediate,셋이미디엇', 'setImmediate 콜백은 poll 바로 다음인 check 페이즈에서, setTimeout(fn, 0) 콜백은 timers 페이즈에서 실행된다. 메인 모듈에서 호출하면 루프에 처음 들어갈 때 1ms로 보정된 타이머가 이미 만료됐는지가 그때그때의 프로세스 성능에 따라 달라 순서가 섞인다. 반면 I/O 콜백은 poll 페이즈에서 실행되므로, 그 안에서 예약한 setImmediate는 곧바로 이어지는 check에서 다음 순회의 timers보다 항상 먼저 실행된다. process.nextTick이나 queueMicrotask 같은 마이크로태스크였다면 두 파일 모두 B가 항상 먼저 찍혀 main.js에서 순서가 섞이지 않았을 것이라는 점에서 구분된다.'),
       (1431, 4426, 'V8,V8 엔진,V8 engine,브이8,브이에이트,JavaScript 엔진,자바스크립트 엔진,JS 엔진', 'V8은 Node.js 안에서 JavaScript를 컴파일·실행하는 엔진으로, 콜 스택과 힙, 가비지 컬렉션(GC)을 직접 관리한다. 콜 스택은 하나뿐이고 크기 한도가 있어 너무 깊은 재귀는 Maximum call stack size exceeded로 멈추고, 힙이 한도에 닿으면 Mark-Compact GC를 되풀이하다 heap out of memory로 프로세스가 종료된다. --max-old-space-size 역시 V8의 힙 한도를 바꾸는 옵션이다. 이벤트 루프와 비동기 I/O, 스레드 풀을 맡는 libuv는 두 한도와 관계가 없다는 점에서 구분된다.');

-- =====================================================
-- Lesson 865: poll 대기와 ReDoS·스레드 풀 크기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5369, 865, '아래 상황에서 poll 페이즈의 동작으로 옳은 것은?', '```javascript
const http = require(''node:http'');

http.createServer((req, res) => res.end(''ok'')).listen(3000);

setTimeout(() => console.log(''A''), 5000);
setTimeout(() => console.log(''B''), 2000);
```

프로그램을 시작한 뒤 요청은 한 건도 들어오지 않았다. 시작 2초 뒤 B가 찍혔고, 이벤트 루프는 이어서 같은 순회의 poll 페이즈에 들어갔다. 코드에 적힌 것 외에 예약된 작업은 없다.', 'OBJECTIVE'),
       (5370, 865, '아래 서버 코드에 대한 설명으로 옳은 것은?', '```javascript
const fs = require(''node:fs'');
const express = require(''express'');

// ㉠
const config = JSON.parse(fs.readFileSync(''config.json'', ''utf8''));

const app = express();

// ㉡
app.get(''/page'', async (req, res) => {
  const html = await fs.promises.readFile(''page.html'', ''utf8'');
  res.send(html.replace(''{{title}}'', config.title));
});

app.listen(3000);
```

서버는 기본 설정의 Node.js 프로세스 하나로 실행하며, 두 파일은 각각 읽는 데 약 50ms가 걸린다.', 'OBJECTIVE'),
       (5371, 865, '아래 서버에 클라이언트 하나가 접속했을 때 콘솔에 찍히는 순서로 옳은 것은?', '```javascript
const net = require(''node:net'');

const server = net.createServer((socket) => {
  socket.on(''close'', () => console.log(''C''));
  setImmediate(() => console.log(''B''));
  socket.destroy();
  console.log(''A'');
});

server.listen(4000);
```

접속한 클라이언트는 이 하나뿐이고, 코드에 적힌 것 외에 예약된 작업은 없다.', 'OBJECTIVE'),
       (5372, 865, '아래 Node.js 런타임 구성 요소에 대한 설명으로 옳은 것은?', 'libuv는 C로 작성된 크로스 플랫폼 비동기 I/O 라이브러리로, Node.js 런타임 안에서 JavaScript 엔진인 V8과 나란히 놓인 구성 요소다.', 'OBJECTIVE'),
       (5373, 865, '아래 장애를 일으킨 공격 유형을 가리키는 용어는?', '```javascript
// 아이디 형식 검사: 영문 소문자·숫자 덩어리를 점(.)으로 이어 붙인 형태
const ID_RULE = /^([a-z0-9]+\.?)+$/;

app.post(''/signup'', (req, res) => {
  if (!ID_RULE.test(req.body.id)) return res.sendStatus(400);
  // ... 가입 처리
});
```

```
10:02:11  POST /signup  201  5ms
10:02:14  POST /signup  수신 (id: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!", 33자)
10:02:15  GET  /health  응답 대기
10:03:02  POST /signup  400  48,210ms
10:03:02  GET  /health  200  47,030ms
```

같은 모양의 id에서 a를 한 글자 늘릴 때마다 처리 시간이 약 두 배로 늘었고, 그동안 CPU 코어 하나가 100%에 머물렀다. 이런 요청은 1분에 한 건씩만 들어왔지만 서버는 거의 내내 응답하지 못했다.', 'SUBJECTIVE'),
       (5374, 865, '아래 명령으로 프로그램을 실행했을 때 마지막으로 찍히는 경과 시간은 약 몇 ms인가?', '```
$ UV_THREADPOOL_SIZE=3 node job.js
```

```javascript
// job.js
const crypto = require(''node:crypto'');
const http = require(''node:http'');

const start = Date.now();
const done = () => console.log(`${Date.now() - start}ms`);

// 해시 계산 7건: 1건당 약 200ms 동안 CPU를 쓴다
for (let i = 0; i < 7; i++) {
  crypto.pbkdf2(''pw'', ''salt'', 100_000, 64, ''sha512'', done);
}

// API 호출 5건: IP 주소로 바로 접속하며, 서버는 요청마다 약 200ms 뒤 응답한다
for (let i = 0; i < 5; i++) {
  http.get(''http://10.0.0.5/api'', (res) => {
    res.resume();
    res.on(''end'', done);
  });
}
```

실행 장비의 CPU 코어는 8개이며, 네트워크 전송 시간과 콜백 실행 시간은 무시한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5369
(14491, 5369, '기다리지 않고 곧바로 check 페이즈로 넘어가, 루프를 계속 돈다.', '할 일이 없으면 poll을 그냥 지나친다고 본 오답. 대기 없이 check로 넘어가는 것은 setImmediate가 예약돼 있을 때뿐이다. 이 코드에는 없으므로 poll은 멈춰 기다리고, 덕분에 유휴 상태에서 CPU를 낭비하지 않는다.', false),
(14492, 5369, '최대 약 3초 동안, A가 만료되는 시각까지 기다린다.', 'poll 큐가 비어 있고 setImmediate도 없으면, 가장 가까운 타이머의 만료 시각까지 블로킹 대기한다. A는 시작 후 5초에 만료되므로 2초 시점에서 남은 시간은 약 3초다. 그사이 요청이 오면 곧바로 깨어나 처리한다.', true),
(14493, 5369, '최대 약 5초 동안, A의 지연 값만큼 다시 기다린다.', '타이머 지연을 지금부터 새로 센다고 본 오답. setTimeout의 5,000ms는 호출한 순간(프로그램 시작)부터 흐르므로 A의 만료 시각은 시작 후 5초로 고정돼 있다. 2초 시점에서 남은 대기는 약 3초다.', false),
(14494, 5369, '요청이 들어올 때까지 시간 제한 없이 기다린다.', 'poll이 I/O 이벤트만 기다린다고 본 오답. 대기 시간은 가장 가까운 타이머의 만료 시각으로 제한된다. 요청이 끝내 오지 않아도 5초 시점에 깨어나 다음 순회의 timers 페이즈에서 A를 실행한다.', false),

-- 문제 5370
(14495, 5370, '㉡의 await는 파일을 다 읽을 때까지 메인 스레드를 멈춰 세워, 다른 요청의 핸들러가 실행되지 못한다.', 'await를 동기 대기로 오해한 오답. await는 async 함수의 남은 부분만 읽기 완료 뒤로 미루고 메인 스레드는 이벤트 루프로 돌려준다. 그래서 읽기가 진행되는 동안에도 다른 요청의 핸들러가 실행된다.', false),
(14496, 5370, '㉡의 파일 읽기는 소켓처럼 epoll 같은 커널 비동기 API로 감시돼, 스레드 풀의 워커를 쓰지 않는다.', '파일 I/O를 소켓 I/O와 같은 경로로 본 오답. 커널 비동기 API로 감시되는 것은 소켓·파이프 같은 대상이고, fs 작업은 libuv 스레드 풀의 워커가 대신 실행한 뒤 완료 결과를 poll 큐로 넘긴다.', false),
(14497, 5370, '㉡의 파일 읽기는 동시에 들어온 요청 수만큼 워커가 새로 만들어져, 모두 한꺼번에 처리된다.', '요청마다 스레드를 띄우는 서버 모델을 스레드 풀에 갖다 붙인 오답. 스레드 풀의 크기는 프로세스 시작 시 정해지고 기본 4개라, 읽기가 한꺼번에 몰리면 워커 4개를 나눠 쓰며 차례를 기다린다.', false),
(14498, 5370, '㉠의 동기 읽기는 첫 요청을 받기 전에 한 번 끝나므로, 이후 요청의 응답 시간을 늦추지 않는다.', '㉠은 모듈이 로드될 때 listen보다 먼저 딱 한 번 실행된다. 이때는 처리 중인 요청이 없어 루프가 잠시 막혀도 기다리는 클라이언트가 없다. 동기 API를 서버 기동 시 설정 로딩에만 쓰고 요청 처리 경로에서 피하는 이유다.', true),

-- 문제 5371
(14499, 5371, 'C → A → B', 'destroy()를 부르는 순간 ''close'' 이벤트가 그 자리에서 발생한다고 본 오답. destroy()는 소켓 핸들을 닫도록 예약할 뿐이고, ''close'' 핸들러는 한 순회의 마지막인 close callbacks 페이즈에서 실행된다.', false),
(14500, 5371, 'B → A → C', 'setImmediate를 이름 그대로 ''지금 즉시''로 읽은 오답. 예약한 콜백은 실행 중인 연결 콜백이 끝나고 루프가 check 페이즈에 닿아야 실행되므로, 같은 콜백의 동기 코드 A보다 앞설 수 없다.', false),
(14501, 5371, 'A → B → C', '연결 콜백은 poll 페이즈에서 실행되므로 동기 코드 A가 먼저 찍힌다. 루프는 poll 다음 check 페이즈에서 setImmediate의 B를, 이어서 close callbacks 페이즈에서 소켓 ''close'' 핸들러의 C를 실행한다.', true),
(14502, 5371, 'A → C → B', '''close'' 핸들러가 check보다 먼저 처리된다고 본 오답. 페이즈 순서는 poll → check → close callbacks라, 같은 순회에서 소켓 종료 핸들러는 setImmediate 콜백보다 뒤에 실행된다.', false),

-- 문제 5372
(14503, 5372, '이벤트 루프 자체를 제공해, timers부터 close callbacks까지 페이즈를 차례로 순회한다.', 'libuv는 이벤트 루프와 스레드 풀을 함께 제공한다. 루프가 페이즈를 순서대로 돌며 완료된 I/O·타이머의 콜백을 꺼내면, 그 콜백의 JavaScript 코드는 V8이 실행한다. 루프를 돌리는 쪽과 코드를 실행하는 쪽이 이렇게 나뉜다.', true),
(14504, 5372, 'JavaScript 코드를 기계어로 컴파일하고, 하나뿐인 콜 스택으로 함수 호출을 관리한다.', 'V8의 역할을 libuv에 갖다 붙인 오답. JavaScript의 컴파일·실행과 콜 스택·힙·GC 관리는 JavaScript 엔진인 V8이 맡고, libuv는 JavaScript 코드를 해석하거나 실행하지 않는다.', false),
(14505, 5372, 'fs·http 같은 모듈의 JavaScript API를 정의해, 개발자가 require로 불러 쓰게 한다.', 'Node.js 바인딩 계층의 역할을 갖다 붙인 오답. fs·http 같은 모듈은 Node.js가 JavaScript API로 노출하는 것이고, libuv는 그 아래에서 실제 비동기 작업을 수행하는 C 라이브러리라 JavaScript API가 없다.', false),
(14506, 5372, '소켓 감시를 자체 방식으로 구현해, 운영체제의 epoll·kqueue 같은 기능은 쓰지 않는다.', 'libuv가 운영체제 기능을 대신한다고 본 오답. libuv는 리눅스 epoll, macOS kqueue, 윈도우 IOCP를 그대로 쓰면서 그 차이를 한 인터페이스로 감싸, 애플리케이션 코드를 운영체제마다 고치지 않아도 되게 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1746, 5373, 'ReDoS,ReDoS 공격,레독스,리도스,정규식 DoS,정규 표현식 DoS,정규식 서비스 거부,정규식 서비스 거부 공격,정규 표현식 서비스 거부,정규 표현식 서비스 거부 공격,Regex DoS,Regular expression DoS,Regular expression Denial of Service', 'ReDoS(Regular expression Denial of Service)는 백트래킹이 폭발하는 정규식에 일부러 끝에서 어긋나는 입력을 보내 매칭 시간을 늘리는 공격이다. ([a-z0-9]+\.?)+처럼 반복 안에 반복이 겹쳐 있으면, 마지막 !에서 매칭이 실패할 때 엔진이 a 덩어리를 나누는 모든 경우를 되짚어 보느라 시도 횟수가 글자 수에 따라 지수적으로 늘어난다. Node.js에서 정규식 매칭은 메인 스레드에서 동기로 실행되므로, 요청 한 건이 이벤트 루프를 수십 초 붙잡아 /health 같은 다른 요청까지 함께 멈춘다. 요청을 대량으로 쏟아부어 자원을 고갈시키는 일반적인 DoS·DDoS와 달리 요청 한 건으로 서비스를 멈춘다는 점에서 구분되며, 정규식 단순화와 입력 길이 제한으로 막는다.'),
       (1747, 5374, '600,600ms,600 ms,약 600,약 600ms,약 600 ms,0.6초,약 0.6초,0.6s,600밀리초', 'UV_THREADPOOL_SIZE=3이라 libuv 스레드 풀의 워커는 3개다. crypto.pbkdf2는 커널이 비동기로 처리할 수 없는 CPU 작업이라 워커에 위임되므로, 7건이 3건·3건·1건씩 나뉘어 약 200ms·400ms·600ms에 끝난다. 반면 HTTP 요청은 IP 주소로 바로 접속해 호스트명 조회(dns.lookup)가 없고, 소켓 송수신은 epoll 같은 커널 비동기 API가 감시하므로 워커를 쓰지 않고 5건 모두 약 200ms에 끝난다. 따라서 마지막 로그는 약 600ms다. 워커 수를 기본값 4개로 착각하면 400ms, 소켓 요청도 워커를 쓴다고 보면 12건을 3개씩 처리해 800ms가 나온다.');
