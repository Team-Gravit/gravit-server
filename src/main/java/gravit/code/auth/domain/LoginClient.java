package gravit.code.auth.domain;

import java.util.Arrays;
import java.util.Optional;

public enum LoginClient {
    WEB,
    ANDROID,
    IOS;

    public static LoginClient from(AppleClient appleClient) {
        return switch (appleClient) {
            case WEB -> WEB;
            case IOS -> IOS;
        };
    }

    public static Optional<LoginClient> fromClaim(String claim) {
        if (claim == null) {
            return Optional.empty();
        }
        return Arrays.stream(values())
                .filter(client -> client.name().equals(claim))
                .findFirst();
    }
}
