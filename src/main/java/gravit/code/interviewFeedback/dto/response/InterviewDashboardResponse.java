package gravit.code.interviewFeedback.dto.response;

import gravit.code.interview.dto.response.InterviewScoreTrendResponse;
import gravit.code.interview.dto.response.InterviewSessionHistoryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewDashboardResponse(

        @Schema(
                description = "완료 세션 수",
                example = "7",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long completedSessionCount,

        @Schema(
                description = "최근 완료 세션 5개의 총점 평균 (반올림 정수). 완료 세션이 없으면 0",
                example = "71",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int recentAverageScore,

        @Schema(
                description = "약점 주제 하위 3개 (정확도율 오름차순)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewTopicAccuracyResponse> weakestTopics,

        @Schema(
                description = "최근 완료 세션 3개 (최신순)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewSessionHistoryResponse> recentSessions,

        @Schema(
                description = "최근 완료 세션 5개의 점수 추이 (오래된 순)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewScoreTrendResponse> scoreTrends
) {
    public static InterviewDashboardResponse of(
            long completedSessionCount,
            int recentAverageScore,
            List<InterviewTopicAccuracyResponse> weakestTopics,
            List<InterviewSessionHistoryResponse> recentSessions,
            List<InterviewScoreTrendResponse> scoreTrends
    ) {
        return InterviewDashboardResponse.builder()
                .completedSessionCount(completedSessionCount)
                .recentAverageScore(recentAverageScore)
                .weakestTopics(weakestTopics)
                .recentSessions(recentSessions)
                .scoreTrends(scoreTrends)
                .build();
    }
}
