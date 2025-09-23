package gravit.code.global.consts;

import java.util.Map;

public final class RedirectHostConst {
    public static final Map<String, String> DEST_BASE = Map.of(
            "prod",  "https://gravit.inuappcenter.kr",
            "local", "http://localhost:5173"
    );
}