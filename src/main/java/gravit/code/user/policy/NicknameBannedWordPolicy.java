package gravit.code.user.policy;

import gravit.code.global.exception.domain.RestApiException;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.NICKNAME_BANNED_WORD;

@Component
public class NicknameBannedWordPolicy {

    private static final String BANNED_WORDS_PATH = "policy/nickname-banned-words.txt";
    private static final String ALLOWED_WORDS_PATH = "policy/nickname-allowed-words.txt";
    private static final String ALLOWED_WORD_MASK = "*";
    private static final String COMMENT_PREFIX = "#";
    private static final Pattern DIGITS = Pattern.compile("[0-9]");

    private final Set<String> bannedWords;
    private final List<String> allowedWords;

    public NicknameBannedWordPolicy() {
        this(loadWords(BANNED_WORDS_PATH), loadWords(ALLOWED_WORDS_PATH));
    }

    private static List<String> loadWords(String path) {
        try {
            String content = new ClassPathResource(path).getContentAsString(StandardCharsets.UTF_8);
            return content.lines()
                    .map(String::strip)
                    .filter(line -> !line.isEmpty())
                    .filter(line -> !line.startsWith(COMMENT_PREFIX))
                    .toList();
        } catch (IOException e) {
            throw new IllegalStateException("닉네임 단어 목록을 읽을 수 없습니다: " + path, e);
        }
    }

    NicknameBannedWordPolicy(
            Collection<String> bannedWords,
            Collection<String> allowedWords
    ) {
        this.bannedWords = bannedWords.stream()
                .map(NicknameBannedWordPolicy::normalize)
                .collect(Collectors.toUnmodifiableSet());
        this.allowedWords = allowedWords.stream()
                .map(NicknameBannedWordPolicy::normalize)
                .distinct()
                .sorted(Comparator.comparingInt(String::length).reversed())
                .toList();

        if (this.bannedWords.isEmpty()) {
            throw new IllegalStateException("닉네임 금지어 목록이 비어 있습니다: " + BANNED_WORDS_PATH);
        }
    }

    public void validate(String nickname) {
        if (nickname == null || nickname.isBlank()) {
            return;
        }

        String normalized = normalize(nickname);

        if (containsBannedWord(maskAllowedWords(normalized))
                || containsBannedWord(maskAllowedWords(removeDigits(normalized)))) {
            throw new RestApiException(NICKNAME_BANNED_WORD);
        }
    }

    private static String normalize(String text) {
        return Normalizer.normalize(text, Normalizer.Form.NFKC).toLowerCase(Locale.ROOT);
    }

    private String maskAllowedWords(String text) {
        String masked = text;
        for (String allowedWord : allowedWords) {
            masked = masked.replace(allowedWord, ALLOWED_WORD_MASK);
        }
        return masked;
    }

    private static String removeDigits(String text) {
        return DIGITS.matcher(text).replaceAll("");
    }

    private boolean containsBannedWord(String text) {
        return bannedWords.stream().anyMatch(text::contains);
    }
}
