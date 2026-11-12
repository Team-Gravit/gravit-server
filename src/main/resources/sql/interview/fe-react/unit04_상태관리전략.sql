-- Unit: 상태 관리 전략 (Unit ID: 144)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(716, 'REACT', 144, 'HARD', true,
 'user·theme·cart를 하나의 Context에 모두 넣어 관리하는 앱에서 장바구니를 갱신할 때마다 화면 전체가 느려지는 문제가 생겼습니다. 원인은 무엇이고 어떻게 단계적으로 개선하며, 그 선택의 대가는 무엇인지 설명해 주세요.',
 '원인은 Context가 선택적 구독(selector)을 지원하지 않는다는 점입니다. useContext는 Context 전체를 구독하기 때문에 { user, theme, cart }를 하나의 Context에 넣으면 cart만 바뀌어도 theme만 쓰는 Header, user만 쓰는 Sidebar까지 모든 소비자가 리렌더됩니다. 중간 컴포넌트를 React.memo로 감싸도 Context는 props가 아니므로 소비자의 리렌더는 막히지 않습니다. 개선은 단계적으로 합니다. 먼저 Provider의 value를 useMemo로 고정해 렌더마다 새 객체가 만들어지는 것을 막고, 자주 바뀌는 값과 거의 안 바뀌는 값을 별도 Context로 분리합니다. 그래도 cart처럼 자주 바뀌고 여러 곳에서 부분 구독이 필요한 상태라면 Zustand 같은 외부 스토어로 옮겨, 각 컴포넌트가 selector로 필요한 조각만 구독하게 합니다. 그러면 선택한 값이 바뀐 컴포넌트만 리렌더됩니다. 이런 라이브러리는 내부적으로 useSyncExternalStore를 사용해 동시성 렌더링 중에도 찢어짐(tearing) 없이 외부 값을 읽습니다. 대가로는 Context와 달리 추가 의존성이 생긴다는 점이 있습니다. 반면 트리 밖 접근이나 DevTools·미들웨어 지원 같은 이점을 얻습니다.',
 'interview-question/716.mp3'),
(717, 'REACT', 144, 'NORMAL', true,
 'Context와 Zustand·Redux 같은 외부 스토어는 어떤 차이가 있고, 각각 어떤 상태에 적합한지 설명해 주세요.',
 '가장 큰 차이는 구독 단위와 리렌더 범위입니다. Context는 Context 전체를 구독하므로 value가 바뀌면 그 Context를 구독하는 모든 소비자가 리렌더됩니다. 반면 외부 스토어는 상태를 React 트리 밖에 두고 각 컴포넌트가 selector로 필요한 조각만 골라 구독하므로, 선택한 값이 바뀐 소비자만 리렌더됩니다. 또 Context는 컴포넌트 안에서만 읽을 수 있지만 외부 스토어는 이벤트 핸들러나 유틸 함수처럼 트리 밖에서도 접근할 수 있고, 대부분 로깅·영속화·타임트래블 같은 DevTools·미들웨어를 지원합니다. 대신 외부 스토어는 추가 의존성이 생깁니다. 본질적으로 Context는 어떤 값을 아래로 전달하는 의존성 주입 통로이고, 스토어는 자주 갱신되는 데이터를 관리하는 상태 저장소입니다. 그래서 테마·로케일·로그인 사용자처럼 드물게 바뀌는 값은 Context에, 장바구니처럼 자주 바뀌고 부분 구독이 필요한 상태는 외부 스토어에 두는 것이 적합합니다.',
 'interview-question/717.mp3'),
(718, 'REACT', 144, 'NORMAL', true,
 '서버 상태와 클라이언트 상태는 어떻게 다르며, 서버 상태를 별도로 관리해야 하는 이유는 무엇인가요?',
 '클라이언트 상태는 클라이언트가 소유하고 동기적이며 항상 최신입니다. 반면 서버 상태는 원본이 서버에 있고 클라이언트는 그 사본, 즉 로컬 캐시만 가집니다. 서버 상태는 비동기이므로 로딩·에러·재시도 처리가 필요하고, 다른 사용자나 탭이 바꿀 수 있어 시간이 지나면 낡음(stale) 상태가 되므로 재검증이 필요합니다. 그래서 캐시, 중복 요청 제거, 백그라운드 갱신, 낙관적 업데이트 같은 기능이 요구됩니다. 이런 서버 데이터를 Redux 같은 전역 스토어에 복사해 두면 캐시 무효화·재검증 로직을 직접 구현해야 하고 그 코드가 스토어의 대부분을 차지하게 됩니다. 따라서 TanStack Query나 SWR 같은 서버 상태 라이브러리에 위임하는 것이 좋습니다. 서버 상태를 분리하고 나면 남는 클라이언트 전역 상태는 생각보다 적어서 Context나 작은 스토어로 충분한 경우가 많습니다.',
 'interview-question/718.mp3'),
(719, 'REACT', 144, 'EASY', true,
 'React의 Context란 무엇이고, 값이 바뀌었을 때 어떻게 동작하는지 설명해 주세요.',
 'Context는 트리의 상위에서 Provider로 값을 제공하면 깊이에 상관없이 하위 컴포넌트가 useContext로 그 값을 읽을 수 있게 하는 의존성 주입 통로입니다. 그래서 중간 컴포넌트가 자신은 쓰지 않는 props를 아래로 전달만 하는 props drilling 없이 테마나 로그인 사용자 같은 값을 전달할 수 있습니다. Provider의 value가 바뀌면 그 Context를 구독하는 모든 하위 컴포넌트가 리렌더됩니다. 이때 value가 바뀌었는지는 Object.is 기준으로 이전 값과 다른지로 판단합니다. 참고로 React 19부터는 <Context.Provider> 대신 <Context>를 직접 Provider로 쓸 수 있고, useContext 대신 조건부 호출이 가능한 use(Ctx)로도 읽을 수 있습니다.',
 'interview-question/719.mp3'),
(720, 'REACT', 144, 'EASY', true,
 '상태 관리 도구를 고르기 전에 상태를 종류별로 분류하라고 하는데, 상태에는 어떤 종류가 있고 각각 어떤 도구가 적합한가요?',
 '종류가 다르면 적합한 도구도 다르기 때문에 도구를 고르기 전에 상태를 먼저 분류해야 합니다. 첫째, 입력값·모달 열림처럼 한두 컴포넌트만 쓰는 지역 UI 상태는 useState나 useReducer로 충분합니다. 둘째, 테마·언어처럼 자주 안 바뀌고 트리 곳곳에서 읽는 전역 UI 상태는 Context가 적합합니다. 셋째, 장바구니·다단계 폼처럼 자주 바뀌고 여러 곳에서 쓰며 갱신 로직이 복잡한 클라이언트 도메인 상태는 Zustand·Redux·Jotai 같은 외부 스토어가 적합합니다. 넷째, 사용자 목록처럼 원본이 서버에 있어 캐시·재검증이 필요한 서버 상태는 TanStack Query·SWR 같은 서버 상태 라이브러리를 씁니다. 다섯째, 검색어·페이지 번호·필터처럼 새로고침·공유·뒤로가기에 살아남아야 하는 URL 상태는 라우터의 쿼리스트링에 둡니다.',
 'interview-question/720.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 716
(3855, 716, 'useContext가 선택적 구독을 지원하지 않아 cart만 바뀌어도 theme·user만 쓰는 소비자까지 리렌더된다고 설명', 'ESSENTIAL', 1),
(3856, 716, 'value를 useMemo로 고정하거나 변경 빈도별로 Context를 분리하는 방법 중 최소 1개를 개선책으로 제시', 'ESSENTIAL', 2),
(3857, 716, '자주 바뀌는 cart를 selector로 필요한 조각만 구독하는 외부 스토어로 옮기는 방안을 제시', 'ESSENTIAL', 3),
(3858, 716, '외부 스토어를 도입하면 추가 의존성이 생긴다는 대가를 언급', 'ESSENTIAL', 4),
(3859, 716, '중간 컴포넌트를 React.memo로 감싸도 Context 소비자의 리렌더는 막히지 않음을 언급', 'SUPPLEMENTARY', 5),
(3860, 716, '외부 스토어가 useSyncExternalStore로 찢어짐(tearing) 없이 외부 값을 읽는다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 717
(3861, 717, 'Context는 Context 전체를, 외부 스토어는 selector로 고른 조각을 구독한다는 구독 단위 차이를 설명', 'ESSENTIAL', 1),
(3862, 717, 'Context는 모든 소비자가, 외부 스토어는 선택값이 바뀐 소비자만 리렌더된다는 차이를 설명', 'ESSENTIAL', 2),
(3863, 717, 'Context는 드물게 바뀌는 값, 외부 스토어는 자주 바뀌는 상태에 적합하다는 점을 설명', 'ESSENTIAL', 3),
(3864, 717, '외부 스토어는 이벤트 핸들러·유틸 함수 등 트리 밖에서도 접근 가능함을 언급', 'SUPPLEMENTARY', 4),
(3865, 717, 'Context의 본질은 의존성 주입이고 스토어는 상태 저장소라고 언급', 'SUPPLEMENTARY', 5),
(3866, 717, '외부 스토어는 대부분 DevTools·미들웨어(로깅, 영속화, 타임트래블)를 지원함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 718
(3867, 718, '서버 상태는 원본이 서버에 있고 클라이언트는 그 사본(로컬 캐시)만 가진다고 설명', 'ESSENTIAL', 1),
(3868, 718, '서버 상태는 비동기라서 로딩·에러·재시도 처리가 필요함을 언급', 'ESSENTIAL', 2),
(3869, 718, '서버 상태는 시간이 지나면 낡아(stale) 재검증이 필요함을 언급', 'ESSENTIAL', 3),
(3870, 718, '서버 상태를 전역 스토어에 복사하면 캐시 무효화·재검증 로직을 직접 구현해야 함을 언급', 'SUPPLEMENTARY', 4),
(3871, 718, 'TanStack Query·SWR 같은 서버 상태 라이브러리에 위임하는 방법을 제시', 'SUPPLEMENTARY', 5),
(3872, 718, '서버 상태를 분리하면 남는 클라이언트 전역 상태가 적어 Context나 작은 스토어로 충분할 수 있다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 719
(3873, 719, '상위의 Provider가 값을 제공하면 깊이에 상관없이 하위에서 useContext로 읽을 수 있다고 설명', 'ESSENTIAL', 1),
(3874, 719, 'Provider의 value가 바뀌면 그 Context를 구독하는 모든 하위 컴포넌트가 리렌더된다고 설명', 'ESSENTIAL', 2),
(3875, 719, 'Context가 중간 컴포넌트를 거치는 props drilling 없이 값을 전달하는 통로임을 언급', 'SUPPLEMENTARY', 3),
(3876, 719, 'value 변경 여부가 Object.is 기준으로 판단된다고 언급', 'SUPPLEMENTARY', 4),
(3877, 719, 'React 19부터 Context 자체를 Provider로 쓰거나 use(Ctx)로 읽을 수 있다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 720
(3878, 720, '지역 UI·전역 UI·클라이언트 도메인·서버·URL 상태 중 최소 3개를 상태 종류로 제시', 'ESSENTIAL', 1),
(3879, 720, '지역 UI→useState·전역 UI→Context·도메인→외부 스토어·서버→서버 상태 라이브러리·URL→쿼리스트링 중 최소 2쌍을 제시', 'ESSENTIAL', 2),
(3880, 720, 'URL 상태는 새로고침·공유·뒤로가기에 살아남아야 해서 쿼리스트링에 둔다고 언급', 'SUPPLEMENTARY', 3),
(3881, 720, '종류가 다르면 적합한 도구도 다르므로 도구보다 상태 분류가 먼저라고 언급', 'SUPPLEMENTARY', 4);
