package gravit.code.learning.dto.event;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record CreateLearningEvent(
        long userId
) {
    public static CreateLearningEvent of(long userId){
        return CreateLearningEvent.builder()
                .userId(userId)
                .build();
    }
}
