# build.ps1 - genera le pagine statiche del sito MIAMI
# Uso: powershell -File build.ps1
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

# Nav unica: ordine, label e file di destinazione
$navItems = @(
    @{ file = "index.html"; label = "Home" },
    @{ file = "clients.html"; label = "faul" },
    @{ file = "packs.html"; label = "Resource Packs" },
    @{ file = "shaders.html"; label = "Shaders" },
    @{ file = "profiles.html"; label = "Profiles" },
    @{ file = "mods.html"; label = "Mods" },
    @{ file = "news.html"; label = "News" }
)

function Build-Nav([string]$activeFile) {
    $out = ""
    foreach ($item in $navItems) {
        $cls = if ($item.file -eq $activeFile) { ' class="active"' } else { '' }
        $out += "<a href=""$($item.file)""$cls>$($item.label)</a>"
    }
    return $out
}

function Build-Card($item, [string]$icon, [int]$hue) {
    $link = $item.link
    if (-not $link) { $link = "#" }
    $desc = if ($item.desc) { "<p class=""card-desc"">$($item.desc)</p>" } else { "" }
    $thumb = if ($item.image) { "<img class=""card-thumb-img"" src=""$($item.image)"" alt=""$($item.name)"" />" }
             else { "<i class=""fa-solid $icon""></i>" }
    return @"
<div class="card" style="--t: $hue">
    <a class="card-thumb" href="$link" target="_blank" rel="noopener">$thumb</a>
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

function Build-NewsCard($item) {
    return @"
<div class="news-card">
    <div class="news-date"><i class="fa-solid fa-calendar-days"></i> $($item.date)</div>
    <h3>$($item.title)</h3>
    <p>$($item.text)</p>
</div>
"@.Trim()
}

$template = Read-Utf8 (Join-Path $root "template.html")
$data = Read-Utf8 (Join-Path $root "data.json") | ConvertFrom-Json

# HOME
$homePartial = Read-Utf8 (Join-Path $root "partials/home.html")
$navHome = Build-Nav "index.html"
$html = $template.Replace("{{SLUG}}", "home")
$html = $html.Replace("{{NAV}}", $navHome)
$html = $html.Replace("{{DESC}}", $data.site.tagline)
$html = $html.Replace("{{TITLE}}", "$($data.site.name) - MiamiArchive")
$html = $html.Replace("{{CONTENT}}", $homePartial)
Write-Utf8 (Join-Path $root "index.html") $html
Write-Host "generato index.html"

# PAGINE CATEGORIA
foreach ($prop in $data.pages.PSObject.Properties) {
    $page = $prop.Value
    $cards = ""
    foreach ($item in $page.items) {
        $cards += (Build-Card $item $page.icon $page.hue) + "`n"
    }
    $content = @"
<section class="category-section">
    <div class="page-header">
        <h2>$($page.title)</h2>
        <p>$($page.subtitle)</p>
    </div>

    <div class="cards-grid">
$cards
    </div>
</section>
"@
    $navPage = Build-Nav $page.file
    $html = $template.Replace("{{SLUG}}", $page.slug)
    $html = $html.Replace("{{NAV}}", $navPage)
    $html = $html.Replace("{{DESC}}", $page.desc)
    $html = $html.Replace("{{TITLE}}", "$($page.title) - MIAMI")
    $html = $html.Replace("{{CONTENT}}", $content)
    Write-Utf8 (Join-Path $root $page.file) $html
    Write-Host "generato $($page.file)"
}

# NEWS
$newsCards = ""
foreach ($item in $data.news) {
    $newsCards += (Build-NewsCard $item) + "`n"
}
$content = @"
<section class="category-section">
    <div class="page-header">
        <h2>News</h2>
        <p>Gli ultimi aggiornamenti dalla community</p>
    </div>

    <div class="news-grid">
$newsCards
    </div>
</section>
"@
$navNews = Build-Nav "news.html"
$html = $template.Replace("{{SLUG}}", "news")
$html = $html.Replace("{{NAV}}", $navNews)
$html = $html.Replace("{{DESC}}", "Gli ultimi aggiornamenti dalla community di Miami.")
$html = $html.Replace("{{TITLE}}", "News - MIAMI")
$html = $html.Replace("{{CONTENT}}", $content)
Write-Utf8 (Join-Path $root "news.html") $html
Write-Host "generato news.html"

Write-Host "Build completata."