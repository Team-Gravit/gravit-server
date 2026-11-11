# [PLAN-611] 면접 직군 카드 설명 문구 서버 제공

> 이슈: #611
> 브랜치: feat/611-stack-group-description

## 목표
직군 그룹 조회 API(`GET /api/v1/interview-stack-groups`)가 설명 값을 내려주지 않아 웹과 앱이 각자 고정 문구를 쓰고, Server 카드는 Java만 되는 것처럼 보인다.
직군 그룹에 설명을 추가해 서버가 내려주고, 그룹에 속한 스택의 프레임워크가 설명에서 빠지지 않도록 테스트로 묶는다.

## 영향 범위
### 신규 파일
- 없음

### 수정 파일
- `src/main/java/gravit/code/interview/domain/InterviewStackGroup.java` - `description` 필드와 그룹별 설명 값 추가
- `src/main/java/gravit/code/interview/dto/response/InterviewStackGroupResponse.java` - `displayName` 다음에 `description` 컴포넌트 추가, `from`에서 채움
- `src/main/java/gravit/code/interview/controller/docs/InterviewStackGroupControllerDocs.java` - `getStackGroups` 200 응답 예시에 `description` 추가
- `src/test/java/gravit/code/interview/service/InterviewStackQueryServiceIntegrationTest.java` - 그룹별 설명 값 테스트, 프레임워크 누락 방지 테스트 추가
- `.claude/spec/service-policy/interview.md` - 정책 추가: 스택 절에 직군 그룹 설명 값과 작성 규칙

## 구현 계획
1. **Entity / Flyway**: 변경 없음 (enum 상수 값만 바뀌고 DB에 저장되는 값은 그룹 이름 그대로)
   - `InterviewStackGroup`에 `private final String description;`을 `displayName`과 `displayOrder` 사이에 추가한다
   - 상수는 `(displayName, description, displayOrder)` 순서로 바꾼다
     - `SERVER("Server", "Spring Boot / NestJS / Django", 1)`
     - `WEB("Web", "React / Vue.js / Next.js", 2)`
     - `AOS("AOS", "Jetpack Compose / Kotlin", 3)`
     - `IOS("iOS", "SwiftUI / Swift", 4)`
   - `@Getter`가 `getDescription()`을 만든다. `@RequiredArgsConstructor`도 필드 선언 순서를 따르므로 그대로 둔다
2. **Repository**: 변경 없음
3. **Service**: 변경 없음. `InterviewStackQueryService.getStackGroups()`가 `InterviewStackGroupResponse::from`으로 매핑하므로 응답 팩토리만 고치면 설명이 나간다
4. **Facade**: 불필요 - 단일 Service, 기존 흐름(Controller → `InterviewStackQueryService`) 유지
5. **DTO**: `InterviewStackGroupResponse`
   - `displayName` 다음에 `String description` 컴포넌트를 추가한다. 기존 `stackGroup`, `displayName`의 이름과 순서는 그대로 둔다
   - `@Schema`는 기존 형식을 따른다
     ```java
     @Schema(
             description = "직군 그룹 설명",
             example = "Spring Boot / NestJS / Django",
             requiredMode = Schema.RequiredMode.REQUIRED
     )
     String description
     ```
   - `from(InterviewStackGroup stackGroup)`에 `.description(stackGroup.getDescription())`을 추가한다
6. **Controller**: 변경 없음 (`GET /api/v1/interview-stack-groups → InterviewStackGroupController.getStackGroups`)
   - Docs만 수정: `InterviewStackGroupControllerDocs.getStackGroups`의 200 응답 `@ExampleObject` value를 아래로 바꾼다. summary, description, 500 응답은 그대로
     ```json
     [
       { "stackGroup": "SERVER", "displayName": "Server", "description": "Spring Boot / NestJS / Django" },
       { "stackGroup": "WEB", "displayName": "Web", "description": "React / Vue.js / Next.js" },
       { "stackGroup": "AOS", "displayName": "AOS", "description": "Jetpack Compose / Kotlin" },
       { "stackGroup": "IOS", "displayName": "iOS", "description": "SwiftUI / Swift" }
     ]
     ```
7. **Test**: `InterviewStackQueryServiceIntegrationTest.GetStackGroups`에 2개 추가. 기존 테스트는 그대로 둔다
   - `그룹별_설명을_돌려준다()`
     - when: `getStackGroups()`
     - then: `description`이 `"Spring Boot / NestJS / Django"`, `"React / Vue.js / Next.js"`, `"Jetpack Compose / Kotlin"`, `"SwiftUI / Swift"` 순서 (`containsExactly`)
   - `@ParameterizedTest @EnumSource(InterviewStackGroup.class)` `그룹_설명에_소속_스택의_프레임워크가_모두_들어있다(InterviewStackGroup stackGroup)`
     - when: `getStackGroups()`에서 `stackGroup`이 같은 응답의 `description`을 고르고, `getStacks(stackGroup)`으로 소속 스택을 가져온다
     - then: 모든 스택에 대해 `description`이 `stack.stack().getFrameworkTopic().getDisplayName()`을 포함한다 (`allSatisfy`)
     - 스택이 추가되고 설명을 안 고치면 이 테스트가 깨진다. AOS는 프레임워크 표시명이 `Compose`라 `Jetpack Compose`에 포함돼 통과한다
8. **Policy**: `interview.md` 스택 절, 기존 불릿 두 개 뒤에 아래를 추가한다
   - 문장: "직군 그룹 목록에는 그룹마다 설명이 함께 나간다. 직군 카드에 보이는 기술 문구다."
   - 표: `| 그룹 | 설명 |` - SERVER `Spring Boot / NestJS / Django`, WEB `React / Vue.js / Next.js`, AOS `Jetpack Compose / Kotlin`, IOS `SwiftUI / Swift`
   - 불릿: "그룹 설명은 그룹에 속한 스택의 프레임워크를 노출 순서대로 ` / `로 잇는다. 프레임워크가 하나뿐인 그룹은 언어를 덧붙인다"
   - 불릿: "스택을 추가하면 그 스택의 프레임워크가 그룹 설명에 들어가도록 설명을 함께 고친다"

## 결정 필요 (Decisions needed)
- 없음 (설명 문구는 이슈 발의 단계에서 추천 값으로 확정)

## 검증
- 대상 테스트: `InterviewStackQueryServiceIntegrationTest` 전체 (기존 4개 + 신규 `그룹별_설명을_돌려준다`, `그룹_설명에_소속_스택의_프레임워크가_모두_들어있다` 4건)
- 컴파일: `./gradlew compileJava compileTestJava`

## Deviation Log
