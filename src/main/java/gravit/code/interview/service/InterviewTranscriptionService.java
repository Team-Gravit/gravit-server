package gravit.code.interview.service;

import gravit.code.interview.infrastructure.InterviewAudioStorage;
import gravit.code.interview.infrastructure.InterviewTranscriptionClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewTranscriptionService {

    private final InterviewAudioStorage interviewAudioStorage;
    private final InterviewTranscriptionClient interviewTranscriptionClient;

    public String transcribe(
            String audioKey,
            List<String> conceptNames
    ) {
        byte[] audio = interviewAudioStorage.download(audioKey);

        return interviewTranscriptionClient.transcribe(audioKey, audio, conceptNames);
    }
}
