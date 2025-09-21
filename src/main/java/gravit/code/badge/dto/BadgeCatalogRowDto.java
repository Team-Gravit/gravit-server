package gravit.code.badge.dto;

public record BadgeCatalogRowDto(
        long categoryId,
        String categoryName,
        int categoryOrder,
        long badgeId,
        String code,
        String badgeName,
        String description,
        int iconId,
        int badgeOrder
) {
}
