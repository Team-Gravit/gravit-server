package gravit.code.interview.domain;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;

@RequiredArgsConstructor
public enum InterviewSessionSort {

    LATEST(Sort.Direction.DESC),
    OLDEST(Sort.Direction.ASC);

    private static final String STARTED_AT = "startedAt";
    private static final String ID = "id";

    private final Sort.Direction direction;

    public Sort toSort() {
        return Sort.by(direction, STARTED_AT, ID);
    }
}
