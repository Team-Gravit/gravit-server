# 성능 최적화 기록 (Perf)

`optimize-performance` 스킬이 생성하는 **측정, 개선 기록**을 보관하는 디렉토리다.

이슈 하나당 디렉토리 하나, 대상 엔드포인트 하나당 그 아래 하위 디렉토리 하나를 쓴다.
시드와 토큰은 이슈 전체가 공유하고, 나머지는 전부 대상별로 독립이다.

```
{이슈번호}/
├── seeds.sql                          # 시드 변수 + 모듈 \i (이슈 공용)
├── tokens.json                        # 측정용 JWT (이슈 공용, gitignore 대상)
└── {엔드포인트-슬러그}/
    ├── record.md                      # 이 대상의 측정, 개선 기록 + 진행 상태
    ├── test-script.js                 # k6 부하 스크립트
    ├── k6-test-summary-{n}.json       # k6 요약 (가공본)
    ├── query-stats-summary-{n}.txt    # pg_stat_statements 통계 (가공본)
    └── query-plan-{n}.txt             # 실행계획 (원본)
```

한 이슈에서 API 3종을 잰 디렉토리는 이렇게 된다.

```
472/
├── seeds.sql
├── tokens.json
├── weak-concepts/     record.md  test-script.js  k6-test-summary-0.json  ...
├── top-chapters/      record.md  test-script.js  k6-test-summary-0.json  ...
└── weekly-report/     record.md  test-script.js  k6-test-summary-0.json  ...
```

3사이클을 돈 대상 디렉토리는 이렇게 된다.

```
k6-test-summary-0.json  query-stats-summary-0.txt  query-plan-0.txt   ← 원본 상태
k6-test-summary-1.json  query-stats-summary-1.txt  query-plan-1.txt   ← 사이클 1 적용 후
k6-test-summary-2.json  query-stats-summary-2.txt  query-plan-2.txt   ← 사이클 2 적용 후
k6-test-summary-3.json  query-stats-summary-3.txt  query-plan-3.txt   ← 사이클 3 적용 후
```

산출물 규약(`{n}`의 의미, 각 파일을 만드는 Phase, 측정 산출물의 형태, 상태 저장소)은
`.claude/skills/optimize-performance/SKILL.md`의 **산출물 규약** 절이 기준이다.

- `k6-test-summary-{n}.json`과 `query-stats-summary-{n}.txt`는 **가공본**이다.
  명령으로 뽑은 1차 출력을 스킬이 읽고 같은 경로에 소비 가능한 형태로 다시 쓴다. 1차 출력은 보존하지 않는다.
- `query-plan-{n}.txt`는 **원본**이다. 노드 트리 전체가 근거이므로 요약이 원본을 대신할 수 없다.
- `tokens.json`은 실 JWT다. gitignore 대상이며 Phase 9에서 삭제한다.

템플릿은 `.claude/skills/optimize-performance/template/`에 있고,
각 템플릿 상단의 **작성 규칙**이 해당 산출물의 작성 기준이다.
시드는 `template/seeds/`의 도메인별 모듈을 조합해 쓴다. 규모는 psql 변수로만 조절한다.

측정은 로컬 `perf` 프로파일에서 수행한다(`src/main/resources/application-perf.yml`).
