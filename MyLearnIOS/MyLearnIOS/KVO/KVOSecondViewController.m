//
//  KVOSecondViewController.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//

#import "KVOSecondViewController.h"
#import "KVOPerson.h"



static void *BWNaviGPSLocationObserverContext = &BWNaviGPSLocationObserverContext;   //借鉴AFN的思路，把静态指针的地址，赋值给静态指针，static void *A; A = &A;
static void *BWNaviVPSLocationObserverContext = &BWNaviVPSLocationObserverContext;


@interface KVOSecondViewController ()

@property (nonatomic, strong) KVOPerson *p;
@end

@implementation KVOSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _p = [[KVOPerson alloc] init];
    [_p addObserver:self forKeyPath:@"fullName" options: NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fullName"]) {
        NSLog(@"%@",change);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    _p.steps ++;
    _p.firstName = @"Tom";
    _p.lastName = @"Joe";
}

- (void)dealloc
{
      
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
