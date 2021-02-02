//
//  MutiDelegateDemo2.m
//  MyLearnIOS
//
//  Created by pulinghao on 2021/2/1.
//

#import "MutiDelegateDemo2.h"

@implementation MutiDelegateDemo2

- (NSNumber *)getId
{
    NSLog(@"Demo2 return nil");
    return nil;
}

- (int)getInt
{
    NSLog(@"Demo2 return 4");
    return 4;
}

- (void)getNoReturn
{
    NSLog(@"Demo2 get no return ");
}

@end
