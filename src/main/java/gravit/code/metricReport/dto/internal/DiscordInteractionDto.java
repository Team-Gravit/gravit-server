package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public record DiscordInteractionDto(

        int type,

        DiscordInteractionDataDto data,

        @JsonProperty("channel_id")
        String channelId,

        DiscordMemberDto member
) {
    public static final int TYPE_PING = 1;
    public static final int TYPE_APPLICATION_COMMAND = 2;
    public static final int TYPE_MESSAGE_COMPONENT = 3;
}
