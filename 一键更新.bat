@echo off
title 壁纸列表更新器

:: 如果 img 文件夹不存在，则自动创建一个
if not exist "img" (
    mkdir "img"
)

echo [1/2] 正在扫描 img 目录下的图片...

:: 使用 PowerShell 扫描 img 文件夹下的图片，并自动带上 img/ 路径前缀
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$htmlPath = 'index.html';" ^
    "$exts = @('.png','.jpg','.jpeg','.bmp','.gif','.webp');" ^
    "$files = Get-ChildItem -LiteralPath 'img' -File | Where-Object { $exts -contains $_.Extension.ToLower() } | ForEach-Object { \"'img/\" + $_.Name + \"'\" };" ^
    "$arrStr = [string]::Join(', ', $files);" ^
    "$content = Get-Content -LiteralPath $htmlPath -Raw -Encoding utf8;" ^
    "$startTag = '<!--IMAGE_LIST_START-->';" ^
    "$endTag = '<!--IMAGE_LIST_END-->';" ^
    "$startIndex = $content.IndexOf($startTag);" ^
    "$endIndex = $content.IndexOf($endTag);" ^
    "if ($startIndex -ne -1 -and $endIndex -ne -1) {" ^
        "$newBlock = $startTag + [Environment]::NewLine + '<script id=\"imageList\">' + [Environment]::NewLine + '    ' + 'const rawImages = [' + $arrStr + '];' + [Environment]::NewLine + '</script>' + [Environment]::NewLine + $endTag;" ^
        "$content = $content.Substring(0, $startIndex) + $newBlock + $content.Substring($endIndex + $endTag.Length);" ^
        "[System.IO.File]::WriteAllText($htmlPath, $content, [System.Text.Encoding]::UTF8);" ^
        "Write-Host 'SUCCESS';" ^
    "} else {" ^
        "Write-Host 'ERROR_TAG_NOT_FOUND';" ^
    "}"

if %errorlevel% equ 0 (
    echo [2/2] 更新成功！已将 img 目录下的图片列表写入 index.html
) else (
    echo [2/2] 更新失败，请检查 index.html 中是否存在 IMAGE_LIST 标记或文件是否被占用。
)

timeout /t 2 >nul