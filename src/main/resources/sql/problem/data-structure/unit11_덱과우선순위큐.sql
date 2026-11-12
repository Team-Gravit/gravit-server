-- Unit: 덱과 우선순위 큐 (Unit ID: 228)
-- Chapter: 자료구조 (Chapter ID: 1)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (970, 228, '덱의 양 끝 연산과 스택·큐 대체'),
       (971, 228, '슬라이딩 윈도우 최댓값과 덱 활용'),
       (972, 228, '우선순위 큐의 삭제 순서와 언어별 구현');

-- =====================================================
-- Lesson 970: 덱의 양 끝 연산과 스택·큐 대체
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5999, 970, '아래 연산을 모두 수행한 뒤 Front부터 Rear 순서로 남아 있는 원소는?', '비어 있는 덱에 아래 연산을 차례로 수행한다.

```java
Deque<Integer> dq = new ArrayDeque<>();
dq.addLast(10);
dq.addFirst(20);
dq.addLast(30);
dq.removeFirst();
dq.addFirst(40);
dq.removeLast();
dq.addLast(50);
```', 'OBJECTIVE'),
       (6000, 970, '대기 인원이 늘었을 때 아래 세 기능의 처리 시간 변화로 옳은 것은?', '놀이공원 대기 앱은 대기자를 덱 하나에 담는다.

- **등록:** 새 대기자는 addLast()로 Rear에 붙는다.
- **입장:** 차례가 오면 removeFirst()로 Front에서 뺀다.
- **취소:** 대기 도중 "줄 서기 취소"를 누르면 그 사람을 덱 안에서 찾아 지운다.

주말이 되자 대기 인원이 평소 1,000명에서 100,000명으로 늘었다.', 'OBJECTIVE'),
       (6001, 970, '아래 리뷰 의견대로 고친 코드로 옳은 것은?', '문서 편집기의 실행 취소 기록을 다루는 코드다.

```java
Stack<String> undo = new Stack<>();
undo.push("타이핑");
undo.push("굵게");
undo.push("삭제");
String last = undo.pop();  // "삭제"
```

리뷰 의견: 레거시 Stack 클래스 대신 Java 공식 문서가 권장하는 표준 덱 구현체로 바꿀 것. 단, 가장 마지막에 한 작업이 가장 먼저 취소되는 지금의 동작은 그대로 유지할 것.', 'OBJECTIVE'),
       (6002, 970, '위 표를 바탕으로 한 설명으로 옳지 않은 것은?', '두 언어가 제공하는 표준 덱 구현체를 정리한 표다.

| 구현체 | 언어 | 내부 구조 | 양 끝 삽입·삭제 | 중간 원소 삭제 |
| --- | --- | --- | --- | --- |
| collections.deque | Python | 이중 연결 리스트 | O(1) | O(n) |
| ArrayDeque | Java | 원형 배열 | O(1) | O(n) |', 'OBJECTIVE'),
       (6003, 970, '아래 코드에서 dq가 데이터를 내보내는 순서 규칙을 가리키는 용어는? (영문 약어 또는 한글 용어)', '```python
from collections import deque

dq = deque()
for ch in "ABC":
    dq.appendleft(ch)

out = ""
while dq:
    out += dq.popleft()
print(out)
```', 'SUBJECTIVE'),
       (6004, 970, '아래 코드가 출력하는 값은?', '최근 기록을 최대 3개까지만 보관하는 코드다.

```java
Deque<Integer> recent = new ArrayDeque<>();
int[] inputs = {7, 2, 9, 4, 6};
for (int x : inputs) {
    if (recent.size() == 3) {
        recent.removeFirst();
    }
    recent.addLast(x);
}
System.out.println(recent.peekFirst());
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5999
(16171, 5999, '50, 10, 40', '최종 상태를 Rear부터 거꾸로 읽은 결과다. addFirst(40)은 Front 쪽에 붙으므로 Front부터 읽으면 40이 맨 앞에 온다.', false),
(16172, 5999, '40, 10, 50', '[10] → [20, 10] → [20, 10, 30] → removeFirst로 20 제거 [10, 30] → [40, 10, 30] → removeLast로 30 제거 [40, 10] → [40, 10, 50]이 된다.', true),
(16173, 5999, '20, 10, 50', 'removeFirst와 removeLast의 방향을 바꿔 본 결과다. removeFirst는 Front의 20을, removeLast는 Rear의 30을 빼야 한다.', false),
(16174, 5999, '20, 30, 50', 'addFirst를 Rear 삽입으로 오해해 모든 값을 뒤에 붙인 결과다. addFirst는 Front에 넣으므로 20과 40은 앞쪽에 들어간다.', false),
-- 문제 6000
(16175, 6000, '세 기능 모두 덱 연산이므로 대기 인원과 무관하게 거의 같은 시간에 끝난다.', '덱이면 모든 연산이 O(1)이라는 오해다. 덱은 양 끝 연산에만 최적화돼 있어, 중간에 있는 사람을 찾아 지우는 취소는 O(n)이다.', false),
(16176, 6000, '세 기능 모두 대기 인원에 비례해 느려져, 등록과 입장도 약 100배 오래 걸린다.', '원소 수가 늘면 모든 연산이 느려진다고 본 오해다. addLast·removeFirst는 양 끝만 건드리는 O(1)이라 인원 수와 무관하다.', false),
(16177, 6000, '등록·입장은 그대로이고, 취소는 대기 인원의 로그에 비례해 조금만 느려진다.', '힙의 O(log n)을 덱에 갖다 붙인 오해다. 덱은 중간 원소를 빠르게 찾는 구조가 없어 앞에서부터 차례로 찾아야 하므로 O(n)이다.', false),
(16178, 6000, '등록·입장은 그대로이고, 취소는 대기 인원에 비례해 약 100배까지 느려질 수 있다.', '등록·입장은 양 끝 연산이라 O(1)이지만, 취소는 중간 위치의 원소를 찾아 지워야 해 O(n)이다. 인원이 100배가 되면 최악 탐색 길이도 100배가 된다.', true),
-- 문제 6001
(16179, 6001, 'Deque<String> undo = new ArrayDeque<>(); 선언 후 addLast()로 넣고 removeLast()로 꺼낸다.', '넣는 끝과 빼는 끝이 같은 Rear라서 마지막에 넣은 "삭제"가 먼저 나오는 LIFO가 유지된다. ArrayDeque는 Java가 Stack 대신 쓰라고 권장하는 구현체다.', true),
(16180, 6001, 'Deque<String> undo = new ArrayDeque<>(); 선언 후 addLast()로 넣고 removeFirst()로 꺼낸다.', '넣는 끝과 빼는 끝이 반대라 큐(FIFO)처럼 동작한다. 가장 먼저 넣은 "타이핑"이 먼저 취소돼 리뷰 조건을 어긴다.', false),
(16181, 6001, 'Deque<String> undo = new ArrayDeque<>(); 선언 후 addFirst()로 넣고 removeLast()로 꺼낸다.', 'Front에 넣고 Rear에서 빼므로 역시 반대쪽 끝을 쓰는 FIFO다. 메서드 이름만 바꿨을 뿐 가장 오래된 "타이핑"이 먼저 나온다.', false),
(16182, 6001, 'PriorityQueue<String> undo = new PriorityQueue<>(); 선언 후 offer()로 넣고 poll()로 꺼낸다.', '우선순위 큐는 넣은 순서가 아니라 값의 우선순위(문자열은 사전 순으로 작은 값)로 꺼낸다. 최근 작업이 먼저 나온다는 보장이 없다.', false),
-- 문제 6002
(16183, 6002, 'collections.deque는 popleft()를 해도 남은 원소를 한 칸씩 옮기지 않고 맨 앞 노드의 연결만 끊는다.', '이중 연결 리스트라 맨 앞 노드를 떼고 다음 노드를 새 Front로 삼으면 끝난다. 그래서 표에서 양 끝 삭제가 O(1)이다. 참인 진술이다.', false),
(16184, 6002, '두 구현체 모두 원소가 10배로 늘면 가운데 원소 하나를 지우는 시간도 대체로 그만큼 늘어난다.', '표에서 중간 원소 삭제는 둘 다 O(n)이다. 시간이 원소 수에 비례하므로 10배면 대략 10배가 된다. 참인 진술이다.', false),
(16185, 6002, 'ArrayDeque는 배열 기반이라 removeFirst() 때마다 뒤 원소를 앞으로 당겨야 해 원소 수에 비례한 시간이 든다.', '거짓이다. 원형 배열은 원소를 옮기지 않고 Front 위치만 다음 칸으로 옮기므로, 표처럼 양 끝 삭제가 O(1)이다. 일반 배열의 앞 삭제와 혼동한 것이다.', true),
(16186, 6002, '두 구현체 모두 맨 앞과 맨 뒤 원소를 지우지 않고 조회만 하는 데 원소 수와 무관한 시간이 든다.', '양 끝 원소는 Front·Rear 위치로 바로 닿으므로 peekFirst·peekLast 같은 조회도 O(1)이다. 참인 진술이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1956, 6003, 'LIFO,후입선출,후입 선출,Last In First Out,Last-In First-Out,Last-In-First-Out,FILO,선입후출,선입 후출,First In Last Out,First-In Last-Out,First-In-Last-Out', 'appendleft()로 A, B, C를 차례로 Front에 넣으면 덱은 [C, B, A]가 되고, popleft()로 같은 Front에서 꺼내면 C, B, A 순으로 나와 CBA가 출력된다. 넣는 끝과 빼는 끝이 같은 한쪽 끝이라 가장 나중에 넣은 값이 가장 먼저 나오는 LIFO(후입선출)다. 먼저 넣은 값이 가장 늦게 나온다는 같은 규칙을 반대쪽에서 부른 FILO(선입후출)도 같은 뜻이다. 덱은 한쪽 끝만 쓰면 스택처럼 동작하며, 그 끝이 Rear(append·pop)든 Front(appendleft·popleft)든 상관없다. 넣는 끝과 빼는 끝이 서로 반대여야 먼저 넣은 값이 먼저 나오는 FIFO(선입선출)가 되므로, 메서드 이름에 left가 붙었다고 해서 큐로 착각하지 않도록 주의한다.'),
       (1957, 6004, '9', '보관 개수가 3개가 되면 Front에서 가장 오래된 값을 빼고 Rear에 새 값을 붙인다. [7] → [7, 2] → [7, 2, 9] → 7을 빼고 [2, 9, 4] → 2를 빼고 [9, 4, 6]이 되므로 peekFirst()는 9를 돌려준다. 덱을 addLast·removeFirst로만 쓰면 큐(FIFO)처럼 동작해 가장 오래된 기록부터 밀려나는 구조다. 삭제 없이 조회만 하는 peekFirst를 Rear 조회인 peekLast로 착각하면 6, 오래된 값을 빼는 단계를 빠뜨리면 처음 넣은 7로 잘못 답하게 된다.');

-- =====================================================
-- Lesson 971: 슬라이딩 윈도우 최댓값과 덱 활용
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6005, 971, '아래 함수 호출의 반환값은?', '```python
from collections import deque

def sliding_window_max(nums, k):
    dq = deque()
    result = []
    for i, num in enumerate(nums):
        if dq and dq[0] <= i - k:
            dq.popleft()
        while dq and nums[dq[-1]] < num:
            dq.pop()
        dq.append(i)
        if i >= k - 1:
            result.append(nums[dq[0]])
    return result

sliding_window_max([9, 4, 2, 6, 1, 3], 3)
```', 'OBJECTIVE'),
       (6006, 971, '아래 호출에서 i = 5를 처리한 직후 dq에 들어 있는 내용은?', '아래 함수를 nums = [4, 2, 12, 3, 8, 1, 5], k = 3으로 호출한다.

```python
def sliding_window_max(nums, k):
    dq = deque()
    result = []
    for i, num in enumerate(nums):
        if dq and dq[0] <= i - k:
            dq.popleft()
        while dq and nums[dq[-1]] < num:
            dq.pop()
        dq.append(i)
        if i >= k - 1:
            result.append(nums[dq[0]])
    return result
```', 'OBJECTIVE'),
       (6007, 971, '아래 측정 결과가 나온 이유로 옳은 것은?', '길이 n = 100,000인 배열에서 크기 k = 50,000인 윈도우를 한 칸씩 옮기며 구간마다 최댓값을 구하는 두 구현의 실행 시간을 쟀다.

- **구현 A:** 윈도우가 한 칸 움직일 때마다 그 구간의 k개 값을 처음부터 훑어 최댓값을 찾는다.
- **구현 B:** 덱에 인덱스를 값의 내림차순으로 유지한다. 새 값이 오면 Rear에서 그보다 작은 값의 인덱스를 지운 뒤 붙이고, 윈도우를 벗어난 인덱스는 Front에서 지운다. 구간 최댓값은 Front에서 읽는다.

| 구현 | 실행 시간 |
| --- | --- |
| A | 41.7초 |
| B | 0.06초 |', 'OBJECTIVE'),
       (6008, 971, '아래 함수에 넣었을 때 True를 반환하는 입력은?', '```python
from collections import deque

def check(s):
    dq = deque(s)
    while len(dq) > 1:
        if dq.popleft() != dq.pop():
            return False
    return True
```', 'OBJECTIVE'),
       (6009, 971, '아래 호출이 끝날 때까지 dq.pop()이 실행되는 총 횟수는?', '아래 함수를 nums = [3, 1, 4, 1, 5, 9, 2], k = 3으로 호출한다.

```python
def sliding_window_max(nums, k):
    dq = deque()
    result = []
    for i, num in enumerate(nums):
        if dq and dq[0] <= i - k:
            dq.popleft()
        while dq and nums[dq[-1]] < num:
            dq.pop()
        dq.append(i)
        if i >= k - 1:
            result.append(nums[dq[0]])
    return result
```', 'SUBJECTIVE'),
       (6010, 971, '아래 대시보드가 표시값을 계산하는 방식을 가리키는 알고리즘 기법의 이름은?', '서버 모니터링 대시보드는 매초 CPU 사용률을 받아 아래처럼 표시값을 띄운다.

| 시각(초) | 1 | 2 | 3 | 4 | 5 | 6 |
| --- | --- | --- | --- | --- | --- | --- |
| CPU(%) | 35 | 80 | 20 | 15 | 60 | 10 |
| 표시값 | - | - | 80 | 80 | 60 | 60 |

4초 표시값을 낼 때는 1초의 35가 계산에서 빠지고 4초의 15가 새로 들어왔다. 5초에는 2초의 80이 빠져 표시값이 60으로 내려갔고, 매초 값이 하나 들어올 때 하나가 빠지므로 한 번에 계산에 쓰이는 값은 늘 3개다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6005
(16187, 6005, '[9, 9, 9, 9]', '윈도우를 벗어난 인덱스를 Front에서 빼는 단계를 무시한 결과다. i = 3에서 인덱스 0(값 9)은 범위 밖이라 popleft로 제거돼야 한다.', false),
(16188, 6005, '[9, 9, 9, 6, 6, 6]', 'i >= k - 1 조건을 무시해 윈도우가 다 차기 전에도 값을 담은 결과다. 길이 6, k = 3이면 윈도우는 4개뿐이다.', false),
(16189, 6005, '[9, 6, 6, 6]', '윈도우는 [9,4,2], [4,2,6], [2,6,1], [6,1,3]이다. i = 3에서 만료된 9를 빼고 6보다 작은 값을 Rear에서 지워 Front에 6이 남는다.', true),
(16190, 6005, '[2, 2, 1, 1]', '각 구간의 최솟값을 구한 결과다. while 조건이 Rear의 더 작은 값을 지우므로 Front에는 큰 값이 남아 최댓값이 나온다.', false),
-- 문제 6006
(16191, 6006, '[4, 5]', 'i = 4 직후 [2, 4]에서, i = 5에는 인덱스 2가 5 - 3 = 2 이하라 popleft로 빠진다. nums[4] = 8은 1보다 커 남고 5를 붙여 [4, 5]가 된다.', true),
(16192, 6006, '[2, 4, 5]', '윈도우를 벗어난 인덱스 2를 Front에서 빼는 단계를 놓쳤다. 조건 dq[0] <= i - k는 2 <= 2로 참이라 popleft가 실행된다.', false),
(16193, 6006, '[5]', '비교 방향을 거꾸로, 현재 값보다 큰 값을 지운다고 본 결과다. 코드는 nums[dq[-1]] < num일 때만 지우므로 8은 1보다 커서 남는다.', false),
(16194, 6006, '[8, 1]', 'dq에 값이 들어간다고 본 오해다. 코드는 dq.append(i)로 인덱스를 넣고, 값은 nums[dq[0]]처럼 인덱스로 찾아 읽는다.', false),
-- 문제 6007
(16195, 6007, '구현 B도 새 값 하나에 Rear에서 최대 k번 지울 수 있어 A와 같은 O(n·k)이고, 차이는 덱의 상수 배 속도 덕이다.', '한 단계의 최악을 n번 곱한 오해다. 한 번 지워진 인덱스는 다시 들어오지 않으므로 지우는 작업은 전체를 다 합쳐도 n번을 넘지 못한다.', false),
(16196, 6007, '구현 B는 값을 넣을 때마다 덱 전체를 정렬된 상태로 다시 맞추므로 힙처럼 O(n log n)이 걸린다.', '힙의 동작을 덱에 갖다 붙인 오해다. B는 정렬하지 않고 Rear에서 작은 값을 버리기만 하며, 각 연산이 O(1)이다.', false),
(16197, 6007, '두 구현 모두 원소마다 한 번씩만 일을 하는 O(n)이고, 차이는 B가 더 빠른 덱 구현체를 쓴 덕이다.', 'A를 O(n)으로 본 오해다. A는 윈도우 n - k + 1개마다 k개를 다시 훑어 O(n·k)이고, k가 클수록 이 곱이 수백 배 차이를 만든다.', false),
(16198, 6007, '구현 B는 각 인덱스가 덱에 한 번 들어가고 많아야 한 번 빠지므로, 지우는 작업을 다 합쳐도 n에 비례한다.', '인덱스마다 삽입 1번, Rear 또는 Front 삭제 최대 1번이라 전체 연산이 O(n)이다. 반면 A는 윈도우마다 k개를 다시 훑어 O(n·k)라 큰 k에서 격차가 커진다.', true),
-- 문제 6008
(16199, 6008, 'abcdba', '바깥쪽 두 쌍(a·a, b·b)만 보고 판단한 오류다. 세 번째 비교에서 c와 d가 달라 False를 반환한다.', false),
(16200, 6008, 'abcba', 'Front와 Rear에서 a·a, b·b를 차례로 꺼내 같음을 확인하면 c 하나만 남아 반복이 끝나고 True다. 양 끝을 동시에 줄여 가는 회문 검사다.', true),
(16201, 6008, 'abcab', '앞뒤를 뒤집어도 같은 글자들이 들어 있으면 된다고 본 오해다. 첫 비교에서 Front의 a와 Rear의 b가 달라 곧바로 False다.', false),
(16202, 6008, 'abccab', '가운데 cc만 짝이 맞으면 된다고 본 오류다. 비교는 바깥에서 안쪽으로 진행해 첫 쌍 a와 b부터 달라 False다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1958, 6009, '5,5회,5번,다섯 번', 'i마다 dq 상태를 따라가면 다음과 같다. i = 0: [0]. i = 1: nums[0] = 3이 1보다 커 그대로 [0, 1]. i = 2: 값 4보다 작은 1·3을 Rear에서 두 번 pop해 [2]. i = 3: 4가 1보다 커 [2, 3]. i = 4: 값 5보다 작은 1·4를 두 번 pop해 [4]. i = 5: 값 9보다 작은 5를 한 번 pop해 [5]. i = 6: 9가 2보다 커 [5, 6]. 따라서 pop은 2 + 2 + 1 = 5번이다. 이 입력에서는 dq[0]이 윈도우를 벗어나기 전에 항상 더 큰 값에 밀려 Rear에서 먼저 지워지므로 Front 쪽 popleft는 한 번도 실행되지 않는다. Front에서 빼는 popleft(만료 처리)와 Rear에서 빼는 pop(작은 값 제거)을 구분하는 것이 핵심이며, 전체 pop 횟수가 원소 수 7을 넘지 못한다는 점이 O(n) 보장의 근거다.'),
       (1959, 6010, '슬라이딩 윈도우,슬라이딩윈도우,슬라이딩 윈도,sliding window,slidingwindow,sliding-window,이동 윈도우', '표시값은 3초부터 매초 직전 3개 값의 최댓값이다. 3초는 35·80·20 중 80, 4초는 80·20·15 중 80, 5초는 20·15·60 중 60, 6초는 15·60·10 중 60이다. 이처럼 크기가 3으로 고정된 구간(윈도우)을 한 칸씩 밀며 새 값 하나를 넣고 가장 오래된 값 하나를 빼는 방식이 슬라이딩 윈도우다. 구간 최댓값은 덱에 인덱스를 값 내림차순으로 유지하면 Front에서 바로 읽을 수 있어, 매번 3개를 다시 훑지 않고 전체 O(n)에 구할 수 있다. 시작부터 그 시점까지의 값을 모두 쌓아 계산하는 누적 방식과 달리 오래된 값이 계산에서 빠진다는 점이 핵심이며, 그래서 2초의 80이 빠진 5초에 표시값이 60으로 내려갔다.');

-- =====================================================
-- Lesson 972: 우선순위 큐의 삭제 순서와 언어별 구현
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (6011, 972, '아래 연산을 우선순위 큐에 차례로 적용할 때 pop()이 꺼내는 작업의 순서는?', '괄호 안 두 번째 값은 작업의 우선순위이며, 숫자가 작을수록 우선순위가 높다.

```
push(A, 3)
push(B, 1)
pop()
push(C, 4)
push(D, 2)
pop()
pop()
```', 'OBJECTIVE'),
       (6012, 972, '아래 작업 패턴에서 하루 전체의 연산 비용이 가장 작은 우선순위 큐 구현 방식은?', '보안 로그 수집기는 하루 동안 이벤트 n건(약 1,000,000건)을 위험도와 함께 우선순위 큐에 넣는다. 하루 중에는 꺼내는 일이 없고, 자정에 위험도가 가장 높은 이벤트 단 1건만 꺼내 보고한 뒤 큐를 통째로 비운다.', 'OBJECTIVE'),
       (6013, 972, '아래 코드의 출력은?', '```python
import heapq

scores = [40, 90, 70]
pq = []
for s in scores:
    heapq.heappush(pq, -s)

first = -heapq.heappop(pq)
print(first, pq[0])
```', 'OBJECTIVE'),
       (6014, 972, '아래 코드가 기대와 다르게 동작한 원인과 해결로 옳은 것은?', '점수가 가장 높은 항목부터 처리하려고 작성한 코드다. 3이 출력되기를 기대했지만 실제로는 1이 출력되었다.

```java
PriorityQueue<Integer> pq = new PriorityQueue<>();
pq.offer(3);
pq.offer(1);
pq.offer(2);
System.out.println(pq.poll());
```', 'OBJECTIVE'),
       (6015, 972, '아래 코드가 출력하는 작업 이름은?', '```python
import heapq

pq = []
jobs = [(2, "backup"), (5, "deploy"), (3, "report"), (4, "alert")]
for pri, name in jobs:
    heapq.heappush(pq, (-pri, name))

heapq.heappop(pq)
print(heapq.heappop(pq)[1])
```', 'SUBJECTIVE'),
       (6016, 972, '아래 실행 로그를 남긴 그래프 알고리즘의 이름은?', '간선은 A-B(4), A-C(1), C-B(2), B-D(5)이다. 알고리즘은 큐에 (값, 정점) 쌍을 넣고, 매번 값이 가장 작은 쌍부터 꺼낸다.

```
pop (0, A) : B = 4, C = 1 로 갱신
pop (1, C) : B = 3 으로 갱신
pop (3, B) : D = 8 로 갱신
pop (4, B) : B는 이미 확정됨, 건너뜀
pop (8, D) : 종료
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 6011
(16203, 6011, 'A, B, C', '들어온 순서대로 꺼내는 FIFO 큐로 본 결과다. 우선순위 큐는 삽입 순서와 무관하게 그 시점에 우선순위가 가장 높은 작업을 꺼낸다.', false),
(16204, 6011, 'B, D, A', '첫 pop 시점엔 A(3)·B(1) 중 B, 이후 A(3)·C(4)·D(2) 중 D, 남은 A(3)·C(4) 중 A가 나온다. 각 pop 시점에 남아 있는 것 중 최우선을 꺼낸다.', true),
(16205, 6011, 'B, D, C', '가장 나중에 넣은 것부터 꺼내는 LIFO로 본 결과다. 마지막 pop에서 A(3)가 C(4)보다 우선순위가 높으므로 A가 나와야 한다.', false),
(16206, 6011, 'A, C, D', '큰 숫자를 높은 우선순위로 거꾸로 읽은 결과다. 본문은 숫자가 작을수록 우선순위가 높다고 했으므로 첫 pop은 B(1)다.', false),
-- 문제 6012
(16207, 6012, '정렬되지 않은 배열', '삽입은 끝에 붙이기만 해 O(1)이고, 전체 탐색 O(n)인 삭제는 단 1번뿐이다. n번 삽입 + 1번 삭제 = O(n)으로 가장 싸다.', true),
(16208, 6012, '정렬된 배열', '삭제가 O(1)인 장점만 본 오해다. 삽입마다 위치를 찾아 끼워 넣느라 O(n)이 들어 n번 삽입이면 O(n²)이고, 삭제는 단 1번이라 이점이 거의 없다.', false),
(16209, 6012, '힙', '표준 구현이라 늘 최선이라고 본 오해다. 삽입마다 O(log n)이 들어 전체 O(n log n)으로, 삽입·삭제가 고르게 섞일 때 유리한 균형형 선택이다.', false),
(16210, 6012, '정렬된 연결리스트', '노드 연결만 바꾸면 삽입이 빠르다고 본 오해다. 끼울 위치를 앞에서부터 찾아야 해 삽입마다 O(n), 전체 O(n²)이 든다.', false),
-- 문제 6013
(16211, 6013, '90 70', 'pq에는 여전히 부호를 뒤집은 값이 저장돼 있다는 점을 놓쳤다. first만 -1을 다시 곱했을 뿐 pq[0]은 -70 그대로다.', false),
(16212, 6013, '-90 -70', '꺼낸 값에 다시 -1을 곱하는 단계를 놓쳤다. heappop은 -90을 돌려주고 앞의 마이너스로 first는 90이 된다.', false),
(16213, 6013, '90 -70', '-40, -90, -70을 넣은 최소 힙에서 heappop은 가장 작은 -90을 꺼내 first = 90이다. 남은 -70, -40 중 최솟값 -70이 pq[0]이다.', true),
(16214, 6013, '40 -90', 'heapq를 최대 힙으로 오해해 -40이 먼저 나온다고 본 결과다. heapq는 최소 힙만 지원하므로 가장 작은 -90이 먼저 나온다.', false),
-- 문제 6014
(16215, 6014, 'poll()은 최솟값을 꺼내는 메서드이므로 최댓값을 꺼내는 pollLast()로 바꿔 호출해야 한다.', '덱의 양 끝 메서드를 우선순위 큐에 갖다 붙인 오해다. PriorityQueue는 양 끝 개념이 없고, 무엇이 먼저 나올지는 생성 시 정한 비교 기준이 결정한다.', false),
(16216, 6014, 'Java PriorityQueue는 최소 힙만 지원하므로 값에 -1을 곱해 넣고 꺼낼 때 다시 -1을 곱해야 한다.', 'Python heapq의 제약을 Java에 옮긴 오해다. Java는 생성자에 Comparator를 넘겨 순서를 바꿀 수 있어 부호 뒤집기가 필요 없다.', false),
(16217, 6014, '내부가 반정렬 상태라 poll() 결과가 호출마다 달라질 수 있으므로, 먼저 정렬한 뒤 꺼내야 한다.', '반정렬을 무작위로 오해했다. 힙은 루트에 늘 최우선 원소를 두므로 poll()은 기준에 따라 항상 같은 값을 꺼낸다.', false),
(16218, 6014, '비교 기준 없이 만들면 작은 값이 먼저 나오므로, 생성자에 Comparator.reverseOrder()를 넘기면 3이 먼저 나온다.', 'PriorityQueue는 기본이 최소 힙이라 1이 먼저 나왔다. Comparator.reverseOrder()를 주면 큰 값이 우선인 최대 힙이 돼 poll()이 3을 꺼낸다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1960, 6015, 'alert', '우선순위에 -1을 곱한 (-2, backup), (-5, deploy), (-3, report), (-4, alert)를 최소 힙인 heapq에 넣었다. 튜플은 첫 값부터 비교하므로 가장 작은 -5(deploy)가 먼저 꺼내지고, 두 번째로는 -4(alert)가 나온다. 즉 부호를 뒤집어 원래 우선순위 숫자가 클수록 먼저 나오는 최대 힙처럼 쓴 것이다. 부호를 뒤집지 않았다면 backup(2)이 먼저, report(3)가 두 번째로 나왔을 것이고, 첫 heappop의 결과를 출력한다고 착각하면 deploy로 답하게 된다. 출력하는 것은 두 번째 heappop의 [1], 즉 작업 이름이다.'),
       (1961, 6016, '다익스트라,다익스트라 알고리즘,데이크스트라,데이크스트라 알고리즘,Dijkstra,Dijkstra algorithm,dijkstra 알고리즘', '로그의 값은 출발점 A에서 그 정점까지 누적된 거리다. C를 꺼낸 뒤 B가 4에서 1 + 2 = 3으로 줄었고, D는 3 + 5 = 8로 기록됐다. 우선순위 큐에서 누적 거리가 가장 작은 정점을 꺼내 확정하고 이웃의 거리를 갱신하는 과정이 다익스트라 최단 경로 알고리즘이다. 늦게 꺼내진 (4, B)는 더 짧은 거리로 이미 확정됐으므로 건너뛴다. 같은 우선순위 큐를 쓰는 프림 알고리즘과 헷갈리기 쉬운데, 프림은 누적 거리가 아니라 트리에 붙일 간선 하나의 가중치를 값으로 쓴다. 프림이었다면 B는 C-B 간선 값 2, D는 B-D 간선 값 5로 기록됐을 것이다. 또 가중치가 모두 같다고 보고 FIFO 큐를 쓰는 BFS와 달리, 다익스트라는 서로 다른 가중치를 다루기 위해 우선순위 큐가 필요하다.');
