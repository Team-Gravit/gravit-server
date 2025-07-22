package gravit.code.auth.oauth.dto;

public record LoginResponse(
        String accessToken,
        boolean isOnboarded
) {
}
