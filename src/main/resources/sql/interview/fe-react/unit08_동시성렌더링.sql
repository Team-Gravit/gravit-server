-- Unit: 동시성 렌더링 (Unit ID: 148)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(736, 'REACT', 148, 'HARD', true,
 '검색창에 입력할 때마다 무거운 목록 필터링 때문에 타이핑이 버벅이고, 키 입력마다 API 요청도 나가는 상황입니다. React의 동시성 기능으로 무엇을 개선할 수 있고, 그 한계는 무엇인가요?',
 '타이핑이 버벅이는 것은 렌더 비용 문제이므로 transition으로 개선할 수 있습니다. 입력창 상태(query)는 긴급 갱신으로 즉시 반영하고, 무거운 필터링 결과를 설정하는 setter만 startTransition으로 감싸 전환 갱신으로 표시합니다. 그러면 목록 렌더는 쪼개서 진행되다가 새 키 입력이 오면 진행 중이던 목록 렌더를 폐기하고 입력창 갱신에 양보하므로 입력이 가로막히지 않고, 렌더가 완료될 때까지 화면은 이전 결과를 유지합니다. 결과를 계산하는 컴포넌트가 setter를 직접 호출할 수 없고 props로 값만 받는다면 useDeferredValue로 값을 지연시키는 방법을 쓸 수 있습니다. 다만 transition은 렌더 비용이 문제일 때 쓰는 것이지 네트워크 요청 횟수를 줄이는 도구가 아닙니다. 키 입력마다 API를 호출하는 문제는 디바운스나 서버 상태 라이브러리의 중복 제거로 해결해야 합니다. 참고로 디바운스는 300ms 같은 고정 시간을 기다려 빠른 기기도 대기하지만, transition은 고정 대기 시간 없이 기기 성능에 따라 적응한다는 차이가 있습니다.',
 'interview-question/736.mp3'),
(737, 'REACT', 148, 'NORMAL', true,
 'useTransition과 useDeferredValue는 어떻게 다르며, 각각 어떤 상황에서 사용하나요?',
 '둘 다 긴급하지 않은 갱신을 뒤로 미뤄 급한 갱신이 가로막히지 않게 하는 동시성 도구지만 적용 대상이 다릅니다. useTransition은 상태 갱신 함수(setter) 호출을 startTransition으로 감싸 그 갱신을 전환 갱신으로 표시하는 방식이라, setter를 직접 호출할 수 있어야 합니다. 탭 전환이나 필터처럼 갱신을 직접 통제할 때 적합하고, isPending으로 진행 중임을 표시할 수 있습니다. 반면 useDeferredValue는 값 자체를 지연된 버전으로 받아 쓰는 방식으로, 원래 값이 급히 바뀌어도 지연된 값은 여유가 있을 때 따라옵니다. 값만 있으면 되므로 부모에서 받은 props처럼 갱신 코드를 통제할 수 없는 경우에 적합하며, 진행 중 여부는 value !== deferredValue로 판단합니다.',
 'interview-question/737.mp3'),
(738, 'REACT', 148, 'NORMAL', true,
 '전통적인 SSR과 React 18의 스트리밍 SSR은 어떻게 다르며, 스트리밍 SSR에서 Suspense 경계는 어떤 역할을 하나요?',
 '전통적 SSR은 서버가 모든 데이터를 준비한 뒤 완성된 HTML을 한 번에 보내기 때문에, 느린 데이터 하나가 전체 응답을 지연시켰습니다. React 18의 스트리밍 SSR(renderToPipeableStream)은 느린 데이터를 기다리지 않고 셸 HTML을 먼저 보내고, 나머지 HTML을 나눠서 순차 전송합니다. 이때 Suspense 경계가 서버에서 스트리밍 청크의 단위가 되어, 준비되지 않은 경계 자리에는 fallback을 먼저 보내고 데이터가 준비되면 해당 조각의 HTML과 fallback을 교체하는 스크립트를 이어서 보냅니다. 클라이언트에서는 Suspense 경계가 하이드레이션의 단위가 되며, 선택적 하이드레이션으로 스트리밍된 조각을 순서와 무관하게 사용자가 먼저 상호작용한 부분부터 하이드레이션합니다. 결과적으로 TTFB와 TTI를 함께 줄이는 것이 목적입니다.',
 'interview-question/738.mp3'),
(739, 'REACT', 148, 'EASY', true,
 'React 18의 동시성 렌더링이란 무엇인지 설명해 주세요.',
 '동시성 렌더링은 React 18에서 도입된 것으로, 렌더 작업을 중단·재개·폐기할 수 있게 만든 내부 메커니즘입니다. React 17까지는 렌더가 동기적이고 중단 불가라 큰 트리를 렌더하는 동안 입력이 멈췄지만, 동시성 렌더링에서는 렌더 단계를 작은 단위로 나눠 실행하고 사이사이 브라우저에 제어권을 돌려주기 때문에 입력 같은 급한 갱신이 대량 목록 같은 느린 갱신에 가로막히지 않고 우선 처리됩니다. 이는 멀티스레드가 아니라, 단일 스레드인 JS에서 React가 렌더 작업을 협력적으로 양보하는 스케줄링으로 협력형 멀티태스킹에 가깝습니다. ReactDOM.render 대신 createRoot를 써야 활성화되며, 렌더가 중단·재시도될 수 있으므로 렌더 단계는 반드시 순수해야 합니다.',
 'interview-question/739.mp3'),
(740, 'REACT', 148, 'EASY', true,
 'React의 Suspense는 어떤 원리로 동작하나요?',
 'Suspense는 하위 트리가 아직 렌더할 준비가 안 됐을 때 대체 UI를 선언적으로 보여주는 기능입니다. 코드 분할(lazy) 로딩이나 데이터 로딩 중인 컴포넌트가 렌더 중 Promise throw나 use(promise)로 준비 안 됨을 알리면, React는 가장 가까운 Suspense 경계까지 렌더를 중단하고 그 경계에 지정한 fallback을 대신 보여줍니다. 이후 Promise가 완료되면 경계 아래를 다시 렌더해 실제 콘텐츠로 교체합니다. 같은 경계 안의 형제도 함께 대기하므로, 하나의 큰 경계는 전부 준비될 때까지 대기하고 여러 작은 경계를 두면 준비된 부분부터 표시됩니다. 또 transition 중에 Suspense가 발생하면 fallback 대신 이전 화면을 유지합니다. use에 넘기는 Promise는 안정된 참조여야 하며, 렌더 안에서 매 렌더 새 Promise를 만들면 재렌더마다 다시 중단되어 무한 로딩이 됩니다.',
 'interview-question/740.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 736
(3964, 736, '입력창은 즉시 갱신하고 목록 결과 갱신만 startTransition으로 감싸는 방법을 제시', 'ESSENTIAL', 1),
(3965, 736, '전환 갱신 중 새 입력이 오면 진행 중인 목록 렌더를 폐기하고 양보함을 설명', 'ESSENTIAL', 2),
(3966, 736, 'transition은 네트워크 요청 횟수를 줄이는 도구가 아님을 언급', 'ESSENTIAL', 3),
(3967, 736, '요청 횟수 문제는 디바운스나 서버 상태 라이브러리의 중복 제거로 해결함을 제시', 'ESSENTIAL', 4),
(3968, 736, 'setter를 직접 호출할 수 없으면 useDeferredValue로 값을 지연하는 대안을 제시', 'SUPPLEMENTARY', 5),
(3969, 736, '디바운스는 고정 시간 대기지만 transition은 기기 성능에 적응함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 737
(3970, 737, 'useTransition은 상태 갱신 함수(setter) 호출을 감싸는 방식임을 설명', 'ESSENTIAL', 1),
(3971, 737, 'useDeferredValue는 값 자체를 지연된 버전으로 받아 쓰는 방식임을 설명', 'ESSENTIAL', 2),
(3972, 737, '부모에서 받은 props처럼 갱신을 통제할 수 없으면 useDeferredValue가 적합함을 제시', 'ESSENTIAL', 3),
(3973, 737, 'useTransition은 진행 중 표시를 위해 isPending을 제공함을 언급', 'SUPPLEMENTARY', 4),
(3974, 737, '탭 전환·필터처럼 갱신을 직접 통제할 때 useTransition이 적합함을 제시', 'SUPPLEMENTARY', 5),

-- 질문 738
(3975, 738, '전통 SSR은 모든 데이터를 준비한 뒤 완성된 HTML을 한 번에 보냄을 설명', 'ESSENTIAL', 1),
(3976, 738, '스트리밍 SSR은 HTML을 한 번에 보내지 않고 나눠서 순차 전송함을 설명', 'ESSENTIAL', 2),
(3977, 738, 'Suspense 경계가 서버에서 스트리밍 청크의 단위가 됨을 언급', 'ESSENTIAL', 3),
(3978, 738, '선택적 하이드레이션은 사용자가 먼저 상호작용한 부분부터 하이드레이션함을 설명', 'SUPPLEMENTARY', 4),
(3979, 738, '클라이언트에서는 Suspense 경계가 하이드레이션의 단위가 됨을 언급', 'SUPPLEMENTARY', 5),
(3980, 738, '느린 데이터를 기다리지 않고 셸 HTML을 먼저 보냄을 언급', 'SUPPLEMENTARY', 6),

-- 질문 739
(3981, 739, '렌더 작업을 중단·재개·폐기할 수 있게 만든 메커니즘임을 설명', 'ESSENTIAL', 1),
(3982, 739, '급한 갱신(입력)이 느린 갱신에 가로막히지 않도록 우선 처리됨을 언급', 'ESSENTIAL', 2),
(3983, 739, '멀티스레드가 아니라 단일 스레드에서 협력적으로 양보하는 스케줄링임을 설명', 'ESSENTIAL', 3),
(3984, 739, 'createRoot를 써야 동시성 기능이 활성화됨을 언급', 'SUPPLEMENTARY', 4),
(3985, 739, '렌더가 중단·재시도될 수 있어 렌더 단계는 순수해야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 740
(3986, 740, '하위 컴포넌트가 준비 안 됨을 알리면 가장 가까운 Suspense 경계까지 렌더를 중단함을 설명', 'ESSENTIAL', 1),
(3987, 740, '준비되는 동안 경계에 지정한 fallback을 대신 보여줌을 언급', 'ESSENTIAL', 2),
(3988, 740, 'Promise가 완료되면 경계 아래를 다시 렌더해 실제 콘텐츠로 교체함을 설명', 'ESSENTIAL', 3),
(3989, 740, 'transition 중 Suspense가 발생하면 fallback 대신 이전 화면을 유지함을 언급', 'SUPPLEMENTARY', 4),
(3990, 740, '매 렌더 새 Promise를 만들어 use에 넘기면 무한 로딩이 됨을 언급', 'SUPPLEMENTARY', 5),
(3991, 740, '여러 작은 경계를 두면 준비된 부분부터 표시됨을 설명', 'SUPPLEMENTARY', 6);
