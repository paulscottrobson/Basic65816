@echo off
rem
rem	Generally used for building stuff. Most of these scripts set up random
rem	basic programs which check the various operations \ functions etc.
rem
rem call exec.bat test_functions.py
rem call exec.bat basicblock.py
rem call exec.bat test_creation.py
rem call exec.bat make_garbage.py
rem python ..\scripts\showdump.py gc
rem python ..\scripts\showdump.py
rem call exec.bat make_tokenise.py

call exec.bat make_basic.py

rem call exec.bat make_editor.py
rem python ..\scripts\check_editor.py


