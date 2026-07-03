---
name: write-api-docs
description: |
  Swagger API 문서(ControllerDocs 인터페이스)를 작성한다.
  Trigger: "API 문서 작성해줘", "Swagger 문서 만들어줘", "Docs 인터페이스 작성해줘", "XXXController 문서화해줘", "API 문서 추가해줘"
  Do NOT use for: DTO에 @Schema만 추가하는 작업(직접 Edit), Controller 로직 수정, 기존 Docs 인터페이스의 단순 오타 수정
  Boundary: Controller 자체의 구현 변경은 이 스킬 범위 밖이다. Docs 인터페이스 생성과 Controller의 implements 연결까지만 수행한다.
allowed-tools: Read, Grep, Glob, Edit, Write
---

# API 문서 작성

대상 Controller: $ARGUMENTS

## Phase 1: 엔드포인트 분석

1. $ARGUMENTS로 지정된 Controller 클래스를 Read로 읽어라
2. 모든 `@GetMapping`, `@PostMapping`, `@PutMapping`, `@PatchMapping`, `@DeleteMapping` 엔드포인트를 목록화하라
3. 각 엔드포인트의 파라미터 타입(PathVariable, RequestParam, RequestBody, AuthenticationPrincipal)을 파악하라
4. 각 엔드포인트의 반환 타입을 파악하라

> 다음 Phase 조건: 모든 엔드포인트의 메서드 시그니처가 파악되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 2: 예외 수집

1. 각 엔드포인트가 호출하는 Facade/Service 메서드를 추적하라 (Read로 해당 파일을 읽어라)
2. 추적한 메서드에서 throw하는 `RestApiException`의 `CustomErrorCode`를 수집하라
3. `CustomErrorCode` enum 파일을 읽어 수집한 코드의 HTTP status, code, message를 확인하라
4. 엔드포인트별로 발생 가능한 에러 목록을 정리하라

> 다음 Phase 조건: 모든 엔드포인트의 에러 코드 목록이 정리되었을 때

> Skip 조건: Controller가 단순 조회(GET)만 있고, Service에서 예외를 던지지 않는 경우 — 이 경우 500 응답만 포함하고 Phase 3으로 진행

## Phase 3: Docs 인터페이스 작성

1. `.claude/spec/api-docs-convention.md`를 읽어 어노테이션 규칙과 작성 컨벤션을 확인하라
2. [template/api-docs-template.md](template/api-docs-template.md)를 읽어 코드 템플릿 구조를 확인하라
3. 컨벤션과 템플릿에 따라 `controller/docs/{Controller}Docs.java` 파일을 생성하라

> 다음 Phase 조건: Docs 인터페이스 파일이 작성되었을 때

> Skip 조건: 없음 (필수 Phase)

## Phase 4: Controller 연결 및 검증

1. Controller 클래스가 생성한 Docs 인터페이스를 `implements` 하고 있는지 확인하라
2. `implements`가 없으면 Controller 클래스에 추가하라
3. Docs 인터페이스의 메서드 시그니처와 Controller의 실제 메서드 시그니처가 일치하는지 대조하라
4. `@ExampleObject`에 사용한 에러코드 값이 `CustomErrorCode` enum과 일치하는지 최종 확인하라
5. 결과를 사용자에게 보고하라: 생성된 파일 경로, 문서화된 엔드포인트 수, 매핑된 에러코드 수

> Skip 조건: 없음 (필수 Phase)