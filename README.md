# 基于FPGA的乒乓球捡球机器人

第六届   全国大学生集成电路创新创业大赛   参赛作品

## 一、简介：

基于Intel Cyclone IV 平台设计、仿真并实现了一台捡球机器人。系统具有视觉识别、自主跟踪、自主避障、语音提示等功能。实现了搜寻、搜集乒乓球并且进行语音播报的功能。

效果演示

 ![小车演示](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202303120131245.gif)




## 二、架构设计 

![image-20230220222701518](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202227595.png)

机器人的整体结构如图所示，采用Intel Cyclone IV作为逻辑电路的设计平台，外部配合激光测距模块，图像识别模块k210作为机器人的视觉传感系统。其中激光测距模块用于检测30cm范围内是否有行人出现，用于机器人的避障。K210模块用于识别小球的位置，发送给fpga主控芯片用于判断机器人的转向。同时配合语音播报模块作为机器人的人机交互系统播报机器人的运动状态，提醒周边行人避让；配合电机驱动电路，控制四个麦克萨姆轮和毛刷滚轴，识别球场上散落的乒乓球，驱动机器人前往球的位置，并且实现捡球功能。

## 三、控制电路

​	控制部分，主要控制四个麦克萨姆轮的运动，为此设计了H桥直流电机驱动电路。由此，通过4路PWM信号的输出以及8路高低控制电平，即可实现对麦克萨姆轮正反转以及转速的控制，实现机器人的全向移动。

由4个PWM输出模块，结合8路高低电平，H桥驱动电路，即可实现对于4个直流电机的转动控制。

再结合一个译码器电路，即可整合4个电机，配合机器人做移动。

![image-20230220223142316](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202231418.png) 

图 机器人的移动控制模块

根据state状态量，选择机器人的不同移动方式，译码器负责根据state状态量，输出对应的占空比，控制PWM模块。

## 四、传感系统

#### 4.1 红外测距模块

选用夏普公司的GP2Y0A21红外距离传感器，该传感器能将距离转换成模拟量进行输出。我们设计了一个比较器电路，将模拟量转换成数字量进行输出。通过电位器，可以调整距离阈值。经过测试，在前方20cm内没有物体，输出高电平；有物体，则输出低电平，满足了设计需要。

![image-20230220222734911](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202227953.png)

图  比较器电路

#### 4.2 语音合成模块

采用了XFS5152CE语音合成芯片，通过IIC进行通信。为此，FPGA需要编写IIC时序逻辑，与模块进行通信。

#### 4.3 k210模块

勘智K210模块带有摄像头，可用于物体位置的识别。将小球的位置信息传给FPGA芯片，用于控制小车转向。

 在k210模块中，我们使用Cpython编写了视觉识别的算法，并将转弯信号输出给FPGA。

五、机械结构

本智能车的机械结构比较简单，机身塑料箱，左右侧壁上固定了四个直流电机。箱子顶端固定了FPGA主控板以及各种传感器，箱子前沿固定转轴刷，用于扫球。

![image-20230220223217468](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202232665.png) 

图  机器人的结构

## 五、算法系统（Algorithm）

#### 5.1 时序逻辑的实现

![image-20230220223314337](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202233376.png) 

图    IIC发送模块

编写了IIC发送模块如图所示，该模块能够实现一个字节数据的发送。8bits的待发送数据，通过I_write_data引脚输入模块，I_clk/I_rst_n/I_iic_send_en分别是时钟、复位、使能引脚。当数据发送完毕，通过O_done_flag输出引脚，通知控制芯片，数据发送完毕，可以进行下一次发送。O_sda_mode表示IO_sda的输入输出状态，当O_sda_mode为低电平时，表示IO_sda引脚为输入状态，请求IIC从设备返回ACK信号。根据这个引脚，可以方便testbench的编写，模拟从设备与模块的通信。

#### 5.2 播报时序的编写

有了IIC_send模块，可以实现一个Byte的发送。在他的前级，需要一个控制模块，控制具体发送什么数据，以及数据的发送顺序。

根据需要，编写了5个模块。分别是初始化模块、“前进”播报、“停止”播报、“左转”播报、“右转”播报模块。

![image-20230220223331835](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202233880.png) 

图   语音播报控制模块

整个语音播报系统分级结构如图所示：voice_play_control负责根据select信号，进行不同语音的播报。后级play_init/play_qianjin/play_tingzhi/play_zuohzuan/play_youzhuan分别对应初始化模块、“前进”播报、“停止”播报、“左转”播报、“右转”播报模块。MUX将多个模块的线连结起来，根据状态选择具体输出哪一路信号。



IIC时序是高电平采样，因此在SCL高电平期间，SDA信号应该保持不动，如果发生变化，则可能是开始或者停止信号。从仿真波形可以看到，主机发送了数据为(01100000)(0x60)，从设备地址为0x30，为7位地址，向左移动一位，最后一位作为读写控制。经过分析，与仿真波形进行对照，输出是正确的。

IIC信号在播报完成后，不再输出，上拉为高电平（图中IO_sda/O_scl）。当state改变后，IIC又继续输出，进行对应语音的合成播报。



#### 5.3 运动逻辑的编写

![image-20230220223348788](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202233835.png) 

图   运动逻辑

引脚说明：

| I_barrier    | 障碍物测量输入（1代表无遮挡，0表示有遮挡）                   |
| ------------ | ------------------------------------------------------------ |
| state        | 输出的状态量，控制机器人的四种移动模式（前进、左转、右转、停止） |
| I_turn_left  | 左转信号。（1代表左转）                                      |
| I_turn_right | 右转信号。（1代表右转）                                      |

 

## 六、FPGA系统总览

![image-20230220223419028](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202234118.png)

![image-20230220223405230](https://sciencebook.oss-cn-hangzhou.aliyuncs.com/202302202234345.png) 

图   系统总览

将所有的设计模块，整合成一个block。之后，就可以新建constrain文件，进行引脚的约束。



