-- Unit: 요청 처리 파이프라인 (Unit ID: 129)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (555, 129, '실행 순서와 가드·예외 필터 책임'),
       (713, 129, '필터 매칭과 APP_GUARD 전역 등록'),
       (871, 129, '파이프 체이닝과 구성요소 위치 선택');

-- =====================================================
-- Lesson 555: 실행 순서와 가드·예외 필터 책임
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3509, 555, '아래 기록에서 401 예외만 인터셉터에 남지 않은 원인으로 옳은 것은?', '모든 예외를 남기려고 전역 인터셉터를 아래와 같이 등록했다.

```typescript
intercept(ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
  return next.handle().pipe(
    catchError((err) => {
      this.logger.error(err.constructor.name);
      return throwError(() => err);
    }),
  );
}
```

하루치 운영 기록을 뽑아 보니 다음과 같았다.

| 예외를 던진 곳 | 클라이언트 응답 | 인터셉터 기록 |
| --- | --- | --- |
| 핸들러가 호출한 서비스 | 500 | 남음 |
| ValidationPipe의 DTO 검증 | 400 | 남음 |
| AuthGuard의 인증 확인 | 401 | 없음 |', 'OBJECTIVE'),
       (3510, 555, '아래 비교표에서 도출한 설명으로 옳지 않은 것은?', '| 구성요소 | 실행 시점 | 접근 가능한 정보 | 같은 종류가 여러 개일 때 적용 순서 |
| --- | --- | --- | --- |
| 미들웨어 | 라우트 매칭 전 | req, res | 등록 순서(전역 → 모듈) |
| 가드 | 미들웨어 다음 | ExecutionContext | 전역 → 컨트롤러 → 메서드 |
| 인터셉터 | 핸들러 앞과 뒤 | ExecutionContext, CallHandler | 앞: 전역 → 컨트롤러 → 메서드 / 뒤: 그 역순 |
| 파이프 | 인터셉터(앞) 다음, 핸들러 직전 | 파라미터 값과 타입 메타데이터 | 전역 → 컨트롤러 → 메서드 → 파라미터 |
| 예외 필터 | 예외가 던져졌을 때 | ArgumentsHost | 메서드 → 컨트롤러 → 전역(먼저 잡은 쪽에서 끝남) |', 'OBJECTIVE'),
       (3511, 555, '아래 코드에서 캐시가 적중한 GET /items/7 요청이 거치는 단계로 옳은 것은?', '```typescript
@Injectable()
export class CacheInterceptor implements NestInterceptor {
  constructor(private readonly store: Map<string, unknown>) {}

  intercept(ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    const url = ctx.switchToHttp().getRequest().url;
    const hit = this.store.get(url);
    if (hit) return of(hit);
    return next.handle().pipe(tap((v) => this.store.set(url, v)));
  }
}

@Controller(''items'')
export class ItemsController {
  @UseGuards(AuthGuard)
  @UseInterceptors(CacheInterceptor)
  @Get('':id'')
  findOne(@Param(''id'', ParseIntPipe) id: number) {
    return this.itemsService.findOne(id);
  }
}
```', 'OBJECTIVE'),
       (3512, 555, '아래 설정에서 주어진 요청 바디를 보냈을 때의 응답으로 옳은 것은?', '```typescript
// main.ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,
  forbidNonWhitelisted: true,
  transform: true,
}));

// create-user.dto.ts
export class CreateUserDto {
  @IsEmail() email: string;
  @Length(8, 64) password: string;
}

// users.controller.ts
@Post()
create(@Body() dto: CreateUserDto) {
  return this.usersService.create(dto);
}
```

요청 바디:

```json
{ "email": "gravit@example.com", "password": "sup3rsecret", "isAdmin": true }
```', 'OBJECTIVE'),
       (3513, 555, '아래 상황에서 응답 형태를 바꾼 NestJS 구성요소의 이름은?', '주문 조회 API에서 데이터베이스 라이브러리가 던진 EntityNotFoundError가 아무 데서도 잡히지 않고 그대로 올라와, 클라이언트에 500 응답과 내부 스택 메시지가 그대로 노출됐다.

컨트롤러와 서비스 코드는 한 줄도 고치지 않고 이 예외 타입을 지정한 클래스 하나를 만들어 전역에 등록하자, 같은 요청이 404와 { statusCode, path, message } 형태의 JSON으로 바뀌었다. 이 클래스는 ArgumentsHost로 응답 객체를 꺼내 상태 코드와 본문을 직접 써 넣는다.', 'SUBJECTIVE'),
       (3514, 555, '아래에서 로직을 옮겨 간 클래스의 메서드가 첫 번째 인자로 받는 객체의 타입 이름은?', '관리자 전용 삭제 API에 @Roles(''admin'')을 붙이고, 권한 판단은 미들웨어에서 처리하도록 짰다. Reflector로 역할 값을 읽어 사용자 권한과 비교할 생각이었지만, 읽어 온 값은 어떤 요청에서도 undefined였다. 결국 역할이 없는 계정의 삭제 요청까지 전부 통과해 리소스가 지워졌다.

판단 코드를 거의 그대로 CanActivate를 구현한 클래스로 옮기자, 이번에는 같은 Reflector 호출이 [''admin'']을 돌려줬고 역할 없는 계정은 403으로 막혔다. 옮긴 메서드가 받는 인자는 하나뿐이며, 로그인 사용자 정보가 담긴 요청 객체도 그 인자에서 꺼내 썼다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3509
(9531, 3509, '401을 만드는 예외는 HttpException 계열이 아니라서 catchError가 잡을 수 있는 대상에서 빠진다.', '인증 실패에 쓰는 UnauthorizedException도 HttpException을 상속한다. 예외의 타입이 아니라 예외가 던져진 시점이 기록 여부를 갈랐다.', false),
(9532, 3509, '인터셉터의 catchError는 4xx를 걸러내고 5xx만 기록하도록 동작한다.', '상태 코드로 거르는 동작은 없다. 표에서 같은 4xx인 400은 남았으므로 상태 코드가 기준이라는 설명과 정면으로 어긋난다.', false),
(9533, 3509, '가드가 인터셉터보다 먼저 실행돼, 가드가 던진 예외는 인터셉터 스트림을 거치지 않고 곧장 예외 필터로 간다.', '순서가 미들웨어 → 가드 → 인터셉터 → 파이프 → 핸들러라, next.handle()이 감싸는 범위는 파이프와 핸들러뿐이다. 가드 단계의 예외는 그 바깥에서 난다.', true),
(9534, 3509, '인증을 미들웨어에서 처리해 라우트 컨텍스트 밖에서 예외가 났기 때문이다.', '표는 예외를 던진 곳을 AuthGuard로 못박고 있다. 미들웨어와 가드를 뭉뚱그리면 ExecutionContext 접근 여부라는 결정적 차이도 함께 놓친다.', false),

-- 문제 3510
(9535, 3510, '응답 본문을 감싸는 변환은 전역 인터셉터의 것이 먼저 적용된 뒤 메서드 인터셉터의 것이 적용된다.', '표의 인터셉터 뒤 처리는 앞 처리의 역순이므로 메서드 → 컨트롤러 → 전역 차례로 응답이 가공된다. 적용 방향을 거꾸로 적은 거짓 진술이다.', true),
(9536, 3510, '같은 요청에서 DTO 검증에 드는 비용은 권한 판단을 통과한 뒤에만 발생한다.', '가드가 파이프보다 앞이라 거부된 요청은 파이프까지 오지 않는다. 거부할 요청의 바디를 파싱·검증하느라 CPU를 쓰지 않는 구조여서 참이다.', false),
(9537, 3510, '요청마다 추적용 ID를 헤더에 넣는 일은 미들웨어에 맡길 수 있지만, 핸들러에 붙은 역할 데코레이터 값을 읽어 판단하는 일은 맡길 수 없다.', '미들웨어는 req·res만 받고 라우트가 정해지기 전에 돌기 때문에 어떤 핸들러의 데코레이터인지 알 방법이 없다. 헤더 조작은 req만으로 되니 참이다.', false),
(9538, 3510, '메서드에 바인딩한 예외 필터가 예외를 처리하면 전역 필터에 넣어 둔 로깅 코드는 실행되지 않는다.', '필터는 메서드부터 적용되고 먼저 잡은 쪽에서 끝나므로 전역까지 예외가 내려가지 않는다. 전역 로깅을 믿고 있다가 놓치기 쉬운 참인 진술이다.', false),

-- 문제 3511
(9539, 3511, 'AuthGuard까지 건너뛴다. 인터셉터가 응답을 직접 만들어 돌려주므로 이 요청은 어떤 검사도 거치지 않는다.', '가드는 인터셉터보다 앞이라 캐시를 들여다보기 전에 이미 끝난다. 그래서 캐시 응답이라도 인증되지 않은 사용자에게는 나가지 않는다.', false),
(9540, 3511, 'ParseIntPipe는 파라미터 단위라 인터셉터보다 먼저 id를 변환하고, findOne 호출만 생략된다.', '파이프는 핸들러 인자를 만들기 직전에 돌아 인터셉터 앞부분보다 뒤다. 핸들러를 부르지 않으면 인자를 만들 일 자체가 없어 변환도 일어나지 않는다.', false),
(9541, 3511, 'findOne이 한 번 실행된 뒤 그 반환값이 저장된 캐시 값으로 교체돼 응답된다.', 'of(hit)는 next.handle() 대신 새 스트림을 만들어 반환한다. 핸들러 호출 자체가 일어나지 않으므로 교체할 반환값도 생기지 않는다.', false),
(9542, 3511, 'AuthGuard는 실행되지만, ParseIntPipe의 변환과 findOne 호출은 일어나지 않는다.', '가드 → 인터셉터(앞) → 파이프 → 핸들러 순서라, 인터셉터가 next.handle()을 부르지 않으면 그 뒤 단계가 통째로 생략된다. 가드는 이미 지나간 뒤다.', true),

-- 문제 3512
(9543, 3512, '201이 응답되고 dto에 isAdmin이 그대로 담긴 채 핸들러로 전달된다.', '검증 데코레이터가 붙은 속성만 본다는 오해다. whitelist가 켜져 있으면 DTO에 선언되지 않은 속성은 핸들러에 닿기 전에 걸러진다.', false),
(9544, 3512, '400이 응답되고 핸들러는 호출되지 않는다.', 'forbidNonWhitelisted는 DTO에 없는 속성을 조용히 지우는 대신 요청 자체를 거절한다. 파이프가 예외를 던지면 핸들러에 닿기 전에 응답이 끝난다.', true),
(9545, 3512, '201이 응답되고 isAdmin만 조용히 제거된 dto가 핸들러로 전달된다.', 'whitelist만 켠 경우의 동작이다. forbidNonWhitelisted까지 켜면 제거로 끝내지 않고 400으로 거절해 잘못된 요청을 드러낸다.', false),
(9546, 3512, '500이 응답된다. DTO 클래스에 없는 속성이라 transform 단계에서 변환에 실패한다.', 'transform은 평범한 객체를 DTO 인스턴스와 기본 타입으로 바꾸는 옵션이라 모르는 속성 때문에 터지지 않는다. 검증에서 걸린 요청은 400으로 나간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1126, 3513, '예외 필터,익셉션 필터,Exception Filter,exception filter,ExceptionFilter,필터,filter', '던져진 예외를 가로채 HTTP 응답으로 바꾸는 자리가 예외 필터다. 기본 내장 필터는 HttpException 계열이 아닌 예외를 모두 500으로 처리하기 때문에 등록 전에는 스택이 그대로 나갔고, 잡을 예외 타입을 지정한 필터를 두자 그 예외만 404 응답으로 바뀌었다. 인터셉터의 catchError와 헷갈리기 쉬운데, 인터셉터는 자신보다 뒤에 있는 파이프·핸들러의 예외만 스트림으로 받고 앞에서 실행되는 가드의 예외는 보지 못한다. 필터는 단계와 상관없이 마지막에 예외를 받아낸다. 적용 범위는 메서드 → 컨트롤러 → 전역 순으로 구체적인 것이 먼저 잡는다.'),
       (1127, 3514, 'ExecutionContext,execution context,Execution Context,실행 컨텍스트,실행컨텍스트,익스큐션 컨텍스트', '미들웨어는 라우트 매칭 전에 실행돼 어떤 핸들러가 이 요청을 처리할지 모른다. 참조할 대상이 없으니 Reflector가 읽어 올 메타데이터도 없어 undefined가 나왔다. 가드·인터셉터·파이프가 받는 ExecutionContext는 실행될 핸들러와 클래스를 getHandler()·getClass()로 알려주므로, 데코레이터에 심어 둔 역할 정보를 읽는 선언적 인가가 가능해진다. 예외 필터가 받는 ArgumentsHost와 구분해야 한다. ArgumentsHost는 프로토콜별 인자(switchToHttp 등)만 제공하고, ExecutionContext는 거기에 핸들러·클래스 정보를 더한 확장 타입이다.');

-- =====================================================
-- Lesson 713: 필터 매칭과 APP_GUARD 전역 등록
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4457, 713, '아래 코드에 요청 A·B·C를 보냈을 때 각 요청이 받는 응답 상태 코드를 순서대로 나열한 것은?', '토큰이 유효할 때만 `req.user`를 채우는 미들웨어가 모든 라우트에 적용돼 있다. 토큰이 없으면 `req.user` 없이 다음 단계로 넘어간다. `postsService.remove()`는 항상 정상 완료된다고 가정한다.

```typescript
export const Roles = (...roles: string[]) => SetMetadata(''roles'', roles);

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<string[]>(''roles'', [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    if (!required) return true;
    const { user } = ctx.switchToHttp().getRequest();
    if (!user) throw new UnauthorizedException();
    return required.some((r) => user.roles.includes(r));
  }
}

@Roles(''member'')
@UseGuards(RolesGuard)
@Controller(''posts'')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Roles(''admin'')
  @Delete('':id'')
  remove(@Param(''id'') id: string) {
    return this.postsService.remove(id);
  }
}
```

| 요청 | 토큰 | req.user.roles |
| --- | --- | --- |
| A: DELETE /posts/3 | 없음 | (req.user 없음) |
| B: DELETE /posts/3 | 유효 | [''member''] |
| C: DELETE /posts/3 | 유효 | [''admin''] |', 'OBJECTIVE'),
       (4458, 713, '아래 코드에서 ①~③의 예외를 각각 처리하는 예외 필터를 순서대로 짝지은 것은?', '```typescript
// all-exceptions.filter.ts
@Catch() // 인자를 비우면 모든 예외
export class AllExceptionsFilter implements ExceptionFilter { /* 생략 */ }

// http-error.filter.ts
@Catch(HttpException)
export class HttpErrorFilter implements ExceptionFilter { /* 생략 */ }

// entity-not-found.filter.ts
@Catch(EntityNotFoundError)
export class EntityNotFoundFilter implements ExceptionFilter { /* 생략 */ }

// main.ts
app.useGlobalFilters(new AllExceptionsFilter());

// orders.controller.ts
@UseFilters(EntityNotFoundFilter)
@Controller(''orders'')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @UseFilters(HttpErrorFilter)
  @Get('':id'')
  findOne(@Param(''id'') id: string) {
    return this.ordersService.findOne(id);
  }
}
```

`findOne` 실행 중 다음 세 경우가 각각 따로 발생한다.

- ① 서비스가 `NotFoundException`을 던진다. (`HttpException`을 상속한다)
- ② ORM이 `EntityNotFoundError`를 던진다. (`HttpException`을 상속하지 않는다)
- ③ 코드 버그로 `TypeError`가 발생한다.', 'OBJECTIVE'),
       (4459, 713, '아래 설명에 해당하는 요청 처리 구성요소에 대한 설명으로 옳은 것은?', 'NestJS에서 요청이 들어오면 가장 먼저 실행되는 단계로, `helmet`·압축 같은 Express 생태계 플러그인을 그대로 끼워 쓸 수 있다. 이 단계가 실행되는 시점에는 아직 라우트 매칭이 이뤄지지 않아, 요청을 어느 컨트롤러 메서드가 처리할지 정해지지 않았다.', 'OBJECTIVE'),
       (4460, 713, '아래 코드와 로그에서 형식이 틀린 값이 걸러지지 않고 핸들러까지 들어온 원인으로 옳은 것은?', '```typescript
// main.ts
app.useGlobalPipes(new ValidationPipe({ whitelist: true }));

// create-user.dto.ts — 검증 규칙을 붙인 클래스
export class CreateUserDto {
  @IsEmail() email: string;
  @Length(8, 64) password: string;
}

// user-input.ts — 프런트엔드와 함께 쓰려고 따로 선언한 타입
export interface UserInput {
  email: string;
  password: string;
}

// users.controller.ts
@Post()
create(@Body() dto: UserInput) {
  console.log(dto);
  return this.usersService.create(dto);
}
```

아래 바디로 요청을 보내자 201이 응답됐다.

```json
{ "email": "not-an-email", "password": "1", "role": "admin" }
```

이때 콘솔에 찍힌 내용은 다음과 같다.

```
{ email: ''not-an-email'', password: ''1'', role: ''admin'' }
```', 'OBJECTIVE'),
       (4461, 713, '아래 로그에서 (A)로 가린 클래스가 속한 NestJS 구성요소의 종류는?', '주문 생성 요청 한 건을 처리하는 동안, 요청 처리에 관여한 클래스가 실행될 때마다 이름과 시각을 남기도록 했다. 그중 한 클래스의 이름만 (A)로 가렸다.

```
12:00:00.000  RequestIdMiddleware      요청 ID 부여
12:00:00.002  AuthGuard                통과
12:00:00.003  (A)                      진입
12:00:00.004  ValidationPipe           CreateOrderDto 검증 통과
12:00:00.180  OrdersController.create  { orderId: 42 } 반환
12:00:00.181  (A)                      받은 값 { orderId: 42 }, 178ms
```', 'SUBJECTIVE'),
       (4462, 713, '아래 상황에서 AppModule 코드의 (가)에 들어갈 토큰 이름은?', '전역 인증 가드 `AuthGuard`는 토큰을 검증하려고 생성자에서 `JwtService`와 `UsersService`를 받는다. 처음에는 `main.ts`에서 아래처럼 등록했다.

```typescript
// main.ts
const jwtService = new JwtService({ secret: ''local-secret'' });
const usersService = new UsersService(app.get(DataSource).getRepository(User));
app.useGlobalGuards(new AuthGuard(jwtService, usersService));
```

운영 배포 뒤 정상 발급된 토큰으로 보낸 요청이 모두 401로 거절됐다. 운영 비밀 키는 `ConfigModule`이 읽어 `JwtModule` 설정으로 넘기는데, 위 코드는 그 설정을 거치지 않고 코드에 적힌 키로 `JwtService`를 만들었기 때문이다.

`main.ts`의 세 줄을 지우고 `AppModule`을 아래처럼 고치자, 생성자 인자를 직접 만드는 코드가 사라졌고 정상 토큰 요청의 401 비율은 100%에서 0%로 떨어졌다. 컨트롤러에는 `@UseGuards()`를 하나도 추가하지 않았는데도, 토큰 없는 요청은 이전처럼 모든 라우트에서 401로 막혔다.

```typescript
// app.module.ts
@Module({
  imports: [ConfigModule.forRoot(), JwtModule.registerAsync({ /* 설정 생략 */ }), UsersModule],
  providers: [{ provide: /* (가) */, useClass: AuthGuard }],
})
export class AppModule {}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4457
(12059, 4457, '403 / 403 / 200', 'user가 없을 때도 false가 반환된다고 본 오해다. 코드는 이때 UnauthorizedException을 직접 던지므로 A는 401이다. false 반환을 Nest가 ForbiddenException(403)으로 바꾸는 경우는 B뿐이다.', false),
(12060, 4457, '401 / 200 / 200', '클래스와 메서드의 역할이 합쳐져 member도 허용된다고 본 오해다. getAllAndOverride는 [핸들러, 클래스] 순으로 찾다가 처음 나온 값만 쓰므로, 이 라우트에 필요한 역할은 admin 하나다.', false),
(12061, 4457, '401 / 403 / 200', 'A는 user가 없어 UnauthorizedException(401)이 던져진다. B는 메서드의 admin이 클래스의 member를 덮어써 false가 반환되고 ForbiddenException(403)이 된다. C만 통과해 DELETE의 기본 상태 코드 200으로 응답한다.', true),
(12062, 4457, '401 / 200 / 403', '클래스에 붙인 값이 메서드 값보다 우선한다고 본 오해다. 조회 배열의 첫 요소가 ctx.getHandler()라 메서드의 admin이 채택되고, 클래스의 member는 메서드에 값이 없을 때만 쓰인다.', false),

-- 문제 4458
(12063, 4458, 'HttpErrorFilter / EntityNotFoundFilter / AllExceptionsFilter', '예외 필터는 메서드 → 컨트롤러 → 전역 순으로 살피다가 @Catch 타입이 맞는 첫 필터에서 멈춘다. ①은 메서드 필터에 맞고, ②는 메서드 필터를 지나 컨트롤러 필터에, ③은 둘 다 지나 전역 필터에 잡힌다.', true),
(12064, 4458, 'HttpErrorFilter / HttpErrorFilter / HttpErrorFilter', '가장 구체적인 메서드 필터가 타입과 상관없이 모든 예외를 받는다고 본 오해다. @Catch(HttpException)은 HttpException 계열만 받으므로 ②·③은 이 필터를 지나쳐 다음 범위로 넘어간다.', false),
(12065, 4458, 'AllExceptionsFilter / AllExceptionsFilter / AllExceptionsFilter', '가드·파이프처럼 전역부터 적용된다고 보고, 모든 예외를 받는 전역 필터가 먼저 가로챈다고 본 오해다. 예외 필터는 순서가 반대라 메서드·컨트롤러 필터가 먼저 기회를 얻는다.', false),
(12066, 4458, 'HttpErrorFilter / 기본 내장 필터 / 기본 내장 필터', '메서드에 필터가 있으면 그 필터만 살핀다고 본 오해다. 타입이 맞지 않으면 컨트롤러·전역 필터로 계속 넘어가고, 어느 필터와도 맞지 않을 때에만 기본 내장 필터가 처리한다.', false),

-- 문제 4459
(12067, 4459, '핸들러에 붙은 @Roles() 값을 읽어, 역할이 맞지 않는 요청을 403으로 막을 수 있다.', '가드의 특징이다. 이 단계는 라우트가 정해지기 전에 실행돼 어떤 핸들러의 데코레이터를 읽어야 할지 알 수 없다. 데코레이터 메타데이터 기반 인가는 ExecutionContext를 받는 가드가 맡는다.', false),
(12068, 4459, '여기서 던진 예외는 인터셉터의 catchError를 먼저 거친 뒤 예외 필터에 도달한다.', '파이프나 핸들러에서 난 예외의 경로다. 이 단계는 가드·인터셉터보다 먼저 실행되므로, 여기서 던진 예외가 아직 시작되지도 않은 인터셉터 스트림을 지날 수 없다.', false),
(12069, 4459, '핸들러가 반환한 값을 받아 { success: true, data } 형태로 감싸서 내보낼 수 있다.', '인터셉터의 특징이다. 이 단계는 req·res만 받아 핸들러 결과에 접근할 수 없으므로 응답 변환에 맞지 않는다. 핸들러 전후 모두에 개입하는 인터셉터가 map으로 응답을 가공한다.', false),
(12070, 4459, '응답을 보내지도 next()를 호출하지도 않고 끝나면, 다음 단계로 넘어가지 않아 요청이 멈춘다.', '이 단계는 미들웨어로, Express와 같은 (req, res, next) 시그니처를 쓴다. 직접 응답하지 않는 한 next()를 불러야 가드 이후 단계로 넘어가며, 빠뜨리면 에러 없이 클라이언트가 타임아웃까지 기다린다.', true),

-- 문제 4460
(12071, 4460, 'forbidNonWhitelisted를 함께 켜지 않으면, 검증 규칙을 어긴 값이 와도 요청을 거절하지 않는다.', 'forbidNonWhitelisted는 DTO에 없는 속성이 왔을 때 제거 대신 400으로 거절할지만 정한다. 규칙이 실제로 적용됐다면 whitelist만 켠 상태에서도 이메일 형식 위반으로 400이 나고 role은 제거됐다.', false),
(12072, 4460, '파라미터 타입이 인터페이스라 런타임에 남는 클래스 정보가 없어, 파이프가 적용할 규칙을 찾지 못했다.', 'ValidationPipe는 파라미터의 타입 메타데이터가 가리키는 클래스에서 규칙을 찾는다. 인터페이스는 컴파일 후 사라져 Object만 남으므로 검증도 whitelist 제거도 건너뛰었고, 그래서 role까지 그대로 들어왔다.', true),
(12073, 4460, 'transform: true를 주지 않으면 바디가 평범한 객체로 남아, 검증 단계 자체가 실행되지 않는다.', 'transform은 검증을 마친 값을 DTO 인스턴스로 바꿔 핸들러에 넘길지 정하는 옵션이다. 검증은 이 옵션과 상관없이 파이프 내부에서 클래스 인스턴스로 바꿔 수행된다.', false),
(12074, 4460, '전역으로 등록한 파이프는 @Body()로 받는 값에는 적용되지 않아, 파라미터마다 따로 붙여야 한다.', 'useGlobalPipes로 등록한 파이프는 모든 핸들러의 @Body()·@Param() 같은 파라미터에 적용된다. 실행 순서가 전역 → 컨트롤러 → 메서드 → 파라미터일 뿐, 전역 파이프가 빠지는 내장 데코레이터는 없다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1442, 4461, '인터셉터,Interceptor,interceptor,NestInterceptor', '로그의 위치가 답을 정한다. (A)의 첫 기록은 AuthGuard 뒤·ValidationPipe 앞에 있고, 두 번째 기록은 핸들러가 값을 반환한 직후 그 반환값을 받아 소요 시간과 함께 남겼다. 가드 다음에 실행되면서 핸들러의 반환값까지 받을 수 있는 구성요소는 인터셉터뿐이다. intercept()에서 next.handle()을 부르기 전에 진입을 기록하고, next.handle()이 돌려준 스트림에 연산자를 붙여 반환값과 경과 시간을 남긴 구조다. 미들웨어는 가드보다 먼저 실행되고 핸들러 반환값에 접근하지 못한다. 파이프는 핸들러 인자를 만들기 전까지만 관여하고, 예외 필터는 예외가 났을 때만 호출되므로 정상 요청 로그에 찍히지 않는다.'),
       (1443, 4462, 'APP_GUARD,APP GUARD,APPGUARD', 'AuthGuard는 CanActivate를 구현한 가드이므로 전역 가드용 토큰 APP_GUARD로 등록한다. app.useGlobalGuards()는 모듈 바깥에서 만든 인스턴스를 그대로 받기 때문에 의존성 주입(DI) 컨테이너를 거치지 않는다. 그래서 생성자 의존성을 손으로 조립해야 했고, 설정 모듈이 준비한 JwtService 대신 코드에 적힌 키를 쓴 인스턴스가 들어가 정상 토큰까지 거절됐다. providers에 { provide: APP_GUARD, useClass: AuthGuard }로 등록하면 Nest가 인스턴스를 만들며 의존성을 주입하고, 어느 모듈에 적든 모든 라우트에 전역으로 적용된다. 구성요소마다 토큰이 달라 인터셉터는 APP_INTERCEPTOR, 파이프는 APP_PIPE, 예외 필터는 APP_FILTER를 쓰므로 등록하려는 클래스의 종류에 맞춰 골라야 한다.');

-- =====================================================
-- Lesson 871: 파이프 체이닝과 구성요소 위치 선택
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5405, 871, '아래 코드에서 GET /users 요청에 대한 최종 응답 본문으로 옳은 것은?', '```typescript
// main.ts
app.useGlobalInterceptors(new WrapInterceptor());

// wrap.interceptor.ts
@Injectable()
export class WrapInterceptor implements NestInterceptor {
  intercept(ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(map((data) => ({ success: true, data })));
  }
}

// list.interceptor.ts
@Injectable()
export class ListInterceptor implements NestInterceptor {
  intercept(ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(map((data) => ({ items: data })));
  }
}

// users.controller.ts
@Controller(''users'')
export class UsersController {
  @UseInterceptors(ListInterceptor)
  @Get()
  findAll() {
    return [''kim'', ''lee''];
  }
}
```', 'OBJECTIVE'),
       (5406, 871, '아래 예외 필터를 전역에 등록했을 때, 요청 A~D 중 에러 로그가 남는 것을 모두 고른 것은?', '```typescript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse<Response>();
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    if (status >= 500) this.logger.error(exception);
    res.status(status).json({ statusCode: status });
  }
}

// app.module.ts
// providers: [{ provide: APP_FILTER, useClass: AllExceptionsFilter }]
```

A~D는 각각 따로 발생한다.

- A: `GET /orders/abc` 요청을 보냈다. 핸들러 인자는 `@Param(''id'', ParseIntPipe) id: number`이다.
- B: 전역 가드의 `canActivate()`가 `false`를 반환했다.
- C: 서비스 코드가 `undefined`의 속성을 읽다가 `TypeError`가 발생했다.
- D: 결제 대행사가 응답하지 않자 서비스가 `throw new HttpException(''결제 대행사 응답 없음'', 502)`를 실행했다.', 'OBJECTIVE'),
       (5407, 871, '아래 코드에 쿼리 문자열 없이 GET /posts/a와 GET /posts/b를 보냈을 때 각 요청의 응답으로 옳은 것은?', '```typescript
// DefaultValuePipe(1): 받은 값이 undefined·null이면 1을, 아니면 받은 값을 그대로 돌려준다.
// ParseIntPipe: 정수 형태가 아닌 값(undefined 포함)을 받으면 BadRequestException(400)을 던진다.

@Controller(''posts'')
export class PostsController {
  @Get(''a'')
  listA(@Query(''page'', new DefaultValuePipe(1), ParseIntPipe) page: number) {
    return { page };
  }

  @Get(''b'')
  listB(@Query(''page'', ParseIntPipe, new DefaultValuePipe(1)) page: number) {
    return { page };
  }
}
```', 'OBJECTIVE'),
       (5408, 871, '아래 요구사항 ①~③을 구현하기에 적합한 위치를 순서대로 짝지은 것은?', '새 API 서버에 다음 세 가지 기능을 넣으려 한다.

① `@Public()`(SetMetadata로 만든 데코레이터)이 붙지 않은 핸들러로 가는 요청은 로그인 토큰을 확인해 막는다. 막힌 요청은 DTO 검증이나 응답 로깅 같은 뒤 단계 작업에 비용을 쓰지 않아야 한다.

② 모든 성공 응답을 `{ success: true, data }` 형태로 감싸고, 핸들러 실행에 걸린 시간을 함께 기록한다.

③ 핸들러마다 인자 타입으로 선언한 DTO 클래스의 검증 규칙으로 요청 바디를 검사하고, 통과하면 그 DTO 인스턴스로 바꿔 핸들러에 넘긴다. 규칙을 어기면 핸들러를 부르지 않고 400으로 응답한다.', 'OBJECTIVE'),
       (5409, 871, '아래 상황에서 두 번째 가드가 판단하는 것을 가리키는 보안 용어는?', '게시글 삭제 API에 가드 두 개를 `@UseGuards(JwtGuard, PostGuard)` 순서로 붙였다. PostGuard는 JwtGuard가 `req.user`에 넣어 둔 회원 번호를 읽어 쓴다.

작성자가 회원 7인 게시글 하나에 삭제 요청을 보낸 결과는 다음과 같다.

| 요청 | 보낸 토큰 | 결과 |
| --- | --- | --- |
| A | 없음 | JwtGuard에서 401 |
| B | 서명이 위조된 토큰 | JwtGuard에서 401 |
| C | 회원 12의 유효한 토큰 | JwtGuard 통과, PostGuard에서 403 |
| D | 회원 7의 유효한 토큰 | 두 가드 모두 통과, 200 |', 'SUBJECTIVE'),
       (5410, 871, '아래 상황에서 기록 함수를 등록한 NestJS 요청 처리 구성요소의 종류는?', '모든 API 요청의 경로·응답 상태 코드·처리 시간을 한 줄씩 남기는 기록 함수를 등록했다. 이 함수는 요청을 받으면 시작 시각을 적어 두고, 응답 전송이 끝났을 때(`res.on(''finish'')`) 한 줄을 남긴다.

하루치 기록을 확인한 결과는 다음과 같았다.

- 정상 처리된 200·201 응답이 모두 남았다.
- 토큰이 없어 전역 인증 가드에서 401로 거절된 요청도 빠짐없이 남았다.
- 요청을 처리한 핸들러(컨트롤러 메서드) 이름도 함께 남기려 했지만, 이 함수가 받는 인자 어디에서도 그 정보를 얻을 수 없었다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5405
(14587, 5405, '{ "items": { "success": true, "data": ["kim", "lee"] } }', '뒤 처리도 앞 처리처럼 전역 → 메서드 순이라고 본 오해다. 전역 인터셉터의 next.handle() 안에 메서드 인터셉터가 중첩돼 있어, 반환값은 안쪽 ListInterceptor의 map부터 거친다.', false),
(14588, 5405, '{ "success": true, "data": { "items": ["kim", "lee"] } }', '앞 처리는 전역 → 메서드 순이지만 뒤 처리는 그 역순이다. 배열이 먼저 ListInterceptor에서 { items }로 감싸진 뒤, 바깥쪽 WrapInterceptor가 그 결과를 { success, data }로 한 번 더 감싼다.', true),
(14589, 5405, '{ "items": ["kim", "lee"] }', '예외 필터처럼 가장 구체적인 메서드 쪽만 적용된다고 본 오해다. 인터셉터는 먼저 적용된 쪽에서 끝나지 않고 바인딩된 것이 모두 중첩돼 실행되므로 전역의 감싸기도 반영된다.', false),
(14590, 5405, '{ "success": true, "data": ["kim", "lee"] }', '전역 인터셉터가 있으면 메서드에 붙인 것은 무시된다고 본 오해다. @UseInterceptors로 붙인 ListInterceptor도 전역 인터셉터 안쪽에서 함께 실행돼 배열을 { items }로 감싼다.', false),

-- 문제 5406
(14591, 5406, 'C, D', 'HttpException 계열은 getStatus()가 생성 시 넘긴 코드를 그대로 돌려줘 D는 502, 그 밖의 예외인 C는 500이 된다. A는 ParseIntPipe의 400, B는 false 반환 시 Nest가 던지는 ForbiddenException의 403이라 남지 않는다.', true),
(14592, 5406, 'C', 'HttpException 계열은 모두 4xx 클라이언트 오류라고 본 오해다. 생성자에 넘긴 502가 getStatus()로 그대로 나오므로 D도 500 이상이 되어 에러 로그가 남는다.', false),
(14593, 5406, 'A, C, D', '숫자 변환 실패를 서버 쪽 오류로 본 오해다. ParseIntPipe는 정수로 바꿀 수 없는 값이 오면 BadRequestException을 던지므로 A는 400으로 응답되고 로그 조건에 걸리지 않는다.', false),
(14594, 5406, 'B, C, D', 'false 반환이 처리되지 않은 오류로 취급돼 500이 된다고 본 오해다. 가드가 false를 돌려주면 Nest가 ForbiddenException을 던지므로, 이 필터에서 status는 403으로 계산된다.', false),

-- 문제 5407
(14595, 5407, 'a → 200 { "page": 1 } / b → 200 { "page": 1 }', '기본값 채우기가 나열 순서와 상관없이 먼저 적용된다고 본 오해다. b에서는 ParseIntPipe가 먼저 undefined를 받아 예외를 던지므로 DefaultValuePipe까지 가지 못한다.', false),
(14596, 5407, 'a → 400 / b → 200 { "page": 1 }', '데코레이터를 쌓을 때처럼 뒤에 적은 것부터 실행된다고 본 오해다. 같은 파라미터의 파이프는 적은 순서대로 실행되므로 기본값을 먼저 채우는 a가 통과하고 b가 실패한다.', false),
(14597, 5407, 'a → 200 { "page": 1 } / b → 400', '같은 파라미터의 파이프는 적은 순서대로 값을 넘긴다. a는 DefaultValuePipe가 undefined를 1로 바꾼 뒤 ParseIntPipe가 1을 받아 통과하고, b는 ParseIntPipe가 undefined를 먼저 받아 400으로 끝난다.', true),
(14598, 5407, 'a → 400 / b → 400', '파이프마다 요청의 원래 값을 따로 받는다고 본 오해다. 뒤 파이프는 앞 파이프가 돌려준 값을 받으므로 a의 ParseIntPipe는 undefined가 아니라 1을 받아 통과한다.', false),

-- 문제 5408
(14599, 5408, '미들웨어 / 인터셉터 / 파이프', '①을 미들웨어에 맡길 수 있다고 본 오해다. 미들웨어는 어떤 핸들러가 요청을 처리할지 모르는 채 실행돼 @Public()이 붙었는지 읽을 수 없다. 메타데이터를 읽어 막는 일은 가드가 맡는다.', false),
(14600, 5408, '가드 / 예외 필터 / 파이프', '②를 응답 형식 변환이라는 이유로 예외 필터에 둔 오해다. 예외 필터는 예외가 났을 때만 호출돼 성공 응답을 감쌀 수 없다. 핸들러 반환값을 받아 가공하는 일은 인터셉터가 한다.', false),
(14601, 5408, '가드 / 인터셉터 / 미들웨어', '③을 미들웨어에 둔 오해다. 미들웨어는 요청을 처리할 핸들러를 모르므로 그 인자 타입으로 선언된 DTO 클래스도 알 수 없다. 파라미터의 타입 메타데이터를 받아 검증·변환하는 일은 파이프가 한다.', false),
(14602, 5408, '가드 / 인터셉터 / 파이프', '가드는 핸들러 메타데이터를 읽고 인터셉터·파이프보다 먼저 실행돼 ①에 맞다. 인터셉터는 핸들러 전후에 모두 개입해 반환값 가공과 시간 측정을 함께 하고, 파이프는 DTO 기준으로 인자를 검증·변환한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1758, 5409, '인가,인가(authorization),authorization,authorisation,authz,권한 부여,권한부여,권한 검사,권한 확인,접근 제어,access control', 'PostGuard는 이미 누구인지 확인된 회원이 이 게시글을 지울 수 있는지를 따진다. 회원 12는 토큰이 유효해도 403으로 막히고 작성자인 회원 7만 통과했으므로, 판단 기준은 "누구인가"가 아니라 "할 수 있는가"이며 이것이 인가(authorization)다. 첫 번째 JwtGuard는 토큰으로 요청자가 누구인지 확인하는 인증(authentication)이고, 실패하면 401을 낸다. 401의 이름이 Unauthorized라 인가 실패로 헷갈리기 쉽지만 실제 의미는 인증 실패이고, 인가 실패는 403 Forbidden이다. 가드는 @UseGuards에 나열한 순서대로 실행되므로 인증 가드를 앞에 두어야 뒤 가드가 req.user를 믿고 쓸 수 있으며, 인증에 실패한 요청은 인가 판단은 물론 인터셉터·파이프까지 가지 않는다. 역할(admin 등)로 판단하든 이 문제처럼 소유권으로 판단하든 "할 수 있는가"를 따지면 모두 인가에 속한다.'),
       (1759, 5410, '미들웨어,미들 웨어,middleware,미들웨어(middleware),NestMiddleware,Express 미들웨어,익스프레스 미들웨어', '기록 함수가 정상 응답뿐 아니라 가드에서 거절된 401 요청까지 모두 봤다는 것은 가드보다 먼저 실행된다는 뜻이고, 요청 처리 구성요소 중 가드보다 앞서는 것은 미들웨어뿐이다. 미들웨어는 라우트 매칭 전에 req·res만 받아 실행되므로 어떤 핸들러가 이 요청을 처리할지 알 수 없어, 핸들러 이름을 얻지 못했다. 처리 시간을 잰다는 점 때문에 인터셉터와 헷갈리기 쉽지만, 인터셉터는 가드 뒤에 실행돼 401로 거절된 요청은 보지 못하고, 대신 ExecutionContext의 getHandler()로 핸들러 이름을 얻을 수 있다. 예외 필터는 예외가 났을 때만 호출되므로 정상 200 응답은 남길 수 없다.');
