-- Unit: Reflow와 Repaint (Unit ID: 83)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(411, 'WEB_COMMON', 83, 'HARD', true,
 '사이드 메뉴를 left 속성으로 슬라이드 애니메이션했더니 화면이 끊깁니다. 원인은 무엇이고 어떻게 개선하며, 그 개선책에는 어떤 한계가 있나요?',
 'left는 요소의 위치를 바꾸는 기하 속성이라, 애니메이션 중 프레임마다 메인 스레드에서 스타일, 레이아웃, 페인트가 반복 실행되고 그 뒤에 합성이 일어납니다. 레이아웃은 변경이 형제·자손 요소로 연쇄되기 때문에 가장 비싸고, 이것이 끊김의 원인입니다. 개선하려면 left 대신 transform: translateX()로 이동시킵니다. 요소가 자체 합성 레이어로 분리되어 있으면 transform은 이미 래스터화된 비트맵을 어디에 배치할지만 바꾸므로, 레이아웃과 페인트를 건너뛰고 합성 단계만 다시 실행됩니다. 또한 합성은 메인 스레드와 분리된 합성 스레드에서 처리되므로 JS 실행으로 메인 스레드가 바빠도 애니메이션이 끊기지 않습니다. 다만 한계도 있습니다. 레이어가 없으면 합성 전용이 아니어서, transform을 처음 적용하는 순간에는 레이어를 새로 만들기 위해 페인트가 한 번 발생합니다. 그래서 will-change: transform을 애니메이션 직전에만 부여하는 것이 이상적이고, 합성 레이어가 지나치게 많아지면 메모리 낭비가 생길 수 있으므로 DevTools의 Layer borders나 Layers 패널로 확인하는 것이 좋습니다.',
 'interview-question/411.mp3'),
(412, 'WEB_COMMON', 83, 'NORMAL', true,
 'Reflow와 Repaint의 차이는 무엇이며, 두 과정은 어떤 관계인가요?',
 'Reflow는 Layout이라고도 하며, 요소의 위치와 크기를 다시 계산하는 과정입니다. 한 요소의 기하 정보가 바뀌면 자식·형제·조상 요소로 연쇄되기 때문에 비용이 큽니다. Repaint는 레이아웃 변화 없이 픽셀만 다시 그리는 과정으로, 레이아웃 단계를 건너뛰고 페인트부터 다시 실행됩니다. 두 과정의 관계는 Reflow가 일어나면 Repaint가 반드시 뒤따르지만, Repaint가 일어난다고 Reflow가 일어나는 것은 아니라는 것입니다. 예를 들어 width, height, margin을 바꾸면 Reflow가 발생하고, color나 background-color처럼 보이는 모습만 바꾸는 속성은 Reflow 없이 Repaint만 유발합니다. 다만 Repaint가 Reflow보다 저렴하더라도, box-shadow나 filter처럼 픽셀 연산이 무거운 속성이 큰 영역에 걸쳐 있으면 여전히 프레임을 떨어뜨릴 수 있습니다.',
 'interview-question/412.mp3'),
(413, 'WEB_COMMON', 83, 'NORMAL', true,
 'CSS contain 속성과 content-visibility: auto는 각각 어떤 방식으로 렌더링 비용을 줄이며, 서로 어떻게 다른가요?',
 '브라우저는 변경이 트리 어디까지 영향을 주는지 알 수 없어 보수적으로 넓게 다시 계산합니다. CSS contain 속성은 개발자가 이 요소의 내부 변경은 바깥에 영향이 없다고 선언해서 그 범위를 좁히는 수단입니다. 예를 들어 contain: layout을 주면 내부 Reflow가 바깥으로 전파되지 않고, contain: paint는 페인트 영역을 요소 박스로 제한하며, contain: strict는 size layout paint style을 한꺼번에 적용하는 가장 강한 격리입니다. 반면 content-visibility: auto는 변경의 전파를 막는 것이 아니라 뷰포트 밖 요소의 렌더링 자체를 건너뛰어, 긴 목록이나 피드에서 초기 렌더 비용을 크게 줄입니다. 즉 contain은 변경의 영향 범위를 제한하고, content-visibility: auto는 화면 밖 요소의 렌더링을 미룬다는 점이 다릅니다. 주의할 점은 content-visibility: auto가 요소가 뷰포트에 들어올 때 비로소 레이아웃을 수행하므로, contain-intrinsic-size로 예상 높이를 지정하지 않으면 스크롤 도중 높이가 갑자기 바뀌어 레이아웃 이동(CLS)이 발생한다는 것입니다.',
 'interview-question/413.mp3'),
(414, 'WEB_COMMON', 83, 'EASY', true,
 '레이아웃 스래싱(Layout Thrashing)이란 무엇이며, 어떻게 줄일 수 있나요?',
 '레이아웃 스래싱은 JavaScript에서 offsetWidth 같은 기하 정보 읽기와 style.width 같은 쓰기를 번갈아 수행할 때 발생하는 현상입니다. 쓰기가 레이아웃을 무효화한 직후 읽기를 하면, 브라우저는 최신 결과를 보장하기 위해 변경을 모아 처리하지 못하고 매번 강제 동기 레이아웃을 실행합니다. 그래서 요소 100개를 반복문에서 읽고 쓰면 레이아웃이 100번 실행될 수 있습니다. 줄이는 방법은 먼저 읽기를 모두 끝낸 뒤 쓰기를 한 번에 수행하도록 읽기 구간과 쓰기 구간을 분리하는 것이고, 이렇게 하면 레이아웃이 1번만 실행됩니다. 쓰기는 requestAnimationFrame 콜백으로 미룰 수 있고, 여러 스타일 변경은 개별 style 대신 클래스 토글 한 번으로 처리하며, 많은 노드를 추가할 때는 DocumentFragment에 모아 한 번에 삽입하는 방법도 있습니다.',
 'interview-question/414.mp3'),
(415, 'WEB_COMMON', 83, 'EASY', true,
 'Reflow를 유발하는 대표적인 변경이나 행위에는 어떤 것들이 있나요?',
 'Reflow는 요소의 기하 정보가 바뀔 때 발생합니다. 대표적으로 width, height, padding, margin, border-width 같은 크기·여백 속성과 top, left, position, display 같은 위치·배치 속성을 바꾸면 Reflow가 일어납니다. font-size, line-height 같은 글꼴·텍스트 변경이나 텍스트 내용 변경도 원인이 되고, 노드 추가·삭제·이동이나 innerHTML 교체 같은 DOM 구조 변경도 Reflow를 유발합니다. 브라우저 창 크기 변경, 스크롤바 등장, 폰트 로딩 완료도 마찬가지입니다. 가장 자주 놓치는 것은 기하 정보 읽기입니다. offsetWidth, clientHeight, getBoundingClientRect() 같은 값을 읽기만 해도 브라우저는 최신 결과를 보장하기 위해 예약된 레이아웃을 즉시 실행하는데, 이를 강제 동기 레이아웃이라 합니다.',
 'interview-question/415.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 411
(2192, 411, 'left 변경은 프레임마다 레이아웃과 페인트를 다시 실행시킨다는 점을 원인으로 설명', 'ESSENTIAL', 1),
(2193, 411, 'left 대신 transform으로 이동시키면 합성 단계만 다시 실행됨을 설명', 'ESSENTIAL', 2),
(2194, 411, 'transform을 처음 적용할 때 레이어를 새로 만들기 위해 페인트가 한 번 발생함을 한계로 언급', 'ESSENTIAL', 3),
(2195, 411, '합성은 메인 스레드와 분리된 합성 스레드에서 처리되어 JS 실행 중에도 끊기지 않음을 설명', 'SUPPLEMENTARY', 4),
(2196, 411, 'will-change는 애니메이션 직전에만 부여하는 것이 이상적임을 언급', 'SUPPLEMENTARY', 5),
(2197, 411, '합성 레이어가 지나치게 많으면 메모리 낭비가 생길 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 412
(2198, 412, 'Reflow는 요소의 위치·크기를 다시 계산하는 과정임을 설명', 'ESSENTIAL', 1),
(2199, 412, 'Repaint는 레이아웃 변화 없이 픽셀만 다시 그리는 과정임을 설명', 'ESSENTIAL', 2),
(2200, 412, 'Reflow가 일어나면 Repaint가 반드시 뒤따르지만 그 역은 성립하지 않음을 설명', 'ESSENTIAL', 3),
(2201, 412, 'color·background-color처럼 Repaint만 유발하는 속성을 최소 1개 예시로 제시', 'SUPPLEMENTARY', 4),
(2202, 412, 'Reflow는 자식·형제·조상 요소로 연쇄되어 Repaint보다 비용이 크다고 언급', 'SUPPLEMENTARY', 5),
(2203, 412, 'box-shadow처럼 픽셀 연산이 무거운 속성은 Repaint만으로도 프레임을 떨어뜨릴 수 있음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 413
(2204, 413, 'contain은 내부 변경이 바깥에 영향이 없다고 선언해 Reflow 전파 범위를 좁힌다고 설명', 'ESSENTIAL', 1),
(2205, 413, 'content-visibility: auto는 뷰포트 밖 요소의 렌더링을 건너뛴다고 설명', 'ESSENTIAL', 2),
(2206, 413, 'contain-intrinsic-size를 지정하지 않으면 스크롤 중 레이아웃 이동(CLS)이 발생함을 언급', 'SUPPLEMENTARY', 3),
(2207, 413, 'contain: paint는 페인트 영역을 요소 박스로 제한함을 언급', 'SUPPLEMENTARY', 4),
(2208, 413, 'contain: strict는 size layout paint style을 한꺼번에 적용함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 414
(2209, 414, 'JavaScript에서 기하 정보 읽기와 스타일 쓰기를 번갈아 수행할 때 발생한다고 설명', 'ESSENTIAL', 1),
(2210, 414, '읽기·쓰기 교차로 매번 강제 동기 레이아웃이 실행된다는 점을 설명', 'ESSENTIAL', 2),
(2211, 414, '읽기를 모두 끝낸 뒤 쓰기를 한 번에 수행하도록 분리하는 방법을 제시', 'ESSENTIAL', 3),
(2212, 414, '쓰기를 requestAnimationFrame 콜백으로 미루는 방법을 언급', 'SUPPLEMENTARY', 4),
(2213, 414, '여러 스타일 변경을 클래스 토글 한 번으로 처리하는 방법을 언급', 'SUPPLEMENTARY', 5),
(2214, 414, '많은 노드를 DocumentFragment에 모아 한 번에 삽입하는 방법을 언급', 'SUPPLEMENTARY', 6),

-- 질문 415
(2215, 415, 'width·height·margin 등 크기·여백 속성 변경 중 최소 1개를 Reflow 원인으로 제시', 'ESSENTIAL', 1),
(2216, 415, '노드 추가·삭제 등 DOM 구조 변경을 Reflow 원인으로 언급', 'ESSENTIAL', 2),
(2217, 415, 'offsetWidth 등 기하 정보를 읽기만 해도 레이아웃이 즉시 실행될 수 있음을 설명', 'ESSENTIAL', 3),
(2218, 415, 'font-size 등 글꼴·텍스트 변경도 Reflow를 유발함을 언급', 'SUPPLEMENTARY', 4),
(2219, 415, '브라우저 창 크기 변경이나 폰트 로딩 완료도 Reflow를 유발함을 언급', 'SUPPLEMENTARY', 5);
