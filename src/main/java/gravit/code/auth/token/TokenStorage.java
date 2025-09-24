package gravit.code.auth.token;

import gravit.code.auth.domain.Subject;
import gravit.code.auth.domain.Token;

import java.util.Optional;

public interface TokenStorage {
    <T extends Token> T saveToken(Subject subject, T token);

    <T extends Token> Optional<String> findToken(Subject subject, Class<T> tokenClass);
}
