//
//  Solution.h
//  booking1
//
//  Created by pulinghao on 2022/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PolygonCount : NSObject

@property (nonatomic, assign) int rhombus;

@property (nonatomic, assign) int parallelogram;

@property (nonatomic, assign) int polygon;

@property (nonatomic, assign) int invalid;


@end
@interface Solution : NSObject

+ (PolygonCount *)polygonCountsFromLines:(NSArray *)lines;
@end

NS_ASSUME_NONNULL_END
