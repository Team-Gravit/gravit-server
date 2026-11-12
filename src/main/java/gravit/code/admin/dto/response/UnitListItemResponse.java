package gravit.code.admin.dto.response;

import gravit.code.unit.domain.Unit;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UnitListItemResponse(

        long unitId,

        String title,

        String description
) {
    public static UnitListItemResponse from(Unit unit) {
        return UnitListItemResponse.builder()
                .unitId(unit.getId())
                .title(unit.getTitle())
                .description(unit.getDescription())
                .build();
    }
}
