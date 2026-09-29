-- Unit: 컴파일과 런타임 경계 (Unit ID: 211)
-- Chapter: TypeScript (Chapter ID: 20)
-- Topic: TYPESCRIPT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-typescript-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1051, 'TYPESCRIPT', 211, 'HARD', true,
 '외부 API 응답을 `as User`로 단언해서 사용하는 코드에는 어떤 문제가 있고, 이를 런타임 검증으로 바꿀 때 타입 서술 함수와 스키마 라이브러리 중 무엇을 선택하며 각각의 대가는 무엇인가요?',
 'TypeScript의 타입은 컴파일 타임에만 존재하고 JavaScript로 변환될 때 모두 제거되므로, `as User` 단언은 검사도 변환도 일으키지 않습니다. 컴파일은 통과하지만 실제 응답에 name이 없으면 런타임에 undefined가 쓰이거나 TypeError가 발생할 수 있습니다. API 응답은 코드 바깥에서 들어오는 신뢰 경계의 값이므로 any가 아닌 unknown으로 받고, 검증을 통과한 뒤에만 User 타입으로 취급해야 합니다. 검증 방식 중 타입 서술 함수(`v is User`)는 의존성 없이 가볍지만, 그 대가로 타입 정의와 검증 로직이 이중으로 존재해 필드가 추가될 때 한쪽을 빠뜨리기 쉽고, 타입 서술 함수의 본문은 컴파일러가 검증하지 않습니다. Zod 같은 스키마 라이브러리는 런타임 스키마를 먼저 정의하고 거기서 타입을 파생(z.infer)하므로 타입과 검증이 단일 원천이 되어 어긋날 수 없고 상세한 오류도 제공하지만, 그 대가로 번들 크기·의존성·학습 비용이 늘어납니다. 따라서 필드 몇 개의 단순 구조라면 타입 서술 함수로 충분하고, API 경계·폼 입력·환경 변수 같은 대부분의 실무에서는 스키마 라이브러리를 선택합니다.',
 'interview-question/1051.mp3'),
(1052, 'TYPESCRIPT', 211, 'NORMAL', true,
 'TypeScript의 `as` 타입 단언과 실제 값의 형변환은 어떻게 다른가요?',
 '`as`는 캐스팅이 아니라 컴파일러의 판단을 덮어쓰는 도구입니다. 컴파일 시 단언은 제거되므로 값 자체는 전혀 변하지 않습니다. 예를 들어 문자열 "42"를 `as unknown as number`로 단언한 뒤 1을 더하면 컴파일은 number + number로 통과하지만 런타임 결과는 문자열 결합인 "421"이 됩니다. 이렇게 이중 단언을 쓰면 컴파일러는 완전히 손을 떼고, 그 값이 실제로 T인지는 오직 개발자의 책임이 됩니다. 실제로 값을 바꾸려면 Number(x), String(x) 같은 실제 변환 함수를 사용하고, 예를 들어 Number.isNaN으로 결과를 검증해야 합니다.',
 'interview-question/1052.mp3'),
(1053, 'TYPESCRIPT', 211, 'NORMAL', true,
 '`enum`으로 정의한 값 목록과 문자열 리터럴 유니온 `type`은 컴파일 후 런타임에서 어떤 차이가 있나요?',
 '대부분의 TypeScript 문법은 컴파일 시 소거되지만 enum은 JS 코드를 생성합니다. enum은 런타임 객체(IIFE)로 컴파일되어 런타임에 값으로 남기 때문에 Object.values(Role)처럼 목록을 얻을 수 있고, 값이므로 import하면 실제 로드가 일어납니다. 반면 `type RoleT = "ADMIN" | "USER"` 같은 리터럴 유니온은 완전히 소거되어 런타임에 목록을 얻을 수 없습니다. 런타임 목록과 타입을 동시에 얻고 싶다면 `const ROLES = ["ADMIN", "USER"] as const`로 값을 먼저 정의하고 `(typeof ROLES)[number]`로 타입을 파생하는 관용구를 씁니다. 또한 TypeScript 5.8의 erasableSyntaxOnly 옵션은 enum처럼 소거만으로 처리할 수 없는 문법을 금지합니다.',
 'interview-question/1053.mp3'),
(1054, 'TYPESCRIPT', 211, 'EASY', true,
 'TypeScript의 타입 소거란 무엇이며, TypeScript는 런타임에 타입을 검사하나요?',
 '타입 소거는 TypeScript를 JavaScript로 컴파일할 때 타입 표기, 인터페이스, 타입 별칭, 제네릭, as 단언이 모두 제거되어 결과 JS에 남지 않는 것을 말합니다. 타입 검사는 변환 전에 한 번 수행될 뿐이고 결과 코드에는 검사 로직이 전혀 들어가지 않습니다. 따라서 TypeScript는 런타임에 타입을 검사하지 않습니다. TypeScript는 정적 타입 검사기이자 변환기일 뿐 런타임이 아니며, 생성된 JS는 타입 없는 JS와 완전히 동일하게 동작합니다.',
 'interview-question/1054.mp3'),
(1055, 'TYPESCRIPT', 211, 'EASY', true,
 '`import type` 구문은 왜 필요하며, `verbatimModuleSyntax` 옵션은 어떤 역할을 하나요?',
 '타입만 가져오는 import는 컴파일 시 소거되어야 하는데, esbuild·swc·Babel처럼 파일 단위로 변환하는 도구는 다른 파일을 보지 못해 가져온 이름이 타입인지 값인지 알 수 없습니다. 그래서 `import type`으로 소거 대상임을 명시하면 런타임 로드가 일어나지 않습니다. TypeScript 5.0의 verbatimModuleSyntax 옵션을 켜면 타입 전용 가져오기에 import type을 강제해, 어떤 도구로 변환해도 결과가 같도록 만들어 줍니다.',
 'interview-question/1055.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1051
(5648, 1051, 'as 단언은 런타임에 검사도 변환도 일으키지 않아 응답 모양이 보장되지 않음을 언급', 'ESSENTIAL', 1),
(5649, 1051, 'v is User 형태 함수는 타입 정의와 검증 로직이 이중으로 존재하는 단점을 언급', 'ESSENTIAL', 2),
(5650, 1051, '스키마 라이브러리의 대가로 번들 크기·의존성·학습 비용 중 최소 1개를 제시', 'ESSENTIAL', 3),
(5651, 1051, '필드 몇 개의 단순 구조에는 v is User 형태 함수, API 경계 같은 실무에는 스키마 라이브러리가 적합함을 언급', 'ESSENTIAL', 4),
(5652, 1051, '스키마 라이브러리는 스키마에서 타입을 파생해 타입과 검증이 단일 원천이 됨을 언급', 'SUPPLEMENTARY', 5),
(5653, 1051, 'API 응답 같은 신뢰 경계의 값은 unknown으로 받아 검증을 통과한 뒤에만 타입으로 취급함을 언급', 'SUPPLEMENTARY', 6),
(5654, 1051, 'v is User 형태 함수의 본문은 컴파일러가 검증하지 않음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 1052
(5655, 1052, 'as는 컴파일러의 판단만 덮어쓸 뿐 값 자체는 변하지 않음을 언급', 'ESSENTIAL', 1),
(5656, 1052, '실제 변환에는 Number(x)·String(x) 같은 변환 함수가 필요함을 언급', 'ESSENTIAL', 2),
(5657, 1052, '문자열 "42"를 number로 단언 후 1을 더하면 "421" 문자열 결합이 되는 예를 제시', 'SUPPLEMENTARY', 3),
(5658, 1052, 'as unknown as T 이중 단언 시 컴파일러는 완전히 손을 떼고 값은 오직 개발자의 책임이 됨을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1053
(5659, 1053, 'enum은 컴파일 후 런타임 객체를 생성해 값으로 남음을 언급', 'ESSENTIAL', 1),
(5660, 1053, 'type 리터럴 유니온은 완전히 소거되어 런타임에 목록을 얻을 수 없음을 언급', 'ESSENTIAL', 2),
(5661, 1053, 'as const 배열에서 typeof로 타입을 파생해 런타임 목록과 타입을 함께 얻는 방법을 제시', 'SUPPLEMENTARY', 3),
(5662, 1053, 'enum은 값이므로 import가 실제 로드를 유발함을 언급', 'SUPPLEMENTARY', 4),
(5663, 1053, 'erasableSyntaxOnly 옵션이 enum처럼 런타임 흔적을 남기는 문법을 금지함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1054
(5664, 1054, '컴파일 시 타입 정보가 모두 제거되어 결과 JS에 남지 않음을 언급', 'ESSENTIAL', 1),
(5665, 1054, 'TypeScript는 런타임에 타입을 검사하지 않음을 명시', 'ESSENTIAL', 2),
(5666, 1054, 'TypeScript가 정적 타입 검사기이자 변환기일 뿐 런타임이 아님을 언급', 'SUPPLEMENTARY', 3),
(5667, 1054, '생성된 JS는 타입 없는 일반 JS와 동일하게 동작함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1055
(5668, 1055, '파일 단위 변환 도구는 다른 파일을 보지 못해 가져온 이름이 타입이냐 값이냐를 알 수 없음을 언급', 'ESSENTIAL', 1),
(5669, 1055, 'verbatimModuleSyntax는 타입 전용 가져오기에 import type을 강제함을 언급', 'ESSENTIAL', 2),
(5670, 1055, 'import type으로 가져온 것은 소거되어 런타임 로드가 없음을 언급', 'SUPPLEMENTARY', 3),
(5671, 1055, '어떤 도구로 변환해도 결과가 같도록 만드는 것이 목적임을 언급', 'SUPPLEMENTARY', 4),
(5672, 1055, 'esbuild·swc·Babel 중 최소 1개를 파일 단위 변환 도구로 제시', 'SUPPLEMENTARY', 5);
