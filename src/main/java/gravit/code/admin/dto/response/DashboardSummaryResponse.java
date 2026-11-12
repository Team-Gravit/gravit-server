package gravit.code.admin.dto.response;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record DashboardSummaryResponse(

        long totalUsers,

        long pendingLabelsCount,

        long unresolvedReportsCount
) {
    public static DashboardSummaryResponse of(
            long totalUsers,
            long pendingLabelsCount,
            long unresolvedReportsCount
    ) {
        return DashboardSummaryResponse.builder()
                .totalUsers(totalUsers)
                .pendingLabelsCount(pendingLabelsCount)
                .unresolvedReportsCount(unresolvedReportsCount)
                .build();
    }
}
