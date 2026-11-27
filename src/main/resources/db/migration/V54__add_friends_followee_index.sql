-- V54__add_friends_followee_index.sql

-- 팔로워 쪽 조회(팔로워 목록, 팔로워 수, 피드 배포 대상)는 followee_id 조건인데 기존 인덱스는 follower_id가 앞이라 쓰지 못한다
-- followee_id로 한 사용자의 팔로워 구간을 찾고, 그 안을 created_at 역순으로 읽어 팔로워 목록이 정렬 없이 LIMIT에서 멈추게 한다
-- follower_id는 조인 키와 반환값으로만 쓰이므로 INCLUDE로 담아 heap 왕복을 줄인다
CREATE INDEX IF NOT EXISTS ix_friends_followee_created
    ON friends (followee_id, created_at DESC) INCLUDE (follower_id);
