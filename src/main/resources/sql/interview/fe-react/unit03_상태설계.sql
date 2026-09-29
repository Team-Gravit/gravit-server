-- Unit: 상태 설계 (Unit ID: 143)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(711, 'REACT', 143, 'HARD', true,
 '여러 패널 중 하나만 열려야 하는 아코디언을 각 패널이 자기 열림 상태를 갖도록 구현했다면 어떤 문제가 생기고, 상태의 위치와 형태를 어떻게 다시 설계해야 하나요?',
 '각 패널이 useState로 자기 열림 상태를 가지면 패널끼리 서로의 상태를 알 수 없기 때문에 ''하나만 열리기''를 구현할 수 없습니다. 한 패널의 변화가 다른 패널의 표시에 영향을 줘야 하는 상황이므로 상태를 공통 부모로 끌어올려야 합니다. 즉 Accordion 같은 부모가 열린 패널의 index(activeIndex)를 소유하고, 자식 Panel은 상태를 소유하지 않은 채 isOpen(값)과 onOpen(변경 요청)만 props로 받는 제어 컴포넌트가 됩니다. 또 패널마다 open을 따로 유지하는 대신 activeIndex 하나로 표현하면 ''동시에 두 개가 열림''이라는 불가능한 상태 자체를 표현할 수 없게 되어 구조적으로 제거됩니다.',
 'interview-question/711.mp3'),
(712, 'REACT', 143, 'NORMAL', true,
 '장바구니 합계처럼 props에서 계산할 수 있는 값을 useState와 useEffect로 동기화해 두는 방식과 렌더 중에 계산하는 방식은 어떤 차이가 있나요?',
 'items에서 계산할 수 있는 total을 useState에 따로 저장하면 원본(items)과 사본(total)이 생겨 단일 진실 공급원이 깨지는 파생 상태가 됩니다. 이를 useEffect로 동기화하면 items 변경 후 낡은 total로 한 번 렌더되고, 이펙트에서 setTotal이 호출돼 다시 렌더되므로 렌더가 2회 돌고 그 사이 잠깐 불일치한 값이 화면에 노출됩니다. 반면 렌더 중에 items.reduce로 바로 계산하면 동기화 코드 없이 항상 items와 일치하며 렌더도 1회로 끝납니다. 계산 비용이 눈에 띄게 크다면 상태로 승격시키는 것이 아니라 useMemo로 감쌉니다. 참고로 props를 useState 초기값으로 복사하는 것도 파생 상태인데, 초기값은 마운트 시 한 번만 반영되므로 이후 props 변경이 무시됩니다.',
 'interview-question/712.mp3'),
(713, 'REACT', 143, 'NORMAL', true,
 '비동기 요청의 진행 상황을 isLoading, isError 같은 boolean 여러 개로 관리하는 방식과 status 유니온 하나로 관리하는 방식은 어떤 차이가 있나요?',
 'isLoading, isError, isSuccess 같은 boolean을 따로 두면 isLoading과 isError가 동시에 참인 것처럼 실제로는 불가능한 조합도 표현할 수 있어 모순된 상태가 생길 수 있습니다. 대신 status를 "idle" | "loading" | "error" | "success" 중 하나만 갖는 문자열 유니온 하나로 표현하면 한 시점에 하나의 상태만 가능하므로 모순이 사라집니다. 더 나아가 판별 유니온 타입으로 error 상태에만 error를, success 상태에만 data를 두면 가능한 상태만 남기고 불가능한 상태는 표현할 수 없게 설계할 수 있습니다. 여러 상태가 같은 이벤트에 의해 함께 전이된다면 액션별 상태 변화를 한 함수에 모으는 useReducer가 적합합니다.',
 'interview-question/713.mp3'),
(714, 'REACT', 143, 'EASY', true,
 'React에서 상태를 어느 컴포넌트에 두어야 하는지, 위치를 정하는 원칙을 설명해 주세요.',
 '상태는 그 상태를 읽거나 쓰는 모든 컴포넌트의 가장 가까운 공통 조상에 둡니다. 예를 들어 검색어를 SearchBar와 ResultList가 함께 쓴다면 둘의 공통 조상인 Main에 두고 App까지 올릴 필요는 없습니다. 더 위로 올리면 관계없는 컴포넌트까지 리렌더되고, 더 아래에 두면 형제가 공유할 수 없습니다. 기본값은 지역 상태로, 입력 중인 값이나 툴팁 열림 여부처럼 한 컴포넌트만 쓰는 상태는 그 컴포넌트 안에 둡니다. ''나중에 공유할지도 몰라서'' 미리 올리지 않고, 필요해질 때 올립니다. 미리 올린 상태는 불필요한 리렌더와 결합도를 만들기 때문입니다.',
 'interview-question/714.mp3'),
(715, 'REACT', 143, 'EASY', true,
 'React에서 상태란 무엇이며, 어떤 값은 상태로 두지 말아야 하는지 설명해 주세요.',
 '상태는 시간에 따라 바뀌며, 바뀌면 화면이 달라져야 하는 값입니다. 입력값, 열림 여부, 선택된 탭 같은 것이 상태입니다. 반대로 설정 상수처럼 시간이 지나도 변하지 않는 값은 props나 상수로 두고, 부모에게서 props로 받는 값은 복사하지 않고 그대로 사용하며, total이나 filteredList처럼 다른 상태·props로 계산할 수 있는 값은 렌더 중에 계산합니다. 타이머 id나 이전 스크롤 위치처럼 바뀌어도 화면이 그대로인 값은 useRef로 둡니다. 상태가 하나 늘 때마다 동기화해야 할 값도 함께 늘고 동기화가 어긋나는 순간이 버그가 되므로 최소한의 상태가 원칙입니다.',
 'interview-question/715.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 711
(3833, 711, '각 패널이 자기 열림 상태를 가지면 ''하나만 열리기''를 구현할 수 없음을 언급', 'ESSENTIAL', 1),
(3834, 711, '열린 패널의 index를 공통 부모가 소유하도록 상태를 끌어올린다고 설명', 'ESSENTIAL', 2),
(3835, 711, 'activeIndex 하나로 표현해 동시에 두 개가 열리는 불가능한 상태를 제거함을 설명', 'ESSENTIAL', 3),
(3836, 711, '자식 패널이 상태를 소유하지 않고 열림 값과 변경 요청만 props로 받는 제어 컴포넌트가 됨을 설명', 'SUPPLEMENTARY', 4),
(3837, 711, '한 컴포넌트의 변화가 다른 컴포넌트 표시에 영향을 주는 것이 끌어올리기 신호임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 712
(3838, 712, '이펙트로 동기화하면 원본과 사본이 잠시 불일치해 낡은 값이 화면에 노출됨을 설명', 'ESSENTIAL', 1),
(3839, 712, '계산 가능한 값을 상태로 두면 원본과 사본이 생겨 단일 진실 공급원이 깨짐을 언급', 'ESSENTIAL', 2),
(3840, 712, '렌더 중 계산하면 이펙트 동기화와 달리 렌더가 1회로 끝남을 설명', 'ESSENTIAL', 3),
(3841, 712, '계산 비용이 크면 상태로 승격하지 않고 useMemo로 감싼다고 언급', 'SUPPLEMENTARY', 4),
(3842, 712, 'props를 useState 초기값으로 복사하면 이후 props 변경이 무시됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 713
(3843, 713, 'boolean 여러 개로는 isLoading과 isError가 동시에 참인 불가능한 조합이 표현됨을 언급', 'ESSENTIAL', 1),
(3844, 713, 'idle·loading·error·success 중 하나만 갖는 status 유니온으로 모순을 없앤다고 설명', 'ESSENTIAL', 2),
(3845, 713, '판별 유니온으로 error는 error 상태에만, data는 success 상태에만 둔다고 설명', 'SUPPLEMENTARY', 3),
(3846, 713, '여러 상태가 같은 이벤트로 함께 전이되면 useReducer가 적합하다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 714
(3847, 714, '상태를 읽거나 쓰는 모든 컴포넌트의 가장 가까운 공통 조상에 둔다고 설명', 'ESSENTIAL', 1),
(3848, 714, '한 컴포넌트만 쓰는 상태는 그 컴포넌트 안의 지역 상태로 둔다고 언급', 'ESSENTIAL', 2),
(3849, 714, '공통 조상보다 더 위로 올리면 관계없는 컴포넌트까지 리렌더됨을 언급', 'SUPPLEMENTARY', 3),
(3850, 714, '''나중에 공유할지도 몰라서'' 상태를 미리 올리지 않는다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 715
(3851, 715, '상태가 시간에 따라 바뀌며 바뀌면 화면이 달라져야 하는 값임을 설명', 'ESSENTIAL', 1),
(3852, 715, '변하지 않는 값·props로 받는 값·계산 가능한 값·화면과 무관한 값 중 최소 2개를 상태가 아닌 예로 제시', 'ESSENTIAL', 2),
(3853, 715, '바뀌어도 화면이 그대로인 값은 useRef로 둔다고 언급', 'SUPPLEMENTARY', 3),
(3854, 715, '상태가 늘수록 동기화할 값이 늘어나므로 최소한의 상태가 원칙임을 언급', 'SUPPLEMENTARY', 4);
