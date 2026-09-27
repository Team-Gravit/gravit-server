-- Unit: 생명주기와 DOM 접근 시점 (Unit ID: 157)
-- Chapter: Vue.js (Chapter ID: 14)
-- Topic: VUE
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-vue-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(781, 'VUE', 157, 'HARD', true,
 'v-if로 숨겨져 있던 입력창을 버튼 클릭 시 표시하고 곧바로 focus()를 호출했는데 포커스가 가지 않습니다. 원인과 해결 방법을 설명하고, 이런 DOM 작업이 특정 상태가 바뀔 때마다 반복돼야 한다면 어떤 대안이 더 나은지 말씀해 주시겠어요?',
 'Vue는 상태가 바뀔 때마다 즉시 DOM을 고치지 않고, 같은 틱에서 일어난 변경을 큐에 모아 두었다가 현재 동기 코드가 끝난 뒤 마이크로태스크에서 한 번에 렌더링합니다. 그래서 editing 같은 상태를 true로 바꿔 v-if 조건을 참으로 만든 바로 다음 줄에서는 입력창 DOM이 아직 생성되지 않았고, 템플릿 ref도 렌더링된 이후에야 채워지므로 값이 null이라 focus() 호출이 아무 일도 하지 않습니다. 해결책은 상태를 바꾼 뒤 await nextTick()으로 다음 DOM 갱신 사이클이 끝나기를 기다린 다음 titleInput.value?.focus()를 호출하는 것입니다. 다만 특정 상태가 바뀔 때마다 DOM을 다뤄야 한다면 이벤트 핸들러마다 nextTick을 쓰기보다 watch에 flush: ''post'' 옵션을 주는 편이 낫습니다. 이렇게 하면 콜백이 DOM 갱신 이후에 실행되므로 nextTick을 매번 쓰지 않아도 되고, 선언적이어서 누락이 적습니다. onUpdated를 쓰는 방법도 있지만 모든 갱신에 반응하고, 그 안에서 상태를 변경하면 다시 갱신이 일어나 무한 루프에 빠질 수 있으므로 원인이 되는 상태를 지정한 flush: ''post'' 감시자가 더 안전합니다. 참고로 이런 배칭 덕분에 count.value++를 100번 해도 렌더는 1번만 일어납니다.'),
(782, 'VUE', 157, 'NORMAL', true,
 'Vue 3에서 setup()(또는 <script setup> 최상위)에서 하는 작업과 onMounted 훅에서 하는 작업은 어떻게 다른가요?',
 'setup()은 Options API의 beforeCreate·created 시점에 해당하며, 반응형 상태는 준비가 끝났지만 DOM은 아직 없는 단계입니다. 그래서 상태와 컴포저블을 초기화하고 데이터 요청을 시작하는 용도로 씁니다. <script setup> 안의 코드도 setup() 시점에 실행되므로 스크립트 최상위에서 document.querySelector나 템플릿 ref를 읽으면 항상 null입니다. 반면 onMounted는 최초 렌더로 실제 DOM이 생성·삽입된 뒤 호출되어 템플릿 ref가 채워져 있으므로, DOM 측정, 외부 라이브러리 초기화, 이벤트 리스너 등록처럼 DOM이 필요한 작업은 반드시 onMounted 안에 둬야 합니다. 부모·자식 관계에서는 자식이 먼저 마운트를 완료하므로 부모의 onMounted에서는 모든 자식의 DOM이 이미 존재합니다. 또 SSR 환경에서는 onMounted가 서버에서 실행되지 않기 때문에 window·document 접근은 이 훅 안에 두는 것이 안전합니다.'),
(783, 'VUE', 157, 'NORMAL', true,
 '컴포넌트가 언마운트될 때 Vue가 자동으로 해제해 주는 것과 개발자가 직접 해제해야 하는 것은 어떻게 다른가요? 직접 해제하지 않으면 어떤 문제가 생기나요?',
 'watch나 computed처럼 Vue가 만든 이펙트는 컴포넌트가 언마운트될 때 Vue가 자동으로 해제합니다. 반면 setInterval로 만든 타이머, window에 등록한 전역 이벤트 리스너, WebSocket, 외부 라이브러리 인스턴스는 Vue가 관리하지 않으므로 개발자가 직접 해제해야 합니다. 보통 onMounted에서 등록했다면 onBeforeUnmount나 onUnmounted에서 clearInterval, removeEventListener 등으로 해제 코드를 작성합니다. 이를 빠뜨리면 컴포넌트가 사라진 뒤에도 콜백이 계속 실행되어 메모리 누수가 생깁니다. 같은 훅은 여러 번 등록할 수 있고 등록한 순서대로 실행되기 때문에, 컴포저블마다 자기 정리 로직을 onUnmounted에 넣어 둘 수 있습니다.'),
(784, 'VUE', 157, 'EASY', true,
 'Vue 컴포넌트의 생명주기 흐름을 설명하고, 각 단계에서 DOM이 어떤 상태인지 말씀해 주시겠어요?',
 '컴포넌트는 생성 → 마운트 → 갱신 → 언마운트 단계를 거칩니다. 먼저 setup()이 실행되어 반응형 상태가 준비되지만 DOM은 없고, 렌더 함수 실행 직전인 onBeforeMount까지도 DOM이 없습니다. 최초 렌더로 실제 DOM이 생성·삽입되면 onMounted가 호출되고, 이때부터 DOM 접근이 가능하며 템플릿 ref도 채워집니다. 이후 상태가 변경되면 재렌더 직전에 onBeforeUpdate가 호출되는데 이때 DOM은 아직 이전 상태이고, diff 후 실제 DOM이 패치되면 onUpdated에서 갱신된 DOM에 접근할 수 있습니다. 부모가 제거하거나 v-if가 false가 되거나 key가 바뀌면 언마운트 단계로 들어가는데, onBeforeUnmount 시점에는 DOM이 아직 존재해 정리 작업을 시작할 수 있고, DOM 제거와 이펙트·감시자 해제가 끝나면 onUnmounted가 호출됩니다. 참고로 Vue 3에서는 Vue 2의 beforeDestroy/destroyed가 beforeUnmount/unmounted로 이름만 바뀌었고, KeepAlive로 캐시된 컴포넌트는 onActivated/onDeactivated가 추가로 호출됩니다.'),
(785, 'VUE', 157, 'EASY', true,
 '<script setup>에서 await로 데이터를 받아온 뒤 onMounted를 등록했더니 훅이 실행되지 않았습니다. 왜 그런가요?',
 '생명주기 훅은 setup 실행 중에 동기적으로 호출되어야 현재 컴포넌트 인스턴스에 등록됩니다. Vue는 지금 setup 중인 컴포넌트를 전역 변수로 추적하는데, await나 비동기 콜백 뒤에는 이 추적이 이미 끝나 있어 훅이 어느 컴포넌트에 속하는지 알 수 없습니다. 그래서 await 뒤에 등록한 onMounted는 경고와 함께 무시되고 실행되지 않습니다. 개선하려면 훅을 먼저 동기적으로 등록하고, 비동기 작업은 onMounted(async () => { const data = await fetchData() })처럼 훅 안이나 별도 함수에서 수행해야 합니다. 같은 이유로 컴포저블도 setup 최상위에서 동기적으로 호출해야 그 내부의 훅이 제대로 등록됩니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 781
(4209, 781, '상태 변경은 큐에 모였다가 마이크로태스크에서 한 번에 렌더링됨을 설명', 'ESSENTIAL', 1),
(4210, 781, 'v-if 조건을 참으로 바꾼 직후에는 템플릿 ref가 아직 null임을 언급', 'ESSENTIAL', 2),
(4211, 781, 'await nextTick()으로 DOM 갱신을 기다린 뒤 focus()를 호출하는 해결책을 제시', 'ESSENTIAL', 3),
(4212, 781, 'watch에 flush: ''post''를 주어 DOM 갱신 이후 콜백을 실행하는 대안을 제시', 'ESSENTIAL', 4),
(4213, 781, 'onUpdated 안에서 상태를 변경하면 무한 루프에 빠질 수 있음을 언급', 'SUPPLEMENTARY', 5),
(4214, 781, '배칭 덕분에 같은 틱에서 상태를 여러 번 바꿔도 렌더는 1번임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 782
(4215, 782, 'setup 시점에는 DOM이 아직 생성되지 않았음을 언급', 'ESSENTIAL', 1),
(4216, 782, '상태·컴포저블 초기화·데이터 요청 시작 중 최소 1개를 setup 용도로 제시', 'ESSENTIAL', 2),
(4217, 782, 'onMounted 시점에는 DOM이 생성되어 템플릿 ref가 채워져 있음을 언급', 'ESSENTIAL', 3),
(4218, 782, 'DOM 측정·외부 라이브러리 초기화·이벤트 등록 중 최소 1개를 onMounted 용도로 제시', 'ESSENTIAL', 4),
(4219, 782, '<script setup> 최상위에서 템플릿 ref나 document.querySelector를 읽으면 null임을 언급', 'SUPPLEMENTARY', 5),
(4220, 782, '부모의 onMounted 시점에는 모든 자식의 DOM이 이미 존재함을 언급', 'SUPPLEMENTARY', 6),
(4221, 782, 'SSR 환경에서는 onMounted가 서버에서 실행되지 않음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 783
(4222, 783, 'watch·computed처럼 Vue가 만든 이펙트는 언마운트 시 자동 해제됨을 언급', 'ESSENTIAL', 1),
(4223, 783, 'setInterval·전역 이벤트 리스너·WebSocket·외부 라이브러리 인스턴스 중 최소 1개를 직접 해제 대상으로 제시', 'ESSENTIAL', 2),
(4224, 783, '해제를 빠뜨리면 컴포넌트가 사라진 뒤에도 콜백이 실행되는 메모리 누수가 생김을 설명', 'ESSENTIAL', 3),
(4225, 783, 'onBeforeUnmount 또는 onUnmounted에서 직접 해제 코드를 작성함을 언급', 'SUPPLEMENTARY', 4),
(4226, 783, '같은 훅을 여러 번 등록하면 등록한 순서대로 실행됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 784
(4227, 784, '생성 → 마운트 → 갱신 → 언마운트 단계 흐름을 순서대로 설명', 'ESSENTIAL', 1),
(4228, 784, 'onBeforeMount까지는 DOM이 없고 onMounted에서 DOM 접근이 가능해짐을 언급', 'ESSENTIAL', 2),
(4229, 784, 'onBeforeUpdate 시점 DOM은 이전 상태, onUpdated 시점 DOM은 갱신된 상태임을 구분', 'ESSENTIAL', 3),
(4230, 784, 'onBeforeUnmount 시점에는 DOM이 아직 존재함을 언급', 'SUPPLEMENTARY', 4),
(4231, 784, 'Vue 3에서 beforeDestroy/destroyed가 beforeUnmount/unmounted로 이름이 바뀌었음을 언급', 'SUPPLEMENTARY', 5),
(4232, 784, 'KeepAlive로 캐시된 컴포넌트는 onActivated/onDeactivated가 추가로 호출됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 785
(4233, 785, '생명주기 훅은 setup 실행 중에 동기적으로 호출해야 컴포넌트 인스턴스에 등록됨을 언급', 'ESSENTIAL', 1),
(4234, 785, 'Vue가 setup 중인 컴포넌트를 전역 변수로 추적하는데 await 뒤에는 추적이 끝나 있음을 설명', 'ESSENTIAL', 2),
(4235, 785, 'await 뒤에 등록한 훅은 경고와 함께 무시됨을 언급', 'SUPPLEMENTARY', 3),
(4236, 785, '훅을 먼저 동기적으로 등록하고 비동기 작업은 onMounted(async) 안에서 수행하는 개선을 제시', 'SUPPLEMENTARY', 4),
(4237, 785, '컴포저블도 setup 최상위에서 동기적으로 호출해야 내부 훅이 등록됨을 언급', 'SUPPLEMENTARY', 5);
