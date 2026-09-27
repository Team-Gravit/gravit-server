-- Unit: Composition API와 Options API (Unit ID: 154)
-- Chapter: Vue.js (Chapter ID: 14)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (580, 154, 'mixin 충돌과 script setup'),
       (738, 154, '관심사 분산과 컴포저블 호출 위치'),
       (896, 154, '컴포저블 작성 규칙과 두 API의 실무 차이');

-- =====================================================
-- Lesson 580: mixin 충돌과 script setup
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3659, 580, '아래 컴포넌트를 마운트했을 때 콘솔에 출력되는 값은?', '```javascript
const paginationMixin = {
  data() { return { page: 1, size: 20 } },
  methods: { next() { this.page += 1 } },
}

const listMixin = {
  data() { return { page: 5 } },
  methods: { next() { this.page += 10 } },
}

export default {
  mixins: [paginationMixin, listMixin],
  mounted() {
    this.next()
    console.log(this.page)
  },
}
```', 'OBJECTIVE'),
       (3660, 580, '아래 비교표를 바탕으로 두 컴포넌트 작성 스타일에 대한 설명으로 옳지 않은 것은?', '| 항목 | Options API | Composition API |
| --- | --- | --- |
| 코드 구성 단위 | 옵션 종류(data·computed·methods) | 기능(관심사) 단위 |
| 로직 재사용 수단 | mixin 병합 | use로 시작하는 함수 호출 |
| 상태 접근 | this로 인스턴스 속성 참조 | setup 안의 클로저 변수 참조 |
| TypeScript | defineComponent 등 추가 장치 필요 | 일반 함수 반환 타입으로 추론 |
| 사용 가능 버전 | Vue 2 · Vue 3 모두 | Vue 3 기본, Vue 2.7부터 백포트 |', 'OBJECTIVE'),
       (3661, 580, '아래 컴포넌트에서 버튼을 세 번 클릭한 뒤의 동작으로 옳은 것은?', '```typescript
// composables/useCounter.ts
import { reactive } from ''vue''

export function useCounter() {
  const state = reactive({ count: 0 })
  const increment = () => { state.count += 1 }
  return { count: state.count, increment }
}
```

```vue
<script setup lang="ts">
import { useCounter } from ''@/composables/useCounter''

const { count, increment } = useCounter()
</script>

<template>
  <button @click="increment">{{ count }}</button>
</template>
```', 'OBJECTIVE'),
       (3662, 580, '아래 코드를 실행한 직후 order.offset.value와 refund.offset.value의 값은?', '```typescript
// composables/usePagination.ts
export function usePagination(size: number) {
  const page = ref(1)
  const offset = computed(() => (page.value - 1) * size)
  const next = () => { page.value += 1 }
  return { page, offset, next }
}
```

```vue
<script setup lang="ts">
const order = usePagination(10)
const refund = usePagination(25)

order.next()
order.next()
refund.next()
</script>
```', 'OBJECTIVE'),
       (3663, 580, '아래 상황에서 문제가 된 Vue 2의 로직 재사용 방식을 부르는 이름은?', 'Vue 2로 만든 목록 화면 컴포넌트를 넘겨받았다. 템플릿과 methods에서 this.page를 쓰는데, 정작 컴포넌트 파일 어디에도 page를 선언한 곳이 없어 값의 출처를 찾으려면 다른 파일을 하나씩 열어 봐야 했다. 재사용 모듈 하나를 더 얹은 뒤로는 잘 돌던 reset()이 다른 동작을 하기 시작했지만, 빌드 오류도 경고도 뜨지 않았다. Vue 3에서도 이 방식은 하위 호환용으로만 남아 있고, 공식 문서는 신규 코드에서 컴포저블을 쓰라고 권한다.', 'SUBJECTIVE'),
       (3664, 580, '아래 상황에서 두 번째로 사용한 Vue 3 단일 파일 컴포넌트 문법의 이름은?', '같은 카운터 컴포넌트를 Vue 3에서 두 가지 방식으로 작성해 비교했다. 처음 방식에서는 count와 increment를 객체에 담아 반환하지 않으면 템플릿에서 값이 undefined로 찍혔다. 두 번째 방식으로 다시 쓰자 반환 구문이 통째로 사라졌고, 최상위에 선언한 const count와 const increment가 그대로 템플릿에 나타났다. 게다가 defineProps와 defineEmits를 import 없이 바로 쓸 수 있었으며, 빌드된 결과물의 런타임 동작은 두 방식이 같았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3659
(9931, 3659, '2', '앞에 등록한 mixin이 우선한다고 본 계산이다. paginationMixin의 page=1에 next()가 1을 더한 값인데, 병합 규칙은 그 반대다.', false),
(9932, 3659, '15', '같은 이름의 data·methods는 뒤에 등록한 mixin이 오류나 경고 없이 덮어쓴다. page는 listMixin의 5, next()도 listMixin의 +10이 남아 15가 된다.', true),
(9933, 3659, '6', 'data는 뒤(page=5), methods는 앞(+1)이 남는다고 본 것이다. 옵션 종류에 따라 우선순위가 갈리지 않고 둘 다 나중 mixin이 이긴다.', false),
(9934, 3659, '11', 'page는 앞의 1, next()는 뒤의 +10을 섞어 본 것이다. 충돌한 항목마다 나중 mixin이 이기므로 page와 next()가 서로 다른 mixin에서 오지 않는다.', false),

-- 문제 3660
(9935, 3660, '검색·페이징·모달이 한 화면에 섞여 있을 때, 기능 하나의 코드를 한자리에 모으기 쉬운 쪽은 Composition API다.', '참인 진술이다. Options API는 코드를 옵션 종류로 나누므로 기능 하나가 여러 블록에 흩어지고, Composition API는 구성 단위가 기능이라 한 덩어리로 묶어 둘 수 있다.', false),
(9936, 3660, '재사용 로직에서 온 값의 출처를 파일 상단 import 문으로 확인할 수 있는 쪽은 Composition API다.', '참인 진술이다. 함수를 import해 호출하고 반환값을 받으므로 출처가 코드에 드러난다. mixin 병합은 컴포넌트 코드에 흔적을 남기지 않아 파일을 열어 봐야 한다.', false),
(9937, 3660, 'Composition API도 상태를 this에 담아 두므로, 메서드를 화살표 함수로 쓸 때 this 바인딩에 주의해야 한다.', '거짓이라 정답이다. 표의 상태 접근 항목대로 Composition API는 setup 안의 클로저 변수를 그대로 참조해 this를 쓰지 않는다. this 주의는 Options API 쪽 이야기다.', true),
(9938, 3660, '같은 컴포넌트를 Vue 2.6 프로젝트로 그대로 옮길 때 별도 도입 작업이 필요한 쪽은 Composition API다.', '참인 진술이다. 표에서 Composition API는 Vue 2.7부터 백포트됐으므로 2.6에서는 별도 플러그인을 붙여야 한다. Options API는 Vue 2에서 그대로 동작한다.', false),

-- 문제 3661
(9939, 3661, '버튼에 찍힌 숫자가 클릭할 때마다 1씩 늘어 0에서 3으로 바뀐다.', 'reactive 객체의 속성을 반환하면 반응형 연결까지 함께 넘어간다고 본 오해다. 반환문에서 state.count를 꺼내는 순간 숫자 0이 복사돼 담기므로 이후 변경이 템플릿에 전달되지 않는다.', false),
(9940, 3661, '버튼에 찍힌 숫자는 0 그대로이고, 컴포저블 안의 state.count도 계속 0에 머무른다.', '반환된 값이 state의 복사본이라 increment도 원본을 못 바꾼다고 본 오해다. increment는 클로저로 state를 직접 참조하므로 클릭할 때마다 state.count는 실제로 늘어난다.', false),
(9941, 3661, '버튼에 찍힌 숫자는 0 그대로이지만, 템플릿을 count.value로 고쳐 쓰면 3이 표시된다.', '반환된 count를 ref로 본 오해다. reactive 객체에서 꺼낸 속성은 ref가 아니라 그냥 숫자라 .value 자체가 없고, 표기를 바꿔도 값은 갱신되지 않는다.', false),
(9942, 3661, '버튼에 찍힌 숫자는 0에 머무르지만, 컴포저블 안의 state.count는 3까지 늘어난다.', 'reactive 객체의 속성 값을 꺼내 반환하면 그 자리에서 반응형 연결이 끊긴다. 템플릿이 보는 count는 숫자 0으로 고정되고 increment가 바꾸는 state.count만 늘어난다. toRefs로 감싸거나 ref를 반환해야 한다.', true),

-- 문제 3662
(9943, 3662, '20과 25', '호출할 때마다 함수 안에서 page ref가 새로 만들어져 두 벌의 상태가 독립한다. order는 page=3이라 (3-1)×10=20, refund는 page=2라 (2-1)×25=25다.', true),
(9944, 3662, '20과 50', 'refund가 order의 next() 호출까지 함께 받는다고 본 것(page=3)이다. 컴포저블은 호출 시점에 새 상태를 만들므로 두 호출이 서로의 page를 건드리지 않는다.', false),
(9945, 3662, '30과 25', 'offset 계산에서 page - 1이 아니라 page를 그대로 곱했다(3×10). 첫 페이지의 offset이 0이 되도록 1을 빼는 것이 이 계산의 핵심이다.', false),
(9946, 3662, '50과 50', '나중 호출이 앞 호출의 상태를 덮어쓴다고 본 것으로, mixin 병합 규칙을 컴포저블에 잘못 옮긴 오해다. 함수 호출은 서로를 덮어쓰지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1176, 3663, 'mixin,mixins,믹스인,믹스인 패턴,vue mixin', '옵션 객체를 컴포넌트에 병합해 로직을 재사용하는 Vue 2의 방식이 mixin이다. 지문의 증상이 곧 mixin의 대표 단점 세 가지다. this.page의 선언 위치가 컴포넌트 코드에 남지 않는 출처 불명확, 같은 이름의 data·methods를 나중 것이 조용히 덮어써 reset()의 동작이 바뀌는 이름 충돌, 그리고 mixin이 컴포넌트에 있을 것이라 가정한 속성을 쓰는 암묵적 결합이다. 같은 재사용이라도 컴포저블은 import로 출처가 보이고 반환값을 구조 분해할 때 이름을 바꿀 수 있어 이 문제들이 생기지 않는다. 부모가 자식에게 값을 내려 주는 props, 상위에서 하위 트리 전체로 값을 전달하는 provide/inject는 데이터 전달 수단이지 로직 재사용 수단이 아니라는 점에서 구분된다.'),
       (1177, 3664, '<script setup>,script setup,스크립트 셋업,스크립트 setup,script setup 문법', 'Composition API를 단일 파일 컴포넌트에서 간결하게 쓰도록 만든 컴파일 타임 문법 설탕이 <script setup>이다. 컴파일 단계에서 결국 setup() 함수 형태로 바뀌므로 런타임 동작은 이전 방식과 같고, 최상위에 선언한 변수·함수가 자동으로 템플릿에 노출돼 반환 구문이 필요 없다. defineProps·defineEmits 같은 컴파일러 매크로도 import 없이 바로 쓸 수 있다. ref·computed·watch 같은 API 묶음 자체를 가리키는 Composition API와, 그 API를 SFC에서 쓰기 편하게 감싼 문법인 <script setup>을 구분해야 한다. setup() 옵션도 여전히 유효하며 <script setup>은 그 축약형이다.');

-- =====================================================
-- Lesson 738: 관심사 분산과 컴포저블 호출 위치
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4607, 738, '아래 컴포넌트에서 버튼을 눌러 패널을 연 뒤 창 크기를 바꿨을 때 일어나는 일로 옳은 것은?', '```javascript
// composables/useWindowWidth.js
import { ref, onMounted, onUnmounted } from ''vue''

export function useWindowWidth() {
  const width = ref(window.innerWidth)
  const update = () => { width.value = window.innerWidth }
  onMounted(() => window.addEventListener(''resize'', update))
  onUnmounted(() => window.removeEventListener(''resize'', update))
  return { width }
}
```

```vue
<!-- SizePanel.vue - 이미 화면에 마운트돼 있는 컴포넌트 -->
<script setup>
import { ref } from ''vue''
import { useWindowWidth } from ''@/composables/useWindowWidth''

const panelWidth = ref(0)

// 아래 함수는 버튼을 클릭한 뒤에야 실행된다
function openPanel() {
  const { width } = useWindowWidth()
  panelWidth.value = width.value
}
</script>

<template>
  <button @click="openPanel">패널 열기</button>
  <p>{{ panelWidth }}</p>
</template>
```', 'OBJECTIVE'),
       (4608, 738, '아래 컴포넌트 작성 스타일에 대한 설명으로 옳은 것은?', 'Vue 컴포넌트를 data·computed·watch·methods 같은 옵션 블록으로 나눠 작성하는 스타일이다. 각 블록에 적어 둔 항목을 Vue가 컴포넌트 인스턴스에 합쳐 주며, 상태와 메서드는 모두 this를 거쳐 참조한다.', 'OBJECTIVE'),
       (4609, 738, '아래 컴포넌트에서 검색 기능과 관련된 코드가 걸쳐 있는 옵션 블록은 모두 몇 개인가?', '```javascript
export default {
  data() {
    return { keyword: '''', results: [], page: 1, isModalOpen: false }
  },
  computed: {
    hasResult() { return this.results.length > 0 },
    offset() { return (this.page - 1) * 20 },
  },
  watch: {
    keyword() { this.page = 1; this.search() },
  },
  methods: {
    search() { /* keyword로 서버를 조회해 results를 채운다 */ },
    next() { this.page += 1 },
    openModal() { this.isModalOpen = true },
  },
  mounted() {
    this.search()
  },
  beforeUnmount() {
    this.isModalOpen = false
  },
}
```', 'OBJECTIVE'),
       (4610, 738, '아래 코드에서 ItemList 컴포넌트를 마운트했을 때 일어나는 일로 옳은 것은?', '```javascript
// mixins/fetchMixin.js
export const fetchMixin = {
  methods: {
    fetchItems() {
      return api.get(`/users/${this.userId}/items`)
    },
  },
  mounted() {
    this.fetchItems()
  },
}
```

```javascript
// UserDashboard.vue - fetchMixin을 먼저 쓰고 있던 화면
export default {
  mixins: [fetchMixin],
  data() { return { userId: 7 } },
}

// ItemList.vue - 같은 mixin을 새로 적용한 화면
export default {
  mixins: [fetchMixin],
  data() { return { sort: ''recent'' } },
}
```', 'OBJECTIVE'),
       (4611, 738, '아래 상황에서 팀이 새로 도입한 로직 재사용 단위를 부르는 이름은?', 'Vue 3 프로젝트의 목록 화면 여섯 곳이 같은 페이징 코드를 복사해 쓰고 있었다. 오프셋 계산을 한 번 고칠 때마다 여섯 파일을 똑같이 손봐야 했고, 한 곳을 빠뜨려 장애가 난 적도 있다. 팀은 page와 offset, next를 만들어 돌려주는 usePagination 파일 하나를 두고 각 화면이 이를 import해 쓰도록 바꿨다. 이후 고칠 곳이 한 군데로 줄었고, 한 화면에서 목록용과 이력용으로 두 번 불러도 페이지 번호가 서로 섞이지 않았다. 예전에 mixin으로 같은 일을 했을 때와 달리, 화면 코드만 봐도 값이 어디서 온 것인지 바로 보였다.', 'SUBJECTIVE'),
       (4612, 738, '아래 상황에서 반환값을 감싸 문제를 해결한 Vue 내장 함수의 이름은?', '한 컴포저블이 reactive로 만든 { page: 1, size: 20 } 객체를 그대로 반환하고 있었다. 화면에서 const { page } = usePaging()으로 받아 쓰자, 버튼을 눌러 컴포저블 안의 상태가 3까지 올라가도 화면에 찍힌 숫자는 1에서 움직이지 않았다. 반환문에서 상태를 어떤 내장 함수로 한 번 감싸자, 호출부의 구조 분해 코드를 한 글자도 고치지 않았는데 화면이 3으로 갱신됐다. 대신 스크립트에서 값을 직접 읽을 때는 page.value처럼 써야 했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4607
(12459, 4607, '창 크기를 바꿀 때마다 등록된 resize 리스너가 update를 실행해 width가 갱신되고, 화면의 panelWidth만 클릭 시점 값에 머무른다.', '리스너가 정상 등록됐다고 본 오해다. onMounted는 setup이 실행되는 동안에만 현재 인스턴스를 찾을 수 있는데, 클릭 핸들러는 그 구간이 끝난 뒤 실행되므로 등록 자체가 이뤄지지 않는다.', false),
(12460, 4607, 'resize 리스너가 아예 등록되지 않고, 콘솔에는 훅을 붙일 활성 인스턴스가 없다는 경고만 남는다.', '생명주기 훅 등록 API는 setup이 실행되는 동안 활성 인스턴스가 있을 때만 동작한다. 컴포저블을 클릭 핸들러 안에서 호출하면 onMounted·onUnmounted가 모두 버려져 리스너가 붙지 않고, Vue는 오류 대신 경고만 남긴다.', true),
(12461, 4607, 'resize 리스너는 등록되지만 onUnmounted가 무시돼, 화면을 떠난 뒤에도 리스너가 남아 메모리가 샌다.', '정리 훅만 실패한다고 본 오해다. 두 훅은 같은 조건에서 등록되므로 한쪽만 살아남지 않는다. 그 증상은 컴포저블이 onUnmounted를 아예 쓰지 않았을 때의 이야기다.', false),
(12462, 4607, 'useWindowWidth를 호출하는 순간 활성 인스턴스가 없다는 오류가 던져져 클릭 처리가 중단된다.', '규칙을 어기면 곧바로 오류로 막힌다고 본 오해다. ref 생성과 반환은 그대로 진행돼 panelWidth에는 클릭 시점의 너비가 담기고, 훅 등록만 조용히 빠진다.', false),

-- 문제 4608
(12463, 4608, '기능이 여러 개 섞인 큰 컴포넌트일수록 한 기능에 필요한 코드가 한자리에 모인다.', '정반대다. 코드를 기능이 아니라 옵션 종류로 나누므로 컴포넌트가 커질수록 기능 하나의 코드가 여러 블록에 흩어져, 수정할 때 파일 위아래를 오가며 읽어야 한다.', false),
(12464, 4608, '상태는 반드시 ref로 선언하고 읽고 쓸 때마다 .value를 붙여야 한다.', 'Composition API의 반응형 선언 방식을 갖다 붙인 오개념이다. 이 스타일에서는 data가 돌려준 객체의 속성을 Vue가 감싸 주므로 this.속성 이름으로 바로 읽고 쓴다.', false),
(12465, 4608, '코드가 놓일 자리가 정해져 있어, 기능이 하나뿐인 작은 컴포넌트에서는 구조를 파악하기 쉽다.', '옵션 종류마다 자리가 고정돼 있다는 점은 규모가 작을 때 장점이 된다. Composition API의 이점은 기능이 여럿 섞인 큰 컴포넌트에서 드러나므로 한쪽이 언제나 낫다고 말할 수 없다.', true),
(12466, 4608, 'Vue 3에서 제거돼 이 방식으로 작성한 컴포넌트는 더 이상 동작하지 않는다.', 'Vue 3가 Composition API를 기본으로 삼았다는 말을 제거로 오해한 것이다. 두 스타일은 Vue 3에서 함께 지원되며 기존 컴포넌트를 고치지 않아도 그대로 동작한다.', false),

-- 문제 4609
(12467, 4609, '2', 'data와 methods만 센 것이다. keyword를 지켜보는 watch, 검색 결과로 값을 내는 computed의 hasResult, 첫 조회를 거는 mounted도 검색 기능이 없으면 존재할 이유가 없는 코드다.', false),
(12468, 4609, '3', 'data·methods·mounted만 센 것이다. results를 보고 계산하는 hasResult와 keyword가 바뀔 때 다시 조회하는 watch까지 넣어야 이 기능의 코드를 빠짐없이 모은 것이 된다.', false),
(12469, 4609, '4', 'computed와 mounted 중 한쪽을 검색과 무관하다고 본 것이다. hasResult는 검색 결과를 재료로 삼고 mounted는 첫 검색을 실행하므로 둘 다 이 기능의 일부다.', false),
(12470, 4609, '5', 'keyword·results(data), hasResult(computed), keyword 감시(watch), search(methods), 첫 조회(mounted)까지 다섯 블록에 흩어져 있다. 모달만 다루는 beforeUnmount가 유일하게 무관하다. 코드를 기능이 아닌 종류로 나눈 결과다.', true),

-- 문제 4610
(12471, 4610, '/users/undefined/items로 요청이 나가고, 빌드할 때는 오류도 경고도 뜨지 않는다.', '재사용 모듈이 this.userId가 컴포넌트에 있을 것이라 가정했지만 새 화면에는 그 값이 없다. 이 의존 관계는 코드 어디에도 적혀 있지 않아 미리 걸러지지 않고 요청 경로에서야 드러난다.', true),
(12472, 4610, 'fetchItems가 참조하는 값이 없어 빌드가 실패하고 컴포넌트를 마운트할 수 없다.', '가져다 쓰는 값이 있는지 도구가 검사해 준다고 본 오해다. 옵션 병합은 실행 시점에 일어나고 없는 속성은 undefined로 읽힐 뿐이라 빌드는 그대로 통과한다.', false),
(12473, 4610, '먼저 쓰던 화면의 userId가 재사용 모듈에 남아 있어 7로 요청이 나간다.', '병합되는 옵션 객체가 상태까지 들고 공유한다고 본 오해다. data는 컴포넌트 인스턴스마다 새로 만들어지므로 다른 화면의 값이 넘어오지 않는다.', false),
(12474, 4610, '필요한 값이 없으므로 mounted의 fetchItems 호출이 건너뛰어져 요청이 나가지 않는다.', 'Vue가 의존 관계를 확인하고 훅을 거른다고 본 오해다. 병합된 mounted는 컴포넌트의 훅과 함께 순서대로 실행되며, 값이 없어도 호출은 그대로 일어난다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1492, 4611, '컴포저블,컴포저블 함수,composable,composables,composable function,컴포져블', '반응형 상태와 로직을 use로 시작하는 일반 함수에 담아 재사용하는 단위가 컴포저블이다. 필요한 값을 인자로 받고 결과를 반환하므로 의존 관계와 출처가 코드에 그대로 드러나고, 구조 분해할 때 이름을 바꿔 받을 수 있어 이름 충돌도 생기지 않는다. 호출할 때마다 상태가 새로 만들어지기 때문에 한 컴포넌트에서 두 번 호출해도 서로 간섭하지 않는다. 옵션 객체를 컴포넌트에 병합해 출처 불명확·이름 충돌·암묵적 결합을 낳는 mixin, 앱 전역에 기능을 설치하는 플러그인, 반응형 상태 없이 계산만 하는 유틸 함수와는 구분한다.'),
       (1493, 4612, 'toRefs,toRefs(),to refs', 'reactive는 객체 자체가 반응형이라, 구조 분해로 속성을 꺼내는 순간 그 자리의 값이 복사돼 원본과의 연결이 끊긴다. toRefs는 객체의 각 속성을 원본과 이어진 ref로 바꿔 돌려주므로 구조 분해한 뒤에도 갱신이 따라오고, 대신 값을 읽을 때 .value가 필요해진다. 속성 하나만 떼어 낼 때는 toRef, 바깥에서 고치지 못하게 넘길 때는 readonly를 쓴다. 컴포저블은 ref들을 담은 일반 객체를 반환하거나 reactive를 toRefs로 감싸 반환하는 것이 관례다. 받은 값이 ref인지 아닌지 가리지 않고 읽으려고 쓰는 unref·toValue와는 방향이 반대다.');

-- =====================================================
-- Lesson 896: 컴포저블 작성 규칙과 두 API의 실무 차이
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5555, 896, '아래 코드에서 토글 버튼을 다섯 번 누른 뒤 window에 남아 있는 resize 리스너의 개수는?', 'Dashboard를 처음 마운트한 뒤 토글 버튼을 다섯 번 눌렀다. 아래 코드 말고는 resize 리스너를 등록하는 곳이 없다.

```typescript
// composables/useWindowWidth.ts
import { ref, onMounted } from ''vue''

export function useWindowWidth() {
  const width = ref(window.innerWidth)
  const update = () => { width.value = window.innerWidth }
  onMounted(() => window.addEventListener(''resize'', update))
  return { width }
}
```

```vue
<!-- WidthBadge.vue -->
<script setup lang="ts">
import { useWindowWidth } from ''@/composables/useWindowWidth''

const { width } = useWindowWidth()
</script>

<template>
  <span>{{ width }}px</span>
</template>
```

```vue
<!-- Dashboard.vue -->
<script setup lang="ts">
import { ref } from ''vue''
import WidthBadge from ''./WidthBadge.vue''

const show = ref(true)
</script>

<template>
  <WidthBadge v-if="show" />
  <button @click="show = !show">배지 토글</button>
</template>
```', 'OBJECTIVE'),
       (5556, 896, '아래 컴포넌트를 빌드할 때 일어나는 일과 해결 방법으로 옳은 것은?', '```vue
<!-- OrderSearch.vue -->
<script setup lang="ts">
import { usePagination } from ''@/composables/usePagination''
import { useSearch } from ''@/composables/useSearch''

// 두 컴포저블 모두 page라는 이름의 ref를 반환한다.
// usePagination의 page는 주문 목록의 페이지 번호,
// useSearch의 page는 검색 결과의 페이지 번호다.
const { page, next } = usePagination(10)
const { keyword, results, page } = useSearch()
</script>
```', 'OBJECTIVE'),
       (5557, 896, '아래 컴포넌트 작성 방식에 대한 설명으로 옳은 것은?', 'Vue 컴포넌트에서 ref·computed 같은 함수를 setup 안에서 호출해 상태와 계산값을 만들고, 한 기능에 관련된 상태·계산·함수를 한곳에 모아 작성하는 방식이다. 모아 둔 코드는 일반 함수로 떼어 내 다른 컴포넌트에서도 불러 쓸 수 있다.', 'OBJECTIVE'),
       (5558, 896, '아래 두 컴포넌트의 버튼을 각각 한 번씩 눌렀을 때의 결과로 옳은 것은?', '두 파일 모두 Vite로 빌드한 Vue 3 프로젝트의 단일 파일 컴포넌트(SFC)다.

```vue
<!-- CounterA.vue -->
<script>
export default {
  data() {
    return { count: 0 }
  },
  methods: {
    increment: () => {
      this.count++
    },
  },
}
</script>

<template>
  <button @click="increment">A: {{ count }}</button>
</template>
```

```vue
<!-- CounterB.vue -->
<script setup>
import { ref } from ''vue''

const count = ref(0)
const increment = () => {
  count.value++
}
</script>

<template>
  <button @click="increment">B: {{ count }}</button>
</template>
```', 'OBJECTIVE'),
       (5559, 896, '아래 상황에서 마지막에 바꿔 쓴 Vue 내장 함수의 이름은?', '검색어를 받아 결과를 불러오는 컴포저블 useSearch(keyword)를 세 화면이 서로 다른 형태로 호출한다. A 화면은 ref로 만든 검색어를, B 화면은 () => route.query.q 같은 getter 함수를, C 화면은 고정 문자열 ''vue''를 넘긴다. 컴포저블은 watchEffect 안에서 검색어를 읽어 요청 주소를 만든다.

- 처음에 검색어를 keyword.value로 읽었을 때는 A만 제대로 요청했고, B와 C는 요청 주소에 undefined가 들어갔다.
- 읽는 부분을 unref(keyword)로 바꾸자 C는 고쳐졌지만, B는 주소에 getter 함수의 코드가 문자열로 그대로 찍혔다.
- 마지막으로 Vue 3.3에 추가된 다른 내장 함수로 바꾸자 세 화면 모두 올바른 검색어로 요청했고, B는 주소의 쿼리가 바뀔 때마다 다시 요청했다.', 'SUBJECTIVE'),
       (5560, 896, '아래 상황에서 번들 크기를 줄인 빌드 최적화 기법을 가리키는 용어는?', 'Vue 2로 만든 관리자 화면을 Vue 3로 옮기면서, 컴포넌트마다 vue 패키지에서 ref·computed·onMounted처럼 실제로 쓰는 함수만 이름을 지정해 import하도록 바꿨다. 이 앱은 템플릿 어디에서도 애니메이션용 내장 컴포넌트인 <Transition>·<TransitionGroup>을 쓰지 않는다.

프로덕션 빌드 결과를 번들 분석기로 열어 보니 두 내장 컴포넌트의 구현 코드가 결과물에 아예 없었고, 번들에서 Vue 런타임이 차지하는 몫도 이전보다 크게 줄었다. Vue 2 시절에는 nextTick 같은 기능이 Vue 전역 객체에 붙어 있어, 한 번도 부르지 않아도 늘 통째로 번들에 들어갔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5555
(14987, 5555, '0', 'Vue가 컴포넌트를 제거할 때 addEventListener로 붙인 리스너도 알아서 떼어 준다고 본 오해다. Vue는 직접 등록하지 않은 window 리스너를 추적하지 않으므로, onUnmounted에서 떼지 않으면 리스너는 그대로 남는다.', false),
(14988, 5555, '1', '같은 update를 여러 번 붙이면 중복이 무시된다고 본 것이다. update는 useWindowWidth를 호출할 때마다 새로 만들어지는 서로 다른 함수라, 마운트할 때마다 별개의 리스너로 쌓인다.', false),
(14989, 5555, '2', '다시 나타난 두 번(두 번째·네 번째 클릭)만 센 것이다. 처음 마운트될 때도 onMounted가 실행돼 리스너가 붙으므로, 마운트는 처음 1번과 다시 나타난 2번을 합쳐 모두 3번이다.', false),
(14990, 5555, '3', 'show가 true→false→true→false→true→false로 바뀌어 배지는 처음을 포함해 3번 마운트된다. 마운트마다 새 update가 붙지만 떼는 코드가 없어 배지가 사라진 지금도 3개가 남는다. onUnmounted에서 removeEventListener를 불러 정리해야 한다.', true),

-- 문제 5556
(14991, 5556, 'page를 같은 범위에서 두 번 선언했다는 오류로 컴파일이 멈추며, 한쪽을 page: searchPage처럼 바꿔 받으면 해결된다.', '구조 분해도 const 선언이라 같은 범위에 page를 두 번 선언하면 JavaScript 문법 오류가 된다. 두 값은 각 컴포저블의 반환 객체에 따로 들어 있으므로, 받을 때 이름을 바꾸면 두 상태를 충돌 없이 함께 쓸 수 있다.', true),
(14992, 5556, '뒤에 호출한 useSearch의 page가 앞의 page를 조용히 덮어쓰며, 호출 순서를 바꾸면 남는 쪽을 고를 수 있다.', 'mixin의 병합 규칙(같은 이름은 나중 것이 조용히 덮어씀)을 컴포저블에 옮겨 온 오해다. 컴포저블 반환값은 평범한 변수 선언으로 받으므로 덮어쓰기가 아니라 중복 선언 오류가 난다.', false),
(14993, 5556, '두 page가 같은 이름의 ref 하나로 합쳐져, 주문 목록 페이지를 넘기면 검색 결과 페이지도 함께 넘어간다.', '이름이 같으면 상태도 합쳐진다고 본 오해다. 각 컴포저블은 호출될 때 자기 함수 안에서 ref를 새로 만들므로 이름과 관계없이 상태가 따로 있고, 애초에 이 코드는 중복 선언 때문에 컴파일되지 않는다.', false),
(14994, 5556, '컴파일은 통과하지만 템플릿에서 page를 쓰면 어느 쪽인지 모호하다는 경고가 뜨고, 먼저 선언한 쪽이 쓰인다.', 'Vue가 이름 충돌을 실행 중에 알아서 가려 준다고 본 오해다. 같은 범위의 중복 const 선언은 JavaScript 문법 단계에서 막히므로 템플릿을 렌더링하는 단계까지 가지도 못한다.', false),

-- 문제 5557
(14995, 5557, '상태와 메서드를 this로 참조하므로, TypeScript 타입 추론을 제대로 받으려면 defineComponent 같은 장치로 감싸야 한다.', 'Options API의 특징을 갖다 붙인 오개념이다. 이 방식은 this 없이 setup 안의 변수를 클로저로 참조하고, 떼어 낸 컴포저블도 일반 함수라 반환 타입이 그대로 추론된다.', false),
(14996, 5557, 'Vue 2.6 프로젝트에서도 별도 플러그인 없이 Vue 기본 기능만으로 바로 쓸 수 있다.', 'Vue 2에서도 쓸 수 있다는 사실을 모든 2.x 버전으로 넓힌 오개념이다. 이 방식은 Vue 3의 기본이고 Vue 2.7에 백포트됐으므로, 2.6 이하에서는 @vue/composition-api 플러그인을 따로 설치해야 한다.', false),
(14997, 5557, '스크립트에서 반응형 값을 다룰 때마다 .value를 붙여야 하는 등, 반응성 원리를 먼저 익혀야 하는 입문 부담이 있다.', 'ref로 만든 값은 스크립트에서 .value를 거쳐야 하고, 반응성이 언제 이어지고 끊기는지 알아야 제대로 쓸 수 있다. 코드 자리가 정해진 Options API보다 학습 곡선이 높은 대신 기능 단위 응집과 명시적 재사용을 얻는다.', true),
(14998, 5557, '떼어 낸 함수를 여러 컴포넌트가 호출하면, 그 함수 안에서 만든 상태를 모든 컴포넌트가 하나로 공유한다.', '재사용을 상태 공유로 오해한 것이다. 함수 안에서 만든 ref는 호출할 때마다 새로 생기므로 컴포넌트마다 독립된 상태를 갖는다. 상태를 공유하려면 함수 바깥(모듈 최상위)에 두는 식으로 따로 설계해야 한다.', false),

-- 문제 5558
(14999, 5558, 'A와 B 모두 버튼의 숫자가 1로 바뀐다.', 'Vue가 methods를 인스턴스에 bind하므로 화살표 함수도 괜찮다고 본 오해다. 화살표 함수는 자기 this가 없어 bind로도 바뀌지 않고, 선언된 자리(모듈 최상위)의 this를 그대로 쓴다.', false),
(15000, 5558, 'A는 TypeError가 나며 0에 머무르고, B는 1로 바뀐다.', 'A의 화살표 함수는 this를 컴포넌트 인스턴스가 아닌 모듈 최상위의 this(undefined)로 잡아, this.count를 읽는 순간 TypeError가 난다. B는 this 없이 setup의 count를 클로저로 참조하므로 화살표 함수여도 정상 동작한다.', true),
(15001, 5558, 'A는 오류 없이 0에 머무르고, B는 1로 바뀐다.', 'A의 this가 전역 객체(window)를 가리켜 엉뚱한 곳의 값만 바뀐다고 본 오해다. SFC의 script는 ES 모듈이라 최상위 this가 undefined이므로, 조용히 넘어가지 않고 속성을 읽는 순간 오류가 난다.', false),
(15002, 5558, 'A와 B 모두 TypeError가 나며 0에 머무른다.', '화살표 함수를 쓰면 Vue에서 늘 상태를 잃는다고 일반화한 오해다. 문제는 this에 기대는 A뿐이다. B는 this를 쓰지 않고 바깥 변수 count를 직접 참조하므로 화살표 함수여도 1로 바뀐다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1808, 5559, 'toValue,toValue(),toValue 함수,to value', 'toValue는 ref를 받으면 .value를, getter 함수를 받으면 호출한 결과를, 일반 값을 받으면 그대로 돌려줘 세 가지 입력을 하나의 값으로 맞춘다. watchEffect 안에서 getter를 호출하므로 route.query.q의 변화도 추적돼 B가 쿼리가 바뀔 때마다 다시 요청한다. unref는 ref만 벗기고 나머지는 그대로 돌려주기 때문에 getter 함수가 호출되지 않은 채 주소에 들어갔다. 반응형 객체의 속성을 ref로 바꾸는 toRef·toRefs나 값을 ref로 감싸는 ref와는 방향이 반대다. 컴포저블이 입력을 이렇게 정규화해 두면 호출하는 쪽이 ref·getter·일반 값 중 무엇을 넘겨도 되므로 활용 범위가 넓어진다.'),
       (1809, 5560, '트리 셰이킹,트리셰이킹,트리 쉐이킹,트리쉐이킹,tree shaking,tree-shaking,treeshaking', '번들러가 ES 모듈의 import·export 관계를 정적으로 따라가 쓰이지 않는 export를 결과물에서 빼는 최적화가 트리 셰이킹이다. Vue 3는 ref·computed 같은 API와 <Transition> 같은 내장 컴포넌트를 이름 있는 export로 나눠 두었고, 템플릿 컴파일러도 실제로 쓴 기능만 import하는 코드를 만들어 주므로 쓰지 않은 기능이 번들에 들어가지 않는다. Vue 2는 기능이 Vue 전역 객체 하나에 붙어 있어 쓰는지 여부를 정적으로 가려낼 수 없었다. 공백과 변수 이름을 줄여 파일을 작게 만드는 코드 압축(minification)은 코드 자체를 남기고, 코드를 여러 조각으로 나눠 필요할 때 불러오는 코드 분할(code splitting)은 전체 코드 양을 줄이지 않는다는 점에서 구분된다.');
