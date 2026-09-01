package gravit.code.interviewQuestion.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewLevel;
import gravit.code.interviewQuestion.domain.InterviewCategory;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.dto.internal.SelectedInterviewQuestion;
import gravit.code.interviewQuestion.repository.InterviewCategoryRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.interviewTechStack.domain.InterviewAxis;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.공통CS_카테고리;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.난이도별_질문;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.직무별_카테고리;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.질문_여러개;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewQuestionSelectionServiceIntegrationTest {

    private static final int QUESTION_COUNT = 5;
    private static final boolean COVER_ALL_CATEGORIES = true;
    private static final boolean NO_COVERAGE_REQUIRED = false;

    @Autowired
    private InterviewQuestionSelectionService interviewQuestionSelectionService;

    @Autowired
    private InterviewCategoryRepository interviewCategoryRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Nested
    @DisplayName("세션 레벨로 질문을 뽑을 때")
    class SelectByLevel {

        @Test
        void 하_레벨은_하_3문항과_중_2문항을_뽑는다() {
            // given
            long categoryId = 충분한_질문을_가진_공통CS_카테고리();

            // when
            List<SelectedInterviewQuestion> selected = interviewQuestionSelectionService.selectQuestions(
                    List.of(categoryId),
                    InterviewLevel.LOW,
                    NO_COVERAGE_REQUIRED
            );

            // then
            Map<InterviewDifficulty, Long> counts = 난이도별_개수(selected);

            assertSoftly(softly -> {
                softly.assertThat(selected).hasSize(QUESTION_COUNT);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.LOW, 0L)).isEqualTo(3);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.MEDIUM, 0L)).isEqualTo(2);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.HIGH, 0L)).isEqualTo(0);
            });
        }

        @Test
        void 중_레벨은_하_1문항과_중_3문항과_상_1문항을_뽑는다() {
            // given
            long categoryId = 충분한_질문을_가진_공통CS_카테고리();

            // when
            List<SelectedInterviewQuestion> selected = interviewQuestionSelectionService.selectQuestions(
                    List.of(categoryId),
                    InterviewLevel.MEDIUM,
                    NO_COVERAGE_REQUIRED
            );

            // then
            Map<InterviewDifficulty, Long> counts = 난이도별_개수(selected);

            assertSoftly(softly -> {
                softly.assertThat(selected).hasSize(QUESTION_COUNT);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.LOW, 0L)).isEqualTo(1);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.MEDIUM, 0L)).isEqualTo(3);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.HIGH, 0L)).isEqualTo(1);
            });
        }

        @Test
        void 상_레벨은_중_2문항과_상_3문항을_뽑는다() {
            // given
            long categoryId = 충분한_질문을_가진_공통CS_카테고리();

            // when
            List<SelectedInterviewQuestion> selected = interviewQuestionSelectionService.selectQuestions(
                    List.of(categoryId),
                    InterviewLevel.HIGH,
                    NO_COVERAGE_REQUIRED
            );

            // then
            Map<InterviewDifficulty, Long> counts = 난이도별_개수(selected);

            assertSoftly(softly -> {
                softly.assertThat(selected).hasSize(QUESTION_COUNT);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.LOW, 0L)).isEqualTo(0);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.MEDIUM, 0L)).isEqualTo(2);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.HIGH, 0L)).isEqualTo(3);
            });
        }

        @Test
        void 출제_순서는_난이도_오름차순이다() {
            // given
            long categoryId = 충분한_질문을_가진_공통CS_카테고리();

            // when
            List<SelectedInterviewQuestion> selected = interviewQuestionSelectionService.selectQuestions(
                    List.of(categoryId),
                    InterviewLevel.MEDIUM,
                    NO_COVERAGE_REQUIRED
            );

            // then
            List<Integer> orders = 난이도_순번(selected);

            assertThat(orders).isEqualTo(orders.stream().sorted().toList());
        }

        @Test
        void 요구한_난이도가_모자라면_인접_난이도로_대체한다() {
            // given
            long categoryId = 카테고리를_저장한다(공통CS_카테고리("운영체제"));
            interviewQuestionRepository.saveAll(질문_여러개(categoryId, InterviewDifficulty.LOW, 3));
            interviewQuestionRepository.saveAll(질문_여러개(categoryId, InterviewDifficulty.MEDIUM, 5));

            // when
            List<SelectedInterviewQuestion> selected = interviewQuestionSelectionService.selectQuestions(
                    List.of(categoryId),
                    InterviewLevel.MEDIUM,
                    NO_COVERAGE_REQUIRED
            );

            // then
            Map<InterviewDifficulty, Long> counts = 난이도별_개수(selected);

            assertSoftly(softly -> {
                softly.assertThat(selected).hasSize(QUESTION_COUNT);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.HIGH, 0L)).isEqualTo(0);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.MEDIUM, 0L)).isEqualTo(4);
                softly.assertThat(counts.getOrDefault(InterviewDifficulty.LOW, 0L)).isEqualTo(1);
            });
        }
    }

    @Nested
    @DisplayName("직무별 모드로 질문을 뽑을 때")
    class SelectForJobSpecific {

        @Test
        void 세_축의_카테고리가_모두_한_문항_이상_나온다() {
            // given
            List<Long> categoryIds = 축별_카테고리를_저장한다();
            categoryIds.forEach(categoryId ->
                    interviewQuestionRepository.saveAll(난이도별_질문(categoryId, 2)));

            // when
            List<SelectedInterviewQuestion> selected = interviewQuestionSelectionService.selectQuestions(
                    categoryIds,
                    InterviewLevel.MEDIUM,
                    COVER_ALL_CATEGORIES
            );

            // then
            assertSoftly(softly -> {
                softly.assertThat(selected).hasSize(QUESTION_COUNT);
                softly.assertThat(카테고리_아이디(selected)).containsExactlyInAnyOrderElementsOf(categoryIds);
            });
        }

        @Test
        void 한_축에_질문이_없으면_예외를_던진다() {
            // given
            List<Long> categoryIds = 축별_카테고리를_저장한다();
            interviewQuestionRepository.saveAll(난이도별_질문(categoryIds.get(0), 3));
            interviewQuestionRepository.saveAll(난이도별_질문(categoryIds.get(1), 3));

            // when & then
            assertThatThrownBy(() -> interviewQuestionSelectionService.selectQuestions(
                    categoryIds,
                    InterviewLevel.MEDIUM,
                    COVER_ALL_CATEGORIES
            ))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }
    }

    @Nested
    @DisplayName("공통 CS 모드로 질문을 뽑을 때")
    class SelectForCommonCs {

        @Test
        void 카테고리가_한쪽으로_쏠리지_않는다() {
            // given
            long firstCategoryId = 카테고리를_저장한다(공통CS_카테고리("운영체제"));
            long secondCategoryId = 카테고리를_저장한다(공통CS_카테고리("네트워크"));
            interviewQuestionRepository.saveAll(난이도별_질문(firstCategoryId, 5));
            interviewQuestionRepository.saveAll(난이도별_질문(secondCategoryId, 5));

            // when
            List<SelectedInterviewQuestion> selected = interviewQuestionSelectionService.selectQuestions(
                    List.of(firstCategoryId, secondCategoryId),
                    InterviewLevel.MEDIUM,
                    NO_COVERAGE_REQUIRED
            );

            // then
            Map<Long, Long> counts = 카테고리별_개수(selected);

            assertSoftly(softly -> {
                softly.assertThat(selected).hasSize(QUESTION_COUNT);
                softly.assertThat(counts.get(firstCategoryId)).isBetween(2L, 3L);
                softly.assertThat(counts.get(secondCategoryId)).isBetween(2L, 3L);
            });
        }
    }

    @Nested
    @DisplayName("질문 풀이 모자랄 때")
    class InsufficientPool {

        @Test
        void 질문이_다섯_개보다_적으면_예외를_던진다() {
            // given
            long categoryId = 카테고리를_저장한다(공통CS_카테고리("운영체제"));
            interviewQuestionRepository.saveAll(질문_여러개(categoryId, InterviewDifficulty.MEDIUM, 4));

            // when & then
            assertThatThrownBy(() -> interviewQuestionSelectionService.selectQuestions(
                    List.of(categoryId),
                    InterviewLevel.MEDIUM,
                    NO_COVERAGE_REQUIRED
            ))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }

        @Test
        void 카테고리가_하나도_없으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewQuestionSelectionService.selectQuestions(
                    List.of(),
                    InterviewLevel.MEDIUM,
                    NO_COVERAGE_REQUIRED
            ))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }
    }

    private long 충분한_질문을_가진_공통CS_카테고리() {
        long categoryId = 카테고리를_저장한다(공통CS_카테고리("운영체제"));
        interviewQuestionRepository.saveAll(난이도별_질문(categoryId, 5));

        return categoryId;
    }

    private long 카테고리를_저장한다(InterviewCategory category) {
        return interviewCategoryRepository.save(category).getId();
    }

    private List<Long> 축별_카테고리를_저장한다() {
        return List.of(
                카테고리를_저장한다(직무별_카테고리("스프링 공통", InterviewAxis.COMMON)),
                카테고리를_저장한다(직무별_카테고리("스프링 프레임워크", InterviewAxis.FRAMEWORK)),
                카테고리를_저장한다(직무별_카테고리("자바 언어", InterviewAxis.LANGUAGE))
        );
    }

    private Map<InterviewDifficulty, Long> 난이도별_개수(List<SelectedInterviewQuestion> selected) {
        return 선별된_질문(selected).stream()
                .collect(Collectors.groupingBy(InterviewQuestion::getDifficulty, Collectors.counting()));
    }

    private Map<Long, Long> 카테고리별_개수(List<SelectedInterviewQuestion> selected) {
        return 선별된_질문(selected).stream()
                .collect(Collectors.groupingBy(InterviewQuestion::getCategoryId, Collectors.counting()));
    }

    private List<Long> 카테고리_아이디(List<SelectedInterviewQuestion> selected) {
        return 선별된_질문(selected).stream()
                .map(InterviewQuestion::getCategoryId)
                .distinct()
                .toList();
    }

    private List<Integer> 난이도_순번(List<SelectedInterviewQuestion> selected) {
        Map<Long, InterviewQuestion> questionById = 선별된_질문(selected).stream()
                .collect(Collectors.toMap(InterviewQuestion::getId, Function.identity()));

        return selected.stream()
                .map(question -> 오름차순_순번(questionById.get(question.questionId()).getDifficulty()))
                .toList();
    }

    private List<InterviewQuestion> 선별된_질문(List<SelectedInterviewQuestion> selected) {
        return interviewQuestionRepository.findAllById(
                selected.stream().map(SelectedInterviewQuestion::questionId).toList()
        );
    }

    private static int 오름차순_순번(InterviewDifficulty difficulty) {
        return switch (difficulty) {
            case LOW -> 0;
            case MEDIUM -> 1;
            case HIGH -> 2;
        };
    }
}
