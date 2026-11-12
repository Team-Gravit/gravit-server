-- Unit: 네트워크 계층 (Unit ID: 99)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(491, 'AOS_COMMON', 99, 'HARD', true,
 '서버에 데이터를 생성하는 POST 요청이 타임아웃으로 실패했을 때, 앱에서 재시도를 어떻게 설계해야 하는지 OkHttp의 기본 재시도 동작과 연결해 설명해 주세요.',
 'OkHttp는 retryOnConnectionFailure(true) 기본 설정으로 커넥션 수립 실패나 풀에서 꺼낸 죽은 커넥션처럼 요청이 서버에 도달하지 않았다고 확신할 수 있는 경우만 조용히 재시도합니다. HTTP 5xx나 타임아웃 후에는 요청이 서버에 도달했을 수 있기 때문에 자동으로 재시도하지 않고, 멱등성은 개발자가 판단해야 합니다. 타임아웃이 난 POST는 서버 도달 여부가 불명이라 그대로 재시도하면 중복 생성 위험이 있으므로 기본은 재시도하지 않습니다. POST는 멱등성이 보장될 때만 재시도할 수 있고, 예를 들어 서버가 멱등성 키(Idempotency-Key)를 지원하면 POST도 안전하게 재시도할 수 있습니다. 애플리케이션 레벨에서 재시도할 때는 지수 백오프와 지터를 적용해 서버 복구 중 동시 폭주를 막습니다. 반면 400·404·422 같은 클라이언트 오류는 같은 요청이 같은 실패를 내므로 재시도하지 않습니다.',
 'interview-question/491.mp3'),
(492, 'AOS_COMMON', 99, 'NORMAL', true,
 '안드로이드에서 OkHttp와 Retrofit을 함께 쓸 때 두 라이브러리의 역할은 어떻게 다른가요?',
 'OkHttp는 실제 소켓을 열고 바이트를 보내는 HTTP 클라이언트로, 커넥션 풀과 Keep-Alive, TLS, HTTP/2, 캐시, 타임아웃, 인터셉터를 담당합니다. Retrofit은 OkHttp 위에서 동작하는 타입 안전 REST 어댑터로, 인터페이스 메서드를 URL·HTTP 메서드·파라미터로 매핑해 HTTP 요청으로 번역하고, Moshi 같은 컨버터로 JSON 직렬화를 처리하며 suspend 함수 같은 코루틴 지원을 제공합니다. 그래서 Retrofit이 네트워크 통신을 한다는 표현은 부정확하고, 타임아웃·인터셉터·재시도 같은 통신 설정은 전부 OkHttp에 두고 Retrofit에는 Base URL과 컨버터, 호출 어댑터를 설정합니다. Retrofit은 OkHttp에 의존하므로 OkHttp 없이는 동작할 수 없고, 반대로 OkHttp만으로도 통신은 가능하지만 보일러플레이트가 크게 늘어납니다. 또 OkHttpClient와 Retrofit은 앱 전체에서 하나만 만들어 공유해야 커넥션 풀과 스레드 풀이 매번 생성되는 낭비를 막을 수 있습니다.',
 'interview-question/492.mp3'),
(493, 'AOS_COMMON', 99, 'NORMAL', true,
 'OkHttp에서 addInterceptor로 등록하는 애플리케이션 인터셉터와 addNetworkInterceptor로 등록하는 네트워크 인터셉터는 어떤 차이가 있나요?',
 'OkHttp의 인터셉터는 체인으로 연결되고, 각 인터셉터가 chain.proceed(request)를 호출해 다음 단계로 넘깁니다. addInterceptor로 등록한 애플리케이션 인터셉터는 OkHttp 코어의 재시도·리다이렉트·캐시·커넥션 처리보다 바깥에 있어서, 리다이렉트나 재시도와 무관하게 요청당 정확히 1회 호출되고 앱이 만든 원본 요청과 최종 응답을 봅니다. 반면 addNetworkInterceptor로 등록한 네트워크 인터셉터는 실제 네트워크 왕복마다 호출되므로 리다이렉트가 일어나면 여러 번 호출되고, OkHttp가 헤더를 추가한 실제 전송 요청과 압축된 원본 응답을 볼 수 있습니다. 캐시된 응답은 네트워크를 타지 않으므로 애플리케이션 인터셉터는 호출되지만 네트워크 인터셉터는 호출되지 않습니다. 그래서 인증 헤더, 공통 파라미터, 로깅, 재시도 로직은 애플리케이션 인터셉터에 두고, 전송 바이트 분석 같은 네트워크 레벨 진단은 네트워크 인터셉터에 둡니다.',
 'interview-question/493.mp3'),
(494, 'AOS_COMMON', 99, 'EASY', true,
 'OkHttp의 Authenticator는 무엇이고, 액세스 토큰이 만료되었을 때 어떻게 동작하는지 설명해 주세요.',
 'Authenticator는 Interceptor와 별도로 OkHttp가 제공하는 훅으로, 401 응답을 받았을 때만 호출됩니다. 액세스 토큰이 만료되어 401이 오면 authenticate 안에서 토큰을 갱신하고, 새 토큰을 Authorization 헤더에 넣은 새 요청을 반환합니다. 그러면 OkHttp가 그 요청으로 자동으로 재요청합니다. priorResponse를 따라 응답 횟수를 세어 2회 이상이면 null을 반환하는 식으로 무한 갱신 루프를 방지합니다. 또 여러 요청이 동시에 401을 받으면 토큰 갱신이 병렬로 여러 번 일어나 서버가 이전 리프레시 토큰을 무효화할 수 있으므로, synchronized나 Mutex로 갱신을 직렬화하고 락을 얻은 뒤 다른 스레드가 이미 갱신했는지 다시 확인해야 합니다.',
 'interview-question/494.mp3'),
(495, 'AOS_COMMON', 99, 'EASY', true,
 'Retrofit 호출에서 발생한 네트워크 오류를 ViewModel까지 전달할 때 Repository에서 어떻게 처리하는지 설명해 주세요.',
 'Retrofit 호출의 실패는 Repository 경계에서 NetworkError 같은 sealed interface로 정의한 도메인 오류 타입으로 변환합니다. 목적은 ViewModel 같은 상위 계층이 HTTP 세부 사항을 모르게 하는 것입니다. 예를 들어 safeApiCall로 호출을 감싸 결과를 Result로 반환하면서, 4xx·5xx인 HttpException은 상태 코드를 담은 Http 오류로, SocketTimeoutException은 Timeout으로, UnknownHost 같은 IOException은 NoConnection으로 매핑합니다. 이때 CancellationException은 catch로 삼키면 화면이 닫혀도 코루틴이 끝나지 않고 사라진 UI에 결과를 전달하려 하므로 반드시 다시 던집니다. 참고로 HttpException은 T를 직접 반환할 때만 발생하고, Response<T>를 반환하면 isSuccessful과 errorBody()로 직접 분기합니다. 오프라인 판단은 예외에만 의존하지 않고 ConnectivityManager의 네트워크 콜백으로 사전 상태를 확인해 오프라인 배너를 띄우는 편이 사용자 경험이 좋습니다.',
 'interview-question/495.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 491
(2633, 491, 'OkHttp는 타임아웃 후에는 요청을 자동으로 재시도하지 않음을 언급', 'ESSENTIAL', 1),
(2634, 491, '타임아웃 시 서버 도달 여부가 불명이라 POST 재시도는 중복 생성 위험이 있음을 설명', 'ESSENTIAL', 2),
(2635, 491, 'POST는 멱등성이 보장될 때만(멱등성 키 등) 재시도할 수 있음을 언급', 'ESSENTIAL', 3),
(2636, 491, '지수 백오프·지터 중 최소 1개를 재시도 폭주 방지 수단으로 제시', 'SUPPLEMENTARY', 4),
(2637, 491, 'retryOnConnectionFailure는 서버 미도달이 확실한 커넥션 실패만 재시도함을 언급', 'SUPPLEMENTARY', 5),
(2638, 491, '400·404·422 같은 클라이언트 오류는 같은 요청이 같은 실패를 내므로 재시도하지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 492
(2639, 492, 'OkHttp가 실제 소켓을 열고 바이트를 보내는 HTTP 클라이언트임을 언급', 'ESSENTIAL', 1),
(2640, 492, 'Retrofit이 인터페이스 메서드를 HTTP 요청으로 번역(매핑)하는 역할임을 설명', 'ESSENTIAL', 2),
(2641, 492, '타임아웃·인터셉터 같은 통신 설정은 Retrofit이 아니라 OkHttp에 둔다고 명시', 'ESSENTIAL', 3),
(2642, 492, 'Retrofit은 OkHttp에 의존하므로 OkHttp 없이는 동작할 수 없음을 언급', 'SUPPLEMENTARY', 4),
(2643, 492, 'Retrofit이 컨버터(Moshi 등)로 JSON 직렬화를 담당함을 언급', 'SUPPLEMENTARY', 5),
(2644, 492, 'OkHttpClient와 Retrofit을 앱 전체에서 하나만 만들어 공유해야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 493
(2645, 493, '애플리케이션 인터셉터는 리다이렉트·재시도와 무관하게 요청당 정확히 1회 호출됨을 언급', 'ESSENTIAL', 1),
(2646, 493, '네트워크 인터셉터는 실제 네트워크 왕복마다 호출되어 리다이렉트 시 여러 번 호출됨을 언급', 'ESSENTIAL', 2),
(2647, 493, '캐시 응답일 때 네트워크 인터셉터는 호출되지 않음을 언급', 'ESSENTIAL', 3),
(2648, 493, '인증 헤더·공통 파라미터·로깅·재시도 로직 중 최소 1개를 애플리케이션 인터셉터의 적합한 용도로 제시', 'SUPPLEMENTARY', 4),
(2649, 493, '네트워크 인터셉터는 OkHttp가 헤더를 추가한 실제 전송 요청을 볼 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2650, 493, '각 인터셉터가 chain.proceed(request)를 호출해 다음 단계로 넘기는 체인 구조를 설명', 'SUPPLEMENTARY', 6),

-- 질문 494
(2651, 494, 'Authenticator는 401 응답을 받았을 때만 호출되는 훅임을 언급', 'ESSENTIAL', 1),
(2652, 494, '토큰 갱신 후 새 요청을 반환하면 OkHttp가 자동으로 재요청함을 설명', 'ESSENTIAL', 2),
(2653, 494, '응답 횟수를 세어 2회 이상이면 null을 반환해 무한 갱신 루프를 방지함을 언급', 'SUPPLEMENTARY', 3),
(2654, 494, '여러 요청이 동시에 401을 받을 때 토큰 갱신을 synchronized나 Mutex로 직렬화해야 함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 495
(2655, 495, 'Repository 경계에서 네트워크 예외를 도메인 오류 타입으로 변환함을 언급', 'ESSENTIAL', 1),
(2656, 495, '도메인 오류 변환의 목적이 상위 계층이 HTTP 세부 사항을 모르게 하는 것임을 언급', 'ESSENTIAL', 2),
(2657, 495, 'HttpException·SocketTimeoutException·IOException 중 최소 2개를 각기 다른 도메인 오류로 매핑해 제시', 'ESSENTIAL', 3),
(2658, 495, 'CancellationException은 catch로 삼키지 않고 다시 던져야 함을 언급', 'SUPPLEMENTARY', 4),
(2659, 495, 'Response<T>를 반환하면 isSuccessful·errorBody()로 직접 분기한다고 언급', 'SUPPLEMENTARY', 5),
(2660, 495, 'ConnectivityManager 네트워크 콜백으로 오프라인 상태를 사전에 확인함을 언급', 'SUPPLEMENTARY', 6);
