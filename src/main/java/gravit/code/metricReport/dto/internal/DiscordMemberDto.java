package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record DiscordMemberDto(

        List<String> roles
) {
}
