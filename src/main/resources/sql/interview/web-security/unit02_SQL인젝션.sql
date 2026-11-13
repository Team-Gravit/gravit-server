-- Unit: SQL 인젝션 (Unit ID: 252)
-- Chapter: 웹 보안 (Chapter ID: 23)
-- Topic: WEB_SECURITY
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-web-security-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1439, 'WEB_SECURITY', 252, 'HARD', true,
 '로그인 기능에서 비밀번호를 몰라도 인증이 통과되는 SQL 인젝션이 발견됐습니다. 어떻게 이런 일이 가능했을까요?',
 '애플리케이션이 사용자 입력을 문자열 연결로 SQL 쿼리에 끼워 넣었기 때문입니다. 이렇게 하면 입력값이 데이터가 아니라 SQL 구문으로 해석되어, 공격자가 쿼리의 논리 자체를 바꿀 수 있습니다. 공격자는 비밀번호 칸에 따옴표와 OR, 그리고 항상 참인 조건을 섞어 넣습니다. 그러면 항상 참인 조건이 OR로 연결되어 WHERE 조건 전체가 항상 참이 되고, 비밀번호 없이 인증이 통과됩니다. 가장 근본적인 방어는 쿼리 구조를 먼저 확정하고 입력값을 데이터로만 채우는 Prepared Statement입니다.',
 'interview-question/1439.mp3'),
(1440, 'WEB_SECURITY', 252, 'NORMAL', true,
 'Error-based와 Blind SQL 인젝션은 정보를 알아내는 방식이 어떻게 다른가요?',
 'Error-based는 DB 에러 메시지에 노출되는 정보를 이용해 데이터베이스 구조를 파악하는 방식입니다. 반면 Blind는 응답에 데이터가 직접 보이지 않을 때 쓰는 방식으로, 참/거짓 응답이나 시간 지연을 보고 정보를 추론합니다. 이 밖에 UNION 구문으로 다른 테이블의 데이터를 결과에 합쳐 추출하는 Union-based도 있습니다. 추가 방어 대책으로는 상세 DB 오류를 사용자에게 노출하지 않는 에러 메시지 은닉이 있습니다.',
 'interview-question/1440.mp3'),
(1441, 'WEB_SECURITY', 252, 'NORMAL', true,
 'ORM을 쓰면 SQL 인젝션을 걱정하지 않아도 되나요? 왜 그런가요?',
 'JPA나 SQLAlchemy 같은 ORM은 내부적으로 파라미터 바인딩을 사용하므로 기본적으로 SQL 인젝션에 안전합니다. 파라미터 바인딩은 쿼리 구조를 먼저 확정한 뒤 입력값을 데이터로만 채워 넣기 때문에, 입력값이 SQL 문법을 담고 있어도 구문으로 해석되지 않습니다. 단, ORM에서 직접 SQL 문자열을 조립하는 경우에는 여전히 취약할 수 있으므로 걱정하지 않아도 되는 것은 아닙니다.',
 'interview-question/1441.mp3'),
(1442, 'WEB_SECURITY', 252, 'EASY', true,
 'SQL 인젝션이란 무엇이고, 왜 치명적인 웹 공격으로 꼽히나요?',
 'SQL 인젝션은 사용자 입력값이 SQL 쿼리의 일부로 그대로 해석되어, 공격자가 데이터베이스를 임의로 조작할 수 있게 되는 취약점입니다. OWASP A03 인젝션에 속합니다. 데이터베이스에 직접 도달하는 공격이므로 피해 규모가 매우 큽니다. 회원 전체의 개인정보나 비밀번호 탈취, 관리자 계정 인증 우회 후 시스템 장악, 데이터 전체 삭제로 이어질 수 있고, 대형 개인정보 유출 사고의 상당수가 이 취약점에서 비롯되었습니다.',
 'interview-question/1442.mp3'),
(1443, 'WEB_SECURITY', 252, 'EASY', true,
 'Prepared Statement는 어떤 원리로 SQL 인젝션을 막나요?',
 'Prepared Statement, 즉 파라미터 바인딩은 SQL 인젝션의 가장 근본적인 방어입니다. 쿼리의 구조를 먼저 확정한 뒤 입력값을 데이터로만 채워 넣습니다. 그래서 입력값이 아무리 SQL 문법을 담고 있어도 구문으로 해석되지 않습니다. 예를 들어 항상 참이 되는 조건을 넣어도 그 문자열 전체가 하나의 아이디 값으로 취급되어 조회에 실패할 뿐, 쿼리 구조는 바뀌지 않습니다.',
 'interview-question/1443.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1439
(6681, 1439, '입력값을 문자열 연결로 SQL 쿼리에 끼워 넣었다고 설명', 'ESSENTIAL', 1),
(6682, 1439, '입력값에 OR와 항상 참인 조건을 섞어 넣었다고 설명', 'ESSENTIAL', 2),
(6683, 1439, 'WHERE 조건 전체가 항상 참이 된다고 설명', 'ESSENTIAL', 3),
(6684, 1439, '입력값이 데이터가 아니라 SQL 구문으로 해석되었다고 언급', 'SUPPLEMENTARY', 4),
(6685, 1439, 'Prepared Statement를 방어책으로 제시', 'SUPPLEMENTARY', 5),

-- 질문 1440
(6686, 1440, 'Error-based는 DB 에러 메시지에 노출되는 정보를 이용한다고 설명', 'ESSENTIAL', 1),
(6687, 1440, 'Blind는 참/거짓·시간 지연 중 최소 1개로 추론한다고 설명', 'ESSENTIAL', 2),
(6688, 1440, 'Blind는 응답에 데이터가 직접 보이지 않을 때 쓰인다고 언급', 'SUPPLEMENTARY', 3),
(6689, 1440, 'Union-based는 UNION 구문으로 다른 테이블의 데이터를 합쳐 추출한다고 언급', 'SUPPLEMENTARY', 4),
(6690, 1440, '상세 DB 오류를 사용자에게 노출하지 않는 에러 메시지 은닉을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1441
(6691, 1441, 'ORM은 내부적으로 파라미터 바인딩을 사용한다고 설명', 'ESSENTIAL', 1),
(6692, 1441, 'ORM에서 직접 SQL 문자열을 조립하면 여전히 취약할 수 있다고 설명', 'ESSENTIAL', 2),
(6693, 1441, '파라미터 바인딩에서는 입력값이 구문으로 해석되지 않는다고 설명', 'SUPPLEMENTARY', 3),
(6694, 1441, 'JPA·SQLAlchemy 중 최소 1개를 ORM 예로 언급', 'SUPPLEMENTARY', 4),

-- 질문 1442
(6695, 1442, '사용자 입력값이 SQL 쿼리의 일부로 그대로 해석되는 취약점이라고 설명', 'ESSENTIAL', 1),
(6696, 1442, '데이터 탈취·인증 우회·데이터 삭제 중 최소 1개를 피해로 제시', 'ESSENTIAL', 2),
(6697, 1442, '데이터베이스에 직접 도달하는 공격이라고 언급', 'SUPPLEMENTARY', 3),
(6698, 1442, 'OWASP A03 인젝션에 속한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1443
(6699, 1443, '쿼리의 구조를 먼저 확정한다고 설명', 'ESSENTIAL', 1),
(6700, 1443, '입력값을 데이터로만 채워 넣는다고 설명', 'ESSENTIAL', 2),
(6701, 1443, '입력값이 SQL 문법을 담고 있어도 구문으로 해석되지 않는다고 설명', 'ESSENTIAL', 3),
(6702, 1443, '공격 문자열 전체가 하나의 아이디 값으로 취급되어 조회에 실패한다고 언급', 'SUPPLEMENTARY', 4),
(6703, 1443, '파라미터 바인딩이라는 다른 이름을 언급', 'SUPPLEMENTARY', 5);
