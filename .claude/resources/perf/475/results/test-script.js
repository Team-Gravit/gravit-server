// PERF-475 / results 부하 테스트 스크립트.
//
// 실행: 토큰 발급, warmup, measure를 각각 따로 돌린다. 통계 리셋은 토큰 발급이 끝난 뒤에 한다.
//
//   (토큰 발급 - Phase 4, 8의 명령 블록 참조. $PERF_DIR/tokens.json 생성)
//   k6 run -e PHASE=warmup $TARGET_DIR/test-script.js
//   (첫 풀이 대역 되돌리기 - Phase 4, 8의 명령 블록 참조)
//   psql ... -c "SELECT pg_stat_statements_reset();"
//   k6 run -e PHASE=measure -e SUMMARY_OUT=$TARGET_DIR/k6-test-summary-{n}.json $TARGET_DIR/test-script.js
//
// ── 이 대상의 특이점: 쓰기 엔드포인트이고 첫 풀이만 잰다 ──────────────
// isFirstTry는 lesson_submission에 (user_id, lesson_id) 행이 없을 때만 true다.
// 따라서 (유저, 레슨) 조합은 소모품이고, 요청 1건이 조합 1개를 쓴다.
//
//   조합 = iterationInTest로 유일하게 배정한다
//     userIdx      = iterationInTest % USER_COUNT
//     lessonOffset = floor(iterationInTest / USER_COUNT) % FIRST_TRY_LESSON_COUNT
//   상한 = USER_COUNT × FIRST_TRY_LESSON_COUNT = 100,000건
//
// warmup과 measure는 별도 k6 프로세스라 iterationInTest가 각각 0부터 다시 센다.
// 그래서 warmup이 쓴 조합을 measure가 그대로 다시 쓴다.
// **measure 직전에 첫 풀이 대역을 되돌리지 않으면 measure 요청이 전부 재풀이가 된다.**
// 되돌리기를 빠뜨리면 요청당 쿼리 수가 리스너 몫만큼 통째로 빠져 기준선이 무의미해진다.
// ──────────────────────────────────────────────────────────────

import http from 'k6/http';
import exec from 'k6/execution';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const USER_ID_START = Number(__ENV.USER_ID_START || 1001);
const USER_COUNT = Number(__ENV.USER_COUNT || 1000);
const PHASE = __ENV.PHASE || 'measure';

// seeds.sql의 first_try_* 변수와 일치시킨다.
const FIRST_TRY_ID_BASE = 910000;
const FIRST_TRY_LESSON_COUNT = 100;
const PROBLEMS_PER_LESSON = 30;

// Phase 3-B에서 확정한 요청 페이로드.
const WRONG_COUNT = 9;
const ACCURACY = Math.round(((PROBLEMS_PER_LESSON - WRONG_COUNT) / PROBLEMS_PER_LESSON) * 100);
const LEARNING_TIME = 300;

const FIRST_TRY_CAPACITY = USER_COUNT * FIRST_TRY_LESSON_COUNT;

// 이 측정이 무엇이었는지 요약 파일만 보고 알 수 있게 한다.
const TARGET = 'results';
const ENDPOINT = 'POST /api/v1/lessons/results';
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
    problems_per_request: PROBLEMS_PER_LESSON,
    wrong_per_request: WRONG_COUNT,
    accuracy: ACCURACY,
    learning_time: LEARNING_TIME,
    first_try_only: true,
    first_try_capacity: FIRST_TRY_CAPACITY,
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

// 레슨 하나의 문제 30개를 그대로 제출한다.
// problem id 홀수 = OBJECTIVE, 짝수 = SUBJECTIVE (seeds.sql의 CASE와 같은 규칙).
// 앞 WRONG_COUNT개를 오답으로 둬 wrong_answered_note 경로를 태운다.
function buildProblemSubmissions(lessonOffset) {
    const firstProblemId = FIRST_TRY_ID_BASE + lessonOffset * PROBLEMS_PER_LESSON + 1;
    const submissions = [];

    for (let i = 0; i < PROBLEMS_PER_LESSON; i++) {
        const problemId = firstProblemId + i;
        const isObjective = problemId % 2 === 1;

        submissions.push({
            problemId: problemId,
            isCorrect: i >= WRONG_COUNT,
            selectedOptionId: isObjective ? problemId : null,
            submittedContent: isObjective ? null : `perf-answer-${problemId}`,
        });
    }

    return submissions;
}

export default function () {
    // 시나리오 전체의 반복 번호로 고른다. VU 수와 무관하게 토큰 1000개를 균등하게 돈다.
    const idx = exec.scenario.iterationInTest;
    const token = tokens[idx % tokens.length];
    const params = { headers: { Authorization: `Bearer ${token}` } };

    // (유저, 레슨) 조합이 반복마다 유일해야 isFirstTry가 true로 유지된다.
    const lessonOffset = Math.floor(idx / USER_COUNT) % FIRST_TRY_LESSON_COUNT;
    const lessonId = FIRST_TRY_ID_BASE + 1 + lessonOffset;

    const payload = JSON.stringify({
        lessonSubmissionSaveRequest: {
            lessonId: lessonId,
            learningTime: LEARNING_TIME,
            accuracy: ACCURACY,
        },
        problemSubmissionSaveRequests: buildProblemSubmissions(lessonOffset),
    });

    const res = http.post(`${BASE_URL}/api/v1/lessons/results`, payload, {
        headers: { ...params.headers, 'Content-Type': 'application/json' },
    });

    check(res, {
        'status is 200': (r) => r.status === 200,
        'body is not empty': (r) => r.body !== null && r.body.length > 2,
        '리그명과 유닛 요약이 실려 있다': (r) => {
            const body = parseBody(r);
            return body !== null
                && body.leagueName !== undefined
                && body.unitSummaryResponse !== undefined
                && body.unitSummaryResponse.unitId !== undefined
                && body.userLevelResponse !== undefined
                && body.userLevelResponse.currentLevel !== undefined;
        },
        // 이 항목이 깨지면 첫 풀이 조합이 소진된 것이다. 이후 요청은 재풀이라 측정값이 섞인다.
        '첫 풀이 조합이 남아 있다': () => idx < FIRST_TRY_CAPACITY,
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
