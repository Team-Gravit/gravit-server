---
description: GitHub Secrets 네이밍 규칙과 발급, 교체 절차
---

# Secret Convention

배포에 쓰이는 값은 GitHub Secrets에 두고, CD 워크플로의 `microsoft/variable-substitution` 단계에서
`application-{profile}.yml`에 주입한다. 이 문서는 그 시크릿의 이름을 어떻게 짓고 어떻게 교체하는지를 정한다.

## 네이밍 규칙

- 환경에 따라 **값이 달라야 하는** 시크릿은 `DEV_`, `PROD_` 접두사를 붙인다
- 환경과 무관하게 같은 값을 쓰는 시크릿만 접두사 없이 쓴다
- 접두사 없는 이름을 두 워크플로가 함께 참조하고 있다면, 그것은 "환경 간 공유"라는 뜻이다.
  공유해도 되는 값인지 확인하고, 아니면 접두사를 붙여 분리하라

## 현재 분리 상태

### 환경별로 분리된 값

| 시크릿 | dev | prod |
|---|---|---|
| JWT 서명 키 | `DEV_JWT_SECRET` | `PROD_JWT_SECRET` |
| DB 접속 URL | `POSTGRESQL_DEV_URL` | `POSTGRESQL_URL` |

### 아직 분리되지 않은 값

아래는 dev와 prod가 같은 시크릿을 참조한다. 분리는 #467에서 다룬다.

- OAuth 클라이언트: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `KAKAO_CLIENT_ID`, `KAKAO_CLIENT_SECRET`, `NAVER_CLIENT_ID`, `NAVER_CLIENT_SECRET`, `KAKAO_NATIVE_APP_KEY`
- 어드민 화이트리스트: `ADMIN_BOOTSTRAP_EMAILS`
- DB 계정: `POSTGRESQL_USERNAME`, `POSTGRESQL_PASSWORD`
- 메일: `STMP_PASSWORD`
- Firebase: `FIREBASE_SERVICE_ACCOUNT`

### 의도적으로 공유하는 값

- LLM 게이트웨이 키: `LITELLM_MASTER_KEY`. dev와 prod가 같은 서버의 LiteLLM 게이트웨이(`llm-net` 네트워크 상 `litellm-gw`)를 함께 쓰므로 값이 하나다.
  `spring.ai.openai.api-key`에 주입되며, 비어 있으면 Spring AI 스타터가 기동 자체를 거부하니 워크플로 머지 전에 반드시 등록하라.

`DEV_GOOGLE_REDIRECT_URI`, `GOOGLE_REDIRECT_URI` 등 redirect-uri 계열 6종은 워크플로가 주입하지만
런타임에서 참조하지 않는다. 실제 redirect_uri는 요청의 `dest` 파라미터로 결정된다. 이 역시 #467 범위다.

## JWT 시크릿 교체 절차

1. 새 값을 생성한다. HS256 대칭키이므로 최소 32바이트 이상의 무작위 문자열을 쓴다
   ```bash
   openssl rand -base64 48
   ```
2. GitHub 저장소 Settings > Secrets and variables > Actions 에서 새 이름으로 등록한다
3. CD 워크플로의 `jwt.secret` 참조를 새 이름으로 바꾼다
4. 배포한다. dev는 `dev` 브랜치 push, prod는 Release 발행이 트리거다
5. 배포된 서버가 정상 동작하는 것을 확인한 뒤 구 시크릿을 삭제한다

> **경고**: JWT 서명 키를 교체하면 그 환경에서 이미 발급된 액세스 토큰과 리프레시 토큰이 전부 무효가 된다.
> Redis에 저장된 리프레시 토큰도 구 키로 서명되어 있어 재발급에 쓸 수 없다.
> prod에서 교체하면 **전체 사용자가 로그아웃**되므로, 교체가 꼭 필요한 상황인지 먼저 판단하라.

> 워크플로 머지와 시크릿 등록의 순서가 어긋나면 `jwt.secret`이 빈 값으로 주입된다.
> 등록을 먼저 하고 워크플로를 머지하라.
