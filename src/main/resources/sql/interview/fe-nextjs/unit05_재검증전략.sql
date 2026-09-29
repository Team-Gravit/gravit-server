-- Unit: 재검증 전략 (Unit ID: 162)
-- Chapter: Next.js (Chapter ID: 15)
-- Topic: NEXT_JS
-- Source: gravit-interview-contents-generator/output/2026-09-24/fe-nextjs-unit05 (note_commit 4d6a66c)

-- 면접 질문 생성
INSERT INTO interview_question (id, topic, unit_id, difficulty, is_active, content, model_answer, audio_key)
VALUES
(806, 'NEXT_JS', 162, 'HARD', true,
 '외부 CMS에서 글이 발행·수정되는 블로그를 Next.js로 운영한다고 할 때, 글 목록과 상세 페이지의 캐시를 어떤 방식으로 재검증하시겠습니까? 구현 시 주의할 점과 이 방식의 한계도 함께 설명해 주세요.',
 'CMS처럼 Next.js 밖에서 데이터가 바뀌는 경우에는 app/api/revalidate 같은 라우트 핸들러를 만들고, CMS가 글 발행 시 웹훅으로 이 핸들러를 POST 호출하게 합니다. 핸들러는 요청 본문으로 받은 태그로 revalidateTag를 호출합니다. 이때 데이터 fetch에 목록 전체용 태그(posts)와 개별 항목용 태그(post-42 같은)를 함께 붙여 두면, 글 하나가 수정됐을 때 그 글 상세와 목록만 정확히 갱신할 수 있습니다. revalidatePath(''/'', ''layout'')처럼 넓게 무효화하면 편하지만 모든 페이지가 다음 요청에서 재생성되어 서버 부하가 급증하므로 태그로 좁게 무효화하는 것을 우선합니다. 주의할 점은 이 라우트 핸들러를 x-revalidate-secret 같은 비밀 키로 검증해야 한다는 것입니다. 검증 없이 노출하면 누구나 캐시를 무효화해 서버를 재생성 폭주로 몰아넣을 수 있습니다. 한계로는, 라우트 핸들러에서 호출한 revalidateTag·revalidatePath는 서버 캐시만 갱신하고 이미 열려 있는 브라우저의 라우터 캐시는 갱신하지 않아서 다음 내비게이션이나 router.refresh() 때에야 반영된다는 점이 있습니다. 또 revalidateTag는 캐시를 지운다기보다 오래됨(stale)으로 표시하는 것이라, 실제 재생성은 사용자의 다음 방문 때 일어납니다.',
 'interview-question/806.mp3'),
(807, 'NEXT_JS', 162, 'NORMAL', true,
 'Next.js의 시간 기반 재검증과 온디맨드 재검증은 어떻게 다르며, 각각 어떤 데이터에 적합한지 설명해 주세요.',
 '재검증은 재배포 없이 특정 데이터나 페이지만 골라 갱신하는 수단이고, 시간 기반과 온디맨드 두 축으로 나뉩니다. 시간 기반 재검증은 fetch의 next.revalidate나 export const revalidate로 지정한 초가 지난 뒤 들어오는 다음 요청에서 재검증이 트리거됩니다. 그래서 신선도는 최대 revalidate초만큼 지연될 수 있지만 옵션 하나로 구현할 수 있습니다. 온디맨드 재검증은 revalidateTag나 revalidatePath를 호출하는 즉시 캐시를 무효화해 변경 직후 다음 방문부터 반영되지만, 데이터가 변경되는 지점마다 호출 코드를 넣어야 합니다. 따라서 변경 시점을 알 수 없는 외부 데이터나 통계에는 시간 기반이 적합하고, CMS·관리자·유저 액션처럼 내 시스템에서 변경되는 데이터에는 온디맨드가 적합합니다. 즉 변경 시점을 내가 알면 온디맨드, 모르면 시간 기반을 선택합니다.',
 'interview-question/807.mp3'),
(808, 'NEXT_JS', 162, 'NORMAL', true,
 'revalidateTag와 revalidatePath는 무효화 단위가 어떻게 다르며, 둘 중 무엇을 우선해서 사용해야 하는지 설명해 주세요.',
 'revalidateTag는 fetch의 next.tags나 unstable_cache의 tags로 데이터에 붙여 둔 태그를 기준으로, 그 태그가 달린 모든 캐시 항목을 한꺼번에 무효화합니다. 어떤 페이지가 그 데이터를 쓰는지 몰라도 되므로 데이터 중심 관리가 가능하고, 해당 데이터를 쓰는 정적 라우트의 전체 라우트 캐시도 함께 무효화됩니다. revalidatePath는 특정 URL 경로 단위로 전체 라우트 캐시와 그 경로가 사용한 데이터 캐시를 무효화하는 페이지 중심 방식으로, 태그를 붙여 두지 않은 데이터나 페이지를 통째로 새로 만들어야 할 때 사용합니다. 두 번째 인자로 ''page''를 주면 동적 라우트 패턴 전체를, ''layout''을 주면 그 레이아웃을 공유하는 모든 하위 라우트를 무효화하는데, ''layout''은 범위가 넓어 다음 요청에서 많은 페이지가 재생성되며 서버 부하를 유발합니다. 그래서 태그로 좁게 무효화할 수 있다면 태그를 우선하고, 경로의 ''layout'' 옵션은 최후 수단으로 씁니다.',
 'interview-question/808.mp3'),
(809, 'NEXT_JS', 162, 'EASY', true,
 'Next.js 시간 기반 재검증의 stale-while-revalidate 동작 흐름을 설명해 주세요.',
 '시간 기반 재검증은 revalidate로 지정한 만료 시각이 지나도 캐시를 즉시 버리지 않습니다. 만료 후 들어온 첫 요청에는 사용자를 기다리게 하지 않고 오래된 값을 그대로 반환하고, 백그라운드에서 새 값을 재생성해 캐시를 교체한 뒤 다음 요청부터 새 값을 반영합니다. 이것이 stale-while-revalidate 방식이고 ISR의 기반입니다. 사용자 지연이 없다는 장점이 있지만, 정확히 ''60초 후''가 아니라 ''60초 후 첫 방문 이후''에 갱신되므로 방문이 없는 페이지는 아무리 시간이 지나도 재생성되지 않아 revalidate 값보다 훨씬 오래된 데이터가 보일 수 있습니다. 또 재생성이 실패하면 기존 캐시를 계속 제공합니다.',
 'interview-question/809.mp3'),
(810, 'NEXT_JS', 162, 'EASY', true,
 'Next.js에서 시간 기반 재검증 주기를 설정할 수 있는 두 가지 위치는 무엇이며, 한 라우트 안에 서로 다른 revalidate 값이 섞이면 어떻게 적용되나요?',
 '첫째는 fetch 단위 설정으로, fetch(url, { next: { revalidate: 300 } })처럼 데이터마다 다른 주기를 줄 수 있습니다. 둘째는 라우트 세그먼트 단위 설정으로, page.tsx·layout.tsx·route.ts에서 export const revalidate = 60처럼 선언하면 그 파일 전체의 기본 주기가 되어 이 라우트의 전체 라우트 캐시를 60초마다 재생성합니다. 한 라우트 안에 서로 다른 revalidate 값이 섞이면 가장 짧은 값이 라우트 전체에 적용됩니다. 예를 들어 revalidate = 3600인 페이지에 revalidate: 10인 fetch가 하나 있으면 페이지는 10초마다 재생성됩니다. 참고로 revalidate = 0은 항상 최신인 동적 렌더링을, false는 무기한 캐시를 뜻합니다.',
 'interview-question/810.mp3');

-- 핵심 개념 생성
INSERT INTO interview_question_concept (id, question_id, name, type, display_order)
VALUES
-- 질문 806
(4343, 806, 'Next.js 밖의 CMS 변경은 웹훅이 호출하는 라우트 핸들러에서 재검증함을 설명', 'ESSENTIAL', 1),
(4344, 806, '재검증 라우트 핸들러에 비밀 키 검증이 없으면 재생성 폭주를 당할 수 있음을 언급', 'ESSENTIAL', 2),
(4345, 806, '목록 태그와 개별 글 태그를 함께 붙여 수정된 글의 상세와 목록만 갱신함을 설명', 'ESSENTIAL', 3),
(4346, 806, '라우트 핸들러에서 호출한 재검증은 브라우저 라우터 캐시를 갱신하지 않음을 언급', 'ESSENTIAL', 4),
(4347, 806, 'revalidateTag는 캐시를 지우기보다 stale로 표시해 다음 방문 때 재생성됨을 언급', 'SUPPLEMENTARY', 5),
(4348, 806, 'revalidatePath(''/'', ''layout'')처럼 넓게 무효화하면 서버 부하가 급증함을 언급', 'SUPPLEMENTARY', 6),

-- 질문 807
(4349, 807, '시간 기반은 지정한 초가 지난 뒤 다음 요청에서 재검증이 트리거됨을 설명', 'ESSENTIAL', 1),
(4350, 807, '온디맨드는 revalidateTag·revalidatePath 호출 즉시 캐시를 무효화함을 설명', 'ESSENTIAL', 2),
(4351, 807, '변경 시점을 알 수 없는 외부 데이터·통계에는 시간 기반이 적합함을 언급', 'ESSENTIAL', 3),
(4352, 807, 'CMS·관리자·유저 액션처럼 내 시스템에서 변경되는 데이터에는 온디맨드가 적합함을 언급', 'ESSENTIAL', 4),
(4353, 807, '시간 기반은 최대 revalidate초만큼 신선도가 지연될 수 있음을 언급', 'SUPPLEMENTARY', 5),
(4354, 807, '온디맨드는 변경 지점마다 호출 코드가 필요해 구현 부담이 더 큼을 언급', 'SUPPLEMENTARY', 6),

-- 질문 808
(4355, 808, 'revalidateTag는 태그가 붙은 캐시 항목을 데이터 중심으로 한꺼번에 무효화함을 설명', 'ESSENTIAL', 1),
(4356, 808, 'revalidatePath는 URL 경로 단위로 페이지 중심의 무효화를 수행함을 설명', 'ESSENTIAL', 2),
(4357, 808, '태그로 좁게 무효화할 수 있다면 revalidatePath보다 태그를 우선한다고 언급', 'ESSENTIAL', 3),
(4358, 808, '태그를 붙이지 않은 데이터나 페이지를 통째로 새로 만들 때 revalidatePath를 쓴다고 언급', 'SUPPLEMENTARY', 4),
(4359, 808, '''layout'' 옵션은 레이아웃을 공유하는 모든 하위 라우트를 무효화해 부하를 유발함을 언급', 'SUPPLEMENTARY', 5),

-- 질문 809
(4360, 809, '만료 후 첫 요청에는 기다리지 않고 오래된 캐시 값을 그대로 반환함을 설명', 'ESSENTIAL', 1),
(4361, 809, '백그라운드에서 새 값을 재생성해 다음 요청부터 반영함을 설명', 'ESSENTIAL', 2),
(4362, 809, '방문이 없는 페이지는 시간이 지나도 재생성되지 않음을 언급', 'SUPPLEMENTARY', 3),
(4363, 809, '재생성이 실패하면 기존 캐시를 계속 제공함을 언급', 'SUPPLEMENTARY', 4),

-- 질문 810
(4364, 810, 'fetch의 next.revalidate 옵션으로 데이터마다 다른 주기를 설정함을 설명', 'ESSENTIAL', 1),
(4365, 810, 'export const revalidate로 라우트 세그먼트 단위의 기본 주기를 설정함을 설명', 'ESSENTIAL', 2),
(4366, 810, '값이 섞이면 가장 짧은 revalidate 값이 라우트 전체에 적용됨을 언급', 'ESSENTIAL', 3),
(4367, 810, 'revalidate = 0이 항상 최신인 동적 렌더링을 뜻함을 언급', 'SUPPLEMENTARY', 4),
(4368, 810, 'revalidate = false가 무기한 캐시를 뜻함을 언급', 'SUPPLEMENTARY', 5);
