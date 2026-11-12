-- 공지 요약(summary) 추가. 기존 row 는 '' 로 백필 후 사용.
ALTER TABLE notice ADD COLUMN summary VARCHAR(255) NOT NULL DEFAULT '';

-- soft delete 마커 (nullable). @SQLDelete/@SQLRestriction 와 정합.
ALTER TABLE notice ADD COLUMN deleted_at TIMESTAMP(6);

-- 마크다운 본문 수용을 위해 content 를 TEXT 로 확장 (기존 VARCHAR(255)).
ALTER TABLE notice ALTER COLUMN content TYPE TEXT;
