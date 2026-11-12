-- Unit: any·unknown·never (Unit ID: 208)
-- Chapter: TypeScript (Chapter ID: 20)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (634, 208, 'unknown 좁히기와 never 반환'),
       (792, 208, '타입 계층의 양 끝과 strict 옵션'),
       (950, 208, 'any·unknown·never - 어디까지 막히고 어디부터 통과하는가');

-- =====================================================
-- Lesson 634: unknown 좁히기와 never 반환
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3983, 634, '아래 코드에서 타입 오류가 발생하는 줄은?', '```typescript
function describe(value: unknown): string {
  const len = value.length;                              // (가)
  if (typeof value === "string") return value.trim();    // (나)
  if (value instanceof Date) return value.toISOString(); // (다)
  return String(value);                                  // (라)
}
```', 'OBJECTIVE'),
       (3984, 634, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 타입 | 담을 수 있는 값 | 다른 타입 변수에 대입 | 멤버 접근 |
|---|---|---|---|
| any | 모든 값 | 어디든 가능 | 검사 없이 허용 |
| unknown | 모든 값 | unknown·any에만 가능 | 좁히기 전에는 불가 |
| never | 없음 | 어디든 가능 | 해당 없음 |', 'OBJECTIVE'),
       (3985, 634, '아래 코드를 그대로 둔 채 Status 유니온에 "error"를 추가했을 때 일어나는 일로 옳은 것은?', '```typescript
type Status = "idle" | "loading" | "done";

function label(status: Status): string {
  switch (status) {
    case "idle": return "대기";
    case "loading": return "로딩 중";
    case "done": return "완료";
    default: {
      const exhaustive: never = status;
      return exhaustive;
    }
  }
}
```', 'OBJECTIVE'),
       (3986, 634, '아래 코드의 프로퍼티 이름 오타를 컴파일러가 잡아내지 못한 이유로 옳은 것은?', '```typescript
function parseConfig(raw: string) {
  const cfg = JSON.parse(raw);
  return cfg.serevr.port;   // server 오타
}

const port = parseConfig(rawJson);
port.toFixed(2);            // 실행 시 TypeError
```', 'OBJECTIVE'),
       (3987, 634, '아래에서 팀이 파싱 결과 변수에 표기하기로 정한 타입의 이름은?', '외부 API 응답을 JSON.parse로 받아 곧바로 res.data.name처럼 꺼내 쓰던 서비스가, 응답 필드 이름이 바뀐 날 배포한 뒤 장애가 나고서야 문제를 알았다. 회고 끝에 팀은 파싱 결과를 담는 변수마다 특정 타입을 표기하도록 규칙을 정했다. 규칙을 적용하자 예전 그대로인 접근 코드가 컴파일 단계에서 전부 오류로 표시됐고, typeof·in으로 모양을 확인한 뒤에야 통과했다. 그 변수를 다른 타입 변수에 옮겨 담는 줄도 함께 막혀, 검사 구멍이 옆 모듈로 번지는 일도 사라졌다.', 'SUBJECTIVE'),
       (3988, 634, '아래에서 fail 함수의 반환 타입으로 고쳐 적은 타입의 이름은?', '설정값이 없으면 곧바로 예외를 던지고 끝나는 fail 함수를 만들었다. 반환 타입을 void로 적었더니 const raw = env.PORT ?? fail("PORT 없음"); 줄에서 raw가 string | void로 추론돼 바로 다음 줄 Number(raw)가 타입 오류로 막혔다. 함수 본문과 호출부는 한 글자도 건드리지 않고 반환 타입 한 단어만 다른 타입으로 고쳐 적자, 같은 자리에서 raw가 string으로 좁혀지며 오류가 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3983
(10795, 3983, '(나)', 'typeof 검사를 통과한 분기 안에서는 value가 string으로 확정돼 trim 호출이 허용된다. 좁히기를 거쳐도 타입이 그대로 남는다고 본 오해.', false),
(10796, 3983, '(가)', 'unknown은 좁히기 전에는 어떤 멤버에도 접근할 수 없는데, length 접근이 어떤 검사보다도 앞에 있어 이 줄에서 막힌다. 같은 자리에 any가 있었다면 그냥 통과했을 것이다.', true),
(10797, 3983, '(다)', 'instanceof도 좁히기 수단이라 이 분기 안에서 value는 Date로 확정되고 toISOString 호출이 가능하다. typeof만 좁히기로 인정된다고 본 오해.', false),
(10798, 3983, '(라)', 'String()은 어떤 값이든 인자로 받으므로 좁히지 않은 값을 그대로 넘겨도 된다. 좁히기 전에는 인자 전달조차 막힌다고 본 오해.', false),

-- 문제 3984
(10799, 3984, 'unknown으로 받은 값을 string 매개변수에 넘기려면 좁히기나 단언을 한 번 거쳐야 한다.', '표에서 unknown은 unknown·any에만 대입되므로 string 자리에 그대로 들어가지 못한다. 쓰기 전 확인을 강제하는 성질이라 참인 진술이다.', false),
(10800, 3984, 'any가 한 번 섞이면 그 값에서 파생된 값까지 검사 없이 통과해 안전성이 조용히 새어 나간다.', '표의 any 행(어디든 대입·검사 없이 접근)이 파생된 값에도 그대로 이어져 전염이 생긴다. 그래서 참인 진술이다.', false),
(10801, 3984, 'string | never로 적은 유니온은 결국 string 하나만 적은 것과 같이 다뤄진다.', '표에서 never는 담을 수 있는 값이 없으므로 유니온에 더해도 늘어나는 값이 없다. 그래서 참인 진술이다.', false),
(10802, 3984, 'never는 담을 수 있는 값이 없으니 다른 타입의 변수에 대입하는 것도 함께 막힌다.', '표의 never 행은 대입이 어디든 가능하다고 적혀 있어 거짓이다. 값이 없다는 성질과 대입 가능 여부를 뒤섞은 진술로, 값이 없으니 쓸 데도 없다고 본 오해다.', true),

-- 문제 3985
(10803, 3985, 'default 분기의 대입 줄에서 컴파일 오류가 나 처리하지 않은 멤버가 있음을 알려 준다.', 'case 세 개를 지나고 남은 status가 "error"로 좁혀지는데 never 변수에는 어떤 값도 대입할 수 없어 이 줄이 막힌다. 유니온이 늘어난 사실을 실행 전에 붙잡는 완전성 검사다.', true),
(10804, 3985, '컴파일은 그대로 통과하고 label("error")를 호출할 때 undefined가 반환된다.', '유니온에 멤버를 더해도 컴파일러는 알아채지 못한다고 본 오해. default에 never 대입이 있어 실행 이전에 오류로 걸린다.', false),
(10805, 3985, 'label 함수의 반환 타입이 never로 바뀌어 이 함수를 부르는 곳마다 오류가 번진다.', 'never는 default 블록 안 지역 변수의 타입일 뿐이고 함수 반환 타입은 선언한 대로 string이다. 한 지역 변수의 타입이 함수 전체로 전파된다고 본 오해.', false),
(10806, 3985, '기존 case 세 곳에서 status 타입 불일치 오류가 먼저 나고 default 분기는 영향을 받지 않는다.', '"idle"·"loading"·"done"은 넓어진 유니온에도 그대로 들어 있어 각 case는 멀쩡하다. 유니온에 멤버를 더하면 기존 분기가 깨진다고 본 오해.', false),

-- 문제 3986
(10807, 3986, '값이 unknown으로 추론돼 멤버 접근은 허용되고 오류 확인만 실행 시점으로 미뤄졌다.', 'unknown이었다면 좁히기 전 멤버 접근 자체가 컴파일 오류로 막혀 오타 줄에서 바로 걸렸을 것이다. any와 unknown을 같은 것으로 본 오해.', false),
(10808, 3986, '매개변수 raw에 string 표기가 있어 함수의 반환 타입도 string으로 고정됐다.', '반환 타입은 return 식에서 추론되며 매개변수 표기를 따라가지 않는다. 표기 하나가 함수 전체의 타입을 정한다고 본 오해.', false),
(10809, 3986, 'JSON.parse의 반환 타입이 any라 거기서 파생된 프로퍼티 접근과 반환값까지 검사에서 빠졌다.', 'any 값에서 나온 값은 다시 any가 돼 오타든 구조 변경이든 걸러지지 않는다. port까지 any로 이어져 toFixed 호출도 통과한 뒤 실행에서 터진다.', true),
(10810, 3986, 'strict를 켜면 암시적 any가 오류가 되므로 이 코드는 strict가 꺼져 있어야만 컴파일된다.', 'noImplicitAny가 잡는 것은 표기가 없어 추론할 근거가 없는 자리다. 여기서는 JSON.parse가 명시적으로 any를 돌려주므로 strict를 켜도 그대로 통과한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1284, 3987, 'unknown,언노운,unknown 타입,언노운 타입', 'any와 unknown은 둘 다 어떤 값이든 담지만, any는 확인을 생략하고 unknown은 쓰기 전 확인을 강제한다. JSON.parse나 fetch 응답처럼 런타임 구조가 보장되지 않는 값에 unknown을 표기하면 검증하지 않은 접근이 컴파일 단계에서 막힌다. 또 unknown은 unknown·any 말고는 대입되지 않아 any처럼 옆 모듈로 전염되지 않는다. catch 절의 예외 객체도 같은 이유로 strict에서 기본이 unknown이다. 어떤 타입이든 받아 그대로 돌려주면서 타입 관계까지 지켜야 한다면 unknown이 아니라 제네릭을 쓴다.'),
       (1285, 3988, 'never,네버,never 타입,네버 타입', 'void는 정상적으로 끝나되 돌려줄 값이 없다는 뜻이라 유니온에 그대로 남아 string | void가 되고, 그래서 Number(raw)가 막혔다. never는 값이 하나도 없는 최하위 타입이라 유니온에 넣으면 사라진다(string | never는 string). 항상 예외를 던지거나 무한 루프에 빠져 정상 종료 자체가 없는 함수의 반환 타입이 never이며, 호출부 뒤쪽 코드가 도달 불가임을 컴파일러가 인식한다. void와 never의 차이는 반환값의 유무가 아니라 정상 종료의 유무다.');

-- =====================================================
-- Lesson 792: 타입 계층의 양 끝과 strict 옵션
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4931, 792, '아래 타입 정의에서 Primitive에 최종적으로 남는 타입은?', '```typescript
type Drop<T, U> = T extends U ? never : T;

type Primitive = Drop<string | number | (() => void), Function>;
```', 'OBJECTIVE'),
       (4932, 792, '아래 설명에 해당하는 TypeScript 특수 타입에 대한 설명으로 옳은 것은?', '이 타입에는 담을 수 있는 값이 하나도 없다. 그래서 이 타입으로 선언한 변수에는 어떤 값도 대입할 수 없으며, 값이 없다는 성질 때문에 타입 계층에서 모든 타입의 아래쪽 끝에 놓인다.', 'OBJECTIVE'),
       (4933, 792, '아래 코드에서 컴파일 오류가 발생하는 줄은?', '```typescript
function move(a: any, u: unknown) {
  const p: string = a;    // (가)
  const q: string = u;    // (나)
  const r: any = u;       // (다)
  const s: unknown = a;   // (라)
}
```', 'OBJECTIVE'),
       (4934, 792, '아래 옵션을 모두 켠 프로젝트에서 일어나는 일로 옳지 않은 것은?', '| 옵션 | strict 포함 여부 | 하는 일 |
|---|---|---|
| noImplicitAny | 포함 | 타입 표기가 없어 추론할 근거가 없는 자리를 오류로 표시한다 |
| useUnknownInCatchVariables | 포함 (4.4 이상) | catch 절이 받는 예외 값의 기본 타입을 unknown으로 정한다 |
| strictNullChecks | 포함 | null·undefined를 다른 값과 구분되는 별도 타입으로 다룬다 |', 'OBJECTIVE'),
       (4935, 792, '아래에서 팀원이 단언으로 붙여 빌드를 통과시킨 타입의 이름은?', 'JavaScript로 된 결제 모듈을 TypeScript로 옮기는 중, 타입 정의 파일이 없는 외부 라이브러리 때문에 빌드가 막혔다. 한 팀원이 그 라이브러리가 돌려준 객체에 as로 어떤 타입을 붙이자 빌드가 곧바로 통과했다. 두 달 뒤, 그 객체에서 꺼내 쓴 값들이 여러 모듈로 퍼진 상태에서 오타가 섞인 프로퍼티 접근도, 문자열 값에 toFixed를 부르는 줄도 에디터에 밑줄 하나 뜨지 않았고, 결제 금액이 NaN으로 찍히는 장애가 배포 뒤에야 드러났다. 같은 자리에 unknown을 붙였다면 그 줄들은 전부 빌드 단계에서 먼저 막혔을 것이다.', 'SUBJECTIVE'),
       (4936, 792, '아래에서 마지막에 first 함수 시그니처에 도입한 문법의 이름은?', '배열의 첫 원소를 돌려주는 유틸 first를 매개변수와 반환 타입 모두 any로 적었더니, const u = first(users) 다음 줄에 u.nmae처럼 오타를 쳐도 빌드가 그대로 통과했다. 반환 타입을 unknown으로 바꾸자 이번에는 오타는 걸렸지만 u.name 같은 정상적인 접근까지 막혀 호출부마다 as User 단언을 붙여야 했다. 시그니처를 한 번 더 고치자 first(users)는 User를, first(scores)는 number를 그대로 돌려주게 됐고, 호출부의 단언은 모두 지웠는데도 u.nmae 오타는 여전히 컴파일 단계에서 걸렸다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4931
(13323, 4931, 'string | number | (() => void)', '조건이 참인 멤버가 never로 바뀔 뿐 유니온의 멤버 수는 그대로라고 본 오해. never는 유니온에 자리를 남기지 않아 멤버가 실제로 줄어든다.', false),
(13324, 4931, 'string | number', '조건이 유니온 멤버마다 따로 적용돼 Function에 해당하는 () => void만 never가 되고, never는 유니온에 흔적을 남기지 않아 나머지 두 멤버만 남는다.', true),
(13325, 4931, 'never', '멤버 하나라도 조건을 만족하면 유니온 전체가 접힌다고 본 오해. 조건은 멤버별로 판정되므로 Function이 아닌 string·number는 그대로 살아남는다.', false),
(13326, 4931, '() => void', '조건이 참일 때와 거짓일 때의 결과를 뒤집어 읽은 오해. 참인 쪽에 never를 적었으므로 조건을 만족한 함수 타입이 남는 것이 아니라 빠진다.', false),

-- 문제 4932
(13327, 4932, '교차 타입에 한 번 섞이면 결과 전체가 이 타입이 되어 만들 수 있는 값이 사라진다.', '두 조건을 동시에 만족해야 하는데 한쪽이 값을 하나도 갖지 않으면 공통으로 남는 값도 없다. string & number처럼 서로 모순되는 교차가 이 타입으로 접히는 것도 같은 이유다.', true),
(13328, 4932, '이 타입의 값은 다른 타입의 변수로 옮겨 담는 길이 모두 막혀 있다.', '값을 받는 쪽과 주는 쪽의 방향을 뒤섞은 오해. 담긴 값이 하나도 없어 어떤 타입의 자리에 놓아도 약속을 깨지 않으므로, 이 타입에서 나가는 대입은 오히려 어디든 허용된다.', false),
(13329, 4932, '함수의 반환 타입으로 적으면 돌려줄 값 없이 정상적으로 끝난다는 뜻이 된다.', 'void의 뜻을 갖다 붙인 오해. 정상 종료하되 돌려줄 값이 없는 쪽이 void이고, 이 타입은 예외를 던지거나 무한 루프에 빠져 정상 종료 자체가 없는 함수에 붙는다.', false),
(13330, 4932, '유니온에 더하면 멤버가 하나 늘어 쓰는 쪽에서 분기를 하나 더 처리해야 한다.', '담을 수 있는 값이 없으니 유니온에 더해도 가능한 값이 늘지 않아 그대로 사라진다. string과 합친 결과가 다시 string이라 처리할 분기도 늘지 않는다.', false),

-- 문제 4933
(13331, 4933, '(다)', 'unknown 값은 any 자리에 그대로 들어간다. 확인을 강제하는 타입이니 any로 옮기는 것도 막힌다고 본 오해로, 실제로 막히는 쪽은 구체 타입 자리다.', false),
(13332, 4933, '(가)', 'any는 타입 계층 밖에 있어 string을 포함한 어떤 타입 자리에도 검사 없이 들어간다. any와 unknown의 대입 규칙을 같은 것으로 본 오해.', false),
(13333, 4933, '(라)', 'unknown은 모든 값을 담는 최상위 타입이라 any 값도 문제없이 받는다. 두 타입이 서로 오가지 못한다고 본 오해.', false),
(13334, 4933, '(나)', 'unknown은 정체를 확인하기 전에는 구체 타입 자리에 놓을 수 없어 이 줄에서 막힌다. typeof로 좁히거나 단언을 거쳐야 통과하며, 이 제약 덕분에 검사 구멍이 옆 코드로 번지지 않는다.', true),

-- 문제 4934
(13335, 4934, 'catch (e) 블록에서 e.message를 바로 읽으면 오류가 나고, instanceof Error로 좁힌 뒤에야 읽을 수 있다.', '표의 두 번째 행대로 예외 값이 unknown으로 들어오고, unknown은 확인 전 멤버 접근이 막히므로 참인 진술이다. JavaScript는 Error가 아닌 값도 던질 수 있어 이 기본값이 안전하다.', false),
(13336, 4934, 'function f(x) { return x; }처럼 매개변수에 타입을 적지 않으면 그 자리에서 오류가 난다.', '표의 첫 행이 가리키는 상황 그대로다. 표기가 없으면 추론할 근거가 없어 암시적으로 any가 되는데, 이 옵션이 바로 그런 자리를 오류로 잡아 주므로 참인 진술이다.', false),
(13337, 4934, 'let x: any = JSON.parse(raw)처럼 any를 직접 적은 선언도 함께 오류로 걸러진다.', '이 옵션이 잡는 것은 표기가 없어 추론할 근거가 없는 자리뿐이라 거짓이다. 직접 적은 any는 의도로 보고 통과시키므로, 명시적 any는 범위를 한 줄로 좁히고 주석으로 의도를 남겨 따로 관리해야 한다.', true),
(13338, 4934, 'const n: number = null 같은 대입이 오류가 되어, null을 허용하려면 타입에 적어 두어야 한다.', '표의 세 번째 행대로 null이 별도 타입으로 다뤄져 number 자리에 그대로 들어가지 못한다. 허용하려면 number | null처럼 유니온에 적어야 하므로 참인 진술이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1600, 4935, 'any,애니,any 타입,애니 타입', 'as로 붙인 타입이 any이면 그 값은 어떤 멤버에 접근하든, 어디에 대입하든 검사를 건너뛴다. 더 큰 문제는 전염이다. any에서 꺼낸 값이 다시 any가 되는 탓에 오타나 구조 변경이 모듈 경계를 넘어가며 조용히 묻히고, 문자열에 toFixed를 부르는 줄까지 통과해 장애가 실행 시점에야 드러난다. 같은 자리에 unknown을 쓰면 값은 똑같이 무엇이든 받지만 typeof·in·instanceof로 확인하기 전에는 접근이 막히고 다른 타입 변수로 옮겨 담는 것도 막혀 번지지 않는다. 불가피하게 any를 써야 한다면 범위를 한 줄로 좁히고 의도를 주석으로 남긴다.'),
       (1601, 4936, '제네릭,제네릭스,제네릭 타입,generic,generics,타입 매개변수,type parameter', '인자로 받은 타입을 반환까지 그대로 이어 주려면 타입을 미리 고정하지 말고 호출 시점에 정해지도록 자리를 비워 두어야 한다. 그 자리를 만들어 주는 문법이 제네릭이다. any는 타입 관계를 잇는 대신 검사를 꺼 버려 오타가 통과하고, unknown은 검사를 살리는 대신 원래 타입 정보를 버려 호출부마다 단언을 요구한다. 셋 다 어떤 타입이든 받는다는 점은 같지만 받은 타입을 기억하는 것은 제네릭뿐이다. 여기에 extends로 제약을 걸면(예: <T, K extends keyof T>) 없는 키를 넘기는 실수까지 컴파일 단계에서 막을 수 있다.');

-- =====================================================
-- Lesson 950: any·unknown·never - 어디까지 막히고 어디부터 통과하는가
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5879, 950, '아래 코드에서 컴파일 오류가 발생하는 줄은?', '```typescript
type Guest = { name: string; token?: never };
type Member = { name: string; token: string };
type User = Guest | Member;

const a: User = { name: "김" };                  // (가)
const b: User = { name: "이", token: "t-01" };   // (나)
const c: Guest = { name: "박", token: "t-02" };  // (다)
const d: Member = { name: "최", token: "t-03" }; // (라)
```', 'OBJECTIVE'),
       (5880, 950, '아래 함수의 매개변수 표기를 any에서 unknown으로 바꿨을 때 일어나는 일로 옳은 것은?', '```typescript
function describe(v: any): string {
  const label: string = v;                         // (가)
  v.trim();                                        // (나)
  if (typeof v === "number") return v.toFixed(2);  // (다)
  return String(v);                                // (라)
}
```', 'OBJECTIVE'),
       (5881, 950, '아래 표의 선택에 대한 설명으로 옳지 않은 것은?', '| 상황 | 이 자리에 적는 것 |
|---|---|
| JSON.parse·fetch 응답처럼 런타임 구조가 보장되지 않는 값을 받을 때 | unknown |
| 예외를 던지고 끝나 정상 종료가 없는 함수의 반환 타입 | never |
| 어떤 타입이든 받아 그대로 돌려주는 함수의 매개변수·반환 타입 | 제네릭 T |
| JavaScript 코드를 옮기는 중 급히 빌드를 통과시켜야 하는 한 줄 | any |', 'OBJECTIVE'),
       (5882, 950, '아래 코드의 컴파일 결과로 옳은 것은?', '```typescript
function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null;
}

function greet(v: unknown): string {
  if (!isRecord(v)) return "";
  const name = v.name;        // (가)
  return name.toUpperCase();  // (나)
}
```', 'OBJECTIVE'),
       (5883, 950, '아래에서 팀이 tsconfig에 켠 옵션의 이름은?', '사내 도구를 JavaScript에서 TypeScript로 옮기며 tsconfig를 거의 비워 둔 채 시작했다. 반년이 지나자 send(to, body)처럼 매개변수에 타입을 적지 않은 함수가 400곳 가까이 쌓였고, 인자 순서를 바꿔 넘긴 호출까지 빌드를 그대로 통과했다. tsconfig에 옵션 한 줄을 켜자 바로 그 400여 곳이 한꺼번에 오류로 표시됐고, 함수 본문은 한 줄도 고치지 않고 매개변수마다 타입만 적어 넣자 오류가 모두 사라졌다. 같은 파일에서 let raw: any = JSON.parse(s) 줄은 옵션을 켜기 전과 똑같이 조용했다.', 'SUBJECTIVE'),
       (5884, 950, '아래에서 logStep의 반환 타입으로 되돌려 적은 타입의 이름은?', '메시지를 콘솔에 찍기만 하는 logStep과, 메시지를 찍은 뒤 곧바로 예외를 던지는 abort를 나란히 두었다. 편집기는 abort("중단"); save(); 에서 뒤 줄을 도달 불가 코드로 흐리게 표시하지만, logStep("시작"); save(); 에서는 뒤 줄에 아무 표시도 하지 않는다. 한번은 logStep의 반환 타입을 abort와 같은 타입으로 바꿔 적어 보았더니, const n: number = logStep("x") 처럼 말이 되지 않는 대입까지 오류 없이 통과해 버려 원래 적어 두었던 타입으로 되돌렸다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5879
(15851, 5879, '(가)', 'Guest의 token에는 물음표가 붙어 있어 아예 적지 않아도 된다. 유니온이면 양쪽 타입을 동시에 만족해야 한다고 본 오해로, 한쪽과만 맞아떨어져도 대입은 통과한다.', false),
(15852, 5879, '(나)', 'token 자리에 문자열이 들어갔으니 Member 쪽과 맞아떨어진다. 유니온 한쪽이 token을 막아 두면 token을 가진 객체는 아예 들어갈 수 없다고 본 오해.', false),
(15853, 5879, '(다)', '물음표는 프로퍼티를 생략해도 된다는 뜻일 뿐, 값을 넣는 순간 그 자리의 타입은 never다. never에 담을 수 있는 값은 하나도 없어 어떤 문자열도 대입되지 않는다. 특정 프로퍼티를 금지할 때 쓰는 표기다.', true),
(15854, 5879, '(라)', 'Member의 token은 string이라 문자열을 그대로 받는다. 유니온 한쪽에 적힌 표기가 다른 쪽 타입에도 함께 적용된다고 본 오해로, never가 붙은 것은 Guest뿐이다.', false),

-- 문제 5880
(15855, 5880, '(가)의 대입과 (나)의 메서드 호출이 새로 막히고, 좁히기를 지난 (다)와 String 호출인 (라)는 그대로 통과한다.', 'unknown은 구체 타입 자리에 그대로 들어가지 못하고 확인 전에는 멤버 접근도 막힌다. 반면 typeof로 number임을 확인한 뒤의 (다)는 허용되고, String은 어떤 값이든 인자로 받아 (라)도 문제없다.', true),
(15856, 5880, '네 줄이 모두 막혀 typeof 검사를 지난 (다)까지 함께 고쳐야 한다.', '좁히기가 any에만 통한다고 본 오해. unknown이야말로 typeof·instanceof로 확인하면 그 분기 안에서 구체 타입으로 확정돼 메서드 호출이 허용된다.', false),
(15857, 5880, '(나)의 메서드 호출만 막히고, 구체 타입 변수에 옮겨 담는 (가)는 바꾸기 전과 똑같이 통과한다.', 'unknown이 거는 제약이 멤버 접근뿐이라고 본 오해. 다른 타입 변수로 옮겨 담는 길까지 막혀 있어 검사 구멍이 옆 코드로 번지지 않는다.', false),
(15858, 5880, '달라지는 줄이 하나도 없다. 두 표기 모두 어떤 값이든 담으므로 뒤따르는 검사 결과도 같다.', '담을 수 있는 값의 범위는 같지만 담긴 뒤가 다르다. any는 확인을 생략하고 unknown은 확인을 강제하는 것이 두 표기를 가르는 지점이다.', false),

-- 문제 5881
(15859, 5881, '첫째 행대로 적으면 검증을 건너뛴 프로퍼티 접근이 빌드 단계에서 드러나, 응답 필드 이름이 바뀐 날 장애가 아니라 컴파일 오류로 먼저 나타난다.', 'unknown은 좁히기 전 멤버 접근을 막으므로 확인 없이 값을 꺼내 쓰던 줄이 한꺼번에 오류로 표시된다. 그래서 참인 진술이다.', false),
(15860, 5881, '둘째 행대로 적으면 그 함수를 호출한 줄 다음 코드가 도달 불가로 판정돼, 앞선 분기에서 값이 좁혀진 채로 이어진다.', 'never 반환은 정상 종료가 없다는 뜻이라 컴파일러가 그 뒤 흐름을 잘라 낸다. 덕분에 조건에 걸린 값이 빠진 채로 타입이 좁혀지므로 참인 진술이다.', false),
(15861, 5881, '넷째 행을 한 줄 범위로 좁혀 두지 않으면 그 값에서 파생된 값까지 검사를 건너뛰어 영향이 모듈 경계를 넘어 퍼진다.', 'any에서 꺼낸 값이 다시 any가 되는 성질 탓에 오타나 구조 변경이 옆 파일에서도 조용히 묻힌다. 그래서 참인 진술이며, 범위를 좁히고 의도를 주석으로 남기라는 권고가 붙는다.', false),
(15862, 5881, '셋째 행 자리에 제네릭 대신 unknown을 적어도 호출한 쪽은 넘긴 타입을 그대로 돌려받아 단언 없이 원래 멤버를 쓸 수 있다.', 'unknown으로 돌려주면 넘긴 타입 정보가 사라져 호출부마다 단언이나 좁히기를 다시 해야 하므로 거짓이다. 받은 타입을 기억해 그대로 이어 주는 것은 제네릭뿐이다.', true),

-- 문제 5882
(15863, 5882, '(가)에서 이미 막힌다. 타입 가드를 지나도 원래 표기가 그대로 남아 프로퍼티를 읽는 것부터 허용되지 않는다.', 'v is 표기가 붙은 함수를 통과하면 그 분기 안에서 v는 확정된 타입으로 다뤄져 프로퍼티를 읽을 수 있다. 좁히기가 함수 호출로는 일어나지 않는다고 본 오해.', false),
(15864, 5882, '(가)는 통과하지만 (나)에서 막힌다. 좁히기로 얻은 것은 값이 객체라는 사실뿐이고 꺼낸 프로퍼티는 다시 정체를 모르는 값이다.', '좁혀진 타입의 프로퍼티 타입이 unknown이라 v.name을 읽는 것까지는 되지만, 거기에 메서드를 부르려면 한 번 더 확인해야 한다. 확인은 값마다 따로 필요하다.', true),
(15865, 5882, '두 줄 모두 통과한다. 타입 가드를 한 번 지나면 그 값에서 꺼낸 것까지 검사가 함께 풀린다.', '확인 한 번으로 아래쪽 값까지 검사가 꺼진다고 본 오해로, 그것은 any에 해당하는 동작이다. 좁히기는 확인한 그 값에만 적용된다.', false),
(15866, 5882, 'isRecord를 선언한 줄에서 막힌다. 반환 자리에 boolean이 아닌 표기를 적었기 때문이다.', 'v is Record<string, unknown>은 참일 때 v의 타입을 함께 알려 주는 정식 반환 표기이고 실제 돌려주는 값은 boolean이다. 타입 가드 문법 자체를 오류로 본 오해.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1916, 5883, 'noImplicitAny,no implicit any,noImplicitAny 옵션', '표기가 없어 추론할 근거가 없는 자리를 오류로 잡아 주는 옵션이 noImplicitAny다. 매개변수에 타입을 적지 않으면 그 자리가 암시적으로 any가 되는데, 이 옵션이 바로 그런 자리만 짚어 주므로 본문을 건드리지 않고 표기를 채워 넣는 것만으로 오류가 사라진다. 반대로 직접 적어 둔 any는 의도로 보고 통과시키기 때문에 let raw: any 줄은 끝까지 조용하다. 명시적 any까지 줄이려면 린트 규칙을 따로 걸어야 한다. 같은 strict 묶음에 든 strictNullChecks(null·undefined를 별도 타입으로 다룸), useUnknownInCatchVariables(catch가 받는 예외 값을 unknown으로 정함)와는 하는 일이 다르니 구분한다.'),
       (1917, 5884, 'void,보이드,void 타입,보이드 타입', 'logStep은 돌려줄 값이 없을 뿐 정상적으로 끝나므로 반환 타입은 void다. never는 정상 종료 자체가 없는 함수에 붙는 타입이라, abort를 부른 줄 다음이 도달 불가 코드로 표시된다. 두 타입의 차이는 반환값의 유무가 아니라 정상 종료의 유무다. 또 never는 담을 수 있는 값이 없는 최하위 타입이어서 어떤 타입의 자리에도 대입되는데, 그래서 반환 타입을 never로 바꿔 적으면 number 변수에 담는 줄까지 통과해 버린다. void 값은 number 자리에 들어가지 못해 같은 줄이 오류로 걸리고, 이 차이가 두 타입을 가르는 실무 신호다.');
