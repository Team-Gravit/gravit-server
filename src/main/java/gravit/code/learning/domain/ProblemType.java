package gravit.code.learning.domain;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Arrays;

@Getter
@AllArgsConstructor
public enum ProblemType {

    FILL_BLANK("FILL_BLANK"), // 빈칸 문제
    SELECT_DESCRIPTION("SELECT_DESCRIPTION"); // 설명에 대한 답 작성/선택 문제

    @JsonValue
    private final String type;

    @JsonCreator
    public static ProblemType from(String type) {
        return Arrays.stream(values())
                .filter(t -> t.type.equals(type))
                .findFirst()
                .orElse(null);
    }
}
