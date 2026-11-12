-- Unit: Combine과 데이터 바인딩 (Unit ID: 185)
-- Chapter: iOS (Chapter ID: 17)
-- Topic: SWIFTUI
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-ios-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(921, 'SWIFTUI', 185, 'HARD', true,
 '검색창에 입력할 때마다 서버 검색을 호출하는 기능을 Combine으로 구현한다면 어떤 연산자를 조합하고, 에러 처리와 실행 스레드는 어떻게 다루어야 하는지 설명해 주시겠어요?',
 '검색어를 @Published 프로퍼티로 두고 그 프로젝션인 $query를 Publisher로 사용해 파이프라인을 구성합니다. 먼저 debounce로 입력이 멈춘 뒤 300ms 정도가 지나야 값이 흘러가게 해서 타이핑 중 매 글자마다 요청이 나가지 않게 하고, removeDuplicates로 같은 검색어가 연속으로 들어오는 경우를 제거합니다. 그다음 map으로 검색 API Publisher를 만들고 switchToLatest를 붙이면, 새 검색어가 들어올 때 이전 요청은 버리고 최신 요청만 유지됩니다. 에러 처리가 중요한데, Combine은 에러가 나면 파이프라인 전체가 종료되어 이후 값이 더 전달되지 않습니다. 그래서 map 안쪽의 검색 요청 Publisher에서 replaceError나 catch로 에러를 빈 결과 같은 값으로 바꿔, 한 번의 실패로 바깥의 검색창 스트림 전체가 죽지 않게 합니다. 이처럼 에러를 값으로 변환하거나 flatMap 안쪽에서 처리해 바깥 스트림을 살리는 것이 핵심입니다. 마지막으로 네트워크 Publisher는 백그라운드에서 발행할 수 있으므로 결과로 UI를 갱신하기 전에 receive(on: DispatchQueue.main)으로 메인 스레드에 복귀한 뒤 assign(to: &$results)로 결과에 연결합니다. 이렇게 ''시간 조건 + 중복 제거 + 이전 요청 취소''를 연산자 조합만으로 선언할 수 있는 것이 Combine의 장점이고, 같은 로직을 async/await로 쓰면 Task의 취소와 보관을 직접 관리해야 합니다.',
 'interview-question/921.mp3'),
(922, 'SWIFTUI', 185, 'NORMAL', true,
 'Combine에서 subscribe(on:)과 receive(on:)은 각각 파이프라인의 어느 구간에 영향을 주며, 어떻게 다른지 설명해 주세요.',
 '둘 다 Scheduler, 즉 코드가 언제·어느 스레드에서 실행되는지를 지정하는 연산자지만 영향 범위가 다릅니다. subscribe(on:)은 업스트림(발행 측), 즉 구독과 수요 요청, 발행 시작 작업이 실행될 스케줄러를 지정합니다. 파이프라인 중간 어디에 써도 위치와 무관하게 파이프라인의 시작점에 영향을 줍니다. 반면 receive(on:)은 다운스트림에 적용되어, 호출한 지점 이후의 연산자와 Subscriber가 실행될 스케줄러를 지정합니다. 여러 번 쓰면 마지막 receive(on:)이 이후 구간을 결정합니다. 그래서 이미지 로딩처럼 무거운 발행 작업은 subscribe(on: DispatchQueue.global())로 백그라운드에서 돌리고, UI를 갱신하기 직전에 receive(on: DispatchQueue.main)으로 메인에 복귀하는 식으로 씁니다. 참고로 RunLoop.main 스케줄러는 스크롤 같은 UI 트래킹 모드 중에는 이벤트를 전달하지 않아 갱신이 지연되므로, UI 바인딩에는 일반적으로 DispatchQueue.main을 사용합니다.',
 'interview-question/922.mp3'),
(923, 'SWIFTUI', 185, 'NORMAL', true,
 '비동기 작업을 처리할 때 Combine과 async/await 중 어떤 것을 선택할지 결정하는 기준은 무엇인가요?',
 '두 방식은 겹치는 부분이 많지만 모델이 다릅니다. Combine은 여러 값이 시간에 따라 흐르는 스트림을 다루는 모델이고, async/await는 하나의 값을 기다리는 함수 호출 모델입니다. 그래서 선택 기준은 값이 여러 번 오고 시간 조건이나 결합이 필요하면 Combine, 요청-응답이 한 번인 단발성 작업이면 async/await입니다. Combine은 combineLatest, debounce, throttle 같은 결합·시간 연산자가 풍부해 검색창 디바운스나 여러 입력의 결합에 강하고, async/await에서는 이런 것을 직접 구현하거나 AsyncAlgorithms 패키지로 보완해야 합니다. 반대로 단발성 요청에 Combine을 쓰면 AnyCancellable 보관, 취소, 에러 매핑이 장황해지는 반면, async/await는 순차 코드처럼 읽히고 throws와 do/catch로 에러를 자연스럽게 처리하며 스택 트레이스도 명확합니다. 실무에서는 네트워크·저장소 계층은 async/await로 쓰고 UI 입력 스트림에만 Combine을 남기는 절충이 흔하며, publisher.values로 Publisher를 AsyncSequence로 소비하는 식으로 두 세계를 연결할 수도 있습니다.',
 'interview-question/923.mp3'),
(924, 'SWIFTUI', 185, 'EASY', true,
 'Combine을 구성하는 Publisher, Operator, Subscriber는 각각 어떤 역할을 하나요?',
 'Combine은 시간에 따라 발생하는 값의 흐름을 Publisher, Operator, Subscriber로 이어지는 파이프라인으로 처리합니다. Publisher는 값(Output)과 완료 또는 에러(Failure)를 발행하는 쪽으로, Just, PassthroughSubject, @Published 등이 있습니다. Operator는 map, filter, debounce처럼 값을 변환·필터·결합해 새 Publisher를 반환하므로 여러 개를 이어 붙일 수 있습니다. Subscriber는 값을 소비하고 얼마나 받을지 수요(Demand)를 요청하는 쪽으로, sink나 assign이 대표적입니다. Publisher는 구독 전까지 아무것도 하지 않는 지연 실행 방식이라, sink나 assign이 붙는 순간 구독이 시작됩니다.',
 'interview-question/924.mp3'),
(925, 'SWIFTUI', 185, 'EASY', true,
 'Combine에서 sink로 구독했을 때 반환되는 AnyCancellable은 어떤 역할을 하며, 이를 보관하지 않으면 어떻게 되나요?',
 'AnyCancellable은 구독을 나타내는 객체로, 구독의 생명주기를 관리합니다. 이를 보관하지 않으면 즉시 해제되어 구독이 취소되고 파이프라인이 사라지기 때문에, 보통 store(in: &cancellables)로 Set<AnyCancellable>에 담아 보관합니다. AnyCancellable은 deinit 시 자동으로 cancel()을 호출하므로, 뷰모델이 해제되면 cancellables도 함께 해제되어 구독이 정리됩니다. 다만 sink 클로저에서 self를 강하게 캡처하고 그 cancellables를 self가 보관하면 순환 참조가 생겨 해제가 일어나지 않으므로, 항상 [weak self]로 캡처해야 합니다.',
 'interview-question/925.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 921
(4958, 921, 'debounce로 입력이 멈춘 뒤 일정 시간이 지나야 검색을 요청하게 함을 설명', 'ESSENTIAL', 1),
(4959, 921, 'switchToLatest로 이전 요청을 버리고 최신 요청만 유지함을 설명', 'ESSENTIAL', 2),
(4960, 921, 'catch·replaceError로 값 변환·flatMap 안쪽 처리 중 최소 1개로 에러 시 바깥 스트림을 살리는 방법을 제시', 'ESSENTIAL', 3),
(4961, 921, '결과로 UI를 갱신하기 전에 receive(on:)으로 메인 스레드에 복귀해야 함을 언급', 'ESSENTIAL', 4),
(4962, 921, '에러가 나면 파이프라인 전체가 종료된다고 언급', 'SUPPLEMENTARY', 5),
(4963, 921, 'removeDuplicates로 같은 검색어의 중복 요청을 제거함을 언급', 'SUPPLEMENTARY', 6),
(4964, 921, '같은 로직을 async/await로 쓰면 Task 취소·보관을 직접 관리해야 함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 922
(4965, 922, 'subscribe(on:)이 업스트림(발행 측) 작업이 실행될 스케줄러를 지정함을 설명', 'ESSENTIAL', 1),
(4966, 922, 'receive(on:)은 호출 지점 이후 다운스트림 연산자와 Subscriber가 실행될 스케줄러를 지정함을 설명', 'ESSENTIAL', 2),
(4967, 922, 'subscribe(on:)은 호출 위치와 무관하게 파이프라인의 시작점에 영향을 줌을 언급', 'SUPPLEMENTARY', 3),
(4968, 922, '무거운 발행 작업은 subscribe(on:)으로 백그라운드에 두고 UI 갱신 전 receive(on:)으로 메인에 복귀하는 용례를 제시', 'SUPPLEMENTARY', 4),
(4969, 922, 'UI 바인딩에는 RunLoop.main 대신 DispatchQueue.main을 쓴다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 923
(4970, 923, 'Combine은 여러 값이 시간에 따라 흐르는 스트림 모델이고 async/await는 하나의 값을 기다리는 모델이라고 비교', 'ESSENTIAL', 1),
(4971, 923, '값이 여러 번 오고 시간 조건·결합이 필요하면 Combine을 택한다는 기준을 제시', 'ESSENTIAL', 2),
(4972, 923, '요청-응답이 한 번인 단발성 작업에는 async/await를 택한다는 기준을 제시', 'ESSENTIAL', 3),
(4973, 923, 'Combine은 combineLatest·debounce 같은 결합·시간 연산자가 풍부하지만 async/await는 직접 구현해야 함을 언급', 'SUPPLEMENTARY', 4),
(4974, 923, 'async/await는 순차 코드처럼 읽혀 스택 트레이스가 명확하다는 가독성 장점을 언급', 'SUPPLEMENTARY', 5),
(4975, 923, 'publisher.values로 Publisher를 AsyncSequence로 소비해 두 방식을 연결할 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 924
(4976, 924, 'Publisher가 값(Output)과 완료·에러(Failure)를 발행하는 역할임을 설명', 'ESSENTIAL', 1),
(4977, 924, 'Operator가 값을 변환·필터·결합해 새 Publisher를 반환하는 역할임을 설명', 'ESSENTIAL', 2),
(4978, 924, 'Subscriber가 값을 소비하고 수요(Demand)를 요청하는 역할임을 설명', 'ESSENTIAL', 3),
(4979, 924, 'Publisher는 구독 전까지 아무것도 하지 않는 지연 실행 방식임을 언급', 'SUPPLEMENTARY', 4),
(4980, 924, 'sink·assign 중 최소 1개를 대표 Subscriber로 제시', 'SUPPLEMENTARY', 5),

-- 질문 925
(4981, 925, 'AnyCancellable을 보관하지 않으면 즉시 해제되어 구독이 취소됨을 설명', 'ESSENTIAL', 1),
(4982, 925, 'AnyCancellable이 deinit 시 자동으로 cancel()을 호출한다고 언급', 'ESSENTIAL', 2),
(4983, 925, 'store(in:)으로 Set<AnyCancellable>에 보관하는 방식을 제시', 'SUPPLEMENTARY', 3),
(4984, 925, '뷰모델이 해제되면 cancellables도 해제되어 구독이 정리됨을 언급', 'SUPPLEMENTARY', 4),
(4985, 925, 'sink 클로저에서 self를 강하게 캡처하면 순환 참조가 생기므로 [weak self]를 써야 함을 언급', 'SUPPLEMENTARY', 5);
