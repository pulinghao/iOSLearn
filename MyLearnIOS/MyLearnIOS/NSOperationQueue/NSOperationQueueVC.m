//
//  NSOperationQueueVC.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/8/9.
//

#import "NSOperationQueueVC.h"
#import "PLHThread.h"

@interface NSOperationQueueVC ()

@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) PLHThread *thread;
@property (nonatomic, strong) UIButton *btn1;

@end

@implementation NSOperationQueueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookupTheInfo:) name:@"kFirstToSecondNotification" object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 100, 40)];
    _label.textColor = [UIColor blueColor];
    _label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:_label];
    
    self.thread = [[PLHThread alloc] initWithTarget:self selector:@selector(keepAlive) object:nil];
    [self.thread start];
    
    _btn1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 210, 150, 40)];
    [_btn1 setTitle:@"在子线程发通知" forState:UIControlStateNormal];
    [_btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btn1 addTarget:self action:@selector(sendNotificationInBackgroundThread) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn1];
//    [NSRunLoop currentRunLoop]
    

}

- (void)sendNotificationInBackgroundThread{
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            NSDictionary *userInfo = @{
//                @"name":@"Notification",
//                @"age":@"18",
//                @"height":@"188cm"
//            };
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirstToSecondNotification" object:nil userInfo:userInfo];
//    }];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *userInfo = @{
                       @"name":@"Notification",
                       @"age":@"18",
                       @"height":@"188cm"
                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFirstToSecondNotification" object:nil userInfo:userInfo];
    });
}


/// 线程保活
- (void)keepAlive{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"plh"];
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
    
}

- (void)test{
    NSLog(@"NSOpertaionVC Thread test");
    NSLog(@"NSOpertaionVC test on %@", [NSThread currentThread]);
}

- (void)lookupTheInfo:(NSNotification *)noti{
    NSDictionary *info = noti.userInfo;
    NSString *st = [info objectForKey:@"name"];
//    _label.text = st;
//    [_label sizeToFit];


    NSLog(@"NSOpertaionVC %@",info);
    
}

- (void)doSomething
{
    NSLog(@"NSOpertaion QueueVC do Something");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
