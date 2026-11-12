-- Unit: 데이터 저장소 선택 (Unit ID: 98)
-- Chapter: AOS (Chapter ID: 8)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (524, 98, 'Room 마이그레이션과 범위 지정 저장소'),
       (682, 98, 'DataStore 원자적 갱신과 싱글턴'),
       (840, 98, 'DataStore 전환과 오프라인 우선');

-- =====================================================
-- Lesson 524: Room 마이그레이션과 범위 지정 저장소
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3323, 524, '아래 코드가 사용하는 저장 방식에 대한 설명으로 옳은 것은?', '```kotlin
val prefs = context.getSharedPreferences("settings", Context.MODE_PRIVATE)

prefs.edit().putBoolean("dark_mode", true).commit()
prefs.edit().putString("token", jwt).apply()

val level = prefs.getInt("level", 0)
```', 'OBJECTIVE'),
       (3324, 524, '아래 표는 한 저장소 라이브러리의 두 구현 A·B를 비교한 것이다. 옳은 설명은?', '| 항목 | A | B |
|---|---|---|
| 스키마 | 없음 (키-값) | Protocol Buffers로 정의 |
| 값 접근 | prefs[booleanPreferencesKey("dark_mode")] | 생성된 클래스의 darkMode 필드 |
| 도입 비용 | 기존 XML 키-값 저장소에서 바로 전환 | .proto 정의와 빌드 설정 필요 |
| 적합한 경우 | 단순 설정, 빠른 전환 | 구조화된 설정 객체 |', 'OBJECTIVE'),
       (3325, 524, '아래 코드에서 쓰인 로컬 데이터베이스 라이브러리의 동작으로 옳은 것은?', '```kotlin
@Entity(tableName = "articles")
data class ArticleEntity(
    @PrimaryKey val id: Long,
    val title: String,
    val savedAt: Long
)

@Dao
interface ArticleDao {
    @Query("SELECT * FROM articles ORDER BY savedAt DESC LIMIT :limit")
    fun recent(limit: Int): Flow<List<ArticleEntity>>

    @Upsert
    suspend fun upsertAll(items: List<ArticleEntity>)
}
```', 'OBJECTIVE'),
       (3326, 524, '아래 저장 위치 비교표에서 이끌어 낼 수 있는 설명으로 옳지 않은 것은?', '| 위치 | API | 권한 | 앱 삭제 시 | 공간 부족 시 시스템 정리 |
|---|---|---|---|---|
| 내부 저장소 | filesDir | 불필요 | 삭제 | 없음 |
| 내부 캐시 | cacheDir | 불필요 | 삭제 | 가능 |
| 외부 앱 전용 | getExternalFilesDir() | 불필요 (API 19+) | 삭제 | 없음 |
| 공유 미디어 | MediaStore | 읽기 시 미디어 권한 | 유지 | 없음 |
| 문서·임의 파일 | Storage Access Framework(SAF) | 사용자 선택으로 대체 | 유지 | 없음 |', 'OBJECTIVE'),
       (3327, 524, '아래 사고를 막으려면 스키마 버전을 올릴 때 무엇을 함께 제공했어야 하는가?', 'Room으로 만든 로컬 데이터베이스에 컬럼 하나를 추가하고 스키마 버전을 1에서 2로 올려 앱을 배포했다. 업데이트를 받은 기기에서 앱을 켜자 기기에 남아 있던 테이블 구조와 맞지 않는다는 예외가 나며 곧바로 종료됐다. 급한 대로 기존 테이블을 통째로 지우고 새로 만드는 옵션을 켜서 다시 배포하자 실행은 됐지만, 사용자가 저장해 둔 글이 모두 사라졌다.', 'SUBJECTIVE'),
       (3328, 524, '아래 변경을 강제한 Android 저장소 정책의 이름은?', 'targetSdkVersion을 29로 올리자, 외부 저장소에서 다른 앱이 만든 폴더를 경로로 직접 열어 파일을 읽던 코드가 저장소 권한을 받았는데도 실패하기 시작했다. 사진은 MediaStore로, 사용자가 고른 문서는 시스템 선택 화면을 거쳐 받도록 고치자 다시 동작했다. 반면 getExternalFilesDir()로 앱 전용 폴더에 쓰던 코드는 아무 수정 없이 그대로 동작했다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3323
(9035, 3323, 'commit()은 변경 사항을 내부 큐에 넣고 즉시 반환하므로 호출 스레드를 막지 않는다.', 'commit()과 apply()의 역할을 뒤바꿔 기억한 오개념이다. commit()은 호출한 스레드에서 XML 파일 쓰기가 끝날 때까지 기다렸다가 성공 여부를 boolean으로 돌려준다. 큐에 넣고 즉시 반환하는 쪽은 apply()다.', false),
(9036, 3323, 'apply()는 디스크 쓰기에 실패하면 호출부에 예외를 던져 실패를 알려 준다.', 'apply()는 메모리에만 즉시 반영하고 실제 쓰기는 백그라운드로 넘기며, 실패해도 예외도 반환값도 없다. 오류를 알 방법이 없다는 점이 SharedPreferences의 약점이고, edit {}가 실패를 예외로 알려 주는 DataStore와 대비된다.', false),
(9037, 3323, 'putBoolean으로 넣은 값을 getString으로 읽는 코드는 타입이 어긋나므로 빌드 단계에서 걸러진다.', '키는 그냥 문자열이고 값은 실행 시점에 캐스팅되므로 컴파일러가 검증할 대상이 없다. 타입이 어긋나면 빌드가 아니라 실행 중 ClassCastException으로 드러난다. 타입 안전이 없다는 것이 이 API의 대표적 한계다.', false),
(9038, 3323, '첫 접근 때 XML 파일 전체를 읽어 들이므로, 메인 스레드에서 처음 호출하면 화면이 잠시 멈출 수 있다.', 'SharedPreferences는 인스턴스를 처음 얻을 때 파일 하나를 통째로 메모리에 올린다. 파일이 크거나 저장소가 느리면 이 로딩이 메인 스레드를 붙잡아 ANR로 이어진다. 조회 한 줄이 항상 가벼운 호출은 아니라는 점이 핵심이다.', true),

-- 문제 3324
(9039, 3324, 'A는 값의 타입이 코드에 고정되지 않아, 키 이름 오타나 타입 불일치가 빌드가 아니라 실행 중에 드러난다.', 'A는 스키마 없이 키 문자열로만 값을 다루므로 컴파일러가 대조할 정의가 없다. 반대로 B는 .proto에서 생성된 클래스의 필드로 접근해 오타·타입 오류가 컴파일 단계에서 잡힌다. 표의 스키마 유무가 오류를 발견하는 시점의 차이로 이어진다.', true),
(9040, 3324, 'B로 바꾸면 목록처럼 큰 데이터도 바뀐 필드만 기록되어 대량 저장에 적합해진다.', '스키마가 있다고 부분 기록이 되는 것은 아니다. 두 구현 모두 값이 하나만 바뀌어도 파일을 통째로 다시 쓰므로 수백 KB를 넘기면 급격히 느려진다. 대량·구조화 데이터는 Room의 몫이고 이 저장소는 소량 설정용이다.', false),
(9041, 3324, '두 구현 모두 쓰기가 호출 스레드에서 동기로 처리되어 메인 스레드에서 부르면 화면이 멈춘다.', 'SharedPreferences의 commit() 동작을 그대로 옮겨 붙인 오개념이다. DataStore는 두 구현 모두 코루틴 기반이라 edit {}가 suspend 함수이고 실제 I/O는 Dispatchers.IO에서 처리되어 메인 스레드를 막지 않는다.', false),
(9042, 3324, 'B는 스키마가 고정돼 있어 값이 바뀌어도 관찰 중인 화면에 자동으로 반영되지 않는다.', '스키마 유무와 관찰 가능성은 별개의 축이다. A와 B 모두 읽기를 Flow로 제공해 값이 바뀌면 구독 중인 화면으로 새 값이 흘러 들어간다. Flow 관찰은 DataStore 공통 특성이지 한쪽 구현만의 기능이 아니다.', false),

-- 문제 3325
(9043, 3325, 'recent()가 돌려준 Flow는 호출 시점의 목록을 한 번 방출한 뒤 끝나므로, 새 글이 저장되면 다시 호출해야 한다.', 'Flow를 일회성 반환값으로 본 오개념이다. DAO가 Flow를 반환하면 쿼리가 참조하는 테이블에 관찰자가 붙어, 그 테이블이 바뀔 때마다 결과를 다시 방출한다. 그래서 새 글이 들어오면 별도 호출 없이 화면이 갱신된다.', false),
(9044, 3325, 'id가 이미 존재하는 행을 upsertAll()에 넘기면 기본 키 제약을 위반해 예외로 중단된다.', '삽입 전용 동작으로 착각한 것이다. upsert는 같은 기본 키가 있으면 갱신하고 없으면 삽입한다. 충돌 시 중단되는 쪽은 충돌 전략이 ABORT인 @Insert이며, 그래서 서버 목록을 다시 받아 덮어쓸 때 upsert가 편하다.', false),
(9045, 3325, '@Query에 적은 SQL은 빌드 단계에서 검증되어, 컬럼 이름을 틀리면 앱을 실행하기 전에 컴파일 오류로 잡힌다.', 'Room은 엔티티 정의로부터 실제 테이블 스키마를 알고 있어 쿼리 문자열의 문법과 컬럼·파라미터 이름을 컴파일 시점에 대조한다. 쿼리를 실행해 봐야 오류를 알 수 있는 SQLiteOpenHelper 직접 사용과 갈리는 지점이다.', true),
(9046, 3325, '@Dao 인터페이스를 구현한 클래스는 개발자가 직접 작성해 @Database에 등록해야 한다.', '보일러플레이트가 그대로 남는다고 본 오개념이다. DAO 구현체는 빌드 시점에 자동 생성되며, 개발자는 인터페이스와 쿼리만 선언하고 @Database의 추상 메서드로 꺼내 쓴다. 커서를 직접 다루던 방식과 크게 달라진 부분이다.', false),

-- 문제 3326
(9047, 3326, '촬영한 사진을 앱을 지운 뒤에도 갤러리에 남기려면 filesDir가 아니라 MediaStore에 써야 한다.', '표에서 filesDir는 앱 삭제 시 함께 지워지고 MediaStore만 유지된다. 앱 생명주기와 무관하게 남아야 하는 사용자 자산은 공유 미디어 저장소로 보내야 한다는 뜻이므로 참인 진술이다.', false),
(9048, 3326, 'cacheDir에 둔 파일은 앱이 직접 지우기 전까지 남으므로, 다시 만들 수 없는 원본을 보관해도 된다.', '표에서 공간 부족 시 시스템 정리 대상은 내부 캐시뿐이다. 언제든 시스템이 지울 수 있으므로 cacheDir에는 사라져도 앱이 정상 동작하는, 다시 만들 수 있는 데이터만 둔다. 원본 보관처로는 filesDir를 쓴다.', true),
(9049, 3326, '사용자가 고른 문서를 읽어 오는 데는 저장소 권한을 따로 요청하지 않고 SAF의 선택 화면을 거치면 된다.', '표에서 SAF의 권한 칸은 사용자 선택으로 대체다. 사용자가 파일을 직접 고르는 행위 자체가 그 파일에 대한 접근 승인이 되므로 별도 권한 요청 없이 읽을 수 있어 참인 진술이다.', false),
(9050, 3326, 'getExternalFilesDir()에 저장한 큰 파일은 권한 없이 쓸 수 있지만, 앱을 삭제하면 함께 사라져 보존이 필요한 데이터에는 맞지 않는다.', '표에서 외부 앱 전용은 권한이 불필요하고 앱 삭제 시 삭제된다. 두 칸을 함께 읽으면 권한 부담은 없지만 영속성은 보장되지 않는다는 결론이 나오므로 참인 진술이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1064, 3327, '마이그레이션,migration,데이터베이스 마이그레이션,DB 마이그레이션,스키마 마이그레이션,명시적 마이그레이션,마이그레이션 코드,Migration 구현', '스키마를 바꿔 version을 올렸다면, 이전 버전의 테이블을 새 버전 구조로 옮기는 Migration을 함께 등록해야 한다. 등록하지 않으면 기기에 남은 스키마와 코드가 선언한 버전이 어긋나 실행 즉시 예외가 난다. 급한 대로 켠 fallbackToDestructiveMigration()은 예외 대신 테이블을 지우고 새로 만드는 우회책이라 사용자 데이터가 통째로 날아간다. 개발 중에는 편하지만 릴리스 빌드에서는 쓰지 않는다. 데이터 자체를 다른 저장소로 옮기는 데이터 이전이나 앱 백업 기능과는 다른, 스키마 버전 사이의 변환 절차라는 점을 구분해 두자.'),
       (1065, 3328, '범위 지정 저장소,범위지정 저장소,스코프드 스토리지,스코프 스토리지,스코프 저장소,Scoped Storage', 'Android 10(API 29)부터 앱은 외부 저장소 전체를 경로로 자유롭게 읽고 쓸 수 없다. 자기 앱 전용 디렉터리 밖의 데이터는 사진·동영상이면 MediaStore로, 사용자가 고른 임의 문서면 Storage Access Framework(SAF)로만 접근한다. 본문에서 getExternalFilesDir() 코드만 멀쩡했던 것이 앱 전용 영역은 이 제한 밖이라는 증거다. 저장소 권한을 없앤 것이 아니라 권한이 있어도 닿을 수 있는 범위를 좁힌 정책이므로, 개별 접근 수단인 MediaStore·SAF나 런타임 권한 모델과는 층위가 다르다.');

-- =====================================================
-- Lesson 682: DataStore 원자적 갱신과 싱글턴
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4271, 682, '아래 저장 설계로 앱을 운영할 때 나타나는 동작으로 옳은 것은?', '뉴스 앱이 사용자가 저장한 기사를 Preferences DataStore의 키 하나(`saved_articles`)에 JSON 배열 문자열로 보관한다.

- 기사마다 id·제목·저장 시각·읽음 여부가 들어 있고, 사용자당 수천 건까지 늘어난다.
- 같은 DataStore에는 다크 모드·알림 설정 키도 함께 들어 있다.
- 화면에는 "안 읽은 기사 최근 10개" 목록과 기사별 읽음 표시 버튼이 있다.', 'OBJECTIVE'),
       (4272, 682, '아래 두 코드를 각각 실행한 뒤 얻은 a와 b에 대한 설명으로 옳은 것은?', '```kotlin
// 두 저장소 모두 count 값이 없는 상태에서 시작한다.
// coroutineScope는 안에서 시작한 코루틴이 모두 끝난 뒤에 반환된다.

// (A) SharedPreferences
coroutineScope {
    repeat(1000) {
        launch(Dispatchers.Default) {
            val cur = prefs.getInt("count", 0)
            prefs.edit().putInt("count", cur + 1).apply()
        }
    }
}
val a = prefs.getInt("count", 0)

// (B) Preferences DataStore, COUNT = intPreferencesKey("count")
coroutineScope {
    repeat(1000) {
        launch(Dispatchers.Default) {
            dataStore.edit { p -> p[COUNT] = (p[COUNT] ?: 0) + 1 }
        }
    }
}
val b = dataStore.data.first()[COUNT]
```', 'OBJECTIVE'),
       (4273, 682, '아래 사진 메모 앱의 두 저장 설계를 비교한 설명으로 옳은 것은?', '사진을 첨부할 수 있는 메모 앱에서 두 가지 저장 설계를 검토했다. 목록 화면에는 메모 제목만 보여 준다.

| 항목 | 설계 A | 설계 B |
|---|---|---|
| 사진 보관 위치 | Room `memos` 테이블의 `photo` 컬럼(ByteArray) | `filesDir` 아래 JPEG 파일 |
| `memos` 행에 남는 사진 정보 | 사진 원본 바이트(장당 수백 KB) | 파일 경로 문자열 |
| 목록 화면 쿼리 | `SELECT * FROM memos` | `SELECT * FROM memos` |', 'OBJECTIVE'),
       (4274, 682, '아래 코드를 실행했을 때 (가)~(다)의 동작에 대한 설명으로 옳은 것은?', '```kotlin
@Dao
interface TodoDao {
    @Insert
    suspend fun insert(todo: TodoEntity)

    @Query("SELECT * FROM todos ORDER BY id DESC")
    fun observeAll(): Flow<List<TodoEntity>>

    @Query("SELECT * FROM todos")
    fun getAll(): List<TodoEntity>
}

// db는 Room.databaseBuilder(...).build()로 만든 AppDatabase이며,
// allowMainThreadQueries()는 호출하지 않았다.
class TodoActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val dao = db.todoDao()

        lifecycleScope.launch { dao.insert(TodoEntity(title = "장보기")) }   // (가)

        lifecycleScope.launch {
            dao.observeAll().collect { adapter.submitList(it) }              // (나)
        }

        val count = dao.getAll().size                                        // (다)
    }
}
```', 'OBJECTIVE'),
       (4275, 682, '아래 크래시를 막기 위해 코드 속 저장소 객체에 적용해야 하는 디자인 패턴의 이름은?', '설정 화면과 홈 화면의 ViewModel이 각자 아래 `SettingsRepository`를 새로 생성해 쓴다. 앱을 켜서 홈 화면이 다크 모드 값을 읽은 뒤 설정 화면으로 이동하자, 설정 화면이 값을 읽는 순간 `IllegalStateException`이 발생하며 앱이 종료됐다. 두 화면이 쓰는 파일은 모두 `settings.preferences_pb` 하나다.

```kotlin
class SettingsRepository(context: Context) {
    private val store: DataStore<Preferences> = PreferenceDataStoreFactory.create {
        context.preferencesDataStoreFile("settings")
    }

    val darkMode: Flow<Boolean> = store.data.map { it[DARK_MODE] ?: false }
}
```', 'SUBJECTIVE'),
       (4276, 682, '아래 빌드 오류를 해결하기 위해 써야 하는 Room 애너테이션의 이름은?', '운동 기록 앱의 엔티티에 운동 시작 시각 필드를 추가하자, Room이 `startedAt` 필드를 DB에 어떻게 저장할지 알 수 없다며 빌드를 멈췄다. 이 값은 DB에 저장해 최근순 정렬에 써야 하므로 필드를 빼거나 저장 대상에서 제외할 수 없고, 코드에서는 타입을 `Instant` 그대로 쓰고 싶다.

```kotlin
@Entity(tableName = "workouts")
data class WorkoutEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val type: String,
    val startedAt: Instant
)
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4271
(11563, 4271, '"안 읽은 기사 최근 10개"를 요청하면 저장소가 JSON을 조건으로 걸러 해당 기사만 디스크에서 읽어 온다.', '키-값 저장소를 DB처럼 본 오개념이다. DataStore는 키로 값을 통째로 꺼낼 뿐 조건 조회를 하지 못한다. 수천 건이 든 문자열을 모두 읽어 파싱한 뒤 앱 코드에서 걸러야 하므로, 조건으로 일부만 꺼내는 목록은 Room에 두는 것이 맞다.', false),
(11564, 4271, 'data Flow는 읽음 여부가 바뀐 기사 한 건만 방출하므로, 화면은 목록 전체를 다시 파싱하지 않아도 된다.', 'Flow가 바뀐 부분만 보낸다고 본 오개념이다. DataStore의 data는 값이 바뀔 때마다 모든 키가 담긴 Preferences 전체를 새로 방출한다. 기사 한 건만 바뀌어도 saved_articles 문자열 전체를 다시 파싱해야 한다.', false),
(11565, 4271, '기사 하나의 읽음 여부만 바꿔도 수천 건이 든 문자열을 다시 직렬화해 파일 전체를 새로 쓴다.', 'DataStore는 edit { } 한 번마다 모든 키를 직렬화해 파일을 통째로 다시 쓴다. 바뀐 것은 기사 한 건이어도 수천 건의 JSON이 매번 기록되므로 목록이 커질수록 쓰기가 느려진다. 소량 설정용 저장소에 목록을 넣으면 생기는 대표적인 문제다.', true),
(11566, 4271, '키마다 파일이 따로 있어서, saved_articles를 고쳐도 다크 모드·알림 설정이 든 파일은 다시 쓰지 않는다.', '키별로 파일이 나뉜다고 본 오개념이다. Preferences DataStore는 이름 하나당 .preferences_pb 파일 하나에 모든 키를 담는다. 기사 목록을 고칠 때마다 같은 파일에 든 다크 모드·알림 설정도 함께 다시 기록된다.', false),

-- 문제 4272
(11567, 4272, 'a와 b 모두 항상 1,000이다.', 'getInt·putInt가 각각 스레드 안전하니 둘을 이어 쓴 것도 안전하다고 본 오개념이다. (A)는 값을 읽고 1을 더해 쓰는 사이에 다른 코루틴이 끼어들 수 있어, 두 코루틴이 같은 값을 읽고 같은 값을 쓰면 증가 한 번이 사라진다.', false),
(11568, 4272, 'a와 b 모두 1,000보다 작게 나올 수 있다.', 'edit { }를 단순한 쓰기로 본 오개념이다. DataStore는 edit 요청을 한 번에 하나씩 처리하고, 블록에 넘기는 p는 앞선 edit까지 반영된 최신 값이다. 읽기-수정-쓰기가 원자적으로 묶여 있어 증가가 유실되지 않는다.', false),
(11569, 4272, 'a는 항상 1,000이지만, b는 코루틴이 동시에 돌아 1,000보다 작게 나올 수 있다.', '두 저장소의 보장을 뒤바꿔 기억한 오개념이다. apply()는 디스크 쓰기를 비동기로 넘길 뿐 읽기와 쓰기를 하나로 묶어 주지 않는다. 동시에 들어온 요청을 줄 세워 최신 값 위에서 하나씩 적용하는 쪽은 DataStore의 edit { }다.', false),
(11570, 4272, 'a는 1,000보다 작게 나올 수 있고, b는 항상 1,000이다.', '(A)는 getInt와 putInt 사이가 보호되지 않아, 두 코루틴이 같은 값을 읽고 덮어쓰면 증가가 사라진다. (B)의 edit { }는 최신 값을 받아 고치고 기록하는 과정 전체를 원자적으로 처리하므로 1,000번의 증가가 모두 반영된다.', true),

-- 문제 4273
(11571, 4273, 'B에서 메모 행을 DELETE하면, 경로 컬럼이 가리키는 사진 파일도 SQLite가 함께 지운다.', 'DB가 경로 너머의 파일까지 관리한다고 본 오개념이다. SQLite에게 경로는 문자열일 뿐이라 행을 지워도 파일은 filesDir에 그대로 남는다. 메모를 지울 때 파일도 앱 코드에서 따로 지워야 쓸모없는 파일이 쌓이지 않는다.', false),
(11572, 4273, 'A는 제목만 띄우는 목록에서도 사진 바이트까지 읽어, 메모가 쌓일수록 조회가 느려진다.', 'SELECT *는 photo 컬럼까지 가져오므로, 제목만 필요한 목록도 행마다 수백 KB짜리 바이트를 메모리에 올린다. 메모가 늘수록 읽는 양과 DB 파일 크기가 함께 불어나 조회가 느려진다. 그래서 사진은 파일로 두고 DB에는 경로만 남기는 B 방식을 쓴다.', true),
(11573, 4273, 'B는 사진을 파일로 쓰므로, 저장소 쓰기 권한을 받기 전에는 filesDir에 사진을 저장할 수 없다.', '파일을 쓰려면 늘 저장소 권한이 필요하다고 본 오개념이다. filesDir는 앱 전용 내부 저장소라 권한 요청 없이 읽고 쓸 수 있다. 권한이 필요한 경우는 다른 앱이 만든 공유 미디어를 읽을 때처럼 앱 밖의 데이터에 접근할 때다.', false),
(11574, 4273, 'B는 DB에 경로만 두므로, 갤러리 같은 다른 앱도 그 경로로 사진 파일을 열어 볼 수 있다.', '경로만 알면 어느 앱이든 파일을 열 수 있다고 본 오개념이다. filesDir는 앱 전용 공간이라 다른 앱은 경로를 알아도 접근하지 못한다. 갤러리에 보여야 하는 사진이라면 MediaStore를 통해 공유 미디어로 저장해야 한다.', false),

-- 문제 4274
(11575, 4274, '(다)의 getAll()이 메인 스레드에서 호출돼, Room이 IllegalStateException을 던지고 앱이 종료된다.', 'onCreate는 메인 스레드에서 실행되고, suspend도 Flow도 아닌 DAO 함수는 호출한 스레드에서 바로 쿼리를 실행한다. Room은 화면 멈춤을 막으려고 기본 설정에서 메인 스레드의 DB 접근을 예외로 막는다. allowMainThreadQueries()는 이 검사를 끄는 옵션이라 실서비스에는 쓰지 않는다.', true),
(11576, 4274, '(가)는 lifecycleScope가 메인 스레드에서 코루틴을 시작하므로, insert의 디스크 쓰기도 메인 스레드에서 돌아 예외가 난다.', '코루틴을 시작한 스레드에서 DAO 작업도 돈다고 본 오개념이다. Room은 suspend DAO 함수의 쿼리를 자체 백그라운드 실행기로 옮겨 처리하고 끝나면 결과를 돌려준다. 그래서 메인 스레드의 코루틴에서 불러도 화면을 막지 않고 예외도 나지 않는다.', false),
(11577, 4274, '(나)의 collect가 메인 스레드에서 돌므로, 목록 쿼리도 메인 스레드에서 실행돼 할 일이 많으면 화면이 멈춘다.', '값을 받는 스레드와 쿼리를 실행하는 스레드를 같은 것으로 본 오개념이다. Flow를 반환하는 DAO는 쿼리를 Room의 백그라운드 실행기에서 돌리고 결과만 수집하는 쪽으로 넘긴다. 메인 스레드에서 collect해도 쿼리가 화면을 막지 않는다.', false),
(11578, 4274, '(다)는 (가)의 삽입이 끝나기를 기다렸다가 실행되므로, count에는 방금 넣은 할 일이 항상 포함된다.', 'launch가 코루틴이 끝날 때까지 기다린다고 본 오개념이다. launch는 코루틴을 시작만 하고 곧바로 다음 줄로 넘어가므로 (가)의 삽입 완료가 보장되지 않는다. 게다가 (다)는 메인 스레드에서 동기로 DB에 접근해 값을 받기 전에 예외로 중단된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1380, 4275, '싱글턴,싱글톤,싱글턴 패턴,싱글톤 패턴,singleton,singleton pattern', 'DataStore는 파일 하나에 대해 동시에 살아 있는 인스턴스가 하나여야 한다. 인스턴스마다 파일 내용을 따로 캐시하고 쓰기를 따로 줄 세우면 원자적인 읽기-수정-쓰기가 깨지므로, 같은 파일에 두 번째 인스턴스가 붙어 읽거나 쓰는 순간 IllegalStateException을 던진다. 본문처럼 저장소 클래스를 화면마다 새로 만들면 생성자 안의 DataStore도 매번 새로 생긴다. DataStore를 최상위 확장 프로퍼티(by preferencesDataStore)로 선언하거나 DI 컨테이너에서 싱글턴 범위로 제공해 앱 전체에서 하나만 쓰게 해야 한다. 코드에 쓰인 PreferenceDataStoreFactory는 객체를 만드는 방법을 감싼 팩토리일 뿐 인스턴스 개수를 제한하지 않고, 의존성 주입(DI)도 싱글턴을 공급하는 수단일 뿐 그 자체로 개수를 하나로 묶지는 않는다는 점을 구분하자.'),
       (1381, 4276, 'TypeConverter,@TypeConverter,TypeConverters,@TypeConverters,타입 컨버터,타입컨버터,타입 변환기', 'Room은 SQLite 컬럼에 바로 담을 수 있는 타입(정수·실수·문자열·바이트 배열 등)만 매핑할 줄 알아서, Instant 같은 객체는 어떤 컬럼 값으로 바꿔 저장할지 스스로 정하지 못한다. Instant를 Long(에포크 밀리초)으로, Long을 다시 Instant로 바꾸는 함수 한 쌍에 @TypeConverter를 붙이고, 그 함수가 든 클래스를 @Database 등에 @TypeConverters(Converters::class)로 등록하면 저장하고 읽을 때마다 자동으로 변환된다. 컬럼에는 Long이 들어가므로 ORDER BY로 최근순 정렬도 그대로 된다. @Ignore는 빌드 오류는 없애지만 값을 아예 저장하지 않고, @Embedded는 필드가 여러 개인 객체를 컬럼 여러 개로 펼칠 때 쓰는 것이라 값 하나의 타입을 바꾸는 이 상황과는 쓰임이 다르다.');

-- =====================================================
-- Lesson 840: DataStore 전환과 오프라인 우선
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5219, 840, '아래 설정 읽기 코드의 동작으로 옳은 것은?', '```kotlin
private val Context.settingsStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

class SettingsRepository(private val context: Context) {
    private val darkModeKey = booleanPreferencesKey("dark_mode")

    val darkMode: Flow<Boolean> = context.settingsStore.data
        .catch { e -> if (e is IOException) emit(emptyPreferences()) else throw e }
        .map { prefs -> prefs[darkModeKey] ?: false }
}

// 화면은 darkMode를 collect해 테마를 적용하고,
// 설정 화면에서 값을 바꾸면 settingsStore.edit { }로 기록한다.
```', 'OBJECTIVE'),
       (5220, 840, '아래 데이터들을 어디에 저장할지 정한 설명으로 옳지 않은 것은?', '메신저 앱이 기기에 남겨야 하는 데이터를 정리한 표다.

| 데이터 | 특징 |
|---|---|
| 다크 모드 켜짐 여부 | 값 하나. 앱을 켤 때 읽고 설정 화면에서만 바뀐다 |
| 주고받은 채팅 메시지 | 건당 보낸이·본문·보낸 시각. 한 방에 5만 건까지 쌓이고, 화면에는 그 방의 최근 30건만 띄운다 |
| 로그인 토큰 | 짧은 문자열 하나. 기기에서 새어 나가면 남이 그대로 계정에 들어올 수 있다 |
| 내려받은 이모티콘 이미지 | 장당 40KB 안팎. 서버에서 언제든 다시 받을 수 있고, 없으면 다시 받아 그리면 된다 |', 'OBJECTIVE'),
       (5221, 840, '아래처럼 저장소를 바꿔 배포했을 때 기존 사용자 기기에서 일어나는 일로 옳은 것은?', '```kotlin
// 이전 버전은 getSharedPreferences("settings", MODE_PRIVATE)에
// dark_mode(Boolean)와 font_scale(Float)을 저장해 왔다.

private val Context.settingsStore: DataStore<Preferences> by preferencesDataStore(
    name = "settings",
    produceMigrations = { ctx -> listOf(SharedPreferencesMigration(ctx, "settings")) }
)

class SettingsRepository(private val context: Context) {
    val darkMode: Flow<Boolean> = context.settingsStore.data
        .map { prefs -> prefs[booleanPreferencesKey("dark_mode")] ?: false }
}
```', 'OBJECTIVE'),
       (5222, 840, '아래 조회 코드가 실제로 데이터를 가져오는 방식으로 옳은 것은?', '```kotlin
@Entity(tableName = "users")
data class UserEntity(@PrimaryKey val id: Long, val name: String)

@Entity(tableName = "posts")
data class PostEntity(@PrimaryKey val id: Long, val userId: Long, val title: String)

data class UserWithPosts(
    @Embedded val user: UserEntity,
    @Relation(parentColumn = "id", entityColumn = "userId")
    val posts: List<PostEntity>
)

@Dao
interface UserDao {
    @Transaction
    @Query("SELECT * FROM users WHERE id = :id")
    suspend fun load(id: Long): UserWithPosts
}
```', 'OBJECTIVE'),
       (5223, 840, '아래 증상을 가리키는 Android 용어(약어)는?', '앱을 켜면 첫 화면이 5초 넘게 멈춘다는 제보가 저가형 기기에서만 들어왔다. 확인해 보니 홈 화면에 들어가기 직전에 설정 키 40여 개를 SharedPreferences의 commit()으로 연달아 기록하고 있었고, 그동안 메인 스레드가 디스크 쓰기가 끝나기를 기다리느라 터치도 화면 전환도 처리하지 못했다. 제보 기기의 로그에는 입력 이벤트 전달이 제한 시간을 넘겼다는 기록과 함께, 시스템이 사용자에게 앱을 닫을지 기다릴지 묻는 대화상자를 띄운 흔적이 남아 있었다. 기록을 DataStore로 옮겨 코루틴에서 처리하자 증상이 사라졌다.', 'SUBJECTIVE'),
       (5224, 840, '아래 앱이 데이터를 다루는 방식을 가리키는 전략의 이름은?', '지하철 터널에서 네트워크가 끊겨도 뉴스 앱의 기사 목록과 본문이 그대로 뜬다. 비행기 모드로 앱을 새로 켜도 마지막으로 받아 둔 목록이 그대로 보이고, 읽음 표시를 누르면 화면에 곧바로 반영된다. 연결이 돌아오면 그동안 누른 읽음 표시가 서버로 올라가고, 새로 내려받은 기사가 목록 맨 위에 조용히 채워진다. 이 앱의 화면은 Room 테이블 하나만 구독하며, 네트워크 응답은 그 테이블을 거쳐야만 화면에 닿는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5219
(14091, 5219, 'catch 블록이 모든 예외를 받아 내므로, 어떤 오류가 나든 화면은 기본값인 밝은 테마로 그려지고 앱이 종료되지 않는다.', 'catch가 있으면 그 아래가 전부 안전해진다고 본 오개념이다. 이 코드는 IOException일 때만 값을 대신 내보내고 나머지는 else throw e로 다시 던진다. 예를 들어 저장된 타입과 다르게 읽어 나는 ClassCastException은 그대로 구독하는 쪽으로 올라간다.', false),
(14092, 5219, '읽기에 실패해도 catch가 예외를 대신 처리해 주므로, 그 뒤 사용자가 설정 화면에서 바꾼 값도 이 Flow로 이어서 흘러온다.', 'catch를 예외를 삼키고 원래 흐름을 이어 주는 장치로 본 오개념이다. catch는 위에서 올라온 예외를 값 하나로 바꿔 내보낼 뿐 끊어진 원본 Flow를 되살리지 못한다. emit 뒤 이 Flow는 종료되므로 다시 구독하기 전에는 변경이 오지 않는다.', false),
(14093, 5219, '저장 파일을 읽다 IOException이 나면 빈 Preferences가 흘러가 map이 false를 내보내므로, 앱은 죽지 않고 밝은 테마로 그려진다.', 'DataStore는 파일 읽기 실패를 data Flow의 예외로 알린다. 이 코드는 그중 IOException만 골라 emptyPreferences()를 대신 내보내고, 키가 없으니 map의 엘비스 연산자가 기본값 false를 채운다. 실패해도 화면은 기본 설정으로 뜬다.', true),
(14094, 5219, '키가 아직 저장되지 않은 첫 실행에서는 prefs[darkModeKey]가 null이라 map에서 예외가 나므로, 기본값은 catch가 대신 채워 준다.', '값이 없는 키 접근을 예외 상황으로 본 오개념이다. Preferences의 인덱스 접근은 값이 없으면 null을 돌려줄 뿐이고, 첫 실행의 기본값은 catch가 아니라 map 안의 ?: false가 정한다. catch가 맡는 것은 파일 자체를 읽지 못한 경우다.', false),

-- 문제 5220
(14095, 5220, '다크 모드 값은 Room 테이블에 행 하나로 두면 트랜잭션과 조건 조회까지 함께 얻으므로, 키-값 저장소에 두는 것보다 낫다.', '저장소는 기능이 많은 쪽이 아니라 읽는 방식에 맞는 쪽으로 고른다. 이 값은 키 하나로 통째로 읽고 걸러 낼 조건이 없어 쿼리·조인은 쓸 일이 없는데, 엔티티·DAO·스키마 버전 관리 부담만 남는다. 설정 값 하나에 관계형 DB는 과하다.', true),
(14096, 5220, '채팅 메시지는 방과 시각으로 걸러 30건만 꺼내야 하므로, 행으로 쌓아 두고 정렬·조건이 붙은 쿼리로 읽는 Room에 둔다.', '한 방에 5만 건이 쌓이는데 화면이 쓰는 것은 최근 30건뿐이다. 조건과 정렬로 일부만 읽어야 하므로, 키로 값을 통째로 꺼내 앱 코드에서 걸러야 하는 저장소로는 감당하기 어렵다. 조회 방식이 Room을 가리키므로 참인 진술이다.', false),
(14097, 5220, '로그인 토큰은 짧은 문자열이라도 평문 키-값 파일에 그대로 두지 않고, 기기의 키 저장소로 암호화해 보관한다.', '표에서 이 값은 새어 나가면 계정이 그대로 넘어간다. 루팅된 기기나 백업 경로로 앱 전용 파일이 통째로 빠져나갈 수 있어, 크기가 작다는 점은 평문 저장의 근거가 되지 못한다. 민감도가 저장 방식을 정하므로 참인 진술이다.', false),
(14098, 5220, '이모티콘 이미지는 다시 내려받을 수 있으므로 cacheDir에 두고, 시스템이 지워도 다시 받아 그리도록 만든다.', '표에서 이 이미지는 사라져도 서버에서 다시 받으면 그만이다. cacheDir는 저장 공간이 부족할 때 시스템이 비울 수 있는 자리라, 없어도 앱이 정상 동작하는 데이터를 두기에 알맞으므로 참인 진술이다.', false),

-- 문제 5221
(14099, 5221, '앱을 업데이트하면 이전 XML 파일이 먼저 지워지므로, 사용자는 다크 모드와 글자 크기를 처음부터 다시 설정해야 한다.', '저장소를 바꾸면 기존 값이 날아간다고 본 오개념이다. produceMigrations에 넘긴 절차가 XML의 키-값을 새 저장소로 옮긴 다음에야 첫 값이 방출되므로, 사용자가 보기에 설정은 그대로 유지된다.', false),
(14100, 5221, '두 저장소가 계속 이어져 있어, 이후 XML 쪽에 값을 써도 같은 이름을 쓰는 DataStore의 읽기에 그대로 반영된다.', '이름이 같으니 한 저장소를 두 API로 보는 것이라고 본 오개념이다. 둘은 settings.xml과 settings.preferences_pb라는 서로 다른 파일이고 옮기는 절차도 한 번만 돈다. 옮긴 뒤 XML에 쓴 값은 DataStore가 읽지 않는다.', false),
(14101, 5221, '앱을 켤 때마다 XML을 다시 읽어 덮어쓰므로, DataStore로 바꾼 값이 다음 실행에서 이전 값으로 되돌아간다.', '옮기는 절차가 실행 때마다 되풀이된다고 본 오개념이다. 기본 설정에서는 키를 모두 옮긴 뒤 원본 XML을 정리하므로, 다음 실행에는 옮길 것이 남지 않아 건너뛴다. 이전 값이 새 값을 덮는 일은 생기지 않는다.', false),
(14102, 5221, 'settingsStore를 처음 읽는 시점에 XML에 있던 dark_mode와 font_scale이 한 번 옮겨지고, 그 뒤로는 DataStore의 값이 쓰인다.', '이 절차는 앱 설치나 시작 시점이 아니라 해당 파일을 처음 읽거나 쓸 때 실행되고, 옮기기가 끝난 뒤에 첫 값이 방출된다. 그래서 화면은 언제나 옮겨진 값을 본다. 기존 사용자의 설정을 지키면서 저장소만 갈아 끼우는 방법이다.', true),

-- 문제 5222
(14103, 5222, 'posts 목록은 users 테이블의 컬럼 하나에 직렬화돼 들어가므로, 글이 늘어날수록 users의 행 하나가 계속 커진다.', '@Relation을 컬럼 매핑으로 본 오개념이다. users 테이블에는 엔티티에 선언한 id·name 컬럼만 있고 글은 posts 테이블의 행으로 따로 쌓인다. @Relation은 저장 구조가 아니라 읽어 온 두 결과를 묶는 방법을 알려 주는 표시다.', false),
(14104, 5222, 'users에서 한 행을 읽고 posts에서 userId가 그 id인 행들을 따로 읽은 뒤, 두 결과를 메모리에서 하나의 객체로 묶어 돌려준다.', 'Room은 @Relation을 조인 한 번으로 바꾸지 않고 부모 쿼리와 자식 쿼리를 나눠 실행한 뒤 키를 맞춰 묶는다. 쿼리가 둘로 나뉘니 사이에 테이블이 바뀌면 앞뒤가 어긋날 수 있어, @Transaction으로 두 조회를 함께 묶어 읽는다.', true),
(14105, 5222, '@Query의 SELECT 문이 users만 가리키므로, 반환된 UserWithPosts의 posts는 언제나 빈 리스트로 채워진다.', '쿼리 문자열에 적힌 테이블만 결과에 담긴다고 본 오개념이다. @Relation이 붙은 필드는 Room이 부모 결과의 키 값을 받아 자식 테이블에 별도 쿼리를 날려 채우므로, SELECT 문에 posts가 없어도 글 목록이 들어온다.', false),
(14106, 5222, '@Embedded는 user를 별도 테이블로 떼어 내라는 뜻이라, UserWithPosts에 해당하는 테이블이 하나 더 만들어진다.', '@Embedded를 테이블을 만드는 표시로 본 오개념이다. 테이블은 @Entity가 붙은 클래스에서만 만들어지고, @Embedded는 조회 결과의 여러 컬럼을 하나의 객체 필드로 접어 담을 때 쓴다. UserWithPosts는 결과를 담는 그릇일 뿐이다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1696, 5223, 'ANR,에이엔알,Application Not Responding,애플리케이션 응답 없음,앱 응답 없음,응답 없음', '메인 스레드가 정해진 시간(입력 이벤트는 약 5초) 안에 일을 넘기지 못하면 시스템이 ANR로 판정해 앱을 닫을지 기다릴지 묻는 대화상자를 띄운다. 본문의 로그에 남은 입력 이벤트 전달 시간 초과가 바로 그 판정 근거다. SharedPreferences의 commit()은 호출한 스레드에서 XML 파일 쓰기가 끝날 때까지 기다리므로, 시작 경로에서 40여 번을 부르면 메인 스레드가 그만큼 붙잡힌다. 반면 DataStore는 모든 I/O를 Dispatchers.IO에서 처리하고 쓰기가 suspend 함수라 메인 스레드를 막지 않는다. 예외 때문에 프로세스가 곧바로 죽는 크래시와 달리 ANR은 앱이 살아 있는데도 반응만 못 하는 상태이고, 몇 프레임이 밀려 화면이 버벅이는 현상과도 구분해서 본다.'),
       (1697, 5224, '오프라인 우선,오프라인 우선 전략,오프라인 퍼스트,오프라인 퍼스트 전략,오프라인 우선 아키텍처,Offline-first,offline first,로컬 우선', '네트워크가 아니라 기기에 있는 로컬 DB를 화면이 읽는 유일한 자리로 두고, 서버에서 받아 온 데이터는 그 DB를 채우는 용도로만 쓰는 전략이 오프라인 우선이다. 연결이 없어도 마지막 사본으로 화면이 채워지고, 쓰기도 로컬에 먼저 반영한 뒤 연결이 돌아왔을 때 서버로 올려 보낸다. Room이 Flow를 돌려주면 테이블이 바뀔 때마다 화면이 자동으로 갱신되므로 네트워크 응답을 화면에 직접 꽂을 필요가 없다. 네트워크를 먼저 시도하고 실패했을 때만 꺼내 쓰는 단순 캐시와는 읽는 순서가 반대라는 점에서 다르고, 화면이 바라보는 출처를 하나로 못 박는 단일 진실 공급원은 이 전략을 떠받치는 원칙, 밀린 쓰기를 나중에 올려 주는 WorkManager 같은 도구는 이 전략을 구현하는 수단이라는 점에서 층위가 다르다.');
