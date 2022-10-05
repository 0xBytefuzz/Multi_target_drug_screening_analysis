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
log_file = finder('log_',root =path )
print(log_file)
print(type(log_file))
f_n = len(log_file)
f_i = 0
m_list = open("mul_target_result.txt", "w+")
m_list.write("\n" + Dividing_line + 'score < -6 result' + Dividing_line + "\n")
while f_i <  f_n:
    logname = log_file[f_i]
    log_result = str(logname)[6:] + ".txt"
    f = open(str(log_result), "w")
    d = {}
    result_list = []
    f.write("\n" + Dividing_line + "auto-dock-vina-score-result" + Dividing_line + "\n")
    for line in open(logname):
        if line.startswith('Processing ligand'):
            mol = line.split()[2]
            mol_name = mol.strip()
            print(mol_name, end=" ")
            f.write(mol_name)
        elif line.startswith('WARNING: Check that it is large enough'):
            print("0")
            f.write(" 0")
            f.write('\n')
            d[mol_name] = int(0)
        elif line.startswith('Parse error'):
            print("0")
            f.write(" 0")
            f.write('\n')
            d[mol_name] = int(0)
        elif line.startswith('!  1'):
            score = (line[5:14])
            print(score)
            f.write(" " + score)
            f.write('\n')
            d[mol_name] = float(score.strip())
        elif line.startswith('An internal error'):
            print("0")
            f.write(" 0")
            f.write('\n')
            d[mol_name] = int(0)
        elif line.startswith('terminate called '):
            print("0")
            f.write(" 0")
            f.write('\n')
            d[mol_name] = int(0)           
    d_order = sorted(d.items(), key=lambda x: x[1], reverse=False)
    f.write("\n" + Dividing_line + 'score < -6 result' + Dividing_line + "\n")
    print("\n" + Dividing_line + 'score < -6 result' + Dividing_line + "\n")
    v = dict(d_order)
    for sorted_mol_name in v.keys():
        if d[sorted_mol_name] < -6.5:
            f.write("\n")
            f.write(str(sorted_mol_name))
            result_list.append(sorted_mol_name)
            print(sorted_mol_name)
    print("\n" + Dividing_line + 'score < -8 result' + Dividing_line + "\n")
    f.write("\n" + Dividing_line + 'score < -8 result' + Dividing_line + "\n")
    v = dict(d_order[:100])
    for sorted_mol_name in v.keys():
        if d[sorted_mol_name] < -8:
            f.write("\n")
            f.write(str(sorted_mol_name))
            print(sorted_mol_name)
            print(v[sorted_mol_name])
    f.write('\n')
    f.write(str(v))
    f.close()
    print("\n")
    f_i += 1
    m_list.write(str(logname)[6:] + "\n")
    m_list.write(str(result_list) + "\n")
Multi_target_result = []
m_result = open("mul_target_result.txt")
for line in m_result:
    if rule.match(line) :
        pass
    else:
        mol_name = line.split(",")
        num = len(mol_name)
        i = 0
        while i < num:
            mol =  mol_name[i]
            #mol =  ''.join(filter(str.isalnum, mol))
            Multi_target_result.append(mol)
            i += 1
print(len(Multi_target_result))
Counting_result = Counter(Multi_target_result)
m_list.write("\n"+ Dividing_line + "Multi-target statistical results" +Dividing_line +"\n")
print(Counting_result)
Counting_list = Counting_result.most_common(len(Counting_result))
for fda_name in Counting_list[:10]:
    print(fda_name)
    m_list.write(str(fda_name) + "\n")
m_list.close()
print("finish")