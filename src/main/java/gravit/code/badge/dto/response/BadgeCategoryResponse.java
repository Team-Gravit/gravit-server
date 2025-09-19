package gravit.code.badge.dto.response;

import java.util.List;

public record BadgeCategoryResponse(
        Long categoryId,
        String categoryName,
        int order,
        List<BadgeResponse> badgeResponses
) {
}
