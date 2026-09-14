package gravit.code.friend.support;

import lombok.experimental.UtilityClass;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

@UtilityClass
public class HandleNormalize {

    private static final Pattern HANDLE_NOT_ALLOWED = Pattern.compile("[^a-z0-9]");
    private static final char HANDLE_PREFIX = '@';

    public static String handleNormalize(String queryText) {
        if (queryText == null || queryText.isBlank()) return "";
        String q = Normalizer.normalize(queryText, Normalizer.Form.NFKC).strip();

        int i = 0;
        while (i < q.length() && q.charAt(i) == HANDLE_PREFIX) i++;
        if (i > 0) q = q.substring(i);

        q = q.toLowerCase(Locale.ROOT);
        q = HANDLE_NOT_ALLOWED.matcher(q).replaceAll("");
        return q;
    }
}
