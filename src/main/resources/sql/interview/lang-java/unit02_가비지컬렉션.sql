-- Unit: 가비지 컬렉션 (Unit ID: 187)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(931, 'JAVA', 187, 'HARD', true,
 '운영 중인 Java 서버에서 Full GC가 잦아지고 지연 시간이 급증하고 있습니다. 어떤 원인을 의심할 수 있고, 어떤 순서로 진단·대응하시겠습니까?',
 'Full GC는 Young과 Old를 전부 수집하며 대부분의 컬렉터에서 가장 긴 STW를 유발하므로, Full GC가 잦으면 지연 시간이 급증합니다. 먼저 의심할 원인은 두 가지입니다. 첫째는 조기 승격으로, Young 영역이 너무 작거나 Minor GC가 너무 잦으면 잠깐 쓰고 버릴 객체까지 Old로 올라가고, 결국 Old 영역이 빨리 차서 Full GC가 늘어납니다. 둘째는 메모리 누수로, 예를 들어 정적 컬렉션에 계속 추가만 하고 제거하지 않으면 쓰지 않는 객체를 루트에서 계속 붙잡게 되어 Old 영역이 계속 증가합니다. ThreadLocal을 스레드 풀에서 쓰고 remove()하지 않는 경우나 리스너를 해제하지 않는 경우도 대표적인 누수 원인입니다. 진단 순서는 먼저 기본 컬렉터로 GC 로그를 수집해 Full GC 빈도, 최대 정지 시간, Old 증가 추세를 확인하고, Minor GC 빈도와 Old 증가 속도를 함께 봅니다. 누수가 의심되면 옵션 튜닝보다 힙 덤프로 원인 객체를 찾는 것이 먼저이고, 그다음 힙 크기(-Xms와 -Xmx를 같게 고정), 목표 정지 시간, 컬렉터 순으로 조정합니다. 또한 System.gc() 호출은 대부분의 컬렉터에서 Full GC를 강제해 긴 STW를 일으키므로 코드에서 제거하거나 -XX:+DisableExplicitGC로 무시하도록 설정합니다.',
 'interview-question/931.mp3'),
(932, 'JAVA', 187, 'NORMAL', true,
 '두 객체가 서로를 참조하는 순환 참조 상태라면 JVM의 GC가 이 객체들을 회수할 수 있나요? 참조 카운팅 방식과 비교해 설명해 주세요.',
 '회수할 수 있습니다. JVM의 GC는 참조 카운트가 아니라 도달 가능성으로 살아 있는 객체를 판단하는 추적(Tracing) GC입니다. 실행 중인 스레드의 스택 프레임 지역 변수·매개변수, 로딩된 클래스의 static 필드 같은 GC 루트에서 참조를 따라갈 수 있는 객체는 살아 있고, 그렇지 못한 객체는 가비지입니다. 따라서 두 객체가 서로를 참조하더라도 루트에서 끊겨 있으면 정상적으로 회수됩니다. 반면 Python의 기본 방식이나 Swift ARC 같은 참조 카운팅 방식에서는 순환 참조가 문제가 됩니다. 그래서 Java에서 순환 참조 자체는 누수 원인이 아니며, Java의 메모리 누수는 쓰지 않는 객체를 루트에서 계속 붙잡고 있는 것입니다.',
 'interview-question/932.mp3'),
(933, 'JAVA', 187, 'NORMAL', true,
 'Mark-Sweep, Mark-Compact, Copying 알고리즘의 차이는 무엇이고, Young 영역과 Old 영역에는 각각 어떤 알고리즘이 주로 쓰이나요?',
 'Mark-Sweep은 도달 가능한 객체를 표시(Mark)하고 나머지를 해제(Sweep)하는 방식으로, 구현이 단순하고 객체 이동이 없지만 단편화가 발생해 할당 시 빈 공간을 탐색하는 비용이 듭니다. Mark-Compact는 Mark 후 생존 객체를 한쪽으로 밀어 정렬하므로 단편화가 해소되고 순차 할당이 가능하지만, 객체 이동과 참조 갱신 비용이 커서 정지 시간이 깁니다. Copying은 생존 객체만 다른 공간으로 복사하고 원래 공간을 통째로 비우는 방식으로, 생존 객체가 적을수록 매우 빠르지만 복사받을 예비 공간을 비워 두어야 합니다. 실제 컬렉터는 이를 영역별로 조합하는데, 생존율이 낮은 Young 영역은 Copying을, 생존율이 높은 Old 영역은 Mark-Sweep 또는 Mark-Compact를 쓰는 것이 일반적입니다. Young 영역의 Survivor 두 개 중 항상 하나가 비어 있는 것이 바로 Copying 알고리즘의 예비 공간 역할입니다.',
 'interview-question/933.mp3'),
(934, 'JAVA', 187, 'EASY', true,
 'Young 영역에서 Minor GC가 어떤 흐름으로 진행되는지 설명해 주세요.',
 '새 객체는 먼저 Eden에 할당되고, Eden이 가득 차면 Minor GC가 발생합니다. Minor GC는 Eden(과 사용 중인 Survivor)의 생존 객체만 비어 있는 Survivor 영역으로 복사하고 원래 공간은 통째로 비우며, 이때 생존 객체의 나이가 1씩 증가합니다. Survivor는 두 개가 있고 항상 하나는 비어 있어서 다음 Minor GC 때 복사 대상이 됩니다. 이렇게 살아남아 나이가 임계값(tenuring threshold)을 넘은 객체는 Old 영역으로 승격(Promotion)됩니다. 나이는 객체 헤더에 기록되고 HotSpot의 최대 임계값은 15입니다. 또한 Survivor에 들어가지 못할 만큼 큰 객체는 Old 영역에 바로 할당되기도 합니다. Old 객체가 Young 객체를 참조하는 경우는 카드 테이블에 기록해 두므로, Minor GC 때 Old 영역 전체를 훑지 않고 표시된 카드만 확인하면 되어 Young 수집이 빨라집니다.',
 'interview-question/934.mp3'),
(935, 'JAVA', 187, 'EASY', true,
 'GC에서 말하는 Stop-The-World란 무엇이며, 애플리케이션 스레드는 언제 멈추게 되나요?',
 'Stop-The-World(STW)는 GC가 정확한 객체 그래프를 얻기 위해 애플리케이션 스레드를 모두 멈추는 것입니다. 스레드는 아무 지점에서나 멈추는 것이 아니라 JIT가 삽입한 세이프포인트(Safepoint)에 도달했을 때 멈춥니다. 그래서 긴 반복문 안에 세이프포인트가 없으면 모든 스레드가 그 스레드를 기다리는 세이프포인트 지연이 생기기도 합니다. STW 동안 애플리케이션은 요청을 처리하지 못하므로 지연 시간 급증으로 이어지고, GC 튜닝의 목표는 결국 전체 실행 시간 중 애플리케이션 실행에 쓴 비율인 처리량과 한 번의 STW가 지속되는 시간인 지연 시간 사이의 균형을 맞추는 것입니다.',
 'interview-question/935.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 931
(5019, 931, 'Young 영역이 작아 조기 승격이 일어나면 Old가 빨리 차 Full GC가 늘어남을 설명', 'ESSENTIAL', 1),
(5020, 931, '정적 컬렉션이 쓰지 않는 객체를 계속 붙잡는 메모리 누수를 Old 증가 원인으로 제시', 'ESSENTIAL', 2),
(5021, 931, '옵션 튜닝 전에 GC 로그를 먼저 수집해 Full GC 빈도·최대 정지 시간을 본다고 언급', 'ESSENTIAL', 3),
(5022, 931, '누수가 의심되면 옵션 튜닝보다 힙 덤프로 원인 객체를 찾는 것이 먼저임을 언급', 'ESSENTIAL', 4),
(5023, 931, 'System.gc() 호출이 Full GC를 강제해 긴 STW를 일으킴을 언급', 'SUPPLEMENTARY', 5),
(5024, 931, 'ThreadLocal을 스레드 풀에서 remove()하지 않는 것을 누수 원인으로 언급', 'SUPPLEMENTARY', 6),

-- 질문 932
(5025, 932, 'JVM은 GC 루트에서 참조를 따라갈 수 있는지(도달 가능성)로 생존을 판단함을 설명', 'ESSENTIAL', 1),
(5026, 932, '루트에서 끊긴 순환 참조 객체는 JVM에서 정상적으로 회수됨을 언급', 'ESSENTIAL', 2),
(5027, 932, '참조 카운팅 방식에서는 순환 참조가 문제가 된다고 언급', 'ESSENTIAL', 3),
(5028, 932, '스택 프레임 지역 변수·static 필드 중 최소 1개를 GC 루트의 예로 제시', 'SUPPLEMENTARY', 4),
(5029, 932, 'Java의 메모리 누수는 쓰지 않는 객체를 루트에서 계속 붙잡는 것임을 언급', 'SUPPLEMENTARY', 5),
(5030, 932, 'Python 기본 방식·Swift ARC 중 최소 1개를 참조 카운팅 방식의 예로 제시', 'SUPPLEMENTARY', 6),

-- 질문 933
(5031, 933, 'Mark-Sweep의 단점이 단편화 발생임을 언급', 'ESSENTIAL', 1),
(5032, 933, 'Mark-Compact의 단점이 객체 이동·참조 갱신 비용으로 인한 긴 정지 시간임을 언급', 'ESSENTIAL', 2),
(5033, 933, 'Copying의 단점이 복사받을 예비 공간을 비워 두어야 하는 것임을 언급', 'ESSENTIAL', 3),
(5034, 933, 'Young은 Copying, Old는 Mark-Sweep 또는 Mark-Compact를 쓴다고 설명', 'ESSENTIAL', 4),
(5035, 933, '영역별 알고리즘 조합의 근거로 Young은 생존율이 낮고 Old는 높다는 점을 제시', 'SUPPLEMENTARY', 5),
(5036, 933, 'Copying은 생존 객체가 적을수록 매우 빠르다는 장점을 언급', 'SUPPLEMENTARY', 6),
(5037, 933, 'Survivor 두 개 중 항상 하나가 비어 Copying의 예비 공간 역할을 함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 934
(5038, 934, '새 객체는 Eden에 할당되고 Eden이 가득 차면 Minor GC가 발생함을 설명', 'ESSENTIAL', 1),
(5039, 934, 'Minor GC 때 생존 객체만 비어 있는 Survivor로 복사된다고 설명', 'ESSENTIAL', 2),
(5040, 934, '나이가 임계값(tenuring threshold)을 넘은 객체는 Old로 승격됨을 언급', 'ESSENTIAL', 3),
(5041, 934, 'Minor GC에서 살아남을 때마다 객체의 나이가 1씩 증가함을 언급', 'SUPPLEMENTARY', 4),
(5042, 934, '카드 테이블로 Old→Young 참조를 기록해 Old 전체를 훑지 않는다고 언급', 'SUPPLEMENTARY', 5),
(5043, 934, 'Survivor에 들어가지 못할 만큼 큰 객체는 Old에 바로 할당될 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 935
(5044, 935, 'STW는 GC가 애플리케이션 스레드를 모두 멈추는 것임을 언급', 'ESSENTIAL', 1),
(5045, 935, '스레드를 멈추는 목적이 정확한 객체 그래프를 얻기 위함임을 언급', 'ESSENTIAL', 2),
(5046, 935, '스레드는 아무 지점이 아니라 세이프포인트에 도달했을 때 멈춘다고 언급', 'ESSENTIAL', 3),
(5047, 935, '긴 반복문에 세이프포인트가 없으면 다른 스레드가 기다리는 지연이 생김을 언급', 'SUPPLEMENTARY', 4),
(5048, 935, 'GC 튜닝의 목표가 처리량과 지연 시간 사이의 균형임을 언급', 'SUPPLEMENTARY', 5);
