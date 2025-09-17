package gravit.code.notice.controller.docs;


import gravit.code.global.dto.SliceResponse;
import gravit.code.notice.dto.response.NoticeDetailResponse;
import gravit.code.notice.dto.response.NoticeSummaryResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Tag(name = "Notice Query API", description = "공지 조회(요약/상세)")
public interface NoticeQueryControllerDocs {

    @Operation(
            summary = "공지 요약 목록 조회",
            description = "최신 공지의 요약 리스트를 페이지 단위(0-based)로 조회합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 조회 성공",
                    content = @Content(mediaType = "application/json"))
    })
    @GetMapping("/summaries/{page}")
    ResponseEntity<SliceResponse<NoticeSummaryResponse>> getNoticeSummaries(@PathVariable("page") int page);

    @Operation(
            summary = "공지 상세 조회",
            description = "공지의 상세 내용을 조회합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 조회 성공",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = NoticeDetailResponse.class)))
    })
    @GetMapping("/{noticeId}")
    ResponseEntity<NoticeDetailResponse> getNoticeSummary(@PathVariable("noticeId") Long noticeId
    );
}
