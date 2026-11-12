-- Unit: 마이크로태스크와 매크로태스크 (Unit ID: 124)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (550, 124, '실행 순서와 nextTick 기아 현상'),
       (708, 124, '중첩 예약과 동기 콜백 함정'),
       (866, 124, '큐 비우기 규칙과 이벤트 루프 양보');

-- =====================================================
-- Lesson 550: 실행 순서와 nextTick 기아 현상
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3479, 550, '아래 코드를 Node.js 18에서 실행했을 때 출력 순서로 옳은 것은?', '```javascript
console.log(''A'');

setTimeout(() => console.log(''B''), 0);

Promise.resolve().then(() => {
  console.log(''C'');
  process.nextTick(() => console.log(''D''));
});

process.nextTick(() => console.log(''E''));

console.log(''F'');
```', 'OBJECTIVE'),
       (3480, 550, '아래 코드를 두 버전에서 실행한 결과에 대한 설명으로 옳지 않은 것은?', '```javascript
setTimeout(() => {
  console.log(''t1'');
  Promise.resolve().then(() => console.log(''p1''));
}, 0);

setTimeout(() => {
  console.log(''t2'');
  Promise.resolve().then(() => console.log(''p2''));
}, 0);
```

| 실행 환경 | 출력 순서 |
|---|---|
| Node.js 10 | t1 → t2 → p1 → p2 |
| Node.js 18 | t1 → p1 → t2 → p2 |', 'OBJECTIVE'),
       (3481, 550, '아래 설명에 해당하는 Node.js 콜백 예약 API에 대한 설명으로 옳은 것은?', '이 API로 등록한 콜백은 이벤트 루프가 poll 페이즈를 지난 뒤 도달하는 check 페이즈에서 실행된다. 이름은 ''즉시''를 뜻하지만, 현재 실행 중인 작업이 끝나자마자 실행되지는 않는다.', 'OBJECTIVE'),
       (3482, 550, '아래 코드를 Node.js 18에서 실행했을 때 세 번째로 출력되는 값은?', '```javascript
async function run() {
  console.log(''A'');
  await null;
  console.log(''B'');
}

setTimeout(() => console.log(''C''), 0);
run();
process.nextTick(() => console.log(''D''));
console.log(''E'');
```', 'OBJECTIVE'),
       (3483, 550, '아래 코드에서 ???로 가린 Node.js API 이름은?', '```javascript
setTimeout(() => console.log(''timeout''), 0);
Promise.resolve().then(() => console.log(''promise''));
???(() => console.log(''X''));
```

실행하면 아래 순서로 출력된다.

```
X
promise
timeout
```

Promise 콜백이 먼저 예약됐는데도 X가 앞서 출력된다.', 'SUBJECTIVE'),
       (3484, 550, '아래 상황에서 발생한 문제를 가리키는 용어는?', '```javascript
// rows: 조회된 120,000행
function drain() {
  handle(rows.splice(0, 500));      // 한 번에 500행, 호출마다 2ms 남짓
  if (rows.length) process.nextTick(drain);
}
drain();
```

배치가 도는 9초 동안 서버의 HTTP 요청 로그가 한 줄도 남지 않았다. CPU 사용률은 35%에 머물렀고 배치 자체는 500행씩 끝까지 잘 진행됐는데, 그사이 도착한 요청 412건은 배치가 끝난 뒤에야 한꺼번에 처리됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3479
(9451, 3479, 'A → F → C → E → D → B', '콜 스택이 비면 nextTick 큐를 먼저 완전히 비운 뒤 Promise 큐로 넘어간다. Promise 큐가 먼저라고 본 오해이며, 이 코드에서는 E가 C보다 앞선다.', false),
(9452, 3479, 'A → F → E → C → B → D', '마이크로태스크를 비우는 도중 새로 쌓인 nextTick도 두 큐가 모두 빈 뒤에야 매크로태스크로 넘어가므로 D가 타이머 콜백 B보다 앞선다. 새 마이크로태스크가 다음 순회로 밀린다고 본 오해다.', false),
(9453, 3479, 'A → F → E → C → D → B', '동기 코드 A·F가 먼저 출력되고, 스택이 비면 nextTick 큐(E) → Promise 큐(C) 순으로 처리된다. C가 예약한 D까지 마이크로태스크를 모두 비운 뒤에야 타이머 콜백 B가 실행된다.', true),
(9454, 3479, 'A → B → F → E → C → D', '지연 0ms는 ''지금 당장''이 아니라 ''최소 0ms 뒤''라는 뜻이다. 타이머 콜백은 콜 스택이 빈 다음 타이머 페이즈에서 실행되므로 동기 코드 F보다 뒤로 밀린다.', false),

-- 문제 3480
(9455, 3480, 'Node.js 10에서 p1이 t2보다 늦게 나온 것은 타이머 콜백을 연달아 처리한 뒤에야 마이크로태스크 큐를 비웠기 때문이다.', 'Node.js 10까지는 마이크로태스크를 페이즈가 끝날 때 한 번만 처리했다. t1이 예약한 p1이 t2 뒤로 밀린 출력이 그 근거이므로 옳은 진술이다.', false),
(9456, 3480, '두 버전의 출력이 갈린 것은 nextTick 큐와 Promise 큐의 우선순위가 서로 뒤바뀌었기 때문이다.', '두 마이크로태스크 큐의 우선순위(nextTick 먼저)는 버전과 무관하게 그대로다. 달라진 것은 마이크로태스크를 비우는 시점이며, 이 코드에는 nextTick이 아예 없어 우선순위와 상관이 없다.', true),
(9457, 3480, 'Node.js 18에서 t1 바로 뒤에 p1이 나온 것은 타이머 콜백 하나가 끝날 때마다 마이크로태스크 큐를 비우기 때문이다.', 'Node.js 11부터 타이머·setImmediate 콜백 하나하나 사이에 마이크로태스크를 처리하도록 바뀌었다. t1 → p1 → t2 → p2 출력이 그 근거이므로 옳은 진술이다.', false),
(9458, 3480, 'Node.js 18의 출력 순서는 같은 코드를 브라우저에서 실행했을 때와 일치한다.', '브라우저는 태스크 하나를 실행할 때마다 마이크로태스크 큐를 비운다. Node.js 11부터 같은 방식을 따르므로 t1 → p1 → t2 → p2로 순서가 같아진다.', false),

-- 문제 3481
(9459, 3481, '인자로 받은 밀리초가 지나야 콜백이 실행되므로 지연 시간을 조절할 수 있다.', '지연 시간을 인자로 받는 것은 setTimeout이고, 그마저도 ''최소'' 지연이라 정확한 시각을 보장하지 않는다. 이 API는 지연 인자 없이 다음 순회의 check 페이즈에 콜백을 걸어 둔다.', false),
(9460, 3481, '브라우저에도 같은 이름으로 표준화되어 있어 클라이언트 코드에 그대로 옮길 수 있다.', 'Node.js 고유 API라 브라우저에는 없다. 두 환경에서 함께 쓰려면 표준인 queueMicrotask나 Promise를 써야 한다. 이름이 익숙해 표준으로 착각하기 쉽다.', false),
(9461, 3481, '예약한 콜백은 같은 순회에서 만료된 0ms 타이머 콜백보다 항상 먼저 실행된다.', '타이머 페이즈가 check 페이즈보다 앞이라 ''항상''은 성립하지 않는다. 순서가 보장되는 것은 I/O 콜백 안에서 둘을 함께 예약했을 때뿐이다.', false),
(9462, 3481, '긴 반복 작업을 잘게 나눠 매 반복을 이 API로 예약하면 반복 사이에 대기 중인 소켓 읽기 콜백이 처리된다.', 'check 페이즈에 닿으려면 poll 페이즈를 지나야 하므로 반복마다 I/O에 차례를 넘겨준다. 같은 반복을 마이크로태스크로 재귀 예약하면 poll에 도달하지 못해 결과가 갈린다.', true),

-- 문제 3482
(9463, 3482, 'D', '동기 구간에서 A·E가 출력되고, 스택이 비면 nextTick 큐가 Promise 큐보다 먼저 처리되어 D가 세 번째다. await 뒤의 B는 Promise 마이크로태스크라 D 다음이다.', true),
(9464, 3482, 'B', 'Promise 큐를 nextTick 큐보다 먼저 비운다고 본 오해다. 콜 스택이 빌 때마다 nextTick 큐를 먼저 완전히 비우므로 B는 D 뒤인 네 번째다.', false),
(9465, 3482, 'E', 'await null은 Promise가 아니니 대기 없이 이어진다고 본 오해다. await는 값이 Promise가 아니어도 반드시 한 번 마이크로태스크 큐를 거치므로 B가 E보다 앞설 수 없다.', false),
(9466, 3482, 'C', '지연 0ms 타이머가 마이크로태스크보다 먼저 처리된다고 본 오해다. 타이머 콜백은 nextTick 큐와 Promise 큐를 모두 비운 뒤 타이머 페이즈에서 실행되므로 이 코드에서는 가장 마지막이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1116, 3483, 'process.nextTick,nextTick,process.nextTick(),넥스트틱', '예약 순서가 뒤인데도 Promise 콜백을 앞지르려면 Promise 마이크로태스크 큐가 아닌 별도의 큐에 들어가야 한다. Node.js는 콜 스택이 빌 때마다 nextTick 큐를 먼저 완전히 비운 뒤 Promise 큐로 넘어가므로 X가 promise보다 앞선다. queueMicrotask나 Promise.resolve().then으로 예약했다면 같은 마이크로태스크 큐 뒤에 붙어 promise 다음에 출력되고, setImmediate는 check 페이즈에서 실행되는 매크로태스크라 두 마이크로태스크 큐가 모두 빈 뒤로 밀린다.'),
       (1117, 3484, '기아,기아 상태,기아 현상,starvation,스타베이션,I/O 기아,이벤트 루프 기아', 'nextTick 큐는 완전히 빌 때까지 실행되므로, 콜백이 자기 자신을 다시 예약하면 큐가 영영 비지 않아 이벤트 루프가 poll 페이즈로 넘어가지 못한다. 그래서 배치는 계속 진행되는데 대기 중인 I/O 콜백만 차례를 얻지 못한다. CPU가 남아도는데도 특정 작업만 무기한 밀리는 이 상태가 기아다. 서로 자원을 기다려 아무도 진행하지 못하는 교착 상태(deadlock)와 다르고, 동기 코드가 콜 스택을 오래 붙잡는 이벤트 루프 블로킹과도 구분된다. 반복 양보가 필요하면 setImmediate로 예약해 매 순회 poll 페이즈를 거치게 한다.');

-- =====================================================
-- Lesson 708: 중첩 예약과 동기 콜백 함정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4427, 708, '아래 코드의 실행 결과에 대한 설명으로 옳은 것은?', '```javascript
// app.js (CommonJS) — Node.js 20에서 실행
setTimeout(() => console.log(''t''), 0);

Promise.resolve().then(() => {
  console.log(''p1'');
  process.nextTick(() => console.log(''n2''));
});
Promise.resolve().then(() => console.log(''p2''));

process.nextTick(() => console.log(''n1''));
```', 'OBJECTIVE'),
       (4428, 708, '아래 코드에서 두 번째 show(1)도 ''완료''를 출력하도록 ★ 줄을 바꾼 것으로 옳은 것은?', '```javascript
// Node.js 20
const cache = new Map();

function getUser(id, cb) {
  if (cache.has(id)) {
    return cb(cache.get(id)); // ★ 캐시 히트
  }
  setTimeout(() => { // DB 조회를 흉내 냄
    cache.set(id, { id });
    cb(cache.get(id));
  }, 10);
}

function show(id) {
  let label = ''로딩 중'';
  getUser(id, () => console.log(label));
  label = ''완료'';
}

show(1);                       // 출력: 완료
setTimeout(() => show(1), 50); // 출력: 로딩 중
```', 'OBJECTIVE'),
       (4429, 708, '아래 코드를 실행했을 때의 출력과 그 이유로 옳은 것은?', '```javascript
// app.js (CommonJS) — Node.js 20에서 실행
const EventEmitter = require(''events'');

class Conn extends EventEmitter {
  constructor() {
    super();
    process.nextTick(() => this.emit(''ready''));
  }
}

async function main() {
  const conn = new Conn();
  await null; // 설정을 불러오는 대기를 흉내 냄
  conn.on(''ready'', () => console.log(''ready''));
}

main();
```', 'OBJECTIVE'),
       (4430, 708, '아래 측정 결과에 대한 해석으로 옳은 것은?', '원소 20만 개짜리 배열을 1,000개씩 처리하는 함수 `step`이 끝날 때마다 다음 `step`을 예약하는 코드를 네 가지로 바꿔 Node.js 20에서 측정했다. 처리를 시작하기 직전에 `setTimeout(tick, 100)`을 걸어 두고, `tick`이 실제로 실행된 시각(시작 기준)을 기록했다. 네 방식 모두 배열을 다 처리하는 데 약 2초가 걸렸다.

| 방식 | 다음 step 예약 코드 | tick 실행 시각 |
|---|---|---|
| A | `process.nextTick(step)` | 약 2,000ms |
| B | `Promise.resolve().then(step)` | 약 2,000ms |
| C | `queueMicrotask(step)` | 약 2,000ms |
| D | `setImmediate(step)` | 약 100ms |', 'OBJECTIVE'),
       (4431, 708, '아래 상황에서 ???에 들어갈 전역 함수 이름은?', 'Node.js용으로 만든 로그 버퍼 라이브러리를 브라우저 번들에 넣자 아래 오류가 났다.

```
ReferenceError: process is not defined
    at schedule (buffer.js:12:3)
```

12번째 줄 `process.nextTick(flush)`를 전역 함수 호출 `???(flush)`로 바꾸자 오류가 사라졌다. 바꾼 뒤 아래 코드를 브라우저와 Node.js 20에서 각각 실행한 결과는 같았다.

```javascript
setTimeout(() => console.log(''timeout''), 0);
Promise.resolve().then(() => console.log(''promise''));
???(() => console.log(''flush''));
```

```
promise
flush
timeout
```', 'SUBJECTIVE'),
       (4432, 708, '아래 실험 결과로 볼 때, defer로 예약한 콜백이 속하는 작업 분류의 이름은?', '사내 유틸 함수 `defer(fn)`이 내부에서 어떤 API를 쓰는지 문서에 없어 Node.js 20에서 실험했다.

```javascript
defer(() => {
  console.log(''d1'');
  Promise.resolve().then(() => console.log(''p1''));
});
defer(() => console.log(''d2''));
Promise.resolve().then(() => console.log(''p0''));
```

```
p0
d1
p1
d2
```

또 `defer`로 자기 자신을 끝없이 다시 예약하는 함수를 돌려 둔 동안에도, 서버에 들어온 HTTP 요청은 평소처럼 바로 응답됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4427
(11979, 4427, 'p1이 예약한 n2는 nextTick 큐가 Promise 큐보다 우선이므로 p2보다 먼저 출력된다.', 'nextTick 큐가 먼저라는 것은 두 큐를 확인하는 순서일 뿐, Promise 콜백 사이사이에 끼어든다는 뜻이 아니다. Promise 큐는 일단 비우기 시작하면 빌 때까지 이어서 실행하므로 n2는 p2까지 끝난 뒤에 출력된다.', false),
(11980, 4427, 'p1과 p2는 코드에서 n1보다 먼저 예약됐으므로 n1보다 먼저 출력된다.', '순서를 정하는 것은 예약 순서가 아니라 큐의 종류다. 콜 스택이 비면 nextTick 큐를 먼저 비우므로, 코드에서 가장 늦게 예약된 n1이 p1·p2보다 먼저 출력된다.', false),
(11981, 4427, 'p2가 출력된 뒤 t가 출력되기 전까지, 그 사이에 출력되는 것은 n2 하나뿐이다.', 'n1이 nextTick 큐에서 가장 먼저 나오고, Promise 큐는 빌 때까지 p1·p2를 이어서 실행한다. p1이 예약한 n2는 Promise 큐가 빈 뒤 다시 확인한 nextTick 큐에서 실행되고, 두 큐가 모두 비어야 t로 넘어간다. 전체 순서는 n1 → p1 → p2 → n2 → t다.', true),
(11982, 4427, 'p1이 예약한 n2는 마이크로태스크를 비우는 도중 새로 예약됐으므로 t보다 늦게 출력된다.', '새로 추가된 작업을 다음 순회로 넘기는 것은 매크로태스크의 규칙이다. 마이크로태스크는 비우는 도중 추가된 것까지 모두 실행한 뒤에야 타이머 콜백 t로 넘어가므로 n2가 t보다 앞선다.', false),

-- 문제 4428
(11983, 4428, 'return new Promise((resolve) => resolve(cb(cache.get(id))));', 'Promise 생성자에 넘긴 실행 함수(executor)는 new Promise를 호출하는 즉시 동기적으로 실행된다. 그 안에서 cb가 불리므로 label이 바뀌기 전에 ''로딩 중''이 출력된다. Promise로 감쌌다고 비동기가 되지는 않는다.', false),
(11984, 4428, 'return process.nextTick(cb(cache.get(id)));', '인자 cb(cache.get(id))가 nextTick 호출보다 먼저 평가되어 cb가 그 자리에서 실행되고 ''로딩 중''이 출력된다. nextTick에는 함수가 아닌 반환값 undefined가 넘어가 ERR_INVALID_ARG_TYPE 오류까지 난다. 미루려면 함수 자체를 넘겨야 한다.', false),
(11985, 4428, 'return (async () => cb(cache.get(id)))();', 'async 함수는 첫 await를 만나기 전까지 호출한 쪽과 같은 흐름에서 동기적으로 실행된다. 본문에 await가 없으니 cb가 곧바로 불려 ''로딩 중''이 출력되고, 반환값만 Promise로 감싸진다.', false),
(11986, 4428, 'return Promise.resolve().then(() => cb(cache.get(id)));', 'then에 넘긴 콜백은 Promise 마이크로태스크로 예약되어 show의 남은 동기 코드(label = ''완료'')가 끝난 뒤 실행된다. 캐시 히트여도 콜백이 항상 비동기로 불려 두 호출 결과가 같아진다. process.nextTick(cb, cache.get(id))도 같은 목적으로 쓴다.', true),

-- 문제 4429
(11987, 4429, '''ready''가 출력되지 않는다. await 뒤 코드는 Promise 큐에 들어가 nextTick 큐의 발행보다 늦게 실행된다.', 'await null은 뒤 코드를 Promise 마이크로태스크로 예약한다. 콜 스택이 비면 nextTick 큐가 Promise 큐보다 먼저 처리되어, 리스너 없이 emit이 끝난 뒤에야 on이 등록된다. nextTick으로 미루는 방식은 호출자가 같은 동기 코드 안에서 리스너를 붙일 때만 유실을 막아 준다.', true),
(11988, 4429, '''ready''가 출력된다. nextTick으로 미룬 발행은 main의 await 뒤 코드까지 끝난 뒤에 실행된다.', 'nextTick은 async 함수가 끝나기를 기다리지 않는다. await 뒤 코드는 Promise 큐에 들어가는데 nextTick 큐가 그보다 먼저 비워지므로, 발행이 on 등록보다 앞서 리스너 없이 끝난다.', false),
(11989, 4429, '''ready''가 출력된다. await null은 기다릴 Promise가 없어 건너뛰므로 on이 발행보다 먼저 등록된다.', 'await는 값이 Promise가 아니어도 반드시 한 번 마이크로태스크 큐를 거친다. 그래서 on 등록은 동기 흐름을 벗어나 Promise 큐로 밀리고, 먼저 처리되는 nextTick 큐의 발행보다 늦어진다.', false),
(11990, 4429, '''ready''가 출력되지 않는다. await 뒤 코드는 매크로태스크로 예약되어 다음 루프 순회에서 실행된다.', '출력이 없다는 결과는 맞지만 이유가 틀렸다. await 뒤 코드는 매크로태스크가 아니라 Promise 마이크로태스크라 다음 매크로태스크 전에 실행된다. 발행이 앞선 것은 nextTick 큐가 Promise 큐보다 먼저 처리되기 때문이다.', false),

-- 문제 4430
(11991, 4430, 'A가 늦은 것은 step 한 번의 처리량 탓이므로, 1,000개씩을 100개씩으로 줄이면 tick이 약 100ms에 실행된다.', '한 번에 처리하는 양을 줄여도 A는 다음 step을 계속 nextTick 큐에 넣으므로 배열 처리가 끝날 때까지 큐가 비지 않는다. 원인은 한 번의 처리 시간이 아니라 이벤트 루프가 타이머 페이즈로 넘어가지 못하는 데 있다.', false),
(11992, 4430, 'C 방식에서 step마다 진행률 출력을 setImmediate로 예약하면, 그 출력도 배열을 다 처리한 뒤에야 나온다.', 'setImmediate 콜백은 check 페이즈에서 실행되는 매크로태스크라 tick과 처지가 같다. C는 배열 처리 내내 마이크로태스크 큐를 채워 두므로 이벤트 루프가 check 페이즈에 닿지 못하고, 진행률 출력도 처리가 끝난 뒤 한꺼번에 나온다.', true),
(11993, 4430, 'D에서 tick이 제때 실행된 것은 setImmediate 콜백이 타이머 페이즈에서 tick과 함께 처리되기 때문이다.', 'setImmediate 콜백은 타이머 페이즈가 아니라 poll 페이즈 다음의 check 페이즈에서 실행된다. 반복마다 이벤트 루프가 한 바퀴를 돌며 타이머 페이즈를 지나므로, 만료된 tick이 제 차례를 얻은 것이다.', false),
(11994, 4430, 'B는 ECMAScript 표준 큐를 쓰므로, 같은 코드를 브라우저에서 돌리면 반복 사이사이에 tick이 끼어 제때 실행된다.', '브라우저도 태스크 하나가 끝날 때마다 마이크로태스크 큐를 빌 때까지 비운다. Promise 재귀가 큐를 계속 채우면 타이머 콜백은 차례를 얻지 못하므로, 표준 큐라서 중간에 양보한다고 본 것은 오해다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1432, 4431, 'queueMicrotask,queueMicrotask(),globalThis.queueMicrotask,window.queueMicrotask,큐마이크로태스크', 'queueMicrotask는 브라우저와 Node.js가 모두 제공하는 전역 함수로, 콜백을 Promise 콜백과 같은 마이크로태스크 큐에 넣는다. 그래서 먼저 예약된 promise 바로 다음, 매크로태스크인 0ms 타이머보다는 앞서 flush가 출력된다. 원래 쓰던 process.nextTick은 Node.js 전용이라 브라우저에서 ReferenceError가 나고, Node.js에서도 Promise 큐보다 먼저 비워지는 별도 큐라 flush가 promise보다 앞섰을 것이다. setImmediate는 브라우저에 없는 데다 매크로태스크라 timeout과 함께 뒤로 밀리고, Promise.resolve().then(flush)는 순서는 같지만 전역 함수 하나를 부르는 형태가 아니다. 브라우저와 코드를 공유하는 라이브러리에서 마이크로태스크를 예약할 때 queueMicrotask를 쓰는 이유다.'),
       (1433, 4432, '매크로태스크,매크로 태스크,macrotask,macro task,macro-task', '코드에서 가장 늦게 예약된 p0가 d1보다 먼저 나왔으니 defer 콜백은 마이크로태스크를 모두 비운 뒤에 실행된다. 또 d1이 예약한 p1이 d2보다 앞섰으니 defer 콜백은 한 번에 하나씩 실행되고, 그 사이마다 마이크로태스크 큐가 비워진다. 재귀 예약 중에도 HTTP 요청이 처리된 것은 반복마다 이벤트 루프가 poll 페이즈를 지나기 때문이다. 세 가지 모두 매크로태스크의 특징이며, 실제로 setTimeout(fn, 0)이나 setImmediate로 defer를 만들면 이 결과가 나온다. 반대로 process.nextTick이나 queueMicrotask 같은 마이크로태스크였다면 d1 → d2 → p0 → p1 순으로 출력되고, 재귀 예약 중 HTTP 요청은 기아 상태에 빠졌을 것이다.');

-- =====================================================
-- Lesson 866: 큐 비우기 규칙과 이벤트 루프 양보
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5375, 866, '아래 코드의 출력 순서로 옳은 것은?', '```javascript
// app.js (CommonJS) — Node.js 20에서 실행
setImmediate(() => {
  console.log(''I1'');
  Promise.resolve().then(() => console.log(''P1''));
  process.nextTick(() => console.log(''N1''));
});

setImmediate(() => console.log(''I2''));

Promise.resolve().then(() => console.log(''P0''));
```', 'OBJECTIVE'),
       (5376, 866, '아래 코드를 실행했을 때 출력되는 값에 가장 가까운 것은?', '```javascript
// app.js (CommonJS) — Node.js 20에서 실행
function busy(ms) {
  const end = Date.now() + ms;
  while (Date.now() < end) {} // ms 동안 CPU를 붙잡는 동기 반복
}

const start = Date.now();

setTimeout(() => {
  console.log(Date.now() - start);
}, 100);

Promise.resolve().then(() => busy(200));

busy(300);
```', 'OBJECTIVE'),
       (5377, 866, '아래 코드를 실행했을 때 console.log 출력과 그 이유로 옳은 것은?', '```javascript
// app.js (CommonJS) — Node.js 20에서 실행
async function loadConfig() {
  console.log(''load'');
  throw new Error(''설정 파일 없음'');
}

try {
  loadConfig();
  console.log(''ok'');
} catch (e) {
  console.log(''caught'');
}
```', 'OBJECTIVE'),
       (5378, 866, '아래 표의 유틸에 대한 설명으로 옳은 것은?', '사내 공통 라이브러리에는 콜백을 예약하는 유틸 세 개가 있고, 내부 구현은 아래와 같다(Node.js 20).

| 유틸 | 내부 구현 |
|---|---|
| `runA(fn)` | `process.nextTick(fn)` |
| `runB(fn)` | `Promise.resolve().then(fn)` |
| `runC(fn)` | `setImmediate(fn)` |', 'OBJECTIVE'),
       (5379, 866, '아래 코드를 실행했을 때 출력되는 n의 값은?', '```javascript
// app.js (CommonJS) — Node.js 20에서 실행
let n = 0;

function inc() {
  n += 1;
  if (n < 3) process.nextTick(inc);
}

Promise.resolve().then(() => {
  n *= 10;
  queueMicrotask(() => {
    n += 5;
  });
});

setImmediate(() => console.log(n));

inc();
```', 'SUBJECTIVE'),
       (5380, 866, '아래 상황에서 ???에 바꿔 넣은 함수의 이름은?', 'Node.js 20으로 만든 작업 서버는 메모리 대기열에 쌓인 작업 20만 건을 하나씩 처리하며, 전부 끝내는 데 약 4분이 걸린다. 작업 하나를 끝낼 때마다 `???(loop)`로 다음 처리를 예약하는데, 처음에는 ??? 자리에 `queueMicrotask`를 썼다.

그러자 처리 도중 배포가 시작되면, 쿠버네티스가 보낸 SIGTERM을 받아 정리 작업을 하는 `process.on(''SIGTERM'', ...)` 핸들러가 30초의 유예 시간 내내 실행되지 않았고 서버는 결국 SIGKILL로 강제 종료됐다.

??? 자리를 다른 전역 함수로 바꾸자 전체 처리 시간은 3%가량 늘었지만, SIGTERM을 받은 지 몇 ms 만에 핸들러가 실행됐다. 다만 같은 모듈을 브라우저에서 그대로 불러오자 `ReferenceError: ??? is not defined`가 발생했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5375
(14507, 5375, 'I1 → I2 → P0 → N1 → P1', 'setImmediate를 이름대로 ''즉시'' 실행된다고 본 오해다. setImmediate 콜백은 check 페이즈에서 실행되는 매크로태스크라, 메인 코드가 끝나면 마이크로태스크인 P0가 먼저 출력된다.', false),
(14508, 5375, 'P0 → I1 → P1 → N1 → I2', '같은 콜백 안에서 먼저 예약한 P1이 먼저 나온다고 본 오해다. 콜백 하나가 끝나면 nextTick 큐를 Promise 큐보다 먼저 비우므로, 나중에 예약된 N1이 P1보다 앞선다.', false),
(14509, 5375, 'P0 → I1 → I2 → N1 → P1', 'check 페이즈의 콜백을 모두 실행한 뒤에야 마이크로태스크를 비운다고 본 오해로, Node.js 10까지의 동작이다. Node.js 11부터는 setImmediate 콜백 하나가 끝날 때마다 마이크로태스크를 비운다.', false),
(14510, 5375, 'P0 → I1 → N1 → P1 → I2', '메인 코드가 끝나면 마이크로태스크 P0가 먼저 출력된다. check 페이즈에서 I1이 끝나자마자 nextTick 큐(N1) → Promise 큐(P1) 순으로 비우고, 그다음에야 두 번째 매크로태스크 I2로 넘어간다.', true),

-- 문제 5376
(14511, 5376, '약 100', '100ms가 되면 타이머가 실행 중인 동기 코드를 끊고 끼어든다고 본 오해다. 타이머 콜백은 콜 스택이 빈 뒤에야 실행될 수 있어, 100ms는 보장된 시각이 아니라 최소 지연일 뿐이다.', false),
(14512, 5376, '약 300', '먼저 예약되어 이미 만료된 타이머가 Promise 콜백보다 먼저 실행된다고 본 오해다. 동기 코드가 끝나면 마이크로태스크인 busy(200)을 먼저 처리한 뒤에야 타이머 페이즈로 넘어간다.', false),
(14513, 5376, '약 500', '동기 busy(300)이 약 300ms에 끝나면 Promise 콜백 busy(200)이 이어서 약 500ms까지 실행된다. 타이머는 100ms에 이미 만료됐지만 마이크로태스크가 모두 빈 뒤에야 콜백이 실행돼 약 500이 출력된다.', true),
(14514, 5376, '약 600', '100ms 지연을 앞선 작업이 모두 끝난 뒤부터 센다고 본 오해다. 지연은 setTimeout을 호출한 시점부터 재므로, 약 500ms에 마이크로태스크가 끝났을 때 타이머는 이미 만료돼 곧바로 실행된다.', false),

-- 문제 5377
(14515, 5377, 'load → caught: 첫 await 전까지는 동기적으로 실행되므로 throw도 그 자리에서 호출자에게 전달된다.', '첫 await 전까지 본문이 동기적으로 실행된다는 앞부분은 맞다. 하지만 async 함수 안의 throw는 호출자에게 던져지지 않고 반환할 Promise를 거부 상태로 만들 뿐이라, try/catch가 잡을 예외가 생기지 않는다.', false),
(14516, 5377, 'load → ok: throw는 반환된 Promise를 거부 상태로 만들 뿐이라 try/catch가 잡지 못한다.', 'async 함수의 예외는 반환된 Promise의 거부로 바뀐다. loadConfig()는 예외를 던지지 않고 거부된 Promise를 돌려주므로 ok가 찍힌다. 이 거부는 처리되지 않아 Node.js 20에서는 오류와 함께 종료되며, await나 .catch()로 받아야 잡힌다.', true),
(14517, 5377, 'load → ok → caught: 예외가 마이크로태스크로 전달되므로 동기 코드가 끝난 뒤에 catch 블록이 실행된다.', 'catch 블록은 try 블록이 실행되는 동안 동기적으로 던져진 예외만 받는다. 거부된 Promise는 예외가 아니라 반환값이므로, 나중에 catch 블록이 따로 실행되는 일은 없고 caught는 출력되지 않는다.', false),
(14518, 5377, 'ok → load: async 함수 본문 전체가 마이크로태스크로 예약되므로 try 블록이 끝난 뒤에 실행된다.', 'async 함수를 호출하면 본문이 곧바로 동기적으로 실행되고, 첫 await를 만날 때 비로소 나머지가 마이크로태스크로 미뤄진다. 이 함수에는 await가 없어 load가 ok보다 먼저 출력된다.', false),

-- 문제 5378
(14519, 5378, 'runC 콜백 안에서 다시 runC를 부르면, 새 콜백은 다음 루프 순회의 check 페이즈에서 실행된다.', 'runC는 setImmediate라 매크로태스크다. check 페이즈 도중 새로 예약된 setImmediate 콜백은 다음 루프 순회로 넘어가므로, 그 사이 poll 페이즈를 거치며 I/O 콜백이 차례를 얻는다. 재귀 예약해도 I/O가 굶지 않는 이유다.', true),
(14520, 5378, 'runA로 자기 자신을 재귀 예약하는 동안에도, runB로 예약해 둔 콜백은 반복 사이사이에 실행된다.', 'runA는 process.nextTick이다. nextTick 큐는 비우는 도중 새로 들어온 콜백까지 모두 실행해야 Promise 큐로 넘어가므로, 재귀 예약이 이어지는 동안 runB(Promise) 콜백은 한 번도 실행되지 못한다.', false),
(14521, 5378, 'runB 콜백 안에서 runA를 부르면, 새 runA 콜백은 다음 루프 순회가 돌아올 때까지 미뤄진다.', 'Promise 콜백이 예약한 nextTick 콜백은 Promise 큐를 비운 직후 다시 확인하는 nextTick 큐에서 실행된다. 마이크로태스크는 매크로태스크로 넘어가기 전에 새로 쌓인 것까지 모두 비우므로 다음 순회로 밀리지 않는다.', false),
(14522, 5378, '같은 동기 코드에서 runC를 먼저, runB를 나중에 부르면 먼저 부른 runC의 콜백이 먼저 실행된다.', '순서를 정하는 것은 호출 순서가 아니라 작업의 종류다. runB(Promise)는 마이크로태스크라 현재 코드가 끝난 직후 실행되고, runC(setImmediate)는 매크로태스크라 check 페이즈까지 기다리므로 runB 콜백이 먼저다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1748, 5379, '35', '동기 구간에서 inc()가 한 번 실행돼 n = 1이 되고, nextTick으로 inc가 다시 예약된다. 콜 스택이 비면 nextTick 큐부터 비우는데, 비우는 도중 새로 예약된 inc까지 이어서 실행하므로 n은 3이 된 뒤 멈춘다. 이어서 Promise 큐에서 n = 30이 되고, 그 콜백이 queueMicrotask로 넣은 콜백은 Promise 콜백과 같은 마이크로태스크 큐에 들어가 곧바로 이어서 실행되므로 n = 35가 된다. setImmediate 콜백은 두 마이크로태스크 큐가 모두 빈 뒤 check 페이즈에서 실행되는 매크로태스크라 35를 출력한다. Promise 큐를 nextTick 큐보다 먼저 비운다고 보면 16, 새로 예약된 nextTick이 Promise 큐 뒤로 밀린다고 보면 26, queueMicrotask를 매크로태스크로 착각하면 30, setImmediate가 이름대로 가장 먼저 실행된다고 보면 1이 나온다.'),
       (1749, 5380, 'setImmediate,setImmediate(),셋이미디엇,셋이미디어트', 'queueMicrotask로 예약한 콜백은 마이크로태스크라 큐가 빌 때까지 이어서 실행된다. 콜백이 매번 다음 콜백을 다시 넣으니 큐가 4분 내내 비지 않고, 이벤트 루프가 poll 페이즈로 넘어가지 못해 SIGTERM 같은 신호를 처리하는 콜백이 차례를 얻지 못한다(기아). setImmediate로 예약한 콜백은 check 페이즈에서 실행되는 매크로태스크라, 반복마다 루프가 한 바퀴 돌며 poll 페이즈를 거치므로 핸들러가 곧 실행된다. 브라우저에는 없는 Node.js 고유 API라 ReferenceError가 났다. process.nextTick도 Node.js 전용이지만 마이크로태스크라 같은 기아가 생기고(오류 메시지도 process is not defined), setTimeout(loop, 0)은 I/O에 양보하지만 브라우저에도 있어 오류가 나지 않으며 반복마다 최소 1ms 지연이 붙어 처리 시간이 크게 늘어난다.');
