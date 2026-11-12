-- Unit: 렌더링 최적화 판단 (Unit ID: 146)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (572, 146, 'memo 무력화와 React 컴파일러'),
       (730, 146, '측정 환경 차이와 useMemo 한계'),
       (888, 146, '렌더링 최적화 판단: memo가 놓치는 렌더와 렌더 시간 측정');

-- =====================================================
-- Lesson 572: memo 무력화와 React 컴파일러
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3611, 572, '아래와 같이 컴포넌트 구조를 바꾼 뒤의 렌더 동작으로 옳은 것은?', '`Fade`는 스크롤 위치를 state로 들고 있어 스크롤 중 매 프레임 리렌더되며, 감싼 영역의 투명도를 그 값으로 바꾼다. 무거운 `Report`는 원래 `Fade` 함수 본문 안에서 `<Report />`로 직접 렌더됐는데, 이번에 `Fade`가 `children`을 받도록 고치고 상위 `Page`에서 `<Fade><Report /></Fade>` 형태로 넘기게 바꿨다.

`Report`에는 `memo`를 붙이지 않았고, 스크롤이 이어지는 동안 `Page`는 리렌더되지 않는다.', 'OBJECTIVE'),
       (3612, 572, '아래 코드에서 화면을 처음 그린 뒤 버튼을 3번 눌렀을 때, `Row`가 렌더된 총 횟수는? (A·B 합산)', '```tsx
const Row = memo(function Row({ label, style, onPick }) {
  return <li style={style} onClick={onPick}>{label}</li>;
});

function List() {
  const [count, setCount] = useState(0);
  const handlePick = useCallback(() => {}, []);
  return (
    <div>
      <button onClick={() => setCount(count + 1)}>{count}</button>
      <ul>
        <Row label="A" style={{ padding: 4 }} onPick={handlePick} />
        <Row label="B" onPick={handlePick} />
      </ul>
    </div>
  );
}
```

개발 모드의 이중 렌더는 없다고 본다.', 'OBJECTIVE'),
       (3613, 572, '아래 프로파일러 기록에 대한 설명으로 옳지 않은 것은?', '한 커밋을 "Record why each component rendered while profiling"을 켜고 기록한 결과다.

| 컴포넌트 | 이 커밋의 렌더 시간 | Why did this render? |
|---|---|---|
| Dashboard | 2ms | Hooks changed |
| FilterBar | 1ms | The parent component rendered |
| ChartPanel | 68ms | Props changed: (options, onZoom) |
| Legend | 0.4ms | The parent component rendered |', 'OBJECTIVE'),
       (3614, 572, '아래 변경 사항에 대한 코드 리뷰 의견으로 옳은 것은?', '렌더 시간 측정 기록 없이 올라온 PR이다. `Badge`는 `memo`로 감싸지 않았고, 세 값은 주석에 적힌 용도로만 쓰인다.

```tsx
const label = useMemo(() => `${first} ${last}`, [first, last]); // <h2>{label}</h2>
const style = useMemo(() => ({ color }), [color]);              // <Badge style={style} />
const onClick = useCallback(() => setOpen(true), []);           // <button onClick={onClick}>
```

세 값 중 어느 것도 이펙트 의존성 배열에는 쓰이지 않는다.', 'OBJECTIVE'),
       (3615, 572, '아래 상황에서 팀이 새로 도입한 도구의 이름은?', 'React 19로 올린 뒤 빌드 설정에 플러그인 하나를 추가했다. 그러고 나서 화면 A의 `useMemo`·`useCallback`을 모두 지웠는데, 프로파일러로 같은 상호작용을 재현해 보니 리렌더 횟수와 커밋 시간이 지우기 전과 같았다. 반면 훅을 조건문 안에서 호출하던 화면 B의 두 컴포넌트는 같은 작업 뒤 리렌더 횟수가 눈에 띄게 늘었다.', 'SUBJECTIVE'),
       (3616, 572, '아래 상황에서 개발자가 정렬 코드에 적용한 훅의 이름은?', '상품 목록 화면은 10,000건 배열을 가격순으로 정렬해 그린다. 검색창에 한 글자 칠 때마다 커밋 시간이 90ms 넘게 찍혀 입력이 눈에 띄게 밀렸다. 정렬 부분에 훅 하나를 적용하고 다시 프로파일링하니 첫 렌더만 90ms이고 이후 입력에서는 8ms로 떨어졌다. 다만 서버에서 상품 배열을 새로 받아 온 직후의 커밋은 다시 90ms가 나왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3611
(9803, 3611, '`Report`에 `memo`를 붙이기 전까지는 구조를 바꿔도 `Fade`가 리렌더될 때마다 `Report`가 함께 렌더된다.', '렌더 생략의 조건을 `memo` 유무로만 보는 오개념. React는 이전과 같은 엘리먼트 참조를 만나면 `memo` 없이도 그 서브트리 렌더를 건너뛴다. `children`은 `Page`가 만들어 넘긴 그대로다.', false),
(9804, 3611, '스크롤로 `Fade`의 투명도는 매 프레임 갱신되지만, 그 안의 `Report`는 다시 렌더되지 않는다.', '`Fade`의 state 변경은 `Fade` 자신만 다시 실행시킨다. `children`으로 받은 엘리먼트는 `Page`가 만든 같은 참조라 렌더를 건너뛰고, 투명도는 `Fade` 자신의 렌더 결과라 그대로 갱신된다.', true),
(9805, 3611, '`children`으로 넘긴 엘리먼트는 `Fade`가 렌더될 때마다 새로 만들어져 얕은 비교가 항상 실패한다.', '엘리먼트를 누가 만드는지 헷갈린 것. `<Report />`는 `Page`의 렌더에서 만들어지므로 `Fade`가 몇 번 리렌더되든 새로 생기지 않는다. 매번 새로 생기는 쪽은 `Fade` 안에서 만든 인라인 값이다.', false),
(9806, 3611, '`Fade`의 state 변경이 `children`을 통해 `Report`의 props로 전달되어 `Report`도 다시 렌더된다.', '`children`을 부모 state가 흘러드는 통로로 오해한 것. `children`은 이미 만들어진 엘리먼트를 담아 둔 props일 뿐이라, `Fade`의 state 값은 그 안으로 전달되지 않는다.', false),

-- 문제 3612
(9807, 3612, '2', '`memo`를 붙이면 부모가 리렌더돼도 자식은 절대 다시 그려지지 않는다고 보고 초기 마운트 2회만 센 값. A에 넘긴 인라인 객체 `style`은 매 렌더 새로 만들어져 얕은 비교가 매번 실패한다.', false),
(9808, 3612, '3', '클릭 3번에 A만 다시 렌더된다는 데까지는 맞다. 하지만 화면을 처음 그릴 때 A·B가 각각 한 번씩 렌더된 마운트 2회를 빼먹었다.', false),
(9809, 3612, '5', '초기 마운트에서 A·B 각 1회로 2회. 이후 클릭마다 `List`가 리렌더되는데, `handlePick`은 `useCallback`으로 고정돼 props가 모두 같은 B는 건너뛰고, 인라인 객체 `style`이 매번 새 참조인 A만 3회 더 렌더된다.', true),
(9810, 3612, '8', '`memo`·`useCallback`이 아무 효과도 못 낸다고 보고 2 + 3×2로 센 값. `onPick`이 고정돼 넘겨받는 props가 모두 같은 B는 실제로 렌더를 건너뛴다.', false),

-- 문제 3613
(9811, 3613, '`Dashboard`는 자신의 state 변경으로 렌더됐으므로 `memo`를 붙여도 이 렌더는 막지 못한다.', '참인 진술. `memo`가 건너뛰는 것은 "부모가 리렌더됐지만 props는 같은" 경우뿐이다. Hooks changed는 자신의 state·reducer 변경이라 `memo`의 사정권 밖이다.', false),
(9812, 3613, '`ChartPanel`의 68ms를 줄이려면 부모에서 `options`·`onZoom`이 매 렌더 새 참조로 만들어지지 않게 해야 한다.', '참인 진술. 참조형 props가 매번 새로 생겨 얕은 비교가 깨진 사례다. 부모에서 `useMemo`·`useCallback`으로 참조를 고정하거나 인라인 생성을 없애는 것이 원인에 맞는 대응이다.', false),
(9813, 3613, '`Legend`는 렌더를 아예 없애도 이 커밋에서 아끼는 시간이 0.4ms뿐이라 최적화 이득이 거의 없다.', '참인 진술. 렌더가 일어났다는 사실이 아니라 그 렌더가 몇 ms인지가 판단 기준이다. 1ms도 안 걸리는 컴포넌트에 `memo`를 붙이면 비교 비용과 코드 복잡도만 남는다.', false),
(9814, 3613, '`ChartPanel`은 부모가 렌더돼서 함께 그려진 것이므로, `memo`로 감싸면 68ms를 없앨 수 있다.', '거짓이라 골라야 할 선지. 기록의 `ChartPanel`은 "The parent component rendered"가 아니라 "Props changed"다. props가 실제로 달라진 렌더는 `memo`가 건너뛰지 않으므로 68ms는 그대로 남는다.', true),

-- 문제 3614
(9815, 3614, '세 값 모두 안정된 참조를 활용할 쪽이 없거나 계산 자체가 싸서, 의존성 비교와 캐시 유지 비용만 늘어난다.', '`label`은 문자열 결합이라 메모가 더 비싸고, `style`을 받는 `Badge`는 `memo`가 아니며, `<button>` 같은 DOM 요소는 함수 참조가 바뀌어도 실제 DOM을 다시 만들지 않는다. 셋 다 이득 없이 비용만 남는다.', true),
(9816, 3614, '`style`은 `useMemo`로 감쌌으므로 `color`가 그대로인 동안 `Badge`는 렌더를 건너뛴다.', '`useMemo`가 리렌더를 막아 준다는 오개념. `useMemo`는 값의 참조를 고정할 뿐이고, 렌더를 건너뛸지 판단하는 쪽은 `memo`로 감싼 컴포넌트다. `Badge`는 `memo`가 아니라 부모가 렌더되면 함께 렌더된다.', false),
(9817, 3614, '`onClick`을 `useCallback`으로 고정했으므로 클릭 때마다 `<button>`이 다시 그려지는 것을 막아 준다.', '참조 안정성이 DOM 요소에도 이득이라는 오개념. 클릭으로 리렌더를 일으키는 것은 `setOpen`이고, `<button>`은 부모가 렌더되면 어차피 다시 평가된다. `useCallback`의 이득은 받는 쪽이 `memo`이거나 이펙트 의존성일 때만 생긴다.', false),
(9818, 3614, '`label`은 문자열이라 `useMemo`가 참조를 고정해 주는 덕에 자식의 얕은 비교를 통과시킨다.', '원시값에 참조 개념을 잘못 붙인 것. 문자열은 값으로 비교되므로 `useMemo` 없이도 내용이 같으면 `Object.is`가 참이다. 게다가 `label`은 `<h2>`에만 쓰여 얕은 비교의 대상조차 되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1160, 3615, 'React Compiler,ReactCompiler,리액트 컴파일러,리액트컴파일러,React 컴파일러,리액트 컴파일러(React Compiler)', 'React Compiler는 빌드 시점에 컴포넌트와 훅을 분석해 `useMemo`·`useCallback`·`memo`에 해당하는 최적화를 자동으로 끼워 넣는다. 그래서 화면 A는 수동 메모를 지워도 리렌더 횟수와 커밋 시간이 그대로였다. 다만 훅의 규칙과 렌더 순수성을 지킨 코드에만 적용되므로, 조건문 안에서 훅을 부른 화면 B의 두 컴포넌트는 컴파일러가 건너뛰어 메모가 사라진 만큼 리렌더가 늘었다. 런타임에 값을 캐시하는 `useMemo`와 달리 동작 시점이 빌드라는 점, 그리고 상태를 어디에 둘지 같은 구조 문제나 계산 자체의 비용은 여전히 개발자 몫이라는 점에서 구분한다.'),
       (1161, 3616, 'useMemo,use memo,usememo,유즈메모,유즈 메모', '`useMemo`는 계산 결과를 캐시해 두고 의존성 배열이 그대로면 다시 계산하지 않는다. 검색어만 바뀐 렌더에서는 정렬을 건너뛰어 90ms가 8ms로 줄고, 의존성인 상품 배열이 새로 들어온 렌더에서는 다시 정렬해 90ms가 나온 것이 이 훅의 동작 그대로다. 함수 참조를 고정하는 `useCallback`(= `useMemo(() => fn, deps)`)과 달리 여기서 아낀 것은 정렬 계산 자체이고, 컴포넌트의 렌더 결과를 기억해 자식 렌더를 건너뛰는 `React.memo`와도 역할이 다르다. 또한 `useMemo`는 그 자체로 리렌더를 막지 못하며, 캐시는 보장이 아니라 힌트라는 점도 함께 기억할 것.');

-- =====================================================
-- Lesson 730: 측정 환경 차이와 useMemo 한계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4559, 730, '아래 측정 결과를 바탕으로 한 판단으로 옳은 것은?', '검색창에 한 글자씩 입력하는 동안 개발 모드에서 Highlight updates를 켜 보니, `ProductList` 영역 전체가 키 입력마다 깜빡였다. 같은 입력을 Profiler로 두 환경에서 녹화한 결과는 아래와 같다.

| 녹화 환경 | 커밋당 렌더 시간 | `ProductList`의 Why did this render? |
|---|---|---|
| 개발 빌드 | 24ms | The parent component rendered |
| 프로덕션 프로파일링 빌드 | 4ms | The parent component rendered |', 'OBJECTIVE'),
       (4560, 730, '아래 코드에서 입력할 때마다 `HeavyList`까지 리렌더되는 문제를 해결하는 수정으로 옳은 것은?', '```tsx
function Page() {
  const [query, setQuery] = useState("");
  return (
    <main>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      <ResultCount query={query} />
      <HeavyList />
    </main>
  );
}
```

`HeavyList`는 렌더 비용이 크고 `query`와 무관하다. 수정 후에도 `ResultCount`는 입력한 검색어를 그대로 반영해야 한다.', 'OBJECTIVE'),
       (4561, 730, '아래 코드의 문제점을 바르게 짚은 것은?', '```tsx
function CheckoutPage({ cart }: { cart: CartItem[] }) {
  // 화면이 떠 있는 동안에는 항상 같은 주문 번호를 써야 한다
  const orderId = useMemo(() => crypto.randomUUID(), []);
  return <PayButton orderId={orderId} cart={cart} />;
}
```

`PayButton`은 결제 요청에 `orderId`를 실어 보내고, 서버는 같은 `orderId`로 들어온 요청을 한 번만 처리해 중복 결제를 막는다.', 'OBJECTIVE'),
       (4562, 730, '아래 코드에서 세 번의 렌더 동안 화면에 표시되는 값을 순서대로 나열한 것은?', '```tsx
function Price({ qty, rate }: { qty: number; rate: number }) {
  const total = useMemo(() => qty * rate, [qty]);
  return <p>{total}</p>;
}
```

부모가 넘기는 props는 아래 순서로 바뀌며, 그때마다 `Price`가 렌더된다. `Price`는 중간에 다시 마운트되지 않고, React가 캐시를 버리는 특수한 경우도 없다고 본다.

1. 첫 렌더: `qty` = 2, `rate` = 100
2. 두 번째 렌더: `qty` = 2, `rate` = 150
3. 세 번째 렌더: `qty` = 3, `rate` = 150', 'OBJECTIVE'),
       (4563, 730, '아래 상황에서 `SalesChart`에 적용한 API의 이름은?', '대시보드는 1초마다 현재 시각을 state로 갱신해 헤더에 표시한다. 같은 대시보드 안의 `SalesChart`는 부모가 `useMemo`로 고정한 `data` 하나만 props로 받는데, 함수 본문 첫 줄에 `console.log("chart")`를 넣어 보니 시각과 무관한데도 60초 동안 로그가 60번 찍혔다.

`SalesChart`의 컴포넌트 선언 전체를 함수 호출 하나로 감싸는 수정만 한 뒤 다시 확인하자, 첫 화면을 그릴 때 한 번 찍힌 뒤로는 60초 동안 로그가 더 찍히지 않았다. 다만 차트 안의 기간 선택 탭(`SalesChart` 내부 state)을 3번 누르자 로그가 3번 찍혔다. Strict Mode는 끈 상태로 확인했다.', 'SUBJECTIVE'),
       (4564, 730, '아래 코드의 빈칸에 들어갈 훅의 이름은?', '상품 1,000개를 그리는 목록에서 한 행을 클릭할 때마다 커밋당 렌더 시간이 45ms로 찍혔다. Profiler를 보니 `memo`로 감싼 `Row` 1,000개가 모두 Props changed: (onSelect)로 표시됐다. 원래 `handleSelect`에는 화살표 함수를 그대로 대입했는데, 아래처럼 빈칸 자리에 훅 하나를 씌우고 같은 클릭을 다시 녹화하자 Flamegraph에서 `Row`가 모두 회색으로 바뀌고 커밋당 렌더 시간은 3ms로 줄었다.

```tsx
function ProductList({ items }: { items: Product[] }) {
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const handleSelect = ________((id: number) => setSelectedId(id), []);
  return (
    <>
      <ul>
        {items.map((item) => (
          <Row key={item.id} item={item} onSelect={handleSelect} />
        ))}
      </ul>
      <Detail id={selectedId} />
    </>
  );
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4559
(12331, 4559, '개발 빌드에서 한 프레임(16ms)을 넘는 24ms가 기록됐으므로, 사용자가 느낄 만한 병목이 확인된 것이다.', '개발 빌드 수치를 그대로 믿은 오개념. 개발 빌드는 경고·검사 코드가 함께 돌아 프로덕션보다 훨씬 느리므로 최종 판단은 프로덕션 프로파일링 빌드로 한다. 같은 입력이 거기서는 4ms라 한 프레임 안에 넉넉히 끝난다.', false),
(12332, 4559, 'Highlight updates에서 목록 전체가 키 입력마다 깜빡였으므로, 렌더가 느리다는 것이 확인된 것이다.', '깜빡임을 느림의 증거로 본 오개념. Highlight updates의 깜빡임은 렌더가 일어났다는 표시일 뿐 걸린 시간을 알려 주지 않는다. 느린지는 Profiler의 ms 기록으로 판단하며, 여기서는 프로덕션 기준 4ms다.', false),
(12333, 4559, '렌더는 불필요하지만 프로덕션 기준으로 한 프레임(16ms) 안에 끝나므로, 아직 메모이제이션을 적용할 단계가 아니다.', '최적화는 렌더가 실제로 느리고 불필요할 때만 의미가 있다. The parent component rendered라 불필요한 렌더는 맞지만, 프로덕션 기준 4ms라 사용자가 느끼지 못한다. 이때 메모이제이션을 더하면 비교·메모리 비용만 늘 수 있다.', true),
(12334, 4559, '리렌더 원인이 부모 렌더이므로, 부모의 이벤트 핸들러를 `useCallback`으로 감싸면 이 렌더가 사라진다.', '`useCallback`이 리렌더를 막는다고 오해한 것. The parent component rendered는 props가 이미 같은데 부모 때문에 렌더됐다는 뜻이라, 핸들러 참조를 고정해도 달라지는 것이 없다. 참조 고정은 받는 쪽이 `memo`일 때만 효과가 난다.', false),

-- 문제 4560
(12335, 4560, '`query` state와 이를 읽는 `<input>`·`ResultCount`를 `SearchPanel`로 함께 옮기고, `Page`는 `SearchPanel`과 `HeavyList`만 렌더한다.', '`query`를 읽는 부분을 모두 한 컴포넌트로 모으면 입력 시 `SearchPanel`만 리렌더된다. `Page`는 state가 없어져 다시 실행되지 않으므로 형제인 `HeavyList`도 렌더되지 않는다. 메모이제이션 비용 없이 리렌더 범위 자체를 줄이는 구조 개선이다.', true),
(12336, 4560, '`query` state와 `<input>`만 `SearchInput`으로 옮기고, `ResultCount`와 `HeavyList`는 `Page`에 그대로 둔다.', '입력창만 떼어 내면 된다고 본 것. `ResultCount`도 `query`를 읽는데 state가 `SearchInput` 안에 갇혀 `Page`에서 넘겨줄 방법이 없어진다. 리렌더는 줄어도 검색어가 개수에 반영되지 않아 요구를 어긴다.', false),
(12337, 4560, '`query` state를 `Page`의 부모인 `App`으로 올리고, `query`와 `setQuery`를 `Page`에 props로 넘긴다.', 'state를 위로 올리면 리렌더 범위가 줄어든다고 오해한 것. 입력하면 `App`이 리렌더되고, 새 `query`를 받는 `Page`와 그 안의 `HeavyList`까지 함께 렌더되므로 범위가 오히려 넓어진다.', false),
(12338, 4560, '`onChange`에 넘기는 함수를 `useCallback`으로 감싸, 입력할 때마다 새 함수가 만들어지지 않게 한다.', '`useCallback`이 리렌더를 막는다고 오해한 것. 함수 참조를 고정해도 `setQuery`로 `Page`가 리렌더되는 것은 그대로다. `HeavyList`는 그 함수를 받지도 않아 고정된 참조를 활용할 곳이 없다.', false),

-- 문제 4561
(12339, 4561, '`crypto.randomUUID()`는 싼 계산이므로, `useMemo`를 지우고 렌더 본문에서 바로 호출하는 편이 낫다.', '싼 계산에는 `useMemo`가 필요 없다는 규칙을 목적을 따지지 않고 적용한 것. 렌더 본문에서 바로 호출하면 리렌더마다 새 UUID가 생겨, 같은 주문 번호를 유지해야 한다는 요구가 곧바로 깨진다.', false),
(12340, 4561, '의존성 배열이 비어 있으므로, `CheckoutPage`가 화면에 있는 동안 React가 같은 값을 보장해 준다.', '메모이제이션을 보장으로 오해한 것. `useMemo`는 성능을 위한 힌트라 React가 필요하면 캐시를 버리고 다시 계산할 수 있다. 빈 의존성 배열도 값이 유지된다는 약속은 아니다.', false),
(12341, 4561, '`useMemo`를 `useCallback(() => crypto.randomUUID(), [])` 형태로 바꾸면, 주문 번호가 처음 한 번만 만들어진다.', '`useCallback`이 호출 결과를 저장한다고 오해한 것. `useCallback`은 넘긴 함수 자체를 기억하므로 `orderId`에는 문자열이 아니라 함수가 담기고, 그 함수를 부를 때마다 새 UUID가 만들어진다.', false),
(12342, 4561, '`useMemo`의 캐시는 React가 버릴 수 있어 `orderId`가 새로 만들어질 수 있으므로, 값 유지를 메모이제이션에 맡기면 안 된다.', '메모이제이션의 캐시는 보장이 아닌 힌트다. 캐시가 버려지면 새 UUID가 생겨 중복 결제 방지가 깨질 수 있다. 한 번 만든 값을 유지하려면 `useState(() => crypto.randomUUID())`처럼 값 보존이 보장되는 state를 쓴다.', true),

-- 문제 4562
(12343, 4562, '200 → 300 → 450', '`useMemo`가 계산 함수 안에서 읽는 값을 알아서 추적한다고 오해한 것. 다시 계산할지는 의존성 배열에 적힌 `qty`만 비교해 정하므로, `rate`만 바뀐 두 번째 렌더에서는 계산이 다시 돌지 않는다.', false),
(12344, 4562, '200 → 200 → 450', '두 번째 렌더는 의존성 `[qty]`가 2로 같아 캐시된 200을 그대로 쓴다. 바뀐 `rate`가 반영되지 않은 낡은 값이다. 세 번째는 `qty`가 달라져 3 × 150 = 450으로 다시 계산된다. 의존성 누락이 만든 정확성 버그다.', true),
(12345, 4562, '200 → 200 → 300', '다시 계산할 때도 첫 렌더의 `rate`(100)를 계속 쓴다고 오해한 것. 재계산에는 그 렌더에서 새로 만든 계산 함수가 쓰여 당시의 `rate` = 150을 읽으므로 3 × 150 = 450이 된다.', false),
(12346, 4562, '200 → 200 → 200', '한 번 계산한 값은 다시 계산하지 않는다고 보고 의존성 배열을 `[]`처럼 취급한 것. 세 번째 렌더에서는 `qty`가 2에서 3으로 바뀌어 비교 결과가 달라지므로 계산이 다시 실행된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1476, 4563, 'memo,React.memo,React memo,memo(),React.memo(),메모,리액트 메모,리액트메모', '`memo`로 감싼 컴포넌트는 부모가 리렌더될 때 새 props를 이전 props와 필드별로 `Object.is` 비교해, 모두 같으면 렌더를 건너뛰고 이전 결과를 다시 쓴다. 시각 state가 바뀌어 대시보드가 리렌더돼도 `SalesChart`가 받는 `data`는 `useMemo`로 고정된 같은 참조라 로그가 더 찍히지 않았다. 반면 기간 선택 탭은 `SalesChart` 자신의 state 변경이라 `memo`가 막지 못하고 3번 모두 렌더됐다. 값을 기억하는 `useMemo`, 함수 참조를 기억하는 `useCallback`과 달리 컴포넌트 단위로 렌더를 건너뛰는 도구라는 점에서 구분한다. 또한 시각을 표시하는 부분만 별도 컴포넌트로 떼어 state를 내리면 `memo` 없이도 같은 문제를 풀 수 있으므로, 구조 개선을 먼저 검토하는 것이 순서다.'),
       (1477, 4564, 'useCallback,use callback,usecallback,React.useCallback,useCallback(),유즈콜백,유즈 콜백', '`useCallback`은 넘긴 함수 자체를 기억해 두고, 의존성 배열이 그대로면 렌더마다 같은 함수 참조를 돌려준다. 원래는 `ProductList`가 렌더될 때마다 새 화살표 함수가 만들어져 `memo`로 감싼 `Row`의 props 비교가 `onSelect`에서 매번 실패했고(Props changed: (onSelect)), 빈칸을 채운 뒤에는 `item`과 `onSelect`가 모두 같아 1,000개의 `Row`가 렌더를 건너뛰었다. 의존성 배열이 비어 있어도 안전한 것은 `setSelectedId` 같은 state 설정 함수가 항상 같은 참조이기 때문이다. 같은 자리에 `useMemo`를 넣으면 첫 인자를 호출한 반환값을 기억하므로 `handleSelect`에 함수가 담기지 않는다(`useCallback(fn, deps)`는 `useMemo(() => fn, deps)`와 같다). 또한 `useCallback`만으로는 리렌더를 막지 못하며, 받는 쪽인 `Row`가 `memo`였기 때문에 효과가 났다.');

-- =====================================================
-- Lesson 888: 렌더링 최적화 판단: memo가 놓치는 렌더와 렌더 시간 측정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5507, 888, '아래 코드에서 버튼을 눌러 `open`이 바뀔 때의 렌더 동작으로 옳은 것은?', '```tsx
function Page() {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button onClick={() => setOpen(!open)}>필터</button>
      <Drawer open={open}>
        <HeavyList />
      </Drawer>
    </>
  );
}

function Drawer({ open, children }: { open: boolean; children: React.ReactNode }) {
  return <aside hidden={!open}>{children}</aside>;
}
```

`HeavyList`는 props를 받지 않으며 `memo`로 감싸지 않았다. Strict Mode는 꺼져 있다.', 'OBJECTIVE'),
       (5508, 888, '아래 코드에서 1초마다 `now`가 갱신될 때 `Profile`의 렌더 동작으로 옳은 것은?', '```tsx
const UserContext = createContext<UserValue | null>(null);

function App() {
  const [user, setUser] = useState(initialUser);
  const [now, setNow] = useState(Date.now());

  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, []);

  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Clock now={now} />
      <Profile />
    </UserContext.Provider>
  );
}

const Profile = memo(function Profile() {
  const ctx = useContext(UserContext);
  return <p>{ctx?.user.name}</p>;
});
```

관찰하는 동안 `user`는 바뀌지 않는다. Strict Mode는 꺼져 있다.', 'OBJECTIVE'),
       (5509, 888, '아래 컴포넌트가 마운트된 뒤 `/api/orders` 요청에서 일어나는 일로 옳은 것은?', '```tsx
function Orders({ userId }: { userId: number }) {
  const [orders, setOrders] = useState<Order[]>([]);

  const load = async () => {
    const res = await fetch(`/api/orders?user=${userId}`);
    setOrders(await res.json());
  };

  useEffect(() => {
    load();
  }, [load]);

  return <OrderTable rows={orders} />;
}
```

`userId`는 바뀌지 않고, 서버는 매번 내용이 같은 주문 목록을 돌려준다. Strict Mode는 꺼져 있다.', 'OBJECTIVE'),
       (5510, 888, '아래 도입 계획에 대한 예상으로 옳은 것은?', 'React 19 프로젝트에 React Compiler를 도입하려 한다. 도입 전 세 화면의 코드 상태는 아래와 같다.

| 화면 | 코드 상태 |
|---|---|
| 주문 목록 | 훅의 규칙을 지키며, 직접 넣은 `useMemo`·`useCallback`·`memo`가 20여 곳에 있다. |
| 리포트 | 렌더 함수 안에서 모듈 전역 배열 `logs`에 값을 `push`하며, 사전 점검에서 렌더 순수성 위반으로 보고됐다. |
| 통계 | 사용자가 기간을 바꿀 때마다 20만 건을 새로 집계하며, 그 커밋은 120ms가 걸린다. |', 'OBJECTIVE'),
       (5511, 888, '아래 세 장면의 로그 결과를 한꺼번에 설명하는 비교 방식을 가리키는 용어는?', '`memo`로 감싼 `Chart`에 렌더될 때마다 로그를 찍게 하고, 부모 `Dashboard`를 여러 번 다시 렌더시키며 props를 세 가지로 넘겨 봤다. `Dashboard`가 렌더될 때마다 `Chart`에 전달되는 props 객체 자체는 새로 만들어진다.

| 장면 | `Dashboard`가 넘긴 props | `Chart` 로그 |
|---|---|---|
| 1 | `title="매출"`, 처음에 한 번 만들어 둔 `range` 객체(`{ from: 1, to: 7 }`) | 첫 렌더 뒤로는 찍히지 않음 |
| 2 | `title="매출"`, 렌더마다 새로 쓴 `range={{ from: 1, to: 7 }}` | 렌더마다 찍힘 |
| 3 | `title="매출"`, 장면 1의 `range`에서 `to`만 14로 직접 바꾼 같은 객체 | 찍히지 않고, 차트도 7일 기간 그대로 |', 'SUBJECTIVE'),
       (5512, 888, '아래 코드의 빈칸에 공통으로 들어갈 React 내장 컴포넌트의 이름은?', '결제 화면이 가끔 느려진다는 제보를 받고, 개발 환경에서 `Checkout`을 아래처럼 감싼 뒤 쿠폰 입력과 결제 버튼을 차례로 눌러 봤다.

```tsx
<________ id="Checkout" onRender={(id, phase, actualDuration) => {
  console.log(id, phase, actualDuration.toFixed(1));
}}>
  <Checkout />
</________>
```

콘솔에는 아래처럼 찍혔다.

```
Checkout mount 41.8
Checkout update 12.6
Checkout update 58.3
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5507
(14859, 5507, '`children`으로 받은 엘리먼트는 같은 참조로 유지되므로, `HeavyList`는 처음 한 번만 렌더된다.', 'children 분리의 결과만 기억하고 조건을 놓친 것. 참조가 유지되는 것은 엘리먼트를 만든 컴포넌트가 다시 렌더되지 않을 때다. 여기서는 `<HeavyList />`를 만든 `Page`가 state를 가져 버튼마다 새 엘리먼트가 생긴다.', false),
(14860, 5507, '`HeavyList`는 받는 props가 없으므로, 부모가 렌더돼도 React가 비교 없이 알아서 건너뛴다.', 'props가 없으면 자동으로 건너뛴다고 오해한 것. `memo`로 감싸지 않은 컴포넌트는 props가 같든 없든 부모가 렌더되면 함께 렌더된다. 이전 props와 비교해 건너뛰는 동작은 `memo`를 붙였을 때만 일어난다.', false),
(14861, 5507, '`<HeavyList />` 엘리먼트가 `Page`의 렌더마다 새로 만들어져, 버튼을 누를 때마다 `HeavyList`도 렌더된다.', 'JSX 엘리먼트는 그것을 쓴 컴포넌트의 렌더 중에 만들어진다. state를 가진 `Page`가 버튼마다 다시 실행되며 새 엘리먼트를 만들므로 `HeavyList`도 렌더된다. children 분리는 state를 가진 쪽이 감싸는 컴포넌트일 때만 효과가 있다.', true),
(14862, 5507, '`Drawer`를 `memo`로 감싸면, `open`이 바뀌어도 `Drawer`와 `HeavyList` 모두 렌더를 건너뛴다.', '`memo`가 모든 리렌더를 막는다고 오해한 것. `Drawer`는 `open` prop이 실제로 바뀌어 비교에 실패하고, `children`도 `Page`가 매번 새로 만든 엘리먼트라 같은 값으로 판단되지 않는다.', false),

-- 문제 5508
(14863, 5508, '`memo`의 props 비교는 통과하지만, `App`이 렌더될 때마다 새로 만든 `value` 때문에 매초 렌더된다.', '`memo`는 부모 렌더로 인한 렌더만 건너뛴다. `Profile`은 Context를 구독하는데 `{ user, setUser }`가 `App`의 렌더마다 새 객체로 만들어져 value가 바뀐 것으로 판단된다. Profiler에는 Context changed로 찍힌다.', true),
(14864, 5508, '`memo`로 감쌌고 받는 props도 없으므로, `user`가 바뀌기 전까지는 다시 렌더되지 않는다.', '`memo`가 모든 리렌더를 막는다고 오해한 것. `memo`는 props만 비교할 뿐, 구독한 Context의 value가 바뀌어 생기는 렌더는 막지 못한다. 여기서는 value가 매초 새 객체라 `user`가 그대로여도 렌더된다.', false),
(14865, 5508, '`value` 안의 `user`와 `setUser`가 그대로이므로, React는 이전 `value`와 같은 값으로 판단한다.', 'Context가 객체 안의 필드를 비교한다고 오해한 것. value는 `Object.is`로 비교되므로 필드가 모두 같아도 새로 만든 객체는 다른 값이다. 인라인 객체 리터럴은 렌더마다 새 참조를 만든다.', false),
(14866, 5508, '`value`를 `useMemo`로 `[user]`에 묶어 고정해도, `App`이 매초 렌더되는 한 `Profile`도 매초 렌더된다.', '`useMemo`가 리렌더를 막지 못한다는 원칙을 거꾸로 적용한 것. value가 `user`가 바뀔 때만 새로 만들어지면 Context 변경이 사라지고, 받는 props가 없는 `memo`된 `Profile`은 부모 렌더를 건너뛴다.', false),

-- 문제 5509
(14867, 5509, '의존성 배열에는 `load`뿐이므로, `userId`가 바뀌지 않는 한 요청은 마운트 때 한 번만 나간다.', '의존성으로 넣은 함수가 렌더 사이에 그대로라고 오해한 것. 컴포넌트 본문에 선언한 함수는 렌더마다 새 참조라 `Object.is` 비교에서 매번 바뀐 것으로 판단되고, 렌더가 일어날 때마다 이펙트가 다시 실행된다.', false),
(14868, 5509, '두 번째 응답은 첫 응답과 내용이 같으므로, React가 렌더를 건너뛰어 요청은 두 번에서 멈춘다.', 'state 비교가 내용을 본다고 오해한 것. `setOrders`는 새 값과 이전 값을 `Object.is`로 비교하므로, 내용이 같아도 `res.json()`이 새로 만든 배열은 다른 값이라 렌더가 다시 일어난다.', false),
(14869, 5509, '요청은 마운트 때 한 번만 나가지만, `setOrders`가 새 배열을 넣으며 `Orders`의 렌더가 끝없이 반복된다.', '렌더와 요청을 따로 떼어 본 것. `Orders`를 다시 렌더시키는 것은 응답 뒤의 `setOrders`뿐이라 요청 없이 렌더만 반복될 수 없다. 렌더마다 `load`가 바뀌어 이펙트가 요청을 다시 보내므로 둘이 함께 반복된다.', false),
(14870, 5509, '응답을 받을 때마다 요청이 다시 나가, `userId`가 그대로여도 요청이 끝없이 반복된다.', '`load`는 렌더마다 새로 만들어져 의존성 비교가 매번 실패한다. 응답 → `setOrders` → 리렌더 → 새 `load` → 이펙트 재실행 → 요청이 꼬리를 문다. `useCallback`으로 `[userId]`에 묶거나 함수를 이펙트 안으로 옮기면 멈춘다.', true),

-- 문제 5510
(14871, 5510, '통계 화면은 기간을 바꿔도 컴파일러가 넣은 메모가 이전 집계 결과를 재사용해, 120ms가 사라진다.', '메모이제이션이 계산 자체를 없애 준다고 오해한 것. 자동으로 넣은 메모도 입력이 같을 때 이전 결과를 다시 쓸 뿐이라, 기간이 바뀌어 새로 집계해야 하는 비용은 그대로다. 느린 계산 자체는 개발자가 줄여야 한다.', false),
(14872, 5510, '리포트 화면의 컴포넌트는 컴파일러가 최적화에서 건너뛰어, 도입 전과 같은 방식으로 렌더된다.', '컴파일러는 훅의 규칙과 렌더 순수성을 지킨 코드에만 최적화를 적용한다. 렌더 중에 전역 배열을 바꾸는 컴포넌트는 위반이 감지돼 건너뛰므로, 이 화면은 자동 메모이제이션 없이 도입 전과 똑같이 렌더된다.', true),
(14873, 5510, '주문 목록 화면의 수동 메모는 컴파일러와 충돌하므로, 도입 전에 반드시 모두 지워야 한다.', '컴파일러가 수동 메모와 함께 쓰일 수 없다고 오해한 것. 규칙을 지킨 코드라면 기존 `useMemo`·`useCallback`·`memo`가 있어도 컴파일된다. 도입 뒤 수동 메모를 대부분 지울 수 있게 될 뿐, 미리 지워야 하는 것은 아니다.', false),
(14874, 5510, '컴파일러는 실행 중 렌더 빈도를 관찰해, 자주 렌더되는 주문 목록 화면부터 메모를 넣는다.', '컴파일러의 동작 시점을 헷갈린 것. React Compiler는 빌드할 때 컴포넌트와 훅의 코드를 분석해 메모이제이션을 삽입한다. 실행 중 렌더 빈도를 관찰해 적용 대상을 고르지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1792, 5511, '얕은 비교,얕은비교,얕은 비교(shallow comparison),얕은 비교(shallow compare),shallow comparison,shallow compare,shallow equality,shallow equal,얕은 동등 비교,얕은 동등성 비교', '`memo`는 이전 props와 새 props를 필드별로 한 단계만 `Object.is`로 비교하는 얕은 비교를 한다. props 객체 자체는 매번 새로 만들어져도 필드인 `title`과 `range`가 각각 같으면 렌더를 건너뛰므로 장면 1은 로그가 찍히지 않는다. 장면 2는 내용이 같아도 새로 만든 객체라 참조가 달라 비교가 실패하고, 장면 3은 객체 안의 `to`가 바뀌었어도 참조가 같아 같은 props로 판단돼 낡은 7일 기간이 그대로 남는다. 객체 안쪽까지 내려가 모든 값을 비교하는 깊은 비교(deep comparison)와 구분하며, props 객체 전체의 참조만 봤다면 장면 1도 매번 렌더됐을 것이다. 그래서 `memo`된 컴포넌트에 넘기는 객체는 `useMemo`로 참조를 고정하고, 값을 바꿀 때는 직접 고치지 말고 새 객체를 만들어 넘겨야 한다.'),
       (1793, 5512, 'Profiler,React.Profiler,<Profiler>,<Profiler />,Profiler 컴포넌트,React Profiler,Profiler API,프로파일러,리액트 프로파일러,프로파일러 컴포넌트', '`<Profiler>`는 감싼 서브트리가 커밋될 때마다 `onRender`를 불러, 식별용 `id`와 처음 그린 것인지 다시 그린 것인지를 나타내는 `phase`(mount/update), 그 커밋에서 렌더에 실제로 걸린 시간 `actualDuration`(ms)을 넘긴다. 기록의 첫 줄이 mount이고 이후가 update인 것도 이 때문이다. 이름이 같은 React DevTools의 Profiler 탭은 사람이 녹화해 Flamegraph·Ranked로 살펴보는 도구이고, `<Profiler>`는 코드 안에서 렌더 시간을 수집하는 컴포넌트라는 점에서 구분한다. 또 개발 빌드는 프로덕션보다 훨씬 느리므로, 58.3ms 같은 수치로 병목을 최종 판단하기 전에 프로덕션 프로파일링 빌드에서 다시 재야 한다.');
