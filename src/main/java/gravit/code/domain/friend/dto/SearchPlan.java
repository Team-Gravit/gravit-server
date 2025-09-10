package gravit.code.domain.friend.dto;

public record SearchPlan(
        String selectSql,
        String countSql,
        String cleanText,
        boolean isQueryNeedContains,
        boolean isEmpty
) {

    public static SearchPlan of(String selectSql, String countSql, String cleanText, boolean isQueryNeedContains) {
        return new SearchPlan(selectSql, countSql, cleanText, isQueryNeedContains, false);
    }

    public static SearchPlan empty(){
        return new SearchPlan(null,null,"",false,true);
    }
}
