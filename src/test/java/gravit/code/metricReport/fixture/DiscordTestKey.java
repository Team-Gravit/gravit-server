package gravit.code.metricReport.fixture;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.HexFormat;

/**
 * 테스트 전용 Ed25519 키쌍. 공개키는 application-test.yml의 discord.public-key와 같다.
 */
public final class DiscordTestKey {

    public static final String PUBLIC_KEY_HEX = "00bd47945d101cd0be3bbbe44b74b05ea2ebdadb059b3aa73f536255a682ac70";

    private static final String PRIVATE_KEY_SEED_HEX = "9419872a9994e5e6464a12fbafa2bb2362c58ea54a97c287e885888101af83f2";
    private static final String ED25519_PKCS8_PREFIX = "302e020100300506032b657004220420";
    private static final String ALGORITHM = "Ed25519";

    private DiscordTestKey() {
    }

    public static String 서명(
            String timestamp,
            String body
    ) {
        try {
            byte[] encoded = HexFormat.of().parseHex(ED25519_PKCS8_PREFIX + PRIVATE_KEY_SEED_HEX);
            PrivateKey privateKey = KeyFactory.getInstance(ALGORITHM).generatePrivate(new PKCS8EncodedKeySpec(encoded));

            Signature signer = Signature.getInstance(ALGORITHM);
            signer.initSign(privateKey);
            signer.update((timestamp + body).getBytes(StandardCharsets.UTF_8));

            return HexFormat.of().formatHex(signer.sign());
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }
}
