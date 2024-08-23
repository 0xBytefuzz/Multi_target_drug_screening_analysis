import os
import shutil

# 定义文件路径和标签名
prmtop = "/home/wb/disk/S/s_gyf/pro_go_mol/go_pro_mol/top/system.prmtop"
tag_name = "Immobilized_XylB"

# 定义计算相关参数
residue_range = "1361-1608"  # ${residue_range}
lig_id = "1609"  # ${lig_id}
key_id = "1610"  # ${key_id}

go_rang="1-1328" 
pei_pda_range="1329-1344"
go_pei_pda_range="1-1344" 

distA_id1 = "15213"  # ${distA-id1}
distA_id2 = "15225"  # ${distA-id2}

distB_id1 = "15219"  # ${distB-id1}
distB_id2 = "13783"  # ${distB-id2}

# 获取当前所在文件夹的名称
current_dir = os.getcwd()
object_name = os.path.basename(current_dir)
object_ana = os.path.join(current_dir, f"{object_name}ana_result")

# 检测并创建结果文件夹
os.makedirs(object_ana, exist_ok=True)

# 在object_ana目录下建立各个结果文件夹
folders = ["proRMSD", "ligpocketRMSD", "keypocketRMSD", "ligRMSD", "proRMSF", "key1DIST", "cproligDIST", "proRG", "proSASA", "proinHn", "proligHn", "prokeyHn", "pro-gopdapeiDIST", "pro-gopdapeiHn", "go-pdapeiHn"]

for folder in folders:
    os.makedirs(os.path.join(object_ana, folder), exist_ok=True)

# 遍历当前文件夹下所有以md开头的文件夹
for dir_name in os.listdir(current_dir):
    if os.path.isdir(dir_name) and dir_name.startswith("mdi"):
        mdi = dir_name.split("_")[-1]
        traj = f"equil_{mdi}.nc"
        tag_result = f"{tag_name}-{mdi}"
        
        # 进入md目录
        os.chdir(dir_name)
        
        # 生成${tag_result}_cMD_ana.in文件内容
        input_content = f"""
parm {prmtop}
trajin {traj} 1 last 2
unwrap !(:WAT,Na+,Cl-)
center !(:WAT,Na+,Cl-) mass origin
image origin center familiar
reference equil_rest_{mdi}.rst
#----------------Periodic correction---------------
rms reference :{residue_range}@CA,C,O,N out {tag_result}_proRMSD.dat
rms reference :{lig_id}<@7.0&@CA,C,N out {tag_result}_ligpocketRMSD.dat
rms reference :{key_id}<@7.0&@CA,C,N out {tag_result}_keypocketRMSD.dat
rms reference :{lig_id}&!@H*= out {tag_result}_ligRMSD.dat

atomicfluct out {tag_result}_proRMSF.dat :{residue_range}@CA byres
distance d_N_S_A_{mdi} @{distA_id1} @{distA_id2} out {tag_result}_key1DIST.dat
distance d_N_S_B_{mdi} @{distB_id1} @{distB_id2} out {tag_result}_key2DIST.dat
distance pro_lig_d :{residue_range} :{lig_id} out {tag_result}_cproligDIST.dat

radgyr rg :{residue_range} out {tag_result}_proRG.dat
surf :{residue_range} out {tag_result}_proSASA.dat


hbond donormask :{residue_range}@F=,O=,N= acceptormask :{residue_range}@F=,O=,N= out {tag_result}_proinHn.dat
hbond donormask :{lig_id}@F=,O=,N= acceptormask :{residue_range}@F=,O=,N= out {tag_result}_proligHn0.dat
hbond donormask :{residue_range}@F=,O=,N= acceptormask :{lig_id}@F=,O=,N= out {tag_result}_proligHn1.dat

hbond donormask :{key_id}@F=,O=,N= acceptormask :{residue_range}@F=,O=,N= out {tag_result}_prokeyHn0.dat
hbond donormask :{residue_range}@F=,O=,N= acceptormask :{key_id}@F=,O=,N= out {tag_result}_prokeyHn1.dat

#go_rang="1-1328" 
#pei_pda_range="1329-1344"
#go_pei_pda_range="1-1344" 
#"pro-gopdapeiDIST", "pro-gopdapeiHn", "go-pdapeiHn"

distance pro_gopeipda_d :{go_pei_pda_range} :{residue_range} out {tag_result}_pro_gopeipdaDIST.dat
hbond donormask :{go_rang}@F=,O=,N= acceptormask :{pei_pda_range}@F=,O=,N= out {tag_result}_go-pdapeiHn0.dat
hbond donormask :{pei_pda_range}@F=,O=,N= acceptormask :{go_rang}@F=,O=,N= out {tag_result}_go-pdapeiHn1.dat
hbond donormask :{residue_range}@F=,O=,N= acceptormask :{go_pei_pda_range}@F=,O=,N= out {tag_result}_pro-gopdapeiHn0.dat
hbond donormask :{go_pei_pda_range}@F=,O=,N= acceptormask :{residue_range}@F=,O=,N= out {tag_result}_pro-gopdapeiHn1.dat

go
"""
        
        with open(f"{tag_result}_cMD_ana.in", "w") as f:
            f.write(input_content)
        
        # 执行cpptraj命令
        os.system(f"cpptraj -i {tag_result}_cMD_ana.in")
        #"pro-gopdapeiDIST", "prokeyHn", "pro-gopdapeiHn", "go-pdapeiHn"
        # 复制结果文件至对应的文件夹
        result_files = {
            f"{tag_result}_proRMSD.dat": "proRMSD",
            f"{tag_result}_ligpocketRMSD.dat": "ligpocketRMSD",
            f"{tag_result}_keypocketRMSD.dat": "keypocketRMSD",
            f"{tag_result}_ligRMSD.dat": "ligRMSD",
            f"{tag_result}_proRMSF.dat": "proRMSF",
            f"{tag_result}_key1DIST.dat": "key1DIST",
            f"{tag_result}_key2DIST.dat": "key1DIST",
            f"{tag_result}_cproligDIST.dat": "cproligDIST",
            f"{tag_result}_proRG.dat": "proRG",
            f"{tag_result}_proSASA.dat": "proSASA",
            f"{tag_result}_proinHn.dat": "proinHn",
            f"{tag_result}_proligHn0.dat": "proligHn",
            f"{tag_result}_proligHn1.dat": "proligHn",            
            f"{tag_result}_pro_gopeipdaDIST.dat": "pro-gopdapeiDIST",
            f"{tag_result}_prokeyHn0.dat": "prokeyHn",
            f"{tag_result}_prokeyHn1.dat": "prokeyHn",                
            f"{tag_result}_go-pdapeiHn0.dat": "go-pdapeiHn",
            f"{tag_result}_go-pdapeiHn1.dat": "go-pdapeiHn",            
            f"{tag_result}_pro-gopdapeiHn0.dat": "pro-gopdapeiHn",
            f"{tag_result}_pro-gopdapeiHn1.dat": "pro-gopdapeiHn"
        }
        
        for result_file, dest_folder in result_files.items():
            if os.path.exists(result_file):
                shutil.copy(result_file, os.path.join(object_ana, dest_folder))
        
        # 返回到初始目录
        os.chdir(current_dir)

print("分析完成")
