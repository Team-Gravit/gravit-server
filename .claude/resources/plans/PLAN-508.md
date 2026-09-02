# [PLAN-508] 면접 답변 LLM 채점 판정 연동

> 이슈: #508
> 브랜치: feat/508-interview-llm-grading

## 목표
Spring AI로 LiteLLM 게이트웨이(OpenAI 호환 API)에 연결해, 질문과 핵심 개념, 답변을 보내면 개념별 전달/누락 판정 응답을 구조화해 받는 것까지 검증한다. 점수 계산, 채점 결과 저장, 세션 상태 전이는 범위 밖이다(서비스 정책 "채점 판정은 AI가 하고 점수 계산은 고정 규칙으로 한다"의 AI 판정 부분만).

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/global/config/AiConfig.java` - 자동 구성된 `ChatModel`로 `ChatClient` 빈 생성
- `src/main/java/gravit/code/interviewFeedback/infrastructure/InterviewGradingClient.java` - 채점 프롬프트 조립, LLM 호출, 구조화 판정 파싱 (외부 연동)
- `src/main/java/gravit/code/interviewFeedback/service/InterviewGradingService.java` - 판정 요청 진입점 (Controller → Service → infrastructure 레이어 흐름 유지)
- `src/main/java/gravit/code/interviewFeedback/dto/internal/InterviewGradingSource.java` - 판정 입력 내부 DTO
- `src/main/java/gravit/code/interviewFeedback/dto/internal/InterviewGradingJudgment.java` - 판정 결과 내부 DTO (LLM 구조화 출력 바인딩 대상)
- `src/main/java/gravit/code/test/interview/TestInterviewGradingController.java` - [QA 전용] 채점 판정 테스트 API (`@Profile("!prod")`)
- `src/main/java/gravit/code/test/interview/docs/TestInterviewGradingControllerDocs.java` - 테스트 API Swagger 문서
- `src/main/java/gravit/code/test/interview/dto/request/TestInterviewGradingRequest.java` - 테스트 요청 DTO
- `src/main/java/gravit/code/test/interview/dto/response/TestInterviewGradingResponse.java` - 테스트 응답 DTO

### 수정 파일
- `build.gradle` - Spring AI BOM 1.1.8 + `spring-ai-starter-model-openai` 의존성 추가 (2.0.x는 Spring Boot 4 전용이라 1.1.x 사용)
- `src/main/resources/application.yml` (local 프로파일) - `spring.ai.openai` 접속 설정 (base-url: `http://codex-llm:4000`, tailscale 경유)
- `src/main/resources/application-dev.yml` - base-url `http://litellm-gw:4000` (llm-net 도커 네트워크), api-key는 기동 보장용 더미 기본값
- `src/main/resources/application-prod.yml` - dev와 동일 형태. 실제 키 주입(GitHub Secrets, variable-substitution)은 후속 작업으로 분리
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `// Interview` 그룹에 판정 실패 에러코드 추가

## 구현 계획
> 레이어 순. Entity, Flyway, Repository 변경 없음 (DB를 읽지도 쓰지도 않는 판정 전용 작업).

1. **Entity / Flyway**: 변경 없음
2. **Repository**: 변경 없음
3. **의존성 / 설정**:
   - `build.gradle`:
     ```gradle
     // Spring AI (LLM 게이트웨이 연동)
     implementation platform('org.springframework.ai:spring-ai-bom:1.1.8')
     implementation 'org.springframework.ai:spring-ai-starter-model-openai'
     ```
   - `application.yml` (local):
     ```yaml
     spring:
       ai:
         openai:
           base-url: http://codex-llm:4000
           api-key: ${LITELLM_MASTER_KEY:changeme}
           chat:
             options:
               model: codex-terra
     ```
     - base-url에 `/v1`을 붙이지 않는다. Spring AI가 기본 completions-path `/v1/chat/completions`를 덧붙인다
     - temperature 등 샘플링 옵션은 설정하지 않는다. 파라미터 정리는 LiteLLM이 담당한다 (`drop_params: true`)
     - 모델 별칭은 LiteLLM config의 `codex-terra`(균형, 기본 권장). 배포 후 `GET /v1/models`로 슬러그 재확인 필요(게이트웨이 config 주석)
   - `application-dev.yml` / `application-prod.yml`: base-url `http://litellm-gw:4000`, api-key `${LITELLM_MASTER_KEY:dummy}`, model은 local과 동일. 더미 기본값은 스타터가 클래스패스에 있으면 api-key 부재 시 기동이 실패하는 것을 막기 위한 것으로, 실제 호출은 키 주입 전까지 실패한다 (후속: secret-convention에 따라 `LITELLM_MASTER_KEY` 시크릿 등록과 CD 주입)
4. **Config**: `AiConfig`
   - `@Bean public ChatClient chatClient(ChatModel chatModel)` - `ChatClient.create(chatModel)` 반환
5. **Infrastructure**: `InterviewGradingClient` (`@Component` + `@RequiredArgsConstructor`, `ChatClient` 주입)
   - `public InterviewGradingJudgment judge(InterviewGradingSource source)`
     - 시스템 프롬프트: `private static final String SYSTEM_PROMPT` 텍스트 블록. 역할(면접 채점관), 판정 규칙을 담는다:
       - 핵심 개념 목록의 각 개념에 대해 전달/누락 판정. 전달이면 답변 원문에서 근거 구간(quote) 인용, 누락이면 무엇이 빠졌는지 안내 문구 생성 (정책: "인정 기준과 누락 안내 문구는 채점 시점에 AI가 판단하고 생성한다")
       - 잘못 말한 구간은 원문 인용(quotedText)과 교정 문장(correctionText) 생성
       - 결론을 먼저 말했는지 판정 (조리 - 구조성)
       - 군더더기 발화 개수 판정 (조리 - 명료성)
       - 종합 개선 제안 1개 생성
       - 모든 생성 문구는 한국어
     - 사용자 메시지: 질문 content, 개념 목록(이름 + ESSENTIAL/SUPPLEMENTARY 구분), 답변 content를 조립하는 private 메서드로 구성
     - 호출: `chatClient.prompt().system(SYSTEM_PROMPT).user(userMessage).call().entity(InterviewGradingJudgment.class)` - BeanOutputConverter가 JSON 스키마 지시를 프롬프트에 덧붙이고 응답을 record로 역직렬화한다 (response_format 미사용이라 게이트웨이 호환성 문제 없음)
     - 호출 실패, 파싱 실패 시: `RuntimeException`을 잡아 `throw new RestApiException(CustomErrorCode.INTERVIEW_GRADING_FAILED)`. 원인 로그는 `log.error`로 남긴다
6. **Service**: `InterviewGradingService` (`@Service` + `@RequiredArgsConstructor`)
   - `public InterviewGradingJudgment judge(InterviewGradingSource source)` - `interviewGradingClient.judge(source)` 위임. DB 접근이 없어 `@Transactional` 미부착
7. **Facade**: 불필요 - 단일 도메인 Service
8. **DTO**:
   - `InterviewGradingSource` (internal record):
     - `String question`, `List<Concept> concepts`, `String answer`
     - 중첩 record `Concept(String name, InterviewConceptType type)`
   - `InterviewGradingJudgment` (internal record, LLM 출력 바인딩이라 정적 팩토리 없이 표준 생성자 사용):
     - `List<ConceptJudgment> conceptJudgments` - 중첩 record `ConceptJudgment(String conceptName, boolean covered, String quote, String missingFeedbackText)` → `InterviewAnswerConceptResult` 필드와 대응
     - `List<WrongStatement> wrongStatements` - 중첩 record `WrongStatement(String quotedText, String correctionText)` → `InterviewAnswerWrongConcept` 필드와 대응
     - `boolean conclusionFirst` - 조리 - 구조성 판정 기준
     - `int irrelevantStatementCount` - 조리 - 명료성 차감 근거 (`InterviewFeedback.irrelevantStatementCount` 대응)
     - `String improvementSuggestion` (`InterviewFeedback.improvementSuggestion` 대응)
   - `TestInterviewGradingRequest` (record, `@Schema` + validation):
     - `@NotBlank String question`, `@NotEmpty @Valid List<ConceptRequest> concepts`, `@NotBlank String answer`
     - 중첩 record `ConceptRequest(@NotBlank String name, @NotNull InterviewConceptType type)`
     - `toSource()` 메서드로 `InterviewGradingSource` 변환
   - `TestInterviewGradingResponse` (record, 정적 팩토리 `from(InterviewGradingJudgment)`) - 판정 필드를 그대로 노출
9. **Controller**: `TestInterviewGradingController` (`@Profile("!prod")`, `@RequestMapping("/api/v1/test")`, Docs 인터페이스 implements)
   - `POST /api/v1/test/interview/grading → gradeAnswer(@Valid @RequestBody TestInterviewGradingRequest request)` - `ResponseEntity.status(HttpStatus.OK).body(TestInterviewGradingResponse.from(...))`
   - 인증: `/api/v1/test/**`는 SecurityConfig에서 permitAll, JwtAuthFilter 제외 경로라 추가 설정 불필요
10. **에러코드**: `CustomErrorCode`의 `// Interview` 그룹에 추가
    - `INTERVIEW_GRADING_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "INTERVIEW_5001", "면접 답변 채점 판정 요청이 실패했습니다.")`

## 결정 필요 (Decisions needed)
- [x] LiteLLM에 등록된 모델 별칭 - `codex-terra` (사용자 공유 LiteLLM config에서 "균형, 기본 권장"으로 확정)
- [x] 로컬 api-key 전달 방식 - 환경변수 `LITELLM_MASTER_KEY` 주입 (게이트웨이 `general_settings.master_key`와 같은 환경변수명, yml에는 `${LITELLM_MASTER_KEY:changeme}` placeholder만)

## 검증
- 로컬 기동(`./gradlew bootRun`, tailnet 연결 상태) 후 Swagger 또는 curl로 `POST /api/v1/test/interview/grading` 호출:
  - gravit-interview-contents-generator가 생성한 질문 + 핵심 개념 + 직접 작성한 답변으로 판정 응답(개념별 전달/누락, 잘못된 개념, 구조성/명료성, 개선 제안)이 구조화되어 오는지 확인
  - 개념을 일부만 언급한 답변, 틀린 내용을 포함한 답변 케이스로 판정 품질 확인
- 자동화 테스트는 이번 범위에서 작성하지 않는다 (LLM 실호출 검증이 목적)

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
- `application.yml`: local 프로파일 api-key를 환경변수 주입에서 평문 기재로 변경 - 이유: 사용자 지시 (repo local 프로파일의 기존 평문 관행에 맞춤)
