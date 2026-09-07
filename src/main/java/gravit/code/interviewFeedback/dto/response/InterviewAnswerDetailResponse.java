package gravit.code.interviewFeedback.dto.response;

import gravit.code.interview.domain.InterviewSession;
import gravit.code.interviewFeedback.dto.internal.InterviewAnswerDetailDto;
import gravit.code.interviewQuestion.dto.response.InterviewConceptResponse;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewAnswerDetailResponse(

        @Schema(
                description = "문항 순서 (1~5)",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "문항 주제",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewTopicResponse topic,

        @Schema(
                description = "질문 내용",
                example = "퀵 정렬의 동작 방식과 시간복잡도를 설명해주세요.",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String questionContent,

        @Schema(
                description = "사용자 답변. 무응답 문항은 null",
                example = "피벗을 기준으로 분할하며 정렬합니다. 평균 O(n log n)입니다.",
                nullable = true
        )
        String answerContent,

        @Schema(
                description = "음성 세션의 음성 키. 텍스트 세션이거나 무응답이면 null",
                nullable = true
        )
        String audioKey,

        @Schema(
                description = "모범답안 (Markdown)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String modelAnswer,

        @Schema(
                description = "핵심 개념 목록 (개념별 전달 여부는 포함하지 않음)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewConceptResponse> concepts,

        @Schema(
                description = "개선 제안 (Markdown). 개선할 점이 없으면 격려 한 문장, 있으면 최대 2개 항목. 무응답 문항은 null",
                example = "**최악 시간복잡도 언급**\n\n최악의 경우 O(n^2)가 되는 조건을 함께 언급하면 좋습니다.",
                nullable = true
        )
        String improvementSuggestion,

        @Schema(
                description = "문항 정확도 점수",
                example = "11",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int accuracyScore,

        @Schema(
                description = "문항 정확도 만점",
                example = "14",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int accuracyMaxScore,

        @Schema(
                description = "문항 구조성 점수",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int structureScore,

        @Schema(
                description = "문항 구조성 만점",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int structureMaxScore,

        @Schema(
                description = "문항 명료성 점수",
                example = "2",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int clarityScore,

        @Schema(
                description = "문항 명료성 만점",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int clarityMaxScore
) {
    public static InterviewAnswerDetailResponse of(
            InterviewAnswerDetailDto detail,
            List<InterviewConceptResponse> concepts,
            InterviewSession session
    ) {
        return InterviewAnswerDetailResponse.builder()
                .displayOrder(detail.displayOrder())
                .topic(InterviewTopicResponse.from(detail.topic()))
                .questionContent(detail.questionContent())
                .answerContent(detail.answerContent())
                .audioKey(detail.audioKey())
                .modelAnswer(detail.modelAnswer())
                .concepts(concepts)
                .improvementSuggestion(detail.improvementSuggestion())
                .accuracyScore(detail.accuracyScore())
                .accuracyMaxScore(session.getQuestionAccuracyMaxScore())
                .structureScore(detail.structureScore())
                .structureMaxScore(session.getQuestionStructureMaxScore())
                .clarityScore(detail.clarityScore())
                .clarityMaxScore(session.getQuestionClarityMaxScore())
                .build();
    }
}
