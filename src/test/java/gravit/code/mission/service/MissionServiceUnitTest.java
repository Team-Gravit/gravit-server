package gravit.code.mission.service;

import gravit.code.global.event.badge.MissionCompletedEvent;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.response.MissionSummaryResponse;
import gravit.code.mission.fixture.MissionFixture;
import gravit.code.mission.repository.MissionRepository;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.MISSION_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MissionServiceUnitTest {

    @InjectMocks
    private MissionService missionService;

    @Mock
    private LessonSubmissionQueryService lessonSubmissionQueryService;

    @Mock
    private MissionRepository missionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ApplicationEventPublisher publisher;

    private User createUser(long id) {
        User user = User.create("test@test.com", "provider_" + id, "테스터", "handle" + id, 1, Role.USER);
        org.springframework.test.util.ReflectionTestUtils.setField(user, "id", id);
        return user;
    }

    @Nested
    @DisplayName("미션 요약을 조회할 때")
    class GetMissionSummaryResponse {

        @Test
        void 미션이_존재하면_요약을_반환한다() {
            // given
            long userId = 1L;
            MissionSummaryResponse summary = new MissionSummaryResponse(MissionType.COMPLETE_LESSON_ONE, false);

            when(missionRepository.findMissionSummaryByUserId(userId)).thenReturn(Optional.of(summary));

            // when
            MissionSummaryResponse result = missionService.getMissionSummary(userId);

            // then
            assertThat(result.missionType()).isEqualTo(MissionType.COMPLETE_LESSON_ONE);
        }

        @Test
        void 미션이_존재하지_않으면_예외가_발생한다() {
            // given
            long userId = 1L;

            when(missionRepository.findMissionSummaryByUserId(userId)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> missionService.getMissionSummary(userId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(MISSION_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("미션을 생성할 때")
    class CreateMission {

        @Test
        void 랜덤_미션을_생성하고_저장한다() {
            // given
            long userId = 1L;

            when(missionRepository.save(any(Mission.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            missionService.createMission(userId);

            // then
            verify(missionRepository).save(any(Mission.class));
        }
    }

    @Nested
    @DisplayName("미션을 재배정할 때")
    class ReassignMission {

        @Test
        void 미션이_있으면_모두_재배정한다() {
            // given
            Mission mission1 = MissionFixture.완료된_미션(1L, MissionType.COMPLETE_LESSON_ONE, 1L);
            Mission mission2 = MissionFixture.완료된_미션(2L, MissionType.PERFECT_LESSON_ONE, 2L);
            Page<Mission> firstPage = new PageImpl<>(List.of(mission1, mission2));
            Page<Mission> emptyPage = new PageImpl<>(List.of());

            when(missionRepository.findAll(any(Pageable.class)))
                    .thenReturn(firstPage)
                    .thenReturn(emptyPage);

            // when
            missionService.reassignMission();

            // then
            assertThat(mission1.isCompleted()).isFalse();
            assertThat(mission1.getProgressRate()).isEqualTo(0.0);
            assertThat(mission2.isCompleted()).isFalse();
            assertThat(mission2.getProgressRate()).isEqualTo(0.0);
        }

        @Test
        void 미션이_없으면_아무것도_하지_않는다() {
            // given
            when(missionRepository.findAll(any(Pageable.class)))
                    .thenReturn(new PageImpl<>(List.of()));

            // when
            missionService.reassignMission();

            // then
            verify(missionRepository).findAll(any(Pageable.class));
        }
    }

    @Nested
    @DisplayName("레슨 미션을 처리할 때")
    class HandleLessonMission {

        @Test
        void 미션이_존재하지_않으면_예외가_발생한다() {
            // given
            long userId = 1L;

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> missionService.handleLessonMission(userId, 1L, 120, 80))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(MISSION_NOT_FOUND);
        }

        @Test
        void 이미_완료된_미션이면_처리를_종료한다() {
            // given
            long userId = 1L;
            Mission mission = MissionFixture.완료된_미션(1L, MissionType.COMPLETE_LESSON_ONE, userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));

            // when
            missionService.handleLessonMission(userId, 1L, 120, 80);

            // then
            verify(lessonSubmissionQueryService, never()).getLessonSubmissionCount(anyLong(), anyLong());
        }

        @Test
        void 재풀이면_처리를_종료한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            Mission mission = MissionFixture.기본_미션(userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));
            when(lessonSubmissionQueryService.getLessonSubmissionCount(userId, lessonId)).thenReturn(2);

            // when
            missionService.handleLessonMission(userId, lessonId, 120, 80);

            // then
            assertThat(mission.getProgressRate()).isEqualTo(0.0);
        }

        @Test
        void COMPLETE_LESSON_ONE_미션이면_한_번에_완료된다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            Mission mission = MissionFixture.기본_미션(userId); // COMPLETE_LESSON_ONE
            User user = createUser(userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));
            when(lessonSubmissionQueryService.getLessonSubmissionCount(userId, lessonId)).thenReturn(1);
            when(userRepository.findById(userId)).thenReturn(Optional.of(user));

            // when
            missionService.handleLessonMission(userId, lessonId, 120, 80);

            // then
            assertThat(mission.isCompleted()).isTrue();
            assertThat(mission.getProgressRate()).isEqualTo(100.0);
            verify(publisher).publishEvent(any(MissionCompletedEvent.class));
        }

        @Test
        void PERFECT_LESSON_미션에서_정답율이_100이_아니면_진행도가_업데이트되지_않는다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            Mission mission = MissionFixture.저장된_미션(1L, MissionType.PERFECT_LESSON_ONE, userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));
            when(lessonSubmissionQueryService.getLessonSubmissionCount(userId, lessonId)).thenReturn(1);

            // when
            missionService.handleLessonMission(userId, lessonId, 120, 80);

            // then
            assertThat(mission.getProgressRate()).isEqualTo(0.0);
            verify(publisher, never()).publishEvent(any());
        }

        @Test
        void PERFECT_LESSON_ONE_미션에서_정답율_100이면_완료된다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            Mission mission = MissionFixture.저장된_미션(1L, MissionType.PERFECT_LESSON_ONE, userId);
            User user = createUser(userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));
            when(lessonSubmissionQueryService.getLessonSubmissionCount(userId, lessonId)).thenReturn(1);
            when(userRepository.findById(userId)).thenReturn(Optional.of(user));

            // when
            missionService.handleLessonMission(userId, lessonId, 120, 100);

            // then
            assertThat(mission.isCompleted()).isTrue();
            verify(publisher).publishEvent(any(MissionCompletedEvent.class));
        }

        @Test
        void LEARNING_MINUTES_미션이면_학습시간으로_진행도가_업데이트된다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            Mission mission = MissionFixture.저장된_미션(1L, MissionType.LEARNING_MINUTES_FIVE, userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));
            when(lessonSubmissionQueryService.getLessonSubmissionCount(userId, lessonId)).thenReturn(1);

            // when
            missionService.handleLessonMission(userId, lessonId, 120, 80); // 2분 (40% 진행, 미완료)

            // then
            assertThat(mission.getProgressRate()).isGreaterThan(0.0);
            assertThat(mission.isCompleted()).isFalse();
        }
    }

    @Nested
    @DisplayName("팔로우 미션을 처리할 때")
    class HandleFollowMission {

        @Test
        void 미션이_존재하지_않으면_예외가_발생한다() {
            // given
            FollowMissionEvent event = new FollowMissionEvent(1L);

            when(missionRepository.findByUserId(1L)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> missionService.handleFollowMission(event))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(MISSION_NOT_FOUND);
        }

        @Test
        void 이미_완료된_미션이면_처리를_종료한다() {
            // given
            long userId = 1L;
            Mission mission = MissionFixture.완료된_미션(1L, MissionType.FOLLOW_NEW_FRIEND, userId);
            FollowMissionEvent event = new FollowMissionEvent(userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));

            // when
            missionService.handleFollowMission(event);

            // then
            verify(userRepository, never()).findById(anyLong());
        }

        @Test
        void FOLLOW_NEW_FRIEND가_아닌_미션_타입이면_처리를_종료한다() {
            // given
            long userId = 1L;
            Mission mission = MissionFixture.기본_미션(userId); // COMPLETE_LESSON_ONE
            FollowMissionEvent event = new FollowMissionEvent(userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));

            // when
            missionService.handleFollowMission(event);

            // then
            assertThat(mission.getProgressRate()).isEqualTo(0.0);
            verify(userRepository, never()).findById(anyLong());
        }

        @Test
        void FOLLOW_NEW_FRIEND_미션이면_완료되고_경험치를_지급한다() {
            // given
            long userId = 1L;
            Mission mission = MissionFixture.저장된_미션(1L, MissionType.FOLLOW_NEW_FRIEND, userId);
            User user = createUser(userId);
            FollowMissionEvent event = new FollowMissionEvent(userId);

            when(missionRepository.findByUserId(userId)).thenReturn(Optional.of(mission));
            when(userRepository.findById(userId)).thenReturn(Optional.of(user));

            // when
            missionService.handleFollowMission(event);

            // then
            assertThat(mission.isCompleted()).isTrue();
            assertThat(mission.getProgressRate()).isEqualTo(100.0);
            verify(userRepository).save(user);
        }
    }
}
