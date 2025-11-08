package gravit.code.learning.dto.event;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UpdateLearningEvent(
        long userId,
        long chapterId
) {

    public static UpdateLearningEvent of(long userId, long chapterId){
        return UpdateLearningEvent.builder()
                .userId(userId)
                .chapterId(chapterId)
                .build();
    }
}
