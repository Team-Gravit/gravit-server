package gravit.code.common.auth.oauth.startegy;

import gravit.code.common.auth.oauth.dto.OAuthUserInfo;
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

    public OAuthUserInfo createOAuthUserInfo(String registrationId, Map<String, Object> attributes){
        OAuthResponseStrategy strategy = strategies.get(registrationId);
        System.out.println(strategy);
        if(Objects.equals(strategy,null)) throw new IllegalStateException("지원하지 않는 provider 입니다.");
        return strategy.createOAuthUserInfo(attributes);
    }
}
