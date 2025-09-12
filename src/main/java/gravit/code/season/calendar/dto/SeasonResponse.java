package gravit.code.season.calendar.dto;

import java.time.LocalDateTime;

public record SeasonResponse(String seasonKey, LocalDateTime startsAt, LocalDateTime endsAt) {
}
