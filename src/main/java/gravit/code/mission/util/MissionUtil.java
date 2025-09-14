package gravit.code.mission.util;

import gravit.code.mission.domain.MissionType;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public final class MissionUtil {

    private static final Random random = new Random();
    
    private MissionUtil(){}
    
    public static MissionType getRandomMissionType(){
        List<MissionType> ticketPool = new ArrayList<>();
        
        for (MissionType mission : MissionType.values()) {
            for (int i = 0; i < mission.getTicket(); i++) {
                ticketPool.add(mission);
            }
        }
        
        int randomIndex = random.nextInt(ticketPool.size());
        return ticketPool.get(randomIndex);
    }
}
