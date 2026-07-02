---
name: springboot-skill-export
description: 将本项目 .cursor/skills 与 .specify 中与 MBM/Eman 低代码平台无关的通用能力（Spec-Driven Development 工作流全套、GitNexus 代码智能、通用 Java 代码规范方法论）一键导出/移植到另一个 Spring Boot（或任意技术栈）项目，供本机可访问代码目录的其他项目复用同一套 Agent Skill 体系。仅当用户明确要求"把这套 skill/技能能力复用、迁移、导出、移植到其他项目"时使用；不用于日常开发任务。
disable-model-invocation: true
---

# springboot-skill-export — 技能体系一键移植

本技能把当前项目积累的 Agent Skill 能力，按"技术栈相关度"分三级导出到另一个目标项目，让新项目免于从零搭建 Spec-Driven Development 工作流与代码规范体系。

**不做什么**：不导出与 MBM 业务、Eman 低代码平台（低代码 Facade、page-studio、`eman-page`/`saber-runtime`）、内部 MCP（云效、MongoDB 页面真源）强耦合的技能——这些脱离本项目基础设施后无法运行，参见 `skill-tiers.md` 的 Tier C 清单。

## 第 0 步：读入判据（必须先读，不得凭记忆执行）

1. `skill-tiers.md` —— 59 个技能（`.cursor/skills` 55 个 + `.agents/skills` 4 个）的三级分类（Tier A 原样复制 / Tier B 模板化改写 / Tier C 不导出）及逐条理由，以及 `.specify/` 运行时哪些子路径可复制、哪些是本项目运行痕迹不可复制。
2. `placeholder-map.md` —— Tier B 技能的具体改写规则：源文件 → 目标文件名、需要替换的 MBM/Eman 专有名词 → 占位符、需要整段删除的示例代码。

## 第 1 步：确认目标与目标技术栈

用 `AskQuestion`（不可用则口头分批问）确认：

1. **目标项目根目录**的绝对路径（本机可访问；只处理这一个路径，不递归扫描其他目录）。
2. 目标项目是否已存在 `.cursor/skills/`、`.specify/`、`AGENTS.md`——已存在同名文件/目录时，**默认不覆盖**，逐项询问"跳过 / 改名后新建（如 `AGENTS.md` → `AGENTS.speckit-import.md`）/ 用户手动确认后覆盖"。
3. 目标项目的 DAO/ORM 技术选型（MyBatis-Plus / JPA-Hibernate / 原生 MyBatis / 其它），用于替换 Tier B 里代码示例中的数据访问调用。
4. 目标项目是否有统一的公共工具类包（包名是什么），用于替换 `{{COMMON_UTIL_MODULE}}` 占位符；没有则保留 TODO，交目标项目自行盘点补全。
5. 目标项目是否已装/计划装 GitNexus MCP——决定是否导出 `gitnexus-*` 七件套（未装则跳过整组，避免导出后工具不可用造成的幻觉）。
6. 目标项目是新项目（greenfield）还是已有存量代码要补规格（brownfield）——决定是否需要第 3 步的"棕地治理附加约束"骨架。

## 第 2 步：导出 Tier A（整目录原样复制，零改写）

按 `skill-tiers.md` §Tier A 清单，逐条用 `Copy-Item -Recurse -Force`（已确认可覆盖时）或先建目标目录再复制。核心两块：

- `.specify/` 运行时骨架（`extensions/` 七个官方扩展包、`templates/` 六个官方模板、`scripts/powershell/`、`extensions.yml`、`init-options.json`、`workflows/speckit/`、`integrations/*.manifest.json`）——**不要**复制 `.specify/memory/constitution.md`、`.specify/feature.json`、`.specify/reports/`、`.specify/workflows/runs/`、`.specify/workflows/mbm-workflow/`（这些是本项目的运行痕迹/业务专属产物）。
- `.cursor/skills/` 下 38 个 speckit 原生工作流与扩展技能目录 + （若第 1 步确认目标项目要用）`gitnexus-*` 七个目录。

复制后如目标项目缺 `.specify/memory/`，新建空目录，交第 5 步写入宪法骨架。

## 第 3 步：生成 Tier B（提炼通用方法论后改写，不是直接复制）

对 `placeholder-map.md` 列出的技能，逐个：读取源 `SKILL.md` → 按替换规则处理 → 在目标项目 `.cursor/skills/<新名>/SKILL.md` **落一份新文件**（不是复制原文件）。每处未能确定的占位符，保留形如 `TODO(springboot-skill-export): 请替换为贵项目的 XXX` 的标记，全文可搜索定位。

若第 1 步确认目标项目是 brownfield，额外生成一份"棕地治理附加约束"骨架（源自本项目 `mbm-brownfield-full-artifacts`/`mbm-brownfield-migrate-all-auto`/`mbm-brownfield-complete-unit-tests` 三者的方法论，具体的"8 件套清单"与"`specs/<menu>/<yyyyMM>/`路径规则"清空为占位符，要求目标项目按自己的规格产物存放约定重写）。

## 第 4 步：Tier C 不导出，产出跳过说明

不生成任何文件，只在第 6 步报告里列出跳过的 14 个技能（`mbm-facade-pagination`/`mbm-api-integration`/`mbm-mask-migrate`/`mbm-bugfix-triage`/`mbm-lowcode-page`/`work-effort-estimation`/`mbm-sdd-workflow`/3 个 brownfield 加固层原文件/`page-analyze`/`page-assemble`/`page-modify`/`page-diagnose`）及各自不可移植的原因（详见 `skill-tiers.md`）。如目标项目恰好也有自研低代码平台或类似 Facade 抽象层，提示"可以这些文件为范例参考自行改写，本次不代做"。

## 第 5 步：生成通用宪法骨架 + AGENTS.md 骨架

- 直接复制 `.specify/templates/constitution-template.md` 到目标项目 `.specify/memory/constitution.md`（**原样**，不臆造具体条文内容——条文必须由目标项目后续跑 `speckit-constitution` 交互式生成，本技能只负责把模板放到位）。
- 生成一份精简版 `AGENTS.md` 骨架，只含三段可复用的治理结构（业务相关章节不复制）：
  1. 构建/测试命令表（命令用 `<mvn 命令>` 等占位符，交目标项目按自己的模块结构填）；
  2. Git 工作流规则（禁 `--force`/`--no-verify`、禁改 git config、仅明确要求才提交——这三条是通用团队纪律，原样保留）；
  3. Agent 安全基线（编辑前必先读文件、不臆造依赖版本、遇高风险停手确认——这三条通用，原样保留；"低代码 metadata 由用户入库"等 MBM 专属条目不复制）。

## 第 6 步：导出报告

产出一份 Markdown 报告（打印在回复中即可，无需落盘）：

- 已复制的 Tier A 目录清单与数量；
- 已生成的 Tier B 文件清单，逐个标注还剩几处 `TODO` 待目标项目补齐；
- 已跳过的 Tier C 清单及理由；
- 目标项目后续启动步骤：① 在目标项目跑 `speckit-constitution` 生成正式宪法；② 如需 GitNexus，在目标项目单独执行索引（`.cursor/skills/gitnexus-cli`）；③ 逐个搜索 `TODO(springboot-skill-export)` 完成客制化；④ 建议先在一个小 feature 上跑一遍 `speckit-specify → plan → tasks → implement` 验证链路通畅。

## 硬约束（全程有效）

- 只处理用户在第 1 步明确给出的目标路径，不主动扫描/枚举其他目录。
- 不导出 `skill-tiers.md` 标记为 Tier C 的技能本体。
- 不覆盖目标项目已有同名文件/目录，冲突必须先询问用户裁决。
- Tier B 生成的文件中，凡替换不了的 MBM/Eman 专有名词，必须留 `TODO(springboot-skill-export)` 标记，禁止编造一个看似合理但目标项目并不存在的类名/包名/命令去填空。
- 新建/整份写入的文件行尾使用 LF。
- 一次会话只服务一个目标项目路径；如需批量导出到多个项目，逐个路径重新走一遍本流程。

## 参考文件

- [`skill-tiers.md`](./skill-tiers.md) —— 59 个技能的完整三级分类表
- [`placeholder-map.md`](./placeholder-map.md) —— Tier B 技能的具体改写规则
