-- Unit: 렌더링 전략 선택 (Unit ID: 158)
-- Chapter: Next.js (Chapter ID: 15)
-- Topic: NEXT_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-nextjs-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(786, 'NEXT_JS', 158, 'HARD', true,
 'App Router로 상품 상세 페이지를 만드는데, 상품 정보는 가끔 바뀌고 재고는 실시간으로 보여야 합니다. 렌더링 전략을 어떻게 구성하고, 그 선택의 대가는 무엇인가요?',
 'App Router는 페이지 단위가 아니라 컴포넌트 단위로 렌더링 전략을 섞을 수 있으므로, 뼈대는 정적으로 만들고 실시간 영역만 동적으로 처리하겠습니다. 상품 정보는 가끔 바뀌므로 `export const revalidate = 60`처럼 재검증 주기를 지정해 ISR로 처리합니다. 그러면 캐시 적중 시 빠르게 응답하면서 재배포 없이 백그라운드에서 페이지를 다시 생성할 수 있습니다. 실시간 재고는 클라이언트 컴포넌트로 분리해 브라우저에서 주기적으로 폴링하는 CSR로 가져오고, 이 컴포넌트를 `Suspense`로 감싸 로딩 중에는 fallback을 보여 줍니다. 대가로는 ISR 영역이 재검증 주기만큼 데이터 신선도가 지연되어 상품 정보 변경이 바로 보이지 않을 수 있다는 점이 있습니다. 반대로 페이지 전체를 SSR로 만들면 항상 최신이지만 요청마다 서버 부하가 발생하고 TTFB가 느려집니다. 이렇게 정적 껍데기와 동적 구멍을 한 라우트 안에서 자동으로 처리하는 것이 부분 사전 렌더링(PPR)의 목표인데, 아직 실험 단계라 버전별로 다를 수 있습니다.',
 'interview-question/786.mp3'),
(787, 'NEXT_JS', 158, 'NORMAL', true,
 'SSR과 SSG는 HTML을 만드는 시점이 어떻게 다르고, 그 차이로 인해 무엇을 맞바꾸게 되나요?',
 'SSG는 빌드 시점에 HTML을 미리 만들어 두고 CDN에서 그대로 서빙하는 방식이고, SSR은 요청이 올 때마다 서버가 HTML을 생성해 응답하는 방식입니다. 그래서 두 방식은 데이터 신선도와 서버 부하를 맞바꿉니다. SSG는 서버 부하가 거의 없고 CDN에서 응답하므로 TTFB가 가장 빠르지만, 데이터가 빌드 시점에 고정됩니다. SSR은 항상 최신 데이터를 보여 줄 수 있지만 요청마다 서버 연산이 발생해 부하가 생기고 TTFB가 느립니다. 또 SSR은 쿠키·헤더를 활용해 사용자별 개인화가 가능한 반면, SSG는 모든 사용자에게 같은 HTML을 주므로 개인화가 불가능합니다.',
 'interview-question/787.mp3'),
(788, 'NEXT_JS', 158, 'NORMAL', true,
 '로그인한 사용자마다 내용이 달라지는 페이지라면 SSR과 CSR 중 무엇을 선택할지 어떤 기준으로 결정하나요?',
 '사용자마다 내용이 다른 페이지는 공용 캐시에 개인 데이터가 섞이면 보안 사고로 이어지므로 SSG·ISR은 선택지에서 빠지고, SSR과 CSR 중에서 고르게 됩니다. 이때 결정 기준은 검색 노출(SEO)과 첫 화면 속도가 중요한가입니다. 중요하다면 서버가 요청마다 HTML을 만들어 주는 SSR을 선택하고, SSR의 느린 TTFB는 스트리밍으로 보완합니다. 중요하지 않다면 서버에서 HTML을 만들 이유가 줄어들어 클라이언트 컴포넌트와 useEffect·SWR·TanStack Query로 데이터를 가져오는 CSR로도 충분합니다. CSR을 피해야 하는 이유는 두 가지 단점 때문입니다. 첫째, CSR은 빈 HTML을 받기 때문에 크롤러가 빈 HTML을 볼 수 있어 SEO에 불리합니다. 둘째, JS 로딩 전까지 빈 화면이 보여 첫 화면 속도가 나빠지고, 번들 크기도 커집니다. 그래서 CSR은 실시간 채팅, 에디터, 관리자 툴처럼 SEO가 필요 없는 화면에 적합합니다.',
 'interview-question/788.mp3'),
(789, 'NEXT_JS', 158, 'EASY', true,
 'Next.js App Router에서 라우트의 기본 렌더링 방식은 무엇이고, 어떤 경우에 동적 렌더링(SSR)으로 전환되나요?',
 'App Router의 서버 컴포넌트는 기본적으로 빌드 시점에 정적으로 렌더링되고, 결과 HTML과 RSC 페이로드는 전체 라우트 캐시에 저장되어 요청마다 재사용됩니다. 그런데 요청 정보를 읽는 `cookies()`나 `headers()`, URL 쿼리마다 결과가 달라지는 `searchParams` 접근, `fetch`의 `cache: ''no-store''` 옵션, `export const dynamic = ''force-dynamic''` 같은 동적 API를 하나라도 사용하면 Next.js는 해당 라우트 전체를 요청 시점 렌더링(SSR)으로 자동 전환합니다. 그래서 루트 레이아웃에서 `cookies()`를 호출하면 하위 모든 라우트가 영향을 받아 사이트 전체가 SSR로 전환되는 함정이 있습니다. 또 Next.js 15부터는 `cookies()`, `headers()` 등이 Promise를 반환하는 비동기 API로 바뀌어 `await`로 접근해야 합니다.',
 'interview-question/789.mp3'),
(790, 'NEXT_JS', 158, 'EASY', true,
 'ISR(Incremental Static Regeneration)이란 무엇이며, 왜 필요한가요?',
 'ISR은 증분 정적 재생성으로, SSG로 빌드 시점에 만든 페이지를 일정 주기나 이벤트에 따라 백그라운드에서 다시 생성하는 방식입니다. 캐시가 만료된 뒤 요청이 오면 캐시된 응답을 먼저 주면서 백그라운드에서 페이지를 재생성합니다. SSG는 빠르지만 데이터가 빌드 시점에 고정되므로, ISR은 SSG의 속도를 유지하면서 재배포 없이 콘텐츠를 갱신하기 위해 필요합니다. App Router에서는 별도 API가 있는 것이 아니라 정적 라우트에 `revalidate` 같은 재검증 주기를 붙이면 ISR이 됩니다. 데이터 신선도는 재검증 주기만큼 지연되지만, 분·시간 단위로 바뀌는 블로그, 상품 목록, 뉴스 같은 페이지에 적합합니다.',
 'interview-question/790.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 786
(4238, 786, '상품 정보 영역은 revalidate 주기를 지정한 ISR로 처리한다고 제시', 'ESSENTIAL', 1),
(4239, 786, '실시간 재고 영역은 클라이언트 컴포넌트에서 가져오는 CSR로 분리한다고 제시', 'ESSENTIAL', 2),
(4240, 786, '한 페이지 안에서 컴포넌트 단위로 렌더링 전략을 섞는다고 설명', 'ESSENTIAL', 3),
(4241, 786, 'ISR 영역은 재검증 주기만큼 상품 정보 반영이 지연될 수 있음을 언급', 'ESSENTIAL', 4),
(4242, 786, '정적 껍데기와 동적 구멍 구조가 부분 사전 렌더링(PPR)의 목표임을 언급', 'SUPPLEMENTARY', 5),
(4243, 786, '페이지 전체를 SSR로 만들면 요청마다 서버 부하가 발생함을 언급', 'SUPPLEMENTARY', 6),
(4244, 786, '동적 영역을 Suspense로 감싸 로딩 중 fallback을 보여 준다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 787
(4245, 787, 'SSG는 빌드 시점에 HTML을 미리 만들어 둔다고 언급', 'ESSENTIAL', 1),
(4246, 787, 'SSR은 요청이 올 때마다 서버가 HTML을 생성한다고 언급', 'ESSENTIAL', 2),
(4247, 787, 'SSR과 SSG가 데이터 신선도와 서버 부하를 맞바꾼다고 설명', 'ESSENTIAL', 3),
(4248, 787, 'SSG는 CDN에서 그대로 서빙되어 TTFB가 가장 빠르다고 언급', 'SUPPLEMENTARY', 4),
(4249, 787, 'SSR은 쿠키·헤더를 활용한 개인화가 가능하다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 788
(4250, 788, 'SEO와 첫 화면 속도가 중요하면 SSR, 아니면 CSR을 고른다고 설명', 'ESSENTIAL', 1),
(4251, 788, 'CSR은 크롤러가 빈 HTML을 볼 수 있어 SEO에 불리하다고 언급', 'ESSENTIAL', 2),
(4252, 788, 'CSR은 JS 로딩 전까지 빈 화면이 보인다고 언급', 'ESSENTIAL', 3),
(4253, 788, '개인화 페이지는 공용 캐시 문제로 SSG·ISR이 선택지에서 빠진다고 설명', 'SUPPLEMENTARY', 4),
(4254, 788, 'SSR의 느린 TTFB를 스트리밍으로 보완할 수 있다고 언급', 'SUPPLEMENTARY', 5),
(4255, 788, '실시간 채팅·에디터·관리자 툴 중 최소 1개를 CSR 적합 예로 제시', 'SUPPLEMENTARY', 6),

-- 질문 789
(4256, 789, 'App Router 서버 컴포넌트의 기본값이 빌드 시점 정적 렌더링임을 언급', 'ESSENTIAL', 1),
(4257, 789, 'cookies()·headers()·searchParams·no-store·force-dynamic 중 최소 2개를 전환 조건으로 제시', 'ESSENTIAL', 2),
(4258, 789, '동적 API를 하나라도 쓰면 해당 라우트 전체가 동적으로 전환된다고 언급', 'ESSENTIAL', 3),
(4259, 789, '루트 레이아웃에서 cookies()를 쓰면 사이트 전체가 SSR로 전환된다고 언급', 'SUPPLEMENTARY', 4),
(4260, 789, 'Next.js 15부터 cookies()·headers()가 Promise를 반환하는 비동기 API임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 790
(4261, 790, 'ISR은 SSG로 만든 페이지를 백그라운드에서 다시 생성하는 방식이라고 설명', 'ESSENTIAL', 1),
(4262, 790, 'ISR의 재생성이 일정 주기나 이벤트에 따라 일어난다고 언급', 'ESSENTIAL', 2),
(4263, 790, 'ISR은 재배포 없이 콘텐츠를 갱신하기 위해 필요하다고 언급', 'ESSENTIAL', 3),
(4264, 790, '만료 후에는 캐시된 응답을 주면서 백그라운드에서 재생성한다고 설명', 'SUPPLEMENTARY', 4),
(4265, 790, 'App Router에서 정적 라우트에 재검증 주기를 붙이면 ISR이 된다고 언급', 'SUPPLEMENTARY', 5),
(4266, 790, '블로그·상품 목록·뉴스 중 최소 1개를 ISR 적합 예로 제시', 'SUPPLEMENTARY', 6);
