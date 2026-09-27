-- Unit: 권한과 프라이버시 (Unit ID: 111)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (537, 111, '권한 상태값과 앱 추적 투명성'),
       (695, 111, '사전 안내 화면과 토큰화, 사진 선택기'),
       (853, 111, '요청 시점 원칙과 프라이버시 매니페스트');

-- =====================================================
-- Lesson 537: 권한 상태값과 앱 추적 투명성
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3401, 537, '아래 코드가 실행될 때 사용자에게 실제로 벌어지는 일로 옳은 것은?', '이 사용자는 예전에 카메라 권한 대화상자에서 "허용 안 함"을 눌렀다. Info.plist에는 NSCameraUsageDescription이 정상적으로 들어 있다.

```swift
@IBAction func onCaptureTapped() {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
            granted ? self.presentCamera()
                    : self.showAlert("카메라를 사용할 수 없습니다")
        }
    }
}
```', 'OBJECTIVE'),
       (3402, 537, '아래 위치 권한 단계표를 바탕으로 옳지 않은 것은?', '| 단계 | 위치를 받는 범위 | 요청 방법 |
|---|---|---|
| 사용 중 허용 | 앱이 화면에 떠 있는 동안만 | requestWhenInUseAuthorization() |
| 항상 허용 | 화면이 꺼져 있어도 계속 | 사용 중 허용을 받은 뒤 requestAlwaysAuthorization() 호출, 그 뒤 시스템이 한동안 사용 패턴을 지켜보고 사용자에게 다시 확인 |
| 정확도 낮춤 | 반경 수 km 단위로만 | 사용자가 대화상자에서 정확한 위치를 끄면 적용, 앱은 requestTemporaryFullAccuracyAuthorization으로 그 순간만 요청 |', 'OBJECTIVE'),
       (3403, 537, '아래 로그인 처리 코드가 남기는 위험에 대한 설명으로 옳은 것은?', '```swift
func onLoginSucceeded(_ response: LoginResponse) {
    UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
    print("login response: \(response)")
    navigateToHome()
}
```

LoginResponse에는 액세스 토큰과 함께 사용자의 이메일, 전화번호가 담겨 있다.', 'OBJECTIVE'),
       (3404, 537, '아래 심사 회신에서 지적된 항목에 대한 설명으로 옳은 것은?', '[App Store Connect 심사 회신 - 빌드 반려]

- 제출된 빌드에서 아래 호출이 확인되었습니다.
    · UserDefaults 읽기와 쓰기
    · 파일의 생성 및 수정 시각 조회
    · 기기의 남은 디스크 공간 조회
- 번들에 포함된 광고 SDK 두 개에서도 같은 성격의 호출이 확인되었습니다.
- 위 항목들에 대한 선언이 빌드에 들어 있지 않아 심사를 계속할 수 없습니다.', 'OBJECTIVE'),
       (3405, 537, '아래 세 사용자 가운데 C의 권한 상태를 가리키는 값의 이름은?', '같은 앱의 카메라 버튼을 눌렀을 때 세 사용자에게 벌어진 일이다.

- A: 앱을 설치하고 처음 눌렀다 → 시스템 대화상자가 떴고, 허용을 누르자 카메라가 열렸다.
- B: 예전에 대화상자에서 허용 안 함을 눌렀다 → 대화상자 없이 바로 실패했다. 설정 앱에서 카메라 스위치를 직접 켜자 다시 동작했다.
- C: 회사가 배포한 관리 프로파일이 걸린 기기다 → 대화상자 없이 바로 실패했다. 설정 앱에 들어가 봐도 이 앱의 카메라 스위치 자체가 없었다.', 'SUBJECTIVE'),
       (3406, 537, '아래 두 빌드 사이의 변화를 만든 iOS 정책 기능의 이름은?', '같은 광고 SDK를 쓰는 앱의 지표 비교다. 앱 코드는 두 빌드가 같다.

| 항목 | 이전 빌드 (iOS 14.4까지) | 현재 빌드 (iOS 14.5 이후) |
|---|---|---|
| 광고 식별자(IDFA) | 기기마다 고유한 값 | 대부분 0으로만 채워진 값 |
| 설치 기여 리포트 채움률 | 98% | 29% |
| 사용자에게 뜨는 화면 | 없음 | 앱을 켜면, 다른 회사의 앱과 웹사이트에서 벌인 활동을 이 앱이 들여다봐도 되는지 묻는 대화상자 |
| Info.plist | 그대로 | 위 대화상자를 띄우려면 목적 설명 키를 새로 넣어야 함 |', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3401
(9243, 3401, '시스템 권한 대화상자가 다시 떠서, 이번에 허용을 누르면 카메라 화면이 열린다.', '한 번 결정된 권한은 같은 API를 또 불러도 대화상자를 띄우지 않는다. 재요청으로 결정을 뒤집을 수 있다는 오해이며, 되돌리는 경로는 설정 앱뿐이다.', false),
(9244, 3401, '대화상자 없이 완료 블록이 granted=false로 곧장 불려 안내 문구만 뜬다.', '대화상자는 상태가 notDetermined일 때만 뜬다. 이미 거부된 상태라 요청은 즉시 실패로 끝나므로, 이 자리에서 설정 앱으로 보내는 버튼을 함께 주는 것이 옳다.', true),
(9245, 3401, '사용 목적 설명이 들어 있어도 거부된 권한을 요청하면 앱이 그 자리에서 종료된다.', '종료는 사용 목적 설명 키가 아예 없을 때 벌어진다. 키가 갖춰진 상태에서의 거부는 크래시가 아니라 실패 응답으로 끝난다.', false),
(9246, 3401, 'iOS가 일정 기간이 지난 뒤 카메라를 계속 막을지 사용자에게 다시 물어 준다.', '시스템이 나중에 다시 확인하는 것은 위치의 항상 허용 단계다. 카메라 거부는 사용자가 설정 앱에서 직접 바꾸기 전까지 그대로 남는다.', false),

-- 문제 3402
(9247, 3402, '화면이 꺼진 동안의 이동 경로까지 남기려면 사용 중 허용만으로는 부족하다.', '사용 중 허용은 앱이 화면에 떠 있는 구간으로 범위가 묶여 있어, 백그라운드 구간에서는 위치가 들어오지 않아 경로가 끊긴다. 참인 진술이라 답이 아니다.', false),
(9248, 3402, '동네 단위 날씨만 보여 주는 화면은 정확도를 낮춘 사용자에게도 그대로 동작한다.', '정확도를 낮춰도 위치 수신이 끊기는 것이 아니라 반경 수 km 단위로 뭉뚱그려 들어온다. 그 정도로 충분한 기능은 영향을 받지 않아 참이다.', false),
(9249, 3402, '항상 허용을 요청하는 API를 부른 직후부터 백그라운드 위치 수신이 확정된다.', '표에 적힌 대로 호출 뒤에도 시스템이 한동안 사용 패턴을 지켜보고 사용자에게 다시 확인한다. 호출 시점에 확정된다고 본 지점이 거짓이라 이 선지를 고른다.', true),
(9250, 3402, '현재 위치를 정확히 찍어야 하는 순간에만 정확도를 높여 달라고 요청할 수 있다.', '표의 일시 요청이 바로 그 용도다. 늘 정확한 위치를 요구하는 대신 필요한 장면에서만 올려 받는 방식이라 참이다.', false),

-- 문제 3403
(9251, 3403, '출력한 값은 릴리스 빌드에서 시스템이 알아서 가려 주므로 저장소만 바꾸면 된다.', '값을 가려 주는 것은 os.Logger에 privacy: .private를 붙였을 때다. print는 그대로 남아 이메일과 전화번호가 통합 로그에 실린다.', false),
(9252, 3403, 'UserDefaults도 샌드박스 안에 있어 Keychain과 보호 등급이 같고, 문제는 출력 한 줄뿐이다.', '샌드박스는 다른 앱의 접근을 막을 뿐 값 자체를 암호화하지 않는다. UserDefaults는 plist 파일로 남아 백업이나 탈옥 기기에서 그대로 읽힌다.', false),
(9253, 3403, '저장 자체는 안전하고, 로그아웃할 때 값을 지우지 않는 점만 고치면 된다.', '로그아웃 시 삭제도 필요하지만 그것만으로는 부족하다. 지우기 전까지 토큰이 평문으로 놓여 있다는 점이 더 큰 구멍이다.', false),
(9254, 3403, '토큰이 암호화되지 않은 파일로 남고, 출력한 개인정보가 크래시 리포트에까지 따라 들어간다.', '한 줄은 저장소를, 다른 한 줄은 로그를 통해 정보를 흘린다. 토큰은 Keychain에 WhenUnlockedThisDeviceOnly 등급으로 넣고, 로그는 식별 정보를 가린 채 남겨야 한다.', true),

-- 문제 3404
(9255, 3404, '지적된 호출은 금지된 것이 아니라, 기기를 되짚어 알아보는 데 악용될 수 있어 사용 근거를 함께 내야 하는 목록이다.', '이런 값들은 여러 개를 조합하면 사용자를 특정하는 지문이 된다. 그래서 필수 사유 API로 묶여, PrivacyInfo.xcprivacy에 승인된 사유 코드를 적어 두면 그대로 쓸 수 있다.', true),
(9256, 3404, '권한 대화상자를 띄워 사용자 동의를 받아 두면 별도의 선언 없이 그대로 쓸 수 있다.', '대화상자는 카메라나 위치처럼 사용자 자원에 다가갈 때의 절차다. 여기서 요구하는 것은 사용자 동의가 아니라 빌드 안에 담기는 선언이라 성격이 다르다.', false),
(9257, 3404, 'App Store Connect의 수집 데이터 신고 화면을 채우면 같은 요건이 함께 충족된다.', '그 화면은 스토어 페이지에 보이는 앱 프라이버시 정보를 만드는 절차다. 빌드에 들어가는 선언 파일과는 별개라 하나로 대신할 수 없다.', false),
(9258, 3404, '번들에 든 광고 SDK의 선언은 제작사 몫이라 앱 개발사가 챙길 필요는 없다.', '회신이 번들 전체를 놓고 온 데서 보이듯 제출 책임은 앱 개발사에 있다. 지정된 SDK는 자체 선언과 서명을 갖춘 버전으로 바꿔 넣어야 한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1090, 3405, 'restricted,.restricted,제한됨,제한 상태', '스스로 거부한 B는 denied라서 설정 앱으로 안내하면 되돌릴 수 있다. 반면 보호자 제한이나 회사 관리 프로파일(MDM)로 막힌 C는 restricted이며, 사용자가 설정 앱에서 바꿀 권한 자체가 없어 스위치가 보이지 않는다. 그래서 이 상태는 설정 이동 버튼 대신 이 기기에서는 사용할 수 없다는 안내로 흐름을 갈라야 한다. 아직 아무 결정도 내려지지 않은 A는 notDetermined이고, 시스템 대화상자는 오직 이 상태에서만 뜬다.'),
       (1091, 3406, '앱 추적 투명성,앱추적투명성,App Tracking Transparency,ATT,추적 투명성', 'iOS 14.5부터 다른 회사의 앱과 웹사이트에 걸친 사용자 추적과 광고 식별자(IDFA) 접근에는 ATTrackingManager.requestTrackingAuthorization으로 받은 허락이 필요하다. 허락이 없으면 IDFA가 0으로만 내려와 설치 기여 리포트 채움률이 떨어진다. 요청하려면 NSUserTrackingUsageDescription이 있어야 하고, 앱 상태가 Active일 때 불러야 화면에 뜬다. 추적을 하지 않는 앱은 아예 요청하지 않아도 된다. 카메라나 위치처럼 기기 자원에 다가가기 위한 권한이 아니라, 다른 서비스에 걸친 활동 연결을 허락받는 절차라는 점에서 구분된다.');

-- =====================================================
-- Lesson 695: 사전 안내 화면과 토큰화, 사진 선택기
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4349, 695, '아래 상황에서 코드가 이어서 실행될 때 벌어지는 일로 옳은 것은?', '영상 메시지 앱을 새로 설치한 사용자가 녹화 버튼을 처음 눌렀고, 카메라 시스템 대화상자에서 허용을 눌렀다. 이 앱의 Info.plist에 들어 있는 권한 관련 키는 아래 하나뿐이다.

```xml
<key>NSCameraUsageDescription</key>
<string>영상 메시지를 촬영하기 위해 카메라를 사용합니다.</string>
```

```swift
func onRecordTapped() async {
    let camera = await AVCaptureDevice.requestAccess(for: .video)
    guard camera else { return showSettingsGuide() }

    let mic = await AVCaptureDevice.requestAccess(for: .audio)
    guard mic else { return showSettingsGuide() }

    startRecording()
}
```', 'OBJECTIVE'),
       (4350, 695, '아래 권한 요청 흐름에 대한 설명으로 옳은 것은?', '메신저 앱의 친구 찾기 흐름이다. 사용자가 "연락처로 친구 찾기" 버튼을 누르면, 연락처 시스템 대화상자를 부르기 전에 앱이 직접 만든 안내 화면을 먼저 띄운다. 이 화면은 연락처를 연결하면 이미 가입한 지인을 한 번에 추가할 수 있다는 점을 보여 주고, "계속"과 "나중에" 두 버튼을 둔다. 앱은 "계속"을 누른 사용자에게만 연락처 시스템 대화상자를 띄운다.', 'OBJECTIVE'),
       (4351, 695, '아래 코드에서 위치 권한 승인율을 떨어뜨리는 부분을 고치는 방향으로 옳은 것은?', '반경 3km 안의 매장 목록을 보여 주는 "주변 매장" 탭의 코드다. 이 앱에는 백그라운드에서 위치를 쓰는 기능이 없다.

```swift
final class NearbyStoresViewController: UIViewController, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @IBAction func onFindStoresTapped() {
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        guard status == .authorizedAlways || status == .authorizedWhenInUse else { return }

        guard manager.accuracyAuthorization == .fullAccuracy else {
            showAlert("정확한 위치를 켜야 매장을 찾을 수 있습니다.")
            return
        }
        manager.requestLocation()
    }
}
```', 'OBJECTIVE'),
       (4352, 695, '아래 출시 전 점검표를 바탕으로 옳지 않은 것은?', '사진 인화 주문 앱의 출시 전 점검표다.

| 점검 항목 | 현재 상태 |
|---|---|
| 회원 계정 | 앱 안에서 가입할 수 있고, 탈퇴 요청은 고객센터 이메일로만 받는다. |
| App Store Connect 앱 프라이버시 정보 | 위치 항목을 "수집하지 않음"으로 신고했다. |
| 실제 서버 전송 | 가까운 인화점을 안내하려고 대략적 위치를 서버로 보내며, 서버는 이 값을 주문 기록과 함께 보관한다. |
| 광고·추적 | 광고 식별자(IDFA)를 읽지 않고, 다른 회사의 앱·웹사이트 데이터와 사용자를 연결하지 않는다. 앱 추적 투명성(ATT) 요청 코드는 없다. |
| 앱 전환기 | 홈으로 나간 뒤 앱 전환기를 열면 마지막에 보던 주문서의 이름·주소·전화번호가 그대로 보인다. |', 'OBJECTIVE'),
       (4353, 695, '아래 개편에서 카드 정보를 다룬 방식을 가리키는 용어는?', '간편결제 앱이 카드 정보 저장 방식을 개편한 뒤 진행한 모의 탈취 점검 결과다. 두 방식 모두 값은 기기의 Keychain에 저장했다.

| 항목 | 개편 전 | 개편 후 |
|---|---|---|
| Keychain에서 꺼낸 값 | 4518 2210 9934 7781 / 유효기간 08/29 | a8Kx2Qp9ZrT4vL1m |
| 꺼낸 값으로 다른 가맹점에서 결제 시도 | 승인 | 거절 |
| 앱 운영사 서버에 남은 카드번호 | 있음 | 없음 |
| 값이 새어 나간 뒤의 조치 | 카드 정지 후 사용자에게 재발급 안내 | 결제 대행사 콘솔에서 이 값만 폐기, 카드는 그대로 사용 |', 'SUBJECTIVE'),
       (4354, 695, '아래 개편에서 새로 띄운 화면의 클래스 이름은?', '커뮤니티 앱에서 게시글에 사진을 첨부하는 흐름을 개편한 뒤 2주간 관찰한 결과다. 두 버전 모두 UIKit으로 작성했다.

- 개편 전: 첨부 버튼 → 사진 보관함 접근 시스템 대화상자 → 허용한 사용자에게만 앱이 직접 만든 사진 그리드 표시. 첨부 완료율 43%.
- 개편 후: 권한 확인·요청 코드와 자체 그리드를 모두 지우고, iOS 14부터 제공되는 화면 하나를 present(_:animated:)로 띄운다. 한 번에 고를 수 있는 사진은 4장으로 제한했다. 첨부 완료율 91%.
- 개편 후 2주 동안 사진 관련 시스템 대화상자 표시 횟수는 0회였고, 앱이 받은 사진은 게시글당 평균 2.3장(최대 4장)이었다.
- Info.plist에서 NSPhotoLibraryUsageDescription을 지운 빌드가 심사를 통과했고, 설정 앱의 이 앱 항목에는 사진 권한 줄이 보이지 않는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4349
(11771, 4349, '마이크 시스템 대화상자가 기본 안내 문구로 떠서, 허용하면 녹화가 시작된다.', '사용 목적 설명 키가 없다고 시스템이 문구를 대신 채워 주지는 않는다. NSMicrophoneUsageDescription이 없는 상태에서 마이크를 요청하면 대화상자를 띄우기 전에 앱이 종료된다.', false),
(11772, 4349, '마이크를 요청하는 줄에서 대화상자 없이 앱이 곧바로 종료된다.', '사용 목적 설명 키는 권한마다 따로 있어야 한다. 카메라 키만 있고 NSMicrophoneUsageDescription이 없으니 오디오 요청 시점에 시스템이 앱을 강제 종료하며, 이런 빌드는 심사에서도 반려된다.', true),
(11773, 4349, '마이크 요청이 대화상자 없이 false로 끝나 설정 이동 안내가 뜬다.', '키 누락을 거부 상태처럼 조용한 실패로 본 오해다. 대화상자 없이 false가 오는 것은 이미 denied나 restricted로 결정된 경우이고, 키가 빠진 경우는 실패 응답 대신 앱 종료로 끝난다.', false),
(11774, 4349, '카메라를 허용했으니 마이크도 함께 허용돼, 대화상자 없이 녹화가 시작된다.', '카메라와 마이크는 따로 결정되는 별개의 권한이다. 같은 AVCaptureDevice API라도 미디어 유형마다 상태가 따로 저장되며, 이 코드에서는 마이크 키가 없어 요청 시점에 앱이 종료된다.', false),

-- 문제 4350
(11775, 4350, '안내 화면에서 "계속"을 누른 순간 권한이 부여되고, 시스템 대화상자는 확인 절차일 뿐이다.', '앱이 만든 화면은 권한 상태를 바꾸지 못한다. 권한은 시스템 대화상자에서 사용자가 고른 결과로만 기록되므로, "계속"을 누른 사용자도 시스템 대화상자에서 거부하면 denied가 된다.', false),
(11776, 4350, '시스템 대화상자에서 거부한 사용자도 안내 화면을 다시 거치면 시스템 대화상자를 볼 수 있다.', '앱 화면을 몇 번 보여 주든 이미 denied로 기록된 권한은 시스템 대화상자를 다시 띄우지 못한다. 이때는 설정 앱으로 이동하는 버튼을 주는 복구 경로가 필요하다.', false),
(11777, 4350, '안내 화면에서 사용 목적을 설명했으니 Info.plist의 연락처 사용 목적 설명 키는 빼도 된다.', '앱 화면의 설명과 Info.plist의 사용 목적 설명 키는 별개다. NSContactsUsageDescription은 시스템 대화상자에 표시되는 필수 키라, 빠지면 요청 시점에 앱이 종료되고 심사에서도 반려된다.', false),
(11778, 4350, '안내 화면에서 "나중에"를 고른 사용자는 권한 상태가 그대로라 다음 기회에 다시 물을 수 있다.', '시스템 대화상자를 부르지 않았으니 상태는 notDetermined로 남는다. 망설이는 사용자가 거부 기록을 남기지 않게 걸러 두어, 친구 찾기를 다시 누르는 순간 시스템 대화상자를 띄울 기회를 지킨다.', true),

-- 문제 4351
(11779, 4351, '사용 중 허용만 요청하고, 대략적 위치를 준 사용자에게도 매장 목록을 그대로 보여 준다.', '본문의 탭은 백그라운드 위치를 쓰지 않으니 항상 허용은 과한 범위이고, 반경 3km 목록은 대략적 위치로도 만들 수 있다. 요청 단계와 정확도를 둘 다 최소 범위로 낮춰야 승인율을 지킬 수 있다.', true),
(11780, 4351, '항상 허용 요청을 앱 첫 실행 직후로 옮겨, 버튼을 누를 때는 기다림 없이 목록이 뜨게 한다.', '요청을 앞당기면 사용자가 위치가 왜 필요한지 모르는 순간에 대화상자를 보게 돼 승인율이 더 떨어진다. 요청은 매장 찾기 버튼처럼 기능을 실행하려는 맥락에서 해야 하고, 범위도 줄여야 한다.', false),
(11781, 4351, '항상 허용 요청은 그대로 두고, 정확한 위치를 요구하는 경고만 지우면 충분하다.', '경고를 지워도 항상 허용 요청이 남는다. 백그라운드 위치가 필요 없는 탭에서 항상 허용을 요청하면 과한 요구로 보여 거부되기 쉽고, 시스템이 나중에 다시 확인할 때 낮춰질 수도 있어 충분하지 않다.', false),
(11782, 4351, '사용 중 허용으로 바꾸되, 대략적 위치를 준 사용자는 설정 앱으로 보내 정확한 위치를 켜게 한다.', '요청 단계는 제대로 낮췄지만 정확도를 강요하는 흐름이 남는다. 반경 3km 목록은 대략적 위치로도 만들 수 있으니, 설정 앱으로 보내는 대신 받은 정확도 그대로 목록을 보여 줘야 한다.', false),

-- 문제 4352
(11783, 4352, '앱 프라이버시 정보의 위치 항목을 실제로 서버에 보내 보관하는 내용에 맞게 고쳐야 한다.', '신고 내용과 실제 동작이 어긋나면 반려나 삭제 사유가 된다. 대략적 위치라도 서버로 보내 주문 기록과 함께 보관하면 수집에 해당하므로, 신고를 실제에 맞게 고쳐야 한다는 진술은 참이다.', false),
(11784, 4352, '탈퇴를 이메일로만 받지 말고 앱 안에서 계정 삭제를 시작할 수 있게 바꿔야 한다.', '앱에서 계정을 만들 수 있으면 계정 삭제도 앱 안에서 제공해야 한다는 심사 요건이 있다. 고객센터 이메일 접수만으로는 이 요건을 채우지 못하므로 참인 진술이다.', false),
(11785, 4352, '첫 화면이 안정된 뒤 ATT 대화상자를 띄우는 코드를 추가해야 심사를 통과한다.', 'ATT 허락은 IDFA를 읽거나 다른 회사 데이터와 사용자를 연결해 추적할 때만 필요하다. 점검표상 추적을 하지 않으니 요청할 이유가 없는데, 모든 앱이 띄워야 한다고 본 지점이 거짓이다.', true),
(11786, 4352, '앱이 활성 상태를 벗어나기 직전에 주문서 화면을 가리는 처리를 넣어야 한다.', '시스템은 앱이 백그라운드로 갈 때 마지막 화면을 스냅샷으로 떠서 앱 전환기에 보여 준다. 개인정보가 보이는 화면은 활성 상태를 벗어나는 시점에 가림 화면을 덮어 두어야 하므로 참이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1406, 4353, '토큰화,tokenization,토크나이제이션,결제 토큰화,카드 토큰화,서버 토큰화,토큰 치환', '개편 후 기기에 남은 값은 카드번호를 암호화한 결과가 아니라, 결제 대행사가 카드번호 대신 쓰도록 발급한 대체값(결제 토큰)이다. 실제 카드번호는 대행사만 보관하므로 이 값은 발급받은 가맹점의 결제에서만 통하고, 새어 나가도 값만 폐기하면 카드를 바꿀 필요가 없다. 암호화는 키만 있으면 원래 카드번호로 되돌릴 수 있어 어디서든 결제에 쓰일 위험이 남는다는 점에서 다르고, Keychain은 값을 어디에 둘지 정하는 저장 위치일 뿐 값 자체를 바꾸지 않는다는 점에서 구분된다. 민감한 식별 정보는 애초에 기기에 두지 않고 토큰으로 대체하는 것이 유출 피해를 줄이는 가장 강력한 방법이다.'),
       (1407, 4354, 'PHPickerViewController,PHPicker,PHPicker 뷰 컨트롤러,PH피커,PH 피커', 'PHPickerViewController는 사진 보관함을 앱과 분리된 시스템 프로세스에서 보여 주고, 사용자가 고른 항목만 앱에 넘긴다. 앱이 보관함 전체를 읽지 않으므로 사진 권한 요청도, 사용 목적 설명 키도 필요 없어 대화상자 없이 첨부가 끝난다. 예전부터 쓰이던 UIImagePickerController는 한 번에 여러 장을 고르는 기능이 없어 이 개편과 맞지 않고, 사진 권한의 선택한 사진만 허용(제한된 접근)은 여전히 시스템 대화상자를 거쳐 받는 권한 단계라는 점에서 구분된다. 권한을 요청하기 전에 이런 시스템 선택 화면으로 대신할 수 있는지 먼저 따지는 것이 최소 범위 원칙이다.');

-- =====================================================
-- Lesson 853: 요청 시점 원칙과 프라이버시 매니페스트
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5297, 853, '아래 기능 목록에 맞춘 권한 요청 계획으로 옳은 것은?', '공연 예매 앱의 이번 업데이트에 들어갈 기능이다. 지원하는 기기는 모두 iOS 17 이상이다.

| 기능 | 하는 일 |
|---|---|
| 일정 담기 | 예매를 마치면 공연 일정을 캘린더에 넣는다. 넣기 전에 같은 시간대에 이미 잡힌 일정이 있는지 살펴보고, 있으면 겹친다고 알려 준다. |
| 티켓 저장 | 입장용 QR 이미지를 사진 보관함에 저장한다. 보관함에 있는 다른 사진은 읽지 않는다. |
| 프로필 사진 | 사용자가 보관함에서 고른 사진 한 장만 받아 프로필로 쓴다. |
| 길 찾기 | 앱을 화면에 띄워 둔 동안 지도 탭에서 현재 위치부터 공연장까지 경로를 그린다. |', 'OBJECTIVE'),
       (5298, 853, '아래 QA 결과의 원인을 바로잡는 방법으로 옳은 것은?', '광고 성과 측정을 위해 앱 추적 투명성(ATT) 요청을 넣은 빌드다. Info.plist에는 NSUserTrackingUsageDescription이 들어 있다.

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

    ATTrackingManager.requestTrackingAuthorization { status in
        AnalyticsConfig.setTrackingAllowed(status == .authorized)
    }
    return true
}
```

[QA 기록] 앱을 새로 설치한 기기 10대에서 첫 실행을 확인했다. 알림 대화상자는 10대 모두 떴지만, 추적 허락 대화상자는 한 대에서도 뜨지 않았다.', 'OBJECTIVE'),
       (5299, 853, '아래 코드가 사용자 기기의 통합 로그에 남긴 줄로 옳은 것은?', '주문 완료 시점에 로그를 남기는 코드다. 릴리스 빌드를 쓰는 사용자 기기에서 Xcode를 연결하지 않은 채 통합 로그를 확인했다.

```swift
import os

let logger = Logger(subsystem: "com.example.shop", category: "order")

func didPlaceOrder(_ order: Order) {
    logger.notice("order=\(order.id, privacy: .public) buyer=\(order.buyerEmail, privacy: .private) address=\(order.address, privacy: .public)")
}
```

이번 주문의 값은 다음과 같다.
- order.id: ORD-731
- order.buyerEmail: kim@example.com
- order.address: 서울시 마포구 월드컵로 12', 'OBJECTIVE'),
       (5300, 853, '아래 코드와 두 제보에 대한 설명으로 옳은 것은?', '로그인 토큰을 Keychain에 저장하는 코드와, 출시 뒤 들어온 제보 두 건이다.

```swift
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: "auth",
    kSecAttrAccount as String: "refreshToken",
    kSecValueData as String: Data(refreshToken.utf8),
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
]
let status = SecItemAdd(query as CFDictionary, nil)
```

- 제보 1: 새 아이폰으로 바꾸면서 이전 기기의 암호화된 백업을 복원했다. 사진과 다른 앱의 로그인은 그대로 넘어왔는데, 이 앱만 다시 로그인하라고 한다.
- 제보 2: 기기가 잠겨 있던 밤사이 백그라운드 새로고침이 돌 때마다 토큰 읽기가 errSecInteractionNotAllowed로 실패해 동기화를 건너뛰었다. 아침에 잠금을 풀고 앱을 열면 다시 로그인하지 않아도 정상으로 동작한다.', 'OBJECTIVE'),
       (5301, 853, '아래 개편에 적용된 권한 요청 원칙을 가리키는 용어는?', '가계부 앱이 권한 요청 방식을 바꾸고 2주 동안 비교한 결과다. 요청하는 권한의 종류와 범위, Info.plist의 사용 목적 설명 문구는 두 버전이 같고, 앱이 직접 만든 안내 화면은 두 버전 모두 없다.

| 권한 | 개편 전 대화상자가 뜬 때 | 개편 후 대화상자가 뜬 때 | 허용 비율 (개편 전 → 후) |
|---|---|---|---|
| 카메라 | 앱 첫 실행 직후 | 영수증 촬영 버튼을 처음 누른 순간 | 38% → 84% |
| 위치 | 앱 첫 실행 직후 | 주변 ATM 지도 탭을 처음 연 순간 | 29% → 71% |
| 알림 | 앱 첫 실행 직후 | 고정 지출을 등록하고 "결제일에 알려 주기"를 켠 순간 | 41% → 77% |', 'SUBJECTIVE'),
       (5302, 853, '아래 내용을 담아 앱 번들에 넣는 파일을 가리키는 용어는?', '출시 전 점검에서 앱 번들에 새로 추가한 파일의 내용 일부다. Info.plist와는 따로 두는 파일이며, Apple이 지정한 광고·분석 SDK도 각자 같은 형식의 파일을 담아 배포해야 한다.

```xml
<key>NSPrivacyTracking</key>
<false/>
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeEmailAddress</string>
        <key>NSPrivacyCollectedDataTypeLinked</key>
        <true/>
        <key>NSPrivacyCollectedDataTypeTracking</key>
        <false/>
        <key>NSPrivacyCollectedDataTypePurposes</key>
        <array>
            <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
        </array>
    </dict>
</array>
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>CA92.1</string>
        </array>
    </dict>
</array>
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5297
(14299, 5297, '일정 담기는 캘린더에 일정을 넣는 기능이므로 iOS 17의 쓰기 전용 접근을 요청한다.', '본문의 일정 담기는 넣기 전에 기존 일정을 읽어 겹침을 확인한다. 쓰기 전용 접근으로는 기존 일정을 읽을 수 없어 이 확인이 막히므로, 이 기능에는 전체 접근이 필요하다.', false),
(14300, 5297, '티켓 저장은 NSPhotoLibraryAddUsageDescription 키를 두고 추가 전용 권한만 요청한다.', '보관함에 이미지를 넣기만 하고 다른 사진은 읽지 않으니, 읽기까지 여는 전체 접근은 과한 범위다. 추가 전용 권한은 저장만 허락받는 단계라 사용자가 부담 없이 허용하기 쉽다.', true),
(14301, 5297, '프로필 사진은 선택한 사진만 허용 단계로라도 사진 보관함 권한을 먼저 받아야 한다.', 'PHPickerViewController 같은 시스템 선택 화면은 사용자가 고른 사진만 앱에 넘겨 주므로 권한 요청이 아예 필요 없다. 선택한 사진만 허용도 결국 권한 대화상자를 거치는 단계라 최소 범위가 아니다.', false),
(14302, 5297, '길 찾기는 이동하는 동안 위치를 계속 받아야 하므로 항상 허용 위치 권한을 요청한다.', '본문의 길 찾기는 앱이 화면에 떠 있는 동안에만 동작한다. 백그라운드 수신이 필요 없으니 사용 중 허용이면 충분하고, 항상 허용을 요구하면 과한 요청으로 보여 거부되기 쉽다.', false),

-- 문제 5298
(14303, 5298, '광고 식별자(IDFA)를 먼저 읽도록 바꾸면, 시스템이 그 순간 추적 대화상자를 대신 띄워 준다.', '기능을 처음 쓰는 순간 대화상자가 저절로 뜬다고 본 오해다. 허락 없이 IDFA를 읽으면 대화상자 없이 0으로만 채워진 값이 돌아오고, 추적 허락은 requestTrackingAuthorization으로만 물을 수 있다.', false),
(14304, 5298, 'Info.plist에 NSUserTrackingUsageDescription을 넣어 추적 대화상자에 보여 줄 문구를 마련한다.', '본문의 Info.plist에는 이 키가 이미 들어 있다. 게다가 사용 목적 설명 키가 빠지면 대화상자가 조용히 생략되는 것이 아니라 요청 시점에 앱이 종료되므로, 이 증상의 원인이 될 수 없다.', false),
(14305, 5298, '추적 요청을 첫 화면이 뜬 뒤 앱이 활성 상태일 때로 옮기고, 알림 대화상자와 겹치지 않게 한다.', '추적 대화상자는 앱이 활성(Active) 상태일 때만 뜨는데, 실행 직후 호출은 아직 활성 전이고 알림 대화상자와도 겹친다. 첫 화면이 안정된 뒤 notDetermined일 때만 요청하면 대화상자가 제대로 뜬다.', true),
(14306, 5298, '알림 요청만 지우면 실행 직후에 남긴 추적 요청이 앱 상태와 상관없이 곧바로 대화상자를 띄운다.', '대화상자 겹침은 원인의 일부일 뿐이다. didFinishLaunching 시점의 앱은 아직 활성 상태가 아니어서, 알림 요청을 지워도 추적 대화상자는 뜨지 않을 수 있다. 호출 위치 자체를 활성 이후로 옮겨야 한다.', false),

-- 문제 5299
(14307, 5299, 'order=ORD-731 buyer=<private> address=서울시 마포구 월드컵로 12', 'privacy 옵션은 보간한 값마다 따로 적용된다. .private를 붙인 이메일만 <private>로 바뀌고, .public을 붙인 주소는 원문 그대로 남는다. 주소도 개인정보이므로 .private로 바꿔야 한다.', true),
(14308, 5299, 'order=ORD-731 buyer=<private> address=<private>', 'Logger가 주소 같은 개인정보를 스스로 알아보고 가려 준다고 본 오해다. 가릴지는 개발자가 붙인 옵션으로만 정해지며, 주소에는 .public이 붙어 있어 원문이 그대로 기록된다.', false),
(14309, 5299, 'order=ORD-731 buyer=kim@example.com address=서울시 마포구 월드컵로 12', 'privacy 옵션을 주석 같은 표시로만 여긴 오해다. Xcode가 연결되지 않은 기기의 통합 로그에서는 .private를 붙인 값이 실제로 <private>로 치환되어 남는다.', false),
(14310, 5299, 'order=<private> buyer=<private> address=<private>', '릴리스 빌드면 보간한 값이 모두 가려진다고 본 오해다. .public을 붙인 주문 번호와 주소는 원문 그대로 남고, 가려지는 것은 .private를 붙인 이메일뿐이다.', false),

-- 문제 5300
(14311, 5300, 'Keychain 항목은 보호 등급과 관계없이 백업에 담기지 않으므로, 제보 1은 어떤 설정으로도 막을 수 없다.', 'ThisDeviceOnly가 붙지 않은 항목은 암호화된 백업에 담겨 새 기기로 복원된다. 다른 앱의 로그인이 넘어온 것도 그 때문이며, 제보 1은 이 코드가 기기 한정 등급을 골라서 생긴 결과다.', false),
(14312, 5300, '기기가 잠기면 이 항목이 Keychain에서 지워지므로, 잠금을 푼 뒤에는 로그인을 다시 거쳐야 한다.', '잠금은 항목을 지우지 않고 잠긴 동안 꺼내지 못하게 막을 뿐이다. 제보 2에서 잠금을 풀자 다시 로그인하지 않고도 정상 동작한 것이 그 근거다.', false),
(14313, 5300, 'kSecAttrAccessible 줄을 빼면 제약 없는 기본 등급이 적용돼, 잠긴 기기에서도 토큰을 읽을 수 있다.', '보호 등급을 적지 않으면 kSecAttrAccessibleWhenUnlocked가 기본으로 적용돼 잠긴 동안에는 여전히 읽히지 않는다. 잠긴 상태의 백그라운드 작업이 꼭 필요하면 AfterFirstUnlock 계열 등급을 따로 검토해야 한다.', false),
(14314, 5300, '두 제보 모두 고른 보호 등급이 의도대로 동작한 결과로, 토큰을 기기 밖으로 옮기지 않고 잠긴 동안 막아 둔 대가다.', 'WhenUnlocked는 잠금이 풀린 동안에만 항목을 꺼낼 수 있게 하고, ThisDeviceOnly는 백업을 거쳐서도 다른 기기로 옮기지 않는다. 토큰 유출 위험을 줄이는 대신 새 기기 재로그인과 잠금 중 읽기 실패를 감수하는 설정이다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1722, 5301, 'Just-in-Time,Just in Time,JustInTime,JIT,저스트 인 타임,저스트인타임,Just-in-Time 요청,JIT 요청,맥락 안에서 요청,맥락 안 요청,맥락 내 요청,맥락 속 요청,맥락 기반 요청,in-context,인 컨텍스트,인컨텍스트,적시 요청', 'Just-in-Time(맥락 안에서 요청)은 사용자가 그 권한이 필요한 기능을 직접 실행하려는 순간에 대화상자를 띄우는 원칙이다. 앱 첫 실행 직후에는 사용자가 권한이 왜 필요한지 알 수 없어 거부하기 쉽고, 한 번 거부된 권한은 앱이 다시 물을 수 없어 설정 앱으로 보내야만 되돌릴 수 있다. 그래서 첫 요청의 승인율이 곧 그 기능의 성패가 된다. 비슷해 보이는 사전 설명 화면(Pre-permission)은 시스템 대화상자 앞에 앱이 만든 화면을 한 겹 더 두는 방식이고, 최소 범위 요청은 시점이 아니라 요청하는 권한의 크기(사용 중 허용, 선택한 사진만 등)를 줄이는 원칙이라는 점에서 구분된다. 본문은 안내 화면도 범위도 그대로 두고 시점만 옮겼다.'),
       (1723, 5302, '프라이버시 매니페스트,프라이버시 매니페스트 파일,privacy manifest,privacy manifest file,PrivacyInfo.xcprivacy,PrivacyInfo,xcprivacy,개인정보 매니페스트,개인정보 보호 매니페스트', '프라이버시 매니페스트(PrivacyInfo.xcprivacy)는 앱이나 SDK가 수집하는 데이터 유형과 목적(NSPrivacyCollectedDataTypes), 추적 여부(NSPrivacyTracking), 필수 사유 API를 쓰는 근거(NSPrivacyAccessedAPITypes)를 빌드 안에 선언하는 파일이다. 본문의 CA92.1은 UserDefaults를 그 앱 안에서만 읽고 쓴다는 승인된 사유 코드로, UserDefaults처럼 기기를 되짚어 알아보는 데 악용될 수 있는 API를 쓰면 이런 사유를 적어야 심사를 통과한다. Info.plist의 사용 목적 설명 키는 권한 대화상자에 보여 줄 문구를 담는 것이고, App Store Connect의 앱 프라이버시 정보(영양 라벨)는 웹에서 신고해 스토어 페이지에 보이는 내용이라 번들에 넣는 파일이 아니라는 점에서 구분된다. 요건은 자주 바뀌므로 최신 Apple 공지를 기준으로 확인해야 한다.');
