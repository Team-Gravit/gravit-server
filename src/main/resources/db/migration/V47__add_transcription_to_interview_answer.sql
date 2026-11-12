-- V47__add_transcription_to_interview_answer.sql

-- 음성 답안의 STT 변환 결과. 사용자가 수정해 제출한 content와 따로 보관한다
ALTER TABLE interview_answer ADD COLUMN transcript TEXT;

-- 변환 상태. 변환을 요청하지 않은 답안(텍스트 세션 포함)은 NULL
ALTER TABLE interview_answer ADD COLUMN transcription_status VARCHAR(255)
    CHECK (transcription_status IN ('PENDING', 'COMPLETED', 'FAILED'));

-- 마지막 변환 요청 시각. PENDING 고착 판정에 쓴다
ALTER TABLE interview_answer ADD COLUMN transcription_requested_at TIMESTAMP(6);
