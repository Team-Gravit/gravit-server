package gravit.code.auth.jwt;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.SignatureException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.function.Function;

import static io.jsonwebtoken.Jwts.SIG.HS256;

@Component
@Slf4j
public class JwtProvider {
    private final UserRepository userRepository;

    private final SecretKey secretKey;
    public int validTime;

    private JwtProvider(UserRepository userRepository,
                        @Value("${jwt.secret}") String secret,
                        @Value("${jwt.valid-time}")int validTime){
        this.userRepository = userRepository;
        this.validTime = validTime;
        this.secretKey = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
    }

    public String createAccessToken(Long userId){
        return Jwts.builder()
                .claim("userId", userId)
                .expiration(new Date(System.currentTimeMillis() + validTime))
                .issuedAt(new Date())
                .signWith(secretKey, HS256)
                .compact();
    }

    public Authentication getAuthUser(String token){
        Long userId = getUserId(token);
        User user = userRepository.findById(userId).orElseThrow(RuntimeException::new);
        LoginUser loginUser = new LoginUser(user.getId(),user.getProviderId(),null);

        return new UsernamePasswordAuthenticationToken(loginUser, "",
                loginUser.getAuthorities());
    }

    public Long getUserId(String token) {
        Claims claims = extractClaims(token);
        return claims.get("userId", Long.class);
    }

    private Claims extractClaims(String token) {
        return handleJwtException(token, (value) ->
                Jwts.parser()
                        .verifyWith(secretKey)
                        .build()
                        .parseSignedClaims(value).getPayload()
        );
    }

    public boolean isValidToken(String token){
        return handleJwtException(token, (value) -> {
            Jws<Claims> claims = Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(value);
            Date expiration = claims.getPayload().getExpiration();
            return expiration.after(new Date());
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
