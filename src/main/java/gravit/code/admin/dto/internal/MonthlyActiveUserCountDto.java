package gravit.code.admin.dto.internal;

public record MonthlyActiveUserCountDto(
        Integer year,
        Integer month,
        Long activeUserCount
) {
}
