-- Unit: Observation 프레임워크 (Unit ID: 179)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(891, 'SWIFTUI', 179, 'HARD', true,
 '@Observable 모델의 값을 바꿨는데 SwiftUI 화면이 갱신되지 않는다면 어떤 원인을 의심할 수 있고, 각각 어떻게 해결하시겠어요?',
 '@Observable은 body 평가 중에 실제로 읽은 프로퍼티에만 의존성을 등록하기 때문에, 먼저 그 값을 body에서 읽고 있는지 확인합니다. onAppear나 버튼 액션 클로저 안에서만 읽은 프로퍼티는 뷰를 갱신시키지 않으므로, 화면에 반영돼야 하는 값이라면 body에서 읽도록 바꿉니다. 반대로 body에서 읽지 않은 값이 바뀌었는데 화면이 안 바뀌는 것은 버그가 아니라 의도된 동작입니다. 두 번째로 해당 프로퍼티에 @ObservationIgnored가 붙어 있으면 추적에서 제외되므로, 화면에 쓰이는 값이라면 이 표시를 제거해야 합니다. 세 번째로 컬렉션 요소의 변경인 경우, items가 구조체 배열이면 요소 수정이 배열 전체의 변경으로 추적되지만 클래스 배열이면 요소 객체도 @Observable이어야 하고 뷰가 item.title처럼 그 프로퍼티를 직접 읽어야 의존성이 생깁니다. 따라서 요소 클래스에 @Observable을 붙입니다. 참고로 SwiftUI 밖에서 withObservationTracking을 쓸 때는 onChange가 변경 직전에 한 번만 호출되고 자동 해제되므로, 첫 변경만 감지되는 문제가 있다면 onChange 안에서 다시 등록해야 합니다.',
 'interview-question/891.mp3'),
(892, 'SWIFTUI', 179, 'NORMAL', true,
 'ObservableObject와 @Published 조합과 비교했을 때 @Observable은 뷰 갱신 범위가 어떻게 다른가요?',
 'ObservableObject는 Combine 기반이라 @Published 프로퍼티가 바뀌면 objectWillChange 퍼블리셔가 발행되고, 그 객체를 구독하는 모든 뷰의 body가 재평가됩니다. 즉 뷰가 어떤 프로퍼티를 읽었는지와 무관하게 객체 전체가 갱신 단위라서, name만 읽는 뷰도 draftMemo가 바뀌면 다시 평가됩니다. 반면 @Observable은 Observation 프레임워크 기반으로, body가 실제로 읽은 프로퍼티가 바뀔 때만 해당 뷰를 갱신하므로 갱신 단위가 프로퍼티로 세분화되고 불필요한 body 재평가가 크게 줄어듭니다. 또 @Published 같은 표시 없이 저장 프로퍼티를 기본으로 추적하고, 제외하려면 @ObservationIgnored를 붙이며, 계산 프로퍼티도 내부에서 읽는 저장 프로퍼티를 통해 자동 추적됩니다.',
 'interview-question/892.mp3'),
(893, 'SWIFTUI', 179, 'NORMAL', true,
 'ObservableObject에서 쓰던 @StateObject, @ObservedObject, @EnvironmentObject는 @Observable로 전환하면 각각 무엇으로 대체되나요?',
 '뷰가 직접 소유·생성하는 객체는 @StateObject 대신 @State로 선언하면 충분합니다. 외부에서 받아 읽기만 하는 경우에는 @ObservedObject 대신 let vm: VM 같은 일반 프로퍼티로 받습니다. 외부에서 받은 객체에 $vm.x 같은 바인딩이 필요하면 @Bindable var vm으로 선언합니다. 뷰 트리 주입은 .environmentObject(obj) 대신 .environment(obj)로 하고, 하위 뷰에서는 @EnvironmentObject 대신 @Environment(VM.self)로 꺼냅니다. 주의할 점은 @Observable 객체를 @State가 아닌 일반 프로퍼티에 담아 뷰 안에서 생성하면 뷰 값이 재생성될 때마다 객체가 새로 만들어진다는 것입니다. 그래서 생성하는 곳은 반드시 @State, 전달받는 곳은 일반 프로퍼티로 둡니다.',
 'interview-question/893.mp3'),
(894, 'SWIFTUI', 179, 'EASY', true,
 '@Observable 매크로가 프로퍼티 단위 변경 추적을 어떻게 구현하는지 설명해 주세요.',
 '@Observable은 Swift 매크로로, 컴파일 시점에 클래스를 확장해 모든 저장 프로퍼티의 접근자에 추적 코드를 삽입합니다. 개념적으로는 ObservationRegistrar를 프로퍼티로 두고, getter에서는 registrar.access(self, keyPath:)를, setter에서는 registrar.withMutation(of:keyPath:)를 호출하도록 바뀝니다. body 평가 중 vm.name을 읽으면 access가 호출되어 이 뷰가 name에 의존한다는 것이 기록되고, 평가가 끝나면 그 뷰의 의존 집합이 정해집니다. 이후 프로퍼티를 쓰면 withMutation이 등록된 관찰자에게 변경을 알리는데, 의존 집합에 있는 name이 바뀌면 뷰가 무효화되고 의존 집합에 없는 draftMemo가 바뀌면 무시됩니다. 이 메커니즘은 SwiftUI 밖에서도 withObservationTracking(_:onChange:)로 직접 사용할 수 있습니다.',
 'interview-question/894.mp3'),
(895, 'SWIFTUI', 179, 'EASY', true,
 'iOS 26부터 UIKit에서 @Observable 객체를 사용하면 뷰 갱신 방식이 어떻게 달라지나요?',
 'iOS 26부터 UIKit도 layoutSubviews()나 updateProperties() 같은 갱신 메서드 안에서 읽은 @Observable 프로퍼티를 자동으로 추적합니다. 그 프로퍼티가 바뀌면 해당 뷰가 무효화되어 갱신 메서드가 다시 실행되므로, 예전처럼 setNeedsLayout()을 수동으로 부를 필요가 없습니다. 예를 들어 셀의 updateProperties()에서 vm.name을 읽어 textLabel에 넣으면 name이 바뀔 때 자동으로 재호출됩니다. updateProperties()는 텍스트·색상·이미지처럼 크기·위치에 영향 없는 속성을 갱신하는 용도로 layoutSubviews() 직전에 호출됩니다. 또한 Info.plist의 UIObservationTrackingEnabled 키로 iOS 18까지 백포트할 수 있습니다.',
 'interview-question/895.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 891
(4799, 891, '의존성은 body 평가 중에 읽은 프로퍼티에만 등록되어 onAppear나 액션 클로저에서만 읽은 값은 갱신을 유발하지 않음을 언급', 'ESSENTIAL', 1),
(4800, 891, '@ObservationIgnored로 표시한 프로퍼티는 추적에서 제외되어 변경돼도 뷰가 갱신되지 않음을 언급', 'ESSENTIAL', 2),
(4801, 891, '클래스 배열의 요소 객체가 @Observable이 아니면 요소 프로퍼티 변경이 추적되지 않음을 언급', 'ESSENTIAL', 3),
(4802, 891, 'body에서 읽지 않은 값의 변경으로 화면이 바뀌지 않는 것은 버그가 아니라 의도된 동작임을 명시', 'SUPPLEMENTARY', 4),
(4803, 891, 'withObservationTracking의 onChange는 한 번만 호출되므로 계속 관찰하려면 다시 등록해야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 892
(4804, 892, 'ObservableObject는 어떤 @Published 프로퍼티가 바뀌어도 그 객체를 구독하는 모든 뷰의 body가 재평가됨을 언급', 'ESSENTIAL', 1),
(4805, 892, '@Observable은 body가 실제로 읽은 프로퍼티가 바뀔 때만 뷰를 갱신함을 언급', 'ESSENTIAL', 2),
(4806, 892, 'ObservableObject는 Combine의 objectWillChange 퍼블리셔로 변경을 발행함을 언급', 'SUPPLEMENTARY', 3),
(4807, 892, '@Observable은 @Published 표시 없이 저장 프로퍼티를 기본으로 추적함을 언급', 'SUPPLEMENTARY', 4),
(4808, 892, '@Observable에서는 계산 프로퍼티도 내부에서 읽는 저장 프로퍼티를 통해 자동 추적됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 893
(4809, 893, '뷰가 소유·생성하는 객체는 @StateObject 대신 @State로 선언함을 언급', 'ESSENTIAL', 1),
(4810, 893, '외부에서 받아 읽기만 하는 객체는 @ObservedObject 대신 일반 프로퍼티로 받음을 언급', 'ESSENTIAL', 2),
(4811, 893, '외부에서 받은 객체에 바인딩이 필요하면 @Bindable을 사용함을 언급', 'ESSENTIAL', 3),
(4812, 893, '@EnvironmentObject 대신 @Environment(Type.self)로 주입된 객체를 꺼냄을 언급', 'ESSENTIAL', 4),
(4813, 893, '@Observable 객체를 뷰 안의 일반 프로퍼티로 생성하면 뷰 값이 재생성될 때마다 객체가 새로 만들어짐을 언급', 'SUPPLEMENTARY', 5),
(4814, 893, '.environmentObject(obj) 대신 .environment(obj)로 하위 트리에 주입함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 894
(4815, 894, '매크로가 컴파일 시점에 저장 프로퍼티의 접근자에 추적 코드를 삽입함을 언급', 'ESSENTIAL', 1),
(4816, 894, '프로퍼티를 읽을 때 access 호출로 해당 키 경로에 대한 의존성이 등록됨을 언급', 'ESSENTIAL', 2),
(4817, 894, '프로퍼티를 쓸 때 withMutation 호출로 등록된 관찰자에게 변경을 알림을 언급', 'ESSENTIAL', 3),
(4818, 894, '추적을 담당하는 ObservationRegistrar가 매크로 확장으로 클래스에 추가됨을 언급', 'SUPPLEMENTARY', 4),
(4819, 894, 'SwiftUI 밖에서는 withObservationTracking으로 같은 추적 메커니즘을 직접 사용할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 895
(4820, 895, 'layoutSubviews()·updateProperties() 안에서 읽은 @Observable 프로퍼티가 자동 추적됨을 언급', 'ESSENTIAL', 1),
(4821, 895, '추적된 프로퍼티가 바뀌면 갱신 메서드가 다시 실행되어 setNeedsLayout()을 수동으로 부를 필요가 없음을 언급', 'ESSENTIAL', 2),
(4822, 895, 'updateProperties()는 크기·위치에 영향 없는 속성 갱신용으로 layoutSubviews() 직전에 호출됨을 언급', 'SUPPLEMENTARY', 3),
(4823, 895, 'Info.plist의 UIObservationTrackingEnabled 키로 iOS 18까지 백포트할 수 있음을 언급', 'SUPPLEMENTARY', 4);
