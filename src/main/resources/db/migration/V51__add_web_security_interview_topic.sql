-- V51__add_web_security_interview_topic.sql

-- 면접 주제에 웹 보안(WEB_SECURITY)을 추가한다. 챕터 23(웹 보안, CS 분류)의 면접 질문이 쓰는 값이다.
-- topic CHECK 제약은 V41에서 컬럼 정의에 붙여 만들어 이름이 자동으로 정해졌다. 같은 이름으로 다시 만든다.
ALTER TABLE interview_question
    DROP CONSTRAINT IF EXISTS interview_question_topic_check;
ALTER TABLE interview_question
    ADD CONSTRAINT interview_question_topic_check CHECK (topic IN (
        'DATA_STRUCTURE', 'ALGORITHM', 'DATABASE', 'OPERATING_SYSTEM', 'NETWORK', 'WEB_SECURITY',
        'SERVER_COMMON', 'WEB_COMMON', 'AOS_COMMON', 'IOS_COMMON',
        'JAVA', 'KOTLIN', 'NODE_JS', 'PYTHON', 'TYPESCRIPT', 'SWIFT',
        'SPRING_BOOT', 'NEST_JS', 'DJANGO', 'REACT', 'VUE', 'NEXT_JS', 'COMPOSE', 'SWIFTUI'));

ALTER TABLE interview_session_topic
    DROP CONSTRAINT IF EXISTS interview_session_topic_topic_check;
ALTER TABLE interview_session_topic
    ADD CONSTRAINT interview_session_topic_topic_check CHECK (topic IN (
        'DATA_STRUCTURE', 'ALGORITHM', 'DATABASE', 'OPERATING_SYSTEM', 'NETWORK', 'WEB_SECURITY',
        'SERVER_COMMON', 'WEB_COMMON', 'AOS_COMMON', 'IOS_COMMON',
        'JAVA', 'KOTLIN', 'NODE_JS', 'PYTHON', 'TYPESCRIPT', 'SWIFT',
        'SPRING_BOOT', 'NEST_JS', 'DJANGO', 'REACT', 'VUE', 'NEXT_JS', 'COMPOSE', 'SWIFTUI'));
