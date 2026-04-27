package gravit.code.admin.dto.response;

public record DashboardSummaryResponse(
        int totalUsers,
        int pendingLabelsCount,
        int unresolvedReportsCount
) {
}
