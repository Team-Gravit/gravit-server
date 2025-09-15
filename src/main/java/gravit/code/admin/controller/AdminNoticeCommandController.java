package gravit.code.admin.controller;

import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.response.NoticeResponse;
import gravit.code.admin.service.AdminNoticeCommandService;
import gravit.code.auth.oauth.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/notice")
public class AdminNoticeCommandController {
    private final AdminNoticeCommandService adminNoticeCommandService;

    @PostMapping("/create")
    public ResponseEntity<NoticeResponse> createNotice(@AuthenticationPrincipal LoginUser loginUser,
                                                       @RequestBody NoticeCreateRequest noticeCreateResponse) {
        Long authorId = loginUser.getId();
        NoticeResponse notice = adminNoticeCommandService.createNotice(authorId, noticeCreateResponse);
        HttpStatus status = HttpStatus.CREATED;
        return ResponseEntity.status(status).body(notice);
    }

}
