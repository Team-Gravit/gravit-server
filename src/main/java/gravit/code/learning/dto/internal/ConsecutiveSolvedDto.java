package gravit.code.learning.dto.internal;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ConsecutiveSolvedDto(
        int before,

        int after
) {
    public static ConsecutiveSolvedDto of(
            int before,
            int after
    ) {
        return ConsecutiveSolvedDto.builder()
                .before(before)
                .after(after)
                .build();
    }
}
