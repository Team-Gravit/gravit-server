package gravit.code.auth.jwt;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import io.jsonwebtoken.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
@Slf4j
public class JwtProvider {
    private final UserRepository userRepository;

    private SecretKey secretKey;

    @Value("${jwt.valid-time}")
    public Long VALID_TIME;

    private JwtProvider(UserRepository userRepository, @Value("${jwt.secret}") String secret){
        this.userRepository = userRepository;
        secretKey = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), Jwts.SIG.HS256.key().build().getAlgorithm());
    }

    public String createAccessToken(Long userId){
        Date timeNow = new Date(System.currentTimeMillis());
        Date expirationTime = new Date(timeNow.getTime() + VALID_TIME);

        return Jwts.builder()
                .claim("userId", userId)
                .setIssuedAt(timeNow)
                .setExpiration(expirationTime)
                .signWith(secretKey, SignatureAlgorithm.HS256)
                .compact();
    }

    public Authentication getAuthUser(String token){
        Long userId = getUserId(token);
        User user = userRepository.findById(userId).orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
        LoginUser loginUser = new LoginUser(user.getId(),user.getProviderId(),null);
        return new UsernamePasswordAuthenticationToken(loginUser, "",
                loginUser.getAuthorities());
    }

    public Long getUserId(String token) {
        return Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload().get("userId", Long.class);
    }

    public String getRole(String token) {
        return Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload().get("role", String.class);
    }

    public boolean isValidToken(String token){
        //log.info("토큰 유효성 검증 시작");
        return valid(secretKey, token);
    }

    private boolean valid(SecretKey secretKey, String token){
        try{
            Jws<Claims> claims = Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
            Date expiration = claims.getBody().getExpiration();
            return expiration.after(new Date());
        }catch (SignatureException ex){
            throw new RuntimeException();
        }catch (MalformedJwtException ex){
            throw new RuntimeException();
        }catch (ExpiredJwtException ex){
            throw new RuntimeException();
        }catch (IllegalArgumentException ex){
            throw new RuntimeException();
        }
    }

}
