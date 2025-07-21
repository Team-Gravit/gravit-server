package gravit.code.auth.oauth.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OAuthServiceFactory {
    private final List<OAuthLoginService> services;

    public OAuthLoginService getService(String provider){
        return services.stream()
                .filter(s -> s.supports(provider))
                .findFirst()
                .orElseThrow(()-> new IllegalArgumentException());
    }
}
