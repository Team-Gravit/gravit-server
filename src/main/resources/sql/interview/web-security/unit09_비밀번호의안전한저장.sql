-- Unit: 비밀번호의 안전한 저장 (Unit ID: 259)
-- Chapter: 웹 보안 (Chapter ID: 23)
-- Topic: WEB_SECURITY
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-web-security-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1474, 'WEB_SECURITY', 259, 'HARD', true,
 '사용자별 Salt를 붙여 SHA-256으로 비밀번호를 저장하던 서비스의 DB가 유출됐다면, 비밀번호는 왜 여전히 위험한가요?',
 'Salt는 미리 계산해 둔 레인보우 테이블을 무력화하지만, 사전 계산을 막을 뿐 개별 계정에 대한 무차별 대입 자체는 막지 못합니다. Salt는 비밀이 아니며 해시 값과 함께 저장되어 있습니다. 게다가 SHA-256 같은 범용 해시는 의도적으로 빠르게 설계되어 GPU로 초당 수십억 회 계산이 가능하고, 짧은 비밀번호는 전수 대입으로 금방 깨집니다. Salt를 붙인 해시도 고속 해시라 무차별 대입이 여전히 약점으로 남으므로, 범용 해시 단독 사용 대신 bcrypt나 Argon2 같은 전용 알고리즘을 사용해야 합니다.',
 NULL),
(1475, 'WEB_SECURITY', 259, 'NORMAL', true,
 '비밀번호 해싱에서 Salt와 Pepper는 어떻게 다른가요?',
 'Salt는 해시 전에 비밀번호에 덧붙이는 사용자별 무작위 값이고, Pepper는 서버만 아는 전역 비밀 값입니다. Salt는 비밀이 아니어서 해시 값과 함께 DB에 저장하지만, Pepper는 DB가 아니라 애플리케이션 설정이나 별도 보안 저장소처럼 DB 밖에 보관합니다. 목적도 다릅니다. Salt는 레인보우 테이블 같은 사전 계산을 막기 위한 것이고, Pepper는 DB 단독 유출 시 방어선을 추가하기 위한 것입니다. 해시 전에 Pepper를 함께 섞어 두면, DB만 유출된 상황에서는 Pepper를 모르는 공격자가 대입 공격 자체를 시작할 수 없습니다.',
 NULL),
(1476, 'WEB_SECURITY', 259, 'NORMAL', true,
 '비밀번호 해싱 알고리즘으로 bcrypt와 Argon2는 어떤 차이가 있나요?',
 '두 알고리즘 모두 Salt를 내장한 비밀번호 전용 알고리즘이지만 비용을 조절하는 방식이 다릅니다. bcrypt는 cost factor 하나로 2의 n제곱회 반복 횟수를 조절하고, cost를 1 올리면 연산량이 2배가 됩니다. 반면 Argon2는 시간뿐 아니라 메모리와 병렬도까지, 시간·메모리·병렬도의 3축으로 비용을 조절합니다. GPU 공격 내성은 bcrypt가 양호한 수준이고, 메모리 하드 방식인 Argon2는 높습니다. bcrypt는 가장 널리 검증된 실무 표준이고, Argon2는 2015년 암호 해싱 대회 우승 알고리즘으로 최신 권장 방식입니다.',
 NULL),
(1477, 'WEB_SECURITY', 259, 'EASY', true,
 '비밀번호를 해시로 저장할 때 Salt란 무엇이고, 왜 필요한가요?',
 'Salt는 해시하기 전에 비밀번호에 덧붙이는 사용자별 무작위 값입니다. 같은 비밀번호라도 Salt가 다르면 완전히 다른 해시가 나오기 때문에, 미리 계산해 둔 레인보우 테이블이 무력화되고 공격자는 Salt별로 테이블을 새로 만들어야 합니다. 또 같은 비밀번호라도 저장 값이 달라지므로 동일 비밀번호를 쓰는 사용자를 식별할 수 없게 됩니다. Salt는 비밀이 아니며 해시 값과 함께 저장합니다. 다만 Salt는 사전 계산을 막을 뿐, 개별 계정에 대한 무차별 대입 자체는 막지 못합니다.',
 NULL),
(1478, 'WEB_SECURITY', 259, 'EASY', true,
 '비밀번호 저장에서 Key Stretching이란 무엇이고, 왜 필요한가요?',
 'Key Stretching은 비밀번호와 Salt에 해시를 수천에서 수십만 번 반복 적용해, 한 번의 검증 비용을 의도적으로 키우는 기법입니다. Salt는 사전 계산을 막을 뿐 개별 계정에 대한 무차별 대입 자체는 막지 못하기 때문에 이 기법이 필요합니다. 정상 사용자는 로그인당 한 번만 계산하므로 수십에서 수백 밀리초의 지연이 체감되지 않지만, 수십억 번을 시도해야 하는 공격자에게는 비용이 수십억 배로 불어납니다.',
 NULL);

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1474
(6850, 1474, 'Salt는 개별 계정에 대한 무차별 대입 자체는 막지 못한다고 설명', 'ESSENTIAL', 1),
(6851, 1474, 'SHA-256 같은 범용 해시는 의도적으로 빠르게 설계되었다고 설명', 'ESSENTIAL', 2),
(6852, 1474, '짧은 비밀번호는 전수 대입으로 깨진다고 언급', 'SUPPLEMENTARY', 3),
(6853, 1474, 'GPU로 초당 수십억 회 계산이 가능하다고 언급', 'SUPPLEMENTARY', 4),
(6854, 1474, 'bcrypt·Argon2 같은 전용 알고리즘으로 바꿔야 한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1475
(6855, 1475, 'Salt는 사용자별 값이고 Pepper는 전역 값이라고 구분', 'ESSENTIAL', 1),
(6856, 1475, 'Salt는 DB에 함께 저장하고 Pepper는 DB 밖에 보관한다고 구분', 'ESSENTIAL', 2),
(6857, 1475, 'Salt의 목적은 사전 계산 방지, Pepper의 목적은 DB 단독 유출 시 방어선 추가라고 구분', 'ESSENTIAL', 3),
(6858, 1475, 'Pepper를 모르는 공격자는 대입 공격 자체를 시작할 수 없다고 언급', 'SUPPLEMENTARY', 4),
(6859, 1475, 'Pepper는 애플리케이션 설정·별도 보안 저장소 중 최소 1개에 둔다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1476
(6860, 1476, 'bcrypt와 달리 Argon2는 메모리까지 비용 조절 축으로 쓴다고 구분', 'ESSENTIAL', 1),
(6861, 1476, 'GPU 공격 내성은 Argon2가 bcrypt보다 높다고 비교', 'ESSENTIAL', 2),
(6862, 1476, 'Argon2는 시간·메모리·병렬도 3축으로 비용을 조절한다고 언급', 'SUPPLEMENTARY', 3),
(6863, 1476, 'Argon2는 메모리 하드 방식이라고 언급', 'SUPPLEMENTARY', 4),
(6864, 1476, 'bcrypt는 가장 널리 검증된 실무 표준이라고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1477
(6865, 1477, 'Salt는 해시 전에 비밀번호에 덧붙이는 사용자별 무작위 값이라고 설명', 'ESSENTIAL', 1),
(6866, 1477, '레인보우 테이블 무력화·동일 비밀번호 사용자 식별 불가 중 최소 1개를 제시', 'ESSENTIAL', 2),
(6867, 1477, 'Salt는 해시 값과 함께 저장한다고 언급', 'SUPPLEMENTARY', 3),
(6868, 1477, 'Salt는 개별 계정에 대한 무차별 대입 자체는 막지 못한다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 1478
(6869, 1478, 'Key Stretching은 해시를 여러 번 반복 적용하는 기법이라고 설명', 'ESSENTIAL', 1),
(6870, 1478, '무차별 대입을 시도하는 공격자의 비용이 불어난다고 설명', 'ESSENTIAL', 2),
(6871, 1478, '한 번의 검증 비용을 의도적으로 키운다고 설명', 'SUPPLEMENTARY', 3),
(6872, 1478, '정상 사용자는 로그인당 한 번만 계산하므로 지연이 체감되지 않는다고 언급', 'SUPPLEMENTARY', 4),
(6873, 1478, 'Salt만으로는 개별 계정에 대한 무차별 대입을 막지 못한다고 언급', 'SUPPLEMENTARY', 5);
