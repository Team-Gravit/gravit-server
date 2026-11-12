package gravit.code.test.fixture.dto.internal;

import gravit.code.test.fixture.dto.response.QaPersonaManifestResponse;

import java.util.List;

public record QaFixtureLoadResultDto(
        List<QaPersonaManifestResponse> personas,

        List<QaRankMemberDto> rankMembers,

        long withdrawingUserId
) {
}
