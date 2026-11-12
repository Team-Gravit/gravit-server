-- Unit: 에러 경계와 예외 처리 (Unit ID: 149)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (575, 149, '포착 범위와 경계 배치, key 재시도'),
       (733, 149, '비동기 에러 전달과 루트 에러 콜백'),
       (891, 149, 'React 에러 경계의 역할 분담·배치·복구와 비동기 에러 위임');

-- =====================================================
-- Lesson 575: 포착 범위와 경계 배치, key 재시도
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3629, 575, '아래 React 예외 처리 장치에 대한 설명으로 옳은 것은?', 'React에서는 하위 트리에서 던져진 렌더 에러를 잡아 준비해 둔 fallback UI를 대신 보여주는 컴포넌트를 둘 수 있다. try/catch의 컴포넌트 버전에 해당하며, 훅 버전이 없어 클래스 컴포넌트로만 작성할 수 있다.', 'OBJECTIVE'),
       (3630, 575, '아래 컴포넌트에서 표시된 네 지점 중, 상위 에러 경계가 잡아 fallback으로 이어지는 에러는?', '```tsx
function Panel({ id }) {
  const [rows, setRows] = useState([]);

  useEffect(() => {
    fetch("/api/rows/" + id)
      .then((r) => r.json())
      .then(() => { throw new Error("A"); });        // (A)

    setTimeout(() => { throw new Error("B"); }, 0);  // (B)

    if (id < 0) throw new Error("C");                // (C)
  }, [id]);

  return (
    // (D)
    <button onClick={() => { throw new Error("D"); }}>{rows.length}건</button>
  );
}
```

Panel은 에러 경계 안쪽에 놓여 있고, 네 지점의 에러는 모두 실제로 발생한다.', 'OBJECTIVE'),
       (3631, 575, '아래 배치표를 바탕으로 옳지 않은 것은?', '한 대시보드 앱에서 에러 경계를 어디에 두느냐에 따라 화면이 사라지는 범위가 달라진다.

| 경계를 두는 위치 | 에러가 났을 때 사라지는 범위 | 예 |
|---|---|---|
| App 바로 아래(루트) | 화면 전체 | "문제가 발생했습니다" 전역 안내 |
| 라우트·페이지 단위 | 페이지 본문만(헤더·내비게이션은 남음) | 주문 상세 페이지 |
| 위젯·카드 단위 | 위젯 하나만(나머지 대시보드는 남음) | 매출 차트 카드 |', 'OBJECTIVE'),
       (3632, 575, '아래 코드에서 fallback의 "다시 시도" 버튼을 눌렀을 때 일어나는 일로 옳은 것은?', '```tsx
function Page() {
  const [attempt, setAttempt] = useState(0);

  return (
    <ErrorBoundary
      key={attempt}
      fallback={<button onClick={() => setAttempt((a) => a + 1)}>다시 시도</button>}
    >
      <Feed />
    </ErrorBoundary>
  );
}
```

Feed는 마운트될 때 useEffect에서 피드 목록을 요청하며, 지금은 그 요청이 실패해 fallback이 보이는 상태다.', 'OBJECTIVE'),
       (3633, 575, '아래 상황에서 이 에러까지 리포팅 도구로 보내려면 window에 추가로 등록해야 하는 이벤트의 이름은?', '주문 저장 버튼의 핸들러가 saveOrder(cart)를 try/catch 없이 호출한다. 요청이 500으로 실패해도 화면은 그대로고 안내 메시지도 뜨지 않는다. 상위 에러 경계는 아무 반응이 없고, 이미 등록해 둔 window의 error 리스너에도 걸리지 않는다. 브라우저 콘솔에만 Uncaught (in promise) ApiError: 500 한 줄이 남고, 리포팅 서버에는 아무 기록도 쌓이지 않는다.', 'SUBJECTIVE'),
       (3634, 575, '아래 클래스에서 빠져 있어 이 증상이 생긴, 에러 발생 시 React가 호출하는 정적 메서드의 이름은?', '```tsx
class Boundary extends Component {
  state = { hasError: false };

  componentDidCatch(error, info) {
    reportError(error, info.componentStack);
  }

  render() {
    return this.state.hasError ? this.props.fallback : this.props.children;
  }
}
```

하위 Post가 렌더 중 throw하면 리포팅 서버에는 에러가 정상적으로 쌓이지만, 화면에는 fallback 대신 빈 화면이 남는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3629
(9851, 3629, '에러가 난 컴포넌트만 fallback으로 바뀌고, 같은 경계 안의 형제 컴포넌트는 그대로 남는다.', '교체 단위를 컴포넌트 하나로 착각한 오개념. React는 에러가 난 지점이 아니라 그 에러를 잡은 경계를 기준으로 아래 트리를 통째로 언마운트한다. 형제만 살리고 싶다면 형제마다 경계를 따로 감싸야 한다.', false),
(9852, 3629, '경계 아래 트리 전체가 언마운트되고 그 자리에 fallback이 그려지며, 경계 위쪽 화면은 그대로 유지된다.', '부분 손상된 UI를 남기는 대신 경계 아래를 통째로 걷어내고 fallback으로 교체하는 것이 기본 동작이다. 경계 위 트리는 렌더가 정상이라 영향받지 않으므로, 어느 단위로 감싸느냐가 곧 사라지는 화면의 범위가 된다.', true),
(9853, 3629, '경계를 여러 겹 중첩하면 안쪽과 바깥쪽이 모두 반응해 fallback이 두 개 그려진다.', '에러 전파를 방송처럼 오해한 것. 가장 가까운 경계가 잡으면 전파는 거기서 멈추고 바깥 경계는 관여하지 않는다. 바깥이 반응하는 것은 안쪽 경계가 아예 없거나, 안쪽 경계 자신의 렌더가 던졌을 때다.', false),
(9854, 3629, '하위에서 fetch().then 콜백이 던진 예외도 하위 트리에서 난 에러이므로 같은 fallback으로 이어진다.', '하위 트리의 에러를 위치 기준으로만 읽은 오개념. 기준은 위치가 아니라 시점이라, React가 컴포넌트를 실행하는 동안 던져진 것만 잡힌다. then 콜백은 렌더가 끝난 뒤 별도 태스크에서 실행되어 경계 밖이다.', false),

-- 문제 3630
(9855, 3630, '(A) 응답을 처리하는 .then 콜백에서 던진 에러', 'fetch 체인은 렌더와 커밋이 모두 끝난 뒤 마이크로태스크에서 실행되므로 React 호출 스택 밖이다. 경계에 걸리지 않고 처리되지 않은 Promise 거부로 흘러간다.', false),
(9856, 3630, '(B) setTimeout 콜백에서 던진 에러', '콜백을 등록한 코드가 useEffect 안이라 잡힌다고 오해하기 쉽다. 판단 기준은 등록 위치가 아니라 실행 시점이며, 타이머 콜백은 브라우저가 별도 태스크로 호출해 React 밖에서 실행된다.', false),
(9857, 3630, '(C) useEffect 콜백 본문에서 동기적으로 던진 에러', 'useEffect 본문은 커밋 단계에서 React가 직접 호출하므로 여기서 던진 예외는 React 호출 스택 안에 있다. 따라서 상위 경계가 잡아 아래 트리를 fallback으로 교체한다.', true),
(9858, 3630, '(D) onClick 핸들러에서 던진 에러', '이벤트 핸들러는 브라우저가 호출하는 것이라 렌더 스택 밖이고, 실패해도 화면 렌더에는 영향이 없다. 그래서 경계 대신 핸들러 안에서 try/catch로 잡아 토스트 등으로 알리는 것이 맞는 처리다.', false),

-- 문제 3631
(9859, 3631, '위젯 단위 경계가 잡은 에러는 루트 경계까지 함께 전파돼 결국 화면 전체가 전역 안내로 바뀐다.', '표의 위젯 행(나머지 대시보드는 남음)과 정면으로 어긋나는 거짓 진술이다. 가장 가까운 경계가 잡으면 전파는 거기서 끝나고 루트 경계는 호출되지 않는다. 루트가 반응하는 것은 안쪽 경계가 없을 때다.', true),
(9860, 3631, '루트에만 경계를 두면 매출 차트 하나가 실패해도 화면 전체가 전역 안내로 바뀌어 나머지 대시보드를 볼 수 없다.', '참이다. 루트 행의 사라지는 범위가 화면 전체이므로, 그 아래에 다른 경계가 없으면 작은 위젯 하나의 실패가 화면 전체 교체로 커진다. 루트 경계를 최후 방어선이라 부르는 이유이자 한계다.', false),
(9861, 3631, '페이지 단위 경계는 본문이 실패해도 헤더·내비게이션이 남아 사용자가 다른 메뉴로 이동해 작업을 이어갈 수 있다.', '참이다. 페이지 행에서 남는 범위가 헤더와 내비게이션이므로, 사용자는 새로고침 말고도 다른 화면으로 이동한다는 복구 경로를 갖게 된다.', false),
(9862, 3631, '위젯 단위 경계만 두고 루트 경계를 생략하면 대시보드 레이아웃 자체의 렌더 에러는 잡을 경계가 없어 빈 화면이 남는다.', '참이다. 경계는 자기 아래 트리만 담당하므로 위젯 바깥에서 난 에러는 어느 경계에도 걸리지 않는다. 위젯 단위로 잘게 감싸더라도 루트 경계를 함께 두는 이유다.', false),

-- 문제 3632
(9863, 3632, 'ErrorBoundary 인스턴스는 그대로 둔 채 내부 hasError만 false로 되돌아가, Feed가 언마운트 없이 이전 상태를 이어서 렌더한다.', 'key 변경을 단순한 상태 초기화로 오해한 것. key가 달라지면 React는 같은 자리라도 다른 컴포넌트로 보고 이전 인스턴스를 버린다. 게다가 코드 어디에도 hasError를 손으로 되돌리는 부분이 없다.', false),
(9864, 3632, 'attempt 값만 바뀔 뿐 같은 위치·같은 타입이므로 React가 기존 인스턴스를 재사용해 fallback이 계속 보인다.', '재조정 기준을 타입과 위치로만 기억한 오개념. key는 타입·위치보다 우선하는 정체성 표시라, 값이 바뀌면 같은 자리·같은 타입이어도 재사용이 끊기고 새로 마운트된다.', false),
(9865, 3632, 'Page 전체가 리마운트되면서 attempt도 0으로 초기화돼 같은 fallback이 다시 나타난다.', 'key는 그것이 붙은 엘리먼트의 정체성만 바꾼다. 부모 Page는 상태가 바뀌어 리렌더될 뿐 리마운트되지 않으므로 attempt는 1로 남고, 그래서 이 재시도 패턴이 성립한다.', false),
(9866, 3632, 'key가 달라져 경계와 Feed가 새 인스턴스로 리마운트되고, Feed의 마운트 이펙트가 다시 실행돼 요청이 처음부터 재시도된다.', '경계에 key를 걸어 리마운트로 초기 상태를 되찾는 복구 패턴이다. 다만 실패를 부른 서버 상태 캐시가 그대로면 같은 에러가 반복되므로, 복구 시 원인 데이터도 함께 무효화해야 한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1166, 3633, 'unhandledrejection,unhandled rejection,onunhandledrejection,unhandledrejection 이벤트', '처리되지 않은 Promise 거부는 동기 예외가 아니라서 window의 error 이벤트로는 오지 않는다. 대신 브라우저가 unhandledrejection 이벤트를 발생시키고, 거부 사유는 e.reason에 담긴다. 에러 경계와 헷갈리지 않게 경계를 나눠 두면, 에러 경계는 렌더 단계에서 던져진 에러만 잡으므로 요청 실패에는 아예 관여하지 않는다. 또한 이 전역 리스너는 로깅을 위한 마지막 안전망일 뿐 UI를 복구해 주지는 않는다. 화면을 유지한 채 사용자에게 알리려면 핸들러 안에서 try/catch로 잡아 안내하는 것이 1차 처리다.'),
       (1167, 3634, 'getDerivedStateFromError,static getDerivedStateFromError,getDerivedStateFromError()', 'React는 하위에서 에러를 잡으면 먼저 렌더 단계에서 getDerivedStateFromError를 호출하고, 그 반환값을 다음 상태로 병합한다. 이 메서드가 없으면 hasError가 계속 false여서 render는 children을 다시 그리려 하고, 결국 트리가 언마운트돼 빈 화면이 남는다. 짝인 componentDidCatch는 커밋 단계에서 로깅 같은 부수효과를 맡는 자리라 예제처럼 리포팅은 되지만 화면 전환은 일으키지 못한다. 둘 다 클래스 컴포넌트에만 있고 훅 버전은 없어, 에러 경계는 여전히 클래스로 작성하거나 라이브러리를 쓴다.');

-- =====================================================
-- Lesson 733: 비동기 에러 전달과 루트 에러 콜백
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4577, 733, '아래 코드에서 Chart가 렌더 중 에러를 던졌을 때 최종 화면으로 옳은 것은?', '```jsx
class Boundary extends Component {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  render() {
    if (this.state.hasError) {
      return <p>{this.props.message.trim()}</p>;
    }
    return this.props.children;
  }
}

function Dashboard() {
  return (
    <>
      <Header />
      <Boundary message="페이지를 표시할 수 없습니다.">
        <SalesPanel />
        <Boundary>
          <Chart />
        </Boundary>
      </Boundary>
    </>
  );
}
```

안쪽 Boundary에는 message를 넘기지 않았고, Dashboard 바깥에는 다른 에러 경계가 없다.', 'OBJECTIVE'),
       (4578, 733, '아래 비동기 에러 처리 방식에 대한 설명으로 옳은 것은?', '요청이 실패하면 더 이상 화면을 그릴 수 없는 Feed 컴포넌트가 있고, Feed는 에러 경계 안쪽에 있다. 요청 Promise에 catch를 붙여 거부 사유를 useState에 저장하고, 그 상태 변경으로 Feed가 다시 렌더될 때 함수 본문 맨 앞에서 저장된 에러를 throw하도록 작성했다.', 'OBJECTIVE'),
       (4579, 733, '아래 설정에서 (가)~(다)가 각각 따로 발생했을 때, 리포팅 서버에 쌓이는 기록으로 옳은 것은?', '```jsx
// React 19
const root = createRoot(document.getElementById("root"), {
  onCaughtError: (error) => send("caught " + error.message),
  onUncaughtError: (error) => send("uncaught " + error.message),
});

root.render(
  <>
    <Header />
    <ErrorBoundary fallback={<p>차트를 불러올 수 없습니다.</p>}>
      <Chart />
    </ErrorBoundary>
  </>
);
```

- (가) Chart가 렌더 중 `new Error("chart")`를 던진다.
- (나) Header가 렌더 중 `new Error("header")`를 던진다.
- (다) Chart의 useEffect에서 등록한 setTimeout 콜백이 `new Error("timer")`를 던진다.

ErrorBoundary는 getDerivedStateFromError만 둔 클래스이고, 리포팅 서버로 보내는 코드는 send뿐이다. 각 에러는 새로 연 화면에서 한 번씩만 발생하며, 기록의 순서는 따지지 않는다.', 'OBJECTIVE'),
       (4580, 733, '아래 증상을 없애는 수정으로 옳은 것은?', '```jsx
import { ErrorBoundary } from "react-error-boundary";

function ProfilePage({ userId }) {
  return (
    <ErrorBoundary FallbackComponent={ProfileFallback}>
      <Profile userId={userId} />
    </ErrorBoundary>
  );
}
```

- ProfileFallback의 "다시 시도" 버튼은 resetErrorBoundary를 호출한다.
- Profile은 userId에 해당하는 프로필을 조회해 그린다.
- 사이드바는 ProfilePage 바깥에 있다. 사이드바에서 다른 사용자를 누르면 ProfilePage는 새로 만들어지지 않고 userId prop만 바뀐다.

증상: 사용자 7의 프로필 조회가 실패해 fallback이 떴다. 이어서 사이드바에서 정상인 사용자 8을 눌러 userId가 8로 바뀌었는데도, "다시 시도"를 누르기 전까지 fallback이 그대로 남는다.', 'OBJECTIVE'),
       (4581, 733, '아래 상황에서 React가 컴포넌트 트리 전체에 한 일을 가리키는 용어는?', '게시글 목록에 author가 null인 게시글이 섞여 들어오자 Post 컴포넌트가 렌더 중 에러를 던졌다. 이 앱에는 에러 경계가 하나도 없다. 에러 직후의 DOM과 콘솔은 다음과 같다.

```text
[에러 전 DOM] <div id="root"><header>…</header><aside>…</aside><main>…</main></div>
[에러 후 DOM] <div id="root"></div>

[콘솔 에러] Uncaught TypeError: Cannot read properties of null (reading ''name'')
              at Post (Post.tsx:14:31)
[콘솔 로그] [Header] useEffect 정리 함수 실행
            [Sidebar] useEffect 정리 함수 실행
```

Sidebar의 검색창에 입력해 둔 값도 함께 사라졌고, 사용자가 화면을 되살릴 방법은 새로고침뿐이다.', 'SUBJECTIVE'),
       (4582, 733, '아래 코드가 설명대로 동작하도록 [ A ]에 넣어야 하는 React 내장 컴포넌트의 이름은?', '```jsx
function Comments({ commentsPromise }) {
  const comments = use(commentsPromise); // React 19
  return comments.map((c) => <p key={c.id}>{c.text}</p>);
}

function Article({ commentsPromise }) {
  return (
    <ErrorBoundary fallback={<p>댓글을 불러오지 못했습니다.</p>}>
      <[ A ] fallback={<CommentsSkeleton />}>
        <Comments commentsPromise={commentsPromise} />
      </[ A ]>
    </ErrorBoundary>
  );
}
```

ErrorBoundary는 직접 작성한 에러 경계 클래스다. commentsPromise가 거부되면 "댓글을 불러오지 못했습니다."가, 이행되면 댓글 목록이 보인다. [ A ]의 fallback은 그 외의 경우에 보인다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4577
(12379, 4577, 'Header와 SalesPanel은 그대로 보이고, Chart 자리에만 내용이 빈 안내 문단이 그려진다.', '안쪽 경계가 자기 fallback을 그리다 난 에러까지 스스로 처리한다고 본 오개념. message가 undefined라 안쪽 Boundary의 render에서 trim() 호출이 TypeError를 던지고, 경계는 자기 렌더 에러를 잡지 못해 바깥으로 넘긴다.', false),
(12380, 4577, 'Header는 그대로 보이고, SalesPanel과 Chart가 있던 영역이 "페이지를 표시할 수 없습니다."로 바뀐다.', 'Chart 에러로 안쪽 경계가 fallback을 그리려다 message.trim()에서 다시 에러가 난다. 경계는 자기 렌더 에러를 못 잡으므로 바깥 Boundary가 받아 자기 아래 트리(SalesPanel 포함)를 안내 문구로 바꾸고, 경계 위 Header는 영향이 없다.', true),
(12381, 4577, '안쪽 경계가 자기 에러를 다시 잡으려고 getDerivedStateFromError를 되풀이해 무한 렌더 루프에 빠진다.', '경계가 자기 에러를 붙잡고 되풀이한다고 본 오개념. React는 에러를 던진 컴포넌트의 위쪽부터 경계를 찾으므로 렌더 중 던진 경계 자신은 후보가 아니고, 곧장 바깥 경계로 넘어가 반복 호출이 생기지 않는다.', false),
(12382, 4577, '경계 컴포넌트 자신이 던진 에러는 어느 경계도 잡지 못해 Header까지 사라지고 빈 화면만 남는다.', '''자기 자신은 못 잡는다''를 ''누구도 못 잡는다''로 넓혀 읽은 오개념. 경계 자신의 렌더 에러는 상위 경계로 전파되며, 여기서는 message가 정상인 바깥 Boundary가 받아 처리하므로 Header는 남는다.', false),

-- 문제 4578
(12383, 4578, 'then·catch 콜백 안에서 곧바로 throw하도록 줄여 써도 경계가 잡아 결과가 같다.', '던지는 코드의 위치만 보고 판단한 오개념. then·catch 콜백은 렌더가 끝난 뒤 마이크로태스크로 실행돼 React 호출 스택 밖이다. 거기서 던지면 경계에 닿지 않고 처리되지 않은 Promise 거부로 남는다.', false),
(12384, 4578, '요청에서 시작된 에러이므로 경계의 componentDidCatch는 호출되지 않는다.', '에러의 출발점으로 판단한 오개념. 경계가 보는 것은 에러가 언제 던져졌는가이다. Feed가 렌더 중에 throw했으므로 일반 렌더 에러처럼 getDerivedStateFromError와 componentDidCatch가 모두 호출된다.', false),
(12385, 4578, '경계를 리셋해 Feed를 다시 그려도 저장해 둔 에러 상태가 남아 곧바로 다시 던져진다.', '컴포넌트 상태가 fallback 교체 뒤에도 살아 있다고 본 오개념. 경계가 fallback을 그릴 때 Feed는 트리에서 제거되며 상태도 함께 버려진다. 리셋 뒤에는 에러 상태가 비어 있는 새 Feed가 요청을 다시 보낸다.', false),
(12386, 4578, '이 요청의 실패는 window의 unhandledrejection 리스너에 기록되지 않는다.', 'catch가 거부를 받아 처리했으므로 체인이 정상 종료돼 처리되지 않은 거부가 생기지 않는다. 에러는 대신 렌더 중 throw를 거쳐 경계로 넘어가므로, 전역 안전망이 아니라 경계가 처리를 맡는다.', true),

-- 문제 4579
(12387, 4579, 'caught chart, uncaught header', '(가)는 경계가 잡아 onCaughtError로, (나)는 경계 밖 렌더 에러라 onUncaughtError로 간다. (다)의 타이머 콜백은 렌더가 끝난 뒤 브라우저가 별도 태스크로 호출해 React를 거치지 않으므로 두 옵션 모두 호출되지 않는다.', true),
(12388, 4579, 'caught chart, uncaught header, uncaught timer', 'onUncaughtError를 앱의 모든 미처리 에러를 받는 전역 리스너로 오해했다. 이 옵션은 React가 컴포넌트를 실행하다 받은 에러 중 경계가 못 잡은 것만 넘긴다. 타이머 에러까지 기록하려면 window의 error 이벤트를 따로 써야 한다.', false),
(12389, 4579, 'caught chart, caught header', '루트를 하나의 에러 경계로 본 오개념. createRoot 옵션은 기록용 훅일 뿐 fallback을 그려 주지 않는다. 경계 밖 Header의 렌더 에러는 잡히지 않은 에러로 분류돼 onUncaughtError로 가고, 화면 전체가 지워진다.', false),
(12390, 4579, 'caught chart, caught timer, uncaught header', '콜백을 등록한 곳(경계 안 Chart의 useEffect)만 보고 잡힌다고 본 오개념. 기준은 실행 시점이라, 별도 태스크에서 도는 타이머 콜백에는 경계도 루트 옵션도 관여하지 않는다. (나)는 경계 밖이라 uncaught가 맞다.', false),

-- 문제 4580
(12391, 4580, 'Profile의 조회 useEffect 의존성 배열에 userId를 넣어, 값이 바뀌면 다시 조회하게 한다.', 'Profile 쪽을 고치면 된다고 본 오개념. fallback이 보이는 동안 Profile은 트리에서 빠져 있어 그 안의 이펙트가 아예 실행되지 않는다. 경계가 에러 상태를 풀지 않는 한 Profile 수정은 화면에 닿지 못한다.', false),
(12392, 4580, 'ErrorBoundary를 사이드바까지 감싸는 라우트 최상단으로 옮겨, 더 넓은 범위를 맡게 한다.', '감싸는 범위를 넓히면 복구된다고 본 오개념. 옮긴 경계도 에러 상태를 풀 계기가 없어 fallback이 그대로 남고, 오히려 사이드바까지 fallback에 가려져 다른 사용자로 이동할 수조차 없게 된다.', false),
(12393, 4580, 'ErrorBoundary에 resetKeys={[userId]}를 넘겨, userId가 바뀌면 경계가 리셋되게 한다.', 'resetKeys 배열의 값이 바뀌면 라이브러리가 경계를 리셋해 Profile을 새 userId로 다시 그린다. 버튼 없이 이동만으로 복구돼야 하는 화면에서 쓰는 패턴이며, 흔히 경로나 id를 키로 넣는다.', true),
(12394, 4580, 'onReset에서 프로필 쿼리 캐시를 무효화해, 실패한 사용자 데이터가 캐시에 남지 않게 한다.', '원인 데이터 무효화를 복구 수단으로 착각한 오개념. 무효화는 리셋 뒤 같은 에러의 반복을 막는 보완책이고, onReset은 리셋이 일어날 때만 호출된다. userId 변경은 리셋을 일으키지 않으므로 fallback이 그대로다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1482, 4581, '언마운트,unmount,unmounting,언마운팅,마운트 해제,전체 언마운트,루트 언마운트', 'React 16부터는 어떤 에러 경계도 잡지 못한 렌더 에러가 나면, 일부만 깨진 UI를 남기느니 지우는 편이 낫다는 판단으로 루트 아래 트리 전체를 언마운트한다(React 18·19도 같다). 그래서 #root가 비고, 트리에서 제거되는 컴포넌트마다 useEffect 정리 함수가 실행되며, 검색창 입력값처럼 컴포넌트에 담겨 있던 상태도 모두 버려진다. 헷갈리기 쉬운 리렌더와는 다르다. 리렌더는 컴포넌트가 트리에 남은 채 함수를 다시 호출하는 것이라 상태가 유지되고, 정리 함수도 의존성이 바뀐 이펙트에서만 실행된다. 또 이 동작은 렌더 중 에러에만 해당한다. 이벤트 핸들러에서 난 에러는 렌더에 영향을 주지 않아 화면이 그대로 남는다. 이런 빈 화면을 막으려면 루트 근처에 최소 하나의 에러 경계를 둬야 한다.'),
       (1483, 4582, 'Suspense,React.Suspense,서스펜스,<Suspense>', 'use로 읽는 Promise가 아직 대기(pending) 중이면 Comments는 렌더를 끝내지 못하고 일시 중단되고, React는 가장 가까운 Suspense를 찾아 그 fallback(여기서는 CommentsSkeleton)을 대신 보여 준다. 반대로 Promise가 거부되면 use가 이를 렌더 중 에러로 바꿔 던지므로, 바깥 ErrorBoundary가 잡아 실패 문구로 바꾼다. 즉 대기는 Suspense가, 실패는 에러 경계가 맡는다. 둘 다 fallback prop을 받아 헷갈리기 쉽지만 반응하는 대상이 다르다. Suspense는 에러를 잡지 못하고, 에러 경계는 대기 상태를 표시하지 못한다. 그래서 한 영역의 ''불러오는 중''과 ''실패''를 함께 표현하려고 이 예제처럼 같은 단위에 짝지어 두는 경우가 많다. 또한 에러 경계는 클래스로 직접 작성해야 하지만 Suspense는 React가 제공하는 내장 컴포넌트다.');

-- =====================================================
-- Lesson 891: React 에러 경계의 역할 분담·배치·복구와 비동기 에러 위임
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5525, 891, '아래 에러 경계 메서드에 대한 설명으로 옳은 것은?', '에러 경계 클래스에는 하위 트리에서 렌더 에러가 던져졌을 때 React가 호출하는 메서드가 두 개 있다. 여기서 다루는 메서드는 그중 하나로, fallback으로 바뀐 화면이 실제 DOM에 반영된 뒤에 호출되며, 던져진 에러 객체와 함께 에러가 난 컴포넌트까지 이어지는 컴포넌트 계층 정보를 인자로 받는다.', 'OBJECTIVE'),
       (5526, 891, '아래 코드에서 OrderSummary가 렌더 중 에러를 던졌을 때 사용자가 보게 되는 화면으로 옳은 것은?', '```tsx
function App() {
  return (
    <ErrorBoundary fallback={<GlobalError />}>
      <Header />
      <Nav />
      <OrderPage />
    </ErrorBoundary>
  );
}

function OrderPage() {
  return (
    <main>
      <OrderSummary />
      <ErrorBoundary fallback={<p>배송 추적을 불러올 수 없습니다.</p>}>
        <Tracking />
      </ErrorBoundary>
      <ErrorBoundary fallback={<p>추천 상품을 불러올 수 없습니다.</p>}>
        <Recommend />
      </ErrorBoundary>
    </main>
  );
}
```

ErrorBoundary는 getDerivedStateFromError로 fallback을 그리는 에러 경계 클래스이고, GlobalError는 "문제가 발생했습니다" 문구와 새로고침 버튼을 보여 준다. OrderSummary 외의 컴포넌트는 모두 정상적으로 렌더된다.', 'OBJECTIVE'),
       (5527, 891, '아래 (가)~(다) 상황에 맞는 처리 방식을 짝지은 것으로 옳은 것은?', '한 쇼핑몰 앱의 팀이 쓸 수 있는 에러 처리 방식은 다음 네 가지다.

| 기호 | 처리 방식 |
|---|---|
| A | 에러가 나는 코드를 try/catch로 감싸 잡고, 토스트로 알린다 |
| B | 상위 에러 경계가 잡아 fallback 화면으로 바꾼다 |
| C | 에러를 useState에 담아 두고, 다시 렌더될 때 컴포넌트 본문에서 throw한다 |
| D | window에 unhandledrejection 리스너를 등록해 둔다 |

- (가) 결제 화면에서 "쿠폰 적용" 버튼의 onClick 핸들러가 호출한 API가 400으로 실패했다. 입력해 둔 배송지와 카드 정보는 화면에 그대로 남아 있어야 한다.
- (나) 주문 상세 컴포넌트가 응답의 items로 목록을 그리던 중, items가 null이라 렌더 중 TypeError가 났다.
- (다) 피드 컴포넌트가 useEffect에서 보낸 목록 요청이 실패했다. 목록이 없으면 보여 줄 것이 없어 피드 영역 전체를 안내 화면으로 바꿔야 한다.

(나)·(다)의 컴포넌트는 모두 에러 경계 안쪽에 있다.', 'OBJECTIVE'),
       (5528, 891, '아래 코드에서 "다시 시도"가 복구로 이어지지 않는 원인으로 옳은 것은?', '```tsx
const cache = new Map<string, Promise<Post[]>>();

function getFeed(url: string) {
  if (!cache.has(url)) {
    cache.set(
      url,
      fetch(url).then((r) => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
    );
  }
  return cache.get(url)!;
}

function Feed() {
  const posts = use(getFeed("/api/feed")); // React 19
  return <PostList posts={posts} />;
}

function FeedSection() {
  return (
    <ErrorBoundary FallbackComponent={RetryFallback}>
      <Suspense fallback={<Spinner />}>
        <Feed />
      </Suspense>
    </ErrorBoundary>
  );
}
```

ErrorBoundary는 react-error-boundary 라이브러리의 컴포넌트이고, RetryFallback의 "다시 시도" 버튼은 resetErrorBoundary를 호출한다.

증상: /api/feed가 503을 돌려줘 fallback이 떴다. 몇 분 뒤 서버가 복구된 것을 확인하고 "다시 시도"를 눌렀지만, 로딩 스피너 없이 곧바로 같은 fallback이 다시 떴다. 네트워크 탭에는 새 /api/feed 요청이 찍히지 않았다.', 'OBJECTIVE'),
       (5529, 891, '아래 상황에서 v2 배포 때 카드마다 감싼 컴포넌트가 맡은 역할을 가리키는 React 용어는?', '대시보드 앱의 매출 차트 카드에 있는 Chart 컴포넌트는 응답의 series가 null이면 렌더 중 TypeError를 던진다. 같은 응답으로 두 버전을 비교했다.

| 항목 | v1 | v2 |
|---|---|---|
| 코드 변경 | 없음 | 대시보드 카드마다 클래스 컴포넌트 하나로 감쌈 |
| Chart 렌더 에러 직후 화면 | #root가 비어 흰 화면만 남음 | 헤더와 다른 카드는 그대로 보임 |
| 매출 차트 카드 자리 | 화면 전체와 함께 사라짐 | "차트를 불러올 수 없습니다." 문구가 보임 |
| 차트의 "내보내기" 버튼 onClick 에러 | 화면 변화 없음 | 화면 변화 없음, 추가한 컴포넌트도 반응 없음 |', 'SUBJECTIVE'),
       (5530, 891, '아래 코드의 (A)에 들어갈 TanStack Query 옵션의 이름은?', '```tsx
// TanStack Query v5
function OrderList() {
  const { data } = useQuery({
    queryKey: ["orders"],
    queryFn: fetchOrders,
    retry: false,
    (A): true,
  });
  return <ul>{data?.map((o) => <li key={o.id}>{o.title}</li>)}</ul>;
}

function OrdersPage() {
  return (
    <ErrorBoundary fallback={<p>주문 목록을 불러올 수 없습니다.</p>}>
      <OrderList />
    </ErrorBoundary>
  );
}
```

fetchOrders가 500으로 실패하는 상황에서 (A) 줄만 넣었다 뺐다 하며 비교했다.

- (A) 줄이 없을 때: 목록 자리가 빈 채로 남고, ErrorBoundary는 아무 반응이 없다.
- (A) 줄이 있을 때: 같은 실패에서 목록 자리에 "주문 목록을 불러올 수 없습니다."가 보인다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5525
(14907, 5525, '반환한 객체가 다음 상태로 병합되며, 이 반환값 덕분에 화면이 fallback으로 전환된다.', '짝이 되는 메서드와 헷갈린 오개념. 상태를 반환해 fallback 전환을 일으키는 것은 렌더 단계에서 먼저 호출되는 getDerivedStateFromError다. 본문의 메서드는 DOM 반영 뒤에 호출되는 componentDidCatch라 이미 fallback이 그려진 다음이다.', false),
(14908, 5525, '리포팅 서버로 에러를 보내는 것처럼 부수효과를 두기에 알맞은 자리다.', 'DOM 반영 뒤, 즉 커밋 단계에서 호출되는 componentDidCatch다. 여러 번 실행되거나 결과가 버려질 수 있는 렌더 단계와 달리 부수효과를 두어도 안전해, 두 번째 인자의 componentStack과 함께 에러를 기록하는 자리로 쓴다.', true),
(14909, 5525, '정적 메서드라서 this로 인스턴스의 props나 상태에 접근할 수 없다.', '정적 메서드는 짝인 getDerivedStateFromError 쪽이다. componentDidCatch는 인스턴스 메서드라 this.props로 받은 콜백을 부르는 등 인스턴스에 접근할 수 있다. 정적이면서 순수해야 하는 쪽은 렌더 단계에서 호출되는 메서드다.', false),
(14910, 5525, '함수 컴포넌트에도 같은 역할을 하는 훅이 있어 클래스 없이 대신할 수 있다.', '에러를 잡는 두 메서드는 클래스 컴포넌트에만 있고, React 19에도 대응하는 훅이 없다. 함수 컴포넌트만 쓰는 코드베이스라면 내부가 클래스로 된 react-error-boundary 같은 라이브러리를 가져다 쓴다.', false),

-- 문제 5526
(14911, 5526, 'Header·Nav와 두 위젯은 그대로이고, OrderSummary가 있던 자리만 비어 있다.', '에러 난 컴포넌트 하나만 빠진다고 본 오개념. React는 에러를 잡은 경계를 기준으로 그 아래 트리를 통째로 교체한다. OrderSummary만 감싼 경계가 없으니 교체는 더 위쪽 경계에서 일어난다.', false),
(14912, 5526, 'Header·Nav는 그대로이고, main 영역만 GlobalError 화면으로 바뀐다.', '경계가 에러 난 가지만 fallback으로 바꾼다고 본 오개념. 경계는 자기 아래 트리 전체를 fallback 하나로 바꾼다. 헤더와 내비게이션을 살리려면 OrderPage를 감싸는 페이지 단위 경계를 따로 둬야 한다.', false),
(14913, 5526, 'Header·Nav까지 사라지고, 화면 전체가 GlobalError 화면으로 바뀐다.', '두 위젯 경계는 OrderSummary의 조상이 아닌 형제라 에러를 받지 못하고, 에러는 위로 전파돼 App의 루트 경계에 잡힌다. 루트 경계는 자기 아래의 Header·Nav·OrderPage를 모두 GlobalError로 바꾼다.', true),
(14914, 5526, 'App의 경계가 OrderSummary를 직접 감싸지 않아 어느 경계도 잡지 못하고 흰 화면만 남는다.', 'JSX에 직접 적힌 자식만 담당한다고 본 오개념. 경계는 자기 아래 트리 전체를 맡으므로 OrderPage 안쪽 깊은 곳의 렌더 에러도 받는다. 흰 화면은 조상 중에 경계가 하나도 없을 때의 결과다.', false),

-- 문제 5527
(14915, 5527, '(가)-B, (나)-B, (다)-B', '에러 경계가 모든 에러를 잡는다고 본 오개념. 경계는 React가 컴포넌트를 실행하는 동안 던져진 에러만 잡는다. 브라우저가 호출하는 onClick 핸들러나, useEffect에서 보낸 요청의 실패는 경계에 닿지 않는다.', false),
(14916, 5527, '(가)-A, (나)-B, (다)-B', '(다)를 경계가 바로 잡는다고 본 오개념. 요청 실패는 렌더가 끝난 뒤 별도 태스크에서 Promise 거부로 나타나 React 호출 스택 밖이다. 경계의 fallback으로 바꾸려면 상태에 담았다가 렌더 중에 다시 던져야 한다.', false),
(14917, 5527, '(가)-C, (나)-B, (다)-D', '(가)를 렌더 중 throw로 경계에 넘기면 경계 아래 화면이 통째로 fallback으로 바뀌어 입력해 둔 값이 사라진다. 또 unhandledrejection 리스너는 기록을 위한 마지막 안전망일 뿐, 피드 영역을 안내 화면으로 바꿔 주지 못한다.', false),
(14918, 5527, '(가)-A, (나)-B, (다)-C', '기준은 "지금 화면을 계속 보여 줘도 되는가"다. (가)는 화면을 지켜야 해 try/catch와 토스트, (나)는 렌더 중 에러라 경계가 잡는다. (다)는 화면을 바꿔야 하지만 경계가 못 보는 비동기 에러라 렌더 중 throw로 경계에 넘긴다.', true),

-- 문제 5528
(14919, 5528, 'getFeed가 cache에 남은 거부된 Promise를 돌려줘, 다시 그려진 Feed가 새 요청 없이 같은 실패를 받는다.', '리셋으로 Feed는 새로 그려지지만 getFeed가 cache에 남은 거부된 Promise를 그대로 돌려주고, use가 이를 곧바로 렌더 에러로 던진다. onReset에서 cache.delete("/api/feed")로 원인 데이터를 비워야 재요청이 일어난다.', true),
(14920, 5528, '에러 경계는 한 번 잡은 에러를 새로고침 전까지 유지하므로, 리셋해도 같은 fallback을 계속 그린다.', '경계의 에러 상태가 영구하다고 본 오개념. resetErrorBoundary는 경계 상태를 초기화해 자식을 다시 그린다. fallback이 곧바로 돌아온 것은 다시 그려진 Feed가 또 에러를 던졌기 때문이다.', false),
(14921, 5528, '거부 사유가 Feed의 상태에 남아 있어, 리셋 뒤에도 같은 Feed 인스턴스가 곧바로 에러를 다시 던진다.', '컴포넌트 상태가 fallback 교체 뒤에도 남는다고 본 오개념. fallback이 그려질 때 경계 아래 트리는 통째로 제거돼 Feed의 인스턴스와 상태가 남지 않는다. 게다가 Feed에는 에러를 담는 상태 자체가 없다.', false),
(14922, 5528, 'use가 실패한 URL을 기억해 두고, 리셋 뒤에도 같은 URL로는 다시 요청하지 않도록 막는다.', 'use가 요청을 관리한다고 본 오개념. use는 넘겨받은 Promise의 결과를 읽을 뿐, URL도 요청을 보낼지 여부도 모른다. 새 요청이 없는 것은 getFeed가 cache에 있던 같은 Promise를 돌려주기 때문이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1798, 5529, '에러 경계,에러경계,에러 바운더리,에러바운더리,오류 경계,error boundary,errorboundary,error boundaries,에러 경계 컴포넌트', 'v2에서 카드마다 감싼 클래스 컴포넌트는 하위 트리에서 던져진 렌더 에러를 잡아 그 아래만 fallback으로 바꾸는 에러 경계다. v1처럼 경계가 하나도 없으면 React는 일부만 깨진 화면을 남기는 대신 루트 아래 트리 전체를 언마운트해 흰 화면이 남는다. v2에서는 매출 차트 카드를 감싼 경계가 에러를 잡아 그 카드 자리만 안내 문구로 바뀌었고, 경계 위쪽의 헤더와 다른 카드는 영향을 받지 않았다. 다만 에러 경계는 React가 컴포넌트를 실행하는 동안 던져진 에러만 잡는다. onClick 핸들러는 렌더가 끝난 뒤 브라우저가 호출하므로 경계가 보지 못하고, 핸들러 안에서 try/catch로 직접 처리해야 한다. 헷갈리기 쉬운 옆 개념과도 구분하자. 카드 자리에 대신 보인 안내 문구는 경계가 그리는 fallback UI일 뿐 컴포넌트의 역할 이름이 아니고, Suspense는 대기 중인 상태를 표시할 뿐 에러를 잡지 못한다. 에러를 잡는 메서드(getDerivedStateFromError·componentDidCatch)가 클래스에만 있어 v2처럼 클래스 컴포넌트로 작성한다.'),
       (1799, 5530, 'throwOnError,throw on error,throwOnError: true,throwOnError:true,useErrorBoundary', 'throwOnError를 true로 켜면 쿼리가 실패했을 때 useQuery가 그 에러를 컴포넌트 렌더 중에 던진다. 렌더 중에 던져진 에러이므로 가장 가까운 에러 경계가 잡아 fallback을 보여 준다. 요청 실패 자체는 렌더가 끝난 뒤 별도 태스크에서 일어나 경계가 볼 수 없는데, 옵션이 없을 때 useQuery는 실패를 error 값으로 돌려줄 뿐이라 data가 비어 목록 자리만 빈 채 남았다. 즉 이 옵션은 에러를 상태에 담아 두었다가 렌더 중에 throw해 경계로 넘기는 승격 패턴을 라이브러리가 대신해 주는 것이다. TanStack Query v4까지는 같은 옵션의 이름이 useErrorBoundary였다. 헷갈리기 쉬운 retry는 실패 시 재요청 횟수만 정할 뿐 경계와는 관계가 없고, window의 unhandledrejection 리스너는 기록용 안전망이라 화면을 fallback으로 바꿔 주지 못한다. 반대로 화면을 유지한 채 목록 자리에만 안내를 띄우고 싶다면 옵션을 켜지 않고 error 값을 보고 인라인으로 처리하면 된다.');
