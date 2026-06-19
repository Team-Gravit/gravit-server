package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.InquiryAnswerCreateRequest;
import gravit.code.admin.dto.request.InquiryAnswerUpdateRequest;
import gravit.code.admin.dto.response.InquiryDetailResponse;
import gravit.code.admin.dto.response.InquiryListItemResponse;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.inquiry.domain.InquiryStatus;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Inquiry API", description = "백오피스 문의 관리 (상태별 조회 / 답변 등록·수정·삭제)")
public interface AdminInquiryControllerDocs {

    @Operation(summary = "문의 목록(상태별)", description = "status 미지정 시 전체 조회. 1-based 페이지, id 내림차순.")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<InquiryListItemResponse>> getInquiries(
            InquiryStatus status,
            int page
    );

    @Operation(summary = "문의 상세", description = "작성자 정보와 답변(있으면)을 포함한다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 문의")
    })
    ResponseEntity<InquiryDetailResponse> getInquiry(long inquiryId);

    @Operation(summary = "문의 답변 등록", description = "답변 등록 시 문의 상태가 RESOLVED 로 자동 전환되고 작성자에게 알림이 발송된다.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "답변 등록 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 문의"),
            @ApiResponse(responseCode = "409", description = "이미 답변이 등록된 문의")
    })
    ResponseEntity<InquiryDetailResponse> answerInquiry(
            LoginUser loginUser,
            long inquiryId,
            InquiryAnswerCreateRequest request
    );

    @Operation(summary = "문의 답변 수정", description = "등록된 답변 내용을 수정한다. 상태는 RESOLVED 로 유지된다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "답변 수정 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 문의 / 등록된 답변 없음")
    })
    ResponseEntity<InquiryDetailResponse> updateAnswer(
            long inquiryId,
            InquiryAnswerUpdateRequest request
    );

    @Operation(summary = "문의 답변 삭제", description = "답변 삭제 시 문의 상태가 PENDING 으로 되돌아간다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "답변 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 문의 / 등록된 답변 없음")
    })
    ResponseEntity<Void> deleteAnswer(long inquiryId);
}
