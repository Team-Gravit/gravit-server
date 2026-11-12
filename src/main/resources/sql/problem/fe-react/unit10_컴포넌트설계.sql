-- Unit: 컴포넌트 설계 (Unit ID: 150)
-- Chapter: React (Chapter ID: 13)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (576, 150, '컴파운드·헤드리스 컴포넌트와 제어 전환'),
       (734, 150, 'children 합성과 비제어 컴포넌트'),
       (892, 150, '컴포넌트 설계: 입력값의 소유자, 슬롯 합성, 분리·추출의 경계');

-- =====================================================
-- Lesson 576: 컴파운드·헤드리스 컴포넌트와 제어 전환
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3635, 576, '아래 코드가 택한 컴포넌트 재사용 방식에 대한 설명으로 옳은 것은?', '```tsx
class Dialog extends React.Component {
  renderBody() { return <p>기본 내용</p>; }
  render() {
    return (
      <section className="dialog">
        <h2>{this.props.title}</h2>
        {this.renderBody()}
      </section>
    );
  }
}

class WelcomeDialog extends Dialog {
  renderBody() { return <p>가입을 축하합니다.</p>; }
}

class SignupDialog extends WelcomeDialog {
  renderBody() {
    return (
      <>
        <p>가입을 축하합니다.</p>
        <SignupForm />
      </>
    );
  }
}
```', 'OBJECTIVE'),
       (3636, 576, '아래 코드에서 경고가 발생한 원인과 알맞은 수정으로 옳은 것은?', '```tsx
function SearchBox({ initial }: { initial?: string }) {
  const [q, setQ] = useState(initial);
  return <input value={q} onChange={(e) => setQ(e.target.value)} />;
}
```

- `<SearchBox initial="react" />`로 렌더하면 검색창에 아무리 입력해도 경고가 나지 않는다.
- `<SearchBox />`로 렌더한 뒤 검색창에 첫 글자를 입력하는 순간 콘솔에 경고가 찍힌다.', 'OBJECTIVE'),
       (3637, 576, '아래 코드에서 버튼을 누른 뒤 화면에 표시되는 A와 B의 값은?', '```tsx
function useCounter(step: number) {
  const [n, setN] = useState(0);
  return [n, () => setN((v) => v + step)] as const;
}

function Panel() {
  const [a, incA] = useCounter(1);
  const [b, incB] = useCounter(5);
  return (
    <>
      <button onClick={incA}>A: {a}</button>
      <button onClick={incB}>B: {b}</button>
    </>
  );
}
```

사용자가 A 버튼을 세 번 누른 뒤 B 버튼을 한 번 눌렀다.', 'OBJECTIVE'),
       (3638, 576, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 패턴 | 재사용 대상 | 사용 형태 | 로직이 컴포넌트로 들어오는 경로 |
| --- | --- | --- | --- |
| 고차 컴포넌트 | 로직 + props 주입 | `const Page = withAuth(Profile)` | 래퍼가 props로 넣어 준다 |
| 렌더 props | 로직 | `<Auth render={(user) => <Profile user={user} />} />` | 자식 함수의 인자로 받는다 |
| 커스텀 훅 | 로직(상태·이펙트) | `const user = useAuth()` | 컴포넌트 안에서 직접 호출한다 |', 'OBJECTIVE'),
       (3639, 576, '아래 개선 후 코드가 따르는 컴포넌트 설계 패턴의 이름은?', '```tsx
// 개선 전
<Tabs items={tabItems} showIcon iconPosition="left" tabAlign="center"
      panelPadding={16} triggerVariant="pill" onTabChange={handleChange} />

// 개선 후
<Tabs defaultValue="overview">
  <Tabs.List align="center">
    <Tabs.Trigger value="overview"><Icon /> 개요</Tabs.Trigger>
    <Tabs.Trigger value="detail">상세</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Panel value="overview"><Overview /></Tabs.Panel>
  <Tabs.Panel value="detail"><Detail /></Tabs.Panel>
</Tabs>
```

개선 전에는 디자인 요구가 하나 늘 때마다 Tabs의 props가 하나씩 붙어 열두 개까지 불어났다. 개선 후에는 아이콘 위치를 옮기거나 탭 사이에 구분선을 넣는 요구가 와도 Tabs의 props는 그대로 두고 화면 쪽에서 태그 배치만 고쳐 처리했다.', 'SUBJECTIVE'),
       (3640, 576, '아래와 같은 형태로 제공되는 UI 라이브러리 컴포넌트를 가리키는 용어는?', '```tsx
function BrandSelect({ items }) {
  const { getToggleProps, getMenuProps, getItemProps, isOpen, selected } = useSelect({ items });
  return (
    <div className="brand-select">
      <button {...getToggleProps()}>{selected ?? "선택하세요"}</button>
      <ul {...getMenuProps()} className="brand-menu">
        {isOpen && items.map((it, i) => (
          <li key={it} {...getItemProps({ item: it, index: i })} className="brand-item">{it}</li>
        ))}
      </ul>
    </div>
  );
}
```

이 라이브러리를 쓴 세 제품은 방향키 이동, ESC로 닫기, aria-activedescendant 갱신이 모두 똑같이 동작한다. 반면 화면에 그려지는 태그와 클래스 이름은 제품마다 다르고, 라이브러리 패키지에는 스타일 시트가 한 장도 들어 있지 않다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3635
(9867, 3635, '변형을 하나 추가할 때 계층을 늘리지 않고 새로운 조합을 만들면 된다.', '합성의 장점을 갖다 붙인 오개념이다. 위 코드는 변형이 하나 생길 때마다 Dialog 아래로 클래스 계층이 한 단계씩 깊어지고, 두 축으로 변형이 갈리면 어느 쪽을 물려받을지부터 막힌다.', false),
(9868, 3635, '재사용되는 부분이 props 인터페이스로만 드러나 부모의 내부 구현을 몰라도 쓸 수 있다.', 'props만 보고 쓸 수 있는 것은 조립하는 쪽의 성질이다. 여기서는 renderBody를 덮어쓰려면 부모의 render가 그 메서드를 언제 어디서 부르는지 먼저 읽어야 한다.', false),
(9869, 3635, '파생 클래스가 부모 render의 내부 구조에 기대고 있어, Dialog의 마크업을 고치면 아래 클래스들이 함께 깨진다.', 'renderBody를 부르는 위치와 감싸는 태그가 부모 render 안에 박혀 있어 결합도가 높다. 부모를 renderBody 대신 children을 그리도록 바꾸는 순간 두 파생 클래스가 덮어쓴 내용은 화면에서 사라진다.', true),
(9870, 3635, '함수 컴포넌트와 훅에서도 같은 방식으로 부모의 동작을 물려받아 쓸 수 있다.', '함수 컴포넌트에는 물려받을 클래스 계층이 없고 훅도 오버라이드 대상이 아니다. 함수 컴포넌트에서 같은 재사용을 하려면 감싸는 컴포넌트로 조립하거나 로직을 커스텀 훅으로 뺀다.', false),

-- 문제 3636
(9871, 3636, 'onChange가 빠져 React가 입력을 읽기 전용으로 본 것이다. onChange 핸들러를 달면 경고가 사라진다.', 'onChange는 이미 붙어 있다. 읽기 전용 경고는 value만 주고 onChange를 뺐을 때 나는 다른 경고이며, initial을 넘겼는지에 따라 경고가 갈리는 이 상황을 설명하지 못한다.', false),
(9872, 3636, 'input에 key가 없어 리렌더마다 DOM 노드가 새로 만들어진 것이다. 고유한 key를 지정하면 사라진다.', 'key는 목록에서 형제 노드를 구분할 때 쓰는 값이라 형제가 없는 단일 input에는 필요 없다. key는 오히려 비제어 입력의 값을 통째로 초기화하려고 일부러 바꿀 때 쓴다.', false),
(9873, 3636, 'setQ가 비동기라 value 반영이 한 박자 늦은 것이다. onChange에서 ref로 DOM 값을 직접 쓰면 된다.', '상태 갱신은 다음 렌더에 반영되지만 화면 값이 한 글자씩 밀리지는 않는다. ref로 DOM을 직접 쓰면 값의 소유자가 state와 DOM으로 갈라져 문제가 더 커진다.', false),
(9874, 3636, '첫 렌더의 value가 undefined라 비제어로 시작했다가 입력 뒤 제어로 바뀐 것이다. 초기값을 빈 문자열로 준다.', 'initial을 안 넘기면 useState(undefined)가 되어 첫 렌더의 value가 undefined다. React는 이를 비제어 입력으로 보고, 입력 후 문자열이 들어오면 전환 경고를 낸다. 초기값을 항상 정의된 값으로 주면 처음부터 제어 입력이다.', true),

-- 문제 3637
(9875, 3637, 'A: 3, B: 5', '한 컴포넌트가 useCounter를 두 번 불러도 호출마다 독립된 상태가 만들어진다. A는 step 1로 세 번 올라 3, B는 step 5로 한 번 올라 5가 된다.', true),
(9876, 3637, 'A: 8, B: 8', '커스텀 훅이 로직뿐 아니라 상태까지 공유한다고 본 오개념이다. 훅은 로직만 공유하고 상태는 호출한 자리마다 따로 생긴다. 값을 나눠 쓰려면 Context나 외부 스토어가 필요하다.', false),
(9877, 3637, 'A: 3, B: 1', '증가폭이 언제나 1이라고 본 것이다. 훅에 넘긴 step 인자가 setN 안의 v + step에 그대로 쓰이므로, B는 한 번만 눌러도 0에서 5로 올라간다.', false),
(9878, 3637, 'A: 1, B: 5', '리렌더될 때 useState가 초기값 0으로 되돌아간다고 본 오개념이다. useState의 인자는 첫 렌더에서만 쓰이고, 이후 렌더에서는 보관돼 있던 값이 그대로 나온다.', false),

-- 문제 3638
(9879, 3638, '세 패턴의 재사용 대상이 모두 로직이라, 같은 인증 로직을 셋 중 어느 형태로도 바꿔 표현할 수 있다.', '참이다. 표의 재사용 대상이 셋 다 로직이라 withAuth로 감싸든 render prop으로 넘기든 useAuth를 부르든 담기는 내용은 같다. 갈리는 것은 그 로직이 컴포넌트에 닿는 경로다.', false),
(9880, 3638, '커스텀 훅이 돌려준 값은 래퍼가 주입하는 것이라, 컴포넌트 코드만 봐서는 그 값의 출처를 알 수 없다.', '거짓이다. 래퍼가 props로 넣어 주는 것은 표에서 고차 컴포넌트의 경로다. 커스텀 훅은 컴포넌트 안에서 useAuth()를 직접 부르므로 값이 어디서 왔는지가 그 한 줄에 그대로 적혀 있다.', true),
(9881, 3638, '고차 컴포넌트를 여러 겹 쌓으면 컴포넌트 트리에 래퍼가 층층이 끼어 실제 컴포넌트를 찾기 번거로워진다.', '참이다. 표대로 고차 컴포넌트는 대상을 감싸므로 withAuth(withLogger(withTheme(Profile)))처럼 겹칠 때마다 트리에 노드가 하나씩 늘어난다. 이 래퍼 지옥이 훅에 자리를 내준 이유 중 하나다.', false),
(9882, 3638, '렌더 props는 로직을 자식 함수의 인자로 받으므로, 여러 로직을 겹치면 JSX 안에 함수가 중첩된다.', '참이다. 표대로 값이 자식 함수의 인자로 오기 때문에 로직을 두세 개 쓰면 render prop 안에 다시 render prop이 들어가 들여쓰기가 깊어진다. 훅은 같은 일을 나란한 호출 줄로 적는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1168, 3639, '컴파운드 컴포넌트,컴파운드 컴포넌트 패턴,컴파운드 패턴,컴파운드,합성 컴포넌트,compound component,compound components,compound component pattern,compound', 'Tabs와 Tabs.List, Tabs.Trigger, Tabs.Panel처럼 서로 관련된 컴포넌트를 한 이름 아래 묶어 두고, 쓰는 쪽이 태그를 조립해 구조를 정하게 하는 방식이 컴파운드 컴포넌트다. 선택된 탭 값 같은 내부 상태는 Tabs가 Context로 자식들에게 내려 주므로 사용자가 값을 일일이 이어 줄 필요가 없다. 개선 전처럼 모든 변형을 props로 받으면 조합이 늘어날 때마다 props가 함께 불어난다. 재사용 대상으로 구분하면 이 패턴이 재사용하는 것은 UI 구조다. 로직(상태·이펙트)을 재사용하는 커스텀 훅, 컴포넌트를 감싸 props를 주입하는 고차 컴포넌트와 헷갈리지 않게 한다.'),
       (1169, 3640, '헤드리스 컴포넌트,헤드리스,헤드리스 UI,헤드리스 컴포넌트 패턴,headless component,headless components,headless,headless ui', '동작과 접근성 처리만 훅으로 내주고 마크업과 스타일은 쓰는 쪽이 정하는 컴포넌트를 헤드리스 컴포넌트라고 한다. getToggleProps처럼 해당 요소에 펴 넣을 속성 묶음만 돌려주기 때문에, 세 제품이 방향키 이동과 ARIA 속성 갱신을 똑같이 가져가면서도 태그와 클래스는 제각각일 수 있다. Radix UI, Headless UI, Downshift가 이 방식이다. 구조까지 정해 주는 컴파운드 컴포넌트와 구분한다 — 컴파운드는 Tabs.List 같은 태그를 제공하지만 헤드리스는 태그를 아예 주지 않는다. 스타일 시트를 함께 내려보내는 일반 UI 컴포넌트 라이브러리와도 다르다.');

-- =====================================================
-- Lesson 734: children 합성과 비제어 컴포넌트
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4583, 734, '아래 코드에서 두 패널의 토글 버튼을 각각 세 번씩 누르는 동안 새로 찍힌 로그 수는?', '```tsx
function ExpensiveTree({ name }: { name: string }) {
  console.log(`${name} 렌더`);
  return <div>{/* 노드 수천 개 */}</div>;
}

function PanelA() {
  const [open, setOpen] = useState(false);
  return (
    <section>
      <button onClick={() => setOpen((o) => !o)}>토글</button>
      {open && <p>상세 설명</p>}
      <ExpensiveTree name="A" />
    </section>
  );
}

function PanelB({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  return (
    <section>
      <button onClick={() => setOpen((o) => !o)}>토글</button>
      {open && <p>상세 설명</p>}
      {children}
    </section>
  );
}

function App() {
  return (
    <>
      <PanelA />
      <PanelB>
        <ExpensiveTree name="B" />
      </PanelB>
    </>
  );
}
```

- 첫 렌더가 끝난 뒤 콘솔을 비우고 나서 버튼을 눌렀다.
- StrictMode와 React.memo는 쓰지 않았다.', 'OBJECTIVE'),
       (4584, 734, '아래 코드 리뷰 상황에 컴포넌트 분리 기준을 적용한 판단으로 옳은 것은?', '코드 리뷰에 두 컴포넌트가 올라왔다.

- `OrderTable` (110줄): props로 받은 주문 배열을 표 한 장으로 그리기만 한다. 자체 상태나 이펙트는 없고, 주문 내역 화면 한 곳에서만 쓴다.
- `PriceTicker` (22줄): `useState`로 시세를 들고, `useEffect`에서 웹소켓을 구독·해제하며, 등락에 따라 글자색을 바꿔 보여 준다.

리뷰 도중 `PriceChart` 컴포넌트에도 `PriceTicker`와 똑같은 `useState`+`useEffect` 구독 코드가 복사돼 있다는 사실이 드러났다.', 'OBJECTIVE'),
       (4585, 734, '아래 코드에서 화면 1과 화면 2의 B 탭 버튼을 각각 한 번 누른 뒤 표시되는 선택 값은?', '```tsx
function useControllableState<T>(
  value: T | undefined,
  defaultValue: T,
  onChange?: (v: T) => void,
) {
  const [internal, setInternal] = useState(defaultValue);
  const isControlled = value !== undefined;
  const current = isControlled ? value : internal;
  const set = (next: T) => {
    if (!isControlled) setInternal(next);
    onChange?.(next);
  };
  return [current, set] as const;
}

function Tabs({ value, defaultValue = "a", onChange }: TabsProps) {
  const [active, setActive] = useControllableState(value, defaultValue, onChange);
  return (
    <div>
      <button onClick={() => setActive("b")}>B 탭</button>
      <p>선택: {active}</p>
    </div>
  );
}

// 화면 1
<Tabs value="a" onChange={(v) => console.log(v)} />

// 화면 2
<Tabs defaultValue="a" onChange={(v) => console.log(v)} />
```', 'OBJECTIVE'),
       (4586, 734, '아래 코드와 린트 결과에 대한 판단으로 옳은 것은?', '```tsx
function useFormatPrice(amount: number) {
  return amount.toLocaleString("ko-KR") + "원";
}

function CartList({ items }: { items: CartItem[] }) {
  return (
    <ul>
      {items.map((it) => (
        <li key={it.id}>
          {it.name} · {useFormatPrice(it.price)}
        </li>
      ))}
    </ul>
  );
}
```

```
src/CartList.tsx
  10:24  error  React Hook "useFormatPrice" cannot be called inside a callback. React Hooks must be called in a React function component or a custom React Hook function  react-hooks/rules-of-hooks
```', 'OBJECTIVE'),
       (4587, 734, '아래 상황에서 Profile에 인증·로그·테마 기능을 붙이는 데 쓴 패턴의 이름은?', '`Profile.tsx`의 마지막 줄은 다음과 같다.

```tsx
export default withAuth(withLogger(withTheme(Profile)));
```

React DevTools의 컴포넌트 트리는 아래처럼 보인다.

```
▾ WithAuth(WithLogger(WithTheme(Profile)))
  ▾ WithLogger(WithTheme(Profile))
    ▾ WithTheme(Profile)
        Profile  props: { userId, user, log, theme }
```

- `Profile` 함수 안에는 `user`·`log`·`theme`를 만드는 코드가 한 줄도 없다. `log`가 어디서 오는지 알아내려고 파일 세 개를 차례로 열어 봐야 했다.
- 관리자 화면에서 `export function Profile`로 함께 내보낸 원본을 그대로 가져다 쓰자 `user`가 `undefined`로 들어와 첫 렌더에서 오류가 났다.', 'SUBJECTIVE'),
       (4588, 734, '아래 상황에서 팀이 입력칸을 바꾼 방식을 가리키는 용어는?', '입력칸이 180개인 설문 폼에서 글자 하나를 칠 때마다 React Profiler에 폼 전체 렌더가 기록됐고, 키 입력 한 번을 처리하는 데 평균 42ms가 걸려 타이핑이 끊겼다. 팀은 입력칸마다 걸려 있던 상태 갱신 코드를 모두 걷어 내고, 제출 버튼을 누를 때 `new FormData(form)`으로 한 번에 모아 서버에 보내도록 바꿨다.

| 항목 | 바꾸기 전 | 바꾼 뒤 |
| --- | --- | --- |
| 타이핑 중 폼 렌더 | 키 입력마다 1회 (42ms) | 0회 |
| 휴대폰 번호를 치는 즉시 하이픈 넣기 | 됨 | 안 됨 |
| 비밀번호 확인이 일치할 때만 가입 버튼 켜기 | 됨 | 안 됨 |
| 다른 설문을 불러올 때 입력칸 비우기 | 상태를 빈 값으로 설정 | 폼의 `key`를 설문 id로 바꿔야 함 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4583
(12395, 4583, 'A 렌더 3회, B 렌더 3회', 'children도 PanelB 안에서 그려지니 PanelB와 함께 다시 렌더된다고 본 오개념이다. B 엘리먼트는 App이 만들어 넘긴 것이라 PanelB가 다시 렌더돼도 같은 참조가 그대로 들어오고, React는 그 아래를 건너뛴다.', false),
(12396, 4583, 'A 렌더 3회, B 렌더 0회', 'PanelA는 렌더할 때마다 A 엘리먼트를 새로 만들어 세 번 모두 다시 그린다. B 엘리먼트는 상태가 없어 다시 렌더되지 않는 App이 만들어 children으로 넘긴 것이라 참조가 그대로여서 React가 건너뛴다. 합성이 렌더 범위까지 좁혀 준 셈이다.', true),
(12397, 4583, 'A 렌더 0회, B 렌더 0회', 'props 값이 그대로면 React가 알아서 렌더를 건너뛴다고 본 오개념이다. React.memo가 없으면 부모가 다시 렌더될 때 새로 만든 자식 엘리먼트는 props 값이 같아도 다시 그려지므로 A는 세 번 찍힌다.', false),
(12398, 4583, 'A 렌더 0회, B 렌더 3회', '직접 쓴 자식은 고정되고 children으로 받은 쪽이 매번 새로 만들어진다고 거꾸로 이해한 것이다. 엘리먼트는 그 JSX를 쓴 컴포넌트가 렌더될 때 만들어지므로, 매번 새로 만들어지는 쪽은 PanelA 안의 A다.', false),

-- 문제 4584
(12399, 4584, 'OrderTable은 100줄을 넘으니 헤더와 행 컴포넌트로 쪼개고, PriceTicker는 22줄로 짧으니 그대로 둔다.', '분리 기준을 줄 수로 본 오개념이다. OrderTable은 길어도 표를 그리는 한 가지 일만 하니 괜찮고, PriceTicker는 짧아도 구독·상태·표시가 한데 섞여 있어 손볼 대상이다.', false),
(12400, 4584, 'PriceChart 안에 PriceTicker를 렌더해 두면, 복사한 구독 코드 없이도 PriceChart가 시세 값을 받아 쓸 수 있다.', 'UI 재사용과 로직 재사용을 혼동했다. 자식으로 그린 PriceTicker의 상태는 그 안에 갇혀 부모인 PriceChart로 올라오지 않는다. 시세를 얻는 동작을 나눠 쓰려면 그 로직을 따로 떼어 내야 한다.', false),
(12401, 4584, 'OrderTable은 한 곳에서만 쓰여 재사용 기준에 걸리지 않으므로, 부모 화면의 JSX 안에 도로 풀어 넣는다.', '재사용만을 분리 기준으로 본 것이다. 110줄짜리 표에 OrderTable이라는 이름이 붙어 있으면 부모 화면의 JSX가 읽기 쉬워지므로, 한 곳에서만 써도 가독성 기준으로 분리해 둘 이유가 충분하다.', false),
(12402, 4584, 'OrderTable은 길어도 그대로 두고, PriceTicker의 구독·해제 로직은 커스텀 훅으로 옮겨 PriceChart와 함께 쓴다.', '분리 기준은 줄 수가 아니라 책임이다. 같은 상태+이펙트 조합이 두 컴포넌트에 반복되고 웹소켓 연동이 컴포넌트에 드러나 있으니 useStockPrice 같은 훅으로 옮기고, 두 컴포넌트에는 표시만 남긴다.', true),

-- 문제 4585
(12403, 4585, '화면 1: a, 화면 2: b', '화면 1은 value가 주어져 isControlled가 true라 setInternal을 건너뛰고 onChange로 b를 알리기만 한다. 값의 소유자인 부모가 value를 바꾸지 않으니 a가 남는다. 화면 2는 value가 undefined라 내부 상태가 b로 바뀌어 다시 렌더된다.', true),
(12404, 4585, '화면 1: b, 화면 2: b', '누르면 어느 쪽이든 내부 상태가 바뀐다고 본 오개념이다. 제어 모드에서는 setInternal을 건너뛰고 onChange만 부르므로, 값의 소유자인 부모가 value를 b로 바꿔 넘겨야 화면이 바뀐다.', false),
(12405, 4585, '화면 1: a, 화면 2: a', 'defaultValue도 value처럼 화면 값을 계속 붙잡아 둔다고 본 오개념이다. defaultValue는 useState의 첫 값으로만 쓰이고, 이후에는 setInternal로 바뀐 내부 상태가 표시된다.', false),
(12406, 4585, '화면 1: b, 화면 2: a', 'value를 첫 값, defaultValue를 고정값으로 뒤바꿔 이해한 것이다. 코드에서 value가 주어지면 current는 늘 value를 따르고, defaultValue는 내부 상태의 첫 값일 뿐이다.', false),

-- 문제 4586
(12407, 4586, 'use로 시작하는 함수는 호출될 때마다 React가 상태 칸을 하나씩 잡으므로, 목록 안에서 부르면 실행 중 상태가 뒤섞인다.', '이름이 상태를 만든다고 본 오개념이다. React 런타임은 함수 이름을 보고 상태를 만들지 않는다. 린트 규칙이 use 접두사를 보고 훅으로 취급할 뿐, 이 함수는 상태를 하나도 만들지 않는다.', false),
(12408, 4586, '커스텀 훅은 한 컴포넌트에서 한 번만 부를 수 있어, 상품 수만큼 쓰려면 항목마다 훅을 따로 만들어야 한다.', '훅 규칙은 호출 횟수가 아니라 호출 위치를 제한한다. 최상위에서 매 렌더 같은 순서로 부르면 같은 훅을 여러 번 불러도 되고, 부를 때마다 독립된 상태가 생긴다.', false),
(12409, 4586, '안에서 훅을 부르지 않는 계산이라 formatPrice라는 일반 함수로 바꾸면 콜백 안에서도 규칙 위반 없이 부를 수 있다.', 'use 접두사는 훅의 규칙을 적용받게 만드는 표시다. 이 함수는 순수 계산이라 훅일 이유가 없고, 이름만 바꾸면 반복문·조건문 어디서든 부를 수 있다. 접두사가 이득 없이 제약만 만든 경우다.', true),
(12410, 4586, 'useFormatPrice 본문을 useMemo로 감싸 결과를 기억하게 하면, 콜백 안에서 호출해도 오류가 사라진다.', 'useMemo도 훅이라 최상위에서만 부를 수 있다. 감싸면 이름뿐이던 훅이 실제로 훅을 부르게 되어, 콜백 안 호출은 목록 길이가 바뀔 때 훅 순서가 어긋나는 진짜 버그가 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1484, 4587, '고차 컴포넌트,고차컴포넌트,고차 컴포넌트 패턴,HOC,HOCs,HOC 패턴,higher-order component,higher order component,higher-order components,higher order components,higher-order component pattern,하이어 오더 컴포넌트', 'withAuth(Profile)처럼 컴포넌트를 인자로 받아 props를 주입한 새 컴포넌트를 돌려주는 방식이 고차 컴포넌트(HOC)다. 겹쳐 쓸 때마다 트리에 래퍼가 한 층씩 늘어나고(래퍼 지옥), 주입된 props는 컴포넌트 코드에 드러나지 않아 출처를 찾기 어렵다. 원본 컴포넌트는 주입을 전제로 짜여 있어서 감싸지 않고 쓰면 본문처럼 값이 비어 오류가 난다. 지금은 같은 로직 재사용을 컴포넌트 안에서 useAuth()처럼 직접 부르는 커스텀 훅으로 표현해, 값의 출처가 호출한 줄에 그대로 드러나게 한다. 자식 함수의 인자로 값을 받는 렌더 props, UI 구조를 묶어 조립하게 하는 컴파운드 컴포넌트와도 구분한다.'),
       (1485, 4588, '비제어 컴포넌트,비제어,비제어 입력,비제어 폼,비제어형 컴포넌트,비제어 방식,uncontrolled component,uncontrolled components,uncontrolled,uncontrolled input,uncontrolled form,언컨트롤드 컴포넌트', '입력값을 React 상태에 두지 않고 DOM이 들고 있게 한 뒤, 필요할 때 FormData나 ref로 읽는 방식이 비제어 컴포넌트다. 키 입력이 상태를 바꾸지 않으니 렌더가 일어나지 않아 대규모 폼의 성능 문제가 풀린다. 대신 입력하는 순간 값을 가로챌 수 없어 즉시 포맷팅·검증이나 여러 칸의 연동이 어렵고, 밖에서 값을 초기화하려면 key를 바꿔 다시 마운트하거나 ref로 직접 조작해야 한다. 값을 부모 상태가 소유하고 value와 onChange로 주고받는 제어 컴포넌트와 반대이며, 하이픈 자동 삽입이나 버튼 연동이 필요한 칸만 제어로 남기는 식으로 섞어 쓸 수도 있다.');

-- =====================================================
-- Lesson 892: 컴포넌트 설계: 입력값의 소유자, 슬롯 합성, 분리·추출의 경계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5531, 892, '아래 코드의 두 입력칸에 같은 글자를 차례로 입력한 뒤 각 입력칸에 보이는 값은?', '```tsx
function PhoneFields() {
  const [a, setA] = useState("");
  const [b, setB] = useState("");
  const onlyDigits = (s: string) => s.replace(/\D/g, "");

  return (
    <>
      <input value={a} onChange={(e) => setA(onlyDigits(e.target.value))} />
      <input defaultValue="" onChange={(e) => setB(onlyDigits(e.target.value))} />
    </>
  );
}
```

사용자가 첫 번째 입력칸(A)과 두 번째 입력칸(B)에 각각 `0`, `1`, `0`, `-`, `1`을 차례로 입력했다.', 'OBJECTIVE'),
       (5532, 892, '아래 코드에서 roomId가 바뀐 뒤까지 콘솔에 찍힌 로그 전체로 옳은 것은?', '```tsx
function useMount(effect: () => void | (() => void)) {
  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => effect(), []);
}

function ChatRoom({ roomId }: { roomId: string }) {
  useMount(() => {
    const conn = createConnection(roomId);
    conn.connect();
    return () => conn.disconnect();
  });
  return <h1>{roomId} 방</h1>;
}
```

- `createConnection(id)`가 돌려준 객체의 `connect()`는 `연결: {id}`, `disconnect()`는 `해제: {id}`를 콘솔에 찍는다.
- `<ChatRoom roomId="general" />`로 처음 렌더한 뒤, 사용자가 방 목록에서 travel을 눌러 roomId가 `"travel"`로 바뀌었다. 화면 제목은 `travel 방`으로 바뀌었다.
- ChatRoom 파일에는 린트 경고가 하나도 없다. StrictMode는 쓰지 않는다.', 'OBJECTIVE'),
       (5533, 892, '아래 새 요구를 구현하는 방법에 대한 판단으로 옳은 것은?', '```tsx
function PageLayout({ sidebar, children }: {
  sidebar: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="page">
      <aside>{sidebar}</aside>
      <main>{children}</main>
    </div>
  );
}

function OrdersPage() {
  return (
    <PageLayout sidebar={<OrderFilter />}>
      <OrderList />
    </PageLayout>
  );
}
```

- 새 요구: 사이드바의 OrderFilter에서 고른 주문 상태(결제 완료·배송 중)에 맞춰, 본문의 OrderList가 목록을 걸러 보여 줘야 한다.
- PageLayout은 다른 화면 열두 곳에서도 쓰고 있다.', 'OBJECTIVE'),
       (5534, 892, '아래 표의 조각들에 컴포넌트 분리 기준을 적용한 판단으로 옳은 것은?', '쇼핑몰 프론트엔드 코드에서 컴포넌트로 뺄지 검토 중인 JSX 조각 네 개다.

| 조각 | 쓰는 곳 | 자체 state·이펙트 | 모양 |
| --- | --- | --- | --- |
| 가. 가격 문구 | 주문 확인 화면 1곳 | 없음 | `<span>{price.toLocaleString()}원</span>` 한 줄 |
| 나. 품절 배지 | 상품 목록·검색 결과·찜 목록 3곳 | 없음 | 5줄. 세 화면에 같은 마크업이 복사돼 있음 |
| 다. 남은 시간 표시 | 홈 화면 이벤트 배너 1곳 | 있음. HomePage 안의 `useState`+`setInterval`로 1초마다 갱신 | 12줄 |
| 라. 배송지 입력 영역 | 결제 화면 1곳 | 없음 | 90줄. 결제 화면 JSX 한가운데 끼어 있어 앞뒤 영역의 경계가 잘 안 보임 |', 'OBJECTIVE'),
       (5535, 892, '아래 코드에서 CurrentUser·WindowSize·MousePosition 컴포넌트가 따르는 설계 패턴의 이름은?', '```tsx
function Dashboard() {
  return (
    <CurrentUser>
      {(user) => (
        <WindowSize>
          {(size) => (
            <MousePosition>
              {(pos) => <Chart user={user} width={size.width} cursor={pos} />}
            </MousePosition>
          )}
        </WindowSize>
      )}
    </CurrentUser>
  );
}
```

- 창 너비가 바뀔 때마다 로그를 남기려고 Dashboard 맨 위에 `useEffect(() => log(size.width), [size.width]);`를 넣자 `Cannot find name ''size''.` 오류가 났다. 결국 로그만 찍는 컴포넌트를 하나 더 만들어 `(size) => ...` 함수 안쪽에 끼워 넣었다.
- 나중에 세 로직을 각각 같은 일을 하는 훅으로 옮기자 `const user = useCurrentUser();`처럼 나란한 호출 세 줄이 되었고, 층층이 깊어지던 들여쓰기가 사라졌다.', 'SUBJECTIVE'),
       (5536, 892, '아래 상황에서 개발자가 ProfileForm에 추가한 prop의 이름은?', '```tsx
function MemberAdmin() {
  const [selected, setSelected] = useState<Member>(members[0]);
  return (
    <>
      <MemberList onSelect={setSelected} />
      <ProfileForm member={selected} />
    </>
  );
}

function ProfileForm({ member }: { member: Member }) {
  const [name, setName] = useState(member.name);
  const [email, setEmail] = useState(member.email);
  useEffect(() => {
    console.log("폼 마운트");
  }, []);
  return (
    <form>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
    </form>
  );
}
```

- 처음에는 `members[0]`인 김하나가 선택돼 있었다. 목록에서 이두리를 누르자 React DevTools에서 ProfileForm의 `member`는 이두리로 바뀌었지만, 입력칸에는 김하나의 이름과 이메일이 그대로 남아 있었다. `폼 마운트`는 처음 한 번만 찍혔다.
- 개발자는 ProfileForm 코드는 건드리지 않고, MemberAdmin의 `<ProfileForm>`에 prop 하나를 `selected.id` 값으로 추가했다.
- 그 뒤로는 다른 회원을 누를 때마다 `폼 마운트`가 새로 찍히고 입력칸이 그 회원의 값으로 채워졌다. 고치던 내용은 회원을 바꾸는 순간 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5531
(14923, 5531, 'A: 0101, B: 0101', 'B도 onChange에서 숫자만 남긴 값을 state에 넣으니 화면도 따라간다고 본 오개념이다. B는 value를 받지 않아 입력값의 주인이 DOM이다. state b는 0101이 되지만 입력칸에는 사용자가 친 010-1이 그대로 남는다.', false),
(14924, 5531, 'A: 010-1, B: 010-1', 'onChange는 입력을 알려 줄 뿐 화면 값은 바꾸지 못한다고 본 오개념이다. A는 value={a}로 React state가 값을 쥐고 있어, 하이픈이 들어온 순간에도 걸러 낸 010이 입력칸에 다시 반영된다.', false),
(14925, 5531, 'A: 0101, B: 010-1', 'A는 value가 state라 onChange에서 걸러 낸 값만 화면에 남고, 하이픈을 친 순간 010으로 되돌아간다. B는 defaultValue만 있어 DOM이 값을 쥐므로 친 글자가 그대로 보인다. 입력 즉시 포맷팅하려면 제어 방식이어야 하는 이유다.', true),
(14926, 5531, 'A: 010-1, B: 0101', '두 방식의 값 소유자를 뒤바꿔 이해한 것이다. defaultValue는 입력칸의 첫 값만 정할 뿐 이후 입력을 가로채지 못한다. 매 입력마다 화면 값을 정하는 쪽은 value를 받은 A다.', false),

-- 문제 5532
(14927, 5532, '연결: general', 'useMount 안의 이펙트는 의존성이 []로 고정돼 마운트 때 한 번만 돈다. 호출 쪽이 roomId를 써도 린트는 useMount 인자를 검사하지 못해 경고가 없고, 제목만 travel로 바뀐 채 연결은 general에 남는다. useEffect에 [roomId]를 직접 적어야 한다.', true),
(14928, 5532, '연결: general → 해제: general → 연결: travel', '이펙트 안에서 쓴 값이 바뀌면 알아서 다시 동기화된다고 본 오개념이다. 그렇게 되려면 의존성 배열에 roomId가 있어야 하는데, useMount가 []를 박아 두고 린트까지 꺼 두어 그 연결이 끊겼다.', false),
(14929, 5532, '연결: general → 연결: travel', '이펙트가 렌더마다 다시 돌되 정리는 건너뛴다고 본 오개념이다. 의존성이 []면 재실행 자체가 없고, 다시 돈다 해도 React는 새 이펙트를 돌리기 전에 이전 정리 함수부터 부른다.', false),
(14930, 5532, '연결: general → 해제: general', 'props가 바뀌면 컴포넌트가 언마운트된다고 본 오개념이다. 같은 자리에 같은 타입이 그려지면 인스턴스는 유지되고 props만 새로 들어오므로 정리 함수가 불리지 않는다.', false),

-- 문제 5533
(14931, 5533, 'PageLayout에 filter·onFilterChange props를 추가해, aside와 main 쪽으로 값을 각각 중계해야 한다.', '엘리먼트를 만드는 곳을 PageLayout으로 착각한 것이다. OrderFilter·OrderList 엘리먼트는 OrdersPage가 만들어 넘기므로 값을 주는 일도 거기서 끝난다. 중계 props를 넣으면 열두 화면이 쓰는 틀이 주문 화면에 묶인다.', false),
(14932, 5533, 'OrdersPage에 필터 state를 두고 두 엘리먼트를 만들 때 props로 넘기면, PageLayout 코드는 고칠 필요가 없다.', 'PageLayout은 받은 엘리먼트를 제자리에 놓기만 할 뿐 그 내용을 모른다. 두 엘리먼트를 만드는 OrdersPage가 state를 쥐고 OrderFilter에는 값과 변경 함수를, OrderList에는 거를 조건을 바로 넘기면 된다. 틀은 슬롯 props에만 의존한다.', true),
(14933, 5533, '두 엘리먼트가 PageLayout 안에 그려지므로, PageLayout이 받은 엘리먼트를 복제해 필터 값을 끼워 넣어야 한다.', '그려지는 위치가 곧 값을 줘야 하는 쪽이라고 본 오개념이다. 틀이 자식의 props를 몰래 고치면 틀과 내용이 서로의 구현에 묶여, 합성이 주는 낮은 결합도를 스스로 버리게 된다.', false),
(14934, 5533, 'OrderFilter는 PageLayout 안에서 렌더되므로, OrdersPage의 setState를 props로 받아도 호출할 수 없다.', '렌더되는 위치가 쓸 수 있는 값을 정한다고 본 오개념이다. 엘리먼트의 props는 만든 곳에서 정해지므로, OrdersPage가 넘긴 setState는 OrderFilter가 어디에 그려지든 그대로 부를 수 있다.', false),

-- 문제 5534
(14935, 5534, '나는 컴포넌트로 빼지 않고 세 화면에 적힌 그대로 둔다.', '분리 기준을 줄 수로 본 오개념이다. 5줄로 짧아도 같은 구조가 세 곳에서 반복되니 재사용 기준에 걸린다. 그대로 두면 배지 모양이 바뀔 때 세 군데를 따로 고쳐야 하고 한 곳을 빠뜨리기 쉽다.', false),
(14936, 5534, '다는 컴포넌트로 빼지 않고 지금처럼 HomePage 안에 둔다.', '재사용만을 분리 기준으로 본 것이다. 다는 자체 state와 이펙트를 가져 따로 빼야 한다. 지금은 1초마다 HomePage 전체가 리렌더되지만, 떼어 내면 매초 리렌더되는 범위가 남은 시간 표시로 좁혀진다.', false),
(14937, 5534, '라는 컴포넌트로 빼지 않고 결제 화면 JSX 안에 그대로 둔다.', '재사용과 state만 보고 가독성 기준을 빠뜨렸다. ShippingAddressSection 같은 이름을 붙여 빼면 결제 화면 JSX가 영역 단위로 읽힌다. 기준은 줄 수가 아니라 책임이라, 이름 붙일 만한 책임이면 한 곳에서만 써도 뺀다.', false),
(14938, 5534, '가는 컴포넌트로 빼지 않고 주문 확인 화면의 그 자리에 둔다.', '두 곳 이상에서 쓰지도, 자체 state를 갖지도 않고, 이름을 붙여도 한 줄짜리 JSX보다 읽기 쉬워지지 않는다. 이런 조각까지 빼면 파일과 props만 늘어나는 과도한 추상화가 된다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1800, 5535, '렌더 props,렌더 프롭스,렌더 프롭,렌더프롭스,렌더프롭,렌더 prop,렌더 props 패턴,렌더 프롭스 패턴,render props,render prop,render-props,render-prop,renderprops,render props pattern,function as children,function as child,children as a function,FaCC,함수 자식', 'CurrentUser처럼 로직(현재 사용자·창 크기·마우스 위치를 얻고 갱신하는 일)은 컴포넌트가 맡고, 그 결과 값만 함수의 인자로 넘겨 무엇을 그릴지는 함수를 넘긴 쪽이 정하게 하는 방식이 렌더 props다. 함수를 render라는 prop으로 받든 본문처럼 children으로 받든 같은 패턴이다. 값이 JSX 안쪽 함수의 인자로만 들어오므로 로직을 여럿 겹치면 들여쓰기가 층층이 깊어지고, 컴포넌트 본문의 이펙트나 이벤트 처리에서는 그 값을 쓸 수 없어 본문처럼 컴포넌트를 하나 더 만들게 된다. 훅 이전에 로직을 나눠 쓰던 방식이라 지금은 컴포넌트 안에서 직접 부르는 커스텀 훅이 같은 일을 대신한다. 컴포넌트를 감싸 props를 넣어 주는 고차 컴포넌트(HOC)와는 값이 들어오는 경로가 다르고(래퍼의 props 주입 vs 자식 함수의 인자), UI 구조를 묶어 쓰는 쪽이 조립하게 하는 컴파운드 컴포넌트와도 구분한다.'),
       (1801, 5536, 'key,키,key prop,key props,key 속성,키 속성,key 프롭,key={selected.id},key=selected.id', 'key는 React가 같은 자리에 그려지는 컴포넌트를 이전과 같은 것으로 볼지 가르는 값이다. key가 바뀌면 React는 이전 ProfileForm을 언마운트하고 새로 마운트하므로, 빈 의존성의 이펙트가 다시 돌아 폼 마운트가 찍히고 useState도 새 member 값으로 다시 초기화된다. key 없이 props만 바뀌면 인스턴스가 그대로 유지돼 useState의 인자는 무시되고, 처음 받은 김하나의 값이 state에 남는다. 부모 입장에서 ProfileForm은 입력값을 자기 안에 쥐는 비제어 컴포넌트라, 밖에서 값을 초기화하려면 이렇게 key를 바꿔 다시 마운트시킨다. 값의 소유자를 부모 state로 옮겨 value와 onChange를 내려 주는 제어 컴포넌트로 바꾸면 부모가 setState로 값을 갈아 끼울 수 있지만, 그러려면 ProfileForm 코드를 고쳐야 한다. 목록에서 형제 항목을 구분하려고 붙이는 key와 같은 prop이며, 목록이 아닌 단일 컴포넌트에서도 인스턴스를 새로 만드는 데 쓸 수 있다.');
