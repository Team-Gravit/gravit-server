package gravit.code.test.fixture.support;

import gravit.code.global.exception.domain.RestApiException;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;

import static gravit.code.global.exception.domain.CustomErrorCode.QA_FIXTURE_SET_INVALID;

@Getter
@RequiredArgsConstructor
public enum QaFixtureSet {

    AUTO("auto"),
    MANUAL("manual");

    private static final String PROVIDER_ID_PREFIX_FORMAT = "qa-persona-%s-";

    private final String key;

    public static QaFixtureSet from(String key) {
        return Arrays.stream(values())
                .filter(set -> set.key.equals(key))
                .findFirst()
                .orElseThrow(() -> new RestApiException(QA_FIXTURE_SET_INVALID));
    }

    public String providerIdPrefix() {
        return PROVIDER_ID_PREFIX_FORMAT.formatted(key);
    }
}
