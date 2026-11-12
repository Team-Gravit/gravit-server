# [PLAN-566] 면접 음성 답변 텍스트 변환

> 이슈: #566
> 브랜치: feat/566-interview-answer-transcription

## 목표
음성 세션에서 문항별로 업로드된 답변 음성을 서버가 `gpt-transcribe`(LiteLLM 경유)로 비동기 변환하고, 제출 전 확인 화면에서 문항별 변환 상태와 텍스트를 내려준다. 문항의 핵심 개념을 변환 힌트(prompt)로 넘겨 CS 용어 정확도를 높이고, 변환 결과는 사용자가 고친 제출 텍스트(`content`)와 따로 보관한다. 일괄 제출 API의 본문 계약은 바꾸지 않고, 변환 중인 답안이 있으면 제출을 거부하는 검증만 더한다.

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V47__add_transcription_to_interview_answer.sql` — 답안에 변환 텍스트, 변환 상태, 변환 요청 시각 컬럼 추가
- `src/main/java/gravit/code/interview/domain/InterviewTranscriptionStatus.java` — 변환 상태 enum (PENDING, COMPLETED, FAILED)
- `src/main/java/gravit/code/interview/dto/request/InterviewTranscriptionRequest.java` — 변환 요청 본문 (`displayOrder`, `audioKey`)
- `src/main/java/gravit/code/interview/dto/response/InterviewTranscriptionResponse.java` — 문항별 변환 상태와 텍스트
- `src/main/java/gravit/code/interview/dto/response/InterviewTranscriptionsResponse.java` — 세션의 문항별 변환 목록
- `src/main/java/gravit/code/interview/dto/event/InterviewTranscriptionRequestedEvent.java` — 변환 요청 사실 (`answerId`, `audioKey`)
- `src/main/java/gravit/code/interview/service/InterviewTranscriptionCommandService.java` — 변환 요청 검증과 상태 전이 (요청, 완료, 실패)
- `src/main/java/gravit/code/interview/service/InterviewTranscriptionQueryService.java` — 세션의 문항별 변환 조회
- `src/main/java/gravit/code/interview/service/InterviewTranscriptionService.java` — S3 음성 다운로드와 STT 호출 위임 (트랜잭션 없음)
- `src/main/java/gravit/code/interview/infrastructure/InterviewTranscriptionClient.java` — `OpenAiAudioTranscriptionModel` 호출, 핵심 개념 prompt 조립
- `src/main/java/gravit/code/interview/facade/InterviewTranscriptionFacade.java` — 답안, 문제 핵심 개념(interviewQuestion 도메인), 변환, 상태 저장 조합
- `src/main/java/gravit/code/interview/listener/InterviewTranscriptionEventListener.java` — 커밋 후 비동기로 변환 실행
- `src/test/java/gravit/code/interview/service/InterviewTranscriptionCommandServiceIntegrationTest.java`
- `src/test/java/gravit/code/interview/service/InterviewTranscriptionQueryServiceIntegrationTest.java`
- `src/test/java/gravit/code/interview/facade/InterviewTranscriptionFacadeIntegrationTest.java`

### 수정 파일
- `src/main/java/gravit/code/interview/domain/InterviewAnswer.java` — 변환 필드 3개와 상태 전이 메서드 추가, `@DynamicUpdate` 적용
- `src/main/java/gravit/code/interview/repository/InterviewAnswerRepository.java` — `findBySessionIdAndDisplayOrder` 추가
- `src/main/java/gravit/code/interview/service/InterviewAnswerQueryService.java` — `getById` 추가
- `src/main/java/gravit/code/interview/service/InterviewSessionCommandService.java` — `submit`에 변환 중 답안 거부 검증 추가
- `src/main/java/gravit/code/interview/infrastructure/InterviewAudioStorage.java` — `exists(String)`, `download(String)` 추가
- `src/main/java/gravit/code/interview/controller/InterviewSessionController.java` — 변환 요청, 변환 조회 엔드포인트 추가
- `src/main/java/gravit/code/interview/controller/docs/InterviewSessionControllerDocs.java` — 두 엔드포인트 문서 추가, 답안 제출에 4023 추가
- `src/main/java/gravit/code/global/config/AsyncConfig.java` — `interviewTranscriptionAsync` 실행기 추가
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` — 면접 에러코드 4개 추가
- `src/main/resources/application-dev.yml`, `application-prod.yml`, `src/test/resources/application-test.yml` — `spring.ai.openai.audio.transcription.options` (model, language) 추가
- `src/test/java/gravit/code/interview/service/InterviewSessionCommandServiceIntegrationTest.java` — 변환 중 제출 거부 케이스 추가
- `.claude/spec/service-policy/interview.md` — 입력 방식 절에 변환 규칙 추가, 답변 제출 절에 거부 조건 추가, P11 갱신 (**정책 변경**)
- `.claude/rules/code-convention/facade.md` — `@Async` 리스너 예외 목록에 변환 리스너 추가

## 전체 흐름

```
[클라이언트]                         [서버]                                   [S3 / LiteLLM]
1. POST /audio-uploads ─────────▶ presigned PUT 발급 (기존)
2. PUT 음성 ─────────────────────────────────────────────────────────────▶ S3
3. POST /transcriptions ────────▶ 검증, S3 HEAD, 답안 PENDING, 이벤트 발행 ──▶ S3 HEAD
                    ◀── 202
                                  (커밋 후, interviewTranscriptionAsync)
                                  답안, 핵심 개념 조회
                                  S3 다운로드 ───────────────────────────▶ S3 GET
                                  gpt-transcribe 호출 ───────────────────▶ LiteLLM
                                  답안 COMPLETED 또는 FAILED
4. GET /transcriptions (폴링) ──▶ 문항별 {status, transcript}
5. PATCH /submit ───────────────▶ 진행 중 PENDING 있으면 4023, 없으면 기존 제출
```

## 구현 계획

### 1. Flyway

`src/main/resources/db/migration/V47__add_transcription_to_interview_answer.sql`

```sql
-- V47__add_transcription_to_interview_answer.sql

-- 음성 답안의 STT 변환 결과. 사용자가 수정해 제출한 content와 따로 보관한다
ALTER TABLE interview_answer ADD COLUMN transcript TEXT;

-- 변환 상태. 변환을 요청하지 않은 답안(텍스트 세션 포함)은 NULL
ALTER TABLE interview_answer ADD COLUMN transcription_status VARCHAR(255)
    CHECK (transcription_status IN ('PENDING', 'COMPLETED', 'FAILED'));

-- 마지막 변환 요청 시각. PENDING 고착 판정에 쓴다
ALTER TABLE interview_answer ADD COLUMN transcription_requested_at TIMESTAMP(6);
```

- 기존 행은 세 컬럼 모두 NULL이 되고, 이는 "변환 요청 전"과 같은 의미라 백필하지 않는다

### 2. Entity

#### `InterviewTranscriptionStatus` (신규)

```java
package gravit.code.interview.domain;

public enum InterviewTranscriptionStatus {
    PENDING,
    COMPLETED,
    FAILED
}
```

#### `InterviewAnswer` (수정)

클래스 선언부에 `@DynamicUpdate`(`org.hibernate.annotations.DynamicUpdate`)를 붙인다.

- 이유: 비동기 변환 완료(`transcript`, `transcription_status`)와 일괄 제출(`status`, `content`, `audio_key`, `answered_at`)이 같은 행을 서로 다른 트랜잭션에서 고친다. Hibernate 기본값인 전체 컬럼 UPDATE에서는 먼저 읽고 나중에 커밋한 쪽이 상대가 바꾼 컬럼을 읽었던 값으로 되돌린다(lost update). 바뀐 컬럼만 UPDATE하면 두 쓰기의 컬럼이 겹치지 않는다
- 언제 겹치나: 결정 2로 진행 중 PENDING에서는 제출을 막지만, 타임아웃이 지난 PENDING은 제출을 막지 않으므로 제출 뒤에 결과가 늦게 도착할 수 있다

```java
@Getter
@Entity
@DynamicUpdate
@Table(...)   // 기존 그대로
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewAnswer extends BaseEntity {

    private static final Duration TRANSCRIPTION_PENDING_TIMEOUT = Duration.ofMinutes(5);

    // 기존 필드 (id, sessionId, questionId, displayOrder, status, content, audioKey, answeredAt) 그대로

    @Column(name = "transcript", columnDefinition = "TEXT")
    private String transcript;

    @Enumerated(EnumType.STRING)
    @Column(name = "transcription_status")
    private InterviewTranscriptionStatus transcriptionStatus;

    @Column(name = "transcription_requested_at")
    private LocalDateTime transcriptionRequestedAt;

    // 생성자: 기존 대입 아래에 추가
    //     this.transcript = null;
    //     this.transcriptionStatus = null;
    //     this.transcriptionRequestedAt = null;

    public boolean isTranscriptionInProgress(LocalDateTime now) {
        return transcriptionStatus == InterviewTranscriptionStatus.PENDING
                && now.isBefore(transcriptionRequestedAt.plus(TRANSCRIPTION_PENDING_TIMEOUT));
    }

    public void requestTranscription(LocalDateTime requestedAt) {
        validatePending();
        validateTranscriptionRequestable(requestedAt);

        this.transcriptionStatus = InterviewTranscriptionStatus.PENDING;
        this.transcript = null;
        this.transcriptionRequestedAt = requestedAt;
    }

    public void completeTranscription(String transcript) {
        if (transcriptionStatus != InterviewTranscriptionStatus.PENDING) {
            return;
        }

        boolean empty = transcript == null || transcript.isBlank();

        this.transcriptionStatus = InterviewTranscriptionStatus.COMPLETED;
        this.transcript = empty ? null : transcript.strip();
    }

    public void failTranscription() {
        if (transcriptionStatus != InterviewTranscriptionStatus.PENDING) {
            return;
        }

        this.transcriptionStatus = InterviewTranscriptionStatus.FAILED;
    }

    private void validateTranscriptionRequestable(LocalDateTime now) {
        if (transcriptionStatus == InterviewTranscriptionStatus.COMPLETED || isTranscriptionInProgress(now)) {
            throw new RestApiException(INTERVIEW_TRANSCRIPTION_ALREADY_REQUESTED);
        }
    }
}
```

- `TRANSCRIPTION_PENDING_TIMEOUT`을 엔티티에 두는 이유: 재요청 허용(결정 3)과 제출 거부(결정 2)가 같은 판정(`isTranscriptionInProgress`)을 써야 한다. 서비스 두 곳에 상수를 나눠 두면 값이 어긋날 수 있다
- 재요청 허용 상태: null(첫 요청), FAILED(결정 1), 타임아웃 지난 PENDING(결정 3). 거부: COMPLETED, 진행 중 PENDING
- `requestTranscription`의 `validatePending()`은 기존 메서드 재사용. 제출된 답안(ANSWERED, NO_RESPONSE)이면 `INTERVIEW_ANSWER_ALREADY_SUBMITTED`. 세션 진행 중 검증이 앞에서 먼저 걸러 실제로는 동시 제출 경합에서만 닿는다
- `completeTranscription`, `failTranscription`이 PENDING이 아닐 때 조용히 무시하는 이유: 타임아웃 뒤 재요청으로 작업이 두 개 돈 경우 먼저 끝난 쪽만 반영하고, 늦은 쪽은 버린다. 예외를 던지면 Facade가 실패로 처리하며 FAILED로 바꾸려다 또 무시되는 것 말고는 얻는 게 없다
- 답안 상태(`status`)는 보지 않는다. 제출 뒤 늦게 도착한 결과도 측정용으로 저장한다

import 추가: `org.hibernate.annotations.DynamicUpdate`, `java.time.Duration`, `static ...CustomErrorCode.INTERVIEW_TRANSCRIPTION_ALREADY_REQUESTED`

### 3. Repository

#### `InterviewAnswerRepository` (수정)

```java
Optional<InterviewAnswer> findBySessionIdAndDisplayOrder(
        long sessionId,
        int displayOrder
);
```

- 파생 쿼리. `uq_interview_answer_session_order` 유니크 인덱스를 탄다
- 조회 API는 기존 `findAllBySessionIdOrderByDisplayOrderAsc`를 재사용한다

### 4. Infrastructure

#### `InterviewAudioStorage` (수정)

```java
private static final int OBJECT_NOT_FOUND_STATUS = 404;

public boolean exists(String audioKey) {
    HeadObjectRequest headObjectRequest = HeadObjectRequest.builder()
            .bucket(bucket)
            .key(audioKey)
            .build();

    try {
        s3Client.headObject(headObjectRequest);
        return true;
    } catch (NoSuchKeyException e) {
        return false;
    } catch (S3Exception e) {
        if (e.statusCode() == OBJECT_NOT_FOUND_STATUS) {
            return false;
        }
        throw e;
    }
}

public byte[] download(String audioKey) {
    GetObjectRequest getObjectRequest = GetObjectRequest.builder()
            .bucket(bucket)
            .key(audioKey)
            .build();

    return s3Client.getObjectAsBytes(getObjectRequest).asByteArray();
}
```

- `HeadObject`는 본문이 없는 응답이라 SDK가 404를 `NoSuchKeyException`이 아닌 일반 `S3Exception`(status 404)으로 줄 수 있다. 그래서 둘 다 잡는다
- **403 주의**: 호출 자격증명에 `s3:ListBucket`이 없으면 S3는 없는 키에 404 대신 403을 준다. 403을 "없음"으로 바꾸면 진짜 권한 오류를 숨기므로 그대로 던진다(500). 기존 `deleteAllByPrefix`가 `ListObjectsV2`(`s3:ListBucket` 필요)를 쓰므로, 탈퇴 삭제가 동작하는 환경이면 권한은 이미 있다. dev에서 없는 키 HEAD로 한 번 확인한다
- 2분 녹음은 1~2MB라 `getObjectAsBytes`로 메모리에 받는다
- import 추가: `HeadObjectRequest`, `NoSuchKeyException`, `S3Exception`

#### `InterviewTranscriptionClient` (신규)

```java
package gravit.code.interview.infrastructure;

@Slf4j
@Component
@RequiredArgsConstructor
public class InterviewTranscriptionClient {

    private static final String PROMPT_FORMAT = "CS 기술 면접 답변입니다. 다음 용어가 나올 수 있습니다: %s";
    private static final String CONCEPT_SEPARATOR = ", ";
    private static final String KEY_PATH_SEPARATOR = "/";

    private final OpenAiAudioTranscriptionModel transcriptionModel;

    public String transcribe(
            String audioKey,
            byte[] audio,
            List<String> conceptNames
    ) {
        try {
            AudioTranscriptionPrompt prompt = buildPrompt(toResource(audioKey, audio), conceptNames);

            return transcriptionModel.call(prompt).getResult().getOutput();
        } catch (RuntimeException e) {
            log.error("면접 답변 음성 변환 호출 실패 - audioKey: {}", audioKey, e);
            throw new RestApiException(INTERVIEW_TRANSCRIPTION_FAILED);
        }
    }

    private Resource toResource(
            String audioKey,
            byte[] audio
    ) {
        String fileName = audioKey.substring(audioKey.lastIndexOf(KEY_PATH_SEPARATOR) + 1);

        return new ByteArrayResource(audio) {
            @Override
            public String getFilename() {
                return fileName;
            }
        };
    }

    private AudioTranscriptionPrompt buildPrompt(
            Resource audio,
            List<String> conceptNames
    ) {
        if (conceptNames.isEmpty()) {
            return new AudioTranscriptionPrompt(audio);
        }

        OpenAiAudioTranscriptionOptions options = OpenAiAudioTranscriptionOptions.builder()
                .prompt(PROMPT_FORMAT.formatted(String.join(CONCEPT_SEPARATOR, conceptNames)))
                .build();

        return new AudioTranscriptionPrompt(audio, options);
    }
}
```

- 파일명을 넘기는 이유: Spring AI 1.1.8의 `OpenAiAudioTranscriptionModel`은 `Resource.getFilename()`으로 multipart 파일명을 정한다(바이트코드에서 확인). 기본 `ByteArrayResource`는 null을 돌려주고, OpenAI는 파일명 확장자로 포맷을 판별한다. 키가 `interview/12/1.m4a`면 `1.m4a`를 넘긴다
- model(`gpt-transcribe`), language(`ko`), temperature(`0`)는 yml 기본 옵션에서 온다. 호출 옵션에는 prompt만 넣는다. Spring AI 1.1.8의 `OpenAiAudioTranscriptionModel.merge`는 호출 옵션의 null 필드를 기본 옵션 값으로 채운다(바이트코드에서 확인)
- 예외 변환과 로그는 `InterviewGradingClient.judge`와 같은 패턴
- import: `org.springframework.ai.audio.transcription.AudioTranscriptionPrompt`, `org.springframework.ai.openai.OpenAiAudioTranscriptionModel`, `org.springframework.ai.openai.OpenAiAudioTranscriptionOptions`, `org.springframework.core.io.ByteArrayResource`, `org.springframework.core.io.Resource`, `static ...INTERVIEW_TRANSCRIPTION_FAILED`

### 5. Service

#### `InterviewTranscriptionCommandService` (신규)

```java
package gravit.code.interview.service;

@Service
@RequiredArgsConstructor
public class InterviewTranscriptionCommandService {

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewAnswerRepository interviewAnswerRepository;

    private final InterviewAudioKeyPolicy interviewAudioKeyPolicy;
    private final InterviewAudioStorage interviewAudioStorage;

    private final ApplicationEventPublisher publisher;
    private final Clock clock;

    @Transactional
    public void request(
            long userId,
            long sessionId,
            InterviewTranscriptionRequest request
    ) {
        InterviewSession session = interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_SESSION_NOT_FOUND));

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(INTERVIEW_SESSION_ACCESS_DENIED);
        }
        if (session.isTextInput()) {
            throw new RestApiException(INTERVIEW_INPUT_TYPE_MISMATCH);
        }
        if (!session.isInProgress()) {
            throw new RestApiException(INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        String audioKey = request.audioKey();
        interviewAudioKeyPolicy.validate(sessionId, request.displayOrder(), audioKey);

        if (!interviewAudioStorage.exists(audioKey)) {
            throw new RestApiException(INTERVIEW_AUDIO_NOT_UPLOADED);
        }

        InterviewAnswer answer = interviewAnswerRepository.findBySessionIdAndDisplayOrder(sessionId, request.displayOrder())
                .orElseThrow(() -> new RestApiException(INTERVIEW_ANSWER_NOT_FOUND));

        answer.requestTranscription(LocalDateTime.now(clock));

        publisher.publishEvent(InterviewTranscriptionRequestedEvent.of(answer.getId(), audioKey));
    }

    @Transactional
    public void complete(
            long answerId,
            String transcript
    ) {
        findAnswer(answerId).completeTranscription(transcript);
    }

    @Transactional
    public void fail(long answerId) {
        findAnswer(answerId).failTranscription();
    }

    private InterviewAnswer findAnswer(long answerId) {
        return interviewAnswerRepository.findById(answerId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_ANSWER_NOT_FOUND));
    }
}
```

- 세션 검증 순서는 `InterviewAudioUploadService.issueUploadUrl`과 같다
- S3 HEAD를 소유자 검증 뒤에 두는 이유: 앞에 두면 남의 세션 키의 존재 여부를 떠볼 수 있다
- S3 HEAD를 트랜잭션 안에서 하는 것: 같은 리전 HEAD 한 번이라 수십 ms다. 트랜잭션 밖으로 빼려면 세션 검증을 두 번 하거나 Facade를 하나 더 두어야 해서 얻는 것보다 복잡도가 크다
- 음성 키는 답안에 저장하지 않고 이벤트로만 넘긴다. 답안의 `audio_key`는 지금처럼 제출 때 확정한다
- 이벤트 발행은 `@Transactional` 경계 안이라 `AFTER_COMMIT` 리스너가 받는다(경계 밖 발행은 폐기된다는 facade.md 제약 충족)

#### `InterviewTranscriptionQueryService` (신규)

```java
package gravit.code.interview.service;

@Service
@RequiredArgsConstructor
public class InterviewTranscriptionQueryService {

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewAnswerRepository interviewAnswerRepository;

    @Transactional(readOnly = true)
    public InterviewTranscriptionsResponse getTranscriptions(
            long userId,
            long sessionId
    ) {
        InterviewSession session = interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_SESSION_NOT_FOUND));

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(INTERVIEW_SESSION_ACCESS_DENIED);
        }
        if (session.isTextInput()) {
            throw new RestApiException(INTERVIEW_INPUT_TYPE_MISMATCH);
        }

        List<InterviewTranscriptionResponse> transcriptions = interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId).stream()
                .map(InterviewTranscriptionResponse::from)
                .toList();

        return InterviewTranscriptionsResponse.of(sessionId, transcriptions);
    }
}
```

- 세션 상태는 제한하지 않는다. 제출 뒤에도 원래 변환 결과를 볼 수 있다

#### `InterviewTranscriptionService` (신규)

```java
package gravit.code.interview.service;

@Service
@RequiredArgsConstructor
public class InterviewTranscriptionService {

    private final InterviewAudioStorage interviewAudioStorage;
    private final InterviewTranscriptionClient interviewTranscriptionClient;

    public String transcribe(
            String audioKey,
            List<String> conceptNames
    ) {
        byte[] audio = interviewAudioStorage.download(audioKey);

        return interviewTranscriptionClient.transcribe(audioKey, audio, conceptNames);
    }
}
```

- 트랜잭션을 걸지 않는다. S3 다운로드와 STT 호출(수 초) 동안 DB 커넥션을 잡지 않기 위해서다
- `InterviewGradingService`와 같은 위임 계층. Facade가 infrastructure를 직접 주입하지 않게 한다

#### `InterviewAnswerQueryService` (수정)

```java
@Transactional(readOnly = true)
public InterviewAnswer getById(long answerId) {
    return interviewAnswerRepository.findById(answerId)
            .orElseThrow(() -> new RestApiException(INTERVIEW_ANSWER_NOT_FOUND));
}
```

#### `InterviewSessionCommandService.submit` (수정, 결정 2)

```java
@Transactional
public InterviewSessionStatusResponse submit(
        long userId,
        long sessionId,
        List<InterviewAnswerSubmitRequest> answerRequests
) {
    InterviewSession session = findSession(sessionId);
    validateOwner(session, userId);
    validateInProgress(session);
    validateDisplayOrders(answerRequests);
    validateAudioKeys(session, answerRequests);

    List<InterviewAnswer> answers = interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId);
    validateAnswerCount(answers);

    LocalDateTime now = LocalDateTime.now(clock);
    validateTranscriptionsSettled(answers, now);      // 추가

    submitAnswers(answers, answerRequests, now);
    session.startGrading(now);

    publisher.publishEvent(InterviewSubmittedEvent.of(sessionId));

    return InterviewSessionStatusResponse.of(session.getId(), session.getStatus());
}

private void validateTranscriptionsSettled(
        List<InterviewAnswer> answers,
        LocalDateTime now
) {
    boolean inProgress = answers.stream()
            .anyMatch(answer -> answer.isTranscriptionInProgress(now));

    if (inProgress) {
        throw new RestApiException(INTERVIEW_TRANSCRIPTION_IN_PROGRESS);
    }
}
```

- 텍스트 세션 분기는 두지 않는다. 텍스트 세션 답안은 변환 상태가 항상 null이라 자연히 통과한다
- 막지 않는 경우: 변환 미요청(null), FAILED, 타임아웃 지난 PENDING. 각각 직접 입력, 무응답 제출, 워커 고장 시 탈출 경로다

### 6. Facade / Listener

#### `InterviewTranscriptionFacade` (신규) — **필요**

변환 힌트로 `interviewQuestion` 도메인의 핵심 개념을 읽어야 해서 두 도메인의 Service를 조합한다.

```java
package gravit.code.interview.facade;

@Slf4j
@Facade
@RequiredArgsConstructor
public class InterviewTranscriptionFacade {

    private final InterviewAnswerQueryService interviewAnswerQueryService;
    private final InterviewQuestionQueryService interviewQuestionQueryService;
    private final InterviewTranscriptionService interviewTranscriptionService;
    private final InterviewTranscriptionCommandService interviewTranscriptionCommandService;

    public void transcribe(
            long answerId,
            String audioKey
    ) {
        try {
            InterviewAnswer answer = interviewAnswerQueryService.getById(answerId);

            List<String> conceptNames = interviewQuestionQueryService.getQuestionIdToConcepts(Set.of(answer.getQuestionId()))
                    .getOrDefault(answer.getQuestionId(), List.of()).stream()
                    .map(InterviewQuestionConcept::getName)
                    .toList();

            String transcript = interviewTranscriptionService.transcribe(audioKey, conceptNames);

            interviewTranscriptionCommandService.complete(answerId, transcript);
        } catch (RuntimeException e) {
            log.error("면접 답변 음성 변환 실패 - answerId: {}", answerId, e);
            markTranscriptionFailed(answerId);
        }
    }

    private void markTranscriptionFailed(long answerId) {
        try {
            interviewTranscriptionCommandService.fail(answerId);
        } catch (RuntimeException e) {
            log.error("면접 답변 음성 변환 실패 상태 전이 실패 - answerId: {}", answerId, e);
        }
    }
}
```

- 트랜잭션 경계를 두지 않는다. 각 서비스 호출이 자기 트랜잭션을 갖고, STT 호출은 어떤 트랜잭션에도 걸치지 않는다
- 실패 처리 구조는 `InterviewGradingFacade.grade`/`markGradingFailed`와 같다. FAILED 기록까지 실패하면 답안은 PENDING에 남고, 5분 뒤 재요청과 제출이 열린다(결정 2, 3)

#### `InterviewTranscriptionEventListener` (신규)

```java
package gravit.code.interview.listener;

@Component
@RequiredArgsConstructor
public class InterviewTranscriptionEventListener {

    private final InterviewTranscriptionFacade interviewTranscriptionFacade;

    @Async("interviewTranscriptionAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleTranscriptionRequested(InterviewTranscriptionRequestedEvent event) {
        interviewTranscriptionFacade.transcribe(event.answerId(), event.audioKey());
    }
}
```

- `InterviewGradingEventListener`와 같은 모양
- 실행기 큐가 차서 제출이 거부되면 예외가 삼켜지고 답안은 PENDING에 남는다. 이것도 5분 타임아웃으로 회수한다
- `facade.md`의 "어길 수 없는 제약"에 `@Async` 리스너 예외가 채점 리스너 하나뿐이라고 적혀 있다. 이 리스너가 두 번째가 되므로 같은 문단에 함께 적는다 → 영향 범위에 `.claude/rules/code-convention/facade.md` 추가

#### `AsyncConfig` (수정)

```java
@Bean(name = "interviewTranscriptionAsync")
public Executor interviewTranscriptionAsyncExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

    executor.setCorePoolSize(2);
    executor.setMaxPoolSize(4);
    executor.setQueueCapacity(100);
    executor.setKeepAliveSeconds(60);
    executor.setAllowCoreThreadTimeOut(true);
    executor.setThreadNamePrefix("InterviewTranscriptionAsync - ");
    executor.initialize();

    return executor;
}
```

- 채점 실행기와 분리해 변환 적체가 채점을 막지 않게 한다. 세션 하나가 변환 작업 5개를 만들어 채점(세션당 1개)보다 작업 수가 많다
- 수치는 채점 실행기(`interviewGradingAsync`: 코어 2, 최대 4, 큐 100)와 같다. 부하 측정 전 초기값이다

### 7. DTO

#### `InterviewTranscriptionRequest` (신규)

```java
package gravit.code.interview.dto.request;

public record InterviewTranscriptionRequest(

        @Schema(
                description = "문항 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @Min(value = 1, message = "문항 번호는 1 이상이어야 합니다.")
        @Max(value = 5, message = "문항 번호는 5 이하여야 합니다.")
        int displayOrder,

        @Schema(
                description = "업로드를 마친 음성 키. 업로드 URL 발급 응답의 audioKey를 그대로 담습니다.",
                example = "interview/12/1.m4a",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotBlank(message = "음성 키가 비어있습니다.")
        String audioKey
) {
}
```

- `audioKey`를 받는 이유: 서버는 업로드 때 고른 포맷(확장자)을 저장하지 않아 문항 번호만으로 키를 다시 만들 수 없다. 제출 본문과 같은 방식이고, 형식은 `InterviewAudioKeyPolicy.validate`로 검증한다

#### `InterviewTranscriptionResponse` (신규)

```java
package gravit.code.interview.dto.response;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTranscriptionResponse(

        @Schema(
                description = "문항 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "변환 상태. PENDING(변환 중) | COMPLETED(완료) | FAILED(실패). 변환을 요청하지 않았으면 null",
                example = "COMPLETED"
        )
        InterviewTranscriptionStatus status,

        @Schema(
                description = "변환된 텍스트. COMPLETED가 아니거나 말이 없었으면 null",
                example = "트랜잭션 격리 수준은 동시에 실행되는 트랜잭션이 서로의 변경을 어디까지 볼 수 있는지 정합니다."
        )
        String transcript
) {
    public static InterviewTranscriptionResponse from(InterviewAnswer answer) {
        return InterviewTranscriptionResponse.builder()
                .displayOrder(answer.getDisplayOrder())
                .status(answer.getTranscriptionStatus())
                .transcript(answer.getTranscript())
                .build();
    }
}
```

- 타임아웃 지난 PENDING도 PENDING으로 내려준다. 응답에 요청 시각을 담지 않으므로, 재요청 시점은 클라이언트가 자기가 변환 요청을 보낸 시각을 기준으로 판단한다. Docs에는 "요청 후 5분이 지나도 PENDING이면 재요청"으로 안내한다

#### `InterviewTranscriptionsResponse` (신규)

```java
package gravit.code.interview.dto.response;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTranscriptionsResponse(

        @Schema(
                description = "면접 세션 아이디",
                example = "12",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "문항 번호 오름차순으로 정렬된 5문항의 변환 결과",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewTranscriptionResponse> transcriptions
) {
    public static InterviewTranscriptionsResponse of(
            long sessionId,
            List<InterviewTranscriptionResponse> transcriptions
    ) {
        return InterviewTranscriptionsResponse.builder()
                .sessionId(sessionId)
                .transcriptions(transcriptions)
                .build();
    }
}
```

- `InterviewSessionQuestionsResponse`와 같은 모양

#### `InterviewTranscriptionRequestedEvent` (신규)

```java
package gravit.code.interview.dto.event;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTranscriptionRequestedEvent(

        long answerId,

        String audioKey
) {
    public static InterviewTranscriptionRequestedEvent of(
            long answerId,
            String audioKey
    ) {
        return InterviewTranscriptionRequestedEvent.builder()
                .answerId(answerId)
                .audioKey(audioKey)
                .build();
    }
}
```

### 8. Controller

#### `InterviewSessionController` (수정)

주입 필드에 Service 두 개를 추가한다(Service 묶음 안).

```java
private final InterviewTranscriptionCommandService interviewTranscriptionCommandService;
private final InterviewTranscriptionQueryService interviewTranscriptionQueryService;

@PostMapping("/{sessionId}/transcriptions")
public ResponseEntity<Void> requestTranscription(
        @AuthenticationPrincipal LoginUser loginUser,
        @PathVariable long sessionId,
        @Valid @RequestBody InterviewTranscriptionRequest request
) {
    interviewTranscriptionCommandService.request(loginUser.getId(), sessionId, request);

    return ResponseEntity.status(ACCEPTED).build();
}

@GetMapping("/{sessionId}/transcriptions")
public ResponseEntity<InterviewTranscriptionsResponse> getTranscriptions(
        @AuthenticationPrincipal LoginUser loginUser,
        @PathVariable long sessionId
) {
    InterviewTranscriptionsResponse transcriptions = interviewTranscriptionQueryService.getTranscriptions(
            loginUser.getId(), sessionId);

    return ResponseEntity.status(OK).body(transcriptions);
}
```

- 위치: `issueUploadUrl` 바로 아래. 사용 순서(업로드 → 변환 요청 → 변환 조회 → 제출)대로 둔다

#### `InterviewSessionControllerDocs` (수정)

`@Tag` description에 "음성 변환 요청과 조회"를 추가하고, 기존 업로드 URL 발급 문서와 같은 형식으로 두 메서드를 추가한다.

- `requestTranscription`
  - summary: `"면접 음성 변환 요청"`
  - description:
    ```
    업로드를 마친 문항의 음성을 텍스트로 변환하도록 요청합니다.<br>
    음성 업로드(PUT)가 성공한 직후 호출하고, 변환은 백그라운드에서 진행됩니다.<br>
    결과는 음성 변환 조회 API로 확인합니다.<br>
    변환에 실패(FAILED)했거나 요청 후 5분이 지나도 변환 중(PENDING)이면 다시 요청할 수 있습니다.<br>
    🔐 <strong>Jwt 필요</strong>
    ```
  - 응답: `202` ✅ 변환 요청 접수(본문 없음) / `400` GLOBAL_4001, INTERVIEW_4006(텍스트 세션), INTERVIEW_4020(발급하지 않은 키), INTERVIEW_4021(업로드되지 않음) / `403` INTERVIEW_4004 / `404` INTERVIEW_4003, INTERVIEW_4010 / `409` INTERVIEW_4005(진행 중 아님), INTERVIEW_4013(제출된 답안), INTERVIEW_4022(이미 요청함) / `500` GLOBAL_5001
- `getTranscriptions`
  - summary: `"면접 음성 변환 조회"`
  - description:
    ```
    음성 세션의 5문항 변환 상태와 텍스트를 문항 순서대로 조회합니다.<br>
    PENDING이면 3초 간격으로 다시 조회하고, COMPLETED면 transcript를 사용자에게 보여 주고 수정받습니다.<br>
    COMPLETED인데 transcript가 null이면 말이 없었던 문항입니다.<br>
    FAILED면 변환을 다시 요청하거나 사용자가 직접 입력합니다. 변환을 요청하지 않은 문항은 status가 null입니다.<br>
    변환 중(PENDING)인 문항이 있으면 답안 제출이 거부됩니다.<br>
    🔐 <strong>Jwt 필요</strong>
    ```
  - 응답: `200` 예시(COMPLETED, PENDING, FAILED, null이 섞인 5건) / `400` INTERVIEW_4006 / `403` INTERVIEW_4004 / `404` INTERVIEW_4003 / `500` GLOBAL_5001
- `submit`: `409` 예시에 `INTERVIEW_4023`(변환이 끝나지 않은 답안 존재)을 추가하고, description에 "음성 세션은 변환 중(PENDING)인 문항이 있으면 거부됩니다" 한 줄을 추가한다

### 9. 에러코드

`CustomErrorCode`의 `// Interview` 그룹, 4xxx는 `INTERVIEW_AUDIO_KEY_INVALID` 아래, 5xxx는 `INTERVIEW_AUDIO_DELETE_FAILED` 아래

```java
INTERVIEW_AUDIO_NOT_UPLOADED(BAD_REQUEST, "INTERVIEW_4021", "음성 파일이 업로드되지 않았습니다."),
INTERVIEW_TRANSCRIPTION_ALREADY_REQUESTED(CONFLICT, "INTERVIEW_4022", "이미 변환을 요청한 답안입니다."),
INTERVIEW_TRANSCRIPTION_IN_PROGRESS(CONFLICT, "INTERVIEW_4023", "음성 변환이 끝나지 않은 답안이 있어 제출할 수 없습니다."),
...
INTERVIEW_TRANSCRIPTION_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "INTERVIEW_5003", "면접 답변 음성 변환 요청이 실패했습니다."),
```

- `INTERVIEW_TRANSCRIPTION_FAILED`는 비동기 경로 안에서만 쓰여 클라이언트에 노출되지 않는다

### 10. 설정

dev, prod yml의 `spring.ai.openai` 아래 (`chat`과 같은 깊이)

```yaml
spring:
  ai:
    openai:
      base-url: http://litellm-gw:4000
      api-key: ${LITELLM_MASTER_KEY:dummy}
      chat:
        options:
          model: codex-terra
      audio:
        transcription:
          options:
            model: gpt-transcribe
            language: ko
            temperature: 0
```

- test yml에도 같은 블록을 넣는다. 테스트는 `OpenAiAudioTranscriptionModel`을 `@MockitoBean`으로 바꾸므로 값은 쓰이지 않지만, 자동 구성이 같은 프로퍼티로 뜨게 맞춘다
- 모델명은 LiteLLM 게이트웨이에 등록된 이름이어야 한다. 채팅 모델(`codex-terra`)처럼 별칭을 쓰면 그 이름으로 바꾼다. 게이트웨이 라우팅 등록은 이 레포 밖의 작업이다
- `language: ko`를 고정하는 이유: 한국어 답변에 영어 용어가 섞여 자동 언어 감지가 영어로 잘못 잡히는 경우를 막는다
- `temperature: 0`을 명시하는 이유: Spring AI 자동 구성의 기본값이 0.7이다(`OpenAiAudioTranscriptionProperties`, OpenAI API 자체 기본값은 0). 받아쓰기에서 temperature가 높으면 없는 문장을 만들어 내는 경향이 커진다

### 11. 정책 문서와 규칙

#### `.claude/spec/service-policy/interview.md`

입력 방식 절, "음성 원본은 서버를 거치지 않고..." 다음에 추가

```
- 음성 답변의 텍스트 변환은 서버가 한다. 클라이언트가 문항 업로드를 마친 뒤 변환을 요청하면 서버가 업로드 실재를 확인하고 백그라운드에서 변환한다
- 변환 엔진은 gpt-transcribe(LiteLLM 경유)다. 언어는 한국어로 고정하고, 문항의 핵심 개념 이름을 변환 힌트로 넘겨 CS 용어 정확도를 높인다
- 변환 상태는 변환 중(PENDING), 완료(COMPLETED), 실패(FAILED)다. 실패했거나 요청 후 5분이 지나도 변환 중이면 다시 요청할 수 있다. 완료된 문항은 다시 요청할 수 없다
- 클라이언트는 제출 전 확인 화면에서 문항별 변환 상태와 텍스트를 조회해 사용자에게 보여 주고 수정받는다. 실패한 문항은 다시 요청하거나 사용자가 직접 입력한다
- 변환 결과는 사용자가 수정해 제출한 텍스트와 따로 보관한다. 채점에는 쓰지 않는다
```

"서버는 제출 시점에 오브젝트가 실제로 올라와 있는지 확인하지 않는다" 항목 끝에 "변환을 요청한 문항은 요청 시점에 확인한다"를 덧붙인다.

"음성 모드의 실제 지원 시점, 변환 엔진, 탈퇴 전 정리(...)는 미결 과제(P11)다" 항목에서 "변환 엔진"을 지운다.

답변 제출 절, "음성 세션의 음성 키는..." 다음에 추가

```
- 음성 세션에 변환 중(PENDING)인 문항이 있으면 제출을 거부한다. 요청 후 5분이 지난 변환 중 문항, 실패한 문항, 변환을 요청하지 않은 문항은 막지 않는다
```

P11 갱신: 남은 것에서 "음성-텍스트 변환 엔진과 수행 주체 미정"을 지우고 확정 목록에 "변환 확정(서버, gpt-transcribe, 업로드 후 요청 시 비동기)"을 추가한다. 남은 것의 "업로드 실재 미확인"은 "업로드 실재는 변환 요청 시에만 확인(제출 시 미확인)"으로 바꾼다. 남은 것에 "무음 구간 환각(없는 문장 생성) 대응 미검증"을 추가한다.

#### `.claude/rules/code-convention/facade.md`

"어길 수 없는 제약"의 `@Async` 예외 문장을 두 리스너로 고친다.

```
예외는 면접 채점 리스너(`InterviewGradingEventListener`)와 면접 음성 변환 리스너(`InterviewTranscriptionEventListener`)로, `@Async`가 붙어 실행기 스레드에서 돌고 `execute()`는 작업 제출만 하고 반환한다
```

## 결정 필요 (Decisions needed)
- [x] 1. 변환 실패(FAILED) 처리 — **A. 같은 문항 재요청 허용**(클라이언트 재시도 버튼, 계속 실패하면 직접 입력) / B. 재요청 없이 직접 입력만
- [x] 2. 변환이 끝나기 전 제출 — A. 허용 / **B. 거부**(진행 중인 PENDING 답안이 있으면 `INTERVIEW_TRANSCRIPTION_IN_PROGRESS`)
  - 결정 3과 함께 적용: 요청 후 5분이 지난 PENDING은 고착으로 보고 제출을 막지 않는다. 워커가 죽었을 때 사용자가 제출하지 못하는 상태가 끝없이 이어지지 않게 하기 위해서다
- [x] 3. PENDING 고착 회수 — **A. 요청 후 5분이 지난 PENDING은 재요청 허용**(`transcription_requested_at` 컬럼) / B. 회수 없음(P11로 미룸)

## 검증
- 공통 설정
  - `S3Client`, `OpenAiAudioTranscriptionModel`은 `@MockitoBean`(외부 연동 대체)
  - 시각: 테스트 `Clock`은 `FixedClockConfig`의 고정 시계라 움직일 수 없다. 타임아웃 전후 상태는 `answer.requestTranscription(LocalDateTime.now(clock).minusMinutes(6))`처럼 과거 요청 시각으로 답안을 만들어 저장해 둔다(타임아웃 전은 `minusMinutes(1)`)
  - 비동기 경합 차단: 통합 테스트에서도 `AFTER_COMMIT` + `@Async` 리스너가 실제로 돈다. `request` 커밋 뒤 실행기 스레드가 목 S3(`getObjectAsBytes`가 null)에서 실패해 답안을 FAILED로 바꾸므로, PENDING 검증이 타이밍에 따라 깨진다. 그래서 `request`를 호출하는 테스트는 `InterviewTranscriptionFacade`를 `@MockitoSpyBean`으로 두고 `doNothing()`으로 막는다(호출 검증 용도). Facade 테스트는 리스너를 거치지 않고 `transcribe`를 직접 호출한다
  - 변환 스텁(`StubInterviewGradingClient` 같은 전역 스텁)은 두지 않는다. 비동기 경로를 타는 테스트가 `request` 테스트뿐이고, 거기서는 Facade를 막는 것으로 충분하다
- 대상 테스트
  - `InterviewTranscriptionCommandServiceIntegrationTest`
    - `Request`: 성공 시 PENDING, 요청 시각 기록, 커밋 후 Facade가 `transcribe(answerId, audioKey)`로 호출됨(`verify(facade, timeout(...))`)
    - `Request`: 텍스트 세션(4006), 남의 세션(4004), 진행 중 아닌 세션(4005), 형식이 틀린 키와 다른 문항의 키(4020), S3 HEAD 404(4021) 거부
    - `Request`: COMPLETED 재요청, 타임아웃 전 PENDING 재요청 거부(4022) / FAILED 재요청, 타임아웃 지난 PENDING 재요청 허용
    - `Complete`: 공백 결과를 null로 저장, 앞뒤 공백 제거, PENDING이 아닌 답안은 그대로
    - `Fail`: PENDING만 FAILED, 그 외는 그대로
  - `InterviewTranscriptionFacadeIntegrationTest`
    - 준비: 답안을 PENDING으로 저장, `s3Client.getObjectAsBytes`는 `ResponseBytes.fromByteArray(...)`, 모델 `call(AudioTranscriptionPrompt)`은 `new AudioTranscriptionResponse(new AudioTranscription(...))`를 돌려주게 한다
    - 성공 시 COMPLETED와 텍스트 저장
    - 모델 호출 인자 캡처: prompt에 문항 핵심 개념 이름 포함, 개념이 없으면 옵션 없음, `Resource.getFilename()`이 키의 파일명(`1.m4a`)
    - 모델 예외, S3 다운로드 예외 시 FAILED
    - 제출 뒤 늦게 완료돼도 답안의 `content`, `status`, `audioKey`가 바뀌지 않음 (`@DynamicUpdate` 회귀 방지)
  - `InterviewTranscriptionQueryServiceIntegrationTest`
    - 5문항이 문항 순서로, 요청 전 문항은 status와 transcript가 null
    - 텍스트 세션(4006), 남의 세션(4004) 거부
  - `InterviewSessionCommandServiceIntegrationTest`
    - 음성 세션에 타임아웃 전 PENDING 답안이 있으면 제출 거부(4023)
    - 타임아웃 지난 PENDING, FAILED, 미요청 답안만 있으면 제출 성공
    - 기존 제출 시나리오 회귀
- 수동 확인 (dev)
  - LiteLLM 게이트웨이의 `gpt-transcribe` 라우팅 등록
  - m4a, webm 녹음 실제 변환
  - 없는 키에 HEAD가 404로 오는지(403이면 `s3:ListBucket` 권한 누락)
  - 거의 무음인 2분 녹음에서 없는 문장이 생기지 않는지

## Deviation Log

### 테스트
- `@DynamicUpdate` 회귀 테스트를 `InterviewTranscriptionFacadeIntegrationTest`가 아니라 `InterviewTranscriptionCommandServiceIntegrationTest`(`Complete`)에 둠. 한 트랜잭션 안에서 답안 조회 → JdbcTemplate로 제출 컬럼 변경 → `complete()` 순서로 실행해 제출 컬럼이 남는지 확인 — 이유: Facade는 `complete()` 안에서 답안을 새로 읽어 Facade 경로로는 덮어쓰기가 재현되지 않는다. Facade 테스트에는 "제출 뒤 늦게 도착한 결과" 시나리오만 남김
- 계획에 없던 케이스 추가: S3 HEAD 403을 없음으로 바꾸지 않고 그대로 던짐, 요청 후 정확히 5분 지난 PENDING 경계값, 요청하지 않은 문항의 답안은 바뀌지 않음, 이미 COMPLETED인 답안에 늦게 온 결과는 버림
- 픽스처 추가: `InterviewSessionFixture`(`변환_중_답안`, `변환_완료_답안`, `변환_실패_답안`), `InterviewAudioS3Fixture`(`음성_있음`, `음성_없음`, `본문_없는_404`, `음성_내용`)
- `build.gradle`: 계획에 없던 수정. `test` 태스크에 `maxHeapSize = '1g'` 추가 — 이유: 전체 테스트가 기본 힙(512m)에서 `OutOfMemoryError`로 멈췄다. `@MockitoBean` 조합마다 Spring 컨텍스트가 따로 캐시되는데 이번에 조합이 2개(CommandService 테스트의 S3 + Facade 스파이, Facade 테스트의 S3 + 변환 모델 목) 늘었다. 1g에서 전체 1218건 통과. CI(`ci-common.yml`)도 같은 기본 힙이라 그대로면 CI에서도 같은 OOM이 날 수 있다

### 변환 엔진 업스트림 확정 (레포 밖 작업)
- 계획은 게이트웨이에 `gpt-transcribe`를 등록하는 것까지만 적었고 업스트림은 정하지 않았다. 게이트웨이 업스트림이 codex-lb 하나뿐이라 확인한 결과, codex-lb가 ChatGPT 구독 경로로 `gpt-4o-transcribe`만 받는다
- 게이트웨이 `model_list`에 `gpt-transcribe` → `openai/gpt-4o-transcribe`(`api_base: http://codex-lb:2455/v1`, `mode: audio_transcription`)를 추가했다. 앱 코드와 yml은 그대로다
- codex-lb v1.24.0(`latest`)은 음성 변환 경로에서 클라이언트 User-Agent(`OpenAI/Python`)를 그대로 넘겨 ChatGPT의 Cloudflare에 403으로 막혔다. 음성 변환 헤더를 Codex CLI 형태로 바꾸는 수정은 v1.25.0-beta.2부터 있어 서버 compose를 `1.25.0-beta.9`로 고정했다. 채점 경로도 같은 방식(Codex CLI 헤더로 바꿔 호출)으로 이미 동작 중임을 소스에서 확인했다
- 실제 한국어 녹음 1건으로 확인: 문장은 거의 그대로 받아썼고, 힌트(`prompt`)는 모델까지 전달된다(`Read Committed` 표기가 힌트와 같아짐). 다만 효과는 표기를 맞추는 정도라 계획의 "CS 용어 정확도를 높인다"보다 작다
- 이 경로는 변환한 음성의 사본을 ChatGPT 계정에 30일 남긴다(`asset_ttl: 30d`). 서비스가 지울 수 없다
- 무음 환각은 말 없는 신호음 1건만 확인(`text: ""`). 실제 무음 녹음은 확인하지 않았다

### 정책 문서
- `interview.md`: 변환 엔진 항목을 실제 경로와 힌트 효과로 고치고, 30일 사본 항목을 추가했으며, P11의 남은 것에 외부 사본, 비공식 경로 의존, 무음 확인 범위를 반영
- `user.md`: 계획에 없던 수정. 실제 삭제 범위에 외부 변환 사본이 들어가지 않는다는 항목 추가 — 이유: 30일 사본이 탈퇴 파기 정책과 어긋나 파기 정책 문서에도 남겨야 한다
