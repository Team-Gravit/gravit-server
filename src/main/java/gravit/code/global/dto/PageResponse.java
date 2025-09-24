package gravit.code.global.dto;

import org.springframework.data.domain.Page;

import java.util.List;

public record PageResponse<T>(
        int page,
        int totalPages,
        boolean hasNext,
        List<T> contents
) {
    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getNumber() + 1,
                page.getTotalPages(),
                page.hasNext(),
                page.getContent()
        );
    }
}
