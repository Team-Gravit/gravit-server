package gravit.code.learning.dto;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LearningIds(
        long chapterId,
        long unitId,
        long lessonId
) {
    public static LearningIds of(long chapterId, long unitId, long lessonId) {
        return LearningIds.builder()
                .chapterId(chapterId)
                .unitId(unitId)
                .lessonId(lessonId)
                .build();
    }
}
