-- Unit: 제네릭과 제약 (Unit ID: 206)
-- Chapter: TypeScript (Chapter ID: 20)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (632, 206, '분배 조건부 타입과 const 매개변수'),
       (790, 206, 'keyof 결과와 인덱스 접근 타입'),
       (948, 206, '제약·keyof·infer로 타입 매개변수 좁히기');

-- =====================================================
-- Lesson 632: 분배 조건부 타입과 const 매개변수
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3971, 632, '아래 타입 별칭을 적용했을 때 R로 평가되는 타입은?', '```typescript
type Wrap<T> = T extends unknown ? T[] : never;

type R = Wrap<string | number>;
```', 'OBJECTIVE'),
       (3972, 632, '아래 코드의 타입 검사 결과에 대한 설명으로 옳은 것은?', '```typescript
interface Config {
  retry: number;
  host: string;
}

function pick<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const conf: Config = { retry: 3, host: "localhost" };
const v = pick(conf, "retry");
```', 'OBJECTIVE'),
       (3973, 632, '아래 비교표를 바탕으로 옳지 않은 것은?', '같은 이름의 함수를 세 가지로 선언해 동작을 비교한 표다.

| 선언 | 본문에서 v.length 접근 | run("abc")의 반환 타입 | run(42) |
|---|---|---|---|
| A `function run<T extends { length: number }>(v: T): T` | 가능 | `string` | 컴파일 오류 |
| B `function run(v: { length: number }): { length: number }` | 가능 | `{ length: number }` | 컴파일 오류 |
| C `function run<T>(v: T): T` | 불가 | `string` | `number` |', 'OBJECTIVE'),
       (3974, 632, '아래 코드에서 Out으로 평가되는 타입은?', '```typescript
type Unpack<T> = T extends (...args: any[]) => infer R
  ? (R extends Promise<infer U> ? U : R)
  : never;

async function loadUser() {
  return { id: 1, name: "김철수" };
}

type Out = Unpack<typeof loadUser>;
```', 'OBJECTIVE'),
       (3975, 632, '아래 수정으로 도입된 TypeScript 타입 문법의 이름은?', '배열의 첫 요소를 돌려주는 헬퍼가 아래처럼 선언돼 있었다.

```typescript
function first(arr: any[]): any {
  return arr[0];
}

const n = first([1, 2, 3]);
n.toUpperCase(); // 편집기 경고 없음 -> 실행 중 TypeError
```

시그니처만 고쳤더니 같은 호출에서 n이 number | undefined로 표시되고 n.toUpperCase()에 곧바로 오류 표시가 붙었다. 인수를 ["a", "b"]로 바꾸면 n은 string | undefined가 된다.', 'SUBJECTIVE'),
       (3976, 632, '아래 상황에서 선언부의 타입 매개변수 앞에 덧붙인 TypeScript 5.0의 키워드는?', '정렬 방향 목록을 만드는 헬퍼가 있다.

```typescript
function tuple<T extends readonly unknown[]>(...items: T): T {
  return items;
}

const t = tuple("asc", "desc"); // t: string[]
```

t를 "asc" | "desc"만 받는 함수에 넘기자 타입이 맞지 않는다는 오류가 났다. 호출부마다 as const를 붙이는 대신 선언부에 키워드 하나만 덧붙이자 t가 readonly ["asc", "desc"]로 추론되며 오류가 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3971
(10763, 3971, '(string | number)[]', '유니온을 통째로 한 번만 대입해 본 오해. 검사 대상을 [T]처럼 튜플로 감싸 분산을 막았을 때 나오는 결과다.', false),
(10764, 3971, 'unknown[]', '조건절에 쓴 unknown이 결과 타입까지 바꾼다고 본 오해. 조건이 참일 때 돌려주는 것은 unknown[]이 아니라 T[]다.', false),
(10765, 3971, 'string[] | number[]', '검사 대상 T가 홀로 놓인 타입 매개변수라 유니온이 string과 number로 나뉘어 각각 적용되고, 그 결과가 다시 유니온으로 합쳐진다.', true),
(10766, 3971, 'never', 'string | number가 unknown에 대입되지 못한다고 본 오해. unknown은 모든 타입을 받으므로 조건이 항상 참이고 never 가지로 가지 않는다.', false),

-- 문제 3972
(10767, 3972, 'v는 number로 추론되고, pick(conf, "port")는 컴파일 오류가 된다.', 'K가 인수 "retry"로 좁혀지고 반환이 T[K]라 Config["retry"] 즉 number가 된다. "port"는 keyof Config에 없어 인수 단계에서 걸린다.', true),
(10768, 3972, '키 검사는 실행 시점에 이뤄지므로 없는 키를 넘겨도 컴파일은 통과한다.', '컴파일 시점 제약을 런타임 검증으로 오해한 것. keyof 제약은 타입 검사 단계에서 걸러지며, 타입 정보는 실행 코드에 남지 않는다.', false),
(10769, 3972, 'K가 string으로 추론되므로 v의 타입은 number | string이 된다.', '리터럴 인수가 K로 좁혀지는 과정을 놓친 것. K extends keyof T 덕분에 K는 "retry"로 추론되어 키 유니온 전체가 되지 않는다.', false),
(10770, 3972, 'T에 제약이 없으므로 함수 본문의 obj[key] 접근이 컴파일 오류가 된다.', 'T 쪽 제약만으로 멤버 접근 가능 여부를 판단한 오해. K가 keyof T로 묶여 있어 obj[key]는 T[K] 타입으로 안전하게 인정된다.', false),

-- 문제 3973
(10771, 3973, 'A는 인수의 타입을 반환까지 실어 보내므로 run("abc").toUpperCase()가 통과한다.', '표에서 A의 반환이 string이라 문자열 메서드를 이어 쓸 수 있다. 제약을 걸어도 반환을 T로 두면 호출부의 원래 타입이 살아남는다.', false),
(10772, 3973, 'C는 42도 받아들이지만, 그 대가로 함수 본문에서 v의 구조를 가정한 접근을 못 한다.', '표의 C는 run(42)가 통과하는 대신 v.length 접근이 불가다. 제약이 없으면 T가 어떤 타입이든 될 수 있어 멤버 접근이 막힌다.', false),
(10773, 3973, 'A와 B는 인수를 걸러내는 판정이 같아, 42를 막는 것만 놓고 보면 차이가 없다.', '표에서 둘 다 run(42)가 컴파일 오류다. 두 선언의 차이는 인수 통과 여부가 아니라 반환 타입을 얼마나 보존하느냐에서 갈린다.', false),
(10774, 3973, 'B는 A와 달리 반환값에도 문자열 고유 메서드를 이어 쓸 수 있다.', '표의 B 반환은 { length: number }라 toUpperCase 같은 문자열 메서드가 사라진다. 원래 타입을 지켜 주는 쪽은 오히려 A이므로 이 진술이 거짓이다.', true),

-- 문제 3974
(10775, 3974, 'Promise<{ id: number; name: string }>', 'infer R까지만 벗기고 안쪽 조건절을 놓친 것. R이 Promise에 대입되면 infer U로 한 겹 더 벗겨진다.', false),
(10776, 3974, '{ id: number; name: string }', 'typeof loadUser는 Promise를 돌려주는 함수 타입이라 R은 Promise<{ id: number; name: string }>이 되고, 안쪽 조건에서 U가 그 객체 타입으로 잡힌다.', true),
(10777, 3974, '{ id: 1; name: "김철수" }', 'async 함수가 반환한 객체가 리터럴 타입으로 굳는다고 본 오해. as const가 없으면 프로퍼티 타입은 number, string으로 넓혀진다.', false),
(10778, 3974, 'never', '함수 타입 매칭에 실패했다고 본 오해. (...args: any[]) => infer R은 매개변수가 없는 함수도 받아들여 조건이 참이 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1280, 3975, '제네릭,제네릭 타입,generic,generics,타입 매개변수,type parameter,타입 파라미터', '같은 호출이 인수에 따라 number | undefined와 string | undefined로 갈리는 것은 타입 매개변수 T가 입력과 출력을 이어 준 결과다. any는 검사를 아예 포기해 이 관계가 끊기고, unknown은 안전하지만 값을 쓸 때마다 좁혀야 해서 호출부 타입이 저절로 살아나지는 않는다. 제네릭의 가치는 호출부 타입 정보의 보존에 있다.'),
       (1281, 3976, 'const,const 타입 매개변수,const type parameter,const 제네릭,const modifier', '타입 매개변수 앞에 붙인 const는 그 매개변수로 추론되는 인수를 as const를 붙인 것처럼 읽어 readonly 튜플과 리터럴 타입으로 굳힌다. 값 선언에 쓰는 const 키워드와는 역할이 다르고, T extends readonly unknown[] 같은 제약과도 구분해야 한다. 제약은 이미 string[]으로 넓혀진 타입도 그대로 받아들이므로 리터럴 보존에는 도움이 되지 않는다.');

-- =====================================================
-- Lesson 790: keyof 결과와 인덱스 접근 타입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4919, 790, '아래 코드에서 타입 K로 평가되는 것은?', '```typescript
interface ScoreTable {
  [subject: string]: number;
}

type K = keyof ScoreTable;
```', 'OBJECTIVE'),
       (4920, 790, '아래 코드에서 타입 A와 B로 각각 평가되는 것은?', '```typescript
type IsNever<T> = T extends never ? "yes" : "no";

type A = IsNever<never>;
type B = IsNever<string>;
```', 'OBJECTIVE'),
       (4921, 790, '아래 비교표에서 따라 나오는 설명으로 옳은 것은?', '값 하나를 그대로 돌려주는 헬퍼 f를 세 가지로 선언하고, 같은 코드를 컴파일한 결과를 비교한 표다.

| 선언 | 본문 안 v.trim() | f(42) 호출 | f("hi")의 반환 타입 | f(42)의 반환 타입 |
|---|---|---|---|---|
| A `function f(v: any): any` | 통과 | 통과 | `any` | `any` |
| B `function f(v: unknown): unknown` | 컴파일 오류 | 통과 | `unknown` | `unknown` |
| C `function f<T>(v: T): T` | 컴파일 오류 | 통과 | `string` | `number` |', 'OBJECTIVE'),
       (4922, 790, '아래 오류를 없애면서 호출부의 반환 타입도 그대로 지키는 시그니처 수정으로 옳은 것은?', '```typescript
interface Entity {
  id: number;
}

function findById<T>(items: T[], target: number): T | undefined {
  return items.find((item) => item.id === target);
}
```

컴파일하면 아래 오류가 난다.

```
error TS2339: Property ''id'' does not exist on type ''T''.
```

User는 Entity의 필드를 모두 가진 인터페이스이며, 호출부에서 findById(users, 3)의 결과는 User | undefined로 남아야 한다.', 'OBJECTIVE'),
       (4923, 790, '아래 빈칸(____)에 들어갈 TypeScript 키워드는?', '```typescript
function loadUser() {
  return { id: 1, name: "김철수" };
}

type UserSummary = { id: number; name: string };
```

loadUser가 돌려주는 객체에 email을 추가한 날, UserSummary는 예전 모양 그대로라 화면 코드에서 summary.email이 없다는 오류가 났다. 아래처럼 고친 뒤로는 loadUser만 손봐도 UserSummary가 함께 바뀌었다.

```typescript
type Ret<T> = T extends (...args: any[]) => ____ R ? R : never;

type UserSummary = Ret<typeof loadUser>;
```', 'SUBJECTIVE'),
       (4924, 790, '아래 코드에서 반환 타입 자리에 쓴 Order["status"] 같은 타입 문법의 이름은?', '주문 코드가 같은 유니온을 두 군데에 나눠 적어 두고 있었다.

```typescript
interface Order {
  id: number;
  status: "READY" | "SHIPPED";
}

function findStatus(id: number): "READY" | "SHIPPED" {
  // ...
}
```

Order의 status에 "CANCELED"를 추가했지만 findStatus의 반환 타입은 그대로 남아, 취소 상태를 돌려주는 경로에서 타입 검사가 아무 경고도 내지 않았다. 아래처럼 고친 뒤로는 Order 한 곳만 고쳐도 findStatus의 반환 타입이 따라왔다.

```typescript
function findStatus(id: number): Order["status"] {
  // ...
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4919
(13291, 4919, 'string', '인덱스 시그니처의 키를 string으로 적었으니 키 유니온도 string뿐이라고 본 오해. JavaScript에서 숫자 키가 문자열로 바뀌어 접근되므로 number 키도 함께 허용된다.', false),
(13292, 4919, 'string | number', '문자열 인덱스 시그니처를 가진 타입에서 keyof는 string | number다. obj[0]처럼 숫자로 접근한 키가 런타임에 문자열로 변환되기 때문이다. 문자열 키만 쓰려면 keyof T & string으로 교차시킨다.', true),
(13293, 4919, 'number', '프로퍼티 값의 타입을 키의 타입으로 혼동한 것. keyof가 뽑는 것은 값 쪽이 아니라 키 쪽이며, 값 타입을 꺼내려면 ScoreTable[string]처럼 인덱스 접근을 써야 한다.', false),
(13294, 4919, 'never', '이름이 고정된 프로퍼티가 하나도 없으니 키 유니온이 비어 있다고 본 오해. 인덱스 시그니처 자체가 어떤 키를 받는지 알려 주므로 빈 유니온이 되지 않는다.', false),

-- 문제 4920
(13295, 4920, 'A는 "yes", B는 "no"', '조건절이 never에도 한 번 그대로 적용된다고 본 오해. 검사 대상이 홀로 놓인 타입 매개변수면 유니온 멤버마다 나눠 적용되는데, never에는 나눠 줄 멤버가 없다.', false),
(13296, 4920, 'A는 "no", B는 "no"', 'never가 never에 대입되지 못한다고 본 오해. 대입 가능성을 따지기 전에 분산이 먼저 일어나므로 거짓 가지인 "no"로도 가지 않는다.', false),
(13297, 4920, 'A는 never, B는 "no"', 'T가 홀로 놓인 타입 매개변수라 유니온의 멤버마다 나눠 적용된다. never는 멤버가 없는 빈 유니온이라 결과도 빈 유니온, 즉 never가 된다. 의도대로 판별하려면 [T] extends [never]처럼 튜플로 감싸 분산을 막는다.', true),
(13298, 4920, 'A는 "yes", B는 "yes"', '어떤 타입이든 never에 대입된다고 방향을 뒤집어 본 오해. never는 값을 하나도 갖지 않는 타입이라 반대로 모든 타입에 대입되는 쪽이고, string은 never에 들어가지 못한다.', false),

-- 문제 4921
(13299, 4921, 'A로 선언하면 f(42).trim()이라고 써도 컴파일 단계에서 걸리지 않아, 오류가 실행 시점까지 미뤄진다.', '표에서 A는 f(42)의 반환도 any다. any는 멤버 접근을 아예 검사하지 않고 통과시키므로, 없는 메서드 호출이 실행 중 TypeError로 뒤늦게 드러난다. 검사를 포기한 대가다.', true),
(13300, 4921, 'B로 선언하면 f("hi")의 반환값에 곧바로 .toUpperCase()를 이어 쓸 수 있다.', '표의 B는 반환이 unknown이라 타입을 좁히기 전에는 어떤 멤버도 쓸 수 없다. unknown은 안전하지만 넘긴 타입을 반환까지 실어 보내지 못한다는 점을 놓친 오해다.', false),
(13301, 4921, 'C는 타입 매개변수를 두었으므로 f(42)를 인수 단계에서 걸러 낸다.', '표에서 C의 f(42)는 통과다. 타입 매개변수를 선언하는 것과 인수를 거르는 것을 혼동한 오해로, 실제로 걸러 내려면 T extends { length: number }처럼 제약을 붙여야 한다.', false),
(13302, 4921, '세 선언 모두 함수 본문에서 v.trim()을 쓸 수 있어 본문을 작성하는 쪽에서는 차이가 없다.', '표에서 B와 C는 본문의 v.trim()이 컴파일 오류다. 제약 없는 T는 어떤 타입이든 될 수 있어 멤버 접근이 막히고, unknown도 좁히기 전에는 마찬가지다.', false),

-- 문제 4922
(13303, 4922, 'function findById<T>(items: T[], target: number): Entity | undefined', '반환 타입만 바꾼 수정. 본문의 item.id 접근은 여전히 제약 없는 T를 기준으로 판정되어 오류가 그대로 남고, 통과하더라도 호출부 결과가 Entity로 납작해진다.', false),
(13304, 4922, 'function findById<T = Entity>(items: T[], target: number): T | undefined', '기본 타입 매개변수를 제약으로 오해한 것. = Entity는 추론이 실패했을 때 대신 쓸 값일 뿐 T의 구조를 약속하지 않으므로, 인수로 추론된 T에는 id가 있다는 보장이 없다.', false),
(13305, 4922, 'function findById(items: Entity[], target: number): Entity | undefined', '제네릭을 없애 오류는 사라지지만, User 배열을 넘겨도 결과가 Entity로 납작해져 호출부에서 User 고유 필드를 쓰지 못한다. 호출부 타입 보존이라는 조건을 놓친 수정이다.', false),
(13306, 4922, 'function findById<T extends Entity>(items: T[], target: number): T | undefined', 'T가 최소한 Entity의 구조를 갖는다고 약속해 본문의 item.id 접근이 허용된다. 동시에 반환을 T로 돌려주므로 호출부에서는 User | undefined가 그대로 유지된다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1596, 4923, 'infer,인퍼,infer R', '조건부 타입의 extends 절에서 들어맞는 자리의 타입을 붙잡아 이름을 붙이는 키워드가 infer다. 여기서는 함수 타입의 반환 위치를 R로 잡아 두었다가 조건이 참일 때 그대로 돌려주므로, loadUser의 반환 객체가 바뀌면 UserSummary도 따라 바뀐다. 내장 ReturnType·Parameters·Awaited가 모두 같은 방식으로 정의돼 있다. 같은 줄에 나오는 extends와 헷갈리기 쉬운데, extends는 "이 타입이 저 타입에 들어맞는가"를 판정하는 쪽이고 infer는 들어맞는 순간 그 일부를 꺼내 쓰는 쪽이다. 값에서 타입을 얻는 typeof와도 역할이 다르다.'),
       (1597, 4924, '인덱스 접근 타입,인덱스 접근,인덱스드 액세스 타입,indexed access type,indexed access types,indexed access,타입 인덱싱,룩업 타입,lookup type', '객체 타입 뒤 대괄호에 키를 넣어 그 프로퍼티의 타입을 꺼내 오는 문법이 인덱스 접근 타입이다. Order["status"]로 적어 두면 Order 쪽 유니온이 바뀔 때 반환 타입도 함께 바뀌므로 두 군데를 따로 고치다 생기는 어긋남이 사라진다. 키 자리에는 리터럴뿐 아니라 유니온이나 keyof Order도 올 수 있어, 제네릭에서는 K extends keyof T와 짝지어 T[K] 형태로 쓴다. 키 이름들의 유니온을 만드는 keyof와 구분해야 한다. keyof Order는 "id" | "status"이고, Order["status"]는 그 키가 가리키는 값 쪽 타입이다. 값에서 타입을 뽑아내는 typeof와도 다르다.');

-- =====================================================
-- Lesson 948: 제약·keyof·infer로 타입 매개변수 좁히기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5867, 948, '아래 함수 선언에 이어지는 호출 중 컴파일 오류가 나는 것은?', '```typescript
function tag<T extends { length: number }>(v: T): T {
  console.log(v.length);
  return v;
}
```', 'OBJECTIVE'),
       (5868, 948, '아래 표에 나온 조건부 타입의 동작에 대한 설명으로 옳지 않은 것은?', 'infer를 쓴 조건부 타입 두 개에 입력을 바꿔 넣고 평가 결과를 적은 표다.

| 조건부 타입 | 입력 T | 평가 결과 |
|---|---|---|
| `type El<T> = T extends (infer E)[] ? E : T` | `string[]` | `string` |
| `type El<T> = T extends (infer E)[] ? E : T` | `number` | `number` |
| `type Ret<T> = T extends (...a: any[]) => infer R ? R : never` | `() => Promise<User>` | `Promise<User>` |
| `type Ret<T> = T extends (...a: any[]) => infer R ? R : never` | `string` | `never` |', 'OBJECTIVE'),
       (5869, 948, '아래 코드에서 picked에 추론되는 타입은?', '```typescript
interface User {
  id: number;
  name: string;
  active: boolean;
}

function take<T, K extends keyof T>(obj: T, keys: K[]): T[K][] {
  return keys.map((k) => obj[k]);
}

const user: User = { id: 1, name: "김철수", active: true };
const picked = take(user, ["id", "name"]);
```', 'OBJECTIVE'),
       (5870, 948, '아래 선언에서 타입 매개변수 T에 대한 설명으로 옳은 것은?', '```typescript
interface User {
  id: number;
  name: string;
}

function report<T>(items: T[], title: string): void {
  console.log(title, items.length);
}

const users: User[] = [];
report(users, "사용자");
```', 'OBJECTIVE'),
       (5871, 948, '아래 빈칸(____)에 들어갈 TypeScript 5.4의 유틸리티 타입 이름은?', '테마 목록과 기본값을 함께 받는 헬퍼가 아래처럼 선언돼 있었다.

```typescript
function createTheme<C extends string>(colors: C[], fallback: C) {
  return { colors, fallback };
}

createTheme(["light", "dark"], "sepia"); // 아무 경고 없이 통과
```

목록에 없는 값을 기본값으로 넘겨도 편집기가 조용했고, C를 확인해 보니 "light" | "dark" | "sepia"로 넓어져 있었다. 두 번째 매개변수만 아래처럼 감싸자 같은 호출에서 곧바로 오류가 떴다.

```typescript
function createTheme<C extends string>(colors: C[], fallback: ____<C>) {
  return { colors, fallback };
}

createTheme(["light", "dark"], "sepia");
// 오류 TS2345: "sepia" 형식의 인수는 "light" | "dark" 형식의 매개변수에 할당될 수 없습니다.
```', 'SUBJECTIVE'),
       (5872, 948, '아래 코드에서 R이 두 갈래로 나뉘게 만든 타입 연산의 성질을 가리키는 용어는?', '응답 값을 한 겹 감싸는 타입을 아래처럼 선언했다.

```typescript
type ApiResult<T> = T extends unknown ? { ok: true; data: T } : never;

type R = ApiResult<User | Post>;
```

R이 `{ ok: true; data: User | Post }` 하나로 나올 줄 알았는데, 편집기에는 `{ ok: true; data: User } | { ok: true; data: Post }`로 표시됐다. 조회 결과에 따라 data에 User나 Post를 담아 돌려주는 값을 R 자리에 대입하자 어느 쪽에도 맞지 않는다는 오류가 났다. 검사 대상만 `[T] extends [unknown]`으로 바꾸자 R이 한 덩어리가 되고 오류도 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5867
(15819, 5867, 'tag("배포 완료")', '원시값이라 객체 모양의 제약을 만족할 수 없다고 본 오해. 구조적 타이핑에서 string은 number 타입의 length를 가진 것으로 취급되므로 제약을 통과하고, T는 "배포 완료"를 품은 string으로 추론된다.', false),
(15820, 5867, 'tag([1, 2, 3])', '제약에 적힌 모양이 배열과 달라 거부된다고 본 오해. 배열도 length: number를 가지므로 통과하며, 이때 T는 number[]로 추론되고 반환도 number[]로 남는다.', false),
(15821, 5867, 'tag({ length: 3, unit: "cm" })', '제약에 없는 unit 때문에 걸린다고 본 오해. 제약은 T가 최소한 갖춰야 할 구조만 요구하므로 남는 프로퍼티가 있어도 통과하고, T는 인수 타입 그대로 추론된다.', false),
(15822, 5867, 'tag(42)', 'number에는 length가 없어 T extends { length: number }를 만족하지 못한다. 제약은 본문에서 v.length를 쓸 수 있게 해 주는 대신, 그 구조가 없는 인수를 호출 단계에서 걸러 낸다.', true),

-- 문제 5868
(15823, 5868, 'El은 요소 타입을 직접 적지 않아도 배열 안쪽의 타입을 꺼내 쓸 수 있게 해 준다.', '표 1행에서 El<string[]>이 string이다. (infer E)[] 패턴이 배열 타입과 맞춰지는 순간 요소 자리의 타입이 E로 붙잡혀 참인 가지로 그대로 나간다.', false),
(15824, 5868, 'El에 배열이 아닌 타입을 넣으면 매칭에 실패해 never로 평가된다.', '표 2행에서 El<number>는 never가 아니라 number다. 매칭에 실패했을 때 무엇이 나오는지는 거짓 가지에 적은 타입이 정하는데, El은 그 자리를 T로 두어 입력을 그대로 돌려준다.', true),
(15825, 5868, 'Ret로 비동기 함수의 결과 값 타입까지 얻으려면 Promise를 한 겹 더 벗기는 조건이 필요하다.', '표 3행의 결과가 Promise<User>다. infer R은 반환 위치의 타입을 한 번만 붙잡으므로, 안쪽까지 꺼내려면 R extends Promise<infer U> ? U : R 같은 조건을 덧대야 한다.', false),
(15826, 5868, 'Ret에 함수가 아닌 타입을 넣으면 값을 하나도 갖지 않는 타입이 된다.', '표 4행에서 Ret<string>은 never다. string은 (...a: any[]) => infer R 패턴에 맞지 않아 거짓 가지로 가고, Ret는 그 자리를 never로 두었기 때문이다.', false),

-- 문제 5869
(15827, 5869, '(string | number | boolean)[]', 'K가 제약에 적힌 keyof T 전체로 추론된다고 본 오해. K는 넘긴 키 배열에서 "id" | "name"으로 좁혀지므로 쓰지 않은 active의 타입은 결과에 들어오지 않는다.', false),
(15828, 5869, 'number[] | string[]', 'T[K]가 키마다 나뉘어 배열이 따로 만들어진다고 본 오해. 유니온 멤버마다 나뉘는 것은 조건부 타입의 성질이고, 인덱스 접근 T[K]는 키들이 가리키는 값 타입을 하나의 유니온으로 합친다.', false),
(15829, 5869, '(number | string)[]', 'K가 "id" | "name"으로 추론되고 User["id" | "name"]은 number | string이다. 반환이 T[K][]라 그 유니온의 배열이 되며, 넘기는 키를 바꾸면 결과 타입도 따라 바뀐다.', true),
(15830, 5869, 'unknown[]', '제약은 허용되는 키만 정할 뿐 값 타입까지는 알 수 없다고 본 오해. T[K]는 그 키가 가리키는 프로퍼티 타입을 그대로 꺼내므로 unknown으로 뭉개지지 않는다.', false),

-- 문제 5870
(15831, 5870, 'T가 매개변수 한 곳에만 쓰여, items를 unknown[]으로 선언해도 호출부가 얻는 타입 정보는 같다.', '제네릭의 값은 입력과 출력을 이어 주는 데 있는데 T는 반환에도 다른 매개변수에도 나오지 않는다. 반환이 void라 실어 보낼 타입 자체가 없어 타입 매개변수를 지워도 호출부는 달라지지 않는다.', true),
(15832, 5870, 'T 덕분에 report(users, "사용자")의 결과에서 요소 타입이 User로 유지된다.', 'T가 붙어 있으면 호출부 타입이 저절로 보존된다고 본 오해. 보존은 T를 반환 타입으로 돌려줄 때 생기는 효과인데, 이 선언의 반환은 void라 결과에 남는 타입이 없다.', false),
(15833, 5870, 'T에 제약이 없어 본문의 items.length 접근이 컴파일 오류가 된다.', '제약이 없으면 어떤 멤버도 못 쓴다고 넓게 본 오해. 막히는 것은 T 자체의 멤버 접근이고, items의 타입은 T[]로 이미 배열이 보장돼 length는 문제없이 읽힌다.', false),
(15834, 5870, 'T가 있어 report(42, "사용자")처럼 배열이 아닌 인수도 받아들인다.', '타입 매개변수를 any처럼 무엇이든 받는 표시로 본 오해. 매개변수 타입은 T[]라 인수가 배열이어야 하고, 42는 요소 타입을 추론할 자리조차 없어 호출 단계에서 걸린다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1912, 5871, 'NoInfer,NoInfer<T>,NoInfer<C>,노인퍼', '두 번째 인수까지 C를 정하는 데 참여하는 바람에 C가 "sepia"를 품도록 넓어져 검사가 무력해진 상황이다. NoInfer<C>로 감싸면 그 자리는 C를 정할 때 쓰이지 않고, 첫 인수에서 정해진 "light" | "dark"로 검사만 받으므로 목록에 없는 기본값이 호출 단계에서 걸린다. C extends string 같은 제약과 헷갈리기 쉬운데, 제약은 C가 문자열 계열인지만 따질 뿐 넓어지는 것을 막지 못한다. 인수를 readonly 튜플과 리터럴로 굳히는 const 타입 매개변수와도 다르다. const는 추론 결과의 모양을 바꾸는 쪽이고, 이 유틸리티 타입은 어느 자리를 추론에 쓸지 고르는 쪽이다.'),
       (1913, 5872, '분산 조건부 타입,분산,분배 조건부 타입,분배,distributive conditional type,distributive,distribution', '검사 대상이 홀로 놓인 타입 매개변수일 때 유니온이 들어오면 멤버마다 조건이 따로 적용되고 그 결과가 다시 유니온으로 합쳐진다. 그래서 ApiResult<User | Post>가 객체 타입 두 개의 유니온이 되고, data에 User나 Post가 섞여 들어가는 값은 어느 멤버에도 맞지 않아 대입에서 걸린다. [T] extends [unknown]처럼 튜플로 감싸면 유니온을 통째로 한 번만 검사해 갈라지지 않는다. 내장 Exclude·Extract가 이 성질로 정의돼 있고, never는 멤버가 없는 빈 유니온이라 나눠 줄 대상이 없어 결과도 never가 된다. 분기 문법 자체인 조건부 타입과는 구분해야 한다.');
