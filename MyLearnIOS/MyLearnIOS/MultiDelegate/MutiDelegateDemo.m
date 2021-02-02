//
//  MutiDelegateDemo.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//

#import "MutiDelegateDemo.h"

@implementation MutiDelegateDemo
- (NSNumber *)getId
{
    NSLog(@"Demo1 return 2");
    return @2;
}

- (int)getInt
{
    NSLog(@"Demo1 return 2");
    return 2;
}

- (void)getNoReturn
{
    NSLog(@"Demo1 get no return ");
}

@end
