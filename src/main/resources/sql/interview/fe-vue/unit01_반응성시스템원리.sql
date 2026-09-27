-- Unit: 반응성 시스템 원리 (Unit ID: 151)
-- Chapter: Vue.js (Chapter ID: 14)
-- Topic: VUE
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-vue-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(751, 'VUE', 151, 'HARD', true,
 'Vue 3가 반응성 구현을 Object.defineProperty에서 Proxy로 바꾸면서 해결된 문제와, 그 대가로 새로 생긴 주의점이나 제약은 무엇인지 설명해 주세요.',
 'Vue 2는 Object.defineProperty로 초기화 시점에 존재하는 속성마다 getter/setter를 붙이는 속성 단위 방식이라, 새 속성 추가나 삭제, 배열 인덱스 대입, length 변경을 감지하지 못해 Vue.set이나 Vue.delete, splice 같은 우회가 필요했습니다. Vue 3는 객체 전체를 감싸는 Proxy를 만들어 읽기·쓰기·추가·삭제를 트랩으로 가로채므로, 새 속성 추가·삭제를 별도 API 없이 감지하고 Vue.set/Vue.delete가 사라졌습니다. 배열 인덱스 대입과 length 변경도 일반 속성 쓰기와 같은 경로로 감지됩니다. 대신 reactive()는 원본과 다른 Proxy 객체를 반환하기 때문에, 원본 참조를 들고 있다가 원본을 직접 수정하면 추적되지 않아 화면이 갱신되지 않습니다. 따라서 항상 reactive()가 반환한 객체를 사용해야 하고, 구조 분해 등으로 속성값을 밖으로 꺼내 원시값으로 만들면 추적 대상에서 벗어난다는 점도 주의해야 합니다. 반응형 객체를 JSON.stringify나 서드파티 라이브러리에 그대로 넘기면 Proxy 때문에 예상치 못한 동작이 생길 수 있어 toRaw()로 원본을 꺼내 전달합니다. 또한 Proxy는 폴리필이 불가능한 언어 기능이라 Vue 3는 IE를 지원하지 않습니다.'),
(752, 'VUE', 151, 'NORMAL', true,
 'Vue 2에서 배열에 push를 호출하면 화면이 갱신되는데, 인덱스로 직접 값을 대입하면 갱신되지 않는 이유는 무엇이고 어떻게 우회하는지 설명해 주세요.',
 'Vue 2의 반응성은 Object.defineProperty로 속성마다 getter/setter를 바꿔 끼우는 속성 단위 방식입니다. 그런데 배열의 인덱스마다 getter/setter를 붙이지는 않았기 때문에 arr[0] = x 같은 인덱스 대입은 setter를 거치지 않아 감지되지 않습니다. 반면 push, pop, splice 같은 배열 메서드는 Vue 2가 프로토타입을 덮어써서 호출 시 갱신을 알리도록 별도 처리했기 때문에 감지됩니다. 그래서 메서드는 되고 인덱스 대입은 안 되는 비대칭이 생깁니다. 인덱스 대입은 Vue.set(arr, 0, x)나 splice로 우회하고, arr.length = 0 같은 길이 변경도 감지되지 않으므로 arr.splice(0)을 사용합니다. Vue 3는 Proxy를 사용해 배열 인덱스 대입과 length 변경도 일반 속성 쓰기와 같은 경로로 감지하므로 이런 우회가 필요 없습니다.'),
(753, 'VUE', 151, 'NORMAL', true,
 'Vue 2와 Vue 3의 반응성 구현은 변경을 가로채는 방식과 감지 단위 측면에서 어떻게 다른지 설명해 주세요.',
 'Vue 2는 Object.defineProperty를 사용해 data()가 반환한 객체의 모든 속성을 순회하며 각 속성을 getter/setter로 바꿔 끼웁니다. getter에서 의존성을 수집하고 setter에서 갱신을 알리는 방식이라 감지 단위가 개별 속성입니다. Vue 3는 객체를 하나씩 변환하는 대신 객체 전체를 감싸는 Proxy를 만들고, get·set·deleteProperty 같은 트랩으로 속성 읽기·쓰기·추가·삭제를 가로챕니다. 즉 Vue 2는 속성 단위, Vue 3는 객체 전체 단위로 변경을 감지합니다. 초기화 방식도 달라서 Vue 2는 초기화 시 전체 트리를 재귀적으로 즉시 변환하지만, Vue 3는 중첩 객체를 접근하는 순간에만 Proxy로 감싸는 지연 변환이라 초기화 비용이 줄어듭니다. 또한 Vue 2는 원본 객체 자체를 변경하는 반면 Vue 3는 원본과 다른 Proxy 객체를 반환합니다.'),
(754, 'VUE', 151, 'EASY', true,
 'Vue의 반응성이란 무엇이며, 어떤 원리로 상태 변경이 화면에 반영되는지 설명해 주세요.',
 'Vue의 반응성은 상태가 바뀌면 그 상태를 사용하는 화면이나 계산값이 자동으로 갱신되는 메커니즘입니다. 일반 JavaScript에서는 변수를 바꿔도 그 변수로 계산한 값이 다시 계산되지 않지만, Vue는 이를 두 단계로 해결합니다. 먼저 상태를 읽을 때(get) 누가 이 값을 읽었는지 의존성을 기록하는 추적(track)을 하고, 상태가 바뀔 때(set) 기록된 이펙트를 다시 실행하는 트리거(trigger)를 합니다. 이 기록·재실행의 단위를 이펙트라고 하며, 컴포넌트 렌더 함수와 computed, watch가 모두 이펙트입니다. 이펙트는 다시 실행되면서 상태를 다시 읽어 의존성을 재추적합니다.'),
(755, 'VUE', 151, 'EASY', true,
 'Vue에서 동기 코드 안에서 상태를 여러 번 연속으로 변경하면 DOM 갱신은 언제, 몇 번 일어나는지 설명해 주세요.',
 'Vue는 상태가 바뀔 때마다 즉시 렌더링하지 않고, 같은 틱 안에서 일어난 상태 변경을 갱신 큐에 모으는 배칭을 합니다. 예를 들어 동기 코드에서 count++를 두 번 하고 list.push()를 해도 갱신 큐에는 한 번만 등록됩니다. 그래서 상태를 여러 번 바꿔도 DOM 갱신은 한 번입니다. 렌더링은 동기 코드가 모두 끝난 뒤에 일어나며, 구체적으로는 마이크로태스크에서 렌더링이 한 번 실행됩니다. 따라서 상태를 바꾼 직후 갱신된 DOM에 접근하려면 nextTick을 기다려야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 751
(4047, 751, '새 속성 추가·삭제 중 최소 1개를 Proxy가 별도 API 없이 감지함을 언급', 'ESSENTIAL', 1),
(4048, 751, '배열 인덱스 대입·length 변경 중 최소 1개를 Proxy가 감지함을 언급', 'ESSENTIAL', 2),
(4049, 751, 'reactive()가 원본과 다른 Proxy 객체를 반환해 원본을 직접 수정하면 추적되지 않음을 설명', 'ESSENTIAL', 3),
(4050, 751, 'Proxy는 폴리필이 불가능해 Vue 3가 IE를 지원하지 않음을 언급', 'SUPPLEMENTARY', 4),
(4051, 751, '구조 분해로 속성값을 꺼내 원시값이 되면 추적 대상에서 벗어남을 언급', 'SUPPLEMENTARY', 5),
(4052, 751, '반응형 객체를 서드파티 라이브러리에 넘길 때 toRaw()로 원본을 꺼내 전달함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 752
(4053, 752, 'defineProperty는 배열 인덱스마다 getter/setter를 붙이지 않아 인덱스 대입을 감지하지 못함을 설명', 'ESSENTIAL', 1),
(4054, 752, 'push·pop·splice 같은 배열 메서드는 프로토타입을 덮어써서 감지하도록 처리했음을 설명', 'ESSENTIAL', 2),
(4055, 752, '인덱스 대입의 우회 방법으로 Vue.set 또는 splice 중 최소 1개를 제시', 'ESSENTIAL', 3),
(4056, 752, 'arr.length = 0 같은 배열 길이 변경도 감지되지 않아 splice로 우회함을 언급', 'SUPPLEMENTARY', 4),
(4057, 752, 'Vue 3의 Proxy는 배열 인덱스 대입을 일반 속성 쓰기와 같은 경로로 감지함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 753
(4058, 753, 'Vue 2는 개별 속성 단위, Vue 3는 객체 전체 단위로 변경을 감지하는 차이를 설명', 'ESSENTIAL', 1),
(4059, 753, 'Vue 2는 data 객체의 모든 속성을 순회하며 getter/setter로 바꿔 끼움을 설명', 'ESSENTIAL', 2),
(4060, 753, 'Vue 3는 Proxy 트랩으로 속성 읽기·쓰기·추가·삭제 중 최소 1개를 가로챔을 설명', 'ESSENTIAL', 3),
(4061, 753, 'Vue 2는 초기화 시 전체 트리를 재귀 변환하고 Vue 3는 접근 시점에 지연 변환함을 설명', 'SUPPLEMENTARY', 4),
(4062, 753, 'Vue 2는 원본 객체 자체를 변경하고 Vue 3는 원본과 다른 Proxy 객체를 반환함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 754
(4063, 754, '반응성은 상태가 바뀌면 그 상태를 사용하는 화면·계산값이 자동으로 갱신되는 메커니즘임을 설명', 'ESSENTIAL', 1),
(4064, 754, '값을 읽을 때 누가 읽었는지 의존성을 기록하는 추적(track) 단계를 설명', 'ESSENTIAL', 2),
(4065, 754, '값이 바뀌면 기록된 이펙트를 재실행하는 트리거(trigger) 단계를 설명', 'ESSENTIAL', 3),
(4066, 754, '렌더 함수·computed·watch가 모두 이펙트임을 언급', 'SUPPLEMENTARY', 4),

-- 질문 755
(4067, 755, '같은 틱 안의 상태 변경을 갱신 큐에 모으는 배칭을 설명', 'ESSENTIAL', 1),
(4068, 755, '상태를 여러 번 바꿔도 DOM 갱신은 한 번임을 명시', 'ESSENTIAL', 2),
(4069, 755, '렌더링이 동기 코드가 모두 끝난 뒤에 일어남을 언급', 'ESSENTIAL', 3),
(4070, 755, '렌더링이 마이크로태스크에서 일어남을 언급', 'SUPPLEMENTARY', 4),
(4071, 755, '갱신된 DOM에 접근하려면 nextTick을 기다려야 함을 언급', 'SUPPLEMENTARY', 5);
