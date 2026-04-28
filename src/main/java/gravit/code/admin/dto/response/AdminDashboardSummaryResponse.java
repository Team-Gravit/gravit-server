package gravit.code.admin.dto.response;

import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record AdminDashboardSummaryResponse(
        long totalUsers,
        long pendingLabelsCount,
        long unresolvedReportsCount
) {
    public static AdminDashboardSummaryResponse create(
            long totalUsers,
            long pendingLabelsCount,
            long unresolvedReportsCount
    ){
        return AdminDashboardSummaryResponse.builder()
                .totalUsers(totalUsers)
                .pendingLabelsCount(pendingLabelsCount)
                .unresolvedReportsCount(unresolvedReportsCount)
                .build();
    }
}
