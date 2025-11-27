package gravit.code.badge.dto.response;

import jakarta.validation.constraints.NotNull;
import java.util.List;

public record AllBadgesResponse(

        int earnedCount,
        int totalCount,
        @NotNull
        List<BadgeCategoryResponse> badgeCategoryResponses
){
}
