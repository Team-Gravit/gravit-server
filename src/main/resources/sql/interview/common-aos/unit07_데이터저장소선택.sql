-- Unit: 데이터 저장소 선택 (Unit ID: 98)
-- Chapter: AOS (Chapter ID: 8)
-- Topic: AOS_COMMON
-- Source: gravit-interview-contents-generator/output/2026-09-24/common-aos-unit07 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)
VALUES
(486, 'AOS_COMMON', 98, 'HARD', true,
 '오프라인에서도 볼 수 있는 기사 목록(최근순 조회 필요), 다크 모드 같은 설정값, 기사 썸네일 이미지를 앱에 저장해야 한다면 각각 어떤 저장소를 선택하시겠어요? 잘못 선택했을 때 생기는 문제도 함께 설명해 주세요.',
 '저장소는 데이터 개수보다 어떻게 읽을 것인가를 기준으로 고릅니다. 키로 통째로 꺼내면 키-값 저장소, 조건으로 걸러 일부만 꺼내면 DB, 바이너리는 파일입니다. 기사 목록은 수십 건 이상 계속 늘어나고 최근순 정렬·조건 조회가 필요하며 오프라인 우선 전략으로 서버 데이터의 로컬 사본을 유지해야 하므로 Room에 저장합니다. DAO에서 Flow<List<T>>를 반환하면 테이블 변경 시 UI가 자동으로 갱신됩니다. 다크 모드 같은 소수의 설정·플래그는 DataStore에 저장합니다. 반대로 목록을 DataStore에 넣으면 DataStore는 소량 설정용이라 매 변경마다 전체 파일을 다시 쓰게 되어 느려지고, ''최근 것 10개만'' 같은 조회가 필요해지는 순간 키-값 저장소는 한계에 부딪힙니다. 썸네일 이미지는 바이너리이므로 DB에 넣지 않고 파일(내부 저장소 또는 캐시)로 저장한 뒤 DB에는 경로만 보관합니다. 이미지를 DB에 넣으면 DB 파일이 비대해지고 쿼리 성능이 떨어집니다. 썸네일처럼 재생성 가능한 데이터를 cacheDir에 둔다면 저장 공간이 부족할 때 시스템이 삭제할 수 있으므로 없어도 동작하도록 만들어야 합니다.'),
(487, 'AOS_COMMON', 98, 'NORMAL', true,
 'Android에서 SharedPreferences 대신 DataStore를 사용하는 이유는 무엇인가요?',
 'SharedPreferences는 XML 파일 하나에 키-값을 저장하는 레거시 API로 설계상 한계가 있습니다. commit()은 호출 스레드에서 동기 디스크 쓰기를 해 스레드를 막고, apply()도 onStop() 등에서 디스크 쓰기가 끝날 때까지 대기해 ANR의 원인이 되어 왔습니다. 또 apply()는 실패해도 예외를 던지지 않아 오류를 알 수 없고, 키가 문자열이고 값은 런타임 캐스팅이라 타입 안전성도 없습니다. DataStore는 코루틴과 Flow 위에서 동작하는 비동기 방식이라 메인 스레드를 막지 않습니다. 모든 I/O는 Dispatchers.IO에서 수행됩니다. edit {}는 원자적 읽기-수정-쓰기를 보장하고 실패 시 예외로 알려줍니다. 읽기가 Flow라서 설정 변경이 UI에 자동 반영되고, SharedPreferencesMigration으로 기존 데이터를 첫 접근 시 자동 이전할 수 있어 전환도 쉽습니다.'),
(488, 'AOS_COMMON', 98, 'NORMAL', true,
 'Preferences DataStore와 Proto DataStore의 차이는 무엇이고, 각각 어떤 경우에 적합한가요?',
 '핵심 차이는 스키마 유무입니다. Preferences DataStore는 스키마 없이 키-값으로 저장하고, Proto DataStore는 Protocol Buffers로 스키마를 정의합니다. 그래서 Proto DataStore는 타입 안전하다는 장점이 있지만, .proto 정의와 빌드 설정이 필요합니다. 반면 Preferences DataStore는 SharedPreferences에서 마이그레이션하기 쉽습니다. 따라서 단순 설정이나 빠른 전환에는 Preferences DataStore, 구조화된 설정 객체나 타입 안전이 중요한 경우에는 Proto DataStore가 적합합니다. 어느 쪽이든 같은 파일에 대해 인스턴스를 두 개 이상 만들면 예외가 발생하므로 최상위 프로퍼티나 DI 컨테이너로 싱글턴 관리해야 합니다.'),
(489, 'AOS_COMMON', 98, 'EASY', true,
 'Room의 구성 요소인 Entity, DAO, Database는 각각 어떤 역할을 하나요?',
 'Room은 SQLite 위에 컴파일 타임 SQL 검증, 객체 매핑, Flow 통합을 얹은 Jetpack 라이브러리입니다. Entity는 테이블에 대응하는 클래스로, @Entity와 @PrimaryKey 등으로 정의합니다. DAO는 쿼리를 정의하는 인터페이스로, @Query에 작성한 SQL이 컴파일 시 검증되고 suspend 함수나 Flow 반환을 지원합니다. Flow를 반환하면 테이블이 변경될 때 자동으로 다시 방출됩니다. Database는 RoomDatabase를 상속해 DAO를 제공하는 진입점이며, 싱글턴으로 관리합니다.'),
(490, 'AOS_COMMON', 98, 'EASY', true,
 'Android 10부터 적용된 범위 지정 저장소(Scoped Storage)란 무엇이고, 공유 데이터에는 어떻게 접근하나요?',
 'Android 10(API 29)부터 범위 지정 저장소(Scoped Storage)가 적용되어 앱이 외부 저장소를 자유롭게 읽고 쓸 수 없게 되었습니다. 앱 전용 파일은 filesDir, cacheDir 같은 내부 저장소나 getExternalFilesDir()의 외부 앱 전용 공간에 두며, 이들은 권한이 불필요하고 앱 삭제 시 함께 삭제됩니다. 다른 앱과 공유해야 하는 데이터는 MediaStore나 Storage Access Framework(SAF)를 통해 접근합니다. 사진·동영상·음악 같은 공유 미디어는 MediaStore를 쓰고 읽기 시 미디어 권한이 필요하며 앱을 삭제해도 유지됩니다. 사용자가 고른 문서를 가져오거나 내보낼 때는 SAF를 쓰며, 권한 대신 사용자 선택으로 접근합니다.');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 486
(2605, 486, '조건 조회·정렬이 필요한 다건 기사 목록은 Room에 저장함을 제시', 'ESSENTIAL', 1),
(2606, 486, '다크 모드 같은 소량 설정값은 DataStore에 저장함을 제시', 'ESSENTIAL', 2),
(2607, 486, '썸네일 이미지는 DB가 아닌 파일로 저장함을 제시', 'ESSENTIAL', 3),
(2608, 486, '목록을 DataStore에 넣으면 매 변경마다 전체 파일 재쓰기, 이미지를 DB에 넣으면 DB 파일 비대화 중 최소 1개를 오선택 문제로 설명', 'ESSENTIAL', 4),
(2609, 486, 'DB에는 이미지 파일의 경로만 보관함을 언급', 'SUPPLEMENTARY', 5),
(2610, 486, 'cacheDir에 둔 데이터는 시스템이 삭제할 수 있어 없어도 동작해야 함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 487
(2611, 487, 'SharedPreferences의 디스크 쓰기 대기가 메인 스레드를 막아 ANR 원인이 되어 왔음을 언급', 'ESSENTIAL', 1),
(2612, 487, 'DataStore는 코루틴 기반 비동기 I/O라 메인 스레드를 막지 않음을 설명', 'ESSENTIAL', 2),
(2613, 487, 'DataStore의 edit가 원자적 읽기-수정-쓰기를 보장함을 언급', 'ESSENTIAL', 3),
(2614, 487, 'DataStore 읽기가 Flow라서 설정 변경이 UI에 자동 반영됨을 언급', 'SUPPLEMENTARY', 4),
(2615, 487, 'SharedPreferencesMigration으로 기존 데이터를 자동 이전할 수 있음을 언급', 'SUPPLEMENTARY', 5),
(2616, 487, 'apply()는 실패해도 예외가 없지만 DataStore는 실패를 예외로 알려줌을 비교', 'SUPPLEMENTARY', 6),

-- 질문 488
(2617, 488, 'Preferences DataStore는 스키마가 없고 Proto DataStore는 Protocol Buffers로 스키마를 정의함을 구분', 'ESSENTIAL', 1),
(2618, 488, 'Proto DataStore가 Protocol Buffers 스키마 덕분에 타입 안전함을 언급', 'ESSENTIAL', 2),
(2619, 488, '단순 설정에는 Preferences, 구조화된 설정 객체에는 Proto가 적합함을 제시', 'ESSENTIAL', 3),
(2620, 488, 'Proto DataStore는 사용 전 .proto 정의가 필요함을 언급', 'SUPPLEMENTARY', 4),
(2621, 488, 'SharedPreferences에서 옮기기는 Preferences DataStore가 쉬움을 언급', 'SUPPLEMENTARY', 5),
(2622, 488, '같은 파일에 DataStore 인스턴스를 두 개 이상 만들면 예외가 발생함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 489
(2623, 489, 'Entity가 테이블에 대응함을 언급', 'ESSENTIAL', 1),
(2624, 489, 'DAO가 쿼리를 정의하는 인터페이스임을 언급', 'ESSENTIAL', 2),
(2625, 489, 'Database가 DAO를 제공하는 Room의 진입점임을 언급', 'ESSENTIAL', 3),
(2626, 489, 'DAO의 SQL이 컴파일 시점에 검증됨을 언급', 'SUPPLEMENTARY', 4),
(2627, 489, 'DAO가 Flow를 반환하면 테이블 변경 시 자동 재방출됨을 언급', 'SUPPLEMENTARY', 5),
(2628, 489, 'Database를 싱글턴으로 관리함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 490
(2629, 490, '외부 저장소를 자유롭게 읽고 쓸 수 없게 됨을 언급', 'ESSENTIAL', 1),
(2630, 490, '공유 데이터는 MediaStore·SAF 중 최소 1개를 통해 접근함을 제시', 'ESSENTIAL', 2),
(2631, 490, 'filesDir·getExternalFilesDir() 같은 앱 전용 공간은 권한이 불필요함을 언급', 'SUPPLEMENTARY', 3),
(2632, 490, 'MediaStore의 공유 미디어는 앱을 삭제해도 유지됨을 언급', 'SUPPLEMENTARY', 4);
