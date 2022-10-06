@ECHO OFF
REM 
echo 正在使用rf-score-vs计算得分 请稍等.....
for %%c in (C:\Users\vvc\Desktop\test\ligmol2\*.mol2) do (
    echo 当前目录：%cd%
	echo %%c
	start rf-score-vs.exe --receptor ARM_C1.pdb %%c -o csv --field "name" --field "RFScoreVS_v2" -O %%c.csv 
)
