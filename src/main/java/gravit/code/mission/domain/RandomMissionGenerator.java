package gravit.code.mission.domain;

import lombok.experimental.UtilityClass;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@UtilityClass
public class RandomMissionGenerator {

    private static final Random random = new Random();
    
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
