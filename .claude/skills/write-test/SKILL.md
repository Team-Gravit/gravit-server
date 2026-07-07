---
name: write-test
description: |
  테스트 코드를 작성한다.
  Trigger: "테스트 작성해줘", "테스트 코드 만들어줘", "이 클래스 테스트해줘", "XXXService 테스트", "테스트 추가해줘"
  Do NOT use for: 테스트 실행/결과 확인(→ run-test), 기존 테스트 수정만 필요한 경우(직접 Edit), 코드 리뷰
  Boundary: 테스트 대상 코드의 버그 수정은 이 스킬 범위 밖이다. 테스트 작성 중 버그를 발견하면 사용자에게 보고만 하라.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: opus
effort: xhigh
---

# 테스트 코드 작성

대상: $ARGUMENTS

**인자 형식**: `<클래스명>` (테스트 대상 클래스명, 필수)
- 예: `BookmarkService`, `ChapterFacade`, `LessonQueryService`

모든 테스트는 통합 테스트(`@TCSpringBootTest`)로 작성한다.

## Phase 1: 대상 분석

1. $ARGUMENTS의 클래스명으로 대상 클래스 파일을 Grep/Glob으로 찾아 Read로 읽어라
2. 클래스의 public 메서드 목록과 각 메서드의 분기(if/switch/예외)를 파악하라
3. 클래스가 의존하는 다른 클래스(생성자 파라미터, 필드 주입)를 목록화하라

> 다음 Phase 조건: 대상 클래스의 메서드와 의존성 목록이 파악되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: Fixture 확인 및 생성

1. `src/test/java/gravit/code/{domain}/fixture/` 디렉토리를 Glob으로 확인하라
2. 필요한 Entity의 Fixture가 이미 존재하면 해당 파일을 읽고 재사용하라
3. 존재하지 않으면 [template/test-code-template.md](template/test-code-template.md)의 Fixture 섹션을 참조하여 생성하라

> 다음 Phase 조건: 테스트에 필요한 모든 Fixture가 준비되었을 때

> Skip 조건: 대상 메서드가 Entity를 사용하지 않거나, 필요한 Fixture가 모두 이미 존재할 때

## Phase 3: 테스트 코드 작성

1. `.claude/spec/test-convention.md`를 읽어 테스트 작성 컨벤션을 확인하라
2. [template/test-code-template.md](template/test-code-template.md)에서 통합 테스트 코드 템플릿을 확인하라
3. 컨벤션과 템플릿에 따라 테스트 코드를 작성하라
4. Phase 1에서 파악한 각 메서드에 대해 다음 테스트 케이스를 작성하라:
   - 정상 동작 (성공 케이스)
   - 예외 발생 (실패 케이스: 존재하지 않음, 권한 없음, 중복 등)
     - **`RestApiException`을 던지는 케이스는 반드시 `errorCode`까지 검증**한다 (예: `.extracting(e -> ((RestApiException) e).getErrorCode()).isEqualTo({CODE})`). 타입만 검증(`.isInstanceOf(RestApiException.class)` 단독)하면 다른 errorCode로 회귀해도 통과하므로 회귀 감지가 불가능하다.
     - `CustomErrorCode`는 static import로 식별자만 노출한다 (`CustomErrorCode.X` 표기 금지).
   - 엣지 케이스 (경계값, 빈 리스트, null 등 — 해당하는 경우만)

> 다음 Phase 조건: 테스트 파일 작성이 완료되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 4: 검증

1. 작성한 테스트 파일이 컴파일 가능한지 import 누락, 타입 불일치를 점검하라
2. 누락된 테스트 케이스가 없는지 Phase 1의 분기 목록과 대조하라
3. 최종 결과를 사용자에게 보고하라: 작성된 파일 경로, 테스트 메서드 수, 커버한 분기

> Skip 조건: 없음 (필수 Phase)

## Phase 5: 테스트 실행

1. 작성한 테스트 파일을 Bash로 실행하라: `./gradlew test --tests "{패키지}.{테스트클래스명}"` (Testcontainers 자동 실행)
2. 실패한 테스트가 있으면 에러 메시지를 분석하고 수정하라
3. 모든 테스트가 통과할 때까지 수정 → 재실행을 반복하라
4. 최종 통과 결과를 사용자에게 보고하라

> Skip 조건: 없음 (필수 Phase)
