// 부하 테스트 스크립트. 대상: GET /api/v1/chapters (이슈 #490)
//
// 실행: 토큰 발급, warmup, measure를 각각 따로 돌린다. 통계 리셋은 토큰 발급이 끝난 뒤에 한다.
//
//   (토큰 발급 - Phase 4, 8의 명령 블록 참조. $PERF_DIR/tokens.json 생성)
//   k6 run -e PHASE=warmup $TARGET_DIR/test-script.js
//   psql ... -c "SELECT pg_stat_statements_reset();"
//   k6 run -e PHASE=measure -e SUMMARY_OUT=$TARGET_DIR/k6-test-summary-{n}.json \
//     $TARGET_DIR/test-script.js
//
// {n}은 상태 번호다. 0 = 아무것도 적용하지 않은 원본(Phase 4), n = 사이클 n 적용 후(Phase 8).

import http from 'k6/http';
import exec from 'k6/execution';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const USER_ID_START = Number(__ENV.USER_ID_START || 1001);
const USER_COUNT = Number(__ENV.USER_COUNT || 1000);
const PHASE = __ENV.PHASE || 'measure';

// 이 API는 전체 챕터를 훑으므로 경로 변수가 없다. 챕터는 5개(900001~900005) 전부가 매 요청에 걸린다.
const CHAPTER_COUNT = 5;

// 이 측정이 무엇이었는지 요약 파일만 보고 알 수 있게 한다.
const TARGET = 'chapters';
const ENDPOINT = 'GET /api/v1/chapters';
const CONDITION = {
    vus: 50,
    steady_state_duration: '1m',
    ramp_up: '30s',
    ramp_down: '30s',
    total_duration: '2m',
    redis_cache: 'cold',
    db_cache: '제어하지 않음',
    user_id_start: USER_ID_START,
    user_count: USER_COUNT,
    chapter_count: CHAPTER_COUNT,
};

// tokens.json은 이슈 디렉토리에 있다(대상 간 공유).
const tokens = JSON.parse(open('../tokens.json'));

if (tokens.length !== USER_COUNT) {
    throw new Error(
        `토큰 ${tokens.length}건 / 필요 ${USER_COUNT}건. 로그인에 실패한 userId가 있다. ` +
        'tokens.json을 다시 만들고 userId 범위와 perf 프로파일 기동 상태를 확인하라.'
    );
}

const scenarios = {
    warmup: {
        executor: 'constant-vus',
        vus: 5,
        duration: '30s',
    },
    measure: {
        executor: 'ramping-vus',
        startVUs: 0,
        stages: [
            { duration: '30s', target: 50 },
            { duration: '1m', target: 50 },
            { duration: '30s', target: 0 },
        ],
    },
};

export const options = {
    scenarios: { [PHASE]: scenarios[PHASE] },
    summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
    thresholds: {
        http_req_failed: ['rate<0.01'],
        checks: ['rate>0.99'],
    },
};

// 비JSON 응답에서 예외를 던지지 않는다. 파싱 실패는 null로 떨어뜨려 check 실패로 드러낸다.
function parseBody(res) {
    if (res.status !== 200 || res.body === null || res.body.length <= 2) {
        return null;
    }
    try {
        return res.json();
    } catch (e) {
        return null;
    }
}

export default function () {
    // 시나리오 전체의 반복 번호로 고른다. VU 수와 무관하게 토큰 USER_COUNT개를 균등하게 돈다.
    const iteration = exec.scenario.iterationInTest;

    const token = tokens[iteration % tokens.length];
    const params = { headers: { Authorization: `Bearer ${token}` } };

    const res = http.get(`${BASE_URL}/api/v1/chapters`, params);

    check(res, {
        'status is 200': (r) => r.status === 200,
        'body is not empty': (r) => r.body !== null && r.body.length > 2,
        'chapterSummaryResponse가 실린 배열이다': (r) => {
            const body = parseBody(r);
            return body !== null
                && Array.isArray(body)
                && body.length > 0
                && body[0].chapterSummaryResponse !== undefined;
        },
    });
}

export function handleSummary(data) {
    const m = data.metrics || {};
    const val = (name, key) => (m[name] && m[name].values[key] !== undefined ? m[name].values[key] : null);
    const trend = (name) => ({
        med: val(name, 'med'),
        p95: val(name, 'p(95)'),
        p99: val(name, 'p(99)'),
        max: val(name, 'max'),
    });

    const summary = {
        phase: PHASE,
        target: TARGET,
        endpoint: ENDPOINT,
        condition: CONDITION,
        requests: val('http_reqs', 'count'),
        rps: val('http_reqs', 'rate'),
        failed_rate: val('http_req_failed', 'rate'),
        checks_rate: val('checks', 'rate'),
        checks: ((data.root_group || {}).checks || []).map((c) => ({
            name: c.name,
            passes: c.passes,
            fails: c.fails,
        })),
        duration_ms: trend('http_req_duration'),
        waiting_ms: trend('http_req_waiting'),
        bytes_received: val('data_received', 'count'),
    };

    // 아래 반올림은 터미널 한 줄 출력에만 쓴다. summary 객체의 값은 손대지 않는다.
    const num = (x, d) => (typeof x === 'number' ? x.toFixed(d) : '-');
    const line = [
        `[${PHASE}] ${TARGET}`,
        `요청 ${summary.requests}건`,
        `p95 ${num(summary.duration_ms.p95, 1)}ms`,
        `p99 ${num(summary.duration_ms.p99, 1)}ms`,
        `실패율 ${num(summary.failed_rate * 100, 2)}%`,
        `check ${num(summary.checks_rate * 100, 2)}%`,
    ].join(' / ');

    const out = { stdout: `\n${line}\n\n` };

    if (__ENV.SUMMARY_OUT) {
        out[__ENV.SUMMARY_OUT] = JSON.stringify(summary, null, 2);
    }

    return out;
}
