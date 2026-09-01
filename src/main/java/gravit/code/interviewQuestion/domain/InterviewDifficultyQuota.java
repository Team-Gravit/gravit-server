package gravit.code.interviewQuestion.domain;

import gravit.code.interview.domain.InterviewLevel;
import gravit.code.interview.domain.InterviewSession;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public enum InterviewDifficultyQuota {

    LOW(3, 2, 0),
    MEDIUM(1, 3, 1),
    HIGH(0, 2, 3);

    private final int lowCount;
    private final int mediumCount;
    private final int highCount;

    InterviewDifficultyQuota(
            int lowCount,
            int mediumCount,
            int highCount
    ) {
        if (lowCount + mediumCount + highCount != InterviewSession.QUESTION_COUNT) {
            throw new IllegalStateException("면접 난이도 구성의 합이 세션 문항 수와 다릅니다.");
        }

        this.lowCount = lowCount;
        this.mediumCount = mediumCount;
        this.highCount = highCount;
    }

    public static InterviewDifficultyQuota from(InterviewLevel level) {
        return InterviewDifficultyQuota.valueOf(level.name());
    }

    private int countOf(InterviewDifficulty difficulty) {
        return switch (difficulty) {
            case LOW -> lowCount;
            case MEDIUM -> mediumCount;
            case HIGH -> highCount;
        };
    }

    public List<InterviewDifficulty> toSlots() {
        List<InterviewDifficulty> slots = new ArrayList<>();

        for (InterviewDifficulty difficulty : ascendingDifficulties()) {
            slots.addAll(Collections.nCopies(countOf(difficulty), difficulty));
        }

        return slots;
    }

    public static List<InterviewDifficulty> ascendingDifficulties() {
        return List.of(InterviewDifficulty.LOW, InterviewDifficulty.MEDIUM, InterviewDifficulty.HIGH);
    }
}
