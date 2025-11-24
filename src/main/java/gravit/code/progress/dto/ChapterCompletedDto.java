package gravit.code.progress.dto;

public record ChapterCompletedDto(
        long before,
        long after,
        long totalUnits
) {
}
