-- Unit: 마이그레이션 (Unit ID: 136)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (562, 136, '무중단 스키마 변경과 sqlmigrate'),
       (720, 136, 'DDL 부분 적용과 이력 병합·압축'),
       (878, 136, '운영 배포에서 겪는 마이그레이션 사고와 대응');

-- =====================================================
-- Lesson 562: 무중단 스키마 변경과 sqlmigrate
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3551, 562, '아래 두 명령의 출력에 대한 해석으로 옳은 것은?', '```
$ python manage.py showmigrations orders
orders
 [X] 0010_add_status
 [X] 0011_previous
 [ ] 0012_order_created_idx

$ python manage.py makemigrations --check --dry-run
Migrations for ''orders'':
  orders/migrations/0013_order_memo.py
    - Add field memo to order
$ echo $?
1
```', 'OBJECTIVE'),
       (3552, 562, '아래 마이그레이션 파일을 운영 PostgreSQL에 적용할 때에 대한 설명으로 옳은 것은?', '```python
from django.contrib.postgres.operations import AddIndexConcurrently
from django.db import migrations, models


class Migration(migrations.Migration):
    atomic = False
    dependencies = [("orders", "0011_previous")]
    operations = [
        AddIndexConcurrently(
            model_name="order",
            index=models.Index(fields=["created_at"], name="order_created_idx"),
        ),
    ]
```', 'OBJECTIVE'),
       (3553, 562, '아래 표의 스키마 변경을 롤링 배포 중에 적용하는 절차로 옳지 않은 것은?', '| 변경 | DB 락·비용 | 구버전 코드와 호환 |
|---|---|---|
| nullable 컬럼 추가 | 낮음 | 호환 |
| 컬럼 삭제 | 낮음 | 비호환 |
| 컬럼 이름 변경 | 낮음 | 비호환 |
| 타입 변경 | 대부분 테이블 재작성 | 상황에 따라 다름 |

\* 롤링 배포 구간에서는 구버전 코드와 신버전 코드가 같은 DB를 동시에 사용한다.', 'OBJECTIVE'),
       (3554, 562, '아래 데이터 마이그레이션 파일에서 생길 수 있는 문제로 옳은 것은?', '```python
# accounts/migrations/0013_backfill_display_name.py
from accounts.models import User
from django.db import migrations


def backfill_display_name(apps, schema_editor):
    for user in User.objects.filter(display_name=""):
        user.display_name = user.username
        user.save()


class Migration(migrations.Migration):
    dependencies = [("accounts", "0012_user_display_name")]
    operations = [migrations.RunPython(backfill_display_name)]
```

*(같은 앱에는 0013 이후로도 마이그레이션 파일이 계속 쌓여 있고, 테스트 DB는 0001부터 전부 재생한다.)*', 'OBJECTIVE'),
       (3555, 562, '아래 두 컬럼의 차이를 만든, channel 선언에만 쓰인 CharField 인자의 이름은?', E'Django 5.0 프로젝트에서 두 컬럼을 모두 "기본값이 있는 컬럼"으로 추가했는데, 마이그레이션 적용 뒤 psql로 확인하니 한쪽에만 기본값이 남아 있었다.\n\n```\n Column  |         Type          | Default\n---------+-----------------------+------------------------------\n status  | character varying(10) |\n channel | character varying(10) | ''web''::character varying\n```\n\nDjango를 거치지 않고 psql에서 `INSERT INTO orders (id) VALUES (1);`을 실행하니 status가 NOT NULL 위반으로 실패했다. status 값을 직접 넣어 다시 실행하자 이번에는 성공했고, channel에는 web이 저절로 채워져 있었다. 두 필드 선언의 차이는 CharField에 넘긴 인자 이름 하나뿐이었다.', 'SUBJECTIVE'),
       (3556, 562, '아래 회고에서 PR에 함께 올리기로 한 출력을 만들어 내는 manage.py 하위 명령은?', E'**[배포 후 장애 회고]**\n\n- 마이그레이션 `0031_alter_order_amount.py`의 내용은 `AlterField` 한 줄뿐이었다.\n- migrate가 12분 24초 걸렸고, 그동안 orders 테이블 쓰기가 전면 대기했다.\n- 4,200만 행 테이블이 통째로 재작성된 것이 원인이었다. 파일만 읽어서는 알 수 없었다.\n\n**재발 방지 규칙:** 앞으로 스키마 변경 PR에는 아래 형태의 출력을 함께 올린다.\n\n```sql\nBEGIN;\n--\n-- Alter field amount on order\n--\nALTER TABLE "orders" ALTER COLUMN "amount" TYPE numeric(12, 2) USING "amount"::numeric(12, 2);\nCOMMIT;\n```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3551
(9643, 3551, '0012는 파일이 사라지고 django_migrations에만 기록이 남은 상태라 migrate --fake로 정리해야 한다.', '[ ]는 파일은 있는데 아직 적용되지 않았다는 표시다. 파일 유실은 반대로 DB 기록만 남은 경우이고, 지금은 migrate 한 번이면 해결된다. --fake는 수동 반영 뒤 상태를 맞출 때만 쓴다.', false),
(9644, 3551, 'migrate를 실행하면 0012는 반영되지만, memo 필드는 파일이 없어 스키마에 반영되지 않는다.', 'showmigrations의 [ ]는 미적용 파일이라 migrate가 처리한다. 반면 memo는 models.py에만 있고 마이그레이션 파일이 없어 두 번째 명령이 이를 감지해 종료 코드 1을 냈다. 두 상태는 서로 별개다.', true),
(9645, 3551, '두 번째 명령이 0013_order_memo.py를 이미 만들었으므로 그대로 커밋하면 된다.', '--dry-run이 붙어 있어 만들 내용만 출력하고 파일은 쓰지 않는다. 실제 파일은 --dry-run 없이 makemigrations를 다시 실행해야 생긴다. CI에서 --check가 잡아내는 지점이 바로 이 누락이다.', false),
(9646, 3551, '두 번째 명령이 종료 코드 1로 끝났으므로 0012의 migrate도 함께 취소된다.', '두 명령은 독립적으로 실행된다. --check의 종료 코드는 "생성할 변경이 남아 있다"는 CI용 신호일 뿐, 이미 존재하는 미적용 파일을 적용할 수 있는지와는 무관하다.', false),

-- 문제 3552
(9647, 3552, '인덱스가 만들어지는 동안 orders 테이블의 INSERT·UPDATE가 전부 대기한다.', '쓰기 잠금은 일반 AddIndex(CREATE INDEX)의 동작이다. CONCURRENTLY는 테이블을 여러 번 훑는 대신 쓰기를 막지 않으려고 쓰는 방식이라, 인덱스를 만드는 동안에도 INSERT·UPDATE가 진행된다.', false),
(9648, 3552, 'atomic = False이므로 이 파일은 적용돼도 django_migrations에 행이 남지 않는다.', 'atomic은 실행을 트랜잭션으로 감쌀지 여부만 정한다. 적용 기록은 그와 별개로 남으므로 이 파일도 성공하면 django_migrations에 기록되고 showmigrations에 [X]로 보인다.', false),
(9649, 3552, 'dependencies가 지정돼 있어, 0011_previous가 미적용이면 그것을 건너뛰고 이 파일이 먼저 실행된다.', 'dependencies는 "먼저 적용돼 있어야 할 파일"을 뜻한다. 0011_previous가 미적용이면 migrate가 그것을 먼저 실행한 뒤 이 파일을 실행한다. 건너뛰는 동작은 없다.', false),
(9650, 3552, '실행 도중 실패하면 자동 롤백이 없어, 쓸 수 없는 인덱스가 남아 수동으로 지워야 할 수 있다.', 'atomic = False는 트랜잭션 없이 실행한다는 뜻이라 중간 실패분이 되돌아가지 않는다. PostgreSQL은 CONCURRENTLY가 실패하면 무효 상태 인덱스를 남기므로, DROP INDEX로 치운 뒤 다시 시도해야 한다.', true),

-- 문제 3553
(9651, 3553, '컬럼 삭제는 락 비용이 낮으므로 마이그레이션을 먼저 돌리고 코드 배포를 뒤에 해도 된다.', '락 비용이 낮아도 표의 "비호환"에 걸린다. 아직 남아 있는 구버전 인스턴스가 삭제된 컬럼을 계속 SELECT해 오류를 낸다. 참조를 지운 코드를 먼저 배포하고 삭제 마이그레이션을 나중에 돌려야 한다.', true),
(9652, 3553, 'nullable 컬럼 추가는 구버전 코드가 그 컬럼을 조회하지 않으므로 마이그레이션을 먼저 돌려도 된다.', 'Django는 모델에 있는 컬럼만 명시해 SELECT한다. 구버전 코드의 모델에는 새 컬럼이 없어 조회 대상에서 빠지므로, 스키마를 먼저 넓혀도 구·신 코드가 함께 살아 있을 수 있다.', false),
(9653, 3553, '컬럼 이름 변경은 한 번에 처리하면 어느 쪽 코드든 실패하므로 추가·이중 쓰기·백필·전환·삭제로 쪼갠다.', '이름을 바꾸는 순간 구버전은 옛 이름을, 신버전은 새 이름을 찾는다. 두 이름이 동시에 존재하는 구간을 만들어야 혼재 구간을 버틸 수 있어서 다섯 단계로 나눈다.', false),
(9654, 3553, '타입 변경은 테이블 재작성이 일어날 수 있어, 새 컬럼을 추가해 옮기는 방식이 더 안전하다.', '재작성은 테이블 전체를 다시 쓰는 동안 잠금이 길게 걸린다. 새 컬럼을 nullable로 추가해 옮기면 락 시간을 짧게 끊고, 중간에 멈췄다가 다시 시도할 수도 있다.', false),

-- 문제 3554
(9655, 3554, 'RunPython 안에서는 save()가 무시되어 백필이 한 건도 반영되지 않는다.', 'RunPython은 넘겨받은 파이썬 함수를 그대로 실행하므로 save()도 동작한다. 다만 행마다 UPDATE가 한 번씩 나가 느리므로, iterator와 bulk_update로 묶어 배치 처리하는 편이 낫다.', false),
(9656, 3554, '역방향 함수를 넘기지 않아 정방향 migrate도 실행되지 않는다.', '두 번째 인자를 비우면 되돌리기만 막힌다. 정방향은 정상 실행된다. 되돌릴 작업이 없더라도 RunPython.noop을 명시해 역방향 경로를 열어 두는 것이 권장된다.', false),
(9657, 3554, '이후 마이그레이션에서 추가된 컬럼까지 함께 조회해, 그 컬럼이 없는 시점의 DB에서 실행하면 오류가 난다.', 'models.py의 User를 직접 임포트해 "현재 코드의 모델"이 실행된다. 0013 시점 스키마에는 나중에 생긴 컬럼이 없어 SELECT가 깨진다. apps.get_model로 그 시점의 이력 모델을 받아 써야 한다.', true),
(9658, 3554, 'dependencies가 같은 앱을 가리켜 순환 의존으로 판정돼 migrate가 거부한다.', '같은 앱의 앞 번호 파일을 가리키는 것은 정상적인 선후 관계이며 오히려 필수다. 순환 의존은 두 앱의 파일이 서로를 가리켜 실행 순서를 정할 수 없을 때 생긴다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1140, 3555, 'db_default,db_default=,db default,dbdefault,디비 디폴트', 'default는 파이썬 수준 기본값이다. Django는 컬럼을 추가할 때 기존 행을 채우려고 DB default를 잠깐 넣었다가 곧바로 제거하므로, 완성된 스키마의 status 컬럼에는 DEFAULT가 남지 않는다. 그래서 ORM을 거치지 않은 psql INSERT는 NOT NULL 위반으로 실패한다. 반면 Django 5.0에서 들어온 db_default는 DB 컬럼 자체에 DEFAULT를 남기므로, psql이나 다른 언어로 만든 클라이언트가 값을 빼먹어도 DB가 채워 준다. 두 인자 모두 "기본값"이라 부르지만 값이 남는 위치가 다르다는 점이 경계다. 덧붙여 db_default는 DB 표현식(예: Now())도 받을 수 있고, default와 함께 지정하면 ORM 경로에서는 default가 우선한다.'),
       (1141, 3556, 'sqlmigrate,sql migrate,manage.py sqlmigrate,python manage.py sqlmigrate,./manage.py sqlmigrate', 'sqlmigrate orders 0031처럼 실행하면 그 마이그레이션이 DB에 실제로 보낼 SQL을 출력한다. 실행은 하지 않으므로 배포 전에 ALTER TABLE이 테이블 재작성을 유발하는지, 어떤 잠금이 걸리는지를 눈으로 확인할 수 있다. 회고에 적힌 12분 24초짜리 사고는 AlterField 한 줄이라는 파일 겉모습만 보고 넘어가서 생긴 일이라, 이 명령의 출력을 리뷰에 붙이는 것이 가장 값싼 안전장치다. 옆 명령과 구분하면 showmigrations는 적용 여부만, migrate --plan은 실행될 파일 목록만 보여 주고 SQL은 보여 주지 않는다. 출력이 BEGIN과 COMMIT으로 감싸여 있으면 그 마이그레이션이 트랜잭션 안에서 실행된다는 뜻이라, atomic = False가 필요한 작업인지도 함께 판단할 수 있다.');

-- =====================================================
-- Lesson 720: DDL 부분 적용과 이력 병합·압축
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4499, 720, '아래 migrate 실패 이후의 상태와 재실행에 대한 설명으로 옳은 것은?', '운영 DB는 MySQL 8.0이다.

```python
# orders/migrations/0008_order_changes.py
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("orders", "0007_previous")]
    operations = [
        migrations.AddField("order", "phone", models.CharField(max_length=20, null=True)),
        migrations.AlterField("order", "code", models.CharField(max_length=20, unique=True)),
        migrations.AddField("order", "memo", models.TextField(null=True)),
    ]
```

```
$ python manage.py migrate orders
Operations to perform:
  Apply all migrations: orders
Running migrations:
  Applying orders.0008_order_changes...Traceback (most recent call last):
  ...
django.db.utils.IntegrityError: (1062, "Duplicate entry ''A-100'' for key ''orders_order.orders_order_code_4f1e2a7c_uniq''")
```', 'OBJECTIVE'),
       (4500, 720, '아래 컬럼 이름 변경 계획에 대한 설명으로 옳은 것은?', '롤링 배포 환경이라 코드 배포가 진행되는 동안에는 구버전과 신버전 인스턴스가 같은 DB를 함께 쓴다.

```
[배포 계획] users.nickname → users.display_name
1) [마이그레이션] display_name 컬럼 추가 (null=True)
2) [코드 배포] 쓰기는 nickname·display_name 모두, 읽기는 nickname
3) [코드 배포] 읽기를 display_name으로 전환, nickname 쓰기 중단
4) [백필] display_name이 NULL인 행에 nickname 값 복사
5) [마이그레이션] nickname 컬럼 삭제
```', 'OBJECTIVE'),
       (4501, 720, '아래 데이터 마이그레이션의 동작에 대한 설명으로 옳은 것은?', '운영 DB는 PostgreSQL이고, 0008_article_slug는 slug 필드를 추가한 마이그레이션이다.

```python
# articles/models.py
from django.db import models
from django.utils.text import slugify


class Article(models.Model):
    title = models.CharField(max_length=200)
    slug = models.SlugField(blank=True)

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.title)
        super().save(*args, **kwargs)
```

```python
# articles/migrations/0009_fill_slug.py
from django.db import migrations


def fill_slug(apps, schema_editor):
    Article = apps.get_model("articles", "Article")
    for article in Article.objects.filter(slug=""):
        article.save()


class Migration(migrations.Migration):
    dependencies = [("articles", "0008_article_slug")]
    operations = [
        migrations.RunPython(fill_slug, migrations.RunPython.noop),
    ]
```', 'OBJECTIVE'),
       (4502, 720, '아래 변경을 이 운영 DB에 적용할 때에 대한 설명으로 옳은 것은?', 'Django 3.2 프로젝트이고 운영 DB는 PostgreSQL 10이다. 아래 네 변경은 모두 orders_order 테이블(3,000만 행)에 각각 별도 마이그레이션으로 적용한다.

| 번호 | 변경 | 마이그레이션 작업 |
|---|---|---|
| ① | note 컬럼 추가 | `AddField` — `TextField(null=True)` |
| ② | priority 컬럼 추가 | `AddField` — `IntegerField(default=0)` |
| ③ | created_at 인덱스 추가 | `AddIndex` — `Index(fields=["created_at"], name="order_created_idx")` |
| ④ | quantity 타입 변경 | `AlterField` — `IntegerField` → `BigIntegerField` |', 'OBJECTIVE'),
       (4503, 720, '아래 상황에서 팀이 실행한 manage.py 명령(옵션 포함)은?', 'feature/coupon과 feature/point 두 브랜치의 작업이 main에 함께 들어간 뒤 배포 파이프라인이 멈췄다.

```
$ ls orders/migrations/
0001_initial.py        0002_order_code.py     0003_order_memo.py
0004_order_status.py   0005_order_coupon.py   0005_order_point.py

$ grep -h "dependencies" orders/migrations/0005_*.py
    dependencies = [("orders", "0004_order_status")]
    dependencies = [("orders", "0004_order_status")]

$ python manage.py migrate
CommandError: Conflicting migrations detected; multiple leaf nodes in the migration graph: (0005_order_coupon, 0005_order_point in orders).
```

팀은 두 0005 파일에 손대지 않고 명령 하나를 실행했다. 그 결과 생긴 아래 파일을 커밋하자 migrate가 정상 진행됐다.

```python
# orders/migrations/0006_coupon_and_point.py
from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("orders", "0005_order_coupon"),
        ("orders", "0005_order_point"),
    ]
    operations = []
```', 'SUBJECTIVE'),
       (4504, 720, '아래 기록에서 테스트 DB 생성 시간을 줄이려고 실행한 manage.py 명령은? (인자는 앱 이름과 4자리 마이그레이션 번호 하나로 쓸 것)', '**[CI 속도 개선 기록]**

- payments 앱의 마이그레이션 파일이 0001부터 0214까지 214개로 늘었다.
- `python manage.py test`를 돌리면 테스트 DB를 만드는 단계에서만 5분 48초가 걸렸다.
- 명령 하나를 실행해 아래 파일을 만들고 커밋하자, 같은 단계가 1분 10초로 줄었다.

```python
# payments/migrations/ 안에 새로 생긴 파일 (파일 이름은 생략)
from django.db import migrations, models


class Migration(migrations.Migration):
    replaces = [
        ("payments", "0001_initial"),
        ("payments", "0002_payment_status"),
        # ... 210개 생략
        ("payments", "0213_payment_memo"),
        ("payments", "0214_refund_reason"),
    ]
    operations = [
        migrations.CreateModel(name="Payment", fields=[...]),
        migrations.CreateModel(name="Refund", fields=[...]),
        # ... 이하 29개 작업
    ]
```

- 원래 파일 214개는 스테이징·운영 DB 모두 0214까지 적용된 것을 확인한 뒤에 지우기로 했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4499
(12171, 4499, '세 작업이 한 트랜잭션으로 묶여 있어, 먼저 끝난 phone 컬럼 추가도 함께 롤백됐다.', 'PostgreSQL·SQLite처럼 DDL을 트랜잭션에 넣을 수 있는 DB를 떠올린 오개념이다. MySQL은 DDL마다 암묵적 커밋이 일어나 롤백할 수 없으므로, 오류 전에 끝난 phone 컬럼 추가는 그대로 남는다.', false),
(12172, 4499, 'phone 컬럼 추가가 성공한 시점에 0008이 적용된 것으로 기록되어, 재실행하면 0008을 건너뛴다.', '기록이 작업 단위로 남는다고 오해한 것이다. django_migrations에는 파일 하나당 한 행이 쓰이고, 그 파일의 작업이 모두 끝나야 기록된다. 도중에 실패한 0008은 미적용 상태로 남는다.', false),
(12173, 4499, '0008이 django_migrations에 기록되지 않아, 다시 migrate하면 phone 컬럼을 또 추가하려다 실패한다.', '적용 기록은 파일의 작업이 모두 성공해야 남는다. MySQL은 phone 추가를 이미 커밋했지만 0008은 미적용으로 보여, 재실행하면 첫 작업부터 다시 돌다 중복 컬럼 오류가 난다. 그래서 한 파일에 여러 스키마 변경을 넣지 않는다.', true),
(12174, 4499, '중복 값을 정리하고 다시 migrate하면, Django가 실패 지점을 기억해 code 변경부터 이어서 실행한다.', 'Django는 파일 안에서 어디까지 실행했는지 저장하지 않는다. 미적용 파일은 첫 작업부터 다시 실행되므로, 이미 커밋된 phone 추가를 또 시도하다 막힌다. 재실행 전에 phone 컬럼을 직접 지우는 등 상태를 맞춰야 한다.', false),

-- 문제 4500
(12175, 4500, '1단계 직후, 모델에 display_name이 없는 구버전 코드가 users를 조회하다 오류를 낸다.', '컬럼이 늘면 기존 조회가 깨진다고 본 오개념이다. Django는 모델에 선언된 컬럼만 나열해 SELECT하므로, 구버전 코드는 새 컬럼과 상관없이 정상 동작한다. 그래서 컬럼 추가는 코드 배포보다 먼저 해도 된다.', false),
(12176, 4500, '5단계 컬럼 삭제는 잠금 부담이 낮으므로, 1단계와 같은 마이그레이션 파일에 넣어도 된다.', '잠금 부담과 호환성을 혼동했다. 1단계 시점에는 nickname을 읽고 쓰는 코드가 모두 살아 있어, 컬럼이 지워지는 순간 그 조회와 저장이 실패한다. 삭제는 nickname 참조를 뺀 코드가 전부 배포된 뒤에 해야 한다.', false),
(12177, 4500, '2단계에서 두 컬럼에 함께 쓰기 시작하면, 백필 없이도 기존 행의 display_name이 모두 채워진다.', '이중 쓰기는 그 뒤에 새로 저장되는 행에만 적용된다. 이전에 만들어져 다시 저장되지 않은 행은 display_name이 NULL로 남으므로, 기존 데이터는 백필로 따로 채워야 한다.', false),
(12178, 4500, '3단계 배포 뒤 백필 전까지, 2단계 전에 가입해 수정되지 않은 사용자의 이름이 빈 값으로 읽힌다.', '계획이 읽기 전환(3단계)을 백필(4단계)보다 앞에 뒀다. 2단계 전에 저장된 뒤 다시 쓰이지 않은 행은 display_name이 아직 NULL이라, 새 컬럼을 읽는 순간 이름이 비어 보인다. 백필을 끝낸 뒤 읽기를 전환해야 한다.', true),

-- 문제 4501
(12179, 4501, 'migrate는 오류 없이 끝나지만, save()를 거친 대상 글의 slug는 하나도 채워지지 않는다.', 'apps.get_model이 돌려주는 이력 모델에는 필드만 있고 models.py의 save() 오버라이드가 없다. 기본 save()가 빈 slug를 그대로 다시 저장할 뿐이므로, 함수 안에서 slugify(title)로 값을 직접 넣어야 한다.', true),
(12180, 4501, 'apps.get_model로 받은 모델도 models.py의 save()를 따르므로, 대상 글에 slug가 채워진다.', '이력 모델을 현재 코드의 모델과 같다고 본 오개념이다. 이력 모델은 그 시점의 필드 구성만 재현하고 사용자 정의 메서드·save() 오버라이드·시그널을 갖지 않아, slug를 만드는 로직이 돌지 않는다.', false),
(12181, 4501, 'apps.get_model로 받은 모델에는 save()가 없어, 첫 글에서 AttributeError로 migrate가 중단된다.', '빠지는 것은 사용자가 덧붙인 메서드뿐이다. save()·delete()나 기본 매니저(objects)처럼 Model이 원래 주는 기능은 이력 모델에도 있어, save() 호출은 정상적으로 UPDATE를 보낸다.', false),
(12182, 4501, 'RunPython은 마이그레이션 트랜잭션 밖에서 돌아, 도중에 실패하면 앞서 저장한 글은 남는다.', 'PostgreSQL처럼 DDL을 트랜잭션에 넣을 수 있는 DB에서는 RunPython도 마이그레이션 트랜잭션 안에서 실행된다. 도중에 실패하면 앞서 저장한 행까지 모두 롤백된다.', false),

-- 문제 4502
(12183, 4502, '①은 3,000만 행 모두에 NULL을 채워 넣느라 테이블 전체를 다시 쓴다.', '새 컬럼이면 행마다 값을 기록해야 한다고 본 오개념이다. 기본값 없는 nullable 컬럼 추가는 카탈로그 정보만 바꾸고, 기존 행은 읽을 때 NULL로 간주되므로 테이블을 다시 쓰지 않는다.', false),
(12184, 4502, '②는 이 DB 버전에서 기존 행마다 기본값을 채우느라 테이블 재작성이 일어난다.', 'PostgreSQL 11 이전에는 기본값이 있는 컬럼을 추가하면 모든 행에 그 값을 실제로 기록한다. 3,000만 행을 다시 쓰는 동안 테이블 전체가 잠기므로, 대형 테이블은 nullable로 추가해 값을 채운 뒤 NOT NULL로 바꾼다.', true),
(12185, 4502, '③이 진행되는 동안 이 테이블에 대한 INSERT뿐 아니라 SELECT도 모두 대기한다.', '잠금 범위를 넓게 본 것이다. 일반 CREATE INDEX는 INSERT·UPDATE·DELETE만 막고 SELECT는 허용한다. 다만 쓰기가 멈추는 것만으로도 장애가 되므로 운영에서는 AddIndexConcurrently를 쓴다.', false),
(12186, 4502, '④는 컬럼의 타입 정보만 바꾸므로 행 수와 관계없이 곧바로 끝난다.', 'integer를 bigint로 바꾸면 값의 저장 크기가 4바이트에서 8바이트로 달라져 모든 행을 새로 써야 한다. 그동안 테이블이 잠기므로 새 컬럼을 추가해 옮기는 방식이 권장된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1456, 4503, 'makemigrations --merge,python manage.py makemigrations --merge,python3 manage.py makemigrations --merge,manage.py makemigrations --merge,./manage.py makemigrations --merge,makemigrations orders --merge,makemigrations --merge orders', '두 브랜치가 각자 0004를 부모로 삼아 0005 파일을 만들었기 때문에 마이그레이션 그래프의 끝(리프 노드)이 둘로 갈라졌다. Django는 두 갈래 중 무엇을 먼저 적용할지 정할 수 없어 migrate를 멈춘다. makemigrations --merge는 두 리프를 모두 dependencies로 가리키고 operations는 비어 있는 파일을 새로 만들어 그래프의 끝을 다시 하나로 모은다. 기존 0005 파일을 고치지 않으므로 한쪽 0005를 이미 적용한 환경도 그대로 이어서 진행할 수 있다. 헷갈리는 방법과 구분하면, 옵션 없는 makemigrations는 충돌을 감지하면 같은 오류로 멈추고 파일을 만들지 않는다. migrate --fake는 실행 없이 적용 기록만 남기는 옵션이라 갈라진 그래프를 합치지 못한다. 한쪽 0005의 dependencies를 손으로 고쳐 번호를 이어 붙이는 방법도 있지만, 이미 그 파일을 적용한 환경의 이력과 어긋날 수 있다. 파일 이름은 --name으로 정할 수 있고, 지정하지 않으면 0006_merge_날짜_시각 형태가 된다.'),
       (1457, 4504, 'squashmigrations payments 0214,python manage.py squashmigrations payments 0214,python3 manage.py squashmigrations payments 0214,py manage.py squashmigrations payments 0214,manage.py squashmigrations payments 0214,./manage.py squashmigrations payments 0214', '본문의 파일은 replaces에 0001_initial부터 0214_refund_reason까지 214개를 모두 적고, 그 작업을 31개로 줄여 담았다. 이런 파일은 squashmigrations payments 0214로 만든다. 이 명령은 0001부터 0214까지의 작업을 파일 하나로 모으고, 모델을 만든 뒤 필드를 추가·수정하는 식으로 이어지는 작업은 가능한 한 합쳐 줄인다. replaces 목록은 새 파일이 원본들을 대신한다는 표시다. 원본을 모두 적용한 DB는 새 파일도 적용된 것으로 취급하고, 테스트 DB처럼 비어 있는 DB는 새 파일만 실행한다. 테스트는 매번 마이그레이션을 처음부터 재생하므로 작업 수가 줄어든 만큼 DB 생성 시간이 짧아진다. squashmigrations는 앱 이름과 종료 마이그레이션 이름이 필수 인자이며, 하나라도 생략하면 인자 누락 오류(the following arguments are required)로 실행되지 않는다. 그래서 squashmigrations나 squashmigrations payments만으로는 이 파일을 만들 수 없다. 마이그레이션 이름은 0214처럼 다른 파일과 겹치지 않는 앞부분만 써도 된다. 이름을 하나만 주면 그 파일이 압축 범위의 끝이 되고 시작은 앱의 첫 파일(0001)이므로, 여기서는 0001이 아니라 0214를 넘겨야 한다. 시작 지점을 따로 정하려면 앱 이름 뒤에 시작·종료 순서로 두 이름을 쓴다. 원본 파일은 모든 환경에 원본이 끝까지 적용된 뒤에만 지워야 한다. 일찍 지우면 중간까지만 적용된 환경은 남은 원본을 찾지 못해 진행할 수 없다. 원본을 지운 뒤에는 새 파일의 replaces를 없애 평범한 마이그레이션으로 전환한다. 헷갈리는 명령과 구분하면, migrate payments 0214는 같은 모양의 인자를 받지만 그 번호까지 적용하거나 되돌릴 뿐 파일을 만들지 않는다. makemigrations --merge는 갈라진 그래프를 합치려고 파일을 하나 더 만드는 명령이라 파일 수를 줄이지 않는다. 새 파일 이름은 --squashed-name을 주지 않으면 0001_initial_squashed_0214_refund_reason.py처럼 시작·종료 마이그레이션 이름을 이어 붙인 형태가 되고, --squashed-name baseline을 주면 0001_baseline.py가 된다.');

-- =====================================================
-- Lesson 878: 운영 배포에서 겪는 마이그레이션 사고와 대응
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5447, 878, '아래 상태에서 migrate accounts 0011을 실행한 결과로 옳은 것은?', '운영 DB는 PostgreSQL이다. accounts 앱의 현재 적용 상태와 각 파일의 operations는 아래와 같다.

```
$ python manage.py showmigrations accounts
accounts
 [X] 0011_user_nickname
 [X] 0012_user_display_name
 [X] 0013_backfill_display_name
 [X] 0014_user_bio
```

| 파일 | operations |
|---|---|
| 0012_user_display_name | `migrations.AddField("user", "display_name", ...)` |
| 0013_backfill_display_name | `migrations.RunPython(backfill_display_name)` |
| 0014_user_bio | `migrations.AddField("user", "bio", ...)` |

이 상태에서 아래 명령을 실행했다.

```
$ python manage.py migrate accounts 0011
```', 'OBJECTIVE'),
       (5448, 878, '아래 배포 기록에 나타난 문제의 원인과 대책으로 옳은 것은?', E'운영 DB는 PostgreSQL이다. billing 서비스는 Kubernetes 파드 3개로 떠 있고, 각 컨테이너는 시작 명령으로 `python manage.py migrate && gunicorn config.wsgi`를 실행한다. 이번 배포에서 미적용 마이그레이션은 요금제 기본 행 3개(basic·pro·team)를 넣는 `0031_seed_plans`(RunPython) 하나였다.\n\n```\n[billing-7f9c-a] 10:02:11  Applying billing.0031_seed_plans... OK\n[billing-7f9c-b] 10:02:11  Applying billing.0031_seed_plans... OK\n[billing-7f9c-c] 10:02:15  No migrations to apply.\n```\n\n배포 뒤 요금제 테이블을 확인했다.\n\n```\n=> SELECT name, count(*) FROM billing_plan GROUP BY name ORDER BY name;\n name  | count\n-------+-------\n basic |     2\n pro   |     2\n team  |     2\n```', 'OBJECTIVE'),
       (5449, 878, '아래 배포 실패에 대한 설명으로 옳은 것은?', '운영 DB는 PostgreSQL이고, payments_payment 테이블에는 3,200만 행이 있다. 배포 잡의 제한 시간은 45분이다.

```python
# payments/migrations/0042_backfill_fee.py
from django.db import migrations


def backfill_fee(apps, schema_editor):
    Payment = apps.get_model("payments", "Payment")
    batch = []
    for p in Payment.objects.filter(fee__isnull=True).iterator(chunk_size=1000):
        p.fee = p.amount * 3 // 100
        batch.append(p)
        if len(batch) >= 1000:
            Payment.objects.bulk_update(batch, ["fee"])
            batch.clear()
    if batch:
        Payment.objects.bulk_update(batch, ["fee"])


class Migration(migrations.Migration):
    dependencies = [("payments", "0041_payment_fee")]
    operations = [
        migrations.RunPython(backfill_fee, migrations.RunPython.noop),
    ]
```

```
[deploy] 13:00:04  Applying payments.0042_backfill_fee...
[deploy] 13:45:04  Job exceeded time limit (45m). Process killed.
```', 'OBJECTIVE'),
       (5450, 878, '아래 상황에 대한 설명으로 옳은 것은?', '개발자가 닉네임 길이 제한을 20자에서 40자로 늘리면서, 새 마이그레이션 파일을 만들지 않고 이미 운영 DB에 적용된 0007 파일을 직접 고쳤다.

```diff
# accounts/models.py
-    nickname = models.CharField(max_length=20, default="")
+    nickname = models.CharField(max_length=40, default="")

# accounts/migrations/0007_user_nickname.py  (3주 전 운영 DB에 적용됨)
-        migrations.AddField("user", "nickname", models.CharField(max_length=20, default="")),
+        migrations.AddField("user", "nickname", models.CharField(max_length=40, default="")),
```

```
$ python manage.py makemigrations --check      # CI
No changes detected

$ python manage.py migrate                     # 운영 배포
Operations to perform:
  Apply all migrations: accounts, admin, auth, contenttypes, sessions
Running migrations:
  No migrations to apply.
```

배포 뒤 25자 닉네임으로 가입하려던 사용자에게서 `value too long for type character varying(20)` 오류가 났다.', 'OBJECTIVE'),
       (5451, 878, '아래 기록에서 팀이 migrate 명령에 붙인 옵션은? (옵션 이름만 쓸 것)', '**[장애 대응 기록]** 운영 DB는 PostgreSQL이다.

- 14:05 긴급 요청으로 DBA가 psql에서 아래 SQL을 직접 실행해 컬럼을 먼저 만들었다.
  `ALTER TABLE "orders_order" ADD COLUMN "phone" varchar(20) NULL;`
- 16:30 같은 변경을 담은 `0015_order_phone.py`(AddField)가 main에 머지됐고, 배포의 migrate 단계가 아래 오류로 실패했다.
  `django.db.utils.ProgrammingError: column "phone" of relation "orders_order" already exists`
- 16:42 팀은 컬럼을 지우지 않고, `python manage.py migrate orders 0015`에 옵션 하나를 붙여 실행했다. 실행 중 DB 로그는 아래와 같다(SELECT 문은 생략).

```
LOG:  statement: INSERT INTO "django_migrations" ("app", "name", "applied") VALUES (''orders'', ''0015_order_phone'', ''2026-09-21T07:42:07.518+00:00''::timestamptz) RETURNING "django_migrations"."id"
```

- 그 뒤 showmigrations에서 0015가 [X]로 바뀌었고, 다음 배포의 migrate는 정상 통과했다.', 'SUBJECTIVE'),
       (5452, 878, '아래 작업 계획이 따르는 스키마 변경 패턴의 이름은?', 'payments_payment 테이블(4,000만 행)의 amount 컬럼을 integer에서 numeric(12, 2)로 바꿔야 한다. 운영 DB는 PostgreSQL이고, 코드 배포는 롤링 방식이라 배포 중에는 직전 버전과 새 버전 인스턴스가 같은 DB를 함께 쓴다. 스테이징 리허설에서 `AlterField` 한 번으로 타입을 바꾸자 테이블 재작성에 38분이 걸렸고, 그동안 결제 저장이 전부 대기했다. 팀은 대신 아래 계획으로 진행했다.

| 순서 | 종류 | 작업 |
|---|---|---|
| 1 | 마이그레이션 | amount_dec 컬럼 추가(`DecimalField`, `null=True`), amount의 NOT NULL 해제 |
| 2 | 코드 배포 | 저장할 때 amount·amount_dec에 모두 기록, 읽기는 amount |
| 3 | 관리 명령 | 기존 행의 amount_dec를 1만 행씩 나눠 채움 |
| 4 | 코드 배포 | 읽기를 amount_dec로 전환(저장은 계속 두 컬럼 모두) |
| 5 | 코드 배포 | amount를 읽고 쓰는 코드 제거 |
| 6 | 마이그레이션 | amount 컬럼 삭제 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5447
(14699, 5447, '0011도 되돌려져 적용 기록이 0010까지로 줄고, nickname 컬럼까지 삭제된다.', '번호를 지정한 migrate는 "그 파일까지 적용된 상태"로 맞추라는 뜻이다. 0011은 남기고 그 뒤의 0012~0014만 되돌리는 대상이 된다. 0011까지 되돌리려면 0010을 지정해야 한다.', false),
(14700, 5447, '0014는 되돌려지지만 0013에서 되돌릴 수 없다는 오류로 멈춰, display_name 컬럼은 남는다.', '되돌리기는 최신 파일부터 한 파일씩 진행되고, 파일마다 따로 커밋·기록된다. 0014의 bio 삭제가 먼저 끝난 뒤 역방향 함수가 없는 0013에서 IrreversibleError가 나, 0012·0013은 적용 상태로 남는다.', true),
(14701, 5447, '실행 전에 0013을 되돌릴 수 없음을 먼저 확인해, 아무 파일도 되돌리지 않고 오류로 끝난다.', 'Django는 되돌리기 전에 전체를 미리 검사하지 않는다. 최신 파일부터 하나씩 실행하다 0013에서 멈추므로, 그때는 0014가 이미 되돌려진 뒤다. 미리 확인하려면 --plan을 붙여 IRREVERSIBLE 표시를 본다.', false),
(14702, 5447, '0013은 역방향 함수가 없으니 할 일 없이 통과해, 0012~0014가 모두 되돌려진다.', '두 번째 인자를 비운 것과 RunPython.noop을 넘긴 것을 같게 본 오개념이다. 인자가 없으면 "되돌릴 방법 없음"으로 취급돼 오류가 나고, noop을 명시해야 "할 일 없음"으로 통과한다.', false),

-- 문제 5448
(14703, 5448, '0031이 스키마 변경과 데이터 삽입을 한 파일에 섞은 탓이므로, 두 파일로 나누면 중복이 사라진다.', '0031은 기본 행을 넣는 RunPython 하나뿐이라 섞인 스키마 변경이 없다. 파일 분리는 실패 복구를 쉽게 하려는 원칙이고, 두 파드가 같은 파일을 동시에 실행하는 문제는 나눠도 그대로 남는다.', false),
(14704, 5448, 'migrate는 적용 기록을 잠근 채 한 번만 실행되므로, seed 함수가 같은 행을 두 번 넣지 않게 고친다.', 'Django는 migrate 중 적용 기록을 잠그지 않는다. 로그처럼 파드 a·b가 모두 0031을 적용했고, 각자 기본 행 3개를 넣어 2건씩이 됐다. seed 함수가 옳아도 두 번 실행되면 중복이 생긴다.', false),
(14705, 5448, 'RunPython이 트랜잭션 밖에서 실행된 탓이므로, Migration에 atomic = True를 명시하면 중복이 막힌다.', 'PostgreSQL에서는 기본값으로 파일 하나가 트랜잭션으로 묶여 실행된다. 트랜잭션은 한 실행을 전부 반영하거나 전부 취소할 뿐, 두 파드가 각자 트랜잭션을 열어 같은 행을 넣는 것까지 막지는 못한다.', false),
(14706, 5448, '파드마다 적용 기록을 읽고 실행하는 사이에 잠금이 없어 생긴 일이므로, migrate를 배포 잡 하나에서만 돌린다.', '파드 a·b가 거의 같은 시각에 기록을 읽어 둘 다 0031을 미적용으로 보고 실행했다. 늦게 뜬 c만 기록을 보고 건너뛰었다. 실행 주체를 배포 잡 하나로 고정하고, 앱 파드는 migrate 없이 뜨게 한다.', true),

-- 문제 5449
(14707, 5449, 'chunk_size=1000으로 나눠 읽었으므로, 강제 종료 전까지 bulk_update한 행의 fee는 DB에 남아 있다.', 'chunk_size는 DB에서 한 번에 읽어 올 행 수일 뿐 커밋 단위가 아니다. PostgreSQL에서는 이 파일 전체가 트랜잭션 하나라, 프로세스가 죽어 연결이 끊기자 45분 동안 쓴 변경이 모두 롤백됐다.', false),
(14708, 5449, '스키마를 바꾸지 않는 작업이라, 실행 중에도 이미 fee를 채운 결제 행은 다른 요청이 바로 수정할 수 있었다.', 'UPDATE한 행에는 커밋될 때까지 행 잠금이 걸린다. 트랜잭션이 45분 동안 열려 있어, 이미 갱신된 결제 행을 고치려는 요청은 그동안 대기했다. DDL이 없어도 긴 트랜잭션은 잠금을 쌓는다.', false),
(14709, 5449, '0042는 적용 기록이 남지 않아, 다음 배포 때 fee가 빈 첫 행부터 백필을 다시 시작한다.', '실패한 파일은 적용 기록이 남지 않아 다음 migrate가 다시 실행한다. 롤백으로 채운 값도 사라져 처음부터 다시 돌고, 또 45분을 넘길 수 있다. 대형 백필은 관리 명령으로 빼 배치마다 커밋하고 이어서 재시도할 수 있게 한다.', true),
(14710, 5449, 'bulk_update가 1,000행을 UPDATE 1,000개로 나눠 보내 느려졌으므로, save()로 바꾸면 제한 시간 안에 끝난다.', 'bulk_update는 배치 하나를 CASE WHEN으로 묶은 UPDATE 한 문장으로 보낸다. save()는 행마다 UPDATE를 보내 오히려 더 느리다. 핵심은 속도보다 3,200만 행을 트랜잭션 하나에 묶은 구조다.', false),

-- 문제 5450
(14711, 5450, '고친 0007까지 재생한 모델 상태가 models.py와 같아져, makemigrations가 차이를 찾지 못했다.', 'makemigrations는 0001부터 파일을 차례로 재생해 만든 모델 상태를 models.py와 비교한다. 고친 0007을 재생하면 이미 40자라 차이가 없다. 실제 DB 컬럼은 비교 대상이 아니어서 운영은 20자 그대로다.', true),
(14712, 5450, '0007 내용이 바뀌었으므로 다음 migrate 때 0007이 다시 실행되어 컬럼 길이가 40으로 늘어난다.', '적용 여부는 django_migrations의 앱·파일 이름으로만 판단하고 파일 내용은 비교하지 않는다. 0007은 이미 기록돼 있어 몇 번을 배포해도 다시 실행되지 않는다. 길이 변경은 새 AlterField 파일로 해야 한다.', false),
(14713, 5450, 'CI의 makemigrations가 운영 DB가 아닌 CI용 DB의 컬럼 정보와 비교해서 변경을 놓쳤다.', 'makemigrations는 DB 스키마를 읽어 비교하지 않는다. 어느 DB에 연결해 실행하든 비교 대상은 파일을 재생한 상태와 models.py라서, 운영 DB에 붙여 돌려도 No changes detected가 나온다.', false),
(14714, 5450, '0007은 그대로 두고 models.py만 고쳤어도 makemigrations --check는 통과해 결과가 같았을 것이다.', 'models.py만 고쳤다면 파일 재생 결과(20자)와 models.py(40자)가 달라 --check가 비정상 종료했을 것이다. 이미 적용된 파일까지 고친 탓에 CI 안전장치마저 비껴간 것이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1772, 5451, '--fake,fake,—fake,-fake,--fake 옵션,fake 옵션,migrate --fake,migrate orders 0015 --fake,python manage.py migrate orders 0015 --fake,페이크', 'phone 컬럼은 DBA가 이미 만들어 두었으므로, 0015가 할 일은 남아 있지 않고 적용 기록만 빠져 있었다. migrate --fake는 파일의 SQL을 실행하지 않고 django_migrations에 적용 기록만 남긴다. 그래서 DB 로그에 기록 INSERT 한 줄만 찍히고 showmigrations가 [X]로 바뀌며, 다음 migrate는 0015를 건너뛴다. 헷갈리는 옵션과 구분하면, --fake-initial은 initial = True인 초기 마이그레이션에만 쓰이고 그 파일이 만들 테이블이 이미 있을 때 기록만 남긴다. 0015 같은 중간 파일에는 해당하지 않는다. 컬럼을 지운 뒤 migrate를 다시 돌리는 방법도 있지만, 그 사이 phone에 저장된 값이 사라진다. --fake의 위험은 Django가 실제 스키마를 확인하지 않고 기록만 남긴다는 점이다. 수동 SQL이 파일과 다르면(예: varchar(30)으로 만들었다면) 그 차이가 그대로 숨는다. 그래서 적용 전 sqlmigrate orders 0015로 파일이 만들 SQL과 수동 SQL을 대조하고, 이번처럼 수동 반영을 이력에 맞출 때만 쓴다.'),
       (1773, 5452, '확장·수축 패턴,확장·수축,확장 수축 패턴,확장 수축,확장수축 패턴,확장수축,확장-수축,확장/수축,expand and contract,expand & contract,expand-contract,expand/contract,expand contract,expand and contract pattern,expand and contract 패턴,확장과 수축,parallel change,병렬 변경', '1단계에서 새 컬럼을 더해 스키마를 넓히고(확장), 마지막 6단계에서 옛 컬럼을 지워 좁힌다(수축). 그 사이 2~5단계에는 amount와 amount_dec가 함께 존재하므로, 롤링 배포로 직전 버전과 새 버전 코드가 섞여 돌아도 어느 쪽이 쓰는 컬럼도 사라지지 않는다. 1단계에서 amount의 NOT NULL을 풀어 두는 것도, 5단계 이후 amount를 쓰지 않는 코드가 저장에 실패하지 않게 하려는 준비다. AlterField로 타입을 한 번에 바꾸면 테이블 재작성 동안 쓰기가 막히지만, 이 방식은 컬럼 추가·삭제처럼 가벼운 DDL만 쓰고 무거운 데이터 이동은 관리 명령의 배치 작업으로 뺀다. 헷갈리는 개념과 구분하면, 이중 쓰기(2단계)와 백필(3단계)은 이 패턴 안의 한 단계일 뿐 전체 이름이 아니다. 롤링 배포·블루-그린 배포는 코드를 교체하는 배포 방식이지 스키마를 바꾸는 순서가 아니다. 컬럼 이름 변경도 RenameField 대신 같은 순서(추가 → 이중 쓰기 → 백필 → 전환 → 삭제)로 쪼갠다.');
