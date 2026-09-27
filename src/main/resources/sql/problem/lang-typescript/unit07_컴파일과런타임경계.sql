-- Unit: 컴파일과 런타임 경계 (Unit ID: 211)
-- Chapter: TypeScript (Chapter ID: 20)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (637, 211, '타입 단언 한계와 import type'),
       (795, 211, '타입 스트리핑과 런타임 검증, 타입 가드'),
       (953, 211, 'TypeScript 컴파일 결과와 실행 중 검증');

-- =====================================================
-- Lesson 637: 타입 단언 한계와 import type
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4001, 637, '아래 코드를 컴파일해 실행했을 때 콘솔에 출력되는 값은?', '```typescript
// getInput()이 런타임에 실제로 반환하는 값: 문자열 "7"
const raw: unknown = getInput();
const n = raw as number;

console.log(n + 3);
```', 'OBJECTIVE'),
       (4002, 637, '아래 표를 바탕으로 한 설명으로 옳지 않은 것은?', '같은 파일에 선언된 네 가지를 컴파일한 뒤, 결과 JavaScript에 무엇이 남았는지 정리한 표다.

| TypeScript 선언 | 컴파일된 JavaScript에 남는 것 |
|---|---|
| interface User { id: number; name: string } | 없음 |
| type Role (문자열 유니언 별칭) | 없음 |
| enum Level { Low, High } | 이름과 값을 서로 매핑하는 객체 |
| const ROLES = ["ADMIN", "USER"] as const | 문자열 두 개가 담긴 배열 |', 'OBJECTIVE'),
       (4003, 637, '아래 빌드 구성에서 장애가 발생한 이유로 옳은 것은?', '어느 팀은 배포 파이프라인에서 esbuild로만 번들을 만든다. 아래처럼 빌드는 성공해 배포까지 끝났는데, 운영 로그에는 TypeError가 쌓였다. 같은 커밋을 에디터에서 열면 문제가 된 줄에 타입 오류가 그대로 표시된다.

```
$ npx esbuild src/index.ts --bundle --outfile=dist/app.js

  dist/app.js  412.7kb

Done in 24ms
```', 'OBJECTIVE'),
       (4004, 637, '아래 두 방식을 비교한 설명으로 옳은 것은?', '같은 API 응답을 다루는 두 가지 코드다.

```typescript
// 방식 A — interface User { id: number; name: string }
const body = await res.json();
const user = body as User;

// 방식 B — const UserSchema = z.object({ ... });
//          type User = z.infer<typeof UserSchema>
const body: unknown = await res.json();
const user = UserSchema.parse(body);
```', 'OBJECTIVE'),
       (4005, 637, '아래 결과가 나타나는 원인이 되는 TypeScript 컴파일 동작을 가리키는 용어는?', 'app.ts에는 interface User와 enum Level이 나란히 선언돼 있다. 빌드해 나온 번들을 검색한 결과는 아래와 같다.

```
$ grep -c "interface User" dist/app.js
0

$ grep -c "Level" dist/app.js
6
```

같은 파일에서 v instanceof User로 분기를 나누려 하자, 컴파일러는 User가 값을 나타내지 않는다며 거부했다.', 'SUBJECTIVE'),
       (4006, 637, '아래 상황에서 첫 줄을 대체해 문제를 없앤 TypeScript 구문은?', 'esbuild는 파일 하나만 보고 변환하므로, 다른 파일에 선언된 이름이 타입인지 값인지 알지 못한다. 아래 코드에서 User는 타입 별칭이고 createUser는 함수다.

```typescript
import { User } from "./types";
import { createUser } from "./service";
```

변환된 JavaScript에는 ./types를 불러오는 코드가 그대로 남아, 그 모듈 최상위의 초기화 로그가 실행될 때마다 찍혔다. 첫 줄만 다른 형태로 고쳤더니 결과 JavaScript에서 그 줄이 통째로 사라졌고 로그도 멈췄다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4001
(10843, 4001, '10', '단언이 Number()처럼 실제 변환을 해 준다고 본 값이다. as는 컴파일러의 판단만 덮어쓸 뿐 값을 건드리지 않으므로 런타임 값은 여전히 문자열이다.', false),
(10844, 4001, '73', 'as number는 변환 과정에서 사라지고 런타임에는 문자열 7만 남는다. 한쪽이 문자열인 + 는 덧셈이 아니라 결합이라 3이 뒤에 이어 붙는다.', true),
(10845, 4001, 'NaN', '문자열과 숫자를 섞으면 무조건 NaN이 된다고 본 것이다. -, *, / 는 숫자로 바꿔 계산해 NaN이 나올 수 있지만, + 는 문자열 결합으로 동작한다.', false),
(10846, 4001, '37', '결합 순서를 뒤집어 본 것이다. n + 3에서 왼쪽 피연산자가 문자열이므로 왼쪽 값 뒤에 3이 붙는 순서가 된다.', false),

-- 문제 4002
(10847, 4002, 'enum Level은 이름과 값을 양쪽으로 이어 두므로, 실행 코드에서 Level[0]을 조회하면 이름 문자열 Low를 되돌려받는다.', '참이다. 표에서 Level만 이름과 값을 서로 잇는 객체를 남긴다. 그 객체에는 Low에서 0으로 가는 방향뿐 아니라 0에서 Low로 되돌아오는 방향도 함께 담겨 있어, 값 자리에서 Level[0]을 조회하는 코드가 그대로 동작한다.', false),
(10848, 4002, 'ROLES.includes(x)로 런타임 값 검사를 하면서 그 배열에서 타입도 함께 뽑아 쓸 수 있다.', '참이다. as const 배열은 값으로 남아 검사에 쓸 수 있고, 그 값에서 타입을 파생하면 목록과 타입이 한 원천에서 나와 어긋나지 않는다.', false),
(10849, 4002, 'interface User가 서술한 모양을 실행 중에 확인하려면 id와 name을 직접 들여다보는 검사 코드를 사람이 따로 써 넣어야 한다.', '참이다. 표에서 interface는 남는 것이 없어 실행 시점에는 대조할 자료 자체가 없다. 타입 표기는 컴파일러가 코드를 검사할 때만 쓰이므로, 값의 모양을 확인하는 일은 별도의 검사 코드가 맡아야 한다.', false),
(10850, 4002, 'Object.values(Role)를 호출하면 런타임에 문자열 목록을 얻을 수 있다.', '거짓이다. 표에서 타입 별칭은 남는 것이 없으므로 호출할 대상 자체가 없다. 목록이 필요하면 enum이나 as const 배열처럼 값이 남는 선언을 써야 한다.', true),

-- 문제 4003
(10851, 4003, 'esbuild는 타입 표기를 지우고 변환만 하므로 타입 검사가 아예 수행되지 않는다. 검사는 tsc --noEmit으로 따로 돌려야 한다.', '변환 전용 도구는 속도를 위해 타입을 지우기만 한다. 빌드 성공은 변환이 끝났다는 뜻일 뿐 타입이 맞다는 보증이 아니므로, 검사 단계를 파이프라인에 따로 둬야 한다.', true),
(10852, 4003, '에디터와 빌드가 서로 다른 tsconfig.json을 읽어, 빌드 쪽에서만 오류가 걸러진 것이다.', '설정 불일치 탓으로 돌린 오개념이다. 같은 설정 파일을 읽게 맞춰도 변환 전용 도구는 애초에 타입을 검사하는 단계를 갖고 있지 않다.', false),
(10853, 4003, 'strict 옵션이 꺼져 있어 변환 도구가 검사를 건너뛴 것이므로, strict를 켜면 빌드에서 잡힌다.', 'strict는 검사의 엄격도를 정하는 옵션이다. 검사를 수행하는 도구의 동작을 조절할 뿐, 검사 자체를 하지 않는 도구를 검사기로 바꾸지는 못한다.', false),
(10854, 4003, '컴파일된 JavaScript에 들어 있던 타입 검사 코드가 번들 최적화 과정에서 제거된 것이다.', '생성된 JS에 검사 코드가 들어간다고 본 오개념이다. 타입 검사는 변환 전 정적 단계에서 한 번 이뤄질 뿐 실행 코드에는 아무것도 남지 않는다.', false),

-- 문제 4004
(10855, 4004, '방식 A는 단언한 타입과 응답의 실제 모양이 다르면 컴파일 단계에서 오류로 잡힌다.', '단언은 컴파일러의 판단을 덮어쓰는 표기라 실제 값과 대조하지 않는다. 서버가 무엇을 보낼지는 컴파일 시점에 알 수 없다.', false),
(10856, 4004, '방식 B는 타입 선언과 검증 규칙을 따로 관리해야 해서 필드를 늘릴 때 한쪽을 빠뜨리기 쉽다.', '이중 관리는 타입 서술 함수를 손으로 쓸 때의 단점이다. B는 스키마 하나에서 타입을 파생하므로 검증 규칙과 타입이 어긋날 수 없다.', false),
(10857, 4004, '응답에 name이 빠져 오면 A는 그 값을 쓰는 지점까지 가서야 문제가 드러나고, B는 파싱 단계에서 바로 실패한다.', 'A에는 값을 확인하는 코드가 없어 모양이 어긋난 객체가 그대로 흘러간다. B는 경계에서 값을 검사하므로 실패 지점이 응답을 받는 순간으로 앞당겨진다.', true),
(10858, 4004, '방식 A도 as로 타입을 좁힌 뒤에는 user.name이 undefined가 아님이 런타임에 보장된다.', 'as는 변환 과정에서 사라져 실행 코드에 아무것도 남기지 않는다. 보장되는 것은 컴파일러가 그 뒤로 User로 취급해 준다는 사실뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1290, 4005, '타입 소거,타입소거,타입 제거,타입제거,type erasure,typeerasure,erasure,타입 이레이저', '타입 표기, interface, 타입 별칭, 제네릭, as 단언은 변환 과정에서 모두 지워져 JavaScript에 남지 않는다. 그래서 번들에서 interface User가 검색되지 않고, 값이 아닌 이름은 instanceof의 오른쪽에 둘 수 없다. 반대로 enum은 이름과 값을 매핑하는 객체를 만들어 내는 값이라 번들에 그대로 남아 6번 검색된 것이다. 최신 문법을 낮은 버전 문법으로 바꾸는 트랜스파일(다운레벨링)과는 별개의 작업이라는 점도 구분해 두자.'),
       (1291, 4006, 'import type,import type 구문,타입 전용 import,타입 전용 임포트,타입 전용 가져오기,type-only import,type only import', 'import type은 그 가져오기가 타입 전용임을 표시해, 파일 단위로 변환하는 도구도 다른 파일을 들여다보지 않고 그 줄을 통째로 지울 수 있게 한다. TypeScript 5.0의 verbatimModuleSyntax 옵션을 켜면 타입 전용 가져오기에 이 표기를 강제해, 어떤 도구로 변환하든 결과가 같아진다. 함수, 클래스, enum처럼 값을 가져오는 일반 import는 런타임에 실제로 로드되므로 타입만 필요한 줄과 구분해서 써야 한다.');

-- =====================================================
-- Lesson 795: 타입 스트리핑과 런타임 검증, 타입 가드
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4949, 795, '아래 코드를 실행했을 때 콘솔에 출력되는 내용으로 옳은 것은?', '```typescript
class Coupon {
  constructor(public code: number) {}
}
interface Ticket {
  code: number;
}

function label(v: unknown): string {
  if (v instanceof Coupon) return "COUPON";
  return "OTHER";
}

const a = new Coupon(10);
const b = { code: 10 } as Coupon;
const c: Ticket = { code: 10 };

console.log(label(a), label(b), label(c));
```', 'OBJECTIVE'),
       (4950, 795, '아래 표를 바탕으로 한 설명으로 옳지 않은 것은?', '최신 Node.js는 .ts 파일에서 타입 표기만 벗겨 내고 곧바로 실행하는 방식을 지원한다. 아래는 같은 프로젝트의 네 가지 선언을 이 방식으로 실행해 본 결과다.

| 선언 | 타입 표기만 벗겨 내는 실행기의 처리 |
|---|---|
| interface Point { x: number } 와 const p: Point = { x: 1 } | 그대로 실행됨 — 표기를 지우면 끝 |
| enum Level { Low, High } | 거부됨 — 이름과 값을 서로 잇는 객체를 새로 만들어야 함 |
| class Box { constructor(public size: number) {} } | 거부됨 — 생성자 안에 this.size = size 대입문을 새로 넣어야 함 |
| import type { Point } from "./types" | 그대로 실행됨 — 줄 전체가 사라짐 |', 'OBJECTIVE'),
       (4951, 795, '아래 코드를 실행했을 때 일어나는 일로 옳은 것은?', '응답 본문으로 {"id": 7, "count": "3"}이 도착하는 상황이다.

```typescript
import { z } from "zod";

const OrderSchema = z.object({
  id: z.number(),
  count: z.number(),
});
type Order = z.infer<typeof OrderSchema>;

const body: unknown = await res.json();
const order: Order = OrderSchema.parse(body);
console.log(order.count + 1);
```', 'OBJECTIVE'),
       (4952, 795, '아래 장애가 발생한 원인으로 옳은 것은?', '결제 서버 코드다. 타입 검사와 빌드가 모두 통과해 배포까지 끝났는데, 운영 로그에는 같은 오류가 반복해서 찍혔다.

```typescript
interface PayReq { orderId: string; amount: number }

app.post("/pay", (req, res) => {
  const body = req.body as PayReq;
  logger.info(`결제 요청 ${body.orderId} / ${body.amount.toFixed(2)}`);
  // 이후 결제 처리
});
```

```
TypeError: body.amount.toFixed is not a function
    at /app/dist/pay.js:18:41
```

오류를 일으킨 요청의 본문은 {"orderId": "A-1", "amount": "12000"}이었다.', 'OBJECTIVE'),
       (4953, 795, '아래 (B)처럼 선언한 함수를 가리키는 용어는?', '두 함수는 본문이 똑같고 반환 타입 표기만 다르다.

```typescript
interface User { id: number; name: string }
const body: unknown = await res.json();

// (A)
function checkA(v: unknown): boolean {
  return typeof v === "object" && v !== null && "name" in v;
}
if (checkA(body)) {
  console.log(body.name);
  //          ~~~~ 오류: body는 unknown 형식입니다
}

// (B) 본문은 A와 같고 반환 타입만 바꿨다
function checkB(v: unknown): v is User {
  return typeof v === "object" && v !== null && "name" in v;
}
if (checkB(body)) {
  console.log(body.name); // 오류 없이 통과
}
```', 'SUBJECTIVE'),
       (4954, 795, '아래 빈칸에 들어갈 TypeScript 표기는?', '실행 중에 순회할 목록과 타입을 한 곳에서 관리하려 한다. 처음 코드는 아래와 같았다.

```typescript
const ROLES = ["ADMIN", "USER"];
type Role = (typeof ROLES)[number];   // string 으로 추론됨
const r: Role = "GUEST";              // 오류 없이 통과
```

배열 리터럴 뒤에 두 단어를 덧붙이자 같은 줄들이 아래처럼 바뀌었다.

```typescript
const ROLES = ["ADMIN", "USER"] ____;
type Role = (typeof ROLES)[number];   // "ADMIN" | "USER"
const r: Role = "GUEST";              // 오류: GUEST 형식은 Role 형식에 할당할 수 없습니다
ROLES.includes("ADMIN");              // 배열은 실행 코드에 그대로 남아 검사에 쓸 수 있다
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4949
(13371, 4949, 'COUPON COUPON OTHER', 'as Coupon이 값을 실제 인스턴스로 만들어 준다고 본 오개념이다. 단언은 컴파일러에게 그렇게 취급하라고 말할 뿐이라 b의 뿌리는 여전히 일반 객체이고, 생성자를 따져 묻는 검사에서는 걸러진다.', false),
(13372, 4949, 'COUPON OTHER OTHER', 'instanceof는 값의 프로토타입 사슬에 Coupon의 것이 있는지만 본다. new로 만든 a만 통과하고, 단언만 붙인 b와 표기만 붙인 c는 실행 시점에 일반 객체일 뿐이라 둘 다 OTHER가 된다.', true),
(13373, 4949, 'COUPON COUPON COUPON', '모양이 같으면 실행 중에도 같은 것으로 인정된다고 본 오개념이다. 구조로 호환을 따지는 일은 컴파일러의 타입 검사에서만 일어나고, instanceof는 어떤 생성자로 만들어졌는지만 확인한다.', false),
(13374, 4949, 'OTHER OTHER OTHER', '클래스도 타입 표기처럼 지워진다고 본 오개념이다. 클래스 선언은 타입이 아니라 값이라 변환 뒤에도 JavaScript 코드로 남고, 그래서 new로 만든 a는 검사를 통과한다.', false),

-- 문제 4950
(13375, 4950, 'enum Level은 실행 코드에 값으로 남으므로, 다른 파일에서 이 이름을 가져다 쓰면 그 모듈을 실제로 불러오는 코드가 생긴다.', '참이다. 표에서 enum만 새 객체를 만들어야 한다고 적혀 있고, 객체가 생긴다는 것은 실행 코드에 값이 남는다는 뜻이다. 값을 가져오는 import는 지울 수 없어 실제 로드로 이어진다.', false),
(13376, 4950, '거부된 두 선언은 원본에 없던 실행 문장을 새로 만들어 내야 한다는 공통점이 있다.', '참이다. 한쪽은 이름과 값을 잇는 객체를, 다른 한쪽은 필드에 값을 넣는 대입문을 만들어야 한다. 표기를 지우기만 하는 처리로는 둘 다 코드가 모자라므로 거부된다.', false),
(13377, 4950, 'enum Level이 거부된 까닭은 그 문법이 오래된 표기여서이므로, 같은 값을 const enum으로 바꿔 선언하면 그대로 실행된다.', '거짓이다. 표가 밝힌 거부 사유는 문법의 낡음이 아니라 새로 만들어 내야 할 객체다. const enum은 값을 쓰는 자리마다 끼워 넣는 작업이 필요해 지우기만 하는 처리로는 역시 다룰 수 없다.', true),
(13378, 4950, 'class Box 선언 자체는 실행 코드에 남으므로, 거부된 원인은 클래스가 아니라 매개변수에 붙은 public 표기에 있다.', '참이다. 클래스는 값이라 그대로 남는다. 매개변수 앞의 public은 필드 대입문을 대신 써 주는 축약 표기라 없던 문장을 만들어 내야 하고, 표에 적힌 거부 사유도 바로 그 대입문이다.', false),

-- 문제 4951
(13379, 4951, 'parse가 count에서 검사에 실패해 예외를 던지고, 그 아래 줄은 실행되지 않는다.', 'z.object로 만든 스키마는 타입이 아니라 값이라 변환 뒤에도 남아 실행 중에 응답을 대조한다. count 자리에 숫자가 아닌 문자열이 와서 대조에 걸리고, 흐름은 그 자리에서 끊긴다.', true),
(13380, 4951, 'parse가 count를 숫자로 바꿔 통과시켜 4가 출력된다.', '검사 도구가 형 변환까지 해 준다고 본 오개념이다. 들어온 값을 숫자로 바꿔 받으려면 변환을 명시한 스키마를 따로 써야 하고, 기본 동작은 모양이 어긋나면 받아들이지 않는 쪽이다.', false),
(13381, 4951, 'count가 문자열인 채로 통과해 31이 출력된다.', '스키마도 타입 표기처럼 변환 과정에서 지워진다고 본 오개념이다. 지워지는 것은 z.infer로 파생한 Order 같은 타입 쪽이고, 스키마 자체는 값이라 실행 코드에 남아 검사를 수행한다.', false),
(13382, 4951, 'parse가 검사에 실패하면 null을 돌려주므로, 그 다음 줄에서 TypeError가 난다.', '실패를 반환값으로 알려 준다고 본 오개념이다. parse는 실패를 예외로 알리므로 다음 줄에는 닿지도 못한다. 성공 여부를 값으로 받고 싶다면 결과 객체를 돌려주는 safeParse 쪽을 쓴다.', false),

-- 문제 4952
(13383, 4952, 'JSON 본문을 읽어 주는 미들웨어가 숫자를 문자열로 담기 때문이며, 그 설정을 고치면 코드를 그대로 두고 해결된다.', '도구 설정 탓으로 돌린 오개념이다. 본문에 적힌 요청 자체가 amount를 따옴표로 감싼 문자열로 보냈다. 보내는 쪽이 무엇을 담아 보낼지는 받는 쪽 설정으로 정해 둘 수 없다.', false),
(13384, 4952, 'tsconfig에서 strict를 켰다면 as로 붙인 표기와 실제 값이 다른 것을 컴파일러가 대조해 잡아냈을 것이다.', 'strict는 검사의 엄격도를 정하는 옵션일 뿐 실행 중에 오가는 값을 보지 않는다. 서버가 어떤 본문을 받을지는 컴파일 시점에 알 수 없어 어떤 옵션으로도 정적으로 가려낼 수 없다.', false),
(13385, 4952, 'dist로 변환하는 과정에서 숫자 필드가 문자열로 바뀌었으므로, 변환 도구의 대상 버전을 올리면 해결된다.', '변환은 코드의 문법을 바꾸는 작업이라 실행 중에 오가는 값에는 손대지 않는다. 문자열이 된 것은 변환 결과가 아니라 요청으로 들어온 값 자체이며, 로그의 줄 번호도 그 값을 쓰는 지점이다.', false),
(13386, 4952, 'req.body에는 요청에서 온 값이 그대로 담기고 as PayReq는 변환 과정에서 사라져, 문자열 amount가 검사 없이 toFixed 호출까지 닿았다.', '코드 바깥에서 들어온 값은 표기를 붙인다고 그 모양이 맞춰지지 않는다. 경계에서 값을 확인하는 코드를 두지 않으면, 어긋난 값은 그것을 처음 쓰는 지점에 가서야 오류로 드러난다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1606, 4953, '타입 가드,타입가드,사용자 정의 타입 가드,사용자 정의 타입가드,커스텀 타입 가드,type guard,typeguard,user-defined type guard,타입 서술 함수,타입 서술함수,타입 판별 함수,type predicate,타입 프레디킷', '반환 타입에 v is User처럼 적으면, 그 함수가 true를 돌려준 가지 안에서 컴파일러가 v를 User로 좁혀 준다. (A)의 boolean은 참과 거짓만 알려 줄 뿐 unknown을 좁히지 못해 body.name 접근이 막힌다. 주의할 점은 함수 본문이 정말 그 모양을 확인하는지 컴파일러가 검사하지 않는다는 것이다. 위 함수는 name만 보고 id는 확인하지 않지만 컴파일러는 그대로 믿는다. 검사 항목을 빠뜨리면 좁혀진 타입이 사실과 어긋나 as 단언과 다를 바 없어진다. 값이 아니면 예외를 던져 그 뒤 코드 전체에서 타입을 보장하는 asserts v is User 형태의 단언 함수와는 쓰임이 다르고, 검증 규칙과 타입을 한 원천에서 뽑아 내는 스키마 라이브러리와도 구분해 두자.'),
       (1607, 4954, 'as const,as const 단언,as const 표기,const 단언,const단언,const assertion,const 어서션,as const assertion', '배열 리터럴은 기본적으로 string[]으로 넓게 추론돼 요소의 리터럴 값이 타입에 남지 않는다. as const를 붙이면 readonly ["ADMIN", "USER"] 튜플로 고정돼 각 요소가 리터럴 타입이 되고, (typeof ROLES)[number]로 "ADMIN" | "USER" 유니언을 뽑아낼 수 있다. 값에서 타입을 파생하므로 목록과 타입이 어긋날 일이 없다. as const 표기 자체는 변환 과정에서 사라지지만 배열은 값이라 실행 코드에 남는다. 그래서 같은 ROLES를 실행 중 검사에도 쓸 수 있다. 반대로 type Role = "ADMIN" | "USER"처럼 유니언 별칭만 선언하면 타입은 얻어도 실행 시점에 순회할 목록이 없다. x as User 같은 일반 단언이 컴파일러의 판단을 덮어쓰는 쪽이라면, as const는 추론을 리터럴로 좁히는 쪽이라는 점도 구분해 두자.');

-- =====================================================
-- Lesson 953: TypeScript 컴파일 결과와 실행 중 검증
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5897, 953, '아래 코드를 컴파일해 실행한 결과로 옳은 것은?', '```typescript
function parse<T>(raw: string): T {
  return JSON.parse(raw);
}

const price = parse<number>(''"1500"'');
console.log(price.toFixed(1));
```', 'OBJECTIVE'),
       (5898, 953, '아래 선언과 변환 결과에 대한 설명으로 옳은 것은?', '같은 파일 안에서 선언하고 사용한 코드와, tsc가 만들어 낸 JavaScript다.

```typescript
// direction.ts
const enum Dir { Up = 1, Down = 2 }
move(Dir.Up);
```

```javascript
// tsc 변환 결과 (direction.js 전체)
move(1 /* Dir.Up */);
```', 'OBJECTIVE'),
       (5899, 953, '아래 코드를 실행했을 때 콘솔에 출력되는 내용은?', '```typescript
interface User { id: number }
class Order { constructor(public id: number) {} }

const u: User = { id: 1 };
const o = new Order(2);
const list: User[] = [u];

console.log(typeof u, typeof o, typeof list);
```', 'OBJECTIVE'),
       (5900, 953, '아래 상황에 대한 설명으로 옳은 것은?', '회원 API 응답을 아래 함수로 확인한 뒤 써 왔다. 이번에 interface User에 email 필드를 추가하고, 화면 코드에 user.email.toLowerCase()를 넣어 배포했다. 그런데 email이 없는 옛 형식 응답이 들어오자 isUser는 true를 돌려줬고, 이어서 TypeError가 났다.

```typescript
interface User { id: number; name: string; email: string }

function isUser(v: unknown): v is User {
  return typeof v === "object" && v !== null &&
    typeof (v as any).id === "number" &&
    typeof (v as any).name === "string";
}
```', 'OBJECTIVE'),
       (5901, 953, '아래 빈칸에 공통으로 들어갈 타입 이름은?', 'API 응답을 담을 변수의 타입을 바꿔 가며 strict 설정으로 컴파일해 봤다. 빈칸에 어떤 타입 하나를 넣었을 때 각 줄의 결과는 아래와 같다.

```typescript
let body: ____ = await res.json();   // 통과
body = null;                          // 통과
body = 42;                            // 통과

body.name;                            // 컴파일 오류
const n: number = body;               // 컴파일 오류

if (typeof body === "string") {
  body.toUpperCase();                 // 통과
}
```

빈칸을 any로 바꾸면 위 줄이 모두 통과한다.', 'SUBJECTIVE'),
       (5902, 953, '아래 빈칸에 들어갈 tsconfig 옵션 이름은?', '같은 코드를 tsc와 swc로 각각 변환했더니 결과 JavaScript의 import 줄이 서로 달랐다. TypeScript 5.0에서 추가된 옵션 하나를 compilerOptions에서 true로 켜자, tsc가 아래 첫 줄에만 오류를 냈다.

```typescript
import { User } from "./types";          // User는 interface
import { createUser } from "./service";  // createUser는 함수
```

```
error TS1484: ''User'' is a type and must be imported using a type-only import when ''____'' is enabled.
```

첫 줄을 고친 뒤로는 어느 도구로 변환해도 결과가 같아졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5897
(15899, 5897, '1500.0이 출력된다.', '제네릭에 number를 넘기면 값이 숫자로 바뀐다고 본 오개념이다. T는 변환 과정에서 지워져 실행 중에는 아무 일도 하지 않고, JSON.parse는 따옴표로 감싼 입력을 문자열로 돌려준다.', false),
(15900, 5897, '컴파일 단계에서 인수가 number가 아니라는 오류가 난다.', '컴파일러가 문자열 인수의 내용까지 읽어 T와 대조한다고 본 오개념이다. JSON.parse의 반환 타입은 any라 어떤 T에도 대입되므로, 검사는 그대로 통과한다.', false),
(15901, 5897, '실행 중에 toFixed가 함수가 아니라는 TypeError가 난다.', 'parse<number>의 number는 컴파일 뒤 사라지고, JSON.parse가 돌려준 문자열 1500이 그대로 price에 담긴다. 문자열에는 toFixed 메서드가 없어 호출하는 순간 오류가 난다.', true),
(15902, 5897, 'NaN이 출력된다.', '숫자로 바꾸는 데 실패하면 NaN이 된다고 본 오개념이다. 이 코드 어디에도 숫자로 바꾸는 과정이 없으므로 NaN이 생길 자리가 없고, 문자열에 없는 메서드를 부르는 지점에서 멈춘다.', false),

-- 문제 5898
(15903, 5898, '다른 파일에서 Dir.Up을 가져다 쓰면, 파일 하나씩만 보고 변환하는 도구는 그 자리에 넣을 값을 알 수 없다.', '이 선언은 쓰는 자리에 값을 끼워 넣고 선언 자체는 지운다. 끼워 넣을 값이 다른 파일에 있으면 그 파일을 봐야 하므로, 파일 단위 변환 도구(isolatedModules 환경)에서 제약이 생긴다.', true),
(15904, 5898, '변환 결과에도 Dir 객체가 남아 있어 Dir[1]로 이름 Up을 조회할 수 있다.', '일반 enum의 동작을 갖다 붙인 오개념이다. 변환 결과 파일 전체에 Dir 선언이 없으므로 이름과 값을 잇는 객체도 없다. 실행 중에 조회할 대상 자체가 사라진다.', false),
(15905, 5898, 'move에 숫자 7을 넘기는 코드는 실행 중에 Dir의 값 목록과 대조되어 거부된다.', '선언이 실행 코드에 검사 로직을 남긴다고 본 오개념이다. 변환 결과에는 숫자 1만 남을 뿐 Dir의 값 목록이 없어, 실행 중에 무엇과도 대조할 수 없다.', false),
(15906, 5898, '앞의 const만 지워 일반 enum으로 바꿔도 변환 결과는 위와 같아 번들 크기에 차이가 없다.', '두 선언을 같다고 본 오개념이다. 일반 enum은 이름과 값을 서로 잇는 객체를 만드는 코드를 결과에 남기므로, 변환 결과가 달라지고 그만큼 코드도 늘어난다.', false),

-- 문제 5899
(15907, 5899, 'User Order Array', '타입 이름이 실행 중에도 남는다고 본 오개념이다. interface는 변환 뒤 사라지고, typeof는 JavaScript가 정한 몇 가지 원시 타입 문자열 중 하나만 돌려준다.', false),
(15908, 5899, 'object Order object', '클래스는 값으로 남으니 typeof가 클래스 이름을 알려 준다고 본 오개념이다. 클래스로 만든 인스턴스도 typeof로는 object일 뿐이고, 어떤 생성자로 만들었는지는 instanceof로 따진다.', false),
(15909, 5899, 'object object array', '배열에는 별도의 typeof 결과가 있다고 본 오개념이다. 배열도 객체라 typeof는 object를 돌려주며, 배열인지 가리려면 Array.isArray를 따로 써야 한다.', false),
(15910, 5899, 'object object object', 'typeof는 값만 보고 JavaScript 원시 타입 문자열을 돌려준다. 평범한 객체, 클래스 인스턴스, 배열은 모두 객체라 object가 되고, User 같은 타입 표기는 판단에 전혀 쓰이지 않는다.', true),

-- 문제 5900
(15911, 5900, 'isUser가 반환 타입에 v is User를 적었으므로, 본문이 email을 확인하지 않으면 tsc가 컴파일 오류로 알려 준다.', '반환 타입의 약속을 컴파일러가 본문과 대조한다고 본 오개념이다. 컴파일러는 이 형태의 함수 본문이 정말 그 모양을 확인하는지 검사하지 않고 그대로 믿는다.', false),
(15912, 5900, '스키마를 먼저 정의하고 거기서 User 타입을 뽑아 썼다면, email 추가가 검증에도 반영돼 응답을 받는 자리에서 걸렸을 것이다.', '타입과 검증 코드를 따로 두면 한쪽만 고치기 쉽다. 스키마(값)에서 타입을 파생하면 필드를 한 곳에서만 추가하므로 둘이 어긋날 수 없고, email 없는 응답은 파싱 단계에서 실패한다.', true),
(15913, 5900, '응답을 unknown 대신 any로 받았다면 email 누락이 컴파일 단계에서 드러났을 것이다.', 'any를 쓰면 검사가 더 느슨해진다. 어떤 타입으로 받든 서버가 보낼 값의 모양은 컴파일 시점에 알 수 없으므로 누락은 실행 중에만 드러난다.', false),
(15914, 5900, 'interface에 필드를 추가하면 변환된 JavaScript에 email 검사 코드가 생기므로 isUser를 따로 고칠 필요가 없다.', 'interface가 실행 코드를 만든다고 본 오개념이다. interface는 변환 과정에서 통째로 지워지므로, 실행 중에 값을 확인하는 일은 사람이 쓴 검사 코드만 맡는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1922, 5901, 'unknown,unknown 타입,unknown type,언노운,언노운 타입', 'unknown은 어떤 값이든 받아들이지만, 좁히기 전에는 프로퍼티 접근이나 다른 타입으로의 대입을 막는다. typeof 같은 검사로 좁힌 가지 안에서만 그 타입의 기능을 쓸 수 있어, 외부에서 들어온 값을 검증 없이 쓰는 실수를 컴파일 단계에서 막아 준다. any는 모든 검사를 꺼 버려 모든 줄이 통과하고, {}나 object는 null이나 42 대입에서 이미 걸린다는 점으로 구분된다. 모든 대입을 거부하는 never와도 반대 방향이다.'),
       (1923, 5902, 'verbatimModuleSyntax,verbatim module syntax,verbatimModuleSyntax 옵션', 'verbatimModuleSyntax를 켜면 import 줄은 type 표시가 있으면 지우고, 없으면 적힌 그대로 남긴다. 그래서 다른 파일을 보지 못하는 swc·esbuild도 tsc와 같은 결과를 낸다. 대신 타입만 가져오는 줄에는 import type을 반드시 써야 해서 첫 줄이 오류가 됐다. 이 옵션은 그 규칙을 강제하는 설정이고, import type은 그 규칙에 맞춰 쓰는 구문이라는 점을 구분하자. 파일 단위 변환을 전제로 한 isolatedModules와도 다른 옵션이다.');
