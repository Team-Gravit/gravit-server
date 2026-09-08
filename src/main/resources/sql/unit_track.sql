-- Unit 테이블 INSERT 쿼리 (직무 트랙 유닛, id 70~227)
--
-- [Chapter 참조]
--  6: Common · Server        7: Common · Web        8: Common · AOS        9: Common · iOS
-- 10: BE · Spring           11: BE · Node.js       12: BE · Django
-- 13: FE · React            14: FE · Vue.js        15: FE · Next.js
-- 16: Mobile · Android      17: Mobile · iOS
-- 18: Language · Java       19: Language · Kotlin  20: Language · TypeScript
-- 21: Language · Python     22: Language · Swift
--
-- 실행 전제: chapter_track.sql 이 먼저 실행되어 chapter id 6~22 가 존재해야 한다.
-- 실행 후 resync_sequences.sql 을 반드시 함께 실행하라 (IDENTITY 시퀀스 재동기화).

-- Chapter 6: Common · Server
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (70, 6, '트랜잭션과 격리 수준', '원자적 실행 단위와 동시 실행 시의 격리 정도', 'common-server/unit01'),
       (71, 6, '인덱스와 실행 계획', '조회 경로 선택 방식과 실행 계획 해석', 'common-server/unit02'),
       (72, 6, '동시성 제어와 락', '락의 종류와 경합 상황에서의 자원 보호', 'common-server/unit03'),
       (73, 6, '분산 환경의 정합성', '여러 서버에 흩어진 데이터의 일관성 확보', 'common-server/unit04'),
       (74, 6, '캐시 전략', '캐시 적용 방식과 무효화 전략', 'common-server/unit05'),
       (75, 6, '비동기 메시징', '메시지 큐 기반의 느슨한 결합과 처리 보장', 'common-server/unit06'),
       (76, 6, '데이터베이스 확장', '복제, 샤딩, 파티셔닝을 통한 확장 방법', 'common-server/unit07'),
       (77, 6, 'HTTP와 REST API 설계', '자원 중심 인터페이스 설계 원칙과 규약', 'common-server/unit08'),
       (78, 6, '인증과 인가', '신원 확인과 권한 부여 방식', 'common-server/unit09'),
       (79, 6, '트래픽 처리와 자원 관리', '부하 분산과 커넥션, 스레드 자원 운용', 'common-server/unit10'),
       (80, 6, '배포와 무중단 전환', '서비스 중단 없이 새 버전으로 전환하는 전략', 'common-server/unit11'),
       (81, 6, '관측성', '로그, 메트릭, 추적으로 시스템 상태 파악', 'common-server/unit12');

-- Chapter 7: Common · Web
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (82, 7, '브라우저 렌더링 파이프라인', 'HTML이 화면에 그려지기까지의 처리 과정', 'common-web/unit01'),
       (83, 7, 'Reflow와 Repaint', '레이아웃 재계산과 다시 그리기의 발생 조건', 'common-web/unit02'),
       (84, 7, '이벤트 루프와 실행 순서', '태스크 큐 기반의 자바스크립트 실행 순서', 'common-web/unit03'),
       (85, 7, '리소스 로딩과 파서 차단', '스크립트와 스타일이 파싱에 미치는 영향', 'common-web/unit04'),
       (86, 7, '렌더링 전략', 'CSR, SSR, SSG 등 화면 생성 시점의 선택', 'common-web/unit05'),
       (87, 7, '브라우저 저장소와 세션 유지', '쿠키와 스토리지를 이용한 상태 보관', 'common-web/unit06'),
       (88, 7, '동일 출처 정책과 CORS', '출처 기반 접근 제한과 교차 출처 허용', 'common-web/unit07'),
       (89, 7, '웹 보안', 'XSS, CSRF 등 웹 취약점과 대응 방안', 'common-web/unit08'),
       (90, 7, 'HTTP 캐싱', '캐시 헤더와 재검증을 통한 응답 재사용', 'common-web/unit09'),
       (91, 7, '웹 성능 지표와 측정', 'Core Web Vitals와 성능 측정 방법', 'common-web/unit10');

-- Chapter 8: Common · AOS
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (92, 8, '4대 컴포넌트와 인텐트', '앱 구성 요소와 컴포넌트 간 호출 방식', 'common-aos/unit01'),
       (93, 8, '액티비티와 프래그먼트 생명주기', '화면 상태 전이와 콜백 호출 순서', 'common-aos/unit02'),
       (94, 8, '구성 변경과 상태 보존', '화면 회전 등 구성 변경 시 데이터 유지', 'common-aos/unit03'),
       (95, 8, '프로세스 수명과 메모리 압력', '시스템에 의한 앱 종료와 상태 복원', 'common-aos/unit04'),
       (96, 8, '메모리 누수 패턴', '참조가 남아 회수되지 않는 대표 사례', 'common-aos/unit05'),
       (97, 8, '백그라운드 작업', '화면 밖에서 실행되는 작업의 실행 보장', 'common-aos/unit06'),
       (98, 8, '데이터 저장소 선택', '저장 방식별 특성과 상황에 맞는 선택', 'common-aos/unit07'),
       (99, 8, '네트워크 계층', '통신 라이브러리 구성과 응답 처리 방식', 'common-aos/unit08'),
       (100, 8, '앱 아키텍처', '계층 분리와 관심사 분리를 위한 구조', 'common-aos/unit09'),
       (101, 8, '권한과 보안', '런타임 권한 요청과 민감 정보 보호', 'common-aos/unit10');

-- Chapter 9: Common · iOS
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (102, 9, '앱 생명주기와 상태 전이', '앱 실행 상태의 변화와 시스템 통지 시점', 'common-ios/unit01'),
       (103, 9, '뷰 컨트롤러 생명주기', '화면 표시 전후에 호출되는 콜백 순서', 'common-ios/unit02'),
       (104, 9, '메모리 압력과 백그라운드 종료', '메모리 부족 시 앱 종료와 대응 방법', 'common-ios/unit03'),
       (105, 9, '셀 재사용과 리스트 성능', '셀 재사용 구조와 스크롤 성능 관리', 'common-ios/unit04'),
       (106, 9, '데이터 영속화 선택', '저장 방식별 특성과 상황에 맞는 선택', 'common-ios/unit05'),
       (107, 9, '네트워크 계층', '통신 계층 구성과 응답 처리 방식', 'common-ios/unit06'),
       (108, 9, '샌드박스와 앱 간 공유', '파일 접근 제한과 앱 간 데이터 전달', 'common-ios/unit07'),
       (109, 9, '앱 아키텍처', '계층 분리와 관심사 분리를 위한 구조', 'common-ios/unit08'),
       (110, 9, '푸시 알림', '원격 알림의 전달 흐름과 수신 처리', 'common-ios/unit09'),
       (111, 9, '권한과 프라이버시', '사용자 동의 획득과 개인정보 보호 정책', 'common-ios/unit10');

-- Chapter 10: BE · Spring
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (112, 10, 'IoC/DI와 빈 생명주기', '컨테이너의 객체 관리와 생성, 소멸 과정', 'be-spring/unit01'),
       (113, 10, 'AOP와 프록시 동작', '공통 관심사 분리와 프록시 기반 위임', 'be-spring/unit02'),
       (114, 10, '요청 처리 흐름', '디스패처 서블릿부터 응답까지의 처리 경로', 'be-spring/unit03'),
       (115, 10, '요청 전후 처리 계층', '필터, 인터셉터, 아규먼트 리졸버의 역할', 'be-spring/unit04'),
       (116, 10, '트랜잭션 추상화', '선언적 트랜잭션의 전파 속성과 롤백 규칙', 'be-spring/unit05'),
       (117, 10, '영속성 컨텍스트', '엔티티 관리와 변경 감지, 쓰기 지연', 'be-spring/unit06'),
       (118, 10, '연관관계와 N+1', '지연 로딩과 조회 쿼리가 늘어나는 문제', 'be-spring/unit07'),
       (119, 10, 'JPA 쓰기와 식별자 전략', '저장 시점과 기본키 생성 전략의 차이', 'be-spring/unit08'),
       (120, 10, '예외 처리와 응답 규약', '전역 예외 처리와 일관된 응답 형식', 'be-spring/unit09'),
       (121, 10, '인증·인가 필터 체인', '시큐리티 필터의 순서와 인증 처리 흐름', 'be-spring/unit10'),
       (122, 10, '스레드와 커넥션 자원 관리', '스레드 풀과 커넥션 풀의 운용과 한계', 'be-spring/unit11');

-- Chapter 11: BE · Node.js
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (123, 11, '이벤트 루프와 논블로킹 I/O', '단일 스레드 기반의 비동기 처리 구조', 'be-nodejs/unit01'),
       (124, 11, '마이크로태스크와 매크로태스크', '큐 우선순위에 따른 콜백 실행 순서', 'be-nodejs/unit02'),
       (125, 11, 'CPU 바운드 작업 처리', '연산 부하로 인한 이벤트 루프 블로킹 해소', 'be-nodejs/unit03'),
       (126, 11, '모듈 시스템', 'CommonJS와 ESM의 차이와 모듈 로딩 방식', 'be-nodejs/unit04'),
       (127, 11, '스트림과 백프레셔', '청크 단위 처리와 처리 속도 조절', 'be-nodejs/unit05'),
       (128, 11, '모듈과 프로바이더 스코프', 'NestJS의 의존성 주입과 인스턴스 범위', 'be-nodejs/unit06'),
       (129, 11, '요청 처리 파이프라인', '가드, 인터셉터, 파이프의 실행 순서', 'be-nodejs/unit07'),
       (130, 11, '에러 핸들링과 프로세스 안정성', '예외 전파 처리와 프로세스 종료 방지', 'be-nodejs/unit08'),
       (131, 11, '메모리 누수 진단', '힙 스냅샷을 이용한 누수 원인 추적', 'be-nodejs/unit09');

-- Chapter 12: BE · Django
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (132, 12, '요청·응답 사이클과 미들웨어', '요청이 뷰에 닿기까지의 처리 순서', 'be-django/unit01'),
       (133, 12, 'QuerySet 지연 평가', '쿼리가 실제로 실행되는 시점과 판단 기준', 'be-django/unit02'),
       (134, 12, '조회 최적화와 N+1', 'select_related와 prefetch_related 활용', 'be-django/unit03'),
       (135, 12, '트랜잭션 관리', 'atomic 블록과 커밋, 롤백이 일어나는 시점', 'be-django/unit04'),
       (136, 12, '마이그레이션', '모델 변경을 스키마에 반영하는 절차', 'be-django/unit05'),
       (137, 12, '인증과 권한', '사용자 인증 체계와 접근 권한 제어', 'be-django/unit06'),
       (138, 12, 'DRF 직렬화와 검증', '시리얼라이저의 변환 과정과 입력 검증', 'be-django/unit07'),
       (139, 12, '시그널과 암묵적 결합', '신호 기반 처리의 부작용과 대안', 'be-django/unit08'),
       (140, 12, '동기와 비동기 혼용', 'ASGI 환경에서 둘을 함께 쓸 때의 주의점', 'be-django/unit09');

-- Chapter 13: FE · React
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (141, 13, '렌더링과 재조정', '리렌더 발생 조건과 변경 사항 비교 과정', 'fe-react/unit01'),
       (142, 13, '훅의 동작 원리', '호출 순서에 의존하는 훅의 내부 동작', 'fe-react/unit02'),
       (143, 13, '상태 설계', '상태의 위치와 최소 단위를 정하는 기준', 'fe-react/unit03'),
       (144, 13, '상태 관리 전략', '지역, 전역, 서버 상태의 분리와 도구 선택', 'fe-react/unit04'),
       (145, 13, 'useEffect의 정의와 오용', '외부 동기화 용도와 잘못된 사용 사례', 'fe-react/unit05'),
       (146, 13, '렌더링 최적화 판단', '메모이제이션이 실제로 필요한 시점', 'fe-react/unit06'),
       (147, 13, 'ref와 DOM 접근', '렌더링 밖의 값 보관과 DOM 직접 제어', 'fe-react/unit07'),
       (148, 13, '동시성 렌더링', '렌더링 우선순위 조정과 중단 가능한 렌더', 'fe-react/unit08'),
       (149, 13, '에러 경계와 예외 처리', '렌더 중 발생한 오류의 격리와 복구', 'fe-react/unit09'),
       (150, 13, '컴포넌트 설계', '재사용과 합성을 고려한 컴포넌트 분리', 'fe-react/unit10');

-- Chapter 14: FE · Vue.js
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (151, 14, '반응성 시스템 원리', '의존성 추적과 자동 갱신이 일어나는 구조', 'fe-vue/unit01'),
       (152, 14, 'ref와 reactive', '두 반응형 API의 차이와 선택 기준', 'fe-vue/unit02'),
       (153, 14, 'computed와 watch', '파생 값 계산과 변화 감지의 구분', 'fe-vue/unit03'),
       (154, 14, 'Composition API와 Options API', '두 작성 방식의 차이와 전환 기준', 'fe-vue/unit04'),
       (155, 14, '컴포넌트 통신', 'props, emit, provide로 데이터를 전달하는 방법', 'fe-vue/unit05'),
       (156, 14, '렌더링 제어', '조건부, 반복 렌더링과 key의 역할', 'fe-vue/unit06'),
       (157, 14, '생명주기와 DOM 접근 시점', '훅 호출 순서와 DOM 접근이 가능한 시점', 'fe-vue/unit07');

-- Chapter 15: FE · Next.js
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (158, 15, '렌더링 전략 선택', '페이지 특성에 맞는 렌더링 방식 결정', 'fe-nextjs/unit01'),
       (159, 15, '서버·클라이언트 컴포넌트 경계', '실행 위치 구분과 경계를 나누는 기준', 'fe-nextjs/unit02'),
       (160, 15, '데이터 페칭과 폭포수', '요청이 순차 실행되며 생기는 지연 해소', 'fe-nextjs/unit03'),
       (161, 15, '캐싱 레이어', '요청, 데이터, 라우트 단위의 캐시 구조', 'fe-nextjs/unit04'),
       (162, 15, '재검증 전략', '시간 기반과 태그 기반의 캐시 갱신', 'fe-nextjs/unit05'),
       (163, 15, '서버 액션', '서버에서 실행되는 폼 처리와 변경 작업', 'fe-nextjs/unit06'),
       (164, 15, '하이드레이션', '서버 렌더 결과에 이벤트를 연결하는 과정', 'fe-nextjs/unit07'),
       (165, 15, '라우팅·레이아웃과 미들웨어', '파일 기반 라우팅과 요청 전처리', 'fe-nextjs/unit08'),
       (166, 15, '자산과 번들 최적화', '이미지, 폰트와 번들 크기 최적화', 'fe-nextjs/unit09');

-- Chapter 16: Mobile · Android
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (167, 16, 'ViewModel과 상태 보존', '화면 상태 유지와 생명주기 대응 방식', 'mobile-android/unit01'),
       (168, 16, '선언형 UI와 Recomposition', '상태 변화에 따른 UI 재구성 과정', 'mobile-android/unit02'),
       (169, 16, 'Compose 상태 관리', '상태 호이스팅과 상태를 저장하는 방식', 'mobile-android/unit03'),
       (170, 16, 'Compose 안정성과 최적화', '불필요한 재구성을 줄이는 안정성 조건', 'mobile-android/unit04'),
       (171, 16, 'Compose 부수효과 API', '컴포지션 밖의 작업을 다루는 효과 API', 'mobile-android/unit05'),
       (172, 16, '생명주기 인식 데이터 수집', '화면 상태에 맞춘 데이터 구독 관리', 'mobile-android/unit06'),
       (173, 16, '의존성 주입', '객체 생성과 주입을 외부에 위임하는 구조', 'mobile-android/unit07'),
       (174, 16, 'Navigation과 화면 전환', '화면 이동과 인자 전달, 백스택 관리', 'mobile-android/unit08'),
       (175, 16, '리스트 성능', '지연 목록의 key 설정과 스크롤 성능', 'mobile-android/unit09'),
       (176, 16, '테스트 가능한 구조', '의존성 분리를 통한 검증 가능한 설계', 'mobile-android/unit10');

-- Chapter 17: Mobile · iOS
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (177, 17, 'SwiftUI 뷰 정체성과 업데이트', '뷰를 식별하는 방식과 갱신 판단 기준', 'mobile-ios/unit01'),
       (178, 17, '상태 프로퍼티 래퍼', 'State, Binding 등 상태의 소유와 전달', 'mobile-ios/unit02'),
       (179, 17, 'Observation 프레임워크', '관찰 기반 상태 추적과 갱신 범위 최소화', 'mobile-ios/unit03'),
       (180, 17, '뷰 모디파이어와 재사용 설계', '모디파이어 적용 순서와 스타일 공통화', 'mobile-ios/unit04'),
       (181, 17, 'UIKit과 SwiftUI 상호운용', '두 프레임워크를 함께 사용하는 방법', 'mobile-ios/unit05'),
       (182, 17, '레이아웃 시스템', '크기 제안과 배치가 결정되는 과정', 'mobile-ios/unit06'),
       (183, 17, '리스트 성능', '지연 스택과 목록 갱신 비용 관리', 'mobile-ios/unit07'),
       (184, 17, '화면 전환과 흐름 제어', '내비게이션 스택과 화면 흐름 관리', 'mobile-ios/unit08'),
       (185, 17, 'Combine과 데이터 바인딩', '퍼블리셔 기반의 비동기 데이터 흐름', 'mobile-ios/unit09');

-- Chapter 18: Language · Java
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (186, 18, 'JVM 메모리 구조', '힙, 스택 등 런타임 데이터 영역의 구성', 'lang-java/unit01'),
       (187, 18, '가비지 컬렉션', '객체 회수 방식과 GC 알고리즘의 차이', 'lang-java/unit02'),
       (188, 18, 'equals와 hashCode 계약', '두 메서드가 함께 지켜야 하는 규약', 'lang-java/unit03'),
       (189, 18, '컬렉션 내부 구조', 'List, Map, Set의 구현 방식과 성능 특성', 'lang-java/unit04'),
       (190, 18, '예외 체계와 설계', '검사와 비검사 예외의 구분과 처리 전략', 'lang-java/unit05'),
       (191, 18, '제네릭과 타입 소거', '컴파일 시점 타입 검사와 런타임 소거', 'lang-java/unit06'),
       (192, 18, '스트림과 함수형 인터페이스', '파이프라인 연산과 람다를 통한 표현', 'lang-java/unit07'),
       (193, 18, '동시성 기본', '스레드와 공유 자원, 메모리 가시성 문제', 'lang-java/unit08'),
       (194, 18, '고수준 동시성 API', '실행자와 동시성 유틸리티의 활용', 'lang-java/unit09'),
       (195, 18, '불변 객체와 값 설계', '변경 불가능한 객체의 설계 방법과 이점', 'lang-java/unit10');

-- Chapter 19: Language · Kotlin
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (196, 19, 'Null Safety 설계', '널 가능 타입의 구분과 안전한 처리 방법', 'lang-kotlin/unit01'),
       (197, 19, '코루틴 구조화된 동시성', '스코프를 기준으로 한 코루틴 수명 관리', 'lang-kotlin/unit02'),
       (198, 19, '코루틴 예외 처리', '취소 전파와 예외를 처리하는 방식', 'lang-kotlin/unit03'),
       (199, 19, 'Flow', '비동기 데이터 스트림의 생성과 수집', 'lang-kotlin/unit04'),
       (200, 19, '확장 함수와 스코프 함수', '기능 확장과 스코프 함수의 선택 기준', 'lang-kotlin/unit05'),
       (201, 19, 'data·sealed·object', '목적에 따른 클래스 선언 방식의 차이', 'lang-kotlin/unit06'),
       (202, 19, '위임과 프로퍼티', '위임 패턴과 프로퍼티 초기화 제어', 'lang-kotlin/unit07'),
       (203, 19, '가시성과 불변성', '접근 범위 제한과 val 기반의 설계', 'lang-kotlin/unit08'),
       (204, 19, '자바 상호운용', '자바 코드와 함께 사용할 때의 주의점', 'lang-kotlin/unit09');

-- Chapter 20: Language · TypeScript
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (205, 20, '구조적 타이핑', '형태를 기준으로 하는 타입 호환성 판단', 'lang-typescript/unit01'),
       (206, 20, '제네릭과 제약', '타입 매개변수와 extends를 통한 제한', 'lang-typescript/unit02'),
       (207, 20, '타입 좁히기', '조건 검사로 타입 범위를 좁히는 방법', 'lang-typescript/unit03'),
       (208, 20, 'any·unknown·never', '특수 타입의 의미와 사용 기준', 'lang-typescript/unit04'),
       (209, 20, '인터페이스와 타입 별칭', '두 선언 방식의 차이와 선택 기준', 'lang-typescript/unit05'),
       (210, 20, '유틸리티 타입과 매핑 타입', '기존 타입을 변형해 새 타입을 만드는 방법', 'lang-typescript/unit06'),
       (211, 20, '컴파일과 런타임 경계', '타입이 사라지는 시점과 검증의 필요성', 'lang-typescript/unit07');

-- Chapter 21: Language · Python
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (212, 21, 'GIL과 동시성 모델', '전역 인터프리터 락과 병렬 처리의 한계', 'lang-python/unit01'),
       (213, 21, '메모리 관리', '참조 카운팅과 순환 참조의 수거 방식', 'lang-python/unit02'),
       (214, 21, '가변·불변 객체와 함정', '변경 가능 여부에 따른 동작 차이', 'lang-python/unit03'),
       (215, 21, '이터레이터와 제너레이터', '반복 프로토콜과 지연 평가 방식', 'lang-python/unit04'),
       (216, 21, '데코레이터 동작 원리', '함수를 감싸 기능을 덧붙이는 구조', 'lang-python/unit05'),
       (217, 21, '클래스와 MRO', '상속 구조와 메서드를 탐색하는 순서', 'lang-python/unit06'),
       (218, 21, '타입 힌트', '타입 표기와 정적 검사 도구의 활용', 'lang-python/unit07'),
       (219, 21, '예외와 컨텍스트 매니저', '예외 처리와 자원 정리의 보장', 'lang-python/unit08');

-- Chapter 22: Language · Swift
INSERT INTO unit (id, chapter_id, title, description, note_path)
VALUES (220, 22, '값 타입 vs 참조 타입', '복사와 참조에 따른 동작 차이', 'lang-swift/unit01'),
       (221, 22, 'ARC와 순환 참조', '참조 카운팅 기반 메모리 관리와 누수', 'lang-swift/unit02'),
       (222, 22, '옵셔널 처리 전략', '값이 없을 수 있는 타입의 안전한 사용', 'lang-swift/unit03'),
       (223, 22, '프로토콜 지향 프로그래밍', '프로토콜과 확장을 중심으로 하는 설계', 'lang-swift/unit04'),
       (224, 22, '제네릭과 associatedtype', '타입 매개변수와 프로토콜의 연관 타입', 'lang-swift/unit05'),
       (225, 22, 'Swift Concurrency', 'async/await 기반의 비동기 처리', 'lang-swift/unit06'),
       (226, 22, 'actor와 데이터 격리', '액터를 통한 동시 접근 제어', 'lang-swift/unit07'),
       (227, 22, '에러 처리', 'throws와 do-catch를 통한 오류 전파', 'lang-swift/unit08');
