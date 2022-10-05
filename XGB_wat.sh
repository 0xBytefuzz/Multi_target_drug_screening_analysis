#! /bin/bash
i=1
touch XGB_SCORE_CU1
for pf in ./dock_scorecu1/ligpdb/*.pdb; do
	fn=`basename $pf ` 
	f="${fn%.*}"
	echo "path+name" ${pf}
	echo "name" ${fn} 
	echo $i
	echo ${f}
	pdbqtname="${i}"
	echo $pdbqtname
	echo ${f} >> XGB_SCORE
	python script/runXGB.py ./dock_scorecu1/ARM_C1.pdb ${pf} | grep 'XGB' >> XGB_SCORE_CU1
	i=$(($i+1))
	echo $i
	echo -e "\n" >>XGB_SCORE_CU1
done