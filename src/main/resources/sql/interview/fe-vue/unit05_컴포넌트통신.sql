-- Unit: 컴포넌트 통신 (Unit ID: 155)
-- Chapter: Vue.js (Chapter ID: 14)
-- Topic: VUE
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-vue-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(771, 'VUE', 155, 'HARD', true,
 '깊이 중첩된 컴포넌트 트리에서 테마 값을 여러 후손이 사용하고 일부 후손은 이 값을 바꿔야 한다면, 어떤 통신 방법을 선택하고 그 대가와 안전하게 쓰는 방법은 무엇인가요?',
 '테마처럼 트리 전체가 공유하는 컨텍스트라면 provide/inject를 선택합니다. 깊은 트리에서 중간 컴포넌트가 쓰지도 않는 props를 단지 아래로 넘기기 위해 받는 것을 props 드릴링이라 하는데, provide/inject는 조상이 값을 제공하면 깊이에 관계없이 후손이 꺼내 쓸 수 있게 해 이 문제를 해결합니다. 타입 안전성을 위해 InjectionKey와 Symbol로 주입 키를 정의해 쓸 수 있습니다. 대가는 provide가 암묵적 의존성을 만든다는 점입니다. 어떤 값을 어디서 받는지 드러나지 않아 컴포넌트를 단독으로 재사용하거나 테스트하기 어려워지므로, 일반적인 부모-자식 데이터 전달에는 쓰지 않고 props/emit을 씁니다. 또 반응형 객체를 그대로 넘기면 어느 후손이든 수정할 수 있어 데이터 흐름을 추적하기 어렵습니다. 그래서 provide(ThemeKey, readonly(theme))처럼 readonly()로 감싸 제공해 후손의 직접 수정을 막고, 값을 바꿔야 하는 후손을 위해서는 값 대신 변경 함수를 함께 제공해 변경은 그 함수를 통해서만 하도록 해 변경 경로를 조상에 모읍니다.'),
(772, 'VUE', 155, 'NORMAL', true,
 '컴포넌트에 사용하는 v-model은 내부적으로 어떻게 동작하며, Vue 2와 Vue 3 사이에 무엇이 달라졌나요?',
 '컴포넌트의 v-model은 props로 값을 내려 주고 emit으로 받아 갱신하는 패턴의 문법 설탕입니다. Vue 3에서 <SearchInput v-model="keyword" />는 :modelValue="keyword" @update:modelValue="keyword = $event"로 풀리므로, 기본 prop 이름은 modelValue이고 기본 이벤트 이름은 update:modelValue입니다. Vue 2에서는 기본 prop이 value, 기본 이벤트가 input이었습니다. 또 Vue 2에서 여러 값을 양방향으로 바인딩할 때 쓰던 .sync 수식어(:title.sync)는 Vue 3에서 제거되고 v-model:title처럼 인자를 붙이는 방식으로 통합됐습니다. 추가로 Vue 3.4 이상에서는 defineModel()로 props와 emit을 한 번에 선언할 수 있습니다. defineModel이 반환한 ref에 값을 대입해도 자식이 부모 상태를 직접 바꾸는 것이 아니라 내부적으로 update:modelValue를 emit하고 부모가 이를 받아 자기 상태를 갱신하므로, 단방향 흐름은 그대로 유지됩니다.'),
(773, 'VUE', 155, 'NORMAL', true,
 '형제 컴포넌트나 트리상 멀리 떨어진 컴포넌트가 상태를 공유해야 할 때, 상태 끌어올리기와 Pinia는 각각 언제 사용하나요?',
 '상태 끌어올리기는 공유가 필요한 상태를 공통 부모로 올리고, 부모가 props로 내려 주고 emit으로 변경을 받아 형제들을 연결하는 방식입니다. 공통 부모가 있는 형제 간 단순 공유에 적합합니다. 반면 트리상 무관하거나 앱 전역에서 쓰는 상태, 예를 들어 로그인 정보나 장바구니 같은 상태는 Pinia 같은 전역 스토어로 모듈 단위로 관리합니다. Vuex도 Vue 3에서 동작하지만 공식 권장 스토어는 Pinia입니다. 다만 전역 스토어는 편리한 만큼 모든 상태를 전역으로 올리는 유혹이 있는데, 두 컴포넌트만 쓰는 상태라면 끌어올리기나 provide로 충분하므로 전역으로 올리지 않아야 합니다. 스토어가 과한 소규모 전역 상태라면 모듈 스코프 ref를 컴포저블로 내보내는 공유 컴포저블을 쓸 수 있습니다.'),
(774, 'VUE', 155, 'EASY', true,
 'Vue 컴포넌트 통신의 단방향 데이터 흐름 원칙이란 무엇이며, 자식이 props를 직접 수정하면 안 되는 이유는 무엇인가요?',
 'Vue 컴포넌트 통신의 대원칙은 ''데이터는 아래로, 이벤트는 위로''입니다. 부모가 자식에게 props로 데이터를 내려 주고, 자식은 props를 읽기만 하며 emit으로 ''이런 일이 있었다''고 알릴 뿐 부모의 데이터를 직접 바꾸지 않습니다. 즉 변경은 emit으로 부모에게 요청하고 실제 갱신은 부모가 합니다. 자식이 props를 직접 수정하면 데이터의 출처가 두 곳이 되어 어디서 바뀌었는지 추적할 수 없게 되기 때문에 금지되며, Vue는 props 수정 시 개발 모드에서 경고를 출력합니다. 특히 객체·배열 props는 참조로 전달되므로 자식이 내부를 바꾸면 경고 없이 부모 데이터가 변하는데, 런타임이 막아 주지 않으므로 규율로 지켜야 합니다. props 값을 자식에서 바꿔 쓰고 싶다면 초기값으로만 사용하고 ref로 로컬 상태에 복사해 쓰는 것이 개선 방법입니다.'),
(775, 'VUE', 155, 'EASY', true,
 '<script setup>에서 자식 컴포넌트가 부모에게 이벤트를 알리는 emit은 어떻게 선언하고 사용하나요?',
 '<script setup>에서는 defineEmits로 emit을 선언합니다. TypeScript를 쓰면 defineEmits<{ select: [id: number] }>()처럼 이벤트 이름과 페이로드 타입을 함께 선언할 수 있고, 이렇게 선언해야 타입 검사와 자동 완성을 받을 수 있습니다. defineProps·defineEmits는 컴파일러 매크로라 import 없이 사용합니다. 사용할 때는 자식이 emit(''select'', 42)처럼 이벤트 이름과 페이로드를 넘겨 이벤트를 발생시키고, 부모는 <UserCard @select="onSelect" />처럼 @이벤트명으로 리스너를 연결해 받습니다. 선언하지 않은 이벤트는 $attrs로 흘러가 루트 요소에 바인딩되므로 의도치 않은 동작의 원인이 됩니다. 개념 자체는 Vue 2의 this.$emit과 같지만, Vue 3는 emits 옵션이나 defineEmits로 이벤트 선언을 요구하는 방향으로 바뀌었습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 771
(4155, 771, '중간 컴포넌트가 쓰지 않는 props를 넘기는 props 드릴링을 provide/inject가 해결함을 설명', 'ESSENTIAL', 1),
(4156, 771, 'provide/inject가 암묵적 의존성을 만들어 컴포넌트의 단독 재사용·테스트가 어려워짐을 언급', 'ESSENTIAL', 2),
(4157, 771, 'provide하는 값을 readonly()로 감싸 후손의 직접 수정을 막는 방법을 제시', 'ESSENTIAL', 3),
(4158, 771, '후손이 값을 바꿔야 하면 변경 함수를 함께 provide해 변경 경로를 조상에 모으는 방법을 제시', 'ESSENTIAL', 4),
(4159, 771, 'InjectionKey와 Symbol로 타입 안전한 주입 키를 정의함을 언급', 'SUPPLEMENTARY', 5),
(4160, 771, '일반적인 부모-자식 데이터 전달에는 provide/inject가 부적합함을 명시', 'SUPPLEMENTARY', 6),

-- 질문 772
(4161, 772, 'v-model이 props로 내려 주고 emit으로 받아 갱신하는 패턴의 문법 설탕임을 설명', 'ESSENTIAL', 1),
(4162, 772, 'Vue 3의 기본 prop이 modelValue, 기본 이벤트가 update:modelValue임을 명시', 'ESSENTIAL', 2),
(4163, 772, 'Vue 2의 기본 prop과 이벤트가 각각 value와 input이었음을 언급', 'ESSENTIAL', 3),
(4164, 772, 'Vue 2의 .sync 수식어가 Vue 3에서 v-model:title 같은 인자 방식으로 대체됐음을 언급', 'ESSENTIAL', 4),
(4165, 772, 'defineModel()이 3.4 이상에서 props와 emit 선언을 한 번에 해 줌을 언급', 'SUPPLEMENTARY', 5),
(4166, 772, 'defineModel이 반환한 ref에 대입해도 update:modelValue를 emit하므로 단방향 흐름이 유지됨을 설명', 'SUPPLEMENTARY', 6),

-- 질문 773
(4167, 773, '상태 끌어올리기가 공통 부모로 상태를 올려 props/emit으로 연결하는 방식임을 설명', 'ESSENTIAL', 1),
(4168, 773, '상태 끌어올리기의 적정 범위가 형제 간 단순 공유임을 언급', 'ESSENTIAL', 2),
(4169, 773, 'Pinia가 로그인 정보·장바구니 같은 앱 전역 상태에 적합함을 언급', 'ESSENTIAL', 3),
(4170, 773, '두 컴포넌트만 쓰는 상태까지 전역 스토어로 올리지 않아야 함을 언급', 'SUPPLEMENTARY', 4),
(4171, 773, 'Vuex 대신 Pinia가 Vue 3의 공식 권장 스토어임을 언급', 'SUPPLEMENTARY', 5),
(4172, 773, '스토어가 과할 때 모듈 스코프 ref를 내보내는 공유 컴포저블을 대안으로 제시', 'SUPPLEMENTARY', 6),

-- 질문 774
(4173, 774, '부모는 props로 데이터를 내려 주고 자식은 emit으로 이벤트를 올린다는 흐름 방향을 설명', 'ESSENTIAL', 1),
(4174, 774, '자식은 부모의 데이터를 직접 바꾸지 않고 emit으로 변경을 요청함을 언급', 'ESSENTIAL', 2),
(4175, 774, '자식이 props를 직접 수정하면 데이터 출처가 두 곳이 되어 변경 추적이 어려워짐을 설명', 'ESSENTIAL', 3),
(4176, 774, '객체·배열 props는 참조로 전달되어 내부 수정 시 경고 없이 부모 데이터가 변함을 언급', 'SUPPLEMENTARY', 4),
(4177, 774, 'props를 초기값으로만 쓰고 로컬 ref 상태로 복사하는 개선 방법을 제시', 'SUPPLEMENTARY', 5),
(4178, 774, 'props를 수정하면 Vue가 개발 모드에서 경고를 출력함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 775
(4179, 775, 'defineEmits로 이벤트 이름과 페이로드 타입을 선언함을 설명', 'ESSENTIAL', 1),
(4180, 775, '자식이 emit(이벤트명, 페이로드)로 발생시킨 이벤트를 부모가 @이벤트명 리스너로 받음을 설명', 'ESSENTIAL', 2),
(4181, 775, '선언하지 않은 이벤트는 $attrs로 흘러가 루트 요소에 바인딩됨을 언급', 'SUPPLEMENTARY', 3),
(4182, 775, 'defineProps·defineEmits가 import 없이 쓰는 컴파일러 매크로임을 언급', 'SUPPLEMENTARY', 4),
(4183, 775, 'Vue 2의 this.$emit과 달리 Vue 3는 emits 옵션이나 defineEmits로 이벤트 선언을 요구함을 언급', 'SUPPLEMENTARY', 5);
