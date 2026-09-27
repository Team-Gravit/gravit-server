-- Unit: 데이터 페칭과 폭포수 (Unit ID: 160)
-- Chapter: Next.js (Chapter ID: 15)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (586, 160, '순차 await 폭포수와 use 훅'),
       (744, 160, '중첩 폭포수와 병렬 실패, 프리로드'),
       (902, 160, 'App Router 데이터 페칭 — 요청 출발 시점, 의존 요청 스트리밍, 부분 실패와 경계 쪼개기');

-- =====================================================
-- Lesson 586: 순차 await 폭포수와 use 훅
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3695, 586, '아래 서버 컴포넌트가 데이터를 모두 받아 렌더를 시작하기까지 걸리는 최소 시간은?', '각 데이터 함수의 응답 시간은 주석과 같고, 네트워크·렌더 외의 오버헤드는 무시한다.

```tsx
// app/dashboard/page.tsx
export default async function Page() {
  const user = await getUser();                   // 150ms
  const [orders, banners] = await Promise.all([
    getOrders(user.id),                           // 200ms
    getBanners(),                                 // 100ms
  ]);
  return <Layout user={user} orders={orders} banners={banners} />;
}
```', 'OBJECTIVE'),
       (3696, 586, '아래 코드에서 preloadItem 호출이 만들어 내는 동작으로 옳은 것은?', '`getItem`은 React의 `cache`로 감싼 함수이고, items API와 `getRelated`의 응답 시간은 각각 300ms다.

```tsx
// lib/data.ts
import { cache } from "react";

export const getItem = cache(async (id: string) => {
  const res = await fetch(`https://api.example.com/items/${id}`);  // 300ms
  return res.json();
});

export const preloadItem = (id: string) => {
  void getItem(id);
};

// app/items/[id]/page.tsx
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  preloadItem(id);
  const related = await getRelated(id);        // 300ms
  return <Item id={id} related={related} />;   // Item 내부에서 await getItem(id)
}
```', 'OBJECTIVE'),
       (3697, 586, '아래 표는 App Router에서 데이터를 가져오는 방식을 정리한 것이다. 표를 바탕으로 한 설명 중 옳지 않은 것은?', '| 방식 | 실행 위치 | 데이터 캐시 | 주 용도 |
|---|---|---|---|
| 서버 컴포넌트 + `fetch` | 서버 | 적용(`fetch` 옵션으로 지정) | 기본 조회 |
| 서버 컴포넌트 + ORM 호출 | 서버 | 미적용 | 데이터베이스 직접 조회 |
| 라우트 핸들러(`route.ts`) | 서버 | 해당 없음 | 외부·클라이언트 컴포넌트가 부르는 API 엔드포인트 |
| 클라이언트 컴포넌트 + SWR·TanStack Query | 브라우저 | 해당 없음 | 실시간·폴링·낙관적 업데이트 |
| 서버 액션 | 서버 | 해당 없음 | 데이터 변경(mutation) |', 'OBJECTIVE'),
       (3698, 586, '아래 페이지에서 첫 화면이 늦게 뜨는 원인으로 옳은 것은?', '세 요청을 `Promise.all`로 묶었는데도 첫 화면이 1,400ms 뒤에야 나타난다.

```tsx
export default async function Page() {
  const [notice, feed, ranking] = await Promise.all([
    getNotice(),    // 30ms
    getFeed(),      // 120ms
    getRanking(),   // 1,400ms
  ]);
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Notice data={notice} />
      <Feed data={feed} />
      <Ranking data={ranking} />
    </Suspense>
  );
}
```', 'OBJECTIVE'),
       (3699, 586, '아래 서버 로그가 드러내는 성능 문제를 부르는 이름은?', '세 API는 서로의 응답을 전혀 사용하지 않는다. 페이지를 한 번 렌더링할 때 남은 서버 로그는 다음과 같다.

```
[server] GET /api/profile   start     0ms   end   210ms
[server] GET /api/feed      start   212ms   end   430ms
[server] GET /api/ads       start   433ms   end   640ms
[server] render complete                          645ms
```

코드를 고쳐 세 요청을 한꺼번에 출발시키자 render complete가 220ms로 줄었다.', 'SUBJECTIVE'),
       (3700, 586, '아래 코드의 빈칸 ____에 공통으로 들어갈 React API의 이름은?', '```tsx
// app/page.tsx (서버 컴포넌트) — await 하지 않고 Promise를 그대로 넘긴다
export default function Page() {
  const commentsPromise = getComments();
  return (
    <Suspense fallback={<p>댓글 불러오는 중...</p>}>
      <Comments promise={commentsPromise} />
    </Suspense>
  );
}

// app/comments.tsx (클라이언트 컴포넌트)
"use client";
import { ____ } from "react";

export function Comments({ promise }: { promise: Promise<Comment[]> }) {
  const comments = ____(promise);   // 풀릴 때까지 위 fallback이 보인다
  return <ul>{comments.map((c) => <li key={c.id}>{c.body}</li>)}</ul>;
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3695
(10027, 3695, '200ms', '세 요청이 모두 동시에 출발한다고 보고 가장 긴 하나만 센 값. `getOrders`는 인자로 `user.id`를 받으므로 `getUser`가 끝나기 전에는 출발할 수 없다.', false),
(10028, 3695, '250ms', '`Promise.all`이 먼저 끝나는 쪽(100ms)에서 해결된다고 본 계산. `Promise.all`은 묶인 Promise가 모두 해결될 때까지 기다리므로 늦게 끝나는 200ms 쪽에 맞춰진다.', false),
(10029, 3695, '350ms', '`getOrders`가 `user.id`에 의존해 앞의 150ms는 줄일 수 없다. 이후 두 요청은 함께 출발해 max(200, 100) = 200ms가 걸리므로 150 + 200 = 350ms다.', true),
(10030, 3695, '450ms', '`Promise.all`을 무시하고 세 응답 시간을 그대로 더한 값(150 + 200 + 100). 배열에 넣은 두 요청은 순서대로가 아니라 동시에 출발한다.', false),

-- 문제 3696
(10031, 3696, '`void`로 반환값을 버렸으므로 `Item` 안의 `getItem(id)`는 API 요청을 처음부터 다시 보낸다.', '`void`는 결과를 기다리지 않겠다는 표시일 뿐 요청을 취소하지 않는다. `cache`가 같은 인자의 호출 결과를 렌더링 동안 보관하므로 두 번째 호출은 이미 진행 중인 같은 Promise를 받는다.', false),
(10032, 3696, 'items 요청이 `getRelated`와 겹쳐 진행돼, 두 응답을 더한 600ms가 아니라 약 300ms 만에 둘 다 끝난다.', '`preloadItem`이 `await` 없이 요청을 먼저 출발시키므로 두 요청 구간이 포개진다. 자식이 쓸 데이터를 부모가 미리 걸어 두어 출발 시점을 앞당기는 것이 프리로드 패턴이 노리는 효과다.', true),
(10033, 3696, '`cache`가 보관한 결과는 다음 사용자의 요청에서도 살아 있어 재방문 시 API 호출이 생략된다.', '요청 메모이제이션과 데이터 캐시를 뒤섞은 오해. `cache`의 보관은 한 번의 서버 렌더링 요청 안에서만 유효하고 렌더가 끝나면 사라진다. 요청을 가로질러 재사용되는 쪽은 데이터 캐시다.', false),
(10034, 3696, '`preloadItem`은 `await`가 없어 요청을 예약만 하고, `Item`이 렌더될 때 비로소 요청이 나간다.', '`getItem(id)`를 호출한 순간 내부 `fetch`가 이미 시작된다. `await`는 요청을 시작하는 장치가 아니라 이미 출발한 요청의 결과를 어디서 기다릴지 정하는 장치다.', false),

-- 문제 3697
(10035, 3697, 'ORM으로 읽은 값은 `fetch` 옵션이 닿지 않으므로, 재검증 주기를 두려면 `unstable_cache` 같은 래퍼로 감싸야 한다.', '표에서 ORM 호출은 데이터 캐시 미적용이다. `fetch`를 거치지 않아 캐시·재검증 옵션을 붙일 자리가 없으므로 별도 래퍼로 감싸야 결과를 재사용할 수 있다. 참인 진술이다.', false),
(10036, 3697, '초 단위로 값이 바뀌는 시세 화면은 서버 컴포넌트만으로는 부족해 브라우저에서 도는 SWR·TanStack Query 쪽이 맞다.', '표에서 이 조합의 실행 위치는 브라우저이고 용도는 실시간·폴링이다. 서버 컴포넌트는 렌더 시점에 한 번 읽을 뿐이라 갱신을 스스로 이어 가지 못한다. 참인 진술이다.', false),
(10037, 3697, '서버 액션으로 목록을 조회하면 POST로 직렬 실행돼 병렬화나 데이터 캐시의 이점을 얻지 못한다.', '표에서 서버 액션의 용도는 데이터 변경이다. 조회에 쓰면 요청이 POST로 나가 순서대로 처리되므로 동시 실행도, 캐시 재사용도 기대할 수 없다. 참인 진술이다.', false),
(10038, 3697, '서버 컴포넌트가 같은 앱의 라우트 핸들러를 `fetch`로 부르면 같은 서버 안이라 네트워크 왕복 없이 처리된다.', '거짓이라 정답이다. 라우트 핸들러는 표에서도 외부·클라이언트 컴포넌트가 부르는 API 엔드포인트다. 서버 컴포넌트가 자기 앱의 엔드포인트를 부르면 실제 HTTP 왕복이 한 번 더 생기므로, 서비스 함수를 직접 import해 호출해야 한다.', true),

-- 문제 3698
(10039, 3698, '세 결과를 `Suspense` 경계 바깥에서 모두 `await`해 가장 느린 요청이 끝난 뒤에야 렌더가 시작된다.', '`await Promise.all`이 컴포넌트 최상단에 있어 세 데이터가 다 도착해야 JSX가 만들어진다. 경계 안 컴포넌트가 대기 상태로 들어간 적이 없어 `fallback`도 쓰이지 않는다. 느린 `getRanking`은 경계 안 컴포넌트로 내려 거기서 기다리게 해야 한다.', true),
(10040, 3698, '`Promise.all` 배열에서 `getRanking()`이 마지막이라 앞의 두 요청이 끝난 뒤에 출발한다.', '배열 순서를 실행 순서로 오해한 것. 배열을 만드는 시점에 세 함수가 모두 호출돼 요청이 이미 나가 있고, `Promise.all`은 그 결과를 모을 뿐이다. 순서를 바꿔도 총 시간은 그대로다.', false),
(10041, 3698, '`fallback`으로 둔 `PageSkeleton`이 무거워 첫 페인트가 그만큼 밀린다.', '스켈레톤은 데이터 없이 즉시 그릴 수 있는 조각이라 1,400ms를 만들지 못한다. 지연 폭이 `getRanking`의 응답 시간과 정확히 겹친다는 점이 원인을 데이터 대기 쪽으로 가리킨다.', false),
(10042, 3698, '경계 하나에 컴포넌트를 셋 다 넣어 `fallback`이 세 번 교체되며 렌더가 밀린다.', '한 경계 안에 컴포넌트가 몇 개든 `fallback`은 한 번 그려지고 한 번에 교체된다. 문제는 개수가 아니라 기다리는 지점의 위치이며, 속도가 다른 영역은 경계를 나눠야 빠른 쪽이 먼저 보인다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1188, 3699, '폭포수,요청 폭포수,폭포수 현상,워터폴,요청 워터폴,waterfall,request waterfall', '앞 요청이 끝난 시각(210ms)과 다음 요청이 시작된 시각(212ms)이 맞물려 있다. 서로 무관한 요청인데도 직렬로 이어져 전체 시간이 각 응답의 합에 가까워진 것이 폭포수다. 원인은 두 가지로, 독립적인 데이터를 순차 `await`한 경우와 부모가 `await`를 끝내야 자식이 렌더를 시작하는 컴포넌트 중첩이다. `Promise.all`이나 프리로드로 출발 시점을 앞당기면 220ms처럼 가장 느린 요청 하나에 수렴한다. 응답 자체가 느린 것을 뜻하는 지연(latency)이나, 완성된 결과를 조각내 먼저 보내는 스트리밍과는 다른 개념이다.'),
       (1189, 3700, 'use,use(),React.use,use 훅,use hook', '클라이언트 컴포넌트에서 Promise를 받아 해결될 때까지 가장 가까운 `Suspense` 경계의 `fallback`을 띄우고, 해결되면 값을 돌려주는 React API가 `use`다. 서버에서 `await`하면 그 시간만큼 HTML 전송이 미뤄지지만, Promise를 그대로 props로 넘기면 서버는 즉시 응답을 시작하고 느린 데이터만 나중에 채워진다. 훅이면서도 조건문·반복문 안에서 부를 수 있어 `useState`·`useEffect`와 규칙이 다르고, 서버 컴포넌트에서 결과를 직접 기다리는 `await`와는 실행 위치가 다르다는 점으로 구분한다.');

-- =====================================================
-- Lesson 744: 중첩 폭포수와 병렬 실패, 프리로드
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4643, 744, '아래 페이지가 HTML을 모두 완성하기까지 걸리는 최소 시간은?', '`Suspense` 경계는 어디에도 두지 않았고, 세 데이터 함수의 응답 시간은 주석과 같다. 네트워크·렌더 외의 오버헤드는 무시한다.

```tsx
// app/page.tsx
export default async function Page() {
  const profile = await getProfile();   // 200ms
  return (
    <>
      <ProfileCard profile={profile} />
      <Feed />   {/* 내부에서 await getFeed() — 300ms, profile을 쓰지 않음 */}
      <Ads />    {/* 내부에서 await getAds() — 100ms, profile을 쓰지 않음 */}
    </>
  );
}
```', 'OBJECTIVE'),
       (4644, 744, '아래 페이지를 서버에서 렌더링한 결과로 옳은 것은?', '광고 서버가 점검 중이라 `getAds`만 거부(reject)되고 나머지 둘은 정상 응답한다. 이 라우트에는 `error.tsx`가 있고 코드에는 `try/catch`가 없다.

```tsx
// app/page.tsx
export default async function Page() {
  const [notice, feed, ads] = await Promise.all([
    getNotice(),   // 40ms 뒤 성공
    getFeed(),     // 120ms 뒤 성공
    getAds(),      // 90ms 뒤 거부
  ]);
  return <Layout notice={notice} feed={feed} ads={ads} />;
}
```', 'OBJECTIVE'),
       (4645, 744, '아래 구성으로 페이지를 열었을 때 사용자 화면에서 일어나는 일로 옳은 것은?', '페이지는 네 영역으로 이뤄지고 각 영역 컴포넌트는 자기 데이터를 자기 안에서 `await`한다. 헤더는 `Suspense` 경계 바깥에 두고, 공지·게시글·추천 세 컴포넌트는 `Suspense` 경계 하나로 함께 감쌌다.

| 영역 | 사용하는 데이터 | 응답 시간 |
|---|---|---|
| 헤더 | 없음 | — |
| 공지 | `getNotice` | 40ms |
| 게시글 | `getPosts` | 200ms |
| 추천 | `getRecommend` | 1,200ms |', 'OBJECTIVE'),
       (4646, 744, '아래 로그처럼 한 번의 렌더에서 같은 쿼리가 세 번 실행된 이유로 옳은 것은?', '`Header`·`Sidebar`·`ProfileCard`는 모두 서버 컴포넌트이고 각자 `await getUserById(42)`를 호출한다. `getUserById`는 `fetch`를 쓰지 않고 ORM 클라이언트로 데이터베이스를 직접 조회하는 함수다.

```
[render] /users/42 렌더 시작
[db] SELECT * FROM users WHERE id = 42   -- Header
[db] SELECT * FROM users WHERE id = 42   -- Sidebar
[db] SELECT * FROM users WHERE id = 42   -- ProfileCard
[render] /users/42 렌더 완료
```', 'OBJECTIVE'),
       (4647, 744, '아래 변경에서 쓴 데이터 페칭 기법의 이름은?', '`getItem`은 React의 `cache`로 감싼 함수이고, 자식 컴포넌트 `Item`이 자기 안에서 `await getItem(id)`로 쓴다. 부모 컴포넌트 첫 줄에 `void getItem(id);` 한 줄을 넣은 것 말고는 코드를 바꾸지 않았다.

```
// 한 줄을 넣기 전
[server] GET /api/related/17  start     0ms   end   302ms
[server] GET /api/items/17    start   304ms   end   607ms
[server] 렌더 완료                                  614ms

// 한 줄을 넣은 뒤
[server] GET /api/items/17    start     2ms   end   305ms
[server] GET /api/related/17  start     4ms   end   307ms
[server] 렌더 완료                                  313ms
```', 'SUBJECTIVE'),
       (4648, 744, '아래 개선에서 추천 영역을 감쌀 때 쓴 React 컴포넌트의 이름은?', '추천 API의 응답 시간(1,200ms)도, 요청 개수도, 페칭 코드도 그대로 두고 화면 구성만 바꿨다. 개선 후에는 추천 영역만 따로 감싸고 그 자리에 먼저 보일 스켈레톤을 지정했다.

| 측정 항목 | 개선 전 | 개선 후 |
|---|---|---|
| 첫 화면이 보이는 시각 | 1,230ms | 150ms |
| 추천 영역이 채워지는 시각 | 1,230ms | 1,210ms |
| 추천 자리에 먼저 뜨는 것 | 없음(빈 화면) | 스켈레톤 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4643
(12555, 4643, '200ms', '부모의 `await`만 끝나면 HTML이 완성된다고 본 값. 자식이 자기 안에서 `await`하면 그 대기까지 끝나야 HTML이 만들어지고, `Suspense` 경계가 없으니 먼저 내보낼 조각도 없다.', false),
(12556, 4643, '300ms', '세 요청이 처음부터 함께 출발한다고 보고 가장 긴 하나만 센 값. `getFeed`·`getAds`는 부모의 `await`가 끝나 자식이 렌더되기 전에는 출발하지 못하므로 앞의 200ms가 그대로 더해진다.', false),
(12557, 4643, '500ms', '부모가 `getProfile`을 기다리는 200ms 동안 자식 요청은 출발조차 못 한다. 자식 둘은 같은 깊이의 형제라 함께 렌더돼 max(300, 100) = 300ms가 붙어 총 500ms다. 트리 깊이가 곧 폭포수 단계가 된다.', true),
(12558, 4643, '600ms', '형제 컴포넌트끼리도 순서대로 기다린다고 보고 셋을 모두 더한 값(200 + 300 + 100). 같은 깊이의 자식은 함께 렌더를 시작하므로 두 요청 구간이 포개진다.', false),

-- 문제 4644
(12559, 4644, '90ms 시점에 `Promise.all`이 함께 거부돼, 이미 받아 둔 공지·피드까지 버려지고 `error.tsx`가 대신 표시된다.', '`Promise.all`은 묶인 것 중 하나라도 거부되면 그 즉시 거부되고, 거부는 `await` 지점 위로 던져져 가장 가까운 에러 경계가 받는다. 성공한 결과를 살리려면 `Promise.allSettled`로 바꿔 항목별 상태를 확인해야 한다.', true),
(12560, 4644, '`getAds` 자리만 `undefined`가 되고 공지·피드는 그대로 렌더된다.', '`Promise.allSettled`의 동작과 뒤섞은 오해. `allSettled`는 항목마다 성공·실패 상태를 담아 돌려주지만, `Promise.all`은 거부를 그대로 던져 결과 배열 자체가 만들어지지 않는다.', false),
(12561, 4644, '세 요청이 모두 끝나는 120ms까지 기다린 뒤에 거부된다.', '성공할 때의 규칙(가장 늦게 끝나는 것에 맞춘다)을 거부에도 그대로 적용한 오해. 거부는 대기할 이유가 없어 첫 거부가 나온 90ms에 곧바로 전달되고, 남은 요청의 결과는 쓰이지 않는다.', false),
(12562, 4644, '거부된 `getAds`만 한 번 자동으로 재시도한 뒤 그래도 실패하면 거부된다.', '`Promise.all`은 여러 Promise의 완료를 모으기만 할 뿐 재시도 기능이 없다. 재시도가 필요하면 각 요청을 감싸는 래퍼를 직접 만들거나 데이터 계층에서 처리해야 한다.', false),

-- 문제 4645
(12563, 4645, '공지는 40ms, 게시글은 200ms, 추천은 1,200ms에 각각 제자리에 채워진다.', '준비된 것부터 교체된다는 설명은 맞지만 그 교체 단위는 경계다. 여기서는 셋이 한 경계 안에 있어 단위도 하나뿐이다. 영역별로 따로 나타나게 하려면 경계를 셋으로 나눠야 한다.', false),
(12564, 4645, '헤더까지 스켈레톤에 가려져 있다가 1,200ms에 네 영역이 한꺼번에 나타난다.', '경계가 페이지 전체를 덮는다고 본 오해. 헤더는 경계 바깥이고 기다리는 데이터도 없어 첫 응답에 바로 실려 나간다. 대기에 묶이는 것은 경계 안에 든 영역뿐이다.', false),
(12565, 4645, '세 요청이 순서대로 실행돼 합계 1,440ms 뒤에 화면이 완성된다.', '경계 안 형제 컴포넌트의 요청이 직렬이라고 본 오해. 세 컴포넌트는 함께 렌더돼 요청이 같이 출발하므로 총 시간은 합이 아니라 가장 느린 하나에 수렴한다. 1,440ms는 세 응답 시간을 더한 값이다.', false),
(12566, 4645, '헤더는 곧바로 보이지만 공지·게시글은 준비를 마치고도 기다렸다가 1,200ms에 추천과 함께 나타난다.', '한 경계는 한 덩어리로 대기하므로 그 안의 표시 시각이 가장 느린 `getRecommend`에 맞춰진다. 40ms·200ms짜리 영역까지 1초 넘게 붙잡히는 셈이니, 속도가 다른 영역은 경계를 나눠야 빠른 쪽이 먼저 보인다.', true),

-- 문제 4646
(12567, 4646, '데이터 캐시의 재검증 시간이 지나 세 호출이 모두 캐시를 비켜 갔다.', '데이터 캐시는 요청과 요청 사이에 결과를 재사용하는 장치라 한 렌더 안에서 겹친 호출과는 층이 다르다. 게다가 `fetch`를 거치지 않는 ORM 호출은 애초에 데이터 캐시가 붙지 않는다.', false),
(12568, 4646, '`fetch` 호출과 달리 ORM 호출은 자동으로 묶이지 않아, 같은 렌더에서 부른 횟수만큼 쿼리가 그대로 나간다.', 'Next.js가 렌더 한 번 동안 같은 요청을 한 번으로 줄여 주는 것은 GET `fetch`에 한정된다. ORM 호출에 같은 효과를 주려면 `getUserById`를 React의 `cache()`로 감싸 세 컴포넌트가 한 결과를 나눠 쓰게 해야 한다.', true),
(12569, 4646, '세 컴포넌트가 서로 다른 `Suspense` 경계 안에 있어 경계마다 렌더가 한 번씩 더 일어났다.', '`Suspense`를 리렌더 장치로 본 오해. 경계는 기다리는 단위를 나눌 뿐 컴포넌트를 다시 실행하지 않는다. 로그의 세 줄은 서로 다른 세 컴포넌트가 각각 한 번씩 부른 결과이며 경계 유무와 무관하다.', false),
(12570, 4646, '세 컴포넌트가 함께 렌더돼 첫 결과가 저장되기 전에 나머지 두 호출이 출발했기 때문이다.', '메모이제이션을 완료된 값만 재사용하는 장치로 본 오해. 렌더 단위 메모이제이션은 진행 중인 Promise를 그대로 돌려주므로 동시에 불러도 조회는 한 번이다. 여기서는 그 장치를 씌우지 않은 것이 원인이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1504, 4647, '프리로드,프리로드 패턴,preload,preload 패턴,preload pattern,preloading,프리로딩', '자식이 쓸 데이터의 요청을 부모가 `await` 없이 먼저 출발시켜 두는 것이 프리로드 패턴이다. 로그를 보면 넣기 전에는 items 요청이 related 요청이 끝난 뒤(304ms)에야 시작해 614ms가 걸렸지만, 넣은 뒤에는 두 구간이 포개져 313ms로 줄었다. `cache`로 감싼 덕분에 `Item` 안의 `getItem(id)`는 이미 진행 중인 같은 Promise를 받아 실제 요청은 한 번만 나간다. 요청을 앞당긴다는 점은 `Promise.all`과 같지만, 부모가 자식의 데이터를 대신 기다리지 않고 요청만 걸어 둔다는 점이 다르다. 결과가 요청과 요청 사이에 남는 데이터 캐시와도 구분해야 한다 — `cache`의 보관은 렌더 한 번 동안만 유효하다.'),
       (1505, 4648, 'Suspense,서스펜스,React.Suspense,Suspense 컴포넌트,서스펜스 컴포넌트,<Suspense>', '느린 부분만 경계로 감싸 그 안이 준비될 때까지 대체 화면을 보여 주고 나머지는 먼저 내보내게 하는 React 컴포넌트가 `Suspense`다. 요청을 앞당기지도, 추천 API를 빠르게 만들지도 않았는데 첫 화면이 1,230ms에서 150ms로 당겨진 까닭은 기다리는 단위가 페이지 전체에서 추천 영역으로 좁아졌기 때문이다. 요청을 동시에 출발시키는 `Promise.all`은 출발을 앞당기는 기법이고 `Suspense`는 도착한 순서대로 보여 주는 기법이라, 둘은 대체 관계가 아니라 함께 쓰는 관계다. 라우트 세그먼트 전체를 덮는 경계는 `loading.tsx` 파일이 자동으로 만들어 준다.');

-- =====================================================
-- Lesson 902: App Router 데이터 페칭 — 요청 출발 시점, 의존 요청 스트리밍, 부분 실패와 경계 쪼개기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5591, 902, '아래 두 페이지 A·B가 세 데이터를 모두 받기까지 걸리는 최소 시간을 바르게 짝지은 것은?', '두 페이지는 같은 데이터 함수를 쓰며, 각 함수의 응답 시간은 A의 주석과 같다. `getCoupons`는 인자로 받은 회원 ID로 조회하고, 네트워크 외의 오버헤드는 무시한다.

```tsx
// A: app/a/page.tsx
export default async function PageA() {
  const member = await getMember();               // 100ms
  const coupons = await getCoupons(member.id);    // 200ms
  const notice = await getNotice();               // 250ms
  return <MyPage member={member} coupons={coupons} notice={notice} />;
}

// B: app/b/page.tsx
export default async function PageB() {
  const noticePromise = getNotice();
  const member = await getMember();
  const coupons = await getCoupons(member.id);
  const notice = await noticePromise;
  return <MyPage member={member} coupons={coupons} notice={notice} />;
}
```', 'OBJECTIVE'),
       (5592, 902, '아래 로그에서 세 조회가 동시에 처리되지 않고 차례로 이어진 이유로 옳은 것은?', '결제 페이지의 클라이언트 컴포넌트가 마운트될 때, 조회용으로 만든 서버 액션 세 개를 `Promise.all`로 한꺼번에 호출한다. 세 함수는 서로의 결과를 쓰지 않고, 각 처리 시간은 약 200ms다.

```tsx
"use client";
// ...
useEffect(() => {
  Promise.all([getCartAction(), getCouponsAction(), getPointsAction()])
    .then(([cart, coupons, points]) => setSummary({ cart, coupons, points }));
}, []);
```

```
[server] POST /checkout  action=getCartAction     start    0ms  end  204ms
[server] POST /checkout  action=getCouponsAction  start  209ms  end  411ms
[server] POST /checkout  action=getPointsAction   start  415ms  end  618ms
```', 'OBJECTIVE'),
       (5593, 902, '아래 페이지의 첫 화면을 앞당기는 방법에 대한 설명으로 옳은 것은?', '주문 내역 페이지는 사용자 정보를 받아야 그 사용자 ID로 주문 목록을 조회할 수 있다. 지금은 페이지 컴포넌트가 두 데이터를 차례로 `await`한 뒤 헤더와 주문 목록을 함께 렌더링하며, 페이지 어디에도 `Suspense` 경계는 없다. 헤더는 `user`만, 주문 목록은 `orders`만 쓴다.

| 항목 | 측정값 |
|---|---|
| `getUser()` 응답 시간 | 300ms |
| `getOrders(user.id)` 응답 시간 | 500ms |
| 헤더가 보이는 시각 | 800ms |
| 주문 목록이 보이는 시각 | 800ms |', 'OBJECTIVE'),
       (5594, 902, '아래 상품 상세 페이지를 열었을 때 일어나는 일로 옳은 것은?', '상품 정보는 서버에서 기다리고, 리뷰는 기다리지 않은 채 클라이언트 컴포넌트로 넘긴다. 응답 시간은 주석과 같고, 네트워크 외의 오버헤드는 무시한다.

```tsx
// app/products/[id]/page.tsx (서버 컴포넌트)
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await getProduct(id);     // 80ms
  const reviewsPromise = getReviews(id);    // 1,200ms — await 하지 않음
  return (
    <>
      <ProductInfo product={product} />
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews promise={reviewsPromise} />
      </Suspense>
    </>
  );
}

// app/products/[id]/reviews.tsx (클라이언트 컴포넌트)
"use client";
import { use } from "react";

export function Reviews({ promise }: { promise: Promise<Review[]> }) {
  const reviews = use(promise);
  return <ul>{reviews.map((r) => <li key={r.id}>{r.body}</li>)}</ul>;
}
```', 'OBJECTIVE'),
       (5595, 902, '아래 코드의 빈칸 ____에 들어갈 Promise 메서드의 이름은?', '대시보드는 서로 독립적인 위젯 데이터 세 개를 한꺼번에 가져온다. 환율 API가 503으로 응답한 날에도 페이지는 에러 화면으로 넘어가지 않았고, 환율 위젯 자리에만 "잠시 후 다시 시도해 주세요"가 표시됐다. 서버 로그는 다음과 같다.

```tsx
const results = await Promise.____([getWeather(), getRates(), getNews()]);
console.log(results);
```

```
[server] [
  { status: "fulfilled", value: { city: "Seoul", temp: 21 } },
  { status: "rejected",  reason: Error: 503 Service Unavailable },
  { status: "fulfilled", value: [ { id: 1, title: "..." }, ... ] }
]
[server] GET /dashboard 200  312ms
```', 'SUBJECTIVE'),
       (5596, 902, '아래 측정표의 (가)에 들어갈 웹 성능 지표의 이름은?', '상품 목록 페이지의 첫 화면을 앞당기려고, `Suspense` 경계 하나로 묶여 있던 상품 카드 12개를 카드마다 별도의 경계로 감쌌다. 카드별 데이터는 40ms~900ms 사이에 제각각 도착하고, 실제 카드는 스켈레톤보다 높이가 60px가량 크다. 변경 뒤 "누르려던 순간 버튼이 아래로 내려가 옆 카드를 눌렀다"는 문의가 늘었다.

| 지표 | 변경 전 (경계 1개) | 변경 후 (경계 12개) |
|---|---|---|
| LCP | 1,900ms | 1,100ms |
| (가) | 0.03 | 0.34 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5591
(15083, 5591, 'A 550ms, B 550ms', 'Promise를 `await`하는 줄에서 요청이 나간다고 본 오해. B의 `getNotice()`는 호출한 첫 줄에서 곧바로 요청이 출발하고, `await noticePromise`는 이미 진행 중인 요청의 결과를 받는 자리일 뿐이다.', false),
(15084, 5591, 'A 550ms, B 300ms', 'A는 세 `await`가 차례로 이어져 100 + 200 + 250 = 550ms다. B는 `getNotice`가 첫 줄에서 출발해 member→coupons 체인(100 + 200 = 300ms)과 겹치고, 250ms에 이미 끝나 마지막 `await`에서 더 기다리지 않는다.', true),
(15085, 5591, 'A 550ms, B 250ms', 'B의 세 요청이 모두 함께 출발한다고 보고 가장 긴 것만 센 값. `getCoupons`는 `member.id`가 있어야 호출할 수 있어 `getMember`가 끝난 100ms에야 출발하므로 300ms 아래로는 줄지 않는다.', false),
(15086, 5591, 'A 300ms, B 300ms', '서로 무관한 `await`는 런타임이 알아서 병렬로 돌린다고 본 오해. A의 `getNotice()`는 앞 두 `await`가 끝난 300ms에야 호출된다. 요청은 코드가 먼저 출발시킨 만큼만 겹친다.', false),

-- 문제 5592
(15087, 5592, '`Promise.all`은 배열 앞쪽 요청이 끝나야 다음 요청을 출발시키므로, 세 호출이 배열 순서대로 이어졌다.', '배열 순서를 실행 순서로 본 오해. 배열을 만드는 순간 세 함수가 모두 호출되고 `Promise.all`은 결과를 모을 뿐이다. 같은 자리에 일반 `fetch` 세 개를 넣으면 약 200ms에 함께 끝난다.', false),
(15088, 5592, '세 요청이 같은 출처로 나가, 브라우저의 출처당 동시 연결 수 제한에 걸려 하나씩 처리됐다.', '브라우저는 한 출처에 여러 연결(HTTP/1.1에서 보통 6개)을 동시에 열고, HTTP/2는 한 연결로 여러 요청을 함께 보낸다. 요청 3개로는 이 제한에 닿지 않아 직렬화의 원인이 될 수 없다.', false),
(15089, 5592, '세 요청이 모두 같은 경로(`/checkout`)로 가서, 요청 메모이제이션이 중복 여부를 가리려고 앞 요청을 기다렸다.', '요청 메모이제이션을 대기 장치로 본 오해. 메모이제이션은 서버 렌더링 중 같은 인자의 GET `fetch`·`cache()` 호출을 한 번으로 줄이는 장치일 뿐, 클라이언트가 보낸 POST 요청의 순서를 조정하지 않는다.', false),
(15090, 5592, '서버 액션은 데이터 변경 용도로 설계돼, 클라이언트가 호출을 대기열에 넣고 한 번에 하나씩 보내기 때문이다.', '클라이언트는 서버 액션 호출을 하나 보내고 응답을 받은 뒤에야 다음을 보낸다. 조회에 쓰면 병렬화도 캐시 재사용도 얻지 못하므로, 조회는 서버 컴포넌트에서 가져와 props로 내리거나 라우트 핸들러를 호출하게 바꾼다.', true),

-- 문제 5593
(15091, 5593, '`getOrders` 호출을 주문 목록 컴포넌트 안으로 옮기고 `Suspense`로 감싸면, 주문 목록은 800ms 그대로지만 헤더는 300ms에 먼저 보인다.', '두 요청은 의존 관계라 합계 800ms 자체는 줄지 않는다. 대신 기다리는 단위를 나누면 헤더는 `getUser`가 끝난 300ms에 스트리밍으로 먼저 나가고, 목록 자리는 `fallback`을 보이다가 800ms에 채워진다.', true),
(15092, 5593, '`Promise.all([getUser(), getOrders(user.id)])`로 묶으면 두 요청이 함께 출발해 헤더와 주문 목록이 모두 500ms에 보인다.', '의존 관계를 무시한 오해. `getOrders`에 넘길 `user.id`는 `getUser`가 끝나야 생기므로 두 호출을 같은 배열에 넣을 수 없다. `Promise.all`은 서로 독립인 요청에만 쓸 수 있다.', false),
(15093, 5593, '`getOrders`를 React의 `cache()`로 감싸 두면 메모이제이션 덕분에 주문 목록도 대기 없이 300ms에 헤더와 함께 보인다.', '`cache()`는 한 렌더링 안에서 같은 인자로 다시 부른 호출을 한 번으로 줄일 뿐, 처음 나가는 요청의 500ms는 그대로다. 이 페이지에서 `getOrders`는 한 번만 불려 줄일 중복도 없다.', false),
(15094, 5593, '페이지 첫 줄에서 `preloadOrders(user.id)`로 주문 요청을 미리 출발시키면 두 요청이 겹쳐 둘 다 500ms에 보인다.', '프리로드는 요청에 쓸 인자를 이미 알 때만 앞당길 수 있다. 첫 줄에서는 `getUser`가 끝나지 않아 `user.id`가 없으므로 주문 요청을 먼저 보낼 수 없다. 의존 관계는 프리로드로도 풀리지 않는다.', false),

-- 문제 5594
(15095, 5594, 'Promise는 직렬화할 수 없는 값이라, 서버 컴포넌트에서 클라이언트 컴포넌트로 넘기는 지점에서 에러가 난다.', '함수처럼 경계를 넘지 못하는 값과 혼동한 오해. Promise는 서버→클라이언트 경계를 넘을 수 있는 값이라, 서버에서 풀린 결과가 응답 스트림에 이어 붙어 클라이언트로 전달된다.', false),
(15096, 5594, '하이드레이션이 끝난 뒤 브라우저가 리뷰 API를 다시 호출해, 리뷰 요청이 서버와 브라우저에서 한 번씩 나간다.', '`use`를 브라우저에서 새 요청을 보내는 훅으로 본 오해. 요청은 서버에서 한 번 출발했고, `use`는 넘겨받은 그 Promise의 결과를 풀어 쓸 뿐이라 브라우저가 API를 다시 부르지 않는다.', false),
(15097, 5594, '상품 정보와 리뷰 스켈레톤은 약 80ms에 먼저 보이고, 리뷰 목록은 리뷰 요청이 끝나는 약 1,280ms에 채워진다.', '서버는 `getProduct`만 기다린 뒤 HTML을 보내기 시작하고, 풀리지 않은 Promise를 받은 `Reviews`는 가장 가까운 `fallback`을 띄운다. 리뷰 요청은 80ms에 출발했으므로 1,200ms 뒤인 약 1,280ms에 채워진다.', true),
(15098, 5594, '`use`가 Promise가 풀릴 때까지 페이지 전체 렌더링을 멈추므로, 상품 정보도 약 1,280ms에 리뷰와 함께 보인다.', '`use`가 페이지 전체를 붙잡는다고 본 오해. 멈추는 범위는 그 컴포넌트를 감싼 가장 가까운 `Suspense` 경계까지이고, 경계 바깥의 상품 정보는 `getProduct`가 끝난 80ms에 이미 전송된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1820, 5595, 'allSettled,Promise.allSettled,allSettled(),Promise.allSettled(),올세틀드,올 세틀드,all settled', '`Promise.allSettled`는 묶인 Promise가 성공하든 실패하든 모두 끝날 때까지 기다린 뒤, 항목마다 `status`(fulfilled·rejected)와 함께 `value` 또는 `reason`을 담은 배열을 돌려준다. 로그의 결과 배열이 바로 그 모양이고, 그래서 환율 요청 하나가 실패해도 날씨·뉴스 결과는 그대로 화면에 쓸 수 있었다. 같은 자리에 `Promise.all`을 쓰면 하나라도 거부되는 즉시 전체가 거부돼 성공한 결과까지 버려지고, 가장 가까운 에러 경계(`error.tsx`)가 화면을 대신한다. 가장 먼저 성공한 하나만 돌려주는 `Promise.any`, 성공·실패와 상관없이 가장 먼저 끝난 하나만 돌려주는 `Promise.race`와도 구분해야 한다. 세 요청을 동시에 출발시킨다는 점은 `Promise.all`과 같아서 총 시간은 가장 느린 요청에 맞춰진다.'),
       (1821, 5596, 'CLS,Cumulative Layout Shift,누적 레이아웃 이동,누적 레이아웃 변경,누적 레이아웃 시프트,레이아웃 시프트,레이아웃 이동,layout shift', 'CLS(Cumulative Layout Shift, 누적 레이아웃 이동)는 이미 보이던 요소가 예고 없이 자리를 옮긴 정도를 점수로 합산한 Core Web Vitals 지표로, 단위 없는 값이며 0.1 이하를 양호로 본다. 경계를 카드마다 나누자 카드가 도착할 때마다 스켈레톤보다 큰 실제 카드로 바뀌면서 아래 요소를 밀어내 0.03이 0.34로 올랐다. 반면 빠른 카드부터 먼저 보여 가장 큰 콘텐츠가 그려지는 시각인 LCP는 1,900ms에서 1,100ms로 좋아졌다. 경계를 잘게 쪼개면 첫 표시는 빨라져도 화면이 여러 번 흔들리는 대가가 따르므로, 시각적으로 한 덩어리인 영역은 한 경계로 묶고 스켈레톤 높이를 실제 콘텐츠와 맞춘다. 입력 뒤 화면이 반응하기까지의 지연을 재는 INP, 첫 콘텐츠가 그려지는 시각을 재는 FCP와는 재는 대상이 다르다.');
