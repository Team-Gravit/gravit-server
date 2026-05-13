package gravit.code.league.dto.internal;

import jakarta.validation.constraints.NotNull;

public record CurrentSeasonDto(

        @NotNull
        String nowSeason
) {
}
