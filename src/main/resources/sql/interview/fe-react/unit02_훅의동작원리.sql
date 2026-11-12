-- Unit: 훅의 동작 원리 (Unit ID: 142)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(706, 'REACT', 142, 'HARD', true,
 'useEffect 안에서 setInterval로 매초 setCount(count + 1)을 호출하고 의존성 배열을 비워 두었더니 화면이 1에서 멈췄습니다. 원인은 무엇이고, 어떤 해결책들이 있으며 각각 어떤 대가나 적합한 상황이 있는지 설명해 주세요.',
 '원인은 stale closure입니다. 렌더는 스냅샷이라 그 렌더에서 만들어진 타이머 콜백은 그 렌더 시점의 count 값을 클로저로 붙잡습니다. 의존성 배열을 비웠기 때문에 이펙트가 마운트 시 한 번만 실행되고 클로저가 갱신되지 않아, 인터벌 콜백은 첫 렌더의 count인 0만 계속 보고 항상 0 + 1을 설정하므로 화면이 1에서 멈춥니다. 가장 먼저 시도할 해결책은 함수형 업데이트입니다. setCount(c => c + 1)처럼 쓰면 콜백이 count를 직접 읽지 않고 최신 상태를 React에게서 받으므로 의존성을 비워 둔 채로도 올바르게 증가합니다. 값 자체가 필요하다면 count를 의존성 배열에 넣는 정직한 방법이 있는데, 이 경우 값이 바뀔 때마다 이펙트가 클린업되고 다시 구성되므로 재구성 비용이 따릅니다. 웹소켓처럼 재구성 비용이 크고 콜백만 최신이면 될 때는 ref.current를 렌더마다 갱신해 최신 값을 보관하거나, React 19.2에서 정식 제공된 useEffectEvent로 이펙트 안에서 최신 값을 읽되 의존성에서는 뺄 수 있습니다. 반면 eslint-disable로 exhaustive-deps 경고를 끄는 것은 거의 항상 버그를 숨기는 행위이므로 피해야 합니다.',
 'interview-question/706.mp3'),
(707, 'REACT', 142, 'NORMAL', true,
 'count가 0인 상태에서 이벤트 핸들러가 setCount(count + 1)을 두 번 연달아 호출할 때와 setCount(c => c + 1)을 두 번 호출할 때 결과가 어떻게 다르고, 왜 그런 차이가 생기는지 설명해 주세요.',
 'setCount(count + 1)을 두 번 호출하면 결과는 2가 아니라 1입니다. 컴포넌트 함수가 실행될 때 useState가 돌려준 값은 그 렌더 시점의 값으로 고정되기 때문에, 렌더 안에서 count는 변수가 아니라 상수처럼 동작하고 절대 바뀌지 않습니다. 따라서 두 호출 모두 같은 렌더의 count인 0을 읽어 0 + 1을 두 번 넣게 되고 결과는 1이 됩니다. 반면 setCount(c => c + 1)을 두 번 호출하면 결과는 2가 됩니다. useState의 setter는 큐에 갱신을 넣기만 하고, 실제 값 계산은 다음 렌더에서 큐를 순서대로 소비하며 이루어지므로 함수형 업데이트는 앞선 갱신 결과를 이전 상태로 받아 차례로 적용되기 때문입니다. 이렇게 계산된 새 count 값으로 다음 렌더가 실행되고, 그 렌더는 새 count를 가진 새 클로저를 만들어 냅니다.',
 'interview-question/707.mp3'),
(708, 'REACT', 142, 'NORMAL', true,
 'useState와 useRef는 둘 다 렌더 사이에 값을 유지하는데, 두 훅은 어떤 점에서 다르고 각각 어떤 값을 담는 데 쓰는지 설명해 주세요.',
 '가장 큰 차이는 렌더 트리거 여부입니다. useState는 값이 변경되면 렌더를 트리거하지만, useRef는 값을 바꿔도 렌더를 트리거하지 않습니다. 그래서 화면에 반영되는 상태는 useState에 두고, 렌더와 무관한 값이나 DOM 참조는 useRef에 둡니다. 저장하는 것도 다른데, useState는 값과 업데이트 큐를 저장하고, useRef는 { current } 객체를 저장하며 그 객체 자체가 렌더 간 동일함이 보장됩니다. 참고로 ref 객체와 useState의 setter는 렌더 간 동일함이 보장되므로 이펙트의 의존성 배열에 넣지 않아도 됩니다.',
 'interview-question/708.mp3'),
(709, 'REACT', 142, 'EASY', true,
 '함수 컴포넌트는 매 렌더마다 처음부터 다시 실행되는데, useState는 어떻게 이전 값을 기억할 수 있나요?',
 '함수 컴포넌트는 매 렌더마다 처음부터 다시 실행되지만, useState의 값은 함수 안의 지역 변수가 아니라 컴포넌트 인스턴스당 하나인 Fiber 노드에 저장되기 때문에 이전 값을 기억할 수 있습니다. 구체적으로 훅들은 Fiber 노드의 memoizedState에 연결 리스트로 이어져 저장되고, 마운트 시에는 셀을 만들고(mountState) 이후 렌더에서는 같은 순서로 셀을 꺼내 씁니다(updateState). 컴포넌트 함수 안의 지역 변수는 값을 보관하는 곳이 아니라 Fiber에 있는 값을 그 렌더 동안만 복사해 둔 스냅샷일 뿐입니다.',
 'interview-question/709.mp3'),
(710, 'REACT', 142, 'EASY', true,
 '훅을 조건문이나 반복문 안에서 호출하면 안 되고 컴포넌트 최상위에서만 호출해야 하는 이유는 무엇인가요?',
 '훅은 Fiber 노드의 연결 리스트에 저장되는데, 각 훅은 이름이나 변수명이 아니라 몇 번째로 호출됐는가로 자기 셀을 찾습니다. 조건문이나 반복문 안에서 훅을 호출하면 렌더마다 호출 순서가 달라지고, 그러면 리스트의 셀이 어긋나 예를 들어 첫 렌더에서 1번이던 훅이 다음 렌더에서 0번 셀을 읽는 식으로 값이 뒤섞입니다. 그래서 훅을 최상위에서만 호출하는 규칙은 관습이 아니라 연결 리스트 구현의 제약입니다. 조건이 필요하면 훅은 항상 호출하고 조건은 훅 내부나 반환값에서 처리하며, 이른 반환은 모든 훅 호출 뒤에 둡니다. ESLint의 react-hooks/rules-of-hooks가 훅 호출 규칙을 정적으로 검사하므로 반드시 켜 둡니다.',
 'interview-question/710.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 706
(3806, 706, '빈 의존성 배열로 이펙트가 한 번만 실행되어 콜백이 첫 렌더의 count(0)만 보는 원인을 설명', 'ESSENTIAL', 1),
(3807, 706, '함수형 업데이트 setCount(c => c + 1)로 최신 상태를 React에게서 받는 해결책을 제시', 'ESSENTIAL', 2),
(3808, 706, 'count를 의존성 배열에 넣으면 값이 바뀔 때마다 이펙트를 재구성하게 됨을 언급', 'ESSENTIAL', 3),
(3809, 706, '재구성 비용이 클 때 ref 또는 useEffectEvent로 최신 값을 읽는 대안을 제시', 'SUPPLEMENTARY', 4),
(3810, 706, '이전 렌더의 값을 붙잡은 함수가 나중에 실행되는 현상을 stale closure로 언급', 'SUPPLEMENTARY', 5),
(3811, 706, 'eslint-disable로 exhaustive-deps 경고를 끄는 것은 버그를 숨기는 행위임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 707
(3812, 707, 'setCount(count + 1) 두 번은 두 호출 모두 같은 렌더의 count(0)를 읽어 결과가 1이 됨을 설명', 'ESSENTIAL', 1),
(3813, 707, 'setCount(c => c + 1)을 두 번 호출하면 결과가 2가 됨을 언급', 'ESSENTIAL', 2),
(3814, 707, 'setter는 큐에 갱신을 넣고 다음 렌더에서 큐를 순서대로 소비해 값을 계산함을 설명', 'ESSENTIAL', 3),
(3815, 707, '렌더 안에서 count는 변수가 아니라 상수처럼 고정된 값임을 언급', 'SUPPLEMENTARY', 4),
(3816, 707, '다음 렌더는 새 count 값을 가진 새 클로저를 만들어 냄을 서술', 'SUPPLEMENTARY', 5),

-- 질문 708
(3817, 708, '값 변경 시 useState는 렌더를 트리거하고 useRef는 트리거하지 않는 차이를 설명', 'ESSENTIAL', 1),
(3818, 708, '화면에 반영되는 상태는 useState, 렌더와 무관한 값·DOM 참조는 useRef로 용도를 구분', 'ESSENTIAL', 2),
(3819, 708, 'useRef는 렌더 간 동일한 { current } 객체에 값을 저장함을 언급', 'SUPPLEMENTARY', 3),
(3820, 708, 'useState가 저장하는 것은 값과 업데이트 큐임을 언급', 'SUPPLEMENTARY', 4),
(3821, 708, 'ref 객체와 setter는 렌더 간 동일해 의존성 배열에 넣지 않아도 됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 709
(3822, 709, '상태 값이 함수 지역 변수가 아니라 컴포넌트의 Fiber 노드에 저장됨을 언급', 'ESSENTIAL', 1),
(3823, 709, '컴포넌트 함수 안의 지역 변수는 그 렌더 동안만 값을 복사해 둔 스냅샷임을 설명', 'ESSENTIAL', 2),
(3824, 709, 'Fiber 노드는 컴포넌트 인스턴스당 하나씩 존재함을 언급', 'SUPPLEMENTARY', 3),
(3825, 709, '훅들이 Fiber의 memoizedState에 연결 리스트로 이어져 저장됨을 서술', 'SUPPLEMENTARY', 4),
(3826, 709, '마운트 시 셀을 만들고(mountState) 이후 렌더에서 같은 순서로 꺼내 씀(updateState)을 서술', 'SUPPLEMENTARY', 5),

-- 질문 710
(3827, 710, '훅은 이름이 아니라 몇 번째로 호출됐는가로 연결 리스트의 자기 셀을 찾음을 설명', 'ESSENTIAL', 1),
(3828, 710, '조건문·반복문 안에서 호출하면 렌더마다 호출 순서가 달라짐을 언급', 'ESSENTIAL', 2),
(3829, 710, '호출 순서가 바뀌면 리스트의 셀이 어긋나 훅의 값이 뒤섞임을 설명', 'ESSENTIAL', 3),
(3830, 710, '이른 반환은 모든 훅 호출 뒤에 두어야 함을 개선법으로 제시', 'SUPPLEMENTARY', 4),
(3831, 710, 'ESLint의 react-hooks/rules-of-hooks가 훅 호출 규칙을 정적으로 검사함을 언급', 'SUPPLEMENTARY', 5),
(3832, 710, '훅을 최상위에서만 호출하는 규칙이 관습이 아니라 연결 리스트 구현의 제약임을 명시', 'SUPPLEMENTARY', 6);
