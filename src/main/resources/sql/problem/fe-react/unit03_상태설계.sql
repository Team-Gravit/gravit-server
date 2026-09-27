-- Unit: 상태 설계 (Unit ID: 143)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (569, 143, '상태 끌어올리기와 단일 진실 공급원'),
       (727, 143, '파생 상태와 key 초기화, 정규화'),
       (885, 143, 'React 상태 설계 실전: 렌더 범위·상태 모양·상태 전이 다루기');

-- =====================================================
-- Lesson 569: 상태 끌어올리기와 단일 진실 공급원
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3593, 569, '아래 컴포넌트가 처음 화면에 그려질 때의 동작으로 옳은 것은?', '```tsx
type Item = { id: number; price: number };

function Cart({ items }: { items: Item[] }) {
  const [total, setTotal] = useState(0);

  useEffect(() => {
    setTotal(items.reduce((sum, i) => sum + i.price, 0));
  }, [items]);

  return <p>합계: {total}원</p>;
}
```

부모는 Cart에 `items={[{ id: 1, price: 12000 }, { id: 2, price: 8000 }]}`를 내려준다.', 'OBJECTIVE'),
       (3594, 569, '아래 코드에서 변경 버튼을 한 번 누른 직후 나타나는 결과로 옳은 것은?', '```tsx
function Parent() {
  const [name, setName] = useState("김철수");
  return (
    <>
      <button onClick={() => setName("이영희")}>변경</button>
      <Profile name={name} />
    </>
  );
}

function Profile({ name }: { name: string }) {
  const [draft, setDraft] = useState(name);
  return <input value={draft} onChange={(e) => setDraft(e.target.value)} />;
}
```

사용자는 input을 한 글자도 건드리지 않은 채 변경 버튼만 눌렀다.', 'OBJECTIVE'),
       (3595, 569, '아래 트리에서 검색어 상태 keyword를 둘 위치에 대한 설명으로 옳은 것은?', '```
App
├─ Header          (로고와 알림 아이콘만 그린다)
└─ Main
   ├─ SearchBar    (사용자가 검색어를 입력해 값을 바꾼다)
   └─ ResultList   (검색어로 걸러낸 결과를 보여준다)
      └─ ResultItem (결과 한 건을 그린다)
```

keyword를 읽거나 쓰는 컴포넌트는 SearchBar와 ResultList 둘뿐이다.', 'OBJECTIVE'),
       (3596, 569, '아래 두 상태 설계를 비교한 설명으로 옳지 않은 것은?', '같은 요청 화면을 A와 B 두 가지 방식으로 구현했다.

| 구분 | 상태 선언 | 표현 가능한 조합 |
|---|---|---|
| A | isLoading, isError, isSuccess 세 개의 boolean | 2 × 2 × 2 = 8가지 |
| B | status 한 개 (idle, loading, error, success 중 하나) | 4가지 |

두 설계 모두 응답 데이터는 별도 변수에 담는다.', 'OBJECTIVE'),
       (3597, 569, '아래 리팩터링에서 selected 상태에 적용한 기법의 이름은?', '탭 화면은 형제 컴포넌트 TabButtons와 TabPanel로 이뤄져 있다.

리팩터링 전에는 TabButtons 안에 `const [selected, setSelected] = useState(0)`이 있었고, 버튼을 눌러 selected가 1로 바뀌어도 TabPanel은 계속 0번 탭 내용만 보여줬다.

리팩터링 뒤 TabButtons에는 useState 줄이 남지 않았고, 두 컴포넌트를 감싸는 Tabs가 selected를 관리한다. TabButtons는 onSelect를, TabPanel은 selected를 props로 받는다.', 'SUBJECTIVE'),
       (3598, 569, '아래 상황에서 깨졌다가 회복된 상태 설계 원칙의 이름은?', '상품 목록 화면은 서버에서 받은 items 배열을 상태로 두고, 사용자가 고른 항목을 selectedItem이라는 또 다른 상태에 객체째 복사해 둔다.

목록에서 어떤 상품의 가격을 12,000원에서 9,900원으로 수정하자 왼쪽 목록은 9,900원으로 바뀌었는데, 오른쪽 상세 패널은 12,000원을 그대로 보여줬다.

selectedItem을 지우고 selectedId만 남긴 뒤 렌더 중 `items.find(i => i.id === selectedId)`로 항목을 찾도록 고치자 두 화면의 값이 다시 같아졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3593
(9755, 3593, '이펙트가 렌더보다 먼저 실행되므로 첫 화면부터 합계 20,000원이 그려지고 렌더는 1회로 끝난다.', '이펙트는 렌더 결과가 화면에 반영된 뒤에 실행된다. 첫 렌더 시점에 total이 가진 값은 useState 초기값 0뿐이라 20,000원이 나올 수 없다.', false),
(9756, 3593, '첫 렌더에서 합계 0원이 그려진 뒤 이펙트의 setTotal이 실행돼 20,000원으로 리렌더된다.', 'useState(0)이 첫 렌더를 지배하고, 커밋 후 이펙트가 setTotal로 상태를 바꿔 렌더가 한 번 더 돈다. 원본 items와 사본 total이 잠시 어긋나는 구간이 이 두 렌더 사이다.', true),
(9757, 3593, 'setTotal이 상태를 바꿔 리렌더되고 그 리렌더가 이펙트를 다시 실행시켜 무한 루프에 빠진다.', '의존성 배열 [items]가 그대로면 이펙트는 다시 실행되지 않는다. 무한 루프는 의존성 배열을 아예 빠뜨렸을 때 생기는 증상이지 여기서는 일어나지 않는다.', false),
(9758, 3593, 'total은 마운트 시 한 번만 채워지므로 이후 부모가 items를 바꿔도 합계 20,000원이 그대로 남는다.', '의존성 배열에 items가 있어 items가 바뀌면 이펙트가 다시 실행된다. 마운트 때 한 번만 실행되는 것은 의존성 배열이 빈 [] 일 때다.', false),

-- 문제 3594
(9759, 3594, 'Profile이 리렌더되면서 useState(name)이 새 props를 읽어 input에 이영희가 표시된다.', 'useState의 인자는 마운트 때 한 번만 초기값으로 쓰인다. 이후 렌더에서는 인자가 무시되고 React가 보관 중인 draft 값이 그대로 반환된다.', false),
(9760, 3594, 'name props가 바뀌면 Profile이 언마운트 후 다시 마운트되므로 input이 빈 문자열이 된다.', '같은 자리에 같은 타입으로 있는 컴포넌트는 props가 바뀌어도 리렌더될 뿐 다시 마운트되지 않는다. 재마운트로 상태를 초기화하려면 key를 바꿔야 한다.', false),
(9761, 3594, 'draft가 다음 렌더에서 이영희로 갱신되므로 화면에는 한 박자 늦게 이영희가 나타난다.', '늦게 반영되는 것이 아니라 아예 반영되지 않는다. props를 상태로 복사해 두면 이후의 props 변경이 draft까지 흘러갈 경로 자체가 없다.', false),
(9762, 3594, 'Profile은 리렌더되지만 input에는 김철수가 그대로 남아 부모의 name과 어긋난다.', 'props를 useState 초기값으로 복사한 파생 상태라 마운트 시점 스냅샷이 계속 살아남는다. 값을 항상 따라가게 하려면 draft를 없애고 props를 직접 쓰거나 부모가 값을 소유해야 한다.', true),

-- 문제 3595
(9763, 3595, 'keyword를 Main에 두면 값이 바뀔 때 다시 그려지는 범위가 Main 아래로 제한돼 Header는 렌더에서 빠진다.', '상태가 바뀌면 그 상태를 가진 컴포넌트부터 아래로 렌더가 내려간다. 공통 조상 중 가장 가까운 Main에 두면 keyword와 무관한 Header가 렌더 대상에서 제외된다.', true),
(9764, 3595, 'keyword를 App에 올려야 SearchBar가 바꾼 값이 ResultList까지 전달될 수 있다.', '전달은 공통 조상이기만 하면 성립한다. Main이 이미 둘의 공통 조상이라 App까지 올릴 이유가 없고, 올리면 keyword를 쓰지도 않는 Header까지 리렌더된다.', false),
(9765, 3595, 'keyword를 SearchBar의 지역 상태로 두고 형제인 ResultList가 SearchBar에게서 props로 받아 오면 된다.', 'props는 부모에서 자식으로만 내려간다. 형제 사이에는 전달 경로가 없어 공통 부모를 거치지 않으면 두 컴포넌트가 같은 값을 공유할 수 없다.', false),
(9766, 3595, 'keyword를 ResultList에 두면 SearchBar가 setKeyword를 호출할 수 있어 props 전달 단계가 줄어든다.', 'SearchBar는 ResultList의 자식이 아니라 형제라서 setKeyword를 받을 방법이 없다. 상태를 읽고 쓰는 컴포넌트가 모두 그 아래에 있어야 성립하는 배치다.', false),

-- 문제 3596
(9767, 3596, 'A에서 요청이 성공하면 isLoading을 false로, isSuccess를 true로 각각 되돌려야 해 한쪽을 빠뜨리면 화면이 어긋난다.', '상태 변수가 셋이라 전이가 일어날 때마다 세 값을 함께 맞춰야 한다. 동기화 지점이 늘어난 만큼 한쪽만 갱신하는 실수가 생길 자리도 늘어난다.', false),
(9768, 3596, 'B는 값이 4가지뿐이라 화면 분기를 네 갈래로 나누면 처리되지 않고 남는 경우가 없다.', 'status가 가질 수 있는 값과 화면 분기가 1대 1로 맞아떨어진다. 유니온 타입이면 처리하지 않은 갈래를 편집기나 타입 검사 단계에서 잡아낼 수 있다.', false),
(9769, 3596, 'A는 isLoading과 isError가 동시에 true인 조합을 타입이 막아 주므로 두 값을 함께 검사할 필요가 없다.', '표의 8가지 조합에는 두 값이 함께 true인 경우도 들어 있다. 서로 독립인 boolean 셋은 상대를 제약하지 못하므로 모순 조합은 타입이 아니라 사람이 쓴 코드가 막아야 한다.', true),
(9770, 3596, 'A의 8가지 중 4가지는 실제로는 일어나면 안 되는 조합이라 코드가 그만큼 방어를 떠안는다.', '의미 있는 조합은 B가 표현하는 4가지뿐이고, 로딩이면서 에러 같은 나머지 4가지는 모순이다. 그 모순을 걸러 내는 방어 코드가 A가 치르는 비용이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1154, 3597, '상태 끌어올리기,상태 끌어 올리기,상태끌어올리기,상태 끌어올림,lifting state up,lift state up,state lifting,리프팅 스테이트 업', '형제끼리는 props로 값을 주고받을 수 없다. 그래서 두 컴포넌트가 함께 쓰는 값은 가장 가까운 공통 조상으로 옮겨야 하고, 이 이동이 상태 끌어올리기다. 올린 뒤 자식은 상태를 소유하지 않고 값(selected)과 변경 요청(onSelect)만 받는다. 파생 상태 제거와 헷갈리기 쉬운데, 파생 상태 제거는 계산으로 대체해 상태 자체를 없애는 일이고 끌어올리기는 상태를 없애지 않고 소유자만 바꾼다. 또 무작정 App까지 올리는 것과도 구분해야 한다. 공통 조상 중 가장 가까운 곳을 넘어서면 그 값을 쓰지도 않는 형제까지 리렌더 대상이 된다.'),
       (1155, 3598, '단일 진실 공급원,단일 진실 공급원 원칙,단일 진실 공급처,진실의 단일 출처,single source of truth,SSOT,싱글 소스 오브 트루스', '같은 데이터를 두 곳에 두면 한쪽만 갱신되는 순간 화면이 어긋난다. items가 원본이고 selectedItem은 그 시점의 사본이었기 때문에 가격 수정이 사본까지 닿지 못한 것이다. 사본 대신 원본을 가리키는 키(selectedId)만 들고 렌더 중에 찾으면 값의 출처가 언제나 하나로 유지된다. 파생 상태를 지양하라는 지침과 이어져 있지만 층위가 다르다. 파생 상태 지양은 계산할 수 있는 값을 상태로 두지 말라는 구체 지침이고, 단일 진실 공급원은 그 지침이 지키려는 상위 원칙이다.');

-- =====================================================
-- Lesson 727: 파생 상태와 key 초기화, 정규화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4541, 727, '아래 컴포넌트의 useState 선언 네 개를 정리하는 방안으로 옳은 것은?', '```tsx
type Product = { id: number; name: string };

function ProductSearch({ products }: { products: Product[] }) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<Product[]>(products);
  const [timerId, setTimerId] = useState<number | null>(null);
  const [pageSize] = useState(20);

  useEffect(() => {
    setResults(products.filter((p) => p.name.includes(query)));
  }, [products, query]);

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const next = e.target.value;
    setQuery(next);
    if (timerId !== null) clearTimeout(timerId);
    setTimerId(window.setTimeout(() => sendSearchLog(next), 500));
  }

  return (
    <>
      <input value={query} onChange={handleChange} />
      <ProductList items={results.slice(0, pageSize)} />
    </>
  );
}
```

sendSearchLog는 마지막 입력 후 0.5초가 지나면 검색어를 서버 로그로 보내는 함수다.', 'OBJECTIVE'),
       (4542, 727, '아래 표의 상태 중 지금 선언한 컴포넌트에서 공통 부모로 끌어올려야 하는 것은?', '쇼핑몰 화면에서 쓰는 상태 네 개를 정리한 표다.

| 상태 | 선언한 컴포넌트 | 값이 필요한 컴포넌트 | 비고 |
|---|---|---|---|
| isTooltipOpen | InfoIcon | InfoIcon | 한 화면에 InfoIcon이 12개 그려지고, 아이콘마다 자기 툴팁만 열고 닫는다 |
| step | CheckoutWizard | CheckoutWizard, StepIndicator | StepIndicator는 CheckoutWizard가 렌더하는 자식이다 |
| sortOrder | SortSelect | SortSelect, ProductGrid | ProductGrid는 SortSelect에서 고른 순서로 상품을 정렬해 그리며, 두 컴포넌트는 형제다 |
| isMenuOpen | Menu | Menu | 나중에 Header에서도 메뉴를 닫게 될지 모른다는 의견이 있다 |', 'OBJECTIVE'),
       (4543, 727, '아래 코드에서 마지막 클릭 직후 두 ScoreEditor에 표시되는 값은?', '```tsx
const scores: Record<number, number> = { 1: 10, 2: 50 };

function Page() {
  const [userId, setUserId] = useState(1);
  return (
    <>
      <button onClick={() => setUserId(2)}>다음 사용자</button>
      <ScoreEditor initialScore={scores[userId]} />
      <ScoreEditor key={userId} initialScore={scores[userId]} />
    </>
  );
}

function ScoreEditor({ initialScore }: { initialScore: number }) {
  const [score, setScore] = useState(initialScore);
  return <button onClick={() => setScore(score + 1)}>{score}</button>;
}
```

화면이 처음 그려진 뒤 사용자는 첫 번째 ScoreEditor를 두 번, 두 번째 ScoreEditor를 한 번 누르고, 마지막으로 다음 사용자 버튼을 눌렀다.', 'OBJECTIVE'),
       (4544, 727, '아래 컴포넌트 구조에 대한 설명으로 옳은 것은?', '상태를 부모로 끌어올리고 나면 자식 컴포넌트에는 useState가 남지 않는다. 무엇을 그릴지는 부모가 내려준 값 props(예: isOpen)로만 정해지고, 사용자가 버튼을 누르면 자식은 부모가 내려준 함수 props(예: onToggle)를 호출해 값을 바꿔 달라고 요청할 뿐이다.', 'OBJECTIVE'),
       (4545, 727, '아래 A 코드의 isValid처럼 설계된 상태를 가리키는 용어는?', '회원가입 폼의 가입 버튼은 isValid가 true일 때만 켜진다. 같은 폼을 A와 B 두 가지 방식으로 구현했다.

```tsx
// A
const [email, setEmail] = useState("");
const [password, setPassword] = useState("");
const [isValid, setIsValid] = useState(false);

function onEmailChange(v: string) {
  setEmail(v);
  setIsValid(v.includes("@") && password.length >= 8);
}
function onPasswordChange(v: string) {
  setPassword(v);
  setIsValid(email.includes("@") && v.length >= 8);
}
function onClearPassword() {
  setPassword("");
}
```

```tsx
// B (onEmailChange, onPasswordChange는 setEmail, setPassword만 호출)
const [email, setEmail] = useState("");
const [password, setPassword] = useState("");
const isValid = email.includes("@") && password.length >= 8;

function onClearPassword() {
  setPassword("");
}
```

QA에서 두 폼 모두 올바른 이메일과 8자리 비밀번호를 넣어 가입 버튼이 켜진 것을 확인한 뒤 [비밀번호 지우기]를 눌렀다. B는 버튼이 곧바로 꺼졌지만, A는 비밀번호 칸이 비었는데도 버튼이 켜진 채 남아 빈 비밀번호로 가입 요청이 나갔다.', 'SUBJECTIVE'),
       (4546, 727, '아래 A에서 B로의 변경처럼 상태의 형태를 바꾸는 작업을 가리키는 용어는?', '게시글 댓글 상태를 A 형태에서 B 형태로 바꿨다.

```ts
// A
const comments = [
  { id: 1, text: "좋은 글이네요", replies: [
    { id: 2, text: "동의합니다", replies: [
      { id: 3, text: "저도요", replies: [] },
    ] },
  ] },
];

// B
const comments = {
  1: { id: 1, text: "좋은 글이네요", replyIds: [2] },
  2: { id: 2, text: "동의합니다", replyIds: [3] },
  3: { id: 3, text: "저도요", replyIds: [] },
};
```

A일 때는 id가 3인 댓글의 text 하나를 고치려고 트리를 재귀로 내려가며 경로 위 객체를 한 단계씩 복사하는 28줄짜리 함수를 썼고, 복사를 한 단계 빠뜨려 이전 상태 객체를 직접 바꾸는 버그가 두 번 났다. B로 바꾼 뒤에는 같은 수정이 아래 한 줄로 끝났다.

```ts
setComments({ ...comments, 3: { ...comments[3], text: "수정됨" } });
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4541
(12283, 4541, 'query는 사용자가 입력한 문자열일 뿐이므로 useRef로 옮겨도 타이핑한 글자가 입력칸에 그대로 보인다.', 'input이 value={query}로 값을 받는 구조라 입력칸 화면은 query를 따라간다. ref는 바꿔도 리렌더를 일으키지 않으므로 입력칸이 새 글자를 그리지 못하고 이전 값에 머문다. 화면에 보여야 하는 값은 상태여야 한다.', false),
(12284, 4541, 'results는 useEffect로 맞추고 있으므로 query가 바뀐 그 렌더의 결과에 이미 걸러진 목록이 들어간다.', '이펙트는 렌더가 커밋된 뒤에 실행된다. query만 바뀐 첫 렌더 결과에는 이전 results가 들어가고, setResults 뒤 렌더가 한 번 더 돈다. products와 query로 렌더 중에 걸러 내면 렌더 1회로 끝난다.', false),
(12285, 4541, 'timerId는 useRef로 옮겨도 이전 타이머 취소가 그대로 되고 화면에 그려지는 결과도 달라지지 않는다.', 'timerId는 clearTimeout에 넘길 때만 쓰이고 JSX 어디에도 그려지지 않는다. 렌더 사이에 값만 기억하면 되므로 ref.current에 담아도 취소 동작은 같고, 바뀌어도 화면이 그대로인 값을 상태로 둘 이유가 없다.', true),
(12286, 4541, 'pageSize는 useState로 선언해야만 리렌더 뒤에도 20이 유지되므로 지금 형태를 그대로 둔다.', '한 번도 바뀌지 않는 값은 렌더마다 새로 만들어져도 늘 20이다. useState는 바뀌는 값을 렌더 사이에 보존할 때 쓰므로, pageSize는 컴포넌트 밖 상수 PAGE_SIZE로 빼는 편이 맞다.', false),

-- 문제 4542
(12287, 4542, 'isTooltipOpen', '아이콘이 12개여도 각자 자기 툴팁만 열고 닫으며 서로의 열림 여부를 볼 일이 없다. 한 컴포넌트 안에서 끝나는 값이라 지역 상태가 맞고, 올리면 툴팁 하나만 열어도 12개 아이콘이 모두 리렌더된다.', false),
(12288, 4542, 'sortOrder', '값을 바꾸는 SortSelect와 그 값으로 정렬하는 ProductGrid가 형제다. props는 부모에서 자식으로만 흐르므로 둘의 공통 부모로 올려야 한쪽의 변경이 다른 쪽 표시에 닿는다.', true),
(12289, 4542, 'step', '필요한 컴포넌트가 둘이지만 StepIndicator가 CheckoutWizard의 자식이라 이미 가장 가까운 공통 조상에 선언돼 있다. props로 내려주면 충분하고, 더 올리면 step과 무관한 컴포넌트까지 리렌더된다.', false),
(12290, 4542, 'isMenuOpen', '"나중에 쓸지 모른다"는 끌어올리기 기준이 아니다. 지금은 Menu만 쓰므로 지역 상태로 두고, Header가 실제로 값을 필요로 할 때 올려도 비용이 크지 않다. 미리 올리면 결합도와 리렌더만 늘어난다.', false),

-- 문제 4543
(12291, 4543, '첫 번째 50, 두 번째 50', 'useState의 인자는 마운트 때 한 번만 초기값으로 쓰인다. key가 없는 첫 번째 ScoreEditor는 같은 자리에서 리렌더만 되므로 새 initialScore 50을 무시하고 누른 결과 12를 유지한다.', false),
(12292, 4543, '첫 번째 12, 두 번째 11', '첫 번째는 맞게 봤지만 두 번째의 key를 놓쳤다. key가 1에서 2로 바뀌면 React는 다른 컴포넌트로 보고 기존 것을 언마운트한 뒤 새로 마운트하므로 11은 버려지고 새 초기값이 쓰인다.', false),
(12293, 4543, '첫 번째 50, 두 번째 11', 'key가 상태를 지켜 준다고 거꾸로 이해한 것이다. key가 없어도 같은 위치·같은 타입이면 상태가 보존되고, 오히려 key가 바뀌어야 상태가 버려지고 새로 마운트된다.', false),
(12294, 4543, '첫 번째 12, 두 번째 50', '첫 번째는 같은 자리에서 리렌더만 돼 초기값 스냅샷 10에서 두 번 누른 12가 남는다. 두 번째는 key가 바뀌어 새로 마운트되므로 useState가 새 props 50으로 초기화된다. props 변경에 맞춰 상태를 리셋하려면 key를 바꾼다.', true),

-- 문제 4544
(12295, 4544, '부모에 [모두 접기] 버튼을 달면 자식 코드를 고치지 않고도 열린 자식을 한 번에 모두 닫을 수 있다.', '자식의 열림 여부는 전적으로 부모가 내려주는 값에 달려 있다. 부모가 자기 상태를 모두 닫힘으로 바꾸면 다음 렌더에서 자식이 그대로 따라 닫히므로, 밖에서 값을 읽거나 리셋해야 하는 요구를 자식 수정 없이 풀 수 있다.', true),
(12296, 4544, '사용자가 자식의 버튼을 누르면 자식이 먼저 자기 화면을 바꾸고 이어서 부모에게 바뀐 값을 알린다.', '자식은 그릴 값을 스스로 들고 있지 않아 먼저 화면을 바꿀 수 없다. 콜백을 받은 부모가 상태를 바꿔 리렌더돼야 새 props가 내려오고, 그제야 자식 화면이 바뀐다. 순서가 반대다.', false),
(12297, 4544, '자식이 받은 isOpen에 isOpen = true처럼 직접 값을 넣으면 콜백 없이도 부모 상태가 함께 바뀐다.', 'props는 읽기 전용 입력이다. 매개변수 isOpen에 새 값을 넣어도 그 렌더 함수 안의 지역 변수만 바뀔 뿐 부모 상태는 그대로이고 리렌더도 일어나지 않는다. 값을 바꾸려면 콜백으로 요청해야 한다.', false),
(12298, 4544, '같은 자식을 여러 개 렌더하면 모두 부모 상태 하나를 바라보므로 자식마다 다른 값을 보여 줄 수 없다.', '부모는 상태 하나로 자식마다 다른 값을 계산해 내려줄 수 있다. 아코디언이 activeIndex 하나로 isOpen={activeIndex === 0}, isOpen={activeIndex === 1}을 나눠 주는 것이 그 예다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1470, 4545, '파생 상태,파생된 상태,파생상태,파생 state,derived state,redundant state,불필요한 상태,불필요한 state', 'A의 isValid는 email과 password만 있으면 언제든 계산할 수 있는데도 useState에 따로 담아 둔 사본, 즉 파생 상태다. 사본을 두면 원본을 바꾸는 모든 경로에서 사본도 함께 맞춰야 하고, 본문의 onClearPassword처럼 한 곳만 빠뜨려도 원본(빈 password)과 사본(true)이 어긋난다. B처럼 렌더 중에 계산하면 동기화할 코드 자체가 없어 늘 원본과 일치한다. 계산이 무겁다면 상태로 올리지 말고 useMemo로 감싼다. 옆 개념과 구분하면, 단일 진실 공급원은 파생 상태를 피해서 지키려는 상위 원칙이고, useState(props.value)처럼 props를 초기값으로 복사해 두는 것도 파생 상태의 한 형태다.'),
       (1471, 4546, '정규화,상태 정규화,데이터 정규화,normalization,normalize,normalizing,평탄화,상태 평탄화,flattening,flatten,노멀라이즈', '중첩된 트리를 id를 키로 하는 객체 하나에 평평하게 펼치고, 부모와 자식의 관계는 replyIds 같은 id 목록으로만 가리키게 바꾸는 것이 정규화다. 깊이와 상관없이 comments[3]으로 곧장 닿으므로 경로 위 객체를 줄줄이 복사할 필요가 없고, 복사를 빠뜨려 이전 상태를 직접 바꾸는 실수가 생길 자리도 줄어든다. 데이터베이스 정규화와 발상(같은 데이터를 한 곳에만 두고 id로 참조)은 같지만, 여기서는 테이블이 아니라 컴포넌트 상태의 모양을 다룬다. 또 상태 끌어올리기가 상태를 어느 컴포넌트에 둘지, 즉 위치를 바꾸는 일이라면 정규화는 위치는 그대로 두고 형태를 바꾸는 일이다.');

-- =====================================================
-- Lesson 885: React 상태 설계 실전: 렌더 범위·상태 모양·상태 전이 다루기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5489, 885, '아래 코드와 조작 순서에서 마지막 조작 직후 문단에 표시되는 내용은?', '```tsx
function Counter() {
  const [dark, setDark] = useState(false);
  const clicksRef = useRef(0);
  let clicksVar = 0;

  function handlePlus() {
    clicksRef.current += 1;
    clicksVar += 1;
  }

  return (
    <div className={dark ? "dark" : "light"}>
      <button onClick={handlePlus}>+1</button>
      <button onClick={() => setDark(!dark)}>테마 전환</button>
      <p>ref: {clicksRef.current} / var: {clicksVar}</p>
    </div>
  );
}
```

화면이 처음 그려진 뒤 사용자는 [+1] 버튼을 세 번 누르고, 이어서 [테마 전환] 버튼을 한 번 눌렀다.', 'OBJECTIVE'),
       (5490, 885, '아래 컴포넌트 트리와 프로파일링 기록에 대한 설명으로 옳은 것은?', '게시판 화면에서 댓글 입력칸에 한 글자를 입력했을 때 React Profiler에 남은 기록이다. draft 상태는 App에 선언돼 있고, props로 Main을 거쳐 CommentBox까지 내려간다.

```
App               (draft 상태 선언)
├─ Header         (로고와 메뉴를 그린다)
└─ Main           (draft를 CommentBox에 넘기기만 한다)
   ├─ Feed        (게시글 300개를 PostItem으로 그린다)
   └─ CommentBox  (draft를 입력칸에 표시하고 onChange로 바꾼다)
```

```
[커밋 #14] 입력 1자 — 렌더 시간 합계 52.4ms
  App          0.4ms
  Header       0.2ms
  Main         0.1ms
  Feed        49.9ms  (PostItem × 300)
  CommentBox   1.8ms
```

Header, Feed, PostItem은 draft를 읽지도 바꾸지도 않는다.', 'OBJECTIVE'),
       (5491, 885, '아래 상태 설계안에 대한 설명으로 옳은 것은?', '아코디언은 배송·환불·교환 세 패널로 이뤄진다. 새 요구 사항은 두 가지다.

- 한 번에 최대 한 패널만 열린다.
- 열린 패널의 제목을 다시 누르면 그 패널이 닫혀, 세 패널이 모두 닫힌 화면도 나올 수 있다.

팀에서 나온 상태 설계안은 아래 네 가지다. A를 뺀 나머지는 Accordion이 상태를 갖고, 패널마다 열림 여부를 계산해 isOpen props로 내려준다.

| 안 | 상태를 가진 컴포넌트 | 상태 선언 |
|---|---|---|
| A | 각 Panel | open: boolean |
| B | Accordion | openStates: boolean[] (패널 수만큼) |
| C | Accordion | activeIndex: number, isAllClosed: boolean |
| D | Accordion | activeIndex: number 또는 null |', 'OBJECTIVE'),
       (5492, 885, '아래 코드의 버그를 고치는 방안으로 옳은 것은?', '```tsx
type Mail = { id: number; subject: string };

function Inbox({ initialMails }: { initialMails: Mail[] }) {
  const [mails, setMails] = useState(initialMails);
  const [selected, setSelected] = useState<Mail | null>(null);

  function remove(id: number) {
    setMails(mails.filter((m) => m.id !== id));
  }

  return (
    <>
      <MailList mails={mails} onSelect={setSelected} onRemove={remove} />
      <MailDetail mail={selected} />
    </>
  );
}
```

MailDetail은 mail이 null이거나 undefined이면 "선택된 메일 없음"을 표시한다.

사용자가 목록에서 견적서 메일을 골라 상세 패널에 띄운 뒤 그 메일을 삭제하자, 목록에서는 견적서가 사라졌지만 상세 패널에는 삭제된 견적서가 그대로 남았다.', 'OBJECTIVE'),
       (5493, 885, '아래 상황에서 문제를 해결하려고 도입한 React 훅의 이름은?', '상품 20,000개를 다루는 SearchPage 컴포넌트는 렌더 중에 목록을 계산해 넘긴다.

```tsx
const filtered = filterSlow(products, query);
return <ProductList items={filtered} />;
```

같은 화면의 다크 모드 토글을 누를 때마다 버튼 반응이 눈에 띄게 늦었다. products와 query는 그대로인데도 Profiler에는 이렇게 찍혔다.

```
[다크 모드 토글 1회] 커밋 42.1ms — filterSlow 39.6ms
```

팀원 한 명은 filtered를 useState에 담고 useEffect로 맞추자고 했다. 그 대신 계산 줄은 그대로 두고 React 훅 하나로 감싼 뒤 두 번째 인자로 [products, query]를 넘기자 기록이 이렇게 바뀌었다. filtered에는 여전히 상품 목록이 담긴다.

```
[다크 모드 토글 1회] 커밋 2.4ms  — filterSlow 호출 없음
[검색어 1자 입력]    커밋 41.3ms — filterSlow 39.2ms
```', 'SUBJECTIVE'),
       (5494, 885, '아래 리팩터링 후 코드의 빈칸에 들어갈 React 훅의 이름은?', 'React 18로 만든 회원가입 폼이다. 리팩터링 전 코드와 QA 기록은 아래와 같다.

```tsx
// 리팩터링 전
const [status, setStatus] = useState<"editing" | "submitting" | "done">("editing");
const [error, setError] = useState<string | null>(null);
const [email, setEmail] = useState("");

async function handleSubmit() {
  setStatus("submitting");
  try {
    await signUp(email);
    setStatus("done");
  } catch {
    setStatus("editing");
    setError("이미 가입된 이메일입니다");
  }
}
```

```
[QA-12] 가입 실패 뒤 [가입]을 다시 누르면 "전송 중…" 표시와 "이미 가입된 이메일입니다" 문구가 함께 보인다.
```

```tsx
// 리팩터링 후
type Form = { status: "editing" | "submitting" | "done"; error: string | null; email: string };
type Action =
  | { type: "edit"; email: string }
  | { type: "submit" }
  | { type: "fail"; message: string }
  | { type: "succeed" };

function next(form: Form, action: Action): Form {
  switch (action.type) {
    case "edit":    return { ...form, email: action.email };
    case "submit":  return { ...form, status: "submitting", error: null };
    case "fail":    return { ...form, status: "editing", error: action.message };
    case "succeed": return { ...form, status: "done" };
  }
}

const [form, send] = ______(next, { status: "editing", error: null, email: "" });

async function handleSubmit() {
  send({ type: "submit" });
  try {
    await signUp(form.email);
    send({ type: "succeed" });
  } catch {
    send({ type: "fail", message: "이미 가입된 이메일입니다" });
  }
}
```

리팩터링 뒤 같은 절차로 다시 확인하자 QA-12는 나오지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5489
(14811, 5489, 'ref: 0 / var: 0', 'ref를 바꿔도 리렌더가 없다는 점만 보고 뒤이은 리렌더를 놓친 것이다. 테마 전환의 setDark가 컴포넌트를 다시 실행시키고, ref는 렌더 사이에 값을 유지하므로 그때 누적된 3이 읽힌다.', false),
(14812, 5489, 'ref: 3 / var: 3', '함수 안의 지역 변수도 렌더 사이에 값이 남는다고 오해한 것이다. 컴포넌트 함수가 다시 실행될 때마다 let clicksVar = 0이 새로 만들어지므로, 이전 렌더에서 올린 3은 새 렌더로 이어지지 않는다.', false),
(14813, 5489, 'ref: 3 / var: 0', '[+1]은 ref와 지역 변수만 바꾸고 setState를 부르지 않아 화면은 그대로다. 테마 전환이 리렌더를 일으키면 ref는 보관 중인 3을, clicksVar는 새로 만든 0을 그린다. 화면에 바로 보여야 할 값은 상태로 둬야 한다.', true),
(14814, 5489, 'ref: 0 / var: 3', 'ref와 지역 변수의 성질을 거꾸로 본 것이다. 렌더마다 새로 만들어지는 쪽은 함수 안의 let 변수이고, useRef가 돌려준 객체는 컴포넌트가 화면에 있는 동안 같은 객체라 올린 값이 남는다.', false),

-- 문제 5490
(14815, 5490, 'Feed는 draft를 props로 받지 않으므로, 기록에 Feed가 잡힌 원인은 PostItem 300개 각자의 상태 변화다.', '부모가 다시 렌더되면 자식은 props가 바뀌었는지와 상관없이 기본적으로 함께 렌더된다. Feed가 잡힌 것은 draft를 가진 App부터 아래로 렌더가 내려왔기 때문이지 PostItem의 상태 때문이 아니다.', false),
(14816, 5490, 'draft를 CommentBox의 지역 상태로 옮기면, 같은 입력 때 커밋에 잡히는 컴포넌트가 CommentBox 하나로 줄어든다.', '상태가 바뀌면 그 상태를 가진 컴포넌트부터 아래로만 렌더된다. draft를 쓰는 곳이 CommentBox뿐이니 그 안에 두면 App·Main·Feed가 렌더 범위에서 빠지고, 49.9ms를 쓰던 Feed도 다시 그려지지 않는다.', true),
(14817, 5490, 'draft를 Main으로 옮기면 가장 가까운 공통 조상 원칙을 따르게 돼 Feed가 커밋에서 빠진다.', 'Main은 Feed의 부모라 Main의 상태가 바뀌면 Feed도 함께 렌더된다. 게다가 draft를 쓰는 컴포넌트는 CommentBox 하나뿐이라, 가장 가까운 공통 조상은 Main이 아니라 CommentBox 자신이다.', false),
(14818, 5490, 'draft를 App의 useRef로 바꾸면 입력칸 표시는 그대로 두고 커밋에 잡히는 컴포넌트만 없앨 수 있다.', 'ref는 바꿔도 리렌더를 일으키지 않으므로, value={draftRef.current}로 그리는 입력칸은 새 글자를 화면에 반영하지 못한다. 입력칸처럼 화면에 보여야 하는 값은 상태여야 한다.', false),

-- 문제 5491
(14819, 5491, 'A는 각 Panel의 useEffect에서 다른 Panel의 open을 false로 바꾸게 하면, 부모를 고치지 않고도 요구를 맞출 수 있다.', '상태는 그 상태를 가진 컴포넌트만 바꿀 수 있고, 형제의 setOpen에 닿을 경로는 없다. 한 패널의 변화가 다른 패널의 표시에 영향을 줘야 한다면 두 패널의 공통 부모로 상태를 올려야 한다.', false),
(14820, 5491, 'B는 true가 둘 이상 담긴 배열을 타입이 막아 주므로, 한 번에 하나만 열린다는 규칙이 상태 모양만으로 지켜진다.', 'boolean[]는 [true, true, false] 같은 값도 그대로 담는다. 규칙은 패널을 열 때마다 다른 칸을 false로 되돌리는 코드가 지켜야 하고, 그 코드를 한 곳만 빠뜨려도 두 패널이 함께 열린다.', false),
(14821, 5491, 'C는 두 값이 어떤 조합으로 들어가도 요구와 어긋나지 않아, 두 값을 함께 맞추는 코드가 따로 필요 없다.', 'activeIndex가 1이면서 isAllClosed가 true인 조합은 환불 열림과 모두 닫힘을 동시에 뜻하는 모순이다. 두 값을 늘 함께 바꾸는 코드가 필요하고, 한쪽만 바꾸면 어느 값을 믿을지 알 수 없게 된다.', false),
(14822, 5491, 'D는 isOpen 계산(activeIndex === i)을 그대로 두고, 열린 패널을 다시 누를 때 null만 넣으면 요구를 모두 만족한다.', 'null은 어떤 패널 번호와도 같지 않아 세 패널이 모두 닫히고, 값이 하나뿐이라 두 패널이 함께 열린 상태는 애초에 표현되지 않는다. 가능한 상태만 담기는 모양이라 두 값을 맞추는 동기화 코드가 필요 없다.', true),

-- 문제 5492
(14823, 5492, 'selected 대신 selectedId만 상태로 두고 렌더 중 mails에서 찾아 넘기면, 삭제 직후에는 찾는 메일이 없어 상세 패널이 비워진다.', '상세 패널이 보는 값을 mails 하나에서만 얻으므로 출처가 하나로 유지된다. 삭제된 메일은 mails.find가 찾지 못해 undefined가 되고, 제목 수정처럼 mails를 바꾸는 다른 경로에서도 따로 맞출 필요 없이 따라간다.', true),
(14824, 5492, 'remove 안에서 setSelected(null)을 함께 부르면, 앞으로 mails를 바꾸는 기능이 늘어나도 두 값이 어긋날 일이 없다.', '삭제 경로 하나만 막을 뿐이다. 제목 수정이나 서버 새로고침처럼 mails를 바꾸는 경로가 생길 때마다 selected도 맞춰야 하고, 하나라도 빠뜨리면 사본이 다시 낡는다. 사본이 있는 한 동기화 부담도 남는다.', false),
(14825, 5492, 'useEffect에서 mails가 바뀔 때마다 selected를 다시 찾아 넣으면, 삭제한 바로 그 렌더부터 상세 패널이 목록과 맞는다.', '이펙트는 렌더 결과가 화면에 반영된 뒤 실행된다. 삭제 직후 첫 렌더에는 낡은 selected가 그대로 그려지고, 이펙트의 setSelected로 렌더가 한 번 더 돌아야 맞춰져 잠깐의 불일치가 남는다.', false),
(14826, 5492, 'filter 대신 splice로 mails 배열에서 견적서를 직접 지우면, selected가 가리키던 객체도 함께 사라져 상세 패널이 비워진다.', '배열에서 원소를 빼도 selected가 들고 있는 객체는 그대로 남는다. 게다가 splice는 기존 배열을 직접 바꿔 참조가 같으므로, React가 변화를 알아채지 못해 목록조차 다시 그려지지 않을 수 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1786, 5493, 'useMemo,useMemo(),React.useMemo,useMemo 훅,유즈메모,유즈 메모,use memo', 'useMemo는 두 번째 인자로 받은 의존성 배열의 값이 이전 렌더와 같으면 지난번 계산 결과를 그대로 돌려주고, 달라졌을 때만 계산 함수를 다시 실행한다. 그래서 products와 query가 그대로인 다크 모드 토글에서는 filterSlow가 불리지 않고, 검색어가 바뀐 렌더에서만 다시 계산된다. 팀원의 제안처럼 filtered를 useState에 담고 useEffect로 맞추면 계산 결과의 사본을 두는 파생 상태가 된다. 그러면 검색어가 바뀔 때마다 렌더가 2회 돌고 그 사이 낡은 목록이 잠깐 보인다. useMemo는 값을 여전히 렌더 중에 얻으므로 원본과 어긋나지 않는다. 옆 개념과 구분하면, useCallback은 계산 결과가 아니라 함수 자체를 기억하므로 여기에 쓰면 filtered에 상품 목록 대신 함수가 담긴다.'),
       (1787, 5494, 'useReducer,useReducer(),React.useReducer,useReducer 훅,유즈리듀서,유즈 리듀서,use reducer', 'useReducer는 (현재 상태, 액션)을 받아 다음 상태를 돌려주는 함수와 초기값을 받아 [상태, dispatch]를 돌려준다. 본문에서는 그 함수가 next, dispatch가 send다. 리팩터링 전에는 status와 error가 같은 이벤트로 함께 바뀌어야 하는데 setter가 흩어져 있어, handleSubmit이 setError(null)을 빠뜨린 순간 전송 중 표시와 이전 에러가 함께 보이는 모순 조합이 생겼다. 리팩터링 뒤에는 submit 액션 하나가 status와 error를 한 번에 정하므로 같은 실수가 끼어들 자리가 없다. useState와 구분하면, useState의 setter는 다음 값을 직접 받지만 useReducer의 dispatch는 무슨 일이 일어났는지(액션)만 받고 다음 값은 리듀서 함수가 정한다.');
