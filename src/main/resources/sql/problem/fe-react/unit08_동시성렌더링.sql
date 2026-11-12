-- Unit: 동시성 렌더링 (Unit ID: 148)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (574, 148, 'transition과 선택적 하이드레이션'),
       (732, 148, '렌더 폐기와 지연 값, 경계 배치'),
       (890, 148, '동시성 렌더링 실전: createRoot, 비동기 전환, 거부된 use, 중첩 경계 스트리밍, 도구 선택');

-- =====================================================
-- Lesson 574: transition과 선택적 하이드레이션
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3623, 574, '아래 화면에서 사용자가 입력창에 글자를 빠르게 이어서 칠 때 나타나는 동작으로 옳은 것은?', '상품 검색 화면의 일부다. filterHeavy는 한 번 실행에 약 300ms가 걸린다.

```tsx
function Search() {
  const [query, setQuery] = useState("");
  const [list, setList] = useState([]);
  const [isPending, startTransition] = useTransition();

  function onChange(e) {
    setQuery(e.target.value);                 // (A)
    startTransition(() => {
      setList(filterHeavy(e.target.value));   // (B)
    });
  }

  return (
    <>
      <input value={query} onChange={onChange} />
      <ul style={{ opacity: isPending ? 0.5 : 1 }}>
        {list.map((it) => <li key={it.id}>{it.name}</li>)}
      </ul>
    </>
  );
}
```', 'OBJECTIVE'),
       (3624, 574, '위 계측표를 바탕으로 옳지 않은 것은?', '같은 검색 화면을 세 가지 방식으로 구현해 계측한 결과다. 지연은 마지막 키 입력부터 결과 목록이 바뀔 때까지 걸린 시간이다.

| 구현 | 저사양 기기 지연 | 고사양 기기 지연 | 10자 입력 시 검색 API 호출 | 진행 중 표시 |
|---|---|---|---|---|
| A. 디바운스 300ms | 320ms | 305ms | 1회 | 직접 만들어야 함 |
| B. useTransition | 210ms | 40ms | 10회 | isPending |
| C. useDeferredValue | 205ms | 45ms | 10회 | 원본 값과 지연된 값 비교 |', 'OBJECTIVE'),
       (3625, 574, '위 구조에서 fallback이 뜨는 방식에 대한 설명으로 옳은 것은?', '대시보드의 탭 전환 구조다. 탭 상태는 startTransition(() => setTab(next)) 안에서 바꾼다.

```tsx
const Chart = lazy(() => import("./Chart"));  // 청크 내려받기 800ms
const Feed  = lazy(() => import("./Feed"));   // 청크 내려받기 120ms

function Panel() {
  return (
    <Suspense fallback={<Spinner />}>
      <Chart />
      <Feed />
    </Suspense>
  );
}
```', 'OBJECTIVE'),
       (3626, 574, '아래 서버 렌더링 방식에 대한 설명으로 옳은 것은?', '요청을 받은 서버는 데이터가 모두 준비되기를 기다리지 않고, 먼저 완성된 셸 HTML을 곧바로 응답으로 내보낸다. 아직 준비되지 않은 Suspense 경계 자리에는 fallback 마크업을 넣어 두고, 그 데이터가 준비되는 대로 해당 조각의 HTML을 같은 응답에 이어 붙여 흘려보낸다.', 'OBJECTIVE'),
       (3627, 574, '아래 화면에서 드러난 현상을 가리키는 용어는?', 'Zustand로 만든 외부 스토어의 unread 값을 한 화면의 두 곳에서 읽는다. 목록이 큰 화면이라 렌더가 여러 조각으로 나뉘어 진행되던 중, 소켓 메시지가 도착해 스토어 값이 3에서 4로 바뀌었다. 커밋된 화면을 보니 위쪽 헤더 배지에는 3이, 같은 화면 아래 요약줄에는 4가 찍혀 있었다. 새로고침하면 두 곳 모두 4가 된다.', 'SUBJECTIVE'),
       (3628, 574, '위 기록에서 리뷰 영역이 페이지 전체보다 먼저 반응하게 만든 React 18의 동작을 가리키는 용어는?', '스트리밍 SSR로 내려받은 상품 페이지의 계측 기록이다.

```
0.4s  셸 HTML 도착 — 헤더와 상품 정보 표시, 리뷰 영역은 fallback
1.0s  리뷰 영역 HTML 도착
1.1s  사용자가 리뷰 영역의 [더보기]를 누름 — 아직 반응 없음
1.3s  리뷰 영역이 클릭에 반응하기 시작
2.9s  손대지 않은 사이드바가 반응하기 시작
4.2s  페이지 전체 JavaScript 실행 완료
```

같은 페이지를 React 17 방식으로 서버 렌더하면 4.2초 전에는 어느 영역도 클릭에 반응하지 않는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3623
(9835, 3623, '(A)와 (B)가 한 덩어리로 처리돼, 목록 렌더 300ms가 끝난 뒤에야 방금 친 글자가 입력창에 보인다.', '같은 이벤트에서 호출됐어도 (B)는 전환 갱신이라 우선순위가 낮다. React는 급한 (A)를 먼저 커밋해 입력창을 즉시 갱신한다. 한 이벤트의 배치 처리와 갱신 우선순위를 뒤섞은 오개념이다.', false),
(9836, 3623, '다음 글자가 들어오면 진행 중이던 (B)의 렌더가 폐기되고, 목록 자리에는 직전에 완성된 결과가 그대로 남는다.', '전환 갱신은 중단하고 버릴 수 있다. 새 입력이 오면 React는 진행 중이던 렌더를 버리고 최신 값으로 다시 시작하며, 새 결과가 준비될 때까지 이전 커밋 화면을 그대로 보여 준다.', true),
(9837, 3623, 'startTransition이 (B)의 실행을 300ms 뒤로 미뤄, filterHeavy가 호출되는 횟수 자체를 줄여 준다.', '고정 시간을 기다려 호출 횟수를 줄이는 것은 디바운스다. startTransition은 호출을 미루는 것이 아니라 그 갱신의 렌더 우선순위만 낮추므로, 계산 횟수는 그대로다.', false),
(9838, 3623, '(B)의 렌더가 별도 워커 스레드로 넘어가 메인 스레드를 막지 않고 병렬로 진행된다.', '동시성 렌더링은 멀티스레드가 아니다. JavaScript는 여전히 단일 스레드이고, React가 렌더를 잘게 나눠 사이사이 브라우저에 제어권을 돌려주는 협력형 스케줄링일 뿐이다.', false),

-- 문제 3624
(9839, 3624, '고사양 기기에서 A만 지연이 거의 줄지 않은 것은, 대기 시간이 기기 성능과 무관하게 고정돼 있기 때문이다.', '참이다. 디바운스는 정해진 300ms를 언제나 채워 기다리므로 빠른 기기의 여유를 쓰지 못한다. B와 C는 남는 여유에 맞춰 렌더를 진행해 40ms대까지 내려갔다.', false),
(9840, 3624, 'A는 10자를 치는 동안 결과를 사실상 한 번만 계산하지만, B와 C는 입력마다 다시 계산해 중간 결과를 보여 준다.', '참이다. 호출 1회와 10회의 차이가 그 결과다. B와 C는 계산을 건너뛰지 않고 순서만 뒤로 미루므로, 타이핑 도중에도 갱신된 목록을 계속 볼 수 있다.', false),
(9841, 3624, 'B는 진행 여부를 알려 주는 값을 따로 받지만, C는 원본 값과 지연된 값이 같은지 견줘 직접 판단해야 한다.', '참이다. 그래서 로딩 표시가 꼭 필요한 화면이면 B가 손이 덜 간다. C를 쓰면 두 값을 비교하는 코드를 직접 한 줄 더 두어야 같은 표시를 만들 수 있다.', false),
(9842, 3624, '검색 API 호출이 서버에 부담인 상황에서도, 지연이 더 짧은 B나 C로 A를 대체하면 호출 부담까지 함께 준다.', '거짓이다. 표에서 B와 C는 10자에 10회를 그대로 호출한다. transition은 렌더 비용을 다루는 도구라 요청 횟수는 건드리지 못한다. 호출을 줄이려면 디바운스나 요청 중복 제거가 필요하다.', true),

-- 문제 3625
(9843, 3625, '이전 탭이 이미 그려진 상태에서 탭을 바꾸면 Spinner가 끼어들지 않고, 이전 화면이 유지되다 새 화면으로 한 번에 바뀐다.', '전환 갱신 도중 대기가 생기면 React는 fallback을 커밋하지 않고 직전 커밋을 유지한다. 보고 있던 콘텐츠가 다시 스피너로 되돌아가는 불쾌한 화면을 막기 위한 동작이다.', true),
(9844, 3625, 'Feed 청크가 120ms에 도착하므로 Feed부터 먼저 그려지고, Chart 자리에만 Spinner가 남아 있게 된다.', 'fallback은 컴포넌트별이 아니라 경계 단위로 걸린다. 한 경계 안 형제는 모두 준비될 때까지 함께 가려지므로 Feed도 Chart를 기다렸다가 800ms 뒤 한꺼번에 나타난다.', false),
(9845, 3625, 'Chart를 별도 경계로 감싸도 두 청크가 모두 도착해야 채워지므로, 화면에 무언가 보이는 시점은 달라지지 않는다.', '경계를 나누면 Feed는 자기 경계만 만족하면 되므로 120ms에 먼저 보인다. 경계를 어디에 두느냐가 표시 시점을 정한다는 점을 놓친 오개념이다.', false),
(9846, 3625, '경계 안에서 대기가 생기면 React는 Panel을 통째로 언마운트했다가, 준비된 뒤 처음부터 다시 마운트한다.', 'React는 준비되지 않은 하위 트리를 감춰 둘 뿐 언마운트하지 않는다. 언마운트라면 이미 그려진 형제의 상태가 매번 초기화되겠지만 실제로는 그대로 유지된다.', false),

-- 문제 3626
(9847, 3626, '브라우저는 조각이 모두 도착한 뒤에야 첫 화면을 그리므로, 첫 바이트 도착 시각만 빨라지고 첫 표시 시점은 예전과 같다.', '셸이 도착하는 즉시 화면이 그려지고 느린 자리에는 fallback이 보인다. 첫 표시 시점까지 함께 앞당겨지는 것이 이 방식의 핵심 이득인데 그 절반만 본 오개념이다.', false),
(9848, 3626, '늦게 도착한 조각은 도착 순서대로 문서 끝에 쌓이므로, 응답이 빠른 경계부터 위쪽에 두어야 화면이 뒤엉키지 않는다.', '늦게 온 조각은 감춰진 마크업으로 받고, 함께 온 짧은 스크립트가 그것을 fallback 자리로 옮겨 심는다. 도착 순서와 화면에서의 위치는 서로 묶여 있지 않다.', false),
(9849, 3626, 'Suspense 경계를 하나도 두지 않으면 나눠 보낼 단위가 없어, 결국 완성된 HTML을 한 번에 보내는 예전 방식과 같아진다.', '경계가 곧 전송 조각의 경계다. 경계가 없으면 쪼갤 지점이 없어, 느린 데이터 하나가 응답 전체를 붙잡아 두던 모습으로 그대로 돌아간다.', true),
(9850, 3626, '느린 조각을 기다리는 사이 서버가 응답을 닫으므로, 그 경계는 브라우저가 다시 요청해 클라이언트에서 렌더한다.', '응답 스트림은 열린 채 유지되고 준비된 조각이 같은 연결로 이어서 내려온다. 스트리밍을 추가 요청이나 클라이언트 렌더 대체로 오해한 것이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1164, 3627, '찢어짐,화면 찢어짐,티어링,테어링,tearing', '렌더가 중단됐다 이어지는 사이 외부 값이 바뀌어, 한 번의 커밋 안에 옛 값 3과 새 값 4가 섞여 그려진 것이 찢어짐이다. useState나 Context 값은 렌더 시작 시점 값으로 고정되므로 이런 일이 생기지 않고, 외부 스토어는 useSyncExternalStore로 구독해야 React가 렌더 도중 스냅샷이 바뀐 것을 알아채고 그 렌더를 버린 뒤 동기적으로 다시 그려 준다. 갱신이 통째로 늦게 반영되는 지연이나, 실행 순서가 엇갈려 결과 자체가 달라지는 경쟁 상태와는 구분한다. 새로고침하면 두 곳이 같아진다는 점이 값이 틀린 게 아니라 한 커밋 안에서만 어긋났다는 단서다.'),
       (1165, 3628, '선택적 하이드레이션,셀렉티브 하이드레이션,selective hydration', '스트리밍으로 먼저 도착한 조각에, 사용자가 먼저 건드린 영역을 앞세워 JavaScript를 붙이는 것이 선택적 하이드레이션이다. 1.1초 클릭이 1.3초에 처리되고 손대지 않은 사이드바가 2.9초로 밀린 기록이 그 증거이며, 전체 실행이 끝나는 4.2초를 기다리지 않는다. HTML을 조각내 순차 전송하는 스트리밍 SSR은 서버 쪽 이야기이고, 선택적 하이드레이션은 이미 받은 HTML에 JavaScript를 붙이는 클라이언트 쪽 순서 이야기라 서로 구분한다. 번들 자체를 쪼개는 코드 분할과도 다르다. 이때 Suspense 경계는 서버에서는 전송 단위, 클라이언트에서는 하이드레이션 단위가 된다.');

-- =====================================================
-- Lesson 732: 렌더 폐기와 지연 값, 경계 배치
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4571, 732, '아래 기록에서 서버 로그가 ResultList 커밋 횟수보다 많이 쌓인 이유로 옳은 것은?', '검색 화면의 일부다. 입력창 값은 별도 상태로 즉시 갱신하고, ResultList에 넘기는 query만 startTransition(() => setQuery(next)) 안에서 바꾼다. SlowRow는 행 하나를 그리는 데 약 1ms가 걸리며, 검색어마다 결과 행이 수천 개다.

```tsx
const ResultList = memo(function ResultList({ query }: { query: string }) {
  sendLog("search-view", query);   // 서버로 조회 로그 전송
  const rows = allItems.filter((it) => it.name.includes(query));
  return <ul>{rows.map((it) => <SlowRow key={it.id} item={it} />)}</ul>;
});
```

사용자가 react를 0.1초 간격으로 빠르게 입력했을 때의 기록이다.

```
서버 로그     : search-view  r / re / rea / reac / react   (5건)
Profiler 기록 : ResultList 커밋 — query = "react" 1회
```', 'OBJECTIVE'),
       (4572, 732, 'query가 "a"에서 "ab"로 바뀐 직후, List가 처음 다시 렌더될 때의 동작으로 옳은 것은?', '부모가 입력창 값을 그대로 query로 넘겨 주는 목록 컴포넌트다. filterHeavy는 한 번 실행에 약 200ms가 걸린다.

```tsx
function List({ query }: { query: string }) {
  const deferredQuery = useDeferredValue(query);
  const items = useMemo(() => filterHeavy(deferredQuery), [deferredQuery]);
  const stale = query !== deferredQuery;

  return (
    <ul style={{ opacity: stale ? 0.5 : 1 }}>
      {items.map((it) => <li key={it.id}>{it.name}</li>)}
    </ul>
  );
}
```', 'OBJECTIVE'),
       (4573, 732, '아래 증상을 해결하는 방법으로 옳은 것은?', 'React 19 클라이언트 컴포넌트에서 댓글 영역을 펼친 뒤 생긴 증상이다.

```tsx
function Comments({ postId, open }: { postId: number; open: boolean }) {
  if (!open) return null;
  const comments = use(
    fetch(`/api/posts/${postId}/comments`).then((r) => r.json())
  );
  return <ul>{comments.map((c) => <li key={c.id}>{c.text}</li>)}</ul>;
}

// 부모
<Suspense fallback={<Spinner />}>
  <Comments postId={7} open={open} />
</Suspense>
```

- open을 true로 바꾸자 Spinner가 뜬 뒤 사라지지 않는다.
- 네트워크 탭에는 /api/posts/7/comments 요청이 응답이 올 때마다 하나씩 새로 추가된다.
- 서버 응답은 매번 200으로 정상이다.', 'OBJECTIVE'),
       (4574, 732, '아래 계측표를 바탕으로 옳은 것은?', '같은 상품 페이지를 스트리밍 SSR로 렌더하면서 Suspense 경계 배치만 바꿔 계측했다. 서버에서 각 데이터가 준비되는 시각은 세 방식 모두 상품 정보 0.1초, 추천 1.0초, 리뷰 2.5초로 같다.

| 배치 | 첫 HTML 도착 | 상품 정보 표시 | 추천 표시 | 리뷰 표시 |
|---|---|---|---|---|
| A. 경계 없음 | 2.6초 | 2.6초 | 2.6초 | 2.6초 |
| B. 추천·리뷰를 한 경계로 감쌈 | 0.2초 | 0.2초 | 2.6초 | 2.6초 |
| C. 추천·리뷰를 각각 다른 경계로 감쌈 | 0.2초 | 0.2초 | 1.1초 | 2.6초 |', 'OBJECTIVE'),
       (4575, 732, '아래 코드의 빈칸에 들어갈 React 훅의 이름은?', '직접 만든 외부 스토어 cartStore의 장바구니 수량을 읽는 코드를 바꾼 전후 기록이다. 상단 장바구니 배지와 하단 결제 버튼이 이 값을 함께 보여 주며, 상품 목록이 커서 렌더가 여러 조각으로 나뉘어 진행된다.

```tsx
// 변경 전
function useCartCount() {
  const [, force] = useReducer((x: number) => x + 1, 0);
  useEffect(() => cartStore.subscribe(force), []);
  return cartStore.getState().count;   // 렌더 중 스토어를 직접 읽음
}

// 변경 후
function useCartCount() {
  return ________(cartStore.subscribe, () => cartStore.getState().count);
}
```

| 구간 | 렌더 도중 스토어 값이 바뀐 횟수 | 배지와 결제 버튼 수량이 다르게 커밋된 횟수 |
|---|---|---|
| 변경 전 | 120회 | 9회 |
| 변경 후 | 120회 | 0회 |', 'SUBJECTIVE'),
       (4576, 732, '실험 2의 운영체제 방식과 대비되는, 실험 1에서 React가 여러 작업을 번갈아 처리하는 방식을 가리키는 용어는?', '[실험 1] React 18 앱(createRoot)에서 상품 목록을 startTransition으로 갱신한다. 목록은 한 번 그리는 데 1ms가 걸리는 행 컴포넌트 수천 개와, 한 번 호출에 300ms가 걸리는 Summary 컴포넌트 하나로 이뤄져 있다. 목록을 그리는 도중 키를 눌렀다.

```
행 컴포넌트를 그리던 중 키 입력  → 수 ms 안에 입력창에 반영
Summary를 그리던 중 키 입력      → Summary 호출이 끝난 뒤에야 입력창에 반영 (최대 300ms 지연)
```

[실험 2] 같은 컴퓨터에서 CPU를 100% 쓰며 끝나지 않는 반복문 프로세스를 띄웠지만, 음악 재생 프로세스는 끊기지 않았다. 운영체제가 타이머 인터럽트로 반복문 프로세스를 중간에 멈추고 CPU를 다른 프로세스에 넘겼기 때문이다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4571
(12363, 4571, '입력마다 렌더가 끝까지 진행돼 커밋됐지만, 화면이 너무 빨리 바뀌어 마지막 결과만 눈에 남았기 때문이다.', 'Profiler에는 ResultList 커밋이 query = "react" 1회만 남았다. 시작된 전환 렌더는 반드시 커밋까지 간다고 본 오개념으로, 새 입력이 오면 진행 중이던 렌더는 커밋되지 않는다.', false),
(12364, 4571, '새 입력이 오면 진행 중인 렌더는 커밋 없이 폐기되는데, 폐기되기 전에 ResultList 본문은 이미 실행됐기 때문이다.', '앞선 네 번의 렌더는 수천 개의 SlowRow를 그리던 중 다음 키 입력에 밀려 폐기됐지만, 맨 앞의 sendLog는 이미 호출됐다. 렌더는 버려지거나 다시 실행될 수 있으니 순수해야 하며, 전송은 커밋 뒤에 도는 useEffect로 옮겨야 한다.', true),
(12365, 4571, '전환 갱신은 결과가 같은지 확인하려고 React가 렌더를 두 번씩 실행하기 때문이다.', '렌더를 두 번 호출해 순수성을 점검하는 것은 개발 모드 StrictMode의 동작이며 transition과는 관계가 없다. 그 때문이라면 글자마다 로그가 2건씩, 모두 10건이 쌓였어야 한다.', false),
(12366, 4571, 'startTransition이 입력마다 렌더를 줄 세워 두었다가, 입력이 멈춘 뒤 하나씩 끝까지 실행했기 때문이다.', '전환 렌더는 줄을 서서 모두 처리되지 않는다. 새 값이 오면 이전 값의 렌더를 버리고 최신 값으로 다시 시작한다. 하나씩 끝까지 실행했다면 r부터 reac까지의 커밋도 기록에 남았어야 한다.', false),

-- 문제 4572
(12367, 4572, 'deferredQuery도 곧바로 "ab"가 되고, filterHeavy 결과만 백그라운드에서 나중에 채워진다.', 'useDeferredValue는 갱신 직후 첫 렌더에서 이전 값 "a"를 그대로 돌려준다. 값이 곧바로 바뀌었다면 useMemo가 이 렌더에서 200ms 계산을 해 버려 입력이 버벅였을 것이다.', false),
(12368, 4572, '입력이 멈춘 뒤 정해진 시간이 지나야 List가 다시 렌더되고, 그때 곧바로 "ab" 결과가 그려진다.', '정해진 시간을 기다리는 것은 디바운스다. useDeferredValue에는 고정 대기 시간이 없어, props가 바뀌면 곧바로 이전 값으로 한 번 렌더하고 여유가 생기면 새 값으로 다시 렌더한다.', false),
(12369, 4572, 'useMemo가 query의 변화를 감지해 filterHeavy("ab")를 먼저 실행한 뒤 deferredQuery를 갱신한다.', '의존성 배열에는 query가 아니라 deferredQuery만 들어 있다. 첫 렌더에서 deferredQuery는 여전히 "a"이므로 useMemo는 이전 결과를 재사용하고 filterHeavy를 부르지 않는다.', false),
(12370, 4572, 'deferredQuery는 아직 "a"라서 filterHeavy가 다시 실행되지 않고, 이전 목록이 반투명하게 보인다.', 'useDeferredValue는 먼저 이전 값으로 렌더해 급한 화면을 바로 커밋하고, 새 값 "ab"로는 뒤이어 백그라운드에서 다시 렌더한다. 그 사이에는 query와 deferredQuery가 달라 stale이 참이 된다.', true),

-- 문제 4573
(12371, 4573, 'Promise를 부모나 캐시에서 한 번만 만들고, 같은 참조를 props로 넘겨 use에 전달한다.', '렌더 안에서 fetch를 부르면 응답 뒤 다시 렌더할 때마다 새 Promise가 생겨 또 중단된다. 한 번 만든 Promise를 안정된 참조로 넘기면 다시 렌더할 때 같은 Promise의 결과를 읽어 fallback이 풀린다.', true),
(12372, 4573, 'use 호출을 if 문보다 위로 옮겨, 훅이 매 렌더 같은 순서로 호출되게 한다.', 'use는 조건문이나 이른 반환 뒤에서도 부를 수 있는 예외적인 훅이라 호출 위치는 원인이 아니다. 위로 옮겨도 렌더마다 새 Promise가 만들어지는 문제는 그대로 남는다.', false),
(12373, 4573, 'Suspense 경계를 더 잘게 나눠, 댓글 목록만 따로 기다리게 한다.', '경계 위치는 무엇을 함께 가릴지만 정한다. 다시 렌더할 때마다 새 요청이 나가 또 중단되는 원인은 그대로여서, 경계를 어디에 두어도 fallback이 풀리지 않는다.', false),
(12374, 4573, 'Comments를 async 함수로 바꾸고 fetch 앞에 await를 붙여, 응답이 온 뒤에 값을 넘긴다.', 'async 컴포넌트는 서버 컴포넌트에서만 쓸 수 있고, 클라이언트 컴포넌트는 await로 렌더를 멈출 수 없다. 클라이언트에서는 안정된 Promise를 use로 읽거나 서버 상태 라이브러리를 거쳐야 한다.', false),

-- 문제 4574
(12375, 4574, '경계를 더 잘게 나눈 C는 B보다 첫 HTML을 먼저 받는다.', '표에서 B와 C의 첫 HTML은 모두 0.2초다. 첫 응답 시각은 느린 데이터가 경계 밖으로 빠졌는지로 정해질 뿐, 경계를 몇 개로 나눴는지와는 관계가 없다.', false),
(12376, 4574, 'C는 경계를 나눈 덕분에 리뷰 데이터를 준비하는 시간 자체도 줄었다.', '리뷰는 세 방식 모두 2.6초에 나타난다. 스트리밍은 준비된 조각부터 먼저 보내는 방식일 뿐, 느린 데이터를 더 빨리 가져오게 해 주지는 않는다.', false),
(12377, 4574, 'B에서 추천이 준비되고도 늦게 나타난 것은, 같은 경계 안의 리뷰까지 함께 기다렸기 때문이다.', '추천 데이터는 1.0초에 준비됐지만 B에서는 2.6초에 표시됐다. 한 경계 안의 내용은 모두 준비돼야 한 조각으로 전송되기 때문이다. C처럼 경계를 나누면 추천이 1.1초에 먼저 채워진다.', true),
(12378, 4574, 'B와 C의 차이는 서버 전송에만 해당하고, 브라우저에서 하이드레이션되는 단위와는 관계가 없다.', 'Suspense 경계는 서버에서는 스트리밍 조각의 단위이고, 클라이언트에서는 하이드레이션의 단위다. 경계 배치는 HTML이 나뉘는 방식과 JavaScript가 붙는 순서 모두에 영향을 준다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1480, 4575, 'useSyncExternalStore,useSyncExternalStore(),React.useSyncExternalStore,use-sync-external-store,유즈싱크익스터널스토어', '변경 전 코드는 렌더 중에 스토어를 직접 읽는다. 렌더가 조각으로 나뉘어 진행되는 사이 값이 바뀌면 배지는 옛 수량을, 결제 버튼은 새 수량을 읽어 한 커밋 안에 두 값이 섞였다(9회). useSyncExternalStore(subscribe, getSnapshot)로 구독하면 React가 렌더 도중 스냅샷이 바뀐 것을 알아채고 그 렌더를 버린 뒤 동기적으로 다시 렌더하므로, 값이 바뀐 횟수는 같은 120회여도 불일치는 0회가 된다. 이 훅이 막는 현상 자체는 찢어짐(tearing)이라 부른다. 값의 반영을 늦춰 급한 렌더를 먼저 처리하게 하는 useDeferredValue나, 갱신의 우선순위를 낮추는 useTransition과는 목적이 다르다. Zustand·Redux 같은 상태 라이브러리도 내부에서 이 훅으로 외부 스토어를 구독한다.'),
       (1481, 4576, '협력형 멀티태스킹,협력적 멀티태스킹,협조적 멀티태스킹,비선점형 멀티태스킹,비선점 멀티태스킹,협력형 스케줄링,비선점형 스케줄링,협력형,비선점형,cooperative multitasking,non-preemptive multitasking,nonpreemptive multitasking,cooperative scheduling,non-preemptive scheduling', 'React의 동시성 렌더링은 컴포넌트 같은 작은 작업 단위를 하나 끝낼 때마다 양보할 때인지 스스로 확인하고, 그때만 브라우저에 제어권을 돌려준다. 그래서 1ms짜리 행 사이에서는 곧바로 키 입력을 처리하지만, 한 번에 300ms를 쓰는 Summary 호출 도중에는 끼어들 수 없다. 실행 중인 작업이 스스로 넘겨줄 때만 전환이 일어나는 이 방식이 협력형(비선점형) 멀티태스킹이다. 실험 2의 운영체제처럼 타이머 인터럽트로 실행 중인 작업을 강제로 멈추는 선점형 멀티태스킹과 구분한다. JavaScript는 여전히 단일 스레드이므로 여러 스레드가 동시에 렌더하는 멀티스레딩과도 다르다. 무거운 컴포넌트는 더 작은 컴포넌트로 쪼개거나 계산을 줄여야 중간에 양보할 기회가 생긴다.');

-- =====================================================
-- Lesson 890: 동시성 렌더링 실전: createRoot, 비동기 전환, 거부된 use, 중첩 경계 스트리밍, 도구 선택
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5519, 890, '아래 계측표를 해석한 것으로 옳은 것은?', 'React 18.3으로 올린 검색 화면에서, 앱을 띄우는 진입 코드와 결과 목록 갱신 방식만 바꿔 가며 계측했다. 결과 목록은 한 행에 약 0.06ms가 걸리는 행 컴포넌트 5,000개로 이뤄져 있고, 목록 컴포넌트는 memo로 감싸 두었다. 입력창 값은 네 구성 모두 별도 상태로 곧바로 갱신한다. 지연은 키를 누른 뒤 그 글자가 입력창에 보일 때까지 걸린 시간이다.

| 구성 | 진입 코드 | 결과 목록 갱신 방식 | 입력창 반영 지연 |
|---|---|---|---|
| A | ReactDOM.render(<App />, el) | 일반 setState | 310ms |
| B | ReactDOM.render(<App />, el) | startTransition 안에서 setState | 305ms |
| C | createRoot(el).render(<App />) | 일반 setState | 300ms |
| D | createRoot(el).render(<App />) | startTransition 안에서 setState | 4ms |', 'OBJECTIVE'),
       (5520, 890, '아래 컴포넌트에서 저장 버튼을 누른 뒤 나타나는 동작으로 옳은 것은?', 'React 19로 만든 프로필 수정 화면이다. saveName은 서버 응답까지 약 800ms가 걸린다.

```tsx
function ProfileForm() {
  const [name, setName] = useState("");
  const [saved, setSaved] = useState("");
  const [isPending, startTransition] = useTransition();

  function onSave() {
    startTransition(async () => {
      const result = await saveName(name);
      startTransition(() => setSaved(result));
    });
  }

  return (
    <>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <button disabled={isPending} onClick={onSave}>저장</button>
      <p>저장된 이름: {saved}</p>
    </>
  );
}
```', 'OBJECTIVE'),
       (5521, 890, '아래 구조에서 commentsPromise가 거부된 직후의 화면으로 옳은 것은?', 'React 19 앱의 게시글 화면이다. commentsPromise는 부모가 한 번 만들어 같은 참조로 넘기는 Promise로, 1초 뒤 서버 오류(500)로 거부된다. Header는 기다릴 데이터가 없어 곧바로 그려지고, ErrorBoundary는 react-error-boundary 라이브러리의 컴포넌트다.

```tsx
function PostPage({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  return (
    <ErrorBoundary fallback={<p>불러오기 실패</p>}>
      <Header />
      <Suspense fallback={<Spinner />}>
        <Comments commentsPromise={commentsPromise} />
      </Suspense>
    </ErrorBoundary>
  );
}

function Comments({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  const comments = use(commentsPromise);
  return <ul>{comments.map((c) => <li key={c.id}>{c.text}</li>)}</ul>;
}
```', 'OBJECTIVE'),
       (5522, 890, '아래 페이지를 스트리밍 SSR로 렌더할 때, 서버가 HTML 조각을 보내는 방식으로 옳은 것은?', '상품 페이지 구조다. 각 컴포넌트에 필요한 데이터는 요청 뒤 주석에 적힌 시각에 서버에서 준비되며, Header와 Footer는 기다릴 데이터가 없다.

```tsx
function ProductPage() {
  return (
    <Layout>
      <Header />
      <Suspense fallback={<ProductSkeleton />}>
        <ProductInfo />                       {/* 0.3초에 준비 */}
        <Suspense fallback={<ReviewSkeleton />}>
          <Reviews />                         {/* 2.0초에 준비 */}
        </Suspense>
      </Suspense>
      <Footer />
    </Layout>
  );
}
```', 'OBJECTIVE'),
       (5523, 890, '아래 기록에서 2차 조치로 적용한 기법을 가리키는 용어는?', '주소 검색 창에서 글자를 칠 때마다 외부 주소 API를 호출하다가 호출 한도를 자주 넘겼다. 요청은 입력창의 onChange 핸들러에서 보낸다. 사용자가 seoul을 0.1초 간격으로 입력했을 때의 기록이다.

```
[1차 조치] 결과 목록 상태 갱신을 startTransition으로 감쌈
0.0s  s      → GET /address?q=s
0.1s  se     → GET /address?q=se
0.2s  seo    → GET /address?q=seo
0.3s  seou   → GET /address?q=seou
0.4s  seoul  → GET /address?q=seoul
요청 5건

[2차 조치] 1차 조치를 되돌리고 다른 기법을 적용
0.0s  s
0.1s  se
0.2s  seo
0.3s  seou
0.4s  seoul
0.7s         → GET /address?q=seoul
요청 1건
```

2차 조치 뒤에는 고사양 기기와 저사양 기기에서 같은 입력을 반복해도 요청이 늘 0.7s에 나갔다.', 'SUBJECTIVE'),
       (5524, 890, '아래 코드의 빈칸에 들어갈 React 훅의 이름은?', '검색 페이지는 다른 팀이 관리해 고칠 수 없고, 입력창 값을 keyword prop으로 곧바로 내려 준다. 우리 팀은 ResultPanel만 고칠 수 있다. ResultList는 memo로 감싼 목록으로, 행 3,000개를 그리는 데 약 250ms가 걸린다.

```tsx
// 다른 팀 코드 — 수정 불가
<input value={text} onChange={(e) => setText(e.target.value)} />
<ResultPanel keyword={text} />

// 우리 팀 코드
function ResultPanel({ keyword }: { keyword: string }) {
  const k = ________(keyword);
  return (
    <div style={{ opacity: keyword !== k ? 0.5 : 1 }}>
      <ResultList keyword={k} />
    </div>
  );
}
```

| 구현 | 키 입력 → 입력창 반영 | 입력하는 동안 결과 영역 |
|---|---|---|
| 빈칸 훅 없이 keyword를 그대로 넘김 | 약 250ms | 글자마다 새 목록을 다 그린 뒤 표시 |
| 빈칸 훅 적용 | 약 5ms | 직전 목록이 반투명하게 남아 있음 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5519
(14891, 5519, 'C의 결과로 보아, 진입 코드만 새 방식으로 바꿔도 앱의 모든 상태 갱신이 중단 가능한 렌더로 처리된다.', 'C는 A와 거의 같은 300ms다. createRoot는 동시성 기능을 쓸 바탕을 마련할 뿐, 일반 갱신은 여전히 중단 없이 한 번에 렌더된다. 전환으로 표시한 갱신만 양보하며 진행되므로 D에서야 지연이 줄었다.', false),
(14892, 5519, 'B의 결과로 보아, 옛 진입 코드에서는 전환으로 표시한 목록 렌더도 양보 없이 한 번에 끝까지 진행된다.', 'B는 전환을 썼는데도 A와 거의 같다. ReactDOM.render로 띄운 앱은 React 18을 설치해도 React 17처럼 동작해, 전환 갱신까지 입력창 갱신과 함께 동기적으로 한 번에 렌더된다. 동시성 기능은 createRoot가 전제다.', true),
(14893, 5519, 'D의 결과로 보아, 전환으로 표시한 목록 렌더는 별도 스레드에서 입력 처리와 동시에 진행된다.', '동시성은 멀티스레드가 아니다. JavaScript는 여전히 단일 스레드이고, React가 목록 렌더를 작은 단위로 나눠 사이사이 제어권을 돌려주기 때문에 D에서 입력창 갱신이 먼저 끼어들 수 있다.', false),
(14894, 5519, 'D의 결과로 보아, 전환으로 표시한 목록 갱신은 입력이 멈출 때까지 렌더를 시작하지 않고 기다린다.', '정해진 시간을 기다렸다 처리하는 것은 디바운스다. 전환 갱신은 곧바로 렌더를 시작하되 우선순위만 낮으며, 새 입력이 오면 진행 중이던 렌더를 버리고 최신 값으로 다시 시작한다.', false),

-- 문제 5520
(14895, 5520, '클릭 직후 버튼이 잠겼다가, 콜백이 await에 이르러 제어를 넘기는 순간 응답을 기다리지 않고 다시 풀린다.', 'React 19는 async 함수를 넘기면 await 이후까지 포함한 흐름 전체를 하나의 전환으로 본다. 동기 구간만 전환으로 치던 이전 동작으로 오해한 것으로, isPending은 응답 뒤 갱신이 커밋될 때까지 참이다.', false),
(14896, 5520, '응답을 기다리는 약 800ms 동안은 입력창 갱신도 함께 뒤로 밀려, 그 사이 친 글자가 화면에 보이지 않는다.', '전환은 그 안의 갱신 우선순위만 낮출 뿐 다른 갱신을 막지 않는다. 입력창의 setName은 긴급 갱신이라, 저장 응답을 기다리는 동안에도 친 글자가 곧바로 반영된다.', false),
(14897, 5520, '급하지 않은 작업으로 표시됐으므로, 입력이 잠잠해질 때까지 saveName 요청을 보내지 않고 기다린다.', 'startTransition은 넘긴 함수를 곧바로 실행하므로 요청은 클릭 즉시 나간다. 입력이 멈출 때까지 기다렸다 보내는 것은 디바운스이고, 전환은 호출 시점을 늦추지 않는다.', false),
(14898, 5520, '응답을 기다리는 약 800ms 내내 버튼이 잠겨 있고, 저장된 이름이 바뀐 뒤에야 다시 누를 수 있게 된다.', 'React 19에서는 startTransition에 async 함수를 넘길 수 있고, 요청부터 await 뒤 상태 갱신까지 전체가 한 전환으로 묶인다. 그래서 isPending이 새 이름이 커밋될 때까지 참으로 남아 중복 저장을 막는다.', true),

-- 문제 5521
(14899, 5521, 'Header까지 포함한 PostPage 전체가 "불러오기 실패" 한 줄로 바뀐다.', '거부되면 use가 그 사유를 오류로 던진다. Suspense는 대기만 맡고 오류는 잡지 않으므로, 오류는 가장 가까운 에러 경계인 ErrorBoundary까지 올라가 그 아래 Header까지 fallback 한 줄로 바뀐다.', true),
(14900, 5521, 'Spinner 자리만 "불러오기 실패"로 바뀌고, 위쪽 Header는 그대로 남는다.', '가장 가까운 Suspense가 오류도 처리한다고 본 오개념이다. Suspense는 오류를 잡지 않아 오류가 ErrorBoundary까지 올라간다. 댓글 자리만 바꾸려면 에러 경계를 Suspense 가까이에 따로 둬야 한다.', false),
(14901, 5521, '거부도 결과를 기다리는 중으로 취급돼, Spinner가 사라지지 않고 계속 남는다.', 'use는 거부된 Promise를 계속 기다리지 않고 곧바로 오류를 던진다. Spinner가 끝없이 남는 무한 로딩은 렌더마다 새 Promise를 만들 때의 증상이며, 한 번 만들어 넘긴 이 Promise와는 관계가 없다.', false),
(14902, 5521, 'use가 빈 값을 돌려줘, Header 아래 댓글 자리에 빈 목록이 그려진다.', 'use는 거부를 빈 값으로 바꿔 돌려주지 않고 오류로 던진다. 설령 undefined를 받았더라도 comments.map에서 다시 오류가 나 에러 경계로 넘어가므로 빈 목록이 그려질 수 없다.', false),

-- 문제 5522
(14903, 5522, '첫 조각에는 Header만 담기고, 문서 순서상 맨 뒤인 Footer는 앞선 경계가 모두 채워지는 2.0초 조각에 담긴다.', '조각은 문서 순서가 아니라 Suspense 경계 단위로 나뉜다. 경계 밖의 Footer는 기다릴 데이터가 없어 첫 조각(셸)에 담기고, 늦게 온 조각은 함께 온 스크립트가 제자리로 옮겨 넣는다.', false),
(14904, 5522, '첫 조각에 ProductSkeleton과 ReviewSkeleton이 함께 담기고, 0.3초 조각에는 ProductInfo만 담긴다.', '안쪽 경계는 바깥 경계의 내용에 속해 셸에 들어가지 않는다. 셸에는 바깥 경계의 fallback만 있고, ReviewSkeleton은 0.3초에 ProductInfo와 함께 바깥 경계의 내용으로 전송된다.', false),
(14905, 5522, '첫 조각에는 Header·ProductSkeleton·Footer가 담기고, 0.3초 조각에 ProductInfo와 ReviewSkeleton이 함께 담긴다.', '셸에는 경계 밖의 Header·Footer와 바깥 경계의 fallback이 담긴다. 바깥 경계는 안쪽 경계를 fallback으로 둔 채 0.3초에 완성돼 전송되고, Reviews는 2.0초에 별도 조각으로 와서 ReviewSkeleton을 대체한다.', true),
(14906, 5522, '첫 조각에는 Header·ProductSkeleton·Footer가 담기고, ProductInfo는 Reviews가 준비되는 2.0초 조각에 함께 담긴다.', '바깥 경계는 안쪽 경계를 기다리지 않는다. 준비 안 된 안쪽 자리는 ReviewSkeleton으로 채운 채 바깥 내용이 0.3초에 먼저 나간다. 둘을 함께 기다리게 하려면 한 경계로 묶어야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1796, 5523, '디바운스,디바운싱,디바운스 처리,디바운싱 처리,debounce,debouncing', '입력이 이어지는 동안에는 요청을 보내지 않다가, 마지막 입력(0.4s)에서 정해진 시간(0.3초)이 지난 0.7s에 한 번만 보낸 것이 디바운스다. 대기 시간이 고정돼 있어 기기 성능과 관계없이 요청 시각이 같다. 일정 간격마다 최대 한 번씩 실행하는 스로틀이었다면 입력이 이어지는 도중(예: 0.0s·0.3s)에도 요청이 나갔을 것이다. 1차 조치의 startTransition은 렌더 우선순위를 낮춰 입력창을 부드럽게 유지할 뿐 이벤트나 요청 횟수를 줄이지 않으므로 요청 5건이 그대로 나갔다. 전환은 렌더 비용 문제에, 디바운스나 서버 상태 라이브러리의 중복 제거는 요청 횟수 문제에 쓴다.'),
       (1797, 5524, 'useDeferredValue,useDeferredValue(),React.useDeferredValue,React.useDeferredValue(),유즈디퍼드밸류', 'setter를 쥔 부모 코드를 고칠 수 없으니 갱신을 startTransition으로 감쌀 수 없고, 손에 쥔 것은 keyword 값뿐이다. 이때 값을 받아 지연된 버전을 돌려주는 useDeferredValue를 쓴다. 키를 누른 직후의 급한 렌더에서는 k가 이전 값으로 남아 memo로 감싼 ResultList를 건너뛰므로 입력창이 약 5ms 만에 반영되고, 새 값으로 목록을 그리는 렌더는 뒤이어 중단 가능한 렌더로 진행된다. 그 사이 keyword와 k가 달라 반투명 표시로 진행 중임을 알릴 수 있다. setter 호출을 감싸는 useTransition과 달리 값만 있으면 쓸 수 있고, 고정 시간을 기다리는 디바운스와 달리 대기 시간이 기기 성능에 맞춰 달라진다는 점으로 구분한다.');
