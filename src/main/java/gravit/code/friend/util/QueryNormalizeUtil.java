package gravit.code.friend.util;

import lombok.experimental.UtilityClass;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

@UtilityClass
public class QueryNormalizeUtil {

    private static final Pattern HANDLE_NOT_ALLOWED    = Pattern.compile("[^a-z0-9]");
    private static final Pattern NICKNAME_NOT_ALLOWED  = Pattern.compile("[^0-9A-Za-z가-힣]");

    /**
     * 핸들(태그) 정규화
     * - 앞의 '@'는 제거 (테이블에는 @까지 저장하지 않음)
     * - NFKC 정규화 후 공백 양끝 제거
     * - 전부 소문자로 변환(소문자만 가능함)
     * - 소문자 알파벳/숫자만 남김
     * @return 정규화된 핸들 문자열(없으면 빈 문자열)
     */
    public static String handleNormalize(String queryText) {
        if (queryText == null || queryText.isBlank()) return "";
        String q = Normalizer.normalize(queryText, Normalizer.Form.NFKC).strip();

        // 앞쪽 연속 '@' 제거
        int i = 0;
        while (i < q.length() && q.charAt(i) == '@') i++;
        if (i > 0) q = q.substring(i);

        q = q.toLowerCase(Locale.ROOT);
        q = HANDLE_NOT_ALLOWED.matcher(q).replaceAll(""); // 소문자/숫자 이외 제거
        return q;
    }

    /**
     * 닉네임 정규화
     *  - NFKC 정규화 후 공백 양끝 제거
     *  - (영문 대/소문자, 숫자, 한글)만 남김
     *  - 대소문자는 보존
     * @return 정규화된 닉네임 문자열(없으면 빈 문자열)
     */
    public static String nicknameNormalize(String queryText) {
        if (queryText == null || queryText.isBlank()) return "";
        String q = Normalizer.normalize(queryText, Normalizer.Form.NFKC).strip();

        q = q.toLowerCase(Locale.ROOT);
        q = NICKNAME_NOT_ALLOWED.matcher(q).replaceAll(""); // 허용 외 문자 제거(공백 포함)
        return q;
    }
}
