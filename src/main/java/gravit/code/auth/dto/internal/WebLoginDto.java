package gravit.code.auth.dto.internal;

import gravit.code.auth.dto.request.WebAuthCodeRequest;

public record WebLoginDto(

        String code,

        String state,

        String origin,

        String dest
) {
    public static WebLoginDto of(
            WebAuthCodeRequest request,
            String origin,
            String dest
    ) {
        return new WebLoginDto(request.code(), request.state(), origin, dest);
    }
}
