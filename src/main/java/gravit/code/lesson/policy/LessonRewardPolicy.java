package gravit.code.lesson.policy;

import org.springframework.stereotype.Component;

@Component
public class LessonRewardPolicy {

    public static final int BASE_REWARD_POINTS = 20;

    public int calculate(
            int basePoints,
            int accuracy
    ) {
        return (int) Math.round(basePoints * accuracy * 0.01);
    }
}
