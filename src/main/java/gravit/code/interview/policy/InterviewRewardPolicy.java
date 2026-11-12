package gravit.code.interview.policy;

import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Component
public class InterviewRewardPolicy {

    private static final BigDecimal BASE_REWARD_POINTS = BigDecimal.valueOf(30);
    private static final int REWARD_SCALE = 0;

    public int calculate(
            int score,
            int maxScore
    ) {
        return BASE_REWARD_POINTS.multiply(BigDecimal.valueOf(score))
                .divide(BigDecimal.valueOf(maxScore), REWARD_SCALE, RoundingMode.HALF_UP)
                .intValue();
    }
}
