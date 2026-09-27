-- Unit: ref와 DOM 접근 (Unit ID: 147)
-- Chapter: React (Chapter ID: 13)
-- Topic: REACT
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-react-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(731, 'REACT', 147, 'HARD', true,
 'React 컴포넌트에 차트나 지도 같은 서드파티 위젯을 연동해야 할 때 ref와 이펙트를 어떻게 구성하시겠습니까? 잘못 구성하면 어떤 문제가 생기는지도 함께 설명해 주세요.',
 '차트·지도·에디터 같은 서드파티 위젯은 자체 DOM을 관리하기 때문에 선언적으로 처리할 수 없고, ref로 컨테이너를 넘겨 useEffect에서 초기화·클린업하는 방식으로 연동합니다. 먼저 컨테이너로 쓸 div에 ref를 걸되, 이 div는 React가 자식을 렌더하지 않는 빈 컨테이너여야 합니다. React가 렌더하는 노드의 자식을 ref로 직접 추가·삭제하면 React의 재조정과 충돌해 "removeChild 실패" 같은 런타임 오류가 나기 때문입니다. 위젯 인스턴스는 화면에 직접 보이는 값이 아니므로 state가 아니라 별도의 ref에 보관합니다. 이펙트는 두 개로 나눕니다. 빈 의존성 배열의 이펙트에서 마운트 시 createChart로 위젯을 생성하고, 언마운트 시 클린업에서 destroy를 호출해 해제한 뒤 ref를 null로 돌립니다. 그리고 data를 의존성으로 하는 이펙트에서 chartRef.current?.setData(data)로 위젯에 데이터를 동기화합니다. 이렇게 생성·해제와 데이터 동기화를 별도 이펙트로 분리하면 data가 바뀔 때 위젯이 재생성되지 않습니다.'),
(732, 'REACT', 147, 'NORMAL', true,
 'useState와 useRef는 값을 바꿨을 때 어떤 차이가 있고, 각각 어떤 종류의 값을 담는 데 사용하는지 설명해 주세요.',
 '가장 큰 차이는 리렌더 여부입니다. useState는 setter로 값을 바꾸면 리렌더가 일어나고 변경이 다음 렌더에 반영되지만, useRef는 ref.current = x로 값을 바꿔도 리렌더가 일어나지 않고 즉시 반영됩니다. 값을 읽는 시점도 다릅니다. state는 해당 렌더의 스냅샷 값을 읽는 반면, ref 객체는 컴포넌트가 살아 있는 동안 같은 참조를 유지하므로 항상 최신 current를 읽습니다. 그래서 화면에 보이는 값은 state에 두고, 바뀌어도 화면을 다시 그릴 필요가 없는 값이나 DOM 노드는 ref에 둡니다. 예를 들어 타이머 id를 state에 두면 불필요한 리렌더가 생기고 스냅샷 때문에 clearInterval 대상이 낡을 수 있어 ref에 보관하는 것이 맞습니다. 다만 ref는 렌더 중에 읽거나 쓰면 렌더 순수성 위반이므로 이벤트 핸들러나 이펙트 안에서만 다뤄야 합니다.'),
(733, 'REACT', 147, 'NORMAL', true,
 '부모 컴포넌트가 자식 함수 컴포넌트 내부의 DOM 요소에 ref로 접근하려면 React 18 이하와 React 19에서 각각 어떻게 해야 하는지 설명해 주세요.',
 'React 18까지는 함수 컴포넌트에 ref를 넘겨도 props에 포함되지 않아 컴포넌트 함수에 전달되지 않았습니다. 그래서 자식 컴포넌트를 forwardRef로 감싸 두 번째 인자로 ref를 받고, 이를 내부 input 같은 DOM 요소에 넘겨주도록 명시해야 부모의 ref가 내부 DOM에 도달했습니다. React 19부터는 ref가 일반 prop으로 전달되므로 forwardRef 없이 props에서 ref를 구조 분해해 내부 요소에 넘기면 됩니다. 부모 쪽 사용법은 두 버전 모두 동일합니다. React 19에서도 forwardRef는 당장 동작하지만 향후 제거가 예고되어 있으므로 새 코드는 ref를 prop으로 받는 형태로 작성하고, 여러 버전을 지원해야 하는 라이브러리라면 당분간 forwardRef를 유지합니다. 참고로 React 19부터는 콜백 ref가 클린업 함수를 반환할 수 있어, 반환한 함수가 해제 시 호출됩니다.'),
(734, 'REACT', 147, 'EASY', true,
 'useImperativeHandle은 무엇이고 왜 사용하는지 설명해 주세요.',
 '부모에게 자식의 DOM 노드 전체를 넘기면 부모가 자식의 내부 구조에 의존하게 됩니다. useImperativeHandle은 ref를 통해 DOM 노드 전체 대신 play·pause처럼 제한된 명령형 API만 노출하는 훅입니다. 예를 들어 VideoPlayer 컴포넌트가 내부 video 요소는 자체 ref로 잡아 두고, useImperativeHandle로 play와 pause 함수만 부모 ref에 노출하면 부모는 playerRef.current.play()는 호출할 수 있지만 내부 DOM에는 접근할 수 없습니다. 이렇게 하면 video가 div 안에 있든 없든 부모가 신경 쓰지 않아도 되므로 캡슐화가 유지됩니다. 다만 자주 쓰면 데이터 흐름이 불투명해지므로 포커스·재생·스크롤처럼 props로 표현할 수 없는 명령에 한정해 사용합니다.'),
(735, 'REACT', 147, 'EASY', true,
 'JSX의 ref 속성으로 DOM 노드를 참조할 때, ref.current에 노드가 채워지는 시점과 다시 비워지는 시점을 설명해 주세요.',
 '렌더 단계에서는 아직 DOM이 없기 때문에 ref.current는 null입니다. 이후 커밋 단계에서 DOM이 반영되고, useLayoutEffect가 실행되기 직전에 ref가 연결되어 current에 실제 DOM 노드가 들어옵니다. 그래서 useLayoutEffect에서는 페인트 전에 DOM을 측정할 수 있고, 브라우저 페인트 후 실행되는 useEffect에서도 DOM에 접근할 수 있습니다. 컴포넌트가 언마운트되는 커밋에서는 ref.current가 다시 null로 돌아갑니다. 조건부 렌더링으로 요소가 사라졌다 나타나면 current도 null과 노드 사이를 오가므로 ref.current?.focus()처럼 옵셔널 체이닝을 쓰는 것이 안전합니다. 같은 이유로 ref는 렌더 도중에 읽지 말고 이벤트 핸들러나 이펙트 안에서만 다뤄야 합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 731
(3939, 731, '위젯은 React가 자식을 렌더하지 않는 빈 컨테이너에만 마운트해야 함을 언급', 'ESSENTIAL', 1),
(3940, 731, 'React가 렌더하는 노드의 자식을 ref로 추가·삭제하면 재조정과 충돌해 런타임 오류가 남을 언급', 'ESSENTIAL', 2),
(3941, 731, '생성·해제와 데이터 동기화 이펙트를 분리하면 data 변경 시 위젯이 재생성되지 않음을 설명', 'ESSENTIAL', 3),
(3942, 731, '위젯 인스턴스는 화면에 직접 보이는 값이 아니므로 state가 아닌 ref에 보관한다고 설명', 'ESSENTIAL', 4),
(3943, 731, '언마운트 시 이펙트 클린업에서 위젯 인스턴스를 destroy로 해제함을 언급', 'SUPPLEMENTARY', 5),
(3944, 731, '차트·지도·에디터 위젯은 자체 DOM을 관리해 선언적으로 처리할 수 없음을 언급', 'SUPPLEMENTARY', 6),

-- 질문 732
(3945, 732, 'ref.current를 바꿔도 리렌더가 없지만 state 변경은 리렌더를 일으킨다는 차이를 설명', 'ESSENTIAL', 1),
(3946, 732, 'ref는 항상 최신 current를 읽고 state는 렌더의 스냅샷 값을 읽는다는 차이를 설명', 'ESSENTIAL', 2),
(3947, 732, '화면에 보이는 값은 state에, 화면과 무관한 값이나 DOM 노드는 ref에 둔다고 설명', 'ESSENTIAL', 3),
(3948, 732, '타이머 id·이전 값·스크롤 위치·웹소켓 인스턴스 중 최소 1개를 ref 보관 예시로 제시', 'SUPPLEMENTARY', 4),
(3949, 732, '렌더 중 ref.current를 읽거나 쓰는 것은 렌더 순수성 위반이라 금지됨을 언급', 'SUPPLEMENTARY', 5),

-- 질문 733
(3950, 733, 'React 18까지 함수 컴포넌트는 ref를 props로 받지 못해 forwardRef로 감싸야 했음을 설명', 'ESSENTIAL', 1),
(3951, 733, 'React 19부터 ref가 일반 prop으로 전달되어 forwardRef가 불필요함을 언급', 'ESSENTIAL', 2),
(3952, 733, 'forwardRef는 향후 제거가 예고되어 새 코드는 ref를 prop으로 받는 형태로 작성한다고 언급', 'SUPPLEMENTARY', 3),
(3953, 733, '여러 React 버전을 지원해야 하는 라이브러리는 당분간 forwardRef를 유지한다고 언급', 'SUPPLEMENTARY', 4),
(3954, 733, 'React 19부터 콜백 ref가 클린업 함수를 반환할 수 있음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 734
(3955, 734, 'useImperativeHandle은 ref를 통해 DOM 노드 전체 대신 제한된 명령형 API만 노출함을 설명', 'ESSENTIAL', 1),
(3956, 734, '부모가 자식의 내부 구조에 의존하지 않게 되어 캡슐화가 유지됨을 언급', 'ESSENTIAL', 2),
(3957, 734, '사용을 포커스·재생·스크롤처럼 props로 표현할 수 없는 명령에 한정한다고 언급', 'SUPPLEMENTARY', 3),
(3958, 734, 'useImperativeHandle을 자주 쓰면 데이터 흐름이 불투명해진다고 언급', 'SUPPLEMENTARY', 4),

-- 질문 735
(3959, 735, '렌더 단계에서는 아직 DOM이 없어 ref.current가 null임을 언급', 'ESSENTIAL', 1),
(3960, 735, '커밋에서 DOM이 반영된 뒤 useLayoutEffect 실행 직전에 ref가 연결된다고 설명', 'ESSENTIAL', 2),
(3961, 735, '언마운트 커밋 시 ref.current가 다시 null로 돌아감을 언급', 'ESSENTIAL', 3),
(3962, 735, '조건부 렌더링으로 current가 null과 노드를 오가므로 옵셔널 체이닝이 안전하다고 언급', 'SUPPLEMENTARY', 4),
(3963, 735, 'DOM ref는 렌더 도중이 아니라 이벤트 핸들러나 이펙트 안에서만 다룬다고 언급', 'SUPPLEMENTARY', 5);
