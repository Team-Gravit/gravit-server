package gravit.code.report.fixture;

import gravit.code.report.domain.UserReport;
import gravit.code.report.domain.UserReportType;

public class UserReportFixture {

    private static final String REPORTED_NICKNAME = "신고된닉";
    private static final String CONTENT = "닉네임이 부적절해요.";

    public static UserReport 미처리_닉네임_신고(
            long reporterId,
            long targetUserId
    ) {
        return UserReport.create(reporterId, targetUserId, UserReportType.INAPPROPRIATE_NICKNAME, REPORTED_NICKNAME, CONTENT);
    }

    public static UserReport 미처리_기타_신고(
            long reporterId,
            long targetUserId
    ) {
        return UserReport.create(reporterId, targetUserId, UserReportType.OTHER, REPORTED_NICKNAME, CONTENT);
    }

    public static UserReport 처리된_닉네임_신고(
            long reporterId,
            long targetUserId
    ) {
        UserReport userReport = 미처리_닉네임_신고(reporterId, targetUserId);
        userReport.changeResolved(true);
        return userReport;
    }
}
