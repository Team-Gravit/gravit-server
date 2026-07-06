package gravit.code.test.notification.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.facade.SocialFacade;
import gravit.code.test.notification.controller.docs.TestNotificationControllerDocs;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
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
public class TestNotificationController implements TestNotificationControllerDocs {

    private final NotificationFacade notificationFacade;
    private final SocialFacade socialFacade;

    @PostMapping("/consecutive-learning-warning")
    public ResponseEntity<Long> sendConsecutiveLearningWarning(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "3") int consecutiveDays
    ) {
        notificationFacade.sendConsecutiveLearningWarningToUser(loginUser.getId(), consecutiveDays);

        return ResponseEntity.status(HttpStatus.OK).body(loginUser.getId());
    }

    @PostMapping("/daily-incomplete")
    public ResponseEntity<Long> sendDailyIncomplete(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        notificationFacade.sendDailyIncompleteToUser(loginUser.getId());

        return ResponseEntity.status(HttpStatus.OK).body(loginUser.getId());
    }

    @PostMapping("/inactivity")
    public ResponseEntity<Long> sendInactivity(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "7") int inactiveDays
    ) {
        notificationFacade.sendInactivityToUser(loginUser.getId(), inactiveDays);

        return ResponseEntity.status(HttpStatus.OK).body(loginUser.getId());
    }

    @PostMapping("/new-content")
    public ResponseEntity<Long> sendNewContent(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam Long unitId
    ) {
        notificationFacade.sendNewContentToUser(loginUser.getId(), unitId);

        return ResponseEntity.status(HttpStatus.OK).body(loginUser.getId());
    }

    @PostMapping("/season-ending")
    public ResponseEntity<Long> sendSeasonEnding(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "7") int daysBefore
    ) {
        notificationFacade.sendSeasonEndingToUser(loginUser.getId(), daysBefore);

        return ResponseEntity.ok(loginUser.getId());
    }

    @PostMapping("/season-reset")
    public ResponseEntity<Long> sendSeasonReset(
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        notificationFacade.sendSeasonResetToUser(loginUser.getId());

        return ResponseEntity.ok(loginUser.getId());
    }

    @PostMapping("/follow")
    public ResponseEntity<Long> sendFollow(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(required = false) Long followerId
    ) {
        long actor = followerId != null ? followerId : loginUser.getId();
        notificationFacade.sendFollowToUser(loginUser.getId(), actor);

        return ResponseEntity.ok(loginUser.getId());
    }

    @PostMapping("/congratulation")
    public ResponseEntity<Long> sendCongratulation(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(required = false) Long congratulatorId
    ) {
        long actor = congratulatorId != null ? congratulatorId : loginUser.getId();
        notificationFacade.sendCongratulationToUser(loginUser.getId(), actor);

        return ResponseEntity.ok(loginUser.getId());
    }

    // 실제 발행 흐름(SocialFacade.publishFeed)을 그대로 재사용한다.
    // actor의 SocialFeed를 생성하고 팔로워에게 UserFeed 배포 + FRIEND_ACTIVITY 알림을 발송하므로,
    // actor를 팔로우한 유저의 알림함/피드에서 축하 동기화까지 실제로 검증할 수 있다.
    @PostMapping("/friend-activity")
    public ResponseEntity<Long> sendFriendActivity(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(required = false) Long actorId,
            @RequestParam(defaultValue = "STREAK_DAYS") FeedEventType eventType,
            @RequestParam(defaultValue = "7") String eventValue
    ) {
        long actor = actorId != null ? actorId : loginUser.getId();
        socialFacade.publishFeed(actor, eventType, eventValue);

        return ResponseEntity.ok(actor);
    }

    @PostMapping("/notice")
    public ResponseEntity<Long> sendNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "테스트 공지 제목") String title,
            @RequestParam(required = false) Long noticeId
    ) {
        notificationFacade.sendNoticeToUser(loginUser.getId(), title, noticeId);

        return ResponseEntity.ok(loginUser.getId());
    }

    @PostMapping("/inquiry-answered")
    public ResponseEntity<Long> sendInquiryAnswered(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "테스트 문의 제목") String title,
            @RequestParam(required = false) Long inquiryId
    ) {
        notificationFacade.sendInquiryAnsweredToUser(loginUser.getId(), title, inquiryId);

        return ResponseEntity.ok(loginUser.getId());
    }
}
