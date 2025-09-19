-- Gravit 프로젝트 ERDCloud용 DDL 스크립트
-- 생성일: 2025-09-19

-- 사용자 테이블
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL,
    provider_id VARCHAR(255) NOT NULL,
    nickname VARCHAR(255) NOT NULL,
    handle VARCHAR(255) UNIQUE,
    level INTEGER NOT NULL,
    xp INTEGER NOT NULL,
    deleted_at TIMESTAMP,
    profile_img_number INTEGER NOT NULL,
    is_onboarded BOOLEAN NOT NULL,
    status VARCHAR(20) NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 리그 테이블
CREATE TABLE league (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    max_lp INTEGER NOT NULL,
    min_lp INTEGER NOT NULL,
    sort_order INTEGER NOT NULL UNIQUE
);

-- 시즌 테이블
CREATE TABLE season (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    season_key VARCHAR(16) NOT NULL UNIQUE,
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    tz VARCHAR(50) NOT NULL
);

-- 사용자 리그 테이블
CREATE TABLE user_league (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    season_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    league_id BIGINT NOT NULL,
    league_point INTEGER NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (season_id) REFERENCES season(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (league_id) REFERENCES league(id)
);

-- 챕터 테이블
CREATE TABLE chapter (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NOT NULL UNIQUE,
    total_units BIGINT NOT NULL
);

-- 유닛 테이블
CREATE TABLE unit (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    total_lessons BIGINT NOT NULL,
    chapter_id BIGINT NOT NULL,
    FOREIGN KEY (chapter_id) REFERENCES chapter(id)
);

-- 레슨 테이블
CREATE TABLE lesson (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    total_problems BIGINT NOT NULL,
    unit_id BIGINT NOT NULL,
    FOREIGN KEY (unit_id) REFERENCES unit(id)
);

-- 문제 테이블
CREATE TABLE problem (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    problem_type VARCHAR(20) NOT NULL,
    question TEXT NOT NULL,
    content TEXT NOT NULL,
    answer TEXT NOT NULL,
    lesson_id BIGINT NOT NULL,
    FOREIGN KEY (lesson_id) REFERENCES lesson(id)
);

-- 선택지 테이블
CREATE TABLE `option` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    content TEXT NOT NULL,
    explanation TEXT NOT NULL,
    is_answer BOOLEAN NOT NULL,
    problem_id BIGINT NOT NULL,
    FOREIGN KEY (problem_id) REFERENCES problem(id)
);

-- 문제 진행도 테이블
CREATE TABLE problem_progress (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    is_correct BOOLEAN NOT NULL,
    incorrect_counts BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    problem_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (problem_id) REFERENCES problem(id)
);

-- 친구 테이블
CREATE TABLE friends (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    follower_id BIGINT NOT NULL,
    followee_id BIGINT NOT NULL,
    FOREIGN KEY (follower_id) REFERENCES users(id),
    FOREIGN KEY (followee_id) REFERENCES users(id)
);

-- 미션 테이블
CREATE TABLE mission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    mission_type VARCHAR(50) NOT NULL,
    progress_rate DOUBLE PRECISION NOT NULL,
    is_completed BOOLEAN NOT NULL,
    user_id BIGINT NOT NULL UNIQUE,
    version BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 신고 테이블
CREATE TABLE report (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    report_type VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    problem_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    is_resolved BOOLEAN NOT NULL,
    submitted_at TIMESTAMP NOT NULL,
    FOREIGN KEY (problem_id) REFERENCES problem(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 공지사항 테이블
CREATE TABLE notice (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,
    pinned BOOLEAN NOT NULL,
    published_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- 사용자 리그 히스토리 테이블 (추가 엔티티로 추정)
CREATE TABLE user_league_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    season_id BIGINT NOT NULL,
    league_id BIGINT NOT NULL,
    final_lp INTEGER NOT NULL,
    final_rank INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (season_id) REFERENCES season(id),
    FOREIGN KEY (league_id) REFERENCES league(id)
);

-- 챕터 진행도 테이블
CREATE TABLE chapter_progress (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    chapter_id BIGINT NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completion_rate DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (chapter_id) REFERENCES chapter(id)
);

-- 유닛 진행도 테이블
CREATE TABLE unit_progress (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    unit_id BIGINT NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completion_rate DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (unit_id) REFERENCES unit(id)
);

-- 레슨 진행도 테이블
CREATE TABLE lesson_progress (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    lesson_id BIGINT NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completion_rate DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (lesson_id) REFERENCES lesson(id)
);

-- 학습 테이블
CREATE TABLE learning (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    lesson_id BIGINT NOT NULL,
    learning_time INTEGER NOT NULL,
    accuracy_rate DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (lesson_id) REFERENCES lesson(id)
);