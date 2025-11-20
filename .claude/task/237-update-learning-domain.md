# Task #237: 학습 도메인 업데이트

## 목표
새로운 기능 요구사항에 맞춰 기존 엔티티를 수정하고 새로운 제출 추적 엔티티를 추가하여 학습 도메인을 리팩토링합니다.

## 배경
- 현재 시스템은 Problem 엔티티에 정답을 직접 저장
- 주관식 문제의 정답 관리를 분리해야 함
- 레슨 및 문제 제출 시도를 추적해야 함
- 사용하지 않는 진행률 엔티티(ChapterProgress, UnitProgress) 제거 필요

## 사전 작업
- [ ] 기존 Problem, Option, Lesson, Unit 엔티티 검토
- [ ] ChapterProgress, UnitProgress를 사용하는 모든 서비스 검토
- [ ] 수정될 엔티티와 관련된 모든 Repository 및 쿼리 검토
- [ ] Flyway 마이그레이션 파일에서 현재 스키마 확인

## 데이터베이스 스키마 변경

### 1. Problem 엔티티 수정
- [ ] `question` 필드를 `instruction`으로 변경
- [ ] Problem 엔티티에서 `answer` 필드 제거
- [ ] Problem 엔티티 클래스 업데이트
- [ ] Problem을 사용하는 모든 DTO 업데이트 (ProblemResponse, ProblemCreateRequest, ProblemUpdateRequest)
- [ ] ProblemRepository 메서드 필요시 업데이트
- [ ] Flyway 마이그레이션 생성: `V{next}__modify_problem_entity.sql`

### 2. Answer 엔티티 생성 (신규)
- [ ] Answer 엔티티 생성 (필드):
    - `id` (PK)
    - `content` (정답 내용)
    - `explanation` (설명)
    - `problemId` (FK, Problem)
- [ ] AnswerRepository 인터페이스 생성
- [ ] AnswerJpaRepository 구현체 생성
- [ ] Flyway 마이그레이션 생성: `V{next}__create_answer_table.sql`

### 3. LessonSubmission 엔티티 생성 (신규)
- [ ] LessonSubmission 엔티티 생성 (필드):
    - `id` (PK)
    - `tryCount` (시도 횟수)
    - `learningTime` (학습 시간, 초 단위)
    - `lessonId` (FK, Lesson)
    - `userId` (FK, User)
- [ ] BaseTimeEntity를 사용하여 타임스탬프 필드 추가 (createdAt, updatedAt)
- [ ] LessonSubmissionRepository 인터페이스 생성
- [ ] LessonSubmissionJpaRepository 구현체 생성
- [ ] Flyway 마이그레이션 생성: `V{next}__create_lesson_submission_table.sql`

### 4. ProblemSubmission 엔티티 생성 (신규)
- [ ] ProblemSubmission 엔티티 생성 (필드):
    - `id` (PK)
    - `isCorrect` (boolean, 풀이 결과)
    - `problemId` (FK, Problem)
    - `userId` (FK, User)
- [ ] BaseTimeEntity를 사용하여 타임스탬프 필드 추가 (createdAt, updatedAt)
- [ ] ProblemSubmissionRepository 인터페이스 생성
- [ ] ProblemSubmissionJpaRepository 구현체 생성
- [ ] Flyway 마이그레이션 생성: `V{next}__create_problem_submission_table.sql`

### 5. Unit 엔티티 업데이트
- [ ] Unit 엔티티에 `description` 필드 추가
- [ ] UnitResponse DTO가 있다면 업데이트
- [ ] Flyway 마이그레이션 생성: `V{next}__add_unit_description.sql`

### 6. Lesson 엔티티 업데이트
- [ ] `name` 필드를 `title`로 변경 (필요시)
- [ ] Lesson 엔티티 클래스 업데이트
- [ ] Lesson을 사용하는 모든 DTO 업데이트
- [ ] Flyway 마이그레이션 생성: `V{next}__modify_lesson_entity.sql`

## 기존 코드 수정

### 7. AdminProblemService 수정
- [ ] createProblem 메서드에서 Answer 엔티티 별도 생성 로직 추가
- [ ] 주관식 문제 생성 시 Answer 저장 로직 구현
- [ ] updateProblem 메서드 Answer 처리 로직 추가
- [ ] deleteProblem 메서드에 Answer 삭제 로직 추가
- [ ] getProblem 메서드에서 Answer 정보 포함하도록 수정

### 8. DTO 수정
- [ ] ProblemCreateRequest에서 `question`을 `instruction`으로 변경
- [ ] ProblemUpdateRequest 수정
- [ ] ProblemResponse에 Answer 정보 포함하도록 수정
- [ ] AnswerResponse DTO 생성 (필요시)
- [ ] LessonSubmissionRequest DTO 생성
- [ ] ProblemSubmissionRequest DTO 생성

### 9. 서비스 레이어 구현
- [ ] LessonSubmissionService 생성
    - 레슨 제출 생성 메서드
    - 시도 횟수 조회 메서드
    - 학습 시간 통계 메서드
- [ ] ProblemSubmissionService 생성
    - 문제 제출 생성 메서드
    - 정답률 조회 메서드
    - 사용자별 풀이 이력 조회 메서드

### 10. ChapterProgress, UnitProgress 제거
- [ ] ChapterProgressService에서 해당 로직 제거 또는 수정
- [ ] UnitProgressService에서 해당 로직 제거 또는 수정
- [ ] ChapterProgressRepository 제거
- [ ] UnitProgressRepository 제거
- [ ] ChapterProgress 엔티티 제거
- [ ] UnitProgress 엔티티 제거
- [ ] 관련 DTO 제거
- [ ] Flyway 마이그레이션 생성: `V{next}__drop_chapter_unit_progress.sql`

### 11. 기존 기능 영향 확인
- [ ] LearningFacade에서 Progress 관련 로직 수정
- [ ] 진행률 계산 로직 재구현 (LessonSubmission 기반)
- [ ] 이벤트 발행 로직 확인 및 수정
- [ ] API 엔드포인트 확인 및 수정

## 테스트

### 12. 단위 테스트 작성
- [ ] Answer 엔티티 테스트
- [ ] LessonSubmission 엔티티 테스트
- [ ] ProblemSubmission 엔티티 테스트
- [ ] AdminProblemService 테스트 수정
- [ ] LessonSubmissionService 테스트
- [ ] ProblemSubmissionService 테스트

### 13. 통합 테스트
- [ ] Problem-Answer 연관관계 테스트
- [ ] LessonSubmission 생성 및 조회 테스트
- [ ] ProblemSubmission 생성 및 조회 테스트
- [ ] 기존 학습 플로우 통합 테스트

### 14. 마이그레이션 테스트
- [ ] 로컬 환경에서 Flyway 마이그레이션 실행 확인
- [ ] 기존 데이터 마이그레이션 스크립트 작성 (필요시)
- [ ] 롤백 시나리오 테스트

## 검증

### 15. 최종 검증
- [ ] 모든 단위 테스트 통과 확인
- [ ] 모든 통합 테스트 통과 확인
- [ ] 빌드 성공 확인
- [ ] API 문서 업데이트 확인 (Swagger)
- [ ] 코드 리뷰 체크리스트 확인

## 주의사항
- Answer는 주관식 문제에만 사용됨 (객관식은 기존 Option 유지)
- LessonSubmission과 ProblemSubmission은 BaseTimeEntity 상속 필수
- 외래키 제약조건 설정 확인
- 기존 데이터 마이그레이션 전략 수립 필요
- ChapterProgress, UnitProgress 제거 전 의존성 완전히 제거 확인

## 참고
- 프로젝트 패키지 구조: `gravit.code.learning.domain`
- Repository 패턴: 인터페이스 + JpaRepository 구현체
- 엔티티 생성 메서드: `create()` static 메서드 사용
- Builder 패턴 적용