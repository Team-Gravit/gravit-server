-- Unit: 4대 컴포넌트와 인텐트 (Unit ID: 92)
-- Chapter: AOS (Chapter ID: 8)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (518, 92, '암시적 인텐트와 PendingIntent'),
       (676, 92, 'exported 선언과 패키지 가시성'),
       (834, 92, '서비스 종류와 브로드캐스트, 인텐트 필터');

-- =====================================================
-- Lesson 518: 암시적 인텐트와 PendingIntent
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3287, 518, '아래 안드로이드 컴포넌트에 대한 설명으로 옳은 것은?', '콘텐츠 프로바이더는 앱이 가진 데이터를 content://authority/path 형태의 URI 인터페이스로 다른 앱에 공개하는 컴포넌트다. query()·insert()·update()·delete() 같은 CRUD 메서드를 구현하며, 내부 저장소로는 보통 SQLite(Room)를 쓴다.', 'OBJECTIVE'),
       (3288, 518, '아래 코드와 매니페스트 선언이 함께 있을 때 startActivity 호출 결과로 옳은 것은?', '보내는 쪽 코드

```kotlin
val intent = Intent(Intent.ACTION_SEND).apply {
    type = "image/png"
    putExtra(Intent.EXTRA_TEXT, "주문이 완료되었습니다")
}
startActivity(intent)
```

받는 쪽 매니페스트

```xml
<activity android:name=".ShareActivity" android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/plain" />
    </intent-filter>
</activity>
```

이 기기에는 위 ShareActivity 말고 ACTION_SEND를 처리하는 컴포넌트가 없다.', 'OBJECTIVE'),
       (3289, 518, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | 명시적 인텐트 | 암시적 인텐트 |
| --- | --- | --- |
| 대상 지정 | 클래스 이름을 직접 지정 | 액션·데이터·카테고리로 간접 지정 |
| 인텐트 필터 | 불필요 | 수신 측에 필수 |
| 주 용도 | 앱 내부 화면 전환, 서비스 시작 | 타 앱 기능 호출(공유·브라우저·전화) |
| 실패 가능성 | 낮음(클래스가 있으면 성공) | 처리할 앱이 없으면 예외 |
| 보안 | 안전 | 악의적 앱이 가로챌 수 있음 |', 'OBJECTIVE'),
       (3290, 518, '아래 서비스를 startService()로 시작했을 때 ANR이 계속 나는 원인으로 옳은 것은?', '개발자는 무거운 작업을 코루틴으로 옮겼는데도 ANR이 사라지지 않는다고 말한다.

```kotlin
class SyncService : Service() {
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        scope.launch {
            val digest = hashLargeFiles(cacheDir)  // 순수 CPU 연산, 약 8초 소요
            saveDigest(digest)
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
```

```
ANR in com.example.player
Reason: Input dispatching timed out (Application does not respond)
```', 'OBJECTIVE'),
       (3291, 518, '아래 증상의 원인이 된, 알림에 함께 넘긴 객체의 이름은?', '주문 5건에 대해 알림을 하나씩 띄웠다. 알림마다 다른 주문 ID를 인텐트 엑스트라에 담았고, 요청 코드(requestCode)는 모두 0으로 두었다. 그런데 어떤 알림을 탭해도 항상 첫 번째 주문의 상세 화면이 열렸다. 알림마다 요청 코드를 다르게 주거나 FLAG_UPDATE_CURRENT를 붙이자 비로소 각 알림이 제 주문을 열었다.', 'SUBJECTIVE'),
       (3292, 518, '아래 두 장면에서 화면이 걷히는 순서와 범위를 결정하는 구조의 이름은?', '장면 1 — 목록 화면에서 상세 화면으로, 다시 공유 화면으로 이동한 뒤 뒤로 가기를 세 번 누르면 공유, 상세, 목록 순으로 화면이 하나씩 걷히고 앱이 끝난다.

장면 2 — 공유 화면에서 FLAG_ACTIVITY_CLEAR_TOP을 붙여 목록 화면을 다시 시작하면, 목록 화면 위에 있던 상세와 공유가 함께 사라지고 이미 만들어져 있던 목록 화면이 그대로 다시 보인다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3287
(8939, 3287, '매니페스트에 선언하지 않고 코드에서 등록·해제할 수 있어, 화면이 떠 있는 동안에만 동작하게 만들 수 있다.', '코드로 등록·해제할 수 있는 것은 브로드캐스트 리시버다. 본문의 컴포넌트는 매니페스트 선언이 필수라 실행 도중에 붙였다 뗄 수 없다.', false),
(8940, 3287, '화면 회전 같은 구성 변경이 일어나면 인스턴스가 소멸·재생성되며 콜백이 처음부터 다시 호출된다.', '구성 변경마다 소멸·재생성되는 것은 화면을 담당하는 액티비티다. UI가 없는 본문의 컴포넌트는 회전과 무관하게 프로세스가 살아 있는 동안 유지된다.', false),
(8941, 3287, '앱 프로세스가 만들어질 때 Application.onCreate()보다 먼저 초기화돼, 라이브러리 초기화 지점으로도 쓰인다.', '다른 앱이 언제든 URI로 질의할 수 있어야 하므로 시스템이 프로세스 생성 직후 가장 먼저 만든다. App Startup 같은 라이브러리가 이 순서를 이용해 초기화를 얹는다.', true),
(8942, 3287, '메서드가 자기 앱의 메인 스레드에서 호출되므로, 무거운 질의를 그대로 두면 ANR로 이어진다.', '메인 스레드에서 콜백이 도는 것은 서비스·브로드캐스트 리시버다. 본문의 컴포넌트는 호출자 요청을 바인더 스레드 풀에서 처리하므로 자기 앱의 메인 스레드를 막지 않는다.', false),

-- 문제 3288
(8943, 3288, '액션과 카테고리가 맞으므로 ShareActivity가 열리고 EXTRA_TEXT에 담긴 문자열을 그대로 받는다.', '인텐트 필터는 액션·데이터·카테고리 세 가지를 모두 통과해야 매칭된다. 액션이 맞아도 데이터 조건에서 걸리면 대상 후보에서 빠진다.', false),
(8944, 3288, '필터가 선언한 MIME 타입과 달라 매칭에 실패하고, 처리할 컴포넌트가 없어 ActivityNotFoundException이 발생한다.', '필터는 text/plain만 처리한다고 선언했는데 인텐트는 image/png를 실었다. 데이터 조건에서 탈락해 후보가 0개가 되고, 암시적 인텐트는 이때 예외로 끝난다.', true),
(8945, 3288, 'CATEGORY_DEFAULT를 코드에서 붙이지 않았으므로 카테고리 조건에서 매칭이 끊긴다.', 'startActivity로 보내는 암시적 인텐트에는 시스템이 CATEGORY_DEFAULT를 자동으로 더해 준다. 매칭이 끊긴 곳은 카테고리가 아니라 MIME 타입이다.', false),
(8946, 3288, '매칭되는 컴포넌트가 ShareActivity 하나뿐이라 선택 대화상자 없이 곧바로 실행된다.', '후보가 하나면 대화상자 없이 실행되는 것은 맞지만, 여기서는 MIME 타입이 달라 애초에 후보에 들지 못한다. 선택 대화상자는 후보가 둘 이상일 때의 이야기다.', false),

-- 문제 3289
(8947, 3289, '같은 앱 안에서 상세 화면으로 이동할 때는 클래스를 직접 지정하는 쪽이 실행에 실패할 여지가 적다.', '표의 실패 가능성 행에서 따라 나온다. 대상 클래스가 앱 안에 있으니 매칭 과정 없이 바로 시작되고, 처리할 앱이 없어 예외가 나는 상황도 생기지 않는다.', false),
(8948, 3289, '결제 토큰처럼 민감한 값을 실어 보낼 때는 클래스를 직접 지정하는 쪽이 가로채기 위험이 낮다.', '표의 보안 행에서 따라 나온다. 대상이 한 클래스로 못 박혀 있어 제3의 앱이 필터를 걸어 두고 같은 인텐트를 받아 가로챌 틈이 없다.', false),
(8949, 3289, '처리 주체를 가리지 않는 공유 기능에는 액션·데이터로 대상을 간접 지정하는 쪽이 어울린다.', '표의 주 용도 행에서 따라 나온다. 어떤 앱이 처리할지 미리 알 수 없으므로 대상 클래스를 못 박지 않고 매칭을 시스템에 맡긴다.', false),
(8950, 3289, '클래스 이름을 직접 지정하는 방식도 수신 측이 인텐트 필터를 선언해 두어야 대상이 정해진다.', '표의 인텐트 필터 행에 정면으로 걸린다. 필터가 필요한 쪽은 암시적 인텐트이고, 클래스를 못 박은 인텐트는 매칭 과정 자체를 건너뛰고 그 컴포넌트로 바로 간다.', true),

-- 문제 3290
(8951, 3290, '코루틴으로 감쌌어도 디스패처가 메인이라 8초짜리 연산이 메인 스레드를 그대로 붙잡는다.', 'CoroutineScope(Dispatchers.Main)에서 launch하면 블록이 메인 스레드에서 실행된다. 중간에 suspend 지점도 없어 8초 내내 입력 처리가 밀린다. Dispatchers.Default로 옮겨야 풀린다.', true),
(8952, 3290, '서비스 콜백은 본래 워커 스레드에서 도는데, launch로 코루틴을 띄우면 실행이 메인 스레드로 옮겨진다.', '서비스가 별도 스레드에서 돈다는 흔한 오해다. onStartCommand는 처음부터 메인 스레드에서 호출되며, 코루틴이 스레드를 옮긴 것이 아니라 디스패처가 메인이라 그대로 남은 것이다.', false),
(8953, 3290, 'launch가 첫 suspend 지점까지 실행을 미루므로, onStartCommand가 반환된 뒤 연산이 한꺼번에 몰린다.', '기본 시작 방식은 실행을 뒤로 미루지 않고 곧바로 예약한다. 설령 실행 시점이 밀리더라도 같은 메인 스레드를 쓰는 한 8초 동안 입력이 막히는 결과는 달라지지 않는다.', false),
(8954, 3290, 'START_STICKY로 반환해 시스템이 서비스를 곧바로 재생성하면서 같은 연산이 겹쳐 실행된다.', 'START_STICKY는 메모리 부족 등으로 시스템이 서비스를 죽인 뒤에 다시 만들라는 뜻이다. 정상 실행 중에 재생성이 반복되지 않으므로 연산이 겹칠 일이 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1052, 3291, 'PendingIntent,pending intent,펜딩 인텐트,펜딩인텐트,대기 인텐트', '요청 코드와 인텐트가 같으면 시스템이 기존 PendingIntent를 재사용하고 엑스트라는 갱신하지 않는다. 그래서 알림 5개가 첫 주문 ID를 그대로 물고 있었고, 요청 코드를 달리하거나 FLAG_UPDATE_CURRENT를 주면 해결된다. 알림을 실제로 탭할 때 인텐트를 발동시키는 쪽은 시스템 UI이고, PendingIntent는 그 실행을 내 앱의 권한과 신원으로 위임하는 토큰이다. 만드는 즉시 내가 실행하는 일반 인텐트와 구분해야 하며, Android 12(API 31)부터는 FLAG_IMMUTABLE 또는 FLAG_MUTABLE을 반드시 지정해야 한다.'),
       (1053, 3292, '백 스택,백스택,back stack,backstack,액티비티 백 스택', '액티비티는 방문 순서대로 하나씩 쌓이고 뒤로 가기는 맨 위부터 꺼내므로 장면 1처럼 역순으로 걷힌다. 장면 2의 FLAG_ACTIVITY_CLEAR_TOP은 대상 액티비티 위에 있던 항목을 한꺼번에 걷어내고 이미 있던 인스턴스를 재사용하는데, 이런 동작이 가능한 이유가 방문 이력이 스택으로 남아 있기 때문이다. 이 스택을 담아 최근 앱 목록에 하나의 작업 단위로 보이는 태스크(Task)와는 층이 다르므로 구분해야 한다.');

-- =====================================================
-- Lesson 676: exported 선언과 패키지 가시성
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4235, 676, '아래 상황에서 메모 앱을 고른 직후 TRACE 태그로 찍히는 로그의 순서로 옳은 것은?', '뉴스 앱에서 기사 링크를 공유하자(ACTION_SEND, text/plain) 대상 앱 목록이 떴고, 사용자가 메모 앱을 골랐다. 이 순간 메모 앱의 프로세스는 실행 중이 아니었다.

메모 앱의 매니페스트에는 application의 android:name이 .MemoApp으로 지정돼 있다. MainActivity는 MAIN·LAUNCHER 필터로, QuickNoteActivity는 SEND 액션·DEFAULT 카테고리·text/plain 타입 필터와 exported="true"로 등록돼 있다.

```kotlin
class MemoApp : Application() {
    override fun onCreate() {
        super.onCreate()
        Log.d("TRACE", "MemoApp.onCreate")
    }
}

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("TRACE", "MainActivity.onCreate")
    }
}

class QuickNoteActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("TRACE", "QuickNoteActivity.onCreate")
    }
}
```', 'OBJECTIVE'),
       (4236, 676, '아래 코드에서 bindService()를 호출한 결과로 옳은 것은?', '음악 앱의 PlayerActivity가 같은 앱 안의 PlayerService에 연결해 재생을 제어하려고 한다. 앱의 targetSdkVersion은 34이고, 호출 시점에 PlayerService는 실행 중이 아니다. 기기에서 아래 액션을 선언한 서비스는 PlayerService 하나뿐이다.

```kotlin
// PlayerActivity.kt
override fun onStart() {
    super.onStart()
    val intent = Intent("com.example.music.action.BIND_PLAYER")
    bindService(intent, connection, Context.BIND_AUTO_CREATE)
}
```

```xml
<!-- 같은 앱의 AndroidManifest.xml -->
<service
    android:name=".PlayerService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.example.music.action.BIND_PLAYER" />
    </intent-filter>
</service>
```', 'OBJECTIVE'),
       (4237, 676, '아래 매니페스트에서 설치 거부의 원인이 된 선언은?', '쇼핑 앱의 targetSdkVersion을 30에서 31로 올린 뒤 기기에 설치하자, 설치 단계에서 매니페스트 문제로 거부됐다. 아래는 매니페스트의 컴포넌트 선언 부분이며, 이 밖의 설정은 올리기 전과 같다.

```xml
<activity
    android:name=".MainActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>

<activity android:name=".SettingsActivity" />

<activity android:name=".ProductLinkActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" android:host="shop.example.com" />
    </intent-filter>
</activity>

<service
    android:name=".OrderSyncService"
    android:exported="true" />

<receiver
    android:name=".CartReminderReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="com.example.shop.action.CART_REMINDER" />
    </intent-filter>
</receiver>
```', 'OBJECTIVE'),
       (4238, 676, '아래 (가)와 (나)에서 onReceive()가 호출되는 리시버를 바르게 짝지은 것은?', '충전 알림 앱(targetSdkVersion 33)이 충전기 연결 이벤트(android.intent.action.ACTION_POWER_CONNECTED)를 받으려고 리시버를 두 가지 방식으로 등록했다. 이 이벤트는 받을 앱을 지정하지 않고 시스템이 보내는 암시적 브로드캐스트이며, Android 8.0의 브로드캐스트 제한에서 예외로 빠진 이벤트가 아니다.

- 리시버 A: 매니페스트에 `<receiver>`와 인텐트 필터로 선언
- 리시버 B: MainActivity의 onStart()에서 registerReceiver()로 등록하고, onStop()에서 unregisterReceiver()로 해제

(가) 사용자가 MainActivity 화면을 보고 있는 동안 충전기를 꽂았다.

(나) 사용자가 홈 화면으로 나간 뒤 앱 프로세스가 종료됐고, 그 상태에서 충전기를 뺐다가 다시 꽂았다.', 'OBJECTIVE'),
       (4239, 676, '아래 상황에서 기록이 끊기지 않도록 바꾼 실행 형태를 가리키는 용어는?', '러닝 기록 앱에서 [달리기 시작]을 누르면, 화면 없이 GPS 위치를 1초마다 저장하는 작업을 startService()로 시작하도록 만들었다. Android 8.0 이상 기기에서 사용자가 버튼을 누르고 곧바로 화면을 끈 채 달리자, 몇 분 지나지 않아 기록이 멈춰 5km 코스 중 0.6km만 저장됐다.

버튼을 누를 때 작업을 시작하는 호출을 바꾸고, 시작 직후 알림 표시줄에 "달리는 중 · 3.2km"처럼 거리가 갱신되는 알림을 띄우도록 고쳤다. 그 뒤로는 화면을 끈 채 40분을 달려도 기록이 끊기지 않았다.', 'SUBJECTIVE'),
       (4240, 676, '아래 상황에서 버튼이 사라지게 만든 제한을 가리키는 용어는?', '결제 화면에서는 파트너 간편결제 앱(com.partner.pay)의 결제 액티비티를 찾을 수 있을 때만 [간편결제] 버튼을 보여 준다.

```kotlin
val intent = Intent("com.partner.pay.action.PAY")
payButton.isVisible = intent.resolveActivity(packageManager) != null
```

targetSdkVersion을 29에서 30으로 올리자 버튼이 사라졌다. 파트너 앱은 기기에 설치돼 있고, 직접 실행하면 결제 화면도 정상적으로 열린다. 코드와 파트너 앱의 인텐트 필터는 그대로 둔 채 매니페스트에 아래 블록만 추가하자 버튼이 다시 보였다.

```xml
<queries>
    <package android:name="com.partner.pay" />
</queries>
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4235
(11467, 4235, 'MemoApp.onCreate → MainActivity.onCreate → QuickNoteActivity.onCreate', '앱이 늘 런처 액티비티부터 연다는 오해다. 시스템은 매니페스트에서 인텐트와 맞는 QuickNoteActivity를 찾아 곧바로 만든다. MAIN·LAUNCHER 필터는 런처 아이콘을 눌렀을 때의 진입점일 뿐이다.', false),
(11468, 4235, 'MemoApp.onCreate → QuickNoteActivity.onCreate', '앱에는 단일 진입점이 없다. 시스템이 공유 인텐트에 맞는 QuickNoteActivity를 띄우려고 메모 앱 프로세스를 새로 만들고, MemoApp.onCreate()를 먼저 호출한 뒤 그 액티비티를 인스턴스화한다. MainActivity는 이 흐름에 끼지 않는다.', true),
(11469, 4235, 'QuickNoteActivity.onCreate → MemoApp.onCreate', '요청받은 컴포넌트가 가장 먼저 만들어진다는 오해다. 새 프로세스에서는 Application.onCreate()가 액티비티 생성보다 앞선다. 네 컴포넌트 중 Application.onCreate()보다 먼저 초기화되는 것은 콘텐츠 프로바이더뿐이다.', false),
(11470, 4235, 'QuickNoteActivity.onCreate', '다른 앱이 띄운 화면은 호출한 앱의 프로세스에서 실행된다는 오해다. 액티비티는 자기 앱의 프로세스에서 돌기 때문에 메모 앱 프로세스가 새로 만들어지고, 그 과정에서 MemoApp.onCreate()가 먼저 찍힌다.', false),

-- 문제 4236
(11471, 4236, '액션이 맞는 서비스가 하나뿐이라 PlayerService가 생성되고 onServiceConnected()가 호출된다.', '액티비티의 암시적 인텐트 해석을 서비스에도 그대로 적용한 오해다. Android 5.0(API 21)부터 서비스는 대상 클래스를 지정하지 않은 인텐트로 시작하거나 연결할 수 없어, 필터가 맞아도 생성 단계까지 가지 못한다.', false),
(11472, 4236, 'exported가 false라 같은 앱의 액티비티도 연결을 거부당해 SecurityException이 발생한다.', 'exported는 다른 앱이 이 컴포넌트를 시작하거나 연결할 수 있는지를 정한다. false여도 같은 앱의 컴포넌트는 막히지 않으므로 SecurityException의 원인이 될 수 없다.', false),
(11473, 4236, '서비스가 아직 실행 중이 아니라 연결할 대상이 없어 bindService()가 false를 반환한다.', '이미 떠 있는 서비스에만 연결된다는 오해다. BIND_AUTO_CREATE를 주면 실행 중이 아닌 서비스도 새로 만들어 연결한다. 이 호출이 실패하는 이유는 서비스 상태가 아니라 인텐트의 형태다.', false),
(11474, 4236, '대상 클래스를 지정하지 않은 인텐트라 매칭을 시도하기 전에 bindService()에서 예외가 발생한다.', '서비스는 명시적 인텐트로만 시작해야 한다. 액션만 담은 암시적 인텐트로 bindService()를 부르면 IllegalArgumentException이 난다. Intent(this, PlayerService::class.java)처럼 클래스를 직접 지정해야 연결된다.', true),

-- 문제 4237
(11475, 4237, 'ProductLinkActivity 선언', 'Android 12(API 31)부터 인텐트 필터가 있는 컴포넌트는 exported 값을 반드시 적어야 한다. 이 액티비티만 필터를 두고도 exported를 생략해 설치가 거부됐다. 외부 링크로 열려야 하므로 true로 명시하면 된다.', true),
(11476, 4237, 'OrderSyncService 선언', '필터 없이 exported를 true로 두면 안 된다는 오해다. 필터가 없어도 다른 앱이 명시적 인텐트로 시작하도록 열어 둘 수 있다. 값이 명시돼 있으므로 설치 규칙에 걸리지 않는다.', false),
(11477, 4237, 'SettingsActivity 선언', '모든 컴포넌트에 exported를 적어야 한다는 오해다. 명시 의무는 인텐트 필터가 있는 컴포넌트에만 붙는다. 필터가 없으면 생략해도 외부에 공개되지 않는 쪽으로 처리돼 설치에 문제가 없다.', false),
(11478, 4237, 'CartReminderReceiver 선언', '필터가 있으면 exported가 반드시 true여야 한다는 오해다. 규칙은 값을 명시하라는 것이지 true를 강제하지 않는다. false로 적으면 다른 앱이 보낸 브로드캐스트를 받지 않을 뿐 설치는 통과한다.', false),

-- 문제 4238
(11479, 4238, '(가) A·B / (나) A', '매니페스트에 선언하면 앱 상태와 상관없이 늘 받는다는, Android 8.0 이전 동작에 머문 오해다. 이제 대부분의 암시적 브로드캐스트는 매니페스트로 선언한 리시버에 아예 전달되지 않는다.', false),
(11480, 4238, '(가) A·B / (나) 없음', '제한이 앱이 백그라운드에 있을 때만 걸린다는 오해다. 매니페스트로 선언한 리시버는 앱 화면이 떠 있어도 암시적 브로드캐스트를 받지 못하므로 (가)에서도 A는 호출되지 않는다.', false),
(11481, 4238, '(가) B / (나) 없음', 'A는 매니페스트 선언이라 대부분의 암시적 브로드캐스트를 받을 수 없어 두 장면 모두 호출되지 않는다. B는 화면이 보이는 동안만 등록돼 (가)에서 호출되고, (나)에서는 onStop()에서 이미 해제된 상태다.', true),
(11482, 4238, '(가) B / (나) B', '코드로 등록한 리시버가 시스템에 남아 계속 받는다는 오해다. B는 onStop()에서 해제됐고, 코드로 등록한 리시버는 앱 프로세스가 살아 있는 동안에만 유효하므로 (나)에서는 호출될 수 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1368, 4239, '포그라운드 서비스,포그라운드서비스,포어그라운드 서비스,포어그라운드서비스,foreground service,foregroundservice,전경 서비스', 'startService()로 시작한 일반 서비스는 Android 8.0부터 백그라운드 실행 제한을 받는다. 앱이 백그라운드로 가고 잠시 뒤 시스템이 서비스를 중지하며, 백그라운드 상태에서는 startService()로 새로 시작할 수도 없다. startForegroundService()로 시작하고 사용자가 볼 수 있는 알림을 띄우면 포그라운드 서비스가 되어, 사용자가 인지하는 작업으로 취급돼 화면이 꺼져도 계속 실행된다. 알림 표시가 필수라는 점이 일반 서비스와 갈리는 지점이다. bindService()로 연결한 클라이언트가 모두 연결을 끊으면 종료되는 바인드 서비스와 구분해야 하고, 별도 스레드에서 돈다는 뜻도 아니다. 콜백은 여전히 메인 스레드에서 호출되므로 위치 저장 같은 작업은 따로 스레드로 넘겨야 한다.'),
       (1369, 4240, '패키지 가시성,패키지 가시성 제한,패키지 가시성 필터링,package visibility,package visibility filtering,패키지 visibility,앱 가시성,앱 가시성 제한', 'Android 11(API 30)을 대상으로 하는 앱은 기기에 설치된 다른 앱을 기본적으로 조회할 수 없다. 그래서 파트너 앱이 설치돼 있어도 resolveActivity()가 null을 돌려줘 버튼이 숨겨졌고, 매니페스트의 queries 요소에 조회할 패키지를 선언하자 다시 보였다. 인텐트 필터 매칭 실패와 헷갈리기 쉽지만, 인텐트와 필터는 그대로였고 targetSdkVersion만 바뀌었다는 점이 다르다. 또한 exported는 다른 앱이 내 컴포넌트를 시작할 수 있는지를, 패키지 가시성은 내 앱이 다른 앱을 조회할 수 있는지를 다루므로 방향이 반대다.');

-- =====================================================
-- Lesson 834: 서비스 종류와 브로드캐스트, 인텐트 필터
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5183, 834, '아래 서비스 비교표를 바탕으로 옳지 않은 것은?', '| 종류 | 시작 방법 | 종료 시점 | 대표 용도 |
| --- | --- | --- | --- |
| 시작된 서비스 | startService() | stopSelf() 또는 stopService() 호출 | 파일 다운로드·업로드 |
| 바인드 서비스 | bindService() | 모든 클라이언트가 unbindService() 호출 | 음악 재생 제어, 앱 간 통신 |
| 포그라운드 서비스 | startForegroundService() | 알림을 띄운 채 실행, 명시적 중지 | 내비게이션, 길 안내 |', 'OBJECTIVE'),
       (5184, 834, '아래 컴포넌트를 앱에서 쓸 때 옳은 것은?', '기기의 배터리가 부족해지거나, 네트워크 연결 상태가 바뀌거나, 부팅이 끝났을 때 시스템은 그 사실을 알리는 메시지를 기기 전체에 뿌린다. 앱은 이 메시지를 받아 처리하려고 이 컴포넌트를 매니페스트나 코드로 등록해 둔다.', 'OBJECTIVE'),
       (5185, 834, '아래 화면 구현에 남아 있는 보안 문제로 옳은 것은?', '사내 문서함 앱의 화면이다. 같은 회사의 다른 앱이 문서 화면을 바로 열 수 있도록 필터를 열어 두었다.

```xml
<activity android:name=".DocumentViewerActivity" android:exported="true">
    <intent-filter>
        <action android:name="com.example.docs.action.OPEN_DOC" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</activity>
```

```kotlin
class DocumentViewerActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val path = intent.getStringExtra("docPath") ?: return
        // 앱 내부 저장소(filesDir) 아래의 파일을 읽어 그대로 화면에 표시
        textView.text = File(filesDir, path).readText()
    }
}
```', 'OBJECTIVE'),
       (5186, 834, '아래 코드에서 업로드가 시작되지 않는 이유로 옳은 것은?', '사진 백업 앱에서 [업로드] 버튼을 눌러도 아무 일이 일어나지 않는다. TRACE 로그에 UploadService.onCreate는 찍히지 않고, 버튼을 누르는 순간 cacheDir을 읽는 줄에서 NullPointerException이 발생한다. 매니페스트에는 `<service android:name=".UploadService" />`가 선언돼 있다.

```kotlin
class UploadService : Service() {
    override fun onCreate() {
        super.onCreate()
        Log.d("TRACE", "UploadService.onCreate")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        uploadAll(cacheDir)   // 캐시 폴더에 쌓인 사진을 서버로 올린다
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
```

```kotlin
// MainActivity
uploadButton.setOnClickListener {
    val service = UploadService()
    service.onStartCommand(Intent(), 0, 1)
}
```', 'OBJECTIVE'),
       (5187, 834, '아래 상황에서 우리 앱의 요청을 받아 준 사진 앱 쪽 컴포넌트의 이름은?', '사진첩 정리 앱을 만들면서 기기에 저장된 사진 목록을 읽어야 했다. 처음에는 사진 앱이 쓰는 SQLite 파일의 경로를 알아내 직접 열어 보려 했지만 권한 오류로 막혔다. 대신 `content://media/external/images/media` 주소로 조회를 요청하자 사진 정보가 줄줄이 담긴 커서가 돌아왔고, 같은 주소로 새 사진을 추가하거나 지울 수도 있었다. 사진 앱에서 파일을 따로 내려받거나 복사해 오는 절차는 한 번도 거치지 않았다.', 'SUBJECTIVE'),
       (5188, 834, '아래 증상의 원인이 된, 매니페스트의 액티비티 선언에 빠져 있던 요소의 이름은?', '사진 편집 앱을 내놨는데, 갤러리에서 사진을 고르고 [공유]를 눌렀을 때 뜨는 앱 목록에 우리 앱만 보이지 않는다는 문의가 이어졌다. 매니페스트에는 `<activity android:name=".ShareActivity" android:exported="true" />`로 선언돼 있고, 우리 앱 안에서 클래스를 직접 지정해 같은 화면을 띄우면 사진을 받아 편집하는 동작까지 정상이다. 같은 선언 안에 블록 하나를 넣고 다시 설치하자, 그때부터 공유 목록에 우리 앱이 나타났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5183
(13995, 5183, '내비게이션처럼 화면을 끈 채 오래 돌아야 하는 작업은 사용자가 실행 사실을 볼 수 있는 형태로 시작해야 한다.', '표의 포그라운드 서비스 행에서 따라 나온다. 알림 표시가 조건으로 붙은 이유가 사용자 모르게 오래 도는 작업을 막기 위해서이므로, 화면이 꺼진 동안 이어져야 하는 작업은 이 형태로 돌려야 한다.', false),
(13996, 5183, 'bindService()로만 시작한 서비스는 연결한 화면이 모두 끊어져도 stopService()를 부르기 전까지 계속 살아 있다.', '표의 종료 시점 행에 정면으로 걸린다. 바인드로만 시작한 서비스는 마지막 클라이언트가 unbindService()를 부르는 순간 시스템이 정리한다. stopService()로 멈추는 쪽은 startService()로 시작한 서비스다.', true),
(13997, 5183, '음악 재생 화면에서 서비스가 가진 메서드를 직접 불러 구간을 건너뛰려면 연결을 맺는 방식으로 시작해야 한다.', '표의 바인드 서비스 행에서 따라 나온다. 연결을 맺으면 서비스가 돌려준 인터페이스로 메서드를 직접 부를 수 있지만, 시작만 하는 방식은 인텐트를 던질 뿐 반환값을 받을 통로가 없다.', false),
(13998, 5183, 'startService()로 시작한 서비스에 화면이 나중에 연결했다면, 그 화면이 연결을 끊어도 stopSelf() 전까지는 멈추지 않는다.', '한 서비스가 시작과 연결이라는 두 조건을 함께 가질 수 있다. 표의 두 행을 겹쳐 보면 시작으로 생긴 수명은 연결을 끊는 것만으로 끝나지 않고, 스스로 멈추거나 중지 요청을 받아야 정리된다.', false),

-- 문제 5184
(13999, 5184, '메시지를 받은 자리에서 화면을 덮는 대화상자를 직접 그려 사용자에게 곧바로 알릴 수 있다.', '이 컴포넌트에는 화면이 없다. 사용자에게 바로 알리려면 알림을 띄우거나 액티비티를 시작해야 하며, 콜백 안에서 UI를 직접 그릴 수는 없다.', false),
(14000, 5184, 'Android 8.0 이상에서도 매니페스트에 적어 두기만 하면 시스템이 뿌리는 대부분의 메시지를 앱 상태와 무관하게 받는다.', 'Android 8.0 이전 동작에 머문 오해다. 지금은 대부분의 암시적 브로드캐스트가 매니페스트로 선언한 쪽에 전달되지 않아, 화면이 살아 있는 동안 코드로 등록하거나 WorkManager 같은 대안을 써야 한다.', false),
(14001, 5184, '한 번 등록하면 앱을 지우기 전까지 해제할 수 없어, 더 받을 필요가 없어진 뒤에도 호출이 계속된다.', '코드로 등록한 쪽은 registerReceiver()와 짝을 이루는 unregisterReceiver()로 언제든 뗄 수 있다. 오히려 떼지 않은 채 화면이 사라지면 등록이 남아 누수 경고가 뜬다.', false),
(14002, 5184, '콜백이 앱의 메인 스레드에서 호출되므로, 네트워크 동기화처럼 긴 작업을 그 안에서 끝내려 하면 ANR로 이어진다.', '이름 때문에 백그라운드 스레드에서 돈다고 오해하기 쉽지만 콜백은 메인 스레드에서 실행된다. 받은 자리에서는 짧게 끝내고 긴 작업은 코루틴이나 WorkManager로 넘겨야 입력 처리가 밀리지 않는다.', true),

-- 문제 5185
(14003, 5185, '엑스트라로 받은 경로를 검사하지 않아, 다른 앱이 ../를 섞은 값을 보내면 공개할 뜻이 없던 내부 파일까지 읽어 보여 준다.', 'exported가 true라 이 인텐트는 임의의 앱이 보낼 수 있고, 엑스트라는 보내는 쪽이 마음대로 채우는 값이다. 검증 없이 경로로 쓰면 상위 경로를 타고 토큰이나 설정 파일까지 읽히므로 허용 목록과 대조해 걸러야 한다.', true),
(14004, 5185, 'exported를 false로 내리면 사내 다른 앱과의 연동은 그대로 두면서 위험만 없앨 수 있는데 값을 잘못 고른 것이다.', 'exported를 false로 내리면 다른 앱이 이 화면을 여는 길 자체가 막혀 연동도 함께 끊긴다. 열어 둔 채로 안전하게 만들려면 받은 값을 검증하거나 서명 권한을 걸어 호출자를 제한해야 한다.', false),
(14005, 5185, '다른 앱이 이 화면을 시작하면 그 앱의 프로세스에서 코드가 실행돼, 읽어 들인 문서 내용이 남의 앱 메모리에 남는다.', '액티비티는 그것을 선언한 앱의 프로세스에서 실행된다. 다른 앱은 인텐트를 보내 화면을 띄울 뿐 이쪽 코드나 메모리에 들어오지 못하므로, 문제의 자리는 프로세스가 아니라 검증 없이 쓴 엑스트라 값이다.', false),
(14006, 5185, '엑스트라는 Bundle에 담겨 시스템을 거치며 값이 검사되므로, 위험한 쪽은 액션 이름을 회사 고유 문자열로 정한 것이다.', '시스템은 Bundle을 전달할 뿐 그 값이 안전한지는 보지 않는다. 고유한 액션 이름은 다른 앱과의 충돌을 줄이려는 권장 방식일 뿐이고, 이름을 감춘다고 해서 같은 인텐트를 못 보내는 것도 아니다.', false),

-- 문제 5186
(14007, 5186, '매니페스트의 service 선언에 android:exported 값을 적지 않아 시스템이 이 서비스를 만들지 못했다.', 'exported는 다른 앱이 이 컴포넌트를 시작할 수 있는지를 정하는 값이고, 인텐트 필터가 없으면 생략해도 된다. 같은 앱 안에서 쓰는 서비스는 이 값과 무관하게 시작된다.', false),
(14008, 5186, 'onBind()가 null을 돌려주어 연결이 맺어지지 않았고, 연결이 없으면 onStartCommand()도 실행되지 않는다.', 'onBind()가 null이면 바인드를 지원하지 않는다는 뜻일 뿐이다. 시작하는 방식으로 쓰는 서비스는 연결 없이도 onStartCommand()가 호출되므로 바인드 여부는 원인이 될 수 없다.', false),
(14009, 5186, '컴포넌트는 시스템이 만들어 컨텍스트를 붙여 주는데, 코드에서 직접 생성한 객체에는 그 과정이 없어 cacheDir이 빈 참조다.', 'onCreate 로그가 찍히지 않은 것이 단서다. 직접 만든 객체는 생명주기 콜백도, 컨텍스트 연결도 받지 못한 껍데기라 파일 경로를 묻는 순간 터진다. startService()로 인텐트를 보내 시스템이 만들게 해야 한다.', true),
(14010, 5186, '클릭 리스너가 워커 스레드에서 실행되는데 서비스 콜백은 메인 스레드에서만 호출될 수 있어 생성이 막혔다.', '버튼 클릭 리스너는 메인 스레드에서 실행되므로 전제부터 어긋난다. 게다가 시스템이 서비스를 만들 때는 요청한 스레드와 무관하게 메인 스레드에서 콜백을 부르므로 스레드는 원인이 아니다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1684, 5187, '콘텐츠 프로바이더,콘텐츠프로바이더,컨텐츠 프로바이더,컨텐츠프로바이더,content provider,contentprovider', '앱이 자기 데이터를 파일로만 쥐고 있으면 다른 앱은 권한에 막혀 손댈 수 없다. 콘텐츠 프로바이더는 그 사이에 표준 창구를 놓아, 부르는 쪽이 저장 방식을 몰라도 URI 하나로 조회·추가·수정·삭제를 하게 해 준다. 본문에서 파일 직접 열기는 권한 오류로 막혔는데 content:// 주소로는 커서가 돌아온 것이 그 창구를 거쳤다는 신호다. 화면이 필요한 일은 액티비티, 화면 없이 오래 도는 일은 서비스가 맡고, 다른 앱에 데이터를 열어 주는 역할만 이 컴포넌트가 맡는다는 선으로 구분하면 된다. 네 컴포넌트 중 유일하게 앱 프로세스가 뜰 때 Application.onCreate()보다 먼저 초기화된다는 점도 함께 기억해 두면 좋다.'),
       (1685, 5188, '인텐트 필터,인텐트필터,intent filter,intentfilter,intent-filter,<intent-filter>', '암시적 인텐트는 대상 클래스가 없으므로, 시스템이 액션·데이터(URI와 MIME 타입)·카테고리 세 가지를 매니페스트에 적힌 인텐트 필터와 대조해 처리할 후보를 찾는다. 필터를 달지 않은 액티비티는 이 대조에 아예 오르지 못해 공유 목록 같은 후보 명단에서 빠진다. exported="true"는 다른 앱이 시작해도 된다는 허가일 뿐, 어떤 요청을 처리할 수 있는지 알리는 선언이 아니라는 점에서 구분해야 한다. 본문처럼 앱 안에서 클래스를 직접 지정하는 명시적 인텐트는 대조 과정을 건너뛰므로 필터가 없어도 잘 열린다. 공유를 받으려면 ACTION_SEND 액션, image/* 같은 MIME 타입, DEFAULT 카테고리를 함께 적어야 한다.');
