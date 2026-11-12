-- Unit: 타입 좁히기 (Unit ID: 207)
-- Chapter: TypeScript (Chapter ID: 20)
-- Topic: TYPESCRIPT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-typescript-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1031, 'TYPESCRIPT', 207, 'HARD', true,
 '종류에 따라 데이터 모양이 달라지는 상태를 선택적 프로퍼티로 뭉뚱그려 설계하면 어떤 문제가 있나요? 판별 유니온으로 재설계했을 때, 나중에 새 종류가 추가되면 처리 누락을 어떻게 컴파일 타임에 잡을 수 있는지도 함께 설명해 주세요.',
 'kind와 radius?, side?처럼 선택적 프로퍼티로 뭉뚱그려 설계하면 어떤 조합이 유효한지 타입이 말해주지 않습니다. 원인데 side만 있는 잘못된 조합도 타입상 허용되는 셈입니다. 그래서 Circle, Square처럼 종류별로 타입을 나누고, 모든 멤버가 kind 같은 공통 리터럴 프로퍼티, 즉 판별자를 갖게 한 판별 유니온으로 재설계합니다. 그러면 switch (shape.kind)처럼 판별자 비교만으로 각 case에서 유니온이 정확한 타입으로 좁혀집니다. 이때 판별자는 반드시 리터럴 타입이어야 하고 string으로 선언하면 좁히기가 일어나지 않으며, 판별자 이름은 유니온의 모든 멤버에서 같아야 합니다. 처리 누락은 never를 이용한 완전성 검사로 잡습니다. switch의 default 분기에서 never 타입 매개변수를 받는 assertNever(shape)를 호출해 두면, 모든 case를 처리한 경우 남은 타입이 never라 통과합니다. 나중에 Shape에 Triangle 같은 멤버가 추가되면 default에 남은 타입이 never가 아니게 되므로, 처리하지 않은 분기가 컴파일 오류로 드러나 누락을 컴파일 타임에 발견할 수 있습니다.',
 'interview-question/1031.mp3'),
(1032, 'TYPESCRIPT', 207, 'NORMAL', true,
 'TypeScript에서 변수에 타입 표기(: T)를 붙이는 것과 satisfies 연산자를 쓰는 것은 어떤 차이가 있고, 언제 satisfies를 선택하나요?',
 '둘 다 값이 타입 T를 만족하는지 검사한다는 점은 같지만, 변수의 최종 타입이 다릅니다. const theme: Theme = {...}처럼 타입 표기를 하면 검사와 동시에 변수 타입이 T로 넓어집니다. 그래서 Theme의 값이 string | [number, number, number]라면 primary에 문자열을 넣었어도 튜플일 수 있다고 판단해 toUpperCase 호출이 오류가 납니다. 반면 TypeScript 4.9에서 추가된 satisfies는 T를 만족하는지 검사하되 변수 타입은 값에서 추론된 좁은 타입으로 유지합니다. 그래서 primary는 string, accent는 튜플로 그대로 쓸 수 있고, 존재하지 않는 키 접근은 오류가 나며 초과 프로퍼티 검사도 적용됩니다. 따라서 외부에 T로 노출해야 할 때는 타입 표기를, 설정 객체나 상수 맵처럼 키와 리터럴을 살려야 할 때는 satisfies를 선택합니다. 참고로 as 단언은 검사를 최소한만 해서 안전성이 약하므로 컴파일러보다 개발자가 더 잘 아는 특수 상황에만 씁니다. 또 as const satisfies Theme처럼 as const와 함께 쓰면 값은 읽기 전용 리터럴로 고정하면서도 구조를 만족하는지 검사할 수 있어 라우트 테이블이나 i18n 키 맵에 유용합니다.',
 'interview-question/1032.mp3'),
(1033, 'TYPESCRIPT', 207, 'NORMAL', true,
 '사용자 정의 타입 가드 중 타입 서술(x is T)과 단언 함수(asserts x is T)는 어떻게 다르며, 두 방식 모두에서 주의해야 할 점은 무엇인가요?',
 '타입 서술은 반환 타입을 pet is Fish처럼 ''매개변수 is 타입''으로 선언한 불리언 반환 함수입니다. 이 함수가 true를 반환한 분기에서 컴파일러가 인수를 해당 타입으로 좁히고, else 분기에서는 나머지 타입으로 취급합니다. pets.filter(isFish)처럼 filter에 넘기면 Fish[]로 추론되기도 합니다. 단언 함수는 ''asserts 매개변수 is 타입''으로 선언하고, 조건이 틀리면 예외를 던지는 검증 함수입니다. 분기를 만드는 대신, 호출이 예외 없이 지나갔다면 그 이후 코드에서 인수가 좁혀진 채로 유지됩니다. 두 방식 모두 주의할 점은 본문을 컴파일러가 검증하지 않는다는 것입니다. pet is Fish라고 선언해 놓고 본문에서 엉뚱한 검사를 해도 잘못된 타입이 통과되므로, 사용자 정의 가드는 ''컴파일러에게 내가 책임진다''는 선언과 같습니다. 그래서 본문의 검사 로직을 단위 테스트로 보호하는 것이 좋습니다.',
 'interview-question/1033.mp3'),
(1034, 'TYPESCRIPT', 207, 'EASY', true,
 'TypeScript의 타입 좁히기란 무엇이며, 컴파일러는 어떤 원리로 타입을 좁히나요?',
 '타입 좁히기는 string | number | null처럼 넓은 타입의 값을 코드 흐름에 따라 더 구체적인 타입으로 줄여 나가는 과정입니다. 원리는 제어 흐름 분석입니다. TypeScript는 if, return, throw, 논리 연산자 등을 따라가며 각 지점에서 변수가 가질 수 있는 타입을 계산합니다. 예를 들어 value === null이면 return하는 코드 아래에서는 null이 제거된 string | number가 되고, 이어서 typeof value === "string" 분기 안에서는 string, 그 뒤에서는 number로 취급됩니다. 이렇게 같은 변수라도 코드 위치에 따라 다른 타입으로 취급되므로 as 단언 없이도 안전하게 코드를 쓸 수 있습니다. 다만 좁히기는 읽기 전용 참조에서만 안정적으로 유지됩니다. let 변수는 이후 대입으로 다시 넓어질 수 있고, 콜백 함수 안에서는 나중에 실행될 때 값이 바뀌었을 수 있어 바깥에서 좁힌 결과가 초기화되어 넓은 타입으로 돌아갑니다. const에 담아 두면 콜백 안에서도 좁힘이 유지됩니다.',
 'interview-question/1034.mp3'),
(1035, 'TYPESCRIPT', 207, 'EASY', true,
 'TypeScript가 제공하는 내장 타입 가드에는 어떤 것들이 있고, typeof로 객체 여부를 검사할 때 주의할 점은 무엇인가요?',
 '내장 타입 가드로는 원시 타입을 좁히는 typeof x === "...", 프로토타입 체인으로 클래스 인스턴스 여부를 좁히는 x instanceof C, 특정 프로퍼티 유무로 객체 유니온을 분기하는 "key" in x, 리터럴이나 null·undefined를 좁히는 ===·!== 동등 비교, null·undefined 등을 제거하는 if (x) 진릿값 검사, 그리고 배열 여부를 판별하는 Array.isArray(x)가 있습니다. typeof로 객체 여부를 검사할 때는 typeof null이 "object"라는 점에 주의해야 합니다. 그래서 typeof v === "object"로 좁혀도 null이 남아 컴파일러는 object | null로 좁히므로, v !== null 검사를 추가해야 합니다. 비슷하게 진릿값 검사는 0과 빈 문자열까지 함께 걸러내므로, 값이 없음만 판별하려면 != null을 쓰는 편이 안전합니다.',
 'interview-question/1035.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1031
(5546, 1031, '선택적 프로퍼티로 뭉뚱그리면 어떤 조합이 유효한지 타입이 알려주지 않음을 언급', 'ESSENTIAL', 1),
(5547, 1031, '종류별로 타입을 나누고 공통 리터럴 판별자 프로퍼티로 분기하는 구조를 설명', 'ESSENTIAL', 2),
(5548, 1031, 'default 분기에서 never 매개변수를 받는 함수를 호출하는 완전성 검사를 설명', 'ESSENTIAL', 3),
(5549, 1031, '유니온에 멤버가 추가되면 처리하지 않은 분기가 컴파일 오류로 드러남을 언급', 'ESSENTIAL', 4),
(5550, 1031, '판별자를 string으로 선언하면 좁히기가 일어나지 않음을 언급', 'SUPPLEMENTARY', 5),
(5551, 1031, '판별자 이름이 유니온의 모든 멤버에서 같아야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1032
(5552, 1032, '타입 표기는 검사와 동시에 변수 타입을 T로 넓혀 좁은 추론 정보를 잃음을 설명', 'ESSENTIAL', 1),
(5553, 1032, 'satisfies는 타입 검사를 하면서도 변수 타입을 원래 추론된 좁은 타입으로 유지함을 설명', 'ESSENTIAL', 2),
(5554, 1032, '설정 객체·상수 맵처럼 키와 리터럴을 살려야 할 때 satisfies가 적합함을 언급', 'ESSENTIAL', 3),
(5555, 1032, 'as 단언은 타입 검사를 최소한만 해서 안전성이 약함을 언급', 'SUPPLEMENTARY', 4),
(5556, 1032, 'as const와 함께 써서 읽기 전용 리터럴 고정과 구조 검사를 함께 얻음을 언급', 'SUPPLEMENTARY', 5),
(5557, 1032, 'satisfies가 TypeScript 4.9에서 추가된 연산자임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1033
(5558, 1033, '반환 타입이 x is T인 함수는 true를 반환한 분기에서 인수를 해당 타입으로 좁힘을 설명', 'ESSENTIAL', 1),
(5559, 1033, '단언 함수는 호출 이후의 코드에서 인수가 좁혀진 채로 유지됨을 설명', 'ESSENTIAL', 2),
(5560, 1033, '사용자 정의 가드의 본문은 컴파일러가 검증하지 않음을 언급', 'ESSENTIAL', 3),
(5561, 1033, '단언 함수는 조건이 틀리면 예외를 던지는 검증 함수임을 언급', 'SUPPLEMENTARY', 4),
(5562, 1033, '가드 본문의 검사 로직을 단위 테스트로 보호해야 함을 언급', 'SUPPLEMENTARY', 5),
(5563, 1033, 'filter에 반환 타입이 x is T인 함수를 넘기면 좁혀진 배열 타입이 추론됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1034
(5564, 1034, '넓은 타입의 값을 코드 흐름에 따라 더 구체적인 타입으로 줄여 나가는 과정임을 설명', 'ESSENTIAL', 1),
(5565, 1034, 'if·return·throw 등 제어 흐름을 따라 각 지점에서 가능한 타입을 계산함을 설명', 'ESSENTIAL', 2),
(5566, 1034, '같은 변수라도 코드 위치에 따라 다른 타입으로 취급됨을 언급', 'ESSENTIAL', 3),
(5567, 1034, '콜백 함수 안에서는 바깥에서 좁힌 결과가 초기화되어 넓은 타입으로 돌아감을 언급', 'SUPPLEMENTARY', 4),
(5568, 1034, 'const에 담아 두면 콜백 안에서도 좁힘이 유지됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1035
(5569, 1035, 'typeof·instanceof·in·===·진릿값 검사 중 최소 3개를 내장 타입 가드로 제시', 'ESSENTIAL', 1),
(5570, 1035, 'typeof null이 "object"라서 typeof로 object를 검사해도 null이 남음을 언급', 'ESSENTIAL', 2),
(5571, 1035, 'typeof 검사 뒤에 v !== null 검사를 추가해 null을 제거해야 함을 언급', 'SUPPLEMENTARY', 3),
(5572, 1035, '진릿값 검사는 null·undefined뿐 아니라 0과 빈 문자열도 함께 걸러냄을 언급', 'SUPPLEMENTARY', 4),
(5573, 1035, 'instanceof는 프로토타입 체인으로 클래스 인스턴스 여부를 좁힘을 언급', 'SUPPLEMENTARY', 5);
