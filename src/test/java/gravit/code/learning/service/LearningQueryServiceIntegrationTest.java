package gravit.code.learning.service;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUserDto;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@TCSpringBootTest
class LearningQueryServiceIntegrationTest {

    // 고정 시계 기준일 2025-08-05. active 임계값(미접속<7일) = 2025-07-30 00:00 이후 접속
    private static final LocalDateTime ACTIVE = LocalDateTime.of(2025, 8, 5, 9, 0);    // 오늘 접속
    private static final LocalDateTime INACTIVE = LocalDateTime.of(2025, 7, 20, 9, 0); // 16일 미접속

    @Autowired
    private LearningQueryService learningQueryService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LearningRepository learningRepository;

    @Nested
    @DisplayName("연속학습 위기 대상을 조회할 때")
    class GetConsecutiveAtRiskUsers {

        @Test
        void 연속1일이상_오늘미완료_최근접속_유저만_반환한다() {
            // given
            long target = createUserAndLearning(1, ACTIVE, 3, false);  // 대상
            createUserAndLearning(2, ACTIVE, 0, false);                // 연속 0 → 제외
            createUserAndLearning(3, ACTIVE, 3, true);                 // 오늘 완료 → 제외
            createUserAndLearning(4, INACTIVE, 3, false);              // 미접속 7일↑ → 제외

            // when
            List<ConsecutiveAtRiskUserDto> result = learningQueryService.getConsecutiveAtRiskUsers();

            // then
            assertThat(result).hasSize(1);
            assertThat(result.get(0).userId()).isEqualTo(target);
            assertThat(result.get(0).consecutiveSolvedDays()).isEqualTo(3);
        }

        @Test
        void 대상이_없으면_빈_리스트를_반환한다() {
            // given
            createUserAndLearning(1, ACTIVE, 0, false);

            // when
            List<ConsecutiveAtRiskUserDto> result = learningQueryService.getConsecutiveAtRiskUsers();

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("오늘 미완료 대상을 조회할 때")
    class GetDailyIncompleteUserIds {

        @Test
        void 연속0_오늘미완료_최근접속_유저만_반환한다() {
            // given
            long target = createUserAndLearning(1, ACTIVE, 0, false);  // 대상
            createUserAndLearning(2, ACTIVE, 3, false);                // 연속 1↑ → 제외
            createUserAndLearning(3, ACTIVE, 0, true);                 // 오늘 완료 → 제외
            createUserAndLearning(4, INACTIVE, 0, false);              // 미접속 7일↑ → 제외

            // when
            List<Long> result = learningQueryService.getDailyIncompleteUserIds();

            // then
            assertThat(result).containsExactly(target);
        }
    }

    private long createUserAndLearning(
            int index,
            LocalDateTime lastAccessedAt,
            int consecutiveDays,
            boolean todaySolved
    ) {
        User user = userRepository.save(
                User.create("e" + index + "@test.com", "p" + index, "유저" + index, "h" + index, 1, Role.USER));
        ReflectionTestUtils.setField(user, "lastAccessedAt", lastAccessedAt);
        userRepository.save(user);

        Learning learning = Learning.create(user.getId());
        ReflectionTestUtils.setField(learning, "consecutiveSolvedDays", consecutiveDays);
        ReflectionTestUtils.setField(learning, "todaySolved", todaySolved);
        learningRepository.save(learning);

        return user.getId();
    }
}
