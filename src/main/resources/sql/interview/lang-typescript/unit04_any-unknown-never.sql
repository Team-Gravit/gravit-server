-- Unit: any·unknown·never (Unit ID: 208)
-- Chapter: TypeScript (Chapter ID: 20)
-- Topic: TYPESCRIPT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-typescript-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1036, 'TYPESCRIPT', 208, 'HARD', true,
 '외부에서 받은 JSON 설정 문자열을 JSON.parse로 파싱해 사용하는 코드가 있습니다. 결과를 any 그대로 쓰면 어떤 문제가 생기고, 어떻게 개선하며, 불가피하게 any를 써야 할 때는 어떻게 해야 하나요?',
 'JSON.parse의 반환 타입은 any이기 때문에 파싱 결과를 그대로 쓰면 그 값이 any가 됩니다. any는 어떤 멤버에 접근하든 어디에 대입하든 오류가 나지 않아서, cfg.server.port처럼 접근할 때 오타나 구조 변경을 전혀 잡지 못합니다. 더 큰 문제는 any가 전염된다는 점입니다. any 값에서 파생된 값도 대부분 any가 되므로, 이 함수의 반환값과 그것을 쓰는 이후 코드까지 검사가 사라지고, port.toFixed(2) 같은 코드가 컴파일은 통과하지만 런타임에 TypeError를 낼 수 있습니다. 개선 방법은 파싱 결과를 unknown으로 받는 것입니다. unknown은 좁히기 전에는 멤버 접근이 불가능하므로 typeof, in 같은 검사로 객체인지, server 프로퍼티가 있는지, port가 number인지를 확인한 뒤에만 사용하게 되고, 형식이 맞지 않으면 에러를 던집니다. 또 unknown은 다른 타입에 대입되지 않아 전염되지도 않습니다. 마이그레이션 중 임시 우회처럼 불가피하게 any를 써야 한다면 그 범위를 한 줄로 최소화하고, eslint-disable-next-line 같은 주석으로 의도를 남깁니다. 아울러 tsconfig의 strict에 포함된 noImplicitAny를 켜 두면 암시적 any가 오류가 되므로 any가 곳곳에 숨어드는 것을 막을 수 있습니다.'),
(1037, 'TYPESCRIPT', 208, 'NORMAL', true,
 'TypeScript에서 any와 unknown은 어떤 차이가 있나요?',
 'any와 unknown은 둘 다 모든 값을 담을 수 있다는 점은 같습니다. 차이는 담긴 값으로 무엇을 할 수 있는가에 있습니다. any는 타입 검사를 끄는 스위치여서 어떤 멤버에 접근하든 어디에 대입하든 검사 없이 허용됩니다. 반면 unknown은 좁히기 전에는 멤버 접근이나 연산을 할 수 없어서, typeof나 instanceof 같은 검사로 값의 정체를 확인한 뒤에야 사용할 수 있습니다. 한 줄로 말하면 unknown은 쓰기 전에 확인을 강제하고 any는 확인을 생략합니다. 또 any는 어디든 대입되어 파생된 값까지 any로 전염되지만, unknown은 unknown과 any에만 대입할 수 있어 전염되지 않습니다. 그래서 API 응답이나 JSON.parse 결과, catch의 예외 객체처럼 외부에서 들어온 모르는 값은 unknown으로 받고, any는 JS 마이그레이션 중 임시 우회처럼 최소 범위로만 씁니다.'),
(1038, 'TYPESCRIPT', 208, 'NORMAL', true,
 '함수의 반환 타입으로 void와 never는 어떻게 다른가요?',
 'void는 반환값은 없지만 함수가 정상적으로 종료되는 경우의 반환 타입입니다. never는 어떤 값도 가질 수 없는 타입으로, 반환 타입으로 쓰이면 함수가 정상 종료 자체를 하지 않는다는 뜻입니다. 대표적으로 항상 예외를 던지는 fail(message) 같은 함수나 무한 루프에 빠지는 함수의 반환 타입이 never입니다. 반환 타입을 never로 두면 컴파일러가 그 함수 호출 이후의 코드는 도달 불가임을 인식합니다. 또 never는 유니온에 넣으면 사라지므로, env.PORT ?? fail(...)처럼 쓰면 결과 타입이 string | never, 즉 string이 되어 이후 코드에서 undefined를 따로 처리하지 않아도 됩니다.'),
(1039, 'TYPESCRIPT', 208, 'EASY', true,
 'never 타입을 이용한 완전성 검사가 어떻게 동작하는지 설명해 주세요.',
 '유니온 타입을 switch나 if로 좁혀 가면서 모든 멤버를 분기로 처리하고 나면, 남은 타입은 never가 됩니다. 예를 들어 Status가 "idle" | "loading" | "done"일 때 세 case를 모두 처리하면 default 분기에서 status의 타입은 never입니다. 이 남은 값을 const exhaustive: never = status처럼 never 타입 변수에 대입하거나 never 매개변수를 받는 함수에 넘겨 둡니다. 그러면 나중에 Status에 "error" 같은 멤버가 추가됐을 때 그 멤버가 처리되지 않고 default까지 내려와 never에 대입할 수 없게 되므로, 컴파일 오류로 누락을 알려 줍니다.'),
(1040, 'TYPESCRIPT', 208, 'EASY', true,
 '타입을 가능한 값의 집합으로 볼 때, TypeScript의 타입 계층에서 unknown과 never는 각각 어떤 위치에 있나요?',
 '타입을 가능한 값의 집합으로 보면 unknown은 모든 값을 포함하는 전체 집합, 즉 최상위 타입(Top Type)입니다. string, number, boolean, object 같은 타입이 모두 그 아래에 있습니다. 반대로 never는 아무 값도 없는 공집합, 즉 최하위 타입(Bottom Type)입니다. 공집합은 모든 집합의 부분집합이므로 never는 어떤 타입에도 대입할 수 있습니다. 참고로 any는 이 계층에서 벗어나 있어서 어떤 타입에도 대입되고 어떤 타입도 받으며 검사를 생략하는, 검사를 끄는 탈출구입니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1036
(5574, 1036, 'any 값에서 파생된 값도 any가 되어 검사 없는 상태가 전염됨을 설명', 'ESSENTIAL', 1),
(5575, 1036, '파싱 결과를 unknown으로 받고 좁히기로 구조를 검증한 뒤 사용하는 방법을 제시', 'ESSENTIAL', 2),
(5576, 1036, 'any가 불가피하면 사용 범위를 한 줄로 최소화함을 언급', 'ESSENTIAL', 3),
(5577, 1036, 'JSON.parse의 반환 타입이 any라서 파싱 결과가 any가 됨을 언급', 'SUPPLEMENTARY', 4),
(5578, 1036, 'strict에 포함된 noImplicitAny가 암시적 any를 오류로 만든다고 언급', 'SUPPLEMENTARY', 5),
(5579, 1036, 'any를 쓸 때 eslint-disable 주석 등으로 의도를 남긴다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1037
(5580, 1037, 'any와 unknown 모두 모든 값을 담을 수 있다고 언급', 'ESSENTIAL', 1),
(5581, 1037, 'unknown은 좁히기 전에는 멤버 접근·연산이 불가능함을 설명', 'ESSENTIAL', 2),
(5582, 1037, 'any는 멤버 접근·대입 시 타입 검사를 생략함을 설명', 'ESSENTIAL', 3),
(5583, 1037, 'unknown은 unknown·any에만 대입 가능해 전염되지 않음을 언급', 'SUPPLEMENTARY', 4),
(5584, 1037, 'API 응답·catch 예외 등 외부에서 들어온 값에는 unknown을 쓴다고 제시', 'SUPPLEMENTARY', 5),

-- 질문 1038
(5585, 1038, 'void는 반환값이 없지만 정상 종료되는 함수의 반환 타입이라고 설명', 'ESSENTIAL', 1),
(5586, 1038, 'never는 정상 종료 자체가 없는 함수의 반환 타입이라고 설명', 'ESSENTIAL', 2),
(5587, 1038, '항상 예외를 던지거나 무한 루프에 빠지는 함수를 never 반환의 예로 제시', 'ESSENTIAL', 3),
(5588, 1038, 'never 반환 함수 호출 이후 코드를 컴파일러가 도달 불가로 인식함을 언급', 'SUPPLEMENTARY', 4),
(5589, 1038, 'never가 유니온에서 사라져 string | never가 string이 됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1039
(5590, 1039, '유니온의 모든 멤버를 분기로 처리하면 남은 타입이 never가 됨을 설명', 'ESSENTIAL', 1),
(5591, 1039, '남은 값을 never 타입의 변수나 매개변수에 대입한다고 언급', 'ESSENTIAL', 2),
(5592, 1039, '유니온에 멤버가 추가되면 컴파일 오류로 처리 누락을 알려 줌을 언급', 'ESSENTIAL', 3),
(5593, 1039, 'switch의 default 분기에서 never 대입을 하는 예를 제시', 'SUPPLEMENTARY', 4),

-- 질문 1040
(5594, 1040, 'unknown은 모든 값을 포함하는 최상위 타입(Top Type)이라고 설명', 'ESSENTIAL', 1),
(5595, 1040, 'never는 아무 값도 없는 공집합인 최하위 타입(Bottom Type)이라고 설명', 'ESSENTIAL', 2),
(5596, 1040, 'never는 공집합이라 모든 타입에 대입 가능하다고 언급', 'SUPPLEMENTARY', 3),
(5597, 1040, 'any는 타입 계층 바깥에서 검사를 끄는 탈출구라고 언급', 'SUPPLEMENTARY', 4);
