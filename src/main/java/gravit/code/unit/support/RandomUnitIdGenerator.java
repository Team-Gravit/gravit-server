package gravit.code.unit.support;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.experimental.UtilityClass;

import java.util.Random;

@UtilityClass
public class RandomUnitIdGenerator {

    public static int[] pickTwoDistinctIndexes(
            long seed,
            int totalUnits
    ) {
        if (totalUnits < 2) {
            throw new RestApiException(CustomErrorCode.UNIT_NOT_FOUND);
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
