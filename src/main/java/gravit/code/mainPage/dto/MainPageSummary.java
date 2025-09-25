package gravit.code.mainPage.dto;

public record MainPageSummary(
        String nickname,
        String leagueName,
        int xp,
        int level,
        int planetConquestRate,
        int consecutiveDays,
        long chapterId,
        String chapterName,
        String chapterDescription,
        long totalUnits,
        long completedUnits
) {
}
