package gravit.code.learning.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_NOT_FOUND;
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
    @DisplayName("사용자의 학습 정보를 get-or-create로 조회할 때")
    class GetOrCreateLearning {

        @Test
        void 학습_정보가_존재하면_기존_정보를_반환하고_생성하지_않는다() {
            // given
            long userId = 1L;
            Learning saved = learningRepository.save(Learning.create(userId));

            // when
            Learning result = learningCommandService.getOrCreateLearning(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.getId()).isEqualTo(saved.getId());
                softly.assertThat(result.getUserId()).isEqualTo(userId);
                softly.assertThat(learningRepository.count()).isEqualTo(1L);
            });
        }

        @Test
        void 학습_정보가_존재하지_않으면_기본값으로_생성해_반환한다() {
            // given
            long userId = 1L;

            // when
            Learning result = learningCommandService.getOrCreateLearning(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.getId()).isNotNull();
                softly.assertThat(result.getUserId()).isEqualTo(userId);
                softly.assertThat(result.getRecentSolvedChapterId()).isEqualTo(1L);
                softly.assertThat(result.isTodaySolved()).isFalse();
                softly.assertThat(result.getConsecutiveSolvedDays()).isZero();
                softly.assertThat(result.getPlanetConquestRate()).isZero();
                softly.assertThat(learningRepository.findByUserId(userId)).isPresent();
            });
        }
    }
}
