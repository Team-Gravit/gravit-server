-- Unit: 앱 아키텍처 (Unit ID: 100)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(496, 'AOS_COMMON', 100, 'HARD', true,
 '프래그먼트가 Retrofit으로 사용자 정보를 직접 받아와 로딩 스피너와 텍스트 뷰를 하나씩 갱신하는 코드가 있습니다. 이 구조의 문제는 무엇이고, 권장 아키텍처에 맞게 어떻게 개선하시겠습니까?',
 '이 코드는 UI가 Retrofit을 직접 호출해 HTTP를 알고 있고, 화면 상태가 여러 뷰에 흩어져 있다는 문제가 있습니다. 결과에 따라 뷰를 조각조각 갱신하기 때문에 요청이 실패하면 로딩 스피너가 그대로 남는 식의 상태 불일치가 생깁니다. 또 화면에서 Retrofit을 직접 호출하면 캐시·오류 변환이 화면마다 중복되고 테스트 시 실제 통신이 필요합니다. 개선하려면 Retrofit 호출을 Repository 뒤로 숨겨 UI가 HTTP를 모르게 하고, ViewModel은 Repository 인터페이스를 주입받아 호출하게 합니다. ViewModel은 로딩 여부·사용자·오류 메시지를 담은 UiState 하나로 상태를 만들고, 프래그먼트는 이를 관찰해 그리기만 합니다. UI는 이벤트만 ViewModel에 전달하므로 상태를 바꾸는 곳이 한 곳이 됩니다. 상태가 한 객체면 불가능한 조합을 타입으로 막을 수 있고, 레이어 간 의존을 인터페이스로 두고 의존성 주입으로 조립하면 테스트에서 가짜(Fake) 구현으로 교체하기도 쉽습니다.',
 'interview-question/496.mp3'),
(497, 'AOS_COMMON', 100, 'NORMAL', true,
 '안드로이드 권장 아키텍처에서 Domain 레이어(UseCase)는 어떤 경우에 도입하고, 어떤 경우에 생략하는 것이 적절한가요?',
 'Domain 레이어는 선택 사항입니다. 사용자·주문·배송처럼 여러 Repository를 조합해야 하거나, 여러 ViewModel이 같은 로직을 재사용해야 할 때 그 비즈니스 규칙을 UseCase로 뽑습니다. 반대로 Repository 메서드를 한 줄 호출만 하는 UseCase는 오버엔지니어링이므로, 이런 경우라면 생략하는 편이 낫습니다. 작은 앱은 Domain 레이어를 생략해도 권장 아키텍처에 부합합니다. UseCase를 둔다면 하나의 동작만 하는 operator fun invoke() 형태로 두고, 안드로이드 의존성을 갖지 않게 유지합니다.',
 'interview-question/497.mp3'),
(498, 'AOS_COMMON', 100, 'NORMAL', true,
 '토스트 표시나 화면 이동 같은 일회성 이벤트를 StateFlow에 그대로 넣는 방식과, 공식 권장처럼 상태로 모델링하는 방식은 어떤 차이가 있나요?',
 'StateFlow는 최신 상태 하나를 유지합니다. 그래서 토스트 한 번 띄우기나 화면 이동 같은 일회성 이벤트를 StateFlow에 그대로 넣으면, 회전 후 화면이 다시 그려질 때 같은 값을 다시 받아 토스트가 재발생합니다. 즉 재구독·재생성 시 이벤트가 중복 발생합니다. 공식 권장 방식은 일회성 이벤트도 상태로 모델링하는 것입니다. 예를 들어 errorMessage를 UiState에 두고, 화면이 이를 보여준 뒤 onErrorShown() 같은 소비 이벤트를 보내 상태에서 지웁니다. 꼭 필요하면 Channel이나 SharedFlow로 분리할 수 있지만, 이때는 유실·중복 가능성을 이해하고 써야 합니다.',
 'interview-question/498.mp3'),
(499, 'AOS_COMMON', 100, 'EASY', true,
 '안드로이드 앱 아키텍처에서 말하는 단방향 데이터 흐름(UDF)이란 무엇인가요?',
 '단방향 데이터 흐름은 상태가 위, 즉 상태 홀더에서 아래인 UI로만 흐르고, 이벤트는 UI에서 상태 홀더로, 아래에서 위로만 흐르는 규칙입니다. UI는 상태를 직접 바꾸지 않고 ''이런 일이 있었다''는 이벤트를 보낼 뿐이며, 상태를 바꾸는 유일한 곳은 ViewModel 같은 상태 홀더입니다. ViewModel은 이벤트를 받아 Repository를 호출하고 새 UiState를 만들며, UI는 그 상태를 그립니다. 이렇게 하면 여러 곳에서 뷰를 직접 바꿔 생기는 상태 불일치를 막고, 상태 변화의 원인을 어떤 이벤트가 어떤 상태를 만들었는지로 추적할 수 있으며, UI가 재생성돼도 최신 UiState를 다시 그리기만 하면 됩니다.',
 'interview-question/499.mp3'),
(500, 'AOS_COMMON', 100, 'EASY', true,
 'Data 레이어에서 Repository가 맡는 핵심 역할은 무엇인가요?',
 'Repository는 여러 데이터 소스를 감추고, 어디서 왔든 이 데이터의 정답은 하나라는 단일 진실 공급원(SSOT)을 제공합니다. 보통 로컬 DB(Room)를 SSOT로 두고 네트워크는 DB를 갱신하는 수단으로 취급합니다. 또 네트워크 응답인 DTO와 DB 행인 Entity는 Data 레이어 안에서만 쓰고, 밖으로는 도메인 모델로 변환해 내보내므로 서버 필드명이 바뀌어도 UI 코드는 그대로입니다. 그리고 Repository는 Dispatchers.IO 전환과 예외를 도메인 오류로 변환하는 일까지 책임집니다. 그래서 호출자는 메인 스레드에서 Repository를 안전하게(main-safe) 부를 수 있습니다. 반면 로딩 여부 같은 UI 상태는 반환하지 않고 데이터와 오류만 넘기며, 로딩 표시는 ViewModel이 결정합니다.',
 'interview-question/500.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 496
(2661, 496, '실패 시 로딩 스피너가 남는 등 뷰를 조각조각 갱신하면 상태 불일치가 생긴다고 설명', 'ESSENTIAL', 1),
(2662, 496, 'Retrofit 호출을 Repository 뒤로 숨겨 UI가 HTTP를 모르게 한다고 제시', 'ESSENTIAL', 2),
(2663, 496, 'ViewModel이 UiState 하나로 상태를 만들고 UI는 이를 그리기만 한다고 설명', 'ESSENTIAL', 3),
(2664, 496, '상태가 한 객체면 불가능한 조합을 타입으로 막을 수 있다고 언급', 'SUPPLEMENTARY', 4),
(2665, 496, 'Repository 인터페이스를 주입받으면 테스트에서 가짜(Fake) 구현으로 교체하기 쉽다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 497
(2666, 497, '여러 Repository를 조합해야 할 때 UseCase로 뽑는다고 제시', 'ESSENTIAL', 1),
(2667, 497, '여러 ViewModel이 같은 로직을 재사용할 때 UseCase로 뽑는다고 제시', 'ESSENTIAL', 2),
(2668, 497, 'Repository 메서드를 한 줄 호출만 하는 UseCase는 오버엔지니어링이라고 설명', 'ESSENTIAL', 3),
(2669, 497, '작은 앱은 Domain 레이어를 생략해도 권장 아키텍처에 부합한다고 언급', 'SUPPLEMENTARY', 4),
(2670, 497, 'UseCase를 하나의 동작만 하는 operator fun invoke() 형태로 둔다고 언급', 'SUPPLEMENTARY', 5),
(2671, 497, 'UseCase는 안드로이드 의존성을 갖지 않게 유지한다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 498
(2672, 498, 'StateFlow는 최신 상태 하나를 유지함을 언급', 'ESSENTIAL', 1),
(2673, 498, 'StateFlow에 넣은 일회성 이벤트는 회전 후 다시 그려질 때 재발생한다고 설명', 'ESSENTIAL', 2),
(2674, 498, '일회성 이벤트를 상태로 두고 보여준 뒤 onErrorShown() 같은 소비 이벤트로 지운다고 설명', 'ESSENTIAL', 3),
(2675, 498, 'Channel·SharedFlow로 분리하면 유실·중복 가능성이 있음을 언급', 'SUPPLEMENTARY', 4),

-- 질문 499
(2676, 499, '상태는 상태 홀더에서 UI로, 위에서 아래로만 흐른다고 설명', 'ESSENTIAL', 1),
(2677, 499, '이벤트는 UI에서 상태 홀더로, 아래에서 위로만 흐른다고 설명', 'ESSENTIAL', 2),
(2678, 499, '상태를 바꾸는 유일한 곳이 상태 홀더(ViewModel)임을 언급', 'ESSENTIAL', 3),
(2679, 499, '상태 불일치·디버깅·구성 변경 대응 중 최소 1개를 UDF가 해결하는 문제로 제시', 'SUPPLEMENTARY', 4),

-- 질문 500
(2680, 500, 'Repository가 데이터의 단일 진실 공급원(SSOT)을 제공한다고 언급', 'ESSENTIAL', 1),
(2681, 500, 'DTO·Entity는 Data 레이어 안에서만 쓰고 도메인 모델로 변환해 내보낸다고 설명', 'ESSENTIAL', 2),
(2682, 500, '호출자가 메인 스레드에서 Repository를 안전하게 부를 수 있게(main-safe) 보장한다고 설명', 'ESSENTIAL', 3),
(2683, 500, '보통 로컬 DB(Room)를 SSOT로 두고 네트워크는 DB를 갱신하는 수단으로 취급한다고 언급', 'SUPPLEMENTARY', 4),
(2684, 500, 'Dispatchers.IO 전환·예외의 도메인 오류 변환 중 최소 1개를 Repository 책임으로 제시', 'SUPPLEMENTARY', 5),
(2685, 500, 'Repository는 로딩 여부 같은 UI 상태를 반환하지 않는다고 언급', 'SUPPLEMENTARY', 6);
