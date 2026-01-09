package gravit.code.friend.dto;

public record SearchPlanDto(
        String selectSql,
        String cleanText,
        boolean isQueryNeedContains,
        boolean isEmpty
) {

    public static SearchPlanDto of(
            String selectSql,
            String cleanText,
            boolean isQueryNeedContains
    ) {
        return new SearchPlanDto(selectSql, cleanText, isQueryNeedContains, false);
    }

    public static SearchPlanDto empty(){
        return new SearchPlanDto(null, "", false, true);
    }
}
