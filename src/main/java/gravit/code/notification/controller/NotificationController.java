package gravit.code.notification.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.notification.controller.docs.NotificationDocs;
import gravit.code.notification.dto.response.NotificationResponse;
import gravit.code.notification.facade.NotificationInboxFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController implements NotificationDocs {

    private final NotificationInboxFacade notificationInboxFacade;

    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getInbox(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        List<NotificationResponse> inbox = notificationInboxFacade.getInbox(loginUser.getId());
        return ResponseEntity.status(HttpStatus.OK).body(inbox);
    }
}
