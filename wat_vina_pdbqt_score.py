import os
import re
from collections import Counter
path = "./"
rule = re.compile('^[a-z]{1}.*$')
Dividing_line = "-*" * 15
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
            print(match)
    for dir in dirs:
            finder(pattern, root=dir)
    return matches
log_file = finder('FDA',root =path )
f_n = len(log_file)
f_i = 0
f = open("result.txt", "w+")
d = {}
while f_i <  f_n:
    pdbqtname = log_file[f_i]
    log_result = "result" + ".txt"
    result_list = []
    for line in open(pdbqtname):
        if line.startswith('REMARK WATVINA RESULT: '):
            score = line.split(":")[1]
            d[pdbqtname] = float(score.strip())
        elif line.startswith('REMARK  status:'):
            f_i += 1
            break
d_order = sorted(d.items(), key=lambda x:x[1], reverse=False)
v = dict(d_order)
p_N = len(d_order)
p_i = 0
for sorted_mol_name in v.keys():
    if d[sorted_mol_name] < -0:
        f.write(sorted_mol_name.split(".")[1].strip("/") + "    ")
        f.write(str(v[sorted_mol_name]))
        f.write('\n')
f.write('\n')
f.close()
print ("Completed {pdbqt_n} PDBQT file docking score extraction".format(pdbqt_n=p_N))
