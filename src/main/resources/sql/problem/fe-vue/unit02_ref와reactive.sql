-- Unit: ref와 reactive (Unit ID: 152)
-- Chapter: Vue.js (Chapter ID: 14)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (578, 152, 'ref 내부 구현과 shallowRef'),
       (736, 152, '템플릿 언박싱과 객체 재할당'),
       (894, 152, 'ref와 reactive: 연결을 지키는 상자와 추적을 우회하는 코드');

-- =====================================================
-- Lesson 578: ref 내부 구현과 shallowRef
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3647, 578, '아래 코드의 콘솔 출력으로 옳은 것은?', '```typescript
import { ref, reactive } from "vue"

const count = ref(0)
const state = reactive({ count })
const list = reactive([ref(10)])

state.count++
console.log(count.value, state.count, list[0].value)
```', 'OBJECTIVE'),
       (3648, 578, '아래 반응형 API에 대한 설명으로 옳은 것은?', 'Proxy는 객체만 감쌀 수 있어 `new Proxy(1, {})`는 곧바로 오류가 난다. 그래서 이 API는 전달받은 값을 직접 감싸지 않는다. `value` 속성 하나만 가진 객체를 새로 만든 뒤, 그 속성에 getter와 setter를 심어 읽기와 쓰기를 가로챈다.', 'OBJECTIVE'),
       (3649, 578, '아래 표에서 화면 갱신 여부가 갈린 이유로 옳지 않은 것은?', '| 코드 | 화면 갱신 |
|---|---|
| `const a = ref(0)` 뒤에 `a.value = 5` | 갱신됨 |
| `const s = reactive({ n: 0 })` 뒤에 `let { n } = s; n = 5` | 갱신 안 됨 |
| `const s = reactive({ n: 0 })` 뒤에 `Object.assign(s, { n: 5 })` | 갱신됨 |
| `let s = reactive({ n: 0 })` 뒤에 `s = reactive({ n: 5 })` | 갱신 안 됨 |', 'OBJECTIVE'),
       (3650, 578, '아래 두 버전의 반응성 구현 차이에서 따라 나오는 결과로 옳은 것은?', '```typescript
// Vue 2 — data가 돌려준 객체의 속성마다 Object.defineProperty로
// getter와 setter를 심어 원본 객체 자체를 반응형으로 바꾼다
export default { data() { return { user: { name: "김철수" } } } }

// Vue 3 — 원본은 그대로 두고, 원본을 감싼 별도의 Proxy를 만들어 돌려준다
const raw = { name: "김철수" }
const state = reactive(raw)
```', 'OBJECTIVE'),
       (3651, 578, '아래 코드의 (A) 자리에 넣어 문제를 해결한 Vue 내장 함수의 이름은?', '```typescript
// composables/useTimer.ts
export function useTimer() {
  const state = reactive({ seconds: 0 })
  setInterval(() => state.seconds++, 1000)
  return state
}

// 사용처 — 화면의 {{ seconds }}가 0에서 멈춰 있다
const { seconds } = useTimer()

// 컴포저블의 return 문만 아래처럼 바꾸자
// 사용처 코드는 그대로인데 1초마다 숫자가 올라갔다
return (A)(state)
```', 'SUBJECTIVE'),
       (3652, 578, '아래 상황에서 ref 대신 사용한 Vue 반응형 API의 이름은?', '1만 행짜리 표 데이터를 `ref([])`에 담아 렌더했더니, 응답을 받은 뒤 화면이 그려지기까지 820ms가 걸렸다. 프로파일러에는 응답 객체의 중첩 필드를 하나하나 훑는 변환 작업이 대부분의 시간으로 잡혔다. 선언 한 줄만 다른 API로 바꾸자 같은 데이터에서 90ms로 줄었다. 대신 `rows.value[0].name = "변경"`처럼 안쪽 값만 고칠 때는 화면이 그대로여서, 갱신을 강제로 알리는 함수를 따로 불러야 했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3647
(9899, 3647, '0 1 10', 'reactive가 ref를 값으로 복사해 담는다고 본 것. reactive 객체의 속성에 담긴 ref는 원본과 같은 상자를 공유하므로 state.count를 올리면 count.value도 함께 1이 된다.', false),
(9900, 3647, '1 1 10', 'reactive 객체의 속성으로 담긴 ref는 자동 언박싱돼 state.count++가 곧 count.value++다. 반면 reactive 배열 안의 ref는 언박싱 예외라 list[0]은 상자 그대로여서 .value로 읽어야 10이 나온다.', true),
(9901, 3647, '1 1 undefined', '배열 안의 ref도 자동 언박싱된다고 본 것. 언박싱은 객체 속성에만 적용되고 배열과 Map은 예외라 list[0]은 여전히 ref이므로 .value가 10을 돌려준다.', false),
(9902, 3647, '0 NaN 10', 'reactive 안에 담긴 ref에도 .value를 붙여야 한다고 본 것. 그렇다면 state.count는 상자 객체라 ++가 NaN이 되겠지만, 실제로는 언박싱돼 숫자 연산이 정상 동작한다.', false),

-- 문제 3648
(9903, 3648, '감쌀 수 있는 대상이 객체와 배열, Map으로 제한돼 숫자나 문자열은 담을 수 없다.', '원시값을 다루려고 상자를 만드는 API인데 그 반대로 본 것. 객체만 감쌀 수 있다는 제한은 Proxy를 그대로 쓰는 reactive 쪽의 특징이다.', false),
(9904, 3648, '템플릿 안에서는 어디에 두든 자동으로 풀리므로 속성 표기를 붙일 일이 없다.', '자동 언박싱은 템플릿의 최상위 참조에만 적용된다. 다른 객체의 속성으로 중첩되거나 reactive 배열에 담기면 .value를 그대로 붙여야 한다.', false),
(9905, 3648, '담긴 값을 새 값으로 통째로 바꾸면 추적 연결이 끊겨 화면이 갱신되지 않는다.', '재할당으로 연결이 끊기는 것은 Proxy를 변수에 담아 쓰는 reactive 쪽 이야기다. 상자는 그대로 두고 안의 값만 바뀌므로 .value 교체는 오히려 안전한 갱신 방법이다.', false),
(9906, 3648, '객체를 담으면 그 객체는 내부에서 다시 Proxy로 변환돼 중첩 속성까지 추적된다.', '상자에 객체를 넣으면 내부적으로 reactive를 한 번 거쳐 보관하므로, .value 아래 중첩된 속성의 변경까지 깊게 추적된다. 상자 하나로 원시값과 객체를 모두 다룰 수 있는 이유다.', true),

-- 문제 3649
(9907, 3649, '넷째 줄은 재할당으로 새 Proxy가 만들어지지 않아 추적할 대상이 사라지기 때문이다.', '새 Proxy는 정상적으로 만들어진다. 변수만 새 Proxy를 가리킬 뿐 템플릿은 처음 구독한 옛 Proxy를 붙잡고 있어 갱신이 끊긴다. 교체가 필요하면 Object.assign으로 기존 Proxy를 채우거나 처음부터 ref로 감싼다.', true),
(9908, 3649, '첫째 줄은 value의 setter가 쓰기를 가로채 트리거를 부르므로 원시값도 추적된다.', 'ref는 상자의 value 속성에 getter와 setter를 심는다. Proxy가 감쌀 수 없는 숫자여도 상자를 거치는 한 변경이 통보되므로 갱신이 일어난다.', false),
(9909, 3649, '둘째 줄은 구조 분해가 Proxy의 읽기를 한 번만 거쳐 값을 복사하기 때문이다.', '구조 분해 결과는 Proxy와 무관한 일반 변수라 이후 대입은 아무도 보지 못한다. 원본과의 연결을 유지하려면 toRefs로 속성을 상자 형태로 꺼내야 한다.', false),
(9910, 3649, '셋째 줄은 Object.assign이 기존 Proxy의 속성에 그대로 쓰기 때문이다.', '대상 객체가 바뀌지 않고 같은 Proxy의 속성에 값이 들어가므로 쓰기 가로채기가 정상 동작한다. reactive 상태를 통째로 갈아끼울 때 쓰는 우회로가 되는 이유다.', false),

-- 문제 3650
(9911, 3650, 'Vue 2.7에서 Composition API를 백포트하면서 감지 방식도 Proxy로 바뀌어 나중에 추가한 키까지 추적된다.', '문법만 백포트됐고 내부 구현은 여전히 Object.defineProperty다. 선언 시점에 없던 키는 그대로 감지되지 않아 $set 같은 우회가 필요하다.', false),
(9912, 3650, 'Vue 2에서도 원시값을 상자에 담아 .value로 접근했으므로 언박싱 규칙은 두 버전이 같다.', 'Vue 2의 원시값은 data 객체의 속성으로만 존재해 상자 개념 자체가 없었다. 언박싱은 상자를 도입한 Vue 3에서 새로 생긴 규칙이다.', false),
(9913, 3650, 'Vue 3에서는 reactive(raw) === raw 비교가 거짓이지만, Vue 2에서 변환된 객체는 원본과 같은 객체다.', '원본을 감싼 새 Proxy를 돌려주므로 동일성 비교 결과가 갈린다. 같은 이유로 Vue 3에서는 raw를 직접 고치면 Proxy를 거치지 않아 변경이 추적되지 않는다.', true),
(9914, 3650, 'Vue 3는 원본과 Proxy를 두 벌로 복사해 두므로 원본을 직접 고치면 두 값이 서로 어긋난다.', 'Proxy는 원본을 복사하지 않고 같은 객체를 대상으로 삼는다. 값은 어긋나지 않으며, 다만 Proxy를 우회한 변경이라 추적되지 않을 뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1172, 3651, 'toRefs,toRefs(),토레프스', '구조 분해는 Proxy의 읽기를 한 번만 거쳐 값을 복사하므로 그 뒤로는 원본과 연결이 끊긴다. toRefs는 reactive 객체의 각 속성을 원본을 다시 읽는 getter를 가진 상자로 바꿔 돌려주므로, 구조 분해한 뒤에도 seconds가 원본 state.seconds를 계속 따라간다. 템플릿 최상위에서는 자동 언박싱돼 {{ seconds }} 그대로 쓸 수 있다. 속성 하나만 연결할 때 쓰는 toRef와, 이미 상자인 값을 만드는 ref와는 쓰임이 다르다.'),
       (1173, 3652, 'shallowRef,shallowRef(),shallow ref', '기본 ref는 담긴 객체의 중첩 속성까지 모두 Proxy로 변환하는 깊은 반응성이라 대용량 데이터에서 변환 비용이 크다. shallowRef는 .value 교체만 추적하고 그 아래는 변환하지 않으므로 820ms가 90ms로 줄어든다. 대신 안쪽 값 변경은 감지되지 않아 triggerRef로 직접 알려야 한다. 최상위 속성까지만 추적하는 shallowReactive, 아예 반응형 변환 대상에서 빼는 markRaw와 구분한다.');

-- =====================================================
-- Lesson 736: 템플릿 언박싱과 객체 재할당
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4595, 736, '아래 컴포넌트를 렌더했을 때 A·B·C 줄에 표시되는 값으로 옳은 것은?', '```vue
<script setup>
import { ref, reactive } from "vue"

const count = ref(1)
const plain = { n: ref(2) }
const state = reactive({ n: ref(3) })
</script>

<template>
  <p>A: {{ count + 1 }}</p>
  <p>B: {{ plain.n + 1 }}</p>
  <p>C: {{ state.n + 1 }}</p>
</template>
```', 'OBJECTIVE'),
       (4596, 736, '아래 반응형 API를 사용했을 때 따라 나오는 결과로 옳은 것은?', '이 API는 전달받은 객체를 Proxy로 감싸 돌려주지만, 가로채는 대상은 최상위 속성의 읽기와 쓰기뿐이다. 속성값이 또 다른 객체여도 꺼낼 때 다시 감싸지 않고 보관해 둔 것을 그대로 돌려준다.', 'OBJECTIVE'),
       (4597, 736, '아래 두 구조 분해의 결과가 갈린 이유로 옳은 것은?', '```typescript
import { ref, reactive } from "vue"

const a = { count: ref(0) }
const b = reactive({ count: 0 })

const { count: fromA } = a
const { count: fromB } = b

fromA.value++   // 화면의 값이 1로 바뀐다
fromB++         // 화면의 값은 0 그대로다
```', 'OBJECTIVE'),
       (4598, 736, '아래 코드에서 마지막 줄이 출력하는 값으로 옳은 것은?', '```typescript
import { ref, reactive, isRef, isReactive } from "vue"

const a = reactive(0)
const b = ref(0)
const c = reactive({ n: 0 })

// 실행하면 아래 경고가 한 줄 먼저 찍힌다
// [Vue warn] value cannot be made reactive: 0

console.log(isReactive(a), isRef(b), isReactive(c))
```', 'OBJECTIVE'),
       (4599, 736, '아래 상황에서 대입문을 대신해 쓴 자바스크립트 내장 메서드의 이름은?', '```typescript
let filters = reactive({ keyword: "", page: 1 })

function apply(next) {
  filters = reactive(next)
}
```

apply({ keyword: "노트북", page: 1 })을 부른 뒤 콘솔에 filters.keyword를 찍으면 노트북이 나오는데, 화면의 {{ filters.keyword }}는 처음의 빈 값 그대로였다. 반응형 객체 선언과 템플릿은 손대지 않고 함수 본문 한 줄만 내장 메서드 호출로 바꾸자, 같은 템플릿이 곧바로 노트북으로 바뀌었다.', 'SUBJECTIVE'),
       (4600, 736, '아래 상황에서 인스턴스를 담기 전에 한 번 통과시킨 Vue 함수의 이름은?', '지도 라이브러리 인스턴스를 state.map = new MapView(el)처럼 반응형 객체의 속성에 담았다. 지도를 드래그하면 프레임이 눈에 띄게 끊겼고, 프로파일러에는 인스턴스 안쪽 수천 개 노드를 훑는 변환 작업이 시간의 대부분으로 잡혔다. 게다가 라이브러리가 내부에서 === 로 비교하던 값이 어긋나 마커 클릭이 엉뚱한 좌표를 집었다. 반응형 객체 선언은 그대로 둔 채 인스턴스를 속성에 담기 전에 Vue 함수 하나를 한 번 통과시키자 두 증상이 모두 사라졌고, new로 만든 원본과 state.map을 === 로 비교하면 참이 나왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4595
(12427, 4595, 'A: 2 / B: 3 / C: 4', '템플릿 안이면 상자가 어디에 있든 모두 풀린다고 본 것. 자동 언박싱은 템플릿의 최상위 참조와 반응형 객체의 속성에만 적용되고, 일반 객체의 속성에 담긴 상자는 그대로 남는다.', false),
(12428, 4595, 'A: 2 / B: [object Object]1 / C: 4', 'count는 최상위라 컴파일러가 풀어 2가 되고, state.n은 반응형 객체의 속성이라 풀려 4가 된다. plain은 일반 객체여서 상자가 그대로 남고, 더하기가 숫자 연산이 아니라 문자열 이어붙이기가 된다.', true),
(12429, 4595, 'A: 2 / B: [object Object]1 / C: [object Object]1', '반응형 객체의 속성에 담긴 상자도 풀리지 않는다고 본 것. 객체의 속성은 자동 언박싱 대상이라 state.n은 3으로 읽힌다. 예외로 기억할 곳은 반응형 배열과 Map 안이다.', false),
(12430, 4595, 'A: 2 / B: 3 / C: [object Object]1', '언박싱되는 자리를 거꾸로 기억한 것. 일반 객체의 속성은 풀리지 않고 반응형 객체의 속성은 풀리므로, B와 C에 적힌 결과가 서로 뒤바뀌어야 한다.', false),

-- 문제 4596
(12431, 4596, '숫자나 문자열도 그대로 넘길 수 있어 원시값 상태를 .value 없이 다룰 수 있다.', 'Proxy는 대상이 객체일 때만 만들어지므로 원시값을 넘기면 경고와 함께 원본이 그대로 돌아온다. 원시값을 담아 추적하려면 value 속성에 getter와 setter를 둔 상자, 곧 ref가 필요하다.', false),
(12432, 4596, '구조 분해로 최상위 속성을 꺼내도 각 속성이 상자로 나와 원본과 연결이 유지된다.', '가로채기는 속성에 접근하는 순간에만 일어나므로 꺼낸 값은 Proxy 밖의 일반 변수가 된다. 속성을 상자 형태로 바꿔 연결을 유지하려면 toRefs를 거쳐야 하고, 이는 변환 깊이와 무관하다.', false),
(12433, 4596, '최상위 속성을 다른 값으로 바꿔도 추적되지 않아 갱신을 알리는 함수를 따로 불러야 한다.', '최상위 속성의 쓰기는 그대로 가로채므로 화면이 갱신된다. 수동 트리거가 필요한 쪽은 얕은 상자에 담긴 값의 안쪽만 고쳐 .value 교체가 일어나지 않은 경우다.', false),
(12434, 4596, '중첩된 객체를 꺼내 원본의 같은 속성과 비교하면 서로 같은 객체로 판정된다.', '깊게 변환하는 쪽은 중첩 객체를 꺼낼 때마다 새 Proxy로 감싸 돌려주어 원본과 동일성이 깨진다. 감싸지 않고 돌려주면 비교가 참이 되고, 그 대신 중첩 속성의 변경은 추적되지 않는다.', true),

-- 문제 4597
(12435, 4597, '꺼낸 것이 한쪽은 읽기와 쓰기를 가로채는 상자 자체이고, 다른 쪽은 그 순간 복사된 숫자이기 때문이다.', '구조 분해는 속성을 한 번 읽어 그 결과를 새 변수에 담는다. 결과가 상자면 이후 조작이 상자의 setter를 거쳐 통보되지만, 숫자면 원본과 무관한 값이라 아무도 변경을 알지 못한다.', true),
(12436, 4597, 'Proxy가 구조 분해 구문을 가로채지 못해 b의 속성 읽기가 처음부터 추적되지 않기 때문이다.', '구조 분해도 결국 속성 읽기라 그 순간에는 Proxy를 거쳐 추적된다. 문제는 그 뒤 fromB가 Proxy 밖의 변수여서 증가가 아무에게도 통보되지 않는다는 점이다.', false),
(12437, 4597, 'a가 일반 객체라 Vue가 접근 시점에 a 전체를 깊은 반응형으로 승격시키기 때문이다.', 'Vue는 일반 객체를 알아서 반응형으로 바꾸지 않는다. a 쪽이 통한 이유는 객체가 아니라 속성에 담긴 상자가 처음부터 추적 통로를 갖고 있어서다.', false),
(12438, 4597, 'b의 속성값이 원시값이라 Proxy로 감쌀 수 없어 애초에 추적 대상에서 빠지기 때문이다.', 'Proxy가 감싸는 대상은 속성값이 아니라 객체 b다. 속성이 숫자여도 b.count++처럼 객체를 거치는 접근은 정상 추적되므로, 객체를 우회한 것이 원인이다.', false),

-- 문제 4598
(12439, 4598, 'true true true', '경고를 흘려보내고 원시값도 Proxy로 감싸진다고 본 것. 대상이 객체가 아니면 Proxy 자체를 만들 수 없어 0은 감싸지지 못하고 원본이 그대로 돌아온다.', false),
(12440, 4598, 'false false true', 'ref가 내부에서 Proxy를 만든다고 보아 b를 상자가 아닌 반응형 객체로 본 것. ref가 만드는 것은 value 속성에 getter와 setter를 둔 상자라 isRef 쪽에서 참이 된다.', false),
(12441, 4598, 'false true true', '0은 객체가 아니어서 경고와 함께 원본이 그대로 돌아오므로 a는 반응형이 아니다. 상자를 만드는 ref는 원시값도 담을 수 있어 참이고, 객체를 받은 c만 Proxy로 감싸져 참이 된다.', true),
(12442, 4598, 'false true false', 'reactive가 원본 객체 자체를 고쳐 돌려준다고 본 Vue 2식 이해. Vue 3는 원본을 감싼 새 Proxy를 돌려주고 참으로 판정되는 쪽은 그 Proxy이며, 원본을 그대로 검사하면 거짓이 나온다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1488, 4599, 'Object.assign,Object.assign(),assign', 'reactive가 돌려준 Proxy를 담은 변수에 새 Proxy를 다시 대입하면 변수만 새 것을 가리키고, 템플릿이 처음 구독한 옛 Proxy에는 아무 일도 일어나지 않아 화면이 멈춘다. Object.assign(filters, next)는 기존 Proxy의 속성에 값을 쓰므로 쓰기 가로채기가 그대로 동작해 구독이 유지된다. 구조 분해로 끊긴 연결을 다시 잇는 toRefs와는 쓰임이 다르고, 통째 교체가 잦은 상태라면 처음부터 ref에 담아 .value를 바꾸는 편이 안전하다.'),
       (1489, 4600, 'markRaw,markRaw(),mark raw', '반응형 객체는 속성에서 꺼낸 객체를 다시 Proxy로 감싸 돌려주므로, 외부 라이브러리 인스턴스를 담으면 깊은 변환 비용이 들고 원본과의 동일성이 깨져 라이브러리 내부의 === 비교가 어긋난다. markRaw는 그 객체를 반응형으로 만들지 말라는 표시를 남겨 reactive와 ref가 변환을 건너뛰게 한다. 최상위 속성이나 .value 교체까지는 추적하는 shallowReactive·shallowRef와 달리 표시된 객체는 아예 추적되지 않으므로, 그 값의 변경만으로 화면을 갱신할 수는 없다.');

-- =====================================================
-- Lesson 894: ref와 reactive: 연결을 지키는 상자와 추적을 우회하는 코드
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5543, 894, '아래 코드를 실행했을 때 콘솔 출력으로 옳은 것은?', '```typescript
import { ref, reactive, toRef } from "vue"

const state = reactive({ count: 0 })
const a = toRef(state, "count")
const b = ref(state.count)

a.value++
b.value += 10
state.count += 100

console.log(state.count, a.value, b.value)
```', 'OBJECTIVE'),
       (5544, 894, '아래 코드의 (1)~(4)를 각각 처음 상태에서 따로 실행할 때, 화면 갱신을 일으키는 줄만 모두 고른 것은?', '```typescript
import { shallowRef, triggerRef } from "vue"

// 템플릿은 todos의 각 항목을 title과 done으로 목록에 그린다
const todos = shallowRef([{ title: "장보기", done: false }])

todos.value[0].done = true                                    // (1)
todos.value.push({ title: "운동", done: false })               // (2)
todos.value = [...todos.value, { title: "독서", done: false }] // (3)
todos.value[0].title = "마트"; triggerRef(todos)               // (4)
```', 'OBJECTIVE'),
       (5545, 894, '아래 팀 규칙에 따라 상태를 선언할 때 따라 나오는 결과로 옳은 것은?', '팀은 새로 작성하는 컴포넌트 상태를 공식 문서가 기본값으로 권장하는 반응형 API 하나로만 선언하기로 했다. 이 API는 숫자·문자열 같은 원시값과 객체를 모두 담을 수 있고, API 응답처럼 값을 통째로 바꿔 넣어도 화면과의 연결이 유지된다. 컴포저블이 이 API로 만든 값들을 객체에 담아 돌려주면, 사용처에서 구조 분해해 꺼내도 반응성이 남는다.', 'OBJECTIVE'),
       (5546, 894, '아래 컴포넌트에서 B → A → B 순서로 버튼을 누를 때, 각 클릭 직후 화면에 표시되는 숫자로 옳은 것은?', '```vue
<script setup>
import { reactive } from "vue"

const raw = { count: 0 }
const state = reactive(raw)
</script>

<template>
  <p>{{ state.count }}</p>
  <button @click="raw.count++">A</button>
  <button @click="state.count++">B</button>
</template>
```', 'OBJECTIVE'),
       (5547, 894, '아래 상황의 결과 차이를 만든 Vue 동작을 가리키는 용어는?', '주문 화면에서 `const qty = ref(2)`를 선언하고 같은 계산을 여러 곳에서 해 보았다.

- 템플릿의 `{{ qty * 10 }}` → 화면에 20
- `<script>`의 `console.log(qty * 10)` → NaN
- `const order = reactive({ qty })` 뒤 스크립트의 `order.qty * 10` → 20
- `const lines = reactive([qty])` 뒤 스크립트의 `lines[0] * 10` → NaN

어느 곳에서도 qty의 값은 바꾸지 않았다.', 'SUBJECTIVE'),
       (5548, 894, '아래 상황에서 먼저 쓰던 버전의 반응형 객체가 내부적으로 사용한 자바스크립트 내장 API의 이름은?', 'Vue 2.7 프로젝트에서 Composition API로 상태를 만들었다.

```javascript
import { reactive } from "vue"

const raw = { name: "김철수" }
const state = reactive(raw)

console.log(state === raw)   // true
state.age = 20               // 템플릿의 {{ state.age }}는 빈 채로 갱신되지 않음
```

같은 코드를 Vue 3 프로젝트로 옮기자 `state === raw`는 false가 되었고, 나중에 추가한 age도 곧바로 화면에 나타났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5543
(14955, 5543, '111 111 111', 'ref(state.count)도 원본과 연결된다고 본 것. state.count는 읽는 순간 숫자 0을 꺼내 넘기므로 b는 그 값을 담은 새 상자일 뿐이고, 원본의 변화와도 a의 변화와도 무관하다.', false),
(14956, 5543, '100 1 10', 'toRef도 만드는 순간의 값을 복사한다고 본 것. toRef가 만든 상자는 value를 읽고 쓸 때마다 원본 Proxy의 count를 거치므로, a.value++이 곧 state.count++가 된다.', false),
(14957, 5543, '101 101 10', 'a는 원본의 count를 다시 읽고 쓰는 상자라 a.value++과 state.count += 100이 같은 값에 쌓여 둘 다 101이다. b는 ref가 호출 시점의 숫자 0을 받아 만든 별개 상자라 10에 머문다.', true),
(14958, 5543, '100 100 10', 'toRef의 연결이 원본에서 상자로 가는 한 방향뿐이라고 본 것. a.value에 쓰면 setter가 원본 Proxy의 count에 그대로 쓰므로 증가분 1도 원본에 남아 101이 된다.', false),

-- 문제 5544
(14959, 5544, '(3), (4)', '얕은 상자는 .value 교체만 가로채므로 새 배열을 대입한 (3)이 트리거된다. (4)는 안쪽만 바꿨지만 triggerRef가 이 상자에 의존하는 렌더를 강제로 다시 실행해 바뀐 title이 함께 그려진다.', true),
(14960, 5544, '(3)만', 'triggerRef의 역할을 놓친 것. .value 교체가 없어도 triggerRef는 이 상자를 구독한 렌더를 직접 다시 실행시키므로, 안쪽에서 고쳐 둔 title이 화면에 반영된다.', false),
(14961, 5544, '(2), (3), (4)', '배열 메서드는 따로 가로챈다고 본 것. shallowRef는 .value에 담긴 배열을 Proxy로 바꾸지 않으므로 push는 일반 배열 조작일 뿐이고, .value 자체도 그대로라 트리거가 없다.', false),
(14962, 5544, '(1), (2), (3), (4)', '기본 ref처럼 깊게 추적된다고 본 것. 얕은 상자는 안쪽 객체와 배열을 반응형으로 변환하지 않아, (1)·(2)처럼 .value 아래만 바꾼 조작은 화면에 알려지지 않는다.', false),

-- 문제 5545
(14963, 5545, '여러 필드를 묶은 폼 상태도 form.name처럼 속성 이름만으로 바로 읽고 쓸 수 있다.', '일반 객체처럼 바로 접근하는 것은 Proxy를 돌려주는 reactive의 특징이다. 이 API는 폼 객체를 상자에 담으므로 스크립트에서는 form.value.name처럼 상자를 한 번 거쳐야 한다.', false),
(14964, 5545, '배열을 담으면 통째 교체만 추적되고, 요소 안쪽 속성을 바꾼 것은 화면에 반영되지 않는다.', '.value 교체만 추적하는 shallowRef와 혼동한 것. 기본값으로 쓰는 이 API는 객체나 배열을 넣으면 내부에서 reactive로 변환해 보관하므로 요소 안쪽 속성 변경까지 깊게 추적된다.', false),
(14965, 5545, 'TypeScript에서 담은 값의 원본 타입이 그대로 추론돼, 감싼 타입을 따로 다룰 일이 없다.', '원본 타입이 그대로 추론되는 것은 reactive 쪽이다. 이 API는 Ref<T> 같은 상자 타입으로 추론돼, 다루는 대상이 상자인지 안의 값인지가 타입에 그대로 드러난다.', false),
(14966, 5545, '<script>에서 읽고 쓸 때는 .value를 붙여야 하지만, 템플릿 최상위에서는 생략할 수 있다.', '원시값까지 담으려고 value 속성을 가진 상자를 쓰는 대가로 스크립트에서는 .value가 필요하다. 템플릿에서는 컴파일러가 최상위 상자를 자동으로 풀어 준다. 기본값으로 권장되는 ref의 트레이드오프다.', true),

-- 문제 5546
(14967, 5546, '1 → 2 → 3', 'Proxy가 원본과 같은 객체를 대상으로 하니 원본을 고쳐도 추적된다고 본 것. 값은 같은 객체에 쌓이지만 가로채기는 Proxy를 거친 쓰기에서만 일어나, A 직후에는 화면이 그대로다.', false),
(14968, 5546, '1 → 1 → 3', 'A는 Proxy를 우회해 원본에 직접 쓰므로 트리거가 없어 화면이 1에 머문다. 그래도 값은 같은 객체에 2로 쌓여 있어, 이어진 B가 Proxy로 2를 읽고 3을 쓰며 트리거해 3이 표시된다.', true),
(14969, 5546, '1 → 1 → 2', 'Proxy가 원본을 따로 복사해 둔다고 본 것. Proxy는 복사본 없이 원본 객체를 그대로 대상으로 삼으므로, B는 A가 원본에 올려 둔 2를 읽어 3을 쓴다.', false),
(14970, 5546, '1 → 1 → 1', '원본을 직접 고친 순간 Proxy와의 연결이 영영 끊긴다고 본 것. 우회한 그 쓰기 한 번이 추적되지 않을 뿐, 이후 Proxy를 거친 B의 쓰기는 정상적으로 트리거된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1804, 5547, '언박싱,자동 언박싱,언래핑,자동 언래핑,unwrapping,auto unwrapping,ref unwrapping,unwrap,unboxing,ref 언박싱', 'ref는 놓인 자리에 따라 .value 없이도 안의 값이 바로 꺼내지는데, 이를 (자동) 언박싱이라 한다. 템플릿의 최상위 ref와 reactive 객체의 속성으로 담긴 ref는 풀려 숫자 2로 계산되지만, <script>에서 직접 쓴 ref와 reactive 배열·Map 안의 ref는 풀리지 않아 상자 객체가 곱셈에 들어가 NaN이 된다. 값을 읽고 쓸 때 의존성을 기록하고 알리는 추적·트리거와는 다른 개념으로, 상자에서 값을 꺼내는 방식에 관한 규칙이다. 템플릿이라도 일반 객체의 속성으로 중첩된 ref는 풀리지 않는다는 점도 같은 규칙에서 나온다.'),
       (1805, 5548, 'Object.defineProperty,Object.defineProperty(),defineProperty,defineProperty()', 'Vue 2.7은 Composition API 문법만 백포트했을 뿐 반응성 구현은 여전히 Object.defineProperty로, 원본 객체에 이미 있는 속성마다 getter·setter를 심는 방식이다. 그래서 원본 자체가 변환돼 state === raw가 참이고, 선언 시점에 없던 age는 가로챌 접근자가 없어 추가해도 화면이 갱신되지 않는다. Vue 3의 reactive는 원본을 감싼 별도의 Proxy를 돌려주므로 비교가 거짓이 되고, 객체 단위로 접근을 가로채 새 키 추가까지 추적한다. 이미 있는 속성 하나하나에 걸리는 defineProperty와 객체 전체의 접근을 가로채는 Proxy의 차이가 경계다.');
