//
//  Block.m
//  Block
//
//  Created by pulinghao on 2022/8/17.
//

#import "Block.h"

@implementation Block

- (id)getBlockArray{
    int val = 10;
    return [[NSArray alloc] initWithObjects:^{NSLog(@"blk0:%d",val);},^{NSLog(@"blk1:%d",val);}, nil];
}


- (id)getBlockArraySafeInMRC{
    int val = 10;
    return [[NSArray alloc] initWithObjects:[^{NSLog(@"blk0:%d",val);} copy],[^{NSLog(@"blk1:%d",val);} copy], nil];
}

- (void)dealloc{
    NSLog(@"block dealloc");
}

@end
