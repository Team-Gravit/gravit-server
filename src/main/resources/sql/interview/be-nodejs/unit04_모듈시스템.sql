-- Unit: 모듈 시스템 (Unit ID: 126)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NODE_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(626, 'NODE_JS', 126, 'HARD', true,
 'CommonJS 프로젝트에서 ESM 전용 패키지를 require()로 불러왔더니 오류가 발생했습니다. 원인이 무엇이고, Node.js 버전에 따라 어떻게 해결할 수 있으며 각 방법의 제약은 무엇인가요?',
 'CommonJS의 require()는 동기 로딩이고 ESM은 비동기 로딩이라는 서로 다른 모듈 시스템이기 때문에 생기는 상호운용 문제입니다. chalk 5나 node-fetch 3 같은 ESM 전용 패키지를 CJS 프로젝트에서 require하면, Node 22.12 / 20.19 미만 버전에서는 ERR_REQUIRE_ESM 오류가 발생합니다. 어느 버전에서나 동작하는 전통적 해결책은 동적 import()입니다. const { default: chalk } = await import(''chalk'')처럼 쓰는데, import()는 Promise를 반환하는 비동기 표현식이라 콜백이나 async 함수 안에서 사용해야 하고, 반환값이 모듈 네임스페이스 객체이므로 default를 직접 꺼내야 합니다. Node 22.12 / 20.19 이상에서는 플래그 없이 require(esm)으로 ESM을 동기 로드할 수 있습니다. 다만 해당 모듈 그래프에 최상위 await가 있으면 ERR_REQUIRE_ASYNC_MODULE 오류가 나므로, 그런 경우에는 여전히 import()를 써야 합니다. 이런 상호운용 오류는 대부분 누가 CJS이고 누가 ESM인지 파악하지 못해 생기므로, 먼저 package.json의 type 필드, 파일 확장자, 패키지의 exports 조건을 확인하고 그다음 Node 버전을 보는 것이 좋습니다.',
 'interview-question/626.mp3'),
(627, 'NODE_JS', 126, 'NORMAL', true,
 'CommonJS와 ESM은 모듈을 로딩하는 방식과 내보낸 값을 바인딩하는 방식에서 어떤 차이가 있나요?',
 '로딩 방식에서 CommonJS의 require()는 동기 로딩입니다. 파일을 읽고 실행한 뒤 module.exports를 즉시 반환하며, 조건문 안을 포함해 코드 어디서나 호출할 수 있습니다. 반면 ESM은 비동기 로딩으로, import 문은 파일 최상단에 문자열 경로로만 선언할 수 있고 파싱, 링킹, 평가의 3단계를 거쳐 모든 의존성이 링크된 뒤 평가됩니다. 그래서 ESM은 모듈 최상단에서 최상위 await를 쓸 수 있지만 CommonJS는 불가합니다. 바인딩 방식에서 CommonJS는 값 복사입니다. module.exports의 프로퍼티는 내보낸 시점의 값이라, 예를 들어 count를 내보낸 뒤 increment()로 원본 변수를 증가시켜도 가져온 쪽의 count는 0 그대로입니다. ESM은 라이브 바인딩으로, 내보낸 변수의 참조를 공유하므로 increment() 후 가져온 count가 1로 바뀝니다. 단, 가져온 쪽에서 이 바인딩은 읽기 전용입니다.',
 'interview-question/627.mp3'),
(628, 'NODE_JS', 126, 'NORMAL', true,
 'ESM의 import가 정적 구조여야 하는 이유는 무엇이며, 이 덕분에 CommonJS와 비교해 트리 셰이킹과 순환 참조 처리에서 어떤 차이가 생기나요?',
 'ESM의 import는 파일 최상단에서 문자열 경로로만 선언할 수 있는 정적 구조라서, 실행 전에 의존 그래프가 확정됩니다. 로딩도 파싱, 링킹, 평가의 3단계로 진행되어 모든 의존성이 링크된 뒤에 평가됩니다. 실행 전에 의존 그래프를 알 수 있기 때문에 사용하지 않는 export를 제거하는 트리 셰이킹이 가능합니다. 반면 CommonJS는 트리 셰이킹이 어렵습니다. 순환 참조에서도 차이가 납니다. CommonJS는 순환 구조에서 미완성 exports 객체를 받게 됩니다. ESM은 링킹 단계에서 바인딩을 미리 연결하므로 순환 구조에서도 바인딩이 연결되며, 평가 전에 그 바인딩에 접근하면 TDZ 오류가 발생합니다. 참고로 동적 import()를 쓰더라도 경로가 동적이면 정적 분석과 트리 셰이킹 혜택은 사라집니다.',
 'interview-question/628.mp3'),
(629, 'NODE_JS', 126, 'EASY', true,
 'Node.js에서 CommonJS의 require()가 모듈을 불러오는 동작 원리를 설명해 주세요.',
 'CommonJS는 require()로 모듈을 불러오고 module.exports로 내보냅니다. Node.js는 각 파일을 exports, require, module, __filename, __dirname을 인자로 받는 함수로 감싸는 module wrapper 형태로 실행하기 때문에, 파일 최상단에 선언한 변수가 전역이 되지 않습니다. require()는 동기 로딩으로, 파일을 읽고 실행한 뒤 module.exports를 즉시 반환합니다. 또한 한 번 로드한 모듈은 require.cache에 저장되어 이후 require하면 같은 객체를 반환하므로, 모듈 스코프가 사실상 싱글톤이 됩니다. 주의할 점은 exports가 module.exports의 별칭일 뿐이라서 exports.foo = 1은 동작하지만 exports = { foo: 1 }처럼 재할당하면 지역 변수만 바뀌고 아무것도 내보내지 않는다는 것입니다. 객체 전체를 내보낼 때는 module.exports = {...}를 사용해야 합니다.',
 'interview-question/629.mp3'),
(630, 'NODE_JS', 126, 'EASY', true,
 'Node.js는 어떤 파일을 CommonJS로 해석할지 ESM으로 해석할지 어떤 규칙으로 결정하나요?',
 'Node.js는 먼저 파일 확장자를 확인합니다. 확장자가 .mjs면 ESM으로, .cjs면 CommonJS로 해석합니다. 확장자가 .js라면 가장 가까운 package.json의 type 필드를 봅니다. type이 "module"이면 ESM, "commonjs"면 CommonJS로 해석하고, type 필드가 없으면 기본값인 CommonJS로 해석합니다. 즉 확장자, 그다음 package.json의 type 순서로 결정됩니다. 패키지 제작자는 package.json의 exports 필드에 import와 require 조건을 두어 두 시스템에 각각 다른 진입점을 제공하는 듀얼 패키지를 만들 수 있습니다. 또 TypeScript는 소스에서 import 문법을 써도 컴파일 결과가 CJS일 수 있으므로, 소스가 아니라 출력물 기준으로 모듈 종류를 판단해야 합니다.',
 'interview-question/630.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 626
(3374, 626, 'Node 22.12 / 20.19 미만에서 ESM 전용 패키지를 require하면 ERR_REQUIRE_ESM 오류가 발생함을 언급', 'ESSENTIAL', 1),
(3375, 626, '동적 import()로 ESM 전용 패키지를 async 함수 안에서 비동기로 불러오는 해결책을 제시', 'ESSENTIAL', 2),
(3376, 626, 'Node 22.12 / 20.19 이상에서는 require(esm)으로 ESM을 동기 로드할 수 있음을 언급', 'ESSENTIAL', 3),
(3377, 626, '모듈 그래프에 최상위 await가 있으면 require(esm)이 ERR_REQUIRE_ASYNC_MODULE 오류를 냄을 설명', 'ESSENTIAL', 4),
(3378, 626, 'import()의 반환값이 모듈 네임스페이스 객체라 default를 꺼내야 함을 언급', 'SUPPLEMENTARY', 5),
(3379, 626, '오류 시 Node 버전보다 package.json type·파일 확장자·exports 조건을 먼저 확인하라고 제시', 'SUPPLEMENTARY', 6),

-- 질문 627
(3380, 627, 'CommonJS의 require()는 동기 로딩, ESM은 비동기 로딩이라는 차이를 구분', 'ESSENTIAL', 1),
(3381, 627, 'CommonJS는 module.exports에 내보낸 시점의 값이 복사되어 원본 변경이 반영되지 않음을 설명', 'ESSENTIAL', 2),
(3382, 627, 'ESM은 라이브 바인딩으로 원본 변수의 참조를 공유해 원본 변경이 가져온 쪽에 반영됨을 설명', 'ESSENTIAL', 3),
(3383, 627, 'ESM에서 가져온 라이브 바인딩은 읽기 전용임을 언급', 'SUPPLEMENTARY', 4),
(3384, 627, 'require()는 조건문 안 등 코드 어디서나 호출 가능하지만 import 문은 파일 최상단에만 선언 가능함을 언급', 'SUPPLEMENTARY', 5),
(3385, 627, 'ESM은 모듈 최상단에서 최상위 await를 쓸 수 있지만 CommonJS는 불가함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 628
(3386, 628, 'ESM은 실행 전에 의존 그래프가 확정되어 사용하지 않는 export를 제거하는 트리 셰이킹이 가능함을 설명', 'ESSENTIAL', 1),
(3387, 628, 'CommonJS는 트리 셰이킹이 어렵다는 점을 언급', 'ESSENTIAL', 2),
(3388, 628, 'CommonJS는 순환 참조 시 미완성 exports 객체를 받게 됨을 언급', 'ESSENTIAL', 3),
(3389, 628, 'ESM은 순환 참조에서도 링킹 단계에서 바인딩을 미리 연결함을 설명', 'ESSENTIAL', 4),
(3390, 628, 'ESM 순환 참조에서 평가 전 바인딩에 접근하면 TDZ 오류가 발생함을 언급', 'SUPPLEMENTARY', 5),
(3391, 628, 'ESM 로딩이 파싱 → 링킹 → 평가 3단계로 진행됨을 설명', 'SUPPLEMENTARY', 6),
(3392, 628, '경로가 동적인 import()는 정적 분석·트리 셰이킹 혜택이 사라짐을 언급', 'SUPPLEMENTARY', 7),

-- 질문 629
(3393, 629, 'Node.js가 각 파일을 함수로 감싸는 module wrapper로 실행해 최상단 변수가 전역이 되지 않음을 설명', 'ESSENTIAL', 1),
(3394, 629, 'require()가 파일을 동기로 읽고 실행한 뒤 module.exports를 즉시 반환함을 설명', 'ESSENTIAL', 2),
(3395, 629, '한 번 로드한 모듈은 require.cache에 저장되어 같은 객체를 반환함을 언급', 'ESSENTIAL', 3),
(3396, 629, '모듈 캐시 때문에 모듈 스코프가 사실상 싱글톤이 됨을 언급', 'SUPPLEMENTARY', 4),
(3397, 629, 'exports = {...}로 재할당하면 아무것도 내보내지 않으므로 module.exports를 써야 함을 설명', 'SUPPLEMENTARY', 5),

-- 질문 630
(3398, 630, '확장자가 .mjs면 ESM, .cjs면 CommonJS로 해석됨을 언급', 'ESSENTIAL', 1),
(3399, 630, '.js 파일은 가장 가까운 package.json의 type 필드 값으로 모듈 종류가 결정됨을 설명', 'ESSENTIAL', 2),
(3400, 630, 'package.json에 type 필드가 없으면 .js 파일은 CommonJS로 해석되는 것이 기본값임을 언급', 'ESSENTIAL', 3),
(3401, 630, 'package.json의 exports 필드에 import·require 조건을 두어 듀얼 패키지를 제공함을 언급', 'SUPPLEMENTARY', 4),
(3402, 630, 'TypeScript는 소스가 아니라 컴파일 출력물 기준으로 모듈 종류를 판단해야 함을 언급', 'SUPPLEMENTARY', 5);
