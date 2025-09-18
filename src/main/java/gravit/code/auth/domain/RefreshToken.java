package gravit.code.auth.domain;

public record RefreshToken(
        String token
) implements Token {
}
