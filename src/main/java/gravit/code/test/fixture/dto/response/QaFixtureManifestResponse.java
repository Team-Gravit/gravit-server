package gravit.code.test.fixture.dto.response;

import gravit.code.test.fixture.support.QaFixtureSet;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.OffsetDateTime;
import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record QaFixtureManifestResponse(

        @Schema(
                description = "적재한 세트. auto | manual",
                example = "auto"
        )
        String set,

        @Schema(
                description = "적재 완료 시각 (KST, 초 단위)",
                example = "2026-10-17T14:05:00+09:00"
        )
        OffsetDateTime loadedAt,

        @Schema(description = "페르소나 13개. 보조 유저는 포함하지 않는다")
        List<QaPersonaManifestResponse> personas
) {
    public static QaFixtureManifestResponse of(
            QaFixtureSet set,
            OffsetDateTime loadedAt,
            List<QaPersonaManifestResponse> personas
    ) {
        return QaFixtureManifestResponse.builder()
                .set(set.getKey())
                .loadedAt(loadedAt)
                .personas(personas)
                .build();
    }
}
