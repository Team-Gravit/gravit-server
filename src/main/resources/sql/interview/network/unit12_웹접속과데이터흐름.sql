-- Unit: 웹 접속 과정과 데이터 흐름 (Unit ID: 39)
-- Chapter: 네트워크 (Chapter ID: 3)
-- Topic: NETWORK
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-network-unit12 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(191, 'NETWORK', 39, 'HARD', true,
 '주소창에 `https://www.example.com:443/path?query=123#section`을 입력했을 때, 이 URL의 각 구성요소가 접속 과정의 어느 단계에서 어떻게 쓰이는지 설명해 주세요. 서버로 전송되지 않는 구성요소가 있다면 그것도 함께 말씀해 주세요.',
 'URL은 인터넷 상의 자원에 접근하기 위한 주소 체계이고, 브라우저는 입력된 URL을 먼저 프로토콜·호스트·포트·경로·쿼리로 파싱합니다. 프로토콜인 https는 통신 방식을 정하는 부분으로 HTTP의 보안 버전이며, HTTPS의 기본 포트는 443입니다. 호스트인 www.example.com은 서버의 도메인 이름으로 DNS를 통해 IP 주소로 변환되며, DNS 서버에 이 도메인의 IP 주소를 요청해 93.184.216.34 같은 IP 주소를 응답받는 DNS 조회 단계에서 쓰입니다. 포트 :443은 논리적 연결 지점으로, 브라우저가 앞서 얻은 IP 주소와 포트 정보를 기반으로 서버에 3-Way Handshake를 수행해 TCP 연결을 맺을 때 쓰입니다. 경로 /path는 서버 내 자원의 위치로, 연결된 TCP 위에서 보내는 HTTP 요청에 `GET /path?query=123 HTTP/1.1`처럼 담겨 서버로 전달됩니다. 쿼리 ?query=123은 서버에 전달할 추가 데이터로 키=값 형태이며, 같은 요청에 함께 전달됩니다. 반면 프래그먼트 #section은 문서 내부의 특정 위치를 가리키는 부분이라 서버로 전송되지 않습니다.',
 'interview-question/191.mp3'),
(192, 'NETWORK', 39, 'NORMAL', true,
 '웹 접속 과정에서 3-Way Handshake와 4-Way Handshake는 각각 어느 시점에 수행되는지 차이를 설명해 주세요.',
 '3-Way Handshake는 접속 과정의 앞부분인 TCP 연결 설정 단계에서 수행됩니다. DNS 조회로 도메인의 IP 주소를 확인한 뒤, 브라우저가 그 IP 주소와 포트(443) 정보를 기반으로 서버와 3-Way Handshake를 수행해 연결을 맺고, 이렇게 맺어진 TCP 위에서 비로소 HTTP 요청을 전송합니다. 반대로 4-Way Handshake는 접속 과정의 마지막인 연결 종료 단계에서 수행됩니다. 모든 데이터 전송이 완료되면 4-Way Handshake를 통해 연결이 종료됩니다. 다만 HTTP/1.1 이상에서는 `Connection: keep-alive`로 TCP 연결을 유지할 수 있어서, 응답을 받았다고 바로 연결을 끊지 않고 재사용할 수 있습니다. 정리하면 3-Way Handshake는 연결을 여는 절차, 4-Way Handshake는 연결을 닫는 절차이고, 그 사이에 HTTP 요청과 응답이 오갑니다.',
 'interview-question/192.mp3'),
(193, 'NETWORK', 39, 'NORMAL', true,
 '브라우저가 서버에 보내는 HTTP 요청 메시지와 서버가 돌려주는 HTTP 응답 메시지에는 각각 어떤 정보가 담기는지 차이를 설명해 주세요.',
 'HTTP 요청 메시지는 브라우저가 TCP 연결 위에서 서버에 보내는 메시지로, `GET /path?query=123 HTTP/1.1`처럼 첫 줄에서 GET으로 서버에 요청할 자원의 경로 /path를 지정합니다. 이때 쿼리 파라미터 query=123도 함께 전달됩니다. 또 `Host: www.example.com`처럼 접속 대상 도메인도 함께 전달됩니다. HTTP 응답 메시지는 서버가 요청을 처리하고 해당 자원을 찾아 돌려주는 메시지로, 첫 줄에 `HTTP/1.1 200 OK`처럼 요청 처리 결과 상태가 담깁니다. 이어서 `Content-Type: text/html`처럼 본문의 형식 정보가 전달되고, 응답 본문에는 요청한 웹페이지의 HTML 내용이 담겨 있습니다. 정리하면 요청 메시지는 ''무엇을 달라''는 대상 지정(경로·쿼리·호스트) 중심이고, 응답 메시지는 처리 결과 상태와 실제 자원 데이터 중심이라는 차이가 있습니다. 브라우저는 이 응답 본문의 HTML을 가지고 다음 단계인 렌더링을 수행합니다.',
 'interview-question/193.mp3'),
(194, 'NETWORK', 39, 'EASY', true,
 '서버로부터 HTTP 응답을 받은 뒤 브라우저가 웹페이지를 화면에 그리기까지 어떤 과정을 거치는지 설명해 주세요.',
 '서버가 보낸 HTTP 응답 본문에는 요청한 웹페이지의 HTML 내용이 담겨 있고, 브라우저는 이 HTML을 입력으로 렌더링을 시작합니다. 브라우저는 HTML → CSS → JavaScript 순으로 해석하며, 이 과정에서 DOM 트리와 렌더 트리(Render Tree)를 생성합니다. 그리고 생성된 트리를 바탕으로 최종적으로 화면에 웹페이지를 렌더링합니다. 즉 응답으로 받은 문서를 그대로 보여주는 것이 아니라, 해석 → 트리 생성 → 화면 표시의 순서를 거칩니다. 렌더링이 끝난 뒤 연결은 `Connection: keep-alive`로 유지되거나 4-Way Handshake로 종료됩니다.',
 'interview-question/194.mp3'),
(195, 'NETWORK', 39, 'EASY', true,
 '브라우저 주소창에 URL을 입력한 순간부터 웹페이지가 화면에 표시될 때까지의 전체 흐름을 순서대로 설명해 주세요.',
 '먼저 사용자가 주소창에 URL을 입력하면 브라우저가 URL을 파싱해 프로토콜·호스트·포트·경로·쿼리로 분리합니다. 다음으로 DNS 서버에 도메인(www.example.com)의 IP 주소를 요청해 93.184.216.34 같은 IP 주소를 응답받습니다. 그 IP 주소와 포트(443) 정보를 기반으로 서버에 3-Way Handshake를 수행해 TCP 연결을 맺습니다. 연결된 TCP 위에서 `GET /path?query=123 HTTP/1.1`과 같은 HTTP 요청을 전송하면, 서버는 요청을 처리하고 해당 자원을 찾아 `HTTP/1.1 200 OK`와 HTML 본문이 담긴 HTTP 응답 메시지로 반환합니다. 브라우저는 받은 내용을 HTML → CSS → JavaScript 순으로 해석해 DOM 트리와 렌더 트리를 생성하고 화면에 웹페이지를 렌더링합니다. 마지막으로 HTTP/1.1 이상에서는 `Connection: keep-alive`로 TCP 연결을 유지해 재사용하거나, 모든 데이터 전송이 완료되면 4-Way Handshake를 통해 연결을 종료합니다.',
 'interview-question/195.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 191
(988, 191, '호스트(도메인 이름)가 DNS를 통해 IP 주소로 변환되는 데 쓰임을 설명', 'ESSENTIAL', 1),
(989, 191, '포트(:443) 정보가 서버와 TCP 연결을 맺을 때 쓰임을 언급', 'ESSENTIAL', 2),
(990, 191, '경로(/path)가 서버 내 자원의 위치로 HTTP 요청에 담겨 전달됨을 서술', 'ESSENTIAL', 3),
(991, 191, '프래그먼트(#section)가 서버로 전송되지 않음을 명시', 'ESSENTIAL', 4),
(992, 191, '쿼리(?query=123)가 서버에 전달할 추가 데이터임을 언급', 'SUPPLEMENTARY', 5),
(993, 191, 'HTTPS의 기본 포트가 443임을 제시', 'SUPPLEMENTARY', 6),
(994, 191, '브라우저가 URL을 프로토콜·호스트·포트·경로·쿼리 중 최소 3개 구성요소로 파싱함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 192
(995, 192, '3-Way Handshake가 HTTP 요청 전송 전에 TCP 연결을 맺는 단계임을 설명', 'ESSENTIAL', 1),
(996, 192, '4-Way Handshake가 모든 데이터 전송 완료 후 연결을 종료하는 절차임을 언급', 'ESSENTIAL', 2),
(997, 192, 'HTTP/1.1 이상에서 Connection: keep-alive로 TCP 연결을 유지할 수 있음을 서술', 'SUPPLEMENTARY', 3),
(998, 192, '3-Way Handshake가 IP 주소와 포트 정보를 기반으로 수행됨을 제시', 'SUPPLEMENTARY', 4),

-- 질문 193
(999, 193, '요청 첫 줄에 GET으로 요청 자원 경로(/path)를 지정함을 설명', 'ESSENTIAL', 1),
(1000, 193, '요청에 Host로 접속 대상 도메인이 함께 전달됨을 언급', 'ESSENTIAL', 2),
(1001, 193, '응답 첫 줄에 200 OK로 요청 처리 결과 상태가 담김을 명시', 'ESSENTIAL', 3),
(1002, 193, '응답 본문에 요청한 웹페이지의 HTML 내용이 담김을 서술', 'ESSENTIAL', 4),
(1003, 193, '쿼리 파라미터 query=123이 요청에 함께 전달됨을 언급', 'SUPPLEMENTARY', 5),
(1004, 193, 'Content-Type: text/html로 응답 본문 형식이 전달됨을 언급', 'SUPPLEMENTARY', 6),
(1005, 193, '서버가 요청을 처리해 해당 자원을 찾아 반환함을 제시', 'SUPPLEMENTARY', 7),

-- 질문 194
(1006, 194, '브라우저가 HTML → CSS → JavaScript 순으로 해석함을 설명', 'ESSENTIAL', 1),
(1007, 194, 'DOM 트리·렌더 트리(Render Tree) 중 최소 1개를 해석 결과 생성물로 언급', 'ESSENTIAL', 2),
(1008, 194, '생성한 트리를 바탕으로 웹페이지를 화면에 렌더링함을 서술', 'ESSENTIAL', 3),
(1009, 194, 'HTTP 응답 본문의 HTML이 렌더링의 입력이 됨을 제시', 'SUPPLEMENTARY', 4),

-- 질문 195
(1010, 195, 'URL 입력과 파싱 다음에 DNS 조회로 IP 주소를 확인함을 설명', 'ESSENTIAL', 1),
(1011, 195, 'IP 주소 확인 후 TCP 3-Way Handshake로 연결을 맺음을 언급', 'ESSENTIAL', 2),
(1012, 195, '연결된 TCP 위에서 HTTP 요청을 전송함을 제시', 'ESSENTIAL', 3),
(1013, 195, '응답 수신 뒤 브라우저 렌더링으로 웹페이지가 표시됨을 서술', 'ESSENTIAL', 4),
(1014, 195, '마지막에 연결을 종료하거나 재사용함을 명시', 'SUPPLEMENTARY', 5);
