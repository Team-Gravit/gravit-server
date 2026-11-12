-- Unit: DRF 직렬화와 검증 (Unit ID: 138)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (564, 138, 'is_valid 검증 순서와 partial'),
       (722, 138, 'save 흐름과 필드별 오류, depth'),
       (880, 138, 'DRF 시리얼라이저 — 검증 전후의 호출 규칙, 변환된 값, 서비스 함수와의 역할 분담');

-- =====================================================
-- Lesson 564: is_valid 검증 순서와 partial
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3563, 564, '아래 시리얼라이저로 요청을 처리한 결과에 대한 설명으로 옳은 것은?', '```python
from rest_framework import serializers


class SignupSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["email", "nickname", "age"]

    def validate_age(self, value):
        if value < 14:
            raise serializers.ValidationError("14세 이상만 가입할 수 있습니다.")

    def validate(self, attrs):
        if attrs["nickname"] in attrs["email"]:
            raise serializers.ValidationError("닉네임을 이메일에 그대로 쓸 수 없습니다.")
        return attrs
```

요청 본문 `{"email": "kim@example.com", "nickname": "neo", "age": 20}`으로 `SignupSerializer(data=request.data)`를 만들고 `is_valid()`를 호출했다.', 'OBJECTIVE'),
       (3564, 564, '아래 코드를 실행했을 때 콘솔에 찍히는 내용으로 옳은 것은?', '```python
class OrderSerializer(serializers.Serializer):
    qty = serializers.IntegerField(max_value=100)
    coupon = serializers.CharField(max_length=10)

    def validate_qty(self, value):
        print("A")
        return value

    def validate(self, attrs):
        print("B")
        return attrs
```

아래를 실행하자 반환값은 False였고, `errors`에는 `{"qty": ["Ensure this value is less than or equal to 100."]}`가 담겼다.

```python
OrderSerializer(data={"qty": 500, "coupon": "SUMMER"}).is_valid()
```', 'OBJECTIVE'),
       (3565, 564, '아래 비교표를 바탕으로 한 설명으로 옳지 않은 것은?', '| 항목 | ModelSerializer | Serializer |
| --- | --- | --- |
| 필드 선언 | 모델 필드에서 자동 생성 | 개발자가 직접 선언 |
| unique=True 제약 | UniqueValidator 자동 부착(저장 전 조회 1회) | 부착하지 않음 |
| create()·update() | 단순 구현을 자동 제공 | 제공하지 않음 |
| 모델의 clean()·full_clean() | 호출하지 않음 | 호출하지 않음 |
| 중첩 시리얼라이저 쓰기 | 기본 미지원 | 기본 미지원 |', 'OBJECTIVE'),
       (3566, 564, '아래 목록 API에서 SQL이 41회 실행된 원인과 해결에 대한 설명으로 옳은 것은?', '```python
class PostSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source="author.name")
    comment_count = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = ["id", "title", "author_name", "comment_count"]

    def get_comment_count(self, obj):
        return obj.comments.count()
```

뷰의 `get_queryset()`은 `Post.objects.all()`이고, 목록 API는 게시글 20건을 응답한다. 응답 한 번에 실제로 실행된 SQL은 게시글 목록 1회 + 작성자 조회 20회 + 댓글 수 COUNT 20회로 모두 41회였다.', 'OBJECTIVE'),
       (3567, 564, '아래 400 응답을 없애려고 시리얼라이저 생성자에 True로 넘긴 인자의 이름은?', '클라이언트가 정원만 바꾸려고 아래처럼 요청했다.

```
PATCH /api/events/12/
{"capacity": 50}
```

뷰 코드는 이렇다.

```python
serializer = EventSerializer(event, data=request.data)
serializer.is_valid(raise_exception=True)
serializer.save()
```

응답은 200이 아니라 400이었다.

```json
{"title": ["This field is required."],
 "starts_at": ["This field is required."],
 "ends_at": ["This field is required."]}
```

`EventSerializer(event, data=request.data, ???=True)`처럼 인자 하나를 더 주자 같은 요청이 200으로 바뀌었고, 보내지 않은 필드는 기존 값 그대로 남았다.', 'SUBJECTIVE'),
       (3568, 564, '아래 400 응답을 만들어 낸, ModelSerializer가 자동으로 붙여 준 검증기의 이름은?', '```python
class Reservation(models.Model):
    room = models.ForeignKey(Room, on_delete=models.CASCADE)
    date = models.DateField()

    class Meta:
        unique_together = ("room", "date")


class ReservationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reservation
        fields = ["id", "room", "date"]
```

같은 room·date 조합으로 두 번째 예약을 POST 하자, DB까지 가서 IntegrityError로 500이 나는 대신 `is_valid()` 단계에서 400과 함께 아래 응답이 돌아왔다.

```json
{"non_field_errors": ["The fields room, date must make a unique set."]}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3563
(9675, 3563, 'age는 요청 값 20이 그대로 validated_data에 담겨 저장된다.', '필드 훅의 반환값이 그 필드의 최종 값을 대체한다는 규칙을 놓친 오해다. 훅을 정의한 순간 원래 입력 20은 훅의 반환값에 자리를 내준다.', false),
(9676, 3563, 'validated_data의 age가 None이 되어 age 없이 저장이 진행된다.', 'age가 14 이상이라 validate_age는 예외 없이 끝나고 암묵적으로 None을 반환한다. DRF는 훅의 반환값을 그대로 쓰므로 validated_data에 None이 들어간다.', true),
(9677, 3563, 'validate_age가 값을 반환하지 않아 검증 오류로 잡히고 400 응답이 나간다.', '반환 누락을 DRF가 실패로 본다는 오해다. 필드 훅은 ValidationError를 던질 때만 실패로 처리되며, 여기서는 조용히 통과해 오류가 잡히지 않는다.', false),
(9678, 3563, 'age는 모델에서 자동 생성된 정수 필드라 타입 변환만 거치고 validate_age는 호출되지 않는다.', 'ModelSerializer가 필드를 자동 생성하면 훅이 무시된다는 오해다. 자동 생성 여부와 무관하게 타입 변환·필드 검증기 다음에 validate_<필드명> 훅이 이어진다.', false),

-- 문제 3564
(9679, 3564, 'A만 찍힌다.', '필드 검증기가 실패해도 그 필드의 훅은 돈다는 오해다. max_value에서 걸린 qty는 validate_qty까지 도달하지 못하므로 A는 찍히지 않는다.', false),
(9680, 3564, 'B만 찍힌다.', '객체 단위 validate()는 필드 결과와 무관하게 항상 돈다는 오해다. validate()는 모든 필드가 통과한 뒤에만 실행되므로 여기서는 호출 자체가 없다.', false),
(9681, 3564, '아무것도 찍히지 않는다.', 'qty=500이 max_value=100에 걸려 to_internal_value 단계에서 오류가 확정된다. 그 뒤의 필드 훅도, 객체 단위 validate()도 실행되지 않아 출력이 없다.', true),
(9682, 3564, 'A와 B가 차례로 찍힌다.', 'DRF가 모든 검증을 끝까지 돌린 뒤 오류를 한꺼번에 모아 준다는 오해다. 실제로는 앞 단계에서 오류가 하나라도 나면 뒤 단계는 건너뛴다.', false),

-- 문제 3565
(9683, 3565, '모델의 clean()에 검증을 넣어 두면 API 요청도 그 검증을 거치므로 시리얼라이저에 다시 쓸 필요가 없다.', '표의 clean() 행이 두 쪽 모두 호출하지 않음이므로 거짓이다. 모델에만 검증을 두면 API 경로로 우회되니, 시리얼라이저에 두거나 validate()에서 full_clean()을 직접 불러야 한다.', true),
(9684, 3565, '검색 조건처럼 대응하는 모델이 없는 입력은 저장이 없으므로 Serializer만으로 충분하다.', '참이다. 표에서 Serializer는 create()를 제공하지 않지만, 저장하지 않는 입력에는 애초에 필요 없다. 필드를 직접 선언해 순수 검증기로 쓰는 전형적인 경우다.', false),
(9685, 3565, 'unique=True인 필드가 늘어날수록 ModelSerializer의 is_valid() 단계에서 나가는 조회 횟수도 늘어난다.', '참이다. 표대로 unique 제약마다 UniqueValidator가 자동으로 붙고 각각 저장 전 조회를 한 번씩 한다. 자동 생성의 편의에 조회 비용이 딸려 온다는 뜻이다.', false),
(9686, 3565, '자식 목록을 함께 받아 저장하는 API는 어느 쪽을 쓰든 create()를 직접 구현해야 한다.', '참이다. 표의 중첩 쓰기 행이 둘 다 기본 미지원이므로, ModelSerializer가 자동 제공하는 create()로도 자식 행은 저장되지 않는다. 트랜잭션으로 묶어 직접 써야 한다.', false),

-- 문제 3566
(9687, 3566, '뷰의 get_queryset()에 select_related와 annotate만 걸면 시리얼라이저 코드는 그대로 두어도 41회가 1회로 준다.', 'annotate는 게시글 행에 댓글 수를 실어 줄 뿐이고, get_comment_count는 그대로 obj.comments.count()로 새 COUNT를 던진다. 작성자 조회 20회만 사라져 21회가 남는다.', false),
(9688, 3566, 'author_name은 CharField라 문자열만 읽으므로 추가 쿼리와 무관하고, 댓글 수 COUNT 20회만 줄이면 된다.', 'source="author.name"은 필드 타입과 무관하게 FK를 따라 작성자 행을 읽는다. 지연 로딩이라 게시글마다 SELECT가 나가고, 이것이 작성자 조회 20회의 정체다.', false),
(9689, 3566, 'comments를 중첩 시리얼라이저로 바꾸거나 Meta에 depth를 주면 관련 객체를 한 번에 가져와 해결된다.', '중첩 시리얼라이저와 depth는 응답 모양만 바꿀 뿐 여전히 행마다 관련 객체를 조회한다. depth는 읽기 전용인 데다 오히려 N+1을 키우기 쉽다.', false),
(9690, 3566, '뷰의 get_queryset()에 select_related와 annotate를 걸고, 댓글 수도 실린 값을 읽는 필드로 바꿔야 41회가 1회로 준다.', '작성자 조인과 댓글 수 집계를 목록 쿼리 한 번에 합치는 것은 뷰의 몫이다. 다만 annotate 값은 저절로 쓰이지 않으므로, comment_count를 IntegerField(read_only=True)로 바꿔 실린 값을 읽게 해야 COUNT 20회까지 사라진다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1144, 3567, 'partial,partial=True,partial 인자,파셜', 'PATCH처럼 일부 필드만 보내는 요청은 시리얼라이저를 partial=True로 만들어야 한다. 그러면 required 검사가 보내지 않은 필드에는 적용되지 않고, validated_data에도 실제로 보낸 키만 담긴다. 이 때문에 validate()에서 attrs["starts_at"]처럼 바로 꺼내면 KeyError가 날 수 있어, attrs.get()을 쓰거나 self.instance의 기존 값과 합쳐 판단해야 한다. 전체 교체를 뜻하는 PUT과 다르고, 필드를 아예 입력에서 빼 버리는 read_only_fields와도 목적이 다르다. read_only_fields는 그 필드를 영원히 못 바꾸게 하는 것이고, partial은 이번 요청에서만 생략을 허용하는 것이다.'),
       (1145, 3568, 'UniqueTogetherValidator,unique_together validator,유니크투게더밸리데이터,유니크투게더 밸리데이터', 'ModelSerializer는 모델의 unique_together·UniqueConstraint를 읽어 Meta.validators에 UniqueTogetherValidator를 자동으로 넣는다. 덕분에 중복 예약이 DB 제약에 부딪혀 IntegrityError로 500이 되기 전에, is_valid() 단계에서 조회 한 번으로 걸러져 400 응답이 된다. 헷갈리는 옆 개념과의 경계는 오류가 어디에 담기느냐로 가른다. 단일 필드 unique=True에 붙는 UniqueValidator는 필드 단위라 오류가 그 필드 키에 담기고, 여러 필드를 묶어 보는 UniqueTogetherValidator는 특정 필드에 귀속되지 않아 non_field_errors에 담긴다. 또 이 검증기들은 자동 생성이므로, 원하지 않으면 Meta.validators를 직접 지정해 덮어써야 한다.');

-- =====================================================
-- Lesson 722: save 흐름과 필드별 오류, depth
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4511, 722, '아래 400 응답의 원인과 해결에 대한 설명으로 옳은 것은?', '```python
class Post(models.Model):
    title = models.CharField(max_length=100)
    body = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)


class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ["id", "title", "body", "author"]
```

작성자는 클라이언트에게 받지 않고 로그인한 사용자로 채우려고, 뷰를 이렇게 썼다.

```python
serializer = PostSerializer(data=request.data)
serializer.is_valid(raise_exception=True)
serializer.save(author=request.user)
```

로그인한 상태로 `{"title": "공지", "body": "점검 안내"}`를 POST로 보내자 응답은 400이었다.

```json
{"author": ["This field is required."]}
```', 'OBJECTIVE'),
       (4512, 722, '아래 PUT 요청을 처리한 뒤 events 테이블의 상태로 옳은 것은?', '```python
class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = ["id", "title", "capacity"]


class EventDetailView(APIView):
    def put(self, request, pk):
        event = get_object_or_404(Event, pk=pk)
        serializer = EventSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
```

요청 전 events 테이블에는 행이 하나뿐이다. id는 자동 증가 기본 키다.

| id | title | capacity |
| --- | --- | --- |
| 12 | 신입 세미나 | 30 |

이 상태에서 아래 요청을 보냈다.

```
PUT /api/events/12/
{"id": 12, "title": "신입 세미나", "capacity": 50}
```', 'OBJECTIVE'),
       (4513, 722, '배포 후 아래 요청을 처리한 결과로 옳은 것은?', '회원 정보 수정 API는 아래 시리얼라이저를 쓴다. 뷰는 로그인한 회원 객체를 instance로 넘기고 `partial=True`로 검증한 뒤 `save()`를 호출하고, `serializer.data`를 응답한다.

```python
class MemberSerializer(serializers.ModelSerializer):
    class Meta:
        model = Member
        fields = "__all__"
```

`Member` 모델에는 원래 id·nickname·email 필드만 있었다. 지난주 배포에서 시리얼라이저와 뷰 코드는 그대로 두고, 모델에만 아래 두 필드를 추가했다.

| 추가 필드 | 모델 정의 | 용도 |
| --- | --- | --- |
| is_admin | `BooleanField(default=False)` | 관리자 페이지 접근 권한 |
| admin_memo | `TextField(blank=True)` | 운영자만 보는 회원 메모 |

배포 후 일반 회원이 아래 요청을 보냈다.

```
PATCH /api/members/me/
{"nickname": "neo", "is_admin": true}
```', 'OBJECTIVE'),
       (4514, 722, '아래 코드를 실행한 뒤 serializer.errors에 담기는 키로 옳은 것은?', '```python
class BookingSerializer(serializers.Serializer):
    date = serializers.DateField()
    people = serializers.IntegerField()
    coupon = serializers.CharField()

    def validate_people(self, value):
        if value > 8:
            raise serializers.ValidationError("8명까지만 예약할 수 있습니다.")
        return value

    def validate_coupon(self, value):
        if not value.startswith("GR"):
            raise serializers.ValidationError("사용할 수 없는 쿠폰입니다.")
        return value

    def validate(self, attrs):
        if attrs["people"] >= 5 and attrs["coupon"]:
            raise serializers.ValidationError("5명 이상 예약에는 쿠폰을 쓸 수 없습니다.")
        return attrs


serializer = BookingSerializer(
    data={"date": "2026-02-30", "people": 10, "coupon": "SUMMER"}
)
serializer.is_valid()
```

2026년 2월은 28일까지다.', 'OBJECTIVE'),
       (4515, 722, '아래 수정 코드의 ??? 자리에 들어갈 Django API의 이름은?', '주문 생성 API의 `OrderSerializer.create()`는 처음에 이렇게 작성돼 있었다.

```python
def create(self, validated_data):
    items_data = validated_data.pop("items")
    order = Order.objects.create(**validated_data)
    OrderItem.objects.bulk_create(
        [OrderItem(order=order, **item) for item in items_data]
    )
    return order
```

`OrderItem`에는 (order, product) 유니크 제약이 있다. 한 요청에 같은 상품이 두 줄로 들어오자 `bulk_create()`에서 `IntegrityError`가 나 500 응답이 나갔다. 그런데 DB를 보니 항목이 하나도 없는 주문 행이 남아 있었고, 이런 빈 주문이 한 달 새 37건 쌓였다.

아래처럼 고친 뒤로는 같은 요청에 여전히 500이 나가지만, 빈 주문 행은 더 이상 생기지 않았다.

```python
def create(self, validated_data):
    items_data = validated_data.pop("items")
    with ???():
        order = Order.objects.create(**validated_data)
        OrderItem.objects.bulk_create(
            [OrderItem(order=order, **item) for item in items_data]
        )
    return order
```', 'SUBJECTIVE'),
       (4516, 722, '아래 코드의 ??? 자리에 들어간 설정의 이름은?', '주문 목록 API의 시리얼라이저에 한 줄을 추가했다. 뷰의 `get_queryset()`은 `Order.objects.all()`이고, 목록은 주문 20건을 응답한다.

```python
class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ["id", "customer", "total"]
        ??? = 1
```

`customer`는 `Customer` 모델을 가리키는 ForeignKey다. 한 줄을 추가하기 전후로 아래처럼 달라졌다.

| 항목 | 추가 전 | 추가 후 |
| --- | --- | --- |
| 응답의 customer 값 | `7` | `{"id": 7, "name": "김철수", "grade": "GOLD"}` |
| 목록 응답 한 번의 SQL 실행 수 | 1회 | 21회 |
| POST 본문에 보낸 `"customer": 7` | validated_data에 담김 | validated_data에서 빠짐 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4511
(12203, 4511, 'save(author=request.user)를 is_valid() 앞줄로 옮기면 author가 먼저 채워져 필수 검사를 통과한다.', 'save()가 검증보다 먼저 값을 채워 줄 수 있다는 오해다. save()는 is_valid()를 부르기 전에 호출하면 AssertionError를 던진다. 합칠 validated_data가 아직 없기 때문이다.', false),
(12204, 4511, 'validate()에서 attrs에 author를 채워 넣으면 필드 검사에서 난 누락 오류가 덮여 통과한다.', 'validate()가 필드 검사의 누락을 메워 줄 수 있다는 오해다. author 누락은 필드 단위 단계에서 오류로 확정되고, 필드 오류가 하나라도 있으면 validate()는 실행되지 않는다.', false),
(12205, 4511, 'author가 입력을 받는 필수 필드라 검증에서 막혔다. read_only_fields에 넣으면 뷰는 그대로 둬도 저장된다.', 'save()에 넘긴 값은 검증이 끝난 뒤에야 validated_data에 합쳐지므로, 검증 시점의 author는 비어 있다. author를 읽기 전용으로 두면 입력 검사에서 빠지고 save() 때 request.user가 들어간다.', true),
(12206, 4511, 'author를 fields에서 빼면 400은 사라지지만, save()에 넘긴 author도 함께 버려져 저장 단계에서 실패한다.', 'save()의 인자가 fields에 선언된 필드에만 반영된다는 오해다. 넘긴 값은 fields와 무관하게 validated_data에 합쳐져 create()로 전달되므로 author는 저장된다. 응답에서 author가 빠질 뿐이다.', false),

-- 문제 4512
(12207, 4512, 'id=12 행 하나만 남고, 그 행의 capacity가 30에서 50으로 바뀐다.', 'URL의 pk나 본문의 id가 수정 대상을 정한다는 오해다. 뷰가 조회한 event를 시리얼라이저에 넘기지 않았고, 자동 증가 id는 읽기 전용 필드라 본문의 12도 버려진다.', false),
(12208, 4512, 'id=12 행은 capacity 30 그대로 남고, capacity가 50인 행이 새 id로 하나 더 생긴다.', '시리얼라이저에 instance 없이 data만 넘겼으므로 save()는 update()가 아니라 create()를 부른다. 본문의 id는 읽기 전용이라 validated_data에 들어가지 않고, 새 행이 새 id로 추가된다.', true),
(12209, 4512, 'id=12 행이 지워지고, capacity가 50인 행이 새 id로 다시 만들어져 행은 하나다.', 'PUT이 전체 교체이니 삭제 후 재생성된다는 오해다. HTTP 메서드는 save()의 동작을 정하지 않는다. save()는 instance 유무만 보고 create() 또는 update()를 부르며, 어느 쪽도 기존 행을 지우지 않는다.', false),
(12210, 4512, '본문의 id 12가 이미 있는 값이라 기본 키 충돌 오류가 나고, 테이블은 요청 전과 같다.', '본문의 id가 INSERT에 그대로 쓰인다는 오해다. ModelSerializer는 자동 증가 id를 읽기 전용 필드로 만들어 입력 값을 validated_data에 넣지 않으므로, DB가 새 id를 부여해 충돌이 없다.', false),

-- 문제 4513
(12211, 4513, '시리얼라이저 코드를 고치지 않았으므로 새 필드는 매핑되지 않아, nickname만 바뀌고 응답에도 두 필드가 없다.', '코드를 안 바꾸면 필드 목록도 그대로라는 오해다. __all__은 모델 정의를 읽어 필드를 만들기 때문에, 모델에 필드를 더하면 시리얼라이저 수정 없이 입력과 출력에 함께 들어온다.', false),
(12212, 4513, 'is_admin은 모델에 default가 있어 읽기 전용 필드로 만들어지므로, 요청의 true는 무시되고 nickname만 바뀐다.', 'default가 있으면 읽기 전용이 된다는 오해다. default는 required=False를 만들 뿐 입력은 그대로 받는다. 입력을 막으려면 read_only_fields에 직접 넣어야 한다.', false),
(12213, 4513, 'is_admin은 true로 저장되지만, admin_memo는 요청에 없던 필드라 응답 JSON에서 빠진다.', 'PATCH 응답에는 보낸 필드만 담긴다는 오해다. partial=True는 입력에서 빠진 필드의 필수 검사만 건너뛸 뿐이고, serializer.data는 instance 전체를 fields 기준으로 그리므로 admin_memo도 실린다.', false),
(12214, 4513, 'is_admin이 true로 저장돼 이 회원이 관리자 권한을 얻고, 응답 JSON에는 admin_memo까지 실린다.', '__all__은 모델의 모든 필드를 자동 매핑해 새 필드를 입력과 출력 양쪽에 그대로 연다. 쓰기 가능한 is_admin이 저장되고 admin_memo도 응답에 실린다. 노출할 필드는 목록으로 직접 적어야 막을 수 있다.', true),

-- 문제 4514
(12215, 4514, 'date, people, coupon', '필드 단위 단계는 한 필드가 실패해도 다음 필드의 변환·검증기·필드 훅을 계속 돌리고, 오류를 필드 이름별로 모은 뒤에 멈춘다. 그래서 두 훅의 오류도 담기지만, 필드 오류가 있으니 validate()는 실행되지 않는다.', true),
(12216, 4514, 'date', '첫 필드 오류에서 곧바로 멈춘다는 오해다. 건너뛰는 것은 실패한 그 필드의 뒷단계와 객체 단위 validate()뿐이고, 다른 필드는 따로 검사되어 people과 coupon 훅의 오류도 함께 모인다.', false),
(12217, 4514, 'date, people, coupon, non_field_errors', 'validate()까지 끝까지 돌려 모든 오류를 한 번에 준다는 오해다. 필드 단위에서 오류가 하나라도 모이면 거기서 멈추므로 validate()는 호출되지 않고 non_field_errors도 생기지 않는다.', false),
(12218, 4514, 'date, non_field_errors', '필드 훅이 시리얼라이저 메서드라 그 오류가 non_field_errors로 간다는 오해다. validate_<필드명>의 오류는 그 필드 이름을 키로 담기고, non_field_errors는 validate()처럼 필드를 지정하지 않은 객체 단위 오류에 쓰인다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1460, 4515, 'transaction.atomic,atomic,django.db.transaction.atomic,transaction.atomic(),atomic()', 'transaction.atomic은 블록 안의 DB 작업을 하나의 트랜잭션으로 묶어, 블록 안에서 예외가 나면 앞서 실행한 INSERT까지 함께 롤백한다. Django는 기본이 자동 커밋이라 원래 코드에서는 Order.objects.create()가 끝나는 순간 주문 행이 확정됐고, 뒤이은 bulk_create() 실패와 상관없이 그대로 남았다. atomic은 예외를 삼키지 않으므로 응답은 여전히 500이지만, 절반만 저장된 데이터는 남지 않는다. 중첩 시리얼라이저로 부모와 자식을 함께 저장하는 create()를 직접 구현할 때 꼭 챙겨야 하는 부분이다. 헷갈리기 쉬운 옆 개념과 구분하면, is_valid()의 검증은 저장 전에 입력을 거르는 단계일 뿐 저장 도중의 실패를 되돌리지 못한다. 또 ModelSerializer가 유니크 제약을 보고 자동으로 붙이는 UniqueTogetherValidator도 여기서는 막아 주지 못한다. 자식 시리얼라이저의 필드에 order가 없어 검증기가 붙지 않고, 같은 요청 안의 두 줄은 아직 DB에 없어 조회로도 걸리지 않기 때문이다.'),
       (1461, 4516, 'depth,depth=1,depth = 1,뎁스', 'depth는 ModelSerializer가 관계 필드를 지정한 깊이만큼 중첩 시리얼라이저로 자동으로 펼쳐 주는 Meta 옵션이다. depth = 1이면 customer의 기본 키 대신 Customer 행 전체가 응답에 실린다. 편하지만 대가가 두 가지다. 첫째, 이렇게 자동으로 만든 중첩 필드는 읽기 전용이라 POST 본문의 customer 값을 받지 못한다. 쓰기가 필요하면 쓰기용 시리얼라이저를 따로 두고 뷰의 get_serializer_class()에서 self.action에 따라 고른다. 둘째, 주문마다 order.customer에 접근하면서 고객 조회가 한 번씩 나가 1 + 20 = 21회의 N+1이 생긴다. 이 해결은 시리얼라이저가 아니라 뷰의 get_queryset()에서 select_related("customer")로 한다. 헷갈리기 쉬운 옆 개념과 구분하면, read_only_fields는 응답 모양은 그대로 둔 채 입력만 막는 옵션이다. 또 customer = CustomerSerializer(read_only=True)처럼 중첩 시리얼라이저를 필드로 직접 선언하면 같은 모양을 내면서도 어떤 관계를 어떤 필드 구성으로 펼칠지 관계마다 고를 수 있다. depth는 지정한 깊이 안의 모든 관계를 한꺼번에 펼친다.');

-- =====================================================
-- Lesson 880: DRF 시리얼라이저 — 검증 전후의 호출 규칙, 변환된 값, 서비스 함수와의 역할 분담
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5459, 880, '아래 뷰가 요청을 처리한 결과로 옳은 것은?', '디버깅을 위해 댓글 작성 뷰에 로그 한 줄을 추가해 배포했다.

```python
class CommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ["id", "post", "body"]


class CommentCreateView(APIView):
    def post(self, request):
        serializer = CommentSerializer(data=request.data)
        logger.info("comment payload: %s", serializer.data)  # 추가한 줄
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
```

배포 후 `{"post": 3, "body": "잘 읽었습니다"}`처럼 형식에 맞는 요청이 들어왔다. id가 3인 게시글은 존재한다.', 'OBJECTIVE'),
       (5460, 880, '아래 코드로 요청 본문을 검증한 결과로 옳은 것은?', '장바구니 담기 API다. 앱이 입력값을 문자열 그대로 보내서, 요청 본문은 `{"product_id": "15", "qty": "0"}`이었다.

```python
class CartItemSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    qty = serializers.IntegerField()

    def validate_qty(self, value):
        if value == "0":
            raise serializers.ValidationError("수량은 1개 이상이어야 합니다.")
        return value


serializer = CartItemSerializer(data=request.data)
serializer.is_valid()
```', 'OBJECTIVE'),
       (5461, 880, '아래 요청을 처리한 뒤의 응답과 DB에 저장된 값으로 옳은 것은?', '신규 상품은 오픈 기념으로 입력 가격의 절반에 등록하기로 하고, 상품 등록 뷰를 이렇게 작성했다.

```python
class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ["id", "name", "price"]

    def validate_price(self, value):
        if value < 1000:
            raise serializers.ValidationError("가격은 1,000원 이상이어야 합니다.")
        return value


class ProductCreateView(APIView):
    def post(self, request):
        serializer = ProductSerializer(data=request.data)
        if serializer.is_valid():
            half = serializer.validated_data["price"] // 2
            serializer.save(price=half)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
```

관리자가 `{"name": "머그컵", "price": 1500}`으로 요청을 보냈다. Product 모델의 price는 별도 제약이 없는 정수 필드다.', 'OBJECTIVE'),
       (5462, 880, '아래 새 요구사항을 반영하는 방법에 대한 설명으로 옳은 것은?', '포인트 충전 API의 시리얼라이저다. 충전 API에서는 문제없이 동작한다.

```python
class PointChargeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PointHistory
        fields = ["amount"]

    def create(self, validated_data):
        user = self.context["request"].user
        with transaction.atomic():
            wallet = Wallet.objects.select_for_update().get(user=user)
            wallet.balance += validated_data["amount"]
            wallet.save()
            return PointHistory.objects.create(user=user, **validated_data)
```

새 요구사항: 매월 1일 새벽, 전체 회원에게 1,000포인트씩 지급하는 관리자 명령(`python manage.py grant_monthly_points`)을 만든다. 이 명령은 HTTP 요청 없이 서버에서 직접 실행되며, 지급 방식(지갑 잔액 증가와 내역 한 줄 추가)은 충전 API와 똑같아야 한다.', 'OBJECTIVE'),
       (5463, 880, '아래 코드의 ??? 자리에 들어갈 메서드의 이름은?', '주문 API의 ViewSet은 처음에 OrderSerializer 하나로 모든 요청을 처리했다. OrderSerializer는 응답에 고객 정보를 펼쳐 보여 주려고 `customer = CustomerSerializer(read_only=True)`로 선언돼 있었다. 고객 id를 받는 OrderWriteSerializer를 새로 만든 뒤, ViewSet을 아래처럼 고쳤다.

```python
class OrderWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ["id", "customer", "total"]


class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.select_related("customer")

    def ???(self):
        if self.action in ("list", "retrieve"):
            return OrderSerializer
        return OrderWriteSerializer
```

고치기 전후로 아래처럼 달라졌다.

| 요청 | 고치기 전 | 고친 뒤 |
| --- | --- | --- |
| `GET /orders/` 응답의 customer | `{"id": 7, "name": "김철수"}` | `{"id": 7, "name": "김철수"}` |
| `POST /orders/` 본문 `{"customer": 7, "total": 32000}` | 500 (customer_id NOT NULL 위반) | 201 |', 'SUBJECTIVE'),
       (5464, 880, '아래 500 응답을 400으로 바꾸려고 뷰 코드에 추가한 인자의 이름은?', '```python
class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = ["id", "title", "capacity"]

    def validate_capacity(self, value):
        if value <= 0:
            raise serializers.ValidationError("정원은 1 이상이어야 합니다.")
        return value


class EventCreateView(APIView):
    def post(self, request):
        serializer = EventSerializer(data=request.data)
        serializer.is_valid()
        serializer.save()
        return Response(serializer.data, status=201)
```

`{"title": "알고리즘 스터디", "capacity": 0}`을 보내자 응답은 500이었고, 서버 로그에는 이렇게 남았다.

```
AssertionError: You cannot call `.save()` on a serializer with invalid data.
```

뷰 코드의 한 줄에 키워드 인자 하나를 `=True`로 추가하자, 같은 요청에 아래 400 응답이 돌아왔고 AssertionError는 더 이상 남지 않았다. 다른 줄은 고치지 않았다.

```json
{"capacity": ["정원은 1 이상이어야 합니다."]}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5459
(14731, 5459, '로그에 요청 본문이 그대로 찍히고, 검증과 저장을 거쳐 201 응답이 나간다.', 'serializer.data를 입력 원본으로 오해한 것이다. data는 출력용 표현이고, 검증 전 원본은 initial_data에 있다. 게다가 data=로 입력을 넘긴 시리얼라이저는 검증 전 data 접근 자체를 막는다.', false),
(14732, 5459, '로그 줄에서 AssertionError가 나고, 검증과 저장 없이 500 응답이 나간다.', 'data=로 만든 시리얼라이저는 is_valid()를 부르기 전에 data에 접근하면 AssertionError를 던진다. 이 예외는 400으로 바뀌지 않아 500이 되고, 뒤의 검증·저장 줄은 실행되지 않는다. 원본을 찍으려면 initial_data를 쓴다.', true),
(14733, 5459, '검증 전이라 로그에 빈 딕셔너리 {}가 찍히고, 이어서 201 응답이 나간다.', '검증 전에는 data가 비어 있을 뿐이라는 오해다. data=로 입력을 넘긴 시리얼라이저는 is_valid() 전의 data 접근을 빈 값으로 넘기지 않고 AssertionError로 막아, 로그 줄에서 요청 처리가 끝난다.', false),
(14734, 5459, 'data 접근이 is_valid()를 대신 불러 검증된 값이 찍히고, 201 응답이 나간다.', 'data가 필요하면 검증을 알아서 돌려 준다는 오해다. DRF는 검증을 자동으로 시작하지 않으며, 순서를 어기면 AssertionError로 알린다. 검증은 항상 뷰가 is_valid()로 직접 시작해야 한다.', false),

-- 문제 5460
(14735, 5460, 'is_valid()는 False이고, errors의 qty에 "수량은 1개 이상이어야 합니다."가 담긴다.', '필드 훅이 요청에 적힌 문자열을 그대로 받는다는 오해다. 훅은 IntegerField가 변환을 마친 정수 0을 받으므로 0 == "0"은 거짓이 되어 오류가 나지 않는다.', false),
(14736, 5460, 'is_valid()는 False이고, errors의 qty에 정수 형식이 아니라는 오류가 담긴다.', 'IntegerField가 숫자 모양의 문자열도 거부한다는 오해다. "0"·"15"처럼 정수로 바꿀 수 있는 문자열은 변환 단계에서 정수가 되어 통과한다. 거부되는 것은 "abc"처럼 바꿀 수 없는 값이다.', false),
(14737, 5460, '정수와 문자열을 비교하다 TypeError가 나고, 500 응답으로 끝난다.', '파이썬의 ==는 타입이 달라도 예외 없이 False를 돌려준다. TypeError는 <·> 같은 크기 비교에서 나는 것이라, 이 훅은 조용히 통과한다. 바로 그 조용함 때문에 버그가 늦게 드러난다.', false),
(14738, 5460, 'is_valid()는 True이고, validated_data의 qty에는 정수 0이 담긴다.', '필드 훅은 타입 변환이 끝난 값을 받는다. qty는 이미 정수 0이라 문자열 "0"과 같지 않아 검사를 그대로 통과하고, 0개 담기가 허용된다. value < 1로 비교하거나 min_value=1을 주어야 막힌다.', true),

-- 문제 5461
(14739, 5461, '201 응답이고, DB에는 price 750이 저장된다.', 'save()에 넘긴 값은 검증을 다시 거치지 않고 validated_data에 합쳐지며, 키가 같으면 넘긴 값이 덮어쓴다. 그래서 validate_price의 1,000원 하한을 벗어난 750이 그대로 저장된다. 서버가 정한 값은 서버가 직접 확인해야 한다.', true),
(14740, 5461, '201 응답이고, DB에는 요청 값인 price 1,500이 저장된다.', 'save()의 인자가 빈 키만 채우고 검증된 값은 건드리지 않는다는 오해다. 인자는 validated_data에 합쳐질 때 같은 키를 덮어쓰므로 1,500이 아니라 750이 create()로 전달된다.', false),
(14741, 5461, '400 응답이고, 750이 validate_price에 걸려 아무것도 저장되지 않는다.', 'save()에 넘긴 값도 검증을 거친다는 오해다. 검증은 is_valid()에서 요청 값 1,500으로 이미 끝났고, save() 인자는 검증 없이 합쳐진다. 서버가 정하는 값을 넣는 통로라 검증을 건너뛴다.', false),
(14742, 5461, '500 응답이고, price 키가 validated_data와 겹쳐 인자 중복 오류가 난다.', 'save()가 validated_data와 인자를 따로따로 create()에 넘긴다는 오해다. DRF는 두 딕셔너리를 하나로 합친 뒤 넘기므로 키가 겹쳐도 오류 없이 인자 쪽 값이 남는다.', false),

-- 문제 5462
(14743, 5462, '명령에서 PointChargeSerializer(data={"amount": 1000})로 검증한 뒤 save()하면 충전 규칙을 그대로 재사용할 수 있다.', '시리얼라이저를 어디서든 그대로 재사용할 수 있다는 오해다. create()가 self.context의 request에서 회원을 꺼내는데, 명령에는 요청이 없어 context가 비어 있으므로 save() 시점에 KeyError가 난다.', false),
(14744, 5462, 'create() 오버라이드를 지우면 ModelSerializer가 자동으로 만든 create()가 잔액 갱신까지 처리한다.', '자동 생성된 create()가 업무 규칙까지 안다는 오해다. 자동 create()는 PointHistory 행 하나를 만들 뿐, 지갑 잠금·잔액 갱신 같은 규칙은 모른다. user도 채워지지 않는다.', false),
(14745, 5462, '충전 규칙을 서비스 함수로 옮기고, 충전 뷰와 관리자 명령이 모두 그 함수를 호출하게 한다.', '업무 규칙을 요청과 무관한 서비스 함수에 두면 API·관리자 명령·배치가 같은 규칙을 함께 쓴다. 시리얼라이저는 입력 검증과 출력 형식만 맡고, 뷰는 검증을 마친 뒤 서비스 함수를 부르면 된다.', true),
(14746, 5462, '잔액 갱신을 validate()로 옮기면 is_valid()만 불러도 충전되므로, 명령에서도 간단히 재사용할 수 있다.', '검증 단계에 업무 처리를 넣어도 된다는 오해다. validate()는 입력을 확인하는 자리라, 부수 효과를 두면 저장하지 않을 검증에서도 잔액이 바뀐다. 회원을 여전히 request에서 꺼낸다면 명령에서는 쓸 수도 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1776, 5463, 'get_serializer_class,get_serializer_class(),get_serializer_class(self),def get_serializer_class(self),GenericAPIView.get_serializer_class', 'get_serializer_class는 GenericAPIView가 이번 요청에 쓸 시리얼라이저 클래스를 얻으려고 부르는 메서드다. 기본 구현은 serializer_class 속성을 그대로 돌려주지만, 오버라이드하면 ViewSet의 self.action(list·retrieve·create 등)에 따라 다른 클래스를 고를 수 있다. 고치기 전에는 customer가 read_only 중첩 필드라 POST 본문의 customer 값이 입력에서 버려졌고, 고객 없이 INSERT를 시도해 NOT NULL 위반으로 500이 났다. 읽기용과 쓰기용을 나누면 응답 모양과 입력 규칙을 따로 관리할 수 있다. 헷갈리기 쉬운 옆 메서드와 구분하면, get_serializer는 클래스가 아니라 시리얼라이저 인스턴스를 돌려주는 메서드로, 내부에서 get_serializer_class()를 부른 뒤 context에 request를 넣어 인스턴스를 만든다. get_queryset은 어떤 데이터를 가져올지를 정할 뿐 시리얼라이저 선택과는 관계가 없다.'),
       (1777, 5464, 'raise_exception,raise_exception=True,raise_exception = True,레이즈 익셉션,레이즈익셉션', 'is_valid(raise_exception=True)는 검증이 실패하면 False를 돌려주는 대신 ValidationError를 던진다. DRF의 예외 처리기가 이 예외를 받아 serializer.errors를 본문으로 한 400 응답으로 바꾸므로, 뒤의 save() 줄은 실행되지 않는다. 원래 코드는 is_valid()가 돌려준 False를 무시하고 save()를 불렀는데, save()는 오류가 있는 시리얼라이저에서 호출되면 AssertionError를 던진다. 이 예외는 DRF가 400으로 바꿔 주는 대상이 아니어서 500이 났다. 헷갈리기 쉬운 옆 방식과 구분하면, if serializer.is_valid(): 로 반환값을 확인하고 실패 시 Response(serializer.errors, status=400)를 직접 돌려줘도 결과는 같지만 분기를 손으로 써야 한다. 또 생성자에 넘기는 partial=True는 보내지 않은 필드의 필수 검사만 건너뛸 뿐, 보낸 capacity=0의 검증 실패는 막지 못한다.');
