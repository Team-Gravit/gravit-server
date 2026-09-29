-- Unit: 마이크로태스크와 매크로태스크 (Unit ID: 124)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NODE_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(616, 'NODE_JS', 124, 'HARD', true,
 '큰 작업을 잘게 나눠 처리하면서 다음 반복을 process.nextTick으로 재귀 예약하는 코드가 있다면 어떤 문제가 생기고, 어떻게 개선해야 하는지 설명해 주시겠어요?',
 'process.nextTick으로 자기 자신을 재귀 예약하면 I/O 기아가 발생합니다. 마이크로태스크 큐는 한 번에 하나가 아니라 큐가 완전히 빌 때까지 전부 실행되고, 비우는 도중 새로 추가된 작업도 계속 실행됩니다. 그래서 nextTick으로 계속 자신을 추가하면 큐가 비지 않아 이벤트 루프가 다음 페이즈로 넘어가지 못하고, poll 페이즈에 영원히 도달하지 못해 I/O 콜백과 타이머가 처리되지 않습니다. Promise.resolve().then(spin) 형태의 Promise 재귀도 같은 문제를 일으킵니다. 개선하려면 다음 반복을 setImmediate로 예약해야 합니다. setImmediate는 check 페이즈에서 실행되는 매크로태스크라 다음 루프 순회에서 재개되므로, 매 반복마다 poll 페이즈를 거치며 그 사이에 I/O 콜백이 실행됩니다. 즉 큰 배열을 나눠 처리하는 청크 처리처럼 긴 작업을 잘게 나눠 I/O에 양보해야 할 때는 setImmediate를 사용해야 합니다.',
 'interview-question/616.mp3'),
(617, 'NODE_JS', 124, 'NORMAL', true,
 'process.nextTick, Promise.then, setImmediate는 각각 언제 실행되며 어떤 차이가 있나요?',
 'process.nextTick과 Promise.then은 마이크로태스크이고, setImmediate는 매크로태스크입니다. 콜 스택이 비면 nextTick 큐를 먼저 전부 비우고, 그다음 Promise 큐를 비운 뒤에야 매크로태스크가 실행되므로 실행 순서는 nextTick → Promise → setImmediate입니다. setImmediate는 이름과 달리 즉시 실행되는 것이 아니라 poll 페이즈 이후 check 페이즈에서 실행되어 세 API 중 가장 늦고, 반대로 nextTick은 현재 작업이 끝나자마자 가장 먼저 실행됩니다. 또 setImmediate는 I/O에 양보하지만 nextTick과 Promise는 양보하지 않습니다. 표준 여부도 달라서 process.nextTick과 setImmediate는 Node.js 고유 API이고 Promise는 ECMAScript 표준입니다.',
 'interview-question/617.mp3'),
(618, 'NODE_JS', 124, 'NORMAL', true,
 'Node.js에서 매크로태스크와 마이크로태스크는 실행 시점과 실행 방식에서 어떤 차이가 있나요?',
 '매크로태스크는 setTimeout, setInterval, setImmediate, I/O 콜백 같은 작업으로, 이벤트 루프의 각 페이즈 큐에 쌓였다가 해당 페이즈 차례가 오면 한 번에 콜백 하나씩 실행됩니다. 반면 마이크로태스크는 process.nextTick, Promise.then 같은 작업으로, 페이즈와 무관한 별도 큐(nextTick 큐, Promise 큐)에 쌓이고 현재 실행 중인 JS가 끝난 직후 다음 매크로태스크 전에 큐가 완전히 빌 때까지 전부 실행됩니다. 그래서 마이크로태스크는 한 콜백이 끝날 때마다 끼어들어 사실상 가장 높은 우선순위를 가집니다. 참고로 Node.js 11 이전에는 마이크로태스크가 페이즈가 끝날 때 한 번만 처리됐지만, Node 11부터는 브라우저처럼 타이머·setImmediate 콜백 하나하나 사이에 마이크로태스크를 비우도록 바뀌었습니다.',
 'interview-question/618.mp3'),
(619, 'NODE_JS', 124, 'EASY', true,
 'async 함수 안에서 await를 만나면 실행 흐름이 어떻게 진행되는지 설명해 주세요.',
 'async 함수는 await를 만나기 전까지는 동기적으로 실행되다가, await를 만나는 즉시 호출자에게 제어를 돌려줍니다. 그리고 await 이후의 나머지 코드는 Promise 마이크로태스크로 예약되어, 호출자의 동기 코드가 끝나고 콜 스택이 빈 뒤에 실행됩니다. 예를 들어 run() 안에서 A를 출력하고 await null 뒤에 C를 출력하며, run() 호출 다음 줄에서 B를 출력하면 결과는 A → B → C입니다. await는 값이 Promise가 아니어도 무조건 한 번 마이크로태스크 큐를 거칩니다. 또한 async 함수 안에서 던진 예외는 동기 throw가 아니라 rejected Promise가 되므로 try/catch 위치에 주의해야 합니다.',
 'interview-question/619.mp3'),
(620, 'NODE_JS', 124, 'EASY', true,
 '콜백을 동기적으로도 비동기적으로도 호출하는 함수는 왜 문제가 되며, process.nextTick으로 어떻게 해결하나요?',
 '같은 함수가 상황에 따라 콜백을 동기적으로도, 비동기적으로도 호출하면 호출 순서가 상황마다 달라져 호출 측의 상태 관리가 꼬입니다. 예를 들어 캐시 히트면 콜백을 동기로 바로 호출하고, 캐시 미스면 DB 조회 후 비동기로 호출하는 경우입니다. 이때 캐시 히트여도 process.nextTick(cb, null, cache.get(id))처럼 콜백을 nextTick으로 미루면 항상 비동기로 통일되어 일관성이 보장됩니다. 비슷한 예로 EventEmitter를 상속한 클래스가 생성자 안에서 바로 this.emit(''ready'')를 호출하면 아직 리스너가 등록되기 전이라 이벤트가 유실되는데, process.nextTick으로 emit을 미루면 호출자가 .on(''ready'', ...)를 붙인 뒤에 발행됩니다. Node.js 내부 API가 nextTick을 쓰는 대표적인 이유입니다.',
 'interview-question/620.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 616
(3325, 616, '마이크로태스크 큐는 완전히 빌 때까지 새로 추가된 작업까지 전부 실행된다는 점을 원인으로 설명', 'ESSENTIAL', 1),
(3326, 616, 'nextTick 재귀 시 이벤트 루프가 poll 페이즈에 도달하지 못해 I/O·타이머 기아가 발생함을 설명', 'ESSENTIAL', 2),
(3327, 616, '다음 반복을 setImmediate로 예약해 매 반복마다 I/O에 양보하는 개선책을 제시', 'ESSENTIAL', 3),
(3328, 616, 'Promise.resolve().then을 이용한 Promise 재귀도 동일한 I/O 기아 문제를 일으킴을 언급', 'SUPPLEMENTARY', 4),
(3329, 616, 'setImmediate는 check 페이즈에서 실행되는 매크로태스크라 다음 루프 순회에서 재개됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 617
(3330, 617, 'process.nextTick·Promise.then은 마이크로태스크이고 setImmediate는 매크로태스크임을 구분', 'ESSENTIAL', 1),
(3331, 617, '실행 순서가 nextTick → Promise → setImmediate 순이라고 제시', 'ESSENTIAL', 2),
(3332, 617, 'setImmediate는 poll 페이즈 이후 check 페이즈에서 실행된다고 언급', 'ESSENTIAL', 3),
(3333, 617, 'setImmediate만 I/O에 양보하고 nextTick·Promise는 양보하지 않는다고 언급', 'SUPPLEMENTARY', 4),
(3334, 617, 'process.nextTick은 Node.js 고유이고 Promise는 ECMAScript 표준이라고 언급', 'SUPPLEMENTARY', 5),

-- 질문 618
(3335, 618, '매크로태스크는 한 번에 콜백 하나씩, 마이크로태스크는 큐가 빌 때까지 전부 실행됨을 비교', 'ESSENTIAL', 1),
(3336, 618, '마이크로태스크는 현재 실행 중인 JS가 끝난 직후 다음 매크로태스크 전에 실행된다고 언급', 'ESSENTIAL', 2),
(3337, 618, '매크로태스크는 이벤트 루프의 각 페이즈 큐에, 마이크로태스크는 페이즈와 무관한 별도 큐에 쌓인다고 구분', 'SUPPLEMENTARY', 3),
(3338, 618, 'setTimeout·setImmediate·I/O 콜백 중 최소 1개를 매크로태스크의 예로 제시', 'SUPPLEMENTARY', 4),
(3339, 618, 'Node 11부터 타이머·setImmediate 콜백 하나하나 사이에 마이크로태스크를 비우도록 바뀌었다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 619
(3340, 619, 'await를 만나는 즉시 호출자에게 제어를 돌려준다고 설명', 'ESSENTIAL', 1),
(3341, 619, 'await 이후의 나머지 코드는 Promise 마이크로태스크로 예약된다고 설명', 'ESSENTIAL', 2),
(3342, 619, 'await 대상 값이 Promise가 아니어도 최소 한 번은 마이크로태스크 큐를 거친다고 언급', 'SUPPLEMENTARY', 3),
(3343, 619, 'async 함수 안에서 던진 예외는 동기 throw가 아니라 rejected Promise가 된다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 620
(3344, 620, '같은 함수가 콜백을 동기·비동기로 섞어 호출하면 호출 측의 상태 관리가 꼬인다고 설명', 'ESSENTIAL', 1),
(3345, 620, '캐시 히트처럼 즉시 결과가 있어도 process.nextTick으로 콜백을 미뤄 항상 비동기로 통일한다고 설명', 'ESSENTIAL', 2),
(3346, 620, 'EventEmitter 생성자에서 바로 emit하면 리스너 등록 전이라 이벤트가 유실된다고 언급', 'SUPPLEMENTARY', 3),
(3347, 620, 'process.nextTick으로 emit을 미루면 호출자가 리스너를 붙인 뒤에 발행된다고 언급', 'SUPPLEMENTARY', 4);
