# matlab
.m代码和.mlx代码。

## README.md
对matlab代码功能、目的进行说明

## log2array_example.m
读取simulink log生成的dataset数据类型示例程序，log2array函数例程

## log2array.m
读取simulink导出logsout变量中特定名称的信号并转换为矩阵

## function_test.m
测试各系统函数。

### firstRampTime测试
- 测试了firstRampTime函数可能可能带来的相位抖动，并以图形的方式展示了检测到的样本帧的触发沿。
- 通过循环位移样本帧模拟了长时间运行时可能触发的边界条件，保证程序的稳定运行。

### getAntIndex测试
- 用样本帧测试天线编号的检测

### interpShift测试
- 用样本帧测试循环移位，将过零点移到首位，并reshape成样本帧中的各周期。可以观察到USRP和AD4046之间的时钟偏移，但由于实际运行时，将各周期作平均，或只用一个周期，因此不会造成相位抖动

## firstRampTime.m
用于提取第一个同步斜坡信号起始时间，返回所有斜坡信号起始时间点，精确到采样时间之下，以第一个采样点为参考时间0。

## getAntIndex.m
判断触发时间对应同步信号的天线编号。

## interpShift.m
循环移位，通过线性插值实现小数位数的移位

