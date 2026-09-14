# [PLAN-535] 로그 보관 기간 6개월로 제한

> 이슈: #535
> 브랜치: chore/535-log-retention (base: dev, 착수 시 `3eff4a1e`로 fast-forward)
>
> **운영, 개발 Loki는 어느 저장소에도 정의돼 있지 않다.** 저장소의 `infra/loki-config.yml`은 `docker-compose-local-monitor.yml`(로컬)에서만 마운트되고, CD는 이 파일을 서버로 보내지 않는다(`cd-prod.yml:112`, `cd-dev.yml:101`). 운영, 개발 Alloy는 `http://loki:3100`으로 보내지만 운영, 개발 compose에는 Loki 서비스가 없다. 앱센터 중앙 모니터링 레포(`inu-appcenter/appcenter-server-metric-monitoring`)도 Prometheus, Grafana뿐이고 커밋 이력 전체에 Loki가 없다. PR #350이 언급한 서버의 `monitoring-config.yml`은 레포 밖 파일로 보인다.
>
> **사용자 결정(2026-09-14): 기존 구성을 이어받지 않고 이 저장소의 compose와 CD로 Loki를 새로 띄운다.** 서버에 레포 밖 Loki가 남아 있다면 걷어내고, 그 데이터는 옮기지 않는다.

## 목표

운영, 개발 Loki를 이 저장소의 compose와 CD로 띄우고, 6개월(4320h)보다 오래된 로그를 지우게 한다. 개인정보 처리방침에 공개한 서비스 이용기록(로그) 보관 기간과 실제 보관 기간을 맞추고, 운영 로그 설정을 저장소에서 추적할 수 있게 한다.

API, DB, 애플리케이션 코드는 바뀌지 않는다.

## 배치 기준

- **Loki는 운영, 개발 compose에 각각 둔다.** Alloy도 이미 환경별 compose에 따로 있고(`alloy`, `alloy-dev`) CD도 환경별로 돈다. Loki를 같은 compose에 두면 서비스 이름 `loki`가 그 환경 네트워크 안에서만 풀려 `config.alloy`의 `http://loki:3100`을 고칠 필요가 없다. 개발 로그가 운영 Loki에 섞이지도 않는다. 설정 파일은 하나(`infra/loki-config.yml`)를 두 환경이 같이 쓴다
- **컨테이너 이름을 `gravit-loki-prod`, `gravit-loki-dev`로 고정한다.** 중앙 Grafana처럼 여러 네트워크에 동시에 붙는 컨테이너에서는 별칭 `loki`가 운영, 개발(그리고 다른 서비스의 Loki) 중 어디로 풀릴지 정해지지 않는다. 밖에서 부를 때는 호스트 전체에서 유일한 컨테이너 이름을 쓴다(중앙 레포 컨벤션 "컨테이너 이름은 `container_name`으로 고정")
- **3100 포트를 호스트에 열지 않는다.** `auth_enabled: false`라 포트가 열리면 서버에 접근하는 누구나 로그를 조회하고 밀어 넣을 수 있다. Alloy와 Grafana는 도커 네트워크로 접근한다
- **데이터는 이름 있는 볼륨(`loki_data`)에 둔다.** Loki 3.5.5 이미지는 uid 10001로 실행되고 `/loki`가 10001 소유다. 이름 있는 볼륨은 처음 붙을 때 이미지 디렉터리의 소유권을 이어받지만, bind mount(`./loki_data`)는 도커가 root 소유로 만들어 Loki가 쓰지 못한다. 운영 Redis가 bind mount를 쓰는 것과 다르게 가는 이유다
- **`common.path_prefix`를 `/loki`로 옮긴다.** 지금 파일은 `path_prefix: /tmp/loki`라 TSDB 인덱스, WAL, compactor 작업 디렉터리가 볼륨 밖에 생긴다. 이 상태로 컨테이너를 다시 만들면 청크는 남고 인덱스가 사라져 로그가 조회되지 않는다. 볼륨 하나(`/loki`)에 전부 두도록 Loki 이미지 기본 설정과 같은 `common` 블록으로 바꾼다
- **이미지를 `grafana/loki:3.5.5`로 고정한다.** `latest`면 재시작 때 메이저 버전이 바뀌어 설정이 거부될 수 있다. 3.x는 retention을 켤 때 `delete_request_store`를 요구하고 없으면 기동하지 않는다(아래 "검증 근거"). 로컬 모니터링 compose도 같은 버전으로 맞춰 같은 설정 파일을 같은 버전으로 검증한다
- **보관은 compactor retention으로 건다.** `compactor.retention_enabled: true`일 때만 `limits_config.retention_period`가 적용된다. compactor retention은 tsdb 인덱스, 인덱스 주기 24h에서 동작하며 지금 스키마가 그렇다. compactor는 보관 기간을 넘긴 청크를 인덱스에서 빼고 표시한 뒤 `retention_delete_delay`(2h)가 지나야 파일을 지운다. 조회 쪽이 캐시한 인덱스가 갱신되기 전에 청크가 먼저 사라지지 않게 하려는 유예다. 180일이 지난 로그는 최대 `compaction_interval`(10m) + 2h 안에 지워진다
- **사용 통계 전송을 끈다(`analytics.reporting_enabled: false`).** Loki는 기본으로 Grafana Labs에 익명 사용 통계를 보낸다. 로그 내용은 아니지만 개인정보를 다루는 서버에서 외부로 나가는 전송을 둘 이유가 없다
- **CD는 설정 파일 전송과 Loki 기동만 더한다.** SCP 대상에 `infra/loki-config.yml`을 넣고, 인프라 서비스 기동 줄에 `loki`를 넣는다. 첫 배포에서 컨테이너가 새로 만들어지며 설정을 읽는다
- **애플리케이션 로그 파일은 이미 6개월 안이다.** `logback-spring.xml`의 파일 appender 4개가 모두 `maxHistory 7`이다. 이번 작업 대상이 아니다
- **정책 문서 변경 없음.** 서비스 정책 목록에 로그, 인프라 범위가 없고, 보관 기간의 출처는 개인정보 처리방침이다

## 영향 범위

### 신규 파일

없음.

### 수정 파일

**이 저장소**
- `infra/loki-config.yml` - 서버에서 쓰는 설정으로 다시 쓴다. `common` 블록으로 경로를 `/loki` 아래로 모으고 `compactor`, `limits_config`, `analytics` 추가
- `docker-compose-prod.yml` - `loki` 서비스(`gravit-loki-prod`)와 `loki_data` 볼륨 추가
- `docker-compose-dev.yml` - `loki` 서비스(`gravit-loki-dev`)와 `loki_data` 볼륨 추가
- `docker-compose-local-monitor.yml` - Loki 이미지를 `grafana/loki:3.5.5`로
- `.github/workflows/cd-prod.yml` - SCP 대상에 `infra/loki-config.yml`, 인프라 기동에 `loki`
- `.github/workflows/cd-dev.yml` - 같은 변경
- `infra/config.alloy` - `loki.write` 주석만 사실에 맞게 수정

**중앙 모니터링 레포 (D1)**
- `docker-compose.yml` - Grafana를 `gravit-prod`, `gravit-dev` 네트워크에 조인
- `grafana/provisioning/datasources/datasources.yml` - Loki 데이터소스 2개 추가

**서버 (수동, 한 번)**
- 레포 밖 기존 Loki가 있으면 제거 (절 5)

> **DB, API, 애플리케이션 코드, 정책 문서 변경 없음.**

## 구현 계획

### 1. Entity / Repository / Service / Facade / DTO / Controller

해당 없음.

### 2. Loki 설정 - `infra/loki-config.yml`

파일 전체를 아래로 바꾼다.

```yaml
# 운영, 개발 compose의 Loki(gravit-loki-prod, gravit-loki-dev)와 로컬 모니터링 compose가 함께 쓰는 설정이다. CD가 서버로 보낸다.
# 보관 기간 4320h(6개월)는 개인정보 처리방침의 서비스 이용기록 보관 기간이다.

auth_enabled: false

server:
  http_listen_port: 3100

common:
  instance_addr: 127.0.0.1
  path_prefix: /loki
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules

schema_config:
  configs:
    - from: 2025-01-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

compactor:
  working_directory: /loki/compactor
  compaction_interval: 10m
  retention_enabled: true
  retention_delete_delay: 2h
  delete_request_store: filesystem

limits_config:
  retention_period: 4320h

analytics:
  reporting_enabled: false
```

- 기존의 `ingester.lifecycler` 블록과 `storage_config.filesystem`은 `common` 블록이 대신하므로 지운다
- `schema_config`는 그대로 둔다. 새로 띄우는 Loki라 이전 데이터와의 호환을 따질 필요가 없다

### 3. compose

**`docker-compose-prod.yml`** - `alloy` 앞에 서비스 추가, 파일 끝에 `volumes` 추가

```yaml
  loki:
    image: grafana/loki:3.5.5
    container_name: gravit-loki-prod
    command: [ "-config.file=/etc/loki/config.yml" ]
    volumes:
      - ./infra/loki-config.yml:/etc/loki/config.yml:ro
      - loki_data:/loki
    networks:
      - gravit-prod

volumes:
  loki_data:
```

**`docker-compose-dev.yml`** - 같은 서비스를 `container_name: gravit-loki-dev`, `networks: [gravit-dev]`로 추가하고, 기존 `volumes:`에 `loki_data:`를 더한다

- `ports`는 두지 않는다
- `alloy`에 `depends_on`을 걸지 않는다. Alloy는 전송에 실패하면 재시도한다

**`docker-compose-local-monitor.yml`** - `loki.image`를 `grafana/loki:2.9.8`에서 `grafana/loki:3.5.5`로

### 4. CD

**`cd-prod.yml`**
- 112행 SCP: `source: "docker-compose-prod.yml,infra/config.alloy,infra/loki-config.yml"`
- 136행: `docker-compose -f docker-compose-prod.yml up -d --no-deps gravit-redis-prod loki alloy`

**`cd-dev.yml`**
- 101행 SCP: `source: "docker-compose-dev.yml,infra/config.alloy,infra/loki-config.yml"`
- 123행: `docker-compose -f docker-compose-dev.yml up -d --no-deps gravit-redis-dev loki alloy-dev`

**`infra/config.alloy:120`** 주석: `// ← 로컬 Loki 서비스로 보냄` → `// 같은 compose 네트워크의 Loki`

### 5. 서버 정리 (수동, 첫 배포 전 한 번)

레포 밖 Loki가 gravit 네트워크에 붙어 있으면 새 Loki와 별칭 `loki`가 겹쳐 Alloy가 둘 중 아무 쪽으로나 보낸다. 개발 첫 배포 전에 확인하고 걷어낸다.

```bash
docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}' | grep -i -E 'loki|grafana'
docker network inspect prod_gravit-prod dev_gravit-dev --format '{{.Name}}: {{range .Containers}}{{.Name}} {{end}}'
```

- Loki 컨테이너가 없으면 할 일이 없다
- 있으면 그 컨테이너를 띄운 compose(`monitoring-config.yml` 등) 디렉터리에서 내리고, 데이터 볼륨도 지운다. 옮기지 않기로 했으므로 6개월이 넘은 기존 로그도 이것으로 지워진다
- **2026-09-14 `docker ps` 결과:** gravit용 Loki, Grafana 컨테이너는 없다. 서버의 Loki는 다른 서비스 스택의 `bjj-loki`(`grafana/loki:2.9.0`, 4개월 전 생성) 하나다. 생성 시기가 Alloy 두 개, PR #350과 겹치므로 머지 전에 위 `network inspect`로 `bjj-loki`가 gravit 네트워크에 붙어 있지 않은지 확인한다. 붙어 있으면 gravit 로그가 지금까지 그 Loki에 쌓였다는 뜻이다. 그 스택은 우리 소유가 아니므로 내리지 말고, 담당자와 조율해 gravit 네트워크에서 분리(`docker network disconnect`)하고 그 안의 gravit 로그 처리 방법을 정한다
- 그 스택에 Grafana가 같이 있었다면 함께 내린다. 로그 조회는 중앙 Grafana로 옮긴다(D1)

### 6. 중앙 Grafana 연결 (D1, 중앙 레포)

**`docker-compose.yml`** - `grafana.networks`에 두 줄 추가. 네트워크 선언은 Prometheus가 이미 쓰고 있어 그대로다

```yaml
    networks:
      - monitoring
      - uss-prod
      - gravit-prod
      - gravit-dev
```

**`grafana/provisioning/datasources/datasources.yml`** - 두 항목 추가

```yaml
  - name: Loki (gravit-prod)
    type: loki
    access: proxy
    url: http://gravit-loki-prod:3100
    editable: true

  - name: Loki (gravit-dev)
    type: loki
    access: proxy
    url: http://gravit-loki-dev:3100
    editable: true
```

- 주소는 별칭 `loki`가 아니라 컨테이너 이름이다. 이유는 배치 기준에 적었다
- **중앙 레포 CD의 결함에 주의한다.** 배포 스크립트가 `curl -X POST http://localhost:9090/-/reload`가 성공하면 `exit 0`으로 끝나 Grafana 갱신(`docker-compose up -d grafana`)까지 가지 않는다. 호스트 9090에 무언가 응답하면 Grafana 변경이 반영되지 않는다. 배포 후 `docker inspect appcenter-grafana -f '{{json .NetworkSettings.Networks}}'`에 gravit 네트워크가 없으면 서버에서 `docker-compose up -d grafana`를 직접 실행한다. 스크립트 수정은 이번 범위 밖이다
- 이 연결은 gravit 개발 Loki가 뜬 뒤에 적용해야 데이터소스 연결 확인이 통과한다

### 7. 배포 순서

1. 서버 정리 (절 5)
2. 이 PR을 dev에 머지 → `cd-dev` → `gravit-loki-dev` 기동
3. 개발 확인 (검증 "배포 후")
4. 중앙 레포 변경 push → Grafana 재생성
5. 릴리스 → `cd-prod` → `gravit-loki-prod` 기동, 운영 확인

### 8. 커밋 순서

1. `docs: 로그 보관 기간 제한 구현 계획서 추가(#535)` - PLAN-535
2. `chore: Loki 설정에 보관 기간 6개월과 영속 경로 적용(#535)` - `infra/loki-config.yml`, `docker-compose-local-monitor.yml`
3. `cicd: 운영, 개발 compose에 Loki 추가와 설정 파일 배포(#535)` - `docker-compose-prod.yml`, `docker-compose-dev.yml`, `cd-prod.yml`, `cd-dev.yml`, `infra/config.alloy`

중앙 레포는 별도 커밋, 별도 저장소다.

## 결정 필요 (Decisions needed)

- [x] **서버 Loki 설정 관리 방식** - 이 저장소의 compose와 CD로 새로 띄운다. 레포 밖 기존 Loki와 데이터는 이어받지 않는다 (사용자 결정)
- [x] **D1 중앙 Grafana 연결** - 이번에 함께 한다. 중앙 레포에서 Grafana를 gravit 네트워크에 조인하고 Loki 데이터소스 2개를 프로비저닝한다(절 6). 중앙 레포는 별도 커밋, 별도 저장소로 진행한다

## 검증

코드 테스트 대상은 없다. 설정 검증과 배포 후 확인으로 대신한다.

**검증 근거 (계획 단계에서 확인함)**

| 설정 | `grafana/loki:3.5.5` | `grafana/loki:2.9.8` |
|---|---|---|
| 절 2의 설정 | `config is valid` | `config is valid` |
| 보관 설정에서 `delete_request_store`만 뺀 설정 | `CONFIG ERROR: invalid compactor config: compactor.delete-request-store should be configured when retention is enabled` | `config is valid` |

- 3.5.5 이미지: `uid=10001(loki)`, `/loki` 소유자 10001 (이름 있는 볼륨을 쓰는 근거)

**구현 중 (로컬)**

- 수정한 `infra/loki-config.yml`로 `docker run --rm ... grafana/loki:3.5.5 -config.file=... -verify-config`가 `config is valid`
- `docker compose -f docker-compose-prod.yml config`, `docker compose -f docker-compose-dev.yml config`가 오류 없이 풀린다(`llm-net` external은 없어도 `config`는 통과한다)
- **보관 동작 실험 (이슈 Task 3).** 새로 띄우는 Loki에는 6개월 넘은 로그가 없어 운영에서는 당장 삭제를 볼 수 없다. 로컬에서 보관 기간만 줄여 삭제가 실제로 일어나는지 확인한다. 스크래치 설정(커밋하지 않음)으로 `retention_period: 24h`, `compaction_interval: 1m`, `retention_delete_delay: 1m`인 Loki를 띄우고, 라벨이 다른 두 스트림에 30시간 전 로그(`{test="old"}`)와 지금 로그(`{test="new"}`)를 밀어 넣는다. `POST /flush`로 청크를 저장소에 내린 뒤 몇 분 지나 조회하면 `old`는 사라지고 `new`는 남아야 한다. 컨테이너를 몇 분 띄워 둬야 하므로 실행 전에 허락을 받는다

**배포 후 (서버, 개발 → 운영)**

```bash
# Loki가 떠 있고 보관 설정이 들어갔는가
docker run --rm --network dev_gravit-dev curlimages/curl -s http://gravit-loki-dev:3100/ready
docker run --rm --network dev_gravit-dev curlimages/curl -s http://gravit-loki-dev:3100/config | grep -E 'retention_enabled|retention_period|delete_request_store'
docker run --rm --network dev_gravit-dev curlimages/curl -s http://gravit-loki-dev:3100/services   # compactor => Running

# Alloy 로그가 들어오는가
docker run --rm --network dev_gravit-dev curlimages/curl -s 'http://gravit-loki-dev:3100/loki/api/v1/label/env/values'   # ["dev"]
docker logs alloy-dev --since 10m 2>&1 | grep -i -E 'error|loki' | tail -5                                                # 전송 오류 없음
```

- 운영은 네트워크를 `prod_gravit-prod`, 이름을 `gravit-loki-prod`, `alloy`로 바꿔 같은 명령을 돌린다
- 중앙 Grafana Explore에서 `Loki (gravit-dev)`로 `{service="backend"}`가 조회된다

## 나중에 고려할 문제

| 항목 | 현재 기본값 |
|---|---|
| 운영에서의 삭제 확인 | 새 Loki라 6개월 넘은 로그가 없다. 2027-03 무렵 180일보다 오래된 구간 조회가 비어 있는지 한 번 확인한다 |
| 설정 파일만 바뀐 배포 | `docker-compose up -d`는 compose 정의가 바뀔 때만 컨테이너를 다시 만든다. `loki-config.yml` 내용만 바뀌면 전송은 되지만 Loki가 다시 읽지 않는다. `config.alloy`도 같은 기존 성질이다. 설정만 바꿀 때는 서버에서 `docker-compose restart loki`를 실행하거나, 해시를 라벨로 넣어 재생성을 유도하는 방법이 있다 |
| Loki 재시작 시 최근 로그 | WAL이 `/loki/wal`(볼륨 안)이라 재시작 후 다시 읽는다. 볼륨을 지우면 함께 사라진다 |
| Loki 자원 제한 | 없음. Redis처럼 `deploy.resources.limits`를 둘 수 있지만 로그량을 보고 정한다 |
| 디스크 사용량 | 6개월치가 볼륨에 쌓인다. 로그량 추이를 보고 필요하면 알림을 둔다 |
| 컨테이너 재시작 정책 | gravit compose의 다른 서비스와 같이 없다. 서버가 재부팅되면 다음 배포까지 뜨지 않는다 |
| Alloy 이미지 버전 | `grafana/alloy:latest` 그대로다 |
| gravit 네트워크 이름 고정 | 네트워크 이름이 배포 디렉터리 이름에 따라 `prod_gravit-prod`, `dev_gravit-dev`로 정해진다. 중앙 레포 README는 이름을 `name:`으로 고정하라고 권한다. 바꾸면 중앙 레포의 external 이름도 함께 바꿔야 한다 |
| 중앙 레포 CD의 조기 `exit 0` | 절 6 참고. Prometheus 리로드가 성공하면 Grafana 갱신을 건너뛴다 |
| 앱 컨테이너 표준 출력 로그 | 도커 `json-file` 로그에 회전 설정이 없다. 배포마다 앱 컨테이너를 다시 만들어 함께 지워지지만, 6개월 넘게 배포가 없으면 그보다 오래된 로그가 남는다. compose `logging.options`(`max-size`, `max-file`)로 막을 수 있다 |
| Prometheus 보관 기간 | 범위 밖. 지표에는 사용자 식별값이 없다 |

## Deviation Log
> implement 스킬이 구현 중 계획을 벗어난 지점을 여기에 기록한다. (작성 시점엔 비워둔다)
