package gravit.code.admin.dto.response;

import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record ChapterStatsResponse(

        List<UnitStatItemResponse> units
) {
    public static ChapterStatsResponse of(List<UnitStatItemResponse> units) {
        return ChapterStatsResponse.builder()
                .units(units)
                .build();
    }
}
