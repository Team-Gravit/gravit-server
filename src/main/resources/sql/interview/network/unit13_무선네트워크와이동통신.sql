-- Unit: 무선 네트워크와 이동 통신 (Unit ID: 40)
-- Chapter: 네트워크 (Chapter ID: 3)
-- Topic: NETWORK
-- Source: gravit-interview-contents-generator/output/2026-09-23/cs-network-unit13 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(196, 'NETWORK', 40, 'HARD', true,
 '유선 이더넷은 CSMA/CD로 충돌을 처리하는데, 무선 LAN에서는 왜 CSMA/CD 대신 CSMA/CA를 사용하는지, 그리고 무선 환경에서만 발생하는 숨은 단말 문제를 IEEE 802.11이 어떤 방식으로 보완하는지 설명해 주세요.',
 '유선 이더넷이 쓰는 CSMA/CD는 충돌이 발생하면 그것을 실시간으로 감지해 전송을 중단하고 재전송하는 방식입니다. 그런데 무선 환경에서는 전파가 거리나 장애물에 의해 쉽게 약해지고 주변 기기·다른 채널의 간섭과 잡음의 영향도 받기 때문에, 송신 중에 충돌을 감지하는 것 자체가 어렵습니다. 그래서 무선 LAN인 IEEE 802.11은 충돌을 감지해 수습하는 대신 사전에 충돌을 회피하는 CSMA/CA를 사용합니다. 송신 노드는 먼저 채널이 조용한지 감지하고 DIFS 시간만큼 대기한 뒤 전송을 시작합니다.

또 무선에는 숨은 단말(Hidden Terminal, Hidden Node) 문제가 있습니다. A와 C가 서로의 탐지 범위 밖에 있으면서 가운데 B와는 각각 통신이 가능한 경우, A와 C는 서로의 존재를 모르기 때문에 채널이 비어 있다고 판단하고 동시에 전송해 충돌이 발생할 수 있습니다.

802.11은 이를 RTS/CTS 방식으로 보완합니다. 송신 노드가 RTS 프레임으로 채널 사용 기간을 알리면 수신 노드가 CTS 프레임으로 응답하고, 이때 주변의 다른 노드들은 NAV를 설정합니다. 이후 SIFS 후에 데이터 프레임을 전송하고, 수신 노드가 ACK를 보내 전송 성공 여부를 확인해 줍니다. NAV가 끝나면 각 노드는 랜덤 대기 시간을 둔 경쟁 윈도우를 거쳐 다시 채널을 두고 경쟁합니다.',
 'interview-question/196.mp3'),
(197, 'NETWORK', 40, 'NORMAL', true,
 '무선 네트워크의 구성 방식인 인프라스트럭처 방식과 애드혹 방식은 어떤 차이가 있는지 설명해 주세요.',
 '인프라스트럭처 방식은 무선 단말들이 기지국이나 액세스 포인트(AP)를 통해 네트워크에 접속하는 방식입니다. 단말끼리 직접 주고받는 것이 아니라 모든 데이터 통신이 AP나 기지국을 경유하며, 중앙 장치가 연결을 관리하기 때문에 안정적이고 유선 네트워크와의 연동도 용이합니다. Wi-Fi 공유기, LTE, 5G가 여기에 해당합니다.

반면 애드혹 방식은 기지국 없이 무선 단말들이 서로 직접(Peer-to-Peer) 연결되어 통신하는 방식입니다. 네트워크가 필요할 때마다 임시로 형성되며, 별도의 인프라가 없어도 빠르게 네트워크를 구성할 수 있다는 장점이 있습니다. Bluetooth나 Wi-Fi Direct가 대표적인 예시입니다.

정리하면 중계 역할을 하는 중앙 장치(AP·기지국)의 존재 여부가 두 방식을 가르는 핵심이고, 그에 따라 인프라스트럭처 방식은 안정성과 유선 연동에, 애드혹 방식은 즉석에서의 빠른 구성에 강점이 있습니다.',
 'interview-question/197.mp3'),
(198, 'NETWORK', 40, 'NORMAL', true,
 '이동 통신에서 핸드오프가 필요한 이유는 무엇이며, Hard Handoff와 Soft Handoff는 어떤 차이가 있는지 설명해 주세요.',
 '이동 통신은 지역을 여러 셀로 나누고 각 셀마다 기지국을 두는 구조이기 때문에, 사용자가 이동하면 담당 셀이 바뀝니다. 이때 통화나 데이터 연결이 끊기지 않도록 연결을 인접 셀로 전환해 주는 것이 핸드오프(Handover)이고, 그래서 핸드오프는 이동 중에도 통신을 유지하기 위해 반드시 필요합니다.

Hard Handoff는 기존 셀과의 연결을 먼저 끊은 뒤 새로운 셀에 연결하는 방식으로, Break-Before-Make라고 부릅니다. 반대로 Soft Handoff는 새 셀과 먼저 연결을 맺고 나서 기존 연결을 끊는 Make-Before-Break 방식으로, 전환 과정에서 두 셀과 동시에 연결된 상태가 유지되며 CDMA 계열에서 사용됩니다.

핸드오프는 단말의 위치를 지속적으로 추적하는 이동성 관리의 한 축이며, 위치 등록으로 얻은 정보와 함께 여러 기지국을 관리하는 기지국 제어기(BSC/RNC/MME)가 담당합니다.',
 'interview-question/198.mp3'),
(199, 'NETWORK', 40, 'EASY', true,
 '무선 네트워크가 유선 네트워크와 구별되는 특징에는 어떤 것들이 있는지 설명해 주세요.',
 '무선 네트워크는 유선 케이블 없이 전파나 적외선 같은 전자기파로 데이터를 송수신하는 네트워크라서, 유선과 구별되는 특징이 몇 가지 있습니다.

첫째, 신호 세기가 감소합니다. 전파는 거리나 벽·유리 같은 장애물에 의해 쉽게 약해지고, 거리 제곱에 비례해 세기가 줄어듭니다. 실내에서는 반사와 흡수로 인한 손실도 큽니다.

둘째, 외부 노이즈의 영향을 받습니다. 주변 기기나 다른 채널의 간섭(Interference), 잡음(Noise)에 영향을 받기 때문에 유선보다 안정성이 낮고 전송 품질이 변동되기 쉽습니다.

셋째, 이동성(Mobility)이 있습니다. 사용자가 이동하면서도 네트워크 연결을 계속 유지할 수 있다는 점이 유선 대비 가장 큰 장점입니다.',
 'interview-question/199.mp3'),
(200, 'NETWORK', 40, 'EASY', true,
 '무선 네트워크는 통신 범위에 따라 어떤 종류로 나뉘는지 설명해 주세요.',
 '무선 네트워크는 통신 범위를 기준으로 WPAN, WLAN, WMAN, WWAN으로 나눌 수 있습니다.

WPAN(Wireless Personal Area Network)은 수 m 정도의 아주 짧은 범위에서 개인 기기 간을 연결하는 네트워크로 Bluetooth, ZigBee가 여기에 속합니다.

WLAN(Wireless Local Area Network)은 수십~수백 m 범위로, 가정이나 사무실에서 AP를 기반으로 쓰는 Wi-Fi(IEEE 802.11)가 대표적입니다.

WMAN(Wireless Metropolitan Area Network)은 수 km 범위의 도시권 네트워크로 WiMAX가 있습니다.

WWAN(Wireless Wide Area Network)은 수십~수백 km 범위를 담당하는 셀룰러 기반 이동통신으로 LTE, 5G가 해당합니다.

즉 WPAN에서 WWAN으로 갈수록 커버하는 통신 범위가 넓어지는 구조입니다.',
 'interview-question/200.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 196
(1015, 196, '무선 환경에서는 송신 중 충돌 감지가 어렵다는 점을 CSMA/CD를 쓸 수 없는 이유로 제시', 'ESSENTIAL', 1),
(1016, 196, 'CSMA/CA가 충돌을 사전에 회피하는 방식임을 언급', 'ESSENTIAL', 2),
(1017, 196, '서로의 탐지 범위 밖 단말 때문에 충돌이 생기는 Hidden Node 문제를 설명', 'ESSENTIAL', 3),
(1018, 196, 'RTS/CTS 프레임 교환으로 숨은 단말 문제를 완화한다는 점을 언급', 'ESSENTIAL', 4),
(1019, 196, 'CTS를 받은 다른 노드들이 NAV를 설정한다는 점을 서술', 'SUPPLEMENTARY', 5),
(1020, 196, 'ACK 프레임으로 전송 성공 여부를 확인한다는 점을 명시', 'SUPPLEMENTARY', 6),

-- 질문 197
(1021, 197, '인프라스트럭처 방식에서 모든 데이터 통신이 AP나 기지국을 경유함을 언급', 'ESSENTIAL', 1),
(1022, 197, '애드혹 방식에서 단말들이 기지국 없이 서로 직접 연결됨을 서술', 'ESSENTIAL', 2),
(1023, 197, '애드혹 네트워크가 필요할 때마다 임시로 형성된다는 점을 명시', 'ESSENTIAL', 3),
(1024, 197, '중앙 장치가 연결을 관리하므로 인프라스트럭처 방식이 안정적임을 제시', 'SUPPLEMENTARY', 4),
(1025, 197, 'Wi-Fi 공유기·LTE·5G 중 최소 1개를 인프라스트럭처 방식 예시로 제시', 'SUPPLEMENTARY', 5),
(1026, 197, 'Bluetooth·Wi-Fi Direct 중 최소 1개를 애드혹 방식 예시로 제시', 'SUPPLEMENTARY', 6),

-- 질문 198
(1027, 198, '핸드오프가 이동 시 연결을 인접 셀로 전환해 통신 단절을 막는 기능임을 언급', 'ESSENTIAL', 1),
(1028, 198, 'Hard Handoff가 기존 연결을 끊고 새 셀에 연결하는 Break-Before-Make 방식임을 설명', 'ESSENTIAL', 2),
(1029, 198, 'Soft Handoff가 두 셀과 동시에 연결되는 Make-Before-Break 방식임을 서술', 'ESSENTIAL', 3),
(1030, 198, 'Soft Handoff가 CDMA 계열에서 쓰이는 방식임을 명시', 'SUPPLEMENTARY', 4),
(1031, 198, '기지국 제어기가 핸드오프와 이동성 관리를 담당함을 제시', 'SUPPLEMENTARY', 5),

-- 질문 199
(1032, 199, '전파가 거리나 장애물에 의해 약해져 신호 세기가 감소함을 언급', 'ESSENTIAL', 1),
(1033, 199, '간섭·잡음 등 외부 노이즈로 유선보다 안정성이 낮음을 서술', 'ESSENTIAL', 2),
(1034, 199, '사용자가 이동하면서도 네트워크 연결을 유지하는 이동성을 제시', 'ESSENTIAL', 3),
(1035, 199, '신호 세기가 거리 제곱에 비례하여 감소한다는 점을 명시', 'SUPPLEMENTARY', 4),
(1036, 199, '실내에서 반사·흡수로 인한 손실이 크다는 점을 서술', 'SUPPLEMENTARY', 5),

-- 질문 200
(1037, 200, 'WPAN·WLAN·WMAN·WWAN 중 최소 3개를 통신 범위별 분류로 제시', 'ESSENTIAL', 1),
(1038, 200, 'WLAN이 수십~수백 m 범위의 Wi-Fi(IEEE 802.11) 기반임을 언급', 'ESSENTIAL', 2),
(1039, 200, 'WWAN이 수십~수백 km 범위의 셀룰러 이동통신임을 서술', 'ESSENTIAL', 3),
(1040, 200, 'WPAN이 수 m 범위로 Bluetooth·ZigBee에 해당함을 명시', 'SUPPLEMENTARY', 4),
(1041, 200, 'WMAN이 수 km 범위의 도시권 네트워크임을 제시', 'SUPPLEMENTARY', 5);
