-- Unit: HTTP 캐싱 (Unit ID: 90)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(446, 'WEB_COMMON', 90, 'HARD', true,
 'app.js를 고정 URL로 배포하면서 max-age=86400을 줬더니, 배포 직후 일부 사용자 화면에서 오류가 발생했습니다. 원인은 무엇이고, 정적 자산과 HTML의 캐시 헤더를 각각 어떻게 설계해야 하나요?',
 'app.js를 고정 URL로 두고 max-age=86400을 주면, 배포 후 최대 하루 동안 브라우저는 캐시된 옛 JS를 그대로 사용하므로 사용자는 옛 JS와 새 HTML 조합을 받게 되어 오류가 발생합니다. 브라우저 캐시는 서버가 강제로 지울 수 없고 CDN 퍼지로도 브라우저 캐시는 지우지 못하기 때문에, URL을 바꾸는 것이 유일하게 확실한 무효화 방법입니다. 그래서 정적 자산은 app.3f9a2c.js처럼 해시 파일명으로 빌드해 내용이 바뀌면 해시가 바뀌고 URL 자체가 달라지게 합니다. 이런 자산에는 Cache-Control: public, max-age=31536000, immutable처럼 1년 max-age를 주고, immutable로 신선한 동안 재검증 요청 자체를 생략하게 합니다. 내용이 바뀌면 파일명이 바뀌므로 오래된 캐시가 재사용될 일이 없습니다. 반면 HTML 진입점은 no-cache를 주어 매번 검증하게 해서, 새 해시 파일명을 가리키는 최신 HTML을 받도록 합니다. HTML에 긴 max-age를 주면 새 해시 파일명을 알 방법이 없어 배포가 그만큼 늦게 반영되므로, HTML은 no-cache(또는 아주 짧은 max-age)가 원칙입니다.',
 'interview-question/446.mp3'),
(447, 'WEB_COMMON', 90, 'NORMAL', true,
 'Cache-Control의 no-cache와 no-store는 어떻게 다르며, 각각 어떤 응답에 사용하나요?',
 'no-cache는 이름과 달리 캐시하지 않는다는 뜻이 아니라, 응답을 저장은 하되 사용하기 전에 반드시 조건부 요청으로 재검증하라는 뜻입니다. 반면 no-store는 응답을 아예 저장하지 않게 합니다. 그래서 결제나 개인정보 같은 민감 정보 응답에는 no-store를 써서 저장 자체를 금지합니다. no-cache는 HTML 진입점이나 사용자별 API 응답처럼 항상 최신이어야 하는 응답에 씁니다. 특히 no-cache에 ETag를 함께 쓰면 매번 검증하면서도 변하지 않았을 때는 본문 없는 304로 응답해 전송량을 줄일 수 있습니다. 또 Cache-Control이 전혀 없으면 브라우저가 휴리스틱 캐싱을 적용해 캐시할 수 있으므로, 캐시하면 안 되는 응답에는 명시적으로 no-store를 줘야 합니다.',
 'interview-question/447.mp3'),
(448, 'WEB_COMMON', 90, 'NORMAL', true,
 '조건부 요청에 쓰이는 ETag와 Last-Modified는 어떻게 다르고, Last-Modified 방식에는 어떤 한계가 있나요?',
 '둘 다 신선 기간이 지난 캐시가 아직 유효한지 서버에 묻는 조건부 요청에 쓰입니다. ETag는 리소스 버전을 나타내는 식별자로 보통 내용의 해시이며, 브라우저는 다음 요청에 If-None-Match로 그 값을 보냅니다. Last-Modified는 파일의 마지막 수정 시각으로 비교하며, 브라우저는 If-Modified-Since로 보냅니다. 유효하면 서버는 본문 없이 304를 돌려줍니다. Last-Modified는 구현이 쉽지만 정밀도가 1초라서 1초 안에 두 번 바뀌면 감지하지 못하고, 내용이 같아도 재배포로 수정 시각이 바뀌면 불필요하게 전체를 다시 보냅니다. 또한 둘 다 있으면 서버는 ETag를 우선 비교합니다.',
 'interview-question/448.mp3'),
(449, 'WEB_COMMON', 90, 'EASY', true,
 '브라우저에 캐시된 리소스를 다시 요청할 때 캐시 사용 여부가 어떻게 판정되는지, 그리고 304 Not Modified는 언제 오는지 설명해 주세요.',
 '캐시는 신선도와 검증이라는 두 축으로 동작합니다. 캐시에 리소스가 있고 max-age가 지나지 않은 신선한 상태라면 네트워크 요청 없이 캐시를 그대로 사용합니다. max-age가 지나 오래된 상태라면 버리지 않고 If-None-Match나 If-Modified-Since를 담은 조건부 요청으로 서버에 바뀌었는지 묻습니다. 변하지 않았다면 서버는 본문 없이 304 Not Modified를 돌려주고, 브라우저는 캐시를 재사용하며 신선도를 갱신합니다. 변했다면 200과 새 본문을 받아 캐시를 교체합니다. 이때 신선도는 Cache-Control이, 검증은 ETag·Last-Modified가 담당합니다.',
 'interview-question/449.mp3'),
(450, 'WEB_COMMON', 90, 'EASY', true,
 'HTTP 응답의 Vary 헤더는 무엇이고, 왜 필요한가요?',
 '캐시는 기본적으로 URL을 키로 응답을 저장합니다. 그런데 같은 URL이라도 Accept-Encoding(gzip 여부), Accept-Language, Origin 같은 요청 헤더에 따라 응답이 달라질 수 있습니다. Vary 헤더는 이런 요청 헤더도 캐시 키에 포함시켜, 요청 헤더가 다르면 다른 캐시 항목으로 구분되게 합니다. 예를 들어 Vary 없이 CORS 응답을 CDN에 캐시하면, a.com 요청에 대한 Allow-Origin: https://a.com 응답이 저장된 뒤 b.com 요청에도 그대로 반환되어 Allow-Origin 불일치로 CORS 에러가 납니다. 그래서 Vary: Accept-Encoding, Origin처럼 지정합니다. 다만 Vary: Cookie나 Vary: User-Agent처럼 값의 조합이 무수히 많은 헤더를 지정하면 캐시 적중률이 0에 가까워지므로, 사용자별 응답이라면 Vary가 아니라 Cache-Control: private을 쓰는 것이 맞습니다.',
 'interview-question/450.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 446
(2384, 446, '배포 후 캐시된 옛 JS와 새 HTML 조합이 섞여 오류가 난다는 원인을 설명', 'ESSENTIAL', 1),
(2385, 446, '정적 자산에 해시 파일명을 써서 내용이 바뀌면 URL 자체가 바뀌게 한다고 설명', 'ESSENTIAL', 2),
(2386, 446, '해시 파일명 자산에 1년(max-age=31536000) 캐시 수명을 지정한다고 제시', 'ESSENTIAL', 3),
(2387, 446, 'HTML 진입점에는 no-cache를 지정해 매번 검증받게 한다고 제시', 'ESSENTIAL', 4),
(2388, 446, 'immutable로 신선한 동안 재검증 요청 자체를 생략한다고 언급', 'SUPPLEMENTARY', 5),
(2389, 446, '브라우저 캐시는 서버가 강제로 지울 수 없어 URL 변경이 확실한 무효화 방법임을 언급', 'SUPPLEMENTARY', 6),
(2390, 446, 'HTML에 긴 max-age를 주면 새 해시 파일명을 몰라 배포 반영이 늦어진다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 447
(2391, 447, 'no-cache는 저장은 하되 사용 전에 반드시 재검증한다는 의미임을 설명', 'ESSENTIAL', 1),
(2392, 447, 'no-store는 응답을 아예 저장하지 않는다는 의미임을 설명', 'ESSENTIAL', 2),
(2393, 447, '결제·개인정보 같은 민감 정보 응답에는 no-store를 써야 한다고 제시', 'ESSENTIAL', 3),
(2394, 447, 'HTML 진입점·사용자별 API 응답 중 최소 1개를 no-cache 사용처로 제시', 'ESSENTIAL', 4),
(2395, 447, 'Cache-Control이 없으면 휴리스틱 캐싱이 적용되어 캐시될 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2396, 447, 'no-cache와 ETag를 함께 쓰면 304 응답으로 전송량을 줄인다는 점을 언급', 'SUPPLEMENTARY', 6),

-- 질문 448
(2397, 448, 'ETag가 리소스 버전을 나타내는 식별자(보통 내용의 해시)임을 설명', 'ESSENTIAL', 1),
(2398, 448, 'Last-Modified가 파일의 마지막 수정 시각 정보임을 설명', 'ESSENTIAL', 2),
(2399, 448, '1초 정밀도로 인한 변경 미감지·재배포 시 불필요한 전체 재전송 중 최소 1개를 Last-Modified 한계로 제시', 'ESSENTIAL', 3),
(2400, 448, 'ETag는 If-None-Match, Last-Modified는 If-Modified-Since 헤더로 보낸다고 언급', 'SUPPLEMENTARY', 4),
(2401, 448, '둘 다 있으면 서버가 ETag를 우선한다는 점을 언급', 'SUPPLEMENTARY', 5),

-- 질문 449
(2402, 449, '신선한(max-age가 안 지난) 캐시는 네트워크 요청 없이 그대로 사용한다고 설명', 'ESSENTIAL', 1),
(2403, 449, '오래된(stale) 캐시는 조건부 요청으로 서버에 변경 여부를 묻는다고 설명', 'ESSENTIAL', 2),
(2404, 449, '변하지 않았으면 서버가 본문 없이 304 Not Modified를 준다고 설명', 'ESSENTIAL', 3),
(2405, 449, '변했으면 200과 새 본문을 받아 캐시를 교체한다고 언급', 'SUPPLEMENTARY', 4),
(2406, 449, 'Cache-Control이 신선도를, ETag·Last-Modified가 검증을 담당한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 450
(2407, 450, '캐시는 기본적으로 URL을 키로 응답을 저장한다고 언급', 'ESSENTIAL', 1),
(2408, 450, 'Vary가 지정한 요청 헤더를 캐시 키에 포함시킨다고 설명', 'ESSENTIAL', 2),
(2409, 450, 'Accept-Encoding·Accept-Language·Origin 중 최소 1개를 응답을 달라지게 하는 요청 헤더 예로 제시', 'ESSENTIAL', 3),
(2410, 450, 'Vary 없이 CORS 응답을 캐시하면 다른 Origin 요청에 CORS 에러가 나는 예를 제시', 'SUPPLEMENTARY', 4),
(2411, 450, 'Cookie·User-Agent처럼 값 조합이 무수히 많은 헤더를 Vary에 지정하면 캐시 적중률이 0에 가까워진다고 언급', 'SUPPLEMENTARY', 5),
(2412, 450, '사용자별 응답에는 Vary 대신 Cache-Control: private이 맞다고 언급', 'SUPPLEMENTARY', 6);
