package gravit.code.report.domain;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Arrays;

@Getter
@AllArgsConstructor
public enum UserReportType {

    INAPPROPRIATE_NICKNAME("INAPPROPRIATE_NICKNAME"),
    OTHER("OTHER");

    @JsonValue
    private final String type;

    @JsonCreator
    public static UserReportType from(String type) {
        return Arrays.stream(values())
                .filter(t -> t.type.equals(type))
                .findFirst()
                .orElse(null);
    }
}
