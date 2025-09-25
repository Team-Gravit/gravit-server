package gravit.code.auth.strategy;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
public class OAuthResponseFactory {
    private final Map<String, OAuthResponseStrategy> strategies;

    public OAuthResponseFactory(List<OAuthResponseStrategy> strategyList)
    {
        this.strategies = strategyList.stream()
                .collect(Collectors.toMap(OAuthResponseStrategy::getProviderName, Function.identity()));
    }

    public OAuthUserInfo createOAuthUserInfo(
            String registrationId,
            Map<String, Object> attributes
    ){
        OAuthResponseStrategy strategy = strategies.get(registrationId);
        if(Objects.equals(strategy,null))
            throw new RestApiException(CustomErrorCode.PROVIDER_INVALID);
        return strategy.createOAuthUserInfo(attributes);
    }
}
