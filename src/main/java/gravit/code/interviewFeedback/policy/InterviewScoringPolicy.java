package gravit.code.interviewFeedback.policy;

import gravit.code.interviewFeedback.dto.internal.InterviewConceptJudgmentDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import gravit.code.interviewFeedback.dto.internal.InterviewScoreDto;
import gravit.code.interviewFeedback.dto.internal.InterviewSessionScoreDto;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class InterviewScoringPolicy {

    private static final BigDecimal ACCURACY_MAX_SCORE = BigDecimal.valueOf(14);
    private static final BigDecimal COVERAGE_MAX_SCORE = BigDecimal.valueOf(8);
    private static final int SUPPLEMENTARY_BONUS_PER_CONCEPT = 1;
    private static final int SUPPLEMENTARY_BONUS_MAX = 2;
    private static final BigDecimal MULTIPLIER_NO_WRONG = new BigDecimal("1.0");
    private static final BigDecimal MULTIPLIER_ONE_WRONG = new BigDecimal("0.5");
    private static final BigDecimal MULTIPLIER_MANY_WRONG = new BigDecimal("0.2");
    private static final int ONE_WRONG_CONCEPT = 1;
    private static final int CLARITY_MAX_SCORE = 3;
    private static final int CLARITY_ONE_IRRELEVANT_SCORE = 2;
    private static final int CLARITY_MIN_SCORE = 1;
    private static final int ONE_IRRELEVANT_STATEMENT = 1;
    private static final int BASE_RATIO_SCALE = 3;
    private static final int DIVISION_SCALE = 10;
    private static final int SCORE_SCALE = 0;

    public InterviewScoreDto score(
            InterviewGradingJudgmentDto judgment,
            List<InterviewQuestionConcept> concepts
    ) {
        Set<String> coveredConceptNames = judgment.conceptJudgments().stream()
                .filter(InterviewConceptJudgmentDto::covered)
                .map(InterviewConceptJudgmentDto::name)
                .collect(Collectors.toSet());

        BigDecimal baseRatio = calculateBaseRatio(concepts, coveredConceptNames);
        BigDecimal multiplier = calculateMultiplier(judgment.wrongConcepts().size());
        int accuracyScore = calculateAccuracyScore(baseRatio, multiplier);

        int structureScore = judgment.structureLevel().getScore();
        int clarityScore = calculateClarityScore(judgment.offTopic(), judgment.irrelevantStatementCount());

        return InterviewScoreDto.of(
                accuracyScore,
                structureScore,
                clarityScore,
                baseRatio,
                multiplier,
                judgment.irrelevantStatementCount(),
                judgment.improvementSuggestion()
        );
    }

    public InterviewSessionScoreDto aggregate(List<InterviewScoreDto> scores) {
        int accuracyScore = scores.stream()
                .mapToInt(InterviewScoreDto::accuracyScore)
                .sum();

        int deliveryScore = scores.stream()
                .mapToInt(InterviewScoreDto::getDeliveryScore)
                .sum();

        return InterviewSessionScoreDto.of(accuracyScore, deliveryScore);
    }

    private BigDecimal calculateBaseRatio(
            List<InterviewQuestionConcept> concepts,
            Set<String> coveredConceptNames
    ) {
        BigDecimal coverage = calculateCoverage(concepts, coveredConceptNames);
        BigDecimal supplementaryBonus = calculateSupplementaryBonus(concepts, coveredConceptNames);

        return coverage.add(supplementaryBonus)
                .min(COVERAGE_MAX_SCORE)
                .divide(COVERAGE_MAX_SCORE, BASE_RATIO_SCALE, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateCoverage(
            List<InterviewQuestionConcept> concepts,
            Set<String> coveredConceptNames
    ) {
        long essentialCount = countByType(concepts, InterviewConceptType.ESSENTIAL);
        if (essentialCount == 0) {
            return COVERAGE_MAX_SCORE;
        }

        long coveredEssentialCount = countCoveredByType(concepts, coveredConceptNames, InterviewConceptType.ESSENTIAL);

        return COVERAGE_MAX_SCORE
                .multiply(BigDecimal.valueOf(coveredEssentialCount))
                .divide(BigDecimal.valueOf(essentialCount), DIVISION_SCALE, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateSupplementaryBonus(
            List<InterviewQuestionConcept> concepts,
            Set<String> coveredConceptNames
    ) {
        long coveredSupplementaryCount = countCoveredByType(concepts, coveredConceptNames, InterviewConceptType.SUPPLEMENTARY);
        long bonus = Math.min(coveredSupplementaryCount * SUPPLEMENTARY_BONUS_PER_CONCEPT, SUPPLEMENTARY_BONUS_MAX);

        return BigDecimal.valueOf(bonus);
    }

    private long countByType(
            List<InterviewQuestionConcept> concepts,
            InterviewConceptType type
    ) {
        return concepts.stream()
                .filter(concept -> concept.getType() == type)
                .count();
    }

    private long countCoveredByType(
            List<InterviewQuestionConcept> concepts,
            Set<String> coveredConceptNames,
            InterviewConceptType type
    ) {
        return concepts.stream()
                .filter(concept -> concept.getType() == type)
                .filter(concept -> coveredConceptNames.contains(concept.getName()))
                .count();
    }

    private BigDecimal calculateMultiplier(int wrongConceptCount) {
        if (wrongConceptCount == 0) {
            return MULTIPLIER_NO_WRONG;
        }
        if (wrongConceptCount == ONE_WRONG_CONCEPT) {
            return MULTIPLIER_ONE_WRONG;
        }

        return MULTIPLIER_MANY_WRONG;
    }

    private int calculateAccuracyScore(
            BigDecimal baseRatio,
            BigDecimal multiplier
    ) {
        return baseRatio.multiply(multiplier)
                .multiply(ACCURACY_MAX_SCORE)
                .setScale(SCORE_SCALE, RoundingMode.HALF_UP)
                .intValue();
    }

    private int calculateClarityScore(
            boolean offTopic,
            int irrelevantStatementCount
    ) {
        if (offTopic) {
            return CLARITY_MIN_SCORE;
        }
        if (irrelevantStatementCount == 0) {
            return CLARITY_MAX_SCORE;
        }
        if (irrelevantStatementCount == ONE_IRRELEVANT_STATEMENT) {
            return CLARITY_ONE_IRRELEVANT_SCORE;
        }

        return CLARITY_MIN_SCORE;
    }
}
