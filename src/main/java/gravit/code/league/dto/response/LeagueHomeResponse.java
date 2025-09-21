package gravit.code.league.dto.response;

import gravit.code.league.dto.CurrentSeasonDto;
import gravit.code.league.dto.LastSeasonPopupDto;

public record LeagueHomeResponse(
        boolean containsPopup,
        CurrentSeasonDto currentSeason,
        LastSeasonPopupDto lastSeasonPopupDto
) {
    public static LeagueHomeResponse normal(
            CurrentSeasonDto currentSeasonDto
    ) {
        return new LeagueHomeResponse(false, currentSeasonDto, null);
    }

    public static LeagueHomeResponse withPopup(
            CurrentSeasonDto currentSeasonDto,
            LastSeasonPopupDto lastSeasonPopupDto
    ) {
        return new LeagueHomeResponse(true, currentSeasonDto, lastSeasonPopupDto);
    }
}
