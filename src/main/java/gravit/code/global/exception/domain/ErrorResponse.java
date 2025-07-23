package gravit.code.global.exception.domain;

import lombok.Builder;

@Builder
public record ErrorResponse<T>(String error, T message) {
}
