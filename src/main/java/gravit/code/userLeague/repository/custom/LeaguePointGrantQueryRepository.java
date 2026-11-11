package gravit.code.userLeague.repository.custom;

import gravit.code.userLeague.dto.internal.UngrantedLessonSubmissionDto;

import java.time.LocalDateTime;
import java.util.List;

public interface LeaguePointGrantQueryRepository {

    List<UngrantedLessonSubmissionDto> findUngrantedFirstLessonSubmissions(
            LocalDateTime since,
            LocalDateTime until,
            int limit
    );
}
