@echo off
set str=%1
set str=%str:"=%
if exist "%str%" (
>nul findstr "^" "%str%" || del "%str%"
)