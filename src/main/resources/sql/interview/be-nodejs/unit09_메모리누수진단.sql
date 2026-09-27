-- Unit: 메모리 누수 진단 (Unit ID: 131)
-- Chapter: Node.js (Chapter ID: 11)
-- Topic: NODE_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/be-nodejs-unit09 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(651, 'NODE_JS', 131, 'HARD', true,
 '운영 중인 Node.js 서버의 메모리가 재시작 전까지 계속 증가하다가 OOM으로 죽는다면, 원인을 찾기까지 어떤 순서로 진단하시겠습니까? 운영 환경에서 힙 스냅샷을 찍을 때 주의할 점도 함께 설명해 주세요.',
 '먼저 process.memoryUsage()와 메트릭으로 heapUsed 추이를 관찰해, GC 이후에도 heapUsed가 계단식으로 계속 오르는지 확인하는 것이 누수 여부 판단의 첫 단계입니다. 필요하면 --trace-gc로 GC 전후 힙 크기를 로그로 남겨, Mark-Sweep 후에도 힙이 줄지 않으면 누수를 의심합니다. 누수가 의심되면 힙 스냅샷으로 원인을 찾습니다. 부하 전 스냅샷 1, N회 요청 후 GC를 돌리고 스냅샷 2, 다시 N회 요청 후 GC를 돌리고 스냅샷 3을 찍는 3-스냅샷 기법을 씁니다. 1과 2의 차이에는 JIT나 캐시 워밍 같은 초기화 객체가 섞여 있으므로 2 → 3의 증가분을 보는 것이 정확합니다. Comparison 뷰에서 Delta가 요청 수에 비례해 큰 생성자를 고르고, 인스턴스 하나를 클릭해 Retainers 패널을 루트 방향으로 따라가면 Map → module → global 같은 경로가 보이므로 이를 통해 코드 위치를 특정합니다. 운영 환경에서 v8.writeHeapSnapshot()이나 --heapsnapshot-signal로 스냅샷을 찍으면 촬영 순간 이벤트 루프가 멈추고 힙 크기의 수 배에 달하는 메모리와 시간이 필요하므로, 트래픽을 뺀 인스턴스에서 촬영해야 합니다.'),
(652, 'NODE_JS', 131, 'NORMAL', true,
 '힙 스냅샷에서 Shallow Size와 Retained Size는 어떻게 다르며, 누수의 크기를 판단할 때는 어느 쪽을 기준으로 봐야 하나요?',
 'Shallow Size는 객체 자체의 크기이고, Retained Size는 그 객체가 사라지면 함께 회수될 총량입니다. 작은 객체가 많이 매달려 있는 경우 Shallow Size에서는 잘 보이지 않기 때문에, 누수의 진짜 크기는 Shallow Size가 아니라 Retained Size를 기준으로 판단하고 Shallow Size는 참고만 합니다. 실제로 스냅샷을 볼 때도 Retained Size를 정렬 기준으로 사용하는데, 이렇게 정렬하면 최상단에는 보통 (GC roots)나 system 같은 내부 항목이 오므로 이들은 무시하고, 애플리케이션 클래스명이나 (closure)가 처음 나타나는 행부터 보면 시간이 절약됩니다.'),
(653, 'NODE_JS', 131, 'NORMAL', true,
 'process.memoryUsage()의 heapUsed와 rss는 각각 무엇을 나타내며, 둘 중 어느 지표가 늘어나느냐에 따라 누수를 어떻게 다르게 해석하나요?',
 'heapUsed는 V8 힙 중 실제 사용 중인 크기이며, 누수 판단의 1차 지표입니다. rss는 힙뿐 아니라 Buffer·네이티브 객체와 코드 같은 힙 밖 영역까지 포함한 프로세스 전체 상주 메모리입니다. heapUsed가 계속 증가하면 V8 힙 안에 GC가 회수하지 못하는 객체가 쌓이는 것이므로 힙 스냅샷으로 진단합니다. 반면 heapUsed는 평평한데 rss만 늘어난다면 Buffer, 네이티브 애드온, 스레드 풀 같은 힙 밖 누수이거나 단순 메모리 단편화입니다. 참고로 external은 Buffer 등 V8 밖 C++ 객체의 메모리를 나타냅니다. 이렇게 어느 지표가 늘어나는지에 따라 사용할 진단 도구가 달라집니다.'),
(654, 'NODE_JS', 131, 'EASY', true,
 '가비지 컬렉터가 있는 JavaScript에서 메모리 누수란 무엇인지, GC가 어떤 객체를 회수하는지와 연결해 설명해 주세요.',
 'GC는 쓰이지 않는 객체가 아니라 GC 루트에서 도달할 수 없는 객체를 회수합니다. 루트는 전역 객체, 현재 실행 중인 스택, 활성 타이머나 핸들의 콜백 등입니다. 따라서 메모리 누수는 더 이상 필요 없어진 객체로 향하는 참조 경로가 남아 있어 GC가 회수하지 못하는 상태입니다. 예를 들어 요청은 끝났지만 모듈 스코프의 캐시 Map이 요청 컨텍스트 객체를 잡고 있으면 그 객체와 응답 버퍼는 회수되지 않습니다. 그래서 누수 진단은 그 참조 경로, 즉 Retainer Path를 찾는 일입니다.'),
(655, 'NODE_JS', 131, 'EASY', true,
 'Node.js 애플리케이션에서 흔히 발생하는 메모리 누수 패턴에는 어떤 것들이 있나요?',
 '대표적으로 세 가지 패턴이 있습니다. 첫째, 전역이나 모듈 스코프의 Map·배열 같은 컬렉션에 요청마다 데이터를 넣고 지우지 않는 경우입니다. 모듈 스코프 변수는 프로세스가 살아 있는 한 GC 루트에서 도달 가능하므로 요청 수에 비례해 메모리가 증가합니다. 이를 막으려면 상한과 만료가 있는 LRU·TTL 캐시를 쓰거나 삭제 경로를 둬야 합니다. 둘째, 클로저가 큰 참조를 잡는 경우입니다. 클로저는 정의된 스코프의 변수를 참조로 유지하므로, 큰 버퍼를 읽은 스코프에서 setInterval 콜백을 만들면 타이머가 해제될 때까지 그 데이터도 회수되지 않습니다. 셋째, 이벤트 리스너 누적입니다. 요청마다 싱글톤 emitter에 리스너를 추가하고 제거하지 않으면, 리스너 함수가 클로저로 req와 res를 참조하므로 요청 하나가 통째로 남습니다. 연결 종료 시 off로 제거하거나 AbortSignal로 해제해야 합니다. 같은 emitter에 리스너가 11개를 넘으면 MaxListenersExceededWarning이 출력되는데, 이는 누수의 가장 이른 신호이므로 끄지 말고 원인을 찾아야 합니다. 세 패턴의 공통 구조는 짧게 살아야 할 요청 객체가 싱글톤, 전역, 타이머, emitter 같은 오래 사는 객체에 매달리는 것입니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 651
(3513, 651, 'heapUsed 추이가 GC 이후에도 계속 오르는지 관찰하는 것을 첫 단계로 제시', 'ESSENTIAL', 1),
(3514, 651, '부하 전후 스냅샷 3장을 찍고 2 → 3의 증가분을 보는 3-스냅샷 기법을 설명', 'ESSENTIAL', 2),
(3515, 651, 'Delta가 큰 생성자의 인스턴스에서 Retainers를 루트 방향으로 추적해 코드 위치를 특정한다고 설명', 'ESSENTIAL', 3),
(3516, 651, '운영 환경 힙 스냅샷 촬영 순간 이벤트 루프가 멈춘다는 점을 주의점으로 언급', 'ESSENTIAL', 4),
(3517, 651, '--trace-gc로 Mark-Sweep 후에도 힙이 줄지 않으면 누수를 의심한다고 언급', 'SUPPLEMENTARY', 5),
(3518, 651, '스냅샷 촬영에 힙 크기의 수 배 메모리와 시간이 필요함을 언급', 'SUPPLEMENTARY', 6),
(3519, 651, '운영 스냅샷은 트래픽을 뺀 인스턴스에서 촬영해야 함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 652
(3520, 652, 'Shallow Size는 객체 자체의 크기임을 설명', 'ESSENTIAL', 1),
(3521, 652, 'Retained Size는 그 객체가 사라지면 함께 회수될 총량임을 설명', 'ESSENTIAL', 2),
(3522, 652, '누수 크기 판단 기준으로 Shallow Size가 아닌 Retained Size를 선택함을 명시', 'ESSENTIAL', 3),
(3523, 652, '작은 객체가 많으면 Shallow Size에서는 누수가 드러나지 않음을 언급', 'SUPPLEMENTARY', 4),
(3524, 652, 'Retained Size 정렬 시 최상단의 (GC roots)·system 같은 내부 항목은 무시한다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 653
(3525, 653, 'heapUsed가 V8 힙 중 실제 사용 중인 크기임을 설명', 'ESSENTIAL', 1),
(3526, 653, 'rss가 힙 밖 영역까지 포함한 프로세스 전체 상주 메모리임을 설명', 'ESSENTIAL', 2),
(3527, 653, 'heapUsed는 평평한데 rss만 늘면 힙 밖 누수나 메모리 단편화로 본다고 설명', 'ESSENTIAL', 3),
(3528, 653, 'Buffer·네이티브 애드온·스레드 풀 중 최소 1개를 힙 밖 누수 원인으로 제시', 'SUPPLEMENTARY', 4),
(3529, 653, 'external이 Buffer 등 V8 밖 C++ 객체의 메모리임을 언급', 'SUPPLEMENTARY', 5),
(3530, 653, 'heapUsed를 누수 판단의 1차 지표로 본다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 654
(3531, 654, 'GC는 GC 루트에서 도달할 수 없는 객체를 회수한다고 설명', 'ESSENTIAL', 1),
(3532, 654, '누수는 필요 없어진 객체로 향하는 참조 경로가 남아 있는 것이라고 설명', 'ESSENTIAL', 2),
(3533, 654, '전역 객체·실행 중인 스택·활성 타이머의 콜백 중 최소 1개를 GC 루트로 제시', 'SUPPLEMENTARY', 3),
(3534, 654, '누수 진단은 루트까지의 참조 경로(Retainer Path)를 찾는 일임을 언급', 'SUPPLEMENTARY', 4),

-- 질문 655
(3535, 655, '전역·모듈 스코프 컬렉션에 상한·삭제 없이 계속 쌓이는 패턴을 제시', 'ESSENTIAL', 1),
(3536, 655, '오래 사는 타이머 콜백 클로저가 큰 데이터를 담은 스코프를 유지하는 패턴을 제시', 'ESSENTIAL', 2),
(3537, 655, '요청마다 추가하고 제거하지 않는 이벤트 리스너 누적을 누수 패턴으로 제시', 'ESSENTIAL', 3),
(3538, 655, '세 패턴의 공통 구조가 짧게 살 객체가 오래 사는 객체에 매달리는 것임을 언급', 'SUPPLEMENTARY', 4),
(3539, 655, 'MaxListenersExceededWarning을 끄지 말고 누수의 이른 신호로 원인을 찾아야 함을 언급', 'SUPPLEMENTARY', 5),
(3540, 655, 'LRU·TTL 캐시 또는 리스너·타이머 해제 경로 중 최소 1개를 예방책으로 제시', 'SUPPLEMENTARY', 6);
