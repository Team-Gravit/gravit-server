package gravit.code.interview.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum InterviewStackGroup {

    SERVER("Server", 1),
    WEB("Web", 2),
    AOS("AOS", 3),
    IOS("iOS", 4);

    private final String displayName;
    private final int displayOrder;
}
