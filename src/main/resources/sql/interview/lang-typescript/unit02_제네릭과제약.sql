-- Unit: 제네릭과 제약 (Unit ID: 206)
-- Chapter: TypeScript (Chapter ID: 20)
-- Topic: TYPESCRIPT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-typescript-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1026, 'TYPESCRIPT', 206, 'HARD', true,
 '제네릭 함수를 설계할 때 타입 매개변수가 불필요하거나 제 역할을 못 하게 되는 경우에는 어떤 것들이 있고, 각각 어떻게 개선해야 하나요?',
 '제네릭은 호출부의 타입 정보를 보존할 때만 가치가 있어서, 그렇지 못한 설계는 고쳐야 합니다. 첫째, `<T>(x: T): void`처럼 타입 매개변수가 한 곳에만 등장해 입력과 출력을 연결하지 않으면 제네릭일 이유가 없고 오류 메시지만 복잡해지므로, 제네릭을 제거하고 unknown이나 구체 타입으로 선언합니다. 둘째, `<T extends User>(u: T): User`처럼 제약과 반환이 같은 타입이면 제네릭의 의미가 상실됩니다. 이때는 반환을 T로 돌려주면 본문에서는 제약 타입의 멤버만 쓰더라도 호출부에서는 원래 타입이 그대로 유지되고, 제네릭이 필요 없다면 그냥 매개변수 타입을 User로 선언하면 됩니다. 셋째, 제약 없는 T는 어떤 타입이든 될 수 있는 값으로 취급되어 `.length` 같은 멤버 접근이 오류가 나므로, `T extends { length: number }`처럼 필요한 최소 구조만 제약합니다. 이 밖에 `["a", "b"]`가 string[]으로 넓혀지는 것을 막고 리터럴 타입을 유지하려면 TypeScript 5.0+의 const 타입 매개변수 `<const T>`를 쓰고, 기본값 인수가 T 추론을 오염시키는 경우에는 TypeScript 5.4+의 `NoInfer<T>`로 해당 매개변수를 추론에서 제외합니다.',
 'interview-question/1026.mp3'),
(1027, 'TYPESCRIPT', 206, 'NORMAL', true,
 '제네릭 대신 any나 unknown을 사용하면 제네릭과 비교해 어떤 차이가 생기나요?',
 'any를 쓰면 어떤 타입이든 받을 수 있지만 들어간 타입과 나오는 타입의 관계가 끊깁니다. 예를 들어 `firstAny(arr: any[]): any`의 반환값은 any가 되어 이후 오타나 잘못된 호출을 잡지 못하고, 사실상 타입 검사를 포기하게 됩니다. 반면 제네릭 `first<T>(arr: T[]): T | undefined`는 타입 매개변수 T가 입력과 출력을 연결해 타입 관계를 보존하므로, 숫자 배열을 넣으면 number | undefined, 문자열 배열을 넣으면 string | undefined가 반환 타입이 됩니다. 이때 T는 호출 시점에 인수로부터 추론되므로 대부분 직접 적어 줄 필요가 없습니다. unknown은 any와 달리 안전하지만 반환값을 쓸 때마다 매번 타입을 좁혀야 한다는 단점이 있습니다.',
 'interview-question/1027.mp3'),
(1028, 'TYPESCRIPT', 206, 'NORMAL', true,
 '조건부 타입에 유니온 타입이 들어왔을 때, 타입 매개변수를 그대로 검사하는 경우와 [T]처럼 튜플로 감싸 검사하는 경우의 결과 차이를 설명해 주세요.',
 '검사 대상 T가 단독 타입 매개변수이고 유니온이 들어오면, 조건부 타입은 유니온의 각 멤버에 개별 적용된 뒤 결과가 다시 유니온으로 합쳐집니다. 이를 분산 조건부 타입이라고 합니다. 예를 들어 `ToArray<T> = T extends unknown ? T[] : never`에 string | number를 넣으면 string[] | number[]가 됩니다. 반면 `[T] extends [unknown]`처럼 튜플로 감싸면 분산이 차단되어 유니온 전체에 한 번 적용되므로 (string | number)[]가 됩니다. 내장 Exclude와 Extract가 이 분산 성질로 구현되어 있는데, `T extends U ? never : T`에서 never는 유니온에서 사라지기 때문입니다. 주의할 점으로 분산 조건부 타입이 never를 만나면 빈 유니온에 분산하므로 결과도 never가 되어, `IsNever<T>`를 의도대로 만들려면 `[T] extends [never]`처럼 튜플로 감싸야 합니다.',
 'interview-question/1028.mp3'),
(1029, 'TYPESCRIPT', 206, 'EASY', true,
 'TypeScript의 keyof 연산자와 인덱스 접근 타입 T[K]는 각각 무엇인가요?',
 'keyof T는 객체 타입 T의 프로퍼티 이름들의 유니온을 만듭니다. 예를 들어 id, name, email을 가진 User에 대해 keyof User는 "id" | "name" | "email"입니다. 인덱스 접근 타입 T[K]는 그 키 K에 해당하는 프로퍼티의 타입을 꺼내는 것으로, User["id"]는 number, User["name"]은 string입니다. 둘을 제약과 조합해 `getProp<T, K extends keyof T>(obj: T, key: K): T[K]`처럼 쓰면 실제 존재하는 키만 받고 반환 타입도 그 키의 값 타입으로 정확히 나오며, 없는 키를 넘기면 오류가 납니다. 참고로 인덱스 시그니처 `[key: string]: T`를 가진 타입에서는 JS에서 숫자 키가 문자열로 변환되므로 keyof가 string | number가 되고, 문자열 키만 필요하면 `keyof T & string`으로 교차시켜야 합니다.',
 'interview-question/1029.mp3'),
(1030, 'TYPESCRIPT', 206, 'EASY', true,
 '조건부 타입에서 infer 키워드는 어떤 역할을 하나요?',
 '조건부 타입은 `T extends U ? X : Y` 형태의 타입 수준 삼항 연산자로, T가 U에 대입 가능하면 X, 아니면 Y로 평가됩니다. infer는 이 조건부 타입의 extends 절 안에서 쓰며, `infer R`이라고 쓰면 매칭되는 위치의 타입을 변수 R로 잡아내 결과에 사용할 수 있습니다. 예를 들어 `MyReturnType<T> = T extends (...args: any[]) => infer R ? R : never`는 함수 타입의 반환 타입을 추출하고, `ElementOf<T> = T extends (infer E)[] ? E : T`는 배열의 원소 타입을 꺼냅니다. 내장 ReturnType, Parameters, Awaited가 모두 이 방식으로 구현되어 있습니다.',
 'interview-question/1030.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1026
(5524, 1026, '타입 매개변수가 한 곳에만 등장해 입력과 출력을 연결하지 않으면 제네릭을 제거해야 함을 설명', 'ESSENTIAL', 1),
(5525, 1026, '제약과 반환이 같은 타입일 때 반환을 T로 돌리거나 매개변수를 제약 타입으로 선언하는 개선 중 최소 1개를 제시', 'ESSENTIAL', 2),
(5526, 1026, '제약 없는 T에 멤버 접근 시 오류가 나므로 필요한 최소 구조만 extends로 제약함을 설명', 'ESSENTIAL', 3),
(5527, 1026, '리터럴 타입 유지를 위해 const 타입 매개변수 <const T>를 사용함을 언급', 'SUPPLEMENTARY', 4),
(5528, 1026, '기본값 인수가 T 추론을 오염시키는 경우 NoInfer<T>로 추론을 제외함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1027
(5529, 1027, 'any는 타입 검사를 아예 포기한다는 점을 언급', 'ESSENTIAL', 1),
(5530, 1027, '제네릭은 타입 매개변수 T가 입력과 출력의 타입 관계를 보존함을 설명', 'ESSENTIAL', 2),
(5531, 1027, 'unknown은 안전하지만 반환값을 매번 좁혀야 한다는 단점을 언급', 'ESSENTIAL', 3),
(5532, 1027, 'T가 호출 시점에 인수로부터 추론됨을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1028
(5533, 1028, '단독 타입 매개변수에 유니온이 들어오면 각 멤버에 개별 적용된 뒤 유니온으로 합쳐짐을 설명', 'ESSENTIAL', 1),
(5534, 1028, '[T] extends [unknown]처럼 튜플로 감싸면 분산이 차단되어 유니온 전체에 한 번 적용됨을 설명', 'ESSENTIAL', 2),
(5535, 1028, 'ToArray<string | number>는 string[] | number[], 분산 차단 시 (string | number)[]임을 제시', 'SUPPLEMENTARY', 3),
(5536, 1028, '내장 Exclude·Extract가 분산 조건부 타입 성질로 구현됨을 언급', 'SUPPLEMENTARY', 4),
(5537, 1028, 'never에 분산하면 결과도 never가 되므로 [T] extends [never]로 감싸야 함을 설명', 'SUPPLEMENTARY', 5),

-- 질문 1029
(5538, 1029, 'keyof T가 객체 타입 T의 프로퍼티 이름들의 유니온을 만든다고 설명', 'ESSENTIAL', 1),
(5539, 1029, '인덱스 접근 타입 T[K]는 키 K에 해당하는 프로퍼티의 타입을 꺼낸다고 설명', 'ESSENTIAL', 2),
(5540, 1029, 'K extends keyof T로 제약하면 실제 존재하는 키만 받을 수 있음을 언급', 'SUPPLEMENTARY', 3),
(5541, 1029, '인덱스 시그니처를 가진 타입에서 keyof가 string | number가 됨을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1030
(5542, 1030, 'infer가 조건부 타입의 extends 절에서 매칭되는 위치의 타입을 변수로 잡아냄을 설명', 'ESSENTIAL', 1),
(5543, 1030, 'infer로 함수의 반환 타입이나 배열의 원소 타입 같은 부분 타입을 추출하는 예를 최소 1개 제시', 'ESSENTIAL', 2),
(5544, 1030, '조건부 타입이 T extends U ? X : Y 형태의 타입 수준 삼항 연산자임을 설명', 'SUPPLEMENTARY', 3),
(5545, 1030, '내장 ReturnType·Parameters·Awaited가 infer 방식으로 구현됨을 언급', 'SUPPLEMENTARY', 4);
