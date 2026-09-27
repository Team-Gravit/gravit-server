-- Unit: 이벤트 루프와 논블로킹 I/O (Unit ID: 123)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NODE_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(611, 'NODE_JS', 123, 'HARD', true,
 'Node.js 서버의 요청 핸들러에서 readFileSync로 파일을 읽으면 어떤 문제가 생기나요? 또 비동기 API로 바꾼 뒤에도 동시 파일 읽기 요청이 많을 때 지연이 남는 이유와 대응 방법은 무엇인가요?',
 'Node.js는 JavaScript를 한 개의 메인 스레드에서 실행하기 때문에, 요청 핸들러에서 readFileSync 같은 동기 API를 쓰면 파일을 다 읽을 때까지 이벤트 루프가 막힙니다. 그 동안 다른 요청의 콜백도 실행되지 못하므로 모든 클라이언트가 함께 대기하고, 결과적으로 요청이 직렬화됩니다. 그래서 동기 API는 서버 기동 시점의 설정 로딩에만 허용하고, 요청 처리에서는 fs.promises.readFile 같은 비동기 API로 이벤트 루프를 즉시 반환해야 합니다. 다만 비동기로 바꿔도 파일 시스템 작업(fs.*)은 운영체제가 비동기 API를 제공하지 않아 libuv 스레드 풀에서 실행되는데, 이 스레드 풀은 기본 4개 스레드입니다. 따라서 파일 I/O를 동시에 5개 이상 요청하면 4개가 끝날 때까지 나머지는 대기하고, 4개씩 묶여 완료되는 현상이 나타납니다. 또 dns.lookup, crypto.pbkdf2, zlib 압축도 같은 스레드 풀을 쓰므로, 호스트명 조회가 많으면 스레드 풀 경합으로 파일 I/O까지 느려질 수 있습니다. 대응으로는 UV_THREADPOOL_SIZE 환경 변수로 스레드 풀 크기를 늘릴 수 있는데(최대 1024), 크기는 프로세스 시작 시점에 결정되므로 반드시 스레드 풀이 처음 사용되기 전에 설정해야 합니다.'),
(612, 'NODE_JS', 123, 'NORMAL', true,
 '블로킹 I/O와 논블로킹 I/O의 차이는 무엇이며, Node.js가 논블로킹 I/O를 사용해서 얻는 이점은 무엇인가요?',
 '블로킹 I/O는 파일 읽기나 네트워크 응답이 끝날 때까지 스레드가 멈춰 기다리는 방식입니다. 그래서 동시 요청을 처리하려면 요청마다 스레드를 늘려야 하고, 스레드 생성과 컨텍스트 스위칭 비용이 커집니다. 반면 논블로킹 I/O는 I/O를 운영체제에 요청만 하고 즉시 다음 코드를 실행하며, 완료 여부는 나중에 이벤트, 즉 콜백으로 통지받습니다. 예를 들어 fs.readFileSync는 파일을 다 읽을 때까지 다음 줄이 실행되지 않지만, fs.readFile은 요청만 던지고 바로 다음 줄을 실행합니다. Node.js는 JavaScript 코드를 한 개의 메인 스레드에서 실행하고 I/O 대기는 운영체제와 libuv에 맡겨 메인 스레드가 놀지 않게 하므로, 단일 스레드로도 수만 개의 동시 연결을 처리할 수 있습니다. 즉 적은 스레드로 많은 연결을 처리할 수 있다는 것이 논블로킹 I/O의 이점입니다.'),
(613, 'NODE_JS', 123, 'NORMAL', true,
 'setTimeout(fn, 0)과 setImmediate를 함께 호출하면 어느 콜백이 먼저 실행되나요? 호출 위치에 따라 순서가 달라지는 이유를 이벤트 루프 페이즈로 설명해 주세요.',
 '두 함수는 서로 다른 페이즈에서 실행됩니다. setTimeout 콜백은 timers 페이즈에서, setImmediate 콜백은 check 페이즈에서 실행되므로 어느 위치에서 호출했는가에 따라 순서가 달라집니다. 메인 모듈에서 둘을 호출하면 실행 순서가 실행마다 달라질 수 있는 비결정적 상태입니다. setTimeout(fn, 0)은 내부적으로 1ms로 보정되는데, 루프에 진입하는 시점에 이 1ms 타이머가 만료되었는지가 프로세스 성능에 따라 다르기 때문입니다. 반면 I/O 콜백 안에서 호출하면 항상 setImmediate가 먼저 실행됩니다. I/O 콜백은 poll 페이즈에서 실행되고 poll 바로 다음이 check 페이즈이므로, check 페이즈의 setImmediate가 다음 루프의 timers 페이즈보다 항상 먼저 실행되기 때문입니다.'),
(614, 'NODE_JS', 123, 'EASY', true,
 'Node.js 이벤트 루프를 구성하는 페이즈를 순서대로 말하고, 주요 페이즈에서 어떤 콜백이 실행되는지 설명해 주세요.',
 '이벤트 루프는 timers, pending callbacks, idle/prepare, poll, check, close callbacks의 6개 페이즈를 순서대로 순회하며, 각 페이즈는 자신의 콜백 큐를 비울 때까지 콜백을 실행한 뒤 다음 페이즈로 넘어갑니다. timers 페이즈에서는 지정 시간이 지난 setTimeout·setInterval 콜백이 실행되고, pending callbacks 페이즈에서는 일부 TCP 오류 콜백처럼 이전 루프에서 미뤄진 콜백이 실행됩니다. idle/prepare는 내부용입니다. poll 페이즈에서는 파일, 소켓, DB 응답 같은 I/O 완료 콜백이 실행되며, 큐가 비면 새 I/O 이벤트나 가장 가까운 타이머 만료 시각까지 여기서 대기합니다. check 페이즈에서는 setImmediate 콜백이, close callbacks 페이즈에서는 socket.on(''close'') 같은 ''close'' 이벤트 핸들러가 실행됩니다.'),
(615, 'NODE_JS', 123, 'EASY', true,
 '"Node.js는 싱글 스레드인가요?"라는 질문에 Node.js 런타임 구조를 근거로 답해 주세요.',
 '정확히는 JavaScript 실행은 싱글 스레드이지만 프로세스 전체는 멀티 스레드입니다. JavaScript를 실행하는 V8 엔진은 콜 스택이 하나뿐이어서 한 번에 한 함수만 실행하므로, 애플리케이션 코드는 한 개의 메인 스레드에서 돌아갑니다. 하지만 런타임 아래에는 libuv가 있는데, libuv는 C로 작성된 크로스 플랫폼 비동기 I/O 라이브러리로 이벤트 루프 자체와 스레드 풀(기본 4개)을 제공합니다. 소켓 이벤트는 Linux의 epoll, macOS의 kqueue, Windows의 IOCP 같은 운영체제 비동기 API로 감시하고, 이를 지원하지 않는 파일 시스템 작업 등은 스레드 풀로 우회합니다. 이렇게 libuv 스레드 풀과 V8의 GC 스레드 등이 백그라운드에서 함께 동작하기 때문에 프로세스 전체로 보면 멀티 스레드입니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 611
(3295, 611, 'readFileSync 같은 동기 API가 이벤트 루프를 막아 모든 클라이언트 요청이 함께 대기함을 설명', 'ESSENTIAL', 1),
(3296, 611, '비동기 파일 I/O(fs.*)는 libuv 스레드 풀에서 처리됨을 언급', 'ESSENTIAL', 2),
(3297, 611, '스레드 풀 기본 크기 4개를 넘는 동시 파일 요청은 앞선 작업이 끝날 때까지 대기함을 설명', 'ESSENTIAL', 3),
(3298, 611, 'UV_THREADPOOL_SIZE 환경 변수로 스레드 풀 크기를 늘릴 수 있음을 언급', 'ESSENTIAL', 4),
(3299, 611, 'UV_THREADPOOL_SIZE는 스레드 풀이 처음 사용되기 전에 설정해야 함을 언급', 'SUPPLEMENTARY', 5),
(3300, 611, 'dns.lookup 호출이 많으면 스레드 풀 경합으로 파일 I/O까지 느려질 수 있음을 언급', 'SUPPLEMENTARY', 6),
(3301, 611, '동기 API는 서버 기동 시점의 설정 로딩에만 허용한다는 원칙을 제시', 'SUPPLEMENTARY', 7),

-- 질문 612
(3302, 612, '블로킹 I/O는 I/O가 끝날 때까지 스레드가 멈춰 기다림을 설명', 'ESSENTIAL', 1),
(3303, 612, '논블로킹 I/O는 I/O를 운영체제에 요청만 하고 즉시 다음 코드를 실행함을 설명', 'ESSENTIAL', 2),
(3304, 612, '블로킹 방식은 동시 요청마다 스레드를 늘려야 해 스레드 생성·컨텍스트 스위칭 비용이 커짐을 설명', 'ESSENTIAL', 3),
(3305, 612, 'Node.js는 단일 메인 스레드로 많은 동시 연결을 처리할 수 있음을 언급', 'ESSENTIAL', 4),
(3306, 612, '논블로킹 I/O의 완료 여부는 나중에 이벤트(콜백)로 통지받음을 언급', 'SUPPLEMENTARY', 5),
(3307, 612, 'readFileSync와 readFile을 블로킹·논블로킹 호출의 예로 제시', 'SUPPLEMENTARY', 6),

-- 질문 613
(3308, 613, 'setTimeout 콜백은 timers 페이즈, setImmediate 콜백은 check 페이즈에서 실행됨을 설명', 'ESSENTIAL', 1),
(3309, 613, '메인 모듈에서 호출하면 두 콜백의 실행 순서가 비결정적임을 언급', 'ESSENTIAL', 2),
(3310, 613, 'I/O 콜백 안에서 호출하면 setImmediate가 항상 먼저 실행됨을 언급', 'ESSENTIAL', 3),
(3311, 613, 'I/O 콜백이 poll 페이즈에서 실행되고 바로 다음이 check 페이즈라는 점을 이유로 제시', 'ESSENTIAL', 4),
(3312, 613, 'setTimeout(fn, 0)은 내부적으로 1ms로 보정됨을 언급', 'SUPPLEMENTARY', 5),
(3313, 613, '메인 모듈의 비결정성은 루프 진입 시 1ms 타이머 만료 여부가 성능에 따라 달라서임을 설명', 'SUPPLEMENTARY', 6),

-- 질문 614
(3314, 614, 'timers→pending callbacks→idle/prepare→poll→check→close callbacks 순서를 제시', 'ESSENTIAL', 1),
(3315, 614, 'timers 페이즈에서 setTimeout·setInterval 콜백이 실행됨을 언급', 'ESSENTIAL', 2),
(3316, 614, 'poll 페이즈에서 파일·소켓 등 I/O 완료 콜백이 실행됨을 언급', 'ESSENTIAL', 3),
(3317, 614, 'check 페이즈에서 setImmediate 콜백이 실행됨을 언급', 'SUPPLEMENTARY', 4),
(3318, 614, 'close callbacks 페이즈에서 소켓의 ''close'' 이벤트 핸들러가 실행됨을 언급', 'SUPPLEMENTARY', 5),
(3319, 614, 'poll 큐가 비면 새 I/O 이벤트나 가장 가까운 타이머 만료 시각까지 대기함을 설명', 'SUPPLEMENTARY', 6),

-- 질문 615
(3320, 615, 'JavaScript 실행은 싱글 스레드이지만 프로세스 전체는 멀티 스레드임을 명시', 'ESSENTIAL', 1),
(3321, 615, 'V8은 콜 스택이 하나뿐이라 한 번에 한 함수만 실행함을 설명', 'ESSENTIAL', 2),
(3322, 615, 'libuv 스레드 풀·V8 GC 스레드 중 최소 1개를 백그라운드 스레드의 예로 제시', 'ESSENTIAL', 3),
(3323, 615, 'libuv가 이벤트 루프와 스레드 풀을 제공하는 비동기 I/O 라이브러리임을 언급', 'SUPPLEMENTARY', 4),
(3324, 615, 'epoll·kqueue·IOCP 중 최소 1개를 소켓 이벤트 감시용 운영체제 비동기 API로 제시', 'SUPPLEMENTARY', 5);
