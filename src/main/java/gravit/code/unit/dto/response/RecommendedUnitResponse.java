package gravit.code.unit.dto.response;

public record RecommendedUnitResponse(
        long unitId,
        String unitTitle,
        long chapterId,
        String chapterTitle
) {
}