-- Unit: 라우팅·레이아웃과 미들웨어 (Unit ID: 165)
-- Chapter: Next.js (Chapter ID: 15)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (591, 165, '레이아웃·템플릿 중첩과 라우트 그룹'),
       (749, 165, '병렬 라우트와 Edge 런타임 제약'),
       (907, 165, 'App Router 경로 매칭·레이아웃 유지와 미들웨어 위치 규칙');

-- =====================================================
-- Lesson 591: 레이아웃·템플릿 중첩과 라우트 그룹
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3725, 591, '아래 파일 구성에서 /dashboard/settings 를 열었을 때 만들어지는 컴포넌트 중첩 순서(바깥 → 안쪽)로 옳은 것은?', '```
app/
  layout.tsx
  template.tsx
  error.tsx
  loading.tsx
  dashboard/
    layout.tsx
    settings/
      page.tsx
```

app/dashboard 에는 template.tsx·error.tsx·loading.tsx 가 없다.', 'OBJECTIVE'),
       (3726, 591, '아래 파일을 내용은 그대로 두고 같은 위치의 template.tsx 로 이름만 바꿨다. /dashboard/a 에서 /dashboard/b 로 이동했을 때 화면의 count 값과 콘솔 출력은?', '```tsx
// app/dashboard/layout.tsx
"use client";
import { useState, useEffect } from "react";

export default function DashboardShell({ children }: { children: React.ReactNode }) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    console.log("mounted");
  }, []);

  return (
    <section>
      <button onClick={() => setCount(count + 1)}>{count}</button>
      {children}
    </section>
  );
}
```

버튼을 눌러 count 를 3까지 올린 뒤, 대시보드 안의 링크로 /dashboard/a 에서 /dashboard/b 로 이동한다.', 'OBJECTIVE'),
       (3727, 591, '아래 접속 로그에서 읽어낼 수 있는 내용으로 옳지 않은 것은?', '설정: middleware.ts 에는 matcher 가 없고, 함수 안에서 외부 인증 API 를 부른다(평균 120ms). /pricing 은 빌드 시 정적으로 생성된 페이지다.

```
GET /pricing                middleware 128ms  → 정적 HTML 응답
GET /_next/static/app.js    middleware 124ms  → 정적 파일 응답
GET /dashboard (프리페치)    middleware 131ms  → RSC 페이로드 응답
GET /favicon.ico            middleware 119ms  → 파일 응답
```', 'OBJECTIVE'),
       (3728, 591, '아래 접근 제어 구성에 대한 설명으로 옳은 것은?', '```tsx
// middleware.ts
import { NextRequest, NextResponse } from "next/server";

export function middleware(req: NextRequest) {
  const token = req.cookies.get("session")?.value;
  if (!token) return NextResponse.redirect(new URL("/login", req.url));
  return NextResponse.next();
}

export const config = { matcher: ["/dashboard/:path*"] };
```

/dashboard 아래의 서버 컴포넌트와 라우트 핸들러에는 별도의 세션 검사 코드가 없다.', 'OBJECTIVE'),
       (3729, 591, '아래 빌드 결과를 만들어 낸 App Router 폴더 표기 방식의 이름은?', '```
Route (app)                    Source
┌ ○ /login                     app/(auth)/login/page.tsx
├ ○ /signup                    app/(auth)/signup/page.tsx
├ ○ /dashboard                 app/(shop)/dashboard/page.tsx
└ ○ /orders                    app/(shop)/orders/page.tsx
```

app/(auth)/layout.tsx 는 가운데 정렬된 카드 화면을, app/(shop)/layout.tsx 는 상단 내비게이션과 장바구니를 렌더링한다. 두 layout.tsx 는 서로를 감싸지 않는다.', 'SUBJECTIVE'),
       (3730, 591, '아래 동작을 만들어 낸 미들웨어 반환값의 이름은?', '쿠키의 언어 값이 ko 인 접속자가 /about 을 요청했을 때 관찰된 것

- 브라우저 주소창은 /about 그대로다.
- 네트워크 탭에는 /about 요청 하나뿐이고, 3xx 응답도 두 번째 요청도 없다.
- 화면에 그려진 것은 app/ko/about/page.tsx 의 내용이다.
- 같은 처리를 거치지 않은 접속자는 같은 주소에서 app/about/page.tsx 의 내용을 본다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3725
(10107, 3725, 'app/loading.tsx → app/layout.tsx → app/template.tsx → app/error.tsx → app/dashboard/layout.tsx → settings/page.tsx', '로딩 화면이 전체를 덮는 모습만 보고 가장 바깥이라 오해한 것. loading.tsx 는 자기 세그먼트를 Suspense 로 감쌀 뿐이라 루트 레이아웃·템플릿보다 안쪽에 들어간다.', false),
(10108, 3725, 'app/layout.tsx → app/template.tsx → app/error.tsx → app/loading.tsx → app/dashboard/layout.tsx → settings/page.tsx', '한 세그먼트 안에서는 레이아웃 → 템플릿 → 에러 경계 → 서스펜스 순으로 자동 중첩되고, 그 안쪽에 하위 세그먼트의 레이아웃과 페이지가 이어 붙는다.', true),
(10109, 3725, 'app/template.tsx → app/layout.tsx → app/error.tsx → app/loading.tsx → app/dashboard/layout.tsx → settings/page.tsx', '템플릿이 레이아웃보다 바깥이라는 오해. 같은 위치에 둘 다 있으면 레이아웃의 children 자리에 템플릿이 들어가므로 레이아웃이 템플릿을 감싼다.', false),
(10110, 3725, 'app/layout.tsx → app/template.tsx → app/dashboard/layout.tsx → app/error.tsx → app/loading.tsx → settings/page.tsx', '하위 레이아웃이 상위의 에러·로딩보다 먼저 붙는다는 오해. app/ 의 error.tsx·loading.tsx 는 dashboard 세그먼트까지 감싸므로 하위 레이아웃보다 바깥에 놓인다.', false),

-- 문제 3726
(10111, 3726, 'count 는 3 그대로이고 mounted 도 더 찍히지 않는다.', '파일 내용이 같으니 동작도 같다는 오해. App Router 에서는 파일명이 곧 역할이라, template.tsx 가 되는 순간 내비게이션마다 새 인스턴스가 붙는다.', false),
(10112, 3726, 'count 는 3 그대로이고 mounted 만 한 번 더 찍힌다.', '재마운트를 단순 리렌더링으로 오해한 것. 빈 의존성 배열의 useEffect 가 다시 도는 것은 새로 마운트됐다는 뜻이고, 그러면 useState 도 초기값으로 되돌아간다.', false),
(10113, 3726, 'count 는 0으로 돌아가지만 mounted 는 처음 한 번만 찍힌 채 그대로다.', '상태 초기화와 마운트를 따로 떼어 본 것. 상태가 0이 된 이유가 언마운트 뒤 새 인스턴스가 붙었기 때문이므로, 그 인스턴스에서 이펙트도 다시 실행된다.', false),
(10114, 3726, 'count 는 0으로 돌아가고 mounted 가 한 번 더 찍힌다.', '템플릿은 내비게이션마다 언마운트 후 새로 마운트된다. 그래서 useState 는 초기값 0으로 돌아가고, 빈 의존성 배열의 useEffect 도 새 인스턴스에서 다시 실행된다.', true),

-- 문제 3727
(10115, 3727, '미들웨어는 캐시 조회와 라우트 매칭이 끝난 뒤 실행되므로, 미리 만들어 둔 /pricing 의 응답 시간에는 영향을 주지 않는다.', '실행 순서가 거꾸로다. 미들웨어는 파일시스템 라우트 매칭·캐시 조회보다 먼저 돌기 때문에, 로그의 /pricing 도 128ms 를 쓴 뒤에야 정적 HTML 을 받는다.', true),
(10116, 3727, 'matcher 를 두지 않아 정적 자산과 파비콘 요청까지 인증 API 호출을 거치고 있다.', 'matcher 가 없으면 모든 요청에 실행된다. 그래서 _next/static/app.js·favicon.ico 요청도 120ms 대를 쓰고 있고, 이 경로들을 matcher 에서 제외하면 사라지는 비용이다.', false),
(10117, 3727, '사용자가 아직 누르지 않은 링크의 프리페치 요청에도 실행돼 인증 API 호출이 미리 발생한다.', '로그의 /dashboard 는 프리페치인데도 미들웨어가 131ms 를 썼다. 프리페치도 같은 경로로 들어오는 요청이라 matcher 로 걸러내지 않으면 그대로 실행된다.', false),
(10118, 3727, '인증 API 호출을 미들웨어 밖으로 옮기면 /pricing 응답 시간에서 120ms 안팎을 덜어낼 수 있다.', '128ms 중 대부분이 외부 호출 대기다. 세션 검증을 데이터에 접근하는 서버 컴포넌트나 라우트 핸들러로 옮기면 정적 페이지 요청은 미들웨어를 바로 통과한다.', false),

-- 문제 3728
(10119, 3728, '미들웨어에서 쿠키를 읽으려면 렌더링 API 인 cookies() 를 써야 하므로 위 코드는 요청 처리 중 오류가 난다.', '미들웨어는 렌더링 컨텍스트 밖에서 돌기 때문에 cookies()·headers() 같은 렌더링 API 를 오히려 쓸 수 없다. req.cookies 로 읽는 위 코드가 정상적인 방식이다.', false),
(10120, 3728, '세션을 데이터베이스 드라이버로 직접 조회하도록 바꿔도 기본 런타임 그대로 동작한다.', '14/15 미들웨어의 기본 실행 환경은 Edge 런타임이라 네이티브 DB 드라이버 같은 Node.js API 를 쓸 수 없다. DB 조회가 필요하면 fetch 로 별도 API 를 부르거나 뒤로 미룬다.', false),
(10121, 3728, '쿠키의 유효성까지는 확인하지 않으므로, 만료된 session 쿠키만 남아 있어도 대시보드 데이터가 그대로 응답된다.', '위 코드는 쿠키가 있는지만 본다. 미들웨어는 낙관적 검사로 리다이렉트를 빨리 처리하는 자리이고, 실제 인가는 데이터에 접근하는 서버 컴포넌트·라우트 핸들러에서 다시 해야 한다.', true),
(10122, 3728, '요청 헤더를 조작해 미들웨어를 건너뛰는 우회는 원리상 불가능하므로 이 구성만으로 인가가 끝난다.', '미들웨어를 유일한 방어선으로 보는 오해다. 2025년 초 특정 내부 헤더로 미들웨어를 우회하는 취약점 CVE-2025-29927 이 공개돼 15.2.3 등에서 패치됐다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1198, 3729, '라우트 그룹,라우트그룹,route group,route groups,routegroup,경로 그룹', '괄호로 감싼 폴더 이름은 URL 세그먼트로 쓰이지 않는다. 그래서 주소는 /login·/dashboard 로 유지되면서 묶음마다 다른 layout.tsx 를 둘 수 있고, 로그인 전후처럼 껍데기가 다른 화면을 같은 깊이의 URL 로 나눌 때 쓴다. 밑줄로 시작하는 프라이빗 폴더(_components)는 라우팅 자체에서 빠진다는 점, @modal 같은 병렬 라우트는 한 URL 안에 독립 슬롯을 여러 개 두는 것이라는 점과 구분한다.'),
       (1199, 3730, 'rewrite,리라이트,NextResponse.rewrite,재작성,URL 재작성', '브라우저에 이동을 알리지 않고 서버가 처리할 경로만 바꿨기 때문에 주소창과 요청 횟수가 그대로다. 다국어 분기, A/B 테스트, 레거시 서버 프록시가 대표적인 쓰임이다. 3xx 상태 코드를 내려 주소창이 바뀌고 브라우저가 새 요청을 보내는 redirect, 경로를 그대로 둔 채 헤더·쿠키만 손대고 통과시키는 next 와 구분한다.');

-- =====================================================
-- Lesson 749: 병렬 라우트와 Edge 런타임 제약
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4673, 749, '아래 폴더 구성에서 브라우저 주소창에 직접 입력해 화면을 열 수 있는 URL은?', '```
app/
  layout.tsx
  (marketing)/
    pricing/
      page.tsx
  dashboard/
    layout.tsx
    settings/
      page.tsx
  blog/
    _drafts/
      page.tsx
```

위에 적힌 파일이 전부이며, 그 밖의 예약 파일은 두지 않았다.', 'OBJECTIVE'),
       (4674, 749, '아래 코드 한 줄을 추가한 뒤 빌드 결과가 달라졌다. 이 변화에 대한 설명으로 옳은 것은?', '```tsx
// app/layout.tsx
import { cookies } from "next/headers";

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const theme = (await cookies()).get("theme")?.value ?? "light";   // 이 줄을 추가했다
  return (
    <html lang="ko" data-theme={theme}>
      <body>{children}</body>
    </html>
  );
}
```

```
추가 전                          추가 후
○  /          (Static)          ƒ  /          (Dynamic)
○  /pricing   (Static)          ƒ  /pricing   (Dynamic)
○  /docs      (Static)          ƒ  /docs      (Dynamic)
```

/pricing·/docs 의 page.tsx 는 한 글자도 고치지 않았다.', 'OBJECTIVE'),
       (4675, 749, '아래 구성에서 getUser() 가 예외를 던졌을 때 사용자가 보게 되는 화면은?', '```
app/
  layout.tsx
  error.tsx            전역 오류 화면
  dashboard/
    error.tsx          대시보드 오류 화면
    layout.tsx
    page.tsx
```

```tsx
// app/dashboard/layout.tsx (서버 컴포넌트)
export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const user = await getUser();   // 여기서 예외가 던져진다
  return (
    <section>
      <b>{user.name}</b>
      {children}
    </section>
  );
}
```

두 error.tsx 는 모두 "use client" 로 시작하는 정상적인 파일이다.', 'OBJECTIVE'),
       (4676, 749, '아래 미들웨어를 배포한 뒤 나타난 증상의 원인으로 옳은 것은?', '```tsx
// middleware.ts
import { NextRequest, NextResponse } from "next/server";

export function middleware(req: NextRequest) {
  const token = req.cookies.get("session")?.value;
  if (!token) {
    const url = req.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }
  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
```

증상

- 세션 쿠키가 있는 사용자는 모든 화면이 정상이다.
- 세션 쿠키가 없는 사용자가 /login 을 열면 로그인 화면이 뜨지 않고 브라우저가 ERR_TOO_MANY_REDIRECTS 를 표시한다.', 'OBJECTIVE'),
       (4677, 749, '아래 화면 동작을 만들어 낸 App Router 라우팅 기능의 이름은?', '한 대시보드 화면을 점검하며 적어 둔 기록

- 주소는 /dashboard 하나뿐인데 팀 활동 영역과 지표 영역이 한 화면에 나란히 그려진다.
- 지표 API 가 느린 날에는 지표 자리에만 스켈레톤이 3초쯤 떠 있고, 팀 활동 영역은 먼저 그려져 스크롤까지 된다.
- 지표 API 가 500 을 내면 그 자리에만 다시 시도 버튼이 뜨고, 팀 활동 영역은 아무 일 없다는 듯 그대로 보인다.
- app/dashboard/layout.tsx 는 children 외에 두 개의 props 를 더 받아 좌우에 배치한다.', 'SUBJECTIVE'),
       (4678, 749, '아래 빌드 실패와 확인 기록이 가리키는, middleware.ts 코드가 실제로 돌아간 실행 환경의 이름은?', '세션을 직접 조회하려고 middleware.ts 에서 데이터베이스 드라이버를 import 했더니 배포 빌드가 실패했다.

```
$ next build

./middleware.ts
Module not found: Can''t resolve ''net''

Import trace for requested module:
  ./node_modules/pg/lib/connection.js
  ./middleware.ts
```

원인을 좁히려고 확인한 것

- 같은 import 문을 app/dashboard/page.tsx 로 옮기면 빌드도 조회도 정상이다.
- middleware.ts 안에서 typeof process.versions?.node 를 찍으면 undefined 가 나오는데, crypto.subtle 로 하는 JWT 서명 검증과 fetch 호출은 잘 된다.
- 드라이버 대신 fetch 로 내부 인증 API 를 부르도록 바꾸면 middleware.ts 에서도 빌드가 통과한다.
- middleware.ts 에 export const config = { runtime: "nodejs" } 를 추가하면(15.5 기준) 같은 import 로도 빌드가 통과한다.
- 드라이버 버전과 next.config 는 건드리지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4673
(12635, 4673, '/marketing/pricing', '괄호로 감싼 폴더 이름은 URL 세그먼트로 쓰이지 않는다. (marketing) 은 레이아웃을 나누고 폴더를 정리할 뿐이라 주소에 나타나지 않으므로 이 URL 은 404 다.', false),
(12636, 4673, '/pricing', '(marketing) 이 주소에서 빠지므로 page.tsx 의 경로는 /pricing 이 된다. 세그먼트에 page.tsx 가 있어야 URL 로 열 수 있다는 조건도 이 경로만 만족한다.', true),
(12637, 4673, '/dashboard', 'layout.tsx 만 있는 세그먼트는 진입 지점이 아니다. page.tsx 는 하위 settings 에만 있어 /dashboard/settings 는 열리지만 /dashboard 자체는 404 다.', false),
(12638, 4673, '/blog/_drafts', '밑줄로 시작하는 프라이빗 폴더는 라우팅에서 제외된다. 안에 page.tsx 가 있어도 URL 세그먼트가 되지 않아 초안 화면은 주소로 열 수 없다.', false),

-- 문제 4674
(12639, 4674, '빌드 표식만 바뀌었을 뿐이라 /pricing 은 요청 때 미리 만들어 둔 HTML 을 그대로 내려준다.', 'ƒ 는 요청 시점에 서버에서 렌더링한다는 뜻이라 미리 만들어 둔 HTML 자체가 없어진다. 표식이 바뀌면 /pricing 도 요청마다 렌더링 비용을 치른다.', false),
(12640, 4674, '루트 레이아웃은 요청마다 한 번만 렌더링되므로 쿠키를 읽지 않는 /docs 는 ○ 로 남는다.', '본문의 빌드 결과와 정면으로 어긋난다. 루트 레이아웃은 모든 경로를 감싸므로 그 안에서 요청 정보를 읽으면 감싸인 경로가 전부 동적 렌더링으로 끌려 들어간다.', false),
(12641, 4674, '같은 쿠키를 middleware.ts 에서 req.cookies 로 읽어도 세 경로가 똑같이 ƒ 로 바뀐다.', '미들웨어는 렌더링 밖에서 요청을 가로채는 자리라 페이지의 정적·동적 판정에 관여하지 않는다. 판정은 렌더링 도중 요청 정보를 읽었는지로만 갈린다.', false),
(12642, 4674, '추가한 줄을 쿠키가 필요한 하위 컴포넌트로 내리면 세 경로 모두 다시 ○ 로 빌드된다.', '동적 렌더링은 요청 정보를 읽은 컴포넌트가 포함된 경로에만 번진다. 개인화를 루트 레이아웃에서 화면 안쪽으로 내리는 것이 정적 빌드를 되찾는 표준 방법이다.', true),

-- 문제 4675
(12643, 4675, '루트 레이아웃 안에서 app/error.tsx 의 전역 오류 화면이 그려진다.', '예외를 던진 app/dashboard/layout.tsx 를 감싸는 가장 가까운 에러 경계는 상위 세그먼트의 app/error.tsx 다. 루트 레이아웃은 남고 그 안쪽이 통째로 오류 화면으로 바뀐다.', true),
(12644, 4675, '대시보드 자리에 app/dashboard/error.tsx 의 대시보드 오류 화면이 그려진다.', '같은 폴더에 있으니 잡아 줄 것이라는 오해다. error.tsx 는 자기 세그먼트의 layout.tsx 안쪽에 놓이므로, 자기를 감싸는 레이아웃에서 난 예외는 잡지 못하고 위로 넘긴다.', false),
(12645, 4675, 'app/dashboard/error.tsx 와 app/error.tsx 의 오류 화면이 겹쳐 함께 그려진다.', '예외가 모든 경계에 전달된다고 본 오해다. 예외는 가장 가까이에서 잡은 경계 한 곳에서만 처리되고 거기서 멈추므로 두 오류 화면이 같이 그려지는 일은 없다.', false),
(12646, 4675, '두 error.tsx 를 모두 건너뛰고 브라우저 기본 오류 화면이 표시된다.', '서버 컴포넌트의 예외는 못 잡는다고 본 오해다. 서버에서 던진 예외도 클라이언트 에러 경계로 전달된다. 기본 화면이 뜨는 경우는 루트 레이아웃 자체가 실패할 때다.', false),

-- 문제 4676
(12647, 4676, 'redirect 의 기본 상태 코드가 308 이라 브라우저가 첫 응답을 캐시해 계속 같은 곳으로 보낸다.', '상태 코드 탓으로 돌린 오해다. NextResponse.redirect 의 기본값은 307 이고, 영구 이동이라 해도 목적지가 자기 자신을 되돌려보내지 않으면 순환은 생기지 않는다.', false),
(12648, 4676, 'matcher 에서 _next/static 을 빼 로그인 화면의 스크립트가 내려오지 못해 요청이 되풀이된다.', '정적 자산을 미들웨어 실행에서 빼는 것은 불필요한 실행을 막으려는 권장 설정이다. 제외해도 파일은 그대로 응답되므로 리다이렉트 순환의 원인이 될 수 없다.', false),
(12649, 4676, 'matcher 가 /login 도 포함해, 쿠키 없는 /login 요청이 다시 /login 으로 보내지는 순환이 생긴다.', '정규식이 정적 자산만 빼고 나머지를 전부 잡는다. 목적지인 /login 요청에도 같은 검사가 걸려 토큰 없는 사용자는 끝없이 되돌려보내진다. /login 을 제외 목록에 넣어야 한다.', true),
(12650, 4676, '미들웨어가 캐시 조회 뒤에 실행돼 리다이렉트 응답이 캐시에 남아 다음 요청에도 되풀이된다.', '실행 시점을 거꾸로 본 오해다. 미들웨어는 캐시 조회·라우트 매칭보다 먼저 돈다. 순환은 캐시가 아니라 목적지 자체가 다시 리다이렉트 대상이라 생긴다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1514, 4677, '병렬 라우트,병렬라우트,병렬 라우팅,패러렐 라우트,parallel routes,parallel route,parallelroutes', '폴더 이름을 @team·@metrics 처럼 @ 로 시작하면 그 폴더는 URL 에 나타나지 않고 같은 레이아웃의 독립된 슬롯이 된다. 그래서 주소는 /dashboard 하나인데 layout.tsx 가 children 외에 슬롯들을 props 로 받아 한 화면에 함께 배치할 수 있다. 슬롯마다 loading.tsx·error.tsx 를 따로 둘 수 있어 한쪽만 스켈레톤이 뜨고 한쪽만 다시 시도 버튼으로 바뀌는 기록이 나온 것이다. URL 을 바꾸지 않고 레이아웃만 나누는 라우트 그룹 (marketing), 라우팅에서 아예 빠지는 프라이빗 폴더 _components 와 구분한다.'),
       (1515, 4678, 'Edge 런타임,Edge런타임,엣지 런타임,엣지런타임,에지 런타임,Edge Runtime,Edge', '미들웨어는 요청을 가로채는 자리라 가볍게 돌도록 Edge 런타임에서 실행된다. 여기에는 net·fs 같은 Node.js 내장 모듈이 없어 네이티브 소켓을 여는 DB 드라이버는 번들 단계에서 net 을 찾지 못하고 실패한다. 반대로 fetch·Web Crypto 같은 웹 표준 API 는 제공되므로 crypto.subtle 로 하는 JWT 서명 검증과 내부 API 호출은 그대로 된다. process.versions.node 가 undefined 인 것, 같은 import 가 서버 컴포넌트인 app/dashboard/page.tsx 에서는 통과하는 것, runtime 을 nodejs 로 지정하면 통과하는 것이 모두 이 실행 환경이 Node.js 런타임이 아님을 가리킨다. 15.5 부터 미들웨어의 Node.js 런타임 선택이 안정화됐고, 16 에서는 파일 이름이 proxy.ts 로 바뀌며 Node.js 런타임으로 고정됐다. 다만 DB 조회가 필요한 세션 검증은 런타임을 바꾸기보다 데이터에 접근하는 서버 컴포넌트·라우트 핸들러로 미루는 것이 원칙이다.');

-- =====================================================
-- Lesson 907: App Router 경로 매칭·레이아웃 유지와 미들웨어 위치 규칙
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5621, 907, '아래 구성에서 요청 URL 에 따른 서버 콘솔 출력과 렌더링 결과로 옳은 것은?', '```
app/
  layout.tsx
  docs/
    [...slug]/
      page.tsx
  shop/
    [[...slug]]/
      page.tsx
```

```tsx
// docs/[...slug]/page.tsx 와 shop/[[...slug]]/page.tsx 의 내용은 같다
export default async function Page({
  params,
}: {
  params: Promise<{ slug?: string[] }>;
}) {
  const { slug } = await params;
  console.log(slug);
  return <p>{slug?.join(" > ") ?? "목록"}</p>;
}
```

위에 적힌 파일이 전부이며, app/docs/page.tsx 와 app/shop/page.tsx 는 없다.', 'OBJECTIVE'),
       (5622, 907, '아래 코드를 배포한 뒤 나타난 증상의 원인으로 옳은 것은?', '```tsx
// middleware.ts
import { NextRequest, NextResponse } from "next/server";

export function middleware(req: NextRequest) {
  const headers = new Headers(req.headers);
  headers.set("x-pathname", req.nextUrl.pathname);
  return NextResponse.next({ request: { headers } });
}
```

```tsx
// app/dashboard/layout.tsx (서버 컴포넌트)
import Link from "next/link";
import { headers } from "next/headers";

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = (await headers()).get("x-pathname");
  const on = (href: string) => (pathname === href ? "on" : "");

  return (
    <div>
      <nav>
        <Link href="/dashboard/orders" className={on("/dashboard/orders")}>주문</Link>
        <Link href="/dashboard/users" className={on("/dashboard/users")}>회원</Link>
      </nav>
      {children}
    </div>
  );
}
```

증상

- 주소창에 /dashboard/orders 를 입력해 열면 주문 메뉴가 강조된다.
- 메뉴의 회원 링크를 누르면 본문은 회원 화면으로 바뀌는데, 강조는 주문 메뉴에 남아 있다.
- 그 상태에서 새로고침하면 그제야 회원 메뉴가 강조된다.', 'OBJECTIVE'),
       (5623, 907, '세션 쿠키가 없는 사용자가 /dashboard 를 요청했을 때 일어나는 일로 옳은 것은?', '```
my-app/
  middleware.ts
  app/
    layout.tsx
    login/
      page.tsx
    dashboard/
      middleware.ts
      page.tsx
```

```tsx
// my-app/middleware.ts
import { NextRequest, NextResponse } from "next/server";

export function middleware(req: NextRequest) {
  const res = NextResponse.next();
  res.headers.set("x-request-id", crypto.randomUUID());
  return res;
}
```

```tsx
// my-app/app/dashboard/middleware.ts
import { NextRequest, NextResponse } from "next/server";

export function middleware(req: NextRequest) {
  if (!req.cookies.get("session")) {
    return NextResponse.redirect(new URL("/login", req.url));
  }
  return NextResponse.next();
}
```

두 파일 모두 config(matcher) 를 export 하지 않았고, 빌드는 오류 없이 끝났다.', 'OBJECTIVE'),
       (5624, 907, '화면 주소 /products 와 JSON 응답을 모두 유지하면서 아래 빌드 오류를 없애는 수정으로 옳은 것은?', '```
app/
  layout.tsx
  products/
    page.tsx      상품 목록 화면
    route.ts      상품 목록 JSON (export async function GET)
```

```
$ next build

Error: Conflicting route and page at /products: route at /products/route and page at /products/page
```

모바일 앱은 이 JSON 응답을 GET 으로 계속 받아야 하며, 앱이 요청할 주소는 설정에서 바꿀 수 있다.', 'OBJECTIVE'),
       (5625, 907, '아래 폴더 구성과 관찰 결과가 보여 주는 App Router 라우팅 패턴의 이름은?', '```
app/
  layout.tsx
  feed/
    layout.tsx          상단 탭 메뉴
    page.tsx            사진 피드 목록
    (..)photo/
      [id]/
        page.tsx        간단한 미리보기
  photo/
    [id]/
      page.tsx          사진 상세 화면
```

| 들어온 방법 | 주소창 | 그려진 화면 |
|---|---|---|
| /feed 에서 사진 7번 썸네일 Link 를 클릭 | /photo/7 | 상단 탭 메뉴 + 간단한 미리보기 |
| 위 상태에서 새로고침 | /photo/7 | 사진 상세 화면 (상단 탭 메뉴 없음) |
| /photo/7 공유 링크를 새 탭에서 열기 | /photo/7 | 사진 상세 화면 (상단 탭 메뉴 없음) |', 'SUBJECTIVE'),
       (5626, 907, '아래 리뷰 의견이 가리키는, app/shop 폴더에 새로 둘 예약 파일의 이름은?', '요구사항: 상점 안에서 페이지를 옮길 때마다 fade-in 애니메이션이 처음부터 다시 재생되고, 조회 로그가 이동 한 번에 한 번씩 남아야 한다.

```tsx
// app/shop/layout.tsx
import ShopNav from "./shop-nav";
import PageShell from "./page-shell";

export default function ShopLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <ShopNav />
      <PageShell>{children}</PageShell>
    </>
  );
}
```

```tsx
// app/shop/page-shell.tsx
"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";

export default function PageShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  useEffect(() => {
    logPageView(pathname);
  }, [pathname]);

  return <div key={pathname} className="fade-in">{children}</div>;
}
```

리뷰 의견

> PageShell 을 걷어 내고 같은 JSX 를 app/shop 의 예약 파일 하나로 옮기세요. 그 파일에서는 usePathname 과 key 없이 useEffect(() => logPageView(location.pathname), []) 만 써도 요구사항이 그대로 충족됩니다. ShopNav 는 layout.tsx 에 남겨 두면 됩니다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5621
(15163, 5621, '/docs 는 콘솔에 undefined 를 찍고 렌더링되며, /docs/a 는 [ ''a'' ] 를 찍는다.', '[...slug] 를 선택적 캐치올과 혼동한 것. 대괄호 한 겹인 캐치올은 세그먼트가 하나 이상 있어야 매칭되므로, app/docs/page.tsx 도 없는 이 구성에서 /docs 는 404 가 된다.', false),
(15164, 5621, '/shop 은 404 가 되고, /shop/a 부터 콘솔에 [ ''a'' ] 를 찍으며 렌더링된다.', '선택적 캐치올을 일반 캐치올처럼 본 오해. 대괄호를 두 겹으로 감싼 [[...slug]] 는 세그먼트가 하나도 없는 /shop 까지 함께 매칭하므로 404 가 나지 않는다.', false),
(15165, 5621, '/docs/a 는 콘솔에 a 를, /docs/a/b 는 남은 경로를 이은 문자열 a/b 를 찍는다.', '남은 경로를 문자열 하나로 받는다고 본 오해. 캐치올은 경로를 세그먼트 단위로 나눈 배열로 넘기므로 /docs/a 는 [ ''a'' ], /docs/a/b 는 [ ''a'', ''b'' ] 가 찍히고 화면엔 a > b 가 그려진다.', false),
(15166, 5621, '/shop 은 콘솔에 undefined 를 찍고 렌더링되며, /shop/a/b 는 [ ''a'', ''b'' ] 를 찍는다.', '[[...slug]] 는 선택적 캐치올이라 세그먼트가 없는 /shop 도 매칭하고, 이때 slug 가 undefined 라 화면엔 "목록"이 그려진다. 세그먼트가 있으면 캐치올과 똑같이 나뉜 배열로 받는다.', true),

-- 문제 5622
(15167, 5622, 'Link 이동은 서버를 거치지 않는 전환이라 미들웨어가 실행되지 않고, 그래서 x-pathname 값도 바뀌지 않는다.', 'Link 이동도 바뀐 세그먼트를 그리려고 서버에 RSC 페이로드를 요청하고, matcher 가 없는 미들웨어는 이 요청에도 실행돼 새 경로 값을 만든다. 문제는 그 값을 레이아웃이 다시 읽지 않는다는 데 있다.', false),
(15168, 5622, 'Link 이동 때는 바뀐 세그먼트만 새로 렌더링하고 공유 레이아웃은 다시 렌더링하지 않아, 처음 읽은 경로 값으로 강조가 고정된다.', '부분 렌더링 때문에 DashboardLayout 은 첫 요청 때 읽은 x-pathname 으로 멈춰 있고, 새로고침처럼 전체를 다시 그릴 때만 갱신된다. 활성 메뉴는 usePathname 을 쓰는 작은 클라이언트 컴포넌트로 떼어 내야 한다.', true),
(15169, 5622, 'headers() 값이 빌드 시점에 한 번 계산돼 정적 HTML 에 들어갔으므로, 어떤 요청에서도 같은 경로가 읽힌다.', 'headers() 를 읽으면 그 경로는 요청 시점에 렌더링되는 동적 렌더링이 된다. 새로고침하면 회원 메뉴가 제대로 강조된다는 증상도 값이 빌드 때 고정된 것이 아님을 보여 준다.', false),
(15170, 5622, '미들웨어가 바꾼 것은 응답 헤더라서, 서버 레이아웃의 headers() 로는 x-pathname 값을 읽어 올 수 없다.', 'NextResponse.next({ request: { headers } }) 는 렌더링으로 넘어가는 요청 헤더를 바꾼다. 주소창에 입력해 처음 열었을 때 주문 메뉴가 강조된 것 자체가 레이아웃이 값을 읽고 있다는 증거다.', false),

-- 문제 5623
(15171, 5623, '/login 으로 리다이렉트되고, 그 응답에 x-request-id 헤더가 붙는다.', '루트 파일과 하위 폴더 파일이 차례로 모두 실행된다고 본 오해. 미들웨어는 레이아웃처럼 폴더마다 쌓이지 않고, 프로젝트 루트(또는 src/)의 middleware.ts 하나만 실행된다.', false),
(15172, 5623, '/login 으로 리다이렉트되고, 응답에 x-request-id 헤더는 붙지 않는다.', '가까운 세그먼트의 파일이 상위 파일을 대신한다고 본 오해. app/ 안의 middleware.ts 는 예약 파일이 아닌 평범한 모듈이라 실행되지 않고, 루트 파일은 matcher 가 없어 이 요청에도 실행된다.', false),
(15173, 5623, '대시보드 화면이 그대로 응답되고, 응답에 x-request-id 헤더가 붙는다.', '미들웨어는 프로젝트당 루트의 파일 하나만 인식한다. 그래서 헤더를 붙이는 루트 파일만 돌고 쿠키 검사는 실행되지 않는다. 경로별 검사는 루트 파일 안에서 pathname 이나 matcher 로 나눠야 한다.', true),
(15174, 5623, '대시보드 화면이 그대로 응답되고, 응답에 x-request-id 헤더는 붙지 않는다.', '루트 파일이 app/ 밖에 있어 인식되지 않는다고 본 오해. 미들웨어는 오히려 app/ 과 같은 높이인 프로젝트 루트(또는 src/)에 두는 파일이고, matcher 가 없어 모든 요청에 실행돼 헤더가 붙는다.', false),

-- 문제 5624
(15175, 5624, 'route.ts 를 app/api/products/route.ts 로 옮기고, 앱이 요청할 주소를 /api/products 로 바꾼다.', 'route.ts 와 page.tsx 는 같은 세그먼트에 함께 둘 수 없다. 핸들러를 다른 세그먼트로 옮기면 화면은 /products, JSON 은 /api/products 로 주소가 갈라져 충돌이 사라진다.', true),
(15176, 5624, 'route.ts 를 app/(api)/products/route.ts 로 옮겨, 라우트 그룹으로 화면과 따로 묶는다.', '괄호로 감싼 폴더는 URL 에 나타나지 않으므로 옮겨도 핸들러 주소는 여전히 /products 다. 폴더만 나뉘었을 뿐 같은 경로에 route 와 page 가 겹쳐 빌드는 계속 실패한다.', false),
(15177, 5624, 'route.ts 에서 GET 을 지우고 POST 만 export 해, 화면 요청과 메서드가 겹치지 않게 한다.', '메서드가 겹쳐서 난 충돌로 본 오해. 제약은 파일 단위라 route.ts 가 어떤 메서드를 export 하든 page.tsx 와 같은 세그먼트에 있으면 충돌한다. GET 으로 받는 앱도 JSON 을 못 받게 된다.', false),
(15178, 5624, 'route.ts 를 app/products/_api/route.ts 로 옮겨, 화면 폴더 안에 핸들러를 함께 둔다.', '밑줄로 시작하는 프라이빗 폴더는 하위 전체가 라우팅에서 빠진다. 빌드 오류는 사라지지만 핸들러가 어떤 주소로도 열리지 않아 앱이 JSON 을 받지 못한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1830, 5625, '인터셉팅 라우트,인터셉팅 라우팅,인터셉팅라우트,인터셉트 라우트,인터셉션 라우트,intercepting routes,intercepting route,interceptingroutes,intercepting routing,가로채기 라우트,라우트 가로채기,라우트 인터셉팅', '폴더 이름 앞의 (..) 는 한 단계 위 세그먼트의 경로를 지금 레이아웃 안으로 가로채 오는 표기다. feed 에서 한 단계 올라가면 app 루트이므로 feed/(..)photo 는 /photo/[id] 를 가로챈다. 그래서 피드 안에서 Link 로 이동하면 주소는 /photo/7 로 바뀌면서도 feed/layout.tsx 의 상단 탭 메뉴 안에 미리보기가 그려지고, 새로고침이나 새 탭처럼 주소로 처음부터 요청하면 가로채지 않은 원래의 app/photo/[id]/page.tsx 가 그려진다. (.) 는 같은 단계, (..)(..) 는 두 단계 위, (...) 는 app 루트 기준이다. 실무에서는 병렬 라우트(@modal)와 함께 써서 피드 위에 모달로 띄우는 경우가 많다. 괄호 모양이 비슷해도 URL 에서 폴더 이름을 빼기만 하는 라우트 그룹 (shop), 한 레이아웃에 독립 슬롯을 여럿 두는 병렬 라우트 자체와는 구분한다.'),
       (1831, 5626, 'template.tsx,template,템플릿,template.js,template.jsx,template 파일,템플릿 파일,app/shop/template.tsx', 'template.tsx 는 레이아웃과 같은 자리에서 children 을 감싸지만, 내비게이션마다 기존 인스턴스를 언마운트하고 새로 마운트한다. 그래서 빈 의존성 배열의 useEffect 도 이동할 때마다 다시 실행되고, fade-in 클래스가 붙은 DOM 도 새로 만들어져 애니메이션이 처음부터 재생된다. key 를 경로로 바꿔 끼우는 PageShell 의 방식을 파일 규칙이 대신해 주는 셈이며, useEffect 를 쓰므로 이 파일도 "use client" 로 시작해야 한다. 반대로 layout.tsx 는 내비게이션 동안 인스턴스와 상태를 유지하므로 ShopNav 처럼 계속 남아 있어야 하는 UI 에 맞고, 같은 위치에 둘 다 있으면 레이아웃이 템플릿을 감싼다. 로딩 UI 를 위한 loading.tsx, 오류 화면을 위한 error.tsx 와도 구분한다.');
