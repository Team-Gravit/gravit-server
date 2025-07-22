package gravit.code.user.dto.response;

import lombok.Builder;

@Builder
public record UserMainPageInfo(
        String nickname,
        Integer level,
        Integer xp
) {
}
