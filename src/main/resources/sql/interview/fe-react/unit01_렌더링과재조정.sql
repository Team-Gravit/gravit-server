-- Unit: 렌더링과 재조정 (Unit ID: 141)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(701, 'REACT', 141, 'HARD', true,
 '삽입·삭제·정렬이 가능한 목록에서 배열 인덱스를 key로 사용하면 어떤 문제가 생기는지 재조정 과정과 연결해 설명하고, 어떤 key를 선택해야 하는지 말씀해 주시겠어요?',
 'key는 경고를 없애는 장치가 아니라 엘리먼트의 정체성(identity)을 React에 알려주는 유일한 수단입니다. 같은 key면 같은 엘리먼트로 취급되어 상태·DOM·ref가 유지되고 props만 갱신되며, 다른 key면 언마운트 후 새로 마운트됩니다. 재조정 시 같은 위치의 자식 목록은 key가 없거나 인덱스일 때 인덱스 순서로 짝을 맞추기 때문에, 앞에 항목을 하나 삽입하면 뒤의 모든 항목이 내용이 바뀐 것으로 판단되어 불필요한 DOM 갱신이 늘어나고 각 항목의 내부 상태가 한 칸씩 밀립니다. 삭제도 마찬가지로, 할 일 목록에서 0번을 삭제하면 1번 항목이 key=0을 물려받아 0번의 체크 상태나 입력값을 그대로 갖게 되는 식으로 상태가 엉뚱한 항목에 붙습니다. 그래서 서버에서 온 목록이나 삽입·삭제·정렬이 있는 목록에는 데이터의 안정적인 고유 id를 key로 써야 합니다. 그러면 삽입 시 새 항목 하나만 삽입되고 나머지는 이동만 하며 상태도 그대로 따라갑니다. 인덱스 key는 정적이고 순서가 절대 바뀌지 않는 목록에서만 적합하고, Math.random() 같은 값은 매 렌더마다 전부 언마운트·재마운트되어 성능과 상태가 모두 무너지므로 쓰면 안 됩니다. 참고로 key는 형제 사이에서만 고유하면 되고 전역 고유일 필요는 없습니다.',
 'interview-question/701.mp3'),
(702, 'REACT', 141, 'NORMAL', true,
 'React에서 렌더 단계와 커밋 단계는 각각 무엇을 하고, 두 단계는 어떤 차이가 있나요?',
 'React에서 렌더링은 DOM을 그리는 것이 아니라 컴포넌트 함수를 호출해 어떤 UI를 원하는지 새 엘리먼트 트리로 설명받는 과정입니다. 트리거가 발생하면 렌더 단계에서 컴포넌트 함수를 호출해 새 엘리먼트 트리를 만들고, 재조정에서 이전 Fiber 트리와 비교해 바뀐 부분만 표시한 뒤, 커밋 단계에서 표시된 변경만 실제 DOM에 반영합니다. 렌더 단계는 부수효과 없는 순수 계산이어야 합니다. 여기서 부수효과를 일으키면 동시성 렌더링에서 렌더가 중단·재시도될 때 예측 불가능한 결과가 생기기 때문입니다. 반면 커밋 단계는 동기적이고 중단되지 않으며, 그래서 렌더 결과와 실제 DOM이 항상 일관되게 유지됩니다. 커밋 이후에는 useLayoutEffect, 브라우저 페인트, useEffect 순서로 진행됩니다. 따라서 리렌더가 일어났다고 DOM이 바뀐 것은 아니며, diff 결과 바뀐 것이 없으면 DOM 조작은 0번입니다.',
 'interview-question/702.mp3'),
(703, 'REACT', 141, 'NORMAL', true,
 'React의 상태 갱신 배치(Batching)란 무엇이고, React 17 이하와 React 18 이상에서 배치 동작은 어떻게 다른가요?',
 'setter 호출은 즉시 렌더를 일으키지 않고 예약(enqueue)만 하며, React는 같은 이벤트 루프 틱 안의 여러 상태 변경을 모아 한 번만 렌더합니다. 이것이 배치입니다. 그래서 핸들러 안에서 setter를 호출한 직후 상태를 읽어도 아직 이전 값이고, 렌더는 핸들러가 끝난 뒤 한 번만 실행됩니다. React 17 이하에서는 React 이벤트 핸들러 안에서만 배치되고, setTimeout이나 Promise.then 같은 외부 콜백에서는 setter마다 렌더가 일어났습니다. React 18 이상에서 createRoot를 쓰면 자동 배치(Automatic Batching)가 적용되어 어디서 호출하든 여러 setter가 한 번의 렌더로 묶입니다. 강제로 동기 렌더가 필요하면 flushSync를 사용합니다. 또 배치 때문에 같은 틱에서 count는 갱신되지 않은 옛 값이므로, 이전 상태에 의존하는 갱신은 setCount(count + 1)이 아니라 setCount((c) => c + 1) 형태로 써야 합니다.',
 'interview-question/703.mp3'),
(704, 'REACT', 141, 'EASY', true,
 'React 컴포넌트가 리렌더되는 조건에는 어떤 것들이 있나요?',
 '리렌더 트리거는 세 가지로 정리할 수 있습니다. 첫째, 자신의 상태 변경입니다. useState나 useReducer의 setter를 호출해 값이 Object.is 기준으로 달라지면 리렌더가 예약되고, 같은 값으로 set하면 리렌더가 대부분 생략됩니다. 둘째, 부모의 리렌더입니다. 부모가 다시 렌더되면 자식은 props 변화와 무관하게 함께 리렌더됩니다. 셋째, useContext로 구독한 Context의 Provider value가 바뀌면 소비자 컴포넌트가 리렌더되며, 중간 컴포넌트가 memo여도 소비자는 리렌더됩니다. 흔한 오해와 달리 props 변경 자체는 트리거가 아니고, props는 부모가 리렌더될 때 따라 바뀌는 것이라 부모의 리렌더가 진짜 원인입니다. 자식이 React.memo로 감싸져 있을 때만 props가 얕은 비교로 같으면 리렌더를 건너뜁니다.',
 'interview-question/704.mp3'),
(705, 'REACT', 141, 'EASY', true,
 'React의 재조정(Reconciliation)에서 diff를 O(n)으로 수행할 수 있게 해 주는 두 가지 가정은 무엇인가요?',
 '두 트리를 완전히 비교하는 알고리즘은 O(n³)이라 실용적이지 않기 때문에, React는 두 가지 휴리스틱 가정을 두고 O(n)으로 diff합니다. 첫째, 타입이 다른 두 엘리먼트는 완전히 다른 트리를 만든다고 가정합니다. 그래서 div가 span으로 바뀌거나 컴포넌트 A가 B로 바뀌면 기존 서브트리 전체를 언마운트하고 새로 마운트하며, 하위 상태는 전부 사라집니다. 반대로 같은 DOM 타입이면 노드를 유지하고 바뀐 속성만 갱신하고, 같은 컴포넌트 타입이면 인스턴스(상태)를 유지한 채 새 props로 리렌더합니다. 이 첫째 가정 때문에 컴포넌트를 다른 컴포넌트 안에서 정의하면 매 렌더마다 다른 함수 객체, 즉 다른 타입이 되어 언마운트·재마운트되고 입력값 같은 상태가 사라지므로, 컴포넌트는 항상 모듈 최상위에서 정의해야 합니다. 둘째, 개발자가 key로 어떤 자식이 렌더 사이에서 동일한지 힌트를 준다고 가정합니다.',
 'interview-question/705.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 701
(3778, 701, 'key가 엘리먼트의 정체성(identity)을 React에 알려주는 수단임을 설명', 'ESSENTIAL', 1),
(3779, 701, '인덱스 key 목록에서 삽입·삭제 시 상태가 엉뚱한 항목에 붙는 문제를 설명', 'ESSENTIAL', 2),
(3780, 701, '앞에 항목을 삽입하면 인덱스 매칭 때문에 뒤의 모든 항목이 갱신되어 DOM 갱신이 늘어남을 언급', 'ESSENTIAL', 3),
(3781, 701, '데이터의 안정적인 고유 id를 key로 사용하는 해법을 제시', 'ESSENTIAL', 4),
(3782, 701, 'Math.random()을 key로 쓰면 매 렌더마다 전부 언마운트·재마운트됨을 언급', 'SUPPLEMENTARY', 5),
(3783, 701, 'key는 형제(sibling) 사이에서만 고유하면 됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 702
(3784, 702, '렌더 단계는 컴포넌트 함수를 호출해 새 엘리먼트 트리를 계산하는 단계임을 설명', 'ESSENTIAL', 1),
(3785, 702, '커밋 단계는 재조정에서 표시된 변경만 실제 DOM에 반영하는 단계임을 설명', 'ESSENTIAL', 2),
(3786, 702, '렌더 단계는 부수효과 없는 순수 계산이어야 함을 언급', 'ESSENTIAL', 3),
(3787, 702, '커밋 단계는 동기적이고 중단되지 않음을 언급', 'ESSENTIAL', 4),
(3788, 702, '리렌더가 일어나도 diff 결과 바뀐 것이 없으면 DOM 조작이 0번임을 언급', 'SUPPLEMENTARY', 5),
(3789, 702, '커밋 후 useLayoutEffect → 브라우저 페인트 → useEffect 순서로 실행됨을 서술', 'SUPPLEMENTARY', 6),

-- 질문 703
(3790, 703, 'setter 호출은 렌더를 예약만 하고 여러 상태 변경을 모아 한 번만 렌더하는 것이 배치임을 설명', 'ESSENTIAL', 1),
(3791, 703, 'React 17 이하는 React 이벤트 핸들러 안에서만 배치됨을 언급', 'ESSENTIAL', 2),
(3792, 703, 'React 18은 createRoot 사용 시 setTimeout·Promise 등 어디서 호출하든 자동 배치됨을 언급', 'ESSENTIAL', 3),
(3793, 703, '강제로 동기 렌더가 필요하면 flushSync를 사용함을 언급', 'SUPPLEMENTARY', 4),
(3794, 703, '이전 상태에 의존하는 갱신은 setCount((c) => c + 1) 같은 함수 형태로 써야 함을 설명', 'SUPPLEMENTARY', 5),

-- 질문 704
(3795, 704, 'useState·useReducer의 setter 호출로 인한 자신의 상태 변경을 트리거로 제시', 'ESSENTIAL', 1),
(3796, 704, '부모가 리렌더되면 자식도 props 변화와 무관하게 리렌더됨을 설명', 'ESSENTIAL', 2),
(3797, 704, 'useContext로 구독한 Context 값 변경을 트리거로 제시', 'ESSENTIAL', 3),
(3798, 704, 'props 변경 자체는 리렌더 트리거가 아님을 명시', 'SUPPLEMENTARY', 4),
(3799, 704, 'React.memo로 감싼 자식만 props가 같으면 리렌더를 건너뜀을 언급', 'SUPPLEMENTARY', 5),
(3800, 704, '같은 값으로 setter를 호출하면 리렌더가 대부분 생략됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 705
(3801, 705, '타입이 다른 두 엘리먼트는 완전히 다른 트리를 만든다는 가정을 설명', 'ESSENTIAL', 1),
(3802, 705, '개발자가 key로 어떤 자식이 렌더 사이에서 동일한지 힌트를 준다는 가정을 설명', 'ESSENTIAL', 2),
(3803, 705, '트리 전체를 diff하는 알고리즘은 O(n³)라 실용적이지 않음을 언급', 'SUPPLEMENTARY', 3),
(3804, 705, '같은 컴포넌트 타입이면 인스턴스(상태)를 유지하고 새 props로 리렌더함을 언급', 'SUPPLEMENTARY', 4),
(3805, 705, '같은 DOM 타입이면 노드를 유지하고 바뀐 속성만 갱신함을 언급', 'SUPPLEMENTARY', 5);
