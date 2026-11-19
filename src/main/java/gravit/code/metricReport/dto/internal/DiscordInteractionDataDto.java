package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record DiscordInteractionDataDto(

        String name,

        List<DiscordInteractionOptionDto> options,

        @JsonProperty("custom_id")
        String customId
) {
}
