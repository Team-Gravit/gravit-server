package gravit.code.metricReport.controller;

import gravit.code.metricReport.controller.docs.DiscordInteractionControllerDocs;
import gravit.code.metricReport.dto.internal.DiscordInteractionResponseDto;
import gravit.code.metricReport.service.DiscordInteractionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/discord")
public class DiscordInteractionController implements DiscordInteractionControllerDocs {

    private static final String SIGNATURE_HEADER = "X-Signature-Ed25519";
    private static final String TIMESTAMP_HEADER = "X-Signature-Timestamp";

    private final DiscordInteractionService discordInteractionService;

    @Override
    @PostMapping("/interactions")
    public ResponseEntity<DiscordInteractionResponseDto> handleInteraction(
            @RequestHeader(value = SIGNATURE_HEADER, required = false) String signature,
            @RequestHeader(value = TIMESTAMP_HEADER, required = false) String timestamp,
            @RequestBody String body
    ) {
        return ResponseEntity.status(OK).body(discordInteractionService.handle(signature, timestamp, body));
    }
}
