package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.LessonUpdateRequest;
import gravit.code.admin.dto.response.LessonDetailResponse;
import gravit.code.admin.dto.response.ProblemListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Lesson API", description = "백오피스 레슨 관리")
public interface AdminLessonControllerDocs {

    @Operation(summary = "레슨 상세 (problemCount 포함)")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 레슨")
    })
    ResponseEntity<LessonDetailResponse> getLesson(Long lessonId);

    @Operation(summary = "레슨 부분 수정 (title 만)")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 레슨")
    })
    ResponseEntity<Void> updateLesson(
            Long lessonId,
            LessonUpdateRequest request
    );

    @Operation(summary = "레슨의 문제 목록")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<ProblemListItemResponse>> getProblems(
            Long lessonId,
            int page
    );
}
