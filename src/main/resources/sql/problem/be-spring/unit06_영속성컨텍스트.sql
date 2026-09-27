-- Unit: 영속성 컨텍스트 (Unit ID: 117)
-- Chapter: Spring (Chapter ID: 10)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (543, 117, '1차 캐시와 변경 감지, 준영속 상태'),
       (701, 117, '트랜잭션별 컨텍스트 범위와 OSIV'),
       (859, 117, '플러시 모드와 쓰기 지연');

-- =====================================================
-- Lesson 543: 1차 캐시와 변경 감지, 준영속 상태
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3437, 543, '아래 코드를 실행하고 트랜잭션을 커밋했을 때 일어나는 일로 옳은 것은?', 'DB에는 id=1, name=kim, email=kim@example.com 인 회원 한 건이 저장돼 있다. 이 상태에서 update(1L)을 호출한다.

```java
@Transactional
public void update(Long id) {
    Member param = new Member();
    param.setId(id);
    param.setName("lee");
    param.setEmail(null);          // email은 채우지 않음

    Member returned = em.merge(param);
    returned.setName("park");
    param.setName("choi");
}
```', 'OBJECTIVE'),
       (3438, 543, '아래 코드를 한 트랜잭션 안에서 실행할 때 일어나는 일로 옳은 것은?', '같은 식별자의 회원을 한 트랜잭션 안에서 세 번 가져온다. 2차 캐시는 쓰지 않는다.

```java
@Transactional
public void load(Long id) {
    Member a = em.find(Member.class, id);
    Member b = em.find(Member.class, id);
    Member c = em.createQuery("select m from Member m where m.id = :id", Member.class)
                 .setParameter("id", id)
                 .getSingleResult();
}
```', 'OBJECTIVE'),
       (3439, 543, '아래 코드에서 (A) 지점까지 데이터베이스로 나가는 SQL에 대한 설명으로 옳은 것은?', '식별자 생성 전략은 SEQUENCE이고 FlushModeType은 기본값 AUTO다. 조회된 회원의 name은 kim이다.

```java
@Transactional
public void process(Long id) {
    Member m = em.find(Member.class, id);
    m.setName("lee");
    em.persist(new Member("park"));

    List<Member> all = em.createQuery("select m from Member m", Member.class)
                         .getResultList();   // (A)
    m.setName("choi");
}
```', 'OBJECTIVE'),
       (3440, 543, '아래는 영속성 컨텍스트의 범위를 정하는 스프링 부트 설정의 두 값을 비교한 표다. 표를 바탕으로 옳지 않은 것은?', '| 항목 | 설정 A | 설정 B |
| --- | --- | --- |
| 영속성 컨텍스트 범위 | 요청 시작 ~ 응답 완료 | 트랜잭션 시작 ~ 종료 |
| 컨트롤러에서 지연 로딩 | 가능 | LazyInitializationException 발생 |
| DB 커넥션 | 트랜잭션 종료 뒤에도 필요하면 다시 확보해 요청 끝까지 유지될 수 있음 | 트랜잭션 종료 시 즉시 반환 |
| 스프링 부트 기본값 | 이 값이 기본 | 직접 꺼야 적용 |', 'OBJECTIVE'),
       (3441, 543, '아래 두 실행의 차이를 만드는 JPA 기능의 이름은?', '아래 메서드는 저장 메서드를 한 번도 부르지 않는데 커밋 시점에 UPDATE가 실행된다.

```java
@Transactional
public void rename(Long id, String name) {
    Member member = memberRepository.findById(id).orElseThrow();
    member.changeName(name);
}
```

실행 로그

```
select member0_.id, member0_.name, member0_.email from member member0_ where member0_.id=?
update member set email=?, name=? where id=?
```

그런데 메서드에 붙은 애너테이션만 @Transactional(readOnly = true)로 바꾸면, 같은 코드에서 update 로그가 사라진다.', 'SUBJECTIVE'),
       (3442, 543, '아래에서 admin 객체가 놓인 엔티티 상태를 가리키는 용어는?', '회원 10만 건을 한 트랜잭션에서 저장하는 배치가 메모리 부족으로 죽어, 1,000건마다 em.flush()와 em.clear()를 부르도록 고쳤다. 메모리 문제는 사라졌지만 아래 표시한 곳에서 예상과 다르게 동작했다. admin.getId()는 끝까지 1을 반환했다.

```java
@Transactional
public void bulkInsert(List<Member> members) {
    Member admin = em.find(Member.class, 1L);   // 반복문 전에 조회

    for (int i = 0; i < members.size(); i++) {
        em.persist(members.get(i));
        if (i % 1000 == 0) {
            em.flush();
            em.clear();
        }
    }

    admin.setName("관리자");    // 커밋 후에도 DB의 이름은 그대로였다
    em.find(Member.class, 1L);  // 이 호출에서 SELECT가 다시 나갔다
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3437
(9339, 3437, 'param이 merge 호출로 영속 상태가 되어 마지막에 넣은 choi가 커밋 시 반영된다.', 'merge는 인자로 넘긴 객체를 관리 대상으로 바꾸지 않는다. 값을 복사받은 반환 객체만 영속이므로, param에 넣은 choi는 어디에도 반영되지 않는다.', false),
(9340, 3437, '커밋 직전 UPDATE가 나가 name은 park이 되고 email 컬럼은 null로 덮어써진다.', 'merge가 조회해 온 영속 엔티티에 param의 값이 복사되어 email이 null이 되고, 반환 객체에 넣은 park이 변경 감지로 UPDATE에 실린다.', true),
(9341, 3437, 'merge는 1차 캐시만 확인하므로 SELECT 없이 UPDATE 한 건만 실행된다.', '1차 캐시에 그 식별자의 엔티티가 없으면 merge는 DB에서 조회한다. 이 트랜잭션은 아직 아무것도 읽지 않았으므로 SELECT가 먼저 나간다.', false),
(9342, 3437, 'merge는 null이 아닌 필드만 복사하므로 email에는 기존 값이 그대로 남는다.', 'merge는 넘긴 객체의 필드를 그대로 복사하며 null도 예외가 아니다. 일부 필드만 바꾸려고 쓰면 나머지 값이 지워지는 이유가 이것이다.', false),

-- 문제 3438
(9343, 3438, '세 번 모두 같은 저장소에서 읽으므로 조회 SQL은 한 번만 실행된다.', 'find 두 번은 1차 캐시로 해결되지만 JPQL은 캐시를 거치지 않고 항상 DB에 질의한다. 그래서 조회가 한 번으로 끝나지 않는다.', false),
(9344, 3438, 'JPQL이 가져온 값이 1차 캐시를 덮어써서 c만 다른 인스턴스를 가리킨다.', '같은 식별자의 엔티티가 이미 있으면 JPQL이 가져온 값을 버리고 기존 인스턴스를 유지한다. 덮어쓰지 않으므로 c도 같은 객체다.', false),
(9345, 3438, 'b는 캐시에서 꺼낸 복사본이라 a와 다른 객체이고 조회 SQL은 세 번 실행된다.', '1차 캐시는 복사본이 아니라 보관 중인 인스턴스 자체를 돌려준다. 그래서 a와 b는 같은 객체이고 두 번째 find는 SQL을 만들지 않는다.', false),
(9346, 3438, 'a, b, c가 모두 같은 인스턴스를 가리키고 조회 SQL은 두 번 실행된다.', '첫 find에서 한 번, JPQL에서 한 번 조회가 나간다. JPQL 결과는 이미 캐시에 있던 인스턴스로 대체되므로 참조 동일성이 유지된다.', true),

-- 문제 3439
(9347, 3439, '조회 쿼리가 실행되기 직전에 flush가 일어나 UPDATE와 INSERT가 먼저 전송된다.', 'AUTO 모드는 쿼리 결과에서 미반영 변경이 빠지지 않도록 JPQL 실행 전 flush를 건다. 쓰기 지연 저장소의 INSERT와 변경 감지로 만들어진 UPDATE가 이때 나간다.', true),
(9348, 3439, '쓰기 지연 저장소의 SQL은 커밋 때만 전송되므로 (A)까지는 조회 쿼리만 나간다.', '쓰기 지연은 전송을 미루는 것이지 커밋까지 무조건 붙잡아 두는 것이 아니다. JPQL 실행 전이나 명시적 호출로도 flush가 일어난다.', false),
(9349, 3439, 'flush가 일어날 때 트랜잭션도 함께 커밋되어 그 이전 변경은 롤백할 수 없다.', 'flush는 변경 내용을 DB로 동기화할 뿐 커밋이 아니다. flush 뒤에도 트랜잭션은 열려 있어 롤백하면 이미 전송된 SQL의 결과까지 취소된다.', false),
(9350, 3439, 'persist에서 INSERT가 즉시 나가고 UPDATE는 저장 호출이 없어 끝까지 나가지 않는다.', 'SEQUENCE 전략은 식별자만 미리 받고 INSERT는 flush까지 미룬다. 영속 상태 엔티티의 변경은 저장 호출 없이도 변경 감지로 UPDATE가 만들어진다.', false),

-- 문제 3440
(9351, 3440, '설정 A에서는 트랜잭션이 끝난 뒤 컨트롤러에서 지연 로딩이 되고, 그만큼 커넥션을 오래 쥔다.', '컨텍스트가 응답 완료까지 살아 있어 프록시 초기화가 가능하고, 그 초기화를 위해 커넥션을 다시 확보해 요청이 끝날 때까지 붙잡는다. 표의 두 행에서 도출된다.', false),
(9352, 3440, '설정 B로 바꾸면 지연 로딩과 DTO 변환을 서비스 계층의 트랜잭션 안에서 끝내야 한다.', '트랜잭션이 끝나는 순간 컨텍스트가 닫혀 컨트롤러의 지연 로딩이 예외로 이어진다. 그래서 필요한 데이터를 트랜잭션 안에서 미리 로딩하거나 DTO로 옮겨 둔다.', false),
(9353, 3440, '설정 B가 기본값이라 아무 설정도 하지 않으면 컨트롤러의 지연 로딩에서 예외가 난다.', '표의 마지막 행에서 기본값은 설정 A다. 손대지 않은 스프링 부트는 요청 범위로 컨텍스트를 열어 두므로 컨트롤러의 지연 로딩도 예외 없이 동작한다.', true),
(9354, 3440, '동시 요청이 많은 API 서버에서는 설정 B가 커넥션 회전율 면에서 유리하다.', '커넥션을 트랜잭션 종료 즉시 반환하니 같은 크기의 풀로 더 많은 요청을 받는다. 요청 끝까지 쥐고 있는 설정 A는 트래픽이 몰릴 때 풀 고갈에 취약하다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1102, 3441, '변경 감지,변경감지,더티 체킹,더티체킹,dirty checking,dirtychecking,dirty check', '영속 상태 엔티티는 조회 시점의 값이 스냅샷으로 함께 보관되고, flush 때 현재 값과 스냅샷을 비교해 달라진 엔티티마다 UPDATE가 만들어진다. 로그의 UPDATE가 바꾸지 않은 email까지 담고 있는 것도 SQL을 재사용하려고 모든 컬럼을 넣는 기본 전략 때문이다. readOnly = true는 스냅샷 보관과 비교를 생략하므로 같은 코드에서 UPDATE가 사라진다. 만들어진 SQL을 모아 두었다가 한 번에 내보내는 쓰기 지연은 그다음 단계이고, 준영속 엔티티는 아예 비교 대상이 아니라는 점을 구분한다.'),
       (1103, 3442, '준영속,준영속 상태,준영속상태,detached,detached 상태,분리 상태,디태치드', 'em.clear()가 컨텍스트를 통째로 비우면서 admin은 관리 대상에서 빠졌다. 관리 대상이 아니므로 이후의 setName은 변경 감지에 잡히지 않고, 1차 캐시도 초기화되어 같은 식별자를 다시 find하면 SELECT가 새로 나간다. 식별자조차 없는 순수 자바 객체인 비영속과 달리 이 상태는 식별자를 그대로 갖고 있어, merge에 넘기면 값이 복사된 영속 엔티티를 돌려받을 수 있다. detach와 close, 트랜잭션 종료로도 같은 상태가 된다.');

-- =====================================================
-- Lesson 701: 트랜잭션별 컨텍스트 범위와 OSIV
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4385, 701, '아래 표의 t3 시점에 스레드 T2에서 일어나는 일로 옳은 것은?', 'MemberRepository는 싱글톤 빈이며, EntityManager를 필드로 주입받아 조회에 사용한다. DB에 저장된 id=1 회원의 name은 kim이고, 2차 캐시는 쓰지 않는다.

```java
@Repository
public class MemberRepository {

    @PersistenceContext
    private EntityManager em;

    public Member findById(Long id) {
        return em.find(Member.class, id);
    }
}
```

서로 다른 HTTP 요청을 처리하는 스레드 T1·T2가 각자 @Transactional 서비스 메서드 안에서 이 리포지토리를 사용한다. 시간 순서는 아래와 같다.

| 시점 | 스레드 T1 | 스레드 T2 |
| --- | --- | --- |
| t1 | 트랜잭션 시작, findById(1L) 호출 | |
| t2 | 받은 회원의 name을 lee로 변경 | |
| t3 | | 트랜잭션 시작, findById(1L) 호출 |
| t4 | 커밋 | |', 'OBJECTIVE'),
       (4386, 701, '아래 두 메서드를 각각 실행했을 때 회원 조회 SELECT 횟수와 출력값으로 옳은 것은?', 'MemberReader의 두 메서드는 웹 요청이 아니라 다른 빈의 스케줄러 메서드에서 각각 호출된다. memberRepository는 Spring Data JPA 리포지토리이고, DB에는 id=1 회원이 있으며 2차 캐시는 쓰지 않는다.

```java
@Service
@RequiredArgsConstructor
public class MemberReader {

    private final MemberRepository memberRepository;

    @Transactional
    public void withTx() {
        Member a = memberRepository.findById(1L).orElseThrow();
        Member b = memberRepository.findById(1L).orElseThrow();
        System.out.println(a == b);
    }

    public void withoutTx() {   // @Transactional 없음
        Member a = memberRepository.findById(1L).orElseThrow();
        Member b = memberRepository.findById(1L).orElseThrow();
        System.out.println(a == b);
    }
}
```', 'OBJECTIVE'),
       (4387, 701, '아래 코드를 실행하고 커밋할 때 DB로 나가는 UPDATE에 대한 설명으로 옳은 것은?', 'Member 엔티티는 id, name, grade, email 컬럼에 매핑되며 @DynamicUpdate는 붙어 있지 않다. 실행 전 DB 상태는 아래와 같다.

| id | name | grade | email |
| --- | --- | --- | --- |
| 1 | kim | SILVER | kim@example.com |
| 2 | park | SILVER | park@example.com |

```java
@Transactional
public void adjust() {
    Member m1 = em.find(Member.class, 1L);
    Member m2 = em.find(Member.class, 2L);

    m1.setName("lee");
    m1.setName("kim");

    m2.setGrade(Grade.GOLD);
}
```', 'OBJECTIVE'),
       (4388, 701, '아래 코드의 (A)~(D) 각 줄을 실행한 직후, 그 줄에서 다루는 회원 객체의 상태를 순서대로 나열한 것은?', 'spring.jpa.open-in-view는 false로 설정했다. 컨트롤러에는 @Transactional이 없고, 서비스의 두 메서드를 차례로 호출한다.

```java
@Service
public class MemberService {

    @PersistenceContext
    private EntityManager em;

    @Transactional
    public Member register(String name) {
        Member member = new Member(name);    // (A)
        em.persist(member);                  // (B)
        return member;
    }

    @Transactional
    public void withdraw(Long id) {
        Member member = em.find(Member.class, id);
        em.remove(member);                   // (D)
    }
}

@RestController
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @PostMapping("/members/trial")
    public void trial() {
        Member joined = memberService.register("kim");   // (C)
        memberService.withdraw(joined.getId());
    }
}
```', 'OBJECTIVE'),
       (4389, 701, '아래 테스트에 추가한 한 줄이 일으킨 JPA 동작의 이름은?', 'member 테이블의 email 컬럼에는 UNIQUE 제약이 있고, 식별자 전략은 SEQUENCE다. 아래 테스트는 중복 이메일을 저장할 때 예외가 나기를 기대했지만, 예외 없이 끝나 실패했다.

```java
@SpringBootTest
@Transactional
class MemberRepositoryTest {

    @Autowired
    MemberRepository memberRepository;

    @Test
    void duplicateEmail() {
        memberRepository.save(new Member("a@test.com"));

        assertThrows(DataIntegrityViolationException.class, () -> {
            memberRepository.save(new Member("a@test.com"));
        });
    }
}
```

- 실패했을 때의 SQL 로그: 시퀀스 값을 가져오는 조회만 있고 INSERT는 한 줄도 없다.
- 두 번째 save 바로 아래에 memberRepository의 메서드 호출 한 줄을 추가하자, 첫 번째 INSERT가 실행되고 이어진 두 번째 INSERT에서 DataIntegrityViolationException이 발생해 테스트가 통과했다.
- 테스트가 끝난 뒤 DB를 확인하니 a@test.com 행은 하나도 남아 있지 않았다.', 'SUBJECTIVE'),
       (4390, 701, '아래 상황에서 개발자가 false로 바꾼 스프링 부트 설정이 켜 두던 기능의 이름은?', '주문 조회 API다. 서비스 메서드에만 @Transactional(readOnly = true)가 붙어 있고, Order의 member 연관관계는 지연 로딩이다.

```java
@GetMapping("/orders/{id}")
public OrderResponse getOrder(@PathVariable Long id) {
    Order order = orderService.findOrder(id);           // 서비스 트랜잭션은 여기서 끝남
    DeliveryStatus status = deliveryClient.fetch(id);   // 외부 배송 API, 평균 2초
    return new OrderResponse(order.getMember().getName(), status);
}
```

- 조치 전: 트래픽이 몰리자 `HikariPool-1 - Connection is not available, request timed out after 30000ms` 로그가 쌓였다. 확인해 보니 커넥션 대부분이 외부 배송 API의 응답을 기다리는 요청에 붙잡혀 있었다.
- 조치: application.yml에 설정 한 줄을 추가해 false로 지정했다.
- 조치 후: 커넥션 대기 오류는 사라졌지만, 이번에는 `order.getMember().getName()`에서 `LazyInitializationException: could not initialize proxy - no Session`이 발생했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4385
(11867, 4385, '두 스레드가 필드의 em 하나를 함께 쓰므로 T1의 1차 캐시에서 name이 lee인 인스턴스를 받는다.', '필드에 주입된 것은 실제 EntityManager가 아니라 공유 프록시다. 호출될 때마다 그 스레드에 묶인 진짜 EntityManager를 찾아 넘기므로 T1의 1차 캐시는 T2에 보이지 않는다.', false),
(11868, 4385, 'em 호출이 T2에 묶인 EntityManager로 넘겨져 SELECT가 새로 나가고, name이 kim인 다른 인스턴스를 받는다.', '주입된 em은 공유 프록시라 T2의 호출을 T2에 묶인 EntityManager로 넘긴다. 그 영속성 컨텍스트의 1차 캐시는 비어 있어 SELECT가 나가고, T1의 변경은 아직 flush 전이라 DB에는 kim이 그대로 있다.', true),
(11869, 4385, 'T1이 같은 em을 쓰는 중이라 t4의 커밋이 끝날 때까지 기다린 뒤 name이 lee인 회원을 받는다.', '실제 EntityManager는 스레드마다 따로 쓰이므로 하나를 두고 잠그며 기다리는 구조가 아니다. 공유 프록시는 호출을 각 스레드의 EntityManager로 넘길 뿐이라 T2는 t3에 곧바로 조회한다.', false),
(11870, 4385, '1차 캐시는 애플리케이션 전체가 공유하므로 SELECT 없이 T1이 조회할 때 떠 둔 스냅샷(kim)을 받는다.', '1차 캐시는 영속성 컨텍스트 하나에 속해 그 범위 안에서만 쓰인다. 여러 요청이 나눠 쓰는 캐시는 2차 캐시나 Redis 같은 별도 캐시의 몫이고, 스냅샷은 변경 감지용 사본이지 조회 결과로 주는 값이 아니다.', false),

-- 문제 4386
(11871, 4386, 'withTx는 SELECT 1회·true, withoutTx는 SELECT 2회·false', 'withTx의 두 조회는 한 트랜잭션의 영속성 컨텍스트를 함께 써서 두 번째 조회가 1차 캐시의 같은 인스턴스를 받는다. withoutTx는 조회마다 컨텍스트가 새로 열리고 닫혀 SELECT가 두 번 나가고 서로 다른 객체가 된다.', true),
(11872, 4386, 'withTx는 SELECT 1회·true, withoutTx는 SELECT 1회·true', '1차 캐시가 리포지토리나 애플리케이션 단위로 남는다고 본 오개념. 1차 캐시는 영속성 컨텍스트에 속해 트랜잭션이 끝나면 함께 사라지므로, 트랜잭션 밖의 두 조회는 캐시를 이어 쓰지 못한다.', false),
(11873, 4386, 'withTx는 SELECT 2회·true, withoutTx는 SELECT 2회·false', '1차 캐시가 동일성만 맞춰 주고 SELECT는 매번 나간다고 본 오개념. 캐시를 건너뛰고 매번 DB에 묻는 것은 JPQL이다. findById는 식별자로 1차 캐시를 먼저 확인해 있으면 SELECT 없이 그 인스턴스를 돌려준다.', false),
(11874, 4386, 'withTx는 SELECT 1회·true, withoutTx는 SELECT 2회·true', '식별자가 같으면 어느 컨텍스트에서 읽어도 같은 인스턴스라고 본 오개념. 참조 동일성은 한 영속성 컨텍스트 안에서만 보장되고, 컨텍스트가 다르면 같은 행이라도 별개의 객체가 만들어진다.', false),

-- 문제 4387
(11875, 4387, 'm1에 2번(lee, kim 순), m2에 1번으로 UPDATE가 모두 3번 차례로 실행된다.', 'setter를 부를 때마다 SQL이 만들어진다고 본 오개념. 변경 감지는 flush 때 한 번, 엔티티의 현재 값과 조회 시점 스냅샷을 비교해 달라진 엔티티마다 UPDATE를 만든다. 중간에 거친 lee는 비교 대상이 아니다.', false),
(11876, 4387, 'm1·m2에 1번씩 실행되며, 각각 setter를 부른 name, grade 컬럼만 SET 절에 담긴다.', '어떤 setter를 불렀는지 기록한다고 본 오개념. 비교 기준은 조회 시점 스냅샷이라, name이 결국 kim으로 돌아온 m1은 달라진 값이 없어 UPDATE가 생기지 않는다.', false),
(11877, 4387, 'm2에만 1번 실행되며, SET 절에 name, grade, email 모든 컬럼이 담긴다.', 'flush 때 m1은 현재 값이 스냅샷과 같아 빠지고, grade가 달라진 m2만 UPDATE가 만들어진다. @DynamicUpdate가 없으면 Hibernate는 SQL을 재사용하려고 바뀌지 않은 컬럼까지 모두 SET 절에 넣는다.', true),
(11878, 4387, 'm2에만 1번 실행되며, SET 절에 값이 바뀐 grade 컬럼 하나만 담긴다.', '바뀐 컬럼만 담는 것은 @DynamicUpdate를 붙였을 때의 동작이다. 기본 전략은 엔티티마다 미리 만들어 둔 전체 컬럼 UPDATE를 재사용하므로 name, email도 기존 값 그대로 함께 실린다.', false),

-- 문제 4388
(11879, 4388, '비영속 → 영속 → 영속 → 삭제', '컨트롤러에서도 영속성 컨텍스트가 살아 있다고 본 오개념. OSIV가 꺼져 있어 register의 트랜잭션이 끝날 때 컨텍스트가 닫히고, 반환된 joined는 식별자를 가진 채 관리 대상에서 빠진다.', false),
(11880, 4388, '비영속 → 비영속 → 준영속 → 삭제', 'INSERT가 DB로 나가야 관리가 시작된다고 본 오개념. persist는 SQL 전송 시점과 상관없이 호출 즉시 엔티티를 영속성 컨텍스트에 등록해 영속 상태로 만든다.', false),
(11881, 4388, '비영속 → 영속 → 준영속 → 준영속', 'remove를 detach처럼 컨텍스트에서 떼어 내는 호출로 본 오개념. remove는 삭제를 예약해 두는 것이어서, 엔티티는 flush 때 DELETE가 나갈 때까지 삭제 상태로 남는다.', false),
(11882, 4388, '비영속 → 영속 → 준영속 → 삭제', '(A)는 new로 만든 순수 객체이고 (B)는 persist로 관리가 시작된 상태다. register의 트랜잭션이 끝나며 컨텍스트가 닫혀 (C)의 joined는 분리되고, (D)는 flush 때 DELETE로 이어질 삭제 예약 상태다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1418, 4389, 'flush,플러시,flush(),em.flush(),flush 호출,플러시 호출', 'persist로 만들어진 INSERT는 곧바로 DB로 가지 않고 쓰기 지연 저장소에 쌓였다가 flush 때 한꺼번에 전송된다. 식별자 전략이 SEQUENCE라 save만으로는 INSERT가 나가지 않았고, 테스트 트랜잭션은 커밋 없이 롤백으로 끝나 커밋 직전에 일어나는 자동 flush도 없었다. 그래서 DB가 UNIQUE 제약을 검사할 SQL 자체가 전달되지 않았다. 추가한 한 줄(예: memberRepository.flush())이 flush를 일으켜 INSERT가 전송되자 DB가 두 번째 행을 거부했다. flush는 영속성 컨텍스트의 변경 내용을 DB에 맞추는 동기화일 뿐 커밋이 아니므로, 테스트가 끝나며 롤백되자 먼저 들어간 행까지 사라졌다. 트랜잭션을 확정하는 커밋, 영속성 컨텍스트를 비워 모든 엔티티를 준영속으로 만드는 clear와 구분한다.'),
       (1419, 4390, 'OSIV,Open Session In View,OpenSessionInView,open-in-view,spring.jpa.open-in-view,오픈 세션 인 뷰,오픈세션인뷰,Open EntityManager In View,OEIV', 'OSIV(Open Session In View)는 영속성 컨텍스트를 트랜잭션이 아니라 HTTP 요청 전체 범위로 열어 두는 기능이고, 스프링 부트에서는 spring.jpa.open-in-view의 기본값이 true라 켜져 있다. 켜져 있을 때는 서비스 트랜잭션이 끝나도 컨텍스트가 살아 있어 컨트롤러에서 지연 로딩이 되지만, 그만큼 DB 커넥션을 응답이 끝날 때까지 쥐고 있어 외부 API를 기다리는 동안 커넥션 풀이 바닥났다. 끄면 컨텍스트가 트랜잭션과 함께 닫혀 커넥션이 곧바로 반환되는 대신, 트랜잭션 밖에서 지연 로딩 프록시를 초기화하려다 예외가 난다. 이때는 필요한 연관 데이터를 서비스 트랜잭션 안에서 미리 읽어 DTO로 옮겨야 한다. 연관 엔티티를 실제로 쓸 때 조회하는 지연 로딩 자체나, 트랜잭션 범위를 정하는 @Transactional과 헷갈리지 않도록 구분한다.');

-- =====================================================
-- Lesson 859: 플러시 모드와 쓰기 지연
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5333, 859, '아래 코드를 실행했을 때 출력되는 값과 그 이유로 옳은 것은?', 'DB의 트랜잭션 격리 수준은 READ COMMITTED이고, 2차 캐시는 쓰지 않는다. id=1 회원의 name은 처음에 kim이다.

```java
@Transactional
public void check(Long id) {
    Member a = em.find(Member.class, id);

    // 이 사이에 다른 트랜잭션이 id=1 회원의 name을 lee로 바꾸고 커밋했다

    Member b = em.createQuery(
            "select m from Member m where m.id = :id", Member.class)
        .setParameter("id", id)
        .getSingleResult();

    System.out.println(b.getName());
}
```', 'OBJECTIVE'),
       (5334, 859, '아래 코드에서 (A)와 (B)에 담기는 값을 순서대로 나열한 것은?', 'JPA 구현체는 Hibernate이고 식별자 전략은 SEQUENCE다. 실행 전 member 테이블에는 id가 1~3인 회원 3명이 있다.

```java
@Transactional
public void run() {
    em.setFlushMode(FlushModeType.COMMIT);

    em.persist(new Member("park"));
    em.persist(new Member("choi"));
    em.remove(em.find(Member.class, 1L));

    Long a = em.createQuery("select count(m) from Member m", Long.class)
               .getSingleResult();   // (A)

    em.flush();

    Long b = em.createQuery("select count(m) from Member m", Long.class)
               .getSingleResult();   // (B)
}
```', 'OBJECTIVE'),
       (5335, 859, '아래 코드를 실행하고 커밋했을 때 member 테이블의 최종 상태로 옳은 것은?', 'DB에는 id가 1, 2, 3인 회원이 있고, 세 회원의 name은 모두 kim이다. 코드 어디에서도 저장 메서드를 따로 호출하지 않는다.

```java
@Transactional
public void rename() {
    Member a = em.find(Member.class, 1L);
    Member b = em.find(Member.class, 2L);
    Member c = em.find(Member.class, 3L);

    em.detach(b);
    em.remove(c);

    a.setName("lee");
    b.setName("lee");
    c.setName("lee");
}
```', 'OBJECTIVE'),
       (5336, 859, '아래는 한 트랜잭션 안에서 부를 수 있는 두 호출과 커밋을 비교한 표다. 표를 바탕으로 옳지 않은 것은?', '식별자 전략은 SEQUENCE이고, 모든 호출은 스프링의 @Transactional 메서드 안에서 일어난다.

| 구분 | 아직 DB로 보내지 않은 SQL | 1차 캐시·스냅샷 | 트랜잭션 |
| --- | --- | --- | --- |
| em.flush() | DB로 전송 | 그대로 유지 | 열린 채 계속 |
| em.clear() | 보내지 않고 버림 | 모두 비움 | 열린 채 계속 |
| 커밋 | 직전 flush로 전송 | 컨텍스트와 함께 종료 | 확정 후 종료 |', 'OBJECTIVE'),
       (5337, 859, '아래 상황에서 개발자가 요청마다 새로 만들도록 바꾼 JPA 객체의 이름은?', '스프링 없이 Hibernate를 JPA 구현체로 쓰는 사내 관리 도구다. 한 개발자가 요청을 처리하는 메서드의 첫 줄에서 JPA 객체 하나를 새로 만들도록 코드를 바꾼 뒤 아래 증상이 나타났다.

- 평균 15ms이던 응답 시간이 1.8초로 늘었다.
- 요청이 들어올 때마다 아래 로그가 반복해서 찍혔고, 커넥션 풀 번호가 요청마다 하나씩 올라갔다.

```
INFO  HHH000204: Processing PersistenceUnitInfo [name: adminPU]
INFO  HikariPool-37 - Starting...
INFO  HikariPool-37 - Start completed.
INFO  HHH000490: Using JtaPlatform implementation: [NoJtaPlatform]
```

- 몇 시간 뒤 DB 서버가 too many connections 오류를 내며 새 연결을 거부했다.

그 객체를 만드는 코드를 main 메서드의 시작 부분으로 옮기자 증상이 모두 사라졌다.', 'SUBJECTIVE'),
       (5338, 859, '아래 로그의 순서와 배치 설정의 효과가 모두 가능했던 바탕인 JPA 동작을 가리키는 용어는?', '회원 10,000명을 한 트랜잭션에서 저장하는 코드다. 식별자 전략은 SEQUENCE다.

```java
@Transactional
public void importAll(List<Member> members) {
    for (Member m : members) {
        em.persist(m);
        log.info("persisted: {}", m.getName());
    }
    log.info("loop end");
}
```

실행 로그의 끝부분 (시퀀스 조회 로그는 생략)

```
persisted: user9999
persisted: user10000
loop end
insert into member (name, id) values (?, ?)
insert into member (name, id) values (?, ?)
insert into member (name, id) values (?, ?)
... (insert 로그 10,000줄)
```

- insert 로그는 persisted 로그 10,000줄이 모두 찍히고 반복문이 끝난 뒤, 커밋 직전에 flush가 일어나면서야 나타났다.
- 설정에 hibernate.jdbc.batch_size: 100 한 줄을 추가하자 DB와 주고받은 왕복이 10,000번에서 100번으로 줄었고, 전체 저장 시간은 42초에서 4초가 됐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5333
(14395, 5333, 'lee — JPQL이 DB에서 읽은 값으로 1차 캐시의 a를 새로 고쳐 b로 돌려준다.', 'JPQL이 DB에 질의해 lee를 읽어 오는 것은 맞지만, 같은 식별자의 엔티티가 이미 영속성 컨텍스트에 있으면 그 값을 덮어쓰지 않는다. DB의 최신 값으로 다시 채우려면 em.refresh() 같은 별도 호출이 필요하다.', false),
(14396, 5333, 'kim — JPQL도 식별자로 1차 캐시를 먼저 찾아, SELECT 없이 a를 돌려준다.', '식별자로 1차 캐시를 먼저 확인하는 것은 find의 동작이다. JPQL은 조건이 식별자 하나뿐이어도 SQL로 바뀌어 항상 DB에 질의하므로 이 줄에서도 SELECT가 나간다.', false),
(14397, 5333, 'kim — SELECT는 실행되지만, 이미 관리 중인 a가 있어 DB에서 읽은 값을 버린다.', 'JPQL은 1차 캐시를 거치지 않고 DB에서 lee를 읽어 오지만, 같은 식별자의 a가 이미 관리 중이라 읽은 값을 버리고 a를 그대로 돌려준다. 동일성은 지켜지는 대신 다른 트랜잭션의 커밋이 반영되지 않은 것처럼 보인다.', true),
(14398, 5333, 'lee — JPQL 결과는 a와 별개인 새 인스턴스로 만들어져 b에 담긴다.', 'JPQL로 가져온 엔티티도 영속성 컨텍스트에 들어가며, 같은 식별자가 이미 있으면 기존 인스턴스로 대체된다. 한 컨텍스트 안에서 같은 식별자는 언제나 같은 객체라서 b는 a와 같은 객체다.', false),

-- 문제 5334
(14399, 5334, '4, 4', '쿼리 실행 전 flush는 기본값 AUTO의 동작이다. COMMIT 모드는 JPQL 앞의 flush를 생략하므로, (A) 시점의 DB에는 persist와 remove가 아직 반영되지 않았다.', false),
(14400, 5334, '3, 4', 'COMMIT 모드라 (A) 앞에서 flush가 일어나지 않아 DB에는 처음의 3명만 있다. em.flush()로 INSERT 2건과 DELETE 1건이 전송된 뒤에는 같은 트랜잭션의 조회가 그 결과를 보므로 3 + 2 - 1 = 4다.', true),
(14401, 5334, '2, 4', 'remove는 호출 즉시 DELETE를 보내지 않고 삭제를 예약만 한다. DELETE도 persist의 INSERT처럼 flush 때 함께 전송되므로 (A) 시점의 DB에서는 아무 행도 빠지지 않았다.', false),
(14402, 5334, '3, 3', '전송된 SQL도 커밋 전에는 조회에 보이지 않는다고 본 오개념. flush로 보낸 변경은 같은 트랜잭션 안의 이후 조회에 바로 보인다. 커밋이 필요한 것은 다른 트랜잭션에 보이게 할 때다.', false),

-- 문제 5335
(14403, 5335, '1번과 2번이 lee로 바뀌고, 3번 행은 삭제된다.', '식별자가 있으면 계속 추적된다고 본 오개념. detach로 분리된 b는 식별자를 가졌어도 관리 대상이 아니라 스냅샷 비교에서 빠지므로, 이후 setName은 DB에 반영되지 않는다.', false),
(14404, 5335, '1번과 2번은 kim으로 남고, 3번 행만 삭제된다.', '저장 메서드를 불러야 UPDATE가 나간다고 본 오개념. 영속 상태인 a는 커밋 직전 flush에서 조회 시점의 스냅샷과 비교되어, 저장 호출 없이도 변경 감지로 UPDATE가 만들어진다.', false),
(14405, 5335, '1번만 lee로 바뀌고, 2번은 kim, 3번 행은 lee로 남는다.', 'remove 뒤의 수정이 삭제를 취소한다고 본 오개념. 삭제 상태인 c는 변경 감지 대상이 아니며 flush 때 DELETE가 나간다. 삭제를 되돌리려면 다시 persist해야 한다.', false),
(14406, 5335, '1번만 lee로 바뀌고, 2번은 kim으로 남으며, 3번 행은 삭제된다.', 'a는 영속 상태라 변경 감지로 UPDATE가 나간다. b는 detach로 준영속이 되어 이후 변경이 무시되고, c는 remove로 삭제 상태가 되어 수정과 상관없이 flush 때 DELETE가 나간다.', true),

-- 문제 5336
(14407, 5336, '1,000건마다 clear만 호출하는 대량 저장은 메모리를 아끼면서도 모든 행이 저장된다.', '표에서 clear는 아직 보내지 않은 SQL을 버린다. flush 없이 clear만 하면 그 전까지 persist한 행의 INSERT가 사라지고, 마지막 clear 이후에 persist한 행만 커밋 때 저장된다. 대량 저장에서 flush와 clear를 짝지어 부르는 이유다.', true),
(14408, 5336, 'flush 뒤 예외로 롤백되면, 이미 DB로 보낸 INSERT의 결과도 함께 취소된다.', '표의 flush 행에서 트랜잭션은 열린 채 계속된다. flush는 SQL을 보내 DB와 맞출 뿐 확정이 아니어서, 이후 롤백하면 이미 보낸 INSERT도 함께 되돌려진다.', false),
(14409, 5336, 'clear 뒤에 같은 식별자로 find를 호출하면 SELECT가 다시 실행된다.', 'clear는 1차 캐시를 모두 비우므로 같은 식별자라도 컨텍스트에서 찾을 엔티티가 없다. 그래서 find가 DB에 SELECT를 다시 보내 새 인스턴스를 만든다.', false),
(14410, 5336, 'flush 뒤에 앞서 조회한 엔티티를 수정하면, 그 변경은 커밋 때 UPDATE로 반영된다.', 'flush는 1차 캐시와 스냅샷을 그대로 두므로 엔티티는 계속 영속 상태다. 이후의 수정도 커밋 직전 flush에서 스냅샷과 비교되어 UPDATE로 나간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1734, 5337, 'EntityManagerFactory,엔티티 매니저 팩토리,엔티티매니저팩토리,엔티티 매니저팩토리,Entity Manager Factory,EMF,SessionFactory,세션 팩토리,세션팩토리', 'EntityManagerFactory는 만들어질 때 영속성 유닛(persistence unit) 설정을 읽고 엔티티 매핑 정보를 분석하며 커넥션 풀까지 준비하므로 생성 비용이 크다. 그래서 애플리케이션 전체에서 하나만 만들어 함께 쓰는 것이 원칙이다. 요청마다 새로 만들면 로그처럼 영속성 유닛 처리와 커넥션 풀 시작이 매번 반복되어 응답이 느려지고, 닫지 않은 팩토리마다 커넥션 풀이 남아 결국 DB 커넥션이 바닥난다. 반면 EntityManager는 이 팩토리에서 요청·트랜잭션 단위로 꺼내 쓰는 가벼운 객체라 요청마다 새로 여는 것이 정상이며, 대신 스레드 간에 공유하면 안 된다. 무거워서 하나만 두는 팩토리와 가벼워서 매번 여는 EntityManager를 구분한다. Hibernate에서는 같은 역할을 하는 객체를 SessionFactory라고 부른다.'),
       (1735, 5338, '쓰기 지연,쓰기지연,지연 쓰기,쓰기 지연 SQL 저장소,쓰기 지연 저장소,트랜잭션을 지원하는 쓰기 지연,write-behind,write behind,writebehind,transactional write-behind,transactional write behind', 'persist로 만들어진 INSERT는 곧바로 DB로 가지 않고 영속성 컨텍스트의 쓰기 지연 SQL 저장소에 쌓였다가, flush가 일어날 때 한꺼번에 전송된다. 그래서 반복문이 끝나고 커밋 직전에 flush가 일어난 뒤에야 insert 로그가 찍혔다. SQL이 한곳에 모여 있기 때문에 hibernate.jdbc.batch_size를 설정하면 여러 INSERT를 JDBC 배치로 묶어 보낼 수 있고, 10,000번이던 DB 왕복이 100번으로 줄었다. flush는 쌓아 둔 SQL을 실제로 내보내는 시점일 뿐 SQL을 모아 두는 방식 자체가 아니며, 엔티티의 현재 값과 스냅샷을 비교해 UPDATE를 만드는 변경 감지와도 구분한다. 식별자 전략이 IDENTITY라면 식별자를 얻으려고 persist 시점에 INSERT가 바로 나가므로 이 이점이 줄어든다.');
