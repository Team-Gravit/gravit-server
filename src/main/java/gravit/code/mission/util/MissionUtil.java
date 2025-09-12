package gravit.code.mission.util;

import gravit.code.mission.domain.MissionType;

import java.util.Random;

public final class MissionUtil {

    private static final Random random = new Random();
    
    private MissionUtil(){}

    public static MissionType getRandomMissionType(){
        MissionType[] allMissions = MissionType.values();
        int randomIndex = random.nextInt(allMissions.length);
        return allMissions[randomIndex];
    }
}
