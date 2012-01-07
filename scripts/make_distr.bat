SET dest=..\_distr

rmdir /S/Q %dest%
mkdir %dest%
xcopy ..\lib %dest%\lib\ /Y /E
xcopy ..\logs %dest%\logs\ /Y /E
xcopy ..\scripts %dest%\scripts\ /Y /E
xcopy ..\central_run_me.rb %dest%\ /Y
xcopy ..\client_run_me.rb %dest%\ /Y
xcopy ..\config.rb.example %dest%\ /Y
PAUSE
