梳理简历中可能会被考察到的问题

# 技能清单

# 项目经历

## 室内导航

### 背景&目的

基于视觉定位算法，实现室内场景下的定位与导航功能。

- 视觉AR
  - 视觉定位算法，利用图像匹配算法，实现定位
  - 3D渲染引擎，主要是基于Lua脚本实现
- 步骑行
  - 室内导航系统，内容包括：获取定位点后重新算路、平面偏航与跨楼层偏航策略
  - 视觉定位算法的生命周期维护，包括算法启动、重启、停止等，捕获算法异常等问题，提供不同的交互方案

### 系统设计

- 主要还是MVC设计模式，Controller负责交互
- 封装与AR SDK通信的独立模块ARController，主要负责与AR SDK接口通信，以代理回调的方式透传数据；
- 封装与ARController及步行ViewController的桥接模块ARManager，负责与AR SDK通信，导航状态的维护，当前位姿的检测等；
- 

### 视频流

#### CVPixelBufferRef 与 CMSampleBufferRef

在iOS里，我们经常能看到 CVPixelBufferRef 这个类型，在Camera 采集返回的数据里得到一个CMSampleBufferRef，而每个CMSampleBufferRef里则包含一个 CVPixelBufferRef，在视频硬解码的返回数据里也是一个 CVPixelBufferRef。

```objective-c
CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
```



### ARKit

- 初始化

ARKit有步骑行上层的ARCameraView接管，基于此设置ARSession和ARConfiguration。初始化做了如下工作：

1. 初始化ARSession，是整个ARKit驱动的核心，并把delegate设置为self；
2. 设置ARContentView，并设置缓存大小为`1280 * 720`，这是AR区域的展示大小
3. 设置ARConfiguration为`Tracking`模式，并将输出格式设置为720
4. 不启动ARSession

```objc
- (void)setupARModule API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.0, *)) {
        self.arSession = [[ARSession alloc] init];
        self.arSession.delegate = self;

        self.arContentView = [[BMVPSARContentView alloc] initWithFrame:self.bounds BufferSize:CGSizeMake(1280, 720)];
        [self addSubview:self.arContentView];
        
        self.arWorldTrackingConfiguration = [[ARWorldTrackingConfiguration alloc] init];
        if (@available(iOS 11.3, *)) {
            NSArray *formats = [ARWorldTrackingConfiguration supportedVideoFormats];
            for (ARVideoFormat *format in formats) {
                if (format.imageResolution.height == 720) {
                    self.arWorldTrackingConfiguration.videoFormat = format;
                }
            }
            self.arWorldTrackingConfiguration.autoFocusEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
        [self setIsARSessionRunning:NO];
        
        self.vpsView = [[BMVPSView alloc] initWithFrame:self.bounds];
        self.vpsView.delegate = self;
        [self addSubview:self.vpsView];
    }
}
```

- ARKit的启动

这里`异步`插入并发队列，将ARKit放在子线程中运行，没有问题。避免主线程卡死！

```objective-c
- (void)runARCamera API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.0, *)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.arSession runWithConfiguration:self.arWorldTrackingConfiguration];
        });
        
        [self setIsARSessionRunning:YES];
    }
}
```

- ARKit 回调的数据

ARKit的回调数据，封装在ARFrame中，里面有：

- `capturedImage`：`CVPixelBufferRef`的图像数据
- `camera`：获取Image的camera，通过camera的相机数据，可以得到当前相机在空间坐标系的位置，具体看高度检测

```objective-c
#pragma mark - ARSessionDelegate
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame API_AVAILABLE(ios(11.0)){
    if(self.mode == BMVPSCameraIndoorAR || self.mode == BMVPSCameraOutdoorAR){
        if (_delegate && [_delegate respondsToSelector:@selector(captureARFrame:)]) {
            [_delegate captureARFrame:frame];
        }
    }
}
```

- 监测ARSession的开启与关闭

ARKit本身不提供状态监听接口，需要遵守`ARSessionObserver`协议。为了检测ARKit被中断和启动，需要自己设置一个标志位。

```objective-c
@property (nonatomic, assign) BOOL isARSessionRunning  API_AVAILABLE(ios(11.0));//标志位(判断ARSession是否正在运行）

#pragma mark - ARSessionObserver
- (void)sessionWasInterrupted:(ARSession *)session API_AVAILABLE(ios(11.0)){
    [self setIsARSessionRunning:NO];
}

- (void)sessionInterruptionEnded:(ARSession *)session API_AVAILABLE(ios(11.0)){
    [self setIsARSessionRunning:YES];
}
```



### CoreMotion

### 高度检测

方案一：使用ARKit的3D坐标

```objective-c
 // 拿到ARFrame后，侦测用户是否有高度的变化(识别用户是否在电梯上）
simd_float4x4 transform = frame.camera.transform;
SCNMatrix4 mat = SCNMatrix4FromMat4(transform);
SCNVector3 pos = SCNVector3Make(mat.m41,mat.m42 ,mat.m43);
[self.vpsController saveCurrentHeight:pos.y];
```

方案二：使用气压计



## VPS室内定位



