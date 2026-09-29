# sql

수동 적재용 콘텐츠, 시드 SQL. Flyway 마이그레이션(`db/migration`)과 별개다.
로컬 기동 시 `application.yml`의 `spring.sql.init.data-locations`에 등록된 파일만 자동 실행된다.

| 폴더 | 내용 | 로컬 자동 실행 |
|---|---|---|
| `chapter/` | 챕터. `chapter.sql`(CS 1~5), `chapter_track.sql`(직무 트랙 6~22) | O |
| `unit/` | 유닛. `unit.sql`(CS 1~69), `unit_track.sql`(직무 트랙 70~227) | O |
| `league/` | 리그 티어 | O |
| `problem/{챕터}/` | 유닛별 레슨, 문제, 선지, 정답 | O |
| `interview/{챕터}/` | 유닛별 면접 질문, 핵심 개념 | O |
| `sync/` | IDENTITY 시퀀스 재동기화 | O (마지막) |
| `seed/` | DEV 전용 더미 데이터 | X |
| `backfill/` | 이미 적재된 DB의 기존 행 보정. 운영자가 psql로 수동 실행 | X |

## 실행 순서

1. `chapter/` → `unit/` → `league/`
2. `problem/`, `interview/`
3. `sync/resync_sequences.sql` - 모든 시드가 id를 직접 지정하므로 적재 후 반드시 실행한다

## 백필

이미 적재된 dev, prod DB에 스키마 변경 후 값을 채울 때 쓴다. 로컬은 시드에 값이 들어 있어 실행하지 않는다.

- `backfill/interview_question_audio_key.sql` - V46 배포 후 한 번 실행한다. 본문이 시드와 같은 행에만 면접 질문 음성 키를 채우고, 끝의 검증 쿼리가 `missing = 0`, `malformed = 0`이어야 한다

## 작성 주의

로컬 기동은 Spring `ScriptUtils`로 스크립트를 읽는다. psql과 달리 다음 두 경우를 잘못 읽으므로,
해당 값은 줄바꿈을 `\n`으로 쓴 `E'...'` 한 줄 문자열로 작성한다.

- 문자열 안의 줄이 `--`로 시작하면 주석으로 보고 그 줄을 버린다
- 따옴표 앞의 백슬래시를 이스케이프로 보고 따옴표를 건너뛴다

## 로컬 application.yml 예시

```yaml
spring:
  sql:
    init:
      mode: always
      data-locations:
        - classpath:sql/chapter/chapter.sql
        - classpath:sql/chapter/chapter_track.sql
        - classpath:sql/league/league.sql
        - classpath:sql/unit/unit.sql
        - classpath:sql/unit/unit_track.sql
        - classpath*:sql/problem/**/*.sql
        - classpath*:sql/interview/**/*.sql
        - classpath:sql/sync/resync_sequences.sql
```
