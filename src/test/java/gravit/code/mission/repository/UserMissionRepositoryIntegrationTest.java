package gravit.code.mission.repository;

import gravit.code.mission.domain.UserMission;
import gravit.code.mission.fixture.MissionFixture;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class UserMissionRepositoryIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long MISSION_ID = 1L;
    private static final LocalDate ASSIGNED_DATE = LocalDate.of(2025, 8, 5);
    private static final LocalDateTime FIRST_TIME = LocalDateTime.of(2025, 8, 5, 10, 0, 0);
    private static final LocalDateTime SECOND_TIME = LocalDateTime.of(2025, 8, 5, 11, 0, 0);

    @Autowired
    private UserMissionRepository userMissionRepository;

    @Autowired
    private TransactionTemplate transactionTemplate;

    private int insertIfAbsent(
            long userId,
            LocalDate assignedDate
    ) {
        return transactionTemplate.execute(status ->
                userMissionRepository.insertIfAbsent(userId, MISSION_ID, assignedDate, FIRST_TIME));
    }

    @Nested
    @DisplayName("오늘자 미션을 삽입할 때")
    class InsertIfAbsent {

        @Test
        void 배정이_없으면_삽입하고_1을_반환한다() {
            // given & when
            int inserted = insertIfAbsent(USER_ID, ASSIGNED_DATE);

            // then
            assertSoftly(softly -> {
                softly.assertThat(inserted).isEqualTo(1);
                softly.assertThat(userMissionRepository.count()).isEqualTo(1);
            });
        }

        @Test
        void 같은_유저_같은_날짜로_두_번_호출하면_예외_없이_0을_반환한다() {
            // given
            int first = insertIfAbsent(USER_ID, ASSIGNED_DATE);

            // when
            int second = insertIfAbsent(USER_ID, ASSIGNED_DATE);

            // then
            assertSoftly(softly -> {
                softly.assertThat(first).isEqualTo(1);
                softly.assertThat(second).isZero();
                softly.assertThat(userMissionRepository.count()).isEqualTo(1);
            });
        }

        @Test
        void 같은_유저라도_날짜가_다르면_새_행으로_쌓인다() {
            // given
            insertIfAbsent(USER_ID, ASSIGNED_DATE.minusDays(1));

            // when
            int today = insertIfAbsent(USER_ID, ASSIGNED_DATE);

            // then
            assertSoftly(softly -> {
                softly.assertThat(today).isEqualTo(1);
                softly.assertThat(userMissionRepository.count()).isEqualTo(2);
            });
        }
    }

    @Nested
    @DisplayName("미션을 완료 처리할 때")
    class CompleteIfNotCompleted {

        @Test
        void 아직_완료되지_않았으면_완료_시각을_기록하고_1을_반환한다() {
            // given
            UserMission saved = userMissionRepository.save(
                    MissionFixture.오늘_배정된_미션(USER_ID, MISSION_ID, ASSIGNED_DATE));

            // when
            int completed = transactionTemplate.execute(status ->
                    userMissionRepository.completeIfNotCompleted(saved.getId(), FIRST_TIME));

            // then
            UserMission result = userMissionRepository.findById(saved.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(completed).isEqualTo(1);
                softly.assertThat(result.getCompletedAt()).isEqualTo(FIRST_TIME);
                softly.assertThat(result.isCompleted()).isTrue();
            });
        }

        @Test
        void 두_번_호출하면_두_번째는_0을_반환하고_완료_시각이_유지된다() {
            // given
            UserMission saved = userMissionRepository.save(
                    MissionFixture.오늘_배정된_미션(USER_ID, MISSION_ID, ASSIGNED_DATE));
            int first = transactionTemplate.execute(status ->
                    userMissionRepository.completeIfNotCompleted(saved.getId(), FIRST_TIME));

            // when
            int second = transactionTemplate.execute(status ->
                    userMissionRepository.completeIfNotCompleted(saved.getId(), SECOND_TIME));

            // then
            UserMission result = userMissionRepository.findById(saved.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(first).isEqualTo(1);
                softly.assertThat(second).isZero();
                softly.assertThat(result.getCompletedAt()).isEqualTo(FIRST_TIME);
            });
        }
    }

    @Nested
    @DisplayName("배정된 유저를 조회할 때")
    class FindAssignedUserIds {

        @Test
        void 해당_날짜에_배정된_유저만_반환한다() {
            // given
            insertIfAbsent(USER_ID, ASSIGNED_DATE);
            insertIfAbsent(USER_ID + 1, ASSIGNED_DATE.minusDays(1));

            // when
            Set<Long> assignedUserIds = userMissionRepository.findAssignedUserIds(
                    ASSIGNED_DATE, List.of(USER_ID, USER_ID + 1));

            // then
            assertThat(assignedUserIds).containsExactly(USER_ID);
        }
    }
}
