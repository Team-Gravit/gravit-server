# [PLAN-503] 면접 기능 공통 기반 정의

> 이슈: #503
> 브랜치: feat/503-interview-common-base

## 목표
면접 API를 두 명이 병렬 구현하기 전에, 양쪽이 모두 수정하게 될 `CustomErrorCode`와 경계 계약(채점 요청 이벤트, 리포지토리 인터페이스)을 한 커밋으로 선점한다. 이 이슈가 dev에 머지된 뒤 각자 기능 브랜치를 딴다.

## 영향 범위
### 신규 파일
- `src/main/java/gravit/code/global/event/InterviewSessionGradingRequestedEvent.java` - 채점 요청 이벤트 record
- `src/main/java/gravit/code/interview/repository/InterviewSessionRepository.java` - 세션 리포지토리 뼈대
- `src/main/java/gravit/code/interview/repository/InterviewAnswerRepository.java` - 답변 리포지토리 뼈대
- `src/main/java/gravit/code/interviewQuestion/repository/InterviewQuestionRepository.java` - 질문 리포지토리 뼈대

### 수정 파일
- `src/main/java/gravit/code/global/exception/domain/CustomErrorCode.java` - `// Interview` 그룹(173행 뒤)에 에러코드 10종 추가

## 구현 계획
1. **Entity / Flyway**: 해당 없음 - DB 변경 없는 코드 선점 작업
2. **CustomErrorCode**: 기존 `// Interview` 그룹의 `INTERVIEW_4002` 뒤에 아래 10종을 순서대로 추가한다. 형식은 기존과 동일하게 `ERROR_NAME(HttpStatus.XXX, "INTERVIEW_40XX", "한글 메시지")`.

   | enum 상수 | HttpStatus | 코드 | 메시지 |
   |---|---|---|---|
   | `INTERVIEW_SESSION_NOT_FOUND` | `NOT_FOUND` | `INTERVIEW_4003` | 존재하지 않는 면접 세션입니다. |
   | `INTERVIEW_SESSION_ACCESS_DENIED` | `FORBIDDEN` | `INTERVIEW_4004` | 본인의 면접 세션만 접근할 수 있습니다. |
   | `INTERVIEW_SESSION_NOT_IN_PROGRESS` | `CONFLICT` | `INTERVIEW_4005` | 진행 중인 면접 세션이 아닙니다. |
   | `INTERVIEW_INPUT_TYPE_MISMATCH` | `BAD_REQUEST` | `INTERVIEW_4006` | 면접 세션의 답변 입력 방식과 일치하지 않습니다. |
   | `INTERVIEW_TECH_STACK_REQUIRED` | `BAD_REQUEST` | `INTERVIEW_4007` | 직무별 면접은 기술 스택 선택이 필요합니다. |
   | `INTERVIEW_TECH_STACK_NOT_ALLOWED` | `BAD_REQUEST` | `INTERVIEW_4008` | 공통 CS 면접은 기술 스택을 선택할 수 없습니다. |
   | `INTERVIEW_QUESTION_POOL_INSUFFICIENT` | `CONFLICT` | `INTERVIEW_4009` | 면접 질문 풀이 부족하여 세션을 생성할 수 없습니다. |
   | `INTERVIEW_ANSWER_NOT_FOUND` | `NOT_FOUND` | `INTERVIEW_4010` | 존재하지 않는 면접 답변입니다. |
   | `INTERVIEW_SESSION_ALREADY_IN_PROGRESS` | `CONFLICT` | `INTERVIEW_4011` | 이미 진행 중인 면접 세션이 있습니다. |
   | `INTERVIEW_FEEDBACK_NOT_READY` | `CONFLICT` | `INTERVIEW_4012` | 면접 채점이 완료되지 않아 피드백을 조회할 수 없습니다. |

3. **이벤트 record**: `global/event/InterviewSessionGradingRequestedEvent` - `public record InterviewSessionGradingRequestedEvent(long sessionId, long userId)`. 기존 `LessonCompletedEvent`처럼 primitive `long` 필드의 빈 본문 record.
   - 배치 근거: 발행처(interview)와 소비처(interviewFeedback)가 다른 크로스 도메인 이벤트다. 소비자 측 `dto/event/` 배치 선례(`FollowMissionEvent`)도 있으나, 두 패키지 모두 아직 서비스 코드가 없는 0단계 계약이므로 패키지 간 의존을 만들지 않는 `global/event/` 선례(`LessonCompletedEvent` 등 7건)를 따른다.
4. **Repository**: 세 인터페이스 모두 메서드 없는 빈 선언. 쿼리 메서드는 각자 브랜치에서 추가한다.
   - `interview/repository/InterviewSessionRepository extends JpaRepository<InterviewSession, Long>`
   - `interview/repository/InterviewAnswerRepository extends JpaRepository<InterviewAnswer, Long>`
   - `interviewQuestion/repository/InterviewQuestionRepository extends JpaRepository<InterviewQuestion, Long>`
5. **Service / Facade**: 해당 없음 - 후속 이슈 범위
6. **DTO / Controller**: 해당 없음 - 후속 이슈 범위

## 결정 필요 (Decisions needed)
- 없음. 에러코드 10종과 이벤트 시그니처는 분담표에서 이미 합의된 값이다.

## 검증
- `./gradlew build` - 컴파일과 기존 테스트 전체 통과 확인 (신규 로직이 없어 추가 테스트는 작성하지 않는다. 리포지토리 쿼리 메서드 테스트는 메서드가 생기는 후속 이슈에서 작성한다)

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
