# fmcw_positioning_radar
基于FMCW雷达的多天线定位系统。

2018年英特尔杯嵌入式邀请赛作品。电子科技大学本科2015级：章程、许浩、管紫菁。

# 文件结构
- ad4159：ad4159评估板配置文件。
- data：存储记录的用于调试的数据。
- documents：文档和说明。
- images：系统运行截图和硬件、实验照片。
- matlab：.m代码和.mlx代码。
- mcu：单片机工程文件。
- simlink：simulink框图.slx文件。

## ad4159
- ADF4159官方软件的参数设置。
- 命名方式：ADF4159_settings_A_B_C.txt，如ADF4159_settings_2000Hz_2800MHz_3800MHz.txt。
    - A：斜坡频率
    - B：扫频起始频率
    - C：扫频结束频率

## data
- 存储记录的用于调试的数据。
- 命名方式：A_B_C_D_E_F，如psZsum_200kHz_2000rps_4rpf_4t12r_stand_fall。
    - A：重要变量
    - B：降采样后中频信号频率
    - C：斜坡频率
    - D：平均帧数
    - E：n发m收天线
    - F：测试过程关键词

## documents
文档、说明、参考资料。

## images
文档所需图片或截图。

## matlab
.m代码或函数。

## mcu
单片机工程文件。

## simulink
simulink框图.slx文件。

### usrp_4t12r_heatmap.slx
成像算法库的演示模型。

### CoorOutlierRemoverAndFilter.slx
坐标异常值剔除和滤波模块。根据帧率（fF）设置异常点剔除窗口大小和低通滤波器采样率。输出坐标相对输入坐标有0.5s左右的延时。

### DelayAndTargetOverlaying.slx
延时与目标标识叠加模块。为输入的雷达成像图叠加目标标识，这里用一个宽度为window length的正方形指示目标位置。

端口说明：
- heatMap：从“雷达成像和定位”模块输出的雷达成像。行对应y方向，列对应x方向。
- coorTar：n行2列的矩阵，n个目标的坐标，单位（m）。第1列为x坐标，第2列为y坐标。前nTar个坐标为有效坐标。
- nTar：目标的个数。
- heatMapTar：叠加了目标标识的雷达图像。

参数说明：
- window length：正方形标识的宽度
- xs：x坐标序列，单位（m）。对应heatMap的列。
- ys：y坐标序列，单位（m）。对应heatMap的行。
- tDelay：如果coorTar端口输入的目标坐标经过“坐标异常值剔除和滤波”模块的处理，会对目标坐标引入一定延时。此参数用于设置对heatMap的延时，以保证目标标识无偏移地叠加到heatMap上。
- fF：帧率。

### RadarImagingAndPositioning.slx
雷达成像和定位模块。包含雷达成像和目标检测的主要算法。参数中USRP、Hardware、Ramp Parameters板块下的参数均与硬件有关，若有调整需求，请联系作者。

端口说明：
- heatMapCar：笛卡尔坐标系的雷达图像，经过对比度调整可以直接显示。
- pMa：雷达图像最大功率值。参考该值设置Targeting Parameters板块下的background power threshold参数，保证无人状态下的pMa小于参数background power threshold。算法原理：当pMa < background power threshold时判定区域内没有目标，此时端口nTar输出的值为0。
- coorTar：n行2列的矩阵，n个目标的坐标，单位（m）。第1列为x坐标，第2列为y坐标。前nTar个坐标为有效坐标。
- nTar：目标的个数。

参数说明：参数中FFT、Imaging、Targeting Parameters板块下的参数影响了运算量和目标检测效果。
- angle FFT length：角度方向的FFT长度，设置为2的幂次方以使用更快的FFT算法。
- dis FFT length：距离方向的FFT长度，设置为2的幂次方以使用更快的FFT算法。
- y min（max）：距离方向（y 方向）的坐标范围，直接影响雷达图像的行数和坐标序列ys，单位（m）。算法原理：两个参数会将2DFFT后的矩阵在距离方向（y方向）上作截取，如果dis FFT length参数设置的FFT长度达不到y max参数要求的FFT长度，会自动截取到dis FFT length所能计算到的最远距离，此ys表示的坐标序列不再以y max为最大值。
- target number max：最大跟踪目标数量。
- average frames：滑动均值滤波的窗口宽度。算法原理：多径效应对成像造成的影响一般呈现出瞬时性，如果通过滑动均值滤波的方法平均多帧雷达图像，可以大大减弱多径效应的影响。同时均值滤波会带来与窗口长度相同的延迟。
- background power threshold：背景功率阈值。参考pMa端口输出的功率设置Targeting Parameters板块下的background power threshold参数，保证无人状态下的pMa小于参数background power threshold。算法原理：当pMa < background power threshold时判定区域内没有目标，此时端口nTar输出的值为0。
- targets relative threshold：目标功率相对与背景噪声功率比值的阈值。算法原理：以背景噪声平均值的targets relative threshold倍作为阈值对图像进行分割，高于此阈值的像素认为有目标存在。


# release note
## 2.0.0
直接运行usrp_4t12r_heatmap.slx呈现二维成像效果。
- 删除z轴成像功能。
- 删除z轴成像数据。
- 调整降采样因子由5到2，并增加距离至10m。
## 2.1.0
- 更改4根发射天线排布，由竖直排列个改为交叉排列试图用左右分布的发射天线消除水平方向的多径效应。
## 2.2.0
- 添加多目标检测模块。
- 通过滑动均值滤波减少多径效应的影响。
- 添加功率图衰减修正因子，按功率以距离的四次方衰减对功率图的幅度进行修正。
## 2.2.1
- 修复运行时不能设置目标功率相对背景功率阈值、背景阈值的问题。
## 2.2.2
- 删除多余模型设置。
- 选择离散solver。
## 2.2.3
- 更换天线切换控制板为nucleo STM32F446。
## 2.2.4
- 修复修复mcu/antenna_switch_mbed工程的板子型号问题。
- 为新的板子nucleo STM32F446精调脉冲宽度。
- 为usrp_4t12r_heatmap.slx添加tPulF参数，独立设置同步信号第一个脉冲宽度，并精调脉冲宽度，解决nucleo STM32F446运算能力较弱的问题。修复脉冲宽度带小数时引发的错误。
