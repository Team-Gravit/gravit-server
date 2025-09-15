package gravit.code.report.domain;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Arrays;

@Getter
@AllArgsConstructor
public enum ReportType {

    TYPO_ERROR("TYPO_ERROR"),
    CONTENT_ERROR("CONTENT_ERROR"),
    ANSWER_ERROR("ANSWER_ERROR"),
    OTHER_ERROR("OTHER_ERROR");

    @JsonValue
    private final String type;

    @JsonCreator
    public static ReportType from(String type){
        return Arrays.stream(values())
                .filter(t -> t.type.equals(type))
                .findFirst()
                .orElse(null);
    }
}
