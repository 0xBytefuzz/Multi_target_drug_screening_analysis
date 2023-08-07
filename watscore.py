import os

main_folder = "out"  # 替换为你的主文件夹路径
output_file = "score.txt"  # 输出文件名

def extract_info_from_file(file_path):
    pdbqt_name = os.path.splitext(os.path.basename(file_path))[0]
    keywords = ["REMARK WATVINA RESULT:", "active torsions"]
    score = None
    torsions = None
    
    with open(file_path, "r") as file:
        lines = file.readlines()
        for line in lines:
            if keywords[0] in line:
                score_index = line.index(keywords[0]) + len(keywords[0]) + 1
                score = float(line[score_index:].split()[0])
                break
        for line in reversed(lines):
            if keywords[1] in line:
                torsions = int(line.split()[1])
                break

    return pdbqt_name, score, torsions

info_list = []

for root, _, files in os.walk(main_folder):
    for file in files:
        if file.endswith(".pdbqt"):
            file_path = os.path.join(root, file)
            pdbqt_name, score, torsions = extract_info_from_file(file_path)
            info_list.append((file, pdbqt_name, score, torsions))

# 对得分进行排序，从低到高
sorted_info = sorted(info_list, key=lambda x: x[2])

with open(output_file, "w") as output:
    for file, pdbqt_name, score, torsions in sorted_info:
        output.write(f"File: {file}, PDBQT Name: {pdbqt_name}, Score: {score}, Torsions: {torsions}\n")