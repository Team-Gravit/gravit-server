-- Unit: 인터페이스와 타입 별칭 (Unit ID: 209)
-- Chapter: TypeScript (Chapter ID: 20)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (635, 209, '선언 병합과 암묵적 인덱스 시그니처'),
       (793, 209, '선택 기준과 교차 타입 성능, 전역 확장'),
       (951, 209, '인터페이스와 타입 별칭이 갈라지는 지점');

-- =====================================================
-- Lesson 635: 선언 병합과 암묵적 인덱스 시그니처
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3989, 635, '아래 TypeScript 코드에 대한 설명으로 옳은 것은?', '```typescript
interface Animal { name: string }

interface Dog extends Animal { bark(): void }

type Cat = Animal & { meow(): void };

interface Puppy extends Dog, Cat {}
```', 'OBJECTIVE'),
       (3990, 635, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 표현·기능 | interface | type |
|---|---|---|
| 객체 모양 선언 | O | O |
| 유니온·튜플·원시 타입에 이름 붙이기 | X | O |
| 매핑·조건부·템플릿 리터럴 타입 | X | O |
| 같은 이름으로 다시 선언했을 때 선언 병합 | O | X |
| 클래스 implements 대상 | O | O (객체 타입일 때) |', 'OBJECTIVE'),
       (3991, 635, '아래 상황에서 오류를 없애는 방법으로 옳은 것은?', 'Express 애플리케이션의 인증 미들웨어가 요청 객체에 `req.user`를 채워 넣는다. 그런데 라우터 핸들러에서 `req.user.id`를 읽으면 "Request 형식에 user 속성이 없습니다" 오류가 난다.

- `Request` 타입은 `express-serve-static-core` 모듈이 내보낸 것이다.
- 프로젝트 코드는 모두 `import`/`export`를 쓰는 ES 모듈로 작성돼 있다.', 'OBJECTIVE'),
       (3992, 635, '아래 코드를 컴파일한 결과로 옳은 것은?', '```typescript
interface Point { x: number; y: number }

type PointT = { x: number; y: number };

function log(obj: Record<string, unknown>) {
  console.log(Object.keys(obj).length);
}

declare const p: Point;
declare const pt: PointT;

log(pt);
log(p);
```', 'OBJECTIVE'),
       (3993, 635, '아래 코드의 마지막 줄이 오류 없이 통과하는 근거가 되는 TypeScript의 성질을 가리키는 용어는?', '```typescript
interface UserI { id: number; name: string }

type UserT = { id: number; name: string };

const a: UserI = { id: 1, name: "김철수" };

const b: UserT = a;
```

두 선언 사이에 `extends`도 `implements`도 쓰지 않았고, 변환 함수나 단언도 없다.', 'SUBJECTIVE'),
       (3994, 635, '아래 오류 메시지의 X 자리에 들어갈 타입 이름은?', '```typescript
interface Base { value: string }

type Mixed = Base & { value: number };

const m: Mixed = { value: 1 };
```

`Mixed`를 선언한 줄에서는 아무 오류도 나지 않는다. 마지막 줄에서야 "number 형식은 X 형식에 할당할 수 없습니다"라는 오류가 난다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3989
(10811, 3989, '인터페이스는 한 번에 한 타입만 확장할 수 있어 Puppy 선언에서 오류가 난다.', '클래스의 단일 상속 규칙을 인터페이스에 옮겨 붙인 오개념이다. 인터페이스는 쉼표로 여러 타입을 한꺼번에 확장할 수 있다.', false),
(10812, 3989, '인터페이스는 타입 별칭으로 만든 객체 타입도 확장할 수 있어 Puppy 선언이 통과한다.', '확장의 대상이 되는 것은 선언 문법이 아니라 객체 모양이다. Cat은 교차 타입이지만 프로퍼티가 확정된 객체 모양이라 인터페이스가 그대로 확장할 수 있다.', true),
(10813, 3989, '교차 타입으로 만든 Cat은 클래스가 implements 대상으로 쓸 수 없다.', 'implements가 막히는 것은 유니온 타입일 때다. Cat은 name과 meow가 모두 있는 객체 모양이라 클래스가 구현할 수 있다.', false),
(10814, 3989, 'Cat 선언은 오류다. 인터페이스는 교차 타입의 피연산자가 될 수 없기 때문이다.', '두 문법은 자유롭게 섞인다. 인터페이스를 &로 결합하는 것도, 타입 별칭을 extends하는 것도 모두 허용된다.', false),

-- 문제 3990
(10815, 3990, '요청 id를 문자열 또는 숫자 중 하나로 받는 타입에 이름을 붙이려면 타입 별칭을 써야 한다.', '유니온 행에서 따라 나온다. 인터페이스는 객체 모양만 선언하므로 두 타입 중 하나를 뜻하는 타입에는 이름을 줄 수 없다.', false),
(10816, 3990, '인터페이스로 공개한 타입은 다른 파일에서 프로퍼티가 늘 수 있으니, 닫힌 타입이 필요하면 타입 별칭이 안전하다.', '선언 병합 행에서 따라 나온다. 병합이 되는 쪽은 외부가 필드를 보탤 수 있고, 병합이 안 되는 타입 별칭은 그 통로가 막혀 있다.', false),
(10817, 3990, 'on으로 시작하는 이벤트 이름만 허용하는 문자열 패턴 타입에도 인터페이스로 이름을 붙일 수 있다.', '템플릿 리터럴 행에 정면으로 걸린다. 인터페이스는 객체 모양 전용이라 문자열 패턴 같은 원시 타입에는 이름을 줄 수 없고 타입 별칭을 써야 한다.', true),
(10818, 3990, '클래스가 구현할 객체 모양은 인터페이스로 선언하든 타입 별칭으로 선언하든 implements할 수 있다.', 'implements 행에서 따라 나온다. 객체 모양이기만 하면 어느 문법으로 선언했는지는 클래스 구현에 영향을 주지 않는다.', false),

-- 문제 3991
(10819, 3991, '프로젝트 안에 같은 이름의 타입 별칭 Request를 선언하고 user 필드를 추가한다.', '타입 별칭은 같은 이름을 다시 선언하면 식별자 중복 오류가 난다. 이름이 같아도 기존 타입에 합쳐지지 않는다.', false),
(10820, 3991, 'declare global 블록 안에 Request 인터페이스를 선언하고 user 필드를 추가한다.', '병합은 같은 스코프 안에서만 일어난다. 전역의 Request는 요청 API 쪽 타입이라, 모듈이 내보낸 Request와는 합쳐지지 않는다.', false),
(10821, 3991, 'node_modules에 설치된 타입 선언 파일을 열어 Request에 user 필드를 직접 적어 넣는다.', '재설치나 버전 업이면 수정이 사라지고 다른 팀원 환경에도 반영되지 않는다. 라이브러리 타입 확장은 프로젝트 코드 쪽에서 해야 한다.', false),
(10822, 3991, 'declare module "express-serve-static-core" 블록 안에 Request 인터페이스를 선언하고 user 필드를 추가한다.', '같은 이름의 인터페이스는 같은 스코프에서 하나로 합쳐진다. 모듈 이름을 지정해 그 스코프 안에서 선언하면 라이브러리의 Request에 필드가 더해진다.', true),

-- 문제 3992
(10823, 3992, 'log(pt)는 통과하고 log(p)는 오류다. 인터페이스는 나중에 병합될 수 있어 모든 키가 unknown이라고 단정되지 않는다.', '타입 별칭은 닫혀 있어 암시적 인덱스 시그니처를 인정받는다. 반면 인터페이스는 다른 파일에서 프로퍼티가 늘 수 있어 컴파일러가 키 전체를 unknown으로 보지 못한다.', true),
(10824, 3992, 'log(p)는 통과하고 log(pt)는 오류다. 타입 별칭에는 인덱스 시그니처가 적혀 있지 않기 때문이다.', '방향이 반대다. 인덱스 시그니처를 직접 적지 않아도 객체 타입 별칭은 암시적 인덱스 시그니처를 얻어 Record에 넘어간다.', false),
(10825, 3992, '두 호출 모두 통과한다. 두 타입의 프로퍼티 구성이 같아 완전히 같은 타입으로 취급되기 때문이다.', '프로퍼티가 같아도 Record 대입 가능 여부는 갈린다. 차이는 프로퍼티 구성이 아니라 선언이 나중에 열려 있는지에서 온다.', false),
(10826, 3992, '두 호출 모두 오류다. 인덱스 시그니처를 직접 적어 둔 타입만 Record에 넘길 수 있기 때문이다.', '객체 타입 별칭은 인덱스 시그니처를 적지 않아도 Record 매개변수에 넘어간다. 따라서 log(pt)에서는 오류가 나지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1286, 3993, '구조적 타이핑,구조적타이핑,구조적 타입 시스템,structural typing,structural type system,덕 타이핑,duck typing', 'TypeScript는 타입의 이름이나 선언해 둔 상속 관계가 아니라 프로퍼티 구성이 맞는지로 대입 가능 여부를 정한다. UserI와 UserT는 id·name의 타입이 같으므로, 둘 사이에 아무 관계를 선언하지 않아도 서로 넣을 수 있다. 이름이 같아야 호환되는 명목적 타이핑(nominal typing)과 반대이며, 같은 이름의 선언이 하나로 합쳐지는 선언 병합과도 다른 개념이다.'),
       (1287, 3994, 'never,never 타입,never type', '교차 타입은 두 타입을 동시에 만족하는 값만 허용한다. string이면서 number인 값은 존재하지 않으므로 value의 타입은 어떤 값도 가질 수 없는 never로 줄어들고, 1을 넣는 순간 대입이 막힌다. 인터페이스 extends로 같은 충돌을 만들었다면 확장을 선언하는 줄에서 곧바로 호환 오류가 났을 것이다. 교차 타입은 선언을 통과시키고 사용 시점에야 문제를 드러내므로, 정체불명의 never가 보이면 프로퍼티 충돌을 먼저 의심한다. 값이 하나도 없다는 뜻의 never를, 반환값이 없다는 뜻의 void와 혼동하지 않도록 주의한다.');

-- =====================================================
-- Lesson 793: 선택 기준과 교차 타입 성능, 전역 확장
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4937, 793, '아래 네 선언 가운데 인터페이스 선언으로 그대로 옮겨 쓸 수 있는 것을 바르게 고른 것은?', '```typescript
type Level = "info" | "warn" | "error";

type Range = [number, number];

type Reducer = (acc: number, cur: number) => number;

type Flags = { [K in Level]: boolean };
```', 'OBJECTIVE'),
       (4938, 793, '아래 코드에서 컴파일 오류가 보고되는 위치로 옳은 것은?', '```typescript
interface Res { status: number }

interface ResA extends Res {
  status: boolean;                        // (A)
}

type ResB = Res & { status: boolean };    // (B)

const r: ResB = { status: true };         // (C)
```', 'OBJECTIVE'),
       (4939, 793, '아래 상황에서 타입 검사 속도를 되돌리기 위한 조치로 옳은 것은?', '사내 공통 타입 패키지를 점검하다 아래 두 가지를 확인했다.

- 화면 Props 타입이 `type Props = Base & Layout & Theme & Tracking & ...` 꼴로 열 단계 넘게 쌓여 있다.
- 조각 하나를 고칠 때마다 편집기의 타입 검사 응답이 수 초씩 밀리고, 오류 메시지에는 타입 이름 대신 프로퍼티가 모두 펼쳐진 긴 구조가 찍힌다.', 'OBJECTIVE'),
       (4940, 793, '아래 요구를 모두 만족하는 타입 선언 방식으로 옳은 것은?', '사내 공용 패키지가 API 응답 타입 하나를 이름 붙여 내보내려 한다. 요구는 두 가지다.

- 응답 값은 `{ ok: true; data: string }` 또는 `{ ok: false; code: number }` 둘 중 하나이며, 두 모양을 하나의 이름으로 묶어 내보내야 한다.
- 패키지를 쓰는 앱이 같은 이름으로 선언을 하나 더 적어 프로퍼티를 몰래 보태는 일은 막아야 한다.', 'OBJECTIVE'),
       (4941, 793, '아래 선언이 브라우저 전역 Window 타입과 하나로 합쳐지게 하려면 선언을 감싸야 하는 블록은?', '```typescript
// app.ts — import와 export가 있어 ES 모듈로 다뤄지는 파일이다
import { render } from "./render";

interface Window {
  appVersion: string;
}

window.appVersion = "1.0.0";
// 오류: Window 형식에 appVersion 속성이 없습니다.

export { render };
```

같은 내용을 import도 export도 없는 전역 스크립트 파일에 적었을 때는 오류가 나지 않았다.', 'SUBJECTIVE'),
       (4942, 793, '아래 오류와 빌드 산출물이 함께 드러내는 TypeScript의 성질을 가리키는 용어는?', '```typescript
// user.ts
interface User { id: number; role: string }

type Admin = { id: number; role: string; grant(): void };

export function check(x: unknown): boolean {
  return typeof x === "object" && x !== null && "role" in x;
}
```

빌드 산출물 user.js는 아래가 전부다.

```javascript
export function check(x) {
  return typeof x === "object" && x !== null && "role" in x;
}
```

check의 본문을 x instanceof User로 줄여 쓰려 하면 "User은(는) 형식만 참조하며 여기서는 값으로 사용되고 있습니다" 오류가 난다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4937
(13339, 4937, 'Reducer 하나만 옮길 수 있다.', '함수 타입은 호출 시그니처를 가진 객체 모양이라 interface Reducer { (acc: number, cur: number): number } 로 같은 뜻을 적을 수 있다. 나머지 셋은 객체 모양이 아니라 인터페이스가 이름을 줄 대상이 못 된다.', true),
(13340, 4937, 'Range와 Reducer 두 개를 옮길 수 있다.', '튜플을 배열 모양의 객체로 본 오개념이다. 인터페이스로 Array를 확장해도 원소가 number 두 개로 고정된다는 조건은 표현할 수 없다.', false),
(13341, 4937, 'Reducer와 Flags 두 개를 옮길 수 있다.', '매핑 타입을 인덱스 시그니처로 대신할 수 있다고 본 오개념이다. 인덱스 시그니처는 키를 Level 세 가지로 한정하지 못하므로 같은 타입이 되지 않는다.', false),
(13342, 4937, 'Level과 Reducer 두 개를 옮길 수 있다.', '유니온을 인터페이스 여러 개로 나눠 선언하면 된다고 본 오개념이다. 인터페이스를 여러 개 만들어도 셋 중 하나를 뜻하는 타입 자체에는 이름을 줄 수 없다.', false),

-- 문제 4938
(13343, 4938, '(A)에서만 보고된다.', '교차 타입이 나중에 적은 타입으로 프로퍼티를 덮어쓴다고 본 오개념이다. 교차는 덮어쓰기가 아니라 두 타입을 동시에 만족하라는 요구여서 (C)의 대입도 막힌다.', false),
(13344, 4938, '(A)와 (C)에서 보고된다.', '인터페이스 확장은 확장을 적은 줄에서 곧바로 호환성을 검사하므로 (A)가 막힌다. 교차 타입은 선언을 통과시키고, status가 어떤 값도 될 수 없는 타입으로 좁혀져 값을 넣는 (C)에서야 드러난다.', true),
(13345, 4938, '(B)와 (C)에서 보고된다.', '인터페이스 확장이 나중 선언을 우선해 (A)를 통과시킨다고 본 오개념이다. 확장은 덮어쓰기가 아니라 호환 검사이며, 교차 타입을 적은 (B) 자체는 오류가 아니다.', false),
(13346, 4938, '(C)에서만 보고된다.', '두 확장 방식 모두 선언 시점에는 충돌을 검사하지 않는다고 본 오개념이다. 인터페이스 확장은 충돌을 선언 시점에 잡는 쪽이라 (A)에서 이미 오류가 난다.', false),

-- 문제 4939
(13347, 4939, '합성에 쓰인 조각 타입만 인터페이스로 바꾸고 결합은 그대로 둔다.', '조각을 인터페이스로 선언해도 결합 결과는 이름 없는 타입이라 참조할 때마다 다시 계산된다. 검사 결과가 이름으로 캐시되는 쪽은 extends로 만든 확장 결과다.', false),
(13348, 4939, '패키지의 인터페이스 선언을 모두 타입 별칭으로 바꿔 선언 병합 가능성을 없앤다.', '병합될 수 있다는 점은 검사 비용의 원인이 아니다. 오히려 확장 결과를 캐시해 두는 쪽을 버리는 조치라 합성이 깊을수록 불리해진다.', false),
(13349, 4939, '겹치는 프로퍼티를 모두 선택적 프로퍼티로 바꿔 조각 사이 충돌을 없앤다.', '교차 타입은 프로퍼티가 겹쳐도 그 자리에서 멈추지 않으므로 충돌은 애초에 검사를 늦추는 원인이 아니다. 물음표를 붙여도 쌓인 합성 단계는 그대로 남는다.', false),
(13350, 4939, '깊게 쌓인 교차 합성을 인터페이스 extends 계층으로 바꾼다.', '인터페이스 확장은 결과가 이름 있는 타입으로 캐시돼 같은 타입을 다시 참조할 때 계산을 되풀이하지 않는다. 오류 메시지도 펼쳐진 구조 대신 이름으로 짧게 표시된다.', true),

-- 문제 4940
(13351, 4940, '성공 모양과 실패 모양을 인터페이스로 각각 선언하고, 둘을 함께 확장한 인터페이스를 내보낸다.', '여러 타입을 한꺼번에 확장하면 둘 중 하나가 아니라 둘을 동시에 만족하는 모양이 된다. ok가 true이면서 false여야 해 어떤 값도 만들 수 없다.', false),
(13352, 4940, '성공 모양과 실패 모양을 인터페이스로 선언하고, 둘을 교차로 결합한 타입 별칭을 내보낸다.', '교차 결합도 두 모양을 동시에 요구하므로 둘 중 하나라는 요구를 담지 못한다. 두 갈래를 묶는 것은 교차가 아니라 유니온이다.', false),
(13353, 4940, '성공 모양과 실패 모양을 유니온으로 묶은 타입 별칭 하나를 선언해 내보낸다.', '둘 중 하나를 뜻하는 타입에는 타입 별칭만 이름을 줄 수 있다. 게다가 같은 이름의 타입 별칭을 다시 선언하면 식별자 중복 오류라, 밖에서 프로퍼티를 보탤 통로도 막힌다.', true),
(13354, 4940, '하나의 인터페이스에 data와 code를 모두 선택적 프로퍼티로 넣어 내보낸다.', '물음표를 붙이면 둘 다 없는 값이나 둘 다 있는 값까지 허용돼 갈래가 갈리지 않는다. 인터페이스라 다른 파일에서 선언을 보태 프로퍼티를 늘릴 수도 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1602, 4941, 'declare global,declare global {},declare global{},declare global 블록,global', '선언 병합은 같은 스코프 안에서만 일어난다. import나 export가 있는 파일은 모듈 스코프이므로, 거기 적은 Window는 브라우저가 미리 선언해 둔 Window와 별개인 새 타입이 되고 window 값의 타입은 그대로다. declare global 블록으로 감싸면 그 안의 선언이 전역 스코프에 놓여 기존 Window와 하나로 합쳐진다. 전역이 아니라 특정 패키지가 내보낸 타입을 넓힐 때는 declare module "패키지명" 블록을 쓴다는 점에서 대상이 다르다. 또 이 방법은 인터페이스에서만 가능하다. 타입 별칭은 같은 이름을 다시 선언하는 순간 식별자 중복 오류라 합쳐질 기회가 없다.'),
       (1603, 4942, '타입 소거,타입소거,type erasure,typeerasure,erasure,타입 지우기,타입 삭제', '인터페이스든 타입 별칭이든 타입 선언은 컴파일러가 검사에만 쓰고 JavaScript 출력에는 한 줄도 남기지 않는다. 그래서 User와 Admin은 값이 아니라 형식일 뿐이고, 값이 와야 하는 instanceof 오른쪽에 놓을 수 없다. 런타임에 모양을 가려내야 한다면 in 연산자나 kind 같은 판별 프로퍼티로 좁히거나, 값으로도 남는 class를 써야 한다. 컴파일 시점에 프로퍼티 구성만 보고 대입 가능 여부를 정하는 구조적 타이핑과 혼동하기 쉬운데, 구조적 타이핑은 검사하는 방식을 뜻하고 타입 소거는 검사가 끝난 뒤 타입 정보가 결과물에 남지 않는다는 뜻이다.');

-- =====================================================
-- Lesson 951: 인터페이스와 타입 별칭이 갈라지는 지점
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5885, 951, '아래 세 선언을 같은 파일에 적었을 때의 컴파일 결과로 옳은 것은?', '```typescript
interface Session {
  id: string;
  expiresAt: number;
}

interface Session {
  id: string;
  user: { name: string };
}

interface Session {
  expiresAt: Date;
}
```', 'OBJECTIVE'),
       (5886, 951, '아래 컴파일 오류를 고치는 방법으로 옳은 것은?', '```typescript
// types.ts
export type LogLevel = "debug" | "info" | "error";

// logger.ts
import { LogLevel } from "./types";

interface Logger extends LogLevel {
  write(message: string): void;
}
```

logger.ts의 `extends LogLevel` 자리에서 아래 오류가 난다.

```
오류: 인터페이스는 정적으로 알려진 멤버가 있는 개체 형식 또는 개체 형식의 교집합만 확장할 수 있습니다.
```', 'OBJECTIVE'),
       (5887, 951, '아래 두 클래스 선언에 대한 설명으로 옳은 것은?', '```typescript
type Serializable = { toJSON(): string };

type ApiResult = { ok: true; data: string } | { ok: false; code: number };

interface Timestamped { at: number }

class Job implements Serializable, Timestamped {
  at = Date.now();
  toJSON() { return "{}"; }
}

class Success implements ApiResult {
  ok = true as const;
  data = "";
}
```', 'OBJECTIVE'),
       (5888, 951, '아래 리뷰 의견에 대한 판단으로 옳은 것은?', '댓글 API 응답 타입을 정하는 중이다.

- 댓글 하나는 `id`, `text`, 그리고 답글 목록 `replies`를 가진다.
- `replies`의 원소도 똑같은 댓글이므로, 선언 안에서 자기 자신의 이름을 다시 써야 한다.
- 작성자는 `type Comment = { id: number; text: string; replies: Comment[] };`로 적었다.
- 리뷰어는 "자기 자신을 참조하는 타입은 인터페이스로만 선언할 수 있으니 interface로 바꾸라"는 의견을 남겼다.', 'OBJECTIVE'),
       (5889, 951, '아래에서 합쳐진 show가 인자 한 개짜리 호출과 두 개짜리 호출을 모두 받아들이게 된 구조를 부르는 용어는?', '```typescript
// vendor.d.ts (전역 스크립트)
interface Toast {
  show(message: string): void;
}

// app.d.ts (전역 스크립트)
interface Toast {
  show(message: string, durationMs: number): void;
}

declare const toast: Toast;

toast.show("저장되었습니다");           // 통과
toast.show("저장되었습니다", 3000);     // 통과
toast.show(3000);                       // 오류
```

두 선언은 같은 전역 스코프에 있어 선언 병합으로 하나의 `Toast`가 되었다. 프로퍼티였다면 타입이 어긋날 때 오류가 났겠지만, `show`는 그러지 않고 위 세 줄과 같은 결과를 낸다.', 'SUBJECTIVE'),
       (5890, 951, '아래 Touched를 선언할 때 쓴 타입 문법의 이름은?', '```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

type Touched = { [K in keyof User]: boolean };

const t: Touched = { id: false, name: true, email: false };
```

`User`에 `phone`을 추가하면 위 객체에서 `phone`이 빠졌다는 오류가 새로 난다. 같은 중괄호 안의 내용을 `interface Touched { ... }`로 옮겨 적으면 "매핑된 형식은 속성이나 메서드를 선언할 수 없습니다" 오류가 난다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5885
(15867, 5885, '세 선언이 하나로 합쳐지고, expiresAt은 마지막에 적은 Date 타입이 된다.', '나중 선언이 앞선 선언을 덮어쓴다고 본 오개념이다. 병합은 덮어쓰기가 아니라 프로퍼티를 모으는 일이고, 같은 이름은 타입까지 같아야 통과한다.', false),
(15868, 5885, 'id는 타입이 같아 그대로 합쳐지지만, expiresAt은 number와 Date로 엇갈려 세 번째 선언에서 오류가 난다.', '병합은 프로퍼티를 합집합으로 모으되 같은 이름에는 동일한 타입을 요구한다. 두 번 적힌 id는 둘 다 string이라 통과하고, 뒤에 적은 expiresAt이 앞선 선언과 호환되지 않아 그 자리에서 걸린다.', true),
(15869, 5885, '같은 이름의 인터페이스를 두 번째로 선언한 시점에서 식별자 중복 오류가 난다.', '같은 이름을 다시 선언할 때 중복 오류가 나는 쪽은 타입 별칭이다. 인터페이스는 같은 스코프에 여러 번 적는 것이 허용되며 하나로 다뤄진다.', false),
(15870, 5885, 'id가 두 선언에 모두 있으므로 두 번째 선언의 id에서 프로퍼티 중복 오류가 난다.', '이름이 겹치는 것 자체를 막는다고 본 오개념이다. 타입이 동일하기만 하면 여러 선언에 겹쳐 적어도 되고, 타입이 어긋날 때만 오류가 된다.', false),

-- 문제 5886
(15871, 5886, 'types.ts의 export type LogLevel을 export interface LogLevel로 바꾼다.', '세 문자열 중 하나라는 타입은 객체 모양이 아니라 인터페이스로 선언할 수 없다. 바꾸는 순간 types.ts 쪽에서 새 문법 오류가 난다.', false),
(15872, 5886, 'Logger를 type Logger = LogLevel & { write(message: string): void }로 바꾼다.', '교차로 바꿔도 문자열이면서 동시에 write를 가진 값을 요구하게 되어 쓸 수 있는 값이 없다. 문제는 확장 문법이 아니라 확장 대상 쪽에 있다.', false),
(15873, 5886, 'LogLevel 선언을 logger.ts 안에 그대로 복사해 적고 import 문을 지운다.', 'import로 가져온 타입이라서 막힌 것이 아니다. 같은 파일에 적어도 갈래가 여럿인 타입이라는 점은 그대로라 같은 오류가 되풀이된다.', false),
(15874, 5886, 'extends LogLevel을 지우고 인터페이스 본문에 level: LogLevel 프로퍼티를 넣는다.', '확장은 물려받을 객체 모양을 지정하는 문법이라 갈래가 여럿인 타입은 대상이 못 된다. 등급 값은 물려받을 모양이 아니라 로거가 가지는 프로퍼티로 두는 것이 맞다.', true),

-- 문제 5887
(15875, 5887, 'Job 선언은 통과하고 Success 선언은 오류다. 갈래가 둘로 나뉜 타입은 구현할 모양이 하나로 정해지지 않는다.', '클래스가 implements로 받을 수 있는 것은 멤버가 확정된 객체 모양이다. Serializable은 타입 별칭이지만 객체 모양이라 문제없고, 두 모양 중 하나를 뜻하는 ApiResult는 구현 대상이 못 된다.', true),
(15876, 5887, 'Job 선언이 오류다. 클래스는 인터페이스만 implements할 수 있고 타입 별칭은 대상이 될 수 없다.', 'implements 대상인지는 선언 문법이 아니라 객체 모양인지로 갈린다. 객체 타입에 이름을 붙인 별칭은 인터페이스와 똑같이 구현 대상이 된다.', false),
(15877, 5887, 'Success 선언은 통과한다. ok가 true인 쪽 모양을 다 갖췄으므로 두 갈래 중 하나를 구현한 것으로 인정된다.', '한 갈래만 만족하면 된다고 본 오개념이다. implements는 적어 둔 타입 전체를 구현하라는 요구이고, 갈래가 나뉜 타입은 애초에 구현 목록에 올릴 수 없다.', false),
(15878, 5887, '두 선언 모두 오류다. implements 뒤에는 타입을 하나만 적을 수 있기 때문이다.', '클래스의 단일 상속 규칙을 implements에 옮겨 붙인 오개념이다. extends와 달리 implements는 쉼표로 여러 타입을 한꺼번에 적을 수 있다.', false),

-- 문제 5888
(15879, 5888, '옳다. 타입 별칭은 선언을 곧바로 펼쳐 계산하므로 자기 이름이 들어가면 끝없이 펼쳐져 막힌다.', '별칭이 항상 즉시 펼쳐진다고 본 오개념이다. 프로퍼티 자리의 자기 참조는 필요한 순간에 풀어 보므로 끝없이 펼쳐지지 않는다.', false),
(15880, 5888, '옳다. 자기 참조는 extends로 이름이 고정되는 인터페이스에서만 되고, 교차로 확장하는 타입 별칭은 쓸 수 없다.', '확장 문법과 자기 참조를 한 덩어리로 본 오개념이다. 재귀 여부는 extends를 썼는지가 아니라 선언 안에서 자기 이름을 쓸 수 있는지의 문제다.', false),
(15881, 5888, '옳지 않다. 객체 모양을 담은 타입 별칭도 자기 이름을 참조할 수 있어 두 문법 모두 이 댓글 타입을 선언할 수 있다.', '재귀는 두 문법이 갈리는 지점이 아니다. 인터페이스로 바꾸자고 하려면 선언 병합 통로나 확장 계층처럼 실제로 갈리는 다른 근거를 들어야 한다.', true),
(15882, 5888, '옳지 않다. 자기 참조는 어느 쪽으로도 막히므로 답글용 타입을 따로 선언하고 replies를 그 배열로 두어야 한다.', '따로 선언해도 그 타입이 다시 답글을 가지면 같은 문제가 되풀이된다. 트리 모양 데이터는 자기 참조 없이 표현할 수 없고, 실제로 두 문법 모두 이를 허용한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1918, 5889, '오버로드,오버로딩,overload,overloading,메서드 오버로드,함수 오버로드,method overload,function overload,오버로드 시그니처,overload signature', '인터페이스 병합은 같은 이름의 프로퍼티에는 타입이 같을 것을 요구하지만, 메서드는 형태가 달라도 지우지 않고 나란히 쌓아 둔다. 그래서 show는 인자 한 개짜리와 두 개짜리 두 시그니처를 함께 갖고, 호출할 때마다 맞는 시그니처가 골라진다. 어느 쪽에도 맞지 않는 show(3000)만 거부되는 것이 그 증거다. 나중에 선언된 쪽이 목록 앞에 놓여 먼저 매칭된다는 점도 함께 기억해 두면 좋다. 여러 선언을 한 이름으로 모으는 일 자체는 선언 병합이고, 그 결과로 한 이름에 여러 호출 형태가 쌓인 것이 오버로드다. 두 타입을 동시에 만족시키려는 교차 타입과도 다르다. 교차는 프로퍼티가 충돌하면 never로 좁혀 값을 못 넣게 만들지만, 오버로드는 형태를 나란히 남겨 둘 다 쓸 수 있게 한다.'),
       (1919, 5890, '매핑 타입,매핑타입,맵드 타입,맵드타입,mapped type,mappedtype,mapped types,매핑된 타입,매핑된 형식', '기존 타입의 키를 keyof로 훑어 키마다 새 타입을 지정하는 문법이 매핑 타입이다. Touched는 User의 키 목록을 그대로 따라가므로 User에 phone이 늘면 Touched에도 phone이 따라 늘고, 그래서 기존 객체 리터럴이 곧바로 오류가 된다. 이 문법은 타입 별칭에서만 쓸 수 있다. 인터페이스는 객체의 모양을 직접 적는 선언이라 키를 계산해 만들어 내는 문법을 본문에 둘 수 없고, 옮겨 적으면 매핑된 형식은 속성이나 메서드를 선언할 수 없다는 오류가 난다. 인덱스 시그니처와 헷갈리기 쉬운데, 인덱스 시그니처는 string처럼 키를 넓게 열어 두는 것이고 매핑 타입은 원본 타입의 키만 정확히 따라간다는 점이 다르다. Partial이나 Readonly 같은 유틸리티 타입도 모두 매핑 타입으로 만들어져 있다.');
