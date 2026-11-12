package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.request.NoticeUpdateRequest;
import gravit.code.admin.dto.response.NoticeDetailResponse;
import gravit.code.admin.dto.response.NoticeListItemResponse;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Notice API", description = "백오피스 공지 관리")
public interface AdminNoticeControllerDocs {

    @Operation(summary = "공지 목록", description = "soft delete 자동 제외.")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<NoticeListItemResponse>> getNotices(int page);

    @Operation(summary = "공지 상세")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 공지")
    })
    ResponseEntity<NoticeDetailResponse> getNotice(Long noticeId);

    @Operation(summary = "공지 생성", description = "status=PUBLISHED 면 publishedAt 세팅. ARCHIVED 작성 불가.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "생성 성공"),
            @ApiResponse(responseCode = "400", description = "검증 실패 / pinned+DRAFT")
    })
    ResponseEntity<NoticeDetailResponse> createNotice(
            LoginUser loginUser,
            NoticeCreateRequest request
    );

    @Operation(summary = "공지 부분 수정", description = "상태 전이 가드(위반 시 409). 감사 로그 기록(상태 전이).")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 공지"),
            @ApiResponse(responseCode = "409", description = "허용되지 않는 상태 전이")
    })
    ResponseEntity<NoticeDetailResponse> updateNotice(
            LoginUser loginUser,
            Long noticeId,
            NoticeUpdateRequest request
    );

    @Operation(summary = "공지 삭제(soft delete)", description = "감사 로그 기록.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "삭제 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 공지")
    })
    ResponseEntity<Void> deleteNotice(
            LoginUser loginUser,
            Long noticeId
    );
}
