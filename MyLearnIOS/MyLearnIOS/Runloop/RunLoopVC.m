//
//  RunLoopVC.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/8/10.
//

#import "RunLoopVC.h"
#import "RunLoopLearn.h"



@interface RunLoopVC ()

@end

@implementation RunLoopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[RunLoopLearn sharedInstance] startMonitor];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"plh log main queue do Something Before");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"plh log main queue do Something");
    });

    
    dispatch_block_t blk = ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"plh log main queue do Something2");
//        });
    };
    NSBlockOperation *op =[NSBlockOperation blockOperationWithBlock:blk];
    op.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"plh log main queue do Something3");
        });
    };
    [[NSOperationQueue mainQueue] addOperation:op];
    
    
    NSLog(@"plh log main queue do Something After");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[RunLoopLearn sharedInstance] stopMonitor];
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
