-- Unit: 자바 상호운용 (Unit ID: 204)
-- Chapter: Kotlin (Chapter ID: 19)
-- Topic: KOTLIN
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-kotlin-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1016, 'KOTLIN', 204, 'HARD', true,
 'Kotlin으로 작성한 라이브러리를 자바 팀이 사용한다고 할 때, companion object의 함수, 기본 인자가 있는 함수, suspend 함수를 자바에서 호출하면 각각 어떤 문제가 생기고 어떻게 개선할 수 있나요?',
 'companion object에 선언한 함수는 자바 관점에서 진짜 static이 아니라 Companion 객체를 경유하므로, @JvmStatic을 붙이지 않으면 자바에서 Money.Companion.zero()처럼 어색하게 호출됩니다. 여기에 @JvmStatic을 붙이면 자바에서 Money.zero()처럼 static 메서드로 호출할 수 있습니다. 기본 인자가 있는 함수는 자바에 전체 인자를 넘기는 오버로드 하나만 노출됩니다. @JvmOverloads를 붙이면 기본 인자마다 자바용 오버로드가 생성되어 format(), format("ko"), format("ko", true)처럼 호출할 수 있습니다. suspend 함수는 자바에서 마지막 파라미터로 Continuation이 추가된 메서드, 예를 들어 Object load(Continuation<? super User> c)로 보이는데, 자바가 Continuation을 직접 구현하는 것은 비현실적입니다. 그래서 자바 호출자를 위해 kotlinx-coroutines-jdk8의 future 빌더로 CompletableFuture를 반환하는 래퍼나 runBlocking을 쓰는 블로킹 래퍼를 별도로 제공하는 것이 일반적입니다. 다만 블로킹 래퍼는 호출 스레드를 점유하므로 요청 처리 스레드에서는 지양해야 합니다.'),
(1017, 'KOTLIN', 204, 'NORMAL', true,
 '자바 SAM 인터페이스, Kotlin 일반 인터페이스, Kotlin fun interface는 Kotlin에서 람다를 전달할 때 어떤 차이가 있나요?',
 'SAM은 추상 메서드가 하나뿐인 인터페이스를 말합니다. Runnable이나 Comparator 같은 자바 SAM 인터페이스를 받는 자리에는 Kotlin 람다를 직접 넘기면 자동으로 변환되고, 변수에 담을 때처럼 대상 타입을 명시하려면 Runnable { } 같은 SAM 생성자를 씁니다. 반면 Kotlin에서 선언한 일반 인터페이스는 추상 메서드가 하나여도 SAM 변환이 적용되지 않습니다. Kotlin에는 (A) -> B 같은 함수 타입이 있으므로 굳이 인터페이스로 만들 이유가 없다는 설계 판단 때문입니다. 그래서 일반 인터페이스는 Kotlin에서 람다를 넘길 수 없고 object 표현식으로 구현해야 합니다. 람다로 받고 싶은 Kotlin 인터페이스는 fun interface로 선언하면 Validator { it.isNotBlank() }처럼 람다로 생성할 수 있고, 자바에서도 함수형 인터페이스로 사용할 수 있어 양쪽에서 가장 매끄럽습니다.'),
(1018, 'KOTLIN', 204, 'NORMAL', true,
 'Kotlin이 자바 메서드의 반환 타입을 읽을 때 널 어노테이션 유무에 따라 어떻게 다르게 처리하는지, 그리고 JSR-305와 JSpecify 어노테이션의 처리 방식은 어떻게 다른지 설명해 주세요.',
 '자바 코드에 널 어노테이션이 없으면 Kotlin은 그 타입을 플랫폼 타입 T!으로 받아들여 널 가능 여부를 알 수 없는 상태로 둡니다. 반대로 널 어노테이션이 있고 Kotlin이 이를 인식하면 플랫폼 타입 대신 일반 널 가능 타입이나 널 불가 타입으로 읽어 컴파일 시점 검사를 적용합니다. 어노테이션 계열마다 처리 강도가 다른데, javax.annotation 패키지의 JSR-305는 기본적으로 경고만 내고 -Xjsr305=strict 옵션을 주어야 에러로 승격되며, Spring 5~6가 이 계열을 사용합니다. JSpecify는 @NullMarked로 범위 전체를 널 불가 기본으로 지정하고 @Nullable로 예외를 표시하는 방식이며, Kotlin 2.1부터 strict 모드가 기본이라 findOrNull의 User? 반환값을 User에 대입하면 컴파일 에러가 납니다. Spring Framework 7과 Spring Boot 4처럼 최근 프레임워크는 JSR-305에서 JSpecify로 이전하는 추세이므로, 사용하는 라이브러리의 어노테이션 계열과 Kotlin 버전의 strict 처리 여부를 빌드 로그 경고로 확인해야 합니다.'),
(1019, 'KOTLIN', 204, 'EASY', true,
 '자바 클래스의 getter/setter와 배열 타입은 Kotlin에서 호출할 때 어떤 형태로 보이나요?',
 '자바의 getName()/setName() 같은 getter/setter 쌍은 Kotlin에서 name 프로퍼티로 접근됩니다. 그래서 p.name = "kim"이라고 쓰면 setName("kim")이 호출됩니다. boolean isActive() 형태의 게터는 isActive 이름 그대로 프로퍼티처럼 사용합니다. 배열은 자바 int[]가 Kotlin의 IntArray로, Integer[]는 Array<Int>로 대응되므로 intArrayOf로 만든 배열을 Arrays.sort에 그대로 넘길 수 있습니다. 자바의 가변 인자 자리에 배열을 넘길 때는 스프레드 연산자 *로 배열을 펼쳐 전달합니다.'),
(1020, 'KOTLIN', 204, 'EASY', true,
 'Kotlin 파일에 선언한 최상위 함수는 자바에서 어떻게 호출되며, Kotlin 함수가 던지는 IOException을 자바에서 catch하려면 무엇이 필요한가요?',
 'Utils.kt 같은 파일에 선언한 최상위 함수는 자바에서 파일명 뒤에 Kt가 붙은 UtilsKt 클래스의 static 메서드로 보이므로 UtilsKt.fn()처럼 호출합니다. 파일 상단에 @file:JvmName("StringUtils")처럼 지정하면 자바에서 보이는 클래스 이름을 바꿔 StringUtils.capitalizeFirst("a")처럼 호출할 수 있습니다. 예외를 던지는 Kotlin 함수는 자바에서 볼 때 throws 선언이 없는 형태로 보이고, 그래서 자바에서 그 예외를 catch하면 컴파일 에러가 납니다. Kotlin은 검사 예외를 강제하지 않으므로, 자바에서 IOException을 catch하려면 Kotlin 함수에 @Throws(IOException::class)를 붙여야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1016
(5473, 1016, '@JvmStatic을 붙이면 companion 멤버를 자바에서 static 메서드로 호출할 수 있음을 설명', 'ESSENTIAL', 1),
(5474, 1016, '@JvmOverloads가 기본 인자마다 자바용 오버로드를 생성함을 설명', 'ESSENTIAL', 2),
(5475, 1016, 'suspend 함수가 자바에서 마지막 파라미터로 Continuation이 추가된 메서드로 보임을 언급', 'ESSENTIAL', 3),
(5476, 1016, '자바 호출자를 위해 CompletableFuture 또는 블로킹 래퍼를 별도로 제공하는 방법을 제시', 'ESSENTIAL', 4),
(5477, 1016, '@JvmStatic이 없는 companion 멤버는 자바에서 Money.Companion.zero()처럼 Companion 경유로 호출됨을 언급', 'SUPPLEMENTARY', 5),
(5478, 1016, '기본 인자 함수가 자바에 전체 인자를 넘기는 오버로드 하나만 노출됨을 언급', 'SUPPLEMENTARY', 6),
(5479, 1016, 'runBlocking 블로킹 래퍼는 호출 스레드를 점유해 요청 처리 스레드에서는 지양함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 1017
(5480, 1017, '자바 SAM 인터페이스 자리에는 Kotlin 람다를 넘기면 자동으로 변환됨을 설명', 'ESSENTIAL', 1),
(5481, 1017, 'Kotlin 일반 인터페이스는 추상 메서드가 하나여도 SAM 변환이 적용되지 않음을 언급', 'ESSENTIAL', 2),
(5482, 1017, '람다로 받을 Kotlin 인터페이스는 fun interface로 선언해야 함을 제시', 'ESSENTIAL', 3),
(5483, 1017, 'Kotlin에는 함수 타입이 있어 일반 인터페이스에 SAM 변환을 두지 않았다는 설계 이유를 언급', 'SUPPLEMENTARY', 4),
(5484, 1017, '일반 인터페이스는 Kotlin에서 람다 대신 object 표현식으로 구현해야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1018
(5485, 1018, '널 어노테이션이 없는 자바 타입은 플랫폼 타입 T!로 들어옴을 언급', 'ESSENTIAL', 1),
(5486, 1018, '널 어노테이션이 인식되면 일반 널 가능·널 불가 타입으로 읽혀 컴파일 시점 검사가 적용됨을 설명', 'ESSENTIAL', 2),
(5487, 1018, 'JSR-305 어노테이션은 기본적으로 경고만 발생시킴을 언급', 'ESSENTIAL', 3),
(5488, 1018, 'JSpecify는 Kotlin 2.1부터 strict 모드가 기본이라 위반 시 컴파일 에러가 남을 언급', 'ESSENTIAL', 4),
(5489, 1018, '-Xjsr305=strict 옵션으로 JSR-305 위반을 에러로 승격할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(5490, 1018, 'JSpecify의 @NullMarked가 범위 전체를 널 불가 기본으로 지정함을 언급', 'SUPPLEMENTARY', 6),
(5491, 1018, 'Spring Framework 7 등 최근 프레임워크가 JSR-305에서 JSpecify로 이전하는 추세를 언급', 'SUPPLEMENTARY', 7),

-- 질문 1019
(5492, 1019, '자바 getName()/setName() 쌍이 Kotlin에서 name 프로퍼티로 접근됨을 설명', 'ESSENTIAL', 1),
(5493, 1019, 'int[]→IntArray, Integer[]→Array<Int> 중 최소 1개의 배열 대응을 제시', 'ESSENTIAL', 2),
(5494, 1019, 'boolean isActive() 게터는 isActive 이름 그대로 사용됨을 언급', 'SUPPLEMENTARY', 3),
(5495, 1019, '자바 가변 인자에 배열을 넘길 때 스프레드 연산자 *를 사용함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 1020
(5496, 1020, '최상위 함수가 자바에서 파일명+Kt 클래스의 static 메서드로 호출됨을 설명', 'ESSENTIAL', 1),
(5497, 1020, '자바에서 예외를 catch하려면 Kotlin 함수에 @Throws(IOException::class)가 필요함을 제시', 'ESSENTIAL', 2),
(5498, 1020, '@file:JvmName으로 자바에서 보이는 클래스 이름을 지정할 수 있음을 언급', 'SUPPLEMENTARY', 3),
(5499, 1020, '@Throws가 없으면 throws 선언이 없어 자바의 catch가 컴파일 에러가 됨을 설명', 'SUPPLEMENTARY', 4);
