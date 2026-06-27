---
title: MBM-AI提效 · 钉钉文档/表格 MCP 使用指南（v1.2）
category: dingtalk
date: 2026-05-14
author: 刘一
tags: [MCP, 钉钉文档, 钉钉表格, Cursor, AI提效]
source: https://alidocs.dingtalk.com/i/nodes/YQBnd5ExVEwxPRxjU2ZB1meL8yeZqMmz
status: active
sync-date: 2026-06-27
---

# MBM-AI提效 · 钉钉文档/表格 MCP 使用指南（v1.2）

**作者**：刘一　|   **日期**：2026-05-14

---

## 目录
1. 背景与目标
2. MCP 配置
3. 安装验证
4. 典型用法 
    - 4.1 钉钉文档
    - 4.2 钉钉表格

---

## 1. 背景与目标

希望钉钉里的文档能在 Cursor 里直接读取得到，并支持**定期扫描**沉淀进 AI 上下文；同时 Cursor 产出的文档（PRD、需求方案、分析结论等）也能**自动上传回钉钉**，让"钉钉 ↔ Cursor"双向打通，不再依赖人工复制粘贴。

## 2. MCP 配置

不需要手写任何代码，按下面 4 步即可：
1. 打开钉钉 MCP 集市首页：https://aihub.dingtalk.com/
2. 分别进入"**钉钉文档**""**钉钉表格**""**钉钉文档互动服务**"三个 MCP 的详情页：
    - 钉钉文档：https://aihub.dingtalk.com/#/detail?mcpId=9629&detailType=marketMcpDetail
    - 钉钉表格：https://aihub.dingtalk.com/#/detail?mcpId=9704&detailType=marketMcpDetail
    - 钉钉文档互动服务：https://aihub.dingtalk.com/#/detail?mcpId=9784&detailType=marketMcpDetail
3. 在详情页里复制本人专属的"Cursor 配置 / streamable-http URL"（每人 key 不同，钉钉会自动用你的身份生成）。
4. 回到 Cursor，把复制下来的内容粘贴到 AI 对话框，并加一句：
> 帮我注册这三个 MCP，MCP 名称不要用中文，分别叫 dingtalk-doc、dingtalk-spreadsheet、dingtalk-doc-comment。

AI 会自动写入 `~/.cursor/mcp.json`。写完后在 Cursor 里点 `Settings → MCP & Integrations → Refresh`，或者 `Ctrl + Shift + P → Developer: Reload Window` 让配置生效。

> ⚠️ `key` 等同登录凭证，**不要把自己的 key 转发给同事**；每人都从上面链接自助开通。

## 3. 安装验证

随便找一份你能访问的钉钉文档或表格，在 Cursor 对话框里发：
> 帮我读一下 `<钉钉文档/表格 URL>` 的内容，按章节给我做个摘要。

若 AI 能正确返回标题、要点 → 接通成功。若提示"MCP 未注册 / 工具找不到" → 回到第 2 步检查 `mcp.json` 是否生效。

## 4. 典型用法

### 4.1 钉钉文档（dingtalk-doc）

直接在对话框用自然语言提问，**附上钉钉文档/文件夹 URL** 即可。

**读取与分析**
- 读取 `<某份客户调研纪要 URL>`，把里面的需求条目提取出来，按业务领域归类
- 对比 `<PRD v1.0 URL>` 和 `<PRD v1.1 URL>`，输出变更点清单
- 在"MBM 产品"知识库下找跟"装配管理"相关的所有文档，按更新时间排序
- 把 `<某份会议录音转写 URL>` 整理成 议题 / 决议 / 待办 三段

**生成与回写**
- 在 `<项目根目录 URL>` 下新建一篇文档，标题"`<项目名>` - 业务方案 v1.0"
- 把这次会议纪要按 议题 / 决议 / 待办 三类整理，追加到 `<周会纪要 URL>` 末尾
- 把 `<PRD URL>` 里"装配管理"章节的描述替换为指定内容
- 把 `<某份临时草稿 URL>` 移动到"已归档"文件夹，并重命名

### 4.2 钉钉表格（dingtalk-spreadsheet）

同样附上钉钉表格 URL。

**读取与分析**
- 读取 `<验证清单 URL>` 的"验证清单"sheet，列出 责任人=刘一 且 计划完成时间 ≤ 5/15 的所有任务
- 按 责任人 维度，统计每个人的未完成任务数
- 把指定 sheet 的内容用 Markdown 表格输出，便于在群里发
- 在接口清单里找跟"采购入库"相关的所有接口行

**更新与回写**
- 把指定行的备注列改成"已完成（YYYY-MM-DD）"
- 在"任务清单"sheet 末尾追加一行
- 把 状态="待执行" 的行批量改为"执行中"
- 把 B 列数字格式改成"百分比"

## 5. 钉钉文档互动服务（评论）

提供钉钉文档的评论互动能力，支持对钉钉在线文档进行评论的查询与创建。所有工具均通过 `nodeId` 定位文档。**不支持跨组织操作**，目前仅支持钉钉在线文档（adoc）。

### 5.1 典型用法

- 列出 `<某份 PRD URL>` 里所有未解决的评论，按时间排序
- 在 `<某份方案 URL>` 末尾创建一条全文评论，并 @相关同事
- 针对指定文字加一条划词评论
- 回复某条评论
