@ECHO OFF



call logiconfig.bat

IF DEFINED LOGI_HOME (
   echo "LOGI_HOME: %LOGI_HOME%"
) ELSE (
         echo The LOGI_HOME environment variable is not defined correctly.
         echo It is needed to run Logi Data Services.

         goto exit
)


IF DEFINED NODE_HOME ( 
  SET "PATH=%NODE_HOME%;%PATH%"
)ELSE (
         echo The NODE_HOME environment variable is not defined correctly.
         echo It is needed to run Logi Data Services.

         goto exit
)

if exist "%LOGI_HOME%\platform\bin\logiconfig.bat" goto checknode
echo The LOGI_HOME environment variable is not defined correctly.
echo It is needed to run Logi Data Services.

goto exit

:checknode

if exist "%NODE_HOME%\node.exe" goto okNode
echo The NODE_HOME environment variable is not defined correctly.
echo It is needed to run Logi Data Services.

goto exit
:okNode
node "%LOGI_HOME%\platform\bin\clientSecret.js" %*


:exit
exit /b %errorlevel% 