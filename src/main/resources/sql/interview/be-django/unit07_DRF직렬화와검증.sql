-- Unit: DRF 직렬화와 검증 (Unit ID: 138)
-- Chapter: Django (Chapter ID: 12)
-- Topic: DJANGO
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-django-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(686, 'DJANGO', 138, 'HARD', true,
 '주문과 주문 항목을 한 요청으로 생성하는 API를 중첩 시리얼라이저를 둔 ModelSerializer로 구현하려 합니다. 기본 동작의 한계와 올바른 구현 방법, 그리고 모델의 clean()에 둔 검증 규칙이 이 API 경로에서 지켜지는지 설명해 주세요.',
 'ModelSerializer는 중첩 관계 쓰기를 기본으로 지원하지 않습니다. items 같은 중첩 시리얼라이저를 둔 채 그대로 save()를 호출하면 "The `.create()` method does not support writable nested fields by default."라는 AssertionError가 발생합니다. 그래서 create()를 오버라이드해 validated_data에서 items를 pop으로 꺼내고, transaction.atomic 트랜잭션 안에서 Order를 먼저 만든 뒤 OrderItem을 bulk_create로 직접 생성해야 합니다. 또 ModelSerializer는 DRF 3.0 이후 모델의 clean()이나 full_clean()을 호출하지 않으므로, 모델에 검증을 두었더라도 API 경로에서는 우회됩니다. 따라서 검증은 시리얼라이저에 두거나, 시리얼라이저 validate()에서 모델 인스턴스를 만들어 full_clean()을 직접 호출해야 합니다. 중첩 update는 기존 자식 중 무엇을 삭제·수정·추가할지 정책이 필요해 더 어렵기 때문에, 자식 리소스를 별도 엔드포인트로 분리하는 설계가 흔히 더 낫습니다.',
 'interview-question/686.mp3'),
(687, 'DJANGO', 138, 'NORMAL', true,
 'DRF 시리얼라이저에서 validate_<필드명> 메서드와 validate() 메서드는 각각 무엇을 검증하며 어떤 차이가 있나요?',
 'validate_<필드명>은 시리얼라이저에 정의하는 필드 훅으로, 타입 변환이 끝난 단일 필드의 값을 받아 그 필드 하나만 검증합니다. 반면 validate()는 객체 단위 훅으로, 시작 시각이 종료 시각보다 앞서는지처럼 여러 필드를 함께 보는 필드 간 교차 검증을 합니다. 실행 시점도 달라서 validate()는 모든 필드 검증이 통과한 뒤 attrs를 받아 실행되며, 필드 훅에서 오류가 나면 validate()는 실행되지 않습니다. 두 메서드 모두 검증한 값을 반드시 반환해야 하며, 예를 들어 validate_<필드명>에서 반환을 빼먹으면 validated_data에 None이 들어갑니다. validate()에서 특정 필드에 오류를 붙이고 싶으면 {"필드명": "메시지"} 형태로 ValidationError를 던집니다.',
 'interview-question/687.mp3'),
(688, 'DJANGO', 138, 'NORMAL', true,
 'DRF에서 Serializer와 ModelSerializer 중 어떤 상황에 무엇을 선택해야 하는지 이유와 함께 설명해 주세요.',
 '단일 모델의 단순 CRUD라면 ModelSerializer를 씁니다. 모델 필드로부터 시리얼라이저 필드와 검증기, 단순 create()·update()를 자동 생성해 주므로 보일러플레이트가 최소화됩니다. 반대로 검색 조건, 로그인 폼, 액션 요청처럼 모델과 무관한 입력에는 순수 Serializer를 씁니다. 모델 매핑이 없으니 create()도 필요 없고 순수 검증기로만 사용하면 됩니다. 여러 모델을 조합한 응답도 자동 매핑이 오히려 방해가 되므로 Serializer나 읽기 전용 ModelSerializer가 적합합니다. 중첩 생성이나 복잡한 비즈니스 규칙이 있으면 create()를 오버라이드하거나 서비스 함수를 호출하는데, 시리얼라이저는 입력 검증과 출력 형식을, 서비스 함수는 도메인 규칙을 맡도록 역할을 나누는 것이 실무 표준입니다. 시리얼라이저 create()에 비즈니스 로직을 몰아넣으면 관리자 명령·배치·시그널 같은 API 외 경로에서 재사용할 수 없기 때문입니다. 또 ModelSerializer를 쓸 때 fields = "__all__"은 새 필드가 자동 노출되는 보안 위험이 있습니다.',
 'interview-question/688.mp3'),
(689, 'DJANGO', 138, 'EASY', true,
 'DRF 시리얼라이저의 is_valid()를 호출하면 검증이 어떤 순서로 진행되는지 설명해 주세요.',
 'is_valid()는 내부적으로 run_validation()을 호출하고, 검증은 필드 단위에서 시리얼라이저 단위 순서로 진행됩니다. 먼저 required, allow_null, default 같은 빈 값 처리를 확인한 뒤 to_internal_value()에서 필드마다 타입 변환, max_length나 UniqueValidator 같은 필드 validators, 그리고 시리얼라이저에 정의한 validate_<필드명> 훅이 순서대로 실행됩니다. 그다음 UniqueTogetherValidator 같은 Meta.validators가 실행되고, 마지막으로 validate()에서 필드 간 교차 검증을 합니다. 앞 단계에서 오류가 하나라도 있으면 뒤 단계는 실행되지 않으므로, 필드 오류가 있으면 validate()는 호출되지 않습니다. 성공하면 validated_data에, 실패하면 errors에 결과가 담깁니다.',
 'interview-question/689.mp3'),
(690, 'DJANGO', 138, 'EASY', true,
 'DRF 시리얼라이저에서 save()를 호출하면 내부적으로 무슨 일이 일어나며, save(organizer=request.user)처럼 넘긴 값은 어떻게 처리되나요?',
 'save()는 시리얼라이저에 self.instance가 있는지에 따라 동작이 갈립니다. instance 없이 data만 넘겨 만든 시리얼라이저라면 create(validated_data)를, instance와 data를 함께 넘긴 수정용이라면 update(instance, validated_data)를 호출합니다. save(organizer=request.user)처럼 save()에 넘긴 kwargs는 검증을 거치지 않고 validated_data에 그대로 병합됩니다. 그래서 요청자나 서버 시각처럼 클라이언트가 정해선 안 되는 값을 서버에서 주입하는 표준 방법으로 쓰입니다. 보통 그 전에 is_valid(raise_exception=True)를 호출하는데, 검증에 실패하면 ValidationError가 던져지고 DRF 예외 핸들러가 이를 400 응답으로 변환합니다.',
 'interview-question/690.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 686
(3698, 686, 'ModelSerializer는 중첩 관계 쓰기(create/update)를 기본 지원하지 않음을 언급', 'ESSENTIAL', 1),
(3699, 686, '중첩 쓰기를 위해 create()를 오버라이드해 중첩 데이터를 직접 생성함을 설명', 'ESSENTIAL', 2),
(3700, 686, 'ModelSerializer는 모델의 clean()을 호출하지 않아 API 경로에서 모델 검증이 우회됨을 언급', 'ESSENTIAL', 3),
(3701, 686, '중첩 생성을 transaction.atomic 트랜잭션 안에서 수행함을 언급', 'SUPPLEMENTARY', 4),
(3702, 686, '시리얼라이저 validate()에서 모델 인스턴스를 만들어 full_clean()을 직접 호출하는 방안을 제시', 'SUPPLEMENTARY', 5),
(3703, 686, '중첩 update는 자식 리소스를 별도 엔드포인트로 분리하는 설계를 대안으로 제시', 'SUPPLEMENTARY', 6),

-- 질문 687
(3704, 687, 'validate_<필드명>은 단일 필드 하나만 검증하는 훅임을 언급', 'ESSENTIAL', 1),
(3705, 687, 'validate()는 여러 필드를 함께 보는 필드 간 교차 검증을 함을 언급', 'ESSENTIAL', 2),
(3706, 687, 'validate()는 모든 필드 검증이 통과한 뒤에 실행됨을 언급', 'SUPPLEMENTARY', 3),
(3707, 687, '두 훅 모두 검증한 값을 반드시 반환해야 함을 언급', 'SUPPLEMENTARY', 4),
(3708, 687, 'validate()에서 특정 필드에 오류를 붙이려면 {"필드명": "메시지"} 형태로 던짐을 언급', 'SUPPLEMENTARY', 5),

-- 질문 688
(3709, 688, '단일 모델의 단순 CRUD에는 필드·검증기 자동 생성 덕분에 ModelSerializer를 권장함을 언급', 'ESSENTIAL', 1),
(3710, 688, '검색 조건·로그인 폼처럼 모델과 무관한 입력에는 순수 Serializer를 권장함을 언급', 'ESSENTIAL', 2),
(3711, 688, '여러 모델을 조합한 응답에는 Serializer·읽기 전용 ModelSerializer 중 최소 1개를 권장안으로 제시', 'ESSENTIAL', 3),
(3712, 688, '중첩 생성·복잡한 비즈니스 규칙에는 create() 오버라이드 또는 서비스 함수 호출 중 하나를 제시', 'SUPPLEMENTARY', 4),
(3713, 688, 'fields = "__all__"은 새 필드가 자동 노출되는 보안 위험임을 언급', 'SUPPLEMENTARY', 5),
(3714, 688, '시리얼라이저 create()에 비즈니스 로직을 두면 API 외 경로에서 재사용할 수 없음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 689
(3715, 689, '검증이 필드 단위에서 시리얼라이저 단위 순서로 진행됨을 설명', 'ESSENTIAL', 1),
(3716, 689, '필드마다 타입 변환 → 필드 validators → validate_<필드명> 순서로 실행됨을 설명', 'ESSENTIAL', 2),
(3717, 689, '앞 단계에서 오류가 하나라도 있으면 뒤 단계가 실행되지 않음을 언급', 'ESSENTIAL', 3),
(3718, 689, 'Meta.validators(UniqueTogetherValidator 등)가 validate()보다 먼저 실행됨을 언급', 'SUPPLEMENTARY', 4),
(3719, 689, '검증 결과가 성공 시 validated_data, 실패 시 errors에 담김을 언급', 'SUPPLEMENTARY', 5),

-- 질문 690
(3720, 690, 'save()가 self.instance 유무에 따라 create() 또는 update()를 호출함을 설명', 'ESSENTIAL', 1),
(3721, 690, 'save()에 넘긴 kwargs는 검증을 거치지 않고 validated_data에 병합됨을 언급', 'ESSENTIAL', 2),
(3722, 690, '요청자·서버 시각처럼 클라이언트가 정해선 안 되는 값을 주입하는 용도임을 언급', 'SUPPLEMENTARY', 3),
(3723, 690, 'is_valid(raise_exception=True) 실패 시 DRF 예외 핸들러가 400 응답으로 변환함을 언급', 'SUPPLEMENTARY', 4);
