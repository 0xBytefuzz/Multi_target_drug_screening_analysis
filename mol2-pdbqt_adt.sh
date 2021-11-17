#! /bin/bash
i=1
for f in ./mol2/*.mol2; do
	b=`basename $f `
	echo "path+name" ${f}
	echo "name" ${b} 
	echo $i
	pdbqtname="${i}"
	echo $pdbqtname
	/home/vvc/opt/mgltools/MGLTools-1.5.6/bin/pythonsh prepare_ligand4.py -l ${f} -o ./outpdbqt/${b}.pdbqt -U lps
	i=$(($i+1))
	echo $i	
done