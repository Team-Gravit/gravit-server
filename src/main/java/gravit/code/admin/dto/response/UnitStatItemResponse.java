package gravit.code.admin.dto.response;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UnitStatItemResponse(

        long unitId,

        String unitTitle,

        int averageProgress,

        long participantCount
) {
    public static UnitStatItemResponse of(
            long unitId,
            String unitTitle,
            int averageProgress,
            long participantCount
    ) {
        return UnitStatItemResponse.builder()
                .unitId(unitId)
                .unitTitle(unitTitle)
                .averageProgress(averageProgress)
                .participantCount(participantCount)
                .build();
    }
}
