-- Unit: 브라우저 렌더링 파이프라인 (Unit ID: 82)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(406, 'WEB_COMMON', 82, 'HARD', true,
 'JavaScript로 요소의 width 값을 매 프레임 바꾸는 애니메이션이 버벅입니다. 렌더링 파이프라인 관점에서 원인과 개선 방법, 그리고 그 개선책의 대가를 설명해 주세요.',
 'width는 요소의 위치와 크기를 결정하는 기하 속성이라, 값을 바꾸면 레이아웃부터 페인트, 합성까지 이후 단계가 전부 다시 실행됩니다. 레이아웃은 한 요소의 크기 변화가 형제·부모·자손 위치에 연쇄적으로 영향을 주기 때문에 가장 비싼 단계이고, 이것을 매 프레임 반복하면 60Hz 기준 약 16.7ms인 프레임 예산을 넘겨 프레임이 누락되는 jank가 생깁니다. 개선 방법은 width 대신 transform과 opacity로 애니메이션하는 것입니다. transform·opacity만 변경하면 레이아웃과 페인트를 건너뛰고 합성만 다시 하면 됩니다. 합성은 합성 스레드가 GPU로 처리하며 메인 스레드와 독립적으로 동작하므로, JavaScript 실행으로 메인 스레드가 바빠도 애니메이션이 끊기지 않습니다. 갱신 타이밍도 setInterval 대신 requestAnimationFrame을 써서 프레임마다 정확히 1회 실행되도록 맞춥니다. 다만 대가가 있습니다. 애니메이션 요소를 별도 레이어로 분리하면 레이어마다 GPU 메모리를 소비하므로, will-change를 모든 요소에 남발하면 오히려 메모리 부족으로 느려질 수 있습니다. 그래서 실제로 애니메이션되는 요소에만, 필요한 시점에만 적용해야 합니다.'),
(407, 'WEB_COMMON', 82, 'NORMAL', true,
 'display: none, visibility: hidden, opacity: 0은 모두 요소를 화면에서 보이지 않게 합니다. 세 방식은 렌더링 과정에서 어떻게 다르게 처리되나요?',
 '세 방식 모두 요소는 DOM에 그대로 포함됩니다. 차이는 렌더 트리와 레이아웃, 이벤트 처리에서 생깁니다. display: none인 요소는 렌더 트리에 포함되지 않고, 그 자손까지 함께 제외되며 레이아웃 공간도 차지하지 않고 이벤트도 받을 수 없습니다. visibility: hidden인 요소는 렌더 트리에 포함되어 보이지만 않을 뿐 레이아웃 공간은 그대로 차지하고, 이벤트는 받을 수 없습니다. opacity: 0인 요소는 렌더 트리에 포함되고 공간도 차지하며, 보이지 않는데도 이벤트를 수신할 수 있다는 점이 다릅니다.'),
(408, 'WEB_COMMON', 82, 'NORMAL', true,
 'CSS와 동기 스크립트는 각각 첫 화면 표시를 어떻게 지연시키나요? 렌더링 차단과 파서 차단의 차이를 중심으로 설명해 주세요.',
 'CSS는 렌더링 차단 리소스이고, 동기 스크립트는 파서 차단 리소스입니다. CSS는 나중에 오는 규칙이 앞의 규칙을 덮어쓸 수 있는 캐스케이딩 특성 때문에 부분 적용이 불가능해서, 스타일시트 전체를 읽기 전에는 어떤 노드의 최종 스타일도 확정할 수 없습니다. 그래서 CSS는 HTML 파싱, 즉 DOM 구성 자체는 멈추지 않지만 CSSOM이 완성될 때까지 렌더 트리 생성 이후 단계가 전부 대기합니다. 반면 HTML 파싱 도중 script 태그를 만나면 파서가 멈추고 스크립트를 실행하므로 DOM 구성 자체가 중단됩니다. 이를 완화하려면 화면에 필요한 최소 CSS인 Critical CSS만 인라인하고 나머지는 지연 로딩하며, 스크립트에는 async나 defer를 사용합니다.'),
(409, 'WEB_COMMON', 82, 'EASY', true,
 '브라우저가 응답으로 받은 HTML과 CSS를 화면의 픽셀로 그리기까지의 렌더링 과정을 단계별로 설명해 주세요.',
 '먼저 HTML 파서가 바이트를 토큰화해 노드로 만들어 DOM 트리를 구성하고, CSS는 CSSOM 트리로 변환됩니다. HTML 파싱은 점진적으로 진행되어 문서 전체가 도착하기 전에도 앞부분부터 트리를 만듭니다. 다음으로 DOM과 CSSOM을 결합해 실제로 화면에 그려질 노드만 모은 렌더 트리를 만들고, 각 노드에 계산된 스타일을 붙입니다. 이후 레이아웃 단계에서 각 요소의 위치와 크기를 계산하고, 페인트 단계에서 색·테두리·그림자·텍스트 등을 그리는 명령을 만들어 래스터화하며, 마지막으로 합성 단계에서 여러 레이어를 GPU로 합쳐 화면에 표시합니다. 이 전체 경로를 크리티컬 렌더링 패스라고 부릅니다.'),
(410, 'WEB_COMMON', 82, 'EASY', true,
 '강제 동기 레이아웃(Forced Synchronous Layout)이란 무엇이며, 어떤 코드에서 발생하나요?',
 '레이아웃은 렌더 트리의 각 요소가 어디에, 얼마나 큰 크기로 놓이는지, 즉 위치와 크기를 계산하는 단계입니다. 브라우저는 스타일 변경을 바로 반영하지 않고 레이아웃을 무효화해 예약해 둔 뒤 다음 프레임까지 모아서 처리합니다. 그런데 스타일을 변경한 직후 offsetWidth나 getBoundingClientRect()처럼 기하 정보를 읽으면, 브라우저는 정확한 최신 값을 돌려주기 위해 예약된 레이아웃을 그 자리에서 즉시 실행해야 합니다. 이것이 강제 동기 레이아웃입니다. 예를 들어 box.style.width를 300px로 바꾼 직후 box.offsetWidth를 읽는 코드에서 발생합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 406
(2166, 406, 'width 같은 기하 속성 변경은 레이아웃부터 이후 단계를 다시 실행시킴을 언급', 'ESSENTIAL', 1),
(2167, 406, 'transform·opacity만 변경하면 레이아웃·페인트를 건너뛰고 합성만 다시 함을 설명', 'ESSENTIAL', 2),
(2168, 406, '레이어마다 GPU 메모리를 소비해 will-change 남발 시 오히려 느려질 수 있음을 대가로 제시', 'ESSENTIAL', 3),
(2169, 406, '합성 스레드는 메인 스레드와 독립적이라 JavaScript가 바빠도 애니메이션이 끊기지 않음을 설명', 'SUPPLEMENTARY', 4),
(2170, 406, '60Hz 기준 한 프레임 예산이 약 16.7ms이고 이를 넘기면 프레임 드롭이 발생함을 언급', 'SUPPLEMENTARY', 5),
(2171, 406, 'setInterval 대신 requestAnimationFrame으로 프레임마다 1회 갱신하는 방법을 제시', 'SUPPLEMENTARY', 6),

-- 질문 407
(2172, 407, 'display: none 요소는 렌더 트리에서 제외됨을 언급', 'ESSENTIAL', 1),
(2173, 407, 'visibility: hidden 요소는 보이지 않아도 렌더 트리에 포함됨을 언급', 'ESSENTIAL', 2),
(2174, 407, 'display: none은 공간을 차지하지 않고 visibility: hidden은 차지한다는 차이를 설명', 'ESSENTIAL', 3),
(2175, 407, 'opacity: 0 요소는 보이지 않아도 이벤트를 수신할 수 있음을 언급', 'ESSENTIAL', 4),
(2176, 407, 'display: none 요소의 자손도 렌더 트리에서 함께 제외됨을 언급', 'SUPPLEMENTARY', 5),
(2177, 407, '세 방식 모두 DOM에는 포함된다는 점을 명시', 'SUPPLEMENTARY', 6),

-- 질문 408
(2178, 408, 'CSS는 CSSOM 완성 전까지 렌더 트리 생성 이후 단계를 대기시킴을 설명', 'ESSENTIAL', 1),
(2179, 408, 'CSS는 DOM 구성(HTML 파싱) 자체는 멈추지 않음을 명시', 'ESSENTIAL', 2),
(2180, 408, '파싱 도중 script를 만나면 HTML 파서가 멈추고 스크립트를 실행함을 언급', 'ESSENTIAL', 3),
(2181, 408, 'CSS는 캐스케이딩 때문에 부분 적용이 불가능하다는 점을 렌더링 차단의 이유로 제시', 'SUPPLEMENTARY', 4),
(2182, 408, 'async·defer 속성으로 파서 차단을 완화할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 409
(2183, 409, 'HTML은 DOM 트리로, CSS는 CSSOM 트리로 파싱됨을 언급', 'ESSENTIAL', 1),
(2184, 409, 'DOM과 CSSOM을 결합해 화면에 그려질 노드만 담은 렌더 트리를 만듦을 설명', 'ESSENTIAL', 2),
(2185, 409, '렌더 트리 이후 레이아웃, 페인트, 합성 순서로 진행됨을 서술', 'ESSENTIAL', 3),
(2186, 409, '이 전체 경로를 크리티컬 렌더링 패스(CRP)라고 부름을 언급', 'SUPPLEMENTARY', 4),
(2187, 409, 'HTML 파싱은 문서 전체가 도착하기 전에도 점진적으로 진행됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 410
(2188, 410, '브라우저는 스타일 변경을 바로 반영하지 않고 다음 프레임까지 모아서 처리함을 언급', 'ESSENTIAL', 1),
(2189, 410, 'offsetWidth·getBoundingClientRect() 같은 기하 정보 읽기를 발생 조건으로 제시', 'ESSENTIAL', 2),
(2190, 410, '정확한 값을 돌려주려고 예약된 레이아웃을 즉시 실행하는 현상임을 설명', 'ESSENTIAL', 3),
(2191, 410, '레이아웃이 각 요소의 위치와 크기를 계산하는 단계임을 언급', 'SUPPLEMENTARY', 4);
