package gravit.code.common.exception;

import lombok.Builder;

@Builder
public record ErrorResponse<T>(String error, T message) {
}
