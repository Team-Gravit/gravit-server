package gravit.code.metricReport.service;

import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.DiscordMessageDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.infrastructure.DiscordWebhookClient;
import gravit.code.metricReport.support.DiscordReportMessageFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MetricReportService {

    private final ServiceMetricQueryService serviceMetricQueryService;

    private final DiscordReportMessageFactory discordReportMessageFactory;
    private final DiscordWebhookClient discordWebhookClient;

    public void sendWeeklyReport() {
        ServiceMetricReportDto report = serviceMetricQueryService.getReport(MetricPeriod.LAST_WEEK);

        DiscordMessageDto message = discordReportMessageFactory.createScheduledReport(report);

        discordWebhookClient.send(message);
    }
}
