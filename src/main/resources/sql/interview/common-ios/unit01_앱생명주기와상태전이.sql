-- Unit: 앱 생명주기와 상태 전이 (Unit ID: 102)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(506, 'IOS_COMMON', 102, 'HARD', true,
 '사용자가 작성 중인 초안과 진행 중인 업로드가 있는 상태에서 앱이 홈 화면으로 나갈 때, 데이터 유실 없이 처리하려면 어느 콜백에서 어떤 방식으로 저장·마무리해야 하며 주의할 점은 무엇인가요?',
 '데이터 저장은 sceneDidEnterBackground에 둬야 합니다. 이 콜백은 앱이 살아 있는 동안 마지막으로 확실히 호출되는 콜백이기 때문입니다. 반대로 applicationWillTerminate는 Suspended 상태에서 시스템이 앱을 종료할 때는 호출되지 않으므로, 저장 로직을 여기에만 두면 데이터가 유실됩니다. 진행 중인 업로드는 Background 진입 후 짧은 유예 시간이 지나면 Suspended로 넘어가면서 끊길 수 있으므로, sceneDidEnterBackground에서 beginBackgroundTask를 호출해 백그라운드 작업 시간을 조금 더 확보하고 업로드가 끝나면 endBackgroundTask를 호출합니다. 이때 endBackgroundTask를 빠뜨리면 시스템이 앱을 강제 종료할 수 있으므로, 시간이 다 됐을 때 불리는 만료 핸들러에서도 반드시 endBackgroundTask를 호출해야 합니다. 허용 시간은 공식 문서에 고정값으로 명시되어 있지 않고 대략 30초 안팎으로 알려져 있어 backgroundTimeRemaining으로 확인하는 것이 안전하며, 몇 분 이상 걸리는 다운로드라면 URLSession의 백그라운드 세션을 사용해야 합니다.',
 'interview-question/506.mp3'),
(507, 'IOS_COMMON', 102, 'NORMAL', true,
 'iOS 13부터 AppDelegate와 SceneDelegate로 역할이 나뉜 이유는 무엇이며, 두 객체가 담당하는 범위는 어떻게 다른가요?',
 'iOS 12까지는 AppDelegate 하나가 프로세스 생명주기와 UI 생명주기를 모두 담당했습니다. 그런데 iOS 13에서 iPadOS 멀티 윈도우가 도입되면서 한 프로세스가 여러 개의 UI 인스턴스, 즉 씬을 가질 수 있게 되었고, 그래서 UI 생명주기가 SceneDelegate로 분리되었습니다. 따라서 AppDelegate는 앱당 1개인 프로세스 단위를 담당하고, SceneDelegate는 여러 개가 존재할 수 있는 UI 인스턴스(씬) 단위를 담당합니다. AppDelegate에는 SDK 초기화, 푸시 토큰 등록, 전역 의존성 구성 같은 프로세스 단위 작업을 두고, SceneDelegate에는 scene(_:willConnectTo:options:)에서의 윈도우 생성, 딥링크 처리, 화면 상태 저장·복원 같은 작업을 둡니다. 씬을 사용하는 앱에서는 AppDelegate의 applicationDidBecomeActive 같은 UI 관련 콜백이 호출되지 않고 SceneDelegate의 대응 메서드가 대신 호출됩니다. 또 sceneDidDisconnect는 사용자가 앱 전환기에서 씬을 닫거나 시스템이 자원을 회수할 때 호출될 뿐 프로세스 종료를 뜻하지는 않습니다.',
 'interview-question/507.mp3'),
(508, 'IOS_COMMON', 102, 'NORMAL', true,
 'iOS 앱의 Background 상태와 Suspended 상태는 어떻게 다르며, 두 상태 사이의 전이는 어떻게 일어나나요?',
 'Background는 화면에서 사라졌지만 잠시 코드가 제한적으로 실행되는 상태이고, Suspended는 메모리에는 남아 있지만 코드가 전혀 실행되지 않는 상태입니다. 앱이 Background로 들어가면 짧은 유예 시간이 주어지고, 유예 시간이 지나면 Suspended로 넘어갑니다. 이 시점에는 어떤 콜백도 오지 않습니다. Suspended 상태의 앱은 시스템이 메모리가 부족하면 아무 통보 없이 종료하여 Not Running이 되며, 다음 실행은 didFinishLaunching부터 다시 시작됩니다. 참고로 UIApplication.State 열거형에는 active, inactive, background 세 값만 있는데, Suspended와 Not Running은 앱 코드가 실행되지 않는 상태라 앱이 스스로 관찰할 수 없기 때문입니다.',
 'interview-question/508.mp3'),
(509, 'IOS_COMMON', 102, 'EASY', true,
 '사용자가 홈 화면으로 이동할 때 SceneDelegate에서 호출되는 콜백 순서와, 각 시점에 넣어야 할 작업을 설명해 주세요.',
 '홈 화면으로 이동하면 먼저 sceneWillResignActive가 호출되어 앱이 Inactive 상태가 되고, 이어서 sceneDidEnterBackground가 호출되어 Background 상태가 됩니다. 그 뒤 유예 시간이 지나면 Suspended로 넘어갑니다. sceneWillResignActive에서는 타이머나 게임 루프를 일시 정지하는 작업을 넣고, sceneDidEnterBackground에서는 사용자 데이터를 저장하고 민감한 정보가 보이지 않도록 화면을 가리는 작업을 넣습니다.',
 'interview-question/509.mp3'),
(510, 'IOS_COMMON', 102, 'EASY', true,
 'iOS 앱의 5가지 실행 상태는 무엇이며, 그중 Inactive 상태는 어떤 상태이고 언제 발생하나요?',
 'iOS 앱의 상태는 Not Running, Inactive, Active, Background, Suspended 5가지입니다. 그중 Inactive는 앱이 포그라운드에 있고 화면에도 표시되며 코드도 실행 중이지만, 이벤트를 받지 않는 상태입니다. 전화 수신, 앱 전환 중, 제어 센터 노출 같은 상황에서 발생합니다. Inactive는 대개 Active와 Background 사이를 지나가는 짧은 순간이지만, 전화 수신이나 알림 센터 노출처럼 사용자가 그 상태에 머무는 경우도 있습니다.',
 'interview-question/510.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 506
(2711, 506, '사용자 데이터 저장을 sceneDidEnterBackground에 배치해야 함을 언급', 'ESSENTIAL', 1),
(2712, 506, 'Suspended 상태에서 시스템이 종료할 때 applicationWillTerminate가 호출되지 않음을 언급', 'ESSENTIAL', 2),
(2713, 506, 'beginBackgroundTask로 백그라운드 작업 시간을 더 확보할 수 있음을 언급', 'ESSENTIAL', 3),
(2714, 506, 'endBackgroundTask를 빠뜨리면 시스템이 앱을 강제 종료할 수 있음을 언급', 'ESSENTIAL', 4),
(2715, 506, '허용 시간이 고정값이 아니므로 backgroundTimeRemaining으로 확인하는 것이 안전함을 언급', 'SUPPLEMENTARY', 5),
(2716, 506, '몇 분 이상 걸리는 다운로드는 URLSession 백그라운드 세션을 사용해야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 507
(2717, 507, 'iPadOS 멀티 윈도우 도입으로 한 프로세스가 여러 씬을 가질 수 있게 된 것을 분리 배경으로 언급', 'ESSENTIAL', 1),
(2718, 507, 'AppDelegate는 프로세스 단위, SceneDelegate는 UI 인스턴스(씬) 단위를 담당함을 구분', 'ESSENTIAL', 2),
(2719, 507, 'SDK 초기화·푸시 토큰 등록·전역 의존성 구성 중 최소 1개를 AppDelegate의 작업으로 제시', 'ESSENTIAL', 3),
(2720, 507, '윈도우 생성·딥링크 처리·화면 상태 저장 중 최소 1개를 SceneDelegate의 작업으로 제시', 'ESSENTIAL', 4),
(2721, 507, '씬을 쓰는 앱에서는 applicationDidBecomeActive 같은 UI 콜백이 호출되지 않음을 언급', 'SUPPLEMENTARY', 5),
(2722, 507, 'sceneDidDisconnect가 프로세스 종료를 뜻하지 않음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 508
(2723, 508, 'Background는 화면에서 사라졌지만 코드가 제한적으로 실행되는 상태임을 언급', 'ESSENTIAL', 1),
(2724, 508, 'Suspended는 메모리에 남아 있지만 코드가 실행되지 않는 상태임을 언급', 'ESSENTIAL', 2),
(2725, 508, '유예 시간이 지나면 Background에서 Suspended로 넘어감을 언급', 'ESSENTIAL', 3),
(2726, 508, 'Suspended로 넘어가는 시점에는 어떤 콜백도 호출되지 않음을 언급', 'SUPPLEMENTARY', 4),
(2727, 508, 'UIApplication.State에 Suspended가 없는 이유가 앱 코드가 실행되지 않아서임을 설명', 'SUPPLEMENTARY', 5),
(2728, 508, '메모리가 부족하면 시스템이 Suspended 앱을 아무 통보 없이 종료함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 509
(2729, 509, 'sceneWillResignActive 다음에 sceneDidEnterBackground가 호출되는 순서를 설명', 'ESSENTIAL', 1),
(2730, 509, '타이머·게임 일시 정지 중 최소 1개를 sceneWillResignActive의 작업으로 제시', 'ESSENTIAL', 2),
(2731, 509, '데이터 저장·민감 화면 가리기 중 최소 1개를 sceneDidEnterBackground의 작업으로 제시', 'ESSENTIAL', 3),
(2732, 509, 'sceneWillResignActive 호출 시점에 앱이 Inactive 상태가 됨을 언급', 'SUPPLEMENTARY', 4),

-- 질문 510
(2733, 510, 'Not Running·Inactive·Active·Background·Suspended 5개 상태를 모두 제시', 'ESSENTIAL', 1),
(2734, 510, 'Inactive는 포그라운드에 있지만 이벤트를 받지 않는 상태임을 언급', 'ESSENTIAL', 2),
(2735, 510, '전화 수신·앱 전환·제어 센터 노출 중 최소 1개를 Inactive 발생 상황으로 제시', 'ESSENTIAL', 3),
(2736, 510, 'Inactive가 대개 Active와 Background 사이를 지나가는 짧은 순간임을 언급', 'SUPPLEMENTARY', 4);
