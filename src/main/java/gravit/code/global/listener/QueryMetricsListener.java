package gravit.code.global.listener;

import gravit.code.global.interceptor.RequestContext;
import gravit.code.global.interceptor.RequestContextHolder;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.ttddyy.dsproxy.ExecutionInfo;
import net.ttddyy.dsproxy.QueryInfo;
import net.ttddyy.dsproxy.listener.QueryExecutionListener;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.TimeUnit;

@Profile("!prod")
@RequiredArgsConstructor
@Component
@Slf4j
public class QueryMetricsListener implements QueryExecutionListener {
    private final MeterRegistry meterRegistry;


    @Override
    public void beforeQuery(ExecutionInfo executionInfo, List<QueryInfo> list) {

    }

    @Override
    public void afterQuery(ExecutionInfo exec, List<QueryInfo> queries) {
        long elapsedMs = exec.getElapsedTime();
        String sql = queries.isEmpty() ? "" : queries.get(0).getQuery();
        String type = guessType(sql);

        RequestContext rc = RequestContextHolder.getContext();
        String httpMethod = (rc != null && rc.getHttpMethod() != null) ? rc.getHttpMethod() : "-";
        String httpPath = (rc != null && rc.getBestMatchPath() != null) ? rc.getBestMatchPath() : "-";

        meterRegistry.timer(
                "db.query",
                "sql_type", type,
                "http_method", httpMethod,
                "http_path", httpPath
        ).record(elapsedMs, TimeUnit.MILLISECONDS);
    }

    private String guessType(String sql) {
        if (sql == null) return "OTHER";
        String s = sql.trim().toUpperCase();
        if (s.startsWith("SELECT")) return "SELECT";
        if (s.startsWith("INSERT")) return "INSERT";
        if (s.startsWith("UPDATE")) return "UPDATE";
        if (s.startsWith("DELETE")) return "DELETE";
        return "UNKNOWN";
    }
}
