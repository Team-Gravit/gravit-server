-- Unit: Observation 프레임워크 (Unit ID: 179)
-- Chapter: iOS (Chapter ID: 17)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (605, 179, '프로퍼티 단위 갱신과 추적 제외'),
       (763, 179, '매크로 확장과 Bindable, 래퍼 전환'),
       (921, 179, 'Observation 프레임워크: 실제로 읽은 값만 추적하는 원리와 전환');

-- =====================================================
-- Lesson 605: 프로퍼티 단위 갱신과 추적 제외
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3809, 605, '아래 코드에서 버튼을 눌러 draftMemo를 바꿨을 때 HeaderView의 동작으로 옳은 것은?', '```swift
import SwiftUI
import Observation

@Observable
final class ProfileViewModel {
    var name = "지수"
    var draftMemo = ""
    @ObservationIgnored var cache: [String: Data] = [:]
}

struct HeaderView: View {
    let vm: ProfileViewModel
    var body: some View {
        Text(vm.name)
    }
}

struct ProfileScreen: View {
    @State private var vm = ProfileViewModel()
    var body: some View {
        VStack {
            HeaderView(vm: vm)
            Button("메모 추가") { vm.draftMemo += "x" }
        }
    }
}
```', 'OBJECTIVE'),
       (3810, 605, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 항목 | ObservableObject + @Published | @Observable |
| --- | --- | --- |
| 기반 | Combine의 objectWillChange | Observation 프레임워크(매크로 + 레지스트라) |
| 갱신 단위 | 객체 — 어느 프로퍼티가 바뀌든 구독 뷰 전체 | 프로퍼티 — body가 읽은 것만 |
| 추적 표시 | @Published를 붙인 프로퍼티만 | 저장 프로퍼티가 기본 추적, 제외는 @ObservationIgnored |
| 계산 프로퍼티 | 감지 불가 | 내부 저장 프로퍼티를 통해 자동 추적 |
| 최소 배포 버전 | iOS 13 | iOS 17 |', 'OBJECTIVE'),
       (3811, 605, '아래 코드에서 입력한 이름이 사라지는 원인으로 옳은 것은?', '```swift
@Observable
final class ProfileViewModel {
    var name = ""
}

struct ProfileScreen: View {
    let vm = ProfileViewModel()

    var body: some View {
        VStack {
            NameEditor(vm: vm)
            Text("현재 이름: \(vm.name)")
        }
    }
}
```

증상: NameEditor에 이름을 입력하는 동안에는 아래 Text가 잘 따라 바뀐다. 그런데 상위 화면의 상태가 바뀌어 ProfileScreen 값이 다시 만들어지는 순간, 입력해 둔 이름이 빈 문자열로 돌아간다.', 'OBJECTIVE'),
       (3812, 605, '아래 코드를 실행했을 때 두 번째 대입부터 changed가 찍히지 않는 원인으로 옳은 것은?', '```swift
@Observable
final class Counter {
    var value = 0
}

let counter = Counter()

withObservationTracking {
    _ = counter.value
} onChange: {
    print("changed")
}

counter.value = 1   // 출력: changed
counter.value = 2   // 출력 없음
counter.value = 3   // 출력 없음
```', 'OBJECTIVE'),
       (3813, 605, '아래 상황에서 프로퍼티 선언 바로 위에 덧붙인 한 줄은?', '피드 화면의 뷰 모델에 내려받은 이미지를 담아 두는 [String: Data] 딕셔너리를 하나 두었다. 스크롤을 내릴 때마다 셀이 이미지를 이 딕셔너리에 넣는데, 넣을 때마다 같은 뷰 모델을 쓰는 화면 전체가 다시 그려져 초당 프레임이 60에서 24까지 떨어졌다. 딕셔너리 자체는 화면 어디에도 표시하지 않는데도 그랬다. 딕셔너리 선언 바로 위에 한 줄을 덧붙이자 그 재평가가 사라지고 다시 60을 유지했다. 같은 클래스의 다른 프로퍼티는 그대로 화면을 갱신한다.', 'SUBJECTIVE'),
       (3814, 605, '아래 코드에서 물음표로 가린 UIKit 갱신 메서드의 이름은?', '```swift
// iOS 26, UIKit
final class ProfileCell: UITableViewCell {
    var vm: ProfileViewModel?              // @Observable 객체

    override func ????() {
        super.????()
        textLabel?.text = vm?.name
        contentView.backgroundColor = vm?.isPublic == true ? .systemGreen : .systemGray6
    }
}
```

vm.name을 바꾸면 setNeedsLayout()을 부른 적이 없는데도 위 메서드가 다시 실행되어 라벨 글자와 배경색이 바뀐다. 같은 코드를 layoutSubviews()에 옮겨도 갱신은 되지만, 글자 한 자만 바뀌어도 셀의 크기·위치 계산이 매번 함께 돌아 스크롤이 눈에 띄게 무거워졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3809
(10331, 3809, 'draftMemo도 추적 대상 저장 프로퍼티이므로 HeaderView의 body가 함께 다시 평가된다.', '객체 하나가 바뀌면 그 객체를 쓰는 뷰가 모두 갱신되던 이전 방식을 그대로 옮겨 온 오개념이다. 추적은 프로퍼티마다 따로 등록되므로, 읽지 않은 프로퍼티의 변경은 이 뷰의 무효화로 이어지지 않는다.', false),
(10332, 3809, 'vm을 @State가 아닌 일반 프로퍼티로 받았으므로 HeaderView는 name이 바뀌어도 갱신되지 않는다.', '래퍼 종류가 갱신 여부를 정한다는 오개념이다. 전달받는 쪽은 일반 프로퍼티가 정석이고, @State는 객체를 만들어 소유하는 쪽에서 인스턴스 수명을 지킬 때 쓴다. 갱신은 body가 무엇을 읽었는지로 갈린다.', false),
(10333, 3809, 'HeaderView의 body는 다시 평가되지 않고, name을 바꿀 때만 다시 평가된다.', 'body가 읽은 프로퍼티는 name 하나뿐이라 이 뷰의 의존 집합은 name만 담는다. draftMemo 변경은 그 집합에 없어 무효화가 일어나지 않는다. 화면이 안 바뀌는 것이 버그가 아니라 의도된 동작이다.', true),
(10334, 3809, 'cache에 붙은 @ObservationIgnored 때문에 이 클래스의 변경 알림이 모두 막힌다.', '@ObservationIgnored를 클래스 단위 스위치로 오해한 것이다. 이 표시는 붙은 프로퍼티 하나만 추적에서 빼며, 같은 클래스의 name·draftMemo는 그대로 추적된다.', false),

-- 문제 3810
(10335, 3810, '배포 타깃이 iOS 15인 앱은 오른쪽 방식을 도입할 수 없어 Combine 기반 구성을 유지해야 한다.', '오른쪽의 최소 배포 버전이 iOS 17이므로 그보다 낮은 타깃에서는 매크로를 쓸 수 없다. 하위 호환이 필요해 두 방식을 섞어야 한다면 모델 계층에서 어느 쪽을 표준으로 삼을지 먼저 정하는 편이 낫다.', false),
(10336, 3810, '오른쪽 방식에서도 추적하려는 저장 프로퍼티마다 @Published를 붙여야 하고, 빠뜨리면 갱신되지 않는다.', '표의 추적 표시 행과 정면으로 어긋나는 거짓 진술이다. 오른쪽은 저장 프로퍼티가 기본 추적 대상이고 빼고 싶을 때만 @ObservationIgnored를 붙인다. @Published는 왼쪽 방식의 문법이다.', true),
(10337, 3810, '여러 값을 더해 돌려주는 계산 프로퍼티를 뷰가 읽을 때, 왼쪽 방식에서는 그 결과가 달라져도 갱신 신호가 오지 않는다.', '왼쪽은 @Published가 붙은 저장 프로퍼티의 발행에만 의존해 계산 프로퍼티 자체를 감지하지 못한다. 오른쪽은 계산 과정에서 읽은 저장 프로퍼티가 대신 등록되어 결과가 바뀌면 뷰가 갱신된다.', false),
(10338, 3810, '한 객체를 여러 뷰가 함께 쓸수록 왼쪽 방식은 관계없는 프로퍼티 변경까지 body 재평가로 이어진다.', '갱신 단위가 객체라 어느 프로퍼티가 바뀌든 그 객체를 쓰는 뷰 전체가 대상이 되기 때문이다. 타이핑마다 값이 바뀌는 임시 입력 문자열이 대표적인 낭비 요인이다.', false),

-- 문제 3811
(10339, 3811, '@Observable 클래스가 구조체인 뷰의 저장 프로퍼티에 담기면서 매번 값이 복사돼 원본과 끊긴다.', '값 타입 복사로 원인을 돌린 오개념이다. 클래스는 참조 타입이라 뷰에 담겨도 복사되지 않는다. 문제는 복사가 아니라 뷰 값이 새로 만들어질 때 인스턴스까지 새로 생기는 데 있다.', false),
(10340, 3811, 'name에 @Published가 빠져 변경이 발행되지 않아 입력값이 유지되지 않는다.', '이전 방식의 문법을 끌어온 오개념이다. @Observable에서는 @Published가 필요 없고, 실제로 입력 중에는 Text가 잘 따라 바뀐다. 발행 여부와 값이 초기화되는 현상은 별개다.', false),
(10341, 3811, '자식 뷰에 vm을 넘길 때 @Bindable을 쓰지 않아 부모와 자식이 서로 다른 인스턴스를 보게 된다.', '@Bindable을 인스턴스 공유 장치로 오해한 것이다. 이 표시는 전달받은 객체에서 $vm.name 같은 바인딩을 꺼내려 할 때 필요할 뿐, 새 인스턴스를 만들거나 참조를 끊지 않는다.', false),
(10342, 3811, '뷰 값이 다시 만들어질 때마다 vm 인스턴스가 새로 생성돼 그동안의 상태가 버려진다.', 'let vm = ProfileViewModel()은 뷰 값이 만들어질 때마다 실행된다. 객체를 만들어 소유하는 자리에는 @State를 써야 뷰 값이 새로 생겨도 같은 인스턴스가 유지된다. 예전 @ObservedObject var vm = X()와 같은 실수다.', true),

-- 문제 3812
(10343, 3812, 'onChange는 첫 변경 직전에 한 번만 불리고 등록이 풀리므로, 계속 받으려면 그 안에서 다시 등록해야 한다.', '이 알림은 willSet 성격이라 변경 직전에 한 번 호출되고 스스로 해제된다. 연속 관찰이 필요하면 onChange 안에서 withObservationTracking을 다시 호출하는 형태로 감싸야 한다.', true),
(10344, 3812, '레지스트라가 짧은 간격으로 일어난 연속 변경을 하나로 합쳐 마지막에 한 번만 알린다.', '알림이 병합된다고 본 오개념이다. 합쳐서 마지막에 알리는 것이 사실이라면 value가 3이 된 뒤 한 번 더 출력돼야 하는데, 출력은 첫 변경에서만 나왔다.', false),
(10345, 3812, 'onChange가 불릴 때 앞의 클로저가 자동으로 다시 실행되어 의존이 갱신되므로 이후 변경은 무시된다.', '앞의 클로저는 자동으로 다시 실행되지 않는다. 오히려 다시 실행되지 않아 읽기가 없고, 그래서 새 의존이 남지 않는 것이다. 다시 읽어 등록하는 일은 개발자 몫이다.', false),
(10346, 3812, '추적은 SwiftUI의 body 평가 중에만 유효해서 뷰 밖에서는 최초 1회만 동작한다.', 'body 밖에서 읽은 값은 뷰를 갱신하지 않는다는 SwiftUI 규칙과 뒤섞은 오개념이다. withObservationTracking은 SwiftUI 없이도 동작하고, 여러 번 등록하면 그만큼 알림을 받는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1226, 3813, '@ObservationIgnored,ObservationIgnored,옵저베이션이그노어드', '@Observable은 클래스의 모든 저장 프로퍼티 접근자에 추적 코드를 넣기 때문에, 화면에 그리지 않는 캐시까지 쓸 때마다 무효화가 일어난다. @ObservationIgnored를 붙인 프로퍼티에는 그 코드가 들어가지 않아 읽어도 의존이 등록되지 않고 바꿔도 알림이 가지 않는다. 클래스 전체를 추적에서 빼는 표시가 아니라 붙인 프로퍼티 하나에만 적용된다는 점, 그리고 @Published가 붙여서 추적을 켜는 표시였다면 이것은 붙여서 끄는 표시라는 점에서 방향이 반대다.'),
       (1227, 3814, 'updateProperties,updateProperties(),update properties', 'iOS 26부터 UIKit도 갱신 메서드 안에서 읽은 @Observable 프로퍼티를 자동으로 추적해, 그 값이 바뀌면 뷰를 무효화하고 메서드를 다시 부른다. 그래서 setNeedsLayout()을 손으로 부를 필요가 없다. updateProperties()는 크기·위치 계산과 분리된 단계라 글자·색·이미지처럼 레이아웃에 영향을 주지 않는 속성 갱신에 쓴다. layoutSubviews()도 같은 자동 추적 대상이지만 레이아웃 계산까지 함께 도는 자리라 잦은 갱신에는 비용이 크다. Info.plist의 UIObservationTrackingEnabled 키로 iOS 18까지 백포트할 수 있다.');

-- =====================================================
-- Lesson 763: 매크로 확장과 Bindable, 래퍼 전환
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4757, 763, '아래 코드에서 버튼을 눌러도 목록의 글자가 바뀌지 않는 원인으로 옳은 것은?', '```swift
import SwiftUI
import Observation

final class Todo {                          // 매크로를 붙이지 않은 일반 클래스
    var title: String
    init(title: String) { self.title = title }
}

@Observable
final class TodoListViewModel {
    var todos: [Todo] = [Todo(title: "장보기")]
}

struct TodoListView: View {
    let vm: TodoListViewModel

    var body: some View {
        VStack {
            ForEach(Array(vm.todos.enumerated()), id: \.offset) { _, todo in
                Text(todo.title)
            }
            Button("첫 항목 이름 바꾸기") { vm.todos[0].title = "청소하기" }
            Button("항목 추가") { vm.todos.append(Todo(title: "빨래")) }
        }
    }
}
```

증상: "항목 추가"를 누르면 새 줄이 즉시 목록에 나타난다. 그런데 "첫 항목 이름 바꾸기"를 누르면 첫 줄 글자가 그대로고, 다른 화면에 갔다가 돌아오면 그제야 바뀐 이름이 보인다.', 'OBJECTIVE'),
       (4758, 763, '아래 확장 결과 코드에서 따라 나오는 동작으로 옳은 것은?', '```swift
// @Observable을 붙인 클래스가 컴파일 시점에 펼쳐진 결과(개념 코드)
final class CartViewModel: Observable {
    private let _$observationRegistrar = ObservationRegistrar()

    private var _items: [String] = []
    var items: [String] {
        get { _$observationRegistrar.access(self, keyPath: \.items); return _items }
        set { _$observationRegistrar.withMutation(of: self, keyPath: \.items) { _items = newValue } }
    }

    private var _coupon = ""
    var coupon: String {
        get { _$observationRegistrar.access(self, keyPath: \.coupon); return _coupon }
        set { _$observationRegistrar.withMutation(of: self, keyPath: \.coupon) { _coupon = newValue } }
    }

    // 계산 프로퍼티에는 위와 같은 코드가 삽입되지 않는다
    var badgeText: String { "\(items.count)개" }
}
```

어떤 뷰의 body는 badgeText 하나만 읽어 배지 글자로 그린다.', 'OBJECTIVE'),
       (4759, 763, '아래 코드에서 MemoEditor가 컴파일되지 않는 원인으로 옳은 것은?', '```swift
@Observable
final class ProfileViewModel {
    var name = ""
    var draftMemo = ""
}

struct ProfileScreen: View {
    @State private var vm = ProfileViewModel()

    var body: some View {
        VStack {
            Text(vm.name)
            MemoEditor(vm: vm)
        }
    }
}

struct MemoEditor: View {
    let vm: ProfileViewModel

    var body: some View {
        TextEditor(text: $vm.draftMemo)   // 컴파일 오류: Cannot find ''$vm'' in scope
    }
}
```

ProfileScreen 쪽은 오류 없이 빌드되고, MemoEditor의 위 한 줄에서만 오류가 난다.', 'OBJECTIVE'),
       (4760, 763, '아래 전환표를 바탕으로 옳지 않은 것은?', '| 역할 | 기존 ObservableObject 방식 | 전환 후 @Observable 방식 |
| --- | --- | --- |
| 뷰가 직접 만들어 소유 | @StateObject private var vm = VM() | @State private var vm = VM() |
| 외부에서 받아 읽기만 | @ObservedObject var vm: VM | let vm: VM |
| 뷰 트리에 주입 | .environmentObject(vm) | .environment(vm) |
| 주입된 값 꺼내 쓰기 | @EnvironmentObject var vm: VM | @Environment(VM.self) private var vm |', 'OBJECTIVE'),
       (4761, 763, '아래 상황에서 모델 클래스 선언 위에 덧붙인 표시는?', '피드 화면의 뷰 모델은 @Observable을 붙인 클래스이고, 네트워크 응답을 받아 posts 배열에 대입하는 코드가 여러 곳에 흩어져 있다. 응답이 한꺼번에 몰리는 구간에서 목록이 절반만 그려진 채 멈추거나 드물게 앱이 튕겼는데, 크래시 로그가 가리키는 줄은 매번 달랐고 시뮬레이터에서는 열 번에 한 번꼴로만 재현됐다.

클래스 선언 위에 표시 한 줄을 덧붙이자 증상이 재현되지 않았고, 백그라운드 큐 안에서 posts에 대입하던 자리들은 await를 붙이라는 컴파일 오류로 한 번에 드러났다. 프로퍼티 이름이나 뷰 코드는 한 줄도 고치지 않았다.', 'SUBJECTIVE'),
       (4762, 763, '아래 전환 코드에서 물음표로 가린, Observation 프레임워크가 제공하는 타입의 이름은?', '```swift
// 이전 — 배지 숫자를 다시 그리려고 모델 변경을 구독했다
cancellable = model.objectWillChange.sink { [weak self] _ in
    self?.refreshBadge(count: model.unreadCount)
}

// 이후 — Combine 없이 (Swift 6.2 / iOS 26)
let stream = ????? { model.unreadCount }
for await count in stream {
    refreshBadge(count: count)
}
```

이전 코드는 같은 모델의 draftMemo에 글자 한 자만 입력해도 배지를 다시 그렸다. 바꾼 뒤에는 unreadCount가 실제로 달라질 때만 루프가 한 번씩 돌았고, 첫 변경만 받고 끊기지 않아 알림 안에서 다시 등록하는 코드도 필요 없었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4757
(12859, 4757, 'ForEach의 id로 offset을 써서 행의 정체성이 그대로 유지되므로, 이미 그린 줄은 갱신에서 제외된다.', 'id는 어느 행이 어느 뷰인지 짝짓는 기준일 뿐, 의존이 등록돼 있다면 정체성이 같아도 그 줄은 다시 평가된다. 같은 id 방식으로 그려진 목록이 항목 추가에서는 곧바로 바뀌는 것이 반례다.', false),
(12860, 4757, 'Todo가 참조 타입이라 title을 고쳐도 todos 프로퍼티 자체는 그대로고, Todo는 추적 대상이 아니라 title을 읽어도 의존이 남지 않는다.', '알림은 저장 프로퍼티의 set에서 나간다. 요소를 제자리에서 고치면 배열이 쥔 참조는 그대로라 todos의 set이 불리지 않고, Todo에 매크로가 없어 title 읽기도 기록되지 않는다. 구조체 배열이었다면 요소 수정이 곧 배열 대입이라 반영된다.', true),
(12861, 4757, 'vm을 @State가 아닌 일반 프로퍼티로 받아서 TodoListView가 모델의 변경 알림을 받지 못한다.', '전달받는 자리는 일반 프로퍼티가 정석이고, 갱신 여부는 body가 무엇을 읽었는지로 갈린다. 같은 vm으로 항목 추가는 즉시 반영되므로 래퍼 종류는 원인이 아니다. @State는 객체를 만들어 소유하며 수명을 지키는 자리에 쓴다.', false),
(12862, 4757, '배열이나 딕셔너리 같은 컬렉션 타입은 추적 대상에서 빠져 있어 내용이 어떻게 바뀌든 뷰가 갱신되지 않는다.', '저장 프로퍼티라면 타입과 무관하게 추적되며, append가 곧바로 화면에 반영되는 것이 그 증거다. 갈리는 지점은 컬렉션 타입이냐가 아니라 컬렉션 자체의 변경이냐 요소 객체 내부의 변경이냐다.', false),

-- 문제 4758
(12863, 4758, 'badgeText만 읽는 뷰는 그 접근자에 레지스트라 호출이 없으므로 items가 바뀌어도 갱신되지 않는다.', '계산 프로퍼티는 몸통을 실행하면서 items의 get을 부르고, 그 get 안의 access가 의존을 대신 등록한다. 삽입된 코드가 없다는 것과 추적되지 않는다는 것은 다르다.', false),
(12864, 4758, '레지스트라가 클래스마다 하나뿐이므로 coupon이 바뀌면 items만 읽은 뷰도 함께 무효화된다.', '레지스트라가 하나라고 갱신 단위까지 객체 하나가 되지는 않는다. access와 withMutation이 모두 키 경로를 함께 넘기므로 등록된 의존과 알림은 프로퍼티별로 짝지어진다.', false),
(12865, 4758, 'items를 읽기만 해도 withMutation이 실행돼 관찰자에게 변경 알림이 전달된다.', '읽기 경로에 들어 있는 것은 access뿐이다. 알림을 보내는 withMutation은 set 안에만 있어, 값을 읽는 것만으로는 어떤 뷰도 무효화되지 않는다. 읽기는 등록, 쓰기는 알림으로 역할이 나뉜다.', false),
(12866, 4758, 'badgeText를 읽은 뷰는 items가 바뀌면 갱신되지만, coupon만 바꾸면 갱신되지 않는다.', 'badgeText를 계산하는 동안 items의 get이 실행돼 items 키 경로가 그 뷰의 의존으로 남는다. coupon은 한 번도 읽히지 않아 그 키 경로로 나간 알림이 이 뷰에 닿지 않는다.', true),

-- 문제 4759
(12867, 4759, '전달받은 객체에서 $ 접두 바인딩을 꺼내려면 그 프로퍼티에 @Bindable 표시가 있어야 한다.', '일반 프로퍼티에는 $로 꺼낼 투영 값이 없다. @Bindable을 붙이면 @Observable 객체의 프로퍼티마다 바인딩이 만들어져 $vm.draftMemo가 성립한다. 값을 읽기만 하는 뷰는 지금처럼 표시 없이 받는 편이 맞다.', true),
(12868, 4759, '객체를 만들어 넘긴 쪽이 @State로 소유하고 있어 자식 뷰에서는 그 값을 다시 쓸 수 없다.', '@State는 인스턴스 수명을 뷰에 묶는 표시일 뿐 전달 후의 쓰기를 막지 않는다. 클래스는 참조 타입이라 자식 뷰에서 프로퍼티 대입도 그대로 된다. 막힌 것은 쓰기가 아니라 바인딩 생성이다.', false),
(12869, 4759, 'draftMemo에 @Published가 빠져 있어 바인딩을 만들 대상이 되지 못한다.', '@Published는 Combine 기반 옛 방식의 표시다. @Observable 클래스의 저장 프로퍼티는 아무 표시 없이 추적되며, 이 오류도 추적이 되냐 마냐가 아니라 $로 꺼낼 투영 값이 없어서 난다.', false),
(12870, 4759, '모델이 클래스라 값 바인딩을 만들 수 없으므로 구조체로 바꿔 @Binding으로 넘겨야 한다.', '참조 타입이라 바인딩을 못 만드는 것이 아니다. @Bindable은 오히려 클래스인 @Observable 객체를 전제로 동작한다. @State와 @Binding 짝은 뷰가 값 타입 상태를 직접 들고 있을 때 쓰는 다른 구성이다.', false),

-- 문제 4760
(12871, 4760, '읽기만 하는 자식 뷰는 아무 표시 없이 일반 프로퍼티로 받아도 body에서 읽은 프로퍼티가 바뀌면 다시 그려진다.', '참이다. 전환 후에는 래퍼가 구독을 만들어 주는 것이 아니라 body 평가 중의 읽기가 의존을 남긴다. 그래서 표의 두 번째 행처럼 표시를 떼어도 갱신이 유지된다.', false),
(12872, 4760, '매크로만 붙인 클래스는 ObservableObject를 따르지 않아, @ObservedObject 자리에 그대로 두면 타입 제약에 걸려 컴파일되지 않는다.', '참이다. @ObservedObject는 ObservableObject를 채택한 타입만 받는다. 매크로는 그 프로토콜과 무관한 추적 코드를 넣을 뿐이라, 표대로 읽기 전용 자리를 일반 프로퍼티로 내려야 빌드된다.', false),
(12873, 4760, '주입하는 쪽만 .environment(vm)로 바꾸고 꺼내는 쪽에 @EnvironmentObject를 그대로 두어도 같은 저장소를 쓰므로 값이 전달된다.', '표의 마지막 두 행은 짝으로 움직인다. 새 방식으로 넣은 값은 타입을 키로 조회하는 @Environment(VM.self)로 꺼내야 하고, @EnvironmentObject는 옛 수정자로 넣은 객체를 찾으므로 한쪽만 바꾸면 값을 받지 못한다.', true),
(12874, 4760, '소유하는 자리를 @State로 바꾸면 부모가 다시 평가돼 뷰 값이 새로 만들어져도 같은 인스턴스가 유지된다.', '참이다. 뷰는 구조체라 값이 새로 만들어지면 초기화 식도 다시 실행되지만, @State는 인스턴스를 뷰 수명에 묶어 두고 같은 객체를 돌려준다. 표의 첫 행이 @StateObject 자리를 그대로 이어받는 이유다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1542, 4761, '@MainActor,MainActor,메인액터,메인 액터,main actor', '@Observable은 프로퍼티 접근에 추적 코드를 넣어 줄 뿐 스레드 안전성까지 보장하지 않는다. UI에 연결된 모델을 여러 스레드에서 고치면 SwiftUI가 갱신 도중 어중간한 상태를 읽어 화면이 절반만 그려지거나 드물게 크래시가 나고, 타이밍에 따라 재현이 들쭉날쭉해진다. 클래스 선언에 @MainActor를 붙이면 그 클래스의 프로퍼티 접근과 메서드 호출이 메인 액터로 격리되어, 다른 실행 맥락에서 부르던 자리는 await가 필요해지고 컴파일 시점에 전부 드러난다. 추적 자체를 끄는 @ObservationIgnored와 헷갈리기 쉬운데, 그쪽은 갱신 범위를 줄이는 표시이고 @MainActor는 어느 실행 맥락에서 만지느냐를 정하는 표시다.'),
       (1543, 4762, 'Observations,observations,옵저베이션스', 'Observations는 Swift 6.2/iOS 26에서 더해진 타입으로, 클로저가 읽은 @Observable 프로퍼티의 변화를 AsyncSequence로 흘려보내 for await로 하나씩 받아 쓸 수 있게 한다. 이전 코드의 objectWillChange는 Combine 퍼블리셔라 객체 단위로 발행되므로, 배지와 무관한 draftMemo가 바뀌어도 클로저가 불려 불필요한 갱신이 섞였다. 비슷해 보이는 withObservationTracking과도 구분해야 한다. 그쪽은 변경 직전에 한 번만 알리고 등록이 풀려 계속 받으려면 알림 클로저 안에서 다시 등록해야 하는데, 전환 후 재등록 코드가 사라진 것이 두 API의 차이를 보여 준다.');

-- =====================================================
-- Lesson 921: Observation 프레임워크: 실제로 읽은 값만 추적하는 원리와 전환
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5705, 921, '아래 관찰 방식에 대한 설명으로 옳은 것은?', 'ObservableObject를 채택한 클래스는 변경을 알릴 프로퍼티에 @Published를 붙이고, 뷰는 @ObservedObject 같은 래퍼로 그 객체를 구독한다. @Published 프로퍼티의 값이 바뀔 때 Combine 기반의 변경 알림이 객체 단위로 발행되고, 그 객체를 구독하던 뷰가 다시 그려진다.', 'OBJECTIVE'),
       (5706, 921, '아래 코드를 실행했을 때 changed가 출력되는 시점으로 옳은 것은?', '```swift
import Observation

@Observable
final class PlayerSettings {
    var isMuted = true
    var volume = 5
    var theme = "dark"
}

let settings = PlayerSettings()

withObservationTracking {
    if settings.isMuted {
        print("음소거 중")
    } else {
        print("볼륨 \(settings.volume)")
    }
} onChange: {
    print("changed")
}

settings.theme = "light"    // (가)
settings.volume = 7         // (나)
settings.isMuted = false    // (다)
```', 'OBJECTIVE'),
       (5707, 921, '아래 코드와 표의 조건에서 첫 할 일의 완료 여부를 토글했을 때, body가 다시 평가되는 뷰로 옳은 것은?', '```swift
struct Todo {                       // 구조체
    var title: String
    var isDone: Bool
}

@Observable
final class TodoStore {
    var todos: [Todo] = [
        Todo(title: "장보기", isDone: false),
        Todo(title: "청소", isDone: false)
    ]
    var filter = "전체"
}
```

| 뷰 | body에서 읽는 값 |
| --- | --- |
| TodoListView | store.todos의 각 항목 title·isDone |
| CountBadge | store.todos.count |
| FilterBar | store.filter |

세 뷰는 모두 같은 store를 일반 프로퍼티(let store: TodoStore)로 받는다. 이 상태에서 버튼 동작으로 store.todos[0].isDone.toggle()을 실행했다. 토글 전후로 todos.count는 2 그대로다.', 'OBJECTIVE'),
       (5708, 921, '아래 코드에서 입력창에 글자를 칠 때 SendButton의 body가 다시 평가되는지와 그 이유로 옳은 것은?', '```swift
@Observable
final class ChatViewModel {
    var draft = ""
    var isSending = false
    func send(_ text: String) { /* 서버로 전송 */ }
}

struct SendButton: View {
    let vm: ChatViewModel

    var body: some View {
        Button("보내기") {
            vm.send(vm.draft)
        }
        .disabled(vm.isSending)
    }
}
```

같은 vm의 draft는 옆 입력창(TextField)이 바인딩으로 한 글자씩 고친다. 전송을 시작해 isSending이 true가 되면 SendButton은 곧바로 비활성화된다.', 'OBJECTIVE'),
       (5709, 921, '아래 코드에서 물음표로 가린 멤버의 이름은?', '```swift
import Combine

final class SettingsModel: ObservableObject {
    @Published var nickname = "민"
    @Published var fontSize = 14
}

let model = SettingsModel()
let cancellable = model.?????.sink { _ in
    print("알림, 지금 fontSize = \(model.fontSize)")
}

model.nickname = "준"
model.fontSize = 16
```

실행 결과:

```
알림, 지금 fontSize = 14
알림, 지금 fontSize = 14
```

nickname만 바꿨을 때도 한 줄이 찍혔고, fontSize를 16으로 바꿀 때 찍힌 줄에도 14가 보였다. 이후 모델을 @Observable로 옮기고 @Published를 지우자 다른 코드는 모두 빌드됐지만, 이 구독 줄에서만 SettingsModel에 그런 멤버가 없다는 컴파일 오류가 났다.', 'SUBJECTIVE'),
       (5710, 921, '아래 전환 코드에서 물음표로 가린 자리에 들어갈 이름은?', '```swift
// 전환 후: ObservableObject 채택과 @Published를 지우고 @Observable을 붙였다
@Observable
final class EditorViewModel {
    var title = ""
}

struct EditorScreen: View {
    @????? private var vm = EditorViewModel()

    var body: some View {
        TextField("제목", text: $vm.title)
    }
}
```

가린 자리를 채우기까지의 시도:

1. 아무 표시 없이 private var vm = EditorViewModel()로 두자 $vm.title 줄에서 $vm을 찾을 수 없다는 컴파일 오류가 났다.
2. 전환 전처럼 @StateObject를 붙이자 EditorViewModel이 ObservableObject를 따르지 않는다는 컴파일 오류가 났다.
3. @Bindable을 붙이자 빌드는 됐지만, 상위 화면이 다시 그려질 때마다 입력하던 제목이 빈칸으로 돌아갔다.
4. 가린 이름으로 바꾸자 빌드도 되고, 상위 화면이 다시 그려져도 입력하던 제목이 그대로 남았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5705
(15387, 5705, '뷰가 body에서 읽지 않은 프로퍼티만 바뀌었다면, 같은 모델을 구독하는 그 뷰의 body는 다시 평가되지 않는다.', '프로퍼티마다 의존을 따로 기록하는 @Observable의 동작을 옮겨 온 오개념이다. 이 방식은 알림이 객체 단위라, 뷰가 name만 읽어도 같은 객체의 다른 @Published 값이 바뀌면 body가 다시 평가된다.', false),
(15388, 5705, '모델이 프로퍼티로 품은 다른 ObservableObject의 @Published 값만 바뀌면, 바깥 모델을 구독한 뷰에는 알림이 가지 않는다.', '바깥 모델의 프로퍼티는 안쪽 객체의 참조만 쥐고 있어, 안쪽 값이 바뀌어도 참조가 그대로라 바깥의 알림이 발행되지 않는다. 안쪽 객체를 따로 구독해야 하며, @Observable은 뷰가 읽은 경로를 따라 안쪽 프로퍼티까지 추적한다.', true),
(15389, 5705, '모델을 래퍼 없이 일반 프로퍼티로 받은 자식 뷰도, 그 모델의 변경 알림을 스스로 구독해 다시 그려진다.', '@Observable에서 읽기 전용 전달을 일반 프로퍼티로 하는 규칙을 이 방식에 옮긴 오개념이다. 여기서는 @ObservedObject 같은 래퍼가 있어야 구독이 생기고, 래퍼가 없으면 자식 뷰는 변경 알림을 받지 못한다.', false),
(15390, 5705, '자식 뷰가 @ObservedObject var vm = VM()처럼 직접 만든 모델은, 부모가 다시 그려져도 같은 인스턴스로 유지된다.', '@ObservedObject는 구독만 할 뿐 인스턴스를 소유하지 않는다. 부모가 다시 그려져 자식 뷰 값이 새로 만들어지면 초기화 식이 다시 실행돼 새 모델이 생긴다. 뷰가 직접 만들어 소유할 때는 @StateObject를 써야 한다.', false),

-- 문제 5706
(15391, 5706, '(가)를 실행할 때 출력된다.', '객체의 어느 프로퍼티든 바뀌면 알림이 간다고 본 것은 ObservableObject의 객체 단위 갱신과 섞은 오개념이다. theme은 추적 클로저가 실행되는 동안 한 번도 읽히지 않아 의존으로 등록되지 않았다.', false),
(15392, 5706, '(나)를 실행할 때 출력된다.', 'volume이 클로저 코드에 적혀 있으니 등록됐다고 본 오개념이다. 의존은 코드에 적힌 것이 아니라 실행 중 실제로 읽힌 프로퍼티만 기록된다. isMuted가 true라 else 분기가 실행되지 않아 volume은 읽히지 않았다.', false),
(15393, 5706, '(다)를 실행할 때 출력된다.', '추적 클로저가 실행될 때 isMuted가 true라 if 분기만 돌고, 이때 읽은 isMuted 하나만 의존으로 남는다. 그래서 theme·volume 변경은 지나치고, isMuted가 바뀌기 직전에 onChange가 불려 changed가 찍힌다.', true),
(15394, 5706, '세 줄을 모두 실행해도 출력되지 않는다.', '추적이 SwiftUI의 body 안에서만 동작한다고 본 오개념이다. withObservationTracking은 SwiftUI 없이도 access로 의존을 기록하고 withMutation으로 알린다. 한 번만 불린다는 제약도 첫 알림 자체를 막지는 않는다.', false),

-- 문제 5707
(15395, 5707, '어느 뷰도 다시 평가되지 않는다.', '요소 필드를 고치면 추적되지 않는다고 본 오개념이다. 그것은 요소가 추적되지 않는 클래스여서 배열이 쥔 참조가 그대로일 때의 이야기다. 구조체 배열에서는 요소 수정이 곧 todos 자체의 변경이라 알림이 나간다.', false),
(15396, 5707, 'TodoListView만 다시 평가된다.', '추적이 읽은 결과값을 비교해 달라졌을 때만 알린다고 본 오개념이다. count를 읽는 것도 todos의 get을 거치므로 todos 키 경로 전체가 CountBadge의 의존으로 남는다. 개수가 그대로여도 todos가 바뀌면 무효화된다.', false),
(15397, 5707, 'TodoListView, CountBadge, FilterBar가 모두 다시 평가된다.', '같은 객체를 쓰면 모두 갱신되던 ObservableObject 방식과 혼동한 오개념이다. FilterBar는 filter만 읽었으므로 todos 키 경로로 나간 알림이 닿지 않는다.', false),
(15398, 5707, 'TodoListView와 CountBadge가 다시 평가된다.', 'Todo가 구조체라 요소의 isDone을 고치는 것은 todos 배열에 새 값을 넣는 변경과 같다. todos를 읽은 두 뷰가 무효화되며, CountBadge는 개수가 같아도 todos 전체에 의존하므로 함께 다시 평가된다.', true),

-- 문제 5708
(15399, 5708, '다시 평가되지 않는다. draft는 버튼을 누를 때 실행되는 클로저 안에서만 읽혀 의존으로 등록되지 않았다.', '의존은 body가 평가되는 동안 읽은 프로퍼티에만 등록된다. body 평가 중에는 버튼 클로저가 만들어지기만 하고 실행되지 않아 draft는 읽히지 않는다. body에서 직접 읽은 isSending만 의존으로 남는다.', true),
(15400, 5708, '다시 평가된다. 버튼 클로저가 body 코드 안에 적혀 있으므로 그 안의 draft 읽기도 이 뷰의 의존이 된다.', '클로저가 body 코드 안에 적혀 있다는 것과 body 평가 중에 실행된다는 것을 혼동한 오개념이다. 버튼 동작은 누르는 순간에 실행되고, 그때의 읽기는 어떤 뷰의 의존도 만들지 않는다.', false),
(15401, 5708, '다시 평가된다. 같은 vm 객체를 쓰는 뷰는 어느 프로퍼티가 바뀌든 모두 함께 무효화된다.', 'ObservableObject의 객체 단위 갱신을 옮겨 온 오개념이다. @Observable은 프로퍼티마다 의존을 따로 기록하므로, 이 뷰가 읽지 않은 draft의 변경은 이 뷰를 무효화하지 않는다.', false),
(15402, 5708, '다시 평가되지 않는다. vm을 래퍼 없이 일반 프로퍼티로 받은 뷰에는 어떤 변경 알림도 오지 않는다.', '결론은 맞지만 이유가 틀렸다. 읽기만 하는 뷰는 일반 프로퍼티로 받는 것이 정석이고, 본문처럼 isSending이 바뀌면 이 뷰도 곧바로 갱신된다. 알림 여부는 래퍼가 아니라 body에서 읽었는지로 갈린다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1858, 5709, 'objectWillChange,model.objectWillChange,objectWillChange 퍼블리셔,오브젝트윌체인지', 'objectWillChange는 ObservableObject를 채택하면 자동으로 생기는 퍼블리셔로, @Published가 붙은 어느 프로퍼티든 값이 바뀌기 직전에 한 번 발행된다. 그래서 fontSize와 무관한 nickname 변경에도 알림이 왔고, fontSize를 16으로 바꿀 때도 아직 바뀌기 전이라 14가 읽혔다. $fontSize처럼 프로퍼티마다 따로 있는 퍼블리셔는 그 프로퍼티가 바뀔 때만 값을 내보낸다는 점에서 구분된다. @Observable로 옮기면 ObservableObject 채택과 함께 이 퍼블리셔도 사라지므로, 모델 변화를 받던 코드는 withObservationTracking이나 Observations로 바꿔야 한다.'),
       (1859, 5710, '@State,State,스테이트', '뷰가 직접 만들어 소유하는 @Observable 객체는 @State에 담는다. @State는 인스턴스를 뷰의 수명에 묶어 두므로 상위 화면이 다시 그려져 뷰 값이 새로 만들어져도 처음 만든 객체를 그대로 돌려주고, $vm.title 같은 바인딩도 꺼낼 수 있다. ObservableObject 시절 @StateObject가 맡던 자리를 이어받은 것인데, @StateObject는 ObservableObject를 채택한 타입만 받으므로 전환 후 그대로 두면 컴파일되지 않는다. 헷갈리기 쉬운 @Bindable은 바인딩만 만들어 줄 뿐 인스턴스를 소유하지 않아, 밖에서 전달받은 객체에 붙이는 표시다. 뷰 안에서 객체를 만들며 붙이면 뷰 값이 새로 만들어질 때마다 인스턴스도 새로 생겨 입력이 사라진다.');
