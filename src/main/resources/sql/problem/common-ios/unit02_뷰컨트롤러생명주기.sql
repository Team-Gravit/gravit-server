-- Unit: 뷰 컨트롤러 생명주기 (Unit ID: 103)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (529, 103, '콜백 호출 횟수와 자식 뷰 컨트롤러'),
       (687, 103, '전환 시점 작업 배치와 타이머 정리'),
       (845, 103, '뷰 지연 로드와 모달 방식, 레이아웃 반복');

-- =====================================================
-- Lesson 529: 콜백 호출 횟수와 자식 뷰 컨트롤러
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3353, 529, '아래 과정을 모두 마쳤을 때 DetailViewController의 viewDidLoad와 viewWillAppear가 호출된 횟수는?', 'DetailViewController 인스턴스 하나를 아래 순서로 사용한다. 화면 전환은 모두 애니메이션이 끝날 때까지 기다리며, 중간에 인스턴스를 새로 만들지 않는다.

1. 목록 화면에서 DetailViewController를 push
2. 그 위에 SettingsViewController를 modalPresentationStyle = .fullScreen으로 present
3. SettingsViewController를 dismiss
4. DetailViewController를 pop해 목록 화면으로 복귀
5. 목록 화면에서 같은 DetailViewController 인스턴스를 다시 push', 'OBJECTIVE'),
       (3354, 529, '아래 표를 바탕으로 각 콜백에 코드를 배치할 때 옳지 않은 것은?', 'UIKit이 뷰 컨트롤러에 알려 주는 주요 콜백을 정리한 표다.

| 콜백 | 호출 횟수 | 뷰 크기 확정 |
| --- | --- | --- |
| viewDidLoad | 인스턴스당 1회 | 아니오 |
| viewWillAppear | 화면에 나타날 때마다 | 아니오 |
| viewDidAppear | 화면 전환 애니메이션이 끝난 뒤 매번 | 예 |
| viewDidDisappear | 화면에서 사라진 뒤 매번 | 예 |', 'OBJECTIVE'),
       (3355, 529, '아래 상황에서 알림 한 번에 refresh()가 실행되는 횟수는?', '장바구니 화면 코드다.

```swift
final class CartViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refresh),
            name: .cartDidChange, object: nil
        )
    }

    @objc private func refresh() {
        print("refresh")
    }
}
```

removeObserver를 호출하는 코드는 이 클래스 어디에도 없다. 탭 바에서 이 화면이 있는 탭을 처음 연 뒤, 다른 탭에 갔다가 돌아오기를 두 번 반복했다. 같은 인스턴스가 유지된 상태에서 .cartDidChange 알림을 한 번 post한다.', 'OBJECTIVE'),
       (3356, 529, '아래 코드로 자식 뷰 컨트롤러를 화면에 붙였을 때 나타나는 결과로 옳은 것은?', '```swift
final class DashboardViewController: UIViewController {
    private let chartViewController = ChartViewController()
    @IBOutlet private var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(chartViewController.view)
        chartViewController.view.frame = containerView.bounds
    }
}
```

ChartViewController는 viewWillAppear에서 차트 데이터를 새로 고친다. 위 코드에는 addChild(_:)와 didMove(toParent:)를 호출하는 부분이 없다.', 'OBJECTIVE'),
       (3357, 529, '아래 상황에서 뷰 컨트롤러가 메모리에서 해제되지 않은 원인을 가리키는 용어는?', '네비게이션에서 pop으로 화면을 닫았는데도 deinit에 넣어 둔 로그가 찍히지 않았다. 같은 화면을 열고 닫기를 반복한 뒤 Memory Graph Debugger로 확인하니, 닫은 횟수만큼 같은 뷰 컨트롤러 인스턴스가 메모리에 그대로 남아 있었다. 뷰 컨트롤러가 소유한 viewModel의 onUpdate 클로저에서 self.tableView.reloadData()를 호출하던 부분을 [weak self]로 바꾸자, 그 뒤로는 화면을 닫을 때마다 로그가 정상적으로 찍혔다.', 'SUBJECTIVE'),
       (3358, 529, '아래 상황에서 문제가 된 코드를 옮겨야 할 뷰 컨트롤러 생명주기 콜백의 이름은?', '프로필 화면의 아바타를 원형으로 만들려고 아래 한 줄을 뷰 컨트롤러의 어떤 콜백 안에 넣었다.

```swift
avatarView.layer.cornerRadius = avatarView.bounds.width / 2
```

처음 화면이 뜰 때 아바타는 모서리가 전혀 둥글지 않은 사각형으로 보였고, 기기를 회전해도 그대로였다. 같은 줄을 다른 콜백으로 옮기자 첫 진입에도, 회전으로 아바타 크기가 바뀐 뒤에도 항상 정확한 원형으로 보였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3353
(9115, 3353, 'viewDidLoad 1회 / viewWillAppear 2회', '3번 dismiss로 돌아오는 순간을 빠뜨린 계산이다. 전체 화면 모달이 덮는 동안 아래 화면은 사라진 것으로 처리되고, 모달이 닫히면 다시 나타나므로 viewWillAppear가 한 번 더 호출된다.', false),
(9116, 3353, 'viewDidLoad 2회 / viewWillAppear 3회', 'pop되면 뷰까지 버려져 다시 push할 때 뷰를 새로 만든다고 본 오해다. 같은 인스턴스는 이미 로드된 뷰를 그대로 들고 있어 loadView와 viewDidLoad가 다시 호출되지 않는다.', false),
(9117, 3353, 'viewDidLoad 1회 / viewWillAppear 3회', 'viewDidLoad는 뷰가 처음 만들어질 때 인스턴스당 한 번뿐이다. viewWillAppear는 1번 push, 3번 모달 dismiss 후 복귀, 5번 재진입으로 세 번 호출된다.', true),
(9118, 3353, 'viewDidLoad 1회 / viewWillAppear 5회', '다섯 단계마다 한 번씩 나타난다고 센 것이다. 2번 present와 4번 pop은 화면에서 물러나는 단계라 viewWillDisappear가 호출되는 시점이다.', false),

-- 문제 3354
(9119, 3354, 'viewDidLoad에서 view.bounds를 읽어 계산한 프레임 값은 실제 화면 크기와 어긋날 수 있다.', '표에서 viewDidLoad는 뷰 크기가 확정되기 전이다. 이때 bounds는 스토리보드 기본값이거나 0일 수 있어 계산 결과가 실제 화면과 달라진다. 흠 없는 참인 진술이다.', false),
(9120, 3354, 'viewDidAppear는 화면에 나타날 때마다 호출되므로 서브뷰 추가와 제약 조건 설정 같은 초기 UI 구성을 여기에 둔다.', '표의 호출 횟수가 매번이라 화면에 들어올 때마다 같은 서브뷰와 제약 조건이 겹쳐 쌓인다. 초기 구성은 인스턴스당 1회만 호출되는 viewDidLoad에 둬야 해서 이 진술이 거짓이다.', true),
(9121, 3354, '다른 탭에 갔다가 돌아왔을 때 최신 데이터를 반영하려면 갱신 코드를 viewWillAppear에 둔다.', '표에서 viewWillAppear는 화면에 나타날 때마다 호출되므로 복귀할 때마다 갱신이 실행된다. 화면이 보이기 직전이라 갱신 결과가 사용자에게 자연스럽게 이어진다. 참인 진술이다.', false),
(9122, 3354, '재생 중이던 타이머를 멈추는 코드를 viewDidDisappear에 두면 화면이 보이지 않는 동안 동작을 멈출 수 있다.', '표에서 viewDidDisappear는 화면에서 사라진 뒤 매번 호출돼 중단 처리 위치로 알맞다. 다만 이 시점에 인스턴스가 해제된 것은 아니므로 복귀 시 다시 시작할 수 있게 짝을 맞춘다. 참인 진술이다.', false),

-- 문제 3355
(9123, 3355, '1회', '같은 객체와 같은 알림 이름 조합이면 NotificationCenter가 한 번만 등록해 준다고 본 오해다. addObserver를 부를 때마다 등록 항목이 하나씩 따로 늘어난다.', false),
(9124, 3355, '2회', '화면이 사라질 때 UIKit이 옵저버를 정리해 준다고 본 오해다. 자동 정리는 인스턴스가 해제될 때의 이야기라 탭을 오가는 것만으로는 등록이 사라지지 않는다.', false),
(9125, 3355, '4회', '탭을 처음 열 때 viewDidLoad에서도 한 번 등록된다고 읽은 것이다. 코드에서 등록이 일어나는 곳은 viewWillAppear 한 군데뿐이다.', false),
(9126, 3355, '3회', 'viewWillAppear는 최초 진입 1회와 복귀 2회로 모두 세 번 실행되고, 해제가 없어 옵저버가 세 개 쌓인다. 알림 한 번에 세 개가 모두 반응해 refresh가 세 번 실행된다.', true),

-- 문제 3356
(9127, 3356, '차트 뷰는 화면에 그려지지만 ChartViewController의 viewWillAppear가 호출되지 않아 데이터 갱신이 실행되지 않는다.', '부모 뷰 컨트롤러가 자식에게 Appear 계열 콜백을 대신 전달하려면 addChild로 관계를 먼저 등록해야 한다. 뷰 계층에만 올린 자식은 그려지기만 하고 생명주기 콜백을 받지 못한다.', true),
(9128, 3356, 'chartViewController.view에 접근해도 뷰가 만들어지지 않아 viewDidLoad조차 호출되지 않는다.', '부모에 등록되지 않으면 아무 콜백도 오지 않는다고 넓게 본 오해다. view 프로퍼티에 처음 접근하는 순간 뷰가 로드되며 viewDidLoad는 정상적으로 호출된다.', false),
(9129, 3356, '기기를 회전하면 ChartViewController에도 회전 관련 콜백이 전달돼 레이아웃이 다시 잡힌다.', '컨테이너가 자식에게 회전과 트레이트 변화를 전달하는 것도 부모-자식 관계가 있을 때다. addChild가 없으면 이 전달 경로가 없어 자식은 변화를 알지 못한다.', false),
(9130, 3356, '부모에 등록되지 않은 chartViewController가 곧바로 해제돼 컨테이너가 비어 보인다.', 'addChild를 참조 유지 수단으로 오해한 것이다. DashboardViewController가 프로퍼티로 강하게 붙잡고 있어 해제되지 않고, 뷰도 화면에 그대로 남는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1074, 3357, '강한 참조 순환,강한 참조 사이클,순환 참조,참조 순환,retain cycle,리테인 사이클,strong reference cycle,스트롱 레퍼런스 사이클', '뷰 컨트롤러가 viewModel을 소유하고 viewModel의 onUpdate 클로저가 다시 self를 강하게 붙잡으면, 서로의 참조 카운트가 0으로 떨어지지 않아 pop 이후에도 deinit이 실행되지 않는다. [weak self]는 이 고리의 한쪽을 약한 참조로 바꿔 끊는다. 화면에서 사라진 것과 메모리에서 해제된 것은 다르다는 점이 핵심이다. viewDidDisappear가 호출된 뒤에도 인스턴스가 살아 있는 것은 정상이며, 다시 열 수 있는 화면이라면 오히려 그래야 한다. 반면 닫은 횟수만큼 인스턴스가 누적된다면 메모리 누수다. 클로저 말고도 Timer.scheduledTimer(target:selector:)가 타겟을 강하게 붙잡는 경우, delegate 프로퍼티를 weak 없이 선언한 경우가 같은 고리를 만든다.'),
       (1075, 3358, 'viewDidLayoutSubviews,viewDidLayoutSubviews()', '아바타의 실제 크기는 오토 레이아웃이 계산을 끝낸 뒤에야 정해진다. 크기가 확정되기 전인 viewDidLoad나 viewWillAppear에서 bounds를 읽으면 스토리보드 기본값이나 0이 들어와 반지름이 엉뚱해진다. viewDidLayoutSubviews는 서브뷰 배치가 끝날 때마다 호출되므로 첫 진입은 물론 회전이나 키보드로 크기가 바뀌어도 반지름이 다시 계산된다. viewDidAppear와 iOS 17의 viewIsAppearing도 크기가 확정된 뒤이지만 화면에 나타날 때만 호출돼 회전 뒤 크기 변화를 따라가지 못한다는 점에서 구분된다. 대신 이 콜백은 여러 번 호출되므로 서브뷰 추가나 네트워크 요청처럼 반복되면 곤란한 작업은 두지 않고, 프레임 갱신처럼 여러 번 실행해도 결과가 같은 작업만 둔다.');

-- =====================================================
-- Lesson 687: 전환 시점 작업 배치와 타이머 정리
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4301, 687, '아래 코드와 진입 기록에서 네트워크 요청이 나간 총 횟수는?', '피드 탭 화면의 코드다.

```swift
final class FeedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        viewModel.loadInitial()      // 조건 없이 요청을 보낸다
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshIfStale()   // 마지막 요청 시각에서 5분 이상 지났을 때만 요청을 보낸다
    }
}
```

- 네트워크 요청은 위 두 메서드에서만 나가며, 요청을 보내는 즉시 "마지막 요청 시각"이 그 시각으로 바뀐다. loadInitial()로 보낸 요청과 refreshIfStale()로 보낸 요청 모두 해당한다.
- 앱을 켠 뒤 피드 탭이 화면에 나타난 시각은 10:00(처음), 10:04, 10:07, 10:10, 10:13이다. 그 사이에는 다른 탭에 가 있었고, FeedViewController 인스턴스는 계속 유지됐다.', 'OBJECTIVE'),
       (4302, 687, '아래 코드에서 댓글 화면을 push했다가 pop으로 돌아오는 과정에 대한 설명으로 옳은 것은?', '영상 재생 화면의 코드다. 제약 조건 설정 코드는 생략했다.

```swift
final class PlayerViewController: UIViewController {
    private var playerView: PlayerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        let playerView = PlayerView()
        view.addSubview(playerView)
        self.playerView = playerView
        playerView.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerView?.stop()
        playerView?.removeFromSuperview()
        playerView = nil
    }
}
```

사용자는 영상 재생 화면에서 댓글 버튼을 눌러 CommentViewController를 push하고, 댓글을 읽은 뒤 pop으로 영상 재생 화면에 돌아왔다. PlayerViewController에는 위 코드 외에 재정의한 생명주기 콜백이 없다.', 'OBJECTIVE'),
       (4303, 687, '아래 코드와 콘솔 로그에 대한 분석으로 옳은 것은?', '퀴즈 화면의 코드다.

```swift
final class QuizViewController: UIViewController {
    private var timer: Timer?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(tick), userInfo: nil, repeats: true
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
    }

    @objc private func tick() {
        print("tick")
    }

    deinit {
        timer?.invalidate()
        print("deinit")
    }
}
```

목록에서 퀴즈 화면을 push로 한 번 열고, 약 3초 뒤 pop으로 닫았다. 콘솔에는 아래처럼 찍혔으며, 그 뒤로도 tick이 1초마다 계속 찍혔다.

```
tick
tick
tick
viewDidDisappear
tick
tick
```', 'OBJECTIVE'),
       (4304, 687, '아래 옵저버 등록·해제 위치 표에 대한 설명으로 옳은 것은?', '탭 바의 세 화면이 같은 알림(.cartDidChange)을 받아 각자 refresh()를 실행하도록 옵저버를 등록했다. 세 화면 모두 addObserver(self, selector:name:object:)로 등록하고 removeObserver(self, name:object:)로 해제한다. 탭을 오가도 각 화면의 인스턴스는 유지되며, 세 화면 모두 한 번 이상 열어 본 상태다.

| 화면 | 등록 위치 | 해제 위치 |
| --- | --- | --- |
| 홈 | viewDidLoad | deinit |
| 장바구니 | viewWillAppear | viewDidDisappear |
| 마이페이지 | viewWillAppear | deinit |', 'OBJECTIVE'),
       (4305, 687, '아래 상황에서 두 줄을 옮겨 두 문제를 모두 해결한 콜백의 이름은?', '상품 상세 화면의 뷰 컨트롤러는 viewWillAppear에서 아래 두 줄을 실행한다.

```swift
couponBanner.startShakeAnimation()          // 0.3초 동안 배너를 흔드는 애니메이션
Analytics.log("product_detail_impression")  // 화면 노출 이벤트 기록
```

이 상태에서 두 가지 문제가 보고됐다.

1. 목록에서 상세 화면을 push하면 화면이 옆에서 밀려 들어오는 동안 흔들림이 끝나 버려, 사용자는 배너가 움직이는 모습을 거의 보지 못했다.
2. 상세 화면 위에 리뷰 화면을 push해 둔 상태에서, 리뷰 화면의 뒤로 가기 스와이프를 시작했다가 손을 떼 취소해도 상세 화면의 노출 이벤트가 기록됐다. 그 결과 노출 수가 실제로 상세 화면을 다시 본 횟수보다 많이 집계됐다.

두 줄을 다른 콜백 한 곳으로 옮기자 두 문제가 모두 사라졌다.', 'SUBJECTIVE'),
       (4306, 687, '아래 상황에서 스크롤 위치 코드를 마지막으로 옮긴 콜백의 이름은?', '최소 지원 버전이 iOS 17인 캘린더 앱이다. 달력 화면은 목록에서 push로 열리며, 요구 사항은 "화면에 나타날 때마다 오늘 날짜 칸이 가로 가운데에 보일 것"이다. 달력은 화면 가로 폭을 가득 채우고, 스크롤 위치는 아래 코드로 맞춘다.

```swift
// todayOffsetX(width:)는 화면 너비를 받아, 오늘 칸이 가운데 오는 x 좌표를 돌려준다
let x = todayOffsetX(width: view.bounds.width)
calendarView.contentOffset = CGPoint(x: x, y: 0)
```

이 코드를 넣는 위치를 바꿔 가며 확인한 결과다.

| 넣은 위치 | 확인 결과 |
| --- | --- |
| viewDidLoad | 기기에 따라 첫 진입부터 오늘 칸이 가운데에서 벗어났고, 상세 화면을 push했다가 pop으로 돌아와도 다시 맞춰지지 않았다. |
| viewWillAppear | 돌아올 때마다 다시 맞춰졌지만, iPad의 Split View로 앱을 화면 절반 크기로 띄우면 오늘 칸이 가운데에서 벗어났다. |
| viewDidLayoutSubviews | 위치는 정확했지만, 사용자가 다른 달로 스크롤해 둔 채 기기를 회전하면 오늘 칸으로 되돌아갔다. |

마지막으로 옮긴 콜백에서는 달력 화면이 밀려 들어오는 동안에도 오늘 칸이 이미 가운데에 있었고, 회전해도 사용자가 스크롤한 위치가 오늘 칸으로 되돌아가지 않았으며, pop으로 돌아올 때마다 다시 오늘 칸으로 맞춰졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4301
(11643, 4301, '1회', '다른 탭에서 돌아올 때는 viewWillAppear가 호출되지 않는다고 본 오해다. 탭 전환으로 다시 나타날 때도 viewWillAppear가 호출되므로, refreshIfStale()은 진입할 때마다 5분 조건을 확인한다.', false),
(11644, 4301, '3회', '10:00에는 viewDidLoad의 loadInitial()이 요청하고, 곧이어 호출된 viewWillAppear에서는 0분 경과라 요청하지 않는다. 이후 viewWillAppear는 진입마다 호출되며 10:07(7분 경과)과 10:13(10:07에서 6분 경과)에만 요청해 모두 3회다.', true),
(11645, 4301, '4회', '10:07에 다시 요청한 뒤에도 기준을 10:00으로 고정해 10:10을 10분 경과로 센 것이다. refreshIfStale()로 보낸 요청도 마지막 요청 시각을 바꾸므로, 10:10은 10:07에서 3분 경과라 요청하지 않는다.', false),
(11646, 4301, '5회', '진입할 때마다 viewDidLoad가 다시 호출돼 loadInitial()이 다섯 번 요청한다고 센 것이다. viewDidLoad는 인스턴스당 한 번뿐이라 loadInitial()은 10:00에만 실행되고, 이후 진입에서는 viewWillAppear만 호출된다.', false),

-- 문제 4302
(11647, 4302, '돌아올 때 viewDidLoad가 다시 호출돼 PlayerView가 새로 붙고, 영상이 처음부터 재생된다.', '화면에 다시 나타나면 뷰도 새로 로드된다고 본 오해다. 네비게이션 스택에 남아 있던 인스턴스는 이미 로드된 뷰를 그대로 쓰므로, 돌아올 때는 viewDidLoad 없이 viewWillAppear부터 호출된다.', false),
(11648, 4302, '댓글 화면에 가려졌을 뿐이라 viewDidDisappear가 호출되지 않아, 돌아오면 영상이 이어서 재생 중이다.', '다른 화면에 가려진 것은 사라진 것이 아니라고 본 오해다. push 전환이 끝나면 아래에 깔린 화면에도 viewWillDisappear와 viewDidDisappear가 차례로 호출돼 정리 코드가 실행된다.', false),
(11649, 4302, '돌아온 뒤에도 PlayerView를 다시 만드는 코드가 실행되지 않아, 플레이어 자리가 빈 채로 남는다.', 'push 전환이 끝나면 viewDidDisappear가 PlayerView를 떼어 내고 nil로 만든다. 돌아올 때 인스턴스당 1회뿐인 viewDidLoad는 다시 호출되지 않아 복구할 코드가 없다. 화면에서 사라진 것을 해제로 오해하고 자원을 지운 결과다.', true),
(11650, 4302, 'push 애니메이션이 시작되는 순간 PlayerView가 떼어져, 댓글 화면이 밀려 들어오는 동안 빈 자리가 보인다.', 'viewWillDisappear와 viewDidDisappear의 시점을 섞은 오해다. viewDidDisappear는 전환 애니메이션이 끝나 화면이 완전히 가려진 뒤 호출되므로, 댓글 화면이 밀려 들어오는 동안에는 영상이 그대로 보인다.', false),

-- 문제 4303
(11651, 4303, 'timer 프로퍼티를 weak var로 선언하면 뷰 컨트롤러와 타이머 사이의 순환이 끊겨, pop 뒤 deinit이 호출된다.', '뷰 컨트롤러가 타이머를 잡는 쪽만 끊으면 된다고 본 오해다. 예약된 타이머는 런 루프가 붙잡고 있고 타이머가 target인 self를 강하게 보유하므로, 프로퍼티를 weak로 바꿔도 뷰 컨트롤러는 해제되지 않는다.', false),
(11652, 4303, 'viewDidAppear가 두 번 호출돼 타이머가 두 개 만들어졌고, deinit에서는 그중 하나만 invalidate()로 멈췄다.', 'tick이 계속 찍히는 것을 타이머 중복으로 해석한 오해다. 화면은 push로 한 번만 열려 viewDidAppear도 한 번이고, 로그에 deinit이 없으니 invalidate()가 담긴 deinit 자체가 실행되지 않았다.', false),
(11653, 4303, 'pop 직후 뷰 컨트롤러는 이미 해제됐지만, 런 루프에 예약된 타이머가 남아 tick을 계속 호출한다.', 'viewDidDisappear를 해제 시점으로 본 오해다. 해제됐다면 deinit 로그가 찍히고 invalidate()도 실행됐어야 한다. 인스턴스 메서드인 tick이 계속 실행된다는 것 자체가 인스턴스가 살아 있다는 뜻이다.', false),
(11654, 4303, '타이머가 target인 뷰 컨트롤러를 붙잡아 deinit이 호출되지 않으며, invalidate()를 viewDidDisappear로 옮기면 pop 뒤 해제된다.', 'target 방식의 scheduledTimer는 target을 강하게 보유하고, 반복 타이머는 invalidate() 전까지 런 루프에 남는다. 해제돼야 실행되는 deinit에 멈춤 코드를 두면 영영 실행되지 않으므로, 화면이 사라질 때 먼저 멈춰 참조를 놓게 해야 한다.', true),

-- 문제 4304
(11655, 4304, '홈 화면은 다른 탭이 보이는 동안 알림이 와도, 가려진 채로 refresh()가 실행된다.', 'viewDidLoad에서 한 번 등록한 옵저버는 deinit 전까지 남는다. 탭 바가 인스턴스를 유지하므로 홈이 가려져 있어도 알림을 받는다. 보이는 동안에만 받게 하려면 장바구니처럼 viewWillAppear와 viewDidDisappear를 짝지어 둔다.', true),
(11656, 4304, '장바구니 화면은 탭을 오갈수록 등록이 쌓여, 알림 한 번에 refresh()가 여러 번 실행된다.', 'viewWillAppear 등록만 보고 중복을 떠올린 오해다. 사라질 때마다 viewDidDisappear에서 해제하므로 등록은 많아야 하나이고, 화면이 보이는 동안 알림 한 번에 refresh()는 한 번 실행된다.', false),
(11657, 4304, '마이페이지 화면은 deinit에서 해제하므로, 탭을 몇 번 오가도 알림 한 번에 refresh()가 한 번만 실행된다.', '해제 코드가 있으니 중복도 없다고 본 오해다. 등록은 나타날 때마다 일어나는데 해제는 인스턴스가 사라질 때 한 번뿐이라, 다시 들어온 횟수만큼 등록이 쌓여 refresh()가 여러 번 실행된다.', false),
(11658, 4304, '마이페이지 화면은 viewWillAppear에서 등록하므로, 다른 탭이 보이는 동안에는 refresh()가 실행되지 않는다.', '등록 위치만 보고 알림을 받는 구간을 정한 오해다. 받는 구간은 등록부터 해제까지인데 해제가 deinit에 있어, 한 번 나타난 뒤로는 다른 탭이 보이는 동안에도 알림을 받는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1390, 4305, 'viewDidAppear,viewDidAppear(_:),viewDidAppear()', '두 문제 모두 코드가 화면 전환이 끝나기 전에 실행돼서 생겼다. viewWillAppear는 화면이 막 나타나려는 시점에 호출되므로, push 애니메이션과 0.3초짜리 흔들림이 동시에 진행돼 사용자가 배너 움직임을 보지 못한다. 또 리뷰 화면에서 뒤로 가기 스와이프를 시작하면 아래에 깔린 상세 화면에 viewWillAppear가 먼저 호출되고, 손을 떼 취소하면 viewDidAppear 없이 viewWillDisappear와 viewDidDisappear로 끝나 노출 이벤트만 남는다. viewDidAppear는 전환이 실제로 끝나 화면이 완전히 보인 뒤에만 호출되므로 애니메이션 시작, 키보드 올리기, 화면 노출 로그에 알맞다. 전환이 끝나기 전에 호출되는 viewWillAppear와 달리 취소된 전환에서는 호출되지 않는다는 점이 경계다. 반대로 서브뷰 추가 같은 초기 UI 구성을 viewDidAppear에 두면 화면이 다 보인 뒤에 UI가 뒤늦게 바뀌어 깜빡이므로, 그런 작업은 viewDidLoad에 둔다.'),
       (1391, 4306, 'viewIsAppearing,viewIsAppearing(_:),viewIsAppearing()', 'viewIsAppearing은 iOS 17과 함께 추가된 콜백으로, 화면에 나타날 때마다 viewWillAppear 다음에 한 번씩 호출된다. 이 시점에는 뷰가 뷰 계층에 붙어 트레이트와 크기가 실제 값으로 반영돼 있고, 화면 전환 애니메이션은 아직 끝나기 전이다. 그래서 너비에 따라 달라지는 스크롤 위치를 사용자가 보기 전에 정확히 맞출 수 있다. 표의 결과와 비교하면 경계가 분명하다. viewDidLoad는 인스턴스당 1회라 돌아올 때 다시 실행되지 않고 크기도 확정 전이다. viewWillAppear는 매번 호출되지만 크기가 반영되기 전이라 Split View처럼 너비가 달라지면 어긋난다. viewDidLayoutSubviews는 크기는 정확하지만 회전처럼 레이아웃이 바뀔 때마다 다시 호출돼 사용자의 스크롤 위치를 덮어쓴다. 표에 없는 viewDidAppear도 크기는 정확하지만 전환 애니메이션이 끝난 뒤 호출돼, 사용자가 달력이 뒤늦게 튀는 모습을 보게 된다.');

-- =====================================================
-- Lesson 845: 뷰 지연 로드와 모달 방식, 레이아웃 반복
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5249, 845, '아래 코드에서 DetailViewController의 viewDidLoad가 처음 호출되는 시점으로 옳은 것은?', '목록 화면의 셀을 탭했을 때 실행되는 코드다. 네 줄은 위에서부터 차례로 실행된다.

```swift
let detail = DetailViewController()                               // (1)
detail.productID = productID                                      // (2)
detail.view.backgroundColor = .systemBackground                   // (3)
navigationController?.pushViewController(detail, animated: true)  // (4)
```

DetailViewController는 스토리보드 없이 코드로만 만들어졌고, viewDidLoad에서 상품 정보를 서버에 요청한다. productID는 값을 담아 두기만 하는 저장 프로퍼티다.', 'OBJECTIVE'),
       (5250, 845, '아래 두 기록을 비교한 설명으로 옳은 것은?', '최소 지원 버전이 iOS 17인 앱이다. HomeViewController의 생명주기 콜백마다 print를 넣고, 같은 인스턴스에서 SettingsViewController를 present했다가 곧바로 dismiss하는 과정을 두 번 기록했다. 두 번의 차이는 SettingsViewController의 modalPresentationStyle뿐이다.

1회차 — modalPresentationStyle = .pageSheet(기본값)

present가 시작되어 dismiss가 끝날 때까지 HomeViewController에서 찍힌 로그가 하나도 없었다.

2회차 — modalPresentationStyle = .fullScreen

```
viewWillDisappear
viewDidDisappear
viewWillAppear
viewIsAppearing
viewDidAppear
```', 'OBJECTIVE'),
       (5251, 845, '아래 코드에서 회전을 되풀이했을 때 두 작업의 결과가 갈린 이유로 옳은 것은?', '영수증 화면의 코드다.

```swift
final class ReceiptViewController: UIViewController {
    private let logoView = UIImageView(image: UIImage(named: "logo"))

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.frame = CGRect(x: 0, y: 120, width: view.bounds.width, height: 1)
        view.addSubview(separator)

        logoView.layer.cornerRadius = logoView.bounds.width / 2
        logoView.layer.masksToBounds = true
    }
}
```

이 화면을 열어 둔 채 기기를 세 번 회전한 뒤 뷰 디버거로 확인했더니 구분선 뷰가 같은 자리에 네 개 겹쳐 있었고, 메모리 사용량도 함께 늘어 있었다. 반면 로고는 첫 진입에도 회전 뒤에도 언제나 정확한 원형이었다.', 'OBJECTIVE'),
       (5252, 845, '아래 실측 표를 바탕으로 코드를 배치할 때 옳지 않은 것은?', '가로 390pt, 세로 844pt인 아이폰에서 같은 화면을 열고 콜백마다 view.bounds.width를 찍었다. 이 화면을 그린 스토리보드 캔버스의 기본 크기는 가로 375pt다. 화면을 열어 둔 채 기기를 가로로 돌려 한 번 더 기록했다.

| 값을 읽은 콜백 | 세로로 처음 진입 | 가로로 회전한 뒤 |
| --- | --- | --- |
| viewDidLoad | 375 | 호출되지 않음 |
| viewWillAppear | 375 | 호출되지 않음 |
| viewIsAppearing | 390 | 호출되지 않음 |
| viewDidLayoutSubviews | 390 | 844 |
| viewDidAppear | 390 | 호출되지 않음 |', 'OBJECTIVE'),
       (5253, 845, '아래 상황에서 두 줄을 옮겨야 할 뷰 컨트롤러 생명주기 콜백의 이름은?', '메모 작성 화면의 코드다.

```swift
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    view.endEditing(true)             // 올라와 있던 키보드를 내린다
    draftStore.save(textView.text)    // 쓰던 내용을 임시 저장한다
}
```

이 화면은 목록 화면에서 push로 열리고, 뒤로 가기로 목록에 돌아간다. 제보된 증상은 두 가지였다.

1. 키보드를 올린 채 뒤로 가기를 누르면 목록이 밀려 들어오는 내내 키보드가 화면 아래에 남아 있다가, 전환이 끝난 다음에야 내려간다. 그 바람에 이미 자리를 잡은 목록이 한 번 덜컥 밀려 올라간다.
2. 목록 화면은 화면에 나타날 때마다 임시 저장본을 읽어 메모 미리보기를 갱신하는데, 뒤로 가기로 돌아오면 방금 쓴 내용이 아니라 그 이전 내용이 보였다. 목록에서 메모를 한 번 더 열었다 닫으면 그때서야 반영됐다.

두 줄을 다른 콜백 한 곳으로 옮기자 두 증상이 모두 사라졌다.', 'SUBJECTIVE'),
       (5254, 845, '아래 상황에서 적립 요청 코드를 옮겨야 할 뷰 컨트롤러 생명주기 콜백의 이름은?', '주문 완료 화면의 코드다.

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    pointService.earn(orderID: orderID)   // 주문 한 건당 한 번만 적립돼야 한다
}
```

이 화면은 결제가 끝나면 push로 열리고, 사용자는 여기서 영수증 상세 화면을 push로 열어 본 뒤 뒤로 가기로 돌아올 수 있다. 서버 로그를 보니 영수증을 두 번 열어 본 사용자의 주문 한 건에 적립 요청이 세 번 들어와 있었다. 그 사이 주문 완료 화면의 인스턴스는 새로 만들어지지 않았고, 사용자가 화면을 두 번 이상 연 적도 없다.

요청 코드를 다른 콜백 한 곳으로 옮기자 같은 조작에도 적립 요청이 한 번만 들어왔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5249
(14171, 5249, '(1)번 줄 — 인스턴스가 만들어질 때 뷰 계층도 함께 만들어진다.', '초기화만으로 뷰가 생긴다고 본 오해다. init은 프로퍼티만 준비할 뿐이고, 루트 뷰는 필요해지는 순간에 따로 만들어진다. 스토리보드에서 꺼낸 인스턴스도 마찬가지다.', false),
(14172, 5249, '(3)번 줄 — view 프로퍼티를 처음 건드리는 순간 뷰가 만들어진다.', 'view를 읽을 때 아직 뷰가 없으면 UIKit이 그 자리에서 뷰를 만들고 이어서 viewDidLoad를 호출한다. 배경색 한 줄 때문에 화면에 붙기도 전에 상품 정보 요청이 나가는 셈이다.', true),
(14173, 5249, '(4)번 줄 — 화면 스택에 붙는 순간 뷰가 만들어진다.', '(3)번 줄이 없었다면 맞는 말이다. push하면서 뷰가 필요해져 그때 로드되지만, 여기서는 그 전에 view를 건드려 로드가 이미 끝난 상태다.', false),
(14174, 5249, '(4)번 줄의 push 애니메이션이 끝나 화면이 완전히 보인 뒤에 만들어진다.', '전환이 끝난 뒤 호출되는 viewDidAppear와 순서를 섞은 오해다. 뷰가 만들어지고 viewDidLoad가 끝나야 viewWillAppear와 viewDidAppear가 이어진다.', false),

-- 문제 5250
(14175, 5250, '1회차에서도 설정 화면이 홈 화면 위를 덮었으므로 viewWillDisappear는 호출됐고, 로그에 없는 것은 모달 전환이 진행 중이라 출력이 밀렸기 때문이다.', '위에 무언가 뜨면 아래 화면은 사라진 것이라고 본 오해다. 시트는 아래 화면을 계속 보이게 두므로 홈 화면은 나타나 있는 상태 그대로이고, Disappear 계열은 아예 호출되지 않는다.', false),
(14176, 5250, '2회차 복귀 기록의 viewIsAppearing은 iOS 17에서 viewWillAppear를 대체한 콜백이므로, 복귀 시 갱신 코드는 viewIsAppearing에만 둬야 한다.', '새 콜백을 대체로 본 오해다. 같은 기록에 viewWillAppear가 먼저 찍혀 있으니 대체가 아니라 그 뒤에 덧붙은 단계다. 둘은 뷰 크기가 반영되기 전과 후라는 차이로 나눠 쓴다.', false),
(14177, 5250, '옵저버를 viewWillAppear에서 등록하고 viewDidDisappear에서 해제해 두면, 1회차 방식으로 설정 화면을 열고 닫을 때마다 등록이 하나씩 쌓인다.', '등록 쪽만 되풀이된다고 본 오해다. 1회차에서는 두 콜백 모두 호출되지 않아 등록도 해제도 일어나지 않는다. 등록이 쌓이려면 등록만 여러 번 실행되는 짝이어야 한다.', false),
(14178, 5250, '화면 복귀 시 목록을 다시 불러오는 코드를 viewWillAppear에 뒀다면, 1회차 방식으로 연 설정 화면에서 값을 바꾸고 닫아도 홈 화면은 예전 목록 그대로다.', '1회차에서는 홈 화면이 사라진 적이 없으니 다시 나타나지도 않아 갱신 코드가 실행되지 않는다. 시트로 띄운 화면의 결과를 반영하려면 닫힐 때 값을 직접 넘겨 주는 길을 따로 마련해야 한다.', true),

-- 문제 5251
(14179, 5251, '구분선은 오토 레이아웃 제약 없이 프레임으로만 놓여서, 회전할 때 UIKit이 이전 배치를 지우지 못하고 같은 뷰를 다시 그려 남긴다.', '프레임으로 놓은 뷰를 UIKit이 알아서 복제한다고 본 오해다. 늘어난 것은 코드가 회전마다 UIView()로 새로 만들어 붙인 인스턴스이고, 제약 조건이 있고 없고와는 상관이 없다.', false),
(14180, 5251, '회전하면 화면이 다시 나타나는 것으로 처리돼 화면을 구성하는 코드가 한 번 더 실행되며, 로고는 이미 둥글어져 있어 달라진 점이 없을 뿐이다.', '회전을 재등장으로 본 오해다. 회전해도 viewWillAppear와 viewDidAppear는 호출되지 않고 레이아웃 계열 콜백만 다시 호출된다. 구분선이 네 개인 것도 첫 진입 1회에 회전 3회를 더한 수다.', false),
(14181, 5251, '이 콜백은 레이아웃이 다시 잡힐 때마다 실행되는데, 구분선은 실행마다 새 뷰를 하나씩 더하는 작업이고 로고는 같은 레이어의 값을 다시 덮어쓰는 작업이다.', '여러 번 실행해도 결과가 같은 작업만 이 콜백에 둔다는 기준이 그대로 드러난 장면이다. 더하기는 쌓이고 덮어쓰기는 쌓이지 않는다. 서브뷰를 붙이는 일은 인스턴스당 1회인 viewDidLoad로 옮긴다.', true),
(14182, 5251, '뷰 계층에 같은 종류의 뷰가 이미 있으면 addSubview가 교체로 동작하는데, 구분선은 배경색만 지정돼 교체할 대상으로 인식되지 않는다.', 'addSubview가 중복을 알아서 걸러 준다고 본 오해다. 이미 붙어 있는 바로 그 인스턴스를 다시 넣을 때만 자리를 옮길 뿐, 새로 만든 인스턴스는 넣는 대로 계속 쌓인다.', false),

-- 문제 5252
(14183, 5252, 'viewDidAppear에서 읽은 값이 실제 너비와 같으므로, 회전으로 너비가 바뀔 때도 이 콜백이 다시 호출돼 값을 새로 계산해 준다.', '표에서 회전 뒤 viewDidAppear는 호출되지 않는다. 첫 진입 때 값이 정확한 것과 회전을 따라 다시 계산되는 것은 별개라, 크기 변화까지 쫓아가려면 레이아웃 계열 콜백이 필요하다.', true),
(14184, 5252, '첫 진입 때 viewWillAppear에서 읽은 값이 실제 너비와 다르므로, 너비에 비례해 프레임을 계산하는 코드를 여기 두면 기기에 따라 어긋난 값이 남는다.', '표의 375는 스토리보드 캔버스 기본값이 그대로 남은 것이다. 이 시점에는 뷰가 실제 화면 크기로 맞춰지기 전이라 그 값으로 계산하면 결과가 어긋난다. 참인 진술이다.', false),
(14185, 5252, '회전한 뒤 값이 다시 기록된 콜백이 하나뿐이므로, 회전으로 크기가 바뀌어도 맞아야 하는 프레임 계산은 viewDidLayoutSubviews에 둔다.', '표에서 844로 갱신된 곳은 viewDidLayoutSubviews 한 줄뿐이다. 레이아웃이 다시 잡힐 때마다 호출되므로 크기에 따라 달라지는 값을 여기서 갱신한다. 참인 진술이다.', false),
(14186, 5252, '오토 레이아웃 제약 조건은 실제 너비 값을 직접 읽어 쓰지 않으므로, 표처럼 시점마다 값이 달라도 제약 설정은 viewDidLoad에 둬도 된다.', '제약 조건은 375나 390 같은 값을 계산에 쓰는 것이 아니라 뷰 사이의 관계를 미리 선언해 둔다. 크기가 확정되기 전에 걸어 둬도 레이아웃 때 알아서 반영된다. 참인 진술이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1706, 5253, 'viewWillDisappear,viewWillDisappear(_:),viewWillDisappear()', 'push와 pop 전환에서 콜백은 나가는 화면의 viewWillDisappear, 들어오는 화면의 viewWillAppear, 나가는 화면의 viewDidDisappear, 들어오는 화면의 viewDidAppear 순으로 맞물린다. 두 증상 모두 정리 코드가 이 맞물림의 맨 뒤에 있어서 생겼다. viewDidDisappear는 전환 애니메이션이 완전히 끝난 뒤에야 호출되므로 키보드는 목록이 밀려 들어오는 내내 떠 있다가 뒤늦게 내려가고, 임시 저장도 목록 화면이 저장본을 읽은 다음에 이뤄져 한 박자 늦은 내용이 보인다. viewWillDisappear는 전환이 시작되기 전에 호출돼 키보드를 미리 내리고 저장을 끝낼 수 있어, 화면을 떠나기 직전에 마무리해야 하는 일의 자리다. 다만 이 콜백은 뒤로 가기 스와이프를 시작했다가 취소해도 호출되므로, 화면이 실제로 사라진 뒤에만 해야 하는 일(옵저버 해제, 타이머 정지, 재생 중단)은 viewDidDisappear에 둔다. viewDidDisappear가 호출됐다고 해서 인스턴스가 해제된 것은 아니라는 점도 함께 기억한다.'),
       (1707, 5254, 'viewDidLoad,viewDidLoad()', 'Appear 계열 콜백은 화면에 나타날 때마다 호출된다. 영수증 화면을 push하면 주문 완료 화면은 가려졌다가 pop으로 돌아올 때 다시 나타나므로, 첫 진입 1회에 복귀 2회를 더해 적립 요청이 세 번 나갔다. viewDidLoad는 뷰가 만들어질 때 인스턴스당 딱 한 번만 호출되므로 주문 한 건에 한 번이면 되는 일의 자리이고, 서브뷰 추가, 제약 조건 설정, 델리게이트와 데이터소스 연결처럼 되풀이하면 곤란한 초기 구성도 같은 이유로 여기에 둔다. viewDidAppear로 옮기는 답은 통하지 않는다. 호출 시점만 뒤로 밀릴 뿐 화면에 나타날 때마다 호출되는 것은 같기 때문이다. 경계도 함께 봐 둔다. viewDidLoad 시점에는 뷰 크기가 아직 확정되지 않아 bounds나 frame을 읽어 계산하는 코드는 두면 안 되고, 반대로 화면에 돌아올 때마다 새로 읽어야 하는 데이터는 viewWillAppear에 남겨 둬야 한다.');
