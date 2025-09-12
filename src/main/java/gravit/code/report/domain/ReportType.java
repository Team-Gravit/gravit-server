package gravit.code.report.domain;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.Arrays;

@Getter
@AllArgsConstructor
public enum ReportType {

    TYPO_ERROR("TYPO_ERROR"),
    CONTENT_ERROR("CONTENT_ERROR"),
    ANSWER_ERROR("ANSWER_PROBLEM"),
    OTHER_ERROR("OTHER_PROBLEM");

    @JsonValue
    private final String type;

    @JsonCreator
    public static ReportType from(String type){
        return Arrays.stream(values())
                .filter(t -> t.type.equals(type))
                .findFirst()
                .orElseThrow(() -> new RestApiException(CustomErrorCode.REPORT_TYPE_NOT_AVAILABLE));
    }
}
