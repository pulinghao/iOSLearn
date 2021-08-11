//
//  RunLoopLearn.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/8/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunLoopLearn : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitor;

- (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
