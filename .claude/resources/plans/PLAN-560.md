# [PLAN-560] 면접 질문 음성(TTS) 키 컬럼 추가와 기존 문항 백필

> 이슈: #560
> 브랜치: feat/560-interview-question-audio-key

## 목표
생성기 레포(gravit-interview-contents-generator#8)가 1,135문항의 질문 음성(mp3)을 면접 음성 버킷 `interview-question/{문제 id}.mp3`에 올렸다. 이 키를 `interview_question.audio_key`에 저장할 수 있게 스키마와 엔티티를 넓히고, 이미 적재된 문항에 키를 채운다. 재생 URL 발급은 후속 이슈다.

## 영향 범위
### 신규 파일
- `src/main/resources/db/migration/V46__add_audio_key_to_interview_question.sql` — `audio_key` 컬럼 추가
- `src/main/resources/sql/backfill/interview_question_audio_key.sql` — 이미 적재된 DB의 기존 행에 키를 채우는 수동 실행 SQL (로컬 자동 실행 X)
- `src/test/java/gravit/code/interviewQuestion/repository/InterviewQuestionRepositoryIntegrationTest.java` — `audio_key` 매핑 검증

### 수정 파일
- `src/main/java/gravit/code/interviewQuestion/domain/InterviewQuestion.java` — `audioKey` 필드 추가
- `src/main/resources/sql/interview/**/*.sql` (227파일) — `INSERT INTO interview_question` 컬럼 목록과 각 행에 `audio_key` 추가 (결정 D2)
- `src/main/resources/sql/README.md` — 폴더 표에 `backfill/` 행 추가, 실행 순서에 백필 절 추가
- `.claude/spec/service-policy/interview.md` — "문제 콘텐츠 관리"에 문항 음성 규칙 추가, P11에 문항 음성 재생 URL 미발급을 추가 (**정책 추가**)

## 구현 계획

1. **Flyway**: `V46__add_audio_key_to_interview_question.sql`
   ```sql
   -- V46__add_audio_key_to_interview_question.sql

   -- 면접 질문 음성(TTS) 오브젝트 키. 콘텐츠 생성 파이프라인이 합성, 업로드하고 키만 저장한다. 음성이 없는 문항은 NULL
   ALTER TABLE interview_question ADD COLUMN audio_key VARCHAR(255);
   ```
   - 타입은 답변 음성 선례 `interview_answer.audio_key VARCHAR(255)`(nullable)와 같다
   - NOT NULL 전환은 전 문항 백필과 생성 파이프라인 편입이 끝난 뒤 별도 마이그레이션으로 판단한다(이번 범위 밖)
   - 착수 시 `origin/dev` 최신 버전을 다시 확인한다(작성 시점 V45, 다른 브랜치에 V46 없음 확인)

2. **Entity**: `InterviewQuestion`
   - 필드 추가 (`active` 아래)
     ```java
     @Column(name = "audio_key")
     private String audioKey;
     ```
   - `create(...)`와 private 생성자 시그니처는 바꾸지 않는다. 문제는 시드 SQL로만 적재되고 애플리케이션이 문제를 생성하는 경로가 없어, 파라미터를 늘리면 테스트 fixture만 바뀌고 쓰는 곳이 없다. 음성 키는 적재 시 SQL로 들어온다
   - 조회는 `@Getter`의 `getAudioKey()`로 한다. 이번 이슈에서 이를 읽는 운영 코드는 없다(재생 URL 발급 후속 이슈가 사용)

3. **키 정책**: 서버 코드에 두지 않는다 (결정 D1)
   - 형식 `interview-question/{문제 id}.mp3`는 서비스 정책 문서에 규칙으로 적는다. 키를 만드는 주체는 콘텐츠 생성 파이프라인이고 서버는 저장된 값을 그대로 쓴다

4. **시드 SQL 227파일** (결정 D2)
   - 헤더 `INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer)`에 `, audio_key`를 붙인다
   - 각 행의 `model_answer` 리터럴 뒤에 `,\n 'interview-question/{id}.mp3'`를 붙인다. 기존 행 서식(값마다 줄바꿈, 앞 공백 1칸)을 따른다
   - 변환은 생성기 레포 스크립트로 한다. 변환 전후 diff가 `audio_key` 컬럼과 값만 바뀌었는지, 키를 붙인 문항이 생성기 manifest의 dev 업로드 확인 목록(1,135건)과 일치하는지 검증한다
   - 생성기 SQL 빌더(생성기 Step 7)는 이 파일을 바이트 단위로 재현하는 것을 목표로 한다

5. **백필 SQL**: `sql/backfill/interview_question_audio_key.sql`
   - 이미 적재된 dev, prod DB의 기존 행에 키를 채운다. `psql`로 수동 실행하며 `spring.sql.init` 대상이 아니다
   - **본문 해시로 대조한 행만 채운다.** 한 문장 UPDATE에 `(id, content_md5, audio_key)` 1,135행 VALUES를 조인한다. DB의 `content`가 시드와 다르면 그 행은 갱신되지 않아, 다른 문항의 음성을 가리키는 키가 들어가지 않는다
     ```sql
     -- 면접 질문 음성 키 백필. 시드와 본문(md5)이 같은 행에만 키를 채운다
     UPDATE interview_question q
     SET audio_key = v.audio_key
     FROM (VALUES
         (1, '{md5}', 'interview-question/1.mp3'),
         ...
     ) AS v(id, content_md5, audio_key)
     WHERE q.id = v.id
       AND md5(q.content) = v.content_md5
       AND q.audio_key IS NULL;
     ```
   - 파일 끝에 검증 쿼리를 주석이 아닌 SELECT로 둔다. 실행자가 결과를 보고 판단한다
     ```sql
     -- 검증: missing, malformed가 모두 0이어야 한다. missing이 남으면 그 행은 본문이 시드와 달라 채우지 않은 것이다
     SELECT COUNT(*) FILTER (WHERE audio_key IS NULL) AS missing,
            COUNT(*) FILTER (WHERE audio_key <> 'interview-question/' || id || '.mp3') AS malformed
     FROM interview_question;
     ```
   - VALUES 목록은 생성기 레포에서 시드 SQL(`origin/dev`)의 `(id, content)`로 만든다. `md5(text)`는 UTF-8 바이트 기준이라 Python `hashlib.md5(content.encode("utf-8"))`와 같다
   - 비활성 문항도 채운다. 이미 출제된 세션에서 재생될 수 있기 때문이다

6. **README**: `sql/README.md`
   - 폴더 표에 `| backfill/ | 이미 적재된 DB의 기존 행 보정. 운영자가 psql로 수동 실행 | X |` 추가
   - "실행 순서" 아래에 "백필" 절: 로컬은 시드에 키가 들어 있어 필요 없고, dev, prod에서 V46 배포 후 한 번 실행한다

7. **서비스 정책**: `interview.md`
   - "문제 콘텐츠 관리"에 추가
     - 문제는 질문을 읽어 주는 음성(mp3)을 가질 수 있다. 음성이 없는 문제도 출제된다
     - 질문 음성 키는 `interview-question/{문제 id}.mp3`다. 콘텐츠 생성 파이프라인이 문제 본문을 낭독 대본으로 바꿔 합성하고 업로드한 뒤 키를 문제에 기록한다. 서버는 질문 음성을 만들거나 올리지 않는다
     - 문제는 수정하지 않으므로 질문 음성도 바뀌지 않는다. 문제를 고치면 새 문제 id로 새 음성이 생긴다. 비활성화된 문제의 음성은 지우지 않는다
     - 질문 음성은 답변 음성(`interview/`)과 접두사가 달라 회원 탈퇴 시 파기 대상이 아니다
   - P11 "남은 것"에 "질문 음성 재생 URL 미발급"을 추가한다

8. **Repository / Service / Facade / DTO / Controller**: 변경 없음. 이번 이슈는 저장까지다. Facade 불필요

## 결정 필요 (Decisions needed)
- [x] D1. 키 형식을 서버 코드에 둘지 — **확정: A 두지 않고 정책 문서에만**. 재생은 presigned GET으로 하며 저장된 키를 그대로 서명하면 되므로 형식이 필요 없다. NULL이면 음성 없음으로 응답해 프론트가 텍스트만 보여 준다(후속 이슈). / B `InterviewQuestionAudioKeyPolicy.issue(long questionId)`를 만든다. 서버는 저장된 키를 읽기만 하고 만들지 않아, B는 운영 코드 호출처가 없는 클래스가 된다. 재생 URL 발급도 저장된 키로 서명하면 되므로 형식을 몰라도 된다
- [x] D2. 시드 SQL 227파일의 `audio_key` 반영 시점 — **확정: A 이번 PR에서 변환 스크립트로 반영** / B 생성기 SQL 빌더(Step 7) 완성 후 별도 PR. A는 이번 PR로 로컬 시드와 dev/prod가 같은 상태가 되고, 빌더의 골든 대조 기준도 키가 들어간 파일이 된다. B는 빌더 완성 전까지 로컬 DB에 키가 없다

## 검증
- `./gradlew build`의 `flywayValidate`로 V46 적용 확인
- `InterviewQuestionRepositoryIntegrationTest`
  - `음성_키를_저장하고_다시_읽는다`: fixture 문제에 `ReflectionTestUtils.setField(question, "audioKey", "interview-question/1.mp3")` 후 저장, `flush`, `clear`, `findById` → `getAudioKey()`가 같다
  - `음성_키가_없는_문제는_null로_읽힌다`: fixture 그대로 저장 후 조회 → `getAudioKey()`가 null
- 시드 SQL: 변환 전후 diff가 `audio_key` 컬럼·값만인지(생성기 스크립트 검증), 로컬 기동(`spring.sql.init`)으로 227파일이 적재되고 `SELECT COUNT(*) FROM interview_question WHERE audio_key IS NULL`이 0인지 확인
- 백필 SQL: 로컬 DB에서 `audio_key`를 NULL로 되돌린 뒤 실행해 검증 쿼리가 0, 0인지 확인. content 하나를 바꾼 행은 채워지지 않는지 확인

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
- `InterviewQuestionRepositoryIntegrationTest`: 시드 SQL 적재 케이스(`모든_문제에_문제_id로_만든_음성_키가_들어간다`) 추가 — 이유: 계획서 검증의 "로컬 기동으로 227파일 적재 확인"을 수동 확인 대신 로컬 기동과 같은 Spring `ScriptUtils`(`ResourceDatabasePopulator`)로 자동화해, 변환한 227파일이 PostgreSQL에서 실제로 적재되고 1,135문항 모두 키를 갖는지 회귀 테스트로 남긴다
