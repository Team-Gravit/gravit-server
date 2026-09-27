-- Unit: 스트림과 백프레셔 (Unit ID: 127)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (553, 127, '변환 스트림과 백프레셔 흐름 제어'),
       (711, 127, '청크 경계와 에러 전파, 버퍼 크기 튜닝'),
       (869, 127, '일시정지 모드와 drain·Duplex');

-- =====================================================
-- Lesson 553: 변환 스트림과 백프레셔 흐름 제어
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3497, 553, '아래 스트림 종류에 대한 설명으로 옳은 것은?', 'gzip 압축, CSV 파싱, 암호화처럼 상류에서 받은 청크를 가공해 하류로 내보내는 스트림이 있다. Node.js의 zlib.createGzip()이 이 종류에 속한다.', 'OBJECTIVE'),
       (3498, 553, '아래 코드를 실행할 때 나타나는 결과로 옳은 것은?', '2GB 동영상 파일을 HTTP 응답(res)으로 내보내는 핸들러다.

```javascript
// 디스크 읽기 약 500MB/s, 클라이언트 회선 약 2MB/s
const src = fs.createReadStream(''movie.mp4'');

src.on(''data'', (chunk) => {
  res.write(chunk);        // 반환값을 쓰지 않는다
});
src.on(''end'', () => res.end());
```', 'OBJECTIVE'),
       (3499, 553, '아래 비교표를 바탕으로 옳지 않은 것은?', '스트림 두 개 이상을 이어 붙이는 두 가지 방식을 비교한 표다.

| 항목 | A 방식 | B 방식 |
| --- | --- | --- |
| 백프레셔 | 자동 처리 | 자동 처리 |
| 중간 단계 에러 | 하류로 전파되지 않아 스트림마다 핸들러가 필요 | 이어 붙인 스트림을 모두 destroy하고 콜백·Promise로 전달 |
| 에러 발생 뒤 리소스 | 상류 스트림이 열린 채 남을 수 있음 | 파일 디스크립터·소켓을 자동 정리 |
| Promise 형태 | 없음 | node:stream/promises로 제공 |', 'OBJECTIVE'),
       (3500, 553, '아래 조건에서 스트림 내부 버퍼가 차지하는 메모리 총량은?', 'Node.js 22로 돌아가는 서버가 동시에 1,200개 요청을 처리한다. 요청마다 기본 옵션으로 fs.createReadStream을 하나씩 열고, 각 스트림의 내부 버퍼는 기준선까지 가득 찬 상태로 본다. 바이트 스트림의 highWaterMark 기본값은 Node.js 20에서 16KiB, Node.js 22에서 64KiB다.', 'OBJECTIVE'),
       (3501, 553, '아래 2)의 pipeline()이 대신 처리해 준 흐름 제어 메커니즘의 이름은?', '관측 데이터 3,000만 행을 읽어 gzip으로 압축한 뒤 원격 스토리지로 올리는 배치가 있다. 읽기 단계는 초당 40만 행을 뽑아내지만 압축·업로드 단계는 초당 3만 행을 소화한다.

```javascript
// 1) rows.on(''data'', (r) => gzipUpload.write(r));
//    → 프로세스 메모리(RSS)가 3.4GB까지 올라 OOM으로 종료
// 2) await pipeline(rows, gzip, upload);
//    → RSS 120MB 아래로 유지되고 정상 종료
```

두 코드가 읽는 데이터도, 올리는 대상도 같다.', 'SUBJECTIVE'),
       (3502, 553, '아래 오류를 없앤 스트림 생성 옵션의 이름은?', '주문 레코드 배열을 스트림으로 흘려 DB에 넣으려고 아래처럼 짰더니 첫 청크에서 바로 멈췄다.

```
const src = Readable.from(orders);   // orders: JS 객체 배열
src.pipe(new Transform({ transform(c, e, cb) { cb(null, c.id); } }));

TypeError [ERR_INVALID_ARG_TYPE]: The "chunk" argument must be of type
string or an instance of Buffer. Received an instance of Object
```

Transform을 만들 때 옵션 하나를 true로 켜자 오류가 사라졌고, 내부 버퍼 기준선도 64KiB에서 16으로 바뀌었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3497
(9499, 3497, '상류에서 청크를 받지 않고 원천에서 데이터를 만들어 내보내기만 하므로 파이프 체인의 맨 앞에만 놓을 수 있다.', 'Readable의 성질을 갖다 붙인 오개념. 이 종류는 상류에서 받은 청크를 가공하는 것이 일이라 체인 중간에 놓인다. 체인의 맨 앞은 fs.createReadStream 같은 Readable이 맡는다.', false),
(9500, 3497, '읽기 방향과 쓰기 방향이 서로 독립적이어서, 받아들인 데이터와 내보내는 데이터 사이에 아무 관계가 없다.', 'TCP 소켓 같은 Duplex의 성질을 갖다 붙인 오개념. 이 종류도 Duplex를 상속하지만 출력 청크가 입력 청크를 가공한 결과라는 점에서 두 방향이 묶여 있다.', false),
(9501, 3497, '데이터를 소비하기만 해서 write()와 end()로만 다루며, 다음 스트림으로 pipe()할 출력이 없다.', 'Writable의 성질을 갖다 붙인 오개념. 이 종류는 읽기 인터페이스도 함께 갖고 있어 가공 결과를 다시 pipe()로 다음 단계에 넘길 수 있다.', false),
(9502, 3497, '_transform에 넘어온 callback을 호출하기 전까지 다음 청크가 들어오지 않아 그 자체로 백프레셔에 참여한다.', '가공이 끝났다는 신호가 곧 callback이라, 가공 로직이 느리면 상류 읽기가 자연히 멈춘다. Transform을 중간에 끼워도 파이프라인 전체의 흐름 제어가 끊기지 않는 이유다.', true),

-- 문제 3498
(9503, 3498, 'res의 내부 버퍼에 청크가 계속 쌓여, 프로세스 메모리 사용량이 파일 크기에 가깝게 늘어난다.', 'data 리스너를 붙인 순간 src는 flowing 모드가 되어 디스크 속도로 청크를 밀어낸다. res는 초당 2MB만 비우므로 그 차이가 고스란히 res의 내부 버퍼에 남는다.', true),
(9504, 3498, 'res.write()가 버퍼 기준선을 넘는 순간 예외를 던져 요청이 그 자리에서 끊긴다.', '기준선을 넘어도 write()는 false를 돌려줄 뿐 오류를 내지 않는다. 조용히 쌓이기만 해서 오히려 문제를 늦게 발견하게 된다.', false),
(9505, 3498, 'data 리스너만 붙였으므로 src는 paused 모드에 머물러, 메모리가 highWaterMark 수준에서 고정된다.', 'paused는 소비자가 read()로 직접 꺼내 갈 때의 기본 모드다. data 리스너 등록은 flowing 모드로 넘어가는 대표적인 방아쇠라 읽기가 멈추지 않는다.', false),
(9506, 3498, 'res.write()가 false를 반환하면 src가 자동으로 pause되고 drain 뒤에 읽기를 다시 시작한다.', 'pause와 drain을 자동으로 이어 주는 것은 pipe()와 pipeline()이다. write()를 직접 호출하는 코드에서는 반환값을 확인해 멈추는 일을 손으로 해야 한다.', false),

-- 문제 3499
(9507, 3499, 'A 방식도 소비자가 느리면 상류 읽기를 멈춰 주므로, 메모리 폭증만 놓고 보면 B 방식과 차이가 없다.', '표 첫 행대로 두 방식 모두 백프레셔를 자동 처리한다. A 방식의 약점은 흐름 제어가 아니라 에러 전파와 리소스 정리 쪽에 있으므로 참인 진술이다.', false),
(9508, 3499, 'A 방식은 백프레셔를 처리하지 않으므로 소비자가 느리면 write() 반환값을 확인해 직접 멈춰야 한다.', '표 첫 행이 A 방식도 백프레셔를 자동 처리한다고 밝히고 있어 거짓이다. 반환값을 손으로 확인해야 하는 쪽은 두 방식을 쓰지 않고 write()를 직접 호출하는 코드다.', true),
(9509, 3499, 'gzip 단계에서 에러가 난 A 방식 코드는 원천 파일이 열린 채 남아, 요청이 쌓일수록 파일 디스크립터가 모자랄 수 있다.', '표 셋째 행대로 A 방식은 에러 뒤 상류를 정리하지 않는다. 회수되지 않은 디스크립터가 쌓이면 결국 새 파일을 열지 못하는 상태에 이르므로 참이다.', false),
(9510, 3499, 'B 방식은 Promise 형태를 쓰면 어느 단계에서 난 에러든 try/catch 한 곳에서 받을 수 있다.', '표 넷째 행의 node:stream/promises 버전은 실패를 거부된 Promise로 돌려준다. 실패가 한 곳으로 모이니 단계마다 핸들러를 달 필요가 없어 참이다.', false),

-- 문제 3500
(9511, 3500, '64KiB', 'highWaterMark가 프로세스 전체에 한 번만 적용된다고 본 오해. 기준선은 스트림 하나마다 따로 잡히므로 동시에 열린 스트림 수를 곱해야 한다.', false),
(9512, 3500, '18.75MiB', 'Node.js 20 기본값 16KiB로 계산한 값(1,200 × 16KiB = 19,200KiB). 본문의 실행 환경은 기준선이 64KiB로 올라간 Node.js 22다.', false),
(9513, 3500, '75MiB', '스트림 하나당 64KiB이고 1,200개가 동시에 열려 있으므로 76,800KiB = 75MiB다. 동시 연결 수가 그대로 곱해지니 기준선을 키울 때는 이 곱셈 효과를 함께 봐야 한다.', true),
(9514, 3500, '150MiB', '읽기 스트림 하나가 읽기용·쓰기용 버퍼를 각각 갖는다고 본 오해. fs.createReadStream이 만드는 것은 Readable이라 내부 버퍼가 하나뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1122, 3501, '백프레셔,백 프레셔,backpressure,back pressure,back-pressure,역압', '소비자의 내부 버퍼가 기준선을 넘으면 write()가 false를 돌려주고, 그 신호에 맞춰 생산자를 멈췄다가 drain에서 다시 움직이게 하는 것이 백프레셔다. 1)은 이 신호를 버려서 초당 40만 행과 3만 행의 차이가 통째로 메모리에 쌓였고, pipeline()은 pause와 resume 연동을 대신 해 준다. 같은 흐름 제어라도 TCP 혼잡 제어와는 층이 다르고, highWaterMark는 신호가 발생하는 기준선일 뿐 메커니즘의 이름이 아니다.'),
       (1123, 3502, 'objectMode,object mode,오브젝트 모드,객체 모드', '스트림은 기본적으로 청크를 문자열이나 Buffer로만 받으므로, JS 객체를 그대로 흘리면 ERR_INVALID_ARG_TYPE이 난다. objectMode: true를 켜면 임의의 값 하나가 청크 한 개로 취급되고, highWaterMark도 바이트가 아니라 객체 개수(기본 16개)로 센다. 객체 하나가 크면 16개만으로도 메모리를 많이 쓰므로 기준선을 함께 조정한다. 문자열 해석을 정하는 encoding 옵션이나 버퍼 크기를 정하는 highWaterMark와 혼동하지 않도록 한다.');

-- =====================================================
-- Lesson 711: 청크 경계와 에러 전파, 버퍼 크기 튜닝
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4445, 711, '아래 실행 결과에서 bad가 생긴 원인으로 옳은 것은?', 'JSON Lines 파일(한 줄에 JSON 객체 하나)을 읽어 형식이 맞는 줄과 깨진 줄을 세는 코드와 실행 결과다.

```javascript
const src = fs.createReadStream(process.argv[2], { encoding: ''utf8'' });
let ok = 0, bad = 0;

src.on(''data'', (chunk) => {
  for (const line of chunk.split(''\n'')) {
    if (!line) continue;
    try { JSON.parse(line); ok++; } catch { bad++; }
  }
});
src.on(''end'', () => console.log({ ok, bad }));
```

```
$ node count.js small.jsonl    # 40줄, 3KiB
{ ok: 40, bad: 0 }
$ node count.js big.jsonl      # 8,000,000줄, 800MiB
{ ok: 7987323, bad: 25354 }
```

big.jsonl을 별도 검증 도구로 한 줄씩 검사하면 형식이 깨진 줄은 하나도 없다.', 'OBJECTIVE'),
       (4446, 711, '아래 두 코드 A·B의 동작을 비교한 설명으로 옳은 것은?', 'CSV 파일 100만 행을 행 객체로 하나씩 내보내는 objectMode Readable `rows`를 DB에 넣는 두 코드다. `rows`는 초당 약 20만 행을 만들어 낼 수 있고, `db.insert()`는 한 건에 약 5ms가 걸린다.

```javascript
// 코드 A
rows.on(''data'', async (row) => {
  await db.insert(row);
});
rows.on(''end'', () => console.log(''done''));

// 코드 B
for await (const row of rows) {
  await db.insert(row);
}
console.log(''done'');
```', 'OBJECTIVE'),
       (4447, 711, '아래 부하 테스트 결과를 바르게 해석한 것은?', '같은 서버에서 500MiB 파일을 내려주는 두 핸들러를 부하 테스트했다.

```javascript
// 핸들러 A
const buf = await fs.promises.readFile(''big.bin'');
res.end(buf);

// 핸들러 B
await pipeline(fs.createReadStream(''big.bin''), res);
```

| 지표 | A | B |
| --- | --- | --- |
| 요청 1건, 첫 바이트까지 걸린 시간 | 1.9초 | 3ms |
| 요청 1건, 프로세스 메모리 증가량 | 약 500MiB | 약 1MiB |
| 동시 요청 8건, 프로세스 메모리 증가량 | 약 4GiB | 약 8MiB |

테스트 클라이언트는 서버와 같은 데이터센터 안에 있어 회선이 빠르다.', 'OBJECTIVE'),
       (4448, 711, '아래 상황에서 서버에 일어나는 일로 옳은 것은?', '요청 경로에 맞는 파일을 내려주는 서버다. 아래 코드 밖에 에러를 처리하는 코드는 따로 없다.

```javascript
const http = require(''node:http'');
const fs = require(''node:fs'');

http.createServer((req, res) => {
  const file = resolvePath(req.url);   // 요청 경로를 디스크 경로로 바꾼다
  fs.createReadStream(file).pipe(res);
}).listen(3000);
```

사용자 수십 명이 큰 파일을 내려받는 도중, 한 사용자가 오타가 난 경로로 요청을 보내 존재하지 않는 파일을 열게 됐다.', 'OBJECTIVE'),
       (4449, 711, '아래 변경 후 코드의 ㉠에 들어갈 함수의 이름은?', '업로드된 .gz 로그를 풀어 저장하는 작업 코드다. 손상된 파일은 경고만 남기고 건너뛰도록 짰다.

```javascript
// 변경 전
const gunzip = zlib.createGunzip();
gunzip.on(''error'', (err) => log.warn(''손상 파일 건너뜀'', srcPath, err.code));
fs.createReadStream(srcPath).pipe(gunzip).pipe(fs.createWriteStream(destPath));
```

손상 파일이 섞여 들어온 날의 모니터링 기록이다.

```
09:00  open fds=212    손상 파일 경고=0건
12:00  open fds=1,846  손상 파일 경고=817건
15:20  Error: EMFILE: too many open files, open ''/data/out/app-0914-1520.log''
```

변경 전 코드를 아래처럼 바꾸자, 같은 양의 손상 파일이 들어와도 open fds가 200대에 머물렀고 손상 파일은 catch 블록에서 한 건씩 기록됐다.

```javascript
// 변경 후
try {
  await ㉠(fs.createReadStream(srcPath), zlib.createGunzip(), fs.createWriteStream(destPath));
} catch (err) {
  log.warn(''손상 파일 건너뜀'', srcPath, err.code);
}
```', 'SUBJECTIVE'),
       (4450, 711, '아래 측정에서 값을 바꿔 가며 조정한 스트림 옵션의 이름은?', '10GiB 백업 파일을 다른 디스크로 복사하는 스크립트에서, `fs.createReadStream()`에 넘기는 옵션 하나의 값만 바꿔 가며 측정한 결과다.

| 옵션 값 | read 시스템 콜 횟수 | 복사 시간 |
| --- | --- | --- |
| 16KiB | 약 655,000회 | 71초 |
| 64KiB (기본값) | 약 164,000회 | 58초 |
| 1MiB | 약 10,200회 | 49초 |

가장 빨랐던 1MiB 설정을 동시 다운로드 4,000건을 처리하는 서버에도 그대로 적용하자, 코드는 바꾸지 않았는데 스트림 버퍼만으로 메모리 사용량이 약 3.9GiB 늘었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4445
(12027, 4445, 'highWaterMark가 버퍼의 절대 상한이라, 버퍼에 다 담기지 못한 줄의 뒷부분이 버려진다.', 'highWaterMark를 넘치면 버리는 하드 리밋으로 본 오개념. 기준선에 닿으면 읽기를 잠시 멈출 뿐 데이터는 다음 청크로 이어진다. 실제로 ok에 bad의 절반을 더하면 8,000,000으로 잃어버린 줄이 없다.', false),
(12028, 4445, '청크가 줄바꿈 위치와 상관없이 잘려, 한 줄의 앞뒤 조각이 서로 다른 data 이벤트로 들어온다.', '청크는 버퍼 크기 단위로 잘릴 뿐 줄 경계를 모른다. 경계에 걸린 줄은 두 조각이 되어 둘 다 파싱에 실패하므로 bad가 쪼개진 줄 수(12,677)의 두 배가 된다. 3KiB 파일은 청크 하나에 다 들어가 문제가 없었다. readline 같은 줄 단위 파서로 해결한다.', true),
(12029, 4445, '앞 data 리스너가 끝나기 전에 다음 청크의 리스너가 겹쳐 실행돼, 두 청크의 줄이 뒤섞인다.', '리스너가 동시에 돈다고 본 오개념. JavaScript는 한 스레드에서 돌고 이 리스너는 동기 코드라, 한 청크 처리가 끝나야 다음 data 이벤트가 전달된다. 조각이 생긴 원인은 실행 순서가 아니라 청크를 자르는 위치다.', false),
(12030, 4445, '처리가 느려 백프레셔가 걸리면, 읽기가 멈춘 사이 원천에서 들어온 데이터 일부가 유실된다.', '백프레셔를 데이터를 버리는 장치로 본 오개념. 백프레셔는 원천 읽기를 잠시 멈췄다가 이어 갈 뿐 데이터를 버리지 않는다. 이 코드는 느린 Writable에 쓰지도 않아 백프레셔가 끼어들 자리도 없다.', false),

-- 문제 4446
(12031, 4446, 'A는 리스너가 async 함수라서, 앞 행의 insert가 끝나야 다음 data 이벤트가 발생한다.', 'async 리스너면 기다려 준다고 본 오개념. EventEmitter는 리스너가 돌려준 Promise를 기다리지 않는다. flowing 모드의 rows는 읽는 대로 data를 내보내므로 끝나지 않은 insert가 계속 겹쳐 쌓인다.', false),
(12032, 4446, 'B는 루프를 돌기 전에 100만 행을 먼저 모두 읽어 두므로, 메모리를 A보다 더 쓴다.', 'for await를 다 읽은 뒤 순회하는 방식으로 본 오개념. Readable의 async iterator는 행을 하나씩 꺼내며, 미리 읽어 두는 양도 내부 버퍼 기준선(objectMode 기본 16개) 수준에 그친다.', false),
(12033, 4446, 'B는 백프레셔를 직접 처리하지 않았으므로, 삽입이 느리면 rows의 내부 버퍼가 끝없이 커진다.', 'write() 반환값처럼 손으로 챙겨야 한다고 본 오개념. for await는 루프가 멈춘 동안 다음 행을 요청하지 않으므로, 내부 버퍼가 기준선에 닿으면 원천 읽기가 저절로 멈춘다.', false),
(12034, 4446, 'B는 insert를 기다리는 동안 다음 행을 꺼내지 않아, 읽기가 삽입 속도에 맞춰 느려진다.', '루프 본문의 await가 끝나야 다음 행을 꺼내므로 내부 버퍼가 차면 원천 읽기도 멈춘다. rows가 초당 20만 행을 만들 수 있어도 실제로는 insert 속도인 초당 약 200행에 맞춰 흐른다.', true),

-- 문제 4447
(12035, 4447, 'B는 파일 끝까지 읽기 전에 전송을 시작하므로, 파일이 5GiB로 커져도 첫 바이트까지의 시간은 거의 늘지 않는다.', 'B는 첫 청크를 읽는 즉시 보내므로 첫 바이트 시간이 파일 크기와 상관없다. A는 파일 끝까지 읽어야 res.end()에 닿아 1.9초가 파일 크기에 비례해 늘어나는 것과 대비된다.', true),
(12036, 4447, 'B도 이미 보낸 청크를 메모리에 남겨 두므로, 파일이 5GiB로 커지면 B의 메모리 증가량도 10배 가까이 는다.', '스트림이 보낸 데이터까지 들고 있다고 본 오개념. 청크는 전송되면 버퍼에서 빠지므로 메모리는 파일 크기가 아니라 버퍼 크기 수준에 묶인다. 표에서도 요청 1건에 약 1MiB로 500MiB와 무관하다.', false),
(12037, 4447, 'B의 메모리가 작은 것은 회선이 빨라서이며, 느린 클라이언트가 받으면 B도 파일 크기만큼 메모리를 쓴다.', '회선 속도가 메모리를 정한다고 본 오개념. pipeline()은 백프레셔를 자동 처리해 res 버퍼가 차면 파일 읽기를 멈추고 drain 뒤에 다시 읽는다. 클라이언트가 느리면 전송 시간만 길어진다.', false),
(12038, 4447, 'A는 같은 파일을 읽은 버퍼를 요청들이 나눠 쓰므로, 동시 요청을 32건으로 늘려도 메모리 증가량은 약 4GiB에 머문다.', '같은 파일이면 버퍼 하나를 나눠 쓴다고 본 오개념. 요청 1건에 약 500MiB, 8건에 약 4GiB로 요청 수에 정비례하므로 요청마다 파일 전체를 따로 올린다. 32건이면 약 16GiB가 필요하다.', false),

-- 문제 4448
(12039, 4448, 'pipe()가 원천의 에러를 res로 넘겨, 오타 요청에만 500 응답이 가고 나머지 다운로드는 계속된다.', 'pipe()를 pipeline()처럼 본 오개념. pipe()는 원천 스트림의 에러를 목적지로 넘기지 않고 원천에 에러 리스너를 달지도 않는다. 그래서 ENOENT는 아무도 받지 않는 error 이벤트로 남는다.', false),
(12040, 4448, '열 파일이 없으면 빈 스트림으로 취급되어, 오타 요청에만 본문이 빈 200 응답이 간다.', '파일 열기 실패를 빈 데이터로 본 오개념. fs.createReadStream은 파일을 열지 못하면 end가 아니라 ENOENT 코드를 담은 error 이벤트를 낸다.', false),
(12041, 4448, '받는 리스너가 없는 error 이벤트가 예외로 던져져 프로세스가 종료되고, 다른 다운로드도 함께 끊긴다.', '스트림은 EventEmitter를 상속해, 리스너 없이 error 이벤트가 나면 에러를 그대로 던진다. 이것이 uncaughtException으로 번져 프로세스가 내려가므로 요청 하나의 실수가 서버 전체 장애가 된다. 콜백이나 try/catch를 붙인 pipeline()으로 막는다.', true),
(12042, 4448, '리스너가 없는 이벤트는 무시되므로 에러가 조용히 버려지고, 오타 요청만 응답 없이 멈춰 있다.', '모든 이벤트가 리스너 없으면 무시된다고 본 오개념. 대부분의 이벤트는 그렇지만 error만은 예외라, 리스너가 없으면 EventEmitter가 에러를 던져 버린다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1438, 4449, 'pipeline,pipeline(),stream.pipeline,stream.pipeline(),파이프라인', 'pipeline()은 넘겨받은 스트림 중 하나라도 실패하면 나머지를 모두 destroy해 파일 디스크립터를 닫고, 에러를 거부된 Promise(콜백 버전은 콜백) 하나로 넘긴다. 변경 전 pipe() 체인은 gunzip이 실패해도 앞의 읽기 스트림과 뒤의 쓰기 스트림을 닫지 않아, 손상 파일 1건마다 디스크립터 2개가 남았다(212 + 817 × 2 = 1,846). pipe()도 백프레셔는 자동으로 처리하므로 두 함수의 차이는 흐름 제어가 아니라 에러 전파와 리소스 정리에 있다. 스트림 하나가 끝났거나 실패했는지만 알려 주는 finished()와도 구분한다.'),
       (1439, 4450, 'highWaterMark,high water mark,high-water mark,하이워터마크,하이 워터 마크', 'highWaterMark는 스트림 내부 버퍼가 이 크기에 닿으면 원천에서 더 읽지 않도록 정한 기준선이다. 값을 키우면 read 한 번에 더 많이 가져와 시스템 콜이 줄고 처리량이 오르지만, 스트림 하나가 붙잡는 버퍼도 그만큼 커져 동시 스트림 수를 곱하면 메모리가 크게 늘어난다(4,000 × 1MiB ≈ 3.9GiB). 넘치면 데이터를 버리는 하드 리밋이 아니라 읽기를 잠시 멈추는 기준선이라는 점, 그리고 zlib의 chunkSize나 문자열 해석을 정하는 encoding 옵션과 다르다는 점을 구분한다.');

-- =====================================================
-- Lesson 869: 일시정지 모드와 drain·Duplex
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5393, 869, '아래 코드를 실행했을 때 나타나는 결과로 옳은 것은?', 'Node.js 22에서 5MiB 로그 파일을 읽어 전체 바이트 수를 세는 코드다. DB 연결을 기다리는 약 2초 동안 파일 스트림에는 아무 리스너도 없다.

```javascript
async function main() {
  const src = fs.createReadStream(''access.log'');   // 5,242,880바이트
  let total = 0;

  await db.connect();                               // 약 2초 걸림

  src.on(''data'', (chunk) => { total += chunk.length; });
  src.on(''end'', () => console.log(total));
}
```', 'OBJECTIVE'),
       (5394, 869, '아래 핸들러로 요청을 보냈을 때 클라이언트가 겪는 일로 옳은 것은?', '로그 줄 가운데 ERROR로 시작하는 줄만 골라 내려주는 HTTP 핸들러다. Readable.from()은 배열 원소 하나를 청크 하나로 흘려보낸다.

```javascript
const { Readable, Transform } = require(''node:stream'');
const { pipeline } = require(''node:stream/promises'');

app.get(''/errors'', async (req, res) => {
  const lines = [''ERROR db timeout'', ''INFO retry 1'', ''ERROR db timeout'', ''INFO recovered''];

  const onlyErrors = new Transform({
    transform(chunk, encoding, callback) {
      const line = chunk.toString();
      if (line.startsWith(''ERROR'')) {
        callback(null, line + ''\n'');
      }
    },
  });

  await pipeline(Readable.from(lines), onlyErrors, res);
});
```', 'OBJECTIVE'),
       (5395, 869, '아래 코드를 실행했을 때 출력되는 배열은?', '처리가 끝나지 않는 느린 목적지를 흉내 내려고, write 함수에서 callback을 부르지 않는 Writable을 만들었다.

```javascript
const { Writable } = require(''node:stream'');

const slow = new Writable({
  highWaterMark: 10,                       // 바이트 단위
  write(chunk, encoding, callback) {
    // callback을 부르지 않는다
  },
});

const results = [];
for (let i = 0; i < 5; i++) {
  results.push(slow.write(Buffer.alloc(4)));   // 4바이트 청크
}
console.log(results);
```', 'OBJECTIVE'),
       (5396, 869, '아래 스트림 종류에 대한 설명으로 옳은 것은?', 'HTTP 응답(res)이나 fs.createWriteStream()이 만든 객체처럼, 데이터가 도착하는 목적지 역할을 맡는 스트림이다. 코드는 write()로 청크를 차례로 써 넣고, 더 넣을 데이터가 없으면 end()를 호출한다.', 'OBJECTIVE'),
       (5397, 869, '아래 코드에서 socket 객체가 속한 스트림 종류의 이름은?', '같은 문자열 hello를 두 객체에 써 넣고, 각 객체에서 읽혀 나오는 데이터를 찍었다.

```javascript
const gzip = zlib.createGzip();
gzip.on(''data'', (c) => console.log(''gzip  :'', c));
gzip.end(''hello'');

const socket = net.connect(7000, ''chat.example.com'');
socket.on(''data'', (c) => console.log(''socket:'', c.toString()));
socket.end(''hello'');
```

```
gzip  : <Buffer 1f 8b 08 00 ... >
socket: [공지] 03:00 서버 점검 예정
socket: [알림] 새 메시지 2건
```

gzip에서 나온 바이트를 풀면 hello가 되지만, socket에서 나온 두 메시지는 hello와 상관없이 채팅 서버가 보낸 것이다.', 'SUBJECTIVE'),
       (5398, 869, '아래 코드의 ㉠에 들어갈 이벤트 이름은?', '500만 행짜리 CSV 보고서를 만들면서 곧바로 내려보내는 핸들러다. 변경 전 코드에는 if 블록 없이 res.write(makeRow(i))만 있었다.

```javascript
const { once } = require(''node:events'');

app.get(''/report.csv'', async (req, res) => {
  let waits = 0;
  for (let i = 0; i < 5_000_000; i++) {
    if (!res.write(makeRow(i))) {   // 변경 후 추가한 if 블록
      waits++;
      await once(res, ''㉠'');
    }
  }
  res.end();
  log.info({ waits });
});
```

회선이 느린 클라이언트 한 명이 내려받는 동안 측정한 결과다.

| 버전 | 프로세스 메모리(RSS) | 결과 |
| --- | --- | --- |
| 변경 전 | 60MiB → 2.1GiB | 전송 도중 OOM으로 프로세스 종료 |
| 변경 후 | 60MiB → 70MiB 안팎 | 끝까지 전송, waits = 38,912 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5393
(14555, 5393, '기다리는 2초 동안 읽힌 청크는 받을 리스너가 없어 버려지므로, 찍히는 total은 5,242,880보다 작다.', '새 Readable이 만들어지자마자 흐른다고 본 오개념. 처음에는 paused 모드라 소비자가 없으면 청크를 이벤트로 내보내지 않는다. 리스너 없이 흘러가 사라지는 청크가 없으므로 total이 줄지 않는다.', false),
(14556, 5393, '리스너가 붙기 전까지 스트림은 청크를 내보내지 않고 기다리므로, 붙은 뒤 흘러나온 데이터로 5,242,880이 찍힌다.', '새 Readable은 paused 모드로 시작해 소비자가 나타날 때까지 청크를 내보내지 않는다. data 리스너를 붙이는 순간 flowing 모드로 바뀌어 처음부터 흘러가므로 total은 파일 크기와 같다.', true),
(14557, 5393, 'data 리스너만 붙였을 뿐 read()나 resume()을 부르지 않았으므로 스트림이 흐르지 않아, 아무것도 찍히지 않는다.', '리스너 등록만으로는 흐르지 않는다고 본 오개념. data 리스너 등록은 pipe()·resume()과 함께 flowing 모드로 넘어가는 방아쇠다. read()를 직접 부르는 것은 paused 모드에서 스스로 꺼내 쓸 때의 방식이다.', false),
(14558, 5393, '기다리는 동안 파일 전체가 내부 버퍼로 미리 읽혀, 리스너가 붙는 순간 5MiB짜리 청크 하나로 한꺼번에 들어온다.', '내부 버퍼가 파일을 통째로 담는다고 본 오개념. 버퍼가 기준선(Node.js 22 기본 64KiB)에 닿으면 원천에서 더 읽지 않는다. 리스너가 붙은 뒤에도 청크는 버퍼 크기 단위로 나뉘어 들어온다.', false),

-- 문제 5394
(14559, 5394, '두 ERROR 줄을 받고 응답이 정상 종료된다. callback을 부르지 않은 INFO 줄은 걸러져 버려질 뿐이다.', 'callback을 안 부르면 그 청크만 버려진다고 본 오개념. callback은 이 청크의 처리가 끝났다는 신호라, 부르지 않으면 Transform이 다음 청크를 받지 않는다. 줄을 걸러 내려면 출력 없이 callback()만 불러야 한다.', false),
(14560, 5394, 'callback이 빠진 청크를 만나는 순간 pipeline이 에러로 끝나, 응답이 도중에 끊긴다.', 'callback 누락을 스트림이 알아챈다고 본 오개념. 스트림은 처리가 오래 걸리는 것과 호출을 잊은 것을 구분하지 못한다. 그래서 에러도 시간 초과도 없이 그 자리에서 기다리기만 한다.', false),
(14561, 5394, 'callback을 부르지 않은 INFO 줄은 가공 없이 그대로 통과해, 네 줄을 모두 받고 응답이 끝난다.', 'Transform이 출력을 넘기지 않은 청크를 그대로 흘려보낸다고 본 오개념. 출력은 callback(null, 값)이나 push()로 넘긴 것만 나간다. 게다가 callback이 오지 않아 셋째·넷째 줄은 처리조차 되지 않는다.', false),
(14562, 5394, '첫 ERROR 줄 하나만 받은 뒤로 응답이 끝나지 않고, 연결이 열린 채 계속 기다린다.', '둘째 줄(INFO retry 1)에서 callback이 불리지 않아 Transform이 그 청크를 처리 중인 채로 멈춘다. 뒤의 줄과 끝 신호가 모두 그 뒤에 막혀 res.end()까지 이어지지 않는다. 걸러 낼 줄에도 callback()을 불러야 한다.', true),

-- 문제 5395
(14563, 5395, '[true, true, true, true, true]', '청크 하나(4바이트)가 기준선보다 작으면 늘 true라고 본 오개념. 비교 대상은 청크 한 개가 아니라 처리가 끝나지 않고 쌓인 총량이다. 세 번째 쓰기에서 총량이 12바이트가 되어 기준선 10바이트를 넘는다.', false),
(14564, 5395, '[true, true, true, false, false]', '곧바로 write 함수로 넘어간 첫 청크는 쌓인 양에서 빠진다고 본 오개념. callback이 불리기 전까지는 처리 중인 청크도 총량에 들어가, 4·8·12바이트로 늘면서 세 번째에서 false가 된다.', false),
(14565, 5395, '[true, true, false, false, false]', 'callback이 오지 않아 쌓인 양이 4→8→12→16→20바이트로 늘기만 한다. 기준선 10바이트를 넘는 세 번째부터 false다. false는 그만 보내라는 신호일 뿐 청크를 거부하지 않으므로, 이후에도 받아 쌓고 false를 돌려준다.', true),
(14566, 5395, '[false, false, false, false, false]', 'write()의 반환값을 청크가 실제로 기록됐는지로 본 오개념. 반환값은 쌓인 양이 기준선 아래라 더 보내도 되는지를 알리는 신호다. 처리 완료와 상관없이 총량이 8바이트인 두 번째까지는 true다.', false),

-- 문제 5396
(14567, 5396, 'end()를 부른 뒤 버퍼에 남은 데이터까지 모두 내보내고 나면 finish 이벤트로 완료를 알린다.', 'end()는 더 쓸 것이 없다는 예고일 뿐이라, 버퍼에 남은 데이터를 목적지로 다 내보낸 뒤에야 finish가 온다. 그래서 파일 저장이 끝난 뒤 할 일은 finish 리스너에 둬야 한다.', true),
(14568, 5396, '데이터를 모두 내보내고 나면 end 이벤트로 완료를 알리므로, 저장 뒤 할 일은 end 리스너에 둔다.', 'Readable의 완료 신호를 갖다 붙인 오개념. end 이벤트는 원천에서 더 읽을 데이터가 없을 때 Readable이 낸다. 목적지 역할의 스트림은 end 이벤트를 내지 않으므로 end 리스너의 코드는 끝내 실행되지 않는다.', false),
(14569, 5396, 'data 리스너를 붙이는 순간 흐르기 시작해, 들어온 청크를 이벤트로 다음 단계에 밀어낸다.', 'Readable의 flowing 모드를 갖다 붙인 오개념. data 이벤트로 청크를 내보내는 것은 읽는 쪽 스트림이다. 목적지 역할의 스트림은 청크를 받아들이기만 할 뿐 읽어 갈 출력이 없다.', false),
(14570, 5396, '써 넣은 청크를 가공한 결과를 다시 읽을 수 있게 내보내, pipe()로 다음 단계에 이어 붙인다.', 'Transform의 성질을 갖다 붙인 오개념. 목적지 역할의 스트림은 읽기 인터페이스가 없어 pipe()의 도착점은 될 수 있어도, 다음 단계로 이어 붙일 출발점은 되지 못한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1754, 5397, 'Duplex,Duplex 스트림,Duplex stream,stream.Duplex,듀플렉스,듀플렉스 스트림,이중 스트림,양방향 스트림', 'socket에 써 넣은 hello는 채팅 서버로 나가고, socket에서 읽히는 것은 서버가 따로 보낸 메시지다. 이처럼 읽기·쓰기 인터페이스를 모두 갖되 두 방향이 서로 독립인 스트림이 Duplex이며, TCP 소켓(net.Socket)이 대표적인 예다. 그래서 socket.end()로 쓰기를 닫은 뒤에도 서버가 보내는 데이터는 계속 읽힌다. 같은 양방향이라도 zlib.createGzip()처럼 읽혀 나오는 데이터가 써 넣은 데이터를 가공한 결과라면 Duplex를 상속한 Transform으로 구분한다. 읽기만 하는 Readable, 쓰기만 하는 Writable과도 다르다.'),
       (1755, 5398, 'drain,drain 이벤트,드레인,드레인 이벤트,''drain''', 'res.write()가 false를 돌려주면 쓰기 스트림의 내부 버퍼가 기준선(highWaterMark)을 넘었다는 뜻이고, 버퍼를 다 비워 다시 받을 수 있게 되면 쓰기 스트림이 drain 이벤트를 낸다. false를 받으면 drain까지 기다렸다가 쓰기를 이어 가야 백프레셔가 지켜진다. 변경 전 코드는 반환값을 버린 채 500만 행을 쉬지 않고 밀어 넣어, 느린 회선으로 나가지 못한 데이터가 전부 메모리에 쌓였다. 모든 데이터를 내보낸 뒤 한 번 오는 finish나 스트림이 닫힐 때 오는 close와 헷갈리지 않도록 한다. 이 자리에서 finish를 기다리면 end()를 부르기 전이라 영원히 오지 않는다.');
