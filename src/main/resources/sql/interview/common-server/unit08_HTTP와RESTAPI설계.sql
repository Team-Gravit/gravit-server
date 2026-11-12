-- Unit: HTTP와 REST API 설계 (Unit ID: 77)
-- Chapter: Server (Chapter ID: 6)
-- Topic: SERVER_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-server-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(381, 'SERVER_COMMON', 77, 'HARD', true,
 '주문 API가 재고 부족 같은 업무 오류를 모두 200 OK와 본문의 success:false로 응답하거나, 반대로 전부 500으로 응답하고 있다고 가정해 보겠습니다. 이 방식의 문제점은 무엇이고, 상태 코드와 오류 응답 본문을 어떻게 개선하시겠습니까?',
 '상태 코드는 클라이언트에게 다음에 무엇을 해야 하는지 알려 주는 신호입니다. 모든 오류를 200으로 감싸고 성공 여부를 본문에서만 판단하게 하거나, 반대로 500으로 뭉뚱그리면 클라이언트는 재시도 여부조차 판단할 수 없습니다. 또 4xx는 클라이언트 잘못, 5xx는 서버 잘못이라는 구분은 재시도·알림·모니터링의 기준이 되는데, 재고 부족 같은 업무 규칙 위반을 500으로 내보내면 서버 오류율 지표가 오염됩니다. 개선 방향은 먼저 상태 코드로 오류를 분류하는 것입니다. 재고 부족은 현재 상태와 충돌하는 경우로 보아 409 Conflict로 응답할 수 있고, 이때 클라이언트는 최신 상태를 조회한 뒤 재시도 여부를 결정할 수 있습니다. 반대로 형식은 맞지만 업무 규칙을 어긴 의미상 검증 실패로 본다면 422 Unprocessable Content로 분류하는 대안도 있으므로, 어떤 근거로 409를 택했는지와 422 대안과의 차이를 설명할 수 있어야 합니다. 그리고 오류 본문에는 OUT_OF_STOCK처럼 기계가 읽을 수 있는 코드와 ''재고가 부족합니다'' 같은 사람이 읽을 메시지, 필요한 상세 정보를 함께 담습니다. 오류 본문 형식은 서비스 전체에서 하나로 통일하고, RFC 9457(Problem Details) 같은 표준 형식을 따르면 클라이언트 처리가 단순해집니다. 마지막으로 스택 트레이스나 내부 테이블명 같은 구현 세부는 노출하지 않습니다.',
 'interview-question/381.mp3'),
(382, 'SERVER_COMMON', 77, 'NORMAL', true,
 'HTTP 메서드의 안전성(Safe)과 멱등성(Idempotent)은 각각 무엇이고 어떻게 다른지, 주요 메서드를 이 기준으로 분류해 설명해 주시겠어요?',
 '안전(Safe)은 서버 상태를 바꾸지 않는 성질로, 그래서 브라우저나 프록시가 마음대로 캐시하거나 프리페치해도 됩니다. 멱등(Idempotent)은 여러 번 호출해도 서버 상태가 한 번 호출한 것과 같은 성질로, 네트워크 오류가 났을 때 클라이언트가 안심하고 재시도할 수 있게 해 줍니다. 다만 응답 코드가 매번 같아야 한다는 뜻은 아니어서, DELETE를 두 번 호출하면 두 번째는 404일 수 있지만 서버 상태는 동일하므로 멱등입니다. 분류하면 GET과 HEAD는 안전하면서 멱등하고, PUT과 DELETE는 서버 상태를 바꾸므로 안전하지 않지만 멱등합니다. POST는 호출할 때마다 새 자원이 생길 수 있어 안전하지도 멱등하지도 않습니다. PATCH는 경우에 따라 다른데, {"count": 5}처럼 값을 지정하면 멱등이지만 {"op":"increment"}처럼 증가시키면 멱등이 아닙니다. POST가 멱등하지 않기 때문에 타임아웃 후 재시도하면 중복 주문이 생길 수 있고, 이는 Idempotency-Key 헤더로 서버가 같은 요청을 인식하게 해서 보완합니다.',
 'interview-question/382.mp3'),
(383, 'SERVER_COMMON', 77, 'NORMAL', true,
 'REST와 GraphQL을 비교했을 때 각각 어떤 장단점이 있고, 어떤 상황에서 GraphQL을 선택하시겠습니까?',
 'REST는 자원마다 여러 URI를 두고 서버가 정한 고정 구조로 응답하기 때문에 Over-fetching이나 Under-fetching이 생길 수 있습니다. GraphQL은 보통 단일 엔드포인트에서 클라이언트가 필요한 필드를 지정하므로 필요한 것만, 한 번에 여러 자원을 조회할 수 있습니다. 반면 캐시 측면에서는 REST가 GET과 URI 기반이라 HTTP 캐시가 잘 동작하지만, GraphQL은 POST 위주라 HTTP 캐시 활용이 어려워 클라이언트 캐시가 필요합니다. 또 GraphQL은 스키마가 곧 문서인 강타입 구조라는 장점이 있지만, 깊은 중첩 쿼리로 비용이 폭발할 수 있어 깊이·복잡도 제한이 필요하고, 리졸버 구조상 N+1 문제가 흔해 DataLoader 같은 배치 로딩이 필요합니다. 그래서 단순 CRUD, 공개 API, 캐시가 중요한 서비스에는 REST가 적합하고, 화면마다 필요한 데이터가 다른 모바일이나 BFF 같은 클라이언트가 있을 때 GraphQL을 선택하겠습니다. GraphQL은 REST의 대체재가 아니라 클라이언트 다양성이 큰 문제를 푸는 도구이므로, 운영 경험이 없고 소비자가 단일 웹 프론트뿐이라면 REST가 더 단순합니다.',
 'interview-question/383.mp3'),
(384, 'SERVER_COMMON', 77, 'EASY', true,
 'REST API의 자원 중심 설계란 무엇인지, URI와 HTTP 메서드의 역할을 중심으로 설명해 주시겠어요?',
 'REST에서 URI는 자원, 즉 명사를 가리키고 그 자원에 대한 행위는 HTTP 메서드로 표현합니다. 예를 들어 POST /getUser?id=7이나 GET /deleteOrder/7처럼 행위를 URI에 넣는 것은 잘못된 설계이고, GET /users/7, DELETE /orders/7처럼 설계해야 합니다. 컬렉션은 /orders처럼 복수형으로, 개별 자원은 /orders/1001처럼 식별자로 표현하고, 사용자 7의 주문 목록처럼 계층은 /users/7/orders로 나타냅니다. 필터·정렬·페이징은 /orders?status=PAID&sort=-createdAt&page=2처럼 쿼리로 표현합니다. 동사가 꼭 필요한 동작은 하위 자원이나 상태 변경으로 모델링하는데, 예를 들어 주문 취소는 POST /orders/1001/cancellation처럼 하위 자원으로 만들거나 PATCH /orders/1001로 status를 CANCELED로 바꾸는 상태 변경으로 표현합니다.',
 'interview-question/384.mp3'),
(385, 'SERVER_COMMON', 77, 'EASY', true,
 'API 버전 관리에서 호환성을 깨는 변경(Breaking Change)이란 무엇인지 예를 들어 설명하고, 버전을 표기하는 방식에는 어떤 것들이 있는지 말씀해 주시겠어요?',
 'API를 바꾸면 이미 배포된 앱이나 외부 클라이언트가 깨질 수 있는데, 이렇게 기존 클라이언트를 깨뜨리는 변경을 호환성을 깨는 변경이라고 합니다. 응답 필드의 삭제·이름 변경·타입 변경, 필수 파라미터 추가, 엔드포인트 삭제나 URI 변경, 상태 코드·오류 코드 의미 변경이 여기에 해당하고 새 버전이 필요합니다. 반대로 응답에 필드 추가, 선택적 요청 파라미터 추가, 새 엔드포인트 추가는 호환성을 깨지 않아 버전을 유지할 수 있습니다. 버전 표기 방식으로는 /v1/orders 같은 URI 경로, /orders?version=2 같은 쿼리 파라미터, X-API-Version 같은 커스텀 헤더, Accept: application/vnd.shop.v2+json 같은 Accept 헤더 방식이 있고, URI 경로 방식이 명확해서 가장 널리 쓰입니다. 운영 측면에서는 되도록 깨지 않는 변경으로 흡수하고, 클라이언트가 모르는 필드를 무시하도록 관용적 파싱을 하게 하며, 이전 버전은 Deprecation·Sunset 헤더나 문서로 지원 종료 일정을 공지합니다.',
 'interview-question/385.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 381
(2021, 381, '모든 오류를 200으로 감싸면 클라이언트가 재시도 여부를 판단할 수 없음을 설명', 'ESSENTIAL', 1),
(2022, 381, '업무 규칙 위반을 500으로 내보내면 서버 오류율 지표가 오염됨을 설명', 'ESSENTIAL', 2),
(2023, 381, '재고 부족 오류를 409 Conflict·422 Unprocessable Content 중 최소 1개로 분류하는 방안을 제시', 'ESSENTIAL', 3),
(2024, 381, '오류 본문에 기계가 읽을 수 있는 오류 코드와 사람이 읽을 메시지를 함께 담는 방식을 제시', 'ESSENTIAL', 4),
(2025, 381, 'RFC 9457(Problem Details) 같은 표준 형식으로 오류 본문 형식을 통일함을 언급', 'SUPPLEMENTARY', 5),
(2026, 381, '스택 트레이스·내부 테이블명 같은 구현 세부를 오류 응답에 노출하지 않음을 언급', 'SUPPLEMENTARY', 6),
(2027, 381, '4xx는 클라이언트 잘못, 5xx는 서버 잘못이라는 기준을 명시', 'SUPPLEMENTARY', 7),

-- 질문 382
(2028, 382, '안전은 서버 상태를 바꾸지 않는 성질임을 설명', 'ESSENTIAL', 1),
(2029, 382, '멱등은 여러 번 호출해도 서버 상태가 한 번 호출한 것과 같은 성질임을 설명', 'ESSENTIAL', 2),
(2030, 382, 'GET·PUT·DELETE는 멱등이고 POST는 멱등하지 않음을 명시', 'ESSENTIAL', 3),
(2031, 382, 'PUT·DELETE는 멱등하지만 안전하지 않은 메서드임을 명시', 'ESSENTIAL', 4),
(2032, 382, 'POST 재시도 시 중복 자원이 생길 수 있어 Idempotency-Key 헤더로 보완함을 언급', 'SUPPLEMENTARY', 5),
(2033, 382, 'PATCH는 요청 내용에 따라 멱등 여부가 달라짐을 언급', 'SUPPLEMENTARY', 6),
(2034, 382, '멱등성이 응답 코드가 매번 같아야 한다는 뜻은 아님을 언급', 'SUPPLEMENTARY', 7),

-- 질문 383
(2035, 383, 'GraphQL은 클라이언트가 필요한 필드를 지정해 과다·과소 조회를 줄임을 설명', 'ESSENTIAL', 1),
(2036, 383, 'REST는 GET·URI 기반 HTTP 캐시가 잘 동작하지만 GraphQL은 POST 위주라 활용이 어렵다는 차이를 설명', 'ESSENTIAL', 2),
(2037, 383, '화면마다 필요한 데이터가 다른 모바일·BFF 같은 클라이언트에 GraphQL이 적합함을 제시', 'ESSENTIAL', 3),
(2038, 383, 'GraphQL은 깊은 중첩 쿼리로 비용이 폭발할 수 있어 깊이·복잡도 제한이 필요함을 언급', 'SUPPLEMENTARY', 4),
(2039, 383, 'GraphQL 리졸버의 N+1 문제를 DataLoader(배치 로딩)로 해결함을 언급', 'SUPPLEMENTARY', 5),
(2040, 383, 'GraphQL은 스키마가 곧 문서인 강타입 구조라는 점을 언급', 'SUPPLEMENTARY', 6),

-- 질문 384
(2041, 384, 'URI는 자원(명사)을 가리키고 행위는 HTTP 메서드로 표현함을 설명', 'ESSENTIAL', 1),
(2042, 384, '컬렉션은 복수형, 개별 자원은 식별자로 URI를 표현함을 설명', 'ESSENTIAL', 2),
(2043, 384, '필터·정렬·페이징은 쿼리 파라미터로 표현함을 언급', 'SUPPLEMENTARY', 3),
(2044, 384, 'POST /getUser처럼 행위를 URI에 넣는 설계를 잘못된 예로 제시', 'SUPPLEMENTARY', 4),
(2045, 384, '동사가 꼭 필요한 동작을 하위 자원이나 상태 변경으로 모델링하는 방법을 제시', 'SUPPLEMENTARY', 5),

-- 질문 385
(2046, 385, '호환성을 깨는 변경이 이미 배포된 앱·외부 클라이언트를 깨뜨리는 변경임을 설명', 'ESSENTIAL', 1),
(2047, 385, '응답 필드 삭제·이름 변경·타입 변경, 필수 파라미터 추가, 엔드포인트 삭제·URI 변경, 상태 코드 의미 변경 중 최소 1개를 깨짐 예로 제시', 'ESSENTIAL', 2),
(2048, 385, 'URI 경로·쿼리 파라미터·커스텀 헤더·Accept 헤더 중 최소 2개를 버전 표기 방식으로 제시', 'ESSENTIAL', 3),
(2049, 385, '응답에 필드를 추가하는 것은 호환성을 깨지 않는 변경임을 언급', 'SUPPLEMENTARY', 4),
(2050, 385, '이전 버전은 Deprecation·Sunset 헤더나 문서로 지원 종료 일정을 공지함을 언급', 'SUPPLEMENTARY', 5),
(2051, 385, '클라이언트가 모르는 필드를 무시하도록 하는 관용적 파싱을 언급', 'SUPPLEMENTARY', 6);
