-- Unit: REST API (Unit ID: 242)
-- Chapter: 네트워크 (Chapter ID: 3)
-- Topic: NETWORK
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-network-unit21 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1389, 'NETWORK', 242, 'HARD', true,
 '하나의 URI에 POST 요청만 보내 모든 기능을 처리하는 API가 있습니다. REST답게 개선하려면 무엇을 바꿔야 하나요?',
 '단일 URI에 POST만 사용하는 구조는 HTTP를 단순 전송 수단으로만 쓰는 리처드슨 성숙도 모델 0단계에 해당합니다. 먼저 자원별로 URI를 구분해 자원을 URI로 식별하게 해야 합니다. 다음으로 자원에 대한 행위를 URI가 아닌 HTTP 메서드로 의미에 맞게 표현해, 조회는 GET, 생성은 POST, 전체 교체는 PUT, 부분 수정은 PATCH, 삭제는 DELETE를 쓰도록 바꿉니다. 여기에 처리 결과까지 HTTP 상태 코드로 명확히 전달하면, HTTP 메서드와 상태 코드를 의미에 맞게 쓰는 2단계가 되며 이것이 실무 대부분의 API가 목표로 하는 수준입니다.',
 NULL),
(1390, 'NETWORK', 242, 'NORMAL', true,
 'PUT과 PATCH는 어떻게 다른가요?',
 'PUT은 자원 전체 교체에 쓰이고, PATCH는 자원 부분 수정에 쓰입니다. 멱등성에서도 차이가 있어서 PUT은 같은 데이터로 전체 교체를 반복해도 최종 상태가 동일하므로 멱등이지만, PATCH는 멱등이 아닙니다. 두 메서드 모두 안전성은 없습니다.',
 NULL),
(1391, 'NETWORK', 242, 'NORMAL', true,
 '실시간 채팅 기능을 만들 때 REST API 대신 웹소켓을 쓰는 이유는 무엇인가요?',
 'REST는 클라이언트가 주도하는 요청-응답 방식으로, 클라이언트가 요청해야만 데이터를 받을 수 있습니다. 또 요청마다 처리 후 연결이 종료됩니다. 반면 웹소켓은 양방향 통신으로 서버가 먼저 데이터를 보낼 수 있고, 한 번 연결한 뒤 연결을 지속 유지합니다. 채팅처럼 서버가 먼저 데이터를 밀어줘야 하는 실시간 양방향 통신이 필요하면 웹소켓을 선택합니다. REST는 일반적인 CRUD나 자원 조회·관리에 적합합니다.',
 NULL),
(1392, 'NETWORK', 242, 'EASY', true,
 '멱등성이란 무엇이고, PUT 메서드가 멱등인 이유는 무엇인가요?',
 '멱등성은 같은 요청을 여러 번 보내도 결과가 한 번 보낸 것과 같은 성질입니다. PUT은 자원 전체 교체에 쓰이는 메서드인데, 같은 데이터로 전체 교체를 반복해도 최종 상태가 동일하기 때문에 멱등입니다. 반면 POST는 반복할 때마다 새 자원이 생성되므로 멱등이 아닙니다.',
 NULL),
(1393, 'NETWORK', 242, 'EASY', true,
 'REST API의 URI에 동사 대신 명사를 쓰는 이유는 무엇인가요?',
 'REST에서는 모든 것을 자원으로 보고, 자원은 URI로 식별합니다. 자원에 대한 행위는 GET, POST, PUT, DELETE 같은 HTTP 메서드가 표현하기 때문에 URI에는 동사가 아닌 명사를 사용합니다. 예를 들어 사용자 삭제를 URI 끝에 delete를 붙여 POST로 보내는 대신 사용자 URI에 DELETE 메서드를 보내는 식입니다. 또한 계층 관계는 슬래시로 표현해 특정 사용자의 게시글처럼 나타냅니다.',
 NULL);

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1389
(6441, 1389, '자원별로 URI를 구분해야 한다고 설명', 'ESSENTIAL', 1),
(6442, 1389, '자원에 대한 행위를 의미에 맞는 HTTP 메서드로 표현해야 한다고 설명', 'ESSENTIAL', 2),
(6443, 1389, '처리 결과를 의미에 맞는 HTTP 상태 코드로 전달해야 한다고 언급', 'SUPPLEMENTARY', 3),
(6444, 1389, '현재 구조가 리처드슨 성숙도 모델 0단계에 해당한다고 언급', 'SUPPLEMENTARY', 4),
(6445, 1389, '실무 API가 목표로 하는 수준이 리처드슨 성숙도 모델 2단계라고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1390
(6446, 1390, 'PUT은 자원 전체 교체에 쓰인다고 설명', 'ESSENTIAL', 1),
(6447, 1390, 'PATCH는 자원 부분 수정에 쓰인다고 설명', 'ESSENTIAL', 2),
(6448, 1390, 'PUT은 멱등이고 PATCH는 멱등이 아니라고 구분', 'ESSENTIAL', 3),
(6449, 1390, 'PUT과 PATCH 모두 안전성이 없다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1391
(6450, 1391, 'REST는 클라이언트가 요청해야만 데이터를 받을 수 있다고 설명', 'ESSENTIAL', 1),
(6451, 1391, '웹소켓은 서버가 먼저 데이터를 보낼 수 있다고 설명', 'ESSENTIAL', 2),
(6452, 1391, '웹소켓은 한 번 연결한 뒤 연결을 지속 유지한다고 설명', 'SUPPLEMENTARY', 3),
(6453, 1391, 'REST는 요청마다 처리 후 연결을 종료한다고 언급', 'SUPPLEMENTARY', 4),
(6454, 1391, 'REST는 일반적인 CRUD에 적합하다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1392
(6455, 1392, '멱등성은 같은 요청을 여러 번 보내도 결과가 한 번 보낸 것과 같은 성질이라고 설명', 'ESSENTIAL', 1),
(6456, 1392, 'PUT은 같은 데이터로 전체 교체를 반복해도 최종 상태가 동일하다고 설명', 'ESSENTIAL', 2),
(6457, 1392, 'POST는 반복할 때마다 새 자원이 생성된다고 언급', 'SUPPLEMENTARY', 3),
(6458, 1392, 'PUT의 용도가 자원 전체 교체라고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1393
(6459, 1393, 'REST에서 자원은 URI로 식별한다고 설명', 'ESSENTIAL', 1),
(6460, 1393, '자원에 대한 행위는 HTTP 메서드가 표현한다고 설명', 'ESSENTIAL', 2),
(6461, 1393, '삭제 행위를 URI에 쓰지 않고 DELETE 메서드로 표현하는 예를 제시', 'SUPPLEMENTARY', 3),
(6462, 1393, 'URI의 계층 관계를 슬래시로 표현한다고 언급', 'SUPPLEMENTARY', 4);
