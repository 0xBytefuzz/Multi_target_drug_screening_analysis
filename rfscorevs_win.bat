@ECHO OFF
REM 
echo ����ʹ��rf-score-vs����÷� ���Ե�.....
for %%c in (C:\Users\vvc\Desktop\test\ligmol2\*.mol2) do (
    echo ��ǰĿ¼��%cd%
	echo %%c
	start rf-score-vs.exe --receptor ARM_C1.pdb %%c -o csv --field "name" --field "RFScoreVS_v2" -O %%c.csv 
)
