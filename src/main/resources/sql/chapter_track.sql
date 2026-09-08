-- Chapter 테이블 INSERT 쿼리 (직무 트랙 챕터, id 6~22)
--
-- 기존 CS 기본 챕터(id 1~5)에 이어지는 신규 챕터다.
-- 실행 전제: chapter 테이블에 id 1~5가 이미 존재하고, 6 이상은 비어 있어야 한다.
-- 실행 후 resync_sequences.sql 을 반드시 함께 실행하라 (IDENTITY 시퀀스 재동기화).

INSERT INTO chapter (id, title, description)
VALUES (6, 'Common · Server', '서버 개발에 공통으로 필요한 데이터와 트래픽 처리 지식'),
       (7, 'Common · Web', '브라우저가 웹 페이지를 그리고 다루는 원리'),
       (8, 'Common · AOS', '안드로이드 앱 동작의 공통 기반 지식'),
       (9, 'Common · iOS', 'iOS 앱 동작의 공통 기반 지식'),
       (10, 'BE · Spring', '스프링이 요청과 데이터를 처리하는 방식'),
       (11, 'BE · Node.js', 'Node.js 런타임의 실행 모델과 서버 구성'),
       (12, 'BE · Django', '장고가 요청과 데이터를 처리하는 방식'),
       (13, 'FE · React', '리액트의 렌더링과 상태 관리 원리'),
       (14, 'FE · Vue.js', '뷰의 반응성 시스템과 컴포넌트 설계'),
       (15, 'FE · Next.js', '넥스트의 렌더링 전략과 캐싱 구조'),
       (16, 'Mobile · Android', '안드로이드 앱의 화면 구성과 상태 관리'),
       (17, 'Mobile · iOS', 'SwiftUI 기반 iOS 화면 구성과 상태 관리'),
       (18, 'Language · Java', '자바 언어와 JVM의 동작 원리'),
       (19, 'Language · Kotlin', '코틀린의 안전성과 코루틴 기반 동시성'),
       (20, 'Language · TypeScript', '타입스크립트의 타입 시스템과 활용'),
       (21, 'Language · Python', '파이썬의 실행 모델과 객체 동작 원리'),
       (22, 'Language · Swift', '스위프트의 타입 체계와 동시성 모델');
