package gravit.code.badge.dto.response;

public record BadgeResponse(
        Long badgeId,
        String code,
        String name,
        String description,
        int order,
        int iconId,
        boolean earned
) {
}
