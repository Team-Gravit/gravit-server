-- Unit: TCP 신뢰성 - 흐름, 혼잡, 오류 제어 (Unit ID: 237)
-- Chapter: 네트워크 (Chapter ID: 3)
-- Topic: NETWORK
-- Source: gravit-interview-contents-generator/output/2026-11-12/cs-network-unit16 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(1364, 'NETWORK', 237, 'HARD', true,
 '수신 서버는 여유가 있는데 TCP 전송 속도가 갑자기 절반 정도로 떨어졌다면 원인은 무엇일까요?',
 '수신 서버가 여유롭다면 수신 측 버퍼를 보호하는 흐름 제어보다는 네트워크를 보호하는 혼잡 제어 쪽이 원인입니다. 수신자가 여유로워도 중간 네트워크, 즉 라우터 큐가 포화되면 패킷이 유실됩니다. TCP의 실제 전송량은 수신 측이 알려 주는 rwnd와 송신 측이 스스로 관리하는 cwnd 중 작은 값, 즉 min(rwnd, cwnd)로 결정되므로 rwnd가 넉넉해도 cwnd가 작아지면 전송량이 줄어듭니다. 혼잡 제어에서는 송신 측이 손실이나 중복 ACK로 혼잡을 추정하고, AIMD의 곱 감소에 따라 손실이 감지되면 cwnd를 절반 이하로 급격히 줄입니다. 특히 같은 번호의 중복 ACK를 3회 받으면 빠른 재전송으로 해당 세그먼트를 즉시 재전송하고, 빠른 회복으로 cwnd를 1로 되돌리지 않고 절반으로 줄인 뒤 혼잡 회피, 즉 선형 증가부터 재개합니다. 그래서 속도가 절반 정도로 떨어진 것으로 볼 수 있습니다.',
 'interview-question/1364.mp3'),
(1365, 'NETWORK', 237, 'NORMAL', true,
 'TCP의 흐름 제어와 혼잡 제어는 어떻게 다른가요?',
 '흐름 제어는 수신 측 버퍼를 보호하는 기법으로, 수신자가 처리 속도보다 빨리 받아 버퍼가 넘치는 문제를 해결합니다. 반면 혼잡 제어는 라우터와 회선을 포함한 네트워크 전체를 보호하며, 네트워크가 과부하되어 패킷이 손실되는 문제를 해결합니다. 판단 주체도 다른데, 흐름 제어는 수신 측이 ACK에 수신 윈도우 rwnd를 실어 알려 주고, 혼잡 제어는 송신 측이 손실이나 중복 ACK로 혼잡을 추정해 혼잡 윈도우 cwnd를 스스로 관리합니다. 실제 전송량은 min(rwnd, cwnd)로 결정됩니다.',
 'interview-question/1365.mp3'),
(1366, 'NETWORK', 237, 'NORMAL', true,
 'Go-Back-N ARQ와 Selective Repeat ARQ의 차이는 무엇인가요?',
 '두 방식 모두 윈도우만큼 연속 전송한다는 점은 같지만 오류가 났을 때 재전송 범위가 다릅니다. Go-Back-N은 오류 지점 이후의 프레임을 전부 재전송하고, Selective Repeat은 오류가 난 프레임만 재전송합니다. 수신 버퍼도 다른데, Go-Back-N은 순서가 어긋난 프레임을 폐기하므로 수신 버퍼가 필요 없고, Selective Repeat은 순서를 재조립하기 위해 수신 버퍼가 필요합니다. 효율 면에서는 Go-Back-N이 중복 재전송 낭비가 있어 중간 수준이고, Selective Repeat은 효율이 높지만 구현이 복잡합니다.',
 'interview-question/1366.mp3'),
(1367, 'NETWORK', 237, 'EASY', true,
 'TCP의 슬라이딩 윈도우란 무엇이고 왜 필요한가요?',
 '가장 단순한 정지-대기 방식은 세그먼트 하나를 보내고 ACK가 올 때까지 기다린 뒤 다음 세그먼트를 보내는데, 왕복 시간인 RTT 동안 회선이 놀게 되어 전송 효율이 극단적으로 낮습니다. 슬라이딩 윈도우는 ACK를 기다리지 않고 윈도우 크기만큼의 세그먼트를 연속 전송하는 방식입니다. ACK가 도착하면 윈도우가 오른쪽으로 미끄러지듯 이동하며 새 데이터를 전송할 수 있게 됩니다. 또 수신 측은 ACK에 남은 버퍼 크기인 수신 윈도우 rwnd를 실어 보내는 윈도우 광고를 하고, 송신 측은 rwnd를 초과해 전송하지 않아 수신 버퍼 넘침이 방지됩니다. rwnd가 0으로 광고되면 송신 측은 전송을 멈춥니다.',
 'interview-question/1367.mp3'),
(1368, 'NETWORK', 237, 'EASY', true,
 'TCP 슬로우 스타트는 어떻게 동작하고, 왜 그렇게 시작하나요?',
 '슬로우 스타트는 혼잡 제어의 시작 단계로, 연결 시작 시 혼잡 윈도우 cwnd를 1 MSS처럼 작게 잡습니다. 그리고 ACK를 받을 때마다 RTT마다 cwnd를 2배씩 지수적으로 증가시킵니다. 이렇게 하는 것은 네트워크 수용량을 모르는 상태에서 조심스럽게 시작하되 빠르게 한계를 탐색하는 전략입니다. cwnd가 임계값 ssthresh에 도달하면 혼잡 회피 단계로 전환해 선형 증가로 바뀝니다.',
 'interview-question/1368.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 1364
(6315, 1364, '원인을 수신 측 흐름 제어가 아닌 네트워크 혼잡 제어로 구분', 'ESSENTIAL', 1),
(6316, 1364, '실제 전송량이 rwnd와 cwnd 중 작은 값으로 결정됨을 설명', 'ESSENTIAL', 2),
(6317, 1364, '손실이 감지되면 송신 측이 cwnd를 절반 이하로 줄인다고 설명', 'ESSENTIAL', 3),
(6318, 1364, '중복 ACK를 3회 받으면 해당 세그먼트를 즉시 재전송한다고 설명', 'SUPPLEMENTARY', 4),
(6319, 1364, '빠른 회복은 cwnd를 1로 되돌리지 않고 혼잡 회피부터 재개한다고 설명', 'SUPPLEMENTARY', 5),
(6320, 1364, '송신 측이 손실·중복 ACK로 혼잡을 추정한다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 1365
(6321, 1365, '흐름 제어는 수신 측 버퍼를 보호한다고 설명', 'ESSENTIAL', 1),
(6322, 1365, '혼잡 제어는 네트워크 전체를 보호한다고 설명', 'ESSENTIAL', 2),
(6323, 1365, '흐름 제어는 수신 측이, 혼잡 제어는 송신 측이 판단한다고 구분', 'ESSENTIAL', 3),
(6324, 1365, '제어 변수로 흐름 제어의 rwnd와 혼잡 제어의 cwnd를 구분', 'SUPPLEMENTARY', 4),
(6325, 1365, '실제 전송량이 min(rwnd, cwnd)로 정해진다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1366
(6326, 1366, 'Go-Back-N은 오류 지점 이후 프레임을 전부 재전송한다고 설명', 'ESSENTIAL', 1),
(6327, 1366, 'Selective Repeat은 오류 프레임만 재전송한다고 설명', 'ESSENTIAL', 2),
(6328, 1366, 'Go-Back-N은 순서가 어긋난 프레임을 폐기하고 Selective Repeat은 수신 버퍼로 순서를 재조립한다고 구분', 'ESSENTIAL', 3),
(6329, 1366, 'Go-Back-N은 중복 재전송으로 낭비가 생긴다고 언급', 'SUPPLEMENTARY', 4),
(6330, 1366, 'Selective Repeat은 구현이 복잡하다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1367
(6331, 1367, 'ACK를 기다리지 않고 윈도우 크기만큼 세그먼트를 연속 전송한다고 설명', 'ESSENTIAL', 1),
(6332, 1367, 'ACK가 도착하면 윈도우가 이동해 새 데이터를 전송할 수 있다고 설명', 'ESSENTIAL', 2),
(6333, 1367, '정지-대기 방식은 RTT 동안 회선이 놀게 된다고 설명', 'ESSENTIAL', 3),
(6334, 1367, '수신 측이 ACK에 수신 윈도우 rwnd를 실어 보낸다고 설명', 'SUPPLEMENTARY', 4),
(6335, 1367, 'rwnd가 0으로 광고되면 송신 측이 전송을 멈춘다고 언급', 'SUPPLEMENTARY', 5),

-- 질문 1368
(6336, 1368, '연결 시작 시 cwnd를 작게 잡는다고 설명', 'ESSENTIAL', 1),
(6337, 1368, 'RTT마다 cwnd를 2배씩 지수적으로 증가시킨다고 설명', 'ESSENTIAL', 2),
(6338, 1368, '네트워크 수용량을 모르는 상태에서 조심스럽게 시작하는 전략이라고 설명', 'ESSENTIAL', 3),
(6339, 1368, 'cwnd가 임계값 ssthresh에 도달하면 혼잡 회피 단계로 전환한다고 설명', 'SUPPLEMENTARY', 4),
(6340, 1368, '초기 cwnd가 1 MSS라고 언급', 'SUPPLEMENTARY', 5);
