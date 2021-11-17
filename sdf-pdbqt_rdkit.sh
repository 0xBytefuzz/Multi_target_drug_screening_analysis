#! /bin/bash
i=1
for f in ./sdf/*.sdf; do
	b=`basename $f `
	python rdkit2pdbqt.py -l ./sdf/${f} 2>&1 | tee -a ./pdbqt/${b}.pdbqt
done