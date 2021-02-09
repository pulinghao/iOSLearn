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
 
    for (int i = 0; i < 10000; i++)
    {
        @autoreleasepool {
            NSNumber *number = [NSNumber numberWithInt:i];
            NSString *string = [NSString stringWithFormat:@"%@", number];
            NSLog(@"%@", string);
            text = [text stringByAppendingFormat:@"%@ &", string];
}
    }
    
//    NSLog(@"%@", text);
}

@end
