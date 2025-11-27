package gravit.code.badge.dto.response;

import jakarta.validation.constraints.NotNull;
import java.util.List;

public record BadgeCategoryResponse(

        long categoryId,
        @NotNull
        String categoryName,
        int order,
        @NotNull
        String categoryDescription,
        @NotNull
        List<BadgeResponse> badgeResponses
) {
}
