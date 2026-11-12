-- Unit: Compose 상태 관리 (Unit ID: 169)
-- Chapter: Android (Chapter ID: 16)
-- Topic: COMPOSE
-- Source: gravit-interview-contents-generator/output/2026-09-24/mobile-android-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(841, 'COMPOSE', 169, 'HARD', true,
 '검색 입력창과 결과 목록처럼 형제 컴포저블이 같은 상태를 함께 읽어야 할 때, 그 상태를 어디까지 끌어올리고 어떻게 흐르게 설계하시겠습니까? 무조건 ViewModel까지 올리거나 같은 상태를 여러 곳에 두면 어떤 문제가 생기는지도 함께 설명해 주세요.',
 '상태는 그 상태를 읽는 모든 컴포저블의 가장 가까운 공통 부모까지만 끌어올립니다. 검색 입력창과 결과 목록이 같은 검색어를 봐야 한다면 최소한 두 형제의 부모까지는 올려야 하고, 상태를 변경하는 곳이 소유자보다 위에 있다면 그 위치까지 올립니다. 입력창 같은 자식 컴포저블은 상태를 직접 갖지 않고 값(value)과 변경 요청 콜백(onValueChange)만 받는 Stateless 컴포저블로 만듭니다. 그러면 상태는 아래로, 이벤트는 위로 흐르는 단방향 데이터 흐름이 됩니다. 이때 자식에게 ViewModel 전체를 넘기면 자식이 ViewModel에 결합되어 미리보기와 테스트가 어려워지므로 필요한 값과 콜백만 넘깁니다. 반대로 무조건 ViewModel까지 올리면 UI 전용 상태가 ViewModel을 오염시키게 됩니다. 또 같은 정보를 ViewModel과 remember 양쪽에 두면 어느 쪽이 진실인지 알 수 없어지므로, 소유자를 하나로 정하고 나머지는 그 값을 받아 그리기만 해야 합니다.',
 'interview-question/841.mp3'),
(842, 'COMPOSE', 169, 'NORMAL', true,
 'Compose에서 remember와 rememberSaveable은 상태를 유지하는 범위가 어떻게 다른가요?',
 'remember는 계산 결과를 컴포지션 트리의 해당 위치에 저장해 재구성 사이에는 값을 유지하지만, 화면 회전 같은 Activity 재생성 시에는 컴포지션이 통째로 사라지므로 값이 초기화됩니다. rememberSaveable은 값을 Bundle(SavedInstanceState)에 함께 저장하기 때문에 화면 회전뿐 아니라 프로세스 종료 후에도 값을 복원합니다. Bundle에 담을 수 있는 타입은 자동으로 처리되지만, 그 외의 사용자 정의 타입은 Saver를 직접 정의해 Bundle 호환 형태로 변환해야 합니다. 다만 Bundle에 저장되므로 큰 목록이나 이미지 같은 무거운 데이터는 넣으면 안 되고, 이런 데이터는 ID만 저장한 뒤 ViewModel이나 저장소에서 다시 불러옵니다. 또한 두 방식 모두 컴포저블이 컴포지션에서 제거되면 값이 소멸합니다. 그래서 remember는 애니메이션 값이나 캐시된 객체에, rememberSaveable은 텍스트 입력·펼침 여부·선택된 탭 같은 값에 적합합니다.',
 'interview-question/842.mp3'),
(843, 'COMPOSE', 169, 'NORMAL', true,
 'UI 상태를 일반 상태 홀더 클래스에 둘 때와 ViewModel에 둘 때는 어떻게 다르며, 각각 어떤 경우에 선택하시나요?',
 '일반 상태 홀더 클래스는 remember로 생성되므로 수명이 컴포지션 위치를 따르고, 여러 UI 상태와 관련 UI 로직을 묶어 담습니다. UI 로직이 복잡해져 컴포저블이 비대해질 때, 로직을 컴포저블 밖으로 분리하되 ViewModel까지는 올리지 않고 싶을 때 선택합니다. 복원이 필요하면 rememberSaveable과 Saver로 감싼 rememberXxxState() 팩토리를 제공하는 것이 Compose 라이브러리의 관례이며, rememberScrollState나 rememberLazyListState가 그 예입니다. 반면 ViewModel은 화면(소유자) 수명을 가지므로 컴포지션에서 제거되어도 유지되고, 화면 데이터와 비즈니스 로직, 저장소 접근을 담습니다. 구성 변경에서 살아남아야 하거나 비동기 작업, DI가 필요한 경우에 ViewModel을 선택합니다.',
 'interview-question/843.mp3'),
(844, 'COMPOSE', 169, 'EASY', true,
 'Compose의 상태 호이스팅(State Hoisting)이란 무엇인지 설명해 주세요.',
 '상태 호이스팅은 상태를 컴포저블 내부에 두지 않고 호출자, 즉 부모로 끌어올리는 패턴입니다. 자식 컴포저블은 상태를 직접 갖지 않고 값(value)과 변경 요청 콜백(onValueChange)만 전달받습니다. 이때 상태를 가진 컴포저블을 Stateful, 상태를 외부에서 받는 컴포저블을 Stateless라고 부릅니다. 결과적으로 상태는 아래로, 이벤트는 위로 흐르는 단방향 데이터 흐름(UDF)이 만들어집니다. 호이스팅의 장점은 재사용성, 테스트 용이성, 단일 진실 원천이며, Stateless 컴포저블은 미리보기와 UI 테스트에서 상태를 직접 주입해 검증할 수 있습니다.',
 'interview-question/844.mp3'),
(845, 'COMPOSE', 169, 'EASY', true,
 'Compose에서 화면에 표시되는 값을 일반 변수 대신 mutableStateOf와 remember로 관리해야 하는 이유는 무엇인가요?',
 'Compose가 값의 변경을 감지하려면 그 값이 Snapshot 상태 객체(State/MutableState)여야 합니다. 일반 변수를 쓰면 값이 바뀌어도 재구성이 일어나지 않아 화면이 갱신되지 않습니다. mutableStateOf로 상태 객체를 만들면 .value를 읽을 때 추적되고, 값을 쓰면 그 값을 읽은 컴포저블이 무효화되어 재구성됩니다. 하지만 mutableStateOf만 쓰고 remember를 빼면 재구성마다 초기값으로 새 객체가 만들어져 값이 항상 초기값으로 돌아갑니다. remember는 계산 결과를 컴포지션 트리의 해당 위치에 저장해 재구성 사이에 값을 유지해 줍니다. 즉 상태 객체를 만드는 것과 재구성 사이에 유지하는 것은 별개의 문제입니다. 참고로 일반 MutableList를 mutableStateOf에 넣고 add()만 하면 참조가 같아서 변경이 감지되지 않으므로, 목록은 mutableStateListOf()를 써야 원소 단위 변경도 추적됩니다.',
 'interview-question/845.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 841
(4530, 841, '상태를 읽는 모든 컴포저블의 가장 가까운 공통 부모까지 끌어올려야 한다고 설명', 'ESSENTIAL', 1),
(4531, 841, '입력창 자식 컴포저블은 값과 변경 콜백만 받는 Stateless로 만든다고 설명', 'ESSENTIAL', 2),
(4532, 841, '무조건 ViewModel까지 올리면 UI 전용 상태가 ViewModel을 오염시킨다고 언급', 'ESSENTIAL', 3),
(4533, 841, '같은 정보는 ViewModel과 remember 양쪽에 두지 말고 소유자를 하나로 정해야 한다고 설명', 'ESSENTIAL', 4),
(4534, 841, '자식에게 ViewModel 전체 대신 필요한 값과 콜백만 넘겨야 한다고 언급', 'SUPPLEMENTARY', 5),
(4535, 841, '상태를 변경하는 곳이 소유자보다 위에 있으면 그 위치까지 올려야 한다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 842
(4536, 842, 'remember는 화면 회전 같은 Activity 재생성 시 값이 초기화된다고 언급', 'ESSENTIAL', 1),
(4537, 842, 'rememberSaveable은 화면 회전 후에도 값이 유지된다고 언급', 'ESSENTIAL', 2),
(4538, 842, 'rememberSaveable은 프로세스 종료 후에도 값을 복원한다고 언급', 'ESSENTIAL', 3),
(4539, 842, 'rememberSaveable이 값을 Bundle(SavedInstanceState)에 저장한다고 언급', 'SUPPLEMENTARY', 4),
(4540, 842, 'remember와 rememberSaveable 모두 컴포지션에서 제거되면 값이 소멸한다고 언급', 'SUPPLEMENTARY', 5),
(4541, 842, 'Bundle에 담을 수 없는 사용자 정의 타입은 Saver를 직접 정의해야 한다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 843
(4542, 843, '일반 상태 홀더 클래스의 수명은 remember로 만든 컴포지션 위치를 따른다고 언급', 'ESSENTIAL', 1),
(4543, 843, 'ViewModel은 화면(소유자) 수명을 가져 컴포지션에서 제거돼도 유지된다고 설명', 'ESSENTIAL', 2),
(4544, 843, 'UI 로직이 복잡해져 컴포저블이 비대해지면 일반 상태 홀더 클래스를 선택한다고 설명', 'ESSENTIAL', 3),
(4545, 843, '구성 변경 생존·비동기 작업·DI 중 하나가 필요하면 ViewModel을 선택한다고 설명', 'ESSENTIAL', 4),
(4546, 843, '상태 홀더를 rememberSaveable과 Saver로 감싼 rememberXxxState() 팩토리로 제공한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 844
(4547, 844, '상태를 컴포저블 내부가 아닌 호출자(부모)로 끌어올리는 패턴이라고 설명', 'ESSENTIAL', 1),
(4548, 844, '자식은 값(value)과 변경 요청 콜백(onValueChange)만 전달받는다고 언급', 'ESSENTIAL', 2),
(4549, 844, '상태는 아래로, 이벤트는 위로 흐르는 단방향 데이터 흐름이 만들어진다고 설명', 'ESSENTIAL', 3),
(4550, 844, '상태를 가진 컴포저블은 Stateful, 외부에서 받는 컴포저블은 Stateless로 구분', 'SUPPLEMENTARY', 4),
(4551, 844, '호이스팅의 장점으로 재사용성·테스트 용이성·단일 진실 원천 중 최소 1개를 제시', 'SUPPLEMENTARY', 5),

-- 질문 845
(4552, 845, '일반 변수는 값이 바뀌어도 재구성이 일어나지 않아 화면이 갱신되지 않는다고 설명', 'ESSENTIAL', 1),
(4553, 845, 'mutableStateOf로 만든 Snapshot 상태 객체여야 Compose가 변경을 감지한다고 설명', 'ESSENTIAL', 2),
(4554, 845, 'remember가 없으면 재구성마다 초기값으로 새 상태 객체가 만들어진다고 설명', 'ESSENTIAL', 3),
(4555, 845, '일반 MutableList에 add()만 하면 참조가 같아 변경이 감지되지 않는다고 언급', 'SUPPLEMENTARY', 4),
(4556, 845, '목록은 mutableStateListOf()를 써야 원소 단위 변경이 추적된다고 언급', 'SUPPLEMENTARY', 5);
