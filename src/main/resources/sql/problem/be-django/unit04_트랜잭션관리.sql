-- Unit: 트랜잭션 관리 (Unit ID: 135)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (561, 135, '세이브포인트와 durable, 행 잠금'),
       (719, 135, 'on_commit 시점과 자동 커밋'),
       (877, 135, 'Django 트랜잭션 경계와 실패 처리');

-- =====================================================
-- Lesson 561: 세이브포인트와 durable, 행 잠금
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3545, 561, '아래 SQL 로그를 남긴 Django 코드에 대한 설명으로 옳은 것은?', '한 번의 주문 요청이 데이터베이스에 남긴 쿼리 로그다. 위에서 아래 순서로 실행됐다.

```sql
UPDATE product SET stock = stock - 1 WHERE id = 7;
BEGIN;
INSERT INTO orders (product_id, user_id) VALUES (7, 3);
SAVEPOINT s1;
INSERT INTO coupons (order_id, code) VALUES (11, ''WELCOME'');
ROLLBACK TO SAVEPOINT s1;
UPDATE orders SET note = ''쿠폰 적용 실패'' WHERE id = 11;
COMMIT;
```', 'OBJECTIVE'),
       (3546, 561, '아래 비교표의 두 트랜잭션 적용 방식에 대한 설명으로 옳지 않은 것은?', 'Django에서 트랜잭션 경계를 잡는 두 방식을 정리한 표다. 방식 A는 DATABASES 설정에서 켜고, 방식 B는 코드에서 transaction.atomic으로 직접 감싼다.

| 항목 | 방식 A | 방식 B |
| --- | --- | --- |
| 트랜잭션 범위 | 미들웨어를 지난 뒤 뷰 함수 전체 | 개발자가 감싼 블록만 |
| 시작·종료 시점 | 뷰 진입 시 BEGIN, 응답 반환 직전 COMMIT | 블록 진입 시 BEGIN, 블록 종료 시 COMMIT |
| 뷰에서 예외가 밖으로 전파될 때 | 전체 롤백 후 500 응답 | 감싼 블록 단위로 롤백 |
| 일부만 빼는 방법 | 데코레이터로 특정 뷰만 제외 | 감싸지 않으면 그만 |', 'OBJECTIVE'),
       (3547, 561, '아래 코드를 실행할 때 (*) 표시가 붙은 줄에서 일어나는 일로 옳은 것은?', 'Tag.name에는 UNIQUE 제약이 걸려 있고, name이 python인 행은 이미 저장돼 있다.

```python
with transaction.atomic():
    try:
        Tag.objects.create(name="python")    # UNIQUE 위반 → IntegrityError
    except IntegrityError:
        pass
    tag = Tag.objects.get(name="python")     # (*)
    tag.count += 1
    tag.save()
```', 'OBJECTIVE'),
       (3548, 561, '아래 run 함수를 호출했을 때 출력 순서로 옳은 것은?', 'run은 다른 atomic 블록 안이 아닌 곳에서 호출되며, Log 모델에는 아무 제약도 없어 저장 자체는 성공한다.

```python
def run():
    with transaction.atomic():                      # 바깥
        transaction.on_commit(lambda: print("A"))
        try:
            with transaction.atomic():              # 안쪽
                Log.objects.create(text="x")
                transaction.on_commit(lambda: print("B"))
                raise ValueError("boom")
        except ValueError:
            pass
        transaction.on_commit(lambda: print("C"))
    print("D")
```', 'OBJECTIVE'),
       (3549, 561, '아래 요구를 만족시키려면 charge 함수의 transaction.atomic에 지정해야 하는 인자는?', '결제 서비스 함수 charge는 내부를 transaction.atomic으로 감싸고 있다. 단독으로 부를 때는 함수가 끝나는 순간 결제가 확정돼 아무 문제가 없었다. 그런데 주문 처리 뷰가 자기 atomic 블록 안에서 charge를 부르기 시작하면서, charge가 반환된 뒤에도 확정이 계속 미뤄지다가 뷰 마지막 줄의 검증 실패로 결제까지 함께 되돌아가는 사고가 났다. 팀은 charge가 이런 위치에서 호출되면 조용히 넘어가지 말고 그 자리에서 예외로 막히게 하기로 했다.', 'SUBJECTIVE'),
       (3550, 561, '아래 상황에서 개발자가 재고 조회 쿼리에 덧붙인 쿼리셋 메서드는?', '한정 수량 상품에 요청이 몰리던 날, 판매 기록은 100건인데 재고는 60개만 줄어 있었다. 개발자가 재고 행을 읽는 쿼리에 메서드 하나를 덧붙이자 다음 이벤트에서는 판매 건수와 재고 감소량이 정확히 맞아떨어졌고, 대신 같은 상품을 노린 다른 요청은 앞 요청이 끝날 때까지 그 행에서 대기했다. 처음 적용할 때는 이 쿼리셋을 transaction.atomic 블록 밖에서 평가했다가 TransactionManagementError를 만나기도 했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3545
(9627, 3545, '쿠폰 INSERT가 취소되면서 앞서 실행된 주문 INSERT까지 함께 취소됐다.', 'ROLLBACK TO SAVEPOINT s1은 s1 이후의 변경만 되돌린다. s1 앞의 주문 INSERT는 그대로 남아 마지막 COMMIT으로 확정된다. 롤백을 늘 전체 취소로 보는 오개념이다.', false),
(9628, 3545, '맨 앞 UPDATE는 트랜잭션 밖에서 실행돼 이미 확정됐고 뒤의 롤백에 영향받지 않는다.', 'BEGIN보다 앞에 찍힌 쿼리는 autocommit 모드로 실행돼 그 자리에서 커밋된다. 재고 차감을 atomic 블록 밖에 두면 이후 블록이 어떻게 끝나든 재고는 되돌아가지 않는다.', true),
(9629, 3545, '안쪽 블록이 별도 트랜잭션으로 열려 바깥과 독립적으로 먼저 커밋됐다.', '로그에 BEGIN과 COMMIT이 각각 한 번씩만 있다. 중첩된 atomic은 새 트랜잭션이 아니라 SAVEPOINT로 바뀌므로 안쪽만 따로 커밋되는 일은 없다.', false),
(9630, 3545, '안쪽 블록에 savepoint=False가 지정돼 세이브포인트 없이 실행됐다.', 'savepoint=False였다면 SAVEPOINT s1과 ROLLBACK TO 자체가 찍히지 않는다. 게다가 안쪽 실패가 바깥까지 오염시켜 COMMIT에 이르지 못한다.', false),

-- 문제 3546
(9631, 3546, '방식 A에서는 뷰가 외부 API 응답을 기다리는 동안에도 트랜잭션과 락이 그대로 유지된다.', '범위가 뷰 함수 전체이고 커밋이 응답 직전이므로, 뷰 안의 느린 호출 시간만큼 트랜잭션이 길어져 락 보유 시간이 늘어난다. 참인 진술이라 고를 선지가 아니다.', false),
(9632, 3546, '방식 B는 트랜잭션을 짧게 유지할 수 있지만 감싸는 것을 빼먹으면 원자성이 깨진다.', '묶이는 구간이 개발자가 감싼 블록뿐이라 범위를 좁게 잡을 수 있는 대신, 빠뜨린 구간은 쿼리마다 즉시 커밋돼 중간 실패가 그대로 남는다. 참인 진술이다.', false),
(9633, 3546, '방식 A에서 뷰가 예외를 잡아 400 응답을 돌려주면 변경 내용은 롤백되지 않고 커밋된다.', '표에서 롤백 조건은 예외가 뷰 밖으로 전파되는 경우다. 정상 응답으로 끝나면 커밋되므로, 되돌리려면 transaction.set_rollback(True)를 직접 불러야 한다. 참인 진술이다.', false),
(9634, 3546, '방식 A는 미들웨어가 실행한 쿼리까지 뷰와 하나의 트랜잭션으로 묶어 준다.', '표의 범위는 미들웨어를 지난 뒤의 뷰 함수 전체다. 미들웨어에서 실행한 쿼리는 이 트랜잭션 밖이라 별도로 커밋되므로 뷰가 롤백돼도 남는다. 유일하게 거짓인 진술이다.', true),

-- 문제 3547
(9635, 3547, 'TransactionManagementError가 발생해 블록이 그대로 실패한다.', '앞의 IntegrityError로 트랜잭션이 이미 실패 상태가 돼 이후 쿼리가 모두 막힌다. 실패할 수 있는 INSERT를 안쪽 atomic으로 감싸면 세이브포인트까지만 롤백돼 조회가 정상 동작한다.', true),
(9636, 3547, '기존 행을 정상적으로 읽어 count가 1 늘어난 채로 커밋된다.', 'except로 파이썬 예외를 잡아도 데이터베이스 쪽 트랜잭션 상태는 되돌아오지 않는다. 예외를 잡았으니 계속 써도 된다고 보는 가장 흔한 오해다.', false),
(9637, 3547, '같은 IntegrityError가 한 번 더 발생하며 예외 종류는 바뀌지 않는다.', '조회 쿼리는 UNIQUE 제약을 건드리지 않아 제약 위반이 날 이유가 없다. 실행을 막는 주체는 제약이 아니라 실패한 트랜잭션을 감지한 Django 쪽 검사다.', false),
(9638, 3547, 'except 절에 들어간 순간 트랜잭션이 롤백돼 이 줄은 실행되지 않는다.', '예외를 잡아도 블록이 끝난 것은 아니라 파이썬 실행 흐름은 그대로 다음 줄로 넘어온다. 롤백은 atomic 블록을 빠져나갈 때 일어난다.', false),

-- 문제 3548
(9639, 3548, 'A, B, C, D 순으로 출력된다.', '안쪽 블록이 세이브포인트까지 롤백되면서 그 안에서 등록한 B 콜백은 폐기된다. 한 번 등록하면 무조건 실행된다고 본 오해다.', false),
(9640, 3548, 'D, A, C 순으로 출력된다.', '콜백은 가장 바깥 블록이 커밋되는 순간, 즉 with 블록을 빠져나가는 시점에 실행된다. 함수가 다 끝난 뒤로 미뤄진다고 본 오해다.', false),
(9641, 3548, 'A, C, D 순으로 출력된다.', '안쪽 예외를 바깥에서 잡았으므로 바깥 트랜잭션은 정상 커밋된다. 커밋 직후 살아남은 콜백이 등록 순서대로 A, C를 찍고, 그다음 with 블록 밖의 D가 찍힌다.', true),
(9642, 3548, 'D만 출력되고 콜백은 하나도 실행되지 않는다.', '예외가 한 번이라도 나면 커밋이 없다고 본 오해다. ValueError는 안쪽 세이브포인트만 되돌리고 바깥은 커밋된다. 콜백이 버려지는 것은 커밋 자체가 없을 때다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1138, 3549, 'durable=True,durable = True,durable', 'durable=True(Django 3.2+)는 그 블록이 반드시 가장 바깥 트랜잭션이어야 한다는 조건을 걸어, 다른 atomic 안에서 실행되면 RuntimeError를 던진다. 덕분에 charge가 끝났는데도 커밋이 미뤄져 결제가 뒤늦게 되돌아가는 구조를 호출 시점에 바로 드러낼 수 있다. 세이브포인트 생성을 생략하는 savepoint=False와 헷갈리기 쉬운데, savepoint=False는 중첩을 허용하되 안쪽 실패가 바깥까지 오염시키는 옵션이라 목적이 정반대다. 커밋 이후로 사이드이펙트를 미루는 on_commit과도 역할이 다르다.'),
       (1139, 3550, 'select_for_update,select_for_update(),.select_for_update(),셀렉트포업데이트,셀렉트 포 업데이트', '읽고 계산해서 다시 쓰는 사이에 다른 트랜잭션이 끼어들어 갱신이 사라지는 상황이므로, 행을 읽는 시점에 잠금을 잡아 두는 select_for_update()가 답이다. 잠금은 트랜잭션이 끝날 때 풀리기 때문에 반드시 transaction.atomic 블록 안에서 평가해야 하고, autocommit 상태에서 호출하면 TransactionManagementError가 난다. 경합 자체를 단일 UPDATE로 피하는 F() 표현식은 잠금을 쓰지 않는 다른 해법이고, 커밋 이후 작업을 미루는 on_commit과는 역할이 아예 다르다.');

-- =====================================================
-- Lesson 719: on_commit 시점과 자동 커밋
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4493, 719, '아래 코드를 실행한 뒤 두 테이블에 남는 행 수로 옳은 것은?', '실행 전 orders와 coupon_usage 테이블은 모두 비어 있고, 이 코드는 다른 atomic 블록 밖에서 실행된다. CouponError는 데이터베이스와 무관한 파이썬 예외다.

```python
with transaction.atomic():                                  # 바깥
    order = Order.objects.create(user=user, total=30000)
    try:
        with transaction.atomic(savepoint=False):           # 안쪽
            CouponUsage.objects.create(order=order, code="WELCOME")
            raise CouponError("만료된 쿠폰")
    except CouponError:
        pass
```', 'OBJECTIVE'),
       (4494, 719, '아래 로그에 나타난 오류에 대한 설명으로 옳은 것은?', '주문 생성 뷰와 Celery 워커가 남긴 로그를 시간순으로 합친 것이다. 두 프로세스는 같은 PostgreSQL 서버의 같은 데이터베이스를 쓰며, 이 오류는 전체 주문 중 약 2%에서만 간헐적으로 나타난다.

```
12:00:00.101 [web]    BEGIN
12:00:00.103 [web]    INSERT INTO orders (...) RETURNING id  → 5012
12:00:00.104 [web]    send_receipt.delay(5012) 발행
12:00:00.109 [worker] send_receipt(5012) 시작
12:00:00.111 [worker] SELECT * FROM orders WHERE id = 5012  → 0 rows
12:00:00.112 [worker] Order.DoesNotExist 발생, 태스크 실패
12:00:00.140 [web]    COMMIT
```', 'OBJECTIVE'),
       (4495, 719, '아래 뷰에 요청 X와 요청 Y를 각각 보냈을 때 PointLog 행이 남는지로 옳은 것은?', 'DATABASES 설정에 ATOMIC_REQUESTS = True가 켜져 있고, 뷰는 Django REST framework(DRF)의 APIView로 기본 예외 핸들러를 쓴다. 요청 X는 coupon 값으로 EXPIRED를 보낸다. 요청 Y는 유효한 쿠폰을 보냈지만 카드 승인이 거절돼 charge_card가 CardError를 던진다. CardError는 데이터베이스와 무관한 예외다.

```python
class PointChargeView(APIView):
    def post(self, request):
        PointLog.objects.create(user=request.user, amount=1000)
        if request.data.get("coupon") == "EXPIRED":
            raise ValidationError("만료된 쿠폰")       # DRF의 ValidationError
        try:
            charge_card(request.user, 1000)
        except CardError:
            return Response({"detail": "카드 승인 실패"}, status=400)
        return Response(status=201)
```

두 요청 모두 클라이언트는 400 응답을 받는다.', 'OBJECTIVE'),
       (4496, 719, '아래 측정표를 바탕으로 한 설명으로 옳은 것은?', '주문 뷰 함수 전체에 @transaction.atomic이 붙어 있고, 함수 안에서 아래 순서대로 실행된다. 표의 소요 시간은 요청 한 건의 구간별 평균이며, ATOMIC_REQUESTS는 꺼져 있다.

| 순서 | 구간 | 소요 시간 |
| --- | --- | --- |
| 1 | 재고 행을 select_for_update()로 조회 | 5ms |
| 2 | 외부 결제 API에 승인 요청 | 2,800ms |
| 3 | 재고 차감 UPDATE, 주문 INSERT | 10ms |
| 4 | 영수증 메일을 SMTP로 직접 발송 | 900ms |
| 5 | 응답 데이터 구성 후 반환 | 20ms |', 'OBJECTIVE'),
       (4497, 719, '아래 상황에서 개발자가 테스트 코드에 사용한 TestCase의 메서드 이름은?', '주문을 만든 뒤 transaction.on_commit으로 영수증 메일을 보내는 place_order 함수가 있다. 운영 서버에서는 메일이 잘 나가는데, TestCase로 작성한 테스트에서는 place_order를 호출한 뒤 mail.outbox의 길이가 늘 0이었다. 테스트 클래스의 부모를 TransactionTestCase로 바꾸자 테스트는 통과했지만, 전체 테스트 실행 시간이 2분에서 9분으로 늘었다.

개발자는 부모를 다시 TestCase로 되돌리고, place_order 호출 부분만 아래처럼 감쌌다. 그러자 전체 실행 시간은 2분 그대로인 채 mail.outbox의 길이가 1이 됐다.

```python
with self.________(execute=True):
    place_order(self.user, self.product)
```', 'SUBJECTIVE'),
       (4498, 719, '아래 상황에서 atomic으로 감싸기 전 Django가 데이터베이스 연결에 적용하고 있던 기본 동작 방식을 가리키는 용어는?', 'Django 셸에서 재고가 100인 상품으로 아래 두 줄을 실행했다.

```python
product.stock = 99; product.save()
Order.objects.create(product=product)   # user 누락
```

첫 줄이 끝나자마자 다른 터미널의 psql에서 조회한 재고는 이미 99였다. 둘째 줄은 NOT NULL 제약 위반으로 IntegrityError를 내며 멈췄고, 주문은 생기지 않았는데 재고는 99로 남았다.

재고를 100으로 되돌린 뒤 같은 두 줄을 with transaction.atomic(): 안에 넣어 다시 실행하자, 첫 줄 직후 psql에서 본 재고는 100이었고 IntegrityError가 난 뒤에도 100 그대로였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4493
(12155, 4493, 'orders 1행, coupon_usage 0행', '안쪽 블록이 세이브포인트까지만 롤백된다고 본 오개념이다. savepoint=False는 되돌아갈 지점을 만들지 않으므로, 안쪽에서 예외가 빠져나가면 안쪽 변경만 골라 취소할 방법이 없다.', false),
(12156, 4493, 'orders 1행, coupon_usage 1행', '파이썬에서 예외를 잡았으니 트랜잭션도 멀쩡하다고 본 오개념이다. except로 실행 흐름은 이어지지만, Django는 안쪽 블록을 빠져나간 예외를 보고 이미 바깥 트랜잭션에 롤백 표시를 해 두었다.', false),
(12157, 4493, 'orders 0행, coupon_usage 0행', '세이브포인트 없는 안쪽 블록에서 예외가 나면 Django는 바깥 트랜잭션 전체를 롤백 예정으로 표시한다. 바깥 블록은 예외 없이 끝나도 COMMIT 대신 ROLLBACK하므로 주문까지 사라진다. except 뒤에 쿼리를 더 실행했다면 TransactionManagementError가 났다.', true),
(12158, 4493, 'orders 0행, coupon_usage 1행', '안쪽 블록이 별도 트랜잭션으로 열려 먼저 커밋된다고 본 오개념이다. 중첩된 atomic은 새 트랜잭션을 열지 않으며, savepoint=False면 바깥 트랜잭션에 그대로 합쳐져 함께 롤백된다.', false),

-- 문제 4494
(12159, 4494, '발행 코드를 transaction.on_commit 콜백으로 옮기면 발행이 COMMIT 뒤로 밀려 이 오류가 사라진다.', '워커는 웹 쪽 트랜잭션이 커밋되기 전의 INSERT를 볼 수 없다. on_commit에 등록한 콜백은 가장 바깥 트랜잭션이 커밋된 직후 실행되므로, 워커가 조회할 때는 주문 행이 이미 확정돼 있다. 롤백되면 콜백이 버려져 발행 자체가 일어나지 않는다.', true),
(12160, 4494, '발행 코드를 atomic 블록의 마지막 줄로 옮기면 COMMIT 이후에 발행돼 이 오류가 사라진다.', '블록의 마지막 줄도 여전히 블록 안이라 COMMIT 전에 실행된다. 커밋은 블록을 빠져나갈 때 일어나므로, 줄 위치만 옮겨서는 워커가 먼저 조회하는 경쟁을 막을 수 없다.', false),
(12161, 4494, '워커 연결의 격리 수준을 READ UNCOMMITTED로 낮추면 커밋 전 행을 읽어 이 오류가 사라진다.', 'PostgreSQL은 READ UNCOMMITTED를 READ COMMITTED처럼 처리해 커밋 전 행을 보여 주지 않는다. 설령 읽히더라도 웹 쪽이 롤백되면 존재하지 않는 주문으로 메일을 보내게 되니 해결책이 아니다.', false),
(12162, 4494, '두 프로세스가 같은 데이터베이스를 쓰므로 0 rows는 워커가 다른 데이터베이스에 붙었다는 뜻이다.', '같은 데이터베이스라도 연결마다 트랜잭션이 따로 있어 커밋되지 않은 INSERT는 다른 연결에서 보이지 않는다. 오류가 일부 주문에서만 나고 COMMIT이 워커 조회보다 늦게 찍힌 것은 설정 문제가 아니라 타이밍 경쟁이라는 증거다.', false),

-- 문제 4495
(12163, 4495, '요청 X: 남음 / 요청 Y: 남음', 'DRF가 예외를 응답으로 바꿔 주니 뷰가 정상 종료돼 커밋된다고 본 오개념이다. DRF 기본 핸들러는 APIException 계열 예외를 응답으로 바꾸면서 ATOMIC_REQUESTS 트랜잭션에 롤백 표시를 남긴다.', false),
(12164, 4495, '요청 X: 남음 / 요청 Y: 남지 않음', '두 경로의 처리를 뒤바꾼 오개념이다. 예외를 DRF가 응답으로 바꿔 준 쪽(X)이 롤백되고, 개발자가 직접 잡아 Response를 돌려준 쪽(Y)은 Django가 보기에 정상 반환이라 커밋된다.', false),
(12165, 4495, '요청 X: 남지 않음 / 요청 Y: 남지 않음', '400 응답이면 무조건 롤백된다고 본 오개념이다. 롤백 여부는 상태 코드가 아니라 예외가 빠져나갔는지, 롤백 표시가 있는지로 정해진다. Y에서 되돌리려면 transaction.set_rollback(True)를 직접 불러야 한다.', false),
(12166, 4495, '요청 X: 남지 않음 / 요청 Y: 남음', 'X의 ValidationError는 APIException 계열이라 DRF 핸들러가 400 응답을 만들면서 롤백 표시를 해 PointLog가 취소된다. Y는 뷰가 CardError를 직접 잡고 Response를 반환해 정상 종료로 처리되므로 PointLog가 커밋된다.', true),

-- 문제 4496
(12167, 4496, '재고 행 잠금은 1번 조회가 끝나는 즉시 풀리므로 같은 상품의 다른 요청은 5ms 정도만 기다린다.', 'select_for_update()가 잡은 잠금은 쿼리가 끝날 때가 아니라 트랜잭션이 끝날 때 풀린다. 이 뷰는 함수 전체가 트랜잭션이라 5번 구간까지 마치고 커밋될 때까지 잠금이 유지된다.', false),
(12168, 4496, '한 요청이 재고 행 잠금을 쥐고 있는 시간은 약 3.7초이고, 그 대부분은 데이터베이스 작업이 아닌 구간이다.', '잠금은 1번에서 잡혀 함수가 끝나는 커밋 시점에 풀리므로 2~5번(2,800+10+900+20=3,730ms) 동안 유지된다. 그중 쿼리는 3번의 10ms뿐이라, 외부 호출을 트랜잭션 밖으로 빼는 것이 핵심 개선 방향이다.', true),
(12169, 4496, '4번 메일 발송을 transaction.on_commit 콜백으로 옮기면 요청 한 건의 응답 시간이 약 900ms 줄어든다.', 'on_commit 콜백은 비동기가 아니라 커밋 직후 같은 요청 흐름에서 바로 실행된다. 옮기면 잠금 보유 시간은 900ms 줄지만 응답은 여전히 메일 발송을 기다린다. 응답까지 줄이려면 콜백에서 태스크 큐로 넘겨야 한다.', false),
(12170, 4496, '2번 결제 요청을 atomic 블록 밖으로 빼도 실행되는 쿼리 수가 같으므로 잠금 보유 시간은 그대로다.', '잠금 보유 시간은 쿼리 개수가 아니라 잠금을 잡은 뒤 커밋까지 걸린 시간으로 정해진다. 결제 요청을 블록 밖으로 빼면 약 2,800ms가 트랜잭션에서 빠져 다른 요청의 대기 시간이 크게 준다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1454, 4497, 'captureOnCommitCallbacks,self.captureOnCommitCallbacks,captureOnCommitCallbacks(),self.captureOnCommitCallbacks(),captureOnCommitCallbacks(execute=True),self.captureOnCommitCallbacks(execute=True)', 'TestCase는 테스트마다 트랜잭션을 열고 끝에 롤백으로 되돌리기 때문에 커밋이 한 번도 일어나지 않고, 그래서 on_commit에 등록한 콜백도 실행되지 않는다. captureOnCommitCallbacks(Django 3.2+)는 with 블록 안에서 등록된 on_commit 콜백을 모아 두고, execute=True를 주면 블록을 빠져나올 때 그 콜백들을 바로 실행해 준다. 실제 커밋을 일으키는 TransactionTestCase도 콜백을 돌릴 수 있지만 테스트마다 테이블을 비우는 방식이라 느리므로, 커밋 이후 다른 연결에서 데이터가 보이는지처럼 실제 커밋이 꼭 필요한 경우에만 쓰는 편이 좋다. 콜백 예외를 로깅만 하고 다음 콜백으로 넘어가게 하는 on_commit의 robust=True 옵션과는 목적이 다르다.'),
       (1455, 4498, '자동 커밋,자동커밋,autocommit,auto commit,auto-commit,오토커밋,오토 커밋,autocommit 모드,자동 커밋 모드', 'Django는 데이터베이스 연결을 자동 커밋(autocommit) 모드로 열어, save()나 create() 같은 쿼리가 실행되는 즉시 각각 확정된다. 그래서 첫 줄의 재고 변경은 다른 연결에서 곧바로 보였고, 둘째 줄이 실패해도 되돌릴 방법이 없었다. transaction.atomic으로 묶으면 블록 전체가 하나의 트랜잭션이 되어 커밋 전에는 다른 연결에서 변경이 보이지 않고, 예외가 블록을 빠져나가면 모두 롤백된다. 트랜잭션 안에서 일부 구간만 되돌리는 세이브포인트나, 뷰 전체를 트랜잭션으로 감싸는 ATOMIC_REQUESTS와 달리, 트랜잭션을 따로 지정하지 않았을 때의 기본값이라는 점이 핵심이다.');

-- =====================================================
-- Lesson 877: Django 트랜잭션 경계와 실패 처리
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5441, 877, '아래 실행 기록표에서 ㉠, ㉡에 들어갈 조회 결과로 옳은 것은?', '데이터베이스는 PostgreSQL이고, 두 연결 모두 기본 격리 수준을 쓴다. 실행 전 order_items 테이블은 비어 있다. 연결 1의 코드는 다른 atomic 블록 밖에서 시작되며, PaymentError는 데이터베이스와 무관한 파이썬 예외다.

| 순서 | 연결 1 (Django 코드) | 연결 2 (psql) |
| --- | --- | --- |
| 1 | 바깥 with transaction.atomic(): 진입 | |
| 2 | Order.objects.create(...) 실행 | |
| 3 | 안쪽 with transaction.atomic(): 진입 후 OrderItem.objects.create(...) 실행 | |
| 4 | 안쪽 블록이 예외 없이 끝남 | SELECT count(*) FROM order_items; → ㉠ |
| 5 | 바깥 블록 안에서 PaymentError 발생, 잡지 않고 블록 밖으로 전파 | |
| 6 | | SELECT count(*) FROM order_items; → ㉡ |', 'OBJECTIVE'),
       (5442, 877, '아래 조건에서 create_order를 호출한 결과로 옳은 것은?', 'create_order는 다른 atomic 블록 밖에서 호출된다. 주문 INSERT 자체는 오류 없이 실행됐지만, SMTP 서버 장애로 콜백 (1)이, 푸시 서버 장애로 콜백 (2)가 각각 예외를 던졌다.

```python
def create_order(user):
    with transaction.atomic():
        order = Order.objects.create(user=user, total=30000)
        transaction.on_commit(lambda: send_receipt(order.id), robust=True)  # (1)
        transaction.on_commit(lambda: push_notify(order.id))                # (2)
        transaction.on_commit(lambda: cache.delete("recent_orders"))        # (3)
    return order
```', 'OBJECTIVE'),
       (5443, 877, '아래 설정과 코드에서 attendance_view에 요청이 들어왔을 때 일어나는 일로 옳은 것은?', 'add_points는 지금까지 Celery 태스크에서만 직접 호출됐고, 매번 문제없이 커밋됐다. 이번에 DATABASES 설정에 ATOMIC_REQUESTS = True를 켠 상태에서 add_points를 부르는 attendance_view를 새로 추가했다. attendance_view에는 트랜잭션 관련 데코레이터가 따로 붙어 있지 않다.

```python
# services.py
@transaction.atomic(durable=True)
def add_points(user, amount):
    user.points += amount
    user.save()
    PointLog.objects.create(user=user, amount=amount)

# views.py
def attendance_view(request):
    Attendance.objects.create(user=request.user)
    add_points(request.user, 100)
    return JsonResponse({"ok": True})
```', 'OBJECTIVE'),
       (5444, 877, '아래 코드에서 handle_transfer(1, 2, 10000)을 실행한 뒤 1번 계좌 잔액과 TransferLog 행으로 옳은 것은?', 'handle_transfer는 다른 atomic 블록 밖에서 호출된다. 실행 전 1번 계좌 잔액은 50,000원이고, 2번 계좌는 동결 상태이며, TransferLog 테이블은 비어 있다. FrozenAccountError는 데이터베이스와 무관한 파이썬 예외다.

```python
@transaction.atomic
def transfer(src_id, dst_id, amount):
    src = Account.objects.get(id=src_id)
    src.balance -= amount
    src.save()
    dst = Account.objects.get(id=dst_id)
    if dst.is_frozen:
        raise FrozenAccountError("동결 계좌")
    dst.balance += amount
    dst.save()

def handle_transfer(src_id, dst_id, amount):
    try:
        transfer(src_id, dst_id, amount)
    except FrozenAccountError:
        TransferLog.objects.create(src_id=src_id, status="REJECTED")
```', 'OBJECTIVE'),
       (5445, 877, '아래 상황에서 개발자가 export_orders 뷰에 붙인 데코레이터의 이름은?', 'DATABASES 설정에 ATOMIC_REQUESTS = True가 켜진 서비스가 있다. 주문 50만 건을 1,000건씩 나눠 조회하면서 CSV 파일을 만드는 export_orders 뷰는 한 번 실행에 약 40초가 걸린다. 이 뷰가 도는 동안 PostgreSQL의 pg_stat_activity에는 해당 연결이 쿼리 사이사이 idle in transaction 상태로 40초 내내 남아 있었고, 그 사이 orders 테이블에 ALTER TABLE을 걸면 내보내기가 끝날 때까지 대기했다.

개발자가 데코레이터 하나를 export_orders에만 붙이자, 내보내기 시간은 40초 그대로였지만 idle in transaction 상태가 사라졌고 ALTER TABLE도 더 이상 40초씩 기다리지 않았다. 주문 생성 뷰를 비롯한 다른 뷰의 트랜잭션 동작은 달라지지 않았다.', 'SUBJECTIVE'),
       (5446, 877, '아래 상황에서 수정 후 쿼리 로그에 행마다 새로 붙은 SQL 명령들이 공통으로 다루는 대상의 이름은?', '상품 1,000행을 CSV에서 읽어 저장하는 가져오기 함수가 있다. 함수 전체를 with transaction.atomic(): 한 블록으로 감싸고, 행마다 Product.objects.create(...)를 try/except IntegrityError로 감쌌다. 파일 곳곳에는 이미 등록된 SKU와 겹치는 행이 13개 섞여 있었다.

- 수정 전: 첫 번째 중복 행에서 IntegrityError를 잡은 직후, 다음 행의 create에서 TransactionManagementError가 나며 가져오기가 멈췄고 한 행도 저장되지 않았다.
- 수정 후: 행마다 create 한 줄만 안쪽 with transaction.atomic():으로 한 번 더 감쌌다. 987행이 저장되고 중복 13행만 빠졌으며, COMMIT은 여전히 마지막에 한 번뿐이었다. 대신 쿼리 로그를 보니 INSERT 한 줄마다 앞에 명령 하나, 뒤에 명령 하나가 새로 붙어 있었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5441
(14683, 5441, '㉠ 1행, ㉡ 1행', '안쪽 블록이 끝나는 순간 커밋된다고 본 오개념이다. 중첩된 atomic은 새 트랜잭션이 아니라 세이브포인트라서 정상 종료해도 RELEASE SAVEPOINT만 실행될 뿐 확정되지 않고, 바깥이 롤백되면 함께 사라진다.', false),
(14684, 5441, '㉠ 1행, ㉡ 0행', '안쪽 블록이 끝나면 변경이 다른 연결에 보인다고 본 오개념이다. RELEASE SAVEPOINT는 되돌아갈 지점을 없앨 뿐 커밋이 아니므로, 바깥 트랜잭션이 커밋되기 전까지 연결 2는 이 행을 볼 수 없다.', false),
(14685, 5441, '㉠ 0행, ㉡ 1행', '세이브포인트가 안쪽 작업을 바깥 롤백으로부터 지켜 준다고 본 오개념이다. 세이브포인트는 안쪽이 실패할 때 그 지점까지만 되돌리는 장치일 뿐, 바깥 트랜잭션이 롤백되면 그 안의 변경은 모두 취소된다.', false),
(14686, 5441, '㉠ 0행, ㉡ 0행', '안쪽 블록은 세이브포인트라 정상 종료해도 RELEASE SAVEPOINT만 실행되고 커밋되지 않는다. PostgreSQL 기본 격리 수준에서 연결 2는 커밋 전 데이터를 못 보므로 ㉠은 0행이다. 5번 예외로 바깥 트랜잭션 전체가 롤백돼 ㉡도 0행이다.', true),

-- 문제 5442
(14687, 5442, '(1)의 예외가 곧바로 전파되어 (2)와 (3)은 실행되지 않는다.', '(1)에 붙은 robust=True를 놓친 오개념이다. robust=True로 등록한 콜백은 예외가 나도 Django가 잡아 로그만 남기고 다음 콜백으로 넘어가므로 (2)는 실행된다.', false),
(14688, 5442, '(3)은 실행되지 않지만 주문 행은 데이터베이스에 그대로 남는다.', '콜백은 커밋이 끝난 뒤 등록 순서대로 실행된다. (1)은 robust=True라 예외가 로그로만 남고, 기본값으로 등록된 (2)의 예외는 그대로 전파돼 뒤의 (3)은 건너뛴다. 이미 커밋된 주문은 콜백 실패로 되돌아가지 않는다.', true),
(14689, 5442, '(2)의 예외가 전파되면서 주문 INSERT까지 롤백되어 주문 행이 사라진다.', 'on_commit 콜백이 트랜잭션 안에서 실행된다고 본 오개념이다. 콜백은 바깥 트랜잭션이 커밋된 직후에 실행되므로, 콜백에서 예외가 나도 이미 확정된 주문 INSERT를 되돌릴 방법이 없다.', false),
(14690, 5442, '세 콜백이 모두 실행되고 (1)과 (2)의 예외는 로그로만 남는다.', 'robust=True가 뒤에 등록한 콜백에도 적용된다고 본 오개념이다. robust는 그 인자를 붙여 등록한 콜백 하나에만 적용되므로, 기본값으로 등록된 (2)가 예외를 던지면 그 뒤 콜백은 실행되지 않는다.', false),

-- 문제 5443
(14691, 5443, 'add_points 블록은 세이브포인트로 바뀌어 실행되고, 응답 직전에 출석 기록과 함께 커밋된다.', 'durable=True를 무시하고 일반 중첩 atomic처럼 본 오개념이다. durable=True는 이 블록이 가장 바깥 트랜잭션이어야 한다는 조건이라, 다른 atomic 안에 놓이면 세이브포인트로 바뀌는 대신 진입 자체가 거부된다.', false),
(14692, 5443, 'add_points 블록은 뷰 트랜잭션과 별개로 열려 먼저 커밋되고, 출석 기록은 응답 직전에 커밋된다.', 'durable=True를 독립된 새 트랜잭션을 여는 옵션으로 본 오개념이다. Django의 atomic에는 바깥과 별개인 트랜잭션을 열어 먼저 커밋하는 기능이 없고, durable=True는 중첩된 위치인지 검사해 막을 뿐이다.', false),
(14693, 5443, 'add_points 본문이 실행되기 전에 RuntimeError가 나고, 출석 기록까지 함께 롤백된다.', 'ATOMIC_REQUESTS가 뷰 전체를 atomic으로 감싸므로 add_points의 durable 블록은 중첩된 위치에 놓여 진입 시 RuntimeError가 난다. 이 예외가 뷰 밖으로 전파되면 요청 트랜잭션이 롤백돼 먼저 만든 출석 기록도 사라진다.', true),
(14694, 5443, 'add_points 본문이 실행되기 전에 RuntimeError가 나지만, 출석 기록은 이미 커밋돼 남는다.', 'ATOMIC_REQUESTS를 켜도 뷰 안의 쿼리가 자동 커밋된다고 본 오개념이다. 이 설정은 뷰 전체를 한 트랜잭션으로 감싸므로 출석 INSERT는 아직 확정 전이고, 예외가 뷰 밖으로 나가면 함께 롤백된다.', false),

-- 문제 5444
(14695, 5444, '잔액 50,000원 / REJECTED 행 1개', '데코레이터로 붙인 atomic도 함수 전체를 한 트랜잭션으로 묶어, 예외가 빠져나가면 앞의 save()까지 롤백한다. 예외는 삼키지 않고 다시 던지므로 except가 실행되고, 이 create는 트랜잭션 밖이라 자동 커밋으로 바로 확정된다.', true),
(14696, 5444, '잔액 40,000원 / REJECTED 행 1개', 'save()가 실행되는 즉시 커밋된다고 본 오개념이다. 자동 커밋은 트랜잭션 밖의 기본 동작일 뿐, @transaction.atomic이 붙은 함수 안의 save()는 함수가 정상 종료돼야 커밋되고 예외가 나면 롤백된다.', false),
(14697, 5444, '잔액 50,000원 / 행 없음', 'atomic이 롤백하면서 예외까지 삼킨다고 본 오개념이다. atomic은 롤백한 뒤 예외를 그대로 다시 던지므로 호출자의 except가 실행된다. 로그 INSERT는 transfer의 트랜잭션이 끝난 뒤라 함께 롤백되지도 않는다.', false),
(14698, 5444, '잔액 40,000원 / 행 없음', 'atomic이 예외를 잡아 거기까지 한 작업을 커밋하고 조용히 끝낸다고 본 오개념이다. 예외가 블록을 빠져나가면 커밋이 아니라 롤백이 일어나고, 예외는 호출자에게 그대로 전달된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1770, 5445, 'non_atomic_requests,@non_atomic_requests,transaction.non_atomic_requests,@transaction.non_atomic_requests,non atomic requests', 'ATOMIC_REQUESTS = True는 모든 뷰 함수를 하나의 트랜잭션으로 감싸기 때문에, 40초 걸리는 내보내기 뷰도 요청 내내 트랜잭션을 열어 둔다. 조회 쿼리가 잡은 잠금은 트랜잭션이 끝날 때까지 유지되므로 그동안 ALTER TABLE이 기다렸다. @transaction.non_atomic_requests를 붙인 뷰만 요청 단위 트랜잭션에서 빠져 자동 커밋(autocommit)으로 쿼리마다 바로 끝나고, 다른 뷰는 그대로 감싸진다. 뷰 안에서 필요한 구간만 transaction.atomic으로 묶는 것과는 방향이 반대이고, 현재 트랜잭션에 롤백 표시를 하는 transaction.set_rollback(True)나 다른 atomic 안에서 호출되면 RuntimeError를 내는 atomic(durable=True)와도 역할이 다르다.'),
       (1771, 5446, '세이브포인트,세이브 포인트,savepoint,save point,savepoints,저장점', '안쪽 atomic 블록은 새 트랜잭션이 아니라 세이브포인트로 바뀐다. 블록에 들어갈 때 SAVEPOINT를 만들고, 정상 종료하면 RELEASE SAVEPOINT, 예외가 나면 ROLLBACK TO SAVEPOINT로 그 지점 이후의 변경만 되돌린다. 그래서 INSERT마다 앞뒤로 명령이 하나씩 붙었고, 중복 행의 INSERT만 취소된 채 트랜잭션이 정상 상태로 돌아와 다음 행을 계속 저장할 수 있었다. COMMIT이 한 번뿐인 것은 가장 바깥 블록만 진짜 트랜잭션이기 때문이다. 안쪽 블록을 독립된 트랜잭션으로 보면 행마다 COMMIT이 찍혀야 하므로 로그와 맞지 않고, 안쪽에 savepoint=False를 주면 이 격리가 사라져 수정 전과 같은 TransactionManagementError가 난다. get_or_create가 내부에서 안쪽 atomic을 쓰는 이유도 같다.');
