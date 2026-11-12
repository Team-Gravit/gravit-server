package gravit.code.learning.dto.internal;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LearningIdsDto(
        long chapterId,

        long unitId,

        long lessonId
) {
    public static LearningIdsDto of(
            long chapterId,
            long unitId,
            long lessonId
    ) {
        return LearningIdsDto.builder()
                .chapterId(chapterId)
                .unitId(unitId)
                .lessonId(lessonId)
                .build();
    }
}
