package gravit.code.interviewFeedback.policy;

import gravit.code.interviewFeedback.domain.InterviewStructureLevel;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import gravit.code.interviewFeedback.dto.internal.InterviewScoreDto;
import gravit.code.interviewFeedback.dto.internal.InterviewSessionScoreDto;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;

import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.개념;
import static gravit.code.interviewFeedback.fixture.InterviewGradingJudgmentFixture.미전달;
import static gravit.code.interviewFeedback.fixture.InterviewGradingJudgmentFixture.전달;
import static gravit.code.interviewFeedback.fixture.InterviewGradingJudgmentFixture.전달_판정;
import static gravit.code.interviewFeedback.fixture.InterviewGradingJudgmentFixture.전달력_판정;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewScoringPolicyIntegrationTest {

    private static final long QUESTION_ID = 1L;
    private static final String ESSENTIAL_A = "필수 개념 A";
    private static final String ESSENTIAL_B = "필수 개념 B";
    private static final String ESSENTIAL_C = "필수 개념 C";
    private static final String SUPPLEMENTARY_A = "보조 개념 A";
    private static final String SUPPLEMENTARY_B = "보조 개념 B";
    private static final String SUPPLEMENTARY_C = "보조 개념 C";
    private static final String UNKNOWN_CONCEPT = "목록에 없는 개념";
    private static final String WRONG_CONCEPT = "잘못 말한 구간";

    @Autowired
    private InterviewScoringPolicy interviewScoringPolicy;

    private List<InterviewQuestionConcept> 필수_2개() {
        return List.of(
                개념(QUESTION_ID, ESSENTIAL_A, InterviewConceptType.ESSENTIAL, 1),
                개념(QUESTION_ID, ESSENTIAL_B, InterviewConceptType.ESSENTIAL, 2)
        );
    }

    private List<InterviewQuestionConcept> 필수_3개() {
        return List.of(
                개념(QUESTION_ID, ESSENTIAL_A, InterviewConceptType.ESSENTIAL, 1),
                개념(QUESTION_ID, ESSENTIAL_B, InterviewConceptType.ESSENTIAL, 2),
                개념(QUESTION_ID, ESSENTIAL_C, InterviewConceptType.ESSENTIAL, 3)
        );
    }

    private List<InterviewQuestionConcept> 필수_2개_보조_2개() {
        return List.of(
                개념(QUESTION_ID, ESSENTIAL_A, InterviewConceptType.ESSENTIAL, 1),
                개념(QUESTION_ID, ESSENTIAL_B, InterviewConceptType.ESSENTIAL, 2),
                개념(QUESTION_ID, SUPPLEMENTARY_A, InterviewConceptType.SUPPLEMENTARY, 3),
                개념(QUESTION_ID, SUPPLEMENTARY_B, InterviewConceptType.SUPPLEMENTARY, 4)
        );
    }

    private List<InterviewQuestionConcept> 필수_3개_보조_3개() {
        return List.of(
                개념(QUESTION_ID, ESSENTIAL_A, InterviewConceptType.ESSENTIAL, 1),
                개념(QUESTION_ID, ESSENTIAL_B, InterviewConceptType.ESSENTIAL, 2),
                개념(QUESTION_ID, ESSENTIAL_C, InterviewConceptType.ESSENTIAL, 3),
                개념(QUESTION_ID, SUPPLEMENTARY_A, InterviewConceptType.SUPPLEMENTARY, 4),
                개념(QUESTION_ID, SUPPLEMENTARY_B, InterviewConceptType.SUPPLEMENTARY, 5),
                개념(QUESTION_ID, SUPPLEMENTARY_C, InterviewConceptType.SUPPLEMENTARY, 6)
        );
    }

    @Nested
    @DisplayName("정확도를 계산할 때")
    class Accuracy {

        @Test
        void 필수_3개_중_2개를_전달하면_기본_비율은_0점667이고_정확도는_9점이다() {
            // given
            InterviewGradingJudgmentDto judgment = 전달_판정(
                    List.of(전달(ESSENTIAL_A), 전달(ESSENTIAL_B), 미전달(ESSENTIAL_C)),
                    List.of()
            );

            // when
            InterviewScoreDto score = interviewScoringPolicy.score(judgment, 필수_3개());

            // then
            assertSoftly(softly -> {
                softly.assertThat(score.accuracyBaseRatio()).isEqualByComparingTo(new BigDecimal("0.667"));
                softly.assertThat(score.accuracyMultiplier()).isEqualByComparingTo(new BigDecimal("1.0"));
                softly.assertThat(score.accuracyScore()).isEqualTo(9);
            });
        }

        @Test
        void 보조_가산은_최대_2점이고_필수를_모두_전달하면_기본_비율은_1이다() {
            // given
            InterviewGradingJudgmentDto judgment = 전달_판정(
                    List.of(
                            전달(ESSENTIAL_A), 전달(ESSENTIAL_B), 전달(ESSENTIAL_C),
                            전달(SUPPLEMENTARY_A), 전달(SUPPLEMENTARY_B), 전달(SUPPLEMENTARY_C)
                    ),
                    List.of()
            );

            // when
            InterviewScoreDto score = interviewScoringPolicy.score(judgment, 필수_3개_보조_3개());

            // then
            assertSoftly(softly -> {
                softly.assertThat(score.accuracyBaseRatio()).isEqualByComparingTo(new BigDecimal("1.000"));
                softly.assertThat(score.accuracyScore()).isEqualTo(14);
            });
        }

        @Test
        void 필수_누락은_보조_가산으로_메울_수_없다() {
            // given - 필수 1/2 (커버리지 4) + 보조 2 (가산 2) = 6/8
            InterviewGradingJudgmentDto judgment = 전달_판정(
                    List.of(전달(ESSENTIAL_A), 미전달(ESSENTIAL_B), 전달(SUPPLEMENTARY_A), 전달(SUPPLEMENTARY_B)),
                    List.of()
            );

            // when
            InterviewScoreDto score = interviewScoringPolicy.score(judgment, 필수_2개_보조_2개());

            // then - 0.750 x 1.0 x 14 = 10.5 → 11
            assertSoftly(softly -> {
                softly.assertThat(score.accuracyBaseRatio()).isEqualByComparingTo(new BigDecimal("0.750"));
                softly.assertThat(score.accuracyScore()).isEqualTo(11);
            });
        }

        @Test
        void 잘못된_개념_수에_따라_감점_배율이_1점0_0점5_0점2로_적용된다() {
            // given
            List<InterviewQuestionConcept> concepts = 필수_2개();
            List<String> expectedMultipliers = List.of("1.0", "0.5", "0.2", "0.2");
            List<Integer> expectedScores = List.of(14, 7, 3, 3);

            // when & then
            assertSoftly(softly -> {
                for (int wrongCount = 0; wrongCount < expectedMultipliers.size(); wrongCount++) {
                    InterviewGradingJudgmentDto judgment = 전달_판정(
                            List.of(전달(ESSENTIAL_A), 전달(ESSENTIAL_B)),
                            Collections.nCopies(wrongCount, WRONG_CONCEPT)
                    );

                    InterviewScoreDto score = interviewScoringPolicy.score(judgment, concepts);

                    softly.assertThat(score.accuracyMultiplier())
                            .as("잘못된 개념 %d개 배율", wrongCount)
                            .isEqualByComparingTo(new BigDecimal(expectedMultipliers.get(wrongCount)));
                    softly.assertThat(score.accuracyScore())
                            .as("잘못된 개념 %d개 정확도", wrongCount)
                            .isEqualTo(expectedScores.get(wrongCount));
                }
            });
        }

        @Test
        void 개념명이_목록과_다르면_전달하지_않은_것으로_센다() {
            // given
            InterviewGradingJudgmentDto judgment = 전달_판정(
                    List.of(전달(UNKNOWN_CONCEPT), 전달(ESSENTIAL_B)),
                    List.of()
            );

            // when
            InterviewScoreDto score = interviewScoringPolicy.score(judgment, 필수_2개());

            // then
            assertSoftly(softly -> {
                softly.assertThat(score.accuracyBaseRatio()).isEqualByComparingTo(new BigDecimal("0.500"));
                softly.assertThat(score.accuracyScore()).isEqualTo(7);
            });
        }

        @Test
        void 필수_개념이_없으면_커버리지를_만점으로_본다() {
            // given
            List<InterviewQuestionConcept> supplementaryOnly = List.of(
                    개념(QUESTION_ID, SUPPLEMENTARY_A, InterviewConceptType.SUPPLEMENTARY, 1)
            );
            InterviewGradingJudgmentDto judgment = 전달_판정(List.of(미전달(SUPPLEMENTARY_A)), List.of());

            // when
            InterviewScoreDto score = interviewScoringPolicy.score(judgment, supplementaryOnly);

            // then
            assertSoftly(softly -> {
                softly.assertThat(score.accuracyBaseRatio()).isEqualByComparingTo(new BigDecimal("1.000"));
                softly.assertThat(score.accuracyScore()).isEqualTo(14);
            });
        }
    }

    @Nested
    @DisplayName("전달력을 계산할 때")
    class Delivery {

        @Test
        void 구조성은_판정_단계에_따라_3점_2점_1점이다() {
            // given
            List<InterviewQuestionConcept> concepts = 필수_2개();

            // when & then
            assertSoftly(softly -> {
                for (InterviewStructureLevel level : InterviewStructureLevel.values()) {
                    InterviewGradingJudgmentDto judgment = 전달력_판정(
                            List.of(전달(ESSENTIAL_A), 전달(ESSENTIAL_B)), level, false, 0
                    );

                    InterviewScoreDto score = interviewScoringPolicy.score(judgment, concepts);

                    softly.assertThat(score.structureScore()).as(level.name()).isEqualTo(level.getScore());
                }
            });
        }

        @Test
        void 명료성은_관계없는_발화_수에_따라_3점_2점_1점이다() {
            // given
            List<InterviewQuestionConcept> concepts = 필수_2개();
            List<Integer> irrelevantCounts = List.of(0, 1, 2, 5);
            List<Integer> expectedClarity = List.of(3, 2, 1, 1);

            // when & then
            assertSoftly(softly -> {
                for (int index = 0; index < irrelevantCounts.size(); index++) {
                    int irrelevantCount = irrelevantCounts.get(index);
                    InterviewGradingJudgmentDto judgment = 전달력_판정(
                            List.of(전달(ESSENTIAL_A), 전달(ESSENTIAL_B)),
                            InterviewStructureLevel.CONCLUSION_FIRST,
                            false,
                            irrelevantCount
                    );

                    InterviewScoreDto score = interviewScoringPolicy.score(judgment, concepts);

                    softly.assertThat(score.clarityScore())
                            .as("관계없는 발화 %d개", irrelevantCount)
                            .isEqualTo(expectedClarity.get(index));
                    softly.assertThat(score.irrelevantStatementCount()).isEqualTo(irrelevantCount);
                }
            });
        }

        @Test
        void 질문을_이탈하면_관계없는_발화가_없어도_명료성은_1점이다() {
            // given
            InterviewGradingJudgmentDto judgment = 전달력_판정(
                    List.of(전달(ESSENTIAL_A), 전달(ESSENTIAL_B)),
                    InterviewStructureLevel.CONCLUSION_FIRST,
                    true,
                    0
            );

            // when
            InterviewScoreDto score = interviewScoringPolicy.score(judgment, 필수_2개());

            // then
            assertThat(score.clarityScore()).isEqualTo(1);
        }
    }

    @Nested
    @DisplayName("무응답이면")
    class NoResponse {

        @Test
        void 세_점수는_0이고_나머지는_비어_있다() {
            // when
            InterviewScoreDto score = InterviewScoreDto.noResponse();

            // then
            assertSoftly(softly -> {
                softly.assertThat(score.accuracyScore()).isZero();
                softly.assertThat(score.structureScore()).isZero();
                softly.assertThat(score.clarityScore()).isZero();
                softly.assertThat(score.accuracyBaseRatio()).isNull();
                softly.assertThat(score.accuracyMultiplier()).isNull();
                softly.assertThat(score.irrelevantStatementCount()).isNull();
                softly.assertThat(score.improvementSuggestion()).isNull();
                softly.assertThat(score.getDeliveryScore()).isZero();
            });
        }
    }

    @Nested
    @DisplayName("세션 점수를 합산할 때")
    class Aggregate {

        @Test
        void 정확도_합과_전달력_합을_돌려준다() {
            // given
            List<InterviewScoreDto> scores = List.of(
                    InterviewScoreDto.of(14, 3, 3, new BigDecimal("1.000"), new BigDecimal("1.0"), 0, "제안"),
                    InterviewScoreDto.of(7, 2, 1, new BigDecimal("0.500"), new BigDecimal("1.0"), 2, "제안"),
                    InterviewScoreDto.noResponse()
            );

            // when
            InterviewSessionScoreDto sessionScore = interviewScoringPolicy.aggregate(scores);

            // then
            assertSoftly(softly -> {
                softly.assertThat(sessionScore.accuracyScore()).isEqualTo(21);
                softly.assertThat(sessionScore.deliveryScore()).isEqualTo(9);
            });
        }
    }
}
