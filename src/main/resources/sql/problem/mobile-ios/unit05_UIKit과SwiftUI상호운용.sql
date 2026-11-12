-- Unit: UIKit과 SwiftUI 상호운용 (Unit ID: 181)
-- Chapter: iOS (Chapter ID: 17)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (607, 181, '코디네이터 위임과 호스팅 컨트롤러 등록'),
       (765, 181, '브리지 생명주기와 해제, 이중 내비게이션'),
       (923, 181, 'UIKit과 SwiftUI 상호운용: 뷰 정체성과 크기·참조 관리');

-- =====================================================
-- Lesson 607: 코디네이터 위임과 호스팅 컨트롤러 등록
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3821, 607, '아래 브리지 코드로 만든 입력창에서 나타나는 현상으로 옳은 것은?', '사용자가 한 글자 입력할 때마다 부모 뷰의 body가 다시 평가된다.

```swift
struct AddressField: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.addTarget(context.coordinator,
                        action: #selector(Coordinator.editingChanged(_:)),
                        for: .editingChanged)
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}
```', 'OBJECTIVE'),
       (3822, 607, '아래 비교표를 바탕으로 두 프레임워크를 한 화면에 섞어 쓸 때의 설명으로 옳지 않은 것은?', '| 항목 | UIKit | SwiftUI |
|---|---|---|
| 뷰 수명 | 개발자가 생성·보관·해제 | 프레임워크가 정체성 기준으로 관리 |
| 갱신 트리거 | 명령형 호출(label.text = ...) | 상태 변경 후 body 재평가 |
| 상태 저장소 | 객체 프로퍼티 | @State 등 프레임워크 저장소 |
| 경계 통과 | 브리지 구조체는 값으로 복사됨 | rootView 교체 또는 관찰 객체 변경 |', 'OBJECTIVE'),
       (3823, 607, '아래 UIKit 컨테이너 코드에서 나타난 증상의 원인으로 옳은 것은?', '탭을 전환해도 host의 viewWillAppear가 호출되지 않고, 화면을 회전하면 SummaryView가 세이프 에어리어를 벗어나 그려진다.

```swift
final class DashboardVC: UIViewController {
    private let host = UIHostingController(rootView: SummaryView())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(host.view)
        host.view.frame = view.bounds
    }
}
```', 'OBJECTIVE'),
       (3824, 607, '아래 상황의 원인과 대응으로 옳은 것은?', 'SwiftUI 화면 A는 상위 뷰에서 .environment로 주입한 테마 설정을 읽어 다크 팔레트로 그려진다. 같은 화면 A를 기존 UIKit 앱의 내비게이션 스택에서 UIHostingController로 감싸 push하자, 화면 A가 읽는 @Environment 값이 모두 기본값이 되어 라이트 팔레트로 그려졌다. 화면 A의 코드와 rootView로 넘긴 인스턴스는 그대로다.', 'OBJECTIVE'),
       (3825, 607, '아래 증상을 모두 없애기 위해 이 구조체에 도입해야 하는 객체의 이름은?', 'SwiftUI 화면에 UITextField를 넣으려고 UIViewRepresentable을 따르는 구조체 SearchField를 만들었다. field.delegate = self로 쓰자 "type does not conform to NSObjectProtocol" 오류가 나 빌드가 멈췄고, addTarget(self, action: #selector(...))도 같은 이유로 막혔다. 급한 대로 updateUIView 안에서 델리게이트를 맡을 객체를 새로 만들어 붙이자 빌드는 통과했지만, 실행 로그는 아래와 같았고 편집 콜백은 끝내 한 번도 들어오지 않았다.

```text
update #1  delegate = 0x600001a0c0e0
update #2  delegate = 0x600001a0d1a0   // 이전 객체 해제
update #3  delegate = 0x600001a0e2b0   // 이전 객체 해제
editingChanged 수신: 0회
```', 'SUBJECTIVE'),
       (3826, 607, '아래 빈칸에 들어갈 iOS 16 이상 타입의 이름은?', 'UIKit 컬렉션 뷰는 그대로 두고 셀 안쪽만 SwiftUI로 바꾸기로 했다. 처음에는 셀마다 UIHostingController를 만들어 contentView에 붙였는데, 스크롤해 셀이 재사용되면 이전 행의 내용이 남아 겹쳐 보이고 자동 높이가 실제 콘텐츠보다 작게 계산됐다. 아래처럼 한 줄로 바꾸자 재사용과 높이 계산이 모두 정상으로 돌아왔다.

```swift
cell.contentConfiguration = ______ {
    OrderRow(order: order)
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3821
(10363, 3821, '상태가 바뀔 때마다 makeUIView가 다시 호출되어 입력 도중 UITextField 인스턴스가 계속 새로 만들어진다.', 'makeUIView는 뷰 정체성이 생길 때 한 번만 불리고, 반복 호출되는 쪽은 updateUIView다. 생성 단계와 갱신 단계를 하나로 뭉뚱그린 오해다.', false),
(10364, 3821, 'updateUIView는 생성 직후 한 번만 호출되므로 Binding 값이 바뀌어도 화면에 반영되지 않는다.', 'updateUIView는 생성 직후뿐 아니라 부모가 재평가될 때마다 호출된다. 반영이 안 되는 것이 아니라 지나치게 자주 되는 것이 이 코드의 문제다.', false),
(10365, 3821, '델리게이트를 updateUIView에서 다시 연결하지 않아 두 번째 입력부터 Coordinator 콜백이 호출되지 않는다.', '델리게이트는 makeUIView에서 한 번 연결하면 같은 UITextField 인스턴스가 유지되는 동안 계속 살아 있다. 갱신마다 재연결해야 한다는 오해다.', false),
(10366, 3821, '한 글자 입력할 때마다 문자열이 통째로 다시 대입되어 커서가 끝으로 밀리고 중간 편집이 어긋난다.', '부모가 재평가될 때마다 갱신 메서드가 돌고, 값이 같아도 대입하면 UITextField가 선택 범위를 재설정한다. 달라졌을 때만 반영하는 멱등한 갱신이 필요하다.', true),

-- 문제 3822
(10367, 3822, '브리지 구조체의 저장 프로퍼티는 UIKit 객체처럼 개발자가 수명을 관리하므로, 뷰가 다시 평가돼도 이전에 넣어 둔 값이 그대로 남는다.', '표의 뷰 수명·경계 통과 행에 정면으로 걸린다. 구조체는 값으로 복사돼 재평가 때 새로 만들어질 수 있으므로, 유지해야 할 상태는 Coordinator나 @State에 둬야 한다.', true),
(10368, 3822, '갱신 트리거가 상태 변경이라 브리지의 갱신 메서드는 여러 번 불릴 수 있고, 그래서 같은 입력에 같은 결과가 나오도록 써야 한다.', '재평가 횟수는 개발자가 정하지 않는다. 호출 횟수에 결과가 좌우되면 같은 화면이 실행마다 다르게 보이므로 멱등하게 쓰는 것이 전제가 된다.', false),
(10369, 3822, 'UIKit 쪽은 명령형 호출로 화면을 바꾸므로, SwiftUI 상태와 UIKit 프로퍼티를 각각 갱신하면 같은 값이 두 곳에 따로 남을 수 있다.', '상태 저장소가 객체 프로퍼티와 프레임워크 저장소로 갈라져 있어 생기는 결과다. 모델 소유권을 한쪽에 두고 다른 쪽은 읽기만 하도록 설계하는 이유다.', false),
(10370, 3822, 'UIKit 뷰는 개발자가 참조를 들고 있는 동안 살아 있으므로, 브리지가 만든 UIView 인스턴스를 갱신마다 새로 만들 필요는 없다.', '뷰 수명 행에서 곧장 나오는 결론이다. 생성은 한 번으로 끝내고 이후에는 그 인스턴스에 바뀐 값만 반영하는 것이 UIKit 쪽 수명 모델에 맞다.', false),

-- 문제 3823
(10371, 3823, 'host.view의 translatesAutoresizingMaskIntoConstraints가 true로 남아 Auto Layout이 적용되지 않은 것이 두 증상의 원인이다.', '프레임으로 배치했더라도 그것 때문에 viewWillAppear 전달이 끊기지는 않는다. 레이아웃 설정 문제와 컨테이너 계약 문제를 섞은 오해다.', false),
(10372, 3823, '호스팅 컨트롤러를 addChild와 didMove(toParent:)로 자식에 등록하지 않고 view만 붙여, 컨테이너가 표시·회전 이벤트를 전달하지 않는다.', '자식 뷰 컨트롤러 계약을 지켜야 부모가 생명주기 호출과 세이프 에어리어 정보를 자식에게 넘긴다. view만 떼어 붙이면 컨트롤러가 계층 밖에 남는다.', true),
(10373, 3823, 'rootView가 구조체라 값으로 복사되고, 그 때문에 화면이 회전할 때 이전 SwiftUI 뷰가 해제되어 콜백이 끊긴다.', 'SwiftUI 뷰가 값 타입인 것은 맞지만, 그것과 UIViewController 생명주기 콜백 전달은 다른 층의 이야기다. 값 타입 특성으로 증상을 설명할 수 없다.', false),
(10374, 3823, 'UIHostingController는 내비게이션 컨트롤러에 push된 경우에만 세이프 에어리어와 생명주기를 처리하므로 컨테이너 임베드는 지원하지 않는다.', '자식 뷰 컨트롤러로 임베드하는 것도 정식 사용법이다. 임베드가 막힌 것이 아니라 임베드 계약을 지키지 않은 것이 문제다.', false),

-- 문제 3824
(10375, 3824, '호스팅 컨트롤러가 rootView를 복사하면서 @Environment가 @State로 바뀌므로, 테마 값을 @Binding으로 바꿔 넘겨야 한다.', '프로퍼티 래퍼가 다른 종류로 바뀌는 일은 없다. 값 복사와 환경 전달을 뒤섞은 오해이며, 래퍼를 바꿔도 끊긴 전달 경로는 이어지지 않는다.', false),
(10376, 3824, '환경값은 앱 진입점에서 한 번 주입하면 앱 전체에 유효하므로, 기본값이 읽혔다면 주입 코드 자체가 빠진 것이다.', '환경값은 앱 전역이 아니라 뷰 트리를 따라 아래로만 전달된다. 화면 A는 SwiftUI 트리 안에서는 값을 잘 읽었으므로 주입 누락으로는 설명되지 않는다.', false),
(10377, 3824, 'SwiftUI 환경은 뷰 트리를 타고 내려가는데 UIKit 계층을 한 번 거치며 끊기므로, rootView에 환경값을 다시 붙여 주입해야 한다.', 'UIHostingController는 새로운 SwiftUI 트리의 뿌리를 만든다. 위쪽 UIKit 화면은 환경을 옮겨 주지 않으니 호스팅 지점마다 필요한 값을 다시 넣어야 한다.', true),
(10378, 3824, 'push된 뷰 컨트롤러는 별도 윈도 씬에 올라가므로 씬 델리게이트에서 테마를 다시 설정해야 한다.', 'push는 같은 윈도의 내비게이션 스택 안에서 일어난다. 씬이 갈라진다는 전제 자체가 사실과 다르므로 대응 방향도 성립하지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1230, 3825, 'Coordinator,코디네이터,coordinator', '구조체는 NSObjectProtocol을 따를 수 없어 델리게이트나 #selector 타깃 자리에 자신을 넣지 못한다. 또 갱신 메서드 안에서 만든 객체는 아무도 붙잡아 두지 않아 곧 해제되므로, 로그처럼 갱신마다 주소만 바뀌고 콜백은 한 번도 도착하지 않는다. UIViewRepresentable은 이 두 문제를 함께 풀라고 Coordinator를 둔다. makeCoordinator()가 만든 NSObject 상속 인스턴스 하나가 뷰 정체성 수명 동안 유지되고, makeUIView에서 context.coordinator로 꺼내 델리게이트와 타깃으로 연결한다. UIKit에서 SwiftUI로 값을 되돌리는 통로도 이 객체의 콜백이다. 갱신 값과 환경을 담아 전달되는 Context, 화면 이동 흐름을 관리하는 UIKit의 코디네이터 패턴과는 다른 개념이니 구분해 두자.'),
       (1231, 3826, 'UIHostingConfiguration,호스팅 컨피규레이션,hosting configuration', '셀 안쪽만 SwiftUI로 채울 때는 셀마다 호스팅 컨트롤러를 붙이는 대신 contentConfiguration에 UIHostingConfiguration을 대입한다. 셀이 재사용될 때 configuration만 교체되므로 이전 행의 내용이 남지 않고, 셀 높이도 SwiftUI 콘텐츠 크기를 반영해 계산된다. 화면 단위로 SwiftUI를 UIKit에 얹는 UIHostingController와는 쓰임이 다르고, 반대 방향으로 UIKit 뷰를 SwiftUI 안에 넣는 UIViewRepresentable과도 구분한다.');

-- =====================================================
-- Lesson 765: 브리지 생명주기와 해제, 이중 내비게이션
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4769, 765, '아래 실행 로그를 남긴 브리지 구조체에 대한 설명으로 옳은 것은?', 'SwiftUI 화면에 UIKit 입력창을 넣는 브리지 구조체 SearchField를 만들고, 생명주기 메서드마다 호출 시각과 객체 주소를 찍었다. 사용자가 검색어를 한 글자씩 입력하는 동안 아래 로그가 남았다.

```text
[00.00] makeCoordinator  coordinator=0x6000a1
[00.01] makeUIView       field=0x7f8b01
[00.01] updateUIView     field=0x7f8b01  coordinator=0x6000a1  text=""
[03.12] updateUIView     field=0x7f8b01  coordinator=0x6000a1  text="se"
[03.12] updateUIView     field=0x7f8b01  coordinator=0x6000a1  text="se"
[04.40] updateUIView     field=0x7f8b01  coordinator=0x6000a1  text="sea"
[04.41] updateUIView     field=0x7f8b01  coordinator=0x6000a1  text="sea"
```', 'OBJECTIVE'),
       (4770, 765, '아래 코드에서 새로고침을 반복할수록 나타나는 증상의 원인과 대응으로 옳은 것은?', '기존 UIKit 화면 안에 주문 요약만 SwiftUI로 그려 넣었다. 새로고침 버튼을 누를 때마다 reload(orders:)가 호출된다.

```swift
final class OrderBoardVC: UIViewController {
    func reload(orders: [Order]) {
        let host = UIHostingController(rootView: OrderSummary(orders: orders))
        addChild(host)
        view.addSubview(host.view)
        host.view.frame = view.bounds
        host.didMove(toParent: self)
    }
}
```

새로고침을 누를수록 화면이 점점 느려지고 메모리 사용량이 계속 늘었다. 스크롤하면 이전 주문 목록이 새 목록 뒤에서 함께 움직이는 것도 보였다.', 'OBJECTIVE'),
       (4771, 765, '아래 코드에서 경고가 반복해서 찍히는 원인과 대응으로 옳은 것은?', 'SwiftUI 화면에 UIKit 지도 뷰를 넣는 브리지 구조체다. 지도가 확대 배율을 자신이 지원하는 단계로 보정하기 때문에, 보정된 값을 화면 상태에도 맞춰 두려고 마지막 한 줄을 덧붙였다.

```swift
struct ZoomableMap: UIViewRepresentable {
    @Binding var zoomLevel: Double

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.setRegion(region(for: zoomLevel), animated: false)
        zoomLevel = map.appliedZoomLevel
    }
}
```

손가락으로 지도를 확대하면 배율이 한 번 튀었다가 되돌아오고, 콘솔에는 정의되지 않은 동작이 생길 수 있다는 경고가 확대할 때마다 쌓였다.', 'OBJECTIVE'),
       (4772, 765, '아래 상황에서 화면 위쪽이 이중으로 보이는 원인으로 옳은 것은?', '기존 UIKit 앱의 설정 화면을 SwiftUI로 새로 만들었다. SettingsView는 단독 화면으로도 쓸 수 있게 안쪽에 NavigationStack을 두고 제목을 붙여 뒀다. 이 화면을 기존 UINavigationController 스택 위에 아래처럼 얹었다.

```swift
let host = UIHostingController(rootView: SettingsView())
navigationController?.pushViewController(host, animated: true)
```

실행하니 화면 위쪽에 제목 줄이 두 층으로 겹쳐 그려지고, 뒤로 가기 화살표도 두 개가 나란히 보였다.', 'OBJECTIVE'),
       (4773, 765, '아래 상황에서 SafariView가 대신 채택해야 할 프로토콜의 이름은?', 'SwiftUI 화면에서 약관 링크를 누르면 SFSafariViewController를 띄우려고 구조체 SafariView를 만들었다. UIViewRepresentable을 채택하고 아래처럼 쓰자 빌드가 멈췄다.

```swift
struct SafariView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
}
```

```text
error: type SafariView does not conform to protocol UIViewRepresentable
note: inferred UIViewType SFSafariViewController must be a UIView subclass
```

급한 대로 SFSafariViewController(url: url).view만 반환하도록 바꾸자 빌드는 통과했지만, 사파리 화면의 완료 버튼이 동작하지 않았고 몇 초 뒤 내용이 흰 화면으로 바뀌었다.', 'SUBJECTIVE'),
       (4774, 765, '아래 증상을 없애려면 이 브리지 구조체에 추가로 구현해야 할 UIViewRepresentable 메서드의 이름은?', 'SwiftUI 화면에 UIKit 지도 뷰를 넣는 브리지 구조체를 아래처럼 만들었다.

```swift
func makeUIView(context: Context) -> MKMapView {
    let map = MKMapView()
    NotificationCenter.default.addObserver(context.coordinator,
                                          selector: #selector(Coordinator.locationDidChange(_:)),
                                          name: .locationDidChange,
                                          object: nil)
    return map
}
```

목록 화면과 지도 화면을 오가며 테스트하자 아래 로그가 남았고, 지도 화면에 들어갈 때마다 메모리 사용량도 함께 늘어 돌아오지 않았다.

```text
지도 화면 1회차 진입 → 알림 1건에 locationDidChange 1회 실행
지도 화면 2회차 진입 → 알림 1건에 locationDidChange 2회 실행
지도 화면 3회차 진입 → 알림 1건에 locationDidChange 3회 실행
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4769
(12891, 4769, '입력이 들어올 때마다 UITextField가 새로 만들어지므로, 생성 시 연결한 델리게이트와 타깃 액션을 갱신 메서드에서 매번 다시 연결해야 한다.', '로그의 field 주소는 처음부터 끝까지 그대로다. 생성은 뷰 정체성이 생길 때 한 번뿐인데, 갱신이 잦은 것을 재생성으로 오해한 것이다. 연결은 생성 단계에서 한 번이면 된다.', false),
(12892, 4769, '브리지를 받치는 참조 객체는 갱신마다 새로 만들어지므로, 직전 입력값처럼 유지해야 하는 값을 이 객체에 두면 다음 갱신에서 사라진다.', 'coordinator 주소도 로그 내내 하나다. 이 객체는 뷰 정체성 수명 동안 유지되므로 오히려 값을 붙잡아 두기 좋은 자리다. 재평가마다 새로 복사되는 구조체 쪽 프로퍼티와 혼동한 것이다.', false),
(12893, 4769, '같은 text 값으로 갱신이 두 번 돈 것은 구현 오류이므로, 호출 횟수를 입력 한 번당 한 번으로 맞춰야 정상 동작한다.', '재평가 횟수는 개발자가 정하지 않는다. 프레임워크가 여러 번 부를 수 있다는 전제 위에서, 몇 번 불려도 결과가 같도록 갱신을 멱등하게 쓰는 것이 올바른 대응이다.', false),
(12894, 4769, '입력 한 번에 갱신이 두 번 돌았으므로, 갱신 메서드 안에서 검색 요청을 시작하면 같은 질의가 두 번 나간다.', '로그에서 같은 text 값이 연속 두 번 들어온다. 반복 호출되는 자리에 부수 효과를 두면 횟수만큼 실행되므로, 요청 시작은 콜백 쪽으로 옮기고 갱신에는 값 반영만 남긴다.', true),

-- 문제 4770
(12895, 4770, '갱신할 때마다 호스팅 컨트롤러를 새로 만들어 붙이기만 하고 이전 것을 떼지 않는다. 하나만 두고 rootView나 관찰 객체를 바꿔 갱신해야 한다.', '자식 등록과 서브뷰 추가가 호출마다 반복되면 예전 화면이 그대로 겹겹이 남아 메모리와 렌더링 비용이 함께 쌓인다. 갈아 끼울 단위는 컨트롤러가 아니라 컨트롤러가 들고 있는 상태다.', true),
(12896, 4770, 'rootView가 값 타입이라 orders가 바뀌어도 화면에 반영되지 않으므로, OrderSummary를 클래스로 바꿔 참조로 넘겨야 한다.', 'SwiftUI 뷰는 값 타입인 채로 갱신되며, 실제 증상도 반영이 안 되는 것이 아니라 새 화면이 계속 덧붙는 것이다. 값 타입이라는 사실을 갱신 불가로 확대 해석한 오해다.', false),
(12897, 4770, 'didMove(toParent:)를 addSubview보다 먼저 호출해야 하는데 순서가 어긋나 이전 화면이 해제되지 못한 것이다.', '자식 등록 계약의 순서는 addChild 다음에 뷰를 붙이고 마지막에 didMove(toParent:)다. 코드의 순서는 맞고, 빠진 것은 순서가 아니라 이전 자식을 떼어내는 단계다.', false),
(12898, 4770, 'SwiftUI 뷰는 UIKit 컨테이너 안에서 상태를 유지할 수 없어 갱신마다 새로 만들어야 하며, 느려지는 것은 렌더링 비용 탓이다.', '호스팅 컨트롤러 안에서도 SwiftUI 상태 저장소는 정상 동작한다. 재생성이 불가피하다는 전제가 틀렸고, 느려지는 원인도 렌더링 자체가 아니라 쌓여 남은 자식 컨트롤러다.', false),

-- 문제 4771
(12899, 4771, '@Binding은 상위 뷰가 소유한 값이라 브리지 안에서는 읽기만 되므로, @State로 바꿔 구조체가 값을 직접 보관하면 경고가 사라진다.', 'Binding은 쓰기가 되는 통로다. 문제는 쓰기 가능 여부가 아니라 쓰는 시점이며, @State로 바꾸면 상위와 값이 끊겨 보정된 배율이 화면 상태에 전달되지 않는다.', false),
(12900, 4771, '지도 뷰 갱신이 백그라운드 스레드에서 실행돼 생긴 경고이므로, 갱신 코드를 메인 액터에서 돌게 하면 해결된다.', '갱신 메서드는 이미 메인에서 불린다. 스레드 경고와 뷰 갱신 중 상태 변경 경고를 섞은 오해이며, 액터를 지정해도 같은 자리에서 상태를 쓰는 구조는 그대로 남는다.', false),
(12901, 4771, '뷰 갱신이 진행되는 도중에 상위 상태를 다시 써서 재평가가 겹치는 것이 원인이다. 보정값은 델리게이트 콜백에서 전달하거나 다음 런루프로 미뤄 반영한다.', '갱신 도중 상태를 바꾸면 평가가 끝나기 전에 다음 평가가 촉발돼 결과가 정의되지 않는다. UIKit에서 SwiftUI로 값을 되돌리는 일은 코디네이터의 콜백이 맡는 자리다.', true),
(12902, 4771, '갱신 메서드가 부모 재평가마다 불려 생긴 경고이므로, 배율이 직전과 다를 때만 setRegion을 호출하도록 조건을 걸면 해결된다.', '멱등한 갱신은 커서 튐이나 중복 로드를 막을 때 쓰는 대응이다. setRegion에 조건을 걸어도 마지막 줄의 상태 쓰기는 그대로 남아 경고의 원인은 사라지지 않는다.', false),

-- 문제 4772
(12903, 4772, '호스팅 뷰가 세이프 에어리어를 이중으로 적용해 위쪽에 여백이 생긴 것이므로, 세이프 에어리어 적용 범위를 조정하면 사라진다.', '세이프 에어리어 이중 적용은 빈 여백이 생기는 문제다. 여기서는 제목 줄과 뒤로 가기 버튼이 실제로 두 벌 그려졌으므로 여백 문제로는 설명되지 않는다.', false),
(12904, 4772, '화면 전환을 이미 UIKit 스택이 소유하고 있는데 SwiftUI 쪽도 자기 내비게이션 컨테이너를 얹어, 두 벌의 바가 함께 그려진다.', '한 화면의 흐름을 양쪽이 동시에 소유하면 바도 두 벌이 된다. 소유권을 어느 쪽에 둘지 먼저 정하고, UIKit이 스택을 쥔다면 rootView 안쪽 컨테이너를 걷어낸다.', true),
(12905, 4772, 'rootView가 값으로 복사되면서 push가 두 번 실행돼, 같은 화면이 내비게이션 스택에 두 개 쌓인 것이다.', '값 복사는 push 횟수와 관계가 없다. 화면이 두 번 쌓였다면 본문 콘텐츠까지 겹쳐 보여야 하는데, 겹친 것은 위쪽 바뿐이라 전제가 증상과 맞지 않는다.', false),
(12906, 4772, '호스팅 컨트롤러는 자체 내비게이션 바를 항상 그리므로, push해서 쓸 때는 UIKit 쪽 바를 숨기는 것이 정해진 사용법이다.', '호스팅 컨트롤러는 여느 뷰 컨트롤러처럼 바깥 바를 그대로 쓴다. 두 번째 바를 그린 것은 rootView 안쪽에 둔 내비게이션 컨테이너이며, UIKit 바를 숨기는 것이 규칙인 것도 아니다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1546, 4773, 'UIViewControllerRepresentable,UIViewControllerRepresentable 프로토콜', 'UIViewRepresentable이 다루는 타입은 UIView 하위 타입이어야 해서 뷰 컨트롤러는 담기지 않는다. 오류 메시지가 가리키는 것도 이 제약이다. 뷰 컨트롤러 단위를 SwiftUI 안에 넣을 때는 UIViewControllerRepresentable을 채택하고 makeUIViewController(context:)와 updateUIViewController(_:context:)를 구현한다. 구조는 UIViewRepresentable과 같고 코디네이터도 그대로 쓸 수 있다. view만 떼어 붙이면 컨트롤러 인스턴스를 아무도 붙잡지 않아 곧 해제되므로, 완료 버튼 처리나 내용 유지처럼 컨트롤러가 맡던 동작이 함께 끊긴다. 방향이 반대인 UIHostingController(SwiftUI 뷰를 UIKit 안에 넣는 컨트롤러), 셀 안쪽에만 쓰는 UIHostingConfiguration과는 쓰임이 다르니 구분해 두자.'),
       (1547, 4774, 'dismantleUIView,dismantleUIView(_:coordinator:),static func dismantleUIView,dismantle', '브리지 뷰가 화면에서 제거될 때 한 번 불리는 정리 훅이 dismantleUIView(_:coordinator:)다. 여기서 옵저버를 해제하지 않으면 지도 화면에 들어올 때마다 새 코디네이터가 옵저버로 등록되고 이전 등록은 알림 센터에 그대로 남는다. 로그처럼 알림 한 건에 핸들러가 진입 횟수만큼 실행되고, 붙잡힌 옛 객체가 해제되지 않아 메모리도 계속 늘어난다. 이 메서드는 인스턴스가 아니라 타입에 붙는 static 메서드이고, 인자로 받은 코디네이터를 통해 생성 단계에서 등록해 둔 것을 되돌린다. 뷰 정체성이 생길 때 한 번 불리는 makeUIView, 재평가마다 반복해서 불리는 updateUIView와 역할이 갈리며, 브리지 구조체는 뷰 컨트롤러가 아니므로 viewWillDisappear 같은 UIKit 생명주기 콜백이 대신 불려 주지 않는다는 점도 함께 기억해 두자.');

-- =====================================================
-- Lesson 923: UIKit과 SwiftUI 상호운용: 뷰 정체성과 크기·참조 관리
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5717, 923, '아래 코드와 로그로 볼 때, 증상의 원인과 대응으로 옳은 것은?', '채팅 화면 아래쪽 입력창은 UITextField를 감싼 브리지 구조체 MessageField로 만들었다. 새 메시지가 오면 입력창 영역도 확실히 새로 그려지게 하려고 아래처럼 한 줄을 덧붙였다.

```swift
VStack {
    MessageList(messages: messages, unread: unreadCount)
    MessageField(text: $draft)
        .id(unreadCount)
}
```

그 뒤로 입력하는 도중에 새 메시지가 도착하면 키보드가 내려가고 커서가 사라졌다. 입력하던 글자는 그대로 남아 있었다. MessageField의 생명주기 메서드마다 객체 주소를 찍은 로그는 아래와 같다.

```text
[unread=0] makeCoordinator  coordinator=0x6000a1
[unread=0] makeUIView       field=0x7f8b01
[unread=0] updateUIView     field=0x7f8b01  text="내일 3시에"
[unread=1] makeCoordinator  coordinator=0x6000c7
[unread=1] makeUIView       field=0x7f8e22
[unread=1] updateUIView     field=0x7f8e22  text="내일 3시에"
```', 'OBJECTIVE'),
       (5718, 923, '아래 코드에서 SwiftUI 배너 숫자가 바뀌지 않는 원인과 대응으로 옳은 것은?', '기존 UIKit 장바구니 화면 위쪽에 SwiftUI로 만든 요약 배너를 얹었다. 담기 버튼과 배지 라벨은 UIKit 쪽에 그대로 있다.

```swift
struct CartBanner: View {
    let count: Int
    var body: some View { Text("담은 상품 \(count)개") }
}

final class CartVC: UIViewController {
    private var count = 0
    private let badgeLabel = UILabel()
    private lazy var host = UIHostingController(rootView: CartBanner(count: count))

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }

    @objc func addTapped() {
        count += 1
        badgeLabel.text = "\(count)"
    }
}
```

담기 버튼을 세 번 누르자 UIKit 배지 라벨은 3이 됐지만, SwiftUI 배너는 계속 "담은 상품 0개"였다.', 'OBJECTIVE'),
       (5719, 923, '아래 측정 결과의 원인과 대응으로 옳은 것은?', '최소 지원 버전이 iOS 16인 기존 UIKit 앱의 공지 화면에서, 세로 스택 뷰(UIStackView) 가운데에 SwiftUI 카드 NoticeCard를 UIHostingController로 넣었다. addChild, 뷰 추가, didMove(toParent:)로 이어지는 자식 컨트롤러 등록 절차는 모두 지켰다. 카드 안의 "더 보기"를 누르면 SwiftUI 상태가 바뀌어 본문이 2줄에서 8줄로 펼쳐진다. 펼치기 전후의 높이를 재 보니 아래와 같았다.

| 상태 | SwiftUI 콘텐츠가 필요로 하는 높이 | 스택 뷰가 카드에 배정한 높이 | 화면 결과 |
|---|---|---|---|
| 접힘 | 96pt | 96pt | 정상 |
| 펼침 | 248pt | 96pt | 카드 아래쪽이 잘림, 카드 밑 UIKit 버튼은 제자리 |', 'OBJECTIVE'),
       (5720, 923, '아래 상황에서 공유 시트가 뜨지 않는 원인과 대응으로 옳은 것은?', 'SwiftUI 문서 화면 DocumentScreen에 UIKit PDF 뷰를 감싼 브리지 구조체를 넣었다. PDF 뷰 위에 얹은 UIKit 공유 버튼을 누르면 코디네이터의 아래 메서드가 공유 시트를 띄운다.

```swift
@objc func shareTapped() {
    let activity = UIActivityViewController(activityItems: [fileURL],
                                            applicationActivities: nil)
    pdfView.window?.rootViewController?.present(activity, animated: true)
}
```

DocumentScreen을 앱의 첫 화면으로 둘 때는 공유 시트가 잘 떴다. 그런데 목록 화면에서 .sheet로 DocumentScreen을 띄운 뒤 같은 버튼을 누르자, 공유 시트는 나타나지 않고 콘솔에 아래 경고만 남았다.

```text
Attempt to present <UIActivityViewController> on <UIHostingController<RootView>>
which is already presenting <PresentationHostingController<AnyView>>
```', 'OBJECTIVE'),
       (5721, 923, '아래 코드와 확인 결과에서 문제를 일으킨, 객체들 사이의 참조 관계를 가리키는 용어는?', 'UIKit 주문 상세 화면 안에 SwiftUI 영수증 뷰를 넣었다. 영수증 뷰의 닫기 버튼을 누르면 onClose 클로저가 불려 이전 화면으로 돌아간다.

```swift
final class OrderDetailVC: UIViewController {
    private var host: UIHostingController<ReceiptView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: ReceiptView(onClose: {
            self.navigationController?.popViewController(animated: true)
        }))
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        self.host = host
    }

    deinit { print("OrderDetailVC 해제") }
}
```

주문 상세 화면에 들어갔다가 닫기를 세 번 반복한 뒤 확인한 결과는 아래와 같다. 화면은 매번 정상적으로 닫혔다.

```text
"OrderDetailVC 해제" 출력: 0회
메모리 그래프: OrderDetailVC 3개, UIHostingController<ReceiptView> 3개가 살아 있음
```', 'SUBJECTIVE'),
       (5722, 923, '아래 수정으로 갱신 메서드가 갖추게 된 성질을 가리키는 용어는?', 'SwiftUI 기사 화면에 WKWebView를 감싼 브리지 구조체를 넣었다. 같은 기사를 읽는 동안 다크 모드 전환, 좋아요 수 변경, 글자 크기 조절이 이어져 부모 뷰가 여러 번 다시 평가됐다. 갱신 메서드를 아래처럼 고치기 전과 후를 같은 조작 순서로 비교했다.

```swift
// 수정 전
func updateUIView(_ webView: WKWebView, context: Context) {
    webView.load(URLRequest(url: url))
}

// 수정 후
func updateUIView(_ webView: WKWebView, context: Context) {
    if webView.url != url {
        webView.load(URLRequest(url: url))
    }
}
```

| 구분 | 갱신 메서드 호출 | 페이지 로드 | 읽던 스크롤 위치 | 최종 화면 |
|---|---|---|---|---|
| 수정 전 | 8회 | 8회 | 매번 맨 위로 돌아감 | 같은 기사 |
| 수정 후 | 8회 | 1회 | 유지됨 | 같은 기사 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5717
(15419, 5717, '갱신 메서드가 같은 문자열을 매번 다시 대입해 커서가 밀린 것이므로, 값이 달라졌을 때만 대입하도록 바꾸면 해결된다.', '로그에서 field 주소가 0x7f8b01에서 0x7f8e22로 바뀌었다. 커서가 밀린 것이 아니라 입력창 자체가 새것으로 바뀐 것이어서, 대입에 조건을 걸어도 사라진 포커스는 돌아오지 않는다.', false),
(15420, 5717, '식별값이 바뀌자 SwiftUI가 다른 뷰로 보고 코디네이터와 입력창을 새로 만들었다. 입력창에서 .id를 떼어 내야 포커스가 유지된다.', 'makeCoordinator와 makeUIView는 뷰 정체성이 생길 때 한 번 불린다. .id 값이 바뀌면 정체성이 새로 생겨 둘 다 다시 불리고, 글자는 Binding으로 다시 채워져도 포커스는 옛 입력창과 함께 버려진다.', true),
(15421, 5717, '코디네이터는 상태가 바뀔 때마다 새로 만들어지므로, 델리게이트를 updateUIView에서 매번 다시 연결하면 포커스가 유지된다.', '코디네이터는 뷰 정체성이 유지되는 동안 하나만 쓰인다. 로그에서 새로 만들어진 때는 .id 값이 바뀐 순간뿐이고, 델리게이트를 다시 연결해도 새 입력창에 포커스가 생기지는 않는다.', false),
(15422, 5717, '부모 body가 다시 평가되면 브리지 구조체는 항상 makeUIView부터 다시 실행되므로, 입력창을 UIKit 컨테이너로 옮겨야 한다.', 'body가 다시 평가될 때 반복해서 불리는 쪽은 updateUIView다. 재평가를 재생성으로 오해한 것이며, 로그에서 새 인스턴스가 생긴 것도 식별값이 바뀐 순간에 한정된다.', false),

-- 문제 5718
(15423, 5718, 'CartBanner가 값을 let으로 받아서 생긴 문제이므로, count를 @State로 선언하면 담을 때마다 배너 숫자가 올라간다.', '@State는 처음 받은 값으로 SwiftUI 저장소를 한 번 채운 뒤 그 값을 스스로 관리한다. VC의 count와 이어지는 통로가 생기지 않으므로 선언만 바꿔서는 여전히 0에 머문다.', false),
(15424, 5718, 'UIHostingController를 자식으로 등록하는 절차가 빠져 SwiftUI 쪽 갱신이 막혔으므로, addChild와 didMove(toParent:)를 추가한다.', 'viewDidLoad에 addChild, 뷰 추가, didMove(toParent:)가 모두 들어 있다. 등록 절차는 지켜졌고, 배너가 0에 머무는 것은 바뀐 값이 배너 쪽으로 전달될 경로가 없기 때문이다.', false),
(15425, 5718, 'count가 값 타입이라 복사된 것이므로, 정수를 평범한 클래스 인스턴스에 담아 넘기기만 하면 배너가 스스로 다시 그려진다.', '참조로 넘기면 같은 값을 가리키긴 하지만, SwiftUI는 관찰 가능한 객체로 표시된 변화만 감지해 body를 다시 평가한다. 평범한 클래스는 값이 바뀌어도 SwiftUI에 알리지 않는다.', false),
(15426, 5718, '배너는 만들 때 받은 0을 복사해 들고 있어 VC의 count와 이어져 있지 않다. 관찰 가능한 모델 하나를 한쪽이 소유하고 양쪽에 참조로 넘긴다.', 'rootView에 넘긴 Int는 값 복사라 이후 VC 프로퍼티를 바꿔도 배너에 닿지 않는다. @Observable 같은 관찰 가능한 모델을 VC가 소유하고 배너에 참조로 주면, 담을 때 모델만 바꿔도 SwiftUI가 다시 그린다.', true),

-- 문제 5719
(15427, 5719, '호스팅 뷰가 SwiftUI 콘텐츠의 크기 변화를 Auto Layout에 알리지 않는다. iOS 16 이상에서는 sizingOptions에 .intrinsicContentSize를 지정한다.', '기본 설정의 호스팅 뷰는 SwiftUI 콘텐츠가 커져도 고유 크기를 스스로 무효화하지 않아 스택 뷰가 처음 높이를 유지한다. 이 옵션을 켜면 이상적 크기가 바뀔 때마다 고유 크기가 무효화돼 높이가 다시 배정된다.', true),
(15428, 5719, '세이프 에어리어가 이중으로 적용돼 카드 안쪽 공간이 줄어든 것이므로, safeAreaRegions를 조정하면 카드가 늘어난다.', '세이프 에어리어 이중 적용은 위아래에 빈 여백이 생기는 문제다. 표에서는 여백이 아니라 스택 뷰가 배정한 높이 자체가 96pt에 멈춰 있으므로 원인이 다르다.', false),
(15429, 5719, 'SwiftUI 뷰는 처음 그려진 뒤에는 자기 크기를 바꿀 수 없으므로, 펼쳐지는 본문은 UIKit 라벨로 옮겨 그려야 한다.', '표에서 SwiftUI 콘텐츠가 필요로 하는 높이는 이미 248pt로 바뀌었다. SwiftUI 쪽은 크기 변화를 제대로 계산했고, 막힌 곳은 그 크기를 UIKit 레이아웃에 전달하는 경계다.', false),
(15430, 5719, '자식 컨트롤러로 등록한 탓에 부모가 카드 크기를 고정했으므로, addChild를 빼고 host.view만 붙이면 높이가 따라 늘어난다.', '자식 등록은 생명주기 호출과 세이프 에어리어 정보를 넘겨받기 위한 계약이지 크기를 고정하는 장치가 아니다. 등록을 빼도 높이 문제는 그대로 남고 화면 회전 같은 전달만 깨진다.', false),

-- 문제 5720
(15431, 5720, '공유 시트를 띄우는 일도 SwiftUI 상태 반영에 해당하므로, present 호출을 updateUIView 안으로 옮기면 뜬다.', 'updateUIView로 옮겨도 요청이 향하는 곳은 이미 시트를 띄운 루트 컨트롤러 그대로다. 게다가 반복 호출되는 갱신 메서드에 화면 표시 같은 부수 효과를 두면 재평가마다 다시 실행된다.', false),
(15432, 5720, '시트 안에서는 UIKit 뷰 컨트롤러를 띄울 수 없으므로, DocumentScreen을 .fullScreenCover로 띄우면 공유 시트가 뜬다.', '.fullScreenCover로 띄워도 루트 컨트롤러가 이미 다른 화면을 띄운 상태가 되는 것은 같다. 경고의 원인은 시트 종류가 아니라 표시 중인 컨트롤러에 또 표시를 요청한 것이다.', false),
(15433, 5720, 'UIView를 감싼 브리지 구조체에는 표시를 맡길 자기 뷰 컨트롤러가 없다. 코디네이터는 상태만 바꾸고, 표시는 .sheet 같은 SwiftUI 프레젠테이션에 맡긴다.', '브리지 구조체가 감싼 것은 UIView라 present를 부를 주체가 없고, 창의 루트를 빌려 쓰면 루트가 이미 시트를 띄운 순간 요청이 거절된다. SwiftUI가 표시 계층을 관리하게 하거나 UIViewControllerRepresentable로 감싼다.', true),
(15434, 5720, 'present가 메인 스레드 밖에서 불려 생긴 경고이므로, 호출을 DispatchQueue.main.async로 감싸면 공유 시트가 뜬다.', '버튼의 타깃 액션은 이미 메인 스레드에서 불린다. 다음 런루프로 미뤄도 요청 대상은 같은 루트 컨트롤러이고, 그 컨트롤러가 시트를 띄우고 있는 한 요청은 계속 거절된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1862, 5721, '순환 참조,강한 참조 순환,참조 순환,강한 순환 참조,강한 참조 사이클,순환참조,강한참조순환,retain cycle,reference cycle,strong reference cycle,리테인 사이클', 'OrderDetailVC는 host 프로퍼티와 자식 컨트롤러 목록으로 UIHostingController를 강하게 붙잡고, UIHostingController는 rootView인 ReceiptView를, ReceiptView는 onClose 클로저를 들고 있다. 그런데 이 클로저가 self를 그대로 캡처해 다시 OrderDetailVC를 강하게 가리키므로 참조가 고리 모양으로 닫힌다. ARC는 참조 카운트가 0이 될 때만 객체를 해제하므로, 화면을 닫아도 고리 안의 객체들이 서로의 카운트를 붙잡고 있어 deinit이 한 번도 불리지 않는다. 클로저를 [weak self]로 캡처해 고리의 한 곳을 약한 참조로 끊으면 해결된다. 결과로 나타나는 메모리 누수(memory leak)는 증상의 이름이고, 여러 스레드가 서로의 자원을 기다리며 멈추는 교착 상태(deadlock)와도 구분해 두자.'),
       (1863, 5722, '멱등성,멱등,멱등한 갱신,멱등한,멱등 갱신,idempotency,idempotence,idempotent', '같은 입력으로 몇 번을 호출해도 한 번 호출한 것과 결과가 같은 성질이 멱등성이다. 갱신 메서드는 부모 뷰가 다시 평가될 때마다 불리고 그 횟수는 개발자가 정하지 않으므로, 호출될 때마다 현재 상태와 비교해 달라진 것만 반영해야 한다. 표에서 수정 전후 호출 횟수는 8회로 같지만, 수정 후에는 로드가 1회로 줄고 스크롤 위치도 지켜졌다. 호출 자체를 줄이는 디바운싱(debounce)이나 스로틀링(throttle)과는 다르다. 이들은 짧은 시간에 몰린 호출을 묶거나 걸러 횟수를 줄이는 기법이지만, 여기서는 호출 횟수는 그대로 두고 반복 호출이 결과를 바꾸지 않게 만들었다. 결과를 저장해 두고 다시 쓰는 캐싱과도 구분한다.');
