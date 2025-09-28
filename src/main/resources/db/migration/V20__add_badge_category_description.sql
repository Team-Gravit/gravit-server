ALTER TABLE badge_category
    ADD COLUMN IF NOT EXISTS description VARCHAR (255);

UPDATE badge_category
SET description = CASE name
    WHEN '연속 학습' THEN '매일 한 개 이상의 레슨 풀이시, 연속학습 유지'
    WHEN '풀이 속도' THEN '85% 이상의 정답률만 인정해요'
    WHEN '행성 완료' THEN '챕터 완료시 각 챕터에 맞는 행성 뱃지 획득'
    WHEN '미션 완료' THEN '오늘의 미션을 특정 개수 이상 완료시 획득'
END
WHERE (description IS NULL OR description = '')
  AND name IN ('연속학습', '풀이 속도', '행성 완료', '미션완료');
