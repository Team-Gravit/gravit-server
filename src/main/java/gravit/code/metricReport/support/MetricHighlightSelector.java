package gravit.code.metricReport.support;

import gravit.code.metricReport.dto.internal.MetricChangeCandidateDto;
import gravit.code.metricReport.dto.internal.ReportInquiryMetricDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.dto.internal.ServiceMetricSnapshotDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

import static gravit.code.metricReport.support.MetricChangeFormatter.SMALL_SAMPLE_THRESHOLD;

@Component
@RequiredArgsConstructor
public class MetricHighlightSelector {

    private static final int MAX_HIGHLIGHTS = 3;
    private static final String NO_CHANGE_MESSAGE = "직전 기간과 비교해 눈에 띄는 변화가 없습니다";

    private final MetricChangeFormatter metricChangeFormatter;

    public List<String> select(ServiceMetricReportDto report) {
        List<String> highlights = new ArrayList<>();

        if (report.hasPrevious()) {
            findBiggestChange(report.current(), report.previous()).ifPresent(highlights::add);
            findIncomparable(report.current(), report.previous()).ifPresent(highlights::add);
        } else {
            highlights.add(summarizeToday(report.current()));
        }

        findPendingWork(report.reportsAndInquiries()).ifPresent(highlights::add);

        if (highlights.isEmpty()) {
            return List.of(NO_CHANGE_MESSAGE);
        }

        return List.copyOf(highlights.subList(0, Math.min(MAX_HIGHLIGHTS, highlights.size())));
    }

    private Optional<String> findBiggestChange(
            ServiceMetricSnapshotDto current,
            ServiceMetricSnapshotDto previous
    ) {
        List<MetricChangeCandidateDto> changed = buildCandidates(current, previous).stream()
                .filter(candidate -> candidate.diff() != 0)
                .toList();

        Optional<MetricChangeCandidateDto> biggestRelative = changed.stream()
                .filter(candidate -> candidate.previous() >= SMALL_SAMPLE_THRESHOLD)
                .max(Comparator.comparingDouble(MetricChangeCandidateDto::changeRate));

        Optional<MetricChangeCandidateDto> biggest = biggestRelative.isPresent()
                ? biggestRelative
                : changed.stream().max(Comparator.comparingDouble(candidate -> Math.abs(candidate.diff())));

        return biggest.map(this::formatTransition);
    }

    private List<MetricChangeCandidateDto> buildCandidates(
            ServiceMetricSnapshotDto current,
            ServiceMetricSnapshotDto previous
    ) {
        boolean isSingleDay = current.range().isSingleDay();

        return List.of(
                MetricChangeCandidateDto.of("신규 가입", current.users().newSignups(), previous.users().newSignups(), "명", false),
                MetricChangeCandidateDto.of(
                        isSingleDay ? "DAU" : "평균 DAU",
                        current.users().averageDailyActiveUsers(),
                        previous.users().averageDailyActiveUsers(),
                        "명",
                        !isSingleDay
                ),
                MetricChangeCandidateDto.of("레슨 제출", current.lessons().submissionCount(), previous.lessons().submissionCount(), "건", false),
                MetricChangeCandidateDto.of("면접 시작", current.interviews().startedCount(), previous.interviews().startedCount(), "건", false)
        );
    }

    private String formatTransition(MetricChangeCandidateDto candidate) {
        return candidate.label() + " " + formatValue(candidate.previous(), candidate) + " → " + formatValue(candidate.current(), candidate);
    }

    private String formatValue(
            double value,
            MetricChangeCandidateDto candidate
    ) {
        String number = candidate.isDecimal()
                ? metricChangeFormatter.decimal(value)
                : metricChangeFormatter.number(Math.round(value));

        return number + candidate.unit();
    }

    private Optional<String> findIncomparable(
            ServiceMetricSnapshotDto current,
            ServiceMetricSnapshotDto previous
    ) {
        Double currentAccuracy = current.lessons().averageAccuracy();
        if (currentAccuracy == null || previous.lessons().averageAccuracy() != null) {
            return Optional.empty();
        }

        return Optional.of("평균 정답률 " + String.format("%.1f%%", currentAccuracy) + " · 직전 제출 없음");
    }

    private String summarizeToday(ServiceMetricSnapshotDto current) {
        return "오늘 신규 가입 " + metricChangeFormatter.number(current.users().newSignups()) + "명 · 활성 "
                + metricChangeFormatter.number(current.users().activeUsers()) + "명";
    }

    private Optional<String> findPendingWork(ReportInquiryMetricDto reportsAndInquiries) {
        long unresolvedReports = reportsAndInquiries.unresolvedReportCount();
        long pendingInquiries = reportsAndInquiries.pendingInquiryCount();
        if (unresolvedReports == 0 && pendingInquiries == 0) {
            return Optional.empty();
        }

        return Optional.of("미처리 신고 " + metricChangeFormatter.number(unresolvedReports) + "건 · 미답변 문의 "
                + metricChangeFormatter.number(pendingInquiries) + "건");
    }
}
