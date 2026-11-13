-- Unit: 인증과 인가 - 세션 vs JWT (Unit ID: 256)
-- Chapter: 웹 보안 (Chapter ID: 23)
-- Topic: WEB_SECURITY
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-web-security-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1459, 'WEB_SECURITY', 256, 'HARD', true,
 'JWT로 인증하는 서비스에서 토큰 탈취가 의심되는 사용자를 바로 차단해야 한다면 어떻게 설계하시겠어요?',
 'JWT는 서버가 아무것도 저장하지 않는 스테이트리스 방식이라, 발급된 토큰은 만료 전까지 서버가 강제로 회수하기 어렵습니다. 그래서 먼저 토큰을 Access Token과 Refresh Token으로 나눕니다. Access Token은 수명을 수 분에서 수십 분으로 짧게 설정해 탈취 피해를 최소화하고, Refresh Token은 서버 DB에 저장해 두었다가 유출이 의심되면 서버에서 폐기해 재발급을 차단합니다. 다만 이것만으로는 이미 발급된 Access Token이 만료될 때까지 남습니다. JWT를 쓰면서도 즉시 차단이 필요하다면 결국 블랙리스트 같은 일부 상태 관리를 도입해야 합니다. Refresh Token을 서버에 저장하는 순간 완전한 스테이트리스는 포기하는 것이고, 이는 세션 방식과의 절충입니다.',
 'interview-question/1459.mp3'),
(1460, 'WEB_SECURITY', 256, 'NORMAL', true,
 '인증 실패와 인가 실패를 서버는 응답에서 어떻게 구분하나요?',
 '인증은 사용자가 누구인지 확인하는 과정이고, 인가는 확인된 사용자에게 어떤 권한을 허용할지 결정하는 과정입니다. 인증은 인가보다 먼저 수행됩니다. 인증에 실패하면 401 Unauthorized로 응답하고, 인증은 되었으나 권한이 없으면 403 Forbidden으로 응답합니다. 예를 들어 관리자만 게시글을 삭제할 수 있는데 권한이 없는 사용자가 삭제를 시도하면 인가 실패입니다. 여기서 HTTP 상태 코드의 이름과 실제 의미가 어긋납니다. 401은 이름과 달리 인증되지 않음을 의미합니다.',
 'interview-question/1460.mp3'),
(1461, 'WEB_SECURITY', 256, 'NORMAL', true,
 '서버를 여러 대로 늘릴 때 세션 방식과 JWT 방식 중 어느 쪽이 유리한가요? 왜 그런가요?',
 'JWT 방식이 수평 확장에 유리합니다. 세션 방식은 로그인에 성공하면 서버가 세션 저장소에 사용자 정보를 기록하는 스테이트풀 방식이라, 서버가 여러 대로 늘어나면 Redis 같은 세션 저장소를 공유해야 하는 부담이 생깁니다. 반면 JWT 방식은 서버가 서명된 토큰을 발급할 뿐 아무것도 저장하지 않는 스테이트리스 방식이고, 요청이 오면 서명만 검증해 사용자를 식별하므로 저장소 조회가 필요 없습니다. 저장소 조회가 없어 서버 확장에 유리합니다.',
 'interview-question/1461.mp3'),
(1462, 'WEB_SECURITY', 256, 'EASY', true,
 'JWT의 서명은 어떤 원리로 토큰 위변조를 탐지하나요?',
 'JWT의 Signature는 Header와 Payload를 서버만 아는 비밀 키로 서명한 값입니다. 서버는 요청으로 받은 토큰의 Header와 Payload를 자신의 비밀 키로 다시 서명해 보고, 예를 들어 HMAC-SHA256으로 재계산한 값이 토큰에 붙어 온 Signature와 일치하는지 비교합니다. 일치하면 위변조가 없다고 보고 신뢰하고, 일치하지 않으면 조작된 토큰으로 보고 거부합니다. 공격자가 Payload를 조작하면 서명이 달라지므로 위변조가 즉시 탐지됩니다. 즉 서명은 내용을 숨기는 것이 아니라 무결성을 보장하는 장치입니다.',
 'interview-question/1462.mp3'),
(1463, 'WEB_SECURITY', 256, 'EASY', true,
 'JWT의 Payload에 비밀번호 같은 민감 정보를 넣으면 안 되는 이유는 무엇인가요?',
 'JWT의 Payload에는 사용자 식별자, 만료 시각 같은 클레임을 담는데, Payload는 암호화가 아니라 Base64URL 인코딩일 뿐입니다. 그래서 누구나 디코딩해 내용을 볼 수 있습니다. 서명 역시 내용을 숨기는 장치가 아니라 무결성을 보장하는 장치입니다. 따라서 비밀번호 같은 민감 정보를 Payload에 넣어서는 안 됩니다.',
 'interview-question/1463.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1459
(6771, 1459, '발급된 JWT는 만료 전까지 서버가 강제로 회수하기 어렵다고 언급', 'ESSENTIAL', 1),
(6772, 1459, 'Access Token 수명 단축, 서버에 저장한 Refresh Token 폐기 중 최소 1개를 제시', 'ESSENTIAL', 2),
(6773, 1459, 'JWT로 즉시 차단하려면 서버가 일부 상태 관리를 도입해야 한다고 설명', 'ESSENTIAL', 3),
(6774, 1459, '즉시 차단을 위한 상태 관리로 블랙리스트를 언급', 'SUPPLEMENTARY', 4),
(6775, 1459, 'Refresh Token을 서버에 저장하면 완전한 스테이트리스를 포기하게 된다고 언급', 'SUPPLEMENTARY', 5),
(6776, 1459, '일부 상태 관리 도입은 세션 방식과의 절충이라고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1460
(6777, 1460, '인증에 실패하면 401 Unauthorized로 응답한다고 언급', 'ESSENTIAL', 1),
(6778, 1460, '인증은 되었으나 권한이 없으면 403 Forbidden으로 응답한다고 언급', 'ESSENTIAL', 2),
(6779, 1460, '인증은 사용자가 누구인지 확인하는 과정이라고 설명', 'SUPPLEMENTARY', 3),
(6780, 1460, '인가는 확인된 사용자에게 허용할 권한을 결정하는 과정이라고 설명', 'SUPPLEMENTARY', 4),
(6781, 1460, '401 Unauthorized라는 이름이 실제 의미와 어긋난다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1461
(6782, 1461, '세션 방식은 서버가 세션 저장소에 인증 상태를 저장한다고 설명', 'ESSENTIAL', 1),
(6783, 1461, '세션 방식은 서버가 늘어나면 세션 저장소를 공유해야 한다고 설명', 'ESSENTIAL', 2),
(6784, 1461, 'JWT 방식은 저장소 조회 없이 서명 검증만으로 사용자를 식별한다고 설명', 'ESSENTIAL', 3),
(6785, 1461, 'JWT 방식이 수평 확장에 유리하다고 언급', 'ESSENTIAL', 4),
(6786, 1461, '세션 저장소 공유에 Redis를 사용할 수 있다고 언급', 'SUPPLEMENTARY', 5),
(6787, 1461, 'JWT 방식은 서버가 상태를 갖지 않는 스테이트리스 방식이라고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1462
(6788, 1462, '서버가 받은 토큰의 Header와 Payload를 비밀 키로 다시 서명한다고 설명', 'ESSENTIAL', 1),
(6789, 1462, '다시 서명한 결과를 토큰에 붙어 온 Signature와 비교한다고 설명', 'ESSENTIAL', 2),
(6790, 1462, 'Signature와 일치하지 않으면 조작된 토큰으로 거부한다고 설명', 'ESSENTIAL', 3),
(6791, 1462, '서명은 무결성을 보장하는 장치라고 언급', 'SUPPLEMENTARY', 4),
(6792, 1462, 'HMAC-SHA256으로 서명을 재계산한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1463
(6793, 1463, 'Payload는 암호화가 아니라 인코딩일 뿐이라고 설명', 'ESSENTIAL', 1),
(6794, 1463, '누구나 Payload를 디코딩해 내용을 볼 수 있다고 설명', 'ESSENTIAL', 2),
(6795, 1463, 'Payload가 Base64URL로 인코딩된다고 언급', 'SUPPLEMENTARY', 3),
(6796, 1463, '서명은 내용을 숨기는 장치가 아니라고 언급', 'SUPPLEMENTARY', 4),
(6797, 1463, 'Payload에는 클레임을 담는다고 언급', 'SUPPLEMENTARY', 5);
