//
//  TransitionViewController2.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/31.
//

#import "TransitionViewController2.h"

@interface TransitionViewController2 ()


@end

@implementation TransitionViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
