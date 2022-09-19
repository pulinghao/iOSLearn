//
//  NSArray+DeltaCoder.h
//  booking1
//
//  Created by pulinghao on 2022/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (DeltaCoder)

- (nullable NSArray *)deltaEncoded;
@end

NS_ASSUME_NONNULL_END
