package gravit.code.friend.support;

import lombok.experimental.UtilityClass;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

@UtilityClass
public class NicknameNormalize {

    private static final Pattern NICKNAME_NOT_ALLOWED = Pattern.compile("[^0-9A-Za-z가-힣]");

    public static String nicknameNormalize(String queryText) {
        if (queryText == null || queryText.isBlank()) return "";
        String q = Normalizer.normalize(queryText, Normalizer.Form.NFKC).strip();

        q = q.toLowerCase(Locale.ROOT);
        q = NICKNAME_NOT_ALLOWED.matcher(q).replaceAll("");
        return q;
    }
}
