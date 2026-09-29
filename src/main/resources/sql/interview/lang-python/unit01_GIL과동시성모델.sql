-- Unit: GIL과 동시성 모델 (Unit ID: 212)
-- Chapter: Python (Chapter ID: 21)
-- Topic: PYTHON
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-python-unit01 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1056, 'PYTHON', 212, 'HARD', true,
 '대규모 동시 연결을 처리하려고 asyncio로 서비스를 작성했는데, 일부 코드가 requests 같은 동기 라이브러리를 호출하고 요청 처리 중 무거운 CPU 연산도 수행합니다. 어떤 문제가 생기며 어떻게 설계를 바꾸시겠고, 그 대가는 무엇인가요?',
 'asyncio는 이벤트 루프 하나가 코루틴을 번갈아 실행하고 await 지점에서만 제어권을 넘기는 단일 스레드 협력적 동시성 모델입니다. 그래서 코루틴 안에서 requests.get이나 time.sleep 같은 동기 블로킹 함수를 호출하면 제어권을 넘기지 못해 이벤트 루프 전체가 멈추고, 다른 수천 개의 연결 처리도 함께 지연됩니다. 가능하면 aiohttp 같은 비동기 지원 라이브러리로 교체하고, 불가피한 블로킹 호출은 await asyncio.to_thread(func)로 스레드에 위임합니다. 무거운 CPU 연산은 단일 스레드인 asyncio나 GIL에 묶이는 threading으로는 병렬 효과가 없으므로, 프로세스마다 독립된 인터프리터와 GIL을 가지는 multiprocessing(예: ProcessPoolExecutor)으로 분리해 GIL을 우회하고 CPU 코어를 모두 활용합니다. 대가로 인자와 반환값이 pickle로 직렬화되어 프로세스 간에 복사되므로 큰 데이터를 자주 주고받으면 오히려 느려질 수 있고, 프로세스 생성·메모리 비용도 스레드보다 훨씬 큽니다. 또한 NumPy처럼 무거운 연산 중 GIL을 직접 해제하는 C 라이브러리라면 스레드로도 병렬 효과를 얻을 수 있으므로 라이브러리 특성까지 고려해 선택합니다.',
 'interview-question/1056.mp3'),
(1057, 'PYTHON', 212, 'NORMAL', true,
 '파이썬에서 멀티스레드를 사용할 때 CPU 바운드 작업과 I/O 바운드 작업의 성능 효과가 어떻게 다른지, GIL과 연결해 설명해 주세요.',
 'CPython의 GIL은 한 번에 하나의 스레드만 바이트코드를 실행하게 하므로, CPU 코어가 여러 개여도 바이트코드를 실행하는 스레드는 항상 1개입니다. CPU 바운드 작업에서는 스레드들이 GIL을 두고 경쟁해 사실상 직렬 실행되므로 멀티스레드 효과가 없고, 스레드 전환 비용까지 추가되어 단일 스레드보다 오히려 느려지는 경우가 흔합니다. 반면 I/O 바운드 작업에서는 스레드가 파일 읽기·소켓 대기 같은 블로킹 I/O 호출 직전에 GIL을 스스로 반납하므로, 한 스레드가 I/O를 기다리는 동안 다른 스레드가 실행될 수 있어 멀티스레드 효과가 있습니다. 참고로 CPython 3.2 이후 스레드는 기본 5ms(sys.setswitchinterval) 간격마다 GIL 반납을 요청받습니다.',
 'interview-question/1057.mp3'),
(1058, 'PYTHON', 212, 'NORMAL', true,
 'I/O 바운드 작업을 동시에 처리할 때 threading과 asyncio는 어떤 차이가 있으며, 각각 언제 선택하시나요?',
 'threading은 인터프리터가 전환 시점을 결정하는 선점형 방식이고, asyncio는 이벤트 루프 하나가 코루틴을 번갈아 실행하며 await 지점에서만 제어권을 넘기는 협력형 방식입니다. threading은 메모리를 공유하므로 락이 필요하지만, asyncio는 스레드가 하나라서 GIL 경합이나 락이 거의 필요 없고 수천 개의 동시 연결을 적은 메모리로 처리할 수 있습니다. 대신 asyncio는 비동기 지원 라이브러리가 필요하고, threading은 기존 동기 코드를 그대로 쓸 수 있습니다. 따라서 동시 연결이 많고 비동기 라이브러리가 있으면 asyncio를, 동기 라이브러리만 있거나 규모가 작으면 threading을 선택합니다.',
 'interview-question/1058.mp3'),
(1059, 'PYTHON', 212, 'EASY', true,
 'GIL이 무엇이고, CPython에 GIL이 존재하는 이유는 무엇인지 설명해 주세요.',
 'GIL(Global Interpreter Lock)은 CPython에서 한 번에 하나의 스레드만 파이썬 바이트코드를 실행하도록 강제하는 뮤텍스입니다. CPython은 객체마다 레퍼런스 카운트를 저장해 메모리를 관리하는데, 여러 스레드가 동시에 같은 객체의 카운트를 증감하면 경쟁 조건이 생겨 객체가 너무 일찍 해제되거나 영원히 남을 수 있습니다. 이를 막기 위해 객체마다 락을 두면 락 획득·해제 비용이 커지고 데드락 위험이 생기므로, 인터프리터 전체에 락 하나를 두는 방식을 택했습니다. 그 결과 단일 스레드 성능과 C 확장 모듈 작성의 단순성을 얻는 대신 멀티코어 병렬성을 포기했습니다. 또한 GIL은 파이썬 언어 명세가 아니라 CPython 구현체의 선택이라서 Jython·IronPython에는 GIL이 없습니다.',
 'interview-question/1059.mp3'),
(1060, 'PYTHON', 212, 'EASY', true,
 'GIL이 있는데도 여러 스레드에서 count += 1 같은 코드를 실행할 때 락이 필요한 이유는 무엇인가요?',
 'GIL은 바이트코드 한 줄 단위로 원자성을 보장할 뿐, 파이썬 코드 한 줄을 원자적으로 만들지는 않습니다. count += 1은 LOAD → ADD → STORE처럼 여러 바이트코드로 나뉘므로, 읽기-수정-쓰기 사이에 스레드가 전환되면 다른 스레드의 갱신이 덮어써져 값이 유실될 수 있습니다. 반면 list.append나 dict[key] = value 같은 단일 C 함수 호출은 GIL 덕분에 원자적으로 동작합니다. 따라서 읽고 판단해서 쓰는 복합 연산은 threading.Lock, RLock, queue.Queue 등으로 임계 구역을 명시적으로 보호해야 합니다.',
 'interview-question/1060.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1056
(5673, 1056, '코루틴 안의 동기 블로킹 호출이 이벤트 루프 전체를 멈춘다는 점을 설명', 'ESSENTIAL', 1),
(5674, 1056, '비동기 지원 라이브러리로 교체·asyncio.to_thread 위임 중 최소 1개를 블로킹 호출 대응책으로 제시', 'ESSENTIAL', 2),
(5675, 1056, 'CPU 바운드 연산은 multiprocessing으로 분리해 GIL을 우회하는 방법을 제시', 'ESSENTIAL', 3),
(5676, 1056, 'pickle 직렬화 비용·프로세스 생성/메모리 비용 중 최소 1개를 multiprocessing의 대가로 제시', 'ESSENTIAL', 4),
(5677, 1056, 'NumPy 등 GIL을 직접 해제하는 C 라이브러리 연산은 스레드로도 병렬 효과를 얻음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1057
(5678, 1057, 'CPU 바운드 작업은 스레드들이 GIL을 두고 경쟁해 사실상 직렬 실행됨을 설명', 'ESSENTIAL', 1),
(5679, 1057, 'I/O 바운드 작업은 I/O 대기 중 GIL을 반납해 다른 스레드가 실행될 수 있음을 설명', 'ESSENTIAL', 2),
(5680, 1057, 'CPU 바운드 작업을 스레드로 나누면 전환 비용이 더해져 단일 스레드보다 느려질 수 있음을 언급', 'SUPPLEMENTARY', 3),
(5681, 1057, '스레드가 기본 5ms 간격(sys.setswitchinterval)마다 GIL 반납을 요청받음을 언급', 'SUPPLEMENTARY', 4),
(5682, 1057, 'CPU 코어가 여러 개여도 바이트코드를 실행하는 스레드는 항상 1개임을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1058
(5683, 1058, 'threading의 선점형 전환과 asyncio의 await 지점 협력형 전환의 차이를 설명', 'ESSENTIAL', 1),
(5684, 1058, '동시 연결이 많고 비동기 라이브러리가 있으면 asyncio를 선택한다는 기준을 제시', 'ESSENTIAL', 2),
(5685, 1058, '동기 라이브러리만 있거나 규모가 작으면 threading을 선택한다는 기준을 제시', 'ESSENTIAL', 3),
(5686, 1058, 'threading은 락이 필요하고 asyncio는 락이 거의 불필요하다는 차이를 설명', 'SUPPLEMENTARY', 4),
(5687, 1058, 'asyncio는 비동기 지원 라이브러리가 필요하다는 제약을 언급', 'SUPPLEMENTARY', 5),
(5688, 1058, 'asyncio가 수천 개의 동시 연결을 적은 메모리로 처리할 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1059
(5689, 1059, 'GIL이 한 번에 하나의 스레드만 바이트코드를 실행하게 하는 락임을 설명', 'ESSENTIAL', 1),
(5690, 1059, 'GIL의 목적이 레퍼런스 카운트 증감의 경쟁 조건 방지임을 언급', 'ESSENTIAL', 2),
(5691, 1059, '객체마다 락을 두는 대신 인터프리터 전체에 락 하나를 둔 설계임을 언급', 'SUPPLEMENTARY', 3),
(5692, 1059, 'GIL이 언어 명세가 아니라 CPython 구현체의 선택임을 언급', 'SUPPLEMENTARY', 4),
(5693, 1059, '단일 스레드 성능과 구현 단순성을 얻는 대신 멀티코어 병렬성을 포기했다는 점을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1060
(5694, 1060, 'GIL은 바이트코드 한 줄 단위로만 원자성을 보장함을 언급', 'ESSENTIAL', 1),
(5695, 1060, 'count += 1이 LOAD·ADD·STORE 여러 바이트코드로 나뉘어 중간에 스레드 전환이 가능함을 설명', 'ESSENTIAL', 2),
(5696, 1060, '읽고 판단해서 쓰는 복합 연산은 Lock·RLock·queue.Queue 등으로 보호해야 함을 언급', 'ESSENTIAL', 3),
(5697, 1060, 'list.append 같은 단일 C 함수 호출은 GIL 덕분에 원자적으로 동작함을 언급', 'SUPPLEMENTARY', 4);
