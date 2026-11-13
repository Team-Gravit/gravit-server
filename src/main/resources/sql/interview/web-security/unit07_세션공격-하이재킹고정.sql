-- Unit: 세션 공격 - 하이재킹, 고정 (Unit ID: 257)
-- Chapter: 웹 보안 (Chapter ID: 23)
-- Topic: WEB_SECURITY
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-web-security-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1464, 'WEB_SECURITY', 257, 'HARD', true,
 '로그인 전후로 세션 ID가 바뀌지 않는 서비스라면 어떤 공격에 취약하고, 어떻게 막아야 하나요?',
 '세션 고정 공격에 취약합니다. 세션 고정은 공격자가 사이트에 접속해 미리 발급받은 세션 ID를 링크 등으로 피해자에게 심어 두는 공격입니다. 로그인 전후에 세션 ID가 바뀌지 않는 서버라면, 피해자가 그 세션 ID 상태로 로그인하는 순간 공격자가 알고 있는 세션 ID가 인증된 세션으로 승격되고, 공격자는 그 세션 ID로 접속해 피해자 계정으로 인증됩니다. 공격자는 세션 ID를 훔칠 필요가 없습니다. 막으려면 로그인 성공 시점에 반드시 세션 ID를 재발급해야 합니다. 기존 세션을 파기하고 새 세션 ID를 발급해 인증 전 세션과 인증 후 세션을 단절시키면, 공격자가 심어 둔 세션 ID는 로그인 순간 쓸모가 없어져 세션 고정이 원천 차단됩니다.',
 'interview-question/1464.mp3'),
(1465, 'WEB_SECURITY', 257, 'NORMAL', true,
 '세션 하이재킹과 세션 고정은 어떻게 다른가요?',
 '세션 하이재킹은 이미 로그인된 피해자의 유효한 세션 ID를 XSS나 스니핑 같은 수단으로 탈취해 그 세션을 가로채는 공격입니다. 반면 세션 고정은 공격자가 미리 발급받아 알고 있는 세션 ID를 피해자에게 주입해 두는 공격입니다. 공격 시점도 다른데, 하이재킹은 피해자의 로그인 이후에 세션을 훔치고, 세션 고정은 피해자의 로그인 이전에 세션 ID를 심어 둡니다. 핵심 방어도 다릅니다. 하이재킹은 HttpOnly와 HTTPS로 세션 ID 노출을 차단하고, 세션 고정은 로그인 성공 시 세션 ID를 재발급해 막습니다.',
 'interview-question/1465.mp3'),
(1466, 'WEB_SECURITY', 257, 'NORMAL', true,
 '쿠키의 HttpOnly 속성과 Secure 속성은 각각 세션 ID 탈취를 어떻게 막나요?',
 'HttpOnly는 자바스크립트의 document.cookie 접근을 차단합니다. 그래서 XSS로 주입된 스크립트가 쿠키를 읽어 유출하는 경로를 막습니다. Secure는 쿠키를 HTTPS 연결에서만 전송하게 해서 평문 노출을 막고, 암호화되지 않은 HTTP 트래픽에서 쿠키를 도청하는 네트워크 스니핑 경로를 막습니다. 다만 HttpOnly는 쿠키 탈취를 막을 뿐 XSS 자체를 막지 못하므로, 스크립트가 실행되면 공격자는 쿠키 없이도 피해자의 브라우저에서 직접 요청을 보낼 수 있어 이스케이프나 CSP 같은 XSS 방어를 별도로 갖춰야 합니다.',
 'interview-question/1466.mp3'),
(1467, 'WEB_SECURITY', 257, 'EASY', true,
 '세션 ID만 탈취돼도 비밀번호 없이 그 사용자로 행세할 수 있는 이유는 무엇인가요?',
 '세션 기반 인증에서 서버는 매 요청마다 아이디와 비밀번호를 다시 확인하지 않고, 쿠키에 담긴 세션 ID가 유효한지만 확인해 사용자를 식별합니다. 서버는 그 세션 ID를 누가 보냈는지 알 방법이 없어서, 공격자가 같은 세션 ID를 보내면 정상 사용자와 구분하지 못합니다. 즉 세션 ID가 곧 인증 상태 그 자체이고, 세션 ID의 기밀성이 무너지면 인증 체계 전체가 무너집니다.',
 'interview-question/1467.mp3'),
(1468, 'WEB_SECURITY', 257, 'EASY', true,
 'IP나 User-Agent 검증만으로 세션 하이재킹을 막기 어려운 이유는 무엇인가요?',
 'IP/User-Agent 검증은 세션 생성 시의 IP·브라우저 정보와 요청 시의 값을 비교해 이상 접근을 탐지하는 보조 수단일 뿐 완전한 방어가 아닙니다. 모바일 환경에서는 정상 사용자도 IP가 수시로 바뀌어 오탐이 생기고, User-Agent는 공격자가 얼마든지 위조할 수 있습니다. IP/User-Agent 검증은 세션 ID 재발급, HttpOnly·Secure, HTTPS 같은 핵심 방어 위에 얹는 탐지 계층입니다.',
 'interview-question/1468.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1464
(6798, 1464, '세션 고정 공격에 취약하다고 언급', 'ESSENTIAL', 1),
(6799, 1464, '공격자가 미리 발급받은 세션 ID를 피해자에게 심어 둔다고 설명', 'ESSENTIAL', 2),
(6800, 1464, '피해자의 로그인으로 공격자의 세션 ID가 인증된 세션으로 승격된다고 설명', 'ESSENTIAL', 3),
(6801, 1464, '로그인 성공 시점에 세션 ID를 재발급해야 한다고 제시', 'ESSENTIAL', 4),
(6802, 1464, '인증 전 세션과 인증 후 세션을 단절시킨다고 설명', 'SUPPLEMENTARY', 5),
(6803, 1464, '공격자가 세션 ID를 훔칠 필요가 없다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1465
(6804, 1465, '세션 하이재킹은 피해자의 세션 ID를 탈취한다고 설명', 'ESSENTIAL', 1),
(6805, 1465, '세션 고정은 공격자가 미리 발급받은 세션 ID를 피해자에게 주입한다고 설명', 'ESSENTIAL', 2),
(6806, 1465, '세션 고정은 피해자 로그인 이전에 세션 ID를 심어 둔다고 언급', 'SUPPLEMENTARY', 3),
(6807, 1465, '세션 고정의 핵심 방어가 로그인 성공 시 세션 ID 재발급이라고 언급', 'SUPPLEMENTARY', 4),
(6808, 1465, '세션 하이재킹의 핵심 방어가 HttpOnly·HTTPS로 노출을 차단하는 것이라고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1466
(6809, 1466, 'HttpOnly가 자바스크립트의 document.cookie 접근을 차단한다고 설명', 'ESSENTIAL', 1),
(6810, 1466, 'Secure가 쿠키를 HTTPS 연결에서만 전송한다고 설명', 'ESSENTIAL', 2),
(6811, 1466, 'HttpOnly가 XSS로 인한 쿠키 유출을 막는다고 언급', 'SUPPLEMENTARY', 3),
(6812, 1466, 'Secure가 평문 노출을 막아 네트워크 스니핑에 대응한다고 언급', 'SUPPLEMENTARY', 4),
(6813, 1466, 'HttpOnly가 XSS 자체를 막지 못한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1467
(6814, 1467, '서버가 세션 ID가 유효한지만 확인해 사용자를 식별한다고 설명', 'ESSENTIAL', 1),
(6815, 1467, '서버는 세션 ID를 누가 보냈는지 알 방법이 없다고 언급', 'ESSENTIAL', 2),
(6816, 1467, '서버가 매 요청마다 아이디와 비밀번호를 다시 확인하지 않는다고 언급', 'SUPPLEMENTARY', 3),
(6817, 1467, '세션 ID의 기밀성이 무너지면 인증 체계 전체가 무너진다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1468
(6818, 1468, '정상 사용자도 IP가 바뀔 수 있어 오탐이 생긴다고 설명', 'ESSENTIAL', 1),
(6819, 1468, 'User-Agent는 공격자가 위조할 수 있다고 언급', 'ESSENTIAL', 2),
(6820, 1468, 'IP/User-Agent 검증은 핵심 방어 위에 얹는 탐지 계층이라고 설명', 'SUPPLEMENTARY', 3),
(6821, 1468, '세션 생성 시의 IP·브라우저 정보와 요청 시의 값을 비교한다고 설명', 'SUPPLEMENTARY', 4);
