@ECHO OFF
CALL cd /D %1
rcc run -e devdata/env.json --task  Run_Orange_HR_Process
