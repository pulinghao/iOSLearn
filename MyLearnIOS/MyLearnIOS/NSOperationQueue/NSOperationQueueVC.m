//
//  NSOperationQueueVC.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/8/9.
//

#import "NSOperationQueueVC.h"

@interface NSOperationQueueVC ()

@property (nonatomic, strong) UILabel* label;

@end

@implementation NSOperationQueueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookupTheInfo:) name:@"kFirstToSecondNotification" object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor blueColor];
    _label.font = [UIFont systemFontOfSize:32];
    [self.view addSubview:_label];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    
}


- (void)lookupTheInfo:(NSNotification *)noti{
    NSDictionary *info = noti.userInfo;
    NSString *st = [info objectForKey:@"name"];
    _label.text = st;
    [_label sizeToFit];

    
    
    
    NSLog(@"%@",info);
    
}

- (void)doSomething
{
    NSLog(@"NSOpertaion QueueVC do Something");
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
