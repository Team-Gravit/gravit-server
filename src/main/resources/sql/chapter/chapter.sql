-- Chapter 테이블 INSERT 쿼리
--
-- [category]
-- CS: 1~5, 23 / COMMON: 6~9 / SERVER: 10~12 / WEB: 13~15 / AOS: 16 / IOS: 17 / LANGUAGE: 18~22
--
-- 실행 후 sync/resync_sequences.sql 을 반드시 함께 실행하라 (IDENTITY 시퀀스 재동기화).

INSERT INTO chapter (id, title, description, category)
VALUES (1, '자료구조', '데이터를 효율적으로 저장하고 관리하는 구조', 'CS'),
       (2, '알고리즘', '문제 해결을 위한 체계적인 절차와 기법', 'CS'),
       (3, '네트워크', '컴퓨터 간 통신을 위한 구조와 프로토콜', 'CS'),
       (4, '데이터베이스', '데이터를 체계적으로 저장하고 관리하는 시스템', 'CS'),
       (5, '운영체제', '컴퓨터 하드웨어와 소프트웨어를 관리하는 시스템', 'CS'),
       (6, 'Server', '서버 개발에 공통으로 필요한 데이터와 트래픽 처리 지식', 'COMMON'),
       (7, 'Web', '브라우저가 웹 페이지를 그리고 다루는 원리', 'COMMON'),
       (8, 'AOS', '안드로이드 앱 동작의 공통 기반 지식', 'COMMON'),
       (9, 'iOS', 'iOS 앱 동작의 공통 기반 지식', 'COMMON'),
       (10, 'Spring', '스프링이 요청과 데이터를 처리하는 방식', 'SERVER'),
       (11, 'Node.js', 'Node.js 런타임의 실행 모델과 서버 구성', 'SERVER'),
       (12, 'Django', '장고가 요청과 데이터를 처리하는 방식', 'SERVER'),
       (13, 'React', '리액트의 렌더링과 상태 관리 원리', 'WEB'),
       (14, 'Vue.js', '뷰의 반응성 시스템과 컴포넌트 설계', 'WEB'),
       (15, 'Next.js', '넥스트의 렌더링 전략과 캐싱 구조', 'WEB'),
       (16, 'Android', '안드로이드 앱의 화면 구성과 상태 관리', 'AOS'),
       (17, 'iOS', 'SwiftUI 기반 iOS 화면 구성과 상태 관리', 'IOS'),
       (18, 'Java', '자바 언어와 JVM의 동작 원리', 'LANGUAGE'),
       (19, 'Kotlin', '코틀린의 안전성과 코루틴 기반 동시성', 'LANGUAGE'),
       (20, 'TypeScript', '타입스크립트의 타입 시스템과 활용', 'LANGUAGE'),
       (21, 'Python', '파이썬의 실행 모델과 객체 동작 원리', 'LANGUAGE'),
       (22, 'Swift', '스위프트의 타입 체계와 동시성 모델', 'LANGUAGE'),
       (23, '웹 보안', '웹 서비스를 노리는 공격 원리와 방어 기법', 'CS');
