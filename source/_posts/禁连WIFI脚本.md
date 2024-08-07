---
title: 禁连WIFI脚本
date: 2024-05-2 00:00:00
tags:
    - Windows
    - Batch Scripts
---

####	解决问题：

公司 WIFI有 Office 和 Guest 两类。有时员工在会议室使用笔记本会图方便连接使用 Office WIFI。为了解决这类问题，需要使员工连接不上 Office WIFI。



####	基本原理:

使用 Windows 提供的 `netsh` 工具，禁用掉指定 SSID 的 WIFI。



####	Batch Scripts：

```powershell
@echo off

rem date 2024.4.19

rem 提权
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%~dp0"

:input

rem 禁用: y, 启用：n
set /p op=disable ^(y^) or enable ^(n^) ?  (y ^| n)	
echo.
if /i "%op%"=="Y" (
	rem netsh wlan add filter permission=denyall networktype=infrastructure
	netsh wlan add filter permission=block ssid="XXX-OFFICE" networktype=infrastructure
	netsh wlan set blockednetworks display=hide
) else if /i "%op%"=="N" (
	rem netsh wlan delete filter permission=denyall networktype=infrastructure
	netsh wlan delete filter permission=block ssid="XXX-OFFICE" networktype=infrastructure
	rem netsh wlan set blockednetworks display=hide
) else (
	echo 无效输入，请输入 y 或 n
	goto input
)

echo done!
pause

```

