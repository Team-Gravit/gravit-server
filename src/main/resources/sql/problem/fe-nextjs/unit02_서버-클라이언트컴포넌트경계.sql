-- Unit: 서버·클라이언트 컴포넌트 경계 (Unit ID: 159)
-- Chapter: Next.js (Chapter ID: 15)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (585, 159, '번들 포함 범위와 server-only'),
       (743, 159, '서드파티 래핑과 RSC 페이로드 직렬화'),
       (901, 159, 'App Router 경계 배치와 흔한 오류 해결');

-- =====================================================
-- Lesson 585: 번들 포함 범위와 server-only
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3689, 585, '아래 모듈 구성에서 각 파일이 어느 번들에 포함되는지 판단한 것으로 옳은 것은?', '```
app/dashboard/page.tsx    (지시자 없음)   → components/chart.tsx, components/filters.tsx 를 import
components/filters.tsx    "use client"    → components/select.tsx, lib/format.ts 를 import
components/select.tsx     (지시자 없음)
components/chart.tsx      (지시자 없음)   → lib/format.ts 를 import
lib/format.ts             (지시자 없음)
```', 'OBJECTIVE'),
       (3690, 585, '아래 코드에서 발생한 빌드 에러를 해결하는 방법으로 옳은 것은?', '```tsx
// components/tab-panel.tsx
"use client";
import { useState } from "react";
import { ReportTable } from "./report-table"; // 내부에서 DB를 직접 조회한다

export function TabPanel() {
  const [open, setOpen] = useState(true);
  return (
    <div>
      <button onClick={() => setOpen((v) => !v)}>토글</button>
      {open && <ReportTable />}
    </div>
  );
}
```

빌드 시 아래 에러가 난다. 열고 닫는 토글 동작은 그대로 유지해야 한다.

```
Error: You''re importing a component that needs "next/headers".
That only works in a Server Component.
```', 'OBJECTIVE'),
       (3691, 585, '아래 코드에서 경계를 넘겨 전달하는 props에 대한 설명으로 옳은 것은?', '```tsx
// app/orders/page.tsx  (서버 컴포넌트)
import { OrderList } from "./order-list"; // "use client"가 선언된 파일

export default async function Page() {
  const rows = await db.order.findMany();
  const updatedAt = new Date();
  const compare = (a, b) => a.total - b.total;

  return <OrderList rows={rows} updatedAt={updatedAt} compare={compare} />;
}
```', 'OBJECTIVE'),
       (3692, 585, '아래 측정 결과에 대한 설명으로 옳지 않은 것은?', '같은 기사 페이지를 두 가지 구성으로 만들어 측정했다. 페이지는 Header, ArticleBody(마크다운을 HTML로 변환), LikeButton으로 이뤄진다.

| 구성 | "use client" 선언 위치 | 클라이언트 JS 번들 | 초기 HTML |
|---|---|---|---|
| A | app/article/page.tsx | 182KB | 서버에서 생성 |
| B | components/like-button.tsx | 41KB | 서버에서 생성 |', 'OBJECTIVE'),
       (3693, 585, '아래 상황에서 팀이 lib/report-query.ts 첫 줄에 추가한 import의 대상 패키지 이름은?', 'lib/report-query.ts는 서버에서만 쓰려고 만든 DB 조회 모듈이다. 새로 합류한 팀원이 이 파일을 클라이언트 컴포넌트에서 import했는데 빌드는 아무 말 없이 통과했고, 실제 페이지를 연 뒤에야 알아보기 힘든 런타임 에러가 떠 원인을 찾는 데 반나절이 걸렸다.

팀은 lib/report-query.ts 첫 줄에 패키지 하나를 import하는 한 줄을 넣었다. 그 뒤로는 같은 import를 시도하는 순간 빌드가 그 자리에서 멈췄고, 어느 클라이언트 모듈이 이 파일을 끌어왔는지가 함께 출력됐다.', 'SUBJECTIVE'),
       (3694, 585, '아래 상황에서 개발자가 환경 변수 이름 앞에 붙인 접두사는?', '관리자 화면의 클라이언트 컴포넌트에서 process.env.PAYMENT_API_KEY를 읽었더니 브라우저 콘솔에 undefined가 찍혔다. 개발자가 환경 변수 이름 앞에 짧은 접두사를 붙여 다시 배포하자 값이 정상적으로 읽혔다.

그런데 배포된 JS 파일을 내려받아 검색해 보니 키 문자열이 평문 그대로 들어 있었다. 반면 서버 컴포넌트에서 같은 값을 읽던 코드는 접두사 없이도 처음부터 잘 동작하고 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3689
(10011, 3689, 'select.tsx는 지시자가 없으므로 서버 컴포넌트로 남아 클라이언트 번들에서 빠진다.', '기준은 지시자 유무가 아니라 import 경로다. 경계 파일인 filters.tsx가 select.tsx를 import하므로 select.tsx도 클라이언트 번들로 함께 끌려간다.', false),
(10012, 3689, 'format.ts는 서버 번들과 클라이언트 번들 양쪽에 모두 포함된다.', '서버 컴포넌트인 chart.tsx와 클라이언트 컴포넌트인 filters.tsx가 둘 다 import하는 공유 모듈이라, 서버용·클라이언트용으로 각각 번들에 실린다.', true),
(10013, 3689, 'filters.tsx를 import한 page.tsx도 클라이언트 컴포넌트로 바뀐다.', '경계는 import하는 쪽으로 거슬러 올라가지 않는다. 서버 컴포넌트는 클라이언트 컴포넌트를 import해도 그대로 서버 컴포넌트로 남는다.', false),
(10014, 3689, 'chart.tsx는 filters.tsx와 같은 화면에 그려지므로 클라이언트 번들에 함께 들어간다.', '한 화면에 같이 그려지는지는 기준이 아니다. 번들 포함 여부는 모듈 그래프의 import 방향으로만 정해지고, chart.tsx는 서버 컴포넌트가 import한다.', false),

-- 문제 3690
(10015, 3690, 'report-table.tsx 첫 줄에 "use client"를 선언해 두 파일의 실행 위치를 맞춘다.', 'ReportTable을 클라이언트로 만들면 DB 조회 코드가 브라우저 번들로 새어 나가고, next/headers 같은 서버 전용 API는 여전히 쓸 수 없어 에러가 그대로 남는다.', false),
(10016, 3690, 'tab-panel.tsx의 "use client"를 지워 TabPanel을 서버 컴포넌트로 되돌린다.', 'TabPanel은 useState로 토글 상태를 들고 있어 서버 컴포넌트가 될 수 없다. 지시자를 지우면 훅을 쓸 수 없다는 다른 에러로 바뀔 뿐이다.', false),
(10017, 3690, 'TabPanel을 async 함수로 선언하고 ReportTable을 await로 렌더링한다.', '클라이언트 컴포넌트는 async 함수로 선언할 수 없다. 게다가 import로 이미 경계가 전파된 뒤라 await를 붙여도 ReportTable은 클라이언트 쪽에 남는다.', false),
(10018, 3690, 'TabPanel이 children을 받게 고치고, 상위 서버 컴포넌트에서 ReportTable을 끼워 넣는다.', 'import는 경계를 전파하지만, props로 받은 엘리먼트는 서버에서 이미 렌더링된 결과라 경계를 넘지 않는다. 토글 상태는 TabPanel에 그대로 남는다.', true),

-- 문제 3691
(10019, 3691, 'compare 때문에 렌더링이 실패하며, 정렬 기준을 값으로 바꿔 넘기면 해결된다.', '일반 함수는 RSC 페이로드에 담기지 못한다. sortBy="total" 같은 직렬화 가능한 값을 넘기고, 비교 함수는 클라이언트 컴포넌트 안에서 고르게 하면 된다.', true),
(10020, 3691, 'updatedAt은 Date 인스턴스라 직렬화되지 않으므로 문자열로 바꿔야 넘길 수 있다.', 'RSC 페이로드는 JSON보다 넓은 범위를 지원해 Date·Map·Set·BigInt를 그대로 넘길 수 있다. JSON.stringify의 제약과 혼동한 것이다.', false),
(10021, 3691, 'rows는 DB에서 읽은 객체 배열이라 RSC 페이로드에 담기지 못한다.', '원시값으로 이뤄진 일반 객체와 배열은 직렬화 대상이다. 행이 많으면 페이로드가 무거워질 뿐, 경계 통과 자체가 막히지는 않는다.', false),
(10022, 3691, 'compare를 useCallback으로 감싸면 참조가 고정돼 그대로 넘길 수 있다.', 'useCallback은 클라이언트 컴포넌트의 리렌더링을 다루는 훅이라 서버 컴포넌트에서 쓸 수 없고, 참조를 고정해도 함수 본체는 직렬화되지 않는다.', false),

-- 문제 3692
(10023, 3692, '구성 A에서는 상호작용이 없는 ArticleBody의 마크다운 변환 코드까지 번들에 실린다.', '참인 진술. 경계가 페이지 최상단에 있으면 그 아래로 import되는 모듈이 전부 클라이언트 번들에 포함된다. 변환 로직까지 끌려 들어가 182KB가 됐다.', false),
(10024, 3692, '구성 B의 Header는 서버에서만 실행돼 41KB 안에 코드가 들어가지 않는다.', '참인 진술. 경계를 잎으로 내리면 Header는 서버에서만 실행되고 출력 HTML만 남는다. 번들이 41KB로 줄어든 몫의 상당 부분이 여기서 나온다.', false),
(10025, 3692, '구성 B의 LikeButton은 브라우저에서만 렌더링되므로 초기 HTML에는 담기지 않는다.', '거짓. 표를 보면 두 구성 모두 초기 HTML을 서버에서 만든다. 클라이언트 컴포넌트도 서버에서 한 번 사전 렌더링된 뒤 브라우저에서 하이드레이션된다.', true),
(10026, 3692, '두 구성의 차이는 렌더링 위치가 아니라 브라우저가 내려받아 하이드레이션할 JS의 양이다.', '참인 진술. 두 구성 모두 서버에서 HTML을 만들고, 달라지는 것은 전송되는 JS 양이다. A는 182KB를 받아 하이드레이션해야 해 초기 비용이 크다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1186, 3693, 'server-only,server only,serveronly,"server-only",import "server-only"', '서버 전용 모듈 맨 위에 import "server-only"를 두면, 그 모듈이 클라이언트 번들 그래프에 끌려 들어가는 순간 빌드가 실패한다. 런타임까지 기다리지 않고 빌드 시점에 막아 준다는 점이 핵심이다. 반대 방향(서버에서 브라우저 전용 코드 사용)을 막는 client-only 패키지가 따로 있고, "use client"는 차단 장치가 아니라 경계를 선언하는 지시자라 역할이 다르다. 근본 해결은 children 패턴으로 경계를 다시 잡는 것이고, server-only는 잘못된 import를 조기에 드러내는 안전장치다.'),
       (1187, 3694, 'NEXT_PUBLIC_,NEXT_PUBLIC,next_public_,next_public', 'Next.js는 NEXT_PUBLIC_ 접두사가 붙은 환경 변수만 빌드 시점에 클라이언트 번들로 인라인한다. 접두사가 없으면 브라우저에서 undefined가 되고, 붙이면 값이 번들에 평문으로 박혀 누구나 열어 볼 수 있다. 그래서 결제 키 같은 비밀 값에는 절대 붙이면 안 되고, 서버 컴포넌트나 서버 액션에서 읽는 값은 접두사 없이 두는 것이 맞다. 접두사는 런타임 접근 권한을 주는 장치가 아니라 번들 포함 여부를 정하는 스위치라는 점이 구분 포인트다.');

-- =====================================================
-- Lesson 743: 서드파티 래핑과 RSC 페이로드 직렬화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4637, 743, '아래 코드에서 서버 터미널에 남은 오류가 발생한 원인으로 옳은 것은?', '```tsx
// components/theme-toggle.tsx
"use client";
import { useState } from "react";

const initial = localStorage.getItem("theme") ?? "light";

export function ThemeToggle() {
  const [theme, setTheme] = useState(initial);
  return <button onClick={() => setTheme(theme === "light" ? "dark" : "light")}>{theme}</button>;
}
```

페이지를 요청하자 브라우저에는 아무것도 그려지지 않았고 서버 터미널에 아래 로그가 남았다.

```
ReferenceError: localStorage is not defined
    at eval (components/theme-toggle.tsx:5:17)
    at renderToReadableStream (react-dom/server)
```', 'OBJECTIVE'),
       (4638, 743, '아래 코드에서 comments prop이 경계를 넘는 방식으로 옳은 것은?', '```tsx
// app/feed/page.tsx  (지시자 없음)
import { CommentPanel } from "./comment-panel"; // 첫 줄에 "use client"가 선언된 파일

export default async function Page() {
  const post = await db.post.find(1);      // 평균 40ms
  const comments = db.comment.findMany(1); // 평균 2,400ms, await를 걸지 않았다
  return <CommentPanel post={post} comments={comments} />;
}
```

CommentPanel은 comments를 use()로 읽고, 그 부분만 Suspense로 감싸 두었다.', 'OBJECTIVE'),
       (4639, 743, '아래 상황에서 빌드를 통과시키는 방법으로 옳은 것은?', '상품 목록 페이지 app/products/page.tsx는 지시자가 없는 파일로, DB에서 상품 300건을 읽어 표로 그린다. 여기에 npm으로 받은 캐러셀 라이브러리의 Carousel을 추가했더니 빌드가 멈췄다. 라이브러리 내부는 useState와 useEffect를 쓰지만 패키지 어느 파일에도 지시자가 없고, 사내 정책상 패키지 코드는 고칠 수 없다.

```
Error: useState only works in Client Components.
Add the "use client" directive at the top of the file to use it.
```

DB 조회와 표 그리기는 지금처럼 서버에 남겨야 한다.', 'OBJECTIVE'),
       (4640, 743, '아래 구성에 대한 설명으로 옳지 않은 것은?', '한 페이지를 이루는 파일과 그 관계를 정리한 표다.

| 파일 | "use client" | 상위 파일과 이어지는 방식 |
|---|---|---|
| app/report/page.tsx | 없음 | 라우트 최상위. DB에서 매출을 읽는다 |
| components/tab-shell.tsx | 있음 | page.tsx가 import |
| components/tab-label.tsx | 없음 | tab-shell.tsx가 import |
| components/revenue-table.tsx | 없음 | page.tsx가 렌더링해 tab-shell.tsx에 children으로 전달 |
| lib/format-won.ts | 없음 | tab-label.tsx와 revenue-table.tsx가 각각 import |', 'OBJECTIVE'),
       (4641, 743, '아래 상황에서 브라우저가 내려받은 응답 데이터를 부르는 이름은?', '목록에서 상세 화면으로 이동할 때 개발자 도구 네트워크 탭을 열어 보니, 주소 끝에 _rsc 쿼리 문자열이 붙은 요청이 하나 오간다. 응답의 Content-Type은 text/html이 아니고 내용은 아래처럼 줄마다 번호가 붙은 조각들이다.

```
0:["$","div",null,{"className":"detail","children":["$","$L1",null,{}]}]
1:I[4823,["static/chunks/app/detail/page.js"],"DetailChart"]
2:"2026-09-18T02:11:04.000Z"
```

화면은 새로고침 없이 바뀌고 열어 둔 입력창에 쳐 둔 값도 그대로 남는다. 1번 줄은 DetailChart가 담긴 JS 파일의 위치만 가리킬 뿐, 서버에서만 돌던 조회 코드는 이 응답 어디에도 들어 있지 않다.', 'SUBJECTIVE'),
       (4642, 743, '아래 상황에서 onSave에 다시 전달하게 된 함수를 부르는 이름은?', '장바구니 담기 버튼은 "use client"가 선언된 파일에 있다. 처음에는 상위 서버 컴포넌트에서 onSave={(id) => db.cart.add(id)}를 그대로 넘겼더니 Functions cannot be passed directly to Client Components 오류가 났다.

같은 일을 하는 함수를 서버 쪽 파일에 따로 두고 함수 본문 첫 줄에 지시자 한 줄을 넣은 뒤 같은 자리에 넘기자 오류가 사라졌다. 빌드된 브라우저 JS를 모두 뒤져도 db.cart.add를 부르는 코드는 없었고, 버튼을 누르면 네트워크 탭에 POST 요청이 하나 생기면서 본문에는 짧은 식별자 문자열과 인자만 실려 나갔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4637
(12539, 4637, '지시자가 파일 맨 위에 있어도 훅을 import한 모듈은 번들러가 서버 그래프에 남겨 두기 때문이다.', '지시자가 맨 위에 있으면 그 모듈부터 클라이언트 번들 경계가 시작된다. 훅을 import했다고 서버 그래프에 남는 일은 없고, 로그가 가리키는 위치도 useState가 아니라 모듈 최상위 줄이다.', false),
(12540, 4637, '이 파일은 클라이언트 번들에 들어가지만 서버에서 HTML을 한 번 만드는 과정에서도 실행되며, 그때는 브라우저 전역 객체가 없다.', '지시자는 브라우저에서만 실행하라는 뜻이 아니다. 클라이언트 컴포넌트도 서버에서 한 번 사전 렌더링되므로 모듈 최상위의 브라우저 저장소 접근이 그 실행에 걸린다. 접근을 useEffect 안으로 옮겨 마운트 이후로 미뤄야 한다.', true),
(12541, 4637, '상위 서버 컴포넌트가 이 파일을 import한 탓이므로, 상위 파일에도 지시자를 붙이면 오류가 사라진다.', '서버 컴포넌트가 클라이언트 컴포넌트를 import하는 것은 정상 방향이다. 상위에 지시자를 붙여 경계를 위로 올려도 그 트리는 여전히 서버에서 한 번 HTML로 만들어지므로 같은 오류가 반복된다.', false),
(12542, 4637, '빌드할 때 번들러가 모듈 최상위 코드를 정적 분석하면서 실제로 한 번 실행해 보기 때문이다.', '번들러는 최상위 코드를 실행하지 않는다. 로그 끝줄의 renderToReadableStream이 말해 주듯 오류는 빌드가 아니라 서버가 요청을 받아 HTML을 만드는 렌더링 중에 났다.', false),

-- 문제 4638
(12543, 4638, '함수 호출이 돌려준 값이라 경계를 넘지 못하고 함수는 전달할 수 없다는 오류로 렌더링이 중단된다.', '경계 통과 여부는 값의 종류로 갈린다. 넘기지 못하는 것은 함수 자체이고, 함수가 돌려준 Promise는 서버 응답에 담을 수 있는 값이다.', false),
(12544, 4638, '서버가 2,400ms를 기다려 배열로 바꾼 뒤 post와 함께 완성된 화면을 한 번에 내려보낸다.', 'await를 걸지 않았으므로 Page는 댓글 조회가 끝나기를 기다리지 않는다. 기다린다면 그 자리를 Suspense로 감싸 둘 이유도 없다. 느린 조회 하나가 화면 전체를 붙잡는 구성이 아니다.', false),
(12545, 4638, '직렬화되지 않아 undefined로 도착하므로 클라이언트에서 같은 목록을 한 번 더 요청해야 한다.', 'props가 조용히 사라지는 일은 없다. 넘길 수 없는 값이면 오류로 알려 주고, Promise는 넘길 수 있으므로 브라우저가 같은 조회를 되풀이할 필요가 없다.', false),
(12546, 4638, '아직 결과가 없는 상태 그대로 실려 나가고, 조회가 끝나면 그 자리만 나중에 채워진다.', '서버가 보내는 응답에는 Promise를 그대로 담을 수 있다. post가 담긴 앞부분이 먼저 도착해 Suspense 대체 화면이 뜨고, 2,400ms짜리 조회가 끝나면 이어지는 조각이 도착해 use()가 그 값을 읽는다.', true),

-- 문제 4639
(12547, 4639, 'Carousel을 다시 내보내기만 하는 파일을 새로 만들어 그 파일 첫 줄에 지시자를 붙이고, 페이지는 그 파일에서 가져다 쓴다.', '지시자는 우리 저장소의 파일에만 붙일 수 있으니 패키지를 감싸는 얇은 파일을 경계로 삼는다. 경계가 캐러셀 아래로만 퍼져 상품 조회와 표 그리기는 서버에 그대로 남는다.', true),
(12548, 4639, 'page.tsx 첫 줄에 지시자를 붙여 페이지 전체를 클라이언트 컴포넌트로 바꾼다.', '캐러셀 오류는 사라지지만 경계가 페이지 꼭대기로 올라가 상품 300건을 읽는 조회 코드까지 클라이언트 번들로 끌려간다. 서버 전용 코드가 번들에 실리면서 그 자리에서 다른 오류가 난다.', false),
(12549, 4639, 'page.tsx에서 Carousel을 렌더링한 뒤 children으로 클라이언트 컴포넌트에 끼워 넣는다.', 'children 패턴은 서버에서 렌더링을 이미 마친 결과를 끼워 넣는 방법이다. 캐러셀은 내부에서 훅을 쓰므로 서버에서 렌더링하는 단계 자체가 불가능해 같은 오류가 그대로 난다.', false),
(12550, 4639, 'next/dynamic으로 Carousel을 ssr: false 옵션과 함께 불러와 지시자 없이 클라이언트 전용으로 만든다.', 'ssr: false는 서버 컴포넌트에서 허용되지 않는 옵션이라 page.tsx에 그대로 넣으면 또 다른 오류가 난다. 어느 방법을 쓰든 지시자를 붙인 파일이 경계로 먼저 있어야 한다.', false),

-- 문제 4640
(12551, 4640, 'tab-label.tsx는 지시자가 없지만 클라이언트 번들에 포함된다.', '참인 진술. 경계는 import를 따라 아래로 퍼지므로, 지시자가 있는 tab-shell.tsx가 import한 파일은 지시자를 따로 붙이지 않아도 클라이언트 번들에 실린다.', false),
(12552, 4640, 'page.tsx는 클라이언트 컴포넌트를 import했지만 서버 컴포넌트로 남아 매출 조회를 계속할 수 있다.', '참인 진술. 경계는 import한 쪽으로 거슬러 올라가지 않는다. 서버 컴포넌트가 클라이언트 컴포넌트를 import하는 것은 정상 방향이라 page.tsx의 DB 조회는 서버에 그대로 남는다.', false),
(12553, 4640, 'revenue-table.tsx는 tab-shell.tsx 안쪽에 그려지므로 클라이언트 번들에도 함께 들어간다.', '거짓인 진술. 번들 포함 여부는 화면에서 어디에 그려지는지가 아니라 import 방향으로 정해진다. 이 파일은 서버 컴포넌트가 렌더링해 children으로 넘긴 결과라 경계를 넘지 않는다.', true),
(12554, 4640, 'format-won.ts는 서버 쪽과 클라이언트 쪽 양쪽에서 쓰여 번들에 두 번 실린다.', '참인 진술. 서버에 남는 revenue-table.tsx와 클라이언트로 끌려간 tab-label.tsx가 같은 모듈을 import하므로, 공유 모듈로서 서버용·클라이언트용 번들에 각각 들어간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1502, 4641, 'RSC 페이로드,RSC payload,rsc페이로드,React Server Component payload,리액트 서버 컴포넌트 페이로드,서버 컴포넌트 페이로드', '서버 컴포넌트를 렌더링한 결과 트리를 직렬화한 형식이 RSC 페이로드다. 완성된 HTML이 아니라 트리를 설명하는 데이터라서, 브라우저는 지금 화면이 들고 있던 상태를 유지한 채 바뀐 부분만 갈아 끼울 수 있다. 입력창 값이 남는 이유가 이것이다. 1번 줄의 I[...]처럼 클라이언트 컴포넌트는 코드가 아니라 어느 청크에 있는지를 가리키는 참조로 들어가고, 실제 코드는 클라이언트 번들에서 따로 내려온다. 서버 컴포넌트의 출력물이 HTML과 이 페이로드인 반면, 클라이언트 컴포넌트의 출력물은 사전 렌더링된 HTML과 하이드레이션용 JS라는 점에서 구분된다. 브라우저가 서버 컴포넌트 코드 자체를 받아 실행하는 것이 아니라는 점도 함께 기억해 두면 좋다.'),
       (1503, 4642, '서버 액션,서버액션,server action,server actions,use server,"use server"', '함수 본문 첫 줄에 "use server"를 붙여 서버에서만 실행되도록 표시한 함수가 서버 액션이다. 경계를 넘을 때 함수 본문이 아니라 참조 식별자가 직렬화되므로, 브라우저 번들에는 DB 호출 코드가 실리지 않고 버튼을 누르면 그 식별자와 인자를 담은 POST 요청이 서버로 간다. 실제 실행은 서버에서 일어난다. 파일 맨 위에 쓰는 "use client"가 클라이언트 번들의 경계를 여는 선언인 것과 달리 "use server"는 서버에서 실행될 함수를 밖에 내주는 표시라 방향이 반대다. 지시자 없는 일반 함수는 참조로도 넘어가지 못하고 오류가 난다는 점에서도 구분된다.');

-- =====================================================
-- Lesson 901: App Router 경계 배치와 흔한 오류 해결
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5585, 901, '아래 코드에서 난 오류를 해결하는 방법으로 옳은 것은?', '```tsx
// components/profile-card.tsx
"use client";
import { useState } from "react";

export default async function ProfileCard({ userId }: { userId: string }) {
  const [open, setOpen] = useState(false);
  const user = await fetch(`https://api.example.com/users/${userId}`).then((r) => r.json());

  return (
    <section>
      <h2>{user.name}</h2>
      <button onClick={() => setOpen((v) => !v)}>자세히</button>
      {open && <p>{user.bio}</p>}
    </section>
  );
}
```

페이지를 열자 아래 오류가 났다. 자세히 버튼으로 소개 글을 펼치고 접는 동작은 그대로 유지해야 한다.

```
Error: async/await is not yet supported in Client Components, only Server Components.
```', 'OBJECTIVE'),
       (5586, 901, '아래 코드를 렌더링할 때 경계를 넘지 못해 오류를 일으키는 prop은?', '```tsx
// app/cart/page.tsx  (지시자 없음)
import { CartSummary } from "./cart-summary"; // 첫 줄에 "use client"가 선언된 파일
import { Money } from "@/lib/money"; // amount·currency 필드와 format() 메서드를 가진 클래스
import { getCoupons } from "@/lib/coupon";

export default function Page() {
  const quantities = new Map([["A-1", 2], ["B-7", 1]]);
  const total = new Money(38000, "KRW");
  const orderNo = 9007199254740993n;
  const coupons = getCoupons(); // await를 걸지 않았다

  return (
    <CartSummary
      quantities={quantities}
      total={total}
      orderNo={orderNo}
      coupons={coupons}
    />
  );
}
```', 'OBJECTIVE'),
       (5587, 901, '아래 레이아웃 구성에서 각 컴포넌트가 실행되는 방식에 대한 설명으로 옳은 것은?', '```tsx
// app/providers.tsx
"use client";
import { createContext, useState } from "react";

export const ThemeContext = createContext({ theme: "light", toggle: () => {} });

export function Providers({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState("light");
  const toggle = () => setTheme((t) => (t === "light" ? "dark" : "light"));
  return <ThemeContext.Provider value={{ theme, toggle }}>{children}</ThemeContext.Provider>;
}
```

```tsx
// app/layout.tsx  (지시자 없음)
import { Providers } from "./providers";
import { NoticeBar } from "@/components/notice-bar"; // 지시자 없음, DB에서 공지를 읽는다

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <Providers>
          <NoticeBar />
          {children}
        </Providers>
      </body>
    </html>
  );
}
```', 'OBJECTIVE'),
       (5588, 901, '아래 페이지의 모든 기능이 동작하면서 클라이언트 번들에 들어가는 파일이 최소가 되도록 "use client"를 선언할 파일을 고른 것은?', '상품 상세 페이지를 이루는 파일과 각 파일이 하는 일이다. 지금은 어느 파일에도 "use client"가 없다.

| 파일 | 하는 일 | 이 파일을 import하는 곳 |
|---|---|---|
| app/product/page.tsx | DB에서 상품과 리뷰를 조회한다 | 라우트 최상위 |
| components/gallery.tsx | 상품 이미지 12장을 격자로 그린다 | page.tsx |
| components/zoom-button.tsx | onClick으로 이미지 확대 여부를 바꾼다 | gallery.tsx |
| components/review-list.tsx | 리뷰 마크다운을 HTML로 변환해 그린다 | page.tsx |
| components/qty-stepper.tsx | useState로 주문 수량을 올리고 내린다 | page.tsx |', 'OBJECTIVE'),
       (5589, 901, '아래 상황에서 버튼이 눌리기 시작하기 전까지 브라우저에서 진행되던 과정을 부르는 이름은?', '기사 페이지의 LikeButton은 첫 줄에 "use client"가 선언된 컴포넌트다. 느린 네트워크 환경으로 측정하자 0.6초에 기사 본문과 "좋아요 12" 버튼이 화면에 나타났지만, 3.4초까지는 버튼을 아무리 눌러도 숫자가 바뀌지 않았다. 그사이 네트워크 탭에는 클라이언트 JS 182KB를 내려받는 요청이 이어졌고, 그 스크립트의 실행이 끝난 직후부터 버튼이 눌렸다.

브라우저 설정에서 JS 실행을 끄고 같은 페이지를 열면 글과 버튼은 똑같이 보이지만 끝까지 눌리지 않는다. 버튼 옆에 Date.now()로 만든 값을 찍어 본 날에는 콘솔에 아래 경고가 떴다.

```
Warning: Text content did not match. Server: "1727000000123" Client: "1727000000981"
```', 'SUBJECTIVE'),
       (5590, 901, '아래 상황에서 개발자가 차트 컴포넌트를 불러오는 방식을 바꾸는 데 쓴 Next.js 모듈의 이름은?', 'components/sales-panel.tsx는 첫 줄에 "use client"가 선언된 파일로, npm으로 받은 차트 라이브러리의 SalesChart를 import해 그린다. 이 라이브러리는 import되는 순간 모듈 최상위에서 window.devicePixelRatio를 읽는다. 페이지를 요청하자 서버 터미널에 아래 로그가 남았다.

```
ReferenceError: window is not defined
    at Object.<anonymous> (node_modules/acme-chart/dist/index.js:3:21)
```

라이브러리 코드는 고칠 수 없어 문제의 줄을 useEffect 안으로 옮길 수도 없었다. 개발자는 SalesChart를 가져오던 import 문을 지우고, Next.js가 제공하는 한 모듈의 함수로 같은 컴포넌트를 다시 불러오면서 옵션 하나를 주었다.

그러자 서버 로그의 오류가 사라졌고, 서버가 보낸 첫 HTML에는 차트 자리에 "차트 불러오는 중" 문구만 담겼다. 차트 코드는 별도의 JS 청크로 나뉘어 브라우저가 따로 내려받았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5585
(15067, 5585, '파일 첫 줄의 "use client"를 지워 ProfileCard를 async 서버 컴포넌트로 되돌린다.', 'ProfileCard는 useState와 onClick으로 펼침 상태를 다루므로 서버 컴포넌트가 될 수 없다. 지시자를 지우면 훅과 이벤트 핸들러를 쓸 수 없다는 다른 오류로 바뀔 뿐이다.', false),
(15068, 5585, 'ProfileCard를 쓰는 쪽에서 Suspense로 감싸 조회가 끝날 때까지 대체 화면을 보여 준다.', 'Suspense는 기다리는 동안 보여 줄 화면을 정할 뿐, 클라이언트 컴포넌트를 async 함수로 선언하는 것 자체를 허용해 주지 않는다. 감싸도 같은 오류가 난다.', false),
(15069, 5585, '상위 서버 컴포넌트에서 사용자 정보를 받아 props로 넘기고, ProfileCard에서는 async와 await를 뺀다.', 'async 컴포넌트는 서버 컴포넌트만 가능하다. 조회는 서버에서 await로 끝내고 결과(일반 객체)를 넘기면, ProfileCard는 동기 함수인 클라이언트 컴포넌트로 남아 펼침 상태를 그대로 다룬다.', true),
(15070, 5585, '파일 첫 줄의 지시자를 "use server"로 바꿔 조회는 서버에서 하고 화면 동작은 브라우저에서 다룬다.', '"use server"는 서버 액션으로 내줄 함수를 표시하는 지시자라 컴포넌트를 둘로 나눠 주지 않는다. 이 파일은 클라이언트 컴포넌트가 아니게 되어 useState와 onClick을 쓸 수 없다.', false),

-- 문제 5586
(15071, 5586, 'quantities', 'Map은 RSC 페이로드가 지원하는 내장 타입이라 그대로 넘어가고, 클라이언트에서도 Map으로 쓸 수 있다. JSON.stringify로는 빈 객체가 되는 것과 혼동한 것이다.', false),
(15072, 5586, 'total', '클래스 인스턴스는 프로토타입과 메서드를 담아 보낼 방법이 없어 경계를 넘지 못한다. amount와 currency만 담은 일반 객체로 바꿔 넘기고, 표시 형식은 클라이언트 쪽에서 만든다.', true),
(15073, 5586, 'orderNo', 'BigInt도 RSC 페이로드가 지원하는 값이라 Number 범위를 넘는 주문 번호도 그대로 전달된다. JSON이 BigInt를 다루지 못한다는 제약을 경계에 그대로 옮겨 온 오해다.', false),
(15074, 5586, 'coupons', 'await를 걸지 않은 Promise도 경계를 넘을 수 있는 값이다. 함수 자체가 아니라 함수가 돌려준 값이므로 오류가 나지 않고, 클라이언트에서 use()로 결과를 꺼내 쓴다.', false),

-- 문제 5587
(15075, 5587, 'layout.tsx는 클라이언트 컴포넌트인 Providers를 import하므로 함께 클라이언트 번들에 들어간다.', '경계는 import하는 쪽으로 거슬러 올라가지 않는다. 서버 컴포넌트가 클라이언트 컴포넌트를 import하는 것은 정상 방향이라 layout.tsx는 서버 컴포넌트로 남는다.', false),
(15076, 5587, 'NoticeBar는 Providers 안쪽에 그려지므로 클라이언트 컴포넌트가 되어 DB를 읽지 못한다.', '그려지는 위치가 아니라 import 방향이 기준이다. NoticeBar는 서버 컴포넌트인 layout.tsx가 import해 서버에서 렌더링한 뒤 children으로 넘기므로 서버에 남아 DB를 읽는다.', false),
(15077, 5587, 'Providers는 브라우저에서만 실행되므로 첫 HTML의 body 안쪽은 JS가 실행되기 전까지 비어 있다.', '클라이언트 컴포넌트도 서버에서 한 번 사전 렌더링된다. Providers와 그 안의 NoticeBar·페이지 내용은 첫 HTML에 이미 담겨 오고, 브라우저에서는 그 위에서 상태 관리가 시작될 뿐이다.', false),
(15078, 5587, 'NoticeBar 안에서 useContext(ThemeContext)로 테마를 읽으려면 그 부분을 "use client" 파일로 떼어 내야 한다.', 'NoticeBar는 Provider 안쪽에 있어도 서버 컴포넌트라 훅을 쓸 수 없다. 테마 상태는 브라우저 쪽 Providers가 들고 있으므로, 값을 읽는 작은 부분만 클라이언트 컴포넌트로 분리해야 한다.', true),

-- 문제 5588
(15079, 5588, 'zoom-button.tsx, qty-stepper.tsx', '상태와 이벤트 핸들러가 필요한 잎 두 곳에만 선언하면 된다. gallery.tsx는 서버 컴포넌트로 남은 채 zoom-button.tsx를 import할 수 있고, 조회와 마크다운 변환 코드는 번들에 실리지 않는다.', true),
(15080, 5588, 'gallery.tsx, qty-stepper.tsx', '기능은 동작하지만 경계가 한 단계 위로 올라가 상호작용이 없는 gallery.tsx까지 번들에 실린다. zoom-button.tsx는 지시자가 없어도 끌려 들어가므로 번들 파일이 하나 더 많다.', false),
(15081, 5588, 'page.tsx 하나', '아래로 import되는 모든 파일이 번들로 끌려가 마크다운 변환 코드까지 브라우저로 향하고, DB 조회는 브라우저에서 할 수 없어 오류가 난다. 한 곳에 몰아 선언하면 편하지만 경계가 가장 위에 놓인다.', false),
(15082, 5588, 'zoom-button.tsx, qty-stepper.tsx, gallery.tsx, page.tsx', '클라이언트 컴포넌트를 import하는 파일에도 지시자가 필요하다고 오해한 것이다. 서버 컴포넌트는 클라이언트 컴포넌트를 그대로 import할 수 있고, 여기에 붙이면 번들만 커지고 page.tsx의 DB 조회가 막힌다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1818, 5589, '하이드레이션,hydration,하이드레이트,hydrate,하이드레이팅,hydrating,리하이드레이션,rehydration,수화', '서버가 사전 렌더링한 HTML은 모양만 갖춘 상태라 JS가 없으면 눌리지 않는다. 브라우저가 클라이언트 컴포넌트의 JS를 받아 실행하면서 이미 그려진 화면에 상태와 이벤트 핸들러를 연결하는 과정이 하이드레이션이고, 이것이 끝난 3.4초부터 버튼이 반응한다. 이때 React는 브라우저에서 한 번 더 렌더링한 결과를 서버가 만든 HTML과 맞춰 보는데, Date.now()처럼 실행할 때마다 달라지는 값이 있으면 둘이 어긋나 불일치 경고가 뜬다. 서버에서 HTML을 만드는 사전 렌더링과는 다른 단계이고, 서버 컴포넌트는 하이드레이션할 JS 자체가 없어 번들에서 빠진다는 점에서 클라이언트 컴포넌트와 갈린다. 번들이 클수록 이 과정이 길어진다는 점이 경계를 잎 쪽으로 내리는 이유이기도 하다.'),
       (1819, 5590, 'next/dynamic,next dynamic,nextdynamic,dynamic,dynamic(),next/dynamic()', 'next/dynamic의 dynamic()은 컴포넌트를 별도 청크로 떼어 나중에 불러오고, ssr: false 옵션을 주면 서버의 사전 렌더링에서 그 컴포넌트를 건너뛴다. 그래서 라이브러리가 import 시점에 window를 읽어도 서버에서는 그 코드가 아예 실행되지 않고, 첫 HTML에는 loading으로 지정한 대체 문구만 담긴다. "use client"만으로 부족했던 이유는 클라이언트 컴포넌트도 서버에서 한 번 사전 렌더링되기 때문이다. 직접 작성한 코드라면 브라우저 전역 접근을 useEffect 안으로 옮기면 충분하지만, import하는 순간 전역을 읽는 라이브러리는 import 자체를 브라우저로 미뤄야 한다. React.lazy도 코드를 나누지만 서버 렌더링을 건너뛰는 옵션이 없어 같은 문제를 풀지 못한다. App Router에서 ssr: false는 클라이언트 컴포넌트 안에서만 쓸 수 있다는 점도 함께 기억해 둔다.');
