UPDATE season
SET
    season_key = '2025-W41',
    starts_at = '2025-10-06 00:00:00',
    ends_at = '2025-10-13 00:00:00',
    status = 'ACTIVE',
    tz = 'Asia/Seoul'
WHERE id = 1
  AND NOT EXISTS (SELECT 1 FROM season WHERE status = 'ACTIVE' AND id <> 1);