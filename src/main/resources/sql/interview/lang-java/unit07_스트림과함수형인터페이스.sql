-- Unit: 스트림과 함수형 인터페이스 (Unit ID: 192)
-- Chapter: Java (Chapter ID: 18)
-- Topic: JAVA
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-java-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(956, 'JAVA', 192, 'HARD', true,
 '여러 사용자의 프로필을 외부 HTTP API로 조회하는 코드를 빠르게 만들려고 parallelStream()을 적용하려 합니다. 이 선택에는 어떤 문제가 있고, 어떻게 개선해야 하나요?',
 'parallelStream()은 Spliterator로 데이터를 분할해 ForkJoinPool.commonPool()의 워커 스레드에 분배하는데, 이 commonPool은 JVM 전체에서 하나를 공유하고 모든 병렬 스트림과 CompletableFuture 기본 실행이 함께 씁니다. 기본 크기도 CPU 코어 수 - 1 정도라서, HTTP 호출처럼 네트워크 대기가 있는 블로킹 I/O를 병렬 스트림 안에서 수행하면 워커들이 대기에 묶여 풀이 고갈되고, 같은 풀을 쓰는 다른 작업까지 지연되어 애플리케이션 전체가 느려질 수 있습니다. 그래서 병렬 스트림은 CPU 연산 전용으로 쓰고, 블로킹 I/O는 Executors.newFixedThreadPool 같은 전용 스레드 풀(ExecutorService)로 분리해 처리해야 합니다. 구체적으로는 이 전용 스레드 풀을 CompletableFuture.supplyAsync에 넘겨 각 호출을 비동기로 실행하고, join으로 결과를 모으는 방식으로 개선할 수 있습니다. 병렬 스트림은 분할이 쉬운 소스, CPU 바운드 연산, 충분한 데이터, 부수 효과 없음이라는 조건을 모두 만족할 때만 고려하고, 하나라도 빠지면 순차 스트림이 낫습니다.',
 'interview-question/956.mp3'),
(957, 'JAVA', 192, 'NORMAL', true,
 '스트림의 중간 연산 중 상태 없는 연산과 상태 있는 연산은 어떻게 다르고, 이 차이 때문에 파이프라인의 연산 배치 순서는 어떻게 가져가야 하나요?',
 'filter, map, flatMap 같은 무상태 중간 연산은 원소 하나씩 독립적으로 처리할 수 있어서, 원소가 파이프라인을 하나씩 통과하는 지연 평가의 흐름을 그대로 유지합니다. 반면 sorted, distinct, limit, skip 같은 상태 있는 연산은 이전 원소 정보가 필요하므로 전체 또는 일부 원소를 버퍼링해야 하고, 특히 sorted()나 distinct()는 배리어가 됩니다. 예를 들어 sorted().findFirst()는 모든 원소를 받아 전체를 정렬한 뒤에야 첫 원소를 내고, 무한 스트림에 sorted()를 걸면 끝나지 않습니다. 그래서 지연 평가의 이점을 살리려면 filter나 limit을 가능한 앞쪽에 두어 상태 있는 연산이 처리할 원소 수를 줄이는 방향으로 배치해야 합니다.',
 'interview-question/957.mp3'),
(958, 'JAVA', 192, 'NORMAL', true,
 '람다식은 익명 클래스와 비교해 어떤 차이가 있고, 람다가 지역 변수를 캡처할 때는 어떤 제약이 있나요?',
 '람다는 익명 클래스와 달리 this가 바깥 인스턴스를 가리킵니다. 또 익명 클래스와 달리 람다는 클래스 파일을 생성하지 않으며, 대신 invokedynamic으로 런타임에 구현체를 만듭니다. 지역 변수 캡처에는 제약이 있어서, 람다가 캡처하는 지역 변수는 effectively final, 즉 사실상 final이어야 합니다. 람다는 캡처한 값을 복사해 가지며, 변수가 있던 스택 프레임이 사라진 뒤에도 실행될 수 있기 때문입니다.',
 'interview-question/958.mp3'),
(959, 'JAVA', 192, 'EASY', true,
 '자바 스트림의 지연 평가(Lazy Evaluation)란 무엇이고, 실제로 원소가 어떤 순서로 처리되나요?',
 '지연 평가는 중간 연산이 "무엇을 할지"만 기록해 두고, 최종 연산이 호출되기 전까지는 실제로 실행되지 않는 방식입니다. 예를 들어 peek와 map만 연결해 두면 아무것도 출력되지 않다가 toList() 같은 최종 연산을 호출하는 순간 파이프라인이 한 번에 융합되어 실행됩니다. 처리 순서도 1단계를 모든 원소에 적용한 뒤 2단계로 가는 것이 아니라, 원소 하나가 파이프라인을 끝까지 통과한 뒤 다음 원소를 처리하는 수직 처리 방식입니다. 이 덕분에 findFirst, anyMatch, limit 같은 단락 연산은 결과가 확정되면 나머지 원소를 처리하지 않아 불필요한 계산을 생략하고, Stream.iterate 같은 무한 스트림도 limit이나 findFirst와 결합하면 정상 동작합니다.',
 'interview-question/959.mp3'),
(960, 'JAVA', 192, 'EASY', true,
 '함수형 인터페이스란 무엇이며, 람다식과는 어떤 관계인가요?',
 '함수형 인터페이스는 추상 메서드가 정확히 하나인 인터페이스이고, 람다식은 이 함수형 인터페이스의 인스턴스로 컴파일됩니다. 즉 람다는 그 하나뿐인 추상 메서드의 구현체 역할을 하며, 이를 통해 동작(코드)을 값처럼 전달할 수 있습니다. @FunctionalInterface 어노테이션을 붙이면 추상 메서드가 둘 이상일 때 컴파일 오류로 잡아 줍니다. 대표적으로 값을 생산하는 Supplier, 값을 소비하는 Consumer, 값을 변환하는 Function, 조건을 판정하는 Predicate 같은 표준 함수형 인터페이스가 있습니다.',
 'interview-question/960.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 956
(5162, 956, '병렬 스트림이 JVM 전체에서 공유하는 ForkJoinPool.commonPool을 사용함을 언급', 'ESSENTIAL', 1),
(5163, 956, '워커 스레드가 블로킹 I/O 대기에 묶이면 commonPool이 고갈되어 다른 작업까지 지연됨을 설명', 'ESSENTIAL', 2),
(5164, 956, '블로킹 I/O는 병렬 스트림 대신 전용 스레드 풀(ExecutorService)로 분리해 처리하는 대안을 제시', 'ESSENTIAL', 3),
(5165, 956, 'commonPool의 기본 크기가 CPU 코어 수 - 1임을 언급', 'SUPPLEMENTARY', 4),
(5166, 956, '분할이 쉬운 소스·CPU 바운드 연산·충분한 데이터·부수 효과 없음 중 최소 2개를 병렬 스트림 사용 조건으로 제시', 'SUPPLEMENTARY', 5),
(5167, 956, 'CompletableFuture.supplyAsync에 전용 스레드 풀을 넘겨 비동기로 호출하는 방식을 제시', 'SUPPLEMENTARY', 6),

-- 질문 957
(5168, 957, 'filter·map 같은 무상태 연산은 원소 하나씩 독립적으로 처리 가능함을 설명', 'ESSENTIAL', 1),
(5169, 957, 'sorted·distinct 같은 상태 있는 연산은 이전 원소 정보가 필요해 원소를 버퍼링함을 설명', 'ESSENTIAL', 2),
(5170, 957, 'filter·limit을 파이프라인의 가능한 앞쪽에 두어 처리량을 줄여야 함을 제시', 'ESSENTIAL', 3),
(5171, 957, 'sorted().findFirst()는 전체를 정렬한 뒤에야 첫 원소를 낸다는 배리어 동작을 언급', 'SUPPLEMENTARY', 4),
(5172, 957, '무한 스트림에 sorted()를 걸면 끝나지 않음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 958
(5173, 958, '람다의 this는 익명 클래스와 달리 바깥 인스턴스를 가리킴을 설명', 'ESSENTIAL', 1),
(5174, 958, '클래스 파일을 생성하지 않음·invokedynamic으로 런타임에 구현체를 만듦 중 최소 1개를 익명 클래스와의 차이로 제시', 'ESSENTIAL', 2),
(5175, 958, '람다가 캡처하는 지역 변수는 effectively final이어야 함을 언급', 'ESSENTIAL', 3),
(5176, 958, '람다가 값을 복사해 가지며 스택 프레임이 사라진 뒤에도 실행될 수 있다는 점을 캡처 제약의 이유로 제시', 'SUPPLEMENTARY', 4),

-- 질문 959
(5177, 959, '중간 연산은 최종 연산이 호출되기 전까지 실행되지 않음을 설명', 'ESSENTIAL', 1),
(5178, 959, '원소 하나가 파이프라인을 끝까지 통과한 뒤 다음 원소를 처리하는 방식을 설명', 'ESSENTIAL', 2),
(5179, 959, 'findFirst 같은 단락 연산은 결과가 확정되면 나머지 원소를 처리하지 않음을 설명', 'SUPPLEMENTARY', 3),
(5180, 959, '지연 평가 덕분에 무한 스트림도 limit·findFirst와 결합하면 정상 동작함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 960
(5181, 960, '함수형 인터페이스는 추상 메서드가 정확히 하나인 인터페이스임을 언급', 'ESSENTIAL', 1),
(5182, 960, '람다식은 함수형 인터페이스의 인스턴스로 컴파일됨을 언급', 'ESSENTIAL', 2),
(5183, 960, '@FunctionalInterface를 붙이면 추상 메서드가 둘 이상일 때 컴파일 오류로 잡아 줌을 언급', 'SUPPLEMENTARY', 3),
(5184, 960, 'Supplier·Consumer·Function·Predicate 중 최소 2개를 표준 함수형 인터페이스 예시로 제시', 'SUPPLEMENTARY', 4);
