package gravit.code.auth.token;

import gravit.code.auth.domain.LoginUser;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.token.config.JwtProperties;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.SignatureException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Map;
import java.util.function.Function;

import static io.jsonwebtoken.Jwts.SIG.HS256;

@Component
@Slf4j
public class JwtProvider {

    private final SecretKey secretKey;

    public JwtProvider(JwtProperties jwtProperties) {
        this.secretKey = new SecretKeySpec(jwtProperties.secret().getBytes(StandardCharsets.UTF_8), "HmacSHA256");
    }

    public String generateToken(Subject subject, Map<String, String> claims, Duration expireTime) {
        Date now = new Date();
        Date expiredDate = new Date(now.getTime() + expireTime.toMillis());
        return Jwts.builder()
                .subject(subject.value())
                .claims(claims)
                .issuedAt(now)
                .expiration(expiredDate)
                .signWith(secretKey, HS256)
                .compact();
    }

    public String generateToken(Subject subject, Duration expireTime) {
        Date date = new Date();
        Date expiredDate = new Date(date.getTime() + expireTime.toMillis());
        return Jwts.builder()
                .subject(subject.value())
                .issuedAt(date)
                .expiration(expiredDate)
                .signWith(secretKey, HS256)
                .compact();
    }

    public Subject parseSubject(String token) {
        String subject = extractClaims(token).getSubject();
        return new Subject(subject);
    }

    public Authentication getAuthentication(User user){
        Collection<? extends GrantedAuthority> authorities = Collections.singleton(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()));

        LoginUser loginUser = new LoginUser(user.getId(),user.getProviderId(),null, authorities);

        return new UsernamePasswordAuthenticationToken(loginUser, "",
                loginUser.getAuthorities());
    }

    public Long getUserId(String token) {
        String subject = extractClaims(token).getSubject();
        return Long.parseLong(subject);
    }

    private Claims extractClaims(String token) {
        return handleJwtException(token, (value) ->
                Jwts.parser()
                        .verifyWith(secretKey)
                        .build()
                        .parseSignedClaims(value).getPayload()
        );
    }

    public void validateToken(String token){
        handleJwtException(token, (value) -> {
            Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(value);
            return null;
        });
    }

    private <T> T handleJwtException(String token, Function<String, T> function){
        try{
            return function.apply(token);
        }catch (MalformedJwtException malformedJwtException){
            throw new RestApiException(CustomErrorCode.TOKEN_INVALID);
        }catch (ExpiredJwtException expiredJwtException){
            throw new RestApiException(CustomErrorCode.TOKEN_EXPIRED);
        }catch (IllegalArgumentException illegalArgumentException){
            throw new RestApiException(CustomErrorCode.TOKEN_EMPTY);
        }catch (SignatureException signatureException){
            throw new RestApiException(CustomErrorCode.TOKEN_NOT_SIGNED);
        }catch (JwtException jwtException){
            throw new RestApiException(CustomErrorCode.INTERNAL_SERVER_ERROR);
        }
    }
}
