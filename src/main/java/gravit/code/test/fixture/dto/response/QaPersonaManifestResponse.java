package gravit.code.test.fixture.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record QaPersonaManifestResponse(

        @Schema(
                description = "페르소나 키 (gravit-qa PersonaKey와 같음)",
                example = "learner"
        )
        String personaKey,

        @Schema(
                description = "이번 적재에서 발급된 유저 ID. 재적재마다 바뀐다",
                example = "123"
        )
        long userId,

        @Schema(
                description = "페르소나 상태 요약",
                example = "최근 14일 제출 이력(정답, 오답 혼합), 오답노트, 북마크, 주간 기록"
        )
        String description
) {
    public static QaPersonaManifestResponse of(
            String personaKey,
            long userId,
            String description
    ) {
        return QaPersonaManifestResponse.builder()
                .personaKey(personaKey)
                .userId(userId)
                .description(description)
                .build();
    }
}
