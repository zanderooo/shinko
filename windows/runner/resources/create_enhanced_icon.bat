@echo off
echo Creating enhanced app icon for Shinko...
echo.

REM Check if ImageMagick is available
where magick >nul 2>nul
if %errorlevel% neq 0 (
    echo ImageMagick not found. Please install ImageMagick or use an online converter.
    echo You can convert app_icon_enhanced.svg to ICO format at:
    echo https://convertio.co/svg-ico/
    echo or https://cloudconvert.com/svg-to-ico
    echo.
    echo Create ICO with these sizes: 16x16, 32x32, 48x48, 64x64, 128x128, 256x256
    pause
    exit /b 1
)

REM Create PNG versions at different sizes
magick convert "app_icon_enhanced.svg" -resize 256x256 "app_icon_256.png"
magick convert "app_icon_enhanced.svg" -resize 128x128 "app_icon_128.png"
magick convert "app_icon_enhanced.svg" -resize 64x64 "app_icon_64.png"
magick convert "app_icon_enhanced.svg" -resize 48x48 "app_icon_48.png"
magick convert "app_icon_enhanced.svg" -resize 32x32 "app_icon_32.png"
magick convert "app_icon_enhanced.svg" -resize 16x16 "app_icon_16.png"

REM Create ICO file with all sizes
magick convert "app_icon_256.png" "app_icon_128.png" "app_icon_64.png" "app_icon_48.png" "app_icon_32.png" "app_icon_16.png" -colors 256 "app_icon.ico"

REM Clean up individual PNG files
del "app_icon_*.png"

echo Enhanced app icon created successfully!
echo.
echo The new icon has been saved as app_icon.ico
echo You may need to restart your application to see the changes.
pause