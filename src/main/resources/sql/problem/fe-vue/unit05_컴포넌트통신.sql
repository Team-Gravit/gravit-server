-- Unit: 컴포넌트 통신 (Unit ID: 155)
-- Chapter: Vue.js (Chapter ID: 14)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (581, 155, 'props 드릴링과 Pinia 도입'),
       (739, 155, '폴스루 속성과 defineModel'),
       (897, 155, 'Vue 컴포넌트 통신 — props 반응성과 기본값, provide 탐색 범위, v-model 인자');

-- =====================================================
-- Lesson 581: props 드릴링과 Pinia 도입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3665, 581, '아래 부모·자식 컴포넌트에서 버튼을 세 번 클릭한 뒤 버튼에 표시되는 문자열은?', 'Vue 3 + `<script setup>` 환경이다.

```vue
<!-- 자식: Counter.vue -->
<script setup>
import { ref } from ''vue''
const props = defineProps({ count: Number })
const emit = defineEmits([''bump''])
const local = ref(props.count)
function onClick() {
  local.value++
  emit(''bump'')
}
</script>

<template>
  <button @click="onClick">{{ local }} / {{ count }}</button>
</template>
```

```vue
<!-- 부모: Parent.vue -->
<script setup>
import { ref } from ''vue''
import Counter from ''./Counter.vue''
const parentCount = ref(10)
</script>

<template>
  <Counter :count="parentCount" @bump="parentCount += 2" />
</template>
```', 'OBJECTIVE'),
       (3666, 581, '아래 컴포넌트 통신 방식에 대한 설명으로 옳은 것은?', '조상 컴포넌트가 `provide(ThemeKey, theme)`로 값을 등록해 두면, 중간 컴포넌트가 아무 props도 중계하지 않아도 몇 단계 아래 후손이 `inject(ThemeKey)` 한 줄로 그 값을 꺼내 쓸 수 있다. `ThemeKey`는 `Symbol`로 만든 주입 키다.', 'OBJECTIVE'),
       (3667, 581, '아래 표는 같은 기능의 Vue 2·Vue 3 표기를 비교한 것이다. 표를 바탕으로 한 설명 중 옳지 않은 것은?', '| 항목 | Vue 2 | Vue 3 |
| --- | --- | --- |
| 기본 prop 이름 | `value` | `modelValue` |
| 기본 이벤트 이름 | `input` | `update:modelValue` |
| 값 여러 개 바인딩 | `.sync` 수식어 (`:title.sync`) | `v-model:title` |
| 선언 편의 API | 없음 | `defineModel()` (3.4 이상) |

부모 쪽 사용법은 두 버전 모두 `<SearchInput v-model="keyword" />`로 같다.', 'OBJECTIVE'),
       (3668, 581, '아래 자식 컴포넌트에서 `normalize()`를 호출했을 때 (A)·(B) 두 줄에서 일어나는 일로 옳은 것은?', '부모는 `<TagChip :tag="tag" :label="label" />`로 반응형 객체 `tag`와 문자열 `label`을 내려 준다.

```vue
<!-- 자식: TagChip.vue -->
<script setup>
const props = defineProps({ tag: Object, label: String })

function normalize() {
  props.tag.name = props.tag.name.trim()   // (A)
  props.label = props.label.trim()         // (B)
}
</script>
```', 'OBJECTIVE'),
       (3669, 581, '아래 코드에서 `Sidebar`·`MenuGroup`이 겪고 있는 문제를 가리키는 용어는?', '로그인한 사용자 이름을 메뉴 항목에 표시하려고 아래처럼 고쳤다.

```vue
<!-- Layout.vue -->
<Sidebar :user="user" />

<!-- Sidebar.vue -->
<script setup>defineProps({ user: Object })</script>
<template><MenuGroup :user="user" /></template>

<!-- MenuGroup.vue -->
<script setup>defineProps({ user: Object })</script>
<template><MenuItem :user="user" /></template>

<!-- MenuItem.vue -->
<script setup>defineProps({ user: Object })</script>
<template><span>{{ user.name }}</span></template>
```

이후 메뉴에 표시할 값이 하나 늘 때마다 `Sidebar`와 `MenuGroup`의 선언도 함께 고쳐야 했다.', 'SUBJECTIVE'),
       (3670, 581, '아래 상황에서 팀이 새로 도입한 것의 이름은?', '장바구니 화면을 만들며 겪은 일이다.

- 헤더의 `CartBadge`와 상품 카드 안의 `AddToCartButton`은 트리에서 서로 남남인데 같은 담긴 개수를 봐야 한다.
- 공통 부모인 `App`까지 상태를 끌어올렸더니 중간 컴포넌트 여섯 곳이 화면에 쓰지도 않는 props와 emit을 중계하게 됐다.
- 팀은 Vue 2 때 쓰던 Vuex를 걷어내고, mutation 개념이 없고 `defineStore`로 선언하는 Vue 3 공식 권장 도구로 바꿨다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3665
(9947, 3665, '10 / 16', 'local이 반응형 ref라서 local.value++는 곧바로 화면에 반영된다. 자식 안에서 일어난 상태 변경이 렌더링에 잡히지 않는다고 본 오해.', false),
(9948, 3665, '13 / 16', 'local은 ref(props.count)로 초기값 10을 한 번 복사한 별개 상태라 클릭마다 1씩 늘어 13. count는 emit 3회를 부모가 받아 2씩 더해 16.', true),
(9949, 3665, '13 / 13', 'ref(props.count)가 props를 계속 따라간다고 본 오해. 초기값을 한 번 복사할 뿐이라 그 뒤로는 부모 값과 따로 움직인다.', false),
(9950, 3665, '16 / 16', 'emit이 부모 값을 자식 local에 되돌려 준다고 본 오해. emit은 변경 요청을 위로 올릴 뿐 자식 상태를 덮어쓰지 않는다.', false),

-- 문제 3666
(9951, 3666, '값을 꺼내는 쪽에 키가 등록돼 있지 않으면 컴파일 단계에서 오류가 나 누락을 미리 잡아 준다.', '실행 시점에 조상 체인을 거슬러 찾는 방식이라 못 찾으면 값이 undefined가 될 뿐이다. 그래서 두 번째 인자로 기본값을 주는 습관이 필요하다.', false),
(9952, 3666, '후손이 받은 값을 고치면 조상이 원래 값으로 되돌리므로 데이터 흐름이 한 방향으로 강제된다.', '반응형 객체를 그대로 제공하면 어느 후손이든 고칠 수 있고 런타임은 막지 않는다. readonly로 감싸 제공하고 변경 함수를 함께 넘겨야 흐름이 지켜진다.', false),
(9953, 3666, '트리에서 서로 무관한 형제 컴포넌트끼리도 같은 키만 쓰면 값을 주고받을 수 있다.', '값을 제공한 조상의 하위 트리 안에서만 찾을 수 있다. 형제끼리 공유하려면 공통 부모로 상태를 끌어올리거나 전역 스토어를 쓴다.', false),
(9954, 3666, '후손이 어느 조상에서 온 값인지 코드에 드러나지 않아 단독 재사용·테스트가 어려워진다.', '값의 출처가 부모 태그에 보이지 않는 암묵적 의존성이 생긴다. 그래서 테마·로케일 같은 읽기 전용 컨텍스트나 복합 컴포넌트 내부로 범위를 제한한다.', true),

-- 문제 3667
(9955, 3667, 'Vue 3에서도 `.sync` 수식어가 남아 있어 `v-model:title`과 상황에 따라 골라 쓸 수 있다.', '표에서 값 여러 개 바인딩은 Vue 2의 `.sync` 자리를 Vue 3의 `v-model:인자`가 통째로 대신한다. `.sync`는 제거돼 Vue 3에서는 쓸 수 없다.', true),
(9956, 3667, 'Vue 2 자식 컴포넌트를 Vue 3로 옮기려면 받던 prop 이름을 `value`에서 `modelValue`로 바꿔야 한다.', '부모의 `v-model`이 내려 주는 기본 prop 이름이 버전마다 달라, 이름을 맞추지 않으면 값이 자식까지 도달하지 않는다.', false),
(9957, 3667, 'Vue 3 자식이 `update:modelValue`를 emit하지 않으면 부모의 `keyword`는 갱신되지 않는다.', '`v-model`은 prop 내려 주기와 이벤트 받기를 묶은 문법 설탕이라, 자식이 약속된 이벤트를 올려야 부모가 자기 상태를 갱신한다.', false),
(9958, 3667, '`defineModel()`을 쓰면 `modelValue` prop과 `update:modelValue` emit을 따로 선언하지 않아도 된다.', '표의 선언 편의 API 자리다. 반환된 ref에 값을 대입하면 내부적으로 약속된 이벤트가 emit되므로 선언만 줄 뿐 단방향 흐름은 그대로다.', false),

-- 문제 3668
(9959, 3668, '(A)·(B) 모두 개발 모드 경고가 떠 부모의 상태는 그대로 남는다.', 'Vue가 막아 주는 것은 props 객체의 최상위 키 재할당까지다. 내려 준 객체 내부까지 지켜 주지는 않는다.', false),
(9960, 3668, '(A)는 경고가 뜨고, (B)는 경고 없이 부모의 `label`까지 바뀐다.', '두 줄의 성격을 뒤집어 본 오해. 재할당이라 걸리는 쪽은 (B)이고, 조용히 통과하는 쪽은 내부 속성을 고치는 (A)다.', false),
(9961, 3668, '(A)는 경고 없이 부모의 `tag` 객체까지 바뀌고, (B)는 읽기 전용 경고가 뜬다.', '객체 props는 참조로 전달돼 내부 속성 변경이 부모 데이터에 그대로 미친다. 반면 props 자체는 읽기 전용이라 최상위 키 재할당은 경고로 걸린다.', true),
(9962, 3668, '(A)·(B) 모두 경고 없이 통과하고 부모의 상태도 함께 바뀐다.', 'props를 평범한 객체로 보고 재할당까지 자유롭다고 본 오해. (B)처럼 props의 키에 직접 대입하면 개발 모드 경고가 뜬다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1178, 3669, 'props 드릴링,프롭 드릴링,프롭스 드릴링,프로퍼티 드릴링,prop drilling,props drilling,드릴링', '중간 컴포넌트가 화면에 쓰지도 않는 값을 오직 아래로 넘기려고 선언해 받는 상태가 props 드릴링이다. 코드에서 `Sidebar`와 `MenuGroup`이 정확히 그 자리이고, 실제로 값을 쓰는 곳은 `MenuItem` 하나뿐이다. 전달 경로가 길수록 필드 하나를 늘리는 데 여러 파일이 함께 바뀌어 유지보수 비용이 커진다. 조상이 값을 제공하면 후손이 깊이에 상관없이 꺼내 쓰는 provide/inject로 중간 단계를 건너뛰거나, 앱 전역에서 쓰는 값이면 스토어로 옮겨 해소한다. 부모가 자식에게 한 단계 값을 내려 주는 정상적인 props 전달, 자식이 props를 직접 고쳐 생기는 단방향 흐름 위반과는 구분한다.'),
       (1179, 3670, 'Pinia,피니아,피니아 스토어,Pinia 스토어,Pinia store', '트리상 서로 무관한 컴포넌트가 같은 상태를 봐야 할 때 공통 부모까지 상태를 끌어올리면 중간 컴포넌트가 불필요한 중계를 떠안는다. 이때 쓰는 전역 스토어로 Vue 3가 공식 권장하는 것이 Pinia다. `defineStore`로 스토어를 선언하고, Vuex에 있던 mutation 계층을 없애 TypeScript와도 잘 맞는다는 점이 Vuex와의 차이다. 조상-후손 서브트리 안에서 읽기 전용 컨텍스트를 나르는 provide/inject, 형제 간 단순 공유에 쓰는 상태 끌어올리기와는 적정 범위가 다르다. 다만 두 컴포넌트만 쓰는 상태까지 전역으로 올릴 필요는 없다.');

-- =====================================================
-- Lesson 739: 폴스루 속성과 defineModel
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4613, 739, '아래 부모·자식 컴포넌트에서 아이콘 버튼을 한 번 클릭했을 때, 부모의 `onClick`과 `onSelect`가 실행되는 횟수의 합은?', 'Vue 3 + `<script setup>` 환경이고, `inheritAttrs`는 기본값 그대로다.

```vue
<!-- 자식: IconButton.vue -->
<script setup>
const emit = defineEmits([''select''])   // click은 선언하지 않았다

function handle() {
  emit(''click'')
  emit(''select'')
}
</script>

<template>
  <button @click="handle">아이콘</button>
</template>
```

```vue
<!-- 부모: Toolbar.vue -->
<script setup>
import IconButton from ''./IconButton.vue''
function onClick() { /* 로그 한 줄 */ }
function onSelect() { /* 로그 한 줄 */ }
</script>

<template>
  <IconButton @click="onClick" @select="onSelect" />
</template>
```', 'OBJECTIVE'),
       (4614, 739, '아래 컴포넌트에서 버튼을 두 번 클릭한 뒤 버튼과 문단에 각각 표시되는 값은?', 'Vue 3.4 이상 + `<script setup>` 환경이다.

```vue
<!-- 자식: QtyStepper.vue -->
<script setup>
const qty = defineModel({ default: 1 })
function addThree() { qty.value += 3 }
</script>

<template>
  <button @click="addThree">{{ qty }}</button>
</template>
```

```vue
<!-- 부모: CartLine.vue -->
<script setup>
import { ref } from ''vue''
import QtyStepper from ''./QtyStepper.vue''
const cart = ref(5)
</script>

<template>
  <QtyStepper v-model="cart" />
  <p>{{ cart }}</p>
</template>
```', 'OBJECTIVE'),
       (4615, 739, '아래 상태 공유 방식에 대한 설명으로 옳은 것은?', '한 모듈 파일의 최상위에서 `const count = ref(0)`을 만들고, 이 `count`와 값을 1 늘리는 함수를 함께 돌려주는 `useCartCount()`를 export했다.

헤더에 있는 `CartBadge`와 상품 카드 안에 있는 `AddToCartButton`은 부모-자식 관계가 아니지만, 각자 이 모듈을 import해 `useCartCount()`를 호출한다.', 'OBJECTIVE'),
       (4616, 739, '아래 표는 상황별로 팀이 고른 통신 방법이다. 표의 선택에 대한 설명으로 옳지 않은 것은?', '| 상황 | 팀이 고른 방법 |
| --- | --- |
| `<Tabs>`가 자기 안에 중첩된 여러 `<Tab>`에 현재 선택값을 알린다 | `provide` / `inject` |
| 로그인 사용자 정보를 앱 어느 화면에서나 읽고 갱신한다 | Pinia |
| 검색창 래퍼 컴포넌트가 입력값을 부모와 주고받는다 | `v-model` |
| 한 화면에 나란히 놓인 형제 둘이 같은 필터 값을 본다 | 이벤트 버스(mitt) |', 'OBJECTIVE'),
       (4617, 739, '아래 상황에서 팀이 지키기로 한, 데이터와 이벤트가 오가는 방향에 관한 Vue의 원칙을 부르는 말은?', '주문서 화면에서 같은 수량이 두 곳에 다르게 표시되는 버그가 반복됐다.

- 자식 `OrderLine`이 내려받은 `order` 객체의 `qty`를 직접 고쳐 둔 자리가 세 곳 있었고, 그때마다 부모가 들고 있는 값과 화면에 보이는 값이 어긋났다.
- 값이 언제 어디서 바뀌었는지 되짚어 보려 해도 값을 바꾸는 코드가 부모와 자식 양쪽에 흩어져 있어 출처를 한 곳으로 좁힐 수 없었다.
- 세 자리를 모두 걷어내고 나서야 버그가 사라졌고, 팀은 이 사건을 계기로 정한 원칙을 코드 리뷰 체크리스트 맨 위에 올렸다.', 'SUBJECTIVE'),
       (4618, 739, '아래 상황에서 조상 컴포넌트가 값을 한 겹 감쌀 때 쓴 Vue 함수의 이름은?', '테마 값을 다루다가 겪은 일이다.

- 조상 `AppShell`이 `provide(ThemeKey, theme)`로 `ref`를 그대로 넘겼더니 후손 어느 파일에서든 `theme.value = ''dark''`가 통했고, 색이 제멋대로 바뀌었을 때 어디서 바꾼 것인지 찾는 데 반나절이 걸렸다.
- 넘길 값을 어떤 함수로 한 겹 감싸서 제공하도록 바꾸자, 후손에서 같은 대입을 하면 개발 모드 경고가 뜨고 값이 바뀌지 않았다. 반면 조상이 자기 `theme`을 바꾸면 후손 화면은 그대로 따라 갱신됐다.
- 팀은 값을 바꿀 일이 있으면 조상이 함께 제공한 `setTheme`을 부르도록 정리했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4613
(12475, 4613, '1회 (onClick 0회 + onSelect 1회)', 'defineEmits에 없는 이벤트는 부모까지 가지 못한다고 본 오해. emit은 선언 여부와 상관없이 컴포넌트에 들어온 onClick 핸들러를 그대로 호출한다. 선언은 그 이벤트를 폴스루 대상에서 뺄지를 정할 뿐이다.', false),
(12476, 4613, '2회 (onClick 1회 + onSelect 1회)', 'emit 한 번에 핸들러 한 번이라고만 센 오해. click은 선언되지 않아 부모의 리스너가 $attrs로 흘러 루트 <button>에 네이티브 클릭 리스너로도 붙으므로, 클릭 자체만으로 onClick이 한 번 더 실행된다.', false),
(12477, 4613, '3회 (onClick 2회 + onSelect 1회)', '클릭 한 번에, 루트 <button>으로 흘러 붙은 폴스루 리스너로 onClick이 한 번, 자식의 handle이 부른 emit(''click'')으로 또 한 번 실행돼 onClick만 2회다. select는 선언돼 폴스루에서 빠지므로 1회, 합 3회.', true),
(12478, 4613, '4회 (onClick 2회 + onSelect 2회)', '선언한 이벤트도 $attrs를 거쳐 루트 요소에 한 번 더 붙는다고 본 오해. defineEmits에 적은 select는 폴스루 대상에서 빠지고, 버튼을 눌러도 네이티브 select 이벤트가 발생하지는 않는다.', false),

-- 문제 4614
(12479, 4614, '버튼 11 / 문단 11', 'defineModel이 돌려준 ref에 값을 대입하면 내부적으로 update:modelValue가 emit되고, v-model로 이어진 부모가 자기 cart를 갱신한다. 5에서 3씩 두 번 늘어 두 자리 모두 11이 된다.', true),
(12480, 4614, '버튼 11 / 문단 5', 'defineModel의 ref를 자식만 쓰는 로컬 상태로 본 오해. 부모가 v-model로 이어 준 경우 대입은 변경 요청이 되어 위로 올라가고, 부모가 바꾼 값이 다시 자식으로 내려온다.', false),
(12481, 4614, '버튼 5 / 문단 5', 'props는 읽기 전용이니 대입이 경고만 내고 무시된다고 본 오해. defineModel은 prop을 직접 고치는 대신 약속된 이벤트를 올려 부모가 고치게 하는 방식이라 값이 정상 반영된다.', false),
(12482, 4614, '버튼 7 / 문단 5', 'default로 준 1에서 3씩 두 번 더해 7로 본 오해. default는 부모가 값을 주지 않았을 때만 쓰이고, 여기서는 v-model이 내려 준 5가 시작값이다.', false),

-- 문제 4615
(12483, 4615, '두 컴포넌트가 화면에서 모두 사라졌다가 다시 마운트되면 count는 0으로 되돌아간다.', '모듈 최상위 변수는 컴포넌트 수명이 아니라 모듈 수명을 따른다. 앱이 실행되는 동안 한 번만 만들어져 값이 남으므로, 초기화를 기대하면 이전 화면의 값이 그대로 보이는 버그로 이어진다.', false),
(12484, 4615, '두 컴포넌트가 같은 값을 보려면 공통 조상이 같은 키로 provide를 해 두어야 한다.', 'import한 순간 같은 모듈의 같은 ref를 가리키므로 트리 상의 조상이 끼어들 필요가 없다. 주입 키가 있어야 값이 이어진다고 본 오해로, provide/inject 방식과 섞어 본 것이다.', false),
(12485, 4615, 'ref를 컴포넌트 밖 모듈 스코프에 두면 반응성이 끊겨 값이 바뀌어도 화면은 다시 그려지지 않는다.', '반응성은 ref가 만드는 것이라 선언 위치와 무관하다. 템플릿에서 읽은 컴포넌트가 의존성으로 등록되므로 어느 쪽에서 값을 바꾸든 두 화면이 함께 갱신된다.', false),
(12486, 4615, 'ref(0)을 useCartCount() 안으로 옮기면 호출한 컴포넌트마다 값이 따로 생겨 공유가 끊긴다.', '공유를 만드는 것은 컴포저블이라는 형식이 아니라 ref가 모듈 스코프에서 한 번만 만들어졌다는 점이다. 함수 안에 두면 호출할 때마다 새 ref가 생겨 각자의 상태가 된다.', true),

-- 문제 4616
(12487, 4616, '`<Tabs>`가 중첩된 `<Tab>`에 선택값을 알리는 자리는 둘이 함께 쓰이도록 묶여 있어, 의존성이 숨는 부담보다 중계를 없애는 이득이 크다.', '복합 컴포넌트 내부는 provide/inject의 적정 범위다. `<Tab>`을 `<Tabs>` 밖에서 따로 쓸 일이 없으니 값의 출처가 태그에 드러나지 않는 단점이 문제되지 않는다.', false),
(12488, 4616, '형제 둘이 같은 필터 값을 보는 자리는 Vue 3가 공식 권장하는 이벤트 버스로 이으면 되고, 공통 부모를 거칠 필요가 없다.', 'Vue 3는 인스턴스의 $on·$off를 없애 이벤트 버스를 쓰려면 mitt 같은 외부 라이브러리를 따로 붙여야 하고, 권장이 아니라 최소화 대상이다. 형제 간 단순 공유는 상태를 공통 부모로 올리는 쪽이 맞다.', true),
(12489, 4616, '로그인 사용자 정보처럼 대부분의 화면이 함께 보는 값은 전역 스토어에 두어도 전역 상태가 지나치게 늘어나는 문제로 보기 어렵다.', '앱 전역에서 쓰는 상태는 Pinia의 대표 용도다. 경계할 것은 두세 컴포넌트만 쓰는 값까지 전역으로 올리는 습관이지, 실제로 전역에서 쓰이는 값을 전역에 두는 선택이 아니다.', false),
(12490, 4616, '검색창 래퍼가 입력값을 부모와 주고받는 자리는 값 내려 주기와 변경 알림이 짝을 이루므로 한 줄로 줄여도 흐름이 유지된다.', 'v-model은 modelValue prop과 update:modelValue 이벤트를 묶은 문법 설탕이다. 표기만 짧아질 뿐 데이터는 아래로, 변경 요청은 위로 가는 구조는 그대로 남는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1494, 4617, '단방향 데이터 흐름,단방향데이터흐름,단방향 데이터흐름,단방향 흐름,단방향 데이터 바인딩,단방향 바인딩,단방향 데이터 플로우,one-way data flow,one way data flow,oneway data flow,unidirectional data flow', 'Vue 컴포넌트 통신의 대원칙은 데이터가 부모에서 자식으로 내려가고 변경 요청이 자식에서 부모로 올라간다는 단방향 데이터 흐름이다. 자식이 내려받은 값을 직접 고치면 같은 값을 바꾸는 코드가 두 곳이 되어, 값이 어긋났을 때 어느 쪽이 바꾼 것인지 되짚을 수 없다 — 상황의 `OrderLine`이 `order.qty`를 고친 세 자리가 정확히 그 경우다. 객체·배열 props는 참조로 전달돼 내부 속성을 고쳐도 런타임이 경고조차 내지 않으므로 규율로 지켜야 하며, 바꿀 일이 있으면 emit으로 부모에 알려 부모가 자기 상태를 고치게 한다. `v-model`은 이 원칙의 예외가 아니라 prop 내려 주기와 이벤트 올리기를 짧게 쓴 문법 설탕이고, 중간 컴포넌트가 쓰지도 않는 props를 넘겨 주기만 하는 props 드릴링은 흐름의 방향이 아니라 전달 경로의 길이가 문제인 별개 주제다.'),
       (1495, 4618, 'readonly,readonly(),readonly 함수,리드온리,리드온리 함수', '`readonly()`는 넘겨받은 ref나 반응형 객체를 감싸 읽기 전용 프록시를 돌려주는 Vue 함수다. 감싼 값에 대입하면 개발 모드에서 경고가 뜨고 변경은 무시되지만, 원본이 바뀌면 프록시를 통해 읽던 화면은 그대로 갱신된다 — 상황의 두 번째 항목이 바로 이 동작이다. `provide`로 반응형 값을 그대로 내려 주면 트리 안 어느 후손이든 고칠 수 있어 변경 출처를 추적할 수 없으므로, `readonly()`로 감싸 제공하고 변경은 함께 제공한 `setTheme` 같은 함수로만 하도록 모으는 것이 권장 패턴이다. 자바스크립트의 `const`는 변수 재할당만 막을 뿐 객체 내부 속성 변경은 막지 못해 이 문제를 해결하지 못하고, `computed`는 다른 값에서 파생된 읽기 전용 값을 새로 만드는 API라 이미 있는 값을 그대로 보호하려는 목적과 다르다. 첫 단계만 보호하는 `shallowReadonly`와도 구분한다.');

-- =====================================================
-- Lesson 897: Vue 컴포넌트 통신 — props 반응성과 기본값, provide 탐색 범위, v-model 인자
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5561, 897, '아래 부모·자식 컴포넌트에서 부모의 버튼을 두 번 클릭한 뒤 자식의 `<span>`에 표시되는 문자열은?', 'Vue 3.4 + `<script setup>` 환경이다.

```vue
<!-- 자식: PriceTag.vue -->
<script setup>
import { computed } from ''vue''
const props = defineProps({ price: Number })
const { price: initial } = props
const a = computed(() => initial * 2)
const b = computed(() => props.price * 2)
</script>

<template>
  <span>{{ initial }} / {{ a }} / {{ b }}</span>
</template>
```

```vue
<!-- 부모: Shop.vue -->
<script setup>
import { ref } from ''vue''
import PriceTag from ''./PriceTag.vue''
const p = ref(100)
</script>

<template>
  <PriceTag :price="p" />
  <button @click="p += 100">인상</button>
</template>
```', 'OBJECTIVE'),
       (5562, 897, '아래 컴포넌트 트리에서 `Logo`와 `NavItem`에 각각 표시되는 값은?', 'Vue 3 + `<script setup>` 환경이며, 컴포넌트 import 문은 생략했다. 트리 구조는 아래와 같다.

```
App
 ├─ TopBar
 │   └─ Logo
 └─ SideNav
     └─ NavItem
```

```vue
<!-- App.vue -->
<script setup>
import { provide } from ''vue''
provide(''theme'', ''light'')
</script>
<template>
  <TopBar />
  <SideNav />
</template>

<!-- TopBar.vue : provide 없음 -->
<template><Logo /></template>

<!-- SideNav.vue -->
<script setup>
import { provide } from ''vue''
provide(''theme'', ''dark'')
</script>
<template><NavItem /></template>
```

```vue
<!-- Logo.vue와 NavItem.vue : 두 파일의 코드가 같다 -->
<script setup>
import { inject } from ''vue''
const theme = inject(''theme'', ''none'')
</script>
<template><span>{{ theme }}</span></template>
```', 'OBJECTIVE'),
       (5563, 897, '아래 코드에서 입력창에 글자를 입력해도 문단의 `bookTitle`은 계속 `초안`으로 남는다. 원인으로 옳은 것은?', 'Vue 3 + `<script setup>` 환경이다.

```vue
<!-- 부모: BookPage.vue -->
<script setup>
import { ref } from ''vue''
import TitleEditor from ''./TitleEditor.vue''
const bookTitle = ref(''초안'')
</script>

<template>
  <TitleEditor v-model:title="bookTitle" />
  <p>{{ bookTitle }}</p>
</template>
```

```vue
<!-- 자식: TitleEditor.vue -->
<script setup>
defineProps({ title: String })
const emit = defineEmits([''update:modelValue''])
</script>

<template>
  <input
    :value="title"
    @input="emit(''update:modelValue'', $event.target.value)"
  />
</template>
```', 'OBJECTIVE'),
       (5564, 897, '아래 조상-후손 간 값 제공 방식에 대한 설명으로 옳은 것은?', '조상 컴포넌트 `CartProvider`는 장바구니 목록 `items`(반응형 배열)를 `readonly()`로 감싼 값과, 목록에 상품을 넣는 함수 `addItem(item)`을 함께 `provide`한다.

몇 단계 아래의 후손 컴포넌트들은 목록을 `inject`로 꺼내 화면에 그리고, 상품을 담을 때는 역시 `inject`로 받은 `addItem`을 호출한다.', 'OBJECTIVE'),
       (5565, 897, '아래 변경 전후 코드에서 `filter` 상태를 두는 자리를 옮겨 버그를 해결한 방식을 부르는 말은?', '상품 목록 화면에서 필터 버튼 묶음 `FilterBar`와 상품 목록 `ProductList`가 서로 다른 필터를 보여 주는 버그가 있어 코드를 아래처럼 고쳤다. 두 컴포넌트는 `ProductPage` 안에 나란히 놓여 있다.

**변경 전**

```vue
<!-- FilterBar.vue -->
<script setup>
import { ref } from ''vue''
const filter = ref(''all'')   // 버튼을 누르면 이 값을 바꾼다
</script>

<!-- ProductList.vue -->
<script setup>
import { ref } from ''vue''
const filter = ref(''all'')   // 이 값으로 목록을 거른다
</script>
```

**변경 후**

```vue
<!-- ProductPage.vue -->
<script setup>
import { ref } from ''vue''
const filter = ref(''all'')
</script>

<template>
  <FilterBar :filter="filter" @change="filter = $event" />
  <ProductList :filter="filter" />
</template>

<!-- FilterBar.vue -->
<script setup>
defineProps({ filter: String })
const emit = defineEmits([''change''])   // 버튼을 누르면 emit(''change'', 값)
</script>

<!-- ProductList.vue -->
<script setup>
defineProps({ filter: String })
</script>
```

고친 뒤로는 두 컴포넌트의 필터가 어긋나는 일이 사라졌다.', 'SUBJECTIVE'),
       (5566, 897, '아래 상황에서 빈칸 ㉠에 들어갈 Vue API의 이름은?', 'TypeScript로 만든 배지 컴포넌트 `Badge.vue`에서 겪은 일이다.

- props를 `interface Props { label: string; size?: ''sm'' | ''lg'' }`로 적고 `const props = defineProps<Props>()`로 선언했다. 클래스 이름은 `''badge--'' + props.size`로 만든다.
- 부모가 `<Badge label="신규" />`처럼 `size`를 빼고 쓰자 클래스 이름이 `badge--undefined`로 붙어 스타일이 깨졌다.
- 선언을 `const props = ㉠(defineProps<Props>(), { size: ''sm'' })`로 바꾸자 같은 태그에서 `badge--sm`이 붙었고, 타입 검사에서도 `props.size`가 더는 `undefined`일 수 있다고 표시되지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5561
(15003, 5561, '300 / 600 / 600', '구조 분해한 `initial`도 props를 계속 따라간다고 본 오해. `const { price: initial } = props`는 그 순간의 값 100을 꺼내 평범한 숫자로 담을 뿐이라, 부모가 값을 바꿔도 `initial`은 그대로다.', false),
(15004, 5561, '100 / 600 / 600', '`computed`로 감싸면 무엇을 읽든 다시 계산된다고 본 오해. `computed`는 계산 중에 읽은 반응형 값만 의존성으로 잡는데 `initial`은 평범한 숫자라, `a`는 처음 계산한 200에 머문다.', false),
(15005, 5561, '100 / 200 / 600', '`initial`은 구조 분해 순간의 숫자 100으로 고정되고, 이를 쓰는 `a`도 200에 머문다. `b`는 반응형인 props 객체를 거쳐 `props.price`로 읽으므로 두 번 인상된 300을 따라가 600이 된다.', true),
(15006, 5561, '100 / 200 / 200', 'props가 처음 받은 값의 사본이라 부모의 변경이 자식에 닿지 않는다고 본 오해. `defineProps`가 돌려준 props 객체는 반응형이라 `props.price`로 읽으면 부모의 최신 값을 따라간다.', false),

-- 문제 5562
(15007, 5562, 'Logo: light / NavItem: dark', '`inject`는 가까운 조상부터 거슬러 올라가 처음 만난 값을 쓴다. `NavItem`은 바로 위 `SideNav`의 dark를 먼저 만나고, `Logo`는 `TopBar`에 값이 없어 `App`의 light까지 올라간다.', true),
(15008, 5562, 'Logo: light / NavItem: light', '가장 바깥 조상이 제공한 값이 우선한다고 본 오해. 같은 키를 중간 조상이 다시 제공하면, 그 아래 후손에게는 더 가까운 쪽 값이 바깥 값을 가린다.', false),
(15009, 5562, 'Logo: dark / NavItem: dark', '나중에 실행된 `provide`가 전역 변수처럼 값을 덮어쓴다고 본 오해. `SideNav`의 제공은 자기 하위 트리에서만 보여, 형제인 `TopBar` 아래의 `Logo`에는 닿지 않는다.', false),
(15010, 5562, 'Logo: none / NavItem: dark', '바로 위 부모가 제공한 값만 꺼낼 수 있다고 본 오해. `inject`는 깊이에 관계없이 조상을 거슬러 찾으므로, `TopBar`에 값이 없어도 `App`의 light를 받는다.', false),

-- 문제 5563
(15011, 5563, '`v-model`에 인자를 붙이는 `v-model:title` 표기는 Vue 3에서 제거돼 바인딩 전체가 무시됐다.', '인자를 붙인 `v-model:title`은 Vue 2의 `.sync` 수식어를 대신해 Vue 3에 들어온 표기다. 제거된 쪽은 `.sync`이고, 여기서도 `title` prop은 정상으로 내려가 입력창에 초안이 표시된다.', false),
(15012, 5563, '`:value`로 값을 묶은 입력창은 읽기 전용이 돼 글자를 쳐도 `input` 이벤트가 발생하지 않는다.', '`:value`는 입력창에 값을 표시할 뿐 입력을 막지 않는다. 글자를 칠 때마다 `input` 이벤트가 발생해 `emit`까지는 실행되며, 문제는 그 이벤트를 받는 쪽에 있다.', false),
(15013, 5563, '자식이 입력값을 `props.title`에 직접 대입하지 않아, 부모에게 변경이 전달되지 않았다.', 'props는 읽기 전용이라 `props.title`에 대입하면 개발 모드 경고가 뜰 뿐 부모의 `bookTitle`은 바뀌지 않는다. 변경은 이벤트로 부모에게 요청해야 하며, 여기서는 그 이벤트 이름이 어긋났다.', false),
(15014, 5563, '자식은 `update:modelValue`를 올리는데, 부모의 `v-model:title`은 `update:title`을 듣고 있다.', '`v-model:title`은 `:title` prop과 `@update:title` 리스너로 풀린다. 자식이 다른 이름인 `update:modelValue`를 올리면 받는 리스너가 없어 `bookTitle`이 그대로다. 이벤트 이름을 `update:title`로 맞춰야 한다.', true),

-- 문제 5564
(15015, 5564, '후손은 `readonly()`로 감싼 시점의 목록 사본을 받으므로, `addItem`으로 상품이 늘어도 화면이 다시 그려지지 않는다.', '`readonly()`는 사본을 만들지 않고 원본을 가리키는 읽기 전용 프록시를 돌려준다. 조상이 `addItem`으로 원본을 바꾸면 이를 읽던 후손 화면도 그대로 따라 갱신된다.', false),
(15016, 5564, '목록을 바꾸는 코드가 조상 한 곳에 모여, 값이 예상과 다르게 바뀌었을 때 들여다볼 곳이 하나로 좁혀진다.', '후손은 읽기만 하고, 실제로 목록을 고치는 코드는 조상이 정의한 `addItem` 하나다. 반응형 배열을 그대로 제공해 어느 후손이든 고칠 수 있게 두면 변경 출처가 흩어져 추적이 어려워진다.', true),
(15017, 5564, '후손이 `addItem`을 부르는 것은 조상의 상태를 직접 고치는 일이라, 단방향 데이터 흐름을 어기는 설계다.', '후손은 변경을 요청할 뿐이고, 목록을 고치는 코드는 조상 쪽 함수에 있다. 자식이 emit으로 알리고 부모가 자기 상태를 고치는 것과 같은 구조라 단방향 흐름이 유지된다.', false),
(15018, 5564, '후손이 꺼낸 목록에 `push`를 하면 경고 없이 조상의 `items`까지 바뀌므로, 팀 규율로 막아야 한다.', '경고 없이 바뀌는 것은 반응형 객체를 감싸지 않고 넘긴 경우다. `readonly()`는 안쪽 요소까지 읽기 전용으로 막아, `push`를 하면 개발 모드 경고가 뜨고 목록은 바뀌지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1810, 5565, '상태 끌어올리기,상태끌어올리기,상태 끌어 올리기,상태 올리기,상태 리프팅,끌어올리기,lifting state up,lift state up,lifting state,state lifting,state lifting up', '형제 컴포넌트가 저마다 `ref`를 들고 있으면 같은 필터 값의 출처가 둘이라 서로 어긋난다. 상태를 두 컴포넌트의 가장 가까운 공통 부모(`ProductPage`)로 올려 한 곳에만 두고, props로 내려 주고 emit으로 변경을 요청받게 바꾸는 것이 상태 끌어올리기다. 형제 사이의 단순 공유에 알맞은 방법이다. 트리상 멀리 떨어진 컴포넌트나 앱 전역에서 쓰는 상태라면 Pinia 같은 전역 스토어가, 조상이 깊은 후손에게 읽기 전용 컨텍스트를 나르는 경우라면 provide/inject가 알맞아 적정 범위가 다르다. 끌어올린 자리가 너무 높아 중간 컴포넌트가 쓰지도 않는 props를 중계하게 되면 props 드릴링으로 번지므로, 두 컴포넌트에 가장 가까운 공통 부모까지만 올린다.'),
       (1811, 5566, 'withDefaults,withDefaults(),with defaults,위드디폴츠,위드 디폴츠,위드디폴트,위드 디폴트', '`withDefaults`는 타입 기반으로 선언한 `defineProps`에 기본값을 붙이는 컴파일러 매크로라 import 없이 쓴다. 타입만으로 선언하면 기본값을 적을 자리가 없어, 부모가 선택 prop을 빼고 쓰면 값이 `undefined`로 남는다 — 상황의 `badge--undefined`가 그 결과다. `withDefaults`로 감싸면 부모가 값을 주지 않을 때 기본값이 채워지고, 기본값을 준 prop은 반환 타입에서도 `undefined`가 빠진다. 런타임 선언인 `defineProps({ size: { type: String, default: ''sm'' } })`에서는 옵션 안의 `default`가 같은 일을 하므로 `withDefaults`가 필요 없다. 또 부모 값을 시작값으로만 받아 자식 안에서 따로 바꾸려는 경우는 기본값 문제가 아니라 `ref(props.size)`처럼 로컬 상태로 복사해 해결하는 별개의 상황이다.');
