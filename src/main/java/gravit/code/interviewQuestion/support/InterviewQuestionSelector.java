package gravit.code.interviewQuestion.support;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewDifficultyQuota;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolItem;
import lombok.experimental.UtilityClass;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@UtilityClass
public class InterviewQuestionSelector {

    private static final Map<InterviewDifficulty, List<InterviewDifficulty>> SUBSTITUTE_ORDER = Map.of(
            InterviewDifficulty.LOW, List.of(InterviewDifficulty.MEDIUM, InterviewDifficulty.HIGH),
            InterviewDifficulty.MEDIUM, List.of(InterviewDifficulty.LOW, InterviewDifficulty.HIGH),
            InterviewDifficulty.HIGH, List.of(InterviewDifficulty.MEDIUM, InterviewDifficulty.LOW)
    );

    public static List<Long> select(
            List<InterviewQuestionPoolItem> pool,
            List<Long> requiredCategoryIds,
            InterviewDifficultyQuota quota
    ) {
        if (pool.size() < InterviewSession.QUESTION_COUNT) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }

        List<InterviewQuestionPoolItem> remaining = new ArrayList<>(pool);
        Collections.shuffle(remaining);

        List<InterviewDifficulty> slots = new ArrayList<>(quota.toSlots());
        List<InterviewQuestionPoolItem> selected = new ArrayList<>();
        Map<Long, Integer> pickedCountByCategory = new HashMap<>();

        reserveRequiredCategories(remaining, requiredCategoryIds, slots, selected, pickedCountByCategory);

        fillRemainingSlots(remaining, slots, selected, pickedCountByCategory);

        return selected.stream()
                .sorted(Comparator.comparingInt(item -> difficultyOrder(item.difficulty())))
                .map(InterviewQuestionPoolItem::questionId)
                .toList();
    }

    private static void reserveRequiredCategories(
            List<InterviewQuestionPoolItem> remaining,
            List<Long> requiredCategoryIds,
            List<InterviewDifficulty> slots,
            List<InterviewQuestionPoolItem> selected,
            Map<Long, Integer> pickedCountByCategory
    ) {
        List<Long> orderedCategoryIds = requiredCategoryIds.stream()
                .distinct()
                .sorted(Comparator.comparingLong(categoryId -> countOfCategory(remaining, categoryId)))
                .toList();

        for (Long categoryId : orderedCategoryIds) {
            List<InterviewQuestionPoolItem> candidates = remaining.stream()
                    .filter(item -> item.categoryId() == categoryId)
                    .toList();

            if (candidates.isEmpty() || slots.isEmpty()) {
                throw new RestApiException(CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT);
            }

            InterviewDifficulty slot = chooseSlotFor(slots, candidates);

            take(remaining, selected, pickedCountByCategory, pickFrom(candidates, slot));
            slots.remove(slot);
        }
    }

    private static void fillRemainingSlots(
            List<InterviewQuestionPoolItem> remaining,
            List<InterviewDifficulty> slots,
            List<InterviewQuestionPoolItem> selected,
            Map<Long, Integer> pickedCountByCategory
    ) {
        List<InterviewDifficulty> orderedSlots = slots.stream()
                .sorted(Comparator.comparingInt(InterviewQuestionSelector::difficultyOrder))
                .toList();

        for (InterviewDifficulty slot : orderedSlots) {
            InterviewQuestionPoolItem picked = pickLeastPickedCategory(
                    candidatesFor(remaining, slot),
                    pickedCountByCategory
            );

            take(remaining, selected, pickedCountByCategory, picked);
        }
    }

    private static InterviewDifficulty chooseSlotFor(
            List<InterviewDifficulty> slots,
            List<InterviewQuestionPoolItem> candidates
    ) {
        return slots.stream()
                .filter(slot -> hasDifficulty(candidates, slot))
                .min(Comparator.comparingInt(InterviewQuestionSelector::difficultyOrder))
                .orElseGet(() -> slots.stream()
                        .min(Comparator.comparingInt(InterviewQuestionSelector::difficultyOrder))
                        .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT)));
    }

    private static InterviewQuestionPoolItem pickFrom(
            List<InterviewQuestionPoolItem> candidates,
            InterviewDifficulty difficulty
    ) {
        for (InterviewDifficulty target : searchOrder(difficulty)) {
            for (InterviewQuestionPoolItem candidate : candidates) {
                if (candidate.difficulty() == target) {
                    return candidate;
                }
            }
        }

        throw new RestApiException(CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT);
    }

    private static List<InterviewQuestionPoolItem> candidatesFor(
            List<InterviewQuestionPoolItem> remaining,
            InterviewDifficulty difficulty
    ) {
        for (InterviewDifficulty target : searchOrder(difficulty)) {
            List<InterviewQuestionPoolItem> candidates = remaining.stream()
                    .filter(item -> item.difficulty() == target)
                    .toList();

            if (!candidates.isEmpty()) {
                return candidates;
            }
        }

        throw new RestApiException(CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT);
    }

    private static InterviewQuestionPoolItem pickLeastPickedCategory(
            List<InterviewQuestionPoolItem> candidates,
            Map<Long, Integer> pickedCountByCategory
    ) {
        InterviewQuestionPoolItem picked = candidates.getFirst();
        int pickedCount = pickedCountByCategory.getOrDefault(picked.categoryId(), 0);

        for (InterviewQuestionPoolItem candidate : candidates) {
            int candidateCount = pickedCountByCategory.getOrDefault(candidate.categoryId(), 0);

            if (candidateCount < pickedCount) {
                picked = candidate;
                pickedCount = candidateCount;
            }
        }

        return picked;
    }

    private static void take(
            List<InterviewQuestionPoolItem> remaining,
            List<InterviewQuestionPoolItem> selected,
            Map<Long, Integer> pickedCountByCategory,
            InterviewQuestionPoolItem picked
    ) {
        remaining.remove(picked);
        selected.add(picked);
        pickedCountByCategory.merge(picked.categoryId(), 1, Integer::sum);
    }

    private static List<InterviewDifficulty> searchOrder(InterviewDifficulty difficulty) {
        List<InterviewDifficulty> order = new ArrayList<>();
        order.add(difficulty);
        order.addAll(SUBSTITUTE_ORDER.get(difficulty));

        return order;
    }

    private static boolean hasDifficulty(
            List<InterviewQuestionPoolItem> candidates,
            InterviewDifficulty difficulty
    ) {
        return candidates.stream().anyMatch(candidate -> candidate.difficulty() == difficulty);
    }

    private static long countOfCategory(
            List<InterviewQuestionPoolItem> pool,
            long categoryId
    ) {
        return pool.stream()
                .filter(item -> item.categoryId() == categoryId)
                .count();
    }

    private static int difficultyOrder(InterviewDifficulty difficulty) {
        return InterviewDifficultyQuota.ascendingDifficulties().indexOf(difficulty);
    }
}
