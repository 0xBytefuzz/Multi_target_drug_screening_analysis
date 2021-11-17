#! /bin/bash
i=1
for f in ./mol2/*.mol2; do
	b=`basename $f `
	echo "path+name" ${f}
	echo "name" ${b} 
	echo $i
	pdbqtname="${i}"
	echo $pdbqtname
	obabel -imol2 ${f} -opdbqt -O ./output/${b}.pdbqt -p 7.2 --partialcharge gasteiger
	i=$(($i+1))
	echo $i
	
done