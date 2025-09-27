package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminNoticeQueryControllerDocs;
import gravit.code.admin.dto.response.AdminNoticeDetailResponse;
import gravit.code.admin.dto.response.AdminNoticeSummaryResponse;
import gravit.code.admin.service.AdminNoticeQueryService;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/notice")
public class AdminNoticeQueryController implements AdminNoticeQueryControllerDocs {
    private final AdminNoticeQueryService adminNoticeQueryService;

    @GetMapping("/{noticeId}")
    public ResponseEntity<AdminNoticeDetailResponse> getNoticeByAdmin(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("noticeId") Long noticeId
    ) {
        Long userId = loginUser.getId();
        AdminNoticeDetailResponse noticeByAdmin = adminNoticeQueryService.getNoticeByAdmin(userId, noticeId);
        HttpStatus httpStatus = HttpStatus.OK;
        return ResponseEntity.status(httpStatus).body(noticeByAdmin);
    }

    @GetMapping("/summaries/{page}")
    public ResponseEntity<PageResponse<AdminNoticeSummaryResponse>> getNoticeSummaryByAdmin(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("page") int page
    ){
        Long userId = loginUser.getId();
        PageResponse<AdminNoticeSummaryResponse> noticeSummaryByAdmin = adminNoticeQueryService.getNoticeSummaryByAdmin(userId, page);
        HttpStatus httpStatus = HttpStatus.OK;
        return ResponseEntity.status(httpStatus).body(noticeSummaryByAdmin);
    }
}
