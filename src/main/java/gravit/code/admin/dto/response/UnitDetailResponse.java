package gravit.code.admin.dto.response;

import gravit.code.unit.domain.Unit;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UnitDetailResponse(

        long unitId,

        long chapterId,

        String title,

        String description,

        long lessonCount
) {
    public static UnitDetailResponse of(
            Unit unit,
            long lessonCount
    ) {
        return UnitDetailResponse.builder()
                .unitId(unit.getId())
                .chapterId(unit.getChapterId())
                .title(unit.getTitle())
                .description(unit.getDescription())
                .lessonCount(lessonCount)
                .build();
    }
}
