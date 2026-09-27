-- Unit: Compose 상태 관리 (Unit ID: 169)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (595, 169, '상태 호이스팅과 Stateless 컴포저블'),
       (753, 169, 'remember 키와 상태 홀더 선택'),
       (911, 169, 'Compose 상태 관리 — 값이 사라지거나 어긋나는 이유 추적하기');

-- =====================================================
-- Lesson 595: 상태 호이스팅과 Stateless 컴포저블
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3749, 595, '아래 컴포저블에서 증가 버튼을 세 번 눌렀을 때 일어나는 일로 옳은 것은?', '```kotlin
@Composable
fun Counter() {
    var count by mutableStateOf(0)
    Column {
        Text("count = $count")
        Button(onClick = { count++ }) { Text("증가") }
    }
}
```', 'OBJECTIVE'),
       (3750, 595, '아래 비교표를 바탕으로 상태를 어디에 둘지 판단한 내용으로 옳지 않은 것은?', '| 항목 | remember | rememberSaveable | ViewModel + SavedStateHandle |
| --- | --- | --- | --- |
| 재구성 사이 유지 | 유지 | 유지 | 유지 |
| 화면 회전(구성 변경) | 초기화 | 유지 | 유지 |
| 프로세스 종료 후 복원 | 초기화 | 복원(Bundle) | 복원(SavedStateHandle) |
| 컴포지션에서 제거 시 | 소멸 | 소멸 | 유지(소유자 수명) |', 'OBJECTIVE'),
       (3751, 595, '아래 코드에서 입력한 검색어가 ResultList에도 반영되게 하려면 어떻게 고쳐야 하는가?', '```kotlin
@Composable
fun SearchScreen() {
    val results = remember { mutableStateListOf<String>() }
    Column {
        SearchField()
        ResultList(results)
    }
}

@Composable
fun SearchField() {
    var query by remember { mutableStateOf("") }
    TextField(value = query, onValueChange = { query = it })
}
```', 'OBJECTIVE'),
       (3752, 595, '아래 코드에서 추가 버튼을 눌렀을 때의 결과로 옳은 것은?', '```kotlin
@Composable
fun TodoScreen() {
    val todos = remember { mutableStateOf(mutableListOf<String>()) }
    Column {
        Button(onClick = { todos.value.add("새 할 일") }) { Text("추가") }
        todos.value.forEach { Text(it) }
    }
}
```', 'OBJECTIVE'),
       (3753, 595, '아래 증상을 없애기 위해 상태 선언에 사용해야 할 Compose 함수의 이름은?', '메모 작성 화면에서 사용자가 제목을 절반쯤 입력한 뒤 기기를 가로로 돌리면 입력 칸이 다시 빈 칸이 된다. 다른 앱을 한참 쓰다가 돌아와 앱이 다시 뜬 경우에도 마찬가지다. 제목은 이 화면 안에서만 쓰는 짧은 문자열이라 ViewModel까지 올리지 않고 컴포저블 안에서 해결하려 한다.

현재 선언은 다음과 같다.

```kotlin
var title by remember { mutableStateOf("") }
```', 'SUBJECTIVE'),
       (3754, 595, '아래에서 검색 바가 해당하는 컴포저블 분류의 이름은?', '같은 화면의 검색 바와 필터 바를 미리보기로 확인했다. 검색 바는 미리보기 코드에서 검색어를 빈 문자열, 아주 긴 문장, 공백만 있는 값으로 각각 지정해 세 가지 화면을 한 번에 그려 볼 수 있었고, UI 테스트에서도 원하는 검색어를 곧바로 넣어 결과를 검증했다.

반면 필터 바는 선택된 조건을 안에서 remember로 만들어 두어 미리보기에서는 늘 아무것도 선택되지 않은 첫 화면만 나왔고, 테스트에서는 탭 클릭을 흉내 내야만 다른 화면을 볼 수 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3749
(10171, 3749, 'count가 스냅숏 상태 객체가 아니어서 값을 바꿔도 재구성이 예약되지 않는다.', 'mutableStateOf로 만든 값은 remember 없이도 스냅숏 상태 객체다. 쓰기는 정상적으로 무효화를 일으키므로 재구성 자체는 예약된다. 문제는 그다음 단계에 있다.', false),
(10172, 3749, '재구성은 일어나지만 그때마다 상태 객체가 새로 만들어져 화면에는 계속 count = 0이 표시된다.', 'remember가 없으면 값이 컴포지션 위치에 보관되지 않아 재구성마다 mutableStateOf(0)이 다시 실행된다. 상태 객체를 만드는 일과 재구성 사이에 유지하는 일은 별개의 문제다.', true),
(10173, 3749, '값이 정상적으로 누적되어 count = 3이 표시되고, 화면을 회전할 때만 0으로 돌아간다.', '회전 시 초기화는 remember를 제대로 쓴 코드의 한계다. 여기서는 remember 자체가 없어 회전 이전에 이미 재구성마다 0으로 돌아간다.', false),
(10174, 3749, '화면에는 계속 count = 0이 표시되며, 이는 재구성 중에 onClick 콜백이 무시되기 때문이다.', '결론은 맞지만 원인이 틀렸다. onClick은 정상 실행되고 count++도 그 시점의 상태 객체에 반영된다. 그 객체가 재구성 때 버려지는 것이 원인이다.', false),

-- 문제 3750
(10175, 3750, '조건이 거짓이 되어 잠시 사라졌다가 다시 그려지는 영역의 입력값을 remember로 두면, 다시 나타날 때 값이 처음 상태로 돌아간다.', '표의 컴포지션에서 제거 시 행에서 remember는 소멸이다. 재구성과 달리 컴포저블이 트리에서 빠지면 값을 보관하던 자리 자체가 없어지므로, 다시 들어올 때 remember 블록이 처음부터 실행된다. 사라지면 안 되는 값은 소유자 수명을 가진 위쪽에 두어야 한다.', false),
(10176, 3750, '프로세스가 종료된 뒤에도 값을 되살려야 한다면 ViewModel에 두더라도 SavedStateHandle을 함께 써야 한다.', '표의 프로세스 종료 후 복원 행에서 ViewModel 열은 SavedStateHandle을 통해 복원된다고 적혀 있다. ViewModel 인스턴스 자체는 프로세스와 함께 사라진다.', false),
(10177, 3750, '회전을 견뎌야 하지만 Bundle에 담기 부담스러운 큰 목록이라면 rememberSaveable보다 ViewModel 쪽이 낫다.', '표에서 회전을 견디는 후보는 rememberSaveable과 ViewModel 둘인데, 앞의 것은 Bundle에 실려 저장되므로 대용량 데이터에는 맞지 않는다. 큰 데이터는 식별자만 남기고 다시 불러온다.', false),
(10178, 3750, '회전 뒤에도 남아야 하는 텍스트 입력값은 remember만으로 지킬 수 있어 rememberSaveable을 쓸 이유가 없다.', '회전은 Activity 재생성이라 컴포지션이 통째로 사라진다. 표의 화면 회전 행에서 remember는 초기화이므로 이 진술만 거짓이다.', true),

-- 문제 3751
(10179, 3751, 'query를 SearchScreen으로 옮기고, SearchField는 query 값과 변경 콜백을 인자로 받게 바꾼다.', '상태를 읽고 쓰는 컴포저블들의 가장 가까운 공통 부모까지 끌어올리는 상태 호이스팅이다. 상태는 아래로, 이벤트는 위로 흐르게 되어 부모가 검색어를 알고 결과 목록에 넘길 수 있다.', true),
(10180, 3751, 'SearchField의 remember를 rememberSaveable로 바꿔 검색어가 사라지지 않게 한다.', '보관 수명 문제로 잘못 진단한 것이다. 지금 문제는 값이 사라지는 것이 아니라 SearchField 밖에서는 그 값을 읽을 수 없다는 소유 위치 문제다.', false),
(10181, 3751, 'ResultList 안에도 같은 이름의 query 상태를 remember로 선언해 두 컴포저블이 같은 값을 보게 한다.', '이름이 같아도 컴포지션 위치마다 별개의 상태가 만들어진다. 같은 정보를 두 곳이 소유하면 단일 진실 원천이 깨져 어느 쪽이 옳은 값인지 알 수 없게 된다.', false),
(10182, 3751, 'SearchField를 ResultList의 자식으로 옮겨 두 컴포저블이 같은 컴포지션 위치를 쓰게 한다.', '트리에서 가깝다고 상태가 공유되지는 않으며 부모는 자식의 내부 상태를 읽을 수 없다. 오히려 결과 목록이 검색어를 인자로 받을 길까지 막힌다.', false),

-- 문제 3752
(10183, 3752, 'add가 상태 쓰기로 감지되어 버튼을 누를 때마다 항목이 곧바로 화면에 나타난다.', '감지 대상은 todos.value에 다른 객체를 대입하는 일이다. 리스트 내부만 고치는 add는 상태 쓰기가 아니라 평범한 객체 변경이라 무효화를 일으키지 않는다.', false),
(10184, 3752, 'MutableList는 스냅숏 상태에 담을 수 없어 add를 호출하는 순간 예외가 발생한다.', '담기는 타입 제약이 없어 컴파일도 실행도 정상이다. 담을 수 있으나 원소 단위 변경이 추적되지 않는다는 점이 함정이다.', false),
(10185, 3752, '리스트에는 항목이 쌓이지만 todos.value가 가리키는 참조가 그대로여서 화면은 계속 비어 있다.', 'MutableState는 value에 담긴 참조가 바뀔 때 무효화된다. 원소 단위 변경까지 추적하려면 mutableStateListOf를 쓰거나, 새 리스트를 만들어 value에 대입해야 한다.', true),
(10186, 3752, 'remember가 첫 리스트를 캐시하므로 add가 무시되어 리스트 크기가 계속 0으로 남는다.', 'remember는 같은 객체를 계속 돌려줄 뿐 그 객체의 변경을 막지 않는다. 로그를 찍어 보면 크기는 1, 2, 3으로 늘어나 있고 화면만 갱신되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1206, 3753, 'rememberSaveable,rememberSaveable(),리멤버세이버블,리멤버 세이버블', '화면 회전은 Activity 재생성이라 컴포지션이 통째로 사라지고, 프로세스가 종료된 뒤에도 값이 필요하므로 remember로는 두 증상을 모두 막을 수 없다. rememberSaveable은 값을 Bundle(SavedInstanceState)에 함께 실어 두었다가 되살리므로 회전과 프로세스 종료를 모두 견딘다. 단 Bundle을 거치므로 큰 목록이나 이미지는 넣지 않고 식별자만 저장하며, Bundle이 모르는 사용자 정의 타입은 Saver를 정의해 변환해야 한다. 컴포지션에서 제거되면 값이 사라지는 것은 remember와 같으므로, 화면 수명 내내 살아 있어야 하는 화면 데이터라면 ViewModel + SavedStateHandle이 맞는 자리다.'),
       (1207, 3754, 'Stateless,Stateless 컴포저블,스테이트리스,스테이트리스 컴포저블,무상태,무상태 컴포저블', '상태를 스스로 들고 있지 않고 값과 변경 콜백을 인자로만 받는 컴포저블이 Stateless다. 그래서 미리보기나 UI 테스트에서 원하는 값을 그대로 주입해 여러 화면을 즉시 확인할 수 있다. 반대로 선택 조건을 remember로 직접 들고 있는 필터 바는 Stateful 컴포저블이라 바깥에서 화면을 지정할 수 없고, 클릭을 흉내 내는 우회가 필요해진다. Stateless로 만드는 수단이 상태 호이스팅이며, 얼마나 높이 올릴지는 그 값을 읽고 쓰는 모든 컴포저블의 가장 가까운 공통 부모까지가 기준이다.');

-- =====================================================
-- Lesson 753: remember 키와 상태 홀더 선택
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4697, 753, '아래 컴포저블이 새 인자로 재구성된 뒤 화면에 표시되는 문구로 옳은 것은?', '```kotlin
@Composable
fun DiscountLabel(price: Int, rate: Int) {
    val discounted = remember { price - price * rate / 100 }
    Text("$price → $discounted")
}
```

이 컴포저블은 처음에 DiscountLabel(price = 800, rate = 10)으로 그려졌다. 잠시 뒤 같은 자리에서 DiscountLabel(price = 900, rate = 25)로 다시 호출되어 재구성이 일어났다.', 'OBJECTIVE'),
       (4698, 753, '아래 표를 바탕으로 상태를 둘 위치를 정한 판단으로 옳은 것은?', '| 상태를 두는 위치 | 수명 | 담는 상태 |
| --- | --- | --- |
| 컴포저블 내부(remember) | 컴포지션 위치 | 단순한 UI 상태 한두 개 |
| 일반 상태 홀더 클래스 | 컴포지션 위치(remember로 생성) | 여러 UI 상태와 거기 딸린 UI 로직 |
| ViewModel | 화면(소유자) 수명 | 화면 데이터와 비즈니스 로직 |', 'OBJECTIVE'),
       (4699, 753, '아래 화면이 예외 없이 뜨고 회전 뒤에도 필터가 복원되게 하려면 필요한 조치로 옳은 것은?', '```kotlin
data class Filter(val keyword: String, val onlyActive: Boolean)

@Composable
fun FilterBar() {
    var filter by rememberSaveable { mutableStateOf(Filter("", false)) }
    TextField(value = filter.keyword, onValueChange = { filter = filter.copy(keyword = it) })
}
```

이 화면을 열면 필터 값을 저장할 수 없다는 예외가 나면서 화면이 그려지지 않는다. Filter는 Bundle이 기본으로 다루는 타입 목록에 없다.', 'OBJECTIVE'),
       (4700, 753, '아래 화면에서 정렬 기준 상태를 둘 위치로 옳은 것은?', '피드 화면은 세 부분으로 이뤄진다. 위쪽 정렬 칩은 누를 때마다 정렬 기준을 바꾸고, 그 아래 요약 문구는 지금 정렬 기준을 문장으로 보여 주며, 맨 아래 목록은 그 기준에 맞춰 글을 정렬해 그린다. 세 부분은 피드 화면 컴포저블이 한 Column 안에서 나란히 호출한다. 정렬 기준은 화면을 벗어나면 기본값으로 돌아가도 되고, 서버 요청이나 저장소 접근에는 쓰이지 않는다.', 'OBJECTIVE'),
       (4701, 753, '아래 증상을 없애려면 ViewModel이 함께 써야 하는 것의 이름은?', '중고 거래 앱의 검색 결과 화면은 사용자가 고른 지역과 가격대 조건을 ViewModel이 들고 있다. 기기를 가로로 돌려도 조건은 그대로 남는다. 그런데 사진을 고르러 다른 앱을 한참 쓰다가 돌아오면, 시스템이 그사이 앱을 정리한 경우에 한해 조건이 모두 초기값으로 되돌아가 있다.

이 조건은 화면이 그리는 데이터라 ViewModel에 그대로 두고, 별도 저장소나 서버를 거치지 않고 해결하려 한다.', 'SUBJECTIVE'),
       (4702, 753, '아래 코드에서 프로퍼티 선언은 그대로 둔 채 선언 바로 아래에 덧붙여야 할 한 줄은?', '```kotlin
class SessionViewModel : ViewModel() {
    var isLoggedIn by mutableStateOf(false)

    fun logout() {
        clearToken()
        isLoggedIn = false
    }
}
```

코드 리뷰에서 이런 지적이 나왔다. 한 화면이 logout()을 거치지 않고 화면 코드에서 곧바로 viewModel.isLoggedIn = false로 값을 바꿔 두어, 토큰이 남은 채 로그인 화면이 떴다. 화면에서 값을 읽는 코드는 지금 그대로 두고, 바깥에서의 대입만 컴파일 단계에서 막으려 한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4697
(12699, 4697, '900 → 675', '인자가 바뀌면 remember 블록도 따라서 다시 실행된다는 오해다. 키를 넘기지 않은 remember는 인자 변화를 신호로 받지 못해 새 rate로 계산할 기회 자체가 없다.', false),
(12700, 4697, '900 → 720', 'price는 매 호출마다 새로 받는 인자라 900으로 바뀌지만, discounted는 첫 컴포지션 때 계산해 그 자리에 저장해 둔 720이 그대로 나온다. 인자에 따라 달라져야 하는 계산에는 remember(price, rate) { } 처럼 키가 필요하다.', true),
(12701, 4697, '800 → 720', 'remember가 컴포저블 전체를 얼려 인자 표시까지 옛 값에 묶어 둔다는 오해다. 보관되는 것은 블록의 계산 결과뿐이고, 인자는 재구성 때마다 새 값이 들어온다.', false),
(12702, 4697, '900 → 0', '재구성 때 블록이 실행되지 않으니 변수도 비워진다는 오해다. remember는 값을 버리는 것이 아니라 저장해 둔 값을 다시 꺼내 돌려주므로 720이 유지된다.', false),

-- 문제 4698
(12703, 4698, '서버에서 받아 온 목록은 이 화면에서만 쓰이므로 컴포저블 내부에 remember로 두는 편이 단순하다.', '화면 데이터는 화면 수명을 따라야 한다. 컴포지션 위치에 묶어 두면 회전할 때마다 목록을 다시 불러오게 되고, 비동기 작업과 저장소 접근까지 컴포저블 안으로 끌려 들어온다.', false),
(12704, 4698, '애니메이션 진행 값처럼 프레임마다 바뀌는 값도 ViewModel에 두어야 재구성 사이에 유지된다.', '재구성 사이 유지는 세 위치가 모두 해 준다. 화면 수명까지는 필요 없는 UI 전용 값을 올리면 화면 그리기 세부 사항이 비즈니스 로직 자리로 섞여 들어갈 뿐이다.', false),
(12705, 4698, '입력 칸 여러 개의 검사 로직이 한 컴포저블에 쌓여 비대해졌고 회전 뒤 값이 남을 필요는 없다면 상태 홀더 클래스가 맞다.', '여러 UI 상태와 거기 딸린 로직을 한 덩어리로 묶는 자리가 상태 홀더 클래스다. 수명이 컴포지션 위치라 회전 생존이 요구되지 않을 때는 ViewModel까지 가지 않아도 된다.', true),
(12706, 4698, '상태 홀더 클래스로 옮긴 값은 클래스 인스턴스가 따로 살아 있어 화면을 돌려도 그대로 남는다.', '이 클래스는 remember로 만들어져 수명이 컴포지션 위치에 묶인다. 회전으로 컴포지션이 다시 만들어지면 인스턴스도 새로 생기므로, 값을 남기려면 Saver로 감싸거나 ViewModel로 올려야 한다.', false),

-- 문제 4699
(12707, 4699, 'mapSaver나 listSaver로 Filter를 Bundle이 아는 형태로 바꾸는 Saver를 만들어 stateSaver 인자로 넘긴다.', 'rememberSaveable은 Bundle이 아는 타입만 알아서 처리한다. 사용자 정의 타입은 저장할 때 Map이나 List로 풀고 복원할 때 되돌리는 변환 규칙을 직접 정의해 넘겨야 한다.', true),
(12708, 4699, 'rememberSaveable을 remember(filter) 형태로 바꿔 키가 바뀔 때마다 값이 다시 만들어지게 한다.', '키는 언제 다시 계산할지를 정할 뿐 저장과는 무관하다. remember로 내리면 회전 때 컴포지션과 함께 값이 사라져, 애초에 노리던 복원이 아예 불가능해진다.', false),
(12709, 4699, 'Filter를 data class에서 일반 class로 바꾸고 @Stable을 붙여 저장 방식을 추론하게 한다.', '@Stable은 재구성을 건너뛰어도 되는지 판단하는 안정성 표시일 뿐 직렬화와 관계가 없다. 표시를 붙여도 Bundle은 이 타입을 담는 방법을 알지 못한다.', false),
(12710, 4699, 'Filter의 두 필드를 각각 mutableStateOf로 감싸 상태 객체로 만든다.', '변경 감지 문제와 저장 문제를 뒤섞은 것이다. 상태 객체로 만들면 값이 바뀔 때 재구성은 잘 일어나지만, Bundle에 담기지 못한다는 사정은 조금도 달라지지 않는다.', false),

-- 문제 4700
(12711, 4700, '정렬 칩 컴포저블 안에 remember로 두고, 요약 문구와 목록이 그 값을 읽어 가게 한다.', '컴포저블 내부 상태는 바깥에서 읽을 길이 없다. 형제는 물론 부모도 자식이 품은 값을 꺼낼 수 없어, 칩만 새 기준으로 바뀌고 요약 문구와 목록은 그대로 남는다.', false),
(12712, 4700, '세 부분이 각각 remember로 같은 이름의 상태를 선언해 같은 값을 보게 한다.', '이름이 같아도 컴포지션 위치마다 별개의 상태가 만들어진다. 같은 정보를 세 곳이 나눠 가지면 어느 쪽이 진짜 기준인지 알 수 없어져 단일 진실 원천이 깨진다.', false),
(12713, 4700, '어차피 화면 전체가 쓰는 값이므로 ViewModel까지 올려 화면 수명 내내 들고 있게 한다.', '필요 이상으로 올린 경우다. 화면을 벗어나면 기본값으로 돌아가도 되고 서버나 저장소와도 무관한 UI 전용 값이라, ViewModel에 두면 화면 그리기 사정이 그쪽으로 새어 든다.', false),
(12714, 4700, '세 부분을 함께 호출하는 피드 화면 컴포저블에 두고, 값과 변경 콜백을 인자로 내려 준다.', '그 값을 읽고 쓰는 컴포저블들의 가장 가까운 공통 부모가 소유자로 알맞다. 상태는 아래로, 이벤트는 위로 흐르게 되어 칩을 누르면 요약 문구와 목록이 같은 기준으로 함께 바뀐다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1522, 4701, 'SavedStateHandle,saved state handle,세이브드 스테이트 핸들,세이브드스테이트핸들', 'ViewModel 인스턴스는 구성 변경은 견디지만 프로세스가 정리되면 함께 사라진다. 회전은 멀쩡한데 앱이 백그라운드에서 정리된 뒤에만 값이 초기화되는 증상이 이 차이를 그대로 보여 준다. SavedStateHandle은 ViewModel이 생성자로 받아 쓰는 키-값 저장소로, 담아 둔 값을 저장된 상태에 함께 실어 두었다가 프로세스가 되살아날 때 돌려준다. 컴포저블 쪽의 rememberSaveable과 하는 일이 닮았지만, rememberSaveable은 컴포지션에서 제거되면 값도 함께 사라지므로 화면 수명 내내 살아 있어야 하는 화면 데이터에는 맞지 않는다. 둘 다 Bundle을 거치므로 큰 목록이나 이미지는 넣지 않고 식별자만 남긴 뒤 저장소에서 다시 불러오는 것이 원칙이다.'),
       (1523, 4702, 'private set,privateset,프라이빗 셋,프라이빗셋', 'Kotlin은 프로퍼티의 게터와 세터에 서로 다른 가시성을 줄 수 있어, 선언 아래에 private set 한 줄만 붙이면 읽기는 지금처럼 공개된 채 대입만 클래스 안으로 막힌다. 화면은 값을 보기만 하고 바꾸려면 logout() 같은 함수를 부르게 되어, 상태는 아래로 이벤트는 위로 흐르는 단방향 데이터 흐름이 지켜진다. StateFlow를 쓸 때 MutableStateFlow를 감추고 asStateFlow()로 읽기 전용만 내보내는 것도 같은 목적의 관례다. 프로퍼티 자체를 private으로 감추면 화면이 값을 읽지 못하고, val로 바꾸면 ViewModel 안에서도 값을 바꿀 수 없어 둘 다 이 요구와는 맞지 않는다.');

-- =====================================================
-- Lesson 911: Compose 상태 관리 — 값이 사라지거나 어긋나는 이유 추적하기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5645, 911, '아래 조작의 3번 직후 입력 칸에 보이는 값과 그 이유로 옳은 것은?', '```kotlin
@Composable
fun ChatRoom(roomId: String) {
    var draft by remember(roomId) { mutableStateOf("") }
    Column {
        Text("방: $roomId")
        TextField(value = draft, onValueChange = { draft = it })
    }
}
```

채팅 앱은 위쪽 탭에서 방을 고르면 화면의 같은 자리에서 ChatRoom을 새 roomId로 다시 호출한다. 사용자가 다음 순서로 조작했다.

1. A방에서 입력 칸에 "내일 봐"를 입력한다.
2. B방 탭을 누르고 입력 칸에 "회의 몇 시?"를 입력한다.
3. 다시 A방 탭을 누른다.', 'OBJECTIVE'),
       (5646, 911, '아래 네 방식 중 버튼을 누르자마자 새 태그가 화면에 나타나는 방식만 모두 고른 것은?', '버튼을 누르면 태그 하나를 추가하는 화면을 네 가지 방식으로 만들었다. 네 방식 모두 화면은 리스트의 원소를 Text로 하나씩 그린다.

| 방식 | 상태 선언 | 버튼의 onClick |
| --- | --- | --- |
| A | `var tags by remember { mutableStateOf(listOf<String>()) }` | `tags = tags + "새 태그"` |
| B | `val tags = remember { mutableStateOf(mutableListOf<String>()) }` | `tags.value.add("새 태그")` |
| C | `val tags = remember { mutableStateListOf<String>() }` | `tags.add("새 태그")` |
| D | `val tags = remember { mutableListOf<String>() }` | `tags.add("새 태그")` |', 'OBJECTIVE'),
       (5647, 911, '아래 증상을 고치는 방법으로 옳은 것은?', '쇼핑 앱의 상품 목록 화면은 서버에서 받은 상품 1,200개(각 상품의 썸네일 이미지 바이트 포함)와 사용자가 고른 상품을 모두 rememberSaveable에 담아 두었다. 목록을 보다가 홈 버튼을 눌러 앱을 백그라운드로 보내는 순간 앱이 종료되고 아래 로그가 남았다.

```
E/AndroidRuntime: FATAL EXCEPTION: main
java.lang.RuntimeException: android.os.TransactionTooLargeException: data parcel size 2418660 bytes
```

화면 회전이나 프로세스 종료 뒤에도 사용자가 보던 목록과 고른 상품이 다시 보여야 한다는 요구는 그대로 지켜야 한다.', 'OBJECTIVE'),
       (5648, 911, '아래 가입 화면을 회전한 직후의 모습으로 옳은 것은?', '```kotlin
@Stable
class SignUpFormState(initialEmail: String = "") {
    var email by mutableStateOf(initialEmail)
        private set
    var password by mutableStateOf("")
        private set
    val canSubmit: Boolean
        get() = email.contains("@") && password.length >= 8

    fun onEmailChange(value: String) { email = value }
    fun onPasswordChange(value: String) { password = value }
}

val SignUpFormStateSaver = listSaver<SignUpFormState, String>(
    save = { listOf(it.email) },
    restore = { SignUpFormState(initialEmail = it[0]) },
)

@Composable
fun rememberSignUpFormState(): SignUpFormState =
    rememberSaveable(saver = SignUpFormStateSaver) { SignUpFormState() }
```

가입 화면은 val state = rememberSignUpFormState()로 상태 홀더를 만들고, 두 입력 칸은 state.email과 state.password를, 가입 버튼은 enabled = state.canSubmit으로 그린다. 사용자가 이메일 kim@inu.ac.kr과 10자리 비밀번호를 입력해 가입 버튼이 활성화된 상태에서 기기를 가로로 돌렸다.', 'OBJECTIVE'),
       (5649, 911, '아래 코드와 증상에서 지켜지지 않은 상태 설계 원칙을 가리키는 용어는?', '프로필 수정 화면의 코드다.

```kotlin
@Composable
fun ProfileScreen(viewModel: ProfileViewModel = hiltViewModel()) {
    val nickname by viewModel.nickname.collectAsStateWithLifecycle()
    NicknameEditor(initial = nickname, onSave = viewModel::saveNickname)
}

@Composable
fun NicknameEditor(initial: String, onSave: (String) -> Unit) {
    var text by remember { mutableStateOf(initial) }
    Column {
        TextField(value = text, onValueChange = { text = it })
        Button(onClick = { onSave(text) }) { Text("저장") }
    }
}
```

화면이 처음 뜰 때는 서버 응답 전이라 nickname이 빈 문자열이었다. 곧 ViewModel이 서버에서 받은 "하늘"로 nickname을 바꾸었고 ProfileScreen도 다시 그려졌지만, 입력 칸은 계속 빈 칸이었다. 디버거로 같은 시점을 확인하니 viewModel.nickname은 "하늘", NicknameEditor의 text는 빈 문자열이었다. 사용자가 이 상태로 저장을 누르자 서버의 닉네임이 빈 문자열로 덮어써졌다.', 'SUBJECTIVE'),
       (5650, 911, '아래 변경 전후 코드에 적용된 Compose 설계 기법의 이름은?', '리뷰 작성 화면의 별점 컴포저블을 아래처럼 바꾸었다.

```kotlin
// 변경 전
@Composable
fun RatingBar() {
    var stars by remember { mutableStateOf(0) }
    Row {
        (1..5).forEach { i ->
            Star(filled = i <= stars, onClick = { stars = i })
        }
    }
}

// 변경 후
@Composable
fun RatingBar(stars: Int, onStarsChange: (Int) -> Unit) {
    Row {
        (1..5).forEach { i ->
            Star(filled = i <= stars, onClick = { onStarsChange(i) })
        }
    }
}
```

변경 전에는 리뷰 작성 화면이 별점이 몇 개인지 알 방법이 없어 별점을 고르지 않아도 등록 버튼이 눌렸다. 변경 후에는 별점이 0이면 등록 버튼을 비활성화할 수 있게 되었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5645
(15227, 5645, '"내일 봐"가 다시 보인다. remember가 키마다 값을 따로 보관해 두었다가 같은 키가 돌아오면 그 값을 꺼내 주기 때문이다.', 'remember를 키별 저장소로 본 오해다. remember는 그 자리에 값 하나만 두고 직전 키와 비교할 뿐이라, 키가 A에서 B로 바뀐 순간 A 때의 값은 이미 버려졌다. 방마다 초안을 남기려면 방 ID별로 값을 모아 두는 상위 소유자가 필요하다.', false),
(15228, 5645, '"회의 몇 시?"가 그대로 보인다. 키는 첫 계산 시점만 정할 뿐, 이후 재구성에서는 저장해 둔 값을 계속 돌려주기 때문이다.', '키를 넘기지 않은 remember의 동작과 혼동한 것이다. 키를 넘기면 재구성 때마다 직전 키와 비교해 달라졌을 때 블록을 다시 실행하므로, B에서 A로 바뀐 순간 B 때 입력한 값도 버려진다.', false),
(15229, 5645, '빈 칸이 보인다. 방을 바꿀 때마다 ChatRoom이 트리에서 빠졌다가 다시 들어와 remember 자리가 새로 만들어지기 때문이다.', '결과는 맞지만 원인이 틀렸다. 같은 자리에서 인자만 바꿔 다시 호출하는 것은 재구성이라 ChatRoom은 트리에 그대로 남아 있다. 값이 새로 만들어진 것은 remember에 넘긴 키가 바뀌었기 때문이다.', false),
(15230, 5645, '빈 칸이 보인다. B에서 A로 돌아온 것도 키가 바뀐 것이라 블록이 다시 실행되어 새 상태 객체가 만들어지기 때문이다.', 'remember(roomId)는 재구성 때 직전 키와 비교해 다르면 블록을 다시 실행한다. B에서 A로 돌아온 것도 키 변경이라 mutableStateOf("")가 새로 만들어진다. 인자가 바뀔 때 상태를 새로 시작하게 하려고 키를 넘기는 것이다.', true),

-- 문제 5646
(15231, 5646, 'C', '새 리스트를 value에 대입하는 A도 감지된다는 점을 놓친 것이다. MutableState는 value에 담긴 참조가 바뀌면 그 값을 읽은 컴포저블을 무효화하므로, tags + "새 태그"로 만든 새 리스트를 대입하면 곧바로 재구성된다.', false),
(15232, 5646, 'A, C', 'A는 value에 새 리스트를 대입해 참조가 바뀌므로 감지되고, C는 mutableStateListOf가 만든 리스트라 add 같은 원소 단위 변경까지 추적된다. B와 D는 같은 리스트 객체의 안만 고칠 뿐 상태 쓰기가 일어나지 않는다.', true),
(15233, 5646, 'B, C', 'mutableStateOf로 감싸면 안에 든 리스트의 변경도 추적된다는 오해다. B의 add는 value가 가리키는 참조를 그대로 둔 채 내용만 고치므로 무효화가 없고, 항목은 다른 이유로 재구성될 때에야 한꺼번에 나타난다.', false),
(15234, 5646, 'A, B, C', '상태 객체로 감싸기만 하면 어떻게 고쳐도 반영된다는 오해다. 감지는 상태 객체에 쓰기가 일어날 때만 되는데, B는 value를 다시 대입하지 않고 리스트 내부만 고쳐 쓰기가 한 번도 일어나지 않는다.', false),

-- 문제 5647
(15235, 5647, '고른 상품의 ID만 rememberSaveable에 남기고, 상품 목록은 ViewModel이 저장소에서 다시 불러오게 한다.', 'rememberSaveable은 값을 Bundle에 실어 시스템 쪽으로 넘기므로 큰 목록이나 이미지 바이트를 담으면 전송 한도를 넘는다. 복원에 꼭 필요한 식별자만 남기고 화면 데이터는 ViewModel이 다시 불러오면 회전·프로세스 종료 뒤에도 같은 화면이 되살아난다.', true),
(15236, 5647, 'rememberSaveable을 remember로 바꿔 상품 목록과 고른 상품을 Bundle에 싣지 않게 한다.', '앱 종료는 멈추지만 요구를 저버린 것이다. remember는 회전 때 컴포지션과 함께 사라지고 프로세스 종료 뒤에도 복원되지 않아, 사용자가 보던 목록과 고른 상품이 모두 초기화된다.', false),
(15237, 5647, '상품 목록을 Map 형태로 풀어 저장하는 Saver를 만들어 stateSaver 인자로 넘긴다.', 'Saver는 Bundle이 모르는 타입을 담을 수 있는 형태로 바꿔 줄 뿐 담기는 양을 줄이지 않는다. 형태만 Map으로 바뀌고 상품 1,200개와 이미지 바이트가 그대로 Bundle에 실려 같은 예외가 난다.', false),
(15238, 5647, '상품 목록을 mutableStateListOf로 바꿔 바뀐 원소만 골라 Bundle에 저장되게 한다.', '변경 추적과 저장을 혼동한 것이다. mutableStateListOf는 원소가 바뀔 때 재구성을 일으키려는 도구일 뿐 저장 방식과는 관계가 없다. 바뀐 원소만 골라 저장하는 기능은 없어 큰 목록을 Bundle로 보내는 구조가 그대로 남는다.', false),

-- 문제 5648
(15239, 5648, '이메일과 비밀번호가 모두 남고, 가입 버튼도 회전 전처럼 활성 상태다.', 'rememberSaveable이 객체 전체를 알아서 저장한다는 오해다. 사용자 정의 타입은 Saver가 담은 값만 Bundle에 남는데, 이 Saver의 save는 email 하나만 리스트에 담고 password는 버린다.', false),
(15240, 5648, '이메일과 비밀번호가 모두 빈 칸이 되고, 가입 버튼은 비활성이 된다.', '상태 홀더는 remember로 만들어져 회전을 견디지 못한다고 본 오해다. rememberSignUpFormState()는 rememberSaveable과 Saver로 인스턴스를 감싸므로, 회전 뒤 Saver가 남긴 값으로 새 인스턴스를 만들어 준다.', false),
(15241, 5648, '이메일만 남고 비밀번호는 빈 칸이 되며, 가입 버튼은 비활성이 된다.', 'save가 email만 담았으므로 복원 때 SignUpFormState(initialEmail = it[0])로 이메일만 되살아나고 password는 초기값인 빈 문자열이 된다. canSubmit은 읽을 때마다 계산하는 게터라 비밀번호 길이 조건에 걸려 false다.', true),
(15242, 5648, '이메일만 남고 비밀번호는 빈 칸이 되지만, 가입 버튼은 회전 전처럼 활성 상태다.', 'canSubmit을 회전 전 결과가 보관된 값으로 본 오해다. 이 프로퍼티는 읽을 때마다 email과 password를 다시 확인하는 게터라, 복원된 새 인스턴스에서는 빈 비밀번호 때문에 false가 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1838, 5649, '단일 진실 원천,단일 진실의 원천,단일 진실 공급원,단일 정보 원천,유일한 진실 원천,신뢰할 수 있는 단일 출처,Single Source of Truth,SingleSourceOfTruth,SSOT', '같은 닉네임을 ViewModel의 nickname과 NicknameEditor의 text가 따로 들고 있어 두 값이 어긋났다. remember { mutableStateOf(initial) }는 첫 호출 때의 initial로 복사본을 만든 뒤 이후 인자 변화를 따라가지 않으므로, ViewModel 값이 "하늘"로 바뀌어도 입력 칸은 빈 문자열에 머물고 그 값이 저장으로 서버까지 덮어썼다. 단일 진실 원천은 한 정보의 소유자를 하나로 정하고 나머지는 그 값을 받아 그리기만 하게 하라는 원칙이다. 입력 중인 값까지 ViewModel이 들게 하고 NicknameEditor는 값과 변경 콜백만 받게 바꾸면 이 버그가 사라진다. 상태 호이스팅은 이 원칙을 지키기 위해 상태를 끌어올리는 기법이고, 단방향 데이터 흐름은 상태가 아래로·이벤트가 위로 흐르는 경로를 가리키는 말이라, 같은 정보가 두 벌 생긴 이 버그의 원인을 직접 부르는 이름과는 구분한다.'),
       (1839, 5650, '상태 호이스팅,상태호이스팅,상태 끌어올리기,상태끌어올리기,State Hoisting,StateHoisting,스테이트 호이스팅,호이스팅,hoisting', '변경 전 RatingBar는 별점을 remember로 스스로 들고 있는 Stateful 컴포저블이라 바깥에서는 별점을 읽을 수 없었다. 변경 후에는 별점 상태를 호출하는 쪽으로 끌어올리고, RatingBar는 값(stars)과 변경 요청 콜백(onStarsChange)만 받는 Stateless 컴포저블이 되었다. 이것이 상태 호이스팅이다. 그 결과 상태는 아래로, 이벤트는 위로 흐르는 단방향 데이터 흐름이 생겨 리뷰 작성 화면이 별점을 읽고 등록 버튼을 제어할 수 있다. 단방향 데이터 흐름은 호이스팅으로 생기는 흐름의 이름이고 Stateless는 호이스팅을 거친 컴포저블의 분류라, 적용한 기법의 이름과는 구분한다. 얼마나 높이 올릴지는 그 값을 읽고 쓰는 모든 컴포저블의 가장 가까운 공통 부모까지가 기준이다.');
