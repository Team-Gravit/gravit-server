package gravit.code.metricReport.controller.docs;

import gravit.code.metricReport.dto.internal.DiscordInteractionResponseDto;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Discord API", description = "디스코드 인터랙션 수신 (외부 웹훅 계약)")
public interface DiscordInteractionControllerDocs {

    ResponseEntity<DiscordInteractionResponseDto> handleInteraction(
            String signature,
            String timestamp,
            String body
    );
}
