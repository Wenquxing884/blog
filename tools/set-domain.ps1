#Requires -Version 5.1
<#
.SYNOPSIS
  一键替换博客里写死的站点域名（canonical / og:url / feed / sitemap / robots）。

.DESCRIPTION
  域名在 8 个 HTML 和 feed.xml、sitemap.xml、robots.txt 里各写了一份。
  这个脚本把旧域名整体换成新域名，写完打印每个文件改了几处。

.PARAMETER Domain
  新地址，例如 https://blog.example.com 或 https://example.com/blog。
  不要以 / 结尾，也不要在中间带多余斜杠。

.PARAMETER Old
  旧地址。省略时从 index.html 的 og:url 自动读取。

.PARAMETER DryRun
  只报告将要修改的文件与处数，不落盘。

.EXAMPLE
  .\tools\set-domain.ps1 -Domain https://blog.example.com -DryRun

.EXAMPLE
  .\tools\set-domain.ps1 -Domain https://example.com/blog
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Domain,

  [string]$Old,

  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$index = Join-Path $root 'index.html'
if (-not (Test-Path -LiteralPath $index)) {
  throw "找不到 $index，请在 blog 目录下的 tools\ 里运行此脚本。"
}

$Domain = $Domain.Trim().TrimEnd('/')
if ($Domain -notmatch '^https?://[^/\s]+(/\S*)?$') {
  throw "域名格式不对：$Domain（需要 http(s):// 开头，且不以 / 结尾）"
}

if (-not $Old) {
  $html = [IO.File]::ReadAllText($index)
  $m = [regex]::Match($html, 'og:url"\s+content="(https?://[^"]+)"')
  if (-not $m.Success) { throw '无法从 index.html 的 og:url 推断旧域名，请用 -Old 指定。' }
  $Old = $m.Groups[1].Value.TrimEnd('/')
}
$Old = $Old.Trim().TrimEnd('/')

if ($Old -eq $Domain) {
  Write-Host "旧域名与新域名相同（$Domain），无需修改。" -ForegroundColor Yellow
  return
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$pattern = [regex]::Escape($Old)
$files = Get-ChildItem -LiteralPath $root -Recurse -File -Include *.html, *.xml, *.txt |
  Where-Object { $_.FullName -notmatch '\\_backup\\|\\tools\\' }

$total = 0
$touched = 0

foreach ($file in $files) {
  $text = [IO.File]::ReadAllText($file.FullName, $utf8)
  $hits = ([regex]::Matches($text, $pattern)).Count
  if ($hits -eq 0) { continue }

  $total += $hits
  $touched++
  $rel = $file.FullName.Substring($root.Length + 1)
  if ($DryRun) {
    Write-Host ("  [dry] {0,-44} {1} 处" -f $rel, $hits)
    continue
  }

  $new = [regex]::Replace($text, $pattern, { param($m) $Domain })
  [IO.File]::WriteAllText($file.FullName, $new, $utf8)
  Write-Host ("  {0,-44} {1} 处" -f $rel, $hits) -ForegroundColor Green
}

Write-Host ''
if ($DryRun) {
  Write-Host ("预览：{0} 个文件共 {1} 处会被替换 {2} → {3}" -f $touched, $total, $Old, $Domain) -ForegroundColor Cyan
} else {
  Write-Host ("完成：{0} 个文件共 {1} 处已替换 {2} → {3}" -f $touched, $total, $Old, $Domain) -ForegroundColor Cyan
  Write-Host '别忘了同步 GitHub 仓库名 / Pages 路径，然后 git commit。'
}
