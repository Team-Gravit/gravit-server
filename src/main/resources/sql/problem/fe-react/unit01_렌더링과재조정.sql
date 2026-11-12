-- Unit: 렌더링과 재조정 (Unit ID: 141)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (567, 141, '리렌더 원인과 key, 자동 배칭'),
       (725, 141, '위치 기반 상태 유지와 flushSync'),
       (883, 141, '렌더링과 재조정: 갱신 생략과 엘리먼트 정체성');

-- =====================================================
-- Lesson 567: 리렌더 원인과 key, 자동 배칭
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3581, 567, '아래 코드에서 위쪽 입력창에 글자를 칠 때, Field 안의 메모 입력창에 적어 둔 내용에 일어나는 일로 옳은 것은?', '```tsx
function Form() {
  const [q, setQ] = useState("");

  function Field() {
    return <input placeholder="메모" />;
  }

  return (
    <>
      <input value={q} onChange={(e) => setQ(e.target.value)} />
      <Field />
    </>
  );
}
```

메모 입력창에 먼저 몇 글자를 적어 둔 뒤, 위쪽 입력창에 글자를 한 자씩 입력한다.', 'OBJECTIVE'),
       (3582, 567, '아래 코드를 React 18의 createRoot 환경에서 실행하고 버튼을 한 번 눌렀을 때, 콘솔에 render가 찍히는 횟수는? (초기 마운트 때의 1회는 세지 않는다)', '```tsx
function App() {
  console.log("render");
  const [a, setA] = useState(0);
  const [b, setB] = useState(0);

  function handleClick() {
    setTimeout(() => {
      setA((v) => v + 1);
      setB((v) => v + 1);
    }, 0);
  }

  return <button onClick={handleClick}>{a + b}</button>;
}
```', 'OBJECTIVE'),
       (3583, 567, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 단계 | 하는 일 | 중단 여부 |
| --- | --- | --- |
| 렌더 | 컴포넌트 함수를 호출해 새 엘리먼트 트리를 만든다 | 중간에 멈추고 처음부터 다시 실행될 수 있다 |
| 재조정 | 새 트리와 이전 트리를 비교해 바뀐 자리를 표시한다 | 렌더와 함께 진행된다 |
| 커밋 | 표시된 자리만 실제 DOM에 반영한다 | 끝까지 중단 없이 한 번에 끝난다 |', 'OBJECTIVE'),
       (3584, 567, '아래 진단 기록에서 CartBadge의 컴포넌트 함수가 다시 호출된 원인으로 옳은 것은?', 'Profiler 기록 — 헤더 검색창에 글자 하나 입력, 화면 갱신 1회

```
Header        1.2ms   자신의 상태(검색어) 변경 있음
Nav           0.3ms   상태 변경 없음 · props 이전과 동일 · Context 구독 없음
CartBadge     0.4ms   상태 변경 없음 · props 이전과 동일 · Context 구독 없음
ProductList   2.1ms   상태 변경 없음 · props 이전과 동일 · Context 구독 없음
```

- Nav · CartBadge · ProductList는 Header가 직접 렌더하는 자식이다.
- 네 컴포넌트 모두 이번 갱신에서 컴포넌트 함수가 호출됐다.
- React.memo로 감싼 컴포넌트는 없다.', 'OBJECTIVE'),
       (3585, 567, '아래 상황은 항목마다 지정한 값을 잘못 골라 생긴 문제다. 값을 잘못 지정한 속성의 이름은?', '할 일 목록의 각 항목에는 체크박스와 메모 입력창이 있다. 항목마다 배열의 순서 번호를 넘겨 목록을 그렸다.

```
지우기 전
  1) 장보기   체크됨       메모: (없음)
  2) 세탁     체크 안 됨   메모: 내일 오전
  3) 운동     체크 안 됨   메모: (없음)

장보기를 지운 뒤 화면
  1) 세탁     체크됨       메모: (없음)
  2) 운동     체크 안 됨   메모: 내일 오전
```

항목 이름은 제대로 두 개로 줄었는데 체크와 메모만 한 칸씩 위로 밀려 붙었다. 항목마다 넘기던 값을 순서 번호에서 각 항목의 고유 id로 바꾸자 증상이 사라졌다.', 'SUBJECTIVE'),
       (3586, 567, '아래 상황에서 개발 모드에만 나타난 현상의 원인이 된, 최상위 트리를 감싸던 React 컴포넌트의 이름은?', '개발 서버에서 상품 목록 페이지를 열자 콘솔에 다음처럼 찍혔다.

```
[ProductList] render
[ProductList] render
[ProductItem] render
[ProductItem] render
```

컴포넌트 함수 안에서 모듈 전역 배열에 항목을 push하던 코드도 항목을 두 개씩 쌓았다. 같은 코드를 프로덕션으로 빌드해 배포하니 로그는 한 줄씩만 찍혔고 배열에도 항목이 하나씩만 들어갔다. 팀에서는 index.tsx에서 최상위 트리를 감싸던 컴포넌트를 잠시 걷어내 원인을 확인했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3581
(9723, 3581, 'Field는 이름이 같은 함수이므로 React가 같은 타입으로 보고 메모 입력창을 그대로 유지한다.', 'React는 엘리먼트 타입을 함수 이름이 아니라 함수 참조로 비교한다. Field는 Form이 실행될 때마다 새로 만들어지는 다른 함수 객체라 이름이 같아도 같은 타입이 될 수 없다.', false),
(9724, 3581, 'Field는 props를 받지 않으므로 React가 호출을 건너뛰고 이전 결과를 그대로 재사용한다.', 'props가 없거나 그대로여도 부모가 리렌더되면 자식은 다시 호출된다. 건너뛰기 판단은 React.memo로 감쌌을 때만 들어가고, 그마저도 앞뒤 타입이 같아야 적용된다.', false),
(9725, 3581, '메모 입력창이 언마운트된 뒤 새로 마운트되어, 적어 둔 내용이 글자를 칠 때마다 사라진다.', 'Form이 실행될 때마다 Field가 새 함수 객체가 되어 이전 렌더와 타입이 달라진다. 타입이 다르면 React는 그 서브트리를 통째로 버리고 새로 마운트하므로 input이 들고 있던 값도 함께 사라진다.', true),
(9726, 3581, '메모 입력창의 DOM 노드는 유지되고 placeholder처럼 바뀐 속성만 새로 갱신된다.', '속성만 갱신하는 처리는 앞뒤 엘리먼트의 타입이 같을 때 일어난다. 여기서는 타입 자체가 매 렌더 달라지므로 속성 갱신이 아니라 서브트리 교체가 일어난다.', false),

-- 문제 3582
(9727, 3582, '0', 'setter가 갱신을 예약만 한다는 설명을 렌더가 아예 일어나지 않는다는 뜻으로 오해한 것. 예약된 갱신은 처리되면서 렌더를 일으키고 바뀐 a + b가 화면에 반영된다.', false),
(9728, 3582, '1', 'React 18의 createRoot는 자동 배치를 적용해 setTimeout 콜백처럼 이벤트 핸들러 밖에서 부른 setter까지 한 번의 렌더로 묶는다. setA와 setB가 모여 렌더는 한 번만 일어난다.', true),
(9729, 3582, '2', 'React 17 이하의 동작이다. 그때는 React 이벤트 핸들러 안에서만 배치돼 setTimeout 콜백에서는 setter마다 렌더됐다. 18의 createRoot에서는 핸들러 밖에서도 배치된다.', false),
(9730, 3582, '3', '버튼 클릭 자체가 렌더를 일으킨다고 보고 setter 두 번을 더한 것. handleClick은 setTimeout을 예약할 뿐 상태를 바꾸지 않아 그 시점에는 렌더가 일어나지 않는다.', false),

-- 문제 3583
(9731, 3583, '렌더 안에서 전역 카운터를 1 늘리는 코드를 넣어도, 화면 갱신 한 번에 카운터는 정확히 1만 늘어난다.', '렌더는 중간에 멈추고 처음부터 다시 실행될 수 있어 한 번의 갱신에서 컴포넌트 함수가 여러 번 돌 수 있다. 카운터는 2 이상 늘어날 수 있으며, 렌더 단계에 부수효과를 두면 안 되는 이유가 여기에 있다.', true),
(9732, 3583, '컴포넌트 함수가 다시 호출됐다는 사실만으로는 그 자리의 DOM이 실제로 바뀌었다고 말할 수 없다.', '참이다. 함수 호출은 렌더 단계의 일이고, 비교에서 표시된 자리가 없으면 커밋에서 반영할 것도 없다. 리렌더 횟수와 DOM 갱신 횟수는 따로 세야 한다.', false),
(9733, 3583, '변경의 일부만 반영된 어중간한 중간 화면이 사용자에게 보이는 일은 없다.', '참이다. 커밋은 중단 없이 한 번에 끝나므로 반영 도중의 트리가 화면에 노출되지 않는다. 렌더 결과와 실제 DOM이 늘 일관되게 유지되는 근거다.', false),
(9734, 3583, '성능이 나쁠 때 먼저 줄여야 할 대상은 DOM 반영보다 컴포넌트 함수의 재실행일 때가 많다.', '참이다. 커밋은 표시된 자리만 건드리지만 렌더는 트리의 넓은 범위를 다시 계산할 수 있다. 그래서 비용은 대개 함수 재실행 쪽에 쌓인다.', false),

-- 문제 3584
(9735, 3584, 'CartBadge에 넘어온 props가 새 객체로 다시 만들어져 얕은 비교에서 달라졌기 때문이다.', '기록에는 props가 이전과 동일하다고 적혀 있다. 게다가 props 얕은 비교로 호출 여부가 갈리는 것은 React.memo로 감쌌을 때뿐인데, 감싼 컴포넌트도 없다.', false),
(9736, 3584, '상위에서 내려오는 Context 값이 바뀌어 이를 구독하던 CartBadge가 갱신됐기 때문이다.', '기록에는 Context 구독이 없다고 적혀 있다. Context 값 변경은 useContext로 구독한 컴포넌트만 다시 호출하게 하며, 구독하지 않은 컴포넌트에는 트리거가 되지 않는다.', false),
(9737, 3584, '커밋 단계에서 CartBadge의 DOM이 실제로 갱신되면서 함수가 한 번 더 호출됐기 때문이다.', '컴포넌트 함수 호출은 렌더 단계의 일이다. 커밋은 이미 계산해 둔 변경을 DOM에 반영할 뿐 함수를 다시 호출하지 않는다. 렌더와 커밋의 역할을 뒤섞은 오해다.', false),
(9738, 3584, '부모인 Header가 다시 렌더돼 그 아래 자식들이 함께 호출됐기 때문이다.', '리렌더 트리거는 자신의 상태 변경, 부모의 리렌더, 구독한 Context 변경 셋뿐이다. CartBadge는 앞뒤 두 가지가 모두 아니고 Header만 상태가 바뀌었으니 부모 리렌더에 딸려 호출된 것이다. props가 그대로여도 memo가 없으면 건너뛰지 않는다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1150, 3585, 'key,키,key 속성,키 속성,key prop', 'key는 형제 항목 사이에서 어떤 엘리먼트가 이전 렌더의 어떤 엘리먼트와 같은 것인지 알려주는 유일한 수단이다. 순서 번호를 key로 쓰면 앞 항목을 지웠을 때 뒤 항목들이 앞 항목의 key를 물려받고, React는 이를 같은 엘리먼트로 보아 체크 상태와 입력값을 그대로 유지한다. 그래서 이름은 제대로 줄었는데 상태만 한 칸씩 밀려 붙는다. 고유 id를 쓰면 정체성이 항목을 따라가므로 지운 항목만 빠지고 나머지는 자기 상태를 그대로 데려간다. key는 형제 사이에서만 고유하면 되고 전역 고유일 필요는 없다. DOM 속성으로 전달되지 않아 자식에서 props.key로 읽을 수 없다는 점에서 id 속성이나 ref와 구분된다.'),
       (1151, 3586, 'StrictMode,Strict Mode,React.StrictMode,<StrictMode>,엄격 모드,엄격모드,스트릭트 모드', '개발 모드의 StrictMode는 컴포넌트 함수를 일부러 두 번 호출해 렌더 단계에 숨어 있던 부수효과를 드러낸다. 전역 배열에 push하는 코드처럼 렌더가 순수하지 않으면 결과가 두 배로 쌓여 바로 눈에 띈다. 프로덕션 빌드에서는 한 번만 호출하므로 증상이 사라지는데, 이는 StrictMode가 버그를 만든 것이 아니라 이미 있던 순수성 위반을 보여 준 것이다. 따라서 감싸기를 걷어내는 대신 부수효과를 useEffect처럼 커밋 이후 단계로 옮겨야 한다. 어떤 컴포넌트가 왜 렌더됐는지 기록하는 Profiler, 리렌더를 화면에서 깜빡여 보여 주는 Highlight updates와는 역할이 다르다.');

-- =====================================================
-- Lesson 725: 위치 기반 상태 유지와 flushSync
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4529, 725, '아래 코드와 조작 순서에서 팀 바꾸기 버튼을 누른 직후 화면에 보이는 내용과 그 이유로 옳은 것은?', '```tsx
function ScoreBoard() {
  const [isBlue, setIsBlue] = useState(true);

  return (
    <div>
      {isBlue ? <TeamScore team="청팀" /> : <TeamScore team="백팀" />}
      <button onClick={() => setIsBlue(!isBlue)}>팀 바꾸기</button>
    </div>
  );
}

function TeamScore({ team }) {
  const [score, setScore] = useState(0);

  return (
    <button onClick={() => setScore(score + 1)}>
      {team}: {score}
    </button>
  );
}
```

청팀 버튼을 세 번 눌러 화면에 "청팀: 3"이 보이는 상태에서 팀 바꾸기 버튼을 한 번 누른다.', 'OBJECTIVE'),
       (4530, 725, '아래 상황에서 답글 입력칸의 글자가 지워지는 원인으로 옳은 것은?', '댓글 목록 화면이다. 상단 시계를 위해 1초마다 상태를 갱신하고, 각 CommentItem은 답글 입력칸의 글자를 자기 안의 useState로 들고 있다.

```tsx
function CommentList({ comments }) {
  const [now, setNow] = useState(Date.now());

  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, []);

  return (
    <>
      <p>{new Date(now).toLocaleTimeString()}</p>
      {comments.map((c) => (
        <CommentItem key={Math.random()} comment={c} />
      ))}
    </>
  );
}
```

답글을 치는 도중 1초 안팎마다 입력한 글자가 통째로 지워지고 입력칸의 포커스도 풀린다. 시계를 갱신하는 setInterval을 잠시 지우자 증상이 사라졌다.', 'OBJECTIVE'),
       (4531, 725, '아래 컴포넌트 구조에서 theme이 바뀐 뒤 컴포넌트 함수가 다시 호출되는 것만 모두 고른 것은?', '```
App              useState로 theme을 들고, <ThemeContext.Provider value={theme}>로 아래를 감싼다
└─ Layout        React.memo로 감쌌고, 받는 props가 없다
   ├─ Sidebar    받는 props가 없고, Context를 구독하지 않는다
   └─ SaveButton useContext(ThemeContext)로 theme을 읽는다
```

App 안의 버튼을 눌러 theme을 "light"에서 "dark"로 한 번 바꿨다.', 'OBJECTIVE'),
       (4532, 725, '아래 컴포넌트에서 버튼을 처음 한 번 눌렀을 때, 콘솔에 찍히는 값과 처리가 끝난 뒤 버튼에 보이는 값으로 옳은 것은?', '```tsx
function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    setCount(count + 1);
    setCount(count + 1);
    setCount((c) => c + 1);
    console.log(count);
  }

  return <button onClick={handleClick}>{count}</button>;
}
```', 'OBJECTIVE'),
       (4533, 725, '아래 상황에서 문제를 해결하려고 가져다 쓴 react-dom 함수의 이름은?', '메시지를 보내면 목록 맨 아래의 새 메시지까지 스크롤되게 하려고 전송 핸들러를 다음처럼 작성했다.

```tsx
function handleSend() {
  setMessages([...messages, draft]);
  listRef.current.lastElementChild.scrollIntoView();
}
```

실제로 보내 보니 다음과 같았다.

```
처음 목록: 안녕 / 뭐 해?
"밥 먹자" 전송   → 스크롤이 멈춘 메시지: 뭐 해?
"지금 갈게" 전송 → 스크롤이 멈춘 메시지: 밥 먹자
```

react-dom에서 가져온 함수 하나로 setMessages 호출을 감싸고 scrollIntoView 줄은 그대로 두자, 스크롤이 매번 방금 보낸 메시지에 정확히 멈췄다.', 'SUBJECTIVE'),
       (4534, 725, '아래 상황에서 코드를 고칠 때 바꿔 넣은 React 훅의 이름은?', '버튼 위에 마우스를 올리면 버튼 바로 위에 툴팁이 뜬다. 툴팁 높이는 글 길이에 따라 달라서, 한 번 그린 뒤 높이를 재어 위치를 정하도록 작성했다.

```tsx
function Tooltip({ anchorTop, text }) {
  const ref = useRef(null);
  const [top, setTop] = useState(0);

  useEffect(() => {
    const { height } = ref.current.getBoundingClientRect();
    setTop(anchorTop - height);
  }, [anchorTop, text]);

  return (
    <div ref={ref} style={{ position: "absolute", top }}>
      {text}
    </div>
  );
}
```

화면 녹화를 한 프레임씩 넘겨 보니 다음과 같았다.

```
프레임 1: 툴팁이 페이지 맨 위(top 0)에 보임
프레임 2: 툴팁이 버튼 바로 위(top 312)로 옮겨 감
```

useEffect를 이름만 다른 React 훅 하나로 바꾸고 인자와 안의 코드는 그대로 두자, 프레임 1부터 툴팁이 top 312에 보였다. 대신 측정 코드에 무거운 계산을 덧붙이자 마우스를 올린 뒤 화면이 잠깐 멈춘 듯 반응이 늦어졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4529
(12251, 4529, '백팀: 0 — team 값이 달라졌으므로 React가 다른 엘리먼트로 보고 TeamScore를 새로 마운트한다.', 'props가 달라져도 엘리먼트의 정체성은 바뀌지 않는다. React는 트리의 같은 자리에 온 엘리먼트를 타입과 key로 비교하므로, 타입이 그대로인 TeamScore는 기존 인스턴스를 유지한 채 새 team 값만 받는다.', false),
(12252, 4529, '백팀: 0 — 삼항 연산자의 두 갈래가 코드상 다른 곳에 적혀 있어 React가 서로 다른 자리로 구분한다.', 'React는 JSX가 소스 코드의 어디에 적혔는지 보지 않는다. 렌더 결과 트리에서 div의 첫 번째 자식 자리에 무엇이 오는지만 보므로, 어느 갈래가 선택되든 같은 자리에 같은 타입인 TeamScore가 온다.', false),
(12253, 4529, '백팀: 3 — 같은 자리에 같은 컴포넌트 타입이 와서 기존 상태가 유지되고 team만 새 값으로 바뀐다.', '팀을 바꾸기 전과 후 모두 div의 첫 번째 자식이 TeamScore라 타입 비교에서 같은 컴포넌트로 판정된다. React는 인스턴스와 score 상태를 그대로 둔 채 새 props로 리렌더하므로 이름표만 백팀으로 바뀌고 점수 3은 남는다.', true),
(12254, 4529, '청팀: 3 — props만 바뀐 TeamScore는 다시 호출되지 않아 팀을 바꾸기 전 화면이 그대로 남는다.', 'props 변경이 리렌더 트리거가 아니라는 말을 자식이 호출되지 않는다는 뜻으로 오해한 것. 부모 ScoreBoard의 상태가 바뀌어 리렌더되면 자식 TeamScore도 함께 호출되므로 이름표는 새 team 값인 백팀으로 바뀐다.', false),

-- 문제 4530
(12255, 4530, '렌더할 때마다 항목의 key가 새 값이 되어 React가 이전 항목을 버리고 새로 마운트하기 때문이다.', 'Math.random()은 호출할 때마다 다른 값을 내므로 CommentList가 매초 리렌더될 때 모든 항목의 key가 바뀐다. key가 다르면 React는 다른 엘리먼트로 보고 언마운트 후 새로 마운트해 입력 상태·DOM·포커스가 함께 사라진다. 데이터의 고유 id를 key로 써야 한다.', true),
(12256, 4530, '부모가 리렌더될 때마다 자식 컴포넌트의 useState가 초기값으로 다시 설정되기 때문이다.', '리렌더를 새로 마운트되는 것과 혼동한 것. 같은 엘리먼트로 판정된 자식은 부모가 리렌더돼도 상태를 그대로 유지한다. useState의 초기값이 다시 쓰이는 것은 새로 마운트될 때뿐이고, 이 코드에서 매초 새 마운트를 일으킨 것은 key다.', false),
(12257, 4530, 'CommentItem을 React.memo로 감싸지 않아 부모가 리렌더될 때마다 입력칸 DOM이 새로 만들어지기 때문이다.', 'React.memo가 없으면 컴포넌트 함수는 다시 호출되지만, 같은 엘리먼트로 판정되면 DOM 노드는 유지되고 바뀐 속성만 갱신된다. 또 key가 매번 달라지면 React.memo로 감싸도 이전 엘리먼트와 짝이 맞지 않아 새로 마운트되므로 증상은 그대로다.', false),
(12258, 4530, 'key는 화면 전체에서 고유해야 하는데 Math.random() 값은 다른 목록의 key와 겹칠 수 있기 때문이다.', 'key는 형제 사이에서만 고유하면 되고 다른 목록의 key와 겹쳐도 문제가 없다. 설령 형제끼리 겹치더라도 매초 글자가 통째로 지워지는 증상으로 이어지지 않는다. 원인은 겹침이 아니라 렌더마다 key가 새 값으로 바뀌는 것이다.', false),

-- 문제 4531
(12259, 4531, 'App, Layout, Sidebar, SaveButton', '부모가 리렌더되면 자손이 모두 따라 호출된다고 보고 React.memo를 빠뜨린 것. Layout은 React.memo로 감쌌고 props가 없어 얕은 비교 결과가 같으므로 건너뛰며, Layout이 호출되지 않으니 그 자식 Sidebar도 호출되지 않는다.', false),
(12260, 4531, 'App, Layout, SaveButton', 'Context 값이 중간 컴포넌트를 거쳐 전달되므로 Layout도 다시 호출돼야 SaveButton에 닿는다고 오해한 것. Provider의 value가 바뀌면 React가 구독한 컴포넌트를 직접 찾아 갱신하므로 React.memo로 건너뛴 Layout은 호출되지 않는다.', false),
(12261, 4531, 'App', 'React.memo가 그 아래 서브트리 전체의 갱신을 막는다고 오해한 것. React.memo는 Layout 자신의 리렌더만 건너뛸 뿐이고, useContext로 theme을 구독한 SaveButton은 중간 컴포넌트와 상관없이 값이 바뀌면 리렌더된다.', false),
(12262, 4531, 'App, SaveButton', 'App은 자신의 상태가 바뀌어 호출된다. Layout은 React.memo로 감쌌고 props가 없어 건너뛰며, 그래서 Sidebar에는 부모 리렌더가 전해지지 않는다. SaveButton은 구독한 Context 값이 바뀌어 중간의 React.memo와 상관없이 리렌더된다.', true),

-- 문제 4532
(12263, 4532, '콘솔 0, 버튼 1', '배치가 여러 갱신을 하나로 합친다고 오해한 것. 배치는 렌더를 한 번으로 묶을 뿐 예약된 갱신은 순서대로 모두 처리된다. 두 번의 count + 1이 값을 1로 만들고, 마지막 함수형 갱신이 그 1에 1을 더한다.', false),
(12264, 4532, '콘솔 0, 버튼 2', '핸들러 안의 count는 이번 렌더의 값 0으로 고정돼 console.log도 0을 찍는다. 예약된 갱신은 다음 렌더에서 차례로 처리된다. count + 1 두 번은 모두 0 + 1이라 값이 1이 되고, 함수형 갱신이 직전 결과 1을 받아 2를 만든다.', true),
(12265, 4532, '콘솔 3, 버튼 3', 'setter가 count를 즉시 바꾼다고 오해한 것. setter는 갱신을 예약만 하므로 핸들러가 끝날 때까지 count는 0이고 console.log도 0을 찍는다. 두 번의 count + 1도 각각 0 + 1, 즉 1로 바꾸라는 요청을 넣을 뿐이다.', false),
(12266, 4532, '콘솔 0, 버튼 3', 'count + 1도 함수형 갱신처럼 직전 결과에 쌓인다고 오해한 것. count + 1은 이번 렌더에서 고정된 0을 읽어 1로 바꾸라는 요청을 두 번 넣으므로 누적되지 않는다. 직전 결과를 받아 쌓는 것은 (c) => c + 1 형태뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1466, 4533, 'flushSync,flushSync(),ReactDOM.flushSync,ReactDOM.flushSync(),플러시싱크,플러시 싱크', 'setter는 갱신을 예약만 하고, 렌더와 커밋은 핸들러가 끝난 뒤 배치로 한 번에 일어난다. 그래서 setMessages 바로 다음 줄에서는 DOM에 새 메시지가 아직 없어 lastElementChild가 직전 메시지를 가리키고, 스크롤이 한 박자 늦게 따라온다. flushSync의 콜백 안에서 일으킨 상태 갱신은 배치를 기다리지 않고 렌더와 커밋까지 곧바로 마친 뒤 반환되므로, 다음 줄의 scrollIntoView가 방금 추가된 메시지를 찾는다. 대신 배치로 얻는 성능 이점을 포기하는 것이라 갱신 직후 DOM을 곧바로 읽어야 하는 곳에만 쓴다. 이전 값을 받아 갱신하는 함수형 갱신(setMessages((prev) => [...prev, draft]))과 헷갈리기 쉽지만, 함수형 갱신은 계산할 값을 바로잡을 뿐 DOM 반영 시점을 앞당기지 않는다. 여러 setter를 한 번의 렌더로 묶는 자동 배치와는 방향이 정반대다.'),
       (1467, 4534, 'useLayoutEffect,useLayoutEffect(),React.useLayoutEffect,유즈레이아웃이펙트,유즈 레이아웃 이펙트,레이아웃 이펙트,layout effect', '커밋 단계는 DOM 반영 → useLayoutEffect 실행 → 브라우저 페인트 → useEffect 실행 순서로 흘러간다. useEffect는 페인트가 끝난 뒤에 돌기 때문에 top 0으로 그려진 화면이 먼저 사용자에게 보이고, 그다음에야 높이를 재 위치를 고쳐 프레임 1과 2가 갈린다. useLayoutEffect는 DOM이 반영된 직후 페인트 전에 동기로 실행되고, 그 안에서 부른 setTop으로 인한 리렌더도 페인트 전에 끝나 처음부터 올바른 위치가 그려진다. 대신 실행이 끝날 때까지 페인트를 막으므로 안의 코드가 무거우면 화면 반응이 늦어진다. 본문 마지막 증상이 이 비용이다. 그래서 레이아웃 측정처럼 페인트 전에 끝내야 하는 일에만 쓰고, 데이터 요청·구독은 useEffect에 둔다. 컴포넌트 함수 본문(렌더 단계)에서 바로 DOM을 재는 방식과도 구분해야 한다. 렌더 단계에서는 새 DOM이 아직 반영되지 않았고 순수해야 하므로 측정이나 setter 호출을 두면 안 된다.');

-- =====================================================
-- Lesson 883: 렌더링과 재조정: 갱신 생략과 엘리먼트 정체성
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5477, 883, '아래 코드와 조작 순서에서 목록에 일어나는 일로 옳은 것은?', '```tsx
function TagEditor() {
  const [tags, setTags] = useState(["react"]);
  const [draft, setDraft] = useState("");

  function handleAdd() {
    tags.push(draft);
    setTags(tags);
  }

  return (
    <>
      <input value={draft} onChange={(e) => setDraft(e.target.value)} />
      <button onClick={handleAdd}>추가</button>
      <ul>
        {tags.map((t) => (
          <li key={t}>{t}</li>
        ))}
      </ul>
    </>
  );
}
```

입력창에 hooks를 친 뒤 추가 버튼을 누르고, 이어서 입력창에 !를 한 글자 더 친다.', 'OBJECTIVE'),
       (5478, 883, '아래 상황에서 원하는 동작을 만드는 수정으로 옳은 것은?', '메신저 화면이다. 왼쪽 목록에서 대화 상대를 누르면 오른쪽 ChatRoom에 그 상대와의 대화가 보인다. ChatRoom은 새 메시지가 도착할 때마다 다시 렌더된다.

```tsx
function ChatRoom({ contact, messages }) {
  return (
    <>
      <MessageList messages={messages} />
      <DraftInput to={contact} />
    </>
  );
}

function DraftInput({ to }) {
  const [text, setText] = useState("");

  return (
    <input
      value={text}
      onChange={(e) => setText(e.target.value)}
      placeholder={`${to.name}에게 보내기`}
    />
  );
}
```

민수와의 대화에서 "내일 봐"까지 적어 둔 채 상대를 지영으로 바꾸자, 안내 문구는 "지영에게 보내기"로 바뀌었는데 "내일 봐"는 그대로 남아 있었다.

원하는 동작은 상대를 바꾸면 입력창이 비고, 같은 상대와 대화하는 동안에는 새 메시지가 와도 적던 글자가 남는 것이다.', 'OBJECTIVE'),
       (5479, 883, '아래 표의 쌍 가운데, 바뀐 뒤 입력창에 적어 둔 글자가 사라지는 것만 모두 고른 것은?', 'Editor는 안에 입력창 하나를 두고, 적힌 글자를 자기 useState로 들고 있는 컴포넌트다. (라)의 input은 value를 지정하지 않은 입력창이다. 각 쌍은 같은 부모의 같은 자리가 한 번의 리렌더로 이전 렌더에서 다음 렌더로 바뀐 경우이며, 바뀌기 전 모든 입력창에 글자를 적어 두었다.

| 쌍 | 이전 렌더 | 다음 렌더 |
| --- | --- | --- |
| (가) | `<div><Editor /></div>` | `<section><Editor /></section>` |
| (나) | `<Editor theme="light" />` | `<Editor theme="dark" />` |
| (다) | `<Editor key="a" />` | `<Editor key="b" />` |
| (라) | `<input className="on" />` | `<input className="off" />` |', 'OBJECTIVE'),
       (5480, 883, '아래 확인 결과를 ProductList 기준으로 해석한 것으로 옳은 것은?', '검색 페이지에서 검색창에 글자를 칠 때마다 화면이 버벅여 두 가지를 확인했다. 검색어 상태는 SearchPage가 들고 있고, SearchBox와 ProductList는 SearchPage가 직접 렌더하는 자식이다. ProductList는 검색어와 무관한 고정 상품 500개를 보여 주며, React.memo로 감싸지 않았다.

```
[React DevTools] Highlight updates 켬
  글자 1개 입력마다 → SearchBox, ProductList 영역에 테두리가 깜빡임

[MutationObserver] ProductList 영역의 DOM 변경 감시
  글자 10개 입력 → 기록된 변경 0건
```', 'OBJECTIVE'),
       (5481, 883, '아래 상황에서 SalesChart를 감싼 React API의 이름은?', '대시보드 페이지 Dashboard는 상단 시계를 위해 1초마다 자기 상태를 갱신한다. 그 아래 SalesChart는 한 번 그리는 데 약 40ms가 드는 차트 컴포넌트로, Dashboard가 처음에 한 번 받아 상태로 들고 있는 data 배열만 props로 받는다.

```
수정 전   1분 동안 SalesChart 함수 호출 61회 (첫 화면 1회 포함), 시계가 넘어갈 때마다 버벅임
수정 후   1분 동안 SalesChart 함수 호출 1회 (첫 화면 1회)
```

수정은 SalesChart 파일의 export 줄에서 컴포넌트를 React가 제공하는 함수 하나로 감싼 것뿐이었다. 그런데 몇 주 뒤 누군가 Dashboard에서 `<SalesChart data={data} style={{ height: 300 }} />`처럼 style을 넘기도록 고치자, 호출 횟수가 다시 1분에 60회 이상으로 늘었다.', 'SUBJECTIVE'),
       (5482, 883, '아래 측정에서 렌더 횟수가 달라진 원인이 된 React 18의 동작을 가리키는 용어는?', 'React 18 프로젝트의 주문 화면 OrderPage는 서버 응답을 받으면 세 상태를 갱신한다. 세 상태 모두 응답 전과 다른 값으로 바뀐다.

```tsx
useEffect(() => {
  fetch("/api/order")
    .then((res) => res.json())
    .then((data) => {
      setOrder(data);
      setLoading(false);
      setFetchedAt(Date.now());
    });
}, []);
```

이 부분은 그대로 두고 진입점 코드만 바꿔 가며, StrictMode 없이 응답 1회당 OrderPage의 렌더 횟수를 쟀다.

```
ReactDOM.render(<App />, root)      렌더 3회
createRoot(root).render(<App />)    렌더 1회
```

같은 세 setter를 버튼의 onClick 핸들러 안에서 호출했을 때는 두 방식 모두 렌더가 1회였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5477
(14779, 5477, '추가를 누르는 즉시 hooks가 나타난다. setter를 부르면 넘긴 값과 상관없이 리렌더가 예약되기 때문이다.', 'setter는 새 값을 이전 값과 Object.is로 비교해 다를 때만 리렌더를 예약한다. push는 원래 배열을 고칠 뿐이라 setTags에 넘긴 값은 이전과 같은 참조이고, 같다고 판정돼 갱신이 생략된다.', false),
(14780, 5477, '추가를 눌러도 그대로이고, !를 치면 hooks가 나타난다. 같은 배열이 넘어가 갱신이 생략됐다가 입력 상태가 바뀔 때 다시 그려지기 때문이다.', 'push는 기존 배열을 직접 고치므로 setTags(tags)는 이전과 같은 참조를 넘기고, Object.is 비교에서 같다고 판정돼 리렌더가 생략된다. 이후 setDraft로 다시 렌더되면 이미 hooks가 든 배열을 그린다. 새 배열 [...tags, draft]를 넘겨야 한다.', true),
(14781, 5477, '추가를 눌러도, !를 쳐도 그대로다. push로 고친 배열을 다음 렌더에서 useState가 원래 값으로 되돌려 놓기 때문이다.', 'useState는 저장해 둔 배열을 복사하지 않고 같은 참조를 돌려준다. push가 그 배열 자체를 고쳤으므로 되돌릴 원본이 따로 없고, 다른 이유로 다시 렌더되면 hooks가 든 배열이 그대로 그려진다.', false),
(14782, 5477, '추가를 눌러도 그대로이고, !를 치면 hooks가 나타난다. 배치가 렌더를 다음 이벤트가 들어올 때까지 미뤄 두기 때문이다.', '나타나는 시점은 맞지만 이유가 틀렸다. 배치는 핸들러가 끝나면 모아 둔 갱신을 곧바로 한 번에 렌더할 뿐 다음 이벤트까지 미루지 않는다. 추가 직후 렌더가 없던 것은 같은 참조라 갱신 자체가 생략됐기 때문이다.', false),

-- 문제 5478
(14783, 5478, 'DraftInput을 React.memo로 감싼다.', 'React.memo는 props가 같을 때 호출을 건너뛸 뿐 상태를 버리지 않는다. 상대가 바뀌어도 같은 자리에 같은 타입인 DraftInput이 오므로 인스턴스와 text 상태가 그대로 유지된다.', false),
(14784, 5478, 'DraftInput에 key={Math.random()}을 붙인다.', '상대를 바꿀 때 비워지긴 하지만, 새 메시지가 도착해 ChatRoom이 다시 렌더될 때마다 key가 새 값이 된다. 그때마다 DraftInput이 새로 마운트돼 같은 상대에게 적던 글자도 지워진다.', false),
(14785, 5478, 'to={{ ...contact }}처럼 매번 새 객체를 넘긴다.', 'props가 새 객체여도 엘리먼트의 정체성은 타입과 key로 정해진다. 타입과 key가 그대로면 React는 같은 인스턴스에 새 props만 넘기므로 text 상태는 남는다. props 변경을 새로 마운트되는 것과 혼동한 것.', false),
(14786, 5478, 'DraftInput에 key={contact.id}를 붙인다.', 'key가 달라지면 React는 다른 엘리먼트로 보고 기존 DraftInput을 언마운트한 뒤 새로 마운트해 text가 초기값으로 돌아간다. 같은 상대와 대화하는 동안에는 contact.id가 그대로라 새 메시지로 다시 렌더돼도 상태가 유지된다.', true),

-- 문제 5479
(14787, 5479, '(가), (다)', '(가)는 바깥 타입이 div에서 section으로 바뀌어 안쪽 Editor까지 서브트리 전체가 새로 마운트된다. (다)는 key가 달라져 다른 엘리먼트로 취급된다. (나)는 같은 컴포넌트 타입이라 상태가 유지되고, (라)는 같은 DOM 타입이라 속성만 갱신된다.', true),
(14788, 5479, '(다)', '타입이 다르면 React가 그 아래를 더 비교하지 않고 서브트리를 통째로 교체한다는 점을 놓친 것. (가)에서 Editor 자체는 같아 보여도 부모 타입이 바뀌어 함께 언마운트되고 새로 마운트된다.', false),
(14789, 5479, '(가), (나), (다)', 'props가 바뀌면 새로 마운트된다고 오해한 것. (나)는 같은 자리에 같은 컴포넌트 타입이 와서 인스턴스와 상태를 유지한 채 새 theme 값으로 리렌더만 된다.', false),
(14790, 5479, '(가), (다), (라)', '속성이 바뀌면 DOM 노드를 새로 만든다고 오해한 것. (라)는 같은 DOM 타입이라 React가 노드를 그대로 두고 className만 갱신하므로 적어 둔 글자도 남는다.', false),

-- 문제 5480
(14791, 5480, 'ProductList의 DOM은 실제로 바뀌었지만, React가 가상 DOM에만 반영해 MutationObserver에 잡히지 않았다.', '커밋 단계는 표시된 변경을 실제 DOM에 반영하므로 React의 갱신도 MutationObserver에 그대로 잡힌다. 0건은 비교 결과 목록에 바뀐 자리가 없어 커밋에서 건드린 DOM이 없었다는 뜻이다.', false),
(14792, 5480, 'DOM 변경이 0건이므로 ProductList는 입력마다 드는 비용이 없어 버벅임의 원인에서 뺄 수 있다.', 'DOM을 건드리지 않아도 컴포넌트 함수가 다시 실행되고 상품 500개의 엘리먼트 트리를 새로 만들어 비교하는 비용은 매번 든다. 성능 문제는 DOM 갱신보다 이런 재실행에서 나오는 경우가 많다.', false),
(14793, 5480, 'DOM 변경은 없지만, 글자를 칠 때마다 ProductList의 컴포넌트 함수는 다시 실행되고 있다.', 'Highlight updates는 컴포넌트가 렌더된 것을, MutationObserver는 실제 DOM 변경을 보여 준다. 부모 SearchPage의 상태가 바뀌어 ProductList도 함께 렌더됐지만 새 트리가 이전과 같아 커밋할 변경이 없었다. 리렌더와 DOM 갱신은 별개다.', true),
(14794, 5480, 'props가 이전과 같아 ProductList는 다시 렌더되지 않았고, 테두리는 SearchBox의 갱신이 번져 보인 것이다.', 'props가 같아도 부모가 리렌더되면 자식은 함께 렌더된다. props 비교로 건너뛰는 것은 React.memo로 감쌌을 때뿐인데 ProductList는 감싸지 않았다. 테두리는 ProductList 자신이 렌더됐다는 표시다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1782, 5481, 'React.memo,memo,React.memo(),memo(),리액트 메모,리액트 memo', 'React.memo로 감싼 컴포넌트는 부모가 리렌더될 때 이전 props와 새 props를 얕은 비교해 모두 같으면 호출을 건너뛴다. 원래는 부모 Dashboard가 매초 리렌더되면 props가 그대로여도 자식 SalesChart가 함께 호출돼 1분에 60회가 더해졌다. data는 같은 배열 참조가 유지되므로 감싼 뒤에는 첫 화면 1회만 남았다. 그런데 style={{ height: 300 }}은 렌더마다 새 객체를 만들어 얕은 비교에서 매번 다르다고 판정되고, 그래서 건너뛰기가 다시 깨졌다. style 객체를 컴포넌트 바깥 상수로 빼면 해결된다. 컴포넌트 안에서 계산한 값을 기억하는 useMemo, 함수 참조를 고정하는 useCallback과 달리 React.memo는 컴포넌트 자체를 감싸 호출 여부를 정한다. 또 React.memo는 props 비교로 부모 리렌더에 딸린 호출만 건너뛸 뿐, 자기 상태나 구독한 Context 값이 바뀌면 여전히 리렌더된다.'),
       (1783, 5482, '자동 배치,자동 배칭,자동배치,자동배칭,automatic batching,auto batching,오토매틱 배칭,오토매틱 배치', 'setter 호출은 곧바로 렌더하지 않고 갱신을 예약하며, React는 같은 틱에 쌓인 갱신을 모아 한 번만 렌더한다. React 17 방식의 ReactDOM.render에서는 이 배치가 React 이벤트 핸들러 안에서만 적용돼 onClick에서는 1회였지만, fetch의 then 콜백처럼 핸들러 밖에서 부른 setter는 호출마다 따로 렌더돼 3회가 됐다. React 18의 createRoot는 자동 배치를 적용해 setTimeout·Promise·네이티브 이벤트 콜백 등 어디서 호출하든 한 번의 렌더로 모은다. 배치는 렌더 횟수를 줄일 뿐 예약된 갱신을 버리지 않으므로 세 상태는 모두 반영된다. 반대로 갱신을 모으지 않고 곧바로 렌더와 커밋까지 끝내야 할 때는 flushSync로 감싼다. 이전 값을 받아 쌓는 함수형 갱신(setCount((c) => c + 1))은 계산할 값을 바로잡는 방법일 뿐 렌더 횟수와는 관계가 없다는 점에서도 구분된다.');
