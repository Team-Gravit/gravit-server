package gravit.code.notification.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.notification.controller.docs.NotificationDocs;
import gravit.code.notification.dto.response.NotificationResponse;
import gravit.code.notification.facade.NotificationFacade;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController implements NotificationDocs {

    private final NotificationFacade notificationFacade;

    @GetMapping
    public ResponseEntity<SliceResponse<NotificationResponse>> getInbox(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "0") @Min(0) int page
    ) {
        SliceResponse<NotificationResponse> inbox = notificationFacade.getInbox(loginUser.getId(), page);
        return ResponseEntity.ok(inbox);
    }
}
