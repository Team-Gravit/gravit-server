-- Unit: HTTP 심화 - 버전과 캐시 (Unit ID: 239)
-- Chapter: 네트워크 (Chapter ID: 3)
-- Topic: NETWORK
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-network-unit18 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1374, 'NETWORK', 239, 'HARD', true,
 '패킷 손실이 잦은 모바일 망에서 HTTP/2로 바꿨는데도 응답이 자주 막힌다면 원인은 무엇이고 어떻게 해결하나요?',
 '원인은 TCP 계층의 HOL 블로킹입니다. HTTP/2는 멀티플렉싱으로 HTTP 계층의 HOL 블로킹은 해소했지만 여전히 TCP 위에서 동작하므로 TCP 계층의 HOL 블로킹은 남아 있습니다. 패킷 하나가 유실되면 TCP가 순서를 보장하느라 그 뒤에 도착한 모든 스트림의 데이터가 함께 대기합니다. 해결책은 HTTP/3입니다. HTTP/3는 TCP 대신 UDP 기반의 QUIC 위에서 동작하고, QUIC은 스트림별로 독립적으로 손실을 복구하므로 한 스트림의 패킷 유실이 다른 스트림을 막지 않습니다.',
 'interview-question/1374.mp3'),
(1375, 'NETWORK', 239, 'NORMAL', true,
 'HTTP/1.1과 HTTP/2는 한 연결에서 여러 요청을 처리하는 방식이 어떻게 다른가요?',
 'HTTP/1.1은 지속 연결(Keep-Alive)을 기본값으로 하여 하나의 TCP 연결로 여러 요청·응답을 처리합니다. 다만 앞선 요청의 처리가 늦어지면 같은 연결의 뒤 요청 전부가 대기하는 HOL 블로킹이 생깁니다. 파이프라이닝은 응답을 기다리지 않고 여러 요청을 연속 전송하는 기능이지만, 응답은 반드시 요청 순서대로 와야 해서 첫 응답이 느리면 뒤 응답이 모두 막히고, 구현 문제로 대부분의 브라우저가 비활성화했습니다. 반면 HTTP/2는 하나의 연결을 여러 스트림으로 나눠 쓰고, 멀티플렉싱으로 여러 요청·응답 스트림이 하나의 TCP 연결에서 순서 제약 없이 병렬 처리됩니다. 이로써 HTTP 계층의 HOL 블로킹이 해소됩니다.',
 'interview-question/1375.mp3'),
(1376, 'NETWORK', 239, 'NORMAL', true,
 '응답에 no-cache를 붙였을 때와 no-store를 붙였을 때 캐시는 각각 어떻게 동작하나요?',
 'no-cache는 이름과 달리 캐시 금지가 아닙니다. 응답을 저장은 하되, 사용 전 반드시 서버에 재검증을 요구합니다. 재검증은 조건부 요청으로 서버에 변경 여부를 확인하는 것으로, 미변경이면 304 응답을 받아 캐시를 재사용하고 변경되었으면 200 응답으로 새 본문을 받아 캐시를 교체합니다. 반면 no-store는 응답을 아예 저장하지 못하게 하는, 저장 자체를 금지하는 지시자로 민감 정보에 씁니다. 실무에서는 HTML을 no-cache로 매번 재검증하는 전략을 많이 씁니다.',
 'interview-question/1376.mp3'),
(1377, 'NETWORK', 239, 'EASY', true,
 '신선도가 만료된 캐시를 ETag로 재검증하는 과정은 어떻게 동작하나요?',
 '서버는 응답 본문의 고유 식별값인 ETag를 내려줍니다. 신선도가 만료되면 클라이언트는 조건부 요청을 보내면서 If-None-Match 헤더에 그 ETag 값을 담아 서버에 보냅니다. 서버가 비교해 값이 같아 미변경이면 304 응답을 받아 캐시를 재사용하고 신선도를 갱신합니다. 304 Not Modified 응답에는 본문이 없으므로 자원이 크더라도 재검증 비용은 헤더 교환 수준으로 작습니다. 변경되었으면 200 응답으로 새 본문을 받아 캐시를 교체합니다.',
 'interview-question/1377.mp3'),
(1378, 'NETWORK', 239, 'EASY', true,
 'HTTP/3의 연결 마이그레이션은 무엇이고 어떻게 가능한가요?',
 '연결 마이그레이션은 네트워크가 바뀌어도 연결을 끊지 않고 유지하는 HTTP/3의 특징입니다. 예를 들어 Wi-Fi에서 LTE로 네트워크가 바뀌어도 연결이 유지됩니다. 이것이 가능한 이유는 HTTP/3가 동작하는 UDP 기반의 QUIC이 연결을 IP·포트가 아닌 커넥션 ID로 식별하기 때문입니다.',
 'interview-question/1378.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1374
(6367, 1374, 'HTTP/2에서도 TCP 계층의 HOL 블로킹이 남아 있다고 설명', 'ESSENTIAL', 1),
(6368, 1374, '해법으로 HTTP/3를 제시', 'ESSENTIAL', 2),
(6369, 1374, 'QUIC은 스트림별로 독립적으로 손실을 복구한다고 설명', 'ESSENTIAL', 3),
(6370, 1374, '패킷 하나가 유실되면 그 뒤에 도착한 모든 스트림의 데이터가 함께 대기한다고 설명', 'SUPPLEMENTARY', 4),
(6371, 1374, 'HTTP/3가 TCP 대신 UDP 기반의 QUIC 위에서 동작한다고 언급', 'SUPPLEMENTARY', 5),
(6372, 1374, 'HTTP/2가 TCP 위에서 동작한다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1375
(6373, 1375, 'HTTP/1.1에서는 앞선 요청이 늦어지면 같은 연결의 뒤 요청 전부가 대기한다고 설명', 'ESSENTIAL', 1),
(6374, 1375, 'HTTP/2는 여러 요청·응답을 순서 제약 없이 병렬 처리한다고 설명', 'ESSENTIAL', 2),
(6375, 1375, 'HTTP/1.1은 지속 연결로 하나의 TCP 연결에서 여러 요청·응답을 처리한다고 언급', 'SUPPLEMENTARY', 3),
(6376, 1375, 'HTTP/2가 하나의 연결을 여러 스트림으로 나눠 쓴다고 언급', 'SUPPLEMENTARY', 4),
(6377, 1375, '파이프라이닝은 응답이 반드시 요청 순서대로 와야 한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1376
(6378, 1376, 'no-cache는 응답 저장을 허용한다고 설명', 'ESSENTIAL', 1),
(6379, 1376, 'no-cache는 사용 전 반드시 서버에 재검증을 요구한다고 설명', 'ESSENTIAL', 2),
(6380, 1376, 'no-store는 응답 저장 자체를 금지한다고 설명', 'ESSENTIAL', 3),
(6381, 1376, '재검증에서 미변경이면 304 응답을 받아 캐시를 재사용한다고 설명', 'SUPPLEMENTARY', 4),
(6382, 1376, 'no-store를 민감 정보에 쓴다고 언급', 'SUPPLEMENTARY', 5),
(6383, 1376, 'HTML을 no-cache로 매번 재검증하는 전략을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1377
(6384, 1377, '클라이언트가 If-None-Match로 ETag 값을 서버에 보낸다고 설명', 'ESSENTIAL', 1),
(6385, 1377, '미변경이면 304 응답을 받아 캐시를 재사용한다고 설명', 'ESSENTIAL', 2),
(6386, 1377, '변경되었으면 200 응답으로 새 본문을 받아 캐시를 교체한다고 설명', 'ESSENTIAL', 3),
(6387, 1377, 'ETag가 응답 본문의 고유 식별값이라고 설명', 'SUPPLEMENTARY', 4),
(6388, 1377, '304 응답에는 본문이 없어 재검증 비용이 작다고 설명', 'SUPPLEMENTARY', 5),
(6389, 1377, '304 응답 후 신선도를 갱신한다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1378
(6390, 1378, '네트워크가 바뀌어도 연결을 끊지 않고 유지한다고 설명', 'ESSENTIAL', 1),
(6391, 1378, '연결을 IP·포트가 아닌 커넥션 ID로 식별한다고 설명', 'ESSENTIAL', 2),
(6392, 1378, 'Wi-Fi에서 LTE로 바뀌는 상황을 예로 언급', 'SUPPLEMENTARY', 3),
(6393, 1378, 'HTTP/3가 UDP 기반의 QUIC 위에서 동작한다고 언급', 'SUPPLEMENTARY', 4);
