-- V46__add_audio_key_to_interview_question.sql

-- 면접 질문 음성(TTS) 오브젝트 키. 콘텐츠 생성 파이프라인이 합성, 업로드하고 키만 저장한다. 음성이 없는 문항은 NULL
ALTER TABLE interview_question ADD COLUMN audio_key VARCHAR(255);
