@echo off
for /f "delims=" %%F in ('dir /b /a-d ^| findstr /vile ".sdb .sbk .lua .bat"') do del "%%F"