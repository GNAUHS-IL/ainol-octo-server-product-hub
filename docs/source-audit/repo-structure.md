# octo-server 目标仓结构总览

本页用于从产品运营视角理解 `Mininglamp-OSS/octo-server` 的源码组织，并说明本需求池/知识库为何按当前领域划分。

## 仓库定位

`octo-server` 是 OCTO 平台的 Go 后端，承载 REST / WebSocket API、业务编排、Lobster Agent 调度，以及对 WuKongIM 的控制面集成。

- 来源: README.md#L27-L37

## 运行与构建入口

| 入口 | 说明 | 证据 |
|---|---|---|
| Go module | 模块名为 `github.com/Mininglamp-OSS/octo-server`，Go 版本为 1.25 | 来源: go.mod#L1-L3 |
| 本地构建 | README 给出 `go build -o octo-server .` 与 `./octo-server --config ./configs/tsdd.yaml` | 来源: README.md#L47-L52 |
| 默认依赖 | 默认开发配置依赖本地 WuKongIM 与 MySQL-compatible database | 来源: README.md#L54-L56 |
| 主程序 | `main.go` 是主入口，并通过 blank import 加载内部模块集合 | 来源: main.go#L1-L3；来源: main.go#L23-L30 |
| Docker 镜像 | Dockerfile 使用 Go 1.25 构建，并把 Git commit/version/tree state 编进产物 | 来源: Dockerfile#L11-L20；来源: Dockerfile#L26-L32 |
| CI | CI 在 PR 和 main push 上运行，Go 版本为 1.25.x | 来源: .github/workflows/ci.yml#L7-L15；来源: .github/workflows/ci.yml#L21-L29；来源: .github/workflows/ci.yml#L36-L39 |

## 顶层目录职责

| 目录/文件 | 目标仓作用 | 对应知识库 |
|---|---|---|
| `main.go` | 服务启动、基础设施初始化、运行期控制面 | `area/build-release`、`area/auth` |
| `internal/` | 内部模块装配与启动级编排 | `area/modules` |
| `modules/` | 业务模块主体，包含用户、群、消息、Bot、Webhook、空间等能力 | `area/modules`、各业务 area |
| `pkg/` | 跨模块公共包，例如错误码、认证、i18n、工具能力 | `area/auth`、`area/api-error` |
| `configs/` | 运行配置模板，覆盖 DB、Redis、IM、文件、推送、注册、机器人等 | `area/config`、`area/storage` |
| `.github/workflows/` | CI / 质量门禁 / 构建发布流程 | `area/build-release` |
| `docs/` | 目标仓自带产品/技术设计、runbook 和专题说明 | 按问题映射 |
| `.octospec/` | 历史规格、设计记录和能力演进材料 | 需求分析参考 |

## 模块加载口径

本 hub 判断“模块是否被主入口加载”时，以 `internal/modules.go` 的 blank import 为主，不直接把 `modules/` 目录存在等同于运行启用。

- 来源: internal/modules.go#L22-L30
- 来源: internal/modules.go#L32-L40
- 来源: internal/modules.go#L41-L49
- 来源: internal/modules.go#L50-L58
- 来源: internal/modules.go#L59-L66
- 来源: internal/modules.go#L67-L77

## 配置面

`configs/tsdd.yaml` 是理解部署和外部依赖的关键入口。它覆盖基础服务配置、Webhook 签名、WuKongIM、数据库、短信、文件服务、推送、注册、内置账户、机器人、第三方登录和缓存等段落。

- 来源: configs/tsdd.yaml#L1-L13
- 来源: configs/tsdd.yaml#L15-L29
- 来源: configs/tsdd.yaml#L52-L59；来源: configs/tsdd.yaml#L60-L67
- 来源: configs/tsdd.yaml#L69-L75
- 来源: configs/tsdd.yaml#L135-L145；来源: configs/tsdd.yaml#L146-L158；来源: configs/tsdd.yaml#L159-L170
- 来源: configs/tsdd.yaml#L172-L181；来源: configs/tsdd.yaml#L182-L191；来源: configs/tsdd.yaml#L192-L205
- 来源: configs/tsdd.yaml#L206-L219；来源: configs/tsdd.yaml#L220-L231；来源: configs/tsdd.yaml#L233-L243；来源: configs/tsdd.yaml#L245-L251

## 对本 hub 的保留原则

基于目标仓结构，本 hub 保留三类资产：

1. **可回答问题的知识库**：`knowledge/`。
2. **可追溯源码的结构化索引**：`docs/source-audit/*-index.md` 与本页。
3. **可承接反馈的需求池流程**：issue templates、labels、PRD、Review、状态扫描脚本。

不再保留大段 grep 输出、源码编号片段、现场沟通规则、一次性初始化脚本等过程材料。
