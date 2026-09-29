-- Unit: 리소스 로딩과 파서 차단 (Unit ID: 85)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(421, 'WEB_COMMON', 85, 'HARD', true,
 'head에 스타일시트 링크와 동기 스크립트가 차례로 있고, 웹 폰트와 CSS 배경 이미지로 구성된 첫 화면이 늦게 나타나는 페이지가 있습니다. 원인을 진단하고 어떻게 개선할지, 그리고 그 개선 방법을 과하게 적용했을 때의 대가는 무엇인지 설명해 주세요.',
 '먼저 head 구조가 문제입니다. 스타일시트는 원래 파싱은 막지 않고 렌더링만 막지만, 그 뒤에 동기 스크립트가 있으면 스크립트가 getComputedStyle로 스타일을 읽을 수 있기 때문에 CSSOM이 완성될 때까지 실행을 기다려야 하고, 그동안 파서도 멈춥니다. 결과적으로 CSS가 파서까지 간접적으로 차단하는 셈입니다. 그래서 스크립트에는 defer를 붙여 병렬로 다운로드하고 파싱이 끝난 뒤 실행되게 하고, 첫 화면에 필요한 최소 CSS는 style로 인라인하는 Critical CSS 방식으로 렌더링 차단을 줄일 수 있습니다. 두 번째 원인은 리소스 발견 지연입니다. 프리로드 스캐너는 파서가 멈춘 동안에도 문서를 앞서 훑어 리소스를 미리 다운로드하지만, CSS 안의 background-image나 @font-face로 선언한 웹 폰트는 CSS를 파싱하고 렌더 트리에 잡혀야 요청되기 때문에 스캐너가 발견하지 못해 요청 체인이 길어집니다. 이런 리소스는 link rel="preload"로 조기 요청하면 됩니다. 다만 preload는 무조건 지금 받으라는 강한 명령이라 너무 많이 걸면 정말 중요한 리소스와 대역폭을 나눠 써서 오히려 느려지고, 3초 안에 사용되지 않으면 콘솔 경고가 뜹니다. 또 as 속성을 빠뜨리면 우선순위 판단이 불가능하고 같은 리소스를 두 번 받을 수 있으므로 꼭 필요한 리소스에만 정확히 지정해야 합니다.',
 'interview-question/421.mp3'),
(422, 'WEB_COMMON', 85, 'NORMAL', true,
 'script 태그의 async 속성과 defer 속성은 어떻게 다르고, 각각 어떤 스크립트에 사용하는 것이 적합한가요?',
 '두 속성 모두 스크립트 다운로드를 HTML 파싱과 병렬로 진행한다는 점은 같지만 실행 시점이 다릅니다. async는 다운로드가 완료되는 즉시, 파싱 중이라도 실행되고 그 순간만 파서가 멈춥니다. 그래서 여러 async 스크립트는 다운로드 완료 순서대로 실행되어 실행 순서가 보장되지 않고, 그 시점까지 만들어진 DOM에만 접근할 수 있습니다. 반면 defer는 HTML 파싱이 끝난 뒤, DOMContentLoaded 직전에 문서에 적힌 순서대로 실행되므로 순서가 보장되고 전체 DOM에 접근할 수 있습니다. 따라서 애널리틱스나 광고처럼 다른 코드와 독립적인 스크립트에는 async를, 앱 번들처럼 DOM에 의존하거나 스크립트 간 의존 관계가 있는 코드에는 defer를 사용합니다. 참고로 defer와 async는 src가 있는 외부 스크립트에만 효과가 있고 인라인 스크립트에서는 무시되며, type="module" 스크립트는 기본적으로 defer처럼 동작합니다.',
 'interview-question/422.mp3'),
(423, 'WEB_COMMON', 85, 'NORMAL', true,
 'DOMContentLoaded 이벤트와 load 이벤트는 각각 언제 발생하며, 어떤 작업에 사용하는 것이 적합한가요?',
 'DOMContentLoaded는 HTML 파싱이 완료된 직후 발생하는 이벤트이고, defer 스크립트의 실행이 끝난 뒤에 발생합니다. 이 시점에는 이미지나 CSS 배경 같은 서브리소스가 아직 로드되지 않았을 수 있지만 DOM은 완성돼 있으므로 DOM 조작을 시작하는 지점으로 적합합니다. load는 이미지, 스타일시트, 폰트, iframe 등 모든 서브리소스까지 로드가 완료된 뒤 발생하므로, 전체 크기 측정이나 지연 가능한 초기화에 적합합니다. async 스크립트는 네트워크 속도에 따라 DOMContentLoaded 전에 실행될지 후에 실행될지 불확정입니다. 또 defer 스크립트가 DOMContentLoaded보다 먼저 실행되기는 하지만, 이벤트가 이미 발생한 뒤에 리스너를 등록하면 호출되지 않는 경우가 있어 실무에서는 document.readyState를 확인하는 방어 코드가 필요합니다.',
 'interview-question/423.mp3'),
(424, 'WEB_COMMON', 85, 'EASY', true,
 '브라우저의 프리로드 스캐너란 무엇이며 어떤 역할을 하나요?',
 '프리로드 스캐너는 동기 스크립트 때문에 메인 파서가 멈춰 있는 동안에도 문서를 앞서 훑는 보조 파서입니다. script의 src, link의 href, img의 src 같은 리소스를 미리 발견해서 파서가 거기에 도달하기 전에 다운로드를 먼저 시작하므로, 파서가 대기하는 시간 동안 브라우저가 놀지 않게 해 줍니다. 다만 JavaScript로 동적으로 삽입하는 스크립트나 이미지, CSS 안의 @import와 background-image, @font-face로 선언한 웹 폰트, 번들 안에서 import()로 지연 로딩하는 모듈은 스캐너가 발견하지 못합니다. 이런 리소스는 발견 자체가 늦어 요청 체인이 길어집니다.',
 'interview-question/424.mp3'),
(425, 'WEB_COMMON', 85, 'EASY', true,
 'HTML 파서가 속성 없는 일반 script 태그를 만나면 파싱을 멈추는데, 그 이유와 이때 어떤 일이 일어나는지 설명해 주세요.',
 '속성이 없는 동기 스크립트를 만나면 파서는 해당 스크립트의 다운로드가 끝나고 실행까지 완료될 때까지 HTML 파싱, 즉 DOM 구성을 멈추고 기다립니다. 이유는 스크립트가 document.write 등으로 DOM 자체를 바꿀 수 있기 때문에 스크립트 결과를 보기 전에는 파싱을 계속할 수 없기 때문입니다. 이 때문에 동기 스크립트는 파싱과 첫 페인트를 모두 차단합니다. 또 동기 스크립트는 자기보다 위쪽 DOM에만 접근할 수 있어서, head에 둔 동기 스크립트는 body DOM이 아직 없으므로 querySelector도 실패합니다. 이를 피하려고 body 맨 끝에 두면 DOM은 구성돼 있지만, 파서가 거기에 도달해야 다운로드가 시작되므로 head에서 즉시 병렬 다운로드를 시작하는 defer보다 늦습니다.',
 'interview-question/425.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 421
(2242, 421, 'CSS 뒤의 동기 스크립트가 CSSOM 완성을 기다리는 동안 파서도 멈춘다고 설명', 'ESSENTIAL', 1),
(2243, 421, '웹 폰트·CSS 배경 이미지는 프리로드 스캐너가 발견하지 못해 요청이 늦어진다고 설명', 'ESSENTIAL', 2),
(2244, 421, '늦게 발견되는 웹 폰트·배경 이미지를 preload로 조기 요청하는 해결책을 제시', 'ESSENTIAL', 3),
(2245, 421, 'preload를 너무 많이 걸면 중요한 리소스와 대역폭을 나눠 써 오히려 느려진다고 설명', 'ESSENTIAL', 4),
(2246, 421, '동기 스크립트에 defer를 적용해 파서 차단을 없애는 방법을 제시', 'SUPPLEMENTARY', 5),
(2247, 421, 'preload에서 as 속성을 빠뜨리면 같은 리소스를 두 번 받을 수 있음을 언급', 'SUPPLEMENTARY', 6),
(2248, 421, '첫 화면에 필요한 최소 CSS를 style로 인라인하는 Critical CSS 방식을 제시', 'SUPPLEMENTARY', 7),

-- 질문 422
(2249, 422, 'async는 다운로드 완료 즉시 실행되어 실행 순서가 보장되지 않는다고 설명', 'ESSENTIAL', 1),
(2250, 422, 'defer는 HTML 파싱 완료 후 문서 순서대로 실행된다고 설명', 'ESSENTIAL', 2),
(2251, 422, '독립 스크립트에는 async, DOM에 의존하는 스크립트에는 defer를 쓰는 기준을 제시', 'ESSENTIAL', 3),
(2252, 422, 'async·defer 모두 다운로드는 HTML 파싱과 병렬로 진행된다고 언급', 'SUPPLEMENTARY', 4),
(2253, 422, 'type="module" 스크립트는 기본적으로 defer처럼 동작한다고 언급', 'SUPPLEMENTARY', 5),
(2254, 422, 'defer·async는 외부 스크립트에만 효과가 있고 인라인 스크립트에서는 무시됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 423
(2255, 423, 'DOMContentLoaded는 HTML 파싱 완료 직후 발생한다고 설명', 'ESSENTIAL', 1),
(2256, 423, 'load는 이미지·스타일시트 등 모든 서브리소스 로드가 끝난 뒤 발생한다고 설명', 'ESSENTIAL', 2),
(2257, 423, 'DOMContentLoaded 시점이 DOM 조작을 시작하기에 적합하다고 제시', 'ESSENTIAL', 3),
(2258, 423, '전체 크기 측정·지연 가능한 초기화 중 최소 1개를 load 시점에 적합한 작업으로 제시', 'ESSENTIAL', 4),
(2259, 423, 'DOMContentLoaded는 defer 스크립트 실행이 완료된 후에 발생한다고 언급', 'SUPPLEMENTARY', 5),
(2260, 423, 'async 스크립트는 DOMContentLoaded 전후 어느 쪽에 실행될지 불확정임을 언급', 'SUPPLEMENTARY', 6),
(2261, 423, 'defer 안의 DOMContentLoaded 리스너가 호출되지 않을 수 있어 document.readyState 확인이 필요함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 424
(2262, 424, '프리로드 스캐너는 메인 파서가 멈춘 동안 문서를 앞서 훑는 보조 파서라고 설명', 'ESSENTIAL', 1),
(2263, 424, 'script의 src·img의 src 같은 리소스를 미리 발견해 다운로드를 먼저 시작한다고 설명', 'ESSENTIAL', 2),
(2264, 424, 'CSS의 @import·background-image, 동적 삽입 스크립트 중 최소 1개를 스캐너가 못 찾는 리소스로 제시', 'SUPPLEMENTARY', 3),
(2265, 424, '스캐너가 못 찾는 리소스는 발견이 늦어 요청 체인이 길어진다고 설명', 'SUPPLEMENTARY', 4),

-- 질문 425
(2266, 425, '동기 스크립트는 다운로드부터 실행까지 끝날 때까지 HTML 파싱을 중단시킨다고 설명', 'ESSENTIAL', 1),
(2267, 425, '스크립트가 document.write로 DOM을 바꿀 수 있어 파서가 멈춘다고 설명', 'ESSENTIAL', 2),
(2268, 425, 'head의 동기 스크립트는 아직 body DOM이 없어 querySelector가 실패할 수 있음을 언급', 'SUPPLEMENTARY', 3),
(2269, 425, '동기 스크립트를 body 끝에 두면 다운로드가 파싱 완료 후 시작되어 defer보다 늦다고 설명', 'SUPPLEMENTARY', 4);
