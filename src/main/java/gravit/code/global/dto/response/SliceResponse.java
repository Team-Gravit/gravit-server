package gravit.code.global.dto.response;

import lombok.Builder;
import org.springframework.data.domain.Slice;

import java.util.List;

@Builder
public record SliceResponse<T>(
        boolean hasNextPage,
        List<T> contents
){
    public static <T> SliceResponse<T> of(
            boolean hasNextPage,
            List<T> contents
    ) {
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

    public static <T> SliceResponse<T> of(Slice<T> slice) {
        return SliceResponse.<T>builder()
                .hasNextPage(slice.hasNext())
                .contents(slice.getContent())
                .build();
    }
}
