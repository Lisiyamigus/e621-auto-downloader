@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
mode con: cols=100 lines=50
title e621 AUTO-SORT QUEUE

set "current_rgb=0;255;255"
if exist "theme.cfg" (
    set /p current_rgb=<theme.cfg
)

py --version >nul 2>&1
if errorlevel 1 (
    echo [!] Python is not found. Please install it from python.org
    pause
    exit
)

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

:home
set "q_count=0"
if exist "queue.json" (
    for /f "usebackq tokens=*" %%a in ("queue.json") do (
        set "line=%%a"
        set "line=!line:{=!"
        if "!line!" neq "%%a" set /a q_count+=1
    )
)

cls
echo %ESC%[38;2;!current_rgb!m
echo  ==================================================================
echo           ███████╗ ██████╗ ██████╗   ██╗
echo           ██╔════╝██╔════╝ ╚═══██╗  ███║
echo           █████╗  ███████╗  █████╔╝  ██║
echo           ██╔══╝  ██╔═══██╗██╔═══╝   ██║
echo           ███████╗╚██████╔╝███████╗  ██║
echo           ╚══════╝ ╚═════╝ ╚══════╝  ╚═╝
echo  ==================================================================
echo   [ STATUS: !q_count! Jobs in Queue ]
echo.
echo   [1] ADD JOB TO QUEUE     [2] START DOWNLOADS     [3] OPEN DOWNLOADS
echo   [4] EDIT BLACKLIST       [5] CHANGE THEME (RGB)   [6] EXIT
echo.
set /p choice=" > Selection: "
if "%choice%"=="1" goto wizard
if "%choice%"=="2" goto run_queue
if "%choice%"=="3" (
    if not exist "downloads" mkdir "downloads"
    start explorer "downloads"
    goto home
)
if "%choice%"=="4" (
    if not exist "blacklist.txt" echo. > blacklist.txt
    notepad blacklist.txt
    goto home
)
if "%choice%"=="5" goto color_menu
if "%choice%"=="6" exit
goto home

:color_menu
cls
echo  ==================== THEME SETTINGS ====================
echo   [1] Cyan   [2] Green   [3] Pink   [4] CUSTOM RGB
set /p c=" > Selection: "
if "%c%"=="1" set "new_rgb=0;255;255"
if "%c%"=="2" set "new_rgb=0;255;0"
if "%c%"=="3" set "new_rgb=255;0;255"
if "%c%"=="4" goto rgb_prompt

set "current_rgb=!new_rgb!"
echo !current_rgb!>theme.cfg
goto home

:rgb_prompt
set /p r=" > R: "
set /p g=" > G: "
set /p b=" > B: "
set "current_rgb=!r!;!g!;!b!"
echo !current_rgb!>theme.cfg
goto home

:wizard
cls
echo  ==================== QUEUE WIZARD ====================
echo.
echo  [ Use e621 tags for names. Use 'all' for species searches ]
:char_entry
set /p w_char=" > Character Name: "
if "!w_char!"=="" goto char_entry

if /i "!w_char!"=="all" (
    echo  [ Enter a species tag like 'canine' or 'dragon' ]
    set /p w_spec=" > Species Name: "
) else ( set "w_spec=none" )

echo.
echo  [ s = Safe, q = Questionable, e = Explicit ]
:rate_entry
set /p w_rate=" > Rating (s/q/e): "
if "!w_rate!"=="" set "w_rate=any"

echo.
echo  [ Write it using an operator: ^>100 , ^<50 , or =200 ]
:score_entry
set /p w_qual=" > Min Score: "

echo.
echo  [ Pick 'n' to exclude specific types ]
:type_interview
set /p all_types=" > Download all file types? (y/n): "
if /i "!all_types!"=="y" (
    set "w_img=y"
    set "w_vid=y"
    set "w_gif=y"
) else (
    set /p w_img=" >> Include Images? (y/n): "
    set /p w_vid=" >> Include Videos? (y/n): "
    set /p w_gif=" >> Include Gifs? (y/n): "
)

echo.
echo  [ Max posts to fetch for this job ]
set /p w_lim=" > Limit (default 10): "
if "!w_lim!"=="" set "w_lim=10"

echo.
echo  [ Use e621 tags only. Separate multiple tags with ; ]
set /p w_tags=" > Extra Tags: "
if not exist "blacklist.txt" echo. > blacklist.txt
set /p w_black=<blacklist.txt

py -c "import json, sys; q=json.load(open('queue.json')); q.append({'char':sys.argv[1],'spec':sys.argv[2],'rate':sys.argv[3],'qual':sys.argv[4],'inc_img':sys.argv[5],'inc_vid':sys.argv[6],'inc_gif':sys.argv[7],'lim':sys.argv[8],'tags':sys.argv[9],'black':sys.argv[10]}); json.dump(q, open('queue.json','w'))" "!w_char!" "!w_spec!" "!w_rate!" "!w_qual!" "!w_img!" "!w_vid!" "!w_gif!" "!w_lim!" "!w_tags!" "!w_black!"

set /p more=" > Add another? (y/n): "
if /i "!more!"=="y" goto wizard
goto home

:run_queue
cls
py downloader.py
echo [] > queue.json
pause
goto home
