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
        List<Long> voiceSessionIds = interviewAudioDeletionService.getVoiceSessionIds(userId);

        if (!userDeletionService.cleanUserDeletion(userId)) {
            return false;
        }

        interviewAudioDeletionService.deleteAllBySessionIds(voiceSessionIds);

        return true;
    }
}
