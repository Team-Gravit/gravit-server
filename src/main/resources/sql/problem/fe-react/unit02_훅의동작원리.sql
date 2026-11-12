-- Unit: 훅의 동작 원리 (Unit ID: 142)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (568, 142, '조건부 훅과 의존성 배열, 지연 초기화'),
       (726, 142, 'Fiber 훅 리스트와 함수형 업데이트'),
       (884, 142, '훅의 동작 원리: 인스턴스별 셀, 마운트 뒤의 초기값, 이펙트 재실행 조건');

-- =====================================================
-- Lesson 568: 조건부 훅과 의존성 배열, 지연 초기화
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3587, 568, '아래 컴포넌트에서 버튼을 한 번 클릭한 뒤, 리렌더된 화면에 표시되는 count 값은?', '```tsx
function Counter() {
  const [count, setCount] = useState(0); // 초기 상태는 0

  function handleClick() {
    setCount(count + 1);
    setCount(count + 1);
    setCount((c) => c + 1);
  }

  return <button onClick={handleClick}>{count}</button>;
}
```

버튼을 한 번만 클릭했고, 그 밖의 상태 변경은 없다.', 'OBJECTIVE'),
       (3588, 568, '아래 비교표에서 따라 나오는 설명으로 옳지 않은 것은?', '| 훅 | 저장하는 것 | 값이 바뀌면 리렌더 | 렌더 간 동일성 |
| --- | --- | --- | --- |
| useState | 값 + 업데이트 큐 | 일어남 | setter는 항상 같은 함수 |
| useRef | { current } 객체 | 일어나지 않음 | 객체 자체가 항상 같음 |
| useMemo | 계산 결과 + 의존성 | 일어나지 않음 | 의존성이 같으면 같은 참조 |
| useCallback | 함수 + 의존성 | 일어나지 않음 | 의존성이 같으면 같은 함수 |', 'OBJECTIVE'),
       (3589, 568, '아래 이펙트가 끝없이 다시 실행되는 원인과 올바른 해결로 옳은 것은?', '```tsx
function ChatRoom({ roomId }) {
  const [msgs, setMsgs] = useState([]);
  const options = { roomId, serverUrl: "https://chat.example.com" };

  useEffect(() => {
    const conn = connect(options);
    conn.on("message", (m) => setMsgs((prev) => [...prev, m]));
    return () => conn.close();
  }, [options]);

  return <MessageList items={msgs} />;
}
```

방에 들어가자마자 콘솔에 연결 로그와 해제 로그가 초당 수백 줄씩 번갈아 찍힌다. roomId는 그동안 한 번도 바뀌지 않았다.', 'OBJECTIVE'),
       (3590, 568, '아래 컴포넌트에서 검색어가 처음 입력돼 리렌더될 때 일어나는 일로 옳은 것은?', '```tsx
function SearchPanel({ query }) {  // 첫 렌더에서 query는 빈 문자열
  const [results, setResults] = useState([]);

  if (query.length > 0) {
    useEffect(() => {
      fetchResults(query).then(setResults);
    }, [query]);
  }

  const [open, setOpen] = useState(false);
  return open ? <List items={results} /> : null;
}
```

사용자가 입력창에 두 글자를 쳐서 query가 "re"가 된 상태로 다시 렌더된다.', 'OBJECTIVE'),
       (3591, 568, '아래 콘솔 출력에서 드러난 현상을 가리키는 용어는?', '```tsx
function Timer() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const id = setInterval(() => console.log("tick", count), 1000);
    return () => clearInterval(id);
  }, []);

  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

버튼을 세 번 눌러 화면의 숫자는 3까지 올라갔는데, 콘솔에는 1초마다 "tick 0"만 계속 찍힌다.', 'SUBJECTIVE'),
       (3592, 568, '아래에서 A안을 B안으로 바꿔 얻은 최적화 기법의 이름은?', '```tsx
const rawCsv = useContext(CsvContext);  // 약 2MB 문자열

// A안 — 입력창에 글자를 칠 때마다 렌더가 40ms 넘게 걸렸다
const [rows, setRows] = useState(parseCsv(rawCsv));

// B안 — 같은 화면, 같은 입력에서 렌더가 3ms로 줄었다
const [rows, setRows] = useState(() => parseCsv(rawCsv));
```

두 방식 모두 화면에 처음 그려진 결과는 같았고, parseCsv는 같은 입력에 같은 결과를 내는 순수 함수다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3587
(9739, 3587, '0', '갱신이 묶여 처리되면 리렌더 자체가 생략된다고 본 오해. 큐에 갱신이 하나라도 들어가면 React는 반드시 리렌더해 화면을 새로 그린다.', false),
(9740, 3587, '1', '앞의 두 호출이 같은 스냅샷 0을 읽는 데까지는 맞지만, 마지막 함수형 업데이트도 그 스냅샷을 쓴다고 본 오해. set(c => c + 1)의 c는 큐를 여기까지 적용한 값 1이다.', false),
(9741, 3587, '2', '앞 두 호출은 이 렌더의 count(0)를 읽어 큐에 1과 1을 넣는다. 마지막 호출은 큐를 적용한 직전 값 1을 받아 2를 넣고, 다음 렌더가 큐를 순서대로 소비해 최종값이 2가 된다.', true),
(9742, 3587, '3', 'setCount가 호출 즉시 count를 바꾼다고 보고 0에서 1, 2, 3으로 센 오해. 렌더 중 count는 상수처럼 고정돼 있어 앞 두 호출은 모두 0을 읽는다.', false),

-- 문제 3588
(9743, 3588, 'ref.current에 새 값을 대입하면 그 자리에서 리렌더가 일어나 바뀐 값이 화면에 나타난다.', 'useRef는 값이 바뀌어도 리렌더를 일으키지 않는다. 대입은 즉시 반영되지만 화면은 다른 이유로 리렌더될 때까지 옛 값을 그대로 보여 준다. 화면에 보여야 하는 값이라면 useState를 써야 한다.', true),
(9744, 3588, 'setCount를 props로 내려 준 자식은 그 props가 달라졌다는 이유로 다시 렌더되는 일이 없다.', 'setter는 렌더 간 동일성이 보장돼 참조가 그대로다. memo로 감싼 자식의 얕은 비교를 통과하므로 그 props 때문에 다시 렌더되지 않는다. 표에서 곧바로 따라 나오는 참인 진술이다.', false),
(9745, 3588, '의존성이 그대로인 useCallback 함수를 이펙트 의존성에 넣어 두면 그 이펙트는 렌더마다 다시 실행되지 않는다.', '의존성이 같으면 useCallback은 이전 렌더의 함수를 그대로 돌려주므로 이펙트의 의존성 비교도 통과한다. 함수를 useCallback으로 감싸지 않으면 매 렌더 새 함수가 생겨 이펙트가 계속 다시 도는 것과 대비된다.', false),
(9746, 3588, 'useMemo가 계산한 결과가 이전과 달라져도 그 자체로 리렌더가 시작되지는 않는다.', 'useMemo는 렌더 도중에 계산해 결과를 보관할 뿐 갱신 큐가 없어 렌더를 촉발하지 못한다. 결과가 달라졌다면 이미 그 렌더를 일으킨 state나 props 변화가 따로 있었던 것이다.', false),

-- 문제 3589
(9747, 3589, 'msgs가 이펙트 안에서 갱신되며 생긴 순환이 원인이며, setMsgs를 의존성 배열에 함께 넣으면 재실행이 멈춘다.', 'setMsgs는 렌더 간 참조가 고정돼 있어 의존성에 넣어도 비교 결과가 달라지지 않는다. 게다가 갱신을 함수형 업데이트로 해서 이펙트가 msgs 값을 읽지도 않는다.', false),
(9748, 3589, '클린업을 반환한 이펙트는 렌더마다 다시 실행되는 것이 원인이며, conn.close()를 돌려주는 return 문을 지우면 멈춘다.', '클린업 유무는 재실행 조건과 아무 상관이 없다. 재실행은 오직 의존성 비교로 정해진다. 클린업을 지우면 해제 로그만 사라지고 닫히지 않은 연결이 계속 쌓여 더 나빠진다.', false),
(9749, 3589, 'roomId가 바뀌지 않았는데도 이펙트가 도는 것이 원인이며, 의존성 배열을 빈 배열로 비워 마운트에서 한 번만 연결하면 된다.', '반복은 멎지만 나중에 roomId가 바뀌어도 이펙트가 다시 돌지 않아 이전 방에 연결된 채로 남는다. 의존성을 지우는 것은 배열을 속이는 대응이지 원인을 없앤 것이 아니다.', false),
(9750, 3589, 'options가 렌더마다 새 객체라 참조가 매번 달라지는 것이 원인이며, 객체 생성을 이펙트 안으로 옮기고 roomId와 serverUrl만 의존성에 두면 된다.', '의존성 비교는 내용이 아니라 참조를 얕게 본다. 값이 같아도 매 렌더 새로 만든 객체는 다른 값으로 판정돼 이펙트가 다시 돌고, 그 갱신이 또 렌더를 불러 순환이 된다. 원시값만 의존성에 두면 끊긴다.', true),

-- 문제 3590
(9751, 3590, 'useEffect의 의존성 배열에 query가 들어 있어 호출 위치와 무관하게 셀이 올바로 짝지어지고, 검색 요청만 한 번 나간다.', '의존성 배열은 이펙트를 다시 실행할지 판단하는 재료일 뿐, 훅이 자기 셀을 찾는 데는 전혀 쓰이지 않는다. 셀은 오직 몇 번째로 호출됐는가로 정해진다.', false),
(9752, 3590, '이전 렌더보다 훅 호출 개수가 하나 늘어, React가 셀을 이어 붙이지 못하고 렌더 도중 오류를 던진다.', 'React는 렌더마다 호출된 훅 개수를 이전 렌더와 대조한다. 첫 렌더에는 useState 두 개뿐이었는데 이번 렌더는 세 개라 순서로 셀을 찾는 연결 리스트가 어긋나고, 렌더가 예외로 중단된다.', true),
(9753, 3590, 'open이 useEffect 자리의 셀을 읽어 false 대신 이펙트 값을 받지만, 렌더 자체는 오류 없이 끝난다.', '호출 순서가 밀린다는 데까지는 맞지만 React가 그대로 두지 않는다. 훅 개수 변화를 감지해 오류를 던지므로 값만 조용히 뒤섞인 채 렌더가 끝나지는 않는다.', false),
(9754, 3590, '조건이 참일 때만 훅이 늘어나는 형태라 ESLint 경고만 뜰 뿐, 실행 중 동작에는 문제가 없다.', '훅의 규칙은 코딩 관습이 아니라 연결 리스트 구현에서 나온 제약이다. 린터는 그 위반을 미리 알려 줄 뿐이고, 경고를 무시하면 실행 중에 실제로 렌더가 깨진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1152, 3591, 'stale closure,스테일 클로저,스테일클로저,오래된 클로저,낡은 클로저,오래된 클로저 문제', '의존성 배열이 비어 있어 인터벌은 마운트 때 딱 한 번 만들어지고, 그때 넘긴 콜백은 첫 렌더의 count(0)를 클로저로 붙잡은 채 계속 살아 있다. 버튼을 누르면 새 렌더가 새 count를 가진 새 콜백을 만들지만, 이미 돌고 있는 인터벌은 옛 콜백을 그대로 쓰므로 콘솔에는 0만 찍힌다. 이렇게 지난 렌더의 값을 붙잡은 함수가 나중에 실행돼 낡은 값을 쓰는 현상이 stale closure다. 실행 순서가 엇갈려 결과가 달라지는 경쟁 상태와는 다르고, clearInterval을 빠뜨려 타이머가 쌓이는 메모리 누수와도 구분해야 한다. 해결은 함수형 업데이트 setCount((c) => c + 1)를 먼저 시도하고, 값 자체가 필요하면 count를 의존성에 넣어 이펙트를 다시 구성하며, 재구성 비용이 크면 ref에 최신 값을 담아 읽는 순서로 찾는다.'),
       (1153, 3592, '지연 초기화,지연 초기화 함수,lazy initialization,lazy initializer,lazy init,게으른 초기화', 'A안은 useState의 인자 자리에 있는 식이 렌더마다 평가되므로 parseCsv가 매 렌더 실행된다. 두 번째 렌더부터 React는 그 결과를 초기값으로 쓰지 않고 버리기 때문에 40ms는 통째로 낭비다. B안처럼 함수를 넘기면 React가 마운트 첫 렌더에서만 그 함수를 호출하고 이후에는 아예 부르지 않아 계산 자체가 사라진다. 이것이 지연 초기화이며, 초기 화면 결과가 같은데도 이후 렌더만 3ms로 줄어든 이유다. useMemo와 헷갈리기 쉬운데, useMemo는 의존성이 바뀔 때마다 다시 계산해 결과를 캐시하는 장치이고 지연 초기화는 초기 상태를 한 번만 만드는 장치다. 초기값이 아니라 props에서 파생되는 값을 렌더마다 새로 계산해야 한다면 useMemo가 맞다.');

-- =====================================================
-- Lesson 726: Fiber 훅 리스트와 함수형 업데이트
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4535, 726, '아래 컴포넌트에서 콘솔에 찍히는 값을 찍힌 순서대로 나열한 것은?', '```tsx
function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    setCount(count + 1);
    setTimeout(() => {
      console.log(count);
    }, 3000);
  }

  return <button onClick={handleClick}>{count}</button>;
}
```

버튼을 1초 간격으로 세 번 눌렀다. 클릭할 때마다 리렌더가 끝나 화면 숫자가 바뀐 것을 확인한 뒤 다음 클릭을 했고, 그 밖의 state 변경은 없다.', 'OBJECTIVE'),
       (4536, 726, '아래 코드에서 Card가 한 번 렌더될 때, Card 자신의 훅 리스트에 쌓이는 훅 셀은 모두 몇 개인가?', '```tsx
function useToggle(initial) {
  const [on, setOn] = useState(initial);
  return [on, () => setOn((v) => !v)];
}

function Badge() {
  const [hover, setHover] = useState(false);
  return (
    <span onMouseEnter={() => setHover(true)}>
      {hover ? "NEW!" : "NEW"}
    </span>
  );
}

function Card() {
  const [liked, toggleLiked] = useToggle(false);
  const [open, setOpen] = useState(false);
  const badgeA = Badge();
  const badgeB = <Badge />;

  return (
    <div>
      {badgeA}
      {badgeB}
      <button onClick={toggleLiked}>{liked ? "취소" : "좋아요"}</button>
      <button onClick={() => setOpen(!open)}>상세</button>
    </div>
  );
}
```

Card는 항상 위 코드 순서 그대로 렌더되며, 조건에 따라 건너뛰는 훅 호출은 없다.', 'OBJECTIVE'),
       (4537, 726, '아래 이펙트의 의존성 배열 자리에 들어갈 값으로 옳은 것은?', '```tsx
import { fetchProducts } from "./api";

const PAGE_SIZE = 20;

function ProductList({ category }) {
  const [sort, setSort] = useState("price");
  const [items, setItems] = useState([]);
  const requestCount = useRef(0);

  useEffect(() => {
    requestCount.current += 1;
    fetchProducts({ category, sort, size: PAGE_SIZE }).then((data) => {
      setItems(data);
    });
  }, /* 의존성 배열 */);

  return (
    <>
      <SortSelect value={sort} onChange={setSort} />
      <Grid items={items} />
    </>
  );
}
```

fetchProducts는 호출할 때마다 새 배열을 만들어 돌려준다.', 'OBJECTIVE'),
       (4538, 726, '아래 상황에서 두 요구 사항을 모두 만족하는 수정으로 옳은 것은?', '채팅방 컴포넌트가 props에서 roomId와 theme를 구조 분해해 받는다. 이펙트는 의존성 배열을 `[roomId]`로 두고 소켓을 연 뒤, 메시지가 올 때마다 콜백에서 theme를 읽어 알림 색을 정한다.

사용자가 다크 모드로 바꿨는데도 알림은 계속 라이트 색으로 뜬다. 소켓을 새로 여는 데는 약 2초가 걸리고, 그사이 도착한 메시지는 사라진다.

- 요구 사항 1: 알림 색은 메시지가 도착한 순간의 theme를 따라야 한다.
- 요구 사항 2: theme가 바뀌어도 소켓을 닫았다가 다시 열지 않아야 한다.', 'OBJECTIVE'),
       (4539, 726, '아래에서 한 줄만 바꿔 문제를 해결한 state 갱신 방식을 가리키는 이름은?', '```tsx
function LikeButton({ postId }) {
  const [likes, setLikes] = useState(0);

  async function handleClick() {
    await api.like(postId); // 응답까지 매번 약 2초
    setLikes(likes + 1);
  }

  return <button onClick={handleClick}>좋아요 {likes}</button>;
}
```

사용자가 1초 안에 버튼을 5번 눌렀다. 서버에는 요청 5건이 모두 성공으로 기록됐는데 화면 숫자는 1에서 멈췄다.

`setLikes(likes + 1)` 한 줄을 `setLikes((n) => n + 1)`로만 바꾸자, 같은 조작에서 화면 숫자가 5가 됐다.', 'SUBJECTIVE'),
       (4540, 726, '아래 콘솔에 출력된 객체를 React 내부에서 부르는 이름은?', 'Counter 컴포넌트는 useState 하나와 useRef 하나를 이 순서로 호출한다. 함수는 렌더마다 처음부터 다시 실행되는데도 버튼을 세 번 누르자 화면 숫자 3이 그대로 유지됐다. 값이 어디에 남아 있는지 보려고, 개발 환경 콘솔에서 버튼 DOM 요소의 React 내부 속성을 따라가 Counter에 대응하는 객체를 출력했다(일부 속성만 추림).

```
{
  tag: 0,
  type: ƒ Counter(),
  stateNode: null,
  memoizedProps: {},
  memoizedState: {
    memoizedState: 3,
    queue: { pending: null, … },
    next: {
      memoizedState: { current: 0 },
      next: null
    }
  },
  return: { … },
  child: { … },
  sibling: null
}
```

버튼을 한 번 더 누른 뒤 같은 방법으로 다시 출력하자, 바깥 memoizedState 안의 memoizedState 값이 4로 바뀌어 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4535
(12267, 4535, '0, 0, 0', '핸들러가 첫 렌더에서 만든 것 하나로 계속 쓰인다고 본 오해. 렌더마다 handleClick이 새로 만들어져 onClick에 붙으므로, 두 번째와 세 번째 클릭은 각각 count가 1, 2인 렌더의 핸들러가 처리한다.', false),
(12268, 4535, '0, 1, 2', '클릭마다 그 시점 렌더의 handleClick이 실행되고, 타이머 콜백은 그 렌더의 count를 클로저로 붙잡는다. 세 콜백은 count가 0, 1, 2인 렌더에서 각각 만들어졌으므로 3초 뒤에도 그 값을 찍는다.', true),
(12269, 4535, '1, 2, 3', 'setCount가 호출 즉시 count를 올린다고 본 오해. setCount는 다음 렌더를 예약할 뿐이고, 실행 중인 렌더의 count는 상수처럼 고정돼 있어 타이머도 증가 전 값을 붙잡는다.', false),
(12270, 4535, '3, 3, 3', '콜백이 실행되는 순간의 최신 state를 읽는다고 본 오해. 첫 로그가 찍힐 때 화면은 이미 3이지만, 각 콜백은 자기가 만들어진 렌더의 count를 붙잡고 있어 그 값을 찍는다.', false),

-- 문제 4536
(12271, 4536, '1', '커스텀 훅의 state는 훅 함수 쪽에, 직접 부른 Badge()의 state는 Badge 쪽에 따로 저장된다고 보고 open만 센 오해. 훅은 호출된 순간 렌더 중인 컴포넌트의 리스트에 붙으므로 두 useState 모두 Card 리스트에 쌓인다.', false),
(12272, 4536, '2', 'Badge()를 직접 불러도 <Badge />처럼 별도 컴포넌트로 렌더된다고 본 오해. 함수를 직접 부르면 React는 새 컴포넌트로 다루지 않고, 그 안의 useState는 Card 렌더 도중 호출된 훅이 돼 Card 리스트에 붙는다.', false),
(12273, 4536, '3', 'useToggle 안의 on, Card의 open, 직접 호출한 Badge() 안의 hover가 모두 Card 렌더 도중 호출돼 호출 순서대로 Card 리스트에 쌓인다. <Badge />는 React가 자식으로 따로 렌더해 자기 리스트를 가진다.', true),
(12274, 4536, '4', '<Badge />를 쓰는 순간 Badge 함수가 Card 안에서 실행된다고 본 오해. JSX는 무엇을 그릴지 적은 객체만 만들고, Badge 함수는 React가 자식 컴포넌트로 렌더할 때 따로 실행돼 그 자식의 리스트에 셀을 둔다.', false),

-- 문제 4537
(12275, 4537, '[category, sort]', '본문이 읽는 반응형 값은 props인 category와 state인 sort뿐이다. PAGE_SIZE는 컴포넌트 밖 상수, requestCount는 ref 객체, setItems는 setter라 렌더 간 같음이 보장돼 넣지 않아도 된다.', true),
(12276, 4537, '[category]', 'props만 넣고 컴포넌트 안 state는 빼도 된다고 본 오해. sort도 렌더마다 달라질 수 있는 반응형 값이라, 빼면 정렬만 바꿨을 때 이펙트가 다시 돌지 않아 이전 정렬로 받은 목록이 그대로 남는다.', false),
(12277, 4537, '[category, sort, items]', '이펙트가 바꾸는 state도 넣어야 한다고 본 오해. 본문은 items를 읽지 않는다. 넣으면 응답마다 새 배열로 items가 바뀌어 이펙트가 다시 요청하고, 그 응답이 또 items를 바꿔 요청이 끝없이 반복된다.', false),
(12278, 4537, '[]', '의존성 배열을 마운트 때 한 번만 실행하게 하는 스위치로 본 오해. 배열은 본문이 읽는 반응형 값의 목록이라, 비우면 category나 sort가 바뀌어도 이펙트가 다시 돌지 않아 첫 렌더 조건의 목록만 남는다.', false),

-- 문제 4538
(12279, 4538, 'theme를 의존성 배열에 추가해, theme가 바뀔 때마다 이펙트가 새 값으로 다시 실행되게 한다.', '의존성을 빠짐없이 채워 요구 사항 1은 맞추지만, theme가 바뀔 때마다 클린업이 소켓을 닫고 새로 열어 요구 사항 2를 어긴다. 재구성 비용이 큰 연결이라 전환할 때마다 2초 동안 메시지를 놓친다.', false),
(12280, 4538, '알림을 띄우는 함수를 [theme] 의존 useCallback으로 감싸고, 그 함수를 이펙트 의존성 배열에 넣는다.', 'useCallback은 의존성이 바뀌면 새 함수를 돌려준다. theme가 바뀌면 함수 참조가 달라지고, 그 함수를 의존성으로 둔 이펙트가 다시 실행돼 결국 소켓을 새로 연다. 참조를 고정해도 재실행이 막히지는 않는다.', false),
(12281, 4538, '의존성 배열은 [roomId]로 두고, 콜백 안에서 구조 분해한 theme 대신 props.theme를 읽는다.', 'props 객체도 그 렌더에 전달된 스냅샷이다. 콜백은 이펙트가 실행된 렌더의 props를 붙잡고 있어 점 표기로 읽어도 여전히 옛 theme를 읽는다. 구조 분해 여부와 상관없이 요구 사항 1을 어긴다.', false),
(12282, 4538, '렌더마다 theme를 themeRef.current에 담아 두고, 메시지 콜백에서는 themeRef.current를 읽는다.', 'ref 객체는 렌더가 바뀌어도 같은 객체라 의존성에 넣을 필요가 없어 소켓이 유지된다. 콜백은 메시지가 온 순간 current를 읽으므로 가장 최근 렌더가 담아 둔 theme를 얻는다. 두 요구 사항을 모두 만족한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1468, 4539, '함수형 업데이트,함수형업데이트,함수형 갱신,함수형 상태 업데이트,함수형 state 업데이트,functional update,functional updates,functional state update,updater function,업데이터 함수,업데이트 함수', '다섯 번의 클릭은 모두 likes가 0인 렌더에서 만들어진 handleClick을 실행한다. 응답이 오기 전까지는 state가 바뀌지 않아 리렌더도 없으므로, 응답 뒤에 이어지는 setLikes(likes + 1)은 다섯 번 모두 붙잡고 있던 0을 읽어 1을 넣고 화면은 1에서 멈춘다. setLikes((n) => n + 1)처럼 값 대신 함수를 넘기면 React가 갱신을 적용하는 시점의 최신 state를 n으로 넘겨 주므로, 붙잡힌 likes를 읽지 않고 1, 2, 3, 4, 5로 차례로 쌓인다. 이것이 함수형 업데이트이며, 이전 state를 바탕으로 다음 값을 계산할 때 가장 먼저 시도할 해결책이다. useState(() => ...)처럼 함수를 넘기는 지연 초기화와 헷갈리기 쉬운데, 지연 초기화는 초기값을 첫 렌더에서 한 번만 만드는 장치이고 함수형 업데이트는 갱신할 때마다 직전 값을 받아 다음 값을 계산하는 장치다. 여러 setState를 한 번의 렌더로 묶는 배칭(batching)과도 구분해야 한다. 배칭은 이 문제의 원인도 해결책도 아니다.'),
       (1469, 4540, 'Fiber,파이버,Fiber 노드,파이버 노드,Fiber node,FiberNode,Fiber 객체,파이버 객체,React Fiber,리액트 파이버', '출력된 객체는 Counter 컴포넌트에 대응하는 Fiber 노드다. tag 0은 함수 컴포넌트, type은 렌더 때 실행할 함수를 뜻하고, return·child·sibling은 부모·첫 자식·다음 형제 Fiber를 가리켜 트리를 이룬다. 핵심은 memoizedState다. 첫 훅인 useState의 셀이 값 3과 갱신 큐를 들고 있고, next로 두 번째 훅인 useRef의 셀 { current: 0 }이 이어진 뒤 null로 끝나는 연결 리스트다. Counter 함수는 렌더마다 처음부터 실행되지만 값은 함수의 지역 변수가 아니라 이 셀에 남아 있고, 훅은 호출 순서대로 셀을 꺼내 쓰기 때문에 3이 유지되고 다음 갱신 뒤에는 4로 바뀐다. JSX가 만드는 React 엘리먼트({ type, props, key })와 헷갈리기 쉬운데, 엘리먼트는 렌더마다 새로 만들어지는 화면 설명일 뿐 훅 셀을 담지 않는다. 실제 화면 요소인 DOM 노드와도 다르다. 함수 컴포넌트는 따로 만들어지는 인스턴스 객체가 없어 stateNode가 null이다.');

-- =====================================================
-- Lesson 884: 훅의 동작 원리: 인스턴스별 셀, 마운트 뒤의 초기값, 이펙트 재실행 조건
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5483, 884, '아래 앱에서 버튼을 누른 뒤 두 Panel에 표시되는 값으로 옳은 것은?', '```tsx
function useCounter() {
  const [n, setN] = useState(0);
  return [n, () => setN((v) => v + 1)];
}

function Panel() {
  const [a, incA] = useCounter();
  const [b, incB] = useCounter();
  return (
    <div>
      <button onClick={incA}>A+</button>
      <button onClick={incB}>B+</button>
      <span>{a} / {b}</span>
    </div>
  );
}

function App() {
  return (
    <>
      <Panel />
      <Panel />
    </>
  );
}
```

첫 번째 Panel의 A+ 버튼을 두 번, 두 번째 Panel의 B+ 버튼을 한 번 눌렀다. 각 Panel은 a / b 형식으로 값을 보여 준다.', 'OBJECTIVE'),
       (5484, 884, '아래 두 컴포넌트가 showNote가 true로 바뀌어 다시 렌더될 때 일어나는 일로 옳은 것은?', '```tsx
const NoteContext = createContext("정가");

function LabelA({ showNote }) {
  const [stock] = useState(3);
  if (!showNote) return <span>재고 {stock}개</span>;
  const [note] = useState("세일");
  return <span>재고 {stock}개 ({note})</span>;
}

function LabelB({ showNote }) {
  const [stock] = useState(3);
  if (!showNote) return <span>재고 {stock}개</span>;
  const note = use(NoteContext);
  return <span>재고 {stock}개 ({note})</span>;
}
```

React 19 환경이다. 두 컴포넌트 모두 showNote가 false인 상태로 처음 렌더됐고, 이후 부모가 showNote를 true로 바꿔 두 컴포넌트가 같은 자리에서 다시 렌더된다.', 'OBJECTIVE'),
       (5485, 884, '아래 상황에서 지영을 누른 직후 입력창에 보이는 값과 그 이유로 옳은 것은?', '```tsx
function NameField({ savedName }) {
  const [name, setName] = useState(savedName);
  return <input value={name} onChange={(e) => setName(e.target.value)} />;
}

function MemberEditor() {
  const [selected, setSelected] = useState(members[0]); // { name: "민수" }
  return (
    <>
      <MemberList onSelect={setSelected} />
      <NameField savedName={selected.name} />
    </>
  );
}
```

처음 화면에서는 민수가 선택돼 있었고 입력창에도 민수가 보였다. 입력창은 건드리지 않은 채 목록에서 지영을 누르자, selected가 지영으로 바뀌어 MemberEditor와 NameField가 다시 렌더됐다.', 'OBJECTIVE'),
       (5486, 884, '아래 표의 순서대로 ChatRoom이 렌더될 때, 마운트(렌더 1) 이후 이펙트가 다시 실행되는 렌더를 모두 고른 것은?', '```tsx
function ChatRoom({ roomId, userName }) {
  const [draft, setDraft] = useState("");

  const onMessage = useCallback((m) => {
    showToast(`${userName}님, 새 메시지: ${m}`);
  }, [userName]);

  useEffect(() => {
    const conn = connect(roomId);
    conn.on("message", onMessage);
    return () => conn.close();
  }, [roomId, onMessage]);

  return <input value={draft} onChange={(e) => setDraft(e.target.value)} />;
}
```

| 렌더 | 계기 | roomId | userName | draft |
| --- | --- | --- | --- | --- |
| 1 | 마운트 | "a" | "kim" | "" |
| 2 | 입력창에 h 입력 | "a" | "kim" | "h" |
| 3 | 부모가 userName을 바꿈 | "a" | "lee" | "h" |
| 4 | 부모가 다른 이유로 다시 렌더(넘기는 props 값은 그대로) | "a" | "lee" | "h" |
| 5 | 부모가 roomId를 바꿈 | "b" | "lee" | "h" |', 'OBJECTIVE'),
       (5487, 884, '아래 C안에서 prev를 보관하는 데 쓴 훅의 이름은?', '검색창 컴포넌트가 입력 중인 검색어를 state인 query로 들고 있다. query가 바뀔 때마다 이펙트에서 "직전 검색어 → 새 검색어" 로그를 남기려고, 직전 검색어 prev를 보관하는 방식 세 가지를 시험했다. 세 방식 모두 이펙트의 의존성 배열은 [query]이고, 이펙트는 로그를 찍은 뒤 prev를 이번 query 값으로 바꿔 둔다.

| 방식 | prev를 두는 곳 | a, ab를 차례로 입력했을 때 로그 | 입력 1번당 렌더 횟수 |
| --- | --- | --- | --- |
| A안 | 컴포넌트 함수 본문의 `let prev = ""` | "" → a, "" → ab | 1번 |
| B안 | `useState("")`로 만든 state (setPrev로 교체) | "" → a, a → ab | 2번 |
| C안 | 또 다른 훅 하나 | "" → a, a → ab | 1번 |', 'SUBJECTIVE'),
       (5488, 884, '아래 코드의 빈칸에 들어간 훅의 이름은?', '```tsx
function ProductPage({ productId }) {
  const cartCount = useCartCount(); // 장바구니에 담긴 상품 수

  const onVisit = ________((id) => {
    logVisit(id, cartCount);
  });

  useEffect(() => {
    onVisit(productId);
  }, [productId]);

  return <ProductDetail id={productId} />;
}
```

React 19.2 프로젝트에서 빈칸에 훅 하나를 넣고, 상품 A에 들어간 뒤 장바구니 상품 수를 0→1→2→3으로 바꾸고 상품 B로 옮겼다.

- 빈칸을 채운 위 코드: 방문 기록은 A, B 두 건만 남았고 B 기록의 cartCount는 3이었다. 의존성 배열에 onVisit와 cartCount가 없는데도 린터(react-hooks/exhaustive-deps) 경고가 뜨지 않았다.
- 비교용으로 빈칸 자리를 useCallback(..., [cartCount])로 바꾸고 의존성 배열을 [productId, onVisit]로 둔 코드: 같은 조작에서 방문 기록이 5건 남았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5483
(14795, 5483, '첫 번째 3 / 3, 두 번째 3 / 3', '커스텀 훅이 전역 저장소처럼 state 하나를 모두에게 나눠 준다고 본 오해. 커스텀 훅 안의 useState는 호출한 컴포넌트의 렌더 도중 실행돼, 부를 때마다 그 컴포넌트의 Fiber에 셀을 따로 만든다.', false),
(14796, 5483, '첫 번째 2 / 1, 두 번째 2 / 1', '셀이 Panel이라는 함수 종류에 붙는다고 보고 두 Panel이 값을 나눠 쓴다고 본 오해. Fiber는 컴포넌트 인스턴스마다 하나라서, 같은 Panel이라도 두 인스턴스는 각자의 셀 리스트를 가진다.', false),
(14797, 5483, '첫 번째 2 / 0, 두 번째 0 / 1', 'Panel 인스턴스마다 Fiber가 따로 있고, 한 Panel 안에서 두 번 부른 useCounter는 호출 순서대로 0번·1번 셀을 따로 차지한다. 그래서 첫 번째 Panel은 a만 2, 두 번째 Panel은 b만 1이 된다.', true),
(14798, 5483, '첫 번째 2 / 2, 두 번째 1 / 1', '같은 훅을 두 번 부르면 이름이 같아 한 셀을 함께 쓴다고 본 오해. 훅은 이름이 아니라 몇 번째로 호출됐는가로 자기 셀을 찾으므로 a와 b는 서로 다른 셀에 저장된다.', false),

-- 문제 5484
(14799, 5484, 'LabelA와 LabelB 모두 오류 없이 정상 렌더된다.', '이른 반환은 조건문이 아니니 괜찮다고 본 오해. LabelA는 이전 렌더에 useState 셀이 1개뿐이었는데 이번 렌더에서 하나를 더 불러, 호출 순서로 짝지을 셀이 없어 렌더가 오류로 멈춘다.', false),
(14800, 5484, 'LabelA와 LabelB 모두 렌더 도중 오류가 난다.', 'use도 다른 훅처럼 이른 반환 뒤에 부르면 안 된다고 본 오해. React 19의 use는 예외적으로 조건문·이른 반환 뒤에서도 부를 수 있게 만든 API라 LabelB는 정상으로 그려진다.', false),
(14801, 5484, 'LabelA는 정상 렌더되고, LabelB만 오류가 난다.', '새로 불린 useState는 마운트 때처럼 셀을 새로 붙이면 된다고 본 오해. 업데이트 렌더는 이전 리스트의 셀을 순서대로 꺼내 쓸 뿐 새 셀을 덧붙이지 않아 LabelA가 오류를 낸다. use 쪽은 오히려 허용된다.', false),
(14802, 5484, 'LabelA만 오류가 나고, LabelB는 정상 렌더된다.', 'LabelA는 이전 렌더보다 useState 호출이 하나 늘어 순서로 짝지을 셀이 없으므로 렌더 도중 오류가 난다. LabelB의 use(NoteContext)는 React 19에서 이른 반환 뒤 호출이 예외적으로 허용돼 정상으로 그려진다.', true),

-- 문제 5485
(14803, 5485, '민수 — 셀이 이미 있으면 그 값을 꺼내 쓰고, useState에 넘긴 인자는 쓰지 않는다.', 'NameField는 같은 자리에서 다시 렌더될 뿐이라 기존 Fiber의 셀을 그대로 꺼내 쓴다. useState 인자는 마운트 때 셀을 처음 만들 때만 쓰이므로 savedName이 지영으로 바뀌어도 name은 민수로 남는다.', true),
(14804, 5485, '지영 — props가 바뀌면 useState가 새 인자로 셀의 값을 다시 채운다.', 'useState 인자가 렌더마다 셀 값에 반영된다고 본 오해. 인자는 셀을 처음 만드는 마운트 때만 쓰이고, 업데이트 렌더에서는 셀에 보관된 값을 꺼낼 뿐 인자를 무시한다.', false),
(14805, 5485, '민수 — 이번 렌더의 savedName에도 이전 렌더 스냅샷인 민수가 그대로 들어온다.', '값은 맞지만 이유를 잘못 짚었다. 새 렌더는 새 props를 받으므로 이번 렌더의 savedName은 지영이다. 스냅샷은 한 렌더 안에서 값이 고정된다는 뜻이지 이전 렌더 값을 물려받는다는 뜻이 아니다.', false),
(14806, 5485, '지영 — props가 바뀌면 NameField가 새로 마운트돼 셀이 새로 만들어진다.', 'props가 바뀌면 컴포넌트가 새로 마운트된다고 본 오해. 같은 자리에 같은 컴포넌트가 그려지면 Fiber가 유지된 채 업데이트 렌더로 처리되므로 셀도 새로 만들어지지 않는다.', false),

-- 문제 5486
(14807, 5486, '렌더 5', 'useCallback으로 한 번 만든 함수는 계속 같은 함수라고 본 오해. 의존성 userName이 바뀐 렌더 3에서 useCallback은 새 함수를 돌려주고, 이펙트는 onMessage 참조가 달라진 것을 보고 다시 실행된다.', false),
(14808, 5486, '렌더 3, 5', '렌더 3은 userName이 바뀌어 useCallback이 새 함수를 돌려주고, 렌더 5는 roomId가 바뀌어 이펙트가 다시 돈다. 렌더 2·4는 roomId와 onMessage 참조가 이전 렌더와 같아 이펙트를 건너뛴다.', true),
(14809, 5486, '렌더 3, 4, 5', '부모가 다시 렌더하며 props를 새로 넘기면 useCallback도 새 함수를 만든다고 본 오해. 렌더 4의 userName은 여전히 lee라 의존성 비교에서 같다고 나오고, 이전 함수가 그대로 돌아와 이펙트도 건너뛴다.', false),
(14810, 5486, '렌더 2, 3, 4, 5', 'useCallback을 써도 렌더마다 새 함수가 생긴다고 본 오해. 의존성이 같으면 이전 함수를 그대로 돌려주므로 draft만 바뀐 렌더 2와 값이 그대로인 렌더 4에서는 이펙트가 다시 실행되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1784, 5487, 'useRef,useRef(),ref,레프,유즈레프,유즈 레프,ref 객체,React.useRef', 'C안은 useRef다. useRef가 돌려주는 { current } 객체는 Fiber의 셀에 보관돼 렌더가 바뀌어도 같은 객체이므로, 이펙트 끝에서 prevRef.current = query로 적어 둔 값이 다음 렌더의 이펙트까지 살아남아 "a → ab"가 찍힌다. 또 current를 바꾸는 일은 갱신 큐에 아무것도 넣지 않아 렌더를 일으키지 않으므로 입력 1번당 렌더가 1번이다. A안의 let 변수는 컴포넌트 함수가 렌더마다 처음부터 다시 실행되며 빈 문자열로 새로 만들어져 직전 값이 사라진다. B안의 useState는 값은 남지만 setPrev가 렌더를 한 번 더 예약해 입력마다 렌더가 2번 일어난다. 화면에 보여야 하는 값이면 useState, 화면과 상관없이 렌더 사이에 기억만 하면 되는 값이면 useRef를 고른다. useRef를 DOM 요소를 가리키는 용도로만 알기 쉬운데, 타이머 id나 직전 값처럼 렌더와 무관한 값을 보관하는 데도 쓴다.'),
       (1785, 5488, 'useEffectEvent,useEffectEvent(),use effect event,유즈이펙트이벤트,유즈 이펙트 이벤트,이펙트 이벤트,effect event,experimental_useEffectEvent,React.useEffectEvent', '빈칸은 useEffectEvent다. useEffectEvent로 감싼 함수는 이펙트 안에서 불릴 때 항상 가장 최근 렌더의 props와 state를 읽지만, 반응형 값으로 취급되지 않아 의존성 배열에서 빼야 하고 린터도 이를 알아 경고하지 않는다. 그래서 이펙트는 productId가 바뀔 때만 다시 돌아 기록이 A, B 두 건이고, B 기록은 방문 순간의 최신 cartCount인 3을 읽는다. useCallback은 의존성 cartCount가 바뀔 때마다 새 함수를 돌려주고, 그 함수를 의존성으로 둔 이펙트가 매번 다시 실행돼 기록이 5건(A 4건, B 1건)이 된다. ref에 최신 cartCount를 담아 읽는 방법도 같은 목적을 이룰 수 있지만, 렌더마다 ref.current를 직접 갱신해야 하고 함수를 감싸는 형태가 아니라 빈칸에 들어갈 수 없다. useEffectEvent는 React 19.2에서 정식 제공됐고 그 이전에는 실험 채널에서만 쓸 수 있었다. 이렇게 만든 함수는 이펙트 안에서만 불러야 하며, 이벤트 핸들러로 자식에게 넘기는 용도가 아니다.');
