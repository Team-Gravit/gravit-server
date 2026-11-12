package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.ChapterUpdateRequest;
import gravit.code.admin.dto.response.ChapterDetailResponse;
import gravit.code.admin.dto.response.ChapterListItemResponse;
import gravit.code.admin.dto.response.ChapterStatsResponse;
import gravit.code.admin.dto.response.UnitListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Chapter API", description = "백오피스 챕터 관리/통계")
public interface AdminChapterControllerDocs {

    @Operation(summary = "챕터 목록")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<ChapterListItemResponse>> getChapters(int page);

    @Operation(summary = "챕터 상세 (unitCount 포함)")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 챕터")
    })
    ResponseEntity<ChapterDetailResponse> getChapter(Long chapterId);

    @Operation(summary = "챕터 유닛별 통계", description = "참여율(참여자/전체 유저)·참여 인원. 비페이지네이션.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 챕터")
    })
    ResponseEntity<ChapterStatsResponse> getChapterStats(Long chapterId);

    @Operation(summary = "챕터 부분 수정")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 챕터")
    })
    ResponseEntity<Void> updateChapter(
            Long chapterId,
            ChapterUpdateRequest request
    );

    @Operation(summary = "챕터의 유닛 목록")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<UnitListItemResponse>> getUnits(
            Long chapterId,
            int page
    );
}
