-- Unit: 동시성 기본 (Unit ID: 193)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(961, 'JAVA', 193, 'HARD', true,
 '여러 스레드가 공유 카운터를 count++로 증가시키고, 별도의 running 종료 플래그로 작업 루프를 멈추는 코드가 있습니다. 두 필드에 각각 어떤 동시성 도구를 적용할지, 그리고 그 선택의 대가는 무엇인지 설명해 주시겠어요?',
 '두 필드는 요구하는 보장이 달라서 도구도 다르게 고릅니다. 먼저 카운터의 count++는 원자적이지 않고 읽기, +1 계산, 쓰기의 세 단계로 실행됩니다. 두 스레드가 같은 값을 읽고 각각 1을 더해 쓰면 두 번 증가했는데도 값은 1만 늘어나는 갱신 유실이 생깁니다. volatile은 가시성과 순서만 보장하고 복합 연산의 원자성은 보장하지 않기 때문에, 카운터에 volatile만 붙여도 갱신 유실은 그대로 발생합니다. 그래서 카운터는 increment 메서드를 synchronized로 만들거나 AtomicInteger의 incrementAndGet을 사용해 보호합니다. 반면 running 플래그는 한 스레드만 값을 쓰고 다른 스레드는 읽기만 하며 새 값이 이전 값에 의존하지 않으므로 volatile이 적합합니다. volatile이 없으면 JIT가 running을 레지스터에 올려 둬서 stop()을 호출해도 루프가 끝나지 않을 수 있는데, volatile은 항상 메인 메모리에서 읽고 쓰므로 가시성을 보장해 줍니다. 대가도 있습니다. synchronized는 원자성·가시성·순서를 모두 보장하지만 락 획득과 해제 비용이 들고, 경쟁이 심하면 스레드가 블로킹되어 대기 상태로 전환되면서 컨텍스트 스위칭 비용이 발생합니다. volatile은 락이 없어 블로킹이 발생하지 않고 캐시 우회·배리어 비용만 들어 락보다 훨씬 가볍지만, 복합 연산의 원자성은 보장하지 않으므로 원자성이 필요한 곳에는 쓸 수 없다는 대가가 있습니다. 참고로 이런 가시성 버그는 JIT 최적화 이후 특정 하드웨어에서 간헐적으로 나타나기 때문에 테스트로 잡기 어렵고, 지금까지 문제가 없었다는 것이 올바르다는 근거가 되지 않습니다.'),
(962, 'JAVA', 193, 'NORMAL', true,
 'synchronized와 volatile의 차이를 원자성·가시성·순서 보장 관점에서 설명해 주시겠어요?',
 '두 키워드의 차이는 락이 있느냐 없느냐보다 원자성, 가시성, 순서라는 세 가지 보장 중 무엇을 제공하느냐에 있습니다. synchronized는 블록 전체의 원자성, 가시성, 순서를 모두 보장합니다. 반면 volatile은 가시성과 순서만 보장하고 원자성은 단일 읽기와 쓰기에만 해당하므로 count++ 같은 복합 연산의 원자성은 보장하지 않습니다. 또 synchronized는 모니터 락을 사용하므로 경쟁이 생기면 스레드가 대기하는 블로킹이 발생하지만, volatile은 락이 없어서 블로킹이 발생하지 않고 비용도 락보다 훨씬 가볍습니다. 적용 대상도 달라서 synchronized는 메서드나 블록에, volatile은 필드에 붙입니다. 그래서 한 스레드만 쓰고 여러 스레드가 읽는 단일 플래그나 설정 값 발행에는 volatile이 적합하고, 여러 변수의 일관성을 지키거나 읽고-수정하고-쓰는 연산에는 synchronized가 적합합니다.'),
(963, 'JAVA', 193, 'NORMAL', true,
 '인스턴스 메서드에 선언한 synchronized와 static 메서드에 선언한 synchronized는 서로 배타적으로 실행되나요? 락 객체 관점에서 차이를 설명해 주세요.',
 '서로 배타적이지 않습니다. 모든 Java 객체는 모니터라는 내재 락을 하나씩 가지고, synchronized는 이 모니터를 획득한 스레드만 실행하게 합니다. 인스턴스 메서드에 synchronized를 선언하면 락 객체는 this이므로, 같은 객체의 synchronized 인스턴스 메서드끼리는 서로 배타적입니다. 반면 static 메서드에 synchronized를 선언하면 락 객체는 클래스.class, 예를 들어 BankAccount.class가 됩니다. 두 락은 서로 별개의 객체이기 때문에 한 스레드가 인스턴스 synchronized 메서드를 실행하는 동안 다른 스레드가 static synchronized 메서드를 동시에 실행할 수 있습니다. 참고로 synchronized (obj) 블록 형태를 쓰면 지정한 객체를 락으로 삼아 임계 영역을 최소화하고 락을 분리하기 유리하며, private final Object lock을 쓰는 것이 권장됩니다. 이때 String 리터럴이나 Integer처럼 공유될 수 있는 객체를 락으로 쓰면 전혀 다른 코드와 같은 락을 잡게 되어 데드락이나 성능 저하가 생길 수 있습니다.'),
(964, 'JAVA', 193, 'EASY', true,
 '멀티스레드 환경에서 가시성 문제란 무엇이고, 왜 발생하는지 설명해 주시겠어요?',
 '가시성은 한 스레드가 쓴 값을 다른 스레드가 볼 수 있다는 보장이고, 가시성 문제는 이 보장이 깨져 한 스레드가 바꾼 값을 다른 스레드가 보지 못하는 상황입니다. 원인은 하드웨어와 컴파일러 최적화에 있습니다. CPU 코어마다 캐시와 레지스터가 있어서 한 코어의 스레드가 변수에 쓴 값이 다른 코어의 스레드에게 언제 보일지 아무 보장이 없습니다. 또 JIT 컴파일러는 성능을 위해 메모리 읽기를 레지스터로 호이스팅하거나 명령을 재배치합니다. 예를 들어 volatile이 없는 running 플래그로 도는 while 루프는 JIT가 running을 레지스터에 올려 두면 다른 스레드가 false로 바꿔도 루프가 끝나지 않을 수 있습니다. Java 메모리 모델, 즉 JMM은 어떤 쓰기가 어떤 읽기에 보이는지를 happens-before 관계로 정의하며, happens-before가 성립해야 다른 스레드의 쓰기가 보입니다.'),
(965, 'JAVA', 193, 'EASY', true,
 'wait()과 notify()의 동작 방식을 설명하고, wait()의 대기 조건을 if가 아닌 while로 검사하는 이유는 무엇인지 말씀해 주시겠어요?',
 '모니터를 가진 스레드는 wait()을 호출하면 락을 놓고 조건이 만족될 때까지 대기합니다. 그리고 다른 스레드가 notify()나 notifyAll()을 호출하면 대기 중인 스레드를 깨웁니다. 두 메서드는 모니터가 필요하므로 반드시 synchronized 블록 안에서 호출해야 합니다. 예를 들어 크기가 제한된 버퍼에서 put은 큐가 가득 차 있으면 wait()으로 대기하고, 원소를 넣은 뒤 notifyAll()로 대기 중인 스레드를 깨웁니다. 이때 대기 조건을 if가 아닌 while로 검사하는 이유는 가짜 깨어남을 방지하기 위해서입니다. 깨어난 뒤 조건을 다시 검사해서 여전히 조건이 맞지 않으면 다시 대기하도록 하는 것입니다. 참고로 wait()은 락을 놓고 대기하지만 Thread.sleep()은 락을 쥔 채로 잔다는 점이 다르고, 실무에서는 wait/notify를 직접 쓰기보다 BlockingQueue나 CountDownLatch 같은 고수준 API를 사용합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 961
(5185, 961, 'count++가 읽기·계산·쓰기 세 단계라 volatile만으로는 갱신 유실이 생김을 설명', 'ESSENTIAL', 1),
(5186, 961, '카운터 보호 수단으로 synchronized 또는 AtomicInteger 중 최소 1개를 제시', 'ESSENTIAL', 2),
(5187, 961, '한 스레드만 쓰는 종료 플래그 running에는 가시성을 보장하는 volatile이 적합함을 설명', 'ESSENTIAL', 3),
(5188, 961, 'synchronized의 블로킹·컨텍스트 스위칭 비용 또는 volatile의 원자성 미보장 중 최소 1개를 선택의 대가로 제시', 'ESSENTIAL', 4),
(5189, 961, 'volatile은 락이 없어 블로킹이 발생하지 않음을 언급', 'SUPPLEMENTARY', 5),
(5190, 961, '가시성 버그는 간헐적으로 나타나 테스트로 잡기 어려움을 언급', 'SUPPLEMENTARY', 6),

-- 질문 962
(5191, 962, 'synchronized는 원자성·가시성·순서를 모두 보장함을 언급', 'ESSENTIAL', 1),
(5192, 962, 'volatile은 가시성과 순서만 보장하고 원자성은 보장하지 않음을 언급', 'ESSENTIAL', 2),
(5193, 962, 'synchronized는 경쟁 시 스레드 대기가 발생하고 volatile은 블로킹이 없다는 차이를 비교', 'SUPPLEMENTARY', 3),
(5194, 962, 'synchronized는 메서드·블록에, volatile은 필드에 적용한다는 적용 대상 차이를 구분', 'SUPPLEMENTARY', 4),
(5195, 962, 'volatile은 단일 플래그, synchronized는 여러 변수의 일관성 유지에 적합함을 서술', 'SUPPLEMENTARY', 5),

-- 질문 963
(5196, 963, '인스턴스 synchronized 메서드의 락 객체가 this임을 명시', 'ESSENTIAL', 1),
(5197, 963, 'static synchronized 메서드의 락 객체가 클래스.class임을 명시', 'ESSENTIAL', 2),
(5198, 963, '두 락이 별개라 인스턴스 메서드와 static 메서드가 동시 실행 가능함을 설명', 'ESSENTIAL', 3),
(5199, 963, 'synchronized 블록은 지정한 객체를 락으로 써서 임계 영역을 최소화할 수 있음을 언급', 'SUPPLEMENTARY', 4),
(5200, 963, 'String 리터럴 등 공유될 수 있는 객체를 락으로 쓰면 데드락·성능 저하가 생김을 언급', 'SUPPLEMENTARY', 5),

-- 질문 964
(5201, 964, '가시성은 한 스레드가 쓴 값을 다른 스레드가 볼 수 있음을 뜻한다고 설명', 'ESSENTIAL', 1),
(5202, 964, 'CPU 코어마다 있는 캐시·레지스터 때문에 쓴 값이 다른 코어에 언제 보일지 보장이 없음을 설명', 'ESSENTIAL', 2),
(5203, 964, 'JIT 컴파일러가 메모리 읽기를 레지스터에 호이스팅하거나 명령을 재배치함을 원인으로 제시', 'ESSENTIAL', 3),
(5204, 964, 'JMM이 happens-before 관계로 어떤 쓰기가 어떤 읽기에 보이는지 정의함을 언급', 'SUPPLEMENTARY', 4),
(5205, 964, '종료 플래그 루프가 끝나지 않는 증상을 가시성 문제의 예로 제시', 'SUPPLEMENTARY', 5),

-- 질문 965
(5206, 965, 'wait()은 락을 놓고 조건이 될 때까지 대기함을 설명', 'ESSENTIAL', 1),
(5207, 965, '다른 스레드가 notify() 또는 notifyAll()로 대기 중인 스레드를 깨움을 설명', 'ESSENTIAL', 2),
(5208, 965, '가짜 깨어남을 방지하려고 조건을 while로 재검사함을 설명', 'ESSENTIAL', 3),
(5209, 965, 'wait()과 notify()는 반드시 synchronized 블록 안에서 호출해야 함을 명시', 'SUPPLEMENTARY', 4),
(5210, 965, 'wait()은 락을 놓지만 sleep()은 락을 쥔 채 대기한다는 차이를 언급', 'SUPPLEMENTARY', 5),
(5211, 965, '실무에서는 BlockingQueue·CountDownLatch 같은 고수준 API를 사용함을 언급', 'SUPPLEMENTARY', 6);
