-- Unit: SOP와 CORS (Unit ID: 255)
-- Chapter: 웹 보안 (Chapter ID: 23)
-- Topic: WEB_SECURITY
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-web-security-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1454, 'WEB_SECURITY', 255, 'HARD', true,
 '서버 로그에는 요청이 성공으로 찍히는데 프론트에서만 CORS 오류가 납니다. 원인은 무엇이고 어떻게 해결하나요?',
 'CORS 오류는 서버가 요청을 막는 것이 아닙니다. 서버는 응답을 정상적으로 보내지만, 응답에 허용 헤더가 없으면 브라우저가 그 응답을 자바스크립트에 넘겨주지 않고 차단합니다. 그래서 서버 로그에는 요청이 성공으로 찍히는데 프론트에서만 에러가 나는 것입니다. 동일 출처 정책은 다른 출처의 응답을 자바스크립트로 읽는 행위를 기본적으로 차단합니다. 해결하려면 서버가 응답의 Access-Control-Allow-Origin 헤더에 프론트엔드의 출처를 허용할 출처로 지정해야 합니다. 필요하면 Access-Control-Allow-Methods로 허용할 HTTP 메서드를, Access-Control-Allow-Headers로 허용할 요청 헤더를 함께 지정합니다.',
 NULL),
(1455, 'WEB_SECURITY', 255, 'NORMAL', true,
 'CORS에서 단순 요청과 사전 요청은 어떻게 다른가요?',
 'CORS 요청은 조건에 따라 단순 요청과 사전 요청으로 나뉩니다. 단순 요청은 GET, POST, HEAD 메서드에 표준 헤더와 제한된 Content-Type만 쓰는 경우입니다. 이 조건을 벗어나면, 예를 들어 PUT이나 DELETE 메서드, 커스텀 헤더, JSON 본문을 쓰면 사전 요청이 됩니다. 사전 요청에서는 실제 요청 전에 브라우저가 OPTIONS 메서드로 서버에 허용 여부를 먼저 물어보고, 서버가 허용 정책을 응답하면 브라우저가 허용을 확인한 후 실제 요청을 보냅니다. Preflight 결과 캐싱 시간은 Access-Control-Max-Age 헤더로 지정합니다.',
 NULL),
(1456, 'WEB_SECURITY', 255, 'NORMAL', true,
 'CORS 허용 출처를 와일드카드로 둘 때와 특정 출처로 둘 때, 쿠키 포함 요청은 어떻게 다르고 왜 그런가요?',
 'Access-Control-Allow-Origin 헤더에는 와일드카드 또는 특정 출처를 지정할 수 있습니다. 하지만 쿠키 같은 credentials를 포함하는 요청에서는 Access-Control-Allow-Origin에 와일드카드를 쓸 수 없고, 반드시 구체적인 출처를 명시해야 합니다. 또한 Access-Control-Allow-Credentials: true 헤더도 함께 있어야 합니다. 이는 보안상 모두 허용과 인증 정보 전달이 함께 이루어지는 것을 막기 위한 제약입니다.',
 NULL),
(1457, 'WEB_SECURITY', 255, 'EASY', true,
 '동일 출처 정책이란 무엇이고, 왜 필요한가요?',
 '동일 출처 정책, SOP는 같은 출처에서 온 자원끼리만 상호작용을 허용하는 브라우저의 기본 보안 정책입니다. 다른 출처의 응답을 자바스크립트로 읽는 행위를 기본적으로 차단합니다. 여기서 출처는 프로토콜, 호스트, 포트 세 가지가 모두 같아야 동일하다고 판정합니다. SOP가 없다면 악성 사이트의 스크립트가 사용자가 로그인한 다른 사이트에 요청을 보내고 그 응답까지 읽어낼 수 있어 데이터 탈취로 이어집니다. SOP는 이런 교차 출처 정보 유출을 원천 차단합니다.',
 NULL),
(1458, 'WEB_SECURITY', 255, 'EASY', true,
 'CORS란 무엇이고, 왜 필요한가요?',
 'CORS는 Cross-Origin Resource Sharing의 줄임말로, 서버가 특정 출처의 요청을 명시적으로 허용하도록 하는 표준 메커니즘입니다. 동일 출처 정책의 제약을 안전하게 완화해 정당한 교차 출처 요청을 허용합니다. 현대 웹은 프론트엔드와 API 서버의 출처가 다른 경우가 흔한데, 이런 정당한 교차 출처 요청까지 SOP가 막으면 서비스가 동작하지 않습니다. 그래서 CORS가 필요합니다.',
 NULL);

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1454
(6750, 1454, '허용 헤더가 없으면 브라우저가 응답을 자바스크립트에 넘겨주지 않고 차단한다고 설명', 'ESSENTIAL', 1),
(6751, 1454, '서버가 응답의 Access-Control-Allow-Origin 헤더에 허용할 출처를 지정해야 한다고 설명', 'ESSENTIAL', 2),
(6752, 1454, '서버는 요청을 막지 않고 응답을 정상적으로 보낸다고 설명', 'SUPPLEMENTARY', 3),
(6753, 1454, 'Allow-Methods·Allow-Headers 헤더 중 최소 1개로 허용 범위를 지정한다고 언급', 'SUPPLEMENTARY', 4),
(6754, 1454, 'SOP가 다른 출처의 응답을 자바스크립트로 읽는 행위를 차단한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1455
(6755, 1455, '사전 요청은 실제 요청 전에 OPTIONS 메서드로 서버에 허용 여부를 먼저 물어본다고 설명', 'ESSENTIAL', 1),
(6756, 1455, '메서드·헤더·Content-Type 중 최소 1개를 두 요청을 가르는 조건으로 제시', 'ESSENTIAL', 2),
(6757, 1455, '브라우저가 허용을 확인한 후 실제 요청을 보낸다고 설명', 'SUPPLEMENTARY', 3),
(6758, 1455, 'Access-Control-Max-Age로 Preflight 결과 캐싱 시간을 지정한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1456
(6759, 1456, 'credentials를 포함하는 요청에서는 Access-Control-Allow-Origin에 와일드카드를 쓸 수 없다고 설명', 'ESSENTIAL', 1),
(6760, 1456, '모두 허용과 인증 정보 전달이 함께 이루어지는 것을 막기 위한 제약이라고 설명', 'ESSENTIAL', 2),
(6761, 1456, 'credentials 포함 요청에는 Access-Control-Allow-Credentials: true가 함께 있어야 한다고 설명', 'SUPPLEMENTARY', 3),
(6762, 1456, 'Access-Control-Allow-Origin에는 와일드카드 또는 특정 출처를 지정한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1457
(6763, 1457, '같은 출처에서 온 자원끼리만 상호작용을 허용하는 브라우저 정책이라고 설명', 'ESSENTIAL', 1),
(6764, 1457, 'SOP가 없으면 악성 사이트의 스크립트가 로그인한 다른 사이트의 응답까지 읽어낼 수 있다고 설명', 'ESSENTIAL', 2),
(6765, 1457, '다른 출처의 응답을 자바스크립트로 읽는 행위를 기본적으로 차단한다고 설명', 'SUPPLEMENTARY', 3),
(6766, 1457, '출처는 프로토콜·호스트·포트 세 가지가 모두 같아야 동일하다고 설명', 'SUPPLEMENTARY', 4),

-- 질문 1458
(6767, 1458, '서버가 특정 출처의 요청을 명시적으로 허용하도록 하는 표준이라고 설명', 'ESSENTIAL', 1),
(6768, 1458, '정당한 교차 출처 요청까지 SOP가 막으면 서비스가 동작하지 않는다고 설명', 'ESSENTIAL', 2),
(6769, 1458, '프론트엔드와 API 서버의 출처가 다른 경우가 흔하다고 언급', 'SUPPLEMENTARY', 3),
(6770, 1458, 'CORS가 SOP의 제약을 안전하게 완화한다고 언급', 'SUPPLEMENTARY', 4);
