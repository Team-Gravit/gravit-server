package gravit.code.learning.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.support.TransactionTemplate;

import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_NOT_FOUND;
import static gravit.code.learning.fixture.LearningFixture.저장_전_학습;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LearningCommandServiceIntegrationTest {

    @Autowired
    private LearningCommandService learningCommandService;

    @Autowired
    private LearningQueryService learningQueryService;

    @Autowired
    private LearningRepository learningRepository;

    @Autowired
    private TransactionTemplate transactionTemplate;

    @Nested
    @DisplayName("사용자의 학습 정보를 조회할 때")
    class GetLearning {

        @Test
        void 학습_정보가_존재하면_반환한다() {
            // given
            long userId = 1L;
            Learning saved = learningRepository.save(Learning.create(userId));

            // when
            Learning result = learningQueryService.getLearning(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.getId()).isEqualTo(saved.getId());
                softly.assertThat(result.getUserId()).isEqualTo(userId);
                softly.assertThat(result.getRecentSolvedChapterId()).isEqualTo(1L);
                softly.assertThat(result.getConsecutiveSolvedDays()).isZero();
            });
        }

        @Test
        void 학습_정보가_존재하지_않으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> learningQueryService.getLearning(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(LEARNING_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("연속 학습일을 정산할 때")
    class UpdateConsecutiveDays {

        @Test
        void 오늘_학습한_유저는_연속일수가_유지되고_표시만_지워진다() {
            // given
            long userId = 1L;
            learningRepository.save(저장_전_학습(userId, true, 5));

            // when
            learningCommandService.updateConsecutiveDays();

            // then
            Learning result = learningQueryService.getLearning(userId);
            assertSoftly(softly -> {
                softly.assertThat(result.isTodaySolved()).isFalse();
                softly.assertThat(result.getConsecutiveSolvedDays()).isEqualTo(5);
            });
        }

        @Test
        void 오늘_미학습_유저는_연속일수가_0으로_초기화된다() {
            // given
            long userId = 1L;
            learningRepository.save(저장_전_학습(userId, false, 5));

            // when
            learningCommandService.updateConsecutiveDays();

            // then
            Learning result = learningQueryService.getLearning(userId);
            assertSoftly(softly -> {
                softly.assertThat(result.isTodaySolved()).isFalse();
                softly.assertThat(result.getConsecutiveSolvedDays()).isZero();
            });
        }

        @Test
        void 이미_초기화된_유저는_갱신하지_않는다() {
            // given
            learningRepository.save(저장_전_학습(1L, false, 0));

            // when
            int resetCount = transactionTemplate.execute(status -> learningRepository.resetConsecutiveDays());

            // then
            assertThat(resetCount).isZero();
        }

        @Test
        void 여러_유저를_한_번에_정산한다() {
            // given
            learningRepository.save(저장_전_학습(1L, true, 5));
            learningRepository.save(저장_전_학습(2L, false, 3));
            learningRepository.save(저장_전_학습(3L, false, 0));

            // when
            int resetCount = transactionTemplate.execute(status -> learningRepository.resetConsecutiveDays());

            // then
            Learning 학습한_유저 = learningQueryService.getLearning(1L);
            Learning 미학습_유저 = learningQueryService.getLearning(2L);
            Learning 연속일수_없는_유저 = learningQueryService.getLearning(3L);

            assertSoftly(softly -> {
                softly.assertThat(resetCount).isEqualTo(2);

                softly.assertThat(학습한_유저.isTodaySolved()).isFalse();
                softly.assertThat(학습한_유저.getConsecutiveSolvedDays()).isEqualTo(5);

                softly.assertThat(미학습_유저.isTodaySolved()).isFalse();
                softly.assertThat(미학습_유저.getConsecutiveSolvedDays()).isZero();

                softly.assertThat(연속일수_없는_유저.isTodaySolved()).isFalse();
                softly.assertThat(연속일수_없는_유저.getConsecutiveSolvedDays()).isZero();
            });
        }

        @Test
        void 같은_날_두_번_제출해도_연속일수는_한_번만_오른다() {
            // given
            long userId = 1L;
            long chapterId = 1L;
            learningRepository.save(저장_전_학습(userId, false, 5));

            // when
            learningCommandService.updateLearningStatus(userId, chapterId);
            learningCommandService.updateLearningStatus(userId, chapterId);

            // then
            Learning result = learningQueryService.getLearning(userId);
            assertSoftly(softly -> {
                softly.assertThat(result.isTodaySolved()).isTrue();
                softly.assertThat(result.getConsecutiveSolvedDays()).isEqualTo(6);
            });
        }
    }
}
