package gravit.code.global.event;

public record LevelUpFeedEvent(
        long userId,
        int newLevel
) {
}
