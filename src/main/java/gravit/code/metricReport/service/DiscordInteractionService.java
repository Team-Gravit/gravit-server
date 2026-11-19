package gravit.code.metricReport.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.metricReport.config.DiscordProps;
import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.DiscordInteractionDataDto;
import gravit.code.metricReport.dto.internal.DiscordInteractionDto;
import gravit.code.metricReport.dto.internal.DiscordInteractionOptionDto;
import gravit.code.metricReport.dto.internal.DiscordInteractionResponseDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.infrastructure.DiscordSignatureVerifier;
import gravit.code.metricReport.support.DiscordReportMessageFactory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.DISCORD_INTERACTION_DISABLED;
import static gravit.code.global.exception.domain.CustomErrorCode.DISCORD_INVALID_SIGNATURE;
import static gravit.code.global.exception.domain.CustomErrorCode.DISCORD_UNSUPPORTED_INTERACTION;
import static gravit.code.metricReport.dto.internal.DiscordInteractionDto.TYPE_APPLICATION_COMMAND;
import static gravit.code.metricReport.dto.internal.DiscordInteractionDto.TYPE_MESSAGE_COMPONENT;
import static gravit.code.metricReport.dto.internal.DiscordInteractionDto.TYPE_PING;
import static gravit.code.metricReport.support.DiscordReportMessageFactory.SHARE_CUSTOM_ID_PREFIX;

@Slf4j
@Service
@RequiredArgsConstructor
public class DiscordInteractionService {

    private static final String STATUS_COMMAND_NAME = "현황";
    private static final String PERIOD_OPTION_NAME = "기간";

    private final ServiceMetricQueryService serviceMetricQueryService;

    private final DiscordReportMessageFactory discordReportMessageFactory;
    private final DiscordSignatureVerifier discordSignatureVerifier;

    private final ObjectMapper objectMapper;
    private final DiscordProps discordProps;

    public DiscordInteractionResponseDto handle(
            String signature,
            String timestamp,
            String rawBody
    ) {
        if (!discordProps.interactionEnabled()) {
            throw new RestApiException(DISCORD_INTERACTION_DISABLED);
        }

        if (!discordSignatureVerifier.isValid(signature, timestamp, rawBody)) {
            throw new RestApiException(DISCORD_INVALID_SIGNATURE);
        }

        DiscordInteractionDto interaction = parse(rawBody);

        return switch (interaction.type()) {
            case TYPE_PING -> DiscordInteractionResponseDto.pong();
            case TYPE_APPLICATION_COMMAND -> handleStatusCommand(interaction);
            case TYPE_MESSAGE_COMPONENT -> handleShare(interaction);
            default -> throw new RestApiException(DISCORD_UNSUPPORTED_INTERACTION);
        };
    }

    private DiscordInteractionDto parse(String rawBody) {
        try {
            return objectMapper.readValue(rawBody, DiscordInteractionDto.class);
        } catch (JsonProcessingException e) {
            throw new RestApiException(DISCORD_UNSUPPORTED_INTERACTION);
        }
    }

    private DiscordInteractionResponseDto handleStatusCommand(DiscordInteractionDto interaction) {
        DiscordInteractionDataDto data = interaction.data();
        if (data == null || !STATUS_COMMAND_NAME.equals(data.name())) {
            throw new RestApiException(DISCORD_UNSUPPORTED_INTERACTION);
        }

        if (!isAllowed(interaction)) {
            return DiscordInteractionResponseDto.message(discordReportMessageFactory.createDeniedReply());
        }

        MetricPeriod period = MetricPeriod.fromOptionValue(findPeriodOptionValue(data.options()));

        ServiceMetricReportDto report = getReportWithTiming(period);

        return DiscordInteractionResponseDto.message(discordReportMessageFactory.createStatusReply(report));
    }

    private boolean isAllowed(DiscordInteractionDto interaction) {
        if (interaction.member() == null || interaction.member().roles() == null) {
            return false;
        }

        boolean isAllowedChannel = discordProps.allowedChannelIds().contains(interaction.channelId());
        boolean hasAllowedRole = interaction.member().roles().stream()
                .anyMatch(discordProps.allowedRoleIds()::contains);

        return isAllowedChannel && hasAllowedRole;
    }

    private String findPeriodOptionValue(List<DiscordInteractionOptionDto> options) {
        if (options == null) {
            return null;
        }

        return options.stream()
                .filter(option -> PERIOD_OPTION_NAME.equals(option.name()))
                .map(DiscordInteractionOptionDto::value)
                .findFirst()
                .orElse(null);
    }

    private ServiceMetricReportDto getReportWithTiming(MetricPeriod period) {
        long startNanos = System.nanoTime();

        ServiceMetricReportDto report = serviceMetricQueryService.getReport(period);

        log.info("디스코드 현황 조회 집계 완료 - period: {}, elapsedMs: {}", period, Duration.ofNanos(System.nanoTime() - startNanos).toMillis());
        return report;
    }

    private DiscordInteractionResponseDto handleShare(DiscordInteractionDto interaction) {
        DiscordInteractionDataDto data = interaction.data();
        if (data == null || data.customId() == null || !data.customId().startsWith(SHARE_CUSTOM_ID_PREFIX)) {
            throw new RestApiException(DISCORD_UNSUPPORTED_INTERACTION);
        }

        if (!isAllowed(interaction)) {
            return DiscordInteractionResponseDto.message(discordReportMessageFactory.createDeniedReply());
        }

        MetricPeriod period = MetricPeriod.fromOptionValue(data.customId().substring(SHARE_CUSTOM_ID_PREFIX.length()));

        ServiceMetricReportDto report = getReportWithTiming(period);

        return DiscordInteractionResponseDto.message(discordReportMessageFactory.createSharedReport(report));
    }
}
