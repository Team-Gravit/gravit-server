// 부하 테스트 스크립트 템플릿.
// {…} 자리를 채워 .claude/resources/perf/{이슈번호}/test-script.js 로 저장한다.
//
// 실행: warmup과 measure를 별도 프로세스로 나눠 돌린다. 사이에 pg_stat_statements를 리셋한다.
//
//   k6 run -e PHASE=warmup $PERF_DIR/test-script.js
//   psql ... -c "SELECT pg_stat_statements_reset();"
//   k6 run -e PHASE=measure -e SUMMARY_OUT=$PERF_DIR/k6-test-summary-{n}.json \
//     $PERF_DIR/test-script.js
//
// {n}은 상태 번호다. 0 = 아무것도 적용하지 않은 원본(Phase 4), n = 사이클 n 적용 후(Phase 8).
// 실행은 호출자가 한다. 스킬은 명령어만 제시한다.
//
// ── 작성 규칙 ──────────────────────────────────────────────
// 1. 이 파일을 복사해 고친다. 빈 파일에서 새로 쓰지 않는다.
// 2. 고치는 자리는 default 함수의 요청 한 줄과 check의 세 번째 항목, VU와 duration뿐이다.
//    그 외 구조는 아래 3~10 규칙 안에서만 손댄다.
// 3. PHASE 분기를 유지한다. 두 시나리오를 한 프로세스에서 같이 돌리지 않는다.
// 4. VU마다 다른 userId를 쓰는 setup() 구조를 유지한다. 전 VU가 같은 토큰을 쓰게 고치지 않는다.
// 5. 응답시간 임계를 thresholds에 넣지 않는다. 판정은 스킬이 전후 비교로 한다.
//    summaryTrendStats는 지우지 않는다. 지우면 p(99)가 요약에서 사라진다(k6 기본값에 없다).
// 6. check에는 실제 데이터가 실렸는지 확인하는 항목을 반드시 하나 넣는다.
//    리스트 응답이면 `r.json().length > 0`, 객체 응답이면 `r.json('{필드}') !== null`,
//    페이지 응답이면 `r.json('content').length > 0`.
// 7. VU와 duration은 Phase 3에서 호출자와 확정한 값으로 채운다. 기본값을 그대로 두지 않는다.
// 8. USER_ID_START, USER_COUNT는 seeds.sql로 실제 만든 userId 범위와 일치시킨다.
// 9. 인증 토큰은 POST /api/v1/test/users/login?userId={id} 응답의 accessToken을 그대로 쓴다.
// 10. handleSummary가 내보내는 필드를 빼지 않는다. Phase 4와 8이 이 필드명을 그대로 참조한다.
//
// measure 실행의 http_reqs에는 setup()의 로그인 USER_COUNT건이 포함된다.
// 요청당 쿼리 수를 계산할 때 분모는 요약의 `requests - USER_COUNT`다.
//
// 대상 엔드포인트 형태별 요청 한 줄:
//   GET               http.get(`${BASE_URL}/api/v1/...`, params)
//   GET + 쿼리        http.get(`${BASE_URL}/api/v1/...?page=${__ITER % 10}&size=20`, params)
//   GET + 경로 변수   http.get(`${BASE_URL}/api/v1/.../${USER_ID_START + (__VU % USER_COUNT)}`, params)
//   POST + 바디       http.post(`${BASE_URL}/api/v1/...`, JSON.stringify({…}),
//                       { headers: { ...params.headers, 'Content-Type': 'application/json' } })
// 경로 변수나 바디에 들어갈 식별자는 `__VU`나 `__ITER`로 흩는다. 고정값을 박으면 한 행만 반복 조회한다.
// ──────────────────────────────────────────────────────────

import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const USER_ID_START = Number(__ENV.USER_ID_START || 1);
const USER_COUNT = Number(__ENV.USER_COUNT || 50);
const PHASE = __ENV.PHASE || 'measure';

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
            { duration: '30s', target: {VU} },
            { duration: '{duration}', target: {VU} },
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

export function setup() {
    const tokens = [];

    for (let i = 0; i < USER_COUNT; i++) {
        const userId = USER_ID_START + i;
        const res = http.post(`${BASE_URL}/api/v1/test/users/login?userId=${userId}`);

        if (res.status === 200) {
            tokens.push(res.json('accessToken'));
        }
    }

    if (tokens.length === 0) {
        throw new Error('토큰을 하나도 발급받지 못했다. userId 범위와 perf 프로파일 기동 상태를 확인하라.');
    }

    return { tokens };
}

export default function (data) {
    const token = data.tokens[__VU % data.tokens.length];
    const params = { headers: { Authorization: `Bearer ${token}` } };

    const res = http.get(`${BASE_URL}{대상 엔드포인트}`, params);

    check(res, {
        'status is 200': (r) => r.status === 200,
        'body is not empty': (r) => r.body !== null && r.body.length > 2,
        '{대표 필드}가 실려 있다': (r) => {데이터검증식},
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

    const num = (x, d) => (typeof x === 'number' ? x.toFixed(d) : '-');
    const line = [
        `[${PHASE}]`,
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
