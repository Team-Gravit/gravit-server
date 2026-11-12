-- Unit: 프로세스 기초 (Unit ID: 57)
-- Chapter: 운영체제 (Chapter ID: 5)
-- Topic: OPERATING_SYSTEM
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-operating-system-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(281, 'OPERATING_SYSTEM', 57, 'HARD', true,
 '시분할 시스템에서 CPU 할당 시간(Time Quantum)을 아주 짧게 설정하면 어떤 이점이 있고 어떤 대가를 치르게 되는지, 문맥 교환 관점에서 설명해 주세요.',
 '시분할은 CPU 시간을 작은 단위로 분할해 각 프로세스에 순환 할당하는 방식으로, 할당 시간을 짧게 할수록 각 프로세스가 CPU를 더 자주 받기 때문에 사용자에게 빠른 응답 시간을 제공한다는 이점이 있습니다. 여러 사용자가 동시에 시스템을 사용하는 것처럼 느끼게 되는 것도 이 때문입니다. 대가는 문맥 교환 횟수의 증가입니다. 문맥 교환은 CPU 할당 시간(Time Quantum)이 만료될 때 발생하는데, 이때 Running 상태의 프로세스는 Ready로 전이되고 운영체제는 현재 프로세스의 문맥을 저장한 뒤 다음 프로세스의 문맥을 복원합니다. 문맥 교환은 CPU가 실제 작업을 수행하지 않는 순수한 오버헤드이며, 구체적인 오버헤드 요인으로는 PCB 저장 및 복원 시간, 캐시 메모리 무효화(Cache Flush), TLB(Translation Lookaside Buffer) 초기화가 있습니다. 따라서 할당 시간이 짧아질수록 응답성은 좋아지지만 전체 CPU 시간 중 실제 작업에 쓰이는 비율은 낮아지므로, 응답 시간과 오버헤드 사이의 균형을 보고 할당 시간을 정해야 합니다. 참고로 시스템 콜이나 인터럽트가 발생하더라도 같은 프로세스로 복귀한다면 문맥 교환이 아니고, 멀티프로그래밍은 한 프로세스가 I/O 대기 중일 때 다른 프로세스를 실행해 CPU 유휴 시간을 최소화하고 CPU 이용률을 극대화합니다.',
 'interview-question/281.mp3'),
(282, 'OPERATING_SYSTEM', 57, 'NORMAL', true,
 '프로세스의 Waiting 상태와 Suspended 상태는 어떻게 다른지 설명해 주세요.',
 'Waiting은 프로세스가 I/O 작업 등 이벤트 발생을 기다리는 상태로, 이때는 CPU를 할당받아도 실행할 수 없습니다. 반면 Suspended는 메모리가 부족할 때 운영체제가 프로세스를 디스크로 스왑 아웃(Swap out)해 메모리 공간을 확보한 상태로, 프로세스가 메모리에 없다는 점이 핵심 차이입니다. 전이 조건도 다릅니다. Waiting 상태의 프로세스는 자신이 요청한 I/O가 완료되거나 이벤트가 발생하면 스스로 Ready로 전이되지만, Suspended 상태의 프로세스는 외부, 즉 운영체제가 다시 메모리에 적재해 주어야 실행 가능한 상태가 됩니다. Suspended는 어떤 상태에서 스왑되었는지에 따라 메모리에서 디스크로 스왑된 Ready 상태인 Suspended Ready와, 스왑된 Waiting 상태인 Suspended Waiting 두 가지로 나뉩니다.',
 'interview-question/282.mp3'),
(283, 'OPERATING_SYSTEM', 57, 'NORMAL', true,
 '장기 스케줄러와 중기 스케줄러는 각각 어떤 역할을 하며, Degree of Multiprogramming에 어떤 영향을 주는지 설명해 주세요.',
 '장기 스케줄러는 Job Scheduler라고도 하며, 디스크에 있는 프로세스를 메모리로 적재할지를 결정합니다. 호출 빈도는 분·시간 단위로 낮습니다. 중기 스케줄러는 Swapper라고도 하며, 메모리가 부족할 때 프로세스를 디스크로 스왑 아웃하는 역할을 하고 초 단위 빈도로 동작합니다. 두 스케줄러는 모두 Degree of Multiprogramming을 제어합니다. Degree of Multiprogramming은 메모리에 동시에 존재하는 프로세스의 수를 의미하는데, 장기 스케줄러가 프로세스를 메모리에 적재하기로 결정하면 이 값이 증가하고, 중기 스케줄러가 프로세스를 스왑 아웃하면 이 값이 감소합니다. 즉 장기 스케줄러는 늘리는 방향, 중기 스케줄러는 줄이는 방향으로 같은 지표를 조절합니다. 참고로 단기 스케줄러는 CPU Scheduler로서 Ready Queue에서 실행할 프로세스를 선택해 CPU를 할당하며, 밀리초 단위로 가장 자주 호출됩니다.',
 'interview-question/283.mp3'),
(284, 'OPERATING_SYSTEM', 57, 'EASY', true,
 '프로세스가 메모리 상에서 구성되는 네 가지 영역과 각 영역에 저장되는 내용을 설명해 주세요.',
 '프로세스는 메모리 상에서 코드, 데이터, 힙, 스택 네 가지 영역으로 구성됩니다. 코드(Code) 영역에는 실행할 프로그램의 기계어 코드가 저장되며 읽기 전용이라 프로그램 실행 중 변경되지 않습니다. 데이터(Data) 영역에는 전역 변수와 정적 변수가 저장되고, 프로그램 시작 시 할당되어 종료 시 해제됩니다. 힙(Heap)은 동적 할당 메모리를 위한 영역으로 프로그래머가 수동으로 할당하고 해제합니다. 스택(Stack)에는 함수 호출 정보와 지역 변수가 저장되며, 함수 호출 시 자동으로 할당되고 반환 시 해제됩니다. 이 네 영역의 내용은 프로세스 문맥 중 메모리 문맥인 주소 공간에 해당합니다.',
 'interview-question/284.mp3'),
(285, 'OPERATING_SYSTEM', 57, 'EASY', true,
 'PCB(Process Control Block)가 무엇이고 어떤 정보를 담고 있는지 설명해 주세요.',
 'PCB는 운영체제가 각 프로세스를 관리하기 위해 유지하는 자료구조로, 해당 프로세스에 대한 모든 정보를 담고 있습니다. 담기는 정보로는 프로세스 식별 정보인 PID와 부모 프로세스 ID(PPID), New/Ready/Running/Waiting/Terminated 같은 프로세스 상태, 다음에 실행할 명령어의 주소인 프로그램 카운터, 누산기·인덱스 레지스터·스택 포인터 등의 CPU 레지스터 값이 있습니다. 그 밖에 우선순위와 스케줄링 큐 포인터 같은 스케줄링 정보, Base/Limit 레지스터나 페이지 테이블 같은 메모리 관리 정보, CPU 사용 시간 등의 계정 정보, 할당된 I/O 장치와 열린 파일 목록 같은 입출력 상태 정보도 포함됩니다. PCB는 커널의 주소 공간에 저장되며 프로세스 문맥 중 커널 문맥에 해당하는 프로세스 제어 정보로, 문맥 교환이 일어날 때 운영체제는 이 PCB를 저장하고 복원합니다.',
 'interview-question/285.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 281
(1446, 281, '시분할이 사용자에게 빠른 응답 시간을 제공하는 이점임을 언급', 'ESSENTIAL', 1),
(1447, 281, 'CPU 할당 시간(Time Quantum) 만료가 문맥 교환을 유발함을 언급', 'ESSENTIAL', 2),
(1448, 281, '문맥 교환이 CPU가 실제 작업을 수행하지 않는 순수한 오버헤드임을 명시', 'ESSENTIAL', 3),
(1449, 281, 'PCB 저장·복원, 캐시 무효화, TLB 초기화 중 최소 1개를 오버헤드 요인으로 제시', 'ESSENTIAL', 4),
(1450, 281, '같은 프로세스로 복귀하는 인터럽트·시스템 콜은 문맥 교환이 아님을 서술', 'SUPPLEMENTARY', 5),
(1451, 281, '멀티프로그래밍이 CPU 유휴 시간을 최소화해 CPU 이용률을 높임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 282
(1452, 282, 'Waiting이 I/O 작업 등 이벤트 발생을 기다리는 상태임을 언급', 'ESSENTIAL', 1),
(1453, 282, 'Suspended가 메모리에서 디스크로 스왑 아웃된 상태임을 언급', 'ESSENTIAL', 2),
(1454, 282, 'Waiting은 이벤트 완료 시 Ready로 전이되지만 Suspended는 외부에서 다시 메모리에 적재해야 함을 비교', 'ESSENTIAL', 3),
(1455, 282, '메모리가 부족할 때 운영체제가 스왑 아웃으로 메모리 공간을 확보함을 서술', 'SUPPLEMENTARY', 4),
(1456, 282, 'Suspended Ready와 Suspended Waiting 두 가지가 있음을 제시', 'SUPPLEMENTARY', 5),

-- 질문 283
(1457, 283, '장기 스케줄러가 디스크의 프로세스를 메모리로 적재할지 결정함을 언급', 'ESSENTIAL', 1),
(1458, 283, '중기 스케줄러가 메모리 부족 시 프로세스를 디스크로 스왑 아웃함을 언급', 'ESSENTIAL', 2),
(1459, 283, 'Degree of Multiprogramming이 메모리에 동시에 존재하는 프로세스의 수임을 명시', 'ESSENTIAL', 3),
(1460, 283, '장기 스케줄러는 Degree of Multiprogramming을 증가시키고 중기 스케줄러는 감소시킴을 비교', 'ESSENTIAL', 4),
(1461, 283, '단기 스케줄러가 Ready Queue에서 실행할 프로세스를 선택함을 서술', 'SUPPLEMENTARY', 5),
(1462, 283, '장기 스케줄러는 분·시간 단위, 단기 스케줄러는 밀리초 단위로 호출 빈도가 다름을 제시', 'SUPPLEMENTARY', 6),

-- 질문 284
(1463, 284, '코드 영역이 실행할 프로그램의 기계어 코드를 담는 영역임을 언급', 'ESSENTIAL', 1),
(1464, 284, '데이터 영역의 저장 대상으로 전역 변수·정적 변수 중 최소 1개를 제시', 'ESSENTIAL', 2),
(1465, 284, '힙이 동적 할당 메모리를 위한 영역임을 언급', 'ESSENTIAL', 3),
(1466, 284, '스택의 저장 대상으로 함수 호출 정보·지역 변수 중 최소 1개를 제시', 'ESSENTIAL', 4),
(1467, 284, '코드 영역이 읽기 전용이라 실행 중 변경되지 않음을 명시', 'SUPPLEMENTARY', 5),
(1468, 284, '힙은 프로그래머가 수동으로 할당·해제함을 명시', 'SUPPLEMENTARY', 6),
(1469, 284, '스택은 함수 호출 시 자동 할당되고 반환 시 해제됨을 명시', 'SUPPLEMENTARY', 7),

-- 질문 285
(1470, 285, 'PCB가 운영체제가 각 프로세스를 관리하기 위해 유지하는 자료구조임을 언급', 'ESSENTIAL', 1),
(1471, 285, 'PID·프로세스 상태·프로그램 카운터·CPU 레지스터 중 최소 2개를 PCB 구성 정보로 제시', 'ESSENTIAL', 2),
(1472, 285, 'PCB가 커널의 주소 공간에 저장됨을 명시', 'SUPPLEMENTARY', 3),
(1473, 285, '우선순위나 스케줄링 큐 포인터 같은 스케줄링 정보가 PCB에 포함됨을 서술', 'SUPPLEMENTARY', 4),
(1474, 285, 'PCB가 프로세스 문맥 중 커널 문맥에 속하는 제어 정보임을 언급', 'SUPPLEMENTARY', 5);
