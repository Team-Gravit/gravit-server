# [PLAN-534] 탈퇴 회원 면접 데이터 미삭제 수정

> 이슈: #534
> 브랜치: fix/534-withdrawn-user-interview-data (base: dev, 착수 시 `d21b3528`로 fast-forward)
>
> **복구한 회원도 탈퇴 7일 뒤 실제 삭제된다. 이번 이슈에서 함께 막는다 (D3).** 탈퇴 확인(`UserDeletionService.confirmDeleteByMailAuthCode`)이 Redis ZSet `user:clean:due`에 삭제 예약을 넣는데, 복구(`UserService.restoreUser`, 어드민 `AdminUserService.updateStatus`)는 이 예약을 지우지 않는다. 예약을 지우는 곳은 `UserCleanScheduler:39` 하나뿐이고, 실제 삭제 SQL은 `DELETE FROM users WHERE id = :id`로 탈퇴 상태를 확인하지 않는다. 그래서 탈퇴 후 복구한 회원도 예약 시각이 되면 계정과 기록이 전부 지워진다. `user.md:15`의 "복구를 선택하면 그때 되살린다"와 코드가 어긋난다.

## 목표

탈퇴 7일 뒤 실제 삭제가 면접 기록(세션, 세션 주제, 답안, 채점 결과)과 S3 음성 원본까지 지우게 해, 개인정보 처리방침에 공개한 파기 범위와 실제 삭제 범위를 맞춘다. 복구한 회원은 실제 삭제에서 뺀다.

API 계약과 DB 스키마는 바뀌지 않는다. 바뀌는 것은 매시간 도는 실제 삭제 배치다.

## 배치 기준

- **면접 테이블 4개는 기존 CTE 한 문장에 넣는다.** 면접 테이블에는 FK가 없어(V41) 순서 제약이 없다. PostgreSQL의 데이터 변경 CTE는 한 스냅샷을 공유하므로 `interview_feedback`의 하위 쿼리가 같은 문장에서 지워지는 `interview_answer`, `interview_session` 행을 그대로 본다. 기존 `d_inquiry_answer`가 이미 기대는 성질이다. 네 테이블 모두 조건 컬럼이 인덱스 선두다(`ix_interview_session_user_started`, `uq_interview_answer_session_order`, `uq_interview_session_topic_session_topic`, `uq_interview_feedback_answer`)
- **이 SQL의 누락은 면접 테이블 4개뿐이다.** 마이그레이션에서 사용자 컬럼을 가진 테이블을 모두 대조했다. V9에서 지운 뱃지 계열, V31에서 사용자 컬럼 없이 다시 만든 `mission`, 정책상 남기는 `user_daily_activity`(`user.md:19`)를 빼면 나머지는 이미 대상이다
- **음성은 세션 접두사 `interview/{세션 id}/` 단위로 목록 조회한 뒤 지운다.** `interview_answer.audio_key`는 제출된 키만 가진다. 발급만 받고 제출하지 않은 녹음, 같은 문항을 다른 포맷으로 올려 생긴 다른 키(`1.m4a`와 `1.webm`)는 DB에 없다. 한 세션 접두사 아래 키는 최대 15개(문항 5 × 확장자 m4a, webm, mp3)라 `ListObjectsV2` 한 번(최대 1000개)으로 끝나고 페이지 처리가 필요 없다. 접두사 끝의 `/`를 빼면 `interview/1`이 `interview/12/...`까지 잡는다
- **음성 세션만 조회한다.** 업로드 URL은 음성 세션에만 발급되고(`InterviewAudioUploadService:38`) 입력 방식은 세션 안에서 바뀌지 않는다(`interview.md` 입력 방식). 텍스트 세션에는 객체가 생길 수 없다. 상태는 거르지 않는다. 진행 중, 취소 세션의 제출하지 않은 녹음도 대상이다
- **`DeleteObjects`의 부분 실패를 검사한다.** 이 API는 일부 키 삭제가 실패해도 200을 돌려주고 실패를 응답의 `errors()`에 담는다. 검사하지 않으면 일부 키에만 권한이 없을 때 성공처럼 지나가 재시도 큐에도 들어가지 않는다. `hasErrors()`가 아니라 `errors().isEmpty()`로 본다. SDK의 `hasXxx()`는 목록이 비었는지가 아니라 응답에 필드가 있었는지를 알려준다
- **SDK 예외는 감싸지 않는다.** `S3Exception`(권한 거부 403 등)과 `SdkClientException`(네트워크)은 메시지에 상태 코드와 원인이 있다. 부분 실패만 새 에러코드 `INTERVIEW_AUDIO_DELETE_FAILED`로 던진다(선례 `InterviewGradingClient`의 `INTERVIEW_5001`)
- **DB를 먼저 지우고 음성은 그 뒤에 지운다. 실패한 세션은 재시도 큐로 넘긴다 (D1).** DB 파기가 S3 상태에 묶이지 않게 하기 위해서다. 세션 id는 DB에만 있으므로 DB 삭제 전에 음성 세션 id를 먼저 모아 둔다. 음성 삭제는 세션 단위로 시도하고, 실패한 세션 id를 `interview-audio-deletion-retry`에 적재한 뒤 다음 세션으로 넘어간다. 재처리는 기존 `RetryQueueSweeper`가 맡는다(30초 주기, 5초에서 5분까지 지수 백오프, 한도 초과 시 `:dead-letter` 리스트). DB 삭제가 실패하면 음성은 건드리지 않은 채 예외가 스케줄러로 올라가 예약 키가 남으므로, 다음 정각에 전체를 다시 시도한다
- **DB 삭제가 끝난 뒤에는 예외를 밖으로 던지지 않는다.** 적재(`RedisRetryEventPublisher.publish`)도 Redis 오류면 `RuntimeException`을 던지므로 이것까지 받아 로그만 남기고 다음 세션으로 넘어간다. DB가 이미 지워진 뒤 예외가 스케줄러에 닿으면 예약 키가 남지만, 다음 정각에는 회원 행이 없어 탈퇴 상태 확인(D3)에서 건너뛰므로 다시 시도되지 않는다. 던져도 얻는 것이 없고 남은 세션만 처리되지 않는다
- **적재는 리스너가 아니라 서비스에서 한다.** 기존 적재 지점은 모두 `AFTER_COMMIT` 리스너다. 여기서는 Facade가 DB 삭제 서비스(자기 트랜잭션에서 커밋)를 부른 뒤 음성 삭제를 순서대로 부르므로 커밋 뒤 실행이 이미 보장된다. 이벤트로 바꾸려면 Facade에 발행용 `TransactionTemplate` 경계를 새로 만들어야 하는데, 결과는 순서 호출과 같다. 큐에 적재하는 서비스와 재처리 대상은 둘 다 interview 도메인에 둔다
- **음성 삭제는 DB 트랜잭션 밖에서 한다.** S3 삭제는 롤백되지 않고, 트랜잭션 안에 두면 네트워크 대기 동안 DB 커넥션을 붙잡는다. 음성 세션 id 조회만 `readOnly` 트랜잭션이고 삭제 메서드에는 트랜잭션이 없다
- **user와 interview를 묶는 `UserDeletionFacade`를 새로 만든다.** 탈퇴 상태 확인과 DB 삭제(user)에 음성 세션 조회와 음성 삭제(interview)를 조합한다. 서비스가 다른 도메인 서비스를 부르지 않는다(`service.md`). 배치가 Facade를 부르는 선례는 `NotificationScheduler → NotificationBatchFacade`다. 기존 `UserFacade`는 메인, 마이페이지 조회 조합이라 넣지 않는다. Facade에는 트랜잭션 경계를 두지 않는다. 음성 삭제와 DB 삭제는 한 트랜잭션으로 묶을 수 없고 각 서비스가 자기 경계를 가진다
- **복구 회원은 실제 삭제 직전에 걸러낸다 (D3).** 복구 시점에 예약 키를 지우는 방식은 택하지 않는다. Redis 쓰기는 복구 트랜잭션과 따로 커밋돼, 복구가 롤백되면 탈퇴 상태인데 예약만 사라져 영영 삭제되지 않는다. 어드민 복구 경로(`AdminUserService`)까지 고쳐야 하는 문제도 있다. 삭제 직전 확인은 두 복구 경로를 모두 덮고, 걸러낸 회원의 예약 키는 스케줄러가 기존 흐름대로 지운다. 확인 쿼리는 네이티브다. `User`의 `@SQLRestriction("deleted_at IS NULL")`이 JPQL에서 탈퇴 회원을 숨긴다(선례 `UserRepository.findByProviderId`)
- **S3 설정 키는 늘리지 않는다.** `S3Client`는 `S3Presigner`와 같은 `aws.s3.region`, `access-key`, `secret-key`를 쓴다. dev, prod, test yml을 바꾸지 않는다

## 영향 범위

### 신규 파일

**main**
- `src/main/java/gravit/code/interview/service/InterviewAudioDeletionService.java` - 음성 세션 id 조회, 세션 접두사별 음성 삭제, 실패 시 재시도 큐 적재
- `src/main/java/gravit/code/interview/infrastructure/InterviewAudioDeletionRetryTarget.java` - `interview-audio-deletion-retry` 재처리
- `src/main/java/gravit/code/user/facade/UserDeletionFacade.java` - 탈퇴 상태 확인 → 음성 세션 id 수집 → DB 실제 삭제 → 음성 삭제

**test**
- `src/test/java/gravit/code/interview/service/InterviewAudioDeletionServiceIntegrationTest.java`
- `src/test/java/gravit/code/interview/infrastructure/InterviewAudioDeletionRetryTargetIntegrationTest.java`
- `src/test/java/gravit/code/user/facade/UserDeletionFacadeIntegrationTest.java`
- `src/test/java/gravit/code/user/batch/UserCleanSchedulerIntegrationTest.java`

### 수정 파일

**main**
- `src/main/java/gravit/code/user/repository/sql/UserCleanDeletionSql.java` - 면접 CTE 4개 추가, Javadoc 삭제 대상 목록에 면접 한 줄 추가
- `src/main/java/gravit/code/user/repository/UserRepository.java` - `existsWithdrawnById` 네이티브 쿼리 추가 (D3)
- `src/main/java/gravit/code/user/service/UserDeletionService.java` - `isWithdrawn` 추가 (D3)
- `src/main/java/gravit/code/user/batch/UserCleanScheduler.java` - 서비스 대신 Facade 호출, 건너뛴 회원 수 집계
- `src/main/java/gravit/code/interview/repository/InterviewSessionRepository.java` - `findIdsByUserIdAndInputType` 추가
- `src/main/java/gravit/code/global/config/S3Config.java` - `S3Client` 빈 추가, 자격 증명 생성 추출 (D2, #523 석환 작성)
- `src/main/java/gravit/code/interview/policy/InterviewAudioKeyPolicy.java` - `sessionPrefix` 추가 (D2, #523 석환 작성)
- `src/main/java/gravit/code/interview/infrastructure/InterviewAudioStorage.java` - `S3Client` 주입, `deleteAllByPrefix` 추가 (D2, #523 석환 작성)
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `INTERVIEW_AUDIO_DELETE_FAILED` 추가

**test**
- `src/test/java/gravit/code/user/service/UserDeletionServiceIntegrationTest.java` - 면접 데이터 삭제, 탈퇴 상태 확인 시나리오 추가

**정책**
- `.claude/spec/service-policy/user.md` - 실제 삭제 범위에 면접 기록과 음성 원본, 음성 삭제 실패 시 동작, 복구 계정 제외
- `.claude/spec/service-policy/interview.md` - 입력 방식 절의 음성 원본 보관 기간, P11 갱신

> **DB 변경 없음.** 엔티티와 마이그레이션을 건드리지 않는다.
>
> **정책 변경 있음.** `interview.md:61`의 "음성 원본은 ... 계속 보관한다"를 "회원이 탈퇴해 실제 삭제될 때까지 보관한다"로 바꾸고, P11에서 보관 기간을 확정 항목으로 옮긴다.
>
> **정책과 코드 불일치 정리 (D3).** `user.md:15`는 복구한 계정을 되살린다고 적지만 코드는 복구한 계정도 예약 시각에 지운다. 문서를 기준으로 코드를 고친다.

## 구현 계획

### 1. Entity / Flyway

변경 없음.

### 2. Repository

**`user/repository/sql/UserCleanDeletionSql`** (수정)

`d_inquiry` 뒤, 마지막 `DELETE FROM users` 앞에 추가한다.

```sql
d_interview_feedback AS (
  DELETE FROM interview_feedback
  WHERE answer_id IN (
    SELECT id FROM interview_answer
    WHERE session_id IN (SELECT id FROM interview_session WHERE user_id = :id)
  )
),
d_interview_answer AS (
  DELETE FROM interview_answer
  WHERE session_id IN (SELECT id FROM interview_session WHERE user_id = :id)
),
d_interview_session_topic AS (
  DELETE FROM interview_session_topic
  WHERE session_id IN (SELECT id FROM interview_session WHERE user_id = :id)
),
d_interview_session AS (
  DELETE FROM interview_session WHERE user_id = :id
)
```

Javadoc 삭제 대상 목록에 `8. 면접 (interview_feedback, interview_answer, interview_session_topic, interview_session)`을 넣고 `사용자 (users)`를 9로 민다. 기존 주석을 사실에 맞추는 수정이며 설명을 새로 달지 않는다.

**`interview/repository/InterviewSessionRepository`** (수정)

```java
@Query("""
        SELECT s.id FROM InterviewSession s
        WHERE s.userId = :userId AND s.inputType = :inputType
""")
List<Long> findIdsByUserIdAndInputType(
        @Param("userId") long userId,
        @Param("inputType") InterviewInputType inputType
);
```

**`user/repository/UserRepository`** (수정, D3)

```java
@Query(value = """
        SELECT EXISTS (
            SELECT 1 FROM users
            WHERE id = :userId AND deleted_at IS NOT NULL
        )
""", nativeQuery = true)
boolean existsWithdrawnById(@Param("userId") long userId);
```

- 탈퇴 상태(soft delete)인 행이 있을 때만 true다. 복구된 계정과 이미 실제 삭제된 id는 false다

### 3. Infrastructure / Config

**`global/config/S3Config`** (수정, D2)

```java
@Bean
public S3Client s3Client(
        @Value("${aws.s3.region}") String region,
        @Value("${aws.s3.access-key}") String accessKey,
        @Value("${aws.s3.secret-key}") String secretKey
)
    // S3Client.builder().region(Region.of(region)).credentialsProvider(credentialsProvider(accessKey, secretKey)).build()

private StaticCredentialsProvider credentialsProvider(
        String accessKey,
        String secretKey
)
    // StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey))
```

- `s3Presigner`도 `credentialsProvider`를 쓰게 바꿔 자격 증명 생성을 한 곳에 둔다
- `S3Client`는 `AutoCloseable`이라 컨텍스트가 종료될 때 스프링이 닫는다

**`interview/policy/InterviewAudioKeyPolicy`** (수정, D2)

```java
private static final String SESSION_PREFIX_FORMAT = "interview/%d/";

public String sessionPrefix(long sessionId)
    // String.format(SESSION_PREFIX_FORMAT, sessionId)
```

- 기존 `KEY_FORMAT`, `KEY_PREFIX_FORMAT`, `issue`, `validate`는 손대지 않는다

**`interview/infrastructure/InterviewAudioStorage`** (수정, D2)

- 생성자에 `S3Client s3Client` 추가, 클래스에 `@Slf4j`

```java
public void deleteAllByPrefix(String prefix)
    // ListObjectsV2Request(bucket, prefix) -> s3Client.listObjectsV2(...).contents()
    // 비었으면 return
    // S3Object.key() -> ObjectIdentifier 목록
    // DeleteObjectsRequest(bucket, Delete(objects, quiet = true)) -> s3Client.deleteObjects(...)
    // response.errors()가 비어 있지 않으면
    //   log.warn("면접 음성 삭제 일부 실패: prefix={}, errors={}", prefix, 키와 code 목록)
    //   throw new RestApiException(CustomErrorCode.INTERVIEW_AUDIO_DELETE_FAILED)
```

- `quiet = true`면 응답에 실패한 키만 담긴다
- 업로드 쪽 `presignUpload(audioKey, contentType)`과 같이 저장소는 키 문자열만 받고 키 형식은 정책이 만든다

**`interview/infrastructure/InterviewAudioDeletionRetryTarget`** (신규, D1)

```java
@Component
@RequiredArgsConstructor
public class InterviewAudioDeletionRetryTarget implements RetrySweepTarget {

    private static final String QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";
    private static final int MAX_ATTEMPTS = 10;

    private final InterviewAudioDeletionService interviewAudioDeletionService;

    @Override
    public String queueKey()
        // QUEUE_KEY

    @Override
    public int maxAttempts()
        // MAX_ATTEMPTS

    @Override
    public void reprocess(Map<String, String> fields)
        // long sessionId = Long.parseLong(fields.get(SESSION_ID_FIELD))
        // interviewAudioDeletionService.deleteBySessionId(sessionId)    실패하면 예외 그대로, 스위퍼가 재적재
}
```

- 재시도 불가로 끊는 경우가 없다. 권한 거부도 권한을 고치면 성공하므로 한도까지 다시 시도한다
- `MAX_ATTEMPTS`는 `UserXpInterviewRetryTarget`과 같은 10이다. 스위퍼 주기와 백오프를 합치면 첫 실패부터 데드레터까지 약 20분이다
- 큐 키와 필드명 문자열은 적재하는 `InterviewAudioDeletionService`와 이 대상에 따로 적는다. 기존 대상들과 같은 방식이며, 두 값이 같다는 것은 테스트로 고정한다

**`global/exception/domain/CustomErrorCode`** (수정)

`// Interview` 그룹의 `INTERVIEW_GRADING_FAILED` 다음에 추가한다.

```java
INTERVIEW_AUDIO_DELETE_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "INTERVIEW_5002", "면접 음성 파일 삭제에 실패했습니다."),
```

### 4. Service

**`interview/service/InterviewAudioDeletionService`** (신규)

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class InterviewAudioDeletionService {

    private static final String RETRY_QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";

    private final InterviewSessionRepository interviewSessionRepository;

    private final InterviewAudioKeyPolicy interviewAudioKeyPolicy;
    private final InterviewAudioStorage interviewAudioStorage;

    private final RetryEventPublisher retryEventPublisher;

    @Transactional(readOnly = true)
    public List<Long> getVoiceSessionIds(long userId)
        // interviewSessionRepository.findIdsByUserIdAndInputType(userId, InterviewInputType.VOICE)

    public void deleteAllBySessionIds(List<Long> sessionIds)
        // sessionIds.forEach(this::deleteOrQueueRetry)

    public void deleteBySessionId(long sessionId)
        // interviewAudioStorage.deleteAllByPrefix(interviewAudioKeyPolicy.sessionPrefix(sessionId))

    private void deleteOrQueueRetry(long sessionId)
        // try: deleteBySessionId(sessionId)
        // catch (Exception e):
        //   log.error("면접 음성 삭제 실패, 재시도 큐 적재: sessionId={}", sessionId, e)
        //   queueRetry(sessionId)

    private void queueRetry(long sessionId)
        // try: retryEventPublisher.publish(RETRY_QUEUE_KEY, Map.of(SESSION_ID_FIELD, String.valueOf(sessionId)))
        // catch (Exception e):
        //   log.error("면접 음성 삭제 재시도 적재 실패, 유실: sessionId={}", sessionId, e)
}
```

- `deleteBySessionId`는 실패하면 예외를 그대로 던진다. 재시도 대상이 이 메서드를 불러 스위퍼의 재적재에 기댄다
- `deleteAllBySessionIds`는 예외를 던지지 않는다. 이유는 배치 기준에 적었다
- 조회와 삭제를 한 메서드로 합치지 않는다. Facade가 DB 삭제 전에 id를 모으고 DB 삭제 뒤에 지워야 하기 때문이다

**`user/service/UserDeletionService`** (수정, D3)

```java
@Transactional(readOnly = true)
public boolean isWithdrawn(long userId)
    // userRepository.existsWithdrawnById(userId)
```

- 기존 `cleanUserDeletion`은 그대로 둔다

### 5. Facade

**`user/facade/UserDeletionFacade`** (신규)

```java
@Facade
@RequiredArgsConstructor
public class UserDeletionFacade {

    private final UserDeletionService userDeletionService;

    private final InterviewAudioDeletionService interviewAudioDeletionService;

    public boolean cleanUserDeletion(long userId)
        // if (!userDeletionService.isWithdrawn(userId)) return false                (D3)
        //
        // List<Long> voiceSessionIds = interviewAudioDeletionService.getVoiceSessionIds(userId)
        //
        // userDeletionService.cleanUserDeletion(userId)                             실패하면 예외 전파, 음성은 건드리지 않음
        //
        // interviewAudioDeletionService.deleteAllBySessionIds(voiceSessionIds)      (D1: 실패한 세션은 재시도 큐, 예외 없음)
        //
        // return true
}
```

- 트랜잭션 경계 없음
- 반환값은 "실제로 지웠는가"다. 스케줄러가 건너뛴 회원을 따로 센다

### 6. Batch

**`user/batch/UserCleanScheduler`** (수정)

- 필드 `UserDeletionService userDeletionService` → `UserDeletionFacade userDeletionFacade`
- `int skipped = 0` 추가, 반복 본문을 아래로 바꾼다

```java
boolean cleaned = userDeletionFacade.cleanUserDeletion(userId);
cleanManager.removeUserKey(userId);

if (cleaned) {
    processed++;
} else {
    skipped++;
}
```

- 종료 로그를 `processed : {}, skipped : {}, failed : {}`로 바꾼다
- 예외 처리(catch → `failed++`, 예약 키 유지)는 그대로다. DB 삭제가 실패하면 이 경로로 다음 정각에 다시 시도한다. 음성 삭제 실패는 Facade 밖으로 나오지 않으므로 이 경로를 타지 않는다

### 7. DTO

변경 없음. 재시도 페이로드는 기존 방식대로 `Map<String, String>`이다.

### 8. Controller

변경 없음. API 계약과 Swagger 문서도 변경 없음.

### 9. 정책 문서

**`user.md:14`** 다음에 추가

- 실제 삭제 때 면접 기록(세션, 고른 주제, 답안, 채점 결과)과 면접 음성 녹음 원본도 함께 지운다. 음성 원본은 제출하지 않은 녹음과 취소한 세션의 녹음까지 지운다
- 음성 원본을 지우지 못해도 기록은 예정대로 지우고, 음성 원본은 따로 다시 시도한다 (D1)

**`user.md:15`** (D3)

- 변경 전: 탈퇴 상태 계정으로 로그인하면 로그인을 막고 탈퇴 상태임을 알린다. 사용자가 복구를 선택하면 그때 되살린다. 복구는 실제 삭제 전(탈퇴 7일 이내)에만 가능하고, 복구 시 핸들은 새로 발급된다
- 변경 후: (위 문장 그대로) + 복구한 계정은 실제 삭제 대상에서 빠진다

**`interview.md:61`**

- 변경 전: 음성 원본은 문항별로 업로드되어 제출 시 답안에 연결되며 계속 보관한다. 세션 안(제출 전 점검)과 리포트 안(복기)에서 재생한다
- 변경 후: 음성 원본은 문항별로 업로드되어 제출 시 답안에 연결되며, 회원이 탈퇴해 실제 삭제될 때까지 보관한다. 파기 시점과 범위는 `user.md`를 따른다. 세션 안(제출 전 점검)과 리포트 안(복기)에서 재생한다

**`interview.md:69`**

- 변경 전: 음성 모드의 실제 지원 시점, 변환 엔진, 보관 기간과 정리 방식은 미결 과제(P11)다
- 변경 후: 음성 모드의 실제 지원 시점, 변환 엔진, 탈퇴 전 정리(취소 세션, 제출하지 않은 녹음)는 미결 과제(P11)다

**`interview.md` P11 행의 현재 기본값**

- 변경 전: 업로드 경로 확정(presigned URL, 결정적 키, 제출 시 키 검증). 남은 것: 음성 원본 계속 보관(정리 배치와 보관 정책 없음), 재생용 다운로드 URL 미발급, 같은 키 덮어쓰기 미차단, 업로드 실재 미확인, 음성-텍스트 변환 엔진과 수행 주체 미정
- 변경 후: 업로드 경로 확정(presigned URL, 결정적 키, 제출 시 키 검증). 보관 기간 확정(탈퇴 실제 삭제 때 세션 단위로 파기). 남은 것: 탈퇴 전 정리 없음(취소 세션과 제출하지 않은 녹음도 탈퇴 전까지 남음), 재생용 다운로드 URL 미발급, 같은 키 덮어쓰기 미차단, 업로드 실재 미확인, 음성-텍스트 변환 엔진과 수행 주체 미정

### 10. 커밋 순서

1. `docs: 탈퇴 회원 면접 데이터 파기 정책 반영과 구현 계획서 추가(#534)` - `user.md`, `interview.md`, PLAN-534
2. `fix: 실제 삭제 SQL에 면접 테이블 추가(#534)` - `UserCleanDeletionSql`. 이 커밋만으로 DB 쪽 누락이 닫힌다
3. `fix: 복구한 회원이 실제 삭제되지 않게 탈퇴 상태 확인(#534)` - `UserRepository`, `UserDeletionService.isWithdrawn`, `UserDeletionFacade`(확인 → DB 삭제), `UserCleanScheduler` Facade 전환
4. `feat: 탈퇴 회원 면접 음성 파일 삭제(#534)` - `S3Config`, `InterviewAudioKeyPolicy`, `InterviewAudioStorage`, `CustomErrorCode`, `InterviewSessionRepository`, `InterviewAudioDeletionService`, `InterviewAudioDeletionRetryTarget`, `UserDeletionFacade`에 음성 세션 수집과 삭제 단계 추가
5. `test: 탈퇴 회원 실제 삭제 통합 테스트 추가(#534)`

## 결정 필요 (Decisions needed)

- [x] **D1 음성 삭제 실패 처리** - DB를 먼저 지우고 음성은 그 뒤에 지운다. 실패한 세션 id는 재시도 큐 `interview-audio-deletion-retry`에 적재한다. DB 파기가 S3 상태에 묶이지 않는 대신, 한도 초과 데드레터(재처리 도구 없음), 적재 실패, DB 삭제와 음성 삭제 사이의 프로세스 종료 때 음성이 남을 수 있음을 받아들인다. 제안했던 "음성 먼저 삭제, 실패 시 회원 전체 보류"는 택하지 않았다
- [x] **D2 석환 작성 파일(#523) 수정** - 기존 파일에 추가한다(`S3Config`의 `S3Client` 빈, `InterviewAudioKeyPolicy.sessionPrefix`, `InterviewAudioStorage.deleteAllByPrefix`). 석환을 PR 리뷰어로 지정해 공유한다
- [x] **D3 복구한 회원의 실제 삭제** - 이번 이슈에서 막는다. 실제 삭제 직전에 탈퇴 상태를 확인하고, 탈퇴 상태가 아니면 삭제를 건너뛰고 예약만 정리한다

## 검증

모두 `@TCSpringBootTest` 통합 테스트다. Docker(Testcontainers)가 필요하다. S3는 `@MockitoBean S3Client`로 대체한다(선례 `UserDeletionServiceIntegrationTest`의 `@MockitoBean MailSender`). 재시도 적재는 `@MockitoBean RetryEventPublisher`로 확인한다(선례 `UserEventListenerIntegrationTest`). 실제 버킷의 권한과 동작은 아래 "배포 전 확인"에서 수동으로 본다.

**픽스처**

- 새 픽스처 없음. 세션은 `InterviewSessionFixture.상태_세션(userId, status, inputType)`, 주제, 답안, 피드백은 `InterviewFeedbackFixture.세션_주제`, `답변한_답안`, `무응답_답안`, `피드백`을 쓴다. 면접 테이블에 FK가 없어 문제 행 없이 임의 `questionId`로 답안을 만들 수 있다
- 탈퇴 회원은 `userFixture.일반_유저(n)` 뒤 `userRepository.deleteById(id)`로 만든다(`@SQLDelete` soft delete)
- S3 목록 응답은 `ListObjectsV2Response.builder().contents(S3Object.builder().key(...).build())`, 삭제 응답은 `DeleteObjectsResponse.builder().build()` 또는 `.errors(S3Error.builder()...)`로 스텁한다

**`UserDeletionServiceIntegrationTest`** (수정, `@Nested` `CleanUserDeletion`에 추가)

- 대상 회원의 세션 2개(완료 세션: 주제, 답안, 피드백 / 진행 중 세션: 미제출 답안)와 다른 회원의 같은 구성을 만든 뒤 실행 → 대상 회원의 4개 테이블 행이 모두 사라지고 다른 회원의 행은 그대로다
- 기존 `연관데이터_없이_정상_삭제`는 수정 없이 통과해야 한다(새 CTE의 테이블명, 문법 회귀)

**`UserDeletionServiceIntegrationTest`** (`@Nested` "탈퇴 상태를 확인할 때" 추가, D3)

- 탈퇴한 회원 → true
- 활성 회원 → false
- 탈퇴 후 `userService.restoreUser(providerId)`로 복구한 회원 → false
- 없는 id → false

**`InterviewAudioDeletionServiceIntegrationTest`** (신규, `@MockitoBean S3Client`, `@MockitoBean RetryEventPublisher`)

음성 세션 id를 조회할 때
- 음성 세션만 나오고 텍스트 세션은 빠진다
- 진행 중, 채점 중, 채점 실패, 완료, 취소 세션이 모두 나온다(`@EnumSource` 상태)
- 다른 회원의 세션은 빠진다
- 세션이 없으면 빈 목록이다

세션 하나의 음성을 지울 때(`deleteBySessionId`)
- `interview/{세션 id}/`로 목록을 조회하고, 나온 키를 버킷 `test-interview-audio`에 `deleteObjects` 한 번으로 지운다(`ArgumentCaptor`로 bucket, prefix, 키 목록 단언)
- 목록이 비면 `deleteObjects`를 부르지 않는다
- 삭제 응답에 errors가 있으면 `INTERVIEW_AUDIO_DELETE_FAILED`
- 목록 조회가 `S3Exception`을 던지면 같은 예외가 그대로 나온다

여러 세션의 음성을 지울 때(`deleteAllBySessionIds`)
- 모두 성공하면 적재하지 않는다
- 한 세션이 실패하면 그 세션만 `interview-audio-deletion-retry`에 `{sessionId}`로 적재하고 나머지 세션은 계속 지운다
- 삭제 응답에 errors가 있어도 적재한다
- 적재가 예외를 던져도 예외 없이 다음 세션을 처리한다
- 빈 목록이면 S3를 부르지 않는다(`verifyNoInteractions`)

**`InterviewAudioDeletionRetryTargetIntegrationTest`** (신규, `@MockitoBean S3Client`)

- 큐 키는 서비스가 적재하는 키(`interview-audio-deletion-retry`)와 같다
- 서비스가 적재한 페이로드 `{sessionId}`로 재처리하면 그 세션 접두사의 음성을 지운다
- 삭제가 실패하면 예외를 다시 던져 스위퍼가 재적재하게 한다

**`UserDeletionFacadeIntegrationTest`** (신규, `@MockitoBean S3Client`, `@MockitoBean RetryEventPublisher`, `@MockitoSpyBean UserDeletionService`)

- 음성 세션이 있는 탈퇴 회원 → 회원 행과 면접 행이 삭제되고, 삭제 전에 모은 세션 id의 접두사로 음성을 지우며 true
- 음성 삭제 실패 → 예외 없이 true, 회원 행과 면접 행은 삭제, 실패한 세션 적재 (D1)
- DB 삭제 실패(`doThrow(...).when(userDeletionService).cleanUserDeletion(userId)`) → 예외 전파, S3 호출 없음 (D1)
- 활성 회원 → S3 호출 없음, 회원 행 그대로, false (D3)
- 이미 실제 삭제된 id → S3 호출 없음, false (D3)

**`UserCleanSchedulerIntegrationTest`** (신규, `@MockitoBean S3Client`, `@MockitoBean RetryEventPublisher`, `@MockitoSpyBean UserDeletionService`)

예약은 `redisTemplate.opsForZSet().add("user:clean:due", String.valueOf(userId), 0)`으로 이미 도래한 상태로 넣는다. `RedisUserCleanManager.storeDeletionUser`는 고정 시계 기준 7일 뒤로 넣어 도래하지 않는다.

- 탈퇴 회원 삭제 성공 → 예약이 사라진다(`cleanManager.allDueUserIds()`가 비어 있음)
- 음성 삭제 실패 → 예약이 사라지고 회원 행도 삭제되며 실패한 세션이 적재된다 (D1)
- DB 삭제 실패 → 예약이 남는다. 다음 정각 재시도의 근거를 고정한다
- 활성 회원 → 예약이 사라지고 회원 행은 남는다 (D3)
- 한 회원의 DB 삭제가 실패해도 다음 회원은 처리된다

**실행**: `./gradlew test --tests 'gravit.code.user*' --tests 'gravit.code.interview*'`

## 배포 전 확인

코드로 확인할 수 없는 항목이다. dev, prod 각각 앱이 쓰는 자격 증명(`DEV_S3_ACCESS_KEY` / `PROD_S3_ACCESS_KEY`)으로 확인한다. 권한이 없으면 배포 뒤 모든 음성 삭제가 약 20분 뒤 데드레터(`interview-audio-deletion-retry:dead-letter`)로 쌓이고 자동으로 다시 처리되지 않으므로(D1) 배포 전에 끝낸다.

- [ ] **목록 조회 권한** `s3:ListBucket` (리소스 `arn:aws:s3:::{버킷}`, `s3:prefix` 조건으로 `interview/*` 제한 가능)
  ```bash
  aws s3api list-objects-v2 --bucket {버킷} --prefix interview/ --max-items 1 --region ap-northeast-2
  ```
- [ ] **삭제 권한** `s3:DeleteObject` (리소스 `arn:aws:s3:::{버킷}/interview/*`). 여러 건 삭제 API도 이 권한을 쓴다. 업로드 URL 서명에 PutObject 권한이 이미 필요하므로 더미 객체로 확인한다. 세션 id 0은 생기지 않는다
  ```bash
  aws s3api put-object --bucket {버킷} --key interview/0/permission-check.txt --region ap-northeast-2
  aws s3api delete-objects --bucket {버킷} --delete 'Objects=[{Key=interview/0/permission-check.txt}],Quiet=true' --region ap-northeast-2
  ```
- [ ] **버전 관리 꺼짐** 켜져 있으면 삭제가 delete marker만 남기고 원본은 이전 버전으로 남아 파기가 되지 않는다. 켜져 있다면 `interview/`에 이전 버전 만료 수명 주기 규칙이 필요하다
  ```bash
  aws s3api get-bucket-versioning --bucket {버킷} --region ap-northeast-2
  ```

## 나중에 고려할 문제

| 항목 | 현재 기본값 |
|---|---|
| 음성 원본의 탈퇴 전 정리 (P11) | 없음. 취소 세션, 채점 실패 세션, 제출하지 않은 녹음도 탈퇴 전까지 남는다 |
| 데드레터 재처리 | 없음. 한도(10회, 약 20분)를 넘긴 세션 id는 `interview-audio-deletion-retry:dead-letter` 리스트에 남고 자동으로 다시 처리되지 않는다. 음성 삭제는 반복해도 결과가 같아, 한도를 늘리거나 데드레터를 큐로 되돌리는 명령을 두어도 안전하다 |
| DB 삭제 뒤, 적재 전의 유실 (D1) | 막지 않는다. 음성 세션 id가 메모리에만 있어, DB 삭제 뒤 음성 삭제나 적재가 끝나기 전에 프로세스가 종료되거나 적재가 실패하면 음성이 영구히 남는다. 막으려면 DB 삭제 전에 세션 id를 큐에 먼저 적재하고 스위퍼만 지우게 바꾼다. 대신 DB 삭제가 실패해도 음성이 먼저 지워질 수 있다 |
| DB 삭제 반복 실패 알림 | 없음. 매시간 다시 시도하고 warn 로그만 남는다. 기존 동작 |
| 목록 조회 권한을 줄 수 없을 때 | 결정적 키 15개(문항 5 × 확장자 3)를 목록 조회 없이 한 번에 지우면 `s3:DeleteObject`만으로 된다. 대신 확장자가 enum에서 빠지면 그 확장자로 올라간 과거 객체를 놓친다 |
| 확인과 삭제 사이의 복구 (D3) | 막지 않는다. 탈퇴 상태 확인과 삭제 SQL 사이(음성 세션 id 조회 한 번)에 복구하면 지워진다. 창이 짧고 복구는 사람이 누르는 동작이다 |

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)

- 테스트: 계획서 "검증"의 신규 테스트 파일 4개와 `UserDeletionServiceIntegrationTest` 시나리오 추가는 작성하지 않음 — 이유: 테스트 작성은 implement 스킬 범위 밖(`write-test`). 기존 테스트는 수정 없이 컴파일된다(`compileJava`, `compileTestJava` 통과).
