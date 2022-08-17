//
//  MyObject.m
//  Block
//
//  Created by pulinghao on 2022/8/17.
//

#import "MyObject.h"

@implementation MyObject

- (instancetype)init{
    self = [super init];
    // 会发生循环引用
//    blk_ = ^{NSLog(@"self = %@",self);};
    
    //不会发生循环引用
//    __block id tmp = self;
//    blk_ = ^{
//        NSLog(@"self = %@",tmp);
//        tmp = nil;
//    };
    return self;
}
- (void)dealloc{
    NSLog(@"dealloc");
    [super dealloc];
}

@end
