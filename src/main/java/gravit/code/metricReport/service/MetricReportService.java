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

    public void sendDailyReport() {
        sendScheduledReport(MetricPeriod.YESTERDAY);
    }

    private void sendScheduledReport(MetricPeriod period) {
        ServiceMetricReportDto report = serviceMetricQueryService.getReport(period);

        DiscordMessageDto message = discordReportMessageFactory.createScheduledReport(report);

        discordWebhookClient.send(message);
    }

    public void sendWeeklyReport() {
        sendScheduledReport(MetricPeriod.LAST_WEEK);
    }
}
