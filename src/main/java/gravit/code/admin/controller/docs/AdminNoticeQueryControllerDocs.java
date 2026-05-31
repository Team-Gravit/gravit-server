package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.response.AdminNoticeDetailResponse;
import gravit.code.admin.dto.response.AdminNoticeSummaryPageResponse;
import gravit.code.admin.dto.response.AdminNoticeSummaryResponse;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
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
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Tag(name = "Admin Notice Query API", description = "관리자 공지 조회  (DRAFT, ARCHIVED 포함)")
public interface AdminNoticeQueryControllerDocs {

    @Operation(
            summary = "어드민 공지 단건 조회",
            description = """
            공지 단건을 조회합니다. <strong>DRAFT</strong> 상태도 조회 가능하며, ADMIN 권한이 필요합니다.<br>
            🔐 <strong>Jwt 필요</strong>
            """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = AdminNoticeDetailResponse.class),
                            examples = @ExampleObject(name = "성공 예시", value = """
                    {
                      "id": 123,
                      "title": "8월 점검 안내(초안)",
                      "content": "내용 본문...",
                      "authorName": "kang",
                      "status": "DRAFT",
                      "pinned": false,
                      "publishedAt": null,
                      "createdAt": "2025-08-30T10:00:00",
                      "updatedAt": "2025-08-30T10:00:00"
                    "
                    """)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 공지 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(name = "NOTICE_NOT_FOUND", value = """
                    { "error": "NOTICE_4041", "message": "공지 정보를 찾을 수 없습니다." }
                    """)
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "🚨 권한 없음(ADMIN 아님)",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(name = "FORBIDDEN", value = """
                    { "error": "GLOBAL_4030", "message": "접근 권한이 없습니다." }
                    """)
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(name = "예상치 못한 오류", value = """
                    { "error": "GLOBAL_5001", "message": "예기치 못한 예외 발생" }
                    """)
                    )
            )
    })
    @GetMapping("/{noticeId}")
    ResponseEntity<AdminNoticeDetailResponse> getNoticeByAdmin(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "조회할 공지 ID", required = true)
            @PathVariable("noticeId") Long noticeId
    );

    @Operation(
            summary = "어드민 공지 목록(요약) 조회",
            description = """
            공지 요약 목록을 조회합니다. <strong>DRAFT, PUBLISHED</strong> 모두 포함되며, ADMIN 권한이 필요합니다.<br>
            🔐 <strong>Jwt 필요</strong><br>
            """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 목록 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = AdminNoticeSummaryPageResponse.class),
                            examples = @ExampleObject(name = "성공 예시", value = """
                    {
                      "page": 0,
                      "totalPages": 3,
                      "hasNextPage": true,
                      "content": [
                        {
                          "id": 201,
                          "title": "9월 점검 안내",
                          "preview": "9월 5일(목) 02:00~03:00...",
                          "pinned": true,
                          "publishedAt": "2025-09-01T09:00:00",
                          "status": "PUBLISHED"
                        },
                        {
                          "id": 198,
                          "title": "신규 기능 공개(초안)",
                          "preview": "다음 분기 공개 예정...",
                          "pinned": false,
                          "publishedAt": null,
                          "status": "DRAFT"
                        }
                      ]
                    }
                    """)
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "🚨 권한 없음(ADMIN 아님)",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            )
    })
    // ⚠️ 현재 컨트롤러가 @GetMapping("/{page}") 이므로 충돌 가능.
    //    경로를 "/page/{page}" 로 바꾸는 것을 권장합니다.
    @GetMapping("/{page}")
    ResponseEntity<PageResponse<AdminNoticeSummaryResponse>> getNoticeSummaryByAdmin(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "1부터 시작하는 페이지 번호", example = "1")
            @PathVariable("page") int page
    );

}
