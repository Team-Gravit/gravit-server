-- Unit: 재검증 전략 (Unit ID: 162)
-- Chapter: Next.js (Chapter ID: 15)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (588, 162, '시간 기반 만료와 태그 무효화'),
       (746, 162, '무효화 반영 시점과 웹훅 인증'),
       (904, 162, 'Next.js 재검증 설계 — 재생성 실패, 전략 선택, 태그와 경로의 무효화 범위');

-- =====================================================
-- Lesson 588: 시간 기반 만료와 태그 무효화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3707, 588, '아래 로그에서 00:05:00 요청이 5분 전에 만든 응답을 그대로 받은 이유로 옳은 것은?', '```tsx
// app/stats/page.tsx
export const revalidate = 60;
```

서버 접근 로그 — 배포 직후부터, 이 페이지로 들어온 요청만 발췌했다.

```
00:00:00  GET /stats  200  1,420ms  body-hash=A   신규 생성
00:00:30  GET /stats  200      3ms  body-hash=A
00:05:00  GET /stats  200      4ms  body-hash=A
00:05:02  GET /stats  200      3ms  body-hash=B
```

00:00:30과 00:05:00 사이에는 이 페이지로 들어온 요청이 한 건도 없었다.', 'OBJECTIVE'),
       (3708, 588, '아래 라우트의 전체 라우트 캐시가 실제로 다시 만들어지는 주기는?', '```tsx
// app/dashboard/page.tsx
export const revalidate = 3600;

async function getNotices() {
  const res = await fetch("https://api.example.com/notices", {
    next: { revalidate: 600 },
  });
  return res.json();
}

async function getTicker() {
  const res = await fetch("https://api.example.com/ticker", {
    next: { revalidate: 30 },
  });
  return res.json();
}

export default async function Page() {
  const [notices, ticker] = await Promise.all([getNotices(), getTicker()]);
  return <Dashboard notices={notices} ticker={ticker} />;
}
```

두 fetch 모두 이 페이지를 렌더링하는 동안 호출된다.', 'OBJECTIVE'),
       (3709, 588, '아래 코드에서 글 42를 수정한 뒤에도 목록 화면의 제목이 그대로인 원인으로 옳은 것은?', '```tsx
// lib/posts.ts
export async function getPostList() {
  const res = await fetch(API + "/posts", { next: { tags: ["posts"] } });
  return res.json();
}

export async function getPost(id: string) {
  const res = await fetch(API + "/posts/" + id, {
    next: { tags: ["posts", "post-" + id] },
  });
  return res.json();
}
```

```tsx
// app/actions.ts
"use server";
import { revalidateTag } from "next/cache";

export async function editPost(id: string, form: FormData) {
  await db.post.update({
    where: { id },
    data: { title: String(form.get("title")) },
  });
  revalidateTag("post-" + id);
}
```

관리자가 글 42의 제목을 고쳐 저장했다. 상세 화면 /posts/42에는 새 제목이 바로 나타나는데, 목록 화면 /posts에는 예전 제목이 계속 보인다는 제보가 이어진다.', 'OBJECTIVE'),
       (3710, 588, '아래 두 장면에 대한 설명으로 옳지 않은 것은?', '**(가) 프로필 저장**
사용자가 프로필 폼을 제출하면 서버 액션이 DB를 고친 뒤 revalidatePath("/profile")을 부른다. 사용자는 제출 직후 그 화면에서 바뀐 프로필을 곧바로 본다.

**(나) CMS 글 발행**
CMS에서 글을 발행하면 웹훅이 POST /api/revalidate를 호출하고, 그 라우트 핸들러가 revalidateTag("posts")를 부른다. 이때 /posts 화면을 이미 열어 둔 사용자는 탭을 그대로 두면 새 글을 보지 못하고, 다른 페이지로 갔다가 돌아오면 새 글을 본다.', 'OBJECTIVE'),
       (3711, 588, '아래 캐시 상태 변화를 일으킨 ⓐ 자리의 함수 이름은?', '```
// app/api/revalidate/route.ts 안에서 ⓐ("posts") 실행

[호출 전]
key=posts-list    tags=["posts"]              state=fresh
key=post-42       tags=["posts", "post-42"]   state=fresh
key=comments-42   tags=["comments"]           state=fresh
key=banner-home   tags=[]                     state=fresh

[호출 후]
key=posts-list    state=stale
key=post-42       state=stale
key=comments-42   state=fresh
key=banner-home   state=fresh
```

comments-42와 banner-home은 posts-list와 함께 /posts 화면 한 장을 그리는 데 쓰인 항목이다.', 'SUBJECTIVE'),
       (3712, 588, '아래 지표에서 B안이 A안 대신 택한 캐시 재검증 방식을 가리키는 용어는?', '같은 쇼핑몰의 상품 페이지를 두 달 동안 서로 다른 방식으로 운영했다. 두 달의 방문 수와 가격 수정 건수는 비슷했다.

| 지표 | A안 (3월) | B안 (4월) |
|---|---|---|
| 상품 페이지 설정 | `export const revalidate = 60` | 만료 시간을 두지 않음 |
| 가격을 고친 뒤 새 가격이 보이기까지 | 평균 34초, 최대 61초 | 평균 1.2초 |
| 하루 상품 페이지 재생성 횟수 | 4,120회 | 380회 |
| 가격 수정이 한 건도 없던 날의 재생성 횟수 | 4,050회 | 6회 |
| 같은 날 가격 수정 건수 | 371건 | 371건 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3707
(10059, 3707, '00:00:30 요청이 캐시를 읽으면서 만료 시각이 그 시점부터 다시 60초 뒤로 밀렸기 때문이다.', '읽을 때마다 유효 기간이 연장된다고 본 것. 만료는 캐시를 만든 시각을 기준으로 정해지고 읽기로는 늘어나지 않는다. 밀렸다 해도 00:01:30에는 이미 만료라 00:05:00이 예전 값인 이유가 설명되지 않는다.', false),
(10060, 3707, '만료된 뒤 처음 들어온 요청에는 예전 캐시를 그대로 돌려주고, 새 페이지는 그 응답 뒤 백그라운드에서 만들기 때문이다.', '00:05:00 응답이 4ms로 빠른데 값은 예전 것(A)이고 2초 뒤부터 새 값(B)이 나온 것이 그 자국이다. 사용자를 기다리게 하지 않는 대신 갱신이 한 박자 늦어, 지정한 초가 아니라 만료 후 첫 방문 뒤에 반영된다.', true),
(10061, 3707, '트래픽이 없는 동안에는 만료 카운트가 멈춰 있다가 첫 재방문 시각부터 60초를 다시 세기 때문이다.', '방문이 없으면 재생성이 일어나지 않는 것을 카운트가 멈춘다고 바꿔 읽은 것. 카운트가 00:05:00부터 다시 시작했다면 2초 뒤인 00:05:02에 새 값(B)이 나올 수 없다.', false),
(10062, 3707, '60초가 지난 캐시는 곧바로 버려지므로 00:05:00 요청이 페이지를 처음부터 다시 만들어 응답했기 때문이다.', '만료를 즉시 삭제로 본 것. 그 자리에서 다시 만들었다면 00:00:00처럼 1,420ms에 가까운 응답 시간과 새 값(B)이 나와야 하는데, 로그는 4ms에 예전 값(A)이다.', false),

-- 문제 3708
(10063, 3708, '3,600초', '라우트 세그먼트에 적은 export const revalidate가 fetch 옵션을 덮어쓴다고 본 것. 세그먼트 값은 그 라우트의 기본 주기일 뿐이고, 더 짧은 fetch 주기가 있으면 그쪽이 라우트 전체를 끌어내린다.', false),
(10064, 3708, '600초', '먼저 선언된 fetch의 주기가 라우트를 대표한다고 본 것. 선언 순서는 기준이 아니다. notices보다 짧은 ticker의 30이 남아 있는 한 600초는 라우트 주기가 될 수 없다.', false),
(10065, 3708, '30초', '한 라우트 안에 여러 revalidate 값이 섞이면 가장 짧은 값이 라우트 전체에 적용된다. ticker의 30이 이겨 페이지는 30초마다 재생성되고, 10분이면 충분했을 notices까지 같은 주기로 다시 불린다.', true),
(10066, 3708, '0초 — 요청마다 새로 생성', '값이 서로 다르면 캐시를 포기하고 동적 렌더링으로 내려간다고 본 것. 값이 섞여도 정적 렌더링은 유지되고 최소값으로 통일될 뿐이다. 0은 revalidate = 0을 직접 적었을 때의 동작이다.', false),

-- 문제 3709
(10067, 3709, '저장할 때 무효화한 태그가 상세를 만든 fetch에만 붙어 있어, 목록을 만든 fetch의 캐시는 신선한 상태로 남기 때문이다.', '무효화 대상은 인자로 준 태그가 달린 항목뿐이다. 목록 fetch에는 posts만 붙어 있어 post-42 무효화의 사정권 밖이다. 목록용 태그도 함께 무효화하거나 목록 화면 경로를 무효화해야 한다.', true),
(10068, 3709, '서버 액션에서 부른 revalidateTag는 브라우저 라우터 캐시만 지우고 서버 캐시에는 닿지 않기 때문이다.', '방향이 반대다. 서버 액션의 재검증은 서버 캐시를 오래됨으로 표시하고, 응답에 새 RSC 페이로드를 실어 라우터 캐시까지 함께 갱신한다. 라우터 캐시만 건드리는 재검증 API는 없다.', false),
(10069, 3709, '한 fetch에 태그를 두 개 붙이면 뒤에 적은 태그만 살아남아 목록용 태그가 지워지기 때문이다.', '태그는 여러 개를 붙여도 모두 살아 있어 어느 쪽으로든 무효화할 수 있다. 게다가 목록 fetch에는 태그가 하나뿐이라, 이 설명은 목록이 안 바뀐 이유가 되지 못한다.', false),
(10070, 3709, 'revalidateTag는 오래됨 표시만 남기므로 무효화된 화면은 재배포 전까지 갱신되지 않기 때문이다.', '오래됨으로 표시된 항목은 다음 요청 때 다시 만들어진다. 재배포 없이 특정 데이터만 갱신하려고 쓰는 수단이며, 실제로 상세 화면은 재배포 없이 새 제목으로 바뀌었다.', false),

-- 문제 3710
(10071, 3710, '(가)에서 제출 직후 화면이 바뀌는 것은 서버 액션 응답에 갱신된 RSC 페이로드가 함께 실려 클라이언트 라우터가 현재 화면을 다시 그리기 때문이다.', '참이다. 서버 액션에만 있는 통로다. 서버 캐시 무효화와 화면 갱신이 한 번의 왕복 안에서 끝나 폼 제출 뒤 따로 새로고침할 필요가 없다.', false),
(10072, 3710, '(가)의 revalidatePath("/profile")은 그 경로의 전체 라우트 캐시와 그 경로가 사용한 데이터 캐시를 함께 오래됨으로 표시한다.', '참이다. 경로 기반 무효화는 페이지 단위로 묶어서 버린다. 두 번째 인자에 "layout"을 주면 그 레이아웃을 공유하는 하위 경로가 모두 대상이 되어 범위가 훨씬 넓어진다.', false),
(10073, 3710, '(나)에서 다른 페이지로 갔다가 돌아왔을 때 새 글이 보이는 것은 그 내비게이션 시점에 라우터 캐시가 서버에서 새 페이로드를 받아오기 때문이다.', '참이다. 라우트 핸들러에는 브라우저에 갱신을 알릴 통로가 없어, 열어 둔 탭은 다음 내비게이션이나 router.refresh() 시점에야 새 내용을 받는다.', false),
(10074, 3710, '(나)에서 새 글이 늦게 보이는 것은 라우트 핸들러 안에서 부른 revalidateTag가 서버 캐시를 무효화하지 못하기 때문이다.', '거짓이라 이 선지가 정답이다. 서버 캐시는 웹훅이 닿은 순간 이미 오래됨으로 표시된다. 늦게 보이는 원인은 이미 열려 있던 탭의 브라우저 라우터 캐시가 그대로 남아 있는 데 있다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1192, 3711, 'revalidateTag,revalidateTag(),revalidate Tag,리밸리데이트태그,리밸리데이트 태그', '같은 화면을 그리는 데 쓰인 comments-42와 banner-home이 멀쩡한데 posts 태그가 달린 두 항목만 stale로 바뀌었다. 무효화 기준이 화면이나 경로가 아니라 데이터에 붙인 라벨이라는 뜻이다. 경로 기준인 revalidatePath였다면 그 화면이 쓴 항목이 함께 stale이 됐을 것이고, 시간 기반 만료(revalidate 옵션)는 누가 불러서가 아니라 지정한 초가 지나야 표시된다는 점에서 구분된다. stale은 삭제가 아니라서 표시된 항목은 다음 요청 때 다시 만들어진다.'),
       (1193, 3712, '온디맨드 재검증,온디맨드 리밸리데이션,온디맨드 방식,온디맨드,on-demand revalidation,on demand revalidation,ondemand revalidation,on-demand', 'A안은 값이 바뀌든 말든 시계에 맞춰 만료돼, 가격 수정이 한 건도 없던 날에도 4,050회를 다시 만들고 반영까지 최대 61초가 걸렸다. B안은 하루 재생성 횟수가 가격 수정 건수와 거의 같고 반영이 1.2초 안에 끝난다 — 시계가 아니라 변경 사건이 무효화를 촉발한다는 뜻이며, 이것이 온디맨드 재검증이다. Next.js에서는 revalidateTag(데이터 중심)와 revalidatePath(페이지 중심)가 그 수단이다. 다만 변경 시점을 내가 알 수 없는 외부 데이터에는 A안 같은 시간 기반이 여전히 맞다.');

-- =====================================================
-- Lesson 746: 무효화 반영 시점과 웹훅 인증
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4655, 746, '아래 로그에서 무효화 호출 뒤 4분 동안 페이지가 다시 만들어지지 않은 이유로 옳은 것은?', E'상품 목록 /products는 정적으로 생성되며, 가격 데이터를 가져오는 fetch에 "prices" 태그가 붙어 있다. 이 라우트에는 revalidate 값을 두지 않았다.\n\n```\n16:00:00  POST /api/revalidate  {"tag":"prices"}  200    7ms\n          -- 이후 4분간 서버 렌더링 로그 없음, CPU 3%대 유지\n16:04:00  GET  /products        200  1,240ms   ← 이 요청에서만 렌더링 로그가 찍힘\n16:04:06  GET  /products        200      5ms\n16:09:11  GET  /products        200      5ms\n```\n\n16:00:00 직전 마지막 방문은 15:58이었고, 그 뒤 16:04:00 전까지 /products로 들어온 요청은 한 건도 없었다.', 'OBJECTIVE'),
       (4656, 746, '아래 네 라우트의 캐시 설정과 하루치 관측값을 바탕으로 옳지 않은 것은?', '네 라우트 모두 정적 렌더링을 쓰며, 온디맨드 무효화(revalidateTag·revalidatePath)는 어디에서도 호출하지 않는다.

| 라우트 | 설정 | 하루 방문 수 | 하루 재생성 횟수 | 응답 시간 중앙값 |
|---|---|---|---|---|
| /news | `export const revalidate = 300` | 41,000회 | 288회 | 5ms |
| /terms | `export const revalidate = false` | 900회 | 0회 | 4ms |
| /me | `export const revalidate = 0` | 2,300회 | 매 요청 렌더 | 180ms |
| /rank | `export const revalidate = 60` | 3회 | 3회 | 6ms |', 'OBJECTIVE'),
       (4657, 746, '아래 페이지에 접속할 때마다 오류가 나는 원인으로 옳은 것은?', '```tsx
// app/products/page.tsx
import { revalidateTag } from "next/cache";
import { getProducts } from "@/lib/products";  // fetch(..., { next: { tags: ["products"] } })

export default async function Page() {
  const products = await getProducts();

  // 재고가 0인 항목이 섞여 있으면 캐시가 낡았다고 보고 그 자리에서 갱신을 건다
  if (products.some((p) => p.stock === 0)) {
    revalidateTag("products");
  }

  return <ProductList items={products} />;
}
```

같은 getProducts()를 쓰는 /search 화면은 멀쩡히 동작하고, /products만 빌드와 접속에서 모두 실패한다.', 'OBJECTIVE'),
       (4658, 746, '아래 라우트 핸들러에 빠져 있어 이 증상을 불러온 처리로 옳은 것은?', '```tsx
// app/api/revalidate/route.ts
import { NextRequest, NextResponse } from "next/server";
import { revalidateTag } from "next/cache";

export async function POST(req: NextRequest) {
  const { tag } = (await req.json()) as { tag: string };
  revalidateTag(tag);
  return NextResponse.json({ ok: true, revalidated: tag });
}
```

배포 이틀 뒤부터 이 경로로 낯선 IP에서 초당 수십 건의 POST가 들어왔다. CMS의 글 발행 건수와 웹훅 설정은 그대로인데, 상품 목록 화면의 응답 시간 중앙값이 6ms에서 900ms대로 올랐고 하루 서버 렌더링 횟수가 평소의 40배가 됐다.', 'OBJECTIVE'),
       (4659, 746, '아래 ⓐ 자리에서 부른 next/cache 함수의 이름은?', '```tsx
// app/actions.ts
"use server";

export async function fixTypo(slug: string) {
  await db.article.update({ where: { slug }, data: { /* 본문 수정 */ } });
  ⓐ("/newsroom/" + slug);
}
```

뉴스룸의 기사 화면 /newsroom/[slug]는 기사 본문·작성자·관련 기사 목록을 서로 다른 세 곳에서 가져오는데, 셋 중 어디에도 태그를 달아 두지 않았다. 예전에는 오탈자 하나를 고쳐도 평균 8분짜리 재배포를 거쳐야 새 글자가 보였다. 위 코드로 바꾼 뒤에는 저장하고 나서 첫 방문에 곧바로 고친 내용이 나왔고, 같은 시각 /newsroom 목록과 /about은 예전 캐시 그대로였다.', 'SUBJECTIVE'),
       (4660, 746, '아래 버튼이 부른 클라이언트 라우터 메서드의 이름은?', '관제 대시보드 /ops는 집계 데이터를 정적으로 캐시해 쓰고, 집계 배치가 끝날 때마다 외부에서 웹훅이 들어와 서버 캐시를 무효화한다.

- 하루 종일 같은 탭을 열어 둔 운영자는 웹훅이 다녀간 뒤에도 옛 수치를 계속 본다. 다른 메뉴로 갔다가 돌아오면 그때서야 새 수치가 나온다.
- 브라우저 새로고침(F5)을 쓰면 새 수치는 나오지만 화면 전체가 다시 그려져, 입력해 둔 기간 필터와 스크롤 위치가 초기화된다.
- 그래서 헤더에 "지금 불러오기" 버튼을 달았다. 누르면 필터와 스크롤은 그대로인 채 표의 수치만 새 값으로 바뀐다. 버튼 핸들러는 useRouter()로 얻은 객체의 메서드 하나를 부르는 것이 전부다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4655
(12587, 4655, '무효화 호출이 대상 항목을 즉시 지우기는 하지만, 새 캐시는 정해진 대기 시간이 지난 뒤 재생성 큐에서 처리되기 때문이다.', '무효화에 고정된 지연 큐가 있다고 본 것. 대기 시간이 원인이라면 재생성 시각이 호출로부터 늘 같은 간격에 찍혀야 하는데, 여기서는 방문이 들어온 16:04:00에 맞춰 일어났다. 시각을 정한 것은 큐가 아니라 요청이다.', false),
(12588, 4655, '무효화 호출은 해당 항목을 오래됨으로 표시만 하고, 실제 재생성은 그 데이터를 필요로 하는 다음 요청이 들어올 때 일어나기 때문이다.', '16:04:00 요청만 1,240ms가 걸리고 그 뒤로 5ms로 돌아온 것이 재생성이 그 요청 안에서 일어났다는 자국이다. 방문이 없으면 표시된 채 그대로 남으므로, 트래픽이 드문 화면은 무효화를 불러도 한참 동안 예전 내용에 머문다.', true),
(12589, 4655, '라우트 핸들러 안에서 부른 무효화는 서버 캐시에 닿지 못하고 브라우저 라우터 캐시만 지우므로, 서버는 아무 일도 하지 않았기 때문이다.', '호출 위치가 서버 캐시 반영 여부를 가른다고 본 것. 서버 캐시는 라우트 핸들러에서 불러도 무효화된다. 서버가 정말 아무 일도 하지 않았다면 16:04:00 요청이 1,240ms를 쓰며 다시 렌더링될 이유가 없다.', false),
(12590, 4655, '재생성은 16:00:00 응답 직후 백그라운드에서 이미 끝났고, 16:04:00이 1,240ms 걸린 것은 오래 비어 있던 서버가 깨어나는 시간 때문이다.', '시간 기반 만료의 백그라운드 재생성을 온디맨드 무효화에 갖다 붙인 것. 백그라운드에서 끝났다면 그 4분 사이에 렌더링 로그와 CPU 상승이 남아야 하는데, 로그에는 둘 다 없다.', false),

-- 문제 4656
(12591, 4656, '/terms는 만료 시각을 두지 않는 설정이라, 재배포나 온디맨드 무효화가 없는 한 처음 만든 캐시를 계속 내보낸다. 재생성 0회는 그 결과다.', '참이다. revalidate = false는 시간에 의한 만료를 끄는 쪽이라 약관처럼 손댈 때만 바뀌는 문서에 맞는다. 내용을 고쳐야 할 때는 배포나 revalidatePath 같은 온디맨드 수단으로 직접 갱신한다.', false),
(12592, 4656, '/me는 캐시된 응답을 쓰지 않고 요청마다 화면을 다시 만드는 설정이라, 응답 시간 중앙값이 다른 세 라우트보다 크게 높다.', '참이다. revalidate = 0은 동적 렌더링을 뜻해 매 요청 서버가 렌더링한다. 개인화된 데이터처럼 남의 응답을 재사용하면 안 되는 화면에 쓰며, 180ms라는 응답 시간이 그 대가다.', false),
(12593, 4656, '/news의 재생성 288회는 하루 86,400초를 300초로 나눈 값과 같아, 만료될 때마다 곧바로 새 방문이 뒤따랐다는 뜻이다.', '참이다. 하루 41,000회 방문이면 300초 구간마다 요청이 끊기지 않아 만료 직후 첫 방문이 매번 재생성을 끌어낸다. 방문이 넉넉하면 실제 갱신 주기가 설정값에 거의 붙는다.', false),
(12594, 4656, '/rank의 재생성이 하루 3회뿐인 것은 설정값이 무시된 결과이므로, revalidate 값을 더 짧게 주면 방문이 없어도 제때 갱신된다.', '거짓이라 이 선지가 정답이다. 재생성은 만료 뒤 첫 요청이 있어야 시작되므로 방문 3회에 재생성 3회는 설정이 그대로 지켜진 모습이다. 값을 줄여도 방문 없는 시간대는 비어 있어, 앞당기려면 온디맨드 무효화가 필요하다.', true),

-- 문제 4657
(12595, 4657, '화면을 그리는 도중에는 재검증 API를 부를 수 없고, 데이터가 실제로 바뀌는 지점인 서버 액션이나 라우트 핸들러에서 불러야 하기 때문이다.', '렌더링은 캐시를 읽어 화면을 만드는 단계라, 읽는 도중 같은 캐시를 오래됨으로 표시하면 방금 만든 결과를 스스로 무효화하는 셈이 된다. 그래서 호출 자체가 막혀 있다. 재고를 바꾸는 서버 액션 쪽으로 호출을 옮기면 해결된다.', true),
(12596, 4657, 'products 태그가 fetch 옵션으로 붙어 있어 revalidateTag가 아니라 revalidatePath로만 무효화할 수 있기 때문이다.', 'fetch의 next.tags에 붙인 태그야말로 revalidateTag가 다루는 대상이다. 태그를 어디에 붙였는지에 따라 호출 함수가 갈리지도 않는다. 태그가 안 맞았다면 오류가 아니라 갱신이 안 되는 증상으로 나타났을 것이다.', false),
(12597, 4657, 'revalidateTag가 비동기 함수라 await 없이 호출하면 렌더링이 끝난 뒤 처리되지 못한 예외가 던져지기 때문이다.', 'await 누락 문제로 본 것. 이 함수는 기다려 받아야 할 결과가 없고, await를 붙인다고 렌더링 중 호출이 허용되지도 않는다. 호출 형태가 아니라 호출 시점이 문제다.', false),
(12598, 4657, 'next/cache의 함수는 서버 컴포넌트에서 import할 수 없고 "use client"를 붙인 파일에서만 쓸 수 있기 때문이다.', '방향이 반대다. 재검증 API는 서버에서만 동작해 클라이언트 컴포넌트에서는 쓸 수 없다. 정해진 호출 자리인 서버 액션과 라우트 핸들러는 둘 다 서버에서 실행되는 코드다.', false),

-- 문제 4658
(12599, 4658, '요청 본문의 tag 값이 미리 등록해 둔 태그 목록에 있는지 확인하고, 없으면 아무 일도 하지 않고 돌려보내는 처리', '허용 태그 목록만으로는 막히지 않는다. posts처럼 흔한 이름을 실어 보낸 요청은 그대로 통과해 같은 무효화를 일으킨다. 걸러야 할 것은 태그 값이 아니라 호출한 상대가 누구인가다.', false),
(12600, 4658, '응답에 Cache-Control: no-store 헤더를 붙여 이 라우트 핸들러의 응답이 중간 캐시에 남지 않게 하는 처리', '핸들러 응답이 캐시되는 것이 문제라고 본 것. 부하는 응답 재사용이 아니라 무효화가 반복돼 화면이 매번 다시 만들어지는 데서 온다. POST 핸들러의 응답은 애초에 캐시 대상도 아니다.', false),
(12601, 4658, '요청 헤더에 담긴 비밀 키를 서버 환경 변수와 대조해, 값이 일치하지 않으면 401로 돌려보내는 처리', '무효화 엔드포인트가 열려 있으면 누구나 캐시를 오래됨으로 만들 수 있고, 그 뒤 방문마다 재생성이 일어나 서버를 밀어붙이는 통로가 된다. 호출자 신원을 먼저 확인하고 키는 웹훅 발신 쪽에만 나눠 준다.', true),
(12602, 4658, 'revalidateTag 호출을 await로 감싸 재생성이 모두 끝난 뒤에 응답을 돌려주도록 하는 처리', '무효화가 곧 재생성이라고 본 것. 이 호출은 오래됨 표시까지만 하고 재생성은 다음 요청이 맡는다. 응답을 늦춘다고 남이 보내는 호출 수가 줄지도 않아 부하의 원인에 닿지 못한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1508, 4659, 'revalidatePath,revalidatePath(),revalidate Path,revalidate path,리밸리데이트패스,리밸리데이트 패스', '태그를 한 곳도 달아 두지 않은 데이터라 태그 기준 무효화는 쓸 수 없고, 인자로 준 것이 URL 문자열이며, 결과도 그 경로 한 장만 새로 만들어지고 이웃 화면은 캐시를 유지했다. 경로 단위로 캐시를 버리는 revalidatePath의 자국이다. 두 번째 인자로 "page"를 주면 /newsroom/[slug] 패턴에 해당하는 모든 화면, "layout"을 주면 그 레이아웃을 공유하는 하위 경로 전부가 대상이 되어 범위가 급격히 넓어지니 최후 수단으로 남겨 둔다. 데이터에 태그를 붙여 둘 수 있다면 목록과 상세를 정확히 짚는 revalidateTag가 범위 면에서 더 안전하고, 만료 시각을 정해 두는 시간 기반 revalidate와는 무효화를 촉발하는 주체(변경 사건이냐 시계냐)에서 갈린다.'),
       (1509, 4660, 'router.refresh(),router.refresh,useRouter().refresh(),refresh(),refresh,라우터 리프레시,라우터 새로고침', '열어 둔 탭이 옛 수치를 보여 준 원인은 서버 캐시가 아니라 브라우저에 남아 있는 라우터 캐시다. 웹훅을 받은 라우트 핸들러의 무효화는 서버 캐시까지만 닿기 때문에, 이미 떠 있는 화면은 다음 내비게이션이나 router.refresh() 호출이 있어야 새 내용을 받는다. refresh()는 현재 경로를 서버에 다시 요청해 새 RSC 페이로드로 화면을 갱신하되 입력값·스크롤 같은 클라이언트 상태는 보존한다는 점에서, 페이지를 통째로 다시 띄우는 F5·location.reload()와 구분된다. 같은 갱신이 서버 액션에서는 따로 부르지 않아도 일어나는데, 액션 응답에 갱신된 RSC 페이로드가 함께 실려 오기 때문이다.');

-- =====================================================
-- Lesson 904: Next.js 재검증 설계 — 재생성 실패, 전략 선택, 태그와 경로의 무효화 범위
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5603, 904, '아래 조건에서 14:10:00 요청이 받는 화면과 그 뒤의 캐시 상태로 옳은 것은?', '```tsx
// app/air/page.tsx
export const revalidate = 300;

export default async function Page() {
  const res = await fetch("https://api.air.example/now");
  if (!res.ok) throw new Error("upstream " + res.status);
  return <AirQuality data={await res.json()} />;
}
```

- 프로덕션 빌드로 배포돼 있고, 이 페이지에는 위 설정 말고 다른 캐시 설정이 없다.
- 14:00:00에 이 페이지가 새로 만들어져 캐시됐다. 이때의 화면을 A라 한다.
- 외부 API는 14:03:00부터 14:30:00까지 모든 요청에 500을 돌려준다.
- 14:00:00 뒤 이 페이지로 들어온 첫 요청은 14:10:00이다.', 'OBJECTIVE'),
       (5604, 904, '아래 세 화면에 캐시·재검증 방식을 짝지은 것으로 옳은 것은?', '세 화면 모두 방문이 많은 편이고, 필요 없는 재생성은 되도록 줄이려 한다.

| 화면 | 데이터의 출처와 성격 |
|---|---|
| (가) 환율 위젯 | 외부 은행 API에서 가져온다. 값이 언제 바뀌는지 알려 주는 수단이 없고, 10분 정도 늦게 보여도 괜찮다. |
| (나) 공지사항 | 운영자가 우리 서비스의 관리자 화면에서 고친다. 수정은 하루 2~3건이지만, 고치면 바로 보여야 한다. |
| (다) 내 주문 내역 | 로그인한 사람마다 내용이 다르고, 다른 사람에게 보이면 안 된다. |', 'OBJECTIVE'),
       (5605, 904, '아래 상황에서 글 하나를 고칠 때 목록과 그 글의 상세만 다시 만들어지게 하는 수정으로 옳은 것은?', '```tsx
// lib/posts.ts
export const getPostList = () =>
  fetch(API + "/posts", { next: { tags: ["posts"] } }).then((r) => r.json());

export const getPost = (id: string) =>
  fetch(API + "/posts/" + id, { next: { tags: ["posts"] } }).then((r) => r.json());
```

```tsx
// app/api/revalidate/route.ts — CMS 웹훅이 부르는 라우트 핸들러 (비밀 키 검증은 생략)
export async function POST(req: NextRequest) {
  const { postId } = (await req.json()) as { postId: string }; // 고친 글의 id
  revalidateTag("posts");
  return NextResponse.json({ ok: true });
}
```

목록은 /posts 한 페이지, 상세 /posts/[id]는 5,000개다. 글 하나를 고칠 때마다 그 뒤 1시간 동안 상세 페이지 렌더링이 평소 40회에서 3,100회로 늘어난다. 새 내용은 목록과 고친 글의 상세에 모두 잘 나온다.', 'OBJECTIVE'),
       (5606, 904, '아래 서버 액션이 한 번 실행된 직후, 캐시가 무효화되어 다음 방문 때 다시 만들어지는 페이지는 모두 몇 개인가?', '```
app/
├─ layout.tsx
├─ page.tsx                → /
├─ about/page.tsx          → /about
├─ shop/
│  ├─ layout.tsx
│  ├─ page.tsx             → /shop
│  ├─ sale/page.tsx        → /shop/sale
│  └─ [id]/page.tsx        → /shop/1 ~ /shop/1200 (1,200개)
└─ blog/
   ├─ page.tsx             → /blog
   └─ [slug]/page.tsx      → 글 300개
```

```tsx
// app/actions.ts
"use server";
import { revalidatePath } from "next/cache";

export async function changeCurrency(formData: FormData) {
  await db.setting.update({ /* 상품 가격 표시 통화 변경 */ });
  revalidatePath("/shop", "layout");
}
```

- 모든 페이지는 미리 만들어져 캐시돼 있다.
- /shop 바깥의 페이지는 /shop 아래 페이지와 같은 데이터를 쓰지 않는다.', 'OBJECTIVE'),
       (5607, 904, '아래 응답 헤더의 ⓐ 자리에 들어갈 Cache-Control 지시어의 이름은?', '특가 페이지 /deals는 `export const revalidate = 60`으로 설정돼 있고, Next.js는 이 페이지 응답에 아래 헤더를 붙여 보낸다.

```
Cache-Control: s-maxage=60, ⓐ
```

아래 표는 이 페이지로 들어온 요청 전부다. 10:00:50에 관리자가 가격을 12,000원에서 11,000원으로 고쳤고, 온디맨드 무효화는 부르지 않았다.

| 요청 시각 | 응답 시간 | 받은 가격 | 서버 렌더링 |
|---|---|---|---|
| 10:00:00 | 1,380ms | 12,000원 | 이 요청 안에서 1회 |
| 10:00:40 | 4ms | 12,000원 | 없음 |
| 10:01:20 | 4ms | 12,000원 | 응답을 보낸 뒤 1회 |
| 10:01:23 | 3ms | 11,000원 | 없음 |', 'SUBJECTIVE'),
       (5608, 904, '아래 코드의 ⓐ 자리에 들어갈 next/cache 함수의 이름은?', '게시글 상세 화면은 로그인 여부에 따라 버튼이 달라 요청마다 렌더링된다. 글 데이터는 fetch가 아니라 ORM으로 DB를 직접 읽는데, 처음에는 getPostById가 db.post.findUnique를 곧바로 불렀고 이후 아래처럼 ⓐ로 감쌌다.

```tsx
// lib/posts.ts
import { ⓐ } from "next/cache";

export const getPostById = ⓐ(
  async (id: string) => db.post.findUnique({ where: { id } }),
  ["post-by-id"],
  { tags: ["posts"] }
);
```

| 지표 | 감싸기 전 | 감싼 뒤 |
|---|---|---|
| 하루 post 테이블 조회 수 | 92,400회 | 310회 |
| 글 데이터 응답 시간 중앙값 | 38ms | 2ms |
| 글 수정 뒤 revalidateTag("posts") 호출의 효과 | 없음 (어차피 요청마다 DB를 읽음) | 다음 요청에서 DB를 한 번 다시 읽어 새 내용 반영 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5603
(15115, 5603, '만료된 캐시는 쓸 수 없어 요청 안에서 페이지를 다시 만들다 실패하므로, 사용자는 곧바로 오류 화면을 받는다.', '만료를 곧 사용 불가로 본 오개념. 만료 뒤 첫 요청도 기다리지 않고 기존 캐시를 받고, 재생성은 응답을 보낸 뒤 백그라운드에서 일어난다. 그래서 재생성 중에 난 오류가 이 요청의 응답으로 이어지지 않는다.', false),
(15116, 5603, '화면 A를 받는다. 백그라운드 재생성은 실패하지만 캐시는 A로 남고, API가 복구된 뒤 재생성이 성공하면 새 화면으로 바뀐다.', '14:05:00에 만료된 뒤 들어온 첫 요청이라 기존 캐시 A를 먼저 받고 재생성은 뒤에서 시도된다. 재생성이 오류로 끝나면 마지막으로 성공한 캐시를 계속 쓰고 이후 요청에서 다시 시도하므로, 장애가 풀리면 자연히 새 화면이 된다.', true),
(15117, 5603, '화면 A를 받는다. 다만 재생성이 실패하는 순간 캐시가 비워져, 장애가 이어지는 동안 다음 요청부터는 오류 화면을 받는다.', '실패를 곧 캐시 삭제로 본 오개념. 재생성이 실패해도 마지막으로 성공한 캐시는 그대로 남는다. 캐시가 비워진다면 외부 API 장애 하나가 곧바로 사이트 장애로 번지는데, 기존 캐시를 지키는 동작이 이를 막는다.', false),
(15118, 5603, '화면 A를 받는다. 다만 재생성이 한 번 실패하면 이 페이지의 재검증이 꺼져, API가 복구돼도 재배포 전까지 A만 보인다.', '실패 한 번으로 재검증이 멈춘다고 본 오개념. 재생성이 실패하면 이후 요청에서 다시 시도하므로, API가 복구된 뒤 첫 재생성이 성공하면 새 화면이 된다. 재검증이 꺼지는 것은 revalidate = false를 직접 적었을 때다.', false),

-- 문제 5604
(15119, 5604, '(가) 온디맨드 태그 무효화 · (나) 시간 기반(revalidate = 10) · (다) 동적 렌더링', '(가)와 (나)를 뒤바꾼 것. 온디맨드 무효화는 변경을 아는 쪽이 불러야 하는데 (가)는 바뀌는 시점을 알 길이 없다. (나)는 우리 관리자 화면에서 바뀌어 저장 직후 부를 수 있는데, 10초 주기로 두면 하루 2~3건 수정에 재생성만 쌓인다.', false),
(15120, 5604, '(가) 시간 기반(revalidate = 600) · (나) 온디맨드 태그 무효화 · (다) 시간 기반(revalidate = 60)', '개인화 데이터를 캐시한 것. (다)를 60초 동안 캐시하면 먼저 방문한 사람의 주문 내역이 다음 사람에게 그대로 나갈 수 있다. 사람마다 달라지는 화면은 캐시하지 않고 요청마다 그리는 동적 렌더링이 맞다.', false),
(15121, 5604, '(가) 시간 기반(revalidate = 600) · (나) 시간 기반(revalidate = 1) · (다) 동적 렌더링', '주기를 아주 짧게 하면 즉시 반영된다고 본 것. 1초 주기여도 만료 뒤 첫 요청은 예전 화면을 받고, 하루 2~3건 수정을 위해 방문이 이어지는 동안 1초마다 재생성하게 돼 재생성을 줄이려는 조건과 어긋난다.', false),
(15122, 5604, '(가) 시간 기반(revalidate = 600) · (나) 온디맨드 태그 무효화 · (다) 동적 렌더링', '바뀌는 시점을 모르는 외부 값은 허용 지연(10분)만큼 주기를 둔 시간 기반이 맞다. 우리 시스템에서 바뀌는 공지는 저장 지점에서 태그를 무효화해 바로 반영하고, 사람마다 다른 주문 내역은 캐시하지 않고 요청마다 그린다.', true),

-- 문제 5605
(15123, 5605, '목록 fetch에는 ["posts-list"], 상세 fetch에는 ["post-" + id]를 붙이고, 라우트 핸들러에서 이 두 태그를 revalidateTag로 각각 부른다.', '목록과 상세가 posts 태그를 함께 쓰는 한, 그 태그를 무효화하면 상세 5,000개가 모두 대상이 된다. 목록 전용 태그와 글마다 다른 태그로 나누면 웹훅이 보낸 postId로 목록 하나와 고친 글 하나만 정확히 짚는다.', true),
(15124, 5605, '상세 fetch의 태그를 ["posts", "post-" + id]로 늘리고, 라우트 핸들러는 지금처럼 revalidateTag("posts")를 한 번만 부른다.', '태그를 하나 더 붙이면 범위가 좁아진다고 본 것. 무효화 범위는 호출에 넣은 태그가 정한다. posts는 여전히 상세 5,000개 모두에 붙어 있어 지금과 똑같이 전부 다시 만들어진다.', false),
(15125, 5605, '상세 fetch의 태그를 ["post-" + id]로 바꾸고, 라우트 핸들러에서는 revalidateTag("post-" + postId) 하나만 부른다.', '상세만 챙기고 목록을 빠뜨린 것. 목록 fetch에는 posts만 붙어 있어 post-42 같은 개별 태그 무효화의 대상이 아니다. 고친 글의 상세는 새로 나오지만 목록에는 예전 제목이 남는다.', false),
(15126, 5605, '라우트 핸들러의 revalidateTag("posts")를 revalidatePath("/posts")로 바꿔, 태그 대신 경로를 기준으로 무효화한다.', '경로 하나를 주면 그 아래 경로까지 무효화된다고 본 것. revalidatePath("/posts")는 그 URL 한 페이지와 그 페이지가 쓴 데이터만 무효화한다. 목록은 갱신되지만 /posts/42 같은 상세는 대상이 아니라 예전 내용이 남는다.', false),

-- 문제 5606
(15127, 5606, '1개', '두 번째 인자 없이 revalidatePath("/shop")만 부른 경우와 같게 본 것. URL만 주면 그 페이지 하나가 대상이지만, "layout"을 주면 그 레이아웃을 공유하는 하위 경로까지 모두 대상이 된다.', false),
(15128, 5606, '1,201개', '하위 경로만 대상이고 /shop 자신은 빠진다고 본 것. /shop 페이지도 shop/layout.tsx 안에서 그려지므로 함께 무효화된다. 레이아웃을 공유하는 경로를 셀 때는 그 레이아웃 바로 아래의 page.tsx도 넣어야 한다.', false),
(15129, 5606, '1,202개', '"layout"을 주면 shop/layout.tsx를 공유하는 모든 경로가 대상이다. /shop 1개, /shop/sale 1개, 상품 상세 1,200개를 더해 1,202개가 다음 방문 때 다시 만들어진다. /, /about, /blog 쪽은 레이아웃 밖이라 캐시가 남는다.', true),
(15130, 5606, '1,505개', '"layout"을 곧 사이트 전체 초기화로 본 것. 사이트 전체가 대상이 되는 것은 revalidatePath("/", "layout")처럼 루트 경로를 줬을 때다. 여기서는 /shop 레이아웃 밖의 /, /about, /blog와 글 300개의 캐시가 그대로 남는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1824, 5607, 'stale-while-revalidate,stale while revalidate,stalewhilerevalidate,SWR,스테일 와일 리밸리데이트,스테일와일리밸리데이트,스테일-와일-리밸리데이트', '10:01:20 요청은 만료 시각(10:01:00) 뒤 첫 요청인데도 4ms 만에 예전 가격을 받았고, 그 응답을 보낸 뒤에야 렌더링이 한 번 일어나 3초 뒤 요청부터 새 가격이 나왔다. 만료된 사본을 먼저 내주고 뒤에서 새로 만드는 stale-while-revalidate의 자국이며, Next.js의 시간 기반 재검증(ISR)이 이 방식을 따른다. 사용자를 기다리게 하지 않는 대신, 갱신은 지정한 60초 시점이 아니라 만료 뒤 첫 방문 이후에 반영된다. 만료된 사본을 원본 확인이 끝나기 전에는 내주지 않는 must-revalidate, 원본이 오류를 낼 때에만 예전 사본을 쓰는 stale-if-error와 구분된다.'),
       (1825, 5608, 'unstable_cache,unstable_cache(),unstable cache,unstablecache,언스테이블 캐시,언스테이블캐시,언스테이블_캐시', 'fetch가 아닌 ORM 호출에는 next.tags를 적을 자리가 없어, 그대로 두면 데이터 캐시에 들어가지 못하고 요청마다 DB를 읽는다. 함수와 캐시 키 조각, tags 옵션을 받아 그 결과를 데이터 캐시에 넣어 주는 것이 unstable_cache다. 그래서 DB 조회가 92,400회에서 310회로 줄었고, 태그가 붙었으니 글을 고친 뒤 revalidateTag("posts")로 fetch 결과와 똑같이 무효화할 수 있게 됐다. 캐시를 무효화하는 쪽인 revalidateTag·revalidatePath와 달리 이 함수는 캐시에 넣는 쪽이며, 붙인 태그 문자열과 무효화할 때 부르는 태그 문자열이 같아야 짝이 맞는다. React의 cache()는 한 번의 요청 안에서만 결과를 나눠 쓰므로, 요청이 바뀌면 다시 DB를 읽는다는 점에서 다르다.');
