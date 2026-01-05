package gravit.code.season.calendar.dto;

import java.time.LocalDateTime;

public record SeasonDto(
        String seasonKey,
        LocalDateTime startsAt,
        LocalDateTime endsAt
) {
}
