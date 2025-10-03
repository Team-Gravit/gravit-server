import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    scenarios: {
        constance_load: {
            executor: 'constant-vus',
            vus: 100,
            duration: '30s',
            gracefulStop: '5s'
        }
    },
    thresholds:{
        http_req_duration: ['p(95) < 500', 'p(99) < 1000'],
        http_req_failed: ['rate < 0.01']
    }
}

const BASE_URL = 'http://localhost:8521'
const JWT = ''

export default function (){
    const lessonId = Math.floor(Math.random() * 8) + 1

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
        'status 200': (r) => r.status === 200,
        'status 401': (r) => r.status === 401,
        'status 403': (r) => r.status === 403,
        'status 404': (r) => r.status === 404,
        'status 500': (r) => r.status === 500,
    });

    sleep(1)
}