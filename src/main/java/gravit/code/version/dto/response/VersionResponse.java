package gravit.code.version.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record VersionResponse(
        @Schema(
                description = "서버가 정의한 최신 앱 버전",
                example = "1.0.0",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String version
) {
    public static VersionResponse of(String version) {
        return new VersionResponse(version);
    }
}
