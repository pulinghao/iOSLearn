//
//  TransitionViewController1.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/31.
//
// 1. 实现转场动画协议
// 2.添加动画

#import "TransitionViewController1.h"
#import "CircleTransition.h"

@interface TransitionViewController1 () <UINavigationControllerDelegate>


@end

@implementation TransitionViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.delegate = self;
}
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    // 1. 判断跳转是哪种跳转
    if (operation == UINavigationControllerOperationPush) {
        CircleTransition *trans = [[CircleTransition alloc] init];
        return trans;
    } else {
        return nil;
    }
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
