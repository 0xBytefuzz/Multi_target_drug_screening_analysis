#!/bin/bash
#routine analysis dt100
echo "Analysis of gromacs simulation results !"
project_path=$(cd `dirname $0`; pwd)
project_name=${project_path##*/}
echo $project_path
echo $project_name
mkdir $project_name

echo  0 0 |gmx trjconv -f md.xtc -s md.tpr -o nojump.xtc -pbc nojump -ur compact -center
echo  21 0 |gmx trjconv -f nojump.xtc -s  md.tpr -dt 100 -fit rot+trans -o mdfit_dt100.xtc -n index.ndx
echo  1 1 |gmx trjconv -f nojump.xtc -dt 100 -s  md.tpr -fit rot+trans -o mdfitpro_dt100.xtc -n index.ndx
echo  4 4 |gmx rms -s md.tpr -f mdfit_dt100.xtc -tu ns -o $project_name/pro-bkbone-rmsd.xvg -n index.ndx
echo  1 |gmx rmsf -s md.tpr -f mdfit_dt100.xtc -b 20000 -o $project_name/pro-rmsf.xvg -ox $project_name/com-avg.pdb -oq $project_name/bf_residue.pdb -res
echo  1 |gmx gyrate -s md.tpr -f mdfit_dt100.xtc -o $project_name/pro-gyrate.xvg
echo  1 |gmx sasa -s md.tpr -f mdfit_dt100.xtc -o $project_name/area.xvg -or $project_name/resarea.xvg -oa $project_name/atomarea.xvg
echo  1 13 |gmx hbond -s md.tpr -f mdfit_dt100.xtc -n index.ndx -num $project_name/pro_lig_hnum.xvg 
mdconvert -o mdfitpro_dt100.dcd  -t $project_name/bf_residue.pdb mdfitpro_dt100.xtc
cp mdfit_dt100.xtc mdfitpro_dt100.dcd $project_name/

#FEL 20ns
mkdir $project_name/FEL 
echo  1 1 |gmx trjconv -f nojump.xtc -b 20000 -s md.tpr -fit rot+trans -o pcamdfit.xtc
echo  3 3 |gmx covar -s md.gro -f pcamdfit -o eigenvalues.xvg -v eigenvectors.trr -xpma covapic.xpm
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -first 1 -last 2 -2d 2d.xvg
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -last 1 -proj pc1.xvg
echo  3 3 |gmx anaeig -f pcamdfit -s md.gro -v eigenvectors.trr -first 2 -last 2 -proj pc2.xvg
perl ~/opt/script/sham.pl -i1 pc1.xvg -i2 pc2.xvg -data 1 -data2 1 -o gsham_pcainput.xvg
gmx sham -f gsham_pcainput.xvg -ls FEL_shampca.xpm -tsham 300
python2 ~/opt/script/xpm2txt.py -f FEL_shampca.xpm -o $project_name/FEL/free-energy-landscapePCA.txt
rm -f gsham_pcainput.xvg
#RMSDRgFEL 20ns
echo  1 |gmx gyrate -s md.tpr -f pcamdfit.xtc -o FEL_gyrate.xvg
echo  1 1 |gmx rms -s  md.tpr -f pcamdfit.xtc -o FEL_rmsd.xvg
perl ~/opt/script/sham.pl -i1 FEL_rmsd.xvg -i2 FEL_gyrate.xvg -data 1 -data2 1 -o gsham_RMSDRginput.xvg
gmx sham -f gsham_RMSDRginput.xvg -ls FEL_shamRMSDRg.xpm -tsham 300
python2 ~/opt/script/xpm2txt.py -f FEL_shamRMSDRg.xpm -o $project_name/FEL/free-energy-landscapeRMSDRg.txt
rm -f gsham_RMSDRginput.xvg
#gmx_mmpbsa
source /home/wuya/miniconda3/etc/profile.d/conda.sh
conda activate gmxMMPBSA
mkdir gmx_MMPBSA
mkdir $project_name/mm_gbsa
mkdir $project_name/mm_pbsa
echo  0 0 |gmx trjconv -f md.xtc -s md.tpr -o nojump.xtc -pbc nojump -ur compact -center
echo  21 0 |gmx trjconv -f nojump.xtc -b 80000 -s md.tpr -dt 10 -fit rot+trans -o mdfit80_100ns.xtc -n index.ndx
cp ~/opt/script/GMX_mm/*.in gmx_MMPBSA/
cp npt.tpr index.ndx mdfit80_100ns.xtc MOL.itp topol.top gmx_MMPBSA/
cp -r amber14sb_parmbsc1.ff gmx_MMPBSA/
rm -f  nojump.xtc mdfit*.xtc nj_cent.xtc pcamdfit.xtc eigenvalues.xvg *.xvg eigenvectors.* cov* 
cd gmx_MMPBSA
gmx_MMPBSA -O -i mmgbsa.in -cs npt.tpr -ci index.ndx -cg 1 13 -ct mdfit80_100ns.xtc  -cp topol.top -o FINAL_RESULTS_MMGBSA.dat -eo FINAL_RESULTS_MMGBSA.csv -nogui
mv FINAL_RESULTS* ../$project_name/mm_gbsa
gmx_MMPBSA -O -i mmpbsa.in -cs npt.tpr -ci index.ndx -cg 1 13 -ct mdfit80_100ns.xtc  -cp topol.top -o FINAL_RESULTS_MMPBSA.dat -eo FINAL_RESULTS_MMPBSA.csv -nogui
mv FINAL_RESULTS* ../$project_name/mm_pbsa

