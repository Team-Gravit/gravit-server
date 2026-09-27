-- Unit: JPA 쓰기와 식별자 전략 (Unit ID: 119)
-- Chapter: Spring (Chapter ID: 10)
-- Topic: SPRING_BOOT
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-spring-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(591, 'SPRING_BOOT', 119, 'HARD', true,
 '같은 트랜잭션에서 회원을 조회한 뒤 @Modifying JPQL 벌크 update로 나이를 올렸더니, 다시 조회해도 갱신 전 값이 나왔습니다. 원인과 해결 방법, 그리고 그 해결 방법의 한계는 무엇인가요?',
 'JPQL의 update/delete 같은 벌크 연산은 영속성 컨텍스트를 거치지 않고 DB에 바로 실행됩니다. 그래서 벌크 연산 전에 조회해 1차 캐시에 올라와 있던 회원 엔티티는 벌크 연산 결과를 모르고, DB에는 age가 21로 바뀌었어도 1차 캐시에는 여전히 20이 남아 있습니다. 이후 findById로 다시 조회해도 1차 캐시에서 반환되기 때문에 갱신 전 값이 나오는 것입니다. 해결 방법은 @Modifying(clearAutomatically = true)를 지정해 벌크 실행 후 em.clear()로 영속성 컨텍스트를 비우는 것입니다. 그러면 이후 조회는 DB에서 새로 읽습니다. 또 flushAutomatically = true를 함께 쓰면 벌크 실행 전에 em.flush()를 호출해, 아직 DB에 나가지 않은 변경이 벌크 연산에 덮이거나 누락되는 것을 막을 수 있습니다. 다만 한계도 있습니다. clear 이후에는 이전에 조회해 둔 엔티티 변수가 준영속이 되므로 그 객체를 수정해도 반영되지 않습니다. 그리고 벌크 연산에는 엔티티 생명주기 콜백, @Version 증가, Cascade가 적용되지 않으므로, 이런 부가 동작이 필요하면 엔티티를 조회해 변경 감지로 처리해야 합니다.'),
(592, 'SPRING_BOOT', 119, 'NORMAL', true,
 'JPA 식별자 생성 전략 중 IDENTITY와 SEQUENCE는 어떤 차이가 있으며, 그 차이가 배치 INSERT에 어떤 영향을 주나요?',
 'IDENTITY는 ID 생성을 DB의 AUTO_INCREMENT에 위임하는 전략이고, SEQUENCE는 DB 시퀀스에서 ID를 미리 받아오는 전략입니다. 핵심 차이는 INSERT 시점입니다. IDENTITY는 persist()를 호출하는 즉시 INSERT를 실행하고, SEQUENCE는 쓰기 지연을 유지해 flush 시점에 INSERT합니다. 그래서 배치 INSERT 가능 여부가 갈립니다. IDENTITY는 쓰기 지연이 깨져 JDBC 배치로 묶을 수 없고, SEQUENCE는 배치 INSERT가 가능합니다. IDENTITY가 즉시 INSERT해야 하는 이유는 영속성 컨텍스트가 ID를 키로 엔티티를 관리하므로 persist 시점에 ID가 필요한데, IDENTITY는 INSERT를 실행해야만 ID를 얻을 수 있기 때문입니다. SEQUENCE는 allocationSize(기본 50)만큼 ID 범위를 한 번에 받아 메모리에서 배분해 DB 왕복을 줄입니다. 대량 INSERT가 필요한 MySQL 환경에서는 IDENTITY 대신 JDBC batchUpdate나 UUID·직접 채번을 검토합니다.'),
(593, 'SPRING_BOOT', 119, 'NORMAL', true,
 'CascadeType.REMOVE와 orphanRemoval=true는 어떻게 다르며, CascadeType.ALL과 orphanRemoval을 함께 쓰는 것은 어떤 경우에 적절한가요?',
 'CascadeType.REMOVE는 부모 엔티티에 대한 remove() 작업을 자식에게 전파하는 옵션으로, 부모를 삭제할 때 자식도 함께 삭제합니다. 반면 orphanRemoval=true는 Cascade와 별개 옵션으로, 부모의 컬렉션에서 제거되어 참조가 끊긴 자식을 DELETE합니다. 예를 들어 주문의 orderItems 리스트에서 주문상품을 remove하면 flush 시 해당 order_item이 DELETE됩니다. 즉 REMOVE는 부모 삭제 시, orphanRemoval은 참조가 끊길 때 동작합니다. CascadeType.ALL과 orphanRemoval의 조합은 부모가 자식의 생명주기를 완전히 소유할 때, 즉 주문-주문상품처럼 자식이 부모 없이는 의미가 없을 때만 사용합니다. 이 조합은 사실상 부모가 자식의 리포지토리 역할을 하는 것으로, DDD의 애그리거트 개념과 같습니다. 반대로 자식이 여러 부모에서 공유되거나 독립적인 생명주기를 가지면 Cascade를 쓰지 않습니다. 또 REMOVE와 orphanRemoval은 자식을 하나씩 조회해 DELETE하므로 대량 삭제 시 성능에 주의해야 하고, Cascade를 걸어도 자식의 FK를 세팅하지 않으면 FK가 null인 채 INSERT되므로 양방향 편의 메서드로 양쪽을 모두 연결해야 합니다.'),
(594, 'SPRING_BOOT', 119, 'EASY', true,
 'Spring Data JPA의 save()는 내부적으로 어떻게 동작하며, ID를 직접 할당한 엔티티를 save()하면 어떤 일이 생기나요?',
 'Spring Data JPA의 SimpleJpaRepository.save()는 엔티티가 새 것인지 isNew로 판단해서, 새 엔티티이면 em.persist()를, 아니면 em.merge()를 호출합니다. persist는 쓰기 지연으로 INSERT를 수행하고, merge는 SELECT 후 INSERT 또는 UPDATE를 수행합니다. 기본 판단 기준은 @Id 필드가 null(참조형)이거나 0(기본형)이면 새 엔티티로 보는 것이고, @Version 필드가 null이어도 새 엔티티로 판단합니다. 그래서 UUID나 문자열 ID처럼 ID를 직접 할당하면 기존 엔티티로 간주되어 merge로 동작하고, 불필요한 SELECT가 1회 추가됩니다. 이를 해결하려면 엔티티가 Persistable 인터페이스를 구현하고 isNew()를 직접 정의해, 예를 들어 createdAt이 null이면 새 엔티티로 보고 persist로 유도할 수 있습니다.'),
(595, 'SPRING_BOOT', 119, 'EASY', true,
 'JPA에서 배치 INSERT가 실제로 동작하게 하려면 어떤 설정이 필요한지 설명해 주세요.',
 'JPA의 배치 INSERT는 쓰기 지연 저장소에 쌓인 SQL을 flush 시 JDBC addBatch()로 묶어 전송하는 방식입니다. 이를 위해 먼저 spring.jpa.properties.hibernate.jdbc.batch_size로 JDBC 배치 크기를, 예를 들어 100으로 지정합니다. 그리고 order_inserts: true를 설정해 같은 테이블에 대한 INSERT를 모아 배치 효율을 높이고, UPDATE도 order_updates로 같은 효과를 줄 수 있습니다. MySQL을 쓴다면 datasource URL에 rewriteBatchedStatements=true를 추가해야 합니다. 이 옵션이 없으면 드라이버가 배치를 받아도 한 건씩 전송하므로 효과가 없고, 이 옵션이 있으면 여러 INSERT를 다중 VALUES로 재작성합니다. 또 대량 삽입 루프에서는 batch_size 단위로 flush()와 clear()를 호출해 1차 캐시 메모리를 정리합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 591
(3180, 591, 'JPQL 벌크 연산은 영속성 컨텍스트를 거치지 않고 DB에 바로 실행됨을 언급', 'ESSENTIAL', 1),
(3181, 591, '1차 캐시에 남은 엔티티가 벌크 결과를 모른 채 이전 값을 반환한다는 원인을 설명', 'ESSENTIAL', 2),
(3182, 591, '@Modifying의 clearAutomatically = true로 벌크 실행 후 영속성 컨텍스트를 비우는 해결책을 제시', 'ESSENTIAL', 3),
(3183, 591, 'clear 이후 이전에 조회해 둔 엔티티 변수는 준영속이 되어 수정해도 반영되지 않음을 언급', 'ESSENTIAL', 4),
(3184, 591, 'flushAutomatically = true로 벌크 실행 전 미반영 변경을 먼저 flush함을 언급', 'SUPPLEMENTARY', 5),
(3185, 591, '벌크 연산에는 생명주기 콜백·@Version 증가·Cascade가 적용되지 않음을 언급', 'SUPPLEMENTARY', 6),
(3186, 591, '부가 동작이 필요하면 엔티티를 조회해 변경 감지로 처리해야 함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 592
(3187, 592, 'IDENTITY는 persist() 즉시 INSERT하고 SEQUENCE는 flush 시 INSERT한다는 차이를 설명', 'ESSENTIAL', 1),
(3188, 592, 'IDENTITY는 JDBC 배치 INSERT가 불가능하고 SEQUENCE는 가능함을 언급', 'ESSENTIAL', 2),
(3189, 592, '영속성 컨텍스트가 ID를 키로 엔티티를 관리해 persist 시점에 ID가 필요하다는 이유를 설명', 'SUPPLEMENTARY', 3),
(3190, 592, 'SEQUENCE는 allocationSize만큼 ID를 미리 받아 DB 왕복을 줄임을 언급', 'SUPPLEMENTARY', 4),
(3191, 592, '대량 INSERT가 필요한 MySQL에서 JDBC batchUpdate·UUID·직접 채번 중 최소 1개를 대안으로 제시', 'SUPPLEMENTARY', 5),

-- 질문 593
(3192, 593, 'CascadeType.REMOVE는 부모 엔티티를 삭제할 때 자식도 함께 삭제함을 언급', 'ESSENTIAL', 1),
(3193, 593, 'orphanRemoval은 부모 컬렉션에서 제거되어 참조가 끊긴 자식을 DELETE함을 언급', 'ESSENTIAL', 2),
(3194, 593, '부모가 자식의 생명주기를 완전히 소유할 때(자식이 부모 없이 의미 없을 때)만 ALL과 orphanRemoval을 쓴다고 설명', 'ESSENTIAL', 3),
(3195, 593, '자식이 여러 부모에서 공유되거나 독립적인 생명주기를 가지면 Cascade를 쓰지 않음을 언급', 'SUPPLEMENTARY', 4),
(3196, 593, 'REMOVE·orphanRemoval은 자식을 하나씩 조회해 DELETE하므로 대량 삭제 시 성능 주의가 필요함을 언급', 'SUPPLEMENTARY', 5),
(3197, 593, 'Cascade를 써도 자식의 FK를 세팅하지 않으면 FK가 null인 채 INSERT됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 594
(3198, 594, 'save()는 엔티티의 isNew 판단 결과에 따라 persist() 또는 merge()를 호출함을 설명', 'ESSENTIAL', 1),
(3199, 594, '@Id 필드가 null(참조형) 또는 0(기본형)이면 새 엔티티로 판단함을 언급', 'ESSENTIAL', 2),
(3200, 594, 'ID를 직접 할당하면 merge로 동작해 SELECT가 1회 추가됨을 언급', 'ESSENTIAL', 3),
(3201, 594, 'Persistable 인터페이스의 isNew()를 구현해 persist로 유도하는 해결책을 제시', 'SUPPLEMENTARY', 4),
(3202, 594, '@Version 필드가 null인 경우에도 새 엔티티로 판단함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 595
(3203, 595, 'hibernate.jdbc.batch_size로 JDBC 배치 크기를 지정함을 언급', 'ESSENTIAL', 1),
(3204, 595, 'order_inserts로 같은 테이블의 INSERT를 모아 배치 효율을 높임을 언급', 'ESSENTIAL', 2),
(3205, 595, 'MySQL은 rewriteBatchedStatements=true가 없으면 한 건씩 전송되어 배치 효과가 없음을 설명', 'ESSENTIAL', 3),
(3206, 595, '쓰기 지연 저장소의 SQL을 flush 시 JDBC addBatch()로 묶어 전송함을 언급', 'SUPPLEMENTARY', 4),
(3207, 595, '대량 삽입 루프에서 batch_size 단위로 flush()와 clear()를 호출해 1차 캐시 메모리를 정리함을 언급', 'SUPPLEMENTARY', 5);
