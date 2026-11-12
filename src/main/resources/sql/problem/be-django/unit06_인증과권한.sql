-- Unit: 인증과 권한 (Unit ID: 137)
-- Chapter: Django (Chapter ID: 12)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (563, 137, '커스텀 사용자 모델과 객체 권한'),
       (721, 137, '권한 조합과 권한 캐시, 401·403'),
       (879, 137, 'Django·DRF 인증과 권한 — 권한 검사 범위·전역 기본값·CSRF·비밀번호 해시');

-- =====================================================
-- Lesson 563: 커스텀 사용자 모델과 객체 권한
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3557, 563, '아래 비교표를 바탕으로 커스텀 사용자 모델 설계를 판단할 때, 옳지 않은 것은?', '커스텀 사용자 모델을 만들 때 고를 수 있는 두 기반 클래스를 정리한 표다.

| 항목 | A 방식 | B 방식 |
|---|---|---|
| 상속 대상 | AbstractUser | AbstractBaseUser + PermissionsMixin |
| 물려받는 필드 | username, email, first_name, last_name, is_staff, is_active, date_joined 전부 | password, last_login 두 개뿐 |
| 로그인 식별자 | 기본은 username이며 다른 필드로 바꿀 수 있음 | 어떤 필드를 쓸지 직접 지정 |
| 매니저 | 기본 UserManager를 그대로 사용 | BaseUserManager를 상속해 직접 작성 |
| 관리자 화면 | UserAdmin과 기본 폼을 그대로 사용 | 관리자 폼을 새로 맞춰야 함 |', 'OBJECTIVE'),
       (3558, 563, '아래 코드에서 서버 기동이 실패한 원인으로 옳은 것은?', '```python
# blog/models.py
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Post(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
```

서버 기동 로그:

```
django.core.exceptions.AppRegistryNotReady: Models aren''t loaded yet.
```', 'OBJECTIVE'),
       (3559, 563, '아래 코드에서 사용자 B가 보낸 PATCH 요청이 처리되는 결과로 옳은 것은?', '```python
class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.author_id == request.user.id


class PostDetail(APIView):
    permission_classes = [IsOwnerOrReadOnly]

    def patch(self, request, pk):
        post = Post.objects.get(pk=pk)
        serializer = PostSerializer(post, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
```

로그인한 사용자 B가 다른 사용자 A가 작성한 글(pk=7)에 PATCH 요청을 보냈다.', 'OBJECTIVE'),
       (3560, 563, '아래 설정에서 API 요청만 계속 막히는 원인으로 옳은 것은?', '```python
# settings.py
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [],
    "DEFAULT_PERMISSION_CLASSES": ["rest_framework.permissions.IsAuthenticated"],
}
```

증상: 세션 로그인을 마친 사용자가 같은 브라우저에서 Django 템플릿 페이지를 열면 자기 닉네임이 정상 출력된다. 그런데 /api/orders/를 호출하면 로그인 상태와 무관하게 언제나 403과 함께 {"detail": "이 작업을 수행할 권한이 없습니다."}가 돌아온다.', 'OBJECTIVE'),
       (3561, 563, '아래 회고에서 첫 마이그레이션 전에 지정했어야 한다고 지목한 settings 설정의 이름은?', '기본 사용자 모델로 6개월 운영한 서비스에 nickname을 추가하려고, accounts 앱에 사용자 모델을 새로 만들었다. 마이그레이션을 돌리자 auth_user를 참조하던 권한·그룹·관리자 로그 테이블의 FK가 줄줄이 깨졌고, 이미 쌓인 계정 데이터를 옮기며 마이그레이션 이력을 손보는 데 이틀이 걸렸다. 회고에는 "첫 migrate 전에 settings.py에 이 설정 한 줄만 잡아 뒀으면 끝났을 일"이라고 적혔다.', 'SUBJECTIVE'),
       (3562, 563, '아래 상황에서 추가한 사용자 모델 클래스 속성의 이름은?', '이메일만으로 로그인하는 서비스를 만들려고 AbstractUser를 상속한 사용자 모델을 정의하고 email 필드에 unique=True를 걸었다. 그런데 createsuperuser는 계속 username부터 물었고, 로그인 요청에 email과 password를 담아 보내면 인증이 실패했다. 모델 클래스에 속성 하나를 추가해 그 값으로 "email"을 지정하자, 이번에는 "이 속성으로 지정한 필드는 REQUIRED_FIELDS에 함께 넣을 수 없다"는 auth.E002 체크 오류로 기동조차 되지 않았다. AbstractUser에서 물려받은 REQUIRED_FIELDS에서 email을 빼고 나서야 두 증상이 함께 사라졌다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3557
(9659, 3557, 'B 방식으로 만든 모델에 is_active를 직접 정의하지 않으면 계정 비활성화로 로그인을 막는 흐름을 스스로 설계해야 한다.', 'B가 물려받는 것은 password와 last_login뿐이라 활성 여부 필드가 없다. ModelBackend가 볼 판단 근거가 사라지므로 직접 정의해야 한다 — 참인 진술.', false),
(9660, 3557, 'B 방식에서 매니저를 작성하지 않은 채 createsuperuser를 실행하면 슈퍼유저 생성이 정상 동작하지 않는다.', 'B는 BaseUserManager를 상속해 create_user·create_superuser를 직접 써야 한다. createsuperuser는 이 매니저 메서드를 진입점으로 삼는다 — 참인 진술.', false),
(9661, 3557, 'A 방식은 로그인 식별자가 username으로 고정돼 이메일만으로 로그인시키려면 B 방식으로 다시 만들어야 한다.', '표는 A의 식별자를 "다른 필드로 바꿀 수 있음"이라고 적었다. A도 식별자를 이메일로 바꿀 수 있어 기반 클래스를 갈아엎을 이유가 없다 — 표에 정면으로 걸리는 거짓 진술.', true),
(9662, 3557, '가입 시각을 남겨야 한다면 A 방식은 추가 작업이 없지만 B 방식은 해당 필드를 직접 정의해야 한다.', 'date_joined는 A가 물려받는 필드 목록에 있고 B에는 없다. B는 가입 시각을 남기려면 필드를 스스로 선언해야 한다 — 참인 진술.', false),

-- 문제 3558
(9663, 3558, '마이그레이션 파일을 아직 만들지 않아 author 필드가 참조할 테이블이 존재하지 않는다.', '테이블 부재는 마이그레이션이나 쿼리 단계의 문제이며 OperationalError 계열로 나타난다. 앱 레지스트리 준비 여부와는 다른 층위다.', false),
(9664, 3558, '앱 로딩이 끝나기 전인 모듈 임포트 시점에 사용자 모델 클래스를 꺼내려 했다.', 'get_user_model()은 앱 레지스트리에서 모델 클래스를 찾아 돌려준다. models.py 최상단은 레지스트리가 채워지기 전이라 호출 즉시 AppRegistryNotReady가 난다. 모델 정의에서는 문자열 설정값으로 사용자 모델을 가리켜야 한다.', true),
(9665, 3558, 'accounts 앱이 blog 앱보다 INSTALLED_APPS 뒤쪽에 있어 임포트 순서가 어긋났다.', '앱 순서를 바꿔도 models.py를 읽는 시점 자체가 레지스트리 준비 전이라 같은 오류가 난다. 순서 조정으로 넘기려는 흔한 오진이다.', false),
(9666, 3558, 'ForeignKey에 모델 클래스를 넘겨서 생긴 오류라 클래스를 앱 라벨 문자열로 바꾸면 해결된다.', 'FK 인자를 문자열로 바꿔도 윗줄의 모듈 최상단 호출이 그대로 남아 오류는 유지된다. 증상이 아니라 호출 시점을 고쳐야 한다.', false),

-- 문제 3559
(9667, 3559, '권한 클래스에 has_permission이 없어 뷰 진입 단계에서 막히고 403이 반환된다.', 'has_permission을 생략하면 BasePermission의 기본값 True가 쓰여 뷰 진입은 그대로 허용된다. 미구현을 거부로 오해한 것이다.', false),
(9668, 3559, '응답을 직렬화하기 직전에 DRF가 has_object_permission을 자동으로 호출해 403이 반환된다.', '객체 검사는 check_object_permissions()가 부를 때만 일어난다. 응답 직전에 알아서 도는 훅은 없다.', false),
(9669, 3559, 'serializer.save() 시점에 작성자 검사가 걸려 수정이 취소되고 400이 반환된다.', 'serializer는 필드 유효성 검사와 저장만 맡는다. 요청자와 작성자가 같은지는 권한 클래스의 몫이라 400도 나지 않는다.', false),
(9670, 3559, 'has_object_permission이 한 번도 호출되지 않아 A의 글이 B의 요청대로 수정된다.', '본문은 get_object() 대신 Post.objects.get(pk=pk)로 객체를 꺼냈다. 이 경로에서는 check_object_permissions()가 불리지 않아 소유자 검사가 통째로 건너뛰어진다. 직접 조회할 때는 self.check_object_permissions(request, obj)를 명시해야 한다.', true),

-- 문제 3560
(9671, 3560, 'DRF가 자신의 인증 클래스로 request.user를 다시 정하는데 그 목록이 비어 있어 늘 익명 사용자가 된다.', '미들웨어가 세션으로 채운 request.user를 DRF는 그대로 믿지 않고 자기 인증 클래스로 다시 판단한다. 후보가 하나도 없으니 AnonymousUser가 확정돼 IsAuthenticated가 항상 실패한다. 시도해 볼 인증 수단조차 없어 인증 요구가 아닌 권한 거부 응답으로 끝난다.', true),
(9672, 3560, '세션 쿠키가 만료돼 Django 미들웨어 단계에서 로그인이 이미 풀렸다.', '같은 브라우저의 템플릿 페이지에서 닉네임이 정상 출력되므로 세션은 살아 있다. 세션이 풀렸다면 템플릿 쪽도 함께 익명이 되어야 하는데 증상이 API 경로에만 나타난다.', false),
(9673, 3560, 'IsAuthenticated는 is_staff가 True인 사용자만 통과시키므로 일반 사용자는 막힌다.', 'is_staff를 요구하는 것은 IsAdminUser다. IsAuthenticated는 로그인 여부만 본다. 두 내장 권한 클래스를 뒤바꾼 오개념이다.', false),
(9674, 3560, 'SessionAuthentication의 CSRF 검사에서 토큰을 찾지 못해 요청이 거부됐다.', '인증 클래스 목록이 비어 있어 SessionAuthentication 자체가 동작하지 않는다. 게다가 CSRF 실패는 안전하지 않은 메서드에서 나며 조회까지 막지는 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1142, 3561, 'AUTH_USER_MODEL,auth_user_model,settings.AUTH_USER_MODEL,AUTH USER MODEL', '프로젝트가 어떤 사용자 모델을 쓸지 Django 전체에 알리는 설정이 AUTH_USER_MODEL이다. 첫 migrate 이후에 바꾸면 auth_user를 참조하던 FK·M2M을 손으로 옮기고 마이그레이션 이력까지 손봐야 해서, 당장 추가할 필드가 없어도 빈 AbstractUser 상속 모델을 만들어 미리 지정해 두는 것이 표준 관행이다. 모델 정의에서 사용자 모델을 가리킬 때 쓰는 문자열이 바로 이 설정값이며, 실행 중에 모델 클래스 자체가 필요할 때 부르는 get_user_model()과는 역할이 다르다.'),
       (1143, 3562, 'USERNAME_FIELD,username_field,USERNAME FIELD', '로그인 식별자로 쓸 필드를 알려 주는 속성이 USERNAME_FIELD다. ModelBackend는 이 값으로 사용자를 조회하고 createsuperuser도 이 필드부터 묻기 때문에, email로 지정해야 두 증상이 함께 풀린다. 다만 AbstractUser는 REQUIRED_FIELDS = ["email"]을 함께 물려주므로 식별자만 바꾸면 auth.E002 체크 오류가 난다. 식별자로 지정한 필드와 password는 REQUIRED_FIELDS에서 빼야 한다. createsuperuser가 식별자·비밀번호 외에 추가로 물을 필드를 나열하는 REQUIRED_FIELDS와 역할을 구분해 두자.');

-- =====================================================
-- Lesson 721: 권한 조합과 권한 캐시, 401·403
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4505, 721, '아래 뷰셋 설정에서 요청별 처리 결과로 옳은 것은?', '```python
# 의도: 공지는 누구나 읽고, 작성·수정은 운영자만 한다
class NoticeViewSet(viewsets.ModelViewSet):
    queryset = Notice.objects.all()
    serializer_class = NoticeSerializer
    permission_classes = [
        permissions.IsAdminUser,
        permissions.IsAuthenticatedOrReadOnly,
    ]
```

- 운영자: is_staff=True인 로그인 사용자
- 일반 사용자: is_staff=False인 로그인 사용자
- 인증 설정은 정상 동작하며, 요청 데이터는 모두 유효하다.', 'OBJECTIVE'),
       (4506, 721, '아래 코드를 차례로 실행했을 때 ⓑ와 ⓒ에서 출력되는 값으로 옳은 것은?', '아래 코드를 한 번의 실행 흐름에서 위에서부터 차례로 실행한다.

```python
# kim: is_active=True, is_superuser=False, 소속 그룹 없음, 직접 받은 권한 없음
user = User.objects.get(email="kim@example.com")
print(user.has_perm("blog.publish_post"))    # ⓐ False

perm = Permission.objects.get(
    content_type__app_label="blog", codename="publish_post"
)
user.user_permissions.add(perm)

print(user.has_perm("blog.publish_post"))    # ⓑ
fresh = User.objects.get(pk=user.pk)
print(fresh.has_perm("blog.publish_post"))   # ⓒ
```', 'OBJECTIVE'),
       (4507, 721, '아래 설정과 권한 표에서 사용자 lee가 보낸 요청의 처리 결과로 옳은 것은?', '```python
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.DjangoModelPermissions]
```

| 사용자 | 로그인 | is_superuser | 소속 그룹 | 그룹이 가진 권한 |
|---|---|---|---|---|
| lee | O | False | 교정팀 | blog.change_post |

- lee가 받은 권한은 교정팀 그룹을 통한 것뿐이다.
- 게시글 pk=3의 작성자는 다른 사용자 park이다.
- 요청 데이터는 모두 유효하다.', 'OBJECTIVE'),
       (4508, 721, '아래 설정에서 요청 A·B·C에 돌아가는 응답 상태 코드로 옳은 것은?', '```python
# settings.py
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework.authentication.TokenAuthentication",
    ],
}

# views.py
class SalesStatsView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        return Response({"total": 1280})
```

| 요청 | Authorization 헤더 | 토큰의 주인 |
|---|---|---|
| A | 없음 | 없음 |
| B | Token 9f2c7a1e (DB에 있는 유효한 토큰) | is_staff=False인 일반 사용자 |
| C | Token 00aa11bb (DB에 없는 값) | 없음 |', 'OBJECTIVE'),
       (4509, 721, '아래 상황에서 사용자 모델의 부모 목록에 덧붙인 클래스의 이름은?', '```python
# accounts/models.py
class User(AbstractBaseUser):
    email = models.EmailField(unique=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()  # create_superuser()가 is_staff·is_superuser를 True로 채워 create_user()에 넘김

    USERNAME_FIELD = "email"
```

```
$ python manage.py createsuperuser
Email: admin@example.com
Password: ********
Password (again): ********
Traceback (most recent call last):
  ...
TypeError: User() got unexpected keyword arguments: ''is_superuser''

>>> editor = User.objects.get(email="lee@example.com")
>>> editor.has_perm("blog.publish_post")
AttributeError: ''User'' object has no attribute ''has_perm''
```

기존 부모인 AbstractBaseUser는 그대로 둔 채 클래스 선언의 부모 목록에 클래스 하나를 덧붙이고, 마이그레이션을 다시 만들어 적용하자 두 오류가 모두 사라졌다.', 'SUBJECTIVE'),
       (4510, 721, '아래 상황에서 운영자가 False로 바꾼 사용자 모델 필드의 이름은?', '탈퇴를 요청한 회원 jung의 계정을 user.delete()로 지우면 on_delete=CASCADE로 연결된 주문 42건까지 함께 사라진다. 그래서 운영자는 계정 행을 남겨 둔 채, 가입 때부터 True였던 불리언 필드 하나만 False로 바꿨다. jung은 슈퍼유저도 운영자도 아닌 일반 사용자다. 그 뒤 셸에서 확인한 결과는 다음과 같다.

```
>>> print(authenticate(email="jung@example.com", password="Spring9!pw"))  # 가입 때 쓴 비밀번호
None
>>> jung = User.objects.get(email="jung@example.com")
>>> jung.check_password("Spring9!pw")
True
>>> jung.groups.filter(name="리뷰어").exists()
True
>>> jung.has_perm("reviews.add_review")  # 리뷰어 그룹이 가진 권한
False
>>> Order.objects.filter(buyer=jung).count()
42
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4505
(12187, 4505, '비로그인 사용자가 GET으로 공지 목록을 조회하면 허용된다.', '나열한 권한 클래스 중 하나만 통과하면 된다고 본 OR 오해다. 리스트에 적은 클래스는 모두 통과해야 하므로, IsAuthenticatedOrReadOnly가 읽기를 허용해도 IsAdminUser에서 막힌다.', false),
(12188, 4505, '일반 사용자가 GET으로 공지 목록을 조회하면 거부된다.', 'permission_classes에 나열한 클래스는 AND로 검사된다. 일반 사용자는 IsAdminUser를 통과하지 못해 읽기조차 막힌다. 주석의 의도를 살리려면 읽기 전용 권한 클래스를 만들어 IsAdminUser와 | 연산자로 묶어야 한다.', true),
(12189, 4505, '일반 사용자가 POST로 공지를 작성하면 허용된다.', '리스트의 마지막 클래스만 적용된다고 본 오해다. IsAuthenticatedOrReadOnly는 로그인 사용자의 쓰기를 허용하지만, 앞에 적힌 IsAdminUser도 함께 통과해야 해 거부된다.', false),
(12190, 4505, '운영자가 POST로 공지를 작성하면 거부된다.', '이름의 ReadOnly를 누구에게나 쓰기를 막는다는 뜻으로 오해한 것이다. 이 클래스는 비로그인 요청의 쓰기만 막는다. 운영자는 로그인 상태이고 IsAdminUser도 통과해 작성이 허용된다.', false),

-- 문제 4506
(12191, 4506, 'ⓑ True, ⓒ True', 'user_permissions.add()가 같은 인스턴스의 판정에 곧바로 반영된다고 본 오해다. ⓐ의 has_perm() 호출 때 권한 목록이 user 인스턴스에 캐시돼, ⓑ는 추가 전 목록으로 판정한다.', false),
(12192, 4506, 'ⓑ False, ⓒ False', '권한 변경은 다시 로그인해야 반영된다고 본 오해다. add()는 호출 즉시 DB에 기록되므로, DB에서 새로 조회한 fresh는 캐시가 없어 추가된 권한을 읽고 True가 된다.', false),
(12193, 4506, 'ⓑ True, ⓒ False', 'M2M의 add() 뒤에 save()를 불러야 DB에 저장된다고 본 오해다. add()는 연결 행을 바로 저장해 fresh도 권한을 본다. user는 ⓐ에서 생긴 캐시 때문에 ⓑ에서 True가 나오지 않는다.', false),
(12194, 4506, 'ⓑ False, ⓒ True', 'ⓐ에서 has_perm()을 부르면 권한 목록이 user 인스턴스에 캐시된다. 같은 인스턴스인 ⓑ는 옛 캐시로 False, DB에서 다시 꺼낸 fresh는 권한을 새로 읽어 True다. 권한을 바꾼 뒤에는 다시 조회한 인스턴스로 검사해야 한다.', true),

-- 문제 4507
(12195, 4507, 'park이 쓴 게시글 pk=3에 PATCH를 보내면 제목이 수정된다.', 'DjangoModelPermissions는 PATCH를 change_post 권한에 매핑하는데, 이 권한은 특정 글이 아니라 모델 전체에 걸린다. 작성자 비교가 없어 남의 글도 고쳐진다. 자기 글만 고치게 하려면 has_object_permission을 따로 구현해야 한다.', true),
(12196, 4507, '새 게시글을 만드는 POST 요청이 허용된다.', '수정 권한이 있으면 생성도 된다고 뭉뚱그린 오해다. POST는 add_post 권한에 매핑되는데 lee에게는 change_post뿐이라 거부된다.', false),
(12197, 4507, 'lee가 직접 쓴 게시글에 DELETE를 보내면 삭제된다.', '작성자 본인이면 삭제할 수 있다고 본 오해다. DELETE는 delete_post 권한을 요구하고, 모델 권한은 작성자가 누구인지 보지 않으므로 lee의 요청은 거부된다.', false),
(12198, 4507, 'view_post 권한이 없어 PATCH 요청까지 모두 거부된다.', '쓰기 요청이 조회 권한을 전제로 한다고 본 오해다. PATCH가 요구하는 권한은 change_post 하나이며, view_post 보유 여부는 PATCH 판정에 쓰이지 않는다.', false),

-- 문제 4508
(12199, 4508, 'A 403, B 403, C 403', '거부된 요청을 모두 권한 실패로 뭉뚱그린 오해다. A는 인증 정보가 없고 C는 토큰이 틀려 사용자를 확정하지 못한 인증 실패다. TokenAuthentication은 인증 헤더 방식을 알려 줄 수 있어 이때 401로 응답한다.', false),
(12200, 4508, 'A 401, B 401, C 401', '거부되면 모두 인증 실패라고 본 오해다. B는 유효한 토큰으로 누구인지 확정된 뒤 IsAdminUser의 is_staff 검사에서 막혔다. 인증은 됐지만 허용되지 않은 일이라 권한 실패인 403이다.', false),
(12201, 4508, 'A 401, B 403, C 401', 'A는 토큰이 없어, C는 없는 토큰이라 사용자를 확정하지 못한 인증 실패다. TokenAuthentication은 WWW-Authenticate 헤더를 줄 수 있어 401이 된다. B는 사용자는 확정됐지만 is_staff 검사에서 막힌 권한 실패라 403이다.', true),
(12202, 4508, 'A 403, B 403, C 401', '헤더가 없는 A를 권한 실패로 본 오해다. 인증 클래스가 있는데 어느 것도 인증에 성공하지 못한 채 권한에서 막히면 DRF는 인증 실패로 처리한다. 토큰 방식이라 A도 401이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1458, 4509, 'PermissionsMixin,Permissions Mixin,django.contrib.auth.models.PermissionsMixin,퍼미션스 믹스인,퍼미션 믹스인,권한 믹스인', 'PermissionsMixin은 사용자 모델에 is_superuser·groups·user_permissions 필드와 has_perm() 계열 메서드를 붙여 Django 권한 체계에 연결한다. AbstractBaseUser는 password·last_login만 물려주므로 이 믹스인이 없으면 매니저가 넘긴 is_superuser를 받을 필드도, has_perm()도 없어 본문의 두 오류가 난다. 관리자 사이트도 권한 검사 메서드를 부르므로 제대로 쓸 수 없다. 부모를 AbstractUser로 바꾸는 방법과 구분하자. AbstractUser는 이 믹스인을 이미 포함하지만 username·first_name 같은 기본 필드까지 함께 물려받는다. 식별자와 필드 구성을 직접 통제하려고 AbstractBaseUser를 고른 경우에는 PermissionsMixin을 덧붙인다.'),
       (1459, 4510, 'is_active,is active,is_active=False,user.is_active,jung.is_active', 'is_active는 계정을 쓸 수 있는 상태인지를 나타내는 필드다. False가 되면 기본 인증 백엔드인 ModelBackend가 비밀번호가 맞아도 인증을 거부하고, has_perm()도 그룹이나 직접 받은 권한과 상관없이 항상 False를 돌려준다. 행 자체는 지우지 않으므로 FK로 연결된 주문 기록이 남아, 탈퇴·정지 처리에 delete() 대신 흔히 쓴다. 관리자 사이트 접근 여부만 정하는 is_staff와 구분하자. is_staff를 False로 바꿔도 일반 로그인과 has_perm() 판정은 달라지지 않는다.');

-- =====================================================
-- Lesson 879: Django·DRF 인증과 권한 — 권한 검사 범위·전역 기본값·CSRF·비밀번호 해시
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5453, 879, '아래 뷰셋에서 사용자 B가 보낸 두 요청의 결과로 옳은 것은?', '```python
class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.owner_id == request.user.id


class MemoViewSet(viewsets.ModelViewSet):
    queryset = Memo.objects.all()
    serializer_class = MemoSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]
```

| 메모 pk | 작성자(owner) |
|---|---|
| 1, 2, 3 | 사용자 A |
| 4, 5 | 사용자 B |

사용자 B는 세션으로 정상 로그인한 상태에서 아래 두 요청을 보냈다.

- 요청 1: GET /memos/ (목록 조회)
- 요청 2: GET /memos/2/ (상세 조회)', 'OBJECTIVE'),
       (5454, 879, '아래 설정에서 비로그인 사용자가 세 뷰에 GET 요청을 보냈을 때의 결과로 옳은 것은?', '```python
# settings.py
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework.authentication.SessionAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
}
```

```python
# views.py
class NoticeListView(APIView):        # A: 공지 목록
    def get(self, request):
        return Response(...)


class HealthView(APIView):            # B: 서버 상태 확인
    permission_classes = []           # 기본 설정을 따르게 하려고 비워 둠

    def get(self, request):
        return Response({"status": "ok"})


class TermsView(APIView):             # C: 이용약관 조회
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response(...)
```', 'OBJECTIVE'),
       (5455, 879, '아래 로그에서 웹 브라우저의 POST 요청만 거부된 원인으로 옳은 것은?', '```python
# settings.py
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework.authentication.SessionAuthentication",
        "rest_framework.authentication.TokenAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
}
```

같은 사용자 kim이 1분 사이에 보낸 요청의 서버 액세스 로그다.

```
[웹 브라우저] 로그인 폼으로 세션 로그인 후 fetch()로 호출, 추가 헤더 없음
GET   /api/cart/          200
POST  /api/cart/items/    403
GET   /api/cart/          200

[모바일 앱] Authorization: Token 9f2c7a1e (kim의 유효한 토큰)
POST  /api/cart/items/    201
```', 'OBJECTIVE'),
       (5456, 879, '아래 모델로 마이그레이션을 적용한 뒤 셸에서 실행한 코드의 출력 ⓐ~ⓒ로 옳은 것은?', '```python
# blog/models.py
class Post(models.Model):
    title = models.CharField(max_length=200)

    class Meta:
        permissions = [("publish_post", "게시글 발행 가능")]
```

```python
# kim: is_active=True, is_superuser=False, 편집팀 그룹 소속
#      편집팀 그룹의 권한은 blog.publish_post 하나뿐
# admin: is_active=True, is_superuser=True, 소속 그룹·직접 받은 권한 없음
kim = User.objects.get(email="kim@example.com")
admin = User.objects.get(email="admin@example.com")

print(kim.has_perm("publish_post"))           # ⓐ
print(admin.has_perm("blog.publish_post"))    # ⓑ
print(Permission.objects.filter(
    content_type__app_label="blog",
    content_type__model="post",
).count())                                    # ⓒ
```', 'OBJECTIVE'),
       (5457, 879, '아래 상황에서 스크립트에 추가해 로그인 실패를 해결한 사용자 인스턴스 메서드의 이름은?', '회원 300명을 한 번에 등록하려고 아래 스크립트를 돌렸다.

```python
for row in rows:
    User.objects.create(
        email=row["email"],
        nickname=row["nickname"],
        password=row["password"],
    )
```

이렇게 등록된 300명은 가입 때 입력한 비밀번호로 모두 로그인에 실패했다. 셸에서 확인한 결과는 다음과 같다.

```
>>> han = User.objects.get(email="han@example.com")   # 스크립트로 등록한 회원
>>> han.password
''Winter2026!''
>>> User.objects.get(email="admin@example.com").password   # createsuperuser로 만든 계정
''pbkdf2_sha256$870000$Qx3lR8...$Jk9wT2...=''
>>> han.check_password("Winter2026!")
False
```

스크립트를 고쳐 User 인스턴스를 먼저 만들고, 그 인스턴스의 메서드 하나에 row["password"]를 넘겨 호출한 뒤 save()하도록 바꿨다. 그러자 새로 등록한 회원은 모두 로그인에 성공했고, password 칸도 admin 계정과 같은 형태로 채워졌다.', 'SUBJECTIVE'),
       (5458, 879, '아래 상황에서 settings.py에 한 줄로 추가한 클래스의 이름은?', '사내 관리 도구(Django 5.1)는 뷰 58개에 데코레이터를 하나씩 붙여 비로그인 방문자를 로그인 화면으로 보내 왔다. 그런데 새로 만든 매출 내보내기 뷰에 이 데코레이터를 빠뜨려, 로그인하지 않은 외부인이 매출 CSV를 내려받는 사고가 났다.

재발을 막으려고 settings.py의 MIDDLEWARE 목록에서, 이미 들어 있던 AuthenticationMiddleware 바로 뒤에 Django가 제공하는 클래스 한 줄을 추가했다. 그 뒤로는 새 뷰에 아무 데코레이터를 붙이지 않아도 아래처럼 동작했다.

```
[비로그인] GET /reports/export/   302 → /accounts/login/?next=/reports/export/
[비로그인] GET /signup/           302 → /accounts/login/?next=/signup/
[비로그인] GET /accounts/login/   200
```

회원가입 페이지까지 로그인 화면으로 넘어가 버려서, 회원가입 뷰에만 예외용 데코레이터를 붙여 다시 열어 주었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5453
(14715, 5453, '요청 1은 B의 메모 2건만 담아 200, 요청 2는 403이다.', '객체 권한이 목록을 사용자별로 걸러 준다고 본 오해다. has_object_permission은 get_object() 안에서 불리는데 목록 조회는 get_object()를 거치지 않는다. 목록을 거르려면 get_queryset()에서 owner로 필터링해야 한다.', false),
(14716, 5453, '요청 1은 메모 5건을 모두 담아 200, 요청 2는 403이다.', '목록 조회는 get_object()를 부르지 않아 객체 검사가 빠지고, IsAuthenticated만 통과하면 queryset 5건이 그대로 나간다. 상세 조회는 get_object() 안에서 has_object_permission이 돌아 A의 메모에 403을 낸다.', true),
(14717, 5453, '요청 1은 A의 메모가 섞여 403, 요청 2도 403이다.', '목록도 객체마다 권한을 검사해 하나라도 실패하면 막힌다고 본 오해다. 목록 조회에서는 has_object_permission이 한 번도 호출되지 않아 A의 메모도 함께 응답된다.', false),
(14718, 5453, '요청 1은 메모 5건을 모두 담아 200, 요청 2도 200이다.', 'has_object_permission은 뷰에서 직접 불러야만 동작한다고 본 오해다. ModelViewSet의 상세 조회는 get_object() 안에서 check_object_permissions()를 거치므로 A의 메모는 403으로 막힌다.', false),

-- 문제 5454
(14719, 5454, 'C만 허용되고, A와 B는 거부된다.', '빈 리스트를 "전역 기본값을 따르라"는 뜻으로 본 오해다. permission_classes를 []로 덮어쓰면 검사할 클래스가 하나도 없어 전역 IsAuthenticated도 적용되지 않는다. 그래서 B는 누구에게나 열린다.', false),
(14720, 5454, 'A·B·C 세 뷰가 모두 허용된다.', '뷰에 권한 클래스를 적지 않으면 검사가 없다고 본 오해다. 속성을 아예 적지 않은 A는 전역 기본값 IsAuthenticated를 물려받아 비로그인 요청이 막힌다.', false),
(14721, 5454, 'B와 C만 허용되고, A는 거부된다.', '전역 기본값은 뷰가 permission_classes를 적지 않았을 때만 쓰인다. A는 IsAuthenticated를 물려받아 거부되고, B는 빈 리스트라 검사 없이, C는 AllowAny라 통과한다. 공개 뷰는 빈 리스트 대신 AllowAny로 의도를 드러내야 한다.', true),
(14722, 5454, 'A·B·C 세 뷰가 모두 거부된다.', '전역 기본값이 뷰 설정과 AND로 합쳐진다고 본 오해다. 뷰에 적은 permission_classes는 전역 값을 대체하므로 AllowAny인 C는 비로그인 요청도 통과시킨다.', false),

-- 문제 5455
(14723, 5455, '세션 인증은 쓰기 요청에 CSRF 토큰을 요구하는데, fetch() 요청에 그 토큰이 실리지 않았다.', 'SessionAuthentication은 인증에 성공한 요청에 CSRF 검사를 붙이며, GET 같은 안전한 메서드는 그냥 통과시킨다. 쿠키는 브라우저가 알아서 실어 보내므로 쓰기 요청엔 X-CSRFToken 헤더가 필요하다. 토큰은 앱이 헤더에 직접 실어 CSRF 검사가 없다.', true),
(14724, 5455, 'IsAuthenticated는 세션으로 로그인한 사용자에게 읽기 요청만 허용한다.', 'IsAuthenticated가 인증 방식에 따라 쓰기를 따로 막는다고 본 오해다. 이 클래스는 request.user가 로그인 사용자인지만 보고, 어떤 인증 클래스로 확정됐는지나 HTTP 메서드는 가리지 않는다.', false),
(14725, 5455, 'POST 직전에 세션이 만료돼 이 요청이 비로그인 요청으로 처리됐다.', 'POST 바로 뒤의 GET이 다시 200이므로 세션은 살아 있다. 세션이 풀렸다면 뒤따른 GET도 IsAuthenticated에서 막혀야 한다.', false),
(14726, 5455, 'TokenAuthentication이 목록 뒤쪽에 있어 세션 사용자의 쓰기 권한이 확인되지 않았다.', '인증 클래스 순서는 요청자를 확정하는 시도 순서일 뿐 쓰기 허용과 무관하다. 브라우저 요청은 첫 번째 SessionAuthentication에서 kim으로 확정됐고, 막힌 곳은 그 단계의 CSRF 검사다.', false),

-- 문제 5456
(14727, 5456, 'ⓐ True, ⓑ True, ⓒ 5', '코드명만으로도 권한을 찾는다고 본 오해다. has_perm()은 "blog.publish_post"처럼 앱 라벨이 붙은 문자열과 비교하므로, kim이 그룹으로 권한을 가졌어도 코드명만 넘긴 ⓐ는 False다.', false),
(14728, 5456, 'ⓐ False, ⓑ False, ⓒ 5', '슈퍼유저도 권한을 따로 부여받아야 한다고 본 오해다. 활성 상태인 슈퍼유저는 그룹이나 직접 받은 권한을 보지 않고 has_perm()이 항상 True를 돌려준다.', false),
(14729, 5456, 'ⓐ False, ⓑ True, ⓒ 1', 'Meta.permissions가 자동 생성 권한을 대체한다고 본 오해다. 사용자 정의 권한은 모델마다 자동으로 만들어지는 add·change·delete·view 4개에 더해지므로 Post의 권한은 5개다.', false),
(14730, 5456, 'ⓐ False, ⓑ True, ⓒ 5', '권한 문자열은 "앱 라벨.코드명" 형식이라 코드명만 넘긴 ⓐ는 False다. 활성 슈퍼유저는 권한 목록과 무관하게 True(ⓑ)다. Meta.permissions는 자동 생성되는 add·change·delete·view 4개에 추가돼 모두 5개(ⓒ)다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1774, 5457, 'set_password,set_password(),user.set_password,user.set_password(),han.set_password,set password,셋패스워드,셋 패스워드', 'set_password()는 받은 평문을 설정된 해시 알고리즘(기본값 PBKDF2)으로 해시해 password 필드에 넣는다. DB에 저장하지는 않으므로 save()를 따로 불러야 한다. create()는 넘긴 값을 그대로 저장해 평문이 들어갔고, check_password()는 저장값에서 해시 알고리즘을 알아내지 못해 False를 돌려 로그인이 실패했다. 매니저의 create_user()도 내부에서 이 메서드를 부르므로 스크립트를 create_user()로 바꿔도 해결된다. 입력한 비밀번호가 저장된 해시와 맞는지 비교만 하는 check_password()와 구분하자.'),
       (1775, 5458, 'LoginRequiredMiddleware,django.contrib.auth.middleware.LoginRequiredMiddleware,Login Required Middleware,로그인 필수 미들웨어,로그인 요구 미들웨어', 'LoginRequiredMiddleware는 Django 5.1에 추가된 미들웨어로, 예외로 표시하지 않은 모든 뷰에서 비로그인 요청을 settings.LOGIN_URL로 리다이렉트한다. request.user를 읽어야 하므로 AuthenticationMiddleware 뒤에 둬야 하고, 공개할 뷰에는 @login_not_required를 붙인다. 로그인 뷰는 Django가 미리 예외로 표시해 두어 200이 난다. 뷰마다 붙이는 @login_required는 빠뜨리면 그대로 열리지만, 이 방식은 빠뜨려도 기본이 막힘이라 같은 사고가 줄어든다. 요청마다 request.user를 채우기만 하고 접근을 막지는 않는 AuthenticationMiddleware, 뷰·객체마다 판정을 달리하는 DRF 권한 클래스와 구분하자.');
