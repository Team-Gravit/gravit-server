-- Unit: 예외 체계와 설계 (Unit ID: 190)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(946, 'JAVA', 190, 'HARD', true,
 'Repository 계층에서 JDBC의 SQLException이 발생할 때, 이를 서비스 계층까지 throws로 전파하는 방식의 문제는 무엇이고 어떻게 개선하시겠어요? 그 선택이 Spring @Transactional 롤백 동작과는 어떻게 연결되나요?',
 'SQLException은 Checked 예외라서 Repository에서 throws로 선언하면 이를 호출하는 서비스 계층 등 모든 중간 계층의 시그니처에도 throws가 번집니다. 그 결과 서비스 계층까지 JDBC라는 하위 기술에 종속되고, 서비스 계층이 SQLException을 노출하게 되어 추상화 수준에 맞지 않는 예외가 됩니다. 개선 방법은 하위 계층에서 SQLException을 잡아 DataAccessException 같은 상위 개념의 Unchecked 예외로 번역해 던지는 것입니다. 이렇게 하면 시그니처 오염 없이 상위로 자연스럽게 전파됩니다. 이때 번역하면서 반드시 원래 예외를 cause로 넘겨 원인 체이닝을 유지해야 원래 스택 트레이스가 보존되어 장애 원인을 추적할 수 있고, 메시지에는 어떤 id로 조회하다 실패했는지 같은 진단 정보를 담습니다. 이 선택은 Spring @Transactional과도 연결됩니다. @Transactional은 기본적으로 RuntimeException과 Error 같은 Unchecked 예외에서만 롤백하고 Checked 예외는 커밋합니다. 따라서 Checked 예외를 그대로 던지면 롤백이 안 되는 문제가 생길 수 있고, Unchecked 예외로 번역하면 기본 설정으로 롤백됩니다. Checked 예외에도 롤백이 필요하다면 rollbackFor 속성으로 조정해야 합니다.'),
(947, 'JAVA', 190, 'NORMAL', true,
 'Java의 Checked 예외와 Unchecked 예외는 어떻게 다르며, 어떤 기준으로 둘 중 하나를 선택하나요?',
 '둘의 구분은 RuntimeException 상속 여부입니다. Checked 예외는 Exception의 하위이면서 RuntimeException의 하위가 아닌 예외로, IOException, SQLException, InterruptedException 등이 있습니다. Unchecked 예외는 RuntimeException과 그 하위 클래스로, NullPointerException, IllegalArgumentException 등이 있습니다. Checked 예외는 컴파일러가 처리를 강제해서 호출자가 반드시 try-catch로 잡거나 throws로 선언해야 컴파일되고, Unchecked 예외는 선언과 처리 여부가 자유롭습니다. 선택 기준은 호출자가 예외를 받고 실질적으로 다른 행동을 할 수 있는지, 즉 합리적으로 복구할 수 있는 상황이면 Checked를 씁니다. 예를 들어 파일이 없으면 기본 설정으로 진행하는 경우입니다. 반면 프로그래밍 오류나 전제 조건 위반처럼 복구보다 수정이 답이고, 호출자가 할 수 있는 일이 로그를 남기고 실패 응답을 주는 것뿐이라면 Unchecked를 씁니다. 또한 Checked 예외는 함수형 인터페이스가 이를 선언하지 않아 람다·스트림에서 매우 불편합니다. 실무에서도 Spring, Hibernate 같은 현대 프레임워크는 대부분 Unchecked 계층을 채택합니다.'),
(948, 'JAVA', 190, 'NORMAL', true,
 'finally 블록에서 close()를 직접 호출해 자원을 해제하는 방식과 try-with-resources를 사용하는 방식은 어떤 차이가 있나요?',
 'finally에서 직접 close()를 호출하는 수동 해제 방식은 close() 전에 null 검사를 해야 해서 번거롭고, 무엇보다 finally의 close()에서 예외가 나면 try 블록에서 발생한 원래 예외를 덮어써서 원래 예외가 사라지는 문제가 있습니다. Java 7부터 도입된 try-with-resources는 AutoCloseable을 구현한 자원을 try 괄호 안에 선언하면 블록이 끝날 때 자동으로 close()를 호출해 줍니다. 여러 자원을 선언하면 선언 순서의 역순으로 닫힙니다. 그리고 close()에서 발생한 예외는 원래 예외의 억제된 예외(suppressed)로 첨부되기 때문에 유실되지 않으며, getSuppressed()로 꺼내 확인할 수 있습니다. 따라서 원래 예외도 보존하고 close 중 발생한 예외도 잃지 않는다는 점이 핵심 차이입니다.'),
(949, 'JAVA', 190, 'EASY', true,
 'Java에서 예외 처리 비용이 크다고 하는데, 비용이 주로 어디서 발생하며 이 때문에 예외를 어떻게 사용해야 하나요?',
 '예외는 던질 때보다 만들 때 비쌉니다. 예외 객체를 생성하면 Throwable 생성자가 fillInStackTrace()를 호출해 현재 스레드의 전체 스택 프레임을 순회하며 스택 트레이스를 캡처하는데, 이것이 주된 비용이고 호출 깊이가 깊을수록 비용이 커집니다. 반면 정상 경로에서 try 블록에 진입하는 것 자체에는 비용이 거의 없습니다. JVM이 예외 테이블로 처리하기 때문입니다. 단순 반환에 비해 예외 생성과 던지기는 수백~수천 배 느릴 수 있으므로, 반복 종료나 존재 여부 확인처럼 정상적인 제어 흐름에 예외를 쓰면 안 되고 조건 검사나 Optional 같은 API를 써야 합니다. 핵심은 예외를 쓰지 말라는 게 아니라 파일 없음, 네트워크 단절 같은 예외적인 상황에만 쓰라는 것입니다. 정말 필요하면 fillInStackTrace()를 재정의해 this를 반환하거나 writableStackTrace=false로 생성해 비용을 줄일 수 있지만, 스택 트레이스가 없으면 장애 원인 추적이 불가능하므로 진짜 오류에는 적용하지 않습니다.'),
(950, 'JAVA', 190, 'EASY', true,
 'Java 예외 클래스 계층 구조를 설명하고, Error와 Exception의 차이를 말씀해 주세요.',
 'Java의 예외는 Throwable을 뿌리로 하는 클래스 계층입니다. Throwable 아래는 Error와 Exception 두 갈래로 나뉩니다. Error는 OutOfMemoryError, StackOverflowError, NoClassDefFoundError처럼 메모리 부족이나 스택 오버플로 같은 JVM 수준의 심각한 문제로, 프로그램이 복구할 수 없는 상황이므로 잡아서 복구하지 않습니다. 그래서 catch (Throwable t)로 Error까지 삼키면 안 됩니다. Exception은 애플리케이션이 처리할 수 있는 문제를 나타내며, 그 하위 중 RuntimeException과 그 하위 클래스는 컴파일러가 처리를 강제하지 않는 Unchecked 예외이고, 나머지인 IOException, SQLException 등은 처리를 강제하는 Checked 예외입니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 946
(5108, 946, 'Checked 예외를 throws로 전파하면 모든 중간 계층 시그니처에 throws가 번진다는 문제를 언급', 'ESSENTIAL', 1),
(5109, 946, 'SQLException을 DataAccessException 같은 Unchecked 예외로 번역해 던지는 방식을 제시', 'ESSENTIAL', 2),
(5110, 946, '@Transactional은 기본적으로 Unchecked 예외에서만 롤백하고 Checked 예외는 커밋함을 언급', 'ESSENTIAL', 3),
(5111, 946, '예외를 번역할 때 cause를 넘겨 원래 스택 트레이스를 보존해야 함을 언급', 'SUPPLEMENTARY', 4),
(5112, 946, 'Checked 예외에도 롤백하려면 rollbackFor 속성을 지정해야 함을 언급', 'SUPPLEMENTARY', 5),
(5113, 946, '서비스 계층이 JDBC 같은 하위 기술에 종속되는 것을 추상화 수준 문제로 서술', 'SUPPLEMENTARY', 6),

-- 질문 947
(5114, 947, 'Checked와 Unchecked가 RuntimeException 상속 여부로 나뉜다는 점을 언급', 'ESSENTIAL', 1),
(5115, 947, 'Checked 예외는 컴파일러가 catch 또는 throws 처리를 강제한다는 점을 언급', 'ESSENTIAL', 2),
(5116, 947, '호출자가 합리적으로 복구할 수 있는 상황이면 Checked를 쓴다는 기준을 제시', 'ESSENTIAL', 3),
(5117, 947, '프로그래밍 오류·전제 조건 위반·복구 불가 중 최소 1개를 Unchecked 선택 기준으로 제시', 'ESSENTIAL', 4),
(5118, 947, '함수형 인터페이스가 Checked 예외를 선언하지 않아 람다·스트림에서 불편함을 언급', 'SUPPLEMENTARY', 5),
(5119, 947, 'Spring·Hibernate 등 현대 프레임워크가 대부분 Unchecked 계층을 채택함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 948
(5120, 948, '수동 해제 시 finally의 close() 예외가 try에서 발생한 원래 예외를 덮어쓴다는 문제를 언급', 'ESSENTIAL', 1),
(5121, 948, 'try-with-resources는 AutoCloseable 자원의 close()를 블록 종료 시 자동 호출함을 언급', 'ESSENTIAL', 2),
(5122, 948, 'close()에서 발생한 예외가 억제된 예외(suppressed)로 첨부되어 유실되지 않음을 언급', 'ESSENTIAL', 3),
(5123, 948, 'try-with-resources의 자원이 선언 순서의 역순으로 닫힌다는 점을 언급', 'SUPPLEMENTARY', 4),
(5124, 948, '수동 해제 방식은 close() 전에 null 검사가 필요해 번거롭다는 점을 언급', 'SUPPLEMENTARY', 5),

-- 질문 949
(5125, 949, '예외 객체를 생성할 때 스택 트레이스를 캡처하는 것이 주된 비용임을 언급', 'ESSENTIAL', 1),
(5126, 949, '정상적인 제어 흐름에 예외를 쓰면 안 되고 예외적인 상황에만 써야 함을 언급', 'ESSENTIAL', 2),
(5127, 949, '스택 트레이스 캡처를 수행하는 메서드로 fillInStackTrace()를 명시', 'SUPPLEMENTARY', 3),
(5128, 949, '스택 트레이스 캡처 비용이 호출 깊이가 깊을수록 커짐을 언급', 'SUPPLEMENTARY', 4),
(5129, 949, 'fillInStackTrace() 재정의나 writableStackTrace=false 중 최소 1개를 비용 절감법으로 제시', 'SUPPLEMENTARY', 5),

-- 질문 950
(5130, 950, 'Throwable을 뿌리로 Error와 Exception 두 갈래로 나뉘는 계층을 설명', 'ESSENTIAL', 1),
(5131, 950, 'Error는 JVM 수준의 복구할 수 없는 문제라 잡아서 복구하지 않는다는 점을 언급', 'ESSENTIAL', 2),
(5132, 950, 'Exception은 애플리케이션이 처리할 수 있는 문제임을 언급', 'ESSENTIAL', 3),
(5133, 950, 'OutOfMemoryError·StackOverflowError 중 최소 1개를 Error의 예로 제시', 'SUPPLEMENTARY', 4),
(5134, 950, 'catch (Throwable)로 Error까지 삼키면 안 된다는 점을 언급', 'SUPPLEMENTARY', 5);
