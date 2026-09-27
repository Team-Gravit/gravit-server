-- Unit: 액티비티와 프래그먼트 생명주기 (Unit ID: 93)
-- Chapter: AOS (Chapter ID: 8)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (519, 93, '전환 콜백 순서와 onPause 작업 비용'),
       (677, 93, '화면 복귀 콜백과 프래그먼트 뷰 수명'),
       (835, 93, '프래그먼트 트랜잭션과 상태 저장 시점');

-- =====================================================
-- Lesson 519: 전환 콜백 순서와 onPause 작업 비용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3293, 519, '위 로그에서 ⓐ 자리에 기록된 줄로 옳은 것은?', '아래는 사용자가 목록 화면에서 상세 화면으로 이동할 때 남은 로그다.

```
09:41:02.104  MainActivity: onPause
09:41:02.131  DetailActivity: onCreate
09:41:02.140  DetailActivity: onStart
09:41:02.166  DetailActivity: onResume
09:41:02.181  ⓐ
```', 'OBJECTIVE'),
       (3294, 519, '위 상황에서 반투명 창이 떠 있는 3초 동안 MainActivity의 상태로 옳은 것은?', 'MainActivity는 목록을 보여 주며, onStart에서 위치 센서를 켜고 onStop에서 끈다. 또 onResume에서 목록 애니메이션을 재개하고 onPause에서 멈춘다.

항목을 길게 누르면 별도의 액티비티가 반투명 창 형태로 뜨도록 만들었다. 이 창은 화면 가운데만 덮고 뒤쪽 목록은 계속 보인다. 사용자가 항목을 길게 눌러 창을 띄운 뒤 3초 동안 그대로 두었다.', 'OBJECTIVE'),
       (3295, 519, '아래 코드에서 작성 중이던 초안이 사라진 이유로 옳은 것은?', '베타 테스트에서 앱을 띄워 둔 채 다른 앱을 오래 쓰다가 돌아온 사용자들이 쓰던 글이 사라졌다고 제보했다.

```kotlin
class DraftActivity : AppCompatActivity() {
    override fun onDestroy() {
        super.onDestroy()
        draftRepository.save(editor.text.toString())
    }
}
```', 'OBJECTIVE'),
       (3296, 519, '위 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '아래는 한 화면 안에서 액티비티와 그 안에 붙은 프래그먼트 중 어느 쪽이 먼저 진행되는지 정리한 표다.

| 시점 | 액티비티 콜백 | 같은 시점의 프래그먼트 콜백 | 먼저 진행되는 쪽 |
|---|---|---|---|
| 화면 생성 | onCreate | onAttach → onCreate → onCreateView → onViewCreated | 액티비티 |
| 화면 표시 | onStart | onStart | 액티비티 |
| 포커스 상실 | onPause | onPause | 프래그먼트 |
| 화면 파괴 | onDestroy | onDestroyView → onDestroy → onDetach | 프래그먼트 |', 'OBJECTIVE'),
       (3297, 519, '위에서 뷰 참조 필드를 null로 비우는 코드를 넣어야 할 프래그먼트 콜백의 이름은?', '탭 화면에서 프래그먼트 A와 B를 replace로 번갈아 붙이면서 addToBackStack으로 쌓았다. 두 탭을 20번 오간 뒤 메모리 프로파일러를 보니 회수되지 않은 View 객체가 20세트 남아 있었다.

힙 덤프를 열어 보니 살아 있는 프래그먼트 인스턴스의 필드 하나가 이미 화면에서 떨어져 나간 뷰 트리를 계속 붙잡고 있었다. 이 필드를 null로 비우는 코드를 한 콜백에 넣자 누수가 사라졌다.', 'SUBJECTIVE'),
       (3298, 519, '위에서 무거운 작업이 원래 들어 있던 액티비티 콜백의 이름은?', '목록 화면에서 상세 화면을 여는 데 평균 380ms가 걸린다는 제보를 받았다.

시스템 트레이스를 보니 상세 화면의 onResume이 시작되기 전 구간에서 목록 화면 쪽 코드가 320ms 동안 DB 저장과 서버 전송을 하고 있었고, 이 구간이 끝나야 상세 화면 코드가 이어졌다. 같은 작업을 목록 화면의 onStop으로 옮기자 전환 시간이 평균 60ms로 줄었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3293
(8955, 3293, 'MainActivity: onRestart', 'onRestart는 onStop을 거친 액티비티가 다시 보이기 직전에만 호출된다. MainActivity는 아직 정지 단계에 들어가지도 않았으므로 이 자리에 올 수 없다.', false),
(8956, 3293, 'MainActivity: onStop', 'DetailActivity가 onResume으로 화면을 완전히 덮은 뒤에야 MainActivity가 정지한다. 그래서 이전 화면의 onStop은 새 화면의 onResume 다음에 찍히고, 그 사이 MainActivity는 onPause 상태로 살아 있다.', true),
(8957, 3293, 'MainActivity: onDestroy', '다른 화면으로 이동해도 이전 액티비티는 백 스택에 남아 정지 상태가 된다. onDestroy는 finish 호출이나 시스템 회수 때 일어나며 단순 전환으로는 호출되지 않는다.', false),
(8958, 3293, 'DetailActivity: onRestart', 'onResume 다음 순서가 onRestart라고 잘못 외운 경우다. onRestart는 정지됐던 액티비티가 다시 보일 때만 거치는 콜백이라 최초 생성 경로에는 나오지 않는다.', false),

-- 문제 3294
(8959, 3294, '위치 센서는 계속 켜져 있고 목록 애니메이션만 멈춘다.', '뒤쪽 목록이 계속 보이므로 MainActivity는 포커스만 잃어 onPause까지만 진행되고 onStop은 호출되지 않는다. 그래서 onPause에 걸어 둔 애니메이션만 멈추고 onStop에 걸어 둔 센서는 그대로 돌아간다.', true),
(8960, 3294, '위치 센서와 목록 애니메이션이 모두 멈춘다.', '다른 액티비티가 뜨면 언제나 onStop까지 내려간다고 본 오개념이다. 화면이 부분적으로라도 보이면 가시 수명이 유지돼 onStop은 호출되지 않는다.', false),
(8961, 3294, '위치 센서만 꺼지고 목록 애니메이션은 계속 돈다.', 'onStop이 onPause보다 먼저 온다고 순서를 뒤집어 본 오개념이다. 내려가는 경로는 onPause 다음이 onStop이며, 이 상황에서는 onStop 자체가 호출되지 않는다.', false),
(8962, 3294, '위치 센서와 목록 애니메이션이 모두 그대로 동작한다.', '화면이 보이기만 하면 아무 콜백도 호출되지 않는다고 본 오개념이다. 포커스를 잃는 순간 onPause는 호출되므로 애니메이션은 멈춘다.', false),

-- 문제 3295
(8963, 3295, '다른 앱으로 나갈 때마다 이 콜백이 호출돼 나중 호출이 빈 값으로 초안을 덮어쓴다.', '화면이 가려질 때 호출되는 것은 onStop이다. onDestroy는 액티비티가 실제로 파괴될 때만 실행되며 홈 버튼으로 나갈 때마다 호출되지는 않는다.', false),
(8964, 3295, '구성 변경으로 재생성될 때만 이 콜백이 호출되므로 회전하지 않으면 저장이 일어나지 않는다.', '회전은 onDestroy가 호출되는 여러 경우 중 하나일 뿐이다. finish 호출이나 시스템 회수로도 호출되므로 회전 전용 콜백이라는 설명은 성립하지 않는다.', false),
(8965, 3295, 'editor의 뷰 내용이 onStop에서 비워지므로 저장되는 값이 언제나 빈 문자열이다.', 'onStop은 뷰의 내용을 지우지 않는다. 뷰 계층은 액티비티가 파괴되기 전까지 유지되므로 값이 비워진다는 전제 자체가 어긋난다.', false),
(8966, 3295, '시스템이 백그라운드 프로세스를 통째로 종료하면 이 콜백이 실행되지 않아 저장이 아예 일어나지 않는다.', 'onDestroy는 호출이 보장되지 않는 콜백이다. 메모리가 부족해 프로세스가 회수되면 그대로 사라지므로, 꼭 남겨야 할 데이터는 onStop 이전에 저장하고 화면 상태는 onSaveInstanceState로 대비한다.', true),

-- 문제 3296
(8967, 3296, '액티비티의 onCreate가 진행되는 도중에 프래그먼트의 뷰가 만들어질 수 있다.', '화면 생성 행에서 액티비티가 먼저 진행되고 그 안에서 프래그먼트의 onCreateView까지 이어진다. 그래서 액티비티 onCreate가 끝나기 전에 프래그먼트 뷰가 완성될 수 있다.', false),
(8968, 3296, '프래그먼트의 onStart 시점에는 호스트 액티비티가 이미 보이기 시작한 상태다.', '화면 표시 행에서 액티비티가 먼저 진행된다. 따라서 프래그먼트 onStart에서 호스트의 뷰 계층을 참조해도 아직 준비되지 않은 상태를 만날 일이 없다.', false),
(8969, 3296, '호스트 액티비티의 onPause가 끝난 뒤에야 그 안의 프래그먼트가 onPause를 받는다.', '포커스 상실 행은 프래그먼트가 먼저 진행된다고 적고 있다. 내려가는 방향에서는 프래그먼트가 먼저 상태를 바꾸므로 호스트가 먼저라는 이 설명은 거짓이다.', true),
(8970, 3296, '프래그먼트가 등록한 리스너를 호스트의 onDestroy에서 해제하면 해제 시점이 늦다.', '화면 파괴 행에서 프래그먼트가 먼저 onDetach까지 끝낸다. 호스트 onDestroy에 해제 코드를 두면 이미 연결이 끊긴 뒤라 정리 시점을 놓친다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1054, 3297, 'onDestroyView,onDestroyView(),Fragment.onDestroyView', '백 스택에 들어간 프래그먼트는 뷰만 파괴되고 인스턴스는 살아남는다. 그래서 뷰 참조를 인스턴스 필드에 그대로 두면 파괴된 뷰 트리 전체가 붙잡혀 남고, 왕복할 때마다 한 세트씩 쌓인다. 뷰가 사라지는 시점인 onDestroyView에서 필드를 null로 비워야 하는 이유다. onDestroy는 인스턴스가 실제로 파괴될 때만 호출돼 백 스택 왕복에서는 실행되지 않으므로 여기에 정리 코드를 두면 누수가 그대로 남는다. onDetach는 액티비티와의 연결이 끊길 때라 더 늦다.'),
       (1055, 3298, 'onPause,onPause(),Activity.onPause', '다음 액티비티의 onResume은 이전 액티비티의 onPause가 끝나야 시작된다. 그래서 onPause에 DB 저장이나 네트워크 호출을 넣으면 그 시간만큼 화면 전환이 그대로 밀린다. 트레이스에서 320ms가 상세 화면 onResume 앞을 막고 있던 이유가 이것이다. onStop은 화면이 완전히 가려진 뒤라 전환 속도에 영향을 주지 않아 무거운 정리에 알맞다. onPause에는 센서 해제처럼 짧은 작업만 두고 가볍게 유지한다.');

-- =====================================================
-- Lesson 677: 화면 복귀 콜백과 프래그먼트 뷰 수명
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4241, 677, '위 상황에서 뒤로 가기를 누른 직후 프로필 화면에 표시되는 내용으로 옳은 것은?', '프로필 화면(ProfileActivity)에서 편집 화면(EditActivity)을 열고, 닉네임을 gravit에서 melon으로, 소개를 hello에서 bye로 고친 뒤 뒤로 가기를 눌렀다.

두 화면은 같은 SharedPreferences 객체 prefs를 쓰며, 편집 전 prefs에는 닉네임 gravit, 소개 hello가 저장돼 있었다. commit()은 호출 즉시 값을 반영하고, 프로필 화면은 onResume에서만 표시 값을 갱신한다.

```kotlin
class EditActivity : AppCompatActivity() {
    override fun onPause() {
        super.onPause()
        prefs.edit().putString("nickname", nicknameInput.text.toString()).commit()
    }

    override fun onStop() {
        super.onStop()
        prefs.edit().putString("bio", bioInput.text.toString()).commit()
    }
}

class ProfileActivity : AppCompatActivity() {
    override fun onResume() {
        super.onResume()
        nicknameView.text = prefs.getString("nickname", "")
        bioView.text = prefs.getString("bio", "")
    }
}
```', 'OBJECTIVE'),
       (4242, 677, '위 순서를 모두 마친 시점에 남아 있는 위치 리스너 등록 건수는?', '지도 화면(MapActivity)은 위치 리스너를 아래 표처럼 등록·해제한다. addListener는 호출될 때마다 등록을 1건 추가하고, removeListener는 호출될 때마다 1건을 제거한다. 다른 곳에서는 두 메서드를 호출하지 않는다.

| 콜백 | 호출하는 코드 |
|---|---|
| onResume | locationClient.addListener(listener) |
| onStop | locationClient.removeListener(listener) |

사용자는 아래 순서로 앱을 사용했고, 도중에 프로세스는 종료되지 않았다.

1. 앱을 실행해 지도 화면이 뜬다.
2. 화면 가운데만 덮는 다이얼로그 테마 액티비티(필터 창)를 열었다가 닫는다. 이를 2번 반복한다.
3. 전체 화면을 덮는 설정 화면(SettingsActivity)을 열었다가 뒤로 가기로 지도 화면에 돌아온다.', 'OBJECTIVE'),
       (4243, 677, '위 상황에서 ListFragment에 대한 설명으로 옳은 것은?', '목록 프래그먼트(ListFragment)는 onCreate에서 서버에 목록을 요청해 받은 결과를 필드 items에 담고, onViewCreated에서 items로 목록 어댑터를 만든다. 서버에 목록을 요청하는 코드는 onCreate에만 있다.

항목을 누르면 FragmentTransaction으로 상세 프래그먼트(DetailFragment)를 replace하고, 같은 트랜잭션에서 addToBackStack도 호출한다. 사용자는 항목 하나를 눌러 상세 화면을 연 뒤 뒤로 가기로 목록 화면에 돌아왔다. 도중에 구성 변경이나 프로세스 종료는 없었다.', 'OBJECTIVE'),
       (4244, 677, '위 코드가 IllegalStateException으로 종료된 원인으로 옳은 것은?', '피드 화면의 FeedFragment를 처음 띄우는 순간 앱이 IllegalStateException으로 종료됐다. requireContext()와 requireView()는 각각 돌려줄 대상이 아직 없으면 IllegalStateException을 던진다.

```kotlin
class FeedFragment : Fragment(R.layout.fragment_feed) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val adapter = FeedAdapter(requireContext())
        requireView().findViewById<RecyclerView>(R.id.feed_list).adapter = adapter
    }
}
```', 'OBJECTIVE'),
       (4245, 677, '위 문제를 없애려고 코드의 this 자리에 넣은 프래그먼트 속성의 이름은?', '장바구니 화면의 CartFragment는 담긴 상품 수가 바뀔 때마다 토스트를 띄운다.

```kotlin
class CartFragment : Fragment(R.layout.fragment_cart) {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel.count.observe(this) { n ->
            Toast.makeText(requireContext(), "상품 ${n}개", Toast.LENGTH_SHORT).show()
        }
    }
}
```

상품 상세 프래그먼트로 replace하면서 addToBackStack을 호출했다가 뒤로 가기로 장바구니 화면에 돌아오는 동작을 3번 반복했다. 그 뒤 장바구니 화면에서 상품을 하나 더 담자 같은 토스트가 한꺼번에 4번 떴다.

코드의 this를 프래그먼트가 가진 다른 속성 하나로 바꾸자, 같은 동작을 거친 뒤 상품을 담아도 토스트가 1번만 떴다.', 'SUBJECTIVE'),
       (4246, 677, '위 표의 결과를 낸 로그 코드가 들어 있는 액티비티 콜백의 이름은?', '뉴스 화면(NewsActivity)의 생명주기 콜백 한 곳에만 refresh 로그를 찍는 코드를 넣고, 아래 순서로 앱을 사용하며 동작마다 찍힌 refresh 로그 수를 셌다. 도중에 프로세스는 종료되지 않았다.

| 순서 | 동작 | refresh 로그 |
|---|---|---|
| 1 | 앱을 처음 실행해 뉴스 화면이 뜬다 | 0번 |
| 2 | 홈 버튼을 눌러 앱을 나간다 | 0번 |
| 3 | 앱 아이콘을 눌러 뉴스 화면으로 돌아온다 | 1번 |
| 4 | 전체 화면을 덮는 설정 화면을 연다 | 0번 |
| 5 | 설정 화면에서 뒤로 가기로 뉴스 화면에 돌아온다 | 1번 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4241
(11483, 4241, '닉네임은 gravit, 소개는 hello로 표시된다.', '뒤로 가기를 누르면 돌아갈 화면이 먼저 복귀한다고 본 오개념이다. 편집 화면의 onPause가 끝나야 프로필 화면의 onRestart → onStart → onResume이 이어지므로, onResume이 읽을 때 닉네임은 이미 melon이다.', false),
(11484, 4241, '닉네임은 melon, 소개는 hello로 표시된다.', '뒤로 가기 순서는 편집 onPause → 프로필 onRestart → onStart → onResume → 편집 onStop → onDestroy다. 프로필 onResume이 읽는 시점에 onPause의 닉네임 저장은 끝났지만 onStop의 소개 저장은 아직이다.', true),
(11485, 4241, '닉네임은 melon, 소개는 bye로 표시된다.', '떠나는 화면이 onStop까지 마친 뒤 이전 화면이 복귀한다고 본 오개념이다. 편집 화면의 onStop은 프로필 화면의 onResume 다음에 호출되므로, 소개를 읽는 시점에는 bye가 아직 저장되지 않았다.', false),
(11486, 4241, '닉네임은 gravit, 소개는 bye로 표시된다.', 'onStop이 onPause보다 먼저 온다고 순서를 뒤집어 본 경우다. 떠나는 화면은 항상 onPause를 거친 뒤 onStop에 이르므로 닉네임이 소개보다 먼저 저장되고, 소개만 새 값인 상태는 나올 수 없다.', false),

-- 문제 4242
(11487, 4242, '0건', '돌아올 때 onResume이 다시 호출되지 않는다고 본 경우다. onResume은 포커스를 되찾을 때마다 호출되므로 필터 창을 닫을 때와 설정 화면에서 돌아올 때 모두 등록이 1건씩 추가된다.', false),
(11488, 4242, '1건', '다이얼로그 테마 창이 떠도 onStop까지 내려간다고 본 경우다. 뒤쪽 지도가 여전히 보이므로 onPause까지만 호출되고 onStop은 호출되지 않아, 창을 닫을 때마다 제거 없이 등록만 1건씩 늘어난다.', false),
(11489, 4242, '3건', '실행 때 1건, 필터 창은 onPause만 일으켜 닫을 때마다 onResume으로 1건씩 늘어 3건이다. 설정 화면이 지도를 완전히 가리면 onStop으로 1건 줄고 돌아오며 1건 늘어 3건이 남는다. 등록·해제 콜백이 짝이 아니라 쌓인다.', true),
(11490, 4242, '4건', '전체 화면을 덮는 설정 화면이 떠도 onStop이 호출되지 않는다고 본 경우다. 설정 화면이 onResume까지 마치면 지도 화면은 완전히 가려져 onStop이 호출되므로 이때 1건이 제거된다.', false),

-- 문제 4243
(11491, 4243, '상세 화면이 떠 있는 동안에는 onStop이 호출되지 않아 시작(STARTED) 상태에 머문다.', '백 스택에 들어간 프래그먼트가 상세 화면에 가려지기만 한다고 본 오개념이다. replace로 컨테이너에서 빠진 프래그먼트는 onPause → onStop → onDestroyView까지 진행되므로, onStop은 이미 호출됐고 CREATED 상태로 내려가 있다.', false),
(11492, 4243, '상세 화면이 떠 있는 동안 onDestroy와 onDetach까지 호출돼 호스트 액티비티와의 연결이 끊긴다.', 'replace가 기존 프래그먼트를 언제나 완전히 파괴한다고 본 오개념이다. 같은 트랜잭션에서 addToBackStack을 호출하면 인스턴스가 백 스택에 보관돼 onDestroyView까지만 진행되고, onDestroy·onDetach는 호출되지 않는다.', false),
(11493, 4243, '뒤로 가기로 돌아오면 보관돼 있던 이전 목록 뷰가 다시 붙어 onViewCreated는 호출되지 않는다.', '뷰도 인스턴스처럼 보관된다고 본 오개념이다. 뷰는 onDestroyView에서 이미 파괴됐으므로, 돌아올 때 onCreateView에서 레이아웃을 새로 인플레이트하고 onViewCreated도 다시 호출돼 어댑터가 새로 만들어진다.', false),
(11494, 4243, '뒤로 가기로 돌아와도 서버에 목록을 다시 요청하지 않으며, 처음 받아 담은 items 값이 그대로 남아 있다.', '백 스택의 프래그먼트는 onDestroyView까지만 진행돼 인스턴스가 살아 있고, 돌아올 때는 onCreateView부터 이어져 onCreate가 다시 실행되지 않는다. 그래서 목록 요청은 다시 나가지 않고 items 필드도 그대로다. 뷰 수명과 프래그먼트 수명이 분리된 결과다.', true),

-- 문제 4244
(11495, 4244, 'onCreate는 레이아웃을 인플레이트하는 onCreateView보다 먼저 호출돼, 이 시점엔 requireView()가 돌려줄 뷰가 없다.', '프래그먼트는 onAttach → onCreate → onCreateView → onViewCreated 순으로 진행된다. onCreate는 뷰 없이 프래그먼트 자체를 초기화하는 단계라, 뷰를 찾는 코드는 뷰가 만들어진 뒤인 onViewCreated로 옮겨야 한다.', true),
(11496, 4244, 'onCreate는 호스트 액티비티에 연결되기 전에 호출돼, 이 시점엔 requireContext()가 돌려줄 context가 없다.', 'onCreate가 액티비티 연결보다 먼저라고 본 오개념이다. onAttach에서 액티비티에 연결된 뒤에 onCreate가 호출되므로 requireContext()는 여기서 정상 동작하고, 예외는 다음 줄 requireView()에서 난다.', false),
(11497, 4244, '생성자에 레이아웃 ID만 넘기고 onCreateView를 직접 구현하지 않아, 뷰가 끝내 만들어지지 않는다.', '생성자로 레이아웃 ID를 넘기면 기본 onCreateView가 그 레이아웃을 인플레이트해 뷰를 돌려준다. 직접 구현하지 않아도 뷰는 만들어지며, 문제는 뷰를 찾는 시점이 그보다 이르다는 데 있다.', false),
(11498, 4244, 'requireView()는 호스트 액티비티의 뷰를 돌려주는데, 액티비티의 뷰 구성이 끝나기 전이라 뷰가 없다.', 'requireView()가 액티비티 화면을 가리킨다고 본 오개념이다. 이 메서드는 프래그먼트가 onCreateView에서 돌려준 자기 뷰를 반환하므로, 액티비티의 준비 상태와는 상관이 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1370, 4245, 'viewLifecycleOwner,getViewLifecycleOwner(),getViewLifecycleOwner,this.viewLifecycleOwner,뷰 라이프사이클 오너,뷰라이프사이클오너,뷰 생명주기 소유자', '백 스택에 들어간 프래그먼트는 onDestroyView까지만 진행되고 인스턴스는 살아 있다가, 돌아오면 onCreateView·onViewCreated부터 다시 실행된다. observe에 this(프래그먼트 자신)를 넘기면 옵저버는 프래그먼트가 onDestroy될 때에야 해제되므로 왕복할 때마다 옵저버가 하나씩 쌓인다. 처음 1개에 3번 왕복분이 더해져 4개가 되고, 값이 한 번 바뀌자 토스트가 4번 뜬 것이다. viewLifecycleOwner는 프래그먼트가 아니라 뷰의 수명을 따르는 LifecycleOwner라 onDestroyView 시점에 옵저버가 자동으로 해제되고, 돌아오면 새 옵저버 1개만 남는다. 프래그먼트 자신(this)이나 호스트 액티비티를 넘기면 뷰보다 오래 살아 같은 누적이 생긴다는 점과 구분한다.'),
       (1371, 4246, 'onRestart,onRestart(),Activity.onRestart,Activity.onRestart(),온리스타트', 'onRestart는 onStop으로 완전히 가려졌던 액티비티가 다시 보이기 직전, onStart 바로 앞에서만 호출된다. 처음 실행할 때는 onCreate → onStart → onResume으로 진행해 onRestart를 거치지 않고(1행), 홈으로 나가거나 설정 화면에 덮일 때는 onPause → onStop만 호출된다(2·4행). 돌아올 때 비로소 onRestart → onStart → onResume이 이어져 3·5행에서만 로그가 찍힌다. onStart·onResume도 돌아올 때마다 호출되지만 처음 실행 때도 호출되므로 1행이 0번일 수 없고, onStop은 나갈 때 호출되므로 2·4행에서 찍혔어야 한다.');

-- =====================================================
-- Lesson 835: 프래그먼트 트랜잭션과 상태 저장 시점
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5189, 835, '위와 같이 트랜잭션을 고친 뒤 목록 프래그먼트에 일어나는 일로 옳은 것은?', '목록 화면(ListFragment)이 붙어 있는 컨테이너에 상세 화면(DetailFragment)을 띄우는 트랜잭션을 아래처럼 고쳤다. DetailFragment의 레이아웃에는 배경색이 지정돼 있지 않다.

```kotlin
// 고치기 전
supportFragmentManager.beginTransaction()
    .replace(R.id.container, DetailFragment())
    .addToBackStack(null)
    .commit()

// 고친 뒤
supportFragmentManager.beginTransaction()
    .add(R.id.container, DetailFragment())
    .addToBackStack(null)
    .commit()
```

고친 뒤로는 상세 화면 너머로 목록 글자가 비쳐 보였고, 그 자리를 누르자 목록 항목이 눌린 것처럼 반응했다. 그동안 호스트 액티비티는 포그라운드에 그대로 있었다.', 'OBJECTIVE'),
       (5190, 835, '위 두 기기의 로그를 바탕으로 판단할 때 옳은 것은?', '글쓰기 화면(WriteActivity)은 onStop에서 편집 세션을 닫아 입력 버퍼를 비우고, onSaveInstanceState에서 그 버퍼의 내용을 읽어 Bundle에 담는다.

같은 앱 빌드를 두 기기에 설치하고, 글을 쓰던 중 홈 버튼을 눌렀을 때 찍힌 로그다.

```
[기기 A · Android 8.1 (API 27)]
WriteActivity: onPause
WriteActivity: onSaveInstanceState
WriteActivity: onStop

[기기 B · Android 11 (API 30)]
WriteActivity: onPause
WriteActivity: onStop
WriteActivity: onSaveInstanceState
```', 'OBJECTIVE'),
       (5191, 835, '위 배치표와 사용 흐름을 바탕으로 판단할 때 옳지 않은 것은?', '음악 앱의 재생 화면(PlayerActivity)은 자원을 아래 표처럼 할당·해제한다. 표에 적힌 콜백 말고 다른 곳에서는 이 자원들을 건드리지 않는다.

| 자원 | 할당하는 콜백 | 해제하는 콜백 |
|---|---|---|
| 재생기(ExoPlayer) | onCreate | onDestroy |
| 위치 센서 | onStart | onStop |
| 화면 꺼짐 방지 플래그 | onResume | onPause |

사용자는 곡을 재생하던 중 홈 버튼을 눌러 다른 앱을 3분 동안 쓰다가 다시 이 앱으로 돌아왔다. 그동안 시스템이 이 앱의 프로세스를 종료하지는 않았다.', 'OBJECTIVE'),
       (5192, 835, '위 collect 호출을 repeatOnLifecycle(Lifecycle.State.STARTED) 블록으로 감쌌을 때, 같은 사용 흐름에서 로그가 달라지는 모습으로 옳은 것은?', '시세 화면(QuoteActivity)은 서버가 몇 초마다 보내는 시세 Flow를 구독해 화면에 그린다.

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    lifecycleScope.launch {
        quoteViewModel.quotes.collect { quote ->
            Log.d("Quote", "수신 ${quote.price}")
            priceView.text = quote.price
        }
    }
}
```

앱을 켜 둔 채 홈 버튼을 눌러 다른 앱을 쓰다가 5분 뒤 돌아왔을 때 찍힌 로그다.

```
10:02:11  Quote: 수신 61,400
10:02:14  Activity: onPause      <- 홈 버튼을 누름
10:02:14  Activity: onStop
10:02:15  Quote: 수신 61,450
10:05:30  Quote: 수신 61,900
10:07:20  Activity: onRestart    <- 앱으로 돌아옴
10:07:20  Activity: onStart
10:07:20  Activity: onResume
10:07:21  Quote: 수신 62,100
```', 'OBJECTIVE'),
       (5193, 835, '위에서 트랜잭션에 덧붙인 FragmentTransaction 메서드의 이름은?', '탭 화면(MainActivity)은 목록 프래그먼트를 컨테이너에 붙여 두고, 항목을 누르면 아래 트랜잭션으로 상세 프래그먼트를 띄운다.

```kotlin
supportFragmentManager.beginTransaction()
    .replace(R.id.container, DetailFragment())
    .commit()
```

상세 화면에서 뒤로 가기를 누르면 목록 화면으로 돌아가야 하는데, 앱이 그대로 종료됐다. 위 트랜잭션에 메서드 호출 한 줄을 덧붙이자 같은 동작에서 목록 화면으로 되돌아왔고, 돌아온 목록은 상세 화면을 열기 전 인스턴스가 그대로 쓰였다.', 'SUBJECTIVE'),
       (5194, 835, '위 코드의 ⓐ에 들어갈 프래그먼트 생명주기 콜백의 이름은?', '필터 프래그먼트(FilterFragment)는 선택 결과를 돌려줄 화면을 host 필드에 담아 둔다. MainActivity에 붙였을 때는 잘 동작했지만, 같은 프래그먼트를 SettingsActivity에 붙이자 화면이 뜨기도 전에 아래 예외로 종료됐다.

```kotlin
class FilterFragment : Fragment(R.layout.fragment_filter) {
    private var host: OnFilterChanged? = null

    override fun ⓐ(context: Context) {
        super.ⓐ(context)
        host = context as OnFilterChanged
    }
}
```

```
FATAL EXCEPTION: main
java.lang.ClassCastException: com.gravit.SettingsActivity cannot be cast to com.gravit.OnFilterChanged
    at com.gravit.FilterFragment.ⓐ(FilterFragment.kt:12)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5189
(14011, 5189, '목록 프래그먼트는 onDestroyView까지 진행돼 뷰가 파괴되고, 뒤로 가기로 돌아올 때 onCreateView부터 다시 실행된다.', 'replace로 붙일 때의 동작을 add에도 그대로 옮겨 붙인 오개념이다. add는 기존 프래그먼트를 컨테이너에서 떼지 않으므로 목록 뷰가 파괴되지 않고, 그 때문에 목록 글자가 상세 화면 너머로 비쳐 보인 것이다.', false),
(14012, 5189, '목록 프래그먼트는 onDestroyView를 거치지 않고 재개(RESUMED) 상태로 남아, 어댑터와 스크롤 위치를 그대로 유지한다.', 'add는 기존 프래그먼트를 컨테이너에 남긴 채 새 뷰를 그 위에 더한다. 프래그먼트 상태는 호스트를 따라가므로 액티비티가 포그라운드인 동안 목록도 재개 상태에 머물고, 뷰와 터치 처리가 살아 있어 겹침 증상이 생긴다.', true),
(14013, 5189, '목록 프래그먼트는 onPause와 onStop을 거쳐 정지 상태로 내려가, 화면 갱신 코드가 더 이상 실행되지 않는다.', '위에 다른 프래그먼트가 뜨면 아래 프래그먼트가 정지한다고 본 오개념이다. 프래그먼트의 상태는 호스트 액티비티를 따라가므로, 액티비티가 포그라운드에 있는 한 가려진 프래그먼트도 정지 단계로 내려가지 않는다.', false),
(14014, 5189, '목록 프래그먼트는 onDestroy와 onDetach까지 호출돼 사라지고, 뒤로 가기를 누르면 새 인스턴스가 만들어진다.', 'addToBackStack이 붙은 트랜잭션은 프래그먼트 인스턴스를 백 스택에 보관한다. replace였더라도 onDestroyView까지만 진행되며, add에서는 뷰조차 파괴되지 않으므로 인스턴스가 사라질 일이 없다.', false),

-- 문제 5190
(14015, 5190, '두 기기 모두 같은 내용이 Bundle에 담긴다. 상태를 저장하는 콜백은 기기와 상관없이 onPause 바로 뒤로 자리가 고정돼 있기 때문이다.', '저장 콜백의 자리가 언제나 고정이라고 본 오개념이다. 같은 빌드인데도 두 로그에서 onStop과의 앞뒤가 서로 뒤바뀌어 찍혔으니, 자리가 고정이라는 전제부터 로그와 어긋난다.', false),
(14016, 5190, '기기 A에서만 빈 내용이 담긴다. 기기 A는 저장 콜백이 onStop보다 앞서 호출돼 버퍼를 아직 읽을 수 없기 때문이다.', '앞뒤 관계를 거꾸로 본 경우다. 기기 A는 버퍼를 비우는 onStop 이전에 저장 콜백이 호출되므로 내용이 남아 있는 상태에서 읽는다. 값이 비는 쪽은 onStop을 먼저 지나는 기기 B다.', false),
(14017, 5190, '기기 B에서는 저장 콜백이 아예 호출되지 않아 아무것도 담기지 않는다. onStop을 지난 액티비티는 상태를 저장할 수 없기 때문이다.', '로그의 마지막 줄이 기기 B에서도 저장 콜백이 호출됐음을 보여 준다. 호출 자체는 일어나며, 다만 그 시점이 버퍼를 비운 뒤라서 읽히는 내용이 달라질 뿐이다.', false),
(14018, 5190, '기기 B에서만 빈 내용이 Bundle에 담겨, 앱으로 돌아왔을 때 기기 B에서만 쓰던 글이 되살아나지 않는다.', '기기 B는 onStop이 먼저라 버퍼가 비워진 뒤에 저장 콜백이 읽는다. 저장 시점은 기기 버전에 따라 onStop 앞뒤로 갈릴 수 있으므로, 저장 콜백이 읽을 자료를 onStop에서 건드리지 않도록 짜야 한다.', true),

-- 문제 5191
(14019, 5191, '홈 버튼으로 화면이 완전히 가려진 3분 동안에도 재생기는 해제되지 않아 소리가 계속 흘러나온다.', '홈 버튼으로 나가면 onPause와 onStop까지만 진행되고 onDestroy는 호출되지 않는다. 재생기 해제를 onDestroy에만 걸어 두었으니 그 3분 동안 재생이 그대로 이어진다 — 참인 진술이다.', false),
(14020, 5191, '위치 센서는 나갈 때 꺼졌다가 돌아올 때 다시 켜지므로, 화면이 보이는 동안에만 동작한다.', 'onStart와 onStop은 화면이 보이기 시작할 때와 완전히 가려질 때 짝으로 호출된다. 이 쌍에 걸어 둔 자원은 화면이 보이는 구간인 가시 수명에 맞춰 켜지고 꺼지므로 참인 진술이다.', false),
(14021, 5191, '홈 버튼으로 나갔다 돌아오기를 되풀이할 때마다 재생기가 새로 만들어져 인스턴스가 하나씩 쌓인다.', 'onCreate는 액티비티가 처음 만들어질 때 한 번만 호출된다. 홈 왕복은 onRestart와 onStart를 거쳐 복귀하므로 재생기는 새로 만들어지지 않는다. 오히려 처음 만든 하나가 계속 살아 있는 것이 이 배치의 문제다.', true),
(14022, 5191, '재생기를 위치 센서와 같은 콜백 쌍으로 옮기면 화면이 가려질 때 재생이 멈추고 돌아올 때 다시 준비된다.', 'onStart와 onStop 쌍으로 옮기면 재생기의 수명이 화면이 보이는 구간과 맞아떨어진다. 자원은 대칭 콜백 쌍에서 할당하고 해제하라는 원칙을 그대로 적용한 것이라 참인 진술이다.', false),

-- 문제 5192
(14023, 5192, '10:02:14의 onStop 뒤로는 수신 로그가 끊겼다가, 10:07:20의 onStart 뒤부터 다시 찍힌다.', 'STARTED를 기준으로 삼으면 수집은 onStart에서 시작해 onStop에서 취소된다. 그래서 화면이 완전히 가려져 있던 구간의 수신 로그가 사라지고, 다시 보이기 시작하는 onStart에서 수집이 새로 시작된다.', true),
(14024, 5192, '10:02:14의 onPause 뒤로 수신 로그가 끊기고, 10:07:20의 onResume 뒤부터 다시 찍힌다.', 'STARTED를 포커스가 있는 구간으로 오해한 경우다. 그 구간은 onResume과 onPause 사이인 포그라운드 수명이고, STARTED는 화면이 보이는 구간인 onStart부터 onStop까지를 가리킨다.', false),
(14025, 5192, '수신 로그는 지금처럼 그대로 찍히고, 화면에 값을 그리는 부분만 건너뛴다.', '수집은 그대로 두고 화면 갱신만 막아 준다고 본 오개념이다. 감싼 블록 전체가 취소 대상이라 collect 자체가 멈추고, 그 안에서 찍던 로그도 함께 사라진다.', false),
(14026, 5192, '10:02:14의 onStop 뒤로 수신 로그가 끊긴 뒤, 액티비티가 새로 만들어지기 전까지는 돌아와도 다시 찍히지 않는다.', '한 번 취소된 수집은 되살아나지 않는다고 본 오개념이다. 이 블록은 지정한 상태에 다시 들어설 때마다 안쪽을 새로 실행하므로, 앱으로 돌아와 onStart를 지나면 수집이 다시 시작된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1686, 5193, 'addToBackStack,addToBackStack(),addToBackStack(null),FragmentTransaction.addToBackStack,애드투백스택', '뒤로 가기는 프래그먼트 백 스택을 먼저 확인하고, 되돌릴 트랜잭션이 없으면 액티비티를 끝낸다. commit만 한 트랜잭션은 스택에 쌓이지 않아 목록으로 돌아갈 기록이 없었고, 그래서 앱이 그대로 종료된 것이다. addToBackStack을 붙이면 그 트랜잭션이 스택에 쌓여 뒤로 가기가 이를 되돌린다. 또 백 스택에 들어간 프래그먼트는 replace로 밀려나도 onDestroyView까지만 진행돼 인스턴스가 살아남으므로, 돌아온 목록은 같은 인스턴스가 onCreateView부터 뷰만 다시 만들어 붙는다. commit은 트랜잭션을 실행 대기열에 올리는 호출이라 뒤로 가기 동작과는 상관이 없고, popBackStack은 쌓인 트랜잭션을 코드로 직접 되돌릴 때 쓰는 별개의 호출이라는 점과 구분한다.'),
       (1687, 5194, 'onAttach,onAttach(),Fragment.onAttach,onAttach(context),온어태치', '프래그먼트 생명주기 콜백 가운데 Context를 파라미터로 받는 것은 onAttach 하나다. 프래그먼트가 호스트 액티비티에 연결되는 첫 단계라 onCreate·onCreateView보다 앞서 호출되고, 이 시점에는 아직 뷰도 저장 상태 복원도 없다. 호스트를 인터페이스로 캐스팅해 보관하기에 알맞은 자리지만, 그 인터페이스를 구현하지 않은 액티비티에 붙이면 화면이 만들어지기도 전에 ClassCastException이 난다. 예외가 SettingsActivity에서만 나고 화면이 뜨기 전에 터진 이유가 이것이다. 짝이 되는 콜백은 연결이 끊기는 onDetach이며, 여기서 host를 null로 비워야 파괴된 액티비티가 붙잡혀 남지 않는다. onCreate는 Bundle을 받고 이미 연결이 끝난 뒤라 context가 필요하면 requireContext()로 얻고, 뷰가 필요한 초기화는 onViewCreated로 미룬다는 점과 구분한다.');
