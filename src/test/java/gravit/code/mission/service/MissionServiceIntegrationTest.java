package gravit.code.mission.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.UserMission;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.mission.fixture.MissionFixture;
import gravit.code.mission.repository.MissionRepository;
import gravit.code.mission.repository.UserMissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.Clock;
import java.time.LocalDate;

import static gravit.code.global.exception.domain.CustomErrorCode.MISSION_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class MissionServiceIntegrationTest {

    private static final long NON_EXISTENT_USER_ID = 999L;
    private static final int ACCURACY_PERFECT = 100;
    private static final int ACCURACY_NOT_PERFECT = 80;
    private static final int LEARNING_TIME = 120;

    @Autowired
    private MissionService missionService;

    @Autowired
    private MissionRepository missionRepository;

    @Autowired
    private UserMissionRepository userMissionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private Clock clock;

    // 미션 배정 대상은 온보딩을 마친 유저다. 대부분의 테스트가 이 상태를 전제한다
    private User createUser(String suffix) {
        return createUser(suffix, Role.USER, true);
    }

    private User createUser(
            String suffix,
            Role role,
            boolean onboarded
    ) {
        User user = User.create(
                "test" + suffix + "@test.com",
                "provider_" + suffix,
                "테스터" + suffix,
                "handle" + suffix,
                1,
                role
        );

        if (onboarded)
            user.completeOnboarding();

        return userRepository.save(user);
    }

    private LocalDate today() {
        return LocalDate.now(clock);
    }

    private void 레슨을_제출한다(
            long userId,
            long lessonId,
            int learningTime,
            int accuracy
    ) {
        lessonSubmissionRepository.save(LessonSubmission.create(learningTime, accuracy, lessonId, userId));
    }

    private UserMission 배정된_미션(long userId) {
        return userMissionRepository.findAssignedMission(userId, today()).orElseThrow().userMission();
    }

    private int 유저_경험치(long userId) {
        return userRepository.findById(userId).orElseThrow().getLevel().getXp();
    }

    @Nested
    @DisplayName("미션 상세를 조회할 때")
    class GetMissionDetail {

        @Test
        void 오늘자_배정이_있으면_해당_미션의_상세를_반환한다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_3개());
            userMissionRepository.save(MissionFixture.진행중_미션(user.getId(), mission.getId(), today(), 1));

            // when
            MissionDetailResponse result = missionService.getMissionDetail(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.missionType()).isEqualTo("COMPLETE_LESSONS_THREE");
                softly.assertThat(result.missionDescription()).isEqualTo("레슨 3개 완료하기");
                softly.assertThat(result.awardXp()).isEqualTo(20);
                softly.assertThat(result.progressRate()).isEqualTo(33.3);
                softly.assertThat(result.isCompleted()).isFalse();
            });
        }

        @Test
        void 오늘자_배정이_없으면_그_자리에서_배정되어_진행도_0인_미션을_반환한다() {
            // given
            User user = createUser("1");
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            MissionDetailResponse result = missionService.getMissionDetail(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.missionType()).isEqualTo("COMPLETE_LESSON_ONE");
                softly.assertThat(result.progressRate()).isZero();
                softly.assertThat(result.isCompleted()).isFalse();
                softly.assertThat(userMissionRepository.count()).isEqualTo(1);
            });
        }

        @Test
        void 두_번_조회해도_배정은_하나만_생긴다() {
            // given
            User user = createUser("1");
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            missionService.getMissionDetail(user.getId());
            missionService.getMissionDetail(user.getId());

            // then
            assertThat(userMissionRepository.count()).isEqualTo(1);
        }

        @Test
        void 활성_미션_정의가_없으면_예외가_발생한다() {
            // given
            User user = createUser("1");
            missionRepository.save(MissionFixture.비활성_미션정의());

            // when & then
            assertThatThrownBy(() -> missionService.getMissionDetail(user.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(MISSION_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("레슨 미션을 처리할 때")
    class HandleLessonMission {

        @Test
        void 오늘자_배정이_없으면_예외가_발생한다() {
            // given & when & then
            assertThatThrownBy(() -> missionService.handleLessonMission(
                    NON_EXISTENT_USER_ID, 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(MISSION_NOT_FOUND);
        }

        @Test
        void 재풀이면_진행도가_오르지_않는다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_3개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            long lessonId = 1L;
            레슨을_제출한다(user.getId(), lessonId, LEARNING_TIME, ACCURACY_NOT_PERFECT);
            레슨을_제출한다(user.getId(), lessonId, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // when
            missionService.handleLessonMission(user.getId(), lessonId, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // then
            assertThat(배정된_미션(user.getId()).getProgressCount()).isZero();
        }

        @Test
        void 레슨_완료_미션은_제출마다_진행도가_1씩_누적된다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_3개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            레슨을_제출한다(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);
            레슨을_제출한다(user.getId(), 2L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // when
            missionService.handleLessonMission(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);
            missionService.handleLessonMission(user.getId(), 2L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // then
            UserMission result = 배정된_미션(user.getId());
            assertSoftly(softly -> {
                softly.assertThat(result.getProgressCount()).isEqualTo(2);
                softly.assertThat(result.isCompleted()).isFalse();
                softly.assertThat(유저_경험치(user.getId())).isZero();
            });
        }

        @Test
        void 목표에_도달하면_완료_시각이_기록되고_경험치가_지급된다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_1개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            레슨을_제출한다(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // when
            missionService.handleLessonMission(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // then
            UserMission result = 배정된_미션(user.getId());
            assertSoftly(softly -> {
                softly.assertThat(result.getProgressCount()).isEqualTo(1);
                softly.assertThat(result.isCompleted()).isTrue();
                softly.assertThat(result.getCompletedAt()).isNotNull();
                softly.assertThat(유저_경험치(user.getId())).isEqualTo(10);
            });
        }

        @Test
        void 완료된_뒤_추가_제출은_경험치를_중복_지급하지_않는다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_1개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            레슨을_제출한다(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);
            missionService.handleLessonMission(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            레슨을_제출한다(user.getId(), 2L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // when
            missionService.handleLessonMission(user.getId(), 2L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // then
            assertSoftly(softly -> {
                softly.assertThat(배정된_미션(user.getId()).getProgressCount()).isEqualTo(1);
                softly.assertThat(유저_경험치(user.getId())).isEqualTo(10);
            });
        }

        @Test
        void 정답율이_100이_아니면_정답율_미션의_진행도가_오르지_않는다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_정답율_100_레슨_1개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            레슨을_제출한다(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // when
            missionService.handleLessonMission(user.getId(), 1L, LEARNING_TIME, ACCURACY_NOT_PERFECT);

            // then
            assertThat(배정된_미션(user.getId()).getProgressCount()).isZero();
        }

        @Test
        void 정답율이_100이면_정답율_미션이_완료된다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_정답율_100_레슨_1개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            레슨을_제출한다(user.getId(), 1L, LEARNING_TIME, ACCURACY_PERFECT);

            // when
            missionService.handleLessonMission(user.getId(), 1L, LEARNING_TIME, ACCURACY_PERFECT);

            // then
            UserMission result = 배정된_미션(user.getId());
            assertSoftly(softly -> {
                softly.assertThat(result.isCompleted()).isTrue();
                softly.assertThat(유저_경험치(user.getId())).isEqualTo(30);
            });
        }

        @Test
        void 학습_시간_미션은_1회_제출당_상한까지만_반영된다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_학습_15분());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            int overCapLearningTime = 400;
            레슨을_제출한다(user.getId(), 1L, overCapLearningTime, ACCURACY_NOT_PERFECT);

            // when
            missionService.handleLessonMission(user.getId(), 1L, overCapLearningTime, ACCURACY_NOT_PERFECT);

            // then
            assertThat(배정된_미션(user.getId()).getProgressCount()).isEqualTo(300);
        }
    }

    @Nested
    @DisplayName("팔로우 미션을 처리할 때")
    class HandleFollowMission {

        @Test
        void 오늘자_배정이_없으면_예외가_발생한다() {
            // given
            FollowMissionEvent event = new FollowMissionEvent(NON_EXISTENT_USER_ID);

            // when & then
            assertThatThrownBy(() -> missionService.handleFollowMission(event))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(MISSION_NOT_FOUND);
        }

        @Test
        void 팔로우_미션이면_완료되고_경험치가_지급된다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_팔로우());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            // when
            missionService.handleFollowMission(new FollowMissionEvent(user.getId()));

            // then
            UserMission result = 배정된_미션(user.getId());
            assertSoftly(softly -> {
                softly.assertThat(result.getProgressCount()).isEqualTo(1);
                softly.assertThat(result.isCompleted()).isTrue();
                softly.assertThat(유저_경험치(user.getId())).isEqualTo(40);
            });
        }

        @Test
        void 팔로우_미션이_아니면_진행도가_변하지_않는다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_1개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            // when
            missionService.handleFollowMission(new FollowMissionEvent(user.getId()));

            // then
            assertSoftly(softly -> {
                softly.assertThat(배정된_미션(user.getId()).getProgressCount()).isZero();
                softly.assertThat(유저_경험치(user.getId())).isZero();
            });
        }

        @Test
        void 이미_완료된_미션이면_경험치가_중복_지급되지_않는다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_팔로우());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));
            missionService.handleFollowMission(new FollowMissionEvent(user.getId()));

            // when
            missionService.handleFollowMission(new FollowMissionEvent(user.getId()));

            // then
            assertSoftly(softly -> {
                softly.assertThat(배정된_미션(user.getId()).getProgressCount()).isEqualTo(1);
                softly.assertThat(유저_경험치(user.getId())).isEqualTo(40);
            });
        }
    }

    @Nested
    @DisplayName("온보딩으로 미션을 배정할 때")
    class CreateMission {

        @Test
        void 오늘자_미션이_배정된다() {
            // given
            User user = createUser("1");
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            missionService.createMission(user.getId());

            // then
            assertThat(userMissionRepository.findAssignedMission(user.getId(), today())).isPresent();
        }

        @Test
        void 이미_배정돼_있으면_중복_삽입되지_않는다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_1개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            // when
            missionService.createMission(user.getId());

            // then
            assertThat(userMissionRepository.count()).isEqualTo(1);
        }

        @Test
        void 이미_배정된_유저의_재시도는_활성_미션이_없어도_예외가_발생하지_않는다() {
            // given: 배정만 남고 활성 미션 정의가 사라진 중복 재시도 상황
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.비활성_미션정의());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today()));

            // when & then
            assertThatCode(() -> missionService.createMission(user.getId()))
                    .doesNotThrowAnyException();
            assertThat(userMissionRepository.count()).isEqualTo(1);
        }
    }

    @Nested
    @DisplayName("자정 배정을 청크 단위로 수행할 때")
    class AssignChunk {

        @Test
        void 청크_크기만큼_배정하고_마지막_유저_id를_반환한다() {
            // given
            User user1 = createUser("1");
            User user2 = createUser("2");
            createUser("3");
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            long lastUserId = missionService.assignChunk(today(), 0L, 2);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lastUserId).isEqualTo(user2.getId());
                softly.assertThat(userMissionRepository.count()).isEqualTo(2);
                softly.assertThat(userMissionRepository.findAssignedMission(user1.getId(), today())).isPresent();
            });
        }

        @Test
        void 다음_청크는_이전_청크_이후의_유저를_배정한다() {
            // given
            createUser("1");
            User user2 = createUser("2");
            User user3 = createUser("3");
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            long lastUserId = missionService.assignChunk(today(), user2.getId(), 2);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lastUserId).isEqualTo(user3.getId());
                softly.assertThat(userMissionRepository.count()).isEqualTo(1);
                softly.assertThat(userMissionRepository.findAssignedMission(user3.getId(), today())).isPresent();
            });
        }

        @Test
        void 대상_유저가_없으면_마지막_유저_id를_그대로_반환한다() {
            // given
            User user = createUser("1");
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            long lastUserId = missionService.assignChunk(today(), user.getId(), 10);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lastUserId).isEqualTo(user.getId());
                softly.assertThat(userMissionRepository.count()).isZero();
            });
        }

        @Test
        void 재실행해도_중복_삽입되지_않는다() {
            // given
            createUser("1");
            createUser("2");
            missionRepository.save(MissionFixture.미션정의_레슨_1개());
            missionService.assignChunk(today(), 0L, 10);

            // when
            missionService.assignChunk(today(), 0L, 10);

            // then
            assertThat(userMissionRepository.count()).isEqualTo(2);
        }

        @Test
        void 온보딩하지_않은_유저는_배정_대상에서_제외된다() {
            // given
            User onboardedUser = createUser("1");
            User notOnboardedUser = createUser("2", Role.USER, false);
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            missionService.assignChunk(today(), 0L, 10);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userMissionRepository.count()).isEqualTo(1);
                softly.assertThat(userMissionRepository.findAssignedMission(onboardedUser.getId(), today())).isPresent();
                softly.assertThat(userMissionRepository.findAssignedMission(notOnboardedUser.getId(), today())).isEmpty();
            });
        }

        @Test
        void 관리자도_배정_대상에_포함된다() {
            // given
            User admin = createUser("1", Role.ADMIN, true);
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            missionService.assignChunk(today(), 0L, 10);

            // then
            assertThat(userMissionRepository.findAssignedMission(admin.getId(), today())).isPresent();
        }

        @Test
        void 탈퇴한_유저는_배정_대상에서_제외된다() {
            // given
            User user = createUser("1");
            userRepository.delete(user);
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            missionService.assignChunk(today(), 0L, 10);

            // then
            assertThat(userMissionRepository.count()).isZero();
        }

        @Test
        void 어제_배정이_있어도_오늘_배정이_새_행으로_쌓인다() {
            // given
            User user = createUser("1");
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_1개());
            userMissionRepository.save(
                    MissionFixture.오늘_배정된_미션(user.getId(), mission.getId(), today().minusDays(1)));

            // when
            missionService.assignChunk(today(), 0L, 10);

            // then
            assertSoftly(softly -> {
                softly.assertThat(userMissionRepository.count()).isEqualTo(2);
                softly.assertThat(userMissionRepository.findAssignedMission(user.getId(), today())).isPresent();
            });
        }
    }
}
