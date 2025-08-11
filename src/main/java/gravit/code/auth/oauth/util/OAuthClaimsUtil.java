package gravit.code.auth.oauth.util;

import java.util.Map;

public final class OAuthClaimsUtil {
    private OAuthClaimsUtil() { }

    public static String getString(Map<String, Object> map, String key) {
        if (map == null) return null;
        Object v = map.get(key);
        return v == null ? null : v.toString();
    }

    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static String providerUserIdFromSub(String sub) {
        if (isBlank(sub)) return null;
        int last = sub.lastIndexOf('|');
        return last == -1 ? sub : sub.substring(last + 1);
    }

}
