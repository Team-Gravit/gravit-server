package gravit.code.test.season.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record TestSeasonPopupResponse(
        @Schema(description = "팝업을 다시 보게 한 유저", example = "123")
        long userId,
        @Schema(description = "lastClosedSeasonId 로 기록한 시즌 id", example = "2")
        long lastClosedSeasonId,
        @Schema(description = "그 시즌의 키", example = "2026-S2")
        String lastClosedSeasonKey,
        @Schema(description = "유저가 그 시즌의 리그 이력을 갖고 있는지. false 면 팝업 조건이 안 맞아 뜨지 않는다", example = "true")
        boolean hasLeagueHistory
) {
}
