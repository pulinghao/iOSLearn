//
//  RunloopMonitor.h
//  MyLearnIOS
//
//  Created by pulinghao on 2021/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunloopMonitor : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitor;

@end

NS_ASSUME_NONNULL_END
