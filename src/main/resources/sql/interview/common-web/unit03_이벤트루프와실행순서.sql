-- Unit: 이벤트 루프와 실행 순서 (Unit ID: 84)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(416, 'WEB_COMMON', 84, 'HARD', true,
 '버튼 클릭 핸들러에서 스피너를 표시한 뒤 무거운 계산을 실행했더니 스피너가 화면에 보이지 않았습니다. 원인은 무엇이고 어떻게 해결하나요? 작업을 await Promise.resolve()로 쪼개면 해결되는지도 함께 설명해 주세요.',
 '원인은 이벤트 루프가 콜 스택이 비어야 다음 작업을 처리한다는 데 있습니다. 스피너의 hidden 속성을 바꿔도 렌더링은 태스크 사이에 기회가 있을 때만 일어나는데, 같은 클릭 핸들러 태스크 안에서 무거운 계산이 이어지면 그 태스크가 끝날 때까지 콜 스택이 비지 않아 렌더링이 전혀 일어나지 않고, 계산이 끝나면 스피너를 다시 숨기므로 결국 화면에 보이지 않습니다. 해결하려면 무거운 작업을 새 태스크로 넘겨야 합니다. setTimeout으로 작업을 분할하면 태스크 사이사이에 렌더링과 입력 처리가 가능해지고, 스피너를 먼저 그리고 싶다면 requestAnimationFrame 안에서 setTimeout을 감싸 한 프레임을 그린 뒤 계산을 실행하는 관용구를 씁니다. rAF 콜백은 렌더링 직전에 실행되므로 그 안에서 바로 계산하면 해당 프레임 렌더링이 또 밀리기 때문입니다. 반면 await Promise.resolve()로 쪼개는 것은 해결책이 아닙니다. Promise는 마이크로태스크이고 마이크로태스크는 렌더링 앞에서 큐가 빌 때까지 전부 실행되므로 이벤트 루프에 제어권이 넘어가지 않습니다. 양보하려면 setTimeout, MessageChannel, scheduler.yield 같은 태스크를 사용해야 합니다. 계산 자체를 메인 스레드에서 떼어내려면 Web Worker를 쓸 수 있지만 DOM에 접근할 수 없어 결과를 메시지로 전달해야 합니다. 참고로 50ms를 넘는 긴 태스크는 클릭·입력 반응과 렌더링을 모두 막아 INP 지표를 악화시킵니다.',
 'interview-question/416.mp3'),
(417, 'WEB_COMMON', 84, 'NORMAL', true,
 '이벤트 루프에서 태스크(매크로태스크)와 마이크로태스크는 처리 방식이 어떻게 다른가요? 이 차이 때문에 setTimeout(fn, 0)과 Promise.then 중 어느 콜백이 먼저 실행되는지도 설명해 주세요.',
 '이벤트 루프의 한 tick은 태스크 큐에서 태스크 1개를 꺼내 실행하고, 그다음 마이크로태스크 큐가 빌 때까지 전부 실행한 뒤, 렌더링 기회가 있으면 렌더링하는 순서로 진행됩니다. 핵심 차이는 ''하나만''과 ''전부''입니다. setTimeout 콜백이나 이벤트 핸들러 같은 태스크는 한 tick에 하나만 처리되지만, Promise.then이나 queueMicrotask 같은 마이크로태스크는 실행 중에 추가된 것까지 포함해 큐가 완전히 빌 때까지 처리됩니다. 그래서 스크립트 안에서 setTimeout(fn, 0)과 Promise.then을 함께 예약하면 Promise.then 콜백이 먼저 실행됩니다. 스크립트 실행 자체가 하나의 태스크이므로 그 안에서 예약한 마이크로태스크가 다음 태스크인 setTimeout 콜백보다 먼저 전부 실행되기 때문입니다. setTimeout(fn, 0)은 즉시가 아니라 현재 태스크와 모든 마이크로태스크가 끝난 뒤의 가장 이른 다음 태스크를 뜻합니다. 반대로 마이크로태스크가 마이크로태스크를 계속 추가하면 렌더링과 다음 태스크가 무한히 미뤄질 수 있다는 점도 주의해야 합니다.',
 'interview-question/417.mp3'),
(418, 'WEB_COMMON', 84, 'NORMAL', true,
 '애니메이션처럼 화면을 주기적으로 갱신할 때 setTimeout 대신 requestAnimationFrame을 쓰는 이유는 무엇인가요?',
 '브라우저는 보통 화면 주사율, 예를 들어 60Hz라면 약 16.7ms마다 렌더링 기회를 주고, 렌더링 단계는 requestAnimationFrame 콜백, 스타일 계산, 레이아웃, 페인트, 합성 순으로 진행됩니다. requestAnimationFrame 콜백은 이 렌더링 직전에 실행되므로 그 안에서 스타일을 바꾸면 해당 프레임에 바로 반영되고, 프레임마다 1회 실행이 보장됩니다. 반면 setTimeout은 렌더링과 무관한 태스크라서 렌더링 기회와 어긋나 한 프레임에 두 번 실행되거나 건너뛸 수 있습니다. 게다가 HTML 명세상 중첩 깊이가 5를 넘는 타이머는 최소 지연이 4ms로 강제되고, 백그라운드 탭에서는 브라우저가 1초 이상으로 늦출 수 있어 정밀한 타이밍이 필요한 애니메이션에는 적합하지 않습니다.',
 'interview-question/418.mp3'),
(419, 'WEB_COMMON', 84, 'EASY', true,
 'JavaScript는 싱글 스레드인데 어떻게 타이머나 네트워크 요청 같은 비동기 작업을 처리할 수 있나요?',
 'JavaScript 엔진 자체는 싱글 스레드로 콜 스택에서 한 번에 하나의 함수만 실행하지만, 타이머나 네트워크 대기 같은 비동기 작업은 브라우저가 별도 스레드의 Web API로 대신 처리합니다. setTimeout이나 fetch를 호출하면 대기는 Web API가 맡고, 작업이 완료되면 그 콜백만 태스크 큐나 마이크로태스크 큐에 들어갑니다. 그리고 이벤트 루프가 콜 스택이 비었을 때 큐에서 콜백을 꺼내 콜 스택으로 올려 실행합니다. 즉 대기는 Web API가 맡고, 완료된 콜백만 큐를 거쳐 콜 스택으로 돌아오기 때문에 싱글 스레드로도 비동기 처리가 가능합니다. 참고로 이벤트 루프는 V8 같은 JavaScript 엔진이 아니라 브라우저나 Node.js 같은 호스트 환경이 제공합니다.',
 'interview-question/419.mp3'),
(420, 'WEB_COMMON', 84, 'EASY', true,
 'async 함수 안에서 await를 만나면 그 이후의 코드는 이벤트 루프에서 어떻게 실행되나요?',
 'async/await도 태스크·마이크로태스크 규칙을 그대로 따릅니다. async 함수가 await를 만나면 그 지점에서 함수 실행이 일시 중단되고, await 뒤따르는 코드는 마이크로태스크로 예약됩니다. 그래서 함수가 중단된 사이 호출부의 이후 동기 코드가 먼저 실행되고, 현재 태스크가 끝난 직후 마이크로태스크 큐가 비워질 때 나머지 코드가 이어서 실행됩니다. 예를 들어 run 함수 안에서 A를 출력하고 await null 뒤에 C를 출력하게 한 뒤, run()을 호출하고 바로 B를 출력하면 출력 순서는 A, B, C가 됩니다.',
 'interview-question/420.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 416
(2220, 416, '무거운 계산 태스크가 끝날 때까지 콜 스택이 비지 않아 렌더링이 일어나지 않음을 설명', 'ESSENTIAL', 1),
(2221, 416, 'setTimeout 등으로 작업을 새 태스크로 넘겨 태스크 사이에 렌더링을 허용하는 해결책을 제시', 'ESSENTIAL', 2),
(2222, 416, 'await Promise.resolve()는 마이크로태스크라 렌더링보다 먼저 실행되어 양보가 되지 않음을 설명', 'ESSENTIAL', 3),
(2223, 416, 'rAF 안에서 setTimeout을 감싸 한 프레임을 그린 뒤 실행하는 관용구를 제시', 'SUPPLEMENTARY', 4),
(2224, 416, 'Web Worker로 계산을 별도 스레드로 옮기되 DOM 접근이 불가하다는 한계를 언급', 'SUPPLEMENTARY', 5),
(2225, 416, '50ms를 넘는 긴 태스크(Long Task)가 INP 지표를 악화시킨다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 417
(2226, 417, '태스크 큐에서는 한 tick에 태스크를 하나만 꺼내 실행한다고 설명', 'ESSENTIAL', 1),
(2227, 417, '마이크로태스크 큐는 현재 태스크 직후 큐가 빌 때까지 전부 실행된다고 설명', 'ESSENTIAL', 2),
(2228, 417, 'Promise.then 콜백이 setTimeout(fn, 0) 콜백보다 먼저 실행됨을 명시', 'ESSENTIAL', 3),
(2229, 417, '마이크로태스크가 계속 추가되면 렌더링과 다음 태스크가 무한히 미뤄질 수 있음을 언급', 'SUPPLEMENTARY', 4),
(2230, 417, 'setTimeout(fn, 0)은 즉시가 아니라 가장 이른 다음 태스크를 뜻한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 418
(2231, 418, 'requestAnimationFrame 콜백은 렌더링 직전에 실행되어 변경이 그 프레임에 바로 반영된다고 설명', 'ESSENTIAL', 1),
(2232, 418, 'setTimeout은 렌더링 기회와 어긋나 한 프레임에 두 번 실행되거나 건너뛸 수 있음을 설명', 'ESSENTIAL', 2),
(2233, 418, 'rAF는 프레임마다 1회 실행이 보장된다고 언급', 'SUPPLEMENTARY', 3),
(2234, 418, '중첩 타이머의 최소 4ms 지연·백그라운드 탭 지연 중 최소 1개를 setTimeout이 정밀한 타이밍에 부적합한 근거로 제시', 'SUPPLEMENTARY', 4),

-- 질문 419
(2235, 419, '타이머·네트워크 대기는 브라우저의 Web API가 대신 처리한다고 설명', 'ESSENTIAL', 1),
(2236, 419, '완료된 콜백만 큐를 거쳐 콜 스택으로 돌아온다고 설명', 'ESSENTIAL', 2),
(2237, 419, '이벤트 루프가 콜 스택이 비면 큐에서 콜백을 꺼내 실행한다고 설명', 'ESSENTIAL', 3),
(2238, 419, '이벤트 루프는 JavaScript 엔진이 아니라 호스트 환경(브라우저, Node.js)이 제공한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 420
(2239, 420, 'await 지점에서 async 함수의 실행이 일시 중단된다고 설명', 'ESSENTIAL', 1),
(2240, 420, 'await 뒤따르는 코드가 마이크로태스크로 예약된다고 설명', 'ESSENTIAL', 2),
(2241, 420, '중단된 사이 호출부의 이후 동기 코드가 먼저 실행된다고 언급', 'SUPPLEMENTARY', 3);
