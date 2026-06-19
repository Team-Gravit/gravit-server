package gravit.code.inquiry.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
import gravit.code.inquiry.dto.request.InquiryUpdateRequest;
import gravit.code.inquiry.dto.response.InquiryDetailResponse;
import gravit.code.inquiry.dto.response.InquirySummaryPageResponse;
import gravit.code.inquiry.dto.response.InquirySummaryResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Inquiry API", description = "문의 관련 API (유저 본인 문의 제출/조회/수정/삭제)")
public interface InquiryControllerDocs {

    @Operation(summary = "문의 제출", description = "새로운 문의를 제출합니다. 응답 body 로 생성된 문의 ID 를 반환합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "✅ 문의 제출 성공 (생성된 문의 ID 반환)"),
            @ApiResponse(responseCode = "400", description = "🚨 유효성 검사 실패 (제목/유형/내용)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "문의 유형 오류",
                                    value = "{\"error\":\"INQUIRY_4001\",\"message\":\"문의 제목이 유효하지 않습니다.\"}"
                            )))
    })
    @PostMapping
    ResponseEntity<Long> submitInquiry(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody InquirySubmitRequest request
    );

    @Operation(summary = "본인 문의 목록 조회", description = "로그인 유저 본인이 작성한 문의 목록을 페이지 단위(1-based)로 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InquirySummaryPageResponse.class),
                            examples = @ExampleObject(
                                    name = "inquiry-summaries",
                                    value = """
                                    {
                                      "page": 1,
                                      "totalPages": 3,
                                      "hasNext": true,
                                      "contents": [
                                        {
                                          "id": 12,
                                          "title": "특정 화면에서 앱이 종료돼요",
                                          "type": "BUG_REPORT",
                                          "status": "PENDING",
                                          "createdAt": "2026-06-18T12:34:56"
                                        }
                                      ]
                                    }
                                    """
                            )))
    })
    @GetMapping
    ResponseEntity<PageResponse<InquirySummaryResponse>> getMyInquiries(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "1부터 시작하는 페이지 번호", example = "1")
            @RequestParam(value = "page", defaultValue = "1") int page
    );

    @Operation(summary = "본인 문의 상세 조회", description = "본인이 작성한 문의의 상세 내용과 답변(있으면)을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 조회 성공",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InquiryDetailResponse.class))),
            @ApiResponse(responseCode = "403", description = "🚨 본인 문의가 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "접근 불가",
                                    value = "{\"error\":\"INQUIRY_4031\",\"message\":\"본인의 문의만 접근할 수 있습니다.\"}"
                            ))),
            @ApiResponse(responseCode = "404", description = "🚨 문의 조회 실패(미존재)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "문의 없음",
                                    value = "{\"error\":\"INQUIRY_4041\",\"message\":\"존재하지 않는 문의입니다.\"}"
                            )))
    })
    @GetMapping("/{inquiryId}")
    ResponseEntity<InquiryDetailResponse> getMyInquiryDetail(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("inquiryId") long inquiryId
    );

    @Operation(summary = "문의 수정", description = "본인이 작성한 문의를 수정합니다. 답변이 완료된(RESOLVED) 문의는 수정할 수 없습니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 문의 수정 성공"),
            @ApiResponse(responseCode = "403", description = "🚨 본인 문의가 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "접근 불가",
                                    value = "{\"error\":\"INQUIRY_4031\",\"message\":\"본인의 문의만 접근할 수 있습니다.\"}"
                            ))),
            @ApiResponse(responseCode = "404", description = "🚨 문의 조회 실패(미존재)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "문의 없음",
                                    value = "{\"error\":\"INQUIRY_4041\",\"message\":\"존재하지 않는 문의입니다.\"}"
                            ))),
            @ApiResponse(responseCode = "409", description = "🚨 이미 답변 완료된 문의",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "수정 불가",
                                    value = "{\"error\":\"INQUIRY_4091\",\"message\":\"이미 답변이 완료된 문의는 수정/삭제할 수 없습니다.\"}"
                            )))
    })
    @PutMapping("/{inquiryId}")
    ResponseEntity<Void> updateInquiry(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("inquiryId") long inquiryId,
            @Valid @RequestBody InquiryUpdateRequest request
    );

    @Operation(summary = "문의 삭제", description = "본인이 작성한 문의를 삭제(soft delete)합니다. 답변이 완료된(RESOLVED) 문의는 삭제할 수 없습니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 문의 삭제 성공"),
            @ApiResponse(responseCode = "403", description = "🚨 본인 문의가 아님",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "접근 불가",
                                    value = "{\"error\":\"INQUIRY_4031\",\"message\":\"본인의 문의만 접근할 수 있습니다.\"}"
                            ))),
            @ApiResponse(responseCode = "404", description = "🚨 문의 조회 실패(미존재)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "문의 없음",
                                    value = "{\"error\":\"INQUIRY_4041\",\"message\":\"존재하지 않는 문의입니다.\"}"
                            ))),
            @ApiResponse(responseCode = "409", description = "🚨 이미 답변 완료된 문의",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "삭제 불가",
                                    value = "{\"error\":\"INQUIRY_4091\",\"message\":\"이미 답변이 완료된 문의는 수정/삭제할 수 없습니다.\"}"
                            )))
    })
    @DeleteMapping("/{inquiryId}")
    ResponseEntity<Void> deleteInquiry(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("inquiryId") long inquiryId
    );
}
