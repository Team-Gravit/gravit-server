-- Unit: 웹 보안 (Unit ID: 89)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(441, 'WEB_COMMON', 89, 'HARD', true,
 'SPA에서 인증 토큰을 LocalStorage와 HttpOnly 쿠키 중 어디에 저장할지 결정해야 한다면, 각 방식이 어떤 공격에 노출되는지와 어떤 방식을 권장하는지 설명해 주시겠어요?',
 '인증 토큰을 어디에 두느냐는 결국 XSS와 CSRF 중 어느 위험에 노출될지를 고르는 문제입니다. LocalStorage에 저장하면 JS에서 읽을 수 있기 때문에 XSS가 발생하면 토큰이 탈취될 수 있습니다. 대신 자동으로 첨부되지 않으므로 CSRF에는 안전합니다. 반대로 HttpOnly 쿠키는 스크립트가 읽을 수 없어 XSS로 탈취되지는 않지만, 브라우저가 요청에 자동으로 첨부하기 때문에 CSRF에 노출됩니다. 이 CSRF 노출은 SameSite 속성으로 방어합니다. 그래서 기본 권장 저장 위치는 HttpOnly 쿠키이고, 여기에 Secure와 SameSite를 함께 설정하며, 서버 세션과 JWT 모두 이 방식으로 다룰 수 있습니다. 프론트와 API가 다른 사이트라 쿠키 방식에 SameSite=None과 CORS credentials 설정이 필요해 복잡하다면, 액세스 토큰은 메모리에 두고 리프레시 토큰만 HttpOnly 쿠키에 두는 조합도 SPA에서 널리 쓰입니다. 어떤 방식이든 액세스 토큰 수명은 분 단위로 짧게 두어 탈취 시 피해 범위를 줄입니다. 참고로 JWT는 전달 형식일 뿐 저장 위치와 무관하므로, JWT를 HttpOnly 쿠키에 담아도 서버는 서명만 검증하면 되어 무상태 이점이 유지됩니다.'),
(442, 'WEB_COMMON', 89, 'NORMAL', true,
 'XSS와 CSRF는 자주 혼동되는데, 두 공격의 차이점은 무엇인가요?',
 '두 공격은 공격 방향이 정반대입니다. XSS는 공격자가 피해 사이트 안에서 자기 스크립트를 실행시키는 공격이고, CSRF는 피해자의 브라우저로 하여금 피해 사이트에 요청을 보내게 만드는 공격입니다. 악용하는 지점도 다른데, XSS는 사이트가 사용자 입력을 검증 없이 출력하는 것을 악용하고, CSRF는 브라우저가 쿠키를 자동으로 첨부하는 것을 악용합니다. 그 결과 XSS는 세션이나 토큰, 화면 데이터를 읽을 수 있지만, CSRF는 피해자 권한으로 송금이나 비밀번호 변경 같은 쓰기만 가능하고 응답은 읽지 못합니다. 또 XSS로 같은 출처에서 스크립트가 돌면 CSRF 토큰을 읽어 정상 요청을 만들 수 있어 CSRF 방어가 무력화되므로, XSS 방어가 우선입니다.'),
(443, 'WEB_COMMON', 89, 'NORMAL', true,
 'CSRF 방어에서 SameSite 쿠키와 CSRF 토큰은 각각 어떤 원리로 동작하며, SameSite 쿠키만으로 충분한가요?',
 'SameSite 쿠키는 크로스 사이트 요청에는 쿠키를 붙이지 않도록 해서, 공격자 사이트에서 보낸 요청에 피해자의 세션 쿠키가 첨부되지 않게 만드는 방식입니다. Lax 이상으로 설정합니다. CSRF 토큰은 서버가 폼이나 페이지마다 난수를 심어 두고 요청이 올 때 그 값을 검증하는 방식으로, 공격자는 그 값을 모르기 때문에 위조 요청이 거부됩니다. SameSite만으로 대부분의 공격은 막을 수 있지만, 같은 사이트 내 서브도메인 XSS에는 무력하고 구형 브라우저 문제도 있어서 서버 측 검증을 병행합니다. 그래서 현대적인 기본 조합은 SameSite=Lax 쿠키에 요청 헤더의 Origin을 허용 목록과 대조하는 Origin 검증을 더하는 것이고, 결제처럼 민감한 동작에는 CSRF 토큰을 추가합니다. 기본 원칙으로 상태 변경에는 GET을 쓰지 않아 이미지 태그나 링크만으로 부작용이 생기지 않게 합니다.'),
(444, 'WEB_COMMON', 89, 'EASY', true,
 'CSP(Content Security Policy)란 무엇이며, XSS를 어떻게 막아 주나요?',
 'CSP는 이 페이지에서 어떤 출처의 스크립트, 스타일, 이미지만 실행하거나 로드할 수 있는지를 서버가 응답 헤더로 선언하는 정책입니다. XSS로 스크립트가 주입되더라도 정책에 맞지 않으면 브라우저가 실행을 거부하기 때문에, 주입된 스크립트의 실행 자체를 차단하는 최종 방어선 역할을 합니다. 예를 들어 서버가 요청마다 생성한 nonce를 script-src에 지정하면 같은 nonce를 가진 스크립트만 실행되고, 주입된 스크립트는 nonce를 모르므로 차단됩니다. 반대로 script-src에 ''unsafe-inline''을 쓰면 XSS 방어 효과가 거의 사라집니다. 처음 도입할 때는 기존 인라인 스크립트가 대거 차단될 수 있으므로 Content-Security-Policy-Report-Only 헤더로 차단 없이 위반 보고만 먼저 수집한 뒤 정책을 다듬어 강제 모드로 전환하는 것이 정석입니다.'),
(445, 'WEB_COMMON', 89, 'EASY', true,
 'XSS에는 어떤 유형이 있고, 프론트엔드 코드에서 이를 막으려면 어떻게 해야 하나요?',
 'XSS는 주입 위치에 따라 세 가지로 나뉩니다. 게시글이나 댓글에 스크립트를 넣어 DB에 저장된 뒤 다른 사용자에게 출력되는 저장형, 요청 파라미터가 응답에 그대로 반영되는 반사형, 그리고 서버와 무관하게 클라이언트 JS가 location.hash 같은 값을 DOM에 삽입하면서 생기는 DOM 기반 XSS입니다. 방어의 핵심은 저장 시점이 아니라 사용자 데이터를 출력하는 시점에 이스케이프하는 것이고, 데이터를 HTML·속성·URL·JS 문자열 중 어느 문맥에 넣느냐에 따라 이스케이프 규칙이 다르므로 문맥별로 처리합니다. 또 innerHTML, document.write, eval 같은 위험한 API는 피해야 합니다. 텍스트는 textContent로 삽입하면 태그가 문자 그대로 표시됩니다. 프레임워크의 자동 이스케이프를 우회하는 dangerouslySetInnerHTML이나 v-html은 정제된 HTML에만 사용해야 하고, 링크처럼 URL 문맥에서는 이스케이프해도 javascript: URL이 실행되므로 http·https 스킴만 화이트리스트로 허용하도록 검사합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 441
(2355, 441, '토큰 저장 위치 선택이 XSS 노출과 CSRF 노출 사이의 선택임을 설명', 'ESSENTIAL', 1),
(2356, 441, 'LocalStorage의 토큰은 JS에서 읽히므로 XSS로 탈취될 수 있음을 언급', 'ESSENTIAL', 2),
(2357, 441, 'HttpOnly 쿠키는 요청에 자동 첨부되어 CSRF에 노출됨을 언급', 'ESSENTIAL', 3),
(2358, 441, '기본 권장 저장 위치가 HttpOnly 쿠키임을 명시', 'ESSENTIAL', 4),
(2359, 441, 'HttpOnly 쿠키의 CSRF 노출은 SameSite 속성으로 방어함을 언급', 'SUPPLEMENTARY', 5),
(2360, 441, '액세스 토큰은 메모리에, 리프레시 토큰은 HttpOnly 쿠키에 두는 조합을 제시', 'SUPPLEMENTARY', 6),
(2361, 441, 'JWT는 전달 형식일 뿐 저장 위치와 무관함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 442
(2362, 442, 'XSS는 피해 사이트 안에서 공격자의 스크립트를 실행시키는 공격임을 설명', 'ESSENTIAL', 1),
(2363, 442, 'CSRF는 피해자의 브라우저가 피해 사이트에 요청을 보내게 하는 공격임을 설명', 'ESSENTIAL', 2),
(2364, 442, 'XSS는 검증 없는 출력을, CSRF는 쿠키 자동 첨부를 악용함을 명시', 'ESSENTIAL', 3),
(2365, 442, 'XSS는 데이터를 읽을 수 있지만 CSRF는 응답을 못 읽는 쓰기 공격임을 언급', 'SUPPLEMENTARY', 4),
(2366, 442, 'XSS가 가능하면 CSRF 토큰을 읽어 CSRF 방어가 무력화됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 443
(2367, 443, 'SameSite 쿠키는 크로스 사이트 요청에 쿠키를 붙이지 않는 방식임을 설명', 'ESSENTIAL', 1),
(2368, 443, 'CSRF 토큰은 서버가 심은 난수를 요청 시 검증하는 방식임을 설명', 'ESSENTIAL', 2),
(2369, 443, '서브도메인 XSS·구형 브라우저 중 최소 1개를 SameSite만으로 불충분한 이유로 제시', 'ESSENTIAL', 3),
(2370, 443, '요청 헤더의 Origin을 허용 목록과 대조하는 Origin 검증을 병행 방어로 제시', 'SUPPLEMENTARY', 4),
(2371, 443, '결제 같은 민감한 동작에는 CSRF 토큰을 추가함을 언급', 'SUPPLEMENTARY', 5),
(2372, 443, '상태 변경 요청에 GET을 쓰지 않아야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 444
(2373, 444, 'CSP는 서버가 응답 헤더로 스크립트 등의 허용 출처를 선언하는 정책임을 설명', 'ESSENTIAL', 1),
(2374, 444, '주입된 스크립트가 정책에 맞지 않으면 브라우저가 실행을 거부함을 설명', 'ESSENTIAL', 2),
(2375, 444, '요청마다 생성한 nonce가 일치하는 스크립트만 실행됨을 언급', 'SUPPLEMENTARY', 3),
(2376, 444, 'script-src에 unsafe-inline을 쓰면 XSS 방어 효과가 거의 사라짐을 언급', 'SUPPLEMENTARY', 4),
(2377, 444, 'Report-Only 헤더로 위반 보고를 먼저 수집한 뒤 강제 모드로 전환함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 445
(2378, 445, '저장형·반사형·DOM 기반 XSS 중 최소 2개를 유형으로 제시', 'ESSENTIAL', 1),
(2379, 445, '사용자 데이터를 출력하는 시점에 이스케이프함을 언급', 'ESSENTIAL', 2),
(2380, 445, 'innerHTML·document.write·eval 중 최소 1개를 회피할 위험한 API로 제시', 'ESSENTIAL', 3),
(2381, 445, 'HTML·속성·URL·JS 문자열 등 삽입 문맥에 따라 이스케이프 규칙이 다름을 설명', 'SUPPLEMENTARY', 4),
(2382, 445, '텍스트는 textContent로 삽입해 태그가 문자 그대로 표시됨을 언급', 'SUPPLEMENTARY', 5),
(2383, 445, 'URL 문맥에서는 http·https 스킴만 화이트리스트로 허용함을 언급', 'SUPPLEMENTARY', 6);
