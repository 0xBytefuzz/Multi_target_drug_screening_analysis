#!/bin/bash
#routine analysis dt100
mkdir mdanalysis
echo  0 0 |gmx trjconv -f md.xtc -s md.tpr -o nojump.xtc -pbc nojump -ur compact -center
echo  21 0 |gmx trjconv -f nojump.xtc -s  md.tpr -fit rot+trans -o mdfit.xtc -n index.ndx
echo  21 0 |gmx trjconv -f nojump.xtc -dt 100 -s  md.tpr -fit rot+trans -o mdfit_dt100.xtc -n index.ndx
echo  1 1 |gmx trjconv -f nojump.xtc -dt 100 -s  md.tpr -fit rot+trans -o mdfitpro_dt100.xtc -n index.ndx
echo  4 4 |gmx rms -s md.tpr -f mdfit_dt100.xtc -tu ns -o mdanalysis/pro-bkbone-rmsd.xvg -n index.ndx
echo  1 |gmx rmsf -s md.tpr -f mdfit.xtc -b 20000 -o mdanalysis/pro-rmsf.xvg -ox mdanalysis/com-avg.pdb -oq mdanalysis/bf_residue.pdb -res
echo  1 |gmx gyrate -s md.tpr -f mdfit_dt100.xtc -o mdanalysis/pro-gyrate.xvg
echo  1 |gmx sasa -s md.tpr -f mdfit_dt100.xtc -o mdanalysis/area.xvg -or mdanalysis/resarea.xvg -oa mdanalysis/atomarea.xvg
echo  1 13 |gmx hbond -s md.tpr -f mdfit_dt100.xtc -n index.ndx -num mdanalysis/pro_lig_hnum.xvg 
mdconvert -o mdfitpro_dt100.dcd  -t mdanalysis/bf_residue.pdb mdfitpro_dt100.xtc
cp mdfit_dt100.xtc mdfitpro_dt100.dcd mdanalysis/

#FEL 20ns
mkdir FEL 
echo  1 1 |gmx trjconv -f nojump.xtc -b 20000 -s md.tpr -fit rot+trans -o pcamdfit.xtc
echo  3 3 |gmx covar -s md.gro -f pcamdfit -o eigenvalues.xvg -v eigenvectors.trr -xpma covapic.xpm
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -first 1 -last 2 -2d 2d.xvg
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -last 1 -proj pc1.xvg
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -first 2 -last 2 -proj pc2.xvg
perl ~/opt/script/sham.pl -i1 pc1.xvg -i2 pc2.xvg -data 1 -data2 1 -o gsham_pcainput.xvg
gmx sham -f gsham_pcainput.xvg -ls FEL_shampca.xpm -tsham 300
python2 ~/opt/script/xpm2txt.py -f FEL_shampca.xpm -o FEL/free-energy-landscapePCA.txt
rm -f gsham_pcainput.xvg
#RMSDRgFEL 20ns
echo  1 |gmx gyrate -s md.tpr -f pcamdfit.xtc -o FEL_gyrate.xvg
echo  1 1 |gmx rms -s  md.tpr -f pcamdfit.xtc -o FEL_rmsd.xvg
perl /home/vvc/opt/script/sham.pl -i1 FEL_rmsd.xvg -i2 FEL_gyrate.xvg -data 1 -data2 1 -o gsham_RMSDRginput.xvg
gmx sham -f gsham_RMSDRginput.xvg -ls FEL_shamRMSDRg.xpm -tsham 300
python2 ~/opt/script/xpm2txt.py -f FEL_shamRMSDRg.xpm -o FEL/free-energy-landscapeRMSDRg.txt
rm -f gsham_RMSDRginput.xvg
#gmx_mmpbsa
source conda.sh
conda activate gmxMMPBSA
mkdir mm_pbgbsa
echo  21 0 |gmx trjconv -f nojump.xtc -b 50000 -s md.tpr -dt 10 -fit rot+trans -o mdfit50_100ns.xtc -n index.ndx
cp ~/opt/script/GMX_mm/*.in mm_pbgbsa/
cp npt.tpr index.ndx mdfit50_100ns.xtc MOL.itp topol.top mm_pbgbsa/
cp -r amber14sb_parmbsc1.ff mm_pbgbsa/
rm -f  nojump.xtc mdfit*.xtc nj_cent.xtc pcamdfit.xtc eigenvalues.xvg *.xvg eigenvectors.* cov* 
cd mm_pbgbsa/
gmx_MMPBSA -O -i mmgbsa.in -cs npt.tpr -ci index.ndx -cg 1 13 -ct mdfit50_100ns.xtc  -cp topol.top -o FINAL_RESULTS_MMGBSA.dat -eo FINAL_RESULTS_MMGBSA.csv

