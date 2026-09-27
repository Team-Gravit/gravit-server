-- Unit: actor와 데이터 격리 (Unit ID: 226)
-- Chapter: Swift (Chapter ID: 22)
-- Topic: SWIFT
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-swift-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1126, 'SWIFT', 226, 'HARD', true,
 'actor로 이미지 캐시를 만들고, 메서드 안에서 캐시를 확인한 뒤 await로 다운로드하고 결과를 캐시에 저장하도록 구현했습니다. 이 코드에서 어떤 문제가 생길 수 있고, 어떻게 해결하시겠습니까?',
 '액터는 중단 지점인 await에서 재진입을 허용합니다. 그래서 메서드가 await로 다운로드를 기다리는 동안 다른 요청이 끼어들어 처리될 수 있고, 이 코드에서는 데이터 경합은 없지만 같은 URL에 대한 두 번째 호출도 캐시를 확인했을 때 아직 값이 없으므로 같은 URL을 중복 다운로드할 수 있습니다. 해결책은 진행 중인 Task를 캐시에 함께 저장해 두고, 두 번째 호출자가 새로 다운로드하지 않고 그 Task의 결과를 기다리게 하는 것입니다. 일반적인 원칙으로는 await 이후에는 상태를 다시 확인하고, 불변식이 깨지지 않도록 상태 변경을 await 사이에 걸치지 않게 설계해야 합니다. 참고로 재진입은 데드락을 막기 위한 의도된 설계입니다. 액터가 await 중에도 다른 요청을 처리할 수 있어야 서로 기다리는 상황이 줄어들기 때문입니다. 따라서 액터는 자동 락이 아니라 동기 구간만 원자적이라고 봐야 합니다.'),
(1127, 'SWIFT', 226, 'NORMAL', true,
 '공유 가변 상태를 보호할 때 락을 사용하는 class와 actor는 어떤 차이가 있나요?',
 '락을 쓰는 class는 NSLock 같은 락으로 개발자가 규약을 지키는 방식이라, 락을 빠뜨린 경로가 한 곳이라도 있으면 경합이 생기는데 컴파일러는 이를 알지 못합니다. 반면 actor는 내부에 직렬 실행기와 메일박스를 가지고 있어서, 외부에서 격리된 멤버에 접근하면 요청이 큐에 들어가고 액터가 한 번에 하나씩 처리합니다. 즉 모든 접근이 자동으로 직렬화되어 상태를 동시에 만지는 일이 구조적으로 불가능합니다. 또 외부에서 actor의 격리된 멤버에 접근할 때는 반드시 await가 강제되고, 액터 내부에서 자기 상태에 접근할 때는 await가 필요 없습니다. 그 밖에 actor는 class처럼 참조 타입이지만 상속이 없고, 상태 접근이 직렬화되므로 항상 Sendable입니다.'),
(1128, 'SWIFT', 226, 'NORMAL', true,
 'Swift 5 언어 모드와 Swift 6 언어 모드는 동시성 안전성 검사에서 어떤 차이가 있나요?',
 '격리 위반이나 비Sendable 값 전달은 Swift 5 언어 모드에서는 기본적으로 무시되고 -strict-concurrency=complete를 켜야 경고로 나타나지만, Swift 6 언어 모드에서는 컴파일 오류가 됩니다. 즉 Swift 6 모드에서는 데이터 경합 가능성이 컴파일 오류로 검출됩니다. 또 Swift 5 모드에서 허용되던 전역 가변 변수 var는 Swift 6 모드에서 오류가 되므로 액터로 격리하거나 let으로 바꾸거나 nonisolated(unsafe)로 표시해야 합니다. 참고로 Swift 6 컴파일러와 Swift 6 언어 모드는 다르며, Xcode 16 이상의 Swift 6 컴파일러로도 Swift 5 언어 모드를 유지할 수 있습니다. 마이그레이션은 보통 complete 경고를 모두 정리한 뒤 모듈별로 Swift 6 모드를 켜는 순서로 진행합니다.'),
(1129, 'SWIFT', 226, 'EASY', true,
 'Swift Concurrency에서 Sendable이란 무엇이고, 어떤 타입이 Sendable을 준수하나요?',
 'Sendable은 어떤 값을 다른 격리 영역, 즉 다른 스레드나 액터로 복사해 보내도 안전하다는 것을 표시하는 마커 프로토콜입니다. 요구 메서드는 없고 컴파일러가 타입의 구조를 검사합니다. struct나 enum 같은 값 타입은 모든 저장 프로퍼티가 Sendable이면 암묵적으로 준수하는데, 복사되어 전달되므로 격리 영역이 달라도 서로 간섭하지 않기 때문입니다. actor는 항상 Sendable이고, 모든 프로퍼티가 let인 final class는 불변이므로 Sendable을 채택할 수 있습니다. 반면 가변 프로퍼티가 있는 class는 참조가 공유되므로 Sendable이 될 수 없습니다. 락으로 직접 보호했다면 @unchecked Sendable로 책임을 선언할 수 있지만, 이는 컴파일러 검사를 끄겠다는 선언이므로 최소화해야 합니다.'),
(1130, 'SWIFT', 226, 'EASY', true,
 '@MainActor는 무엇이며, 어떤 역할을 하나요?',
 '@MainActor는 메인 스레드에서 실행되는 전역 액터입니다. UIKit이나 SwiftUI의 뷰와 상태는 메인 스레드에서만 만져야 하는데, @MainActor는 이를 타입 시스템으로 보장해 UI 상태 접근을 컴파일 타임에 메인 스레드로 강제합니다. 격리되지 않은 곳에서 @MainActor 프로퍼티에 접근하면 실행 전에 컴파일 오류로 잡힙니다. 타입·메서드·프로퍼티·클로저 어디에나 붙일 수 있고, 타입에 붙이면 모든 멤버가 메인 액터에 격리됩니다. 예를 들어 @MainActor 뷰모델의 메서드에서 네트워크 호출을 await로 기다린 뒤에는 자동으로 메인 액터로 돌아오므로 곧바로 UI 상태에 대입할 수 있습니다. 기존에 DispatchQueue.main.async로 감싸던 UI 갱신 코드는 @MainActor 격리로 대체되며, 차이는 컴파일러가 강제한다는 점입니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1126
(6036, 1126, '액터가 await 중단 지점에서 다른 요청의 재진입을 허용함을 언급', 'ESSENTIAL', 1),
(6037, 1126, 'await로 기다리는 동안 다른 호출이 같은 URL을 중복 다운로드할 수 있음을 설명', 'ESSENTIAL', 2),
(6038, 1126, '진행 중인 Task를 캐시에 저장해 두 번째 호출자가 그 Task의 결과를 기다리게 하는 해결책을 제시', 'ESSENTIAL', 3),
(6039, 1126, 'await 이후에는 상태를 다시 확인해야 한다는 원칙을 언급', 'SUPPLEMENTARY', 4),
(6040, 1126, '재진입이 데드락을 막기 위한 의도된 설계임을 언급', 'SUPPLEMENTARY', 5),
(6041, 1126, '액터는 자동 락이 아니라 동기 구간만 원자적이라는 점을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1127
(6042, 1127, 'class와 락 방식은 락을 빠뜨린 경로가 있어도 컴파일러가 알지 못한다는 점을 언급', 'ESSENTIAL', 1),
(6043, 1127, 'actor는 격리된 상태에 대한 접근을 직렬화해 한 번에 하나씩 처리함을 설명', 'ESSENTIAL', 2),
(6044, 1127, '외부에서 actor의 격리된 멤버에 접근할 때는 await가 강제됨을 언급', 'ESSENTIAL', 3),
(6045, 1127, 'actor는 class처럼 참조 타입이지만 상속이 불가능함을 언급', 'SUPPLEMENTARY', 4),
(6046, 1127, 'actor 타입은 항상 Sendable이라는 점을 언급', 'SUPPLEMENTARY', 5),
(6047, 1127, '액터 내부에서 자기 상태에 접근할 때는 await가 필요 없음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1128
(6048, 1128, '격리 위반·비Sendable 전달이 Swift 6 언어 모드에서는 컴파일 오류가 됨을 설명', 'ESSENTIAL', 1),
(6049, 1128, 'Swift 5 모드에서 허용되던 전역 가변 변수(var)가 Swift 6 모드에서는 오류가 됨을 언급', 'ESSENTIAL', 2),
(6050, 1128, 'Swift 6 컴파일러와 Swift 6 언어 모드가 서로 다른 개념이라는 점을 언급', 'SUPPLEMENTARY', 3),
(6051, 1128, 'complete 경고를 모두 정리한 뒤 모듈별로 Swift 6 모드를 켜는 마이그레이션 순서를 제시', 'SUPPLEMENTARY', 4),
(6052, 1128, '전역 가변 변수 오류의 대응으로 액터 격리·let 변경·nonisolated(unsafe) 중 최소 1개를 제시', 'SUPPLEMENTARY', 5),

-- 질문 1129
(6053, 1129, 'Sendable이 다른 격리 영역으로 보내도 안전한 타입임을 나타내는 표시 프로토콜임을 설명', 'ESSENTIAL', 1),
(6054, 1129, '모든 저장 프로퍼티가 Sendable인 값 타입(struct·enum)은 암묵적으로 준수함을 언급', 'ESSENTIAL', 2),
(6055, 1129, '가변 프로퍼티가 있는 class는 Sendable을 준수할 수 없음을 언급', 'ESSENTIAL', 3),
(6056, 1129, '모든 프로퍼티가 let인 final class는 Sendable을 채택할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(6057, 1129, '@unchecked Sendable이 컴파일러 검사를 끄는 선언이라는 점을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1130
(6058, 1130, '@MainActor가 메인 스레드에서 실행되는 전역 액터라는 점을 언급', 'ESSENTIAL', 1),
(6059, 1130, 'UI 상태 접근을 컴파일 타임에 메인 스레드로 강제하는 역할을 설명', 'ESSENTIAL', 2),
(6060, 1130, '타입에 @MainActor를 붙이면 모든 멤버가 메인 액터에 격리됨을 언급', 'SUPPLEMENTARY', 3),
(6061, 1130, 'DispatchQueue.main.async로 감싸던 UI 갱신 코드를 @MainActor 격리로 대체한다는 점을 언급', 'SUPPLEMENTARY', 4),
(6062, 1130, '@MainActor 메서드에서 await 복귀 후 자동으로 메인 액터로 돌아옴을 언급', 'SUPPLEMENTARY', 5);
