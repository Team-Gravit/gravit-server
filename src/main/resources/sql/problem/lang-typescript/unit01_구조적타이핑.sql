-- Unit: 구조적 타이핑 (Unit ID: 205)
-- Chapter: TypeScript (Chapter ID: 20)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (631, 205, '구조적 호환과 반공변성, 브랜드 타입'),
       (789, 205, '신선도와 약한 타입 감지, 명목적 타이핑'),
       (947, 205, 'TypeScript 구조적 타이핑과 제네릭·함수·클래스 호환 규칙');

-- =====================================================
-- Lesson 631: 구조적 호환과 반공변성, 브랜드 타입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3965, 631, '아래 코드에서 컴파일 오류가 발생하는 줄은?', '```typescript
interface Named { name: string }
interface Person { name: string; age: number }
interface Employee { name: string; age: number; company: string }

declare const named: Named;
declare const person: Person;
declare const employee: Employee;

const a: Named = person;      // ①
const b: Person = employee;   // ②
const c: Person = named;      // ③
const d: Named = employee;    // ④
```', 'OBJECTIVE'),
       (3966, 631, '아래 코드의 컴파일 결과로 옳은 것은?', '```typescript
// tsconfig: strictFunctionTypes 활성화

type Handler = (e: MouseEvent) => void;

const wide = (e: Event) => console.log(e.type);
const narrow = (e: MouseEvent) => console.log(e.clientX);

const h1: Handler = wide;               // ①
const h2: (e: Event) => void = narrow;  // ②
```', 'OBJECTIVE'),
       (3967, 631, '아래 타입 호환 판단 방식에 대한 설명으로 옳은 것은?', '어떤 언어의 타입 검사기는 값이 어떤 이름으로 선언됐는지, 무엇을 상속했는지를 따지지 않는다. 두 타입이 가진 프로퍼티 이름과 타입의 집합만 비교해 한쪽을 다른 쪽 자리에 대입할 수 있는지 판단한다.', 'OBJECTIVE'),
       (3968, 631, '아래 표를 바탕으로 옳지 않은 것은?', '| 상황 | 대입 가능 여부 | 비고 |
|---|---|---|
| 대상 타입의 선택적 프로퍼티 a?: T | 원본에 a가 없어도 가능 | 대상이 요구하지 않는 프로퍼티 |
| readonly 표시만 다른 프로퍼티 | 호환 판단에 영향 없음 | readonly는 수정 가능 여부만 제한 |
| 클래스의 private, protected 멤버 | 같은 선언에서 유래할 때만 가능 | 모양이 같아도 출처가 다르면 불가 |
| 서로 다른 enum 타입 | 불가능 | 숫자 enum은 number와는 상호 호환 |
| Box<string> 과 Box<number> | 불가능 | 타입 인자를 대입한 결과 구조로 비교 |', 'OBJECTIVE'),
       (3969, 631, '아래 수정에서 두 문자열 기반 타입이 서로 섞이지 않게 만든 기법의 이름은?', '```typescript
type UserId = string;
type OrderId = string;

declare function findOrder(id: OrderId): void;

const uid: UserId = "u-1";
findOrder(uid); // 통과됨 — 사용자 ID가 주문 조회로 흘러들어 장애가 났다

// 수정 후
type Marked<T, K extends string> = T & { readonly __kind: K };
type SafeUserId = Marked<string, "UserId">;
type SafeOrderId = Marked<string, "OrderId">;

declare function findOrderSafe(id: SafeOrderId): void;

const sid = "u-1" as SafeUserId;
findOrderSafe(sid); // 컴파일 오류로 잡힘
```', 'SUBJECTIVE'),
       (3970, 631, '아래 코드에서 a에만 오류가 나게 만든 TypeScript 검사의 이름은?', '```typescript
interface Options {
  title: string;
  color?: string;
}

const a: Options = { title: "저장", colour: "red" };  // 오류 발생

const preset = { title: "저장", colour: "red" };
const b: Options = preset;                            // 정상 컴파일
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3965
(10747, 3965, '① const a: Named = person;', 'Person은 Named가 요구하는 name을 갖고 있어 대입된다. age가 남는 것은 대입을 막지 않으며, 변수를 대입한 것이라 초과 프로퍼티 검사도 걸리지 않는다.', false),
(10748, 3965, '② const b: Person = employee;', 'Employee는 Person이 요구하는 name과 age를 모두 갖는다. company가 남아 오류가 난다고 오해하기 쉽지만, 남는 프로퍼티는 호환 판단에서 무시된다.', false),
(10749, 3965, '③ const c: Person = named;', 'Named에는 age가 없어 Person이 요구하는 프로퍼티가 빠진다. 대입은 프로퍼티가 많은 좁은 타입에서 적은 넓은 타입 방향으로만 가능하고, 반대 방향은 누락 오류가 된다.', true),
(10750, 3965, '④ const d: Named = employee;', 'Employee는 name을 갖고 있으므로 Named 자리에 들어간다. 두 타입이 상속으로 이어져 있지 않고 두 단계 떨어져 있어도 요구 프로퍼티만 충족하면 대입된다.', false),

-- 문제 3966
(10751, 3966, '①만 오류다. 더 넓은 매개변수를 받는 함수는 좁은 매개변수 자리에 들어갈 수 없다.', '매개변수는 반공변이라 방향이 반대다. wide는 Event 전체를 다루므로 MouseEvent만 들어오는 자리에서도 안전하게 동작해 ①은 통과한다.', false),
(10752, 3966, '②만 오류다. 더 좁은 매개변수만 받는 함수는 넓은 매개변수 자리에 들어갈 수 없다.', 'h2 자리에는 KeyboardEvent 같은 다른 Event도 들어올 수 있는데 narrow는 clientX를 읽는다. 안전하지 않으므로 매개변수를 좁게 받는 함수의 대입은 거부된다.', true),
(10753, 3966, '①과 ② 모두 오류다. 함수 대입은 매개변수 타입이 정확히 같을 때만 허용된다.', '매개변수 타입이 일치해야 한다는 오해. 더 넓은 타입을 받는 함수는 허용되며, 매개변수 개수도 적은 쪽이 많은 쪽 자리에 들어간다(forEach 콜백이 그 예다).', false),
(10754, 3966, '①과 ② 모두 통과한다. 함수 타입 표기의 매개변수는 양변으로 검사된다.', '메서드 표기와 혼동한 것. 메서드 표기는 흔한 패턴을 허용하려고 양변 검사를 유지하지만, strictFunctionTypes 아래 함수 타입 표기의 매개변수는 반공변으로 검사된다.', false),

-- 문제 3967
(10755, 3967, '필드가 완전히 같아도 선언 이름이 다르면 다른 타입이라, 값을 넘기려면 어댑터 코드를 따로 만들어야 한다.', '이름으로 타입을 구분하는 방식의 특징을 잘못 가져온 것. 프로퍼티 집합으로 판단하므로 모양이 같으면 이름이 달라도 그대로 대입되고 어댑터가 필요 없다.', false),
(10756, 3967, '상속 관계로 선언되지 않은 두 타입은 프로퍼티가 겹쳐도 서로 대입할 수 없다.', '상속 선언이 있어야 호환된다는 오개념. 상속 관계가 전혀 없는 클래스 인스턴스도 인터페이스가 요구하는 프로퍼티를 모두 갖고 있으면 그 자리에 대입된다.', false),
(10757, 3967, '이미 존재하는 객체 리터럴을 쓰려면 그 모양에 맞는 타입 이름을 먼저 선언해 붙여야 한다.', '타입 이름을 먼저 붙여야 한다는 오해. 이름 없는 리터럴도 구조만 맞으면 대입되며, 덕분에 기존 JavaScript 코드에 점진적으로 타입을 입힐 수 있다.', false),
(10758, 3967, '의미가 서로 다른 두 식별자 타입이라도 실제 구조가 같으면 값을 바꿔 넘겨도 걸러내지 못한다.', '구조만 보므로 둘 다 string을 감싼 사용자 ID와 주문 ID는 서로 섞여도 컴파일러가 잡지 못한다. 유연함의 대가로 치르는 대표적 함정이다.', true),

-- 문제 3968
(10759, 3968, '필드 이름과 타입이 모두 같은 두 클래스는 각자 자신이 선언한 private 필드를 하나씩 갖고 있어도 서로 대입할 수 있다.', '표의 세 번째 행에 정면으로 걸린다. private 멤버는 같은 선언에서 유래해야 호환되므로, 각자 선언한 private 필드를 가진 두 클래스는 모양이 같아도 대입되지 않는다.', true),
(10760, 3968, '선택적 프로퍼티는 없어도 대입되므로, 그 프로퍼티가 항상 있다고 가정하고 값을 읽는 코드는 undefined를 만날 수 있다.', '참이다. 대상이 요구하지 않는 프로퍼티라 빠진 채로 대입이 성립하고, 읽는 쪽에서는 값이 없는 경우를 따로 처리해야 한다.', false),
(10761, 3968, 'readonly 여부는 호환에 영향을 주지 않으므로, readonly가 붙었다는 사실만으로 그 값이 끝까지 바뀌지 않는다고 보장할 수는 없다.', '참이다. readonly는 대입 자체를 막지 않으므로 readonly가 없는 타입 자리에 넘어간 뒤 그쪽 코드에서 수정될 수 있다.', false),
(10762, 3968, '숫자 enum 값을 number 매개변수에 넘기는 호출은 통과하지만, 같은 값을 다른 enum 타입 자리에 넘기면 오류가 난다.', '참이다. 숫자 enum은 number와 상호 호환되지만 enum끼리는 이름으로 구분되므로, 값이 같아도 다른 enum 타입 자리에는 대입되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1278, 3969, '브랜드 타입,브랜디드 타입,브랜드타입,브랜딩,브랜드,brand type,branded type,branding,brand,opaque type,오패크 타입', '런타임에는 존재하지 않는 표식 프로퍼티(__kind)를 타입에만 끼워 넣어 구조 자체를 다르게 만드는 기법이 브랜드 타입이다. 구조적 타이핑은 이름이 아니라 프로퍼티 집합으로 호환을 판단하므로, string에 별칭만 다르게 붙인 UserId와 OrderId는 서로 구분되지 않는다. 브랜드 타입은 그 구조에 인위적인 차이를 만들어 명목적 타이핑을 흉내 낸다. 클래스의 private 멤버로 명목성을 얻는 방식이나, 검사를 그냥 무력화하는 타입 단언과는 구분해 두자. __kind는 타입 수준 표식이라 컴파일 후에는 사라지고 런타임에는 그냥 string이므로, 값을 만들 때만 단언이나 검증 함수를 거치게 하면 된다.'),
       (1279, 3970, '초과 프로퍼티 검사,초과 프로퍼티 체크,초과 속성 검사,잉여 프로퍼티 검사,잉여 속성 검사,excess property check,excess property checks,excess property checking', '객체 리터럴을 타입이 명시된 자리에 곧바로 대입할 때만 대상 타입에 없는 프로퍼티를 오류로 잡는 것이 초과 프로퍼티 검사다. 리터럴이 만들어지는 순간 그 타입은 신선한(fresh) 리터럴 타입으로 표시되고, preset처럼 변수에 한 번 담기면 신선함이 사라져 일반 구조적 호환성 규칙만 적용된다. 구조적 타이핑에서는 프로퍼티가 남아도 대입이 되므로 b는 통과한다. 요구 프로퍼티가 빠져서 나는 일반 호환성 오류와는 성격이 다르며, 타입 안전성 규칙이라기보다 옵션 이름 오타를 잡기 위한 편의 기능이라는 점이 핵심이다.');

-- =====================================================
-- Lesson 789: 신선도와 약한 타입 감지, 명목적 타이핑
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4913, 789, '아래 코드에서 컴파일 오류가 나는 대입은?', '```typescript
type Reducer = (acc: number, cur: number, index: number) => number;

const plain = (acc: number, cur: number) => acc + cur;
const full = (acc: number, cur: number, i: number) => acc + cur * i;
const wide = (acc: number, cur: number, i: number, all: number[]) => acc;
const none = () => 0;

const r1: Reducer = plain;   // ①
const r2: Reducer = full;    // ②
const r3: Reducer = wide;    // ③
const r4: Reducer = none;    // ④
```', 'OBJECTIVE'),
       (4914, 789, '아래 타입 검사 동작에 대한 설명으로 옳은 것은?', '어떤 타입 검사기는 객체 리터럴이 만들어지는 순간 그 타입에 신선하다는 표시를 붙인다. 표시가 붙은 값을 타입이 명시된 자리에 곧바로 대입하면 대상 타입에 선언되지 않은 프로퍼티까지 오류로 잡지만, 그 값이 변수에 한 번 담기거나 함수의 반환값으로 빠져나가면 표시가 사라지고 프로퍼티 집합 비교만 남는다.', 'OBJECTIVE'),
       (4915, 789, '아래 코드의 컴파일과 실행 결과로 옳은 것은?', '```typescript
interface Named { name: string }

const employee = { name: "김철수", age: 30, company: "Gravit" };
const n: Named = employee;

for (const key of Object.keys(n)) {
  console.log(key);
}
```', 'OBJECTIVE'),
       (4916, 789, '아래 선언 표를 바탕으로 옳지 않은 것은?', '| 선언 | 멤버 구성 |
|---|---|
| interface Tag | name: string |
| class RedTag | id: string (private), name: string |
| class BlueTag | id: string (private), name: string |
| type Slim | name: string, code?: string (readonly) |

RedTag와 BlueTag는 서로 상속 관계가 없고, 각자 자기 클래스 안에서 id를 private으로 선언했다.', 'OBJECTIVE'),
       (4917, 789, '아래 상황에서 옮겨 간 언어가 쓰는 타입 호환 판단 방식을 부르는 용어는?', '한 팀이 좌표 계산 모듈을 다른 언어로 옮겼다. 원래 코드에서는 x와 y를 가진 값이면 무엇이든 그리기 함수에 넘길 수 있었다. 옮긴 언어에서는 필드 이름과 타입이 글자 하나까지 같은 두 클래스 Point와 Vector 사이에서도 값을 넘기면 컴파일이 거부됐고, 결국 Vector를 받아 Point를 새로 만들어 주는 변환 클래스를 따로 두어야 했다. 함수 호출 자리에서 그때그때 만들어 넘기던 이름 없는 객체 값들도 모두 미리 선언한 타입 이름을 붙여야 했다.', 'SUBJECTIVE'),
       (4918, 789, '아래 코드에서 a 대입만 거부하는 TypeScript 검사의 이름은?', '```typescript
interface ChartOptions {
  title?: string;
  color?: string;
  width?: number;
}

const themeA = { padding: 8, margin: 4 };
const themeB = { padding: 8, width: 320 };

const a: ChartOptions = themeA;  // 오류
const b: ChartOptions = themeB;  // 정상
const c: ChartOptions = {};      // 정상
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4913
(13275, 4913, '① const r1: Reducer = plain;', '매개변수가 적은 함수는 많은 자리에 들어간다. 남는 인수는 그냥 무시되므로 acc와 cur만 받아도 안전하다. forEach 콜백에 값 하나만 적어도 통과하는 것과 같은 규칙이다.', false),
(13276, 4913, '② const r2: Reducer = full;', '매개변수 개수와 타입이 Reducer의 선언과 그대로 일치하고 반환 타입도 number라, 호환을 따질 거리가 아예 없는 대입이다.', false),
(13277, 4913, '③ const r3: Reducer = wide;', 'Reducer 자리는 인수를 세 개만 넘겨주는데 wide는 네 번째 매개변수 all을 읽는다. 받을 값이 없는 매개변수가 생겨 안전하지 않으므로, 대상보다 매개변수가 많은 함수는 거부된다.', true),
(13278, 4913, '④ const r4: Reducer = none;', '매개변수를 하나도 받지 않는 함수는 넘어온 인수를 전부 무시할 뿐이라 안전하다. 개수가 맞아야 대입된다는 오해에서 고르기 쉬운 선지다.', false),

-- 문제 4914
(13279, 4914, '대상 타입에 [key: string]: unknown 같은 인덱스 시그니처를 선언해 두면 같은 리터럴을 그대로 대입해도 통과한다.', '인덱스 시그니처가 있으면 선언되지 않은 프로퍼티라는 판정 자체가 성립하지 않는다. 임의의 추가 필드를 받아야 하는 설정 객체에서 이 검사를 정식으로 완화하는 방법이다.', true),
(13280, 4914, '리터럴을 함수 인자로 직접 적어 넘길 때는 이 검사가 적용되지 않아 선언에 없는 프로퍼티도 통과한다.', '변수 선언 자리에서만 검사한다는 오해. 인자로 직접 적은 리터럴도 만들어진 그 자리에서 매개변수 타입에 대입되는 것이라 표시가 살아 있고 똑같이 걸린다.', false),
(13281, 4914, '다른 객체를 스프레드로 펼쳐 새로 만든 객체는 리터럴이 아니므로 이 검사를 피해 간다.', '스프레드로 조합한 결과도 그 자리에서 새로 만들어진 리터럴이라 표시가 붙는다. 검사를 피하려면 결과를 변수에 한 번 담아 표시를 없애야 한다.', false),
(13282, 4914, 'as 단언으로 대상 타입을 지정해도 선언에 없는 프로퍼티는 여전히 오류로 남는다.', '단언은 이 검사를 무력화해 오류가 사라진다. 다만 이름을 잘못 적은 프로퍼티까지 함께 통과되므로 안전한 우회책은 아니다.', false),

-- 문제 4915
(13283, 4915, '대입할 때 Named에 없는 age와 company가 떨어져 나가므로 반복문은 name만 출력한다.', '타입 대입이 값을 잘라낸다는 오해. 대입은 같은 객체를 다른 타입으로 가리키게 할 뿐이라, 런타임 객체에는 세 프로퍼티가 그대로 남아 모두 출력된다.', false),
(13284, 4915, 'employee에 Named가 선언하지 않은 프로퍼티가 있어 대입하는 줄에서 컴파일 오류가 난다.', '초과 프로퍼티 검사와 혼동한 것. 그 검사는 그 자리에서 만든 리터럴에만 걸리고, 변수를 거친 employee는 요구 프로퍼티만 갖추면 남는 프로퍼티가 있어도 대입된다.', false),
(13285, 4915, 'key의 타입이 "name" 리터럴로 좁혀져 n[key] 접근이 추가 단언 없이 허용된다.', 'Object.keys는 키를 keyof로 좁혀 주지 않는다. 검사기는 실제 객체에 선언 밖 프로퍼티가 더 있을 수 있다고 보기 때문이며, 그래서 n[key] 접근에는 별도 단언이나 타입 가드가 필요하다.', false),
(13286, 4915, '반복문은 name, age, company를 모두 출력하지만 key의 타입은 string으로 추론된다.', '값에는 남는 프로퍼티가 살아 있고 타입 쪽은 Named가 아는 만큼만 본다. 넓은 타입으로 대입하면서 생긴 정보 손실 때문에 Object.keys의 반환도 string[]에 머문다.', true),

-- 문제 4916
(13287, 4916, 'RedTag 인스턴스와 BlueTag 인스턴스는 멤버 구성이 같아도 서로의 타입 자리에 대입할 수 없다.', '참이다. 비공개 멤버는 같은 선언에서 유래할 때만 호환되므로, 각자 자기 클래스에서 선언한 id를 가진 두 클래스는 모양이 같아도 끝내 다른 타입으로 취급된다.', false),
(13288, 4916, 'RedTag 인스턴스를 Slim 타입 변수에 담으려면 code 값을 먼저 채워 넣어야 한다.', '거짓이다. code는 선택적 프로퍼티라 원본에 없어도 대입이 성립한다. Slim이 요구하는 것은 name뿐이고, RedTag에 남는 id는 호환 판단에서 무시된다.', true),
(13289, 4916, 'Tag 타입 변수에는 RedTag 인스턴스도 BlueTag 인스턴스도 상속 선언 없이 그대로 담을 수 있다.', '참이다. Tag가 요구하는 name을 두 클래스가 모두 갖고 있고, Tag에는 비공개 멤버가 없다. 상속으로 이어져 있지 않아도 프로퍼티 집합 비교만으로 대입이 성립한다.', false),
(13290, 4916, 'Slim의 code에 붙은 readonly는 대입 가능 여부를 가르는 조건이 아니다.', '참이다. readonly는 그 프로퍼티를 나중에 고칠 수 있는지만 제한하고 호환 판단에는 관여하지 않아, readonly가 없는 타입과도 서로 대입된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1594, 4917, '명목적 타이핑,명목 타이핑,명목적 타입 시스템,명목적 타입,노미널 타이핑,노미널 타입 시스템,이름 기반 타이핑,nominal typing,nominal type system,nominally typed,nominal', '선언된 이름과 상속 관계로 타입을 구분하는 방식이 명목적 타이핑이다. 모양이 같아도 이름이 다르면 다른 타입이라 값을 그대로 넘길 수 없고, 변환 클래스 같은 보일러플레이트가 늘어난다. 이름 없는 객체 값마다 타입 이름을 선언해 붙여야 했던 것도 같은 이유다. 대신 의미가 다른 값이 섞여 들어가는 사고를 컴파일 단계에서 막아 준다. 프로퍼티 집합만 비교하는 구조적 타이핑과 반대 축에 있으며, 값의 모양만 보고 판단하는 덕 타이핑은 구조적 타이핑 쪽이니 헷갈리지 말자. TypeScript도 클래스의 private·protected 멤버와 enum에 한해서는 같은 선언에서 유래했는지를 따져 이 방식처럼 동작한다.'),
       (1595, 4918, '약한 타입 감지,약한 타입 검사,약한 타입 탐지,약한 타입 체크,약한 타입,위크 타입 감지,weak type detection,weak type check,weak type checking,weak types,weak type', '모든 프로퍼티가 선택적인 타입을 약한 타입이라 하고, 그런 타입에 대입하려는 값이 프로퍼티를 갖고 있으면서 이름이 겹치는 것이 하나도 없으면 실수로 보고 거부하는 규칙이 약한 타입 감지다. themeA는 padding과 margin만 있어 ChartOptions와 겹치는 이름이 없어 걸리고, themeB는 width가 겹치므로 남는 padding이 있어도 통과한다. c처럼 프로퍼티가 하나도 없는 객체는 애초에 이 검사의 대상이 아니다. 초과 프로퍼티 검사와 헷갈리기 쉬운데, 그 검사는 그 자리에서 만든 신선한 리터럴에만 걸린다. 여기서는 themeA와 themeB가 변수를 거쳐 오므로 초과 프로퍼티 검사는 작동하지 않는다.');

-- =====================================================
-- Lesson 947: TypeScript 구조적 타이핑과 제네릭·함수·클래스 호환 규칙
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5861, 947, '아래 코드에서 타입 오류로 거부되는 줄은?', '```typescript
interface Box<T> { value: T }

interface Point { x: number; y: number }
interface Point3D { x: number; y: number; z: number }

declare const flat: Box<Point>;
declare const deep: Box<Point3D>;

const a: Box<Point> = deep;                              // ①
const b: Box<Point3D> = flat;                            // ②
const c: { value: Point } = deep;                        // ③
const d: Box<Point3D> = { value: { x: 1, y: 2, z: 3 } }; // ④
```', 'OBJECTIVE'),
       (5862, 947, '아래 타입 설계 기법에 대한 설명으로 옳은 것은?', '어떤 팀은 서로 섞이면 안 되는 두 식별자 타입을 구분하려고, 원래의 string에 런타임에는 만들지 않는 읽기 전용 표식 프로퍼티를 교차 타입으로 덧붙였다. 표식의 값 자리에는 타입마다 다른 문자열 리터럴을 넣어 두 타입의 구조가 서로 달라지게 했다.', 'OBJECTIVE'),
       (5863, 947, '위 함수 타입 호환 규칙 표를 바탕으로 옳지 않은 것은?', '| 항목 | 검사 방식 | 비고 |
|---|---|---|
| 메서드 표기 pick(item: T): void | 매개변수를 양변(bivariant)으로 검사 | 흔한 패턴을 허용하려고 남겨 둔 예외 |
| 함수 타입 프로퍼티 표기 pick: (item: T) => void | 매개변수를 반공변(contravariant)으로 검사 | strictFunctionTypes를 켠 상태 |
| 매개변수 개수 | 적게 받는 함수를 더 많이 넘겨주는 자리에 대입 가능 | 남는 인수는 무시된다 |
| 반환 타입 | 공변(covariant)으로 검사 | 더 좁은 반환을 넓은 반환 자리에 대입 가능 |', 'OBJECTIVE'),
       (5864, 947, '아래 선언들에 대한 설명으로 옳은 것은?', '```typescript
class RedToken {
  private secret = "";
  constructor(public name: string) {}
}

class BlueToken {
  private secret = "";
  constructor(public name: string) {}
}

class GreenToken extends RedToken {}

interface NameHolder { name: string }

declare const red: RedToken;
declare const blue: BlueToken;
declare const green: GreenToken;
```', 'OBJECTIVE'),
       (5865, 947, '아래 오류를 한꺼번에 없앤, 인터페이스 선언에 더한 문법 요소의 이름은?', '```typescript
interface FeatureFlags {
  newEditor: boolean;
}

declare const raw: string;
const flags: FeatureFlags = JSON.parse(raw);

console.log(flags["betaSearch"], flags["darkMode"]);
// error TS7053: FeatureFlags 타입을 betaSearch로 인덱싱할 수 없어 요소가 암시적으로 any 타입이 됩니다.

const preset: FeatureFlags = { newEditor: true, betaSearch: false, darkMode: true };
// error TS2353: 객체 리터럴에는 선언된 프로퍼티만 지정할 수 있습니다.
```

FeatureFlags 선언 안에 한 줄을 더하자 위 오류가 모두 사라졌다. 대신 betaSearsh처럼 이름을 잘못 적은 접근까지 조용히 통과하게 됐다.', 'SUBJECTIVE'),
       (5866, 947, '아래 세 가지 일이 모두 일어날 수 있게 만든 TypeScript 타입 시스템의 성질을 부르는 용어는?', '한 팀이 다른 언어로 쓰던 도메인 모듈을 TypeScript로 옮긴 뒤 아래 일을 겪었다.

- Repository 인터페이스를 implements로 선언하지 않은 테스트용 목 객체를 서비스에 그대로 주입했는데 컴파일이 통과했다.
- 라이브러리가 제공하는 타입을 import하지 않고 같은 모양의 인터페이스를 직접 선언해 쓴 동료의 코드도 오류 없이 붙었다.
- 반면 사용자 번호를 받는 함수에 주문 번호를 넘긴 코드는 끝내 걸러지지 않아 운영에서 장애가 났다. 두 값은 모두 문자열이었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5861
(15803, 5861, '① const a: Box<Point> = deep;', 'deep의 value는 Point가 요구하는 x와 y를 모두 갖는다. 타입 인자가 글자까지 같아야 한다는 오해에서 고르기 쉬운데, 제네릭은 인자를 대입한 결과 구조로 비교되므로 남는 z는 판단에서 빠진다.', false),
(15804, 5861, '② const b: Box<Point3D> = flat;', 'value 자리에서 Point를 Point3D에 맞춰야 하는데 z가 없다. 호환 검사는 프로퍼티 단위로 재귀 적용돼, 중첩된 안쪽에서 요구 프로퍼티가 빠지면 바깥 대입도 함께 거부된다.', true),
(15805, 5861, '③ const c: { value: Point } = deep;', '이름이 Box인지 이름 없는 객체 타입인지는 판단 기준이 아니다. value 프로퍼티 하나만 놓고 비교하므로 선언 이름이 달라도 ①과 같은 이유로 통과한다.', false),
(15806, 5861, '④ const d: Box<Point3D> = { value: { x: 1, y: 2, z: 3 } };', '그 자리에서 만든 리터럴이라 초과 프로퍼티 검사를 받지만, 안쪽 객체의 x와 y와 z가 Point3D와 그대로 맞아 선언에 없는 이름이 하나도 없다. 중첩 리터럴이면 무조건 걸린다는 오해다.', false),

-- 문제 5862
(15807, 5862, '표식 프로퍼티는 컴파일된 JavaScript 객체에도 남아 JSON으로 내보낼 때 함께 실린다.', '타입 자리에만 존재하는 표식이라 컴파일 뒤 코드에는 흔적이 없다. 타입 선언과 실제 값의 모양을 같은 것으로 본 오해이며, 직렬화 결과에는 원래의 문자열만 남는다.', false),
(15808, 5862, '원래 타입과 교차했기 때문에 그 값에서는 string이 주는 메서드를 더 이상 호출할 수 없다.', '교차 타입은 양쪽 멤버를 모두 갖는 타입이라 문자열 기능이 그대로 살아 있다. 표식이 원래 타입을 대체한다고 본 오해로, 길이 읽기나 문자열 메서드는 평소처럼 쓸 수 있다.', false),
(15809, 5862, '표식이 붙은 타입의 값은 평범한 문자열에서 바로 만들 수 없어, 단언이나 검증 함수를 거쳐야 한다.', '런타임에 붙일 수 없는 프로퍼티를 요구하는 타입이라 일반 문자열은 그대로 대입되지 않는다. 그래서 값을 만드는 통로를 한 곳으로 모아 두고, 그 뒤부터는 컴파일러가 섞임을 막게 한다.', true),
(15810, 5862, '표식을 붙이고 나면 그 값은 평범한 string 매개변수를 받는 함수에는 더 이상 넘길 수 없다.', '교차 타입은 string이 요구하는 것을 모두 갖추고 있어 string 자리에는 그대로 들어간다. 구분이 생기는 방향은 표식이 서로 다른 타입끼리이며, 넓은 쪽으로의 대입은 막히지 않는다.', false),

-- 문제 5863
(15811, 5863, '메서드 표기로 선언한 콜백 자리에는 매개변수를 더 좁은 타입으로 받는 함수를 넣을 수 없다.', '거짓이다. 표 첫 행대로 메서드 표기의 매개변수는 양변으로 검사돼 더 좁게 받는 함수도 들어간다. Array<Dog>를 Array<Animal> 자리에 쓰는 흔한 코드를 막지 않으려고 남겨 둔 예외다.', true),
(15812, 5863, '같은 시그니처를 함수 타입 프로퍼티로 바꿔 선언하면, 매개변수를 더 좁게 받는 함수를 넣던 코드가 그 순간부터 오류로 잡힌다.', '참이다. 둘째 행의 반공변 검사는 더 넓게 받는 함수만 허용한다. 좁게 받는 함수는 자기가 모르는 값이 들어올 수 있어 거부되므로, 안전이 중요한 콜백은 이 표기로 선언한다.', false),
(15813, 5863, '인수를 세 개 넘겨주는 자리에 매개변수를 하나만 적은 콜백을 넘겨도 통과한다.', '참이다. 셋째 행대로 남는 인수는 그냥 버려지므로 적게 받는 쪽이 안전하다. 콜백을 쓸 때 필요한 매개변수만 적어도 컴파일이 되는 이유가 이 규칙이다.', false),
(15814, 5863, '선언한 반환 타입보다 프로퍼티를 더 많이 가진 객체를 돌려주는 함수도 그 자리에 대입된다.', '참이다. 넷째 행의 공변 검사는 더 좁은 반환을 허용한다. 받는 쪽은 선언된 프로퍼티만 꺼내 쓰므로 값에 남는 프로퍼티가 있어도 문제가 되지 않는다.', false),

-- 문제 5864
(15815, 5864, 'RedToken과 BlueToken은 멤버 이름과 타입이 모두 같으므로 서로의 타입 자리에 그대로 대입된다.', '모양만 같으면 된다고 본 오해. 비공개 멤버는 같은 선언에서 유래할 때만 호환되므로, 각자 자기 클래스에서 선언한 secret을 가진 두 클래스는 끝까지 다른 타입으로 남는다.', false),
(15816, 5864, 'GreenToken은 secret을 자기 몸체에서 선언하지 않았으므로 그 인스턴스는 RedToken 자리에 대입되지 않는다.', '물려받은 secret은 RedToken의 선언에서 유래한 같은 멤버다. 직접 적어야 호환된다는 오해이며, 출처가 같으므로 GreenToken 인스턴스는 RedToken 자리에 그대로 들어간다.', false),
(15817, 5864, 'NameHolder 자리에는 name만 가진 객체 리터럴이 들어가지만, 비공개 멤버를 가진 red는 거부된다.', '비공개 멤버는 대상이 요구하지 않는 한 남는 멤버일 뿐이라 대입을 막지 않는다. NameHolder에는 비공개 멤버가 없어 name만 맞으면 리터럴도 클래스 인스턴스도 들어간다.', false),
(15818, 5864, 'red와 green은 NameHolder 자리에 모두 들어가지만, red를 BlueToken 자리에 넣는 것은 거부된다.', 'NameHolder가 요구하는 것은 name뿐이라 두 인스턴스 모두 통과한다. 반면 RedToken과 BlueToken은 각자 선언한 secret 때문에 구조가 같아도 섞이지 않아, 클래스는 부분적으로 이름 기반으로 동작한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1910, 5865, '인덱스 시그니처,인덱스시그니처,인덱스 시그니쳐,색인 시그니처,index signature,indexsignature,index signatures', '키 이름을 하나씩 나열하는 대신 어떤 타입의 키에 어떤 타입의 값이 오는지를 한 줄로 선언해 두는 것이 인덱스 시그니처다. [key: string]: boolean 한 줄이 들어가면 선언에 없는 이름으로 읽을 때 나던 암시적 any 오류가 사라지고, 초과 프로퍼티 검사도 선언되지 않은 프로퍼티라는 판정 자체가 성립하지 않아 리터럴 대입이 통과한다. betaSearch와 darkMode를 각각 선택적 프로퍼티로 추가하는 방법과 헷갈리기 쉬운데, 그쪽은 이름을 적은 만큼만 열리고 오타는 그대로 잡힌다. 반대로 인덱스 시그니처는 어떤 이름이든 열리므로 오타까지 통과한다는 점이 본문의 마지막 문장과 이어진다. 검사를 그 자리 한 번만 무력화하는 타입 단언이나 신선함을 없애려고 변수에 담는 우회와 달리, 타입 선언 자체를 넓히는 정식 방법이라 값 타입을 unknown으로 두고 좁혀 쓰면 더 안전하다.'),
       (1911, 5866, '구조적 타이핑,구조 타이핑,구조적 타입 시스템,구조적 타입,구조적 서브타이핑,구조적 부분 타입,structural typing,structural type system,structural subtyping,structurally typed,structural', '선언한 이름이나 상속 관계가 아니라 값이 가진 프로퍼티 이름과 타입의 집합으로 호환을 판단하는 방식이 구조적 타이핑이다. implements 선언이 없어도 요구하는 프로퍼티만 갖추면 그 자리에 들어가고, 같은 모양의 인터페이스를 따로 선언해도 같은 타입으로 취급되므로 앞의 두 가지 일이 가능하다. 그 대가로 사용자 번호와 주문 번호처럼 의미만 다르고 모양이 같은 값은 걸러지지 않는데, 이때는 타입에만 존재하는 표식을 덧붙이는 브랜드 타입으로 구조에 차이를 만들어 막는다. 선언 이름으로 타입을 가르는 명목적 타이핑과 반대 축에 있고, 런타임에 필요한 멤버가 실제로 있는지로 판단하는 덕 타이핑과 달리 컴파일 단계에서 정적으로 검사한다. TypeScript도 클래스의 private·protected 멤버와 enum에 한해서는 같은 선언에서 유래했는지를 따져 이름 기반처럼 동작한다.');
