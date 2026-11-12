-- Unit: 브라우저 저장소와 세션 유지 (Unit ID: 87)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(431, 'WEB_COMMON', 87, 'HARD', true,
 '로그인 후 발급한 토큰을 LocalStorage에 저장하는 방식과 HttpOnly 쿠키에 저장하는 방식 중 무엇을 선택하시겠어요? 각 방식이 어떤 보안 위험을 감수하는지와 함께 설명해 주세요.',
 '두 방식은 서로 다른 위험을 감수합니다. LocalStorage 같은 Web Storage에는 HttpOnly 같은 보호 수단이 없어서, 페이지에서 실행되는 모든 JS — 서드파티 스크립트나 XSS로 주입된 스크립트까지 — 가 토큰을 읽을 수 있습니다. 즉 XSS가 발생하면 토큰이 탈취될 수 있습니다. 대신 Web Storage의 토큰은 JS가 Authorization 헤더에 직접 첨부하므로 자동 첨부되지 않고, 따라서 CSRF 위험은 없습니다. 반대로 HttpOnly 쿠키는 document.cookie로 읽고 쓸 수 없어 XSS로 토큰을 탈취할 수 없습니다. 하지만 쿠키는 조건에 맞는 요청마다 브라우저가 자동으로 첨부하기 때문에 CSRF 위험이 생기고, 이는 SameSite 속성이나 CSRF 토큰으로 방어해야 합니다. 결국 저장 위치 선택은 자동 첨부의 편리함(CSRF 노출)과 JS 접근 가능성(XSS 노출) 사이의 트레이드오프로, 한쪽 위험을 피하면 다른 쪽 위험을 받아들이게 됩니다. 저라면 서버가 매 요청마다 알아야 하는 식별자이므로 자동 첨부되면서 JS 접근이 차단되는 HttpOnly; Secure; SameSite 쿠키를 선택하고, 그로 인해 생기는 CSRF 위험은 SameSite 속성으로 막겠습니다.',
 'interview-question/431.mp3'),
(432, 'WEB_COMMON', 87, 'NORMAL', true,
 '쿠키의 SameSite 속성 값인 Strict, Lax, None은 크로스 사이트 요청에서 각각 어떻게 다르게 동작하나요?',
 'SameSite는 다른 사이트에서 시작된 요청에 쿠키를 붙일지 결정하는 속성으로, CSRF 방어의 1차 수단입니다. 여기서 사이트는 등록 가능한 도메인(eTLD+1)과 스킴 기준이라 출처보다 넓은 개념이어서, a.example.com과 b.example.com은 다른 출처지만 같은 사이트입니다. Strict는 크로스 사이트 요청에 쿠키를 절대 전송하지 않습니다. 그래서 외부 링크로 들어와도 로그인이 풀린 것처럼 보이며, 은행·결제처럼 보안이 최우선인 쿠키에 씁니다. Lax는 주소창 이동이나 링크 클릭 같은 최상위 탐색이면서 GET 같은 안전한 메서드인 경우에만 쿠키를 전송하고, 이미지 태그·fetch·POST 폼 요청에는 붙이지 않습니다. 일반 세션 쿠키의 기본 선택이며 최신 Chrome 등은 미지정 시 Lax로 취급합니다. None은 크로스 사이트 요청에도 항상 쿠키를 전송하며, 반드시 Secure와 함께 써야 합니다. 결제 위젯이나 SSO iframe 같은 서드파티 임베드에 사용합니다.',
 'interview-question/432.mp3'),
(433, 'WEB_COMMON', 87, 'NORMAL', true,
 'LocalStorage와 SessionStorage의 차이를 데이터 수명과 탭 간 공유 관점에서 설명해 주세요.',
 '둘 다 서버로 전송되지 않는 키-값 문자열 저장소이고 API도 같지만, 수명과 범위가 다릅니다. 수명 측면에서 LocalStorage는 직접 삭제하기 전까지 데이터가 영구히 유지되고, SessionStorage는 탭(브라우징 컨텍스트)을 닫으면 삭제됩니다. 다만 SessionStorage도 새로고침에는 살아남습니다. 공유 측면에서 LocalStorage는 출처 단위라 같은 출처의 탭끼리 공유되며, 다른 탭에서 변경한 내용을 storage 이벤트로 감지할 수 있습니다. 반면 SessionStorage는 출처에 더해 탭 단위라서 탭 간에 공유되지 않고, 새 탭에서는 비어 있습니다. 그래서 탭을 닫아도 남아야 할 UI 설정은 LocalStorage에, 작성 중인 폼 같은 탭별 임시 상태는 탭을 닫으면 자동 정리되고 탭 간 간섭이 없는 SessionStorage에 두는 것이 적합합니다.',
 'interview-question/433.mp3'),
(434, 'WEB_COMMON', 87, 'EASY', true,
 '쿠키는 서버와 브라우저 사이에서 어떻게 설정되고 전송되는지 동작 과정을 설명해 주세요.',
 'HTTP는 상태를 기억하지 않는 stateless 프로토콜이라 로그인 상태 같은 정보를 유지하려면 브라우저 쪽 저장소가 필요하고, 쿠키가 그 역할을 합니다. 예를 들어 로그인 요청이 오면 서버는 세션을 생성하고 Set-Cookie 응답 헤더로 sid=abc123 같은 쿠키를 내려줍니다. 브라우저는 이를 저장해 두었다가, 이후 도메인·경로 등 조건에 맞는 요청마다 Cookie 헤더에 쿠키를 자동으로 실어 보냅니다. 서버는 전달받은 세션 ID로 세션 저장소를 조회해 사용자를 식별합니다. 개발자가 코드로 첨부하지 않아도 전송된다는 점이 LocalStorage 같은 다른 저장소와의 결정적 차이입니다.',
 'interview-question/434.mp3'),
(435, 'WEB_COMMON', 87, 'EASY', true,
 '쿠키의 Secure 속성과 HttpOnly 속성은 각각 어떤 역할을 하나요?',
 'Secure 속성은 쿠키를 HTTPS에서만 전송하게 합니다. 지정하지 않으면 HTTP에서도 쿠키가 전송되어 탈취 위험이 있습니다. HttpOnly 속성은 JS에서 document.cookie로 해당 쿠키를 읽고 쓰지 못하게 막습니다. 지정하지 않으면 JS에서 쿠키가 읽히므로 XSS로 탈취될 수 있습니다. 그래서 세션 쿠키는 속성 없이 내려주지 말고 Secure; HttpOnly; SameSite=Lax처럼 전송 조건을 최대한 좁혀 설정하는 것이 좋습니다.',
 'interview-question/435.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 431
(2299, 431, 'LocalStorage에 둔 토큰은 페이지의 모든 JS가 읽을 수 있어 XSS로 탈취될 수 있음을 언급', 'ESSENTIAL', 1),
(2300, 431, 'HttpOnly 쿠키는 JS에서 읽을 수 없어 XSS로 토큰을 탈취할 수 없음을 언급', 'ESSENTIAL', 2),
(2301, 431, '쿠키는 브라우저가 요청에 자동 첨부하므로 CSRF 위험이 생김을 언급', 'ESSENTIAL', 3),
(2302, 431, 'CSRF 방어 수단으로 SameSite 속성·CSRF 토큰 중 최소 1개를 제시', 'SUPPLEMENTARY', 4),
(2303, 431, 'Web Storage에 둔 토큰은 자동 첨부되지 않아 CSRF 위험이 없음을 언급', 'SUPPLEMENTARY', 5),
(2304, 431, '두 저장 방식의 선택을 CSRF 노출과 XSS 노출을 맞바꾸는 트레이드오프로 명시', 'SUPPLEMENTARY', 6),

-- 질문 432
(2305, 432, 'Strict는 크로스 사이트 요청에 쿠키를 절대 전송하지 않음을 언급', 'ESSENTIAL', 1),
(2306, 432, 'Lax는 최상위 탐색의 GET 요청에만 크로스 사이트 쿠키를 전송함을 언급', 'ESSENTIAL', 2),
(2307, 432, 'None은 크로스 사이트 요청에도 쿠키를 항상 전송함을 언급', 'ESSENTIAL', 3),
(2308, 432, 'SameSite=None은 반드시 Secure 속성과 함께 써야 함을 언급', 'SUPPLEMENTARY', 4),
(2309, 432, 'SameSite가 CSRF 방어의 1차 수단임을 언급', 'SUPPLEMENTARY', 5),
(2310, 432, '사이트는 eTLD+1과 스킴 기준으로 출처보다 넓은 개념임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 433
(2311, 433, 'LocalStorage는 직접 삭제하기 전까지 데이터가 영구히 유지됨을 언급', 'ESSENTIAL', 1),
(2312, 433, 'SessionStorage는 탭을 닫으면 데이터가 삭제됨을 언급', 'ESSENTIAL', 2),
(2313, 433, 'LocalStorage는 탭 간 공유되지만 SessionStorage는 탭 간 공유되지 않음을 언급', 'ESSENTIAL', 3),
(2314, 433, 'SessionStorage 데이터는 새로고침에는 살아남음을 언급', 'SUPPLEMENTARY', 4),
(2315, 433, '다른 탭의 LocalStorage 변경을 storage 이벤트로 감지할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2316, 433, '작성 중인 폼 같은 탭별 임시 상태 저장에 SessionStorage가 적합함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 434
(2317, 434, '서버가 Set-Cookie 응답 헤더로 쿠키를 내려줌을 언급', 'ESSENTIAL', 1),
(2318, 434, '브라우저가 조건에 맞는 요청마다 Cookie 헤더에 쿠키를 자동으로 실어 보냄을 언급', 'ESSENTIAL', 2),
(2319, 434, 'HTTP가 stateless라서 상태 유지를 위해 브라우저 쪽 저장소가 필요함을 언급', 'SUPPLEMENTARY', 3),
(2320, 434, '서버가 쿠키에 담긴 세션 ID로 사용자를 식별함을 언급', 'SUPPLEMENTARY', 4),
(2321, 434, '개발자가 코드로 첨부하지 않아도 전송되는 점이 다른 저장소와의 차이임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 435
(2322, 435, 'Secure 속성은 쿠키를 HTTPS에서만 전송하게 함을 언급', 'ESSENTIAL', 1),
(2323, 435, 'HttpOnly 속성은 document.cookie로 쿠키를 읽고 쓰지 못하게 막음을 언급', 'ESSENTIAL', 2),
(2324, 435, 'Secure가 없으면 HTTP에서도 쿠키가 전송되어 탈취 위험이 있음을 언급', 'SUPPLEMENTARY', 3),
(2325, 435, 'HttpOnly가 없으면 쿠키가 JS에서 읽혀 XSS로 탈취될 수 있음을 언급', 'SUPPLEMENTARY', 4);
