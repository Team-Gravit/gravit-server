-- Unit: 메모리 누수 진단 (Unit ID: 131)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (557, 131, '메모리 지표와 스냅샷 비교, WeakMap'),
       (715, 131, '리스너 누수와 Retainers 경로 추적'),
       (873, 131, 'Node.js 메모리 누수 진단: 오래 사는 객체에 매달린 참조와 도구 고르기');

-- =====================================================
-- Lesson 557: 메모리 지표와 스냅샷 비교, WeakMap
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3521, 557, '아래 프로세스 메모리 지표 추이를 근거로 내릴 수 있는 판단으로 옳은 것은?', 'Node.js API 서버를 재시작한 뒤 `process.memoryUsage()`를 5분 간격으로 수집했다. 아래는 그중 일부이며 값은 모두 MB 단위다.

| 경과 시간 | rss | heapTotal | heapUsed | external |
| --- | --- | --- | --- | --- |
| 0분 | 182 | 108 | 94 | 11 |
| 30분 | 351 | 110 | 97 | 168 |
| 60분 | 528 | 109 | 95 | 344 |
| 90분 | 704 | 110 | 96 | 519 |

같은 구간의 `--trace-gc` 로그에서 Mark-Compact는 정상적으로 실행되고 있으며, 수집 직후 heapUsed는 매번 90MB 안팎으로 돌아온다. 트래픽 양은 90분 내내 일정했다.', 'OBJECTIVE'),
       (3522, 557, '아래 코드가 실행된 뒤의 메모리 회수에 대한 설명으로 옳은 것은?', '```javascript
// rows: 데이터베이스에서 한 번에 읽어 온 조회 결과 (약 40MB)
function register(rows) {
  const summary = { count: rows.length };
  const onTick = () => log(summary);      // rows를 직접 쓰지 않는다
  const pickFirst = () => rows[0];
  setInterval(onTick, 60_000);            // clearInterval을 부르는 곳이 없다
  return pickFirst;
}

const first = register(await db.fetchAll());
console.log(first());
// 이후 first를 다시 참조하는 코드는 없다
```', 'OBJECTIVE'),
       (3523, 557, '아래 힙 스냅샷 비교 결과에 대한 설명으로 옳지 않은 것은?', '스테이징 서버에 요청을 정확히 5,000회 흘린 뒤 강제 수집을 하고 스냅샷 3을 찍었다. 아래는 스냅샷 2를 기준으로 한 Comparison 뷰 결과다.

| 생성자 | # New | # Deleted | # Delta | Retained Size 증가분 |
| --- | --- | --- | --- | --- |
| RequestContext | 5,004 | 2 | +5,002 | 96.4MB |
| (closure) | 5,131 | 129 | +5,002 | 41.2MB |
| (string) | 24,880 | 24,010 | +870 | 2.1MB |
| Timeout | 6 | 5 | +1 | 0.1MB |', 'OBJECTIVE'),
       (3524, 557, '아래에서 팀이 교체한 자료구조에 대한 설명으로 옳은 것은?', '요청 객체를 키로, 추적 ID와 시작 시각을 값으로 담는 모듈 스코프 `Map`을 두었다. 요청이 끝난 뒤 항목을 지우는 코드가 없어 힙이 단조 증가했고, 힙 스냅샷에서는 이 `Map`이 처리가 끝난 요청 객체를 붙잡고 있는 경로가 그대로 보였다.

팀은 `delete`를 호출하는 코드를 넣는 대신, 키로 쓴 객체를 다른 곳에서 아무도 참조하지 않게 되면 그 항목이 함께 사라지는 자료구조로 `Map`을 교체했다.', 'OBJECTIVE'),
       (3525, 557, '아래 로그에서 수집을 마친 뒤에도 계속 커지고 있는 V8 힙 영역의 이름은?', '`node --trace-gc server.js`로 띄운 프로세스에 같은 양의 트래픽을 90분간 흘리며 남긴 로그의 일부다. 화살표 앞뒤는 수집 전후의 힙 사용량, 괄호 안은 그 시점에 확보해 둔 힙 크기다.

```
Scavenge        418.2 (515.4) -> 409.6 (515.4) MB, 1.1 ms
Scavenge        425.0 (515.4) -> 410.3 (515.4) MB, 1.0 ms
Mark-Compact    512.7 (620.1) -> 402.4 (620.1) MB, 238.6 ms
Scavenge        821.5 (921.3) -> 812.9 (921.3) MB, 1.2 ms
Mark-Compact    918.8 (1024.6) -> 806.1 (1024.6) MB, 401.2 ms
Mark-Compact   1290.4 (1400.2) -> 1183.0 (1400.2) MB, 512.9 ms
```

짧은 수집은 매번 10MB 안팎만 줄이고 끝난다. 무거운 수집을 마친 뒤 남는 양은 402MB, 806MB, 1,183MB로 회차마다 커지고 정지 시간도 238ms에서 512ms로 늘어난다.', 'SUBJECTIVE'),
       (3526, 557, '아래에서 CacheEntry를 목록 맨 위로 끌어올려 주는 힙 스냅샷 컬럼의 이름은?', '힙 스냅샷 Summary 뷰에서 `CacheEntry`는 한 개당 48바이트로 표시돼, 크기 순으로 정렬해도 목록 한참 아래에 묻혀 있었다. 그런데 인스턴스마다 40KB짜리 응답 본문을 하나씩 물고 있었고, 캐시에서 `CacheEntry` 12,000개를 끊어 내자 힙이 480MB 줄었다. 스냅샷 표에는 크기를 나타내는 컬럼이 두 개 있는데, 48바이트를 보여 준 쪽이 아니라 나머지 한 쪽으로 정렬해야 이 생성자가 첫 화면에 나온다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3521
(9563, 3521, '--max-old-space-size로 힙 상한을 올리면 메모리 증가 추세가 멈춘다.', '이 플래그는 V8 힙에만 걸리는 상한이다. 표에서 커지는 값은 힙 밖 영역이므로 상한을 올려도 rss는 같은 기울기로 계속 오르고 OOM 시점만 조금 늦춰진다.', false),
(9564, 3521, 'V8 힙 밖에서 관리되는 Buffer 등 네이티브 자원이 해제되지 않고 쌓이고 있다.', 'heapTotal과 heapUsed는 90~110MB에서 평평한데 external만 11MB에서 519MB로 늘었다. 이 증가분이 rss 증가분과 거의 같으므로 누적 지점은 V8 힙 안이 아니라 밖이다.', true),
(9565, 3521, '힙 스냅샷을 두 번 찍어 Comparison 뷰에서 Delta가 큰 생성자를 찾으면 원인이 드러난다.', '힙 스냅샷은 V8 힙 안의 객체만 담는다. 힙 안이 평평하니 Delta도 거의 잡히지 않는다. 이때는 Buffer 할당 지점 추적이나 네이티브 쪽 프로파일러가 필요하다.', false),
(9566, 3521, 'heapUsed가 일정하므로 누수는 없고 GC가 제 역할을 하고 있는 정상 상태다.', 'heapUsed가 누수 판단의 1차 지표인 것은 맞지만 유일한 지표는 아니다. 트래픽이 일정한데 rss가 90분 내내 단조 증가하면 결국 OOM으로 죽는다.', false),

-- 문제 3522
(9567, 3522, 'summary가 rows.length만 담으므로 rows는 곧 회수되고, 남는 것은 Timeout 객체 하나뿐이다.', '문제는 Timeout 객체 자체의 크기가 아니라 그것이 붙잡고 있는 스코프다. rows는 회수되지 않은 채 Old Space에 남고, 스냅샷에서는 (closure)의 Retained Size로 드러난다.', false),
(9568, 3522, '활성 타이머의 콜백은 GC 루트가 아니므로 함수가 반환되는 순간 참조가 모두 끊긴다.', '등록된 타이머와 그 콜백은 clearInterval로 해제될 때까지 GC 루트에서 도달 가능하다. 루트에서 도달 가능하면 아무도 쓰지 않는 값이어도 회수 대상이 아니다.', false),
(9569, 3522, '두 클로저가 같은 컨텍스트 객체를 공유하므로 타이머가 살아 있는 한 rows 40MB도 함께 남는다.', 'V8은 한 스코프에서 만들어진 클로저들이 컨텍스트를 공유한다. onTick이 summary만 읽어도 그 컨텍스트 안에 rows가 들어 있어 타이머 수명만큼 40MB가 유지된다.', true),
(9570, 3522, 'onTick이 참조하는 값은 summary뿐이므로 rows는 register가 반환되는 즉시 회수된다.', '클로저가 실제로 읽는 변수만 골라 잡는다는 오해다. 회수 단위는 변수 하나가 아니라 스코프 컨텍스트여서, 같은 스코프에 있던 큰 값이 통째로 끌려 남는다.', false),

-- 문제 3523
(9571, 3523, 'RequestContext와 (closure)의 Delta가 흘린 요청 수와 거의 같아, 요청 하나마다 객체가 남는 구조를 의심할 근거가 된다.', '참이다. 부하를 N회로 통제했을 때 Delta가 N에 비례하는 생성자가 곧 누수 지점이다. 여기서는 +5,002가 요청 5,000회에 붙어 있어 요청 단위로 남는다고 볼 수 있다.', false),
(9572, 3523, 'Timeout의 Delta가 +1에 그치므로, 타이머가 요청마다 쌓이는 경로는 원인 후보에서 뒤로 미룰 수 있다.', '참이다. 타이머 누수라면 Timeout의 Delta도 요청 수를 따라 올라간다. 증가가 없으니 먼저 볼 곳은 요청 객체를 붙잡고 있는 컬렉션이나 제거되지 않은 리스너 쪽이다.', false),
(9573, 3523, 'RequestContext 인스턴스 하나를 열어 Retainers를 루트 방향으로 따라가면 붙잡고 있는 코드 지점을 좁힐 수 있다.', '참이다. Retainers는 이 객체를 누가 참조하는지 역방향으로 보여 준다. 경로 중간에 Map이나 EventEmitter의 _events가 나타나면 그 자리가 곧 수정 지점이다.', false),
(9574, 3523, '(string)은 # New가 24,880으로 가장 많으므로 다른 생성자보다 먼저 원인으로 지목해야 한다.', '# New는 그동안 새로 만들어진 수일 뿐이다. (string)은 # Deleted가 24,010이라 대부분 회수됐고 Delta는 +870, Retained 증가분도 2.1MB에 그친다. 판단은 Delta와 Retained Size로 한다.', true),

-- 문제 3524
(9575, 3524, '담긴 항목을 순회하거나 개수를 셀 수 없어, 추적 중인 요청 수를 지표로 내보내려면 별도 카운터가 필요하다.', 'WeakMap은 키가 언제 회수될지 정해지지 않아 순회와 size 조회를 제공하지 않는다. 이 제약을 모른 채 모니터링 지표를 여기서 바로 뽑으려다 막히는 일이 흔하다.', true),
(9576, 3524, '키를 요청 객체 대신 요청 ID 문자열로 바꿔도 같은 자동 회수 효과를 그대로 얻는다.', '키가 객체일 때만 성립하는 방식이라 문자열이나 숫자는 키로 쓸 수 없다. 문자열 키가 필요하면 결국 상한과 만료를 갖춘 캐시로 돌아가야 한다.', false),
(9577, 3524, '값으로 넣은 객체가 회수될 때 정리 콜백이 함께 실행되므로 소켓이나 파일 핸들 해제까지 맡길 수 있다.', '회수 시점에 콜백을 받는 것은 FinalizationRegistry이고, 그마저 실행 시점이 보장되지 않는다. 반드시 해야 하는 정리는 명시적인 해제 경로로 처리해야 한다.', false),
(9578, 3524, '항목 수 상한과 만료 시간이 내부에 있어, 조회 결과를 담는 일반 캐시도 이것으로 바꾸면 최대 크기를 정할 필요가 없다.', '약한 참조는 참조가 수명을 결정하는 구조를 푸는 도구일 뿐 상한과 만료를 대신하지 않는다. 키가 살아 있으면 값도 그대로 남으므로 일반 캐시에는 여전히 LRU와 TTL이 필요하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1130, 3525, 'Old Space,올드 스페이스,Old 영역,올드 영역,Old Generation,올드 제너레이션,구세대,구세대 영역,올드 세대,Old 세대,오래된 세대', 'Scavenge는 New Space만 훑기 때문에 매번 10MB 남짓만 줄이고 끝난다. 반면 Mark-Compact가 정리를 마친 뒤 남는 양이 402MB, 806MB, 1,183MB로 커지는데, 이 잔존량이 곧 Old Space에 쌓인 객체다. 두 번 살아남아 승격된 객체가 GC 루트에서 여전히 도달 가능하다는 뜻이며, Old Space가 단조 증가하는 그래프는 메모리 누수의 전형적인 모습이다. New Space는 수 MB 규모로 고정돼 있어 단조 증가의 무대가 될 수 없고, heapUsed는 평평한데 rss만 오르는 힙 밖(external) 누수와도 구분해야 한다. 정지 시간이 238ms에서 512ms로 늘어난 것도 훑어야 할 Old Space가 커진 결과다.'),
       (1131, 3526, 'Retained Size,retained size,retainedsize,리테인드 사이즈,리테인드사이즈,유지 크기,보유 크기,Retained', 'Shallow Size는 객체 자체가 차지하는 48바이트만 세지만, Retained Size는 그 객체가 사라질 때 함께 회수되는 총량을 센다. CacheEntry 하나가 40KB 응답 본문을 붙잡고 있으니 12,000개면 480MB이고, 이 값이 누수의 실제 크기다. 작은 객체가 큰 데이터를 물고 있을 때 Shallow Size로 정렬하면 원인이 목록 아래에 묻히는 이유가 여기에 있다. 다만 Retained Size 상단에는 (GC roots)나 system 같은 내부 항목이 먼저 오므로, 애플리케이션 클래스명이나 (closure)가 처음 나타나는 행부터 보면 시간을 아낄 수 있다. 참조 거리를 뜻하는 Distance와도 구분한다. Distance가 짧으면 전역이나 모듈 스코프에 가깝게 매달려 있다는 뜻일 뿐 크기 정보는 아니다.');

-- =====================================================
-- Lesson 715: 리스너 누수와 Retainers 경로 추적
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4469, 715, '아래 SSE 핸들러 코드에 대한 설명으로 옳은 것은?', 'SSE(Server-Sent Events) 연결이 하나 들어올 때마다 아래 핸들러가 실행된다. `bus`는 프로세스 전체가 함께 쓰는 `EventEmitter` 인스턴스 하나다.

```javascript
app.get("/events", (req, res) => {
  bus.on("update", (data) => res.write(`data: ${JSON.stringify(data)}\n\n`));

  res.on("close", () => {
    bus.off("update", (data) => res.write(`data: ${JSON.stringify(data)}\n\n`));
  });
});
```', 'OBJECTIVE'),
       (4470, 715, '아래 힙 스냅샷 측정 절차와 결과에 대한 판단으로 옳은 것은?', '스테이징 서버에서 아래 순서로 힙 스냅샷 세 장을 찍었다. 매 촬영 직전에는 DevTools Memory 탭의 수집 버튼을 눌러 강제로 GC를 돌렸다.

1. 서버 기동 직후 스냅샷 1
2. `/orders` 요청을 정확히 1,000회 보낸 뒤 스냅샷 2
3. 같은 요청을 다시 1,000회 보낸 뒤 스냅샷 3

| 생성자 | 1→2 # Delta | 2→3 # Delta |
| --- | --- | --- |
| (compiled code) | +3,410 | +6 |
| (string) | +5,820 | +41 |
| TemplateCache | +240 | 0 |
| OrderContext | +1,003 | +1,000 |', 'OBJECTIVE'),
       (4471, 715, '아래 Retainers 경로를 근거로 고른 근본 수정으로 옳은 것은?', '부하 시험 뒤 Comparison 뷰에서 요청 수만큼 늘어난 `SessionData` 인스턴스 하나를 골라, Retainers 패널을 루트 방향으로 펼쳤다. 아래는 그 경로를 옮긴 것이다(일부 행 생략).

```
▼ SessionData @84213
  ▼ table in Map @30637
    ▼ sessions in system / Context @30633
      ▼ context in function handleLogin() @30629
        ▼ handleLogin in Object @30625
          ▼ exports in Module @30601
            ▼ /app/routes/auth.js in Object @1187
              ▼ (GC roots)
```', 'OBJECTIVE'),
       (4472, 715, '아래 인스턴스 중 힙 스냅샷을 받기에 알맞은 곳은?', '운영 중인 Node.js 인스턴스 네 대에서 같은 누수가 재현되고 있다. 한 대를 골라 `kill -USR2 <pid>`로 힙 스냅샷 파일을 받으려 한다.

| 인스턴스 | 트래픽 | 컨테이너 메모리 한도 | 현재 heapUsed | 실행 명령 |
| --- | --- | --- | --- | --- |
| A | 초당 900건 처리 중 | 4GB | 1.2GB | `node --heapsnapshot-signal=SIGUSR2 server.js` |
| B | 로드밸런서에서 제외됨 | 1.5GB | 1.2GB | `node --heapsnapshot-signal=SIGUSR2 server.js` |
| C | 로드밸런서에서 제외됨 | 4GB | 1.2GB | `node server.js` |
| D | 로드밸런서에서 제외됨 | 4GB | 1.2GB | `node --heapsnapshot-signal=SIGUSR2 server.js` |', 'OBJECTIVE'),
       (4473, 715, '아래 두 실험에서 객체의 회수 여부를 가른 기준을 가리키는 용어는?', '같은 CommonJS 모듈 안에서 두 실험을 한 뒤, 강제로 GC를 돌리고 힙 스냅샷을 찍었다.

```javascript
// 실험 1
const history = [];
function finishOrder(order) {
  history.push(order); // history에 넣은 주문을 다시 꺼내는 코드는 없다
}
module.exports = { finishOrder };

// 실험 2
let a = { name: "a" };
let b = { name: "b" };
a.peer = b;
b.peer = a;
a = null;
b = null;
```

- 실험 1: `finishOrder`로 넘긴 주문 객체 3,000개는 다시 쓰이지 않는데도 스냅샷에 모두 남아 있었다.
- 실험 2: 두 객체는 `peer`로 서로를 가리키는 참조를 그대로 가진 채 스냅샷에서 함께 사라졌다.', 'SUBJECTIVE'),
       (4474, 715, '아래에서 실행 명령에 붙인 Node.js 옵션의 이름은?', '메모리 한도가 1GB인 컨테이너에서 Node.js 서버를 `node server.js`로 띄웠다. 기동 로그에 찍은 `v8.getHeapStatistics().heap_size_limit` 값은 약 2,090MB였다. 누수가 있는 버전에 부하를 주자 rss가 1GB에 닿는 순간 컨테이너가 `OOMKilled`로 강제 종료됐고, 애플리케이션 로그에는 아무 오류도 남지 않았다.

실행 명령에 옵션 하나를 붙이고 값으로 `768`을 주자 `heap_size_limit`가 800MB대로 내려갔다. 같은 부하에서 이번에는 컨테이너가 죽기 전에 프로세스가 아래 로그를 남기고 스스로 종료돼, 힙 안에서 누수가 난다는 증거를 확보할 수 있었다.

```
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4469
(12091, 4469, 'bus가 리스너를 약한 참조로 들고 있어, 연결이 끊기면 리스너와 res가 다음 GC에서 함께 회수된다.', 'EventEmitter는 등록된 함수를 내부 _events에 일반 참조로 보관한다. 떼어 내기 전까지는 bus가 살아 있는 한 리스너와 그 클로저가 붙잡은 res도 회수되지 않는다.', false),
(12092, 4469, '같은 이벤트 이름으로 on을 다시 부르면 이전 리스너가 교체돼, bus에는 리스너가 늘 하나만 남는다.', 'on은 교체가 아니라 추가다. 연결마다 리스너가 배열에 하나씩 쌓이며, 개수가 기본 한도를 넘는 순간 MaxListenersExceededWarning이 출력되는 것도 이 때문이다.', false),
(12093, 4469, 'off에 넘긴 함수는 on에 넘긴 함수와 코드만 같은 별개의 객체라, 연결이 끊겨도 떼어지는 리스너가 없다.', 'off는 넘겨받은 함수와 같은(===) 객체를 찾아 지운다. 화살표 함수 식은 평가될 때마다 새 함수 객체를 만들므로 일치하는 리스너가 없고, 연결마다 리스너와 res가 남는다. 함수를 변수에 담아 on과 off에 같은 값을 넘겨야 한다.', true),
(12094, 4469, 'off는 이벤트 이름이 같은 리스너를 한꺼번에 지우므로, 한 연결이 끊기면 다른 연결도 업데이트를 못 받는다.', 'off(removeListener)는 넘긴 함수와 일치하는 리스너를 하나만 지운다. 이름이 같은 리스너를 모두 지우는 것은 removeAllListeners이고, 이 코드의 off는 일치하는 함수가 없어 아무것도 지우지 않는다.', false),

-- 문제 4470
(12095, 4470, '(compiled code)는 첫 구간에서 크게 늘어, 가장 먼저 추적할 누수 후보다.', '(compiled code)는 JIT가 코드를 컴파일하며 생긴 몫이라 워밍업이 끝나면 증가가 멈춘다. 2→3 구간에서 +6에 그쳐 요청 수와 관계가 없으므로 누수 후보가 아니다.', false),
(12096, 4470, 'TemplateCache는 둘째 구간에서 늘지 않아, 첫 구간 증가분을 초기화 몫으로 볼 수 있다.', '첫 요청들이 템플릿을 읽어 캐시를 채운 뒤로는 새 항목이 생기지 않았다. 스냅샷 1→2에는 이런 워밍업 객체가 섞이므로, 2→3 증가분을 기준으로 봐야 누수와 초기화를 구분할 수 있다.', true),
(12097, 4470, 'OrderContext는 첫 구간 증가폭이 (string)보다 작아, 누수 후보에서 뒤로 밀린다.', '첫 구간 크기로 순위를 매긴 오류다. OrderContext는 두 구간 모두 요청 1,000회에 맞춰 약 1,000개씩 늘어, 워밍업이 빠진 2→3 기준으로 보면 가장 유력한 누수 후보다.', false),
(12098, 4470, '(string)은 두 구간 합계 Delta가 가장 커서, 요청 수에 비례해 남는 객체다.', '합계의 대부분은 첫 구간의 워밍업 몫이다. 2→3에서는 요청 1,000회에 +41뿐이라 요청마다 남는 구조가 아니다. 비례 여부는 부하를 통제한 구간끼리 비교해야 드러난다.', false),

-- 문제 4471
(12099, 4471, '항목 수 상한과 만료 시간이 있는 캐시나 외부 저장소로 옮겨, 쌓이는 양에 끝을 둔다.', '경로는 모듈 스코프 변수 sessions가 가리키는 Map이 SessionData를 붙잡고 있음을 보여 준다. 넣기만 하고 빼지 않는 컬렉션이 원인이므로 LRU·TTL 캐시나 Redis 같은 외부 저장소로 상한을 둬야 한다.', true),
(12100, 4471, '요청이 끝날 때 clearInterval을 호출해, 타이머 콜백이 붙잡은 스코프를 풀어 준다.', 'context in function 행을 타이머 클로저로 오해한 선택이다. 이 컨텍스트는 Map을 쓰는 handleLogin의 스코프이고 경로에 Timeout이 없어, 타이머를 해제해도 Map의 참조는 그대로다.', false),
(12101, 4471, '연결이 끊길 때 off를 호출해, EventEmitter에 쌓인 요청별 리스너를 떼어 낸다.', '리스너 누적이라면 경로 중간에 EventEmitter의 _events 아래 배열이 나타난다. 이 경로에는 EventEmitter가 없어 떼어 낼 리스너가 없고, SessionData를 붙잡은 Map도 그대로 남는다.', false),
(12102, 4471, '메모리가 한도에 가까워지면 프로세스를 재시작하도록 설정해, 쌓인 객체를 비운다.', '재시작하면 Map이 비워져 당장 증상은 사라지지만, 참조 경로는 그대로라 같은 속도로 다시 쌓인다. 원인을 없애는 수정이 아니라 증상 완화에 그친다.', false),

-- 문제 4472
(12103, 4472, '인스턴스 A', '촬영하는 동안 이벤트 루프가 멈춘다. 초당 900건을 받는 중이라 1.2GB 힙을 기록하는 사이 들어온 요청이 응답을 받지 못하고 시간 초과가 난다. 먼저 트래픽에서 빼야 한다.', false),
(12104, 4472, '인스턴스 B', '스냅샷을 만드는 동안 힙 크기만큼의 메모리가 더 든다. 1.2GB 힙이면 합쳐서 2GB를 훌쩍 넘어 1.5GB 한도에 걸리므로, 파일이 나오기 전에 컨테이너가 강제 종료될 수 있다.', false),
(12105, 4472, '인스턴스 C', '--heapsnapshot-signal은 프로세스를 띄울 때 붙여야 한다. 옵션 없이 실행된 프로세스는 SIGUSR2를 처리할 곳이 없어, 스냅샷 대신 신호의 기본 동작대로 종료될 수 있다.', false),
(12106, 4472, '인스턴스 D', '트래픽에서 빠져 이벤트 루프가 멈춰도 요청 손실이 없고, 4GB 한도라 스냅샷에 드는 추가 메모리를 감당할 수 있다. 신호 옵션도 실행할 때 켜 두어 kill -USR2로 파일을 받을 수 있다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1446, 4473, '도달 가능성,도달가능성,도달성,도달 가능 여부,도달 가능,reachability,reachable,루트 도달 가능성,GC 루트 도달 가능성,GC 루트에서의 도달 가능성,접근 가능성', 'GC는 객체가 앞으로 쓰일지가 아니라, GC 루트(전역 객체, 실행 중인 스택, 활성 타이머의 콜백, 모듈 캐시 등)에서 참조를 따라가 닿을 수 있는지로 회수 여부를 정한다. 실험 1의 주문 객체는 require 캐시 → module.exports → finishOrder → 클로저 컨텍스트의 history → 주문 객체로 이어지는 경로가 살아 있어, 다시 꺼내 쓰는 코드가 없어도 회수되지 않는다. 그래서 누수는 늘 필요 없어진 객체로 향하는 참조 경로가 남아 있는 문제로 볼 수 있다. 실험 2의 두 객체는 서로를 가리키지만 루트에서 닿는 경로가 끊겼으므로 함께 회수된다. 참조 개수만 세는 참조 카운팅 방식이었다면 서로의 카운트가 남아 회수하지 못했을 장면이다. GC 루트는 탐색을 시작하는 출발점이고, Mark-Sweep은 이 기준으로 살아 있는 객체를 표시한 뒤 나머지를 치우는 알고리즘이므로 판단 기준 자체와는 구분한다.'),
       (1447, 4474, '--max-old-space-size,max-old-space-size,--max-old-space-size=768,max-old-space-size=768,--max_old_space_size,max_old_space_size,max old space size', '--max-old-space-size는 V8이 Old Space에 쓸 수 있는 크기의 상한을 MB 단위로 정한다. 값을 주지 않았을 때의 상한(여기서는 약 2GB)이 컨테이너 한도 1GB보다 커서, 힙이 상한에 닿기 전에 rss가 먼저 1GB를 넘었고 커널이 한도를 넘은 컨테이너 프로세스를 강제 종료했다. 이 경우 V8은 오류를 남길 틈이 없어 원인이 로그에 보이지 않는다. 상한을 768MB로 낮추자 힙이 그 근처에서 더 확보할 수 없게 되는 순간 V8이 JavaScript heap out of memory를 남기고 스스로 종료해, 힙 안 누수라는 증거가 남았다. 그래서 상한은 Buffer 같은 힙 밖 메모리와 코드·스택 몫을 남기도록 컨테이너 한도보다 낮게 잡는다. 반대로 상한을 올리는 것은 OOM 시점을 늦출 뿐 누수를 고치지 못하고, heapUsed는 평평한데 rss만 느는 힙 밖 누수에는 이 옵션이 걸리지 않는다는 점도 구분한다.');

-- =====================================================
-- Lesson 873: Node.js 메모리 누수 진단: 오래 사는 객체에 매달린 참조와 도구 고르기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5417, 873, '아래 코드와 경고 로그를 근거로 한 판단으로 옳은 것은?', '시세 알림 서버에서 WebSocket 연결이 하나 들어올 때마다 아래 코드가 실행된다. `priceFeed`는 프로세스 전체가 함께 쓰는 `EventEmitter` 인스턴스 하나다.

```javascript
wss.on("connection", (ws) => {
  priceFeed.on("tick", (quote) => ws.send(JSON.stringify(quote)));
  ws.on("close", () => metrics.decrement("clients"));
});
```

배포 후 하루 동안 동시 접속자 수는 3~6명 사이를 오갔는데, 로그에 아래 경고가 남았다.

```
(node:3187) MaxListenersExceededWarning: Possible EventEmitter memory leak detected. 11 tick listeners added to [EventEmitter]. Use emitter.setMaxListeners() to increase limit
```', 'OBJECTIVE'),
       (5418, 873, '아래 서비스의 메모리 동작에 대한 설명으로 옳은 것은?', 'NestJS 애플리케이션에 스코프 옵션 없이 `@Injectable()`만 붙여 등록한 `AuditService`가 있다. 이 서비스는 `private recent: Request[] = []` 필드를 두고 있고, 컨트롤러는 요청을 받을 때마다 `auditService.record(req)`를 호출해 요청 객체 `req`를 `recent`에 `push`한다. `recent`를 비우거나 항목을 지우는 코드는 어디에도 없다.', 'OBJECTIVE'),
       (5419, 873, '아래 조사 기록 중 확인하려는 것에 맞지 않는 방법을 고른 사례는?', '메모리 누수가 의심되는 Node.js 서버를 네 사람이 나눠 조사하며 남긴 기록이다.

| 사례 | 확인하려는 것 | 고른 방법 |
| --- | --- | --- |
| A | 트래픽을 흘리는 동안 `heapUsed`와 `rss`가 어떻게 변하는지 | `process.memoryUsage()` 값을 1분마다 메트릭으로 수집 |
| B | 요청 1,000회 사이에 어떤 생성자의 인스턴스가 몇 개 늘었는지 | 워밍업을 마친 뒤 요청 1,000회 전후로 강제 GC를 하고 스냅샷 두 장을 찍어 Comparison 뷰의 # Delta 확인 |
| C | 무거운 수집(Mark-Sweep)을 마친 직후에도 힙이 줄지 않는지 | `--trace-gc`를 붙여 실행하고 수집 전후 힙 크기 로그를 확인 |
| D | 요청 수만큼 늘어난 `SessionData`를 지금 어떤 객체가 붙잡고 있는지 | `--heap-prof`를 붙여 실행하고 할당 위치별 프로파일을 확인 |', 'OBJECTIVE'),
       (5420, 873, '아래 코드로 요청 10,000건을 처리한 뒤의 메모리 상태로 옳은 것은?', '누수가 발견된 핸들러를 아래처럼 고쳐 배포했다. `render`와 `report`는 인자를 어디에도 저장하지 않는다.

```javascript
function handle(req, res) {
  const big = fs.readFileSync("template.html");   // 약 5MB
  res.end(render(big));
  scheduleReport({ path: req.url });              // 반환값은 받지 않는다
}

function scheduleReport(stats) {
  const t = setInterval(() => report(stats), 60_000);
  return () => clearInterval(t);
}
```', 'OBJECTIVE'),
       (5421, 873, '아래 코드의 ㉠에 들어갈 JavaScript 내장 클래스의 이름은?', '썸네일 캐시를 아래처럼 바꿨다. `decode`는 인자를 어디에도 저장하지 않는다.

```javascript
const thumbs = new Map();   // 파일 경로 문자열 → ㉠ 인스턴스

function getThumb(path) {
  const cached = thumbs.get(path)?.deref();
  if (cached) return cached;

  const img = decode(fs.readFileSync(path));   // 약 2MB
  thumbs.set(path, new ㉠(img));
  return img;
}
```

같은 경로를 짧은 간격으로 다시 요청하면 `cached`에 이전 이미지가 그대로 돌아왔다. 그런데 몇 분 뒤 GC가 돈 다음에는, 그사이 어떤 요청도 이미지를 들고 있지 않던 경로에서 `cached`가 `undefined`로 나와 이미지를 다시 디코드했다. `thumbs`에서 항목을 지우는 코드는 없다.', 'SUBJECTIVE'),
       (5422, 873, '아래 표에서 ㉠으로 가린 컬럼의 이름은?', '누수가 의심되는 서버의 힙 스냅샷 Summary 뷰에서 `UserSession` 생성자를 펼쳤다. 아래는 인스턴스 일부이며, 한 컬럼의 이름을 ㉠으로 가렸다.

| 인스턴스 | ㉠ | Shallow Size | Retained Size |
| --- | --- | --- | --- |
| UserSession @51207 | 4 | 96B | 38KB |
| UserSession @51933 | 4 | 96B | 41KB |
| UserSession @77410 | 13 | 96B | 39KB |

@51207의 Retainers를 펼치자 `Map`, 모듈 스코프 컨텍스트, 모듈 객체를 차례로 지나 곧바로 `(GC roots)`가 나왔다. @77410은 처리 중인 요청의 `res`, 소켓, 내부 핸들 목록 등 열 개 넘는 객체를 거친 뒤에야 `(GC roots)`에 닿았다. 팀은 ㉠ 값이 작은 인스턴스부터 조사해 모듈 스코프에 매달린 `sessions` Map을 찾아냈다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5417
(14619, 5417, '경고의 11은 동시 접속자 수이므로, 접속이 잠시 몰린 순간에 나온 경고일 뿐 누수의 신호는 아니다.', '11은 접속자 수가 아니라 priceFeed의 tick 이벤트에 붙은 리스너 수다. 동시 접속자가 6명을 넘은 적이 없는데 리스너가 11개라면, 끊긴 연결의 리스너가 떼어지지 않고 남아 있다는 뜻이다.', false),
(14620, 5417, '리스너가 11개째 붙는 순간 Node.js가 가장 오래된 리스너를 떼어 내, 붙어 있는 수는 10개로 유지된다.', '한도는 경고를 띄우는 기준일 뿐, 리스너를 거부하거나 떼어 내지 않는다. 경고가 나온 뒤에도 연결이 들어올 때마다 리스너는 계속 하나씩 늘어난다.', false),
(14621, 5417, '끊긴 연결의 리스너가 클로저로 ws를 붙잡고 있어, 이미 떠난 클라이언트의 소켓 객체도 회수되지 않고 남는다.', 'priceFeed는 프로세스 내내 살아 있고, 등록된 리스너는 클로저로 ws를 참조한다. close 핸들러가 리스너를 떼지 않으니 떠난 연결마다 ws와 그에 딸린 객체가 GC 루트에서 도달 가능한 채 남는다.', true),
(14622, 5417, 'priceFeed.setMaxListeners(0)으로 한도를 없애면 경고와 함께 그동안 쌓인 리스너도 정리된다.', 'setMaxListeners는 경고를 띄우는 기준만 바꾼다. 0으로 한도를 없애면 누수의 가장 이른 신호만 사라지고 리스너는 그대로 쌓인다. close에서 on에 넘긴 것과 같은 함수를 off로 떼어 내야 한다.', false),

-- 문제 5418
(14623, 5418, '모든 요청이 인스턴스 하나를 함께 쓰고 그 인스턴스가 프로세스와 수명을 같이해, recent에 들어간 req가 하나도 회수되지 않는다.', '스코프 옵션이 없으면 DEFAULT 스코프라 애플리케이션 전체에서 인스턴스가 하나만 만들어진다. 오래 사는 인스턴스의 필드가 짧게 살 요청 객체를 붙잡는, 모듈 스코프 컬렉션과 같은 구조의 누수다.', true),
(14624, 5418, '요청이 끝나면 그 요청에 쓰인 서비스 인스턴스도 폐기되므로, recent는 요청마다 빈 배열에서 다시 시작한다.', '요청마다 인스턴스를 새로 만드는 것은 REQUEST 스코프다. 스코프 옵션이 없으면 인스턴스와 recent는 하나뿐이며, 요청이 끝나도 비워지지 않고 계속 커진다.', false),
(14625, 5418, 'recent는 private이라 클래스 밖에서 접근할 수 없으므로, GC는 배열에 담긴 req를 회수 대상으로 본다.', 'GC는 접근 제어자가 아니라 GC 루트에서 참조를 따라 닿을 수 있는지를 본다. private 필드라도 살아 있는 인스턴스가 가리키는 한 그 안의 req는 도달 가능해 회수되지 않는다.', false),
(14626, 5418, '배열에는 req의 복사본이 아니라 참조만 담기므로, 늘어나는 메모리는 참조 크기인 수 바이트씩에 그친다.', '참조 하나는 작아도 그 참조가 req 전체를 살려 둔다. req가 가리키는 헤더, 파싱된 본문, 소켓까지 남으므로 누수 크기는 Shallow Size가 아니라 Retained Size로 봐야 한다.', false),

-- 문제 5419
(14627, 5419, '사례 A', '시간에 따른 heapUsed와 rss 추이를 모으는 것은 누수 여부를 가리는 첫 단계로 알맞다. 두 값을 함께 보면 늘어나는 곳이 힙 안인지 Buffer 같은 힙 밖인지도 나눠 볼 수 있다.', false),
(14628, 5419, '사례 B', 'Comparison 뷰는 두 스냅샷 사이의 # New, # Deleted, # Delta를 생성자별로 보여 준다. 워밍업을 뺀 구간에서 Delta가 요청 수에 비례하는 생성자를 찾는 데 알맞은 방법이다.', false),
(14629, 5419, '사례 C', '--trace-gc는 수집이 일어난 시점과 종류, 수집 전후 힙 크기를 로그로 남긴다. 무거운 수집을 마친 뒤에도 남는 양이 회차마다 커지는지 확인하는 데 알맞다.', false),
(14630, 5419, '사례 D', '--heap-prof는 어느 코드에서 할당이 많았는지를 보여 줄 뿐, 지금 누가 그 객체를 참조하는지는 알려 주지 않는다. 붙잡고 있는 쪽은 힙 스냅샷에서 인스턴스를 골라 Retainers를 루트 방향으로 따라가야 한다.', true),

-- 문제 5420
(14631, 5420, 'big을 읽은 스코프에서 타이머를 만들지 않으므로, 응답이 끝나면 요청마다 남는 객체 없이 모두 회수된다.', 'big이 콜백의 스코프에서 빠진 것은 맞지만 타이머는 여전히 등록된다. clearInterval을 부를 함수를 아무도 받지 않아, 요청마다 타이머와 콜백, stats가 GC 루트에 매달린 채 남는다.', false),
(14632, 5420, 'big은 회수되지만 해제되지 않은 타이머가 요청마다 하나씩 남아, 타이머 10,000개와 각각의 stats가 계속 살아 있다.', '콜백은 scheduleReport 안에서 만들어져 stats만 붙잡으므로 big은 응답 뒤 회수된다. 하지만 정리 함수를 버렸으니 setInterval이 해제되지 않고, 타이머 10,000개가 1분마다 실행되며 stats를 붙잡는다.', true),
(14633, 5420, '타이머 콜백이 handle의 스코프를 함께 붙잡으므로, 요청마다 big 5MB가 회수되지 않고 쌓인다.', '고치기 전 코드와 혼동한 것이다. 콜백은 scheduleReport의 스코프(stats, t)에서 만들어져 handle의 컨텍스트를 공유하지 않는다. 그래서 big은 응답을 보낸 뒤 회수된다.', false),
(14634, 5420, 'scheduleReport가 반환되면 지역 변수 t가 사라지므로, 타이머는 다음 GC 때 함께 해제된다.', 't는 타이머를 가리키는 변수일 뿐 타이머의 수명을 정하지 않는다. 활성 타이머는 clearInterval로 해제될 때까지 GC 루트에서 도달 가능하므로, 변수가 사라져도 1분마다 계속 실행된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1762, 5421, 'WeakRef,Weak Ref,WeakRef 클래스,new WeakRef,위크레프,위크 레프,위크렙,위크 렙', 'deref()로 대상을 꺼내고, 대상이 이미 회수됐으면 undefined를 돌려주는 내장 클래스가 WeakRef다. WeakRef는 대상을 약하게 참조하므로 다른 곳에 강한 참조가 없으면 GC가 대상을 회수할 수 있다. 그래서 GC가 돌기 전에는 캐시가 맞다가, 아무도 이미지를 들고 있지 않은 채 GC가 돌고 나면 비는 장면이 나온다. WeakMap과 구분해야 한다. WeakMap은 문자열을 키로 받을 수 없고, 값이 아니라 키가 회수될 때 항목이 사라지는 구조라 경로 문자열을 키로 쓰는 이 캐시에는 맞지 않는다. FinalizationRegistry는 객체가 회수될 때 콜백을 받는 도구로 값을 꺼내는 deref()가 없고, 콜백이 언제 실행될지도 보장되지 않는다. 다만 이 코드에서도 thumbs의 항목(경로 문자열과 빈 WeakRef)은 지우지 않는 한 계속 남으므로, 약한 참조가 상한 없는 캐시의 면죄부는 아니다. 일반 캐시에는 여전히 LRU·TTL로 상한을 둔다.'),
       (1763, 5422, 'Distance,디스턴스,Distance 컬럼,거리,참조 거리,루트 거리,루트까지의 거리,GC 루트 거리,GC 루트로부터의 거리', 'Distance는 GC 루트에서 그 객체까지 참조를 따라가는 가장 짧은 경로의 길이다. @51207처럼 값이 4인 인스턴스는 Map, 모듈 스코프 컨텍스트, 모듈 객체만 지나 루트에 닿으므로 전역이나 모듈 스코프에 가깝게 매달려 있을 가능성이 높다. 모듈 스코프 변수는 모듈 캐시 때문에 프로세스가 살아 있는 한 도달 가능하므로, 이런 인스턴스가 먼저 볼 누수 후보가 된다. 반면 @77410처럼 값이 큰 쪽은 처리 중인 요청을 거쳐 붙잡혀 있어 요청이 끝나면 풀릴 수 있다. Distance는 거리 정보일 뿐 크기 정보가 아니다. 객체 자체의 크기는 Shallow Size, 그 객체가 사라질 때 함께 회수될 총량은 Retained Size로 보며, Distance가 작다고 곧 누수인 것도 아니어서 요청 수에 비례해 늘어나는지(Comparison 뷰의 Delta)와 함께 판단한다.');
