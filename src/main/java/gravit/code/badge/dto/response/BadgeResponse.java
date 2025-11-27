package gravit.code.badge.dto.response;

import jakarta.validation.constraints.NotNull;

public record BadgeResponse(

        long badgeId,
        @NotNull
        String code,
        @NotNull
        String name,
        @NotNull
        String description,
        int order,
        int iconId,
        boolean earned
) {
}
