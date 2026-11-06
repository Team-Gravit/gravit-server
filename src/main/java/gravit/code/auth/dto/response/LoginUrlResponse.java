package gravit.code.auth.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record LoginUrlResponse(

        @Schema(
                description = "OAuth 제공자 인가 페이지 URL",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String loginUrl,

        @Schema(
                description = "이번 로그인 시도에 발급한 state. 10분 뒤 만료되고 한 번만 쓸 수 있다",
                example = "3f1c2b8e-7a4d-4e8a-9b1f-0c2d3e4f5a6b",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String state
) {
    public static LoginUrlResponse of(
            String loginUrl,
            String state
    ) {
        return new LoginUrlResponse(loginUrl, state);
    }
}
