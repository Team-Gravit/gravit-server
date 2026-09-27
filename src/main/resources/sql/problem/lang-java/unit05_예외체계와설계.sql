-- Unit: 예외 체계와 설계 (Unit ID: 190)
-- Chapter: Java (Chapter ID: 18)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (616, 190, '검사 예외 구분과 예외 비용, 자원 해제'),
       (774, 190, 'finally 반환과 예외 계층, 롤백'),
       (932, 190, 'Java 예외 실전: catch 순서, 인터럽트 상태 복원, 예외 번역, 사라진 스택 트레이스');

-- =====================================================
-- Lesson 616: 검사 예외 구분과 예외 비용, 자원 해제
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3875, 616, '아래 클래스에서 컴파일 오류가 나는 메서드는?', '아래가 클래스 전체이며, 네 메서드는 서로 호출하지 않는다.

```java
class Repo {

    void a() {
        throw new IllegalStateException("초기화 전");
    }

    void b() {
        throw new java.io.IOException("파일 없음");
    }

    void c() throws java.io.IOException {
        throw new java.io.IOException("파일 없음");
    }

    void d() {
        throw new StackOverflowError();
    }
}
```', 'OBJECTIVE'),
       (3876, 616, '아래 측정에서 개선 전 코드가 느렸던 원인으로 옳은 것은?', '100만 줄짜리 로그 파일에서 숫자로만 이뤄진 줄의 개수를 센다. 이 중 약 50만 줄은 숫자가 아니다.

```java
// 개선 전: 4.2초
int count = 0;
for (String s : lines) {
    try {
        Integer.parseInt(s);
        count++;
    } catch (NumberFormatException e) {
        // 숫자가 아닌 줄
    }
}

// 개선 후: 0.05초
// DIGITS는 미리 컴파일해 둔 Pattern 상수
int count = 0;
for (String s : lines) {
    if (DIGITS.matcher(s).matches()) count++;
}
```

두 코드가 센 count 값은 같았고, 개선 전 코드에서 catch 블록은 약 50만 번 실행됐다.', 'OBJECTIVE'),
       (3877, 616, '아래 비교표를 바탕으로 판단할 때 옳지 않은 것은?', '| 항목 | Checked 예외 | Unchecked 예외 |
|---|---|---|
| 상속 관계 | Exception 하위(RuntimeException 계열 제외) | RuntimeException 하위 |
| 컴파일러의 처리 강제 | catch 또는 throws가 필수 | 없음 |
| 중간 계층 전파 | 거쳐 가는 모든 메서드 시그니처에 throws가 붙음 | 시그니처를 건드리지 않고 전파 |
| 대표 예시 | IOException, SQLException, InterruptedException | NullPointerException, IllegalArgumentException |
| Spring @Transactional 기본 롤백 | 롤백하지 않고 커밋 | 롤백 |', 'OBJECTIVE'),
       (3878, 616, '아래 코드를 실행했을 때 표준 출력에 찍히는 순서로 옳은 것은?', '```java
class Res implements AutoCloseable {

    private final String name;

    Res(String name) {
        this.name = name;
        System.out.println("open " + name);
    }

    @Override
    public void close() {
        System.out.println("close " + name);
    }
}

public static void main(String[] args) {
    try (Res a = new Res("A"); Res b = new Res("B")) {
        System.out.println("body");
    }
    System.out.println("end");
}
```', 'OBJECTIVE'),
       (3879, 616, '아래 로그 변화를 만들어 낸 예외 처리 방식을 가리키는 용어는?', 'PaymentService는 개선 전과 후 모두 외부 결제사 호출에서 난 SocketTimeoutException을 잡아 PaymentException으로 바꿔 던진다. 바뀐 것은 PaymentException 객체를 만드는 방식 한 줄뿐이다.

[개선 전] 결제 실패 시 남는 로그

```
com.shop.PaymentException: 결제 처리 실패
    at com.shop.PaymentService.pay(PaymentService.java:88)
    at com.shop.PaymentController.order(PaymentController.java:31)
```

[개선 후] 같은 실패에서 남는 로그

```
com.shop.PaymentException: 결제 처리 실패 - orderId=10423
    at com.shop.PaymentService.pay(PaymentService.java:88)
    at com.shop.PaymentController.order(PaymentController.java:31)
Caused by: java.net.SocketTimeoutException: connect timed out
    at java.base/java.net.Socket.connect(Socket.java:633)
    at com.shop.PgClient.send(PgClient.java:57)
```

개선 전에는 결제사 호출이 왜 실패했는지 로그만으로는 알 수 없어 담당자가 매번 게이트웨이 접속 기록을 따로 뒤져야 했다.', 'SUBJECTIVE'),
       (3880, 616, '아래 두 코드에서, 바꾼 코드가 원래 예외에 함께 담아 전달한 close() 쪽 예외를 가리키는 용어는?', '```java
// 예전 코드: 수동 해제
Connection conn = dataSource.getConnection();
try {
    query(conn);      // 여기서 SQLException("쿼리 타임아웃") 발생
} finally {
    conn.close();     // 닫는 중에도 SQLException("connection reset") 발생
}
// 로그에는 connection reset 만 남고 쿼리 타임아웃은 흔적도 없이 사라졌다.

// 바꾼 코드: try-with-resources
try (Connection conn = dataSource.getConnection()) {
    query(conn);      // 여기서 SQLException("쿼리 타임아웃") 발생
}
// 호출자는 쿼리 타임아웃을 그대로 받고, connection reset 은 그 예외 객체에 함께 담겨 따라온다.
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3875
(10507, 3875, 'a() — IllegalStateException을 던지면서 throws 선언을 하지 않았다', 'IllegalStateException은 RuntimeException 하위, 즉 Unchecked라 컴파일러가 처리도 선언도 강제하지 않는다. 던지는 예외는 무엇이든 throws에 적어야 한다고 본 오해다.', false),
(10508, 3875, 'b() — IOException을 던지면서 throws 선언도 catch도 하지 않았다', 'IOException은 Exception 하위이면서 RuntimeException 계열이 아닌 Checked 예외다. 호출자가 대응할 수 있도록 catch로 잡거나 throws로 선언해야만 컴파일된다.', true),
(10509, 3875, 'c() — IOException을 throws로 선언만 하고 catch로 잡지 않았다', 'Checked 예외는 catch와 throws 중 하나만 만족하면 된다. 호출자에게 넘기는 throws도 정식 처리 방법이라 c()는 정상 컴파일된다. 둘 다 해야 한다고 본 오해다.', false),
(10510, 3875, 'd() — Error 계열 객체를 코드에서 직접 만들어 던졌다', 'StackOverflowError는 Throwable 아래 Error 계열이라 Unchecked다. 권장할 코드는 아니지만 컴파일은 통과한다. 처리 강제 기준을 심각도로 착각한 오해다.', false),

-- 문제 3876
(10511, 3876, 'try 블록에 들어가는 것 자체에 비용이 있어 반복 100만 번의 진입 비용이 쌓였다', '예외가 나지 않는 정상 경로에서 try 진입 비용은 사실상 없다. JVM은 메서드에 딸린 예외 테이블을 보고 예외가 실제로 던져진 순간에만 catch를 찾는다.', false),
(10512, 3876, 'catch 블록이 비어 있어 JIT 컴파일러가 반복문 전체를 최적화에서 제외했다', '빈 catch가 최적화를 막지는 않는다. 비용은 최적화가 걸리지 않아서가 아니라 실패한 50만 번마다 예외 객체를 새로 만드는 데서 나온다.', false),
(10513, 3876, '숫자가 아닌 50만 줄마다 예외 객체가 만들어지면서 그때의 스택 프레임 전체를 훑어 스택 트레이스를 채웠다', 'Throwable 생성자는 fillInStackTrace()로 현재 스레드의 스택을 순회해 트레이스를 캡처한다. 예외는 던질 때보다 만들 때 비싸고, 호출 깊이가 깊을수록 더 비싸진다.', true),
(10514, 3876, 'NumberFormatException이 Checked 예외라 컴파일러가 반복마다 처리 여부를 검사하는 코드를 넣었다', 'NumberFormatException은 IllegalArgumentException 하위의 Unchecked 예외다. 게다가 Checked 검사는 컴파일 시점에 끝나므로 실행 중 반복 비용이 되지 않는다.', false),

-- 문제 3877
(10515, 3877, 'IllegalArgumentException을 던지는 메서드는 호출하는 쪽에서 catch로 잡거나 throws로 선언해야 컴파일된다', '표에서 IllegalArgumentException은 Unchecked 예시이고 Unchecked에는 처리 강제가 없다. 아무 대응 없이 호출해도 컴파일되므로 이 진술이 거짓이다.', true),
(10516, 3877, '리포지토리가 SQLException을 그대로 던지면 이를 호출하는 서비스와 컨트롤러 시그니처에도 throws가 붙어 상위 계층이 JDBC에 묶인다', '표의 전파 항목대로 Checked 예외는 거쳐 가는 모든 시그니처에 throws를 남긴다. 이 기술 종속을 끊으려고 하위 예외를 도메인 예외로 번역한다.', false),
(10517, 3877, 'IOException을 잡아 RuntimeException을 상속한 도메인 예외로 바꿔 던지면 위쪽 메서드 시그니처를 고치지 않고도 예외를 올려보낼 수 있다', '번역 후에는 Unchecked가 되므로 표의 전파 항목에 따라 중간 계층 시그니처가 깨끗하게 유지된다. Spring이 SQLException을 DataAccessException으로 바꾸는 이유도 같다.', false),
(10518, 3877, '재고 부족을 알리려고 Checked 예외를 던진 @Transactional 메서드는 별도 설정이 없으면 변경 내용이 커밋된다', '표의 롤백 항목대로 기본 롤백 대상은 Unchecked와 Error뿐이다. Checked 예외에서도 롤백하려면 rollbackFor로 대상 예외를 지정해야 한다.', false),

-- 문제 3878
(10519, 3878, 'open A → open B → body → close A → close B → end', '선언한 순서 그대로 닫힌다고 본 오해다. try-with-resources는 나중에 연 자원을 먼저 닫으므로 close B가 close A보다 앞선다.', false),
(10520, 3878, 'open A → open B → close B → close A → body → end', 'try 괄호 안 자원이 블록 본문보다 먼저 닫힌다고 본 오해다. close()는 블록 본문이 끝나거나 예외로 빠져나갈 때 호출된다.', false),
(10521, 3878, 'open A → body → open B → close B → close A → end', '자원이 처음 쓰이는 시점에 하나씩 만들어진다고 본 오해다. 괄호에 선언한 자원은 본문 진입 전에 왼쪽부터 모두 초기화된다.', false),
(10522, 3878, 'open A → open B → body → close B → close A → end', '자원은 선언 순서대로 초기화되고 블록을 벗어날 때 역순으로 close()가 불린다. finally나 명시적 close 호출 없이도 이 해제가 보장되는 것이 핵심이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1248, 3879, '원인 체이닝,예외 체이닝,체이닝,원인 보존,예외 원인 체이닝,cause chaining,exception chaining,chaining', '예외를 상위 개념으로 번역할 때 원래 예외를 cause로 함께 넘겨 두면 스택 트레이스가 Caused by 아래로 이어져 근본 원인이 남는다. 생성자에 Throwable을 넘기거나 initCause()로 지정한다. 개선 전에도 SocketTimeoutException을 PaymentException으로 바꾸는 예외 번역은 이미 하고 있었고, 바뀐 것은 원인을 매달아 둔 것뿐이다. 즉 하위 기술 예외를 도메인 예외로 바꾸는 행위가 예외 번역, 그때 원래 예외를 잃지 않게 붙여 두는 것이 원인 체이닝이라 둘을 구분해야 한다. 원인을 넘기지 않는 번역은 사실상 원인 정보를 지우는 일이며, 장애 대응 시간이 길어지는 전형적인 이유가 된다.'),
       (1249, 3880, '억제된 예외,억제 예외,suppressed exception,suppressed,서프레스드 예외', 'try-with-resources는 본문에서 던진 예외를 그대로 호출자에게 올려보내고, close() 도중 난 예외는 그 예외 객체에 붙여 둔다. getSuppressed()로 배열을 꺼낼 수 있고 스택 트레이스에는 Suppressed: 줄로 찍힌다. 원인 체이닝의 cause는 원래 실패를 일으킨 근본 원인이지만, 억제된 예외는 정리 과정에서 덤으로 생긴 별개의 실패라는 점이 다르다. 예전처럼 finally에서 직접 close()를 부르면 나중에 난 예외가 앞의 예외를 덮어써 진짜 원인이 사라지는데, 이것이 수동 해제 코드의 대표적 함정이다.');

-- =====================================================
-- Lesson 774: finally 반환과 예외 계층, 롤백
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4823, 774, '아래 코드에서 read(null)을 호출했을 때의 결과로 옳은 것은?', '```java
static int read(String path) {
    try {
        if (path == null) {
            throw new IllegalArgumentException("path=null");
        }
        return 1;
    } finally {
        return 0;
    }
}
```

호출하는 쪽은 read(null)이 돌려준 값을 출력할 뿐, 예외를 따로 잡지 않는다.', 'OBJECTIVE'),
       (4824, 774, '아래 예외 계열에 대한 설명으로 옳은 것은?', 'OutOfMemoryError, StackOverflowError, NoClassDefFoundError는 모두 Throwable 바로 아래에서 갈라져 나온 Error 계열이다. JVM이 정상 동작을 더 이어갈 수 없는 지점에서 던져지므로, 애플리케이션이 받아서 되돌릴 수 있는 종류의 문제가 아니다.', 'OBJECTIVE'),
       (4825, 774, '아래 예외 계층을 쓰는 애플리케이션에 대한 설명으로 옳은 것은?', '```
RuntimeException
└── BusinessException                  (errorCode, httpStatus를 필드로 가짐)
     ├── EntityNotFoundException       → 404
     │    └── UserNotFoundException    → 404
     ├── InvalidRequestException       → 400
     │    └── DuplicateEmailException  → 400
     └── AccessDeniedException         → 403
```

서비스 계층은 실패를 알릴 때 이 계층에 속한 예외만 던진다. 컨트롤러에는 try-catch가 한 줄도 없고, 예외를 HTTP 응답으로 바꾸는 일은 @RestControllerAdvice 처리기 한 곳이 맡는다.', 'OBJECTIVE'),
       (4826, 774, '아래 상황에서 회원 행이 롤백되지 않고 남은 이유로 옳은 것은?', '```java
@Transactional
public void register(SignupRequest req) throws MailException {
    userRepository.save(new User(req));   // INSERT 실행
    mailSender.send(req.email());         // 여기서 MailException 발생
}
```

MailException은 Exception을 직접 상속한 클래스이고, @Transactional에는 rollbackFor 같은 속성을 따로 주지 않았다. register()는 컨트롤러가 주입받은 빈을 통해 호출한다. 메일 전송이 실패해 500 응답이 나간 요청인데도 users 테이블에는 그 회원 행이 그대로 남아 있었다.', 'OBJECTIVE'),
       (4827, 774, '아래에서 바꾼 코드가 catch 블록 개수를 줄이려고 쓴 Java 7 문법의 이름은?', '```java
// 예전 코드 — catch 블록 두 개의 내용이 완전히 같다
try {
    load(path);
} catch (IOException e) {
    throw new ConfigException("설정 로드 실패", e);
} catch (SQLException e) {
    throw new ConfigException("설정 로드 실패", e);
}

// 바꾼 코드 — 잡는 예외와 던지는 동작은 그대로인데 블록이 하나로 줄었다
try {
    load(path);
} catch (IOException | SQLException e) {
    throw new ConfigException("설정 로드 실패", e);
}
```', 'SUBJECTIVE'),
       (4828, 774, '아래 코드의 빈 자리에 들어갈 표준 예외 클래스의 이름은?', '```java
public class Session {

    private boolean closed;

    public void close() {
        closed = true;
    }

    public void send(String message) {
        validate(message);   // 메시지 형식 검증은 여기서 이미 끝난다
        if (closed) {
            throw new ______("이미 닫힌 세션입니다");
        }
        channel.write(message);
    }
}
```

팀 규칙상 이 자리에는 예외 클래스를 새로 만들지 않고 java.lang이 이미 제공하는 표준 예외를 쓴다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4823
(13035, 4823, 'IllegalArgumentException이 호출자에게 그대로 전달되고 반환값은 없다', 'try에서 예외가 던져졌더라도 finally가 값을 반환하며 정상 종료하면 그 예외는 폐기된다. 한 번 던져진 예외는 무조건 호출자까지 올라간다고 본 오해다.', false),
(13036, 4823, '1이 반환되고 IllegalArgumentException은 호출자에게 전달되지 않는다', 'path가 null이라 throw가 먼저 실행되므로 return 1에는 도달하지 못한다. try 블록 끝의 return이 언제나 반환값을 정한다고 본 오해다.', false),
(13037, 4823, '0이 반환되고 IllegalArgumentException은 호출자에게 전달되지 않는다', 'finally의 return 0이 메서드를 정상 종료시켜 진행 중이던 예외를 조용히 삼킨다. 컴파일 경고만 날 뿐 오류가 아니어서 장애가 통째로 숨는데, finally에서 return을 쓰지 말라는 규칙이 여기서 나온다.', true),
(13038, 4823, '0이 반환된 직후 IllegalArgumentException이 이어서 호출자에게 전달된다', '메서드는 값을 반환하거나 예외를 던지거나 둘 중 하나로만 끝난다. 반환과 예외 전파가 함께 일어날 수 있다고 본 오해다.', false),

-- 문제 4824
(13039, 4824, 'catch (Exception e)로 넓게 감싼 전역 처리기에 함께 걸려 한 곳에서 응답으로 바뀐다', 'Exception과 Error는 Throwable 아래에서 갈라진 형제 계열이라 catch (Exception e)에 걸리지 않는다. 마지막 방어선을 뚫고 나가 스레드를 끝내는 이유다.', false),
(13040, 4824, '컴파일러가 catch도 throws도 요구하지 않아 선언 없이 호출 스택을 타고 밖으로 나간다', '처리 강제 여부는 심각도가 아니라 상속 위치로 갈린다. Exception 하위이면서 RuntimeException 계열이 아닌 것만 Checked이고, Error 계열은 여기에 들지 않아 선언 없이 전파된다.', true),
(13041, 4824, '발생 즉시 JVM이 프로세스를 끝내므로 catch 블록에 타입으로 적을 수조차 없다', 'Throwable 하위라 catch (OutOfMemoryError e)라고 적는 것 자체는 문법상 가능하고, 던져졌다고 프로세스가 바로 죽지도 않는다. 복구 대상이 아니라는 설계 지침을 문법 제약으로 오해한 것이다.', false),
(13042, 4824, 'try-with-resources 블록 안에서 나면 close()가 불리지 않아 열린 자원이 그대로 남는다', '자동 해제는 예외 종류를 가리지 않고 블록을 벗어나는 순간 일어난다. 자원 해제가 Exception일 때만 보장된다고 본 오해다.', false),

-- 문제 4825
(13043, 4825, '서비스가 UserNotFoundException을 던지려면 메서드 시그니처에 throws로 선언해야 컴파일된다', '루트인 BusinessException이 RuntimeException을 상속하므로 계층 전체가 Unchecked다. 직접 만든 예외는 무조건 선언해야 한다고 본 오해다.', false),
(13044, 4825, 'AccessDeniedException은 RuntimeException을 직접 상속하지 않으므로 Checked 예외로 취급된다', '상속은 여러 단계를 건너 이어지며, BusinessException을 거쳐 RuntimeException의 하위가 되므로 Unchecked다. 바로 위 부모만 보고 계열을 판단한 오해다.', false),
(13045, 4825, 'DuplicateEmailException을 잡는 catch 블록은 InvalidRequestException으로 던져진 예외까지 함께 잡는다', 'catch는 선언한 타입과 그 하위만 받는다. 상위 타입 객체는 하위 타입 catch에 걸리지 않으므로 포함 방향이 반대다. 계층을 위아래로 뒤집어 본 오해다.', false),
(13046, 4825, '처리기가 BusinessException 한 타입만 잡아도 그 아래 다섯 예외가 함께 걸리고, 나머지는 예상 못 한 오류로 갈린다', 'catch가 하위 타입까지 받으므로 루트 하나로 우리가 정의한 실패를 모두 받아 errorCode대로 응답을 만들 수 있고, 여기에 안 걸린 예외는 예상 못 한 오류로 남아 알림 대상이 된다. 루트를 두는 가장 큰 이유다.', true),

-- 문제 4826
(13047, 4826, '던져진 예외가 RuntimeException 계열이 아니어서 기본 롤백 대상에서 빠졌고 트랜잭션이 그대로 커밋됐다', '@Transactional의 기본 롤백 대상은 Unchecked 예외와 Error뿐이다. MailException은 Exception을 직접 상속한 Checked라 예외가 나가도 커밋된다. rollbackFor로 대상을 넓혀야 의도대로 동작한다.', true),
(13048, 4826, 'save() 호출이 끝나는 순간 INSERT가 커밋되므로 그 뒤에 난 예외로는 되돌릴 수 없다', '트랜잭션 메서드 안에서는 리포지토리 호출마다 커밋되지 않고 메서드가 끝날 때 한 번에 커밋 또는 롤백된다. 커밋 단위를 호출 하나로 본 오해다.', false),
(13049, 4826, '예외를 메서드 안에서 잡지 않고 밖으로 던져 트랜잭션 경계가 끊겼고 롤백 절차가 생략됐다', '롤백 여부는 예외가 경계 밖으로 나오는 순간 판정된다. 오히려 안에서 잡아 삼키면 판정 기회가 사라진다. 던지는 행위 자체를 문제로 본 오해다.', false),
(13050, 4826, '메일 전송은 데이터베이스 작업이 아니어서 거기서 난 예외는 트랜잭션 상태에 영향을 주지 않는다', '판정 기준은 예외가 어디서 났는지가 아니라 어떤 계열인지다. 같은 자리에서 RuntimeException을 상속한 예외가 났다면 INSERT는 롤백된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1564, 4827, '멀티 캐치,멀티캐치,다중 캐치,다중캐치,multi-catch,multicatch,multi catch,멀티 캐치 블록,다중 예외 캐치', '처리 내용이 같은 여러 예외 타입을 세로줄(|)로 묶어 한 catch로 받는 Java 7 문법이 멀티 캐치다. 같은 코드를 복사해 둔 catch 블록이 사라져 중복이 줄고, 나중에 처리 방식을 바꿀 때 한 군데만 고치면 된다. 이때 변수 e는 암묵적으로 final이라 다른 예외를 다시 대입할 수 없고, 정적 타입은 묶은 예외들의 공통 상위 타입으로 잡힌다. 상속 관계인 두 타입(예: IOException | FileNotFoundException)을 함께 묶으면 한쪽이 다른 쪽에 이미 포함되므로 컴파일 오류가 난다. catch (Exception e)로 뭉뚱그려 잡는 것과는 다르다. 멀티 캐치는 잡을 예외를 이름으로 못 박으므로 예상 못 한 예외까지 삼키지 않는다. 같은 Java 7에 함께 들어온 try-with-resources는 자원 해제를 맡는 별개 문법이니 혼동하지 않는다.'),
       (1565, 4828, 'IllegalStateException,java.lang.IllegalStateException,illegal state exception,IllegalStateException(),new IllegalStateException', '메서드를 부른 시점의 객체 상태가 요구 조건에 맞지 않을 때 쓰는 표준 예외가 IllegalStateException이다. 여기서는 message가 잘못된 것이 아니라 close() 뒤에 send()를 부른 호출 순서가 문제이므로, 인자 값이 규칙에 어긋날 때 쓰는 IllegalArgumentException과 구분된다. 구현이 그 기능 자체를 제공하지 않으면 UnsupportedOperationException, 값이 null이라 더 진행할 수 없으면 NullPointerException이 맞는 자리다. 셋 다 RuntimeException 하위의 Unchecked라 throws 선언 없이 던질 수 있다. 의미가 맞는 표준 예외가 이미 있으면 같은 뜻의 커스텀 예외를 새로 만들지 않는 편이, 처음 코드를 읽는 사람이 예외 이름만 보고 원인을 짐작하기에 유리하다.');

-- =====================================================
-- Lesson 932: Java 예외 실전: catch 순서, 인터럽트 상태 복원, 예외 번역, 사라진 스택 트레이스
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5771, 932, '아래 클래스를 컴파일했을 때의 결과로 옳은 것은?', '아래가 클래스 전체이며, read()는 IOException을 던질 수 있다. FileNotFoundException은 IOException의 하위 클래스다.

```java
class ConfigLoader {

    void load(Path path) {
        try {
            read(path);
        } catch (Exception e) {
            log.error("설정 로드 실패", e);
        } catch (FileNotFoundException e) {
            useDefaults();
        }
    }

    private void read(Path path) throws IOException { ... }

    private void useDefaults() { ... }
}
```', 'OBJECTIVE'),
       (5772, 932, '아래 로그 변화의 원인으로 옳은 것은?', '주문 API를 배포한 직후, 쿠폰이 없는 주문에서 남은 오류 로그다.

```
java.lang.NullPointerException: Cannot invoke "Coupon.rate()" because "coupon" is null
    at com.shop.OrderService.discount(OrderService.java:72)
    at com.shop.OrderService.place(OrderService.java:38)
    ... 18줄 더
```

같은 API가 수만 번 호출된 뒤부터, 같은 줄(OrderService.java:72)에서 나는 실패는 이렇게만 남는다.

```
java.lang.NullPointerException: null
```

배포 이후 코드도, 로그 설정도, JVM 실행 옵션도 바뀌지 않았고 예외를 남기는 log.error(msg, e) 호출도 그대로다.', 'OBJECTIVE'),
       (5773, 932, '아래 워커가 종료 요청을 받고도 멈추지 않은 이유로 옳은 것은?', '작업 큐를 비우는 워커 스레드다.

```java
public void run() {
    while (!Thread.currentThread().isInterrupted()) {
        Task t = takeNext();
        if (t != null) t.execute();
    }
    log.info("워커 종료");
}

private Task takeNext() {
    try {
        return queue.take();          // 큐가 빌 때까지 블로킹
    } catch (InterruptedException e) {
        log.warn("대기 중 인터럽트됨");
        return null;
    }
}
```

배포 스크립트가 executor.shutdownNow()를 부른 직후 "대기 중 인터럽트됨" 경고는 로그에 남았지만, "워커 종료"는 끝내 찍히지 않았고 이 스레드는 계속 돌았다.', 'OBJECTIVE'),
       (5774, 932, '아래 설계 결정을 따랐을 때의 결과로 옳은 것은?', '설정 로더 API를 만들면서 실패를 두 가지로 나눴다.

- (가) 지정한 경로에 설정 파일이 없다 — 호출자는 내장 기본값으로 대신 진행할 수 있다.
- (나) 설정 키로 null이 넘어왔다 — 호출자가 실행 중에 할 수 있는 일은 없고 호출 코드를 고쳐야 한다.

팀은 (가)를 Exception을 직접 상속한 ConfigFileMissingException으로, (나)를 IllegalArgumentException으로 던지기로 했다.', 'OBJECTIVE'),
       (5775, 932, '아래에서 리포지토리가 한 일을 가리키는 용어는?', '```java
// 예전 — 이 시그니처가 서비스와 컨트롤러까지 그대로 번졌다
public User findById(Long id) throws SQLException {
    return jdbc.queryForObject(SQL, mapper, id);
}

// 지금
public User findById(Long id) {
    try {
        return jdbc.queryForObject(SQL, mapper, id);
    } catch (SQLException e) {
        throw new UserRepositoryException("사용자 조회 실패: id=" + id, e);
    }
}
```

UserRepositoryException은 RuntimeException을 상속한다. 이렇게 바꾼 뒤 데이터 접근 기술을 JDBC에서 다른 것으로 갈아 끼웠을 때, 서비스와 컨트롤러는 한 줄도 고치지 않았다.', 'SUBJECTIVE'),
       (5776, 932, '아래 로그에서 ????로 가린 클래스의 이름은?', '조직도 조회 API에서만 나는 실패의 로그다.

```
2026-03-11 02:14:07 ERROR [http-nio-8080-exec-7] OrgController - 조직도 조회 실패
java.lang.????
    at com.hr.OrgService.findRoot(OrgService.java:41)
    at com.hr.OrgService.findRoot(OrgService.java:41)
    at com.hr.OrgService.findRoot(OrgService.java:41)
    ... 같은 줄이 1만 번 넘게 이어짐
```

findRoot()는 부서의 상위 부서를 따라 올라가며 자기 자신을 다시 부른다. 장애 전날 데이터 이관에서 A의 상위를 B로, B의 상위를 A로 넣은 행이 들어갔다. 같은 시각 힙 사용률은 평소와 같은 35%였고 다른 API는 정상 응답했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5771
(15563, 5771, '정상 컴파일되고, 파일이 없을 때는 더 구체적인 아래쪽 catch가 뽑혀 useDefaults()가 실행된다', 'catch 절은 위에서부터 차례로 검사해 처음 맞는 절을 고른다. 오버로딩처럼 가장 구체적인 절이 선택되지 않으며, 애초에 이 코드는 컴파일 단계를 넘지 못한다.', false),
(15564, 5771, '정상 컴파일되지만 아래쪽 catch는 실행되지 않은 채 경고만 남는다', '도달할 수 없는 catch는 경고로 넘어가지 않고 컴파일을 막는다. 실행되지 않는 코드가 남을 뿐이라고 본 오해다.', false),
(15565, 5771, '아래쪽 catch에 어떤 경우에도 도달할 수 없어 컴파일 오류가 난다', '위쪽 catch (Exception e)가 FileNotFoundException까지 모두 받아 아래 절은 영원히 실행될 수 없다. 자바는 이런 catch를 오류로 막으므로 구체적인 타입부터 적어야 한다.', true),
(15566, 5771, 'read()가 Checked 예외를 던지는데 load()에 throws 선언이 없어 read() 호출 줄에서 컴파일 오류가 난다', 'catch (Exception e)가 IOException까지 받으므로 read() 호출은 이미 처리된 상태다. Checked 예외는 throws 선언으로만 처리한다고 본 오해로, catch도 정식 처리 방법이다.', false),

-- 문제 5772
(15567, 5772, '같은 자리에서 되풀이되는 내장 예외를 JVM이 스택 트레이스 없는 객체로 바꿔 던지는 최적화가 걸렸다', 'HotSpot은 같은 지점에서 반복되는 NullPointerException 같은 예외를 JIT 컴파일 후 미리 만들어 둔 객체로 재사용한다. 트레이스 캡처 비용을 아끼는 대신 로그에서 원인 위치가 사라진다.', true),
(15568, 5772, '로그 프레임워크가 짧은 시간에 반복되는 같은 메시지를 묶어 뒤쪽 출력을 줄였다', '반복 메시지를 묶는 설정은 건드리지 않았고, 그런 억제라면 로그 줄 전체가 빠지지 트레이스만 골라 사라지지 않는다.', false),
(15569, 5772, '예외가 여러 계층을 거쳐 전파되는 동안 스택 프레임이 하나씩 풀려 남길 정보가 없어졌다', '스택 트레이스는 예외 객체를 만드는 순간 캡처돼 객체 안에 담긴다. 전파하며 프레임이 풀려도 이미 담아 둔 트레이스는 없어지지 않는다.', false),
(15570, 5772, 'NullPointerException은 Unchecked라 선언 없이 전파되며, 이 계열은 JVM이 트레이스를 채우지 않는다', 'Checked와 Unchecked를 가르는 기준은 컴파일러의 처리 강제 여부이지 트레이스 캡처가 아니다. 같은 예외가 배포 직후에는 트레이스를 남긴 사실과도 어긋난다.', false),

-- 문제 5773
(15571, 5773, 'shutdownNow()는 큐에 남은 작업만 버릴 뿐 이미 실행 중인 스레드에는 아무 신호도 보내지 않는다', 'shutdownNow()는 대기 작업을 버리는 동시에 실행 중인 스레드에 인터럽트를 건다. 경고 로그가 남은 것이 신호가 도착했다는 증거다.', false),
(15572, 5773, 'isInterrupted()는 상태를 확인하면서 함께 지우므로 검사 직후 상태가 사라져 루프가 끝나지 못한다', '확인과 동시에 상태를 지우는 것은 정적 메서드 Thread.interrupted()다. isInterrupted()는 읽기만 하므로 상태가 남아 있다면 참을 돌려준다. 둘을 맞바꿔 본 오해다.', false),
(15573, 5773, 'InterruptedException을 catch로 잡아 처리한 순간 종료 요청이 소비돼 같은 스레드에 다시 인터럽트를 걸 수 없다', '인터럽트는 스레드가 들고 있는 상태 플래그일 뿐이라 소비 완료로 기록되지 않고, 필요하면 다시 걸 수도 있다. Checked 예외인지 여부와도 무관하다.', false),
(15574, 5773, 'take()가 예외를 던지며 인터럽트 상태를 지웠는데 catch가 이를 되살리지 않아 while 조건이 계속 참이다', 'InterruptedException이 던져지는 순간 스레드의 인터럽트 상태는 false로 지워진다. catch에서 Thread.currentThread().interrupt()로 복원하거나 예외를 다시 던지지 않으면 종료 신호가 통째로 사라진다.', true),

-- 문제 5774
(15575, 5774, '(나)는 컴파일러가 처리를 강제하지 않으므로 호출부에서 try-catch로 잡는 것 자체가 불가능하다', '처리 강제가 없다는 말은 잡지 않아도 컴파일된다는 뜻이지 잡을 수 없다는 뜻이 아니다. IllegalArgumentException도 필요하면 얼마든지 catch로 받는다.', false),
(15576, 5774, '(가)를 던지는 메서드는 Stream.map에 넘긴 람다 안에서 그대로 호출할 수 없어 따로 감싸야 한다', 'ConfigFileMissingException은 Exception을 직접 상속한 Checked 예외다. Function 같은 함수형 인터페이스는 이 예외를 선언하지 않아 람다 본문에서 밖으로 내보낼 수 없고, Unchecked로 바꿔 던지는 손질이 필요하다.', true),
(15577, 5774, '(나)를 던지는 메서드는 시그니처에 throws로 적을 수 없어 호출자에게 알릴 방법이 없다', 'Unchecked 예외도 throws에 적을 수 있다. 컴파일러가 요구하지 않을 뿐이며 호출자에게 알리는 문서 용도로 쓰기도 한다. 강제와 금지를 헷갈린 오해다.', false),
(15578, 5774, '(가)와 (나)를 한 catch 블록에서 함께 받으려면 둘의 공통 상위인 RuntimeException으로 잡아야 한다', '한쪽은 Exception 직속이고 다른 쪽은 RuntimeException 하위라, 둘을 함께 받는 가장 가까운 타입은 Exception이다. 계층의 위아래를 거꾸로 본 오해다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1880, 5775, '예외 번역,예외번역,exception translation,translation,예외 변환,예외변환,예외 래핑,예외래핑,exception wrapping,wrapping', '하위 기술이 던지는 예외를 그 계층의 추상화 수준에 맞는 예외로 바꿔 던지는 것이 예외 번역이다. SQLException이 리포지토리 밖으로 나가지 않으니 서비스와 컨트롤러 시그니처에 throws가 번지지 않고, 상위 계층이 JDBC라는 구현 세부에 묶이지 않아 데이터 접근 기술을 갈아 끼워도 그대로 살아남는다. Spring이 SQLException을 DataAccessException 계층으로 바꿔 던지는 것도 같은 기법이다. 생성자 마지막 인자로 넘긴 e는 원인 체이닝이라 부르며 번역과 짝으로 쓰이지만 서로 다른 이름이다. 번역은 던질 예외의 타입을 바꾸는 일이고, 체이닝은 그때 원래 예외를 cause로 매달아 로그의 Caused by 아래에 남기는 일이다. 원인을 빼먹고 타입만 바꾸면 근본 원인이 지워져 장애 추적이 막히므로 둘은 늘 함께 간다.'),
       (1881, 5776, 'StackOverflowError,java.lang.StackOverflowError,스택오버플로에러,스택 오버플로 에러,스택오버플로우에러,스택 오버플로우 에러,스택 오버플로,스택오버플로우,stack overflow error', '서로를 상위 부서로 가리키는 두 행 때문에 findRoot()가 끝나지 못하고 자신을 계속 불러 스레드 스택이 한계를 넘었고, 이때 JVM이 던지는 것이 StackOverflowError다. 같은 프레임이 반복해 찍힌 트레이스가 무한 재귀의 전형적인 흔적이다. 힙이 모자랄 때 나는 OutOfMemoryError와 헷갈리기 쉬운데, 힙 사용률이 평소와 같은 35%였고 다른 API는 멀쩡했다는 점이 둘을 가른다. 또 이 클래스는 Exception이 아니라 Error 계열이라 Throwable 아래에서 갈라진 형제이고, catch (Exception e)로 넓게 친 전역 처리기에도 걸리지 않는다. 잡아서 복구할 대상이 아니라 종료 조건이나 데이터를 고쳐야 하는 문제이며, 재귀를 반복문으로 바꾸거나 방문한 부서를 기록해 순환을 끊는 것이 정석이다.');
