-- Unit: 모듈과 프로바이더 스코프 (Unit ID: 128)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (554, 128, '프로바이더 exports와 스코프 전파'),
       (712, 128, '주입 토큰과 TRANSIENT 스코프'),
       (870, 128, '동적 모듈 공유와 순환 종속 해소');

-- =====================================================
-- Lesson 554: 프로바이더 exports와 스코프 전파
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3503, 554, '아래 모듈 구성으로 앱을 부팅했을 때의 동작으로 옳은 것은?', '```typescript
@Injectable()
export class CacheService {
  private store = new Map<string, string>();
  set(k: string, v: string) { this.store.set(k, v); }
  get(k: string) { return this.store.get(k); }
}

@Module({ providers: [CacheService], controllers: [UsersController] })
export class UsersModule {}

@Module({ providers: [CacheService], controllers: [OrdersController] })
export class OrdersModule {}
```

UsersController와 OrdersController는 각각 생성자에서 CacheService를 주입받는다.', 'OBJECTIVE'),
       (3504, 554, '아래 프로바이더 스코프 비교표를 바탕으로 옳지 않은 것은?', '| 스코프 | 인스턴스 생성 시점 | 살아 있는 인스턴스 수 |
| --- | --- | --- |
| DEFAULT | 앱 부팅 시 한 번 | 앱 전체에 1개 |
| REQUEST | HTTP 요청이 들어올 때마다 | 처리 중인 요청 수만큼 |
| TRANSIENT | 주입 지점마다 | 주입받은 소비자 수만큼 |', 'OBJECTIVE'),
       (3505, 554, '아래 의존 관계로 구성한 앱에서 나타나는 동작으로 옳은 것은?', '```typescript
@Injectable({ scope: Scope.REQUEST })
export class RequestContextService {
  constructor(@Inject(REQUEST) private readonly req: Request) {}
}

@Injectable()  // 스코프를 지정하지 않음
export class UsersService {
  constructor(private readonly ctx: RequestContextService) {}
}

@Controller()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}
}
```', 'OBJECTIVE'),
       (3506, 554, '아래 부팅 오류가 난 구성에 대한 설명으로 옳은 것은?', '```
[Nest] ERROR [ExceptionHandler] Nest can''t resolve dependencies of the UsersService (?).
Please make sure that the argument OrdersService at index [0] is available in the UsersModule context.
```

UsersService는 생성자에서 OrdersService를, OrdersService는 생성자에서 UsersService를 주입받는다. 두 서비스는 각각 UsersModule과 OrdersModule의 providers·exports에 등록돼 있고, 두 모듈은 서로를 imports한다.', 'OBJECTIVE'),
       (3507, 554, '아래 상황에서 UsersModule의 @Module 데코레이터에 새로 추가한 속성의 이름은?', 'OrdersModule은 imports에 UsersModule을 넣었고, UsersModule의 providers에는 UsersService가 들어 있다. 그런데 OrdersService 생성자에 UsersService를 넣자 부팅이 아래 메시지에서 멈췄다.

```
Nest can''t resolve dependencies of the OrdersService (?).
Please make sure that the argument UsersService at index [0] is available in the OrdersModule context.
```

UsersModule의 @Module 데코레이터에 배열 속성 하나를 추가하고 그 배열에 UsersService를 넣자, 나머지 코드는 그대로인데 부팅이 정상으로 끝났다.', 'SUBJECTIVE'),
       (3508, 554, '아래 등록에서 useValue 자리에 대신 써야 할 프로바이더 등록 키는?', '```typescript
// createPool은 접속을 열고 커넥션 풀을 돌려주는 async 함수다
@Module({
  providers: [
    { provide: ''DB'', useValue: createPool(process.env.DB_URL) },
  ],
})
export class DatabaseModule {}
```

이 모듈을 imports한 쪽에서 ''DB'' 토큰을 주입받아 pool.query(...)를 부르자 `pool.query is not a function` 오류가 났다. 주입된 값을 출력해 보니 커넥션 풀이 아니라 Promise 객체였다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3503
(9515, 3503, '클래스 정의가 하나뿐이므로 두 컨트롤러는 같은 인스턴스를 받아 캐시를 공유한다.', 'Node.js의 파일 단위 모듈 캐시와 혼동한 오개념. Nest의 싱글톤은 모듈 컨텍스트 단위라 클래스가 하나여도 컨테이너가 모듈마다 따로 인스턴스를 만든다.', false),
(9516, 3503, 'UsersController가 넣어 둔 값을 OrdersController에서 조회하면 찾지 못한다.', '두 모듈이 각자 providers에 등록해 컨테이너가 인스턴스를 둘 만든다. store 맵도 두 벌이라 한쪽에 쓴 값이 다른 쪽에서는 보이지 않는다.', true),
(9517, 3503, '같은 클래스가 두 번 등록됐으므로 부팅 중 중복 등록 오류가 나 앱이 뜨지 않는다.', '컨테이너가 중복을 막아 줄 것이라 본 오개념. providers 중복 등록은 오류가 아니라 정상 동작이며, 조용히 넘어가기 때문에 문제를 늦게 발견하게 된다.', false),
(9518, 3503, '나중에 등록된 OrdersModule의 CacheService가 앞의 등록을 덮어써 인스턴스가 하나만 남는다.', '전역 레지스트리 하나에 토큰이 덮어쓰기된다고 본 오개념. 등록 정보는 모듈 컨텍스트별로 따로 보관돼 서로 덮어쓰지 않는다.', false),

-- 문제 3504
(9519, 3504, 'DEFAULT로 둔 서비스의 필드에 방금 들어온 요청의 사용자 ID를 저장하면, 뒤이은 다른 요청이 그 값을 읽게 된다.', '인스턴스가 앱 전체에 1개라 필드를 모든 요청이 공유하므로 참이다. 요청별 데이터는 필드가 아니라 요청 스코프 객체에 담아야 사용자 간 혼선이 없다.', false),
(9520, 3504, '동시에 처리 중인 요청이 늘어날수록 REQUEST 프로바이더의 살아 있는 인스턴스 수도 함께 늘어난다.', '요청마다 생성되고 요청이 끝나야 회수되므로 동시 요청 수에 비례해 참이다. 요청 스코프의 성능 비용이 바로 여기서 나온다.', false),
(9521, 3504, '같은 TRANSIENT 프로바이더를 주입받은 두 서비스는 상대가 자기 인스턴스에 쌓아 둔 상태를 볼 수 없다.', '주입 지점마다 인스턴스가 따로 만들어져 소비자별로 상태가 격리되므로 참이다. 소비자별 컨텍스트를 담는 로거에 TRANSIENT를 쓰는 이유다.', false),
(9522, 3504, '생성자에서 TRANSIENT 프로바이더를 한 번 주입받은 서비스는 그 프로바이더의 메서드를 호출할 때마다 새 인스턴스를 받는다.', 'TRANSIENT의 단위는 호출이 아니라 주입 지점이다. 한 소비자 안에서는 처음 주입받은 인스턴스가 그대로 유지되므로 거짓이다.', true),

-- 문제 3505
(9523, 3505, 'UsersService는 스코프를 지정하지 않았으므로 부팅 때 한 번만 만들어지고, 주입된 ctx만 요청마다 갈아 끼워진다.', '선언한 스코프가 그대로 유지된다고 본 오개념. 요청마다 달라지는 의존을 가진 인스턴스를 하나로 유지할 수 없어 컨테이너는 소비자 쪽 스코프를 올린다.', false),
(9524, 3505, '스코프가 서로 다른 프로바이더를 주입했다는 이유로 부팅 중 오류가 나 앱이 뜨지 않는다.', '스코프 혼합을 금지 규칙으로 본 오개념. 컨테이너가 소비자 스코프를 올려 조용히 맞춰 주기 때문에 오류 대신 성능 비용으로만 뒤늦게 드러난다.', false),
(9525, 3505, '부팅 직후 app.get(UsersService)로 인스턴스를 꺼내면 실패하고, moduleRef.resolve에 컨텍스트 식별자를 넘겨야 얻을 수 있다.', 'UsersService가 요청 스코프로 올라가 요청 컨텍스트 없이는 어느 인스턴스인지 특정할 수 없다. 테스트 코드에서 자주 부딪히는 증상이다.', true),
(9526, 3505, '승격은 직접 의존한 UsersService에서 멈춰 UsersController는 앱 전체에 하나로 유지된다.', '승격이 한 단계에서 멈춘다고 본 오개념. 요청 스코프가 된 프로바이더를 주입받은 쪽도 같은 이유로 올라가 컨트롤러까지 요청마다 생성된다.', false),

-- 문제 3506
(9527, 3506, '두 서비스의 생성자 주입과 두 모듈의 imports를 모두 forwardRef로 감싸야 부팅이 끝난다.', 'forwardRef는 참조 평가를 뒤로 미루는 처리라 순환의 양쪽 모두에 걸어야 한다. 프로바이더끼리의 순환과 모듈끼리의 순환은 따로 풀어야 한다.', true),
(9528, 3506, '오류 메시지가 UsersService를 가리키므로 UsersService 생성자에만 forwardRef를 걸면 해결된다.', '메시지에 찍힌 쪽만 고치면 된다고 본 오개념. 먼저 걸린 지점이 보고됐을 뿐이라, 반대 방향 참조가 남으면 오류 대상만 OrdersService로 바뀐다.', false),
(9529, 3506, '두 모듈이 서로를 imports한 것이 원인이므로 한쪽 모듈의 imports를 지우면 부팅된다.', '모듈 순환만 끊으면 된다고 본 오개념. imports를 지우면 그 모듈 컨텍스트에서 상대 프로바이더를 찾지 못해 같은 메시지가 다시 뜬다.', false),
(9530, 3506, '생성자 순환은 서로의 메서드를 실제로 호출할 때만 문제가 되므로 호출하지 않으면 오류 없이 부팅된다.', '런타임 문제로 본 오개념. 생성자 주입은 부팅 시 의존 그래프를 만들며 해결되므로 이후 호출 여부와 관계없이 그 단계에서 실패한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1124, 3507, 'exports,export,exports 배열,exports 속성', '모듈은 캡슐화 단위라 providers에 등록한 것만으로는 모듈 밖에서 주입할 수 없고, exports 배열에 올려 공개해야 imports한 쪽이 주입받을 수 있다. imports는 남이 공개한 것을 가져오는 쪽, exports는 내 것을 내주는 쪽이라 방향이 반대이고, providers는 그 모듈이 소유·생성하는 목록일 뿐 공개 여부와는 무관하다. 어디서나 주입되게 하려고 @Global()을 붙이는 방법도 있지만 의존 관계가 불투명해져 설정·로거 정도에만 권한다.'),
       (1125, 3508, 'useFactory,use factory,팩토리,팩토리 프로바이더,factory,factory provider', 'useValue는 넘긴 값을 그대로 토큰에 묶으므로 async 함수가 돌려준 Promise가 그대로 주입돼 pool.query를 찾을 수 없다. useFactory로 등록하면 Nest가 부팅 중 팩토리를 호출하고 반환값이 Promise면 완료를 기다린 뒤 그 결과를 주입하므로, 커넥션 풀이 준비된 상태로 들어온다. inject 배열로 ConfigService 같은 다른 프로바이더를 팩토리 인자로 받을 수도 있다. 이미 있는 인스턴스를 다른 토큰으로 노출하는 useExisting, 클래스를 지정해 컨테이너가 생성하게 하는 useClass와 구분한다.');

-- =====================================================
-- Lesson 712: 주입 토큰과 TRANSIENT 스코프
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4451, 712, '아래 코드로 띄운 앱에 GET /visit 요청을 차례로 세 번 보냈을 때, 세 번째 응답 본문은?', '```typescript
@Injectable()
export class TotalService {
  private count = 0;
  inc() { return ++this.count; }
}

@Injectable({ scope: Scope.REQUEST })
export class VisitService {
  private count = 0;
  inc() { return ++this.count; }
}

@Controller(''visit'')
export class VisitController {
  constructor(
    private readonly total: TotalService,
    private readonly visit: VisitService,
  ) {}

  @Get()
  hit() {
    return `${this.total.inc()}-${this.visit.inc()}`;
  }
}
```

세 클래스는 같은 모듈에 등록돼 있고, 다른 곳에서는 TotalService와 VisitService를 쓰지 않는다.', 'OBJECTIVE'),
       (4452, 712, '아래 부팅 오류를 해결하는 수정으로 옳은 것은?', '```typescript
export interface UserRepository {
  findById(id: number): Promise<User | null>;
}

@Injectable()
export class TypeOrmUserRepository implements UserRepository { /* ... */ }

@Injectable()
export class UsersService {
  constructor(private readonly repo: UserRepository) {}
}

@Module({
  providers: [
    UsersService,
    { provide: ''USER_REPOSITORY'', useClass: TypeOrmUserRepository },
  ],
})
export class UsersModule {}
```

```
Nest can''t resolve dependencies of the UsersService (?).
Please make sure that the argument Object at index [0] is available in the UsersModule context.
```', 'OBJECTIVE'),
       (4453, 712, '아래 오류의 원인을 없애는 수정으로 옳은 것은?', 'UsersService와 OrdersService는 같은 CommerceModule의 providers에 함께 등록돼 있고, 생성자에서 서로를 주입받는다. 두 생성자 모두 상대 클래스를 forwardRef로 감쌌지만, 부팅할 때마다 UsersService의 0번 인자가 undefined라는 오류가 난다. 세 파일의 import 구성은 아래와 같다.

```typescript
// commerce/index.ts
export * from ''./users.service'';
export * from ''./orders.service'';

// commerce/users.service.ts
import { OrdersService } from ''./index'';

// commerce/orders.service.ts
import { UsersService } from ''./index'';
```', 'OBJECTIVE'),
       (4454, 712, '아래 코드를 실행했을 때 콘솔에 출력되는 내용은?', '```typescript
@Injectable()
export class SessionStore {
  private data = new Map<string, string>();
  set(k: string, v: string) { this.data.set(k, v); }
  get(k: string) { return this.data.get(k); }
}

@Module({
  providers: [
    SessionStore,
    { provide: ''STORE_A'', useExisting: SessionStore },
    { provide: ''STORE_B'', useClass: SessionStore },
  ],
})
export class SessionModule {}

// main.ts
const app = await NestFactory.createApplicationContext(SessionModule);
app.get(SessionStore).set(''user'', ''kim'');
console.log(app.get(''STORE_A'').get(''user''), app.get(''STORE_B'').get(''user''));
```', 'OBJECTIVE'),
       (4455, 712, '아래 코드의 ??? 자리에 넣은 값은?', 'UsersService와 OrdersService는 둘 다 생성자에서 AppLogger를 주입받고, 곧바로 각자 setContext(''Users'')와 setContext(''Orders'')를 호출한다.

```typescript
@Injectable({ scope: ??? })
export class AppLogger {
  private context = ''App'';
  constructor() { console.log(''AppLogger 생성''); }
  setContext(ctx: string) { this.context = ctx; }
  log(msg: string) { console.log(`[${this.context}] ${msg}`); }
}
```

- 처음에는 옵션 없이 `@Injectable()`로 두었더니, 두 서비스의 로그가 모두 `[Orders]`로 찍혔다.
- `???` 자리에 값을 넣고 다시 띄우자 로그가 `[Users]`와 `[Orders]`로 제대로 나뉘었다.
- 이때 `AppLogger 생성`은 부팅 중 2번 찍혔고, 이후 요청을 1만 건 보내는 동안 한 번도 더 찍히지 않았다.', 'SUBJECTIVE'),
       (4456, 712, '아래 상황의 3단계에서 storage를 만든 Node.js 내장 클래스의 이름은?', '주문 API의 모든 로그에 요청 헤더의 x-trace-id를 붙이려고 세 단계로 고쳤다.

1. DEFAULT 스코프인 TraceService의 필드에 미들웨어가 trace ID를 넣게 했다. 동시 요청이 몰리자 사용자 A의 요청 로그에 사용자 B의 trace ID가 찍혔다.
2. TraceService를 REQUEST 스코프로 바꾸자 섞임은 사라졌지만, p99 응답 시간이 40ms에서 95ms로 늘었고 프로파일러에서 요청마다 생성되는 객체 수가 크게 불어나 있었다.
3. TraceService를 DEFAULT로 되돌리고 아래처럼 바꾸자 섞임 없이 p99가 42ms로 돌아왔다.

```typescript
// 미들웨어
storage.run({ traceId: req.headers[''x-trace-id''] }, () => next());

// TraceService (DEFAULT)
get traceId() {
  return storage.getStore()?.traceId;
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4451
(12043, 4451, '3-3', '컨트롤러가 앱 전체에 1개로 남아 처음 받은 VisitService를 계속 쓴다고 본 오개념. REQUEST 프로바이더를 주입받은 컨트롤러는 요청마다 새로 만들어지므로 VisitService도 매번 새 인스턴스다.', false),
(12044, 4451, '1-1', '버블링이 의존 대상 쪽으로도 퍼져 TotalService까지 요청마다 새로 만든다고 본 오개념. 스코프는 주입받는 쪽(위)으로만 올라가므로 TotalService는 앱 전체에 1개로 남는다.', false),
(12045, 4451, '3-1', 'TotalService는 DEFAULT라 세 요청이 한 인스턴스를 공유해 3이 된다. 컨트롤러는 VisitService 때문에 REQUEST로 올라가 요청마다 새로 생기고, 그때마다 새 VisitService를 받아 항상 1이다.', true),
(12046, 4451, '1-3', '두 스코프의 수명을 맞바꿔 본 오개념. DEFAULT는 부팅 때 한 번 만들어져 계속 쓰이고, REQUEST는 요청마다 새로 만들어져 필드가 0부터 다시 시작한다.', false),

-- 문제 4452
(12047, 4452, 'UsersModule의 exports에 ''USER_REPOSITORY''를 추가해 UsersService가 그 토큰을 볼 수 있게 한다.', 'exports를 주입 가능 여부 전반의 스위치로 본 오개념. exports는 다른 모듈에 공개할 때 쓰며, 같은 모듈의 providers끼리는 없어도 주입된다. 오류는 토큰 자체를 Object로 찾아서 난 것이다.', false),
(12048, 4452, 'UsersService 생성자 파라미터 앞에 @Inject(''USER_REPOSITORY'')를 붙여 토큰을 직접 지정한다.', '인터페이스는 컴파일 후 사라져 파라미터 타입 메타데이터가 Object로 남는다. @Inject로 문자열 토큰을 직접 지정하면 useClass로 등록한 TypeOrmUserRepository가 주입된다.', true),
(12049, 4452, '생성자 파라미터를 @Inject(forwardRef(() => UserRepository))로 감싸 참조를 늦게 평가하게 한다.', '순환 종속 오류로 본 오개념. 여기엔 순환이 없고, UserRepository는 인터페이스라 런타임 값이 없어 forwardRef가 돌려줄 대상도 없다.', false),
(12050, 4452, 'provide 값을 문자열 대신 UserRepository로 바꿔 파라미터 타입과 토큰을 일치시킨다.', '인터페이스를 런타임 토큰으로 쓸 수 있다고 본 오개념. 인터페이스는 타입으로만 존재해 값 자리에 쓰면 컴파일 오류가 난다. 토큰은 클래스·문자열·Symbol만 된다.', false),

-- 문제 4453
(12051, 4453, 'UsersService 쪽 forwardRef를 지워 늦게 평가하는 참조를 한쪽에만 남긴다.', 'forwardRef가 양쪽에 걸려 서로 충돌한다고 본 오개념. 프로바이더끼리 순환이면 양쪽 모두 감싸야 하며, 한쪽을 지우면 DI 순환 오류까지 겹친다.', false),
(12052, 4453, 'CommerceModule에 @Global()을 붙여 두 서비스를 앱 어디서나 주입할 수 있게 한다.', '주입 가시성 문제로 본 오개념. 두 서비스는 이미 같은 모듈에 있어 서로 보인다. 클래스 참조 자체가 undefined인 것은 공개 범위와 관계가 없다.', false),
(12053, 4453, '두 서비스를 서로 다른 모듈로 나누고, 두 모듈의 imports를 forwardRef로 감싼다.', '모듈 배치 문제로 본 오개념. 모듈을 나눠도 두 파일이 index.ts를 거쳐 서로를 import하는 파일 순환은 그대로라 undefined 오류가 계속된다.', false),
(12054, 4453, '두 파일이 상대 클래스를 ''./index'' 대신 ''./orders.service''처럼 파일 경로로 직접 import하게 바꾼다.', 'index.ts를 거치면 두 파일이 서로를 import하는 파일 순환이 생겨, 한쪽을 읽는 시점에 상대 클래스가 아직 undefined다. DI 순환과 별개인 이 문제는 forwardRef로 풀리지 않아 직접 경로 import로 끊어야 한다.', true),

-- 문제 4454
(12055, 4454, 'kim undefined', 'useExisting은 이미 있는 SessionStore 인스턴스에 토큰 이름만 하나 더 붙여 STORE_A가 같은 객체를 가리킨다. useClass는 컨테이너가 인스턴스를 새로 만들어 STORE_B의 data는 비어 있다.', true),
(12056, 4454, 'kim kim', '같은 클래스면 한 모듈 안에서 인스턴스가 하나라고 본 오개념. 싱글톤은 클래스가 아니라 토큰 단위라 useClass로 등록한 STORE_B는 별도 인스턴스가 되어 값이 없다.', false),
(12057, 4454, 'undefined undefined', '토큰마다 무조건 새 인스턴스가 생긴다고 본 오개념. useExisting은 새로 만들지 않고 이미 등록된 SessionStore 인스턴스를 다른 토큰으로 가리킨다.', false),
(12058, 4454, 'undefined kim', 'useExisting과 useClass의 의미를 맞바꾼 오개념. 기존 인스턴스를 재사용하는 쪽은 useExisting이고, useClass는 지정한 클래스로 새 인스턴스를 만든다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1440, 4455, 'Scope.TRANSIENT,TRANSIENT,트랜지언트,트랜션트,TRANSIENT 스코프,트랜지언트 스코프', '생성 로그가 2번 찍혀 두 서비스가 각자 다른 AppLogger를 받았고, 요청이 1만 건 들어와도 더 생성되지 않았으므로 주입받는 소비자마다 인스턴스를 하나씩 만드는 TRANSIENT다. 옵션이 없던 DEFAULT는 앱 전체에 인스턴스가 1개라 나중에 호출된 setContext(''Orders'')가 앞의 값을 덮어써 두 서비스 로그가 모두 [Orders]로 찍혔다. REQUEST였다면 요청마다 새로 만들어져 요청 1만 건 동안 생성 로그가 계속 찍혔을 것이고, 이를 주입받은 두 서비스도 버블링으로 요청마다 다시 만들어진다. TRANSIENT라도 한 소비자 안에서는 처음 주입받은 인스턴스가 계속 유지된다는 점까지 함께 구분한다.'),
       (1441, 4456, 'AsyncLocalStorage,Async Local Storage,ALS,에이싱크 로컬 스토리지,어싱크 로컬 스토리지,비동기 로컬 스토리지,AsyncLocalStorage 클래스', 'AsyncLocalStorage는 run으로 연 저장소를 그 콜백에서 이어지는 비동기 호출 흐름 전체에서 getStore로 꺼내 쓰게 해 준다. 그래서 TraceService를 DEFAULT 싱글톤으로 두어도 요청마다 다른 값을 섞이지 않게 읽을 수 있다. 1단계는 인스턴스가 앱 전체에 1개라 필드를 모든 요청이 공유해 생긴 사고이고, 2단계의 REQUEST 스코프는 의존 그래프를 따라 주입받는 쪽까지 버블링돼 요청마다 객체를 만드는 성능 비용이 붙는다. 인스턴스 수는 늘리지 않고 요청 컨텍스트만 호출 흐름에 태운다는 점이 REQUEST 스코프와 갈리는 지점이다.');

-- =====================================================
-- Lesson 870: 동적 모듈 공유와 순환 종속 해소
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5399, 870, '아래 증상을 없애는 수정으로 옳은 것은?', 'RedisModule은 팀에서 만든 동적 모듈로, forRoot가 연결을 여는 RedisService를 providers와 exports에 담아 돌려준다. 두 기능 모듈이 이를 각자 불러온다.

```typescript
@Module({
  imports: [RedisModule.forRoot({ url: process.env.REDIS_URL })],
  providers: [UsersService],
})
export class UsersModule {}

@Module({
  imports: [RedisModule.forRoot({ url: process.env.REDIS_URL })],
  providers: [OrdersService],
})
export class OrdersModule {}
```

- 부팅 로그에 `Redis 연결 생성`이 두 번 찍혔다.
- Redis 서버에서 연결 목록을 보니 앱 프로세스 하나당 연결이 2개였다.
- UsersService와 OrdersService가 주입받은 RedisService를 `===`로 비교하니 false였다.', 'OBJECTIVE'),
       (5400, 870, '아래 두 서비스의 순환을 forwardRef 없이 끊는 구조 변경으로 옳은 것은?', 'UsersModule의 UsersService와 OrdersModule의 OrdersService는 생성자에서 서로를 주입받고, 두 모듈도 서로를 imports한다. 지금은 양쪽을 모두 forwardRef로 감싸 겨우 부팅된다. 두 서비스가 서로 부르는 메서드는 아래 둘뿐이다.

- 회원 탈퇴: `UsersService.withdraw()` 안에서 `OrdersService.cancelAllByUser(userId)`를 호출해 진행 중인 주문을 취소한다.
- 주문 생성: `OrdersService.create()` 안에서 `UsersService.getGrade(userId)`로 회원 등급을 조회해 할인율을 정한다. getGrade는 users 테이블만 읽고 다른 서비스를 부르지 않는다.', 'OBJECTIVE'),
       (5401, 870, '아래처럼 수정한 코드에 대한 설명으로 옳은 것은?', '두 서비스는 같은 CommerceModule의 providers에 함께 등록돼 있다. 원래는 두 생성자가 서로를 주입받아 부팅이 실패했는데, UsersService를 아래처럼 고쳤다.

```typescript
@Injectable()
export class UsersService implements OnModuleInit {
  private ordersService: OrdersService;

  constructor(private readonly moduleRef: ModuleRef) {}

  onModuleInit() {
    this.ordersService = this.moduleRef.get(OrdersService);
  }

  async withdraw(userId: number) {
    await this.ordersService.cancelAllByUser(userId);
  }
}

@Injectable()
export class OrdersService {
  constructor(private readonly usersService: UsersService) {}
}
```', 'OBJECTIVE'),
       (5402, 870, '아래 설계표대로 구현했을 때 잘못된 결과가 나오는 서비스는?', '주문 API 서버의 서비스별 스코프 설계표다. 서버는 동시에 수백 건의 요청을 처리한다.

| 서비스 | 하는 일 | 고른 스코프 |
| --- | --- | --- |
| TaxCalculator | 금액과 세율을 인자로 받아 세금을 계산해 돌려준다. 필드는 없다. | DEFAULT |
| TenantContext | 미들웨어가 넣어 준 이번 요청의 테넌트 ID를 보관한다. | REQUEST |
| RequestTimer | 요청이 들어오면 시작 시각을 필드에 적고, 응답 직전에 현재 시각에서 빼 처리 시간을 기록한다. | DEFAULT |
| ContextLogger | 주입받은 서비스마다 setContext로 서로 다른 이름표를 달고 로그를 찍는다. | TRANSIENT |', 'OBJECTIVE'),
       (5403, 870, '아래 코드의 ??? 자리에 넣은 옵션 이름은?', '테넌트가 3곳인 SaaS 서버에서 TenantConfigService는 테넌트별 설정을 DB에서 읽어 필드에 담아 둔다.

```typescript
@Injectable({ scope: Scope.REQUEST, ???: true })
export class TenantConfigService {
  constructor(@Inject(REQUEST) private readonly ctx: { tenantId: string }) {
    console.log(`TenantConfigService 생성: ${ctx.tenantId}`);
  }
}

// main.ts: x-tenant-id 헤더 값으로 요청을 묶고, 그 값을 tenantId로 넘기는 전략
ContextIdFactory.apply(new AggregateByTenantContextIdStrategy());
```

- `???` 옵션 없이 전략만 등록했을 때는 요청 3,000건 동안 생성 로그가 3,000번 찍혔다.
- `???: true`를 넣자 같은 3,000건 동안 생성 로그가 테넌트마다 한 번씩, 모두 3번만 찍혔다.
- 그 뒤에도 A 테넌트 요청에서 B 테넌트의 설정이 읽히는 일은 없었다.', 'SUBJECTIVE'),
       (5404, 870, '아래 상황에서 ConfigModule에 붙어 있던 데코레이터의 이름은?', '새로 합류한 개발자가 주문 모듈 코드를 읽다가 의아해했다. ConfigModule은 팀이 직접 만든 정적 모듈이다.

```typescript
@Module({
  providers: [OrdersService],
  controllers: [OrdersController],
})
export class OrdersModule {}

@Injectable()
export class OrdersService {
  constructor(private readonly config: ConfigService) {}
}
```

- OrdersModule의 imports에 ConfigModule이 없는데도 부팅과 주입이 정상이다.
- 다른 기능 모듈 20여 개도 ConfigModule을 imports하지 않은 채 ConfigService를 주입받는다.
- ConfigModule 파일을 열어 보니 `@Module({ providers: [ConfigService], exports: [ConfigService] })` 위에 데코레이터가 하나 더 붙어 있었다.
- 시험 삼아 AppModule의 imports에서 ConfigModule을 빼자, 모든 기능 모듈에서 ConfigService를 찾지 못한다는 오류가 났다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5399
(14571, 5399, 'RedisService 선언에 scope: Scope.DEFAULT를 명시해 앱 전체에 하나만 만들게 한다.', '스코프 문제로 본 오개념. 기본값이 이미 DEFAULT라 명시해도 달라지지 않는다. DEFAULT의 1개는 모듈 컨텍스트마다 1개라서, forRoot 호출로 RedisModule이 두 벌 생기면 RedisService도 벌마다 따로 만들어진다.', false),
(14572, 5399, 'forRoot는 루트 모듈에서 한 번만 호출하고, 기능 모듈은 forFeature 등으로 그 연결을 받아 쓴다.', 'forRoot는 호출할 때마다 새 모듈 인스턴스와 그 안의 프로바이더를 만들어, 두 번 부르면 RedisService와 연결도 두 벌이 된다. 루트 모듈에서 한 번만 만들고 기능 모듈은 그 결과를 받아 쓰게 하면 인스턴스가 하나로 모인다.', true),
(14573, 5399, '두 모듈의 imports 항목을 forwardRef로 감싸 같은 RedisModule을 가리키게 한다.', '순환 종속 문제로 본 오개념. forwardRef는 아직 정의되지 않은 참조를 나중에 평가하게 할 뿐이라, forRoot가 두 번 호출되는 사실은 그대로이고 RedisModule도 두 벌 생긴다.', false),
(14574, 5399, '두 모듈의 exports에 RedisService를 추가해 양쪽이 같은 인스턴스를 보게 한다.', 'exports를 인스턴스를 합쳐 주는 장치로 본 오개념. exports는 imports한 쪽에 공개할 목록일 뿐이고 두 모듈은 서로를 imports하지도 않는다. forRoot를 두 번 불러 생긴 두 벌은 그대로 남는다.', false),

-- 문제 5400
(14575, 5400, '두 서비스를 한 모듈의 providers로 합쳐, 모듈끼리 서로 imports하던 구조를 없앤다.', '모듈끼리의 순환만 문제라고 본 오개념. 한 모듈에 넣어도 두 생성자가 서로를 주입받는 프로바이더 간 순환은 그대로라, forwardRef를 빼면 같은 부팅 오류가 난다.', false),
(14576, 5400, '두 서비스를 Scope.REQUEST로 바꿔, 부팅 때가 아니라 요청이 들어올 때 만들어지게 한다.', '생성 시점을 늦추면 순환이 풀린다고 본 오개념. 순환은 의존 그래프 자체에 있어 요청 때 만들 때도 서로를 먼저 요구한다. 요청마다 DI 서브트리를 새로 만드는 비용만 더해진다.', false),
(14577, 5400, 'AppModule의 imports에서 OrdersModule을 UsersModule보다 앞에 둬 먼저 초기화되게 한다.', '초기화 순서로 순환을 풀 수 있다고 본 오개념. 어느 쪽을 먼저 만들든 그 생성자가 아직 없는 상대를 요구하므로 고리는 그대로이고, imports 순서와 관계없이 같은 오류가 난다.', false),
(14578, 5400, '등급 조회를 제3의 모듈로 빼고, OrdersService가 UsersService 대신 그 모듈을 의존하게 한다.', 'OrdersService가 UsersService에서 쓰던 것은 users 테이블만 읽는 등급 조회뿐이라, 이를 공통 모듈로 옮기면 Orders→Users 방향이 사라진다. Users→Orders 한 방향만 남아 고리가 없으니 forwardRef 없이 부팅된다.', true),

-- 문제 5401
(14579, 5401, '부팅은 되지만, UsersService 생성자만 봐서는 OrdersService가 필요하다는 사실이 드러나지 않는다.', '생성자 주입이 ModuleRef 하나로 줄어 부팅 때 서로를 요구하는 고리가 사라진다. 대신 OrdersService 의존이 메서드 안으로 숨어 생성자만 보고는 알 수 없고 테스트 구성 때도 놓치기 쉬워, 구조 개선이 어려울 때의 최후 수단으로 쓴다.', true),
(14580, 5401, 'OrdersService 생성자의 UsersService도 forwardRef로 감싸야 순환 오류 없이 부팅된다.', '생성자 순환이 남아 있다고 본 오개념. UsersService 생성자는 ModuleRef만 받으므로 의존은 OrdersService→UsersService 한 방향뿐이다. 고리가 없으니 forwardRef 없이도 부팅된다.', false),
(14581, 5401, 'withdraw를 호출할 때마다 moduleRef가 OrdersService 인스턴스를 새로 만들어 넘겨준다.', 'get을 인스턴스 생성으로 본 오개념. get은 컨테이너가 이미 만든 인스턴스를 찾아 돌려줄 뿐이고, 여기서는 onModuleInit에서 한 번 꺼내 필드에 담아 두므로 withdraw마다 새로 만들지 않는다.', false),
(14582, 5401, 'onModuleInit 시점에는 OrdersService가 아직 없어 ordersService 필드에 undefined가 담긴다.', '초기화 순서를 오해한 오개념. onModuleInit은 컨테이너가 프로바이더 인스턴스를 모두 만든 뒤에 호출되므로, 그 시점엔 OrdersService가 이미 있어 get으로 꺼낼 수 있다.', false),

-- 문제 5402
(14583, 5402, 'TaxCalculator', '싱글톤이면 동시 요청의 계산이 꼬인다고 본 오개념. 필드 없이 인자만으로 계산해 요청끼리 공유할 상태가 없으므로, 인스턴스 하나를 모두가 써도 결과가 맞다.', false),
(14584, 5402, 'TenantContext', '생성 비용이 드니 잘못된 선택이라 본 오개념. 테넌트 ID는 요청마다 다른 값이라 요청 단위로 따로 보관해야 섞이지 않으므로, 비용을 감수하고 REQUEST를 고른 것이 맞다.', false),
(14585, 5402, 'RequestTimer', 'DEFAULT는 앱 전체에 인스턴스가 1개라 필드도 모든 요청이 공유한다. 동시 요청이 몰리면 뒤에 온 요청이 시작 시각을 덮어써 앞 요청의 처리 시간이 틀리게 기록된다. 요청별 값은 REQUEST 스코프 객체나 AsyncLocalStorage에 담아야 한다.', true),
(14586, 5402, 'ContextLogger', 'TRANSIENT를 요청마다 새로 만드는 스코프로 본 오개념. TRANSIENT는 주입받는 소비자마다 인스턴스를 따로 만들어, 서비스별 이름표가 서로 덮어쓰이지 않으므로 맞는 선택이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1756, 5403, 'durable,durable: true,durable:true,durable 옵션,Durable 프로바이더,durable provider,듀러블,듀러블 옵션,듀러블 프로바이더', 'durable: true를 켠 REQUEST 스코프 프로바이더는 ContextIdStrategy가 묶어 준 단위(여기서는 x-tenant-id 헤더 값)마다 인스턴스를 하나 만들고, 같은 테넌트의 다음 요청에서는 그 인스턴스를 재사용한다. 그래서 3,000건 요청에도 생성 로그가 테넌트 수만큼 3번만 찍히고, 테넌트끼리는 인스턴스가 달라 설정이 섞이지 않는다. 전략을 등록했어도 durable을 켜지 않은 프로바이더는 여전히 요청마다 새로 만들어진다는 점(첫 번째 기록)을 구분한다. 일반 REQUEST 스코프(요청 단위)와 DEFAULT(앱 단위) 사이의 중간 단위로 인스턴스를 재사용해 REQUEST 스코프의 생성 비용을 줄이는 방법이라는 점이 핵심이다.'),
       (1757, 5404, '@Global(),@Global,Global(),Global,글로벌,@글로벌,Global 데코레이터,@Global 데코레이터,글로벌 데코레이터', '@Global()을 붙인 모듈을 루트 모듈에 한 번 등록하면, 그 모듈의 exports를 다른 모듈이 imports 없이도 주입받을 수 있다. 그래서 OrdersModule을 비롯한 20여 개 모듈이 ConfigModule을 가져오지 않고도 ConfigService를 받았고, AppModule에서 빼자 등록 자체가 사라져 모두 실패했다. 공개 대상은 여전히 exports로 정하며, @Global()은 공개 범위를 넓힐 뿐 exports를 대신하지 않는다. 기본 방식인 exports·imports 짝과 달리 의존 관계가 코드에 드러나지 않아 새 개발자처럼 출처를 찾기 어려워지므로, 설정·로거처럼 거의 모든 모듈이 쓰는 것에만 쓰도록 권한다.');
