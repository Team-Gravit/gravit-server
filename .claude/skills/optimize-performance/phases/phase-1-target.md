## Phase 1. 개선 대상 확정

### 목적
이슈와 작업 브랜치를 확보하고, 개선 대상 API의 실행 경로를 파악한 뒤 `record.md`를 생성한다.

### 선행 조건
- SKILL.md에서 전달받은 대상 API가 있다. 비어있다면 중단하고 호출자에게 질의한다.

### 참조 파일
- `.claude/skills/optimize-performance/template/PERF-template.md`
- `.claude/spec/git-convention.md`

### 절차

1. 현재 브랜치에서 이슈 번호를 확보한다.

   ```bash
   git branch --show-current
   ```

   - 브랜치명이 `{종류}/{이슈번호}-{slug}` 형식이면 이슈 번호를 뽑아 이슈를 조회한다.

     ```bash
     gh issue view {이슈번호} --json number,title,state,url
     ```

   - 조회 결과(번호, 제목, 상태)를 호출자에게 보고하고, 이 이슈로 진행할지 확답을 받는다.
   - 이슈가 `CLOSED`면 그 사실을 함께 알리고, 확답 전까지 다음 단계로 넘어가지 마라.
   - 브랜치에서 번호를 못 뽑거나, 호출자가 다른 이슈를 원하면 `open-issue` 스킬을 호출해 이슈와 브랜치를 확보한다.

2. 대상 API의 처리 경로를 Controller → Facade → Service → Repository 순으로 읽는다.
   - 호출되는 Repository 메서드와 쿼리를 모두 나열한다.
   - 지연 로딩 지점을 모두 표시한다.

3. 작업 디렉토리 `.claude/resources/perf/{이슈번호}/`를 만들고 그 안에 `record.md`를 생성한다.
   - `template/PERF-template.md`를 Read해 그 구조 그대로 만든다.
   - 이 대상에서 만드는 산출물(시드 SQL, k6 스크립트, k6 요약)은 모두 이 디렉토리 안에 둔다.
   - **대상**과 **진행 상태**의 Phase 1을 채운다.
   - 작업 디렉토리를 셸 변수로 잡도록 호출자에게 제시한다. 이후 모든 셸 명령이 이 변수를 쓴다.

     ```bash
     export PERF_DIR=.claude/resources/perf/{이슈번호}
     ```

### 출력
- `.claude/resources/perf/{이슈번호}/record.md` 생성
- `.claude/resources/perf/{이슈번호}/record.md`의 진행 상태의 Phase 1이 ✅로 기록

### 실패 처리
- 없음

> 다음 Phase 조건: 이슈 번호를 확보했고, 예상 쿼리 목록이 `record.md`에 적혔을 때 → Phase 2

> Skip 조건: 없음 (필수 Phase)
