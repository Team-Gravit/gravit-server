# [PLAN-523] 면접 세션 시작과 중단 API 구현

> 이슈: #523
> 브랜치: feat/523-interview-session-start (base: dev)
>
> #521이 `7b54904d`로 dev에 머지되어 rebase를 마쳤다(로컬 커밋이 없어 fast-forward, 이력 재작성 없음). 착수 전제였던 `InterviewSessionController`, `InterviewSessionCommandService`, `InterviewSessionQueryService`, `InterviewQuestionQueryService`, `InterviewSessionStatusResponse`, `InterviewSession.validateInProgress()`, 에러코드 4013~4015가 모두 dev에 있다. 에러코드는 4015까지만 차서 이 계획의 4016~4020 자리가 그대로 유효하다.

## 목표
`interview.md`의 모드, 주제 태그, 스택, 난이도, 입력 방식, 세션 생성, 출제, 취소 정책을 구현한다. 사용자가 선택지를 받아 세션을 만들고, 확정된 5문항을 받아 풀고, 음성 모드면 문항별 음성 원본을 올리고, 필요하면 중단하기까지 제출 이전 단계의 API 7개를 구현한다. 제출과 채점(#520), 결과 조회(#517)는 이미 있고 이 이슈가 그 앞단을 채운다.

음성 원본은 서버를 거치지 않고 presigned URL로 S3에 직접 올린다. 키 형식을 정하는 것이 이 이슈이므로, 제출 시 음성 키를 검증하는 미구현 자리(#520의 `validateAudioKeys`)도 여기서 함께 닫는다.

### API 계약

| 메서드 | 경로 | 요청 | 응답 | 상태 |
|---|---|---|---|---|
| GET | `/api/v1/interview-topics` | - | `[{ topic, displayName }]` | 200 |
| GET | `/api/v1/interview-stack-groups` | - | `[{ stackGroup, displayName }]` | 200 |
| GET | `/api/v1/interview-stack-groups/{stackGroup}/stacks` | `stackGroup` (PathVariable) | `[{ stack, displayName }]` | 200 |
| POST | `/api/v1/interview-sessions` | `{ inputType, mode, difficulty, stack, topics }` | `{ sessionId }` | 201 |
| GET | `/api/v1/interview-sessions/{sessionId}/questions` | `sessionId` (PathVariable) | `{ sessionId, questions: [{ displayOrder, content }] }` | 200 |
| POST | `/api/v1/interview-sessions/{sessionId}/audio-uploads` | `{ displayOrder, contentType }` | `{ audioKey, uploadUrl, expiresAt }` | 200 |
| PATCH | `/api/v1/interview-sessions/{sessionId}/abandon` | `sessionId` (PathVariable) | `{ sessionId, status: "ABANDONED" }` | 200 |

- 주제 목록은 CS 종류 태그 5개만 나간다. 나머지 18개는 스택을 통해서만 출제된다
- 스택 목록은 그룹별 노출 순서 오름차순이다. 그룹 목록도 노출 순서 오름차순이다
- 세 목록 조회는 콘텐츠 충족 여부를 반영하지 않고 열거형 전체를 그대로 내린다 (P8)
- 세션 생성 응답은 식별자만 담는다 (`facade.md` 쓰기 응답 규칙). 문제는 별도 조회 API로 받는다
- 중단 응답은 제출, 상태 조회와 같은 `InterviewSessionStatusResponse`를 재사용한다
- 업로드 URL 발급은 리소스를 만들지 않고 서명만 돌려주므로 201이 아니라 200이다. 진행 중인 음성 세션에만, 문항 하나씩 발급한다
- 발급 응답에 `audioKey`를 함께 내린다. 클라이언트가 업로드 후 제출 본문에 그대로 실어야 하는데, URL에서 파싱하게 하면 서명 파라미터와 섞인다

## 배치 기준

- **의존 방향은 `interviewFeedback -> interview -> interviewQuestion`이다** (PLAN-517, PLAN-520 기준). `InterviewMode`, `InterviewStack`, `InterviewStackGroup`은 `interview/domain/`에, `InterviewTopic`, `InterviewTopicKind`, `InterviewDifficulty`는 `interviewQuestion/domain/`에 있다. 따라서 **`interviewQuestion`은 모드도 스택도 몫도 알면 안 된다.** 배분과 선별은 전부 `interview/`가 하고, `interviewQuestion/`은 태그와 난이도로 거른 문제 풀만 돌려준다
- **세션 생성만 Facade를 쓴다.** `interviewQuestion`의 문제 풀 조회와 `interview`의 세션 저장 두 도메인 서비스를 조합하기 때문이다 (`facade.md`). 나머지 6개는 단일 도메인이라 컨트롤러가 서비스를 직접 주입한다
- **세션 생성 Facade에 `TransactionTemplate`을 두지 않는다.** 문제 풀 조회는 사전 조회라 경계 밖이고, 쓰기는 `InterviewSessionCommandService.create()` 한 번뿐이다. `facade.md`의 "단일 서비스 위임뿐인 Facade 메서드에는 경계를 만들지 마라"에 해당한다
- **출제 정책 전부를 `interview/policy/InterviewQuestionAllocationPolicy`가 맡는다.** 모드 조합 검증, 태그별 배분, 태그별 무작위 선별, 풀 부족 판정, 문항 순서까지다. `interviewFeedback/policy/InterviewScoringPolicy` 선례를 따라 `@Component`로 두며, 그 선례가 `interviewQuestion.domain.InterviewQuestionConcept`를 인자로 받듯 이쪽도 `InterviewQuestionPoolDto`를 인자로 받는다
- **선별을 `InterviewQuestionQueryService`에 두지 않는 이유는 문항 순서의 정확성 때문이다.** 직군 모드의 문항 순서는 배분 맵의 순회 순서에 의존한다. 선별을 다른 클래스에 두면 그 클래스가 `LinkedHashMap`을 돌려준다는 약속에 순서 정확성이 걸리는데, 이 자리의 자연스러운 구현인 `Collectors.groupingBy`는 맵 팩토리를 주지 않으면 기본이 `HashMap`이다. 빠뜨려도 컴파일되고, 공통 CS는 어차피 셔플하니 멀쩡하고, 직군 순서만 조용히 어긋난다. 배분과 선별과 순서가 한 클래스에 있으면 이 불변식이 내부로 들어와 사라진다. `InterviewQuestionQueryService`의 기존 두 메서드가 모두 순수 조회라는 점과도 맞는다
- **문제 목록 조회는 단일 JPQL 조인 프로젝션이다.** `InterviewAnswerRepository`에 두어 `interview -> interviewQuestion` 방향을 지킨다. 반대로 `InterviewQuestionRepository`에 두면 방향이 뒤집힌다
- **컨트롤러는 3개다.** 주제는 태그의 주인인 `interviewQuestion/controller/InterviewTopicController`, 스택 그룹은 `interview/controller/InterviewStackGroupController`, 세션 4개(생성, 문제 목록, 업로드 URL, 중단)는 기존 `interview/controller/InterviewSessionController`에 메서드를 더한다
- **음성 키는 세션과 문항에서 결정적으로 만든다.** `interview/{sessionId}/{displayOrder}.{확장자}` 형식이라 제출 때 같은 규칙으로 다시 만들어 대조하면 "발급된 세션과 문항에 일치하는가"가 판정된다. **발급 대장을 저장하지 않는다.** 랜덤 키를 쓰면 Redis나 테이블에 발급 기록을 두고 정리까지 책임져야 하는데, 재녹음이 없어 문항당 오브젝트가 하나뿐인 이 정책에서 그 대장은 키 자체와 같은 정보만 담는다. #520의 `InterviewAnswerSubmitRequest`가 이미 `interview/12/1.m4a`를 예시로 적어둔 형식이기도 하다
- **키 발급과 키 검증은 같은 컴포넌트(`interview/policy/InterviewAudioKeyPolicy`)에 둔다.** 형식을 발급 측과 제출 측이 각자 만들면 어긋나는 순간 제출이 통째로 막힌다
- **S3 접근은 `interview/infrastructure/InterviewAudioStorage`가 감싼다.** `interviewFeedback/infrastructure/InterviewGradingClient`가 `ChatClient`를 감싸는 것과 같은 자리다. `S3Presigner` 빈은 `global/config/S3Config`에 두어 `AiConfig`의 `ChatClient` 등록과 위치를 맞춘다
- **음성은 면접 전용이므로 `interview/`에 둔다.** 다른 도메인이 오브젝트 스토리지를 쓰기 시작하면 그때 `global/`로 올린다. 지금 올리면 쓰는 곳이 하나뿐인 추상을 먼저 만드는 셈이다
- **목록 조회 서비스에는 트랜잭션 어노테이션을 붙이지 않는다.** DB를 타지 않는 열거형 조회라 `readOnly` 트랜잭션은 커넥션만 잡는다. `service.md`의 "조회 메서드에 `@Transactional(readOnly = true)`"에서 벗어나는 유일한 지점이며 이유를 여기 남긴다
- **rebase는 끝났다.** #521이 머지되어 `origin/dev`(`7b54904d`) 위에 올라와 있다. 착수 전제가 전부 충족됐다
- **제출 시 음성 키 검증은 정책이 이미 이 이슈로 지정해뒀다.** #521이 `interview.md`에 "음성 키 발급 기능이 없는 동안은 음성 세션이 보낸 키를 검증 없이 그대로 저장한다. 형식과 일치 검증은 발급 기능(P11)과 함께 붙인다"를 넣어뒀다. 이 이슈가 발급 기능을 만들므로 그 유예 조항을 걷어내고 검증을 붙이는 것이 정책이 지시한 순서다

## 영향 범위

### 신규 파일

**interview/ (세션 생성, 문제 조회, 중단, 스택 선택지)**
- `src/main/java/gravit/code/interview/controller/InterviewStackGroupController.java` - 그룹 목록, 그룹별 스택 목록 엔드포인트
- `src/main/java/gravit/code/interview/controller/docs/InterviewStackGroupControllerDocs.java` - Swagger 문서 인터페이스
- `src/main/java/gravit/code/interview/service/InterviewStackQueryService.java` - 그룹과 스택 열거형 조회
- `src/main/java/gravit/code/interview/facade/InterviewSessionFacade.java` - 배분, 선별, 저장을 조합하는 세션 생성
- `src/main/java/gravit/code/interview/policy/InterviewQuestionAllocationPolicy.java` - 모드 조합 검증, 태그별 배분, 무작위 선별, 풀 부족 판정, 문항 순서
- `src/main/java/gravit/code/interview/dto/request/InterviewSessionCreateRequest.java` - `{ inputType, mode, difficulty, stack, topics }`
- `src/main/java/gravit/code/interview/dto/response/InterviewSessionCreateResponse.java` - `{ sessionId }`
- `src/main/java/gravit/code/interview/dto/response/InterviewStackGroupResponse.java` - `{ stackGroup, displayName }`
- `src/main/java/gravit/code/interview/dto/response/InterviewSessionQuestionResponse.java` - `{ displayOrder, content }`
- `src/main/java/gravit/code/interview/dto/response/InterviewSessionQuestionsResponse.java` - `{ sessionId, questions }`
- `src/main/java/gravit/code/interview/dto/internal/InterviewSessionQuestionDto.java` - 조인 프로젝션 `{ displayOrder, content }`
- `src/main/java/gravit/code/interview/dto/internal/InterviewSessionCreateDto.java` - Facade가 조립해 서비스에 넘기는 세션 생성 입력

**interview/ (음성 업로드)**
- `src/main/java/gravit/code/interview/domain/InterviewAudioFormat.java` - 허용 포맷과 확장자 매핑
- `src/main/java/gravit/code/interview/policy/InterviewAudioKeyPolicy.java` - 음성 키 발급 형식과 검증
- `src/main/java/gravit/code/interview/infrastructure/InterviewAudioStorage.java` - presigned PUT URL 발급
- `src/main/java/gravit/code/interview/service/InterviewAudioUploadService.java` - 세션 검증 후 URL 발급
- `src/main/java/gravit/code/interview/dto/request/InterviewAudioUploadRequest.java` - `{ displayOrder, contentType }`
- `src/main/java/gravit/code/interview/dto/response/InterviewAudioUploadResponse.java` - `{ audioKey, uploadUrl, expiresAt }`
- `src/main/java/gravit/code/interview/dto/internal/InterviewAudioUploadDto.java` - `{ uploadUrl, expiresAt }`
- `src/main/java/gravit/code/global/config/S3Config.java` - `S3Presigner` 빈 등록

**interviewQuestion/ (주제 선택지, 문제 풀 조회)**
- `src/main/java/gravit/code/interviewQuestion/controller/InterviewTopicController.java` - CS 주제 목록 엔드포인트
- `src/main/java/gravit/code/interviewQuestion/controller/docs/InterviewTopicControllerDocs.java` - Swagger 문서 인터페이스
- `src/main/java/gravit/code/interviewQuestion/service/InterviewTopicQueryService.java` - CS 종류 태그 조회
- `src/main/java/gravit/code/interviewQuestion/dto/internal/InterviewQuestionPoolDto.java` - 문제 풀 프로젝션 `{ topic, questionId }`

**test**
- `src/test/java/gravit/code/interviewQuestion/fixture/InterviewQuestionFixture.java` - 태그, 난이도, 활성 여부를 지정하는 문제 픽스처
- `src/test/java/gravit/code/interview/policy/InterviewQuestionAllocationPolicyIntegrationTest.java`
- `src/test/java/gravit/code/interview/facade/InterviewSessionFacadeIntegrationTest.java`
- `src/test/java/gravit/code/interviewQuestion/service/InterviewTopicQueryServiceIntegrationTest.java`
- `src/test/java/gravit/code/interview/service/InterviewStackQueryServiceIntegrationTest.java`
- `src/test/java/gravit/code/interview/policy/InterviewAudioKeyPolicyIntegrationTest.java`
- `src/test/java/gravit/code/interview/service/InterviewAudioUploadServiceIntegrationTest.java`

### 수정 파일
- `src/main/java/gravit/code/interview/domain/InterviewSession.java` - `abandon(LocalDateTime endedAt)` 추가 (필드, 생성자, `create`는 손대지 않는다)
- `src/main/java/gravit/code/interview/repository/InterviewSessionRepository.java` - 시도 차수 채번 쿼리 추가
- `src/main/java/gravit/code/interview/repository/InterviewAnswerRepository.java` - 세션 문제 목록 조인 프로젝션 추가
- `src/main/java/gravit/code/interviewQuestion/repository/InterviewQuestionRepository.java` - 태그, 난이도별 활성 문제 풀 조회 추가
- `src/main/java/gravit/code/interview/service/InterviewSessionCommandService.java` - `create()`, `abandon()` 추가, `validateAudioKeys()`를 VOICE 세션까지 확장
- `src/main/java/gravit/code/interview/service/InterviewSessionQueryService.java` - `getQuestions()` 추가
- `src/main/java/gravit/code/interviewQuestion/service/InterviewQuestionQueryService.java` - `getPool()` 추가 (기존 두 메서드처럼 순수 조회)
- `src/main/java/gravit/code/interview/controller/InterviewSessionController.java` - 생성, 문제 목록, 업로드 URL, 중단 엔드포인트 추가, Facade 주입
- `src/main/java/gravit/code/interview/controller/docs/InterviewSessionControllerDocs.java` - 위 4개 문서 추가, `@Tag` 설명 갱신
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - 스택 에러코드 2개 개명, 주제 에러코드 3개와 음성 에러코드 2개 추가
- `src/test/java/gravit/code/interview/fixture/InterviewSessionFixture.java` - 세션 생성 요청 픽스처 추가
- `src/test/java/gravit/code/interview/service/InterviewSessionCommandServiceIntegrationTest.java` - 중단, 음성 키 검증 시나리오 추가
- `src/test/java/gravit/code/interview/service/InterviewSessionQueryServiceIntegrationTest.java` - 문제 목록 시나리오 추가

**빌드, 설정, 배포 (음성 업로드)**
- `build.gradle` - AWS SDK v2 S3 의존성 추가
- `src/main/resources/application-local.yml`, `application-dev.yml`, `application-prod.yml` - `aws.s3` 블록 추가
- `src/test/resources/application-test.yml` - 더미 자격증명 추가
- `.github/workflows/cd-dev.yml`, `cd-prod.yml` - `variable-substitution` 단계에 S3 시크릿 3종 주입 추가
- `.claude/spec/secret-convention.md` - "환경별로 분리된 값" 표에 S3 시크릿 3종 추가
- `.claude/spec/service-policy/interview.md` - 입력 방식 절에 음성 업로드 방식 확정, **답변 제출 절의 음성 키 검증 유예 조항(99행) 삭제**, P11 표 갱신

> **DB 변경 없음.** V41 스키마를 그대로 쓴다. 문제 풀 조회는 `ix_interview_question_topic_difficulty`, 시도 차수 채번은 `ix_interview_session_user_started`의 선두 컬럼, 문제 목록 조회는 `uq_interview_answer_session_order`가 각각 받는다. 음성 키는 `interview_answer.audio_key`(VARCHAR(255))에 그대로 들어가고 `interview/{sessionId}/{displayOrder}.{확장자}`는 길이가 30자를 넘지 않는다.
>
> **정책 문서 변경 있음.** 모드, 주제 태그, 스택, 난이도, 세션 생성, 출제, 취소 절은 이번 구현을 이미 전부 규정하며 손대지 않는다. 다만 음성 업로드는 `interview.md`가 "음성 원본은 문항별로 업로드되어 제출 시 답안에 연결된다"까지만 적고 **어떻게 올리는지를 P11로 미뤄둔 자리**다. presigned URL 방식, 키 형식, 만료, 허용 포맷을 이 이슈에서 확정하므로 입력 방식 절과 P11 표를 갱신한다.
>
> **인프라 선행 작업 있음.** 이 저장소에는 오브젝트 스토리지 연동이 하나도 없다(AWS SDK 의존성 없음, 파일 업로드 코드 0건). 버킷 생성, CORS, IAM, GitHub Secrets 등록이 배포 전에 끝나야 하며 절 1에 적었다.

## 구현 계획

### 1. 의존성과 설정

**`build.gradle`**

```gradle
// Object Storage (면접 음성 원본)
implementation platform('software.amazon.awssdk:bom:{최신 안정 버전}')
implementation 'software.amazon.awssdk:s3'
```

`S3Presigner`는 `software.amazon.awssdk:s3` 아티팩트의 `services.s3.presigner` 패키지에 들어 있다. 별도 모듈이 필요 없다. 이 프로젝트의 의존성은 전부 버전을 고정하므로 BOM 버전도 착수 시점에 Maven Central에서 최신 안정판을 확인해 박아 넣는다.

**`application-{local,dev,prod}.yml`**

```yaml
aws:
  s3:
    region: ap-northeast-2
    bucket: ${S3_INTERVIEW_AUDIO_BUCKET}
    access-key: ${S3_ACCESS_KEY}
    secret-key: ${S3_SECRET_KEY}
    upload-expiry: 10m
```

만료 10분은 문항 하나의 발화 2분에 재시도와 네트워크 지연을 더한 값이다. 발급이 문항별 온디맨드라 세션 전체 소요 시간을 감당할 필요가 없다.

**`application-test.yml`** (더미 값)

```yaml
aws:
  s3:
    region: ap-northeast-2
    bucket: test-interview-audio
    access-key: test-access-key
    secret-key: test-secret-key
    upload-expiry: 10m
```

Spring AI 스타터에 더미 `api-key`를 두는 것과 같은 이유로 기동을 보장한다. 다만 여기엔 이점이 하나 더 있다. **`S3Presigner.presignPutObject`는 네트워크 호출이 아니라 로컬 서명 계산이다.** 그래서 더미 자격증명으로도 진짜 URL이 만들어지고, 통합 테스트가 AWS 없이 발급 로직을 그대로 검증한다. `StubInterviewGradingClient` 같은 대역을 만들 필요가 없다.

**GitHub Secrets** (`secret-convention.md`의 "환경별로 분리된 값" 표에 추가)

| 시크릿 | dev | prod |
|---|---|---|
| 음성 버킷 | `DEV_S3_INTERVIEW_AUDIO_BUCKET` | `PROD_S3_INTERVIEW_AUDIO_BUCKET` |
| S3 액세스 키 | `DEV_S3_ACCESS_KEY` | `PROD_S3_ACCESS_KEY` |
| S3 시크릿 키 | `DEV_S3_SECRET_KEY` | `PROD_S3_SECRET_KEY` |

처음부터 환경별로 나눈다. dev와 prod가 같은 버킷을 보면 개발 중 녹음이 운영 데이터에 섞이고, 나중에 분리하려면 이미 쌓인 오브젝트를 옮겨야 한다. `cd-dev.yml`, `cd-prod.yml`의 `variable-substitution` 단계에 `aws.s3.bucket`, `aws.s3.access-key`, `aws.s3.secret-key` 세 줄을 더한다.

**버킷 설정** (코드 밖 인프라 작업, 배포 전 선행)

- 퍼블릭 액세스를 전면 차단한다. 오브젝트는 presigned URL로만 읽고 쓴다. 키가 추측 가능한 형식인 것은 이 전제 위에서만 안전하다
- CORS에 `PUT`과 앱 오리진을 등록한다. 브라우저가 S3로 직접 PUT하므로 없으면 업로드가 전부 막힌다. **가장 빠뜨리기 쉬운 항목이다**
- IAM 정책은 해당 버킷의 `s3:PutObject`, `s3:GetObject`로만 한정한다. presigned URL의 권한은 서명한 자격증명의 권한을 넘지 못하므로, 여기가 넓으면 URL이 새는 순간 피해가 커진다

### 2. Entity / Enum

DB 변경 없음.

**`InterviewSession`** (추가만)

```java
public void abandon(LocalDateTime endedAt)
    // validateInProgress() -> INTERVIEW_SESSION_NOT_IN_PROGRESS (기존 private 메서드 재사용)
    // status = ABANDONED, this.endedAt = endedAt
```

`startGrading`과 같은 모양이지만 `gradingAttemptCount`는 건드리지 않는다. 취소는 채점 시도가 아니다.

**`interview/domain/InterviewAudioFormat`** (신규 열거형)

```java
M4A("audio/m4a", "m4a"),
MP4("audio/mp4", "m4a"),
WEBM("audio/webm", "webm"),
MPEG("audio/mpeg", "mp3");

private final String contentType;
private final String extension;

public static InterviewAudioFormat from(String contentType)
    // 미허용 -> INTERVIEW_AUDIO_FORMAT_UNSUPPORTED

public static boolean hasExtension(String extension)
    // 제출 시 키 검증용
```

iOS는 m4a, Android와 Web은 webm이 기본 녹음 포맷이라 둘은 반드시 받는다. `MP4`와 `M4A`가 같은 확장자로 떨어지는 것은 의도한 것이다. 컨테이너가 같고 클라이언트마다 신고하는 MIME만 다르다.

**요청은 이 열거형이 아니라 MIME 문자열로 받는다.** 열거형으로 직접 바인딩하면 오타 하나가 `HttpMessageNotReadableException`이 되는데, 이 프로젝트의 `GlobalExceptionHandler`에는 그 핸들러가 없어 500 `GLOBAL_5001`로 나간다. 문자열로 받아 `from()`이 판정하면 400 도메인 에러코드로 나간다.

### 3. Repository

**`InterviewQuestionRepository`** (추가)

```java
@Query("""
        SELECT new gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolDto(q.topic, q.id)
        FROM InterviewQuestion q
        WHERE q.topic IN :topics AND q.difficulty = :difficulty AND q.active = true
""")
List<InterviewQuestionPoolDto> findPoolByTopicsAndDifficulty(
        @Param("topics") Collection<InterviewTopic> topics,
        @Param("difficulty") InterviewDifficulty difficulty
);
```

본문, 모범답안, 개념을 싣지 않는다. 선별에는 태그와 id만 필요하고 문제 본문은 목록 조회 API가 따로 읽는다.

**`InterviewSessionRepository`** (추가)

```java
@Query("""
        SELECT COALESCE(MAX(s.attemptCount), 0)
        FROM InterviewSession s
        WHERE s.userId = :userId
""")
long findMaxAttemptCountByUserId(@Param("userId") long userId);
```

`COUNT + 1`이 아니라 `MAX + 1`이다. 차수는 생성 순번이고 행이 지워져도 되감기면 안 된다.

**`InterviewAnswerRepository`** (추가)

```java
@Query("""
        SELECT new gravit.code.interview.dto.internal.InterviewSessionQuestionDto(a.displayOrder, q.content)
        FROM InterviewAnswer a JOIN InterviewQuestion q ON q.id = a.questionId
        WHERE a.sessionId = :sessionId
        ORDER BY a.displayOrder ASC
""")
List<InterviewSessionQuestionDto> findQuestionsBySessionId(@Param("sessionId") long sessionId);
```

답안과 문제는 연관관계 매핑이 없는 plain ID라 `ON` 조인을 명시한다.

### 4. Policy

**`interview/policy/InterviewQuestionAllocationPolicy`** (`@Component`)

```java
private static final Map<Integer, List<Integer>> CS_QUOTAS_BY_TOPIC_COUNT = Map.of(
        1, List.of(5),
        2, List.of(3, 2),
        3, List.of(2, 2, 1),
        4, List.of(2, 1, 1, 1),
        5, List.of(1, 1, 1, 1, 1)
);
private static final int JOB_COMMON_QUOTA = 1;
private static final int JOB_LANGUAGE_QUOTA = 2;
private static final int JOB_FRAMEWORK_QUOTA = 2;
private static final int MAX_CS_TOPIC_COUNT = 5;

public Map<InterviewTopic, Integer> allocate(
        InterviewMode mode,
        InterviewStack stack,
        List<InterviewTopic> topics
)
```

`allocate`가 모드 조합 검증과 배분을 함께 한다. 반환은 `LinkedHashMap`이며 **키 집합이 곧 `interview_session_topic`에 남길 주제 목록**이다. 공통 CS는 고른 주제, 직군은 스택 구성 태그 3개가 그대로 키가 되어 정책의 "세션의 주제는 공통 CS는 고른 주제, 직군은 스택 구성 태그 3개로 기록한다"를 별도 분기 없이 만족한다.

- `mode == COMMON_CS`
  - `stack != null` -> `INTERVIEW_STACK_NOT_ALLOWED`
  - `topics == null || topics.isEmpty()` -> `INTERVIEW_TOPIC_REQUIRED`
  - `topics.size() > MAX_CS_TOPIC_COUNT`, 중복 존재, `topic.getKind() != InterviewTopicKind.CS`인 태그 존재 -> `INTERVIEW_TOPIC_INVALID`
  - 배분: `topics`를 복사해 `Collections.shuffle` 한 뒤 `CS_QUOTAS_BY_TOPIC_COUNT.get(size)`의 몫을 순서대로 매긴다. 셔플이 "3문항을 받을 주제는 랜덤"을 만든다
- `mode == JOB_SPECIFIC`
  - `stack == null` -> `INTERVIEW_STACK_REQUIRED`
  - `topics != null && !topics.isEmpty()` -> `INTERVIEW_TOPIC_NOT_ALLOWED`
  - 배분: `stack.getCommonTopic()` 1, `stack.getLanguageTopic()` 2, `stack.getFrameworkTopic()` 2를 이 순서로 넣는다. 스택의 세 태그는 종류가 달라 항상 서로 다르므로 키 충돌이 없다

```java
public List<Long> select(
        InterviewMode mode,
        Map<InterviewTopic, Integer> topicToQuota,
        List<InterviewQuestionPoolDto> pool
)
```

`display_order` 1부터 5까지에 놓을 문제 id를 순서대로 만든다. 선별과 순서를 한 메서드가 맡는다.

1. `pool`을 태그별로 묶는다
2. 태그마다 `Collections.shuffle` 후 몫만큼 take한다. 어느 태그든 풀 크기가 몫보다 작으면 `INTERVIEW_QUESTION_POOL_INSUFFICIENT`
3. `COMMON_CS`는 뽑은 id 전체를 한 리스트로 모아 다시 `Collections.shuffle`한다
4. `JOB_SPECIFIC`은 `topicToQuota`의 순회 순서(= `allocate`가 만든 공통 -> 언어 -> 프레임워크)대로 이어 붙인다. 셔플하지 않는다

private 헬퍼 둘로 나눈다. 2번이 `pickByQuota`, 3~4번이 `orderByMode`다.

`stack`을 받지 않는다. 순서 정보는 이미 `allocate`가 만든 맵의 순서에 들어 있고, 그 맵을 여기서 직접 순회하므로 순서 보존이 다른 클래스의 반환 타입에 걸리지 않는다.

같은 문제가 두 번 나오지 않는 것은 태그가 문제당 하나라 태그별 풀이 서로 겹치지 않기 때문에 자연히 보장된다. `interview_answer`의 `uq_interview_answer_session_question`이 마지막 방어선이다.

**`interview/policy/InterviewAudioKeyPolicy`** (`@Component`)

```java
private static final String KEY_FORMAT = "interview/%d/%d.%s";
private static final String KEY_PREFIX_FORMAT = "interview/%d/%d.";

public String issue(
        long sessionId,
        int displayOrder,
        InterviewAudioFormat format
)
    // "interview/{sessionId}/{displayOrder}.{extension}"

public void validate(
        long sessionId,
        int displayOrder,
        String audioKey
)
    // 접두사가 KEY_PREFIX_FORMAT과 다르면 -> INTERVIEW_AUDIO_KEY_INVALID
    // 남은 확장자가 InterviewAudioFormat에 없으면 -> INTERVIEW_AUDIO_KEY_INVALID
```

접두사 대조와 확장자 화이트리스트, 둘 다 필요하다. 접두사만 보면 `interview/12/1.sh`가 통과하고, 확장자만 보면 남의 세션 키인 `interview/99/1.m4a`가 통과한다. 확장자를 화이트리스트로 판정하므로 `interview/12/1.m4a/../../13/1.m4a` 같은 경로 조작도 함께 걸린다.

발급과 검증이 한 클래스에 있는 이유는 배치 기준에 적었다.

### 5. Infrastructure

**`global/config/S3Config`** (`@Configuration`)

```java
@Bean
public S3Presigner s3Presigner(
        @Value("${aws.s3.region}") String region,
        @Value("${aws.s3.access-key}") String accessKey,
        @Value("${aws.s3.secret-key}") String secretKey
)
    // S3Presigner.builder()
    //     .region(Region.of(region))
    //     .credentialsProvider(StaticCredentialsProvider.create(
    //             AwsBasicCredentials.create(accessKey, secretKey)))
    //     .build()
```

`AiConfig`가 `ChatClient`를 등록하는 것과 같은 자리다. `S3Presigner`는 스레드 안전한 싱글턴으로 쓰도록 설계돼 있어 빈으로 한 번만 만든다.

**`interview/infrastructure/InterviewAudioStorage`** (`@Component`)

```java
private final S3Presigner s3Presigner;
private final Clock clock;

private final String bucket;              // @Value("${aws.s3.bucket}")
private final Duration uploadExpiry;      // @Value("${aws.s3.upload-expiry}")

public InterviewAudioUploadDto presignUpload(
        String audioKey,
        String contentType
)
    // PutObjectRequest(bucket, audioKey, contentType)
    // PutObjectPresignRequest(signatureDuration = uploadExpiry)
    // -> InterviewAudioUploadDto(url, LocalDateTime.now(clock) + uploadExpiry)
```

`contentType`을 서명에 포함한다. 그래야 발급받을 때 신고한 포맷과 다른 것을 올리면 S3가 거부한다. 포함하지 않으면 `audio/m4a`로 URL을 받아 임의의 바이트를 올릴 수 있다.

`expiresAt` 계산에 `Clock`을 주입해 쓴다. 테스트가 `FixedClockConfig`의 고정 시각으로 값을 단언할 수 있다.

### 6. Service

**`interviewQuestion/service/InterviewQuestionQueryService`** (추가)

```java
@Transactional(readOnly = true)
public List<InterviewQuestionPoolDto> getPool(
        Collection<InterviewTopic> topics,
        InterviewDifficulty difficulty
)
    // findPoolByTopicsAndDifficulty(topics, difficulty)를 그대로 반환
```

모드도 스택도 몫도 모른다. 태그 집합과 난이도만 받아 조건에 맞는 문제 풀을 돌려줄 뿐, 선별도 판정도 하지 않는다. 이 클래스의 기존 두 메서드(`getQuestionIdToQuestion`, `getQuestionIdToConcepts`)와 성격이 같다.

**`interview/service/InterviewSessionCommandService`** (추가)

```java
@Transactional
public long create(
        long userId,
        InterviewSessionCreateDto createDto
)
    // attemptCount = interviewSessionRepository.findMaxAttemptCountByUserId(userId) + ATTEMPT_COUNT_INCREMENT
    // InterviewSession.create(userId, attemptCount, createDto.mode(), createDto.inputType(),
    //                         createDto.difficulty(), createDto.stack()) 저장
    //
    // createDto.topics() -> InterviewSessionTopic.create(sessionId, topic) saveAll
    //
    // createDto.orderedQuestionIds() -> InterviewAnswer.create(sessionId, questionId, index + FIRST_DISPLAY_ORDER) saveAll
    //
    // return sessionId
```

**요청 DTO를 그대로 받지 않는다.** `InterviewSessionCreateRequest`를 넘기면 서비스 시그니처에 `request.topics()`(사용자가 고른 원본, 직군 모드에서는 null)와 정책이 만든 `topics`가 나란히 놓인다. 둘 다 `InterviewTopic` 컬렉션이고 순회 코드가 같아 바꿔 써도 컴파일되며, 공통 CS는 결과까지 같아 직군 테스트에서만 터진다. 내부 DTO로 묶으면 서비스가 보는 `topics`가 정답 하나뿐이라 그 자리가 없어진다. `InterviewFeedbackCommandService.saveAll(List<InterviewGradedAnswerDto>)`가 요청이 아니라 Facade가 조립한 내부 DTO를 받는 것과 같은 형태다.

`InterviewSessionTopicRepository`를 새로 주입한다. 세션, 주제, 답안 셋은 하나라도 빠지면 세션이 성립하지 않으므로 같은 트랜잭션이다 (`facade.md` 계층 1).

```java
@Transactional
public InterviewSessionStatusResponse abandon(
        long userId,
        long sessionId
)
    // findSession -> validateOwner -> session.abandon(LocalDateTime.now(clock))
    // return InterviewSessionStatusResponse.of(session.getId(), session.getStatus())
```

진행 중 여부는 엔티티의 `abandon()`이 검증한다. 기존 `findSession`, `validateOwner` private 메서드를 그대로 쓴다.

**`interview/service/InterviewSessionCommandService.validateAudioKeys`** (기존 private 메서드 확장)

지금은 TEXT 세션만 검사하고 VOICE 세션은 무엇을 보내도 통과한다. 정책의 "음성 세션의 음성 키는 서버가 발급한 형식이어야 하며 발급된 세션과 문항에 일치해야 한다"가 아직 구현되지 않은 자리다. 키 형식을 정하는 것이 이 이슈이므로 여기서 닫는다.

```java
private void validateAudioKeys(
        InterviewSession session,
        List<InterviewAnswerSubmitRequest> answerRequests
)
    // TEXT: audioKey가 하나라도 있으면 INTERVIEW_INPUT_TYPE_MISMATCH (기존 그대로)
    // VOICE: audioKey가 null이거나 공백이면 통과 (무응답 문항은 비어 있을 수 있다)
    //        값이 있으면 interviewAudioKeyPolicy.validate(session.getId(), displayOrder, audioKey)
```

`InterviewAudioKeyPolicy`를 새로 주입한다. **오브젝트가 실제로 올라와 있는지는 확인하지 않는다.** 확인하려면 제출 트랜잭션 안에서 S3에 HEAD를 5번 던져야 하는데, 그 대가로 제출이 외부 장애에 묶인다. 키만 있고 파일이 없는 경우는 재생 시점에 드러나고, 채점은 어차피 텍스트만 본다.

**`interview/service/InterviewAudioUploadService`** (신규)

```java
@Transactional(readOnly = true)
public InterviewAudioUploadResponse issueUploadUrl(
        long userId,
        long sessionId,
        InterviewAudioUploadRequest request
)
    // findSession -> 없으면 INTERVIEW_SESSION_NOT_FOUND
    // 소유자 아니면 INTERVIEW_SESSION_ACCESS_DENIED
    // session.isTextInput() -> INTERVIEW_INPUT_TYPE_MISMATCH
    // !session.isInProgress() -> INTERVIEW_SESSION_NOT_IN_PROGRESS
    //
    // format = InterviewAudioFormat.from(request.contentType())
    // audioKey = interviewAudioKeyPolicy.issue(sessionId, request.displayOrder(), format)
    // upload = interviewAudioStorage.presignUpload(audioKey, format.getContentType())
    // return InterviewAudioUploadResponse.of(audioKey, upload)
```

`InterviewSessionRepository`, `InterviewAudioKeyPolicy`, `InterviewAudioStorage`를 주입한다. 세션 조회 한 번뿐이라 `QueryService`에 넣을 수도 있지만, 발급은 조회가 아니고 외부 컴포넌트를 타므로 분리한다.

진행 중 검사는 제출 이후의 발급을 막는다. 이게 없으면 채점이 끝난 세션의 음성을 나중에 갈아치울 수 있다.

**`interview/service/InterviewSessionQueryService`** (추가)

```java
@Transactional(readOnly = true)
public InterviewSessionQuestionsResponse getQuestions(
        long userId,
        long sessionId
)
    // findSession -> 소유자 아니면 INTERVIEW_SESSION_ACCESS_DENIED
    // interviewAnswerRepository.findQuestionsBySessionId(sessionId) -> 응답 매핑
```

상태를 가리지 않는다. 정책상 진행 중, 채점 중, 채점 실패, 취소 세션도 문제 목록은 볼 수 있다. `InterviewAnswerRepository`를 새로 주입한다.

**`interviewQuestion/service/InterviewTopicQueryService`** (신규)

```java
public List<InterviewTopicResponse> getCsTopics()
    // Arrays.stream(InterviewTopic.values())
    //     .filter(topic -> topic.getKind() == InterviewTopicKind.CS)
    //     .map(InterviewTopicResponse::from).toList()
```

**`interview/service/InterviewStackQueryService`** (신규)

```java
public List<InterviewStackGroupResponse> getStackGroups()
    // 노출 순서 오름차순

public List<InterviewStackResponse> getStacks(InterviewStackGroup stackGroup)
    // group 일치 + 노출 순서 오름차순
```

두 서비스 모두 리포지토리를 주입하지 않고 트랜잭션도 열지 않는다.

### 7. Facade

**`interview/facade/InterviewSessionFacade`** (`@Facade`)

```java
private final InterviewQuestionAllocationPolicy interviewQuestionAllocationPolicy;

private final InterviewQuestionQueryService interviewQuestionQueryService;
private final InterviewSessionCommandService interviewSessionCommandService;

public InterviewSessionCreateResponse create(
        long userId,
        InterviewSessionCreateRequest request
) {
    Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
            request.mode(), request.stack(), request.topics());

    List<InterviewQuestionPoolDto> pool = interviewQuestionQueryService.getPool(
            topicToQuota.keySet(), request.difficulty());

    List<Long> orderedQuestionIds = interviewQuestionAllocationPolicy.select(
            request.mode(), topicToQuota, pool);

    long sessionId = interviewSessionCommandService.create(
            userId, InterviewSessionCreateDto.of(request, topicToQuota.keySet(), orderedQuestionIds));

    return InterviewSessionCreateResponse.from(sessionId);
}
```

검증, 조회, 선별은 경계 밖, 쓰기는 서비스 한 번이다. `TransactionTemplate`을 쓰지 않는 이유는 배치 기준에 적었다. 엔티티를 경계 밖으로 꺼내지 않으므로 `open-in-view: false`에도 안전하다.

조회 → 정책 → 내부 DTO 조립 → CommandService 위임은 `InterviewGradingFacade.grade()`가 이미 쓰는 순서다.

나머지 6개 엔드포인트는 Facade를 만들지 않는다. 목록 조회 3개, 중단, 문제 목록 조회, 업로드 URL 발급은 모두 단일 도메인이다. 발급이 `InterviewAudioStorage`를 함께 부르지만 인프라 컴포넌트는 다른 도메인의 서비스가 아니다.

### 8. DTO

**`interview/dto/request/InterviewSessionCreateRequest`**

```java
public record InterviewSessionCreateRequest(
        @NotNull InterviewInputType inputType,
        @NotNull InterviewMode mode,
        @NotNull InterviewDifficulty difficulty,
        InterviewStack stack,       // JOB_SPECIFIC만
        List<InterviewTopic> topics // COMMON_CS만 1~5개
) {}
```

`stack`과 `topics`에는 validation 어노테이션을 붙이지 않는다. 필수 여부가 `mode`에 따라 뒤집혀 단일 필드 제약으로 표현되지 않는다. 조합 규칙은 전부 `InterviewQuestionAllocationPolicy.allocate()`가 판정해 도메인 에러코드로 알린다. 필드 제약과 정책 검증이 갈라져 같은 위반이 요청마다 다른 코드로 나오는 편이 더 나쁘다.

**`interview/dto/request/InterviewAudioUploadRequest`**

```java
public record InterviewAudioUploadRequest(
        @Min(1) @Max(5) int displayOrder,
        @NotBlank String contentType
) {}
```

`displayOrder` 제약은 `InterviewAnswerSubmitRequest`와 같은 값을 쓴다. `contentType`을 열거형으로 받지 않는 이유는 절 2에 적었다.

**응답 record** (모두 private `@Builder` + 정적 팩토리)

- `InterviewSessionCreateResponse.from(long sessionId)` - `{ sessionId }`
- `InterviewStackGroupResponse.from(InterviewStackGroup group)` - `{ stackGroup, displayName }`
- `InterviewSessionQuestionResponse.from(InterviewSessionQuestionDto dto)` - `{ displayOrder, content }`
- `InterviewSessionQuestionsResponse.of(long sessionId, List<InterviewSessionQuestionResponse> questions)` - `{ sessionId, questions }`
- `InterviewAudioUploadResponse.of(String audioKey, InterviewAudioUploadDto upload)` - `{ audioKey, uploadUrl, expiresAt }`

`InterviewTopicResponse`, `InterviewStackResponse`, `InterviewSessionStatusResponse`는 이미 있어 그대로 쓴다.

**내부 DTO** (`dto.md` Internal 규칙: `Dto` 접미사, 표준 생성자, `@Schema` 없음)

- `interviewQuestion/dto/internal/InterviewQuestionPoolDto(InterviewTopic topic, Long questionId)`
- `interview/dto/internal/InterviewSessionQuestionDto(Integer displayOrder, String content)`
- `interview/dto/internal/InterviewAudioUploadDto(String uploadUrl, LocalDateTime expiresAt)`

```java
public record InterviewSessionCreateDto(
        InterviewMode mode,
        InterviewInputType inputType,
        InterviewDifficulty difficulty,
        InterviewStack stack,
        Set<InterviewTopic> topics,
        List<Long> orderedQuestionIds
) {
    public static InterviewSessionCreateDto of(
            InterviewSessionCreateRequest request,
            Set<InterviewTopic> topics,
            List<Long> orderedQuestionIds
    )
}
```

정적 팩토리 `of`가 요청에서 내부 DTO로 가는 변환을 한 군데로 모은다. **`request.topics()`를 버리고 정책이 만든 `topics`를 쓴다는 사실이 이 한 곳에만 드러난다.** 이 record는 쿼리 프로젝션이 아니라 Facade와 서비스 사이의 전달용이고, `InterviewAudioUploadDto`도 인프라와 서비스 사이의 전달용이다. `dto.md`의 Internal 절이 프로젝션과 레이어 간 전달을 같은 자리로 규정한다.

`InterviewQuestionPoolDto`와 `InterviewSessionQuestionDto`는 JPQL 생성자 표현식의 대상이므로 정적 팩토리 없이 표준 생성자를 쓴다. 나머지 둘은 대상이 아니라 `@Builder` + 정적 팩토리를 쓴다 (`common.md`).

### 9. Controller

**`interviewQuestion/controller/InterviewTopicController`** (신규)

```java
@RequestMapping("/api/v1/interview-topics")
GET ""                        -> getCsTopics()               // 200, List<InterviewTopicResponse>
```

**`interview/controller/InterviewStackGroupController`** (신규)

```java
@RequestMapping("/api/v1/interview-stack-groups")
GET ""                        -> getStackGroups()            // 200, List<InterviewStackGroupResponse>
GET "/{stackGroup}/stacks"    -> getStacks(stackGroup)       // 200, List<InterviewStackResponse>
```

**`interview/controller/InterviewSessionController`** (추가)

```java
POST ""                          -> create(loginUser, request)         // 201, InterviewSessionCreateResponse
GET  "/{sessionId}/questions"    -> getQuestions(loginUser, id)        // 200, InterviewSessionQuestionsResponse
POST "/{sessionId}/audio-uploads" -> issueUploadUrl(loginUser, id, req) // 200, InterviewAudioUploadResponse
PATCH "/{sessionId}/abandon"     -> abandon(loginUser, id)             // 200, InterviewSessionStatusResponse
```

`InterviewSessionFacade`와 `InterviewAudioUploadService`를 추가로 주입한다. 생성만 Facade, 나머지는 서비스에 위임한다 (`controller.md`의 혼합 주입 허용).

세 목록 조회 API도 `@AuthenticationPrincipal LoginUser loginUser`를 받는다. 인증 없이 열 이유가 없고 나머지 면접 API와 접근 조건을 맞춘다.

### 10. 에러코드

**개명** (`// Interview` 그룹, 선언 위치는 그대로. 두 코드 모두 현재 참조하는 코드가 없어 안전하다)

```java
INTERVIEW_STACK_REQUIRED(HttpStatus.BAD_REQUEST, "INTERVIEW_4007", "직군 면접은 스택을 선택해야 합니다."),
INTERVIEW_STACK_NOT_ALLOWED(HttpStatus.BAD_REQUEST, "INTERVIEW_4008", "공통 CS 면접은 스택을 선택할 수 없습니다."),
```

`TECH_STACK`은 #515에서 사라진 `interview_tech_stack` 테이블 시절 이름이다.

**추가** (`4015` 뒤, `5001` 앞)

```java
INTERVIEW_TOPIC_REQUIRED(HttpStatus.BAD_REQUEST, "INTERVIEW_4016", "공통 CS 면접은 주제를 1개 이상 선택해야 합니다."),
INTERVIEW_TOPIC_NOT_ALLOWED(HttpStatus.BAD_REQUEST, "INTERVIEW_4017", "직군 면접은 주제를 선택할 수 없습니다."),
INTERVIEW_TOPIC_INVALID(HttpStatus.BAD_REQUEST, "INTERVIEW_4018", "면접 주제는 중복 없는 CS 주제 1~5개여야 합니다."),
INTERVIEW_AUDIO_FORMAT_UNSUPPORTED(HttpStatus.BAD_REQUEST, "INTERVIEW_4019", "지원하지 않는 음성 포맷입니다."),
INTERVIEW_AUDIO_KEY_INVALID(HttpStatus.BAD_REQUEST, "INTERVIEW_4020", "서버가 발급한 음성 키가 아닙니다."),
```

**재사용**: `INTERVIEW_QUESTION_POOL_INSUFFICIENT`(4009, 409), `INTERVIEW_SESSION_NOT_FOUND`(4003), `INTERVIEW_SESSION_ACCESS_DENIED`(4004), `INTERVIEW_SESSION_NOT_IN_PROGRESS`(4005), `INTERVIEW_INPUT_TYPE_MISMATCH`(4006).

4006("면접 세션의 답변 입력 방식과 일치하지 않습니다")을 TEXT 세션의 업로드 URL 요청에 그대로 쓴다. 메시지가 이미 정확해서 코드를 새로 만들 이유가 없다.

### 11. Swagger 문서

**`InterviewTopicControllerDocs`** - `@Tag(name = "Interview Topic API")`. 200 예시(CS 태그 5개), 500.

**`InterviewStackGroupControllerDocs`** - `@Tag(name = "Interview Stack Group API")`. 그룹 목록 200 예시, 스택 목록 200 예시와 `@Parameter(description = "직군 그룹")`, 500.

**`InterviewSessionControllerDocs`** (추가) - `@Tag` description을 "AI 면접 세션 생성, 문제 조회, 음성 업로드 URL 발급, 답안 제출, 상태 조회, 중단 API"로 갱신.

- create: 201 성공 예시, 400(`GLOBAL_4001`, `INTERVIEW_4007`, `4008`, `4016`, `4017`, `4018`), 409(`INTERVIEW_4009`), 500
- questions: 200 예시(5문항), 403(`4004`), 404(`4003`), 500
- audio-uploads: 200 예시, 400(`GLOBAL_4001`, `INTERVIEW_4006`, `4019`), 403(`4004`), 404(`4003`), 409(`4005`), 500
- abandon: 200 예시(`ABANDONED`), 403(`4004`), 404(`4003`), 409(`4005`), 500
- submit (기존 문서 보강): 400 목록에 `INTERVIEW_4020` 추가

audio-uploads의 `contentType` 설명에 허용 목록(`audio/m4a`, `audio/mp4`, `audio/webm`, `audio/mpeg`)을 그대로 적는다. 열거형이 아니라 문자열이라 Swagger가 자동으로 뽑아주지 못한다. 응답 설명에는 "이 URL로 PUT하고, 발급받은 `audioKey`를 제출 본문에 담으라"는 사용 순서를 적는다. 발급과 업로드와 제출이 세 번에 나뉘어 있어 계약만 봐서는 순서가 드러나지 않는다.

세 목록 조회의 응답 설명에 "콘텐츠 충족 여부는 반영하지 않는다"를 적지 않는다. 사용자에게 의미 없는 내부 사정이다.

### 12. 커밋 순서

1. `docs: 면접 음성 업로드 방식 확정(#523)` - `interview.md` 입력 방식 절과 P11 표, `secret-convention.md` 시크릿 3종
2. `feat: 면접 주제와 스택 선택지 조회 API 구현(#523)` - 목록 조회 3개, 서비스 2개, 응답 DTO, Docs 2개
3. `feat: 면접 출제 배분과 문제 선별 구현(#523)` - `InterviewQuestionAllocationPolicy`(`allocate`, `select`), 풀 조회 쿼리와 `getPool`, 에러코드
4. `feat: 면접 세션 생성 API 구현(#523)` - Facade, `create`, 요청과 응답 DTO, `InterviewSessionCreateDto`, 시도 차수 채번, 컨트롤러
5. `feat: 면접 세션 문제 조회와 중단 API 구현(#523)` - `abandon`, `getQuestions`, 조인 프로젝션, 컨트롤러, Docs
6. `feat: 면접 음성 업로드 URL 발급 API 구현(#523)` - S3 의존성과 설정, `S3Config`, `InterviewAudioStorage`, `InterviewAudioFormat`, `InterviewAudioKeyPolicy`, `InterviewAudioUploadService`, 컨트롤러, Docs, CD 워크플로
7. `feat: 면접 제출의 음성 키 검증 추가(#523)` - `validateAudioKeys` 확장, 에러코드 2개
8. `test: 면접 세션 시작과 음성 업로드 통합 테스트 추가(#523)` - 픽스처, 테스트 7종

정책 문서를 맨 앞에 둔다. 구현이 정책을 따르는 순서이고, 리뷰어가 6번 커밋의 키 형식을 볼 때 근거가 이미 저장소에 있어야 한다.

## 결정 필요 (Decisions needed)

- [x] **시도 차수 채번의 동시성** - 그대로 둔다. `MAX + 1`은 같은 사용자가 동시에 두 번 생성하면 같은 차수를 받고 V41에 `(user_id, attempt_count)` 유니크가 없어 막히지도 않는다. 다만 차수 중복은 세션 중복 생성의 결과이지 원인이 아니므로, 중복 생성 차단(P1)을 정하기 전에 유니크 제약만 거는 것은 순서가 뒤집힌다. 마이그레이션과 재시도는 P1과 함께 다룬다
- [x] **목록 조회 3개의 인증 요구** - 인증 필수로 두고 컨트롤러가 `@AuthenticationPrincipal LoginUser loginUser`를 받는다. `SecurityConfig`가 `anyRequest().authenticated()`라 permitAll을 더하지 않으면 그대로 인증이 걸리므로 설정 변경은 없다. 서비스는 `userId`를 쓰지 않지만 나머지 면접 API와 시그니처를 맞추고 Swagger 잠금 표시를 일관되게 한다
- [x] **문제 목록 조회의 상태 제한** - 정책대로 다섯 상태 모두 허용한다. 채점 실패나 취소로 끝난 세션도 무엇을 받았는지는 복기할 수 있어야 한다
- [x] **업로드 URL의 발급 시점** - 문항별 온디맨드로 발급한다. 세션 생성 응답에 5개를 한꺼번에 담는 방식은 왕복이 한 번으로 줄지만, 5문항 x 2분 발화에 확인과 수정 시간까지 감당하려면 만료를 한 시간 넘게 잡아야 하고, 쓰기 응답에 식별자만 담는 규칙(`facade.md`)에서도 벗어난다. 온디맨드면 만료가 10분이면 충분하고 TEXT 세션에는 아예 발급하지 않는다
- [x] **음성 키의 형식** - `interview/{sessionId}/{displayOrder}.{확장자}`로 결정적으로 만들고 발급 대장을 저장하지 않는다. 근거는 배치 기준에 적었다. 키가 추측 가능한 것은 버킷 퍼블릭 액세스 차단이 전제되므로 문제가 되지 않는다
- [x] **스토리지** - AWS S3. `S3Presigner`(AWS SDK v2)를 쓴다. 버킷과 자격증명은 dev, prod를 처음부터 분리한다
- [x] **제출 시 음성 키 검증을 이 이슈에 포함할지** - 포함한다. 키 형식을 정하는 것이 이 이슈인데 검증을 미루면, 그동안 VOICE 세션은 임의의 문자열을 음성 키로 제출해도 통과한다. #520이 `validateAudioKeys`에 남겨둔 자리를 그대로 채우는 일이라 범위도 좁다
- [x] **음성 재생(다운로드) URL** - 이 이슈에 넣지 않는다. 결과 조회(#517)의 `InterviewAnswerDetailResponse`가 지금은 raw `audioKey`만 내려주는데, 재생을 열려면 그 응답 계약을 함께 바꿔야 해서 #517 영역까지 번진다. 제출 전 점검은 클라이언트가 방금 올린 로컬 파일을 재생하면 되므로 이 이슈가 막히지도 않는다. 별도 이슈로 뺀다

## 검증

모두 `@TCSpringBootTest` 통합 테스트다. `@WithMockLoginUser`가 주석 처리돼 있어 컨트롤러 테스트는 쓰지 않고 Facade, Service, Policy 수준으로 검증한다. Docker(Testcontainers)가 필요하다.

**픽스처**
- `InterviewQuestionFixture.문제(topic, difficulty, unitId)`, `.비활성_문제(topic, difficulty, unitId)`, `.문제_여러건(topic, difficulty, count)` - `InterviewQuestion.create`는 항상 활성이므로 비활성은 `ReflectionTestUtils.setField(question, "active", false)`로 만든다
- `InterviewSessionFixture.생성_요청_공통CS(difficulty, topics...)`, `.생성_요청_직군(difficulty, stack)`
- `InterviewSessionFixture.상태_세션(userId, status)`는 지금 TEXT로 고정돼 있다. 음성 테스트가 "GRADING 상태의 VOICE 세션"을 필요로 하므로 `.상태_세션(userId, status, inputType)` 오버로드를 더한다. 기존 시그니처는 TEXT로 위임해 남긴다 (#520 테스트가 쓰고 있다)

**`InterviewQuestionAllocationPolicyIntegrationTest`** (`@Nested` "조합 검증" / "공통 CS 배분" / "직군 배분" / "선별" / "문항 순서")

출제 정책 전부가 이 클래스에 모였으므로 검증도 여기로 모인다. **`select`는 문제 풀을 인자로 받으므로 DB가 필요 없다.** 풀 리스트를 손으로 만들어 넣는다.

- 주제 1~5개 각각에 대해 몫의 합이 5이고 몫 다중집합이 표와 같다 (2개 -> `{3, 2}`, 3개 -> `{2, 2, 1}`, 4개 -> `{2, 1, 1, 1}`)
- 반환 맵의 키 집합이 입력 주제 집합과 같다
- 직군: 키가 공통, 언어, 프레임워크 순이고 몫이 1, 2, 2다
- 조합 실패 5종: 공통 CS + stack -> `INTERVIEW_STACK_NOT_ALLOWED`, 직군 + stack 없음 -> `INTERVIEW_STACK_REQUIRED`, 직군 + topics -> `INTERVIEW_TOPIC_NOT_ALLOWED`, 공통 CS + topics 없음 -> `INTERVIEW_TOPIC_REQUIRED`, 6개 / 중복 / CS 아닌 태그 -> `INTERVIEW_TOPIC_INVALID`
- `select` 성공: 반환이 5건이고 id 중복이 없으며, 태그별 개수가 배분과 정확히 일치한다
- `select` 부족: 어느 한 태그만 몫에 미달해도 `INTERVIEW_QUESTION_POOL_INSUFFICIENT`, 풀이 통째로 비어도 같은 코드
- `select` 무작위성: 태그 풀이 몫보다 클 때(예: 몫 1에 후보 5건) 같은 인자로 여러 번 호출하면 뽑히는 조합이 최소 한 번은 달라진다. 재출제 회피(P4)가 없는 지금 이 무작위성이 사용자가 체감하는 전부다
- `select` 순서: 공통 CS는 5건이 모두 포함되고 순서가 고정되지 않는다(여러 번 호출해 최소 한 번은 달라진다). 직군은 **항상** 공통 -> 언어 -> 프레임워크 순이다
- 직군 순서 회귀: `allocate`가 준 맵을 그대로 넘겼을 때 스택 구성 태그 순서가 유지된다. 배치 기준에 적은 `HashMap` 함정을 잡는 자리다

**`InterviewSessionFacadeIntegrationTest`** (`@Nested` "세션을 생성할 때")

정책 검증이 위로 빠졌으므로 여기는 **저장 결과와 조립**만 본다.

- 공통 CS 성공: 세션 1건(IN_PROGRESS, `attemptCount` 1, 만점 70/15/15), 주제 행이 고른 주제와 같음, 답안 5건이 PENDING이고 `displayOrder` 1~5, 문제 id 중복 없음
- 직군 성공: 주제 행 3건이 스택 구성 태그이고, 답안이 공통 -> 언어 -> 프레임워크 순으로 저장된다
- 두 번째 생성 시 `attemptCount`가 2다. 취소, 채점 실패 세션이 있어도 차수를 소비한다
- 세션 난이도와 다른 난이도 문제만 있으면 `INTERVIEW_QUESTION_POOL_INSUFFICIENT` (쿼리의 난이도 필터가 실제로 걸리는지 확인)
- 비활성 문제는 뽑히지 않는다 (쿼리의 `active` 필터 확인. 활성 몫만큼만 있고 비활성이 더 있어도 성공, 활성이 부족하면 실패)
- 풀 부족으로 실패하면 **세션과 주제와 답안이 하나도 남지 않는다**
- 조합 실패 시 세션이 생기지 않는다

난이도와 활성 필터는 Policy가 아니라 JPQL이 하므로 DB를 타는 이 테스트에 남는다.

**`InterviewSessionCommandServiceIntegrationTest`** (`@Nested` "세션을 중단할 때", "음성 세션을 제출할 때" 추가)
- IN_PROGRESS 중단 성공: 응답 `ABANDONED`, `endedAt`이 고정 시각, `gradingAttemptCount`가 0 그대로
- 없는 세션 `INTERVIEW_SESSION_NOT_FOUND`, 남의 세션 `INTERVIEW_SESSION_ACCESS_DENIED`
- GRADING, COMPLETED, GRADING_FAILED, ABANDONED 세션 -> `INTERVIEW_SESSION_NOT_IN_PROGRESS`이고 상태와 `endedAt`이 바뀌지 않는다
- 음성 키 검증: 자기 세션과 문항의 키는 통과, 다른 세션 id의 키 / 다른 문항 번호의 키 / 미허용 확장자 / 임의 문자열은 `INTERVIEW_AUDIO_KEY_INVALID`
- 무응답 문항의 빈 음성 키는 통과한다 (null과 공백 둘 다)
- TEXT 세션에 음성 키를 실으면 기존대로 `INTERVIEW_INPUT_TYPE_MISMATCH` (회귀 확인)

**`InterviewAudioKeyPolicyIntegrationTest`** (`@Nested` "키를 발급할 때" / "키를 검증할 때")
- 4개 포맷이 각각 `interview/{sessionId}/{displayOrder}.{m4a|m4a|webm|mp3}`로 나온다
- 발급한 키는 같은 세션, 같은 문항으로 검증하면 통과한다 (발급과 검증의 왕복)
- 거부: 다른 세션 id, 다른 문항 번호, 미허용 확장자(`.sh`), 확장자 없음, 접두사 없는 임의 문자열, 경로 조작(`interview/12/1.m4a/../../13/1.m4a`)

**`InterviewAudioUploadServiceIntegrationTest`** (`@Nested` "업로드 URL을 발급할 때")
- VOICE + IN_PROGRESS 성공: `audioKey`가 키 규칙과 일치, `uploadUrl`이 설정한 버킷 호스트를 가리키고 `X-Amz-Signature`와 `X-Amz-Expires`를 포함, `expiresAt`이 고정 시각 + 10분
- 서명에 `contentType`이 포함된다 (`X-Amz-SignedHeaders`에 `content-type`이 들어간다)
- TEXT 세션 -> `INTERVIEW_INPUT_TYPE_MISMATCH`
- GRADING, COMPLETED, GRADING_FAILED, ABANDONED 세션 -> `INTERVIEW_SESSION_NOT_IN_PROGRESS`
- 없는 세션 `INTERVIEW_SESSION_NOT_FOUND`, 남의 세션 `INTERVIEW_SESSION_ACCESS_DENIED`
- 미허용 `contentType`(`audio/flac`) -> `INTERVIEW_AUDIO_FORMAT_UNSUPPORTED`

이 테스트는 AWS에 붙지 않는다. presign이 로컬 서명 계산이라 `application-test.yml`의 더미 자격증명만으로 진짜 URL이 만들어지고, 그 URL의 구조를 그대로 단언한다. 실제 PUT이 성공하는지는 버킷 CORS와 IAM에 달려 있어 통합 테스트로 덮이지 않는다. 배포 후 수동 확인이 필요한 유일한 지점이다.

**`InterviewSessionQueryServiceIntegrationTest`** (`@Nested` "문제 목록을 조회할 때" 추가)
- 5문항이 `displayOrder` 오름차순으로 나오고 본문이 문제의 본문과 같다
- 다섯 상태 모두 조회에 성공한다
- 없는 세션 `INTERVIEW_SESSION_NOT_FOUND`, 남의 세션 `INTERVIEW_SESSION_ACCESS_DENIED`

**`InterviewTopicQueryServiceIntegrationTest`** - CS 5개만 나오고 선언 순이며 표시명이 붙는다

**`InterviewStackQueryServiceIntegrationTest`** - 그룹 4개가 노출 순서대로, SERVER 스택 4개가 노출 순서대로, IOS 스택 1건

**실행**: `./gradlew test --tests 'gravit.code.interview*'`

## 나중에 고려할 문제

| 항목 | 현재 기본값 |
|---|---|
| 문제 콘텐츠 부재 | `interview_question` 시드가 없어 세션 생성은 항상 `INTERVIEW_QUESTION_POOL_INSUFFICIENT`다. 난이도당 57문항, 세 난이도 171문항 제작은 별도 이슈 (P8) |
| 선택지에 콘텐츠 충족 반영 | 반영 안 함. 열거형 전체 노출 (P8) |
| 시도 차수 동시 채번 | 중복 가능. 중복 생성 차단(P1)과 함께 |
| 진행 중 세션 중복 생성 | 허용 (P1) |
| 문제 풀 전량 조회 후 메모리 셔플 | 태그당 활성 문제가 수천 건이 되면 `ORDER BY random() LIMIT n` 네이티브 쿼리로 전환 검토 |
| 재출제 회피 | 없음. 콘텐츠가 하한에 머무는 동안 같은 문제가 반복된다 (P4) |
| 열거형 바인딩 오타 | 전역 핸들러가 `MethodArgumentTypeMismatchException`(PathVariable, RequestParam)도 `HttpMessageNotReadableException`(요청 본문)도 잡지 않아 500 `GLOBAL_5001`이 나간다. `{stackGroup}`과 세션 생성 본문의 열거형 4필드가 여기 해당한다. 음성 `contentType`은 문자열로 받아 이 구멍을 피했다. 전역 핸들러 보강은 이 이슈 범위 밖 |
| 음성 원본 보관과 정리 | 계속 보관한다. 수명 주기 규칙도, 세션이나 계정이 지워질 때 오브젝트를 지우는 경로도 없다 (P11) |
| 같은 키 덮어쓰기 | 결정적 키라 같은 문항에 두 번 PUT하면 앞의 녹음을 덮어쓴다. "문항당 발화 1회, 재녹음 없음" 정책과 어긋나지만 서버가 막지 않는다. 발급이 진행 중 세션에만 열리므로 창은 세션 진행 중으로 한정된다 (P11) |
| 업로드 실재 확인 | 안 함. 제출 시 오브젝트 존재를 검사하지 않아 키만 있고 파일이 없을 수 있다. 검사하려면 제출이 S3 장애에 묶인다 |
| 음성 재생 URL | 없음. 결과 조회는 raw `audioKey`만 내려주며 다운로드 presigned URL 발급은 별도 이슈 (P11) |
| 음성-텍스트 변환 | 이 이슈는 원본 업로드 경로만 연다. 변환 엔진과 수행 주체는 미정 (P11) |
| S3 자격증명 | 정적 액세스 키를 설정으로 주입한다. 서버가 EC2나 ECS로 옮겨가면 인스턴스 역할로 바꿔 키를 없앨 수 있다 |

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다.

- `InterviewQuestionAllocationPolicy`: 상수명을 `CS_QUOTAS_BY_TOPIC_COUNT`에서 `TOPIC_COUNT_TO_CS_QUOTAS`로 바꿈 — 이유: `common.md`의 "Map은 `{키}To{값}`으로 짓고 `{값}By{키}`는 쓰지 않는다"에 어긋나서.
- `build.gradle`: AWS SDK BOM을 `2.54.13`으로 고정 — 이유: 계획서가 "착수 시점 최신 안정판 확인 후 고정"으로 남겨둔 자리. Maven Central 메타데이터에서 최신 릴리스를 확인해 박음.
- `InterviewSessionCommandService.validateAudioKeys`: private 헬퍼 `validateTextAudioKeysEmpty`, `validateVoiceAudioKeys` 둘로 분리 — 이유: TEXT/VOICE 분기가 한 메서드에 들어가면서 길어져서. 동작은 계획서와 같다.
- `application-local.yml`: dev/prod와 달리 `${...}` 대신 리터럴 더미 값을 넣음 — 이유: 이 파일은 CD의 `variable-substitution` 대상이 아니라 플레이스홀더를 두면 로컬 기동이 실패한다.
