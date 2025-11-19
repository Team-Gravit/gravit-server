# Claude Code Development Guidelines

## Core Principles

1. **Code Quality First**: Write maintainable code, not just working code
2. **Verified Logic Only**: Never use speculative or imaginary methods
3. **Official Documentation Based**: Always verify framework/library usage against official docs
4. **Strict Fact-Speculation Separation**: Clearly distinguish between confirmed knowledge and assumptions

## Project Context

- **Tech Stack**: Spring Boot, JPA, MySQL, Flyway
- **Architecture**: Layered Architecture (Facade, Service, Repository)
- **Domain**: CS Learning Platform (Chapter > Unit > Lesson > Problem structure)
- **Core Entities**: User, Progress, League, Season, Mission

## Code Writing Rules

### 1. Follow Existing Code Patterns

- Strictly adhere to existing code style and architectural patterns
- Use Facade Pattern: Business logic combining multiple Services belongs in Facade
- Use Records: Write DTOs as records
- Use Builder Pattern: Apply Builder for complex object creation

### 2. Use Only Real APIs

- Spring Data JPA methods: Use only methods verified in official documentation
- Explicitly mark as "custom method" when creating non-existent methods
- Mark example code explicitly as "example" or "reference only"

### 3. Test Code Required

- Write tests alongside new features
- Use Mockito and AssertJ
- Test method naming: `methodName_testScenario_expectedResult` format

### 4. Exception Handling

- Use custom exceptions (`RestApiException`)
- Manage error codes with `CustomErrorCode` Enum
- Provide clear error messages

### 5. Database

- Manage schema changes with Flyway migration files
- Naming: `V{version}__{description}.sql` format
- Verify JPA Entity and DB schema consistency

## Code Writing Process

### When Implementing New Features

1. **Analyze Requirements**
    - Confirm exactly what needs to be implemented
    - Ask specific questions for unclear points

2. **Understand Existing Code Patterns**
    - Review existing implementations of similar features
    - Follow project code style

3. **Layer-by-Layer Implementation**
    - Order: Entity/Domain → Repository → Service → Facade → Controller
    - Clearly separate responsibilities of each layer

4. **Write Tests**
    - Write unit tests first
    - Consider edge cases

5. **Verification**
    - Check for compilation errors
    - Verify existing tests pass

### When Fixing Bugs

1. **Reproduce the Problem**
    - Write test case that reproduces the bug

2. **Analyze Root Cause**
    - Analyze stack traces and logs
    - Trace actual code flow, not speculation

3. **Minimal Changes**
    - Change only minimum code necessary for bug fix
    - Minimize side effects

4. **Regression Testing**
    - Verify no impact on other features from the fix

## Prohibited Actions

1. **Calling Non-Existent Methods**
    - Verify existence before using methods like `repository.findByXxxAndYyyOrderByZzz()`

2. **Speculative Implementation**
    - Never write code based on "probably works this way" assumptions

3. **Ignoring Existing Architecture**
    - Don't publish Events directly in Service; handle in Facade
    - Don't include business logic in Repository

4. **Adding Unverified Dependencies**
    - Always request confirmation before adding new libraries

## Code Review Checklist

Self-verify the following after writing code:

- [ ] Maintains consistency with existing code patterns
- [ ] Uses only real, existing methods
- [ ] Clear naming (methods, variables, classes)
- [ ] Proper exception handling
- [ ] Tests written
- [ ] Unnecessary comments removed
- [ ] Unused imports removed

## When Uncertain

Always ask questions in the following cases:

- When multiple implementation approaches exist
- When a different approach from existing patterns is needed
- When framework/library behavior is unclear
- When requirements are ambiguous

**If uncertain, ask instead of guessing.**