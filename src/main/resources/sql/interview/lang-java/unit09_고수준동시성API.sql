-- Unit: 고수준 동시성 API (Unit ID: 194)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(966, 'JAVA', 194, 'HARD', true,
 '트래픽이 몰리는 백엔드 서비스에서 Executors.newFixedThreadPool을 그대로 쓰면 어떤 문제가 생기고, ThreadPoolExecutor를 직접 구성한다면 무엇을 고려해야 하나요?',
 'Executors.newFixedThreadPool은 편하지만 내부적으로 무한 LinkedBlockingQueue를 사용하기 때문에, 트래픽이 몰려 처리 속도보다 제출 속도가 빠르면 작업이 큐에 계속 쌓여 결국 메모리가 고갈됩니다. 비슷하게 newCachedThreadPool은 스레드 수 상한이 없어 부하 시 스레드가 폭증합니다. ThreadPoolExecutor는 작업이 들어오면 먼저 실행 중인 스레드가 corePoolSize보다 적으면 새 스레드를 만들어 실행하고, core가 가득 차면 큐에 넣으며, 큐까지 가득 찼을 때 비로소 maximumPoolSize까지 스레드를 추가하고, 큐도 가득 차고 스레드도 max에 도달하면 거부 정책을 실행합니다. 즉 ''큐가 먼저, 스레드 추가는 나중''이라서 큐가 무한이면 스레드 추가 단계가 영원히 일어나지 않아 maximumPoolSize가 무의미해집니다. 그래서 운영 코드에서는 ThreadPoolExecutor를 직접 생성해 ArrayBlockingQueue 같은 유한 큐와 거부 정책을 명시하는 것이 원칙입니다. 거부 정책은 예외를 던지는 기본 AbortPolicy 외에, 제출한 스레드가 직접 실행해 자연스러운 배압을 만드는 CallerRunsPolicy 등을 고를 수 있습니다. 풀 크기는 CPU 바운드면 코어 수 ± 1, I/O 바운드면 코어 수 × (1 + 대기 시간 / 계산 시간)에서 출발해 측정으로 조정합니다.',
 'interview-question/966.mp3'),
(967, 'JAVA', 194, 'NORMAL', true,
 'AtomicInteger 같은 원자 클래스가 사용하는 CAS 방식과 synchronized 같은 락 방식은 어떤 차이가 있고, 각각 언제 쓰는 것이 적합한가요?',
 '락(synchronized·Lock)은 먼저 잠그고 실행하는 비관적 방식이고, 원자 클래스의 CAS는 ''메모리 값이 기대한 값이면 새 값으로 바꾼다''를 CPU 명령으로 원자적으로 수행하면서, 일단 시도하고 그 사이 다른 스레드가 값을 바꿨으면 실패 후 재시도하는 낙관적 방식입니다. 락은 대기 스레드가 블로킹되어 컨텍스트 스위칭이 생기지만, CAS는 블로킹 없이 스핀 재시도합니다. 그래서 경쟁이 낮을 때는 CAS가 매우 빠르고 락은 오버헤드가 상대적으로 큽니다. 반대로 경쟁이 높으면 CAS는 재시도가 폭증해 CPU를 낭비하고, 락은 대기 후 순차 처리로 안정적입니다. 적용 범위도 달라서 CAS는 단일 변수의 갱신에, 락은 여러 변수를 다루는 복합 로직에 적합합니다. 고경쟁 카운터라면 셀을 여러 개 두고 스레드를 분산시키는 LongAdder를 고려합니다. 또 CAS는 값이 A → B → A로 바뀌면 변화를 감지하지 못하는 ABA 문제가 있어, 참조 타입에서 문제가 되면 AtomicStampedReference로 버전을 함께 비교합니다.',
 'interview-question/967.mp3'),
(968, 'JAVA', 194, 'NORMAL', true,
 'ConcurrentHashMap은 Collections.synchronizedMap과 비교해 동시성을 어떻게 보장하며, 사용할 때 주의할 점은 무엇인가요?',
 'Collections.synchronizedMap은 모든 메서드에 하나의 락을 거는 방식이라 ConcurrentHashMap보다 훨씬 느리고, 순회할 때도 별도 동기화가 필요합니다. ConcurrentHashMap은 Java 8+에서 버킷 단위로 CAS를 사용하고, 충돌이 나면 해당 버킷 헤드에만 synchronized를 걸어 동시성을 보장하며, 읽기는 락 없이 수행됩니다. 주의할 점은 개별 메서드가 안전하더라도 두 연산의 조합은 원자적이지 않다는 것입니다. 예를 들어 containsKey로 검사한 뒤 put하는 check-then-act 코드는 두 연산 사이에 다른 스레드가 끼어들어 갱신이 유실될 수 있으므로, merge·compute·computeIfAbsent 같은 원자적 복합 연산을 써야 합니다. 또 ConcurrentHashMap은 null 키·값을 허용하지 않고, size()·isEmpty()는 순간 스냅샷일 뿐 정확한 동기화 값이 아닙니다.',
 'interview-question/968.mp3'),
(969, 'JAVA', 194, 'EASY', true,
 '자바에서 스레드 인터럽트란 무엇이며, InterruptedException을 잡았을 때는 어떻게 처리해야 하나요?',
 '인터럽트는 스레드를 강제로 종료하는 것이 아니라 ''멈춰 달라''는 협력적 신호입니다. sleep·wait·BlockingQueue.take 같은 메서드는 인터럽트되면 InterruptedException을 던지면서 인터럽트 상태를 지웁니다. 그래서 이 예외를 빈 catch로 삼켜 버리면 종료 요청이 사라져, 스레드 풀이 shutdownNow로 종료하려 해도 스레드가 멈추지 않습니다. 올바른 처리는 예외를 삼키지 않고 catch 블록에서 Thread.currentThread().interrupt()를 호출해 인터럽트 상태를 복원한 뒤 종료하는 것이며, 이렇게 하면 상위 코드나 풀이 종료 의사를 알 수 있습니다.',
 'interview-question/969.mp3'),
(970, 'JAVA', 194, 'EASY', true,
 '요청마다 new Thread()로 스레드를 만드는 대신 Executor 기반 스레드 풀을 사용하는 이유는 무엇인가요?',
 '플랫폼 스레드는 생성할 때마다 OS 스레드와 스택 메모리(기본 약 1MB)를 할당하므로 생성 비용이 큽니다. 또 요청마다 new Thread()를 하면 스레드 수에 제한이 없어서, 부하가 몰리면 스레드가 수천 개 생기고 unable to create native thread 같은 OOM이 발생할 수 있습니다. Executor는 작업 제출과 실행을 분리해서, 미리 만든 스레드를 재사용해 생성 비용을 줄이고 스레드 개수를 제한합니다. 예를 들어 크기가 제한된 풀에 submit으로 작업을 제출하고 Future로 결과를 받는 방식으로 사용합니다.',
 'interview-question/970.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 966
(5212, 966, 'newFixedThreadPool은 무한 큐를 써서 작업이 쌓이면 메모리가 고갈됨을 언급', 'ESSENTIAL', 1),
(5213, 966, 'ThreadPoolExecutor가 core 스레드 → 큐 → max까지 스레드 추가 → 거부 정책 순으로 작업을 처리함을 설명', 'ESSENTIAL', 2),
(5214, 966, '큐가 무한이면 스레드 추가가 일어나지 않아 maximumPoolSize가 무의미해짐을 언급', 'ESSENTIAL', 3),
(5215, 966, 'ThreadPoolExecutor를 직접 생성해 유한 큐와 거부 정책을 설정해야 함을 제시', 'ESSENTIAL', 4),
(5216, 966, 'CallerRunsPolicy는 제출한 스레드가 직접 실행해 자연스러운 배압을 만든다는 점을 언급', 'SUPPLEMENTARY', 5),
(5217, 966, 'newCachedThreadPool은 스레드 수 상한이 없어 부하 시 스레드가 폭증함을 언급', 'SUPPLEMENTARY', 6),
(5218, 966, 'I/O 바운드 풀 크기를 코어 수 × (1 + 대기 시간 / 계산 시간)에서 출발해 조정함을 제시', 'SUPPLEMENTARY', 7),

-- 질문 967
(5219, 967, '락은 먼저 잠그는 비관적 방식, CAS는 시도 후 충돌 시 재시도하는 낙관적 방식이라는 차이를 설명', 'ESSENTIAL', 1),
(5220, 967, '락은 대기 스레드가 블로킹되지만 CAS는 블로킹 없이 스핀 재시도함을 언급', 'ESSENTIAL', 2),
(5221, 967, '경쟁이 높을 때 CAS는 재시도 폭증으로 CPU를 낭비함을 언급', 'ESSENTIAL', 3),
(5222, 967, 'CAS는 단일 변수 갱신에, 락은 여러 변수·복합 로직에 적합함을 제시', 'ESSENTIAL', 4),
(5223, 967, '고경쟁 카운터에는 AtomicLong 대신 LongAdder를 고려함을 언급', 'SUPPLEMENTARY', 5),
(5224, 967, 'ABA 문제의 대응책으로 AtomicStampedReference를 제시', 'SUPPLEMENTARY', 6),

-- 질문 968
(5225, 968, 'synchronizedMap은 모든 메서드에 하나의 락을 걸어 ConcurrentHashMap보다 느림을 언급', 'ESSENTIAL', 1),
(5226, 968, 'ConcurrentHashMap이 Java 8+에서 버킷 단위 CAS와 충돌 시 버킷 헤드 synchronized를 씀을 설명', 'ESSENTIAL', 2),
(5227, 968, 'containsKey 후 put 같은 check-then-act 조합은 원자적이지 않아 갱신이 유실될 수 있음을 언급', 'ESSENTIAL', 3),
(5228, 968, 'merge·compute·computeIfAbsent 같은 원자적 복합 연산을 대안으로 제시', 'SUPPLEMENTARY', 4),
(5229, 968, 'ConcurrentHashMap의 읽기는 락 없이 수행됨을 언급', 'SUPPLEMENTARY', 5),
(5230, 968, 'ConcurrentHashMap은 null 키·값을 허용하지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 969
(5231, 969, '인터럽트는 스레드를 강제 종료하는 것이 아니라 멈춰 달라는 협력적 신호임을 언급', 'ESSENTIAL', 1),
(5232, 969, 'catch 블록에서 Thread.currentThread().interrupt()로 인터럽트 상태를 복원함을 언급', 'ESSENTIAL', 2),
(5233, 969, 'InterruptedException이 던져질 때 인터럽트 상태가 지워짐을 언급', 'SUPPLEMENTARY', 3),
(5234, 969, '예외를 삼키면 풀이 shutdownNow로 종료해도 스레드가 멈추지 않음을 언급', 'SUPPLEMENTARY', 4),

-- 질문 970
(5235, 970, '플랫폼 스레드는 생성마다 OS 스레드와 스택 메모리를 할당해 생성 비용이 큼을 언급', 'ESSENTIAL', 1),
(5236, 970, '요청마다 스레드를 만들면 스레드 수가 무제한으로 늘어 OOM이 발생할 수 있음을 언급', 'ESSENTIAL', 2),
(5237, 970, 'Executor가 스레드를 재사용해 생성 비용을 줄임을 언급', 'ESSENTIAL', 3),
(5238, 970, 'Executor가 스레드 개수를 제한함을 언급', 'SUPPLEMENTARY', 4),
(5239, 970, 'Executor가 작업 제출과 실행을 분리함을 언급', 'SUPPLEMENTARY', 5);
