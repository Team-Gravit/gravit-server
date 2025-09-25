-- 리그 이름 한글화 (기존 데이터 수정)
UPDATE league
SET name = CASE id
               WHEN 1 THEN '브론즈 1'
               WHEN 2 THEN '브론즈 2'
               WHEN 3 THEN '브론즈 3'
               WHEN 4 THEN '실버 1'
               WHEN 5 THEN '실버 2'
               WHEN 6 THEN '실버 3'
               WHEN 7 THEN '골드 1'
               WHEN 8 THEN '골드 2'
               WHEN 9 THEN '골드 3'
               WHEN 10 THEN '플래티넘 1'
               WHEN 11 THEN '플래티넘 2'
               WHEN 12 THEN '플래티넘 3'
               WHEN 13 THEN '다이아몬드 1'
               WHEN 14 THEN '다이아몬드 2'
               WHEN 15 THEN '다이아몬드 3'
    END
WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);