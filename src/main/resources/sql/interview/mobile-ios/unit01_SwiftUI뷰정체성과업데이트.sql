-- Unit: SwiftUI 뷰 정체성과 업데이트 (Unit ID: 177)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(881, 'SWIFTUI', 177, 'HARD', true,
 '펼침/접힘 카드를 if/else 분기로 구현했더니 카드 안의 입력값이 초기화되고 높이 애니메이션도 동작하지 않습니다. 뷰 정체성 관점에서 원인과 해결 방법을 설명해 주시겠어요?',
 'SwiftUI는 뷰 트리에서의 위치로 정체성을 판단하는데, if/else의 두 분기는 트리상 서로 다른 위치이므로 같은 CardView라도 서로 다른 구조적 정체성을 가집니다. 그래서 isExpanded가 바뀌면 이전 분기의 뷰는 제거되고 다른 분기의 뷰가 새로 생성됩니다. @State의 수명은 뷰 값이 아니라 뷰의 정체성에 묶여 있기 때문에, 정체성이 바뀌는 순간 내부 @State가 초기화되어 입력값이 사라지고, 서로 다른 뷰가 교체되는 것이므로 크기 애니메이션도 불가능합니다. 해결 방법은 분기를 없애고 CardView().frame(height: isExpanded ? 200 : 80)처럼 삼항 연산자로 모디파이어 파라미터만 바꾸는 것입니다. 이렇게 하면 같은 뷰가 계속 유지되어 정체성이 같으므로 상태가 보존되고, 같은 뷰의 속성만 바뀌기 때문에 withAnimation으로 높이가 자연스럽게 변합니다.',
 'interview-question/881.mp3'),
(882, 'SWIFTUI', 177, 'NORMAL', true,
 'SwiftUI의 View가 구조체로 만들어지는 이유를 UIKit의 UIView와 비교해 설명해 주시겠어요?',
 'UIKit의 UIView는 클래스이고 화면 위에 실제로 존재하는 객체인 반면, SwiftUI의 View는 대부분 구조체로 무엇을 보여줄지를 기술한 값, 즉 UI의 선언일 뿐입니다. UIView는 개발자가 생성과 제거를 관리하지만, SwiftUI 뷰 값은 프레임워크가 필요할 때마다 새로 생성합니다. body는 초당 수십 번 재계산될 수 있으므로 뷰 값은 복사 비용이 거의 없어야 하는데, UIView가 힙 할당과 참조 카운팅 비용을 갖는 것과 달리 구조체는 스택 값 복사라 매우 저렴합니다. 또 불변 선언이므로 프레임워크가 이전 선언 값과 새 선언 값을 비교해 달라진 부분만 실제 렌더 트리에 반영하기 쉽습니다. 뷰 값이 매번 새로 만들어지기 때문에 UIView처럼 인스턴스 프로퍼티에 상태를 저장할 수 없고, 유지돼야 할 상태는 @State 같은 래퍼로 뷰 밖의 프레임워크 저장소에 맡겨 참조합니다. 갱신 방식도 UIKit은 프로퍼티를 직접 바꾸는 명령형이고, SwiftUI는 상태가 바뀌면 body를 다시 계산하는 선언형입니다.',
 'interview-question/882.mp3'),
(883, 'SWIFTUI', 177, 'NORMAL', true,
 '여러 상태를 루트 뷰 한곳에서 모두 소유하는 방식과, 상태를 실제로 사용하는 하위 뷰로 내려서 소유하는 방식은 body 재평가 측면에서 어떤 차이가 있나요?',
 'SwiftUI는 body가 읽은 상태가 바뀌면 그 뷰를 무효화하고 body를 다시 계산합니다. 루트 뷰가 query, isOn 같은 모든 상태를 소유하고 읽으면, TextField에 타이핑할 때마다 루트 뷰 전체 body가 재평가되고 그 아래 자식 뷰 값도 다시 생성됩니다. 반대로 query는 SearchBar 안에서만, isOn은 SettingToggle 안에서만 소유하도록 상태를 실제로 쓰는 하위 뷰로 내리면, 상태 변화가 해당 하위 뷰만 무효화하므로 무효화 범위가 좁아집니다. 또한 body 안에서 정렬이나 포매팅 같은 무거운 연산을 하면 재평가마다 반복 실행되므로 body는 순수하고 빠르게 유지해야 합니다. 어떤 이유로 재평가됐는지는 body 안에서 let _ = Self._printChanges()로 확인할 수 있고, 필요하면 Equatable 채택과 .equatable()로 재평가를 막을 수 있지만 비교 비용이 더 클 수 있어 무거운 뷰에만 적용합니다.',
 'interview-question/883.mp3'),
(884, 'SWIFTUI', 177, 'EASY', true,
 'SwiftUI에서 뷰의 body는 언제 다시 평가되나요?',
 'SwiftUI는 body를 평가하는 동안 @State, @Binding, @Environment 같은 어떤 상태를 읽었는지 기록해 의존성을 추적합니다. 그 상태가 바뀌면 해당 뷰를 무효화하고 다음 렌더 사이클에 body를 다시 계산합니다. 의존성은 읽었는가로 결정되므로 읽지 않은 상태가 바뀌면 재평가되지 않습니다. 부모가 재평가되면 자식 뷰 값은 다시 생성되지만, 자식의 입력이 이전과 같다고 판단되면 자식의 body는 건너뜁니다. 그리고 body 재평가가 곧 화면을 다시 그리는 것은 아니며, 재평가 결과가 같으면 렌더 트리는 그대로입니다.',
 'interview-question/884.mp3'),
(885, 'SWIFTUI', 177, 'EASY', true,
 'SwiftUI에서 명시적 정체성이란 무엇이고, 개발자는 이를 어떤 방법으로 부여하나요?',
 '명시적 정체성은 뷰 트리의 위치로 정해지는 구조적 정체성과 달리, 개발자가 직접 부여하는 정체성입니다. 대표적으로 ForEach의 id가 있으며, Identifiable을 채택하면 item.id가 사용됩니다. id가 안정적이어야 항목 이동이나 삭제 시 상태와 애니메이션이 올바르게 따라가고, 인덱스를 id로 쓰면 삭제 시 뒤 항목이 앞 항목의 상태를 물려받는 문제가 생깁니다. 또 다른 방법은 .id() 모디파이어로, 그 값이 바뀌면 같은 위치라도 다른 뷰로 취급됩니다. 그래서 DetailView(post: post).id(post.id)처럼 써서 의도적으로 상태를 초기화하거나 전환 애니메이션을 유도할 수 있습니다.',
 'interview-question/885.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 881
(4747, 881, 'if/else의 두 분기는 뷰 트리상 위치가 달라 서로 다른 구조적 정체성임을 설명', 'ESSENTIAL', 1),
(4748, 881, '분기가 바뀌면 이전 뷰가 제거되고 새 뷰가 생성됨을 설명', 'ESSENTIAL', 2),
(4749, 881, '@State의 수명이 뷰 값이 아니라 뷰의 정체성에 묶여 있음을 설명', 'ESSENTIAL', 3),
(4750, 881, '분기 대신 삼항 연산자로 모디파이어 파라미터만 바꿔 같은 정체성을 유지하는 해결책을 제시', 'ESSENTIAL', 4),
(4751, 881, '같은 뷰의 속성만 바뀌면 withAnimation으로 높이가 자연스럽게 변함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 882
(4752, 882, 'UIView는 화면에 존재하는 객체이고 SwiftUI View는 화면을 기술한 값이라는 차이를 설명', 'ESSENTIAL', 1),
(4753, 882, 'body가 자주 재계산되므로 뷰 값은 복사 비용이 거의 없어야 함을 설명', 'ESSENTIAL', 2),
(4754, 882, 'SwiftUI 뷰 값은 프레임워크가 필요할 때마다 새로 생성함을 언급', 'ESSENTIAL', 3),
(4755, 882, '유지돼야 할 상태는 뷰 밖 프레임워크 저장소에 두고 래퍼로 참조함을 설명', 'ESSENTIAL', 4),
(4756, 882, 'UIView는 힙 할당·참조 카운팅 비용이 든다는 대비를 언급', 'SUPPLEMENTARY', 5),
(4757, 882, '이전 선언 값과 새 선언 값의 달라진 부분만 렌더 트리에 반영됨을 설명', 'SUPPLEMENTARY', 6),
(4758, 882, 'UIKit은 프로퍼티를 직접 바꾸는 명령형, SwiftUI는 body를 다시 계산하는 선언형임을 구분', 'SUPPLEMENTARY', 7),

-- 질문 883
(4759, 883, '루트 뷰가 모든 상태를 읽으면 작은 변화에도 루트 전체 body가 재평가됨을 설명', 'ESSENTIAL', 1),
(4760, 883, '상태를 실제로 쓰는 하위 뷰로 내리면 무효화 범위가 좁아짐을 설명', 'ESSENTIAL', 2),
(4761, 883, 'body 안의 무거운 연산은 재평가마다 반복 실행됨을 언급', 'SUPPLEMENTARY', 3),
(4762, 883, 'Self._printChanges()로 body가 재평가된 원인을 확인할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(4763, 883, 'Equatable 채택과 .equatable()로 body 재평가를 막을 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 884
(4764, 884, 'body 평가 중 어떤 상태를 읽었는지 기록해 의존성을 추적함을 설명', 'ESSENTIAL', 1),
(4765, 884, 'body 평가 중 읽은 상태가 바뀌면 body가 다시 계산됨을 설명', 'ESSENTIAL', 2),
(4766, 884, '읽지 않은 상태가 바뀌면 body가 재평가되지 않음을 언급', 'SUPPLEMENTARY', 3),
(4767, 884, '부모가 재평가되어도 입력이 같은 자식 뷰의 body는 건너뜀을 언급', 'SUPPLEMENTARY', 4),
(4768, 884, 'body 재평가가 화면 다시 그리기와 같지 않음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 885
(4769, 885, 'Explicit Identity는 구조적 위치가 아니라 개발자가 직접 부여하는 정체성임을 언급', 'ESSENTIAL', 1),
(4770, 885, 'ForEach의 id를 개발자가 정체성을 직접 부여하는 방법으로 제시', 'ESSENTIAL', 2),
(4771, 885, '.id() 값이 바뀌면 같은 위치라도 다른 뷰로 취급됨을 설명', 'ESSENTIAL', 3),
(4772, 885, '인덱스를 id로 쓰면 삭제 시 뒤 항목이 앞 항목의 상태를 물려받음을 언급', 'SUPPLEMENTARY', 4),
(4773, 885, '.id()로 의도적으로 상태를 초기화하거나 전환 애니메이션을 유도할 수 있음을 언급', 'SUPPLEMENTARY', 5);
