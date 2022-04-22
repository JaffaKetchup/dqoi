@echo off

bin\dqoi -f testing\dice.qoi | more
bin\dqoi -f outputs\testing\dice.png | more

move /Y outputs\outputs\testing\dice.qoi outputs\
rmdir /S /Q outputs\outputs
move /Y outputs\testing\dice.png outputs\
rmdir /S /Q outputs\testing

fc /b testing\dice.png outputs\dice.png > nul
if errorlevel 1 (
    echo "Different Contents"
) else (
    echo "Same Contents"
)

fc /b testing\dice.qoi outputs\dice.qoi > nul
if errorlevel 1 (
    echo "Different Contents"
) else (
    echo "Same Contents"
)

bin\dqoi -f testing\monument.qoi --bin | more
bin\dqoi -f outputs\testing\monument.bin -w 735 -h 588 | more

move /Y outputs\outputs\testing\monument.qoi outputs\
rmdir /S /Q outputs\outputs
move /Y outputs\testing\monument.bin outputs\
rmdir /S /Q outputs\testing

fc /b testing\monument.qoi outputs\monument.qoi > nul
if errorlevel 1 (
    echo "Different Contents"
) else (
    echo "Same Contents"
)
fc /b testing\monument.bin outputs\monument.bin > nul
if errorlevel 1 (
    echo "Different Contents"
) else (
    echo "Same Contents"
)