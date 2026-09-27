-- Unit: 유틸리티 타입과 매핑 타입 (Unit ID: 210)
-- Chapter: TypeScript (Chapter ID: 20)
-- Topic: TYPESCRIPT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-typescript-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1046, 'TYPESCRIPT', 210, 'HARD', true,
 '원본 User 타입에서 Omit으로 응답 타입을 파생할 때, 제외할 키에 오타가 난 경우와 유니온 타입에 Omit을 적용한 경우 각각 어떤 문제가 생기고 어떻게 대응할 수 있나요?',
 'Omit은 Pick<T, Exclude<keyof T, K>>로 구현되는데, K가 keyof T가 아니라 keyof any, 즉 string | number | symbol로 느슨하게 제약되어 있어 키 오타를 잡지 못합니다. 예를 들어 Omit<User, "pasword">는 조용히 통과되어 password가 응답 타입에 그대로 남습니다. 반면 Pick의 K는 keyof T로 제약되어 존재하지 않는 키를 넘기면 오류가 납니다. 엄격한 검사가 필요하면 type StrictOmit<T, K extends keyof T> = Omit<T, K>처럼 K를 keyof T로 제약한 StrictOmit을 정의해 씁니다. 두 번째로 Omit은 keyof를 먼저 계산하므로 분산 조건부 타입인 Exclude와 달리 분산되지 않습니다. 그래서 Omit<A | B, K>는 A와 B의 공통 키만 남긴 뒤 K를 제외하므로 유니온 구조가 사라집니다. 유니온 각 멤버에 Omit을 적용하려면 T extends unknown ? Omit<T, K> : never 형태의 분산 래퍼를 직접 만들어 사용해야 합니다.'),
(1047, 'TYPESCRIPT', 210, 'NORMAL', true,
 'TypeScript에서 동형 매핑 타입이란 무엇이고, 임의의 유니온을 순회하는 매핑 타입과 비교해 결과 타입에서 어떤 차이가 있나요?',
 '[P in keyof T]처럼 keyof T를 그대로 순회하는 매핑 타입을 동형(homomorphic) 매핑 타입이라고 합니다. 동형 매핑은 원본 프로퍼티의 readonly와 ? 제어자를 자동으로 보존하고, T가 배열이나 튜플이면 결과도 배열·튜플이 되며, 원시 타입에는 적용되지 않고 그대로 통과됩니다. 내장 Partial, Readonly가 이 성질에 의존합니다. [P in keyof T as ...]처럼 as 절이 붙어도 동형 매핑으로 취급되어 제어자가 보존됩니다. 반면 [P in SomeUnion]처럼 keyof T가 아닌 임의의 유니온을 순회하면 제어자 보존이 일어나지 않으므로, 필요하면 readonly나 ?를 명시적으로 지정해야 합니다.'),
(1048, 'TYPESCRIPT', 210, 'NORMAL', true,
 'Pick·Omit 같은 내장 유틸리티 타입 대신 매핑 타입의 as 절, 즉 키 재지정을 직접 사용하는 것은 어떤 경우인가요?',
 'Pick과 Omit은 지정한 키 K를 기준으로 일부 필드를 선택하거나 제외하는 도구입니다. 반면 키 이름을 규칙적으로 변환하거나 값 타입을 기준으로 필터링해야 할 때는 TypeScript 4.1부터 지원되는 매핑 타입의 as 절, 즉 키 재지정을 씁니다. 첫째, 키 이름 규칙 변환입니다. [P in keyof T as `get${Capitalize<string & P>}`]: () => T[P]처럼 as 절과 템플릿 리터럴 타입을 결합하면 Person의 name, age에서 getName, getAge 같은 규칙적인 이름을 타입 수준에서 생성할 수 있습니다. 여기서 string & P는 keyof T에 number·symbol 키가 섞일 수 있어 문자열 키만 템플릿에 넣기 위한 교차입니다. 둘째, 값 기준 필터링입니다. [P in keyof T as T[P] extends Function ? P : never]처럼 as 절이 never를 반환하면 해당 프로퍼티가 결과에서 사라지므로, 값 타입이 함수인 프로퍼티만 남기는 식의 필터링이 가능합니다.'),
(1049, 'TYPESCRIPT', 210, 'EASY', true,
 'TypeScript의 매핑 타입이 무엇인지, 그리고 매핑 중에 readonly나 선택적(?) 제어자를 어떻게 조작하는지 설명해 주세요.',
 '매핑 타입은 [P in K]: V 문법으로 키 집합 K를 순회하며 각 키 P에 대한 프로퍼티를 생성하는 문법으로, for...in을 타입 수준으로 옮긴 것이라 볼 수 있습니다. 예를 들어 Flags<"darkMode" | "beta">는 darkMode와 beta가 각각 boolean인 객체 타입이 됩니다. 기존 객체 타입을 변형할 때는 [P in keyof T]: T[P]처럼 keyof T로 키를 순회하고 인덱스 접근 T[P]로 각 키의 값 타입을 가져옵니다. 매핑 중에는 + 또는 - 기호로 readonly와 ? 제어자를 붙이거나 떼어낼 수 있습니다. -readonly를 쓰면 읽기 전용이 제거되고, -?를 쓰면 선택적 제어자가 제거되어 Required와 동일한 타입이 됩니다.'),
(1050, 'TYPESCRIPT', 210, 'EASY', true,
 'Record<K, V> 유틸리티 타입은 무엇이고, 상태 값 같은 유니온 타입을 키로 사용할 때 어떤 이점이 있나요?',
 'Record<K, V>는 키 K 전부에 값 V를 가진 객체 타입을 만드는 유틸리티 타입입니다. 예를 들어 Record<"a" | "b", number>는 { a: number; b: number }가 됩니다. 유니온 타입을 키로 쓰면 유니온의 모든 멤버에 대해 빠짐없이 매핑하도록 강제할 수 있다는 이점이 있습니다. "idle" | "loading" | "done" | "error" 같은 Status 유니온에 대해 Record<Status, string>으로 상태별 라벨 객체를 선언하면, 키가 하나라도 빠지면 컴파일 오류가 나므로 누락을 막을 수 있습니다. 또 Record<User["id"], PublicUser>처럼 인덱스 접근으로 id 타입을 재사용해 키 타입을 원본에서 파생할 수도 있습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1046
(5622, 1046, 'Omit의 K가 keyof any로 느슨하게 제약되어 키 오타를 잡지 못함을 설명', 'ESSENTIAL', 1),
(5623, 1046, 'K extends keyof T로 제약한 StrictOmit을 오타 방지 대안으로 제시', 'ESSENTIAL', 2),
(5624, 1046, 'Omit<A | B, K>가 공통 키만 남겨 유니온 구조가 사라짐을 설명', 'ESSENTIAL', 3),
(5625, 1046, 'T extends unknown ? Omit<T, K> : never 형태의 분산 래퍼를 대안으로 제시', 'ESSENTIAL', 4),
(5626, 1046, 'Pick의 K는 keyof T로 제약되어 존재하지 않는 키를 넘기면 오류임을 언급', 'SUPPLEMENTARY', 5),
(5627, 1046, 'Omit이 keyof를 먼저 계산하므로 분산되지 않는다는 점을 원인으로 명시', 'SUPPLEMENTARY', 6),

-- 질문 1047
(5628, 1047, '[P in keyof T]처럼 keyof T를 그대로 순회하는 매핑 타입을 동형 매핑이라 함을 명시', 'ESSENTIAL', 1),
(5629, 1047, '동형 매핑은 원본의 readonly·? 제어자를 자동으로 보존함을 설명', 'ESSENTIAL', 2),
(5630, 1047, '임의의 유니온을 순회하는 매핑 타입에서는 제어자 보존이 일어나지 않음을 설명', 'ESSENTIAL', 3),
(5631, 1047, '동형 매핑에서 T가 배열·튜플이면 결과도 배열·튜플이 됨을 언급', 'SUPPLEMENTARY', 4),
(5632, 1047, '동형 매핑은 원시 타입에는 적용되지 않고 그대로 통과됨을 언급', 'SUPPLEMENTARY', 5),
(5633, 1047, 'as 절이 붙은 [P in keyof T as ...]도 동형 매핑으로 취급됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1048
(5634, 1048, 'Pick·Omit은 지정한 키 K를 기준으로 필드를 선택·제외하는 도구임을 설명', 'ESSENTIAL', 1),
(5635, 1048, 'as 절과 템플릿 리터럴 타입을 결합해 getName 같은 규칙적인 키 이름으로 변환함을 설명', 'ESSENTIAL', 2),
(5636, 1048, 'as 절이 never를 반환하면 해당 프로퍼티가 결과에서 제거되어 값 기준 필터링이 됨을 설명', 'ESSENTIAL', 3),
(5637, 1048, '키 재지정 as 절이 TypeScript 4.1부터 지원됨을 언급', 'SUPPLEMENTARY', 4),
(5638, 1048, 'keyof T에 number·symbol 키가 섞일 수 있어 string & P로 문자열 키만 템플릿에 넣음을 설명', 'SUPPLEMENTARY', 5),

-- 질문 1049
(5639, 1049, '[P in K]: V 문법으로 키 집합을 순회하며 각 키의 프로퍼티를 생성함을 설명', 'ESSENTIAL', 1),
(5640, 1049, 'keyof T와 인덱스 접근 T[P]로 기존 객체 타입의 키와 값 타입을 가져옴을 설명', 'ESSENTIAL', 2),
(5641, 1049, '+/- 기호로 readonly·? 제어자를 붙이거나 떼어낼 수 있음을 언급', 'ESSENTIAL', 3),
(5642, 1049, '매핑 타입을 for...in을 타입 수준으로 옮긴 것에 비유해 서술', 'SUPPLEMENTARY', 4),
(5643, 1049, '-? 로 선택적 제어자를 제거하면 Required와 동일함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1050
(5644, 1050, 'Record<K, V>가 키 K 전부에 값 V를 가진 객체 타입을 만듦을 설명', 'ESSENTIAL', 1),
(5645, 1050, '유니온 키 중 하나라도 빠지면 컴파일 오류가 나 빠짐없는 매핑을 강제함을 설명', 'ESSENTIAL', 2),
(5646, 1050, 'Record<Status, string>처럼 상태별 라벨 객체를 선언하는 예를 제시', 'SUPPLEMENTARY', 3),
(5647, 1050, 'User["id"] 같은 인덱스 접근으로 Record의 키 타입을 재사용하는 예를 제시', 'SUPPLEMENTARY', 4);
