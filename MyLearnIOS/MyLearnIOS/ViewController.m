//
//  ViewController.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/1/16.
//

#import "ViewController.h"
#import "KVOPerson.h"
#import "RuntimeLearn.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    RuntimeLearn *runteim = [[RuntimeLearn alloc] init];
    
    [runteim exchangeMethod];
}


@end
