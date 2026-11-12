package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionHistoryResponse(

        @Schema(
                description = "세션 ID",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "시도 차수 (사용자의 세션 생성 순서)",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sequence,

        @Schema(
                description = "면접 모드",
                example = "COMMON_CS",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewMode mode,

        @Schema(
                description = "직군 모드의 스택. 공통 CS 모드면 null",
                nullable = true
        )
        InterviewStackResponse stack,

        @Schema(
                description = "세션 주제 목록 (공통 CS 모드는 선택한 주제, 직군 모드는 스택 구성 태그 3개)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewTopicResponse> topics,

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
                description = "세션 만점 (생성 시 스냅샷)",
                example = "100",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int maxScore
) {
    public static InterviewSessionHistoryResponse of(
            InterviewSession session,
            List<InterviewTopic> topics
    ) {
        return InterviewSessionHistoryResponse.builder()
                .sessionId(session.getId())
                .sequence(session.getAttemptCount())
                .mode(session.getMode())
                .stack(session.getStack() == null ? null : InterviewStackResponse.from(session.getStack()))
                .topics(topics.stream().map(InterviewTopicResponse::from).toList())
                .startedAt(session.getStartedAt())
                .score(session.getScore())
                .maxScore(session.getMaxScore())
                .build();
    }
}
