package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DiscordButtonDto(

        int type,

        int style,

        String label,

        @JsonProperty("custom_id")
        String customId,

        String url
) {
    public static final int COMPONENT_TYPE_BUTTON = 2;
    public static final int STYLE_SECONDARY = 2;
    public static final int STYLE_LINK = 5;

    public static DiscordButtonDto secondary(
            String label,
            String customId
    ) {
        return new DiscordButtonDto(COMPONENT_TYPE_BUTTON, STYLE_SECONDARY, label, customId, null);
    }

    public static DiscordButtonDto link(
            String label,
            String url
    ) {
        return new DiscordButtonDto(COMPONENT_TYPE_BUTTON, STYLE_LINK, label, null, url);
    }
}
