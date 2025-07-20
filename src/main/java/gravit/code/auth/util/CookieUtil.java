package gravit.code.auth.util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;

public class CookieUtil {
    public static Cookie createCookie(final String nameOfCookie, final String token,
                                      final Long cookieValidTime) {
        Cookie cookie = new Cookie(nameOfCookie,token);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        cookie.setMaxAge(Math.toIntExact(cookieValidTime));
        cookie.setSecure(true);
        return cookie;
    }

    public static Cookie getCookie(HttpServletRequest request, String nameOfCookie) {
        Cookie[] cookies = request.getCookies();

        if (cookies == null || cookies.length == 0) {
            return null;
        }

        for (Cookie cookie : cookies) {
            if (cookie.getName().equals(nameOfCookie)) {
                return cookie;
            }
        }
        return null;
    }
}
