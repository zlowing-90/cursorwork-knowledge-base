# 知识库工作区

> 基于 Cursor AI 的团队知识沉淀与管理工作区，支持钉钉在线文档同步。

## 目录结构

```
cursorwork/
├── knowledge-base/          # 核心知识库
│   ├── 00-index/            # 知识索引与导航
│   ├── 01-projects/         # 项目文档（按项目分子目录）
│   ├── 02-topics/           # 专题知识（技术领域、业务领域）
│   ├── 03-meetings/         # 会议记录
│   ├── 04-decisions/        # 决策记录（ADR）
│   └── 05-references/       # 参考资料、外部链接
├── dingtalk-docs/           # 钉钉文档同步区（通过 MCP 拉取）
└── .cursor/
    └── rules/               # Cursor AI 规则，引导 AI 使用知识库
```

## 模块说明

### knowledge-base/00-index
知识库的总索引文件，维护各分类的导航地图，方便快速定位内容。

### knowledge-base/01-projects
按项目划分，每个项目一个子目录，包含：
- 项目背景与目标
- 技术方案
- 进展记录
- 问题与解决方案

### knowledge-base/02-topics
按主题/领域沉淀的通用知识，例如：
- 架构设计原则
- 技术规范
- 业务领域知识

### knowledge-base/03-meetings
会议纪要，按日期命名，格式：`YYYY-MM-DD-主题.md`

### knowledge-base/04-decisions
架构决策记录（ADR），记录重要技术/业务决策的背景、选项和结论。

### knowledge-base/05-references
外部参考资料、文档链接、钉钉文档引用索引。

### dingtalk-docs/
通过钉钉 MCP 从钉钉在线文档拉取并同步的内容。  
配置好 MCP 后，AI 可直接读取钉钉文档内容并整合进知识库。

## 快速开始

1. 在 `knowledge-base/00-index/` 下创建总索引 `INDEX.md`
2. 按项目在 `01-projects/` 下建立子目录
3. 配置钉钉 MCP（见 `.cursor/mcp.json`），接入在线文档
4. 使用 Cursor AI 对话，AI 会自动参考知识库内容回答问题

## 钉钉文档集成

钉钉文档 MCP 配置后，可以：
- 读取指定钉钉文档的内容
- 将钉钉文档内容同步到 `dingtalk-docs/` 目录
- AI 对话时直接引用钉钉在线文档

配置文件位于：`.cursor/mcp.json`（等待钉钉 MCP 信息补充后填写）
