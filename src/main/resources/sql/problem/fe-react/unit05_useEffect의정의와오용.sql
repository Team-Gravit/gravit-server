-- Unit: useEffect의 정의와 오용 (Unit ID: 145)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (571, 145, '불필요한 이펙트와 클린업 누락'),
       (729, 145, '재실행 순서와 useEffectEvent'),
       (887, 145, 'useEffect를 쓸 자리와 대신 쓸 방법');

-- =====================================================
-- Lesson 571: 불필요한 이펙트와 클린업 누락
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3605, 571, '아래 코드에서 userId가 3에서 7로 바뀐 직후, 3에 대한 응답이 7에 대한 응답보다 늦게 도착했을 때 일어나는 일로 옳은 것은?', '```tsx
function Profile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    let ignore = false;
    fetchUser(userId).then((data) => {
      if (!ignore) setUser(data);
    });
    return () => { ignore = true; };
  }, [userId]);

  return <p>{user?.name}</p>;
}
```', 'OBJECTIVE'),
       (3606, 571, '아래 컴포넌트를 처음 렌더할 때 실제로 일어나는 일로 옳은 것은?', '```tsx
function Cart({ items }) {
  const [total, setTotal] = useState(0);

  useEffect(() => {
    setTotal(items.reduce((sum, item) => sum + item.price, 0));
  }, [items]);

  return <p>합계 {total}원</p>;
}
```', 'OBJECTIVE'),
       (3607, 571, '아래 분류표를 바탕으로 한 판단으로 옳지 않은 것은?', '| 하려는 일 | 이펙트인가? | 대안 |
| --- | --- | --- |
| props·state에서 값 계산 | 아니오 | 렌더 중 계산, useMemo |
| props 변경 시 상태 리셋 | 아니오 | key 변경 |
| 사용자 액션에 반응(요청·알림) | 아니오 | 이벤트 핸들러 |
| 부모에게 변화 통지 | 아니오 | 이벤트 핸들러에서 콜백 호출 |
| 외부 스토어 구독 | 대체로 아니오 | useSyncExternalStore |
| 브라우저 API·소켓·타이머 동기화 | 예 | useEffect + 클린업 |
| 페이지 진입 분석 로그 | 예 | useEffect |', 'OBJECTIVE'),
       (3608, 571, '화면 맨 아래에 있는 버튼에 아래 툴팁을 열었을 때 사용자가 보게 되는 모습으로 옳은 것은?', '```tsx
function Tooltip({ anchorRect }) {
  const ref = useRef(null);
  const [flip, setFlip] = useState(false);

  useEffect(() => {
    const height = ref.current.getBoundingClientRect().height;
    setFlip(anchorRect.bottom + height > window.innerHeight);
  }, [anchorRect]);

  const top = flip ? anchorRect.top - 8 : anchorRect.bottom + 8;
  return <div ref={ref} style={{ top }}>도움말</div>;
}
```', 'OBJECTIVE'),
       (3609, 571, '아래 상황에서 지운 React 내장 컴포넌트의 이름은?', '개발 서버에서 채팅 화면을 처음 열자 콘솔에 connect A, disconnect A, connect A가 차례로 찍혔다. 같은 코드를 프로덕션으로 빌드해 열면 connect A 한 줄만 남는다. 컴포넌트 코드는 손대지 않고 main.tsx에서 <App />을 감싸고 있던 컴포넌트 하나를 지웠더니, 개발 서버에서도 connect A 한 줄만 찍혔다.', 'SUBJECTIVE'),
       (3610, 571, '아래 이펙트에 빠져 있는 것을 가리키는 용어는?', '관리자 대시보드에서 목록 화면과 상세 화면을 오가며 열 번쯤 이동했더니, 5초에 한 번이던 갱신 요청이 네트워크 탭에 5초마다 열 줄씩 찍혔다. 상세 화면을 닫고 목록만 보고 있어도 요청은 멈추지 않았고, 브라우저 탭을 새로 고치자 다시 한 줄로 돌아왔다. 상세 화면의 이펙트는 아래가 전부다.

```tsx
useEffect(() => {
  setInterval(() => refetch(), 5000);
}, []);
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3605
(9787, 3605, '나중에 도착한 3의 응답이 상태를 덮어써 화면이 3번 사용자 정보로 되돌아간다.', '클린업이 없을 때 벌어지는 일을 그대로 옮긴 오개념. userId가 7로 바뀔 때 새 이펙트보다 이전 이펙트의 클린업이 먼저 실행돼 그 실행의 ignore가 true가 되므로, 늦게 온 3의 응답은 setUser까지 가지 못한다.', false),
(9788, 3605, '3의 응답이 도착해도 setUser가 호출되지 않아 화면에는 7번 사용자 정보가 남는다.', '의존성 userId가 달라지면 새 이펙트 실행 직전에 이전 이펙트의 클린업이 돌아 그 실행에 묶인 ignore가 true가 된다. then 콜백은 자기 실행의 ignore를 보므로 낡은 응답만 골라 버리게 된다.', true),
(9789, 3605, '클린업이 fetchUser 요청 자체를 취소해 3의 응답은 브라우저에 도착하지 않는다.', '클린업이 네트워크 요청을 되돌린다고 본 오개념. 여기서 클린업이 하는 일은 ignore 값을 바꾸는 것뿐이라 3의 응답은 그대로 도착하며, 다만 상태에 반영되지 않고 버려진다.', false),
(9790, 3605, '두 실행이 같은 ignore를 함께 쓰기 때문에 7의 응답까지 무시돼 화면이 계속 비어 있다.', 'ignore를 컴포넌트가 공유하는 값으로 본 오개념. ignore는 이펙트가 실행될 때마다 새로 만들어지는 지역 변수이고 각 then 콜백은 자기 실행의 것을 보므로, 7의 응답은 ignore가 false인 채로 반영된다.', false),

-- 문제 3606
(9791, 3606, '이펙트가 렌더 도중에 실행되므로 total이 첫 화면부터 올바른 합계로 그려진다.', '이펙트가 렌더 단계에서 돈다고 본 오개념. 렌더는 순수 계산이어야 하므로 이펙트는 커밋과 페인트가 끝난 뒤에 실행되고, 첫 화면에는 useState의 초기값이 그대로 쓰인다.', false),
(9792, 3606, 'setTotal이 이펙트 안에 있어 이펙트가 스스로를 다시 부르는 무한 렌더 루프가 생긴다.', '상태를 바꾸는 이펙트는 무조건 루프를 만든다고 본 오개념. 의존성 배열에는 items만 있고 total은 없어서, items가 그대로면 재렌더가 일어나도 이펙트는 다시 실행되지 않는다.', false),
(9793, 3606, '합계 0원이 한 번 화면에 그려진 뒤 이펙트가 상태를 바꿔 다시 렌더되면서 실제 합계로 교체된다.', '렌더에서 페인트, 이펙트, setState, 재렌더로 이어지는 순서 탓에 초기값 0이 한 프레임 노출되고 렌더가 두 번 돈다. props에서 얻는 값이니 렌더 중에 곧바로 계산하면 이 왕복이 사라진다.', true),
(9794, 3606, 'items를 의존성에 넣었더라도 첫 렌더에서는 이펙트가 건너뛰어져 total이 갱신되지 않는다.', '의존성 배열이 있으면 값이 바뀐 뒤에만 실행된다고 본 오개념. 이펙트는 마운트 후 반드시 한 번 실행되고, 그 다음부터 의존성이 달라질 때 다시 실행된다.', false),

-- 문제 3607
(9795, 3607, '여러 화면이 함께 보는 외부 스토어를 구독하려면 이펙트로 직접 구독하는 것 말고는 방법이 없다.', '표는 외부 스토어 구독을 대체로 아니오로 두고 useSyncExternalStore를 대안으로 제시하므로 방법이 없다는 진술은 거짓이다. 이펙트 구독은 구독 시점과 렌더 시점 사이에 값이 어긋날 수 있어 전용 훅이 따로 있다.', true),
(9796, 3607, '상세 페이지가 열렸다는 조회 로그를 보내는 코드는 이벤트 핸들러가 아니라 이펙트에 둔다.', '표에서 이펙트가 맞다고 표시된 두 항목 중 하나다. 사용자가 무엇을 눌러서가 아니라 그 화면에 존재했다는 사실 자체가 계기이므로 이벤트 핸들러에 둘 자리가 없다.', false),
(9797, 3607, '검색어와 원본 목록에서 필터 결과를 만드는 코드는 이펙트 없이 렌더 중에 계산한다.', 'props·state에서 값을 얻는 계산이라 표의 첫 줄에 해당한다. 이펙트로 돌리면 렌더가 한 번 더 도는 데다 그 사이 낡은 목록이 노출되므로 렌더 중 계산이 맞다.', false),
(9798, 3607, 'userId가 바뀔 때 폼 입력값을 비우려면 이펙트 대신 컴포넌트의 key를 바꾸는 방법이 있다.', 'props 변경 시 상태 리셋 항목에 해당한다. key가 달라지면 React가 같은 자리의 컴포넌트를 새로 만들어 상태가 초기값으로 돌아가므로 이펙트로 하나씩 지울 필요가 없다.', false),

-- 문제 3608
(9799, 3608, '툴팁이 처음부터 버튼 위쪽에 나타나고 위치가 옮겨지는 모습은 보이지 않는다.', '측정과 보정이 화면을 그리기 전에 끝난다고 본 오개념. useEffect는 페인트 뒤에 실행되므로 flip이 false인 첫 화면이 이미 사용자 눈에 닿은 뒤에야 위치가 바뀐다.', false),
(9800, 3608, '측정이 끝날 때까지 툴팁이 그려지지 않다가 위쪽 위치가 정해진 뒤에 한 번에 나타난다.', '이펙트가 페인트를 미룬다고 본 오개념. getBoundingClientRect로 높이를 재려면 DOM이 이미 그려져 있어야 하므로 툴팁이 먼저 화면에 나오고 측정은 그 뒤에 이뤄진다.', false),
(9801, 3608, '툴팁이 버튼 아래쪽에 그대로 있고 화면 밖으로 넘친 부분은 잘린 채로 남는다.', '이펙트가 아예 실행되지 않는다고 본 오개념. 마운트 후 이펙트가 실행되고 조건이 참이라 setFlip(true)가 반영되므로 툴팁은 결국 버튼 위쪽으로 옮겨진다.', false),
(9802, 3608, '툴팁이 버튼 아래쪽에 잠깐 나타났다가 위쪽으로 옮겨지는 모습이 한 프레임 보인다.', 'useEffect는 브라우저가 화면을 그린 뒤 실행돼 flip이 false인 상태가 먼저 보이고 보정이 뒤따른다. DOM을 재서 곧바로 위치를 고쳐야 하는 이런 작업은 페인트 전에 도는 useLayoutEffect로 옮겨야 깜빡임이 사라진다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1158, 3609, 'StrictMode,React.StrictMode,<StrictMode>,<React.StrictMode>,스트릭트 모드,스트릭트모드,엄격 모드,strict mode', '개발 모드의 StrictMode는 마운트 직후 이펙트, 클린업, 이펙트를 한 번 더 돌려 클린업이 제대로 짝지어졌는지 드러낸다. connect A 뒤에 disconnect A가 따라오고 다시 connect A가 찍힌 것이 그 흔적이며, 프로덕션 빌드에는 이 이중 실행이 없어 한 줄만 남는다. 로그가 두 번 나오는 것은 버그가 아니라 점검 장치이므로 useRef 플래그로 실행 횟수를 세어 우회하지 말고 클린업을 채우는 쪽으로 고쳐야 한다. Fragment나 Suspense처럼 화면 구성에 관여하는 래퍼가 아니라 개발 중 검사만 하는 래퍼라는 점에서 구분된다.'),
       (1159, 3610, '클린업,클린업 함수,cleanup,cleanup function,정리 함수,뒷정리 함수,클린업 함수 반환,clean up', '이펙트가 만든 것을 되돌리는 함수가 클린업이다. React는 의존성이 바뀌어 이펙트를 다시 실행하기 직전과 컴포넌트가 사라질 때 이 함수를 부른다. 위 코드는 setInterval로 타이머를 걸기만 하고 되돌리지 않아 상세 화면에 들어갈 때마다 살아 있는 타이머가 하나씩 쌓였고, 화면을 닫아도 남아 요청이 늘어났다. 탭을 새로 고치면 자바스크립트 실행 환경이 통째로 초기화되므로 다시 한 줄이 된다. 타이머 id를 받아 return () => clearInterval(id)를 붙이면 화면을 떠날 때 정리된다. 언마운트 처리 전용이라고 외우면 의존성 변경 때도 실행된다는 점을 놓치기 쉽고, 의존성 배열은 이 동기화가 읽는 값의 목록일 뿐 클린업을 대신하지 못한다.');

-- =====================================================
-- Lesson 729: 재실행 순서와 useEffectEvent
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4553, 729, '아래 코드가 1~3 순서로 실행될 때 콘솔에 찍히는 로그 순서로 옳은 것은?', 'StrictMode 없이 프로덕션 빌드로 실행한다.

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    console.log(`connect ${roomId}`);
    return () => console.log(`disconnect ${roomId}`);
  }, [roomId]);

  return <h1>{roomId} 채팅방</h1>;
}
```

1. 부모가 `<ChatRoom roomId="A" />`를 처음 렌더한다.
2. 부모가 roomId를 "B"로 바꿔 다시 렌더한다.
3. 부모가 ChatRoom을 더 이상 렌더하지 않는다.', 'OBJECTIVE'),
       (4554, 729, '아래 컴포넌트에서 사용자가 주문하기를 누른 뒤, 부모가 쿠폰 할인이 반영된 새 cart 객체를 내려보냈을 때 일어나는 일로 옳은 것은?', '```tsx
function Checkout({ cart }: { cart: Cart }) {
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    if (submitted) {
      postOrder(cart); // 서버에 주문 생성 요청
    }
  }, [submitted, cart]);

  return <button onClick={() => setSubmitted(true)}>주문하기</button>;
}
```', 'OBJECTIVE'),
       (4555, 729, '아래 표의 두 훅을 비교했을 때, 훅 Y가 아니라 훅 X에 두어야 하는 작업은?', '| 항목 | 훅 X | 훅 Y |
| --- | --- | --- |
| 실행 시점 | DOM 변경을 반영한 직후, 브라우저가 화면을 그리기 전 | 보통 브라우저가 화면을 그린 뒤 |
| 실행 방식 | 동기 실행 | 예약해 두었다가 실행 |
| 무거운 작업을 넣으면 | 끝날 때까지 화면이 그려지지 않아 프레임이 끊길 수 있음 | 화면이 먼저 그려지고 작업은 뒤이어 처리됨 |', 'OBJECTIVE'),
       (4556, 729, '아래 컴포넌트에서 pageId는 그대로이고 roomId만 바뀌어 다시 렌더될 때 일어나는 일로 옳은 것은?', '```tsx
function ProductChat({ pageId, roomId }: Props) {
  useEffect(() => {
    sendVisitLog(pageId); // 분석 서버에 방문 기록 전송
    const conn = createConnection(roomId);
    conn.connect();
    return () => conn.disconnect();
  }, [pageId, roomId]);

  return <ChatPanel roomId={roomId} />;
}
```', 'OBJECTIVE'),
       (4557, 729, '아래 상황에서 알림 콜백을 감싸는 데 쓴 React 훅의 이름은?', '채팅 화면의 이펙트는 roomId로 채팅 서버에 연결하고, 연결이 끝나면 현재 theme 색으로 "연결됨" 알림을 띄운다. 처음 코드는 이펙트 안에서 theme을 직접 읽어 의존성 배열이 [roomId, theme]이었다.

```
[변경 전]
light 테마로 화면 진입   → connect general / 알림(light)
다크 모드로 전환         → disconnect general / connect general / 알림(dark)
```

알림을 띄우는 콜백을 React 19.2에서 정식 기능이 된 훅으로 감싸고, 이펙트는 연결이 끝난 시점에 그 콜백을 호출하도록 바꾼 뒤 의존성 배열을 [roomId]로 줄였다. 린트 규칙(exhaustive-deps)은 경고를 내지 않았다.

```
[변경 후]
light 테마로 화면 진입   → connect general / 알림(light)
다크 모드로 전환         → (로그 없음)
music 방으로 이동        → disconnect general / connect music / 알림(dark)
```', 'SUBJECTIVE'),
       (4558, 729, '아래 기록에서 목록이 입력과 어긋나게 된 문제를 가리키는 용어는?', '상품 검색 화면은 query가 바뀔 때마다 이펙트에서 검색 API를 호출하고, 응답이 오면 setResults로 목록을 바꾼다. 이 이펙트에는 클린업이 없다. 사용자가 "노트"를 입력했다가 곧바로 "노트북"으로 고쳤을 때의 기록은 아래와 같다.

```
  0ms  query = "노트"     → 요청 1 전송 (응답까지 900ms 소요)
150ms  query = "노트북"   → 요청 2 전송 (응답까지 200ms 소요)
350ms  요청 2 응답 도착   → 목록: "노트북" 검색 결과
900ms  요청 1 응답 도착   → 목록: "노트" 검색 결과
```

검색창에는 "노트북"이 입력돼 있는데 목록에는 "노트" 검색 결과가 남았다. 서버가 요청 1에 빨리 응답한 날에는 같은 순서로 입력해도 목록이 정상이었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4553
(12315, 4553, 'connect A → connect B → disconnect B', '클린업이 언마운트 때만 실행된다고 본 오개념. 의존성 roomId가 바뀌면 새 이펙트를 실행하기 직전에 이전 실행의 클린업이 먼저 돌아 disconnect A가 찍힌다.', false),
(12316, 4553, 'connect A → disconnect B → connect B → disconnect B', '클린업이 최신 roomId를 읽는다고 본 오개념. 클린업은 자신을 만든 렌더의 roomId를 기억하므로, B로 바뀔 때 실행되는 클린업은 A를 출력한다.', false),
(12317, 4553, 'connect A → disconnect A → connect B → disconnect B', 'roomId가 바뀌면 A를 기억한 이전 클린업이 먼저 실행된 뒤 B로 새 이펙트가 실행된다. 언마운트될 때는 마지막 실행의 클린업이 돌아 disconnect B로 끝나, 연결과 해제가 항상 짝을 이룬다.', true),
(12318, 4553, 'connect A → connect B → disconnect A → disconnect B', '새 이펙트가 먼저 실행되고 이전 클린업이 뒤따른다고 본 오개념. React는 재실행 직전에 이전 클린업을 불러 A 연결을 끊은 다음 B에 연결하므로 두 연결이 함께 살아 있는 순간이 없다.', false),

-- 문제 4554
(12319, 4554, 'submitted가 그대로 true여서 이펙트가 다시 실행되고, 주문 생성 요청이 한 번 더 전송된다.', 'cart가 새 객체라 의존성이 달라져 이펙트가 재실행되고, 조건인 submitted는 여전히 true라 postOrder가 또 호출된다. 사용자가 누른 순간 한 번만 보낼 요청은 onClick 핸들러에서 보내야 이런 중복이 생기지 않는다.', true),
(12320, 4554, '요청은 클릭했을 때 이미 한 번 나갔으므로, 새 cart는 화면 표시에만 쓰이고 요청은 더 나가지 않는다.', '이펙트가 클릭 한 번에 한 번만 돈다고 본 오개념. 이펙트는 사용자 행동이 아니라 의존성 값에 묶여 있어, cart가 바뀌면 조건을 다시 검사하고 요청을 또 보낸다.', false),
(12321, 4554, 'cart가 바뀌면 먼저 보낸 주문 요청이 취소된 뒤 새 cart로 다시 요청돼, 주문은 한 건만 남는다.', '이펙트 재실행이 이전 작업을 자동으로 취소한다고 본 오개념. 이 이펙트에는 클린업이 없어 되돌리는 일이 전혀 일어나지 않으므로, 첫 요청은 그대로 남고 두 번째 요청이 추가로 나간다.', false),
(12322, 4554, 'cart의 일부 필드만 달라졌으므로, React가 이전 값과 같다고 판단해 이펙트를 건너뛴다.', '의존성을 내용으로 비교한다고 본 오개념. React는 의존성을 Object.is로 비교하므로, 새로 만든 cart 객체는 필드 값이 비슷해도 이전 값과 다른 것으로 판단된다.', false),

-- 문제 4555
(12323, 4555, '채팅방 id가 바뀔 때마다 웹소켓 연결을 끊고 새로 맺는 작업', '화면 모양과 상관없는 외부 연결이라 화면을 그리기 전에 끝낼 이유가 없다. 훅 X에 두면 연결 준비가 끝날 때까지 화면 그리기만 늦어지므로 화면을 막지 않는 훅 Y가 맞다.', false),
(12324, 4555, '상세 페이지가 열렸다는 조회 기록을 분석 서버로 보내는 작업', '화면에 나타났다는 사실만 있으면 되는 작업이라 화면을 그린 뒤에 보내도 사용자가 보는 화면은 같다. 동기로 실행되는 훅 X를 쓰면 얻는 것 없이 화면 그리기만 미뤄진다.', false),
(12325, 4555, '사용자가 저장 버튼을 눌렀을 때 변경 내용을 서버로 보내는 작업', '사용자가 버튼을 누른 것이 계기인 코드라 두 훅 어디에도 두지 않고 클릭 이벤트 핸들러에서 보낸다. 이펙트에 두면 재렌더나 재마운트 때 같은 요청이 다시 나갈 수 있다.', false),
(12326, 4555, '목록 화면으로 돌아왔을 때 저장해 둔 스크롤 위치로 목록을 옮기는 작업', '목록이 DOM에 반영된 직후 스크롤 위치를 맞춰야 맨 위가 한 번 그려졌다가 아래로 튀는 모습이 보이지 않는다. 화면을 그리기 전에 동기로 실행되는 훅 X만 이 순서를 보장한다.', true),

-- 문제 4556
(12327, 4556, '연결만 새로 맺어지고, pageId는 그대로이므로 방문 기록은 다시 전송되지 않는다.', '바뀐 의존성을 읽는 줄만 골라 실행한다고 본 오개념. React는 이펙트 함수 전체를 다시 실행하므로 roomId만 바뀌어도 sendVisitLog(pageId)가 함께 호출된다.', false),
(12328, 4556, '이전 연결이 끊기고 새 연결이 맺어지며, 방문 기록도 한 번 더 전송된다.', '서로 다른 두 동기화를 한 이펙트에 묶어 roomId 변경이 방문 기록까지 다시 보내게 됐다. 연결용 이펙트는 [roomId], 기록용 이펙트는 [pageId]만 갖도록 나누면 각자 필요할 때만 실행된다.', true),
(12329, 4556, '두 의존성이 모두 바뀌어야 다시 실행되므로, 연결과 방문 기록 모두 그대로 유지된다.', '의존성 배열을 모든 값이 바뀌어야 하는 조건으로 본 오개념. 배열의 값 중 하나라도 이전 렌더와 다르면 이펙트는 다시 실행된다.', false),
(12330, 4556, '클린업이 이전 실행 전체를 되돌리므로, 앞서 보낸 방문 기록도 함께 취소된다.', '클린업이 이펙트의 모든 작업을 자동으로 되돌린다고 본 오개념. 클린업은 반환한 함수에 적힌 일(연결 해제)만 하며, 이미 전송된 방문 기록에는 영향을 주지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1474, 4557, 'useEffectEvent,React.useEffectEvent,useEffectEvent(),experimental_useEffectEvent,이펙트 이벤트,이펙트이벤트,effect event,effectevent,유즈이펙트이벤트,유즈 이펙트 이벤트', 'useEffectEvent로 감싼 함수는 호출될 때마다 가장 최근 렌더의 props·state를 읽지만, 반응형 값으로 취급되지 않아 의존성 배열에 넣지 않는다. 그래서 theme이 바뀌어도 연결 이펙트는 다시 실행되지 않았고(다크 모드 전환 때 로그 없음), music 방으로 옮겨 새로 연결됐을 때는 바뀐 테마인 dark로 알림이 떴다. 린트 규칙도 이 함수를 의존성으로 요구하지 않는다. useCallback과 헷갈리기 쉬운데, useCallback은 의존성인 theme이 바뀌면 새 함수를 만들고 그 함수를 의존성에 둔 이펙트를 다시 실행시키므로 재연결을 막지 못한다. 경고를 없애려고 의존성 배열에서 theme만 지우는 것은 옛 theme을 붙잡는 stale closure를 남기는 우회일 뿐이다. 이펙트 이벤트 함수는 이펙트 안에서만 호출해야 한다.'),
       (1475, 4558, '경쟁 조건,경쟁 상태,경쟁조건,경쟁상태,경합 조건,경합 상태,race condition,racecondition,레이스 컨디션,레이스컨디션', '늦게 보낸 요청 2의 응답이 먼저 오고 먼저 보낸 요청 1의 응답이 나중에 와서, 낡은 응답이 최신 결과를 덮어쓴 것이 경쟁 조건이다. 결과가 요청을 보낸 순서가 아니라 응답이 도착한 타이밍에 따라 달라지므로, 서버가 요청 1에 빨리 응답한 날에는 문제가 드러나지 않았다. fetch는 취소가 어렵기 때문에 이펙트 안에 let ignore = false를 두고 클린업에서 ignore = true로 바꾸면, query가 바뀔 때 이전 실행의 응답은 setResults까지 가지 못한다. 서로를 기다리며 멈춰 버리는 교착 상태(deadlock)와 달리 두 요청은 모두 끝나고 반영 순서만 뒤바뀐다. 또 요청 1의 콜백이 "노트"를 기억하는 것 자체는 정상 동작이므로, 클로저가 옛 값을 읽어 생기는 stale closure 문제와도 구분된다.');

-- =====================================================
-- Lesson 887: useEffect를 쓸 자리와 대신 쓸 방법
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5501, 887, '아래 코드에서 버튼을 한 번 눌렀을 때 콘솔에 찍히는 로그 순서로 옳은 것은?', 'StrictMode 없이 실행한다. 첫 화면이 뜬 뒤 콘솔을 비우고 버튼을 한 번 눌렀다.

```tsx
function Settings() {
  const [enabled, setEnabled] = useState(false);
  console.log(`Settings 렌더: ${enabled}`);
  return <Toggle onChange={setEnabled} />;
}

function Toggle({ onChange }: { onChange: (on: boolean) => void }) {
  const [isOn, setIsOn] = useState(false);
  console.log(`Toggle 렌더: ${isOn}`);

  useEffect(() => {
    onChange(isOn);
  }, [isOn, onChange]);

  return <button onClick={() => setIsOn(!isOn)}>알림 전환</button>;
}
```', 'OBJECTIVE'),
       (5502, 887, '아래 과정에서 채팅 연결에 일어나는 일로 옳은 것은?', '개발 모드에서 connect가 두 번 실행되는 것을 막으려고 ref 플래그를 넣은 코드다. 이 코드를 프로덕션 빌드로 실행해 roomId가 "A"인 채로 마운트한 뒤 roomId를 "B"로 바꾸고, 마지막으로 ChatRoom을 화면에서 없앴다.

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  const connected = useRef(false);

  useEffect(() => {
    if (connected.current) return;
    connected.current = true;

    const conn = createConnection(roomId);
    conn.connect();
    return () => conn.disconnect();
  }, [roomId]);

  return <h1>{roomId} 채팅방</h1>;
}
```', 'OBJECTIVE'),
       (5503, 887, '아래 강의 플레이어의 이펙트 (가)~(라) 중 다른 방식으로 옮기지 않고 이펙트로 두는 것이 맞는 것은?', '```tsx
function LecturePlayer({ lecture, speed, isPlaying, onVolumeChange }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [caption, setCaption] = useState("");
  const [liked, setLiked] = useState(false);
  const [volume, setVolume] = useState(50);

  // (가)
  useEffect(() => {
    setCaption(`${lecture.title} · ${speed}배속`);
  }, [lecture.title, speed]);

  // (나) 좋아요 버튼의 onClick은 setLiked(true)만 호출한다
  useEffect(() => {
    if (liked) postLike(lecture.id);
  }, [liked, lecture.id]);

  // (다) 음량 슬라이더의 onChange는 setVolume만 호출한다
  useEffect(() => {
    onVolumeChange(volume);
  }, [volume, onVolumeChange]);

  // (라) isPlaying은 부모의 재생 버튼이 바꿔 내려 주는 props 값이다
  useEffect(() => {
    if (isPlaying) videoRef.current!.play();
    else videoRef.current!.pause();
  }, [isPlaying]);

  // JSX 생략: <video ref={videoRef} />, {caption}, 좋아요 버튼, 음량 슬라이더
}
```', 'OBJECTIVE'),
       (5504, 887, '아래 조건과 비교표를 바탕으로 한 판단으로 옳은 것은?', '상품 목록 화면과 상품 상세 화면은 라우터가 번갈아 렌더하며, 화면을 옮기면 이전 화면의 컴포넌트는 언마운트된다. 두 화면 모두 데이터가 도착하기 전에는 로딩 화면을 보여 준다. 팀은 데이터를 불러오는 두 방식을 아래처럼 비교했다.

| 항목 | 방식 A: useEffect + fetch 직접 작성 | 방식 B: 서버 상태 라이브러리 |
| --- | --- | --- |
| 받은 응답을 두는 곳 | 요청한 컴포넌트의 state | 컴포넌트 바깥의 캐시(요청 키별 보관) |
| 같은 요청이 여러 곳에서 동시에 나갈 때 | 컴포넌트마다 따로 요청 | 하나로 합쳐 요청 |
| 늦게 도착한 낡은 응답 | 클린업의 ignore 플래그로 직접 무시 | 라이브러리가 처리 |
| 데이터 다시 가져오기 | 직접 작성 | 창 포커스 복귀 등에서 자동 |', 'OBJECTIVE'),
       (5505, 887, '아래 상황에서 useEffect 대신 쓴 React 훅의 이름은?', '공지 배너는 서버에서 받은 제목을 그린 뒤, ref로 제목의 실제 너비를 재서 배너보다 넓으면 글자 크기 state를 한 단계 줄인다. 처음에는 이 코드를 useEffect에 넣었는데, 공지를 불러와 배너가 나타날 때마다 큰 글자로 배너 밖까지 넘친 제목이 잠깐 보였다가 작아졌다.

```tsx
useEffect(() => {
  const width = titleRef.current!.scrollWidth;
  if (width > bannerWidth) setFontSize((size) => size - 2);
}, [title, fontSize, bannerWidth]);
```

이펙트 안의 코드와 의존성 배열은 그대로 두고 훅 이름만 다른 React 내장 훅으로 바꾸자, 넘친 제목은 한 번도 보이지 않고 처음부터 줄어든 글자로 나타났다. 다만 같은 방식을 한 화면에 있는 카드 수백 개의 제목에 적용하자, 모든 카드의 측정이 끝날 때까지 첫 화면이 눈에 띄게 늦게 떴다.', 'SUBJECTIVE'),
       (5506, 887, '아래 코드의 ㉠에 들어갈 속성 이름은?', '회원 관리 화면에서 왼쪽 목록의 회원을 고르면 오른쪽 MemoEditor에 그 회원 앞으로 메모를 쓸 수 있다. StrictMode 없이 실행하며, 처음 코드는 아래와 같았다.

```tsx
function MemoEditor({ userId }: { userId: number }) {
  const [draft, setDraft] = useState("");
  const [expanded, setExpanded] = useState(false);

  useEffect(() => {
    setDraft("");
    setExpanded(false);
  }, [userId]);
  // ...
}

// 부모 컴포넌트
<MemoEditor userId={selectedId} />
```

3번 회원 메모를 쓰다가 7번 회원을 고르면 MemoEditor가 두 번 렌더됐고, 첫 번째 렌더의 draft에는 3번 회원에게 쓰던 글이 그대로 들어 있었다. 이후 MemoEditor의 이펙트를 통째로 지우고 부모 코드만 아래처럼 바꾸자, 회원을 바꿀 때 MemoEditor는 한 번만 렌더됐고 draft와 expanded는 처음부터 초기값이었다.

```tsx
<MemoEditor userId={selectedId} ㉠={selectedId} />
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5501
(14843, 5501, 'Settings 렌더: true → Toggle 렌더: true', '이펙트 안의 onChange 호출을 이벤트 핸들러 안의 호출처럼 본 오개념. 핸들러에서 setIsOn과 onChange를 함께 부르면 한 번에 처리돼 이렇게 찍히지만, 이펙트는 Toggle의 렌더와 커밋이 끝난 뒤에 실행되므로 Toggle 렌더가 먼저 찍힌다.', false),
(14844, 5501, 'Toggle 렌더: true → Settings 렌더: true → Toggle 렌더: true', '클릭으로 Toggle만 먼저 렌더·커밋되고, 그 뒤 실행된 이펙트가 onChange(true)로 부모 state를 바꿔 Settings와 자식 Toggle이 다시 렌더된다. 한 번의 변화가 렌더 두 차례로 나뉜 것이라, 핸들러에서 setIsOn과 onChange를 함께 부르면 한 차례로 줄어든다.', true),
(14845, 5501, 'Toggle 렌더: true → Settings 렌더: true', 'props가 그대로면 부모가 렌더돼도 자식은 건너뛴다고 본 오개념. memo로 감싸지 않은 자식은 부모가 렌더될 때 함께 렌더되므로, onChange가 같은 setEnabled여도 Toggle 렌더가 한 번 더 찍힌다.', false),
(14846, 5501, 'Toggle 렌더: true → Settings 렌더: true → Toggle 렌더: true → Settings 렌더: true', '렌더될 때마다 이펙트가 다시 실행된다고 본 오개념. 두 번째 Toggle 렌더에서는 isOn이 true 그대로이고 onChange도 같은 setEnabled라 의존성이 바뀌지 않으므로, 이펙트가 실행되지 않고 로그는 세 줄에서 멈춘다.', false),

-- 문제 5502
(14847, 5502, 'B로 바뀌면 A 연결이 끊기고 B에 새로 연결되며, ChatRoom이 사라질 때 B 연결도 끊긴다.', 'ref가 이펙트를 다시 실행할 때마다 초기화된다고 본 오개념. useRef 값은 컴포넌트가 화면에 있는 동안 유지되므로 connected.current는 true로 남고, 두 번째 실행은 첫 줄에서 바로 끝나 B에 연결하지 않는다.', false),
(14848, 5502, 'B로 바뀌어도 A 연결이 그대로 유지되다가, ChatRoom이 사라질 때에야 A 연결이 끊긴다.', '새 실행이 일찍 끝나면 이전 클린업도 건너뛴다고 본 오개념. React는 roomId가 바뀌면 새 실행이 무엇을 하든 그보다 먼저 이전 실행의 클린업을 부르므로, A 연결은 B로 바뀌는 시점에 끊긴다.', false),
(14849, 5502, 'B로 바뀌면 A 연결이 끊긴 뒤 B에는 연결되지 않아, ChatRoom이 사라질 때까지 어느 방에도 연결되지 않는다.', 'B로 바뀌면 A를 기억한 이전 클린업이 먼저 실행돼 연결이 끊기지만, connected.current가 이미 true라 새 실행은 연결 없이 끝난다. 실행 횟수를 막는 플래그가 재동기화까지 막은 것이므로, 플래그를 지우고 이펙트와 클린업이 짝을 이루게 둬야 한다.', true),
(14850, 5502, 'B로 바뀌면 A 연결이 끊기고, ChatRoom이 사라질 때 A의 클린업이 한 번 더 실행돼 disconnect가 다시 호출된다.', '클린업이 한 번 등록되면 다음 클린업으로 바뀔 때까지 남는다고 본 오개념. 클린업은 자신을 반환한 실행에 딸린 것이라 한 번만 쓰이고, 두 번째 실행은 아무것도 반환하지 않았으므로 사라질 때 부를 클린업이 없다.', false),

-- 문제 5503
(14851, 5503, '(가)', 'lecture.title과 speed는 props라 caption은 렌더 중에 곧바로 계산할 수 있는 값이다. 이펙트로 두면 낡은 caption으로 한 번 렌더된 뒤 setCaption으로 또 렌더되므로, const caption = ... 한 줄로 바꾸는 것이 맞다.', false),
(14852, 5503, '(나)', '좋아요 요청은 사용자가 버튼을 눌렀기 때문에 보내는 것이라 onClick 핸들러의 몫이다. 이펙트에 두면 liked가 true인 채 lecture.id만 바뀌어도, 누르지 않은 다른 강의에 좋아요 요청이 나간다.', false),
(14853, 5503, '(다)', '부모에게 음량 변화를 알리는 일은 슬라이더 onChange에서 setVolume과 onVolumeChange를 함께 부르면 된다. 이펙트로 알리면 자식이 먼저 렌더된 뒤 부모가 따로 다시 렌더돼 한 번의 변화가 렌더 두 차례로 나뉜다.', false),
(14854, 5503, '(라)', '부모가 정한 isPlaying 값에 맞춰 React 바깥에 있는 브라우저 video 요소의 재생 상태를 맞추는 동기화다. play()와 pause()는 렌더 중에 부를 수 없고 DOM이 반영된 뒤에 불러야 하므로 이펙트가 제자리다.', true),

-- 문제 5504
(14855, 5504, '방식 A로 목록, 상세, 목록 순서로 이동하면 목록으로 돌아올 때 요청이 다시 나가 로딩 화면이 한 번 더 보인다.', '방식 A는 응답을 목록 컴포넌트의 state에만 두므로 상세로 이동해 목록이 언마운트되면 데이터도 함께 사라진다. 돌아오면 목록이 새로 마운트돼 state가 초기값에서 시작하고 이펙트도 다시 실행되므로 로딩과 요청이 반복된다.', true),
(14856, 5504, '방식 A에서 이펙트의 의존성 배열을 []로 두면, 목록 화면을 떠났다 돌아와도 요청은 앱 전체에서 처음 한 번만 나간다.', '의존성 배열 []를 앱 전체에서 한 번이라는 뜻으로 본 오개념. []는 마운트될 때마다 한 번 실행된다는 뜻이라, 목록 컴포넌트가 언마운트됐다가 다시 마운트되면 이펙트도 다시 실행돼 요청이 또 나간다.', false),
(14857, 5504, '방식 A에서 검색어가 빠르게 바뀌면 fetch가 이전 요청을 스스로 취소하므로, ignore 플래그 없이도 낡은 응답은 반영되지 않는다.', 'fetch가 낡은 요청을 알아서 취소한다고 본 오개념. fetch는 이전 요청을 스스로 취소하지 않아 늦게 온 응답이 최신 결과를 덮어쓸 수 있으므로, 표처럼 클린업에서 ignore 플래그를 세워 낡은 응답을 직접 무시해야 한다.', false),
(14858, 5504, '방식 B로 바꾸면 이펙트가 하던 일을 라이브러리가 모두 맡으므로, 채팅 서버와의 웹소켓 연결에도 더는 useEffect가 필요 없다.', '서버 상태 라이브러리가 모든 이펙트를 대신한다고 본 오개념. 라이브러리가 맡는 것은 서버 데이터의 요청·캐시·재검증이고, 웹소켓처럼 외부 시스템과 연결을 맺고 끊는 동기화는 여전히 useEffect와 클린업으로 처리한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1790, 5505, 'useLayoutEffect,React.useLayoutEffect,useLayoutEffect(),유즈레이아웃이펙트,유즈 레이아웃 이펙트,레이아웃 이펙트,레이아웃이펙트,layout effect,layouteffect', 'useLayoutEffect는 커밋 단계에서 DOM 변경이 반영된 직후, 브라우저가 화면을 그리기 전에 동기로 실행된다. 그 안에서 너비를 재고 setFontSize를 부르면 React가 페인트 전에 다시 렌더하므로 사용자는 줄어든 최종 글자만 본다. 처음 쓴 useEffect는 페인트 뒤에 실행돼 넘친 첫 화면이 먼저 보인 것이다. 대신 이 훅이 끝날 때까지 화면 그리기가 멈추므로, 무거운 측정을 여러 곳에 걸면 카드 수백 개의 사례처럼 첫 화면이 늦어진다. 그래서 DOM을 재서 곧바로 위치나 크기를 고쳐야 하는 경우에만 쓰고, 구독·요청·로그처럼 화면 모양과 상관없는 동기화는 useEffect에 둔다. useLayoutEffect가 더 빨라서 좋은 훅이라고 여겨 모든 이펙트에 쓰면 오히려 성능이 나빠진다는 점에서 useEffect와 구분해야 한다.'),
       (1791, 5506, 'key,key prop,key props,key 속성,key 프롭,key 프롭스,키,키 속성', 'key는 React가 같은 자리에 그려지는 컴포넌트를 이전과 같은 것으로 볼지 판단하는 기준이다. key 값이 3에서 7로 바뀌면 React는 이전 MemoEditor를 언마운트하고 새 MemoEditor를 마운트하므로, 안의 state가 모두 useState의 초기값으로 새로 시작한다. 이펙트로 초기화할 때는 낡은 draft로 한 번 렌더한 뒤 setDraft로 다시 렌더해야 했지만, key를 바꾸면 처음부터 새 state로 한 번만 렌더된다. userId처럼 일반 props는 값을 바꿔 전달할 뿐 state를 지우지 않는다는 점에서 구분된다. 목록을 그릴 때 형제 항목을 구분하려고 붙이는 key와 같은 속성으로, props 변경에 맞춰 state를 통째로 되돌려야 할 때 이펙트 대신 쓰는 방법이다.');
