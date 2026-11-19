package gravit.code.metricReport.support;

import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.DiscordActionRowDto;
import gravit.code.metricReport.dto.internal.DiscordButtonDto;
import gravit.code.metricReport.dto.internal.DiscordEmbedDto;
import gravit.code.metricReport.dto.internal.DiscordEmbedFieldDto;
import gravit.code.metricReport.dto.internal.DiscordEmbedFooterDto;
import gravit.code.metricReport.dto.internal.DiscordMessageDto;
import gravit.code.metricReport.dto.internal.InquiryItemDto;
import gravit.code.metricReport.dto.internal.InterviewMetricDto;
import gravit.code.metricReport.dto.internal.LessonMetricDto;
import gravit.code.metricReport.dto.internal.MetricRangeDto;
import gravit.code.metricReport.dto.internal.ReportInquiryMetricDto;
import gravit.code.metricReport.dto.internal.ReportItemDto;
import gravit.code.metricReport.dto.internal.RetentionDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.dto.internal.ServiceMetricSnapshotDto;
import gravit.code.metricReport.dto.internal.TypeCountDto;
import gravit.code.metricReport.dto.internal.UserMetricDto;
import org.springframework.stereotype.Component;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class DiscordReportMessageFactory {

    public static final String SHARE_CUSTOM_ID_PREFIX = "metric-share:";

    private static final int FLAG_EPHEMERAL = 1 << 6;
    private static final int FLAG_SUPPRESS_NOTIFICATIONS = 1 << 12;
    private static final int EMBED_COLOR = 0x5865F2;
    private static final int FIELD_VALUE_MAX_LENGTH = 1024;
    private static final int INQUIRY_TITLE_MAX_LENGTH = 50;
    private static final String TRUNCATION_SUFFIX = "…";
    private static final String LINE_SEPARATOR = "\n";
    private static final double UNCHANGED_THRESHOLD = 0.05;

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter SHORT_DATE_FORMATTER = DateTimeFormatter.ofPattern("MM-dd");
    private static final DateTimeFormatter MONTH_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM");
    private static final DateTimeFormatter GENERATED_AT_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private static final Map<String, String> REPORT_TYPE_LABELS = Map.of(
            "TYPO_ERROR", "오타",
            "CONTENT_ERROR", "내용 오류",
            "ANSWER_ERROR", "정답 오류",
            "OTHER_ERROR", "기타"
    );

    private static final Map<String, String> INQUIRY_TYPE_LABELS = Map.of(
            "BUG_REPORT", "버그",
            "CONTENT_ERROR", "콘텐츠 오류",
            "FEATURE_SUGGESTION", "기능 제안",
            "OTHER", "기타"
    );

    public DiscordMessageDto createScheduledReport(ServiceMetricReportDto report) {
        String title = switch (report.period()) {
            case YESTERDAY -> "📊 일간 리포트 · " + formatRange(report.current().range());
            case LAST_WEEK -> "📊 주간 리포트 · " + formatRange(report.current().range());
            default -> buildStatusTitle(report);
        };

        return DiscordMessageDto.of(
                null,
                List.of(buildEmbed(title, report)),
                null,
                FLAG_SUPPRESS_NOTIFICATIONS
        );
    }

    private String formatRange(MetricRangeDto range) {
        if (range.isSingleDay()) {
            return range.startDate().format(DATE_FORMATTER);
        }

        return range.startDate().format(SHORT_DATE_FORMATTER) + " ~ " + range.endDate().format(SHORT_DATE_FORMATTER);
    }

    private String buildStatusTitle(ServiceMetricReportDto report) {
        return "📊 서비스 현황 · " + report.period().getLabel() + " (" + formatRange(report.current().range()) + ")";
    }

    private DiscordEmbedDto buildEmbed(
            String title,
            ServiceMetricReportDto report
    ) {
        ServiceMetricSnapshotDto current = report.current();
        ServiceMetricSnapshotDto previous = report.previous();

        List<DiscordEmbedFieldDto> fields = List.of(
                DiscordEmbedFieldDto.of("👥 사용자", formatUsers(current, previous)),
                DiscordEmbedFieldDto.of("🔁 재방문", formatRetention(current.users(), previous == null ? null : previous.users())),
                DiscordEmbedFieldDto.of("📚 레슨", formatLessons(current.lessons(), previous == null ? null : previous.lessons())),
                DiscordEmbedFieldDto.of("🎤 면접", formatInterviews(current.interviews(), previous == null ? null : previous.interviews())),
                DiscordEmbedFieldDto.of("🚨 신고", formatReports(report.reportsAndInquiries())),
                DiscordEmbedFieldDto.of("💬 문의", formatInquiries(report.reportsAndInquiries()))
        );

        return DiscordEmbedDto.of(
                title,
                buildDescription(report),
                EMBED_COLOR,
                fields,
                DiscordEmbedFooterDto.from(buildFooter(report))
        );
    }

    private String formatUsers(
            ServiceMetricSnapshotDto current,
            ServiceMetricSnapshotDto previous
    ) {
        UserMetricDto users = current.users();
        UserMetricDto previousUsers = previous == null ? null : previous.users();
        boolean isSingleDay = current.range().isSingleDay();

        List<String> lines = new ArrayList<>();
        lines.add("총 가입자 " + formatNumber(users.totalUsers()) + "명");
        lines.add("신규 가입 " + formatCount(users.newSignups(), previousUsers == null ? null : previousUsers.newSignups(), "명"));

        if (isSingleDay) {
            lines.add("DAU " + formatCount(users.activeUsers(), previousUsers == null ? null : previousUsers.activeUsers(), "명"));
        } else {
            lines.add("평균 DAU " + formatAverage(users.averageDailyActiveUsers(), previousUsers == null ? null : previousUsers.averageDailyActiveUsers(), "명"));
            lines.add("기간 활성 " + formatCount(users.activeUsers(), previousUsers == null ? null : previousUsers.activeUsers(), "명"));
        }

        String mauStatus = users.mauInProgress() ? ", 진행 중" : "";
        lines.add("MAU (" + users.mauMonth().format(MONTH_FORMATTER) + mauStatus + ") " + formatNumber(users.monthlyActiveUsers()) + "명");

        return String.join(LINE_SEPARATOR, lines);
    }

    private String formatNumber(long value) {
        return String.format("%,d", value);
    }

    private String formatCount(
            long current,
            Long previous,
            String unit
    ) {
        String value = formatNumber(current) + unit;
        if (previous == null) {
            return value;
        }

        long diff = current - previous;
        if (diff == 0) {
            return value + " (→)";
        }

        String arrow = diff > 0 ? "▲" : "▼";
        if (previous == 0) {
            return value + " (" + arrow + formatNumber(Math.abs(diff)) + ")";
        }

        double changeRate = (double) diff / previous * 100;
        return value + " (" + arrow + formatNumber(Math.abs(diff)) + ", " + String.format("%+.1f%%", changeRate) + ")";
    }

    private String formatAverage(
            double current,
            Double previous,
            String unit
    ) {
        String value = String.format("%,.1f", current) + unit;
        if (previous == null) {
            return value;
        }

        double diff = current - previous;
        if (Math.abs(diff) < UNCHANGED_THRESHOLD) {
            return value + " (→)";
        }

        String arrow = diff > 0 ? "▲" : "▼";
        return value + " (" + arrow + String.format("%.1f", Math.abs(diff)) + ")";
    }

    private String formatRetention(
            UserMetricDto current,
            UserMetricDto previous
    ) {
        return String.join(
                LINE_SEPARATOR,
                "D1 " + formatRetentionRate(current.d1Retention(), previous == null ? null : previous.d1Retention()),
                "D7 " + formatRetentionRate(current.d7Retention(), previous == null ? null : previous.d7Retention())
        );
    }

    private String formatRetentionRate(
            RetentionDto current,
            RetentionDto previous
    ) {
        Double rate = current.rate();
        if (rate == null) {
            return "- (가입자 없음)";
        }

        String value = String.format("%.1f%%", rate * 100)
                + " (" + formatNumber(current.retainedCount()) + "/" + formatNumber(current.cohortSize()) + "명)";

        Double previousRate = previous == null ? null : previous.rate();
        return appendPercentPointChange(value, rate * 100, previousRate == null ? null : previousRate * 100);
    }

    private String appendPercentPointChange(
            String value,
            double currentPercent,
            Double previousPercent
    ) {
        if (previousPercent == null) {
            return value;
        }

        double diff = currentPercent - previousPercent;
        if (Math.abs(diff) < UNCHANGED_THRESHOLD) {
            return value + " →";
        }

        String arrow = diff > 0 ? "▲" : "▼";
        return value + " " + arrow + String.format("%.1f%%p", Math.abs(diff));
    }

    private String formatLessons(
            LessonMetricDto current,
            LessonMetricDto previous
    ) {
        List<String> lines = new ArrayList<>();
        lines.add("제출 " + formatCount(current.submissionCount(), previous == null ? null : previous.submissionCount(), "건"));
        lines.add("학습자 " + formatCount(current.learnerCount(), previous == null ? null : previous.learnerCount(), "명"));
        lines.add("평균 정답률 " + formatAccuracy(current.averageAccuracy(), previous == null ? null : previous.averageAccuracy()));

        return String.join(LINE_SEPARATOR, lines);
    }

    private String formatAccuracy(
            Double current,
            Double previous
    ) {
        if (current == null) {
            return "-";
        }

        return appendPercentPointChange(String.format("%.1f%%", current), current, previous);
    }

    private String formatInterviews(
            InterviewMetricDto current,
            InterviewMetricDto previous
    ) {
        return String.join(
                LINE_SEPARATOR,
                "시작 " + formatCount(current.startedCount(), previous == null ? null : previous.startedCount(), "건"),
                "제출 " + formatCount(current.submittedCount(), previous == null ? null : previous.submittedCount(), "건"),
                "채점된 답변 " + formatCount(current.gradedAnswerCount(), previous == null ? null : previous.gradedAnswerCount(), "건")
        );
    }

    private String formatReports(ReportInquiryMetricDto metric) {
        long newTotal = metric.newReportTotal();
        String header = "신규 " + formatNumber(newTotal) + "건" + formatTypeBreakdown(metric.newReportCounts(), REPORT_TYPE_LABELS)
                + " · 미처리 총 " + formatNumber(metric.unresolvedReportCount()) + "건";

        if (newTotal == 0) {
            return header + LINE_SEPARATOR + "새로 들어온 신고 없음";
        }

        List<String> items = metric.newReports().stream()
                .map(this::formatReportItem)
                .toList();

        return joinWithinLimit(header, items, newTotal);
    }

    private String formatTypeBreakdown(
            List<TypeCountDto> typeCounts,
            Map<String, String> typeLabels
    ) {
        if (typeCounts.isEmpty()) {
            return "";
        }

        return typeCounts.stream()
                .map(typeCount -> toTypeLabel(typeCount.type(), typeLabels) + " " + formatNumber(typeCount.count()))
                .collect(Collectors.joining(", ", " (", ")"));
    }

    private String toTypeLabel(
            String type,
            Map<String, String> typeLabels
    ) {
        return typeLabels.getOrDefault(type, type);
    }

    private String formatReportItem(ReportItemDto report) {
        return "- " + toTypeLabel(report.reportType(), REPORT_TYPE_LABELS) + " · 문제 #" + report.problemId();
    }

    private String joinWithinLimit(
            String header,
            List<String> items,
            long total
    ) {
        List<String> shownItems = new ArrayList<>(items);

        while (true) {
            String body = buildListBody(header, shownItems, total);
            if (body.length() <= FIELD_VALUE_MAX_LENGTH || shownItems.isEmpty()) {
                return body;
            }

            shownItems.removeLast();
        }
    }

    private String buildListBody(
            String header,
            List<String> shownItems,
            long total
    ) {
        List<String> lines = new ArrayList<>();
        lines.add(header);
        lines.addAll(shownItems);

        long hiddenCount = total - shownItems.size();
        if (hiddenCount > 0) {
            lines.add("외 " + formatNumber(hiddenCount) + "건");
        }

        return String.join(LINE_SEPARATOR, lines);
    }

    private String formatInquiries(ReportInquiryMetricDto metric) {
        long newTotal = metric.newInquiryTotal();
        String header = "신규 " + formatNumber(newTotal) + "건" + formatTypeBreakdown(metric.newInquiryCounts(), INQUIRY_TYPE_LABELS)
                + " · 미답변 총 " + formatNumber(metric.pendingInquiryCount()) + "건";

        if (newTotal == 0) {
            return header + LINE_SEPARATOR + "새로 들어온 문의 없음";
        }

        List<String> items = metric.newInquiries().stream()
                .map(this::formatInquiryItem)
                .toList();

        return joinWithinLimit(header, items, newTotal);
    }

    private String formatInquiryItem(InquiryItemDto inquiry) {
        return "- " + toTypeLabel(inquiry.inquiryType(), INQUIRY_TYPE_LABELS) + " · " + truncateTitle(inquiry.title());
    }

    private String truncateTitle(String title) {
        if (title.length() <= INQUIRY_TITLE_MAX_LENGTH) {
            return title;
        }

        return title.substring(0, INQUIRY_TITLE_MAX_LENGTH) + TRUNCATION_SUFFIX;
    }

    private String buildDescription(ServiceMetricReportDto report) {
        if (!report.hasPrevious()) {
            return "오늘 0시부터 지금까지의 값입니다. 진행 중이라 비교하지 않습니다.";
        }

        return "괄호 안은 직전 같은 기간(" + formatRange(report.previous().range()) + ") 대비 증감입니다.";
    }

    private String buildFooter(ServiceMetricReportDto report) {
        String footer = "생성 " + report.generatedAt().format(GENERATED_AT_FORMATTER) + " KST";
        if (report.period() == MetricPeriod.TODAY) {
            return footer + " · 오늘은 진행 중인 값";
        }

        return footer;
    }

    public DiscordMessageDto createStatusReply(ServiceMetricReportDto report) {
        DiscordButtonDto shareButton = DiscordButtonDto.secondary(
                "채널에 공유",
                SHARE_CUSTOM_ID_PREFIX + report.period().getOptionValue()
        );

        return DiscordMessageDto.of(
                null,
                List.of(buildEmbed(buildStatusTitle(report), report)),
                List.of(DiscordActionRowDto.of(List.of(shareButton))),
                FLAG_EPHEMERAL
        );
    }

    public DiscordMessageDto createSharedReport(ServiceMetricReportDto report) {
        return DiscordMessageDto.of(
                null,
                List.of(buildEmbed(buildStatusTitle(report), report)),
                null,
                FLAG_SUPPRESS_NOTIFICATIONS
        );
    }

    public DiscordMessageDto createDeniedReply() {
        return DiscordMessageDto.of(
                "이 채널이나 역할에서는 현황을 조회할 수 없습니다.",
                null,
                null,
                FLAG_EPHEMERAL
        );
    }
}
