package gravit.code.badge.dto.response;

import java.util.List;

public record AllBadgesResponse(
        int earnedCount,
        int totalCount,
        List<BadgeCategoryResponse> badgeCategoryResponses
){
}
