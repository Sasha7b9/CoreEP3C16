@echo off
atxt32 -l@@ %1.asm %1.mac
zmac -8 -m %1.mac
rem srec_cat zout\%1.hex -Intel -offset -0x0100 -o zout\%1.com -Binary
srec_cat zout\%1.hex -Intel -o zout\%1.bin -VMem 8
copy zout\%1.bin ..\Model\simulation\modelsim\test.bin >>NUL
srec_cat zout\%1.hex -Intel -fill 0 0x0000 0x8000 -o zout\%1.mif -Memory_Initialization_File 8
copy zout\%1.mif ..\Model\memini.mif >>NUL
del %1.mac
@echo on
