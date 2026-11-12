package gravit.code.report.fixture;

import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import org.springframework.test.util.ReflectionTestUtils;

public class ReportFixture {

    public static Report 기본_신고(
            long problemId,
            long userId
    ) {
        Report report = Report.of(ReportType.CONTENT_ERROR, "문제 내용이 잘못되었습니다.", problemId, userId);
        ReflectionTestUtils.setField(report, "id", 1L);
        return report;
    }

    public static Report 저장된_신고(
            long id,
            ReportType reportType,
            long problemId,
            long userId
    ) {
        Report report = Report.of(reportType, "신고 내용" + id, problemId, userId);
        ReflectionTestUtils.setField(report, "id", id);
        return report;
    }
}
