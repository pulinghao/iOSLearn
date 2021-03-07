//
//  AutoReleasePoolLearn.m
//  MyLearnIOS
//
//  Created by zhanghuiqiang on 2021/2/3.
//

#import "AutoReleasePoolLearn.h"

@implementation AutoReleasePoolLearn


- (void)withoutAutoreleasepoolClick
{
    NSString *text = @"text:";
    _myStr = @"mystr:";
    for (int i = 0; i < 10000; i++)
    {
        @autoreleasepool {
            NSNumber *number = [NSNumber numberWithInt:i];
            NSString *string = [NSString stringWithFormat:@"%@", number];  //这是autorelease对象
        NSString *string2 = @"123";
//            NSLog(@"%@", string);
//            text = string2;
            text = [text stringByAppendingFormat:@"%@ &", string2];  //产生autorelease对象
//            _myStr = [_myStr stringByAppendingFormat:@"%@ &", string];
        }
    }
    
//    NSLog(@"%@", text);
}

@end
