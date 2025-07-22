package gravit.code.lesson.dto.response;

import gravit.code.problem.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "문제 정보 Response")
public record LessonResponse(

        @Schema(description = "문제 아이디", example = "1")
        Long problemId,

        @Schema(description = "문제 타입", example = "FILL_BLANK")
        ProblemType problemType,

        @Schema(description = "문제지", example = "이진 탐색 트리에서 중위 순회(In-order traversal)를 수행하면 노드들이 ( )된 순서로 방문됩니다.")
        String question,

        @Schema(description = "선택지", example = "1. 삽입, 2. 오름차순 정렬, 3. 내림차순 정렬, 4. 무작위")
        String options,

        @Schema(description = "답안지", example = "1")
        String answer
) {
        public static LessonResponse create(Long problemId, ProblemType problemType, String question, String options, String answer) {
                return LessonResponse.builder()
                        .problemId(problemId)
                        .problemType(problemType)
                        .question(question)
                        .options(options)
                        .answer(answer)
                        .build();
        }
}