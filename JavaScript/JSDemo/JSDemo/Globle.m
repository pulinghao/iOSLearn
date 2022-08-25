//
//  Globle.m
//  JSDemo
//
//  Created by pulinghao on 2022/8/23.
//

#import "Globle.h"

@implementation Globle


- (void)changeBackgroundColor:(JSValue *)value{
    NSLog(@"changeBackgroundColor");
    NSLog(@"jsvalue: %@", value);
    NSString *name = value.toString;
    self.ownerController.view.backgroundColor = [UIColor colorWithRed:value[@"r"].toDouble green:value[@"g"].toDouble blue:value[@"b"].toDouble alpha:value[@"a"].toDouble];
}


- (void)doSomething:(JSValue *)value{
    NSString *name = value[@"name"].toString;
    NSLog(@"do Something");
//    self.ownerController.view.backgroundColor = [UIColor colorWithRed:value[@"r"].toDouble green:value[@"g"].toDouble blue:value[@"b"].toDouble alpha:value[@"a"].toDouble];
}
@end
