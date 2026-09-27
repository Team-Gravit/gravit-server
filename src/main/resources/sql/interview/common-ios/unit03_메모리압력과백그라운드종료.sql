-- Unit: 메모리 압력과 백그라운드 종료 (Unit ID: 104)
-- Chapter: iOS (Chapter ID: 9)
-- Topic: IOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-ios-unit03 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(516, 'IOS_COMMON', 104, 'HARD', true,
 '사용자들이 앱을 백그라운드에 두었다가 돌아오면 작성 중이던 내용이 사라지고 첫 화면부터 다시 시작된다고 제보하는데, 크래시 도구에는 아무 기록이 없습니다. 원인으로 무엇을 의심하고 어떻게 대응하시겠어요?',
 '가장 먼저 Jetsam에 의한 종료를 의심합니다. iOS는 스왑을 사용하지 않기 때문에 물리 메모리가 부족해지면 커널의 Jetsam이 우선순위가 낮은 프로세스부터 종료하는데, 백그라운드 앱이 포그라운드 앱보다 먼저 희생되고 같은 그룹 안에서는 메모리를 많이 쓰는 프로세스가 먼저 종료됩니다. Jetsam 종료는 크래시 리포트에 일반적인 스택 트레이스가 남지 않고 EXC_RESOURCE 유형의 이벤트나 JetsamEvent 로그로 남기 때문에 크래시 도구에 잡히지 않는 ''이유 없는 재시작''으로 보입니다. Suspended 상태에서 Jetsam으로 종료되면 어떤 콜백도 호출되지 않으므로 ''종료될 때 저장한다''는 전략은 성립하지 않습니다. 따라서 백그라운드 진입 시점, 즉 sceneDidEnterBackground에서 입력 중인 초안, 스크롤 위치, 진행 중인 화면 식별자 저장을 미리 끝내 두고, 다음 실행 시 didFinishLaunchingWithOptions에서 저장된 상태를 읽어 사용자가 보던 화면을 복원하겠습니다. 동시에 백그라운드 진입 시 큰 이미지 버퍼와 캐시를 미리 줄여 두면 Jetsam 우선순위에서 밀려나 살아남을 확률도 높아집니다.'),
(517, 'IOS_COMMON', 104, 'NORMAL', true,
 '이미지 캐시를 직접 만든 딕셔너리로 구현하는 것과 NSCache로 구현하는 것은 메모리 경고 상황에서 어떤 차이가 있나요? NSCache를 쓰더라도 추가로 해야 할 일이 있다면 함께 말씀해 주세요.',
 '직접 만든 딕셔너리 캐시는 메모리 경고가 와도 스스로 비워지지 않기 때문에 개발자가 정리하지 않으면 메모리를 계속 붙잡고 있게 됩니다. 반면 NSCache는 메모리 압력 시 자동으로 축출되고, totalCostLimit으로 비용 한도도 설정할 수 있습니다. 다만 NSCache가 자동으로 비워진다고 안심하면 안 되는데, 축출 시점과 양은 시스템 재량이라 경고를 받은 직후에도 캐시가 남아 있을 수 있습니다. 그래서 UIApplication.didReceiveMemoryWarningNotification을 관찰해 NSCache도 명시적으로 비우는 코드를 함께 두는 것이 안전합니다. 예를 들어 알림 핸들러에서 removeAllObjects를 호출해 경고 시 즉시 전량 비울 수 있습니다. 이미지·데이터 캐시는 가장 크고 다시 받거나 디코딩하면 복원할 수 있어서 메모리 경고 시 정리 우선순위의 1순위이기도 합니다.'),
(518, 'IOS_COMMON', 104, 'NORMAL', true,
 'iOS 앱의 메모리 풋프린트를 구성하는 Dirty, Compressed, Clean 메모리는 각각 어떻게 다르고, 이 중 어떤 것이 Jetsam 계산에 포함되나요?',
 '시스템이 판단하는 앱의 메모리 사용량은 단순 할당량이 아니라 풋프린트입니다. Dirty 메모리는 힙 객체, 디코딩된 이미지 버퍼, 캐시 등 앱이 기록한 메모리이고 Jetsam 계산에 포함됩니다. Compressed 메모리는 한동안 접근하지 않아 압축된 Dirty 페이지로, 역시 Jetsam 계산에 포함됩니다. Clean 메모리는 실행 파일 코드나 매핑된 파일처럼 디스크에서 다시 읽을 수 있는 페이지라 회수 가능하므로 Jetsam 계산에 포함되지 않습니다. 예를 들어 이미지를 UIImage(named:)로 그리면 파일 크기가 아니라 가로 × 세로 × 4바이트의 디코딩 버퍼가 Dirty 메모리로 잡혀 4000×3000 사진 한 장이 약 48MB가 됩니다. 또 압축된 메모리는 다시 접근할 때 해제 비용이 들기 때문에, 백그라운드 진입 전에 큰 버퍼를 아예 해제하는 편이 압축에 맡기는 것보다 유리합니다.'),
(519, 'IOS_COMMON', 104, 'EASY', true,
 'iOS에서 메모리 경고가 앱에 전달되는 과정을 설명해 주세요.',
 '먼저 커널의 Jetsam이 메모리 압력을 감지하면 UIApplication.didReceiveMemoryWarningNotification이 발생합니다. 이 경고는 AppDelegate의 applicationDidReceiveMemoryWarning(_:)과, 뷰가 로드된 모든 UIViewController의 didReceiveMemoryWarning()에 전달됩니다. 경고는 지금 정리하지 않으면 곧 종료된다는 마지막 기회이고 응답에 쓸 수 있는 시간은 매우 짧습니다. 경고에 응답하지 않아 압력이 계속되면 Jetsam이 프로세스를 종료합니다. 참고로 DispatchSource.makeMemoryPressureSource를 쓰면 UIKit 콜백보다 세분화된 warning·critical 단계를 백그라운드 큐에서 받을 수 있고, 뷰 컨트롤러의 didReceiveMemoryWarning은 예전처럼 화면 밖 뷰를 자동 해제하지 않으므로 개발자가 명시적으로 정리해야 합니다.'),
(520, 'IOS_COMMON', 104, 'EASY', true,
 '위젯이나 공유 익스텐션에서 이미지를 다룰 때 메모리 측면에서 무엇을 주의해야 하며, 이미지 다운샘플링이란 무엇인가요?',
 '익스텐션은 앱보다 메모리 한계가 매우 낮습니다. 공식 문서에 수치로 명시되어 있지는 않고 기기·OS 버전에 따라 다르지만, 위젯 익스텐션은 약 30MB, 공유 익스텐션은 약 120MB 수준으로 알려져 있습니다. 그래서 위젯은 이미지 몇 장으로도 한계를 넘을 수 있고, 공유 익스텐션도 원본 이미지를 그대로 디코딩하면 초과할 위험이 있습니다. 이 때문에 이미지 다운샘플링이 사실상 필수인데, 다운샘플링은 원본을 메모리에 다 올리지 않고 축소본만 생성하는 방법입니다. UIImage(contentsOfFile:)로 원본을 열고 draw로 줄이면 원본 크기의 버퍼가 잠시 생기지만, ImageIO의 썸네일 생성은 원본을 디코딩하지 않고 축소본만 만들어 메모리 피크가 훨씬 낮습니다. 또 os_proc_available_memory()로 현재 프로세스가 추가로 쓸 수 있는 메모리를 조회해 대용량 처리 전에 분기 기준으로 활용할 수 있습니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 516
(2764, 516, '메모리 부족 시 Jetsam이 백그라운드 앱을 종료했을 가능성을 원인으로 제시', 'ESSENTIAL', 1),
(2765, 516, 'Suspended 상태에서 Jetsam으로 종료되면 어떤 콜백도 호출되지 않음을 언급', 'ESSENTIAL', 2),
(2766, 516, '백그라운드 진입 시점(sceneDidEnterBackground)에 초안·화면 정보 저장을 미리 끝내야 함을 설명', 'ESSENTIAL', 3),
(2767, 516, '백그라운드 진입 시 큰 캐시·이미지 버퍼를 줄이면 살아남을 확률이 높아짐을 언급', 'ESSENTIAL', 4),
(2768, 516, 'Jetsam 종료는 크래시 리포트에 일반적인 스택 트레이스가 남지 않음을 언급', 'SUPPLEMENTARY', 5),
(2769, 516, 'JetsamEvent 로그 또는 EXC_RESOURCE 이벤트로 종료 흔적을 확인할 수 있음을 언급', 'SUPPLEMENTARY', 6),
(2770, 516, 'didFinishLaunchingWithOptions에서 저장된 상태를 읽어 보던 화면을 복원함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 517
(2771, 517, '직접 만든 딕셔너리 캐시는 메모리 경고가 와도 스스로 비워지지 않음을 언급', 'ESSENTIAL', 1),
(2772, 517, 'NSCache는 메모리 압력 시 자동으로 축출됨을 언급', 'ESSENTIAL', 2),
(2773, 517, 'NSCache 축출 시점과 양은 시스템 재량이라 경고 직후에도 캐시가 남을 수 있음을 설명', 'ESSENTIAL', 3),
(2774, 517, '메모리 경고 알림에서 NSCache를 비우는 코드를 함께 두는 것이 안전함을 언급', 'ESSENTIAL', 4),
(2775, 517, 'NSCache의 totalCostLimit으로 비용 한도를 설정할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2776, 517, '캐시가 가장 크고 다시 받거나 디코딩하면 복원 가능해 정리 1순위임을 언급', 'SUPPLEMENTARY', 6),
(2777, 517, '경고 시 removeAllObjects로 캐시를 즉시 전량 비우는 방법을 제시', 'SUPPLEMENTARY', 7),

-- 질문 518
(2778, 518, 'Dirty 메모리는 힙 객체·디코딩된 이미지 버퍼 등 앱이 기록한 메모리임을 언급', 'ESSENTIAL', 1),
(2779, 518, 'Compressed 메모리는 한동안 접근하지 않아 압축된 Dirty 페이지임을 언급', 'ESSENTIAL', 2),
(2780, 518, 'Clean 메모리는 실행 파일 코드·매핑된 파일 등 디스크에서 다시 읽을 수 있는 페이지임을 언급', 'ESSENTIAL', 3),
(2781, 518, 'Dirty·Compressed는 Jetsam 계산에 포함되고 Clean은 미포함임을 구분', 'ESSENTIAL', 4),
(2782, 518, '이미지는 파일 크기가 아닌 가로 × 세로 × 4바이트의 디코딩 버퍼로 잡힘을 언급', 'SUPPLEMENTARY', 5),
(2783, 518, '압축에 맡기기보다 백그라운드 진입 전 큰 버퍼를 해제하는 편이 유리함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 519
(2784, 519, '커널의 Jetsam이 메모리 압력을 감지하면서 경고가 시작됨을 언급', 'ESSENTIAL', 1),
(2785, 519, 'didReceiveMemoryWarningNotification이 AppDelegate와 모든 뷰 컨트롤러에 전달됨을 설명', 'ESSENTIAL', 2),
(2786, 519, '경고에 응답하지 않아 압력이 계속되면 Jetsam이 프로세스를 종료함을 언급', 'ESSENTIAL', 3),
(2787, 519, 'DispatchSource 메모리 압력 소스로 warning·critical의 세분화된 단계를 받을 수 있음을 언급', 'SUPPLEMENTARY', 4),
(2788, 519, 'didReceiveMemoryWarning은 화면 밖 뷰를 자동 해제하지 않아 개발자가 정리해야 함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 520
(2789, 520, '익스텐션은 메모리 한계가 매우 낮아 이미지 몇 장이나 원본 디코딩으로도 초과할 수 있음을 언급', 'ESSENTIAL', 1),
(2790, 520, '다운샘플링은 원본을 메모리에 다 올리지 않고 축소본만 생성하는 것임을 설명', 'ESSENTIAL', 2),
(2791, 520, '위젯 익스텐션 약 30MB·공유 익스텐션 약 120MB 중 최소 1개의 메모리 한계 수치를 제시', 'SUPPLEMENTARY', 3),
(2792, 520, 'ImageIO 썸네일 생성은 원본을 디코딩하지 않아 메모리 피크가 낮음을 언급', 'SUPPLEMENTARY', 4),
(2793, 520, 'os_proc_available_memory()로 남은 메모리를 조회해 대용량 처리 전 분기 기준으로 삼음을 언급', 'SUPPLEMENTARY', 5);
