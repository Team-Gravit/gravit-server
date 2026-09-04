package gravit.code.interview.domain;

import gravit.code.interviewQuestion.domain.InterviewTopic;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum InterviewStack {

    JAVA_SPRING_BOOT(
            InterviewStackGroup.SERVER, "Java + Spring Boot",
            InterviewTopic.SERVER_COMMON, InterviewTopic.JAVA, InterviewTopic.SPRING_BOOT, 1
    ),
    KOTLIN_SPRING_BOOT(
            InterviewStackGroup.SERVER, "Kotlin + Spring Boot",
            InterviewTopic.SERVER_COMMON, InterviewTopic.KOTLIN, InterviewTopic.SPRING_BOOT, 2
    ),
    NODE_NEST(
            InterviewStackGroup.SERVER, "Node.js + NestJS",
            InterviewTopic.SERVER_COMMON, InterviewTopic.NODE_JS, InterviewTopic.NEST_JS, 3
    ),
    PYTHON_DJANGO(
            InterviewStackGroup.SERVER, "Python + Django",
            InterviewTopic.SERVER_COMMON, InterviewTopic.PYTHON, InterviewTopic.DJANGO, 4
    ),
    TS_REACT(
            InterviewStackGroup.WEB, "TypeScript + React",
            InterviewTopic.WEB_COMMON, InterviewTopic.TYPESCRIPT, InterviewTopic.REACT, 1
    ),
    TS_VUE(
            InterviewStackGroup.WEB, "TypeScript + Vue.js",
            InterviewTopic.WEB_COMMON, InterviewTopic.TYPESCRIPT, InterviewTopic.VUE, 2
    ),
    TS_NEXT(
            InterviewStackGroup.WEB, "TypeScript + Next.js",
            InterviewTopic.WEB_COMMON, InterviewTopic.TYPESCRIPT, InterviewTopic.NEXT_JS, 3
    ),
    KOTLIN_COMPOSE(
            InterviewStackGroup.AOS, "Kotlin + Compose",
            InterviewTopic.AOS_COMMON, InterviewTopic.KOTLIN, InterviewTopic.COMPOSE, 1
    ),
    SWIFT_SWIFTUI(
            InterviewStackGroup.IOS, "Swift + SwiftUI",
            InterviewTopic.IOS_COMMON, InterviewTopic.SWIFT, InterviewTopic.SWIFTUI, 1
    );

    private final InterviewStackGroup group;
    private final String displayName;
    private final InterviewTopic commonTopic;
    private final InterviewTopic languageTopic;
    private final InterviewTopic frameworkTopic;
    private final int displayOrder;
}
