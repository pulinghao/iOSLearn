//
//  GCDViewController.m
//  GCDTimer
//
//  Created by pulinghao on 2022/8/19.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@property(nonatomic, assign) NSInteger num;
@property(nonatomic, strong) dispatch_source_t timer;

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.num = 0;
    // 创建一个定时器
    dispatch_source_t sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    self.timer = sourceTimer; //持有

    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(2.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(sourceTimer, start, interval, 0);
    // 设置回调
//    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(sourceTimer, ^{
        NSLog(@"num = %ld", self.num ++); //注意：需要使用weakSelf，不然会内存泄漏
        if (self.num == 10) {
            dispatch_source_cancel(self.timer);
        }
    });
    // 启动定时器
    dispatch_resume(sourceTimer);
    NSLog(@"定时器开始工作");
}

- (void)dealloc {
    NSLog(@"DetailViewController dealloc");
    // 如果前面block回调使用了weakSelf，那么cancel可以写在这里
//    dispatch_source_cancel(self.timer);
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
