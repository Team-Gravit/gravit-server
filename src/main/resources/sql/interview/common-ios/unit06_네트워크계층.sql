-- Unit: 네트워크 계층 (Unit ID: 107)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit06 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(531, 'IOS_COMMON', 107, 'HARD', true,
 'URLSession 기반 APIClient를 설계할 때 요청 실패를 어떤 기준으로 구분하고, 재시도와 401 응답은 각각 어떻게 처리해야 하나요?',
 '먼저 전송 오류와 HTTP 오류를 구분해야 합니다. URLSession은 error가 nil이어도 HTTP 4xx·5xx 응답을 성공 콜백으로 전달하기 때문에, 응답을 HTTPURLResponse로 캐스팅해 statusCode가 200..<300 범위인지 직접 확인해야 합니다. 그리고 APIClient에서는 오류를 invalidResponse, httpStatus, decoding 같은 APIError로 타입화합니다. 재시도는 타임아웃이나 연결 끊김 같은 네트워크 오류에만 지수 백오프로 수행하고, 4xx는 재시도하지 않습니다. 401 응답은 별도로 다뤄서, 리프레시 토큰으로 토큰을 재발급받은 뒤 원래 요청을 1회 재시도하는 계층을 APIClient 안에 둡니다. 이때 동시 다발로 401이 발생하는 경우의 중복 갱신은 단일 갱신 작업을 공유해 방지합니다.'),
(532, 'IOS_COMMON', 107, 'NORMAL', true,
 'URLSessionConfiguration의 default, ephemeral, background 구성은 어떻게 다르고 각각 어떤 상황에 적합한가요?',
 'default 구성은 디스크 캐시와 쿠키, 자격 증명을 영구 저장하는 구성으로 일반적인 API 호출에 씁니다. ephemeral 구성은 캐시·쿠키·자격 증명을 메모리에만 보관하고 세션이 종료되면 폐기하므로 시크릿 모드나 민감한 요청에 적합합니다. background 구성은 별도 시스템 프로세스가 전송을 대행하기 때문에 앱이 정지되거나 종료돼도 전송이 계속되며, 대용량 다운로드·업로드에 적합합니다. 백그라운드 세션은 앱이 종료된 뒤 전송이 완료되면 시스템이 앱을 다시 깨워 application(_:handleEventsForBackgroundURLSession:completionHandler:)를 호출합니다.'),
(533, 'IOS_COMMON', 107, 'NORMAL', true,
 'ATS 때문에 HTTP 서버와 통신이 막힐 때, NSAllowsArbitraryLoads와 NSExceptionDomains는 어떻게 다르며 어느 쪽으로 예외를 두어야 하나요?',
 'ATS는 앱의 네트워크 연결이 HTTPS와 TLS 1.2 이상의 현대적인 TLS 설정을 쓰도록 강제하는 정책이라, 평문 HTTP 요청은 기본적으로 차단되어 오류로 실패합니다. 예외는 Info.plist의 NSAppTransportSecurity에 선언하는데, NSAllowsArbitraryLoads는 모든 도메인의 평문을 허용하므로 정당한 사유 없이는 심사에서 리젝 사유가 됩니다. 반면 NSExceptionDomains는 특정 도메인만 예외로 두는 방식이고 사유를 설명하면 대체로 허용되므로, 도메인 단위 예외가 원칙입니다. 개발 서버가 HTTP라서 예외가 필요하다면 Debug 구성에서만 예외가 적용되도록 Info.plist를 빌드 구성별로 분리하는 편이 안전합니다. 참고로 웹뷰로 임의 사이트를 여는 앱이라면 WKWebView 내 콘텐츠만 예외로 하는 NSAllowsArbitraryLoadsInWebContent가 적절합니다.'),
(534, 'IOS_COMMON', 107, 'EASY', true,
 'URLSession의 URLCache는 서버가 보낸 HTTP 캐시 헤더에 따라 응답 캐싱을 어떻게 처리하나요?',
 'URLSession은 별도 코드 없이도 HTTP 표준 캐시 규칙을 따르는 URLCache를 갖고 있어서, 서버가 보내는 헤더가 캐시 동작을 결정합니다. 요청이 오면 URLCache를 먼저 조회하고, Cache-Control의 max-age 이내인 유효한 캐시가 있으면 네트워크 없이 즉시 응답합니다. 캐시가 만료됐더라도 ETag나 Last-Modified가 있으면 If-None-Match 같은 조건부 요청을 보내고, 서버가 304 Not Modified로 응답하면 캐시된 본문을 재사용해 본문 전송을 절약합니다. 캐시가 없거나 no-store인 경우에는 일반 요청을 보낸 뒤 저장 가능한 응답을 저장합니다. 또한 POST 응답은 기본적으로 캐시되지 않고 캐시는 GET 요청에 초점을 맞추며, 인증 토큰이 포함된 개인화 응답이 디스크 캐시에 남지 않도록 서버가 Cache-Control: private 또는 no-store를 보내는지 확인해야 합니다.'),
(535, 'IOS_COMMON', 107, 'EASY', true,
 '서버 응답에서 필드가 추가되거나 삭제돼도 Codable 디코딩이 전체 실패하지 않게 하려면 모델을 어떻게 설계해야 하나요?',
 '서버가 필드 하나만 추가·삭제해도 디코딩 전체가 실패해 화면이 비는 앱은 취약하므로, 서버 변경에 관대한 모델을 만들어야 합니다. 먼저 가끔 누락되거나 없어도 되는 필드는 옵셔널 프로퍼티로 선언합니다. 그리고 열거형에는 알 수 없는 값을 받을 unknown 케이스를 두어 서버가 새 값을 보내도 디코딩이 실패하지 않게 합니다. 서버가 숫자를 문자열로 보내는 경우처럼 타입이 흔들리면 init(from:)을 직접 구현해 두 타입을 모두 수용합니다. 또한 DecodingError는 어느 키에서 어떤 타입 불일치로 실패했는지 정보를 담고 있으므로, keyNotFound나 typeMismatch의 키와 codingPath를 로그로 남겨 두면 실패 원인을 추적할 수 있습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 531
(2848, 531, 'error가 nil이어도 HTTP 4xx·5xx가 성공 콜백으로 오므로 statusCode를 직접 확인해야 함을 설명', 'ESSENTIAL', 1),
(2849, 531, '재시도는 타임아웃·연결 끊김 같은 네트워크 오류에만 하고 4xx는 재시도하지 않음을 언급', 'ESSENTIAL', 2),
(2850, 531, '401 응답 시 리프레시 토큰으로 재발급한 뒤 원 요청을 1회 재시도함을 설명', 'ESSENTIAL', 3),
(2851, 531, '동시 다발 401에는 단일 갱신 작업을 공유해 중복 갱신을 방지함을 언급', 'SUPPLEMENTARY', 4),
(2852, 531, '네트워크 오류 재시도에 지수 백오프를 적용함을 언급', 'SUPPLEMENTARY', 5),
(2853, 531, '오류를 invalidResponse·httpStatus·decoding 같은 APIError 타입으로 타입화함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 532
(2854, 532, 'default 구성은 디스크 캐시·쿠키·자격 증명을 영구 저장함을 설명', 'ESSENTIAL', 1),
(2855, 532, 'ephemeral 구성은 캐시·쿠키·자격 증명을 메모리에만 보관하고 세션 종료 시 폐기함을 설명', 'ESSENTIAL', 2),
(2856, 532, 'background 구성은 별도 시스템 프로세스가 전송을 대행해 앱이 종료돼도 전송이 계속됨을 설명', 'ESSENTIAL', 3),
(2857, 532, '구성 3종 중 최소 2개의 적합한 상황(일반 API 호출·민감한 요청·대용량 다운로드)을 제시', 'ESSENTIAL', 4),
(2858, 532, '백그라운드 세션 완료 시 시스템이 앱을 깨워 handleEventsForBackgroundURLSession을 호출함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 533
(2859, 533, 'NSAllowsArbitraryLoads는 모든 도메인의 평문을 허용함을 언급', 'ESSENTIAL', 1),
(2860, 533, 'NSAllowsArbitraryLoads는 정당한 사유 없이는 심사에서 리젝 사유가 됨을 언급', 'ESSENTIAL', 2),
(2861, 533, 'NSExceptionDomains로 특정 도메인만 예외 처리하는 도메인 단위 예외가 원칙임을 설명', 'ESSENTIAL', 3),
(2862, 533, 'ATS가 HTTPS와 TLS 1.2 이상을 강제해 평문 HTTP 요청을 기본적으로 차단함을 설명', 'SUPPLEMENTARY', 4),
(2863, 533, '개발 서버용 예외는 Debug 구성에서만 적용되도록 Info.plist를 빌드 구성별로 분리함을 언급', 'SUPPLEMENTARY', 5),
(2864, 533, 'NSAllowsArbitraryLoadsInWebContent는 WKWebView 내 콘텐츠만 예외로 허용함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 534
(2865, 534, 'Cache-Control max-age 이내의 유효한 캐시가 있으면 네트워크 없이 즉시 응답함을 설명', 'ESSENTIAL', 1),
(2866, 534, '만료된 캐시라도 ETag·Last-Modified가 있으면 조건부 요청을 보냄을 설명', 'ESSENTIAL', 2),
(2867, 534, '304 Not Modified 응답을 받으면 캐시된 본문을 재사용해 본문 전송을 절약함을 설명', 'ESSENTIAL', 3),
(2868, 534, 'POST 응답은 기본적으로 캐시되지 않고 캐시는 GET 요청에 초점을 맞춤을 언급', 'SUPPLEMENTARY', 4),
(2869, 534, '개인화 응답이 디스크 캐시에 남지 않도록 Cache-Control private 또는 no-store가 필요함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 535
(2870, 535, '없어도 되는 필드를 옵셔널 프로퍼티로 선언함을 언급', 'ESSENTIAL', 1),
(2871, 535, '열거형에 알 수 없는 값을 받을 unknown 케이스를 둠을 언급', 'ESSENTIAL', 2),
(2872, 535, 'DecodingError의 keyNotFound·typeMismatch가 담은 실패 키와 codingPath를 로그로 남김을 언급', 'SUPPLEMENTARY', 3),
(2873, 535, '서버가 숫자를 문자열로 보내면 init(from:)을 직접 구현해 두 타입을 모두 수용함을 언급', 'SUPPLEMENTARY', 4);
