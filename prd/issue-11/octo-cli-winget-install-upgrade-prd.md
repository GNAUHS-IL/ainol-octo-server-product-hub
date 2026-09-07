# PRD：octo-cli 支持 Windows winget 安装与升级

## 1. 背景与问题

Windows 用户当前反馈 `octo-cli` 安装需要手动下载发布包并解压。对于 Windows 机器较多的客户、实施和运营场景，这会带来首次接入门槛、版本不一致、升级路径不统一、来源可信与校验口径不清等问题。

本需求按 P0 处理，不是因为“安装更方便”，而是因为 CLI 是 Windows 用户接入 Octo 能力的基础入口；如果安装、升级、版本一致性和来源可信不可控，会影响规模化交付、安全更新和支持排障。

现有仓库已具备发布流程与 release 口径基础：
- Release 发布流程要求提供发布 tag。来源: .github/workflows/release-publish.yml#L3-L9
- Release 发布流程要求提供成功 CI run ID 作为发布证据。来源: .github/workflows/release-publish.yml#L10-L18
- Release 发布流程通过可复用发布流程执行，并授予发布所需内容写入与 CI 读取权限。来源: .github/workflows/release-publish.yml#L23-L31
- Release Drafter 会生成版本名和 tag 模板，支撑 release 版本一致性口径。来源: .github/release-drafter.yml#L1-L9
- 项目 README 明确 release 应作为自包含产品交付。来源: README.md#L147-L147

## 2. 目标与非目标

### 目标

- Windows 用户可以通过 `winget install <package-id>` 安装 `octo-cli`。
- Windows 用户可以通过 `winget upgrade <package-id>` 升级 `octo-cli`。
- `winget` 安装/升级版本与官方 release 版本一致。
- 用户和支持人员能确认安装来源、发布主体、包名、版本号、SHA256 校验和签名状态。
- 已手动下载/解压安装的存量用户能安全迁移到 `winget` 管理版本，并能处理命令路径冲突。
- 文档覆盖 Windows 安装、升级、卸载、迁移、版本检查和来源可信说明。

### 非目标

- 不要求本期同步支持 Chocolatey、Scoop、MSI 全量安装器或企业私有源。
- 不改变 `octo-cli` 核心命令能力。
- 不覆盖非 Windows 平台安装方式改造。
- 不承诺自动清理所有旧手动安装；本期优先提供安全迁移指引和用户确认动作。
- 不展示发布凭证、私钥、token 或任何内部敏感信息。

## 3. 用户故事

### US-01：Windows 用户通过 winget 首次安装
- 角色：作为 Windows `octo-cli` 使用者
- 场景：当我在一台新的 Windows 机器上准备使用 Octo CLI
- 诉求：希望通过系统常用包管理入口安装，不需要手动下载、解压或配置路径
- 价值：以便降低首次接入成本并减少安装错误
- 来源: .github/workflows/release-publish.yml#L3-L9

### US-02：Windows 用户通过 winget 升级
- 角色：作为已安装 `octo-cli` 的 Windows 用户
- 场景：当官方 release 发布新版本
- 诉求：希望通过标准升级入口升级到与官方 release 一致的版本
- 价值：以便及时获得修复并降低版本分散
- 来源: .github/release-drafter.yml#L1-L9

### US-03：实施/IT 管理员批量部署
- 角色：作为客户侧 IT、实施或管理员
- 场景：当需要在多台 Windows 机器上部署 `octo-cli`
- 诉求：希望有统一包名、可信来源、校验方式和迁移说明
- 价值：以便规模化部署并降低供应链误装风险
- 来源: README.md#L147-L147

### US-04：研发与支持定位版本问题
- 角色：作为研发或客户支持人员
- 场景：当用户反馈 CLI 行为异常或升级失败
- 诉求：希望用户能提供明确版本、安装来源和是否为 winget 管理版本
- 价值：以便快速判断是否为受支持版本并给出下一步
- 来源: .github/workflows/release-publish.yml#L10-L18

## 4. 功能需求

### F-01-1 winget 首次安装
- 所属故事：US-01
- 需求描述：Windows 用户应能通过 `winget install <octo-cli-package-id>` 安装 `octo-cli`。
- 业务规则：安装完成后，新终端中应能执行 `octo --version` 或等价版本命令并看到正确版本。
- 边界场景：安装失败时，用户应看到可理解失败原因或下一步建议；不得要求用户回退到不可信下载源。
- 来源: .github/workflows/release-publish.yml#L23-L31

### F-01-2 winget 升级
- 所属故事：US-02
- 需求描述：已安装用户应能通过 `winget upgrade <octo-cli-package-id>` 升级到新版本。
- 业务规则：升级后版本号、官方 release 版本和文档说明应一致；升级不应破坏用户配置、登录态或工作区数据。
- 边界场景：无可升级版本时，用户应看到“已是最新版本 / 无可用升级”的明确提示。
- 来源: .github/release-drafter.yml#L1-L9

### F-01-3 版本一致性
- 所属故事：US-02、US-04
- 需求描述：`winget` 包版本、官方 release 版本、CLI 版本输出和 release notes 应保持一致。
- 业务规则：支持人员应能根据用户提供的版本号判断是否为当前受支持版本。
- 边界场景：如果 `winget` 官方源审核导致版本延迟，文档应说明当前可用版本与官方 release 的关系和下一步。
- 来源: .github/workflows/release-publish.yml#L3-L17

### F-01-4 SHA256 / 签名 / 来源可信
- 所属故事：US-03、US-04
- 需求描述：`winget` manifest 应体现官方认可的包名、发布主体、下载来源和 SHA256 校验；如支持签名，应说明签名校验口径。
- 业务规则：下载来源必须指向官方认可 release，不得指向个人或不可信中转；SHA256 必须与官方发布物一致。
- 边界场景：如本期暂不支持代码签名，应在文档中明确 SHA256 + 官方来源作为首版兜底，并记录后续签名计划。
- 来源: README.md#L147-L147

### F-01-5 旧手动安装迁移
- 所属故事：US-01、US-03
- 需求描述：已手动下载/解压安装的 Windows 用户应能按文档迁移到 `winget` 管理版本。
- 业务规则：文档应说明如何识别旧安装、处理 PATH 冲突、确认当前命令指向 `winget` 管理版本。
- 边界场景：迁移过程不应自动删除用户配置、登录态或工作区数据；清理旧安装必须由用户明确确认。
- 来源: .github/workflows/release-publish.yml#L10-L18

### F-01-6 Windows 安装与迁移文档
- 所属故事：US-01、US-03、US-04
- 需求描述：应补充 Windows 安装、升级、卸载、迁移、版本检查、来源可信和失败处理文档。
- 业务规则：文档需明确推荐命令、包名、发布主体、版本检查方式、SHA256/签名说明、旧安装迁移步骤和支持入口。
- 边界场景：文档不得展示发布凭证、私钥、token 或内部敏感信息。
- 来源: README.md#L147-L147

## 5. 状态与提示

- 可安装：当前 Windows 环境支持通过 `winget install <package-id>` 安装。
- 可升级：存在新版本，可通过 `winget upgrade <package-id>` 升级。
- 已是最新：当前版本与 `winget` 可用版本一致。
- 来源可信：包名、发布主体、下载地址和 SHA256 与官方说明一致。
- 需人工确认：签名缺失、包名冲突、来源不一致、SHA256 不一致、旧安装冲突或审核延迟。
- 迁移中：用户正在从手动安装切换到 `winget` 管理版本，需确认路径指向和配置保留。

## 6. 验收标准

### Windows winget install
- AC-01：在受支持 Windows 环境中，用户可以通过 `winget install <octo-cli-package-id>` 安装 `octo-cli`。
- AC-02：安装后打开新终端，用户可以执行 `octo --version` 或等价版本命令并看到正确版本。
- AC-03：安装过程不要求用户手动下载、解压或手动配置二进制路径。
- AC-04：安装失败时，用户能看到可理解失败原因或下一步建议。

### Windows winget upgrade
- AC-05：当存在新版本时，用户可以通过 `winget upgrade <octo-cli-package-id>` 升级。
- AC-06：升级后版本号与官方 release 版本一致。
- AC-07：升级不破坏用户现有配置、登录态或工作区数据。
- AC-08：无可升级版本时，用户能看到明确的“已是最新版本 / 无可用升级”提示。

### 版本一致性
- AC-09：`winget` manifest 中的版本号与官方 release 版本一致。
- AC-10：同一版本的安装包、CLI 版本输出和 release notes 保持一致。
- AC-11：研发/支持可以根据用户提供的版本号判断是否为当前受支持版本。

### SHA256 / 签名 / 来源可信
- AC-12：`winget` manifest 中配置的 SHA256 与官方发布物一致。
- AC-13：下载来源必须是官方认可 release，不指向个人或不可信中转。
- AC-14：如支持签名，文档说明签名校验口径；如暂不支持签名，文档明确 SHA256 + 官方来源兜底和后续签名计划。
- AC-15：文档明确官方包名、发布主体和可信安装来源，避免用户安装同名非官方包。

### 旧手动安装迁移
- AC-16：文档说明如何检查本机是否存在旧手动解压安装版本。
- AC-17：文档说明如何处理 PATH 中多个 `octo` / `octo-cli` 路径冲突。
- AC-18：迁移到 `winget` 后，用户能确认当前命令指向 `winget` 管理版本。
- AC-19：迁移过程不删除用户配置、登录态或工作区数据，除非用户明确执行清理动作。

## 7. Labels 检查

- type/*：`type/feature`
- priority/*：`priority/P0`
- status/*：当前为 `status/prd-drafting`，完成四件套后应更新为唯一 `status/reviewing`
- area/*：`area/build-release`
- V5 only：未使用 `pm/*`、`source/*`、`evidence/*`、`risk/*`
- Blocking risk：如无法确认官方来源、SHA256、签名口径或旧安装迁移安全边界，建议保持 P0 并进入阻塞处理。

## 8. 研发开放问题与推荐决策

### 研发需确认

1. `winget` 包名采用什么命名，如何避免与现有包冲突。
2. Windows 发布物首选格式是什么，是否满足 `winget` 分发要求。
3. 首版支持 Windows amd64 还是同时支持 arm64。
4. SHA256 由 release 哪一步生成、核验和回填，谁负责最终确认。
5. 是否已有代码签名证书或发布物签名机制；如没有，后续签名计划是什么。
6. CLI 命令名采用 `octo`、`octo-cli` 还是两者都支持。
7. 旧手动安装常见路径有哪些，是否能提供安全检测和迁移提示。
8. `winget upgrade` 如何确保保留配置、认证态和工作区数据。
9. `winget` 官方源审核周期、责任人和失败回滚流程是什么。
10. 是否同步更新官网、README、安装文档和 release notes。

### 推荐决策

建议本期按 P0 进入 Review：首版采用“官方 release 发布物 + winget manifest + SHA256 校验 + Windows 安装/升级/迁移文档”的最小闭环；优先支持 Windows amd64，arm64 由研发确认发布物稳定性后纳入。若短期没有代码签名，不阻塞首版 P0，但必须明确官方来源、SHA256 校验和后续签名计划。旧手动安装采用“检测冲突 + 文档引导 + 用户确认迁移”，不做静默删除。

## 9. 五类风险检查

- 多租户 / Space 隔离：本需求主要是 CLI 分发入口，不应扩大任何 Space 数据访问范围。
- 权限 / ownership：发布主体、包名、release 来源和审核责任人必须清晰，避免用户安装非官方包。
- 安全 / 外部输入 / 凭证：不展示发布凭证、私钥、token；SHA256、签名和来源可信是本需求核心验收。
- 限流 / 防滥用：升级提示应引导用户使用标准渠道，不鼓励反复下载不可信发布物。
- 审计 / 可追溯：发布、SHA256 确认、签名状态、manifest 更新和回滚应能追溯责任人和版本。

## 10. What-only 自检摘要

- 技术 How：通过；未写内部技术方案。
- 引用核验：通过；引用均来自只读目标仓。
- Label 完整性：通过；当前 issue 覆盖 type、priority、status、area。
- 状态真实性：通过；PRD 完成并回填 issue 后，应由 `status/prd-drafting` 更新为唯一 `status/reviewing`。
- 风险提醒 / 待人工确认：有；P0 风险集中在官方来源、SHA256、签名状态、旧安装迁移和审核回滚责任。
