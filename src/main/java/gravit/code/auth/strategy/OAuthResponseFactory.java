package gravit.code.auth.strategy;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.strategy.support.OAuthUserInfoValidator;
import gravit.code.global.exception.domain.RestApiException;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;

@Component
public class OAuthResponseFactory {
    private final Map<String, OAuthResponseStrategy> registrationIdToStrategy;

    public OAuthResponseFactory(List<OAuthResponseStrategy> strategyList)
    {
        this.registrationIdToStrategy = strategyList.stream()
                .collect(Collectors.toMap(OAuthResponseStrategy::getProviderName, Function.identity()));
    }

    public OAuthUserInfo createOAuthUserInfo(
            String registrationId,
            Map<String, Object> attributes
    ){
        OAuthResponseStrategy strategy = registrationIdToStrategy.get(registrationId);
        if(Objects.equals(strategy,null))
            throw new RestApiException(PROVIDER_INVALID);

        OAuthUserInfo userInfo = strategy.createOAuthUserInfo(attributes);
        OAuthUserInfoValidator.validate(userInfo);

        return userInfo;
    }
}
