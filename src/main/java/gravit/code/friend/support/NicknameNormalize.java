package gravit.code.friend.support;

import lombok.experimental.UtilityClass;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

@UtilityClass

public class NicknameNormalize {
    private static final Pattern NICKNAME_NOT_ALLOWED  = Pattern.compile("[^0-9A-Za-z가-힣]");

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
