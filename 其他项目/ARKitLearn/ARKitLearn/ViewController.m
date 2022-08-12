//
//  ViewController.m
//  ARKitLearn
//
//  Created by pulinghao on 2022/6/16.
//

#import "ViewController.h"
#import <ARKit/ARKit.h>

@interface ViewController () <ARSessionDelegate,ARSessionObserver,ARSCNViewDelegate>

// ====AR Kit 三件套 ====
@property (nonatomic, strong) ARSession *arSession API_AVAILABLE(ios(11.0));
@property (nonatomic, strong) ARWorldTrackingConfiguration *arWorldTrackingConfiguration API_AVAILABLE(ios(11.0));
@property (nonatomic, assign) BOOL isARSessionRunning  API_AVAILABLE(ios(11.0));//标志位(判断ARSession是否正在运行）



// =====室外AR 模式=======
@property (nonatomic, strong) ARSCNView *arSCNView   API_AVAILABLE(ios(11.0)); //室外AR模式

@property (nonatomic, strong) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button = [[UIButton alloc] init];
    self.button.frame = CGRectMake(10, 20, 100, 50);
    self.button.backgroundColor = [UIColor redColor];
    
    [self.button addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
    self.arSession = [[ARSession alloc] init];
    self.arSession.delegate = self;

    
    self.arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds options:nil];
    self.arSCNView.scene = [SCNScene new];
    self.arSCNView.session = self.arSession;
    self.arSCNView.delegate = self;
    self.arSCNView.backgroundColor = [UIColor clearColor];
//        这个必须add，否则会一片空白
    [self.view addSubview:self.arSCNView];
    [self.view addSubview:self.button];

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
    }
    
    [self runARCamera];
    
}

- (void)runARCamera API_AVAILABLE(ios(11.0)){
    if (@available(iOS 11.0, *)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.arSession runWithConfiguration:self.arWorldTrackingConfiguration];
        });
        
        [self setIsARSessionRunning:YES];
    }
}
#pragma mark - ARSessionDelegate
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame API_AVAILABLE(ios(11.0)){
    NSLog(@"session didUpdateFrame");
}

- (void)session:(ARSession *)session didOutputAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer{
    NSLog(@"session audioSampleBuffer");
}


#pragma mark - ARSessionObserver
- (void)sessionWasInterrupted:(ARSession *)session API_AVAILABLE(ios(11.0)){
    [self setIsARSessionRunning:NO];
//    NSLog(@"暂停");
}

- (void)sessionInterruptionEnded:(ARSession *)session API_AVAILABLE(ios(11.0)){
    [self setIsARSessionRunning:YES];
//    NSLog(@"启动");
}


- (void)pause{
    self.isARSessionRunning = !self.isARSessionRunning;
    if (self.isARSessionRunning) {
        [self runARCamera];
    } else {
        [self.arSession pause];
    }
    
}

@end
