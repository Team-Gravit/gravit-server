package gravit.code.user.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.interview.service.InterviewAudioDeletionService;
import gravit.code.user.service.UserDeletionService;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class UserDeletionFacade {

    private final UserDeletionService userDeletionService;

    private final InterviewAudioDeletionService interviewAudioDeletionService;

    public boolean cleanUserDeletion(long userId) {
        if (!userDeletionService.isWithdrawn(userId)) {
            return false;
        }

        List<Long> voiceSessionIds = interviewAudioDeletionService.getVoiceSessionIds(userId);

        userDeletionService.cleanUserDeletion(userId);

        interviewAudioDeletionService.deleteAllBySessionIds(voiceSessionIds);

        return true;
    }
}
