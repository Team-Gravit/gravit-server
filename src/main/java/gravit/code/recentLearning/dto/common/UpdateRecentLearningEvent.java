package gravit.code.recentLearning.dto.common;

public record UpdateRecentLearningEvent(
        Long userId,
        Long chapterId
) {
}
