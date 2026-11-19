package gravit.code.metricReport.infrastructure;

import gravit.code.metricReport.config.DiscordProps;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.X509EncodedKeySpec;
import java.util.HexFormat;

@Slf4j
@Component
public class DiscordSignatureVerifier {

    private static final String ALGORITHM = "Ed25519";
    private static final String ED25519_X509_PREFIX = "302a300506032b6570032100";

    private final PublicKey publicKey;

    public DiscordSignatureVerifier(DiscordProps discordProps) {
        this.publicKey = discordProps.interactionEnabled()
                ? createPublicKey(discordProps.publicKey())
                : null;
    }

    private static PublicKey createPublicKey(String publicKeyHex) {
        try {
            byte[] encoded = HexFormat.of().parseHex(ED25519_X509_PREFIX + publicKeyHex);
            return KeyFactory.getInstance(ALGORITHM).generatePublic(new X509EncodedKeySpec(encoded));
        } catch (GeneralSecurityException | IllegalArgumentException | NullPointerException e) {
            throw new IllegalStateException("디스코드 공개키(discord.public-key) 형식이 올바르지 않습니다.", e);
        }
    }

    public boolean isValid(
            String signatureHex,
            String timestamp,
            String rawBody
    ) {
        if (publicKey == null || signatureHex == null || timestamp == null || rawBody == null) {
            return false;
        }

        try {
            Signature verifier = Signature.getInstance(ALGORITHM);
            verifier.initVerify(publicKey);
            verifier.update((timestamp + rawBody).getBytes(StandardCharsets.UTF_8));

            return verifier.verify(HexFormat.of().parseHex(signatureHex));
        } catch (GeneralSecurityException | IllegalArgumentException e) {
            log.warn("디스코드 요청 서명 검증 실패 - {}", e.getMessage());
            return false;
        }
    }
}
