# 听原的个人博客

零依赖静态博客。双击 `index.html` 就能看，不需要安装任何东西。

**作者**：[听原](https://github.com/Wenquxing884) · **视觉**：配色与头像取自插画「菲比啾比」

## 目录

```
blog/
├── index.html              首页（hero + 搜索 + 文章卡片列表）
├── archive.html            归档（按年份平铺）
├── about.html              关于页（GitHub 仓库、邮箱、RSS）
├── 404.html                404 页（GitHub Pages 会自动使用，附推荐入口）
├── feed.xml                RSS 2.0 订阅源
├── sitemap.xml             站点地图
├── robots.txt              爬虫规则
├── README.md               本文件
├── posts/
│   ├── android-ai-image-studio.html
│   ├── hello-world.html            既是第一篇，也是新文章模板
│   ├── text-recognition-clicker.html
│   └── build-with-zero-deps.html
├── assets/
│   ├── img/
│   │   ├── avatar.webp     头像 512×512，18KB
│   │   ├── avatar.jpg      同尺寸 JPEG 备用
│   │   ├── avatar-180.png  无损小图
│   │   ├── favicon.png     站点图标 64×64
│   │   └── og-cover.png    社交分享预览图 1200×630
│   ├── style.css           全部样式（明暗双主题 + 打印样式）
│   └── main.js             主题切换 / 进度条 / 回到顶部 / 搜索 / 代码复制 / 标题锚点
├── games/
│   └── phoebe-2048/        菲比啾比 2048（单文件游戏）
│       ├── index.html      游戏本体，HTML/CSS/JS 全内联
│       ├── assets/phoebe.jpg
│       ├── assets/sfx-merge.wav  合并音效（8-bit 版，随数值升调）
│       ├── assets/sfx-win.wav    达成 2048 的音效
│       ├── preview.png     原尺寸截图 900×1040
│       └── preview-small.webp  480×555，15KB
├── preview/                整页截图，改版前后对比用，不参与部署
└── tools/
    ├── set-domain.ps1      一键换域名
    └── screenshots.ps1     重新生成 preview/ 里的截图
```

## 本地预览

直接双击 `index.html` 即可。想用本地服务器（更接近线上环境，`file://` 下剪贴板 API 会降级）：

```powershell
cd F:\1\个人博客\blog
python -m http.server 8080
# 然后打开 http://127.0.0.1:8080
```

## 换域名（部署前唯一必做的一步）

域名在 8 个 HTML 和 `feed.xml`、`sitemap.xml`、`robots.txt` 里各写了一份，手改容易漏。用脚本：

```powershell
cd F:\1\个人博客\blog

# 先看会改哪些文件、共几处（不落盘）
.\tools\set-domain.ps1 -Domain https://blog.example.com -DryRun

# 确认无误后真正写入
.\tools\set-domain.ps1 -Domain https://blog.example.com
```

旧地址从 `index.html` 的 `og:url` 自动读取，也可以用 `-Old` 显式指定。脚本只碰 `*.html`、`*.xml`、`*.txt`，跳过 `_backup` 与 `tools`。

## 重新生成预览截图

改了样式之后，`preview/` 里的图会过时。一条命令重拍（自动起临时服务器、调用本机 Chrome 无头模式，跑完关掉）：

```powershell
cd F:\1\个人博客\blog
.\tools\screenshots.ps1
```

输出五张：`home.png`、`about.png`、`post-android.png`、`post-ocr.png`、`mobile.png`，尺寸与文件名固定。端口被占用时加 `-Port 8100`，没装 Chrome 会自动找 Edge。

## 设计语言

来自头像插画的三条规则：

1. **奶油底色 + 深棕墨色**，不用纯黑。`#FEF8E8` 底、`#3A2A22` 字。
2. **圆润 + 描边**。卡片 20px 圆角、1.5px 描边；按钮是 2px 描边加 3px 硬阴影，按下会位移。
3. **虚线分隔**，呼应被子边缘那排虚线。

背景铺了一层 22px 的点阵，模仿插画的网点质感，透明度 4.5%，几乎察觉不到但能消除纯色底的塑料感。

### 色板

| 变量 | 浅色 | 深色 | 用途 |
|---|---|---|---|
| `--paper` | `#FEF8E8` | `#1A1613` | 页面底色 |
| `--card` | `#FFFDF6` | `#221D19` | 卡片 / 代码块 |
| `--ink` | `#3A2A22` | `#F0E6D8` | 正文、按钮描边 |
| `--line-strong` | `#D9C9AE` | `#4A3A2C` | 描边、虚线 |
| `--accent` | `#5FA8D8` | `#7FBEE6` | 发夹蓝，按钮底与装饰 |
| `--accent-deep` | `#2A6E99` | `#9CCFF0` | 链接、小标题（浅色下压深过，保证 4.5:1） |
| `--violet` | `#8E7BD0` | `#A996E8` | 瞳孔紫，次级强调 |
| `--butter` | `#FEECBD` | `#3A3320` | 被子黄，标签与高亮 |
| `--blush` | `#F5C9C2` | `#4A302C` | 腮红粉，备用 |

改配色只动 `assets/style.css` 顶部这两组变量，全站跟着变。改完记得同步 `<meta name="theme-color">` 的 `#FEF8E8`（在每页 `<head>` 里，`main.js` 切主题时会覆盖它）。

### 对比度约束

正文之外的弱化文字（日期、分类、页脚、图注）都用 `--muted`，两套主题都压在 4.5:1 以上：

| 组合 | 浅色 | 深色 |
|---|---|---|
| `--muted` 压 `--paper` | 4.87:1 | 5.46:1 |
| `--muted` 压 `--card` | 5.07:1 | 5.07:1 |
| `--accent-deep` 压 `--paper` | 4.91:1 | 10.78:1 |
| 按钮字压 `--accent` | 6.22:1 | 8.02:1 |

主按钮统一用深墨字（`#17222A`）压在浅蓝上，而不是白字——白字在 `#5FA8D8` 上只有 2.55:1，看着“糊”。`.btn.ghost` 是卡片底，必须继续用 `var(--ink)`，否则深色下深墨字压深底等于消失。改按钮配色时这两条别踩。

## 主题切换怎么不闪白

深色模式如果在 `<body>` 末尾才应用，会先闪一下奶油底。所以每页 `<head>` 里都有一段内联脚本，在样式表之前就把 `data-theme` 写上去：

```html
<script>/* 首屏前应用主题，避免深色模式闪白 */
(function(){try{var t=localStorage.getItem('yg-blog-theme')||
(window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light');
document.documentElement.setAttribute('data-theme',t);}catch(e){}})();
</script>
```

这段必须内联、必须在 `<link rel="stylesheet">` 之前。`assets/main.js` 只负责后续切换与存储。

## 头像

`assets/img/avatar.webp` 是 512×512、质量 88、18KB。四个位置在用：

- **导航右上角 34px 圆形**，在「关于」链接和主题按钮之间，点它进关于页（悬停会歪一下）
- 首页 hero 108px，白边 + 双环阴影
- 文章页标题下 22px 作者标记
- 页脚 22px，以及 `favicon`（`<link rel="icon">` 指向 `favicon.png`）

换头像：替换这个文件，保持文件名不变即可，别忘同步 `avatar.jpg`。

## 写一篇新文章

1. 复制 `posts/hello-world.html` → `posts/新文件名.html`
2. 改 `<title>`、`<h1>`、`<time datetime>`、`.article-meta` 里的日期/分类/时长
3. 改 `.prose` 里的正文
4. 在 `index.html` 的 `.post-list` 里复制一张 `.card`，改链接、标题、摘要、标签；顺手把 `.section-head .count` 的「N 篇」加一
5. 在 `archive.html` 里加一行 `.archive-item`
6. 在 `sitemap.xml` 加一条 `<url>`，在 `feed.xml` 加一条 `<item>`（最新在最前）
7. 文章末尾的「上一篇 / 下一篇」两个链接互相指一下

文章页可用的排版元素（样式都在 `assets/style.css` 的 `.prose` 段）：

| 元素 | 写法 | 效果 |
|---|---|---|
| 二级标题 | `<h2>` | 左侧蓝色粗竖线，自动生成 `#锚点` |
| 引用 | `<blockquote><p>…</p></blockquote>` | 奶油底 + 黄色左边框 |
| 代码块 | `<pre><code>…</code></pre>` | 描边卡片，横向滚动，右上角自动出现「复制」按钮 |
| 行内代码 | `<code>` | 小号等宽 + 浅底 |
| 表格 | `<table>` | 描边圆角，表头浅底 |
| 图片 + 图注 | `<img>` + `<p class="caption">` | 描边圆角 + 居中说明 |
| 分隔线 | `<hr>` | 虚线 |

代码块的复制按钮和标题锚点都是 `main.js` 运行时加的，正文里不用写任何额外标记。

## 加一个小游戏

游戏放在 `games/<名字>/`，单文件最好（HTML/CSS/JS 全内联），这样没有构建、没有依赖：

1. 建目录 `games/你的游戏/`，把 `index.html` 和素材放进去，**入口文件名必须是 `index.html`**，地址才是 `/games/你的游戏/`
2. 页面 `<head>` 补 `description`、`canonical`、`og:*`，参照 `games/phoebe-2048/index.html`
3. 页面里留两个回博客的入口，否则用户进去就出不来：工具栏里一个按钮，页脚一个链接
   ```html
   <a class="btn back-to-blog" href="../../index.html">← 博客</a>
   <a class="blog-back" href="../../index.html">← 回到听原的博客</a>
   ```
4. 顶部导航 `nav-links` 里加一项 `2048`（指向 `games/phoebe-2048/`），全站页脚也加一个「游戏」入口；`sitemap.xml` 加一条 `<url>`
5. **首页不放游戏卡片**。入口就是导航和页脚两处，首页保持纯文章列表

导航在 420px 以下会自动收紧：间距和字号变小，头像隐藏（「关于」链接还在，不影响导航），这样四个链接也塞得下 360px 宽的屏幕。

游戏页不继承博客的 CSS，样式自带，所以主题切换、进度条那些不会出现在游戏里——这是故意的，游戏要保持自己的画面。

### 2048 的音效与方块

音效是采样，不是合成振荡器：

- `assets/sfx-merge.wav` —— 合并时播放，`playbackRate` 跟着合并后的数值升调（4 约 1.06 倍速，2048 约 1.65 倍速），越合越尖
- `assets/sfx-win.wav` —— 达成 2048 时播放，260 ms 后再叠一层 1.26 倍速的弱音

两个文件都是本项目自己合成的（TTS + 变调 + 啾声 + 混响），没有采样任何现成音频。生成脚本在项目根的 `media/make_audio.py`。

方块视觉：每块有顶部高光和内圈描边（`::before` / `::after`），128 以上右上角出现蓝色十字发卡，2048 和更高数值的紫色块带呼吸光圈（`glowPulse`）。

**调色板预览**：地址后加 `?demo` 会直接摆一桌 2 到 4096 的方块，改配色时用这个看效果，不用真打到 2048。

```text
/games/phoebe-2048/?demo
```

## 每页都有的东西

| 位置 | 内容 | 作用 |
|---|---|---|
| `<head>` | `canonical` | 告诉搜索引擎哪个是正式地址，避免重复收录 |
| `<head>` | `application/ld+json` | 结构化数据：首页 `Blog`、文章页 `BlogPosting`（标题、日期、作者、封面） |
| `<head>` | `og:*` / `twitter:*` | 分享到微信、X、Telegram 时的卡片 |
| `<body>` 开头 | `.skip-link` | 键盘用户第一个 Tab 就能跳到正文 |
| `<footer>` | 归档 / 关于 / RSS / GitHub | 四个入口全站统一 |

## 部署

**GitHub Pages**（最省事）

```powershell
cd F:\1\个人博客\blog
git init
git add .
git commit -m "init blog"
git branch -M main
git remote add origin https://github.com/Wenquxing884/仓库名.git
git push -u origin main
```

然后仓库 Settings → Pages → Source 选 `main` 分支根目录 → Save。访问 `https://wenquxing884.github.io/仓库名/`。

**Cloudflare Pages**：连仓库，构建命令留空，输出目录填 `/`。适合绑自定义域名。

**Vercel**：导入仓库，Framework 选 `Other`，Build Command 留空，Output Directory 填 `.`。

三者都自动签发 HTTPS。域名一年几十块，是这件事唯一的花费。

> 部署前跑一次 `.\tools\set-domain.ps1 -Domain 你的域名`，否则 `og:url`、`canonical`、RSS 里的链接还指着旧地址。

三条路线的完整步骤（GitHub Pages / Cloudflare Pages / 自己的 VPS + nginx）、检查清单、回滚方式，都在 [../deploy/DEPLOY.md](../deploy/DEPLOY.md) 里。VPS 那条配了现成脚本：

```powershell
cd F:\1\个人博客
.\deploy\deploy-ssh.ps1 -Server 服务器IP -Path /var/www/blog -DryRun   # 预览
.\deploy\deploy-ssh.ps1 -Server 服务器IP -Path /var/www/blog          # 真传
```

## 以后想升级

- **文章多了嫌复制烦** → 换 Hugo / Astro / Hexo，写 Markdown，构建出静态页。当前 HTML 结构可以直接迁。
- **要评论** → Giscus（基于 GitHub Discussions，免费、无广告）。
- **要统计** → Umami 或 Cloudflare Web Analytics，都不用挂 cookie 横幅。
- **要 RSS** → 手写一个 `feed.xml`，或换生成器后自动产出。

## 图片怎么处理

- 宽度压到 1600px 以内，WebP 或 JPEG（质量 80），单张 200KB 以下
- 文件名用英文小写加连字符，别用中文和空格
- 每张图都写 `alt`，这既是无障碍要求，也是搜索引擎能读到的内容
- 放在 `assets/img/` 下，文章里用相对路径引用

```html
<img src="../assets/img/example.webp" alt="终端里 nmap 扫描结果的截图" width="1200" height="640" loading="lazy" decoding="async">
<p class="caption">图 1：扫描结果，注意 8080 端口是开放的</p>
```

## 备份

批量改之前整站备份在 `F:\1\个人博客\_backup\blog-<时间戳>\`，出问题直接整目录覆盖回来。`_backup` 与 `_tmp` 不在部署范围内。
