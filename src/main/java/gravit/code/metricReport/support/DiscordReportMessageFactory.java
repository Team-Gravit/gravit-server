package gravit.code.metricReport.support;

import gravit.code.metricReport.config.DiscordProps;
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
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.dto.internal.ServiceMetricSnapshotDto;
import gravit.code.metricReport.dto.internal.TypeCountDto;
import gravit.code.metricReport.dto.internal.UserMetricDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class DiscordReportMessageFactory {

    public static final String SHARE_CUSTOM_ID_PREFIX = "metric-share:";
    public static final String LIST_CUSTOM_ID_PREFIX = "metric-list:";

    private static final int FLAG_EPHEMERAL = 1 << 6;
    private static final int FLAG_SUPPRESS_NOTIFICATIONS = 1 << 12;
    private static final int EMBED_COLOR = 0x5865F2;
    private static final int FIELD_VALUE_MAX_LENGTH = 1024;
    private static final int INQUIRY_TITLE_MAX_LENGTH = 50;
    private static final String TRUNCATION_SUFFIX = "…";
    private static final String LINE_SEPARATOR = "\n";
    private static final String BLOCK_SEPARATOR = "\n\n";
    private static final String SMALL_TEXT_PREFIX = "-# ";
    private static final String SECTION_PREFIX = "### ";
    private static final String QUOTE_PREFIX = "> ";
    private static final String INLINE_SEPARATOR = " · ";
    private static final String AI_SUMMARY_HEADER = "🧠 **AI 요약**";

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter SHORT_DATE_FORMATTER = DateTimeFormatter.ofPattern("MM-dd");
    private static final DateTimeFormatter MONTH_DAY_FORMATTER = DateTimeFormatter.ofPattern("M월 d일");
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

    private final MetricChangeFormatter metricChangeFormatter;
    private final MetricHighlightSelector metricHighlightSelector;

    private final DiscordProps discordProps;

    public DiscordMessageDto createScheduledReport(
            ServiceMetricReportDto report,
            String summary
    ) {
        String title = report.period() == MetricPeriod.LAST_WEEK
                ? "📊 주간 리포트 · " + formatRange(report.current().range())
                : buildStatusTitle(report);

        return DiscordMessageDto.of(
                null,
                List.of(buildReportEmbed(title, report, summary)),
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
        return "📊 서비스 현황 · " + report.period().getLabel();
    }

    private DiscordEmbedDto buildReportEmbed(
            String title,
            ServiceMetricReportDto report,
            String summary
    ) {
        return DiscordEmbedDto.of(
                title,
                adminUrlOrNull(),
                buildBody(report, summary),
                EMBED_COLOR,
                null,
                DiscordEmbedFooterDto.from(buildFooter(report))
        );
    }

    private String adminUrlOrNull() {
        return StringUtils.hasText(discordProps.adminUrl()) ? discordProps.adminUrl() : null;
    }

    private String buildBody(
            ServiceMetricReportDto report,
            String summary
    ) {
        return String.join(
                BLOCK_SEPARATOR,
                buildRangeLine(report),
                buildHighlights(report, summary),
                buildSections(report, true)
        );
    }

    private String buildSections(
            ServiceMetricReportDto report,
            boolean withAdminLink
    ) {
        return String.join(
                LINE_SEPARATOR,
                buildUserSection(report),
                buildRetentionSection(report),
                buildLearningSection(report),
                buildPendingSection(report, withAdminLink)
        );
    }

    private String buildUserSection(ServiceMetricReportDto report) {
        ServiceMetricSnapshotDto current = report.current();
        UserMetricDto users = current.users();
        UserMetricDto previousUsers = report.hasPrevious() ? report.previous().users() : null;

        List<String> lines = new ArrayList<>();
        lines.add(SECTION_PREFIX + "👥 사용자");
        lines.add(metric("신규 가입", metricChangeFormatter.number(users.newSignups()) + "명", countChange(users.newSignups(), previousUsers == null ? null : previousUsers.newSignups())));

        if (current.range().isSingleDay()) {
            lines.add(metric("DAU", metricChangeFormatter.number(users.activeUsers()) + "명", countChange(users.activeUsers(), previousUsers == null ? null : previousUsers.activeUsers())));
        } else {
            lines.add(String.join(
                    INLINE_SEPARATOR,
                    metric(
                            "평균 DAU",
                            metricChangeFormatter.decimal(users.averageDailyActiveUsers()) + "명",
                            previousUsers == null ? "" : metricChangeFormatter.averageChange(users.averageDailyActiveUsers(), previousUsers.averageDailyActiveUsers())
                    ),
                    metric("기간 활성", metricChangeFormatter.number(users.activeUsers()) + "명", countChange(users.activeUsers(), previousUsers == null ? null : previousUsers.activeUsers()))
            ));
        }

        lines.add(metric("총 가입자", metricChangeFormatter.number(users.totalUsers()) + "명", "")
                + INLINE_SEPARATOR + metric("MAU", metricChangeFormatter.number(users.monthlyActiveUsers()) + "명", ""));
        lines.add(SMALL_TEXT_PREFIX + describeMau(users, current.range().endDate()));

        return String.join(LINE_SEPARATOR, lines);
    }

    private String metric(
            String label,
            String value,
            String change
    ) {
        String line = label + " **" + value + "**";
        String pill = metricChangeFormatter.pill(change);

        return pill.isEmpty() ? line : line + " " + pill;
    }

    private String countChange(
            long current,
            Long previous
    ) {
        return metricChangeFormatter.countChange(current, previous);
    }

    private String describeMau(
            UserMetricDto users,
            LocalDate endDate
    ) {
        int month = users.mauMonth().getMonthValue();
        if (!users.mauInProgress()) {
            return "MAU는 " + month + "월 전체";
        }

        return "MAU는 " + month + "월 1일부터 " + endDate.format(MONTH_DAY_FORMATTER) + "까지 집계 중";
    }

    private String buildRetentionSection(ServiceMetricReportDto report) {
        UserMetricDto users = report.current().users();
        UserMetricDto previousUsers = report.hasPrevious() ? report.previous().users() : null;

        return String.join(
                LINE_SEPARATOR,
                SECTION_PREFIX + "🔁 리텐션",
                "가입 다음 날 다시 온 사람 " + metricChangeFormatter.retention(users.d1Retention(), previousUsers == null ? null : previousUsers.d1Retention()),
                "가입 7일째 다시 온 사람 " + metricChangeFormatter.retention(users.d7Retention(), previousUsers == null ? null : previousUsers.d7Retention()),
                SMALL_TEXT_PREFIX + "D1, D7 · 대상 " + MetricChangeFormatter.SMALL_SAMPLE_THRESHOLD + "명 미만은 비율 비교 생략"
        );
    }

    private String buildLearningSection(ServiceMetricReportDto report) {
        LessonMetricDto lessons = report.current().lessons();
        InterviewMetricDto interviews = report.current().interviews();
        LessonMetricDto previousLessons = report.hasPrevious() ? report.previous().lessons() : null;
        InterviewMetricDto previousInterviews = report.hasPrevious() ? report.previous().interviews() : null;

        String lessonLine = String.join(
                INLINE_SEPARATOR,
                metric("레슨 제출", metricChangeFormatter.number(lessons.submissionCount()) + "건", countChange(lessons.submissionCount(), previousLessons == null ? null : previousLessons.submissionCount())),
                metric("학습자", metricChangeFormatter.number(lessons.learnerCount()) + "명", countChange(lessons.learnerCount(), previousLessons == null ? null : previousLessons.learnerCount()))
        );

        String interviewLine = String.join(
                INLINE_SEPARATOR,
                metric("면접 시작", metricChangeFormatter.number(interviews.startedCount()) + "건", countChange(interviews.startedCount(), previousInterviews == null ? null : previousInterviews.startedCount())),
                metric("제출", metricChangeFormatter.number(interviews.submittedCount()) + "건", countChange(interviews.submittedCount(), previousInterviews == null ? null : previousInterviews.submittedCount())),
                metric("채점된 답변", metricChangeFormatter.number(interviews.gradedAnswerCount()) + "건", countChange(interviews.gradedAnswerCount(), previousInterviews == null ? null : previousInterviews.gradedAnswerCount()))
        );

        return String.join(
                LINE_SEPARATOR,
                SECTION_PREFIX + "📚 학습 · 🎤 면접",
                lessonLine,
                formatAccuracy(lessons, previousLessons),
                interviewLine
        );
    }

    private String formatAccuracy(
            LessonMetricDto lessons,
            LessonMetricDto previousLessons
    ) {
        Double accuracy = lessons.averageAccuracy();
        if (accuracy == null) {
            return metric("평균 정답률", "-", "제출 없음");
        }

        String change = previousLessons == null
                ? ""
                : metricChangeFormatter.percentPointChange(accuracy, previousLessons.averageAccuracy());

        return metric("평균 정답률", String.format("%.1f%%", accuracy), change);
    }

    private String buildPendingSection(
            ServiceMetricReportDto report,
            boolean withAdminLink
    ) {
        ReportInquiryMetricDto metric = report.reportsAndInquiries();

        String pendingLine = metric("미처리 신고", metricChangeFormatter.number(metric.unresolvedReportCount()) + "건", "")
                + INLINE_SEPARATOR + metric("미답변 문의", metricChangeFormatter.number(metric.pendingInquiryCount()) + "건", "");

        String adminUrl = adminUrlOrNull();
        if (withAdminLink && adminUrl != null) {
            pendingLine += " → [어드민 열기](" + adminUrl + ")";
        }

        return String.join(
                LINE_SEPARATOR,
                SECTION_PREFIX + "🚨 처리 필요",
                pendingLine,
                SMALL_TEXT_PREFIX + "이번 기간 신규 신고 " + metricChangeFormatter.number(metric.newReportTotal())
                        + "건, 문의 " + metricChangeFormatter.number(metric.newInquiryTotal()) + "건"
        );
    }

    private String buildRangeLine(ServiceMetricReportDto report) {
        if (!report.hasPrevious()) {
            return SMALL_TEXT_PREFIX + "오늘 0시부터 지금까지 · 비교 없음";
        }

        return SMALL_TEXT_PREFIX + formatRange(report.current().range())
                + " · 직전 같은 기간(" + formatRange(report.previous().range()) + ") 대비";
    }

    private String buildHighlights(
            ServiceMetricReportDto report,
            String summary
    ) {
        if (summary != null) {
            return QUOTE_PREFIX + AI_SUMMARY_HEADER + LINE_SEPARATOR + summary.lines()
                    .filter(line -> !line.isBlank())
                    .map(line -> QUOTE_PREFIX + line.strip())
                    .collect(Collectors.joining(LINE_SEPARATOR));
        }

        return metricHighlightSelector.select(report).stream()
                .map(highlight -> QUOTE_PREFIX + highlight)
                .collect(Collectors.joining(LINE_SEPARATOR));
    }

    private String buildFooter(ServiceMetricReportDto report) {
        return "생성 " + report.generatedAt().format(GENERATED_AT_FORMATTER) + " KST";
    }

    public DiscordMessageDto createStatusReply(ServiceMetricReportDto report) {
        String periodValue = report.period().getOptionValue();

        List<DiscordButtonDto> buttons = new ArrayList<>();
        buttons.add(DiscordButtonDto.secondary("채널에 공유", SHARE_CUSTOM_ID_PREFIX + periodValue));
        buttons.add(DiscordButtonDto.secondary("신고·문의 목록", LIST_CUSTOM_ID_PREFIX + periodValue));
        addAdminLinkButton(buttons);

        return DiscordMessageDto.of(
                null,
                List.of(buildReportEmbed(buildStatusTitle(report), report, null)),
                List.of(DiscordActionRowDto.of(buttons)),
                FLAG_EPHEMERAL
        );
    }

    private void addAdminLinkButton(List<DiscordButtonDto> buttons) {
        String adminUrl = adminUrlOrNull();
        if (adminUrl != null) {
            buttons.add(DiscordButtonDto.link("어드민 열기", adminUrl));
        }
    }

    public DiscordMessageDto createSharedReport(ServiceMetricReportDto report) {
        List<DiscordButtonDto> buttons = new ArrayList<>();
        addAdminLinkButton(buttons);

        return DiscordMessageDto.of(
                null,
                List.of(buildReportEmbed(buildStatusTitle(report), report, null)),
                buttons.isEmpty() ? null : List.of(DiscordActionRowDto.of(buttons)),
                FLAG_SUPPRESS_NOTIFICATIONS
        );
    }

    public DiscordMessageDto createListReply(ServiceMetricReportDto report) {
        ReportInquiryMetricDto metric = report.reportsAndInquiries();

        DiscordEmbedDto embed = DiscordEmbedDto.of(
                "🗂️ 신고·문의 목록 · " + report.period().getLabel(),
                adminUrlOrNull(),
                SMALL_TEXT_PREFIX + formatRange(report.current().range()) + " 접수분 · 최근순",
                EMBED_COLOR,
                List.of(
                        DiscordEmbedFieldDto.of("🚨 신고", formatReports(metric)),
                        DiscordEmbedFieldDto.of("💬 문의", formatInquiries(metric))
                ),
                DiscordEmbedFooterDto.from(buildFooter(report))
        );

        List<DiscordButtonDto> buttons = new ArrayList<>();
        addAdminLinkButton(buttons);

        return DiscordMessageDto.of(
                null,
                List.of(embed),
                buttons.isEmpty() ? null : List.of(DiscordActionRowDto.of(buttons)),
                FLAG_EPHEMERAL
        );
    }

    private String formatReports(ReportInquiryMetricDto metric) {
        long newTotal = metric.newReportTotal();
        String header = "신규 " + metricChangeFormatter.number(newTotal) + "건" + formatTypeBreakdown(metric.newReportCounts(), REPORT_TYPE_LABELS)
                + " · 미처리 총 " + metricChangeFormatter.number(metric.unresolvedReportCount()) + "건";

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
                .map(typeCount -> toTypeLabel(typeCount.type(), typeLabels) + " " + metricChangeFormatter.number(typeCount.count()))
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
            lines.add("외 " + metricChangeFormatter.number(hiddenCount) + "건");
        }

        return String.join(LINE_SEPARATOR, lines);
    }

    private String formatInquiries(ReportInquiryMetricDto metric) {
        long newTotal = metric.newInquiryTotal();
        String header = "신규 " + metricChangeFormatter.number(newTotal) + "건" + formatTypeBreakdown(metric.newInquiryCounts(), INQUIRY_TYPE_LABELS)
                + " · 미답변 총 " + metricChangeFormatter.number(metric.pendingInquiryCount()) + "건";

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

    public DiscordMessageDto createDeniedReply() {
        return DiscordMessageDto.of(
                "이 채널이나 역할에서는 현황을 조회할 수 없습니다.",
                null,
                null,
                FLAG_EPHEMERAL
        );
    }

    public String createSummaryInput(ServiceMetricReportDto report) {
        return String.join(
                BLOCK_SEPARATOR,
                buildRangeLine(report),
                buildSections(report, false)
        );
    }
}
