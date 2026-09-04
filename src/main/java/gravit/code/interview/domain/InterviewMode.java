package gravit.code.interview.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum InterviewMode {

    COMMON_CS(
            "CS(Computer Science)",
            "자료 구조, 알고리즘 등 CS 5개 분야 중 원하는 주제를 골라 연습해요.",
            1
    ),
    JOB_SPECIFIC(
            "직군 특화 주제",
            "준비하는 직군에 맞춰 프레임워크, 언어까지 깊이 있게 물어봐요.",
            2
    );

    private final String displayName;
    private final String description;
    private final int displayOrder;
}
