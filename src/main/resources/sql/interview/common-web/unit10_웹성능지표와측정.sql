-- Unit: 웹 성능 지표와 측정 (Unit ID: 91)
-- Chapter: Web (Chapter ID: 7)
-- Topic: WEB_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-web-unit10 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(451, 'WEB_COMMON', 91, 'HARD', true,
 '무한 스크롤 피드 페이지에서 초기 로드는 빠른데 실사용자 데이터의 INP가 나쁨으로 나옵니다. 원인을 어떻게 분해해 진단하고, 어떻게 개선하며, 측정할 때 무엇에 주의해야 하는지 설명해 주세요.',
 'INP는 초기 로드가 아니라 페이지 생애 전체에서 발생한 클릭·탭·키 입력의 지연 중 가장 느린 값을 보고하기 때문에, 초기 로드가 빨라도 INP는 나쁠 수 있습니다. 진단은 한 상호작용을 메인 스레드가 다른 태스크로 바빠 클릭이 대기하는 입력 지연, 이벤트 핸들러가 실행되는 처리 시간, 스타일·레이아웃·페인트가 이루어지는 표시 지연의 3구간으로 분해해 어느 구간이 긴지 찾습니다. 무한 스크롤 피드처럼 DOM이 수만 개로 불어난 뒤의 클릭에서는 핸들러가 유발하는 대규모 DOM 갱신 때문에 레이아웃·페인트가 무거워져 표시 지연이 길어지고, 핸들러 안의 큰 계산은 처리 시간을 늘립니다. 개선의 핵심 방향은 긴 태스크 분할, 핸들러 경량화, DOM 갱신 최소화입니다. 예를 들어 버튼 비활성화처럼 가벼운 상태 변경으로 즉각적인 피드백을 먼저 그리고, 무거운 계산과 렌더링은 setTimeout으로 다음 태스크로 양보해 렌더링 기회를 준 뒤 실행합니다. 측정 시에는 Lighthouse 같은 합성 도구가 상호작용을 재현하지 못해 INP를 직접 측정할 수 없다는 점에 주의해야 하며, INP는 실사용자 측정(RUM)에서만 측정되므로 RUM으로 확인하고, Lab에서는 TBT를 대리 지표로 참고합니다.',
 'interview-question/451.mp3'),
(452, 'WEB_COMMON', 91, 'NORMAL', true,
 '실사용자 측정(RUM)과 합성 측정(Lab)은 어떤 차이가 있나요? 그리고 Lighthouse 점수는 좋은데 검색 콘솔에서는 나쁨으로 나오는 이유는 무엇인가요?',
 '실사용자 측정(RUM)은 CrUX나 web-vitals 라이브러리처럼 실제 사용자의 브라우저에서 데이터를 얻고, 합성 측정(Lab)은 Lighthouse·WebPageTest처럼 통제된 환경에서 시뮬레이션해 데이터를 얻습니다. 집계 방식도 달라 RUM은 페이지 뷰의 75번째 백분위수(p75)를 쓰고, Lab은 단일 실행 값을 쓰며 여러 번 실행해 중앙값을 보는 것이 권장됩니다. RUM은 기기·네트워크·행동의 실제 분포를 반영하지만 노이즈가 많고 원인 파악이 어렵고, Lab은 재현 가능하고 배포 전 검증과 상세한 원인 진단에 유리하지만 특정 기기·네트워크를 가정하고 상호작용 재현에 한계가 있어 INP는 RUM에서만 측정됩니다. Lighthouse 점수가 좋은데 검색 콘솔에서 나쁨으로 나오는 것은, Lighthouse가 개발자의 좋은 PC·네트워크에서 한 번 로드한 결과인 반면 검색 콘솔(CrUX)은 저사양 모바일 사용자를 포함한 p75 값이기 때문입니다. 그래서 기준은 항상 실사용자 p75로 보고, Lab 도구는 원인을 찾는 현미경, 즉 원인 진단용으로 씁니다.',
 'interview-question/452.mp3'),
(453, 'WEB_COMMON', 91, 'NORMAL', true,
 'LCP가 느릴 때 리소스 로드 지연이 긴 경우와 요소 렌더 지연이 긴 경우는 원인과 개선 방법이 어떻게 다른가요?',
 'LCP는 TTFB, 리소스 로드 지연, 리소스 로드 시간, 요소 렌더 지연의 4구간으로 분해해 병목을 찾습니다. 리소스 로드 지연이 긴 경우는 LCP 이미지가 CSS 배경 이미지이거나 loading="lazy"가 붙어 있어 브라우저가 이미지를 늦게 발견하는 것이 원인이므로, preload나 fetchpriority="high"로 LCP 리소스를 조기에 발견하고 높은 우선순위로 가져오게 개선합니다. 반면 요소 렌더 지연이 긴 경우는 이미지는 이미 도착했는데 렌더링 차단 CSS나 긴 JS 태스크가 그리기를 막는 것이 원인이므로, CSS 분리나 하이드레이션 분할로 차단을 줄여 개선합니다. 참고로 LCP의 좋음 기준은 2.5초 이하입니다.',
 'interview-question/453.mp3'),
(454, 'WEB_COMMON', 91, 'EASY', true,
 'Core Web Vitals를 구성하는 세 가지 지표는 무엇이며, 각각 무엇을 측정하는지 설명해 주세요.',
 'Core Web Vitals는 LCP·INP·CLS 세 가지로, 각각 로딩·반응성·시각적 안정성을 대표합니다. LCP(Largest Contentful Paint)는 뷰포트 내 가장 큰 이미지 또는 텍스트 블록 같은 콘텐츠가 그려진 시각을 측정하며 2.5초 이하가 좋음입니다. INP(Interaction to Next Paint)는 클릭·탭·키 입력 같은 상호작용 후 다음 화면 갱신까지의 지연을 측정하고 그중 가장 느린 값을 보고하며 200ms 이하가 좋음입니다. INP는 2024년 3월에 FID를 대체했습니다. CLS(Cumulative Layout Shift)는 예상치 못한 레이아웃 이동의 누적량을 측정하는 단위 없는 점수로 0.1 이하가 좋음입니다.',
 'interview-question/454.mp3'),
(455, 'WEB_COMMON', 91, 'EASY', true,
 'CLS 점수는 어떻게 계산되며, 레이아웃 이동을 일으키는 흔한 원인과 해결 방법에는 무엇이 있나요?',
 'CLS는 사용자 입력과 무관하게 이미 보이던 요소가 움직인 정도의 누적 점수입니다. 개별 레이아웃 이동 점수는 영향 비율 × 이동 거리 비율로 계산하고, 여러 이동은 간격 1초 이내·최대 5초의 세션 윈도우로 묶어 가장 큰 윈도우의 합을 CLS로 삼습니다. 입력 후 500ms 이내의 이동은 사용자가 의도한 것으로 보고 제외합니다. 흔한 원인은 크기 없는 이미지·광고·임베드, 웹 폰트 로드 후 글자 크기 변화, 뒤늦게 위쪽에 삽입되는 배너 등입니다. 크기 없는 미디어에는 width/height 속성이나 aspect-ratio로 공간을 미리 확보하고, 폰트는 font-display: optional이나 size-adjust로 대체 폰트 크기를 맞추며, 배너는 오버레이로 표시하거나 공간을 예약합니다. content-visibility: auto 요소의 높이가 지정되지 않아 생기는 이동에는 contain-intrinsic-size를 지정합니다. 또 top/height 대신 transform 애니메이션을 쓰면 레이아웃 이동으로 집계되지 않습니다.',
 'interview-question/455.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 451
(2413, 451, 'INP는 초기 로드가 아니라 페이지 생애 전체의 상호작용에서 측정됨을 언급', 'ESSENTIAL', 1),
(2414, 451, '한 상호작용을 입력 지연·처리 시간·표시 지연 3구간으로 분해해 설명', 'ESSENTIAL', 2),
(2415, 451, '긴 태스크 분할·다음 태스크로 양보·핸들러 경량화·DOM 갱신 최소화 중 최소 1개를 INP 개선책으로 제시', 'ESSENTIAL', 3),
(2416, 451, 'Lighthouse 같은 합성 도구로는 INP를 직접 측정할 수 없음을 언급', 'ESSENTIAL', 4),
(2417, 451, 'DOM이 수만 개로 불어난 뒤의 대규모 DOM 갱신이 표시 지연을 늘린다고 설명', 'SUPPLEMENTARY', 5),
(2418, 451, '가벼운 상태 변경으로 즉각적인 피드백을 먼저 그리는 패턴을 제시', 'SUPPLEMENTARY', 6),
(2419, 451, '합성 측정에서는 TBT를 INP의 대리 지표로 본다고 언급', 'SUPPLEMENTARY', 7),

-- 질문 452
(2420, 452, 'RUM은 실제 사용자 브라우저, Lab은 통제된 환경의 시뮬레이션에서 데이터를 얻는다고 설명', 'ESSENTIAL', 1),
(2421, 452, 'RUM은 페이지 뷰의 p75로, Lab은 단일 실행 값으로 집계된다고 설명', 'ESSENTIAL', 2),
(2422, 452, 'Lighthouse의 좋은 환경 단일 로드 또는 검색 콘솔의 저사양 모바일 포함 p75 중 최소 1개를 차이 원인으로 제시', 'ESSENTIAL', 3),
(2423, 452, 'Lab 도구는 원인 진단용으로 쓴다고 언급', 'SUPPLEMENTARY', 4),
(2424, 452, 'INP는 RUM에서만 측정할 수 있다고 언급', 'SUPPLEMENTARY', 5),
(2425, 452, '재현 가능·배포 전 검증 중 최소 1개를 Lab의 장점으로 제시', 'SUPPLEMENTARY', 6),

-- 질문 453
(2426, 453, '리소스 로드 지연의 원인으로 CSS 배경 이미지나 loading="lazy"로 인한 늦은 발견을 제시', 'ESSENTIAL', 1),
(2427, 453, '리소스 로드 지연의 개선책으로 preload 또는 fetchpriority="high"를 제시', 'ESSENTIAL', 2),
(2428, 453, '렌더 지연의 원인으로 렌더링 차단 CSS나 긴 JS 태스크가 그리기를 막는 상황을 제시', 'ESSENTIAL', 3),
(2429, 453, '렌더 지연의 개선책으로 CSS 분리 또는 하이드레이션 분할을 제시', 'ESSENTIAL', 4),
(2430, 453, 'LCP를 TTFB·리소스 로드 지연·리소스 로드 시간·요소 렌더 지연 4구간으로 분해해 서술', 'SUPPLEMENTARY', 5),
(2431, 453, 'LCP 좋음 기준이 2.5초 이하임을 언급', 'SUPPLEMENTARY', 6),

-- 질문 454
(2432, 454, 'Core Web Vitals가 LCP·INP·CLS 세 가지임을 명시', 'ESSENTIAL', 1),
(2433, 454, 'LCP는 뷰포트 내 가장 큰 콘텐츠가 그려진 시각을 측정한다고 설명', 'ESSENTIAL', 2),
(2434, 454, 'INP는 상호작용 후 다음 화면 갱신까지의 지연을 측정한다고 설명', 'ESSENTIAL', 3),
(2435, 454, 'CLS는 예상치 못한 레이아웃 이동의 누적량을 측정한다고 설명', 'ESSENTIAL', 4),
(2436, 454, '좋음 기준 LCP 2.5초·INP 200ms·CLS 0.1 중 최소 2개를 제시', 'SUPPLEMENTARY', 5),
(2437, 454, 'INP가 2024년 3월에 FID를 대체했다고 언급', 'SUPPLEMENTARY', 6),

-- 질문 455
(2438, 455, '레이아웃 이동 점수를 영향 비율 × 이동 거리 비율로 계산한다고 설명', 'ESSENTIAL', 1),
(2439, 455, '여러 이동을 세션 윈도우로 묶어 가장 큰 윈도우의 합을 CLS로 삼는다고 설명', 'ESSENTIAL', 2),
(2440, 455, '크기 없는 미디어 공간 미리 확보·대체 폰트 크기 맞춤·배너 오버레이 표시 중 최소 1개를 CLS 해결책으로 제시', 'ESSENTIAL', 3),
(2441, 455, '입력 후 500ms 이내의 이동은 CLS 집계에서 제외된다고 언급', 'SUPPLEMENTARY', 4),
(2442, 455, 'transform 애니메이션은 레이아웃 이동으로 집계되지 않는다고 언급', 'SUPPLEMENTARY', 5),
(2443, 455, 'content-visibility 요소에 contain-intrinsic-size를 지정하는 해결책을 제시', 'SUPPLEMENTARY', 6);
