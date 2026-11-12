-- Unit: 영속성 컨텍스트 (Unit ID: 117)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(581, 'SPRING_BOOT', 117, 'HARD', true,
 '스프링에서 영속성 컨텍스트는 기본적으로 어떤 범위로 살아 있고, OSIV(spring.jpa.open-in-view)가 켜져 있으면 그 범위가 어떻게 달라지나요? 트래픽이 많은 API 서버에서 이것이 왜 문제가 될 수 있고, OSIV를 끈다면 코드 구조를 어떻게 바꿔야 하나요?',
 '스프링에서 영속성 컨텍스트는 기본적으로 트랜잭션과 생명주기가 같아서, 트랜잭션 시작 시 생성되고 종료 시 닫힙니다. 그런데 스프링 부트의 spring.jpa.open-in-view, 즉 OSIV는 기본값이 true이고, 켜져 있으면 영속성 컨텍스트의 범위를 트랜잭션이 아니라 HTTP 요청 전체, 즉 요청 시작부터 뷰 렌더링과 응답 완료까지로 넓힙니다. 그래서 컨트롤러에서도 지연 로딩이 가능해 편리하지만, 트랜잭션이 끝난 뒤에도 지연 로딩 시 커넥션을 다시 얻고 요청이 끝날 때까지 DB 커넥션을 점유할 수 있습니다. 트래픽이 많은 API 서버에서는 커넥션 효율이 중요하므로 이런 점유가 불리하고, 그래서 OSIV를 끄는 쪽을 검토합니다. OSIV를 끄면 영속성 컨텍스트가 다시 트랜잭션 시작부터 종료까지만 살아 있고 커넥션도 트랜잭션 종료 시 즉시 반환되지만, 컨트롤러에서 지연 로딩을 시도하면 LazyInitializationException이 발생합니다. 따라서 지연 로딩과 DTO 변환을 모두 트랜잭션 안, 즉 서비스 계층에서 끝내야 하고, 흔히 @Transactional(readOnly = true)를 붙인 조회 전용 서비스를 별도로 두는 구조를 씁니다. 반대로 OSIV를 켜 두는 설정은 트래픽이 적은 관리자 화면이나 빠른 개발에 적합하며, 결국 OSIV는 편의와 커넥션 효율 사이의 트레이드오프입니다.',
 'interview-question/581.mp3'),
(582, 'SPRING_BOOT', 117, 'NORMAL', true,
 'JPA에서 flush와 clear는 각각 무엇을 하며 어떻게 다른가요? 대량 저장 시 둘을 함께 호출하는 이유도 말씀해 주세요.',
 'flush는 영속성 컨텍스트의 변경 내용, 즉 쓰기 지연 SQL 저장소에 쌓인 INSERT·UPDATE·DELETE를 DB로 전송해 동기화하는 것이고 커밋이 아닙니다. 그래서 flush 후에도 트랜잭션은 열려 있고 롤백이 가능합니다. flush는 트랜잭션 커밋 직전에 JpaTransactionManager가 자동으로 호출하고, 기본 FlushModeType.AUTO에서는 JPQL 쿼리 실행 전에도 발생하며, em.flush()나 saveAndFlush()로 명시적으로 호출할 수도 있습니다. 반면 clear는 영속성 컨텍스트를 완전히 비워 모든 엔티티를 준영속으로 만듭니다. 1차 캐시가 초기화되므로 이후 조회는 DB에서 새로 읽고, clear 이전에 조회해 둔 엔티티 변수를 계속 수정해도 준영속이라 변경이 반영되지 않습니다. 대량 저장 시에는 persist한 엔티티가 1차 캐시에 계속 쌓이므로, 예를 들어 1000건마다 flush로 쌓인 INSERT를 DB로 보내고 clear로 1차 캐시를 비워 메모리 증가를 방지합니다.',
 'interview-question/582.mp3'),
(583, 'SPRING_BOOT', 117, 'NORMAL', true,
 '같은 트랜잭션 안에서 엔티티를 find()로 조회할 때와 JPQL로 조회할 때, 1차 캐시는 각각 어떻게 동작하나요?',
 '영속성 컨텍스트는 식별자를 키로 엔티티를 담는 Map 형태의 1차 캐시를 가집니다. find()는 먼저 1차 캐시를 조회하고, 없을 때만 SELECT를 실행합니다. 그래서 같은 트랜잭션 안에서 같은 식별자로 두 번 조회하면 두 번째는 SELECT 없이 같은 인스턴스가 반환되어 == 비교가 true가 되고, REPEATABLE READ 수준의 일관성을 애플리케이션 레벨에서 제공합니다. 반면 JPQL은 1차 캐시를 거치지 않고 항상 DB에 질의합니다. 다만 결과를 영속성 컨텍스트에 넣을 때 같은 식별자의 엔티티가 이미 있으면 DB에서 가져온 값을 버리고 기존 인스턴스를 유지합니다. 그래서 동일성은 보장되지만, 다른 트랜잭션이 커밋한 내용이 반영되지 않는 것처럼 보일 수 있습니다. 또 기본 FlushModeType.AUTO에서는 JPQL 실행 전에 flush가 먼저 수행되어 쿼리 결과에 미반영 변경이 빠지지 않도록 합니다.',
 'interview-question/583.mp3'),
(584, 'SPRING_BOOT', 117, 'EASY', true,
 'JPA의 변경 감지(Dirty Checking)는 어떤 방식으로 동작하나요?',
 '변경 감지는 영속 상태 엔티티의 값이 바뀌면 flush 시점에 JPA가 알아서 UPDATE를 만드는 기능이고, 스냅샷 비교로 구현됩니다. 먼저 엔티티를 영속화하거나 조회할 때 그 시점의 값을 스냅샷으로 복사해 1차 캐시에 함께 보관합니다. 이후 비즈니스 로직에서 setter나 도메인 메서드로 필드를 바꾸면, flush 시점에 1차 캐시의 모든 엔티티를 순회하며 현재 값과 스냅샷을 비교합니다. 값이 달라진 엔티티마다 UPDATE 문을 생성해 쓰기 지연 저장소에 넣고 DB로 전송합니다. 그래서 영속 엔티티는 save()를 호출하지 않아도 커밋 시 flush로 갱신됩니다. 기본적으로는 모든 컬럼을 포함한 UPDATE가 나가며, 컬럼이 매우 많으면 @DynamicUpdate로 변경된 컬럼만 포함할 수 있습니다. 변경 감지는 영속 상태와 트랜잭션 안에서만 동작하므로, 준영속 엔티티나 readOnly 트랜잭션에서는 UPDATE가 나가지 않습니다.',
 'interview-question/584.mp3'),
(585, 'SPRING_BOOT', 117, 'EASY', true,
 'JPA 엔티티의 생명주기 상태에는 어떤 것들이 있는지 설명해 주세요.',
 '엔티티 생명주기는 비영속, 영속, 준영속, 삭제의 4가지 상태로 나뉩니다. 비영속은 new Member()처럼 만든 순수 자바 객체로 영속성 컨텍스트와 무관합니다. 영속은 persist()나 find(), JPQL 조회로 들어가며 영속성 컨텍스트가 관리 중인 상태입니다. 4가지 상태 중 변경 감지는 영속 상태에서만 적용되어, 값을 바꾸면 flush 시 UPDATE가 자동 생성됩니다. 준영속은 관리되다가 영속성 컨텍스트에서 분리된 상태로, detach(), clear(), close()나 트랜잭션 종료로 진입하며 식별자는 있지만 이후 변경은 반영되지 않습니다. 삭제는 remove()로 삭제가 예약된 상태이며 flush 시 DELETE가 나갑니다. 참고로 merge()는 넘긴 객체를 영속으로 바꾸는 것이 아니라 DB나 1차 캐시에서 조회한 영속 엔티티에 값을 복사해 그 엔티티를 반환하므로, 반환된 객체가 영속이고 인자로 넘긴 객체는 여전히 준영속으로 남습니다.',
 'interview-question/585.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 581
(3124, 581, '스프링에서 영속성 컨텍스트는 기본적으로 트랜잭션과 생명주기가 같다고 설명', 'ESSENTIAL', 1),
(3125, 581, 'OSIV가 영속성 컨텍스트 범위를 HTTP 요청 전체(응답 완료까지)로 넓힌다고 설명', 'ESSENTIAL', 2),
(3126, 581, 'OSIV가 켜져 있으면 DB 커넥션을 요청 끝까지 점유할 수 있어 트래픽이 많을 때 불리함을 설명', 'ESSENTIAL', 3),
(3127, 581, 'OSIV를 끄면 지연 로딩·DTO 변환을 트랜잭션 안(서비스 계층)에서 끝내야 함을 언급', 'ESSENTIAL', 4),
(3128, 581, 'OSIV를 끄면 컨트롤러에서 지연 로딩 시 LazyInitializationException이 발생함을 언급', 'SUPPLEMENTARY', 5),
(3129, 581, '조회 전용 서비스를 @Transactional(readOnly = true)로 별도로 두는 구조를 제시', 'SUPPLEMENTARY', 6),
(3130, 581, 'OSIV를 켜 두는 쪽은 트래픽 적은 관리자 화면이나 빠른 개발에 적합함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 582
(3131, 582, 'flush는 영속성 컨텍스트의 변경 내용을 DB에 동기화(SQL 전송)하는 것이라고 설명', 'ESSENTIAL', 1),
(3132, 582, 'clear는 영속성 컨텍스트를 비워 모든 엔티티를 준영속으로 만든다고 설명', 'ESSENTIAL', 2),
(3133, 582, '대량 저장 시 flush·clear를 주기적으로 호출해 1차 캐시의 메모리 증가를 방지함을 설명', 'ESSENTIAL', 3),
(3134, 582, '트랜잭션 커밋 직전·JPQL 쿼리 실행 전·em.flush() 호출 중 최소 1개를 flush 발생 시점으로 제시', 'SUPPLEMENTARY', 4),
(3135, 582, 'flush는 커밋이 아니어서 이후에도 롤백이 가능함을 언급', 'SUPPLEMENTARY', 5),
(3136, 582, 'clear 이후 이전에 조회해 둔 엔티티를 수정해도 변경이 반영되지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 583
(3137, 583, 'find()는 1차 캐시를 먼저 조회하고 없을 때만 SELECT를 실행한다고 설명', 'ESSENTIAL', 1),
(3138, 583, 'JPQL은 1차 캐시를 거치지 않고 항상 DB에 질의한다고 설명', 'ESSENTIAL', 2),
(3139, 583, 'JPQL 결과에 같은 식별자의 엔티티가 이미 있으면 DB 값을 버리고 기존 인스턴스를 유지한다고 설명', 'ESSENTIAL', 3),
(3140, 583, '같은 식별자로 두 번 조회하면 같은 인스턴스(== 참조 동일성)가 반환됨을 언급', 'SUPPLEMENTARY', 4),
(3141, 583, '기존 인스턴스 유지 때문에 다른 트랜잭션의 커밋 내용이 반영되지 않는 것처럼 보일 수 있음을 언급', 'SUPPLEMENTARY', 5),
(3142, 583, 'FlushModeType.AUTO에서는 JPQL 실행 전에 flush가 먼저 수행됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 584
(3143, 584, '엔티티를 영속화(조회)할 때 그 시점의 값을 스냅샷으로 1차 캐시에 함께 보관한다고 설명', 'ESSENTIAL', 1),
(3144, 584, 'flush 시점에 1차 캐시 엔티티의 현재 값과 스냅샷을 비교', 'ESSENTIAL', 2),
(3145, 584, '값이 달라진 엔티티마다 UPDATE 문이 자동으로 생성된다고 설명', 'ESSENTIAL', 3),
(3146, 584, '영속 엔티티는 save() 호출 없이도 변경 감지로 갱신된다고 언급', 'SUPPLEMENTARY', 4),
(3147, 584, '준영속 엔티티나 readOnly 트랜잭션에서는 변경 감지로 UPDATE가 나가지 않음을 언급', 'SUPPLEMENTARY', 5),
(3148, 584, '기본적으로 모든 컬럼을 포함한 UPDATE가 나가고 @DynamicUpdate로 변경 컬럼만 포함할 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 585
(3149, 585, '비영속·영속·준영속·삭제의 4가지 상태를 이름으로 제시', 'ESSENTIAL', 1),
(3150, 585, '영속 상태는 영속성 컨텍스트가 관리 중인 상태라고 설명', 'ESSENTIAL', 2),
(3151, 585, '준영속은 관리되다가 영속성 컨텍스트에서 분리된 상태라고 설명', 'ESSENTIAL', 3),
(3152, 585, '4가지 상태 중 변경 감지는 영속 상태에서만 적용된다고 언급', 'SUPPLEMENTARY', 4),
(3153, 585, 'detach()·clear()·close()·트랜잭션 종료 중 최소 1개를 준영속 진입 방법으로 제시', 'SUPPLEMENTARY', 5),
(3154, 585, 'merge()의 인자로 넘긴 객체는 여전히 준영속으로 남는다고 언급', 'SUPPLEMENTARY', 6);
