package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminNoticeControllerDocs;
import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.request.NoticeUpdateRequest;
import gravit.code.admin.dto.response.NoticeDetailResponse;
import gravit.code.admin.dto.response.NoticeListItemResponse;
import gravit.code.admin.service.AdminNoticeService;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/notices")
public class AdminNoticeController implements AdminNoticeControllerDocs {

    private final AdminNoticeService adminNoticeService;

    @GetMapping
    public ResponseEntity<PageResponse<NoticeListItemResponse>> getNotices(@RequestParam(value = "page", defaultValue = "1") int page) {
        return ResponseEntity.status(HttpStatus.OK).body(adminNoticeService.getNotices(page));
    }

    @GetMapping("/{noticeId}")
    public ResponseEntity<NoticeDetailResponse> getNotice(@PathVariable("noticeId") Long noticeId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminNoticeService.getNotice(noticeId));
    }

    @PostMapping
    public ResponseEntity<NoticeDetailResponse> createNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody NoticeCreateRequest request
    ) {
        NoticeDetailResponse notice = adminNoticeService.createNotice(loginUser.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(notice);
    }

    @PatchMapping("/{noticeId}")
    public ResponseEntity<NoticeDetailResponse> updateNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("noticeId") Long noticeId,
            @Valid @RequestBody NoticeUpdateRequest request
    ) {
        NoticeDetailResponse notice = adminNoticeService.updateNotice(loginUser.getId(), noticeId, request);
        return ResponseEntity.status(HttpStatus.OK).body(notice);
    }

    @DeleteMapping("/{noticeId}")
    public ResponseEntity<Void> deleteNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("noticeId") Long noticeId
    ) {
        adminNoticeService.deleteNotice(loginUser.getId(), noticeId);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
