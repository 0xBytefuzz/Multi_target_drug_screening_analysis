import os
import pandas as pd
from datetime import datetime
from rdkit import Chem
def mkdir(path):
    folder = os.path.exists(path)

    if not folder:  # 判断是否存在文件夹如果不存在则创建为文件夹
        os.makedirs(path)  # makedirs 创建文件时如果路径不存在会创建这个路径
        print
        "---  new folder...  ---"
        print
        "---  OK  ---"

    else:
        print
        "---  There is this folder!  ---"
def finder(pattern, root='.'):
    matches = []
    dirs = []
    for x in os.listdir(root):
        nd = os.path.join(root, x)
        if os.path.isdir(nd):
            dirs.append(nd)
        elif os.path.isfile(nd) and pattern in x:
            matches.append(nd)
    for match in matches:
        print( "find molecular file is %s " % match.split("/")[1])
    for dir in dirs:
            finder(pattern, root=dir)
    return matches
path = "./" #文件目录
Molecular_number = 1 #写入分子编号，防止同分异构体cas号重复
keyword = "edurg" # 定义关键字
all_MOL_file = finder(keyword,root =path )
print(all_MOL_file)
# com_molecular_file_name = all_file[0]
# print("The file you need to split is %s, The split output directory is %s"  %(com_molecular_file_name,outpath))
# tcm_all = Chem.SDMolSupplier(com_molecular_file_name)
# count = len(tcm_all)
# for mol1 in tcm_all:
#         name = mol1.GetProp('_Name')
#         propNames = list(mol1.GetPropNames())
#         mol_name = mol1.GetProp('cas')
#         mol_name = str(mol_name)
#        # mol_name = mol_name.split(":")[1]
#         mol_name = mol_name.strip()
#         mol_name = keyword + "cas_" +  mol_name +"_n" + str(f_n) + ".sdf" #.split("-")[0]
#         tcm_name.append( mol_name)
#         print(tcm_name[-1])
#         f_n += 1
# print(len(tcm_name))
# print(len(set(tcm_name)))
# # 分割分子
# f = open(com_molecular_file_name,'r')
# i = 0
# end = "$$$$\n"
# seg_sdf_path = []
# while i < len(tcm_name):
#     for content in f.readlines():
#         mol_name = tcm_name[i]
#         mol_name = outpath + str(mol_name)
#         seg_sdf_path.append(mol_name)
#         f_new = open (mol_name, 'a')
#         if str(content) != "$$$$\n" :
#             v = str(content)
#             f_new.write (v)
#         else:
#             f_new.write (end)
#             f_new.close ()
#             i += 1
#             print(i)
#             print(mol_name.split("/")[2])
# print("The partition task has been completed")
# #转换分子
for mol_set in all_MOL_file:
    sdf_sup = Chem.SDMolSupplier(mol_set, removeHs=False)
    print(len(sdf_sup))
    outpath = mol_set.split("_")[1] + "SegToPdb"
    mkdir(outpath)
    for sdf_mol in sdf_sup:
        name = sdf_mol.GetProp("cas")
        name = outpath + "/" + "M" + str(Molecular_number) + "_" + str(name).strip() + ".pdb"
        print(name)
        Molecular_number += 1
        Chem.MolToPDBFile(sdf_mol, name)