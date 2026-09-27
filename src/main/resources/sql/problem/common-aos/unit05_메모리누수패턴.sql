-- Unit: 메모리 누수 패턴 (Unit ID: 96)
-- Chapter: AOS (Chapter ID: 8)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (522, 96, 'Handler 누수와 힙 덤프 진단'),
       (680, 96, 'GC 루트 추적과 내부 클래스·약한 참조'),
       (838, 96, '전역 참조와 Context 수명 불일치');

-- =====================================================
-- Lesson 522: Handler 누수와 힙 덤프 진단
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3311, 522, '아래 화면에 들어간 뒤 5초 만에 뒤로 가기로 빠져나갔을 때 벌어지는 일로 옳은 것은?', '```kotlin
class SplashActivity : AppCompatActivity() {
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handler.postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
        }, 60_000L)
    }
    // onDestroy는 재정의하지 않았다
}
```', 'OBJECTIVE'),
       (3312, 522, '아래 Context 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '| Context 종류 | 수명 | 적합한 용도 | 주의 |
| --- | --- | --- | --- |
| Application Context | 프로세스 전체 | 싱글턴·라이브러리 초기화, 리소스 접근 | 테마가 없어 다이얼로그 생성·레이아웃 인플레이트 불가 |
| Activity Context | 액티비티 생명주기 | 뷰 생성, 다이얼로그, 테마가 필요한 작업 | 오래 사는 객체에 저장 금지 |
| Service Context | 서비스 생명주기 | 서비스 내부 작업 | 서비스가 끝나면 무효 |', 'OBJECTIVE'),
       (3313, 522, '아래 액티비티에서 다른 화면으로 이동해 MapActivity가 파괴된 직후의 상태로 옳은 것은?', '```kotlin
class MapActivity : AppCompatActivity() {
    private val locationManager by lazy {
        getSystemService(LocationManager::class.java)
    }
    private val listener = LocationListener { location -> updateMarker(location) }

    override fun onStart() {
        super.onStart()
        locationManager.requestLocationUpdates(
            LocationManager.GPS_PROVIDER, 1000L, 1f, listener
        )
    }

    override fun onStop() {
        super.onStop()   // removeUpdates 호출 없음
    }
}
```', 'OBJECTIVE'),
       (3314, 522, '아래 힙 덤프 결과에 대한 해석으로 옳은 것은?', '화면 회전 5회 반복 후 강제 GC → 힙 덤프 (Android Studio Memory Profiler)

| Class Name | Allocations | Shallow Size | Retained Size |
| --- | --- | --- | --- |
| ListActivity | 6 | 184 B | 12.4 MB |
| ItemAdapter | 6 | 152 B | 8.1 MB |
| ListViewModel | 1 | 120 B | 96.0 KB |

덤프 시점에 화면에 떠 있는 ListActivity는 1개다.', 'OBJECTIVE'),
       (3315, 522, '아래 출력을 만들어 낸 라이브러리의 이름은?', '디버그 빌드로 앱을 쓰다 결제 화면을 닫자 잠시 뒤 알림이 하나 떴고, 로그에는 아래 참조 경로가 찍혔다. 같은 앱을 릴리스 빌드로 만들면 이 알림도 로그도 나오지 않는다.

```
┬───
│ GC Root: 시스템 클래스가 들고 있는 static 필드
│
├─ com.example.AnalyticsTracker class
│    ↓ static AnalyticsTracker.context
├─ com.example.CheckoutActivity instance
│    ~~~~~~~ 파괴됨, 5.2 MB 유지
╰→ 여기서 참조가 끊겨야 한다
```', 'SUBJECTIVE'),
       (3316, 522, '아래에서 GlobalScope를 대신해 쓴 코루틴 스코프의 이름은?', '액티비티에서 아래처럼 상세 정보를 불러왔더니, 사용자가 화면을 열자마자 닫아도 응답이 도착할 때까지 그 화면이 힙에 남아 있었다.

```kotlin
GlobalScope.launch {          // 응답까지 평균 8초
    val data = api.fetch(id)
    binding.title.text = data.title
}
```

launch를 액티비티가 기본으로 제공하는 스코프에서 실행하도록 한 줄만 바꾸자, 화면을 닫는 순간 진행 중이던 요청 로그가 끊겼고 힙 덤프의 액티비티 인스턴스도 다시 1개로 돌아왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3311
(9003, 3311, '지연 시간이 60초로 길어 그 사이 GC가 여러 번 돌기 때문에 액티비티는 예약과 상관없이 회수된다.', '추적 GC는 시간이 지나서가 아니라 GC 루트에서 도달할 수 없게 됐을 때 객체를 회수한다. 메인 루퍼의 메시지 큐가 루트 쪽에서 예약을 붙잡고 있는 한 GC가 몇 번을 돌아도 회수 대상이 되지 않는다.', false),
(9004, 3311, '뒤로 간 뒤에도 약 55초 동안 SplashActivity가 회수되지 못하고, 시간이 되면 사라진 화면에서 화면 전환이 실행된다.', '메시지 큐는 메인 루퍼에 매달려 있어 실행 전까지 Runnable을 붙잡는다. 람다가 Intent에 this를 넘겨 액티비티를 캡처하므로 남은 55초 동안 화면이 살아 있고, 시간이 차면 전환도 그대로 실행된다.', true),
(9005, 3311, '뒤로 가기로 onDestroy가 끝나는 순간 프레임워크가 이 화면이 걸어 둔 예약을 메시지 큐에서 지운다.', '생명주기 콜백은 큐를 청소해 주지 않는다. 남은 콜백은 onDestroy에서 removeCallbacksAndMessages(null)로 직접 지우거나, 생명주기에 묶인 스코프의 delay로 바꿔야 사라진다.', false),
(9006, 3311, '메시지 큐는 액티비티마다 하나씩 붙어 있어 액티비티가 사라지면 예약도 함께 사라진다.', '큐는 액티비티가 아니라 루퍼에 딸려 있다. 여기서는 앱 전체가 메인 루퍼의 큐 하나를 함께 쓰므로, 액티비티가 사라져도 그 액티비티가 넣은 예약은 큐에 그대로 남는다.', false),

-- 문제 3312
(9007, 3312, '화면 회전을 넘겨 살아 있어야 하는 캐시 객체에는 Application Context를 넘겨야 한다.', '캐시는 프로세스가 살아 있는 동안 유지되는데 수명이 액티비티에 묶인 Context를 넣으면 회전으로 파괴된 화면을 캐시가 계속 붙잡는다. 수명이 더 긴 쪽을 골라야 하므로 참인 진술이다.', false),
(9008, 3312, '서비스가 끝난 뒤 미뤄 둔 작업을 그때 받아 둔 Service Context로 실행하면 동작을 보장할 수 없다.', 'Service Context는 수명이 서비스에 묶여 종료 뒤에는 무효다. 무효가 된 Context로 리소스나 시스템 서비스를 찾으면 실패하거나 예기치 않게 동작하므로 참인 진술이다.', false),
(9009, 3312, '다이얼로그를 띄우는 공용 유틸리티 싱글턴에 Application Context를 주입하면 수명과 테마 문제가 모두 풀린다.', '수명 문제는 풀리지만 테마가 없는 Context로는 다이얼로그를 만들 수 없어 표의 주의와 정면으로 어긋난다. 유틸리티는 Context를 보관하지 말고 호출 시점에 Activity Context를 받아 쓰는 편이 맞다.', true),
(9010, 3312, '코드로 만든 커스텀 뷰에 화면 테마를 그대로 입히려면 Application Context로는 대체할 수 없다.', '테마가 필요한 작업은 Activity Context의 몫이다. 테마가 없는 Context로 뷰를 만들면 스타일 속성이 풀리거나 예외가 나므로 참인 진술이다.', false),

-- 문제 3313
(9011, 3313, '위치 갱신 요청을 받아 둔 쪽이 listener를 계속 들고 있어 파괴된 MapActivity와 뷰 트리가 회수되지 않는다.', '람다로 만든 listener는 updateMarker를 부르려고 바깥 액티비티를 캡처한다. 등록을 받은 쪽의 참조가 남아 GC 루트에서 도달 가능한 체인이 유지되므로 화면 전체가 힙에 남는다.', true),
(9012, 3313, 'onStop에서 super만 호출해도 프레임워크가 이 화면이 건 등록을 되돌리므로 참조가 남지 않는다.', 'super.onStop()은 상위 클래스의 생명주기 처리를 이어갈 뿐 개발자가 직접 건 등록까지 알지 못한다. requestLocationUpdates에는 removeUpdates를 대칭 콜백에서 짝지어야 한다.', false),
(9013, 3313, 'locationManager를 lazy로 선언했으므로 액티비티가 파괴되면 시스템 서비스 쪽 참조도 초기화 이전으로 돌아간다.', 'lazy는 첫 접근까지 초기화를 미룰 뿐 값을 되돌리는 장치가 아니다. 게다가 붙잡는 방향은 액티비티에서 서비스가 아니라 등록을 받은 쪽에서 액티비티라 프로퍼티 선언 방식과 무관하다.', false),
(9014, 3313, '위치 갱신 주기가 1초라 파괴 뒤 첫 갱신에서 받을 대상이 없다고 판단돼 등록이 자동으로 끊긴다.', '콜백을 받는 listener 객체 자체는 멀쩡히 살아 있어 갱신은 계속 전달된다. 액티비티가 파괴됐다는 사실은 등록을 받은 쪽이 알 수 없으므로 스스로 끊기지 않는다.', false),

-- 문제 3314
(9015, 3314, 'ListActivity의 Shallow Size가 184 B이므로 인스턴스가 남아도 실제로 붙잡히는 메모리는 그 정도에 그친다.', 'Shallow Size는 객체 껍데기 크기이고, 그 객체가 사라져야 함께 풀리는 총량은 Retained Size다. 여기서는 12.4 MB가 뷰 트리·비트맵까지 묶여 남아 있다는 뜻이다.', false),
(9016, 3314, '세 클래스의 Retained Size를 더한 약 20.6 MB가 서로 겹치지 않고 따로 쓰이는 메모리다.', 'Retained Size는 겹칠 수 있다. 어댑터가 액티비티에 매달려 있으면 어댑터 몫 8.1 MB는 액티비티의 12.4 MB 안에 이미 포함되므로 단순 합계는 실제 사용량이 아니다.', false),
(9017, 3314, '인스턴스가 6개인 클래스가 둘이므로 두 클래스가 서로를 참조하는 순환 참조가 원인이며, 순환은 GC가 풀지 못한다.', 'ART의 추적 GC는 GC 루트에서 도달 가능한지만 보므로 서로만 가리키는 순환은 통째로 회수한다. 남아 있는 이유는 순환이 아니라 루트에서 이어지는 체인이 살아 있어서다.', false),
(9018, 3314, '회전을 거쳐도 ListViewModel은 하나뿐이므로, 화면이 쌓인 통로가 ViewModel 자체는 아니라고 볼 수 있다.', 'ViewModel은 구성 변경을 넘어 유지되도록 만들어져 인스턴스가 1개인 것이 정상이다. 회전 횟수만큼 늘어난 액티비티와 어댑터 쪽에서 끊어야 할 참조를 찾아야 한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1060, 3315, 'LeakCanary,리크캐너리,리크 캐너리,릭캐너리,릭 캐너리,leak canary', '파괴됐어야 할 Activity·Fragment·View를 WeakReference로 지켜보다가 강제 GC 뒤에도 남아 있으면 힙 덤프를 떠서 GC 루트부터의 참조 체인을 출력해 주는 라이브러리가 LeakCanary다. debugImplementation으로만 추가해 릴리스 빌드에는 포함되지 않으므로 디버그에서만 알림이 뜬다는 점이 본문의 단서다. 개발자가 직접 힙 덤프를 떠 인스턴스 수와 Retained Size를 살펴보는 Memory Profiler와 달리, 자동으로 감지해 끊어야 할 지점까지 짚어 준다는 점에서 구분한다.'),
       (1061, 3316, 'lifecycleScope,라이프사이클스코프,라이프사이클 스코프,lifecycle scope', '액티비티·프래그먼트의 Lifecycle에 딸린 lifecycleScope에서 코루틴을 띄우면 화면이 DESTROYED로 갈 때 그 스코프의 작업이 함께 취소돼, 응답을 기다리던 코루틴이 액티비티와 binding을 붙잡고 있을 일이 없다. GlobalScope는 프로세스와 수명이 같아 화면이 사라져도 살아남기 때문에 응답이 올 때까지 액티비티가 남는다. 프래그먼트에서 뷰를 건드리는 작업이라면 viewLifecycleOwner의 스코프를, ViewModel 안이라면 viewModelScope를 쓰는 것으로 구분한다.');

-- =====================================================
-- Lesson 680: GC 루트 추적과 내부 클래스·약한 참조
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4259, 680, '아래 코드로 상세 화면에 들어가 머무는 동안, FeedFragment 쪽 메모리 상태로 옳은 것은?', 'FeedFragment의 코드는 아래가 전부이고, 목록에서 글을 누르면 MainActivity가 아래 트랜잭션으로 상세 화면을 띄운다.

```kotlin
class FeedFragment : Fragment(R.layout.fragment_feed) {
    private var binding: FragmentFeedBinding? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding = FragmentFeedBinding.bind(view)
        binding?.feedList?.adapter = FeedAdapter()
    }
}
```

```kotlin
// MainActivity
supportFragmentManager.commit {
    replace(R.id.container, DetailFragment())
    addToBackStack(null)
}
```', 'OBJECTIVE'),
       (4260, 680, '업로드를 시작한 직후 사용자가 화면을 닫았을 때, 아래 두 버전을 비교한 설명으로 옳은 것은?', 'UploadApi는 Context를 참조하지 않는 전역 object이고, upload()는 약 30초 뒤에 돌아오는 동기 호출이다. 두 버전은 inner 키워드 하나만 다르다.

```kotlin
// 버전 A
class UploadActivity : AppCompatActivity() {
    inner class UploadTask(private val file: File) : Runnable {
        override fun run() {
            UploadApi.upload(file)
        }
    }

    private fun startUpload(file: File) {
        Thread(UploadTask(file)).start()
    }
}
```

```kotlin
// 버전 B
class UploadActivity : AppCompatActivity() {
    class UploadTask(private val file: File) : Runnable {
        override fun run() {
            UploadApi.upload(file)
        }
    }

    private fun startUpload(file: File) {
        Thread(UploadTask(file)).start()
    }
}
```', 'OBJECTIVE'),
       (4261, 680, '아래 참조 경로를 끊어 누수를 해결하는 수정으로 옳은 것은?', '장바구니 화면(CartActivity)을 열고 닫기를 세 번 반복한 뒤 강제 GC를 하고, 힙 덤프에서 확인한 참조 경로다. CartActivity는 onCreate()에서 object : PriceListener { ... }로 만든 리스너를 CartRepository.addListener()에 넘기며, 이 리스너는 가격이 바뀌면 액티비티의 updateTotal()을 호출한다.

```
static CartRepository.INSTANCE
    ↓
CartRepository (앱 전역 싱글턴)
    ↓ listeners
java.util.ArrayList (size = 3)
    ↓ [2]
CartActivity$onCreate$1 (익명 리스너 객체)
    ↓ this$0
CartActivity (mDestroyed = true, Retained Size 7.8 MB)
```', 'OBJECTIVE'),
       (4262, 680, '아래 콜백 구조로 바꾼 뒤 앱의 동작으로 옳은 것은?', '결제 SDK에는 콜백을 넘기는 setCallback()만 있고 해제 API가 없으며, SDK 내부 싱글턴이 마지막으로 받은 콜백 객체를 계속 보관한다. SDK 코드는 고칠 수 없어서, 콜백이 액티비티를 약한 참조(WeakReference)로만 가리키도록 아래처럼 바꿨다. 결제는 요청 후 결과가 오기까지 수십 초가 걸릴 수 있다.

```kotlin
class PayResultCallback(activity: CheckoutActivity) : PaySdk.Callback {
    private val activityRef = WeakReference(activity)

    override fun onResult(result: PayResult) {
        activityRef.get()?.showResult(result)
    }
}

// CheckoutActivity.onCreate()
PaySdk.setCallback(PayResultCallback(this))
```', 'OBJECTIVE'),
       (4263, 680, '아래 상황에서 알림 한 건에 로그가 한 줄만 찍히게 하려면, observe()의 첫 인자 this 자리에 넣어야 하는 값은?', '목록 화면(ListFragment)에서 설정 화면으로 갈 때는 replace()와 addToBackStack()을 쓰고, 뒤로 가기로 목록에 돌아온다. ListFragment는 안 읽은 알림 수를 아래처럼 구독한다.

```kotlin
override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    viewModel.unreadCount.observe(this) { count ->
        Log.d("Badge", "update $count")
        binding.badge.text = count.toString()
    }
}
```

앱을 켜서 목록에 들어온 뒤 설정 화면을 두 번 다녀왔다. 이어서 목록에 머무는 동안 새 알림이 한 건 도착하자 Logcat에 아래 로그가 찍혔다.

```
D/Badge: update 4
D/Badge: update 4
D/Badge: update 4
```', 'SUBJECTIVE'),
       (4264, 680, '아래 표에서 세 참조 경로의 맨 끝 지점을 공통으로 가리키는 용어는?', '힙 덤프에서 서로 다른 누수 세 건을 조사했다. 파괴된 액티비티를 가리키는 참조를 거꾸로 따라가자, 각 경로의 맨 끝은 아래와 같았다.

| 누수된 액티비티 | 참조 경로의 맨 끝 |
| --- | --- |
| LoginActivity | SessionHolder 클래스의 static 필드 |
| PhotoActivity | 서버 응답을 기다리며 멈춰 있는 스레드의 스택에 있는 지역 변수 |
| CameraActivity | 네이티브 라이브러리가 만든 JNI 전역 참조 |

세 경우 모두 맨 끝 지점에서 액티비티까지 이어진 참조 가운데 하나를 끊자, 다음 GC에서 액티비티가 회수됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4259
(11531, 4259, 'onDestroyView()와 함께 FeedFragment 인스턴스도 파괴되므로, binding이 가리키던 뷰 트리도 곧바로 회수 대상이 된다.', 'onDestroyView()는 뷰만 정리하는 단계다. addToBackStack()으로 교체하면 FragmentManager가 FeedFragment 인스턴스를 보관해 onDestroy()까지 가지 않으므로, 인스턴스의 필드인 binding도 그대로 남는다.', false),
(11532, 4259, '생성된 바인딩 클래스가 뷰 파괴를 감지해 안의 뷰 필드를 스스로 비우므로, binding에는 빈 껍데기만 남는다.', '뷰 바인딩이 생성한 클래스는 루트 뷰와 각 뷰를 필드로 들고 있을 뿐 생명주기를 감지하지 않는다. 대신 비워 주는 장치가 없으니 onDestroyView()에서 binding = null로 직접 끊어야 한다.', false),
(11533, 4259, 'FeedFragment 인스턴스는 백 스택에 남고, binding이 화면에서 떨어진 목록 뷰와 어댑터를 계속 붙잡아 회수되지 않는다.', '뷰는 파괴됐지만 살아 있는 프래그먼트가 binding으로 이전 루트 뷰를 참조한다. 백 스택에 있는 동안 이 참조가 유지돼 목록 뷰와 FeedAdapter까지 힙에 남으며, onDestroyView()에서 binding을 null로 비우면 끊긴다.', true),
(11534, 4259, '뒤로 돌아오면 binding에 남아 있던 뷰 트리를 다시 붙여 쓰므로 onCreateView()는 다시 호출되지 않는다.', '돌아올 때 프래그먼트는 onCreateView()부터 새 뷰를 만들고 onViewCreated()에서 binding을 새 값으로 덮어쓴다. 이전 뷰 트리는 재사용되지 않고, 덮어써질 때까지 메모리만 차지한 셈이다.', false),

-- 문제 4260
(11535, 4260, 'A에서만 업로드가 끝날 때까지 UploadActivity가 회수되지 않고, B에서는 업로드 중이어도 액티비티가 회수될 수 있다.', 'Kotlin의 inner 클래스는 바깥 인스턴스 참조를 항상 품는다. A는 실행 중인 스레드→UploadTask→UploadActivity로 참조가 이어지지만, B의 중첩 클래스는 file만 들고 있어 스레드에서 액티비티로 가는 경로가 없다.', true),
(11536, 4260, '두 버전 모두 스레드가 실행 중인 동안에는 그 스레드를 시작한 UploadActivity가 똑같이 회수되지 않는다.', '실행 중인 스레드는 자신이 참조하는 객체만 살려 두며, 스레드를 시작한 객체까지 자동으로 붙잡지는 않는다. B의 UploadTask에는 바깥 참조가 없어 스레드에서 액티비티로 이어지는 참조가 없다.', false),
(11537, 4260, 'A의 run()은 액티비티 멤버를 쓰지 않으므로 컴파일러가 바깥 참조를 빼 주어 두 버전의 메모리 동작이 같다.', '쓰는 값만 캡처하는 람다와 헷갈린 것이다. inner 클래스는 멤버를 쓰는지와 상관없이 바깥 인스턴스를 생성자로 받아 필드에 보관하므로, A의 UploadTask는 늘 UploadActivity를 가리킨다.', false),
(11538, 4260, 'A는 inner 클래스라서 UploadActivity가 onDestroy()에 들어가면 그 안에서 시작한 스레드도 함께 중단된다.', '스레드는 액티비티 생명주기와 무관하게 run()이 끝날 때까지 돈다. onDestroy()가 스레드를 멈춰 주지 않으므로, 화면과 함께 끝내려면 직접 중단하거나 lifecycleScope처럼 생명주기에 묶인 스코프를 써야 한다.', false),

-- 문제 4261
(11539, 4261, 'onDestroy()에서 System.gc()를 호출해, 파괴된 CartActivity가 다음 GC를 기다리지 않고 곧바로 회수되게 한다.', 'System.gc()는 회수를 요청할 뿐, 참조가 이어져 닿을 수 있는 객체를 풀어 주지 않는다. static 필드에서 CartActivity까지 경로가 살아 있는 한 몇 번을 불러도 결과는 같다.', false),
(11540, 4261, 'onDestroy()에서 CartActivity의 뷰·어댑터 필드를 null로 비워, 이 경로로 붙잡히는 메모리가 남지 않게 한다.', '필드를 비우면 Retained Size는 줄지만 리스너의 this$0이 CartActivity를 가리키는 연결은 그대로라 액티비티 인스턴스는 계속 남고, 열고 닫을 때마다 하나씩 쌓인다. 줄이는 것과 끊는 것은 다르다.', false),
(11541, 4261, '익명 리스너 객체를 람다로 바꾸면 리스너가 this$0 같은 바깥 액티비티 참조를 갖지 않으므로 이 경로가 끊긴다.', '람다도 본문에서 updateTotal()처럼 액티비티 멤버를 쓰면 바깥 인스턴스를 캡처한다. 표기만 바뀔 뿐, 싱글턴의 listeners가 액티비티를 붙잡은 리스너를 계속 들고 있는 구조는 같다.', false),
(11542, 4261, 'onCreate()에서 넘긴 리스너를 onDestroy()에서 listeners 목록에서 빼도록 해제 코드를 짝지어 둔다.', '오래 사는 싱글턴은 남아 있는 것이 정상이므로, 끊을 곳은 수명이 짧은 리스너를 붙잡는 listeners 참조다. 등록한 onCreate()와 짝이 되는 onDestroy()에서 빼면 static 필드에서 CartActivity로 가는 경로가 사라진다.', true),

-- 문제 4262
(11543, 4262, 'CheckoutActivity가 화면에 떠 있는 동안에도 GC가 돌 때마다 참조가 비워져, 결과 표시가 수시로 빠진다.', '화면에 떠 있는 액티비티는 프레임워크가 강한 참조로 붙잡고 있다. 강한 참조 경로가 하나라도 있으면 GC는 약한 참조를 비우지 않으므로, 살아 있는 화면에는 결과가 정상적으로 전달된다.', false),
(11544, 4262, '결제 중 화면이 닫히고 GC가 돈 뒤 결과가 오면, showResult()가 불리지 않고 결과가 조용히 버려질 수 있다.', '화면이 파괴되고 강한 참조가 사라지면 다음 GC에서 약한 참조가 비워져 get()이 null을 돌려준다. 누수는 막지만 결과를 언제 잃을지 예측하기 어려워, 수명이 맞는 곳에 두는 근본 해법을 쓸 수 없을 때의 차선책이다.', true),
(11545, 4262, 'SDK 싱글턴이 콜백 객체를 계속 붙잡고 있으므로, 그 안에서 가리키는 CheckoutActivity도 회수되지 않아 누수는 그대로다.', '약한 참조만 거쳐 닿는 객체는 GC가 살려 둘 대상으로 보지 않는다. 콜백 객체 자체는 남지만 그 안의 약한 참조는 참조 체인을 이어 주지 않아, 파괴된 CheckoutActivity는 회수된다.', false),
(11546, 4262, '약한 참조는 메모리가 부족해질 때만 비워지므로, 여유 있는 기기에서는 파괴된 CheckoutActivity가 계속 남는다.', '메모리가 부족해질 때까지 버티는 것은 소프트 참조(SoftReference)에 가까운 성질이다. 약한 참조는 강한 참조가 모두 사라지면 메모리 여유와 상관없이 다음 GC에서 비워진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1376, 4263, 'viewLifecycleOwner,getViewLifecycleOwner(),getViewLifecycleOwner,뷰 라이프사이클 오너,뷰라이프사이클오너,뷰 생명주기 오너,view lifecycle owner', 'ListFragment 인스턴스(this)는 백 스택에 들어가도 onDestroy()까지 가지 않아, 생명주기가 CREATED에 머물 뿐 DESTROYED가 되지 않는다. 그래서 this에 묶인 옵저버는 제거되지 않고, 목록으로 돌아와 onViewCreated()가 다시 불릴 때마다 새 옵저버가 하나씩 더해진다. 설정 화면을 두 번 다녀왔으니 옵저버가 3개가 되어 알림 한 건에 로그가 3줄 찍힌 것이다. viewLifecycleOwner는 프래그먼트의 뷰가 만들어질 때 시작해 onDestroyView()에서 DESTROYED가 되므로, 그때 옵저버가 자동으로 빠져 늘 1개만 남는다. requireActivity()를 넘기면 수명이 더 길어져 옵저버가 똑같이 쌓이므로 답이 아니다. 프래그먼트 인스턴스의 수명과 프래그먼트 뷰의 수명이 다르다는 점이 핵심이다.'),
       (1377, 4264, 'GC 루트,GC루트,GC Root,GCRoot,GC Roots,가비지 컬렉션 루트,가비지 컬렉터 루트,garbage collection root,GC 루트 객체,루트 객체,루트 집합,root set', 'GC는 static 필드, 실행 중인 스레드의 스택, JNI 전역 참조처럼 그 자체로 살아 있다고 보는 지점을 GC 루트로 삼고, 여기서 참조를 따라 닿을 수 있는 객체만 남긴다. 파괴된 액티비티라도 루트에서 이어진 참조 체인 위에 있으면 회수되지 않고, 체인 중간의 참조 하나만 끊어도 루트에서 닿을 수 없게 되어 다음 GC에서 회수된다. 루트에서 누수 객체까지 이어진 경로 전체를 뜻하는 참조 체인(Leak Trace), 한 객체가 사라질 때 함께 풀리는 메모리 양인 Retained Size와 구분한다. 또 참조 개수를 세는 방식이 아니므로, 루트에 닿지 않는 순환 참조 묶음은 서로를 가리키고 있어도 회수된다.');

-- =====================================================
-- Lesson 838: 전역 참조와 Context 수명 불일치
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5207, 838, '아래처럼 배너 뷰를 전역 객체에 담아 두고 쓸 때 벌어지는 일로 옳은 것은?', '앱 여러 곳에서 같은 배너 뷰를 가져다 쓰려고, 화면이 만들어질 때마다 그 뷰를 전역 객체에 담아 두었다. HomeActivity는 화면 회전으로 여러 번 재생성되며 그때마다 아래 대입이 다시 실행된다.

```kotlin
object BannerHolder {
    var banner: View? = null
}

class HomeActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)
        BannerHolder.banner = findViewById(R.id.promo_banner)
    }
}
```', 'OBJECTIVE'),
       (5208, 838, '아래 화면에서 회전을 10번 반복한 뒤 힙에 남는 액티비티 인스턴스에 대한 설명으로 옳은 것은?', 'ProfileViewModel은 저장소에서 읽은 값을 화면 언어에 맞게 바꾸려고 Context를 생성자로 받는다. ProfileActivity는 아래처럼 자기 자신을 팩토리에 넘겨 ViewModel을 만들고, 회전을 마칠 때마다 강제 GC를 실행했다.

```kotlin
class ProfileViewModel(private val context: Context) : ViewModel() {
    fun greeting(): String = context.getString(R.string.greeting)
}

class ProfileViewModelFactory(private val context: Context) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T =
        ProfileViewModel(context) as T
}

class ProfileActivity : AppCompatActivity() {
    private val viewModel: ProfileViewModel by viewModels { ProfileViewModelFactory(this) }
}
```', 'OBJECTIVE'),
       (5209, 838, '아래 두 시점의 측정값을 비교한 해석으로 옳은 것은?', '화면이 하나뿐인 사진 목록 앱이다. 앱을 켠 직후에 한 번, 화면 회전을 4번 반복한 뒤에 한 번 아래 명령으로 객체 수를 확인했다. 두 번째 측정 직전에 강제 GC를 실행했고, 그 시점에 화면에 떠 있는 액티비티는 1개다.

```bash
adb shell dumpsys meminfo com.example.gallery
```

| 항목 | 켠 직후 | 회전 4회 후 |
| --- | --- | --- |
| Activities | 1 | 5 |
| Views | 386 | 1,842 |
| AppContexts | 3 | 7 |
| Java Heap (KB) | 14,320 | 58,204 |', 'OBJECTIVE'),
       (5210, 838, '아래 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '액티비티 화면에서 응답까지 10초쯤 걸리는 요청을 띄우는 네 가지 방법을 비교한 표다.

| 실행 방법 | 작업이 취소되는 시점 | 작업에서 액티비티로 참조가 이어지는 경로 |
| --- | --- | --- |
| Thread(익명 Runnable) | 없음 (run이 끝날 때까지) | 익명 클래스가 바깥 인스턴스를 자동으로 참조 |
| GlobalScope.launch | 없음 (프로세스가 끝날 때까지) | 람다가 쓰는 액티비티 멤버를 캡처 |
| lifecycleScope.launch | 액티비티가 DESTROYED가 될 때 | 람다가 쓰는 액티비티 멤버를 캡처 |
| viewModelScope.launch | ViewModel의 onCleared()가 불릴 때 | 없음 (ViewModel 안에서 실행) |', 'OBJECTIVE'),
       (5211, 838, '아래에서 init()에 넘기는 값을 무엇으로 바꾸었는가?', '설정 화면을 열었다 닫기를 10번 반복하고 강제 GC를 한 뒤 힙 덤프를 떴더니, 화면에 떠 있지 않은데도 SettingsActivity 인스턴스가 1개 남아 있었다. 몇 번을 더 열고 닫아도 남는 수는 늘 1개였고, 그 1개는 언제나 가장 마지막에 닫은 화면이었다. 붙잡고 있는 참조를 거꾸로 따라가자 아래 전역 객체가 나왔다. 테마 값은 앱 어느 화면에서나 읽어야 해서 보관한 참조를 비우거나 약한 참조로 바꿀 수는 없었다. init()에 넘기는 값 한 곳만 고치자 같은 시험에서 남는 인스턴스가 0개가 되었다.

```kotlin
object SettingsStore {
    private lateinit var context: Context

    fun init(context: Context) {
        this.context = context
    }

    fun theme(): String =
        context.getSharedPreferences("cfg", Context.MODE_PRIVATE)
            .getString("theme", "light")!!
}

class SettingsActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        SettingsStore.init(this)
    }
}
```', 'SUBJECTIVE'),
       (5212, 838, '아래 경고를 없애려고 onDestroy()에 한 줄로 추가한 호출은?', '새 메시지 알림을 배너로 띄우려고 ChatActivity의 onCreate()에서 IntentFilter를 만들어 브로드캐스트 리시버를 코드로 등록했다. 채팅방을 열고 닫기를 반복하자 닫을 때마다 아래 경고가 찍혔고, 힙 덤프의 ChatActivity 인스턴스도 열고 닫은 횟수만큼 늘어 있었다.

```
E/ActivityThread: Activity com.example.chat.ChatActivity has leaked IntentReceiver
    com.example.chat.ChatActivity$receiver$1@3b9f21c that was originally registered here.
```

onDestroy()에 한 줄을 더하자 경고가 사라졌고 인스턴스 수도 1로 돌아왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5207
(14059, 5207, 'View는 자기가 그려질 자리만 알 뿐 Context를 들고 있지 않으므로, 전역 객체에 담아 둬도 액티비티 회수에는 영향이 없다.', '모든 View는 생성될 때 받은 Context를 필드로 보관하고, 레이아웃에서 만들어진 뷰의 Context는 그 화면의 액티비티다. 전역 객체가 뷰 하나를 붙잡으면 그 참조를 타고 액티비티까지 살아남는다.', false),
(14060, 5207, '전역 객체가 가장 최근에 담은 뷰 하나를 붙잡아, 그 뷰가 들고 있는 Context인 액티비티가 파괴된 뒤에도 회수되지 않는다.', '프로세스와 수명이 같은 object는 정적 필드로 컴파일돼 GC 루트 쪽에 놓인다. 전역 객체에서 뷰, 뷰에서 Context인 액티비티로 참조가 이어지므로 담아 둔 뷰 하나 때문에 화면 전체가 힙에 남는다.', true),
(14061, 5207, '회전할 때마다 직전 화면의 뷰가 함께 쌓여, 회전 횟수만큼 HomeActivity 인스턴스가 남는다.', 'banner는 값을 하나만 담는 필드라 새로 대입할 때마다 이전 뷰를 가리키던 참조가 끊긴다. 그래서 남는 액티비티는 마지막 하나뿐이며, 목록이나 맵에 계속 더하는 구조라야 회전 횟수만큼 쌓인다.', false),
(14062, 5207, '담기 전에 부모 레이아웃에서 removeView로 떼어 내면 액티비티로 이어지는 참조까지 함께 끊긴다.', '부모에서 떼어 내면 뷰 트리 위쪽 연결만 사라질 뿐, 뷰가 만들어질 때부터 들고 있던 Context 참조는 그대로 남는다. 끊어야 할 곳은 전역 객체가 뷰를 가리키는 참조다.', false),

-- 문제 5208
(14063, 5208, '회전할 때마다 ViewModel이 새로 만들어지면서 그때 받은 액티비티를 각각 붙잡으므로, 회전 횟수만큼 ProfileActivity가 쌓인다.', 'ViewModel은 구성 변경을 견디도록 ViewModelStore에 보관돼, 회전 뒤에는 같은 인스턴스가 그대로 돌아온다. 새로 만들어지지 않으니 팩토리도 다시 쓰이지 않고 붙잡히는 액티비티도 늘지 않는다.', false),
(14064, 5208, '회전으로 이전 액티비티가 파괴될 때 onCleared()가 불려 생성자로 받은 참조가 정리되므로, 회수되지 못하고 남는 인스턴스는 없다.', 'onCleared()는 회전 때가 아니라 ViewModel이 완전히 버려질 때, 즉 화면이 진짜로 끝날 때 한 번 불린다. 게다가 onCleared()가 생성자로 받아 둔 필드를 알아서 비워 주지도 않는다.', false),
(14065, 5208, '액티비티가 파괴되면 그 Context는 프레임워크가 무효 상태로 바꾸기 때문에, 참조가 남아 있어도 메모리는 회수된다.', '파괴 여부를 나타내는 플래그가 붙을 뿐 객체가 사라지는 것은 아니다. GC는 플래그가 아니라 GC 루트에서의 도달 가능성만 보므로, 참조가 이어져 있으면 뷰 트리까지 그대로 남는다.', false),
(14066, 5208, '맨 처음 ViewModel을 만들 때 팩토리에 넘어간 ProfileActivity 하나가, 회전을 몇 번 하든 같은 ViewModel에 붙잡혀 계속 남는다.', 'ViewModel은 회전을 넘겨 유지되므로 처음 받은 액티비티를 끝까지 가리킨다. 화면에 떠 있는 최신 액티비티와 별개로 첫 인스턴스가 회수되지 않아, 회전을 10번 해도 힙에 남는 액티비티는 2개다.', true),

-- 문제 5209
(14067, 5209, 'Activities가 1에서 5로 늘고 Views도 다섯 배 가까이 늘었으므로, 파괴된 액티비티가 뷰 트리를 붙잡은 채 남아 있다고 볼 수 있다.', '회전 횟수만큼 액티비티가 더 잡혀 있고 뷰 수도 같은 배수로 늘었다는 것은 화면 한 벌이 통째로 회수되지 않았다는 뜻이다. 액티비티가 남으면 그 뷰 계층과 비트맵까지 함께 남는다는 점이 수치로 드러났다.', true),
(14068, 5209, 'Views가 1,842개나 되는 것이 문제의 핵심이므로, 레이아웃 중첩을 줄여 뷰 개수를 낮추는 일이 먼저다.', '화면 수는 그대로인데 386개였던 뷰가 다섯 배가 된 점이 요점이다. 레이아웃이 복잡한 것과 같은 레이아웃이 여러 벌 남아 있는 것은 다른 문제이며, 여기서는 뒤쪽이라 중첩을 줄여도 수치는 그대로다.', false),
(14069, 5209, '회전하면 액티비티가 재생성되므로 Activities가 5인 것은 정상이며, 이전 인스턴스는 다음 GC에서 사라진다.', '재생성 자체는 정상이지만 이전 인스턴스는 곧 회수돼야 한다. 강제 GC를 한 뒤에 측정했는데도 4개가 남았다는 것은 GC가 아직 안 돈 것이 아니라 루트에서 닿는 참조가 살아 있다는 뜻이다.', false),
(14070, 5209, 'Java Heap이 14,320KB에서 58,204KB로 커진 것만이 직접 증거이고, Activities 수는 메모리 사용량과 무관한 지표다.', '힙 증가는 이미지 캐시나 비트맵 로딩으로도 생겨 그것만으로는 원인을 못 짚는다. 반대로 Activities 수는 회수됐어야 할 화면이 몇 개 남았는지 바로 알려 주는 값이라 누수 판단에서 먼저 본다.', false),

-- 문제 5210
(14071, 5210, 'Thread로 띄운 익명 Runnable은 액티비티를 끝내도 스스로 멈추지 않으므로, 응답이 올 때까지 그 화면이 힙에 남는다.', '표의 두 열이 함께 걸리는 경우다. 취소 장치가 없는 데다 익명 클래스가 바깥 인스턴스를 자동으로 참조하니, 실행 중인 스레드에서 액티비티까지 이어진 참조가 10초 동안 유지된다.', false),
(14072, 5210, 'GlobalScope.launch 안에서 화면의 텍스트뷰를 갱신하면, 화면을 닫아도 응답이 도착할 때까지 액티비티가 회수되지 않는다.', '텍스트뷰를 건드리려면 람다가 액티비티 멤버를 캡처해야 하고, GlobalScope는 프로세스와 수명이 같아 화면이 닫혀도 취소되지 않는다. 그래서 응답이 오기 전까지 참조 체인이 끊기지 않는다.', false),
(14073, 5210, 'viewModelScope로 띄운 요청은 회전으로 액티비티가 파괴될 때 함께 취소되므로, 회전 뒤에는 요청을 처음부터 다시 보내야 한다.', '표에서 viewModelScope의 취소 시점은 액티비티 파괴가 아니라 onCleared()다. 회전으로 액티비티가 파괴돼도 ViewModel은 살아남으므로 요청도 이어지며, 회전 때마다 재요청하는 일을 피하려고 쓰는 방법이기도 하다.', true),
(14074, 5210, 'lifecycleScope로 띄우면 취소 시점이 생명주기에 묶여 있어, 화면을 닫을 때 해제 코드를 따로 짝지어 두지 않아도 된다.', 'lifecycleScope는 액티비티가 DESTROYED가 되는 순간 그 스코프의 코루틴을 함께 취소한다. 등록과 해제를 직접 짝지어야 하는 리스너와 달리 취소가 생명주기에 딸려 오므로 캡처한 참조도 함께 풀린다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1692, 5211, 'applicationContext,application context,context.applicationContext,this.applicationContext,getApplicationContext(),getApplicationContext,애플리케이션 컨텍스트,애플리케이션컨텍스트,앱 컨텍스트', 'object로 선언한 싱글턴은 프로세스와 수명이 같아서, 한 번 받아 둔 Context를 앱이 끝날 때까지 들고 있다. 여기에 액티비티를 넘기면 그 화면이 닫힌 뒤에도 정적 필드에서 액티비티로 참조가 이어져 회수되지 않고, 그 화면의 뷰 트리와 비트맵까지 함께 남는다. context는 값을 하나만 담는 필드라 화면을 다시 열 때마다 이전 참조가 끊기므로 남는 인스턴스는 늘 마지막에 닫은 하나뿐이지만, 화면 한 벌이 통째로 붙잡혀 있다는 점에서 누수인 것은 같다. applicationContext는 화면이 아니라 Application 객체를 가리키고 이 객체는 프로세스와 수명이 같으므로, 같은 자리에 넣어도 회수를 막지 않는다. 다만 테마가 없는 Context라 다이얼로그를 띄우거나 레이아웃을 인플레이트하는 데는 쓸 수 없고, 그런 작업은 보관하지 말고 호출 시점에 Activity Context를 받아서 처리한다. 약한 참조로 감싸는 방법은 참조가 언제 비워질지 예측하기 어려워, 설정 값을 상시로 읽어야 하는 이 상황에는 맞지 않는다.'),
       (1693, 5212, 'unregisterReceiver,unregisterReceiver(),unregisterReceiver(receiver),언레지스터리시버,리시버 해제,브로드캐스트 리시버 해제', '코드로 등록한 리시버는 액티비티가 아니라 앱 프로세스 쪽에서 등록 정보를 들고 있다. 해제하지 않으면 그 등록을 통해 파괴된 액티비티까지 참조가 이어지고, 화면을 열고 닫을 때마다 등록이 하나씩 더해져 액티비티도 그만큼 쌓인다. 경고에 IntentReceiver가 새어 나갔다고 찍힌 것이 이 상태를 가리킨다. registerReceiver()와 unregisterReceiver()는 대칭 콜백에서 짝을 맞춰야 하며, onCreate()에서 등록했으면 onDestroy()에서, onStart()에서 등록했으면 onStop()에서 해제한다. 매니페스트에 선언한 리시버는 시스템이 수명을 관리하므로 이런 해제가 필요 없고, 반대로 해제를 두 번 부르면 IllegalArgumentException이 나므로 짝을 한 번씩만 맞춘다는 점도 함께 기억해 둔다.');
