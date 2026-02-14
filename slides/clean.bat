@echo off
del /Q *.aux *.log *.nav *.out *.snm *.toc *.vrb *.fls *.fdb_latexmk *.synctex.gz *.synctex *.synctex(busy) 2>nul
del /Q sections\*.aux sections\*.log sections\*.nav sections\*.out sections\*.snm sections\*.toc sections\*.vrb sections\*.fls sections\*.fdb_latexmk sections\*.synctex.gz sections\*.synctex sections\*.synctex(busy) 2>nul
echo LaTeX auxiliary files cleaned.