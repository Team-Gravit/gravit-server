-- Unit: Composition API와 Options API (Unit ID: 154)
-- Chapter: Vue.js (Chapter ID: 14)
-- Topic: VUE
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-vue-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(766, 'VUE', 154, 'HARD', true,
 '여러 컴포넌트에서 쓸 컴포저블을 만들 때, 컴포저블을 await 뒤에서 호출하거나 reactive 객체를 그대로 반환하면 어떤 문제가 생기고 어떻게 설계해야 하나요?',
 '먼저 호출 시점 문제입니다. 컴포저블 안의 onMounted나 watch 같은 훅 등록은 컴포넌트 setup 실행 컨텍스트 안에서만 유효합니다. 그래서 await 뒤에서 컴포저블을 호출하면 setup 컨텍스트가 이미 끝나 생명주기 훅이 등록되지 않습니다. 조건문이나 비동기 콜백 안에서 호출해도 마찬가지이므로, 컴포저블은 항상 동기적으로 호출해야 합니다. 다음은 반환값 문제입니다. 컴포저블이 reactive 객체를 반환하면 호출부에서 구조 분해할 때 반응성이 끊깁니다. 그래서 컴포저블은 ref들을 담은 일반 객체를 반환하거나, reactive를 쓸 경우 toRefs()로 감싸 반환하는 것이 관례입니다. 추가로 컴포저블이 등록한 이벤트 리스너나 타이머는 onUnmounted에서 정리해 메모리 누수를 막아야 하고, 입력이 반응형일 수 있다면 toValue()로 ref와 getter를 모두 받도록 정규화하면 활용도가 높아집니다.',
 'interview-question/766.mp3'),
(767, 'VUE', 154, 'NORMAL', true,
 'Options API와 Composition API는 코드를 구성하는 방식에서 어떤 차이가 있고, 어떤 상황에서 각각을 선택하시겠어요?',
 'Options API는 data, methods, computed 같은 옵션 종류 단위로 코드를 나누고, Composition API는 setup 안에서 함수 조합으로 기능(관심사) 단위로 로직을 모읍니다. 또 Options API는 this를 통해 상태와 메서드에 접근하지만, Composition API는 this 없이 클로저 변수를 사용합니다. 그래서 Composition API는 TypeScript 지원이 자연스러운 반면, ref와 .value 같은 반응성 원리를 이해해야 해서 학습 곡선은 Options API보다 높습니다. 선택 기준으로는, 신규 Vue 3 프로젝트라면 Composition API와 script setup, TypeScript 조합이 사실상 표준이라 Composition API를 선택합니다. 반대로 Vue 2 레거시를 유지보수하거나 팀이 Options API에 익숙하고 컴포넌트가 작다면 Options API도 충분합니다. 다만 한 프로젝트에서 두 스타일을 섞으면 코드 리뷰와 온보딩 비용이 커지므로 하나로 통일하고, 점진적으로 이전할 때는 새 컴포넌트부터 Composition API로 작성합니다.',
 'interview-question/767.mp3'),
(768, 'VUE', 154, 'NORMAL', true,
 '로직 재사용 수단으로서 Vue 2의 mixin과 Composition API의 컴포저블은 어떤 차이가 있나요?',
 'mixin은 옵션 블록을 다른 컴포넌트에 병합해 로직을 재사용하고, 컴포저블은 반응형 상태와 로직을 캡슐화한 일반 함수로 재사용합니다. 첫째, mixin은 this.page 같은 속성이 어느 mixin에서 왔는지 컴포넌트 코드만으로 알 수 없지만, 컴포저블은 import 문과 구조 분해 이름으로 출처가 바로 보입니다. 둘째, 두 mixin이 같은 이름의 data나 method를 정의하면 나중 것이 컴파일 오류 없이 조용히 덮어쓰지만, 컴포저블은 반환값을 구조 분해할 때 이름을 바꿀 수 있어 이름 충돌이 없습니다. 셋째, mixin은 컴포넌트에 있을 것이라 가정한 속성을 쓰는 암묵적 결합이 생기지만, 컴포저블은 필요한 값을 인자로 받아 의존성이 명시적입니다. 그 밖에 컴포저블은 같은 컴포넌트에서 여러 번 호출해 독립된 상태를 두 벌 만들 수 있고, 일반 함수의 반환 타입이라 TypeScript 타입이 완전히 추론됩니다. Vue 3에도 mixins 옵션은 하위 호환용으로 남아 있지만 공식 문서는 신규 코드에서 컴포저블을 권장합니다.',
 'interview-question/768.mp3'),
(769, 'VUE', 154, 'EASY', true,
 'Options API에서 컴포넌트가 커질수록 ''관심사가 흩어진다''는 것은 어떤 의미인가요?',
 'Options API는 코드를 데이터인지 메서드인지 같은 종류 단위로, 즉 data, computed, watch, methods, mounted 같은 옵션 블록으로 나눕니다. 그래서 컴포넌트가 커지면 검색 같은 하나의 기능에 관련된 코드가 data, computed, watch, methods, mounted에 흩어지게 됩니다. 이 때문에 기능 하나를 수정하려면 파일을 위아래로 오가며 여러 블록을 동시에 봐야 하고, 그 기능을 다른 컴포넌트로 옮기기도 어렵습니다. 반면 Composition API는 useSearch, usePagination처럼 기능 단위로 로직을 응집할 수 있습니다. 다만 작은 컴포넌트에서는 정해진 자리에 정해진 코드가 있는 Options API가 오히려 읽기 쉽고, Composition API의 이점은 컴포넌트가 커지고 기능이 여러 개 섞일 때 드러납니다.',
 'interview-question/769.mp3'),
(770, 'VUE', 154, 'EASY', true,
 'Vue 3의 <script setup>은 무엇이고, 일반 setup() 함수와 비교해 작성 방식이 어떻게 달라지나요?',
 '<script setup>은 setup() 함수의 컴파일 타임 문법 설탕입니다. 일반 setup() 함수에서는 템플릿에서 쓸 값을 반환해야 하지만, <script setup>에서는 최상위에 선언한 변수와 함수가 자동으로 템플릿에 노출되기 때문에 return이 필요 없습니다. 예를 들어 const count = ref(0)과 increment 함수를 최상위에 선언하면 템플릿에서 바로 사용할 수 있습니다. Composition API와 <script setup> 조합은 Vue 3의 권장 방식이며, Composition API 자체는 Vue 2.7에도 백포트되었습니다.',
 'interview-question/770.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 766
(4125, 766, '훅 등록은 setup 실행 컨텍스트 안에서만 유효해 await 뒤에 호출하면 훅이 등록되지 않음을 설명', 'ESSENTIAL', 1),
(4126, 766, '컴포저블은 await 뒤가 아니라 동기적으로 호출해야 한다는 규칙을 제시', 'ESSENTIAL', 2),
(4127, 766, 'reactive 객체를 반환하면 호출부에서 구조 분해할 때 반응성이 끊긴다는 점을 설명', 'ESSENTIAL', 3),
(4128, 766, 'ref들을 담은 일반 객체로 반환하거나 reactive를 toRefs()로 감싸 반환하는 방법을 제시', 'ESSENTIAL', 4),
(4129, 766, '컴포저블이 등록한 이벤트 리스너·타이머를 onUnmounted에서 정리해 메모리 누수를 막는다고 언급', 'SUPPLEMENTARY', 5),
(4130, 766, '조건문이나 비동기 콜백 안에서 컴포저블을 호출해도 훅이 등록되지 않음을 언급', 'SUPPLEMENTARY', 6),
(4131, 766, '입력을 ref·getter 모두 받도록 toValue()로 정규화하는 방법을 언급', 'SUPPLEMENTARY', 7),

-- 질문 767
(4132, 767, 'Options API는 옵션 종류 단위로, Composition API는 기능(관심사) 단위로 코드를 구성한다는 차이를 설명', 'ESSENTIAL', 1),
(4133, 767, 'Options API는 this로 상태에 접근하고 Composition API는 this 없이 클로저 변수를 쓴다는 차이를 설명', 'ESSENTIAL', 2),
(4134, 767, '신규 Vue 3 프로젝트에서는 Composition API를 선택한다는 기준을 제시', 'ESSENTIAL', 3),
(4135, 767, 'Vue 2 레거시 유지보수나 작은 컴포넌트에는 Options API도 충분하다는 기준을 제시', 'ESSENTIAL', 4),
(4136, 767, 'Composition API가 TypeScript 지원이 자연스럽다는 장점을 언급', 'SUPPLEMENTARY', 5),
(4137, 767, '한 프로젝트에서 두 스타일을 섞지 않고 하나로 통일해야 한다고 언급', 'SUPPLEMENTARY', 6),
(4138, 767, 'Composition API는 반응성 원리(ref·.value)를 알아야 해서 학습 곡선이 더 높다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 768
(4139, 768, 'mixin은 속성의 출처가 불명확하지만 컴포저블은 import로 출처가 드러난다는 차이를 설명', 'ESSENTIAL', 1),
(4140, 768, 'mixin은 같은 이름을 나중 것이 조용히 덮어쓰지만 컴포저블은 구조 분해 시 이름을 바꿀 수 있다는 차이를 설명', 'ESSENTIAL', 2),
(4141, 768, 'mixin의 암묵적 결합과 달리 컴포저블은 필요한 값을 인자로 받아 의존성이 드러난다는 차이를 설명', 'ESSENTIAL', 3),
(4142, 768, '컴포저블은 한 컴포넌트에서 여러 번 호출해 독립된 상태를 여러 벌 만들 수 있다고 언급', 'SUPPLEMENTARY', 4),
(4143, 768, 'mixin은 병합된 this의 타입 추론이 어렵지만 컴포저블은 타입이 완전히 추론된다고 언급', 'SUPPLEMENTARY', 5),
(4144, 768, 'Vue 3의 mixins 옵션은 하위 호환용이며 신규 코드에는 컴포저블이 권장된다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 769
(4145, 769, 'Options API가 코드를 data·methods 같은 종류 단위로 나눈다는 점을 언급', 'ESSENTIAL', 1),
(4146, 769, '한 기능의 코드가 data·computed·watch·methods·mounted 등 여러 옵션 블록에 흩어진다고 설명', 'ESSENTIAL', 2),
(4147, 769, '기능 수정 시 여러 블록을 오가야 하거나 다른 컴포넌트로 옮기기 어렵다는 불편 중 최소 1개를 제시', 'ESSENTIAL', 3),
(4148, 769, '작은 컴포넌트에서는 정해진 자리에 코드가 있는 Options API가 오히려 읽기 쉽다고 언급', 'SUPPLEMENTARY', 4),
(4149, 769, 'Composition API는 useSearch처럼 기능 단위로 로직을 응집할 수 있다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 770
(4150, 770, '<script setup>이 setup() 함수의 컴파일 타임 문법 설탕임을 언급', 'ESSENTIAL', 1),
(4151, 770, '최상위에 선언한 변수·함수가 템플릿에 자동으로 노출된다고 설명', 'ESSENTIAL', 2),
(4152, 770, '<script setup>에서는 return이 필요 없다는 점을 언급', 'ESSENTIAL', 3),
(4153, 770, 'Composition API + <script setup>이 Vue 3 권장 방식이라고 언급', 'SUPPLEMENTARY', 4),
(4154, 770, 'Composition API가 Vue 2.7에 백포트되었다고 언급', 'SUPPLEMENTARY', 5);
