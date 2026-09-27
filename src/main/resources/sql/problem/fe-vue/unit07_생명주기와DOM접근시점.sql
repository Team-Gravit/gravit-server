-- Unit: 생명주기와 DOM 접근 시점 (Unit ID: 157)
-- Chapter: Vue.js (Chapter ID: 14)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (583, 157, '부모·자식 훅 순서와 nextTick'),
       (741, 157, 'onUpdated 루프와 훅 이름 변경'),
       (899, 157, 'Vue 생명주기 훅의 호출 순서와 정리 책임');

-- =====================================================
-- Lesson 583: 부모·자식 훅 순서와 nextTick
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3677, 583, '아래 생명주기 훅 비교표를 바탕으로 옳지 않은 것은?', '| 훅 | 호출되는 시점 | 그 시점의 DOM |
| --- | --- | --- |
| `setup()` | 반응형 상태 준비가 끝난 직후 | 아직 없음 |
| `onBeforeMount` | 최초 렌더 함수 실행 직전 | 아직 없음 |
| `onMounted` | 최초 렌더 결과가 문서에 삽입된 뒤 | 생성됨 |
| `onBeforeUpdate` | 재렌더 직전 | 갱신 전 상태 그대로 |
| `onUpdated` | 변경분이 DOM에 패치된 뒤 | 갱신됨 |
| `onBeforeUnmount` | 제거 절차가 시작될 때 | 아직 문서에 있음 |
| `onUnmounted` | DOM 제거와 이펙트 해제가 끝난 뒤 | 사라짐 |', 'OBJECTIVE'),
       (3678, 583, '아래 컴포넌트에서 차트가 끝내 그려지지 않는 원인으로 옳은 것은?', '```vue
<script setup lang="ts">
import { ref, onMounted } from ''vue''

const box = ref<HTMLElement | null>(null)
const stats = await fetchStats()   // 응답까지 약 300ms

onMounted(() => {
  drawChart(box.value, stats)
})
</script>

<template>
  <div ref="box"></div>
</template>
```

컴포넌트는 화면에 정상적으로 나타나고 `stats`도 응답값으로 채워지지만, `<div>` 안은 계속 비어 있다.', 'OBJECTIVE'),
       (3679, 583, '아래 코드에서 부모가 자식의 `reset()`을 호출하려 할 때 일어나는 일로 옳은 것은?', '```vue
<!-- ItemList.vue -->
<script setup lang="ts">
import { ref } from ''vue''
const items = ref<string[]>([])
function reset() { items.value = [] }
</script>
```

```vue
<!-- Parent.vue -->
<script setup lang="ts">
import { ref, onMounted } from ''vue''
const list = ref(null)

onMounted(() => {
  list.value.reset()
})
</script>

<template>
  <ItemList ref="list" />
</template>
```', 'OBJECTIVE'),
       (3680, 583, '아래는 부모와 자식 컴포넌트가 남긴 실행 로그다. 이 로그에서 알 수 있는 것으로 옳은 것은?', E'```\n[Parent] setup\n[Parent] onBeforeMount\n[Child]  setup\n[Child]  onBeforeMount\n[Child]  onMounted\n[Parent] onMounted\n--- 라우트를 이동해 Parent를 화면에서 제거 ---\n[Parent] onBeforeUnmount\n[Child]  onBeforeUnmount\n[Child]  onUnmounted\n[Parent] onUnmounted\n```', 'OBJECTIVE'),
       (3681, 583, '아래 코드에서 주석 자리에 넣어야 입력창에 포커스가 가는 Vue 내장 함수의 이름은?', '```vue
<script setup lang="ts">
import { ref } from ''vue''

const editing = ref(false)
const titleInput = ref<HTMLInputElement | null>(null)

async function startEdit() {
  editing.value = true
  // ← 여기에 한 줄이 필요하다
  titleInput.value?.focus()
}
</script>

<template>
  <input v-if="editing" ref="titleInput" />
  <button v-else @click="startEdit">편집</button>
</template>
```

지금은 편집 버튼을 눌러도 커서가 잡히지 않는다. `editing`을 바꾼 바로 다음 줄에서 `titleInput.value`를 찍어 보면 `null`이고, 잠시 뒤 같은 값을 다시 찍으면 실제 요소가 나온다.', 'SUBJECTIVE'),
       (3682, 583, '아래 로그에서 드러난 문제를 가리키는 용어는?', '```
10:00:00  [ChartPage] onMounted        setInterval(poll, 5000) 등록
10:00:05  [ChartPage] poll() 실행
10:00:10  [ChartPage] poll() 실행
10:00:12  라우트 이동 → [ChartPage] onUnmounted
10:00:15  [ChartPage] poll() 실행
10:00:20  [ChartPage] poll() 실행
```

이 페이지를 20번 드나든 뒤에는 같은 초에 `poll()`이 20번 찍혔고, 탭의 힙 스냅숏 크기가 처음의 6배가 되었다. 반면 컴포넌트 안에서 쓰던 `watch`와 `computed`는 따로 손대지 않았는데도 조용해졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3677
(9979, 3677, '`<script setup>` 최상위에서는 요소 높이를 잴 수 없지만, 같은 코드를 `onMounted`로 옮기면 실제 높이가 나온다.', '최상위 코드는 setup 시점에 실행돼 아직 참조할 요소가 없고, onMounted는 문서 삽입이 끝난 뒤라 측정이 성립한다. DOM 측정 코드를 onMounted로 옮기라는 규칙이 여기서 나온다.', false),
(9980, 3677, '`onBeforeUpdate`에서 읽은 목록의 스크롤 위치와 `onUpdated`에서 읽은 값이 서로 다를 수 있다.', '두 훅 사이에 변경분이 DOM에 패치되므로 같은 값을 재도 결과가 갈린다. 갱신 전 스크롤 위치를 저장했다가 갱신 후 복원하는 패턴이 이 간격을 이용한다.', false),
(9981, 3677, '`onBeforeUnmount` 시점에는 요소가 이미 제거된 뒤라 마지막 스크롤 위치를 읽어 둘 수 없다.', '제거 절차가 시작될 때라도 요소는 아직 문서에 남아 있어 측정이 가능하다. 참조가 풀리는 것은 그다음인 onUnmounted이므로, 사라지기 전 값을 갈무리하려면 onBeforeUnmount를 써야 한다.', true),
(9982, 3677, '`onUnmounted` 안에서 템플릿 ref로 요소를 다시 측정하려 하면 참조가 비어 있다.', 'DOM 제거와 이펙트 해제가 모두 끝난 뒤라 붙잡을 요소가 남아 있지 않다. 그래서 이 훅에서는 측정이 아니라 타이머·리스너 해제 같은 마지막 뒷정리만 한다.', false),

-- 문제 3678
(9983, 3678, '최상위 `await` 뒤에는 Vue가 추적하던 현재 인스턴스가 이미 풀려 있어, 그 뒤에 부른 훅이 어느 컴포넌트에도 등록되지 않는다.', '훅은 setup이 동기적으로 실행되는 동안에만 지금 setup 중인 인스턴스에 붙는다. await로 실행이 한 번 끊기면 그 추적이 끝나 등록이 무시되고 경고만 남는다.', true),
(9984, 3678, '`await` 때문에 컴포넌트의 마운트 자체가 취소돼 `onMounted` 시점이 아예 오지 않는다.', '마운트는 정상적으로 일어나 컴포넌트가 화면에 나타난다. 오지 않는 것은 마운트 시점이 아니라 콜백을 받아 갈 훅 등록이라는 점이 갈림길이다.', false),
(9985, 3678, '`onMounted` 콜백이 `async`가 아니어서 비동기로 채워진 `stats`를 읽지 못하고 그대로 반환된다.', '콜백이 실행될 시점이면 stats는 이미 응답값으로 채워져 있고, 훅 콜백은 동기 함수여도 아무 문제가 없다. 값이 아니라 등록이 빠진 것이 원인이다.', false),
(9986, 3678, '훅 등록이 최초 렌더보다 늦어져, 콜백이 마운트가 아니라 다음 갱신 때로 밀린다.', '등록이 늦어 밀린 것이라면 이후 어느 갱신에서는 실행돼야 한다. 인스턴스 추적이 끝난 뒤의 등록은 미뤄지는 것이 아니라 그대로 버려진다.', false),

-- 문제 3679
(9987, 3679, '`onMounted` 시점에는 자식이 아직 마운트되지 않아 `list.value`가 `null`이다.', '자식은 부모보다 먼저 마운트를 마치므로 부모의 onMounted에서 참조는 이미 채워져 있다. 비어 있는 것은 참조가 아니라 그 참조로 꺼내 쓸 수 있는 항목이다.', false),
(9988, 3679, '컴포넌트에 붙인 `ref`에는 루트 DOM 요소가 담기므로, 스크립트에서 정의한 함수는 애초에 담길 자리가 없다.', '컴포넌트에 붙인 ref는 요소가 아니라 컴포넌트 인스턴스를 담는다. 다만 그 인스턴스가 무엇까지 보여 줄지는 자식이 정하므로, 정의만으로 접근이 열리지는 않는다.', false),
(9989, 3679, '`reset()`은 호출되지만 `items`를 새 배열로 바꾼 탓에 자식 화면은 다음 갱신 전까지 옛 목록을 그대로 보여 준다.', '호출 자체가 성립하지 않으므로 화면 갱신 시점을 따질 단계가 아니다. 게다가 반응형 상태를 바꾸면 그 변경은 다음 렌더에 반드시 반영된다.', false),
(9990, 3679, '`<script setup>` 컴포넌트는 내부가 닫혀 있는 것이 기본이라 `reset`이 보이지 않고, 자식에서 `defineExpose`로 내보내야 호출할 수 있다.', 'script setup으로 쓴 컴포넌트는 내부 바인딩을 비공개로 두므로 부모가 함수를 바로 꺼낼 수 없다. defineExpose에 담아 내보낸 것만 참조를 통해 드러난다.', true),

-- 문제 3680
(9991, 3680, '자식의 `setup`은 부모의 `onMounted` 뒤에 실행되므로, 부모가 마운트를 마쳐야 자식이 상태를 만들 수 있다.', '로그에서 자식 setup은 부모 onMounted보다 앞선다. 부모는 렌더 도중 자식을 만나 곧바로 자식 초기화로 내려가고, 부모의 마운트 완료는 그보다 나중이다.', false),
(9992, 3680, '부모의 `onMounted`에서는 자식 영역이 이미 문서에 들어가 있으므로 자식 요소의 크기를 바로 잴 수 있다.', '자식 onMounted가 부모 것보다 먼저 찍혔다는 것은 자식 DOM이 그 전에 삽입을 마쳤다는 뜻이다. 반대로 자식이 자기 onMounted에서 부모의 최종 레이아웃에 기대는 것은 위험하다.', true),
(9993, 3680, '언마운트는 가장 깊은 자식부터 시작되므로 부모의 `onBeforeUnmount`에서는 자식 요소가 이미 문서에서 빠져 있다.', '로그의 언마운트 구간은 부모 onBeforeUnmount가 가장 먼저다. 절차는 위에서 아래로 시작하고 완료만 아래에서 올라오므로, 이 시점의 자식 요소는 아직 남아 있다.', false),
(9994, 3680, '마운트와 언마운트 모두 부모가 먼저 끝나므로, 정리 작업은 자식보다 부모에서 먼저 마무리된다.', '두 구간 모두 완료를 알리는 훅은 자식이 먼저 찍혔다. 부모는 자식의 정리가 끝난 뒤에야 자기 onUnmounted에 도달하므로 마무리 순서는 반대다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1182, 3681, 'nextTick,nextTick(),await nextTick(),$nextTick,next tick,nexttick,넥스트틱,넥스트 틱', '상태 변경은 곧바로 DOM에 반영되지 않고 큐에 모였다가 마이크로태스크에서 한 번에 렌더된다. 그래서 v-if를 켠 바로 다음 줄에서는 입력창이 아직 문서에 없고 템플릿 ref도 비어 있다. nextTick()이 돌려주는 프로미스를 await하면 그 렌더가 끝난 뒤 코드가 재개되므로 참조가 채워진 상태에서 focus()를 부를 수 있다. onMounted는 최초 마운트에 한 번만 실행돼 이 상황을 해결하지 못하고, 상태가 바뀔 때마다 DOM을 다뤄야 하는 경우라면 watch에 flush: ''post''를 주는 편이 빠뜨림이 적다.'),
       (1183, 3682, '메모리 누수,메모리누수,memory leak,memoryleak,메모리 릭,메모리릭', 'onMounted에서 등록한 setInterval을 언마운트 때 해제하지 않아, 사라진 컴포넌트를 붙들고 있는 콜백이 계속 살아남았다. 이렇게 회수되지 못한 자원이 쌓여 사용량이 계속 늘어나는 것이 메모리 누수다. watch·computed처럼 Vue가 만든 이펙트는 언마운트 시 자동 해제되므로 로그에서 조용해졌지만, setInterval·전역 이벤트 리스너·WebSocket·외부 라이브러리 인스턴스는 onBeforeUnmount나 onUnmounted에서 개발자가 직접 정리해야 한다. 실행이 엇갈려 결과가 달라지는 경쟁 상태나, onUpdated 안에서 상태를 바꿔 렌더가 되풀이되는 무한 갱신 루프와는 원인도 증상도 다르다.');

-- =====================================================
-- Lesson 741: onUpdated 루프와 훅 이름 변경
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4625, 741, '아래 코드에서 콘솔에 순서대로 찍히는 값은?', '```vue
<script setup lang="ts">
import { ref, nextTick } from ''vue''

const count = ref(0)
const el = ref<HTMLElement | null>(null)

async function run() {
  count.value++
  count.value++
  console.log(el.value?.textContent)   // 1번째
  await nextTick()
  console.log(el.value?.textContent)   // 2번째
  count.value++
  console.log(el.value?.textContent)   // 3번째
}
</script>

<template>
  <span ref="el">{{ count }}</span>
  <button @click="run">실행</button>
</template>
```

마운트가 끝난 화면에서 실행 버튼을 한 번만 누른다.', 'OBJECTIVE'),
       (4626, 741, '아래 컴포넌트에서 추가 버튼을 누른 뒤 로그가 멈추지 않는 원인으로 옳은 것은?', '```vue
<script setup lang="ts">
import { ref, onUpdated } from ''vue''

const items = ref([''a''])
const renderedAt = ref(0)

onUpdated(() => {
  renderedAt.value = Date.now()
  console.log(''rendered'', renderedAt.value)
})

function add() { items.value.push(''b'') }
</script>

<template>
  <p>마지막 갱신: {{ renderedAt }}</p>
  <ul>
    <li v-for="i in items" :key="i">{{ i }}</li>
  </ul>
  <button @click="add">추가</button>
</template>
```

화면에 처음 올라올 때는 조용하다가, 추가 버튼을 한 번 누른 뒤부터 `rendered` 로그가 초당 수천 줄씩 찍히며 탭이 응답하지 않는다.', 'OBJECTIVE'),
       (4627, 741, '아래 코드에서 `rows.value`에 대한 설명으로 옳은 것은?', '```vue
<script setup lang="ts">
import { ref, onMounted } from ''vue''

const users = ref([{ id: 11 }, { id: 22 }, { id: 33 }])
const rows = ref(null)

onMounted(() => {
  console.log(rows.value)
})
</script>

<template>
  <ul>
    <li v-for="u in users" :key="u.id" ref="rows">{{ u.id }}</li>
  </ul>
</template>
```

콘솔에는 `[li, li, li]`처럼 요소 세 개가 담긴 값이 찍힌다.', 'OBJECTIVE'),
       (4628, 741, '아래 컴포넌트를 Vue 3 프로젝트로 옮긴 뒤 임시 저장이 동작하지 않는 원인으로 옳은 것은?', '```vue
<script>
export default {
  data: () => ({ draft: '''' }),
  created() { console.log(''created'') },
  mounted() { console.log(''mounted'') },
  beforeDestroy() {
    console.log(''beforeDestroy'')
    localStorage.setItem(''draft'', this.draft)
  }
}
</script>
```

| 로그 | Vue 2 프로젝트 | 같은 파일을 올린 Vue 3 프로젝트 |
| --- | --- | --- |
| `created` | 찍힘 | 찍힘 |
| `mounted` | 찍힘 | 찍힘 |
| `beforeDestroy` | 다른 화면으로 옮길 때마다 찍힘 | 한 번도 안 찍힘 |

Vue 3에서는 화면을 떠났다 돌아와도 작성 중이던 글이 복구되지 않는다.', 'OBJECTIVE'),
       (4629, 741, '아래 상황에서 지도 초기화 코드를 옮겨 넣어야 하는 생명주기 훅의 이름은?', '관리자 페이지의 `<script setup>` 최상위에서 지도 라이브러리를 초기화하며 `document.querySelector(''#map'')`를 넘겼더니 콘솔에 `container is null`이 찍히고 지도 자리가 빈칸으로 남았다.

같은 두 줄을 화면의 새로고침 버튼 핸들러로 옮겨 실행하면 지도가 제대로 그려진다. 같은 요소를 템플릿 ref로 받아 두고 최상위에서 찍어 봐도 값은 `null`이었다.', 'SUBJECTIVE'),
       (4630, 741, '아래 감시자가 갱신된 DOM을 읽도록 세 번째 인자 옵션에 지정해야 하는 설정은?', '```vue
<script setup lang="ts">
import { ref, watch } from ''vue''

const messages = ref<string[]>([])
const box = ref<HTMLElement | null>(null)

watch(messages, () => {
  box.value!.scrollTop = box.value!.scrollHeight   // 맨 아래로 내리기
})
</script>
```

| 새 메시지가 도착한 뒤 | 콜백에서 읽은 `scrollHeight` | 화면에 보이는 위치 |
| --- | --- | --- |
| 1번째 | 1,200 | 마지막에서 두 번째 메시지 |
| 2번째 | 1,320 | 마지막에서 두 번째 메시지 |
| 3번째 | 1,440 | 마지막에서 두 번째 메시지 |

메시지는 정상적으로 쌓이는데 스크롤만 늘 한 칸씩 뒤처지고, 콜백 안에서 읽은 값은 언제나 방금 도착한 메시지가 빠진 높이다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4625
(12507, 4625, '"0", "2", "2"', '같은 틱에서 일어난 두 번의 증가는 갱신 큐에 모여 한 번만 렌더되므로 1번째 줄에서는 아직 옛 "0"이다. await nextTick()으로 그 렌더를 기다린 뒤 "2"가 되고, 3번째 증가는 다시 큐에 들어갔을 뿐이라 그 줄에서는 여전히 "2"다.', true),
(12508, 4625, '"0", "2", "3"', '마지막 증가만 곧바로 DOM에 닿는다고 본 것. 증가가 큐에 쌓이는 규칙은 앞의 두 번과 똑같아서, 렌더를 기다리지 않고 바로 읽은 그 줄에서는 아직 반영 전이다.', false),
(12509, 4625, '"2", "2", "3"', '상태를 바꾼 그 줄에서 DOM이 즉시 고쳐진다고 본 것. 변경은 갱신 큐에 등록될 뿐이고 실제 렌더는 현재 동기 코드가 끝난 뒤 마이크로태스크에서 일어난다.', false),
(12510, 4625, '"0", "1", "2"', '변경마다 렌더가 한 번씩 예약돼 큐가 하나씩 소진된다고 본 것. 같은 틱에 쌓인 변경은 합쳐져 한 번만 렌더되므로 첫 nextTick 뒤의 값은 "1"이 아니라 "2"다.', false),

-- 문제 4626
(12511, 4626, '`:key`에 항목 값을 그대로 써서 갱신 때마다 목록 노드가 통째로 다시 만들어지고, 그때마다 훅이 다시 불린다.', 'key는 어떤 노드를 재사용할지 판단하는 힌트일 뿐이고, 값이 서로 다르면 오히려 재사용이 잘 된다. 노드를 새로 만드는 것만으로는 다음 갱신이 예약되지 않는다.', false),
(12512, 4626, '`items.value.push`가 배열을 새 객체로 바꾸지 않아 변경 감지가 계속 다시 일어난다.', 'Vue 3의 반응형 프록시는 제자리 변경도 그대로 잡아내며, push 한 번은 갱신 한 번만 예약한다. 배열을 새로 만들지 않아 감지가 되풀이되는 일은 없다.', false),
(12513, 4626, '갱신이 끝난 뒤 실행되는 훅에서 화면에 그려지는 상태를 다시 바꿔, 그 변경이 또 갱신을 부르며 서로를 되풀이한다.', 'onUpdated는 DOM 패치 뒤에 불리는데 그 안에서 바꾼 renderedAt을 템플릿이 그리고 있으므로 갱신이 다시 예약되고, 그 갱신이 끝나면 훅이 또 불린다. 갱신 후 DOM 작업은 원인이 되는 상태를 지정한 감시자에 flush: ''post''를 주는 편이 안전하다.', true),
(12514, 4626, '`<script setup>` 최상위에 훅을 둬서 렌더가 일어날 때마다 같은 훅이 새로 등록되고, 등록 수만큼 로그가 늘어난다.', '최상위 코드는 setup 시점에 한 번만 실행되므로 등록도 한 번뿐이다. 같은 훅을 여러 번 등록할 수는 있지만, 그것은 한 갱신에서 찍히는 줄 수를 늘릴 뿐 갱신을 스스로 다시 부르지는 않는다.', false),

-- 문제 4627
(12515, 4627, '`users`에 항목을 더 넣어도 마운트 때 모인 세 칸 그대로 고정돼, 새 요소는 참조를 따로 만들어야 잡을 수 있다.', '이 참조는 렌더가 끝날 때마다 그 시점의 요소들로 다시 채워진다. 마운트 때 한 번 찍고 마는 값이 아니라서 항목이 늘면 담기는 개수도 따라 늘어난다.', false),
(12516, 4627, '`onMounted` 대신 `onBeforeMount`에서 읽어도 같은 요소 세 개가 들어 있다.', 'onBeforeMount는 최초 렌더 함수가 돌기 전이라 요소가 아직 만들어지지 않았다. 템플릿 ref가 채워지는 것은 렌더 결과가 문서에 삽입된 뒤다.', false),
(12517, 4627, '`:key`를 인덱스로 바꿔야 담긴 순서가 `users`의 순서와 맞춰진다.', 'key는 갱신 때 어떤 노드를 재사용할지 판단하는 힌트일 뿐 참조가 모이는 순서를 정하지 않는다. 오히려 인덱스 key는 항목이 중간에 끼어들 때 노드 재사용을 어긋나게 한다.', false),
(12518, 4627, '담긴 요소의 순서가 `users`의 순서와 같다는 보장이 없어, 특정 항목의 요소를 인덱스로 집으면 어긋날 수 있다.', 'v-for 안의 ref는 배열로 모이지만 수집 순서가 소스 배열 순서와 일치한다는 보장은 없다. 항목별 요소가 꼭 필요하면 ref를 함수로 받아 항목과 짝지어 저장하는 편이 안전하다.', true),

-- 문제 4628
(12519, 4628, '라우트를 옮겨도 컴포넌트가 캐시에 남아 제거 절차에 들어가지 않아, 훅 호출이 뒤로 미뤄진 것이다.', '캐시는 KeepAlive로 감쌌을 때만 생기고, 그때도 제거 대신 비활성 훅이 불린다. 감싸지 않은 컴포넌트는 화면에서 빠지는 순간 제거 절차를 밟는다.', false),
(12520, 4628, 'Vue 3에서 제거 단계 훅의 이름이 unmount 계열로 바뀌어, 옛 이름으로 적어 둔 함수는 훅으로 인식되지 않는다.', 'beforeDestroy·destroyed는 Vue 3에서 beforeUnmount·unmounted로 이름만 바뀌었고 불리는 시점은 같다. 옛 이름은 옵션 객체의 평범한 속성으로 취급돼 아무 때도 불리지 않으므로, 이름만 바꿔 주면 그대로 동작한다.', true),
(12521, 4628, 'Vue 3는 제거 단계 훅을 `setup` 안에서 등록한 것만 인정하므로, 옵션 객체에 적은 함수는 무시된다.', '옵션 객체에 적어도 beforeUnmount·unmounted는 그대로 불린다. 표에서 created·mounted가 Vue 3에서도 찍히는 것처럼, 갈리는 지점은 등록 방식이 아니라 훅 이름이다.', false),
(12522, 4628, 'Vue 3는 제거 단계 훅을 탭이나 창을 완전히 닫을 때만 부르므로, 화면 전환 정도로는 호출되지 않는다.', '컴포넌트가 화면에서 빠지는 순간이 곧 제거 시점이며 브라우저를 닫는 것과는 무관하다. 오히려 창을 닫을 때는 훅이 불리지 않을 수 있어 정리 작업을 그 시점에 기대면 안 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1498, 4629, 'onMounted,onMounted(),mounted,mounted(),온마운티드', 'DOM은 최초 렌더 결과가 문서에 삽입된 뒤에야 존재하는데, `<script setup>` 최상위 코드는 그보다 이른 setup 시점에 실행된다. 그래서 최상위에서는 querySelector도 템플릿 ref도 null이고, 이미 마운트가 끝난 뒤 실행되는 버튼 핸들러에서는 같은 코드가 요소를 잡는다. 문서 삽입이 끝난 직후 한 번 불리는 훅이 onMounted라서 DOM 측정·외부 라이브러리 초기화·이벤트 등록은 이 안에 둔다. 상태만 준비하는 setup, 렌더 직전이라 아직 요소가 없는 onBeforeMount, 최초 렌더에는 불리지 않는 onUpdated와 구분해야 한다. 서버 렌더 환경에서 window·document를 만지는 코드를 이 훅 안에 두라고 하는 것도, onMounted가 서버에서는 실행되지 않기 때문이다.'),
       (1499, 4630, 'flush: ''post'',flush:''post'',{ flush: ''post'' },{flush:''post''},post,''post'',flush post', '상태 변경은 곧바로 DOM에 반영되지 않고 큐에 모였다가 마이크로태스크에서 한 번에 렌더된다. 감시자 콜백은 기본값인 flush: ''pre''에서 그 렌더보다 먼저 실행되므로, 콜백 안에서 읽은 scrollHeight는 방금 추가된 메시지가 빠진 옛 높이가 되고 스크롤이 한 칸씩 뒤처진다. 세 번째 인자에 { flush: ''post'' }를 주면 콜백이 DOM 갱신 뒤로 밀려 새 높이를 읽는다. 콜백 첫 줄에서 await nextTick()을 해도 결과는 같지만, 상태가 바뀔 때마다 DOM을 다뤄야 하는 경우라면 옵션 한 줄로 선언해 두는 쪽이 빠뜨림이 적다. 모든 갱신에 반응하는 onUpdated와 달리 원인이 되는 상태만 좁혀 본다는 점도 다르다.');

-- =====================================================
-- Lesson 899: Vue 생명주기 훅의 호출 순서와 정리 책임
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5573, 899, '아래 코드에서 `Parent`가 처음 마운트될 때 콘솔에 찍히는 순서는?', '```typescript
// useLogger.ts
import { onMounted } from ''vue''

export function useLogger(name: string) {
  onMounted(() => console.log(name))
}
```

```vue
<!-- Child.vue -->
<script setup lang="ts">
import { onMounted } from ''vue''

onMounted(() => console.log(''C''))
</script>
```

```vue
<!-- Parent.vue -->
<script setup lang="ts">
import { onMounted } from ''vue''
import Child from ''./Child.vue''
import { useLogger } from ''./useLogger''

onMounted(() => console.log(''P1''))
useLogger(''L'')
onMounted(() => console.log(''P2''))
</script>

<template>
  <Child />
</template>
```', 'OBJECTIVE'),
       (5574, 899, '아래 컴포넌트가 마운트된 뒤 ①~③에서 찍히는 `chartEl.value`를 순서대로 나열한 것은?', '```vue
<script setup lang="ts">
import { ref, onMounted, nextTick } from ''vue''

const loaded = ref(false)
const chartEl = ref<HTMLElement | null>(null)

onMounted(async () => {
  console.log(chartEl.value)        // ①
  const stats = await fetchStats()  // 응답까지 약 300ms
  loaded.value = true
  console.log(chartEl.value)        // ②
  await nextTick()
  console.log(chartEl.value)        // ③
  drawChart(chartEl.value, stats)
})
</script>

<template>
  <p v-if="!loaded">불러오는 중…</p>
  <div v-else ref="chartEl"></div>
</template>
```', 'OBJECTIVE'),
       (5575, 899, '아래 컴포넌트가 화면에서 제거된 뒤에도 해제되지 않고 남는 것은?', '```vue
<script setup lang="ts">
import { ref, watch, onMounted, onUnmounted } from ''vue''

const query = ref('''')
let timer: ReturnType<typeof setInterval>

watch(query, (q) => search(q))

onMounted(() => {
  timer = setInterval(poll, 5000)
  window.addEventListener(''resize'', onResize)
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>

<template>
  <input v-model="query" />
  <button @click="save">저장</button>
</template>
```

`search`·`poll`·`onResize`·`save`는 같은 파일 아래쪽에 정의돼 있다.', 'OBJECTIVE'),
       (5576, 899, '아래 서버 사이드 렌더링(SSR) 결과에서 `A.vue`만 서버 렌더에 실패한 이유로 옳은 것은?', '```vue
<!-- A.vue -->
<script setup lang="ts">
import { ref } from ''vue''

const width = ref(window.innerWidth)
</script>
```

```vue
<!-- B.vue -->
<script setup lang="ts">
import { ref, onMounted } from ''vue''

const width = ref(0)

onMounted(() => {
  width.value = window.innerWidth
})
</script>
```

| 컴포넌트 | 서버 렌더 결과 | 브라우저에서 연 뒤 `width` |
| --- | --- | --- |
| `A.vue` | `ReferenceError: window is not defined` | 페이지가 뜨지 않음 (500 오류) |
| `B.vue` | 성공 | 1,280 (실제 창 너비) |', 'OBJECTIVE'),
       (5577, 899, '아래 표의 `???` 자리에 들어가는 생명주기 훅의 이름은?', '채팅방 맨 위의 이전 대화 보기 버튼을 누를 때마다 과거 메시지 20개가 목록 앞쪽에 붙는다. 읽던 메시지가 화면 아래로 밀려나지 않도록, 두 훅에서 목록 상자의 `scrollHeight`를 읽고 그 차이만큼 `scrollTop`을 더했다.

| 클릭 | 값을 읽은 곳 | `scrollHeight` |
| --- | --- | --- |
| 1번째 | `???` 안 | 1,600 |
| 1번째 | `onUpdated` 안 | 2,400 |
| 2번째 | `???` 안 | 2,400 |
| 2번째 | `onUpdated` 안 | 3,200 |

두 번 모두 800만큼 보정되어 읽던 메시지가 제자리에 머물렀다.', 'SUBJECTIVE'),
       (5578, 899, '아래 상황에서 `clearInterval(timer)`를 옮겨 넣어야 하는 생명주기 훅의 이름은?', '탭 영역은 아래처럼 감싸져 있고, 주식 탭(`StockTab`)은 1초마다 시세를 요청한다.

```vue
<!-- App.vue -->
<template>
  <KeepAlive>
    <component :is="currentTab" />
  </KeepAlive>
</template>
```

```typescript
// StockTab.vue의 <script setup>
onMounted(() => { timer = setInterval(fetchPrice, 1000) })
onUnmounted(() => { clearInterval(timer) })
```

뉴스 탭으로 옮겨 가도 시세 요청이 1초마다 계속 나간다. 주식 탭으로 돌아오면 입력해 두었던 종목 검색어가 그대로 남아 있고, `onMounted`는 처음 한 번만 실행됐다. 탭을 열 번 오가는 동안 `onUnmounted`는 한 번도 호출되지 않았다. 다른 탭을 보는 동안에는 시세 요청이 멈추게 하려 한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5573
(15035, 5573, 'P1 → L → P2 → C', '부모가 먼저 마운트를 마친다고 본 것. 부모는 렌더 도중 자식을 만나 자식의 마운트부터 끝내므로 자식의 onMounted가 먼저 찍힌다. 그래서 부모의 onMounted에서는 자식 DOM이 이미 존재한다.', false),
(15036, 5573, 'C → P1 → P2 → L', '컴포저블 안의 훅은 컴포넌트가 직접 등록한 훅 뒤로 밀린다고 본 것. useLogger는 setup 도중 동기적으로 호출돼 그 안의 onMounted도 그 자리에서 Parent 인스턴스에 등록된다. 실행 순서는 정의한 파일이 아니라 등록한 순서를 따른다.', false),
(15037, 5573, 'C → P1 → L → P2', '자식이 먼저 마운트를 마쳐 C가 가장 앞선다. Parent에는 같은 훅이 세 번 등록됐고 훅은 등록한 순서대로 실행되므로, P1 다음에 useLogger 안에서 등록된 L, 그다음 P2가 찍힌다.', true),
(15038, 5573, 'C → P2', '같은 훅을 다시 등록하면 앞의 것을 덮어쓴다고 본 것. 훅은 목록에 차례로 쌓이는 방식이라 여러 번 등록해도 모두 실행된다. 컴포저블마다 자기 뒷정리를 onUnmounted에 따로 넣을 수 있는 것도 이 덕분이다.', false),

-- 문제 5574
(15039, 5574, '`null` → `null` → `<div>` 요소', '마운트 시점에는 loaded가 false라 div가 없어 ①은 null이다. loaded를 바꿔도 그 변경은 갱신 큐에 등록될 뿐이라 ②도 null이고, nextTick으로 렌더를 기다린 ③에서야 새로 생긴 div가 참조에 채워진다.', true),
(15040, 5574, '`<div>` 요소 → `<div>` 요소 → `<div>` 요소', 'onMounted면 템플릿의 모든 ref가 채워져 있다고 본 것. 마운트 때 렌더되지 않은 요소는 참조할 대상이 없다. v-if로 가려진 요소의 ref는 조건이 참이 되어 실제로 렌더된 뒤에야 채워진다.', false),
(15041, 5574, '`null` → `<div>` 요소 → `<div>` 요소', '상태를 바꾼 그 줄에서 DOM이 곧바로 고쳐진다고 본 것. Vue는 변경을 큐에 모았다가 현재 동기 코드가 끝난 뒤 마이크로태스크에서 렌더하므로, 바로 다음 줄인 ②에서는 div가 아직 없다.', false),
(15042, 5574, '`null` → `null` → `null`', '템플릿 ref가 마운트 때 한 번만 정해진다고 본 것. 참조는 렌더가 끝날 때마다 그 시점에 존재하는 요소로 다시 채워지므로, 나중에 v-else 쪽 div가 생기면 그 요소가 담긴다.', false),

-- 문제 5575
(15043, 5575, '`query`를 지켜보는 `watch` 감시자', '감시자도 직접 멈춰야 한다고 본 것. setup 중에 만든 감시자는 그 컴포넌트에 묶여 있어 언마운트될 때 Vue가 자동으로 해제한다. computed도 같은 방식으로 정리된다.', false),
(15044, 5575, '저장 버튼에 `@click`으로 붙인 핸들러', '모든 이벤트 리스너를 손수 떼야 한다고 본 것. 템플릿으로 붙인 핸들러는 Vue가 요소를 만들 때 붙이고 요소와 함께 걷어 내므로 따로 해제할 필요가 없다.', false),
(15045, 5575, '5초마다 `poll`을 부르는 `setInterval` 타이머', 'onUnmounted는 정리하기에 늦다고 본 것. 이 훅도 제거 과정에서 반드시 호출되므로 여기 둔 clearInterval로 타이머는 멈춘다. 제거 직전의 DOM이 필요한 정리라면 요소가 아직 남아 있는 onBeforeUnmount를 쓴다.', false),
(15046, 5575, '`window`에 등록한 `resize` 리스너', '전역 객체에 직접 붙인 리스너는 Vue가 추적하지 않는 자원이라 removeEventListener로 직접 떼야 한다. 빠뜨리면 컴포넌트가 사라진 뒤에도 창 크기가 바뀔 때마다 onResize가 실행되며 메모리 누수가 생긴다.', true),

-- 문제 5576
(15047, 5576, '서버가 브라우저 전역을 흉내 낸 객체를 준비하는데, `B.vue`의 `onMounted`는 그 준비가 끝난 뒤에 실행된다.', 'SSR 서버에 가짜 window가 마련된다고 본 것. 서버에는 window·document가 없고, onMounted는 애초에 서버에서 실행되지 않는다. B가 성공한 것은 그 코드가 서버에서 한 번도 돌지 않았기 때문이다.', false),
(15048, 5576, '최상위 코드는 서버에서도 실행되지만 `onMounted`는 브라우저에서만 실행되어, `A.vue`만 서버에서 `window`를 읽었다.', '최상위 코드는 setup 시점에 실행되는데, 서버도 HTML을 만들려면 setup을 돌려 상태를 준비해야 한다. 반면 onMounted·onUnmounted는 서버에서 실행되지 않으므로 window·document 접근은 이 훅 안에 두는 편이 안전하다.', true),
(15049, 5576, '서버에서는 `setup`이 실행되지 않으므로, `A.vue`의 오류는 렌더가 아니라 파일을 불러오는 단계에서 났다.', 'setup이 브라우저 전용이라고 본 것. 서버는 초기 상태가 담긴 HTML을 만들기 위해 setup을 실행하며, script setup의 최상위 코드도 그때 함께 실행된다. 오류는 바로 그 실행 도중에 난 것이다.', false),
(15050, 5576, '`B.vue`의 `onMounted`에서 난 오류는 경고로만 남아, 서버에서 실패했어도 결과에 드러나지 않았을 뿐이다.', '훅 안의 오류가 조용히 삼켜진다고 본 것. 브라우저에서 width에 실제 창 너비가 들어간 것처럼 B의 onMounted는 브라우저에서 정상 실행됐고, 서버에서는 아예 호출되지 않아 오류가 날 일이 없었다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1814, 5577, 'onBeforeUpdate,onBeforeUpdate(),beforeUpdate,beforeUpdate(),on before update,before update,온비포업데이트,온 비포 업데이트', 'onBeforeUpdate는 상태 변경으로 재렌더가 일어나 DOM이 패치되기 직전에 호출되므로, 그 안에서 읽은 DOM은 아직 이전 상태다. 표에서 ???는 클릭할 때마다 호출되며 목록이 늘어나기 전 높이(1,600, 2,400)를 읽었고, 패치가 끝난 뒤 불리는 onUpdated는 이미 늘어난 높이(2,400, 3,200)를 읽었다. 이 차이만큼 scrollTop을 더하면 읽던 위치가 유지되며, 이렇게 갱신 전 스크롤 위치를 저장해 두는 것이 이 훅의 대표 용도다. 최초 렌더 직전에 한 번만 불려 DOM이 아직 없는 onBeforeMount, 최초 마운트 때 한 번만 불리는 onMounted는 클릭마다 값을 읽을 수 없고, onUpdated는 패치가 끝난 뒤라 늘어난 높이만 보인다는 점에서 구분된다.'),
       (1815, 5578, 'onDeactivated,onDeactivated(),deactivated,deactivated(),on deactivated,온디액티베이티드,온 디액티베이티드', 'KeepAlive로 감싼 컴포넌트는 다른 탭으로 전환돼도 제거되지 않고 캐시에 보관된다. 돌아왔을 때 검색어가 남아 있고 onMounted가 다시 실행되지 않았으며 onUnmounted가 한 번도 불리지 않은 것이 그 근거다. 캐시된 컴포넌트는 화면에서 빠질 때 onDeactivated, 다시 나타날 때 onActivated가 호출되므로 타이머 정지는 onDeactivated에, 재시작은 onActivated에 둔다. onActivated는 최초 마운트 때도, onDeactivated는 최종 제거 때도 호출되므로 이 한 쌍만으로 시작과 정리의 짝이 맞는다. onBeforeUnmount·onUnmounted는 캐시에서 실제로 제거될 때만 불리고, onActivated는 탭으로 돌아올 때라 멈춰야 할 시점과 반대다.');
