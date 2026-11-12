-- Unit: 스레드와 커넥션 자원 관리 (Unit ID: 122)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit11 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(606, 'SPRING_BOOT', 122, 'HARD', true,
 '@Transactional 메서드 안에서 타임아웃 없이 결제 API를 호출하는 주문 서비스가 있습니다. 결제사에 장애가 나면 서비스 전체에 어떤 일이 벌어지고, 어떻게 개선하시겠습니까?',
 '커넥션은 트랜잭션 시작 시 획득해 종료 시 반환되므로, @Transactional 안에서 결제 API를 호출하면 외부 호출이 끝날 때까지 DB 커넥션을 붙잡게 됩니다. 타임아웃이 없으면 결제사 장애 시 호출이 무한 대기하고, HikariCP 기본 풀 크기 10이라면 동시 요청 10개만으로 커넥션 풀이 고갈됩니다. 이후 요청들은 커넥션 획득을 기다리며 톰캣 스레드를 점유하므로 커넥션 풀 고갈이 톰캣 스레드 고갈로 전파되고, 결제와 무관한 API까지 전부 멈추게 됩니다. 개선은 먼저 트랜잭션을 DB 작업으로만 좁히는 것입니다. TransactionTemplate으로 주문 저장만 트랜잭션에서 처리하고, 결제 API 호출은 트랜잭션 밖에서 한 뒤, 결과 반영을 다시 별도 트랜잭션으로 처리합니다. 또한 외부 HTTP 호출에는 반드시 연결·읽기 타임아웃을 설정해야 합니다. 추가로 connection-timeout 기본값 30초는 장애 전파 시간이 길므로 수 초 수준으로 낮춰 빠르게 실패시키고 알림을 받는 것이 좋습니다. 풀 크기를 무작정 키우면 DB 쪽 컨텍스트 스위칭만 늘어나므로, 고갈의 원인인 커넥션 점유 시간을 먼저 줄여야 합니다.',
 'interview-question/606.mp3'),
(607, 'SPRING_BOOT', 122, 'NORMAL', true,
 '스프링 부트에서 톰캣 스레드 풀과 HikariCP 커넥션 풀은 요청 처리 중 점유되는 구간과 한도를 초과했을 때의 동작이 어떻게 다른가요?',
 '톰캣 워커 스레드는 요청 하나에 1개가 할당되어 필터부터 응답 완료까지 요청 처리 전 과정 동안 점유되고, DB·외부 API 같은 블로킹 I/O를 기다리는 동안에도 점유됩니다. 반면 DB 커넥션은 @Transactional 서비스에서 트랜잭션 시작 시 획득하고 트랜잭션 종료 시 반환하는 것이 원칙이라 점유 구간이 더 좁습니다. 기본값은 톰캣 threads.max가 200, HikariCP maximum-pool-size가 10입니다. 한도를 넘으면 톰캣은 accept-count(기본 100) 큐에서 요청을 대기시키고, 이 큐도 넘치면 연결을 거부합니다. HikariCP는 커넥션을 얻지 못한 요청을 connection-timeout, 기본 30초 동안 대기시킨 뒤 SQLTransientConnectionException을 던집니다. 참고로 가상 스레드를 켜면 스레드 200개 한계는 사실상 사라지지만 DB 커넥션 풀 한계는 그대로라 커넥션 대기 병목이 더 두드러질 수 있습니다.',
 'interview-question/607.mp3'),
(608, 'SPRING_BOOT', 122, 'NORMAL', true,
 '@Transactional 메서드 안에서 @Async 메서드를 호출하면 비동기 메서드는 호출자의 트랜잭션에 참여하나요? 트랜잭션 커밋 이후에 비동기 작업을 실행하려면 어떻게 해야 하나요?',
 '참여하지 않습니다. 스프링 트랜잭션은 커넥션과 EntityManager를 TransactionSynchronizationManager의 ThreadLocal에 바인딩하기 때문에 트랜잭션은 스레드 하나의 범위를 넘지 못합니다. @Async 메서드는 다른 스레드에서 실행되므로 그 스레드의 ThreadLocal은 비어 있고, 호출자 트랜잭션에 참여하지 않습니다. 그래서 부모 트랜잭션이 롤백해도 자식 스레드가 저장한 데이터는 이미 별도로 커밋되었거나 트랜잭션 없이 실행되어 원자성이 깨질 수 있습니다. 같은 이유로 SecurityContextHolder나 MDC 로그 컨텍스트도 새 스레드에서는 비어 있습니다. 비동기 메서드에서 트랜잭션이 필요하다면 비동기 메서드 자체에 @Transactional을 두어 독립 트랜잭션으로 설계합니다. 또 @Async 호출은 호출자 트랜잭션 커밋보다 먼저 시작될 수 있으므로, 커밋 이후에 실행되게 하려면 @TransactionalEventListener(phase = AFTER_COMMIT)와 @Async를 조합합니다.',
 'interview-question/608.mp3'),
(609, 'SPRING_BOOT', 122, 'EASY', true,
 'REQUIRES_NEW 중첩 때문에 발생하는 커넥션 풀 데드락이 무엇인지 설명해 주세요.',
 'REQUIRES_NEW 중첩 구조에서는 외부 트랜잭션이 커넥션 1개를 보유한 채 내부 REQUIRES_NEW가 커넥션 1개를 더 요청합니다. 예를 들어 풀 크기가 10이고 동시 요청이 10개면, 10개 요청이 각각 커넥션을 1개씩 잡은 상태에서 두 번째 커넥션을 기다리게 됩니다. 반환되는 커넥션이 없으니 풀 데드락이 되고, connection-timeout인 30초 후 전부 타임아웃으로 실패합니다. HikariCP 문서는 풀 크기 ≥ Tn × (Cm − 1) + 1을 데드락 회피 기준으로 제시하지만, 근본 해결은 REQUIRES_NEW를 최소화하거나 이벤트로 분리해 한 요청이 커넥션 두 개를 잡는 구조를 피하는 것입니다.',
 'interview-question/609.mp3'),
(610, 'SPRING_BOOT', 122, 'EASY', true,
 '스프링 부트의 @Async 기본 실행기를 그대로 사용할 때 어떤 문제가 있고, 전용 실행기는 어떻게 설정해야 하나요?',
 '스프링 부트는 @EnableAsync 시 applicationTaskExecutor 빈을 기본 실행기로 쓰고, 이름을 지정하지 않은 @Async는 모두 여기로 갑니다. 스프링 부트 기본 설정에서 이 실행기는 core 8에 큐가 무제한이라(버전에 따라 다를 수 있음) 작업이 무한히 쌓일 수 있고, 그 결과 지연과 메모리 증가가 발생합니다. 또 ThreadPoolTaskExecutor는 core → 큐 → max 순서로 확장하므로 큐가 무제한이면 max 설정은 사실상 무의미합니다. 그래서 전용 ThreadPoolTaskExecutor 빈을 만들어 queueCapacity로 큐 상한을 두고 CallerRunsPolicy 같은 거부 정책을 지정한 뒤, @Async("mailExecutor")처럼 이름으로 지정해 씁니다. 용도별로 실행기를 분리하면 한 작업의 지연이 다른 작업을 막지 않습니다.',
 'interview-question/610.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 606
(3266, 606, '외부 호출이 끝날 때까지 트랜잭션이 DB 커넥션을 붙잡아 커넥션 풀이 고갈됨을 설명', 'ESSENTIAL', 1),
(3267, 606, '커넥션 풀 고갈이 톰캣 스레드 고갈로 전파되어 무관한 API까지 멈춤을 설명', 'ESSENTIAL', 2),
(3268, 606, '트랜잭션을 DB 작업으로만 좁히고 외부 호출을 트랜잭션 밖으로 빼는 개선을 제시', 'ESSENTIAL', 3),
(3269, 606, '외부 호출에 연결·읽기 타임아웃을 반드시 설정해야 함을 언급', 'ESSENTIAL', 4),
(3270, 606, 'connection-timeout을 수 초 수준으로 낮춰 빠르게 실패시키는 설정을 언급', 'SUPPLEMENTARY', 5),
(3271, 606, '풀 크기를 키우기보다 커넥션 점유 시간을 먼저 줄여야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 607
(3272, 607, '톰캣 스레드는 요청 처리 전 과정 동안 점유됨을 언급', 'ESSENTIAL', 1),
(3273, 607, 'DB 커넥션은 트랜잭션 시작 시 획득해 트랜잭션 종료 시 반환됨을 언급', 'ESSENTIAL', 2),
(3274, 607, '스레드 초과 시 accept-count 큐에서 대기하고 큐도 넘치면 연결이 거부됨을 설명', 'ESSENTIAL', 3),
(3275, 607, '커넥션 초과 시 connection-timeout 동안 대기한 뒤 예외가 발생함을 설명', 'ESSENTIAL', 4),
(3276, 607, '톰캣 기본 최대 스레드 200개와 HikariCP 기본 최대 풀 크기 10을 수치로 제시', 'SUPPLEMENTARY', 5),
(3277, 607, 'DB·외부 API 같은 블로킹 I/O 동안에도 톰캣 스레드가 점유됨을 언급', 'SUPPLEMENTARY', 6),
(3278, 607, '가상 스레드를 켜도 DB 커넥션 풀 한계는 그대로 남음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 608
(3279, 608, '@Async 메서드는 다른 스레드에서 실행되어 호출자 트랜잭션에 참여하지 않음을 설명', 'ESSENTIAL', 1),
(3280, 608, '트랜잭션이 ThreadLocal에 바인딩되어 스레드 경계를 넘지 못함을 언급', 'ESSENTIAL', 2),
(3281, 608, '@TransactionalEventListener(AFTER_COMMIT)와 @Async 조합으로 커밋 이후 실행하는 방법을 제시', 'ESSENTIAL', 3),
(3282, 608, '비동기 메서드 자체에 @Transactional을 두어 독립 트랜잭션으로 설계하는 방법을 제시', 'SUPPLEMENTARY', 4),
(3283, 608, '부모 트랜잭션이 롤백돼도 자식 스레드의 저장은 별도로 커밋되어 원자성이 깨짐을 언급', 'SUPPLEMENTARY', 5),
(3284, 608, '시큐리티 컨텍스트·MDC도 ThreadLocal 기반이라 새 스레드에서 비어 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 609
(3285, 609, '외부 트랜잭션이 커넥션 1개를 보유한 채 내부 REQUIRES_NEW가 커넥션 1개를 더 요청함을 설명', 'ESSENTIAL', 1),
(3286, 609, '모든 요청이 커넥션을 1개씩 잡고 두 번째를 기다려 반환되는 커넥션이 없는 상태를 설명', 'ESSENTIAL', 2),
(3287, 609, '대기하던 요청들이 connection-timeout 후 전부 타임아웃으로 실패함을 언급', 'SUPPLEMENTARY', 3),
(3288, 609, '한 요청이 커넥션 두 개를 잡는 구조를 피하는 것이 근본 해결임을 언급', 'SUPPLEMENTARY', 4),
(3289, 609, 'HikariCP 데드락 회피 기준인 풀 크기 ≥ Tn × (Cm − 1) + 1 공식을 제시', 'SUPPLEMENTARY', 5),

-- 질문 610
(3290, 610, '기본 실행기 applicationTaskExecutor의 큐가 무제한이라 작업이 무한히 쌓임을 언급', 'ESSENTIAL', 1),
(3291, 610, '전용 실행기에 큐 상한과 거부 정책을 지정하는 대응을 제시', 'ESSENTIAL', 2),
(3292, 610, 'ThreadPoolTaskExecutor가 core → 큐 → max 순서로 확장해 무제한 큐에서는 max가 무의미함을 설명', 'SUPPLEMENTARY', 3),
(3293, 610, '용도별 실행기 분리로 한 작업의 지연이 다른 작업을 막지 않게 됨을 언급', 'SUPPLEMENTARY', 4),
(3294, 610, '큐가 무한히 쌓이면 지연과 메모리 증가가 발생함을 언급', 'SUPPLEMENTARY', 5);
