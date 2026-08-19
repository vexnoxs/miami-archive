# build.ps1 - genera le pagine statiche del sito MIAMI
# Uso: powershell -File build.ps1
# Unica fonte di verita': data.json (nav + contenuti) + template.html (shell) + partials/
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8([string]$path) {
    return [System.IO.File]::ReadAllText($path)
}

function Write-Utf8([string]$path, [string]$content) {
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

$template = Read-Utf8 (Join-Path $root "template.html")
$data = Read-Utf8 (Join-Path $root "data.json") | ConvertFrom-Json

function Get-Title([string]$slug) {
    if ($slug -eq "home") { return "miami//" }
    return "miami//$slug"
}

function Build-FooterNav() {
    $out = ""
    foreach ($item in $data.nav) {
        $out += "<a href=""$($item.file)"">$($item.label)</a>"
    }
    return $out
}

function Build-Card($item, [string]$icon, [int]$hue, [int]$index) {
    $link = $item.link
    if (-not $link) { $link = "#" }
    $desc = if ($item.desc) { "<p class=""card-desc"">$($item.desc)</p>" } else { "" }
    $thumb = if ($item.image) { "<img class=""card-thumb-img"" src=""$($item.image)"" alt=""$($item.name)"" />" }
             else { "<i class=""fa-solid $icon""></i>" }
    $thumbClass = if ($item.image) { " card-thumb--img" } else { "" }
    $delay = $index * 0.06
    return @"
<div class="card reveal" style="--t: $hue; --d: ${delay}s">
    <a class="card-thumb$thumbClass" href="$link" target="_blank" rel="noopener">$thumb</a>
    <div class="card-body">
        <h3><a href="$link" target="_blank" rel="noopener">$($item.name)</a></h3>
        $desc
        <div class="card-meta">
            <span class="chip"><i class="fa-solid fa-tag"></i> $($item.version)</span>
            <span class="chip"><i class="fa-solid fa-desktop"></i> $($item.platform)</span>
            <span class="status $($item.status)">$($item.status)</span>
        </div>
    </div>
</div>
"@.Trim()
}

function Build-NewsCard($item, [int]$index) {
    $delay = $index * 0.06
    return @"
<div class="news-card reveal" style="--d: ${delay}s">
    <div class="news-date"><i class="fa-solid fa-calendar-days"></i> $($item.date)</div>
    <h3>$($item.title)</h3>
    <p>$($item.text)</p>
</div>
"@.Trim()
}

$footerNav = Build-FooterNav

# HOME
$homePartial = Read-Utf8 (Join-Path $root "partials/home.html")
$html = $template.Replace("{{SLUG}}", "home")
$html = $html.Replace("{{NAV}}", $footerNav)
$html = $html.Replace("{{DESC}}", $data.site.tagline)
$html = $html.Replace("{{TITLE}}", (Get-Title "home"))
$html = $html.Replace("{{CONTENT}}", $homePartial)
Write-Utf8 (Join-Path $root "index.html") $html
Write-Host "generato index.html"

# PAGINE CATEGORIA
foreach ($prop in $data.pages.PSObject.Properties) {
    $page = $prop.Value
    $cards = ""
    $i = 0
    foreach ($item in $page.items) {
        $cards += (Build-Card $item $page.icon $page.hue $i) + "`n"
        $i++
    }
    $content = @"
<section class="category-section">
    <div class="page-header reveal">
        <h2 class="chrome-text">$($page.title)</h2>
        <p>$($page.subtitle)</p>
    </div>

    <div class="cards-grid">
$cards
    </div>
</section>
"@
    $html = $template.Replace("{{SLUG}}", $page.slug)
    $html = $html.Replace("{{NAV}}", $footerNav)
    $html = $html.Replace("{{DESC}}", $page.desc)
    $html = $html.Replace("{{TITLE}}", (Get-Title $page.slug))
    $html = $html.Replace("{{CONTENT}}", $content)
    Write-Utf8 (Join-Path $root $page.file) $html
    Write-Host "generato $($page.file)"
}

# NEWS
$newsCards = ""
$i = 0
foreach ($item in $data.news) {
    $newsCards += (Build-NewsCard $item $i) + "`n"
    $i++
}
$content = @"
<section class="category-section">
    <div class="page-header reveal">
        <h2 class="chrome-text">News</h2>
        <p>Gli ultimi aggiornamenti dalla community</p>
    </div>

    <div class="news-grid">
$newsCards
    </div>
</section>
"@
$html = $template.Replace("{{SLUG}}", "news")
$html = $html.Replace("{{NAV}}", $footerNav)
$html = $html.Replace("{{DESC}}", "Gli ultimi aggiornamenti dalla community di Miami.")
$html = $html.Replace("{{TITLE}}", (Get-Title "news"))
$html = $html.Replace("{{CONTENT}}", $content)
Write-Utf8 (Join-Path $root "news.html") $html
Write-Host "generato news.html"

Write-Host "Build completata."