-- Unit: 렌더링 최적화 판단 (Unit ID: 146)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(726, 'REACT', 146, 'HARD', true,
 '검색 입력창에 글자를 칠 때마다 화면이 느려진다는 제보를 받았다면, 원인을 찾고 최적화하기까지 어떤 순서로 진행하고 각 단계에서 무엇을 판단하시겠어요?',
 '느리다고 느껴지는 것만으로 바로 useMemo나 useCallback을 붙이지 않고, 먼저 React DevTools의 Profiler로 입력 상호작용을 녹화해 커밋별로 어떤 컴포넌트가 몇 ms 걸렸는지 측정합니다. 최적화는 리렌더가 실제로 느리고, 그 리렌더가 불필요할 때만 의미가 있기 때문입니다. 다음으로 느린 커밋의 원인 컴포넌트를 클릭해 "Why did this render?"로 부모가 렌더돼서인지, props가 바뀌었는지, 자신의 state나 context가 바뀌었는지를 확인합니다. 예를 들어 입력값 state가 Page처럼 너무 위에 있어서 query와 무관한 HeavyList까지 매 키 입력마다 함께 렌더되는 경우라면, 메모 훅보다 입력 상태를 쓰는 부분만 SearchInput 같은 별도 컴포넌트로 내리는 구조 개선을 먼저 합니다. 상태를 가진 컴포넌트가 무거운 자식을 감싸야 한다면 자식을 children으로 받아 부모가 리렌더돼도 같은 참조라 렌더가 생략되게 할 수 있습니다. 구조 개선 후에도 불필요한 렌더가 남으면 그때 memo를 적용하고, 참조형 props는 useMemo나 useCallback으로 고정한 뒤, 다시 측정해 효과를 확인합니다. 모든 메모는 의존성 비교, 캐시 저장 메모리, 코드 가독성이라는 비용을 지불하고 측정 없이 적용된 메모는 부채가 되므로 측정된 병목에만 적용해야 하고, 개발 빌드는 느리기 때문에 최종 판단은 프로덕션 프로파일링 빌드나 실제 배포 환경에서 합니다.'),
(727, 'REACT', 146, 'NORMAL', true,
 'React.memo, useMemo, useCallback은 각각 무엇을 기억하고 어떤 역할 차이가 있나요?',
 'React.memo는 컴포넌트의 마지막 렌더 결과를 기억하고, props를 필드별로 Object.is 얕은 비교해 같으면 렌더를 건너뜁니다. 즉 부모 리렌더로 인한 자식 리렌더를 막으며, 자신의 state나 context 변경으로 인한 리렌더는 막지 못합니다. useMemo는 계산 결과 값을 기억해 의존성 배열이 같으면 비싼 계산을 반복하지 않고 객체·배열 참조도 유지합니다. useCallback은 함수 참조를 기억하며 useMemo(() => fn, deps)와 같습니다. 중요한 차이는 useMemo와 useCallback은 그 자체로는 리렌더를 막지 않는다는 점입니다. 이 둘은 참조를 고정해 memo된 자식이나 이펙트 의존성이 ''같다''고 판단하게 만드는 보조 도구이고, 예를 들어 memo된 Row에 넘기는 onSelect를 useCallback으로 고정하지 않으면 매 렌더 새 함수가 생겨 memo가 무력화됩니다. 또한 셋 다 보장이 아니라 힌트이므로 정확성이 메모에 의존하면 안 됩니다.'),
(728, 'REACT', 146, 'NORMAL', true,
 'memo나 useMemo, useCallback을 적용해도 효과가 없는 경우와 효과가 있는 경우는 각각 어떤 상황인가요?',
 '효과가 없는 대표 경우는 먼저 memo한 컴포넌트에 인라인 객체·배열·함수나 children JSX처럼 매번 새 참조가 props로 들어오는 경우입니다. 이때는 얕은 비교가 항상 실패해 memo 비용만 추가됩니다. 또 <li>{name}</li> 수준의 싼 렌더에 memo를 쓰면 props 비교 비용과 큰 차이가 없어 이득이 없고 코드만 복잡해지며, a + b나 짧은 배열 filter 같은 싼 계산에 useMemo를 쓰면 의존성 비교, 클로저 생성, 캐시 저장 같은 메모 오버헤드가 계산보다 큽니다. useCallback은 받는 자식이 memo이거나 이펙트 의존성으로 쓰일 때만 의미가 있고, 일반 <button>에 넘기는 함수처럼 아무도 참조 안정성을 활용하지 않으면 비교·메모리 비용만 발생합니다. 반대로 효과가 있는 경우는 부모가 자주 리렌더되고, 자식 렌더가 비싸며, props가 대체로 같은 조건이 겹칠 때 memo를 쓰고 참조 props를 useMemo·useCallback으로 고정하는 경우, 수만 개 항목 정렬·필터처럼 눈에 띄게 비싼 계산에 useMemo를 쓰는 경우, 객체·배열·함수를 memo된 자식 props나 이펙트 의존성으로 전달하는 경우입니다. ''일단 다 감싸면 손해는 없다''는 틀린 생각이며, 의존성 배열을 잘못 적으면 낡은 값을 보여주는 정확성 버그까지 생길 수 있습니다.'),
(729, 'REACT', 146, 'EASY', true,
 '메모이제이션 훅을 쓰지 않고 컴포넌트 구조만 바꿔서 불필요한 리렌더를 줄이는 방법을 설명해 주세요.',
 '리렌더의 원인은 대부분 상태가 너무 위에 있어서 넓은 서브트리가 함께 다시 그려지는 것이기 때문에, 메모 훅보다 컴포넌트 구조 변경이 근본적이고 비용도 없습니다. 첫째는 상태를 아래로 내리는 방법입니다. 예를 들어 Page가 입력값 query를 들고 있으면 query와 무관한 HeavyList까지 매 키 입력마다 리렌더되는데, 입력 상태를 쓰는 부분만 SearchInput이라는 별도 컴포넌트로 분리하면 HeavyList는 리렌더되지 않습니다. 둘째는 children으로 분리하는 방법입니다. 스크롤 위치 state를 가진 ScrollTracker처럼 상태를 가진 컴포넌트가 무거운 자식을 감싸야만 하는 경우, 자식을 children으로 받으면 부모가 리렌더돼도 children 엘리먼트는 바깥에서 만든 같은 참조이므로 React가 렌더를 건너뜁니다.'),
(730, 'REACT', 146, 'EASY', true,
 'React Compiler는 무엇이며, 어떤 코드에 적용되나요?',
 'React Compiler는 React 19와 함께 공개된 컴파일러로, 빌드 시점에 컴포넌트와 훅을 분석해 useMemo·useCallback·memo에 해당하는 최적화를 자동으로 삽입합니다. 다만 훅의 규칙과 렌더 순수성을 지킨 코드에만 적용되고, 규칙 위반이 감지된 컴포넌트는 건너뜁니다. 컴파일러를 쓰면 수동 메모 코드는 대부분 제거할 수 있지만, 도입 여부와 세부 동작은 프로젝트 설정·버전에 따라 다를 수 있습니다. 또 상태를 어디에 둘지와 느린 계산 자체는 컴파일러가 해결해 주지 않으므로 구조적 최적화는 여전히 개발자의 몫입니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 726
(3910, 726, 'React DevTools Profiler로 커밋별 렌더 시간(ms)을 먼저 측정하는 단계를 제시', 'ESSENTIAL', 1),
(3911, 726, 'Why did this render로 부모·props·state·context 중 렌더 원인을 식별하는 단계를 설명', 'ESSENTIAL', 2),
(3912, 726, '메모 적용 전에 상태 내리기·children 분리 중 최소 1개를 구조 개선으로 제시', 'ESSENTIAL', 3),
(3913, 726, 'memo 계열을 적용한 뒤 다시 측정해 효과를 검증하는 단계를 언급', 'ESSENTIAL', 4),
(3914, 726, '측정 없이 적용된 메모는 비용만 늘리는 부채가 됨을 언급', 'SUPPLEMENTARY', 5),
(3915, 726, '최종 판단은 프로덕션 프로파일링 빌드나 실제 배포 환경에서 해야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 727
(3916, 727, 'React.memo는 컴포넌트의 마지막 렌더 결과를 기억함을 언급', 'ESSENTIAL', 1),
(3917, 727, 'useMemo는 계산 결과 값을 기억함을 언급', 'ESSENTIAL', 2),
(3918, 727, 'useCallback은 함수 참조를 기억함을 언급', 'ESSENTIAL', 3),
(3919, 727, 'useMemo·useCallback은 그 자체로는 리렌더를 막지 않음을 설명', 'ESSENTIAL', 4),
(3920, 727, 'useMemo·useCallback이 memo된 자식이나 이펙트 의존성을 돕는 보조 도구임을 언급', 'SUPPLEMENTARY', 5),
(3921, 727, 'memo가 props 변경 여부를 필드별 Object.is로 판단함을 언급', 'SUPPLEMENTARY', 6),
(3922, 727, 'state·context 변경 중 최소 1개로 인한 리렌더는 memo가 막지 못함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 728
(3923, 728, '인라인 객체·배열·함수 props는 매번 새 참조라 memo가 무력화됨을 설명', 'ESSENTIAL', 1),
(3924, 728, '렌더나 계산이 싼 경우 메모 오버헤드가 얻는 이득보다 크다는 점을 설명', 'ESSENTIAL', 2),
(3925, 728, 'useCallback은 받는 자식이 memo이거나 이펙트 의존성일 때만 의미가 있음을 설명', 'ESSENTIAL', 3),
(3926, 728, '부모가 자주 리렌더됨·자식 렌더가 비쌈·props가 대체로 같음 중 최소 2개를 memo 효과 조건으로 제시', 'ESSENTIAL', 4),
(3927, 728, '의존성 배열을 잘못 적으면 낡은 값을 보여주는 정확성 버그가 생김을 언급', 'SUPPLEMENTARY', 5),
(3928, 728, '수만 개 항목 정렬·필터 같은 눈에 띄게 비싼 계산에 useMemo가 효과적임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 729
(3929, 729, '상태를 쓰는 부분만 별도 컴포넌트로 분리해 상태를 아래로 내리는 방법을 설명', 'ESSENTIAL', 1),
(3930, 729, '무거운 자식을 children으로 받으면 부모가 리렌더돼도 같은 참조라 렌더가 생략됨을 설명', 'ESSENTIAL', 2),
(3931, 729, '리렌더 원인이 대부분 상태가 너무 위에 있어서 넓은 서브트리가 함께 그려지는 것임을 언급', 'SUPPLEMENTARY', 3),
(3932, 729, '구조 변경은 메모 훅과 달리 추가 비용이 없다는 점을 언급', 'SUPPLEMENTARY', 4),
(3933, 729, '컴포넌트 구조 변경이 메모 훅보다 근본적인 해결책임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 730
(3934, 730, 'React Compiler가 빌드 시점에 useMemo·useCallback·memo에 해당하는 최적화를 자동 삽입함을 설명', 'ESSENTIAL', 1),
(3935, 730, '훅의 규칙·렌더 순수성 중 최소 1개를 컴파일러 적용 조건으로 제시', 'ESSENTIAL', 2),
(3936, 730, '규칙 위반이 감지된 컴포넌트는 컴파일러가 건너뜀을 언급', 'SUPPLEMENTARY', 3),
(3937, 730, '상태를 어디에 둘지·느린 계산 자체 중 최소 1개를 컴파일러가 해결하지 못하는 영역으로 제시', 'SUPPLEMENTARY', 4),
(3938, 730, '컴파일러 도입 시 수동 메모 코드를 대부분 제거할 수 있음을 언급', 'SUPPLEMENTARY', 5);
