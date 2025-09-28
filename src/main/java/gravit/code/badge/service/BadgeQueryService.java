package gravit.code.badge.service;

import gravit.code.badge.dto.BadgeCatalogRowDto;
import gravit.code.badge.dto.response.AllBadgesResponse;
import gravit.code.badge.dto.response.BadgeCategoryResponse;
import gravit.code.badge.dto.response.BadgeResponse;
import gravit.code.badge.infrastructure.BadgeRepository;
import gravit.code.badge.infrastructure.user.UserBadgeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class BadgeQueryService {
    private final BadgeRepository badgeRepository;
    private final UserBadgeRepository userBadgeRepository;

    public AllBadgesResponse getAllMyBadges(long userId) {

        // 1. 정렬된 카탈로그들
        List<BadgeCatalogRowDto> rows = badgeRepository.findCatalogOrdered();

        // 2. 유저가 획득한 뱃지
        Set<Long> earnedBadgeIds = new HashSet<>(userBadgeRepository.findBadgeIdsByUserId(userId));

        record CatKey(Long id, String name, int order, String description) {
        }

        Map<CatKey, List<BadgeCatalogRowDto>> byCategory = rows.stream()
                .collect(Collectors.groupingBy(
                        r -> new CatKey(r.categoryId(), r.categoryName(), r.categoryOrder(), r.categoryDescription()),
                        LinkedHashMap::new, Collectors.toList()));

        List<BadgeCategoryResponse> categories = byCategory.entrySet().stream()
                .map(e -> {
                    CatKey key = e.getKey();
                    List<BadgeResponse> badgeResponses = e.getValue().stream()
                            .map(r -> new BadgeResponse(
                                    r.badgeId(), r.code(), r.badgeName(), r.badgeDescription(), r.badgeOrder(), r.iconId(), earnedBadgeIds.contains(r.badgeId())
                            )).toList();
                    return new BadgeCategoryResponse(key.id, key.name, key.order, key.description, badgeResponses);
                }).toList();

        int total = rows.size();
        int earned = (int) rows.stream().filter(r-> earnedBadgeIds.contains(r.badgeId())).count();

        return new AllBadgesResponse(earned, total, categories);
    }
}
