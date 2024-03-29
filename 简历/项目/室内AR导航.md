# 室内AR导航

解决室内导航的问题

# 现状

室内导航（定位）的主流方案：基于蓝牙的iBeacon方案及WIFI的方案

|        | 蓝牙                           | WIFI                         |
| ------ | ------------------------------ | ---------------------------- |
| 原理   | 部署蓝牙设备，基于信号反射定位 | 基于Wifi的强弱估算定位       |
| 成本   | 高，需要部署硬件设备           | 低（商场一般都部署免费WiFi） |
| 平台   | Android/iOS                    | Android                      |
| 精度   | 1-2米级                        | 5米级                        |
| 可用性 | 较好                           | 较差，偏航率较高             |

# 挑战

## 1. 平面导航 -> 空间立体导航

新增一个维度——高度

- 用户偏航状态的判断，多交互
- 如何判断用户的高度状态

|      | 加速度计                                   | 视觉信息                         | 气压计                             |
| ---- | ------------------------------------------ | -------------------------------- | ---------------------------------- |
| 优势 | 灵敏度好                                   | 基于视觉获取Z轴方向变化          | 灵敏度好，反应及时                 |
| 劣势 | 误判率较高，加速度特征不明显，需要复杂计算 | 相似场景（直梯）下，Bad Case率高 | iOS全机型支持；Android高度机型支持 |
| 实际 | 未使用                                     | 部分使用                         | 按照机型使用                       |



## 2. 多状态、多时态、多信号源数据

### 多状态：

- 扫描态（获取首帧定位）
- 导航态（正常导航）
- 偏航态（偏离路线）
- 跨楼层态
- 终止态

导航过程中，存在多个状态的切换

解决方案：

- 按照导航内部状态+用户交互状态+定位状态，三者融合

- 从一个状态切换到另外一个状态，需要满足哪些条件
- 分层设计的思想，自低向上，根据定位状态、用户交互状态，驱动上层UI的展示
- 合理利用锁、同步队列等，解决多线程的调度（例如网络线程与定位线程不在一个线程中），数据同步的问题

#### 解决措施：状态机+MVVM模型

使用状态机的优势

- 导航是一个过程，系统主要是在各个状态之间进行切换（扫描态、导航态、跨楼层态、偏航态、终止态）
- 结构清晰，明确业务边界，便于定位问题
- 状态驱动业务逻辑，当某个状态改变时，能够知道当前处在哪个阶段，符合MVVM的模式

在每个状态下，设置对应的处理方式，并更新视图

### 多时序：

- 扫描阶段
- 导航阶段

### 多输入源：

- 定位信号（平面坐标）
- 朝向信息（角度）
- 高度信息
- 加速度信息（用于判断用户的手机姿势）

#### 串行任务队列

对于存在竞争关系的输入源：使用串行的任务队列，提交消息；

例如定位信号和朝向信息，都是刷新图区UI的，可以放在主队列中，一起提交

高度信息和加速度信息，可以分别放在子线程中；当某个输入源的数据异常时，中断主流程，切换到对应的异常状态



## 3. 资源竞争

CoreMotion多实例引起的线上大面积崩溃问题.

问题表现：在进入导航的过程中， 由于业务方和定位方，都在子线程中创建了CoreMotion。由于CoreMotion的接口是独立创建的，但是CoreMotion在系统内部，其实是一个单例。因此，会引起崩溃

改造CoreMotion的访问方式



# 收益

##  产品指标

单个商场的PV均值 200-300，峰值在500左右

## 技术指标

首帧定位成功率 87%，10% 场景相似（定位失败）；3%算法异常

|          | AR                                        | 蓝牙                                 |
| -------- | ----------------------------------------- | ------------------------------------ |
| 定位精度 | 1米以内                                   | 1-2米                                |
| 偏航率   | 50米 0%<br>100米  12%<br> 200米 45%       | 50米 20%<br>100米  60%<br> 200米 70% |
| 朝向问题 | 完美解决                                  | 始终存在，因为基于地磁定位           |
| 耗电     | 高                                        | 低                                   |
| 特点     | ToB属性更好，融入商家定制的3D元素，有交互 | 简单的交互                           |

