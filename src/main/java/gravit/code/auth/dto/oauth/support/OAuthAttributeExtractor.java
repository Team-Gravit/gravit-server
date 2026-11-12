package gravit.code.auth.dto.oauth.support;

import java.util.Map;

public final class OAuthAttributeExtractor {

    private OAuthAttributeExtractor() {
    }

    public static String getAttributeAsString(
            Map<String, Object> attributes,
            String key
    ) {
        if (attributes == null) {
            return null;
        }

        Object value = attributes.get(key);
        return value == null ? null : value.toString();
    }

    public static String getNestedAttributeAsString(
            Map<String, Object> attributes,
            String parentKey,
            String key
    ) {
        return getAttributeAsString(getNestedAttributes(attributes, parentKey), key);
    }

    @SuppressWarnings("unchecked")
    public static Map<String, Object> getNestedAttributes(
            Map<String, Object> attributes,
            String key
    ) {
        if (attributes == null) {
            return null;
        }

        Object value = attributes.get(key);
        return value instanceof Map<?, ?> nested ? (Map<String, Object>) nested : null;
    }
}
