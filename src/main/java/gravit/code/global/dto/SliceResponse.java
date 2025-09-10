package gravit.code.global.dto;

import lombok.Builder;

import java.util.List;

@Builder
public record SliceResponse<T>(
        boolean hasNextPage,
        List<T> contents
){
    public static <T> SliceResponse<T> of(boolean hasNextPage, List<T> contents) {
        return SliceResponse.<T>builder()
                .hasNextPage(hasNextPage)
                .contents(contents)
                .build();
    }

    public static <T> SliceResponse<T> empty() {
        return SliceResponse.<T>builder()
                .hasNextPage(false)
                .contents(List.of())
                .build();
    }
}
