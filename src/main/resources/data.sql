INSERT INTO league (id, name, min_lp, max_lp, sort_order)
VALUES (1, '브론즈 3', 0, 100, 1),
       (2, '브론즈 2', 101, 200, 2),
       (3, '브론즈 1', 201, 320, 3),

       (4, '실버 3', 321, 460, 4),
       (5, '실버 2', 461, 620, 5),
       (6, '실버 1', 621, 800, 6),

       (7, '골드 3', 801, 1000, 7),
       (8, '골드 2', 1001, 1220, 8),
       (9, '골드 1', 1221, 1460, 9),

       (10, '플래티넘 3', 1461, 1720, 10),
       (11, '플래티넘 2', 1721, 2000, 11),
       (12, '플래티넘 1', 2001, 2300, 12),

       (13, '다이아몬드 3', 2301, 2620, 13),
       (14, '다이아몬드 2', 2621, 2960, 14),
       (15, '다이아몬드 1', 2961, 9999, 15);

INSERT INTO badge_category (id, name, display_order, description, created_at, updated_at)
VALUES
    (1, '행성 완료', 1, '챕터 완료시 각 챕터에 맞는 행성 뱃지 획득', now(), now()),
    (2, '연속 학습', 2, '매일 한 개 이상의 레슨 풀이시, 연속학습 유지', now(), now()),
    (3, '풀이 속도', 3, '85% 이상의 정답률만 인정해요', now(), now()),
    (4, '미션 완료', 4, '오늘의 미션을 특정 개수 이상 완료시 획득', now(), now());

INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    -- 모든 행성 완료 (올스타)
    ('올스타', 'PLANETS_ALL_COMPLETE', '모든 행성(챕터)을 완료하세요.', 100, 1,1, 'ALL_PLANETS_COMPLETE', '{}'::jsonb, now(), now()),
    ('지구',   'PLANET_EARTH_COMPLETE',   '지구 행성(챕터)을 완료하세요.',   101, 1,2,  'PLANET_COMPLETE', '{"planet":"EARTH"}'::jsonb,   now(), now()),
    ('달',     'PLANET_MOON_COMPLETE',    '달 행성(챕터)을 완료하세요.',     102, 1, 3, 'PLANET_COMPLETE', '{"planet":"MOON"}'::jsonb,    now(), now()),
    ('수성',   'PLANET_MERCURY_COMPLETE', '수성 행성(챕터)을 완료하세요.',   103, 1,4,  'PLANET_COMPLETE', '{"planet":"MERCURY"}'::jsonb, now(), now()),
    ('금성',   'PLANET_VENUS_COMPLETE',   '금성 행성(챕터)을 완료하세요.',   104, 1, 5, 'PLANET_COMPLETE', '{"planet":"VENUS"}'::jsonb,   now(), now()),
    ('화성',   'PLANET_MARS_COMPLETE',    '화성 행성(챕터)을 완료하세요.',   105, 1, 6, 'PLANET_COMPLETE', '{"planet":"MARS"}'::jsonb,    now(), now()),
    ('목성',   'PLANET_JUPITER_COMPLETE', '목성 행성(챕터)을 완료하세요.',   106, 1, 7, 'PLANET_COMPLETE', '{"planet":"JUPITER"}'::jsonb, now(), now()),
    ('토성',   'PLANET_SATURN_COMPLETE',  '토성 행성(챕터)을 완료하세요.',   107, 1, 8,'PLANET_COMPLETE', '{"planet":"SATURN"}'::jsonb,  now(), now()),
    ('천왕성', 'PLANET_URANUS_COMPLETE',  '천왕성 행성(챕터)을 완료하세요.', 108, 1, 9, 'PLANET_COMPLETE', '{"planet":"URANUS"}'::jsonb,  now(), now());

-- 연속 학습
INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    -- 모든 연속 학습 뱃지 획득 완료
    ('올스타', 'STREAK_ALL_STAR', '연속 학습 카테고리의 모든 뱃지를 획득하세요.', 200, 2, 1,'STREAK_DAYS', '{}'::jsonb, now(), now()),

    ('10일',  'STREAK_10_DAYS',  '연속 학습 10일을 달성하세요.',  201, 2,2,  'STREAK_DAYS', '{"days":10}'::jsonb,  now(), now()),
    ('30일',  'STREAK_30_DAYS',  '연속 학습 30일을 달성하세요.',  202, 2, 3, 'STREAK_DAYS', '{"days":30}'::jsonb,  now(), now()),
    ('50일',  'STREAK_50_DAYS',  '연속 학습 50일을 달성하세요.',  203, 2, 4, 'STREAK_DAYS', '{"days":50}'::jsonb,  now(), now()),
    ('100일', 'STREAK_100_DAYS', '연속 학습 100일을 달성하세요.', 204, 2, 5, 'STREAK_DAYS', '{"days":100}'::jsonb, now(), now());

-- 풀이 속도 (3분 이내 85% 이상 정답률을 달성한 문제 수)
INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    ('올스타', 'SPEED_ALL_STAR', '풀이 속도 카테고리의 모든 뱃지를 획득하세요.', 300, 3,1,  'SPEED_QUALIFIED_COUNT', '{}'::jsonb, now(), now()),
    ('10개',  'SPEED_QUALIFIED_10',  '2분 이내 85% 이상 정답률로 10개를 달성하세요.',  301, 3, 2, 'SPEED_QUALIFIED_COUNT', '{"count":10}'::jsonb,  now(), now()),
    ('20개',  'SPEED_QUALIFIED_20',  '2분 이내 85% 이상 정답률로 20개를 달성하세요.',  302, 3,3,  'SPEED_QUALIFIED_COUNT', '{"count":20}'::jsonb,  now(), now()),
    ('30개',  'SPEED_QUALIFIED_30',  '2분 이내 85% 이상 정답률로 30개를 달성하세요.',  303, 3,4,  'SPEED_QUALIFIED_COUNT', '{"count":30}'::jsonb,  now(), now()),
    ('50개',  'SPEED_QUALIFIED_50',  '2분 이내 85% 이상 정답률로 50개를 달성하세요.',  304, 3,5,  'SPEED_QUALIFIED_COUNT', '{"count":50}'::jsonb,  now(), now());

-- 미션 완료
INSERT INTO badge
(name, code, description, icon_id, category_id, display_order, criteria_type, criteria_params, created_at, updated_at)
VALUES
    ('올스타', 'MISSION_ALL_STAR', '미션 완료 카테고리의 모든 뱃지를 획득하세요.', 400, 4, 1, 'MISSION_COUNT', '{}'::jsonb, now(), now()),
    ('10개',  'MISSION_10',  '미션 10개 완료를 달성하세요.',  401, 4, 2, 'MISSION_COUNT', '{"count":10}'::jsonb,  now(), now()),
    ('20개',  'MISSION_20',  '미션 20개 완료를 달성하세요.',  402, 4, 3, 'MISSION_COUNT', '{"count":20}'::jsonb,  now(), now()),
    ('30개',  'MISSION_30',  '미션 30개 완료를 달성하세요.',  403, 4, 4, 'MISSION_COUNT', '{"count":30}'::jsonb,  now(), now()),
    ('50개',  'MISSION_50',  '미션 50개 완료를 달성하세요.',  404, 4, 5, 'MISSION_COUNT', '{"count":50}'::jsonb,  now(), now());

-- Chapter 테이블 INSERT 쿼리

INSERT INTO chapter (id, title, description)
VALUES (1, '자료구조', '데이터를 효율적으로 저장하고 관리하는 구조'),
       (2, '알고리즘', '문제 해결을 위한 체계적인 절차와 기법'),
       (3, '네트워크', '컴퓨터 간 통신을 위한 구조와 프로토콜'),
       (4, '데이터베이스', '데이터를 체계적으로 저장하고 관리하는 시스템'),
       (5, '보안', '시스템과 데이터를 보호하기 위한 기술'),
       (6, 'SW 공학', '소프트웨어 개발과 유지보수를 위한 방법론'),
       (7, '운영체제', '컴퓨터 하드웨어와 소프트웨어를 관리하는 시스템');

-- Unit 테이블 INSERT 쿼리

-- Chapter 1: 자료구조
INSERT INTO unit (id, chapter_id, title, description)
VALUES (1, 1, '배열', '연속된 메모리 공간에 데이터를 저장하는 선형 자료구조'),
       (2, 1, '연결리스트', '노드가 포인터로 연결된 선형 자료구조'),
       (3, 1, '스택 & 큐', 'LIFO와 FIFO 구조의 선형 자료구조'),
       (4, 1, '트리 기본', '계층적 구조를 가진 비선형 자료구조'),
       (5, 1, '이진 트리 & 이진 탐색 트리', '최대 두 개의 자식을 가지는 트리 구조'),
       (6, 1, '힙 & 우선순위 큐', '완전 이진 트리 기반의 우선순위 자료구조'),
       (7, 1, '트라이(Trie)', '문자열 검색에 특화된 트리 자료구조'),
       (8, 1, '균형 이진 탐색 트리', '높이 균형을 유지하는 이진 탐색 트리'),
       (9, 1, '해시테이블', '키-값 쌍을 저장하는 자료구조'),
       (10, 1, '그래프', '정점과 간선으로 연결 관계를 표현하는 자료구조'),

-- Chapter 2: 알고리즘
       (11, 2, '시간복잡도 & Big-O 표기법', '알고리즘 효율성을 나타내는 지표'),
       (12, 2, '공간 복잡도 & 점근적 표기', '메모리 사용량을 나타내는 지표'),
       (13, 2, '브루트 포스 개념과 한계', '모든 경우의 수를 탐색하는 방법'),
       (14, 2, '백트래킹', '조건에 맞지 않는 경로를 제거하며 탐색하는 기법'),
       (15, 2, '버블 정렬', '인접한 원소를 비교하며 정렬하는 알고리즘'),
       (16, 2, '선택 정렬', '최솟값을 선택하여 정렬하는 알고리즘'),
       (17, 2, '삽입 정렬', '정렬된 부분에 원소를 삽입하는 알고리즘'),
       (18, 2, '합병 정렬', '분할 정복 방식의 정렬 알고리즘'),
       (19, 2, '퀵 정렬', '피벗을 기준으로 분할하는 정렬 알고리즘'),
       (20, 2, '힙 정렬', '힙 자료구조를 이용한 정렬 알고리즘'),
       (21, 2, '기수 정렬', '자릿수를 기준으로 정렬하는 알고리즘'),
       (22, 2, '위상 정렬', 'DAG에서 순서를 결정하는 알고리즘'),
       (23, 2, 'DFS와 BFS', '그래프 탐색을 위한 기본 알고리즘'),
       (24, 2, '그리디 알고리즘', '매 순간 최선의 선택을 하는 알고리즘'),
       (25, 2, '다이내믹 프로그래밍', '중복 계산을 제거하는 최적화 기법'),
       (26, 2, '최소 신장 트리(MST)', '최소 비용으로 모든 정점을 연결하는 트리'),
       (27, 2, '최단 거리 알고리즘', '최단 경로를 찾는 알고리즘'),

-- Chapter 3: 네트워크
       (28, 3, '네트워크 기초', '네트워크의 개념과 기본 구성 요소'),
       (29, 3, '네트워크 토폴로지', '네트워크의 물리적·논리적 연결 구조'),
       (30, 3, '프로토콜과 계층 구조', '통신 규칙과 OSI 7계층 모델'),
       (31, 3, '데이터 단위와 캡슐화 과정', '계층별 데이터 처리 방식'),
       (32, 3, '물리 계층과 전송 매체', '신호 전송과 물리적 연결'),
       (33, 3, '데이터 링크 계층과 이더넷', '프레임 전송과 MAC 주소'),
       (34, 3, '네트워크 계층과 IP 주소 체계', 'IP 주소와 라우팅'),
       (35, 3, '서브넷과 라우팅', '네트워크 분할과 경로 선택'),
       (36, 3, '전송 계층: TCP와 UDP', '신뢰성 있는 데이터 전송'),
       (37, 3, '포트, 소켓, NAT', '프로세스 식별과 주소 변환'),
       (38, 3, '응용 계층 서비스', 'HTTP, DNS 등 응용 프로토콜'),
       (39, 3, '웹 접속 과정과 데이터 흐름', 'URL 입력부터 응답까지의 과정'),
       (40, 3, '무선 네트워크와 이동 통신', 'Wi-Fi와 셀룰러 통신'),
       (41, 3, '네트워크 보안과 안정성', '네트워크 보호와 신뢰성 확보');
