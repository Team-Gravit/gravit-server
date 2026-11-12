-- Unit: 하이드레이션 (Unit ID: 164)
-- Chapter: Next.js (Chapter ID: 15)
-- Topic: NEXT_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-nextjs-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(816, 'NEXT_JS', 164, 'HARD', true,
 '클라이언트 컴포넌트에서 localStorage에 저장된 테마 값을 바로 읽어 렌더링했더니 하이드레이션 오류가 발생했습니다. 원인은 무엇이고, 어떻게 해결하며 그 해결책의 대가는 무엇인가요?',
 '하이드레이션은 서버가 만든 HTML을 새로 만들지 않고, 브라우저가 클라이언트 컴포넌트를 다시 렌더링한 결과를 기존 DOM과 대조해 이벤트 핸들러를 부착하는 과정입니다. 그런데 서버에는 localStorage가 없기 때문에 서버는 기본값인 "light"로 HTML을 그리고, 브라우저의 첫 렌더링은 저장된 "dark"를 그리게 되어 두 결과가 달라지고 하이드레이션 미스매치가 발생합니다. 심하면 React가 해당 서브트리를 버리고 클라이언트에서 처음부터 다시 렌더링해 성능 손실과 깜빡임이 생깁니다. 해결 원칙은 첫 렌더링을 서버와 동일하게 만드는 것입니다. useState의 초기값은 서버와 같은 "light"로 두고, 하이드레이션이 끝난 뒤 실행되는 useEffect 안에서 localStorage의 실제 값으로 교체합니다. 다만 이 방식은 첫 화면에 기본값이 잠깐 보이는 깜빡임을 감수해야 합니다. 외부 저장소를 구독하는 형태라면 useSyncExternalStore의 세 번째 인자 getServerSnapshot으로 서버용 값을 따로 제공할 수도 있습니다. 깜빡임을 없애려면 테마를 쿠키에 저장하고 서버 컴포넌트에서 읽어 props로 넘길 수 있는데, 이 경우 라우트가 동적 렌더링된다는 대가가 있습니다.',
 'interview-question/816.mp3'),
(817, 'NEXT_JS', 164, 'NORMAL', true,
 '기존 SSR과 스트리밍 SSR은 HTML을 응답하는 방식에서 어떻게 다르고, 스트리밍 SSR의 이점은 무엇인가요?',
 '기존 SSR은 페이지의 모든 데이터가 준비돼야 HTML을 한 번에 응답했기 때문에, 느린 API 하나가 전체 응답을 막는 문제가 있었습니다. 스트리밍 SSR은 HTML을 여러 청크로 나눠 준비된 순서대로 보냅니다. App Router는 이를 기본으로 사용하며 청크의 단위는 Suspense 경계입니다. 첫 청크에는 레이아웃·헤더 같은 셸과 각 Suspense의 fallback이 담겨 즉시 표시되므로 TTFB와 FCP가 빨라집니다. 이후 청크는 hidden으로 숨겨진 실제 콘텐츠와 이를 fallback 자리에 옮겨 넣는 작은 인라인 스크립트로 구성되고, 순서에 상관없이 준비된 것부터 전송됩니다. 결과적으로 느린 데이터가 전체 응답을 막지 않습니다. 다만 프록시나 CDN이 응답을 버퍼링하면 스트리밍 효과가 사라지므로 인프라의 압축·버퍼링 설정을 확인해야 합니다.',
 'interview-question/817.mp3'),
(818, 'NEXT_JS', 164, 'NORMAL', true,
 '하이드레이션 미스매치를 다룰 때 suppressHydrationWarning과 next/dynamic의 ssr: false는 각각 어떤 상황에 쓰며, 사용 시 주의할 점은 무엇인가요?',
 'suppressHydrationWarning은 시각이나 타임스탬프처럼 서버와 브라우저의 값이 다를 수밖에 없는, 불일치가 불가피한 텍스트 한 곳에 붙여 경고를 억제하는 도구입니다. 한 단계 깊이의 텍스트·속성만 억제하므로 남용하면 안 됩니다. next/dynamic의 ssr: false는 차트·에디터·지도처럼 브라우저 API에 전적으로 의존하는 컴포넌트에 씁니다. 이 경우 해당 컴포넌트가 서버 HTML에서 빠지므로 SEO와 첫 화면에 영향을 줍니다. 즉 ssr: false는 미스매치를 고치는 것이 아니라 서버 렌더링을 포기하는 선택이라서, 미스매치 원인이 값 하나라면 useEffect 패턴으로 충분하고 전체 컴포넌트를 CSR로 돌리는 것은 마지막 수단으로 남겨 둡니다.',
 'interview-question/818.mp3'),
(819, 'NEXT_JS', 164, 'EASY', true,
 '하이드레이션이란 무엇이고, 서버 렌더링을 하는데도 브라우저에서 JavaScript가 필요한 이유는 무엇인가요?',
 '하이드레이션은 서버가 만든 정적 HTML에 브라우저의 React가 이벤트 핸들러와 상태를 붙여 상호작용 가능한 앱으로 되살리는 과정입니다. 브라우저는 먼저 HTML을 파싱해 화면을 표시하지만 이 시점에는 클릭·입력이 불가능하고, 이후 JS 번들을 내려받아 실행하면서 클라이언트 컴포넌트를 메모리에서 다시 렌더링합니다. 그 결과를 기존 DOM과 대조해 일치하면 DOM을 재사용하고 이벤트 핸들러를 부착합니다. 즉 DOM을 새로 만들지 않고 이미 있는 DOM에 React 트리를 연결합니다. HTML은 화면을, 하이드레이션은 동작을 담당하기 때문에, HTML만으로는 onClick이 붙지 않아 클라이언트 컴포넌트의 JS가 여전히 필요합니다. 화면 표시와 상호작용 가능 시점 사이가 길면 보이지만 반응하지 않는 구간이 생깁니다. 참고로 하이드레이션 대상은 클라이언트 컴포넌트뿐이며, 서버 컴포넌트는 JS가 브라우저로 가지 않으므로 하이드레이션 비용이 0입니다.',
 'interview-question/819.mp3'),
(820, 'NEXT_JS', 164, 'EASY', true,
 'React 18의 선택적 하이드레이션(Selective Hydration)이란 무엇인가요?',
 '선택적 하이드레이션은 스트리밍 SSR과 짝을 이루는 React 18의 기능으로, 전체 번들이 도착·실행될 때까지 기다리지 않고 도착한 청크부터 독립적으로 하이드레이션합니다. 이때 Suspense 경계가 하이드레이션의 단위가 됩니다. 또 사용자가 아직 하이드레이션되지 않은 영역을 클릭하면 그 영역을 우선 처리하며, 클릭 이벤트는 React가 기록해 두었다가 하이드레이션 완료 직후 재생합니다. 그 결과 전체 번들이 실행될 때까지 아무것도 반응하지 않던 문제가 해결됩니다.',
 'interview-question/820.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 816
(4397, 816, '서버에는 localStorage가 없어 서버 HTML과 브라우저 첫 렌더링 결과가 달라짐을 설명', 'ESSENTIAL', 1),
(4398, 816, '첫 렌더링은 서버와 같은 기본값으로 두고 useEffect에서 실제 값으로 교체하는 방법을 제시', 'ESSENTIAL', 2),
(4399, 816, 'useEffect 패턴은 첫 화면에 기본값이 잠깐 보이는 깜빡임을 감수해야 함을 언급', 'ESSENTIAL', 3),
(4400, 816, '쿠키 값을 서버 컴포넌트에서 읽어 넘기는 방식은 라우트가 동적 렌더링되는 대가가 있음을 언급', 'SUPPLEMENTARY', 4),
(4401, 816, '쿠키 값을 서버 컴포넌트에서 읽어 props로 넘기면 깜빡임 없이 처리됨을 언급', 'SUPPLEMENTARY', 5),
(4402, 816, 'useSyncExternalStore의 getServerSnapshot으로 서버용 값을 따로 제공하는 방법을 언급', 'SUPPLEMENTARY', 6),

-- 질문 817
(4403, 817, '기존 SSR은 페이지의 모든 데이터가 준비돼야 HTML을 한 번에 응답함을 언급', 'ESSENTIAL', 1),
(4404, 817, '스트리밍 SSR은 HTML을 여러 청크로 나눠 준비된 순서대로 보냄을 설명', 'ESSENTIAL', 2),
(4405, 817, '느린 데이터가 전체 응답을 막지 않음과 셸을 먼저 보내 TTFB·FCP 개선 중 최소 1개를 이점으로 제시', 'ESSENTIAL', 3),
(4406, 817, 'App Router에서 스트리밍 청크의 단위가 Suspense 경계임을 언급', 'SUPPLEMENTARY', 4),
(4407, 817, '이후 청크가 숨겨진 실제 콘텐츠와 fallback 자리에 옮겨 넣는 인라인 스크립트로 구성됨을 설명', 'SUPPLEMENTARY', 5),
(4408, 817, '프록시·CDN이 응답을 버퍼링하면 스트리밍 효과가 사라짐을 언급', 'SUPPLEMENTARY', 6),

-- 질문 818
(4409, 818, 'suppressHydrationWarning은 타임스탬프처럼 불일치가 불가피한 텍스트 한 곳에 쓰는 도구임을 언급', 'ESSENTIAL', 1),
(4410, 818, 'ssr: false는 차트·에디터·지도처럼 브라우저 API에 전적으로 의존하는 컴포넌트에 쓰는 도구임을 언급', 'ESSENTIAL', 2),
(4411, 818, 'ssr: false를 쓰면 서버 HTML에서 빠져 SEO·첫 화면에 영향을 줌을 언급', 'ESSENTIAL', 3),
(4412, 818, 'suppressHydrationWarning은 한 단계 깊이의 텍스트·속성만 억제하므로 남용하면 안 됨을 언급', 'SUPPLEMENTARY', 4),
(4413, 818, 'ssr: false는 미스매치를 고치는 것이 아니라 서버 렌더링을 포기하는 선택임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 819
(4414, 819, '서버가 만든 HTML에 React가 이벤트 핸들러와 상태를 붙여 상호작용 가능하게 만드는 과정임을 설명', 'ESSENTIAL', 1),
(4415, 819, '하이드레이션은 DOM을 새로 만들지 않고 이미 있는 DOM에 React 트리를 연결함을 언급', 'ESSENTIAL', 2),
(4416, 819, 'HTML만으로는 onClick이 붙지 않아 클라이언트 컴포넌트의 JS가 여전히 필요함을 설명', 'ESSENTIAL', 3),
(4417, 819, '하이드레이션 대상은 클라이언트 컴포넌트뿐이고 서버 컴포넌트는 하이드레이션 비용이 0임을 언급', 'SUPPLEMENTARY', 4),
(4418, 819, 'HTML 표시 후 JS 실행 전까지 보이지만 반응하지 않는 구간이 생김을 언급', 'SUPPLEMENTARY', 5),

-- 질문 820
(4419, 820, '스트리밍으로 도착한 청크부터 독립적으로 하이드레이션함을 설명', 'ESSENTIAL', 1),
(4420, 820, '사용자가 아직 하이드레이션되지 않은 영역을 클릭하면 그 영역을 우선 처리함을 언급', 'ESSENTIAL', 2),
(4421, 820, '기록해 둔 클릭 이벤트를 하이드레이션 완료 직후 재생(replay)함을 언급', 'SUPPLEMENTARY', 3),
(4422, 820, 'Suspense 경계가 하이드레이션의 단위가 됨을 언급', 'SUPPLEMENTARY', 4);
