package gravit.code.notification.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.notification.controller.docs.NotificationControllerDocs;
import gravit.code.notification.dto.response.NotificationResponse;
import gravit.code.notification.facade.NotificationInboxFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController implements NotificationControllerDocs {

    private final NotificationInboxFacade notificationInboxFacade;

    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getInbox(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        List<NotificationResponse> inbox = notificationInboxFacade.getInbox(loginUser.getId());
        return ResponseEntity.status(OK).body(inbox);
    }
}
