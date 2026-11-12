-- Unit: 리소스 로딩과 파서 차단 (Unit ID: 85)
-- Chapter: Web (Chapter ID: 7)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (511, 85, 'CSS·스크립트 차단과 프리로드 스캐너'),
       (669, 85, 'preconnect와 요청 우선순위 조정'),
       (827, 85, '늦게 발견되는 리소스와 prefetch');

-- =====================================================
-- Lesson 511: CSS·스크립트 차단과 프리로드 스캐너
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3245, 511, '아래 문서를 브라우저가 내려받아 파싱할 때의 동작으로 옳은 것은?', '```html
<head>
  <link rel="stylesheet" href="app.css">
  <script src="app.js"></script>
</head>
<body>
  <h1>월간 리포트</h1>
  <img src="hero.webp">
</body>
```

응답이 도착하기까지 걸린 시간은 app.css 800ms, app.js 200ms, hero.webp 400ms이다. 스크립트 실행 시간과 파싱 자체에 드는 시간은 무시한다.', 'OBJECTIVE'),
       (3246, 511, '아래 조건에서 세 스크립트가 실행되는 순서로 옳은 것은?', '```html
<head>
  <script src="a.js" defer></script>
  <script src="b.js" async></script>
  <script src="c.js" defer></script>
</head>
```

HTML 파싱은 200ms에 끝난다. 각 파일의 다운로드 완료 시각은 b.js 100ms, c.js 150ms, a.js 500ms이며 스크립트 실행에 드는 시간은 무시한다.', 'OBJECTIVE'),
       (3247, 511, '아래 head 설정과 콘솔 경고에 대한 설명으로 옳지 않은 것은?', '```html
<head>
  <link rel="preload" href="/fonts/Pretendard.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="/img/hero.webp">
  <link rel="preconnect" href="https://api.example.com">
  <link rel="prefetch" href="/js/checkout.chunk.js">
</head>
```

배포 후 콘솔에는 `/img/hero.webp`를 두 번 내려받았다는 경고가 떴다. checkout.chunk.js는 결제 화면에서만 쓰는 번들이다.', 'OBJECTIVE'),
       (3248, 511, '아래 문서의 첫 화면 표시 성능에 대한 설명으로 옳은 것은?', '```html
<head>
  <link rel="stylesheet" href="print.css" media="print">
  <link rel="stylesheet" href="app.css">
</head>
<body>
  <img class="hero" src="hero.webp" loading="lazy" decoding="async">
  <p>이번 달 요약</p>
</body>
```

현재 사용자는 화면으로 문서를 보고 있으며, hero.webp는 화면 최상단에 놓여 첫 화면에서 가장 큰 요소다.', 'OBJECTIVE'),
       (3249, 511, '아래 네트워크 기록과 같은 요청 순서를 만들어 낸 브라우저 구성 요소의 이름은?', '```
0ms     app.js 요청 시작        head의 동기 스크립트, 응답에 900ms 소요
5ms     bundle.js 요청 시작     body 맨 끝의 script
5ms     hero.webp 요청 시작     body 중간의 img
900ms   app.js 실행, 파서가 body 파싱 재개
940ms   chart.js 요청 시작      app.js가 document.createElement로 삽입한 script
```

파서는 0ms부터 900ms까지 head에서 멈춰 있었는데도, 파서가 아직 도달하지 못한 body 아래쪽 리소스들의 요청은 5ms에 이미 시작됐다.', 'SUBJECTIVE'),
       (3250, 511, '아래 상황에서 widget.js가 리스너를 걸었지만 이미 지나가 버린 이벤트의 이름은?', '```html
<head>
  <script src="widget.js" async></script>
</head>
```

```javascript
// widget.js
document.addEventListener("____", () => renderChart());
window.addEventListener("load", () => console.log("ready"));
```

widget.js는 CDN 응답이 늦어, HTML 파싱이 모두 끝나고 대형 이미지들은 아직 내려받는 중일 때에야 실행됐다. 콘솔에는 ready가 찍혔지만 차트는 끝내 그려지지 않았고 오류도 없었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3245
(8827, 3245, 'app.js는 200ms에 도착하는 즉시 실행되므로 app.css 응답을 기다리지 않는다.', '스타일시트는 렌더링만 막는다는 절반짜리 지식에서 나온 오해다. 뒤따르는 동기 스크립트는 getComputedStyle로 스타일을 읽을 수 있어 CSSOM이 완성돼야 실행된다.', false),
(8828, 3245, 'app.js는 200ms에 도착하고도 800ms까지 실행되지 못하며, 그동안 body 파싱도 멈춰 있다.', 'CSS 뒤의 동기 스크립트는 CSSOM 완성 시점인 800ms까지 기다려야 하고, 동기 스크립트는 파서를 막으므로 그 대기 시간만큼 body의 DOM 구성도 함께 밀린다.', true),
(8829, 3245, 'hero.webp 요청은 파서가 body의 img 태그에 도달한 뒤인 800ms 이후에야 시작된다.', '메인 파서가 멈추면 모든 요청도 멈춘다고 본 오해다. 보조 파서가 문서를 앞서 훑으며 img의 src를 찾아 먼저 요청을 띄우므로 대기 중에도 다운로드는 진행된다.', false),
(8830, 3245, 'h1은 app.css가 도착하기 전에 먼저 그려지고 800ms에 스타일이 입혀진다.', '스타일이 나중에 덧입혀진다고 본 오해다. 스타일시트는 렌더 트리 구성을 막으므로 CSSOM이 완성되는 800ms 전에는 첫 페인트 자체가 일어나지 않는다.', false),

-- 문제 3246
(8831, 3246, 'a.js → c.js → b.js', 'async 스크립트가 늘 맨 뒤로 밀린다고 본 오해다. b.js는 도착하는 100ms에 곧바로 실행되므로 파싱이 끝나기도 전에 셋 중 가장 먼저 실행된다.', false),
(8832, 3246, 'a.js → b.js → c.js', '세 스크립트가 모두 문서에 적힌 순서를 지킨다고 본 오해다. 순서를 보장하는 것은 defer뿐이고, async는 문서 순서와 무관하게 도착하는 대로 실행된다.', false),
(8833, 3246, 'b.js → c.js → a.js', 'defer도 다운로드가 끝난 순서인 c.js 150ms, a.js 500ms대로 실행된다고 본 오해다. defer는 도착 순서와 무관하게 문서에 적힌 순서를 지킨다.', false),
(8834, 3246, 'b.js → a.js → c.js', 'b.js는 도착하는 100ms에 파싱 도중 바로 실행된다. defer인 둘은 파싱이 끝난 200ms 이후로 미뤄지고 문서 순서를 지켜야 하므로, a.js가 도착하는 500ms에 a.js, 이어서 c.js가 실행된다.', true),

-- 문제 3247
(8835, 3247, 'api.example.com에 걸어 둔 힌트 덕분에 첫 API 응답이 미리 캐시에 담겨 호출 즉시 데이터를 쓸 수 있다.', '거짓이라 정답이다. preconnect는 DNS 조회와 TCP 연결, TLS 핸드셰이크까지만 미리 끝내 둘 뿐 응답 본문은 받아 오지 않는다. 데이터를 미리 받으려면 별도의 사전 요청이 필요하다.', true),
(8836, 3247, 'hero.webp를 두 번 받은 것은 as 속성이 없어 브라우저가 용도와 우선순위를 판단하지 못한 탓이다.', '참이다. as가 빠지면 어떤 종류의 리소스인지 알 수 없어 우선순위를 정할 수 없고, 뒤이은 실제 요청과 별개의 요청으로 취급돼 같은 파일을 두 번 내려받게 된다.', false),
(8837, 3247, 'checkout.chunk.js는 낮은 우선순위로 유휴 시간에 받으므로 첫 화면의 폰트·이미지와 대역폭을 크게 다투지 않는다.', '참이다. prefetch는 다음에 이동할 화면에서 쓸 리소스를 위한 힌트라 우선순위가 낮게 잡히고, 지금 당장 필요한 리소스를 밀어내지 않는다.', false),
(8838, 3247, '폰트에 붙은 crossorigin을 지우면 요청 모드가 달라져 폰트를 다시 받게 되고 preload 효과가 사라진다.', '참이다. 웹 폰트는 CORS 익명 모드로 요청되므로, preload 쪽 요청 모드가 다르면 서로 다른 요청으로 취급돼 미리 받아 둔 파일이 재사용되지 않는다.', false),

-- 문제 3248
(8839, 3248, 'print.css도 스타일 규칙을 담고 있으므로 app.css와 함께 첫 페인트를 막는다.', '모든 스타일시트가 렌더링을 막는다고 본 오해다. media 조건이 지금 상황과 맞지 않는 스타일시트는 낮은 우선순위로 받아 둘 뿐 첫 페인트를 막지 않는다.', false),
(8840, 3248, '두 스타일시트가 파서를 멈추게 하므로 body의 img 태그를 발견하는 시점 자체가 늦어진다.', '스타일시트가 HTML 파싱까지 막는다고 본 오해다. 스타일시트는 렌더 트리 구성을 막을 뿐이고, 사이에 동기 스크립트가 없으면 DOM 구성은 그대로 이어진다.', false),
(8841, 3248, 'hero.webp의 요청이 뷰포트 판정 뒤로 밀려, 가장 큰 요소가 그려지는 시점이 오히려 늦어진다.', '지연 로딩은 첫 화면 밖 이미지의 전송량을 줄이려는 장치다. 첫 화면에서 가장 큰 이미지에 붙이면 발견과 요청이 늦어져 LCP가 나빠지므로 오히려 우선순위를 올려야 한다.', true),
(8842, 3248, 'decoding 속성이 붙어 있어 이 이미지의 다운로드가 다른 리소스와 병렬로 진행된다.', '디코딩과 다운로드를 혼동한 오해다. 이미지 다운로드는 원래 병렬로 이뤄지며, 이 속성은 내려받은 이미지를 화면에 올릴 때 메인 스레드를 막지 않게 할 뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1038, 3249, '프리로드 스캐너,프리로드스캐너,preload scanner,preloadscanner,preload-scanner', '메인 파서가 동기 스크립트 앞에서 멈춰 있는 동안에도 보조 파서가 문서를 앞서 훑으며 script의 src, link의 href, img의 src를 찾아 요청을 먼저 띄운다. 그래서 파서가 아직 도달하지 못한 bundle.js와 hero.webp가 5ms에 이미 요청됐다. 반대로 마크업에 적혀 있지 않은 리소스, 즉 코드로 만들어 붙인 chart.js나 CSS 안의 @import·background-image, @font-face 폰트는 이 스캐너가 찾지 못해 발견 자체가 늦다. 그렇게 늦게 발견되는 리소스를 앞당기는 수단이 preload 힌트이며, 문서를 미리 훑는 이 구성 요소와는 역할이 다르다.'),
       (1039, 3250, 'DOMContentLoaded,DOM Content Loaded,dom-content-loaded,DOMContentLoaded 이벤트,domcontentloaded event', 'HTML 파싱이 끝나고 defer 스크립트까지 모두 실행되면 DOMContentLoaded가 발생한다. async 스크립트는 도착 시점에 따라 이 이벤트 앞뒤 어디서든 실행될 수 있어, 늦게 도착하면 리스너를 거는 순간 이미 발생이 끝나 있어 콜백이 영영 호출되지 않는다. 반면 load는 이미지 같은 서브리소스까지 모두 끝나야 발생하므로 그 시점에는 아직 남아 있었고, 그래서 ready만 찍혔다. 두 이벤트는 기준이 다르다. DOM 조작을 시작하는 지점은 DOMContentLoaded, 전체 크기 측정처럼 리소스가 다 필요한 일은 load에 건다. 늦게 실행될 수 있는 코드라면 document.readyState를 확인해 이미 지났으면 곧바로 실행하는 방어 코드를 둔다.');

-- =====================================================
-- Lesson 669: preconnect와 요청 우선순위 조정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4193, 669, '아래 문서를 열었을 때 두 script의 동작에 대한 설명으로 옳은 것은?', '```html
<head>
  <script defer>
    document.querySelector(''#app'').textContent = ''준비 완료'';
  </script>
  <script type="module" src="main.js"></script>
</head>
<body>
  <div id="app"></div>
</body>
```

문서를 열자 콘솔에 아래 오류가 찍혔다. 오류가 난 위치는 head의 첫 번째 script 안 코드다.

```
Uncaught TypeError: Cannot set properties of null (setting ''textContent'')
```', 'OBJECTIVE'),
       (4194, 669, '아래 조건에서 힌트를 추가한 뒤, 요청 발견부터 폰트 다운로드 완료까지 걸리는 시간은?', 'https://fonts.example.net에서 웹 폰트를 처음 요청할 때, 요청이 발견된 뒤 각 단계에 걸린 시간은 아래와 같다.

| 단계 | 소요 시간 |
|---|---|
| DNS 조회 | 90ms |
| TCP 연결 | 110ms |
| TLS 핸드셰이크 | 160ms |
| 폰트 다운로드 | 140ms |

이후 head에 아래 한 줄을 추가했다. 힌트로 미리 할 수 있는 작업은 폰트 요청이 발견되기 전에 모두 끝나고, 나머지 단계의 소요 시간은 그대로라고 가정한다.

```html
<link rel="dns-prefetch" href="https://fonts.example.net">
```', 'OBJECTIVE'),
       (4195, 669, '아래 브라우저 동작에 대한 설명으로 옳은 것은?', '메인 HTML 파서가 head의 동기 스크립트를 내려받아 실행하느라 멈춰 있는 동안에도, 브라우저의 보조 파서는 아직 파싱되지 않은 뒷부분의 HTML을 앞서 훑어 리소스 URL을 찾아내고 그 다운로드를 먼저 시작한다. 그래서 메인 파서가 다시 움직일 때쯤에는 body에 적힌 이미지나 스크립트 일부의 다운로드가 이미 끝나 있기도 하다.', 'OBJECTIVE'),
       (4196, 669, '아래 문서를 열었을 때 콘솔에 찍히는 순서로 옳은 것은?', '```html
<head>
  <script src="setup.js" defer></script>
</head>
<body>
  <img src="photo.jpg">
  <script>console.log(''inline'');</script>
</body>
```

```javascript
// setup.js
console.log(''defer'');
document.addEventListener(''DOMContentLoaded'', () => console.log(''DOMContentLoaded''));
window.addEventListener(''load'', () => console.log(''load''));
```

setup.js는 HTML 파싱이 시작되고 10ms 만에 다운로드가 끝났으며, HTML 파싱은 50ms에 끝난다. photo.jpg는 3,000ms 뒤에야 도착한다.', 'OBJECTIVE'),
       (4197, 669, '아래 기록에서 페이지 B의 리소스 Y가 일으킨 현상을 가리키는 용어는?', '두 페이지는 body 내용이 같고, head에서 서로 다른 외부 리소스를 하나씩 불러온다. 그 밖의 리소스는 없다.

```
[페이지 A — head에 리소스 X]
    0ms  HTML 파싱 시작, X 요청 시작
1,800ms  X 응답 완료
1,810ms  HTML 파싱 완료, DOMContentLoaded 발생
1,850ms  첫 페인트

[페이지 B — head에 리소스 Y]
    0ms  HTML 파싱 시작, Y 요청 시작
  140ms  HTML 파싱 완료, DOMContentLoaded 발생
1,800ms  Y 응답 완료
1,840ms  첫 페인트
```', 'SUBJECTIVE'),
       (4198, 669, '아래 기록에서 변경 후 hero.webp의 img 태그에 추가된 속성의 이름은?', 'hero.webp는 첫 화면 맨 위에 놓인 가장 큰 이미지로, 이 페이지의 LCP(Largest Contentful Paint) 요소다. 변경 전 태그는 `<img src="hero.webp" alt="메인 배너">`였고, 변경 후에는 이 태그에 속성 하나만 추가됐다. 태그 위치·이미지 파일·head 설정은 바뀌지 않았다.

| 구분 | 요청 시작 | 요청 시 우선순위 | 레이아웃 후 우선순위 | 응답 완료 | LCP |
|---|---|---|---|---|---|
| 변경 전 | 420ms | Low | High | 1,880ms | 2,600ms |
| 변경 후 | 70ms | High | High | 1,040ms | 1,300ms |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4193
(11355, 4193, 'main.js는 async·defer가 없으므로 파서를 멈추고, 실행을 마친 뒤에야 body 파싱이 이어진다.', '속성이 없으면 동기 스크립트라고 본 오해다. type="module" 스크립트는 기본으로 defer처럼 동작해 파싱과 나란히 내려받고, 파싱이 끝난 뒤에 실행되므로 파서를 멈추지 않는다.', false),
(11356, 4193, '첫 번째 script의 defer가 효과를 내지 못해, div가 만들어지기 전에 코드가 곧바로 실행됐다.', 'defer·async는 src로 불러오는 외부 스크립트에만 효과가 있다. 인라인 스크립트에서는 무시돼 파서가 만나는 즉시 실행되므로, 아직 파싱되지 않은 body의 #app을 찾지 못해 null이 반환됐다.', true),
(11357, 4193, '첫 번째 script의 defer를 async로 바꾸면 파싱이 끝난 뒤 실행되어 이 오류가 사라진다.', '속성만 바꾸면 인라인 코드도 늦출 수 있다고 본 오해다. async도 인라인 스크립트에서는 무시되고, 외부 스크립트라 해도 async는 파싱 완료가 아니라 도착하는 즉시 실행된다.', false),
(11358, 4193, 'main.js 안에서 같은 코드로 #app을 조회해도 이 문서에서는 똑같이 null 오류가 난다.', 'head에 있으니 main.js도 body보다 먼저 실행된다고 본 오해다. 모듈 스크립트는 파싱이 끝난 뒤 실행되므로, 그 시점에는 body의 #app까지 DOM에 만들어져 있어 조회에 성공한다.', false),

-- 문제 4194
(11359, 4194, '0ms', '이름에 든 prefetch 때문에 폰트 파일까지 미리 받아 둔다고 본 오해다. dns-prefetch는 도메인 이름을 IP 주소로 바꾸는 조회만 앞당길 뿐, 연결을 맺거나 파일을 내려받지 않는다.', false),
(11360, 4194, '140ms', 'preconnect와 혼동한 오해다. DNS 조회·TCP 연결·TLS 핸드셰이크를 모두 미리 끝내 두는 것은 preconnect이고, dns-prefetch는 그중 DNS 조회만 수행한다.', false),
(11361, 4194, '300ms', 'DNS 조회에 이어 TCP 연결까지 미리 맺어 둔다고 본 오해다. dns-prefetch는 연결을 열지 않으므로 TCP 연결 110ms와 TLS 핸드셰이크 160ms가 요청 시점에 그대로 남는다.', false),
(11362, 4194, '410ms', 'dns-prefetch는 DNS 조회만 미리 해 두므로 90ms만 빠진다. TCP 연결 110ms + TLS 핸드셰이크 160ms + 다운로드 140ms = 410ms다. 곧 연결할 것이 확실한 출처라면 preconnect로 연결 비용까지 앞당길 수 있다.', true),

-- 문제 4195
(11363, 4195, '외부 CSS 파일의 background-image로 지정한 이미지는 이 과정에서 발견되지 않아 요청이 늦게 시작된다.', '보조 파서(프리로드 스캐너)는 HTML 마크업만 훑는다. CSS 파일 속 URL은 CSS를 내려받아 파싱하고 요소에 스타일을 적용해야 드러나 발견이 늦으므로, 중요한 이미지라면 preload로 요청을 앞당긴다.', true),
(11364, 4195, '앞서 훑은 태그로 DOM 노드까지 미리 만들어 두어, 메인 파서가 재개되면 그 구간을 건너뛴다.', '미리 훑는 과정이 DOM 구성까지 대신한다고 본 오해다. 보조 파서는 리소스 URL을 찾아 요청만 먼저 띄울 뿐이고, DOM은 메인 파서가 재개된 뒤 차례대로 직접 만든다.', false),
(11365, 4195, '앞서 찾아낸 스크립트는 다운로드가 끝나는 즉시 실행되어 메인 파서의 대기 시간이 줄어든다.', '미리 받는 것과 미리 실행하는 것을 혼동한 오해다. 보조 파서는 파일을 먼저 내려받아 둘 뿐이고, 실행은 메인 파서가 그 태그에 도달한 뒤 async·defer 여부에 따라 이뤄진다.', false),
(11366, 4195, '스크립트 코드 속 document.createElement로 삽입될 script도 코드를 읽어 미리 요청한다.', '스크립트 내용까지 분석한다고 본 오해다. 보조 파서는 스크립트를 해석하거나 실행하지 않으므로, 코드가 실행되면서 동적으로 넣는 리소스는 실제로 실행되기 전까지 발견되지 않는다.', false),

-- 문제 4196
(11367, 4196, 'defer → inline → DOMContentLoaded → load', 'setup.js가 10ms에 도착했고 문서에서도 앞서 있으니 먼저 실행된다고 본 오해다. defer 스크립트는 일찍 도착해도 HTML 파싱이 끝나는 50ms까지 기다리므로, 파싱 도중 실행되는 인라인 스크립트가 먼저 찍힌다.', false),
(11368, 4196, 'inline → DOMContentLoaded → defer → load', 'defer 스크립트가 DOMContentLoaded 뒤에 실행된다고 본 오해다. DOMContentLoaded는 HTML 파싱이 끝나고 defer 스크립트 실행까지 모두 마친 다음에 발생하므로 defer가 먼저 찍힌다.', false),
(11369, 4196, 'inline → defer → DOMContentLoaded → load', '인라인 스크립트는 파서가 만나는 즉시 실행된다. setup.js는 파싱이 끝나는 50ms 시점에 실행되며 두 리스너를 걸고, 이어서 DOMContentLoaded가 발생한다. load는 3,000ms 뒤 photo.jpg까지 도착해야 발생한다.', true),
(11370, 4196, 'inline → defer → load', 'defer 스크립트에서 건 DOMContentLoaded 리스너가 이미 지난 이벤트를 놓친다고 본 오해다. 이 이벤트는 defer 실행이 끝난 뒤 발생하므로 리스너가 제때 호출된다. 놓칠 수 있는 쪽은 늦게 실행되는 async 스크립트다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1354, 4197, '렌더링 차단,렌더 차단,렌더링차단,렌더차단,렌더링 블로킹,렌더 블로킹,렌더링블로킹,렌더블로킹,렌더링 차단 리소스,render blocking,render-blocking,renderblocking,render-blocking resource', '페이지 B는 140ms에 HTML 파싱이 끝나 DOMContentLoaded까지 발생했는데도, Y의 응답이 도착한 1,800ms 이후에야 첫 페인트가 일어났다. DOM 구성은 막지 않고 화면 그리기만 막는 이런 성질이 렌더링 차단이며, 대표적인 예가 head의 스타일시트다. CSSOM이 완성돼야 렌더 트리를 만들 수 있기 때문이다. 반면 페이지 A는 X의 응답이 올 때까지 HTML 파싱 자체가 멈춰 DOMContentLoaded도 1,810ms로 밀렸다. 이것은 동기 스크립트가 일으키는 파서 차단으로, 렌더링 차단과 구분해야 한다. 참고로 스타일시트 뒤에 동기 스크립트가 오면 그 스크립트가 CSSOM 완성을 기다리는 동안 파서까지 간접적으로 멈춘다. 렌더링 차단 시간은 첫 화면에 필요한 규칙만 style 태그로 인라인하거나, 현재 조건에 맞지 않는 스타일시트에 media를 지정해 줄일 수 있다.'),
       (1355, 4198, 'fetchpriority,fetch priority,fetch-priority,fetchpriority=high,fetchpriority="high",fetchpriority 속성,페치 프라이어리티,페치프라이어리티', 'fetchpriority="high"는 이 리소스를 다른 리소스보다 높은 우선순위로 요청하라고 브라우저에 알리는 속성이다. Chromium 계열 브라우저는 이미지를 Low 우선순위로 요청하고, 레이아웃이 끝나 뷰포트 안에 있다고 확인된 뒤에야 High로 올린다. Low 요청은 중요한 리소스가 처리되는 동안 뒤로 밀리기도 해서, 변경 전에는 요청이 420ms에야 출발하고 응답도 늦었다. 속성을 붙이자 처음부터 High로 요청돼 LCP가 2,600ms에서 1,300ms로 앞당겨졌다. 헷갈리는 옆 속성과 구분하면, loading="eager"는 이미 기본값이라 우선순위를 바꾸지 않고, decoding="async"는 내려받은 이미지의 디코딩이 메인 스레드를 막지 않게 할 뿐 네트워크 우선순위와는 무관하다. link rel="preload"는 img 태그의 속성이 아니라 head에 두는 별도 힌트로, CSS 배경 이미지처럼 늦게 발견되는 리소스를 앞당길 때 쓴다. 반대로 첫 화면의 가장 큰 이미지에 loading="lazy"를 붙이면 요청이 늦어져 LCP가 나빠진다.');

-- =====================================================
-- Lesson 827: 늦게 발견되는 리소스와 prefetch
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5141, 827, '아래 변경을 적용한 뒤 Pretendard.woff2의 응답이 완료되는 시각은?', '변경 전 네트워크 기록이다. 모든 시각은 index.html 요청 시점을 0ms로 잰 값이다.

```
    0ms  index.html 요청 시작
  120ms  index.html 응답 완료, HTML 파싱 시작
  120ms  app.css 요청 시작
  520ms  app.css 응답 완료, CSSOM 완성
  520ms  Pretendard.woff2 요청 시작
  820ms  Pretendard.woff2 응답 완료
```

Pretendard.woff2는 app.css 안에 @font-face로 선언한 웹 폰트다. head의 스타일시트 link 앞에 아래 한 줄을 추가했고 다른 변경은 없다. 각 파일을 내려받는 데 걸리는 시간은 변경 전과 같다.

```html
<link rel="preload" href="/fonts/Pretendard.woff2" as="font" type="font/woff2" crossorigin>
```', 'OBJECTIVE'),
       (5142, 827, '아래 문서를 열었을 때의 이미지 로딩 동작으로 옳은 것은?', '```html
<body>
  <img class="hero" src="hero-1200.webp"
       srcset="hero-480.webp 480w, hero-1200.webp 1200w"
       sizes="100vw" fetchpriority="high" alt="메인 배너">

  <!-- 아래 상품 이미지 40장은 모두 같은 형태다 -->
  <img class="item" src="item-01.webp" loading="lazy" decoding="async" alt="상품 1">
  <img class="item" src="item-02.webp" loading="lazy" decoding="async" alt="상품 2">
</body>
```

접속 기기의 뷰포트 폭은 480 CSS 픽셀이고 화면 배율(DPR)은 1이다. hero는 첫 화면 맨 위에 놓인 가장 큰 요소이며, 상품 이미지 40장은 모두 스크롤해야 보이는 위치에 있다.', 'OBJECTIVE'),
       (5143, 827, '아래 스크립트 구성에 대한 설명으로 옳지 않은 것은?', '| 파일 | 위치와 속성 | 하는 일 |
|---|---|---|
| polyfill.js | head, 속성 없음 | 구형 브라우저 보정 |
| vendor.js | head, defer | 차트 라이브러리 |
| app.js | head, defer (vendor.js 바로 뒤) | 차트를 body의 div에 그림 |
| metrics.js | head, async | 방문 기록 전송 |

네 파일 모두 src로 불러오는 외부 스크립트이고, 파일 크기와 응답 시간은 서로 다르다. body에는 차트를 그릴 div가 들어 있다.', 'OBJECTIVE'),
       (5144, 827, '아래 문서의 첫 화면 로딩에 대한 설명으로 옳은 것은?', '```html
<head>
  <link rel="stylesheet" href="app.css">
</head>
```

```css
/* app.css */
@import url("theme.css");
.hero { background-image: url("/img/bg.webp"); }
```

```
    0ms  HTML 파싱 시작, app.css 요청 시작
   40ms  HTML 파싱 완료
  300ms  app.css 응답 완료
  300ms  theme.css 요청 시작
  640ms  theme.css 응답 완료, CSSOM 완성
  650ms  첫 페인트
  650ms  bg.webp 요청 시작
1,020ms  bg.webp 응답 완료, 배경이 나타남
```

문서에는 위 두 스타일시트와 배경 이미지 말고 다른 외부 리소스가 없다.', 'OBJECTIVE'),
       (5145, 827, '아래 변경에서 head에 추가한 link 태그의 rel 값은?', '```
[변경 전 — 상품 목록 화면]
      0ms  문서 요청
  1,150ms  LCP
   (이후)  결제 버튼 클릭 → checkout.chunk.js 요청 시작 → 1,240ms 뒤 결제 화면 표시

[변경 후 — 상품 목록 화면]
      0ms  문서 요청
  1,150ms  LCP (변경 전과 같음)
  1,900ms  checkout.chunk.js 요청 시작, 요청 우선순위 Lowest
  2,600ms  checkout.chunk.js 응답 완료
   (이후)  결제 버튼 클릭 → 180ms 뒤 결제 화면 표시
```

상품 목록 화면은 checkout.chunk.js를 한 줄도 쓰지 않으며, 콘솔에는 아무 경고도 뜨지 않았다. head에 link 태그 한 줄을 추가한 것 말고 다른 변경은 없다.', 'SUBJECTIVE'),
       (5146, 827, '아래 3차 시도에서 script 태그에 추가한 속성의 이름은?', '방문 기록을 보내는 analytics.js의 배치를 세 번 바꾸며 측정한 기록이다.

```
[1차] head에 <script src="analytics.js"></script>
  HTML 파싱 완료 940ms, 첫 페인트 1,020ms
  → 화면이 한참 비어 있다는 제보가 들어왔다.

[2차] 같은 태그를 body 맨 끝으로 옮김
  HTML 파싱 완료 150ms, 첫 페인트 260ms
  analytics.js 요청 시작 150ms, 실행 1,050ms
  → 첫 화면은 빨라졌지만 금방 떠나는 방문의 측정 누락이 늘었다.

[3차] 태그를 다시 head로 되돌리고 속성 하나만 추가
  HTML 파싱 완료 150ms, 첫 페인트 260ms
  analytics.js 요청 시작 5ms
  → 실행 시점이 접속마다 달라 DOMContentLoaded보다 앞서기도 하고 늦기도 했다.
```

analytics.js는 다른 스크립트에 기대지 않고 혼자 동작하며, 실행 순서가 중요하지 않다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5141
(13883, 5141, '120ms', '요청이 나가는 시각과 파일을 다 받은 시각을 같게 본 계산이다. preload는 요청을 언제 시작할지를 앞당길 뿐이고, 변경 전 520ms에서 820ms까지 걸리던 폰트 다운로드 300ms는 그대로 필요하다.', false),
(13884, 5141, '420ms', 'preload는 CSS를 받아 파싱해 폰트 규칙을 찾을 때까지 기다리지 않고, 파서가 head를 읽는 120ms에 바로 요청을 띄운다. 다운로드에 드는 300ms는 그대로여서 120ms + 300ms = 420ms에 응답이 끝난다.', true),
(13885, 5141, '520ms', 'preload를 걸어도 그 폰트를 쓰는 텍스트가 렌더 트리에 잡혀야 요청이 나간다고 본 오해다. preload는 CSSOM·렌더 트리와 무관하게 URL만 보고 즉시 내려받으라는 지시라, CSSOM 완성 시점보다 먼저 끝난다.', false),
(13886, 5141, '820ms', 'preload를 prefetch처럼 본 오해다. prefetch는 다음 화면에 쓸 파일을 낮은 우선순위로 나중에 받지만, preload는 지금 이 화면에 곧 필요한 리소스를 당장 높은 우선순위로 받으라는 힌트라 발견 시점이 앞당겨진다.', false),

-- 문제 5142
(13887, 5142, '상품 이미지 40장도 스크롤 전에 모두 요청되고, 디코딩만 뒤로 미뤄져 메인 스레드를 막지 않는다.', 'loading과 decoding을 뒤섞은 오해다. loading="lazy"는 뷰포트 근처에 올 때까지 요청 자체를 미루고, decoding="async"는 이미 내려받은 이미지를 화면에 올릴 때 메인 스레드를 막지 않게 할 뿐이다.', false),
(13888, 5142, 'hero는 srcset에 적힌 후보 두 장을 모두 내려받은 뒤 화면 폭에 맞는 한 장을 골라 그린다.', '후보가 전부 전송된다고 본 오해다. 브라우저는 요청을 내기 전에 sizes로 계산한 표시 폭과 화면 배율을 따져 후보 하나를 고르고, 그 파일만 요청한다. 전송량을 줄이는 것이 srcset을 쓰는 이유다.', false),
(13889, 5142, 'hero는 sizes가 100vw라 표시 폭이 480 CSS 픽셀로 계산돼 hero-480.webp 한 장만 요청된다.', 'sizes="100vw"는 이 이미지가 뷰포트 폭만큼 표시된다는 뜻이다. 뷰포트 480 CSS 픽셀에 배율 1이므로 필요한 실제 폭은 480픽셀이고, 480w 후보가 이를 채우므로 hero-1200.webp는 내려받지 않는다.', true),
(13890, 5142, 'hero의 loading 속성도 lazy로 바꾸면 첫 화면 전송량이 줄어 LCP가 더 빨라진다.', '지연 로딩을 첫 화면에 적용한 오용이다. 가장 큰 요소인 hero의 요청이 뷰포트 판정 뒤로 밀려 발견과 다운로드가 늦어지므로 LCP는 오히려 나빠진다. lazy는 첫 화면 밖 이미지에 쓰는 장치다.', false),

-- 문제 5143
(13891, 5143, 'metrics.js는 문서에서 app.js보다 뒤에 있으므로 app.js 실행이 끝난 뒤에 실행된다.', '거짓이라 고를 선지다. async 스크립트는 문서 순서와 무관하게 다운로드가 끝나는 즉시 실행된다. 파일이 작아 먼저 도착하면 defer인 vendor.js·app.js보다 앞설 수 있어 실행 순서가 정해지지 않는다.', true),
(13892, 5143, 'polyfill.js를 내려받아 실행하는 동안 파서가 멈춰, body의 div가 만들어지는 시점도 그만큼 밀린다.', '참이다. 속성이 없는 스크립트는 document.write로 DOM을 바꿀 수 있어 브라우저가 파싱을 멈추고 다운로드와 실행을 먼저 끝낸다. 그동안 뒤쪽 태그는 DOM으로 만들어지지 않는다.', false),
(13893, 5143, 'app.js가 vendor.js보다 먼저 도착하더라도 vendor.js 실행이 끝난 뒤에 실행된다.', '참이다. defer는 도착 순서가 아니라 문서에 적힌 순서대로 실행하므로, 라이브러리와 그것을 쓰는 코드를 두 파일로 나눠도 순서가 뒤집히지 않는다.', false),
(13894, 5143, 'app.js는 head에 적혀 있지만 body의 div를 찾아 차트를 그릴 수 있다.', '참이다. defer 스크립트는 HTML 파싱이 모두 끝난 뒤 DOMContentLoaded 직전에 실행되므로, 태그가 head에 있어도 실행 시점에는 body까지 DOM이 갖춰져 있다.', false),

-- 문제 5144
(13895, 5144, 'theme.css도 app.css와 함께 head에서 발견되므로, 두 파일을 나란히 받고도 첫 페인트가 650ms까지 밀렸다.', '프리로드 스캐너가 CSS 파일 속 @import까지 미리 찾아 준다고 본 오해다. 기록처럼 theme.css 요청은 app.css를 받아 파싱한 300ms에야 시작됐고, 두 다운로드가 앞뒤로 이어지며 첫 페인트가 밀렸다.', false),
(13896, 5144, '첫 페인트가 늦은 것은 두 스타일시트가 파서를 멈춰 세워 DOM 구성이 지연됐기 때문이다.', '파서 차단과 렌더링 차단을 혼동한 오해다. 기록의 HTML 파싱이 40ms에 끝난 데서 보듯 스타일시트는 DOM 구성을 막지 않는다. 다만 CSSOM이 완성돼야 렌더 트리를 만들 수 있어 화면 그리기만 늦어진다.', false),
(13897, 5144, 'bg.webp가 첫 페인트를 막고 있으므로, 이 이미지를 preload하면 첫 페인트도 650ms보다 앞당겨진다.', '배경 이미지가 화면 그리기를 막는다고 본 오해다. 이미지는 도착하면 그 영역만 다시 그릴 뿐 첫 페인트를 막지 않는다. preload는 650ms에야 시작되는 발견을 앞당겨 배경이 늦게 나타나는 문제를 줄여 준다.', false),
(13898, 5144, 'app.css의 @import를 지우고 theme.css도 head의 link로 적으면 첫 페인트가 650ms보다 앞당겨진다.', '@import로 적은 파일은 CSS를 받아 파싱해야 드러나 요청이 한 단계 뒤로 밀린다. 두 스타일시트를 모두 HTML의 link로 적으면 프리로드 스캐너가 0ms에 함께 찾아 병렬로 받으므로, 이어 붙던 두 다운로드가 겹쳐진다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1670, 5145, 'prefetch,rel="prefetch",rel=prefetch,link rel="prefetch",프리페치,프리 페치,pre-fetch', '변경 후 checkout.chunk.js는 상품 목록 화면의 LCP가 끝난 뒤인 1,900ms에, 그것도 Lowest 우선순위로 요청됐다. 지금 화면에서 한 줄도 쓰지 않는 파일을 남는 시간에 미리 받아 두었다가 다음 화면 이동을 1,240ms에서 180ms로 줄인 것이 prefetch다. 헷갈리는 옆 힌트와 경계를 그으면, preload는 지금 이 화면에 곧 필요한 리소스를 높은 우선순위로 당장 받으라는 강한 지시라 요청이 즉시 나가고 3초 안에 쓰이지 않으면 콘솔 경고가 뜬다. 기록에서 요청이 1,900ms로 늦고 우선순위가 가장 낮으며 경고도 없었다는 점이 preload가 아니라는 단서다. preconnect는 DNS 조회·TCP 연결·TLS 핸드셰이크만 미리 끝내 둘 뿐 파일 본문을 받지 않고, dns-prefetch는 그중 DNS 조회만 한다. 이름은 비슷해도 파일을 실제로 내려받는 쪽은 prefetch다. 다만 남발하면 쓰지 않을 파일로 대역폭과 데이터를 낭비하므로, 다음 단계로 이어질 가능성이 높은 화면에만 건다.'),
       (1671, 5146, 'async,async 속성,async="async",비동기 속성', '3차 기록에는 두 가지가 함께 나타난다. 요청이 5ms에 시작돼 다운로드가 HTML 파싱과 나란히 진행됐고, 실행 시점이 접속마다 흔들려 DOMContentLoaded 앞뒤 어느 쪽으로도 갈 수 있었다. 이 둘을 동시에 만족하는 속성은 async다. async 스크립트는 파서를 멈추지 않고 병렬로 내려받다가 도착하는 즉시 실행하므로, 실행 시점이 네트워크 속도에 좌우된다. defer와 경계를 그으면, defer도 병렬로 내려받지만 실행은 늘 HTML 파싱이 끝난 뒤 DOMContentLoaded 직전이고 문서에 적힌 순서까지 보장한다. 그래서 defer였다면 실행 시점이 접속마다 흔들리지 않는다. 2차 시도처럼 동기 스크립트를 body 맨 끝에 두면 파서는 막지 않지만 파서가 그 태그에 닿아야 다운로드가 시작돼 실행이 늦고, 그래서 금방 떠나는 방문에서 측정이 빠졌다. analytics.js처럼 다른 코드에 기대지 않고 순서도 상관없는 스크립트에는 async를, DOM을 다루고 실행 순서가 중요한 앱 번들에는 defer를 쓴다. 한편 async 스크립트 안에서 DOMContentLoaded 리스너를 걸면 이미 지나간 뒤일 수 있으므로 document.readyState를 확인하는 방어 코드가 필요하다.');
