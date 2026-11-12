-- Unit: 동일 출처 정책과 CORS (Unit ID: 88)
-- Chapter: Web (Chapter ID: 7)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (514, 88, '출처 판별과 단순 요청, 헤더 노출'),
       (672, 88, '정책 차단 범위와 프리플라이트 캐시'),
       (830, 88, '브라우저 검사 주체와 리버스 프록시');

-- =====================================================
-- Lesson 514: 출처 판별과 단순 요청, 헤더 노출
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3263, 514, '아래 서버 설정에서 응답 본문을 정상적으로 읽을 수 있는 요청 페이지는?', 'API 서버 https://api.example.com/users는 요청의 Origin 헤더를 아래 목록과 대조해, 일치할 때만 Access-Control-Allow-Origin 헤더를 응답에 넣는다.

```javascript
const ALLOWED = new Set([''https://app.example.com'']);
```

네 개의 브라우저 탭이 각자 열린 페이지의 스크립트로 https://api.example.com/users에 fetch를 보냈다.', 'OBJECTIVE'),
       (3264, 514, '아래 실행 결과에 대한 설명으로 옳은 것은?', 'https://blog.com 페이지의 스크립트가 아래 요청을 보냈다.

```javascript
await fetch(''https://api.io/visits'', {
  method: ''POST'',
  headers: { ''Content-Type'': ''text/plain'' },
  body: ''1'',
});
```

콘솔에는 응답을 읽을 수 없다는 CORS 에러가 떴다. 그런데 같은 시각 api.io 액세스 로그에는 `POST /visits 200 12ms` 한 줄이 남았고, visits 집계 값도 1 늘어 있었다.', 'OBJECTIVE'),
       (3265, 514, '아래 크로스 출처 요청이 실패한 원인으로 옳은 것은?', 'https://app.com 화면에서 https://api.io/me를 부르며 로그인 쿠키를 함께 보내려 했다.

```javascript
const res = await fetch(''https://api.io/me'', { credentials: ''include'' });
```

서버가 돌려준 응답 헤더는 아래와 같았고, 브라우저는 응답을 읽지 못한 채 콘솔에 CORS 에러를 남겼다.

```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Content-Type: application/json
```', 'OBJECTIVE'),
       (3266, 514, '아래 비교표를 바탕으로 옳지 않은 것은?', 'CORS 에러를 없애려고 검토한 방법을 정리한 표다.

| 방법 | 적용 위치 | 배포 환경에 적용되는가 |
| --- | --- | --- |
| 서버가 허용 목록과 대조해 Access-Control-Allow-Origin을 응답에 넣음 | 백엔드 | 예 |
| nginx가 /api 요청을 내부 API 서버로 전달해 같은 출처로 서빙 | 인프라 | 예 |
| 프론트엔드 개발 서버의 proxy 옵션 | 로컬 개발 서버 | 아니오 |
| 브라우저 보안 검사를 끄는 확장 프로그램 설치 | 개발자 PC | 아니오 |', 'OBJECTIVE'),
       (3267, 514, '아래 로그에서 PUT보다 먼저 오간 요청을 가리키는 이름은?', 'https://app.com 화면에서 주문을 수정하려고 https://api.io/orders/12로 PUT을 보내자 콘솔에 CORS 에러가 났다. 그때 api.io 액세스 로그에는 아래 한 줄만 남아 있었다.

```
OPTIONS /orders/12 401 3ms
```

토큰 검사 미들웨어를 라우터 앞이 아니라 뒤로 옮기자 로그가 아래처럼 바뀌었고 화면도 정상 동작했다.

```
OPTIONS /orders/12 204 2ms
PUT /orders/12 200 41ms
```', 'SUBJECTIVE'),
       (3268, 514, '아래 상황에서 서버가 응답에 추가한 헤더의 이름은?', '목록 API는 전체 건수를 응답 헤더 X-Total-Count에 담아 보낸다. 같은 출처에서 열었을 때는 아래 코드가 1284를 찍는데, https://app.com 화면에서 https://api.io를 부를 때는 같은 코드가 null을 찍는다.

```javascript
console.log(res.headers.get(''x-total-count''));
```

개발자 도구 네트워크 탭에는 응답에 X-Total-Count: 1284가 분명히 찍혀 있고, Content-Type은 같은 방식으로 잘 읽힌다. 서버 응답에 헤더 한 줄을 더하자 곧바로 1284가 찍혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3263
(8875, 3263, 'http://app.example.com/dashboard', '스킴이 http라 목록의 https 값과 다른 출처다. 출처는 스킴·호스트·포트를 묶어 비교하므로 프로토콜 하나만 달라도 허용 헤더를 받지 못한다.', false),
(8876, 3263, 'https://app.example.com:8443/dashboard', '포트가 8443이라 https 기본 포트 443을 쓰는 목록 값과 다른 출처다. 스킴과 호스트가 같아도 포트가 다르면 별개 출처로 본다.', false),
(8877, 3263, 'https://admin.app.example.com/dashboard', '서브도메인이 붙어 호스트 문자열이 달라졌으므로 다른 출처다. 상위 도메인이 같다고 해서 동일 출처가 되지는 않는다.', false),
(8878, 3263, 'https://app.example.com/reports/2026', '출처는 스킴·호스트·포트로만 정해지고 경로는 포함되지 않는다. 경로가 /reports/2026이어도 출처는 목록 값과 같아 허용 헤더를 받아 응답을 읽을 수 있다.', true),

-- 문제 3264
(8879, 3264, '콘솔에 에러가 떴으므로 브라우저가 요청을 보내지 않았고, 로그의 200은 다른 클라이언트가 남긴 기록이다.', 'CORS 에러는 요청 차단이 아니라 응답 읽기 거부다. 요청은 실제로 전송돼 서버가 처리했고, 집계 값이 1 늘어난 것이 그 증거다.', false),
(8880, 3264, 'Content-Type이 text/plain이라 OPTIONS 요청이 먼저 나갔고, 그 실패가 콘솔 에러의 원인이다.', 'text/plain은 폼으로도 보낼 수 있던 CORS 안전 목록 값이라 프리플라이트가 붙지 않는다. 로그에 OPTIONS 줄이 없는 것도 그 때문이다.', false),
(8881, 3264, '브라우저의 응답 차단으로는 이미 반영된 쓰기를 되돌릴 수 없으므로 CSRF 방어를 서버에 따로 둬야 한다.', '단순 요청은 서버에 도달해 부작용을 남긴 뒤 응답만 가려진다. CORS는 응답 열람을 통제할 뿐 쓰기를 막는 장치가 아니어서, 토큰 검증 같은 CSRF 대책이 별도로 필요하다.', true),
(8882, 3264, '서버가 Access-Control-Allow-Origin을 붙이면 이 요청은 아예 서버까지 오지 않게 된다.', '허용 헤더는 받은 응답을 스크립트에 넘길지만 결정한다. 헤더를 붙이면 콘솔 에러가 사라지고 응답을 읽게 될 뿐, 요청이 전송되고 처리되는 것은 그대로다.', false),

-- 문제 3265
(8883, 3265, '응답에 Vary: Origin이 없어 브라우저가 다른 출처용 캐시로 보고 폐기했다.', 'Vary: Origin은 CDN·브라우저 캐시가 출처별로 응답을 구분하게 하는 장치다. 빠지면 캐시가 섞여 간헐적 실패를 부를 수 있지만, 매번 실패하는 이번 상황의 원인은 아니다.', false),
(8884, 3265, '쿠키를 함께 보내는 요청에서는 허용 출처에 와일드카드를 둘 수 없어 요청 출처를 그대로 적어야 한다.', 'credentials가 붙은 요청은 Access-Control-Allow-Origin이 *이면 무조건 실패한다. 허용 목록과 대조한 뒤 https://app.com을 그대로 돌려주고 Vary: Origin을 함께 붙여야 한다.', true),
(8885, 3265, 'credentials 값 ''include''는 같은 출처 요청에만 적용돼 크로스 출처에서는 무시된다.', '기본값이 same-origin이고 include는 크로스 출처에도 쿠키를 붙이라는 지시다. 클라이언트 쪽 설정은 맞게 돼 있으므로 원인이 될 수 없다.', false),
(8886, 3265, 'Access-Control-Allow-Headers에 Cookie를 넣지 않아 브라우저가 쿠키 헤더를 떼고 보냈다.', 'Allow-Headers는 프리플라이트에서 개발자가 직접 지정한 요청 헤더를 허락하는 목록이다. 쿠키는 credentials 규칙이 다루므로 이 목록에 넣어서 풀리는 문제가 아니다.', false),

-- 문제 3266
(8887, 3266, '개발 서버의 proxy 옵션과 nginx 전달은 모두 배포 환경에서도 같은 출처를 만들어 주므로 서버 CORS 설정이 필요 없다.', 'nginx 전달은 배포 환경에 적용되지만 개발 서버 proxy는 로컬에서만 동작한다. 표의 마지막 열이 갈리는 이유이며, 로컬에서 에러가 사라져도 배포용 해결책은 따로 필요하다.', true),
(8888, 3266, 'nginx가 /api 요청을 내부 API 서버로 넘기면 브라우저에는 모든 요청이 한 출처로 보여 CORS 검사가 일어나지 않는다.', 'CORS는 출처가 다를 때만 개입한다. 정적 파일과 API가 같은 스킴·호스트·포트로 서빙되면 크로스 출처 자체가 성립하지 않아 헤더 협상이 필요 없다.', false),
(8889, 3266, '확장 프로그램으로 브라우저 보안 검사를 끄면 개발자 PC에서만 화면이 동작하고 사용자 환경은 달라지지 않는다.', '브라우저 설정 변경은 그 기기에만 남는다. 서버가 허용 헤더를 돌려주지 않는 한 다른 사용자에게는 같은 에러가 그대로 나므로 해결책이 아니다.', false),
(8890, 3266, '서버가 허용 목록과 대조하지 않고 요청 Origin을 그대로 돌려주면 사실상 모든 출처를 허용하는 설정이 된다.', '어떤 출처가 오든 그 값을 그대로 반영하면 브라우저 검사는 항상 통과한다. 쿠키까지 허용하면 임의의 사이트가 사용자 데이터를 읽을 수 있어 목록 대조가 필수다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1044, 3267, '프리플라이트,프리플라이트 요청,preflight,preflight request,사전 요청,예비 요청', '단순 요청 조건을 벗어난 크로스 출처 요청은 본 요청 전에 브라우저가 OPTIONS로 서버 허락을 먼저 확인하는데, 이 확인 요청이 프리플라이트다. 여기서는 PUT 메서드가 단순 요청 조건을 벗어나게 만든 원인이다. 프리플라이트에는 쿠키나 인증 헤더가 붙지 않으므로 토큰 검사 미들웨어를 라우터 앞에 두면 401이 나고, 프리플라이트 응답이 2xx가 아니면 본 요청은 아예 전송되지 않는다. 미들웨어를 뒤로 옮겨 204가 돌아오자 비로소 PUT이 나간 것이 그 흐름이다. 실제로 데이터를 바꾸는 PUT은 본 요청(actual request)이며, 브라우저가 자동으로 만들어 보내는 프리플라이트와 구분한다.'),
       (1045, 3268, 'Access-Control-Expose-Headers,Access Control Expose Headers,Expose-Headers,Expose Headers,ACEH', '크로스 출처 응답에서 스크립트가 그냥 읽을 수 있는 헤더는 Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma 정도로 제한된다. Content-Type이 잘 읽히고 X-Total-Count만 null인 것이 이 제한을 그대로 보여준다. 네트워크 탭에 값이 보이는 것은 브라우저가 응답을 받았다는 뜻일 뿐이고, 스크립트에 넘겨줄지는 서버가 Access-Control-Expose-Headers: X-Total-Count로 따로 허락해야 한다. 이름이 비슷한 Access-Control-Allow-Headers는 프리플라이트에서 브라우저가 보낼 요청 헤더를 허락하는 목록이라 방향이 반대다.');

-- =====================================================
-- Lesson 672: 정책 차단 범위와 프리플라이트 캐시
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4211, 672, '아래 네 동작 중 동일 출처 정책에 막혀 실패하는 것은?', '현재 열린 페이지는 https://app.example.com/home이고, 이 페이지의 스크립트가 아래 네 동작을 각각 따로 실행한다. cdn.example.com과 api.example.com은 CORS 관련 응답 헤더를 전혀 보내지 않는다.

```javascript
// (가)
const me = await (await fetch(''https://app.example.com:443/api/me'')).json();

// (나)
const img = document.createElement(''img'');
img.src = ''https://cdn.example.com/banner.png'';
document.body.append(img);

// (다)
const user = await (await fetch(''https://api.example.com/me'')).json();

// (라)
const form = document.createElement(''form'');
form.method = ''POST'';
form.action = ''https://api.example.com/logout'';
document.body.append(form);
form.submit();
```', 'OBJECTIVE'),
       (4212, 672, '아래 로그에서 (2) 요청에만 OPTIONS가 먼저 찍힌 원인으로 옳은 것은?', 'https://app.com 화면이 https://api.io로 요청 두 개를 차례로 보냈다.

```javascript
// (1) 장바구니에 상품 담기
await fetch(''https://api.io/cart/items'', {
  method: ''POST'',
  body: new URLSearchParams({ itemId: ''7'' }),
});

// (2) 담긴 상품 수량 바꾸기
await fetch(''https://api.io/cart/items'', {
  method: ''POST'',
  credentials: ''include'',
  headers: { ''Content-Type'': ''application/json'' },
  body: JSON.stringify({ itemId: 7, qty: 3 }),
});
```

api.io 액세스 로그에는 아래 순서로 남았다.

```
POST /cart/items 200 15ms
OPTIONS /cart/items 204 2ms
POST /cart/items 200 22ms
```', 'OBJECTIVE'),
       (4213, 672, '아래 CORS 해결 구성에 대한 설명으로 옳은 것은?', '팀이 직접 만든 프론트엔드 전용 서버를 배포 환경에서 화면과 같은 출처(https://app.com)로 서빙한다. 브라우저는 https://app.com/api/weather에만 요청하고, 이 서버가 자기 환경 변수에 둔 비밀 키를 붙여 외부 날씨 API(https://weather.io)를 호출한 뒤 화면에 필요한 필드만 골라 돌려준다.', 'OBJECTIVE'),
       (4214, 672, '아래 요청 기록에 대한 설명으로 옳은 것은?', 'https://api.io/products 앞에는 HTTP 표준 캐시 규칙대로 동작하는 CDN이 있다. api.io는 요청의 Origin이 허용 목록(https://a.com, https://b.com)에 있으면 그 값을 Access-Control-Allow-Origin에 그대로 넣어 응답하고, 응답에는 Cache-Control: public, max-age=300이 붙는다. 아래는 CDN을 거친 요청 기록이다.

| 시각 | 요청 Origin | CDN 캐시 | 받은 Access-Control-Allow-Origin | 화면 결과 |
| --- | --- | --- | --- | --- |
| 10:00:01 | https://a.com | MISS | https://a.com | 성공 |
| 10:00:07 | https://b.com | HIT | https://a.com | CORS 에러 |
| 10:02:40 | https://a.com | HIT | https://a.com | 성공 |
| 10:05:10 | https://b.com | MISS | https://b.com | 성공 |', 'OBJECTIVE'),
       (4215, 672, '아래 로그가 바뀌도록 서버가 OPTIONS 응답에 추가한 헤더의 이름은?', 'https://app.com 문서 편집 화면은 저장 버튼을 누를 때마다 https://api.io/docs/42로 Content-Type이 application/json인 PUT을 보낸다. 사용자가 13초 간격으로 저장을 누르자 api.io 로그가 아래처럼 찍혔다.

```
10:00:05 OPTIONS /docs/42 204 2ms
10:00:05 PUT     /docs/42 200 35ms
10:00:18 OPTIONS /docs/42 204 2ms
10:00:18 PUT     /docs/42 200 33ms
10:00:31 OPTIONS /docs/42 204 2ms
10:00:31 PUT     /docs/42 200 36ms
```

서버가 OPTIONS 응답에 헤더 한 줄을 추가한 뒤 같은 방식으로 저장을 이어 누르자 로그가 아래처럼 바뀌었고, 화면에서 잰 저장 한 번의 평균 대기 시간도 190ms에서 110ms로 줄었다.

```
10:20:05 OPTIONS /docs/42 204 2ms
10:20:05 PUT     /docs/42 200 34ms
10:20:18 PUT     /docs/42 200 32ms
10:20:31 PUT     /docs/42 200 35ms
(13초 간격으로 PUT만 이어짐)
10:30:16 OPTIONS /docs/42 204 2ms
10:30:16 PUT     /docs/42 200 36ms
```', 'SUBJECTIVE'),
       (4216, 672, '아래 상황에서 서버가 Set-Cookie에 추가한 쿠키 속성의 이름은?', 'https://app.com 화면이 로그인한 사용자 정보를 받으려고 https://api.io/me를 부른다. 로그인은 https://api.io/login 페이지에서 마쳤고, 이때 api.io가 내려준 쿠키는 아래와 같다.

```http
Set-Cookie: sid=9f2c1a; Path=/; Secure; HttpOnly
```

화면의 코드와 api.io의 응답 헤더는 아래와 같다. 콘솔에 CORS 에러는 없지만, api.io 서버 로그를 보면 이 요청에는 Cookie 헤더가 아예 실려 오지 않았다.

```javascript
const res = await fetch(''https://api.io/me'', { credentials: ''include'' });
console.log(res.status); // 401
```

```http
HTTP/1.1 401 Unauthorized
Access-Control-Allow-Origin: https://app.com
Access-Control-Allow-Credentials: true
Vary: Origin
```

같은 Chrome에서 주소창에 https://api.io/me를 직접 열면 쿠키가 실려 200이 온다. 서버가 위 Set-Cookie에 속성 하나를 추가하고 사용자가 다시 로그인하자, app.com 화면의 요청에도 쿠키가 실려 200이 찍혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4211
(11403, 4211, '(가)', 'https의 기본 포트가 443이라 :443을 적어도 출처는 https://app.example.com 그대로다. 포트 번호가 URL에 보인다고 다른 출처가 되지 않으므로 같은 출처 요청으로 응답을 읽을 수 있다.', false),
(11404, 4211, '(나)', '동일 출처 정책은 다른 출처 리소스를 가져와 브라우저가 화면에 표시하는 것까지 막지 않는다. img로 다른 호스트의 이미지를 띄우는 것은 허용되며, 막히는 것은 스크립트가 받은 내용을 읽으려 할 때다.', false),
(11405, 4211, '(다)', '호스트가 app과 api로 달라 다른 출처다. fetch로 받은 응답을 스크립트가 읽는 것은 동일 출처 정책이 막는 대상이고, 서버가 Access-Control-Allow-Origin으로 허용하지 않았으므로 fetch가 에러로 끝나 JSON을 얻지 못한다.', true),
(11406, 4211, '(라)', '폼 제출은 CORS가 생기기 전부터 다른 출처로 보낼 수 있던 요청이라 동일 출처 정책이 막지 않는다. 페이지가 api.example.com으로 이동하며 요청이 처리되고, 스크립트가 응답을 읽는 과정이 없어 차단할 대상도 없다.', false),

-- 문제 4212
(11407, 4212, 'credentials: ''include''로 쿠키를 함께 싣도록 해 프리플라이트 대상이 됐다.', 'credentials 설정은 프리플라이트 발생 조건이 아니다. 쿠키를 실어도 메서드·헤더·Content-Type이 단순 요청 조건 안이면 바로 전송되고, 대신 응답에 정확한 출처와 Access-Control-Allow-Credentials: true가 있어야 읽힌다.', false),
(11408, 4212, 'Content-Type 값이 HTML 폼으로는 보낼 수 없던 형식이라 프리플라이트 대상이 됐다.', 'application/json은 단순 요청이 허용하는 Content-Type(application/x-www-form-urlencoded·multipart/form-data·text/plain)에 없다. (1)의 URLSearchParams 본문은 urlencoded로 전송돼 조건 안이라 OPTIONS 없이 나갔다.', true),
(11409, 4212, 'headers 옵션으로 헤더를 직접 지정하면 값과 무관하게 프리플라이트 대상이 된다.', 'Content-Type은 값이 폼 형식 세 가지 중 하나면 CORS-안전 목록에 드는 헤더라 직접 적는 것 자체는 문제가 아니다. text/plain을 넣었다면 OPTIONS 없이 나갔을 것이며, 원인은 application/json이라는 값이다.', false),
(11410, 4212, '데이터를 바꾸는 POST 메서드를 써서 브라우저가 프리플라이트 대상으로 봤다.', 'POST는 GET·HEAD와 함께 단순 요청이 허용하는 메서드다. (1)도 POST인데 OPTIONS 없이 바로 찍힌 것이 그 증거이며, PUT·DELETE처럼 목록 밖 메서드였다면 그때 프리플라이트가 붙는다.', false),

-- 문제 4213
(11411, 4213, '브라우저가 weather.io의 응답을 직접 받으므로 weather.io의 CORS 허용 설정이 여전히 필요하다.', '브라우저가 요청하는 곳은 같은 출처의 app.com뿐이고 weather.io 호출은 서버끼리 이뤄진다. CORS는 브라우저가 검사하는 절차라 서버 간 통신에는 개입하지 않으므로 weather.io 쪽 설정은 필요 없다.', false),
(11412, 4213, '로컬 개발 환경에서만 통하는 방식이라 배포할 때는 별도의 CORS 해결책을 마련해야 한다.', '로컬에서만 유효한 것은 개발 서버의 proxy 설정이다. 이 구성은 배포 환경에서 실제로 서빙되는 서버가 외부 API를 대신 부르므로 운영에서도 그대로 동작하는 정식 해결이다.', false),
(11413, 4213, '사용자 요청이 외부 업체가 운영하는 중계 서버를 거치므로 쿠키·토큰이 제3자에게 노출된다.', '제3자 서버를 거쳐 인증 정보가 새는 것은 공개 CORS 프록시 서비스를 쓸 때의 위험이다. 여기서 중간 서버는 팀이 직접 만들어 운영하는 서버라 사용자 요청이 외부 업체 손을 거치지 않는다.', false),
(11414, 4213, 'weather.io가 CORS 응답 헤더를 전혀 보내지 않아도 화면은 날씨 데이터를 읽을 수 있다.', '브라우저는 같은 출처인 app.com의 응답만 읽으므로 CORS 검사가 일어나지 않고, weather.io 호출은 서버 간 통신이라 CORS가 없다. 이런 BFF(Backend for Frontend) 구성은 비밀 키도 브라우저에 두지 않는다.', true),

-- 문제 4214
(11415, 4214, '응답에 Vary: Origin을 붙이면 10:00:07 요청은 캐시에 적중하지 않고 b.com 값을 받는다.', 'Vary: Origin이 있으면 CDN이 Origin 값마다 캐시 항목을 따로 둔다. b.com의 첫 요청은 a.com용 항목에 적중하지 않아 원 서버로 가고, Access-Control-Allow-Origin: https://b.com이 담긴 응답을 받는다.', true),
(11416, 4214, '10:00:07 실패는 b.com이 허용 목록에 없어서 생겼으므로 목록에 b.com을 추가해야 한다.', 'b.com은 이미 허용 목록에 있고, 캐시가 만료된 10:05:10에는 원 서버가 b.com 값을 돌려줘 성공했다. 실패는 목록 판단이 아니라 a.com용으로 저장된 캐시 응답이 b.com에 그대로 전달된 탓이다.', false),
(11417, 4214, '서버가 목록 대조 없이 요청 Origin을 그대로 넣도록 바꾸면 10:00:07 같은 실패가 사라진다.', '10:00:07 요청은 CDN에서 HIT로 끝나 원 서버에 닿지 않았다. 반영 방식을 바꿔도 캐시에 박힌 a.com 값이 그대로 나가며, 대조 없는 반영은 쿠키 허용과 겹치면 아무 사이트나 사용자 데이터를 읽게 되는 위험한 우회다.', false),
(11418, 4214, 'max-age를 늘려 캐시를 오래 두면 두 출처용 응답이 함께 쌓여 이런 실패가 줄어든다.', 'Vary가 없으면 캐시가 출처를 구분하지 않아 /products 응답은 하나만 저장된다. 유지 시간을 늘리면 먼저 저장된 a.com 값이 더 오래 남아 b.com이 실패하는 구간이 오히려 길어진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1360, 4215, 'Access-Control-Max-Age,Access Control Max Age,AccessControlMaxAge,Max-Age,Max Age,ACMA,액세스 컨트롤 맥스 에이지', '프리플라이트 결과를 브라우저가 몇 초 동안 재사용할지 알려 주는 응답 헤더가 Access-Control-Max-Age다. 이 헤더가 없으면 명세상 기본 캐시 시간이 5초뿐이라, 13초 간격으로 저장할 때마다 OPTIONS가 다시 나갔다. OPTIONS 응답에 Access-Control-Max-Age: 600처럼 초 단위 값을 넣자 브라우저가 같은 URL·메서드·헤더 조합에 대한 허락을 10분 동안 기억해 PUT만 바로 보냈고, 10분이 지난 10:30:16에야 OPTIONS를 다시 보냈다. 요청마다 한 번씩 더 들던 왕복(RTT)이 빠져 대기 시간도 줄었다. 큰 값을 넣어도 브라우저별 상한(Chrome은 2시간)을 넘겨 캐시되지는 않는다. 이름이 비슷한 Cache-Control의 max-age는 응답 자체를 HTTP 캐시에 얼마나 둘지 정하는 값이라 프리플라이트 허락의 재사용과는 관계가 없고, Access-Control-Allow-Methods·Access-Control-Allow-Headers는 무엇을 허락할지 정할 뿐 그 허락을 얼마나 기억할지는 정하지 않는다.'),
       (1361, 4216, 'SameSite,SameSite=None,SameSite 속성,Same-Site,Same Site,세임사이트', 'Set-Cookie에 SameSite를 적지 않으면 Chrome은 Lax로 간주한다. Lax 쿠키는 주소창 입력 같은 최상위 이동에는 실리지만, 다른 사이트인 app.com 페이지가 fetch로 부르는 요청에는 실리지 않는다. 그래서 CORS 응답 헤더가 모두 맞는데도 Cookie 헤더가 빠져 401이 났고, SameSite=None을 명시하자 다른 사이트에서 보낸 요청에도 쿠키가 실렸다. None은 Secure가 함께 있어야 받아들여지는데 이 쿠키에는 이미 Secure가 있어 속성 하나만 더하면 됐다. credentials: ''include''와 Access-Control-Allow-Credentials: true는 쿠키를 실어 보내고 그 응답을 스크립트가 읽도록 허락하는 CORS 쪽 조건이고, SameSite는 쿠키가 다른 사이트 요청에 실릴지를 정하는 쿠키 쪽 조건이라 둘 다 갖춰야 한다. 스크립트의 쿠키 접근을 막는 HttpOnly, HTTPS 연결에서만 쿠키를 보내게 하는 Secure와도 구분한다.');

-- =====================================================
-- Lesson 830: 브라우저 검사 주체와 리버스 프록시
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5159, 830, '아래 세 가지 호출 결과에 대한 설명으로 옳은 것은?', 'https://api.io/orders를 같은 시각에 세 가지 방법으로 불러 결과를 정리한 표다. api.io는 어떤 응답에도 Access-Control-로 시작하는 헤더를 넣지 않으며, 세 호출 모두 api.io 액세스 로그에 GET /orders 200으로 남았다.

| 호출 방법 | 응답 본문을 손에 넣었는가 |
| --- | --- |
| 개발자 PC 터미널에서 curl로 호출 | 예 |
| 사내 배치 서버의 Node.js 코드에서 호출 | 예 |
| https://app.com 페이지의 스크립트가 fetch로 호출 | 아니오, 콘솔에 CORS 에러 |', 'OBJECTIVE'),
       (5160, 830, '아래 네 요청 가운데 브라우저가 OPTIONS 요청을 먼저 보내는 것은?', 'https://app.com 페이지의 스크립트가 https://api.io로 아래 네 요청을 각각 따로 보낸다. 네 요청 모두 api.io가 정상 처리할 수 있는 요청이다.

```javascript
// (가)
await fetch(''https://api.io/search?q=cors'');

// (나)
await fetch(''https://api.io/subscribe'', {
  method: ''POST'',
  headers: { ''Content-Type'': ''text/plain'' },
  body: ''me@app.com'',
});

// (다)
await fetch(''https://api.io/uploads'', {
  method: ''POST'',
  body: new FormData(document.querySelector(''#upload-form'')),
});

// (라)
await fetch(''https://api.io/orders'', {
  method: ''POST'',
  headers: {
    ''Content-Type'': ''application/x-www-form-urlencoded'',
    ''X-Request-Id'': ''a91f3c'',
  },
  body: ''itemId=7'',
});
```', 'OBJECTIVE'),
       (5161, 830, '아래 요청이 콘솔 에러로 끝난 원인으로 옳은 것은?', 'https://app.com 화면이 로그인 상태를 확인하려고 아래 요청을 보냈다.

```javascript
const res = await fetch(''https://api.io/me'', { credentials: ''include'' });
```

api.io 액세스 로그에는 쿠키가 실려 와 세션까지 찾았다고 남았다.

```
GET /me 200 8ms  cookie=sid=9f2c1a  user=u_204
```

브라우저 네트워크 탭에도 사용자 정보가 담긴 200 응답이 그대로 보이는데, 스크립트는 응답을 읽지 못하고 콘솔에 CORS 에러가 남았다. 서버가 돌려준 응답 헤더는 아래가 전부다.

```http
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.com
Vary: Origin
Content-Type: application/json
```', 'OBJECTIVE'),
       (5162, 830, '아래 서버 설정에 대한 설명으로 옳은 것은?', 'api.io 팀은 여러 프론트엔드에서 CORS 에러가 난다는 신고를 받고 미들웨어를 아래처럼 고쳤고, 그 뒤로 신고가 사라졌다.

```typescript
app.use((req, res, next) => {
  res.setHeader(''Access-Control-Allow-Origin'', req.headers.origin ?? ''*'');
  res.setHeader(''Access-Control-Allow-Credentials'', ''true'');
  next();
});
```

api.io는 로그인 세션을 쿠키로 관리하고, 그 쿠키에는 SameSite=None; Secure가 붙어 있다. /me·/orders 같은 엔드포인트는 이 쿠키만 보고 사용자 데이터를 돌려준다.', 'OBJECTIVE'),
       (5163, 830, '아래 변경에서 CORS 에러 자체가 생기지 않게 만든 서버 구성의 이름은?', '전에는 화면을 https://app.com이, API를 https://api.internal.io가 맡았고 브라우저 콘솔에 CORS 에러가 자주 떴다. 서버의 허용 출처 목록은 그대로 둔 채 앞단 웹 서버에 아래 설정을 넣고 배포하자 에러가 사라졌다.

```nginx
server {
  server_name app.com;

  location / {
    root /var/www/app;                       # 정적 파일
  }

  location /api/ {
    proxy_pass http://api-internal:8080/;    # 내부 API 서버로 전달
  }
}
```

화면 코드에서는 fetch 주소를 https://api.internal.io/users에서 /api/users로 바꿨다. 개발자 도구 네트워크 탭에는 요청이 https://app.com/api/users로 찍히고, 요청 헤더에서 Origin 줄도 사라졌다.', 'SUBJECTIVE'),
       (5164, 830, '아래에서 서버가 값을 빠뜨렸던 응답 헤더의 이름은?', 'https://app.com 관리 화면은 https://api.io/posts/31로 조회(GET)·수정(PUT)·삭제(DELETE)를 보내고, 모든 요청에 Authorization 헤더를 붙인다. 조회와 수정은 잘 되는데 삭제 버튼만 콘솔에 CORS 에러가 나고, api.io 액세스 로그에는 DELETE 줄이 아예 남지 않는다. 삭제를 눌렀을 때 오간 내용은 아래와 같다.

```http
OPTIONS /posts/31
Origin: https://app.com
Access-Control-Request-Method: DELETE
Access-Control-Request-Headers: authorization

204 No Content
Access-Control-Allow-Origin: https://app.com
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Methods: GET, POST, PUT
```

서버 설정에서 허용 목록 한 곳에 DELETE를 추가하자 로그에 DELETE 줄이 찍히고 삭제도 정상 동작했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5159
(13931, 5159, '앞의 두 호출이 성공한 것은 api.io가 그 두 호출의 출처를 허용 목록에 넣어 뒀기 때문이다.', '허용 목록에 넣었다면 응답에 Access-Control-Allow-Origin이 실려야 하는데 이 서버는 그 헤더를 아예 넣지 않는다. curl과 배치 서버 호출에는 출처를 알리는 Origin 헤더조차 붙지 않는다.', false),
(13932, 5159, '세 번째 호출도 응답 자체는 받았으므로, 콘솔 에러와 상관없이 fetch가 돌려준 객체에서 본문을 읽을 수 있다.', '브라우저는 허용 헤더가 없으면 받아 둔 응답을 폐기하고 fetch를 에러로 끝낸다. 네트워크 탭에 응답이 보여도 스크립트에는 넘어오지 않으므로 본문을 읽을 방법이 없다.', false),
(13933, 5159, '허용 헤더를 보고 응답을 넘길지 정하는 쪽은 브라우저뿐이라, 브라우저 밖에서 이뤄진 두 호출은 같은 응답을 그대로 쓴다.', 'CORS는 브라우저가 수행하는 검사다. curl이나 서버 간 호출에는 이 절차 자체가 없어 허용 헤더가 없어도 본문을 그대로 쓴다. 서버에서는 되는데 브라우저에서만 안 된다는 증상이 CORS 문제의 전형적인 모습이다.', true),
(13934, 5159, '세 번째 호출을 고치려면 페이지를 내려준 app.com이 자기 응답에 Access-Control-Allow-Origin을 붙여야 한다.', '허용 여부를 알리는 쪽은 요청을 받는 api.io다. app.com이 어떤 헤더를 붙여도 api.io 응답에 대한 브라우저 판정은 달라지지 않는다.', false),

-- 문제 5160
(13935, 5160, '(라)', 'Content-Type 값은 폼으로 보낼 수 있던 세 형식 중 하나라 문제가 없지만, 직접 붙인 X-Request-Id가 CORS 안전 목록 밖 헤더다. 목록 밖 헤더가 하나라도 있으면 브라우저가 OPTIONS로 허락을 먼저 확인한다.', true),
(13936, 5160, '(가)', '메서드가 GET이고 직접 설정한 헤더도 없어 단순 요청 조건을 모두 만족한다. 출처가 다르다는 사실만으로 프리플라이트가 붙지는 않는다.', false),
(13937, 5160, '(나)', 'POST는 단순 요청이 허용하는 메서드이고 text/plain도 허용되는 세 가지 Content-Type 중 하나다. 값이 폼 형식이면 Content-Type을 직접 적어도 조건 안에 남는다.', false),
(13938, 5160, '(다)', '본문으로 FormData를 주면 브라우저가 Content-Type을 multipart/form-data로 붙인다. 이 역시 폼으로 보낼 수 있던 형식이라 OPTIONS 없이 본 요청이 바로 나간다.', false),

-- 문제 5161
(13939, 5161, '응답에 Vary: Origin이 붙어 있어 브라우저가 이 응답을 다른 출처용으로 판단하고 폐기했다.', 'Vary: Origin은 캐시가 출처별로 응답을 따로 보관하게 하는 지시일 뿐 브라우저의 허용 판정에 쓰이는 값이 아니다. 출처마다 응답이 달라지는 서버라면 오히려 붙여 두는 편이 맞다.', false),
(13940, 5161, '쿠키를 싣는 요청은 반드시 프리플라이트를 거쳐야 하는데 로그에 OPTIONS가 없어 본 요청이 무효 처리됐다.', 'credentials 설정은 프리플라이트 발생 조건이 아니다. GET이고 직접 붙인 헤더도 없어 단순 요청 조건 안이므로 OPTIONS 없이 바로 나간 것이 정상 동작이다.', false),
(13941, 5161, '쿠키가 서버까지 갔으니 클라이언트 설정은 끝났고, 남은 원인은 세션 만료이므로 다시 로그인하면 해결된다.', '로그에 세션을 찾아 200을 돌려줬다고 남아 있어 인증은 이미 성공했다. 막힌 지점은 서버 처리가 아니라 받은 응답을 스크립트에 넘길지 정하는 브라우저 검사다.', false),
(13942, 5161, '쿠키를 실은 요청인데 응답에 Access-Control-Allow-Credentials가 없어, 허용 출처가 맞는데도 폐기됐다.', 'credentials 요청은 출처를 명시하는 것에 더해 이 헤더를 요구한다. 서버가 한 줄만 추가하면 같은 응답이 그대로 읽힌다. 쿠키를 실을지는 credentials: ''include''와 쿠키의 SameSite가 정하고, 읽게 할지는 이 헤더가 정한다.', true),

-- 문제 5162
(13943, 5162, '요청 Origin을 그대로 돌려주는 것은 허용 목록을 코드 밖으로 옮긴 것일 뿐이라, 브라우저 검사는 그대로 남고 신고만 없어진 것이다.', '어떤 값이 와도 그대로 반영하면 대조 단계가 사라져 검사는 항상 통과한다. 목록을 다른 곳에 옮겨 둔 것이 아니라 허용 여부를 판단하는 일 자체를 없앤 설정이다.', false),
(13944, 5162, '사용자가 로그인한 채로 아무 사이트나 열면 그 사이트의 스크립트가 api.io의 사용자 데이터를 읽어 갈 수 있다.', '악성 페이지의 출처도 그대로 반영되고 쿠키까지 허용되므로, 브라우저는 사용자 세션이 붙은 응답을 그 페이지 스크립트에 넘긴다. 허용 목록과 대조한 뒤에만 출처를 반영해야 하는 이유다.', true),
(13945, 5162, 'Access-Control-Allow-Origin에 구체적인 출처 값이 들어가므로 모든 요청이 단순 요청으로 처리돼 프리플라이트가 사라진다.', '프리플라이트 여부는 요청의 메서드·헤더·Content-Type이 정하지 응답 헤더 값이 정하지 않는다. 이 설정과 무관하게 PUT이나 CORS 안전 목록 밖 헤더에는 OPTIONS가 먼저 나간다.', false),
(13946, 5162, 'Vary: Origin을 함께 붙이지 않았으므로 브라우저가 출처를 구분하지 못해 크로스 출처 요청이 모두 실패한다.', 'Vary는 캐시가 출처별 응답을 뒤섞지 않게 하는 지시라, 빠지면 캐시가 낀 구간에서 간헐적으로만 문제가 생긴다. 캐시를 거치지 않는 요청은 그대로 통과한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1676, 5163, '리버스 프록시,리버스프록시,reverse proxy,reverseproxy,역방향 프록시,리버스 프록시 서버,reverse proxy server', '브라우저가 보는 주소가 https://app.com 하나로 모이므로 크로스 출처 요청 자체가 성립하지 않고, 실제 API 호출은 앞단 웹 서버가 내부 네트워크에서 대신 처리한다. 요청 헤더에서 Origin 줄이 사라진 것이 같은 출처 요청이 됐다는 증거이며, 헤더 협상이 일어나지 않으니 허용 출처 목록을 손댈 필요도 없었다. 프론트엔드 개발 서버의 proxy 옵션과 헷갈리기 쉬운데, 그쪽은 로컬 개발 서버에서만 동작해 배포 환경에는 따로 해결책이 필요하다. 반면 이 구성은 실제 서비스 앞단에 두는 것이라 운영에서도 그대로 동작하는 정식 해결이다. 외부 API를 대신 호출하면서 비밀 키를 감추고 응답을 가공하는 BFF(Backend for Frontend)와도 구분한다. 여기서는 요청 경로를 내부 서버로 넘길 뿐 응답을 다시 만들지 않는다.'),
       (1677, 5164, 'Access-Control-Allow-Methods,Access Control Allow Methods,AccessControlAllowMethods,Allow-Methods,Allow Methods,ACAM', '프리플라이트 응답의 Access-Control-Allow-Methods는 본 요청에서 쓸 수 있는 메서드 목록을 알려 주는 헤더다. 목록에 GET·POST·PUT만 있고 DELETE가 없으면 브라우저는 허락을 받지 못했다고 보고 본 요청을 아예 보내지 않는다. 액세스 로그에 DELETE 줄이 남지 않고 콘솔에만 에러가 뜬 것이 그 결과다. 응답 상태가 204로 정상이어도 목록이 맞지 않으면 통과하지 못한다는 점이 핵심이다. 요청 쪽의 Access-Control-Request-Method는 브라우저가 앞으로 쓸 메서드를 미리 알리는 헤더라 방향이 반대이고, Access-Control-Allow-Headers는 메서드가 아니라 직접 붙인 요청 헤더(여기서는 Authorization)를 허락하는 목록이라 여기에 DELETE를 적어도 풀리지 않는다. 조회와 수정이 잘 되던 것은 GET·PUT이 이미 목록에 있었기 때문이다.');
