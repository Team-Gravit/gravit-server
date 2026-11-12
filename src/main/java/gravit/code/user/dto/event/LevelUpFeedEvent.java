package gravit.code.user.dto.event;

public record LevelUpFeedEvent(
        long userId,

        int newLevel
) {
}
