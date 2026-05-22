package gravit.code.mission.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.mission.dto.response.MissionSummaryResponse;
import gravit.code.mission.repository.MissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.MISSION_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
@Transactional
class MissionServiceIntegrationTest {

    @Autowired
    private MissionService missionService;

    @Autowired
    private MissionRepository missionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    private User createAndSaveUser() {
        return userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 1, Role.USER));
    }

    @Nested
    @DisplayName("미션 요약을 조회할 때")
    class GetMissionSummaryResponse {

        @Test
        void 미션이_존재하면_요약을_반환한다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));

            // when
            MissionSummaryResponse result = missionService.getMissionSummary(user.getId());

            // then
            assertThat(result.missionType()).isEqualTo(MissionType.COMPLETE_LESSON_ONE);
            assertThat(result.isCompleted()).isFalse();
        }

        @Test
        void 미션이_존재하지_않으면_예외가_발생한다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> missionService.getMissionSummary(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(MISSION_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("미션을 생성할 때")
    class CreateMission {

        @Test
        void 미션을_생성하고_저장한다() {
            // given
            User user = createAndSaveUser();

            // when
            missionService.createMission(user.getId());

            // then
            assertThat(missionRepository.findByUserId(user.getId())).isPresent();
        }
    }

    @Nested
    @DisplayName("미션을 재배정할 때")
    class ReassignMission {

        @Test
        void 미션이_있으면_모두_재배정된다() {
            // given
            User user1 = userRepository.save(User.create("a@test.com", "provider_a", "유저1", "handle_a", 1, Role.USER));
            User user2 = userRepository.save(User.create("b@test.com", "provider_b", "유저2", "handle_b", 1, Role.USER));
            Mission mission1 = missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user1.getId()));
            Mission mission2 = missionRepository.save(Mission.create(MissionType.PERFECT_LESSON_ONE, user2.getId()));

            // when
            missionService.reassignMission();

            // then
            Mission updated1 = missionRepository.findByUserId(user1.getId()).get();
            Mission updated2 = missionRepository.findByUserId(user2.getId()).get();
            assertThat(updated1.isCompleted()).isFalse();
            assertThat(updated1.getProgressRate()).isEqualTo(0.0);
            assertThat(updated2.isCompleted()).isFalse();
            assertThat(updated2.getProgressRate()).isEqualTo(0.0);
        }

        @Test
        void 미션이_없으면_아무것도_하지_않는다() {
            // given (no missions saved)

            // when & then (no exception)
            missionService.reassignMission();
            assertThat(missionRepository.count()).isEqualTo(0);
        }
    }

    @Nested
    @DisplayName("레슨 미션을 처리할 때")
    class HandleLessonMission {

        @Test
        void 미션이_존재하지_않으면_예외가_발생한다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> missionService.handleLessonMission(nonExistentUserId, 1L, 120, 80))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(MISSION_NOT_FOUND);
        }

        @Test
        void 이미_완료된_미션이면_진행도가_변경되지_않는다() {
            // given
            User user = createAndSaveUser();
            Mission mission = missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));
            // 미션을 완료 상태로 만들기
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, 1L, user.getId()));
            missionService.handleLessonMission(user.getId(), 1L, 120, 80);
            double completedProgressRate = missionRepository.findByUserId(user.getId()).get().getProgressRate();

            // 두 번째 호출 (이미 완료 상태)
            // when
            missionService.handleLessonMission(user.getId(), 2L, 120, 80);

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.isCompleted()).isTrue();
            assertThat(result.getProgressRate()).isEqualTo(completedProgressRate);
        }

        @Test
        void 재풀이면_진행도가_변경되지_않는다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));
            long lessonId = 1L;
            // 이미 한 번 제출한 기록 2개 저장 (tryCount > 1 의미: 두 번째 제출)
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lessonId, user.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lessonId, user.getId()));

            // when
            missionService.handleLessonMission(user.getId(), lessonId, 120, 80);

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.getProgressRate()).isEqualTo(0.0);
        }

        @Test
        void COMPLETE_LESSON_ONE_미션이면_완료된다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));
            long lessonId = 1L;
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lessonId, user.getId()));

            // when
            missionService.handleLessonMission(user.getId(), lessonId, 120, 80);

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.isCompleted()).isTrue();
            assertThat(result.getProgressRate()).isEqualTo(100.0);
        }

        @Test
        void PERFECT_LESSON_ONE_미션에서_정답율이_100이_아니면_진행도가_업데이트되지_않는다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.PERFECT_LESSON_ONE, user.getId()));
            long lessonId = 1L;
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lessonId, user.getId()));

            // when
            missionService.handleLessonMission(user.getId(), lessonId, 120, 80);

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.getProgressRate()).isEqualTo(0.0);
        }

        @Test
        void PERFECT_LESSON_ONE_미션에서_정답율_100이면_완료된다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.PERFECT_LESSON_ONE, user.getId()));
            long lessonId = 1L;
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lessonId, user.getId()));

            // when
            missionService.handleLessonMission(user.getId(), lessonId, 120, 100);

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.isCompleted()).isTrue();
            assertThat(result.getProgressRate()).isEqualTo(100.0);
        }

        @Test
        void LEARNING_MINUTES_미션이면_학습시간으로_진행도가_업데이트된다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.LEARNING_MINUTES_FIVE, user.getId()));
            long lessonId = 1L;
            lessonSubmissionRepository.save(LessonSubmission.create(300, 80, lessonId, user.getId()));

            // when
            missionService.handleLessonMission(user.getId(), lessonId, 300, 80); // 5분

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.getProgressRate()).isGreaterThan(0.0);
        }
    }

    @Nested
    @DisplayName("팔로우 미션을 처리할 때")
    class HandleFollowMission {

        @Test
        void 미션이_존재하지_않으면_예외가_발생한다() {
            // given
            FollowMissionEvent event = new FollowMissionEvent(999L);

            // when & then
            assertThatThrownBy(() -> missionService.handleFollowMission(event))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(MISSION_NOT_FOUND);
        }

        @Test
        void 이미_완료된_미션이면_진행도가_변경되지_않는다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.FOLLOW_NEW_FRIEND, user.getId()));
            // 완료 상태로 만들기
            missionService.handleFollowMission(new FollowMissionEvent(user.getId()));
            double completedProgressRate = missionRepository.findByUserId(user.getId()).get().getProgressRate();

            // when (두 번째 호출)
            missionService.handleFollowMission(new FollowMissionEvent(user.getId()));

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.getProgressRate()).isEqualTo(completedProgressRate);
        }

        @Test
        void FOLLOW_NEW_FRIEND가_아닌_미션_타입이면_처리를_종료한다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));
            FollowMissionEvent event = new FollowMissionEvent(user.getId());

            // when
            missionService.handleFollowMission(event);

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.getProgressRate()).isEqualTo(0.0);
        }

        @Test
        void FOLLOW_NEW_FRIEND_미션이면_완료된다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.FOLLOW_NEW_FRIEND, user.getId()));
            FollowMissionEvent event = new FollowMissionEvent(user.getId());

            // when
            missionService.handleFollowMission(event);

            // then
            Mission result = missionRepository.findByUserId(user.getId()).get();
            assertThat(result.isCompleted()).isTrue();
            assertThat(result.getProgressRate()).isEqualTo(100.0);
        }
    }

    @Nested
    @DisplayName("미션 상세를 조회할 때")
    class GetMissionDetailResponse {

        @Test
        void 미션이_존재하면_상세를_반환한다() {
            // given
            User user = createAndSaveUser();
            missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));

            // when
            MissionDetailResponse result = missionService.getMissionDetail(user.getId());

            // then
            assertThat(result.missionType()).isEqualTo(MissionType.COMPLETE_LESSON_ONE.name());
            assertThat(result.missionDescription()).isEqualTo(MissionType.COMPLETE_LESSON_ONE.getDescription());
            assertThat(result.awardXp()).isEqualTo(MissionType.COMPLETE_LESSON_ONE.getAwardXp());
            assertThat(result.progressRate()).isEqualTo(0.0);
            assertThat(result.isCompleted()).isFalse();
        }

        @Test
        void 미션이_존재하지_않으면_예외가_발생한다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> missionService.getMissionDetail(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(MISSION_NOT_FOUND);
        }
    }
}
