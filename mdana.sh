#!/bin/bash
#routine analysis dt100
echo  0 0 |gmx trjconv -f md.xtc -s md.tpr -o nj_centdt100.xtc  -dt 100 -pbc nojump -ur compact -center
echo  24 0 |gmx trjconv -f nj_centdt100.xtc -s  md.tpr -fit rot+trans -o mdfit.xtc -n index.ndx
echo  4 4 |gmx rms -s md.tpr -f mdfit.xtc -o pro-bkbone-rmsd.xvg -n index.ndx
echo  1 |gmx rmsf -s md.tpr -f mdfit.xtc -b 20000 -o pro-rmsf.xvg -ox com-avg.pdb -oq bf_residue.pdb -res
echo  1 |gmx gyrate -s md.tpr -f mdfit.xtc -o pro-gyrate.xvg
echo  1 |gmx sasa -s md.tpr -f mdfit.xtc -o area.xvg -or resarea.xvg -oa atomarea.xvg
echo  1 13 |gmx hbond -s md.tpr -f mdfit.xtc -num pro_lig_hnum.xvg -n index.ndx
#FEL
echo  0 0 |gmx trjconv -f md.xtc -s md.tpr -o nj_cent.xtc -pbc nojump -ur compact -center
echo  1 1 |gmx trjconv -f nj_cent.xtc -b 20000 -s md.tpr -fit rot+trans -o pcamdfit.xtc
echo  3 3 |gmx covar -s md.gro -f pcamdfit -o eigenvalues.xvg -v eigenvectors.trr -xpma covapic.xpm
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -first 1 -last 2 -2d 2d.xvg
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -last 1 -proj pc1.xvg
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -first 2 -last 2 -proj pc2.xvg
rm -f gsham_input.xvg
perl sham.pl -i1 pc1.xvg -i2 pc2.xvg -data 1 -data2 1 -o gsham_input.xvg
gmx sham -f gsham_input.xvg -ls FES.xpm
python2 xpm2txt.py -f FES.xpm -o free-energy-landscapePCA.txt
#RMSDRgFEL
echo  0 0 |gmx trjconv -f nj_cent.xtc -s md.tpr -o pcamdfit -pbc nojump -ur compact -center
echo  1 |gmx gyrate -s md.tpr -f pcamdfit.xtc -o FEL_gyrate.xvg
echo  1 1 |gmx rms -s  md.tpr -f pcamdfit.xtc -o FEL_rmsd.xvg
rm -f gsham_RMSDRginput.xvg
perl sham.pl -i1 FEL_rmsd.xvg -i2 FEL_gyrate.xvg -data 1 -data2 1 -o gsham_RMSDRginput.xvg
gmx sham -f gsham_RMSDRginput.xvg -ls FEL_sham.xpm -tsham 300
python2 xpm2txt.py -f FEL_sham.xpm -o free-energy-landscapeRMSDRg.txt
#PCA
echo  0 0 |gmx trjconv -f md.xtc -s md.tpr -o nj_cent_dt.xtc  -dt 50 -pbc nojump -ur compact -center
echo  1 1 |gmx trjconv -f nj_cent_dt.xtc -b 10000 -s md.tpr -fit rot+trans -o pcamdfit.xtc
mdconvert -o pca.dcd  -t bf_residue.pdb pcamdfit.xtc
Rscript PCA_DCCM.R
mkdir ana_md
mv mdfit.xtc pro-bkbone-rmsd.xvg pro-rmsf.xvg bf_residue.pdb pro-gyrate.xvg area.xvg pro_lig_hnum.xvg  ana_md/
mv free-energy-landscapePCA.txt free-energy-landscapeRMSDRg.txt  PCA.png DCCM.png PC.png ana_md/
rm -rf gsham_RMSDRginput.xvg gsham_input.xvg pca.dad 

