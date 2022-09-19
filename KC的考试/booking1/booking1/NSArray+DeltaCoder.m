//
//  NSArray+DeltaCoder.m
//  booking1
//
//  Created by pulinghao on 2022/9/17.
//

#import "NSArray+DeltaCoder.h"

@implementation NSArray (DeltaCoder)

- (nullable NSArray *)deltaEncoded {
    // please add your code here
    
    if (self.count == 0) {
        return nil;
    }
    
    if (self.count == 1) {
        return self;
    }
    
    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.count; i++) {
        if (i == 0) {
            [res addObject:[self objectAtIndex:i]];
            continue;
        }
        NSInteger cur = [[self objectAtIndex:i] integerValue];
        NSInteger last = [[self objectAtIndex:i - 1] integerValue];
        NSInteger delta = cur - last;
        if (delta > 127 || delta < -127) {
            [res addObject:@(-128)];
            [res addObject:@(delta)];
        } else {
            [res addObject:@(delta)];
        }
    }
    return res;
}


@end
