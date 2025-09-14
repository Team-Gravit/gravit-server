package gravit.code.learning.dto.event;

public record UpdateLearningEvent(
        Long userId,
        Long chapterId
) {
}
