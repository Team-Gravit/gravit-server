package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record DiscordInteractionOptionDto(

        String name,

        String value
) {
}
