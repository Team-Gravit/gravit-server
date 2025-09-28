package gravit.code.badge.dto.response;

import java.util.List;

public record BadgeCategoryResponse(
        long categoryId,
        String categoryName,
        int order,
        String categoryDescription,
        List<BadgeResponse> badgeResponses
) {
}
