package gravit.code.interview.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum InterviewStackGroup {

    SERVER("Server", "Spring Boot / NestJS / Django", 1),
    WEB("Web", "React / Vue.js / Next.js", 2),
    AOS("AOS", "Jetpack Compose / Kotlin", 3),
    IOS("iOS", "SwiftUI / Swift", 4);

    private final String displayName;
    private final String description;
    private final int displayOrder;
}
