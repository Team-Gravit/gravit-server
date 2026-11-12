-- Unit: Compose 안정성과 최적화 (Unit ID: 170)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit04 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(846, 'COMPOSE', 170, 'HARD', true,
 'Strong Skipping 모드가 기본 활성화된 환경에서도 컴포저블 안에서 items.filter { }로 목록을 만들어 자식에게 넘기면 여전히 성능 문제가 생길 수 있습니다. 그 이유와 개선 방법을 설명해 주시겠어요?',
 'Strong Skipping 모드는 불안정한 인자를 가진 컴포저블도 참조 동일성(===)으로 비교해 건너뛸 수 있게 하는 컴파일러 모드로, Kotlin 2.0.20의 Compose 컴파일러부터 기본 활성화되었습니다. 하지만 이는 비교 기준이 equals에서 참조 동일성으로 완화된 것일 뿐이라서, 참조가 바뀌면 여전히 재실행됩니다. 컴포저블 안에서 items.filter { }나 map으로 새 목록을 만들면 매 재구성마다 새 참조가 생기므로, 자식 컴포저블은 내용이 같아도 건너뛰지 못하고 매번 다시 실행됩니다. 그래서 컬렉션 변환은 컴포저블이 아니라 ViewModel에서 수행해 UI 상태로 미리 가공해 내려보내는 것이 좋습니다. 즉 Strong Skipping이 있어도 새 인스턴스를 계속 만드는 구조라면 안정성 설계는 여전히 중요합니다. 다만 재구성 횟수가 많아도 프레임 예산 안에 끝나면 문제가 아니므로, Compose 컴파일러 리포트나 Layout Inspector로 먼저 측정하고 릴리스 빌드 기준으로 판단해야 합니다.',
 'interview-question/846.mp3'),
(847, 'COMPOSE', 170, 'NORMAL', true,
 'Compose의 @Immutable과 @Stable 어노테이션은 각각 무엇을 약속하며, 어떤 차이가 있나요?',
 '두 어노테이션은 외부 모듈 타입처럼 컴파일러가 안정성을 추론할 수 없을 때 개발자가 계약을 보증하는 수단입니다. @Immutable은 모든 공개 값이 생성 후 절대 바뀌지 않는다, 즉 불변임을 선언합니다. 반면 @Stable은 값은 바뀔 수 있지만 바뀌면 반드시 변경이 Snapshot 시스템, 즉 Compose에 통지된다는 약속이라서, MutableState를 내부에 쓰는 상태 홀더에 적합합니다. 즉 차이는 값 자체가 불변이냐, 바뀌더라도 그 변경이 통지되느냐에 있습니다. 주의할 점은 컴파일러가 이 약속을 검증하지 않는다는 것이고, 그래서 @Immutable·@Stable로 계약을 보증하되 약속을 어기면 화면이 갱신되지 않는 갱신 누락 버그가 생깁니다.',
 'interview-question/847.mp3'),
(848, 'COMPOSE', 170, 'NORMAL', true,
 'derivedStateOf는 어떤 상황에서 사용하고, 일반 remember(key)를 쓰는 편이 나은 경우와는 어떻게 다른가요?',
 'derivedStateOf는 자주 바뀌는 상태에서 드물게 바뀌는 값을 계산할 때 사용합니다. 계산 결과가 이전과 같으면 그 값을 읽은 컴포저블을 무효화하지 않기 때문에, 재구성 횟수가 결과 변경 횟수로 줄어듭니다. 예를 들어 스크롤 위치(firstVisibleItemIndex)는 매 프레임 바뀌지만 ''맨 위로'' 버튼의 표시 여부(Boolean)는 가끔만 바뀌므로, derivedStateOf로 감싸면 결과가 바뀔 때만 버튼이 재구성됩니다. 반대로 포매팅이나 단순 매핑처럼 입력 변경이 곧 결과 변경인 경우에는 파생 상태의 이점이 없고 오히려 오버헤드만 생기므로 일반 remember(key)로 충분합니다. 또 입력이 상태가 아닌 컴포저블 인자라면 Snapshot으로 자동 추적되지 않으므로, remember(arg)처럼 키로 넘겨 갱신해야 합니다.',
 'interview-question/848.mp3'),
(849, 'COMPOSE', 170, 'EASY', true,
 'Compose 컴파일러가 어떤 타입을 안정적(Stable)이라고 추론하는 조건은 무엇이며, List 타입 인자는 왜 불안정으로 취급되나요?',
 '컴파일러는 세 가지 조건을 만족하는 타입을 안정적으로 추론합니다. 첫째, 두 인스턴스의 equals 결과가 영원히 변하지 않아야 합니다. 둘째, 공개 프로퍼티가 바뀌면 MutableState처럼 컴포지션에 통지되어야 합니다. 셋째, 모든 공개 프로퍼티의 타입 역시 안정적이어야 합니다. 그래서 var를 가진 클래스는 통지 없이 값이 바뀔 수 있어 불안정합니다. List는 listOf()로 만든 읽기 전용 목록이어도 타입이 코틀린 표준 List 인터페이스이고, 구현체가 MutableList일 수 있어 불변을 보장하지 못하므로 불안정으로 취급됩니다. 불안정한 인자를 받은 컴포저블은 값이 같아도 건너뛰지 못하고 부모 재구성 때마다 재실행될 수 있습니다.',
 'interview-question/849.mp3'),
(850, 'COMPOSE', 170, 'EASY', true,
 'LazyColumn에서 items에 key를 지정하는 이유는 무엇인가요?',
 'LazyColumn은 기본적으로 인덱스를 항목의 식별자로 사용합니다. 그래서 맨 앞에 항목을 삽입하거나 순서를 바꾸면 모든 인덱스가 밀려 모든 항목이 새 항목으로 인식되고, 그 결과 항목 내부의 remember 상태가 손실되거나 전체가 재구성되며 animateItem 같은 애니메이션도 쓸 수 없습니다. key로 안정적인 고유 ID를 주면 이동한 항목의 컴포지션과 상태를 그대로 재사용할 수 있습니다. 이때 key는 목록 안에서 유일해야 하고 중복되면 런타임 예외가 발생하며, 스크롤 위치 복원에 쓰이므로 Bundle에 저장 가능한 타입이어야 합니다. 함께 쓰는 contentType은 헤더·광고·일반 행처럼 레이아웃이 다른 항목이 섞여 있을 때 같은 유형끼리만 컴포지션을 재사용하도록 재사용 풀을 분리해 줍니다.',
 'interview-question/850.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 846
(4557, 846, 'Strong Skipping은 불안정한 인자도 참조 동일성(===) 기준으로 건너뛰게 함을 언급', 'ESSENTIAL', 1),
(4558, 846, '참조가 바뀌면 Strong Skipping에서도 컴포저블이 여전히 재실행됨을 언급', 'ESSENTIAL', 2),
(4559, 846, '컴포저블 안에서 filter·map을 쓰면 매 재구성마다 새 목록 참조가 생긴다고 설명', 'ESSENTIAL', 3),
(4560, 846, '컬렉션 변환을 ViewModel에서 UI 상태로 미리 가공해 내려보내는 방법을 제시', 'ESSENTIAL', 4),
(4561, 846, 'Strong Skipping이 Kotlin 2.0.20의 Compose 컴파일러부터 기본 활성화됨을 언급', 'SUPPLEMENTARY', 5),
(4562, 846, 'Strong Skipping에서는 기준이 equals에서 참조 동일성으로 완화된 것일 뿐임을 명시', 'SUPPLEMENTARY', 6),
(4563, 846, 'Compose 컴파일러 리포트나 Layout Inspector로 먼저 측정해야 함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 847
(4564, 847, '@Immutable은 모든 공개 값이 생성 후 불변임을 약속한다고 설명', 'ESSENTIAL', 1),
(4565, 847, '@Stable은 값이 바뀔 수 있지만 변경이 Snapshot 시스템에 통지됨을 약속한다고 설명', 'ESSENTIAL', 2),
(4566, 847, '컴파일러가 @Immutable·@Stable의 약속을 검증하지 않음을 언급', 'SUPPLEMENTARY', 3),
(4567, 847, '@Immutable·@Stable 약속을 어기면 화면 갱신 누락 버그가 생김을 언급', 'SUPPLEMENTARY', 4),
(4568, 847, '@Stable이 MutableState를 내부에 쓰는 상태 홀더에 적합함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 848
(4569, 848, 'derivedStateOf는 입력은 자주 바뀌고 결과는 드물게 바뀔 때 적합하다고 설명', 'ESSENTIAL', 1),
(4570, 848, 'derivedStateOf는 계산 결과가 이전과 같으면 읽은 컴포저블을 무효화하지 않음을 언급', 'ESSENTIAL', 2),
(4571, 848, '입력 변경이 곧 결과 변경인 포매팅·단순 매핑에는 remember(key)로 충분하다고 설명', 'ESSENTIAL', 3),
(4572, 848, '결과가 입력만큼 자주 바뀌면 derivedStateOf는 오버헤드만 생긴다고 언급', 'SUPPLEMENTARY', 4),
(4573, 848, '스크롤 위치로 맨 위로 이동 버튼의 표시 여부를 계산하는 예를 제시', 'SUPPLEMENTARY', 5),
(4574, 848, '컴포저블 인자는 Snapshot 상태가 아니라서 remember(arg)로 키를 넘겨야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 849
(4575, 849, 'equals 결과 불변·변경 시 컴포지션 통지·공개 프로퍼티 타입 안정 중 최소 2개를 조건으로 제시', 'ESSENTIAL', 1),
(4576, 849, 'List는 구현체가 MutableList일 수 있어 불변을 보장 못해 불안정하다고 설명', 'ESSENTIAL', 2),
(4577, 849, 'listOf()로 만든 읽기 전용 목록도 타입이 List 인터페이스라 불안정으로 취급됨을 언급', 'SUPPLEMENTARY', 3),
(4578, 849, 'var를 가진 클래스는 통지 없이 값이 바뀔 수 있어 불안정하다고 언급', 'SUPPLEMENTARY', 4),
(4579, 849, '불안정한 인자를 받은 컴포저블은 값이 같아도 건너뛰지 못하고 재실행됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 850
(4580, 850, '기본 인덱스 식별에서는 맨 앞 삽입 시 모든 항목이 새 항목으로 인식됨을 설명', 'ESSENTIAL', 1),
(4581, 850, '상태(remember) 손실·전체 재구성·애니메이션 불가 중 최소 1개를 문제로 제시', 'ESSENTIAL', 2),
(4582, 850, 'key로 고유 ID를 주면 이동한 항목의 컴포지션과 상태를 재사용한다고 설명', 'ESSENTIAL', 3),
(4583, 850, 'key는 목록 안에서 유일해야 하며 중복되면 런타임 예외가 발생함을 언급', 'SUPPLEMENTARY', 4),
(4584, 850, 'key는 스크롤 위치 복원을 위해 Bundle에 저장 가능한 타입이어야 함을 언급', 'SUPPLEMENTARY', 5),
(4585, 850, 'contentType은 같은 유형끼리만 컴포지션을 재사용하도록 재사용 풀을 분리한다고 언급', 'SUPPLEMENTARY', 6);
