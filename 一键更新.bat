@echo off
title 壁纸列表更新器

echo [1/2] 正在扫描当前目录的图片...

:: 完全避免在命令行中使用 > 或 < 等特殊重定向符号，改用安全的纯文本拼接与文件写入
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$htmlPath = 'index.html';" ^
    "$exts = @('.png','.jpg','.jpeg','.bmp','.gif','.webp');" ^
    "$files = Get-ChildItem -File | Where-Object { $exts -contains $_.Extension.ToLower() } | ForEach-Object { \"'\" + $_.Name + \"'\" };" ^
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
    echo [2/2] 更新成功！已将最新图片列表写入 index.html
) else (
    echo [2/2] 更新失败，请检查 index.html 中是否存在 IMAGE_LIST 标记或文件是否被占用。
)

timeout /t 2 >nul