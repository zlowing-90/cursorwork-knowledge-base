# 技能三级分类表（Tier A / B / C）

本文件是 `springboot-skill-export` 的判据正文，供导出流程第 0 步完整读取。分类依据唯一标准：**脱离 MBM 项目自研的 Eman 低代码平台/内部业务基础设施后，这个技能还能不能在一个"普通" Spring Boot 项目里正常工作**。

- **Tier A（原样复制）**：技术栈无关或仅依赖 Spring Boot/Maven/Git 通用生态，零改写即可在任意 Java 项目使用。
- **Tier B（模板化改写）**：核心方法论通用，但正文里混有 MBM/Eman 专有类名、包名、命令，需要替换为占位符后目标项目自行补全。
- **Tier C（不导出）**：与 MBM 自研平台（Eman 低代码引擎、page-studio、`eman-page`/`saber-runtime` 运行时）或内部专属基础设施（云效 MCP、MongoDB 页面真源库、`mbm-integration-mng` 具体包结构）强耦合，脱离后无法运行或毫无意义。

---

## Tier A —— 原样复制（共 38 个技能目录 + `.specify/` 运行时骨架）

### `.specify/` 运行时骨架（非 skill 目录，但导出必须一并带走，否则 speckit-* 技能无法运行）

| 路径 | 说明 |
|------|------|
| `.specify/extensions/agent-context/` | 官方扩展：Agent 上下文刷新 |
| `.specify/extensions/brownfield/` | 官方扩展：棕地迁移三件套 |
| `.specify/extensions/bugfix/` | 官方扩展：缺陷闭环四件套 |
| `.specify/extensions/git/` | 官方扩展：Git 工作流五件套 |
| `.specify/extensions/memorylint/` | 官方扩展：Agent 记忆边界审计 |
| `.specify/extensions/repoindex/` | 官方扩展：仓库索引三件套 |
| `.specify/extensions/worktrees/` | 官方扩展：Git worktree 并行开发 |
| `.specify/templates/*.md`（6 份） | 官方模板：spec/plan/tasks/checklist/constitution/agent-file |
| `.specify/scripts/powershell/*.ps1`（6 份） | 官方脚本：建 feature 分支、setup-plan、setup-tasks、前置条件检查、覆盖率聚合 |
| `.specify/extensions.yml` | 扩展安装清单 + hooks 编排配置（内容是官方 hook 名，无 MBM 业务字段） |
| `.specify/init-options.json` | speckit 初始化选项（ai/脚本类型/编号策略，无业务字段） |
| `.specify/workflows/speckit/workflow.yml` | 官方默认工作流编排 |
| `.specify/integrations/*.manifest.json` | Agent 集成清单 |

**不要复制**：`.specify/memory/constitution.md`（MBM 专属条文）、`.specify/feature.json`（当前会话指针）、`.specify/reports/`（本项目测试/治理报告痕迹）、`.specify/workflows/runs/`（执行日志）、`.specify/workflows/mbm-workflow/`（MBM 定制工作流编排）。

### Spec-Kit 原生工作流（9 个）

`speckit-specify`、`speckit-clarify`、`speckit-plan`、`speckit-tasks`、`speckit-analyze`、`speckit-checklist`、`speckit-implement`、`speckit-constitution`、`speckit-agent-context-update`

### Spec-Kit 扩展（21 个）

`speckit-git-initialize`、`speckit-git-feature`、`speckit-git-validate`、`speckit-git-remote`、`speckit-git-commit`、`speckit-worktrees-create`、`speckit-worktrees-list`、`speckit-worktrees-clean`、`speckit-brownfield-scan`、`speckit-brownfield-bootstrap`、`speckit-brownfield-validate`、`speckit-brownfield-migrate`、`speckit-bugfix-report`、`speckit-bugfix-patch`、`speckit-bugfix-verify`、`speckit-bugfix-switch`、`speckit-repoindex-overview`、`speckit-repoindex-module`、`speckit-repoindex-architecture`、`speckit-memorylint-load-agents`、`speckit-memorylint-run`、`speckit-taskstoissues`

（以上合计 22 个，加原生 9 个，共 31 个；均为 `github-spec-kit`/官方扩展包原文，通读全部技能未发现任何 MBM 专有名词，可整目录复制。）

### GitNexus 代码智能（7 个，条件导出）

`gitnexus-guide`、`gitnexus-exploring`、`gitnexus-impact-analysis`、`gitnexus-debugging`、`gitnexus-refactoring`、`gitnexus-pr-review`、`gitnexus-cli`

> 前提：目标项目已装或计划装 GitNexus MCP 并对该仓库单独跑过索引（`gitnexus analyze`）。未装则整组跳过，避免导出后引用一个不存在的 MCP 工具。GitNexus 本身是通用代码知识图谱工具，与 Spring Boot/Java 无强绑定，甚至跨语言可用。

**Tier A 合计：31（speckit）+ 7（gitnexus，条件）= 38。**

---

## Tier B —— 提炼方法论后模板化改写（7 个）

| 源技能 | 通用部分（保留） | MBM/Eman 专有部分（替换为占位符或整段删除） | 目标文件名建议 |
|--------|-----------------|---------------------------------------------|---------------|
| `mbm-code-style` | Javadoc 强制、循环内禁查询、MapStruct 命名规则 `tranXToY[List]`、代码自查清单 | `mbm-util` 模块名、`com.eman.mbm.util.entity.GeneralEntityService` 具体类名 | `java-code-style` |
| `mbm-performance-optimization` | "循环前批量查询、循环内只做内存查找+写库"原则、批量写入优先、事务范围约束 | 示例代码里的 `generalEntityService.insert/insertBatch`、`deptService.findByName` | `java-loop-performance` |
| `mbm-sql-portability` | 跨库（MySQL/PgSQL/SQLServer/达梦等）ANSI SQL 函数绿区/黄区/红区白黑名单，是纯 SQL 知识，与 Eman 无关 | "适用范围"一节里的 `GeneralEntityService._criteria/_orderBy/_groupBy/_having`、`MetaQueryWrapper`、`MetadataQueryBuilder.selectExpression` 等 Eman 专有 API 入口点描述 | `sql-cross-db-portability` |
| `mbm-run-tests` | Maven 模块化测试执行流程、Surefire/JaCoCo 报告收集、"非 0 退出码不得标记通过"纪律 | "MBM"措辞、`compatibility: MBM-Backend local workflow` | `maven-run-tests` |
| `mbm-generate-tests` | 从 spec 的用户故事生成 Given-When-Then UAT 场景表的方法论 | "Gate 3"、MBM 专属评审流程措辞 | `generate-uat-scenarios` |
| `mbm-refresh-env` | "校验本地端口可达性 + 可选调用刷新端点"的环境自检模式 | 具体端口 `127.0.0.1:3000`/`28087/refresh/model` | `refresh-local-env` |
| `mbm-utils`（仅方法论段落，不整份复制） | "生成代码前先查工具类选型表，禁止重复造轮子"的方法论 + 选型表**表头结构**（场景/工具类/包路径三列） | 表格全部 18 行具体工具类清空为空表，交目标项目盘点自己的 `common`/`utils` 包后自行填表 | `common-utils-selection` |

**棕地治理附加约束骨架（可选，仅 brownfield 场景生成）**：源自 `mbm-brownfield-full-artifacts`（强制产物完整性清单的思路）+ `mbm-brownfield-migrate-all-auto`（批量编排、逐目标独立提交的思路）+ `mbm-brownfield-complete-unit-tests`（比对验收标准补测试缺口任务的思路）三者方法论的合并骨架，"8 件套清单"与 `specs/<menu>/<yyyyMM>/` 路径规则清空为占位符。目标文件名建议 `brownfield-governance-overlay`。

---

## Tier C —— 不导出（14 个）

| 技能 | 不可移植原因 |
|------|-------------|
| `mbm-facade-pagination` | 依赖 Eman 低代码 `@ModelComponent` Facade 契约（`this.vo.getPageData()`/`getSearch()`），普通 Spring Boot 项目没有这层抽象 |
| `mbm-api-integration` | 依赖 `mbm-integration-mng` 具体包结构、金蝶/SAP 对接细节 |
| `mbm-mask-migrate` | 依赖 MBM 特定的 `empf_mask`/`empf_maskrule` 表结构 |
| `mbm-bugfix-triage` | 依赖云效 MCP、MongoDB 页面真源库（`devmodel.000000_s_page`）、内部多 MCP 组合编排 |
| `mbm-lowcode-page` | Eman 低代码平台填页专有工具链（`scripts/<task>/out/*.page_content.json`） |
| `work-effort-estimation` | MBM 内部人天估算标准，属组织级政策而非技术能力 |
| `mbm-sdd-workflow` | 导航型 skill，指向 MBM 专属四层 DDD 标签体系（`[FACADE]/[DOMAIN]/[PAGE]`）与 page-studio；可作"如何写团队级 SDD 导航 skill"的范例参考，不可直接套用 |
| `mbm-brownfield-full-artifacts` | 本体含 MBM 专属"8 件套"清单与菜单路径规则；方法论已抽入 Tier B 骨架 |
| `mbm-brownfield-migrate-all-auto` | 同上，编排逻辑已抽入 Tier B 骨架 |
| `mbm-brownfield-complete-unit-tests` | 同上，方法论已抽入 Tier B 骨架 |
| `.agents/skills/page-analyze` | 依赖 Eman page-studio 判据体系与 `list_apps`/`get_model_columns` 等平台 MCP 工具 |
| `.agents/skills/page-assemble` | 依赖 `eman-page` MCP、`saber-runtime` 组件契约、内置案例库 CLI |
| `.agents/skills/page-modify` | 依赖 `get_page`/`hydrate_page`/`commit_page` 等平台专有 MCP 工具链 |
| `.agents/skills/page-diagnose` | 依赖 `@eman-manuverse/saber-runtime` 运行时源码与 `graphify` 索引 |

---

## 汇总核对

Tier A 38 + Tier B 7 + Tier C 14 = **59**，与项目内 `.cursor/skills`（55）+ `.agents/skills`（4）技能总数一致，无遗漏。
