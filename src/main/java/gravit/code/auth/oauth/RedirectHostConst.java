package gravit.code.auth.oauth;

import java.util.Map;

public final class RedirectHostConst {
    public static final Map<String, String> DEST_BASE = Map.of(
            "prod",  "https://gravit-cs.vercel.app",
            "local", "http://localhost:5173"
    );
}
