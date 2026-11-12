-- Unit: 셀 재사용과 리스트 성능 (Unit ID: 105)
-- Chapter: iOS (Chapter ID: 9)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (531, 105, '재사용 셀 초기화와 오프스크린 렌더링'),
       (689, 105, '프리페칭과 Diffable 데이터 소스'),
       (847, 105, '셀 재구성 비용과 이미지 다운샘플링');

-- =====================================================
-- Lesson 531: 재사용 셀 초기화와 오프스크린 렌더링
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3365, 531, '아래 목록 화면 코드로 스크롤할 때 나타나는 동작으로 옳은 것은?', '`ProductCell`은 등록을 마쳤고 `prepareForReuse()`는 재정의하지 않았다. `badgeLabel`의 초기 텍스트는 nil이며, 상품 1만 개 가운데 품절 상품은 드물게 섞여 있다.

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
    let product = products[indexPath.row]
    cell.titleLabel.text = product.name
    if product.isSoldOut {
        cell.badgeLabel.text = "품절"
    }
    return cell
}
```', 'OBJECTIVE'),
       (3366, 531, '아래 셀 설정 위치 비교표를 바탕으로 옳지 않은 것은?', '| 설정 위치 | 호출 시점 | 맡는 일 |
| --- | --- | --- |
| `init`·`awakeFromNib` | 셀 인스턴스가 처음 만들어질 때 1회 | 제약 조건, 폰트, 모서리 처리 등 항목과 무관한 고정 설정 |
| `prepareForReuse()` | 큐에 있던 셀이 다시 쓰이기 직전 | 이전 항목의 이미지·상태 플래그·콜백 정리, 진행 중인 작업 취소 |
| `configure(with:)` | 셀이 특정 행에 배정될 때마다 | 이번 항목의 텍스트·이미지 값 대입 |', 'OBJECTIVE'),
       (3367, 531, '아래 로그에서 마지막에 엉뚱한 이미지가 남은 원인으로 옳은 것은?', '상품 목록을 빠르게 스크롤하며 남긴 로그다. row 9의 상품 이미지는 B인데, 화면에는 A가 표시된 채로 멈춰 있다.

```
14:02:31.100  row 3 ← cell#7 배정, GET /img/A 시작
14:02:31.180  cell#7 화면 이탈, 재사용 큐로 반납
14:02:31.190  row 9 ← cell#7 배정, GET /img/B 시작
14:02:31.240  GET /img/B 응답 도착, cell#7 썸네일 갱신
14:02:31.610  GET /img/A 응답 도착, cell#7 썸네일 갱신
```', 'OBJECTIVE'),
       (3368, 531, '아래 데이터 소스 방식에 대한 설명으로 옳은 것은?', '이 데이터 소스는 화면에 놓일 섹션과 항목 식별자의 목록을 스냅샷으로 받는다. 새 스냅샷을 적용하면 직전 스냅샷과 견주어 달라진 부분을 계산하고, 그 차이만 테이블 뷰에 반영한다. 항목 식별자는 Hashable이어야 하며 iOS 13부터 쓸 수 있다.', 'OBJECTIVE'),
       (3369, 531, '아래 상황에서 프레임 시간을 세 배로 늘린 렌더링 방식의 이름은?', '프로필 목록의 정사각형 썸네일을 원형으로 바꾸려고 셀의 이미지 뷰에 `layer.cornerRadius`와 `layer.masksToBounds = true`를 함께 지정했다. 그러자 스크롤 중 한 프레임을 그리는 데 걸리는 시간이 8ms에서 24ms로 늘고 GPU 사용률이 크게 뛰었다. Instruments의 Core Animation 디버그 옵션을 켜니 썸네일 영역만 노랗게 표시됐다. 원본 이미지를 미리 원형으로 가공해 넣도록 바꾸자 프레임 시간은 9ms로 돌아왔다.', 'SUBJECTIVE'),
       (3370, 531, '아래 관찰이 드러내는 테이블 뷰의 동작 방식을 가리키는 용어는?', '항목 1만 개짜리 상품 목록을 끝까지 스크롤하면서 살아 있는 `ProductCell` 인스턴스 수를 세었더니 최대 14개에서 더 늘지 않았다. 인스턴스 주소를 함께 찍어 보니 row 4를 그렸던 객체가 화면 밖으로 나간 뒤 row 41에서 다시 나타났다. 항목을 1,000개에서 10,000개로 늘려도 목록이 쓰는 메모리는 거의 같았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3365
(9147, 3365, '큐가 비어 있을 때 dequeue가 nil을 돌려주므로 강제 캐스팅 지점에서 실행이 중단된다.', 'for: indexPath 버전은 등록만 되어 있으면 셀을 항상 보장한다. nil을 돌려줄 수 있는 쪽은 indexPath를 받지 않는 dequeueReusableCell 이다.', false),
(9148, 3365, '품절 상품을 그렸던 셀이 다시 쓰이면 품절이 아닌 항목에도 품절 배지가 남아 보인다.', 'isSoldOut이 참일 때만 배지 텍스트를 넣고 거짓일 때 지우는 분기가 없다. 큐에서 꺼낸 셀은 이전 항목의 텍스트를 그대로 들고 있어 그 값이 그대로 노출된다.', true),
(9149, 3365, '행이 화면 밖으로 나갈 때 테이블 뷰가 셀의 서브뷰 값을 비워 주므로 이전 항목의 표시는 남지 않는다.', 'UIKit은 셀을 큐에 보관만 할 뿐 내용을 지워 주지 않는다. 지우는 일은 prepareForReuse나 셀 구성 코드에서 직접 해야 한다.', false),
(9150, 3365, '행마다 새 인스턴스가 만들어져 돌아오므로 이전 행의 상태가 섞일 일이 없다.', 'dequeue는 큐에 남은 셀이 있으면 그 인스턴스를 다시 내준다. 새 인스턴스는 큐가 비어 있는 초기 몇 개에서만 만들어진다.', false),

-- 문제 3366
(9151, 3366, '폰트나 모서리 처리를 configure에 두면 값이 바뀌지 않는데도 행이 배정될 때마다 같은 설정을 되풀이하게 된다.', '표에서 폰트·모서리는 항목과 무관한 고정 설정이다. 항목마다 불리는 자리에 두면 결과는 같은데 비용만 반복되므로 참인 진술이다.', false),
(9152, 3366, '다시 쓰이기 직전에 이전 작업을 취소해 두면 쓸모없어진 다운로드와 디코딩 비용을 줄일 수 있다.', '표에서 진행 중인 작업 취소는 재사용 직전 단계의 몫이다. 이미 화면을 떠난 항목의 작업을 끊으면 그만큼 네트워크와 CPU를 아끼므로 참인 진술이다.', false),
(9153, 3366, '제약 조건은 행마다 크기가 달라질 수 있으므로 재사용 직전 단계에서 다시 잡아 주어야 한다.', '표에서 제약 조건은 인스턴스가 처음 만들어질 때 1회 설정하는 항목이다. 재사용마다 제약을 다시 잡으면 같은 작업이 스크롤 내내 반복돼 프레임 예산만 갉아먹는다.', true),
(9154, 3366, '셀이 처음 만들어져 바로 화면에 그려질 때는 지울 이전 항목이 없어 정리 단계를 거치지 않는다.', '표의 호출 시점이 큐에 있던 셀을 다시 쓰기 직전이므로 새로 만든 셀은 해당하지 않는다. 그래서 초기 표시값은 생성 시점에 잡아야 하며, 진술 자체는 참이다.', false),

-- 문제 3367
(9155, 3367, '두 요청이 같은 커넥션을 공유해 응답이 요청 순서대로 처리되면서 A가 마지막이 됐다.', 'HTTP 응답이 도착하는 순서는 요청 순서와 무관하다. 순서가 보장된다면 A가 먼저 도착하고 B가 뒤에 반영돼 이 증상 자체가 생기지 않는다.', false),
(9156, 3367, '셀이 큐로 반납될 때 인스턴스가 해제되어 A의 완료 처리에서 이미 사라진 뷰를 건드렸다.', '큐 반납은 해제가 아니라 보관이다. 같은 cell#7이 row 9에 다시 배정된 로그가 인스턴스가 살아 있다는 증거이며, 해제됐다면 갱신 자체가 일어나지 않는다.', false),
(9157, 3367, '이미지 캐시가 URL이 아니라 행 번호를 키로 삼아 row 9 자리에 A가 저장됐다.', '로그에는 캐시 적중이 없고 A와 B 모두 네트워크 요청으로 나갔다. 캐시 키 설계 문제라면 요청 횟수나 적중 기록에서 흔적이 보여야 한다.', false),
(9158, 3367, '응답이 도착한 시점에 셀이 아직 같은 항목을 가리키는지 확인하지 않아, 늦게 온 이전 요청의 결과가 나중 이미지를 덮어썼다.', 'cell#7은 row 3과 row 9에서 같은 인스턴스다. 31.610의 A 응답이 31.240의 B 결과를 덮어썼으므로, 요청 때 적어 둔 URL이나 항목 ID를 응답 시점에 대조해 걸러야 한다.', true),

-- 문제 3368
(9159, 3368, '항목을 넣고 뺄 때 행 개수와 인덱스를 개발자가 직접 맞추지 않아도 되므로, 갱신 전후 개수가 어긋나 생기는 크래시를 피할 수 있다.', '삽입·삭제 인덱스를 손으로 계산해 넘기던 자리를 스냅샷 비교가 대신한다. 개수 불일치로 던지던 예외가 구조적으로 사라지는 것이 이 방식의 큰 실무 이점이다.', true),
(9160, 3368, '스냅샷을 적용하면 보이는 셀이 모두 다시 구성되므로 전체 갱신과 화면 갱신 비용이 같다.', '차이만 반영하는 것이 핵심이라 그대로인 항목의 셀은 다시 구성되지 않는다. 비용이 전체 갱신과 같다면 스냅샷을 비교할 이유가 없다.', false),
(9161, 3368, '항목마다 전용 셀을 계속 들고 있어야 하므로 재사용 큐와 함께 쓸 수 없다.', '셀 공급은 여전히 dequeue로 이뤄진다. 스냅샷은 어떤 항목이 어느 자리에 놓일지를 정할 뿐 셀을 돌려쓰는 방식은 그대로다.', false),
(9162, 3368, '식별자 대신 모델 객체 전체를 스냅샷에 넣어야 변경 감지가 동작한다.', 'Hashable이기만 하면 되므로 ID만 담아도 동작한다. 오히려 ID만 담는 편이 메모리도 적고, 값 일부가 바뀐 항목을 다른 항목으로 오인할 여지도 줄어든다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1078, 3369, '오프스크린 렌더링,오프 스크린 렌더링,offscreen rendering,off-screen rendering,off screen rendering,offscreen render,화면 밖 렌더링', '모서리를 둥글게 깎아 그 안쪽만 남기려면 GPU가 화면 버퍼에 바로 그리지 못하고 별도 버퍼에 한 번 그린 뒤 합성해야 한다. 이렇게 화면 밖 버퍼를 거치는 처리가 오프스크린 렌더링이며, 셀 수십 개가 동시에 스크롤될 때 한 프레임 예산인 16.6ms를 넘기는 흔한 원인이다. 이미지를 미리 원형으로 가공해 넣는 해법은 매 프레임 GPU 비용을 준비 단계의 CPU 비용 한 번으로 바꾸는 것이고, 그림자도 같은 이유로 비싸지만 shadowPath를 지정하면 피할 수 있다. 같은 픽셀을 여러 겹 덧그리는 오버드로나, 오토레이아웃 계산처럼 CPU에서 벌어지는 지연과는 구분해야 한다.'),
       (1079, 3370, '셀 재사용,셀재사용,셀 재활용,재사용 메커니즘,재사용 큐,cell reuse,cell reusing,reuse queue,cell recycling', '화면 밖으로 나간 셀을 큐에 보관했다가 새로 들어오는 행에 다시 배정하는 것이 셀 재사용이다. 살아 있는 셀 수가 화면에 보이는 개수 언저리로 고정되므로 항목이 1만 개여도 메모리가 항목 수에 비례해 늘지 않는다. row 4와 row 41이 같은 주소를 썼다는 것은 두 행이 같은 인스턴스를 공유했다는 뜻이므로, 이전 행의 텍스트·이미지·선택 상태가 남아 있을 수 있다. 그래서 항목별 값은 셀 구성 시점에 빠짐없이 덮어쓰고 이전 흔적 정리는 prepareForReuse에서 한다. 데이터를 나눠 받는 페이지네이션이나, 곧 보일 항목을 미리 준비하는 프리페칭과는 층위가 다른 개념이다.');

-- =====================================================
-- Lesson 689: 프리페칭과 Diffable 데이터 소스
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4313, 689, '아래 코드와 상황에서 운동화 이미지 응답이 반영된 직후의 화면으로 옳은 것은?', '화면에는 row 0~9가 보이고 있다. row 5의 운동화 상품 셀이 이미지를 요청한 직후, 새 상품인 모자를 `products` 배열 맨 앞에 넣고 `insertRows(at:with:)`로 row 0을 삽입했다. 삽입 전 row 4는 가방이었다. 삽입 전부터 있던 다른 행의 이미지는 모두 도착해 있었고, 스크롤은 없었다. 그 뒤 운동화 이미지 응답이 도착했다. `ImageLoader`의 완료 클로저는 메인 스레드에서 호출된다.

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
    let product = products[indexPath.row]
    cell.titleLabel.text = product.name
    cell.thumbnail.image = UIImage(named: "placeholder")

    ImageLoader.shared.load(product.imageURL) { [weak tableView] image in
        // 응답이 오면 요청할 때의 indexPath에 있는 셀을 찾아 반영
        guard let target = tableView?.cellForRow(at: indexPath) as? ProductCell else { return }
        target.thumbnail.image = image
    }
    return cell
}
```', 'OBJECTIVE'),
       (4314, 689, '아래 측정 결과로 판단할 때 스크롤 끊김에 대한 설명으로 옳은 것은?', '60Hz 기기에서 상품 목록을 스크롤하며 Time Profiler로 측정했다. 한 프레임의 예산은 약 16.6ms이고, 아래는 새 행 하나가 화면에 들어오는 프레임에서 메인 스레드가 쓴 평균 시간이다.

| 단계 | 평균 시간 |
| --- | --- |
| 재사용 큐에서 셀 꺼내기 | 0.3ms |
| 원본 3,000×3,000 픽셀 이미지 디코딩 | 18.5ms |
| 가격 문자열 만들기 (`NumberFormatter`를 매번 새로 생성) | 4.1ms |
| 레이블·이미지 뷰에 값 대입 | 0.4ms |', 'OBJECTIVE'),
       (4315, 689, '아래 셀 코드로 목록을 띄운 뒤 아래로 스크롤했을 때의 화면으로 옳은 것은?', '스토리보드에서 `OrderCell`의 contentView 배경색은 시안 작업 때 넣은 회색이 그대로 남아 있다. `cellForRowAt`은 `dequeueReusableCell(withIdentifier:for:)`로 셀을 꺼낸 뒤 `configure(with:)`만 호출한다. 주문은 200건이고 모든 주문의 `isDelayed`는 `false`다. 첫 화면에는 10개 행이 보인다.

```swift
final class OrderCell: UITableViewCell {
    @IBOutlet private weak var statusLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        statusLabel.text = nil
        contentView.backgroundColor = .systemBackground
    }

    func configure(with order: Order) {
        statusLabel.text = order.status
        if order.isDelayed {
            contentView.backgroundColor = .systemRed.withAlphaComponent(0.1)
        }
    }
}
```', 'OBJECTIVE'),
       (4316, 689, '아래 셀 획득 방식에 대한 설명으로 옳은 것은?', '`cellForRowAt`에서 셀을 얻을 때 재사용 식별자와 함께 현재 행의 `indexPath`를 넘기는 메서드를 쓴다. 재사용 큐에 같은 식별자의 셀이 남아 있으면 그 인스턴스를 돌려주고, 없으면 식별자에 연결해 둔 셀 클래스로 새 인스턴스를 만들어 돌려준다.', 'OBJECTIVE'),
       (4317, 689, '아래 로그에서 새로 적용된 이미지 로딩 방식을 가리키는 용어는?', '상품 목록은 원래부터 이미지를 비동기로 받아 메모리 캐시에 저장하고 있었지만, 새 행이 화면에 들어온 뒤 썸네일이 뜨기까지 플레이스홀더가 평균 450ms 보였다. 뷰 컨트롤러에 프로토콜 하나를 추가로 채택해 테이블 뷰에 연결한 뒤, 같은 목록을 스크롤하며 남긴 로그는 아래와 같다. 이후 플레이스홀더가 보이는 시간은 평균 30ms로 줄었다.

```
10:20:05.100  보이는 행 row 12~19, 아래로 스크롤 중
10:20:05.120  GET /img/p24 시작
10:20:05.121  GET /img/p25 시작
10:20:05.410  GET /img/p24 완료, 캐시에 저장
10:20:05.480  row 24 화면 진입, 캐시 적중으로 바로 표시
10:20:05.900  보이는 행 row 20~27
10:20:05.910  GET /img/p32 시작
10:20:05.911  GET /img/p33 시작
10:20:06.010  스크롤 방향 전환, 위로 이동
10:20:06.012  GET /img/p32 취소, GET /img/p33 취소
```', 'SUBJECTIVE'),
       (4318, 689, '아래 상황에서 목록에 새로 교체해 넣은 구성 요소를 가리키는 용어는?', '상품 목록 화면에서 서버가 새 상품 3개를 화면에 보이는 구간 중간에 끼워 보내면, 배열을 고친 뒤 `reloadData()`를 호출하고 있었다. 그때마다 보이던 셀 11개가 모두 다시 구성되어 썸네일이 한꺼번에 깜빡였고, 행이 늘어나는 애니메이션 없이 목록이 순간적으로 바뀌었다.

테이블 뷰의 데이터 소스를 iOS 13부터 제공되는 다른 클래스로 교체하자, 처음에는 `Product`가 `Hashable`을 따르지 않는다는 컴파일 오류가 났다. 항목 자리에 `Product.ID`를 쓰도록 고쳐 빌드한 뒤 같은 갱신을 다시 확인하니, 셀 구성 클로저는 새 상품 3개에 대해서만 호출됐고 기존 행은 아래로 밀려나는 애니메이션과 함께 자리를 옮겼다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4313
(11675, 4313, '요청할 때의 indexPath로 셀을 다시 찾으므로 행이 한 칸 밀려도 운동화 셀에 정확히 들어간다.', 'indexPath는 요청 시점의 행 번호를 담은 값일 뿐 상품을 따라가지 않는다. 모자가 앞에 끼면서 운동화는 row 6으로 밀리고 row 5는 가방이 차지했으므로, 같은 indexPath로 찾은 셀은 운동화 셀이 아니다.', false),
(11676, 4313, '가방을 표시하는 셀에 운동화 이미지가 들어가고, 운동화 셀은 플레이스홀더로 남는다.', '삽입 뒤 가방은 row 5, 운동화는 row 6이다. 클로저가 붙잡은 row 5로 셀을 찾으니 가방 셀에 운동화 이미지가 들어가고, 기존 행은 다시 구성되지 않아 운동화 셀은 플레이스홀더 그대로다. indexPath 대신 상품 ID나 URL을 대조해야 막을 수 있다.', true),
(11677, 4313, '행 번호가 바뀌면 cellForRow(at:) 호출이 nil을 돌려주어 운동화 이미지는 어느 셀에도 반영되지 않는다.', 'cellForRow(at:)는 그 행이 화면에 보이기만 하면 셀을 돌려준다. 삽입 뒤에도 row 5는 화면 안에 있어 가방 셀이 반환되므로, 이미지는 버려지지 않고 엉뚱한 셀에 들어간다.', false),
(11678, 4313, '운동화 이미지가 가방 셀에 들어가지만, 운동화 셀은 삽입 때 다시 구성되어 곧 제 이미지를 받는다.', 'insertRows는 새로 들어온 row 0의 셀만 구성하고 이미 보이던 셀은 자리만 옮긴다. 운동화 행의 cellForRowAt이 다시 불리지 않아 새 요청도 나가지 않으므로 운동화 셀에는 플레이스홀더가 남는다.', false),

-- 문제 4314
(11679, 4314, '셀을 꺼내는 단계가 병목이므로 셀 인스턴스를 미리 넉넉히 만들어 두면 끊김이 사라진다.', '셀 꺼내기는 0.3ms로 전체 23.3ms 가운데 극히 일부다. 끊김은 셀을 얻는 비용이 아니라 꺼낸 뒤 구성하는 단계의 무거운 작업에서 생기므로, 인스턴스를 늘려도 프레임 시간은 거의 그대로다.', false),
(11680, 4314, '포맷터를 한 번만 만들어 재사용하면 새 행이 들어오는 프레임이 예산 안으로 들어온다.', '포맷터 비용 4.1ms를 통째로 없애도 0.3+18.5+0.4=19.2ms로 16.6ms를 넘는다. 포맷터 재사용 자체는 유효한 개선이지만, 가장 큰 비용인 디코딩이 메인 스레드에 남아 있는 한 끊김은 해소되지 않는다.', false),
(11681, 4314, '디코딩을 메인 스레드에서 빼지 않으면 나머지 단계를 모두 없애도 그 프레임은 예산을 넘긴다.', '디코딩 한 단계만 18.5ms로 16.6ms 예산보다 크다. 백그라운드에서 표시 크기로 다운샘플링해 디코딩하고 결과만 대입하도록 바꿔야 셀 구성이 값 대입 수준으로 가벼워진다.', true),
(11682, 4314, '값 대입을 백그라운드 스레드로 옮기면 메인 스레드의 프레임 시간이 크게 줄어든다.', '값 대입은 0.4ms뿐이라 옮겨도 줄어드는 몫이 거의 없다. 게다가 UIKit 뷰 속성은 메인 스레드에서만 바꿔야 하므로, 백그라운드로 보낼 대상은 대입이 아니라 디코딩 같은 계산 작업이다.', false),

-- 문제 4315
(11683, 4315, '첫 화면의 행은 회색 배경인데, 스크롤로 재사용된 셀이 놓인 행은 기본 배경이라 색이 섞여 보인다.', 'prepareForReuse는 큐에 있던 셀을 다시 쓸 때만 불린다. 스토리보드에서 막 만들어진 셀은 회색을 그대로 쓰고 재사용된 셀만 기본 배경이 된다. 초기 배경은 awakeFromNib에서 잡고 이전 항목 정리는 prepareForReuse에 두어야 한다.', true),
(11684, 4315, '첫 화면을 그릴 때도 셀마다 prepareForReuse가 먼저 불리므로 모든 행이 처음부터 기본 배경이다.', 'prepareForReuse는 재사용 경로에서만 호출되고, 스토리보드에서 새로 만들어진 셀은 이 단계를 건너뛴다. 그래서 첫 화면 10개 행은 스토리보드에 남은 회색 배경으로 표시된다.', false),
(11685, 4315, '큐에서 꺼낸 셀은 스토리보드에 지정한 초기 상태로 되돌아가므로 스크롤 뒤에도 모든 행이 회색이다.', '재사용 큐는 셀을 보관만 할 뿐 스토리보드 값으로 되돌리지 않는다. 다시 쓰일 때 prepareForReuse가 배경을 기본색으로 바꾸므로, 재사용된 셀이 놓인 행은 회색이 아니다.', false),
(11686, 4315, '재사용된 셀은 prepareForReuse가 텍스트를 비운 탓에 상태 문구가 빈칸으로 보인다.', 'prepareForReuse는 dequeue가 셀을 돌려주기 직전에 불리고, configure는 그 뒤 cellForRowAt에서 실행된다. 비운 텍스트를 곧바로 order.status로 다시 채우므로 상태 문구는 정상 표시된다.', false),

-- 문제 4316
(11687, 4316, '반환값이 옵셔널이라 호출부에서 nil이 왔을 때의 분기를 따로 두어야 한다.', 'nil을 돌려줄 수 있는 쪽은 indexPath를 받지 않는 dequeueReusableCell(withIdentifier:)이다. indexPath를 받는 버전은 옵셔널이 아닌 셀을 돌려주므로 nil 분기가 필요 없다.', false),
(11688, 4316, '같은 행을 다시 그릴 때는 그 행을 이전에 그렸던 셀 인스턴스가 돌아온다.', 'indexPath는 셀을 그 행에 맞게 준비하는 데 쓰일 뿐 행과 인스턴스를 묶어 두지 않는다. 큐에 남은 셀 가운데 하나가 돌아오므로, 같은 행이라도 그릴 때마다 다른 인스턴스일 수 있다.', false),
(11689, 4316, '돌려받은 셀은 행 크기가 반영되지 않아 frame을 행 높이에 직접 맞춰 주어야 한다.', 'indexPath를 함께 넘기는 이유 중 하나가 크기 조정이다. 테이블 뷰가 그 행의 크기를 알고 셀을 맞춰 돌려주므로 frame을 손으로 고칠 필요가 없다. 크기를 모르는 채 돌려받는 쪽은 indexPath 없는 버전이다.', false),
(11690, 4316, '식별자 등록을 빠뜨리면 nil을 받는 대신 호출 지점에서 바로 크래시가 나 원인을 찾기 쉽다.', '이 버전은 셀을 반드시 돌려주는 대신 등록을 전제로 하므로, 등록이 없으면 그 자리에서 예외로 멈춘다. nil이 조용히 흘러가 엉뚱한 곳에서 터지는 경우보다 원인 위치가 분명해 디버깅이 쉽다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1394, 4317, '프리페칭,프리페치,프리패칭,프리패치,prefetching,prefetch,pre-fetching,pre-fetch,데이터 프리페칭,UITableViewDataSourcePrefetching,UICollectionViewDataSourcePrefetching,prefetchRowsAt,미리 가져오기,선반입,사전 로딩,preloading', '로그에서 보이는 행이 row 12~19일 때 아직 화면에 없는 row 24·25의 이미지 요청이 먼저 나갔고, row 24가 들어온 순간 캐시 적중으로 바로 표시됐다. 테이블 뷰가 곧 보일 행의 indexPath를 넘겨주면 그 항목의 데이터를 앞서 요청해 두는 방식이 프리페칭이며, UITableViewDataSourcePrefetching의 prefetchRowsAt에서 요청을 시작하고 cancelPrefetchingForRowsAt에서 취소한다. 스크롤 방향이 바뀌자 p32·p33 요청이 취소된 것이 이 취소 콜백의 흔적이다. 메모리 캐시는 원래부터 있었으므로 450ms를 30ms로 줄인 요인이 아니다. 캐시는 이미 받은 이미지를 다시 쓰게 할 뿐 첫 요청 시점을 앞당기지 못한다. 셀이 보일 때 비로소 요청하는 지연 로딩(lazy loading)과는 요청 시점이 정반대다.'),
       (1395, 4318, 'Diffable Data Source,디퍼블 데이터 소스,디퍼블 데이터소스,디퍼블,diffable,diffable datasource,DiffableDataSource,UITableViewDiffableDataSource,UICollectionViewDiffableDataSource,디퍼러블 데이터 소스,디프어블 데이터 소스', 'Diffable Data Source(UITableViewDiffableDataSource)는 iOS 13부터 제공되며, 섹션과 항목 식별자를 담은 스냅샷을 받아 직전 스냅샷과 비교한 뒤 달라진 부분만 테이블 뷰에 반영한다. 항목 식별자가 Hashable이어야 하므로 Product를 그대로 넣자 컴파일 오류가 났고, 모델 전체보다 ID만 넣는 편이 변경 판단이 정확하고 메모리도 적다. 그래서 새로 끼운 3개 행에서만 셀 구성이 일어나고 기존 셀은 다시 구성되지 않은 채 애니메이션으로 밀려났다. reloadData()는 보이는 행을 통째로 다시 구성해 깜빡임이 생기고, performBatchUpdates 안에서 insertRows를 직접 부르는 방식은 부분 갱신은 되지만 삽입 위치와 개수를 손으로 맞춰야 해 어긋나면 크래시가 난다는 점에서 구분된다.');

-- =====================================================
-- Lesson 847: 셀 재구성 비용과 이미지 다운샘플링
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5261, 847, '아래 목록 화면 코드로 한참 스크롤했을 때 나타나는 동작으로 옳은 것은?', '`ProductCell`은 스토리보드 프로토타입 셀로 등록돼 있고 `prepareForReuse()`는 재정의하지 않았다. 상품은 3,000개이고 등급 문구는 상품마다 다르다. 한 화면에는 행 12개가 보인다.

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
    let product = products[indexPath.row]
    cell.titleLabel.text = product.name

    let gradeTag = UILabel(frame: CGRect(x: 12, y: 4, width: 72, height: 16))
    gradeTag.text = product.gradeText
    cell.contentView.addSubview(gradeTag)
    return cell
}
```', 'OBJECTIVE'),
       (5262, 847, '아래 코드에서 카테고리 필터를 바꾼 직후 목록에 나타나는 동작으로 옳은 것은?', '카테고리를 바꾸면 `products`를 새 목록으로 갈아 끼우고 `reloadData()`를 부른다. 두 카테고리의 상품은 하나도 겹치지 않고, 바꾸기 전 첫 화면 12개 행의 썸네일은 모두 받아 둔 상태다. 기기 메모리는 넉넉하다.

```swift
final class ThumbnailCache {
    static let shared = ThumbnailCache()
    private let cache = NSCache<NSNumber, UIImage>()
    func image(row: Int) -> UIImage? { cache.object(forKey: NSNumber(value: row)) }
    func store(_ image: UIImage, row: Int) { cache.setObject(image, forKey: NSNumber(value: row)) }
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
    let product = products[indexPath.row]
    cell.titleLabel.text = product.name

    if let cached = ThumbnailCache.shared.image(row: indexPath.row) {
        cell.thumbnail.image = cached
        return cell
    }
    cell.thumbnail.image = UIImage(named: "placeholder")
    ImageLoader.shared.load(product.imageURL) { image in
        ThumbnailCache.shared.store(image, row: indexPath.row)
        (tableView.cellForRow(at: indexPath) as? ProductCell)?.thumbnail.image = image
    }
    return cell
}
```', 'OBJECTIVE'),
       (5263, 847, '아래 측정표에서 읽어 낼 수 있는 내용으로 옳지 않은 것은?', '같은 상품 목록(항목 4,000개)을 세 가지로 구성해 60Hz 기기에서 측정했다. 한 프레임 예산은 약 16.6ms다.

| 구성 | 셀 확보 방식 | 셀 구성 단계에서 하는 일 | 첫 화면 표시까지 | 스크롤 중 평균 프레임 시간 | 살아 있는 셀 인스턴스 |
| --- | --- | --- | --- | --- | --- |
| A | 항목마다 셀을 미리 만들어 들고 있음 | 값 대입만 | 3.2초 | 8.9ms | 4,000개 |
| B | 재사용 큐에서 꺼내 씀 | 원본 이미지 동기 디코딩 + 값 대입 | 0.1초 | 27.4ms | 14개 |
| C | 재사용 큐에서 꺼내 씀 | 값 대입만 | 0.1초 | 7.6ms | 14개 |', 'OBJECTIVE'),
       (5264, 847, '아래 셀 공급 방식에 대한 설명으로 옳은 것은?', '테이블 뷰에는 셀 클래스와 문자열 하나를 미리 짝지어 등록해 둔다. 행을 그릴 때 그 문자열을 건네 셀을 요청하면, 화면을 벗어나 보관 중인 셀이 있으면 그 인스턴스를 돌려주고 없으면 짝지어 둔 클래스로 새 인스턴스를 만들어 돌려준다.', 'OBJECTIVE'),
       (5265, 847, '아래 셀 클래스에서 재정의한 메서드의 이름은?', '상품 목록을 빠르게 스크롤하면 이전 상품의 썸네일이 잠깐 보였다 바뀌고, 즐겨찾기 체크 표시가 엉뚱한 행에 켜진 채 나타났다. 셀 클래스에 아래 메서드를 재정의해 넣자 두 증상이 모두 사라졌다.

```swift
final class ProductCell: UITableViewCell {
    @IBOutlet private weak var thumbnail: UIImageView!
    private var imageTask: Task<Void, Never>?
    var onFavoriteTap: (() -> Void)?

    override func ____() {
        super.____()
        imageTask?.cancel()
        imageTask = nil
        thumbnail.image = nil
        accessoryType = .none
        onFavoriteTap = nil
    }
}
```

이 메서드 안에 로그를 남겨 보니 목록을 처음 띄우는 동안에는 한 줄도 찍히지 않았고, 화면 밖으로 밀려난 행이 생긴 뒤부터 새 행이 들어올 때마다 한 줄씩 찍혔다.', 'SUBJECTIVE'),
       (5266, 847, '아래 함수가 원본 이미지에 적용하는 처리를 가리키는 용어는?', '상품 목록의 썸네일은 120×120 포인트 자리에 놓이는데 서버가 주는 원본은 4,000×4,000 픽셀이다. `UIImage(data:)`로 원본을 그대로 올려 쓰는 동안에는 스크롤 중 평균 프레임 시간이 31ms, 목록이 쓰는 메모리가 820MB까지 올라 앱이 강제 종료되기도 했다. 아래 함수가 돌려준 이미지를 셀에 넣도록 바꾸자 프레임 시간은 7ms, 메모리는 90MB로 줄었다.

```swift
func makeThumbnail(from data: Data, pointSize: CGSize, scale: CGFloat) -> UIImage? {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }

    let maxPixel = max(pointSize.width, pointSize.height) * scale
    let thumbOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: maxPixel,
        kCGImageSourceCreateThumbnailWithTransform: true
    ] as CFDictionary

    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbOptions) else { return nil }
    return UIImage(cgImage: cgImage)
}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5261
(14203, 5261, '`addSubview`는 같은 자리에 놓인 기존 레이블을 새 레이블로 바꿔 다는 호출이라, 행에는 언제나 최신 등급 문구 하나만 보인다.', '`addSubview`는 교체가 아니라 뷰를 한 장 더 얹는 호출이다. 좌표와 크기가 같아도 아래에 깔린 레이블은 그대로 남아 글자가 겹쳐 보인다.', false),
(14204, 5261, '큐에서 꺼낸 셀에 이전 항목의 등급 레이블이 남은 채 새 레이블이 더해져, 문구가 겹쳐 보이고 셀의 서브뷰 수가 스크롤할수록 늘어난다.', '같은 인스턴스가 여러 행에 다시 쓰이는데 `cellForRowAt`이 불릴 때마다 레이블을 새로 붙인다. 붙인 레이블을 걷어 내는 코드가 없어 한 셀에 수십 장이 쌓인다.', true),
(14205, 5261, '셀이 재사용 큐로 들어갈 때 `contentView`에 붙은 서브뷰가 정리되므로, 다시 쓰인 셀에도 등급 레이블은 한 장뿐이다.', 'UIKit은 셀을 큐에 보관만 할 뿐 코드로 붙인 뷰를 걷어 내지 않는다. 정리는 `prepareForReuse()`나 셀 구성 코드에서 직접 해야 한다.', false),
(14206, 5261, '살아 있는 셀 인스턴스가 12개 남짓으로 유지되므로, 등급 레이블도 12장을 넘지 않아 겹침은 생기지 않는다.', '인스턴스 개수와 인스턴스 하나가 품은 서브뷰 개수는 다른 값이다. 셀이 12개여도 각 셀은 자신이 맡았던 행 수만큼 레이블을 떠안아 서브뷰가 계속 늘어난다.', false),

-- 문제 5262
(14207, 5262, '`reloadData()`가 불리면 테이블 뷰가 쓰던 이미지 캐시도 함께 비워지므로, 모든 행이 썸네일을 처음부터 다시 내려받는다.', '`reloadData()`는 데이터 소스에 행 정보를 다시 물어볼 뿐 앱이 따로 들고 있는 캐시에는 손대지 않는다. 캐시를 비우는 일은 필터를 바꾸는 코드에서 직접 해야 한다.', false),
(14208, 5262, '셀이 다시 쓰이기 직전에 썸네일을 비우는 정리 코드를 셀에 넣으면, 바뀐 목록에서도 사진이 제 상품에 맞춰진다.', '정리 코드는 이전 이미지를 잠깐 지울 뿐이고, 셀은 곧바로 같은 행 번호로 캐시를 조회해 같은 사진을 다시 꽂는다. 문제는 셀에 남은 흔적이 아니라 캐시 키에 있다.', false),
(14209, 5262, '새 목록의 행 수가 더 적으면 범위를 벗어난 캐시 항목이 함께 버려지므로, 남은 행은 모두 썸네일을 새로 내려받는다.', '`NSCache`는 테이블 뷰의 행 수를 모른다. 메모리 압박이 없는 한 넣어 둔 키는 그대로 남아, 새 목록의 행 번호와 겹치는 순간 다시 꺼내 쓰인다.', false),
(14210, 5262, '상품 이름은 새 카테고리의 값으로 바뀌는데, 썸네일만 바꾸기 전 목록의 사진이 그대로 걸린다.', '캐시 키가 상품이 아니라 행 번호라, 목록이 통째로 바뀌어도 row 0~11이라는 키는 살아남아 그대로 적중한다. 키를 상품 ID나 이미지 URL로 바꿔야 이름과 사진이 함께 움직인다.', true),

-- 문제 5263
(14211, 5263, 'A의 첫 화면이 3.2초나 걸린 것은 화면에 보이지도 않는 행의 셀까지 미리 만들었기 때문이므로, 항목이 4,000개보다 늘면 더 길어진다.', 'A의 인스턴스 수는 항목 수와 똑같은 4,000개다. 첫 화면을 띄우기 전에 항목 수만큼 셀을 만들어 두는 구성이라 항목이 늘면 준비 시간도 같이 늘어난다.', false),
(14212, 5263, 'B와 C는 셀을 얻는 방식이 같은데 프레임 시간이 세 배 넘게 벌어지므로, 끊김의 원인은 셀을 얻는 단계가 아니라 셀을 구성하는 단계에 있다.', '두 구성은 셀 구성 단계만 다른데 27.4ms와 7.6ms로 갈린다. 한 변수만 바뀐 비교라 원인을 구성 단계의 동기 디코딩으로 좁힐 수 있다.', false),
(14213, 5263, 'A는 셀을 미리 만들어 두어 스크롤 중에 셀을 새로 얻을 일이 없으므로, 프레임 시간이 세 구성 가운데 가장 짧다.', '표에서 A는 8.9ms로 C의 7.6ms보다 길어 가장 짧지 않다. 셀을 미리 만들어 두어도 스크롤 중 그리는 일은 그대로 남고, 큐에서 셀을 꺼내는 비용은 프레임 시간을 가를 만큼 크지 않다.', true),
(14214, 5263, 'C는 항목이 4,000개여도 셀 인스턴스가 14개에 머무르므로, 항목을 더 늘려도 셀 자체가 차지하는 메모리는 거의 그대로다.', '재사용 큐를 쓰면 살아 있는 셀 수가 한 화면에 보이는 개수 언저리에 묶인다. 메모리가 항목 수를 따라가지 않는 것이 인스턴스 4,000개를 들고 있는 A와 갈리는 지점이다.', false),

-- 문제 5264
(14215, 5264, '한 화면에 생김새가 다른 행을 섞으려면 문자열을 갈라 등록해야 하고, 보관되는 셀도 문자열별로 따로 묶여 서로 건너가 쓰이지 않는다.', '보관과 반환의 기준이 문자열이다. 구조가 다른 헤더형·상품형 행에 같은 문자열을 쓰면 서브뷰 구성이 맞지 않는 셀이 돌아오므로, 문자열을 나눠 재사용 큐를 따로 두어야 한다.', true),
(14216, 5264, '보관되는 셀은 문자열 하나당 한 개뿐이라, 같은 문자열을 쓰는 행이 화면에 여러 개 보이면 그 행들이 한 인스턴스를 번갈아 쓴다.', '재사용 큐에는 화면을 벗어난 셀이 여러 개 쌓일 수 있고, 동시에 보이는 행은 각각 다른 인스턴스를 받는다. 한 인스턴스를 나눠 쓴다면 보이는 행이 모두 같은 내용으로 보일 것이다.', false),
(14217, 5264, '스토리보드에서 프로토타입 셀에 식별자를 적어 두었더라도, 코드에서 `register(_:forCellReuseIdentifier:)`를 한 번 더 불러야 셀을 받을 수 있다.', '프로토타입 셀은 테이블 뷰가 올라올 때 그 식별자로 자동 등록된다. 오히려 코드로 다시 등록하면 스토리보드에서 이어 둔 뷰 연결이 없는 셀로 덮어써 `@IBOutlet`이 nil인 채 돌아온다.', false),
(14218, 5264, '요청할 때 넘긴 문자열이 등록해 둔 것과 다르면, 가장 최근에 등록한 셀 클래스로 인스턴스를 만들어 돌려준다.', '문자열이 곧 어떤 셀을 만들지 정하는 열쇠라 대신 쓸 클래스를 고르는 규칙 자체가 없다. 등록하지 않은 문자열을 넘기면 그 자리에서 예외로 멈춘다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1710, 5265, 'prepareForReuse,prepareForReuse(),prepare for reuse,prepare_for_reuse,프리페어포리유즈,프리페어 포 리유즈,프리페어포리유스', '큐에 있던 셀이 다음 행에 배정되기 직전 한 번 호출되는 메서드가 prepareForReuse()다. 여기서 이전 항목의 이미지·선택 표시·콜백을 지우고 진행 중이던 다운로드를 취소해, 다시 쓰인 셀이 이전 항목의 흔적을 들고 화면에 나오는 일을 막는다. 로그가 첫 화면에서 한 줄도 남지 않은 것이 이 메서드의 경계를 보여 준다. 새로 만들어진 셀은 이 단계를 거치지 않으므로, 폰트·제약 조건 같은 항목과 무관한 초기 설정은 init이나 awakeFromNib에 두고 항목별 값은 configure처럼 셀을 구성하는 자리에서 넣어야 한다. 여기에 새 데이터를 세팅하면 첫 화면에 뜬 셀만 값이 비는 버그가 생긴다. 셀이 만들어질 때 한 번 불리는 awakeFromNib, 뷰가 화면에 붙을 때 불리는 didMoveToWindow와는 호출 시점이 다르다.'),
       (1711, 5266, '다운샘플링,다운 샘플링,다운샘플,downsampling,down sampling,down-sampling,downsample,이미지 다운샘플링,image downsampling', '`CGImageSourceCreateThumbnailAtIndex`에 표시 크기(포인트 × 화면 배율)를 최대 픽셀로 넘겨, 원본을 통째로 펼치지 않고 필요한 크기의 비트맵만 만들어 내는 처리가 다운샘플링이다. 4,000×4,000 이미지를 픽셀당 4바이트로 펼치면 한 장에 약 61MB지만, 120포인트 자리에 배율 3배면 360×360으로 약 0.5MB면 된다. 셀마다 이 차이가 쌓여 메모리와 디코딩 시간이 함께 줄고, 스크롤 중 프레임 시간이 31ms에서 7ms로 내려간 이유도 여기에 있다. 이미 펼쳐 둔 UIImage를 작게 그려 내는 리사이즈는 원본 디코딩 비용을 이미 치른 뒤라 메모리 급증을 막지 못하고, 요청 시점을 앞당기는 프리페칭이나 받은 결과를 다시 쓰는 캐시와도 손대는 지점이 다르다.');
