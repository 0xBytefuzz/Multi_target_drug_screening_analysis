#! /bin/bash
i=1
touch SF_SCORE_CU1.dat
for pf in ./ligmol2/*.mol2; do
	fn=`basename $pf ` 
	f="${fn%.*}"
	echo "path+name" ${pf}
	echo "name" ${fn} 
	echo $i
	echo ${f}
	pdbqtname="${i}"
	echo $pdbqtname
	python ../predict.py -p ARM_C1.pdb -l ${pf} -o output
	i=$(($i+1))
	echo $i
done
cat ./score/*.dat >SF_SCORE_CU1.dat