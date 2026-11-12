package gravit.code.test.notification.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.facade.SocialFacade;
import gravit.code.test.notification.controller.docs.TestNotificationControllerDocs;
import gravit.code.test.notification.facade.TestNotificationQaFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@Profile("!prod")
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/test/notifications")
public class TestNotificationController implements TestNotificationControllerDocs {

    private final TestNotificationQaFacade notificationQaFacade;
    private final SocialFacade socialFacade;

    @PostMapping("/consecutive-learning-warning")
    public ResponseEntity<Long> sendConsecutiveLearningWarning(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "3") int consecutiveDays
    ) {
        notificationQaFacade.sendConsecutiveLearningWarningToUser(loginUser.getId(), consecutiveDays);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/daily-incomplete")
    public ResponseEntity<Long> sendDailyIncomplete(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        notificationQaFacade.sendDailyIncompleteToUser(loginUser.getId());

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/inactivity")
    public ResponseEntity<Long> sendInactivity(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "7") int inactiveDays
    ) {
        notificationQaFacade.sendInactivityToUser(loginUser.getId(), inactiveDays);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/new-content")
    public ResponseEntity<Long> sendNewContent(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam Long unitId
    ) {
        notificationQaFacade.sendNewContentToUser(loginUser.getId(), unitId);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/season-ending")
    public ResponseEntity<Long> sendSeasonEnding(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "7") int daysBefore
    ) {
        notificationQaFacade.sendSeasonEndingToUser(loginUser.getId(), daysBefore);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/season-reset")
    public ResponseEntity<Long> sendSeasonReset(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        notificationQaFacade.sendSeasonResetToUser(loginUser.getId());

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/follow")
    public ResponseEntity<Long> sendFollow(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(required = false) Long followerId
    ) {
        long actor = followerId != null ? followerId : loginUser.getId();
        notificationQaFacade.sendFollowToUser(loginUser.getId(), actor);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/congratulation")
    public ResponseEntity<Long> sendCongratulation(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(required = false) Long congratulatorId
    ) {
        long actor = congratulatorId != null ? congratulatorId : loginUser.getId();
        notificationQaFacade.sendCongratulationToUser(loginUser.getId(), actor);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/friend-activity")
    public ResponseEntity<Long> sendFriendActivity(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(required = false) Long actorId,
            @RequestParam(defaultValue = "STREAK_DAYS") FeedEventType eventType,
            @RequestParam(defaultValue = "7") String eventValue
    ) {
        long actor = actorId != null ? actorId : loginUser.getId();
        socialFacade.publishFeed(actor, eventType, eventValue);

        return ResponseEntity.status(OK).body(actor);
    }

    @PostMapping("/notice")
    public ResponseEntity<Long> sendNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "테스트 공지 제목") String title,
            @RequestParam(required = false) Long noticeId
    ) {
        notificationQaFacade.sendNoticeToUser(loginUser.getId(), title, noticeId);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }

    @PostMapping("/inquiry-answered")
    public ResponseEntity<Long> sendInquiryAnswered(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "테스트 문의 제목") String title,
            @RequestParam(required = false) Long inquiryId
    ) {
        notificationQaFacade.sendInquiryAnsweredToUser(loginUser.getId(), title, inquiryId);

        return ResponseEntity.status(OK).body(loginUser.getId());
    }
}
