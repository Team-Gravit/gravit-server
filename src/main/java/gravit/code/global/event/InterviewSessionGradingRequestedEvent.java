package gravit.code.global.event;

public record InterviewSessionGradingRequestedEvent(
        long sessionId,
        long userId
) {
}
