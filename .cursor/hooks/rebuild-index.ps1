#!/usr/bin/env pwsh
# 重建 knowledge-base/00-index/INDEX.md
# 用法：在项目根目录执行 .\.cursor\hooks\rebuild-index.ps1

param(
    [string]$Root = $PSScriptRoot + "\..\.."
)

$Root = Resolve-Path $Root
$KbRoot = Join-Path $Root "knowledge-base"
$IndexFile = Join-Path $KbRoot "00-index\INDEX.md"

function Get-FrontMatter {
    param([string]$FilePath)
    $lines = Get-Content $FilePath -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($lines.Count -gt 0) {
        # 去除 UTF-8 BOM 可能残留在首行开头的字符，避免误判无 front matter
        $lines[0] = $lines[0].TrimStart([char]0xFEFF)
    }
    $fm = @{}
    if ($lines.Count -gt 0 -and $lines[0].Trim() -eq "---") {
        $i = 1
        while ($i -lt $lines.Count -and $lines[$i] -ne "---") {
            if ($lines[$i] -match "^([\w-]+):\s*(.+)$") {
                $fm[$Matches[1]] = $Matches[2].Trim()
            }
            $i++
        }
    }
    # Fallback: extract title from first H1 if no front matter
    if (-not $fm.ContainsKey("title")) {
        foreach ($line in $lines) {
            if ($line -match "^#\s+(.+)$") {
                $fm["title"] = $Matches[1].Trim()
                break
            }
        }
    }
    if (-not $fm.ContainsKey("date")) { $fm["date"] = (Get-Item $FilePath).LastWriteTime.ToString("yyyy-MM-dd") }
    if (-not $fm.ContainsKey("title")) { $fm["title"] = [System.IO.Path]::GetFileNameWithoutExtension($FilePath) }
    return $fm
}

# Collect files by category
$projects   = @()
$topics     = @()
$meetings   = @()
$decisions  = @()
$references = @()
$dingtalk   = @()

# 01-projects
Get-ChildItem "$KbRoot\01-projects" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "^_" } | ForEach-Object {
    $rel = $_.FullName.Replace($Root + "\", "").Replace("\", "/")
    $fm = Get-FrontMatter $_.FullName
    $project = $_.Directory.Name
    if ($_.Directory.FullName -eq "$KbRoot\01-projects") { $project = "(根目录)" }
    $projects += [PSCustomObject]@{ Project = $project; Title = $fm["title"]; Path = $rel; Date = $fm["date"] }
}

# 02-topics
Get-ChildItem "$KbRoot\02-topics" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "^_" } | ForEach-Object {
    $rel = $_.FullName.Replace($Root + "\", "").Replace("\", "/")
    $fm = Get-FrontMatter $_.FullName
    $topic = $_.Directory.Name
    $topics += [PSCustomObject]@{ Topic = $topic; Title = $fm["title"]; Path = $rel; Date = $fm["date"] }
}

# 03-meetings
Get-ChildItem "$KbRoot\03-meetings" -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "MEETING-TEMPLATE.md" } | ForEach-Object {
    $rel = $_.FullName.Replace($Root + "\", "").Replace("\", "/")
    $fm = Get-FrontMatter $_.FullName
    $meetings += [PSCustomObject]@{ Date = $fm["date"]; Title = $fm["title"]; Path = $rel }
}
$meetings = $meetings | Sort-Object Date -Descending

# 04-decisions
Get-ChildItem "$KbRoot\04-decisions" -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "ADR-TEMPLATE.md" } | ForEach-Object {
    $rel = $_.FullName.Replace($Root + "\", "").Replace("\", "/")
    $fm = Get-FrontMatter $_.FullName
    $num = if ($_.Name -match "ADR-(\d+)") { $Matches[1] } else { "---" }
    $status = if ($fm.ContainsKey("status")) { $fm["status"] } else { "draft" }
    $decisions += [PSCustomObject]@{ Num = $num; Title = $fm["title"]; Date = $fm["date"]; Status = $status; Path = $rel }
}
$decisions = $decisions | Sort-Object Num

# 05-references（支持按领域分子目录，如 文学阅读/、企业调研/，根目录文件归为"综合"）
Get-ChildItem "$KbRoot\05-references" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "^_" } | ForEach-Object {
    $rel = $_.FullName.Replace($Root + "\", "").Replace("\", "/")
    $fm = Get-FrontMatter $_.FullName
    $domain = $_.Directory.Name
    if ($_.Directory.FullName -eq "$KbRoot\05-references") { $domain = "综合" }
    $references += [PSCustomObject]@{ Domain = $domain; Title = $fm["title"]; Path = $rel; Date = $fm["date"] }
}

# dingtalk-docs
Get-ChildItem "$Root\dingtalk-docs" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "README.md" } | ForEach-Object {
    $rel = $_.FullName.Replace($Root + "\", "").Replace("\", "/")
    $fm = Get-FrontMatter $_.FullName
    $space = $_.Directory.Name
    $source = if ($fm.ContainsKey("source")) { $fm["source"] } else { "—" }
    $dingtalk += [PSCustomObject]@{ Space = $space; Title = $fm["title"]; Source = $source; Path = $rel; Date = $fm["date"] }
}

# Build INDEX.md content
$now = Get-Date -Format "yyyy-MM-dd HH:mm"
$sb = [System.Text.StringBuilder]::new()

$null = $sb.AppendLine("# 知识库总索引")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("> 最后更新：$now（由 rebuild-index.ps1 自动生成）")
$null = $sb.AppendLine("")

# Projects
$null = $sb.AppendLine("## 项目文档 (01-projects)")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| 项目 | 文档 | 更新日期 |")
$null = $sb.AppendLine("|------|------|----------|")
if ($projects.Count -eq 0) {
    $null = $sb.AppendLine("| *(待添加)* | | |")
} else {
    foreach ($p in $projects) {
        $null = $sb.AppendLine("| $($p.Project) | [$($p.Title)]($($p.Path)) | $($p.Date) |")
    }
}
$null = $sb.AppendLine("")

# Topics
$null = $sb.AppendLine("## 专题知识 (02-topics)")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| 领域 | 文档 | 更新日期 |")
$null = $sb.AppendLine("|------|------|----------|")
if ($topics.Count -eq 0) {
    $null = $sb.AppendLine("| *(待添加)* | | |")
} else {
    foreach ($t in $topics) {
        $null = $sb.AppendLine("| $($t.Topic) | [$($t.Title)]($($t.Path)) | $($t.Date) |")
    }
}
$null = $sb.AppendLine("")

# Meetings
$null = $sb.AppendLine("## 会议记录 (03-meetings)")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| 日期 | 主题 | 文件 |")
$null = $sb.AppendLine("|------|------|------|")
if ($meetings.Count -eq 0) {
    $null = $sb.AppendLine("| *(待添加)* | | |")
} else {
    foreach ($m in $meetings) {
        $null = $sb.AppendLine("| $($m.Date) | [$($m.Title)]($($m.Path)) | ``$([System.IO.Path]::GetFileName($m.Path))`` |")
    }
}
$null = $sb.AppendLine("")

# Decisions
$null = $sb.AppendLine("## 决策记录 (04-decisions)")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| 编号 | 标题 | 日期 | 状态 |")
$null = $sb.AppendLine("|------|------|------|------|")
if ($decisions.Count -eq 0) {
    $null = $sb.AppendLine("| *(待添加)* | | | |")
} else {
    foreach ($d in $decisions) {
        $null = $sb.AppendLine("| $($d.Num) | [$($d.Title)]($($d.Path)) | $($d.Date) | $($d.Status) |")
    }
}
$null = $sb.AppendLine("")

# References
$null = $sb.AppendLine("## 参考资料 (05-references)")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| 领域 | 标题 | 文件 | 日期 |")
$null = $sb.AppendLine("|------|------|------|------|")
if ($references.Count -eq 0) {
    $null = $sb.AppendLine("| *(待添加)* | | | |")
} else {
    foreach ($r in $references) {
        $null = $sb.AppendLine("| $($r.Domain) | [$($r.Title)]($($r.Path)) | ``$([System.IO.Path]::GetFileName($r.Path))`` | $($r.Date) |")
    }
}
$null = $sb.AppendLine("")

# DingTalk
$null = $sb.AppendLine("## 钉钉文档 (dingtalk-docs)")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| 空间 | 文档 | 来源 | 同步日期 |")
$null = $sb.AppendLine("|------|------|------|----------|")
if ($dingtalk.Count -eq 0) {
    $null = $sb.AppendLine("| *(等待 MCP 配置后同步)* | | | |")
} else {
    foreach ($dt in $dingtalk) {
        $null = $sb.AppendLine("| $($dt.Space) | [$($dt.Title)]($($dt.Path)) | $($dt.Source) | $($dt.Date) |")
    }
}
$null = $sb.AppendLine("")
$null = $sb.AppendLine("---")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("## 快速操作")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("- **重建索引**：运行 ``.cursor\hooks\rebuild-index.ps1``")
$null = $sb.AppendLine("- **新增文档**：直接告诉 AI 内容，它会自动分类存放并更新本索引")
$null = $sb.AppendLine("- **钉钉同步**：配置好 MCP 后，AI 可直接拉取钉钉文档")

$content = $sb.ToString()
Set-Content -Path $IndexFile -Value $content -Encoding UTF8 -NoNewline

Write-Host "✅ INDEX.md 重建完成：$IndexFile"
Write-Host "   项目文档：$($projects.Count) 篇"
Write-Host "   专题知识：$($topics.Count) 篇"
Write-Host "   会议记录：$($meetings.Count) 篇"
Write-Host "   决策记录：$($decisions.Count) 篇"
Write-Host "   参考资料：$($references.Count) 篇"
Write-Host "   钉钉文档：$($dingtalk.Count) 篇"
