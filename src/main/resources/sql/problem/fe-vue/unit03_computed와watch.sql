-- Unit: computed와 watch (Unit ID: 153)
-- Chapter: Vue.js (Chapter ID: 14)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (579, 153, '파생 값 캐싱과 감시 소스 지정'),
       (737, 153, 'flush 시점과 await 뒤 추적 누락'),
       (895, 153, 'computed와 watch 심화: 메서드와의 차이·쓰기 가능한 computed·감시 범위와 해제');

-- =====================================================
-- Lesson 579: 파생 값 캐싱과 감시 소스 지정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3653, 579, '아래 코드를 실행했을 때 콘솔에 calc가 출력되는 횟수는?', '```typescript
const price = ref(1000)
const qty = ref(2)

const total = computed(() => {
  console.log(''calc'')
  return price.value * qty.value
})

console.log(total.value)
console.log(total.value)
qty.value = 3
qty.value = 4
console.log(total.value)
console.log(total.value)
```', 'OBJECTIVE'),
       (3654, 579, '아래 코드에서 감시 콜백이 한 번도 실행되지 않는 원인으로 옳은 것은?', '```typescript
const state = reactive({ count: 0 })

watch(state.count, (newVal) => {
  console.log(''changed:'', newVal)
})

state.count = 1
state.count = 2
```

실행해도 콘솔에는 changed가 한 번도 찍히지 않는다.', 'OBJECTIVE'),
       (3655, 579, '위 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | `watch` | `watchEffect` |
| --- | --- | --- |
| 의존성 지정 | 감시할 소스를 직접 지정 | 콜백에서 읽은 값을 자동 추적 |
| 최초 실행 | 지연(`immediate` 옵션으로 변경) | 등록 즉시 1회 실행 |
| 이전 값 접근 | 가능(`(newVal, oldVal)`) | 불가능 |
| 반환값 | 감시 해제 함수 | 감시 해제 함수 |', 'OBJECTIVE'),
       (3656, 579, '아래 파생 값을 화면에 출력했을 때 나타나는 동작으로 옳은 것은?', '```typescript
const clock = computed(() => new Date().toLocaleTimeString())
```

시계 컴포넌트가 이 값을 템플릿에 `{{ clock }}`으로 출력한다. 컴포넌트 안에는 1초마다 상태를 바꾸는 타이머가 없고, 화면의 다른 부분은 사용자 입력에 따라 계속 리렌더링된다.', 'OBJECTIVE'),
       (3657, 579, '아래 감시자에 추가해야 할 옵션의 이름은?', '```typescript
watch(() => props.userId, async (id) => {
  user.value = await fetchUser(id)
})
```

목록에서 다른 사용자를 고르면 상세 화면이 제대로 바뀐다. 그런데 주소창에 URL을 직접 입력해 페이지를 처음 열면 이름 자리가 계속 비어 있고, 네트워크 탭에도 `/api/users/1` 요청이 찍히지 않는다.', 'SUBJECTIVE'),
       (3658, 579, '아래 코드의 fullName을 선언할 때 썼어야 할 반응형 API의 이름은?', '```typescript
const last = ref(''홍'')
const first = ref(''길동'')
const fullName = ref('''')

watch([last, first], () => {
  fullName.value = `${last.value}${first.value}`
})
```

컴포넌트를 처음 열면 이름 자리가 빈 문자열로 보인다. 또 다른 코드가 `fullName.value`에 값을 직접 대입한 뒤에는 `last`·`first`와 화면의 이름이 서로 어긋난 채 남는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3653
(9915, 3653, '1', '첫 계산 뒤 캐시가 영원히 유지된다고 본 것. 의존성인 qty가 바뀌면 캐시는 더티로 표시돼 다음 읽기에서 다시 계산된다.', false),
(9916, 3653, '2', '첫 읽기에서 1회 계산해 캐시하고, qty 변경 2회는 더티 표시만 남긴다. 그다음 읽기에서 1회 재계산하고 마지막 읽기는 캐시를 그대로 쓰므로 총 2회다.', true),
(9917, 3653, '3', '의존성이 바뀔 때마다 즉시 다시 계산한다고 본 것. computed는 지연 평가라 값을 읽기 전에는 계산하지 않고 더티 플래그만 세운다.', false),
(9918, 3653, '4', '템플릿의 메서드 호출처럼 .value를 읽을 때마다 매번 계산한다고 본 것. 캐시가 유효하면 읽어도 계산을 건너뛴다.', false),

-- 문제 3654
(9919, 3654, 'reactive로 만든 객체의 속성은 deep: true를 줘야 변경이 감지된다.', 'deep은 중첩 객체를 순회해 안쪽 변경까지 볼 때 쓰는 옵션이다. reactive 객체를 통째로 감시하면 이미 암묵적 deep이라 여기서는 원인이 아니다.', false),
(9920, 3654, '같은 틱 안에서 두 번 바뀌면 변경이 상쇄돼 콜백이 건너뛰어진다.', '한 틱의 연속 변경이 배치로 묶여 콜백이 1회로 합쳐질 수는 있어도 0회가 되지는 않는다. 감시가 걸려 있었다면 최소 한 번은 실행된다.', false),
(9921, 3654, 'immediate: true를 주지 않으면 감시자가 등록만 되고 활성화되지 않는다.', 'immediate는 등록 직후 1회 실행 여부만 정한다. 이 옵션이 없어도 이후 소스가 바뀌면 콜백은 정상 실행된다.', false),
(9922, 3654, '소스 자리에 숫자 0이 그대로 전달돼 추적할 반응형 대상이 없다.', 'state.count는 인자로 넘기는 순간 숫자로 평가된다. () => state.count처럼 getter로 감싸야 속성을 읽는 시점이 감시자 실행 때로 미뤄져 의존성이 등록된다.', true),

-- 문제 3655
(9923, 3655, 'watchEffect의 콜백은 이전 값과 새 값을 인자로 받아 두 값을 비교할 수 있다.', '표의 이전 값 접근 행에 정면으로 걸린다. watchEffect 콜백이 받는 인자는 정리 함수를 등록하는 onCleanup뿐이며, 이전 값이 필요하면 watch를 써야 한다.', true),
(9924, 3655, 'watch로 등록한 감시자는 옵션을 주지 않으면 소스가 처음 바뀔 때까지 콜백을 실행하지 않는다.', '최초 실행이 지연이기 때문이다. 마운트 직후에도 한 번 돌려야 하는 초기 로딩은 immediate를 켜서 해결한다.', false),
(9925, 3655, 'watchEffect 콜백 안에서 한 번도 읽지 않은 반응형 값은 바뀌어도 재실행을 일으키지 않는다.', '의존성이 콜백에서 실제로 읽힌 값 기준으로 등록되기 때문이다. 조건 분기 때문에 읽히지 않고 지나간 값은 의존성에서 빠진다.', false),
(9926, 3655, '두 함수 모두 호출 결과를 변수에 담아 두면 나중에 감시를 중단할 수 있다.', '표의 반환값 행대로 둘 다 감시 해제 함수를 돌려준다. 다만 컴포넌트 안에서 동기적으로 등록한 감시자는 언마운트 때 자동 해제된다.', false),

-- 문제 3656
(9927, 3656, '화면이 리렌더링될 때마다 getter가 다시 실행돼 시각이 갱신된다.', '템플릿에서 메서드를 호출하는 것과 혼동한 것. computed는 렌더링 횟수가 아니라 의존성 변경으로만 다시 계산한다.', false),
(9928, 3656, '.value를 읽는 순간 캐시가 만료되므로 읽을 때마다 새 시각이 나온다.', '읽기를 캐시 만료 신호로 본 것. 캐시를 무효로 만드는 것은 의존성 변경이고, 읽기는 유효한 캐시를 그대로 반환한다.', false),
(9929, 3656, '처음 읽힌 시각이 캐시에 남아 화면의 시각이 갱신되지 않고 멈춰 있다.', 'getter가 반응형 값을 하나도 읽지 않아 의존성 목록이 비어 있다. 더티로 표시될 계기가 없으니 최초 계산값이 계속 반환된다.', true),
(9930, 3656, '반응형 의존성이 없는 getter라 Vue가 등록 단계에서 오류를 던진다.', '의존성이 비어도 경고나 오류 없이 조용히 동작한다. 그래서 값이 갱신되지 않는 버그의 원인을 찾기 어렵다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1174, 3657, 'immediate,immediate: true,immediate 옵션,이미디에이트', 'watch는 기본이 지연 실행이라 소스가 실제로 바뀌어야 콜백이 돈다. 목록에서 이동할 때는 userId가 달라져 요청이 나가지만, 첫 진입은 변경이 아니라 초기값이므로 콜백이 돌지 않아 화면이 빈 채로 남는다. immediate: true를 주면 등록 직후에도 한 번 실행돼 초기 로딩까지 같은 감시자로 처리된다. 중첩 속성까지 훑는 deep, 한 번만 실행하고 스스로 해제되는 once, 콜백 실행 시점을 정하는 flush와는 역할이 다르니 구분해 두자.'),
       (1175, 3658, 'computed,컴퓨티드,계산된 속성,계산 속성', 'fullName은 last와 first에서 계산되는 파생 값이다. 파생 값을 별도 ref로 두고 watch로 맞추면 같은 정보를 두 벌로 관리하게 돼, 초기값이 비거나 누군가 직접 대입해 원본과 어긋나는 문제가 생긴다. computed로 도출하면 읽기 전용 파생 값이 되고 의존성이 바뀔 때만 다시 계산되며 캐싱 이점까지 얻는다. 판단 기준은 다른 상태로부터 계산될 수 있는가다. 계산이면 computed, 요청·저장·라우팅처럼 행동이 필요하면 watch다.');

-- =====================================================
-- Lesson 737: flush 시점과 await 뒤 추적 누락
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4601, 737, '아래 코드를 실행했을 때 콘솔에 출력되는 내용은?', '```typescript
const state = reactive({ count: 0 })

watch(state, (newVal, oldVal) => {
  console.log(`${newVal.count} / ${oldVal.count}`)
})

state.count = 1
```

감시자에는 옵션을 아무것도 주지 않았고, 콜백은 한 번 실행된다.', 'OBJECTIVE'),
       (4602, 737, '아래 감시자가 항목 추가 뒤의 목록 높이를 읽도록 고치는 방법으로 옳은 것은?', '```typescript
const listRef = ref<HTMLUListElement | null>(null)
const items = ref<string[]>([])

watch(items, () => {
  console.log(listRef.value?.scrollHeight)
})

function add(name: string) {
  items.value = [...items.value, name]
}
```

항목 하나의 높이는 40px이다. add를 연달아 호출하면 콘솔에는 0, 40, 80이 찍혀 방금 추가한 항목이 빠진 높이만 보인다.', 'OBJECTIVE'),
       (4603, 737, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | `computed` | `watch` |
| --- | --- | --- |
| 목적 | 다른 상태에서 값을 도출 | 상태 변화에 부수 효과 실행 |
| 반환값 | 읽기 전용 ref | 감시 해제 함수 |
| 캐싱 | 있음 | 없음 |
| 계산 함수 안의 비동기·상태 변경 | 허용하지 않음 | 허용 |
| 실행 시점 | `.value`를 읽을 때(지연) | 의존성이 바뀐 뒤(flush 옵션 따름) |', 'OBJECTIVE'),
       (4604, 737, '아래 코드에서 size를 바꿔도 목록이 갱신되지 않는 원인으로 옳은 것은?', '```typescript
const page = ref(1)
const size = ref(20)
const rows = ref([])

watchEffect(async () => {
  const res = await fetchPage(page.value)
  rows.value = res.slice(0, size.value)
})
```

page를 2로 바꾸면 목록이 곧바로 다시 불러와진다. 반면 size를 20에서 30으로 바꾸면 화면에는 계속 20행만 남고 네트워크 요청도 새로 나가지 않는다.', 'OBJECTIVE'),
       (4605, 737, '아래 코드의 ○○○ 자리에 쓰인 반응형 API의 이름은?', '```typescript
const userId = ref(1)
const detail = ref(null)

○○○(async (onCleanup) => {
  const controller = new AbortController()
  onCleanup(() => controller.abort())
  detail.value = await fetchUser(userId.value, controller.signal)
})
```

화면을 열자마자 네트워크 탭에 /api/users/1 요청이 한 번 찍힌다. 목록에서 다른 사용자를 빠르게 연달아 고르면 앞선 요청은 canceled로 바뀌고 마지막 요청만 살아남는다.', 'SUBJECTIVE'),
       (4606, 737, '아래 computed의 계산 함수 안에서 하면 안 되는 (1)·(2) 같은 동작을 통틀어 부르는 말은?', '```typescript
const list = computed(() => {
  loading.value = true                       // (1)
  fetchLogs().then(r => { logs.value = r })  // (2)
  return logs.value.filter(l => l.level === ''ERROR'')
})
```

이 코드를 올린 뒤 개발 서버에 무한 갱신 경고가 뜨고, 화면 어디에서 값을 읽었는지에 따라 (1)·(2)가 몇 번 실행되는지가 매번 달라진다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4601
(12443, 4601, '1 / 0', 'reactive 객체를 감시해도 변경 전 스냅샷이 따로 온다고 본 것. 감시 소스가 객체 자체라 Vue는 같은 프록시를 두 인자에 그대로 넘기므로 이전 값만 0으로 남을 수 없다.', false),
(12444, 4601, '1 / 1', 'reactive 객체를 통째로 감시하면 newVal과 oldVal이 같은 프록시를 가리킨다. 콜백이 도는 시점의 count는 이미 1이라 두 자리 모두 1로 찍힌다.', true),
(12445, 4601, '1 / undefined', 'immediate로 등록 직후 실행될 때 이전 값이 없어 undefined가 오는 경우와 혼동. 여기서는 실제 변경으로 실행된 콜백이라 이전 값 자리가 비지 않는다.', false),
(12446, 4601, '0 / 0', '콜백이 변경 직전 상태를 붙잡아 실행된다고 본 것. 기본 flush가 pre라도 콜백은 값이 바뀐 다음에 돌기 때문에 새 값이 보인다.', false),

-- 문제 4602
(12447, 4602, 'deep: true를 주어 배열 안쪽 원소 변경까지 감지하게 한다.', '변경이 감지되지 않는 문제로 본 것. 배열을 통째로 새로 대입하고 있어 감지는 이미 되고 있으며, 콘솔이 매번 찍히는 것이 그 증거다. deep은 감지 범위를 넓힐 뿐 실행 시점을 옮기지 못한다.', false),
(12448, 4602, 'immediate: true를 주어 등록 직후에도 콜백이 한 번 돌게 한다.', '처음 찍히는 0을 초기 실행 누락으로 본 것. 등록 직후 실행이 하나 늘 뿐, 추가할 때마다 한 박자 이전 높이를 읽는 문제는 그대로 남는다.', false),
(12449, 4602, '감시 소스를 () => items.value.length 게터로 바꿔 길이 변화만 보게 한다.', '소스를 잘못 지정한 문제로 본 것. 소스를 무엇으로 바꾸든 콜백이 도는 시점은 기본값 그대로라 화면은 아직 갱신되기 전이다.', false),
(12450, 4602, 'flush: ''post''를 주어 콜백이 DOM 갱신 뒤에 실행되게 한다.', '기본 flush는 pre라 콜백이 렌더링 전에 돈다. post로 미루면 새 항목이 그려진 뒤 실행돼 갱신된 scrollHeight를 읽는다.', true),

-- 문제 4603
(12451, 4603, 'computed는 의존성이 바뀌는 즉시 다시 계산해 두므로 값을 읽지 않아도 늘 최신 상태를 유지한다.', '표의 실행 시점 행에 정면으로 걸린다. 의존성이 바뀌면 더티 표시만 해 두고 실제 계산은 누군가 .value를 읽는 순간으로 미루는 지연 평가다.', true),
(12452, 4603, '같은 파생 값을 템플릿 여러 곳에서 읽어도 의존성이 그대로면 계산은 한 번만 일어난다.', '캐싱 행에서 따라 나오는 결과다. 계산 결과를 캐시에 두고 의존성이 바뀌기 전까지 재사용하므로 읽는 횟수가 늘어도 비용이 늘지 않는다.', false),
(12453, 4603, '서버에서 받아 온 값을 화면에 쓰려면 요청은 watch 쪽에서 하고 응답을 담을 상태를 따로 두어야 한다.', '비동기·상태 변경 행에서 따라 나오는 결과다. 계산 함수 안에서는 응답을 기다릴 수 없으므로 요청이라는 행동은 watch가 맡고 결과만 상태로 남긴다.', false),
(12454, 4603, 'watch로 등록한 감시자는 돌려받은 함수를 호출해 도중에 감시를 멈출 수 있다.', '반환값 행에서 따라 나오는 결과다. watch가 돌려주는 것은 값이 아니라 감시 해제 함수라, 조건이 달라지면 직접 호출해 감시를 끊을 수 있다.', false),

-- 문제 4604
(12455, 4604, 'watchEffect는 콜백에서 가장 먼저 읽은 반응형 값 하나만 의존성으로 등록한다.', 'page만 반응하는 것을 보고 개수 제한이 있다고 세운 규칙. watchEffect는 동기 구간에서 읽은 값을 모두 의존성으로 모으므로 개수가 아니라 읽은 시점이 결과를 갈랐다.', false),
(12456, 4604, '감시할 값이 둘 이상이면 watch에 배열 소스를 준 형태로 바꿔야 함께 추적된다.', '다중 소스를 배열로 적는 watch 문법을 그대로 옮겨 붙인 오해. watchEffect는 소스를 적지 않아도 콜백에서 읽기만 하면 여러 값을 함께 추적한다.', false),
(12457, 4604, 'size.value를 await 뒤에서 읽어 자동 추적된 의존성 목록에 들어가지 않았다.', '의존성은 콜백이 동기적으로 도는 첫 구간에서 읽은 값만 등록된다. await 이후는 추적이 끝난 뒤라 size는 잡히지 않으므로, 필요한 값은 await 앞에서 미리 읽어 두어야 한다.', true),
(12458, 4604, 'rows에 slice가 만든 새 배열을 대입해 반응형 연결이 끊겼다.', 'ref에 새 배열을 넣는 것은 .value 교체라 반응형이 그대로 유지된다. 연결이 끊겼다면 page를 바꿨을 때도 화면이 그대로여야 하는데 그렇지 않다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1490, 4605, 'watchEffect,watch effect,워치이펙트,워치 이펙트', '감시할 소스를 따로 적지 않고 콜백 하나만 넘기는 형태가 watchEffect다. 등록과 동시에 콜백을 한 번 실행하면서 그 안에서 읽은 반응형 값(userId)을 자동으로 의존성에 담고, 그 값이 바뀌면 다시 실행한다. 화면을 열자마자 요청이 나간 것이 즉시 1회 실행의 증거이고, 콜백의 첫 인자로 받은 정리 함수는 다음 실행 직전과 감시 해제 시에 불려 이전 요청을 끊기 때문에 앞선 요청이 canceled로 남는다. 소스를 직접 적고 이전 값까지 받아 보는 watch, 값을 돌려주며 캐싱하는 computed와 구분해 두자. 다만 await 뒤에서 읽은 값은 의존성으로 잡히지 않으니, 추적이 필요한 값은 첫 동기 구간에서 읽어야 한다.'),
       (1491, 4606, '부수 효과,부수효과,부작용,사이드 이펙트,사이드이펙트,side effect,side-effect', 'computed의 계산 함수는 다른 상태로부터 값을 도출하기만 하는 순수 함수여야 한다. (1)처럼 다른 반응형 상태를 바꾸거나 (2)처럼 요청을 띄우는 것은 값 도출 바깥의 일, 곧 부수 효과다. computed는 읽힐 때 계산하는 지연 평가라 언제 몇 번 다시 도는지를 Vue가 정한다. 그래서 부수 효과를 넣으면 실행 횟수가 화면 사정에 따라 달라지고, 계산 도중 바꾼 상태가 그 계산을 다시 깨우면 무한 갱신으로 이어진다. 상태 변경·요청·저장 같은 행동은 watch나 watchEffect로 옮기고 계산 함수에는 filter 같은 순수한 도출만 남겨야 한다. 참고로 부수 효과를 실행하는 감시자 자체는 이펙트라고 부르며, 이펙트를 쓰는 것 자체가 문제가 아니라 값 도출 자리에 섞는 것이 문제다.');

-- =====================================================
-- Lesson 895: computed와 watch 심화: 메서드와의 차이·쓰기 가능한 computed·감시 범위와 해제
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5549, 895, '아래 컴포넌트에서 콘솔에 찍힌 method와 computed의 출력 횟수로 옳은 것은?', '```vue
<script setup lang="ts">
const theme = ref(''light'')
const keyword = ref('''')
const fruits = ref([''apple'', ''banana'', ''cherry''])

const byComputed = computed(() => {
  console.log(''computed'')
  return fruits.value.filter(f => f.includes(keyword.value))
})

function byMethod() {
  console.log(''method'')
  return fruits.value.filter(f => f.includes(keyword.value))
}
</script>

<template>
  <div :class="theme">
    <p>{{ byComputed.length }}</p>
    <p>{{ byMethod().length }}</p>
  </div>
</template>
```

첫 렌더링이 끝난 뒤 theme를 ''dark''로 바꾸고, 잠시 뒤 keyword를 ''an''으로 바꿨다. 두 변경은 서로 다른 시점에 일어나 리렌더링이 한 번씩 따로 일어났다.', 'OBJECTIVE'),
       (5550, 895, '아래 코드를 실행했을 때 콘솔에 출력되는 값은?', '```typescript
const last = ref(''홍'')
const first = ref(''길동'')

const fullName = computed({
  get: () => `${last.value} ${first.value}`,
  set: (v: string) => {
    const [l, f] = v.split('' '')
    last.value = l
    first.value = f
  },
})

fullName.value = ''김 철수''
first.value = ''영희''
console.log(fullName.value)
```', 'OBJECTIVE'),
       (5551, 895, '아래처럼 감시 소스를 바꾼 뒤의 동작으로 옳은 것은?', '주문서 화면의 `order`는 배송지·결제 정보·상품 500개 목록이 여러 겹으로 중첩된 `reactive` 객체다. 처음에는 `watch(order, cb)`로 객체 전체를 감시했다. 그런데 콜백에 실제로 필요한 값은 쿠폰 코드 `order.payment.coupon` 하나뿐이어서, 감시 소스를 `() => order.payment.coupon`으로 바꿨다. 콜백 `cb`는 그대로이고, 옵션은 바꾸기 전후 모두 주지 않았다.', 'OBJECTIVE'),
       (5552, 895, '아래 코드에서 컴포넌트가 언마운트된 뒤 B만 찍힌 원인으로 옳은 것은?', '```typescript
// SearchPanel.vue의 <script setup>
import { keyword } from ''@/stores/search''   // 여러 화면이 함께 쓰는 전역 ref

watch(keyword, (k) => console.log(''A'', k))

setTimeout(() => {
  watch(keyword, (k) => console.log(''B'', k))
}, 0)
```

검색 패널을 열었다가 닫아 SearchPanel이 언마운트됐다. 그 뒤 다른 화면에서 keyword를 ''vue''로 바꾸자 콘솔에는 `B vue` 한 줄만 찍혔다.', 'OBJECTIVE'),
       (5553, 895, '아래 로그에 드러난 computed의 평가 방식을 가리키는 용어는?', '```typescript
const tab = ref<''list'' | ''stats''>(''list'')
const region = ref(''all'')

const stats = computed(() => {
  console.time(''stats 계산'')
  const r = summarize(orders.value, region.value)   // 주문 10만 건 집계
  console.timeEnd(''stats 계산'')
  return r
})
```

```html
<OrderList v-if="tab === ''list''" :region="region" />
<StatsPanel v-else :data="stats" />
```

화면은 목록 탭으로 시작한다. 아래는 그때부터 남은 콘솔 로그이며, [변경] 줄은 값을 바꿀 때마다 따로 찍은 것이다.

```
[변경] region = seoul
[변경] region = busan
  … region을 50번 바꾸는 동안 stats 계산 로그 없음
[변경] tab = stats
stats 계산: 820ms
```', 'SUBJECTIVE'),
       (5554, 895, '아래 요구를 만족하도록 동료의 코드를 바꿀 때 써야 할 Vue 반응형 API의 이름은?', '검색 화면에 다음 동작을 넣으려 한다.

1. 검색어 `keyword`가 바뀌면, 바뀌기 직전의 검색어를 최근 검색 목록 맨 앞에 넣는다.
2. 이어서 새 검색어로 `searchApi`를 호출한다.
3. 화면을 처음 열었을 때는 1·2 모두 일어나지 않아야 한다.

동료가 먼저 짠 코드는 아래와 같다.

```typescript
watchEffect(async () => {
  // 1번: 직전 검색어를 꺼낼 방법을 못 찾아 비워 둠
  results.value = await searchApi(keyword.value)
})
```

이 코드를 올리자 화면을 열자마자 네트워크 탭에 `/api/search?q=` 요청이 한 번 찍혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5549
(14971, 5549, 'method 3회 / computed 3회', 'computed도 템플릿의 메서드 호출처럼 렌더링마다 다시 계산된다고 본 것. theme는 computed가 읽지 않는 값이라, theme 변경으로 리렌더링될 때는 캐시된 값이 그대로 쓰인다.', false),
(14972, 5549, 'method 2회 / computed 2회', '메서드에도 캐싱이 있어 읽은 값(keyword)이 바뀔 때만 다시 실행된다고 본 것. 템플릿의 메서드 호출은 무엇 때문에 리렌더링되든 렌더링마다 매번 실행된다.', false),
(14973, 5549, 'method 3회 / computed 2회', '렌더링은 첫 화면·theme 변경·keyword 변경으로 3번이다. 메서드는 렌더링마다 실행돼 3회, computed는 처음 읽을 때와 의존성 keyword가 바뀐 뒤 읽을 때만 계산해 2회다.', true),
(14974, 5549, 'method 3회 / computed 1회', 'computed가 첫 계산 뒤 캐시를 영원히 쓴다고 본 것. 계산 중에 읽은 keyword가 의존성으로 등록돼, keyword가 바뀌면 다음 읽기에서 다시 계산한다.', false),

-- 문제 5550
(14975, 5550, '홍 길동', 'computed를 처음 계산한 값에 고정된 캐시로 본 것. 대입은 setter를 거쳐 원본을 바꾸고, 원본이 바뀌면 캐시는 다음 읽기에서 다시 계산된다.', false),
(14976, 5550, '홍 영희', 'computed는 읽기 전용이라 대입이 무시된다고 본 것. get과 set을 함께 넘기면 대입한 값이 setter로 전달돼 last와 first가 바뀐다.', false),
(14977, 5550, '김 철수', '대입한 값이 ref처럼 computed 안에 그대로 저장된다고 본 것. setter는 원본만 바꿀 뿐이고, 읽을 때는 getter가 현재 last·first로 다시 계산한다.', false),
(14978, 5550, '김 영희', '대입은 setter로 넘어가 last가 ''김'', first가 ''철수''가 된다. 이어서 first가 ''영희''로 바뀌어 캐시가 더티로 표시되고, 읽는 순간 getter가 다시 계산해 ''김 영희''가 나온다.', true),

-- 문제 5551
(14979, 5551, '쿠폰을 바꾸면 콜백의 새 값·이전 값 인자에 바뀌기 전후의 쿠폰 코드가 각각 들어온다.', 'getter가 문자열을 돌려주므로 Vue는 직전 반환값을 보관했다가 새 값과 함께 넘긴다. 객체를 통째로 감시하던 때는 두 인자가 같은 프록시를 가리켜 전후를 비교할 수 없었다.', true),
(14980, 5551, '바꾼 뒤에도 감시자가 돌 때마다 order의 중첩 속성을 전부 순회해 비용이 바꾸기 전과 같다.', 'reactive 객체를 직접 넘길 때의 암묵적 deep 비용을 getter에도 적용한 것. getter는 쿠폰 속성 하나만 읽으므로 추적 대상이 그 하나로 줄고 순회도 없어진다.', false),
(14981, 5551, 'getter가 등록 시점의 쿠폰 코드를 한 번만 읽어 두어 이후 쿠폰을 바꿔도 콜백이 돌지 않는다.', 'watch(order.payment.coupon, cb)처럼 값을 직접 넘긴 경우와 혼동한 것. getter는 감시자가 돌 때마다 다시 호출돼 쿠폰 속성을 읽는 의존성이 계속 유지된다.', false),
(14982, 5551, 'getter가 문자열을 돌려주므로 deep: true를 함께 줘야 쿠폰 변경이 감지된다.', 'deep은 돌려받은 객체의 안쪽 변경까지 훑을 때 쓰는 옵션이다. getter가 원시값을 돌려주면 그 값이 달라지는 것만으로 콜백이 실행된다.', false),

-- 문제 5552
(14983, 5552, '여러 화면이 함께 쓰는 전역 ref를 감시하면 컴포넌트가 사라져도 감시자가 해제되지 않는다.', '그렇다면 같은 ref를 보는 A도 찍혀야 한다. A가 멈춘 것을 보면 해제 여부를 가른 것은 감시 대상이 아니라 감시자를 등록한 시점이다.', false),
(14984, 5552, 'B는 setTimeout 콜백에서 등록돼 컴포넌트에 묶이지 않아 언마운트 때 해제되지 않았다.', 'setup이 동기적으로 도는 동안 등록한 감시자만 현재 컴포넌트에 묶여 언마운트 때 함께 정리된다. 타이머 콜백은 setup이 끝난 뒤 실행되므로 B는 어느 컴포넌트에도 묶이지 않는다.', true),
(14985, 5552, '언마운트 전에 대기열에 들어가 있던 B의 콜백은 감시 해제와 상관없이 끝까지 실행된다.', 'keyword는 언마운트한 뒤에 바뀌었으므로 그 시점에 대기 중인 콜백은 없었다. B가 해제됐다면 이후 변경에는 새로 반응하지 않았어야 한다.', false),
(14986, 5552, 'setTimeout 안에서 호출한 watch는 해제 함수를 돌려주지 않아 멈출 방법이 없다.', 'watch는 어디서 호출하든 해제 함수를 돌려준다. B의 반환값을 받아 두었다가 onUnmounted에서 호출하면 언마운트와 함께 멈출 수 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1806, 5553, '지연 평가,지연평가,지연 계산,게으른 평가,느긋한 평가,레이지 평가,레이지 이밸류에이션,lazy evaluation,lazy-evaluation,lazy', 'computed는 의존성(region)이 바뀌어도 그 자리에서 다시 계산하지 않고, 다시 계산해야 한다는 표시(더티 플래그)만 남긴다. 실제 계산은 누군가 .value를 읽을 때 일어나는데, 목록 탭에서는 stats를 읽는 곳이 없어 region이 50번 바뀌는 동안 계산이 한 번도 돌지 않았다. 통계 탭이 열려 StatsPanel에 stats를 넘기는 순간 최신 region으로 한 번만 계산한 것이 820ms 로그다. 이처럼 값이 실제로 읽힐 때까지 계산을 미루는 것이 지연 평가다. 계산 결과를 재사용하는 캐싱은 같은 값을 여러 번 읽을 때 드러나는 성질로 구분해 두자. 의존성이 바뀔 때마다 곧바로 계산해 두는 방식은 즉시 평가(eager evaluation)라고 부른다.'),
       (1807, 5554, 'watch,워치,와치,watch(),watch 함수', '감시할 소스를 첫 인자로 직접 지정하는 watch는 콜백이 새 값과 이전 값을 함께 받아 직전 검색어를 꺼낼 수 있고(요구 1), 기본이 지연 실행이라 keyword가 실제로 바뀌기 전에는 콜백이 돌지 않는다(요구 3). 동료가 쓴 watchEffect는 등록 즉시 한 번 실행되고 이전 값을 받지 못해 두 요구를 모두 놓쳤으며, 화면을 열자마자 찍힌 빈 검색어 요청이 그 증거다. 값을 도출하기만 하는 computed는 요청 같은 부수 효과를 넣을 자리가 아니라 후보가 되지 못한다. 같은 watch라도 immediate: true를 주면 첫 진입에 콜백이 돌아 요구 3이 깨지므로 옵션 없이 등록해야 한다.');
