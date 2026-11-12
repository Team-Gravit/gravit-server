-- Unit: ref와 reactive (Unit ID: 152)
-- Chapter: Vue.js (Chapter ID: 14)
-- Topic: VUE
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-vue-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(756, 'VUE', 152, 'HARD', true,
 '컴포저블이 reactive 객체를 반환했는데, 사용하는 쪽에서 이를 구조 분해하거나 변수에 새 객체를 통째로 대입했더니 화면이 갱신되지 않았습니다. 각각의 원인과 해결 방법, 그리고 이런 문제를 줄이기 위한 ref와 reactive 선택 기준을 설명해 주세요.',
 '반응성은 Proxy를 통해 속성에 접근하는 행위를 가로채서 동작합니다. 그런데 구조 분해는 그 접근을 딱 한 번 실행하고 결과를 일반 변수에 복사하기 때문에, 이후로는 Proxy를 거치지 않아 추적도 트리거도 일어나지 않습니다. 예를 들어 let { count } = state 후 count++를 해도 state.count는 그대로이고 화면도 갱신되지 않습니다. 해결은 toRefs로 각 속성을 원본과 양방향 연결된 ref로 변환해서 꺼내는 것입니다. toRefs가 만든 ref는 내부적으로 원본 Proxy를 다시 읽는 구조라 연결이 유지되고, 그래서 컴포저블에서 reactive 객체를 반환할 때 toRefs로 감쌉니다. 새 객체를 통째로 대입하는 경우도 마찬가지로, state = reactive({...})는 변수가 새 Proxy를 가리킬 뿐 템플릿이 붙잡고 있던 옛 Proxy는 그대로여서 연결이 끊깁니다. 교체가 필요하면 Object.assign(state, newObj)로 기존 객체의 내용을 바꾸거나 처음부터 ref로 감싸면 됩니다. 이런 이유로 공식 문서와 대부분의 스타일 가이드는 ref를 기본값으로 권장합니다. ref는 원시값과 객체를 모두 처리할 수 있고, x.value = newObj 같은 재할당과 구조 분해에서 안전하며, 컴포저블의 반환값으로 일관된 형태를 유지할 수 있기 때문입니다. reactive는 폼 상태처럼 여러 필드를 한 덩어리로 다루는 로컬 상태에서 가독성을 높이고 싶을 때 사용합니다.',
 'interview-question/756.mp3'),
(757, 'VUE', 152, 'NORMAL', true,
 'Vue 3의 ref와 reactive는 어떤 차이가 있고, 각각 어떤 데이터에 적합한가요?',
 'ref는 원시값·객체·배열 등 모든 값을 감쌀 수 있지만, reactive는 객체를 Proxy로 감싸는 방식이라 객체·배열·Map·Set만 다룰 수 있습니다. 접근 방식도 달라서 ref는 .value로 접근하고(템플릿 최상위에서는 자동 언박싱), reactive는 일반 객체처럼 속성에 바로 접근합니다. 또 ref는 x.value = newObj처럼 전체 재할당이 가능하지만 reactive는 전체를 재할당하면 연결이 끊겨 불가능합니다. 타입 측면에서는 ref가 Ref<T>로 명확하게 추론되고 reactive는 원본 타입을 그대로 가집니다. 그래서 ref는 단일 값이나 API 응답처럼 교체되는 데이터에 적합하고, reactive는 폼 상태처럼 서로 묶여 다니는 필드 집합에서 .value를 줄여 가독성을 높이고 싶을 때 적합합니다.',
 'interview-question/757.mp3'),
(758, 'VUE', 152, 'NORMAL', true,
 '기본 ref와 shallowRef는 반응성 추적 범위에서 어떻게 다르며, 언제 shallowRef를 선택하나요?',
 '기본 ref는 깊은(deep) 반응성이라 중첩된 객체 내부까지 추적합니다. reactive와 마찬가지로 중첩된 객체까지 모두 Proxy로 감싸므로 데이터가 크면 비용이 듭니다. 반면 shallowRef는 .value 교체만 추적하고, rows.value[0].name = ''변경'' 같은 내부 변경은 추적하지 않아 화면이 갱신되지 않습니다. 그래서 최상위 변경만 추적하면 충분한 경우, 예를 들어 수만 개의 행을 가진 대용량 리스트나 외부 라이브러리 인스턴스를 보관할 때 shallowRef를 선택합니다. 내부를 바꾼 뒤 갱신이 필요하면 triggerRef로 수동 트리거할 수 있고, 차트·지도 인스턴스처럼 내부 상태가 방대한 객체는 markRaw로 반응형으로 만들지 않도록 표시할 수도 있습니다. 다만 얕은 반응성은 기본값이 아니라 성능 최적화 수단이므로 변수명이나 주석으로 의도를 드러내는 것이 좋습니다.',
 'interview-question/758.mp3'),
(759, 'VUE', 152, 'EASY', true,
 'Vue 3에서 ref는 왜 .value로 접근해야 하나요?',
 'Vue 3의 반응성은 Proxy 기반인데, Proxy는 객체만 감쌀 수 있어서 숫자·문자열·불리언 같은 원시값은 그대로 반응형으로 만들 수 없습니다. 그래서 ref는 원시값을 { value } 형태의 객체, 즉 상자로 한 번 감쌉니다. 이 상자 객체가 RefImpl입니다. value 속성에 getter와 setter를 두어 value를 읽을 때 추적하고 쓸 때 트리거하므로, 상자를 통해 .value로 접근해야 추적·트리거가 가능합니다. 원시값은 참조가 아니라 값으로 복사되기 때문에 이 값을 가리키는 상자를 주고받아야 변경을 추적할 수 있고, 그래서 .value는 불편함이 아니라 필연입니다. 참고로 ref에 객체를 넣으면 내부적으로 reactive()로 변환해 보관합니다.',
 'interview-question/759.mp3'),
(760, 'VUE', 152, 'EASY', true,
 'ref의 .value가 자동으로 언박싱되는 경우와 .value가 필요한 경우를 설명해 주세요.',
 '<script> 안에서 ref에 접근할 때는 count.value++처럼 항상 .value가 필요합니다. 반면 템플릿에서는 컴파일러가 최상위 ref를 자동 언박싱하므로 {{ count }}처럼 .value 없이 씁니다. 또 reactive 객체의 속성으로 담긴 ref도 자동 언박싱되어 state.count로 접근하며, 이때 원래 ref와 같은 값을 공유합니다. 하지만 템플릿에서 일반 객체의 속성으로 중첩된 ref는 풀리지 않아 obj.count.value처럼 써야 하고, 그대로 연산하면 [object Object]1 같은 결과가 나옵니다. reactive 배열이나 Map 안에 담긴 ref도 언박싱되지 않아 list[0].value처럼 .value가 필요합니다.',
 'interview-question/760.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 756
(4072, 756, '구조 분해가 Proxy를 한 번만 거쳐 값을 일반 변수에 복사해 이후 추적이 끊긴다고 설명', 'ESSENTIAL', 1),
(4073, 756, 'toRefs로 각 속성을 원본과 연결된 ref로 꺼내 구조 분해 문제를 해결함을 제시', 'ESSENTIAL', 2),
(4074, 756, 'reactive 변수에 새 객체를 대입하면 템플릿이 옛 Proxy를 붙잡고 있어 연결이 끊긴다고 설명', 'ESSENTIAL', 3),
(4075, 756, '재할당·구조 분해에 안전한 ref를 기본값으로 쓰는 선택 기준을 제시', 'ESSENTIAL', 4),
(4076, 756, 'Object.assign(state, newObj)로 기존 reactive 객체의 내용을 교체하는 방법을 제시', 'SUPPLEMENTARY', 5),
(4077, 756, 'toRefs가 만든 ref가 원본 Proxy를 다시 읽는 구조라 연결이 유지된다고 설명', 'SUPPLEMENTARY', 6),

-- 질문 757
(4078, 757, 'ref는 원시값을 포함한 모든 값을, reactive는 객체·배열·Map·Set만 감쌀 수 있다는 차이를 설명', 'ESSENTIAL', 1),
(4079, 757, 'ref는 .value로, reactive는 일반 객체처럼 접근한다는 차이를 설명', 'ESSENTIAL', 2),
(4080, 757, 'ref는 단일 값·교체되는 데이터에, reactive는 묶여 다니는 필드 집합에 적합하다고 설명', 'ESSENTIAL', 3),
(4081, 757, '전체 재할당이 ref는 가능하고 reactive는 불가능하다고 언급', 'SUPPLEMENTARY', 4),
(4082, 757, 'ref는 Ref<T>로 타입 추론이 명확하다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 758
(4083, 758, '기본 ref는 중첩된 객체 내부까지 추적하는 깊은(deep) 반응성임을 언급', 'ESSENTIAL', 1),
(4084, 758, 'shallowRef는 .value 교체만 추적하고 내부 필드 변경은 추적하지 않는다고 설명', 'ESSENTIAL', 2),
(4085, 758, '대용량 리스트나 외부 라이브러리 인스턴스 보관 시 shallowRef를 선택한다고 제시', 'ESSENTIAL', 3),
(4086, 758, '내부 변경 후 triggerRef로 수동 트리거할 수 있다고 언급', 'SUPPLEMENTARY', 4),
(4087, 758, 'markRaw로 객체를 절대 반응형으로 만들지 않도록 표시할 수 있다고 언급', 'SUPPLEMENTARY', 5),
(4088, 758, '얕은 반응성은 기본값이 아닌 성능 최적화 수단이라고 언급', 'SUPPLEMENTARY', 6),

-- 질문 759
(4089, 759, 'Proxy는 객체만 감쌀 수 있어 원시값을 직접 반응형으로 만들 수 없다고 설명', 'ESSENTIAL', 1),
(4090, 759, 'ref가 원시값을 { value } 형태의 객체(상자)로 한 번 감싼다고 설명', 'ESSENTIAL', 2),
(4091, 759, 'value 속성을 읽을 때 추적, 쓸 때 트리거가 일어난다고 설명', 'ESSENTIAL', 3),
(4092, 759, 'ref에 객체를 넣으면 내부적으로 reactive()로 변환해 보관한다고 언급', 'SUPPLEMENTARY', 4),
(4093, 759, '원시값은 참조가 아니라 값으로 복사되기 때문에 상자가 필요하다고 언급', 'SUPPLEMENTARY', 5),
(4094, 759, 'ref가 만드는 상자 객체의 이름이 RefImpl임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 760
(4095, 760, '템플릿의 최상위 ref는 .value 없이 자동 언박싱된다고 언급', 'ESSENTIAL', 1),
(4096, 760, 'script 안에서 ref에 접근할 때는 .value가 필요하다고 언급', 'ESSENTIAL', 2),
(4097, 760, 'reactive 객체의 속성으로 담긴 ref는 자동 언박싱된다고 언급', 'ESSENTIAL', 3),
(4098, 760, '템플릿에서 일반 객체 안에 중첩된 ref는 자동 언박싱되지 않는다고 언급', 'SUPPLEMENTARY', 4),
(4099, 760, 'reactive 배열·Map 안의 ref는 언박싱되지 않아 .value가 필요하다고 언급', 'SUPPLEMENTARY', 5);
