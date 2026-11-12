-- Unit: 트랜잭션 추상화 (Unit ID: 116)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(576, 'SPRING_BOOT', 116, 'HARD', true,
 '서비스 메서드에 @Transactional을 붙였는데도 트랜잭션이 적용되지 않거나, 예외가 났는데 롤백되지 않고 커밋되는 경우가 있습니다. 어떤 원인들이 있고 각각 왜 그런 일이 생기는지 설명해 주시겠어요?',
 '@Transactional은 AOP 프록시가 메서드 호출을 가로채 TransactionInterceptor가 트랜잭션을 시작·커밋·롤백하는 방식이라, 프록시를 거치지 않거나 프록시가 예외를 모르면 기대대로 동작하지 않습니다. 첫째, 같은 클래스 안에서 this.method()로 호출하는 self-invocation은 프록시를 거치지 않으므로 @Transactional이 무시됩니다. 예를 들어 a()에서 b()를 호출할 때 b()에 REQUIRES_NEW를 붙여도 새 트랜잭션은 생기지 않습니다. 둘째, 가시성 문제로 private 메서드에는 어떤 경우에도 적용되지 않고, final 메서드도 적용할 수 없으며, JDK 프록시는 인터페이스 메서드만 지원합니다. 스프링 빈이 아닌 객체도 프록시로 감싸지지 않으니 트랜잭션이 걸리지 않습니다. 셋째, 트랜잭션 자원은 ThreadLocal에 묶이기 때문에 @Async, CompletableFuture, 새 스레드에서 실행되는 코드는 호출자의 트랜잭션에 참여하지 않습니다. 넷째, 롤백 여부는 예외가 프록시까지 전파됐는지로 판단하므로, 메서드 안에서 catch로 예외를 삼키면 프록시는 정상 종료로 보고 커밋합니다. 또 체크 예외는 기본 규칙상 롤백 대상이 아니라 커밋되므로 rollbackFor로 지정해야 합니다.',
 'interview-question/576.mp3'),
(577, 'SPRING_BOOT', 116, 'NORMAL', true,
 '@Transactional 메서드에서 체크 예외가 발생했을 때와 런타임 예외가 발생했을 때 롤백 동작은 어떻게 다른가요?',
 '스프링의 기본 롤백 규칙은 예외 종류에 따라 다릅니다. RuntimeException과 그 하위 예외, 그리고 OutOfMemoryError 같은 Error 계열은 기본적으로 롤백됩니다. 반면 IOException이나 Exception을 상속한 커스텀 예외 같은 체크 예외는 기본적으로 롤백되지 않고 커밋됩니다. 이 규칙은 EJB 관례를 따른 것으로, 체크 예외는 비즈니스적으로 예상된 상황이라 복구 가능하다고 간주하기 때문입니다. 체크 예외에서도 롤백하고 싶다면 @Transactional(rollbackFor = Exception.class)처럼 rollbackFor 속성으로 롤백 대상을 지정할 수 있고, 반대로 런타임 예외를 롤백하지 않으려면 noRollbackFor를 씁니다. 실무에서는 커스텀 예외를 RuntimeException 기반으로 설계해 별도 설정 없이 롤백되게 하는 것이 일반적입니다.',
 'interview-question/577.mp3'),
(578, 'SPRING_BOOT', 116, 'NORMAL', true,
 '트랜잭션 전파 속성 중 REQUIRED와 REQUIRES_NEW는 어떤 차이가 있고, REQUIRES_NEW는 언제 사용하나요?',
 '전파 속성은 이미 트랜잭션이 진행 중일 때 @Transactional 메서드를 호출하면 어떻게 할지를 정합니다. 기본값인 REQUIRED는 기존 트랜잭션이 있으면 거기에 참여해 같은 물리 트랜잭션, 즉 같은 커넥션을 사용하고, 없으면 새로 만듭니다. 그래서 내부 메서드는 논리 트랜잭션일 뿐이고, 내부에서 런타임 예외가 발생하면 외부에서 catch하더라도 트랜잭션이 rollback-only로 표시되어 커밋 시점에 UnexpectedRollbackException이 발생합니다. REQUIRES_NEW는 기존 트랜잭션을 잠시 보류하고 새 물리 트랜잭션을 생성하므로, 별도 커넥션으로 독립적으로 커밋·롤백됩니다. 그래서 본 트랜잭션이 롤백되어도 남아야 하는 실패 이력이나 감사 로그 저장처럼 본 작업과 무관하게 커밋해야 할 때 사용합니다. 다만 REQUIRES_NEW는 커넥션을 하나 더 점유하므로 풀 크기가 작으면 커넥션 고갈이나 데드락의 원인이 될 수 있고, 같은 클래스 내부 호출이면 적용되지 않는다는 점도 주의해야 합니다.',
 'interview-question/578.mp3'),
(579, 'SPRING_BOOT', 116, 'EASY', true,
 '스프링에서 @Transactional 애노테이션은 내부적으로 어떻게 동작하나요?',
 '@Transactional이 붙은 빈은 AOP 프록시로 감싸집니다. 호출자가 메서드를 호출하면 프록시가 받아 TransactionInterceptor에 넘기고, TransactionInterceptor가 트랜잭션 매니저를 통해 트랜잭션을 시작·커밋·롤백합니다. 구체적으로는 전파 속성에 따라 기존 트랜잭션에 참여하거나 새로 만들고, 커넥션을 획득해 autoCommit을 false로 설정한 뒤 원본 메서드를 실행합니다. 예외가 없으면 커밋하고, 롤백 대상 예외가 발생하면 롤백합니다. 이때 커넥션은 트랜잭션 동기화(TransactionSynchronizationManager)로 ThreadLocal에 보관되어, 같은 스레드의 리포지토리가 파라미터로 커넥션을 넘겨받지 않고도 꺼내 씁니다. 트랜잭션 매니저는 PlatformTransactionManager 인터페이스로 JDBC·JPA·JTA 등 기술별 트랜잭션 API를 추상화한 것이라 서비스 코드는 기술과 무관하게 작성할 수 있습니다.',
 'interview-question/579.mp3'),
(580, 'SPRING_BOOT', 116, 'EASY', true,
 '조회 메서드에 @Transactional(readOnly = true)를 붙이면 어떤 효과가 있나요?',
 'readOnly = true는 단순한 표시가 아니라 여러 계층에 최적화 힌트를 전달합니다. 먼저 Hibernate는 플러시 모드를 MANUAL로 바꿔 커밋 시 플러시하지 않고, 변경 감지용 스냅샷 비교·더티 체킹을 생략하므로 메모리와 CPU를 절약합니다. JDBC 드라이버에는 Connection.setReadOnly(true)가 전달되어 DB에 따라 쓰기 방지나 최적화 힌트로 쓰입니다. 또 LazyConnectionDataSourceProxy와 AbstractRoutingDataSource를 함께 쓰면 읽기 복제본(Replica)으로 DB 라우팅을 분기하는 힌트가 됩니다. 주의할 점은 읽기 전용 트랜잭션에서 엔티티를 수정해도 예외 없이 조용히 DB에 반영되지 않는다는 것입니다.',
 'interview-question/580.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 576
(3096, 576, '같은 클래스 내부 호출(self-invocation)은 프록시를 거치지 않아 @Transactional이 무시됨을 설명', 'ESSENTIAL', 1),
(3097, 576, '메서드 안에서 catch로 예외를 삼키면 프록시가 정상 종료로 보고 커밋함을 설명', 'ESSENTIAL', 2),
(3098, 576, 'private·final 메서드, 빈이 아닌 객체, 다른 스레드 중 최소 1개를 트랜잭션 미적용 원인으로 제시', 'ESSENTIAL', 3),
(3099, 576, '체크 예외는 기본 롤백 규칙상 롤백되지 않고 커밋됨을 언급', 'SUPPLEMENTARY', 4),
(3100, 576, '트랜잭션 자원이 ThreadLocal에 묶여 @Async나 새 스레드에서는 호출자의 트랜잭션에 참여하지 않음을 설명', 'SUPPLEMENTARY', 5),
(3101, 576, 'private 메서드에는 어떤 프록시 방식에서도 @Transactional이 적용되지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 577
(3102, 577, 'RuntimeException(런타임 예외)과 그 하위 예외는 기본적으로 롤백됨을 언급', 'ESSENTIAL', 1),
(3103, 577, '체크 예외(Checked Exception)는 기본적으로 롤백되지 않고 커밋됨을 언급', 'ESSENTIAL', 2),
(3104, 577, 'rollbackFor 속성으로 체크 예외도 롤백 대상으로 지정할 수 있음을 언급', 'ESSENTIAL', 3),
(3105, 577, 'Error 계열도 기본적으로 롤백됨을 언급', 'SUPPLEMENTARY', 4),
(3106, 577, '체크 예외를 비즈니스적으로 예상된 복구 가능 상황으로 간주해 커밋함을 언급', 'SUPPLEMENTARY', 5),
(3107, 577, '실무에서는 커스텀 예외를 RuntimeException 기반으로 설계하는 것이 일반적임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 578
(3108, 578, 'REQUIRED는 기존 트랜잭션이 있으면 참여해 같은 물리 트랜잭션을 사용함을 설명', 'ESSENTIAL', 1),
(3109, 578, 'REQUIRES_NEW는 기존 트랜잭션을 보류하고 새 물리 트랜잭션을 생성함을 설명', 'ESSENTIAL', 2),
(3110, 578, '본 트랜잭션이 롤백되어도 남아야 하는 실패 이력·감사 로그를 REQUIRES_NEW 용도로 제시', 'ESSENTIAL', 3),
(3111, 578, 'REQUIRES_NEW는 커넥션을 하나 더 점유해 커넥션 고갈의 원인이 될 수 있음을 언급', 'SUPPLEMENTARY', 4),
(3112, 578, 'REQUIRED 내부 예외를 외부에서 catch해도 rollback-only로 UnexpectedRollbackException이 발생함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 579
(3113, 579, '@Transactional이 붙은 빈이 AOP 프록시로 감싸짐을 언급', 'ESSENTIAL', 1),
(3114, 579, 'TransactionInterceptor가 트랜잭션 매니저로 트랜잭션 시작·커밋·롤백을 수행함을 설명', 'ESSENTIAL', 2),
(3115, 579, '커넥션을 ThreadLocal에 보관해 같은 스레드의 리포지토리가 꺼내 쓰는 트랜잭션 동기화를 설명', 'ESSENTIAL', 3),
(3116, 579, 'PlatformTransactionManager가 JDBC·JPA 등 기술별 트랜잭션 API를 추상화함을 언급', 'SUPPLEMENTARY', 4),
(3117, 579, '원본 메서드 실행 전에 커넥션의 autoCommit을 false로 설정함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 580
(3118, 580, 'Hibernate가 더티 체킹을 생략해 메모리·CPU를 절약함을 언급', 'ESSENTIAL', 1),
(3119, 580, 'readOnly 트랜잭션은 커밋 시 플러시를 하지 않음을 언급', 'ESSENTIAL', 2),
(3120, 580, '읽기 복제본(Replica)으로 DB 라우팅을 분기하는 힌트가 됨을 언급', 'ESSENTIAL', 3),
(3121, 580, 'JDBC 드라이버에 Connection.setReadOnly(true) 힌트가 전달됨을 언급', 'SUPPLEMENTARY', 4),
(3122, 580, '읽기 전용 트랜잭션에서 엔티티를 수정해도 예외 없이 DB에 반영되지 않음을 언급', 'SUPPLEMENTARY', 5),
(3123, 580, 'Hibernate 플러시 모드가 MANUAL로 바뀜을 언급', 'SUPPLEMENTARY', 6);
