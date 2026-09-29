-- Unit: 에러 경계와 예외 처리 (Unit ID: 149)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(741, 'REACT', 149, 'HARD', true,
 '루트에 에러 경계를 두었는데도 주문 저장 버튼을 눌러 API 요청이 실패하면 사용자에게 아무 피드백이 없습니다. 원인이 무엇이고, 에러 종류에 따라 어떻게 처리해야 할까요?',
 '에러 경계는 React가 컴포넌트를 실행하는 동안, 즉 렌더와 생명주기·이펙트에서 던져진 에러만 잡습니다. 이벤트 핸들러와 setTimeout, Promise.then, fetch 같은 비동기 콜백의 에러는 에러 경계가 잡지 못합니다. 이벤트 핸들러는 React 렌더 스택 밖에서 브라우저가 호출하고, 비동기 콜백은 렌더가 끝난 뒤 별도 태스크에서 실행되기 때문입니다. 그래서 버튼 클릭 후 요청 실패는 루트 경계가 전혀 보지 못해 피드백이 없었던 것입니다. 이벤트 핸들러 에러는 렌더에 영향이 없으므로 핸들러 안에서 직접 try/catch로 처리합니다. catch 블록에서는 토스트나 인라인 메시지로 사용자에게 피드백하고 에러를 리포트하며, UI는 그대로 유지합니다. 반면 비동기 에러가 이 화면을 더 이상 보여줄 수 없는 수준이라면, 에러를 상태에 담아 두고 렌더 중에 throw해 가장 가까운 에러 경계가 fallback으로 화면을 교체하게 합니다. TanStack Query의 throwOnError 옵션이나 React 19의 use도 같은 원리로 에러를 경계에 넘깁니다. 판단 기준은 이 에러가 났을 때 현재 화면을 계속 보여줘도 되는가이며, 그래도 빠져나간 에러는 window의 error와 unhandledrejection 리스너로 로깅 목적의 전역 안전망을 둡니다. 다만 이 안전망은 UI 복구는 하지 못합니다.',
 'interview-question/741.mp3'),
(742, 'REACT', 149, 'NORMAL', true,
 '에러 경계를 앱 루트에 하나만 두는 것과 페이지·위젯 단위로 나누어 두는 것은 어떤 차이가 있나요?',
 '에러가 발생하면 에러 경계 아래 트리 전체가 언마운트되고 fallback으로 교체되며, 경계 위의 트리는 영향받지 않습니다. 그래서 경계를 어디에 두느냐가 에러 시 사라지는 화면 범위를 결정합니다. 루트에 둔 경계는 빈 화면을 막고 ''문제가 발생했습니다 + 새로고침'' 같은 전역 fallback을 보여주는 최후 방어선이지만, 경계를 루트에만 두면 에러 하나에 앱 화면 전체가 fallback으로 바뀝니다. 반면 페이지·위젯 단위로 경계를 나누면 오류가 난 영역만 fallback으로 교체되고 나머지 화면은 유지됩니다. 예를 들어 라우트·페이지 단위로 두면 한 페이지 오류가 나도 내비게이션과 헤더는 살아 있고, 위젯·카드 단위로 두면 차트 하나가 죽어도 나머지 대시보드는 정상 동작합니다. 그래서 보통 루트와 페이지·위젯 단위를 여러 층으로 중첩하며, 안쪽 경계가 잡으면 바깥은 관여하지 않고 안쪽이 없으면 바깥으로 전파됩니다. 다만 너무 세밀하게 두면 fallback이 화면 곳곳에 흩어져 오히려 혼란스러우므로 피합니다. 같은 단위로 로딩 중과 실패를 표현하도록 Suspense 경계와 짝으로 배치하는 것이 자연스럽습니다.',
 'interview-question/742.mp3'),
(743, 'REACT', 149, 'NORMAL', true,
 '에러 경계를 구현할 때 쓰는 getDerivedStateFromError와 componentDidCatch는 각각 어떤 역할을 하며 어떻게 다른가요?',
 'getDerivedStateFromError는 렌더 단계에서 호출되어 hasError 같은 상태를 true로 바꾸고, 다음 렌더에서 children 대신 fallback UI를 그리도록 하는 역할입니다. componentDidCatch는 커밋 단계에서 호출되며 에러 객체와 componentStack 정보를 받아 에러 리포팅 같은 로깅 등 부수효과를 처리합니다. 즉 getDerivedStateFromError는 렌더 단계에서 화면 전환을 위한 상태 변경을, componentDidCatch는 커밋 단계에서 부수효과를 담당한다는 점이 다릅니다. 두 메서드는 클래스 컴포넌트에만 존재하고 훅 버전이 없기 때문에 에러 경계는 React 19에서도 클래스로 작성해야 하며, 그렇지 않으면 react-error-boundary 같은 라이브러리를 사용합니다.',
 'interview-question/743.mp3'),
(744, 'REACT', 149, 'EASY', true,
 '에러 경계가 없을 때 컴포넌트 렌더 중 예외가 발생하면 React는 어떻게 동작하며, 에러 경계란 무엇인가요?',
 '컴포넌트 렌더 중 던져진 예외가 처리되지 않으면 React는 루트 트리 전체를 언마운트해 빈 화면을 남깁니다. 콘솔에 에러가 출력될 뿐 사용자는 새로고침 외에 복구 수단이 없습니다. 이는 부분 손상된 UI를 남기는 것보다 아예 지우는 것이 낫다는 판단으로 React 16부터 기본 동작이 되었습니다. 에러 경계는 이를 막는 장치로, 하위 트리에서 발생한 렌더 에러를 잡아 fallback UI를 대신 보여주는 컴포넌트입니다. try/catch의 컴포넌트 버전이라고 볼 수 있습니다. 그래서 프로덕션 앱에서는 루트 근처에 최소한 하나의 에러 경계를 두어야 합니다.',
 'interview-question/744.mp3'),
(745, 'REACT', 149, 'EASY', true,
 '에러 경계의 fallback 화면에서 사용자가 다시 시도할 수 있도록 복구를 구현하는 방법을 설명해 주세요.',
 'fallback만 보여주고 끝나면 사용자는 새로고침밖에 할 수 없으므로 복구 경로를 함께 설계합니다. 첫 번째 방법은 에러 경계에 key를 주고 ''다시 시도'' 버튼에서 그 key 값을 바꾸는 것입니다. key가 바뀌면 경계가 리마운트되면서 내부 상태가 초기화되어 하위 트리를 다시 렌더합니다. 두 번째 방법은 react-error-boundary 라이브러리를 사용하는 것으로, FallbackComponent가 받는 resetErrorBoundary를 버튼에 연결하거나, resetKeys에 userId 같은 값을 넣어 그 값이 바뀌면 자동으로 복구되게 할 수 있습니다. 라우트 이동 시 자동 복구되도록 resetKeys에 경로를 넣는 패턴도 흔합니다. 이때 onReset에서 queryClient.invalidateQueries를 호출하는 식으로 에러 원인이 된 데이터도 함께 무효화해야 같은 에러가 반복되지 않습니다.',
 'interview-question/745.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 741
(3992, 741, '이벤트 핸들러·비동기 콜백 중 최소 1개를 에러 경계가 잡지 못하는 위치로 언급', 'ESSENTIAL', 1),
(3993, 741, '이벤트 핸들러는 React 렌더 스택 밖에서 브라우저가 호출하기 때문에 잡히지 않음을 설명', 'ESSENTIAL', 2),
(3994, 741, '이벤트 핸들러 에러는 핸들러 안에서 직접 try/catch로 처리함을 설명', 'ESSENTIAL', 3),
(3995, 741, '화면을 보여줄 수 없는 비동기 에러는 상태에 담아 렌더 중 throw해 에러 경계로 넘김을 설명', 'ESSENTIAL', 4),
(3996, 741, 'catch에서 토스트·인라인 메시지 중 최소 1개로 사용자에게 피드백함을 언급', 'SUPPLEMENTARY', 5),
(3997, 741, '현재 화면을 계속 보여줘도 되는가를 try/catch와 에러 경계 선택의 판단 기준으로 제시', 'SUPPLEMENTARY', 6),
(3998, 741, 'TanStack Query의 throwOnError로 쿼리 실패를 에러 경계에 위임할 수 있음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 742
(3999, 742, '루트 에러 경계는 빈 화면을 막는 최후 방어선 역할을 함을 언급', 'ESSENTIAL', 1),
(4000, 742, '경계를 루트에만 두면 에러 하나에 앱 화면 전체가 fallback으로 바뀜을 언급', 'ESSENTIAL', 2),
(4001, 742, '페이지·위젯 단위로 경계를 나누면 오류가 난 영역만 fallback으로 교체되고 나머지 화면은 유지됨을 설명', 'ESSENTIAL', 3),
(4002, 742, '중첩된 경계에서는 안쪽 경계가 에러를 잡으면 바깥 경계는 관여하지 않음을 설명', 'SUPPLEMENTARY', 4),
(4003, 742, '경계를 너무 세밀하게 두면 fallback이 화면 곳곳에 흩어져 혼란스러움을 언급', 'SUPPLEMENTARY', 5),
(4004, 742, '에러 경계를 Suspense 경계와 같은 단위로 짝지어 배치함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 743
(4005, 743, 'getDerivedStateFromError는 다음 렌더에서 fallback을 그리도록 상태를 변경하는 역할임을 설명', 'ESSENTIAL', 1),
(4006, 743, 'componentDidCatch는 에러 로깅 같은 부수효과를 처리하는 역할임을 설명', 'ESSENTIAL', 2),
(4007, 743, 'getDerivedStateFromError는 렌더 단계, componentDidCatch는 커밋 단계에서 동작함을 구분', 'ESSENTIAL', 3),
(4008, 743, '두 메서드는 클래스 컴포넌트에만 있어 에러 경계는 훅으로 작성할 수 없음을 언급', 'SUPPLEMENTARY', 4),
(4009, 743, 'react-error-boundary 같은 라이브러리를 클래스 작성의 대안으로 언급', 'SUPPLEMENTARY', 5),

-- 질문 744
(4010, 744, '처리되지 않은 렌더 에러가 발생하면 React가 루트 트리 전체를 언마운트해 빈 화면이 됨을 언급', 'ESSENTIAL', 1),
(4011, 744, '에러 경계는 하위 트리의 렌더 에러를 잡아 fallback UI를 대신 보여주는 컴포넌트임을 설명', 'ESSENTIAL', 2),
(4012, 744, '부분 손상된 UI를 남기기보다 지우는 것이 낫다는 판단을 전체 언마운트의 이유로 제시', 'SUPPLEMENTARY', 3),
(4013, 744, '에러 경계를 try/catch의 컴포넌트 버전으로 비유해 설명', 'SUPPLEMENTARY', 4),
(4014, 744, '프로덕션 앱에는 루트 근처에 최소 하나의 에러 경계가 필요함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 745
(4015, 745, '에러 경계의 key를 바꿔 리마운트해 내부 상태를 초기화하는 방법을 설명', 'ESSENTIAL', 1),
(4016, 745, 'react-error-boundary의 resetErrorBoundary나 resetKeys 중 최소 1개를 복구 수단으로 제시', 'ESSENTIAL', 2),
(4017, 745, '복구 시 에러 원인이 된 데이터도 함께 무효화해야 같은 에러가 반복되지 않음을 언급', 'SUPPLEMENTARY', 3),
(4018, 745, '라우트 이동 시 자동 복구되도록 resetKeys에 경로를 넣는 패턴을 언급', 'SUPPLEMENTARY', 4);
