//
//  AutoReleasePoolVC.m
//  MyLearnIOS
//
//  Created by pulinghao on 2022/6/22.
//  参考 https://www.jianshu.com/p/b6cfbeabfb14

#import "AutoReleasePoolVC.h"

@interface AutoReleasePoolVC(){
    __weak id tracePtr;
}

@end
@implementation AutoReleasePoolVC


- (void)viewDidLoad{
    [super viewDidLoad];
    
//    NSString *str = [NSString stringWithFormat:@"%@", @"ssuuuuuuuuuuuuuuuuuuuu"]; //
//
//
//    NSMutableString *str = [@"a string object" mutableCopy];
//    tracePtr = str;
    
//    NSString *str = nil;
    @autoreleasepool {
        NSString *str = [NSString stringWithFormat:@"%@", @"ssuuuuuuuuuuuuuuuuuuuu"];
        tracePtr = str;
    }
    NSLog(@"viewDidLoad tracePtr: %@", tracePtr);
    
}
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear tracePtr: %@", tracePtr);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear tracePtr: %@", tracePtr);
}


@end
