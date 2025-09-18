package gravit.code.learning.dto.event;

public record UpdateLearningEvent(
        long userId,
        long chapterId
) {
}
