# [PLAN-562] 면접 질문 음성 재생 URL 발급

> 이슈: #562
> 브랜치: feat/562-interview-question-audio-url

## 목표
면접 질문의 음성 키(`interview_question.audio_key`, #560)를 클라이언트가 재생할 수 있도록, 세션 문항 조회 응답에 presigned GET URL(`audioUrl`)을 싣는다. 음성이 없는 문항은 `audioUrl`을 null로 내려 클라이언트가 텍스트만 보여 주게 한다.

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/interview/infrastructure/InterviewAudioStorage.java` — 재생용 presigned GET 발급 `presignDownload(String)` 추가, 만료 설정값 주입
- `src/main/java/gravit/code/interview/dto/internal/InterviewSessionQuestionDto.java` — `audioKey` 컴포넌트 추가
- `src/main/java/gravit/code/interview/repository/InterviewAnswerRepository.java` — `findQuestionsBySessionId` 프로젝션에 `q.audioKey` 추가
- `src/main/java/gravit/code/interview/dto/response/InterviewSessionQuestionResponse.java` — `audioUrl` 필드 추가, 팩토리를 `of(question, audioUrl)`로 변경
- `src/main/java/gravit/code/interview/service/InterviewSessionQueryService.java` — `getQuestions`에서 문항별 재생 URL 발급
- `src/main/java/gravit/code/interview/controller/docs/InterviewSessionControllerDocs.java` — 문제 목록 조회 설명과 응답 예시에 `audioUrl` 반영
- `src/main/resources/application-dev.yml`, `application-prod.yml`, `src/test/resources/application-test.yml` — `aws.s3.download-expiry` 추가
- `src/test/java/gravit/code/interview/service/InterviewSessionQueryServiceIntegrationTest.java` — `GetQuestions`에 재생 URL 케이스 추가
- `.claude/spec/service-policy/interview.md` — 질문 음성 재생 규칙 추가, P11 갱신 (**정책 변경**)

## 구현 계획

1. **Entity / Flyway**: 변경 없음. `InterviewQuestion.audioKey`와 V46은 #560에서 추가됐다.

2. **Repository**: `InterviewAnswerRepository.findQuestionsBySessionId(long sessionId)`
   - 생성자 표현식에 `q.audioKey`를 추가한다. 이미 `InterviewQuestion`과 조인하므로 쿼리 수는 그대로 1회다.
     ```java
     SELECT new gravit.code.interview.dto.internal.InterviewSessionQuestionDto(a.displayOrder, q.content, q.audioKey)
     FROM InterviewAnswer a JOIN InterviewQuestion q ON q.id = a.questionId
     WHERE a.sessionId = :sessionId
     ORDER BY a.displayOrder ASC
     ```
   - `InterviewSessionQuestionDto`에 `String audioKey` 컴포넌트를 추가한다(생성자 표현식 대상이라 표준 생성자 유지).

3. **Infrastructure**: `InterviewAudioStorage`
   - 생성자에 `@Value("${aws.s3.download-expiry}") Duration downloadExpiry` 추가, 필드 `downloadExpiry`
   - 메서드 추가
     ```java
     public String presignDownload(String audioKey) {
         GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                 .bucket(bucket)
                 .key(audioKey)
                 .build();

         GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
                 .signatureDuration(downloadExpiry)
                 .getObjectRequest(getObjectRequest)
                 .build();

         return s3Presigner.presignGetObject(presignRequest).url().toString();
     }
     ```
   - 키 형식은 검증하지 않는다. 저장된 키를 그대로 서명한다(PLAN-560 D1: 서버는 질문 음성 키를 만들거나 검증하지 않는다).
   - 오브젝트 존재 여부는 확인하지 않는다(HEAD 호출 없음). 존재는 콘텐츠 파이프라인이 업로드 검증과 DB↔S3 대조로 보장한다.

4. **Service**: `InterviewSessionQueryService.getQuestions(long userId, long sessionId)`
   - 의존성 추가: `InterviewAudioStorage interviewAudioStorage` (Repository 묶음 다음, 컴포넌트 종류)
   - 조회 후 문항별로 URL을 붙인다. 소유권 검사는 기존과 같다.
     ```java
     List<InterviewSessionQuestionResponse> responses = questions.stream()
             .map(question -> InterviewSessionQuestionResponse.of(question, issueAudioUrl(question.audioKey())))
             .toList();

     return InterviewSessionQuestionsResponse.of(sessionId, responses);
     ```
   - private 메서드 `String issueAudioUrl(String audioKey)` — `audioKey`가 null이면 null, 아니면 `interviewAudioStorage.presignDownload(audioKey)`
   - 세션 상태와 입력 방식으로 거르지 않는다(결정 D1). 문제 목록 조회가 다섯 상태 모두에서 허용되는 기존 규칙을 따른다.

5. **Facade**: 불필요 — 단일 Service. `InterviewAudioStorage`는 같은 `interview` 도메인의 인프라 컴포넌트다(`InterviewAudioUploadService` 선례).

6. **DTO**: `InterviewSessionQuestionResponse`
   - 필드 추가 (`content` 다음)
     ```java
     @Schema(
             description = "질문 음성 재생 URL(presigned GET). 음성이 없는 문항은 null. 발급 후 설정된 만료 시간 동안 유효",
             example = "https://gravit-interview-audio.s3.ap-northeast-2.amazonaws.com/interview-question/1.mp3?X-Amz-Algorithm=...",
             nullable = true
     )
     String audioUrl
     ```
   - 팩토리 `from(InterviewSessionQuestionDto question)`를 `of(InterviewSessionQuestionDto question, String audioUrl)`로 바꾼다. 호출처는 `InterviewSessionQueryService` 하나다.

7. **Controller / Docs**: 엔드포인트 변경 없음(`GET /api/v1/interview/sessions/{sessionId}/questions`). `InterviewSessionControllerDocs.getQuestions`
   - 설명에 "각 문항에 질문 음성 재생 URL(`audioUrl`)을 함께 내려줍니다. 음성이 없는 문항은 null입니다. URL은 30분 동안 유효하므로 만료 후에는 목록을 다시 조회합니다." 추가
   - 응답 예시의 각 문항에 `audioUrl` 추가(5개 중 1개는 null로 두어 null 가능성을 보인다)

8. **설정**: `aws.s3.download-expiry: 30m`을 `application-dev.yml`, `application-prod.yml`, `application-test.yml`에 추가한다.
   - `upload-expiry`와 같이 기본값 없이 필수로 둔다. **로컬 `application-local.yml`은 레포에서 추적하지 않는 파일이라 각자 한 줄을 추가해야 기동된다** — PR 본문에 적는다.

9. **서비스 정책**: `interview.md`
   - "입력 방식"에 추가: 세션 문항 조회는 문항마다 질문 음성 재생 URL을 함께 준다. 질문 음성이 없는 문항은 비워 두며, 클라이언트는 이때 텍스트만 보여 준다. URL은 30분 동안 유효하고 만료되면 문항을 다시 조회해 새 URL을 받는다
   - P11 "남은 것"의 "재생용 다운로드 URL 미발급(답변 음성, 질문 음성 모두)"을 "재생용 다운로드 URL 미발급(답변 음성)"으로 고친다

10. **배포 전 확인 (코드로 확인 불가)**
    - dev, prod 서버 S3 키(`DEV_/PROD_S3_ACCESS_KEY`)의 IAM 정책에 `interview-question/*`에 대한 `s3:GetObject`가 있는지 확인한다. presigned URL은 서명한 키의 권한을 따르므로, `interview/*`로 한정돼 있으면 URL은 발급되지만 재생이 403으로 실패한다. 없으면 추가한다
    - 질문 음성은 dev 버킷에만 올라가 있다. prod 버킷 업로드 전에 prod에 배포되면 URL은 발급되지만 404가 난다. prod 음성 업로드(콘텐츠 레포 #8)와 배포 순서를 맞춘다

## 결정 필요 (Decisions needed)
- [x] D1. 재생 URL을 줄 세션 범위 — **확정: A 모든 세션** / B 음성(VOICE) 세션만. 질문 음성은 질문을 읽어 주는 것이라 답변 입력 방식과 무관하고, 텍스트 모드에서도 듣기를 제공할지는 클라이언트가 정할 수 있다. 서명은 로컬 연산이라 비용 차이가 없다. B면 텍스트 세션 응답은 항상 null이다
- [x] D2. URL 만료 시간 — **확정: A 30분** / B 10분(업로드와 동일). 클라이언트가 문항 목록을 세션 시작 때 한 번만 받는다면 5문항 × (질문 듣기 + 발화 2분)에 여유를 둔 30분이 필요하다. 문항마다 목록을 다시 부른다면 10분으로 충분하다. 클라이언트 조회 방식 확인이 필요하다
- [x] D3. 결과 화면(문항별 상세)에도 질문 음성 URL을 줄지 — **확정: A 이번에는 주지 않음**(후속 이슈) / B 함께 추가. 이슈 범위는 세션 진행 중 재생이다. 복기용 재생은 문항별 상세 응답(`InterviewAnswerQueryService`)을 따로 바꿔야 해 후속 이슈로 둔다

## 검증
- 대상 테스트: `InterviewSessionQueryServiceIntegrationTest.GetQuestions`
  - `음성_키가_있는_문항은_서명된_재생_URL을_돌려준다`: 출제 문항에 `audioKey`를 설정(`ReflectionTestUtils`) → `audioUrl`이 키를 포함하고 `X-Amz-Signature=`, `X-Amz-Expires=1800`를 포함 (`InterviewAudioUploadServiceIntegrationTest` 선례)
  - `음성_키가_없는_문항은_재생_URL이_null이다`
  - 기존 `문항_번호_오름차순으로_본문을_돌려준다`, `모든_상태에서_조회할_수_있다`, 예외 2건은 그대로 통과해야 한다
- `./gradlew build`(전체 테스트, `flywayCi`)
- dev 배포 후 수동: 문항 목록 조회 → `audioUrl` 하나를 브라우저에서 열어 재생(IAM 권한 확인 겸)

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
- `.claude/spec/service-policy/interview.md`: P11 문구를 계획의 "재생용 다운로드 URL 미발급(답변 음성)" 대신 "미발급(답변 음성. 질문 음성은 세션 문항 조회에서 발급, 결과 화면 문항별 상세는 미발급)"으로 씀 — 이유: 결정 D3(결과 화면 제외)로 질문 음성도 결과 화면에서는 아직 미발급이라, 계획 문구대로 쓰면 질문 음성 재생이 모두 해결된 것처럼 읽힌다
