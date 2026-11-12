package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.UnitUpdateRequest;
import gravit.code.admin.dto.response.LessonListItemResponse;
import gravit.code.admin.dto.response.UnitDetailResponse;
import gravit.code.global.dto.response.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Unit API", description = "백오피스 유닛 관리")
public interface AdminUnitControllerDocs {

    @Operation(summary = "유닛 상세 (lessonCount 포함)")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 유닛")
    })
    ResponseEntity<UnitDetailResponse> getUnit(Long unitId);

    @Operation(summary = "유닛 부분 수정")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 유닛")
    })
    ResponseEntity<Void> updateUnit(
            Long unitId,
            UnitUpdateRequest request
    );

    @Operation(summary = "유닛의 레슨 목록")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<LessonListItemResponse>> getLessons(
            Long unitId,
            int page
    );
}
