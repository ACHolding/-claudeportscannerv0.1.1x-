@echo off
setlocal enabledelayedexpansion

REM ===================================================
REM  KONDO PORT SCANNER v0.1
REM  Simple batch-based port scanner for Windows
REM  Usage: Kondo_portscannerv0.1.bat [target] [start_port] [end_port]
REM ===================================================

color 0A
title KONDO Port Scanner v0.1

if "%1"=="" (
    echo.
    echo  [!] No target specified
    echo  Usage: Kondo_portscannerv0.1.bat [target_ip] [start_port] [end_port]
    echo  Example: Kondo_portscannerv0.1.bat 192.168.1.1 1 1000
    echo.
    set /p target="Enter target IP: "
    set /p start_port="Enter start port (default 1): "
    set /p end_port="Enter end port (default 65535): "
    if "!start_port!"=="" set start_port=1
    if "!end_port!"=="" set end_port=65535
) else (
    set target=%1
    set start_port=%2
    set end_port=%3
    if "!start_port!"=="" set start_port=1
    if "!end_port!"=="" set end_port=1024
)

echo.
echo ============================================================
echo  [+] KONDO Port Scanner v0.1
echo  [+] Target: !target!
echo  [+] Port Range: !start_port! - !end_port!
echo  [+] Start Time: %date% %time%
echo ============================================================
echo.

REM Create temp file for results
set logfile=%temp%\kondo_scan_%random%.txt

REM PowerShell-based scanner (more reliable)
powershell -NoProfile -Command "
$target = '!target!'
$startport = !start_port!
$endport = !end_port!
$timeout = 500

Write-Host '[*] Starting port scan...' -ForegroundColor Cyan

for ($port = $startport; $port -le $endport; $port++) {
    try {
        $socket = New-Object System.Net.Sockets.TcpClient
        $socket.ConnectAsync($target, $port).Wait($timeout)
        if ($socket.Connected) {
            Write-Host '[OPEN]' -ForegroundColor Green -NoNewline
            Write-Host ' Port ' -NoNewline
            Write-Host $port -ForegroundColor Yellow -NoNewline
            Write-Host ' is open'
            $socket.Close()
        }
    } catch {
        REM Port closed, skip
    }
    
    if ($port % 50 -eq 0) {
        Write-Host '[*] Scanned up to port ' $port -ForegroundColor Cyan
    }
}

Write-Host '' 
Write-Host '[+] Scan complete!' -ForegroundColor Green
"

echo.
echo ============================================================
echo  [+] End Time: %date% %time%
echo ============================================================
echo.
pause
