package gravit.code.global.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.data.domain.Page;

import java.util.List;

public record PageResponse<T>(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int page,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int totalPages,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean hasNext,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long totalElements,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<T> contents
) {
    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getNumber() + 1,
                page.getTotalPages(),
                page.hasNext(),
                page.getTotalElements(),
                page.getContent()
        );
    }
}
