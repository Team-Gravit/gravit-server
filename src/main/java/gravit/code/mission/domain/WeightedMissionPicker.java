package gravit.code.mission.domain;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Random;

@Component
public class WeightedMissionPicker {

    private final Random random = new Random();

    public Mission pick(List<Mission> missions) {
        int totalWeight = 0;
        for (Mission mission : missions) {
            totalWeight += mission.getWeight();
        }

        if (totalWeight <= 0)
            throw new RestApiException(CustomErrorCode.MISSION_NOT_FOUND);

        int point = random.nextInt(totalWeight);
        for (Mission mission : missions) {
            point -= mission.getWeight();
            if (point < 0)
                return mission;
        }

        throw new RestApiException(CustomErrorCode.MISSION_NOT_FOUND);
    }
}
