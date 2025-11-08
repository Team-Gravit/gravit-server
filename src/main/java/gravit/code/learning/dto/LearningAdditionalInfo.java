package gravit.code.learning.dto;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LearningAdditionalInfo(
        long chapterId,
        String lessonName
) {
    public static LearningAdditionalInfo of(long chapterId, String lessonName){
        return LearningAdditionalInfo.builder()
                .chapterId(chapterId)
                .lessonName(lessonName)
                .build();
    }
}
