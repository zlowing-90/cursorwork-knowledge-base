# MBM-Backend 项目架构与 Skill 技能体系总览

> 本文档为一次性人工梳理产物，汇总项目技术架构与 `.cursor/skills/` + `.agents/skills/` 下全部 Agent Skill 的用途、触发方式与关键约束，供团队快速查阅"有哪些能力可用、什么时候用哪个"。
>
> 与本文档配套、职责不同的既有文档：
>
> - [`.github/speckit/repo_index/overview.md`](../.github/speckit/repo_index/overview.md) / [`architecture.md`](../.github/speckit/repo_index/architecture.md) —— 由 `speckit-repoindex-*` skill 自动生成的仓库结构 / 架构索引（本文档架构部分对其做了摘要与整合，细节以其为准，且会随代码演进自动刷新）。
> - [`.specify/memory/constitution.md`](../.specify/memory/constitution.md) —— 架构治理"宪法"，本文档不重复其条文，只提炼关键规则。
> - [`docs/skills-usage/`](./skills-usage/) —— 个别技能（`mbm-bugfix-triage`、`mbm-lowcode-page`、`mbm-mask-migrate`）的详细使用教程。
> - [`docs/spec-kit-flow-dingtalk.md`](./spec-kit-flow-dingtalk.md) —— 团队 SDD 流程基线（钉钉协作视角）。
> - [`docs/代码智能工具GitNexus使用指南.md`](./代码智能工具GitNexus使用指南.md) —— GitNexus 单独使用指南。
>
> 生成时间：2026-07-02。

---

## 一、项目定位

**MBM-Backend**（`eman-mbm-parent`）是基于 **Eman 低代码建模框架**构建的制造业务管理（Manufacturing Business Management）后端系统，覆盖基础数据、计划、制造执行、质量、仓储、设备、供应链、工装/模具/量具、AI、公共分析与集成等业务域，采用 **Java 17 + Spring Boot 3.2.12** 单体部署、内部严格 DDD 分层、跨域通过 Dubbo `PublicService` 通信的"模块化单体"架构。

前端页面自 2026-06 起进入"前后端一体交付"阶段：新需求页面由 AI 经 **page-studio**（`.eman-page` 工具链）生成，与后端 Java 实现同属一次规格 - 计划 - 任务 - 实现交付；存量页面维护走 legacy 的 `mbm-lowcode-page`（`scripts/<task>/out/`）过渡轨。

---

## 二、技术栈速览

| 类别 | 技术 | 版本 |
|------|------|------|
| 语言 | Java | 17 |
| 应用框架 | Spring Boot | 3.2.12 |
| 微服务框架 | Spring Cloud | 2023.0.3 |
| 内部低代码平台 | Eman Framework / ModelCore（`eman-modelframework`/`eman-modelengine`） | 4.2.2.3 |
| RPC | Apache Dubbo（`eman-dubbo`） | 4.2.2.3 |
| 构建 | Maven 多模块 | 3.9.x |
| ORM / DAO | MyBatis Flex + 平台 `GeneralEntityService`（统一 CRUD 门面） | — |
| 数据源 | Druid 动态路由（`dynamic-datasource`） | — |
| 数据库 | MySQL 5.7+/8.x（跨库可移植性同时兼容达梦 DM / SQL Server / MariaDB） | — |
| 配置中心 | Nacos（强制） | — |
| 消息队列 | RabbitMQ（Spring AMQP） | — |
| 缓存 | Redis（`eman-starter-redis`/`eman-starter-cache`） | — |
| 任务调度 | PowerJob（`eman-starter-job`） | — |
| 状态机 | Spring State Machine | 3.0.0 |
| 对象转换 | MapStruct | 1.5.5.Final |
| 测试 | JUnit 5 + Mockito + Surefire 3.2.5 | — |
| 覆盖率 | JaCoCo（目标 ≥80%，核心 100%，当前仅出报告未阻断） | 0.8.11 |
| 外部集成 | 金蝶 K3Cloud SDK、SAP、U9C 等（经 `mbm-integration-mng` 防腐层） | — |
| 代码智能 | GitNexus（156335 符号 / 300772 关系 / 300 执行流，MCP 工具） | — |
| 容器化 | Docker（OpenJDK17 基础镜像）+ Jenkins 流水线（华为云 SWR） | — |

---

## 三、模块结构

Maven 多模块工程，三层组织：**一级业务域 cluster**（`mbm-<cluster>`）→ **业务模块 `*-mng`** → **DDD 三件套**（`-interface` / `-model` / `-service`）。

```text
eman-mbm-parent/
├── eman-mbm/            # 启动模块（唯一 main 类 EmanApplication，端口 28087 / Dubbo 38087）
├── mbm-starter/         # 客制化团队聚合 starter
├── mbm-util/            # 通用工具域（GeneralEntityService 等，被所有模块依赖）
├── mbm-basic/           # 00 基础数据域
├── mbm-planning/        # 01 计划域：订单/项目/主计划/排产
├── mbm-manufacturing/   # 02 制造域：设计/工艺/程序/执行/异常
├── mbm-quality/         # 03 质量域：过程质量/外协质量
├── mbm-warehouse/       # 04 仓储域
├── mbm-equipment/       # 05 设备域
├── mbm-supply/          # 06 供应链域：外协
├── mbm-tooling/         # 07 工具域：模具/刀具夹具/量具
├── mbm-purchasing/      # 采购域（新增，未纳入历史索引文档）
├── mbm-ai/              # 08 AI 域
└── mbm-common/          # 88 公共域：公共能力/分析看板/集成/打印
```

每个 `*-mng-service` 内部固定四层包结构：`facade`（低代码入口，主战场）/ `controller`（仅集成·看板·PDA）/ `application`（AppService 用例编排）/ `domain`（DomainService + Entity + Event）/ `eventhandler` / `infrastructure`（`invoke` 跨域防腐层、`mapper` MapStruct、`spi`）/ `job` / `publicservice`（Dubbo Provider）。

### 分层调用链（唯一合法路径）

```text
低代码平台/Web/PDA
   ↓
Facade(@ModelComponent) 或 Controller(@RestController)   ← 接入层
   ↓
AppService(@Service, 事务/用例编排/流程性校验)              ← 应用层
   ↓
DomainService(最小可测单元, 业务规则校验, 数据库CRUD)         ← 领域层
   ↓
GeneralEntityService / MyBatis Flex                        ← 基础设施层
```

跨子域一律经 `PublicService`（Dubbo 契约，`*-interface` 定义）或 `infrastructure/invoke/*ContextInvoke`（防腐层，外域 DTO→本域 VO），**禁止**任何一层跨域直接注入其他域 `DomainService`/`AppService`。

### 关键设计模式

DDD Bounded Context、Anti-Corruption Layer（`ContextInvoke`）、Repository 门面（`GeneralEntityService`）、Service Layer（Facade/App/Domain 三层分离）、State Machine（8+ 处 `@EnableStateMachineFactory`）、Event-Driven（Spring Event + RabbitMQ）、Strategy/Policy、Template Method（`EventExeHandler` 基类）、MapStruct Translator、AOP Aspect（`ViewSourceAspect`）、分布式锁、幂等操作。

---

## 四、治理体系：Constitution（`.specify/memory/constitution.md`，当前 v3.10.0）

项目采用 **Spec-Driven Development（SDD，规格驱动开发）**，`constitution.md` 是全部开发规范的唯一来源，优先级高于其他文档。核心原则（NON-NEGOTIABLE）：

| # | 原则 | 要点 |
|---|------|------|
| I | 四层分层架构 | Facade/Controller → AppService → DomainService → Infrastructure，单向依赖；Facade 禁止直接用 `GeneralEntityService`；DDD 校验职责划分（业务规则校验在 DomainService，流程性校验在 AppService）；更新语义持久化前必须并发存在性二次校验 |
| II | 数据访问规范 | 优先 `GeneralEntityService`；禁止循环内查询/远程调用；禁止全表扫描；字段名必须用 `Entity.FIELD_*` 常量；DomainService 禁止跨子域直接访问 Entity |
| III | 测试优先 | 覆盖率 ≥80%（核心 100%）；每个 `if` 分支双路径覆盖；JUnit5+Mockito；命名 `should_X_when_Y()`；后端单元测试与 UAT（Playwright）两条链路不可互相替代 |
| IV | 安全与性能 | 输入校验、SQL 安全、文件上传校验、凭证禁止硬编码；性能 SLA（列表 p95≤1000ms 等）；事务范围约束；批量 ≤200 条/批 |
| V | **前后端一体交付与低代码平台职责边界** | 前端页面由 AI 经 page-studio（`.eman-page`）生成（`[PAGE]`）；低代码平台内置能力标 `[LOW-CODE]`（不生成代码/页面）；`spec/plan/tasks/data-model` 均须含前端部分；**implement 收尾必须做前后端一致性自检**（绑定名↔data-model 英文名↔`FIELD_*`↔Facade 接口，不一致为 blocker） |
| VI | 可观测性与代码风格 | DomainService ≤800 行/方法≤60 行/圈复杂度≤10；`BusinessException` 中文提示+业务编号（禁用主键 ID）；SLF4J 禁 `System.out`；规格追踪类 Javadoc；分步行内注释；枚举替代魔法值 |
| VII | 禁止代码重复 | 生成 Java 代码前必须先读 `mbm-utils` skill 选型表 |
| VIII | API 一致性 | Controller 统一 `R<T>`；URL kebab-case；Swagger 注解齐全 |
| IX | 规格产物菜单路径治理 | `specs/<一级菜单>/<二级菜单>/<yyyyMM>/<short-name>/`；技术类 `specs/tech/...`；跨菜单 `specs/cross-menu/...` |

---

## 五、Skill 技能体系总览（重点）

项目内 Skill 分布在两处，遵循 **Agent Skills 标准**（Cursor / Claude Code / Codex 通用）：

- `.cursor/skills/` —— 55 个技能，覆盖 Spec-Kit 原生工作流、其扩展包（brownfield/bugfix/git/worktrees/repoindex/memorylint）与 MBM 项目定制技能、GitNexus。
- `.agents/skills/` —— 4 个技能，`page-*` 系列，前端 page-studio 页面生成/改页/诊断判据的**单一真源**。

按用途分为 7 大类，逐一说明。

### 5.1 Spec-Kit 原生工作流（SDD 主链，来源 `github-spec-kit`）

这 9 个技能来自官方 spec-kit 模板，构成"需求→计划→任务→实现"的标准闭环，命令名与 skill 目录一一对应（`/speckit-xxx`）。

| Skill | 作用 | 关键行为 |
|-------|------|---------|
| `speckit-specify` | 自然语言→`spec.md` | 生成 2-4 词短名 → 建 `specs/<dir>/spec.md` → 最多 3 个 `[NEEDS CLARIFICATION]` → 生成 `checklists/requirements.md` 并自校验（最多迭代 3 次） |
| `speckit-clarify` | 澄清 spec 歧义 | 8 大类覆盖扫描（范围/数据模型/交互/非功能/集成/边界/约束/术语）→ 最多 5 个高影响问题，逐题提供推荐项 → 写回 `## Clarifications` 章节并增量更新受影响小节 |
| `speckit-plan` | 生成实施计划 | Technical Context → Constitution Check（门禁）→ Phase0 `research.md` → Phase1 `data-model.md`/`contracts/`/`quickstart.md` → 更新 Agent Context（`.cursor/rules/specify-rules.mdc` 的 SPECKIT 标记段） |
| `speckit-tasks` | 生成 `tasks.md` | 按 User Story（P1/P2/P3…）分阶段生成任务；严格 checklist 格式 `- [ ] T001 [P] [US1] 描述+文件路径`；Setup→Foundational→按故事→Polish |
| `speckit-analyze` | 只读一致性分析 | 交叉核对 spec/plan/tasks 三件套：重复/歧义/欠规格/宪法冲突/覆盖缺口/矛盾，输出严重度分级报告，不改文件 |
| `speckit-checklist` | 生成"需求质量单测" | **核心理念**：checklist 检验"需求写得好不好"而非"实现对不对"，禁止 "Verify/Test/Confirm" 式条目，要求 "Are xxx defined/specified?" 式条目 |
| `speckit-implement` | 按 `tasks.md` 执行实现 | 先查 `checklists/` 完成度门禁 → 逐阶段执行（尊重 `[P]` 并行标记）→ 每完成任务标记 `[X]` |
| `speckit-constitution` | 创建/更新 `constitution.md` | 语义化版本号（MAJOR/MINOR/PATCH）；生成 Sync Impact Report；联动检查依赖模板 |
| `speckit-agent-context-update` | 刷新 Agent 上下文文件中的 SPECKIT 标记段 | 指向最近修改的 `specs/**/plan.md` |

### 5.2 Spec-Kit 扩展：Git 工作流（`speckit-git-*`）

| Skill | 作用 |
|-------|------|
| `speckit-git-initialize` | 首次 `git init` + 初始提交 |
| `speckit-git-feature` | 按 `sequential`/`timestamp` 策略创建 feature 分支（仅创建分支，不建 spec 目录） |
| `speckit-git-validate` | 校验当前分支名是否符合 `NNN-xxx` 或 `YYYYMMDD-HHMMSS-xxx` 规范 |
| `speckit-git-remote` | 探测 GitHub remote（供 issue 创建等下游功能判断是否为 GitHub 仓库） |
| `speckit-git-commit` | Hook 化自动提交（受 `.specify/extensions/git/git-config.yml` 的 `auto_commit` 配置控制，默认关闭） |

> 本仓库 Constitution v3.0.0 已移除"自动创建/切换 Git 分支"相关约束，实际工作流中这组 skill 使用受限，遵循 `AGENTS.md` 的 Git 安全基线（未经明确要求禁止 commit）。

### 5.3 Spec-Kit 扩展：Worktrees（并行开发）

| Skill | 作用 |
|-------|------|
| `speckit-worktrees-create` | 为 feature 分支建独立 git worktree（`sibling`/`nested` 布局），支持多 Agent 并行 |
| `speckit-worktrees-list` | 仪表盘展示所有 worktree 的分支/产物/任务进度/最后活跃时间/合并状态 |
| `speckit-worktrees-clean` | 清理已合并/孤立/陈旧 worktree，动手前必须展示计划并等待确认 |

### 5.4 Spec-Kit 扩展：Brownfield（棕地迁移，官方版）

| Skill | 作用 |
|-------|------|
| `speckit-brownfield-scan` | 只读扫描：技术栈/架构模式/模块地图/命名约定/既有治理文件 |
| `speckit-brownfield-bootstrap` | 基于 scan 结果生成定制化 `constitution.md`/模板/`AGENTS.md`，写前必须展示计划并确认 |
| `speckit-brownfield-validate` | 校验 bootstrap 产物是否仍与实际代码结构一致（检测 drift） |
| `speckit-brownfield-migrate` | 为已存在功能逆向生成 `spec.md`/`plan.md`/`tasks.md`（默认仅三件套），标记 `status: migrated` |

> **MBM 项目对官方 `speckit-brownfield-migrate` 做了强制叠加约束**，见 5.6 节 `mbm-brownfield-full-artifacts`。

### 5.5 Spec-Kit 扩展：Bugfix（缺陷闭环）

| Skill | 作用 |
|-------|------|
| `speckit-bugfix-report` | 缺陷归类（Spec gap / Spec conflict / Implementation drift / Untested flow / Dependency issue）+ 溯源到 spec/plan/tasks，写 `specs/{feature}/bugs/BUG-NNN.md` |
| `speckit-bugfix-patch` | 对 spec/plan/tasks 做**外科手术式**最小修改（新增需求、划掉冲突项、重开误标完成的任务），禁止整份重写 |
| `speckit-bugfix-verify` | 只读校验 patch 后三件套的一致性（覆盖率、重开标注、依赖 DAG 无环） |
| `speckit-bugfix-switch` | 切换到已有 feature 的缺陷上下文（checkout 分支 + 更新 `.specify/feature.json`） |

### 5.6 MBM 项目定制：Brownfield 扩展层（叠加约束，非替代）

这三个技能是**本地对官方 brownfield 能力的加固**，遵循"叠加约束不改上游文件"的设计：

| Skill | 角色边界 |
|-------|---------|
| `mbm-brownfield-full-artifacts` | **单目标产物完整性**：强制官方三件套扩展为 **8 件套**（`spec.md`/`checklists/requirements.md`/`plan.md`/`research.md`/`data-model.md`/`quickstart.md`/`contracts/*.md`（条件性必出）/`tasks.md`），并规定固定写入顺序；`contracts/` 命中 Facade/Controller/PublicService/EventExeHandler/对外 `*-interface` 任一条件即为必出 |
| `mbm-brownfield-migrate-all-auto` | **批量编排层**：仅在用户显式要求"全部迁移/自动继续"时启用，内部链式调用官方 `speckit-brownfield-migrate` + `mbm-brownfield-full-artifacts`；每个目标迁移完成后立即单独提交（不做跨目标合并提交） |
| `mbm-brownfield-complete-unit-tests` | **单测缺口补全**：从已迁移的 Spec Kit 产物出发，比对 `spec.md` 验收标准与 `tasks.md` 测试任务，补 `T-GAP-###` 任务并实现缺失单测；不生成迁移产物、不改动业务代码（除非发现真实缺陷并经用户确认） |

### 5.7 Spec-Kit 扩展：RepoIndex / Memorylint / TasksToIssues

| Skill | 作用 |
|-------|------|
| `speckit-repoindex-overview` | 生成 `.github/speckit/repo_index/overview.md`（项目简介/技术栈/模块结构/快速开始） |
| `speckit-repoindex-module` | 生成单模块 profile（业务场景/技术组件/API/数据模型/文件索引 JSON） |
| `speckit-repoindex-architecture` | 生成 `architecture.md`（分层/依赖图/性能考量/技术债务） |
| `speckit-memorylint-load-agents` | `before_plan` 门禁：强制加载 `AGENTS.md`，缺失则阻断 plan 阶段 |
| `speckit-memorylint-run` | 审计 `AGENTS.md` vs `constitution.md` 的职责边界（架构类规则应在 constitution，基础设施类规则应在 AGENTS），自动搬迁 |
| `speckit-taskstoissues` | 把 `tasks.md` 转成 GitHub Issue（仅当 remote 确认为 GitHub 时执行，防止误建到错误仓库） |

### 5.8 MBM 项目定制：编码规范类（implement 阶段高频引用）

这组技能是编写 Java 代码时的"事实标准"，`constitution.md` 原则 VII 明确要求生成代码前必须先读 `mbm-utils`。

| Skill | 核心内容 |
|-------|---------|
| `mbm-utils` | **工具类选型总表**：`GeneralEntityService`（CRUD 首选）、`CommonUtils`/`CollectionUtils`（集合）、`MathUtils`（精度计算，禁止裸 `+-*/`）、`DateTimeUtils`、`FormUtils`/`GridUtils`/`ResultUtils`（Facade 取参/回写）、`RowStatusUtils`（行状态分组）、`JsonUtils`（禁止裸 fastjson/Jackson）、`IdempotentUtils`（防重提交）、`DistributedLockUtils`（Redisson 分布式锁）、`TreeNodeUtils`/`saveTreeEntity`（树结构）、`StateMachineUtils`、`ThreadLocalHolder` 等 18 类工具的选型表 + 用法示例；并特别标注 `updateEntities`（增量写，null 不清空）vs `saveEntities`（整实体落库，可显式置空）选型坑点 |
| `mbm-code-style` | Javadoc/注释规范、循环禁查询、报错提示语规则、MapStruct 命名规则（`tranXToYList`）与集合/单对象方法配套要求 |
| `mbm-performance-optimization` | 循环内禁数据库查询（先批量查 Map 再循环取值）、批量写入优先、事务范围约束 |
| `mbm-facade-pagination` | Facade 分页标准实现：分页参数**必须**取自 `vo.getPageData()`（禁止 `vo.getBean()` 手动解析）；筛选条件取自 `vo.getSearch()`；单次返回上限 500 条 |
| `mbm-api-integration` | `mbm-integration-mng` 集成接口开发规范：URL 前缀 `/public/v1/integrationmng/*`；Controller→AppService→防腐层强约束；ERP 同步四段式骨架（`queryPendingData`/`processData`/`executeErp`/`batchUpsertSyncResult`）；基础物料推 ERP 的完整调用链与字段映射表 |
| `mbm-sql-portability` | 手写 SQL（`_criteria`/`MetaQueryWrapper` 原始片段）跨库（MySQL/MariaDB/达梦/SQL Server）可移植性红黄绿名单：禁止 `IFNULL`/`NOW()`/`SUBSTR`/`||` 拼接等，日期格式化与分页一律下沉应用层 |

### 5.9 MBM 项目定制：SDD 流程编排与工作量评估

| Skill | 作用 |
|-------|------|
| `mbm-sdd-workflow` | **SDD 总览导航**：串联 `speckit-specify→clarify→plan→tasks→implement` 主链，标注前后端一体（`[PAGE]`/`[FACADE]`/`[DOMAIN]`/`[LOW-CODE]`/`[CONTROLLER]` 五类标签的职责边界与路由），implement 收尾要求前后端一致性自检 |
| `mbm-generate-tests` | 生成 UAT 场景表（Given-When-Then，覆盖 spec 每个用户故事），Gate 3 门禁 |
| `mbm-run-tests` | 按模块跑 `mvn -pl <module> -am test`，填测试执行报告模板，非 0 退出码不得标记通过 |
| `mbm-refresh-env` | 校验本地运行环境（`127.0.0.1:3000`）与可选模型刷新端点（`28087/refresh/model`），可选自动拉起后端 |
| `work-effort-estimation` | 需求类/缺陷类工作量评估双路径：需求类按 9 种功能类型 + 复用度折算（高/中/低 ×0.4/0.7/1.0）；缺陷类按 10 类缺陷 + L1-L5 修复层级 + 迭代清算/详评双模式 |

### 5.10 MBM 项目定制：受限触发技能（禁止模型自动调用，需用户显式 `@`）

以下技能设置了 `disable-model-invocation: true`，**只有用户在消息中显式 `@技能名` 才会加载**，防止因关键词联想被误触发：

| Skill | 用途 | 触发词 |
|-------|------|--------|
| `mbm-bugfix-triage` | 全链路缺陷分析编排（证据采集→路由分类 A/B1/B2/B3/C→修复授权→分析→报告→修复闭环）；整合云效 MCP、MongoDB（页面真源 `devmodel.000000_s_page`）、MySQL（仅 SELECT）、GitNexus、`mbm-lowcode-page`、`speckit-bugfix-*` | `@mbm-bugfix-triage` |
| `mbm-lowcode-page` | Legacy 低代码填页全流程（full/gen/patch/fix/sync/brief 六种子模式），产物限定 `scripts/<task>/out/*.page_content.json`，Agent 对 `metadata/product/**` 只读，入库由用户在设计器完成 | `@mbm-lowcode-page` 或 `gen/fix/sync/brief/full` 子命令 |

### 5.11 MBM 项目定制：数据迁移类

| Skill | 作用 |
|-------|------|
| `mbm-mask-migrate` | 掩码规则（`empf_mask`/`empf_maskrule`）跨库迁移 SQL 生成：强制先询问目标 `tenant_id`/`plant_id`，`id` 严格按源库升序重新生成，禁止用省略号等方式缩写 SQL 输出 |

### 5.12 前端页面生成：page-studio（`.agents/skills/page-*`，单一真源）

这 4 个技能是"前后端一体交付"中前端侧的核心思考逻辑，供 `[PAGE]` 标记的功能在 implement 阶段调用；**判据正文只存 `.agents/skills/` 一份**，`.claude/`、`.cursor/` 下均为薄转发，防止多份判据漂移。

| Skill | 对应流程阶段 | 核心产物 | 关键硬约束 |
|-------|-------------|---------|-----------|
| `page-analyze` | oneshot 步骤 1+3：需求分析与确认 | 自然语言分析稿 + 冻结版《确认单》 | 分析期**不产出任何页面 JSON/代码**；appCode 必须由 `list_apps` 解析，禁止从文档标题猜测；分批提问（每批≤5问）、选项化、不替用户答 |
| `page-assemble` | oneshot 步骤 2：装配生成提示词 | 逐页 `*.prompt.md`（自包含材料 1-6：需求摘录/写法硬约定/标准布局模版/组件契约+运行时 grounding/模型真值/样例页） | 只消费已冻结确认单，不回读 `page-analyze` 判据；产物只是 PROMPT，不生成任何页面 JSON；单页 PROMPT ≤50k token 硬闸 |
| `page-modify` | 改页流程：已有页面定点微调 | 改页确认单 + delta 物料 + 回写后的页面 JSON（同一 pageId） | 核心原则"能 patch 不重生成"；真值只来自平台工具（`get_page`/`get_model_columns`/`list_chains`），溯不到真值立即打断汇报，绝不臆测 |
| `page-diagnose` | 页面渲染缺陷归因 | 归因物料（结论：页面 JSON 问题 vs Saber3 运行时问题 + 源码证据） | 依赖 `@eman-manuverse/saber-runtime` 运行时索引（`graphify query`）；只诊断不改页不改运行时；归因必须有源码证据，溯不到标"待核" |

生成阶段的落库闸门：`hydrate_page`（确定性真值回填，含 `modelId`/`fieldId`/组件实例 `id`）→ `split_page_json` → `plan_page_commit` → `commit_page`，任一环节 `truth.missing` 非空则禁止继续。

### 5.13 GitNexus 代码智能（`gitnexus-*`，全局强制前置）

`AGENTS.md` 顶层规则要求：**编辑任何符号前必须先跑 `impact` 分析**，**提交前必须跑 `detect_changes()`**。

| Skill | 使用场景 |
|-------|---------|
| `gitnexus-guide` | 工具/资源/图谱 Schema 速查入口，任何 GitNexus 任务先读这个 |
| `gitnexus-exploring` | "这段代码怎么工作的"——`query`（按概念找执行流）→ `context`（符号 360° 视图）→ 读 `process` 资源追踪完整链路 |
| `gitnexus-impact-analysis` | "改这个安全吗"——`impact({direction:"upstream"})` 算爆炸半径（d=1 一定坏/d=2 可能受影响/d=3 需测试），HIGH/CRITICAL 必须警告用户 |
| `gitnexus-debugging` | 追踪异常/报错——`query` 找相关执行流 → `context` 看调用者/被调用者 → `cypher` 自定义调用链查询 |
| `gitnexus-refactoring` | 重命名/抽取/拆分——`rename`（多文件协同改名，先 dry_run）、`impact` 找全部依赖方 |
| `gitnexus-pr-review` | PR 审查——`detect_changes({scope:"compare"})` 映射 diff 到受影响执行流，逐符号跑 `impact`，含测试覆盖检查 |
| `gitnexus-cli` | `npx gitnexus analyze/status/clean/wiki/list` 命令行操作，索引过期时重新分析 |

### 5.14 元技能：技能体系一键移植（`springboot-skill-export`）

`.cursor/skills/springboot-skill-export/` 是本次梳理后新增的元技能，专门解决"如何把本项目积累的 59 个技能中与 MBM/Eman 低代码平台无关的通用能力，复用到另一个 Spring Boot 项目"这一问题。核心是对全部 59 个技能做三级分类（详见其 `skill-tiers.md`）：

- **Tier A（38 个，原样整目录复制）**：Spec-Kit 原生工作流全套（31 个）+ GitNexus 代码智能（7 个，条件导出）+ `.specify/` 运行时骨架，均与 MBM 业务无关，零改写即可迁移。
- **Tier B（7 个，模板化改写）**：`mbm-utils`/`mbm-code-style`/`mbm-performance-optimization`/`mbm-sql-portability`/`mbm-run-tests`/`mbm-generate-tests`/`mbm-refresh-env`——方法论通用，但需把 `GeneralEntityService`/`mbm-util` 等 Eman 专有名词替换为目标项目占位符后再落盘（替换规则见其 `placeholder-map.md`）。
- **Tier C（14 个，不导出）**：`mbm-facade-pagination`/`mbm-api-integration`/`mbm-bugfix-triage`/`mbm-lowcode-page`/`mbm-sdd-workflow`/`work-effort-estimation`/3 个 brownfield 加固层技能 + `page-*` 全部 4 个——与 Eman 低代码平台、内部 MCP、MBM 专属业务强耦合，脱离后不可用。

仅当用户显式要求"把这套技能复用/迁移/导出到其他项目"时触发（`disable-model-invocation: true`），流程为：确认目标项目路径与技术栈 → 复制 Tier A → 改写生成 Tier B → 跳过 Tier C 并说明原因 → 落地通用宪法模板骨架与精简版 `AGENTS.md` → 输出导出报告。

### 5.15 Cursor 通用 IDE 技能（非项目定制，全局可用）

以下 13 个技能来自 Cursor IDE 内置技能库（`C:\Users\Administrator\.cursor\skills-cursor\`），与 MBM 业务无关，属于通用 Agent 能力，仅列名备查：`automate`（创建自动化）、`babysit`（PR 保活）、`canvas`（可视化画布）、`create-hook`（创建 Hook）、`create-rule`（创建规则）、`create-skill`（创建技能）、`loop`（定时循环执行）、`review-bugbot`（Bugbot 审查）、`review-security`（安全审查）、`sdk`（Cursor SDK 集成）、`split-to-prs`（拆分 PR）、`statusline`（状态栏定制）、`update-cursor-settings`（编辑器设置）。

---

## 六、Skill 触发方式一览

| 触发方式 | 说明 | 代表 |
|---------|------|------|
| 语义自动触发 | 描述匹配即可能被模型主动加载 | 绝大多数 `mbm-*` 编码规范类、`gitnexus-*`、`speckit-*` |
| 命令式触发 | `/speckit-xxx` 斜杠命令 | 全部 speckit 原生工作流技能 |
| **显式 `@` 才可加载**（`disable-model-invocation: true`） | 防止关键词误触发，涉及跨系统副作用（改代码/写库/调用外部 MCP） | `mbm-bugfix-triage`、`mbm-lowcode-page` |
| 独立会话/子 agent 专属 | 判据只在特定阶段会话生效，跨阶段不复用 | `page-analyze`（分析会话）/`page-assemble`（装配会话）/生成子 agent（只读 PROMPT） |

---

## 七、架构层面的技术债务与改进建议（摘自 `architecture.md`，供参考）

1. `controller/test/*Controller` 等测试触发器混入 `src/main/java`，建议加 `@Profile("dev")` 隔离。
2. `@DSTransactional` 与 `@Transactional` 混用，建议统一约定。
3. 缓存使用未显式化（少见标准 `@Cacheable`），看板类高频读建议引入统一缓存门面。
4. `dependency.check.skip=true` 关闭了 OWASP 依赖漏洞扫描，建议 CI 补齐。
5. JaCoCo 当前只出报告不阻断，建议核心域（execution/planning/warehouse 的 DomainService）分阶段接入 `check` 阈值门禁。
6. Druid 连接池上限 80 在 1000 线程容器规格下偏低，建议按实例规格上调。

---

## 八、快速导览：我该用哪个 Skill？

| 我想做的事 | 应该用 |
|-----------|--------|
| 新需求从 0 开始规格化 | `speckit-specify` → `speckit-clarify` → `speckit-plan` → `speckit-tasks` → `speckit-implement`（导航见 `mbm-sdd-workflow`） |
| 写 Java 代码前确认有没有现成工具类 | `mbm-utils` |
| 写 Facade 分页接口 | `mbm-facade-pagination` |
| 写手写 SQL/`_criteria` 条件 | `mbm-sql-portability` |
| 改动函数/类之前评估影响面 | `gitnexus-impact-analysis` |
| 排查一个报错/Bug 根因（后端） | `gitnexus-debugging`；涉及页面/全链路走 `@mbm-bugfix-triage` |
| 存量页面加字段/改按钮 | `.agents/skills/page-modify` |
| 全新页面从需求到落库 | `.agents/skills/page-analyze` → `page-assemble` → 独立子 agent 生成 → `hydrate_page`→`commit_page` |
| 遗留代码补 Spec Kit 规格产物 | `speckit-brownfield-migrate` + `mbm-brownfield-full-artifacts`（单个）或 `mbm-brownfield-migrate-all-auto`（批量） |
| 遗留功能补单元测试 | `mbm-brownfield-complete-unit-tests` |
| 评估需求/缺陷工时 | `work-effort-estimation` |
| 掩码规则跨库迁移 | `mbm-mask-migrate` |
| 生成/刷新仓库总览文档 | `speckit-repoindex-overview` / `speckit-repoindex-architecture` |
