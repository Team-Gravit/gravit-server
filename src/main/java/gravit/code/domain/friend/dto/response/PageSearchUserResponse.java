package gravit.code.domain.friend.dto.response;

import lombok.Builder;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

@Slf4j
@Builder
public record PageSearchUserResponse(
        long pages,
        long total,
        boolean hasNext,
        List<SearchUser> searchUsers
){
    public static PageSearchUserResponse of(int page, int size, long total,  List<SearchUser> searchUsers){
        long pages = (total == 0) ? 0 : ((total + size - 1) / size);
        log.info("pages: {}", pages);
        boolean hasNext = (page + 1) < pages;
        log.info("hasNext: {}", hasNext);

        return PageSearchUserResponse.builder()
                .pages(pages)
                .total(total)
                .hasNext(hasNext)
                .searchUsers(searchUsers == null ? List.of() : searchUsers)
                .build();
    }

    public static PageSearchUserResponse empty() {
        return PageSearchUserResponse.builder()
                .pages(0).total(0).hasNext(false).searchUsers(List.of())
                .build();
    }
}
