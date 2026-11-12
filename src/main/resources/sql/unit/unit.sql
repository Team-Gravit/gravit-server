-- Unit 테이블 INSERT 쿼리
--
-- [Chapter 참조]
--  1: 자료구조              2: 알고리즘             3: 네트워크             4: 데이터베이스
--  5: 운영체제             23: 웹 보안
--  6: Common · Server       7: Common · Web        8: Common · AOS        9: Common · iOS
-- 10: BE · Spring          11: BE · Node.js       12: BE · Django
-- 13: FE · React           14: FE · Vue.js        15: FE · Next.js
-- 16: Mobile · Android     17: Mobile · iOS
-- 18: Language · Java      19: Language · Kotlin  20: Language · TypeScript
-- 21: Language · Python    22: Language · Swift
--
-- [id 구간]
-- 1~69: CS 기본 / 70~227: 직무 트랙 / 228~263: CS 추가 유닛(자료구조, 알고리즘, 네트워크, 데이터베이스 후속 유닛과 웹 보안)
-- 유닛 id는 추가된 순서로 매기므로 같은 챕터라도 이어지지 않는다. 챕터 안 순서는 display_order, 노트 파일은 note_path로 정한다.
--
-- 실행 전제: chapter/chapter.sql 이 먼저 실행되어 있어야 한다.
-- 실행 후 sync/resync_sequences.sql 을 반드시 함께 실행하라 (IDENTITY 시퀀스 재동기화).

-- Chapter 1: 자료구조
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (1, 1, '배열', '연속된 메모리 공간에 데이터를 저장하는 선형 자료구조', 'data-structure/unit01', 1),
       (2, 1, '연결리스트', '노드가 포인터로 연결된 선형 자료구조', 'data-structure/unit02', 2),
       (3, 1, '스택 & 큐', 'LIFO와 FIFO 구조의 선형 자료구조', 'data-structure/unit03', 3),
       (4, 1, '트리 기본', '계층적 구조를 가진 비선형 자료구조', 'data-structure/unit04', 4),
       (5, 1, '이진 트리 & 이진 탐색 트리', '최대 두 개의 자식을 가지는 트리 구조', 'data-structure/unit05', 5),
       (6, 1, '힙 & 우선순위 큐', '완전 이진 트리 기반의 우선순위 자료구조', 'data-structure/unit06', 6),
       (7, 1, '트라이(Trie)', '문자열 검색에 특화된 트리 자료구조', 'data-structure/unit07', 7),
       (8, 1, '균형 이진 탐색 트리', '높이 균형을 유지하는 이진 탐색 트리', 'data-structure/unit08', 8),
       (9, 1, '해시테이블', '키-값 쌍을 저장하는 자료구조', 'data-structure/unit09', 9),
       (10, 1, '그래프', '정점과 간선으로 연결 관계를 표현하는 자료구조', 'data-structure/unit10', 10),
       (228, 1, '덱과 우선순위 큐', '양 끝 삽입·삭제와 우선순위 기반 꺼내기를 지원하는 자료구조', 'data-structure/unit11', 11),
       (229, 1, '유니온-파인드', '서로소 집합을 합치고 대표 원소를 찾는 자료구조', 'data-structure/unit12', 12);

-- Chapter 2: 알고리즘
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (11, 2, '시간복잡도 & Big-O 표기법', '알고리즘 효율성을 나타내는 지표', 'algorithm/unit01', 1),
       (12, 2, '공간 복잡도 & 점근적 표기', '메모리 사용량을 나타내는 지표', 'algorithm/unit02', 2),
       (13, 2, '브루트 포스 개념과 한계', '모든 경우의 수를 탐색하는 방법', 'algorithm/unit03', 3),
       (14, 2, '백트래킹', '조건에 맞지 않는 경로를 제거하며 탐색하는 기법', 'algorithm/unit04', 4),
       (15, 2, '버블 정렬', '인접한 원소를 비교하며 정렬하는 알고리즘', 'algorithm/unit05', 5),
       (16, 2, '선택 정렬', '최솟값을 선택하여 정렬하는 알고리즘', 'algorithm/unit06', 6),
       (17, 2, '삽입 정렬', '정렬된 부분에 원소를 삽입하는 알고리즘', 'algorithm/unit07', 7),
       (18, 2, '합병 정렬', '분할 정복 방식의 정렬 알고리즘', 'algorithm/unit08', 8),
       (19, 2, '퀵 정렬', '피벗을 기준으로 분할하는 정렬 알고리즘', 'algorithm/unit09', 9),
       (20, 2, '힙 정렬', '힙 자료구조를 이용한 정렬 알고리즘', 'algorithm/unit10', 10),
       (21, 2, '기수 정렬', '자릿수를 기준으로 정렬하는 알고리즘', 'algorithm/unit11', 11),
       (22, 2, '위상 정렬', 'DAG에서 순서를 결정하는 알고리즘', 'algorithm/unit12', 12),
       (23, 2, 'DFS와 BFS', '그래프 탐색을 위한 기본 알고리즘', 'algorithm/unit13', 13),
       (24, 2, '그리디 알고리즘', '매 순간 최선의 선택을 하는 알고리즘', 'algorithm/unit14', 14),
       (25, 2, '다이내믹 프로그래밍', '중복 계산을 제거하는 최적화 기법', 'algorithm/unit15', 15),
       (26, 2, '최소 신장 트리(MST)', '최소 비용으로 모든 정점을 연결하는 트리', 'algorithm/unit16', 16),
       (27, 2, '최단 거리 알고리즘', '최단 경로를 찾는 알고리즘', 'algorithm/unit17', 17),
       (230, 2, '재귀와 분할 정복', '문제를 작은 부분 문제로 나눠 풀고 결과를 합치는 기법', 'algorithm/unit18', 18),
       (231, 2, '이진 탐색', '정렬된 범위를 절반씩 줄여 값을 찾는 탐색 알고리즘', 'algorithm/unit19', 19),
       (232, 2, '파라메트릭 서치와 lower/upper bound', '최적화 문제를 결정 문제로 바꿔 경계를 찾는 탐색 기법', 'algorithm/unit20', 20),
       (233, 2, '투 포인터와 슬라이딩 윈도우', '두 인덱스를 움직여 구간을 선형 시간에 탐색하는 기법', 'algorithm/unit21', 21),
       (234, 2, '동적 프로그래밍 활용', 'LIS, LCS, 배낭 문제 등 대표 DP 유형의 상태 설계', 'algorithm/unit22', 22),
       (235, 2, '문자열 탐색 - KMP', '실패 함수로 비교를 재사용하는 선형 시간 문자열 탐색', 'algorithm/unit23', 23);

-- Chapter 3: 네트워크
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (28, 3, '네트워크 기초', '네트워크의 개념과 기본 구성 요소', 'network/unit01', 1),
       (29, 3, '네트워크 토폴로지', '네트워크의 물리적·논리적 연결 구조', 'network/unit02', 2),
       (30, 3, '프로토콜과 계층 구조', '통신 규칙과 OSI 7계층 모델', 'network/unit03', 3),
       (31, 3, '데이터 단위와 캡슐화 과정', '계층별 데이터 처리 방식', 'network/unit04', 4),
       (32, 3, '물리 계층과 전송 매체', '신호 전송과 물리적 연결', 'network/unit05', 5),
       (33, 3, '데이터 링크 계층과 이더넷', '프레임 전송과 MAC 주소', 'network/unit06', 6),
       (34, 3, '네트워크 계층과 IP 주소 체계', 'IP 주소와 라우팅', 'network/unit07', 7),
       (35, 3, '서브넷과 라우팅', '네트워크 분할과 경로 선택', 'network/unit08', 8),
       (36, 3, '전송 계층: TCP와 UDP', '신뢰성 있는 데이터 전송', 'network/unit09', 9),
       (37, 3, '포트, 소켓, NAT', '프로세스 식별과 주소 변환', 'network/unit10', 10),
       (38, 3, '응용 계층 서비스', 'HTTP, DNS 등 응용 프로토콜', 'network/unit11', 11),
       (39, 3, '웹 접속 과정과 데이터 흐름', 'URL 입력부터 응답까지의 과정', 'network/unit12', 12),
       (40, 3, '무선 네트워크와 이동 통신', 'Wi-Fi와 셀룰러 통신', 'network/unit13', 13),
       (41, 3, '네트워크 보안과 안정성', '네트워크 보호와 신뢰성 확보', 'network/unit14', 14),
       (236, 3, 'ARP와 DHCP', 'IP와 MAC 주소 변환, 주소 자동 할당 과정', 'network/unit15', 15),
       (237, 3, 'TCP 신뢰성 - 흐름, 혼잡, 오류 제어', 'TCP가 순서와 전달을 보장하고 전송량을 조절하는 방식', 'network/unit16', 16),
       (238, 3, 'DNS', '도메인 이름을 IP 주소로 바꾸는 계층적 조회 체계', 'network/unit17', 17),
       (239, 3, 'HTTP 심화 - 버전과 캐시', 'HTTP/1.1, 2, 3의 차이와 캐시 제어 헤더', 'network/unit18', 18),
       (240, 3, 'HTTPS와 TLS', 'TLS 핸드셰이크와 암호화 통신의 원리', 'network/unit19', 19),
       (241, 3, '쿠키, 세션, 토큰', '무상태 HTTP에서 사용자 상태를 유지하는 방법', 'network/unit20', 20),
       (242, 3, 'REST API', '자원 중심 URI와 메서드, 상태 코드 설계 원칙', 'network/unit21', 21),
       (243, 3, '로드밸런싱, 프록시, CDN', '트래픽 분산과 중계, 콘텐츠 전송 가속 구조', 'network/unit22', 22);

-- Chapter 4: 데이터베이스
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (42, 4, '데이터 모델링 기본', '개념적, 논리적, 물리적 모델링의 기초', 'database/unit01', 1),
       (43, 4, '식별 관계와 비식별 관계', '엔터티 간 관계의 종류와 특성', 'database/unit02', 2),
       (44, 4, '관계형 모델 개념', '릴레이션, 튜플, 속성과 무결성 제약', 'database/unit03', 3),
       (45, 4, '키', '기본키, 후보키, 외래키 등 키의 개념', 'database/unit04', 4),
       (46, 4, '외래키와 제약 조건', '참조 무결성과 제약 조건', 'database/unit05', 5),
       (47, 4, 'DDL', '데이터 정의어(CREATE, ALTER, DROP)', 'database/unit06', 6),
       (48, 4, 'DML', '데이터 조작어(SELECT, INSERT, UPDATE, DELETE)', 'database/unit07', 7),
       (49, 4, '서브쿼리', '쿼리 안의 쿼리: 스칼라/인라인뷰/상관 서브쿼리와 EXISTS 활용', 'database/unit08', 8),
       (50, 4, '조인', '여러 테이블 결합(INNER/OUTER/CROSS/SELF)과 조인 조건 설계', 'database/unit09', 9),
       (51, 4, '페이징', 'LIMIT/OFFSET 및 커서 기반 페이징의 원리와 성능 고려', 'database/unit10', 10),
       (52, 4, '뷰', '가상 테이블(View)의 목적, 장단점, 보안/추상화 활용', 'database/unit11', 11),
       (53, 4, '정규화', '이상 현상 방지: 1NF~3NF/BCNF와 반정규화 트레이드오프', 'database/unit12', 12),
       (54, 4, '트랜잭션', '원자성·일관성·고립성·지속성(ACID)과 격리 수준/락', 'database/unit13', 13),
       (55, 4, '인덱스', '조회 성능 향상을 위한 인덱스 구조(B-Tree 등)와 설계/주의점', 'database/unit14', 14),
       (244, 4, 'SQL 개요와 명령어 분류', 'SQL의 특징과 DDL, DML, DCL, TCL 분류', 'database/unit15', 15),
       (245, 4, '집계 함수와 GROUP BY, HAVING', '행을 그룹으로 묶어 요약하고 그룹 조건을 거는 방법', 'database/unit16', 16),
       (246, 4, '동시성 제어 - 격리 수준, 락, MVCC', '동시 트랜잭션의 이상 현상과 이를 막는 제어 기법', 'database/unit17', 17),
       (247, 4, 'SQL 튜닝과 실행 계획', '실행 계획 해석과 쿼리 성능 개선 방법', 'database/unit18', 18),
       (248, 4, '커넥션과 커넥션 풀', 'DB 연결 비용과 커넥션 재사용 구조', 'database/unit19', 19),
       (249, 4, '확장 전략 - 파티셔닝, 샤딩, 레플리케이션', '데이터 분할과 복제로 DB를 확장하는 방법', 'database/unit20', 20),
       (250, 4, 'NoSQL과 CAP 이론', '비관계형 데이터베이스 유형과 분산 시스템의 트레이드오프', 'database/unit21', 21);

-- Chapter 5: 운영체제
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (56, 5, '운영체제 개요', '하드웨어와 사용자 사이의 인터페이스 역할을 하는 시스템 소프트웨어', 'operating-system/unit01', 1),
       (57, 5, '프로세스 기초', '실행 중인 프로그램으로 메모리 구조와 상태 전이', 'operating-system/unit02', 2),
       (58, 5, '시스템 콜', '응용 프로그램이 커널 서비스를 요청하는 인터페이스', 'operating-system/unit03', 3),
       (59, 5, '인터럽트', 'CPU가 예기치 않은 상황을 처리하는 메커니즘', 'operating-system/unit04', 4),
       (60, 5, '프로세스 관리', '프로세스 생성, 종료, IPC와 스케줄링', 'operating-system/unit05', 5),
       (61, 5, '스레드와 멀티스레딩', '프로세스 내 실행 흐름과 동시성 구현', 'operating-system/unit06', 6),
       (62, 5, 'CPU 스케줄링', '프로세스에 CPU를 할당하는 알고리즘', 'operating-system/unit07', 7),
       (63, 5, '동기화와 병행성', '공유 자원 접근 제어와 임계 영역 보호', 'operating-system/unit08', 8),
       (64, 5, '데드락', '프로세스 간 자원 대기로 인한 교착 상태', 'operating-system/unit09', 9),
       (65, 5, '메모리 관리 기초', '메모리 계층 구조와 주소 바인딩', 'operating-system/unit10', 10),
       (66, 5, '가상 메모리', '물리 메모리 제약 없는 논리 주소 공간', 'operating-system/unit11', 11),
       (67, 5, '페이지 관리', '페이지 교체 알고리즘과 스레싱 해결', 'operating-system/unit12', 12),
       (68, 5, '캐시 메모리', '고속 메모리로 지역성 기반 성능 향상', 'operating-system/unit13', 13),
       (69, 5, '파일 시스템과 디스크 관리', '파일 저장 구조와 디스크 스케줄링 알고리즘', 'operating-system/unit14', 14);

-- Chapter 6: Common · Server
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (70, 6, '트랜잭션과 격리 수준', '원자적 실행 단위와 동시 실행 시의 격리 정도', 'common-server/unit01', 1),
       (71, 6, '인덱스와 실행 계획', '조회 경로 선택 방식과 실행 계획 해석', 'common-server/unit02', 2),
       (72, 6, '동시성 제어와 락', '락의 종류와 경합 상황에서의 자원 보호', 'common-server/unit03', 3),
       (73, 6, '분산 환경의 정합성', '여러 서버에 흩어진 데이터의 일관성 확보', 'common-server/unit04', 4),
       (74, 6, '캐시 전략', '캐시 적용 방식과 무효화 전략', 'common-server/unit05', 5),
       (75, 6, '비동기 메시징', '메시지 큐 기반의 느슨한 결합과 처리 보장', 'common-server/unit06', 6),
       (76, 6, '데이터베이스 확장', '복제, 샤딩, 파티셔닝을 통한 확장 방법', 'common-server/unit07', 7),
       (77, 6, 'HTTP와 REST API 설계', '자원 중심 인터페이스 설계 원칙과 규약', 'common-server/unit08', 8),
       (78, 6, '인증과 인가', '신원 확인과 권한 부여 방식', 'common-server/unit09', 9),
       (79, 6, '트래픽 처리와 자원 관리', '부하 분산과 커넥션, 스레드 자원 운용', 'common-server/unit10', 10),
       (80, 6, '배포와 무중단 전환', '서비스 중단 없이 새 버전으로 전환하는 전략', 'common-server/unit11', 11),
       (81, 6, '관측성', '로그, 메트릭, 추적으로 시스템 상태 파악', 'common-server/unit12', 12);

-- Chapter 7: Common · Web
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (82, 7, '브라우저 렌더링 파이프라인', 'HTML이 화면에 그려지기까지의 처리 과정', 'common-web/unit01', 1),
       (83, 7, 'Reflow와 Repaint', '레이아웃 재계산과 다시 그리기의 발생 조건', 'common-web/unit02', 2),
       (84, 7, '이벤트 루프와 실행 순서', '태스크 큐 기반의 자바스크립트 실행 순서', 'common-web/unit03', 3),
       (85, 7, '리소스 로딩과 파서 차단', '스크립트와 스타일이 파싱에 미치는 영향', 'common-web/unit04', 4),
       (86, 7, '렌더링 전략', 'CSR, SSR, SSG 등 화면 생성 시점의 선택', 'common-web/unit05', 5),
       (87, 7, '브라우저 저장소와 세션 유지', '쿠키와 스토리지를 이용한 상태 보관', 'common-web/unit06', 6),
       (88, 7, '동일 출처 정책과 CORS', '출처 기반 접근 제한과 교차 출처 허용', 'common-web/unit07', 7),
       (89, 7, '웹 보안', 'XSS, CSRF 등 웹 취약점과 대응 방안', 'common-web/unit08', 8),
       (90, 7, 'HTTP 캐싱', '캐시 헤더와 재검증을 통한 응답 재사용', 'common-web/unit09', 9),
       (91, 7, '웹 성능 지표와 측정', 'Core Web Vitals와 성능 측정 방법', 'common-web/unit10', 10);

-- Chapter 8: Common · AOS
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (92, 8, '4대 컴포넌트와 인텐트', '앱 구성 요소와 컴포넌트 간 호출 방식', 'common-aos/unit01', 1),
       (93, 8, '액티비티와 프래그먼트 생명주기', '화면 상태 전이와 콜백 호출 순서', 'common-aos/unit02', 2),
       (94, 8, '구성 변경과 상태 보존', '화면 회전 등 구성 변경 시 데이터 유지', 'common-aos/unit03', 3),
       (95, 8, '프로세스 수명과 메모리 압력', '시스템에 의한 앱 종료와 상태 복원', 'common-aos/unit04', 4),
       (96, 8, '메모리 누수 패턴', '참조가 남아 회수되지 않는 대표 사례', 'common-aos/unit05', 5),
       (97, 8, '백그라운드 작업', '화면 밖에서 실행되는 작업의 실행 보장', 'common-aos/unit06', 6),
       (98, 8, '데이터 저장소 선택', '저장 방식별 특성과 상황에 맞는 선택', 'common-aos/unit07', 7),
       (99, 8, '네트워크 계층', '통신 라이브러리 구성과 응답 처리 방식', 'common-aos/unit08', 8),
       (100, 8, '앱 아키텍처', '계층 분리와 관심사 분리를 위한 구조', 'common-aos/unit09', 9),
       (101, 8, '권한과 보안', '런타임 권한 요청과 민감 정보 보호', 'common-aos/unit10', 10);

-- Chapter 9: Common · iOS
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (102, 9, '앱 생명주기와 상태 전이', '앱 실행 상태의 변화와 시스템 통지 시점', 'common-ios/unit01', 1),
       (103, 9, '뷰 컨트롤러 생명주기', '화면 표시 전후에 호출되는 콜백 순서', 'common-ios/unit02', 2),
       (104, 9, '메모리 압력과 백그라운드 종료', '메모리 부족 시 앱 종료와 대응 방법', 'common-ios/unit03', 3),
       (105, 9, '셀 재사용과 리스트 성능', '셀 재사용 구조와 스크롤 성능 관리', 'common-ios/unit04', 4),
       (106, 9, '데이터 영속화 선택', '저장 방식별 특성과 상황에 맞는 선택', 'common-ios/unit05', 5),
       (107, 9, '네트워크 계층', '통신 계층 구성과 응답 처리 방식', 'common-ios/unit06', 6),
       (108, 9, '샌드박스와 앱 간 공유', '파일 접근 제한과 앱 간 데이터 전달', 'common-ios/unit07', 7),
       (109, 9, '앱 아키텍처', '계층 분리와 관심사 분리를 위한 구조', 'common-ios/unit08', 8),
       (110, 9, '푸시 알림', '원격 알림의 전달 흐름과 수신 처리', 'common-ios/unit09', 9),
       (111, 9, '권한과 프라이버시', '사용자 동의 획득과 개인정보 보호 정책', 'common-ios/unit10', 10);

-- Chapter 10: BE · Spring
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (112, 10, 'IoC/DI와 빈 생명주기', '컨테이너의 객체 관리와 생성, 소멸 과정', 'be-spring/unit01', 1),
       (113, 10, 'AOP와 프록시 동작', '공통 관심사 분리와 프록시 기반 위임', 'be-spring/unit02', 2),
       (114, 10, '요청 처리 흐름', '디스패처 서블릿부터 응답까지의 처리 경로', 'be-spring/unit03', 3),
       (115, 10, '요청 전후 처리 계층', '필터, 인터셉터, 아규먼트 리졸버의 역할', 'be-spring/unit04', 4),
       (116, 10, '트랜잭션 추상화', '선언적 트랜잭션의 전파 속성과 롤백 규칙', 'be-spring/unit05', 5),
       (117, 10, '영속성 컨텍스트', '엔티티 관리와 변경 감지, 쓰기 지연', 'be-spring/unit06', 6),
       (118, 10, '연관관계와 N+1', '지연 로딩과 조회 쿼리가 늘어나는 문제', 'be-spring/unit07', 7),
       (119, 10, 'JPA 쓰기와 식별자 전략', '저장 시점과 기본키 생성 전략의 차이', 'be-spring/unit08', 8),
       (120, 10, '예외 처리와 응답 규약', '전역 예외 처리와 일관된 응답 형식', 'be-spring/unit09', 9),
       (121, 10, '인증·인가 필터 체인', '시큐리티 필터의 순서와 인증 처리 흐름', 'be-spring/unit10', 10),
       (122, 10, '스레드와 커넥션 자원 관리', '스레드 풀과 커넥션 풀의 운용과 한계', 'be-spring/unit11', 11);

-- Chapter 11: BE · Node.js
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (123, 11, '이벤트 루프와 논블로킹 I/O', '단일 스레드 기반의 비동기 처리 구조', 'be-nodejs/unit01', 1),
       (124, 11, '마이크로태스크와 매크로태스크', '큐 우선순위에 따른 콜백 실행 순서', 'be-nodejs/unit02', 2),
       (125, 11, 'CPU 바운드 작업 처리', '연산 부하로 인한 이벤트 루프 블로킹 해소', 'be-nodejs/unit03', 3),
       (126, 11, '모듈 시스템', 'CommonJS와 ESM의 차이와 모듈 로딩 방식', 'be-nodejs/unit04', 4),
       (127, 11, '스트림과 백프레셔', '청크 단위 처리와 처리 속도 조절', 'be-nodejs/unit05', 5),
       (128, 11, '모듈과 프로바이더 스코프', 'NestJS의 의존성 주입과 인스턴스 범위', 'be-nodejs/unit06', 6),
       (129, 11, '요청 처리 파이프라인', '가드, 인터셉터, 파이프의 실행 순서', 'be-nodejs/unit07', 7),
       (130, 11, '에러 핸들링과 프로세스 안정성', '예외 전파 처리와 프로세스 종료 방지', 'be-nodejs/unit08', 8),
       (131, 11, '메모리 누수 진단', '힙 스냅샷을 이용한 누수 원인 추적', 'be-nodejs/unit09', 9);

-- Chapter 12: BE · Django
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (132, 12, '요청·응답 사이클과 미들웨어', '요청이 뷰에 닿기까지의 처리 순서', 'be-django/unit01', 1),
       (133, 12, 'QuerySet 지연 평가', '쿼리가 실제로 실행되는 시점과 판단 기준', 'be-django/unit02', 2),
       (134, 12, '조회 최적화와 N+1', 'select_related와 prefetch_related 활용', 'be-django/unit03', 3),
       (135, 12, '트랜잭션 관리', 'atomic 블록과 커밋, 롤백이 일어나는 시점', 'be-django/unit04', 4),
       (136, 12, '마이그레이션', '모델 변경을 스키마에 반영하는 절차', 'be-django/unit05', 5),
       (137, 12, '인증과 권한', '사용자 인증 체계와 접근 권한 제어', 'be-django/unit06', 6),
       (138, 12, 'DRF 직렬화와 검증', '시리얼라이저의 변환 과정과 입력 검증', 'be-django/unit07', 7),
       (139, 12, '시그널과 암묵적 결합', '신호 기반 처리의 부작용과 대안', 'be-django/unit08', 8),
       (140, 12, '동기와 비동기 혼용', 'ASGI 환경에서 둘을 함께 쓸 때의 주의점', 'be-django/unit09', 9);

-- Chapter 13: FE · React
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (141, 13, '렌더링과 재조정', '리렌더 발생 조건과 변경 사항 비교 과정', 'fe-react/unit01', 1),
       (142, 13, '훅의 동작 원리', '호출 순서에 의존하는 훅의 내부 동작', 'fe-react/unit02', 2),
       (143, 13, '상태 설계', '상태의 위치와 최소 단위를 정하는 기준', 'fe-react/unit03', 3),
       (144, 13, '상태 관리 전략', '지역, 전역, 서버 상태의 분리와 도구 선택', 'fe-react/unit04', 4),
       (145, 13, 'useEffect의 정의와 오용', '외부 동기화 용도와 잘못된 사용 사례', 'fe-react/unit05', 5),
       (146, 13, '렌더링 최적화 판단', '메모이제이션이 실제로 필요한 시점', 'fe-react/unit06', 6),
       (147, 13, 'ref와 DOM 접근', '렌더링 밖의 값 보관과 DOM 직접 제어', 'fe-react/unit07', 7),
       (148, 13, '동시성 렌더링', '렌더링 우선순위 조정과 중단 가능한 렌더', 'fe-react/unit08', 8),
       (149, 13, '에러 경계와 예외 처리', '렌더 중 발생한 오류의 격리와 복구', 'fe-react/unit09', 9),
       (150, 13, '컴포넌트 설계', '재사용과 합성을 고려한 컴포넌트 분리', 'fe-react/unit10', 10);

-- Chapter 14: FE · Vue.js
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (151, 14, '반응성 시스템 원리', '의존성 추적과 자동 갱신이 일어나는 구조', 'fe-vue/unit01', 1),
       (152, 14, 'ref와 reactive', '두 반응형 API의 차이와 선택 기준', 'fe-vue/unit02', 2),
       (153, 14, 'computed와 watch', '파생 값 계산과 변화 감지의 구분', 'fe-vue/unit03', 3),
       (154, 14, 'Composition API와 Options API', '두 작성 방식의 차이와 전환 기준', 'fe-vue/unit04', 4),
       (155, 14, '컴포넌트 통신', 'props, emit, provide로 데이터를 전달하는 방법', 'fe-vue/unit05', 5),
       (156, 14, '렌더링 제어', '조건부, 반복 렌더링과 key의 역할', 'fe-vue/unit06', 6),
       (157, 14, '생명주기와 DOM 접근 시점', '훅 호출 순서와 DOM 접근이 가능한 시점', 'fe-vue/unit07', 7);

-- Chapter 15: FE · Next.js
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (158, 15, '렌더링 전략 선택', '페이지 특성에 맞는 렌더링 방식 결정', 'fe-nextjs/unit01', 1),
       (159, 15, '서버·클라이언트 컴포넌트 경계', '실행 위치 구분과 경계를 나누는 기준', 'fe-nextjs/unit02', 2),
       (160, 15, '데이터 페칭과 폭포수', '요청이 순차 실행되며 생기는 지연 해소', 'fe-nextjs/unit03', 3),
       (161, 15, '캐싱 레이어', '요청, 데이터, 라우트 단위의 캐시 구조', 'fe-nextjs/unit04', 4),
       (162, 15, '재검증 전략', '시간 기반과 태그 기반의 캐시 갱신', 'fe-nextjs/unit05', 5),
       (163, 15, '서버 액션', '서버에서 실행되는 폼 처리와 변경 작업', 'fe-nextjs/unit06', 6),
       (164, 15, '하이드레이션', '서버 렌더 결과에 이벤트를 연결하는 과정', 'fe-nextjs/unit07', 7),
       (165, 15, '라우팅·레이아웃과 미들웨어', '파일 기반 라우팅과 요청 전처리', 'fe-nextjs/unit08', 8),
       (166, 15, '자산과 번들 최적화', '이미지, 폰트와 번들 크기 최적화', 'fe-nextjs/unit09', 9);

-- Chapter 16: Mobile · Android
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (167, 16, 'ViewModel과 상태 보존', '화면 상태 유지와 생명주기 대응 방식', 'mobile-android/unit01', 1),
       (168, 16, '선언형 UI와 Recomposition', '상태 변화에 따른 UI 재구성 과정', 'mobile-android/unit02', 2),
       (169, 16, 'Compose 상태 관리', '상태 호이스팅과 상태를 저장하는 방식', 'mobile-android/unit03', 3),
       (170, 16, 'Compose 안정성과 최적화', '불필요한 재구성을 줄이는 안정성 조건', 'mobile-android/unit04', 4),
       (171, 16, 'Compose 부수효과 API', '컴포지션 밖의 작업을 다루는 효과 API', 'mobile-android/unit05', 5),
       (172, 16, '생명주기 인식 데이터 수집', '화면 상태에 맞춘 데이터 구독 관리', 'mobile-android/unit06', 6),
       (173, 16, '의존성 주입', '객체 생성과 주입을 외부에 위임하는 구조', 'mobile-android/unit07', 7),
       (174, 16, 'Navigation과 화면 전환', '화면 이동과 인자 전달, 백스택 관리', 'mobile-android/unit08', 8),
       (175, 16, '리스트 성능', '지연 목록의 key 설정과 스크롤 성능', 'mobile-android/unit09', 9),
       (176, 16, '테스트 가능한 구조', '의존성 분리를 통한 검증 가능한 설계', 'mobile-android/unit10', 10);

-- Chapter 17: Mobile · iOS
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (177, 17, 'SwiftUI 뷰 정체성과 업데이트', '뷰를 식별하는 방식과 갱신 판단 기준', 'mobile-ios/unit01', 1),
       (178, 17, '상태 프로퍼티 래퍼', 'State, Binding 등 상태의 소유와 전달', 'mobile-ios/unit02', 2),
       (179, 17, 'Observation 프레임워크', '관찰 기반 상태 추적과 갱신 범위 최소화', 'mobile-ios/unit03', 3),
       (180, 17, '뷰 모디파이어와 재사용 설계', '모디파이어 적용 순서와 스타일 공통화', 'mobile-ios/unit04', 4),
       (181, 17, 'UIKit과 SwiftUI 상호운용', '두 프레임워크를 함께 사용하는 방법', 'mobile-ios/unit05', 5),
       (182, 17, '레이아웃 시스템', '크기 제안과 배치가 결정되는 과정', 'mobile-ios/unit06', 6),
       (183, 17, '리스트 성능', '지연 스택과 목록 갱신 비용 관리', 'mobile-ios/unit07', 7),
       (184, 17, '화면 전환과 흐름 제어', '내비게이션 스택과 화면 흐름 관리', 'mobile-ios/unit08', 8),
       (185, 17, 'Combine과 데이터 바인딩', '퍼블리셔 기반의 비동기 데이터 흐름', 'mobile-ios/unit09', 9);

-- Chapter 18: Language · Java
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (186, 18, 'JVM 메모리 구조', '힙, 스택 등 런타임 데이터 영역의 구성', 'lang-java/unit01', 1),
       (187, 18, '가비지 컬렉션', '객체 회수 방식과 GC 알고리즘의 차이', 'lang-java/unit02', 2),
       (188, 18, 'equals와 hashCode 계약', '두 메서드가 함께 지켜야 하는 규약', 'lang-java/unit03', 3),
       (189, 18, '컬렉션 내부 구조', 'List, Map, Set의 구현 방식과 성능 특성', 'lang-java/unit04', 4),
       (190, 18, '예외 체계와 설계', '검사와 비검사 예외의 구분과 처리 전략', 'lang-java/unit05', 5),
       (191, 18, '제네릭과 타입 소거', '컴파일 시점 타입 검사와 런타임 소거', 'lang-java/unit06', 6),
       (192, 18, '스트림과 함수형 인터페이스', '파이프라인 연산과 람다를 통한 표현', 'lang-java/unit07', 7),
       (193, 18, '동시성 기본', '스레드와 공유 자원, 메모리 가시성 문제', 'lang-java/unit08', 8),
       (194, 18, '고수준 동시성 API', '실행자와 동시성 유틸리티의 활용', 'lang-java/unit09', 9),
       (195, 18, '불변 객체와 값 설계', '변경 불가능한 객체의 설계 방법과 이점', 'lang-java/unit10', 10);

-- Chapter 19: Language · Kotlin
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (196, 19, 'Null Safety 설계', '널 가능 타입의 구분과 안전한 처리 방법', 'lang-kotlin/unit01', 1),
       (197, 19, '코루틴 구조화된 동시성', '스코프를 기준으로 한 코루틴 수명 관리', 'lang-kotlin/unit02', 2),
       (198, 19, '코루틴 예외 처리', '취소 전파와 예외를 처리하는 방식', 'lang-kotlin/unit03', 3),
       (199, 19, 'Flow', '비동기 데이터 스트림의 생성과 수집', 'lang-kotlin/unit04', 4),
       (200, 19, '확장 함수와 스코프 함수', '기능 확장과 스코프 함수의 선택 기준', 'lang-kotlin/unit05', 5),
       (201, 19, 'data·sealed·object', '목적에 따른 클래스 선언 방식의 차이', 'lang-kotlin/unit06', 6),
       (202, 19, '위임과 프로퍼티', '위임 패턴과 프로퍼티 초기화 제어', 'lang-kotlin/unit07', 7),
       (203, 19, '가시성과 불변성', '접근 범위 제한과 val 기반의 설계', 'lang-kotlin/unit08', 8),
       (204, 19, '자바 상호운용', '자바 코드와 함께 사용할 때의 주의점', 'lang-kotlin/unit09', 9);

-- Chapter 20: Language · TypeScript
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (205, 20, '구조적 타이핑', '형태를 기준으로 하는 타입 호환성 판단', 'lang-typescript/unit01', 1),
       (206, 20, '제네릭과 제약', '타입 매개변수와 extends를 통한 제한', 'lang-typescript/unit02', 2),
       (207, 20, '타입 좁히기', '조건 검사로 타입 범위를 좁히는 방법', 'lang-typescript/unit03', 3),
       (208, 20, 'any·unknown·never', '특수 타입의 의미와 사용 기준', 'lang-typescript/unit04', 4),
       (209, 20, '인터페이스와 타입 별칭', '두 선언 방식의 차이와 선택 기준', 'lang-typescript/unit05', 5),
       (210, 20, '유틸리티 타입과 매핑 타입', '기존 타입을 변형해 새 타입을 만드는 방법', 'lang-typescript/unit06', 6),
       (211, 20, '컴파일과 런타임 경계', '타입이 사라지는 시점과 검증의 필요성', 'lang-typescript/unit07', 7);

-- Chapter 21: Language · Python
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (212, 21, 'GIL과 동시성 모델', '전역 인터프리터 락과 병렬 처리의 한계', 'lang-python/unit01', 1),
       (213, 21, '메모리 관리', '참조 카운팅과 순환 참조의 수거 방식', 'lang-python/unit02', 2),
       (214, 21, '가변·불변 객체와 함정', '변경 가능 여부에 따른 동작 차이', 'lang-python/unit03', 3),
       (215, 21, '이터레이터와 제너레이터', '반복 프로토콜과 지연 평가 방식', 'lang-python/unit04', 4),
       (216, 21, '데코레이터 동작 원리', '함수를 감싸 기능을 덧붙이는 구조', 'lang-python/unit05', 5),
       (217, 21, '클래스와 MRO', '상속 구조와 메서드를 탐색하는 순서', 'lang-python/unit06', 6),
       (218, 21, '타입 힌트', '타입 표기와 정적 검사 도구의 활용', 'lang-python/unit07', 7),
       (219, 21, '예외와 컨텍스트 매니저', '예외 처리와 자원 정리의 보장', 'lang-python/unit08', 8);

-- Chapter 22: Language · Swift
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (220, 22, '값 타입 vs 참조 타입', '복사와 참조에 따른 동작 차이', 'lang-swift/unit01', 1),
       (221, 22, 'ARC와 순환 참조', '참조 카운팅 기반 메모리 관리와 누수', 'lang-swift/unit02', 2),
       (222, 22, '옵셔널 처리 전략', '값이 없을 수 있는 타입의 안전한 사용', 'lang-swift/unit03', 3),
       (223, 22, '프로토콜 지향 프로그래밍', '프로토콜과 확장을 중심으로 하는 설계', 'lang-swift/unit04', 4),
       (224, 22, '제네릭과 associatedtype', '타입 매개변수와 프로토콜의 연관 타입', 'lang-swift/unit05', 5),
       (225, 22, 'Swift Concurrency', 'async/await 기반의 비동기 처리', 'lang-swift/unit06', 6),
       (226, 22, 'actor와 데이터 격리', '액터를 통한 동시 접근 제어', 'lang-swift/unit07', 7),
       (227, 22, '에러 처리', 'throws와 do-catch를 통한 오류 전파', 'lang-swift/unit08', 8);

-- Chapter 23: 웹 보안
INSERT INTO unit (id, chapter_id, title, description, note_path, display_order)
VALUES (251, 23, '웹 보안 기초와 OWASP Top 10', '웹 보안의 기본 원칙과 대표 취약점 분류', 'web-security/unit01', 1),
       (252, 23, 'SQL 인젝션', '입력값으로 쿼리 구조를 바꾸는 공격과 방어', 'web-security/unit02', 2),
       (253, 23, 'XSS', '악성 스크립트를 페이지에 주입하는 공격과 방어', 'web-security/unit03', 3),
       (254, 23, 'CSRF', '사용자 권한으로 원치 않는 요청을 보내게 하는 공격과 방어', 'web-security/unit04', 4),
       (255, 23, 'SOP와 CORS', '출처 기반 접근 제한과 교차 출처 허용 방식', 'web-security/unit05', 5),
       (256, 23, '인증과 인가 - 세션 vs JWT', '신원 확인과 권한 부여, 세션과 토큰 방식 비교', 'web-security/unit06', 6),
       (257, 23, '세션 공격 - 하이재킹, 고정', '세션 식별자를 탈취하거나 고정하는 공격과 방어', 'web-security/unit07', 7),
       (258, 23, '암호학 기초', '대칭키, 공개키, 해시, 전자서명의 원리', 'web-security/unit08', 8),
       (259, 23, '비밀번호의 안전한 저장', '솔트와 느린 해시로 비밀번호를 보관하는 방법', 'web-security/unit09', 9),
       (260, 23, 'HTTPS 인증서와 CA 체인', '인증서 발급과 신뢰 체인 검증 과정', 'web-security/unit10', 10),
       (261, 23, '파일 업로드 취약점', '업로드 파일을 통한 공격과 검증 방법', 'web-security/unit11', 11),
       (262, 23, 'SSRF, 오픈 리다이렉트, 클릭재킹', '서버 요청 위조와 리다이렉트, 화면 위장 공격과 방어', 'web-security/unit12', 12),
       (263, 23, '접근 통제와 시큐어 코딩', '권한 검증 누락을 막는 접근 통제와 안전한 코딩 원칙', 'web-security/unit13', 13);
