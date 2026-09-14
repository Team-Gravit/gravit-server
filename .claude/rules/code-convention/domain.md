---
description: Entity(domain) 클래스 작성 패턴
paths:
  - "src/main/java/**/domain/**/*.java"
---

# Domain (Entity) Convention

- `@Entity` + `@Getter` + `@NoArgsConstructor(access = AccessLevel.PROTECTED)`를 사용하라
- 공통 필드가 필요하면 `BaseEntity`를 상속하라 (`createdAt`, `updatedAt` 자동 관리)
  - 테이블에 `created_at`만 있고 `updated_at`이 없으면 `BaseEntity`를 상속하지 말고 `createdAt`을 직접 선언하라 (`Bookmark`, `StagingLabel`, `AuditLog`)
- 검증 로직은 Entity 내부 private 메서드로 구현하라

객체 생성(정적 팩토리 + private `@Builder`)과 예외 처리 규칙은 `common.md`를 따른다.

## DB 매핑

- Entity 클래스명과 테이블명이 다를 경우 `@Table(name = "...")`을 명시하라
- 컬럼명은 `@Column(name = "snake_case", ...)`으로 명시하라 (`@Column(name = "problem_id", nullable = false)`). `@Id` 필드는 `@Column`을 생략한다
- enum 매핑은 `@Enumerated(EnumType.STRING)`을 사용하라. ORDINAL을 사용하지 마라
- ID 생성은 `@GeneratedValue(strategy = GenerationType.IDENTITY)`를 사용하라. 외부에서 id를 적재하는 스테이징 엔티티(`admin/domain/staging`)는 `@GeneratedValue`를 생략한다
- Soft delete가 필요하면 `@SQLRestriction` + `@SQLDelete` 패턴을 사용하라
