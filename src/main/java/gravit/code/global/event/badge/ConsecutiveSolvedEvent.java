package gravit.code.global.event.badge;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ConsecutiveSolvedEvent(
        long userId,
        int streakCount
) {
    public static ConsecutiveSolvedEvent of(long userId, int streakCount) {
        return ConsecutiveSolvedEvent.builder()
                .userId(userId)
                .streakCount(streakCount)
                .build();
    }
}
