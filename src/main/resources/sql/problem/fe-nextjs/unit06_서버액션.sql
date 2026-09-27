-- Unit: 서버 액션 (Unit ID: 163)
-- Chapter: Next.js (Chapter ID: 15)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (589, 163, '액션 내부 인가와 점진적 향상'),
       (747, 163, '폼 상태 반환과 Origin 검사'),
       (905, 163, '서버 액션의 요청 흐름과 놓치기 쉬운 함정');

-- =====================================================
-- Lesson 589: 액션 내부 인가와 점진적 향상
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3713, 589, '아래 데이터 변경 수단에 대한 설명으로 옳은 것은?', 'Next.js에서 `"use server"` 지시자를 붙인 비동기 함수는 빌드 시 고유 ID를 부여받고, 클라이언트 번들에는 함수 본체 대신 이 ID만 남는다. 클라이언트에서 이 함수를 호출하면 ID와 인자를 담은 POST 요청이 현재 경로로 전송되고, 서버는 받은 ID로 함수를 찾아 실행한다.', 'OBJECTIVE'),
       (3714, 589, '아래 서버 액션으로 폼을 제출했을 때 일어나는 일로 옳은 것은?', '제목은 항상 유효하고 `db.post.create`는 성공한다고 가정한다.

```tsx
"use server";
import { revalidateTag } from "next/cache";
import { redirect } from "next/navigation";

export async function createPost(formData: FormData) {
  try {
    const post = await db.post.create({
      data: { title: String(formData.get("title")) },
    });
    revalidateTag("posts");
    redirect(`/posts/${post.id}`);
  } catch (e) {
    return { error: "저장에 실패했습니다" };
  }
}
```', 'OBJECTIVE'),
       (3715, 589, '아래 표는 서버 액션 안에서 쓰는 호출들이다. 표를 바탕으로 옳지 않은 것은?', '| 호출 | 효과 |
| --- | --- |
| `revalidateTag("posts")` | "posts" 태그가 달린 데이터 캐시와, 그 데이터를 쓰는 라우트 캐시를 함께 무효화 |
| `revalidatePath("/posts")` | `/posts` 경로의 라우트 캐시 전체를 무효화 |
| `redirect("/posts/1")` | 대상 경로로 이동하고 그 페이지를 최신 상태로 렌더링 |
| `(await cookies()).set(...)` | 쿠키 쓰기. 서버 액션 안에서만 가능하며 응답과 함께 화면이 갱신됨 |', 'OBJECTIVE'),
       (3716, 589, '아래 배포 뒤 발생한 사고의 원인으로 옳은 것은?', '삭제 버튼은 관리자 화면에서만 렌더링했고, 그 화면은 진입할 때 세션을 검사해 관리자가 아니면 되돌려 보낸다. 배포 이틀 뒤 일반 사용자 계정으로 남의 글이 지워지는 사고가 났다.

```tsx
// app/posts/actions.ts
"use server";
import { revalidateTag } from "next/cache";

export async function deletePost(id: string) {
  await db.post.delete({ where: { id } });
  revalidateTag("posts");
}
```', 'OBJECTIVE'),
       (3717, 589, '아래 코드의 빈칸에 공통으로 들어갈 React 훅의 이름은?', '글 작성 폼의 제출 버튼을 별도 컴포넌트로 떼어 냈다. 저장이 1~2초 걸리는 동안 버튼이 계속 눌리는 상태로 남아, 사용자가 연타한 만큼 같은 글이 중복 저장됐다. 아래처럼 고쳐 제출이 끝날 때까지 버튼을 잠그려 한다.

```tsx
"use client";
import { ____ } from "react-dom";

function SubmitButton() {
  const { pending } = ____();
  return <button disabled={pending}>{pending ? "저장 중..." : "작성"}</button>;
}
```', 'SUBJECTIVE'),
       (3718, 589, '아래 폼이 두 경우 모두 동작하게 만드는 웹 개발 원칙을 가리키는 용어는?', '서버 컴포넌트에서 `<form action={createPost}>`로 작성 폼을 렌더링했다. 네트워크가 느린 기기에서 페이지를 열자마자, 즉 JavaScript 번들이 아직 내려오지 않은 상태에서 작성 버튼을 눌렀는데도 요청이 서버에 닿아 글이 저장되고 새 화면이 그려졌다. 번들이 모두 로드된 뒤 같은 버튼을 누르면, 이번에는 페이지 전체가 새로 뜨지 않고 화면 일부만 바뀐다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3713
(10075, 3713, '클라이언트 번들에 함수 본체가 그대로 담기므로, 함수 안에서 참조한 서버 전용 비밀 값도 함께 내려간다.', '번들에 남는 것은 ID뿐이고 본체는 서버에만 있다. 클라이언트로 코드가 내려가는 `"use client"` 경계의 동작을 그대로 옮겨 붙인 오개념이다.', false),
(10076, 3713, '호출하는 쪽에서 GET·PUT·DELETE 등 필요한 HTTP 메서드를 골라 지정할 수 있다.', '메서드를 자유롭게 정하는 쪽은 라우트 핸들러(`route.ts`)다. 액션 호출은 POST 한 가지로 고정돼 있어 조회용 GET 캐싱을 얹을 수 없다.', false),
(10077, 3713, '같은 사용자가 연달아 호출하면 큐에 쌓여 순서대로 처리되므로, 조회에 남용하면 병렬 페칭의 이점을 잃는다.', 'ID로 지목된 함수가 POST 한 줄기를 타고 직렬로 실행된다. 그래서 조회는 서버 컴포넌트나 라우트 핸들러에 맡기고 액션은 변경에 쓰는 것이 원칙이다.', true),
(10078, 3713, '응답에는 함수의 반환값만 담기므로, 화면을 갱신하려면 클라이언트에서 router.refresh()를 따로 불러야 한다.', '액션 응답에는 갱신된 RSC 페이로드가 함께 실려 라우터 캐시까지 바뀐다. 수동 갱신이 필요한 쪽은 라우트 핸들러다.', false),

-- 문제 3714
(10079, 3714, '글은 저장되고 태그 무효화도 끝나지만, 상세 페이지로 이동하지 않고 에러 객체가 반환된다.', 'redirect()는 이동을 예외로 알리는 방식이라, try 안에서 부르면 그 예외를 catch가 삼켜 이동만 사라진다. 앞서 끝난 저장과 재검증은 그대로 남는다.', true),
(10080, 3714, '저장과 태그 무효화까지 함께 취소되고 에러 객체만 반환된다.', 'redirect가 던진 예외는 이미 커밋된 DB 쓰기나 끝난 재검증을 되돌리지 않는다. 예외 전파를 트랜잭션 롤백으로 오해한 것이다.', false),
(10081, 3714, 'redirect가 정상 처리돼 상세 페이지로 이동하고 catch 블록은 실행되지 않는다.', 'redirect를 값을 돌려주는 평범한 함수로 오해한 것이다. 예외로 구현돼 있어 같은 try 블록 안에서는 프레임워크보다 catch가 먼저 잡는다.', false),
(10082, 3714, 'catch가 반환한 객체는 무시되고 브라우저에 500 에러 화면이 표시된다.', '액션이 돌려준 값은 직렬화돼 호출한 쪽으로 전달된다. 이동만 실패했을 뿐 요청 자체는 정상 종료되므로 에러 화면은 뜨지 않는다.', false),

-- 문제 3715
(10083, 3715, '목록·사이드바·상세가 같은 태그를 공유한다면 호출 한 번으로 세 화면의 데이터를 함께 최신으로 되돌릴 수 있다.', '참인 진술이다. 태그 무효화는 경로가 아니라 데이터에 걸리므로, 화면이 흩어져 있어도 같은 태그를 쓰면 한 번에 정리된다.', false),
(10084, 3715, '로그인 쿠키는 서버 컴포넌트를 렌더링하는 도중에도 심을 수 있으므로 액션 밖에서 처리하는 편이 간단하다.', '표에 쿠키 쓰기는 서버 액션 안에서만 가능하다고 적혀 있다. 렌더링 중에는 읽기만 되고 쓰기는 막혀 있어 거짓이다.', true),
(10085, 3715, '상세 페이지 하나만 다시 그리면 되는 상황이라면, 태그보다 경로를 지정하는 쪽이 무효화 범위를 좁게 가져간다.', '참인 진술이다. 태그는 그 태그를 쓰는 라우트까지 번지지만, 경로 지정은 지목한 경로의 라우트 캐시에서 영향이 그친다.', false),
(10086, 3715, '액션에서 재검증을 먼저 하고 이동하면, 이동한 페이지는 갱신된 데이터로 렌더링된다.', '참인 진술이다. 표대로 이동 대상은 최신 상태로 렌더링되므로, 앞서 무효화해 비워 둔 캐시가 새로 채워진 결과를 보게 된다.', false),

-- 문제 3716
(10087, 3716, '액션 ID가 추측하기 쉬운 값이라 노출된 탓이므로, 함수 이름을 알아보기 어렵게 바꾸면 막을 수 있다.', 'ID는 15부터 추측 불가능한 값으로 생성되며, ID를 가린다고 호출 권한이 생기거나 사라지지는 않는다. 난독화를 접근 제어로 착각한 것이다.', false),
(10088, 3716, '인라인 액션이 아니라 별도 파일에서 export한 탓에 클로저 변수 암호화가 적용되지 않았기 때문이다.', '클로저 암호화는 인라인 액션이 캡처한 값이 왕복할 때의 노출을 줄이는 장치일 뿐, 호출한 사람이 누구인지 가려 주지 않는다.', false),
(10089, 3716, 'Origin과 Host 헤더 비교가 기본으로 꺼져 있어서이므로, allowedOrigins를 설정하면 해결된다.', '헤더 비교는 기본 동작이고 걸러 내는 대상은 다른 출처에서 온 위조 요청뿐이다. 정상 화면에서 로그인한 사용자가 보낸 호출은 그대로 통과한다.', false),
(10090, 3716, '액션은 화면과 무관하게 직접 호출되는 POST 엔드포인트인데, 함수 안에 세션·소유권 확인이 없어 임의의 id로 실행됐다.', '버튼을 감추거나 페이지 진입을 막는 것은 화면 단의 조치일 뿐이다. 인증 → 입력 검증 → 인가는 액션 함수 안에서 호출마다 직접 수행해야 한다.', true);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1194, 3717, 'useFormStatus,useFormStatus(),use form status,유즈폼스테이터스', 'react-dom의 useFormStatus는 자신을 감싼 `<form>`의 제출 진행 여부(pending)를 자식 컴포넌트에서 바로 읽게 해 주므로, 제출 버튼만 따로 떼어 내도 상태를 props로 내려받을 필요가 없다. 반드시 `<form>`의 자식 컴포넌트에서 불러야 하고, 폼과 같은 컴포넌트 안에서 부르면 항상 false가 나온다. 액션의 반환값과 진행 상태를 함께 다루는 useActionState는 `[state, formAction, isPending]` 배열을 돌려주므로 코드의 객체 구조 분해와 형태가 다르고(Next.js 14에서는 useFormState), useOptimistic은 서버 응답 전에 화면을 먼저 바꿔 두는 훅이라 중복 제출 자체를 막지는 못한다.'),
       (1195, 3718, '점진적 향상,프로그레시브 인핸스먼트,progressive enhancement,progressive-enhancement,점진적 개선', '`<form action={서버액션}>`은 JavaScript가 아직 없을 때 브라우저의 기본 HTML 폼 POST로 제출되고, 하이드레이션이 끝난 뒤에는 페이지 전환 없는 fetch 방식으로 바뀐다. 기본 기능을 먼저 보장한 다음 환경이 갖춰지면 경험을 얹는 이 방식이 점진적 향상이다. 서버가 보낸 HTML에 이벤트 핸들러를 붙여 상호작용을 살리는 하이드레이션은 이 원칙을 이루는 한 단계일 뿐이라 용어를 바꿔 쓰면 안 되고, 서버 응답 전에 UI를 먼저 갱신하는 낙관적 업데이트와도 구분해야 한다. 클라이언트에서 fetch로 호출하는 라우트 핸들러는 JavaScript가 없으면 아무 요청도 나가지 않아 이 성질을 따로 구현해야 한다.');

-- =====================================================
-- Lesson 747: 폼 상태 반환과 Origin 검사
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4661, 747, '아래 비교표를 바탕으로 옳지 않은 것은?', '| 기준 | 서버 액션 | 라우트 핸들러(`route.ts`) |
| --- | --- | --- |
| 주 용도 | UI에서 시작되는 변경(폼·버튼) | 외부 시스템·모바일 앱·웹훅용 공개 API |
| HTTP 메서드 | POST 고정 | GET·POST·PUT·DELETE 자유 |
| 변경 후 화면 갱신 | 자동(응답에 갱신된 RSC 페이로드 동봉) | 수동(`router.refresh()` 등) |
| 점진적 향상 | 지원(JavaScript 없이도 폼 동작) | 별도 구현 필요 |
| 응답 형식 제어 | 직렬화 가능한 값만 반환 | 상태 코드·헤더·스트리밍까지 제어 |', 'OBJECTIVE'),
       (4662, 747, '아래 폼이 프로덕션에서만 다르게 동작하는 원인으로 옳은 것은?', '로컬 개발 서버에서 제목을 비우고 제출하면 화면에 "제목은 2자 이상이어야 합니다"가 그대로 떴다. 같은 코드를 배포하자 프로덕션에서는 같은 상황에서 "오류가 발생했습니다" 수준의 일반 문구만 뜬다.

```tsx
// app/posts/actions.ts
"use server";

export async function createPost(formData: FormData) {
  const title = String(formData.get("title") ?? "").trim();
  if (title.length < 2) throw new Error("제목은 2자 이상이어야 합니다");
  await db.post.create({ data: { title } });
}
```', 'OBJECTIVE'),
       (4663, 747, '아래 배포 환경에서 폼 제출만 실패하는 원인으로 옳은 것은?', '사내 서비스를 리버스 프록시 뒤에 올렸다. 페이지 조회와 `route.ts` 호출은 정상인데, 같은 화면의 폼 제출만 아무 반응이 없다. 서버 로그에는 실패한 요청의 헤더가 아래처럼 남았다.

```
POST /posts  403
host: 10.0.2.15:3000
origin: https://shop.example.com
x-forwarded-host: shop.example.com
next-action: 7f3c1a...
```', 'OBJECTIVE'),
       (4664, 747, '아래 코드에서 제출 중에도 버튼이 잠기지 않는 원인으로 옳은 것은?', '저장이 2초쯤 걸리는 동안 버튼이 계속 눌리는 상태로 남아, 연타한 만큼 같은 글이 중복 저장된다. 콘솔에 pending을 찍어 보면 제출 중에도 계속 false다.

```tsx
"use client";
import { useFormStatus } from "react-dom";
import { createPost } from "./actions";

export function PostForm() {
  const { pending } = useFormStatus();
  return (
    <form action={createPost}>
      <input name="title" />
      <button disabled={pending}>{pending ? "저장 중..." : "작성"}</button>
    </form>
  );
}
```', 'OBJECTIVE'),
       (4665, 747, '아래 상황에서 액션 끝에 한 줄로 추가한 `next/cache` 함수의 이름은?', '목록 `/posts`, 대시보드 `/dashboard`, 상세 `/posts/[id]` 세 라우트가 `fetch(url, { next: { tags: ["posts"] } })`로 받아 온 같은 글 데이터를 함께 쓴다. 삭제 액션이 데이터베이스만 바꾸던 동안에는 삭제 직후에도 세 화면 모두 지운 글이 그대로 보였고, 브라우저를 강제로 새로 고쳐야 사라졌다. 액션 마지막에 문자열 하나만 넘기는 호출을 한 줄 추가하자, 경로는 하나도 적지 않았는데 세 화면이 모두 최신 목록으로 바뀌었다.', 'SUBJECTIVE'),
       (4666, 747, '아래 화면 동작을 만들려고 쓴 React 훅의 이름은?', '좋아요 버튼을 누르면 서버 액션 왕복에 걸리는 300ms를 기다리지 않고 숫자가 곧바로 1 올라간다. 액션이 실패로 끝나면 숫자는 아무 알림 없이 이전 값으로 되돌아가고, 성공하면 서버가 돌려준 목록의 값으로 자연스럽게 이어진다. 같은 목록을 다른 탭에 열어 두면, 첫 탭에서 숫자가 올라간 뒤에도 액션이 끝나기 전까지는 다른 탭에 그 증가가 보이지 않는다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4661
(12603, 4661, '파일 다운로드처럼 Content-Type과 상태 코드를 직접 지정해야 하는 응답은 액션으로 처리하기 어렵다.', '액션이 돌려줄 수 있는 것은 직렬화 가능한 값뿐이라 응답 헤더나 상태 코드를 건드릴 수 없다. 헤더·스트리밍까지 제어하는 라우트 핸들러의 몫이므로 참인 진술이다.', false),
(12604, 4661, '느린 회선에서 번들이 늦게 내려와도 폼 제출이 서버에 닿게 하려면 액션 쪽이 유리하다.', '액션을 폼에 직접 넘기면 JavaScript가 아직 없을 때 브라우저 기본 폼 POST로 제출된다. 라우트 핸들러는 클라이언트 코드가 요청을 보내야 해 같은 성질을 따로 구현해야 하므로 참이다.', false),
(12605, 4661, '모바일 앱에 목록 조회 API를 열어야 한다면, 이미 만들어 둔 액션을 GET으로 부르도록 안내하면 된다.', '액션 호출은 POST 한 가지로 고정돼 GET으로 부를 수 없고, 쓰임 자체가 UI에서 시작되는 변경이다. 외부 앱에 열어 줄 조회 API는 메서드를 자유롭게 정하는 라우트 핸들러로 만들어야 하므로 거짓이다.', true),
(12606, 4661, '액션으로 글을 지운 뒤에는 목록을 다시 그리려고 클라이언트에서 갱신 함수를 따로 부르지 않아도 된다.', '액션 응답에는 갱신된 RSC 페이로드가 함께 실려 브라우저의 라우터 캐시까지 교체된다. 수동 갱신이 필요한 쪽은 라우트 핸들러라 참인 진술이다.', false),

-- 문제 4662
(12607, 4662, '서버 액션이 던진 에러의 상세 메시지는 프로덕션에서 가려지므로, 사용자에게 보여 줄 검증 결과는 예외가 아니라 반환값으로 돌려줘야 한다.', '에러 문구에는 파일 경로나 쿼리 같은 내부 정보가 섞여 나갈 수 있어 프로덕션은 상세를 일반 문구로 바꾼다. 개발 모드에서만 원문이 보이므로, 화면에 띄울 문구는 값으로 반환해 내려야 한다.', true),
(12608, 4662, '프로덕션 빌드에서는 액션 본체가 클라이언트 번들에 인라인돼 throw가 서버에 닿기 전에 처리된다.', '번들에 남는 것은 액션 ID뿐이고 본체는 빌드 모드와 무관하게 서버에만 있다. 클라이언트 컴포넌트 코드가 번들에 실리는 동작을 액션에 옮겨 붙인 오개념이다.', false),
(12609, 4662, '빌드 최적화가 문자열 리터럴을 압축한 탓이므로, 메시지를 별도 상수로 빼면 원문이 그대로 표시된다.', '문자열을 어디에 두든 프로덕션에서 가려지는 것은 똑같다. 메시지가 사라지는 지점은 빌드가 아니라 서버가 에러를 클라이언트로 돌려주는 순간이다.', false),
(12610, 4662, '프로덕션에서만 Origin과 Host 검사가 켜져 요청이 거부되고, 그 거부 응답의 문구가 대신 표시된 것이다.', '출처 검사는 환경과 관계없이 동작하고, 걸리면 요청 자체가 거부돼 제목 검증까지 가지도 못한다. 정상 화면에서 보낸 제출이 배포만으로 위조 요청이 되지도 않는다.', false),

-- 문제 4663
(12611, 4663, '배포 때마다 액션 ID가 새로 생성돼, 브라우저가 들고 있던 옛 ID를 서버가 찾지 못했다.', '옛 ID로 호출하면 해당 액션을 못 찾는 오류가 나지 폼 제출만 골라 거부되지는 않는다. 로그에 next-action 헤더가 실려 있어 ID 자체는 서버까지 전달됐다.', false),
(12612, 4663, '프록시가 POST 본문을 버퍼링하지 못해 FormData가 비어 도착했고, 액션이 검증에서 요청을 되돌렸다.', '액션 안에서 되돌린 검증 실패는 정상 응답에 값으로 실려 오지 403이 되지 않는다. 로그의 요청은 액션이 실행되기 전 단계에서 끊겼다.', false),
(12613, 4663, '폼이 서버 컴포넌트에서 렌더링돼 하이드레이션 전에는 액션이 연결되지 않아 요청이 빈 경로로 나갔다.', '서버 컴포넌트가 그린 폼도 하이드레이션 전에 일반 HTML 폼 POST로 현재 경로에 닿는다. 로그의 요청 역시 /posts에 정상 도착했다.', false),
(12614, 4663, '액션 요청은 Origin과 Host가 같은지 확인한 뒤 통과시키는데, 프록시가 넘긴 내부 Host와 브라우저 Origin이 달라 거부됐다.', '이 확인은 위조 요청을 막으려고 POST인 액션 호출에만 적용돼, 조회 요청은 멀쩡한데 폼 제출만 막힌다. 프록시 뒤에서는 serverActions.allowedOrigins에 외부 도메인을 등록하면 통과한다.', true),

-- 문제 4664
(12615, 4664, '훅을 react가 아니라 react-dom에서 가져와 폼과 연결되지 않는 구현이 호출됐다.', '이 훅은 원래 react-dom이 제공하므로 import 경로에는 잘못이 없다. 훅마다 제공 패키지가 다른 점을 오류로 착각한 것이다.', false),
(12616, 4664, '훅이 자신을 감싼 상위 폼의 제출 상태를 읽는데, 폼을 직접 그리는 컴포넌트 안에서 불러 늘 false가 나온다.', '제출 중인 폼이 호출 지점보다 위에 있어야 상태가 잡힌다. 버튼을 자식 컴포넌트로 떼어 내 그 안에서 훅을 부르면 pending이 제대로 바뀌어 중복 제출이 막힌다.', true),
(12617, 4664, '폼에 서버 액션을 직접 넘기면 브라우저 기본 폼 POST로 제출돼 진행 상태가 아예 생기지 않는다.', '하이드레이션이 끝난 뒤에는 같은 폼이 페이지 전환 없는 제출로 바뀌고 이때 진행 상태도 만들어진다. 점진적 향상을 위한 대비책을 상시 동작으로 오해한 것이다.', false),
(12618, 4664, '액션이 아무 값도 반환하지 않아 제출이 끝난 시점을 알 수 없으므로, 상태를 반환하도록 고쳐야 한다.', '진행 여부는 반환값이 아니라 폼의 제출 수명주기에서 나온다. 반환값이 필요한 쪽은 에러 문구처럼 결과를 화면에 그려야 할 때다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1510, 4665, 'revalidateTag,revalidatetag,revalidate tag,리밸리데이트태그,리밸리데이트 태그', '태그 무효화는 경로가 아니라 데이터에 걸린다. fetch에 달아 둔 "posts" 태그를 인자로 넘기면 그 태그가 붙은 데이터 캐시와, 그 데이터를 쓰는 라우트 캐시가 함께 무효화된다. 그래서 경로를 하나도 나열하지 않아도 같은 데이터를 쓰는 세 화면이 한 번에 정리된다. 경로를 인자로 받는 revalidatePath였다면 세 경로를 각각 불러야 하고, `/posts/[id]`처럼 값마다 달라지는 동적 경로는 빠뜨리기 쉽다. 클라이언트에서 부르는 router.refresh()는 지금 보고 있는 라우트만 다시 요청하고, redirect는 이동일 뿐 캐시를 비우지 않는다.'),
       (1511, 4666, 'useOptimistic,useoptimistic,use optimistic,유즈옵티미스틱,유즈 옵티미스틱', '서버 응답이 오기 전 화면에만 임시 값을 보여 주고, 액션이 끝나면 실제 상태로 대체하는 훅이다. 실패하면 임시 값이 저절로 버려져 이전 값으로 돌아가므로 좋아요·댓글처럼 실패 확률이 낮은 변경에 쓴다. 다른 탭에 증가가 보이지 않는 것도 이 값이 서버가 아니라 그 화면 안에만 있기 때문이다. 제출 중 여부만 알려 주는 useFormStatus는 화면 값을 미리 바꾸지 못하고, useActionState는 액션이 돌려준 결과와 진행 상태를 다루는 훅이라 응답 전 화면을 앞질러 바꾸는 일과는 구분해야 한다.');

-- =====================================================
-- Lesson 905: 서버 액션의 요청 흐름과 놓치기 쉬운 함정
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5609, 905, '아래 코드의 보안상 문제로 옳은 것은?', '로그인한 사용자가 자기 닉네임을 바꾸는 설정 화면이다.

```tsx
// app/settings/page.tsx (서버 컴포넌트)
import { redirect } from "next/navigation";
import { updateNickname } from "./actions";

export default async function SettingsPage() {
  const session = await getSession();
  if (!session) redirect("/login");
  return (
    <form action={updateNickname}>
      <input type="hidden" name="userId" value={session.userId} />
      <input name="nickname" />
      <button type="submit">저장</button>
    </form>
  );
}
```

```tsx
// app/settings/actions.ts
"use server";

export async function updateNickname(formData: FormData) {
  const session = await getSession();
  if (!session) return { error: "로그인이 필요합니다" };

  const userId = String(formData.get("userId"));
  const nickname = String(formData.get("nickname") ?? "").trim();
  await db.user.update({ where: { id: userId }, data: { nickname } });
  return { ok: true };
}
```', 'OBJECTIVE'),
       (5610, 905, '아래 파일을 점검한 결과로 옳은 것은?', 'Next.js 14 프로젝트의 `app/admin/actions.ts` 파일이다. 첫 줄에 `"use server"`가 있고, 아래 세 비동기 함수를 모두 export한다. 관리자 화면의 클라이언트 컴포넌트는 이 중 `approveRefund`만 import한다.

| 함수 | 하는 일 | 권한 확인 | 부르는 곳 |
| --- | --- | --- | --- |
| `approveRefund(orderId)` | 환불을 승인하고 `grantCredit`으로 적립금 지급 | 관리자 세션 확인 | 관리자 화면의 승인 버튼 |
| `grantCredit(userId, amount)` | 사용자 적립금을 amount만큼 증가 | 없음 | `approveRefund` 내부 |
| `getRefundStats()` | 월별 환불 통계 계산 | 없음 | 관리자 대시보드 서버 컴포넌트 |', 'OBJECTIVE'),
       (5611, 905, '아래 측정 결과가 나온 원인으로 옳은 것은?', '대시보드 위젯 세 개의 데이터를 서버 액션 `getSales`·`getVisitors`·`getOrders`로 받아 오게 만들었다. 액션 하나만 부르면 약 300ms가 걸리는데, 아래처럼 셋을 함께 부르면 약 900ms가 걸린다. 같은 코드에서 액션 대신, 같은 데이터를 돌려주는 라우트 핸들러에 GET 요청을 보내는 함수 세 개로 바꿔 똑같이 `Promise.all`로 묶자 약 300ms에 모두 끝났다.

```tsx
"use client";
import { useEffect, useState } from "react";
import { getSales, getVisitors, getOrders } from "./actions";

export function Dashboard() {
  const [data, setData] = useState(null);
  useEffect(() => {
    (async () => {
      const [sales, visitors, orders] = await Promise.all([
        getSales(),
        getVisitors(),
        getOrders(),
      ]);
      setData({ sales, visitors, orders });
    })();
  }, []);
  // ...
}
```', 'OBJECTIVE'),
       (5612, 905, '아래 폼을 제출할 때 오류가 나는 원인으로 옳은 것은?', 'Next.js 15 프로젝트에서 구독 폼에 검증 오류 문구를 띄우려고 `useActionState`를 붙였다. 액션을 폼에 직접 넘기던 때는 문제없이 저장됐는데, 아래처럼 바꾼 뒤로는 개발 서버에서 폼을 제출할 때마다 서버 로그에 오류가 찍힌다.

```tsx
// app/newsletter/actions.ts
"use server";

export async function subscribe(formData: FormData) {
  const email = String(formData.get("email") ?? "");
  if (!email.includes("@")) return { error: "이메일 형식이 아닙니다" };
  await db.subscriber.create({ data: { email } });
  return { error: "" };
}
```

```tsx
// app/newsletter/form.tsx
"use client";
import { useActionState } from "react";
import { subscribe } from "./actions";

export function NewsletterForm() {
  const [state, formAction, isPending] = useActionState(subscribe, { error: "" });
  return (
    <form action={formAction}>
      <input name="email" />
      <button disabled={isPending}>구독</button>
      {state.error && <p role="alert">{state.error}</p>}
    </form>
  );
}
```

```
TypeError: formData.get is not a function
    at subscribe (app/newsletter/actions.ts:4:32)
```', 'OBJECTIVE'),
       (5613, 905, '아래 파일 첫 줄의 빈칸에 들어갈 코드는?', '상품 상세 화면의 장바구니 버튼을 클라이언트 컴포넌트로 만들고, 아래 파일의 `addToCart`를 import해 `onClick`에서 불렀다.

- 첫 줄을 비워 둔 채 빌드하자, 데이터베이스 드라이버가 브라우저용 번들에 딸려 들어가 `Module not found: Can''t resolve ''net''` 오류로 멈췄다.
- 빈칸을 채우자 빌드가 통과했다. 브라우저용 번들에서 `addToCart`의 코드는 사라지고 `7f3a9c…` 같은 문자열 하나만 남았으며, 버튼을 누르면 `Next-Action: 7f3a9c…` 헤더가 붙은 POST 요청이 현재 경로로 나갔다.

```ts
// app/products/[id]/cart-actions.ts
____
import { db } from "@/lib/db";
import { revalidateTag } from "next/cache";

export async function addToCart(productId: string) {
  const session = await getSession();
  if (!session) return { error: "로그인이 필요합니다" };
  await db.cartItem.create({ data: { productId, userId: session.userId } });
  revalidateTag("cart");
  return { ok: true };
}
```', 'SUBJECTIVE'),
       (5614, 905, '아래 응답 본문에 담겨 온 데이터를 가리키는 용어는?', '글 목록 `/posts`에서 삭제 버튼을 눌러 서버 액션을 실행했다. 액션은 데이터베이스에서 글을 지운 뒤 `revalidatePath("/posts")`를 부르고 `{ ok: true }`를 반환한다. 네트워크 탭에는 요청이 하나만 찍혔고, 뒤따르는 GET 요청도 새로 고침도 없이 목록에서 글이 사라졌다. 이 요청의 응답은 HTML 문서도, 반환값만 담은 JSON도 아니었다.

```
POST /posts  200
content-type: text/x-component

0:{"a":"$@1","f":[…,["$","ul",null,{"children":[["$","li","p2",{"children":"두 번째 글"}]]}]…]}
1:{"ok":true}
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5609
(15131, 5609, '페이지를 거치지 않고 액션을 직접 호출하면, 로그인하지 않은 사람도 닉네임을 바꿀 수 있다.', '액션 첫머리에서 세션을 다시 확인하므로 비로그인 호출은 오류 값만 돌려받고 끝난다. 인증은 갖춰져 있고, 빠진 것은 바꾸려는 대상이 본인인지에 대한 확인이다.', false),
(15132, 5609, '로그인한 사용자라면 요청에 담긴 userId를 다른 값으로 바꿔 보내, 남의 닉네임을 고칠 수 있다.', '숨김 필드도 요청 본문의 일부라 클라이언트가 얼마든지 조작할 수 있다. 바꿀 대상은 폼 값이 아니라 액션 안에서 읽은 session.userId로 정해야 한다.', true),
(15133, 5609, '숨김 필드 값은 렌더링 때 암호화되므로, 클라이언트가 바꿔 보내면 서버에서 복호화에 실패해 요청이 거부된다.', '암호화되는 것은 인라인 액션이 캡처한 클로저 변수다. 폼의 숨김 필드는 HTML에 평문으로 들어가 개발자 도구로 바로 고칠 수 있다.', false),
(15134, 5609, '다른 사이트에 이 폼을 흉내 낸 페이지를 만들어 제출하면, 사용자의 쿠키가 실려 액션이 그대로 실행된다.', '서버 액션은 Origin과 Host 헤더를 비교해 다른 출처에서 온 요청을 거부한다. 사이트 간 요청 위조(CSRF)는 프레임워크가 기본으로 막아 주는 영역이다.', false),

-- 문제 5610
(15135, 5610, '`approveRefund`가 관리자 세션을 확인하므로, 그 안에서 부르는 `grantCredit`도 관리자가 보낸 요청으로만 실행된다.', '세션 확인은 approveRefund를 거치는 경로만 지킨다. grantCredit도 export된 액션이라 자기 ID로 따로 호출될 수 있고, 그 길에는 아무 확인도 없다.', false),
(15136, 5610, '`getRefundStats`는 서버 컴포넌트에서만 부르므로, 브라우저에서 이 함수를 호출할 방법이 없다.', '부르는 곳이 서버여도 "use server" 파일에서 export한 이상 원격 호출 대상이 된다. 통계 같은 조회는 권한 확인을 넣거나 액션 파일 밖의 서버 전용 모듈로 옮겨야 한다.', false),
(15137, 5610, '클라이언트가 import하지 않은 `grantCredit`은 빌드 때 제거되므로, `approveRefund`에서 부르면 함수를 찾지 못해 오류가 난다.', '쓰이지 않는 액션을 걸러 내는 데드 코드 제거는 Next.js 15부터이고, 그것도 클라이언트 번들에서 ID를 빼는 일이다. 서버 코드는 남으므로 서버 안에서 부르면 평범한 함수 호출로 동작한다.', false),
(15138, 5610, '관리자 화면을 거치지 않고 `grantCredit`을 직접 호출하면, 관리자가 아닌 사람도 적립금을 올릴 수 있다.', 'export된 함수는 import 여부와 관계없이 각자 POST 엔드포인트가 되고, Next.js 14까지는 액션 ID도 추측할 수 있었다. 권한 확인이 없는 헬퍼는 액션 파일 밖으로 옮기거나 export하지 않아야 한다.', true),

-- 문제 5611
(15139, 5611, '서버 액션 호출은 한 번에 하나씩 줄 세워 처리되므로, 동시에 불러도 앞 호출이 끝나야 다음 호출이 실행된다.', '서버 액션은 직렬로 실행돼 세 호출의 시간이 그대로 더해졌다(300ms×3). 조회를 액션으로 만들면 병렬 페칭의 이점을 잃으므로, 조회는 서버 컴포넌트나 라우트 핸들러에 맡기고 액션은 변경에 쓴다.', true),
(15140, 5611, '`Promise.all`은 배열의 Promise를 앞에서부터 하나씩 기다렸다가 다음을 시작하므로, 무엇을 넣어도 시간이 더해진다.', 'Promise.all은 이미 시작된 작업들을 한꺼번에 기다릴 뿐 순서대로 실행하지 않는다. 같은 방식으로 묶은 GET 요청 세 개가 약 300ms에 끝난 것이 그 증거다.', false),
(15141, 5611, '브라우저가 한 출처에 동시에 여는 연결 수 제한에 걸려, 나머지 요청이 빈 연결이 생길 때까지 기다렸다.', '연결 수 제한이 원인이라면 같은 출처로 가는 GET 요청 세 개도 똑같이 느려야 한다. 요청 개수가 아니라 액션 호출에만 걸리는 실행 규칙이 시간을 늘렸다.', false),
(15142, 5611, '`useEffect` 안의 비동기 호출은 렌더링이 한 번 끝날 때마다 하나씩 시작되므로, 세 호출이 렌더링 세 번에 나뉘어 처리됐다.', '세 호출은 한 번의 effect 실행 안에서 곧바로 시작된다. 같은 useEffect 구조의 GET 버전이 약 300ms에 끝났으니 렌더링 횟수는 원인이 아니다.', false),

-- 문제 5612
(15143, 5612, '`useActionState`는 `react-dom`에서 가져와야 하는데 `react`에서 가져와, 폼과 연결되지 않은 구현이 호출됐다.', 'useActionState는 React 19부터 react 패키지가 제공한다. react-dom에서 가져오는 것은 useFormStatus로, 두 훅의 제공 패키지를 뒤섞은 오개념이다.', false),
(15144, 5612, '서버 액션은 FormData를 인자로 받을 수 없어, 직렬화 과정에서 폼 데이터가 빈 객체로 바뀌어 도착했다.', 'FormData는 서버 액션이 받는 대표적인 인자다. 본문에서도 폼에 액션을 직접 넘기던 때는 같은 FormData로 정상 저장됐다.', false),
(15145, 5612, '훅에 넘긴 액션은 첫 인자로 이전 상태를 받으므로, formData 자리에 { error: "" } 객체가 들어왔다.', 'useActionState로 감싼 액션은 (이전 상태, FormData) 순서로 호출된다. subscribe(prev, formData)처럼 매개변수를 하나 앞에 더해야 하고, 반환값은 다음 호출의 prev로 이어진다.', true),
(15146, 5612, '`<form action>`에는 서버 액션을 직접 넘겨야 하는데, 훅이 돌려준 `formAction`을 넘겨 FormData가 전달되지 않았다.', '훅을 쓸 때는 돌려받은 formAction을 폼에 넘기는 것이 정석이다. formAction이 FormData를 받아 이전 상태와 함께 원래 액션에 전달한다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1826, 5613, 'use server,"use server",''use server'',"use server";,''use server'';', '파일 첫 줄의 `"use server"`는 그 파일에서 export한 비동기 함수를 모두 서버에서 실행되는 원격 호출 대상으로 노출하라는 선언이다. 그래서 빌드 때 함수마다 액션 ID가 붙고, 브라우저용 번들에는 함수 본체 대신 이 ID만 남는다. 호출은 ID와 인자를 담은 POST 요청으로 바뀌고, 데이터베이스 드라이버는 서버에만 남아 빌드 오류도 사라진다. 이름이 짝처럼 보이는 `"use client"`는 반대로 그 파일을 클라이언트 번들로 들어가는 경계로 선언하는 것이라, 여기에 쓰면 드라이버를 브라우저로 끌어오는 문제가 그대로 남는다. 두 지시자는 대칭이 아니며, `"use server"`를 컴포넌트 파일에 붙인다고 서버 컴포넌트가 되는 것도 아니다.'),
       (1827, 5614, 'RSC 페이로드,RSC페이로드,RSC payload,RSCpayload,React Server Component payload,React Server Components payload,리액트 서버 컴포넌트 페이로드,서버 컴포넌트 페이로드,알에스씨 페이로드', '서버 액션의 응답에는 반환값과 함께, 서버가 다시 렌더링한 서버 컴포넌트 트리의 결과가 RSC 페이로드로 실린다. `text/x-component` 형식의 이 데이터에는 HTML 대신 React 요소 트리가 직렬화돼 있어, 브라우저는 이를 받아 라우터 캐시를 교체하고 바뀐 부분만 다시 그린다. 그래서 액션 안에서 `revalidatePath`를 부르면 별도 재요청 없이 화면이 바뀐다. 첫 방문 때 내려오는 HTML 문서와 달리 이 데이터는 클라이언트 라우터가 직접 소비하며, 이 데이터를 담아 두는 저장소인 라우터 캐시와도 구분해야 한다. 라우트 핸들러에서 같은 재검증을 부르면 응답에 이 데이터가 실리지 않아 `router.refresh()` 같은 추가 갱신이 필요하다.');
