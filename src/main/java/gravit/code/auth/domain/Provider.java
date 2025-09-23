package gravit.code.auth.domain;

import java.util.Locale;
import java.util.Optional;

public enum Provider {
    GOOGLE("google"),
    KAKAO("kakao"),
    NAVER("naver");

    private final String provider;

    Provider(String provider) {
        this.provider = provider;
    }

    public static Optional<String> parse(String provider) {
        if (provider == null || provider.isBlank())
            return Optional.empty();

        String lowerProvider = provider.trim().toLowerCase(Locale.ROOT);
        for (Provider pv : values()) if(pv.provider.equals(lowerProvider))
            return Optional.of(lowerProvider);

        return Optional.empty();
    }
}
