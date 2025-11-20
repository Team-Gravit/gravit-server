package gravit.code.learning.dto.common;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "학습 추가 정보")
public record LearningAdditionalInfo(
        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        long chapterId,

        @Schema(
                description = "레슨 이름",
                example = "스택 1/3"
        )
        String lessonName
) {
    public static LearningAdditionalInfo of(long chapterId, String lessonName){
        return LearningAdditionalInfo.builder()
                .chapterId(chapterId)
                .lessonName(lessonName)
                .build();
    }
}
