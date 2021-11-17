# Multi-target-drug-screening-analysis
#### 使用方法

本地目录下执行python Multi-target-drug-screening.py

log文件存放

**每个靶点日志文件**存放在当前目录（脚本也位于当前目录）

执行脚本**python  ./Multi-target-drug-screening.py**

##### 控制 

**主要参数**

rule = re.compile('^[A-Z]{1}.*$') **#正则表达式用于控参与分析的log文件**

Threshold_value_a = -6.5 **#该值用于控制参与多靶点击中分析结合能阈值**

Threshold_value_b = -8  **#该值用于控制单个靶点击中分析结果**

multi_target_threshold = 10 **#该值用于控制多靶点筛选结果top10**

#### 分析结果

单个靶点结果文件**XXXX—target.txt**

多个靶标及击中次数文件位于**Multi-target-result**
