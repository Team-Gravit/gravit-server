-- Unit: 구성 변경과 상태 보존 (Unit ID: 94)
-- Chapter: AOS (Chapter ID: 8)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (520, 94, '뷰 상태 복원과 ViewModel 생존'),
       (678, 94, '보관 위치 선택과 Bundle 크기 한계'),
       (836, 94, '프로세스 종료 복원과 활동 유지 안 함');

-- =====================================================
-- Lesson 520: 뷰 상태 복원과 ViewModel 생존
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3299, 520, '아래 화면에서 기기를 가로로 회전했을 때 일어나는 일로 옳은 것은?', '글 작성 화면의 레이아웃과 액티비티 코드 일부다. onSaveInstanceState()는 재정의하지 않았다. 사용자는 두 입력란에 각각 글자를 채우고 첨부 버튼을 3번 눌러 attachCount를 3으로 만든 뒤 기기를 회전했다.

```xml
<EditText android:id="@+id/etTitle" ... />        <!-- 제목 입력란 -->
<EditText ... />                                  <!-- 본문 입력란, android:id 없음 -->
<TextView android:id="@+id/tvCount" ... />
```

```kotlin
class WriteActivity : AppCompatActivity() {
    private var attachCount = 0
    // 첨부 버튼 클릭 시 attachCount++ 후 tvCount 갱신
}
```', 'OBJECTIVE'),
       (3300, 520, '아래 표를 근거로 한 판단으로 옳지 않은 것은?', '같은 화면의 상태를 세 가지 방법으로 보관했을 때, 상황별로 값이 남는지 정리한 표다.

| 보관 방법 | 화면 회전·다크 모드 전환 | 시스템이 프로세스를 종료 | 사용자가 앱을 직접 종료 |
| --- | --- | --- | --- |
| savedInstanceState | 유지 | 유지 | 유실 |
| ViewModel | 유지 | 유실 | 유실 |
| 영속 저장소(DataStore·Room) | 유지 | 유지 | 유지 |', 'OBJECTIVE'),
       (3301, 520, '아래 설정으로 구성 변경을 다룰 때 일어나는 일로 옳은 것은?', '동영상 재생 화면이 회전할 때마다 플레이어가 처음부터 다시 버퍼링되는 문제를 없애려고, 매니페스트의 해당 액티비티에 android:configChanges="orientation|screenSize"를 선언했다. 이 앱은 res/layout-land/에 가로 전용 레이아웃을, res/values-night/에 야간 색상표를 따로 두고 있다.', 'OBJECTIVE'),
       (3302, 520, '아래 로그를 남긴 화면에 대한 설명으로 옳은 것은?', '목록 화면에서 기기를 한 번 회전했을 때 남은 로그다. 이 액티비티는 by viewModels()로 ViewModel을 얻고, ViewModel의 onCleared()에도 로그를 심어 두었다.

```
D/List: onPause
D/List: onStop
D/List: onSaveInstanceState
D/List: onDestroy
D/List: onCreate savedInstanceState=Bundle[{scrollY=980}]
D/List: onStart
D/List: onRestoreInstanceState
D/List: onResume
```

회전 구간 어디에도 onCleared 로그는 찍히지 않았다.', 'OBJECTIVE'),
       (3303, 520, '아래 상황에서 문제를 해결한 객체의 이름은?', '검색 화면이 검색어와 필터를 ViewModel의 프로퍼티에 들고 있다. 기기를 아무리 돌려도 조건은 잘 남았는데, 홈으로 나가 다른 앱을 한참 쓰다 돌아오면 조건이 모두 비워진 채 첫 화면이 떴다. adb shell am kill로 프로세스만 끊고 다시 들어가도 증상이 같았다. ViewModel이 만들어질 때 함께 넘겨받는 객체 하나에 검색어와 필터를 옮겨 담자, 프로세스가 끊긴 뒤 돌아와도 조건이 그대로 복원됐다.', 'SUBJECTIVE'),
       (3304, 520, '아래 세 버그가 공통으로 겪고 있는 기기 환경 변화를 부르는 용어는?', 'QA가 올린 리포트 세 건이다.

1. 글 작성 화면에서 기기를 가로로 눕히면 입력하던 내용이 사라진다.
2. 시스템 설정에서 글꼴 크기를 크게 바꾸고 앱으로 돌아오면 목록이 맨 위로 튄다.
3. 다크 모드를 켜면 진행률 표시가 0%로 되돌아간다.

세 건 모두 로그에는 액티비티의 onDestroy()와 onCreate()가 차례로 찍혀 있었다. 개발자가 매니페스트에 android:screenOrientation="portrait"를 걸어 1번은 막았지만 2번과 3번은 그대로였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3299
(8971, 3299, 'onSaveInstanceState()를 재정의하지 않았으므로 두 입력란의 글자와 attachCount가 모두 초기 상태로 돌아간다.', 'android:id가 있는 뷰는 저장 코드를 따로 쓰지 않아도 시스템이 텍스트·스크롤·체크 상태를 자동으로 저장하고 되돌려 준다. 재정의 여부와 무관하게 etTitle의 글자는 살아남는다.', false),
(8972, 3299, '액티비티 인스턴스가 그대로 재사용되므로 두 입력란의 글자와 attachCount가 회전 전 값 그대로 남는다.', '회전은 액티비티를 파괴하고 새 인스턴스를 만든다. 이전 인스턴스에 딸린 멤버 변수 attachCount도 함께 사라져 새 인스턴스에서는 0부터 다시 시작한다.', false),
(8973, 3299, 'etTitle의 글자는 시스템이 자동으로 되살리지만, id가 없는 입력란의 글자와 attachCount는 초기값으로 돌아간다.', '뷰 상태 자동 저장은 android:id가 붙은 뷰만 대상으로 한다. id가 없으면 되돌릴 뷰를 특정할 수 없어 건너뛰고, 멤버 변수는 액티비티 인스턴스와 수명을 같이한다.', true),
(8974, 3299, 'id가 없는 입력란도 뷰 계층에서의 위치로 짝을 찾아 복원되고, 멤버 변수인 attachCount만 초기화된다.', '복원의 열쇠는 뷰의 배치 순서가 아니라 android:id다. id가 없는 뷰는 저장 대상에서 아예 빠지므로 위치가 같아도 글자가 돌아오지 않는다.', false),

-- 문제 3300
(8975, 3300, '홈으로 나간 사이 시스템이 프로세스를 정리했다가 다시 들어오면, ViewModel에만 담아 둔 목록이 그대로 복원돼 있다.', '표에서 ViewModel은 시스템의 프로세스 종료 열이 유실이다. ViewModel은 메모리에만 있어 프로세스가 사라지면 같이 없어지므로, 이 경우까지 지키려면 SavedStateHandle이나 영속 저장소가 필요하다.', true),
(8976, 3300, '사용자가 최근 앱 목록에서 앱을 밀어 없앤 뒤 다시 켜면, 입력 중이던 글자를 savedInstanceState로는 되살릴 수 없다.', '표에서 savedInstanceState는 사용자가 직접 종료한 열이 유실이다. 직접 종료는 새 시작으로 취급되어 시스템이 들고 있던 Bundle을 넘겨주지 않기 때문이다.', false),
(8977, 3300, '자동 로그인 토큰처럼 앱을 껐다 켠 뒤에도 남아야 하는 값은 세 방법 중 영속 저장소에만 맡길 수 있다.', '사용자가 직접 종료한 뒤에도 유지인 행은 표에서 영속 저장소뿐이다. 나머지 둘은 화면이나 프로세스의 수명에 묶여 있어 앱 재시작을 넘기지 못한다.', false),
(8978, 3300, '다크 모드 전환만 놓고 보면 세 방법이 모두 유지이므로, 그 상황만 대비한다면 어느 쪽을 골라도 결과가 같다.', '표의 첫 상황 열은 세 행이 모두 유지라 판단 자체는 참이다. 다만 구성 변경 하나만 볼 때의 이야기이고, 프로세스 종료까지 넣으면 세 방법의 결과가 갈린다.', false),

-- 문제 3301
(8979, 3301, '선언한 액티비티는 시스템이 메모리를 확보하려 프로세스를 정리해도 화면 상태를 잃지 않는다.', 'configChanges는 구성 변경 때 재생성을 건너뛰게 할 뿐 프로세스가 정리되는 것과는 상관이 없다. 프로세스 종료 대비는 savedInstanceState나 영속 저장소로 따로 해야 한다.', false),
(8980, 3301, '다크 모드로 바꿀 때도 재생성이 일어나지 않아 values-night의 야간 색상표가 적용되지 않는다.', '선언 목록에 uiMode가 없다. 선언하지 않은 구성 변경은 평소대로 재생성되므로, 다크 모드로 바꾸면 액티비티가 다시 만들어지면서 야간 색상표가 정상 적용된다.', false),
(8981, 3301, '회전할 때 onSaveInstanceState()가 호출되어 Bundle에 담은 값이 새 onCreate()로 전달된다.', '회전으로 인한 재생성 자체가 일어나지 않으므로 저장·복원 콜백도 불리지 않는다. 같은 인스턴스가 계속 쓰이고 onConfigurationChanged()만 호출된다.', false),
(8982, 3301, '회전해도 layout-land의 가로 레이아웃이 저절로 적용되지 않아, 개발자가 직접 뷰를 다시 구성해야 한다.', '리소스 한정자는 액티비티가 다시 만들어질 때 다시 선택된다. 재생성을 막으면 그 과정이 통째로 빠지므로 onConfigurationChanged()에서 레이아웃을 손수 갈아 끼워야 한다.', true),

-- 문제 3302
(8983, 3302, 'onDestroy가 찍혔으니 ViewModel도 함께 정리됐고, 새 onCreate에서 다른 인스턴스가 만들어진 것이다.', 'ViewModel은 액티비티가 아니라 ViewModelStore에 보관된다. 액티비티가 파괴돼도 스토어는 남아 객체가 유지되며, 그 증거가 바로 찍히지 않은 onCleared 로그다.', false),
(8984, 3302, '재생성 뒤에도 같은 ViewModel 객체가 새 액티비티에 다시 연결되므로, 목록을 네트워크에서 다시 받지 않아도 된다.', 'onCleared는 스토어가 비워질 때만 불린다. 로그에 없다는 것은 객체가 살아 있다는 뜻이고, by viewModels()가 새 인스턴스에 같은 객체를 돌려주므로 이미 받아 둔 목록을 그대로 쓴다.', true),
(8985, 3302, 'onCreate에 Bundle이 들어왔으므로 사용자가 뒤로 가기로 화면을 끝냈다가 다시 연 상황이다.', '사용자가 직접 끝낸 화면은 새 시작으로 취급돼 Bundle이 null로 들어온다. Bundle이 값과 함께 채워져 있다는 것은 시스템이 스스로 파괴하고 되살렸다는 신호다.', false),
(8986, 3302, 'onRestoreInstanceState가 onStart보다 뒤에 찍혔으므로 로그 일부가 순서를 잃고 뒤섞인 것이다.', '저장은 onStop 뒤, 복원은 onStart 뒤 onResume 앞이 정상 순서다. 로그가 그 순서를 그대로 따르고 있으므로 뒤섞였다고 볼 근거가 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1056, 3303, 'SavedStateHandle,saved state handle,세이브드스테이트핸들,세이브드 스테이트 핸들,저장 상태 핸들', 'ViewModel은 메모리에만 존재해 구성 변경은 넘기지만 시스템의 프로세스 종료에서는 사라진다. 홈으로 나간 사이나 am kill 이후에만 값이 비는 증상이 그 신호다. SavedStateHandle은 savedInstanceState의 Bundle 저장 방식을 ViewModel 안으로 끌어와, 회전과 프로세스 종료 두 경우를 한 번에 덮는다. ViewModelStore는 구성 변경 구간에서 ViewModel을 붙들어 두는 보관함일 뿐 프로세스가 죽으면 함께 사라지므로 구분해야 하고, 사용자가 앱을 직접 종료한 경우는 SavedStateHandle로도 복원되지 않아 그때는 DataStore·Room 같은 영속 저장소가 필요하다.'),
       (1057, 3304, '구성 변경,구성변경,configuration change,컨피규레이션 체인지,config change', '화면 방향·글꼴 크기(fontScale)·다크 모드(uiMode)는 모두 리소스 선택에 영향을 주는 구성 값이다. 값이 바뀌면 시스템은 새 리소스 세트를 확실히 적용하려고 액티비티를 파괴하고 다시 만들며, 그래서 세 리포트 모두 onDestroy와 onCreate가 이어서 찍혔다. 회전만 막는 screenOrientation 고정이 2번·3번에 통하지 않는 이유도 여기에 있어, 근본 해결은 상태를 액티비티 밖에 두는 것이다. 생명주기가 끊긴다는 점 때문에 프로세스 종료와 헷갈리기 쉬운데, 구성 변경은 프로세스가 살아 있는 채 액티비티만 다시 만드는 것이라 ViewModel은 그대로 살아남는다는 점이 다르다.');

-- =====================================================
-- Lesson 678: 보관 위치 선택과 Bundle 크기 한계
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4247, 678, '아래 순서대로 조작한 뒤 마지막으로 찍힌 로그는?', '아래 코드를 가진 앱을 처음 실행해 HomeActivity가 뜬 뒤, 다음 순서로 조작했다.

1. 기기를 가로로 회전
2. 다시 세로로 회전
3. 홈 버튼을 눌러 나감
4. adb shell am kill com.example.app 실행
5. 최근 앱 목록에서 앱을 눌러 복귀

```kotlin
object VisitCounter {
    var total = 0
}

class HomeActivity : AppCompatActivity() {
    private var restored = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)
        VisitCounter.total++
        restored = (savedInstanceState?.getInt("restored") ?: 0) + 1
        Log.d("Home", "total=${VisitCounter.total}, restored=$restored")
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putInt("restored", restored)
    }
}
```', 'OBJECTIVE'),
       (4248, 678, '아래 코드와 조작에서 벌어지는 일로 옳은 것은?', '프로필 화면 코드다. fetchUser()는 응답까지 약 3초가 걸린다. 사용자는 화면에 들어온 지 1초 만에 기기를 가로로 회전했다.

```kotlin
class ProfileViewModel : ViewModel() {
    var nameView: TextView? = null

    fun load() {
        viewModelScope.launch {
            val user = repository.fetchUser()      // 응답까지 약 3초
            nameView?.text = user.name
        }
    }
}

class ProfileActivity : AppCompatActivity() {
    private val viewModel: ProfileViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_profile)
        if (viewModel.nameView == null) {          // 처음 한 번만 연결하고 요청
            viewModel.nameView = findViewById(R.id.tvName)
            viewModel.load()
        }
    }
}
```', 'OBJECTIVE'),
       (4249, 678, '아래 코드에서 NullPointerException이 발생하는 상황은?', '상품 상세 화면 코드다. 목록 화면에서 상품을 누르면 상품 ID를 인텐트에 담아 이 화면을 연다. repository.findProduct()는 항상 상품을 찾아 돌려준다고 가정한다.

```kotlin
class DetailViewModel : ViewModel() {
    var product: Product? = null
}

class DetailActivity : AppCompatActivity() {
    private val viewModel: DetailViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_detail)
        if (savedInstanceState == null) {
            val id = intent.getLongExtra("productId", -1L)
            viewModel.product = repository.findProduct(id)
        }
        findViewById<TextView>(R.id.tvName).text = viewModel.product!!.name
    }
}
```', 'OBJECTIVE'),
       (4250, 678, '아래 요구사항 표를 바탕으로 한 보관 위치 판단으로 옳은 것은?', '뉴스 앱의 기사 목록 화면에서 다루는 데이터와 요구사항이다.

| 데이터 | 크기 | 요구사항 |
| --- | --- | --- |
| 기사 목록(2,000건, 제목·요약·썸네일 URL) | 약 3MB | 회전·다크 모드 전환 때 서버에 다시 요청하지 않는다. 시스템이 프로세스를 종료한 뒤 복귀했을 때는 다시 요청해도 된다. |
| 선택한 카테고리 ID·마지막으로 연 기사 ID | 수십 바이트 | 회전 뒤에도, 시스템이 프로세스를 종료한 뒤 복귀해도 그대로 복원된다. |
| 작성 중인 댓글 초안 | 약 2KB | 사용자가 최근 앱 목록에서 앱을 밀어 없앤 뒤 다시 실행해도 남아 있다. |', 'OBJECTIVE'),
       (4251, 678, '아래 상황에서 앱을 강제 종료시킨 예외의 클래스 이름은?', '사진 편집 앱의 사진 선택 화면은 사용자가 고른 사진들의 썸네일 Bitmap 목록을 onSaveInstanceState()에서 outState에 통째로 넣는다. 몇 장만 고른 채 홈 버튼을 누를 때는 아무 문제가 없었지만, 300장을 고른 채 홈 버튼을 누르자 화면이 사라지자마자 앱이 강제 종료됐다. 크래시 로그의 원인 줄 끝에는 `data parcel size 6843212 bytes`라는 메시지가 붙어 있었다.

Bundle에는 사진 ID 목록만 넣고 썸네일은 복귀한 뒤 저장소에서 다시 읽도록 고치자, 같은 조작에서도 앱이 종료되지 않았다.', 'SUBJECTIVE'),
       (4252, 678, '아래 [추가 후] 로그에서 ??? 자리에 찍힌 메서드의 이름은?', '카메라 촬영 화면에서 기기를 회전할 때마다 프리뷰가 1초가량 검게 끊겨, 매니페스트의 CameraActivity 선언에 `android:configChanges="orientation|screenSize"`를 추가했다. 추가 전후로 기기를 한 번 회전했을 때 남은 로그다.

```
[추가 전]
D/Camera: onPause
D/Camera: onStop
D/Camera: onSaveInstanceState
D/Camera: onDestroy
D/Camera: onCreate
D/Camera: onStart
D/Camera: onRestoreInstanceState
D/Camera: onResume

[추가 후]
D/Camera: ??? orientation=LANDSCAPE
```

추가 후에는 회전해도 프리뷰가 끊기지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4247
(11499, 4247, 'total=4, restored=1', '정적 값과 Bundle의 수명을 거꾸로 본 것이다. VisitCounter는 프로세스 메모리에 있어 am kill과 함께 사라지고, 시스템이 종료한 경우 Bundle은 시스템이 보관했다가 복귀한 onCreate()에 돌려준다.', false),
(11500, 4247, 'total=1, restored=4', '회전 두 번은 같은 프로세스 안에서의 재생성이라 total이 3까지 늘지만, 프로세스가 종료되며 0으로 돌아가 복귀 시 1이 된다. restored는 홈으로 나갈 때 onStop() 뒤 저장된 3을 Bundle로 돌려받아 4가 된다.', true),
(11501, 4247, 'total=4, restored=4', '회전 때 VisitCounter가 살아남은 것은 프로세스가 그대로였기 때문이다. am kill로 프로세스가 끝나면 정적 변수도 사라져, 복귀하면서 시작된 새 프로세스에서 0부터 다시 센다.', false),
(11502, 4247, 'total=1, restored=1', '시스템이 프로세스를 종료해도 Bundle은 시스템 쪽에 남아 복귀 시 전달된다. savedInstanceState가 null로 들어오는 것은 뒤로 가기나 밀어 없애기처럼 사용자가 직접 화면을 끝냈을 때다.', false),

-- 문제 4248
(11503, 4248, '회전으로 액티비티가 파괴될 때 viewModelScope도 함께 취소되어, 요청이 중단되고 user.name은 어느 TextView에도 쓰이지 않는다.', 'viewModelScope는 ViewModel의 onCleared()가 불릴 때 취소된다. 회전은 ViewModelStore를 비우지 않아 onCleared()가 호출되지 않으므로, 코루틴은 계속 돌아 3초 뒤 응답을 받아 nameView에 쓴다.', false),
(11504, 4248, '새 액티비티도 같은 ViewModel을 받으므로, 도착한 이름이 새 화면의 이름 칸에 정상적으로 표시된다.', 'ViewModel이 같다고 안에 든 뷰 참조까지 새 화면 것으로 바뀌지는 않는다. nameView가 이미 채워져 있어 if 블록을 건너뛰므로, nameView는 여전히 첫 화면의 TextView를 가리킨다.', false),
(11505, 4248, '회전하면 ViewModel도 새로 만들어져 nameView가 null이 되므로, load()가 다시 호출되어 요청이 두 번 나간다.', '구성 변경에서는 ViewModelStore가 유지되어 by viewModels()가 같은 인스턴스를 돌려준다. nameView는 null로 돌아가지 않으므로 load()는 처음 한 번만 호출된다.', false),
(11506, 4248, '도착한 이름은 파괴된 첫 화면의 TextView에 쓰여 새 화면에는 보이지 않고, 첫 액티비티는 GC되지 못한 채 남는다.', 'ViewModel은 액티비티보다 오래 살아 첫 화면의 TextView를 계속 붙든다. 그 뷰가 첫 액티비티의 Context를 참조하므로 파괴된 액티비티가 수거되지 못하는 메모리 누수가 되고, 응답도 보이지 않는 옛 뷰에 쓰인다.', true),

-- 문제 4249
(11507, 4249, '상세 화면을 띄운 채 기기를 가로로 회전하고 다시 세로로 돌렸을 때', '회전은 구성 변경이라 ViewModelStore가 유지되어 product가 든 같은 ViewModel이 다시 연결된다. savedInstanceState가 null이 아니라 대입을 건너뛰어도 값이 남아 있어 예외가 나지 않는다.', false),
(11508, 4249, '상세 화면에서 뒤로 가기로 나갔다가 목록에서 같은 상품을 다시 눌렀을 때', '뒤로 가기로 끝낸 화면을 다시 열면 완전히 새로 시작하므로 savedInstanceState가 null이다. if 블록이 실행되어 product가 채워진 뒤 이름을 읽는다.', false),
(11509, 4249, '상세 화면을 띄운 채 홈으로 나간 뒤 adb shell am kill로 종료하고 다시 들어갔을 때', '시스템이 프로세스를 종료하면 메모리에만 있던 ViewModel은 사라지지만 Bundle은 시스템이 보관했다가 돌려준다. savedInstanceState가 null이 아니라 대입을 건너뛰고, 새로 만든 ViewModel의 product가 null이라 !!에서 예외가 난다.', true),
(11510, 4249, '최근 앱 목록에서 앱을 밀어 없앤 뒤 다시 실행해 같은 상품의 상세 화면에 들어갔을 때', '사용자가 앱을 직접 밀어 없애면 저장된 상태도 버려져 새 시작으로 취급된다. 상세 화면은 savedInstanceState가 null인 채 열려 if 블록에서 product가 채워진다.', false),

-- 문제 4250
(11511, 4250, '기사 목록은 회전 때 같은 인스턴스가 새 액티비티에 다시 연결되는 ViewModel에 두면 요구사항을 채운다.', 'ViewModel은 구성 변경 때 ViewModelStore에 남아 새 액티비티에 다시 연결되므로 목록을 다시 요청할 필요가 없다. 메모리에만 있어 프로세스 종료 때는 사라지지만, 표가 그때의 재요청을 허용하므로 문제없다.', true),
(11512, 4250, '기사 목록은 SavedStateHandle에 담으면 ViewModel 안에 있으므로 크기 한도 없이 요구사항을 채운다.', 'SavedStateHandle은 ViewModel 안에서 쓰지만 값은 savedInstanceState와 같은 Bundle 경로로 시스템에 넘겨진다. 3MB를 담으면 Bundle 크기 한도(약 1MB)를 넘어 홈으로 나가 상태를 저장하는 순간 앱이 강제 종료된다.', false),
(11513, 4250, '카테고리 ID·기사 ID는 수십 바이트로 작으므로 ViewModel 프로퍼티에만 둬도 요구사항을 채운다.', '값의 크기가 아니라 수명이 문제다. ViewModel은 메모리에만 있어 시스템이 프로세스를 종료하면 함께 사라진다. 표의 둘째 줄처럼 프로세스 종료 뒤 복원이 필요하면 SavedStateHandle이나 savedInstanceState에 둬야 한다.', false),
(11514, 4250, '댓글 초안은 2KB로 Bundle 한도 안이므로 savedInstanceState에 넣으면 요구사항을 채운다.', '크기는 문제없지만, 사용자가 앱을 밀어 없애면 새 시작으로 취급되어 savedInstanceState가 복원되지 않는다. 앱을 다시 실행해도 남아야 하는 초안은 Room·DataStore 같은 영속 저장소에 둔다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1372, 4251, 'TransactionTooLargeException,android.os.TransactionTooLargeException,Transaction Too Large Exception,TransactionTooLarge,트랜잭션투라지익셉션,트랜잭션 투 라지 익셉션', 'onSaveInstanceState()에 담긴 Bundle은 직렬화되어 Binder IPC로 시스템 프로세스에 넘겨지는데, 한 번에 보낼 수 있는 트랜잭션 버퍼(약 1MB)를 넘기면 TransactionTooLargeException이 발생한다. 홈 버튼으로 나가 onStop() 뒤 상태를 저장해 보내는 순간 한도를 넘었기 때문에 화면이 사라지자마자 종료됐고, 사진이 몇 장일 때는 한도 안이라 문제가 없었다. 그래서 Bundle에는 ID·스크롤 위치처럼 다시 조회할 열쇠만 수십 KB 이하로 넣고, 큰 데이터는 저장소에서 다시 읽는다. 앱 힙이 모자랄 때 나는 OutOfMemoryError와 헷갈리기 쉽지만, 이 예외는 앱 메모리가 아니라 프로세스 간 전송 버퍼의 한도에 걸린 것이라 largeHeap을 켜도 해결되지 않는다.'),
       (1373, 4252, 'onConfigurationChanged,onConfigurationChanged(),onConfigurationChanged(newConfig),onConfigurationChanged(Configuration),Activity.onConfigurationChanged,온컨피규레이션체인지드,온 컨피규레이션 체인지드', '매니페스트의 configChanges에 선언한 구성 변경이 일어나면 시스템은 액티비티를 파괴하고 다시 만드는 대신 같은 인스턴스의 onConfigurationChanged(newConfig)만 호출한다. 그래서 [추가 전]의 onPause부터 onResume까지 이어지던 재생성 흐름이 통째로 사라지고 프리뷰도 끊기지 않았다. 대가로 layout-land 같은 리소스 한정자가 자동으로 적용되지 않아 필요한 뷰 갱신을 직접 해야 하고, 선언하지 않은 변경(예: 다크 모드의 uiMode)에서는 여전히 재생성된다. 재생성 경로에서 상태를 Bundle에 담는 onSaveInstanceState()나 복원 때 불리는 onRestoreInstanceState()와 헷갈리지 말아야 하며, 이 설정은 시스템의 프로세스 종료를 막지 못하므로 상태 보존 대책을 대신하지 않는다.');

-- =====================================================
-- Lesson 836: 프로세스 종료 복원과 활동 유지 안 함
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5195, 836, '아래 조작을 모두 마친 뒤 화면에 표시되는 세 값은?', '장바구니 화면의 코드다. onSaveInstanceState()는 재정의하지 않았고, onCreate()에서 세 값을 tap / recent / coupon 순서로 화면에 표시한다.

```kotlin
class CartViewModel(private val handle: SavedStateHandle) : ViewModel() {
    var recentView = 0                                  // 일반 프로퍼티
    var couponCount: Int                                // SavedStateHandle에 저장
        get() = handle["coupon"] ?: 0
        set(value) { handle["coupon"] = value }
}

class CartActivity : AppCompatActivity() {
    private val viewModel: CartViewModel by viewModels()
    private var tapCount = 0                            // 액티비티 멤버 변수

    // 담기 버튼을 누를 때마다 tapCount, viewModel.recentView, viewModel.couponCount를 각각 1 늘린다
}
```

조작 순서는 다음과 같다.

1. 담기 버튼을 4번 누른다
2. 기기를 가로로 회전한다
3. 담기 버튼을 2번 더 누른다
4. 홈으로 나가 다른 앱을 한참 쓰는 사이, 시스템이 메모리를 확보하려고 이 앱의 프로세스를 정리했다
5. 최근 앱 목록에서 이 앱으로 다시 들어온다', 'OBJECTIVE'),
       (5196, 836, '아래 로그를 근거로 한 설명으로 옳은 것은?', '글쓰기 화면은 onCreate·onStart·onResume·onPause·onStop·onSaveInstanceState·onRestoreInstanceState·onDestroy 여덟 콜백에 빠짐없이 로그를 심어 두었다. 사용자가 제목과 본문을 입력한 뒤 남은 로그다.

```
[홈 버튼을 눌러 나감]
D/Edit: onPause
D/Edit: onStop
D/Edit: onSaveInstanceState

[최근 앱 목록에서 다시 들어옴]
D/Edit: onStart
D/Edit: onResume

[뒤로 가기 버튼을 눌러 화면을 닫음]
D/Edit: onPause
D/Edit: onStop
D/Edit: onDestroy
```', 'OBJECTIVE'),
       (5197, 836, '아래 표를 바탕으로 한 판단으로 옳은 것은?', '한 액티비티가 떠 있는 동안 사용자가 일으킬 수 있는 기기 설정 변경을 정리한 표다. 이 앱의 매니페스트에는 android:configChanges 선언이 없다.

| 사용자 조작 | 바뀌는 구성 값 | 앱이 가진 대응 리소스 디렉터리 |
| --- | --- | --- |
| 기기를 가로로 눕힘 | orientation, screenSize | res/layout-land/ |
| 시스템 언어를 영어로 바꿈 | locale | res/values-en/ |
| 다크 모드를 켬 | uiMode | res/values-night/ |
| 글꼴 크기를 크게로 바꿈 | fontScale | 없음 |', 'OBJECTIVE'),
       (5198, 836, '아래 QA 결과에 대한 판단으로 옳은 것은?', '메모 앱의 작성 화면은 입력 중인 메모 본문(평균 1~2KB)을 ViewModel의 SavedStateHandle에 담아 둔다. QA가 글을 절반쯤 쓴 상태에서 세 가지를 시험했다.

- 기기를 가로로 눕혔다가 다시 세움: 쓰던 글이 그대로 남았다.
- 홈으로 나가 다른 앱을 한참 쓴 뒤 복귀: 그대로 남았다.
- 최근 앱 목록에서 앱을 밀어 없앤 뒤 다시 실행: 작성 화면이 빈 칸으로 열렸다.

기획은 세 번째 경우에도 쓰던 글을 되살려 주기를 원한다.', 'OBJECTIVE'),
       (5199, 836, '아래 상황에서 QA 기기에만 켜져 있던 개발자 옵션의 이름은?', '출시 직전 QA가 "어느 화면이든 홈으로 나갔다가 최근 앱으로 돌아오면 처음부터 다시 시작된다"는 리포트를 여러 건 올렸다. 같은 기기 모델을 쓰는 개발자 자리에서는 같은 조작으로 재현되지 않았다.

QA 기기 로그를 받아 보니 홈으로 나간 직후에 onDestroy가, 복귀할 때 onCreate가 찍혀 있었다. 이때 ViewModel에만 담아 둔 목록은 매번 비어 있었지만, Bundle에 담아 둔 스크롤 위치는 정확히 복원됐다. 앱을 다시 설치하거나 코드를 고치지 않고 QA 기기의 개발자 옵션에서 설정 하나만 끄자 리포트의 증상이 모두 사라졌다.', 'SUBJECTIVE'),
       (5200, 836, '아래 로그에서 두 객체의 수명을 갈라놓은 보관 장치의 이름은?', '목록 화면의 상태 보존이 의심스러워, 액티비티와 ViewModel 객체의 identityHashCode를 onCreate마다 찍어 보았다.

```
[처음 실행]                     activity=0x1a2b  viewModel=0x77c0
[가로로 회전]                   activity=0x9f31  viewModel=0x77c0
[다시 세로로 회전]              activity=0x5c14  viewModel=0x77c0
[뒤로 가기로 닫은 뒤 다시 열기] activity=0x4d08  viewModel=0x35e9
```

액티비티는 매번 다른 객체였지만 ViewModel은 회전 구간에서만 같은 객체가 돌아왔고, 뒤로 가기로 닫은 구간에서만 ViewModel의 onCleared 로그가 함께 찍혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5195
(14027, 5195, 'tap 2 / recent 6 / coupon 6', '프로세스가 정리된 뒤의 복귀를 회전과 같은 재생성으로 본 것이다. 액티비티 멤버 변수는 인스턴스와 수명을 같이하므로, 회전 한 번에도 tapCount는 이미 0으로 돌아간다.', false),
(14028, 5195, 'tap 0 / recent 6 / coupon 6', 'ViewModel이 프로세스 종료까지 넘긴다고 본 오해다. ViewModel은 메모리에만 있어 프로세스가 정리되면 recentView도 함께 사라지고, 복귀 때는 새로 만들어진 인스턴스가 0부터 시작한다.', false),
(14029, 5195, 'tap 0 / recent 0 / coupon 6', '회전은 프로세스를 그대로 두는 재생성이라 두 ViewModel 값이 6까지 오르지만, 프로세스가 정리되면 메모리에 있던 tapCount와 recentView는 사라진다. couponCount만 홈으로 나갈 때 Bundle에 실려 시스템에 보관됐다가 돌아온다.', true),
(14030, 5195, 'tap 0 / recent 0 / coupon 0', 'SavedStateHandle도 ViewModel의 일부라 함께 사라진다고 본 오해다. 이 값은 savedInstanceState와 같은 Bundle 경로로 시스템이 들고 있다가 돌려주므로, 프로세스가 정리된 뒤에도 되살아난다.', false),

-- 문제 5196
(14031, 5196, '뒤로 가기로 끝낸 화면은 시스템이 되살릴 일이 없다고 보아 Bundle을 아예 준비하지 않는다.', '마지막 구간은 화면이 파괴되는데도 저장 콜백이 없다. 사용자가 직접 끝낸 화면은 새 시작으로 취급되므로 시스템이 되살릴 상태를 만들지 않는 것이고, 반대로 첫 구간은 파괴되지 않았는데도 미리 저장해 둔다.', true),
(14032, 5196, '첫 구간에서 저장 콜백이 불린 것은 그 시점에 액티비티가 파괴됐다는 뜻이고, 복귀 때 새 인스턴스가 만들어졌다.', '첫 구간에는 onDestroy가, 복귀 구간에는 onCreate가 없다. 화면이 가려지면 시스템이 언제든 프로세스를 정리할 수 있어 미리 저장해 둘 뿐, 저장과 파괴는 별개의 사건이다.', false),
(14033, 5196, '마지막 구간에서 화면이 파괴됐으므로, 이 화면을 다시 열면 직전에 입력하던 글자가 Bundle로 복원된다.', '복원의 재료인 Bundle은 저장 콜백이 불려야 만들어진다. 마지막 구간에는 그 콜백이 없으므로 다음에 화면을 열 때 onCreate의 savedInstanceState는 null로 들어온다.', false),
(14034, 5196, '복귀 구간에 onRestoreInstanceState가 없으므로 앞서 저장한 Bundle이 버려졌고, 입력하던 글자도 함께 사라졌다.', '복귀 구간에 onCreate조차 없다는 것은 같은 인스턴스가 그대로 재개됐다는 뜻이다. 되돌릴 것이 없어 복원 콜백이 불리지 않았을 뿐, 화면이 들고 있던 값은 그대로 남아 있다.', false),

-- 문제 5197
(14035, 5197, '매니페스트에 configChanges 선언이 없으므로 네 조작 모두 재생성 대신 onConfigurationChanged()만 호출된다.', '방향이 거꾸로다. 선언이 없을 때의 기본 동작이 재생성이고, 선언해 둔 구성에서만 재생성을 건너뛰고 onConfigurationChanged()가 불린다.', false),
(14036, 5197, '대응 리소스 디렉터리가 하나도 없는 마지막 줄에서는 갈아 끼울 것이 없으므로 화면에 아무 일도 일어나지 않는다.', '재생성 여부는 앱이 어떤 디렉터리를 가졌는지가 아니라 구성 값이 바뀌었는지로 정해진다. fontScale이 달라지면 대응 디렉터리가 없어도 시스템은 화면을 다시 만든다.', false),
(14037, 5197, '셋째 줄은 색상표만 달라지는 변경이라 재생성 없이 뷰를 다시 그리는 것으로 끝난다.', 'uiMode도 엄연한 구성 값이라 다크 모드 전환 역시 재생성을 부른다. 색만 바뀌어 보여도 시스템은 화면을 다시 만들면서 values-night를 고른다.', false),
(14038, 5197, '네 조작 모두 액티비티가 파괴된 뒤 다시 만들어지므로, 멤버 변수에만 둔 값은 어느 줄에서도 남지 않는다.', '둘째 열이 네 줄 모두 채워져 있다는 점이 핵심이다. 구성 값이 하나라도 바뀌면 시스템은 리소스를 다시 고르려고 화면을 재생성하며, 대응 디렉터리가 있는지는 재생성 여부를 바꾸지 못한다.', true),

-- 문제 5198
(14039, 5198, '두 번째에서 글이 남은 것은 프로세스가 끊기지 않았기 때문이며, 시스템이 프로세스를 정리했다면 SavedStateHandle의 값도 함께 비었을 것이다.', 'SavedStateHandle은 savedInstanceState와 같은 Bundle 경로로 값을 시스템에 넘겨 둔다. 시스템이 프로세스를 정리한 뒤 복귀해도 값이 돌아오며, 이 점이 ViewModel의 일반 프로퍼티와 갈리는 지점이다.', false),
(14040, 5198, '세 번째는 새 시작으로 취급돼 시스템이 보관하던 값을 넘기지 않는 경우라, 글을 기기에 직접 써 두는 저장소로만 채울 수 있다.', '사용자가 직접 앱을 없애면 시스템도 들고 있던 상태를 함께 버린다. 앱 재실행을 넘겨야 하는 임시 저장 초안은 DataStore·Room·파일처럼 기기에 남는 계층에 써 둬야 한다.', true),
(14041, 5198, '세 번째 증상은 메모가 Bundle 한도를 넘겨 저장이 실패한 것이므로, 입력 글자 수에 상한을 두면 해결된다.', '한도에 걸리면 저장 순간 TransactionTooLargeException으로 앱이 강제 종료된다. 본문은 1~2KB라 수십 KB 권장선 안쪽이고, 앞의 두 시험에서 값이 잘 남은 것이 저장 자체는 성공했다는 증거다.', false),
(14042, 5198, '앱을 밀어 없애도 프로세스는 남아 있으므로, 글을 ViewModel의 일반 프로퍼티로 옮기면 세 번째에서도 남는다.', '밀어 없애기는 태스크와 프로세스를 함께 끝낸다. 메모리에만 있는 ViewModel은 프로세스가 사라지면 같이 없어지므로, 옮기면 오히려 두 번째 경우까지 못 지키게 된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1688, 5199, '활동 유지 안 함,활동 유지 안함,활동 유지하지 않음,활동을 유지하지 않음,Don''t keep activities,Dont keep activities,Do not keep activities,돈트 킵 액티비티스', '개발자 옵션의 "활동 유지 안 함"을 켜면 사용자가 화면을 벗어나는 순간 시스템이 액티비티를 곧바로 파괴한다. 홈으로 나갈 때 onDestroy가, 복귀할 때 onCreate가 찍힌 것이 그 신호다. 이때의 파괴는 구성 변경이 아니라 화면이 끝난 것으로 처리되어 ViewModelStore가 비워지므로 ViewModel은 새로 만들어지고, onSaveInstanceState로 넘겨 둔 Bundle은 시스템이 들고 있다가 돌려준다. 목록만 비고 스크롤 위치는 복원된 이유가 여기에 있다. 결과가 시스템의 프로세스 종료 뒤 복귀와 같아서, 평소 재현하기 어려운 복원 경로를 점검하는 용도로 켠다. 다만 프로세스까지 끊는 것은 아니라 정적 변수나 Application 객체는 살아 있으므로, 프로세스 종료까지 재현하려면 adb shell am kill로 프로세스를 직접 끊어야 한다.'),
       (1689, 5200, 'ViewModelStore,ViewModel Store,View Model Store,뷰모델스토어,뷰모델 스토어', 'ViewModel 객체는 액티비티가 직접 들고 있는 것이 아니라 액티비티가 가진 ViewModelStore에 담긴다. 구성 변경으로 액티비티가 파괴될 때 시스템은 이 스토어를 비우지 않고 다음 인스턴스에 그대로 넘기므로, 두 번의 회전 뒤에도 같은 0x77c0이 돌아왔다. 반대로 뒤로 가기처럼 화면이 완전히 끝나는 경우에만 스토어가 비워지고, 그때 각 ViewModel의 onCleared()가 불린다. 마지막 줄에서 해시가 바뀐 것과 onCleared 로그가 찍힌 것은 같은 사건의 양면이다. 보관되는 값인 ViewModel 자체와 그것을 붙들고 있는 스토어를 구분해야 하고, 스토어도 메모리에 있는 객체라 프로세스가 정리되면 함께 사라지므로 그 경우까지 값을 지키려면 SavedStateHandle이나 영속 저장소가 필요하다.');
