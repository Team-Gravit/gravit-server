package gravit.code.interviewQuestion.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum InterviewDifficulty {

    EASY("하"),
    NORMAL("중"),
    HARD("상");

    private final String displayName;
}
