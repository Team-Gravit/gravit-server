package gravit.code.notification.facade;

import gravit.code.friend.fixture.FriendFixture;
import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationActionType;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.response.NotificationActor;
import gravit.code.notification.dto.response.NotificationResponse;
import gravit.code.notification.repository.NotificationRepository;
import gravit.code.social.domain.Congratulation;
import gravit.code.social.repository.CongratulationRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@DisplayName("알림 인박스를 조회할 때")
class NotificationInboxFacadeIntegrationTest {

    @Autowired
    private NotificationInboxFacade notificationInboxFacade;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private FriendFixture friendFixture;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CongratulationRepository congratulationRepository;

    @Test
    void 알림이_없으면_빈_결과를_반환한다() {
        // given
        User user = userFixture.일반_유저(1);

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(user.getId());

        // then
        assertThat(result).isEmpty();
    }

    @Test
    void FOLLOW_알림에서_상대를_아직_팔로우하지_않았으면_FOLLOW_BACK을_반환한다() {
        // given
        User me = userFixture.일반_유저(1);
        User follower = userFixture.일반_유저(2);
        // follower가 me를 팔로우했고, me는 아직 맞팔로우 안 함
        notificationRepository.save(Notification.create(me.getId(), NotificationType.FOLLOW,
                "유저2님이 나를 팔로우했어요! 👀", follower.getId()));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertThat(result).hasSize(1);
        assertSoftly(softly -> {
            softly.assertThat(result.get(0).actionType()).isEqualTo(NotificationActionType.FOLLOW_BACK.name());
            softly.assertThat(result.get(0).targetId()).isEqualTo(follower.getId());
        });
    }

    @Test
    void FOLLOW_알림에서_상대를_이미_팔로우했으면_NONE을_반환한다() {
        // given
        User me = userFixture.일반_유저(1);
        User follower = userFixture.일반_유저(2);
        // follower가 me를 팔로우했고, me도 follower를 맞팔로우한 상태 → 버튼 없음(NONE)
        friendFixture.팔로우(me, follower);
        notificationRepository.save(Notification.create(me.getId(), NotificationType.FOLLOW,
                "유저2님이 나를 팔로우했어요! 👀", follower.getId()));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertThat(result).hasSize(1);
        assertSoftly(softly -> {
            softly.assertThat(result.get(0).actionType()).isEqualTo(NotificationActionType.NONE.name());
            softly.assertThat(result.get(0).targetId()).isEqualTo(follower.getId());
        });
    }

    @Test
    void FOLLOW_알림은_상대_유저의_actor_정보를_포함한다() {
        // given
        User me = userFixture.일반_유저(1);
        User follower = userFixture.일반_유저(2);
        notificationRepository.save(Notification.create(me.getId(), NotificationType.FOLLOW,
                "유저2님이 나를 팔로우했어요! 👀", follower.getId()));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        NotificationActor actor = result.get(0).actor();
        assertThat(actor).isNotNull();
        assertSoftly(softly -> {
            softly.assertThat(actor.profileId()).isEqualTo(follower.getId());
            softly.assertThat(actor.nickname()).isEqualTo("유저2");
            softly.assertThat(actor.profileImgNumber()).isEqualTo(follower.getProfileImgNumber());
        });
    }

    @Test
    void 탈퇴한_유저의_FOLLOW_알림은_actor가_null이다() {
        // given
        User me = userFixture.일반_유저(1);
        User follower = userFixture.일반_유저(2);
        notificationRepository.save(Notification.create(me.getId(), NotificationType.FOLLOW,
                "유저2님이 나를 팔로우했어요! 👀", follower.getId()));
        // 상대 유저 탈퇴 (soft delete)
        userRepository.delete(follower);

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.get(0).actor()).isNull();
            // 알림 자체와 액션 정보는 그대로 유지된다
            softly.assertThat(result.get(0).targetId()).isEqualTo(follower.getId());
            softly.assertThat(result.get(0).actionType()).isEqualTo(NotificationActionType.FOLLOW_BACK.name());
        });
    }

    @Test
    void FOLLOW가_아닌_알림은_actor가_null이다() {
        // given
        User me = userFixture.일반_유저(1);
        notificationRepository.save(Notification.create(me.getId(), NotificationType.CONGRATULATION,
                "유저2님이 축하해줬어요! 🎉"));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertThat(result.get(0).actor()).isNull();
    }

    @Test
    void CONGRATULATION_알림은_NONE_액션을_반환한다() {
        // given
        User me = userFixture.일반_유저(1);
        notificationRepository.save(Notification.create(me.getId(), NotificationType.CONGRATULATION,
                "유저2님이 축하해줬어요! 🎉"));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.get(0).actionType()).isEqualTo(NotificationActionType.NONE.name());
            softly.assertThat(result.get(0).targetId()).isNull();
        });
    }

    @Test
    void FRIEND_ACTIVITY_알림은_CONGRATULATE_액션과_feedId를_반환하고_미축하시_congratulated는_false다() {
        // given
        User me = userFixture.일반_유저(1);
        long feedId = 77L;
        notificationRepository.save(Notification.create(me.getId(), NotificationType.FRIEND_ACTIVITY,
                "유저2님이 OS행성을 정복했어요! 🌍", feedId));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.get(0).actionType()).isEqualTo(NotificationActionType.CONGRATULATE.name());
            softly.assertThat(result.get(0).targetId()).isEqualTo(feedId);
            softly.assertThat(result.get(0).congratulated()).isFalse();
        });
    }

    @Test
    void 해당_피드를_이미_축하했으면_FRIEND_ACTIVITY_알림의_congratulated가_true다() {
        // given — 같은 feedId에 대한 축하 기록(소셜 피드/알림함 공통 원천)이 있으면 알림함도 완료로 노출
        User me = userFixture.일반_유저(1);
        long actorId = 2L;
        long feedId = 77L;
        notificationRepository.save(Notification.create(me.getId(), NotificationType.FRIEND_ACTIVITY,
                "유저2님이 OS행성을 정복했어요! 🌍", feedId));
        congratulationRepository.save(Congratulation.create(me.getId(), actorId, feedId));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.get(0).actionType()).isEqualTo(NotificationActionType.CONGRATULATE.name());
            softly.assertThat(result.get(0).congratulated()).isTrue();
        });
    }

    @Test
    void FRIEND_ACTIVITY가_아닌_알림의_congratulated는_null이다() {
        // given
        User me = userFixture.일반_유저(1);
        notificationRepository.save(Notification.create(me.getId(), NotificationType.CONGRATULATION,
                "유저2님이 축하해줬어요! 🎉"));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertThat(result.get(0).congratulated()).isNull();
    }

    @Test
    void 여러_타입의_알림이_혼재할_때_각_타입에_맞는_액션을_반환한다() {
        // given
        User me = userFixture.일반_유저(1);
        User followerA = userFixture.일반_유저(2); // 아직 맞팔로우 안 함
        User followerB = userFixture.일반_유저(3); // 이미 맞팔로우 함
        friendFixture.팔로우(me, followerB);

        notificationRepository.save(Notification.create(me.getId(), NotificationType.FOLLOW,
                "유저2님이 나를 팔로우했어요! 👀", followerA.getId()));
        notificationRepository.save(Notification.create(me.getId(), NotificationType.FOLLOW,
                "유저3님이 나를 팔로우했어요! 👀", followerB.getId()));
        notificationRepository.save(Notification.create(me.getId(), NotificationType.CONGRATULATION,
                "유저2님이 축하해줬어요! 🎉"));

        // when
        List<NotificationResponse> result = notificationInboxFacade.getInbox(me.getId());

        // then
        assertThat(result).hasSize(3);
        assertThat(result)
                .filteredOn(n -> n.type().equals(NotificationType.FOLLOW.name())
                        && n.targetId().equals(followerA.getId()))
                .singleElement()
                .extracting(NotificationResponse::actionType)
                .isEqualTo(NotificationActionType.FOLLOW_BACK.name());

        assertThat(result)
                .filteredOn(n -> n.type().equals(NotificationType.FOLLOW.name())
                        && n.targetId().equals(followerB.getId()))
                .singleElement()
                .extracting(NotificationResponse::actionType)
                .isEqualTo(NotificationActionType.NONE.name());

        assertThat(result)
                .filteredOn(n -> n.type().equals(NotificationType.CONGRATULATION.name()))
                .singleElement()
                .extracting(NotificationResponse::actionType)
                .isEqualTo(NotificationActionType.NONE.name());
    }
}
