package gravit.code.auth.dto.oauth.android.support;

import java.util.Map;

public final class AndroidOAuthClaimsExtractor {
    private AndroidOAuthClaimsExtractor() { }

    public static String getClaimAsString(
            Map<String, Object> map,
            String key
    ) {
        if (map == null)
            return null;
        Object value = map.get(key);
        return value == null ? null : value.toString();
    }

    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static String extractProviderUserIdFromSub(String sub) {
        if (isBlank(sub))
            return null;
        int last = sub.lastIndexOf('|');
        return last == -1 ? sub : sub.substring(last + 1);
    }

}
