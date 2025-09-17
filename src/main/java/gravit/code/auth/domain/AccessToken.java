package gravit.code.auth.domain;

public record AccessToken(
        String token
) implements Token {
}
