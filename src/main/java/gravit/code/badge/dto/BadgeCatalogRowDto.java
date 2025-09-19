package gravit.code.badge.dto;

public record BadgeCatalogRowDto(
        Long categoryId,
        String categoryName,
        int categoryOrder,
        Long badgeId,
        String code,
        String badgeName,
        String description,
        int iconId,
        int badgeOrder
) {
}
