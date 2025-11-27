package gravit.code.friend.dto;

public record SearchPlan(

        String selectSql,
        String cleanText,
        boolean isQueryNeedContains,
        boolean isEmpty
) {

    public static SearchPlan of(
            String selectSql,
            String cleanText,
            boolean isQueryNeedContains
    ) {
        return new SearchPlan(selectSql, cleanText, isQueryNeedContains, false);
    }

    public static SearchPlan empty(){
        return new SearchPlan(null,"",false,true);
    }
}
