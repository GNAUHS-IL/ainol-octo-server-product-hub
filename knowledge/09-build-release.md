# 09 — 构建与发布

## 知识点：本仓本地 Go build 依赖 OCTO 生态 sibling repo，早期 private preview 可能需要 replace octo-lib

### 结论

`BUILDING.md` 明确指出本项目依赖 `octo-lib` 和 `octo-adapters`，pre-release 阶段 `go build ./...` 可能因 missing go.sum entry 失败；本地构建建议 clone sibling repo，并在 `go.mod` 加 `replace github.com/Mininglamp-OSS/octo-lib => ../octo-lib` 后运行 `go mod tidy && go build ./...`。

### 证据

- 来源: BUILDING.md#L3-L12
- 来源: BUILDING.md#L13-L22
- 来源: BUILDING.md#L23-L27

### 适用范围

适用于解释为什么考试不要求本地完整跑起来，以及本地构建依赖缺口。

### 不确定边界

当前 public 依赖是否已全部可通过 proxy 解析，需要实际 `go build` 验证。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：完整端到端部署不在本仓，而是指向 `Mininglamp-OSS/octo-deployment`

### 结论

`BUILDING.md` 指出完整 OCTO stack（server、admin/web/matter/smart-summary、WuKongIM、MySQL、Redis、MinIO、nginx）应看 `Mininglamp-OSS/octo-deployment`，本仓旧 docker compose stack 已退役。

### 证据

- 来源: BUILDING.md#L33-L41
- 来源: BUILDING.md#L49-L55

### 适用范围

适用于考试答辩中说明“为什么不要求把 octo-server 单独跑起来”。

### 不确定边界

`octo-deployment` 的实际部署文件需另查该仓库，本知识库当前只证明 octo-server 对它的引用关系。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：Dockerfile 是源码内构建，Dockerfile.ghcr 是接收预构建二进制的镜像封装

### 结论

`Dockerfile` 使用 `golang:1.25` 多阶段构建，复制源码后执行 `go build` 生成 `/home/app`；`Dockerfile.ghcr` 基于 `debian:bookworm-slim`，复制 `linux_${TARGETARCH}` 为 main，作为 GHCR/多架构发布形态。

### 证据

- 来源: Dockerfile#L11-L20
- 来源: Dockerfile#L21-L30
- 来源: Dockerfile#L31-L32
- 来源: Dockerfile#L35-L48
- 来源: Dockerfile.ghcr#L1-L10
- 来源: Dockerfile.ghcr#L11-L17

### 适用范围

适用于解释 `Dockerfile` 与 `Dockerfile.ghcr` 的区别。

### 不确定边界

GHCR 工作流文件具体构建产物命名需要继续查 `.github/workflows`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## 知识点：Makefile 的 build 是本地 docker build，push/deploy 指向历史私有 Aliyun registry，非 canonical release surface

### 结论

`Makefile` 中 `build` 只执行 `docker build -t octo-server .`；`push/deploy/deploy-v2` 指向 Aliyun registry。`BUILDING.md` 明确说明这些 push/deploy 目标是历史遗留，不应作为 canonical release surface。

### 证据

- 来源: Makefile#L1-L13
- 来源: BUILDING.md#L57-L62

### 适用范围

适用于构建发布、考试答辩和部署口径。

### 不确定边界

实际 Docker Hub/GHCR 发布流水线需继续查 `.github/workflows/docker-publish.yml`。

### 最后验证

- Commit: 49dc9fd97b49c6c9bad9a0abaefb0b48241e9601
- Time: 2026-09-04T20:10:58+08:00

## V2 深挖补强（2026-09-04）

### 知识点：CI 主流程以 Go 1.25.x 为基线，Build 只做 `CGO_ENABLED=0 go build -v ./...`

#### 结论

`.github/workflows/ci.yml` 定义 `GO_VERSION: 1.25.x`。Build job 使用 `actions/setup-go` 后执行 `CGO_ENABLED=0 go build -v ./...`，说明 CI 的编译基线是全包 Go build，不依赖 Docker 容器构建才能完成基础编译校验。

#### 证据

- 来源: .github/workflows/ci.yml#L37-L37
- 来源: .github/workflows/ci.yml#L95-L100
- 来源: go.mod#L1-L9

#### 适用范围

适用于解释 CI 构建基线、Go 版本要求、为什么本地构建应优先对齐 Go 1.25。

#### 不确定边界

CI 能通过不代表完整 OCTO stack 可用；端到端运行仍依赖 MySQL、Redis、WuKongIM 等服务。

### 知识点：CI 区分 unit 与 E2E，unit 走白名单包列表并开启 race/shuffle

#### 结论

Unit Test job 调用 `ci/run-unit-tests.sh`；该脚本先通过 `ci/list-unit-packages.sh` 解析 `ci/unit-packages.txt` 中的包模式，再执行 `go test -race -shuffle=on -count=1 -timeout 2m`。因此 unit 范围不是 `./...` 全量，而是维护的包白名单。

#### 证据

- 来源: .github/workflows/ci.yml#L102-L111
- 来源: .github/workflows/ci.yml#L112-L121
- 来源: ci/list-unit-packages.sh#L1-L10
- 来源: ci/list-unit-packages.sh#L11-L20
- 来源: ci/list-unit-packages.sh#L21-L21
- 来源: ci/run-unit-tests.sh#L1-L10
- 来源: ci/run-unit-tests.sh#L11-L20
- 来源: ci/run-unit-tests.sh#L21-L26

#### 适用范围

适用于 CI 失败定位、为什么某些包未进入 unit job、是否可把单元测试覆盖等同全仓测试覆盖。

#### 不确定边界

`ci/unit-packages.txt` 的维护策略需人工审查；本条只确认脚本行为。

### 知识点：E2E CI 使用 4 分片，每个分片独立 MySQL/Redis 服务，并逐包重置数据库和 Redis

#### 结论

E2E job 的 matrix 是 4 个 shard，每个 runner 启动独立 MySQL 8.0 与 Redis 7-alpine service。运行脚本会通过 `ci/list-e2e-shard.sh` 从全测试包中减去 unit 包，再按权重分配；`ci/run-e2e-shard.sh` 对每个包执行前都会 drop/create `test` 数据库并 `redis-cli -e FLUSHALL`，再执行 `go test -race -shuffle=on -count=1 -timeout 5m`。

#### 证据

- 来源: .github/workflows/ci.yml#L123-L132
- 来源: .github/workflows/ci.yml#L133-L142
- 来源: .github/workflows/ci.yml#L143-L152
- 来源: .github/workflows/ci.yml#L153-L160
- 来源: .github/workflows/ci.yml#L285-L294
- 来源: .github/workflows/ci.yml#L295-L304
- 来源: .github/workflows/ci.yml#L305-L314
- 来源: .github/workflows/ci.yml#L315-L324
- 来源: .github/workflows/ci.yml#L325-L328
- 来源: ci/list-e2e-shard.sh#L1-L10
- 来源: ci/list-e2e-shard.sh#L11-L20
- 来源: ci/list-e2e-shard.sh#L21-L30
- 来源: ci/list-e2e-shard.sh#L31-L40
- 来源: ci/list-e2e-shard.sh#L41-L50
- 来源: ci/list-e2e-shard.sh#L51-L60
- 来源: ci/list-e2e-shard.sh#L61-L70
- 来源: ci/list-e2e-shard.sh#L71-L73
- 来源: ci/run-e2e-shard.sh#L31-L40
- 来源: ci/run-e2e-shard.sh#L41-L50
- 来源: ci/run-e2e-shard.sh#L51-L60
- 来源: ci/run-e2e-shard.sh#L61-L70
- 来源: ci/run-e2e-shard.sh#L71-L80
- 来源: ci/run-e2e-shard.sh#L81-L90
- 来源: ci/run-e2e-shard.sh#L91-L100
- 来源: ci/run-e2e-shard.sh#L101-L101

#### 适用范围

适用于 E2E flaky 定位、为什么测试之间需要重置 DB/Redis、为什么不能直接打开 `-tags integration`。

#### 不确定边界

WuKongIM 可达性与部分测试 skip 条件需要查对应测试文件；CI 注释已说明部分 issue 仍以 TODO/skip 跟踪。

### 知识点：Docker Publish 真实发布到 Docker Hub `mininglamposs/octo-server`，并按 tag/手动输入做无密钥预校验

#### 结论

`docker-publish.yml` 在 `v*` tag push 或 workflow_dispatch 时触发，镜像名为 `mininglamposs/octo-server`。workflow 先做不持有密钥的 validate job，拒绝非法 tag、可能覆盖 semver alias 的手动输入和未审核 ref；之后才进入需要 `docker-hub-publish` environment 的 secret-bearing build job。

#### 证据

- 来源: .github/workflows/docker-publish.yml#L1-L15
- 来源: .github/workflows/docker-publish.yml#L37-L45
- 来源: .github/workflows/docker-publish.yml#L49-L58
- 来源: .github/workflows/docker-publish.yml#L59-L68
- 来源: .github/workflows/docker-publish.yml#L69-L70
- 来源: .github/workflows/docker-publish.yml#L127-L135

#### 适用范围

适用于发布权限、安全审核、Docker Hub 凭证何时进入 runner、tag 命名规范解释。

#### 不确定边界

GitHub environment `docker-hub-publish` 的 required reviewers/ref allowlist 属仓库设置，源码只能证明 workflow 期望该 environment 存在。

### 知识点：Docker Publish 分架构按 digest 推送，再创建 manifest list；`latest` 只给稳定 semver

#### 结论

Docker Publish 对 `linux/amd64` 与 `linux/arm64` 分别 buildx build，并以 digest 方式 push；随后下载 digest artifacts，使用 `docker/metadata-action` 生成 semver tags，`latest=auto` 使稳定版本发布 `latest`、预发布版本跳过 `latest`，最后用 `docker buildx imagetools create` 创建并推送 manifest list。

#### 证据

- 来源: .github/workflows/docker-publish.yml#L127-L136
- 来源: .github/workflows/docker-publish.yml#L137-L146
- 来源: .github/workflows/docker-publish.yml#L147-L156
- 来源: .github/workflows/docker-publish.yml#L157-L166
- 来源: .github/workflows/docker-publish.yml#L167-L173
- 来源: .github/workflows/docker-publish.yml#L200-L209
- 来源: .github/workflows/docker-publish.yml#L210-L219
- 来源: .github/workflows/docker-publish.yml#L220-L229
- 来源: .github/workflows/docker-publish.yml#L230-L236
- 来源: .github/workflows/docker-publish.yml#L236-L245
- 来源: .github/workflows/docker-publish.yml#L246-L255
- 来源: .github/workflows/docker-publish.yml#L256-L265
- 来源: .github/workflows/docker-publish.yml#L266-L272

#### 适用范围

适用于多架构镜像发布、为什么不同架构先有 digest artifact、为什么 rc tag 不应更新 latest。

#### 不确定边界

本 workflow 当前使用 `Dockerfile` 源码内构建；`Dockerfile.ghcr` 是否被其它复用 workflow 使用需查组织级 reusable workflow 或发布脚本。

### 知识点：Release Publish 不直接构建，要求提供 tagged commit 的成功 CI run id 作为发布证据

#### 结论

`release-publish.yml` 是手动触发，输入包括 release tag 和 `validate_run_id`，说明发布 release 需要提供 tagged commit 上成功 CI run ID 作为 evidence；实际发布逻辑委托给 `Mininglamp-OSS/.github` 的 reusable workflow。

#### 证据

- 来源: .github/workflows/release-publish.yml#L1-L10
- 来源: .github/workflows/release-publish.yml#L11-L20
- 来源: .github/workflows/release-publish.yml#L21-L30

#### 适用范围

适用于 release 归档、考试答辩中“发布必须带 CI 证据”的说明。

#### 不确定边界

reusable workflow 的内部行为不在本仓，需要查 `Mininglamp-OSS/.github` 才能证明 release assets / changelog 细节。

### 知识点：安全与质量工作流覆盖 Docker lint、CodeQL、secret scan、OSV，但 CodeQL 不是 PR 必跑

#### 结论

仓库配置了 Docker Lint，Dockerfile 或 docker/workflow 相关改动触发 reusable docker lint；Secret Scan 在 PR 和 main push 上运行；CodeQL 注释明确为 weekly + manual 深扫，不在每个 PR/push 上跑，因此代码级 SAST 的发现延迟可达约 7 天。CI 中还包含 golangci-lint、若干自定义 lint 和 i18n extract check。

#### 证据

- 来源: .github/workflows/docker-lint.yml#L1-L10
- 来源: .github/workflows/docker-lint.yml#L11-L20
- 来源: .github/workflows/docker-lint.yml#L21-L22
- 来源: .github/workflows/secret-scan.yml#L1-L15
- 来源: .github/workflows/codeql.yml#L1-L10
- 来源: .github/workflows/codeql.yml#L11-L20
- 来源: .github/workflows/codeql.yml#L21-L28
- 来源: .github/workflows/ci.yml#L378-L387
- 来源: .github/workflows/ci.yml#L388-L397
- 来源: .github/workflows/ci.yml#L398-L407
- 来源: .github/workflows/ci.yml#L408-L417
- 来源: .github/workflows/ci.yml#L418-L427
- 来源: .github/workflows/ci.yml#L428-L437
- 来源: .github/workflows/ci.yml#L438-L447
- 来源: .github/workflows/ci.yml#L448-L457
- 来源: .github/workflows/ci.yml#L458-L466

#### 适用范围

适用于安全扫描覆盖范围、PR 必跑项与定时项边界、不能把 CodeQL 说成每 PR 阻断。

#### 不确定边界

reusable workflow 的具体规则、版本更新策略、告警处理 SLA 需查组织级 `.github` 仓库。

### 知识点：Dockerfile 内嵌版本信息来自 git，tag 不存在时降级为 `dev`

#### 结论

`Dockerfile` 在构建阶段读取 `git rev-parse HEAD`、`git log`、`git describe --tags --abbrev=0` 和 `git status`，通过 `-ldflags` 写入 `main.Commit`、`main.CommitDate`、`main.Version`、`main.TreeState`。注释说明 OSS repo 初始 tag 可能为空，因此 `git describe` 失败时 fallback 到 `dev`，避免首个 OSS 构建失败。

#### 证据

- 来源: Dockerfile#L1-L11
- 来源: Dockerfile#L24-L32

#### 适用范围

适用于镜像版本号、`/version` 或日志中 version=dev 的解释、为什么 docker-publish checkout 要 fetch tags。

#### 不确定边界

`main.Version` 等变量在运行时如何暴露需要查 `main.go` 或 health/version endpoint。

### 知识点：Dockerfile 与 Dockerfile.ghcr 仍是两种不同封装模型，当前 Docker Hub 发布使用 Dockerfile

#### 结论

`Dockerfile` 使用 `golang:1.25` 多阶段从源码构建，再把 app/assets/configs 复制进 Alpine runtime；`Dockerfile.ghcr` 则只在 Debian slim 中复制预构建的 `linux_${TARGETARCH}` 为 main。`docker-publish.yml` 的 buildx step 明确 `file: ./Dockerfile`，因此当前 Docker Hub 发布路径是源码内构建模式，而非 `Dockerfile.ghcr` 的预构建二进制封装。

#### 证据

- 来源: Dockerfile#L11-L20
- 来源: Dockerfile#L21-L30
- 来源: Dockerfile#L31-L40
- 来源: Dockerfile#L41-L48
- 来源: Dockerfile.ghcr#L1-L10
- 来源: Dockerfile.ghcr#L11-L17
- 来源: .github/workflows/docker-publish.yml#L163-L172

#### 适用范围

适用于 Dockerfile 差异、为什么 Docker Hub 发布不读取 `linux_amd64` / `linux_arm64` 预构建文件。

#### 不确定边界

`Dockerfile.ghcr` 的历史用途或外部调用链需查旧 workflow、组织级 release workflow 或 release artifacts。

### 知识点：Makefile 的 run-dev 已退役，testenv docker-compose 仅保留旧测试环境入口

#### 结论

Makefile 的 `run-dev` 目标只打印提示，说明 bundled docker-compose stack 已迁移到 `octo-deployment`；`start-test-env` 仍调用 `./testenv/docker-compose.yaml` 启动测试环境。结合 `BUILDING.md`，本仓不应被描述为完整 OOTB 部署仓库，完整 stack 仍指向 `Mininglamp-OSS/octo-deployment`。

#### 证据

- 来源: Makefile#L14-L26
- 来源: BUILDING.md#L33-L41
- 来源: BUILDING.md#L49-L55

#### 适用范围

适用于本地开发、测试环境和正式部署入口区分。

#### 不确定边界

`testenv/docker-compose.yaml` 的实际服务版本和可用性需另查；本条只确认 Makefile 入口。
