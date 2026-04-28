package gravit.code.admin.dto.response;

import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record DashboardSummaryResponse(
        long totalUsers,
        long pendingLabelsCount,
        long unresolvedReportsCount
) {
    public static DashboardSummaryResponse create(
            long totalUsers,
            long pendingLabelsCount,
            long unresolvedReportsCount
    ){
        return DashboardSummaryResponse.builder()
                .totalUsers(totalUsers)
                .pendingLabelsCount(pendingLabelsCount)
                .unresolvedReportsCount(unresolvedReportsCount)
                .build();
    }
}
