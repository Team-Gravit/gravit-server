package gravit.code.badge.dto.internal;

public record BadgeCatalogRowDto(
        long categoryId,
        String categoryName,
        int categoryOrder,
        String categoryDescription,
        long badgeId,
        String code,
        String badgeName,
        String badgeDescription,
        int iconId,
        int badgeOrder
) {
}
