package gravit.code.common.exception.domain;

import lombok.Builder;

@Builder
public record ErrorResponse<T>(String error, T message) {
}
