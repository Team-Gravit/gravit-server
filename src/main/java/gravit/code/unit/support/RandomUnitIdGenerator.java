package gravit.code.unit.support;

import gravit.code.global.exception.domain.RestApiException;
import lombok.experimental.UtilityClass;

import java.util.Random;

import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;

@UtilityClass
public class RandomUnitIdGenerator {

    public static final int PICK_COUNT = 2;

    public static int[] pickTwoDistinctIndexes(
            long seed,
            int totalUnits
    ) {
        if (totalUnits < PICK_COUNT) {
            throw new RestApiException(UNIT_NOT_FOUND);
        }

        Random random = new Random(seed);

        int first = random.nextInt(totalUnits);
        int second;

        do {
            second = random.nextInt(totalUnits);
        } while (second == first);

        return new int[]{first, second};
    }
}
