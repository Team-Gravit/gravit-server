package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ChapterSummary(
        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        long chapterId,

        @Schema(
                description = "챕터명",
                example = "자료구조"
        )
        String title,

        @Schema(
                description = "챕터 설명",
                example = "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다."
        )
        String description
) { }
