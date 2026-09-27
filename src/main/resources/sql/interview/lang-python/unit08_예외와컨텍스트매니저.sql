-- Unit: 예외와 컨텍스트 매니저 (Unit ID: 219)
-- Chapter: Python (Chapter ID: 21)
-- Topic: PYTHON
-- Source: gravit-interview-contents-generator/output/2026-09-24/lang-python-unit08 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(1091, 'PYTHON', 219, 'HARD', true,
 '파이썬에서 @contextmanager로 DB 트랜잭션용 컨텍스트 매니저를 직접 만든다면 예외 처리를 어떻게 설계하시겠어요? 잘못 설계했을 때 생기는 문제도 함께 말씀해 주세요.',
 '@contextmanager는 제너레이터 함수를 컨텍스트 매니저로 바꿔 주는데, yield 앞이 __enter__, 뒤가 __exit__에 해당합니다. 트랜잭션이라면 begin을 호출한 뒤 try 안에서 yield conn을 하고, 그 뒤에 commit을 두어 블록이 정상 종료했을 때만 커밋되게 합니다. 중요한 점은 with 블록에서 예외가 나면 그 예외가 yield 지점에서 다시 발생한다는 것입니다. 그래서 yield를 try/finally로 감싸지 않으면 예외가 났을 때 yield 이후의 정리 코드가 실행되지 않습니다. except Exception에서는 rollback을 한 뒤 반드시 인자 없는 raise로 재전파해야 합니다. 예외를 삼키면 호출자는 실패를 모르게 됩니다. 마지막으로 finally에서 conn.close()를 호출해 어떤 경로로 빠져나가도 커넥션이 닫히게 합니다. 이를 잘못 설계해 커넥션이 해제되지 않으면 커넥션 풀이 고갈되어 서비스 전체가 멈출 수 있습니다. 또 finally는 정리 작업만 해야 하며, finally 안에서 return을 쓰면 진행 중이던 예외가 조용히 사라지므로 주의해야 합니다.'),
(1092, 'PYTHON', 219, 'NORMAL', true,
 'except 블록에서 예외를 다시 던질 때 raise, raise e, raise 새예외 from e는 각각 어떻게 다른가요?',
 '인자 없는 raise는 현재 처리 중인 예외를 원본 트레이스백을 유지한 채 그대로 재전파합니다. 로깅이나 정리 작업을 한 뒤 같은 예외를 다시 던질 때 씁니다. 반면 except ... as e: raise e처럼 쓰면 트레이스백에 현재 줄이 추가되어 원래 발생 지점이 헷갈리게 되므로, 같은 예외를 다시 던질 때는 인자 없는 raise를 쓰는 것이 맞습니다. raise New() from e는 원인 예외를 __cause__로 연결하는 명시적 연쇄로, 트레이스백에 ''The above exception was the direct cause of…''가 표시됩니다. 예를 들어 OSError 같은 저수준 예외를 AppError 같은 도메인 예외로 번역할 때 사용합니다. 참고로 except 안에서 from 없이 새 예외를 던지면 __context__로 암묵적 연쇄가 되어 ''During handling…, another exception occurred''로 표시되는데, 이는 실수로 생기는 경우가 많습니다.'),
(1093, 'PYTHON', 219, 'NORMAL', true,
 '파이썬에서 말하는 EAFP 스타일과 LBYL 스타일의 차이는 무엇이고, 각각 어떤 상황에서 유리한가요?',
 'EAFP는 Easier to Ask Forgiveness than Permission의 약자로, 일단 시도하고 실패하면 예외로 처리하는 방식입니다. 예를 들어 cache[key]를 바로 꺼내고 KeyError가 나면 compute(key)를 호출합니다. LBYL은 Look Before You Leap으로, if key in cache처럼 미리 검사한 뒤 사용합니다. LBYL은 검사와 사용 사이에 상태가 바뀔 수 있어, 멀티스레드 환경에서는 검사 후 사용 전에 키가 삭제되는 경쟁 조건 문제가 있습니다. EAFP는 바로 시도하므로 이런 문제가 없고, 파이썬은 EAFP 스타일을 선호합니다. 성능 면에서는 try가 거의 공짜이고 예외가 실제 발생할 때만 비용이 들기 때문에, 예외가 드물게 발생하면 EAFP가 빠르고 자주 발생하면 LBYL이 빠릅니다.'),
(1094, 'PYTHON', 219, 'EASY', true,
 '파이썬의 with 문은 내부적으로 어떻게 동작하나요?',
 'with 문은 try/finally를 객체에 캡슐화한 것입니다. 블록에 들어갈 때 컨텍스트 매니저의 __enter__가 호출되고, 그 반환값이 as 뒤의 변수에 바인딩됩니다. 블록을 나올 때는 예외 여부와 관계없이 __exit__가 호출됩니다. 정상 종료면 __exit__(None, None, None)이, 예외가 발생하면 __exit__(exc_type, exc, tb)처럼 예외 타입·예외 객체·트레이스백이 전달됩니다. 이때 __exit__가 True를 반환하면 예외가 억제되고, False나 None을 반환하면 예외가 그대로 전파됩니다. 그래서 with open(...) as f로 파일을 열면 블록 안에서 예외가 나도 __exit__가 호출되어 파일이 닫힙니다.'),
(1095, 'PYTHON', 219, 'EASY', true,
 '파이썬의 try/except/else/finally에서 각 블록이 언제 실행되는지 설명해 주세요.',
 '먼저 try 본문이 실행됩니다. 예외가 발생하면 except 절을 위에서 아래로 탐색해 첫 번째로 일치하는 절을 실행합니다. 그래서 하위 클래스 예외를 담은 except 절을 상위 클래스보다 먼저 적어야 합니다. 일치하는 except가 없으면 예외는 finally를 거친 뒤 상위로 전파됩니다. else 블록은 try 본문에서 예외가 없을 때만 실행됩니다. 그래서 try 본문에는 예외가 날 수 있는 최소한의 코드만 두고 나머지는 else로 옮기면 어떤 줄이 어떤 예외를 내는지 명확해집니다. finally 블록은 예외 여부나 return 여부와 무관하게 항상 실행되므로 정리 작업을 둡니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1091
(5853, 1091, 'with 블록에서 예외가 나면 yield 지점에서 예외가 다시 발생함을 설명', 'ESSENTIAL', 1),
(5854, 1091, 'yield를 try/finally로 감싸지 않으면 예외 시 yield 이후 정리 코드가 실행되지 않음을 설명', 'ESSENTIAL', 2),
(5855, 1091, 'except에서 rollback 후 예외를 삼키지 않고 raise로 재전파해야 호출자가 실패를 알 수 있음을 설명', 'ESSENTIAL', 3),
(5856, 1091, '커넥션이 해제되지 않으면 커넥션 풀이 고갈되어 서비스 전체가 멈출 수 있음을 언급', 'ESSENTIAL', 4),
(5857, 1091, 'finally 안에서 return을 쓰면 진행 중이던 예외가 조용히 사라짐을 언급', 'SUPPLEMENTARY', 5),
(5858, 1091, '블록이 정상 종료했을 때만 commit이 실행되도록 yield 뒤에 둠을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1092
(5859, 1092, '인자 없는 raise는 원본 트레이스백을 유지한 채 같은 예외를 재전파함을 설명', 'ESSENTIAL', 1),
(5860, 1092, 'raise e는 트레이스백에 현재 줄이 추가되어 원래 발생 지점이 헷갈림을 설명', 'ESSENTIAL', 2),
(5861, 1092, 'raise New() from e는 원인 예외를 __cause__로 연결하는 연쇄임을 설명', 'ESSENTIAL', 3),
(5862, 1092, 'from e 연쇄가 저수준 예외를 도메인 예외로 번역할 때 쓰임을 언급', 'SUPPLEMENTARY', 4),
(5863, 1092, 'except 안에서 from 없이 새 예외를 던지면 __context__로 암묵적 연쇄가 됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1093
(5864, 1093, 'EAFP가 일단 시도하고 실패하면 예외로 처리하는 방식임을 설명', 'ESSENTIAL', 1),
(5865, 1093, 'LBYL은 검사와 사용 사이에 상태가 바뀔 수 있는 경쟁 조건 문제가 있음을 설명', 'ESSENTIAL', 2),
(5866, 1093, '예외가 드물게 발생하면 EAFP가, 자주 발생하면 LBYL이 빠름을 설명', 'ESSENTIAL', 3),
(5867, 1093, 'try는 거의 비용이 없고 예외가 실제 발생할 때만 비용이 듦을 언급', 'SUPPLEMENTARY', 4),
(5868, 1093, '파이썬이 EAFP 스타일을 선호함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 1094
(5869, 1094, 'with 블록에 들어갈 때 __enter__가 호출됨을 설명', 'ESSENTIAL', 1),
(5870, 1094, '블록을 나올 때 예외 여부와 관계없이 __exit__가 호출됨을 설명', 'ESSENTIAL', 2),
(5871, 1094, '__exit__가 True를 반환하면 예외가 억제되고 False나 None이면 전파됨을 설명', 'ESSENTIAL', 3),
(5872, 1094, 'with 문이 try/finally를 객체에 캡슐화한 것임을 언급', 'SUPPLEMENTARY', 4),
(5873, 1094, '예외 발생 시 __exit__에 예외 타입·예외 객체·트레이스백이 전달됨을 언급', 'SUPPLEMENTARY', 5),
(5874, 1094, '__enter__의 반환값이 as 뒤 변수에 바인딩됨을 언급', 'SUPPLEMENTARY', 6),

-- 질문 1095
(5875, 1095, 'try 본문에서 예외가 발생하면 일치하는 except 절이 실행됨을 설명', 'ESSENTIAL', 1),
(5876, 1095, 'else 블록은 try 본문에서 예외가 없을 때만 실행됨을 설명', 'ESSENTIAL', 2),
(5877, 1095, 'finally 블록은 예외 여부·return 여부와 무관하게 항상 실행됨을 설명', 'ESSENTIAL', 3),
(5878, 1095, 'except 절은 위에서 아래로 첫 번째 일치를 택하므로 하위 클래스 예외를 먼저 적어야 함을 언급', 'SUPPLEMENTARY', 4),
(5879, 1095, '일치하는 except가 없으면 finally 실행 후 예외가 상위로 전파됨을 언급', 'SUPPLEMENTARY', 5),
(5880, 1095, 'try 본문은 최소화하고 나머지 코드를 else로 옮기는 것이 좋음을 언급', 'SUPPLEMENTARY', 6);
