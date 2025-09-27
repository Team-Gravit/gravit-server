package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminNoticeCommandControllerDocs;
import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.request.NoticeUpdateRequest;
import gravit.code.admin.dto.response.AdminNoticeDetailResponse;
import gravit.code.admin.service.AdminNoticeCommandService;
import gravit.code.auth.domain.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/notice")
public class AdminNoticeCommandController implements AdminNoticeCommandControllerDocs {
    private final AdminNoticeCommandService adminNoticeCommandService;

    @PostMapping
    public ResponseEntity<AdminNoticeDetailResponse> createNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestBody NoticeCreateRequest noticeCreateResponse
    ) {
        Long authorId = loginUser.getId();
        AdminNoticeDetailResponse notice = adminNoticeCommandService.createNotice(authorId, noticeCreateResponse);
        HttpStatus status = HttpStatus.CREATED;
        return ResponseEntity.status(status).body(notice);
    }

    @PatchMapping
    public ResponseEntity<AdminNoticeDetailResponse> updateNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestBody NoticeUpdateRequest noticeUpdateRequest
    ) {
        Long authorId = loginUser.getId();
        AdminNoticeDetailResponse notice = adminNoticeCommandService.updateNotice(authorId, noticeUpdateRequest);
        HttpStatus status = HttpStatus.CREATED;
        return ResponseEntity.status(status).body(notice);
    }

    @DeleteMapping("/{noticeId}")
    public ResponseEntity<Void> deleteNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("noticeId") Long noticeId
    ) {
        Long authorId = loginUser.getId();
        adminNoticeCommandService.deleteNotice(authorId, noticeId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).build();
    }

}
