-- Unit: 액티비티와 프래그먼트 생명주기 (Unit ID: 93)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit02 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(461, 'AOS_COMMON', 93, 'HARD', true,
 '동영상 재생기(ExoPlayer)를 onCreate()에서 만들고 onDestroy()에서만 해제하는 액티비티가 있습니다. 이 코드에서 어떤 문제가 생기는지, 그리고 어떤 콜백에서 할당·해제하도록 바꾸는 것이 좋은지 화면 전환 시 콜백 순서까지 고려해 설명해 주세요.',
 'onCreate()에서 재생기를 만들고 onDestroy()에서만 해제하면, 사용자가 홈 버튼으로 나가 화면이 보이지 않는 상태에서도 재생기가 살아 있어 배터리와 메모리가 낭비됩니다. 개선 방법은 재생기를 가시 수명, 즉 onStart()에서 만들고 onStop()에서 release()하는 대칭 콜백 쌍에 맞추는 것입니다. 자원은 onCreate↔onDestroy, onStart↔onStop, onResume↔onPause처럼 대칭 쌍에서 할당·해제해야 하고, 짝이 어긋나면 화면이 여러 번 열리고 닫힐 때 중복 등록이나 누수가 생깁니다. 그렇다고 onPause()에 무거운 정리를 두면 안 됩니다. A에서 B로 전환할 때 A.onPause()가 끝나야 B.onResume()이 호출되므로, onPause()에서 DB 저장이나 네트워크 호출 같은 무거운 작업을 하면 화면 전환이 눈에 띄게 느려집니다. 그래서 무거운 자원 해제는 onStop()으로 미루는 것이 적절합니다. 참고로 onDestroy()는 호출이 보장되는 콜백이 아니어서, 메모리 부족으로 프로세스가 통째로 종료되면 onDestroy()는 호출되지 않습니다.'),
(462, 'AOS_COMMON', 93, 'NORMAL', true,
 '액티비티의 onPause()와 onStop()은 각각 언제 호출되며, 두 콜백에 어떤 작업을 나눠 두어야 하는지 차이를 설명해 주세요.',
 'onPause()는 다이얼로그가 뜨거나 다른 화면이 위로 올라와 액티비티가 포커스를 잃었을 때, 즉 부분적으로 가려진 상태에서 호출됩니다. onStop()은 화면이 사용자에게 완전히 보이지 않게 되었을 때 호출됩니다. onResume()~onPause() 구간이 상호작용 가능한 포그라운드 수명이고, onStart()~onStop() 구간이 화면이 보이는 가시 수명입니다. onPause()가 끝나야 다음 액티비티의 onResume()이 호출되기 때문에, onPause()에는 카메라·센서 해제나 가벼운 저장처럼 짧은 작업만 두어야 합니다. 반면 무거운 자원 해제, DB 저장, 리스너 해제는 onStop()에서 처리합니다. onPause()에서 무거운 작업을 하면 화면 전환이 눈에 띄게 느려지기 때문입니다.'),
(463, 'AOS_COMMON', 93, 'NORMAL', true,
 '프래그먼트에서 LiveData를 관찰할 때 this 대신 viewLifecycleOwner를 LifecycleOwner로 써야 하는 이유를 프래그먼트 수명과 뷰 수명의 차이와 연결해 설명해 주세요.',
 '프래그먼트는 프래그먼트 자체의 수명과 뷰의 수명이 분리되어 있습니다. 백 스택에 들어간 프래그먼트는 onDestroyView()까지만 호출되어 뷰는 파괴되지만 onDestroy()는 호출되지 않아 인스턴스는 살아 있습니다. 뒤로 가기로 돌아오면 onCreateView()부터 뷰만 다시 생성됩니다. 이때 this, 즉 프래그먼트를 LifecycleOwner로 써서 관찰하면 뷰가 파괴돼도 옵저버가 남아 있기 때문에 복귀 시 옵저버가 두 개로 누적됩니다. viewLifecycleOwner를 사용하면 뷰 수명에 맞춰 옵저버가 자동으로 해제되므로 중복 옵저버와 누수를 막을 수 있습니다. 같은 이유로 뷰 바인딩 객체도 onDestroyView()에서 null로 만들어야 합니다. 그렇지 않으면 파괴된 뷰 트리 전체가 프래그먼트에 붙잡혀 메모리 누수가 생깁니다.'),
(464, 'AOS_COMMON', 93, 'EASY', true,
 '액티비티 A에서 startActivity()로 액티비티 B를 시작할 때 두 액티비티의 생명주기 콜백이 어떤 순서로 호출되는지 설명해 주세요.',
 'A에서 B를 시작하면 두 액티비티의 콜백이 번갈아 호출됩니다. 먼저 A.onPause()가 호출되고, 그다음 B.onCreate(), B.onStart(), B.onResume()이 차례로 호출되어 이 시점부터 B와 상호작용할 수 있습니다. A.onStop()은 B가 화면을 완전히 덮은 뒤, 즉 B.onResume() 다음에 호출됩니다. 다만 B가 투명하거나 다이얼로그 테마라면 A가 여전히 부분적으로 보이기 때문에 A는 onPause()까지만 가고 onStop()은 호출되지 않습니다. 반대로 B에서 뒤로 가기를 누르면 B.onPause() 후 A.onRestart(), A.onStart(), A.onResume()으로 A가 복귀하고, 그 뒤 B.onStop(), B.onDestroy()가 호출됩니다.'),
(465, 'AOS_COMMON', 93, 'EASY', true,
 '액티비티가 생성될 때부터 파괴될 때까지 기본 콜백들이 어떤 순서로 호출되는지, 그리고 onStart()와 onResume()이 각각 어떤 시점에 호출되는지 설명해 주세요.',
 '액티비티가 생성되면 onCreate() → onStart() → onResume() 순서로 콜백이 호출됩니다. onCreate()는 최초 생성 시 1회 호출되며, 여기서 뷰 바인딩, ViewModel 연결, 저장 상태 복원을 수행합니다. onStart()는 화면이 사용자에게 보이기 시작할 때, onResume()은 화면이 포커스를 얻어 사용자와 상호작용할 수 있게 될 때 호출됩니다. 화면을 벗어나 포커스를 잃으면 onPause(), 화면이 완전히 보이지 않게 되면 onStop()이 호출되고, 액티비티가 파괴될 때는 그 뒤 파괴 직전에 onDestroy()까지 호출됩니다. 즉 액티비티가 파괴될 때는 onPause() → onStop() → onDestroy() 순서입니다. onStop() 상태에서 다시 화면으로 돌아오면 보이기 직전에 onRestart()가 호출되고 onStart(), onResume()으로 이어집니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 461
(2471, 461, '홈 버튼으로 나가도 재생기가 살아 있어 배터리·메모리가 낭비되는 문제를 설명', 'ESSENTIAL', 1),
(2472, 461, '재생기를 가시 수명인 onStart()~onStop() 대칭 콜백 쌍에서 할당·해제하는 방안을 제시', 'ESSENTIAL', 2),
(2473, 461, 'onPause()에서 무거운 작업을 하면 다음 액티비티의 onResume()이 늦어져 화면 전환이 느려짐을 설명', 'ESSENTIAL', 3),
(2474, 461, '짝이 어긋난 콜백에서 할당·해제하면 화면을 여러 번 열고 닫을 때 중복 등록이나 누수가 생김을 언급', 'SUPPLEMENTARY', 4),
(2475, 461, '프로세스가 통째로 종료되면 onDestroy()가 호출되지 않음을 언급', 'SUPPLEMENTARY', 5),

-- 질문 462
(2476, 462, 'onPause()는 다이얼로그나 다른 화면 때문에 포커스를 잃었을 때 호출됨을 설명', 'ESSENTIAL', 1),
(2477, 462, 'onStop()은 화면이 완전히 보이지 않게 되었을 때 호출됨을 설명', 'ESSENTIAL', 2),
(2478, 462, 'onPause()에는 카메라·센서 해제 같은 가벼운 작업만 매우 짧게 두어야 함을 언급', 'ESSENTIAL', 3),
(2479, 462, '무거운 자원 해제나 DB 저장은 onStop()에서 처리함을 언급', 'ESSENTIAL', 4),
(2480, 462, '포그라운드 수명은 onResume()~onPause(), 가시 수명은 onStart()~onStop() 구간임을 제시', 'SUPPLEMENTARY', 5),

-- 질문 463
(2481, 463, '백 스택에 들어간 프래그먼트는 onDestroyView()까지만 호출되고 인스턴스는 유지됨을 설명', 'ESSENTIAL', 1),
(2482, 463, '뒤로 가기로 돌아오면 onCreateView()부터 뷰만 다시 생성됨을 언급', 'ESSENTIAL', 2),
(2483, 463, 'this로 관찰하면 뷰가 파괴돼도 옵저버가 남아 복귀 시 옵저버가 중복됨을 설명', 'ESSENTIAL', 3),
(2484, 463, 'viewLifecycleOwner를 쓰면 뷰 수명에 맞춰 옵저버가 자동 해제됨을 언급', 'ESSENTIAL', 4),
(2485, 463, 'onDestroyView()에서 바인딩을 null로 만들지 않으면 파괴된 뷰 트리가 남아 누수됨을 설명', 'SUPPLEMENTARY', 5),

-- 질문 464
(2486, 464, 'A.onPause()가 B의 콜백보다 먼저 호출됨을 언급', 'ESSENTIAL', 1),
(2487, 464, 'B.onCreate() → B.onStart() → B.onResume() 순서로 호출됨을 제시', 'ESSENTIAL', 2),
(2488, 464, 'A.onStop()은 B.onResume() 다음에 호출됨을 명시', 'ESSENTIAL', 3),
(2489, 464, 'B가 투명하거나 다이얼로그 테마라면 A는 onPause()까지만 가고 onStop()은 호출되지 않음을 언급', 'SUPPLEMENTARY', 4),
(2490, 464, 'B에서 뒤로 가기 시 A.onRestart()·onStart()·onResume() 후 B.onStop()·onDestroy()가 호출됨을 제시', 'SUPPLEMENTARY', 5),

-- 질문 465
(2491, 465, '생성 시 onCreate() → onStart() → onResume() 순서로 호출됨을 설명', 'ESSENTIAL', 1),
(2492, 465, '액티비티가 파괴될 때 onPause() → onStop() → onDestroy() 순서로 호출됨을 설명', 'ESSENTIAL', 2),
(2493, 465, 'onStart()는 화면이 보이기 시작할 때, onResume()은 포커스를 얻어 상호작용 가능할 때 호출됨을 설명', 'ESSENTIAL', 3),
(2494, 465, 'onStop() 이후 다시 보이기 직전에 onRestart()가 호출되어 onStart()로 이어짐을 언급', 'SUPPLEMENTARY', 4),
(2495, 465, 'onCreate()에서 뷰 바인딩·ViewModel 연결을 수행함을 언급', 'SUPPLEMENTARY', 5);
