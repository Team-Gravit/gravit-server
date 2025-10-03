import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    scenarios: {
        ramp_up_load: {
            executor: 'ramping-vus',

            startVUs: 0,

            stages: [
                { duration: '2m', target: 50 },

                { duration: '3m', target: 50 },

                { duration: '2m', target: 100 },

                { duration: '5m', target: 100 },

                { duration: '3m', target: 200 },

                { duration: '5m', target: 200 },

                { duration: '2m', target: 0 },
            ],

            gracefulStop: '30s',

            gracefulRampDown: '30s',
        },
    },

    thresholds: {
        http_req_duration: ['p(95)<500'],
        http_req_failed: ['rate<0.01'],
    },
};

const BASE_URL = 'http://localhost:8521'
const JWT = ''

export default function() {
    const lessonId = Math.floor(Math.random() * 8) + 1;

    const params = {
        headers: {
            'Authorization': `Bearer ${JWT}`,
            'Content-Type': 'application/json',
        },
    };

    const response = http.get(
        `${BASE_URL}/api/v1/learning/${lessonId}`,
        params
    );

    check(response, {
        'status is 200': (r) => r.status === 200,
        'response time OK': (r) => r.timings.duration < 500,
        'has response body': (r) => r.body && r.body.length > 0,
    });

    sleep(1);
}