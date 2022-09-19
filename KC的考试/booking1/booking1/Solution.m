//
//  Solution.m
//  booking1
//
//  Created by pulinghao on 2022/9/17.
//

#import "Solution.h"



@implementation PolygonCount



@end

@implementation Solution

+ (BOOL)isPolygons:(NSArray *)line{
    if (line.count < 4) {
        return NO;
    }
    
    for (int i = 0; i < line.count; i++) {
        NSInteger l = [[line objectAtIndex:i] integerValue];
        if (l <= 0) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)isRhombus:(NSArray *)line{
    if (line.count != 4) {
        return NO;
    } else {
        NSInteger line1 = [line[0] integerValue];
        NSInteger line2 = [line[1] integerValue];
        NSInteger line3 = [line[2] integerValue];
        NSInteger line4 = [line[3] integerValue];
        if (line1 == line2 && line2 == line3 && line3 == line4) {
            return YES;
        } else {
            return NO;
        }
    }
}

+ (BOOL)isParallelogram:(NSArray *)line{
    if (line.count != 4) {
        return NO;
    } else {
        if ([Solution isRhombus:line]) {
            return NO;
        } else {
            NSArray *sortline = [line sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                if ([obj1 integerValue] < [obj2 integerValue]){
                    return NSOrderedAscending;
                }
                return NSOrderedDescending;
            }];
            
            NSInteger line1 = [sortline[0] integerValue];
            NSInteger line2 = [sortline[1] integerValue];
            NSInteger line3 = [sortline[2] integerValue];
            NSInteger line4 = [sortline[3] integerValue];
            if (line1 == line2 && line3 == line4) {
                return YES;
            } else {
                return NO;
            }
        }
    }
}


+ (PolygonCount *)polygonCountsFromLines:(NSArray *)lines {
    // please add your code here
    NSMutableArray *res = [[NSMutableArray alloc] init];
    PolygonCount *count = [[PolygonCount alloc] init];
    for (int i = 0; i < lines.count; i++) {
        NSString *line = [lines objectAtIndex:i];
        NSArray *lineArray = [line componentsSeparatedByString:@" "];
        
        if (![Solution isPolygons:lineArray]) {
            count.invalid++;
        } else {
            if ([Solution isRhombus:lineArray]) {
                count.rhombus++;
            } else {
                if ([Solution isParallelogram:lineArray]) {
                    count.parallelogram++;
                } else {
                    count.polygon++;
                }
            }
        }
    }
    return count;
}
    
@end
