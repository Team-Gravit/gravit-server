-- Unit: 응용 계층 서비스 (Unit ID: 38)
-- Chapter: 네트워크 (Chapter ID: 3)
-- Topic: NETWORK
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-network-unit11 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(186, 'NETWORK', 38, 'HARD', true,
 '사용자가 브라우저에 웹사이트 주소를 입력한 뒤 화면에 페이지가 표시되기까지 응용 계층에서 DNS와 HTTP가 어떻게 이어져 동작하는지 설명하고, HTTP의 비연결성과 상태비저장성이 이 과정에 어떤 영향을 주는지도 함께 말씀해 주세요.',
 '먼저 사용자가 웹사이트 주소를 입력하면 DNS가 동작합니다. DNS는 도메인 이름을 IP 주소로 변환하는 프로토콜로, DNS 서버가 해당 도메인의 IP를 찾아 응답합니다. 사람이 읽기 쉬운 주소를 컴퓨터가 이해할 수 있는 숫자 주소로 바꿔 주는 역할입니다. 그다음 HTTP가 이 IP로 통신을 수행합니다. 브라우저가 서버에 HTTP 요청을 보내면 서버는 HTML, 이미지 등 필요한 데이터를 응답하고, 브라우저가 그 데이터를 화면에 표시합니다. 이때 HTTP의 특징이 과정에 영향을 줍니다. HTTP는 비연결성(Connectionless)이라 요청마다 독립적으로 처리되고 요청이 끝나면 연결이 종료됩니다. 또한 상태비저장성(Stateless)이라 서버가 이전 요청 정보를 저장하지 않기 때문에, 이전에 어떤 요청을 했는지는 다음 요청에 반영되지 않습니다. 요청은 GET, POST, PUT, DELETE 같은 대표 메서드로 구분해 보냅니다.',
 'interview-question/186.mp3'),
(187, 'NETWORK', 38, 'NORMAL', true,
 '원격 접속에 사용하는 SSH와 Telnet은 어떤 차이가 있으며, 서버에 접속할 때 SSH를 선택하는 이유는 무엇인가요?',
 'SSH와 Telnet은 둘 다 원격 시스템에 접속할 때 쓰는 응용 계층 프로토콜입니다. 차이는 암호화 여부입니다. Telnet은 원격 접속용이지만 통신이 암호화되지 않아 보안에 취약합니다. 반면 SSH(Secure Shell)는 원격 시스템에 안전하게 접속하기 위한 암호화 통신 프로토콜로, Telnet과 달리 모든 데이터가 암호화되어 전송되므로 보안성이 높습니다. 그래서 서버에 접속할 때는 SSH를 선택합니다. SSH는 기본 포트로 22번을 사용하고, 공개키 인증을 통해 안전하게 접속할 수 있습니다. 용도로는 서버 관리, 원격 명령 실행, SCP/SFTP를 이용한 파일 전송 등에 사용합니다.',
 'interview-question/187.mp3'),
(188, 'NETWORK', 38, 'NORMAL', true,
 'FTP는 어떤 구조로 파일을 주고받으며, 실제 서비스에서 FTP 대신 FTPS나 SFTP를 사용하는 이유는 무엇인가요?',
 'FTP(File Transfer Protocol)는 파일을 업로드하거나 다운로드할 때 사용하는 응용 계층 프로토콜입니다. 클라이언트가 서버에 접속해 파일을 전송하거나 가져올 수 있는 구조이고, 통신은 명령을 주고받는 명령 채널(제어)과 실제 파일을 옮기는 데이터 채널(전송)을 분리해서 수행합니다. 그리고 보안 강화를 위해서는 FTP 대신 FTPS나 SFTP를 사용합니다. 이 중 SFTP는 SSH 기반이어서 데이터가 암호화된 채로 전송됩니다.',
 'interview-question/188.mp3'),
(189, 'NETWORK', 38, 'EASY', true,
 'SMTP는 어떤 프로토콜이고 어떤 상황에서 사용되는지 설명해 주세요.',
 'SMTP(Simple Mail Transfer Protocol)는 이메일을 전송하는 프로토콜입니다. 메일 클라이언트에서 메일 서버로 메일을 보낼 때 사용하고, 메일 서버 간에 메시지를 전달할 때도 SMTP를 사용합니다. 응용 계층에서 동작하는 프로토콜이며, 포트는 기본적으로 25번을 사용하고 보안 연결을 쓸 때는 587번이나 465번을 사용합니다.',
 'interview-question/189.mp3'),
(190, 'NETWORK', 38, 'EASY', true,
 'OSI 7계층에서 응용 계층은 어떤 계층이며, 어떤 기능을 담당하는지 설명해 주세요.',
 '응용 계층(Application Layer)은 OSI 7계층의 최상위 계층으로, 사용자가 직접 네트워크 서비스를 이용할 수 있게 해 주는 계층입니다. 애플리케이션과 하위 계층 사이의 인터페이스 역할을 하며, 네트워크에서 데이터를 주고받기 위한 규칙을 정의합니다. 주요 기능으로는 네트워크를 통한 서비스 제공과 접근 제어, 클라이언트와 서버 간의 요청(Request)과 응답(Response) 처리, 하위 계층에서 받은 데이터를 사용자에게 표시 가능한 형태로 변환하는 일이 있습니다. 또 각 프로토콜마다 고유한 포트 번호를 사용하며 이 값은 관리자가 변경할 수 있습니다. 대표적인 응용 계층 프로토콜로는 HTTP, DNS, SMTP, FTP, SSH, Telnet 등이 있습니다.',
 'interview-question/190.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 186
(960, 186, 'DNS 서버가 도메인 이름을 IP 주소로 변환해 응답함을 설명', 'ESSENTIAL', 1),
(961, 186, '변환된 IP 주소로 HTTP가 통신을 수행함을 언급', 'ESSENTIAL', 2),
(962, 186, '비연결성으로 요청 후 연결이 종료됨을 서술', 'ESSENTIAL', 3),
(963, 186, '상태비저장성으로 이전 요청 정보를 저장하지 않음을 명시', 'ESSENTIAL', 4),
(964, 186, 'HTTP 요청이 요청마다 독립적으로 처리됨을 언급', 'SUPPLEMENTARY', 5),
(965, 186, '서버가 HTML·이미지 등 필요한 데이터를 응답함을 서술', 'SUPPLEMENTARY', 6),
(966, 186, 'GET·POST·PUT·DELETE 중 최소 1개를 HTTP 대표 메서드로 제시', 'SUPPLEMENTARY', 7),

-- 질문 187
(967, 187, 'Telnet은 암호화되지 않아 보안에 취약함을 언급', 'ESSENTIAL', 1),
(968, 187, 'SSH는 모든 데이터가 암호화되어 전송되므로 보안성이 높음을 설명', 'ESSENTIAL', 2),
(969, 187, 'SSH의 기본 포트가 22번임을 제시', 'SUPPLEMENTARY', 3),
(970, 187, 'SSH가 공개키 인증으로 안전하게 접속할 수 있음을 서술', 'SUPPLEMENTARY', 4),
(971, 187, '서버 관리·원격 명령 실행·파일 전송 중 최소 1개를 SSH 용도로 제시', 'SUPPLEMENTARY', 5),

-- 질문 188
(972, 188, 'FTP가 명령 채널과 데이터 채널을 분리해 통신함을 설명', 'ESSENTIAL', 1),
(973, 188, '보안 강화를 위해 FTPS나 SFTP를 사용함을 제시', 'ESSENTIAL', 2),
(974, 188, 'SFTP가 SSH 기반의 파일 전송 방식임을 명시', 'SUPPLEMENTARY', 3),
(975, 188, '클라이언트가 서버에 접속해 파일을 전송하거나 가져옴을 서술', 'SUPPLEMENTARY', 4),

-- 질문 189
(976, 189, 'SMTP가 이메일을 전송하는 프로토콜임을 언급', 'ESSENTIAL', 1),
(977, 189, '메일 클라이언트에서 메일 서버로 메일을 보낼 때 사용함을 설명', 'ESSENTIAL', 2),
(978, 189, '메일 서버 간에도 SMTP로 메시지가 전달됨을 서술', 'ESSENTIAL', 3),
(979, 189, 'SMTP가 포트 25를 사용함을 명시', 'SUPPLEMENTARY', 4),
(980, 189, '보안 연결 시 587 또는 465 포트를 사용함을 제시', 'SUPPLEMENTARY', 5),
(981, 189, 'SMTP가 응용 계층에서 동작하는 프로토콜임을 명시', 'SUPPLEMENTARY', 6),

-- 질문 190
(982, 190, '응용 계층이 OSI 7계층의 최상위 계층임을 명시', 'ESSENTIAL', 1),
(983, 190, '사용자가 직접 네트워크 서비스를 이용할 수 있게 하는 계층임을 설명', 'ESSENTIAL', 2),
(984, 190, '애플리케이션과 하위 계층 간의 인터페이스 역할을 함을 언급', 'ESSENTIAL', 3),
(985, 190, '클라이언트와 서버 간의 요청과 응답을 처리함을 서술', 'SUPPLEMENTARY', 4),
(986, 190, 'HTTP·DNS·SMTP·FTP 중 최소 2개를 응용 계층 프로토콜로 제시', 'SUPPLEMENTARY', 5),
(987, 190, '각 프로토콜마다 고유한 포트 번호를 사용함을 언급', 'SUPPLEMENTARY', 6);
