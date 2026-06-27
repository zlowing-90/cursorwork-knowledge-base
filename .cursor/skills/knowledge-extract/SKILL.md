---
name: knowledge-extract
description: 对任意文档（会议记录、项目复盘、技术文章、钉钉文档、流程文档、学习笔记等）自动选择最合适的提炼方法论（金字塔原理、GRAI、ORID、ECRS、KPT、费曼技巧等），输出结构化总结，并自动存入知识库对应目录、更新索引。使用场景：用户说"帮我总结/提炼/复盘/整理"这类文档，或直接粘贴内容要求分析时。
---

# 知识提炼技能（knowledge-extract）

## 第一步：识别文档类型 → 选择方法论

| 文档类型 | 主方法 | 辅助方法 | 知识库目录 |
|----------|--------|----------|-----------|
| 会议纪要 / 讨论记录 | ORID | KPT | `03-meetings/` |
| 项目复盘 / 阶段总结 | GRAI | PDCA | `01-projects/{项目}/` |
| 技术文章 / 领域知识 | 金字塔原理 + 四步思维法 | MECE | `02-topics/{领域}/` |
| 流程优化 / 效率问题 | ECRS | PDCA | `02-topics/流程优化/` |
| 读书笔记 / 学习输入 | 费曼技巧 + 四步思维法 | 金字塔原理 | `02-topics/{领域}/` |
| 周报 / 日报 / 工作汇报 | KPT + KISS | — | `01-projects/{项目}/` |
| 年终总结 / 季度总结 | 金字塔原理 + GRAI | ORID | `02-topics/个人成长/` |
| 方案汇报 / 技术选型 | 金字塔原理 + KISS | MECE | `04-decisions/` |
| 钉钉文档（多种类型） | 按内容特征判断 | — | `dingtalk-docs/{空间}/` |
| 碎片信息 / 无明确类型 | 四步思维法（拆→归→联→提） | MECE | `05-references/` |

**判断优先级**：用户明确说明类型 > 文档标题/关键词 > 内容结构特征

## 第二步：执行提炼

读取 [methods.md](methods.md) 获取所选方法的完整操作步骤。

核心原则（所有方法通用）：
- 必须有「一句话核心结论」（无法一句话说清的说明未提炼到位）
- 避免流水账：每条要有 **是什么 → 为什么 → 怎么做/价值**
- 用 MECE 检验分类：无重叠、无遗漏

## 第三步：输出结构化文档

输出必须包含：
1. **一句话结论**（置顶，粗体）
2. **提炼方法**（注明使用了哪个模型及原因）
3. **结构化正文**（按所选方法模板展开）
4. **行动项**（如有，带负责人和时间）
5. **关联知识**（与知识库中已有哪些文档相关）

输出文档头部必须包含 YAML frontmatter：
```yaml
---
title: 文档标题
category: meetings | projects | topics | decisions | references
date: YYYY-MM-DD
tags: [提炼方法, 领域标签]
extract-method: GRAI | 金字塔原理 | ORID | ...
status: active
source: 原始来源（钉钉链接/用户粘贴/etc）
---
```

## 第四步：存入知识库 + 更新索引

1. 按分类表选择目标目录创建文件
2. 文件命名：
   - 会议类：`YYYY-MM-DD-{主题}.md`
   - 决策类：`ADR-{三位编号}-{标题}.md`
   - 其他：`{主题}.md`（无空格，用 `-` 连接）
3. 在 `knowledge-base/00-index/INDEX.md` 对应表格中插入新行
4. 如需重建完整索引，运行：`.cursor/hooks/rebuild-index.ps1`

## 第五步：自动推送到 GitHub

文档写入知识库、INDEX.md 更新完毕后，**必须**执行以下 git 操作将变更同步到 GitHub：

```powershell
cd e:\cursorwork
git add .
git commit -m "docs: 新增/更新知识文档 - {文档标题简述}"
git push
```

**提交信息规范**（根据文档类型选择前缀）：

| 文档类型 | commit 前缀 | 示例 |
|----------|------------|------|
| 新增文档 | `docs: 新增` | `docs: 新增 钉钉MCP使用指南提炼` |
| 更新已有文档 | `docs: 更新` | `docs: 更新 INDEX.md 索引` |
| 新增决策记录 | `adr: ` | `adr: ADR-001 选择钉钉MCP方案` |
| 会议记录 | `meeting: ` | `meeting: 2026-06-27 周会纪要` |
| 钉钉文档同步 | `sync: ` | `sync: 钉钉文档 MCP使用指南 v1.2` |

> ⚠️ **注意**：`.cursor/mcp.json` 已在 `.gitignore` 中排除，不会被提交，敏感 key 不会泄漏。

## 避坑清单

- [ ] 结论是否前置？（不能只有过程描述）
- [ ] 有没有「为什么」？（不能只有「做了什么」）
- [ ] 分类是否 MECE？（无遗漏、无重叠）
- [ ] 行动项是否可执行？（有具体负责人/时间）
- [ ] 是否更新了 INDEX.md？

## 参考资源

- 详细方法论说明：[methods.md](methods.md)
- 各方法输出模板：[templates/](templates/)
- 知识库索引：`knowledge-base/00-index/INDEX.md`
