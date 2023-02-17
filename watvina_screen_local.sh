#! /bin/bash
for f in mol/*.pdbqt; do
    b=`basename $f .pdbqt`
	echo $b
	echo $f
    echo Processing ligand $b
    mkdir -p ./out/$b
    ./watvina --config conf.txt --ligand $f  --out ./out/${b}/out.pdbqt --log ./out/${b}/log.txt
done
