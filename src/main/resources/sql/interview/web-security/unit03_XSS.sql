-- Unit: XSS (Unit ID: 253)
-- Chapter: 웹 보안 (Chapter ID: 23)
-- Topic: WEB_SECURITY
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-web-security-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1444, 'WEB_SECURITY', 253, 'HARD', true,
 '게시판 글을 열람한 사용자들의 세션이 줄줄이 탈취됐다면, 원인은 무엇이고 어떻게 막아야 하나요?',
 '원인은 Stored XSS로 볼 수 있습니다. Stored XSS는 악성 스크립트가 서버 DB에 저장되어, 해당 페이지를 여는 모든 사용자에게 실행됩니다. XSS의 대표적인 악용은 브라우저에 저장된 쿠키를 외부로 전송해 세션을 탈취하는 것입니다. 막으려면 사용자 입력을 출력할 때 HTML 특수문자를 엔티티로 변환하는 출력 이스케이프를 적용해, 입력이 코드가 아닌 텍스트로 표시되게 합니다. 추가 방어 대책으로 세션 쿠키에 HttpOnly 속성을 설정합니다. HttpOnly를 설정하면 자바스크립트에서 document.cookie로 쿠키에 접근할 수 없습니다. XSS가 발생해도 세션 쿠키 탈취를 막는 중요한 방어선입니다. CSP 헤더로 실행 가능한 스크립트 출처를 제한하거나, 입력값 검증으로 허용된 문자·태그만 통과시킬 수도 있습니다.',
 NULL),
(1445, 'WEB_SECURITY', 253, 'NORMAL', true,
 'Stored XSS와 Reflected XSS는 어떻게 다른가요?',
 '두 유형은 악성 스크립트가 어디에 저장되고 어떻게 전달되는지가 다릅니다. Stored XSS는 공격자가 게시글 등에 작성한 악성 스크립트가 서버 DB에 저장되어, 해당 페이지를 여는 모든 사용자의 브라우저에서 실행됩니다. 그래서 피해 범위가 페이지 열람자 전체로 가장 넓습니다. Reflected XSS는 스크립트가 URL 파라미터에 담겨 서버 응답에 그대로 반사되는 방식으로, 공격자가 악성 링크를 만들어 피해자를 유도하고 그 링크를 클릭한 사용자의 브라우저에서 실행됩니다. 둘 다 서버를 경유한다는 점은 같습니다.',
 NULL),
(1446, 'WEB_SECURITY', 253, 'NORMAL', true,
 'XSS와 SQL 인젝션은 같은 인젝션 계열인데, 무엇이 다른가요?',
 '둘은 같은 인젝션 계열이지만 공격 대상이 다릅니다. XSS는 다른 사용자의 브라우저를 공격하고, SQL 인젝션은 서버의 데이터베이스를 공격합니다. 실행 위치도 XSS는 클라이언트 측, SQL 인젝션은 서버 측입니다. 핵심 방어 역시 달라서 XSS는 출력 이스케이프와 CSP로, SQL 인젝션은 Prepared Statement로 막습니다. XSS는 서버가 아니라 다른 사용자의 브라우저를 공격합니다. 서버 자체는 멀쩡해 보여도 이용자들이 대규모로 피해를 입을 수 있습니다.',
 NULL),
(1447, 'WEB_SECURITY', 253, 'EASY', true,
 'XSS란 어떤 취약점이고, 어떤 상황에서 발생하나요?',
 'XSS는 공격자가 웹 페이지에 악성 스크립트를 삽입해, 그 페이지를 보는 다른 사용자의 브라우저에서 스크립트가 실행되게 하는 취약점입니다. 애플리케이션이 사용자 입력을 검증 없이, 이스케이프하지 않고 화면에 출력할 때 발생합니다. 정상이라면 입력값은 텍스트로만 표시되어야 하지만, 입력에 스크립트 태그 같은 코드가 담기면 브라우저가 그것을 코드로 실행합니다. 그 결과 세션 탈취나 피싱 같은 피해로 이어지며, OWASP A03 인젝션에 속합니다.',
 NULL),
(1448, 'WEB_SECURITY', 253, 'EASY', true,
 'XSS 방어에서 출력 이스케이프는 어떤 원리로 스크립트 실행을 막나요?',
 '출력 이스케이프는 사용자 입력을 화면에 출력할 때 HTML 특수문자를 엔티티로 변환하는 방식입니다. 예를 들어 < 는 &lt;, > 는 &gt;, & 는 &amp;로, 큰따옴표와 작은따옴표는 &quot;와 &#x27;로 바뀝니다. 이렇게 하면 script 태그가 &lt;script&gt;로 변환되어 브라우저가 이를 실행하지 않고 글자 그대로 보여 주므로, 입력이 코드가 아닌 텍스트로 표시됩니다. XSS에 대한 가장 기본적이고 확실한 방어입니다.',
 NULL);

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1444
(6704, 1444, '원인을 Stored XSS로 제시', 'ESSENTIAL', 1),
(6705, 1444, '사용자 입력을 출력할 때 HTML 특수문자를 엔티티로 변환한다고 제시', 'ESSENTIAL', 2),
(6706, 1444, 'XSS의 대표적 악용이 쿠키를 외부로 전송해 세션을 탈취하는 것이라고 설명', 'SUPPLEMENTARY', 3),
(6707, 1444, '세션 쿠키에 HttpOnly 속성을 설정한다고 제시', 'SUPPLEMENTARY', 4),
(6708, 1444, 'CSP 헤더·입력값 검증 중 최소 1개를 추가 방어 대책으로 제시', 'SUPPLEMENTARY', 5),

-- 질문 1445
(6709, 1445, 'Stored XSS는 악성 스크립트가 서버 DB에 저장된다고 설명', 'ESSENTIAL', 1),
(6710, 1445, 'Reflected XSS는 URL 파라미터에 담긴 스크립트가 서버 응답에 그대로 반사된다고 설명', 'ESSENTIAL', 2),
(6711, 1445, 'Stored는 페이지 열람자 전체, Reflected는 링크를 클릭한 사용자가 피해를 입는다고 구분', 'ESSENTIAL', 3),
(6712, 1445, 'Reflected XSS에서 공격자가 악성 링크를 만들어 피해자를 유도한다고 언급', 'SUPPLEMENTARY', 4),
(6713, 1445, 'Stored XSS의 피해 범위가 가장 넓다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1446
(6714, 1446, 'XSS는 다른 사용자의 브라우저를 공격한다고 설명', 'ESSENTIAL', 1),
(6715, 1446, 'SQL 인젝션은 서버의 데이터베이스를 공격한다고 설명', 'ESSENTIAL', 2),
(6716, 1446, 'XSS는 클라이언트 측, SQL 인젝션은 서버 측에서 실행된다고 구분', 'SUPPLEMENTARY', 3),
(6717, 1446, 'XSS는 출력 이스케이프·CSP 중 최소 1개로, SQL 인젝션은 Prepared Statement로 방어한다고 구분', 'SUPPLEMENTARY', 4),
(6718, 1446, 'XSS는 서버 자체가 멀쩡해 보여도 이용자들이 대규모로 피해를 입을 수 있다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1447
(6719, 1447, '삽입된 악성 스크립트가 다른 사용자의 브라우저에서 실행된다고 설명', 'ESSENTIAL', 1),
(6720, 1447, '사용자 입력이 검증 없이 화면에 출력될 때 발생한다고 설명', 'ESSENTIAL', 2),
(6721, 1447, '세션 탈취·피싱 중 최소 1개를 XSS의 피해로 언급', 'SUPPLEMENTARY', 3),
(6722, 1447, 'XSS가 OWASP A03 인젝션에 속한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1448
(6723, 1448, '사용자 입력을 출력할 때 HTML 특수문자를 엔티티로 변환한다고 설명', 'ESSENTIAL', 1),
(6724, 1448, '변환된 입력을 브라우저가 코드가 아닌 텍스트로 표시한다고 설명', 'ESSENTIAL', 2),
(6725, 1448, '<·>·& 문자 중 최소 1개를 HTML 엔티티로 변환하는 대상으로 언급', 'SUPPLEMENTARY', 3),
(6726, 1448, '출력 이스케이프가 가장 기본적이고 확실한 방어라고 언급', 'SUPPLEMENTARY', 4);
