@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
mode con: cols=100 lines=48
title e621 AUTO-SORT QUEUE

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "current_rgb=0;255;255"
if not exist "queue.json" echo [] > queue.json

:home
set "q_count=0"
for /f "usebackq tokens=*" %%a in ("queue.json") do (
    set "line=%%a"
    set "line=!line:{=!"
    if "!line!" neq "%%a" set /a q_count+=1
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
if "%choice%"=="3" start explorer "downloads" & goto home
if "%choice%"=="4" notepad blacklist.txt & goto home
if "%choice%"=="5" goto color_menu
if "%choice%"=="6" exit
goto home

:wizard
cls
echo  ==================== QUEUE WIZARD ====================
echo.
echo  [ SLIP NOTE: Use 'all' for species searches ]
:char_entry
set /p w_char=" > Character Name: "
if "!w_char!"=="" goto char_entry
if /i "!w_char!"=="all" (
    echo  [ SLIP NOTE: Enter a species like 'canine' or 'dragon' ]
    :spec_entry
    set /p w_spec=" > Species Name: "
    if "!w_spec!"=="" goto spec_entry
) else ( set "w_spec=none" )

echo.
echo  [ SLIP NOTE: s = Safe, q = Questionable, e = Explicit ]
:rate_entry
set /p w_rate=" > Rating (s/q/e): "
py -c "import sys; sys.exit(0 if sys.argv[1].lower() in ['s','q','e'] else 1)" "!w_rate!"
if errorlevel 1 goto rate_entry

echo.
echo  [ SLIP NOTE: Must include operator, e.g., >50 or =100 ]
:score_entry
set /p w_qual=" > Min Score: "
py -c "import sys; s=sys.argv[1]; sys.exit(0 if any(op in s for op in '><=') and any(c.isdigit() for c in s) else 1)" "!w_qual!"
if errorlevel 1 goto score_entry

echo.
echo  [ SLIP NOTE: Pick 'n' to exclude specific types ]
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
echo  [ SLIP NOTE: Max posts to fetch for this job ]
:limit_entry
set /p w_lim=" > Limit: "
py -c "import sys; sys.exit(0 if sys.argv[1].isdigit() else 1)" "!w_lim!"
if errorlevel 1 goto limit_entry

echo.
echo  [ SLIP NOTE: Optional tags, separate with ; ]
set /p w_tags=" > Extra Tags: "
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

:color_menu
cls
echo  ==================== THEME SETTINGS ====================
echo   [1] Cyan   [2] Green   [3] Pink   [4] CUSTOM RGB
set /p c=" > Selection: "
if "%c%"=="1" set "current_rgb=0;255;255" & goto home
if "%c%"=="2" set "current_rgb=0;255;0"   & goto home
if "%c%"=="3" set "current_rgb=255;0;255" & goto home
if "%c%"=="4" goto rgb_prompt
goto home

:rgb_prompt
set /p r=" > R: "
set /p g=" > G: "
set /p b=" > B: "
set "current_rgb=!r!;!g!;!b!"
goto home
