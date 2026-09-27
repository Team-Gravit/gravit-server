-- Unit: 동일 출처 정책과 CORS (Unit ID: 88)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(436, 'WEB_COMMON', 88, 'HARD', true,
 'https://app.com의 프론트엔드가 쿠키 기반 인증으로 https://api.io의 API를 호출하는데 쿠키가 전송되지 않고 CORS 에러가 납니다. 클라이언트와 서버에서 각각 무엇을 설정해야 하며, 여러 출처를 허용해야 할 때는 무엇을 주의해야 하나요?',
 'fetch는 기본적으로 같은 출처에만 쿠키를 보내므로, 다른 출처 API에 쿠키를 보내려면 클라이언트와 서버 양쪽 모두 허용해야 합니다. 클라이언트는 fetch에 credentials: ''include'' 옵션을 지정하고(XHR의 withCredentials = true에 해당), 서버는 응답에 Access-Control-Allow-Credentials: true를 넣어야 합니다. 또 credentials 요청에서는 Access-Control-Allow-Origin에 *를 쓸 수 없고 https://app.com처럼 출처를 정확히 지정해야 하며, Allow-Headers와 Allow-Methods도 *가 아니라 값을 나열해야 합니다. 두 사이트가 다르므로 쿠키에는 SameSite=None; Secure 설정도 필요합니다. 여러 출처를 허용해야 한다면 요청의 Origin 값을 허용 목록(화이트리스트)과 대조한 뒤에만 그 값을 그대로 Allow-Origin으로 돌려주고, Vary: Origin을 붙여 캐시가 출처별로 응답을 구분하도록 해야 합니다. Vary: Origin을 빠뜨리면 CDN이나 브라우저 캐시가 다른 출처용 응답을 돌려줘 간헐적으로만 실패하는 CORS 에러가 생깁니다. 반대로 Origin을 검증 없이 그대로 반영하면서 credentials까지 허용하면 사실상 SOP를 해제하는 것이라, 아무 사이트나 사용자 데이터를 열람할 수 있게 됩니다.'),
(437, 'WEB_COMMON', 88, 'NORMAL', true,
 'CORS에서 단순 요청과 프리플라이트 요청은 어떻게 다르며, 어떤 요청일 때 프리플라이트가 발생하나요?',
 '단순 요청은 조건을 모두 만족할 때 브라우저가 프리플라이트 없이 본 요청을 바로 보내는 경우입니다. 조건은 메서드가 GET, HEAD, POST 중 하나이고, 수동으로 설정한 헤더가 CORS-안전 목록에 속하며, Content-Type이 application/x-www-form-urlencoded, multipart/form-data, text/plain 중 하나인 것입니다. 이는 CORS가 생기기 전부터 HTML 폼으로 보낼 수 있던 요청과 같아서 어차피 막을 수 없었던 요청이므로 프리플라이트가 없습니다. 반면 이 조건을 벗어나면 브라우저는 본 요청 전에 OPTIONS 요청을 먼저 보내 서버의 허락을 확인하는데, 이것이 프리플라이트입니다. Content-Type: application/json, Authorization 헤더, PUT이나 DELETE 메서드가 대표적인 발생 원인입니다. 프리플라이트는 왕복을 한 번 더 소비하므로 Access-Control-Max-Age로 결과를 캐시하면 같은 URL·메서드·헤더 조합에 대해 재사용할 수 있습니다.'),
(438, 'WEB_COMMON', 88, 'NORMAL', true,
 'CORS 에러를 없애는 방법 중 정식 해결과 위험한 우회에는 각각 어떤 것이 있고, 우회가 왜 위험한가요?',
 '정식 해결은 서버가 허용 출처를 화이트리스트로 관리하며 정확한 CORS 헤더를 응답하는 방법, 리버스 프록시로 /api를 같은 출처에 배치하는 방법, 프론트 전용 BFF 서버가 외부 API를 호출하게 하는 방법입니다. 리버스 프록시를 쓰면 브라우저 입장에서는 모두 같은 출처라 CORS 자체가 발생하지 않고, BFF를 쓰면 비밀 키를 브라우저에 두지 않아도 됩니다. 개발 서버의 proxy 설정은 로컬에서만 유효한 개발용 우회라 배포 환경 해결책은 따로 필요합니다. 위험한 우회로는 Allow-Origin에 요청 Origin을 검증 없이 무조건 반영하는 것과 공개 CORS 프록시 서비스를 경유하는 것이 있습니다. Origin을 무조건 반영하면서 credentials까지 허용하면 사실상 SOP를 해제하는 것이라 아무 사이트나 사용자 데이터를 열람할 수 있고, 공개 CORS 프록시는 요청과 응답이 제3자를 거치므로 인증 정보가 유출됩니다.'),
(439, 'WEB_COMMON', 88, 'EASY', true,
 '웹에서 출처(Origin)란 무엇이며, 동일 출처 정책(SOP)은 정확히 무엇을 막는 정책인가요?',
 '출처는 스킴(프로토콜), 호스트, 포트의 조합이고, 셋 중 하나라도 다르면 다른 출처입니다. 경로는 무관해서 https://app.example.com과 https://app.example.com/users는 동일 출처지만, http로 바뀌거나 서브도메인이나 포트가 다르면 다른 출처입니다. 동일 출처 정책은 브라우저가 강제하는 정책으로, 다른 출처의 리소스를 가져오는 것 자체를 막는 것이 아니라 다른 출처의 응답을 스크립트가 읽는 것을 막습니다. 그래서 script src, 이미지, CSS, 폼 제출처럼 가져와서 브라우저가 쓰는 것은 허용되지만, fetch나 XMLHttpRequest로 받은 응답 본문 읽기, 다른 출처 iframe의 DOM 접근은 차단됩니다.'),
(440, 'WEB_COMMON', 88, 'EASY', true,
 'CORS는 어떤 방식으로 동작하나요? 브라우저와 서버가 주고받는 헤더를 중심으로 설명해 주세요.',
 'CORS는 헤더 기반 협상입니다. 브라우저가 다른 출처로 요청을 보낼 때 Origin 헤더에 자신의 출처를 붙여 보내고, 서버는 응답의 Access-Control-Allow-Origin 헤더로 허용할 출처를 알려줍니다. 허용 여부 검사는 서버가 아니라 브라우저가 수행합니다. 응답의 Allow-Origin에 내 출처가 있으면 브라우저가 JS에 응답을 전달하고, 없으면 응답을 폐기하고 콘솔에 CORS 에러를 띄웁니다. 이때 요청은 이미 서버에서 실행된 상태라 서버 로그에는 요청이 찍혀 있습니다. 이렇게 브라우저가 검사하는 구조이므로 curl이나 서버 간 통신에는 CORS가 존재하지 않습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 436
(2326, 436, '클라이언트 fetch에 credentials: ''include'' 옵션을 지정해야 한다고 언급', 'ESSENTIAL', 1),
(2327, 436, '서버가 Access-Control-Allow-Credentials: true를 응답해야 한다고 언급', 'ESSENTIAL', 2),
(2328, 436, 'credentials 요청에서는 Allow-Origin에 *를 쓸 수 없다고 언급', 'ESSENTIAL', 3),
(2329, 436, '요청의 Origin을 허용 목록과 대조한 뒤에만 그 값을 Allow-Origin으로 돌려준다고 설명', 'ESSENTIAL', 4),
(2330, 436, 'Vary: Origin을 붙여 캐시가 출처별로 응답을 나누게 해야 한다고 언급', 'SUPPLEMENTARY', 5),
(2331, 436, '사이트가 다르면 쿠키에 SameSite=None; Secure 설정이 필요하다고 언급', 'SUPPLEMENTARY', 6),
(2332, 436, 'Origin을 검증 없이 반영하면 아무 사이트나 사용자 데이터를 열람할 수 있다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 437
(2333, 437, '단순 요청은 프리플라이트 없이 본 요청을 바로 보낸다고 언급', 'ESSENTIAL', 1),
(2334, 437, '프리플라이트는 본 요청 전에 OPTIONS 요청으로 서버의 허락을 확인하는 절차라고 설명', 'ESSENTIAL', 2),
(2335, 437, '메서드가 GET·HEAD·POST 중 하나여야 한다는 단순 요청 조건을 언급', 'ESSENTIAL', 3),
(2336, 437, 'application/json·Authorization 헤더·PUT/DELETE 중 최소 1개를 프리플라이트 발생 원인으로 제시', 'ESSENTIAL', 4),
(2337, 437, '단순 요청 조건이 HTML 폼으로 보낼 수 있던 요청과 같다고 언급', 'SUPPLEMENTARY', 5),
(2338, 437, 'Access-Control-Max-Age로 프리플라이트 결과를 캐시할 수 있다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 438
(2339, 438, '서버 CORS 헤더 응답·리버스 프록시·BFF 중 최소 1개를 정식 해결로 제시', 'ESSENTIAL', 1),
(2340, 438, 'Origin 무조건 반영·공개 CORS 프록시 경유 중 최소 1개를 위험한 우회로 제시', 'ESSENTIAL', 2),
(2341, 438, 'SOP가 사실상 해제됨·인증 정보가 제3자에 유출됨 중 최소 1개를 우회의 위험 근거로 제시', 'ESSENTIAL', 3),
(2342, 438, '리버스 프록시로 API를 같은 출처에서 서빙하면 CORS 자체가 발생하지 않는다고 언급', 'SUPPLEMENTARY', 4),
(2343, 438, '개발 서버의 proxy 설정은 로컬에서만 유효한 개발용 우회라고 언급', 'SUPPLEMENTARY', 5),
(2344, 438, 'BFF를 경유하면 비밀 키를 브라우저에 두지 않아도 된다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 439
(2345, 439, '출처가 스킴·호스트·포트의 조합이라고 언급', 'ESSENTIAL', 1),
(2346, 439, 'SOP가 다른 출처의 응답을 스크립트가 읽는 것을 막는다고 설명', 'ESSENTIAL', 2),
(2347, 439, 'SOP가 다른 출처의 리소스를 가져오는 것 자체는 막지 않는다고 언급', 'ESSENTIAL', 3),
(2348, 439, '경로가 달라도 스킴·호스트·포트가 같으면 동일 출처라고 언급', 'SUPPLEMENTARY', 4),
(2349, 439, 'script src·이미지·CSS·폼 제출 중 최소 1개를 SOP가 허용하는 예로 제시', 'SUPPLEMENTARY', 5),

-- 질문 440
(2350, 440, '브라우저가 요청에 Origin 헤더를 붙여 보낸다고 언급', 'ESSENTIAL', 1),
(2351, 440, '서버가 Access-Control-Allow-Origin 헤더로 허용할 출처를 알려준다고 언급', 'ESSENTIAL', 2),
(2352, 440, '허용 여부 검사를 서버가 아니라 브라우저가 수행한다고 언급', 'ESSENTIAL', 3),
(2353, 440, '허용되지 않으면 요청은 이미 서버에서 실행됐고 응답만 폐기된다고 설명', 'SUPPLEMENTARY', 4),
(2354, 440, 'curl이나 서버 간 통신에는 CORS가 존재하지 않는다고 언급', 'SUPPLEMENTARY', 5);
