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
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LearningServiceIntegrationTest {

    @Autowired
    private LearningService learningService;

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
            Learning result = learningService.getLearning(userId);

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
            assertThatThrownBy(() -> learningService.getLearning(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(LEARNING_NOT_FOUND);
        }
    }
}
