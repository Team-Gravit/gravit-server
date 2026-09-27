-- Unit: ref와 DOM 접근 (Unit ID: 147)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (573, 147, 'useRef 두 용도와 명령형 핸들'),
       (731, 147, '콜백 ref와 최신 값 참조, 측정 시점'),
       (889, 147, 'ref와 DOM 접근 — 렌더 사이 값 보관부터 위젯 컨테이너 분리까지');

-- =====================================================
-- Lesson 573: useRef 두 용도와 명령형 핸들
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3617, 573, '아래 컴포넌트를 마운트한 뒤 버튼을 세 번 클릭했을 때의 결과로 옳은 것은?', '```tsx
function Counter() {
  const [shown, setShown] = useState(0);
  const clickRef = useRef(0);

  function handleClick() {
    clickRef.current += 1;
    console.log(clickRef.current);
  }

  return (
    <>
      <button onClick={handleClick}>click</button>
      <span>{shown}</span>
    </>
  );
}
```

setShown은 이 컴포넌트 어디에서도 호출하지 않는다.', 'OBJECTIVE'),
       (3618, 573, '아래 컴포넌트를 처음 마운트할 때 콘솔에 찍히는 값으로 옳은 것은?', '```tsx
function Panel() {
  const boxRef = useRef<HTMLDivElement>(null);
  console.log("A", boxRef.current);

  useLayoutEffect(() => {
    console.log("B", boxRef.current);
  });

  useEffect(() => {
    console.log("C", boxRef.current);
  });

  return <div ref={boxRef}>panel</div>;
}
```

출력은 A → B → C 순서로 찍힌다.', 'OBJECTIVE'),
       (3619, 573, '아래 표를 바탕으로 명령형 처리와 선언적 처리의 구분에 대해 옳지 않은 것은?', '| 작업 | 상태로 표현할 수 있나 | 처리 방식 |
| --- | --- | --- |
| 입력창 포커스 이동 | 불가 (일회성 동작) | ref + focus() |
| 요소 크기·위치 측정 | 불가 | ref + getBoundingClientRect() (커밋 이후) |
| 지도 위젯 마운트 | 불가 (위젯이 자체 DOM을 관리) | ref로 빈 컨테이너만 넘기고 useEffect에서 초기화·해제 |
| 배지 표시·숨김 | 가능 | state로 조건부 렌더 |', 'OBJECTIVE'),
       (3620, 573, '아래 컴포넌트에서 data prop이 바뀔 때 일어나는 일로 옳은 것은?', '```tsx
function Chart({ data }: { data: number[] }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<ChartInstance | null>(null);

  useEffect(() => {
    chartRef.current = createChart(containerRef.current!);
    return () => {
      chartRef.current?.destroy();
      chartRef.current = null;
    };
  }, []);

  useEffect(() => {
    chartRef.current?.setData(data);
  }, [data]);

  return <div ref={containerRef} />;
}
```

createChart는 넘겨받은 컨테이너 안에 위젯이 스스로 DOM을 그려 넣는다.', 'OBJECTIVE'),
       (3621, 573, '아래 상황에서 자식 컴포넌트가 새로 도입한 React Hook의 이름은?', '영상 카드 컴포넌트에 ref를 넘겨 부모가 재생을 제어한다.

- 처음: 부모가 `cardRef.current.querySelector("video").play()`처럼 자식 내부를 직접 뒤졌다.
- 사고: 자식에서 `<video>`를 `<div>`로 한 겹 감싸자 부모 코드가 한꺼번에 깨졌다.
- 이후: 자식에 Hook 하나를 도입하자 부모가 받은 ref에는 `play`·`pause` 두 함수만 담긴 객체가 들어 있었고, 자식이 내부 마크업을 바꿔도 부모는 손댈 일이 없었다.', 'SUBJECTIVE'),
       (3622, 573, '아래 상황에서 TextField 선언부를 감싼 React API의 이름은?', 'React 18로 만든 사내 폼 라이브러리에서 공용 입력 컴포넌트 `TextField`를 쓴다.

- 폼에서 `<TextField ref={fieldRef} />`로 ref를 넘기고, 제출에 실패하면 `fieldRef.current?.focus()`를 호출하도록 했다.
- 그런데 포커스가 전혀 이동하지 않았고 `fieldRef.current`는 계속 `null`이었다.
- 콘솔에는 `Function components cannot be given refs. Attempts to access this ref will fail.` 경고가 찍혔다.
- `TextField` 선언부를 어떤 React API로 한 번 감싸자 경고가 사라지고 포커스가 정상 동작했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3617
(9819, 3617, '클릭할 때마다 리렌더가 일어나 span에 1, 2, 3이 차례로 표시된다.', 'current 대입은 리렌더를 예약하지 않는다. 화면에 그려지는 값은 shown인데 setShown을 부르지 않았으므로 span은 계속 0이다.', false),
(9820, 3617, '콘솔에는 1, 2, 3이 차례로 찍히지만 span의 값은 0에서 바뀌지 않는다.', 'clickRef.current는 setter를 거치지 않고 즉시 반영돼 1, 2, 3으로 읽힌다. 반면 리렌더가 없어 span에 그려진 shown은 0인 채로 남는다. 값 변경이 화면과 분리되는 것이 ref의 특성이다.', true),
(9821, 3617, 'clickRef가 렌더마다 다시 만들어져 콘솔에 1이 세 번 찍힌다.', 'useRef가 돌려준 객체는 컴포넌트가 살아 있는 동안 같은 참조를 유지한다. 초기값 0은 첫 렌더에만 쓰이고 이후 렌더에서 current가 다시 초기화되지는 않는다.', false),
(9822, 3617, '리렌더가 없어 clickRef.current 갱신도 반영되지 않아 콘솔에 0이 세 번 찍힌다.', '리렌더는 화면을 다시 그리는 일일 뿐 current 대입의 조건이 아니다. state와 달리 ref는 다음 렌더를 기다리지 않고 대입 직후 줄에서 바로 새 값을 읽는다.', false),

-- 문제 3618
(9823, 3618, 'A와 B에서는 null이 찍히고 C에서만 div 노드가 찍힌다.', 'useLayoutEffect는 커밋이 끝난 뒤 페인트 직전에 실행되므로 그 시점에 ref는 이미 연결돼 있다. useEffect에서만 DOM에 닿는다고 본 오해다.', false),
(9824, 3618, 'A, B, C 모두 div 노드가 찍힌다.', '렌더 단계는 화면에 무엇을 그릴지 계산하는 단계라 아직 DOM 노드가 없다. JSX에 ref를 적는 순간 노드가 존재한다고 본 오해로, A 시점의 current는 null이다.', false),
(9825, 3618, 'A는 null, B에서는 div 노드가 찍히고 C에서는 다시 null이 된다.', 'ref가 null로 돌아가는 시점은 노드가 화면에서 빠질 때(언마운트·조건부 해제)다. 브라우저 페인트가 끝났다고 연결이 풀리지는 않는다.', false),
(9826, 3618, 'A는 null이고 B와 C에서는 div 노드가 찍힌다.', 'ref는 커밋으로 DOM이 반영된 직후, useLayoutEffect 실행 직전에 연결된다. 그래서 렌더 본문인 A에서는 null이고, 커밋 이후에 도는 B와 C에서는 실제 노드를 읽는다.', true),

-- 문제 3619
(9827, 3619, '포커스 이동은 그 순간 한 번 일어나는 동작이라 화면 상태 값으로 나타내기 어렵다.', '상태는 지금 화면이 어떤 모습인지를 담는 값이다. 포커스를 옮기는 행위는 지속되는 모습이 아니라 순간의 동작이라 표에서도 상태로 표현 불가로 분류된다.', false),
(9828, 3619, '요소 크기 측정은 DOM이 반영된 뒤에 해야 하므로 렌더 함수 본문에서는 값을 얻을 수 없다.', '표가 측정을 커밋 이후로 적어 둔 이유다. 렌더 단계에서는 ref.current가 null이라 getBoundingClientRect를 호출할 대상 자체가 없다.', false),
(9829, 3619, '배지의 표시·숨김은 리렌더를 줄이기 위해 ref로 클래스를 직접 토글하는 편이 낫다.', '표에서 배지는 상태로 표현 가능한 작업으로 분류된다. React가 관리하는 노드를 ref로 바꾸면 다음 렌더에서 덮어써지고 상태와 화면이 어긋나므로, 리렌더를 아끼려는 시도가 오히려 버그가 된다.', true),
(9830, 3619, '지도 위젯은 자체 DOM을 관리하므로 React가 자식을 렌더하는 노드에 붙이면 충돌할 수 있다.', '표가 빈 컨테이너만 넘기라고 한 이유다. React가 재조정으로 자기 자식을 지우려 할 때 위젯이 만들어 둔 노드와 어긋나 removeChild 실패 같은 오류가 난다.', false),

-- 문제 3620
(9831, 3620, '기존 위젯 인스턴스는 그대로 두고 setData만 호출되어, 차트는 언마운트 전까지 한 번만 만들어진다.', '생성·해제 이펙트는 의존성 배열이 비어 있어 마운트와 언마운트에만 돈다. data가 바뀌면 의존성이 [data]인 두 번째 이펙트만 다시 실행돼 위젯에 새 값을 넘긴다.', true),
(9832, 3620, 'createChart와 destroy가 다시 실행되어 차트 인스턴스가 매번 새로 만들어진다.', '생성 이펙트의 의존성에 data가 없어 재실행되지 않는다. 두 이펙트를 하나로 합쳤을 때의 동작을 갖다 붙인 오해로, 실제로 합치면 값이 바뀔 때마다 위젯이 재생성된다.', false),
(9833, 3620, 'chartRef.current가 갱신되면서 리렌더가 일어나 컨테이너 div가 새 노드로 교체된다.', 'ref.current 대입은 리렌더를 예약하지 않는다. 또 리렌더가 일어나더라도 같은 자리의 같은 타입 요소는 재사용되므로 div가 통째로 교체되지도 않는다.', false),
(9834, 3620, 'React가 컨테이너 div의 자식을 다시 그리면서 위젯이 만든 노드를 지운다.', '이 div에는 JSX 자식이 없어 React가 그 안을 관리하지 않는다. 위젯 전용 빈 컨테이너를 쓰는 이유가 바로 이 충돌을 피하기 위해서다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1162, 3621, 'useImperativeHandle,use imperative handle,유즈임페러티브핸들,유즈 임페러티브 핸들', '부모에게 DOM 노드를 통째로 넘기면 부모가 자식의 내부 구조에 의존하게 되어, 자식이 마크업을 한 겹만 바꿔도 부모가 깨진다. useImperativeHandle(ref, () => ({ play, pause }), [])처럼 ref에 담길 값을 자식이 직접 정하면 부모는 약속된 명령 몇 개만 쓰게 되어 캡슐화가 유지된다. forwardRef와 헷갈리기 쉬운데, forwardRef는 부모의 ref를 자식까지 전달하는 통로를 여는 쪽이고 useImperativeHandle은 그 통로에 무엇을 담을지 고르는 쪽이다. 다만 남용하면 데이터 흐름이 불투명해지므로 포커스·재생·스크롤처럼 props로 표현할 수 없는 명령에 한정한다.'),
       (1163, 3622, 'forwardRef,React.forwardRef,forward ref,포워드레프,포워드 레프', 'React 18까지 함수 컴포넌트는 ref를 일반 prop으로 받지 못한다. 그래서 부모가 넘긴 ref는 컴포넌트 함수에 도달하지 못하고 경고만 남으며 current는 null에 머문다. forwardRef로 감싸면 컴포넌트 함수가 props와 ref 두 인자를 받게 되어 그 ref를 내부 input에 연결할 수 있다. useImperativeHandle과는 역할이 다르다. forwardRef는 ref가 자식까지 내려가는 통로를 여는 쪽이고, useImperativeHandle은 그 통로에 담길 값을 고르는 쪽이다. React 19부터는 ref가 일반 prop으로 전달되므로 function TextField({ ref, ...props })처럼 받으면 되고 forwardRef는 필요 없다.');

-- =====================================================
-- Lesson 731: 콜백 ref와 최신 값 참조, 측정 시점
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4565, 731, '아래 코드에서 입력창에 글자를 입력한 뒤 새 메시지가 도착했을 때의 동작으로 옳은 것은?', '```tsx
function ChatRoom({ roomId, onMessage }: ChatRoomProps) {
  const onMessageRef = useRef(onMessage);

  useEffect(() => {
    onMessageRef.current = onMessage;
  });

  useEffect(() => {
    const socket = connect(roomId);
    socket.on("message", (m: string) => onMessageRef.current(m));
    return () => socket.close();
  }, [roomId]);

  return null;
}

function Page() {
  const [keyword, setKeyword] = useState("");

  return (
    <>
      <input value={keyword} onChange={(e) => setKeyword(e.target.value)} />
      <ChatRoom
        roomId="general"
        onMessage={(m) => {
          if (m.includes(keyword)) notify(m);
        }}
      />
    </>
  );
}
```

- `connect`는 해당 방에 소켓을 연결해 돌려주고, `notify`는 화면에 알림을 띄운다.
- 마운트 후 입력창에 `ref`를 한 글자씩 입력했고, 그다음 새 메시지 여러 개가 도착했다.', 'OBJECTIVE'),
       (4566, 731, '아래 코드에서 마운트 후 검색 버튼을 눌렀을 때의 결과로 옳은 것은?', '```jsx
function SearchInput({ ref }) {
  const inputRef = useRef(null);

  useImperativeHandle(ref, () => ({
    focus: () => inputRef.current?.focus(),
    clear: () => {
      inputRef.current.value = "";
    },
  }), []);

  return <input ref={inputRef} defaultValue="react ref" />;
}

function Header() {
  const searchRef = useRef(null);

  function handleClick() {
    searchRef.current.focus();
    console.log(searchRef.current instanceof HTMLInputElement);
    searchRef.current.select();
  }

  return (
    <>
      <SearchInput ref={searchRef} />
      <button onClick={handleClick}>검색</button>
    </>
  );
}
```

앱은 React 19에서 실행한다.', 'OBJECTIVE'),
       (4567, 731, '아래 PR에 대한 검토 의견으로 옳은 것은?', '사내 UI 패키지 `@acme/ui`의 입력 컴포넌트를 정리하는 PR이 올라왔다.

- 기존 코드: `TextField`를 `forwardRef`로 감싸 부모가 넘긴 ref를 내부 `<input>`에 연결했다.
- PR 내용: React 19 문서를 참고해 `forwardRef`를 모두 걷어내고 `function TextField({ ref, ...props })` 형태로 바꿨다. 받은 `ref`는 그대로 `<input ref={ref} {...props} />`에 넘긴다.
- 사용처: React 19로 올린 서비스 A와 아직 React 18에 머문 서비스 B가 이 패키지를 함께 쓴다. 두 서비스 모두 `<TextField ref={fieldRef} />`로 ref를 넘기고, 제출에 실패하면 `fieldRef.current?.focus()`로 입력창에 포커스를 옮긴다.', 'OBJECTIVE'),
       (4568, 731, '아래 컴포넌트에서 3단계의 강조 표시가 사라진 원인으로 옳은 것은?', '```tsx
function Card({ title }: { title: string }) {
  const [dark, setDark] = useState(false);
  const [likes, setLikes] = useState(0);
  const cardRef = useRef<HTMLDivElement>(null);

  return (
    <div ref={cardRef} className={dark ? "card dark" : "card"}>
      <h3 onClick={() => cardRef.current?.classList.toggle("selected")}>{title}</h3>
      <button onClick={() => setLikes((n) => n + 1)}>좋아요 {likes}</button>
      <button onClick={() => setDark((d) => !d)}>테마</button>
    </div>
  );
}
```

1. 제목을 클릭하자 카드에 `selected` 강조 표시가 생겼다.
2. 좋아요 버튼을 눌러 숫자가 1로 바뀌었고, 강조 표시는 그대로 남아 있었다.
3. 테마 버튼을 누르자 카드가 어두워지면서 강조 표시가 사라졌다.', 'OBJECTIVE'),
       (4569, 731, '아래 상황의 시도 2에서 적용한 ref 사용 방식의 이름은?', '채팅 화면에 "답장 원문으로 이동" 기능을 넣는다. 메시지 목록은 대화가 오갈수록 길어지고, 삭제하면 짧아진다.

- 시도 1: 메시지마다 ref 객체를 두려고 컴포넌트 본문에서 `messages.map(() => useRef(null))`을 호출했다. 새 메시지가 도착하는 순간 `Rendered more hooks than during the previous render.` 오류로 화면이 멈췄다.
- 시도 2: Hook 호출은 최상단의 `const nodes = useRef(new Map())` 하나만 남기고, 각 `<li>`의 `ref` 속성에 넘기는 값의 형태를 바꿨다.
- 결과: 메시지가 몇 개로 늘어도 오류가 없었고, `nodes.current.get(id)?.scrollIntoView()`로 원문까지 스크롤됐다. 메시지를 삭제하면 그 id의 항목도 Map에서 빠져 있었다.', 'SUBJECTIVE'),
       (4570, 731, '아래 상황에서 조치로 바꿔 쓴 React Hook의 이름은?', '상품 카드에 도움말 툴팁을 붙였다. 툴팁은 먼저 카드 맨 위(`top: 0`)에 렌더되고, `useEffect` 안에서 `tooltipRef.current.getBoundingClientRect()`로 자기 높이를 잰 뒤 위치 state를 바꿔 버튼 바로 위로 옮겨 간다.

- 증상: 툴팁을 열 때마다 카드 맨 위에 한순간 번쩍 나타났다가 버튼 위로 튀었다. 저사양 기기일수록 더 또렷하게 보였다.
- 조치: 측정·위치 계산 코드는 한 줄도 바꾸지 않고, 그 코드를 감싼 Hook만 `useEffect`에서 다른 Hook으로 바꿨다.
- 결과: 번쩍임이 사라졌고, 사용자는 처음부터 버튼 위에 뜬 툴팁만 보게 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4565
(12347, 4565, '글자를 입력할 때마다 소켓이 닫혔다가 다시 연결되고, 새 메시지는 ref가 들어간 것만 알림으로 뜬다.', '연결 이펙트의 의존성은 [roomId]뿐이다. Page가 리렌더할 때마다 onMessage는 새 함수가 되지만 roomId는 그대로라 이 이펙트는 다시 실행되지 않는다. onMessage를 의존성에 넣었을 때의 동작과 혼동한 것이다.', false),
(12348, 4565, '소켓은 마운트 때 한 번만 연결된 채 유지되고, 새 메시지는 ref가 들어간 것만 알림으로 뜬다.', '의존성 배열이 없는 첫 이펙트가 렌더마다 onMessageRef.current를 최신 onMessage로 바꾼다. 리스너는 호출될 때 current를 읽으므로 재연결 없이 최신 keyword로 거른다. 이것이 latest ref 패턴이다.', true),
(12349, 4565, '소켓은 마운트 때 한 번만 연결되지만, 콜백이 첫 렌더의 빈 keyword를 읽어 모든 메시지가 알림으로 뜬다.', '리스너가 onMessage를 직접 캡처했다면 나올 결과(stale closure)다. 여기서 리스너는 호출될 때마다 같은 ref 객체의 current를 읽고, 그 값은 렌더마다 최신 콜백으로 교체된다.', false),
(12350, 4565, '소켓은 마운트 때 한 번만 연결되지만, current에 새 함수를 대입하는 순간 리스너가 끊겨 알림이 뜨지 않는다.', '리스너가 붙잡은 것은 onMessageRef 객체이지 current 값의 복사본이 아니다. current를 바꿔도 객체 참조는 그대로라, 다음 메시지가 오면 새로 대입된 함수가 불린다.', false),

-- 문제 4566
(12351, 4566, '입력창으로 포커스가 옮겨지고 콘솔에 true가 찍힌 뒤, 입력창의 텍스트가 선택된다.', '부모의 ref에 담기는 것은 useImperativeHandle의 두 번째 인자가 돌려준 객체다. 내부 input 노드가 그대로 부모에게 간다고 본 오해로, 이 객체는 DOM 요소가 아니어서 instanceof 결과도 false다.', false),
(12352, 4566, '첫 줄에서 searchRef.current가 null이라 TypeError가 나고, 이어지는 두 줄은 실행되지 않는다.', 'React 19에서는 ref가 일반 prop으로 전달되고, 핸들은 커밋 과정에서 연결돼 마운트 후 이벤트 핸들러에서는 이미 채워져 있다. 함수 컴포넌트는 ref를 받지 못한다는 React 18 이하 규칙을 적용한 오해다.', false),
(12353, 4566, '입력창으로 포커스가 옮겨지고 콘솔에 false가 찍힌 뒤, select가 내부 input으로 넘어가 텍스트가 선택된다.', '핸들은 DOM 메서드를 알아서 넘겨주는 대리 객체가 아니다. 직접 정의한 focus·clear만 존재하므로, 정의하지 않은 select는 내부 input으로 이어지지 않는다.', false),
(12354, 4566, '입력창으로 포커스가 옮겨지고 콘솔에 false가 찍힌 뒤, select 호출에서 함수가 아니라는 TypeError가 난다.', 'searchRef.current에는 focus·clear만 가진 객체가 담긴다. focus는 내부 input에 위임돼 동작하지만 select는 없어 undefined를 호출하다 오류가 난다. 노출할 명령만 골라 내부 DOM을 감추는 설계다.', true),

-- 문제 4567
(12355, 4567, '서비스 B에서는 ref가 TextField 함수까지 전달되지 않아, fieldRef.current가 null에 머물고 포커스가 옮겨지지 않는다.', 'React 18까지 ref는 key처럼 React가 따로 떼어 가는 속성이라 props에 들어오지 않는다. 구조 분해한 ref는 undefined가 되어 input에 연결되지 않는다. 두 버전을 함께 지원하는 동안은 forwardRef를 유지해야 한다.', true),
(12356, 4567, 'React 19에서 forwardRef는 이미 삭제된 API라, PR 이전 코드는 서비스 A에서 실행 오류를 낸다.', 'React 19에서도 forwardRef는 그대로 동작하고, 필요 없어져 향후 제거가 예고됐을 뿐이다. 그래서 여러 React 버전을 지원해야 하는 패키지는 당분간 forwardRef를 유지하는 쪽을 택한다.', false),
(12357, 4567, 'ref도 결국 props 객체에 담겨 전달되므로, 서비스 A와 B 모두에서 fieldRef가 내부 input에 연결된다.', 'ref를 일반 prop처럼 받는 것은 React 19에서 바뀐 동작이다. React 18에서는 props에서 ref가 빠지고 Function components cannot be given refs 경고만 남는다. 두 버전의 차이를 지운 오해다.', false),
(12358, 4567, '서비스 A에서는 fieldRef.current에 내부 input 대신 TextField 컴포넌트 자체가 담겨 focus를 부를 수 없다.', '함수 컴포넌트에는 ref로 가리킬 인스턴스가 없다. React 19에서는 받은 ref를 input에 그대로 넘기므로 input 노드가 담기고 focus가 동작한다. 클래스 컴포넌트에서 ref가 인스턴스를 가리키던 동작을 섞은 오해다.', false),

-- 문제 4568
(12359, 4568, '테마 state가 바뀌면 Card가 새로 마운트되어, cardRef가 강조 표시가 없는 새 div 노드를 가리키게 된다.', 'state 변경은 같은 컴포넌트를 다시 렌더할 뿐 새로 마운트하지 않는다. 같은 자리의 같은 div는 재사용되고 cardRef도 같은 노드를 가리킨다. 리렌더를 리마운트로 착각한 오해다.', false),
(12360, 4568, 'setDark 호출이 cardRef.current를 null로 비웠다가 다시 채우면서, classList로 바꾼 내용이 되돌려진다.', 'ref 객체는 컴포넌트가 살아 있는 동안 유지되고 state 변경으로 비워지지 않는다. 또 classList 변경은 DOM 노드 자체에 남는 것이라 ref가 무엇을 가리키는지와 무관하다.', false),
(12361, 4568, 'React가 바뀐 className 값으로 class 속성을 다시 쓰면서, JSX에 없는 selected가 함께 지워진다.', 'React는 이전 렌더와 달라진 속성만 DOM에 반영한다. 2단계에선 className이 그대로라 손대지 않았고, 3단계에선 값이 바뀌어 class 속성을 새 값으로 통째로 썼다. 화면에 보이는 강조는 state로 표현해야 한다.', true),
(12362, 4568, 'ref로 바꾼 DOM은 다음 리렌더에서 무조건 원래대로 돌아가므로, 2단계의 좋아요 클릭은 리렌더를 일으키지 않았다.', 'setLikes로 숫자가 1로 바뀌어 보였으니 리렌더는 일어났다. 그런데도 강조가 남은 것은 React가 렌더마다 DOM을 통째로 다시 쓰지 않고, 달라진 속성만 고치기 때문이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1478, 4569, '콜백 ref,콜백ref,콜백 레프,콜백레프,callback ref,callbackref,callback refs,ref callback,ref 콜백,ref콜백,ref 콜백 함수,레프 콜백,콜백 참조', 'ref 속성에 ref 객체 대신 함수를 넘기는 방식이 콜백 ref다. React는 노드가 연결될 때 그 노드를 인자로 함수를 부르고, 해제될 때는 null로 다시 부른다(React 19부터는 함수가 클린업 함수를 반환하면 null 호출 대신 그 클린업이 실행된다). 그래서 `ref={(node) => { if (node) nodes.current.set(id, node); else nodes.current.delete(id); }}`처럼 쓰면 Hook 개수를 늘리지 않고도 길이가 바뀌는 목록의 노드를 id별로 모으고 치울 수 있다. 시도 1은 반복문 안에서 Hook을 불러 렌더마다 Hook 개수가 달라졌기 때문에 오류가 났다. forwardRef·useImperativeHandle은 부모와 자식 사이에서 ref를 전달하거나 노출 범위를 좁히는 API로, 한 컴포넌트 안에서 여러 노드를 모으는 콜백 ref와는 목적이 다르다.'),
       (1479, 4570, 'useLayoutEffect,use layout effect,React.useLayoutEffect,유즈레이아웃이펙트,유즈 레이아웃 이펙트,레이아웃 이펙트,layout effect', 'useEffect는 브라우저가 화면을 그린(페인트) 뒤에 실행된다. 그래서 측정 전의 top: 0 상태가 한 번 그려졌다가, 위치 state 변경으로 다시 그려지면서 번쩍임이 보였다. useLayoutEffect는 커밋으로 DOM이 반영되고 ref가 연결된 직후, 페인트 전에 동기적으로 실행된다. 이 안에서 getBoundingClientRect로 측정하고 state를 바꾸면 React가 페인트 전에 다시 렌더하므로 사용자는 최종 위치만 보게 된다. 대신 이 안의 작업은 페인트를 막아 길어지면 화면이 늦게 뜨므로, 측정·위치 보정처럼 화면에 보이기 전에 끝나야 하는 일에만 쓴다. 렌더 함수 본문에서 바로 재려 하면 ref.current가 아직 null이라 측정 자체가 안 된다는 점과도 구분한다.');

-- =====================================================
-- Lesson 889: ref와 DOM 접근 — 렌더 사이 값 보관부터 위젯 컨테이너 분리까지
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5513, 889, '아래 컴포넌트에서 3초 뒤 콘솔에 찍히는 내용으로 옳은 것은?', '```tsx
function Composer() {
  const [text, setText] = useState("");
  const textRef = useRef("");

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    setText(e.target.value);
    textRef.current = e.target.value;
  }

  function handleSend() {
    setTimeout(() => {
      console.log("state:", text, "/ ref:", textRef.current);
    }, 3000);
  }

  return (
    <>
      <input value={text} onChange={handleChange} />
      <button onClick={handleSend}>전송</button>
    </>
  );
}
```

- 마운트 후 입력창에 `hi`를 입력하고 전송 버튼을 눌렀다.
- 3초가 지나기 전에 `!`를 더 입력해 입력창이 `hi!`가 되었다.', 'OBJECTIVE'),
       (5514, 889, '아래 컴포넌트를 마운트한 뒤 검색 열기 버튼을 두 번 연달아 눌렀을 때의 결과로 옳은 것은?', '```tsx
function SearchBar() {
  const [open, setOpen] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  function handleOpen() {
    setOpen(true);
    inputRef.current?.focus();
  }

  return (
    <>
      <button onClick={handleOpen}>검색 열기</button>
      {open && <input ref={inputRef} placeholder="검색어" />}
    </>
  );
}
```

두 번째 클릭은 첫 클릭으로 생긴 화면 갱신이 모두 끝난 뒤에 일어났다.', 'OBJECTIVE'),
       (5515, 889, '아래 컴포넌트에서 발생한 오류를 없애는 수정으로 옳은 것은?', '```tsx
function StoreMap({ stores }: { stores: Store[] }) {
  const boxRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const map = createMap(boxRef.current!);
    return () => map.destroy();
  }, []);

  return (
    <div ref={boxRef} className="map">
      {stores.length === 0 && <p>표시할 매장이 없습니다</p>}
    </div>
  );
}
```

- `createMap`은 넘겨받은 요소의 기존 내용을 모두 비운 뒤, 그 안에 지도용 노드를 직접 그려 넣는다.
- 처음에는 `stores`가 빈 배열이었다. 잠시 뒤 매장 목록이 도착하자 화면이 깨지며 콘솔에 아래 오류가 찍혔다.

```
NotFoundError: Failed to execute ''removeChild'' on ''Node'': The node to be removed is not a child of this node.
```', 'OBJECTIVE'),
       (5516, 889, '아래 설명에 해당하는 React의 ref 사용 방식에 대한 설명으로 옳은 것은?', 'JSX의 `ref` 속성에 ref 객체 대신 함수를 넘기는 방식이다. React는 해당 DOM 노드가 화면에 붙는 순간 그 노드를 인자로 이 함수를 호출한다. 그래서 요소가 나타나는 시점을 잡거나, 개수가 바뀌는 목록의 노드를 id별로 Map에 모을 때 쓴다.', 'OBJECTIVE'),
       (5517, 889, '아래 상황에서 3차 시도에 쓴 React Hook의 이름은?', '스톱워치 컴포넌트에서 경과 시간은 `elapsed` state로 화면에 표시하고, 시작 버튼을 누르면 `setInterval`로 1초마다 1씩 늘린다. 인터벌이 돌려준 id를 어디에 보관할지 세 번 바꿔 봤다.

- 1차: id를 `useState`에 넣었다. 동작은 맞았지만, 시작·정지 버튼을 누를 때마다 화면에 보이는 값은 그대로인데도 리렌더가 한 번씩 일어났다.
- 2차: 컴포넌트 함수 안의 `let` 변수에 넣었다. 그 리렌더는 사라졌지만, 시작 후 경과 시간이 한 번이라도 갱신되고 나면 정지 버튼을 눌러도 숫자가 계속 올라갔다.
- 3차: id 보관을 다른 Hook 하나로 바꾸자, 불필요한 리렌더 없이 정지도 언제나 정상 동작했다.', 'SUBJECTIVE'),
       (5518, 889, '아래 상황에서 main.tsx에서 지운 컴포넌트의 이름은?', '게시판 컴포넌트가 몇 번 렌더되는지 보려고 컴포넌트 본문에 아래 코드를 넣고, `renderCount.current` 값을 화면 구석에 표시했다.

```tsx
const renderCount = useRef(0);
renderCount.current += 1;
```

- 개발 서버에서는 좋아요 버튼을 한 번 누를 때마다 표시된 값이 2씩 올랐다.
- 같은 코드를 배포 빌드로 띄우자 1씩 올랐다.
- `main.tsx`에서 `<App />`을 감싸던 React 내장 컴포넌트 하나를 지우자, 개발 서버에서도 1씩 오르게 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5513
(14875, 5513, 'state: hi / ref: hi', 'ref는 콜백이 값을 복사해 두는 대상이 아니라 모든 렌더가 함께 쓰는 한 객체다. 콜백은 3초 뒤 실행되는 순간 current를 읽으므로 그 사이 입력한 !까지 반영된 값을 얻는다. ref도 클릭 시점에 고정된다고 본 오해다.', false),
(14876, 5513, 'state: hi! / ref: hi!', 'state는 렌더마다 고정된 스냅샷이다. 전송을 누른 렌더의 handleSend는 text가 hi인 렌더에서 만들어졌고, 이후 리렌더가 일어나도 이미 예약된 콜백이 붙잡은 text는 바뀌지 않는다.', false),
(14877, 5513, 'state: hi / ref: hi!', 'setTimeout 콜백은 전송을 누른 렌더의 text(hi)를 붙잡는다. 반면 textRef는 렌더가 바뀌어도 같은 객체라 3초 뒤 읽는 순간의 최신 값(hi!)이 나온다. 렌더의 스냅샷을 읽는 state와 항상 최신 current를 읽는 ref의 차이다.', true),
(14878, 5513, 'state: (빈 문자열) / ref: hi!', 'handleSend는 렌더마다 새로 만들어지므로 첫 렌더의 빈 문자열이 아니라 클릭한 렌더의 text를 읽는다. 의존성 배열이 빈 이펙트처럼 함수가 마운트 때 한 번만 만들어진다고 본 오해다.', false),

-- 문제 5514
(14879, 5514, '첫 클릭에 입력창이 나타나며 바로 포커스가 들어가고, 두 번째 클릭도 같다.', 'setOpen은 다음 렌더를 예약할 뿐 그 자리에서 DOM을 바꾸지 않는다. 핸들러가 끝나고 커밋돼야 input이 생기고 ref가 연결되므로, 첫 클릭의 focus 줄에서는 current가 아직 null이다.', false),
(14880, 5514, '첫 클릭에는 입력창만 나타나고 포커스는 없으며, 두 번째 클릭에 포커스가 들어간다.', '첫 클릭의 focus 줄은 커밋 전이라 current가 null이고, ?.가 호출을 건너뛰어 오류 없이 끝난다. 커밋 때 ref에 input이 연결되므로 두 번째 클릭에서는 current가 노드를 가리켜 포커스가 들어간다.', true),
(14881, 5514, '첫 클릭에 TypeError가 나서 입력창이 나타나지 않고, 두 번째 클릭에 입력창이 나타난다.', '?.는 앞의 값이 null이면 호출을 건너뛸 뿐 오류를 던지지 않는다. 첫 클릭의 렌더 예약도 그대로 처리돼 입력창은 첫 클릭에 나타난다. ?. 없이 점(.)으로 호출했다면 null에서 focus를 읽다가 TypeError가 났을 것이다.', false),
(14882, 5514, '첫 클릭에는 입력창만 나타나고, 두 번째 클릭에도 ref가 null로 남아 포커스가 들어가지 않는다.', 'ref 객체는 계속 같은 객체이고, current는 커밋 때마다 React가 채운다. 조건부 요소가 나타나면 그 노드가 current에 연결되므로 두 번째 클릭에서는 input을 가리킨다. 첫 렌더의 null에 고정된다고 본 오해다.', false),

-- 문제 5515
(14883, 5515, 'createMap 호출을 useLayoutEffect로 옮겨, 브라우저가 화면을 그리기 전에 지도를 만든다.', '실행 시점만 페인트 전으로 당겨질 뿐 createMap이 <p>를 지워 버리는 것은 그대로다. React와 위젯이 같은 div의 자식을 함께 다루는 한, 목록이 도착했을 때 React는 이미 사라진 <p>를 지우려다 같은 오류를 낸다.', false),
(14884, 5515, '의존성 배열에 stores를 넣어, 목록이 바뀔 때마다 지도를 지우고 새로 만들게 한다.', '커밋에서는 DOM 변경이 먼저 반영되고 이펙트의 클린업·재실행은 그 뒤에 온다. React는 지도를 다시 만들기 전에 이미 사라진 <p>를 지우려다 같은 오류를 낸다. 목록이 바뀔 때마다 위젯을 재생성하는 비용도 붙는다.', false),
(14885, 5515, '안내 문구 <p>에 key를 붙여, React가 지워야 할 노드를 정확히 찾게 한다.', 'key는 형제 요소 사이에서 어느 것이 어느 것인지 가려 주는 표시일 뿐이다. React는 key와 무관하게 자신이 만든 <p> 노드를 div에서 떼려 하고, 그 노드는 이미 위젯이 치운 뒤라 오류가 그대로 난다.', false),
(14886, 5515, '안내 문구를 지도 div 바깥의 형제 요소로 옮기고, ref를 단 div에는 JSX 자식을 두지 않는다.', '원인은 위젯과 React가 한 노드의 자식을 함께 관리한 것이다. React가 자식을 렌더하지 않는 빈 컨테이너만 위젯에 넘기고 안내 문구는 바깥에서 렌더하면, React가 지우려는 노드를 위젯이 먼저 치우는 일이 생기지 않는다.', true),

-- 문제 5516
(14887, 5516, '노드가 떨어질 때도 null로 다시 불리며, React 19에서는 반환한 클린업 함수가 이를 대신할 수 있다.', '연결뿐 아니라 해제 때도 같은 함수가 불려, Map에 넣은 노드를 그때 지울 수 있다. React 19부터는 이 함수가 클린업 함수를 반환하면 해제 시 null 호출 대신 그 클린업이 실행된다. 연결과 해제를 한 함수에서 짝지어 다루는 방식이다.', true),
(14888, 5516, '부모에게 넘길 값을 play·pause 같은 함수 몇 개로 좁혀, 부모가 자식의 내부 마크업에 기대지 않게 한다.', 'ref에 담길 값을 자식이 직접 골라 노출하는 것은 useImperativeHandle의 특징이다. 본문의 방식은 DOM 노드가 붙고 떨어지는 순간을 함수로 받는 것이지, 부모에게 보일 API를 제한하는 장치가 아니다.', false),
(14889, 5516, 'React 18 이하에서 함수 컴포넌트가 부모가 넘긴 ref를 두 번째 인자로 받을 수 있게 해 준다.', '함수 컴포넌트가 (props, ref) 두 인자를 받게 해 ref를 내부 요소까지 전달하는 것은 forwardRef의 역할이다. 본문의 방식은 ref를 전달하는 통로가 아니라 노드가 연결될 때 불리는 함수다.', false),
(14890, 5516, 'current 속성에 값을 담아 두고, 그 값을 바꿔도 리렌더 없이 컴포넌트가 살아 있는 동안 유지한다.', 'current를 가진 객체를 렌더 사이에 유지하는 것은 useRef가 돌려주는 ref 객체의 특징이다. 본문의 방식은 ref 속성에 객체 대신 함수를 넘기므로 current 속성이 없고, 노드는 함수의 인자로 전달된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1794, 5517, 'useRef,use ref,React.useRef,useRef(),유즈레프,유즈 레프,유즈ref,유즈 ref', 'useRef가 돌려주는 ref 객체는 컴포넌트가 살아 있는 동안 같은 객체로 유지되고, current를 바꿔도 리렌더를 일으키지 않는다. 1차의 useState는 값이 렌더 사이에 유지되지만 setter를 부를 때마다 리렌더가 따라와, 화면에 보이지도 않는 id 때문에 렌더가 늘었다. 2차의 let 변수는 리렌더 없이 바꿀 수 있지만 렌더마다 새로 만들어진다. 1초 뒤 elapsed가 바뀌어 리렌더되면 새 렌더의 정지 핸들러는 값이 비어 있는 변수를 보게 되어 clearInterval에 undefined를 넘기고, 타이머는 계속 돈다. 렌더 사이 유지와 리렌더 없음을 모두 만족하는 것이 useRef다. 화면에 보여야 하는 경과 시간은 state에, 화면과 무관한 타이머 id·위젯 인스턴스는 ref에 두고, current는 렌더 중이 아니라 이벤트 핸들러나 이펙트 안에서만 다룬다.'),
       (1795, 5518, 'StrictMode,React.StrictMode,Strict Mode,<StrictMode>,<React.StrictMode>,스트릭트 모드,스트릭트모드,엄격 모드,엄격모드', 'StrictMode는 개발 모드에서만 컴포넌트 함수를 한 번 더 호출해, 렌더 중에 바깥 값을 바꾸는 코드를 드러낸다. 렌더 본문의 renderCount.current += 1은 이 두 번의 호출에서 같은 ref 객체를 두 번 바꾸므로 한 번의 갱신에 값이 2씩 올랐다. 배포 빌드에는 이 검사가 없어 1씩 올랐지만, 동시성 렌더링에서는 React가 계산하다 버린 렌더도 ref를 바꿀 수 있어 여전히 믿을 수 없는 값이다. 그래서 ref는 렌더 중에 읽거나 쓰지 않고(초기화 예외) 이벤트 핸들러나 이펙트 안에서만 다룬다. StrictMode를 지워 증상이 사라진 것은 문제를 가린 것일 뿐 고친 것이 아니다. 렌더 시간을 재는 Profiler처럼 <App />을 감싸는 다른 내장 컴포넌트는 렌더를 두 번 호출하지 않는다는 점에서 구분된다.');
