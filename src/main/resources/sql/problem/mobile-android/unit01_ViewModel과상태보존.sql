-- Unit: ViewModel과 상태 보존 (Unit ID: 167)
-- Chapter: Android (Chapter ID: 16)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (593, 167, '프로세스 종료 복원과 저장 크기 한도'),
       (751, 167, 'onCleared 호출 조건과 보관 위치'),
       (909, 167, 'ViewModel 수명 추적과 상태 저장의 한계');

-- =====================================================
-- Lesson 593: 프로세스 종료 복원과 저장 크기 한도
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3737, 593, '아래 화면에서 사용자가 기기를 회전했을 때 일어나는 동작으로 옳은 것은?', '```kotlin
class FeedViewModel : ViewModel() {
    val items = MutableStateFlow<List<Item>>(emptyList())
    var lastQuery: String = ""
}

class FeedActivity : AppCompatActivity() {
    private val viewModel: FeedViewModel by viewModels()
    private var scrollIndex: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (viewModel.items.value.isEmpty()) {
            lifecycleScope.launch { viewModel.items.value = repository.load() }
        }
    }
}
```

회전 직전 상태: items에 30건이 담겨 있고, lastQuery는 "안드로이드", scrollIndex는 12다.', 'OBJECTIVE'),
       (3738, 593, '아래 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '| 상황 | Activity | ViewModel | SavedStateHandle |
|---|---|---|---|
| 화면 회전(구성 변경) | 재생성 | 유지 | 유지 |
| 뒤로 가기·finish() | 종료 | 폐기 | 폐기 |
| 백그라운드에서 프로세스 종료 | 복원 재생성 | 새로 생성 | Bundle에서 복원 |', 'OBJECTIVE'),
       (3739, 593, '아래에서 설명하는 ViewModel 소유자 지정 방식에 대한 설명으로 옳은 것은?', '한 Activity 위에 목록 Fragment와 상세 Fragment가 차례로 올라간다. 두 Fragment는 같은 선택 항목을 다뤄야 해서, 각자 자기 자신을 소유자로 두지 않고 호스트 Activity를 ViewModelStoreOwner로 지정해 ViewModel을 가져오도록 만들었다.', 'OBJECTIVE'),
       (3740, 593, '아래 코드로 만든 화면에서 회전을 여러 번 반복할 때 생기는 문제로 옳은 것은?', '```kotlin
class ReportViewModel(private val activity: ReportActivity) : ViewModel() {
    private val titleView = activity.findViewById<TextView>(R.id.title)

    fun showDone() {
        titleView.text = "완료"
    }
}

class ReportActivity : AppCompatActivity() {
    private val viewModel: ReportViewModel by viewModels {
        ReportViewModelFactory(this)
    }
}
```', 'OBJECTIVE'),
       (3741, 593, '아래 상황에서 사라진 입력값을 지키려면 ViewModel이 생성자로 받아 써야 하는 것의 이름은?', '검색 화면에 "안드로이드 면접"을 입력한 뒤 홈 버튼으로 앱을 벗어났다. 다른 앱을 한참 쓰다 돌아오니 화면은 다시 그려졌지만 입력창은 비어 있었다. 화면을 수십 번 회전시켜 본 테스트에서는 한 번도 재현되지 않았고, 개발자 옵션의 "액티비티 유지 안 함"을 켜자 매번 재현됐다.', 'SUBJECTIVE'),
       (3742, 593, '아래 상황에서 앱을 강제 종료시킨 예외의 이름은?', '검색 결과 3,000건을 통째로 상태 저장 키에 담아 두는 코드를 넣은 뒤부터, 홈 버튼을 눌러 앱을 벗어나는 순간 앱이 죽었다. 로그에는 시스템으로 넘기려던 데이터 묶음의 크기가 1,052,436바이트로 찍혀 있었다. 저장 대상을 결과 ID 20개와 검색어로 줄이자 더는 재현되지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3737
(10139, 3737, 'scrollIndex는 0으로 돌아가지만 lastQuery는 "안드로이드"가 그대로 남는다.', 'Activity는 구성 변경으로 파괴·재생성돼 멤버 변수 scrollIndex가 초기값으로 돌아간다. 반면 ViewModelStore는 새 Activity 인스턴스로 넘겨져 같은 ViewModel을 돌려받으므로 lastQuery는 보존된다.', true),
(10140, 3737, 'scrollIndex와 lastQuery가 모두 회전 전 값을 그대로 유지한다.', 'Activity 필드도 함께 살아남는다고 본 오개념. 회전하면 Activity 인스턴스 자체가 새로 만들어지므로 그 안의 멤버 변수는 선언된 초기값으로 시작한다.', false),
(10141, 3737, 'items가 빈 목록으로 초기화되어 repository.load()가 다시 실행된다.', 'ViewModel도 Activity와 함께 재생성된다고 본 오개념. items에는 30건이 남아 있어 isEmpty() 조건이 거짓이 되므로 재요청 분기로 들어가지 않는다.', false),
(10142, 3737, 'onCleared()가 호출된 뒤 새 ViewModel이 만들어져 lastQuery가 빈 문자열이 된다.', 'onDestroy와 onCleared를 같은 시점으로 본 오개념. onCleared()는 소유자가 완전히 종료될 때만 호출되고, 구성 변경으로 인한 onDestroy에서는 호출되지 않는다.', false),

-- 문제 3738
(10143, 3738, '검색어를 SavedStateHandle에 담아 두면 백그라운드에서 프로세스가 종료된 뒤 돌아와도 입력값을 되살릴 수 있다.', '프로세스 종료 시 ViewModel은 초기 상태로 새로 만들어지지만 SavedStateHandle의 값은 Bundle에서 복원되므로, 검색어처럼 작은 키 값은 살아남는다. 옳은 진술이다.', false),
(10144, 3738, '뒤로 가기로 화면을 벗어났다가 다시 들어오면 직전 ViewModel이 그대로 이어져 목록을 다시 불러오지 않는다.', '뒤로 가기는 소유자를 완전히 종료시켜 onCleared() 후 ViewModel을 폐기한다. 다시 들어가면 빈 상태의 새 인스턴스를 받아 목록을 처음부터 불러오므로 이 진술은 거짓이다.', true),
(10145, 3738, '회전 테스트만 반복해서는 SavedStateHandle에 값을 담지 않은 실수를 잡아내기 어렵다.', '회전에서는 ViewModel이 유지돼 값이 살아 있는 것처럼 보인다. 저장 누락은 ViewModel이 사라지는 프로세스 종료 시나리오에서야 드러나므로 옳은 진술이다.', false),
(10146, 3738, '프로세스 종료 뒤 복원된 화면에서는 ViewModel이 들고 있던 목록을 다시 채워야 한다.', 'ViewModel은 메모리와 함께 사라져 초기 상태로 생성되므로 목록이 비어 있다. 복원된 키 값을 단서로 데이터를 다시 불러오는 코드가 필요하니 옳은 진술이다.', false),

-- 문제 3739
(10147, 3739, '두 Fragment가 각각 하나씩 인스턴스를 받아 한쪽에서 바꾼 값이 다른 쪽에 보이지 않는다.', 'Fragment마다 무조건 별도 인스턴스가 생긴다고 본 오개념. 인스턴스는 소유자의 ViewModelStore에 키로 보관되므로, 같은 소유자를 지정하면 이미 있는 인스턴스를 함께 쓴다.', false),
(10148, 3739, '구성 변경이 일어나면 공유하던 값이 초기화되므로 화면마다 다시 채워야 한다.', '소유자인 Activity가 재생성돼도 ViewModelStore는 새 인스턴스로 넘겨지므로 값이 유지된다. 값이 실제로 사라지는 시점은 구성 변경이 아니라 프로세스 종료다.', false),
(10149, 3739, '목록 Fragment가 백스택에서 제거돼도 인스턴스가 남아 상세 화면에서 이어 쓸 수 있다.', 'ViewModel의 수명은 지정한 소유자를 따라간다. 소유자가 호스트 Activity이므로 Fragment 하나가 사라져도 Activity가 살아 있는 한 onCleared()가 호출되지 않는다.', true),
(10150, 3739, '값을 주고받으려면 두 Fragment 사이에 Bundle 인자를 반드시 함께 넘겨야 한다.', '같은 인스턴스의 상태를 양쪽이 구독하므로 인자 전달이 필수는 아니다. Bundle 인자는 화면에 처음 들어갈 때 입력을 넘기는 별개의 수단이다.', false),

-- 문제 3740
(10151, 3740, '회전할 때마다 ViewModel이 새로 만들어져 보관하던 값이 초기화된다.', '구성 변경에서 ViewModel이 재생성된다고 본 오개념. ViewModelStore가 새 Activity로 넘겨져 같은 인스턴스가 유지되고, 바로 그 때문에 참조가 오래 남는 문제가 생긴다.', false),
(10152, 3740, 'onCleared()가 회전마다 호출돼 보관하던 상태가 매번 정리된다.', 'onCleared()는 소유자가 뒤로 가기나 finish()로 완전히 종료될 때만 호출된다. 회전은 종료가 아니라 재생성이므로 정리 시점이 오지 않는다.', false),
(10153, 3740, 'ViewModel 생성자에 인자가 있어 컴파일 단계에서 빌드가 실패한다.', 'ViewModelProvider.Factory를 함께 지정하면 생성자 인자가 있어도 빌드는 정상적으로 통과한다. 여기서 문제가 드러나는 지점은 빌드가 아니라 실행 중이다.', false),
(10154, 3740, '회전으로 파괴된 이전 Activity와 그 뷰가 계속 참조돼 메모리에서 해제되지 않는다.', 'ViewModel이 Activity보다 오래 살아남는데 처음 만들어질 때 받은 Activity와 그 뷰를 필드로 붙들고 있다. 회전할 때마다 죽은 화면이 회수되지 못하고 쌓인다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1202, 3741, 'SavedStateHandle,Saved State Handle,세이브드스테이트핸들,세이브드 스테이트 핸들', '회전에서는 ViewModelStore가 새 Activity로 넘겨져 ViewModel이 유지되므로 입력값이 살아 있는 것처럼 보인다. 하지만 백그라운드에서 시스템이 프로세스를 거두면 ViewModel도 메모리와 함께 사라져 초기 상태로 새로 생성된다. 이때 값을 되살리려면 Activity의 onSaveInstanceState 메커니즘을 ViewModel에서 쓸 수 있게 감싼 SavedStateHandle에 키 단위로 담아야 한다. 구성 변경까지만 버티는 ViewModel 자체와 다르고, 앱을 지웠다 깔기 전까지 남아야 하는 데이터를 두는 Room·DataStore 같은 영속 저장소와도 구분한다. 개발자 옵션의 "액티비티 유지 안 함"은 이 시나리오를 재현하는 도구다.'),
       (1203, 3742, 'TransactionTooLargeException,android.os.TransactionTooLargeException,Transaction Too Large Exception', 'SavedStateHandle에 담은 값은 Bundle로 묶여 시스템 프로세스로 건너가는데, 이 전달 통로에는 수백 KB 수준의 크기 한도가 있어 넘기면 TransactionTooLargeException이 발생한다. 힙이 부족해서 나는 OutOfMemoryError와 달리 메모리가 넉넉해도 한 번에 넘기는 묶음이 크면 터진다는 점이 구분점이다. 그래서 목록 전체가 아니라 ID·검색어·스크롤 위치처럼 복원에 꼭 필요한 소량의 키만 저장하고, 데이터 자체는 복원 후 다시 불러오는 것이 원칙이다.');

-- =====================================================
-- Lesson 751: onCleared 호출 조건과 보관 위치
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4685, 751, '아래 로그에서 ViewModel 객체가 마지막에 교체된 이유로 옳은 것은?', E'```\nApplication onCreate  pid=8123\nonCreate   activity=@a1c3  viewModel=@7f20  savedState=null\n--- 사용자가 기기를 가로로 회전 ---\nonDestroy  activity=@a1c3  isChangingConfigurations=true\nonCreate   activity=@b904  viewModel=@7f20  savedState=Bundle[{tab=2}]\n--- 홈 버튼으로 앱을 벗어난 뒤 다른 앱을 한참 쓰다가 앱 아이콘으로 복귀 ---\nApplication onCreate  pid=9047\nonCreate   activity=@e551  viewModel=@31ad  savedState=Bundle[{tab=2}]\n```', 'OBJECTIVE'),
       (4686, 751, '아래 상황에서 입력값이 사라진 원인으로 옳은 것은?', '설문 화면에서 사용자가 주관식 답변 다섯 칸을 모두 채운 뒤, 화면이 눈부시다며 알림창을 내려 시스템 다크 모드를 켰다. 설문 화면으로 돌아오니 다섯 칸이 전부 비어 있었다.

- 답변은 화면 클래스의 멤버 변수 MutableList에 담고 있었다.
- 로그에는 앱 프로세스가 새로 뜬 흔적이 남아 있지 않았다.
- QA 팀의 회전 테스트 목록에는 이 화면이 빠져 있었다.', 'OBJECTIVE'),
       (4687, 751, '아래 코드의 검색 화면이 프로세스 종료 뒤 복원됐을 때 나타나는 결과로 옳은 것은?', '```kotlin
class SearchViewModel(
    private val handle: SavedStateHandle,
    private val repository: SearchRepository,
) : ViewModel() {

    val query: StateFlow<String> = handle.getStateFlow(KEY_QUERY, "")
    private val _results = MutableStateFlow<List<Item>>(emptyList())
    val results: StateFlow<List<Item>> = _results.asStateFlow()

    init {
        handle[KEY_QUERY] = ""
        loadResults("")
    }

    fun onQueryChange(q: String) {
        handle[KEY_QUERY] = q
        loadResults(q)
    }

    // 비동기로 검색해 _results 를 갱신한다
    private fun loadResults(q: String) { ... }

    companion object { private const val KEY_QUERY = "query" }
}
```

프로세스가 종료되기 직전, 사용자는 검색창에 "코루틴"을 입력해 그 결과 목록을 보고 있었다.', 'OBJECTIVE'),
       (4688, 751, '아래 요구사항을 모두 만족하는 상태 보관 위치 배치로 옳은 것은?', '메모 작성 화면에는 상태 세 가지가 있다.

- ㉠ 글꼴 크기 조절 패널이 펼쳐져 있는지 여부
- ㉡ 서버에서 받아 와 추천으로 보여 주는 태그 목록
- ㉢ 사용자가 지금 타이핑하고 있는 본문 글

기획이 요구한 조건은 다음과 같다.

- ㉢은 사용자가 앱을 완전히 종료했다가 다시 켜도 그대로 남아 있어야 한다.
- ㉡은 화면에 들어올 때마다 최신이면 되지만, 기기를 회전할 때 다시 받느라 목록이 깜빡이는 것은 피하고 싶다.
- ㉠은 화면을 다시 그리는 동안만 유지되면 된다.', 'OBJECTIVE'),
       (4689, 751, '아래 코드에서 밑줄 자리에 들어갈 코루틴 스코프의 이름은?', '```kotlin
class SyncViewModel(private val repository: SyncRepository) : ViewModel() {

    fun startSync() {
        // 변경 전
        // CoroutineScope(Dispatchers.IO).launch { repository.sync() }

        // 변경 후
        ____.launch { repository.sync() }
    }
}
```

변경 전에는 동기화가 도는 동안 뒤로 가기로 화면을 완전히 벗어나도 요청이 끝까지 진행됐고, 이미 사라진 화면의 상태를 갱신하려다 경고 로그가 쌓였다. 변경 후에는 화면을 벗어난 직후 작업이 CancellationException과 함께 멈췄고 경고도 사라졌다.', 'SUBJECTIVE'),
       (4690, 751, '아래 로그의 (A) 자리에 찍힌 ViewModel 콜백 메서드의 이름은?', E'```\n--- 기기를 가로로 회전 ---\nonDestroy      activity=@c210  isChangingConfigurations=true\nCartViewModel  (콜백 호출 없음)\n\n--- 같은 화면에서 사용자가 뒤로 가기 ---\nonDestroy      activity=@d733  isChangingConfigurations=false\nCartViewModel  (A)  -> 등록해 둔 결제 리스너 해제, 보관하던 임시 장바구니 비움\n```\n\n회전 뒤 다시 그려진 화면은 같은 ViewModel 객체를 돌려받았고, 뒤로 가기 뒤 다시 들어간 화면은 빈 상태의 새 객체를 받았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4685
(12667, 4685, 'Activity 인스턴스가 새로 만들어질 때마다 ViewModel도 함께 새로 만들어지기 때문이다.', '회전 구간을 보면 activity는 @a1c3에서 @b904로 바뀌었는데 viewModel은 @7f20 그대로다. 화면 재생성 자체는 교체 사유가 되지 못한다는 반례가 로그 안에 이미 들어 있다.', false),
(12668, 4685, 'savedState가 Bundle에서 복원되면서 그 값으로 ViewModel을 다시 만들기 때문이다.', 'Bundle 복원과 ViewModel 생성을 한 동작으로 본 오개념. 회전 직후에도 savedState는 Bundle[{tab=2}]로 채워져 있었지만 viewModel 해시는 바뀌지 않았다.', false),
(12669, 4685, '앱 프로세스가 새로 떠서 이전 메모리에 있던 인스턴스가 하나도 남아 있지 않기 때문이다.', '마지막 구간에서 Application onCreate가 다시 찍히고 pid가 8123에서 9047로 바뀌었다. 이전 프로세스가 종료돼 메모리가 통째로 사라졌으니 ViewModel도 초기 상태로 새로 만들어진다.', true),
(12670, 4685, '홈 버튼으로 화면을 벗어날 때 소유자가 완전히 종료돼 보관하던 인스턴스가 정리되기 때문이다.', '홈 버튼을 뒤로 가기·finish()와 같게 본 오개념. 홈 버튼은 화면을 백그라운드로 내릴 뿐 소유자를 끝내지 않으므로, 이 로그에서 인스턴스를 잃은 계기는 정상 종료가 아니다.', false),

-- 문제 4686
(12671, 4686, '다크 모드 전환도 구성 변경이라 화면이 파괴·재생성됐고, 새 인스턴스의 멤버 변수가 초기값에서 시작했다.', '구성 변경은 회전만이 아니라 다크 모드·언어·글꼴 크기 변경까지 포함한다. 화면이 새 인스턴스로 다시 만들어지면 그 안의 멤버 변수는 선언된 초기값에서 출발하므로 담아 둔 답변이 사라진다.', true),
(12672, 4686, '시스템이 백그라운드에서 프로세스를 종료해 메모리에 있던 값이 함께 사라졌다.', '값이 사라지면 곧 프로세스 종료라고 본 오개념. 프로세스가 종료됐다면 앱이 처음부터 다시 뜬 기록이 로그에 남는데, 여기에는 그런 흔적이 없다.', false),
(12673, 4686, '구성 변경은 기기 회전에만 해당하므로, 원인은 답변을 가변 컬렉션에 담아 둔 데 있다.', '구성 변경을 회전으로만 좁혀 본 오개념. 컬렉션이 가변인지 불변인지는 화면 재생성과 무관하고, 어느 쪽을 써도 새 인스턴스에서는 빈 값으로 다시 시작한다.', false),
(12674, 4686, '화면이 onPause·onStop만 거쳤을 뿐 파괴되지 않아, 값은 남았는데 화면만 다시 그려지지 않았다.', '테마가 바뀌면 그에 맞는 리소스를 다시 읽어야 해서 화면은 파괴 후 재생성을 거친다. 값이 실제로 남아 있었다면 다시 그려진 화면의 입력칸에 그대로 보였을 것이다.', false),

-- 문제 4687
(12675, 4687, '검색창에 "코루틴"이 되살아나고 그때 보던 결과 목록도 함께 복원된다.', 'SavedStateHandle이 ViewModel의 다른 필드까지 되살린다고 본 오개념. 복원 대상은 키에 담아 둔 값뿐이라 _results는 새 인스턴스의 초기값인 빈 목록에서 출발한다.', false),
(12676, 4687, '검색창이 빈 채로 열리고, 목록은 빈 검색어로 다시 조회한 결과로 채워진다.', 'Bundle의 값은 handle에 실려 오지만 init이 곧바로 같은 키에 빈 문자열을 대입해 덮어쓴다. 이어 loadResults("")까지 돌기 때문에 복원한 검색어도, 그때 보던 목록도 화면에 남지 않는다.', true),
(12677, 4687, '검색창에는 "코루틴"이 남지만 목록이 비어 있어 사용자가 다시 검색해야 한다.', 'SavedStateHandle의 일반 원칙만 보고 init의 대입을 놓친 판단. 복원된 값은 뒤이어 실행되는 init의 대입에 덮이므로 화면까지 도달하지 못한다.', false),
(12678, 4687, '저장해 둔 키가 복원 과정에서 함께 지워져 검색창과 목록이 모두 빈 채로 열린다.', '프로세스가 종료되면 Bundle도 사라진다고 본 오개념. Bundle은 시스템이 대신 보관했다가 돌려주므로 값은 실제로 전달된다. 목록도 빈 검색어 조회 결과로 채워져 완전히 비어 있지는 않다.', false),

-- 문제 4688
(12679, 4688, '㉠은 화면 로컬 상태, ㉡은 ViewModel, ㉢은 SavedStateHandle에 둔다.', 'SavedStateHandle은 시스템이 거둬 간 프로세스를 복원하는 데까지가 한계라, 사용자가 앱을 완전히 종료하면 Bundle도 함께 사라져 ㉢ 요구를 못 지킨다. 길어지는 본문 글은 Bundle 크기 한도에도 걸린다.', false),
(12680, 4688, '㉠은 ViewModel, ㉡은 SavedStateHandle, ㉢은 영속 저장소에 둔다.', '생존 범위가 넓을수록 안전하다고 본 배치. ㉠은 다시 그리는 동안만 필요해 로컬로 충분하고, ㉡은 회전에서 ViewModel이 그대로 살아남으므로 목록 전체를 Bundle에 실을 이유가 없다.', false),
(12681, 4688, '㉠·㉡·㉢을 모두 ViewModel에 둔다.', '회전만 놓고 보면 셋 다 살아남지만, ViewModel은 소유자가 완전히 종료될 때 함께 폐기된다. 사용자가 앱을 껐다 켜면 ㉢이 사라지므로 첫 번째 조건을 어긴다.', false),
(12682, 4688, '㉠은 화면 로컬 상태, ㉡은 ViewModel, ㉢은 영속 저장소에 둔다.', '앱 재실행 뒤에도 필요한 것은 ㉢뿐이라 Room·DataStore 같은 영속 계층에 둔다. ㉡은 회전만 견디면 되니 ViewModel이 알맞고, ㉠은 다시 그리는 동안만 필요하니 화면 로컬 상태로 충분하다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1518, 4689, 'viewModelScope,viewModel Scope,뷰모델스코프,뷰모델 스코프,뷰 모델 스코프', 'ViewModel에는 자기 수명에 묶인 코루틴 스코프가 확장 프로퍼티로 붙어 있는데 그것이 viewModelScope다. 소유자가 완전히 종료돼 ViewModel이 폐기되는 시점에 이 스코프의 Job이 취소되므로, 안에서 돌던 코루틴은 CancellationException과 함께 멈춘다. 반면 직접 만든 CoroutineScope는 프레임워크의 정리 대상이 아니어서 화면이 사라진 뒤에도 계속 돌고, 이미 없는 화면의 상태를 건드리다 경고 로그나 메모리 누수로 이어진다. 화면이 보이는 동안만 수집을 이어 가는 lifecycleScope와는 소유자도 수명도 다르다는 점을 함께 구분해 두자.'),
       (1519, 4690, 'onCleared,onCleared(),ViewModel.onCleared,onCleared 메서드', 'ViewModel이 폐기되기 직전 딱 한 번 불리는 콜백이 onCleared()다. 로그가 보여 주듯 구성 변경으로 인한 onDestroy에서는 호출되지 않는데, 이때는 ViewModelStore가 새 화면 인스턴스로 그대로 넘어가 같은 객체를 다시 쓰기 때문이다. 뒤로 가기나 finish()처럼 소유자가 완전히 끝날 때만 호출되므로, 등록해 둔 리스너 해제 같은 정리를 여기에 모아 둔다. 화면이 사라질 때마다 불리는 onDestroy와는 호출 조건이 다르고, 시스템이 프로세스를 거둬 갈 때는 아예 호출되지 않을 수 있다는 점도 함께 기억해 두자.');

-- =====================================================
-- Lesson 909: ViewModel 수명 추적과 상태 저장의 한계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5633, 909, '아래 시나리오가 끝날 때까지 (A)의 fetchHeadlines()와 (B)의 fetchTrending()이 호출되는 횟수는?', '```kotlin
class NewsActivity : AppCompatActivity() {
    private var headlines: List<News> = emptyList()
    private val viewModel: NewsViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycleScope.launch { headlines = NewsApi.fetchHeadlines() }   // (A)
        lifecycleScope.launch {
            viewModel.trending.collect { renderTrending(it) }
        }
    }
}

class NewsViewModel : ViewModel() {
    private val _trending = MutableStateFlow<List<News>>(emptyList())
    val trending: StateFlow<List<News>> = _trending.asStateFlow()

    init {
        viewModelScope.launch { _trending.value = NewsApi.fetchTrending() }   // (B)
    }
}
```

시나리오

1. MainActivity에서 뉴스 버튼을 눌러 NewsActivity를 연다.
2. 기기를 세 번 회전한다.
3. 뒤로 가기로 MainActivity에 돌아왔다가, 뉴스 버튼을 눌러 NewsActivity를 다시 연다.

AndroidManifest에 android:configChanges 설정은 없고, 시나리오 내내 앱 프로세스는 종료되지 않았다.', 'OBJECTIVE'),
       (5634, 909, '아래 테스트 결과에서 ④에서만 작성 중이던 리뷰가 사라진 이유로 옳은 것은?', '리뷰 작성 화면은 사용자가 입력한 초안을 ViewModel이 생성자로 받은 SavedStateHandle의 draft 키에 저장한다. QA 팀이 초안을 입력해 둔 상태에서 네 가지 절차를 거친 뒤 화면을 다시 확인했다.

| 번호 | 절차 | 다시 본 입력창 |
|---|---|---|
| ① | 기기를 회전한다 | 초안 그대로 |
| ② | 개발자 옵션의 "액티비티 유지 안 함"을 켜고 홈 버튼으로 나갔다가 돌아온다 | 초안 그대로 |
| ③ | 홈 버튼으로 나가 고사양 게임을 오래 실행한 뒤 돌아온다 (로그에 앱 프로세스가 새로 시작된 기록) | 초안 그대로 |
| ④ | 최근 앱 목록에서 앱을 밀어 닫은 뒤 앱 아이콘으로 다시 실행한다 | 비어 있음 |', 'OBJECTIVE'),
       (5635, 909, '아래 saveScreenState()를 호출했을 때 예외가 발생하는 줄은?', '```kotlin
// kotlin-parcelize 플러그인 적용됨
data class SortOption(val field: String, val ascending: Boolean)

@Parcelize
data class PriceFilter(val min: Int, val max: Int) : Parcelable

class ShopViewModel(private val handle: SavedStateHandle) : ViewModel() {

    fun saveScreenState(photo: Uri) {
        handle["photo"] = photo                         // (가)
        handle["pickedIds"] = arrayListOf(3L, 7L)       // (나)
        handle["filter"] = PriceFilter(10000, 50000)    // (다)
        handle["sort"] = SortOption("price", true)      // (라)
    }
}
```', 'OBJECTIVE'),
       (5636, 909, '아래 과정에서 일어나는 일로 옳은 것은?', '화면 회전이나 다크 모드 전환이 일어나면 시스템은 기존 Activity를 onDestroy까지 진행시킨다. 다만 이 Activity가 ViewModel들을 담아 두던 저장소는 비우지 않고 메모리에 따로 맡겨 두었다가, 곧이어 만든 새 Activity 인스턴스에 그대로 넘겨준다. 새 Activity는 onCreate에서 by viewModels()로 ViewModel을 요청한다.', 'OBJECTIVE'),
       (5637, 909, '아래 누수 보고를 없애려고 고친 코드에서 빈칸에 들어갈 상위 클래스의 이름은?', 'PhotoActivity에서 기기를 회전하자 LeakCanary가 아래 보고를 남겼다.

```
1 retained object
├─ com.example.PhotoViewModel instance
│    ↓ PhotoViewModel.context
╰→ com.example.PhotoActivity instance
     Leaking: YES (Activity#mDestroyed is true)
```

PhotoViewModel은 문자열 리소스만 읽으면 된다는 점을 확인하고 아래처럼 고쳤다. 고친 뒤에는 Activity 쪽에서 Factory 없이 by viewModels()만 남겼는데도 ViewModel이 정상적으로 만들어졌고, 회전을 반복해도 보고가 더 나오지 않았다.

```kotlin
// 변경 전
class PhotoViewModel(private val context: Context) : ViewModel() {
    fun title() = context.getString(R.string.photo_title)
}
// PhotoActivity: by viewModels { PhotoViewModelFactory(this) }

// 변경 후
class PhotoViewModel(private val app: Application) : ______(app) {
    fun title() = app.getString(R.string.photo_title)
}
// PhotoActivity: by viewModels()
```', 'SUBJECTIVE'),
       (5638, 909, '아래 세 시도에서 괄호 안에 넘긴 객체들이 공통으로 구현하고 있어 그 자리의 인자 타입이 되는 인터페이스의 이름은?', '주문 흐름(장바구니 → 배송지 → 결제 확인)을 이루는 세 Fragment가 같은 주문 정보를 다뤄야 한다. 세 Fragment는 모두 MainActivity 하나 위에서 Navigation으로 전환되고, 주문 흐름은 order_graph라는 중첩 그래프로 묶여 있다. 개발자는 OrderViewModel을 얻는 코드를 세 번 바꿔 봤다.

- 시도 1: `ViewModelProvider(this)[OrderViewModel::class.java]` (각 Fragment 안에서 this) → 배송지 화면에서 입력한 주소가 결제 확인 화면에 보이지 않았다.
- 시도 2: `ViewModelProvider(requireActivity())[OrderViewModel::class.java]` → 세 화면이 주소를 공유했지만, 결제를 마치고 홈 Fragment로 돌아온 뒤에도 인스턴스가 남아 다음 주문에 이전 주소가 채워졌다.
- 시도 3: `ViewModelProvider(findNavController().getBackStackEntry(R.id.order_graph))[OrderViewModel::class.java]` → 세 화면이 주소를 공유했고, 주문 흐름을 빠져나오는 순간 onCleared()가 호출됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5633
(15195, 5633, '(A) 5회, (B) 5회', 'ViewModel도 Activity와 함께 새로 만들어진다고 본 오개념. 회전 때는 ViewModel을 담은 저장소가 새 Activity로 넘겨져 같은 인스턴스를 돌려받으므로, (B)가 있는 init 블록은 회전으로 다시 실행되지 않는다.', false),
(15196, 5633, '(A) 5회, (B) 2회', '(A)는 onCreate 안에 있어 처음 열 때 1회, 회전마다 1회씩 3회, 다시 열 때 1회로 모두 5회다. (B)는 ViewModel이 만들어질 때만 실행되므로 처음 1회, 뒤로 가기로 폐기된 뒤 새 인스턴스가 생길 때 1회로 2회다.', true),
(15197, 5633, '(A) 5회, (B) 1회', 'ViewModel이 화면을 떠난 뒤에도 남는다고 본 오개념. 뒤로 가기로 NewsActivity가 완전히 종료되면 onCleared() 후 ViewModel이 폐기되고, 다시 열 때 새 인스턴스의 init에서 (B)가 한 번 더 실행된다.', false),
(15198, 5633, '(A) 2회, (B) 2회', '회전해도 Activity가 그대로 유지된다고 본 오개념. 회전은 구성 변경이라 Activity가 파괴 후 재생성되고 onCreate가 매번 다시 불리므로, (A)는 회전할 때마다 새로 호출된다.', false),

-- 문제 5634
(15199, 5634, '사용자가 직접 앱을 닫은 경우로 보고, 시스템이 복원에 쓸 저장 상태까지 함께 버렸다.', 'SavedStateHandle의 값은 시스템이 거둬 간 화면을 되살릴 때 쓰인다. 최근 앱 목록에서 밀어 닫는 것은 사용자가 의도한 종료라 저장된 상태도 폐기되므로, 재실행 뒤에도 남기려면 Room·DataStore 같은 영속 저장소에 둬야 한다.', true),
(15200, 5634, '④는 시스템이 메모리 확보를 위해 프로세스를 거둔 경우라, SavedStateHandle도 함께 초기화됐다.', '프로세스 종료가 저장 상태까지 지운다고 본 오개념. 시스템이 프로세스를 거둔 경우는 ③이고, 거기서는 초안이 Bundle에서 복원됐다. 시스템 주도 종료를 견디게 하는 것이 바로 SavedStateHandle이다.', false),
(15201, 5634, '초안이 길어 Bundle 크기 한도를 넘는 바람에, ④에서만 저장이 조용히 건너뛰어졌다.', '크기 한도를 넘으면 조용히 건너뛰지 않고 TransactionTooLargeException으로 앱이 죽는다. 또 ②·③도 같은 저장 과정을 거쳤는데 초안이 복원됐으므로 크기는 원인이 아니다.', false),
(15202, 5634, 'init 블록이 draft 키를 빈 문자열로 덮어써서, 복원된 값이 화면까지 전달되지 않았다.', 'init의 덮어쓰기는 ViewModel이 새로 생길 때마다 일어나므로, ViewModel이 다시 만들어지는 ②·③에서도 초안이 비어야 한다. 두 절차 모두 초안이 남았으니 코드가 아니라 종료 방식이 원인이다.', false),

-- 문제 5635
(15203, 5635, '(가) 선택한 사진의 Uri를 담는 줄', '안드로이드 전용 객체라 저장할 수 없다고 본 오개념. Uri는 Parcelable을 구현하고 있어 Bundle에 그대로 들어가므로 SavedStateHandle에도 문제없이 저장된다.', false),
(15204, 5635, '(나) 상품 ID 목록을 ArrayList로 담는 줄', '컬렉션은 저장할 수 없다고 본 오개념. ArrayList는 Serializable이고 Bundle이 지원하는 타입이라, Long 같은 기본형 원소를 담은 목록은 그대로 저장된다.', false),
(15205, 5635, '(다) 가격 필터 객체를 담는 줄', '직접 만든 클래스는 모두 저장할 수 없다고 본 오개념. @Parcelize로 Parcelable을 구현한 클래스는 Bundle에 담을 수 있어 SavedStateHandle에도 저장된다.', false),
(15206, 5635, '(라) 정렬 기준 객체를 담는 줄', 'SavedStateHandle은 Bundle에 넣을 수 있는 타입만 받고, 값을 넣는 즉시 타입을 검사한다. SortOption은 data class일 뿐 Parcelable도 Serializable도 구현하지 않아 IllegalArgumentException이 발생한다.', true),

-- 문제 5636
(15207, 5636, '새 Activity가 ViewModel을 요청하는 순간 init 블록이 다시 실행돼 초기 로딩이 한 번 더 일어난다.', '요청할 때마다 객체가 새로 만들어진다고 본 오개념. 넘겨받은 저장소에 있던 기존 객체를 그대로 돌려받으므로, 생성자와 init은 그 객체가 처음 만들어질 때 한 번만 실행된다.', false),
(15208, 5636, 'ViewModel 객체가 직렬화돼 Bundle에 담겼다가 새 Activity에서 역직렬화되어 복원된다.', 'SavedStateHandle의 Bundle 복원과 섞은 오개념. 저장소는 직렬화 없이 메모리에 그대로 맡겨지므로, 프로세스가 종료되면 함께 사라지고 Bundle 크기 한도와도 무관하다.', false),
(15209, 5636, '직전에 viewModelScope에서 시작한 요청은 취소되지 않고 이어져, 새 화면이 그 결과를 받는다.', 'viewModelScope는 ViewModel이 폐기될 때만 취소된다. 이 과정에서는 onDestroy가 불려도 ViewModel이 폐기되지 않으므로, 진행 중이던 코루틴이 끝까지 돌고 새 화면은 같은 ViewModel의 상태를 구독해 결과를 받는다.', true),
(15210, 5636, '직전에 lifecycleScope에서 시작한 요청도 저장소와 함께 넘겨져, 새 화면에서 끝까지 이어진다.', 'lifecycleScope는 Activity 인스턴스의 수명에 묶여 있어 onDestroy가 불리면 취소된다. 새 Activity로 넘어가는 것은 ViewModel을 담은 저장소일 뿐, 이전 Activity에서 시작한 코루틴은 넘어가지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1834, 5637, 'AndroidViewModel,androidx.lifecycle.AndroidViewModel,Android ViewModel,안드로이드뷰모델,안드로이드 뷰모델,안드로이드 뷰 모델', 'AndroidViewModel은 생성자로 Application을 받는 ViewModel이다. Application Context는 앱 프로세스가 살아 있는 동안 하나뿐이라, ViewModel이 Activity보다 오래 살아도 이미 파괴된 화면을 붙들지 않는다. 변경 전에는 Factory에 this(Activity)를 넘겨, 회전 뒤에도 옛 PhotoActivity가 ViewModel의 context 필드에 묶여 회수되지 못했다. 기본 Factory가 Application 하나를 받는 생성자를 알아서 채워 주므로 별도 Factory도 필요 없어진다. Hilt를 쓴다면 @HiltViewModel과 @ApplicationContext로 같은 Context를 주입받는 방법도 있다. 다만 Application Context에는 Activity의 테마가 없으므로 뷰를 만들거나 테마 속성을 읽는 데는 쓰지 않는다는 점을 함께 구분해 두자.'),
       (1835, 5638, 'ViewModelStoreOwner,androidx.lifecycle.ViewModelStoreOwner,ViewModel Store Owner,ViewModelStore Owner,뷰모델스토어오너,뷰모델 스토어 오너,뷰 모델 스토어 오너', 'ViewModelProvider(owner)가 인자로 받는 타입은 ViewModelStoreOwner다. 이 인터페이스를 구현한 객체는 ViewModel을 키로 보관하는 ViewModelStore를 하나씩 갖고 있어서, 어떤 소유자를 넘기느냐에 따라 인스턴스를 공유하는 범위와 폐기 시점이 정해진다. Fragment를 넘기면 화면마다 따로, Activity를 넘기면 Activity가 끝날 때까지, NavBackStackEntry를 넘기면 그 그래프가 백스택에서 빠질 때까지 인스턴스가 산다. 세 객체는 생명주기 상태를 알려 주는 LifecycleOwner도 함께 구현하지만, LifecycleOwner는 ViewModel 저장소를 제공하지 않으므로 ViewModelProvider의 인자가 될 수 없다. 소유자가 가진 저장소 자체인 ViewModelStore와도 구분한다.');
