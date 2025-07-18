package gravit.code.common.exception.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum CustomErrorCode implements ErrorCode {

    LESSON_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4041", "레슨 조회 실패");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;
}