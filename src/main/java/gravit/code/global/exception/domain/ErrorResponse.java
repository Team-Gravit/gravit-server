package gravit.code.global.exception.domain;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ErrorResponse<T>(String error, T message) {

    public static <T> ErrorResponse<T> of(String error, T message) {
        return new ErrorResponse<>(error, message);
    }
}
