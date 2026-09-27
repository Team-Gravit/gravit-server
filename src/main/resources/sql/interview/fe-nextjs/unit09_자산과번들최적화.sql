-- Unit: 자산과 번들 최적화 (Unit ID: 166)
-- Chapter: Next.js (Chapter ID: 15)
-- Topic: NEXT_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-nextjs-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(826, 'NEXT_JS', 166, 'HARD', true,
 'Next.js 대시보드 페이지의 클라이언트 JavaScript 번들이 커서 상호작용 반응이 느립니다. 번들을 줄이기 위해 어떤 순서로 접근하시겠으며, 각 단계에서 주의할 점은 무엇인가요?',
 '먼저 @next/bundle-analyzer로 청크 구성을 시각화해 어디가 큰지 확인한 뒤 판단하겠습니다. 분석 후 축소 순서는 ① 서버 컴포넌트로 옮길 수 있는가 → ② 라우트 분할이 제대로 되는가 → ③ next/dynamic으로 지연할 수 있는가 → ④ 라이브러리 자체를 가벼운 것으로 바꿀 수 있는가입니다. 즉 next/dynamic 지연 로딩보다 서버 컴포넌트 이동을 먼저 검토합니다. 서버 컴포넌트는 애초에 클라이언트 번들에 포함되지 않기 때문에, 마크다운 파서나 날짜 라이브러리, 큰 데이터 변환 로직을 서버 컴포넌트에 두는 것만으로 클라이언트 번들이 줄어듭니다. 다음으로 App Router가 라우트 세그먼트마다 별도 청크를 만드는지 확인하고, 한 라우트 안에서도 모달·에디터·차트처럼 조건부로 표시되는 무거운 컴포넌트는 next/dynamic으로 감싸 버튼을 누를 때처럼 실제로 사용하는 시점에 로드합니다. 이때 dynamic의 ssr: false는 브라우저 API에 의존해 서버 렌더링이 불가능한 경우에만 쓰고, SEO나 첫 화면 표시가 필요한 컴포넌트에는 쓰지 않아야 합니다. 또 15 기준으로 ssr: false는 서버 컴포넌트 안에서 쓸 수 없어 클라이언트 컴포넌트로 감싸서 사용해야 합니다. 아이콘·UI 킷처럼 배럴 파일이 큰 라이브러리는 optimizePackageImports로 사용한 모듈만 포함시킬 수 있습니다. 하이드레이션 비용은 클라이언트 번들 크기에 비례하므로 이런 번들 최적화는 곧 TTI·INP 같은 상호작용 시점 최적화로 이어집니다.'),
(827, 'NEXT_JS', 166, 'NORMAL', true,
 'next/image를 사용할 때 첫 화면에 보이는 히어로 이미지와 스크롤해야 보이는 이미지의 로딩 방식은 어떻게 달라야 하며, 그 이유는 무엇인가요?',
 'next/image는 뷰포트 밖 이미지를 스크롤이 가까워질 때 로드하는 지연 로딩이 기본값입니다. 그래서 스크롤해야 보이는 이미지는 기본값인 지연 로딩을 그대로 두면 됩니다. 반면 첫 화면의 히어로 이미지는 대개 LCP를 결정하는 요소이기 때문에, 기본값대로 지연 로딩되면 LCP 이미지의 로드가 늦어져 LCP가 악화됩니다. 그래서 지연 로딩은 첫 화면 이미지에는 오히려 꺼야 하며, 뷰포트 안의 가장 큰 이미지 1~2개, 즉 LCP 후보에는 priority를 지정해 지연 로딩을 해제하고 preload 힌트를 주어야 합니다. 다만 모든 이미지에 priority를 주면 preload가 남발되어 다른 리소스가 밀리므로 LCP 후보에만 사용해야 합니다. 추가로 반응형 이미지에서 sizes를 지정하지 않으면 모바일에서도 데스크톱 크기를 다운로드하므로 실제 렌더링 폭에 맞는 sizes를 작성하는 것이 좋습니다.'),
(828, 'NEXT_JS', 166, 'NORMAL', true,
 'Google Fonts CDN 링크로 폰트를 불러오는 방식과 비교했을 때, next/font를 사용하면 무엇이 달라지고 어떤 이점이 있나요?',
 'Google Fonts CDN 링크로 불러오면 외부 요청 왕복이 생기고, 폰트가 교체될 때 글자 깜빡임(FOUT)과 레이아웃 이동이 발생해 CLS와 FCP에 영향을 줍니다. next/font는 빌드 시 폰트 파일을 프로젝트 안으로 내려받아 자체 호스팅하기 때문에 외부 요청이 0회가 되어 Google Fonts CDN으로의 DNS·연결 비용이 사라지고, 개인정보 관점에서도 유리합니다. 또 폴백 폰트의 size-adjust·ascent-override를 계산해 실제 폰트와 같은 공간을 차지하게 만들기 때문에 폰트 교체 시 레이아웃 이동이 없어져 CLS가 0이 됩니다. 사용할 때는 루트 레이아웃에서 한 번만 선언하고 CSS 변수로 내려보내는 것이 표준 패턴이며, 여러 파일에서 각각 선언하면 중복 인스턴스가 생깁니다. 한글 폰트처럼 용량이 큰 경우 굵기별 파일 여러 개보다 가변 폰트 하나가 전체 전송량이 작으므로 서브셋과 가변 폰트를 조합합니다.'),
(829, 'NEXT_JS', 166, 'EASY', true,
 'Core Web Vitals의 LCP, CLS, INP는 각각 주로 어떤 요소에 의해 결정되나요?',
 'LCP(Largest Contentful Paint)는 대개 히어로 이미지나 큰 제목 폰트가 결정합니다. CLS(Cumulative Layout Shift)는 크기를 지정하지 않은 이미지와 폰트 교체, 이 두 가지가 결정합니다. INP(Interaction to Next Paint)는 JavaScript 실행량이 결정합니다. 그래서 이미지는 next/image로 리사이즈·포맷 변환하고 width·height로 로드 전에 자리를 미리 확보해 LCP와 CLS를 개선하고, 폰트는 next/font로 CLS를, JavaScript 번들은 라우트 분할·next/dynamic·서버 컴포넌트로 INP를 개선하는 식으로 자산과 지표를 연결해 최적화합니다.'),
(830, 'NEXT_JS', 166, 'EASY', true,
 'Next.js App Router에서 라우트 단위 코드 스플리팅은 어떻게 자동으로 이루어지나요?',
 'App Router는 라우트 세그먼트마다 별도 청크를 만듭니다. 그래서 /dashboard를 열 때 /settings의 코드는 내려받지 않고, /settings 청크는 해당 라우트로 이동할 때 로드됩니다. 공유 레이아웃과 React 같은 공통 라이브러리는 별도의 공용 청크로 분리되어 라우트 간에 재사용됩니다. 또 <Link>가 뷰포트에 보이면 대상 라우트의 청크를 미리 프리페치해 이동을 빠르게 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 826
(4450, 826, '서버 컴포넌트는 클라이언트 번들에 포함되지 않아 옮기면 번들이 줄어듦을 설명', 'ESSENTIAL', 1),
(4451, 826, '번들 축소 방법 중 서버 컴포넌트 이동을 next/dynamic 지연 로딩보다 먼저 검토함을 제시', 'ESSENTIAL', 2),
(4452, 826, '조건부로 표시되는 무거운 컴포넌트를 next/dynamic으로 사용 시점에 로드하는 방법을 설명', 'ESSENTIAL', 3),
(4453, 826, 'dynamic의 ssr: false는 브라우저 API에 의존하는 경우에만 쓰고 SEO·첫 화면이 필요하면 쓰지 않음을 언급', 'ESSENTIAL', 4),
(4454, 826, '@next/bundle-analyzer로 청크 구성을 시각화한 뒤 줄일 지점을 판단함을 언급', 'SUPPLEMENTARY', 5),
(4455, 826, '하이드레이션 비용이 클라이언트 번들 크기에 비례해 번들 최적화가 INP 개선으로 이어짐을 서술', 'SUPPLEMENTARY', 6),
(4456, 826, 'optimizePackageImports로 배럴 파일 라이브러리에서 사용한 모듈만 포함시키는 방법을 제시', 'SUPPLEMENTARY', 7),

-- 질문 827
(4457, 827, 'next/image는 뷰포트 밖 이미지를 지연 로딩하는 것이 기본값임을 언급', 'ESSENTIAL', 1),
(4458, 827, '첫 화면 히어로 이미지가 지연 로딩되면 LCP가 악화됨을 설명', 'ESSENTIAL', 2),
(4459, 827, '첫 화면의 LCP 후보 이미지에는 priority를 지정해 지연 로딩을 해제해야 함을 설명', 'ESSENTIAL', 3),
(4460, 827, '모든 이미지에 priority를 주면 preload 남발로 다른 리소스가 밀림을 언급', 'SUPPLEMENTARY', 4),
(4461, 827, 'priority가 지연 로딩 해제와 함께 preload 힌트를 추가함을 언급', 'SUPPLEMENTARY', 5),
(4462, 827, '반응형에서 sizes를 지정하지 않으면 모바일에서도 데스크톱 크기를 다운로드함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 828
(4463, 828, 'next/font가 빌드 시 폰트 파일을 프로젝트 안으로 내려받아 자체 호스팅함을 설명', 'ESSENTIAL', 1),
(4464, 828, '자체 호스팅으로 외부 CDN에 대한 DNS·연결 비용이 사라짐을 언급', 'ESSENTIAL', 2),
(4465, 828, '폴백 폰트에 size-adjust를 적용해 폰트 교체 시 레이아웃 이동을 없앤다고 설명', 'ESSENTIAL', 3),
(4466, 828, '외부 CDN 요청이 없어 개인정보 관점에서도 유리함을 언급', 'SUPPLEMENTARY', 4),
(4467, 828, '루트 레이아웃에서 한 번 선언하고 CSS 변수로 내려보내는 것이 표준 패턴임을 언급', 'SUPPLEMENTARY', 5),
(4468, 828, '굵기별 파일 여러 개보다 가변 폰트 하나가 전체 전송량이 작음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 829
(4469, 829, 'LCP는 대개 히어로 이미지나 큰 제목 폰트가 결정함을 언급', 'ESSENTIAL', 1),
(4470, 829, 'CLS의 원인으로 크기 미지정 이미지와 폰트 교체 두 가지를 모두 언급', 'ESSENTIAL', 2),
(4471, 829, 'INP는 JavaScript 실행량이 결정함을 언급', 'ESSENTIAL', 3),
(4472, 829, 'next/image가 width·height로 자리를 미리 확보해 CLS를 방지함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 830
(4473, 830, 'App Router가 라우트 세그먼트마다 별도 청크를 만든다고 설명', 'ESSENTIAL', 1),
(4474, 830, '한 라우트를 열 때 다른 라우트의 코드는 내려받지 않음을 언급', 'ESSENTIAL', 2),
(4475, 830, '공유 레이아웃과 React 등 공통 라이브러리는 공용 청크로 분리되어 재사용됨을 언급', 'SUPPLEMENTARY', 3),
(4476, 830, '<Link>가 뷰포트에 보이면 대상 라우트 청크를 프리페치함을 언급', 'SUPPLEMENTARY', 4);
