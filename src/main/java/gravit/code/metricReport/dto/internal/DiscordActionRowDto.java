package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DiscordActionRowDto(

        int type,

        List<DiscordButtonDto> components
) {
    public static final int COMPONENT_TYPE_ACTION_ROW = 1;

    public static DiscordActionRowDto of(List<DiscordButtonDto> buttons) {
        return new DiscordActionRowDto(COMPONENT_TYPE_ACTION_ROW, buttons);
    }
}
