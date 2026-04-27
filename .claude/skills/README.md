# Skills

Claude Code가 자동 또는 슬래시 커맨드로 호출하는 작업 스킬입니다.

| Skill | 설명 | 구성 |
|---|---|---|
| `write-test` | 테스트 코드 작성 | SKILL.md + references/ (test-code-template.md, test-classification.md) |
| `run-test` | 테스트 실행 및 결과 분석 | SKILL.md |
| `write-api-docs` | Swagger ControllerDocs 인터페이스 작성 | SKILL.md + references/ (api-docs-template.md) |
| `read-branch-issue` | 현재 브랜치와 연결된 GitHub 이슈 조회 및 숙지 | SKILL.md |

## 구조

각 스킬은 Phase 기반 절차로 구성되어 있으며, 세부 지식(템플릿, 분류 기준 등)은 `references/` 디렉토리에 분리되어 필요한 시점에만 로드됩니다.

```
skills/{skill-name}/
├── SKILL.md              # Phase 기반 실행 절차
└── references/           # 세부 지식 (조건부 로드)
    ├── template.md
    └── classification.md
```

## 사용법

### 슬래시 커맨드 (직접 호출)

```
/write-test BookmarkService          # BookmarkService 테스트 작성
/write-test                          # 대상 클래스를 대화로 확인 후 작성

/run-test                            # 전체 테스트 실행
/run-test UserServiceTest            # 특정 테스트 클래스 실행

/write-api-docs BookmarkController   # BookmarkController의 Docs 인터페이스 작성
/write-api-docs                      # 대상 Controller를 대화로 확인 후 작성
```

### 자동 트리거

"테스트 작성해줘", "API 문서 만들어줘" 등의 요청 시 Claude가 자동으로 해당 skill을 호출합니다.