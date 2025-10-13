package gravit.code.learning.dto;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record StreakDto(
        int before,
        int after
) {
    public static StreakDto of(int before, int after) {
        return StreakDto.builder()
                .before(before)
                .after(after)
                .build();
    }
}
