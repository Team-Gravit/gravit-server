package gravit.code.domain.season.calendar.dto;

import gravit.code.domain.league.domain.League;

import java.time.LocalDateTime;

public record SeasonResponse(String seasonKey, LocalDateTime startsAt, LocalDateTime endsAt) {
}
