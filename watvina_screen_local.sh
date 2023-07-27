#! /bin/bash
for f in outpdbqt/*.pdbqt; do
    b=`basename $f .pdbqt`
	echo $b
	echo $f
    echo Processing ligand $b
    mkdir -p ./out/$b
    ./watvina --config conf.txt --implicitsol --ligand $f  --out ./out/${b}/${b}.pdbqt --log ./out/${b}/${b}.txt 
done
