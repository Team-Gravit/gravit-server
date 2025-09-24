package gravit.code.notice.controller.docs;


import gravit.code.global.dto.PageResponse;
import gravit.code.global.dto.SliceResponse;
import gravit.code.notice.dto.response.NoticeDetailResponse;
import gravit.code.notice.dto.response.NoticeSummaryResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.ErrorResponse;
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
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = SliceResponse.class),
                            examples = @ExampleObject(
                                    name = "notice-summaries",
                                    value = """
                                    {
                                      "hasNext": true,
                                      "content": [
                                        {
                                          "id": 123,
                                          "title": "9월 정기 점검 안내",
                                          "summary": "9/25(수) 02:00~05:00 점검으로 서비스 이용이 제한됩니다.",
                                          "pinned": true,
                                          "publishedAt": "2025-09-24T12:34:56"
                                        },
                                        {
                                          "id": 122,
                                          "title": "신규 기능 출시",
                                          "summary": "프로필 커버 이미지 기능이 추가되었습니다.",
                                          "pinned": false,
                                          "publishedAt": "2025-09-20T10:00:00"
                                        }
                                      ]
                                    }
                                    """
                            )
                    )
            )
    })
    @GetMapping("/summaries/{page}")
    ResponseEntity<PageResponse<NoticeSummaryResponse>> getNoticeSummaries(
            @Parameter(description = "1부터 시작하는 페이지 번호", example = "1")
            @PathVariable("page") int page);

    @Operation(
            summary = "공지 상세 조회",
            description = "공지의 상세 내용을 조회합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 조회 성공",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = NoticeDetailResponse.class)))
    ,
            @ApiResponse(
                    responseCode = "NOTICE_4041",
                    description = "🚨 공지 조회 실패(미존재)",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "공지 없음",
                                    value = "{\"error\":\"NOTICE_4041\",\"message\":\"존재하지 않는 공지사항입니다.\"}"
                            )
                    )
            ),
    })
    @GetMapping("/{noticeId}")
    ResponseEntity<NoticeDetailResponse> getNoticeSummary(@PathVariable("noticeId") Long noticeId
    );
}
