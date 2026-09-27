-- Unit: 유틸리티 타입과 매핑 타입 (Unit ID: 210)
-- Chapter: TypeScript (Chapter ID: 20)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (636, 210, '수식어 제거와 키 재매핑, 동형 매핑 타입'),
       (794, 210, '얕은 Partial과 Record 완전성'),
       (952, 210, '유틸리티 타입이 실제로 만들어 내는 결과');

-- =====================================================
-- Lesson 636: 수식어 제거와 키 재매핑, 동형 매핑 타입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3995, 636, '아래 코드에서 타입 Result로 평가되는 것은?', '```typescript
interface Config {
  readonly host: string;
  port?: number;
}

type Result = { -readonly [P in keyof Config]-?: Config[P] };
```', 'OBJECTIVE'),
       (3996, 636, '아래 비교표를 바탕으로 옳지 않은 것은?', '```typescript
interface User { id: number; name: string; password: string }
```

| 유틸리티 | 타입 매개변수 제약 | 구현 |
|---|---|---|
| `Pick<T, K>` | `K extends keyof T` | `{ [P in K]: T[P] }` |
| `Omit<T, K>` | `K extends keyof any` | `Pick<T, Exclude<keyof T, K>>` |
| `Exclude<T, U>` | 제약 없음 | `T extends U ? never : T` (유니온 멤버마다 따로 적용) |', 'OBJECTIVE'),
       (3997, 636, '아래 두 매핑 타입에 쓰인 키 자리 문법에 대한 설명으로 옳은 것은?', '```typescript
type Getters<T> = {
  [P in keyof T as `get${Capitalize<string & P>}`]: () => T[P];
};

type Methods<T> = {
  [P in keyof T as T[P] extends Function ? P : never]: T[P];
};

interface Person { readonly name?: string; age: number; greet(): void }
```', 'OBJECTIVE'),
       (3998, 636, '아래 코드에서 타입 C로 평가되는 것은?', '```typescript
type Status = "idle" | "loading" | "done";

async function load() {
  return { id: 1, tag: "x" };
}

type A = Exclude<Status, "idle">;
type B = keyof Awaited<ReturnType<typeof load>>;
type C = Record<A, B>;
```', 'OBJECTIVE'),
       (3999, 636, '아래 상황에서 요청 본문 타입을 감싸는 데 쓴 내장 유틸리티 타입의 이름은?', '회원 수정 API의 요청 본문 타입을 어떤 내장 유틸리티 타입으로 감쌌다. 그 뒤 클라이언트가 name 자리에 undefined를 담아 보낸 요청도 타입 검사를 그대로 통과했고, 서버가 `{ ...기존회원, ...요청본문 }`으로 병합하는 순간 저장돼 있던 name 값이 undefined로 덮어써졌다. tsconfig에서 exactOptionalPropertyTypes를 켜자 그때부터 같은 요청이 거부됐다.', 'SUBJECTIVE'),
       (4000, 636, '아래 두 매핑 타입 중 M1과 같은 성질을 갖는 매핑 타입을 부르는 이름은?', '```typescript
interface Row { readonly id: number; name?: string }

type M1<T> = { [P in keyof T]: T[P] };
type M2<T> = { [P in "id" | "name"]: T[P] };

type R1 = M1<Row>;        // { readonly id: number; name?: string }
type R2 = M2<Row>;        // { id: number; name: string | undefined }

type A1 = M1<string[]>;   // string[]
type A2 = M2<string[]>;   // 오류: string[]에는 "id" 키가 없다
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3995
(10827, 3995, '`{ readonly host: string; port?: number }`', '동형 매핑이 제어자를 보존한다는 것만 보고 앞뒤에 붙은 마이너스 기호를 놓친 결과. -readonly와 -?는 보존이 아니라 제거를 지시하는 표기다.', false),
(10828, 3995, '`{ host: string; port: number }`', '-readonly가 읽기 전용 표시를 떼고, -?가 선택적 표시와 값 타입의 undefined를 함께 떼어낸다. Mutable과 Required를 한 번에 적용한 모양이 된다.', true),
(10829, 3995, '`{ readonly host: string; port: number }`', '-readonly를 읽기 전용 부여로 뒤집어 읽은 결과. 제어자를 붙이는 쪽은 +readonly이고 마이너스는 언제나 제거를 뜻한다.', false),
(10830, 3995, '`{ host: string; port: number | undefined }`', '-?가 물음표만 떼고 undefined는 유니온에 남긴다고 오해한 것. -?는 선택적 표시와 함께 값 타입의 undefined까지 걷어낸다.', false),

-- 문제 3996
(10831, 3996, '`Pick<User, "nmae">`는 오타 난 키가 keyof User에 없어 컴파일 오류가 난다.', '표의 K extends keyof T 제약이 인자를 원본 키 집합 안으로 묶는다. 존재하지 않는 키는 제약을 만족하지 못해 그 자리에서 걸린다.', false),
(10832, 3996, '`Exclude<keyof User, "password">`는 키 유니온의 멤버마다 조건이 따로 적용돼 `"id" | "name"`이 된다.', '표의 T extends U ? never : T가 유니온 멤버마다 나뉘어 평가된다. 걸러진 멤버는 never가 되고 never는 유니온에서 자동으로 사라진다.', false),
(10833, 3996, '`Omit<T, K>`는 keyof T를 먼저 계산하므로 T가 유니온이어도 멤버별로 나뉘어 처리되지 않는다.', '표의 구현에서 유니온이 나뉘는 자리는 Exclude 안쪽뿐이고 바깥 T는 조건부 타입의 검사 대상이 아니다. keyof가 공통 키만 남겨 유니온 구조가 무너진다.', false),
(10834, 3996, '`Omit<User, "pasword">`는 오타 난 키가 제약에 걸려 컴파일 오류가 나므로 실수를 잡아 준다.', '표에서 Omit의 제약은 keyof any라 어떤 문자열이든 통과한다. 오타가 조용히 넘어가 password가 결과 타입에 그대로 남는다. 막으려면 K extends keyof T로 좁힌 타입을 따로 정의해야 한다.', true),

-- 문제 3997
(10835, 3997, 'Methods<Person>에서 name과 age는 값 타입이 never인 프로퍼티가 되어 결과에 그대로 남는다.', '키 자리 조건이 never를 내면 값 타입이 never로 바뀌는 게 아니라 그 키 자체가 결과에서 빠진다. Methods<Person>은 greet만 남긴다.', false),
(10836, 3997, 'Getters<Person>의 getName은 원본의 readonly와 ?를 잃고 읽기 쓰기가 가능한 필수 프로퍼티가 된다.', 'keyof T를 순회하는 형태는 키 이름을 바꿔도 동형 매핑으로 취급돼 제어자가 보존된다. getName도 읽기 전용이자 선택적으로 남는다.', false),
(10837, 3997, 'Getters의 string & P는 keyof T에 섞일 수 있는 number, symbol 키를 걸러 문자열 키만 템플릿에 넘긴다.', '템플릿 리터럴 타입 자리에는 문자열만 들어갈 수 있다. string과 교차해 문자열 키만 남긴 뒤 Capitalize 같은 문자열 변환 타입에 넘기는 관용 표현이다.', true),
(10838, 3997, 'Methods처럼 값 타입을 기준으로 프로퍼티를 걸러내려면 결과 타입에 Omit을 한 번 더 겹쳐야 한다.', '조건식이 never를 내는 순간 그 키가 결과에서 빠지므로 필터링이 키 자리에서 끝난다. 값 타입 기준 필터링은 Omit으로는 표현하기 어렵다.', false),

-- 문제 3998
(10839, 3998, '`{ loading: "id" | "tag"; done: "id" | "tag" }`', 'Exclude가 "idle"을 걷어내 A는 "loading" | "done"이 되고, Awaited가 Promise를 벗겨 B는 "id" | "tag"가 된다. Record가 A의 모든 키에 B를 값 타입으로 붙인다.', true),
(10840, 3998, '`{ idle: "id" | "tag" }`', 'Exclude를 Extract로 뒤집어 읽은 결과. Exclude는 두 번째 인자에 해당하는 멤버를 남기는 게 아니라 유니온에서 걸러낸다.', false),
(10841, 3998, '`{ loading: number | string; done: number | string }`', 'keyof를 값 타입 모으기로 오해한 것. keyof는 키 이름의 유니온을 만들고, 값 타입의 유니온이 필요하면 T[keyof T]로 인덱스 접근해야 한다.', false),
(10842, 3998, '`{ loading: "then" | "catch" | "finally"; done: "then" | "catch" | "finally" }`', 'Awaited를 건너뛰고 Promise 자체의 키를 센 결과. async 함수의 ReturnType은 Promise라서 한 번 벗겨야 안쪽 객체의 키가 나온다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1288, 3999, 'Partial,Partial<T>,파셜,파셜 타입,partial', '모든 프로퍼티에 ?를 붙이는 매핑 타입이 Partial이고 구현은 { [P in keyof T]?: T[P] }다. 함정은 선택적이 "필드를 빼도 된다"만이 아니라 "undefined를 명시해도 된다"까지 허용한다는 점이다. 그래서 스프레드 병합에서 undefined가 기존 값을 덮어쓴다. exactOptionalPropertyTypes를 켜야 두 경우가 구분된다. ?를 반대로 떼어 내는 Required(-? 사용), 값 변경만 막는 Readonly와는 목적이 다르다.'),
       (1289, 4000, '동형 매핑 타입,동형 매핑,동형 매핑된 타입,homomorphic mapped type,homomorphic,호모모픽 매핑 타입', 'keyof T를 그대로 순회하는 매핑 타입만 동형으로 취급된다. 동형 매핑은 원본의 readonly와 ?를 자동으로 보존하고(R1), T가 배열이나 튜플이면 결과도 같은 모양을 유지하며(A1), 원시 타입은 변형 없이 통과시킨다. 내장 Partial, Required, Readonly, Pick이 모두 이 성질에 기대고 있다. 반면 M2처럼 임의의 키 유니온을 순회하면 제어자 보존이 일어나지 않아 ?가 떨어지고 값 타입에 undefined만 남는다(R2). Pick은 { [P in K]: T[P] } 형태이지만 K가 keyof T로 제약돼 동형으로 인정되는 경우다.');

-- =====================================================
-- Lesson 794: 얕은 Partial과 Record 완전성
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4943, 794, '아래 타입 Draft를 쓰는 코드 중 컴파일 오류가 나는 것은?', '```typescript
interface Profile {
  name: string;
  address: { city: string; zip: string };
}

type Draft = Partial<Profile>;

declare const d: Draft;
```', 'OBJECTIVE'),
       (4944, 794, '아래 코드에서 Plan에 "enterprise"를 한 멤버 더 추가했을 때 일어나는 일로 옳은 것은?', '```typescript
type Plan = "free" | "pro" | "team";

const priceOf: Record<Plan, number> = {
  free: 0,
  pro: 9900,
  team: 29000,
};

function priceLabel(p: Plan): string {
  return `${priceOf[p]}원`;
}
```', 'OBJECTIVE'),
       (4945, 794, '아래 코드에서 타입 X로 평가되는 것은?', '```typescript
declare function retryJob(jobId: string, at: Date, count?: number): void;

type Args = Parameters<typeof retryJob>;
type X = [Args[1], NonNullable<Args[2]>];
```', 'OBJECTIVE'),
       (4946, 794, '아래 표에 정리한 세 유틸리티 타입에 대한 설명으로 옳지 않은 것은?', '| 타입 | 적용 방식 | 예시 |
|---|---|---|
| `Exclude<T, U>` | 유니온 T의 멤버마다 조건을 따로 평가해 U에 대입 가능한 멤버를 제거 | `Exclude<"a" \| "b" \| "c", "a" \| "c">` → `"b"` |
| `Extract<T, U>` | 유니온 T의 멤버마다 조건을 따로 평가해 U에 대입 가능한 멤버만 유지 | `Extract<string \| number \| null, null>` → `null` |
| `NonNullable<T>` | 유니온 T에서 null과 undefined 멤버를 제거 | `NonNullable<string \| null \| undefined>` → `string` |', 'OBJECTIVE'),
       (4947, 794, '아래 상황에서 내부 전용 타입을 만들 때 응답 타입을 감싼 내장 유틸리티 타입의 이름은?', '결제 대행사가 내려 주는 응답 타입은 모든 프로퍼티에 물음표가 붙어 있다. 우리 서버는 스키마 검증을 통과한 응답만 정산 로직으로 넘기는데도, 정산 함수마다 `if (res.amount === undefined) throw new Error(...)` 같은 방어 코드가 열 곳 넘게 되풀이됐다. 검증을 통과한 지점에서 응답을 내장 유틸리티 타입 하나로 감싼 별칭으로 좁히자 그 방어 코드가 모두 사라졌고, 값 타입에 딸려 있던 undefined도 함께 정리됐다.', 'SUBJECTIVE'),
       (4948, 794, '아래 상황에서 목록 화면의 props 타입을 파생시키는 데 쓴 내장 유틸리티 타입의 이름은?', '주문 목록 화면은 주문 번호와 상태 두 가지만 그린다. 그런데 props 타입으로 서버 응답 타입 Order를 그대로 받아 쓰다 보니, 테스트에서 목 객체를 만들 때마다 화면이 쓰지도 않는 필드까지 22개를 전부 채워야 했다. props 타입을 Order에서 파생한 타입으로 바꾸자 목 객체가 두 줄로 줄었다. 그리고 파생할 때 키 이름을 orderNo 대신 ordrNo로 잘못 적자 그 자리에서 곧바로 컴파일 오류가 났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4943
(13355, 4943, '`d.name = undefined;`', 'Partial이 붙인 물음표는 프로퍼티를 빼도 된다는 뜻만이 아니라 값 타입에 undefined를 더한 것이기도 해서 이 대입은 통과한다. 두 경우를 가르려면 exactOptionalPropertyTypes를 켜야 한다.', false),
(13356, 4943, '`d.address = { city: "서울" };`', 'Partial은 바깥 한 겹의 키에만 물음표를 붙이고 address 안쪽 zip은 그대로 필수라 zip이 빠진 객체가 거부된다. 중첩까지 선택적으로 만들려면 재귀 매핑 타입을 직접 작성해야 한다.', true),
(13357, 4943, '`d.address = { city: "서울", zip: "04524" };`', 'address 프로퍼티를 생략할 수 있게 됐을 뿐, 값을 줄 때 요구하는 모양은 원본 그대로다. 안쪽 필수 키를 모두 채웠으므로 통과한다.', false),
(13358, 4943, '`delete d.address;`', 'delete는 선택적 프로퍼티에만 허용되는데 Partial이 address에 물음표를 붙여 두었으므로 통과한다. 원본 Profile 타입의 값이었다면 거부됐을 코드다.', false),

-- 문제 4944
(13359, 4944, 'priceLabel 안의 priceOf[p] 접근이 키를 찾지 못해 그 줄에서 컴파일 오류가 난다.', 'Record가 만든 타입은 Plan의 모든 멤버를 키로 갖고 있어서 p가 어떤 멤버든 인덱스 접근은 성립한다. 부족한 쪽은 값을 채워 넣는 객체다.', false),
(13360, 4944, '타입 검사에서는 아무 오류도 없고, enterprise 요금을 조회할 때 실행 중에 undefined가 나온다.', 'Record를 키를 느슨하게 받는 인덱스 시그니처로 오해한 결과. 인덱스 시그니처와 달리 Record는 유니온 멤버를 하나하나 요구해 빠진 키를 컴파일 단계에서 잡는다.', false),
(13361, 4944, 'Record가 키를 선택적으로 다루므로 그대로 통과하며, 전부 채우게 하려면 Required로 한 번 더 감싸야 한다.', 'Record가 만드는 프로퍼티에는 물음표가 붙지 않는다. 처음부터 전부 필수라 Required를 덧붙일 이유가 없고, 감싸도 결과 타입은 달라지지 않는다.', false),
(13362, 4944, 'priceOf 객체 리터럴에 enterprise 키가 없어 그 선언에서 컴파일 오류가 난다.', 'Record는 키 유니온의 멤버마다 필수 프로퍼티를 만들기 때문에 멤버가 늘면 대입하는 객체도 그만큼 채워야 한다. 유니온이 커질 때 빠뜨린 자리를 컴파일러가 짚어 주게 하는 쓰임새다.', true),

-- 문제 4945
(13363, 4945, '`[Date, number]`', 'Parameters는 매개변수 타입을 선언 순서대로 담은 튜플이라 Args[1]은 Date, Args[2]는 number | undefined다. NonNullable이 그 undefined 멤버를 걷어내 number만 남는다.', true),
(13364, 4945, '`[string, Date]`', '튜플 인덱스를 1부터 센 오해. Args[0]이 첫 매개변수 string이고 Args[1]이 두 번째인 Date다.', false),
(13365, 4945, '`[Date, number | undefined]`', '선택적 매개변수라 undefined가 붙는 데까지는 맞지만 NonNullable을 적용하지 않은 결과다. NonNullable은 유니온에서 null과 undefined 멤버를 걸러낸다.', false),
(13366, 4945, '`[Date, undefined]`', 'NonNullable을 null이 될 수 있는 멤버만 남기는 도구로 거꾸로 읽은 결과. 이름 그대로 null이 아닌 쪽을 남긴다.', false),

-- 문제 4946
(13367, 4946, '유니온이 아닌 단일 타입에 써도 되며, 이때는 조건이 한 번만 평가돼 결과가 원래 타입 아니면 never 둘 중 하나가 된다.', '멤버가 하나뿐인 유니온으로 보면 된다. 표의 규칙을 그대로 한 번만 적용하므로 `Exclude<string, number>`는 string이 남고 `Extract<string, number>`는 걸러져 never가 된다.', false),
(13368, 4946, '같은 T와 U를 넣었을 때 Exclude가 남긴 멤버와 Extract가 남긴 멤버를 합치면 원래 유니온 T가 된다.', '두 타입은 멤버마다 같은 조건을 평가해 한쪽은 거짓인 멤버를, 다른 쪽은 참인 멤버를 모은다. 표의 예시도 `string | number`와 `null`을 합치면 원래 유니온으로 되돌아간다.', false),
(13369, 4946, 'NonNullable은 객체 타입에 쓰면 프로퍼티 값에 섞인 null까지 걷어내므로 `NonNullable<{ id: number; name: string | null }>`은 name이 string인 타입이 된다.', 'NonNullable이 보는 것은 T 자체의 유니온 멤버뿐이다. 객체 타입은 통째로 멤버 하나이고 null이 아니므로 그대로 통과하며 안쪽 name은 손대지 않는다. 안쪽까지 바꾸려면 매핑 타입을 직접 써야 한다.', true),
(13370, 4946, '함수 반환 타입이 `User | null`일 때 표의 세 번째 도구를 ReturnType 결과에 이어 붙이면 null 검사를 마친 뒤의 타입을 이름 붙여 쓸 수 있다.', '`NonNullable<ReturnType<typeof findUser>>`처럼 겹쳐 쓰면 유니온에서 null만 빠진 타입이 나온다. 유틸리티 타입은 결과를 다시 인자로 넘겨 조합하는 것이 기본 사용법이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1604, 4947, 'Required,Required<T>,required,리콰이어드', '모든 프로퍼티에서 물음표를 떼어 필수로 만드는 내장 타입이 Required이고, 구현은 매핑 중에 제어자를 제거하는 `{ [P in keyof T]-?: T[P] }` 형태다. 물음표만 사라지는 것이 아니라 값 타입에 딸려 있던 undefined까지 함께 빠지기 때문에 호출부의 방어 코드가 필요 없어진다. 반대로 물음표를 붙이는 Partial, 대입만 막는 Readonly와 목적이 다르고, 유니온에서 null·undefined 멤버를 걸러내는 NonNullable과도 구분해야 한다. NonNullable은 프로퍼티 단위가 아니라 타입 전체의 유니온을 다룬다.'),
       (1605, 4948, 'Pick,pick,픽', '원본 타입에서 필요한 키만 골라 새 타입을 만드는 내장 타입이 Pick이고 구현은 `{ [P in K]: T[P] }`다. K가 `keyof T`로 제약돼 있어 오타 난 키는 제약을 만족하지 못하고 그 자리에서 걸리는데, 이 대목이 Omit과 갈리는 단서다. 특정 키를 빼는 Omit은 `Pick<T, Exclude<keyof T, K>>`로 구현되지만 K 제약이 `keyof any`라 오타를 잡아 주지 못한다. 남길 필드가 적으면 Pick, 뺄 필드가 적으면 Omit이 읽기 쉽고, 어느 쪽이든 원본 하나에서 파생해 두면 필드 변경이 자동으로 따라온다.');

-- =====================================================
-- Lesson 952: 유틸리티 타입이 실제로 만들어 내는 결과
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5891, 952, '아래 코드에서 타입 NoId로 평가되는 것은?', '```typescript
type Circle = { kind: "circle"; id: number; radius: number };
type Square = { kind: "square"; id: number; side: number };
type Shape = Circle | Square;

type NoId = Omit<Shape, "id">;
```', 'OBJECTIVE'),
       (5892, 952, '아래 코드를 컴파일하고 실행했을 때 일어나는 일로 옳은 것은?', '```typescript
// tsconfig: strict 켬, noUncheckedIndexedAccess 끔
const stock: Record<string, number> = { apple: 3 };

const n = stock["banana"];
console.log(n.toFixed(1));
```', 'OBJECTIVE'),
       (5893, 952, '아래 코드에서 타입 A와 C로 평가되는 것을 바르게 짝지은 것은?', '```typescript
type Box<T> = { [P in keyof T]: T[P][] };

type A = Box<[string, number]>;
type C = Box<string>;
```', 'OBJECTIVE'),
       (5894, 952, '아래 코드에서 컴파일 오류가 나는 줄은?', '```typescript
interface Cart {
  items: string[];
  owner: { name: string };
}

declare const c: Readonly<Cart>;
```', 'OBJECTIVE'),
       (5895, 952, '아래 상황에서 ReturnType 결과를 한 번 더 감싸는 데 쓴 내장 유틸리티 타입의 이름은?', '주문 조회 함수 `fetchOrders`는 async 함수이고 반환 타입을 따로 적지 않았다. 화면 코드에서 `type Result = ReturnType<typeof fetchOrders>;`로 결과 타입을 받아 `res.items`에 접근하자 아래 오류가 났다.

```
error TS2339: Property ''items'' does not exist on type ''Promise<{ items: Order[]; total: number; }>''.
```

`ReturnType<...>` 바깥을 내장 유틸리티 타입 하나로 감싸자 오류가 사라졌다. 같은 타입에 `Promise<Promise<number>>`를 넣어 보니 결과는 `number`였다.', 'SUBJECTIVE'),
       (5896, 952, '아래 코드의 빈칸에 들어갈 문법 요소를 가리키는 용어는?', '```typescript
interface FormState { email: string; nickname: string; agreed: boolean }

type Setters<T> = {
  [P in keyof T ____ `set${Capitalize<string & P>}`]: (v: T[P]) => void;
};

type S = Setters<FormState>;
// { setEmail: (v: string) => void;
//   setNickname: (v: string) => void;
//   setAgreed: (v: boolean) => void }
```

빈칸 뒤의 식을 `T[P] extends string ? ... : never`로 바꾸자 결과에서 `setAgreed`가 아예 사라졌다. 이 문법은 TypeScript 4.1부터 쓸 수 있다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5891
(15883, 5891, '`{ kind: "circle"; radius: number } | { kind: "square"; side: number }`', 'Omit이 유니온 멤버마다 따로 적용된다고 본 오해. Omit은 keyof를 먼저 계산하는 Pick과 Exclude의 조합이라 분산되지 않는다.', false),
(15884, 5891, '`{ kind: "circle" | "square" }`', 'keyof Shape는 두 멤버의 공통 키인 "kind" | "id"뿐이다. 여기서 "id"를 빼면 kind만 남고, 그 값 타입은 두 멤버의 kind를 합친 유니온이 된다.', true),
(15885, 5891, '`{ kind: "circle" | "square"; radius: number; side: number }`', '유니온의 keyof를 모든 멤버 키의 합집합으로 착각한 결과. 유니온 타입의 keyof는 모든 멤버에 공통인 키만 모은다.', false),
(15886, 5891, '`never`', '유니온 전체에 Omit을 쓰면 타입이 성립하지 않는다고 본 오해. 공통 키가 남아 있으므로 결과는 빈 타입이 아니라 kind 하나를 가진 객체 타입이다.', false),

-- 문제 5892
(15887, 5892, 'stock 선언에서 모든 문자열 키를 채우지 않았다는 컴파일 오류가 난다.', '유니온 키의 Record가 멤버를 빠짐없이 요구하는 성질을 string 키에도 적용한 오해. 키가 string이면 인덱스 시그니처가 되어 어떤 키 조합이든 대입된다.', false),
(15888, 5892, 'stock["banana"] 접근에서 존재하지 않는 키라는 컴파일 오류가 난다.', 'Record<string, number>는 모든 문자열 키를 허용하는 타입이라 banana도 합법적인 키다. 실제로 값이 있는지는 타입 검사가 알 수 없다.', false),
(15889, 5892, 'n이 number | undefined로 추론돼 toFixed 호출에서 컴파일 오류가 난다.', '인덱스 접근 결과에 undefined를 붙여 주는 것은 noUncheckedIndexedAccess를 켰을 때의 동작이다. 본문처럼 꺼져 있으면 n은 그냥 number다.', false),
(15890, 5892, '컴파일은 통과하지만 실행하면 toFixed 호출에서 TypeError가 난다.', '인덱스 시그니처의 값 타입이 number라 n도 number로 추론돼 검사를 통과한다. 하지만 실제 값은 undefined라 실행 중에 메서드 호출이 실패한다.', true),

-- 문제 5893
(15891, 5893, 'A: `[string[], number[]]`, C: `string[]`', '튜플은 맞게 풀었지만 원시 타입도 배열로 감싼다고 본 결과. keyof T를 순회하는 매핑 타입에 원시 타입을 넣으면 변형 없이 그대로 통과한다.', false),
(15892, 5893, 'A: `[string, number][]`, C: `string[]`', '매핑 타입이 T 전체를 배열로 감싼다고 본 오해. 매핑은 키 하나하나의 값 타입을 바꾸므로 튜플의 각 요소가 따로 배열이 된다.', false),
(15893, 5893, 'A: `[string[], number[]]`, C: `string`', 'keyof T를 그대로 순회하는 동형 매핑은 튜플을 넣으면 요소마다 변환한 튜플을 돌려주고, 원시 타입을 넣으면 손대지 않고 그대로 돌려준다.', true),
(15894, 5893, 'A: `(string | number)[]`, C: `string`', '원시 타입은 맞게 읽었지만 튜플을 요소 유니온의 배열로 뭉갠 결과. 동형 매핑은 튜플의 길이와 자리별 타입을 그대로 유지한다.', false),

-- 문제 5894
(15895, 5894, '`c.items = [...c.items, "a"];`', 'Readonly는 바깥 한 겹의 프로퍼티에 readonly를 붙인다. items 자리에 새 배열을 대입하는 것은 그 프로퍼티 자체를 바꾸는 일이라 거부된다.', true),
(15896, 5894, '`c.items.push("a");`', 'Readonly가 배열 내용까지 얼린다고 본 오해. items의 타입은 여전히 string[]이라 push가 허용된다. 내용까지 막으려면 readonly string[]이 필요하다.', false),
(15897, 5894, '`c.owner.name = "kim";`', 'Readonly가 중첩 객체까지 적용된다고 본 오해. owner 참조만 읽기 전용이고 안쪽 name은 그대로 쓸 수 있다. 깊은 변환은 재귀 매핑 타입을 직접 써야 한다.', false),
(15898, 5894, '`const list: string[] = c.items;`', '읽기 전용 프로퍼티라도 값을 읽어 다른 변수에 담는 것은 문제없다. items의 타입이 string[] 그대로라 대입도 통과한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1920, 5895, 'Awaited,Awaited<T>,awaited,어웨이티드', 'async 함수의 ReturnType은 결과 객체가 아니라 그것을 담은 Promise라서 items 같은 안쪽 프로퍼티가 보이지 않는다. Awaited는 Promise를 벗겨 안쪽 타입을 꺼내는 내장 타입이고, Promise가 여러 겹이어도 재귀적으로 끝까지 벗긴다(TypeScript 4.5 이상). 그래서 Awaited<ReturnType<typeof fetchOrders>>처럼 겹쳐 쓰는 조합이 관용 표현이다. 함수에서 반환 타입을 뽑는 ReturnType, 매개변수 튜플을 뽑는 Parameters와는 역할이 다르며, 유니온에서 null과 undefined를 거르는 NonNullable로는 Promise가 벗겨지지 않는다.'),
       (1921, 5896, 'as,as 절,as절,키 재지정,키 리매핑,키 재매핑,key remapping,key remap', '매핑 타입의 키 자리에 as 절을 붙이면 순회 중인 키 P를 다른 이름으로 바꿀 수 있다. 템플릿 리터럴 타입과 Capitalize를 함께 쓰면 email이 setEmail로 바뀌는 식의 규칙적인 이름을 만들 수 있고, as 뒤 식이 never가 되면 그 키가 결과에서 빠져 값 타입 기준 필터링도 된다. keyof T를 순회하는 형태라 as가 있어도 원본의 readonly와 ?는 보존된다. 키 집합을 순회하는 in 자체나, 키 이름만 걸러내는 Exclude와는 구분해야 한다. Exclude는 유니온만 다룰 뿐 값 타입을 보고 키를 고를 수 없다.');
