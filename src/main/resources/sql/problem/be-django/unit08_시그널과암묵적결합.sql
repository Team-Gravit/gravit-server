-- Unit: 시그널과 암묵적 결합 (Unit ID: 139)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (565, 139, 'post_save 실행 시점과 중복 등록'),
       (723, 139, '발생 경로와 m2m_changed·raw'),
       (881, 139, 'Django 시그널이 숨기는 비용과 명시적 대안');

-- =====================================================
-- Lesson 565: post_save 실행 시점과 중복 등록
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3569, 565, '아래 로그가 남은 요청의 처리 결과로 옳은 것은?', '`create_order` 뷰는 `transaction.atomic()` 블록 없이 실행된다. 프로젝트 설정은 `ATOMIC_REQUESTS=False`이다.

```
POST /orders/  ->  500 Internal Server Error

Traceback (most recent call last):
  File "orders/views.py", line 22, in create_order
    order = Order.objects.create(user=request.user, total=10000)
  File "django/db/models/base.py", line 812, in save_base
    post_save.send(sender=Order, instance=self, created=True)
  File "django/dispatch/dispatcher.py", line 189, in send
    response = receiver(signal=self, sender=sender, **named)
  File "notifications/signals.py", line 14, in notify_on_create
    send_push(instance.user_id)
ConnectionError: push gateway unreachable
```', 'OBJECTIVE'),
       (3570, 565, '아래 두 경로로 주문을 등록한 뒤 재고 데이터에 대한 설명으로 옳은 것은?', '```python
# stock/signals.py
@receiver(post_save, sender=Order)
def reduce_stock(sender, instance, created, **kwargs):
    if created:
        Stock.objects.filter(product=instance.product).update(qty=F("qty") - instance.qty)


# (A) 상담원 화면 - 주문 1건 등록
Order.objects.create(product=p, qty=2)

# (B) 야간 배치 - 제휴사 CSV 주문 1,200건 등록
Order.objects.bulk_create([Order(product=r.product, qty=r.qty) for r in rows])
```

두 경로 모두 예외 없이 끝났고, 주문 테이블에는 1,201건이 정상으로 쌓였다.', 'OBJECTIVE'),
       (3571, 565, '아래에서 테스트 환경에서만 오류가 나는 원인으로 옳은 것은?', '두 수신자는 각 앱의 `AppConfig.ready()`에서 `signals` 모듈을 임포트해 등록된다.

```python
# settings/prod.py
INSTALLED_APPS = ["orders", "billing", "analytics"]

# settings/test.py
INSTALLED_APPS = ["orders", "analytics", "billing"]

# billing/signals.py
@receiver(post_save, sender=Order)
def make_invoice(sender, instance, created, **kwargs):
    if created:
        Invoice.objects.create(order=instance, amount=instance.total)

# analytics/signals.py
@receiver(post_save, sender=Order)
def record_revenue(sender, instance, created, **kwargs):
    if created:
        Revenue.objects.create(amount=instance.invoice.amount)
```

운영에서는 같은 코드가 오류 없이 돌지만, 테스트에서만 아래가 뜬다.

```
RelatedObjectDoesNotExist: Order has no invoice.
```', 'OBJECTIVE'),
       (3572, 565, '아래 표를 바탕으로 옳지 않은 것은?', '주문 저장에 딸린 사이드이펙트(알림 발송)를 어디에 두느냐에 따라 관측되는 동작을 정리한 표다.

| 사이드이펙트를 둔 위치 | `order.save()` 호출 시 | `Order.objects.update()` 시 | `atomic` 블록이 롤백될 때 |
| --- | --- | --- | --- |
| `post_save` 수신자 | 실행됨 | 실행 안 됨 | 롤백 전에 이미 실행됨 |
| `Model.save()` 오버라이드 | 실행됨 | 실행 안 됨 | 롤백 전에 이미 실행됨 |
| `transaction.on_commit()` 등록 | 커밋된 뒤 실행됨 | 등록되지 않음 | 실행되지 않음 |
| 서비스 함수 안 명시 호출 | 그 함수를 거친 경우만 실행됨 | 실행 안 됨 | 롤백 전에 이미 실행됨 |', 'OBJECTIVE'),
       (3573, 565, '아래 상황이 다시 생기지 않도록 수신자를 등록할 때 지정해야 하는 값의 이름은?', '```
[08:12:03] orders        INFO  Order#4821 created
[08:12:03] notifications INFO  push sent to user 77
[08:12:03] notifications INFO  push sent to user 77
```

`notify_on_create` 수신자는 `orders/signals.py`에 딱 한 번 정의돼 있다. 그런데 `orders/apps.py`의 `ready()`와 `orders/models.py` 맨 아래에서 각각 `from . import signals`를 하고 있고, 이번 배포 뒤부터 사용자에게 같은 푸시가 두 번씩 도착한다.', 'SUBJECTIVE'),
       (3574, 565, '아래 지표의 원인을 없애기 위해 알림 발송을 등록해 두어야 하는 Django 트랜잭션 API의 이름은?', '주문 생성과 결제 승인은 하나의 `transaction.atomic()` 블록으로 묶여 있고, 접수 알림은 `post_save` 수신자 안에서 곧바로 발송한다. 결제 취소가 잦은 시간대 1시간의 지표는 다음과 같다.

```
주문 생성 시도                              1,000건
결제 실패로 atomic 롤백                       180건
DB에 남은 주문                                820건
발송된 주문 접수 알림                       1,000건
고객센터 문의 "취소됐는데 접수 문자가 왔다"     173건
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3569
(9691, 3569, 'Django가 수신자 예외를 자동으로 걸러 내므로 뷰는 정상 응답을 반환하고 로그만 남는다.', 'send()는 수신자 예외를 그대로 호출부로 전파한다. 예외를 잡아 반환값 목록으로 돌려주는 것은 send_robust()이며, 기본 send()에는 그런 보호막이 없다.', false),
(9692, 3569, '수신자는 응답을 보낸 뒤 별도 스레드에서 실행되므로 이 예외는 응답 코드와 무관하다.', '시그널을 비동기 이벤트로 오해한 것. 수신자는 발신자와 같은 스레드에서 동기 실행되며, save()가 반환되기 전에 모두 끝난다. 트레이스백이 뷰 프레임까지 이어진 것이 그 증거다.', false),
(9693, 3569, '주문 INSERT는 이미 커밋된 뒤라 행은 DB에 남고, 클라이언트만 500을 받는다.', 'post_save는 save_base가 INSERT를 실행한 직후에 발신된다. atomic 블록이 없어 그 INSERT는 자동 커밋된 상태이므로, 뒤이어 수신자가 터져도 행은 되돌아가지 않는다.', true),
(9694, 3569, '수신자에서 예외가 나면 앞서 실행된 INSERT까지 함께 롤백되어 주문 행이 남지 않는다.', '시그널 예외가 롤백을 유발한다는 오해. 롤백은 열려 있는 트랜잭션이 있을 때만 가능한데, 본문은 atomic 블록이 없다고 못 박아 되돌릴 트랜잭션 자체가 없다.', false),

-- 문제 3570
(9695, 3570, '(B)로 만들어진 1,200건은 재고가 줄지 않아, 장부상 재고가 실제보다 많게 남는다.', 'bulk_create()는 인스턴스마다 save()를 부르지 않고 INSERT를 직접 보내는 최적화 경로라 post_save가 아예 발신되지 않는다. 결국 (A)의 1건만 차감된다.', true),
(9696, 3570, '(B)는 한 번의 INSERT로 처리되므로 post_save도 1,200건을 묶어 한 번만 발신된다.', '대량 경로에서 시그널이 하나로 합쳐진다는 오해. 합쳐지는 것이 아니라 발신 자체가 일어나지 않는다.', false),
(9697, 3570, '(B)에서도 행마다 post_save가 발신되지만 created가 False라 차감이 건너뛰어진다.', 'created 플래그와 시그널 발신 여부를 혼동한 것. bulk_create 경로는 수신자를 호출하지 않으므로 created 값을 따질 단계까지 가지도 않는다.', false),
(9698, 3570, '(A)와 (B) 모두 정상 차감되며, 다만 (B)는 배치가 끝난 뒤 한꺼번에 반영된다.', '시그널이 큐에 쌓였다가 나중에 처리된다는 오해. 시그널 발신은 등록된 수신자를 그 자리에서 부르는 동기 함수 호출이라 지연 반영이라는 개념이 없다.', false),

-- 문제 3571
(9699, 3571, 'post_save가 수신자마다 별도 스레드로 실행돼 두 수신자가 같은 주문을 동시에 건드린 경쟁 상태다.', '수신자는 발신자와 같은 스레드에서 하나씩 차례로 호출된다. 동시 실행이 없으니 경쟁 상태가 생길 자리도 없다.', false),
(9700, 3571, 'make_invoice가 예외를 삼키도록 작성돼 테스트에서만 청구서 생성이 조용히 실패한 것이다.', '본문의 make_invoice에는 예외를 삼키는 코드가 없다. 정말 그런 결함이라면 설정이 다를 뿐 같은 코드인 운영에서도 똑같이 청구서가 없어야 한다.', false),
(9701, 3571, '같은 sender에 붙은 수신자는 마지막 등록분만 남으므로 make_invoice가 처음부터 연결되지 않았다.', '수신자는 덮어쓰이지 않고 목록에 쌓여 모두 호출된다. 그 주장대로면 운영에서도 청구서가 없어야 하는데 운영은 정상이라 앞뒤가 맞지 않는다.', false),
(9702, 3571, '테스트 설정에서 analytics가 billing보다 먼저 등록돼, 청구서가 만들어지기 전에 record_revenue가 돌았다.', '수신자는 등록(임포트)된 순서대로 호출되고 그 순서는 INSTALLED_APPS 배치를 따른다. 수신자 사이의 순서 의존은 코드 어디에도 적히지 않아 설정만 바뀌어도 조용히 깨진다.', true),

-- 문제 3572
(9703, 3572, 'post_save 수신자와 save() 오버라이드는 QuerySet.update() 경로에서 똑같이 우회된다.', '표의 둘째 열에서 두 방식 모두 실행 안 됨이다. update()는 SQL UPDATE를 직접 보내 모델 인스턴스의 저장 절차를 거치지 않기 때문이다.', false),
(9704, 3572, 'on_commit()으로 등록한 작업은 롤백돼도 그대로 실행되므로 유령 알림을 막지 못한다.', '표의 마지막 열에서 on_commit만 실행되지 않음으로 적혀 있다. 커밋이 실제로 끝난 뒤에만 콜백을 돌리므로 롤백되면 콜백은 버려진다. 유령 알림을 막는 유일한 칸이다.', true),
(9705, 3572, '롤백된 주문에 알림이 나가는 것을 막고 싶다면 네 방식 중 on_commit 등록만이 조건을 만족한다.', '마지막 열에서 실행되지 않음이 적힌 줄은 on_commit 하나뿐이라 표에서 곧바로 따라 나온다. 나머지 셋은 롤백 전에 이미 나간 뒤다.', false),
(9706, 3572, '서비스 함수 안 명시 호출은 그 함수를 거치지 않은 저장 경로를 막아 주지 못한다.', '표의 첫째 열이 그 함수를 거친 경우만 실행됨이라고 못 박는다. 다른 코드가 서비스 함수를 건너뛰고 save()를 직접 부르면 알림은 나가지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1146, 3573, 'dispatch_uid,dispatch uid,디스패치 uid,디스패치 유아이디', '같은 모듈이 두 경로로 임포트되면 함수 객체가 새로 만들어지고, Signal.connect는 이를 서로 다른 수신자로 보아 둘 다 등록한다. 그래서 save() 한 번에 푸시가 두 번 나간 것이다. @receiver(post_save, sender=Order, dispatch_uid="orders.notify_on_create")처럼 문자열 키를 주면 같은 키로는 한 번만 등록돼 중복이 사라진다. 수신자를 약한 참조로 잡을지 정하는 weak 인자나, 예외를 삼켜 반환값으로 돌려주는 send_robust()는 중복 등록과 아무 상관이 없으니 구분해 두자. 등록 지점을 AppConfig.ready() 한 곳으로 모으는 것도 함께 지켜야 할 규칙이다.'),
       (1147, 3574, 'on_commit,transaction.on_commit,django.db.transaction.on_commit,온커밋', 'post_save는 커밋 시점이 아니라 INSERT 문이 실행된 시점에 발신된다. atomic 블록 안이라면 아직 커밋 전이라, 뒤에서 결제가 실패해 롤백되어도 알림은 이미 나간 뒤다. 롤백된 180건에 알림이 나가 문의 173건이 쌓인 이유가 이것이다. transaction.on_commit(lambda: send_push(order.user_id))로 등록하면 콜백이 커밋 성공 이후로 미뤄지고, 롤백되면 콜백은 실행되지 않고 버려진다. 블록 전체를 하나의 원자 단위로 묶는 atomic이나, 부분 취소 지점을 찍는 savepoint와는 역할이 다르다는 점을 함께 정리해 두자.');

-- =====================================================
-- Lesson 723: 발생 경로와 m2m_changed·raw
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4517, 723, '아래 코드에서 뷰 함수가 한 번 실행될 때 콘솔에 찍히는 순서는?', '두 수신자는 `AppConfig.ready()`에서 임포트되어 한 번씩 등록돼 있다.

```python
# orders/models.py
class Order(models.Model):
    total = models.IntegerField()

    def save(self, *args, **kwargs):
        print("A")
        super().save(*args, **kwargs)
        print("B")


# orders/signals.py
@receiver(pre_save, sender=Order, dispatch_uid="orders.before_save")
def before_save(sender, instance, **kwargs):
    print("C")


@receiver(post_save, sender=Order, dispatch_uid="orders.after_save")
def after_save(sender, instance, created, **kwargs):
    print("D")


# orders/views.py
def place_order(request):
    print("E")
    Order.objects.create(total=500)
    print("F")
    return HttpResponse("ok")
```', 'OBJECTIVE'),
       (4518, 723, '아래 코드를 차례로 모두 실행한 뒤 AuditLog 테이블에 새로 쌓인 행의 개수는?', '```python
# audit/signals.py  (AppConfig.ready()에서 등록)
@receiver(post_save, sender=Product, dispatch_uid="audit.log_save")
def log_save(sender, instance, **kwargs):
    AuditLog.objects.create(object_id=instance.pk, action="save")


@receiver(post_delete, sender=Product, dispatch_uid="audit.log_delete")
def log_delete(sender, instance, **kwargs):
    AuditLog.objects.create(object_id=instance.pk, action="delete")
```

```python
# (1) 상품 1개의 가격 수정
p = Product.objects.get(pk=7)
p.price = 990
p.save(update_fields=["price"])

# (2) 단종 상품 비활성화 - 조건에 맞는 행 30개
Product.objects.filter(discontinued=True).update(is_active=False)

# (3) 할인가 일괄 반영 - 미리 불러 둔 Product 객체 50개
Product.objects.bulk_update(items, ["price"])

# (4) 재고가 0인 상품 삭제 - 조건에 맞는 행 12개
Product.objects.filter(stock=0).delete()
```

네 단계의 대상 행은 서로 겹치지 않고, `Product`를 참조하는 다른 모델은 없다. 모든 문장은 예외 없이 끝났다.', 'OBJECTIVE'),
       (4519, 723, '아래 오류를 없애는 수정으로 옳은 것은?', '글을 저장할 때 제목으로 slug를 채우려고 아래 수신자를 추가했다. 그 뒤로 글 작성 API가 매번 500을 반환한다.

```python
# blog/signals.py
@receiver(post_save, sender=Article)
def fill_slug(sender, instance, **kwargs):
    instance.slug = slugify(instance.title)
    instance.save()
```

```
Traceback (most recent call last):
  File "blog/views.py", line 21, in create_article
    article.save()
  File "django/db/models/base.py", line 822, in save
    self.save_base(using=using, force_insert=force_insert, ...)
  File "django/db/models/base.py", line 895, in save_base
    post_save.send(sender=origin, instance=self, ...)
  File "django/dispatch/dispatcher.py", line 176, in send
    response = receiver(signal=self, sender=sender, **named)
  File "blog/signals.py", line 5, in fill_slug
    instance.save()
  File "django/db/models/base.py", line 822, in save
    self.save_base(using=using, force_insert=force_insert, ...)
  File "django/db/models/base.py", line 895, in save_base
    post_save.send(sender=origin, instance=self, ...)
  File "django/dispatch/dispatcher.py", line 176, in send
    response = receiver(signal=self, sender=sender, **named)
  File "blog/signals.py", line 5, in fill_slug
    instance.save()
  ... (위 여덟 줄이 수백 번 반복) ...
RecursionError: maximum recursion depth exceeded
```', 'OBJECTIVE'),
       (4520, 723, '아래 요구 사항을 구현하는 방식에 대한 설명으로 옳은 것은?', '사내 공통 패키지 `audit-trail`을 만들고 있다. 서비스 팀은 이 패키지를 `INSTALLED_APPS`에 추가하기만 하면, 자기 프로젝트의 어떤 모델이 저장되거나 삭제되든 변경 이력이 남기를 원한다.

- 패키지 팀은 각 서비스의 모델·뷰·서비스 함수 코드를 볼 수도, 고칠 수도 없다.
- 서비스 팀에 코드 수정을 요청하지 않는 것이 도입 조건이다.
- 이력은 운영 감사용 참고 자료이며, 대량 수정 경로에서 이력이 빠질 수 있다는 점은 문서로 안내하기로 합의했다.', 'OBJECTIVE'),
       (4521, 723, '아래 상황에서 검색 결과가 다시 맞도록 수신자를 새로 연결해야 하는 시그널의 이름은?', '```python
# search/signals.py  (AppConfig.ready()에서 등록)
@receiver(post_save, sender=Post, dispatch_uid="search.reindex_post")
def reindex_post(sender, instance, **kwargs):
    search_index.upsert(
        instance.id,
        title=instance.title,
        tags=[t.name for t in instance.tags.all()],
    )
```

```python
# posts/views.py - 글 편집 화면에서 태그만 바꿀 때 실행되는 코드
post = Post.objects.get(pk=42)
post.tags.add(django_tag, orm_tag)
post.tags.remove(legacy_tag)
```

편집 직후 DB의 `posts_post_tags` 테이블에는 새 태그 두 개가 들어가 있고 `legacy_tag` 행은 지워져 있다. 그런데 검색에서 `django` 태그로 찾으면 42번 글이 나오지 않고, 제목을 한 글자 고쳐 저장하면 그제야 검색에 잡힌다. 로그에는 태그를 편집한 시점에 `reindex_post`가 실행된 기록이 없다.', 'SUBJECTIVE'),
       (4522, 723, '아래 사고가 다시 생기지 않도록 수신자가 먼저 확인해야 하는 인자의 이름은?', '새 스테이징 서버에 운영 회원 데이터를 담은 fixture를 넣었다.

```
$ python manage.py loaddata users.json
Installed 850 object(s) from 1 fixture(s)
```

```python
# accounts/signals.py  (AppConfig.ready()에서 등록)
@receiver(post_save, sender=User, dispatch_uid="accounts.welcome_mail")
def send_welcome_mail(sender, instance, created, **kwargs):
    if created:
        mailer.send(instance.email, template="welcome")
```

명령이 끝나자 메일 발송 로그에 가입 환영 메일 850건이 찍혔고, 이미 몇 년 전에 가입한 실제 회원들에게서 "왜 이제 와서 가입 환영 메일이 오느냐"는 문의가 들어왔다. 회원가입 API로 새 회원이 생길 때는 지금처럼 메일이 나가야 한다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4517
(12219, 4517, 'E → C → A → B → D → F', '시그널이 오버라이드한 save() 호출 바깥을 감싼다고 본 오해다. pre_save·post_save는 super().save()가 부르는 save_base() 안에서 발신되므로 A보다 뒤, B보다 앞에 찍힌다.', false),
(12220, 4517, 'E → A → B → F → C → D', '수신자를 요청이 끝난 뒤 따로 처리되는 비동기 이벤트로 본 오해다. 수신자는 발신자와 같은 스레드에서 그 자리에서 호출되므로 create()가 반환되기 전, 곧 F보다 먼저 모두 끝난다.', false),
(12221, 4517, 'E → A → C → D → B → F', 'create()가 오버라이드한 save()를 불러 A가 찍히고, super().save() 안에서 INSERT 전에 pre_save(C), INSERT 직후 post_save(D)가 동기로 발신된다. 수신자가 끝나야 super().save()가 돌아와 B, 뷰로 돌아와 F가 찍힌다.', true),
(12222, 4517, 'E → A → C → B → D → F', 'post_save를 save() 메서드가 끝난 뒤 발신되는 것으로 본 오해다. post_save는 super().save() 안에서 INSERT 직후 발신되므로, 오버라이드의 뒷부분인 B보다 먼저 실행된다.', false),

-- 문제 4518
(12223, 4518, '1', 'QuerySet.delete()도 update()처럼 SQL 한 번으로 끝나 시그널을 건너뛴다고 본 오해다. post_delete 수신자가 걸려 있으면 Django는 지울 객체를 먼저 불러온 뒤 객체마다 post_delete를 발신한다.', false),
(12224, 4518, '13', '(1)의 save()에서 post_save 1번, (4)의 QuerySet.delete()에서 지운 객체마다 post_delete 12번이 발신된다. update()와 bulk_update()는 SQL UPDATE를 직접 보내 시그널이 없으므로 1 + 12 = 13이다.', true),
(12225, 4518, '63', 'bulk_update()가 Product 객체 목록을 받으니 객체마다 save()를 부른다고 본 오해다. bulk_update()는 CASE WHEN으로 묶은 UPDATE 문을 직접 보내는 경로라 post_save가 발신되지 않는다.', false),
(12226, 4518, '93', 'ORM으로 바꾸거나 지우면 어떤 경로든 시그널이 발생한다고 본 오해다. update()·bulk_update()는 인스턴스의 save()를 거치지 않아, (2)의 30개와 (3)의 50개 행에서는 수신자가 한 번도 실행되지 않는다.', false),

-- 문제 4519
(12227, 4519, '@receiver에 dispatch_uid를 지정해 같은 수신자가 두 번 등록되지 않게 한다.', '중복 등록과 재귀를 혼동한 오해다. 수신자가 한 번만 등록돼 있어도 그 안의 save()가 다시 post_save를 발신하므로, 호출이 자기 자신으로 계속 되돌아오는 구조는 그대로다.', false),
(12228, 4519, '수신자 안의 저장을 instance.save(update_fields=["slug"])로 바꿔 slug 컬럼만 쓴다.', 'update_fields를 주면 시그널이 생략된다고 본 오해다. update_fields는 저장할 컬럼만 줄일 뿐 여전히 save() 경로라 post_save가 발신되고, 그 값이 update_fields 인자로 전달될 뿐이다.', false),
(12229, 4519, '수신자를 pre_save에 연결하도록 바꾸고, 안의 instance.save() 호출은 그대로 둔다.', 'INSERT 전에 돌면 재귀가 생기지 않는다고 본 오해다. pre_save 수신자 안에서 save()를 부르면 그 save()가 다시 pre_save를 발신해 똑같이 끝없이 되돌아온다.', false),
(12230, 4519, '수신자를 지우고, Article.save()를 오버라이드해 super().save() 전에 slug를 채운다.', 'slug는 모델 스스로 지켜야 할 값이라 save() 오버라이드가 알맞은 자리다. super().save() 전에 값을 넣으면 한 번의 저장에 slug가 함께 담기고, save()를 다시 부르지 않으니 시그널이 되풀이 발신되지 않는다.', true),

-- 문제 4520
(12231, 4520, 'post_save·post_delete 수신자를 패키지 안에서 등록해 서비스의 저장·삭제에 끼어드는 방식이 알맞다.', '패키지는 서비스의 모델 코드를 소유하지 않으므로, Django 코드 안에서 모델 변경에 반응할 훅은 사실상 시그널뿐이다. 재사용 패키지가 사용자 프로젝트의 저장에 끼어드는 경우는 시그널이 제 역할을 하는 대표 사례다.', true),
(12232, 4520, '호출 흐름이 드러나도록 각 서비스 함수가 기록 함수를 직접 부르게 하는 방식이 알맞다.', '보통은 권장되는 대안이지만 이 요구에는 맞지 않는다. 서비스 함수마다 호출을 넣으려면 서비스 팀 코드를 고쳐야 하는데, 본문은 패키지 팀이 코드를 고칠 수 없고 수정 요청도 하지 않는 것을 조건으로 둔다.', false),
(12233, 4520, '모델 save() 오버라이드는 QuerySet.update() 경로까지 잡으므로 시그널보다 이력 누락이 적다.', 'save() 오버라이드도 update()·bulk_create()처럼 save()를 거치지 않는 경로에서는 실행되지 않는다. 게다가 오버라이드는 모델 클래스 안에 써야 해서 패키지가 남의 모델에 끼울 수도 없다.', false),
(12234, 4520, 'transaction.on_commit()에 기록 함수를 한 번 걸어 두면 이후 모든 모델의 커밋마다 호출된다.', 'on_commit()은 지금 열린 트랜잭션이 커밋될 때 콜백을 한 번 실행하도록 등록하는 API일 뿐, 모델 저장을 가로채지 않는다. 저장할 때마다 코드에서 직접 불러야 하니 결국 서비스 코드를 고쳐야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1462, 4521, 'm2m_changed,m2m changed,m2mchanged,signals.m2m_changed,models.signals.m2m_changed,django.db.models.signals.m2m_changed', 'tags는 다대다 필드라 add()·remove()는 Post 인스턴스의 save()를 거치지 않고 중간 테이블(posts_post_tags)에 행을 직접 넣고 지운다. 그래서 post_save에 연결된 reindex_post는 불리지 않았고, 제목을 고쳐 save()를 부른 뒤에야 색인이 갱신된 것이다. 다대다 관계가 add·remove·clear로 바뀔 때는 m2m_changed가 발신되므로, @receiver(m2m_changed, sender=Post.tags.through)로 연결하고 action이 post_add·post_remove·post_clear일 때 색인을 다시 쓰면 된다. post_add·post_remove는 m2m_changed가 넘겨주는 action 값이지 시그널 이름이 아니고, pre_save·post_save는 Post 행 자체의 저장에만 반응한다는 점을 구분해 두자.'),
       (1463, 4522, 'raw,raw 인자,raw 인수,raw=True,raw 플래그,kwargs["raw"],kwargs.get("raw")', 'loaddata는 모델의 save()를 부르지는 않지만 save_base()를 raw=True로 불러 pre_save·post_save를 그대로 발신한다. 빈 DB에 새로 들어가는 행이라 created도 True로 넘어오므로, created만 보는 수신자는 fixture 로딩과 실제 가입을 구분하지 못해 850명 모두에게 메일을 보냈다. fixture 로딩 중에는 raw 인자가 True로 넘어오니, 수신자 맨 앞에서 if kwargs.get("raw"): return으로 건너뛰면 회원가입 API 경로(raw=False)의 메일은 그대로 나간다. 새로 INSERT됐는지를 알려 주는 created, 이번 저장에서 쓴 컬럼 목록인 update_fields와는 역할이 다르니 구분해 두자.');

-- =====================================================
-- Lesson 881: Django 시그널이 숨기는 비용과 명시적 대안
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5465, 881, '아래 삭제 작업의 지표가 9월 16일부터 달라진 원인으로 옳은 것은?', '매일 새벽 3시에 90일이 지난 접근 로그를 지우는 작업이다. `AccessLog`를 외래 키로 참조하는 모델은 없다.

```python
# jobs/purge_logs.py
AccessLog.objects.filter(created_at__lt=cutoff).delete()
```

9월 15일 오후, 다른 팀이 아래 수신자를 추가해 배포했다. 그 밖에 데이터 양·인덱스·DB 설정·작업 코드는 바뀌지 않았다.

```python
# audit/signals.py  (AppConfig.ready()에서 등록)
@receiver(post_delete, sender=AccessLog, dispatch_uid="audit.count_purged")
def count_purged(sender, instance, **kwargs):
    metrics.incr("access_log.purged")
```

| 실행일 | 삭제 행 수 | 실행 시간 | 최대 메모리 |
| --- | --- | --- | --- |
| 09-14 | 2,400,112 | 41초 | 58MB |
| 09-15 | 2,398,530 | 39초 | 61MB |
| 09-16 | 2,401,877 | 52분 | 7.9GB |', 'OBJECTIVE'),
       (5466, 881, '아래 이벤트 발행 방식에 대한 설명으로 옳은 것은?', '여러 앱이 주문 생성에 반응해야 해서, 시그널 대신 아래 이벤트 발행 함수를 두었다. DB는 PostgreSQL이라 `bulk_create()` 뒤 각 객체에 id가 채워진다.

```python
# core/events.py
HANDLERS = {
    OrderPlaced: [reserve_stock, send_confirm_mail, update_daily_stats],
}


def publish(event):
    for handler in HANDLERS[type(event)]:
        handler(event)


# orders/services.py - 장바구니 여러 개를 한 번에 결제
def place_orders(user, carts):
    with transaction.atomic():
        orders = Order.objects.bulk_create(
            [Order(user=user, total=c.total) for c in carts]
        )
        charge(user, sum(o.total for o in orders))  # 결제 실패 시 PaymentError
    for order in orders:
        publish(OrderPlaced(order_id=order.id))
    return orders
```', 'OBJECTIVE'),
       (5467, 881, '아래 코드와 타임라인에서 요청 A가 커밋된 뒤 상품 조회 API의 응답으로 옳은 것은?', 'DB는 PostgreSQL(격리 수준은 기본값 READ COMMITTED)이고, 캐시는 모든 서버가 함께 쓰는 Redis다.

```python
# catalog/signals.py  (AppConfig.ready()에서 등록)
@receiver(post_save, sender=Product, dispatch_uid="catalog.evict_cache")
def evict_cache(sender, instance, **kwargs):
    cache.delete(f"product:{instance.pk}")


# catalog/views.py - 고객용 상품 조회
def product_detail(request, pk):
    data = cache.get(f"product:{pk}")
    if data is None:
        data = serialize(Product.objects.get(pk=pk))
        cache.set(f"product:{pk}", data, timeout=3600)
    return JsonResponse(data)


# backoffice/services.py - 관리자 가격 변경
def change_price(product, new_price):
    with transaction.atomic():
        product.price = new_price
        product.save(update_fields=["price"])
        sync_erp(product)  # 외부 ERP 호출, 약 2초
```

| 시각 | 요청 A: 관리자가 가격을 10,000원에서 12,000원으로 변경 | 요청 B: 고객이 같은 상품을 조회 |
| --- | --- | --- |
| 0.0초 | `change_price` 호출, `save()` 반환 | |
| 0.5초 | `sync_erp` 응답 대기 중 | `product_detail` 호출, 응답 완료 |
| 2.0초 | `atomic` 블록을 빠져나오며 커밋 | |

이후 1시간 동안 이 상품의 가격을 바꾸는 요청은 없다.', 'OBJECTIVE'),
       (5468, 881, '아래 리팩터링 이력에 대한 설명으로 옳은 것은?', '주문 앱(`orders`)이 알림 앱(`notifications`)을 직접 부르지 않게 하려고, 주문 접수 알림을 보내던 호출을 지우고 아래 수신자를 `notifications` 쪽에 두었다. 이 변경 뒤 `orders` 코드에는 `notifications`를 임포트하는 줄이 하나도 없다.

```python
# notifications/signals.py  (AppConfig.ready()에서 등록)
@receiver(post_save, sender=Order, dispatch_uid="notifications.order_received")
def notify_received(sender, instance, created, **kwargs):
    if created:
        send_push(instance.user_id, template="order_received")
```

반년 뒤 `orders` 팀은 장바구니 저장 기능을 만들면서 흐름을 아래처럼 바꿨다. `orders` 앱의 테스트와 코드 리뷰는 모두 통과했다.

- 변경 전: 결제가 끝나는 순간 `Order` 행을 처음 만든다.
- 변경 후: 상품을 장바구니에 담는 순간 `status="CART"`인 `Order` 행을 만들고, 결제가 끝나면 같은 행의 `status`만 `"PAID"`로 바꿔 `save()`한다.', 'OBJECTIVE'),
       (5469, 881, '아래 변경 후 코드의 빈칸(____)에 들어갈 이름은?', '결제가 끝나면 외부 업체가 만든 플러그인 앱들이 반응하도록 커스텀 시그널 `order_paid`를 두었다. 수신자는 `coupon_plugin`, `receipt_plugin` 순서로 등록돼 있다.

변경 전 코드와 로그:

```python
# payments/services.py
def complete_payment(order):
    order.status = "PAID"
    order.save(update_fields=["status"])
    order_paid.send(sender=Order, order=order)
```

```
[10:02:11] ERROR  POST /payments/complete -> 500
  File "coupon_plugin/signals.py", line 8, in issue_coupon
KeyError: ''coupon_code''
[10:02:11] (receipt_plugin 로그 없음)
```

발신하는 줄을 아래처럼 바꾸고 결과를 로그로 남기게 했다. 플러그인 코드는 그대로다.

```python
# payments/services.py
def complete_payment(order):
    order.status = "PAID"
    order.save(update_fields=["status"])
    results = order_paid.____(sender=Order, order=order)
    for receiver, result in results:
        if isinstance(result, Exception):
            logger.warning("plugin failed: %s %r", receiver.__name__, result)
```

```
[10:05:40] INFO   receipt_plugin: receipt #8812 issued
[10:05:40] WARN   plugin failed: issue_coupon KeyError(''coupon_code'')
[10:05:40] INFO   POST /payments/complete -> 200
```', 'SUBJECTIVE'),
       (5470, 881, '아래 쿼리 로그에서 드러난 성능 문제를 흔히 부르는 이름은?', '매일 밤 결제 대기 주문을 확정하는 스크립트다. 스크립트 코드에는 고객(`customer`)을 읽는 줄이 없다.

```python
# jobs/confirm_orders.py
for order in Order.objects.filter(status="PENDING"):  # 오늘 2,000건
    order.status = "CONFIRMED"
    order.save(update_fields=["status"])
```

그런데 쿼리 추적 도구로 본 로그는 아래와 같았고, 스크립트는 예상보다 몇 배 오래 걸렸다.

```
SELECT ... FROM orders WHERE status = ''PENDING''
UPDATE orders SET status = ''CONFIRMED'' WHERE id = 1
SELECT ... FROM customers WHERE id = 381     <- loyalty/signals.py: check_vip
UPDATE orders SET status = ''CONFIRMED'' WHERE id = 2
SELECT ... FROM customers WHERE id = 77      <- loyalty/signals.py: check_vip
... (주문마다 같은 두 줄이 반복)

합계: orders 조회 1회 / UPDATE 2,000회 / customers 조회 2,000회
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5465
(14747, 5465, '수신자 호출이 메시지 큐로 넘어가면서, 작업이 큐에 쌓인 240만 건이 모두 처리될 때까지 기다렸다.', '시그널을 메시지 큐로 본 오해다. 수신자는 발신한 코드와 같은 스레드에서 그 자리에서 불리는 함수라 큐에 쌓이는 단계가 없다. 큐 대기로는 최대 메모리가 7.9GB로 뛴 것도 설명되지 않는다.', false),
(14748, 5465, '수신자가 생기자 DELETE 한 번으로 끝내던 경로 대신, 대상 행을 모두 객체로 불러와 객체마다 수신자를 부르며 지웠다.', '삭제 시그널 수신자도, 참조하는 모델도 없으면 Django는 행을 불러오지 않고 DELETE 한 번으로 지운다(fast delete). post_delete 수신자가 붙으면 객체마다 시그널을 보내야 해서 240만 행을 메모리에 올린 뒤 나눠 지운다.', true),
(14749, 5465, 'DELETE 문이 끝난 뒤 post_delete가 한 번만 발신되며, 지운 240만 행을 목록 하나에 담아 수신자에 넘겼다.', 'post_delete는 묶음 단위로 한 번 발신되는 게 아니라 지운 객체마다 한 번씩 발신되고, 수신자는 instance 하나만 받는다. 수신자 코드의 instance 인자가 그 증거다.', false),
(14750, 5465, 'QuerySet.delete()는 원래도 행을 객체로 불러와 지웠고, 느려진 것은 수신자 안의 metrics 호출이 더해졌기 때문이다.', '수신자가 없던 9월 14·15일의 최대 메모리가 58~61MB인 것이 행을 객체로 불러오지 않았다는 증거다. 호출 비용만 늘었다면 메모리가 7.9GB까지 뛸 이유가 없다.', false),

-- 문제 5466
(14751, 5466, 'publish()가 핸들러를 별도 워커로 넘기므로, 핸들러가 느려도 place_orders의 응답 시간은 늘지 않는다.', 'publish()는 목록을 돌며 핸들러를 그 자리에서 차례로 부르는 반복문일 뿐이다. 워커나 큐가 없으니 핸들러 실행 시간이 그대로 place_orders에 더해진다.', false),
(14752, 5466, 'PaymentError로 atomic 블록이 롤백되어도, 그 전에 publish()가 불려 확인 메일이 나갈 수 있다.', 'publish() 호출은 with 블록 밖, 커밋이 끝난 뒤에 있다. charge()가 PaymentError를 내면 블록이 롤백되고 예외가 그대로 올라가 반복문에 닿지 않으므로 메일은 나가지 않는다.', false),
(14753, 5466, '주문을 bulk_create()로 넣었어도, 커밋 뒤 반복문이 주문마다 publish()를 부르므로 세 핸들러가 빠짐없이 불린다.', 'bulk_create()는 post_save를 발신하지 않지만, 이 코드는 저장 시그널에 기대지 않고 커밋 뒤 주문마다 publish()를 직접 부른다. 핸들러 실행이 저장 방식과 분리돼 있어 대량 저장 경로에서도 빠지지 않는다.', true),
(14754, 5466, '핸들러 하나가 예외를 내도 publish()가 이를 잡아 두므로, 나머지 핸들러는 계속 실행된다.', 'publish()에는 예외를 잡는 코드가 없다. 앞 핸들러가 예외를 내면 반복문이 그 자리에서 멈추고 예외가 place_orders로 올라가, 뒤 핸들러는 불리지 않는다.', false),

-- 문제 5467
(14755, 5467, 'B가 캐시에 넣은 10,000원이 남아, 커밋 뒤에도 약 1시간 동안 10,000원이 응답된다.', 'post_save는 커밋이 아니라 UPDATE 직후인 0.0초에 발신돼 캐시가 그때 지워진다. 0.5초의 B는 빈 캐시 때문에 DB를 읽는데 아직 커밋 전이라 10,000원을 보고 1시간짜리 캐시로 채운다. 커밋 뒤 이를 지울 코드는 없다.', true),
(14756, 5467, 'post_save가 커밋 시점에 발신돼 2.0초에 캐시가 지워지므로, 그 뒤 조회부터 12,000원이 응답된다.', 'post_save를 커밋 뒤 신호로 본 오해다. 수신자는 save()가 UPDATE를 실행한 직후, atomic 블록이 아직 열린 0.0초에 돈다. 커밋 뒤로 미루려면 transaction.on_commit()으로 등록해야 한다.', false),
(14757, 5467, 'B의 조회가 A의 커밋까지 기다렸다가 12,000원을 읽어 캐시에 넣으므로, 12,000원이 응답된다.', 'READ COMMITTED에서 일반 SELECT는 다른 트랜잭션이 고치는 중인 행을 기다리지 않고, 마지막으로 커밋된 값인 10,000원을 곧바로 읽는다. 쓰기 잠금이 읽기까지 막는다고 본 오해다.', false),
(14758, 5467, '커밋 시점에 evict_cache가 한 번 더 실행돼 캐시가 비워지므로, 커밋 뒤 조회부터 12,000원이 응답된다.', '커밋이 시그널을 다시 발신한다고 본 오해다. post_save는 save() 한 번에 한 번만 발신되고 커밋과는 연결돼 있지 않다. 그래서 B가 옛값으로 채운 캐시를 커밋 뒤에 지워 줄 코드가 없다.', false),

-- 문제 5468
(14759, 5468, 'orders가 notifications를 임포트하지 않으므로 두 앱은 결합돼 있지 않고, 장바구니 기능은 알림 동작에 영향을 주지 않는다.', '임포트가 없어진 것을 결합이 없어진 것으로 본 오해다. 수신자는 Order 행이 언제 처음 INSERT되는지에 기대고 있어, orders가 행을 만드는 시점을 바꾸면 알림이 나가는 시점도 함께 바뀐다.', false),
(14760, 5468, '결제 때 status를 바꾸는 save()에서 created가 True로 넘어오므로, 접수 알림은 전처럼 결제 시점에 나간다.', 'created는 그 save()가 INSERT였는지를 알려 준다. 장바구니 단계에서 이미 행이 생겼으므로 결제 때의 save()는 UPDATE이고 created는 False다. 결제 시점에는 접수 알림이 나가지 않는다.', false),
(14761, 5468, 'notifications가 Order를 임포트하고 있으므로, orders 팀은 흐름을 바꿀 때 이 수신자를 자연히 확인하게 된다.', '의존은 notifications에서 orders로만 향한다. orders 코드에는 수신자를 가리키는 흔적이 없어, 전체 코드에서 post_save 수신자를 검색하지 않으면 찾을 수 없다. 테스트와 리뷰가 통과한 것이 그 결과다.', false),
(14762, 5468, '결합은 방향만 바뀌어 notifications가 orders의 저장 시점에 묶여 있고, 이제 장바구니에 담기만 해도 접수 알림이 나간다.', '장바구니 단계에서 Order가 처음 INSERT되므로 그때 created=True로 수신자가 돌아 접수 알림이 나간다. 앱 간 결합은 줄어든 게 아니라 방향만 바뀌어, orders 코드에서는 보이지 않는 의존이 된 것이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1778, 5469, 'send_robust,send_robust(),order_paid.send_robust,order_paid.send_robust(),Signal.send_robust,Signal.send_robust(),send robust,sendrobust,센드 로버스트,센드로버스트', 'send()는 등록된 수신자를 차례로 부르다가 예외가 나면 그 자리에서 멈추고 예외를 호출부로 그대로 전파한다. 그래서 변경 전에는 issue_coupon의 KeyError가 요청을 500으로 만들었고, 뒤에 등록된 receipt_plugin은 불리지도 않았다. send_robust()는 수신자마다 예외를 잡아 그 예외 객체를 (수신자, 결과) 목록의 결과 자리에 담고 다음 수신자로 넘어가므로, 영수증은 발급되고 요청은 200으로 끝난다. send() 호출을 try/except로 감싸는 것만으로는 500은 막아도 멈춘 뒤의 수신자는 여전히 불리지 않으니 구분해 두자. 중복 등록을 막는 dispatch_uid, 커밋 뒤로 실행을 미루는 transaction.on_commit()과도 역할이 다르다. 또 post_save 같은 모델 시그널은 Django가 send()로 발신하므로, 이 선택은 직접 발신하는 커스텀 시그널에서만 할 수 있다.'),
       (1779, 5470, 'N+1,N+1 문제,N+1문제,N+1 쿼리,N+1 쿼리 문제,N+1 query,N+1 problem,N+1 query problem,N+1 select,N + 1,N + 1 문제', '스크립트의 반복문은 customer를 한 번도 읽지 않지만, save()마다 동기로 도는 loyalty 앱의 수신자 check_vip가 instance.customer에 접근한다. 주문을 불러올 때 고객은 함께 가져오지 않았으므로 접근할 때마다 customers 조회가 한 번씩 나가, 목록 조회 1번에 대상 수(N)만큼 조회가 더 붙는 N+1 문제가 된다. 쿼리가 스크립트가 아니라 수신자에서 나오기 때문에 호출부만 봐서는 원인을 찾기 어렵다는 점이 시그널이 성능 비용을 숨기는 전형적인 모습이다. 조회 쿼리셋에 select_related("customer")를 붙이면 고객이 JOIN으로 함께 와서 추가 조회가 사라진다. 지연 로딩(lazy loading)은 이 문제를 일으키는 동작 방식일 뿐 문제의 이름이 아니고, 한 번의 쿼리로 테이블 전체를 훑는 풀 스캔과도 다르니 구분해 두자.');
