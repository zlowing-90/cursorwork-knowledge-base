# Tier B 改写规则（占位符映射表）

本文件是 `springboot-skill-export` 第 3 步的判据正文。对每个 Tier B 源文件，按"查找 → 替换"表逐条处理；替换值来自导出流程第 1 步向用户收集的目标项目信息（记为 `{{变量}}`）；收集不到的一律保留 `TODO(springboot-skill-export)` 标记，不得编造。

## 通用变量（第 1 步收集）

| 变量 | 含义 | 收集不到时 |
|------|------|-----------|
| `{{COMMON_DAO_CLASS}}` | 目标项目统一数据访问入口类名（如自研 `BaseRepository`、或直接写 `Mapper`/`Repository`） | `TODO(springboot-skill-export): 请替换为贵项目的统一 DAO/Repository 类名` |
| `{{COMMON_UTIL_MODULE}}` | 目标项目公共工具类包名 | `TODO(springboot-skill-export): 请替换为贵项目的公共工具包路径` |
| `{{BUILD_MODULE_PATH}}` | 目标项目 Maven 模块路径写法示例 | `<module-path>` |
| `{{PROJECT_NAME}}` | 目标项目名（用于替换正文里的"MBM") | `TODO(springboot-skill-export): 贵项目名` |

---

## 1. `mbm-code-style` → `java-code-style`

| 查找 | 替换为 |
|------|--------|
| `com.eman.mbm.util.entity.GeneralEntityService` | `{{COMMON_DAO_CLASS}}` |
| `mbm-util` 模块内的工具类 | `{{COMMON_UTIL_MODULE}}` 内的工具类 |
| description 中的 `MBM 项目` | `{{PROJECT_NAME}}` |

保留原样：Javadoc 强制要求段、循环禁查询段、MapStruct 命名规则 `tran{入参}To{出参}[List]` 整段、代码自查清单。

---

## 2. `mbm-performance-optimization` → `java-loop-performance`

| 查找 | 替换为 |
|------|--------|
| 示例代码 `deptService.findByName(...)` / `generalEntityService.insert(entity)` | 改写为通用占位示例：`xxxRepository.findByName(...)` / `{{COMMON_DAO_CLASS}}.insert(entity)`，并加注释"示例中的 Repository/DAO 调用请替换为贵项目实际的数据访问方式" |
| `generalEntityService.insertBatch(list)` | `{{COMMON_DAO_CLASS}}.saveAll(list)` 或对应批量方法（按 MyBatis-Plus 用 `saveBatch`，JPA 用 `saveAll`，需目标项目自行确认） |

保留原样：**循环内禁止数据库查询**的核心原则段落、批量写入优先段、事务管理段——这三条与具体 ORM 无关，是纯 Java/Spring 通用建议。

---

## 3. `mbm-sql-portability` → `sql-cross-db-portability`

| 查找 | 替换为 |
|------|--------|
| "适用范围"一节整段（`GeneralEntityService` 的 `_criteria/_orderBy/_groupBy/_having`、`MetaQueryWrapper`、`MetadataQueryBuilder.selectExpression`） | 改写为："本规范约束一切手写 SQL 片段，常见出现位置包括：自定义 `@Select` 注解 SQL、动态 SQL 构造器的原始片段拼接、报表类原生 SQL。`{{RAW_SQL_ENTRY_POINTS}}`（TODO：请替换为贵项目实际的手写 SQL 入口，如 MyBatis XML 的 `<if>`片段、JPA `@Query(nativeQuery=true)`等）" |
| 标题/正文中的"MBM" | `{{PROJECT_NAME}}` |

保留原样：绿区/黄区/红区 ANSI SQL 函数白黑名单全部内容（这是跨数据库通用知识，不因 ORM 框架不同而改变）。若目标项目明确不需要跨库兼容（只用单一数据库），此技能整体标为可选，导出报告里注明"仅当贵项目需要兼容多种数据库方言时才需要"。

---

## 4. `mbm-run-tests` → `maven-run-tests`

| 查找 | 替换为 |
|------|--------|
| `mvn -pl <module-path> -am test` | 保留原样（已是通用占位符写法） |
| description/正文里的 "MBM" | `{{PROJECT_NAME}}` |
| `compatibility: MBM-Backend local workflow` | `compatibility: {{PROJECT_NAME}} local workflow`（或按目标项目实际 shell 环境调整 Windows/Linux 措辞） |

保留原样：Required Order 步骤、Pass Criteria（退出码 0、Surefire/JaCoCo 报告路径记录、环境阻塞如实记录不静默通过）。

---

## 5. `mbm-generate-tests` → `generate-uat-scenarios`

| 查找 | 替换为 |
|------|--------|
| "MBM"、"Gate 3" 等内部评审措辞 | 通用化为"验收评审门禁" |

保留原样：从 `spec.md` 每个用户故事生成 Given-When-Then 场景表的方法论主体。

---

## 6. `mbm-refresh-env` → `refresh-local-env`

| 查找 | 替换为 |
|------|--------|
| `127.0.0.1:3000` | `TODO(springboot-skill-export): 贵项目本地前端/网关端口` |
| `28087/refresh/model` | `TODO(springboot-skill-export): 贵项目模型/配置刷新端点（如无此类端点，删除本条，仅保留端口可达性自检）` |

保留原样：整体"先探测端口可达性，再可选调用刷新接口，全部记录证据"的自检模式。

---

## 7. `mbm-utils` → `common-utils-selection`（仅取方法论，不整份复制）

只提取以下内容生成新文件，**不复制原文 18 行选型表的具体类名**：

```markdown
---
name: common-utils-selection
description: {{PROJECT_NAME}} 项目通用工具类使用规范。当生成 Java 代码时，优先查阅本规范选用合适工具类，尽量避免重复造轮子。
---

# 通用工具类使用规范

生成代码前，**必须先查阅本规范**，优先使用已有工具类，禁止重复实现。

## 快速选型表（请按贵项目实际 {{COMMON_UTIL_MODULE}} 包盘点填写）

| 场景 | 工具类 | 包路径 |
|------|--------|--------|
| 数据库 CRUD | TODO(springboot-skill-export) | TODO(springboot-skill-export) |
| 空值/非空判断 | TODO(springboot-skill-export) | TODO(springboot-skill-export) |
| 集合处理 | TODO(springboot-skill-export) | TODO(springboot-skill-export) |
| 时间处理 | TODO(springboot-skill-export) | TODO(springboot-skill-export) |
| JSON 序列化 | TODO(springboot-skill-export) | TODO(springboot-skill-export) |
| 分布式锁 | TODO(springboot-skill-export) | TODO(springboot-skill-export) |
| 幂等控制 | TODO(springboot-skill-export) | TODO(springboot-skill-export) |
```

导出时提示用户：这张表是本项目 `mbm-utils` 沉淀了 18 类工具后的产物，新项目应随开发积累持续补充，而非一次性照抄。

---

## 棕地治理附加约束骨架（可选，仅 brownfield 目标生成）→ `brownfield-governance-overlay`

```markdown
---
name: brownfield-governance-overlay
description: {{PROJECT_NAME}} 棕地迁移的叠加约束层，配合官方 speckit-brownfield-migrate 使用，在其基础上强制补全产物完整性、批量编排纪律与单测缺口。
---

# 棕地治理附加约束

## 产物完整性清单（在官方三件套 spec/plan/tasks 之外，按需追加）

TODO(springboot-skill-export): 按贵项目治理要求列出必须产出的附加文档（如 research.md/data-model.md/quickstart.md/contracts/），并给出"何时必出"的判定条件。

## 批量编排纪律

多目标批量迁移时，每个目标完成后应独立提交，不跨目标合并提交；仅在用户明确要求"全部自动迁移"时才连续处理下一个目标，否则每个目标完成后停下确认。

## 单测缺口补全

从已迁移的 spec.md 验收标准出发，比对 tasks.md 的测试任务，缺口记为独立编号任务（如 `T-GAP-###`）并补齐实现；不在此过程中改动业务代码，除非发现真实缺陷且经用户确认。
```
