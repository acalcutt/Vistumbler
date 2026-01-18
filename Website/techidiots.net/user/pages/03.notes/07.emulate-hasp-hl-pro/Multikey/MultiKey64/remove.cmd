cd /d %~dp0
@devcon remove root\multikey
@if exist %systemroot%\system32\drivers\multikey.sys del %systemroot%\system32\drivers\multikey.sys
@pause