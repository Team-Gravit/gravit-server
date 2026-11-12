-- Unit: 라우팅·레이아웃과 미들웨어 (Unit ID: 165)
-- Chapter: Next.js (Chapter ID: 15)
-- Topic: NEXT_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-nextjs-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(821, 'NEXT_JS', 165, 'HARD', true,
 '로그인한 사용자만 /dashboard에 접근하도록 Next.js 미들웨어에서 세션을 검증하려고 합니다. 미들웨어만으로 인증을 처리할 때의 한계는 무엇이고, 어떻게 설계해야 하는지 설명해 주시겠어요?',
 '미들웨어는 "쿠키가 있는지" 같은 낙관적 검사로 로그인하지 않은 사용자를 /login으로 빠르게 리다이렉트하는 용도로 쓰는 것이 맞고, 인증을 미들웨어에서 끝내면 안 됩니다. 먼저 14/15의 미들웨어는 기본적으로 Edge 런타임에서 실행되어 fs나 네이티브 DB 드라이버 같은 Node.js API를 쓸 수 없기 때문에, DB 조회가 필요한 세션 검증은 미들웨어에서 하기 어렵습니다. 또 미들웨어는 캐시 조회·라우트 매칭보다 먼저 매 요청마다 실행되므로, 세션 검증을 위해 외부 API를 호출하면 그 시간이 모든 페이지의 TTFB에 더해집니다. 그래서 설계는 미들웨어에서는 쿠키 유무만 보고 리다이렉트하고, 실제 인가는 데이터에 접근하는 지점인 서버 컴포넌트·서버 액션·라우트 핸들러에서 반드시 다시 수행하는 방식이어야 합니다. JWT 서명 검증처럼 Web Crypto로 가능한 작업은 Edge에서도 되지만, DB 조회가 필요하면 fetch로 별도 API를 부르거나 서버 컴포넌트로 미룹니다. 실제로 2025년 초 특정 내부 헤더로 미들웨어를 우회할 수 있는 CVE-2025-29927 취약점이 공개되어, 미들웨어만으로 보호한 시스템은 이 우회로 전부 뚫렸습니다. 참고로 Next.js 16에서는 이런 오해를 줄이기 위해 middleware.ts가 proxy.ts로 이름이 바뀌고 Node.js 런타임으로 고정됐습니다.',
 'interview-question/821.mp3'),
(822, 'NEXT_JS', 165, 'NORMAL', true,
 'Next.js App Router에서 layout.tsx와 template.tsx의 차이는 무엇이고, 어떤 경우에 템플릿을 사용하는지 설명해 주세요.',
 '핵심 차이는 내비게이션 시 인스턴스가 유지되는가입니다. layout.tsx는 페이지를 이동해도 인스턴스가 유지되고 리렌더링되지 않기 때문에 내부 useState 상태가 그대로 유지되고, useEffect도 최초 1회만 실행되며 DOM 요소도 재사용됩니다. 반면 template.tsx는 레이아웃과 같은 위치에 두지만 내비게이션마다 언마운트 후 새 인스턴스로 마운트되므로 useState가 초기화되고 useEffect가 페이지 이동마다 재실행되며 DOM도 새로 생성됩니다. 그래서 레이아웃은 내비게이션 바, 사이드바, Provider처럼 유지돼야 하는 공유 UI에 쓰고, 템플릿은 페이지 진입 애니메이션, 페이지별 로깅, 폼 초기화처럼 이동할 때마다 다시 실행돼야 하는 경우에 씁니다. 레이아웃 안에서 key를 바꿔 상태를 억지로 초기화하는 대신 템플릿으로 바꾸면 대부분 해결됩니다. 같은 위치에 둘 다 있으면 레이아웃이 템플릿을 감싸, 레이아웃의 children 자리에 템플릿이 들어갑니다.',
 'interview-question/822.mp3'),
(823, 'NEXT_JS', 165, 'NORMAL', true,
 'Next.js 미들웨어에서 NextResponse.redirect와 NextResponse.rewrite는 어떻게 다르고, 각각 어떤 상황에서 사용하나요?',
 '미들웨어는 반환값으로 redirect, rewrite, next 중 하나를 선택합니다. redirect는 URL 자체가 바뀌는 이동이고, rewrite는 사용자에게 보이는 URL은 그대로 두고 내부 경로만 바꿉니다. 그래서 rewrite는 /about을 내부적으로 /ko/about으로 보내는 다국어 처리, /pricing을 /pricing-b로 보내는 A/B 테스트, 레거시 서버 프록시에 쓰입니다. 반면 redirect는 URL이 바뀌고 검색 엔진에도 이동이 알려지므로 영구 이동에는 redirect(308)를 쓰고, 세션 쿠키가 없는 사용자를 /login으로 보내는 경우에도 redirect를 씁니다. next는 요청을 그대로 통과시키면서 헤더나 쿠키를 수정할 수 있어, 예를 들어 x-request-id 헤더를 붙이는 데 씁니다.',
 'interview-question/823.mp3'),
(824, 'NEXT_JS', 165, 'EASY', true,
 'App Router에서 page.tsx와 layout.tsx는 각각 어떤 역할을 하고, 예약 파일들은 렌더링 시 어떤 순서로 중첩되는지 설명해 주세요.',
 'App Router는 app 디렉터리의 폴더 구조가 곧 URL 구조이고, 폴더 안의 예약된 파일명이 세그먼트의 UI 역할을 결정합니다. page.tsx는 해당 세그먼트의 고유 UI로, 이 파일이 있어야 URL로 접근할 수 있고 없으면 폴더는 경로 조직용으로만 쓰입니다. layout.tsx는 하위 세그먼트를 감싸는 공유 UI로 내비게이션 시 유지됩니다. loading.tsx는 세그먼트를 자동으로 Suspense로 감싸는 로딩 UI이고, error.tsx는 세그먼트를 자동으로 Error Boundary로 감싸며 클라이언트 컴포넌트여야 하고 reset()을 제공합니다. 렌더링 시에는 바깥부터 레이아웃 → 템플릿 → 에러 경계 → 서스펜스 → 페이지 순으로 자동 중첩됩니다.',
 'interview-question/824.mp3'),
(825, 'NEXT_JS', 165, 'EASY', true,
 'App Router의 라우트 그룹이란 무엇이고, 어떤 상황에서 사용하는지 설명해 주세요.',
 '라우트 그룹은 (marketing)처럼 폴더명을 괄호로 감싸 표기하는 라우팅 패턴으로, 이 폴더명은 URL에 포함되지 않습니다. 그래서 URL에 영향 없이 레이아웃을 공유하거나 폴더를 정리하는 데 씁니다. 대표적으로 로그인 전과 후의 레이아웃이 다른데 URL은 같은 깊이여야 하는 상황에서, (auth)/login과 (app)/dashboard처럼 그룹별로 layout.tsx를 따로 두면 URL은 /login, /dashboard로 유지되면서 레이아웃만 나눌 수 있습니다.',
 'interview-question/825.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 821
(4423, 821, '미들웨어는 쿠키 존재 여부 같은 낙관적 검사로 리다이렉트하는 용도임을 언급', 'ESSENTIAL', 1),
(4424, 821, '실제 인가는 서버 컴포넌트·서버 액션·라우트 핸들러 등 데이터 접근 지점에서 다시 수행해야 함을 언급', 'ESSENTIAL', 2),
(4425, 821, '미들웨어 기본 Edge 런타임에서는 Node.js API를 쓸 수 없어 DB 조회 세션 검증이 어렵다는 점을 설명', 'ESSENTIAL', 3),
(4426, 821, '미들웨어가 매 요청 실행되므로 외부 API 세션 검증 호출이 모든 페이지의 TTFB에 더해짐을 언급', 'SUPPLEMENTARY', 4),
(4427, 821, '특정 내부 헤더로 미들웨어를 우회할 수 있었던 취약점(CVE-2025-29927)을 사례로 언급', 'SUPPLEMENTARY', 5),
(4428, 821, 'JWT 서명 검증은 Web Crypto로 Edge 런타임에서도 가능함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 822
(4429, 822, '레이아웃은 내비게이션 시 인스턴스가 유지되고 템플릿은 매번 새로 마운트된다는 차이를 설명', 'ESSENTIAL', 1),
(4430, 822, '템플릿 용도로 페이지 진입 애니메이션·페이지별 로깅·폼 초기화 중 최소 1개를 제시', 'ESSENTIAL', 2),
(4431, 822, '페이지 이동 시 템플릿의 useState 초기화·useEffect 재실행·DOM 새로 생성 중 최소 1개를 제시', 'SUPPLEMENTARY', 3),
(4432, 822, '같은 위치에 둘 다 있으면 레이아웃이 템플릿을 감싼다는 점을 언급', 'SUPPLEMENTARY', 4),
(4433, 822, '레이아웃 용도로 내비게이션 바·사이드바·Provider 중 최소 1개를 제시', 'SUPPLEMENTARY', 5),

-- 질문 823
(4434, 823, 'redirect는 사용자에게 보이는 URL이 바뀌고 rewrite는 URL을 유지한 채 내부 경로만 바뀐다는 차이를 설명', 'ESSENTIAL', 1),
(4435, 823, 'rewrite 활용 사례로 다국어·A/B 테스트·레거시 서버 프록시 중 최소 1개를 제시', 'ESSENTIAL', 2),
(4436, 823, 'redirect 사용 예로 영구 이동(308)·비로그인 사용자의 /login 이동 중 최소 1개를 제시', 'ESSENTIAL', 3),
(4437, 823, 'next를 반환하면 요청을 통과시키면서 헤더·쿠키를 수정할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(4438, 823, 'redirect는 검색 엔진에도 이동이 알려진다는 점을 언급', 'SUPPLEMENTARY', 5),

-- 질문 824
(4439, 824, 'page.tsx가 있어야 해당 세그먼트가 URL로 접근 가능함을 언급', 'ESSENTIAL', 1),
(4440, 824, 'layout.tsx가 하위 세그먼트를 감싸는 공유 UI임을 언급', 'ESSENTIAL', 2),
(4441, 824, '레이아웃 → 템플릿 → 에러 경계 → 서스펜스 → 페이지 순의 자동 중첩 순서를 설명', 'ESSENTIAL', 3),
(4442, 824, 'loading.tsx가 세그먼트를 Suspense로 자동으로 감싼다고 언급', 'SUPPLEMENTARY', 4),
(4443, 824, 'error.tsx가 세그먼트를 Error Boundary로 자동으로 감싼다고 언급', 'SUPPLEMENTARY', 5),
(4444, 824, 'error.tsx는 클라이언트 컴포넌트여야 한다는 점을 언급', 'SUPPLEMENTARY', 6),

-- 질문 825
(4445, 825, '라우트 그룹은 (marketing)처럼 괄호로 감싼 폴더명으로 표기함을 언급', 'ESSENTIAL', 1),
(4446, 825, '라우트 그룹의 폴더명은 URL에 포함되지 않는다는 점을 언급', 'ESSENTIAL', 2),
(4447, 825, '그룹별로 layout.tsx를 따로 두어 URL은 유지한 채 레이아웃을 나누는 용도를 설명', 'ESSENTIAL', 3),
(4448, 825, '로그인 전후 레이아웃을 나누는 (auth)/login과 (app)/dashboard 같은 예를 제시', 'SUPPLEMENTARY', 4),
(4449, 825, '라우트 그룹을 폴더 정리 용도로도 쓸 수 있음을 언급', 'SUPPLEMENTARY', 5);
