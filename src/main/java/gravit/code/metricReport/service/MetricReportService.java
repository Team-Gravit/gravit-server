package gravit.code.metricReport.service;

import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.DiscordMessageDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.infrastructure.DiscordWebhookClient;
import gravit.code.metricReport.infrastructure.MetricSummaryClient;
import gravit.code.metricReport.support.DiscordReportMessageFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MetricReportService {

    private final ServiceMetricQueryService serviceMetricQueryService;

    private final DiscordReportMessageFactory discordReportMessageFactory;
    private final DiscordWebhookClient discordWebhookClient;
    private final MetricSummaryClient metricSummaryClient;

    public void sendWeeklyReport() {
        ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.LAST_WEEK);

        String summary = metricSummaryClient.summarize(discordReportMessageFactory.createSummaryInput(report))
                .orElse(null);

        DiscordMessageDto message = discordReportMessageFactory.createScheduledReport(report, summary);

        discordWebhookClient.send(message);
    }
}
