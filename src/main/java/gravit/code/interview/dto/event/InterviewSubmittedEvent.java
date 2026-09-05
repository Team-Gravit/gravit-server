package gravit.code.interview.dto.event;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSubmittedEvent(
        long sessionId
) {

    public static InterviewSubmittedEvent of(long sessionId) {
        return InterviewSubmittedEvent.builder()
                .sessionId(sessionId)
                .build();
    }
}
