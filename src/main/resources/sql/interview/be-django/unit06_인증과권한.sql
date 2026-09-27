-- Unit: 인증과 권한 (Unit ID: 137)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(681, 'DJANGO', 137, 'HARD', true,
 'DRF로 게시글 API를 만들면서 ''작성자 본인만 게시글을 수정할 수 있다''는 요구사항을 구현해야 합니다. Django 모델 권한만으로 이를 구현할 수 있는지, 권한 클래스로 구현한다면 어떻게 하고 객체 권한 검사가 누락되는 경우는 무엇인지 설명해 주시겠어요?',
 'Django 모델 권한은 add·change·delete·view처럼 모델 단위로만 부여되기 때문에 ''이 사용자가 게시글을 수정할 수 있는가''까지만 답할 수 있고, ''자기 게시글만 수정''과 같은 객체 단위 권한은 Django 기본 백엔드가 지원하지 않습니다. 그래서 DRF의 BasePermission을 상속한 권한 클래스에서 has_object_permission을 구현합니다. 읽기 요청(SAFE_METHODS)은 허용하고, 쓰기 요청이면 obj.author_id가 request.user.id와 같은지 검사해 작성자만 통과시키는 방식입니다. has_object_permission은 has_permission이 통과한 뒤에만 호출되며, get_object() 내부의 check_object_permissions를 통해 호출됩니다. 따라서 get_object()를 거치지 않고 Post.objects.get(pk=pk)처럼 직접 조회하면 has_object_permission이 호출되지 않아 객체 권한 검사가 빠집니다. 직접 조회할 때는 반드시 self.check_object_permissions(request, obj)를 호출해야 합니다. 또한 목록(list) 뷰에서도 has_object_permission은 호출되지 않으므로 객체 권한만 믿어서는 안 됩니다.'),
(682, 'DJANGO', 137, 'NORMAL', true,
 '커스텀 사용자 모델을 만들 때 AbstractUser와 AbstractBaseUser는 어떤 차이가 있고, 각각 어떤 경우에 선택하나요?',
 'AbstractUser는 username, email, first/last_name, is_staff, is_active, date_joined 등 기본 사용자 필드를 전부 포함하고 기본 UserManager와 관리자 화면·폼도 제공합니다. 반면 AbstractBaseUser는 password와 last_login 필드만 제공하고 나머지 필드는 직접 정의해야 하며, USERNAME_FIELD로 이메일이나 전화번호 같은 로그인 식별자를 자유롭게 지정할 수 있습니다. 대신 BaseUserManager를 상속한 매니저를 직접 작성하고 UserAdmin과 생성·변경 폼도 커스터마이징해야 합니다. 또 PermissionsMixin을 함께 상속해야 is_superuser·groups·user_permissions와 has_perm() 계열 메서드가 생겨 Django 권한 체계와 관리자 사이트를 쓸 수 있습니다. 따라서 기본 구조를 유지하면서 필드만 추가하려면 AbstractUser를, username 없이 이메일로 로그인하는 등 필드 구성을 완전히 통제하려면 AbstractBaseUser를 선택합니다.'),
(683, 'DJANGO', 137, 'NORMAL', true,
 '인증과 인가(권한)는 어떻게 다르며, DRF에서 인증 클래스와 권한 클래스는 각각 어떤 역할을 하고 실패했을 때 어떤 응답 코드를 반환하나요?',
 '인증(Authentication)은 요청한 사용자가 ''누구인가''를 확인하는 것이고, 인가(Authorization, 권한)는 그 사용자가 ''무엇을 할 수 있는가''를 판단하는 것입니다. DRF에서는 APIView.initial()에서 먼저 authentication_classes를 순회해 request.user와 request.auth를 확정하고, 이어서 permission_classes의 has_permission()으로 뷰 진입 가능 여부를 검사합니다. 즉 인증 클래스는 request.user를 결정하고, 권한 클래스는 그 사용자를 판정합니다. 인증 클래스가 비어 있으면 request.user는 AnonymousUser가 되어 IsAuthenticated는 항상 실패합니다. 실패 응답은 인증 실패의 경우 인증 헤더가 있는 방식이면 401로 응답되고, 방식에 따라서는 인증 실패도 403으로 응답될 수 있으며, 권한 실패는 403으로 응답됩니다.'),
(684, 'DJANGO', 137, 'EASY', true,
 'Django 프로젝트에서 커스텀 사용자 모델을 프로젝트 시작 시점부터 설정하라고 권장하는 이유는 무엇인가요?',
 'Django 공식 문서는 프로젝트 시작 시점에 커스텀 사용자 모델을 설정할 것을 강력히 권장하며, settings.py의 AUTH_USER_MODEL은 첫 마이그레이션 이전에 결정해야 합니다. 기본 auth.User를 쓰다가 중간에 바꾸면 auth_user 테이블을 참조하는 권한·세션·관리자 로그 등의 모든 FK·M2M을 수동으로 옮겨야 하고, 마이그레이션 이력까지 수술해야 합니다. 테이블 이름을 auth_user로 맞추고 마이그레이션을 fake하는 우회도 있지만 위험이 크기 때문에, 필드가 당장 필요 없더라도 빈 AbstractUser 상속 모델을 만들어 두는 것이 표준 관행입니다.'),
(685, 'DJANGO', 137, 'EASY', true,
 '커스텀 사용자 모델을 쓰는 프로젝트에서 다른 모델의 FK로 사용자 모델을 참조할 때와 뷰·서비스 코드에서 사용자 모델을 사용할 때 각각 어떤 방식을 써야 하나요?',
 '모델 정의에서 사용자 모델을 FK로 참조할 때는 models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)처럼 settings.AUTH_USER_MODEL 문자열 설정값을 사용합니다. 모델 정의에서 get_user_model()을 모듈 최상단에서 호출하면 앱 로딩 순서에 따라 AppRegistryNotReady가 날 수 있기 때문입니다. 그 외 뷰·서비스·시리얼라이저에서는 get_user_model()을 호출해 그 시점에 실제 사용자 모델 클래스를 얻습니다. 특히 재사용 가능한 앱이나 라이브러리에서 django.contrib.auth.models의 User를 직접 임포트하면 커스텀 모델을 쓰는 프로젝트에서 깨지므로 피해야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 681
(3671, 681, 'Django 모델 권한은 모델 단위라 기본 백엔드가 객체 단위 권한을 지원하지 않음을 언급', 'ESSENTIAL', 1),
(3672, 681, 'has_object_permission에서 객체의 작성자가 request.user와 같은지 검사하는 방식을 서술', 'ESSENTIAL', 2),
(3673, 681, 'get_object() 대신 직접 조회하면 has_object_permission이 호출되지 않음을 언급', 'ESSENTIAL', 3),
(3674, 681, '직접 조회할 때는 check_object_permissions(request, obj)를 호출해야 함을 언급', 'ESSENTIAL', 4),
(3675, 681, '목록(list) 뷰에서는 has_object_permission이 호출되지 않음을 언급', 'SUPPLEMENTARY', 5),
(3676, 681, 'has_object_permission은 has_permission이 통과한 뒤에만 호출됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 682
(3677, 682, 'AbstractUser는 username·email·is_staff 등 기본 필드를 전부 포함함을 언급', 'ESSENTIAL', 1),
(3678, 682, 'AbstractBaseUser는 password와 last_login 필드만 제공함을 언급', 'ESSENTIAL', 2),
(3679, 682, 'AbstractBaseUser에서는 USERNAME_FIELD로 로그인 식별자를 자유롭게 지정함을 언급', 'ESSENTIAL', 3),
(3680, 682, '필드만 추가할 때는 AbstractUser, 이메일 로그인 등 필드 구성을 완전히 통제할 때는 AbstractBaseUser를 선택함을 서술', 'ESSENTIAL', 4),
(3681, 682, 'AbstractBaseUser 사용 시 BaseUserManager를 상속한 매니저를 직접 작성해야 함을 언급', 'SUPPLEMENTARY', 5),
(3682, 682, 'PermissionsMixin을 함께 상속해야 Django 권한 체계와 관리자 사이트를 쓸 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 683
(3683, 683, '인증은 ''누구인가''를, 인가는 ''무엇을 할 수 있는가''를 판단하는 것으로 구분', 'ESSENTIAL', 1),
(3684, 683, '인증 클래스는 request.user를 결정하고 권한 클래스는 그 사용자를 판정하는 역할임을 설명', 'ESSENTIAL', 2),
(3685, 683, '권한 검사 실패 시 403으로 응답됨을 언급', 'ESSENTIAL', 3),
(3686, 683, '인증 헤더가 있는 인증 방식에서 인증 실패는 401로 응답됨을 언급', 'ESSENTIAL', 4),
(3687, 683, '인증 클래스가 비어 있으면 request.user가 AnonymousUser가 되어 IsAuthenticated가 항상 실패함을 언급', 'SUPPLEMENTARY', 5),
(3688, 683, 'APIView.initial()에서 인증 클래스 순회 후 권한 클래스의 has_permission이 검사되는 순서를 언급', 'SUPPLEMENTARY', 6),
(3689, 683, '인증 실패도 인증 방식에 따라 401이 아닌 403으로 응답될 수 있음을 언급', 'SUPPLEMENTARY', 7),

-- 질문 684
(3690, 684, 'AUTH_USER_MODEL은 첫 마이그레이션 이전에 설정해야 함을 언급', 'ESSENTIAL', 1),
(3691, 684, '중간에 바꾸면 auth_user 테이블을 참조하는 모든 FK·M2M을 수동으로 옮겨야 함을 언급', 'ESSENTIAL', 2),
(3692, 684, '필드가 당장 필요 없어도 빈 AbstractUser 상속 모델을 만들어 두는 관행을 언급', 'ESSENTIAL', 3),
(3693, 684, '중간 변경 시 마이그레이션 이력을 수술해야 하는 부담을 언급', 'SUPPLEMENTARY', 4),

-- 질문 685
(3694, 685, '모델 FK에서는 settings.AUTH_USER_MODEL 문자열로 사용자 모델을 참조함을 언급', 'ESSENTIAL', 1),
(3695, 685, '뷰·서비스·시리얼라이저에서는 get_user_model()로 모델 클래스를 얻음을 언급', 'ESSENTIAL', 2),
(3696, 685, 'django.contrib.auth.models의 User를 직접 임포트하면 커스텀 모델 프로젝트에서 깨짐을 언급', 'SUPPLEMENTARY', 3),
(3697, 685, 'get_user_model()을 모듈 최상단에서 호출하면 AppRegistryNotReady가 날 수 있음을 언급', 'SUPPLEMENTARY', 4);
