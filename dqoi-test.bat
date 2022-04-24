@echo off

:: Binary and QOI testing
bin\dqoi -f testing\monument.qoi --bin | more
bin\dqoi -f outputs\testing\monument.bin -w 735 -h 588 --channels 4 --colorspace 1 | more

move /Y outputs\outputs\testing\monument.qoi outputs\ > nul
rmdir /S /Q outputs\outputs
move /Y outputs\testing\monument.bin outputs\ > nul
rmdir /S /Q outputs\testing

fc /b testing\monument.qoi outputs\monument.qoi
fc /b testing\monument.bin outputs\monument.bin

:: PNG and QOI testing
:: Does not test decoding algorithm
bin\dqoi -f testing\testcard_rgba.png | more
move /Y outputs\testing\testcard_rgba.qoi outputs\ > nul
rmdir /S /Q outputs\testing
fc /b testing\testcard_rgba.qoi outputs\testcard_rgba.qoi