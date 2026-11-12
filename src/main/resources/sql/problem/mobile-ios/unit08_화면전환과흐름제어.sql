-- Unit: 화면 전환과 흐름 제어 (Unit ID: 184)
-- Chapter: iOS (Chapter ID: 17)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (610, 184, '경로 상태와 흐름 소유권, 메모리 누수'),
       (768, 184, '딥 링크 경로 조립과 모달, 루트 교체'),
       (926, 184, '화면 전환과 흐름 제어 — 흐름 정리 시점·중첩 스택·딥링크 진입점');

-- =====================================================
-- Lesson 610: 경로 상태와 흐름 소유권, 메모리 누수
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3839, 610, '아래 코드가 모두 실행된 직후 path에 남아 있는 값의 개수는?', 'SwiftUI 화면 전환 경로를 조작하는 코드다. path는 값이 하나도 없는 상태에서 시작한다.

```swift
@State private var path = NavigationPath()   // 시작 시 값 0개

path.append(orderA)        // Order 값
path.append(orderB)        // Order 값
path.append(refundReq)     // RefundRequest 값
path.removeLast()
path.append(orderC)        // Order 값
path.removeLast(2)
```', 'OBJECTIVE'),
       (3840, 610, '아래처럼 화면 전환 책임을 나눈 구조에 대한 설명으로 옳은 것은?', 'UIKit 앱의 주문 흐름이다. AppFlow는 OrderFlow를 만들어 자신의 자식 목록에 담아 둔 뒤 start()를 호출한다.

```swift
final class OrderListVC: UIViewController {
    var onSelect: ((Order) -> Void)?
    func didSelect(order: Order) { onSelect?(order) }   // 일어난 일만 알린다
}

final class OrderFlow {
    private let navigation: UINavigationController
    private let container: DependencyContainer

    func start() {
        let list = container.makeOrderListVC()
        list.onSelect = { [weak self] order in self?.showDetail(order) }
        navigation.pushViewController(list, animated: false)
    }

    private func showDetail(_ order: Order) {
        let detail = container.makeOrderDetailVC(order: order)
        navigation.pushViewController(detail, animated: true)
    }
}
```', 'OBJECTIVE'),
       (3841, 610, '아래 표에 비추어 옳지 않은 것은?', 'UIKit에서 한 화면에서 다른 화면으로 넘어가는 네 가지 방식을 정리한 표다.

| 방식 | 대표 API | 특징 |
| --- | --- | --- |
| 스택 push/pop | UINavigationController.pushViewController | 뒤로 가기 내장, 계층적 탐색 |
| 모달 present/dismiss | UIViewController.present(_:animated:) | 독립 작업 흐름, modalPresentationStyle로 표시 방식 지정 |
| 탭 전환 | UITabBarController.selectedIndex | 나란히 놓인 최상위 흐름 사이 이동 |
| 컨테이너 교체 | addChild · removeFromParent | 커스텀 컨테이너, 온보딩에서 메인으로 갈아 끼우기 |', 'OBJECTIVE'),
       (3842, 610, '아래 화면 전환이 실패하는 원인으로 옳은 것은?', 'Order는 Hashable을 채택했고, 아래 코드는 경고 없이 빌드된다.

```swift
NavigationStack(path: $path) {
    List(orders) { order in
        NavigationLink("상세", value: order)
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(order: order)
            }
    }
}
```

증상: 목록 맨 위쪽 행을 누르면 상세 화면이 열린다. 그런데 아래로 한참 스크롤한 뒤 나온 행을 누르면 아무 일도 일어나지 않고, 콘솔에는 해당 값의 목적지를 찾지 못했다는 경고만 남는다.', 'OBJECTIVE'),
       (3843, 610, '아래 상황에서 발생한 문제를 가리키는 용어는?', 'UIKit 앱에서 회원가입 흐름에 들어갔다가 뒤로 가기 스와이프로 빠져나오기를 20번 반복했다. 화면은 모두 pop돼 눈앞에서 사라졌지만, 디버그 메모리 그래프에는 그 흐름을 맡았던 객체가 20개 그대로 잡히고 앱이 쓰는 메모리도 계속 우상향한다. 부모가 childCoordinators 배열에서 끝난 자식을 지우지 않은 탓이다.', 'SUBJECTIVE'),
       (3844, 610, '아래에서 새로 도입한 SwiftUI 내비게이션 컨테이너의 이름은?', 'iOS 15 시절에 만든 목록에서 상세, 상세에서 결제로 이어지는 화면이 있다. 푸시 알림을 눌러 결제 화면까지 한 번에 열려고 isActive 바인딩을 겹쳐 썼더니 중간 화면이 깜빡이거나 두 번째 전환이 통째로 무시되는 일이 잦았다. 배포 타깃을 iOS 16으로 올리고 루트를 바꾼 뒤로는 경로 값 배열 하나를 통째로 대입하는 것만으로 세 화면이 정확히 쌓였고, 그 배열을 파일로 저장해 두었다가 앱 재시작 때 되돌려 넣자 보던 깊이까지 그대로 복원됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3839
(10411, 3839, '0', '마지막 removeLast(2)를 경로를 통째로 비우는 동작으로 오해한 값이다. 인자는 뒤에서 지울 개수를 뜻하므로 3개 중 2개만 빠진다. 전부 비우려면 path = NavigationPath()처럼 새 경로를 대입한다.', false),
(10412, 3839, '1', 'append가 네 번이라 최대 3개까지 쌓였다가, removeLast()로 1개, removeLast(2)로 2개가 빠져 4 - 3 = 1개가 남는다. 값 타입이 Order와 RefundRequest로 섞여도 경로 길이는 넣고 뺀 횟수로만 정해진다.', true),
(10413, 3839, '2', '마지막 removeLast(2)를 인자 없는 pop 한 번으로 세어 하나만 뺀 값이다. 인자를 주면 그 개수만큼 뒤에서 한꺼번에 빠진다.', false),
(10414, 3839, '4', 'append 네 번만 세고 removeLast 호출을 빠뜨린 값이다. 경로는 배열처럼 넣은 만큼 늘고 뺀 만큼 줄어드는 데이터라 pop도 길이에 반영된다.', false),

-- 문제 3840
(10415, 3840, '목록 화면이 상세 화면을 직접 만들어 push하므로 두 화면의 의존 관계는 그대로 남는다.', '화면이 다음 화면을 직접 생성하던 구조를 그대로 갖다 붙인 오해다. 본문의 목록 화면은 onSelect로 선택 사실만 넘길 뿐 상세 화면의 타입도 생성 방법도 모른다.', false),
(10416, 3840, '사용자가 뒤로 가기 스와이프로 흐름을 빠져나가면 OrderFlow도 함께 정리된다.', 'UIKit 내비게이션 스택은 pop이 일어났다는 사실을 흐름 객체에 알려주지 않는다. UINavigationControllerDelegate의 didShow로 pop을 감지하거나 화면의 완료 콜백을 받아 직접 정리해야 한다.', false),
(10417, 3840, 'AppFlow가 끝난 OrderFlow를 자식 목록에서 지우지 않으면 화면이 모두 pop된 뒤에도 객체가 남는다.', '흐름 객체의 수명은 화면 스택이 아니라 부모가 쥔 참조가 정한다. 화면이 사라져도 부모 배열이 붙들고 있으면 해제되지 않으므로, 흐름 종료 시점에 부모가 참조를 끊어 줘야 한다.', true),
(10418, 3840, '목록 화면만 따로 테스트하려면 실제 UINavigationController를 함께 구성해야 한다.', '전환은 흐름 객체가 맡고 화면은 onSelect 호출까지만 책임진다. 선택했을 때 클로저가 불렸는지만 확인하면 되므로 내비게이션 스택 없이도 화면을 검증할 수 있다.', false),

-- 문제 3841
(10419, 3841, '상세 화면에 뒤로 가기 버튼을 따로 붙이지 않아도 되는 것은 화면을 스택에 쌓아 올리기 때문이다.', '참인 진술이다. push는 이전 화면을 아래에 남긴 채 새 화면을 얹으므로 되돌아갈 경로가 그대로 있고, 그래서 뒤로 가기가 기본으로 제공된다.', false),
(10420, 3841, '같은 화면을 아래쪽 절반만 덮게 띄울지 전체를 덮게 띄울지는 띄우는 쪽에서 정한다.', '참인 진술이다. present는 modalPresentationStyle로 표시 방식을 고르므로 같은 화면이라도 시트로도, 전체 화면으로도 올릴 수 있다.', false),
(10421, 3841, '온보딩을 마치고 메인으로 넘어가며 뒤로 가기를 아예 막으려면 자식 뷰 컨트롤러를 갈아 끼우면 된다.', '참인 진술이다. addChild와 removeFromParent로 자식을 교체하면 이전 화면이 스택에 남지 않아 되돌아갈 경로 자체가 사라진다.', false),
(10422, 3841, '로그인처럼 목록과 무관한 독립 작업을 띄울 때는 selectedIndex 값을 바꾸는 방식이 표준이다.', '거짓이라 정답이다. selectedIndex는 나란히 놓인 최상위 흐름 사이를 오갈 때 쓰는 수단이다. 시작과 끝이 뚜렷한 독립 작업은 present로 띄우고 dismiss로 닫는 모달이 제자리다.', true),

-- 문제 3842
(10423, 3842, '목록 행이 화면에 보일 때 만들어지는 탓에 목적지 선언이 등록되지 않은 행이 생긴다.', 'navigationDestination은 그 선언이 붙은 뷰가 실제로 만들어져야 스택에 등록된다. List 행은 필요할 때 지연 생성되므로 아직 그려지지 않은 행에는 선언이 없다. 선언을 스택 루트 근처로 올려 한 번만 두면 된다.', true),
(10424, 3842, 'Order가 Hashable을 채택하지 않아 값을 경로에 넣을 수 없다.', '값 기반 링크에 Hashable이 필요한 것은 맞지만 본문의 Order는 이미 채택했고, 빠졌다면 실행이 아니라 빌드 단계에서 걸린다. 스크롤 위치에 따라 결과가 갈리는 증상도 설명하지 못한다.', false),
(10425, 3842, 'path를 @State가 아니라 @Binding으로 선언해야 경로 변경이 스택에 전달된다.', '경로를 소유한 뷰는 @State로 두고 스택에 $path로 넘기는 것이 정상 사용법이다. @Binding은 경로를 다른 곳에서 받아 쓸 때 필요하며, 여기서는 전환 실패와 무관하다.', false),
(10426, 3842, 'NavigationLink에 목적지 뷰 대신 값을 넘겨서 어디로 갈지가 정해지지 않는다.', '값만 넘기는 링크는 iOS 16 이후의 정상 사용법으로, 어디로 갈지는 타입별 navigationDestination(for:)가 정한다. 목적지를 링크마다 박아 넣던 이전 방식이 오히려 프로그래밍 전환에 약했다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1236, 3843, '메모리 누수,메모리누수,메모리 릭,memory leak,memoryleak,누수,leak', '쓸 일이 없어진 객체를 누군가 계속 붙들고 있어 회수되지 못한 메모리가 쌓이는 현상이 메모리 누수다. 여기서 붙들고 있는 주체는 부모가 쥔 강한 참조 하나이며, 두 객체가 서로를 강하게 참조해 함께 못 죽는 강한 참조 순환(retain cycle)과는 원인이 다르다. 화면이 pop된 것이 곧 흐름 종료를 뜻하지는 않으므로, UINavigationControllerDelegate의 didShow로 pop을 감지하거나 흐름 완료 콜백을 받아 부모가 자식을 목록에서 제거해 수명을 끊어 줘야 한다.'),
       (1237, 3844, 'NavigationStack,navigation stack,내비게이션스택,내비게이션 스택,네비게이션스택,네비게이션 스택', '경로를 Hashable 값의 배열로 들고 다니며 화면 전환을 상태 변경으로 다루는 iOS 16 이상의 컨테이너가 NavigationStack이다. 배열을 통째로 갈아 끼울 수 있어 여러 단계를 한 번에 여는 딥링크와 상태 복원이 같은 코드 경로를 탄다. 목적지 뷰를 링크마다 박아 넣어 다단계 전환이 불안정했던 NavigationView와 NavigationLink(destination:) 조합은 iOS 16에서 deprecated 됐다. 경로 값을 담는 타입인 NavigationPath는 이 컨테이너에 넘기는 데이터이지 컨테이너 자체가 아니라는 점도 구분한다.');

-- =====================================================
-- Lesson 768: 딥 링크 경로 조립과 모달, 루트 교체
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4787, 768, '아래 상황에서 사용자가 뒤로 가기를 한 번 했을 때의 화면과 router.path로 옳은 것은?', '앱이 꺼져 있던 상태에서 알림의 gravit://orders/42/refund 주소로 실행돼 아래 코드가 그대로 동작했다. 화면에는 환불 요청 화면이 떠 있고, 그 위에서 사용자가 시스템 뒤로 가기 제스처를 한 번 한다.

```swift
enum OrderRoute: Hashable {
    case detail(Order)
    case refund(RefundRequest)
}

@Observable
final class OrderRouter {
    var path: [OrderRoute] = []              // 시작 시 빈 배열

    func handle(deepLink url: URL) {         // gravit://orders/42/refund
        path = [.detail(Order(id: 42)), .refund(RefundRequest(orderID: 42))]
    }
}

struct OrderFlowView: View {
    @State private var router = OrderRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            OrderListView()                                   // 루트: 주문 목록
                .navigationDestination(for: OrderRoute.self) { route in
                    switch route {
                    case .detail(let order): OrderDetailView(order: order)
                    case .refund(let req):   RefundView(request: req)
                    }
                }
        }
        .onOpenURL { router.handle(deepLink: $0) }
    }
}
```', 'OBJECTIVE'),
       (4788, 768, '아래 비교표에서 따라 나오는 결과로 옳은 것은?', 'SwiftUI 화면 전환 방식 두 가지를 정리한 표다.

| 항목 | 왼쪽: NavigationView + NavigationLink(destination:) | 오른쪽: NavigationStack + NavigationPath |
| --- | --- | --- |
| 스택 표현 | 뷰 계층 안에 암묵적 | Hashable 값 배열로 명시적 |
| 프로그래밍 전환 | isActive 바인딩, 여러 단계 push가 불안정 | 배열에 넣고 빼며 자유롭게 |
| 목적지 결정 | 링크마다 목적지 뷰를 지정 | navigationDestination(for:)에서 값 타입별로 한 번 |
| 상태 복원 | 어려움 | 경로의 codable 표현을 저장해 되돌릴 수 있음 |
| 가용 버전 | iOS 13+ (iOS 16에서 deprecated) | iOS 16+ |', 'OBJECTIVE'),
       (4789, 768, '아래 모달 표시에서 나타난 증상의 원인으로 옳은 것은?', '주문 목록에서 행을 누르면 편집 화면을 모달로 띄우려고 만든 코드다.

```swift
struct OrderListView: View {
    let orders: [Order]
    @State private var isEditorShown = false
    @State private var editingOrder: Order?

    var body: some View {
        List(orders) { order in
            Button(order.title) {
                editingOrder = order
                isEditorShown = true
            }
        }
        .sheet(isPresented: $isEditorShown) {
            OrderEditView(order: editingOrder)     // 값이 없으면 빈 화면을 그린다
        }
    }
}
```

증상: 앱을 켜고 맨 처음 누른 행은 내용이 비어 있는 편집 화면이 뜬다. 그 뒤로도 방금 누른 주문이 아니라 직전에 눌렀던 주문이 보일 때가 있다. 스크롤 위치와는 상관없이 첫 행에서도 같은 증상이 난다.', 'OBJECTIVE'),
       (4790, 768, '아래 요구를 모두 만족하는 UIKit 화면 전환 방식은?', '온보딩을 마치면 메인 탭 화면으로 넘어가는 전환을 설계한다. 기획이 내건 조건은 셋이다.

- 온보딩 3단계를 마치면 메인 탭 화면이 앱의 첫 화면 자리에 놓인다.
- 메인에서 뒤로 가기 버튼이나 스와이프로 온보딩에 되돌아갈 수 없어야 한다.
- 전환이 끝나면 온보딩 화면 객체들은 메모리에서 해제돼야 한다. 다만 로그아웃하면 온보딩부터 다시 시작한다.

현재 온보딩 3단계는 UINavigationController 하나에 쌓여 있고, 메인 탭 화면은 아직 만들어지지 않았다.', 'OBJECTIVE'),
       (4791, 768, '아래 리팩터링에서 도입한 UIKit 설계 패턴의 이름은?', '주문 목록 화면 하나를 일반 구매·선물하기·정기 배송 세 흐름이 함께 쓴다.

리팩터링 전: 목록 화면 안에 다음 화면을 고르는 if 문이 12갈래로 늘어나 화면 파일이 940줄이었다. 흐름이 하나 늘 때마다 이 파일을 또 고쳤고, 목록만 테스트하려 해도 상세·결제 화면과 그 의존성을 전부 준비해야 했다. 선물하기 순서를 바꾼 배포에서 일반 구매가 함께 깨진 적도 있다.

리팩터링 후: 목록 화면은 320줄이 됐고, 밖으로 내보내는 것은 onSelect(order) 클로저 하나뿐이다. 흐름별로 따로 만든 객체 세 개가 앱 시작 지점의 객체 아래 트리로 묶이고, 흐름이 끝나면 부모가 자식 배열에서 그 객체를 지운다. 네 번째 흐름을 붙일 때 목록 화면 코드는 한 줄도 바뀌지 않았고, 목록 테스트는 클로저가 불렸는지만 확인한다.', 'SUBJECTIVE'),
       (4792, 768, '아래 빌드 오류를 없애려고 SwiftUI 결제 화면을 감싼 UIKit 타입의 이름은?', '기존 UIKit 앱의 주문 흐름에서 결제 화면만 SwiftUI로 새로 만들었다. 흐름을 맡은 객체가 쓰던 전환 코드는 그대로 두고 화면만 바꿔 끼우려 했더니 빌드가 멈췄다.

```swift
let payment = PaymentView(order: order)              // SwiftUI View
navigation.pushViewController(payment, animated: true)
```

```
error: cannot convert value of type ''PaymentView'' to expected argument type ''UIViewController''
```

아래처럼 한 줄을 감싸자 오류가 사라졌다. 결제 화면은 UIKit 내비게이션 스택의 세 번째 화면으로 올라갔고, 위쪽 뒤로 가기 버튼과 가장자리 스와이프가 그대로 동작했다.

```swift
let payment = ____(rootView: PaymentView(order: order))
navigation.pushViewController(payment, animated: true)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4787
(12939, 4787, '주문 목록 화면으로 돌아가고 router.path는 빈 배열이 된다.', '경로를 한 번에 대입했으니 뒤로 가기도 루트까지 한 번에 되돌린다고 본 오해다. 스택에는 목록·상세·환불 세 장이 쌓여 있어 뒤로 가기는 맨 위 한 장만 걷어 낸다. 루트로 단번에 가려면 path를 빈 배열로 만들어야 한다.', false),
(12940, 4787, '주문 상세 화면이 보이고 router.path에는 .detail 하나만 남는다.', '경로 배열에 값이 둘이므로 루트 위에 상세·환불 두 화면이 쌓인 상태다. 뒤로 가기는 맨 위 한 장을 덜어 내고, 스택을 $router.path로 묶어 뒀으니 배열에서도 .refund가 빠진다. 남은 .detail의 목적지인 상세 화면이 드러난다.', true),
(12941, 4787, '주문 상세 화면이 보이지만 router.path에는 .detail과 .refund가 그대로 남는다.', '화면 스택과 경로 배열이 따로 논다고 본 오해다. 배열은 스택을 그린 그림이 아니라 스택의 상태 그 자체이며, 바인딩으로 넘겼으므로 사용자가 직접 pop해도 배열이 같은 크기로 줄어든다.', false),
(12942, 4787, '환불 요청 화면이 그대로 남고 router.path도 두 값 그대로다.', '배열을 통째로 대입하면 중간 화면 없이 마지막 화면만 뜬다고 본 오해다. 값 하나가 화면 하나여서 상세 화면이 실제로 스택에 끼어 있고, 그래서 돌아갈 자리가 있다.', false),

-- 문제 4788
(12943, 4788, '왼쪽 방식도 경로를 파일에 저장해 두면 앱을 다시 켤 때 쌓여 있던 화면 깊이를 그대로 되살릴 수 있다.', '왼쪽은 스택이 뷰 계층 안에 암묵적으로만 있어 저장할 경로 값 자체가 없다. 되살리기는 스택을 데이터로 들고 있는 쪽에서만 나오는 결과다.', false),
(12944, 4788, '배포 타깃이 iOS 14인 앱도 오른쪽 방식으로 바꾸면 여러 단계 전환을 안정적으로 처리할 수 있다.', '오른쪽은 iOS 16부터 쓸 수 있어 iOS 14 기기에서는 선택지가 되지 못한다. 낮은 타깃을 유지해야 하면 왼쪽을 쓰거나 버전에 따라 갈라 구현해야 한다.', false),
(12945, 4788, '왼쪽 방식에서 화면 세 개를 한 번에 열려면 isActive 바인딩 하나를 true로 바꾸면 된다.', 'isActive는 링크 하나의 활성 여부라 단계마다 바인딩이 따로 필요하고, 겹쳐 켜면 중간 화면이 건너뛰어지거나 무시되기 쉽다. 표가 여러 단계 push를 불안정하다고 적은 이유다.', false),
(12946, 4788, '오른쪽 방식에서는 어떤 값 타입이 도착할 화면을 바꿔도 그 값을 push하는 링크 쪽 코드는 손대지 않아도 된다.', '목적지가 링크가 아니라 값 타입별 선언 한 곳에서 정해지므로, 목록·검색·알림 등 여러 곳에서 같은 값을 push해도 도착 화면은 한 군데만 고치면 바뀐다. 왼쪽은 링크마다 목적지 뷰가 박혀 있어 전부 찾아 고쳐야 한다.', true),

-- 문제 4789
(12947, 4789, '열지 말지를 정하는 상태와 무엇을 보여줄지 담은 상태가 따로 있어, 시트 본문을 만들 때 둘이 같은 값을 가리킨다는 보장이 없다.', '표시 여부만 참으로 바뀌어도 시트는 열리므로 편집 대상이 아직 반영되지 않은 채 본문이 만들어질 수 있다. 옵셔널 값 하나가 곧 표시 여부가 되는 sheet(item:)을 쓰면 값과 표시가 한 상태로 묶여 어긋날 수 없다.', true),
(12948, 4789, 'List가 행을 지연 생성하는 탓에 아직 그려지지 않은 행의 Button 동작이 등록되지 않았다.', '지연 생성은 화면 밖 행이 아직 만들어지지 않았다는 뜻인데, 눌린 행은 이미 만들어져 동작이 붙어 있다. 스크롤과 무관하게 첫 행에서도 증상이 난다는 점이 이 설명을 배제한다.', false),
(12949, 4789, 'editingOrder를 @State가 아니라 @Binding으로 선언해야 시트 쪽에 값이 전달된다.', '값을 직접 소유한 뷰는 @State로 두는 것이 정상이고, @Binding은 다른 뷰가 가진 값을 받아 쓸 때 쓴다. 선언을 바꿔도 표시 여부와 값이 두 상태로 갈라져 있는 구조는 그대로다.', false),
(12950, 4789, '시트는 한 뷰에 하나만 붙일 수 있어 목록 행마다 붙은 시트가 서로 덮어쓴다.', '행마다 시트를 붙이면 실제로 문제가 되지만, 본문의 시트는 행이 아니라 List 바깥에 하나만 붙어 있어 덮어쓸 상대가 없다. 증상의 원인을 잘못 짚은 선지다.', false),

-- 문제 4790
(12951, 4790, '온보딩이 쌓여 있는 내비게이션 컨트롤러에 메인 탭 화면을 pushViewController로 얹는다.', 'push는 이전 화면을 아래에 남겨 두는 방식이라 온보딩 3단계가 그대로 살아 있고 되돌아갈 경로도 남는다. 세 조건 중 두 개를 어긴다.', false),
(12952, 4790, '메인 탭 화면을 present로 전체 화면 모달로 띄우고 온보딩은 그 아래에 둔다.', '모달은 아래 화면을 덮을 뿐 없애지 않으므로 온보딩 화면 객체가 그대로 유지된다. 모달은 시작과 끝이 뚜렷한 독립 작업을 띄울 때 제자리를 찾는다.', false),
(12953, 4790, '루트 컨테이너가 자식 뷰 컨트롤러를 온보딩에서 메인 탭 화면으로 갈아 끼운다.', 'addChild와 removeFromParent로 자식을 교체하면 이전 화면이 스택에도 아래에도 남지 않아 되돌아갈 경로가 사라지고 참조가 끊겨 해제된다. 로그아웃 때는 반대 방향으로 한 번 더 갈아 끼우면 된다.', true),
(12954, 4790, '탭 바 컨트롤러에 온보딩과 메인을 탭으로 나란히 넣고 selectedIndex를 메인 쪽으로 바꾼다.', '탭 전환은 나란히 놓인 최상위 흐름 사이를 오갈 때 쓰는 수단이고, 선택되지 않은 탭의 화면은 그대로 살아 있다. 온보딩 탭이 남아 아무 때나 돌아갈 수 있다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1552, 4791, '코디네이터 패턴,코디네이터패턴,코디네이터,Coordinator 패턴,Coordinator패턴,Coordinator,coordinator pattern,coordinatorpattern', '화면에서 흐름 제어와 다음 화면 생성 책임을 떼어 내 따로 세운 객체가 코디네이터이고, 이 구조를 코디네이터 패턴이라 부른다. 화면은 무슨 일이 일어났는지만 알리므로 같은 목록 화면이 세 흐름에 그대로 쓰이고, 테스트는 클로저 호출 여부만 보면 끝난다. 화면이 이벤트를 알리는 수단인 델리게이트·클로저는 이 패턴을 이루는 부품일 뿐 패턴 자체가 아니며, 화면 상태와 표현 로직을 나누는 MVVM은 흐름의 소유권 문제를 풀지 않는다는 점에서 구분한다. 다만 흐름이 끝났을 때 부모가 자식을 배열에서 지우지 않으면 화면이 pop된 뒤에도 객체가 남아 메모리가 새므로, pop 감지나 완료 콜백으로 수명을 끊어 줘야 한다.'),
       (1553, 4792, 'UIHostingController,uihostingcontroller,UIHostingController(rootView:),호스팅 컨트롤러,호스팅컨트롤러,유아이호스팅컨트롤러', 'SwiftUI 뷰를 UIViewController 자리에 끼워 주는 어댑터가 UIHostingController다. rootView로 감싸고 나면 보통의 뷰 컨트롤러와 같아서 push·present는 물론 자식으로 붙이는 것도 된다. 반대로 UIKit 화면을 SwiftUI 안에 넣을 때 쓰는 UIViewRepresentable·UIViewControllerRepresentable과는 감싸는 방향이 반대라는 점을 구분한다. 이렇게 올린 SwiftUI 화면의 전환은 UIKit 쪽 흐름 객체가 소유하므로, 그 안에 NavigationStack을 또 두면 내비게이션 바가 겹치고 뒤로 가기가 두 스택으로 갈려 흐름 객체가 전환을 놓친다.');

-- =====================================================
-- Lesson 926: 화면 전환과 흐름 제어 — 흐름 정리 시점·중첩 스택·딥링크 진입점
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5735, 926, '아래 코드에서 RefundCoordinator가 childCoordinators에서 지워지는 경우는?', '주문 흐름 객체 OrderCoordinator가 내비게이션 컨트롤러의 delegate로 등록돼 있다. 현재 스택은 주문 목록 → 주문 상세 → 환불 요청(RefundVC) 순이고, 환불 요청 화면은 자식 흐름 객체 RefundCoordinator가 띄웠다. 모든 전환은 애니메이션과 함께 일어난다.

```swift
extension OrderCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigation: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        // 방금 끝난 전환에서 떠나온 화면
        guard let from = navigation.transitionCoordinator?
                .viewController(forKey: .from) else { return }

        if navigation.viewControllers.contains(from) { return }

        if from is RefundVC {
            childCoordinators.removeAll { $0 is RefundCoordinator }
        }
    }
}
```', 'OBJECTIVE'),
       (5736, 926, '아래 세 증상을 모두 없애는 수정으로 옳은 것은?', 'UIKit으로 만든 주문 흐름에서 쿠폰 화면만 SwiftUI로 새로 만들어 주문 상세 다음에 붙였다. 흐름 객체 OrderCoordinator는 화면을 push할 때마다 기록을 남긴다.

```swift
// OrderCoordinator (UIKit)
func showCoupons() {
    let host = UIHostingController(rootView: CouponListView())
    navigation.pushViewController(host, animated: true)
    log("push: 쿠폰 목록")
}

// CouponListView (SwiftUI)
var body: some View {
    NavigationStack {
        List(coupons) { coupon in
            NavigationLink(coupon.name, value: coupon)
        }
        .navigationDestination(for: Coupon.self) { CouponDetailView(coupon: $0) }
    }
}
```

증상
1. 쿠폰 목록 위쪽에 내비게이션 바가 두 줄로 겹쳐 보인다.
2. 쿠폰 상세에서 맨 위 바의 뒤로 가기를 누르면 쿠폰 목록을 건너뛰고 주문 상세로 돌아간다.
3. 흐름 객체의 기록에 쿠폰 상세 화면이 한 번도 남지 않는다.', 'OBJECTIVE'),
       (5737, 926, '아래 SwiftUI 흐름 설계에 대한 설명으로 옳은 것은?', '경로를 화면의 @State에 두지 않고, 경로 배열 path를 가진 관찰 가능한 객체를 따로 만든다. 이 객체의 path를 NavigationStack에 바인딩하고, 객체 자체는 환경(environment)으로 하위 뷰 전체에 주입한다. 경로의 각 값은 .detail(Order)·.refund(RefundRequest) 같은 enum 케이스이고, 화면은 이 객체의 showDetail(_:) 같은 메서드만 호출한다. 케이스마다 어떤 뷰를 그릴지는 스택 루트의 navigationDestination(for:) 한 곳에서 정한다.', 'OBJECTIVE'),
       (5738, 926, '아래 테스트 결과로 미루어 볼 때 딥링크 처리 코드의 상태로 옳은 것은?', '알림을 누르면 gravit://orders/42/refund 주소로 주문 42의 환불 요청 화면을 여는 기능을 테스트했다. 기대 결과는 주문 목록 → 주문 42 상세 → 환불 요청 세 화면이 쌓이는 것이다.

| 알림을 누를 때 앱 상태 | 실제 결과 |
| --- | --- |
| 완전히 꺼져 있음 | 주문 목록 → 주문 42 상세 → 환불 요청이 쌓인다 |
| 백그라운드 (주문 7 상세를 보던 중) | 앱만 앞으로 나오고 주문 7 상세가 그대로 보인다 |
| 화면에 떠 있음 (주문 목록을 보던 중) | 알림 배너를 눌러도 화면이 바뀌지 않는다 |', 'OBJECTIVE'),
       (5739, 926, '아래 빈칸에 들어간 SwiftUI 타입의 이름은?', '주문 흐름의 경로를 처음에는 Order 배열로 선언했다. 환불 화면을 붙이려고 RefundRequest 값도 같은 경로에 넣자 빌드가 멈췄다.

```swift
@State private var path: [Order] = []

path.append(order)           // Order 값
path.append(refundRequest)   // RefundRequest 값
```

```
error: cannot convert value of type ''RefundRequest'' to expected argument type ''Order''
```

선언 한 줄만 아래처럼 바꾸자 두 append 줄은 손대지 않고도 빌드됐다. Order 값과 RefundRequest 값이 넣은 순서대로 스택에 쌓였고, 각 값은 타입별로 선언해 둔 navigationDestination(for:)가 그렸다.

```swift
@State private var path = ____()

NavigationStack(path: $path) { ... }
```', 'SUBJECTIVE'),
       (5740, 926, '아래 상황을 일으킨 참조 형태를 가리키는 용어는?', '주문 흐름 객체와 목록 화면에 해제 로그를 달았다.

```swift
final class OrderCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigation: UINavigationController
    private let container: DependencyContainer
    private var list: OrderListVC?      // 나중에 목록을 새로고침하려고 보관

    func start() {
        let list = container.makeOrderListVC()
        list.onSelect = { order in self.showDetail(order) }
        self.list = list
        navigation.pushViewController(list, animated: true)
    }

    deinit { print("OrderCoordinator 해제") }
}
// OrderListVC에도 deinit { print("OrderListVC 해제") }가 있다.
```

사용자가 뒤로 가기로 주문 흐름을 빠져나오면 목록 화면은 내비게이션 스택에서 빠지고, 부모 흐름 객체도 childCoordinators에서 OrderCoordinator를 지운다. 그런데 두 해제 로그는 끝내 찍히지 않는다. 클로저를 { [weak self] order in self?.showDetail(order) }로 바꾸자 뒤로 가기 직후 두 로그가 모두 찍혔다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5735
(15467, 5735, '환불 요청 화면 위에 사진 첨부 화면을 push해 사진 첨부 화면이 보일 때', '떠나온 화면은 RefundVC가 맞지만, push는 아래 화면을 스택에 남겨 두므로 contains 검사에서 곧바로 return한다. 화면이 가려진 것을 흐름이 끝난 것으로 본 오해다.', false),
(15468, 5735, '사진 첨부 화면에서 뒤로 가기로 환불 요청 화면에 돌아왔을 때', '사진 첨부 화면은 pop돼 스택에서 빠졌으므로 contains 검사는 통과하지만, 떠나온 화면이 RefundVC가 아니어서 마지막 조건에 걸린다. pop이면 무조건 정리된다고 본 오해다.', false),
(15469, 5735, '환불 요청 화면에서 가장자리 스와이프로 주문 상세 화면에 돌아왔을 때', '떠나온 화면이 RefundVC이고 pop으로 스택에서 빠졌으니 두 검사를 모두 통과한다. 시스템 뒤로 가기는 흐름 객체에 따로 알려 주지 않으므로, 이렇게 didShow에서 pop을 감지해 부모가 자식 참조를 끊어야 누수가 없다.', true),
(15470, 5735, '환불 요청 화면 위에 제출 확인 알림을 present로 띄웠을 때', 'present는 내비게이션 스택을 건드리지 않는 모달 전환이라 이 delegate 메서드가 불리지 않는다. 설령 불리더라도 RefundVC가 스택에 그대로 있어 정리 대상이 아니다.', false),

-- 문제 5736
(15471, 5736, 'CouponListView의 NavigationStack을 걷어 내고, 쿠폰을 누르면 클로저로 알려 OrderCoordinator가 상세 화면을 감싸 push하게 한다.', 'UIKit 스택 위에 올린 SwiftUI 화면 안에 스택이 하나 더 생겨 전환이 흐름 객체 모르게 안쪽에서 일어났다. 안쪽 스택을 없애고 전환을 흐름 객체로 모으면 바가 한 줄이 되고, 뒤로 가기도 한 칸씩 되며 기록도 남는다.', true),
(15472, 5736, 'navigationDestination 선언을 NavigationStack 바깥으로 옮겨 쿠폰 목적지 선언이 흐름 전체에서 한 곳에만 있게 한다.', '목적지 선언은 스택 안의 뷰에 붙어야 등록되므로 바깥으로 빼면 쿠폰 상세로 가는 전환마저 끊긴다. 선언 위치 문제와 스택이 둘로 갈린 문제를 혼동한 선지다.', false),
(15473, 5736, 'UIHostingController 대신 UIViewControllerRepresentable로 쿠폰 화면을 감싸 OrderCoordinator가 그대로 push하게 한다.', 'UIViewControllerRepresentable은 UIKit 뷰 컨트롤러를 SwiftUI 안에 넣을 때 쓰는 반대 방향 어댑터라, SwiftUI 화면을 UIKit 스택에 올리는 데 쓸 수 없다. 감싸는 방향을 혼동한 오해다.', false),
(15474, 5736, 'OrderCoordinator가 쿠폰 화면을 push 대신 present로 띄워 위쪽 내비게이션 바가 한 줄만 보이게 한다.', '모달로 띄우면 UIKit 바가 빠져 겹침은 사라지지만, 쿠폰 상세 전환은 여전히 안쪽 스택에서 일어나 흐름 객체의 기록에 남지 않는다. 셋째 증상이 그대로 남는다.', false),

-- 문제 5737
(15475, 5737, '목록 화면이 상세로 넘어가려면 상세 화면의 타입을 알고 있어야 showDetail(_:)에 넘길 수 있다.', '목록 화면이 넘기는 것은 Order 값뿐이고, 그 값을 어떤 뷰로 그릴지는 스택 루트의 선언이 정한다. 화면이 다음 화면을 직접 만들던 구조를 겹쳐 본 오해다.', false),
(15476, 5737, '깊은 곳의 하위 화면이 전환을 일으키려면 부모에게서 경로 바인딩을 단계마다 넘겨받아야 한다.', '경로를 한 뷰의 @State에 둘 때 생기는 번거로움이다. 객체를 환경으로 주입했으므로 어느 깊이의 화면이든 그 객체를 꺼내 메서드를 부르면 되고, 중간 화면이 바인딩을 넘겨줄 필요가 없다.', false),
(15477, 5737, '전환이 일어날 때마다 이 객체가 다음 화면의 뷰 인스턴스를 만들어 스택에 직접 넣는다.', '이 객체는 경로 값만 바꿀 뿐 뷰를 만들지 않는다. 값이 쌓이면 navigationDestination이 그 값에 맞는 뷰를 그린다. 뷰 컨트롤러를 만들어 push하는 UIKit 흐름 객체의 동작을 그대로 옮겨 온 오해다.', false),
(15478, 5737, '화면을 하나도 띄우지 않고 메서드를 부른 뒤 path 배열만 기대값과 비교하는 단위 테스트로 흐름을 검증할 수 있다.', '경로가 뷰 바깥의 평범한 객체 안에 enum 배열로 들어 있어, 메서드 호출 뒤 배열만 비교하면 어떤 화면이 쌓일지 확인된다. 경로가 뷰의 @State 안에 있으면 뷰를 띄우지 않고는 확인하기 어렵다.', true),

-- 문제 5738
(15479, 5738, 'URL을 경로로 바꾸는 코드가 환불 요청 화면 하나만 현재 스택 위에 얹도록 짜여 있다.', '앱이 꺼져 있을 때는 목록·상세·환불 세 화면이 제대로 쌓였으므로 경로 조립 자체는 맞다. 조립 결과가 아니라 조립 코드가 불리는 시점을 봐야 한다.', false),
(15480, 5738, 'URL을 경로로 바꾸는 코드가 앱이 새로 시작할 때만 불리고, 실행 중 URL을 받는 쪽에는 연결돼 있지 않다.', '앱이 새로 뜰 때만 결과가 맞고 이미 떠 있는 동안은 아무 변화가 없다. URL을 경로 배열로 바꾸는 함수를 흐름 객체 한 곳에 두고, 앱 시작과 실행 중 URL 수신 양쪽에서 같은 함수를 불러야 한다.', true),
(15481, 5738, 'URL에서 주문 번호를 잘못 읽어 요청한 주문이 아닌 다른 주문의 화면을 열고 있다.', '꺼져 있을 때 주문 42 상세가 정확히 열렸으므로 번호 해석은 맞다. 백그라운드에서 보인 주문 7 상세는 딥링크가 연 화면이 아니라 사용자가 원래 보던 화면이다.', false),
(15482, 5738, '앱이 백그라운드에서 돌아오면 스택이 초기화돼 딥링크가 쌓아 둔 화면이 지워진다.', '백그라운드에서 돌아왔을 때 보던 주문 7 상세가 그대로 남았으므로 스택은 초기화되지 않았다. 쌓인 화면이 지워진 것이 아니라 애초에 경로가 새로 조립되지 않은 것이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1868, 5739, 'NavigationPath,NavigationPath(),navigation path,내비게이션 패스,내비게이션패스,네비게이션 패스,네비게이션패스', 'NavigationPath는 서로 다른 Hashable 값을 한 경로에 담을 수 있도록 원소 타입을 지운 SwiftUI의 경로 컨테이너다. 그래서 Order와 RefundRequest를 따로 감싸는 코드 없이 그대로 append할 수 있고, 어떤 뷰를 그릴지는 값 타입별 navigationDestination(for:)가 정한다. [Order]처럼 원소 타입이 하나로 고정된 배열은 그 타입만 받기 때문에 본문의 빌드 오류가 났다. 값 타입이 하나뿐이거나 [OrderRoute]처럼 enum 하나로 경로를 표현한다면 일반 배열로도 충분하다. NavigationPath는 화면을 쌓는 컨테이너인 NavigationStack에 넘기는 경로 데이터이지 스택 자체가 아니라는 점을 구분한다. 담긴 값이 모두 Codable이면 codable 표현을 꺼내 저장해 두었다가 앱을 다시 켤 때 경로를 되살릴 수도 있다.'),
       (1869, 5740, '순환 참조,순환참조,강한 참조 순환,강한참조순환,강한 순환 참조,참조 순환,참조순환,retain cycle,retaincycle,reference cycle,strong reference cycle,리테인 사이클,리테인사이클', 'OrderCoordinator는 list 프로퍼티로 목록 화면을 강하게 붙잡고, 목록 화면은 onSelect 클로저를 붙잡으며, 그 클로저는 self를 강하게 캡처해 다시 OrderCoordinator를 붙잡는다. 이렇게 강한 참조가 고리를 이루면 바깥 참조(부모의 childCoordinators, 내비게이션 스택)가 모두 끊겨도 서로의 참조 카운트가 0이 되지 않아 둘 다 해제되지 않는다. 이것이 강한 참조 순환(순환 참조)이다. [weak self]는 클로저 쪽 참조를 약하게 만들어 고리를 끊으므로, 부모가 흐름 객체를 지우는 순간 흐름 객체가 먼저 해제되고 이어서 목록 화면도 해제된다. 강한 참조 자체는 흔하고 정상이며 고리를 이룰 때만 문제가 된다는 점, 그리고 결과로 나타난 현상인 메모리 누수와 그 원인인 참조 형태를 구분한다. 부모가 끝난 자식을 배열에서 지우지 않아 생기는 누수는 고리가 없어도 생기므로 원인이 다르다.');
