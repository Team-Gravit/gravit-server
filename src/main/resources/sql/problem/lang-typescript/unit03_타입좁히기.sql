-- Unit: 타입 좁히기 (Unit ID: 207)
-- Chapter: TypeScript (Chapter ID: 20)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (633, 207, '제어 흐름 분석과 타입 가드, 완전성 검사'),
       (791, 207, '진릿값 검사와 클래스 좁히기, 단언 함수'),
       (949, 207, '타입 좁히기 응용: 진릿값·동등 비교·in 가드에서 구조 분해와 satisfies까지');

-- =====================================================
-- Lesson 633: 제어 흐름 분석과 타입 가드, 완전성 검사
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3977, 633, '아래 코드에서 컴파일 오류가 발생하는 지점은?', '```typescript
let input: string | null = load();
const fixed: string | null = load();

if (input !== null && fixed !== null) {
  input.trim();                       // (A)
  fixed.trim();                       // (B)
  setTimeout(() => input.trim(), 0);  // (C)
  setTimeout(() => fixed.trim(), 0);  // (D)
}

input = load();
```', 'OBJECTIVE'),
       (3978, 633, '아래 코드의 표시된 줄에서 컴파일 오류가 나는 이유로 옳은 것은?', '```typescript
function size(v: number[] | string | null) {
  if (typeof v === "object") {
    return v.length;   // 여기서 오류 발생
  }
  return v.length;
}
```', 'OBJECTIVE'),
       (3979, 633, '아래 사용자 정의 타입 가드에 대한 설명으로 옳은 것은?', '```typescript
function isText(value: unknown): value is string {
  return typeof value === "number";
}

function shout(input: unknown) {
  if (isText(input)) {
    return input.toUpperCase();
  }
  return "";
}
```', 'OBJECTIVE'),
       (3980, 633, '아래 세 가지 도형 타입 설계안에 대한 설명으로 옳지 않은 것은?', '| 설계안 | 판별자 kind의 선언 | 데이터 프로퍼티 |
|---|---|---|
| A | 한 인터페이스에 kind: string | 같은 인터페이스 안에 radius?: number, side?: number |
| B | 한 인터페이스에 kind를 "circle" 또는 "square" 리터럴 유니온으로 | 같은 인터페이스 안에 radius?: number, side?: number |
| C | Circle에 kind: "circle", Square에 kind: "square" | Circle에 radius: number, Square에 side: number |

세 설계안 모두 switch (shape.kind)로 분기한다.', 'OBJECTIVE'),
       (3981, 633, '아래 코드의 빈칸에 들어갈 TypeScript 연산자는?', '```typescript
type Theme = Record<string, string | [number, number, number]>;

// 처음 작성 — 타입 표기를 사용
const theme1: Theme = { primary: "#0af", accent: [255, 0, 0] };
theme1.primary.toUpperCase(); // 오류: 튜플일 수도 있다고 판단
theme1.secondary;             // 오류 없음: 없는 키를 잡아 주지 못함

// 타입 표기를 지우고 값 뒤에 한 구문을 덧붙임
const theme2 = { primary: "#0af", accent: [255, 0, 0] } ____ Theme;
theme2.primary.toUpperCase(); // 통과
theme2.accent[0];             // 통과
theme2.secondary;             // 오류: 존재하지 않는 키
```', 'SUBJECTIVE'),
       (3982, 633, '아래 상황에서 활용된 타입 검사 기법의 이름은?', '```typescript
function fail(x: never): never {
  throw new Error("처리되지 않은 케이스");
}

type Shape = Circle | Square;

function describe(shape: Shape): string {
  switch (shape.kind) {
    case "circle": return "원";
    case "square": return "정사각형";
    default: return fail(shape);
  }
}
```

얼마 뒤 Shape에 Triangle을 추가하자, 손대지 않은 describe의 default 줄에서 "Triangle 형식의 인수는 never 형식의 매개변수에 할당될 수 없습니다" 오류가 떴다. describe에 case를 하나 더 채우자 오류가 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3977
(10779, 3977, '(A) 콜백 밖에서 호출한 input.trim()', 'if 조건이 input !== null을 통과한 직후 지점이라 input은 string으로 좁혀져 있다. 같은 함수 흐름 안이므로 제어 흐름 분석 결과가 그대로 적용된다.', false),
(10780, 3977, '(B) 콜백 밖에서 호출한 fixed.trim()', 'const라 재대입이 불가능하고 조건도 통과한 뒤이므로 fixed는 string이다. 좁히기가 가장 안정적으로 유지되는 경우다.', false),
(10781, 3977, '(C) 콜백 안에서 호출한 input.trim()', 'input은 let이고 아래에서 재대입되므로, 나중에 실행될 콜백 안에서는 좁히기가 초기화되어 string | null로 되돌아간다. 그래서 null 가능성 오류가 난다.', true),
(10782, 3977, '(D) 콜백 안에서 호출한 fixed.trim()', 'fixed는 const라 값이 바뀔 수 없어 콜백 안에서도 좁힌 결과가 유지된다. 콜백이기만 하면 무조건 좁히기가 풀린다고 오해하기 쉬운 지점이다.', false),

-- 문제 3978
(10783, 3978, '배열의 typeof 결과는 "array"여서 number[]가 이 분기에서 빠지고 null만 남기 때문', 'typeof는 배열에도 "object"를 돌려준다. "array"라는 결과 자체가 없으므로 배열을 가려내려면 Array.isArray를 써야 하고, number[]는 이 분기에 그대로 남는다.', false),
(10784, 3978, 'typeof 결과가 "object"인 값에 null도 포함되어 v가 number[] | null로만 좁혀지기 때문', 'typeof null이 "object"라서 이 분기에서 null이 걸러지지 않는다. v !== null 검사를 덧붙여야 .length 접근이 안전해진다.', true),
(10785, 3978, 'typeof 검사는 유니온 멤버가 셋 이상이면 좁히기를 포기하고 원래 타입을 유지하기 때문', '유니온 멤버 개수와 좁히기는 무관하다. 제어 흐름 분석은 멤버가 몇 개든 조건을 만족할 수 있는 것만 남긴다.', false),
(10786, 3978, '.length는 배열에만 있는 프로퍼티라서 string이 남아 있는 분기에서는 접근할 수 없기 때문', 'string에도 length가 있어 마지막 줄은 오류가 없다. 문제는 프로퍼티 유무가 아니라 남아 있는 null 가능성이다.', false),

-- 문제 3979
(10787, 3979, '반환 타입은 value is string인데 본문은 숫자를 검사하므로 선언과 본문이 어긋나 컴파일 오류가 난다.', '컴파일러는 타입 서술 함수의 본문 검사 로직을 검증하지 않는다. 선언을 그대로 믿고 넘어가므로 이 코드는 컴파일을 통과한다.', false),
(10788, 3979, 'isText가 true를 반환해도 input은 unknown 그대로여서 toUpperCase 호출에서 컴파일 오류가 난다.', '반환 타입이 매개변수 is 타입 형태이므로 true 분기에서 인수가 string으로 좁혀진다. unknown이 그대로 남는다는 것은 타입 서술의 효과를 놓친 오해다.', false),
(10789, 3979, '타입 서술은 유니온 타입 매개변수에만 쓸 수 있어 unknown을 받는 이 선언은 거부된다.', 'unknown을 비롯한 어떤 타입에도 타입 서술을 쓸 수 있다. 오히려 unknown을 좁혀 쓰는 것이 타입 서술의 대표적인 용도다.', false),
(10790, 3979, '컴파일은 통과하지만 shout에 숫자를 넘기면 toUpperCase 호출이 런타임에 실패한다.', '본문이 검증되지 않으므로 잘못 쓴 가드는 컴파일러를 속인다. 숫자는 isText를 통과해 string으로 취급되지만 toUpperCase가 없어 런타임에 터진다.', true),

-- 문제 3980
(10791, 3980, 'A는 kind 비교만으로 각 분기에서 radius나 side가 있는 쪽으로 좁혀지므로 추가 검사가 필요 없다.', 'kind가 string으로 선언되면 리터럴 비교로 타입이 갈리지 않아 좁히기가 아예 일어나지 않는다. 판별자는 반드시 리터럴 타입이어야 한다.', true),
(10792, 3980, 'B는 kind 자체는 리터럴로 좁혀지지만 radius와 side가 number | undefined로 남아 쓰기 전에 확인이 필요하다.', '판별자만 리터럴이고 멤버 타입이 갈라지지 않으면 선택적 프로퍼티의 undefined 가능성이 그대로 남는다. 좁혀지는 것은 kind 프로퍼티뿐이다.', false),
(10793, 3980, 'C는 case "circle" 분기에서 shape가 Circle로 좁혀져 radius를 옵셔널 검사 없이 바로 쓸 수 있다.', '종류별로 타입을 나누고 공통 리터럴 판별자를 두면 판별자 비교만으로 유니온 전체가 한 멤버로 정확히 좁혀진다. 판별 유니온을 쓰는 이유가 이것이다.', false),
(10794, 3980, 'A와 B는 radius와 side를 동시에 채운 값도 타입 검사를 통과해 유효하지 않은 조합을 막지 못한다.', '선택적 프로퍼티로 뭉뚱그린 설계는 어떤 조합이 유효한지 타입이 말해 주지 않는다. 둘 다 채우거나 둘 다 비운 값도 통과한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1282, 3981, 'satisfies,satisfies 연산자,satisfies operator', 'satisfies는 값이 Theme를 만족하는지 검사하되 변수 타입은 추론된 좁은 타입 그대로 남긴다. 그래서 primary는 string, accent는 [number, number, number]로 유지되어 두 줄이 모두 통과하고, 없는 키 접근은 초과 프로퍼티 검사에 걸린다. 반면 타입 표기(: Theme)는 검사와 동시에 변수 타입을 Theme로 넓혀 각 값이 string | [number, number, number]가 되므로 primary.toUpperCase()가 막히고, 인덱스 시그니처 때문에 없는 키도 통과한다. as Theme는 단언이라 검사 자체가 느슨해 오타를 더 못 잡는다는 점에서 또 다르다. TypeScript 4.9부터 쓸 수 있고 as const와 함께 라우트 테이블 같은 상수 맵을 정의할 때 특히 유용하다.'),
       (1283, 3982, '완전성 검사,exhaustiveness check,exhaustiveness checking,exhaustive check,완전성 체크,철저성 검사', 'never는 어떤 값도 가질 수 없는 타입이라 아무 값도 대입할 수 없다. 모든 case를 처리했다면 default에 남는 shape의 타입이 never로 줄어 fail(shape) 호출이 통과하고, 유니온에 멤버가 늘어 남은 타입이 never가 아니게 되면 대입이 막혀 컴파일 오류가 난다. 그래서 처리하지 않은 분기가 배포 전에 드러난다. default에서 예외만 던지는 런타임 방어는 그 분기를 실제로 실행해 봐야 알 수 있다는 점이 결정적인 차이다. 판별 유니온이 전제라는 점도 함께 기억할 것 — 판별자가 string처럼 넓은 타입이면 좁히기 자체가 일어나지 않아 default에 남는 타입이 never로 줄지 않고, 이 검사도 성립하지 않는다.');

-- =====================================================
-- Lesson 791: 진릿값 검사와 클래스 좁히기, 단언 함수
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4925, 791, '아래 코드의 (C) 지점에서 컴파일러가 보는 v의 타입은?', '```typescript
function render(v: string | number[] | null) {
  if (Array.isArray(v)) {
    return v.join(",");      // (A)
  } else if (v) {
    return v.trim();         // (B)
  } else {
    return "표시할 값 없음";  // (C) 이 지점의 v
  }
}
```', 'OBJECTIVE'),
       (4926, 791, '아래 코드에 HttpError 인스턴스를 넘겼을 때의 동작으로 옳은 것은?', '```typescript
class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

function handle(err: unknown) {
  if (err instanceof Error) {
    return err.message;           // (A)
  }
  if (err instanceof HttpError) {
    return `HTTP ${err.status}`;  // (B)
  }
  return String(err);             // (C)
}

handle(new HttpError(404, "Not Found"));
```', 'OBJECTIVE'),
       (4927, 791, '아래 코드에서 a와 b에 추론되는 타입으로 옳은 것은?', '```typescript
interface Fish { swim(): void }
interface Bird { fly(): void }

function isFish(pet: Fish | Bird): pet is Fish {
  return (pet as Fish).swim !== undefined;
}

const pets: (Fish | Bird)[] = loadPets();

const a = pets.filter(isFish);
const b = pets.filter((pet): boolean => "swim" in pet);
```', 'OBJECTIVE'),
       (4928, 791, '아래 세 작성 방식을 같은 값에 적용한 결과로 옳지 않은 것은?', '```typescript
type Theme = Record<string, string | [number, number, number]>;
```

| 작성 방식 | Theme를 만족하는지 검사 | 변수에 남는 타입 |
|---|---|---|
| (가) `const t: Theme = { primary: "#0af", accent: [255, 0, 0] }` | 한다 | Theme |
| (나) `const t = { primary: "#0af", accent: [255, 0, 0] } as Theme` | 비교 가능한지만 본다 | Theme |
| (다) `const t = { primary: "#0af", accent: [255, 0, 0] } satisfies Theme` | 한다 | 값에서 추론된 타입 |', 'OBJECTIVE'),
       (4929, 791, '아래 수정에서 빈칸에 들어갈 TypeScript 키워드는?', '```typescript
// 수정 전 - 검증 함수를 호출해도 다음 줄에서 오류가 난다
function ensureString(value: unknown): void {
  if (typeof value !== "string") throw new TypeError("문자열이 아닙니다");
}

function shout(input: unknown) {
  ensureString(input);
  return input.toUpperCase(); // 오류: input의 형식이 unknown입니다
}

// 수정 후 - 본문은 그대로 두고 반환 타입만 아래처럼 바꾸자 오류가 사라졌다
function ensureString(value: unknown): ____ value is string {
  if (typeof value !== "string") throw new TypeError("문자열이 아닙니다");
}
```', 'SUBJECTIVE'),
       (4930, 791, '아래 리팩터링으로 적용한 타입 설계 패턴의 이름은?', '결제 응답 타입을 아래처럼 쓰다가 두 가지 문제가 반복됐다.

```typescript
interface PayResult {
  status: "ok" | "fail";
  receiptId?: string;
  reason?: string;
}
```

- `res.status === "ok"`를 확인한 뒤에도 `res.receiptId`가 `string | undefined`라 매번 한 번 더 확인해야 했다.
- `{ status: "ok", reason: "잔액 부족" }`처럼 실제로는 생길 수 없는 조합이 타입 검사를 통과했다.

아래처럼 바꾸자 두 문제가 함께 사라졌고, `switch (res.status)`의 각 분기에서 필요한 프로퍼티를 바로 쓸 수 있었다.

```typescript
interface PayOk { status: "ok"; receiptId: string }
interface PayFail { status: "fail"; reason: string }
type PayResult = PayOk | PayFail;
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4925
(13307, 4925, 'null', '진릿값 검사가 null과 undefined만 걸러 낸다고 본 것이다. 빈 문자열도 거짓으로 취급되므로 마지막 분기에는 string일 가능성이 그대로 남는다.', false),
(13308, 4925, 'string | null', 'Array.isArray가 거짓이라 number[]가 빠져 string | null이 되고, if (v)의 거짓 분기에는 빈 문자열일 수 있는 string이 null과 함께 남는다.', true),
(13309, 4925, 'never', '앞의 두 분기가 유니온을 모두 소진했다고 본 것이다. 빈 문자열과 null이 아직 걸러지지 않아 마지막 분기는 실제로 도달 가능하다.', false),
(13310, 4925, 'string | number[] | null', '거짓 분기에서는 좁히기가 풀려 선언 타입으로 되돌아간다고 본 것이다. 제어 흐름 분석은 else 쪽에도 앞선 조건의 결과를 이어서 적용한다.', false),

-- 문제 4926
(13311, 4926, '(B)가 실행되어 HTTP 404가 반환된다.', '더 구체적인 클래스 검사를 컴파일러가 알아서 먼저 적용해 준다고 본 것이다. instanceof 검사는 적힌 순서대로 평가되므로 (B)는 앞 검사를 통과하지 못한 값만 만난다.', false),
(13312, 4926, '(B)의 검사가 도달할 수 없다고 판정되어 컴파일 오류가 난다.', 'unknown은 instanceof의 거짓 분기에서도 unknown으로 남아 뒤따르는 검사가 그대로 허용된다. 실행되지 않는 코드라는 것과 컴파일 오류는 다른 문제다.', false),
(13313, 4926, '(A) 분기에서 err.status까지 읽을 수 있어 상태 코드가 함께 반환된다.', '좁혀진 타입이 런타임의 실제 클래스까지 반영한다고 본 것이다. (A)에서 err은 Error로만 좁혀지므로 status 접근은 컴파일 오류가 난다.', false),
(13314, 4926, '(A)가 실행되어 message만 반환되고 status는 쓰이지 않는다.', 'HttpError는 Error를 상속해 프로토타입 체인에 Error가 들어 있으므로 첫 검사에서 이미 참이 된다. 하위 클래스를 따로 다루려면 그 검사를 위로 올려야 한다.', true),

-- 문제 4927
(13315, 4927, 'a는 Fish[], b는 (Fish | Bird)[]', 'filter에는 인수가 타입 서술 함수일 때 결과 배열을 좁혀 주는 오버로드가 있다. b는 반환 타입을 boolean으로 못 박아 그 오버로드가 선택되지 않는다.', true),
(13316, 4927, 'a와 b 모두 Fish[]', '런타임에 걸러지는 원소가 같으니 타입도 같다고 본 것이다. 컴파일러는 실행 결과가 아니라 넘긴 함수의 반환 타입 선언만 보고 결과 타입을 정한다.', false),
(13317, 4927, 'a와 b 모두 (Fish | Bird)[]', 'filter는 원소를 골라낼 뿐 배열 타입은 바꾸지 못한다고 본 것이다. 타입 서술 함수를 넘기면 결과가 Fish[]로 좁혀진다.', false),
(13318, 4927, 'a는 (Fish | Bird)[], b는 Fish[]', '호출 지점에서 직접 검사하는 쪽이 더 정확하다고 본 것이다. 좁히기를 만드는 것은 검사 방식이 아니라 pet is Fish라는 반환 타입 선언이다.', false),

-- 문제 4928
(13319, 4928, '(가)에서는 t.primary.toUpperCase()가 막히지만 (다)에서는 통과한다.', '(가)는 변수 타입이 Theme가 되어 primary가 문자열과 튜플의 유니온으로 넓어진다. (다)는 값에서 추론된 string이 남아 문자열 메서드를 쓸 수 있다.', false),
(13320, 4928, '(나)는 값이 Theme와 비교 가능한지만 보므로 셋 가운데 값의 오류를 놓치기 가장 쉽다.', '표의 (나) 행처럼 단언은 검사 강도를 낮춰 컴파일러보다 개발자의 판단을 앞세우는 구문이다. 그래서 잘못 적은 값을 걸러 내는 힘이 가장 약하다.', false),
(13321, 4928, '(다)는 검사를 건너뛰고 추론만 살리므로 Theme를 만족하지 않는 값도 그대로 통과한다.', '표의 (다) 행은 검사를 한다고 적혀 있다. satisfies는 만족 여부를 그대로 검사하고 변수 타입만 추론된 쪽으로 남긴다. 검사를 느슨하게 하는 것은 (나)의 단언이다.', true),
(13322, 4928, '(다)에서 t.accent[0]은 number로 쓸 수 있다.', '값에서 추론된 타입이 남으므로 accent는 원소 세 개짜리 튜플로 유지된다. (가)·(나)에서는 accent에 문자열 가능성이 남아 인덱스 접근 결과가 number로 확정되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1598, 4929, 'asserts,asserts 키워드', 'asserts value is string으로 선언하면 컴파일러는 이 함수가 예외를 던지지 않고 반환했다는 사실만으로 인수를 string으로 취급한다. 그래서 호출한 줄 아래부터 좁힘이 이어져 input.toUpperCase()가 통과한다. 반환 타입을 value is string(타입 서술)으로만 쓰면 boolean을 돌려주어야 하고 if로 감싼 분기 안에서만 좁혀지므로, 값을 검증하고 지나가는 이 코드에서는 오류가 그대로 남는다. 두 선언 모두 본문의 검사 로직은 컴파일러가 검증하지 않으니 조건을 잘못 쓰면 런타임에서야 드러난다. 또 단언 함수는 호출하는 이름에 명시적 타입 표기가 있어야 효과가 적용되므로, 표기 없는 const 화살표 함수로 만들면 좁힘이 일어나지 않는다.'),
       (1599, 4930, '판별 유니온,discriminated union,태그된 유니온,tagged union,구별된 유니온,판별된 유니온,disjoint union', '종류마다 타입을 따로 두고 모든 멤버가 같은 이름의 리터럴 프로퍼티(여기서는 status)를 갖게 하면, 그 프로퍼티 하나를 비교하는 것만으로 유니온 전체가 한 멤버로 좁혀진다. 그래서 ok 분기에서 receiptId가 필수 string이 되어 추가 확인이 사라지고, 성공 표시에 실패 사유만 담은 값은 어느 멤버에도 맞지 않아 대입 단계에서 막힌다. 경계로 기억할 것 — 판별자를 string처럼 넓은 타입으로 선언하면 비교해도 좁혀지지 않고, 멤버마다 프로퍼티 이름이 다르면 판별자 구실을 하지 못한다. 구조 분해해서 쓸 때는 const로 받아야 좁힘이 유지된다. 이 구조가 갖춰져야 default 분기에서 never로 누락된 종류를 잡아내는 완전성 검사도 성립한다.');

-- =====================================================
-- Lesson 949: 타입 좁히기 응용: 진릿값·동등 비교·in 가드에서 구조 분해와 satisfies까지
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5873, 949, '아래 코드에서 마지막 호출이 내놓는 결과와 그 원인으로 옳은 것은?', '```typescript
type Stock = { name: string; count: number | null };

function label(item: Stock) {
  if (item.count) {
    return `${item.name} ${item.count}개 남음`;
  }
  return `${item.name} 입고 예정`;
}

label({ name: "키보드", count: 3 });    // 키보드 3개 남음
label({ name: "마우스", count: null }); // 마우스 입고 예정
label({ name: "모니터", count: 0 });    // ?
```', 'OBJECTIVE'),
       (5874, 949, '아래 코드의 (A) 지점에서 컴파일러가 보는 a와 b의 타입은?', '```typescript
function sync(a: string | number, b: number | boolean) {
  if (a === b) {
    // (A) 이 지점에서의 a와 b
  }
}
```

비교문 `a === b` 자체는 경고 없이 컴파일된다.', 'OBJECTIVE'),
       (5875, 949, '아래 코드에서 (A)와 (B) 두 줄이 모두 오류 없이 컴파일되는 이유로 옳은 것은?', '```typescript
type Payload =
  | { kind: "text"; body: string }
  | { kind: "count"; body: number };

function render(p: Payload) {
  const { kind, body } = p;

  if (kind === "text") {
    return body.trim();      // (A)
  }
  return body.toFixed(1);    // (B)
}
```', 'OBJECTIVE'),
       (5876, 949, '아래 코드의 (A)에서 Keys에 추론되는 타입은?', '```typescript
type Handlers = Record<string, (n: number) => number>;

const handlers = {
  double: (n: number) => n * 2,
  half: (n: number) => n / 2,
} satisfies Handlers;

type Keys = keyof typeof handlers; // (A)
```', 'OBJECTIVE'),
       (5877, 949, '아래 수정에서 빈칸에 들어갈 TypeScript 연산자는?', '결제 결과 타입을 아래처럼 정의해 두고 쓰다가 컴파일 오류를 만났다.

```typescript
interface Paid { paidAt: string }
interface Failed { reason: string }
type PayResult = Paid | Failed;

function report(res: PayResult) {
  if (res.reason) { // 오류: reason 속성이 PayResult 형식에 없습니다
    return res.reason;
  }
  return res.paidAt;
}
```

as 단언은 쓰지 않고 검사 부분만 아래처럼 바꾸자 오류가 사라졌고, 블록 안에서 res는 Failed로, 그 뒤 줄에서는 Paid로 다뤄졌다.

```typescript
  if ("reason" ____ res) {
    return res.reason;
  }
```', 'SUBJECTIVE'),
       (5878, 949, '아래 상황에서 반환 타입 자리에 적어 넣은 문법의 이름은?', 'API 응답을 unknown으로 받아 쓰려고 검사 헬퍼를 만들었는데, 검사를 통과한 블록 안에서도 아래처럼 오류가 났다.

```typescript
function hasStatus(e: unknown) {
  return typeof e === "object" && e !== null && "status" in e;
}

function log(e: unknown) {
  if (hasStatus(e)) {
    console.log(e.status); // 오류: e의 형식이 unknown입니다
  }
}
```

본문은 한 줄도 고치지 않고 반환 타입만 아래처럼 적어 넣자 오류가 사라졌다. 대신 그 뒤로는 본문의 검사가 선언과 맞는지 컴파일러가 확인해 주지 않아, 검사 로직을 단위 테스트로 지켜야 했다.

```typescript
function hasStatus(e: unknown): e is { status: number } {
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5873
(15835, 5873, '모니터 0개 남음을 돌려준다. 첫 분기에서 count가 number로 좁혀져 템플릿에 그대로 들어가기 때문이다.', '진릿값 검사가 null과 undefined만 걸러 낸다고 본 것이다. 0도 거짓으로 취급되므로 이 호출은 첫 분기에 들어가지조차 못한다.', false),
(15836, 5873, '모니터 입고 예정을 돌려준다. 진릿값 검사가 null뿐 아니라 0도 거짓으로 함께 걸러 내기 때문이다.', 'if (item.count)는 값이 참으로 취급되는지만 보므로 0과 빈 문자열까지 거짓 분기로 보낸다. 값이 없는 경우만 가려내려면 item.count != null로 검사해야 한다.', true),
(15837, 5873, '첫 분기에서 count가 number | null로 남아 템플릿 리터럴에 넣는 줄에서 컴파일 오류가 난다.', '진릿값 검사도 null과 undefined를 제거하는 좁히기라 첫 분기의 count는 number다. 컴파일은 통과하고 어긋나는 것은 실행 결과 쪽이다.', false),
(15838, 5873, '컴파일러가 count === 0인 경우를 다루지 않았다고 판정해 완전성 검사 오류를 낸다.', '완전성 검사는 판별 유니온에서 남은 멤버가 never인지 확인할 때 일어난다. 숫자 값 하나하나를 다뤘는지까지 컴파일러가 따지지는 않는다.', false),

-- 문제 5874
(15839, 5874, 'a: string | number, b: number | boolean', '동등 비교는 좁히기에 쓰이지 않는다고 본 것이다. ===는 두 값이 같다는 사실을 알려 주므로 컴파일러는 그 분기에서 양쪽 타입을 함께 줄인다.', false),
(15840, 5874, 'a: number, b: number | boolean', '비교의 왼쪽만 좁혀진다고 본 것이다. 두 값이 같다면 오른쪽도 같은 타입이어야 하므로 b에서도 겹치지 않는 boolean이 빠진다.', false),
(15841, 5874, 'a: string | number, b: number', '비교 대상이 된 쪽만 좁혀진다고 본 것이다. 좁히기는 어느 한쪽이 아니라 ===로 묶인 두 참조 모두에 적용된다.', false),
(15842, 5874, 'a: number, b: number', '===로 같다면 두 값의 타입도 겹치는 자리에 있어야 한다. 양쪽에 공통으로 있는 타입은 number뿐이라 a에서는 string이, b에서는 boolean이 빠진다.', true),

-- 문제 5875
(15843, 5875, 'kind와 body를 const로 함께 구조 분해했으므로, 판별자인 kind를 리터럴과 비교하면 같은 객체에서 나온 body도 짝이 맞는 타입으로 함께 좁혀진다.', 'TypeScript 4.6부터 판별 유니온을 const로 구조 분해하면 변수들 사이의 짝이 유지된다. 재대입할 수 있는 선언으로 받으면 이 연결이 끊겨 body는 string | number로 남는다.', true),
(15844, 5875, 'kind만 리터럴로 좁혀지고 body는 string | number로 남지만, 구조 분해의 원본인 p가 좁혀져 있어 두 줄이 통과한다.', '(A)와 (B)가 메서드를 부르는 대상은 p.body가 아니라 구조 분해로 받은 body 변수다. p 쪽이 좁혀지는 것만으로는 body 변수의 타입이 달라지지 않는다.', false),
(15845, 5875, '두 멤버가 모두 body를 갖고 있어, 유니온에서 공통으로 존재하는 프로퍼티는 쓰는 자리마다 알아서 좁혀지기 때문이다.', '공통 프로퍼티는 좁히기 없이 읽을 수만 있을 뿐 타입은 string | number 그대로다. 타입을 갈라 주는 것은 공통이라는 사실이 아니라 판별자 비교다.', false),
(15846, 5875, 'const로 선언한 변수는 재대입이 없어 컴파일러가 선언 시점의 실제 값 타입 하나로 고정하므로, body가 처음부터 string이나 number로 정해진다.', 'const가 값 타입을 좁혀 주는 것은 원시 값을 직접 대입할 때 이야기다. 구조 분해로 받은 body의 출발 타입은 여전히 string | number이고, 하나로 정해지는 것은 분기 안에서다.', false),

-- 문제 5876
(15847, 5876, 'string', '값 뒤에 붙인 구문이 타입 표기처럼 변수 타입을 Handlers로 바꾼다고 본 것이다. 그랬다면 키 정보가 인덱스 시그니처에 묻혀 double과 half가 사라진다.', false),
(15848, 5876, '(n: number) => number', 'keyof가 프로퍼티의 값 타입을 준다고 혼동한 것이다. keyof는 키를 모은 유니온을 만들며, 값 타입이 필요하면 (typeof handlers)[Keys]처럼 인덱스 접근을 쓴다.', false),
(15849, 5876, '"double" | "half"', 'satisfies는 Handlers를 만족하는지 검사만 하고 변수에는 값에서 추론된 타입을 그대로 남긴다. 그래서 키가 리터럴로 살아 있어 keyof가 두 키의 유니온이 된다.', true),
(15850, 5876, 'never', '검사를 통과하고 나면 추론 정보가 지워진다고 본 것이다. satisfies는 타입을 덮어쓰거나 비우지 않으며, keyof 결과가 never가 되는 것은 키가 하나도 없을 때다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1914, 5877, 'in,in 연산자,in operator,"reason" in res,reason in res', 'in은 오른쪽 객체에 그 이름의 프로퍼티가 있는지 보는 연산자이고, TypeScript는 이 검사를 유니온을 가르는 좁히기 장치로 함께 쓴다. 참 분기에서는 reason을 가진 Failed로, 거짓 분기에서는 Paid로 좁혀지므로 단언 없이 두 줄이 모두 통과한다. 수정 전 코드가 막힌 이유도 같이 기억할 것 — 유니온 값에서는 모든 멤버가 공통으로 가진 프로퍼티만 바로 읽을 수 있어, 한쪽에만 있는 reason은 좁히기 전에 접근할 수 없다. 경계도 하나 있다. 다른 멤버에 같은 이름이 선택적 프로퍼티로 들어 있으면 in 검사만으로는 멤버가 깔끔히 갈리지 않으므로, 종류를 구분하는 것이 목적이라면 kind처럼 모든 멤버가 공유하는 리터럴 판별자를 두는 편이 낫다.'),
       (1915, 5878, '타입 서술,타입 술어,type predicate,타입 프레디케이트,사용자 정의 타입 가드,user-defined type guard,타입 가드 함수,타입 가드', '반환 타입을 매개변수 is 타입 꼴로 적으면, 컴파일러는 그 함수가 true를 돌려준 분기에서 인수를 그 타입으로 다룬다. 그래서 boolean을 돌려줄 때와 달리 if 블록 안에서 e가 { status: number }로 좁혀져 e.status를 읽을 수 있다. 헬퍼 안에서 아무리 꼼꼼히 검사해도 반환 타입이 boolean이면 그 결과가 호출한 쪽으로 전해지지 않는다는 점이 핵심이다. 경계로 기억할 것 — asserts e is T로 선언하는 단언 함수는 값을 돌려주는 대신 조건이 틀리면 예외를 던지고, if로 감싸지 않아도 호출한 줄 아래부터 좁힘이 이어진다. 또 타입 서술의 본문은 컴파일러가 검증하지 않으므로, 엉뚱한 조건을 적어 두면 잘못 좁혀진 값이 그대로 통과해 런타임에서야 문제가 드러난다.');
