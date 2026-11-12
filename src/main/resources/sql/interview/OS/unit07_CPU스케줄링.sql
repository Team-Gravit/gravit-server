-- Unit: CPU 스케줄링 (Unit ID: 62)
-- Chapter: 운영체제 (Chapter ID: 5)
-- Topic: OPERATING_SYSTEM
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-operating-system-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(306, 'OPERATING_SYSTEM', 62, 'HARD', true,
 'CPU 실행 시간이 짧은 프로세스를 먼저 실행하는 SJF나 SRTF를 선택하면 어떤 부작용이 생기며, 특히 SJF의 이 문제를 해결하기 위해 고안된 알고리즘은 무엇이고 그 알고리즘은 어떤 대가를 치르는지 설명해 주세요.',
 'SJF는 CPU 실행 시간이 가장 짧은 프로세스를 먼저 실행하는 비선점형 알고리즘이고, SRTF는 SJF의 선점형 버전으로 남은 실행 시간이 가장 짧은 프로세스를 먼저 실행합니다. 두 방식 모두 CPU 실행 시간이 긴 프로세스의 실행이 계속 연기될 수 있어 starvation(기아)이 발생합니다. 또한 SJF는 이론적으로 평균 대기 시간이 최소지만 CPU 실행 시간을 예측하기 어려워 실제로 사용하기도 힘듭니다. SJF에서 발생하는 기아 현상을 해결하기 위해 만들어진 알고리즘이 HRN입니다. HRN은 비선점형 알고리즘으로 대기 시간과 CPU 실행 시간을 함께 고려해 (대기 시간 + CPU 사용 시간) / CPU 사용 시간이라는 응답률로 우선순위를 계산하므로, 실행 시간이 길어도 대기 시간이 쌓이면 우선순위가 올라갑니다. 대신 매번 응답률을 계산해야 하므로 복잡해질 수 있다는 대가가 있고, 주로 비실시간 시스템에 사용됩니다.',
 'interview-question/306.mp3'),
(307, 'OPERATING_SYSTEM', 62, 'NORMAL', true,
 '선점형 스케줄링과 비선점형 스케줄링은 어떻게 다른지 CPU 반납 시점과 각각의 단점을 중심으로 설명해 주세요.',
 '선점형 스케줄링은 실행 중인 프로세스를 강제로 종료하고 다른 프로세스에 CPU를 할당하는 방식으로, 인터럽트 발생 등의 시점에 CPU를 반납하게 만듭니다. 덕분에 우선순위가 높은 프로세스를 즉시 실행할 수 있어 실시간 시스템에 적합하지만, 컨텍스트 스위칭이 자주 발생해 오버헤드가 생긴다는 단점이 있습니다. Round Robin, SRTF, 선점형 Priority가 대표적입니다. 반대로 비선점형 스케줄링은 실행 중인 프로세스가 자발적으로 CPU를 반납할 때까지 대기하며, 프로세스 종료나 yield() 호출 시점에 CPU가 반납됩니다. 컨텍스트 스위칭 오버헤드가 작다는 장점이 있지만 한 프로세스가 CPU를 독점할 수 있다는 단점이 있습니다. FCFS, SJF, 비선점형 Priority가 여기에 속합니다.',
 'interview-question/307.mp3'),
(308, 'OPERATING_SYSTEM', 62, 'NORMAL', true,
 'FCFS와 Round Robin은 CPU를 할당하는 방식이 어떻게 다르며, 각각 어떤 문제나 특성을 갖는지 설명해 주세요.',
 'FCFS는 선입 선출 방식으로 먼저 들어온 프로세스가 먼저 실행되는 비선점형 스케줄링 알고리즘입니다. 비선점형이라 컨텍스트 스위칭 오버헤드는 작지만, 실행 시간이 긴 프로세스가 먼저 실행되면 뒤의 짧은 프로세스들이 계속 대기하게 되는 Convoy Effect(호위 효과)가 발생해 대기 시간이 길어집니다. 반면 Round Robin은 각 프로세스에 동일한 Time Slice(Time Quantum)를 부여하고, Time Slice가 만료되면 해당 프로세스를 Ready Queue 맨 뒤로 보내는 선점형 스케줄링입니다. Ready Queue는 순환 큐로 관리하며, 프로세스가 n개이고 시간 할당량이 q일 때 최대 대기 시간이 (n-1) × q라서 응답 시간이 보장됩니다. 이런 특성 덕분에 대화형 시스템에 적합합니다. 다만 Time Slice 선택이 중요해서, 너무 크면 FCFS와 유사해지고 너무 작으면 컨텍스트 스위칭 오버헤드가 커집니다.',
 'interview-question/308.mp3'),
(309, 'OPERATING_SYSTEM', 62, 'EASY', true,
 'MLFQ(Multi-Level Feedback Queue) 스케줄링이 어떤 방식으로 동작하는지 설명해 주세요.',
 'MLFQ는 큐 간 이동이 허용된 MLQ로, 프로세스의 우선순위를 동적으로 조정할 수 있는 선점형 스케줄링 알고리즘입니다. 프로세스는 항상 가장 높은 우선순위 큐에서 시작하고, 그 큐에 할당된 Time Slice를 모두 사용하면 하위 큐로 이동됩니다. 이렇게 하면 CPU Burst는 낮은 우선순위의 큐에, I/O Burst는 높은 우선순위의 큐에 배치되는 효과가 생깁니다. 단계가 내려갈수록 Time Slice는 증가하고, 가장 하위 큐는 FCFS 스케줄링 알고리즘을 사용합니다. 하위 큐에 계속 머무르면 기아가 생길 수 있으므로, 가장 하위 큐에서 너무 오래 대기한 프로세스는 aging 기법을 통해 상위 큐로 이동시켜 starvation을 방지합니다.',
 'interview-question/309.mp3'),
(310, 'OPERATING_SYSTEM', 62, 'EASY', true,
 'CPU 스케줄링의 성능을 평가할 때 사용하는 지표에는 어떤 것들이 있는지 설명해 주세요.',
 'CPU 스케줄링 성능은 주로 다섯 가지 지표로 평가합니다. 대기 시간은 프로세스가 Ready Queue에서 대기한 총 시간입니다. 반환 시간은 프로세스 제출부터 완료까지의 총 시간으로, 대기 시간 + 실행 시간 + I/O 시간으로 계산합니다. 응답 시간은 요청, 즉 프로세스 제출 후 첫 응답(첫 실행)까지 걸린 시간이라서 대화형 시스템에서 특히 중요합니다. 이 밖에 CPU 사용률은 CPU가 실제로 작업한 시간 비율이고, 처리량은 단위 시간당 완료된 프로세스 수입니다. 예를 들어 같은 프로세스 집합이라도 FCFS에서는 평균 대기시간이 2.67인 반면 SRTF에서는 2.00으로 줄어드는 식으로, 알고리즘 비교에 이 지표들을 사용합니다.',
 'interview-question/310.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 306
(1592, 306, 'SJF·SRTF 중 최소 1개에서 실행 시간이 긴 프로세스의 실행이 연기되는 starvation이 발생함을 언급', 'ESSENTIAL', 1),
(1593, 306, 'SJF의 기아 현상을 해결하기 위해 만들어진 알고리즘으로 HRN을 제시', 'ESSENTIAL', 2),
(1594, 306, 'HRN이 대기 시간과 CPU 실행 시간을 함께 고려해 응답률로 우선순위를 계산함을 설명', 'ESSENTIAL', 3),
(1595, 306, 'HRN은 매번 응답률을 계산해야 해서 복잡해질 수 있다는 점을 언급', 'ESSENTIAL', 4),
(1596, 306, 'SJF는 CPU 실행 시간을 예측하기 어려워 사용하기 힘들다는 한계를 언급', 'SUPPLEMENTARY', 5),
(1597, 306, 'HRN이 주로 비실시간 시스템에 사용됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 307
(1598, 307, '선점형은 인터럽트 발생 등의 시점에 실행 중인 프로세스를 강제로 종료하고 CPU를 반납시킴을 설명', 'ESSENTIAL', 1),
(1599, 307, '비선점형은 프로세스 종료·yield() 호출처럼 자발적으로 CPU를 반납할 때까지 대기함을 설명', 'ESSENTIAL', 2),
(1600, 307, '선점형은 컨텍스트 스위칭이 자주 발생해 오버헤드가 생긴다는 단점을 언급', 'ESSENTIAL', 3),
(1601, 307, '비선점형은 한 프로세스가 CPU를 독점할 수 있다는 단점을 언급', 'ESSENTIAL', 4),
(1602, 307, '선점형 알고리즘 예로 Round Robin·SRTF·선점형 Priority 중 최소 1개를 제시', 'SUPPLEMENTARY', 5),
(1603, 307, '비선점형 알고리즘 예로 FCFS·SJF·비선점형 Priority 중 최소 1개를 제시', 'SUPPLEMENTARY', 6),
(1604, 307, '선점형이 우선순위가 높은 프로세스를 즉시 실행할 수 있어 실시간 시스템에 적합함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 308
(1605, 308, 'FCFS는 먼저 들어온 프로세스가 먼저 실행되는 선입 선출 방식임을 설명', 'ESSENTIAL', 1),
(1606, 308, 'Round Robin은 Time Slice가 만료된 프로세스를 Ready Queue 맨 뒤로 이동시킴을 설명', 'ESSENTIAL', 2),
(1607, 308, 'FCFS에서 실행 시간이 긴 프로세스가 먼저 실행되면 Convoy Effect가 발생함을 언급', 'ESSENTIAL', 3),
(1608, 308, 'Round Robin은 응답 시간이 보장됨을 언급', 'ESSENTIAL', 4),
(1609, 308, 'FCFS는 비선점형, Round Robin은 선점형임을 구분', 'SUPPLEMENTARY', 5),
(1610, 308, 'Round Robin의 Time Slice가 너무 크면 FCFS와 유사해짐을 명시', 'SUPPLEMENTARY', 6),
(1611, 308, 'Round Robin의 Time Slice가 너무 작으면 컨텍스트 스위칭 오버헤드가 커짐을 언급', 'SUPPLEMENTARY', 7),

-- 질문 309
(1612, 309, 'MLFQ가 큐 간 이동이 허용된 MLQ임을 설명', 'ESSENTIAL', 1),
(1613, 309, '프로세스가 항상 가장 높은 우선순위 큐에서 시작함을 언급', 'ESSENTIAL', 2),
(1614, 309, '각 큐에 할당된 Time Slice를 모두 사용하면 하위 큐로 이동됨을 언급', 'ESSENTIAL', 3),
(1615, 309, '가장 하위 큐에서 너무 오래 대기한 프로세스는 상위 큐로 이동됨을 언급', 'ESSENTIAL', 4),
(1616, 309, 'MLFQ는 우선순위를 동적으로 조정함을 언급', 'SUPPLEMENTARY', 5),
(1617, 309, 'CPU Burst는 낮은 우선순위 큐에, I/O Burst는 높은 우선순위 큐에 배치됨을 서술', 'SUPPLEMENTARY', 6),
(1618, 309, 'MLFQ가 aging 기법으로 starvation을 방지함을 언급', 'SUPPLEMENTARY', 7),

-- 질문 310
(1619, 310, '대기 시간이 Ready Queue에서 대기한 총 시간임을 설명', 'ESSENTIAL', 1),
(1620, 310, '반환 시간이 프로세스 제출부터 완료까지의 총 시간임을 설명', 'ESSENTIAL', 2),
(1621, 310, '응답 시간이 프로세스 제출 후 첫 실행까지의 시간임을 설명', 'ESSENTIAL', 3),
(1622, 310, '처리량이 단위 시간당 완료된 프로세스 수임을 언급', 'SUPPLEMENTARY', 4),
(1623, 310, 'CPU 사용률이 CPU가 실제로 작업한 시간 비율임을 언급', 'SUPPLEMENTARY', 5),
(1624, 310, '반환 시간이 대기 시간·실행 시간·I/O 시간의 합임을 명시', 'SUPPLEMENTARY', 6);
