-- Unit: 스트림과 백프레셔 (Unit ID: 127)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NODE_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(631, 'NODE_JS', 127, 'HARD', true,
 '대용량 파일을 HTTP로 내려줄 때 스트림의 ''data'' 이벤트 안에서 res.write()를 호출하도록 구현했는데 서버 메모리가 계속 늘어납니다. 원인은 무엇이고 어떻게 고쳐야 하나요?',
 '원인은 백프레셔를 처리하지 않은 것입니다. 디스크 읽기는 수백 MB/s로 빠르고 네트워크 전송은 수 MB/s로 느리기 때문에, 생산자인 Readable이 소비자인 res보다 훨씬 빠르게 데이터를 밀어 넣습니다. ''data'' 리스너를 등록하면 flowing 모드가 되어 소비자가 느려도 데이터를 계속 방출하는데, res.write()의 반환값을 무시하면 오류는 나지 않지만 쓰이지 못한 데이터가 내부 버퍼에 무한히 쌓여 메모리가 폭증합니다. 결국 스트림을 쓰고도 파일 전체를 메모리에 올린 것과 같아집니다. write()는 내부 버퍼가 highWaterMark를 넘으면 false를 반환하므로, false를 받으면 쓰기를 멈추고 ''drain'' 이벤트가 올 때까지 기다린 뒤 다시 써야 합니다. 실무에서는 이 pause/drain 연동을 직접 짜기보다 pipeline()을 쓰는 것이 표준인데, pipeline()은 백프레셔를 자동으로 처리하고 에러 시 모든 스트림을 정리해 줍니다. 또는 for await로 청크를 소비하면 await가 끝날 때까지 다음 청크를 읽지 않으므로 백프레셔가 자연스럽게 적용됩니다.'),
(632, 'NODE_JS', 127, 'NORMAL', true,
 'readable.pipe()와 stream.pipeline()의 차이는 무엇이고, 실무에서 pipeline()을 권장하는 이유는 무엇인가요?',
 '두 방식 모두 백프레셔는 자동으로 처리한다는 공통점이 있습니다. 차이는 에러 처리와 리소스 정리입니다. pipe()는 에러가 전파되지 않아 각 스트림마다 개별 에러 핸들러를 달아야 하고, 체인 중간 스트림에서 에러가 나면 상류 스트림이 열린 채 남아 파일 디스크립터 누수가 생길 수 있습니다. 반면 pipeline()은 어느 스트림에서 에러가 나든 모든 스트림을 파괴(destroy)하고 에러를 콜백에 전달하며, 파일 디스크립터와 소켓도 자동으로 정리합니다. 또 node:stream/promises의 pipeline을 쓰면 Promise 기반으로 await할 수 있어 실패가 예외로 전달됩니다. 이런 이유로 pipe()는 간단한 데모 수준이고 pipeline()이 실무 표준입니다.'),
(633, 'NODE_JS', 127, 'NORMAL', true,
 'Readable 스트림의 paused 모드와 flowing 모드는 어떻게 다른가요?',
 '기본 상태인 paused 모드에서는 소비자가 read()를 호출할 때만 데이터를 내어주고, 내부 버퍼가 highWaterMark에 도달하면 원천에서 더 읽지 않고 대기합니다. flowing 모드는 ''data'' 리스너를 등록하거나 pipe(), resume()을 호출하면 전환되며, 데이터가 도착하는 대로 ''data'' 이벤트로 자동으로 밀어냅니다. flowing 모드는 소비자가 느려도 멈추지 않으므로, 직접 ''data'' 이벤트로 소비할 때는 백프레셔를 직접 처리해야 합니다.'),
(634, 'NODE_JS', 127, 'EASY', true,
 'Node.js에서 스트림이란 무엇이고, 파일 전체를 메모리에 읽어 처리하는 방식 대신 스트림을 쓰는 이유는 무엇인가요?',
 '스트림은 데이터를 한 번에 메모리에 올리지 않고 작은 조각인 청크 단위로 흘려보내며 처리하는 추상화입니다. 파일 전체를 읽는 방식은 파일 끝까지 읽은 뒤에야 처리를 시작하고 메모리 사용량이 데이터 크기에 비례하기 때문에, 2GB 파일을 동시 요청마다 버퍼에 올리면 메모리가 크게 늘어납니다. 반면 스트림은 첫 청크가 도착하는 즉시 처리를 시작해 시간 효율이 좋고, 메모리 사용량이 버퍼 크기 수준으로 고정되어 공간 효율이 좋습니다. HTTP 요청·응답, 소켓, 파일, zlib 등 Node.js의 I/O 객체 대부분이 스트림입니다.'),
(635, 'NODE_JS', 127, 'EASY', true,
 'Node.js 스트림의 네 가지 종류를 들고 각각의 역할을 설명해 주시겠어요?',
 '스트림은 Readable, Writable, Duplex, Transform 네 가지입니다. Readable은 fs.createReadStream이나 HTTP 요청처럼 데이터를 읽어오는 원천이고, Writable은 fs.createWriteStream이나 HTTP 응답처럼 데이터를 써 넣는 목적지입니다. Duplex는 TCP 소켓처럼 읽기와 쓰기가 독립적으로 모두 가능한 스트림이고, Transform은 zlib.createGzip처럼 입력을 변환해 출력하는 Duplex입니다. 모든 스트림은 EventEmitter를 상속하므로 ''data'', ''end'', ''error'', ''finish'' 같은 이벤트로 상태를 알립니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 631
(3403, 631, 'write() 반환값을 무시하면 내부 버퍼가 무한히 자라 메모리가 폭증함을 설명', 'ESSENTIAL', 1),
(3404, 631, '느린 소비자(네트워크)와 빠른 생산자(디스크 읽기) 간 속도 차가 원인임을 설명', 'ESSENTIAL', 2),
(3405, 631, 'write()가 false면 ''drain''까지 대기·pipeline() 사용 중 최소 1개를 해결책으로 제시', 'ESSENTIAL', 3),
(3406, 631, 'write()의 false 반환 기준이 내부 버퍼의 highWaterMark 초과임을 언급', 'SUPPLEMENTARY', 4),
(3407, 631, 'for await로 소비하면 await 동안 읽기가 멈춰 백프레셔가 자동 적용됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 632
(3408, 632, 'pipe()는 에러를 전파하지 않고 pipeline()은 에러를 콜백에 전달한다는 차이를 설명', 'ESSENTIAL', 1),
(3409, 632, 'pipe() 체인에서 에러 시 상류 스트림이 열린 채 남아 파일 디스크립터 누수가 생김을 설명', 'ESSENTIAL', 2),
(3410, 632, 'pipeline()은 에러 시 모든 스트림을 파괴(destroy)해 파일 디스크립터·소켓을 정리함을 언급', 'ESSENTIAL', 3),
(3411, 632, 'pipe()와 pipeline() 모두 백프레셔를 자동 처리한다는 공통점을 언급', 'SUPPLEMENTARY', 4),
(3412, 632, 'stream/promises의 pipeline을 await로 사용할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 633
(3413, 633, 'paused 모드는 소비자가 read()를 호출할 때만 데이터를 내어줌을 설명', 'ESSENTIAL', 1),
(3414, 633, 'flowing 모드는 데이터가 도착하는 대로 ''data'' 이벤트로 밀어냄을 설명', 'ESSENTIAL', 2),
(3415, 633, '''data'' 리스너 등록·pipe()·resume() 중 최소 1개를 flowing 모드 전환 조건으로 제시', 'ESSENTIAL', 3),
(3416, 633, 'flowing 모드는 소비자가 느려도 멈추지 않아 백프레셔를 직접 처리해야 함을 언급', 'SUPPLEMENTARY', 4),
(3417, 633, 'paused 모드에서 내부 버퍼가 highWaterMark에 도달하면 원천에서 더 읽지 않음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 634
(3418, 634, '스트림이 데이터를 한 번에 메모리에 올리지 않고 청크 단위로 흘려보내며 처리함을 설명', 'ESSENTIAL', 1),
(3419, 634, '스트림의 메모리 사용량이 데이터 크기가 아닌 버퍼 크기로 고정됨을 설명', 'ESSENTIAL', 2),
(3420, 634, '첫 청크가 도착하는 즉시 처리를 시작해 처리 시작이 앞당겨짐을 언급', 'ESSENTIAL', 3),
(3421, 634, 'HTTP 요청·응답, 소켓, 파일, zlib 중 최소 2개를 스트림인 I/O 객체로 제시', 'SUPPLEMENTARY', 4),

-- 질문 635
(3422, 635, 'Readable 스트림이 데이터를 읽어오는 원천임을 설명', 'ESSENTIAL', 1),
(3423, 635, 'Writable 스트림이 데이터를 써 넣는 목적지임을 설명', 'ESSENTIAL', 2),
(3424, 635, 'Duplex는 읽기·쓰기가 독립적으로 모두 가능한 스트림임을 설명', 'ESSENTIAL', 3),
(3425, 635, 'Transform은 입력을 변환해 출력하는 Duplex임을 설명', 'ESSENTIAL', 4),
(3426, 635, '모든 스트림이 EventEmitter를 상속해 이벤트로 상태를 알림을 언급', 'SUPPLEMENTARY', 5),
(3427, 635, 'TCP 소켓·zlib.createGzip 중 최소 1개를 Duplex 또는 Transform의 예로 제시', 'SUPPLEMENTARY', 6);
