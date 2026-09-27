-- Unit: computed와 watch (Unit ID: 153)
-- Chapter: Vue.js (Chapter ID: 14)
-- Topic: VUE
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-vue-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(761, 'VUE', 153, 'HARD', true,
 '검색어가 바뀔 때마다 API를 호출하고, 받아온 결과를 필터링해 화면에 보여줘야 한다면 computed와 watch를 각각 어디에 쓰시겠어요? 역할을 반대로 쓰면 어떤 문제가 생기는지도 설명해 주세요.',
 '검색어 변경에 따른 API 호출은 값을 만드는 것이 아니라 네트워크 요청이라는 부수 효과이므로 watch로 검색어를 감시하다가 바뀌면 콜백에서 요청을 보내고 결과를 상태에 저장합니다. 반면 받아온 결과 중 조건에 맞는 항목만 걸러내는 것은 다른 상태로부터 계산될 수 있는 파생 값이므로 computed로 만듭니다. 판단 기준은 ''이 값이 다른 상태로부터 계산될 수 있는가''이고, 계산이 아니라 요청·저장·이동 같은 행동이 필요하면 watch입니다. 역할을 반대로 쓰면 문제가 생깁니다. computed 안에서 비동기 요청을 하면, computed가 언제 재계산될지(혹은 안 될지)는 Vue가 결정하기 때문에 부수 효과의 실행 시점이 예측 불가능해집니다. computed 안에서 loading 같은 다른 상태를 바꾸면 무한 루프가 생길 수도 있어서 computed는 순수 함수여야 합니다. 거꾸로 필터링 결과를 watch로 별도 ref에 동기화하면 상태를 두 벌로 관리하는 셈이 되어 버그의 온상이 되고, 중복 상태와 초기값 누락 위험이 생깁니다. 그래서 파생 값은 computed 하나로 끝내고, 부수 효과만 watch로 분리합니다.'),
(762, 'VUE', 153, 'NORMAL', true,
 '템플릿에서 메서드를 호출해 값을 계산하는 것과 computed를 쓰는 것은 어떤 차이가 있나요?',
 '템플릿에서 메서드를 호출하면 렌더링될 때마다 무조건 실행됩니다. 반면 computed는 의존성 기반으로 캐싱되기 때문에 의존하는 상태가 바뀌었을 때만 재계산됩니다. 의존하는 상태가 바뀌지 않았다면 몇 번을 읽어도 계산을 다시 하지 않고 캐시된 값을 그대로 반환합니다. 그래서 리스트 필터링이나 정렬처럼 비용이 큰 계산일수록 메서드와 computed의 차이가 커지고, 다른 상태로부터 계산되는 값은 computed로 두는 것이 유리합니다.'),
(763, 'VUE', 153, 'NORMAL', true,
 'watch와 watchEffect는 어떤 차이가 있고, 각각 어떤 상황에서 선택하시나요?',
 'watch는 감시할 소스를 직접 지정하는 반면, watchEffect는 소스를 지정하지 않고 콜백 안에서 읽은 반응형 값을 자동으로 의존성으로 추적합니다. watch는 콜백에서 (newVal, oldVal)로 이전 값에 접근할 수 있지만 watchEffect는 이전 값에 접근할 수 없습니다. 최초 실행도 다른데, watch는 지연되어 소스가 바뀔 때 처음 실행되고(immediate: true를 주면 등록 즉시 한 번 실행), watchEffect는 등록 즉시 한 번 실행됩니다. 선택 기준은 이렇습니다. ''A가 바뀌면 B를 해라''처럼 인과가 명확할 때, 즉 이전 값이 필요하거나 특정 값의 변경에만 반응해야 하면 watch를 씁니다. 반대로 의존성이 여러 개고 여러 값을 조합해 동기화하는 선언적 로직이라면 watchEffect가 간결합니다. 다만 watchEffect는 콜백이 커질수록 무엇에 반응하는지 읽기 어려워지므로 팀 코드에서는 watch를 기본으로 두고 watchEffect는 짧은 동기화 로직에 한정하는 편이 관리하기 쉽습니다. 또 watchEffect에서 await 뒤에 읽은 반응형 값은 의존성으로 등록되지 않으므로 필요한 값은 await 전에 읽어 두어야 합니다.'),
(764, 'VUE', 153, 'EASY', true,
 'Vue의 computed가 무엇이고, 내부적으로 어떻게 동작하는지 설명해 주세요.',
 'computed는 다른 반응형 상태로부터 계산된 값, 즉 파생 상태를 만드는 기능이고 핵심은 캐싱입니다. 내부적으로는 더티(dirty) 플래그를 가진 지연 이펙트로, 의존성이 바뀌면 즉시 재계산하지 않고 더티 플래그만 세워 둡니다. 그리고 누군가 .value를 읽을 때 비로소 재계산하고 캐시를 갱신한 뒤 플래그를 내립니다. 의존하는 상태가 바뀌지 않았다면 몇 번을 읽어도 계산을 다시 하지 않고 캐시를 즉시 반환합니다. 또 계산 도중 읽은 상태가 자동으로 의존성이 되므로 의존성을 별도로 선언할 필요가 없습니다.'),
(765, 'VUE', 153, 'EASY', true,
 'reactive 객체의 특정 속성 하나를 watch로 감시하려면 어떻게 작성해야 하고, 그 이유는 무엇인가요?',
 'reactive 객체의 특정 속성을 감시하려면 watch(() => state.count, cb)처럼 getter 함수로 감싸서 넘겨야 합니다. watch(state.count, cb)처럼 속성을 직접 넘기면 숫자 값 하나가 전달될 뿐이라 감시가 되지 않기 때문입니다. reactive를 구조 분해할 때와 같은 원리입니다. 참고로 ref는 .value 없이 ref 자체를 전달하면 되고, reactive 객체 전체를 소스로 넘기면 암묵적으로 deep 감시가 되며 이전 값과 새 값이 같은 객체가 됩니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 761
(4100, 761, 'API 호출 같은 비동기 부수 효과는 watch에 두어야 함을 언급', 'ESSENTIAL', 1),
(4101, 761, '결과 필터링 같은 파생 값은 computed로 계산해야 함을 언급', 'ESSENTIAL', 2),
(4102, 761, 'computed의 재계산 시점은 Vue가 결정하므로 비동기 요청의 실행 시점이 예측 불가능함을 설명', 'ESSENTIAL', 3),
(4103, 761, '파생 값을 watch로 만들면 상태를 두 벌로 관리하게 됨을 언급', 'ESSENTIAL', 4),
(4104, 761, 'computed 안에서 다른 상태를 바꾸면 무한 루프 위험이 있음을 언급', 'SUPPLEMENTARY', 5),
(4105, 761, 'watch로 파생 값을 동기화하면 초기값 누락 위험이 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 762
(4106, 762, '템플릿의 메서드 호출은 렌더링될 때마다 무조건 실행됨을 언급', 'ESSENTIAL', 1),
(4107, 762, 'computed는 의존성이 바뀌었을 때만 재계산됨을 언급', 'ESSENTIAL', 2),
(4108, 762, '의존성이 그대로면 computed가 계산 없이 캐시된 값을 반환함을 언급', 'ESSENTIAL', 3),
(4109, 762, '리스트 필터링·정렬처럼 비용이 큰 계산일수록 차이가 커짐을 언급', 'SUPPLEMENTARY', 4),

-- 질문 763
(4110, 763, 'watch는 소스를 직접 지정하고 watchEffect는 콜백에서 읽은 값을 자동 추적하는 차이를 설명', 'ESSENTIAL', 1),
(4111, 763, 'watch는 이전 값에 접근할 수 있지만 watchEffect는 불가능함을 언급', 'ESSENTIAL', 2),
(4112, 763, 'watch는 최초 실행이 지연되고 watchEffect는 즉시 실행됨을 언급', 'ESSENTIAL', 3),
(4113, 763, '인과가 명확하면 watch, 여러 값을 조합한 선언적 동기화면 watchEffect를 선택함을 설명', 'ESSENTIAL', 4),
(4114, 763, 'watch도 immediate: true 옵션으로 등록 즉시 실행할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(4115, 763, 'watchEffect는 콜백이 커질수록 무엇에 반응하는지 읽기 어려워짐을 언급', 'SUPPLEMENTARY', 6),
(4116, 763, 'watchEffect에서 await 뒤에 읽은 반응형 값은 의존성으로 등록되지 않음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 764
(4117, 764, 'computed가 다른 반응형 상태로부터 계산된 파생 값을 만듦을 언급', 'ESSENTIAL', 1),
(4118, 764, '의존성 변경 시 더티 플래그만 세우고 .value를 읽을 때 재계산하는 지연 평가를 설명', 'ESSENTIAL', 2),
(4119, 764, '의존하는 상태가 바뀌지 않았다면 여러 번 읽어도 다시 계산하지 않음을 언급', 'ESSENTIAL', 3),
(4120, 764, '계산 도중 읽은 상태가 자동으로 의존성이 되어 따로 선언할 필요가 없음을 언급', 'SUPPLEMENTARY', 4),

-- 질문 765
(4121, 765, 'reactive의 특정 속성은 () => state.count 같은 getter 함수로 감싸 전달해야 함을 언급', 'ESSENTIAL', 1),
(4122, 765, 'watch(state.count, cb)처럼 속성을 직접 넘기면 숫자 값 하나만 전달돼 감시되지 않는 이유를 설명', 'ESSENTIAL', 2),
(4123, 765, 'ref는 .value 없이 ref 자체를 감시 소스로 전달함을 언급', 'SUPPLEMENTARY', 3),
(4124, 765, 'reactive 객체 전체를 소스로 넘기면 암묵적으로 deep 감시됨을 언급', 'SUPPLEMENTARY', 4);
