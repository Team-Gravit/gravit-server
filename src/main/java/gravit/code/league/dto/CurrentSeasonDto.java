package gravit.code.league.dto;

import jakarta.validation.constraints.NotNull;

public record CurrentSeasonDto(

        @NotNull
        String nowSeason
) {
}
