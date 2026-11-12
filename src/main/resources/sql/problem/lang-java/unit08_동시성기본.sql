-- Unit: 동시성 기본 (Unit ID: 193)
-- Chapter: Java (Chapter ID: 18)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (619, 193, '가시성과 원자성, 더블 체크 락킹'),
       (777, 193, '락 객체 선택과 재진입, 찢어진 읽기'),
       (935, 193, '동시성 기본 - 잠금 범위와 대기 규칙이 가르는 결과');

-- =====================================================
-- Lesson 619: 가시성과 원자성, 더블 체크 락킹
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3893, 619, '아래 코드에서 두 스레드가 모두 종료한 뒤 get()이 돌려주는 값에 대한 설명으로 옳은 것은?', '```java
public class Counter {
    private volatile int count = 0;

    public void increment() { count++; }
    public int get() { return count; }
}
```

스레드 A와 B가 같은 Counter 객체에서 increment()를 각각 10,000번 호출한다. main 스레드는 두 스레드에 join()을 걸어 종료를 기다린 뒤 get()을 호출한다.', 'OBJECTIVE'),
       (3894, 619, '아래 코드와 실행 기록에서 worker 스레드가 멈추지 않은 원인으로 옳은 것은?', '```java
public class Worker implements Runnable {
    private boolean running = true;

    public void run() { while (running) { doWork(); } }
    public void stop() { running = false; }
}
```

```
[main]   t=0.0s   worker 스레드 시작
[main]   t=1.0s   stop() 호출 반환, running 필드에 false 기록 확인
[worker] t=60.0s  루프가 여전히 돌고 있음 (종료되지 않음)
```

같은 코드를 다른 장비에서 돌렸을 때는 1초 뒤 정상 종료됐다.', 'OBJECTIVE'),
       (3895, 619, '아래 코드의 락 동작에 대한 설명으로 옳은 것은?', '```java
public class Registry {
    private static int total;
    private int local;

    public synchronized void addLocal() { local++; }

    public static synchronized void addTotal() { total++; }

    public synchronized void addBoth() {
        synchronized (this) { local++; }
        addTotal();
    }
}
```

Registry 인스턴스 r 하나를 여러 스레드가 공유한다.', 'OBJECTIVE'),
       (3896, 619, '아래 비교표를 바탕으로 한 판단으로 옳지 않은 것은?', '| 항목 | synchronized | volatile |
|---|---|---|
| 원자성 | 블록 전체를 한 덩어리로 보장 | 단일 읽기·쓰기만 보장 |
| 가시성 | 보장 | 보장 |
| 재배치 금지 | 블록 경계 기준 | 변수 접근 기준 |
| 블로킹 | 경쟁이 있을 때 대기 발생 | 없음 |
| 적용 대상 | 메서드·블록 | 필드 |', 'OBJECTIVE'),
       (3897, 619, '아래 상황에서 Thread.sleep(100) 자리에 들어가야 할 메서드의 이름은?', '```java
public synchronized void put(T item) throws InterruptedException {
    while (queue.size() == capacity) {
        Thread.sleep(100);          // 자리가 나기를 기다림
    }
    queue.add(item);
    notifyAll();
}
```

```
[생산자] t=0.0s   큐가 가득 참, 100ms 대기를 반복
[소비자] t=0.1s   take() 호출 - 메서드 안으로 들어가지 못하고 멈춤
[소비자] t=30.0s  여전히 들어가지 못함
```

100ms 대기를 다른 메서드 호출 한 줄로 바꾸자 소비자가 곧바로 항목을 꺼내 갔고, 생산자도 깨어나 계속 진행했다.', 'SUBJECTIVE'),
       (3898, 619, '아래 코드의 간헐적 오류를 없애려면 instance 필드 선언에 추가해야 할 키워드는?', '```java
public class Config {
    private static Config instance;

    public static Config getInstance() {
        if (instance == null) {
            synchronized (Config.class) {
                if (instance == null) instance = new Config();
            }
        }
        return instance;
    }
}
```

```
부하 테스트: getInstance() 호출 1,000,000회 중 3회에서
            돌려받은 객체의 timeout 필드가 0으로 관찰됨
전제:       생성자가 timeout을 30으로 채우며, 대입 이후 값을 바꾸는 코드는 없음
```

단일 스레드 테스트와 개발 장비에서는 한 번도 재현되지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3893
(10555, 3893, 'join()으로 기다렸더라도 A와 B가 쓴 값이 main 스레드에 반영되지 않아 get()이 0을 돌려줄 수 있다.', 'join() 반환은 그 스레드의 모든 동작보다 뒤에 오도록 happens-before가 성립해 가시성이 보장된다. 여기서 깨지는 것은 가시성이 아니라 원자성이다.', false),
(10556, 3893, 'A와 B의 증가가 서로 겹쳐 get()이 20,000보다 작은 값을 돌려줄 수 있다.', 'count++는 읽기-계산-쓰기 세 단계라 두 스레드가 같은 값을 읽으면 증가 한 번이 사라진다. volatile은 이 세 단계를 한 덩어리로 묶어 주지 못한다.', true),
(10557, 3893, 'volatile이 읽기-계산-쓰기를 한 덩어리로 묶어 주므로 get()은 항상 20,000이다.', 'volatile이 원자성까지 준다는 대표적 오해. volatile이 보장하는 것은 단일 읽기·쓰기의 가시성과 주변 명령의 재배치 금지까지다.', false),
(10558, 3893, '증가 요청이 중복 반영돼 get()이 20,000보다 큰 값을 돌려줄 수 있다.', '실행이 엇갈리면 값이 아무렇게나 튄다는 오해. 호출 한 번이 더하는 양은 1이므로 상한은 20,000이고, 겹침은 값을 늘리는 게 아니라 잃게 만든다.', false),

-- 문제 3894
(10559, 3894, 'JIT가 running 읽기를 루프 밖으로 끌어올려 매 반복마다 메모리에서 다시 읽지 않았다.', '한 스레드 관점에서는 running이 바뀌지 않으니 컴파일러는 읽기를 레지스터에 올려 둘 수 있다. 장비와 JIT 적용 시점에 따라 증상이 갈리는 것도 같은 이유다.', true),
(10560, 3894, 'stop()이 running에 false를 쓰기 전에 run()이 먼저 시작돼 두 동작의 순서가 뒤집혔다.', '기록상 stop()은 t=1.0s에 이미 반환했고 루프는 그 뒤로 59초를 더 돌았다. 시작 순서가 아니라 쓴 값이 상대에게 보이지 않는 것이 문제다.', false),
(10561, 3894, 'boolean 쓰기가 원자적이지 않아 false가 절반만 기록돼 중간 상태가 읽혔다.', '쓰기가 쪼개질 수 있는 것은 volatile이 아닌 long·double이고, 그마저도 중간값이지 boolean처럼 두 값뿐인 타입에는 해당하지 않는다.', false),
(10562, 3894, 'main과 worker가 running을 동시에 수정해 갱신이 유실됐다.', '갱신 유실은 여러 스레드가 같은 값을 읽고 고쳐 쓸 때 생긴다. 여기서 running에 쓰는 스레드는 main 하나뿐이고 worker는 읽기만 한다.', false),

-- 문제 3895
(10563, 3895, '한 스레드가 r.addLocal()을 실행하는 동안에는 Registry.addTotal()도 함께 잠겨 다른 스레드가 대기한다.', '같은 클래스에 있으면 락도 하나라는 오해. addLocal()이 잡는 모니터는 인스턴스 r이고 addTotal()이 잡는 모니터는 Registry.class로 서로 별개다.', false),
(10564, 3895, 'addBoth()에 들어간 스레드는 이미 쥔 this 락을 synchronized (this)에서 다시 요구하다 스스로 교착 상태에 빠진다.', 'Java의 내재 락은 재진입 가능해서 같은 스레드는 이미 쥔 락을 다시 얻는다. 획득 횟수를 세다가 0이 될 때 비로소 락이 풀린다.', false),
(10565, 3895, '한 스레드가 r.addLocal()을, 다른 스레드가 Registry.addTotal()을 동시에 실행할 수 있다.', '인스턴스 메서드의 락 대상은 this, static 메서드의 락 대상은 Registry.class다. 두 모니터가 별개라 서로의 진입을 막지 않는다.', true),
(10566, 3895, '인스턴스를 두 개 만들면 addTotal()도 인스턴스마다 다른 락을 잡아 total을 동시에 갱신할 수 있다.', 'static synchronized의 락 대상은 인스턴스 수와 무관하게 Registry.class 하나뿐이다. 그래서 total 갱신은 언제나 한 줄로 직렬화된다.', false),

-- 문제 3896
(10567, 3896, 'synchronized 블록은 경쟁이 없어도 락을 얻고 푸는 비용이 들지만, 스레드가 대기 상태로 넘어가지는 않는다.', '표의 블로킹 행은 대기가 경쟁이 있을 때 생긴다고 적고 있다. 경쟁이 없으면 대기 전환은 없되 진입 비용까지 0은 아니므로 참인 진술이다.', false),
(10568, 3896, '메서드 전체를 volatile로 선언해 임계 영역을 만드는 방식은 쓸 수 없다.', '표의 적용 대상 행대로 volatile은 필드에만 붙는 한정자다. 메서드나 블록을 통째로 잠그는 일은 synchronized의 몫이라 참인 진술이다.', false),
(10569, 3896, '두 필드를 항상 짝지어 갱신해야 하는 규칙은 각 필드에 volatile을 붙이는 것만으로 지킬 수 없다.', 'volatile의 원자성은 필드 하나의 읽기·쓰기까지다. 두 쓰기 사이에 다른 스레드가 끼어들면 한쪽만 갱신된 중간 상태가 보이므로 참인 진술이다.', false),
(10570, 3896, 'synchronized는 락으로 원자성을 지키는 대신, volatile이 주는 가시성 보장까지는 제공하지 못한다.', '표의 가시성 행은 두 도구 모두 보장이라고 적고 있어 거짓이다. 락을 풀 때 변경이 메인 메모리로 밀려 나가고 얻을 때 캐시가 무효화된다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1254, 3897, 'wait,wait(),Object.wait,Object.wait(),wait 메서드', '생산자가 put()의 모니터를 쥔 채 잠들어 있어서 소비자가 같은 모니터를 쓰는 take()에 들어가지 못했다. wait()은 그 모니터를 놓고 대기 집합으로 들어가므로 소비자가 진입해 항목을 꺼내고 notifyAll()로 생산자를 깨울 수 있다. 반면 Thread.sleep()은 락을 쥔 채 자기 때문에 같은 코드가 그대로 멈춘다. 이것이 wait()과 sleep()의 결정적 차이다. wait()·notify()는 반드시 synchronized 블록 안에서 호출해야 IllegalMonitorStateException을 피할 수 있고, 가짜 깨어남 때문에 조건은 if가 아니라 while로 다시 검사해야 한다.'),
       (1255, 3898, 'volatile,volatile 키워드', 'new Config()는 메모리 할당, 생성자 실행, 참조 대입의 세 단계이고 JIT는 생성자 실행과 참조 대입의 순서를 바꿀 수 있다. 그러면 락 밖의 1차 검사만 통과한 다른 스레드가 생성자가 끝나기 전의 참조를 받아 timeout이 아직 0인 객체를 보게 된다. instance를 volatile로 선언하면 이 재배치가 금지되고, volatile 쓰기 이전의 모든 쓰기가 그 변수의 읽기 이후에 보이므로 객체가 안전하게 발행된다. synchronized 블록은 락 안쪽만 지켜 줄 뿐 락 밖 1차 검사를 보호하지 못한다는 점이 핵심이다. 더 단순한 대안으로는 static 홀더 클래스 관용구나 enum 싱글턴이 있다.');

-- =====================================================
-- Lesson 777: 락 객체 선택과 재진입, 찢어진 읽기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4841, 777, '아래 두 클래스의 락 동작에 대한 설명으로 옳은 것은?', '```java
public class OrderCache {
    private int hit;

    public void record() {
        synchronized ("CACHE_LOCK") { hit++; }
    }
}

public class UserCache {
    private int hit;

    public void record() {
        synchronized ("CACHE_LOCK") { hit++; }
    }
}
```

두 클래스는 서로 다른 팀이 작성했고 공유하는 필드도 상속 관계도 없다. 스레드 W1은 OrderCache.record()만, 스레드 W2는 UserCache.record()만 반복 호출한다.', 'OBJECTIVE'),
       (4842, 777, '아래 코드와 실행 기록에서 C2가 예외로 끝난 원인으로 옳은 것은?', '```java
public synchronized void put(T item) {
    queue.add(item);
    notifyAll();
}

public synchronized T take() throws InterruptedException {
    if (queue.isEmpty()) wait();
    return queue.remove();
}
```

```
소비자 C1, C2와 생산자 P가 같은 버퍼 객체를 공유한다.
t=0.000s  C1 take() 호출 - 큐가 비어 대기
t=0.001s  C2 take() 호출 - 큐가 비어 대기
t=0.500s  P put(x) 호출 - 항목 1개 추가, notifyAll() 반환
t=0.501s  C1 정상 반환, 돌려준 항목은 x
t=0.501s  C2 NoSuchElementException 발생
```', 'OBJECTIVE'),
       (4843, 777, '아래 측정 결과에 대한 판단으로 옳은 것은?', '공유 카운터를 네 가지로 구현하고, 스레드 2개가 각각 10,000번씩 증가시킨 뒤 최종값을 읽었다. 구현마다 10회씩 측정했다.

| 구현 | 10회 실행의 최종값 | 평균 소요 시간 |
|---|---|---|
| int count; count++; | 12,431 ~ 19,988 (실행마다 다름) | 0.9ms |
| volatile int count; count++; | 15,207 ~ 19,996 (실행마다 다름) | 1.6ms |
| synchronized 메서드 안에서 count++; | 20,000 (10회 모두) | 6.4ms |
| AtomicInteger의 incrementAndGet(); | 20,000 (10회 모두) | 2.2ms |', 'OBJECTIVE'),
       (4844, 777, '아래 코드에서 reader()가 관찰하는 값에 대한 설명으로 옳은 것은?', '```java
public class Holder {
    private int data = 0;                      // 일반 필드
    private volatile boolean ready = false;    // volatile 필드

    public void writer() {          // 스레드 W가 한 번만 호출
        data = 42;
        ready = true;
    }

    public void reader() {          // 스레드 R이 반복 호출
        if (ready) {
            System.out.println(data);
        }
    }
}
```

두 메서드 어디에도 synchronized는 없고, data에 42가 아닌 값을 쓰는 코드도 없다.', 'OBJECTIVE'),
       (4845, 777, '아래 로그에 나타난 모니터 락의 성질을 가리키는 용어는?', '```java
public class Vault {
    private int balance = 100;

    public synchronized void transfer(int amount) {
        withdraw(amount);
        deposit(amount);
    }

    public synchronized void withdraw(int amount) { balance -= amount; }
    public synchronized void deposit(int amount) { balance += amount; }
}
```

```
스레드 T1이 transfer(10)을, 스레드 T2가 같은 인스턴스의 withdraw(5)를 호출한다.
[T1] transfer() 진입 - 이 인스턴스의 모니터 보유 횟수 0 -> 1
[T1] withdraw() 진입 - 같은 모니터를 다시 요청, 보유 횟수 1 -> 2
[T1] withdraw() 반환 - 보유 횟수 2 -> 1
[T1] deposit()  진입 - 보유 횟수 1 -> 2
[T1] deposit()  반환 - 보유 횟수 2 -> 1
[T1] transfer() 반환 - 보유 횟수 1 -> 0
[T2] withdraw() 진입 - 이 시점에 비로소 모니터 획득
```', 'SUBJECTIVE'),
       (4846, 777, '아래 기록에서 대입한 적 없는 값이 관찰된 현상을 가리키는 용어는?', '```
실행 환경: 32비트 JVM
필드 선언: private long position;

쓰기 스레드가 이 필드에 번갈아 대입한 값은 두 가지뿐이다.
  0x0000000000000000
  0xFFFFFFFFFFFFFFFF

읽기 스레드가 기록한 값:
  0x0000000000000000
  0xFFFFFFFFFFFFFFFF
  0x00000000FFFFFFFF   <- 대입한 적 없는 값
  0xFFFFFFFF00000000   <- 대입한 적 없는 값

필드 선언을 private volatile long position; 으로 바꾸자
읽기 스레드는 앞의 두 값만 기록했다.
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4841
(13083, 4841, '두 클래스가 각자의 문자열 객체를 잠그므로, W1과 W2의 record() 호출은 서로를 막지 않고 나란히 진행된다.', '락 대상이 클래스마다 따로 생긴다고 본 오해. 내용이 같은 문자열 리터럴은 상수 풀의 한 객체로 인턴되므로 두 블록이 잡는 모니터는 결국 하나다.', false),
(13084, 4841, '두 클래스가 상수 풀의 같은 문자열 객체를 잠그므로, 공유 자료가 없는데도 한쪽이 끝날 때까지 다른 쪽이 기다린다.', '문자열 리터럴은 JVM 안에서 하나로 인턴되어 무관한 코드끼리 모니터가 겹친다. 필요 없는 직렬화로 처리량이 떨어지고, 같은 리터럴을 쓰는 제3의 코드가 끼면 교착 상태로까지 번진다.', true),
(13085, 4841, '문자열은 불변 객체라 모니터를 갖지 않으므로, 이 synchronized 블록은 애초에 컴파일되지 않는다.', '불변성과 모니터 보유를 뒤섞은 오해. 모든 Java 객체가 모니터를 하나씩 가지므로 String도 락 대상이 된다. 문제는 문법이 아니라 그 객체가 온 JVM에서 공유된다는 점이다.', false),
(13086, 4841, '락 대상이 리터럴이라 스레드마다 사본을 잡게 되므로, 두 record() 모두 상호 배제가 걸리지 않는다.', '스레드가 객체 사본을 갖는다고 본 오해. 스레드 스택에 놓이는 것은 참조뿐이고 리터럴 객체 자체는 힙의 상수 풀에 하나만 있다. 상호 배제는 안 걸리는 게 아니라 지나치게 걸린다.', false),

-- 문제 4842
(13087, 4842, 'notifyAll()이 대기 중인 스레드를 모두 깨운 것이 원인이므로, notify()로 바꿔 하나만 깨우면 이 예외는 사라진다.', '깨우는 수만 줄이면 된다는 오해. 깨어난 스레드가 조건을 다시 보지 않는 한 가짜 깨어남 한 번으로 같은 예외가 난다. 게다가 notify()는 대상을 고를 수 없어 필요한 스레드를 못 깨우고 멈출 위험을 더한다.', false),
(13088, 4842, 'wait()이 모니터를 쥔 채 대기하는 탓에, C1과 C2가 같은 시점에 take() 안에 함께 들어가 있었다.', 'wait()과 Thread.sleep()을 뒤섞은 오해. wait()은 모니터를 놓고 대기 집합으로 들어가며 깨어난 뒤에도 모니터를 다시 얻어야 진행하므로, 두 소비자가 동시에 임계 영역 안에 있을 수는 없다.', false),
(13089, 4842, 'queue가 동기화되지 않은 컬렉션이라, put()의 add()와 take()의 remove()가 겹쳐 내부 상태가 깨졌다.', '컬렉션 자체의 동시 접근을 원인으로 본 오해. 두 메서드 모두 같은 객체의 synchronized 메서드라 접근은 한 줄로 직렬화된다. 예외는 비어 있는 큐에서 remove()를 부른 결과다.', false),
(13090, 4842, '함께 깨어난 C2가 큐 상태를 다시 보지 않고 진행해, C1이 항목을 가져간 뒤의 빈 큐에서 remove()를 호출했다.', '깨어났다는 것은 모니터를 다시 얻었다는 뜻일 뿐 조건이 참이라는 보장이 아니다. 항목은 하나인데 소비자는 둘이라 늦게 진입한 쪽은 빈 큐를 만난다. 조건 검사를 if가 아니라 while로 두어야 하는 이유다.', true),

-- 문제 4843
(13091, 4843, 'volatile을 붙여도 최종값이 20,000에 못 미치므로, 어긋남의 원인은 쓴 값이 안 보이는 데 있지 않고 읽고 고쳐 쓰는 사이에 다른 스레드가 끼어드는 데 있다.', 'volatile이 주는 것은 단일 읽기·쓰기의 가시성과 주변 명령의 재배치 금지까지다. 증가 연산은 읽기-계산-쓰기 세 단계라 두 스레드가 같은 값을 읽으면 증가 한 번이 사라진다. 둘째 행이 그 증거다.', true),
(13092, 4843, 'volatile 행의 최종값이 첫째 행보다 높은 것은, volatile이 증가 연산의 일부를 한 덩어리로 묶어 주기 때문이다.', 'volatile이 원자성을 조금이라도 준다고 본 오해. 매번 메인 메모리를 거치느라 값이 어긋날 수 있는 시간 창이 좁아졌을 뿐, 세 단계가 묶이지 않는 사실은 그대로다.', false),
(13093, 4843, '최종값이 20,000으로 맞는 두 구현은 모두 모니터를 얻으므로, 경쟁이 심해지면 스레드가 대기 상태로 넘어간다.', '값이 맞으면 락을 쓴 것이라고 본 오해. 원자 클래스는 CAS 재시도로 값을 맞추며 모니터를 잡지 않는다. 소요 시간이 synchronized의 3분의 1 수준인 것도 대기 전환이 없기 때문이다.', false),
(13094, 4843, 'synchronized 행이 가장 느리므로, 여러 필드를 함께 갱신하는 코드도 원자 클래스로 바꾸면 같은 일관성을 더 싸게 얻는다.', '한 번에 묶이는 범위를 넓게 본 오해. 원자 클래스가 보장하는 것은 변수 하나의 연산까지다. 두 필드가 늘 짝지어 바뀌어야 한다면 두 갱신을 한 덩어리로 감싸는 synchronized나 Lock이 필요하다.', false),

-- 문제 4844
(13095, 4844, '두 쓰기가 한 덩어리가 아니므로, R이 그 사이에 끼어들면 ready는 true인데 data는 0인 상태를 볼 수 있다.', '원자성과 가시성을 뒤섞은 판단. 두 쓰기가 원자적이지 않은 것은 맞지만, ready가 true로 읽혔다면 프로그램 순서상 앞선 data 대입은 이미 끝났고 volatile 규칙이 그 결과까지 보이게 한다.', false),
(13096, 4844, 'ready에 붙은 volatile이 앞선 쓰기를 뒤로 미루는 재배치를 허용하므로, R에게 ready만 먼저 보일 수 있다.', '재배치를 막는 쪽과 허용하는 쪽을 거꾸로 본 오해. volatile 쓰기는 그 앞의 쓰기가 뒤로 넘어가지 못하도록 경계를 세운다. 재배치가 열리는 것은 오히려 volatile이 없을 때다.', false),
(13097, 4844, 'R이 ready를 true로 읽었다면 data는 반드시 42로 읽히며, 이 보장은 data 자체에 volatile을 붙이지 않아도 성립한다.', 'volatile 쓰기는 같은 변수의 이후 읽기보다 happens-before이고, 그 쓰기 이전의 일반 쓰기까지 함께 보이게 한다. volatile 변수 하나가 다른 데이터의 발행 신호 노릇을 하는 전형적인 형태다.', true),
(13098, 4844, 'volatile은 붙은 변수만 새로 읽어 오므로, R은 ready의 최신 값을 보면서도 data는 캐시에 남은 0을 계속 읽는다.', '캐시가 변수 하나 단위로 갱신된다는 그림에서 나온 오해. volatile 읽기는 그 지점에 경계를 세워 상대 스레드가 그 전에 쓴 값들까지 함께 보이게 하므로, data만 뒤처져 남지 않는다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1570, 4845, '재진입,재진입성,재진입 가능,재진입가능,reentrant,reentrancy,리엔트런트,리엔트런시', 'T1은 transfer()에서 이미 이 인스턴스의 모니터를 쥔 상태로 withdraw()와 deposit()을 부른다. 같은 스레드가 자신이 이미 가진 모니터를 다시 요청하면 JVM은 막지 않고 보유 횟수만 1 늘리는데, 이 성질이 재진입이다. 로그의 0 -> 1 -> 2 -> 1 -> 2 -> 1 -> 0이 그 횟수 변화다. 재진입이 없었다면 T1은 자기가 쥔 락을 자기가 기다리며 멈췄을 것이고, synchronized 메서드끼리 서로 호출하는 코드는 아예 쓸 수 없었을 것이다. 횟수가 0이 되는 순간에만 락이 풀리므로 T2는 transfer() 전체가 끝난 뒤에야 진입한다. 헷갈리기 쉬운 옆 개념과 구분하면, 교착 상태는 서로 다른 스레드가 상대가 쥔 락을 기다려 순환이 생기는 경우이고 상호 배제는 임계 영역에 한 스레드만 두겠다는 목표 자체여서, 같은 스레드의 재요청을 어떻게 다루느냐를 가리키는 재진입과는 층이 다르다.'),
       (1571, 4846, '찢어진 읽기,찢어진 쓰기,워드 티어링,워드티어링,word tearing,wordtearing,word-tearing,티어링,tearing', 'Java 메모리 모델은 volatile이 아닌 64비트 long과 double의 읽기·쓰기를 32비트씩 두 번으로 나누어 처리하는 것을 허용한다. 그래서 상위 절반만 갱신되고 하위 절반은 아직 이전 값인 중간 상태가 읽힐 수 있고, 어느 스레드도 대입한 적 없는 0x00000000FFFFFFFF 같은 값이 관찰된다. 필드에 volatile을 붙이면 64비트 접근이 한 덩어리로 처리되어 기록이 두 값으로 돌아온 것이 이를 확인해 준다. 옆 개념과 구분하면, 가시성 문제는 남이 쓴 최신 값을 한동안 못 보는 것이고 갱신 유실은 읽고 고쳐 쓰는 사이에 끼어들어 증가 한 번이 사라지는 것인데, 여기서는 대입 하나가 둘로 쪼개져 존재한 적 없는 값이 보인다는 점이 다르다. 다만 volatile이 주는 것은 이 단일 대입의 원자성까지이며, position++ 같은 복합 연산까지 보장하지는 않는다.');

-- =====================================================
-- Lesson 935: 동시성 기본 - 잠금 범위와 대기 규칙이 가르는 결과
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5789, 935, '아래 코드와 실행 기록에서 remaining이 음수가 된 원인으로 옳은 것은?', '```java
public class TicketBooth {
    private int remaining = 10;
    private final Object lock = new Object();

    public boolean sell() {
        if (remaining > 0) {              // 재고 검사
            synchronized (lock) {
                remaining--;              // 재고 차감
            }
            return true;
        }
        return false;
    }
}
```

```
TicketBooth 객체 하나를 스레드 20개가 공유하며 sell()을 한 번씩 호출한다.

true를 돌려받은 호출: 13건
모든 스레드 종료 후 remaining: -3
```', 'OBJECTIVE'),
       (5790, 935, '아래 코드에서 worker 스레드가 출력하는 값에 대한 설명으로 옳은 것은?', '```java
public class Settings {
    int timeout = 0;            // 일반 필드, volatile 아님
    String host = null;         // 일반 필드, volatile 아님
}
```

```java
// main 스레드가 실행하는 코드
Settings s = new Settings();
s.timeout = 30;
s.host = "api.example.com";

Thread worker = new Thread(() -> System.out.println(s.timeout + " " + s.host));
worker.start();
```

main 스레드는 start() 이후 s의 어떤 필드도 다시 건드리지 않고, s를 건드리는 스레드도 worker 말고는 없다.', 'OBJECTIVE'),
       (5791, 935, '아래 표를 바탕으로 한 판단으로 옳지 않은 것은?', '| 호출 | 호출 위치 제약 | 대기 동안의 모니터 | 대기가 끝나는 계기 |
|---|---|---|---|
| obj.wait() | obj의 모니터를 쥔 상태 | 놓는다 | obj.notify()·obj.notifyAll()·시간 만료·인터럽트 |
| Thread.sleep(ms) | 없음 | 쥔 채 유지한다 | 시간 만료·인터럽트 |
| t.join() | 없음 | 쥔 채 유지한다 | t의 종료·시간 만료·인터럽트 |
| obj.notifyAll() | obj의 모니터를 쥔 상태 | 대기하지 않는다 | - |', 'OBJECTIVE'),
       (5792, 935, '아래 코드와 실행 기록에서 await()이 예외로 끝난 원인으로 옳은 것은?', '```java
public class Gate {
    private final Object lock = new Object();
    private boolean open = false;

    public void await() throws InterruptedException {
        while (!open) {
            lock.wait();                 // 조건이 될 때까지 대기
        }
    }

    public void open() {
        synchronized (lock) {
            open = true;
            lock.notifyAll();
        }
    }
}
```

```
[T1]   t=0.000s  await() 호출
[T1]   t=0.000s  java.lang.IllegalMonitorStateException 으로 종료
[main] t=1.000s  open() 호출, 정상 반환
```', 'OBJECTIVE'),
       (5793, 935, '아래 측정에서 구현 A에만 나타난 현상을 가리키는 용어는?', 'JDK 21. 요청마다 외부 API를 200ms 동안 호출하는 서버를 가상 스레드로 옮겼다. 캐리어 스레드는 8개다.

구현 A

```java
synchronized (lock) { callExternalApi(); }
```

```
동시 요청 10,000건
같은 시각에 진행 중인 API 호출: 8건을 넘지 못함
전체 처리 시간: 250초
```

구현 B

```java
lock.lock();                                             // ReentrantLock
try { callExternalApi(); } finally { lock.unlock(); }
```

```
같은 부하에서 같은 시각에 진행 중인 API 호출: 수천 건까지 올라감
전체 처리 시간: 4초
```

두 구현이 임계 영역 안에서 하는 일은 같다. 같은 코드를 플랫폼 스레드로 돌렸을 때는 A와 B의 처리 시간이 서로 비슷했다.', 'SUBJECTIVE'),
       (5794, 935, '아래 스레드 덤프가 가리키는 상태의 이름은?', '```java
public class Account {
    private final Object lock = new Object();
    private long balance;

    public void transferTo(Account to, long amount) {
        synchronized (this.lock) {
            synchronized (to.lock) {
                this.balance -= amount;
                to.balance += amount;
            }
        }
    }
}
```

```
스레드 T1: a.transferTo(b, 100) 호출
스레드 T2: b.transferTo(a, 50) 호출

60초 뒤 스레드 덤프
"T1" BLOCKED
   - locked <0x7a1> (a의 lock)
   - waiting to lock <0x7b2> (b의 lock)
"T2" BLOCKED
   - locked <0x7b2> (b의 lock)
   - waiting to lock <0x7a1> (a의 lock)

두 스레드는 프로세스를 강제로 끝낼 때까지 이 상태에서 벗어나지 못했다.
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5789
(15611, 5789, 'remaining에 volatile이 없어 한 스레드가 차감한 값이 다른 스레드의 검사에 반영되지 않은 탓이다.', '가시성으로 원인을 돌린 오해. remaining을 volatile로 바꿔도 검사를 통과한 뒤 차감하기까지의 틈은 그대로라 음수는 계속 나온다. 여기서 깨진 것은 가시성이 아니라 검사와 행동이 한 덩어리로 묶이지 않았다는 원자성이다.', false),
(15612, 5789, 'lock이 sell() 호출마다 새로 만들어져 스레드마다 서로 다른 모니터를 잡은 탓에 차감이 직렬화되지 않았다.', '락 객체의 생명주기를 잘못 본 오해. lock은 인스턴스의 final 필드라 TicketBooth 객체 하나당 하나뿐이고 20개 스레드가 그 객체를 공유한다. 모니터가 하나이므로 차감 자체는 제대로 직렬화되어 정확히 13번만 줄었다.', false),
(15613, 5789, '검사가 synchronized 블록 밖에 있어, 한 스레드가 검사를 통과한 뒤 차감하기 전에 다른 스레드들도 같은 검사를 통과했다.', '재고가 1일 때 여러 스레드가 함께 remaining > 0을 통과하면, 그 뒤 차감이 한 줄로 직렬화되더라도 통과한 수만큼 모두 실행된다. 검사와 행동을 같은 블록 안에 넣어야 막히는 전형적인 check-then-act 문제다.', true),
(15614, 5789, 'remaining-- 의 쓰기가 32비트씩 두 번으로 나뉘어, 절반만 갱신된 중간값이 필드에 남은 탓이다.', '찢어진 쓰기를 int에 갖다 붙인 오해. JMM이 둘로 쪼개질 수 있다고 허용하는 것은 volatile이 아닌 64비트 long과 double이고 int는 해당하지 않는다. -3도 중간값이 아니라 10에서 13번 차감된 정확한 결과다.', false),

-- 문제 5790
(15615, 5790, '두 필드 모두 start() 호출보다 앞에서 쓰였으므로, volatile도 락도 없이 worker는 30과 api.example.com을 본다.', 'JMM의 스레드 시작 규칙은 Thread.start() 호출 이전의 모든 동작을 그 스레드의 모든 동작보다 앞선 것으로 정한다. 그래서 start() 앞에서 채워 둔 값은 일반 필드라도 새 스레드에 그대로 보인다.', true),
(15616, 5790, '두 필드 어디에도 volatile이 없으므로 worker는 0과 null이 그대로 남은 값을 볼 수 있다.', 'volatile이 없으면 값이 언제나 안 보일 수 있다고 본 오해. 가시성은 volatile 말고도 happens-before가 성립하면 보장되며 스레드 시작이 바로 그런 규칙이다. 두 스레드가 나란히 돌며 값을 주고받는 상황이라면 이야기가 달라진다.', false),
(15617, 5790, 'main이 worker를 시작한 뒤 join()으로 종료를 기다려야만 두 쓰기가 worker에게 보인다.', 'join()도 happens-before 규칙이지만 방향이 반대다. 새 스레드가 한 쓰기를 기다린 쪽에 보이게 하는 규칙이라, 시작 전에 쓴 값을 새 스레드가 읽는 여기서는 시작 규칙이 이미 적용돼 join()이 필요 없다.', false),
(15618, 5790, '두 쓰기의 재배치 탓에 worker는 timeout만 30이고 host는 아직 null인 조합을 볼 수 있다.', '재배치를 걱정할 자리는 맞지만 경계가 어디에 서는지를 놓쳤다. start() 호출이 경계가 되어 그 앞의 쓰기들이 새 스레드의 시작 뒤로 밀려날 수 없으므로, 한쪽만 반영된 조합은 관찰되지 않는다.', false),

-- 문제 5791
(15619, 5791, '대기 중인 스레드에 인터럽트를 걸면 wait()·sleep()·join() 셋 다 대기를 끝내고 InterruptedException으로 빠져나온다.', '표의 마지막 열을 보면 세 호출 모두 대기가 끝나는 계기에 인터럽트가 들어 있다. 셋 다 검사 예외로 인터럽트를 알리도록 선언돼 있어, 대기를 외부에서 끊는 공통 수단이 된다는 점에서 참인 진술이다.', false),
(15620, 5791, '어떤 모니터도 잡지 않은 메서드에서 obj.notifyAll()을 호출하는 코드는 컴파일은 되지만 실행 중 예외로 끝난다.', '표의 호출 위치 제약 열대로 notifyAll()은 그 객체의 모니터를 쥔 스레드만 부를 수 있다. 이 제약은 문법이 아니라 실행 시점에 확인되므로 컴파일은 통과하고 IllegalMonitorStateException이 난다.', false),
(15621, 5791, 'wait()은 notify 호출 없이도 반환될 수 있으므로, 깨어난 뒤 조건을 다시 보지 않으면 조건이 거짓인 채로 진행할 수 있다.', '표의 마지막 열에는 notify 계열 말고도 시간 만료와 인터럽트가 함께 적혀 있다. 그래서 조건 검사는 if 한 번이 아니라 while로 두어 깨어날 때마다 다시 확인해야 하므로 참인 진술이다.', false),
(15622, 5791, '버퍼가 빌 때까지 기다리는 코드에서 wait() 대신 Thread.sleep()을 써도, 대기 동안 모니터가 풀려 다른 스레드가 같은 객체의 synchronized 메서드에서 버퍼를 채울 수 있다.', '표의 대기 동안의 모니터 열은 sleep()이 모니터를 쥔 채 유지한다고 적고 있어 거짓이다. 잠든 스레드가 락을 놓지 않으니 버퍼를 채우려는 스레드는 아예 진입하지 못하고, 둘 다 풀리지 않는 채로 멈춘다.', true),

-- 문제 5792
(15623, 5792, 'open 필드에 volatile이 없어 while 조건이 갱신된 값을 읽지 못한 탓이다.', '가시성으로 원인을 돌린 오해. 가시성이 문제라면 증상은 예외가 아니라 루프가 끝나지 않는 것이어야 한다. 기록을 보면 예외는 open()이 호출되기도 전인 t=0.000s에 났으므로 open 값이 보이고 말고는 원인이 아니다.', false),
(15624, 5792, 'await()이 lock의 모니터를 쥐지 않은 채 lock.wait()을 호출했기 때문이다.', 'wait()·notify()·notifyAll()은 그 객체의 모니터를 쥔 스레드만 호출할 수 있다. await()에는 synchronized가 없어 lock의 모니터 없이 불렀고, JVM은 이를 IllegalMonitorStateException으로 거절한다. open()은 블록 안이라 문제가 없다.', true),
(15625, 5792, 'wait()을 while 안에서 부르면 대기가 중첩되므로 조건 검사를 if로 바꿔야 한다.', 'while과 if를 거꾸로 본 오해. 시간 만료나 가짜 깨어남으로 조건이 거짓인 채 반환될 수 있어 조건은 오히려 while로 다시 검사해야 한다. 게다가 예외는 첫 반복의 wait() 호출에서 났으므로 반복 방식과는 무관하다.', false),
(15626, 5792, '깨워 줄 스레드가 아직 없는 시점에 wait()을 불러, 기다릴 상대가 없는 대기가 거부됐기 때문이다.', '깨워 줄 상대가 없으면 호출이 거부된다고 본 오해. 아무도 깨우지 않으면 wait()은 예외 없이 그저 계속 대기할 뿐이다. 기록에서도 open()은 1초 뒤에 정상 반환했고 예외는 그보다 앞서 났다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1886, 5793, '고정,피닝,핀닝,pinning,pinned,스레드 고정,캐리어 스레드 고정,캐리어 고정,가상 스레드 고정,virtual thread pinning', 'JDK 21의 가상 스레드는 블로킹 작업을 만나면 캐리어 스레드에서 내려와 다른 가상 스레드에게 자리를 내주도록 설계됐다. 그런데 synchronized 블록 안에서 블로킹하면 내려오지 못하고 캐리어 스레드를 붙든 채 남는데, 이것이 고정(pinning)이다. 구현 A에서 같은 시각에 진행 중인 호출이 캐리어 스레드 수인 8을 넘지 못한 것이 그 결과이고, 가상 스레드를 아무리 많이 만들어도 처리량이 8개 분량에 묶인다. ReentrantLock은 대기할 때 가상 스레드가 내려오도록 만들어져 있어 구현 B에서는 동시 진행 수가 수천 건까지 올라갔다. 플랫폼 스레드로 돌렸을 때 A와 B가 비슷했던 것도, 고정이 가상 스레드와 캐리어 스레드라는 구도에서만 생기는 문제임을 보여 준다. 헷갈리기 쉬운 옆 개념과 구분하면, 교착 상태는 서로 상대가 쥔 락을 기다려 아무도 나아가지 못하는 것이고 기아는 특정 스레드만 계속 자원을 얻지 못하는 것인데, 여기서는 모든 요청이 결국 정상 처리되지만 동시에 진행되는 수가 캐리어 스레드 수로 제한된다는 점이 다르다. 이 제약은 이후 JDK에서 개선되었으므로 쓰고 있는 버전의 릴리스 노트를 확인해야 한다.'),
       (1887, 5794, '교착 상태,교착상태,데드락,데드 락,deadlock,dead lock', 'T1은 a의 모니터를 쥔 채 b의 모니터를, T2는 b의 모니터를 쥔 채 a의 모니터를 기다린다. 덤프의 locked와 waiting to lock이 서로 엇갈려 대기가 순환을 이루고, 둘 다 자기가 쥔 락을 놓지 않으므로 외부에서 끊지 않는 한 영원히 풀리지 않는다. 이것이 교착 상태다. 원인은 transferTo()가 락을 잡는 순서를 호출한 쪽의 인스턴스에 맡겨 둔 데 있다. 계좌 번호처럼 모든 스레드가 같게 매기는 기준을 정해 늘 같은 순서로 락을 잡게 하거나, ReentrantLock의 tryLock으로 시한을 두고 실패하면 쥔 락을 모두 풀고 물러났다 다시 시도하면 순환이 끊어진다. 옆 개념과 구분하면, 기아는 다른 스레드들이 진행하는 동안 특정 스레드만 자원을 얻지 못하는 것이고 라이브락은 서로 양보하느라 계속 움직이면서도 진행이 없는 것인데, 여기서는 두 스레드가 모두 BLOCKED로 멈춰 선 채 서로의 락을 기다린다. 또 같은 스레드가 자기가 이미 쥔 모니터를 다시 요청하는 것은 재진입으로 허용되므로 교착 상태가 아니다.');
