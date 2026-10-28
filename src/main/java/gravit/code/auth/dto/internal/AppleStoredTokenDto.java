package gravit.code.auth.dto.internal;

import gravit.code.auth.domain.AppleClient;

public record AppleStoredTokenDto(

        String refreshToken,

        AppleClient client
) {
    public static AppleStoredTokenDto of(
            String refreshToken,
            AppleClient client
    ) {
        return new AppleStoredTokenDto(refreshToken, client);
    }
}
