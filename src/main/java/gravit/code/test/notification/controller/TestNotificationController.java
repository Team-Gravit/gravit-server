package gravit.code.test.notification.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.test.notification.controller.docs.TestNotificationDocs;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Profile("!prod")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test/notifications")
public class TestNotificationController implements TestNotificationDocs {

    private final NotificationFacade notificationFacade;

    @PostMapping("/consecutive-learning-warning")
    public ResponseEntity<Long> sendConsecutiveLearningWarning(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "3") int consecutiveDays
    ) {
        notificationFacade.sendConsecutiveLearningWarningToUser(loginUser.getId(), consecutiveDays);

        return ResponseEntity.ok(loginUser.getId());
    }

    @PostMapping("/daily-incomplete")
    public ResponseEntity<Long> sendDailyIncomplete(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        notificationFacade.sendDailyIncompleteToUser(loginUser.getId());

        return ResponseEntity.ok(loginUser.getId());
    }

    @PostMapping("/inactivity")
    public ResponseEntity<Long> sendInactivity(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "7") int inactiveDays
    ) {
        notificationFacade.sendInactivityToUser(loginUser.getId(), inactiveDays);

        return ResponseEntity.ok(loginUser.getId());
    }

    @PostMapping("/new-content")
    public ResponseEntity<Long> sendNewContent(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam Long unitId
    ) {
        notificationFacade.sendNewContentToUser(loginUser.getId(), unitId);

        return ResponseEntity.ok(loginUser.getId());
    }
}
