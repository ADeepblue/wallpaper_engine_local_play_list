@echo off
title 壁纸列表更新器

echo [1/2] 正在全自动扫描图片并重组 index.html ...

:: 统一调用系统自带的 PowerShell 来处理文本，完美规避 > 和 < 的特殊字符冲突
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$htmlPath = 'index.html';" ^
    "$exts = @('.png', '.jpg', '.jpeg', '.webp', '.bmp');" ^
    "$files = Get-ChildItem -File | Where-Object { $exts -contains $_.Extension.ToLower() } | ForEach-Object { \"'\" + $_.Name + \"'\" };" ^
    "$arrStr = [string]::Join(',', $files);" ^
    "$content = Get-Content -LiteralPath $htmlPath -Raw -Encoding utf8;" ^
    "$pattern = '(?s)<!--IMAGE_LIST_START-->.*';" ^
    "$replacement = '<!--IMAGE_LIST_START-->' + [Environment]::NewLine + '<script>const rawImages = [' + $arrStr + '];</script>';" ^
    "$newContent = $content -replace $pattern, $replacement;" ^
    "[System.IO.File]::WriteAllText($htmlPath, $newContent, [System.Text.Encoding]::UTF8);"

if %errorlevel% equ 0 (
    echo [2/2]  更新成功！已将最新图片写进壁纸 
) else (
    echo [2/2]  更新失败，请检查 index.html 是否被其他程序占用。
)

timeout /t 2 >nul
