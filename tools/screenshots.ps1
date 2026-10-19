#Requires -Version 5.1
<#
.SYNOPSIS
  重新生成 preview/ 里的整页截图（首页、关于、两篇文章、移动端）。

.DESCRIPTION
  用本机 Chrome 无头模式截整页图，尺寸与文件名跟原来保持一致。
  脚本会自己起一个临时 http 服务器，跑完关掉，端口默认 8099。

.PARAMETER Port
  临时服务器端口，被占用时换一个。

.PARAMETER Chrome
  Chrome 可执行文件路径，省略时自动在常见位置查找。

.EXAMPLE
  .\tools\screenshots.ps1
#>
[CmdletBinding()]
param(
  [int]$Port = 8099,
  [string]$Chrome
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $root 'index.html'))) {
  throw "找不到 index.html，请在 blog\tools\ 下运行。"
}

if (-not $Chrome) {
  $candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
  )
  $Chrome = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
  if (-not $Chrome) { throw '没找到 Chrome 或 Edge，请用 -Chrome 指定路径。' }
}

$shots = @(
  @{ url = 'index.html';                            file = 'home.png';        w = 1280; h = 1500 },
  @{ url = 'about.html';                            file = 'about.png';       w = 1280; h = 1450 },
  @{ url = 'posts/android-ai-image-studio.html';    file = 'post-android.png'; w = 1280; h = 1400 },
  @{ url = 'posts/text-recognition-clicker.html';   file = 'post-ocr.png';    w = 1280; h = 1400 },
  @{ url = 'index.html';                            file = 'mobile.png';      w = 500;  h = 1000 }
)

$server = $null
$profiles = @()
try {
  $server = Start-Process -FilePath 'python' `
    -ArgumentList '-m', 'http.server', $Port, '--bind', '127.0.0.1' `
    -WorkingDirectory $root -WindowStyle Hidden -PassThru

  $ready = $false
  for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Milliseconds 250
    try {
      $null = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/index.html" -UseBasicParsing -TimeoutSec 2
      $ready = $true
      break
    } catch { }
  }
  if (-not $ready) { throw "临时服务器没起来（端口 $Port 可能被占用），换 -Port 再试。" }

  $n = 0
  foreach ($s in $shots) {
    $n++
    $out = Join-Path $root ('preview\' + $s.file)
    $profile = Join-Path $env:TEMP ("dsh-shot-$PID-$n")
    $profiles += $profile
    $args = @(
      '--headless=new', '--disable-gpu', '--no-first-run', '--hide-scrollbars',
      "--user-data-dir=$profile",
      "--window-size=$($s.w),$($s.h)",
      '--virtual-time-budget=3500',
      "--screenshot=$out",
      "http://127.0.0.1:$Port/$($s.url)"
    )
    Start-Process -FilePath $Chrome -ArgumentList $args -Wait -NoNewWindow
    $size = [math]::Round((Get-Item $out).Length / 1KB, 1)
    Write-Host ("  {0,-16} {1,6} KB  {2}" -f $s.file, $size, $s.url) -ForegroundColor Green
  }
  Write-Host ''
  Write-Host ("完成：{0} 张截图已更新到 preview\" -f $shots.Count) -ForegroundColor Cyan
}
finally {
  if ($server -and -not $server.HasExited) { Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue }
  foreach ($p in $profiles) { Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue }
}
