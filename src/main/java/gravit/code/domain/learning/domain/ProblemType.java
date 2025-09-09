package gravit.code.domain.learning.domain;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Arrays;

@Getter
@AllArgsConstructor
public enum ProblemType {

    SUBJECTIVE("subjective"),
    OBJECTIVE("objective");

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
