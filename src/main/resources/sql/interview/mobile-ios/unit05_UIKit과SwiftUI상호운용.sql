-- Unit: UIKit과 SwiftUI 상호운용 (Unit ID: 181)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(901, 'SWIFTUI', 181, 'HARD', true,
 '기존 UIKit 앱의 화면 안에 UIHostingController로 SwiftUI 화면을 임베드하고, 표시할 데이터가 자주 바뀌는 상황이라면 어떻게 설계하시겠어요? 이때 주의해야 할 함정도 함께 설명해 주세요.',
 '하나의 UIHostingController를 컨테이너 뷰 컨트롤러가 보관하고, 데이터가 바뀌면 컨트롤러를 새로 만들어 교체하는 대신 rootView를 바꾸거나 @Observable/ObservableObject 같은 관찰 객체의 값을 변경하겠습니다. 그러면 SwiftUI가 알아서 body를 재평가합니다. 매번 새 HostingController를 만들어 push하면 갱신 때마다 화면이 쌓이는 안티패턴이 됩니다. 컨테이너에 붙일 때는 addChild로 자식 VC를 추가하고, addSubview로 host.view를 붙인 뒤 제약을 걸고, 마지막에 didMove(toParent:)를 호출하는 자식 VC 계약을 지켜야 합니다. 이 계약을 지키지 않고 view만 떼어 붙이면 화면 회전, 세이프 에어리어, viewWillAppear 전달이 깨지므로 임시 프로토타입에서만 허용됩니다. 또 UIHostingController로 UIKit을 한 번 거치면 SwiftUI 환경 체인이 끊기므로, rootView에 .environment(...)나 .environmentObject(...)를 다시 붙여 주입해야 합니다. 마지막으로 UIKit 내비게이션 스택 위에 push한 경우 SwiftUI 안에서 NavigationStack을 또 만들면 내비게이션 바가 이중으로 생기므로, 흐름 제어를 어느 쪽이 소유할지 먼저 정해야 합니다.'),
(902, 'SWIFTUI', 181, 'NORMAL', true,
 'UIViewRepresentable과 UIHostingController는 각각 어떤 방향으로 UIKit과 SwiftUI를 연결하며, 어떤 상황에서 쓰는지 차이를 설명해 주세요.',
 '두 도구는 방향이 반대입니다. UIViewRepresentable(과 UIViewControllerRepresentable)은 UIKit 뷰를 SwiftUI 뷰 트리 안에 넣는 다리로, SwiftUI가 아직 제공하지 않는 웹뷰, 지도, 카메라, 서드파티 UIKit 컴포넌트를 SwiftUI 앱에서 쓸 때 사용합니다. 반대로 UIHostingController는 SwiftUI 뷰를 루트로 가지는 UIViewController로, 기존 UIKit 앱에 SwiftUI 화면을 도입할 때 UIKit 내비게이션에 push하거나 자식 VC로 임베드해 씁니다. 기존 UIKit 앱에 새 화면을 추가할 때는 화면 단위로 UIHostingController를 쓰고 흐름은 기존 Coordinator를 유지하는 것이 권장됩니다. 테이블이나 컬렉션 셀 내부만 SwiftUI로 만들 때는 별도 호스팅 컨트롤러 대신 iOS 16+의 UIHostingConfiguration을 쓰는 것이 재사용과 크기 계산 면에서 안전합니다.'),
(903, 'SWIFTUI', 181, 'NORMAL', true,
 'UIViewRepresentable에서 makeUIView와 updateUIView는 각각 언제 호출되며, 그 호출 방식 때문에 updateUIView는 어떻게 작성해야 하나요?',
 'makeUIView(context:)는 뷰 정체성이 생길 때 한 번만 호출되며, UIView를 생성하고 델리게이트를 연결하고 초기 설정을 하는 곳입니다. 반면 updateUIView(_:context:)는 생성 직후와 이후 SwiftUI 상태가 바뀔 때마다 반복 호출되며, SwiftUI 상태를 UIView에 반영하는 역할입니다. 이렇게 updateUIView는 부모 뷰가 재평가될 때마다 반복 호출되기 때문에 매번 무조건 값을 대입하면 UITextField의 커서가 튀거나 WKWebView가 같은 페이지를 다시 로드하는 문제가 생깁니다. 그래서 if uiView.text != text처럼 값이 달라졌을 때만 반영하는 멱등한 갱신으로 작성해야 합니다.'),
(904, 'SWIFTUI', 181, 'EASY', true,
 'UIViewRepresentable에서 Coordinator는 왜 필요하고 어떤 역할을 하나요?',
 'UIKit의 델리게이트, 데이터소스, 타깃 액션은 참조 타입(NSObject)이 필요한데, Representable은 구조체라서 이 역할을 할 수 없습니다. 그래서 Coordinator 클래스가 대신 델리게이트와 액션을 받습니다. 데이터 흐름은 두 갈래로, SwiftUI에서 UIKit 방향은 updateUIView가 담당하고, UIKit에서 SwiftUI 방향은 Coordinator가 Binding이나 클로저를 통해 전달합니다. 예를 들어 텍스트 필드의 editingChanged 액션을 Coordinator가 받아 text.wrappedValue에 값을 씁니다. Coordinator는 makeCoordinator()로 가장 먼저 한 번 생성되어 Representable의 정체성 수명 동안 하나만 유지되고, context.coordinator로 접근합니다. Representable 구조체 자체에 저장한 값은 재생성될 때 사라지므로 유지해야 할 것은 Coordinator나 @State에 둡니다.'),
(905, 'SWIFTUI', 181, 'EASY', true,
 'updateUIView 안에서 Binding에 값을 쓰면 어떤 문제가 생기나요? 부득이하게 뷰 갱신 중에 상태를 바꿔야 한다면 어떻게 처리해야 하나요?',
 'updateUIView 안에서 Binding에 값을 쓰면 뷰 갱신 중에 상태를 변경하게 되어 "Modifying state during view update" 경고와 함께 정의되지 않은 동작이 됩니다. 그래서 UIKit에서 SwiftUI 방향의 갱신은 updateUIView가 아니라 Coordinator가 받는 델리게이트나 액션 콜백에서 수행하는 것이 원칙입니다. 그래도 부득이하게 뷰 갱신 중에 상태를 바꿔야 한다면 DispatchQueue.main.async나 Task { @MainActor in ... }로 상태 변경을 다음 런루프로 미뤄서 처리합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 901
(4847, 901, '데이터가 바뀔 때 HostingController를 새로 만들지 않고 rootView나 관찰 객체를 갱신함을 설명', 'ESSENTIAL', 1),
(4848, 901, 'addChild → addSubview → didMove(toParent:) 순서의 자식 VC 계약을 제시', 'ESSENTIAL', 2),
(4849, 901, 'UIKit을 거치면 환경 체인이 끊겨 rootView에 environment를 다시 주입해야 함을 설명', 'ESSENTIAL', 3),
(4850, 901, '계약 위반 시 깨지는 것으로 화면 회전·세이프 에어리어·viewWillAppear 전달 중 최소 1개를 제시', 'SUPPLEMENTARY', 4),
(4851, 901, 'UIKit 스택 위 SwiftUI에서 NavigationStack을 또 만들면 내비게이션 바가 이중으로 생김을 언급', 'SUPPLEMENTARY', 5),

-- 질문 902
(4852, 902, 'UIViewRepresentable은 UIKit 뷰를 SwiftUI 뷰 트리 안에 넣는 도구임을 설명', 'ESSENTIAL', 1),
(4853, 902, 'UIHostingController는 SwiftUI 뷰를 루트로 가지는 UIViewController임을 설명', 'ESSENTIAL', 2),
(4854, 902, '웹뷰·지도·카메라 중 최소 1개를 UIViewRepresentable의 대표 용도로 제시', 'ESSENTIAL', 3),
(4855, 902, '기존 UIKit 앱에 SwiftUI 화면을 도입할 때 UIHostingController를 쓴다고 언급', 'ESSENTIAL', 4),
(4856, 902, '셀 내부만 SwiftUI로 할 때는 UIHostingConfiguration을 쓴다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 903
(4857, 903, 'makeUIView는 뷰 정체성이 생길 때 한 번만 호출됨을 설명', 'ESSENTIAL', 1),
(4858, 903, 'updateUIView는 생성 직후와 SwiftUI 상태가 바뀔 때마다 반복 호출됨을 설명', 'ESSENTIAL', 2),
(4859, 903, 'updateUIView는 값이 달라졌을 때만 반영하는 멱등한 갱신으로 작성해야 함을 설명', 'ESSENTIAL', 3),
(4860, 903, '무조건 대입하면 커서가 튀거나 WKWebView가 같은 페이지를 다시 로드하는 문제를 언급', 'SUPPLEMENTARY', 4),
(4861, 903, 'UIView 생성·델리게이트 연결·초기 설정 중 최소 1개를 makeUIView의 역할로 제시', 'SUPPLEMENTARY', 5),

-- 질문 904
(4862, 904, '델리게이트·타깃 액션은 참조 타입이 필요해 구조체 대신 Coordinator 클래스가 받음을 설명', 'ESSENTIAL', 1),
(4863, 904, 'UIKit → SwiftUI 방향 데이터를 Coordinator가 Binding이나 클로저로 전달함을 설명', 'ESSENTIAL', 2),
(4864, 904, 'Coordinator는 정체성 수명 동안 하나만 유지되고 context.coordinator로 접근함을 언급', 'SUPPLEMENTARY', 3),
(4865, 904, 'Representable 구조체에 저장한 값은 재생성될 때 사라진다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 905
(4866, 905, 'updateUIView 안에서 Binding에 값을 쓰면 정의되지 않은 동작이 됨을 설명', 'ESSENTIAL', 1),
(4867, 905, 'DispatchQueue.main.async·Task 중 최소 1개로 상태 변경을 다음 런루프로 미룬다고 제시', 'ESSENTIAL', 2),
(4868, 905, 'Modifying state during view update 경고가 발생함을 언급', 'SUPPLEMENTARY', 3),
(4869, 905, 'UIKit → SwiftUI 방향 갱신은 updateUIView가 아닌 델리게이트/액션 콜백에서 수행한다고 언급', 'SUPPLEMENTARY', 4);
