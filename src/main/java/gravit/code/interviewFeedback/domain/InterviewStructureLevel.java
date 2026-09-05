package gravit.code.interviewFeedback.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum InterviewStructureLevel {

    CONCLUSION_FIRST(3),
    CONCLUSION_REACHED(2),
    UNCLEAR(1);

    private final int score;
}
