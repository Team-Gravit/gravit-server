package gravit.code.auth.domain;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.Collections;
import java.util.Map;

@Getter
public class LoginUser implements OAuth2User {

    private final Long id;
    private final String provider;
    private final Map<String, Object> attributes;
    private final Collection<? extends GrantedAuthority> authorities;

    public LoginUser(
            Long id,
            String provider,
            Map<String, Object> attributes,
            Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.provider = provider;
        this.attributes = attributes;
        this.authorities = (authorities == null) ? Collections.emptyList() : authorities;
    }

    @Override
    public Map<String, Object> getAttributes() {
        return attributes;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getName() {
        return String.valueOf(id);
    }
}
