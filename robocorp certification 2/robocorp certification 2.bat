@ECHO OFF
CALL cd /D %1
rcc run -e devdata/env.json
