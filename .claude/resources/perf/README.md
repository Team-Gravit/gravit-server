# 성능 최적화 기록 (Perf)

`optimize-performance` 스킬이 생성하는 **측정, 개선 기록**을 보관하는 디렉토리다.

대상 하나당 디렉토리 하나를 쓴다. 한 번의 성능 개선에서 나오는 산출물은 모두 그 안에 모인다.

```
{이슈번호}/
├── record.md                  # 측정, 개선 기록
├── seeds.sql                  # 시드 SQL (필요했을 때만)
├── test-script.js             # k6 부하 스크립트
├── k6-test-summary-{n}.json   # k6 요약
├── query-stats-{n}.txt        # pg_stat_statements 통계
└── query-plan-{n}.txt         # 실행계획
```

3사이클을 돈 디렉토리는 이렇게 된다.

```
k6-test-summary-0.json  query-stats-0.txt  query-plan-0.txt   ← 원본
k6-test-summary-1.json  query-stats-1.txt  query-plan-1.txt   ← 사이클 1 적용 후
k6-test-summary-2.json  query-stats-2.txt  query-plan-2.txt   ← 사이클 2 적용 후
k6-test-summary-3.json  query-stats-3.txt  query-plan-3.txt   ← 사이클 3 적용 후
```

산출물 규약(`{n}`의 의미, 각 파일을 만드는 Phase, 원본과 해석의 분리, 상태 저장소)은
`.claude/skills/optimize-performance/SKILL.md`의 **산출물 규약** 절이 기준이다.

템플릿은 `.claude/skills/optimize-performance/template/`에 있고,
각 템플릿 상단의 **작성 규칙**이 해당 산출물의 작성 기준이다.

측정은 로컬 `perf` 프로파일에서 수행한다(`src/main/resources/application-perf.yml`).
