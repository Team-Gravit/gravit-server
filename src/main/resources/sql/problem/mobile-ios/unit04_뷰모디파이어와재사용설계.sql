-- Unit: 뷰 모디파이어와 재사용 설계 (Unit ID: 180)
-- Chapter: iOS (Chapter ID: 17)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (606, 180, '모디파이어 순서와 뷰 분리, 조건부 적용'),
       (764, 180, '중첩 모디파이어와 스타일 재사용, 환경값'),
       (922, 180, 'SwiftUI 모디파이어 순서·상태 보존과 뷰 분리 판단');

-- =====================================================
-- Lesson 606: 모디파이어 순서와 뷰 분리, 조건부 적용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3815, 606, '아래 두 뷰 선언에서 노란 배경이 칠해지는 영역을 옳게 비교한 것은?', '아래 두 뷰 선언을 비교하라. 텍스트 "저장" 자체의 크기는 40×20으로 가정한다.

```swift
// A
Text("저장")
    .padding(20)
    .background(.yellow)
    .frame(width: 200, height: 60)

// B
Text("저장")
    .frame(width: 200, height: 60)
    .padding(20)
    .background(.yellow)
```', 'OBJECTIVE'),
       (3816, 606, '아래 뷰 분리 방법 비교표에서 따라 나오는 결론으로 옳지 않은 것은?', 'body가 길어졌을 때 쓰는 세 가지 분리 방법을 정리한 표다.

| 분리 방법 | 선언 형태 | 정체성 | 부모의 다른 상태가 바뀔 때 |
|---|---|---|---|
| 별도 struct 뷰 | struct RowView: View | 독립된 정체성 | 입력값이 같으면 body 평가를 건너뜀 |
| 계산 프로퍼티 | var header: some View | 부모의 일부 | 부모와 함께 항상 재평가 |
| @ViewBuilder 메서드 | func row(_ item: Item) -> some View | 부모의 일부 | 부모와 함께 항상 재평가 |', 'OBJECTIVE'),
       (3817, 606, '아래 확장을 적용한 뒤 나타난 증상의 원인으로 옳은 것은?', '아래 확장을 만들어 뷰에 적용했다.

```swift
extension View {
    @ViewBuilder
    func `if`<T: View>(_ cond: Bool, transform: (Self) -> T) -> some View {
        if cond { transform(self) } else { self }
    }
}

struct MemoRow: View {
    @Binding var text: String
    @State private var isHighlighted = false

    var body: some View {
        TextField("메모", text: $text)
            .if(isHighlighted) { $0.foregroundStyle(.red) }
    }
}
```

증상: 메모를 편집하는 도중 isHighlighted가 바뀌면 입력 커서가 풀리고, 진행 중이던 페이드 애니메이션이 중간에 끊긴다.', 'OBJECTIVE'),
       (3818, 606, '아래 두 컨테이너 뷰 선언의 차이로 옳은 것은?', '같은 카드 껍데기를 여러 화면에서 쓰려고 컨테이너 뷰를 두 가지 형태로 선언해 보았다.

```swift
// X
struct SectionCardX<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            content()
        }
    }
}

// Y
struct SectionCardY: View {
    let title: String
    let content: () -> AnyView

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            content()
        }
    }
}
```', 'OBJECTIVE'),
       (3819, 606, '아래 상황을 해결하려면 제스처보다 안쪽에 붙여야 하는 뷰 모디파이어의 이름은?', '설정 화면의 한 행을 아래처럼 만들었다.

```swift
HStack {
    Image(systemName: "bell")
    Text("알림")
    Spacer()
}
.frame(maxWidth: .infinity)
.onTapGesture { open() }
```

행 전체가 눌리기를 기대했지만, QA에서 아이콘이나 글자를 정확히 짚었을 때만 화면이 열리고 아이콘과 글자 사이의 빈 곳이나 Spacer가 차지한 오른쪽 여백을 누르면 아무 반응이 없다는 보고가 올라왔다. 행에는 배경색을 지정하지 않았다.', 'SUBJECTIVE'),
       (3820, 606, '아래 상황에서 CardStyle 구조체가 채택한 SwiftUI 프로토콜의 이름은?', '카드 UI를 만드는 padding(16) → background(...) → clipShape(...) → shadow(...) 네 줄 조합이 화면 일곱 곳에 그대로 복사되어 있었다. 디자이너가 그림자 반경을 8에서 4로 낮추자고 하자 일곱 파일을 모두 고쳐야 했고, 한 곳을 빠뜨려 QA에서 걸렸다. 그래서 아래처럼 정리했다.

```swift
struct CardStyle: <이 자리에 들어갈 프로토콜> {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3815
(10347, 3815, 'A는 200×60, B는 240×100 영역이 노랗게 칠해진다.', 'frame이 background보다 바깥에 붙어 있어 이미 정해진 배경을 넓히지 못한다. A의 배경은 여백까지만 감싼 80×60이고, frame은 그 뷰를 200×60 안에 가운데로 놓을 뿐이다.', false),
(10348, 3815, 'A는 80×60, B는 240×100 영역이 노랗게 칠해진다.', 'A는 padding(20) 다음에 background가 와서 40×20 텍스트에 사방 여백을 더한 80×60이 칠해지고, frame은 그 결과를 200×60 안에 배치할 뿐이다. B는 200×60 프레임에 여백을 더한 240×100이 배경 범위가 된다.', true),
(10349, 3815, 'A는 240×100, B는 80×60 영역이 노랗게 칠해진다.', '두 체인의 순서를 뒤바꿔 읽은 것이다. 나중에 쓴 모디파이어일수록 바깥쪽이므로, background는 자기보다 앞에 쓴 부분까지만 감싼다.', false),
(10350, 3815, 'A와 B 모두 200×60 영역이 노랗게 칠해진다.', '뷰의 최종 크기와 배경이 칠해지는 영역을 같게 본 오해다. B의 최종 크기는 240×100이고, A의 배경은 프레임보다 작은 80×60에 머문다.', false),

-- 문제 3816
(10351, 3816, '프로파일링에서 무거운 차트 뷰가 매번 다시 평가된다면, 계산 프로퍼티로 빼는 것만으로는 해결되지 않는다.', '표에서 계산 프로퍼티는 부모와 함께 항상 재평가된다. 재평가를 건너뛰게 하려면 독립된 정체성을 갖는 별도 struct로 빼야 하므로 이 진술은 참이다.', false),
(10352, 3816, '자기만의 @State를 가져야 하는 부분은 계산 프로퍼티로 나눌 수 없고 별도 struct가 필요하다.', '계산 프로퍼티는 부모의 일부라 자체 저장소를 가질 수 없다. @State를 소유하려면 독립된 정체성을 가진 struct 뷰여야 하므로 이 진술은 참이다.', false),
(10353, 3816, '계산 프로퍼티와 @ViewBuilder 메서드는 재평가 범위가 같고, 매개변수를 받을 수 있는지만 다르다.', '표에서 두 방법은 정체성과 재평가 열이 똑같고 선언 형태만 다르다. 인자가 필요하면 메서드, 아니면 계산 프로퍼티를 고르는 문제이므로 이 진술은 참이다.', false),
(10354, 3816, 'body를 계산 프로퍼티 셋으로 나누면, 상태가 바뀔 때 그중 관련된 하나만 다시 평가된다.', '표의 "부모와 함께 항상 재평가"에 정면으로 걸린다. 계산 프로퍼티는 코드 정리일 뿐 렌더 단위를 쪼개지 않으므로 셋 모두 다시 평가된다.', true),

-- 문제 3817
(10355, 3817, 'if와 else 두 갈래가 서로 다른 뷰 타입을 반환해 구조적 정체성이 바뀌고, 기존 뷰가 사라진 뒤 새 뷰가 만들어지기 때문이다.', '조건이 참일 때는 ModifiedContent, 거짓일 때는 원본 타입이 나온다. 타입이 갈리면 if/else로 뷰를 나눈 것과 같아 정체성이 바뀌고, 포커스나 진행 중인 애니메이션처럼 정체성에 매인 상태가 함께 버려진다.', true),
(10356, 3817, 'transform이 값 타입인 Self를 복사해 받아 원본 뷰와 상태 저장소를 공유하지 못하기 때문이다.', '뷰가 값 타입인 것은 맞지만 상태 저장소는 뷰 값이 아니라 정체성에 묶여 SwiftUI가 따로 보관한다. 값 복사 자체는 상태를 끊지 않는다.', false),
(10357, 3817, '@ViewBuilder가 붙은 함수는 호출될 때마다 하위 뷰를 처음부터 다시 만들도록 표시하기 때문이다.', '@ViewBuilder는 나열된 뷰를 하나로 합쳐 주는 결과 빌더일 뿐 재생성을 지시하지 않는다. 문제는 반환 타입이 조건에 따라 갈리는 데 있다.', false),
(10358, 3817, 'foregroundStyle처럼 외형을 바꾸는 모디파이어는 적용되거나 해제될 때 대상 뷰를 다시 만들기 때문이다.', '모디파이어는 대상 뷰를 감싼 새 뷰를 반환할 뿐 정체성을 바꾸지 않는다. foregroundStyle(isHighlighted ? .red : .primary)처럼 값만 조건부로 바꾸면 증상이 사라진다.', false),

-- 문제 3818
(10359, 3818, 'X는 @ViewBuilder 때문에 내용 뷰를 하나만 넘길 수 있고, Y는 개수 제한 없이 나열할 수 있다.', '@ViewBuilder는 오히려 나열된 여러 뷰를 하나로 합쳐 주는 장치다. 내용을 사실상 하나로 제한하는 쪽은 그 장치가 없는 Y다.', false),
(10360, 3818, '호출부 코드는 X와 Y가 같고, 컴파일 시간만 제네릭을 쓴 X가 더 오래 걸린다.', 'Y는 클로저 반환 타입이 AnyView라 호출부가 AnyView(...)로 직접 감싸야 한다. 컴파일 시간을 따지기 전에 호출부 코드부터 달라진다.', false),
(10361, 3818, 'X는 중괄호 안에 여러 뷰를 나열해도 그대로 전달되지만, Y는 호출부에서 AnyView로 감싸 넘겨야 한다.', '@ViewBuilder를 붙인 클로저는 나열한 뷰들을 TupleView 하나로 묶어 준다. 그런 변환이 없는 Y는 반환 타입을 맞추려고 호출부가 AnyView 래핑을 직접 해야 한다.', true),
(10362, 3818, 'Y는 내용의 구체 타입을 그대로 들고 있어, 내용이 같을 때 재평가를 건너뛰기에 더 유리하다.', '거꾸로다. AnyView는 타입을 지워 앞뒤 값을 비교하기 어렵게 만든다. 구체 타입을 유지해 최적화에 유리한 쪽은 제네릭 Content를 쓴 X다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1228, 3819, 'contentShape,.contentShape,contentShape(),contentShape(Rectangle()),.contentShape(Rectangle()),콘텐츠셰이프,콘텐츠 셰이프', '배경이 지정되지 않은 영역은 히트 테스트 대상에서 빠지므로 탭이 그대로 통과한다. contentShape(Rectangle())을 onTapGesture보다 안쪽에 두면 프레임 전체가 탭 판정 도형이 되어 아이콘 사이의 빈 곳과 Spacer 영역까지 반응한다. 그리기 영역을 잘라 내는 clipShape나 탭을 통째로 막는 allowsHitTesting(false)과는 역할이 다르다. 제스처보다 바깥에 붙이면 이미 좁아진 판정 영역에 적용되므로, 여기서도 모디파이어 순서가 곧 결과다.'),
       (1229, 3820, 'ViewModifier,View Modifier,뷰 모디파이어,뷰모디파이어', 'body(content:) 하나만 요구하고 modifier(_:)로 적용되는 것이 ViewModifier다. 매개변수 content가 원본 뷰라서 거기에 모디파이어를 이어 붙이면 조합 전체가 한 타입에 담기고, 일곱 곳에 흩어져 있던 네 줄이 cardStyle() 한 줄로 줄어든다. @State나 @Environment를 프로퍼티로 가질 수 있어 다크 모드별 그림자처럼 환경에 반응하는 스타일도 담을 수 있다. 상태 없이 조합만 묶을 것이라면 View 확장만으로도 충분하고, 눌림 상태까지 다뤄야 하는 버튼은 ButtonStyle이 맞는 자리다.');

-- =====================================================
-- Lesson 764: 중첩 모디파이어와 스타일 재사용, 환경값
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4763, 764, '아래 칩의 회색 테두리가 시안과 어긋난 원인으로 옳은 것은?', '태그 칩을 아래처럼 만들었다.

```swift
struct TagChip: View {
    var body: some View {
        Text("신규")
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.yellow)
            .cornerRadius(10)
            .border(.gray, width: 1)
    }
}
```

증상: 노란 배경은 네 모서리가 반지름 10만큼 둥글게 깎여 나왔는데, 회색 선만 직각 사각형으로 그려져 모서리마다 배경 바깥으로 삐져나온다.', 'OBJECTIVE'),
       (4764, 764, '아래 계측 결과에서 aggregate의 재실행을 없애는 조치로 옳은 것은?', '보고서 화면의 코드와 계측 결과다.

```swift
struct ReportView: View {
    let rows: [Row]                          // 화면이 떠 있는 동안 바뀌지 않는다
    @State private var isExpanded = false    // 헤더 접기·펴기

    private var summaryChart: some View {
        ChartCanvas(points: aggregate(rows))    // aggregate는 평균 80ms
    }

    var body: some View {
        VStack {
            Header(isExpanded: $isExpanded)
            if isExpanded { DetailList(rows: rows) }
            summaryChart
        }
    }
}
```

계측: 헤더를 한 번 접거나 펼 때마다 aggregate가 다시 실행돼 80ms를 쓴다. 그동안 rows는 한 번도 바뀌지 않았고, isExpanded는 헤더 모양과 DetailList의 표시 여부를 함께 정하므로 ReportView가 계속 소유해야 한다.', 'OBJECTIVE'),
       (4765, 764, '아래 비교표에서 따라 나오는 결론으로 옳은 것은?', '반복되는 스타일을 한곳에 묶는 세 가지 수단을 정리한 표다.

| 수단 | 적용 방법 | 자체 상태·환경값 | 눌림 같은 상호작용 상태 |
|---|---|---|---|
| ViewModifier를 채택한 struct | .modifier(CardStyle()) | @State·@Environment 프로퍼티를 가질 수 있음 | 읽을 경로 없음 |
| View 확장 메서드 | .cardStyle() | 없음. 모디파이어 조합만 이어 붙여 반환 | 읽을 경로 없음 |
| ButtonStyle을 채택한 struct | .buttonStyle(ScaleStyle()) | @Environment 프로퍼티를 가질 수 있음 | makeBody(configuration:)에서 configuration.isPressed로 읽음 |', 'OBJECTIVE'),
       (4766, 764, '아래 body가 그리는 두 줄의 모습으로 옳은 것은?', '같은 Text 값을 프로퍼티에 담아 두고 두 줄에 나눠 썼다.

```swift
struct PriceRow: View {
    let amount = Text("12,000원")

    var body: some View {
        VStack(alignment: .trailing) {
            amount
                .foregroundStyle(.red)
                .strikethrough()

            amount
                .font(.title)
        }
    }
}
```', 'OBJECTIVE'),
       (4767, 764, '아래 상황에서 팀이 새로 도입한 SwiftUI 값 전달 방식의 이름은?', '설정 화면의 뷰 계층은 RootView → TabHost → SettingsPage → SectionCard → ToggleRow 순으로 다섯 단계다. 브랜드 강조 색은 RootView가 정하고 말단의 ToggleRow만 쓰는데, 값을 내려보내려고 중간의 TabHost·SettingsPage·SectionCard에까지 쓰지도 않는 accent 프로퍼티를 달아 그대로 넘기기만 했다. 화면을 하나 추가할 때마다 같은 프로퍼티를 또 달아야 했고, 한 곳에서 넘기기를 빠뜨리자 그 아래 전부가 기본 색으로 나왔다.

방식을 바꾼 뒤에는 RootView의 body 끝에 값을 심는 모디파이어 한 줄만 붙였다. 중간 세 뷰의 accent 프로퍼티를 모두 지웠는데도 ToggleRow는 부모에게서 아무것도 받지 않고 색을 제대로 읽었고, RootView에서 색을 오렌지로 바꾸자 그 아래 화면의 모든 ToggleRow가 한 번에 오렌지로 다시 그려졌다.', 'SUBJECTIVE'),
       (4768, 764, '아래 출력에서 □ 자리에 공통으로 들어가는 제네릭 타입의 이름은?', '플레이그라운드에서 타입을 찍어 봤다. 출력 중 이름 하나만 □로 가렸다.

```swift
let plain = Text("합계")
let styled = plain
    .padding()
    .background(.yellow)

print(type(of: plain))
// Text

print(type(of: styled))
// □<□<Text, _PaddingLayout>, _BackgroundModifier>
```

plain에 두 줄을 이어 붙였는데도 plain을 찍은 결과는 그대로 Text이고, styled는 안쪽부터 Text·패딩·배경 순으로 겹겹이 들어앉은 이름 하나로 찍힌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4763
(12875, 4763, 'cornerRadius가 배경에만 적용되고 그보다 안쪽의 Text에는 적용되지 않아, 테두리가 따라갈 둥근 형태가 만들어지지 않았다.', 'cornerRadius는 자기보다 안쪽 체인 전체를 한 덩어리로 잘라 낸다. 텍스트와 여백과 배경이 함께 깎였고, 배경 모서리가 둥글게 나온 것이 그 증거다. 형태가 없는 것이 아니라 그 형태를 border가 참고하지 않는 것이 문제다.', false),
(12876, 4763, 'border는 늘 안쪽 콘텐츠 크기를 기준으로 선을 그어, 패딩으로 넓어진 영역을 반영하지 못한다.', 'border는 안쪽 콘텐츠가 아니라 자기가 감싼 뷰의 경계에 선을 긋는다. 패딩이 포함된 크기를 그대로 따라가므로 선의 가로세로 크기는 배경과 같고, 어긋난 것은 크기가 아니라 모서리 모양이다.', false),
(12877, 4763, 'border가 cornerRadius로 깎인 뷰를 다시 감싸, 그 뷰의 직사각형 경계를 따라 선을 긋기 때문이다.', '모디파이어는 대상을 고치지 않고 감싼 새 뷰를 돌려준다. 나중에 쓴 border가 바깥에 놓여 이미 잘린 결과를 또 감싸는데 그 뷰의 경계는 여전히 직사각형이다. overlay로 RoundedRectangle(cornerRadius: 10).stroke를 얹으면 곡률이 맞는다.', true),
(12878, 4763, '체인에서 나중에 쓴 모디파이어일수록 안쪽에 놓이므로, border가 cornerRadius보다 먼저 그려졌다.', '순서 규칙을 거꾸로 외운 것이다. 나중에 쓴 모디파이어일수록 바깥쪽에 놓인다. 여기서는 cornerRadius가 안쪽, border가 바깥쪽이라 이미 둥글게 잘린 결과 위에 직각 선이 덧그려진다.', false),

-- 문제 4764
(12879, 4764, 'summaryChart를 rows를 입력으로 받는 별도 struct 뷰로 빼낸다.', '별도 struct 뷰는 독립된 정체성을 가져 입력이 이전과 같으면 body 평가를 통째로 건너뛴다. rows가 그대로이므로 isExpanded를 아무리 토글해도 그 뷰 안의 aggregate 호출까지 가지 않는다.', true),
(12880, 4764, 'summaryChart를 rows를 인자로 받는 @ViewBuilder 메서드로 바꾼다.', '@ViewBuilder 메서드는 계산 프로퍼티와 마찬가지로 부모의 일부라, 부모 body가 돌 때마다 함께 호출된다. 인자를 받을 수 있다는 점만 다를 뿐 재평가 범위는 조금도 줄지 않아 aggregate도 그대로 다시 실행된다.', false),
(12881, 4764, 'VStack을 LazyVStack으로 바꿔 필요한 부분만 평가되게 한다.', 'Lazy 계열 컨테이너는 스크롤 뷰 안에서 아직 화면에 들어오지 않은 항목의 생성을 미루는 장치다. 차트는 이미 화면에 보이므로 미룰 대상이 아니고, 부모가 다시 평가되면 값도 그대로 따라 계산된다.', false),
(12882, 4764, 'isExpanded를 Header와 DetailList로 내려보내 하위 뷰가 각각 소유하게 한다.', '두 뷰가 같은 값을 따로 들면 접힘 상태가 서로 어긋난다. 상태를 내려보내는 것은 좋은 습관이지만, summaryChart가 부모의 계산 프로퍼티로 남아 있는 한 부모 body가 도는 어떤 이유에도 다시 계산된다.', false),

-- 문제 4765
(12883, 4765, '다크 모드에 따라 그림자 색을 바꾸는 스타일은 세 수단 중 View 확장으로만 만들 수 있다.', '환경값 프로퍼티를 가질 수 있는 쪽은 ViewModifier와 ButtonStyle이고, View 확장은 자체 상태·환경값이 없는 칸이다. 조합을 이어 붙이기만 하는 확장이 오히려 환경에 반응하기 어렵다.', false),
(12884, 4765, 'ViewModifier가 @State를 가질 수 있으니, 같은 스타일 값을 두 뷰에 적용하면 두 뷰가 그 상태를 함께 쓴다.', '@State 저장소는 스타일 값이 아니라 적용된 자리의 정체성에 매인다. 같은 CardStyle()을 두 곳에 붙여도 저장소는 둘로 나뉘어, 한쪽에서 일어난 변화가 다른 쪽을 건드리지 않는다.', false),
(12885, 4765, '적용 방법이 서로 달라, View 확장으로 만든 스타일 뒤에는 다른 모디파이어를 이어 붙일 수 없다.', '적용 방법 칸은 호출 형태를 적어 둔 것일 뿐이다. 확장 메서드도 뷰를 감싼 새 뷰를 돌려주므로 .cardStyle().padding(8)처럼 평소대로 체인을 이어 갈 수 있다.', false),
(12886, 4765, '누르고 있는 동안에만 줄었다가 손을 떼면 돌아오는 효과는 커스텀 모디파이어로 옮겨 담을 수 없다.', '눌림 상태를 읽을 경로는 ButtonStyle의 configuration.isPressed 하나뿐이다. ViewModifier와 View 확장은 자신이 감싼 뷰가 눌렸는지 알 방법이 없어, 버튼 계열 스타일은 ButtonStyle로 만드는 것이 맞다.', true),

-- 문제 4766
(12887, 4766, '두 줄 모두 취소선이 그어진 빨간 글씨가 되고, 아랫줄만 글자 크기가 커진다.', '모디파이어를 amount라는 값을 고치는 명령으로 본 오해다. 모디파이어는 원본을 그대로 두고 감싼 새 뷰를 돌려주므로, 윗줄에 붙인 색과 취소선은 그 새 뷰 안에만 남는다.', false),
(12888, 4766, '윗줄은 취소선이 그어진 빨간 글씨, 아랫줄은 취소선 없는 기본 색의 큰 글씨가 된다.', 'amount는 두 번 다 원래의 Text 그대로 쓰인다. 윗줄은 그것을 색과 취소선으로 감싼 뷰, 아랫줄은 글꼴로만 감싼 뷰라 서로 다른 뷰가 되고 스타일이 옆으로 번지지 않는다.', true),
(12889, 4766, '아랫줄에도 빨간색은 남고 취소선만 사라진 큰 글씨가 된다.', 'foregroundStyle이 뷰 값 자체에 색을 칠해 둔다고 본 오해다. 색은 그 모디파이어가 감싼 범위 안으로만 내려가고, 아랫줄은 그 범위 밖이라 기본 색으로 그려진다.', false),
(12890, 4766, 'amount가 let 상수라 처음 적용한 스타일로 고정되고, 아랫줄의 font는 무시된다.', 'let은 뷰 값을 담은 상수일 뿐이라 그 값을 감싸는 새 뷰는 얼마든지 만들 수 있다. 원본을 바꾸지 않을 뿐 적용 자체를 막지 않으므로, 아랫줄의 font는 정상적으로 반영돼 글자가 커진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1544, 4767, '환경값,환경 값,Environment,EnvironmentValues,EnvironmentKey,@Environment,environment,뷰 환경', '상위 뷰가 한 번 심어 두면 뷰 트리를 따라 함께 내려가 하위 어디서든 꺼내 쓰는 값 저장소가 환경값이다. RootView에서 .environment(\.brandAccent, .orange)로 심고 말단에서 @Environment(\.brandAccent)로 읽으면, 중간 뷰는 전달자 노릇을 하지 않아도 되고 값이 바뀌면 그 값을 읽는 뷰가 다시 그려진다. 직접 만든 키는 EnvironmentKey를 채택해 defaultValue를 주고 EnvironmentValues의 계산 프로퍼티로 등록한다. 참조 타입 객체 하나를 트리에 꽂아 공유하는 @EnvironmentObject, 부모가 자식에게 값을 직접 쥐여 주고 쓰기 권한까지 넘기는 @Binding과는 전달 경로가 다르다.'),
       (1545, 4768, 'ModifiedContent,Modified Content,모디파이드콘텐트,모디파이드 콘텐트,모디파이드콘텐츠,모디파이드 콘텐츠', '모디파이어를 호출하면 원본 뷰를 고치는 대신, 원본 뷰 타입과 모디파이어 타입을 매개변수로 묶은 ModifiedContent를 새로 만들어 돌려준다. 그래서 plain은 Text로 남고, 체인이 길어질수록 ModifiedContent가 겹겹이 쌓이며 나중에 쓴 모디파이어가 가장 바깥에 온다. 이 중첩 순서가 곧 크기 협상과 그리기 순서라, padding과 background의 자리를 바꾸면 배경이 칠해지는 범위가 달라진다. 여러 뷰를 나열해 하나로 묶는 TupleView, 구체 타입을 지워 감추는 AnyView와는 역할이 다르다.');

-- =====================================================
-- Lesson 922: SwiftUI 모디파이어 순서·상태 보존과 뷰 분리 판단
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5711, 922, '아래 요구 사항대로 태그 칩을 그리는 코드는?', '디자인 시안에 적힌 "신규" 태그 칩의 요구 사항이다.

- 글자 둘레로 노란 배경이 사방 12만큼 넉넉하게 칠해져야 한다.
- 노란 칩 바깥으로 사방 8만큼은 아무것도 칠하지 않은 투명한 간격을 두어, 옆에 놓인 요소와 떨어뜨린다.', 'OBJECTIVE'),
       (5712, 922, '아래 코드에서 조작을 마친 뒤 두 행 옆에 표시되는 숫자로 옳은 것은?', '과일 목록의 각 행에 탭 횟수를 세는 커스텀 모디파이어를 붙였다.

```swift
struct TapBadge: ViewModifier {
    @State private var count = 0

    func body(content: Content) -> some View {
        HStack {
            content
            Text("\(count)")
        }
        .onTapGesture { count += 1 }
    }
}

struct FruitList: View {
    @State private var title = "과일"

    var body: some View {
        VStack {
            Text(title)
            Button("제목 바꾸기") { title = "오늘의 과일" }
            Text("사과").modifier(TapBadge())
            Text("배").modifier(TapBadge())
        }
    }
}
```

조작 순서: ① "사과"를 세 번 누른다 → ② "제목 바꾸기" 버튼을 누른다 → ③ "배"를 한 번 누른다.', 'OBJECTIVE'),
       (5713, 922, '아래 코드에서 토글을 다시 켠 직후 A와 B 입력칸의 모습으로 옳은 것은?', '같은 메모 입력 뷰를 두 가지 방식으로 숨기고 보이게 했다.

```swift
struct MemoBox: View {
    @State private var text = ""

    var body: some View {
        TextField("메모", text: $text)
    }
}

struct NoteScreen: View {
    @State private var show = true

    var body: some View {
        VStack {
            if show { MemoBox() }                // A
            MemoBox().opacity(show ? 1 : 0)      // B
            Toggle("메모 표시", isOn: $show)
        }
    }
}
```

조작 순서: A에 "우유", B에 "계란"을 입력한다 → 토글을 끈다 → 토글을 다시 켠다.', 'OBJECTIVE'),
       (5714, 922, '아래 코드에서 검색창에 한 글자를 입력했을 때 콘솔에 찍히는 이름으로 옳은 것은?', '대시보드 화면 코드다. 각 body와 header는 평가될 때 첫 줄에서 자기 이름을 콘솔에 찍는다.

```swift
struct SearchField: View {
    @State private var query = ""

    var body: some View {
        let _ = print("SearchField")
        HStack {
            TextField("검색", text: $query)
            Text("\(query.count)/20")
        }
    }
}

struct DashboardView: View {
    @State private var points: [Int] = [3, 5, 2]

    private var header: some View {
        print("header")
        return Text("합계 \(points.reduce(0, +))")
    }

    var body: some View {
        let _ = print("Dashboard")
        VStack {
            header
            SearchField()
            ChartView(points: points)   // ChartView의 body 첫 줄: let _ = print("Chart")
        }
    }
}
```

화면이 뜬 뒤 콘솔을 비웠고, 검색창에 포커스가 있는 상태에서 한 글자를 입력했다.', 'OBJECTIVE'),
       (5715, 922, '아래 상황에서 row 메서드 선언 바로 위에 붙인 속성의 이름은?', '주문 목록에서 행을 그리는 부분을 매개변수가 있는 메서드로 떼어 냈다.

```swift
struct OrderList: View {
    let items: [Item]

    func row(_ item: Item) -> some View {
        if item.isSoldOut {
            return Text(item.name).strikethrough()
        } else {
            return HStack {
                Text(item.name)
                Spacer()
                Text("\(item.price)원")
            }
        }
    }

    var body: some View {
        List(items) { item in
            row(item)
        }
    }
}
```

컴파일 오류:
Function declares an opaque return type ''some View'', but the return statements in its body do not have matching underlying types

같은 if/else를 body 안에 직접 썼을 때는 오류가 나지 않았다. 두 return을 지우고 row 선언 바로 위에 속성 한 줄을 붙이자 컴파일이 통과했고, 품절 행과 일반 행이 모두 제대로 그려졌다.', 'SUBJECTIVE'),
       (5716, 922, '아래 상황에서 □ 자리에 들어갈 SwiftUI 프로토콜의 이름은?', '결제 화면의 버튼 12개에 아래 커스텀 모디파이어를 붙여 모양을 맞췄다.

```swift
struct PayLook: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.yellow)
            .clipShape(Capsule())
    }
}

Button("결제하기") { pay() }
    .modifier(PayLook())
```

QA 보고: 노란 캡슐에서 글자 바깥 부분을 누르면 결제가 시작되지 않는다. 누르는 동안 글자만 살짝 흐려질 뿐 캡슐은 그대로라 눌렸는지 알아보기 어렵다.

각 버튼의 .modifier(PayLook()) 줄을 지우고 아래 구조체를 만든 뒤, 화면 최상단 VStack에 한 번만 적용했다. 그 밖에는 12개 버튼의 라벨과 action 코드를 한 줄도 고치지 않았는데, 이제 캡슐 어디를 눌러도 결제가 시작되고 누르는 동안 캡슐 전체가 흐려진다.

```swift
struct PayCapsule: □ {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.yellow)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5711
(15403, 5711, 'Text("신규").padding(8).background(.yellow).padding(12)', '먼저 쓴 모디파이어가 바깥에 놓인다고 거꾸로 읽은 것이다. 나중에 쓴 것일수록 바깥이므로 이 코드는 노란 배경이 사방 8, 그 바깥의 투명 간격이 12가 되어 두 값이 뒤바뀐다.', false),
(15404, 5711, 'Text("신규").padding(12).background(.yellow).padding(8)', 'background는 자기보다 앞에 쓴 부분까지만 감싸 칠한다. padding(12) 뒤에 background가 와서 여백 12까지 노랗게 칠해지고, 그 결과를 다시 감싼 padding(8)은 칠해지지 않는 바깥 간격이 된다.', true),
(15405, 5711, 'Text("신규").padding(12).padding(8).background(.yellow)', '두 padding이 모두 background보다 앞에 있어 배경이 사방 20까지 한꺼번에 칠해진다. 숫자는 시안과 같지만 노란 칩 바깥에 남는 투명 간격이 없다.', false),
(15406, 5711, 'Text("신규").background(.yellow).padding(12).padding(8)', 'background가 여백보다 먼저 붙어 글자 크기만큼만 노랗게 칠해진다. 뒤의 두 padding은 모두 칠해지지 않는 간격이 되어, 글자에 딱 붙은 노란 바탕 바깥으로 사방 20의 빈 여백만 생긴다.', false),

-- 문제 5712
(15407, 5712, '사과 행 0, 배 행 1', '제목이 바뀌며 FruitList의 body가 다시 평가되고 TapBadge() 값도 새로 만들어진다. 하지만 @State 저장소는 구조체 값이 아니라 뷰 트리의 자리에 묶여 있어, 자리가 그대로인 사과 행의 3은 유지된다.', false),
(15408, 5712, '사과 행 4, 배 행 4', '같은 TapBadge 타입이면 count 하나를 함께 쓴다고 본 오해다. @State 저장소는 모디파이어를 적용한 자리마다 따로 생기므로, 사과 행과 배 행의 숫자는 서로 영향을 주지 않는다.', false),
(15409, 5712, '사과 행 0, 배 행 0', 'ViewModifier 안의 @State는 동작하지 않는다고 본 오해다. ViewModifier도 @State를 가질 수 있고, count가 바뀌면 그 모디파이어의 body가 다시 평가되어 숫자가 갱신된다.', false),
(15410, 5712, '사과 행 3, 배 행 1', '모디파이어를 적용한 자리마다 @State 저장소가 따로 생기고, 부모 body가 다시 평가되어 TapBadge()가 새로 만들어져도 자리가 같으면 저장소는 유지된다. 그래서 두 행은 각자 눌린 횟수만 센다.', true),

-- 문제 5713
(15411, 5713, 'A는 비어 있고, B에는 "계란"이 남아 있다.', 'A는 show가 거짓이 되는 순간 뷰 트리에서 빠지며 @State도 함께 버려지고, 다시 켜면 새 MemoBox로 만들어진다. B는 늘 같은 자리에 있고 opacity 값만 바뀌므로 입력한 글자가 그대로 남는다.', true),
(15412, 5713, 'A에는 "우유", B에는 "계란"이 남아 있다.', '숨기는 방식과 상관없이 상태가 남는다고 본 오해다. if로 감싼 A는 트리에서 아예 빠졌다가 다시 들어오므로, 빈 @State를 가진 새 뷰로 시작한다.', false),
(15413, 5713, 'A에는 "우유"가 남아 있고, B는 비어 있다.', '두 방식을 뒤바꿔 이해한 것이다. opacity(0)은 투명하게 그릴 뿐 뷰를 트리에서 빼지 않아 B의 상태가 유지되고, 트리에서 빠졌다 돌아오는 쪽은 if로 감싼 A다.', false),
(15414, 5713, 'A와 B 모두 비어 있다.', '화면에서 안 보이면 무조건 상태가 초기화된다고 본 오해다. B는 투명해졌을 뿐 같은 자리에 계속 있어 정체성과 @State가 그대로 유지된다.', false),

-- 문제 5714
(15415, 5714, 'Dashboard, header, SearchField가 차례로 찍힌다.', '자식의 상태가 바뀌면 부모 body도 다시 평가된다고 본 오해다. query는 SearchField가 소유하고 DashboardView는 읽지 않으므로, 부모와 그 계산 프로퍼티인 header는 평가되지 않는다.', false),
(15416, 5714, 'Dashboard, SearchField만 찍히고 header는 건너뛴다.', '계산 프로퍼티가 별도 struct처럼 따로 건너뛰어진다고 본 오해다. header는 부모의 일부라 부모가 평가되면 반드시 함께 평가된다. 더구나 여기서는 query를 읽지 않는 부모 자체가 평가되지 않는다.', false),
(15417, 5714, 'SearchField만 찍히고 나머지 셋은 찍히지 않는다.', 'query를 소유하고 읽는 뷰는 SearchField뿐이라 그 body만 다시 평가된다. 상태를 쓰는 곳으로 내려보냈기 때문에 입력이 부모를 건드리지 않아, 부모의 header와 ChartView도 평가 대상에서 빠진다.', true),
(15418, 5714, 'Dashboard, header, SearchField, Chart가 모두 찍힌다.', '상태 하나가 바뀌면 화면 전체가 다시 평가된다고 본 오해다. SwiftUI는 바뀐 상태에 의존하는 뷰만 다시 평가하므로, query와 무관한 DashboardView와 ChartView는 평가되지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1860, 5715, 'ViewBuilder,@ViewBuilder,View Builder,뷰빌더,뷰 빌더', '@ViewBuilder는 결과 빌더(result builder)라서, 메서드 안의 if/else 두 갈래를 _ConditionalContent라는 하나의 타입으로 묶어 some View의 실제 타입을 하나로 맞춰 준다. body 안에서 오류가 없었던 것은 View 프로토콜의 body 요구 사항에 이미 @ViewBuilder가 붙어 있어 구현에도 그대로 적용되기 때문이다. return을 지운 까닭은 명시적인 return이 있으면 결과 빌더 변환이 꺼지기 때문이다. 타입을 지워 억지로 맞추는 AnyView와 달리 두 갈래의 구체 타입이 그대로 남는다. 또 이렇게 메서드로 뗀 뷰는 별도 struct가 아니라 부모의 일부라서, 부모 body가 다시 평가될 때마다 함께 호출된다는 점도 구분해 둔다.'),
       (1861, 5716, 'ButtonStyle,Button Style,버튼스타일,버튼 스타일', 'ButtonStyle은 버튼의 라벨과 동작은 그대로 두고 외형만 바꾸는 스타일 프로토콜로, makeBody(configuration:)에서 configuration.label로 라벨을, configuration.isPressed로 눌림 여부를 받는다. 커스텀 모디파이어는 Button의 바깥을 감싸므로 여백과 배경이 버튼의 탭 영역에 들어가지 않고 눌림 여부도 알 수 없었다. 반면 makeBody가 돌려준 뷰는 버튼 자신의 모습이 되어 캡슐 전체가 눌리는 영역이 된다. .buttonStyle(PayCapsule())로 적용하며, 이 설정은 환경값을 타고 하위 버튼 모두에 전해지므로 VStack에 한 번만 붙여도 된다. 버튼이 아닌 뷰에도 붙이는 ViewModifier, 눌림 여부 대신 탭 처리 자체를 직접 정할 때 쓰는 PrimitiveButtonStyle과 구분한다.');
