-- Unit: 모듈과 프로바이더 스코프 (Unit ID: 128)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NEST_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(636, 'NEST_JS', 128, 'HARD', true,
 'NestJS에서 DEFAULT 스코프로 선언한 서비스의 필드 캐시가 요청마다 초기화되는 현상이 발생했습니다. 가능한 원인과 해결 방법을, 요청 스코프를 사용할 때의 비용과 함께 설명해 주시겠어요?',
 '가장 유력한 원인은 스코프 버블링입니다. 스코프는 의존 그래프를 따라 위로 전파되기 때문에, DEFAULT로 선언한 서비스라도 REQUEST 스코프 프로바이더에 의존하면 요청마다 새로 만들어야 하므로 암묵적으로 REQUEST 스코프로 승격됩니다. 이 승격은 연쇄적이어서 그 서비스를 주입받는 컨트롤러까지 요청 스코프가 되고, 결과적으로 싱글톤이라 믿었던 서비스가 요청마다 재생성되어 필드 캐시가 매번 초기화됩니다. REQUEST 스코프는 요청 컨텍스트를 안전하게 담을 수 있지만 요청마다 DI 서브트리를 생성하므로 요청 하나에 생성되는 객체 수가 크게 늘어나는 성능 비용이 있습니다. 해결 방법은 요청 데이터를 별도의 REQUEST 프로바이더나 AsyncLocalStorage로 분리해, 캐시를 가진 서비스가 REQUEST 스코프에 의존하지 않도록 하는 것입니다. 요청 스코프가 꼭 필요하다면 durable: true와 ContextIdStrategy를 쓰는 Durable 프로바이더로 테넌트별로 하나 같은 중간 단위로 인스턴스를 재사용해 비용을 줄일 수 있습니다.'),
(637, 'NEST_JS', 128, 'NORMAL', true,
 'NestJS 프로바이더 스코프인 DEFAULT, REQUEST, TRANSIENT는 인스턴스가 생성되는 시점과 개수 측면에서 어떻게 다른가요?',
 'DEFAULT 스코프는 앱 부팅 시 한 번 생성되어 앱 전체에 1개만 존재하는 싱글톤입니다. 그래서 클래스 필드를 모든 요청이 공유하며, 상태를 갖지 않는 대부분의 서비스·리포지토리에 적합합니다. REQUEST 스코프는 HTTP 요청마다 인스턴스가 새로 생성되어 요청 수만큼 만들어지고 요청이 끝나면 GC됩니다. 사용자, 테넌트, 트레이스 ID 같은 요청 정보를 상태로 가져야 할 때 적합합니다. TRANSIENT 스코프는 주입받는 곳마다 새로 생성되어 소비자 수만큼 인스턴스가 생깁니다. 예를 들어 A와 B가 같은 TRANSIENT 프로바이더를 주입받으면 서로 다른 인스턴스를 받지만, 한 소비자 안에서는 같은 인스턴스가 유지됩니다. 로거 컨텍스트처럼 소비자별로 독립 상태가 필요한 유틸에 씁니다.'),
(638, 'NEST_JS', 128, 'NORMAL', true,
 'NestJS에서 두 서비스가 서로를 주입하는 순환 종속이 생겼을 때, forwardRef로 해결하는 방식과 구조를 고치는 방식은 어떻게 다르며 어느 쪽을 먼저 검토해야 하나요?',
 'A가 B를, B가 A를 주입하면 Nest는 부팅 시 한쪽 클래스가 아직 정의되지 않은 undefined 상태를 만나 의존성을 해석할 수 없다는 오류를 냅니다. forwardRef는 @Inject(forwardRef(() => OrdersService))처럼 나중에 평가할 참조를 넘겨 이 순환을 우회하는 방식이고, 모듈 간 순환이라면 양쪽 모듈의 imports를 모두 forwardRef로 감싸야 합니다. 하지만 forwardRef는 증상 완화일 뿐이므로 forwardRef보다 구조 개선을 먼저 검토해야 합니다. 순환은 대개 책임 분리가 잘못됐다는 신호이기 때문입니다. 구조적 해결책으로는 둘 다 필요로 하는 로직을 SharedModule 같은 제3의 모듈로 빼는 공통 모듈 추출, 한쪽이 직접 호출하는 대신 이벤트를 발행하고 상대가 구독하게 하는 이벤트 기반 역전, 반대 방향 호출을 컨트롤러 계층이나 파사드로 올리는 호출 방향 단일화가 있습니다. ModuleRef로 필요한 시점에 꺼내는 지연 조회도 가능하지만 의존이 숨겨지므로 최후 수단입니다. 또 배럴 파일로 재export하면 DI 순환이 없어도 파일 import 순환이 생겨 forwardRef를 써도 undefined 오류가 날 수 있으므로, 직접 경로로 import하는지도 확인해야 합니다.'),
(639, 'NEST_JS', 128, 'EASY', true,
 'NestJS의 @Module 데코레이터에서 imports, providers, exports는 각각 어떤 역할을 하나요?',
 'NestJS는 모듈 단위로 코드를 조직하고 DI 컨테이너가 프로바이더의 생명주기를 관리합니다. @Module의 providers에는 이 모듈이 소유하고 생성하는 프로바이더를 등록합니다. exports는 그중 다른 모듈에서 쓸 수 있게 공개할 프로바이더를 지정하고, imports는 다른 모듈이 export한 프로바이더를 가져와 이 모듈에서 주입받을 수 있게 합니다. 모듈은 캡슐화 단위이므로 exports하지 않은 프로바이더는 다른 모듈에서 주입할 수 없습니다. @Global() 모듈의 export는 어디서나 주입할 수 있지만, 남용하면 의존 관계가 불투명해지므로 설정이나 로거 정도에만 쓰는 것이 권장됩니다.'),
(640, 'NEST_JS', 128, 'EASY', true,
 'NestJS에서 같은 서비스 클래스를 두 모듈의 providers에 각각 등록하면 어떤 문제가 생기고, 어떻게 고쳐야 하나요?',
 'Nest의 싱글톤은 모듈당 개념이기 때문에, 같은 클래스를 여러 모듈의 providers에 등록하면 모듈마다 별도 인스턴스가 생성되어 인스턴스가 두 벌이 됩니다. 예를 들어 UsersModule과 OrdersModule이 각각 CacheService를 providers에 등록하면 캐시가 두 벌이 됩니다. 해결하려면 CacheModule 같은 소유 모듈 하나에서만 providers와 exports로 등록하고, 나머지 모듈은 그 모듈을 imports로 가져와야 합니다. Node.js의 모듈 캐시는 파일 단위 싱글톤이지만 Nest DI 컨테이너는 모듈 컨텍스트 단위 싱글톤이라, 클래스 정의가 하나여도 컨테이너가 두 컨텍스트에서 각각 new를 호출하면 인스턴스가 둘이 됩니다. 비슷하게 동적 모듈의 forRoot()를 여러 모듈에서 호출해도 호출마다 새 프로바이더가 생성되므로, 루트 모듈에서 한 번만 forRoot를 호출하고 나머지는 forFeature나 @Global을 사용합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 636
(3428, 636, 'REQUEST 스코프 프로바이더에 의존하면 해당 프로바이더도 암묵적으로 REQUEST 스코프로 승격됨을 설명', 'ESSENTIAL', 1),
(3429, 636, 'REQUEST 스코프는 요청마다 DI 서브트리를 생성해 성능 비용이 있음을 언급', 'ESSENTIAL', 2),
(3430, 636, '요청 데이터를 별도 REQUEST 프로바이더나 AsyncLocalStorage로 분리하는 해결책을 제시', 'ESSENTIAL', 3),
(3431, 636, '스코프 승격이 의존 그래프를 따라 컨트롤러까지 연쇄적으로 전파됨을 언급', 'SUPPLEMENTARY', 4),
(3432, 636, 'Durable 프로바이더로 ''테넌트별로 하나'' 같은 중간 단위로 인스턴스를 재사용해 비용을 줄임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 637
(3433, 637, 'DEFAULT는 앱 부팅 시 한 번 생성되어 앱 전체에 1개만 존재하는 싱글톤임을 설명', 'ESSENTIAL', 1),
(3434, 637, 'REQUEST는 HTTP 요청마다 인스턴스가 새로 생성됨을 설명', 'ESSENTIAL', 2),
(3435, 637, 'TRANSIENT는 주입받는 곳(소비자)마다 새 인스턴스가 생성됨을 설명', 'ESSENTIAL', 3),
(3436, 637, 'TRANSIENT라도 한 소비자 안에서는 같은 인스턴스가 유지됨을 언급', 'SUPPLEMENTARY', 4),
(3437, 637, '사용자·테넌트·트레이스 ID 같은 요청 정보를 상태로 가져야 할 때 REQUEST 스코프가 적합함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 638
(3438, 638, 'forwardRef가 나중에 평가할 참조를 넘겨 부팅 시 순환을 우회함을 설명', 'ESSENTIAL', 1),
(3439, 638, 'forwardRef보다 구조 개선을 먼저 검토해야 함을 언급', 'ESSENTIAL', 2),
(3440, 638, '공통 모듈 추출·이벤트 기반 역전·호출 방향 단일화 중 최소 1개를 구조적 해결책으로 제시', 'ESSENTIAL', 3),
(3441, 638, '순환 종속은 대개 책임 분리가 잘못됐다는 신호임을 언급', 'SUPPLEMENTARY', 4),
(3442, 638, '모듈 간 순환은 양쪽 모듈의 imports를 모두 forwardRef로 감싸야 함을 언급', 'SUPPLEMENTARY', 5),
(3443, 638, '배럴 파일 재export로 파일 import 순환이 생기면 forwardRef를 써도 undefined 오류가 날 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 639
(3444, 639, 'providers는 이 모듈이 소유하고 생성하는 프로바이더를 등록함을 설명', 'ESSENTIAL', 1),
(3445, 639, 'exports는 프로바이더를 다른 모듈에서 쓸 수 있게 공개함을 설명', 'ESSENTIAL', 2),
(3446, 639, 'imports는 다른 모듈이 export한 프로바이더를 가져옴을 설명', 'ESSENTIAL', 3),
(3447, 639, 'exports하지 않은 프로바이더는 다른 모듈에서 주입할 수 없다는 캡슐화를 언급', 'SUPPLEMENTARY', 4),
(3448, 639, '@Global() 모듈을 남용하면 의존 관계가 불투명해짐을 언급', 'SUPPLEMENTARY', 5),

-- 질문 640
(3449, 640, '모듈마다 별도 인스턴스가 생성되어 인스턴스가 두 벌이 됨을 설명', 'ESSENTIAL', 1),
(3450, 640, '한 모듈에서만 providers와 exports로 등록하고 나머지 모듈은 imports로 가져오는 해결책을 제시', 'ESSENTIAL', 2),
(3451, 640, 'Node.js 모듈 캐시(파일 단위)와 Nest DI 컨테이너(모듈 컨텍스트 단위)의 싱글톤 범위를 비교', 'SUPPLEMENTARY', 3),
(3452, 640, '동적 모듈 forRoot()를 여러 모듈에서 호출해도 프로바이더가 새로 생성됨을 언급', 'SUPPLEMENTARY', 4);
