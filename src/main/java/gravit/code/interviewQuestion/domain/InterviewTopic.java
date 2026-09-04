package gravit.code.interviewQuestion.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum InterviewTopic {

    DATA_STRUCTURE(InterviewTopicKind.CS, "자료구조"),
    ALGORITHM(InterviewTopicKind.CS, "알고리즘"),
    DATABASE(InterviewTopicKind.CS, "데이터베이스"),
    OPERATING_SYSTEM(InterviewTopicKind.CS, "운영체제"),
    NETWORK(InterviewTopicKind.CS, "네트워크"),

    SERVER_COMMON(InterviewTopicKind.COMMON, "서버 공통"),
    WEB_COMMON(InterviewTopicKind.COMMON, "웹 공통"),
    AOS_COMMON(InterviewTopicKind.COMMON, "안드로이드 공통"),
    IOS_COMMON(InterviewTopicKind.COMMON, "iOS 공통"),

    JAVA(InterviewTopicKind.LANGUAGE, "Java"),
    KOTLIN(InterviewTopicKind.LANGUAGE, "Kotlin"),
    NODE_JS(InterviewTopicKind.LANGUAGE, "Node.js"),
    PYTHON(InterviewTopicKind.LANGUAGE, "Python"),
    TYPESCRIPT(InterviewTopicKind.LANGUAGE, "TypeScript"),
    SWIFT(InterviewTopicKind.LANGUAGE, "Swift"),

    SPRING_BOOT(InterviewTopicKind.FRAMEWORK, "Spring Boot"),
    NEST_JS(InterviewTopicKind.FRAMEWORK, "NestJS"),
    DJANGO(InterviewTopicKind.FRAMEWORK, "Django"),
    REACT(InterviewTopicKind.FRAMEWORK, "React"),
    VUE(InterviewTopicKind.FRAMEWORK, "Vue.js"),
    NEXT_JS(InterviewTopicKind.FRAMEWORK, "Next.js"),
    COMPOSE(InterviewTopicKind.FRAMEWORK, "Compose"),
    SWIFTUI(InterviewTopicKind.FRAMEWORK, "SwiftUI");

    private final InterviewTopicKind kind;
    private final String displayName;
}
