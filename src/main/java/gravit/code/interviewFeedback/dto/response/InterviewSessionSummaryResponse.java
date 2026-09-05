package gravit.code.interviewFeedback.dto.response;

import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.response.InterviewRecentSessionResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionSummaryResponse(

        @Schema(
                description = "세션 ID",
                example = "12",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "시도 차수",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sequence,

        @Schema(
                description = "세션 시작 시각",
                example = "2026-09-04T10:15:30",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        LocalDateTime startedAt,

        @Schema(
                description = "세션 총점 (정확도 + 전달력)",
                example = "78",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int score,

        @Schema(
                description = "세션 만점",
                example = "100",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int maxScore,

        @Schema(
                description = "세션 정확도 점수",
                example = "54",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int accuracyScore,

        @Schema(
                description = "세션 정확도 만점",
                example = "70",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int accuracyMaxScore,

        @Schema(
                description = "세션 전달력 점수 (구조성 + 명료성)",
                example = "24",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int deliveryScore,

        @Schema(
                description = "세션 전달력 만점",
                example = "30",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int deliveryMaxScore,

        @Schema(
                description = "전체 사용자 완료 세션의 평균 정확도 점수 (반올림 정수)",
                example = "49",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int averageAccuracyScore,

        @Schema(
                description = "전체 사용자 완료 세션의 평균 전달력 점수 (반올림 정수)",
                example = "21",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int averageDeliveryScore,

        @Schema(
                description = "이 세션을 포함한 최근 완료 세션 5개의 추이 (오래된 순)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewRecentSessionResponse> recentSessions,

        @Schema(
                description = "문항별 점수 (문항 순서대로)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewAnswerScoreResponse> answers,

        @Schema(
                description = "약점 분야 (문항 획득 점수가 문항 만점의 절반 이하인 문항의 유닛, 중복 제거)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewWeakTopicResponse> weakTopics
) {
    public static InterviewSessionSummaryResponse of(
            InterviewSession session,
            int averageAccuracyScore,
            int averageDeliveryScore,
            List<InterviewRecentSessionResponse> recentSessions,
            List<InterviewAnswerScoreResponse> answers,
            List<InterviewWeakTopicResponse> weakTopics
    ) {
        return InterviewSessionSummaryResponse.builder()
                .sessionId(session.getId())
                .sequence(session.getAttemptCount())
                .startedAt(session.getStartedAt())
                .score(session.getScore())
                .maxScore(session.getMaxScore())
                .accuracyScore(session.getAccuracyScore())
                .accuracyMaxScore(session.getAccuracyMaxScore())
                .deliveryScore(session.getDeliveryScore())
                .deliveryMaxScore(session.getDeliveryMaxScore())
                .averageAccuracyScore(averageAccuracyScore)
                .averageDeliveryScore(averageDeliveryScore)
                .recentSessions(recentSessions)
                .answers(answers)
                .weakTopics(weakTopics)
                .build();
    }
}
