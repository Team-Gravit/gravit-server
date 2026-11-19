package gravit.code.metricReport.scheduler;

import gravit.code.metricReport.config.DiscordProps;
import gravit.code.metricReport.service.MetricReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class MetricReportScheduler {

    private final MetricReportService metricReportService;

    private final DiscordProps discordProps;

    @Scheduled(cron = "0 0 9 * * MON", zone = "Asia/Seoul")
    public void sendWeeklyReport() {
        if (!discordProps.reportEnabled()) {
            return;
        }

        try {
            metricReportService.sendWeeklyReport();
        } catch (Exception e) {
            log.error("주간 지표 리포트 전송 실패", e);
        }
    }
}
