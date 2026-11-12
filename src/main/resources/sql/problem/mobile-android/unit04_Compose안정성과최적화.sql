-- Unit: Compose 안정성과 최적화 (Unit ID: 170)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (596, 170, '안정성 계약과 Strong Skipping'),
       (754, 170, '역방향 쓰기와 derivedStateOf'),
       (912, 170, 'Compose 최적화 점검: 안정성 추론·상태 읽기 지연·측정 기준');

-- =====================================================
-- Lesson 596: 안정성 계약과 Strong Skipping
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3755, 596, '아래 코드에서 버튼을 눌러 Screen이 재구성될 때 ProductList에서 일어나는 일로 옳은 것은?', '프로젝트는 Compose 컴파일러 1.5.x를 쓰고 있으며 Strong Skipping 모드는 꺼져 있다.

```kotlin
data class Product(val name: String, val price: Int)

@Composable
fun ProductList(products: List<Product>) { /* 항목 렌더링 */ }

@Composable
fun Screen() {
    var count by remember { mutableStateOf(0) }
    val products = remember { listOf(Product("연필", 1000)) }
    Button(onClick = { count++ }) { Text("$count") }
    ProductList(products)
}
```', 'OBJECTIVE'),
       (3756, 596, '아래 코드를 실행했을 때 나타날 수 있는 문제로 옳은 것은?', '```kotlin
@Immutable
data class Filter(val tags: MutableList<String>)

@Composable
fun FilterChips(filter: Filter) {
    Row { filter.tags.forEach { Chip(it) } }
}

@Composable
fun SearchScreen() {
    val filter = remember { Filter(mutableListOf("전체")) }
    Button(onClick = { filter.tags.add("신상") }) { Text("태그 추가") }
    FilterChips(filter)
}
```', 'OBJECTIVE'),
       (3757, 596, '아래 측정표에 대한 설명으로 옳지 않은 것은?', '같은 화면의 TopBar를 세 가지로 바꿔 3초 동안 목록을 스크롤하며 Layout Inspector로 재구성 횟수를 셌다. count는 1초에 한 번 증가하는 상태 값이다.

| 구현 | 입력이 바뀌는 빈도 | TopBar 재구성 횟수 |
| --- | --- | --- |
| A: `val show = listState.firstVisibleItemIndex > 0` | 매 프레임 | 172 |
| B: `val show by remember { derivedStateOf { listState.firstVisibleItemIndex > 0 } }` | 매 프레임 | 2 |
| C: `val label by remember { derivedStateOf { count.toString() } }` | 1초에 1회 | 3 |', 'OBJECTIVE'),
       (3758, 596, '아래 코드와 증상의 원인으로 옳은 것은?', '```kotlin
LazyColumn {
    items(messages) { message ->
        var expanded by remember { mutableStateOf(false) }
        MessageRow(message, expanded, onToggle = { expanded = !expanded })
    }
}
```

증상: 세 번째 메시지를 펼쳐 둔 채로 새 메시지가 목록 맨 앞에 삽입되면, 펼쳐 둔 메시지는 접히고 바로 위 메시지가 대신 펼쳐진 모습으로 보인다.', 'OBJECTIVE'),
       (3759, 596, '아래 상황에서 동작 차이를 만든 Compose 컴파일러 모드의 이름은?', '팀이 Kotlin을 2.0.0에서 2.0.20으로 올리고 다시 빌드하자, 인자로 List<Item>을 받던 컴포저블들이 컴파일러 리포트에서 restartable skippable로 바뀌었다. 코드는 한 줄도 고치지 않았다. 다만 화면에서 items.filter { it.done }의 결과를 그때그때 만들어 넘기던 목록 하나만은 Layout Inspector의 재구성 횟수가 그대로였다.', 'SUBJECTIVE'),
       (3760, 596, '아래 상황에서 items()에 추가로 넘긴 매개변수의 이름은?', '채팅 화면의 LazyColumn에는 날짜 구분선·광고 배너·일반 말풍선 세 종류의 행이 뒤섞여 있다. 항목마다 메시지 ID를 key로 이미 주었는데도 빠르게 스크롤하면 프레임 시간이 널뛰었다. items()에 항목마다 문자열을 돌려주는 람다를 하나 더 넘겨 구분선은 "date", 배너는 "ad", 말풍선은 "msg"를 반환하게 하자 평균 프레임 시간이 21ms에서 9ms로 줄었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3755
(10187, 3755, 'Product의 프로퍼티가 모두 val이라 목록도 안정적으로 추론돼 ProductList는 건너뛰어진다.', '항목 타입의 불변성이 목록 타입의 안정성까지 만들어 준다는 오개념이다. List는 인터페이스여서 구현체가 MutableList일 수 있으므로 항목이 완전히 불변이어도 인자 자체는 불안정으로 추론된다.', false),
(10188, 3755, 'remember로 만들어 둔 값을 넘겼으므로 인자 비교 없이 곧바로 건너뛰어진다.', 'remember는 같은 인스턴스를 유지해 줄 뿐 건너뛰기를 보장하지 않는다. 건너뛸 수 있는지는 인자 타입이 안정적이라고 컴파일러가 판정했는지에 달려 있다.', false),
(10189, 3755, 'products가 같은 인스턴스인데도 ProductList의 본문이 매번 다시 실행된다.', 'List 인자가 불안정해 컴파일러가 값의 동일성을 확신하지 못하므로 ProductList는 skippable이 아니다. Strong Skipping이 꺼져 있어 참조 동일성 비교로도 구제되지 않는다.', true),
(10190, 3755, 'count를 읽지 않는 ProductList는 재구성 스코프 밖이라 호출 자체가 생략된다.', 'count를 읽는 곳은 Screen이므로 재구성 스코프는 Screen 본문 전체다. ProductList 호출은 그대로 일어나고, 다만 인자가 안정적이면 그 지점에서 건너뛸 뿐이다.', false),

-- 문제 3756
(10191, 3756, '버튼을 눌러 tags에 항목이 늘어도 FilterChips가 다시 실행되지 않아 화면에 반영되지 않는다.', '@Immutable을 붙이면 컴파일러는 인자를 안정적으로 보고 같은 인스턴스면 건너뛴다. 그런데 MutableList는 통지 없이 내용이 바뀌므로 약속을 어긴 대가로 갱신이 유실된다.', true),
(10192, 3756, '@Immutable 계약을 어긴 것을 컴파일러가 검사해 빌드 단계에서 오류로 막아 준다.', '컴파일러가 애노테이션을 검증한다는 오개념이다. @Immutable은 개발자가 보증하는 약속이라 검증 없이 그대로 받아들여지고, 어긴 결과는 런타임의 갱신 누락으로 나타난다.', false),
(10193, 3756, 'tags에 항목이 추가될 때마다 Snapshot 시스템이 통지를 받아 SearchScreen이 계속 재구성된다.', 'MutableList는 Compose가 관찰하는 자료가 아니라는 점을 놓친 오개념이다. 변경을 통지받으려면 mutableStateListOf처럼 Snapshot 자료 구조를 써야 한다.', false),
(10194, 3756, '@Immutable이 붙은 인자는 전달될 때마다 새 인스턴스로 복사돼 FilterChips가 항상 재실행된다.', '애노테이션이 방어적 복사를 만들어 준다는 오개념이다. @Immutable은 안정성 계약을 선언할 뿐이고 인스턴스는 그대로 전달된다.', false),

-- 문제 3757
(10195, 3757, 'A는 스크롤 위치를 직접 읽어 값이 그대로여도 프레임마다 무효화가 일어난다.', '매 프레임 바뀌는 상태를 컴포저블 본문에서 바로 읽으면 그 상태를 읽은 스코프가 프레임마다 무효화된다. A의 172회가 그 결과다.', false),
(10196, 3757, 'B는 결과 Boolean이 바뀐 순간에만 무효화돼 재구성 횟수가 결과 변경 횟수로 줄었다.', '파생 상태는 계산 결과가 이전과 같으면 이 값을 읽은 컴포저블을 무효화하지 않는다. 3초 동안 경계를 두 번 넘었으므로 2회만 남았다.', false),
(10197, 3757, 'C는 입력이 바뀔 때마다 결과도 바뀌므로 remember(count)로 바꿔도 재구성 횟수가 비슷하다.', 'count가 늘면 문자열도 반드시 달라져 무효화를 막을 여지가 없다. 이런 단순 변환은 키를 준 remember로 충분하고 결과도 같다.', false),
(10198, 3757, 'C처럼 입력이 드물게 바뀔수록 파생 상태로 얻는 재구성 절감 효과가 커진다.', '거짓이다. 절감은 입력 빈도가 아니라 입력 변경 횟수와 결과 변경 횟수의 격차에서 나온다. C는 입력과 결과가 1대 1이라 이득이 없고 비교 비용만 붙는다.', true),

-- 문제 3758
(10199, 3758, 'messages가 List 인터페이스라 불안정해 항목 안의 remember 값이 초기화된다.', '안정성은 컴포저블을 건너뛸 수 있는지를 가르는 기준이지 항목 상태의 보존과는 다른 문제다. 목록 타입을 바꿔도 이 증상은 그대로 남는다.', false),
(10200, 3758, '항목 식별자가 인덱스라 앞에 삽입되면 자리가 밀려 다른 메시지에 기존 컴포지션과 상태가 붙는다.', 'items에 key를 주지 않으면 위치가 곧 정체성이 된다. 메시지 ID를 key로 주면 항목이 이동해도 컴포지션과 remember 값이 그 메시지를 따라간다.', true),
(10201, 3758, 'LazyColumn 항목 안에서는 remember를 쓸 수 없어 값이 재구성마다 초기값으로 돌아간다.', '항목 컴포지션 안에서도 remember는 정상 동작한다. 값이 초기값으로 보이는 이유는 그 자리에 다른 메시지의 새 컴포지션이 들어왔기 때문이다.', false),
(10202, 3758, 'Modifier.animateItem()을 붙이지 않아 삽입 애니메이션이 도는 동안 항목 상태가 버려진다.', 'animateItem은 위치 변화를 눈에 보이게 해 줄 뿐 상태를 지켜 주지 않는다. 오히려 항목의 정체성을 알아야 하므로 key가 있어야 동작한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1208, 3759, 'Strong Skipping,strong skipping,Strong Skipping 모드,strong skipping mode,스트롱 스키핑,강한 건너뛰기', '불안정한 인자를 가진 컴포저블도 참조 동일성(===)으로 비교해 건너뛸 수 있게 하는 컴파일러 모드가 Strong Skipping이고, Kotlin 2.0.20의 Compose 컴파일러부터 기본으로 켜진다. 코드를 한 줄도 고치지 않았는데 List 인자를 받던 컴포저블이 skippable로 바뀐 이유가 여기에 있다. 다만 비교 기준이 equals에서 참조 동일성으로 완화된 것일 뿐이라, filter로 매번 새 목록을 만들어 넘기면 참조가 달라져 여전히 재실행된다. @Immutable·@Stable과 헷갈리지 않게 구분하자. 이 둘은 개발자가 타입의 성질을 보증하는 애노테이션이고, Strong Skipping은 프로젝트 전체에 걸리는 컴파일러 모드다.'),
       (1209, 3760, 'contentType,content type,콘텐츠 타입,콘텐츠타입', 'LazyColumn이 화면 밖으로 나간 항목의 컴포지션을 재사용할 때, 같은 갈래끼리만 재사용 풀을 나누도록 힌트를 주는 인자가 contentType이다. 레이아웃 구조가 다른 행이 섞여 있으면 재사용이 어긋나 항목을 처음부터 다시 만들게 되는데, 갈래를 알려 주면 구조가 같은 항목끼리 재사용돼 프레임 시간이 안정된다. RecyclerView의 viewType과 같은 역할이다. key와 헷갈리지 않게 구분하자. key는 어느 데이터의 항목인지를 알려 상태 손실과 잘못된 애니메이션을 막고, contentType은 재사용 대상을 분류한다. 그래서 이미 key를 준 뒤에도 contentType이 따로 필요하다.');

-- =====================================================
-- Lesson 754: 역방향 쓰기와 derivedStateOf
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4703, 754, '아래 컴파일러 리포트 결과에 대한 설명으로 옳은 것은?', ':feature 모듈의 컴포저블을 Compose 컴파일러 리포트로 뽑았다. Order는 :domain 모듈에 선언돼 있고 프로퍼티는 모두 val이며 타입은 Long과 String뿐이다. 프로젝트는 Kotlin 2.0.10이라 Strong Skipping은 꺼져 있다.

```text
restartable skippable fun PriceText(
  stable price: Int
)
restartable fun OrderSummary(
  stable total: Int
  unstable order: Order
)
```', 'OBJECTIVE'),
       (4704, 754, '아래 코드에서 스크롤은 그대로 두고 query만 바뀌었을 때 일어나는 일로 옳은 것은?', 'listState는 화면에 보이는 첫 항목이 바뀔 때마다 갱신되는 Snapshot 상태이고, query는 상위 화면이 넘겨 주는 인자다.

```kotlin
@Composable
fun SearchHint(query: String, listState: LazyListState) {
    val hidden by remember {
        derivedStateOf { listState.firstVisibleItemIndex > 0 || query.isBlank() }
    }
    if (!hidden) HintBanner(query)
}
```', 'OBJECTIVE'),
       (4705, 754, '아래 코드에서 items가 비어 있지 않을 때 나타나는 현상으로 옳은 것은?', '```kotlin
@Composable
fun BadgeRow(items: List<Item>) {
    var seen by remember { mutableStateOf(0) }
    Text("본 항목 " + seen + "개")
    seen = seen + items.size
}
```', 'OBJECTIVE'),
       (4706, 754, '아래 실험 결과에 대한 설명으로 옳지 않은 것은?', '채팅 목록 LazyColumn에서 items()에 넘기는 key만 바꿔 가며, 항목 하나를 펼쳐 둔 채 새 메시지를 맨 앞에 삽입해 보았다. 각 항목은 내부에 remember로 펼침 상태를 들고 있다.

| key 설정 | 삽입 직후 펼침 상태 | 다시 그린 항목 수 |
| --- | --- | --- |
| A: 넘기지 않음(기본) | 바로 위 항목이 대신 펼쳐짐 | 화면의 모든 항목 |
| B: `key = { UUID.randomUUID() }` | 모두 접힘 | 화면의 모든 항목 |
| C: `key = { it.id }` | 원래 항목이 그대로 펼쳐짐 | 새 항목 1개 |
| D: `key = { it.senderName }` | 확인 불가 — 실행 중 예외로 앱이 멈춤 | - |', 'OBJECTIVE'),
       (4707, 754, '아래 상황에서 클래스 선언에 붙인 애노테이션의 이름은?', '스크롤 위치를 들고 있는 상태 홀더 클래스를 인자로 받는 컴포저블이 있다. 클래스 내부 값은 mutableStateOf로 관리하는데도 컴파일러 리포트는 이 컴포저블을 skippable로 찍어 주지 않았다. 클래스 선언 위에 애노테이션 한 줄을 붙이자 같은 리포트에서 skippable로 바뀌었고, 3초 동안 목록을 훑는 사이 이 컴포저블의 재구성이 312회에서 6회로 줄었다. 같은 자리에 @Immutable을 붙여도 리포트 결과는 같았지만, 스크롤 위치가 바뀌어도 화면이 따라오지 않는 버그가 생겨 되돌렸다.', 'SUBJECTIVE'),
       (4708, 754, '아래 상황에서 계산식을 감싸는 데 쓴 Compose API의 이름은?', '목록 맨 위 그림자를 보일지 말지는 첫 보이는 항목 인덱스가 0보다 큰지로 정한다. 처음에는 이 비교식을 상단 바 안에서 그대로 읽었더니, 3초 동안 목록을 훑는 사이 Layout Inspector에 찍힌 상단 바 재구성 횟수가 174회였다. 같은 비교식을 특정 블록으로 감싸 remember로 기억하게 하자 같은 조작에서 2회로 줄었다. 반면 1초에 1씩 늘어나는 카운터를 문자열로 바꾸는 코드에 같은 블록을 씌웠을 때는 횟수가 그대로였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4703
(12715, 4703, 'Order는 프로퍼티가 모두 val이라 이미 안정적이므로, unstable 표시는 Strong Skipping이 꺼져 있어서 붙은 것이다.', '안정성 판정과 건너뛰기 모드를 한 덩어리로 본 오개념이다. Strong Skipping은 불안정한 인자를 참조 동일성으로 구제하는 모드일 뿐, 타입이 안정적인지에 대한 판정 자체를 바꾸지는 않는다.', false),
(12716, 4703, 'Order 소스를 한 줄도 고치지 않아도, 그 클래스를 컴파일러 옵션의 목록에 등록하면 OrderSummary가 skippable로 바뀔 수 있다.', '컴파일러는 다른 모듈에 있는 클래스의 소스를 분석할 수 없어 기본적으로 불안정으로 둔다. 안정성 설정 파일에 클래스나 패키지를 적어 두면 안정적으로 취급되며, 고칠 수 없는 외부 라이브러리 타입에도 같은 방법을 쓴다.', true),
(12717, 4703, 'total이 stable로 찍혔으므로 total만 그대로라면 OrderSummary는 호출 지점에서 건너뛰어진다.', '인자 하나가 안정적이면 그만큼 건너뛴다고 본 오개념이다. 건너뛰기는 인자 전부가 안정적이라고 판정돼야 가능하며, 불안정한 인자가 하나라도 있으면 리포트에 skippable이 붙지 않는다.', false),
(12718, 4703, 'unstable 인자가 있으면 그 컴포저블은 restartable 자격도 잃어 부모 스코프가 통째로 다시 실행된다.', 'restartable과 skippable을 같은 판정으로 묶어 본 오개념이다. OrderSummary에 restartable이 그대로 붙어 있듯 둘은 별개이며, restartable이면 부모를 끌어들이지 않고 이 함수만 따로 다시 실행할 수 있다.', false),

-- 문제 4704
(12719, 4704, 'hidden이 다시 계산되지 않아 예전 query로 구한 값에 그대로 머문다.', 'remember에 키가 없어 파생 상태 객체가 처음 만든 것 그대로 유지되고, 인자인 query는 Snapshot 상태가 아니라 블록 안에서 읽어도 추적되지 않는다. remember(query) { derivedStateOf { } }처럼 키를 넘겨야 한다.', true),
(12720, 4704, 'query가 바뀔 때마다 블록이 다시 계산되지만, 결과가 같으면 HintBanner만 갱신되지 않는다.', 'derivedStateOf가 블록 안에서 읽은 값을 모두 추적한다고 본 오개념이다. 추적되는 것은 Snapshot 상태뿐이라 일반 인자인 query가 바뀌어도 재계산이 일어나지 않는다.', false),
(12721, 4704, 'remember의 계산식이 재구성마다 다시 실행돼 파생 상태 객체가 매번 새로 만들어진다.', '키 없는 remember의 동작을 거꾸로 본 오개념이다. 키가 없으면 같은 자리에서 계산식은 한 번만 실행되고 그 결과가 계속 재사용된다. 문제는 매번 다시 만들어지는 것이 아니라 갱신되지 않는 것이다.', false),
(12722, 4704, 'listState를 읽고 있어 스크롤이 멈춰 있어도 프레임마다 hidden을 읽은 자리가 무효화된다.', '파생 상태로 감싼 효과를 놓친 오개념이다. 계산 결과가 이전과 같으면 그 값을 읽은 컴포저블은 무효화되지 않고, 애초에 스크롤이 멈춰 있으면 첫 항목 인덱스도 바뀌지 않는다.', false),

-- 문제 4705
(12723, 4705, 'seen이 한 번만 갱신된 뒤 값이 고정돼 화면에는 항목 개수가 그대로 표시된다.', '대입이 한 번으로 끝난다고 본 오개념이다. 대입할 값을 seen 자신에 더해 만들기 때문에 실행될 때마다 값이 달라지고, 값이 달라지면 그 상태를 읽은 스코프가 다시 무효화된다.', false),
(12724, 4705, 'remember가 값을 기억하므로 첫 컴포지션 이후에는 대입문이 실행되지 않는다.', 'remember의 범위를 오해한 것이다. remember는 중괄호 안 계산식의 결과를 보관해 줄 뿐이고, 컴포저블 본문의 나머지 문장은 재구성될 때마다 처음부터 다시 실행된다.', false),
(12725, 4705, 'seen을 읽은 뒤 같은 컴포지션에서 다시 써서 무효화가 꼬리를 물어 재구성이 멈추지 않는다.', '이미 읽은 상태에 컴포지션 도중 쓰는 역방향 쓰기다. 쓰기가 그 상태를 읽은 스코프를 무효화하고, 다시 실행된 본문이 또 쓰기를 하므로 루프가 된다. 이런 누적 계산은 UI 상태로 미리 가공해 내려보내야 한다.', true),
(12726, 4705, '대입문은 컴포지션이 끝난 뒤로 미뤄져 다음 프레임에 한 번만 반영된다.', '컴포저블 본문의 문장이 알아서 지연 실행된다고 본 오개념이다. 컴포지션이 끝난 뒤에 실행하고 싶다면 SideEffect나 LaunchedEffect 같은 효과 API로 직접 감싸야 한다.', false),

-- 문제 4706
(12727, 4706, 'A에서 펼침이 옆 항목으로 옮겨간 것은 기본 식별자가 항목의 위치라서, 앞에 하나가 끼어들면 상태가 그 자리에 남기 때문이다.', 'key를 넘기지 않으면 인덱스가 곧 정체성이 된다. 맨 앞에 삽입되면 모든 인덱스가 한 칸씩 밀려 이전 자리의 컴포지션과 remember 값이 다른 메시지에 붙는다.', false),
(12728, 4706, 'B는 key를 주고도 A와 결과가 다르지 않은데, 재구성마다 새 값이 나와 이전 항목과 이어 붙일 수 없기 때문이다.', '무작위 값은 항목을 가리키는 이름 구실을 못 한다. 매번 다른 key가 나오면 모든 항목이 새 항목으로 취급돼 컴포지션과 상태가 버려지므로, 안 준 것과 같거나 대조 비용만 더 든다.', false),
(12729, 4706, 'D에서 예외가 난 것은 같은 이름으로 보낸 메시지가 둘 이상이어서 key가 목록 안에서 유일하지 않았기 때문이다.', 'LazyList의 key는 목록 안에서 유일해야 하고 중복되면 실행 중 예외가 난다. 보낸 사람 이름처럼 겹칠 수 있는 값 대신 메시지 ID 같은 고유 값을 key로 써야 한다.', false),
(12730, 4706, 'C처럼 key를 제대로 주면 항목 컴포지션이 보존되므로 Modifier.animateItem()을 붙이지 않아도 자리 이동이 애니메이션으로 이어진다.', '거짓이다. key는 어느 데이터의 항목인지 알려 상태와 컴포지션을 지켜 줄 뿐, 이동을 눈에 보이게 그려 주지는 않는다. 자리 이동 애니메이션은 Modifier.animateItem()을 붙여야 하고 key는 그 전제 조건이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1524, 4707, '@Stable,Stable,스테이블,Stable 애노테이션', '값이 바뀔 수는 있지만 변경이 Snapshot 시스템에 반드시 통지된다는 것을 개발자가 보증하는 애노테이션이 @Stable이다. 내부에 mutableStateOf를 두고 값이 계속 바뀌는 상태 홀더에 알맞고, 이 보증 덕분에 컴파일러가 인자를 안정적으로 보아 컴포저블을 skippable로 판정한다. @Immutable과 헷갈리지 않게 경계를 잡자. @Immutable은 생성 후 값이 절대 바뀌지 않는다는 더 센 약속이라, 실제로 값이 바뀌는 타입에 붙이면 컴파일러가 같은 인스턴스를 그냥 건너뛰어 화면 갱신이 유실된다. 본문에서 @Immutable을 붙였을 때 스크롤 위치가 화면에 반영되지 않은 이유가 바로 이것이다. 두 애노테이션 모두 컴파일러가 검증하지 않는 약속이므로 어기면 조용한 버그로 돌아온다. 소스를 고칠 수 없는 외부 라이브러리 타입이라면 애노테이션 대신 안정성 설정 파일에 등록해 같은 효과를 낼 수 있다.'),
       (1525, 4708, 'derivedStateOf,derived state of,derived state,파생 상태', '계산 결과가 이전과 같으면 그 값을 읽은 컴포저블을 무효화하지 않는 것이 derivedStateOf다. 스크롤 위치는 프레임마다 바뀌지만 첫 항목 인덱스가 0보다 큰지는 경계를 넘을 때만 바뀌므로 174회가 2회로 줄었다. 반대로 카운터를 문자열로 바꾸는 계산은 입력이 바뀌면 결과도 반드시 바뀌어 막을 무효화가 없고 비교 비용만 얹힌다. 두 번째 측정에서 횟수가 그대로였던 까닭이다. remember(key)와 헷갈리지 않게 구분하자. remember(key)는 키가 달라질 때 다시 계산해 주는 장치이고, derivedStateOf는 다시 계산하되 결과가 같으면 읽는 쪽을 깨우지 않는 장치다. 또 블록 안에서 읽는 값이 Snapshot 상태가 아니라 컴포저블 인자라면 추적되지 않으므로 remember(arg) { derivedStateOf { } }처럼 키를 함께 넘겨야 한다.');

-- =====================================================
-- Lesson 912: Compose 최적화 점검: 안정성 추론·상태 읽기 지연·측정 기준
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5651, 912, '아래 코드를 Strong Skipping 모드가 꺼진 컴파일러로 빌드했을 때, 인자가 그대로이면 실행을 건너뛸 수 있는 컴포저블은?', '아래 클래스와 컴포저블은 모두 같은 :app 모듈에 선언돼 있다.

```kotlin
data class Tag(val id: Long, val label: String)
data class Draft(var text: String)
data class Order(val id: Long, val tags: List<Tag>)

@Composable
fun DraftEditor(draft: Draft) { /* ... */ }

@Composable
fun OrderCard(order: Order) { /* ... */ }

@Composable
fun TagChip(tag: Tag, selected: MutableState<Boolean>) { /* ... */ }

@Composable
fun TagRow(tags: List<Tag>) { /* ... */ }
```', 'OBJECTIVE'),
       (5652, 912, '아래 코드를 A에서 B로 바꾼 뒤 화면을 스크롤할 때 달라지는 점으로 옳은 것은?', 'scroll은 스크롤할 때마다 value가 바뀌는 ScrollState이다. A와 B는 모두 헤더를 스크롤 거리의 절반만큼 위로 밀어 올린다.

```kotlin
// A
@Composable
fun CollapsingHeader(scroll: ScrollState) {
    val density = LocalDensity.current
    val y = with(density) { (-scroll.value / 2).toDp() }
    Box(Modifier.offset(y = y)) { HeaderContent() }
}

// B
@Composable
fun CollapsingHeader(scroll: ScrollState) {
    Box(Modifier.offset { IntOffset(0, -scroll.value / 2) }) { HeaderContent() }
}
```', 'OBJECTIVE'),
       (5653, 912, '아래 코드에서 now만 바뀌어 TodoScreen이 다시 실행될 때의 동작으로 옳은 것은?', 'Kotlin 2.0.20 프로젝트이며 Compose 컴파일러의 Strong Skipping 모드가 켜져 있다. todos는 상위에서 같은 인스턴스가 그대로 넘어오고, now는 1초마다 바뀐다. Todo는 val만 가진 data class이다.

```kotlin
@Composable
fun TodoScreen(todos: List<Todo>, now: Long) {
    Text(formatTime(now))
    val active = remember(todos) { todos.filter { !it.done } }

    TodoList(todos)                        // (가)
    TodoList(active)                       // (나)
    TodoList(todos.sortedBy { it.title })  // (다)
}

@Composable
fun TodoList(items: List<Todo>) { /* ... */ }
```', 'OBJECTIVE'),
       (5654, 912, '아래 측정 결과를 해석한 것으로 옳은 것은?', '피드 화면의 FeedItem이 재구성을 너무 많이 한다는 지적을 받고, 60Hz 화면을 쓰는 같은 기기에서 피드를 10초 동안 스크롤하며 측정했다. 디버그 빌드에서 Layout Inspector로 보니 FeedItem은 1,240번 재구성됐고 건너뛴 횟수는 0이었다. Compose 컴파일러 리포트에는 `restartable fun FeedItem(unstable post: FeedPost)`로 찍혔다.

| 빌드 | 프레임 시간 중앙값 | 프레임 시간 P90 |
| --- | --- | --- |
| 디버그 빌드 | 31ms | 52ms |
| 릴리스 빌드(R8 적용) | 8ms | 13ms |

P90은 프레임을 걸린 시간이 짧은 순서로 줄 세웠을 때 90% 지점에 오는 값이다.', 'OBJECTIVE'),
       (5655, 912, '아래 상황에서 문제를 고치려고 items()에 새로 넘긴 인자의 매개변수 이름은?', '장바구니 화면의 LazyColumn은 items(products) { ... }로 상품 행을 그리고, 각 행은 사용자가 입력한 수량을 remember로 들고 있다. 사용자가 맨 위 사과 행에 수량 3을 입력한 뒤 정렬을 가격순으로 바꾸자, 3은 새로 맨 위에 올라온 배 행에 표시되고 사과 행의 수량 칸은 비어 있었다. items()에 상품마다 SKU 문자열을 돌려주는 람다를 인자로 하나 더 넘기자, 정렬을 여러 번 바꿔도 수량 3이 사과 행을 따라다녔다.', 'SUBJECTIVE'),
       (5656, 912, '아래 코드에서 증상을 일으킨, 상태를 잘못 다룬 방식을 가리키는 용어는?', '게시글 목록 화면이 몇 번 그려지는지 보려고 디버그용 카운터를 넣었다. 그런데 화면을 건드리지 않아도 카운터 숫자가 쉬지 않고 올라갔고, CPU 사용률이 치솟았다.

```kotlin
@Composable
fun FeedScreen(viewModel: FeedViewModel) {
    val posts by viewModel.posts.collectAsState()
    var drawCount by remember { mutableStateOf(0) }

    Button(onClick = { viewModel.refresh() }) { Text("새로고침") }
    FeedList(posts)
    Text("그린 횟수: $drawCount")
    drawCount++
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5651
(15243, 5651, 'DraftEditor', 'data class라서 equals가 구조적으로 비교되니 안정적이라고 본 오개념이다. text가 var라 통지 없이 값이 바뀔 수 있어 equals 결과가 계속 같다고 보장할 수 없으므로 Draft는 불안정으로 추론된다.', false),
(15244, 5651, 'OrderCard', '프로퍼티가 모두 val이면 안정적이라고 본 오개념이다. 안정적이려면 모든 공개 프로퍼티의 타입도 안정적이어야 하는데, tags의 List는 구현체가 MutableList일 수 있어 불안정이므로 Order도 불안정해진다.', false),
(15245, 5651, 'TagChip', 'Tag는 val만 갖고 필드 타입이 Long·String이라 안정적이다. MutableState는 값이 바뀌어도 그 변경을 Compose에 통지하므로 안정적 타입으로 취급된다. 인자가 모두 안정적이라 값이 같으면 건너뛸 수 있다.', true),
(15246, 5651, 'TagRow', '항목 Tag가 안정적이면 목록도 안정적이라고 본 오개념이다. List는 인터페이스라 불변을 보장하지 못해 불안정으로 추론되고, Strong Skipping이 꺼져 있어 참조 비교로 건너뛸 길도 없다.', false),

-- 문제 5652
(15247, 5652, '스크롤 중 CollapsingHeader는 재구성되지 않고, 헤더를 배치하는 단계부터 프레임마다 다시 처리된다.', 'B는 scroll.value를 컴포지션이 아니라 offset 람다 안, 즉 배치 단계에서 읽는다. 상태를 읽은 단계부터 다시 실행되므로 본문 재실행 없이 위치만 다시 잡힌다. A는 본문에서 읽어 프레임마다 재구성된다.', true),
(15248, 5652, '람다가 처음 읽은 scroll.value를 붙잡아 두므로, 스크롤해도 헤더가 처음 자리에 머문다.', '람다가 값을 한 번만 읽어 고정한다고 본 오개념이다. 람다는 배치할 때마다 실행돼 그때의 scroll.value를 새로 읽고, 그 읽기도 추적되므로 값이 바뀌면 배치가 다시 일어난다.', false),
(15249, 5652, 'CollapsingHeader는 여전히 프레임마다 재구성되고, 픽셀을 dp로 바꾸는 계산만 사라진다.', '차이를 단위 변환 비용으로만 본 오개념이다. 핵심은 상태를 읽는 시점이다. 본문에서 값을 읽지 않으니 컴포지션이 이 상태를 구독하지 않아 재구성 자체가 일어나지 않는다.', false),
(15250, 5652, 'offset에 넘긴 람다가 프레임마다 새로 만들어져, A보다 CollapsingHeader가 더 자주 재구성된다.', '람다 생성과 재구성을 혼동한 오개념이다. 람다는 본문이 실행될 때만 만들어지는데, 스크롤 값 변화는 배치 단계에서 처리돼 본문이 다시 실행되지 않으므로 새 람다도 생기지 않는다.', false),

-- 문제 5653
(15251, 5653, '(가)는 인자가 불안정한 List라서, now가 바뀔 때마다 TodoList 본문이 다시 실행된다.', 'Strong Skipping을 빼고 본 오개념이다. 이 모드에서는 불안정한 인자도 참조 동일성(===)으로 비교하므로, 같은 인스턴스가 그대로 넘어온 (가)는 건너뛰어진다.', false),
(15252, 5653, '(나)는 TodoScreen이 다시 실행될 때마다 filter가 새로 돌아, TodoList도 다시 실행된다.', 'remember의 키를 놓친 오개념이다. todos가 같은 인스턴스인 동안 remember(todos)는 처음 계산한 목록을 그대로 돌려주므로 참조가 같아 건너뛰어진다.', false),
(15253, 5653, 'Todo에 @Immutable을 붙이면, (다)도 정렬 결과가 같은 동안 건너뛰어진다.', '항목 타입을 보증하면 목록 인자도 안정적이 된다고 본 오개념이다. 인자 타입은 여전히 List라 참조로 비교되고, sortedBy가 매번 새 목록을 만들어 참조가 달라진다.', false),
(15254, 5653, '(다)는 정렬 결과의 내용이 매번 같아도, TodoList 본문이 매번 다시 실행된다.', 'sortedBy는 호출될 때마다 새 List 인스턴스를 만든다. Strong Skipping은 비교 기준을 참조 동일성으로 완화할 뿐이라 내용이 같아도 참조가 달라 건너뛰지 못한다. 정렬은 remember나 ViewModel에서 미리 해 둔다.', true),

-- 문제 5654
(15255, 5654, '디버그 빌드의 중앙값이 프레임 예산의 약 두 배이므로, 사용자도 스크롤 중 끊김을 자주 겪는다.', '디버그 빌드의 속도를 실제 성능으로 본 오개념이다. 디버그 빌드는 최적화가 빠지고 디버깅용 처리가 붙어 느리다. 사용자가 받는 것은 R8이 적용된 릴리스 빌드이므로 그 기준으로 판단해야 한다.', false),
(15256, 5654, '릴리스 빌드는 P90도 프레임 예산 안이라, 재구성이 많아도 대부분의 프레임이 제때 그려진다.', '60Hz 화면의 프레임 예산은 약 16ms다. 릴리스 빌드는 90% 지점도 13ms라 예산 안에 든다. 재구성 횟수가 많아도 예산 안에 끝나면 사용자에겐 문제가 아니므로, 이것만으로 최적화를 서두를 근거는 약하다.', true),
(15257, 5654, '리포트의 unstable 표시는 R8이 적용되면 사라지므로, 릴리스 빌드에서는 FeedItem이 건너뛰어진다.', '빌드 최적화가 안정성 판정을 바꾼다고 본 오개념이다. 안정성은 Compose 컴파일러가 코드를 컴파일할 때 추론해 결과 코드에 새겨 두고, R8은 그 뒤 코드를 줄이고 다듬을 뿐 이 판정을 바꾸지 않는다.', false),
(15258, 5654, '릴리스 빌드도 중앙값이 프레임 예산을 넘으므로, 절반이 넘는 프레임이 제때 그려지지 못한다.', '표의 값을 예산과 잘못 견준 것이다. 60Hz 화면의 프레임 예산은 약 16ms인데 릴리스 빌드의 중앙값은 8ms로 그 절반 수준이다. 예산을 넘는 쪽은 디버그 빌드이고, 디버그 빌드의 느림은 실제 성능과 무관한 경우가 많다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1840, 5655, 'key,키,key 매개변수,item key,아이템 키,항목 키,LazyList key,고유 키', 'LazyColumn은 key를 주지 않으면 항목의 위치(인덱스)를 정체성으로 삼는다. 정렬로 순서가 바뀌어도 컴포지션과 remember 값은 자리에 남아 있어, 사과에 입력한 3이 그 자리로 옮겨 온 배 행에 보였다. 상품마다 바뀌지 않는 고유 값(SKU)을 key로 주면 항목이 어디로 움직이든 컴포지션과 상태가 그 상품을 따라간다. key는 목록 안에서 유일해야 하고(중복되면 실행 중 예외), 안드로이드에서는 Bundle에 담을 수 있는 타입이어야 하므로 String·Long 같은 값이 알맞다. contentType과 헷갈리지 않게 구분하자. contentType도 항목마다 값을 돌려주는 람다로 넘기지만, 어느 상품인지가 아니라 레이아웃 갈래(헤더·광고·일반 행)를 알려 같은 갈래끼리 컴포지션을 재사용하게 하는 힌트다. 그래서 상품마다 다른 값을 줄 필요가 없고, 항목 상태를 지켜 주지도 않는다.'),
       (1841, 5656, '역방향 쓰기,역방향쓰기,backwards write,backward write,backwards writes,backwards-write,백워드 라이트,백워즈 라이트,역방향 쓰기(backwards write)', '컴포지션 도중 이미 읽은 상태에 다시 쓰는 것을 역방향 쓰기(Backwards Write)라 한다. 본문의 Text가 drawCount를 읽은 뒤 같은 컴포지션에서 drawCount++로 값을 바꾸면, 그 상태를 읽은 FeedScreen이 무효화돼 다시 실행되고, 다시 실행된 본문이 또 값을 올리므로 입력이 없어도 재구성이 끝없이 이어진다. 화면에 보일 값은 ViewModel에서 미리 계산해 내려보내고, 상태 변경은 클릭 같은 이벤트 콜백 안에서 해야 한다. 재구성이 과하다는 증상만 보고 불안정한 인자 탓으로 돌리기 쉬운데 둘은 다르다. 불안정한 인자는 부모가 재구성될 때 자식이 건너뛰지 못해 실행이 늘어나는 문제이고, 역방향 쓰기는 부모의 변화 없이도 컴포저블이 스스로 재구성을 다시 불러 무한 루프에 빠지는 문제다. 안정성을 고쳐도 이 루프는 멈추지 않는다.');
