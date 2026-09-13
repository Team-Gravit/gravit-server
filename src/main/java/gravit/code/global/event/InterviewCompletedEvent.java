package gravit.code.global.event;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewCompletedEvent(
        long userId,
        long sessionId,
        int rewardPoints
) {

    public static InterviewCompletedEvent of(
            long userId,
            long sessionId,
            int rewardPoints
    ) {
        return InterviewCompletedEvent.builder()
                .userId(userId)
                .sessionId(sessionId)
                .rewardPoints(rewardPoints)
                .build();
    }
}
