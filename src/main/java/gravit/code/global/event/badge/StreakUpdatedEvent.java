package gravit.code.global.event.badge;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record StreakUpdatedEvent(
        long userId,
        int streakCount
) {
    public static StreakUpdatedEvent of(long userId, int streakCount) {
        return StreakUpdatedEvent.builder()
                .userId(userId)
                .streakCount(streakCount)
                .build();
    }
}