-- Unit: 상태 관리 전략 (Unit ID: 144)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (570, 144, 'Context 리렌더와 외부 스토어 구독'),
       (728, 144, 'URL 상태와 서버 상태, 의존성 주입'),
       (886, 144, '상태 관리 전략: 리렌더 원인 구분부터 서버 상태 캐시 신선도까지');

-- =====================================================
-- Lesson 570: Context 리렌더와 외부 스토어 구독
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3599, 570, '아래 코드에서 addItem이 호출돼 cart.count가 0에서 1로 바뀐 직후 리렌더되는 컴포넌트는?', '상점 화면이 아래와 같이 구성돼 있다.

```tsx
const AppContext = createContext(null);

function App() {
  const [user, setUser] = useState({ name: "민수" });
  const [theme, setTheme] = useState("dark");
  const [cart, setCart] = useState({ count: 0 });
  const addItem = () => setCart((c) => ({ count: c.count + 1 }));

  return (
    <AppContext.Provider value={{ user, theme, cart, addItem }}>
      <Header />
      <Sidebar />
      <CartBadge />
    </AppContext.Provider>
  );
}

const Header = React.memo(function Header() {
  const { theme } = useContext(AppContext);   // theme만 꺼내 씀
  return <h1 className={theme}>상점</h1>;
});

function Sidebar() {
  const { user } = useContext(AppContext);    // user만 꺼내 씀
  return <p>{user.name}</p>;
}

function CartBadge() {
  const { cart } = useContext(AppContext);    // cart만 꺼내 씀
  return <span>{cart.count}</span>;
}
```', 'OBJECTIVE'),
       (3600, 570, '아래 두 구현에서 user가 그대로인 채 AuthProvider가 다시 렌더될 때, AuthContext 소비자에게 일어나는 일로 옳은 것은?', '같은 인증 Context를 두 가지 방식으로 구현했다.

```tsx
// (가)
function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const login = useCallback((u) => setUser(u), []);
  const logout = useCallback(() => setUser(null), []);

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// (나)
function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const login = useCallback((u) => setUser(u), []);
  const logout = useCallback(() => setUser(null), []);
  const value = useMemo(() => ({ user, login, logout }), [user, login, logout]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}
```', 'OBJECTIVE'),
       (3601, 570, '아래 비교표에서 따라 나오는 설명으로 옳지 않은 것은?', 'Context와 외부 스토어를 항목별로 비교한 자료다.

| 항목 | Context | 외부 스토어 |
|---|---|---|
| 구독 단위 | Context 값 전체 | selector로 고른 조각 |
| 리렌더 범위 | 모든 소비자 | 고른 값이 바뀐 소비자만 |
| 트리 밖 접근 | 불가(컴포넌트 렌더 중에만) | 가능(이벤트 핸들러·유틸 함수에서도) |
| DevTools·미들웨어 | 없음 | 로깅·영속화·타임트래블 등 대부분 지원 |
| 추가 의존성 | 없음 | 있음 |', 'OBJECTIVE'),
       (3602, 570, '아래 구현에서 보고된 세 증상을 함께 해결하는 방향으로 옳은 것은?', '주문 목록 화면이 아래와 같이 구현돼 있다.

```tsx
function OrderList() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/orders")
      .then((r) => r.json())
      .then((d) => { setOrders(d); setLoading(false); });
  }, []);

  // ... 목록 렌더링
}
```

운영 중 아래 세 가지가 보고됐다.

- 주문 목록을 쓰는 화면 세 곳을 오갈 때마다 같은 요청이 새로 나간다.
- 다른 관리자가 주문 상태를 바꿔도, 화면을 새로 고치기 전까지 옛 값이 그대로 보인다.
- 응답이 실패하면 로딩 표시가 사라지지 않는다.', 'OBJECTIVE'),
       (3603, 570, '아래 코드에서 드러난 구조적 문제를 가리키는 용어는?', '```tsx
function App() {
  const [user, setUser] = useState({ name: "민수" });
  return <PageLayout user={user} />;
}

function PageLayout({ user }) {
  return (
    <main>
      <Sidebar user={user} />
    </main>
  );
}

function Sidebar({ user }) {
  return (
    <aside>
      <ProfileMenu user={user} />
    </aside>
  );
}

function ProfileMenu({ user }) {
  return <span>{user.name}</span>;
}
```

ProfileMenu에 avatarUrl을 하나 더 보여 주려고 하니 PageLayout과 Sidebar의 매개변수, 그리고 그 두 곳의 호출부까지 함께 고쳐야 했다.', 'SUBJECTIVE'),
       (3604, 570, '아래 usePrice를 대신할 React 18의 내장 훅 이름은?', '사내 대시보드는 WebSocket으로 들어오는 시세를 React 트리 밖의 전역 객체에 담아 두고, 각 컴포넌트는 아래처럼 읽는다.

```tsx
function usePrice(symbol) {
  const [price, setPrice] = useState(() => priceStore.get(symbol));
  useEffect(() => priceStore.subscribe(symbol, setPrice), [symbol]);
  return price;
}
```

동시성 기능을 켠 뒤 아래가 보고됐다.

- 같은 종목을 그리는 헤더와 표가 한 화면 안에서 서로 다른 숫자를 보여 주는 순간이 생긴다.
- 렌더가 중간에 끊겼다 이어질 때 일부 컴포넌트만 새 값으로 그려진다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3599
(9771, 3599, 'CartBadge만 리렌더된다. useContext가 구조 분해로 꺼낸 필드만 비교해, cart를 쓰는 소비자만 갱신하기 때문이다.', 'useContext는 선택적 구독을 지원하지 않는다. 구조 분해는 렌더 함수 안에서 벌어지는 일일 뿐이고, 구독 단위는 언제나 Context 값 객체 전체다. 조각 단위 구독은 selector를 제공하는 외부 스토어의 특성이다.', false),
(9772, 3599, 'Sidebar와 CartBadge만 리렌더된다. Header는 React.memo로 감싸져 있어 갱신이 차단되기 때문이다.', 'memo는 부모가 넘긴 props만 얕게 비교한다. Context 값은 props로 내려오지 않으므로 memo로 감싸도 소비자 리렌더는 막히지 않는다. Context 리렌더를 줄이려면 value 참조 안정화나 Context 분리가 필요하다.', false),
(9773, 3599, 'Header, Sidebar, CartBadge가 모두 리렌더된다. Provider에 이전과 다른 value 객체가 전달돼 세 소비자가 모두 갱신 대상이 되기 때문이다.', 'setCart로 App이 다시 렌더되면서 value 자리의 객체 리터럴이 새로 만들어진다. Context는 이 value를 Object.is로 비교하므로, 값이 그대로인 theme·user만 쓰는 Header·Sidebar까지 함께 리렌더된다.', true),
(9774, 3599, '세 컴포넌트 모두 리렌더되지 않는다. user와 theme의 참조가 그대로여서 value가 이전과 같다고 판정되기 때문이다.', 'value는 렌더할 때마다 새로 만드는 객체 리터럴이라, 안쪽 필드의 참조가 유지돼도 바깥 객체는 다른 참조다. Object.is 비교가 어긋나므로 값이 같다고 판정될 수 없다.', false),

-- 문제 3600
(9775, 3600, '(가)와 (나) 모두 소비자가 리렌더된다. Provider가 다시 렌더되면 Context 값은 언제나 새것으로 취급되기 때문이다.', 'Context는 Provider가 다시 렌더됐는지가 아니라 value의 참조가 달라졌는지를 본다. (나)는 의존성이 그대로라 useMemo가 이전 객체를 그대로 돌려주므로 소비자 리렌더가 일어나지 않는다.', false),
(9776, 3600, '(가)에서만 소비자가 리렌더된다. (가)는 렌더마다 객체 리터럴을 새로 만들고, (나)는 의존성이 그대로라 같은 객체를 다시 쓰기 때문이다.', 'useCallback으로 login·logout을 고정해도 (가)의 value는 매 렌더 새 참조다. (나)의 useMemo는 의존성 세 개가 모두 그대로면 이전 객체를 반환하므로 Object.is 비교를 통과해 소비자가 그대로 있는다.', true),
(9777, 3600, '(나)에서만 소비자가 리렌더된다. useMemo는 매 렌더 다시 실행돼 새 객체를 만들고, 객체 리터럴은 내용이 같으면 재사용되기 때문이다.', '두 도구의 역할을 뒤집은 오개념이다. useMemo는 의존성이 그대로면 계산을 건너뛰고 이전 값을 돌려주며, 객체 리터럴은 내용이 같아도 평가될 때마다 다른 참조를 만든다.', false),
(9778, 3600, '(가)와 (나) 모두 소비자가 리렌더되지 않는다. user·login·logout이 모두 그대로라 React가 value의 필드를 하나씩 비교하기 때문이다.', 'Context는 value의 필드를 얕게 비교하지 않고 Object.is로 참조 하나만 본다. 그래서 필드가 전부 그대로여도 (가)처럼 객체를 새로 만들면 값이 바뀐 것으로 판정된다.', false),

-- 문제 3601
(9779, 3601, '초당 수십 번 바뀌는 값을 여러 화면이 조금씩 나눠 쓰는 경우, 스토어 쪽이 불필요한 리렌더를 더 많이 줄인다.', '참인 진술이다. 구독 단위가 selector로 고른 조각이므로, 자기가 고른 값이 그대로인 화면은 렌더를 건너뛴다. Context였다면 값이 바뀔 때마다 소비자 전체가 다시 그려진다.', false),
(9780, 3601, '값이 드물게 바뀌고 조각 단위 구독이 필요 없다면, 의존성이 늘지 않는 Context로 충분하다.', '참인 진술이다. 스토어의 이점인 부분 구독이 필요 없는 상황이면 추가 의존성 없이 쓸 수 있는 Context가 더 알맞다. 테마·로케일·로그인 사용자가 대표적인 경우다.', false),
(9781, 3601, '상태가 바뀌어 온 이력을 되짚으며 디버깅해야 한다면, Context만으로는 도구 지원을 기대하기 어렵다.', '참인 진술이다. Context에는 DevTools·미들웨어가 없어 로깅·영속화·타임트래블이 필요하면 직접 만들어야 한다. 스토어는 대부분 이런 기능을 기본으로 제공한다.', false),
(9782, 3601, '이벤트 핸들러나 유틸 함수에서도 Context 값을 훅 없이 직접 꺼내 쓸 수 있어, 트리 밖 로직에는 스토어가 필요 없다.', '거짓이다. Context 값은 컴포넌트 렌더 중 useContext로만 읽을 수 있어 트리 밖에서는 접근할 수 없다. 로그인 만료를 감지한 인터셉터처럼 컴포넌트 밖에서 상태를 읽거나 비워야 하면 스토어가 필요하다.', true),

-- 문제 3602
(9783, 3602, '주문 목록을 서버 상태 라이브러리에 맡겨 요청을 캐시 키로 묶고, 낡음 판정 시각을 정해 백그라운드에서 다시 받아 오게 한다.', '세 증상은 각각 중복 요청 제거, 재검증, 에러 상태 관리가 없어서 생긴다. 원본이 서버에 있는 데이터의 캐시를 다루는 계층이 이 셋을 함께 맡으므로, 화면마다 만들던 로딩·에러 처리도 사라진다.', true),
(9784, 3602, '주문 목록을 Context에 올려 트리 어디서든 읽게 하면 중복 요청과 낡은 값 문제가 함께 풀린다.', 'Context는 값을 아래로 전달하는 통로일 뿐 캐시·재검증 기능이 없다. 요청 중복과 신선도 문제는 그대로 남고, 목록이 갱신될 때마다 소비자 전체가 리렌더되는 부담만 늘어난다.', false),
(9785, 3602, 'useEffect의 의존성 배열에 orders를 넣어 목록이 바뀔 때마다 다시 받아 오게 한다.', '응답이 도착하면 orders가 바뀌고 그 때문에 effect가 다시 돌아 요청이 끝없이 반복된다. 신선도는 의존성 배열이 아니라 낡음 판정 기준과 재검증 시점으로 다룰 문제다.', false),
(9786, 3602, '주문 목록을 전역 스토어에 복사해 두고, 화면마다 selector로 필요한 조각만 구독하게 한다.', 'selector는 리렌더 범위를 줄일 뿐 캐시 무효화·재검증·중복 제거를 대신하지 않는다. 서버 데이터를 스토어에 복사하면 그 로직을 직접 구현하게 되어 스토어 코드의 대부분을 차지하게 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1156, 3603, 'props drilling,prop drilling,프롭스 드릴링,프롭 드릴링,프롭스드릴링,프롭드릴링,프로퍼티 드릴링,props-drilling', '중간 컴포넌트가 자신은 쓰지 않는 값을 아래로 넘기기만 하는 구조가 props drilling이다. PageLayout과 Sidebar는 user를 화면에 그리지 않는데도 매개변수에 user를 달고 있어, 아래로 내려야 할 값이 하나 늘 때마다 경유하는 컴포넌트가 모두 바뀐다. 리렌더 성능 문제라기보다 결합도·유지보수 문제라는 점이 핵심이다. 해결책은 Context로 의존성을 주입하거나 children으로 넘기는 합성이며, 그 값이 자주 바뀌어 리렌더가 부담이 되면 외부 스토어를 고려한다. 상태를 위로 올려 공유하는 상태 끌어올리기(lifting state up)는 이 구조를 만드는 원인 쪽이라 구분해야 한다.'),
       (1157, 3604, 'useSyncExternalStore,useSyncExternalStore(),React.useSyncExternalStore,use sync external store', '외부 스토어를 React에 연결하는 표준 훅이 useSyncExternalStore(subscribe, getSnapshot)이다. useState로 값을 복사해 두고 useEffect에서 구독하는 방식은, 렌더가 여러 조각으로 나뉘어 진행되는 동안 스토어가 바뀌면 이미 그려진 컴포넌트와 아직 그려지지 않은 컴포넌트가 서로 다른 값을 쓰게 된다. 이것이 본문에 보고된 찢어짐(tearing)이다. useSyncExternalStore는 렌더 중에도 getSnapshot으로 같은 스냅숏을 읽도록 보장하고 값이 바뀌면 동기 렌더로 전환해 화면을 한 값으로 맞춘다. Zustand·Redux 같은 라이브러리도 내부적으로 이 훅을 쓴다. 값 계산을 건너뛰는 useMemo나 구독을 흉내 내는 useEffect로는 이 보장을 얻을 수 없다.');

-- =====================================================
-- Lesson 728: URL 상태와 서버 상태, 의존성 주입
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4547, 728, '아래 문의를 모두 해결하려면 검색 조건을 어디에 두어야 하는가?', '상품 목록 페이지는 검색어·정렬 기준·페이지 번호를 페이지 컴포넌트의 useState로 관리한다. 운영 중 아래 문의가 들어왔다.

- 3페이지를 보다가 새로고침하면 1페이지 기본 목록으로 돌아간다.
- "가격 낮은 순"으로 정렬한 화면의 주소를 동료에게 보냈는데, 동료에게는 기본 목록이 열린다.
- 상품 상세에 들어갔다가 브라우저의 뒤로 가기를 누르면 입력했던 검색어가 지워져 있다.', 'OBJECTIVE'),
       (4548, 728, '아래 기록에서 두 버튼의 불필요한 리렌더를 없애는 변경으로 옳은 것은?', '장바구니를 아래처럼 하나의 Context로 제공한다. 상품 목록에는 AddButton이 120개 있다.

```tsx
function CartProvider({ children }: { children: ReactNode }) {
  const [cart, setCart] = useState<Cart>({ items: [] });
  const add = useCallback((item: Item) => setCart((c) => ({ items: [...c.items, item] })), []);
  const clear = useCallback(() => setCart({ items: [] }), []);
  const value = useMemo(() => ({ cart, add, clear }), [cart, add, clear]);

  return <CartContext value={value}>{children}</CartContext>;
}

function CartBadge() {
  const { cart } = useContext(CartContext);
  return <span>{cart.items.length}</span>;
}

function AddButton({ item }: { item: Item }) {
  const { add } = useContext(CartContext);
  return <button onClick={() => add(item)}>담기</button>;
}

function ClearButton() {
  const { clear } = useContext(CartContext);
  return <button onClick={clear}>비우기</button>;
}
```

React DevTools Profiler로 "담기"를 한 번 눌렀을 때를 기록하니, Context를 읽는 컴포넌트 중 리렌더된 것은 CartBadge 1개, AddButton 120개, ClearButton 1개였다. CartBadge는 앞으로도 담긴 개수를 바로 보여 줘야 한다.', 'OBJECTIVE'),
       (4549, 728, '아래 코드에서 enqueue가 한 번 호출된 직후 리렌더되는 컴포넌트는?', '음악 플레이어 화면이 Zustand 스토어를 아래처럼 사용한다. 처음에 queue는 빈 배열이다.

```tsx
const usePlayerStore = create<PlayerState>((set) => ({
  track: { title: "Intro", artist: "Gravit" },
  volume: 0.5,
  queue: [],
  enqueue: (song) => set((s) => ({ queue: [...s.queue, song] })),
}));

function Player() {  // 스토어를 구독하지 않는 부모
  return (
    <>
      <NowPlaying />
      <VolumeLabel />
      <QueueCount />
      <QueueList />
    </>
  );
}

function NowPlaying() {
  const title = usePlayerStore((s) => s.track.title);
  return <h2>{title}</h2>;
}

function VolumeLabel() {
  const volume = usePlayerStore((s) => s.volume);
  return <span>{Math.round(volume * 100)}%</span>;
}

function QueueCount() {
  const count = usePlayerStore((s) => s.queue.length);
  return <span>대기 {count}곡</span>;
}

function QueueList() {
  const queue = usePlayerStore((s) => s.queue);
  return <ul>{queue.map((song) => <li key={song.id}>{song.title}</li>)}</ul>;
}
```', 'OBJECTIVE'),
       (4550, 728, '아래 검토표를 바탕으로 판단한 것으로 옳은 것은?', '한 앱에서 Context로 내려보낼지 검토 중인 값 네 가지다. 값마다 Context를 하나씩 따로 둔다고 가정한다.

| 값 | 바뀌는 빈도 | 읽는 컴포넌트 수 | 컴포넌트가 쓰는 부분 |
|---|---|---|---|
| 로케일 | 사용자가 설정을 바꿀 때 | 약 200개 | 값 전체 |
| 로그인 사용자 | 로그인·로그아웃 때 | 약 30개 | 값 전체 |
| 마우스 좌표 | 초당 약 60회 | 약 150개 | x·y 중 하나 |
| 편집 중인 문서(필드 500개) | 키 입력마다 | 약 80개 | 필드 하나씩 |', 'OBJECTIVE'),
       (4551, 728, '아래 사례에서 라이브러리로 옮긴 데이터는 어떤 종류의 상태에 해당하는가?', '쇼핑몰 프런트엔드의 Redux 스토어가 약 3,000줄로 불어났다. 살펴보니 그중 약 2,300줄이 아래 코드였다.

- 마지막으로 받아 온 시각을 저장해 두고, 60초가 지나면 다시 요청하는 코드
- 같은 요청이 동시에 두 번 나가지 않게 막는 플래그
- 브라우저 탭으로 돌아오면 목록을 다시 받아 오는 코드
- 요청이 실패하면 세 번까지 다시 시도하는 코드

이 코드가 다루던 회원 목록·상품 상세·알림을 데이터 요청 전용 라이브러리로 옮기자, 스토어에는 테마와 사이드바 접힘 여부만 남아 약 150줄이 됐다.', 'SUBJECTIVE'),
       (4552, 728, '아래 리팩터링에서 Context가 맡은 역할에 해당하는 설계 기법의 이름은? (React 전용 용어가 아닌 일반 소프트웨어 설계 용어로 답한다)', '결제 폼 PaymentForm은 원래 컴포넌트 안에서 `new PaymentClient("https://pay.example.com")`으로 결제 클라이언트를 만들었다. 그래서 테스트를 돌릴 때마다 실제 결제 서버로 요청이 나갔다. 아래처럼 바꾼 뒤에는 테스트할 때 PaymentForm 코드는 그대로 둔 채 가짜 클라이언트로 검사할 수 있게 됐다.

```tsx
const PaymentClientContext = createContext<PaymentClient>(realClient);

function PaymentForm({ order }: { order: Order }) {
  const client = useContext(PaymentClientContext);
  return <button onClick={() => client.pay(order)}>결제</button>;
}

// 테스트 코드
render(
  <PaymentClientContext value={fakeClient}>
    <PaymentForm order={sampleOrder} />
  </PaymentClientContext>
);
```

운영 환경에서는 앱이 실행되는 동안 이 Context 값이 한 번도 바뀌지 않는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4547
(12299, 4547, '앱 최상단의 Context로 올려, 페이지를 오가도 값이 유지되게 한다.', 'Context 값은 메모리에만 있어 앱 안에서 화면을 오갈 때는 남지만, 새로고침하면 초기화되고 주소만 받은 동료의 브라우저에는 아예 없다. 첫째·둘째 문의가 그대로 남는다.', false),
(12300, 4547, '외부 스토어에 두고, 영속화 미들웨어로 localStorage에도 함께 저장한다.', 'localStorage 덕분에 새로고침은 견디지만, 저장소는 내 브라우저에만 있어 주소를 받은 동료는 기본 목록을 본다. 조건이 주소에 담기지 않으니 둘째 문의가 풀리지 않는다.', false),
(12301, 4547, '주소의 쿼리스트링에 담고, 목록 화면은 그 값을 읽어 목록을 그린다.', '새로고침·공유·뒤로 가기를 거쳐도 살아남아야 하는 값은 URL 상태다. 조건이 주소에 있으면 새로고침해도, 주소를 받은 동료도 같은 목록을 보고, 뒤로 가기는 방문 기록의 주소를 되살리므로 검색어도 돌아온다.', true),
(12302, 4547, '데이터 요청 라이브러리의 캐시 키(queryKey)에 넣어, 조건별 결과를 캐시해 둔다.', 'queryKey는 받아 온 결과를 구분하는 캐시 이름표일 뿐, 검색 조건을 보관하는 곳이 아니다. 조건은 여전히 useState에 있어 새로고침·공유 때 사라지고, 메모리 캐시는 다른 사람 브라우저에 없다.', false),

-- 문제 4548
(12303, 4548, 'AddButton과 ClearButton을 React.memo로 감싸, 부모가 리렌더돼도 두 버튼은 건너뛰게 한다.', 'memo는 부모가 넘긴 props만 비교한다. 두 버튼이 리렌더되는 원인은 부모가 아니라 구독 중인 CartContext의 value가 바뀐 것이라, memo로 감싸도 Context 소비자의 리렌더는 막히지 않는다.', false),
(12304, 4548, 'value를 만드는 useMemo의 의존성 배열에서 cart를 빼, value 참조가 처음 값으로 고정되게 한다.', 'value가 처음 객체로 고정되면 버튼 리렌더는 사라지지만 CartBadge도 cart 변경을 받지 못해 개수가 0에 멈춘다. 참조 안정화는 값이 그대로일 때 새 객체를 만들지 않는 것이지, 바뀐 값을 숨기는 것이 아니다.', false),
(12305, 4548, 'useContext(CartContext) 호출을 모두 use(CartContext)로 바꿔, 값이 필요한 순간에만 Context를 읽게 한다.', 'React 19의 use는 조건문 안에서도 Context를 읽을 수 있게 할 뿐, 구독 방식은 useContext와 같다. value가 바뀌면 여전히 그 Context를 읽는 모든 컴포넌트가 리렌더된다.', false),
(12306, 4548, 'add·clear만 담아 참조를 고정한 Context를 따로 두고, 두 버튼은 그 Context만 읽게 한다.', 'useContext는 selector가 없어 value 일부만 바뀌어도 소비자가 모두 리렌더된다. 자주 바뀌는 cart와 거의 안 바뀌는 액션을 나누면, cart가 바뀌어도 액션 Context의 value는 같은 참조라 버튼은 리렌더되지 않는다.', true),

-- 문제 4549
(12307, 4549, 'QueueCount만 리렌더된다.', '곡이 기존 queue 배열에 더해질 뿐 배열 자체는 그대로라고 본 오개념이다. enqueue는 스프레드로 새 배열을 만들어 넣으므로 s.queue의 참조가 바뀌고, 그 배열을 고른 QueueList도 리렌더된다.', false),
(12308, 4549, 'QueueCount와 QueueList만 리렌더된다.', '외부 스토어는 selector가 돌려준 값을 이전 값과 비교해 달라진 컴포넌트만 리렌더한다. queue.length는 0에서 1로, s.queue는 새 배열로 바뀌었고, title과 volume은 그대로라 NowPlaying·VolumeLabel은 건너뛴다.', true),
(12309, 4549, 'NowPlaying, VolumeLabel, QueueCount, QueueList가 모두 리렌더된다.', 'Context처럼 스토어가 바뀌면 구독자 전체가 갱신된다고 본 오개념이다. set이 상태 객체를 새로 만들어도 selector 결과인 track.title과 volume은 이전과 같아 두 컴포넌트는 리렌더되지 않는다.', false),
(12310, 4549, '어떤 컴포넌트도 리렌더되지 않는다.', '갱신이 부모에서 자식으로만 내려온다고 본 오개념이다. 외부 스토어는 selector로 구독한 컴포넌트를 직접 갱신하므로, 구독하지 않는 Player를 거치지 않고도 값이 바뀐 컴포넌트는 리렌더된다.', false),

-- 문제 4550
(12311, 4550, '마우스 좌표를 Context로 내리면 초당 약 9,000번의 소비자 리렌더가 생길 수 있어, 외부 스토어로 옮길 신호다.', 'Context는 selector가 없어 값이 바뀔 때마다 소비자 전체가 리렌더된다. 초당 60회 × 150개로 부담이 매우 크고, 컴포넌트마다 x·y 중 하나만 쓰므로 고른 조각만 구독하는 외부 스토어가 알맞다.', true),
(12312, 4550, '로케일은 읽는 컴포넌트가 가장 많으므로, Context로 내리면 네 값 중 리렌더 부담이 가장 크다.', '부담은 소비자 수만이 아니라 소비자 수 × 변경 빈도로 본다. 로케일은 사용자가 설정을 바꿀 때만 바뀌어 200개가 리렌더되는 일이 드물다. 드물게 바뀌고 값 전체를 쓰는 전형적인 Context 대상이다.', false),
(12313, 4550, '로그인 사용자는 여러 필드를 가진 객체이므로, 드물게 바뀌더라도 Context 대신 외부 스토어에 둬야 한다.', '도구를 가르는 기준은 값의 모양이 아니라 변경 빈도와 부분 구독 필요 여부다. 로그인 사용자는 로그인·로그아웃 때만 바뀌고 값 전체를 쓰므로 Context로 충분하며, value 참조만 안정화하면 된다.', false),
(12314, 4550, '편집 중인 문서는 컴포넌트마다 필드 하나만 쓰므로, Context로 내려도 키 입력 한 번에 그 필드를 쓰는 컴포넌트만 리렌더된다.', 'useContext는 선택적 구독을 지원하지 않아, 필드 하나만 바뀌어도 문서 Context를 읽는 80개가 키 입력마다 모두 리렌더된다. 필드 단위로 구독하려면 selector를 제공하는 외부 스토어가 필요하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1472, 4551, '서버 상태,서버상태,server state,serverstate,server-state,서버 스테이트,원격 상태,remote state', '원본이 서버에 있고 클라이언트는 그 사본을 캐시로 들고 있는 데이터가 서버 상태다. 다른 사용자가 원본을 바꿀 수 있어 시간이 지나면 낡고(stale), 받아 오는 과정이 비동기라서 본문의 재요청 시각 관리·중복 요청 차단·탭 복귀 시 갱신·재시도 같은 코드가 필요해진다. 이를 전역 스토어에서 직접 구현하면 그 코드가 스토어의 대부분을 차지하게 되므로, TanStack Query·SWR 같은 서버 상태 라이브러리에 맡긴다. 스토어에 남은 테마·사이드바 접힘은 클라이언트가 소유하고 동기적으로 바뀌는 전역 UI 상태라서, 원본이 브라우저에 있다는 점에서 서버 상태와 구분된다.'),
       (1473, 4552, '의존성 주입,의존성주입,의존 관계 주입,의존관계 주입,의존성 주입(DI),dependency injection,dependencyinjection,DI,디펜던시 인젝션', '컴포넌트가 쓸 객체를 스스로 만들지 않고 바깥에서 받아 쓰게 하는 기법이 의존성 주입이다. PaymentForm은 useContext로 받은 client만 쓰고, 어떤 구현이 들어올지는 트리 위쪽의 Provider가 정한다(Provider가 없으면 createContext의 기본값인 realClient). 그래서 코드를 고치지 않고도 테스트에서는 fakeClient가 들어간다. Context의 본질은 이렇게 값을 아래로 전달하는 통로이지, 자주 바뀌는 데이터를 관리하는 상태 저장소가 아니다. 본문처럼 거의 바뀌지 않는 값이 Context에 잘 맞는 이유다. 가짜 객체를 만드는 목(mock)은 주입되는 대상일 뿐이고, 제어의 역전(IoC)은 의존성 주입을 포함하는 더 넓은 설계 원칙이라 구분한다.');

-- =====================================================
-- Lesson 886: 상태 관리 전략: 리렌더 원인 구분부터 서버 상태 캐시 신선도까지
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5495, 886, '아래 여행 예약 앱의 값 (가)~(라)에 알맞은 관리 방식을 판단한 것으로 옳은 것은?', '여행 예약 앱에서 다루는 값 네 가지다.

| 값 | 설명 |
|---|---|
| (가) | 호텔별 남은 객실 수. 서버 DB에서 받아 오며, 다른 사용자가 예약할 때마다 줄어든다. |
| (나) | 예약 정보 입력값. 투숙객·옵션·결제 수단을 세 화면에 나눠 입력하고, 화면마다 앞 단계 값을 읽어 요금을 다시 계산한다. 마지막 화면에서 서버로 제출한다. |
| (다) | 날짜 선택 달력의 펼침 여부. 같은 부모 아래에 있는 달력 버튼과 달력 패널 두 컴포넌트만 읽고 쓴다. |
| (라) | 표시 통화(원·달러). 설정 화면에서 가끔 바뀌고, 가격이 나오는 화면 대부분이 읽는다. |', 'OBJECTIVE'),
       (5496, 886, '아래 조건에서 /api/users 요청이 네트워크로 나간 시점과 횟수로 옳은 것은?', 'TanStack Query를 쓰는 사용자 목록 화면에는 UserList와 UserCount 두 컴포넌트가 있고, 둘 다 아래 훅으로 데이터를 읽는다. 두 컴포넌트는 목록 화면에 들어올 때 함께 마운트되고, 화면을 떠날 때 함께 언마운트된다.

```tsx
function useUsers() {
  return useQuery({
    queryKey: ["users"],
    queryFn: () => fetch("/api/users").then((r) => r.json()),
    staleTime: 60_000,
  });
}
```

사용자의 이동 기록은 아래와 같다.

| 시각 | 이동 |
|---|---|
| 0초 | 목록 화면에 처음 들어옴 |
| 20초 | 상세 화면으로 이동 |
| 50초 | 목록 화면으로 돌아옴 |
| 80초 | 상세 화면으로 이동 |
| 130초 | 목록 화면으로 돌아옴 |

- 응답은 요청 즉시 도착하고 항상 성공한다.
- 받은 데이터는 화면을 떠난 뒤에도 5분 동안 캐시에 남는다.
- 브라우저 탭 전환·네트워크 재연결은 없었고, staleTime 외의 옵션은 기본값이다.', 'OBJECTIVE'),
       (5497, 886, '아래 코드에서 클릭 버튼을 한 번 눌러 count가 0에서 1로 바뀐 직후, Header와 Footer 중 리렌더되는 것은?', '```tsx
const ThemeContext = createContext("light");

function App() {
  const [theme, setTheme] = useState("light");
  const [count, setCount] = useState(0);

  return (
    <ThemeContext value={theme}>
      <button onClick={() => setTheme((t) => (t === "light" ? "dark" : "light"))}>테마</button>
      <button onClick={() => setCount((c) => c + 1)}>클릭 {count}</button>
      <Header />
      <Footer />
    </ThemeContext>
  );
}

const Header = React.memo(function Header() {
  const theme = useContext(ThemeContext);
  return <h1 className={theme}>여행 예약</h1>;
});

function Footer() {
  return <footer>고객센터 1588-0000</footer>;
}
```

React 19 환경이며, React Compiler는 쓰지 않는다.', 'OBJECTIVE'),
       (5498, 886, '아래 코드에서 API 요청이 401로 실패해 인터셉터가 실행된 직후, 화면에 일어나는 일로 옳은 것은?', '로그인 정보와 테마를 Zustand 스토어 하나로 관리한다. api.ts는 컴포넌트가 아닌 일반 모듈이다.

```tsx
// store.ts
const useAppStore = create<AppState>((set) => ({
  user: { name: "민수" },
  theme: "dark",
  logout: () => set({ user: null }),
}));

// api.ts
api.interceptors.response.use(undefined, (error) => {
  if (error.response?.status === 401) {
    useAppStore.getState().logout();
  }
  return Promise.reject(error);
});

// Header.tsx
function ProfileMenu() {
  const user = useAppStore((s) => s.user);
  return user ? <span>{user.name}</span> : <a href="/login">로그인</a>;
}

function ThemeLabel() {
  const theme = useAppStore((s) => s.theme);
  return <span>{theme}</span>;
}
```', 'OBJECTIVE'),
       (5499, 886, '아래 기록에 나타난 화면 갱신 방식을 가리키는 용어는?', '게시글 좋아요 버튼의 동작을 개편한 뒤 남긴 기록이다. 두 기록 모두 버튼을 누르기 전 좋아요 수는 100이었다.

**기록 1 — 요청 성공**

| 시각 | 일어난 일 |
|---|---|
| 0ms | 버튼 클릭 → 화면의 좋아요 수 101, 하트 채워짐 |
| 0ms | POST /api/posts/7/like 전송 |
| 850ms | 200 응답 수신 → 화면 변화 없음 |

**기록 2 — 요청 실패**

| 시각 | 일어난 일 |
|---|---|
| 0ms | 버튼 클릭 → 화면의 좋아요 수 101, 하트 채워짐 |
| 0ms | POST /api/posts/7/like 전송 |
| 1,200ms | 500 응답 수신 → 화면의 좋아요 수 100, 하트 비워짐, "잠시 후 다시 시도해 주세요" 안내 |

개편 전에는 버튼을 누르면 응답이 올 때까지 버튼에 로딩 표시가 돌았고, 좋아요 수는 200 응답을 받은 뒤에야 101로 바뀌었다.', 'SUBJECTIVE'),
       (5500, 886, '아래 코드의 빈칸에 들어갈 React 훅의 이름은?', 'AuthProvider는 세션 만료까지 남은 시간을 1초마다 줄여 SessionTimer에 보여 준다. AuthContext를 읽는 소비자 40개는 모두 children 안에 있으며, 아래처럼 값을 꺼내 쓴다.

```tsx
const { user, logout } = useContext(AuthContext);
```

AuthProvider는 아래와 같고, value를 만드는 줄만 바꿨다.

```tsx
function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [secondsLeft, setSecondsLeft] = useState(1800);
  const login = useCallback((u: User) => setUser(u), []);
  const logout = useCallback(() => setUser(null), []);

  useEffect(() => {
    const id = setInterval(() => setSecondsLeft((s) => s - 1), 1000);
    return () => clearInterval(id);
  }, []);

  // 변경 전: const value = { user, login, logout };
  const value = ______(() => ({ user, login, logout }), [user, login, logout]);

  return (
    <AuthContext value={value}>
      <SessionTimer seconds={secondsLeft} />
      {children}
    </AuthContext>
  );
}
```

React DevTools Profiler로 로그인·로그아웃 없이 1분씩 기록한 결과다.

| 구간 | AuthContext 소비자 리렌더 |
|---|---|
| 변경 전 | 매초 40개, 1분 동안 총 2,400회 |
| 변경 후 | 0회 |

변경 후에도 로그아웃 버튼을 누르면 소비자 40개가 한 번씩 리렌더되며 로그인 링크로 정상적으로 바뀌었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5495
(14827, 5495, '(가)는 한 번 받아 외부 스토어에 복사해 두고, 여러 화면이 그 사본을 읽게 하는 것이 알맞다.', '스토어에 복사한 값은 받아 온 순간의 사본이라, 다른 사용자의 예약으로 서버의 객실 수가 줄어도 알 수 없다. 원본이 서버에 있는 값은 낡음 판정·재검증을 맡아 주는 서버 상태 라이브러리에 둔다.', false),
(14828, 5495, '(다)는 앱 최상단의 Context로 올려야만 달력 버튼과 달력 패널이 같은 값을 볼 수 있다.', '두 컴포넌트만 쓰는 지역 UI 상태는 가장 가까운 공통 부모로 끌어올려 useState로 두면 충분하다. 앱 전체로 올리면 값을 쓰지 않는 곳까지 관리 범위만 넓어진다.', false),
(14829, 5495, '(나)는 외부 스토어에 두고, 각 화면이 필요한 값만 골라 읽고 고치게 하는 것이 알맞다.', '서버로 제출된다고 서버 상태가 되지는 않는다. 제출 전 입력값은 원본이 브라우저에 있어 재검증할 대상이 없는 클라이언트 상태이고, 여러 화면이 읽고 고치며 요금 계산이 얽혀 있어 외부 스토어가 알맞다.', true),
(14830, 5495, '(라)는 값이 원·달러 둘 중 하나뿐이므로, 가격을 보여 주는 컴포넌트마다 useState로 따로 두는 것이 알맞다.', '컴포넌트마다 따로 두면 설정 화면에서 바꾼 통화가 다른 화면에 전해지지 않는다. 도구는 값의 단순함이 아니라 누가 읽는지와 변경 빈도로 고른다. 가끔 바뀌고 널리 읽히는 값이라 Context가 알맞다.', false),

-- 문제 5496
(14831, 5496, '0초에 1번, 130초에 1번', '같은 queryKey로 함께 마운트된 두 컴포넌트는 요청 하나를 같이 쓴다. 50초에는 받은 지 60초가 안 돼 신선하므로 캐시만 쓰고, 130초에는 낡은 캐시를 먼저 보여 준 뒤 백그라운드에서 다시 받는다.', true),
(14832, 5496, '0초에 2번, 130초에 2번', '컴포넌트마다 요청이 따로 나간다고 본 오개념이다. 같은 queryKey의 요청이 이미 진행 중이거나 캐시가 신선하면 새 요청을 만들지 않아, 두 컴포넌트가 함께 마운트돼도 요청은 1번이다.', false),
(14833, 5496, '0초, 50초, 130초에 1번씩', '다시 마운트될 때마다 새로 받는다고 본 오개념이다. 50초는 마지막으로 받은 지 50초라 staleTime(60초) 안이므로, 캐시를 신선한 것으로 보고 요청 없이 그대로 쓴다.', false),
(14834, 5496, '0초, 60초, 130초에 1번씩', 'staleTime을 자동 재요청 주기로 본 오개념이다. 60초가 지나면 캐시가 낡음으로 표시될 뿐 저절로 다시 받지 않는다. 재요청은 130초처럼 낡은 캐시를 쓰는 컴포넌트가 다시 마운트될 때 일어난다.', false),

-- 문제 5497
(14835, 5497, 'Header와 Footer 모두 리렌더된다.', 'App이 렌더되면 Provider 아래가 모두 갱신된다고 본 오개념이다. Header는 React.memo라 props가 같으면 건너뛰고, value인 문자열 "light"도 Object.is로 이전과 같아 Context 쪽 리렌더 원인도 없다.', false),
(14836, 5497, 'Header만 리렌더된다.', 'Provider가 렌더되면 소비자가 늘 갱신된다고 본 오개념이다. Context는 value가 Object.is로 달라졌을 때만 소비자를 갱신하는데 theme은 그대로다. 또 React.memo가 없는 Footer는 부모를 따라 리렌더된다.', false),
(14837, 5497, '둘 다 리렌더되지 않는다.', 'props도 Context도 없는 컴포넌트는 건너뛴다고 본 오개념이다. React.memo로 감싸지 않은 컴포넌트는 넘겨받은 props가 같아도 부모 App이 렌더되면 함께 리렌더된다.', false),
(14838, 5497, 'Footer만 리렌더된다.', '리렌더 원인은 부모의 렌더와 Context 값 변경 두 갈래다. Footer는 React.memo가 없어 부모를 따라 리렌더되고, Header는 memo가 부모 쪽 원인을 막고 theme이 Object.is로 같아 Context 쪽 원인도 없다.', true),

-- 문제 5498
(14839, 5498, '인터셉터가 컴포넌트 밖에서 스토어를 호출해 오류가 나고, ProfileMenu는 계속 "민수"를 보여 준다.', '훅 규칙은 useAppStore(selector)처럼 훅으로 부를 때만 적용된다. getState()는 스토어 객체의 일반 함수라 컴포넌트가 아닌 모듈에서도 상태를 읽고 바꿀 수 있다. 트리 밖 접근은 외부 스토어가 Context와 갈리는 지점이다.', false),
(14840, 5498, 'ProfileMenu가 곧바로 리렌더돼 로그인 링크를 보여 주고, ThemeLabel은 리렌더되지 않는다.', 'set으로 스토어가 바뀌면 구독 중인 컴포넌트마다 selector 결과를 이전과 비교한다. user는 null로 바뀌어 ProfileMenu만 리렌더되고, theme은 "dark" 그대로라 ThemeLabel은 건너뛴다.', true),
(14841, 5498, '스토어의 user는 null이 되지만, ProfileMenu는 다른 이유로 리렌더될 때까지 "민수"를 보여 준다.', '컴포넌트 밖에서 바꾼 값은 늦게 반영된다고 본 오개념이다. 스토어는 누가 값을 바꿨든 구독자에게 곧바로 알리므로, 인터셉터에서 호출한 logout도 즉시 화면에 반영된다.', false),
(14842, 5498, 'ProfileMenu가 로그인 링크를 보여 주고, 같은 스토어를 구독하는 ThemeLabel도 함께 리렌더된다.', '스토어가 바뀌면 구독자 전체가 갱신된다고 본 Context식 오개념이다. 외부 스토어는 selector가 고른 값을 이전과 비교하므로, theme이 그대로인 ThemeLabel은 리렌더되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1788, 5499, '낙관적 업데이트,낙관적 갱신,낙관적 UI,낙관적 UI 업데이트,낙관적업데이트,optimistic update,optimistic updates,optimistic UI,optimistic updating,옵티미스틱 업데이트,옵티미스틱 UI', '서버 응답을 기다리지 않고 요청이 성공하리라 가정해 화면을 먼저 바꾸고, 실패하면 이전 값으로 되돌리는 방식이 낙관적 업데이트다. 기록 1에서 0ms에 좋아요 수가 101이 되고 200 응답 뒤에는 변화가 없는 것, 기록 2에서 500 응답 뒤 100으로 돌아가는 것(롤백)이 그 두 단계다. 원본이 서버에 있는 서버 상태를 고칠 때 체감 속도를 높이려고 쓰며, TanStack Query 같은 서버 상태 라이브러리가 이전 값 보관·롤백·응답 뒤 재검증을 돕는다. 개편 전처럼 응답을 받은 뒤에야 화면을 바꾸는 방식은 비관적 업데이트(pessimistic update)라 부르며 구분한다. 또 낡은 캐시를 먼저 보여 주고 뒤에서 다시 받아 오는 백그라운드 재검증은 이미 받은 서버 데이터를 새로 고치는 일이고, 낙관적 업데이트는 사용자가 만든 변경을 응답 전에 미리 반영하는 일이라 다르다.'),
       (1789, 5500, 'useMemo,useMemo(),React.useMemo,React.useMemo(),유즈메모,유즈 메모,use memo', 'useMemo는 의존성 배열의 값이 이전과 모두 같으면 계산을 건너뛰고 이전에 만든 값을 그대로 돌려준다. 변경 전에는 secondsLeft가 바뀌어 AuthProvider가 렌더될 때마다 객체 리터럴이 새로 만들어졌고, Context는 value를 Object.is로 비교하므로 user가 그대로여도 소비자 40개가 매초 리렌더됐다. useMemo로 감싸면 user·login·logout이 그대로인 동안 같은 참조가 유지돼 소비자 리렌더가 사라지고, 로그아웃으로 user가 바뀔 때만 새 객체가 만들어진다. login·logout을 useCallback으로 고정해 둔 것도 의존성이 매 렌더 바뀌지 않게 하려는 것이다. 빈칸에 함수 자체를 기억하는 useCallback을 넣으면 value가 객체가 아니라 함수가 되어 소비자가 user를 꺼낼 수 없다. 소비자를 React.memo로 감싸는 방법은 Context 값 변경에 따른 리렌더를 막지 못한다는 점도 구분한다.');
